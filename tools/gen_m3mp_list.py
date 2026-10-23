#!/usr/bin/env python3
"""
gen_m3mp_list.py - regenerate the "<Index>.xml" / M3MP_List.xml manifest that
Blobset Tools' own GUI writes when you extract an M3MP bundle (ExtractFileInfo
root, Index + IsCompressed attrs, one self-closing <Entry FilePath="..." />
per contained file, in the bundle's own internal file order).

This repo only ever has ONE such manifest on disk at a time at the project
root (M3MP_List.xml) - that's the GUI's own behavior (it overwrites the file
on every extraction) and exactly the "doesn't reflect all of them, just the
last one" problem. Rather than re-extract each of the other bundles through
the GUI one at a time to regenerate their manifest, this reconstructs the
identical XML directly from the bundle's own file-record table (same decode
as extract_m3mp.py's decode_m3mp) - byte-for-byte verified against the real
GUI-produced M3MP_List.xml for entry 39959 (diff clean).

So when it's time to build a mod for entry N via Blobset Tools' M3MP Creator
(which expects the project's extracted/ folder + a M3MP_List.xml at the
project root matching the entry you're packing), copy manifests/<N>.xml over
the root M3MP_List.xml first.

Usage:
    python gen_m3mp_list.py --entry 39954 --out ../manifests/39954.xml
    python gen_m3mp_list.py --all --out-dir ../manifests
"""

import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pack  # noqa: E402
import classify_entries as ce  # noqa: E402
import extract_m3mp as em  # noqa: E402

ALL_KNOWN_ENTRIES = [39952, 39953, 39954, 39955, 39956, 39957, 39958, 39959,
                     39960, 39962, 57644, 57645, 57647, 85314]


def build_manifest_xml(entry, records):
    lines = [b'<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n']
    lines.append(f'<ExtractFileInfo Index="{entry}" IsCompressed="false">\r\n'.encode("latin1"))
    lines.append(b'  <Entries>\r\n')
    for _cum, _size, name in records:
        rel = name.replace("\\", "/")
        lines.append(f'    <Entry FilePath="{rel}" />\r\n'.encode("latin1"))
    lines.append(b'  </Entries>\r\n')
    lines.append(b'</ExtractFileInfo>')
    return b"".join(lines)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--blobset", default=pack.BLOBSET_PATH)
    ap.add_argument("--entry", type=int, default=None)
    ap.add_argument("--all", action="store_true", help="generate for every known bundle entry")
    ap.add_argument("--out", default=None, help="output path (single --entry mode)")
    ap.add_argument("--out-dir", default=None, help="output directory (--all mode, writes <entry>.xml)")
    args = ap.parse_args()

    ce.load_index(args.blobset)

    entries = ALL_KNOWN_ENTRIES if args.all else [args.entry]
    if not args.all and args.entry is None:
        ap.error("pass --entry N or --all")

    for entry in entries:
        raw, folder, file_hash, bpath = ce.read_blob_full(args.blobset, entry)
        if raw is None:
            print(f"entry {entry}: blob not found at {bpath}, skipping")
            continue
        records, _files = em.decode_m3mp(raw)
        xml = build_manifest_xml(entry, records)

        if args.all:
            os.makedirs(args.out_dir, exist_ok=True)
            dest = os.path.join(args.out_dir, f"{entry}.xml")
        else:
            dest = args.out

        with open(dest, "wb") as f:
            f.write(xml)
        print(f"entry {entry}: {len(records)} files -> {dest}")


if __name__ == "__main__":
    main()
