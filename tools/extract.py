#!/usr/bin/env python3
"""
extract.py - Read-only extractor for RL26's data-0.blobset.pc archive.

Ported from the sibling RLL4 project's tools/extract.py (same Big Ant engine,
same blobset/M3MP format - format details below were reverse-engineered there
and ground-truthed against Blobset Tools.dll's decompiled source). Only the
two RL26-specific constants below (BLOBSET_PATH, default --entry) differ;
every byte-level format fact is unchanged, and this project's own extracted/
folder (5,330 files) + M3MP_List.xml already confirm it decodes correctly.

Maps the blobset index, pulls out a chosen entry (default: 39959, the script
bundle - confirmed via Blobset.Tools' M3MP_File_List.csv, every script in
M3MP_List.xml maps to entry 39959), decodes its 32KB-LZMA-chunked payload,
parses the resulting M3MP pack, and writes every contained file out to a
destination folder, preserving the pack's internal relative paths.

Format notes (reverse-engineered against the RLL4 Oct 2026 Steam build, see
that project's CLAUDE.md / instructions.pdf; re-confirmed here against RL26's
own M3MP_List.xml + extracted output):

BLOBSET (data-0.blobset.pc):
  offset 0        : 20-byte hash
  offset 20       : magic b"BOLB"
  offset 24       : uint32 version (4 when pristine)
                    Ground-truthed against Blobset Tools.dll's decompiled
                    source (see pack.py's module docstring point 5): this is
                    actually BlobsetFile.BlobsetCount in the real tool, a
                    field it never reads back anywhere, but which Modify.
                    BlobsetV1 unconditionally stamps to literal 2 on every
                    repack regardless of which entries changed. The ==4
                    check below is still the right guard here (it correctly
                    rejects reading an already-patched-and-not-restored
                    archive), but don't assume "4" has anything to do with
                    format versioning.
  offset 28       : uint32 entry count
  offset 32       : entry table, 32 bytes/entry (8x uint32 LE):
                      descOffset, descStoredSize, descSize,
                      dataOffset, dataStoredSize, dataSize,
                      id, volume
                    For every entry seen so far the *payload* actually lives
                    behind the "description" triple (descOffset/descStoredSize/
                    descSize); the "data" triple is unused (zero) for ordinary
                    entries. We therefore read the description triple.

  A part's bytes (descStoredSize bytes on disk, descSize bytes decoded) are
  a sequence of "chunk frames":
      uint32 frameLen        - total bytes of this frame, INCLUDING this
                                 4-byte field itself
      <frameLen-4 bytes>     - either:
                                 - a compressed sub-chunk: 1-byte LZMA
                                   propbyte + 4-byte LE dict_size, followed by
                                   raw LZMA1 compressed payload, decoding to
                                   *at least* the needed bytes (decompressing
                                   the full payload can run past the true
                                   chunk boundary because raw LZMA1 has no
                                   end-of-stream marker - the decoded output
                                   must be trimmed to exactly 32768 bytes, or
                                   the last partial chunk's remaining byte
                                   count, whichever is smaller)
                                 - OR a raw (uncompressed) sub-chunk if the
                                   bytes don't parse as a plausible LZMA
                                   header (this is detected, not flagged
                                   explicitly - see _decode_single_chunk)
  Chunks are concatenated to reconstruct the full decoded part.

M3MP pack (the decoded payload of entry 39959):
  offset 0  : magic b"M3MP"
  offset 4  : uint32 fileCount
  offset 8  : uint32 chunkCount        (number of inner 32KB LZMA chunks)
  offset 12 : uint32 chunkTableOffset  (ABSOLUTE offset, from the start of
                                         the M3MP buffer, where the inner
                                         chunk table begins - this is also
                                         exactly where the file-name table
                                         ends)
  offset 16 : file table, fileCount entries x 16 bytes (4x uint32 LE):
                 cumOffset  - this file's start offset in the fully
                              decompressed "data blob" (logical, not a file
                              offset)
                 size       - this file's decompressed byte length
                 nameOffset - ABSOLUTE offset (from M3MP buffer start) of a
                              NUL-terminated path string for this file
                 reserved   - observed 0
              (cumOffset of record i+1 == cumOffset_i + size_i; i.e. this is
              simply a running total, not stored separately)
  then       : name table (NUL-terminated path strings, referenced by
               nameOffset above), ending exactly at chunkTableOffset
  at chunkTableOffset:
               inner chunk table, chunkCount entries x 12 bytes (3x uint32):
                 chunkOffset       - ABSOLUTE offset (from M3MP buffer start)
                                      of this chunk's compressed bytes
                 storedSize        - compressed byte length
                 decompressedSize  - decompressed byte length (32768 for all
                                      but the last chunk)
               Each chunk's bytes are a 1-byte LZMA propbyte + 4-byte LE
               dict_size + raw LZMA1 payload, same trim-to-declared-size rule
               as the outer blobset layer.
  Concatenating all inner chunks (trimmed) reconstructs one big "data blob";
  each file's content is data_blob[cumOffset : cumOffset+size].

Usage:
    python extract.py --list                       # just print the index/entry info
    python extract.py --entry 39959 --out <dir>     # extract entry 39959's M3MP contents
"""

import argparse
import struct
import lzma
import os
import sys

BLOBSET_PATH = r"D:\SteamLibrary\steamapps\common\Rugby League\data\data-0.blobset.pc"
DEFAULT_OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "extracted")

CHUNK_SIZE = 32768


class BlobsetEntry:
    __slots__ = ("desc_offset", "desc_stored", "desc_size",
                 "data_offset", "data_stored", "data_size", "id", "volume", "index")

    def __init__(self, fields, index):
        (self.desc_offset, self.desc_stored, self.desc_size,
         self.data_offset, self.data_stored, self.data_size,
         self.id, self.volume) = fields
        self.index = index


def read_blobset_index(path):
    with open(path, "rb") as f:
        header = f.read(32)
        if len(header) < 32:
            raise ValueError("file too short for a blobset header")
        hash20 = header[:20]
        magic = header[20:24]
        version, count = struct.unpack_from("<2I", header, 24)
        if magic != b"BOLB":
            raise ValueError(f"expected BOLB magic, got {magic!r}")
        if version != 4:
            raise ValueError(f"expected version 4, got {version}")
        entries = []
        table = f.read(32 * count)
        if len(table) != 32 * count:
            raise ValueError("truncated entry table")
        for i in range(count):
            fields = struct.unpack_from("<8I", table, i * 32)
            entries.append(BlobsetEntry(fields, i))
    return hash20, version, count, entries


def _lzma_props_from_byte(propbyte):
    lc = propbyte % 9
    d = propbyte // 9
    lp = d % 5
    pb = d // 5
    return lc, lp, pb


def _decode_single_chunk(buf, pos, frame_or_stored_len, target_size, *, has_len_prefix):
    """
    Decode one LZMA (or raw) sub-chunk starting at buf[pos].

    If has_len_prefix: buf[pos:pos+4] is a uint32 "frameLen" that includes
    itself (outer blobset layer). Otherwise, frame_or_stored_len is already
    the exact stored byte length of this chunk (inner M3MP chunk-table case)
    and buf[pos] is the first byte of the chunk's own data (no length
    prefix to skip).

    Returns (decoded_bytes_trimmed_to_target, next_pos).
    """
    if has_len_prefix:
        frame_len = struct.unpack_from("<I", buf, pos)[0]
        if frame_len < 4:
            raise ValueError(f"bad frame length {frame_len} at {pos}")
        body = buf[pos + 4: pos + frame_len]
        next_pos = pos + frame_len
    else:
        frame_len = frame_or_stored_len
        body = buf[pos: pos + frame_len]
        next_pos = pos + frame_len

    decoded = None
    if len(body) >= 5:
        propbyte = body[0]
        dict_size = struct.unpack_from("<I", body, 1)[0]
        if 0 < dict_size <= (1 << 24):
            lc, lp, pb = _lzma_props_from_byte(propbyte)
            if lc + lp <= 4 and pb <= 4:
                try:
                    filt = [{"id": lzma.FILTER_LZMA1, "dict_size": dict_size,
                             "lc": lc, "lp": lp, "pb": pb}]
                    dec = lzma.LZMADecompressor(format=lzma.FORMAT_RAW, filters=filt)
                    out = dec.decompress(body[5:])
                    if len(out) >= target_size:
                        decoded = out[:target_size]
                except lzma.LZMAError:
                    decoded = None

    if decoded is None:
        # Fall back to "stored raw" - the body itself is the (uncompressed)
        # content, trimmed/padded to the target size.
        decoded = body[:target_size]

    return decoded, next_pos


def decode_outer_part(path, entry):
    """Decode a blobset entry's description payload.

    Implements the "stored raw" bypass documented above and confirmed
    against Blobset_Tools.Extract.BlobsetV1's ground truth (see pack.py's
    module docstring point 1): when descStoredSize == descSize there is NO
    frame-prefixed chunking at all, just the bytes verbatim. This matters in
    practice for a freshly-installed entry (pack.py's install() always
    writes it flat) - without this check, the chunked decode path below would
    misinterpret the M3MP payload's own leading bytes as a bogus frame
    length and fail or silently truncate."""
    with open(path, "rb") as f:
        f.seek(entry.desc_offset)
        blob = f.read(entry.desc_stored)

    if entry.desc_stored == entry.desc_size:
        return bytes(blob)

    out = bytearray()
    pos = 0
    n_chunks = n_raw = n_comp = 0
    while pos < len(blob) and len(out) < entry.desc_size:
        target = min(CHUNK_SIZE, entry.desc_size - len(out))
        before = len(out)
        decoded, pos = _decode_single_chunk(blob, pos, None, target, has_len_prefix=True)
        out.extend(decoded)
        n_chunks += 1
    if len(out) != entry.desc_size:
        raise ValueError(f"decoded {len(out)} bytes, expected {entry.desc_size}")
    return bytes(out)


def decode_m3mp(buf):
    """Parse an M3MP pack buffer. Returns (file_records, names, data_blob)."""
    if buf[:4] != b"M3MP":
        raise ValueError(f"not an M3MP pack (magic={buf[:4]!r})")
    file_count, chunk_count, chunk_table_off = struct.unpack_from("<3I", buf, 4)

    table_start = 16
    records = []
    for i in range(file_count):
        off = table_start + i * 16
        cum_off, size, name_off, reserved = struct.unpack_from("<4I", buf, off)
        records.append((cum_off, size, name_off, reserved))

    names = []
    for cum_off, size, name_off, reserved in records:
        end = buf.find(b"\x00", name_off)
        if end == -1:
            raise ValueError(f"unterminated name string at {name_off}")
        names.append(buf[name_off:end].decode("latin1"))

    chunk_table = []
    for i in range(chunk_count):
        off = chunk_table_off + i * 12
        chunk_off, stored_size, decomp_size = struct.unpack_from("<3I", buf, off)
        chunk_table.append((chunk_off, stored_size, decomp_size))

    # The highest (cumOffset+size) across ALL records, not just the last
    # array entry: table array order need not correlate with cumOffset order
    # (confirmed against Blobset Tools' own M3MP reader, which never assumes
    # that either - see pack.py's module docstring point 3). In the pristine
    # file these happen to coincide because entries were originally laid out
    # in cumOffset order, but a rebuilt pack that keeps an edited file at its
    # original array index while appending its new bytes at the tail will not
    # have the max-cumOffset record last in the array.
    logical_total = max((c + s) for c, s, _, _ in records) if records else 0
    data_blob = bytearray()
    for chunk_off, stored_size, decomp_size in chunk_table:
        decoded, _ = _decode_single_chunk(buf, chunk_off, stored_size, decomp_size, has_len_prefix=False)
        data_blob.extend(decoded)

    if len(data_blob) != logical_total:
        raise ValueError(f"inner data blob is {len(data_blob)} bytes, expected {logical_total}")

    return records, names, bytes(data_blob)


def extract_entry(blobset_path, entry_index, out_dir, verbose=True):
    hash20, version, count, entries = read_blobset_index(blobset_path)
    if entry_index < 0 or entry_index >= count:
        raise IndexError(f"entry {entry_index} out of range (0..{count - 1})")
    entry = entries[entry_index]

    if verbose:
        print(f"Blobset: {count} entries total (version {version}).")
        print(f"Entry {entry_index}: descOffset={entry.desc_offset} "
              f"descStored={entry.desc_stored} descSize={entry.desc_size}")

    part = decode_outer_part(blobset_path, entry)
    if verbose:
        print(f"Decoded outer part: {len(part)} bytes (magic={part[:4]!r})")

    records, names, data_blob = decode_m3mp(part)
    if verbose:
        print(f"M3MP pack: {len(records)} file entries, "
              f"data blob {len(data_blob)} bytes")

    os.makedirs(out_dir, exist_ok=True)
    n_written = 0
    n_skipped_empty = 0
    for (cum_off, size, name_off, reserved), name in zip(records, names):
        rel_path = name.replace("\\", "/").lstrip("/")
        dest = os.path.join(out_dir, *rel_path.split("/"))
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        content = data_blob[cum_off:cum_off + size]
        with open(dest, "wb") as f:
            f.write(content)
        n_written += 1
        if size == 0:
            n_skipped_empty += 1

    if verbose:
        n_lua = sum(1 for n in names if n.lower().endswith(".lua"))
        print(f"Wrote {n_written} files to {out_dir} "
              f"({n_lua} with .lua extension, {n_skipped_empty} zero-byte).")

    return records, names, out_dir


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--blobset", default=BLOBSET_PATH, help="path to data-0.blobset.pc")
    ap.add_argument("--entry", type=int, default=39959, help="0-based entry index to extract (default 39959)")
    ap.add_argument("--out", default=DEFAULT_OUT, help="output directory")
    ap.add_argument("--list", action="store_true", help="only print index/entry info, don't extract")
    args = ap.parse_args()

    if args.list:
        hash20, version, count, entries = read_blobset_index(args.blobset)
        print(f"{args.blobset}: BOLB v{version}, {count} entries")
        e = entries[args.entry]
        print(f"entry {args.entry}: descOffset={e.desc_offset} descStored={e.desc_stored} "
              f"descSize={e.desc_size} id={e.id} volume={e.volume}")
        return

    extract_entry(args.blobset, args.entry, args.out)


if __name__ == "__main__":
    main()
