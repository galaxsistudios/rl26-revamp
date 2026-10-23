#!/usr/bin/env python3
"""
diff_bundle.py - decode two M3MP bundles (e.g. the same entry's blob from
before/after a game update) and report what changed between them.

The decoder reuses the same M3MP container parsing as build.py's
self_verify_build (magic, file table, name table, chunk table, zstd chunks).
That parsing is generic to the container format - it doesn't care whether
the bundle was built by this project's build.py or shipped by the game
itself, so it works equally well on a pristine backup and a freshly patched
live blob.

For files that are LuaJIT bytecode (the "\x1bLJ" magic), pass --decompile to
run toolchain/decompiler/luajit-decompiler-v2.exe on both the old and new
copy and unified-diff the decompiled source, so you can actually read what a
game update changed in a script rather than just seeing "bytes differ".

Usage:
    python diff_bundle.py OLD.m3mp NEW.m3mp [--filter SUBSTRING] [--decompile] [--out DIR]
"""

import argparse
import difflib
import os
import struct
import subprocess
import sys

import zstandard

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DIFF_OUT_DIR = os.path.join(REPO_ROOT, "_build", "bundle_diff")

DECOMPILER_EXE = r"D:\galaxsi\projects\games\modding\toolchain\decompiler\luajit-decompiler-v2.exe"
DECOMPILER_OUTPUT_DIR = os.path.join(os.path.dirname(DECOMPILER_EXE), "output")
BYTECODE_MAGIC = b"\x1bLJ"
M3MP_MAGIC = 1347236685
ZSTD_FRAME_MAGIC = b"\x28\xb5\x2f\xfd"


# --------------------------------------------------------------------------
# outer blob-storage wrapper (discovered on a live post-update blob that
# Steam re-synced: NOT part of the M3MP container itself, build.py never
# writes it, and an old pre-update blob we checked didn't have it either -
# so it's an outer compression layer the blobset storage itself applies,
# independent of M3MP's own internal 32KB-chunk compression. Format is a
# sequence of records back to back: 4-byte LE record_len (includes itself),
# then (record_len-4) payload bytes that are either a raw zstd frame (if
# they start with the zstd frame magic) or stored uncompressed verbatim
# (seen on a block zstd couldn't shrink) - concatenating every record's
# decoded bytes reconstructs the bare M3MP bundle. A bare M3MP (starts with
# the M3MP magic directly, e.g. anything build.py writes) has none of this
# and is returned unchanged.
# --------------------------------------------------------------------------

def unwrap_outer_blob(buf):
    if buf[:4] == b"M3MP":
        return bytes(buf)

    dctx = zstandard.ZstdDecompressor()
    pos = 0
    out = bytearray()
    while pos < len(buf):
        record_len = struct.unpack_from("<I", buf, pos)[0]
        payload = buf[pos + 4:pos + record_len]
        if payload[:4] == ZSTD_FRAME_MAGIC:
            out += dctx.decompress(payload, max_output_size=16 * 1024 * 1024)
        else:
            out += payload
        pos += record_len
    return bytes(out)


# --------------------------------------------------------------------------
# M3MP decode (generic - see build.py's self_verify_build for the original)
# --------------------------------------------------------------------------

def decode_m3mp(path):
    """Return {bundle_path: bytes} for every file in an M3MP bundle, keyed
    by the name each entry carries in the bundle's OWN name table.

    Deliberately does NOT accept an external name list to apply by position:
    a live post-update bundle was found to have its file TABLE in a
    different order than an older bundle's (and than M3MP_List.xml, which
    was generated from one specific bundle) even though the same 5330 files
    are all still present - matching entries by position across two bundles
    silently pairs the wrong files together. Matching by each bundle's own
    name-table string is the only way that's safe across a reorder."""
    with open(path, "rb") as f:
        raw = f.read()
    buf = unwrap_outer_blob(raw)
    magic, file_count, chunk_count, chunk_table_off = struct.unpack_from("<4I", buf, 0)
    if magic != M3MP_MAGIC:
        raise ValueError(f"{path}: not an M3MP bundle (bad magic {magic})")

    names = []
    sizes = []
    cum_offs = []
    for i in range(file_count):
        off = 16 + i * 16
        cum_off, size, name_off, _reserved = struct.unpack_from("<4I", buf, off)
        end = buf.find(b"\x00", name_off)
        names.append(buf[name_off:end].decode("latin1"))
        sizes.append(size)
        cum_offs.append(cum_off)

    chunks = []
    for i in range(chunk_count):
        off = chunk_table_off + i * 12
        chunks.append(struct.unpack_from("<3I", buf, off))

    dctx = zstandard.ZstdDecompressor()
    data_blob = bytearray()
    for c_off, c_size, u_size in chunks:
        raw_chunk = buf[c_off:c_off + c_size]
        if raw_chunk[:4] == ZSTD_FRAME_MAGIC:
            piece = dctx.decompress(raw_chunk, max_output_size=u_size)
        else:
            piece = raw_chunk
        if len(piece) != u_size:
            raise AssertionError(f"{path}: chunk decompressed to {len(piece)} bytes, expected {u_size}")
        data_blob += piece

    return {
        names[i]: bytes(data_blob[cum_offs[i]:cum_offs[i] + sizes[i]])
        for i in range(file_count)
    }


# --------------------------------------------------------------------------
# decompile LuaJIT bytecode for a readable diff
# --------------------------------------------------------------------------

def decompile_bytecode(bytecode, label):
    """Run the LuaJIT decompiler on raw bytecode bytes, return decompiled
    source text, or None if this isn't bytecode or decompiling fails."""
    if bytecode[:3] != BYTECODE_MAGIC:
        return None

    decompiler_dir = os.path.dirname(DECOMPILER_EXE)
    tmp_name = f"_diffbundle_tmp_{label}.lua"
    tmp_in = os.path.join(decompiler_dir, tmp_name)
    out_path = os.path.join(DECOMPILER_OUTPUT_DIR, tmp_name)

    with open(tmp_in, "wb") as f:
        f.write(bytecode)
    if os.path.exists(out_path):
        os.remove(out_path)
    try:
        subprocess.run([DECOMPILER_EXE, tmp_in], capture_output=True, text=True, timeout=60)
        text = None
        if os.path.exists(out_path):
            with open(out_path, "r", encoding="utf-8", errors="replace") as f:
                text = f.read()
        return text
    finally:
        for p in (tmp_in, out_path):
            if os.path.exists(p):
                os.remove(p)


# --------------------------------------------------------------------------
# diff
# --------------------------------------------------------------------------

def diff_bundles(old_path, new_path, filter_substr, decompile, out_dir, verbose=True):
    old_files = decode_m3mp(old_path)
    new_files = decode_m3mp(new_path)

    old_keys = set(old_files)
    new_keys = set(new_files)

    added = sorted(new_keys - old_keys)
    removed = sorted(old_keys - new_keys)
    common = sorted(old_keys & new_keys)
    changed = [bp for bp in common if old_files[bp] != new_files[bp]]

    if filter_substr:
        added = [bp for bp in added if filter_substr in bp]
        removed = [bp for bp in removed if filter_substr in bp]
        changed = [bp for bp in changed if filter_substr in bp]

    if verbose:
        print(f"Old: {len(old_files)} files, New: {len(new_files)} files")
        print(f"Added:   {len(added)}")
        print(f"Removed: {len(removed)}")
        print(f"Changed: {len(changed)}")
        print()
        for bp in added:
            print(f"  + {bp} ({len(new_files[bp])} bytes)")
        for bp in removed:
            print(f"  - {bp} ({len(old_files[bp])} bytes)")
        for bp in changed:
            print(f"  * {bp} ({len(old_files[bp])} -> {len(new_files[bp])} bytes)")

    if decompile and changed:
        os.makedirs(out_dir, exist_ok=True)
        print()
        print(f"Decompiling {len(changed)} changed file(s) into {out_dir}/ ...")
        for bp in changed:
            old_src = decompile_bytecode(old_files[bp], "old")
            new_src = decompile_bytecode(new_files[bp], "new")
            if old_src is None or new_src is None:
                print(f"  (skipped, not LuaJIT bytecode: {bp})")
                continue
            udiff = list(difflib.unified_diff(
                old_src.splitlines(keepends=True),
                new_src.splitlines(keepends=True),
                fromfile=f"old/{bp}", tofile=f"new/{bp}",
            ))
            safe_name = bp.replace("/", "__") + ".diff"
            report_path = os.path.join(out_dir, safe_name)
            with open(report_path, "w", encoding="utf-8") as f:
                f.writelines(udiff if udiff else [f"(decompiled text identical for {bp} despite differing bytecode bytes)\n"])
            print(f"  wrote {report_path} ({len(udiff)} diff lines)")

    return {"added": added, "removed": removed, "changed": changed}


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("old", help="path to the OLD M3MP bundle (e.g. a pristine pre-update backup)")
    ap.add_argument("new", help="path to the NEW M3MP bundle (e.g. the current pristine live blob)")
    ap.add_argument("--filter", default=None, help="only show/report bundle paths containing this substring")
    ap.add_argument("--decompile", action="store_true", help="decompile changed LuaJIT bytecode files and write unified diffs")
    ap.add_argument("--out", default=DIFF_OUT_DIR, help="directory to write decompiled diffs into")
    args = ap.parse_args()

    diff_bundles(args.old, args.new, args.filter, args.decompile, args.out)


if __name__ == "__main__":
    main()
