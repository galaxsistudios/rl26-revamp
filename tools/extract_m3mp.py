#!/usr/bin/env python3
"""
extract_m3mp.py - generalized read-only extractor for ANY M3MP-bundle
blobset entry, not just the script bundle (39959). Decoding logic is the
exact inverse of build.py's build_bundle()/zstd_compress_chunk() (same
header layout, same raw-zstd-frame-per-32KB-chunk inner compression - see
build.py's docstring for how that was ground-truthed against Blobset
Tools.dll). extract.py's own decode_m3mp() cannot be reused: it assumes
RLL4's LZMA-chunk format, which is wrong for RL26 (build.py's docstring
explains why).

Several other entries besides 39959 are also M3MP bundles - confirmed via
Blobset Tools' own precomputed manifest at
"Blobset.Tools/games/Rugby League 26/pc/M3MP_File_List.csv" (built by its
FileMapping feature, which classify_entries.py's docstring also
reimplements from scratch in case that manifest isn't available). Notably
entry 39954 ("defaultdata/*.clubdata" + "*.playerdata" + misc config, 4264
files) is the on-disc default club/player roster database the user asked
about - this is NOT the same thing as native.CPlayerDatabaseOnDisc's binary
save-game format, but it is the shipped default data those systems seed
from, and it's just as readable/editable as any other M3MP bundle.

Usage:
    python extract_m3mp.py --entry 39954 --out extracted_defaultdata
    python extract_m3mp.py --entry 39954 --list          # just print paths
"""

import argparse
import io
import os
import struct
import sys

import zstandard

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pack  # noqa: E402
import classify_entries as ce  # noqa: E402

M3MP_MAGIC = 1347236685


def decode_m3mp(raw):
    """Return (names, file_bytes_by_name) for a fully-raw (already
    outer-decompressed) M3MP buffer."""
    magic, file_count, chunk_count, chunk_table_off = struct.unpack_from("<4I", raw, 0)
    if magic != M3MP_MAGIC:
        raise ValueError(f"not an M3MP pack (magic={magic})")

    records = []
    for i in range(file_count):
        off = 16 + i * 16
        cum_off, size, name_off, _reserved = struct.unpack_from("<4I", raw, off)
        end = raw.find(b"\x00", name_off)
        name = raw[name_off:end].decode("latin1")
        records.append((cum_off, size, name))

    dctx = zstandard.ZstdDecompressor()
    data_blob = bytearray()
    for i in range(chunk_count):
        off = chunk_table_off + i * 12
        chunk_off, stored_size, decomp_size = struct.unpack_from("<3I", raw, off)
        comp = raw[chunk_off:chunk_off + stored_size]
        with dctx.stream_reader(io.BytesIO(comp)) as reader:
            piece = reader.read(decomp_size)
        data_blob.extend(piece[:decomp_size])

    out = {}
    for cum_off, size, name in records:
        out[name] = bytes(data_blob[cum_off:cum_off + size])
    return records, out


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--blobset", default=pack.BLOBSET_PATH)
    ap.add_argument("--entry", type=int, required=True)
    ap.add_argument("--out", default=None)
    ap.add_argument("--list", action="store_true", help="just print contained paths, don't extract")
    args = ap.parse_args()

    ce.load_index(args.blobset)
    raw, folder, file_hash, bpath = ce.read_blob_full(args.blobset, args.entry)
    if raw is None:
        raise RuntimeError(f"entry {args.entry}: blob not found at {bpath}")

    records, files = decode_m3mp(raw)
    print(f"entry {args.entry}: {len(records)} files, blob at {bpath}")

    if args.list:
        for _cum, _size, name in records:
            print(" ", name)
        return

    if not args.out:
        print("(pass --out DIR to extract, or --list to just see paths)")
        return

    for name, content in files.items():
        rel = name.replace("\\", "/").lstrip("/")
        dest = os.path.join(args.out, *rel.split("/"))
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        with open(dest, "wb") as f:
            f.write(content)
    print(f"Wrote {len(files)} files to {args.out}")


if __name__ == "__main__":
    main()
