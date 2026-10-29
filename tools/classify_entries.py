#!/usr/bin/env python3
"""
classify_entries.py - sniff every entry in data-0.blobset.pc's index and
report what kind of asset it is (script bundle, texture, audio, font, UI,
unrecognized), without extracting full payloads.

Ground-truthed against Blobset_Tools.dll (decompiled with ilspycmd), class
Blobset_Tools.FileMapping, method WriteV4 - this is the exact method the
real GUI tool uses to build its own "<blobset>.mapping" + TXPK_File_List.csv
+ M3MP_File_List.csv files for BlobsetVersion=4 games (confirmed this is our
version via pack.py's own docstring/status output). This script reimplements
WriteV4's branching in Python, reading each entry's blob file directly (same
folder/filehash resolution as pack.py's entry_hash/blob_path).

Per-entry logic (WriteV4), given MainCompressedSize/MainUnCompressedSize and
VramCompressedSize/VramUnCompressedSize from the index, and the blob's own
bytes read from offset 0 of data/<folder>/<filehash>:

  - mainCompressed == mainUncompressed (main stored raw):
      - vramCompressed == vramUncompressed too (nothing compressed):
          - bytes[20:24] == b"conv"  -> Mini_TXPK (single DDS texture; the
            string is the start of "convant2-temp-intermediate/..." baked
            into the header at a fixed offset)
          - else sniff uint32 magic at offset 0:
              1347236685 ("M3MP" LE)  -> M3MP bundle (scripts)
              1179011410              -> sound/wem
              1145588546              -> sound/bnk
              1415073867              -> TXPK bundle (multiple DDS textures)
              543575362               -> font .bmf
              541217602 / 1112752672  -> ui .bsb
              else                    -> unknown
      - vram compressed, main not: same "conv" check, else magic 1415073867
        -> TXPK, else unknown (vram's own compression is irrelevant to this
        sniff - it only ever affects the *pixel* payload, never the small
        header/path region at the front, which WriteV4 always reads as if
        raw)
  - main itself compressed: the WHOLE blob (header region included) is
    "outer" ZSTD-chunk-framed (see decode_outer_zstd_frames below) and must
    be reconstructed before sniffing; same magic table applies afterward
    (confirmed via Blobset_Tools.TXPK_Viewer.TXPX_DecompressZSTD, which does
    exactly this reconstruction before handing the buffer to TXPK/Mini_TXPK
    parsers).

Outer per-entry ZSTD chunk framing (distinct from M3MP's own *inner*
chunking, which has no length prefix - see build.py's docstring): each frame
is `uint32 frameLen` (total bytes INCLUDING this field) followed by
`frameLen-4` bytes that are either a raw zstd frame (first 4 bytes equal the
zstd magic 0xFD2FB528 as a little-endian uint32, i.e. byte sequence
28 B5 2F FD) or, if that check fails, stored-raw bytes used verbatim. Frames
are concatenated back to back until EOF. This is ground-truthed against
Blobset_Tools.TXPK_Viewer.TXPX_DecompressZSTD byte for byte.

Usage:
    python classify_entries.py --start 0 --end 103400 --out manifest.csv
    python classify_entries.py --entry scripts              # just one entry
"""

import argparse
import csv
import io
import os
import struct
import sys

import zstandard

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pack  # noqa: E402  (reuse read_index/entry_hash/entry_sizes/blob_path)
import entries  # noqa: E402

ZSTD_MAGIC = 0xFD2FB528

MAGIC_NAMES = {
    1347236685: "m3mp",
    1179011410: "sound_wem",
    1145588546: "sound_bnk",
    1415073867: "txpk",
    543575362: "font_bmf",
    541217602: "ui_bsb",
    1112752672: "ui_bsb",
}


def decode_outer_zstd_frames(buf):
    """Reconstruct the fully-raw buffer from outer length-prefixed ZSTD (or
    stored-raw) frames. See module docstring. Decompresses the WHOLE blob -
    only call this on entries whose main component is reported compressed,
    and prefer decode_outer_zstd_frames_partial for cheap header sniffing."""
    dctx = zstandard.ZstdDecompressor()
    out = bytearray()
    pos = 0
    while pos < len(buf):
        if pos + 4 > len(buf):
            break
        frame_len = struct.unpack_from("<I", buf, pos)[0]
        if frame_len < 4:
            break
        body = buf[pos + 4: pos + frame_len]
        pos += frame_len
        if len(body) >= 4 and struct.unpack_from("<I", body, 0)[0] == ZSTD_MAGIC:
            # The real tool's ZSTD_c_contentSizeFlag=0 on compress means these
            # frames carry no embedded size (confirmed in build.py's docstring
            # for M3MP's inner chunks; the same compressor settings produce
            # this outer per-entry framing) - a one-shot decompress() needs a
            # size up front, so stream instead (matches ZstdSharp's Unwrap()).
            with dctx.stream_reader(io.BytesIO(body)) as reader:
                out.extend(reader.read())
        else:
            out.extend(body)
    return bytes(out)


def read_blob_full(blobset_path, entry):
    """Like read_blob_head but returns the ENTIRE reconstructed (fully raw,
    outer-zstd-decompressed if needed) blob - needed to actually extract a
    texture's pixel payload, not just sniff its type.

    Mirrors Blobset_Tools.TXPK_Viewer.TXPX_DecompressZSTD's own branching
    exactly (ground-truthed by reading its decompiled source): when EITHER
    component is already raw (main_c==main_u OR vram_c==vram_u), the first
    main_u bytes are used verbatim as a prefix and only the remainder is
    outer-chunk-framed; only when BOTH components are compressed does the
    chunk framing start from byte 0 of the file."""
    folder, file_hash = pack.entry_hash(_INDEX_DATA, _HASH_TABLE_OFF, entry)
    bpath = pack.blob_path(blobset_path, folder, file_hash)
    if not os.path.exists(bpath):
        return None, folder, file_hash, bpath
    main_c, main_u, vram_c, vram_u = pack.entry_sizes(_INDEX_DATA, _SIZE_TABLE_OFF, entry)
    with open(bpath, "rb") as f:
        raw = f.read()

    if main_c == main_u and vram_c == vram_u:
        return raw, folder, file_hash, bpath
    # A compressed main with no vram component at all (Rugby 25's lua
    # bundle, for one) is framed from byte 0 - an empty vram is not a raw
    # "prefix" case.
    if main_c != main_u and vram_u == 0:
        return decode_outer_zstd_frames(raw), folder, file_hash, bpath
    if main_c == main_u or vram_c == vram_u:
        prefix = raw[:main_u]
        remainder = decode_outer_zstd_frames(raw[main_u:])
        return prefix + remainder, folder, file_hash, bpath
    return decode_outer_zstd_frames(raw), folder, file_hash, bpath


def read_blob_head(blobset_path, entry, max_bytes=65536):
    """Read enough of an entry's blob to sniff its type and (for Mini_TXPK)
    its embedded file path, decompressing the outer per-entry ZSTD framing
    first if the index says the main component is compressed."""
    folder, file_hash = pack.entry_hash(_INDEX_DATA, _HASH_TABLE_OFF, entry)
    bpath = pack.blob_path(blobset_path, folder, file_hash)
    if not os.path.exists(bpath):
        return None, folder, file_hash, bpath
    main_c, main_u, vram_c, vram_u = pack.entry_sizes(_INDEX_DATA, _SIZE_TABLE_OFF, entry)
    with open(bpath, "rb") as f:
        raw = f.read() if main_c != main_u else f.read(max_bytes)
    if main_c != main_u:
        # main component compressed -> whole blob is outer-zstd-framed;
        # reconstructing the first ~max_bytes worth is enough for sniffing
        # (header/path regions are always tiny relative to a 32KB frame).
        raw = decode_outer_zstd_frames(raw)[:max_bytes]
    return raw, folder, file_hash, bpath


def classify(raw):
    """Return (kind, extra) for a blob's raw (already outer-decompressed)
    head bytes, replicating FileMapping.WriteV4's sniff order."""
    if raw is None or len(raw) < 4:
        return "missing_or_empty", None
    if len(raw) >= 24 and raw[20:24] == b"conv":
        end = raw.find(b"\x00", 20)
        path = raw[20:end].decode("latin1", "replace") if end != -1 else None
        if path:
            path = path.replace("convant2-temp-intermediate/", "").replace("convant2-temp-intermediate\\", "")
            # newer titles (GameId > 15, confirmed ours is one - see
            # Mini_TXPK.Deserialize) store the path with a ".badds"
            # extension even though the embedded payload is an ordinary
            # .dds file (verified: payload always starts with "DDS ").
            path = path.replace(".badds", ".dds")
        return "mini_txpk", path
    magic = struct.unpack_from("<I", raw, 0)[0]
    name = MAGIC_NAMES.get(magic)
    if name:
        return name, None
    return "unknown", f"magic={magic}"


_INDEX_DATA = None
_HASH_TABLE_OFF = None
_SIZE_TABLE_OFF = None


def load_index(blobset_path):
    global _INDEX_DATA, _HASH_TABLE_OFF, _SIZE_TABLE_OFF
    data, files_count, hash_table_off, size_table_off = pack.read_index(blobset_path)
    _INDEX_DATA = data
    _HASH_TABLE_OFF = hash_table_off
    _SIZE_TABLE_OFF = size_table_off
    return files_count


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--blobset", default=pack.BLOBSET_PATH)
    ap.add_argument("--start", type=int, default=0)
    ap.add_argument("--end", type=int, default=None, help="exclusive (default: FilesCount)")
    ap.add_argument("--entry", type=entries.arg, default=None, help="classify just this one entry, print, and exit")
    ap.add_argument("--out", default=None, help="write a CSV manifest here")
    ap.add_argument("--progress-every", type=int, default=2000)
    args = ap.parse_args()

    files_count = load_index(args.blobset)

    if args.entry is not None:
        raw, folder, file_hash, bpath = read_blob_head(args.blobset, args.entry)
        kind, extra = classify(raw)
        print(f"entry {args.entry}: {folder}/{file_hash} -> {kind} {extra or ''}")
        return

    start = args.start
    end = args.end if args.end is not None else files_count
    rows = []
    counts = {}
    for i in range(start, end):
        raw, folder, file_hash, bpath = read_blob_head(args.blobset, i)
        kind, extra = classify(raw)
        counts[kind] = counts.get(kind, 0) + 1
        rows.append((i, folder, file_hash, kind, extra or ""))
        if args.progress_every and (i - start + 1) % args.progress_every == 0:
            print(f"  ...{i - start + 1}/{end - start} scanned", file=sys.stderr)

    if args.out:
        with open(args.out, "w", newline="") as f:
            w = csv.writer(f)
            w.writerow(["entry_index", "folder", "file_hash", "kind", "extra"])
            w.writerows(rows)
        print(f"Wrote {len(rows)} rows to {args.out}")

    print("Summary:")
    for kind, n in sorted(counts.items(), key=lambda kv: -kv[1]):
        print(f"  {kind}: {n}")


if __name__ == "__main__":
    main()
