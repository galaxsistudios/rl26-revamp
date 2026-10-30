#!/usr/bin/env python3
"""
texture_mods.py - mods/ convention for whole-texture replacements (Mini_TXPK
entries: one DDS per blobset entry), mirroring data_mods.py's per-record
JSON convention but for binary texture content, which has no meaningful
"diff" - a replacement mod file simply *is* the new .dds content.

Convention: mods/<mod-name>/textures/<entry hash>_<label>.dds, e.g.
    mods/realistic-pitch-grass/textures/7e287bb34d7c364a_broadcast.dds
The leading 16 hex digits are the target entry's index hash (FNV-1a 64 of its
logical path, see entries.py) - NOT its position, which moves whenever a game
update adds files. The <label> is purely for human readability and never
parsed. `python texture_mods.py hash-name --entry v5887:36616` prints the
prefix for an entry.

Unlike the M3MP script bundle (entry 39959, handled by build.py), each
texture is its OWN independent blobset entry with its own backup/install/
restore lifecycle via pack.py - there's no "whole bundle rebuild" step to
hook into, so this module provides its own small apply/install flow instead
of plugging into build.py's build_bundle().

Only Mini_TXPK entries (one DDS per entry) are supported here. A target
entry classified as "txpk" (many DDS files sharing one entry) needs the
directory-based inject-bundle flow in build_texture.py instead - this
module raises clearly rather than mishandling that case silently.

Usage:
    python texture_mods.py list
    python texture_mods.py apply --confirm
    python texture_mods.py apply --mod nrl-broadcast-scoreboard --confirm
"""

import argparse
import os
import re
import struct
import sys

import zstandard

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pack  # noqa: E402
import entries  # noqa: E402
import classify_entries as ce  # noqa: E402
import extract_textures as et  # noqa: E402

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODS_DIR = os.path.join(REPO_ROOT, "mods")
TEXTURE_MOD_SUBDIR = "textures"

_LEADING_HASH = re.compile(r"^([0-9a-fA-F]{16})_")


def scan_texture_mod_overrides(mods_dir=MODS_DIR):
    """Return {entry_index: (abs_dds_path, mod_name)} for every
    mods/<mod-name>/textures/<entry hash>_<label>.dds file found, resolved to
    the live index. Raises if two mods target the same entry."""
    overrides = {}
    if not os.path.isdir(mods_dir):
        return overrides
    for mod_name in sorted(os.listdir(mods_dir)):
        tex_dir = os.path.join(mods_dir, mod_name, TEXTURE_MOD_SUBDIR)
        if not os.path.isdir(tex_dir):
            continue
        for fn in sorted(os.listdir(tex_dir)):
            if not fn.lower().endswith(".dds"):
                continue
            m = _LEADING_HASH.match(fn)
            if not m:
                raise ValueError(f"{os.path.join(tex_dir, fn)}: filename must start with '<16-hex entry hash>_'")
            entry_index = entries.index_of(int(m.group(1), 16))
            if entry_index in overrides and overrides[entry_index][1] != mod_name:
                raise ValueError(
                    f"entry {entry_index} is claimed by both mods/{overrides[entry_index][1]}/ "
                    f"and mods/{mod_name}/"
                )
            overrides[entry_index] = (os.path.join(tex_dir, fn), mod_name)
    return overrides


VRAM_CHUNK_SIZE = 262144


def encode_outer_chunks(data, chunk_size=VRAM_CHUNK_SIZE):
    """Ground-truthed against Blobset Tools.dll's own texture-replacement
    path (Blobset_Tools.Modify.BlobsetV4's "dds" case, calling
    ZSTD_IO.CompressAndWrite / IO.ReadWriteModifyData) - decompiled and
    read directly after two live installs using a single giant zstd frame
    both broke the game (one crashed on load, one froze), which is what
    sent us to ground truth instead of guessing a third time.

    The real algorithm splits `data` into chunk_size (262144-byte) pieces:
    every FULL-size chunk is zstd-compressed (level 4) and written as
    [uint32 frameLen incl. itself][compressed bytes] - falling back to
    storing that chunk raw (same framing, uncompressed body) if
    compression didn't actually shrink it below chunk_size. The final,
    smaller remainder chunk (if any) is ALWAYS stored raw, never
    compressed, regardless of whether compression would have helped -
    this is IO.ReadWriteModifyData's behavior, not a fallback path, and
    was the specific detail the single-frame attempt got wrong."""
    out = bytearray()
    pos = 0
    n = len(data)
    while pos < n:
        piece = data[pos:pos + chunk_size]
        pos += len(piece)
        if len(piece) == chunk_size:
            compressed = zstandard.ZstdCompressor(level=4).compress(piece)
            if len(compressed) < chunk_size:
                out += struct.pack("<I", 4 + len(compressed)) + compressed
            else:
                out += struct.pack("<I", 4 + len(piece)) + piece
        else:
            out += struct.pack("<I", 4 + len(piece)) + piece
    if n == 0:
        out += struct.pack("<I", 4)
    return bytes(out)


def build_texture_blob(blobset_path, entry_index, dds_path):
    """Rebuild a Mini_TXPK blob for entry_index with dds_path's bytes as the
    new payload, reusing the entry's own live raw_path/image_type (always
    re-read fresh from the live blobset, never cached - same principle
    data_mods.apply_overrides follows for data records).

    Matches Blobset_Tools.Modify.BlobsetV4's own "dds" replacement path
    exactly (ground-truthed by decompiling Blobset Tools.dll): main = the
    tiny 20-byte header + NUL-terminated path string, written RAW with no
    outer framing at all (main_c == main_u, read_blob_full's "stored raw"
    branch); vram = the actual .dds file bytes, run through
    encode_outer_chunks (262144-byte chunked zstd, see its docstring).
    Earlier attempts that flattened everything into one raw "main" blob,
    and then one that framed vram as a single giant zstd frame, both broke
    live texture loading - this is the one ground-truthed against the real
    tool's own code instead of guessed.

    Returns (blob_bytes, sizes, raw_path) where sizes is the
    (main_c, main_u, vram_c, vram_u) tuple to hand to pack.do_install."""
    raw, folder, file_hash, bpath = ce.read_blob_full(blobset_path, entry_index)
    if raw is None:
        raise RuntimeError(f"entry {entry_index}: blob not found at {bpath}")
    kind, _ = ce.classify(raw[:65536])
    if kind != "mini_txpk":
        raise ValueError(
            f"entry {entry_index} is classified as {kind!r}, not mini_txpk - "
            f"multi-file TXPK bundles need build_texture.py's inject-bundle flow instead"
        )
    _path, _dds, raw_path, _w, _h, image_type = et.parse_mini_txpk(raw)
    with open(dds_path, "rb") as f:
        dds_bytes = f.read()
    if dds_bytes[:4] != b"DDS ":
        raise ValueError(f"{dds_path} is not a valid DDS (missing 'DDS ' magic)")

    new_height, new_width = struct.unpack_from("<2I", dds_bytes, 12)
    path_bytes = raw_path.encode("latin1") + b"\x00"
    main_bytes = struct.pack("<5I", new_width, new_height, image_type, 20, len(dds_bytes)) + path_bytes
    vram_bytes = encode_outer_chunks(dds_bytes)

    blob_bytes = main_bytes + vram_bytes
    sizes = (len(main_bytes), len(main_bytes), len(vram_bytes), len(dds_bytes))
    return blob_bytes, sizes, raw_path


def cmd_list(args):
    overrides = scan_texture_mod_overrides(args.mods_dir)
    if not overrides:
        print("No texture mods found.")
        return
    for entry_index, (dds_path, mod_name) in sorted(overrides.items()):
        print(f"entry {entry_index}: mods/{mod_name}/ <- {dds_path}")


def cmd_apply(args):
    ce.load_index(args.blobset)
    overrides = scan_texture_mod_overrides(args.mods_dir)
    if args.mod:
        overrides = {e: v for e, v in overrides.items() if v[1] == args.mod}
    if not overrides:
        print("No texture mods found.")
        return
    for entry_index, (dds_path, mod_name) in sorted(overrides.items()):
        if args.confirm and os.path.exists(pack.backup_meta_path(entry_index)):
            # already installed (a rerun): back to stock first - the rebuild reads the stock blob
            pack.do_restore(args.blobset, entry_index)
            ce.load_index(args.blobset)  # its cached size table still has the modded record
            print(f"entry {entry_index}: restored the earlier install")
        new_blob, sizes, raw_path = build_texture_blob(args.blobset, entry_index, dds_path)
        main_c, main_u, vram_c, vram_u = sizes
        out_path = os.path.join(pack.REPO_ROOT, "_build", f"entry_{entry_index}.miniTxpk.bin")
        os.makedirs(os.path.dirname(out_path), exist_ok=True)
        with open(out_path, "wb") as f:
            f.write(new_blob)
        print(f"entry {entry_index} (mods/{mod_name}/): rebuilt from {os.path.basename(dds_path)} "
              f"(raw_path={raw_path!r}, main={main_c}, vram_c={vram_c}, vram_u={vram_u})")
        if not args.confirm:
            continue
        result = pack.do_install(args.blobset, entry_index, out_path, confirm=True, sizes=sizes)
        print(f"  installed: new size {result['new_size']} bytes, "
              f"backup at {result['backup_meta']}")
    if not args.confirm:
        print("\nDry run (pass --confirm to actually install).")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)

    p_list = sub.add_parser("list", help="show discovered texture mods and their target entries")
    p_list.add_argument("--mods-dir", default=MODS_DIR)
    p_list.set_defaults(func=cmd_list)

    p_apply = sub.add_parser("apply", help="rebuild and install every discovered texture mod")
    p_apply.add_argument("--mods-dir", default=MODS_DIR)
    p_apply.add_argument("--blobset", default=pack.BLOBSET_PATH)
    p_apply.add_argument("--mod", default=None, help="only apply textures from mods/<MOD>/ (others may already be installed)")
    p_apply.add_argument("--confirm", action="store_true", help="required to actually install (otherwise dry run)")
    p_apply.set_defaults(func=cmd_apply)

    p_name = sub.add_parser("hash-name", help="print the <hash>_ filename prefix for an entry")
    p_name.add_argument("--entry", type=entries.arg, required=True, help="name/path/0xhash/v5887:N/index")
    p_name.set_defaults(func=lambda a: print(f"{entries.hash_at(a.entry)}_"))

    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
