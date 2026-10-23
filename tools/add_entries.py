#!/usr/bin/env python3
"""
add_entries.py - add NEW files to the game (not replacements) by appending
entries to data-0.blobset.pc.

How the game finds a file (verified 2026-10-23 against the live index):
  - Every index entry's u64 "hash" is FNV-1a 64 of the file's LOGICAL path,
    lowercased: e.g. fnv1a64("characters/flag/textures/flag_col.texture") is
    entry 1442's value, 3000/3000 sampled texture paths matched, and so do
    models ("props/cutscene/models/effectlocator_01.model" -> 57746) and the
    M3MP bundles ("mempacks/lua.mempack.retail" -> 39959,
    "particles/gameplay-effects.mempack" -> 57665, ...).
  - The engine lowercases before hashing: Lua asks for
    "textures/effects/lensFlareStarburst.texture" and the index only holds
    the lowercase form.
  - The hash also names the blob on disk (data/<byte7>/<bytes6..0>, see
    pack.py), and the hash table is in no particular order (entries are
    sorted by path, not by hash), so the game must look entries up by hash.
    Appending an entry at the END therefore never moves an existing entry.

Logical extensions differ from the source/debug names embedded in blobs:
textures are "<path>.texture" (not ".pc.dds"), models "<path>.model".

UNVERIFIED until tested in-game: that the game accepts a FilesCount it
didn't ship with, and loads an appended entry by its hash. See
research/adding-new-assets.md for the test procedure.

Bookkeeping lives in _backup/added_entries.json (base FilesCount, the
pre-add index snapshot, and every added entry). `remove-all` truncates the
index back to the base count - keeping any later pack.py installs to
existing entries - and deletes the added blobs.

Usage:
    python add_entries.py hash PATH
    python add_entries.py add --path NEWPATH --clone EXISTINGPATH [--confirm]
    python add_entries.py add --path NEWPATH --blob FILE --sizes MC,MU,VC,VU [--confirm]
    python add_entries.py list
    python add_entries.py remove-all [--confirm]
"""

import argparse
import glob
import json
import os
import shutil
import struct
import sys

import pack

REGISTRY_PATH = os.path.join(pack.BACKUP_DIR, "added_entries.json")
BASE_INDEX_BACKUP = os.path.join(pack.BACKUP_DIR, "added_entries.base.data-0.blobset.pc.bak")

FNV64_OFFSET = 0xCBF29CE484222325
FNV64_PRIME = 0x100000001B3
MASK64 = (1 << 64) - 1


def fnv1a64(text):
    h = FNV64_OFFSET
    for c in text.encode("utf-8"):
        h = ((h ^ c) * FNV64_PRIME) & MASK64
    return h


def path_hash(logical_path):
    return fnv1a64(logical_path.replace("\\", "/").lower())


def hash_location(h):
    b = struct.pack("<Q", h)
    folder = f"{b[7]:02x}"
    file_hash = "".join(f"{b[i]:02x}" for i in range(6, -1, -1))
    return folder, file_hash


def load_hashes(data, files_count, hash_off):
    return list(struct.unpack_from(f"<{files_count}Q", data, hash_off))


def find_entry(data, files_count, hash_off, logical_path):
    h = path_hash(logical_path)
    hashes = load_hashes(data, files_count, hash_off)
    try:
        return hashes.index(h)
    except ValueError:
        return None


def load_registry():
    if not os.path.exists(REGISTRY_PATH):
        return None
    with open(REGISTRY_PATH) as f:
        return json.load(f)


def save_registry(reg):
    os.makedirs(pack.BACKUP_DIR, exist_ok=True)
    with open(REGISTRY_PATH, "w") as f:
        json.dump(reg, f, indent=2)


def write_index(blobset_path, hashes, sizes):
    """sizes is a flat list, 4 u32 per entry."""
    n = len(hashes)
    assert len(sizes) == 4 * n
    out = struct.pack("<2I", pack.MAGIC_V4, n) + struct.pack(f"<{n}Q", *hashes) + struct.pack(f"<{4 * n}I", *sizes)
    tmp = blobset_path + ".tmp"
    with open(tmp, "wb") as f:
        f.write(out)
    os.replace(tmp, blobset_path)


# --------------------------------------------------------------------------
# commands


def cmd_hash(args):
    data, files_count, hash_off, _ = pack.read_index(args.blobset)
    h = path_hash(args.path)
    folder, file_hash = hash_location(h)
    idx = find_entry(data, files_count, hash_off, args.path)
    print(f"path   : {args.path.lower()}")
    print(f"hash   : 0x{h:016x}")
    print(f"blob   : data/{folder}/{file_hash}")
    print(f"entry  : {idx if idx is not None else 'not in index'}")


def replace_added_entry(blobset_path, logical_path, blob_bytes, new_sizes, source_desc, confirm):
    """Overwrite the blob + sizes of an entry this tool added earlier (never
    a shipped one - those go through pack.py's backup/restore)."""
    reg = load_registry() or {"entries": []}
    rec = next((e for e in reg["entries"] if e["path"] == logical_path.lower()), None)
    if rec is None:
        raise SystemExit(f"{logical_path!r} exists but wasn't added by this tool - refusing to replace a shipped file")
    data, files_count, hash_off, size_off = pack.read_index(blobset_path)
    if f"0x{load_hashes(data, files_count, hash_off)[rec['entry_index']]:016x}" != rec["hash"]:
        raise SystemExit(f"entry {rec['entry_index']} no longer holds {logical_path} - refusing")
    new_sizes = list(new_sizes)
    if len(blob_bytes) != new_sizes[0] + new_sizes[2]:
        raise SystemExit(f"blob is {len(blob_bytes)} bytes but sizes say main {new_sizes[0]} + vram {new_sizes[2]}")
    print(f"replace entry {rec['entry_index']}: {logical_path.lower()} from {source_desc}, sizes {new_sizes}")
    if not confirm:
        return rec["entry_index"]
    with open(rec["blob_path"], "wb") as f:
        f.write(blob_bytes)
    pack.write_entry_sizes(blobset_path, size_off, rec["entry_index"], *new_sizes)
    rec["sizes"], rec["source"] = new_sizes, source_desc
    save_registry(reg)
    return rec["entry_index"]


def add_entry(blobset_path, logical_path, blob_bytes, new_sizes, source_desc, confirm, replace=False):
    """Append one entry holding blob_bytes at logical_path. Returns the new
    entry index (or the would-be index on a dry run). With replace=True, an
    entry this tool added before is overwritten in place instead."""
    data, files_count, hash_off, size_off = pack.read_index(blobset_path)
    hashes = load_hashes(data, files_count, hash_off)
    sizes = list(struct.unpack_from(f"<{4 * files_count}I", data, size_off))

    new_hash = path_hash(logical_path)
    if new_hash in hashes:
        if replace:
            return replace_added_entry(blobset_path, logical_path, blob_bytes, new_sizes, source_desc, confirm)
        raise SystemExit(f"{logical_path!r} is already entry {hashes.index(new_hash)} - nothing to add (use replace)")
    folder, file_hash = hash_location(new_hash)
    new_blob = pack.blob_path(blobset_path, folder, file_hash)
    if os.path.exists(new_blob):
        raise SystemExit(f"blob file {new_blob} already exists on disk but isn't indexed - refusing to overwrite")
    new_sizes = list(new_sizes)
    if len(blob_bytes) != new_sizes[0] + new_sizes[2]:
        raise SystemExit(f"blob is {len(blob_bytes)} bytes but sizes say main {new_sizes[0]} + vram {new_sizes[2]}")

    print(f"new entry {files_count}: {logical_path.lower()}")
    print(f"  hash 0x{new_hash:016x} -> data/{folder}/{file_hash}")
    print(f"  from {source_desc}, sizes {new_sizes}")
    if not confirm:
        return files_count

    reg = load_registry()
    if reg is None:
        os.makedirs(pack.BACKUP_DIR, exist_ok=True)
        shutil.copy2(blobset_path, BASE_INDEX_BACKUP)
        reg = {
            "blobset_path": os.path.abspath(blobset_path),
            "base_files_count": files_count,
            "base_index_backup": BASE_INDEX_BACKUP,
            "entries": [],
        }
    elif files_count != reg["base_files_count"] + len(reg["entries"]):
        raise SystemExit(
            f"index has {files_count} entries, registry expects "
            f"{reg['base_files_count'] + len(reg['entries'])} - the game was probably updated; "
            f"run remove-all (or delete the registry if the game reverted it) first"
        )

    os.makedirs(os.path.dirname(new_blob), exist_ok=True)
    with open(new_blob, "wb") as f:
        f.write(blob_bytes)
    write_index(blobset_path, hashes + [new_hash], sizes + new_sizes)

    reg["entries"].append({
        "path": logical_path.lower(),
        "hash": f"0x{new_hash:016x}",
        "entry_index": files_count,
        "blob_path": new_blob,
        "sizes": new_sizes,
        "source": source_desc,
    })
    save_registry(reg)
    print(f"added. index now has {files_count + 1} entries")
    return files_count


def cmd_add(args):
    data, files_count, hash_off, size_off = pack.read_index(args.blobset)
    if args.clone:
        src = find_entry(data, files_count, hash_off, args.clone)
        if src is None:
            raise SystemExit(f"--clone {args.clone!r} is not in the index")
        src_folder, src_file = pack.entry_hash(data, hash_off, src)
        src_blob = pack.blob_path(args.blobset, src_folder, src_file)
        new_sizes = pack.entry_sizes(data, size_off, src)
        source_desc = f"clone of entry {src} ({args.clone})"
    else:
        if not (args.blob and args.sizes):
            raise SystemExit("give --clone, or both --blob and --sizes")
        src_blob = args.blob
        new_sizes = [int(x) for x in args.sizes.split(",")]
        if len(new_sizes) != 4:
            raise SystemExit("--sizes needs 4 comma-separated values: MainC,MainU,VramC,VramU")
        source_desc = f"file {args.blob}"
    with open(src_blob, "rb") as f:
        blob_bytes = f.read()
    add_entry(args.blobset, args.path, blob_bytes, new_sizes, source_desc, args.confirm)
    if not args.confirm:
        print("dry run - pass --confirm to write (close the game first)")


def cmd_list(args):
    reg = load_registry()
    if not reg:
        print("no added entries")
        return
    print(f"base FilesCount {reg['base_files_count']}")
    for e in reg["entries"]:
        print(f"  {e['entry_index']}: {e['path']}  ({e['source']})")


def cmd_remove_all(args):
    reg = load_registry()
    if not reg:
        print("no added entries")
        return
    data, files_count, hash_off, size_off = pack.read_index(args.blobset)
    base = reg["base_files_count"]
    added = reg["entries"]
    if files_count != base + len(added):
        raise SystemExit(f"index has {files_count} entries, expected {base + len(added)} - refusing")
    hashes = load_hashes(data, files_count, hash_off)
    for e in added:
        if f"0x{hashes[e['entry_index']]:016x}" != e["hash"]:
            raise SystemExit(f"entry {e['entry_index']} no longer holds {e['path']} - refusing")

    # pack.py backups taken AFTER entries were added hold the larger index; restoring them
    # once the index has shrunk would be refused, so make the user restore those first.
    for meta_path in glob.glob(os.path.join(pack.BACKUP_DIR, "entry_*.backup.json")):
        with open(meta_path) as f:
            meta = json.load(f)
        _, backup_count, _, _ = pack.read_index(meta["blobset_backup"])
        if backup_count > base:
            raise SystemExit(f"{meta_path} was installed after entries were added - restore it first")

    print(f"removing {len(added)} added entries, index back to {base}")
    if not args.confirm:
        print("dry run - pass --confirm to write (close the game first)")
        return
    sizes = list(struct.unpack_from(f"<{4 * base}I", data, size_off))
    write_index(args.blobset, hashes[:base], sizes)
    for e in added:
        if os.path.exists(e["blob_path"]):
            os.remove(e["blob_path"])
    os.remove(REGISTRY_PATH)
    print("done")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--blobset", default=pack.BLOBSET_PATH)
    sub = ap.add_subparsers(dest="cmd", required=True)

    p_hash = sub.add_parser("hash", help="print a logical path's hash, blob location and entry index")
    p_hash.add_argument("path")
    p_hash.set_defaults(func=cmd_hash)

    p_add = sub.add_parser("add", help="append a new entry")
    p_add.add_argument("--path", required=True, help="new logical path, e.g. ui/textures/sponsor/spon_x.texture")
    p_add.add_argument("--clone", help="existing logical path whose blob + sizes to copy")
    p_add.add_argument("--blob", help="blob file to use instead of --clone")
    p_add.add_argument("--sizes", help="MainC,MainU,VramC,VramU for --blob")
    p_add.add_argument("--confirm", action="store_true", help="required to actually write")
    p_add.set_defaults(func=cmd_add)

    p_list = sub.add_parser("list", help="list entries added by this tool")
    p_list.set_defaults(func=cmd_list)

    p_rm = sub.add_parser("remove-all", help="truncate the index back to its pre-add size and delete added blobs")
    p_rm.add_argument("--confirm", action="store_true", help="required to actually write")
    p_rm.set_defaults(func=cmd_remove_all)

    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    sys.exit(main())
