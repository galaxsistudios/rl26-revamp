#!/usr/bin/env python3
"""
extract_textures.py - read-only extractor for texture entries (Mini_TXPK /
TXPK) in data-0.blobset.pc, writing out standard .dds files.

Ground-truthed against Blobset_Tools.dll (decompiled with ilspycmd), classes
BlobsetIO.Mini_TXPK / BlobsetIO.TXPK and Blobset_Tools.TXPK_Creator - see
classify_entries.py's module docstring for the entry-classification side
(this script reuses it) and the outer per-entry ZSTD chunk-frame format.

Two texture container shapes exist on PC (little-endian; the big-endian /
console branches in the decompiled source, with extra swizzled-header
fields, do not apply here and are not implemented):

Mini_TXPK (one DDS per blobset entry) - header at offset 0 of the
reconstructed (outer-decompressed) blob:
    uint32 DDSWidth
    uint32 DDSHeight
    uint32 DDSImageType
    uint32 DDSFilePathOffset      (constant 20 - byte offset of the path
                                    string below, from the start of this
                                    header)
    uint32 ConsoleDDSHeaderOffset (on PC: doubles as the DDS payload's exact
                                    byte length, confirmed via Mini_TXPK.cs
                                    Serialize()'s non-bigendian branch, which
                                    sets it to Utilities.FileInfo(fileIn) -
                                    the original .dds file's size)
    NUL-terminated path string, always starting "convant2-temp-intermediate/"
    (stripped here) - this is also how classify_entries.py's "conv" sniff at
    offset 20 detects a Mini_TXPK: offset 20 is exactly where this string
    starts.
    Immediately after the NUL: ConsoleDDSHeaderOffset bytes of a complete,
    ordinary .dds file (header + pixel data), verbatim.

TXPK (many DDS files bundled in one blobset entry, like M3MP is to scripts)
- header at offset 0:
    uint32 magic = 1415073867
    uint32 filesCount
    filesCount x 16 bytes: DDSPathOffset, DDSPathSize, DDSDataOffset (u32,
        cumulative offset into the trailing concatenated DDS-data blob),
        DDSDataSize
    at each DDSPathOffset: uint32 Width, Height, ImageType, FilePathOffset
        (constant 20), ConsoleDDSHeaderOffset, then NUL-terminated path
        (".dds" is NOT included - append it)
    trailing data blob: every entry's complete .dds file, concatenated in
        entry-table order (DDSDataOffset is simply the running total of
        DDSDataSize - confirmed via TXPK_Creator.CreateTXPK, which appends
        each source .dds's bytes back to back with no padding). This
        script locates the blob's start as
        (len(buffer) - sum(DDSDataSize for every entry)) rather than
        trusting DDSPathOffset bookkeeping, which is more robust to the
        same "array index order need not match offset order" caveat
        extract.py's own M3MP reader already documents for that format.

Usage:
    python extract_textures.py --entry 12345 --out extracted_textures
    python extract_textures.py --start 0 --end 103400 --out extracted_textures
    python extract_textures.py --from-csv manifest.csv --out extracted_textures
"""

import argparse
import csv
import os
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pack  # noqa: E402
import classify_entries as ce  # noqa: E402

TXPK_MAGIC = 1415073867


def _read_cstr(buf, off):
    end = buf.find(b"\x00", off)
    if end == -1:
        raise ValueError(f"unterminated string at {off}")
    return buf[off:end].decode("latin1"), end + 1


def parse_mini_txpk(raw):
    """Return (rel_path, dds_bytes, raw_path, width, height, image_type) for
    a Mini_TXPK blob. raw_path is the EXACT byte-for-byte string stored in
    the blob (e.g. "convant2-temp-intermediate/characters/.../flag_col.pc.badds")
    - keep it around for rebuild_mini_txpk() so a reinstalled entry is
    byte-identical apart from the swapped-in .dds payload."""
    width, height, image_type, path_off, dds_size = struct.unpack_from("<5I", raw, 0)
    raw_path, after = _read_cstr(raw, path_off)
    path = raw_path.replace("convant2-temp-intermediate/", "").replace("convant2-temp-intermediate\\", "")
    path = path.replace(".badds", ".dds")
    dds_bytes = raw[after:after + dds_size]
    if len(dds_bytes) != dds_size or dds_bytes[:4] != b"DDS ":
        raise ValueError(f"Mini_TXPK payload doesn't look like a DDS file (got {len(dds_bytes)}/{dds_size} bytes, magic={dds_bytes[:4]!r})")
    return path, dds_bytes, raw_path, width, height, image_type


def rebuild_mini_txpk(raw_path, dds_bytes, image_type):
    """Inverse of parse_mini_txpk: given the ORIGINAL raw_path string (as
    returned by parse_mini_txpk - must be reused verbatim for a faithful
    rebuild) and a (possibly edited) dds_bytes payload, rebuild a complete
    Mini_TXPK blob ready to hand to pack.do_install. width/height are
    re-derived from the new DDS's own header (bytes 12/16 per the DDS spec,
    same offsets TXPK_Creator.cs reads) rather than trusted blindly, so a
    resized replacement texture still gets a consistent header."""
    if dds_bytes[:4] != b"DDS ":
        raise ValueError("replacement file is not a DDS (missing 'DDS ' magic)")
    new_height, new_width = struct.unpack_from("<2I", dds_bytes, 12)
    path_bytes = raw_path.encode("latin1") + b"\x00"
    header = struct.pack("<5I", new_width, new_height, image_type, 20, len(dds_bytes))
    return header + path_bytes + dds_bytes


def parse_txpk(raw, main_uncompressed_size=None):
    """Return a list of (rel_path, dds_bytes) for a TXPK bundle blob.

    data_blob_start is simply the entry's MainUnCompressedSize - confirmed
    against a real shipped TXPK (entry 39879, fields/textures/fieldlines*):
    the TXPK header+per-entry-header+path region is exactly the "main"
    component (sized 234 bytes there) and the concatenated DDS payloads are
    exactly the "vram" component starting right where main ends, regardless
    of any gaps between individual members' declared DDSDataOffset/Size
    (the real game's own build pipeline leaves padding there that Blobset
    Tools' own TXPK_Creator doesn't reproduce when authoring a *new* bundle
    - harmless, since every member is still located correctly via its own
    DDSDataOffset relative to this one base). Callers that don't have
    main_uncompressed_size handy (e.g. working from a bare buffer) fall
    back to the old same-length heuristic, which is only exactly right when
    members are stored back to back with no padding - true for anything
    this project's own serialize_txpk() produces, not guaranteed for an
    arbitrary pristine shipped bundle."""
    magic, file_count = struct.unpack_from("<2I", raw, 0)
    if magic != TXPK_MAGIC:
        raise ValueError(f"not a TXPK (magic={magic})")
    entries = []
    for i in range(file_count):
        off = 8 + i * 16
        path_off, path_size, data_off, data_size = struct.unpack_from("<4I", raw, off)
        entries.append([path_off, path_size, data_off, data_size, None])

    for e in entries:
        path_off, path_size, data_off, data_size, _ = e
        # header at path_off: width, height, imagetype, filepathoffset(=20), consoleddsheaderoffset
        _w, _h, _t, _fpo, _cdho = struct.unpack_from("<5I", raw, path_off)
        path, _after = _read_cstr(raw, path_off + 20)
        e[4] = path

    if main_uncompressed_size is not None and main_uncompressed_size < len(raw):
        # the common pristine-shipped case (see docstring above). Guarded by
        # "< len(raw)" because once WE reinstall a bundle via pack.do_install
        # it always collapses to main_c=main_u=whole-blob-size (see pack.py's
        # write_entry_sizes convention) - at that point main_u no longer
        # marks the header/data boundary and we must fall back below, which
        # is exact for anything serialize_txpk() produced (contiguous, no
        # padding between members).
        data_blob_start = main_uncompressed_size
    else:
        data_blob_start = len(raw) - sum(e[3] for e in entries)
    out = []
    for path_off, path_size, data_off, data_size, path in entries:
        dds_bytes = raw[data_blob_start + data_off: data_blob_start + data_off + data_size]
        if len(dds_bytes) != data_size or dds_bytes[:4] != b"DDS ":
            raise ValueError(f"TXPK member {path!r} doesn't look like a DDS file (got {len(dds_bytes)}/{data_size} bytes, magic={dds_bytes[:4]!r})")
        out.append((path.replace("\\", "/") + ".dds", dds_bytes))
    return out


def serialize_txpk(entries):
    """Inverse of parse_txpk: entries is [(path_no_ext_fwdslash, dds_bytes), ...]
    in the same order as the original bundle's table. Rebuilds a complete
    TXPK blob from scratch.

    Ground-truthed against Blobset_Tools.TXPK_Creator.CreateTXPK's
    non-bigendian (PC) branch: unlike TXPK.Serialize (which relies on a
    stateful FileStream and literally serializes itself twice to bootstrap
    DDSPathOffset - see this function's own long-form equivalent in
    extract_textures.py's commit history / module docstring reasoning),
    this computes every offset analytically in one pass, which is
    equivalent for a from-scratch rebuild: the header region is strictly
    fixed-size-per-entry (20 bytes) plus a NUL-terminated path, in table
    order, immediately followed by the concatenated DDS payloads."""
    file_count = len(entries)
    header_fixed = 8
    entry_table_size = file_count * 16

    path_bytes_list = [p.encode("latin1") + b"\x00" for p, _ in entries]
    header_region_sizes = [20 + len(pb) for pb in path_bytes_list]

    path_offsets = []
    pos = header_fixed + entry_table_size
    for size in header_region_sizes:
        path_offsets.append(pos)
        pos += size
    data_blob_start = pos

    data_offsets = []
    cum = 0
    for _p, dds_bytes in entries:
        data_offsets.append(cum)
        cum += len(dds_bytes)

    out = bytearray()
    out += struct.pack("<2I", TXPK_MAGIC, file_count)
    for i, (path, dds_bytes) in enumerate(entries):
        out += struct.pack("<4I", path_offsets[i], header_region_sizes[i], data_offsets[i], len(dds_bytes))
    for i, (path, dds_bytes) in enumerate(entries):
        image_type = 2 if "mat.pc" in path else 1
        out += struct.pack("<5I", 0, 0, image_type, 20, len(dds_bytes))  # width/height left 0 - cosmetic, not read back by this engine's loader per TXPK.Deserialize's own PC branch
        out += path_bytes_list[i]
    assert len(out) == data_blob_start, (len(out), data_blob_start)
    for _path, dds_bytes in entries:
        out += dds_bytes
    return bytes(out)


def extract_entry(blobset_path, entry_index, out_dir, verbose=True):
    raw, folder, file_hash, bpath = ce.read_blob_full(blobset_path, entry_index)
    if raw is None:
        raise RuntimeError(f"entry {entry_index}: blob not found at {bpath}")

    head_kind, _ = ce.classify(raw[:65536])
    written = []
    if head_kind == "mini_txpk":
        path, dds_bytes, raw_path, width, height, image_type = parse_mini_txpk(raw)
        if not path:
            path = f"entry_{entry_index}.dds"
        if not path.lower().endswith(".dds"):
            path += ".dds"
        dest = os.path.join(out_dir, *path.replace("\\", "/").split("/"))
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        with open(dest, "wb") as f:
            f.write(dds_bytes)
        # sidecar: everything build_texture.py's `inject` needs to rebuild
        # this exact entry later (raw_path must be reused byte-for-byte).
        with open(dest + ".meta.json", "w") as f:
            import json
            json.dump({"entry_index": entry_index, "kind": "mini_txpk", "raw_path": raw_path,
                       "width": width, "height": height, "image_type": image_type}, f)
        written.append((path, dest, entry_index))
    elif head_kind == "txpk":
        _main_c, main_u, _vram_c, _vram_u = pack.entry_sizes(ce._INDEX_DATA, ce._SIZE_TABLE_OFF, entry_index)
        for path, dds_bytes in parse_txpk(raw, main_u):
            dest = os.path.join(out_dir, *path.split("/"))
            os.makedirs(os.path.dirname(dest), exist_ok=True)
            with open(dest, "wb") as f:
                f.write(dds_bytes)
            written.append((path, dest, entry_index))
    else:
        raise ValueError(f"entry {entry_index} is not a texture entry (classified as {head_kind!r})")

    if verbose:
        for path, dest, idx in written:
            print(f"  entry {idx}: wrote {dest}  ({path})")
    return written


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--blobset", default=pack.BLOBSET_PATH)
    ap.add_argument("--out", required=True)
    ap.add_argument("--entry", type=int, default=None)
    ap.add_argument("--start", type=int, default=None)
    ap.add_argument("--end", type=int, default=None)
    ap.add_argument("--from-csv", default=None, help="a manifest CSV from classify_entries.py; only kind in (mini_txpk, txpk) rows are extracted")
    args = ap.parse_args()

    ce.load_index(args.blobset)

    entries = []
    if args.entry is not None:
        entries = [args.entry]
    elif args.from_csv:
        with open(args.from_csv, newline="") as f:
            for row in csv.DictReader(f):
                if row["kind"] in ("mini_txpk", "txpk"):
                    entries.append(int(row["entry_index"]))
    elif args.start is not None and args.end is not None:
        entries = list(range(args.start, args.end))
    else:
        ap.error("pass --entry, --from-csv, or --start/--end")

    total_written = 0
    errors = 0
    for idx in entries:
        try:
            written = extract_entry(args.blobset, idx, args.out)
            total_written += len(written)
        except Exception as ex:
            errors += 1
            print(f"  entry {idx}: SKIPPED ({ex})")
    print(f"Done: {total_written} .dds files written, {errors} entries skipped.")


if __name__ == "__main__":
    main()
