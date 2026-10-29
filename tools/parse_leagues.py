#!/usr/bin/env python3
"""
parse_leagues.py - reader for extracted/defaultdata/defaultdata_leagues (26
competition/league records: NRL, Hostplus Cup QLD, NSW Cup, Super League,
Championship, League 1, Representative, Developer, NRLW, WSL, Challenge Cup
(M/W), International, Representative Womens, 1895 Cup, 2026 equivalents of
most of the above, World Cup Men/Women).

Format: same self-describing-schema + sparse flag-per-field convention as
defaultdata_players/defaultdata_clubs (see parse_players.py's docstring for
the general mechanics). Anchors on id (flag+u32) immediately followed by two
consecutive length-prefixed strings (name, shortName) - this must be found
with a plain left-to-right byte scan (find_anchors below), NOT a regex: a
regex's finditer silently "uses up" a span the moment it matches the raw
byte shape, even one this code's own ASCII/length validation will reject
moments later as a false positive (there are many small coincidental matches
inside each league's own "clubs" id array) - once a span is consumed,
finditer never rescans starting inside it, so a handful of real leagues get
silently skipped depending on exact regex tuning. The hand-rolled scanner
here advances one byte at a time until a position's own chain validates, so
it can't make that mistake.

Confirmed fields after name/shortName, in order: icon (flag+u32), B (flag+
u8), C (flag+u8), sortIndex (flag+u32), then a variable-length clubs[] array
(flag+u32 per slot, consumed until the next league's anchor).

B and C's real schema names are NOT confirmed - the schema preamble lists
several candidate labels in this neighbourhood ("sex", "sort club list",
"can select as favourite", "is career league", "isFrontendLeague" x2,
"worldCupLeague") but, same as "sex" turning out not to matter for
shirtName's position in player records, the schema's TEXT order doesn't
reliably predict actual field identity here either. What IS confirmed
empirically: B is 0 for DEVELOPER (clearly meant to stay internal) and for
one of each duplicate pair of "CHAMPIONSHIP 2026"/"CHALLENGE CUP 2026"
entries (ids 17 and 22 - this file has two near-identical records for each
of those, one with B=0 and one with B=1), suggesting B gates whether a
league record is actually in use/shown. C was 0 for every single league in
this file - no signal yet on what it does.

Applied fix: INTRUST SUPER PREMIERSHIP (NSW) 2025 (id=3, the NSW Cup) had
B=0 while every other currently-running competition had B=1. Flipped to 1
(see patch at D:\\...\\extracted\\defaultdata\\defaultdata_leagues, offset
1074 in the pristine file) and installed into M3MP entry 39954. Not yet
confirmed in-game whether this was sufficient on its own to make NSW Cup
selectable (clubs were already individually unhidden via defaultdata_clubs'
frontendVisible, in entry 39957).

Usage:
    python parse_leagues.py --list
"""

import argparse
import json
import os
import re
import struct

DEFAULT_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "extracted", "defaultdata", "defaultdata_leagues")
DEFAULT_EXPORT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "decompiled", "defaultdata", "defaultdata_leagues")


def _try_str(data, pos):
    if pos >= len(data) or data[pos] != 1:
        return None
    length = data[pos + 1]
    if not (3 <= length <= 64):
        return None
    start = pos + 2
    chunk = data[start:start + length]
    if len(chunk) != length or not all(32 <= b < 127 for b in chunk):
        return None
    return chunk.decode("latin1"), start + length


def find_anchors(data):
    """Hand-rolled left-to-right scan - see module docstring for why this
    can't be a regex. Returns [(start, end, id, name, shortName), ...]."""
    matches = []
    pos = 0
    while pos < len(data) - 10:
        if data[pos] != 1:
            pos += 1
            continue
        id_val = struct.unpack_from("<I", data, pos + 1)[0]
        p = pos + 5
        r1 = _try_str(data, p)
        if r1 is None:
            pos += 1
            continue
        name, p2 = r1
        r2 = _try_str(data, p2)
        if r2 is None:
            pos += 1
            continue
        shortname, p3 = r2
        matches.append((pos, p3, id_val, name, shortname))
        pos = p3  # jump past this whole match - never rescan inside it
    return matches


def parse_record(data, end, bound):
    """Decode icon/B/C/sortIndex/clubs[] starting right after a league's
    shortName (end), bounded by the next league's anchor start."""
    p = end
    fields = {}

    def read_u32():
        nonlocal p
        if data[p] == 1:
            val = struct.unpack_from("<I", data, p + 1)[0]
            p += 5
            return val
        p += 1
        return None

    def read_u8():
        nonlocal p
        if data[p] == 1:
            val = data[p + 1]
            p += 2
            return val
        p += 1
        return None

    fields["icon"] = read_u32()
    fields["B"] = read_u8()
    fields["C"] = read_u8()
    fields["sortIndex"] = read_u32()

    clubs = []
    while p < bound:
        val = read_u32()
        if val is not None:
            clubs.append(val)
    fields["clubs"] = clubs
    return fields


def load_leagues(path=DEFAULT_PATH):
    data = open(path, "rb").read()
    anchors = find_anchors(data)
    leagues = []
    for idx, (start, end, id_val, name, shortname) in enumerate(anchors):
        bound = anchors[idx + 1][0] if idx + 1 < len(anchors) else len(data)
        fields = parse_record(data, end, bound)
        leagues.append({"id": id_val, "name": name, "shortName": shortname, **fields})
    return leagues


def export_json(leagues, out_dir):
    os.makedirs(out_dir, exist_ok=True)
    written = 0
    for lg in leagues:
        safe = re.sub(r"[^A-Za-z0-9_-]", "_", lg["shortName"])
        dest = os.path.join(out_dir, f"{lg['id']:06d}_{safe}.json")
        with open(dest, "w") as f:
            json.dump(lg, f, indent=2)
        written += 1
    return written


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--path", default=DEFAULT_PATH)
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--export-dir", default=None, nargs="?", const=DEFAULT_EXPORT_DIR,
                     help=f"write one JSON file per league (default: {DEFAULT_EXPORT_DIR})")
    args = ap.parse_args()

    leagues = load_leagues(args.path)

    if args.export_dir:
        written = export_json(leagues, args.export_dir)
        print(f"wrote {written} league JSON files to {args.export_dir}")
        return

    for lg in leagues:
        print(f"id={lg['id']:3d} B={lg['B']} C={lg['C']} sortIndex={lg['sortIndex']:>3} "
              f"clubs={len(lg['clubs']):3d} {lg['name']!r} ({lg['shortName']})")


if __name__ == "__main__":
    main()
