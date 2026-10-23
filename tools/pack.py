#!/usr/bin/env python3
"""
pack.py - status / backup / install / restore for RL26 script mods.

RL26 does NOT use RLL4's single-big-archive blobset format. Its data-0.blobset.pc
(magic "BLOB", GameInfo.ini's claimed "BlobsetVersion=3") is just a ~2.4MB INDEX
into a 77GB content-addressed blob store at data/<2-hex>/<14-hex>/ (one file per
hash). GameInfo.ini's BlobsetVersion=3 is stale/wrong in the same way RLL4's own
GameLocation was once stale - Blobset Tools' own Modify.BlobsetV3 is a dead
`return true;` stub. The format actually in use, confirmed byte-for-byte against
the real files below, is BlobsetVersion=4.

All of this was ground-truthed by decompiling "Blobset Tools.dll" with ilspycmd
(BlobsetIO/BlobsetFile.cs's Deserialize(), Blobset_Tools/Modify.cs's BlobsetV4()
and BackupFilesV3V4()) and independently verified against the live files:
entry 39959 (the script bundle) resolves to data/f7/7a1b66f42029d8, which exists
and whose size matches the index's own MainUnCompressedSize field exactly, and
the index's computed total header size (8 + FilesCount*24) matches the real
data-0.blobset.pc's file size exactly, with zero slack.

data-0.blobset.pc layout (BlobsetVersion=4, confirmed):
  offset 0  : uint32 magic (1112493122 for this platform)
  offset 4  : uint32 FilesCount
  offset 8  : hash table, FilesCount x 8 bytes. Each is a little-endian uint64;
              BitConverter.GetBytes() on that value gives 8 LE bytes where
              byte[7] is the 1-byte "folder hash" (-> 2 lowercase hex chars,
              the data/<xx>/ subfolder) and bytes[6..0] (reversed) are the
              7-byte "file hash" (-> 14 lowercase hex chars, the blob's
              filename). I.e. folder = byte 7 of the LE-encoded uint64;
              file = bytes 6,5,4,3,2,1,0 of that same encoding, each as %02x.
  offset 8 + FilesCount*8 : size table, FilesCount x 16 bytes (4x uint32 LE):
              MainCompressedSize, MainUnCompressedSize,
              VramCompressedSize, VramUnCompressedSize
              (for an m3mp entry, Main==Main and Vram fields are both 0 - no
              separate vram/texture component).
  Total file size == 8 + FilesCount*24 exactly (verified against the real file).

A blob file at data/<folder>/<file> is NOT grown by an "append" in the normal
sense - Modify.BlobsetV4 calls BackupFilesV3V4() first, which (on the FIRST
modify only) MOVES the pristine blob to backup/<folder>/<file>, then
unconditionally DELETES the live file if it still exists. The subsequent
FileMode.Append write therefore always starts from nothing: net effect is a
clean replace, not a true append.

M3MP bundle building (the *.m3mp file itself, e.g. mods/m3mp/uncompressed/
39959.m3mp + companion 39959.xml) is NOT reimplemented here - Blobset Tools'
own "M3MP Creator" already does this correctly (confirmed: rebuilds all 5,330
files, inner chunks are ZSTD-compressed - a newer-engine difference from
RLL4's LZMA - which is exactly why this project's extract.py (ported
unmodified from RLL4) fails to decode a freshly-built bundle; that's a
decode-side limitation of this port, not evidence anything is wrong with the
bundle). Use Blobset Tools' M3MP Creator (point it at this project's
extracted/ folder + M3MP_List.xml, with your edited files swapped in) to
produce the *.m3mp + *.xml pair, then pass --bundle to this script's
`install` command.

Usage:
    python pack.py status  [--blobset PATH]
    python pack.py backup  [--blobset PATH] --entry N
    python pack.py install [--blobset PATH] --entry N --bundle PATH.m3mp --confirm
    python pack.py restore [--blobset PATH] --entry N
"""

import argparse
import json
import os
import shutil
import struct
import sys

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BACKUP_DIR = os.path.join(REPO_ROOT, "_backup")

BLOBSET_PATH = r"D:\SteamLibrary\steamapps\common\Rugby League\data\data-0.blobset.pc"
MAGIC_V4 = 1112493122
DEFAULT_ENTRY = 39959  # the script (m3mp) bundle - see M3MP_List.xml's Index attr


# --------------------------------------------------------------------------
# data-0.blobset.pc index parsing / patching
# --------------------------------------------------------------------------

def read_index(blobset_path):
    with open(blobset_path, "rb") as f:
        data = f.read()
    magic, files_count = struct.unpack_from("<2I", data, 0)
    if magic != MAGIC_V4:
        raise ValueError(f"expected BlobsetVersion=4 magic {MAGIC_V4}, got {magic}")
    hash_table_off = 8
    size_table_off = 8 + files_count * 8
    expected_size = size_table_off + files_count * 16
    if expected_size != len(data):
        raise ValueError(
            f"computed header size {expected_size} != actual file size {len(data)} "
            f"- format assumption may be wrong, aborting"
        )
    return data, files_count, hash_table_off, size_table_off


def entry_hash(data, hash_table_off, index):
    off = hash_table_off + index * 8
    raw = data[off:off + 8]
    val = struct.unpack("<Q", raw)[0]
    b = struct.pack("<Q", val)  # LE byte order, same as C# BitConverter.GetBytes()
    folder = f"{b[7]:02x}"
    file_hash = f"{b[6]:02x}{b[5]:02x}{b[4]:02x}{b[3]:02x}{b[2]:02x}{b[1]:02x}{b[0]:02x}"
    return folder, file_hash


def entry_sizes(data, size_table_off, index):
    off = size_table_off + index * 16
    return struct.unpack_from("<4I", data, off)  # main_c, main_u, vram_c, vram_u


def blob_path(blobset_path, folder, file_hash):
    return os.path.join(os.path.dirname(blobset_path), folder, file_hash)


def entry_record_offset(size_table_off, index):
    return size_table_off + index * 16


def write_entry_sizes(blobset_path, size_table_off, index, main_c, main_u, vram_c, vram_u):
    off = entry_record_offset(size_table_off, index)
    with open(blobset_path, "r+b") as f:
        f.seek(off)
        f.write(struct.pack("<4I", main_c, main_u, vram_c, vram_u))


# --------------------------------------------------------------------------
# backup / restore bookkeeping (separate from Blobset Tools' own backup/ dir -
# this is this project's own, so restore works even if Blobset Tools' copy
# is touched by something else)
# --------------------------------------------------------------------------

def backup_meta_path(entry_index):
    return os.path.join(BACKUP_DIR, f"entry_{entry_index}.backup.json")


def do_backup(blobset_path, entry_index):
    meta_path = backup_meta_path(entry_index)
    if os.path.exists(meta_path):
        raise RuntimeError(
            f"backup already exists at {meta_path} - run restore before installing "
            f"again (never install over an existing un-restored install)"
        )

    data, files_count, hash_table_off, size_table_off = read_index(blobset_path)
    if entry_index < 0 or entry_index >= files_count:
        raise IndexError(f"entry {entry_index} out of range (0..{files_count - 1})")

    folder, file_hash = entry_hash(data, hash_table_off, entry_index)
    bpath = blob_path(blobset_path, folder, file_hash)
    if not os.path.exists(bpath):
        raise RuntimeError(f"blob file not found: {bpath}")

    main_c, main_u, vram_c, vram_u = entry_sizes(data, size_table_off, entry_index)

    os.makedirs(BACKUP_DIR, exist_ok=True)
    blobset_backup = os.path.join(BACKUP_DIR, f"entry_{entry_index}.data-0.blobset.pc.bak")
    blob_backup = os.path.join(BACKUP_DIR, f"entry_{entry_index}.blob.bak")
    shutil.copy2(blobset_path, blobset_backup)
    shutil.copy2(bpath, blob_backup)

    meta = {
        "blobset_path": os.path.abspath(blobset_path),
        "entry_index": entry_index,
        "folder": folder,
        "file_hash": file_hash,
        "blob_path": os.path.abspath(bpath),
        "main_compressed_size": main_c,
        "main_uncompressed_size": main_u,
        "vram_compressed_size": vram_c,
        "vram_uncompressed_size": vram_u,
        "blobset_backup": blobset_backup,
        "blob_backup": blob_backup,
    }
    with open(meta_path, "w") as f:
        json.dump(meta, f, indent=2)
    return meta


def do_install(blobset_path, entry_index, bundle_path, confirm, sizes=None):
    """sizes, if given, is (main_c, main_u, vram_c, vram_u) to write to the
    index verbatim - use this whenever the bundle_path file's on-disk layout
    isn't simply "the whole thing, stored raw" (e.g. texture_mods.py's
    main-raw-header/vram-compressed-payload split for Mini_TXPK entries,
    which real pristine texture entries always use - see its module
    docstring for why collapsing that split caused real breakage once).
    Default (None) keeps the original behavior: the whole file is treated
    as stored raw (main_c=main_u=file size, vram=0,0) - still correct for
    the M3MP script bundle and build_texture.py's existing inject/
    inject-bundle commands, which this default preserves exactly."""
    if not confirm:
        raise RuntimeError("install requires --confirm")
    if not os.path.exists(bundle_path):
        raise RuntimeError(f"bundle not found: {bundle_path}")

    meta_path = backup_meta_path(entry_index)
    if os.path.exists(meta_path):
        raise RuntimeError(
            f"backup already exists at {meta_path} - run restore first, this script "
            f"refuses to install over an un-restored prior install"
        )

    meta = do_backup(blobset_path, entry_index)

    new_size = os.path.getsize(bundle_path)
    bpath = meta["blob_path"]

    # Matches the real tool's net effect (BackupFilesV3V4 moves-then-deletes the
    # live file before the "append", which on a just-deleted file is really a
    # fresh write): replace the blob file's content entirely, don't append to
    # the old bytes.
    with open(bundle_path, "rb") as src, open(bpath, "wb") as dst:
        shutil.copyfileobj(src, dst)

    _data, _files_count, _hash_table_off, size_table_off = read_index(blobset_path)
    if sizes is None:
        main_c = main_u = new_size
        vram_c = vram_u = 0
    else:
        main_c, main_u, vram_c, vram_u = sizes
    write_entry_sizes(blobset_path, size_table_off, entry_index, main_c, main_u, vram_c, vram_u)

    return {
        "entry_index": entry_index,
        "blob_path": bpath,
        "new_size": new_size,
        "backup_meta": meta_path,
    }


def do_restore(blobset_path, entry_index):
    """Undo install: restore just THIS entry's blob file and its own index
    record (hash + size table entries), surgically - never overwrite the
    whole index file wholesale. Restoring a whole-file snapshot is unsafe
    whenever more than one entry has been installed: each entry's backup
    snapshot is a full copy of the index taken at ITS OWN install time, so
    if entry A is installed, then entry B, then A is restored first, a
    wholesale copy of A's snapshot would silently re-revert B's index
    record to pristine too (fine) - but the real danger is the reverse
    order: restoring B first (B's snapshot already has A's modified record
    baked in) then A clobbers A's own fix right back to A's modified value,
    while A's blob *file* (restored unconditionally, see below) stays
    pristine - producing exactly the index/blob mismatch this bug once
    caused live (index claiming a multi-megabyte raw blob where the actual
    file was a tiny pristine compressed one)."""
    meta_path = backup_meta_path(entry_index)
    if not os.path.exists(meta_path):
        raise RuntimeError(f"no backup found at {meta_path} - nothing to restore")
    with open(meta_path) as f:
        meta = json.load(f)
    if os.path.abspath(blobset_path) != meta["blobset_path"]:
        raise RuntimeError(
            f"backup is for {meta['blobset_path']!r}, not {os.path.abspath(blobset_path)!r}"
        )

    backup_data, backup_files_count, backup_hash_off, backup_size_off = read_index(meta["blobset_backup"])
    live_data, live_files_count, live_hash_off, live_size_off = read_index(blobset_path)
    # add_entries.py only appends at the end, so a live index that has grown keeps every
    # existing position - but only if all the backup's other hashes are still in place.
    if live_files_count < backup_files_count or any(
        backup_data[backup_hash_off + i * 8: backup_hash_off + i * 8 + 8]
        != live_data[live_hash_off + i * 8: live_hash_off + i * 8 + 8]
        for i in range(backup_files_count) if i != entry_index
    ):
        raise RuntimeError(
            f"live index now has {live_files_count} entries but this backup was taken when it had "
            f"{backup_files_count} - the game was likely updated since this entry was installed; "
            f"a positional restore would be unsafe, refusing"
        )

    folder, file_hash = entry_hash(backup_data, backup_hash_off, entry_index)
    main_c, main_u, vram_c, vram_u = entry_sizes(backup_data, backup_size_off, entry_index)

    hash_off = live_hash_off + entry_index * 8
    with open(blobset_path, "r+b") as f:
        f.seek(hash_off)
        f.write(backup_data[backup_hash_off + entry_index * 8: backup_hash_off + entry_index * 8 + 8])
    write_entry_sizes(blobset_path, live_size_off, entry_index, main_c, main_u, vram_c, vram_u)

    shutil.copy2(meta["blob_backup"], meta["blob_path"])

    os.remove(meta_path)
    return meta


def do_status(blobset_path, entry_index):
    data, files_count, hash_table_off, size_table_off = read_index(blobset_path)
    folder, file_hash = entry_hash(data, hash_table_off, entry_index)
    main_c, main_u, vram_c, vram_u = entry_sizes(data, size_table_off, entry_index)
    bpath = blob_path(blobset_path, folder, file_hash)
    meta_path = backup_meta_path(entry_index)
    info = {
        "blobset_path": blobset_path,
        "files_count": files_count,
        "entry_index": entry_index,
        "folder": folder,
        "file_hash": file_hash,
        "blob_path": bpath,
        "blob_exists": os.path.exists(bpath),
        "blob_size_on_disk": os.path.getsize(bpath) if os.path.exists(bpath) else None,
        "main_compressed_size": main_c,
        "main_uncompressed_size": main_u,
        "vram_compressed_size": vram_c,
        "vram_uncompressed_size": vram_u,
        "installed_by_this_tool": os.path.exists(meta_path),
    }
    return info


# --------------------------------------------------------------------------
# CLI
# --------------------------------------------------------------------------

def cmd_status(args):
    print(json.dumps(do_status(args.blobset, args.entry), indent=2))


def cmd_backup(args):
    meta = do_backup(args.blobset, args.entry)
    print(f"Backed up entry {args.entry}:")
    print(f"  data-0.blobset.pc -> {meta['blobset_backup']}")
    print(f"  blob ({meta['folder']}/{meta['file_hash']}) -> {meta['blob_backup']}")


def cmd_install(args):
    result = do_install(args.blobset, args.entry, args.bundle, args.confirm)
    print(f"Installed: entry {result['entry_index']}'s blob "
          f"({result['blob_path']}) replaced, new size {result['new_size']} bytes.")
    print(f"Backup recorded at {result['backup_meta']} - run 'restore' to undo.")


def cmd_restore(args):
    meta = do_restore(args.blobset, args.entry)
    print(f"Restored entry {args.entry}: data-0.blobset.pc and "
          f"{meta['folder']}/{meta['file_hash']} both reverted to pristine.")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)

    p_status = sub.add_parser("status", help="report an entry's current index record + blob path")
    p_status.add_argument("--blobset", default=BLOBSET_PATH)
    p_status.add_argument("--entry", type=int, default=DEFAULT_ENTRY)
    p_status.set_defaults(func=cmd_status)

    p_backup = sub.add_parser("backup", help="back up an entry's blob + the whole index, without changing anything")
    p_backup.add_argument("--blobset", default=BLOBSET_PATH)
    p_backup.add_argument("--entry", type=int, default=DEFAULT_ENTRY)
    p_backup.set_defaults(func=cmd_backup)

    p_install = sub.add_parser("install", help="back up, then replace an entry's blob with a rebuilt *.m3mp and update its index record")
    p_install.add_argument("--blobset", default=BLOBSET_PATH)
    p_install.add_argument("--entry", type=int, default=DEFAULT_ENTRY)
    p_install.add_argument("--bundle", required=True, help="path to the rebuilt *.m3mp (from Blobset Tools' M3MP Creator)")
    p_install.add_argument("--confirm", action="store_true", help="required to actually write")
    p_install.set_defaults(func=cmd_install)

    p_restore = sub.add_parser("restore", help="undo install: revert the index and blob from this tool's own backup")
    p_restore.add_argument("--blobset", default=BLOBSET_PATH)
    p_restore.add_argument("--entry", type=int, default=DEFAULT_ENTRY)
    p_restore.set_defaults(func=cmd_restore)

    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
