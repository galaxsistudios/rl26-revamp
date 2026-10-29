#!/usr/bin/env python3
"""
build_texture.py - rebuild a texture blobset entry (Mini_TXPK: one DDS per
entry, or TXPK: a bundle of many DDS files sharing one entry) from edited
.dds file(s) and install it, reusing pack.py's existing backup/install/
restore safety net exactly like build.py does for the script bundle
(entry 39959).

Workflow for a single-texture (Mini_TXPK) entry:
    1. extract_textures.py --entry N --out DIR   (writes foo.dds + a
       foo.dds.meta.json sidecar with the entry's raw_path/width/height)
    2. edit DIR/foo.dds in any DDS-capable tool, keeping it a valid DDS
       (same or different dimensions both work - the header is
       re-derived from the new file, see rebuild_mini_txpk())
    3. python build_texture.py inject --entry N --dds DIR/foo.dds --confirm
       (backs up entry N via pack.py, rebuilds the Mini_TXPK blob, installs
       it with texture_mods.py's main/vram split - header raw in main, DDS
       chunk-framed in vram; a fully-raw main-only blob never loads in game)
    4. python pack.py restore --entry N   (to undo, same as any other entry)

Workflow for a multi-texture (TXPK) bundle entry - replace one or more
members, every other member in the bundle is re-packed byte-identical:
    1. extract_textures.py --entry N --out DIR   (writes every member .dds
       under DIR, preserving their relative paths)
    2. edit one or more of the .dds files under DIR in place
    3. python build_texture.py inject-bundle --entry N --dir DIR --confirm
       (re-reads every member's path list straight from the live entry, so
       it never needs a separate manifest; any file under DIR whose path
       matches a member and whose bytes differ from the original is swapped
       in, everything else is re-packed unchanged)
    4. python pack.py restore --entry N

Usage:
    python build_texture.py inject --entry N --dds PATH [--meta PATH] --confirm
    python build_texture.py inject-bundle --entry N --dir DIR --confirm
"""

import argparse
import json
import os
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pack  # noqa: E402
import entries  # noqa: E402
import classify_entries as ce  # noqa: E402
import extract_textures as et  # noqa: E402
import texture_mods  # noqa: E402


def cmd_inject(args):
    ce.load_index(args.blobset)

    meta_path = args.meta or (args.dds + ".meta.json")
    if os.path.exists(meta_path):
        with open(meta_path) as f:
            meta = json.load(f)
        if meta["entry_index"] != args.entry:
            raise ValueError(f"meta file {meta_path} is for entry {meta['entry_index']}, not {args.entry}")
        raw_path, image_type = meta["raw_path"], meta["image_type"]
    else:
        # fall back to re-deriving raw_path/image_type from the LIVE blob
        # (works as long as entry N hasn't already been reinstalled with a
        # different raw_path - the common case when no sidecar is handy).
        raw, folder, file_hash, bpath = ce.read_blob_full(args.blobset, args.entry)
        if raw is None:
            raise RuntimeError(f"entry {args.entry}: blob not found at {bpath}")
        kind, _ = ce.classify(raw[:65536])
        if kind != "mini_txpk":
            raise ValueError(f"entry {args.entry} is classified as {kind!r}, not mini_txpk, and no --meta sidecar was given")
        _path, _dds, raw_path, _w, _h, image_type = et.parse_mini_txpk(raw)

    with open(args.dds, "rb") as f:
        dds_bytes = f.read()

    # Same layout as texture_mods.build_texture_blob (ground-truthed against
    # Blobset Tools): raw header+path in main, DDS chunk-framed in vram.
    # Flattening everything into main (what this used to do via
    # et.rebuild_mini_txpk) installs fine but the texture never finishes
    # loading in game.
    if dds_bytes[:4] != b"DDS ":
        raise ValueError(f"{args.dds} is not a valid DDS (missing 'DDS ' magic)")
    new_height, new_width = struct.unpack_from("<2I", dds_bytes, 12)
    main_bytes = struct.pack("<5I", new_width, new_height, image_type, 20, len(dds_bytes)) + raw_path.encode("latin1") + b"\x00"
    vram_bytes = texture_mods.encode_outer_chunks(dds_bytes)
    new_blob = main_bytes + vram_bytes
    sizes = (len(main_bytes), len(main_bytes), len(vram_bytes), len(dds_bytes))

    out_path = args.out or os.path.join(pack.REPO_ROOT, "_build", f"entry_{args.entry}.miniTxpk.bin")
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, "wb") as f:
        f.write(new_blob)
    print(f"Rebuilt Mini_TXPK blob -> {out_path} ({len(new_blob)} bytes, raw_path={raw_path!r})")

    if not args.confirm:
        print("Dry run (pass --confirm to actually install). Built blob left at the path above.")
        return

    result = pack.do_install(args.blobset, args.entry, out_path, confirm=True, sizes=sizes)
    print(f"Installed: entry {result['entry_index']}'s blob ({result['blob_path']}) replaced, "
          f"new size {result['new_size']} bytes.")
    print(f"Backup recorded at {result['backup_meta']} - run 'python pack.py restore --entry {args.entry}' to undo.")


def cmd_inject_bundle(args):
    ce.load_index(args.blobset)
    raw, folder, file_hash, bpath = ce.read_blob_full(args.blobset, args.entry)
    if raw is None:
        raise RuntimeError(f"entry {args.entry}: blob not found at {bpath}")
    kind, _ = ce.classify(raw[:65536])
    if kind != "txpk":
        raise ValueError(f"entry {args.entry} is classified as {kind!r}, not txpk")

    _main_c, main_u, _vram_c, _vram_u = pack.entry_sizes(ce._INDEX_DATA, ce._SIZE_TABLE_OFF, args.entry)
    members = et.parse_txpk(raw, main_u)  # [(path_with_dds_ext, dds_bytes), ...]
    changed = []
    new_entries = []
    for path, orig_dds_bytes in members:
        local_path = os.path.join(args.dir, *path.split("/"))
        if os.path.exists(local_path):
            with open(local_path, "rb") as f:
                candidate = f.read()
            if candidate != orig_dds_bytes:
                if candidate[:4] != b"DDS ":
                    raise ValueError(f"{local_path} is not a valid DDS (missing 'DDS ' magic)")
                changed.append(path)
                new_entries.append((path[:-4], candidate))  # strip ".dds" - serialize_txpk expects bare path
                continue
        new_entries.append((path[:-4], orig_dds_bytes))

    if not changed:
        print("No member .dds files under --dir differ from the live bundle - nothing to do.")
        return

    new_blob = et.serialize_txpk(new_entries)
    out_path = args.out or os.path.join(pack.REPO_ROOT, "_build", f"entry_{args.entry}.txpk.bin")
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, "wb") as f:
        f.write(new_blob)
    print(f"Rebuilt TXPK bundle -> {out_path} ({len(new_blob)} bytes, {len(members)} members, "
          f"{len(changed)} changed):")
    for p in changed:
        print(f"    modded: {p}")

    if not args.confirm:
        print("Dry run (pass --confirm to actually install). Built blob left at the path above.")
        return

    result = pack.do_install(args.blobset, args.entry, out_path, confirm=True)
    print(f"Installed: entry {result['entry_index']}'s blob ({result['blob_path']}) replaced, "
          f"new size {result['new_size']} bytes.")
    print(f"Backup recorded at {result['backup_meta']} - run 'python pack.py restore --entry {args.entry}' to undo.")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)

    p_inject = sub.add_parser("inject", help="rebuild one Mini_TXPK entry from an edited .dds and install it")
    p_inject.add_argument("--blobset", default=pack.BLOBSET_PATH)
    p_inject.add_argument("--entry", type=entries.arg, required=True)
    p_inject.add_argument("--dds", required=True, help="the edited .dds file")
    p_inject.add_argument("--meta", default=None, help="sidecar .meta.json from extract_textures.py (default: <dds>.meta.json)")
    p_inject.add_argument("--out", default=None, help="where to write the rebuilt blob before install (default: _build/entry_N.miniTxpk.bin)")
    p_inject.add_argument("--confirm", action="store_true", help="required to actually install (otherwise just builds + prints)")
    p_inject.set_defaults(func=cmd_inject)

    p_bundle = sub.add_parser("inject-bundle", help="rebuild a TXPK bundle entry, swapping in any edited members found under --dir")
    p_bundle.add_argument("--blobset", default=pack.BLOBSET_PATH)
    p_bundle.add_argument("--entry", type=entries.arg, required=True)
    p_bundle.add_argument("--dir", required=True, help="directory previously produced by extract_textures.py --entry N --out DIR")
    p_bundle.add_argument("--out", default=None)
    p_bundle.add_argument("--confirm", action="store_true")
    p_bundle.set_defaults(func=cmd_inject_bundle)

    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
