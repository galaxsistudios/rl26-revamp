#!/usr/bin/env python3
"""
motionset.py - read / write animations/motionset.motionset, the global table
of every clip's root-motion summary (CMotionSet).

The cutscene layout (native CCutsceneLayout:init) looks clips up here to place
actors; a clip that's in an animset but not in the motion set aborts the game
natively (0xC0000409). Rugby 25 clips therefore need their records merged into
RL26's motion set before they can play.

Layout (little endian; verified by rebuilding RL26's stock file byte for byte,
see `verify`):
  0x00  u64 0
  0x08  u32 count
  0x0c  u32 bucket count (power of two)
  0x10  u32 bucket table offset (0x1c)
  0x14  u16 0x1c, u16 version (RL26 2, Rugby 25 4)
  0x18  u32 string section offset
  0x1c  buckets, 8 bytes each: u32 fnv1a32(name), u32 index; empty =
        (0, 0xffffffff). Open addressing: slot = hash & (buckets-1), then +1
        (wrapping) until free, inserted in index order.
  then  count x 32-byte records, one per clip: f32 duration, 12 bytes of
        packed root-motion summary, 16 zero bytes. Same layout in both
        games (shared clips with unchanged animation are byte-identical).
  strings: u32 count, count x u32 fnv1a32(name), count x u32 name offset
        (from the string section start), NUL-terminated names.

Usage:
    python motionset.py info [--blobset PATH]
    python motionset.py verify [--blobset PATH]      # parse + rebuild == stock?
"""

import argparse
import struct
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pack  # noqa: E402

LOGICAL_PATH = "animations/motionset.motionset"
EMPTY = (0, 0xFFFFFFFF)
RECORD_SIZE = 32


def fnv1a32(text):
    h = 0x811C9DC5
    for c in text.encode("latin1"):
        h = ((h ^ c) * 0x01000193) & 0xFFFFFFFF
    return h


class MotionSet:
    def __init__(self, names, records, version, bucket_count):
        self.names = list(names)
        self.records = list(records)
        self.version = version
        self.bucket_count = bucket_count

    @classmethod
    def parse(cls, raw):
        zero, count, nb, toff, hdr_size, version, so = struct.unpack_from("<QIIIHHI", raw, 0)
        if zero != 0 or toff != 0x1C or hdr_size != 0x1C:
            raise ValueError("not a motion set (unexpected header)")
        rec_off = toff + nb * 8
        records = [raw[rec_off + i * RECORD_SIZE:rec_off + (i + 1) * RECORD_SIZE] for i in range(count)]
        n2 = struct.unpack_from("<I", raw, so)[0]
        assert n2 == count, "string count != record count"
        offsets = struct.unpack_from(f"<{count}I", raw, so + 4 + count * 4)
        names = []
        for o in offsets:
            end = raw.index(b"\0", so + o)
            names.append(raw[so + o:end].decode("latin1"))
        ms = cls(names, records, version, nb)
        ms._bucket_check = [struct.unpack_from("<II", raw, toff + i * 8) for i in range(nb)]
        return ms

    def index(self, name):
        try:
            return self.names.index(name)
        except ValueError:
            return None

    def add(self, name, record):
        if len(record) != RECORD_SIZE:
            raise ValueError("record must be 32 bytes")
        if name in self.names:
            raise ValueError(f"{name} already in motion set")
        self.names.append(name)
        self.records.append(bytes(record))

    def build(self):
        count = len(self.names)
        nb = self.bucket_count
        while count * 2 > nb:  # keep the stock files' <= 50% load
            nb *= 2
        buckets = [EMPTY] * nb
        for i, name in enumerate(self.names):
            h = fnv1a32(name)
            slot = h & (nb - 1)
            while buckets[slot] != EMPTY:
                slot = (slot + 1) & (nb - 1)
            buckets[slot] = (h, i)

        strings = bytearray()
        offsets = []
        str_base = 4 + count * 8
        for name in self.names:
            offsets.append(str_base + len(strings))
            strings += name.encode("latin1") + b"\0"

        toff = 0x1C
        so = toff + nb * 8 + count * RECORD_SIZE
        out = bytearray(struct.pack("<QIIIHHI", 0, count, nb, toff, 0x1C, self.version, so))
        for h, i in buckets:
            out += struct.pack("<II", h, i)
        for r in self.records:
            out += r
        out += struct.pack("<I", count)
        out += struct.pack(f"<{count}I", *(fnv1a32(n) for n in self.names))
        out += struct.pack(f"<{count}I", *offsets)
        out += strings
        return bytes(out)


def read_from_index(blobset_path):
    import classify_entries as ce
    data, n, hash_off, size_off = pack.read_index(blobset_path)
    import add_entries as ae
    hashes = struct.unpack_from(f"<{n}Q", data, hash_off)
    i = hashes.index(ae.path_hash(LOGICAL_PATH))
    ce.load_index(blobset_path)
    return i, ce.read_blob_full(blobset_path, i)[0]


def cmd_info(args):
    i, raw = read_from_index(args.blobset)
    ms = MotionSet.parse(raw)
    print(f"entry {i}: {len(ms.names)} clips, version {ms.version}, {ms.bucket_count} buckets, {len(raw)} bytes")


def cmd_verify(args):
    i, raw = read_from_index(args.blobset)
    rebuilt = MotionSet.parse(raw).build()
    if rebuilt == raw:
        print(f"OK: entry {i} rebuilt byte for byte ({len(raw)} bytes)")
    else:
        first = next((k for k in range(min(len(raw), len(rebuilt))) if raw[k] != rebuilt[k]), None)
        print(f"MISMATCH: sizes {len(raw)} vs {len(rebuilt)}, first difference at {first:#x}" if first is not None
              else f"MISMATCH: sizes {len(raw)} vs {len(rebuilt)}")
        sys.exit(1)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--blobset", default=pack.BLOBSET_PATH)
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("info").set_defaults(func=cmd_info)
    sub.add_parser("verify").set_defaults(func=cmd_verify)
    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
