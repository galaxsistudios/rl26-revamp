#!/usr/bin/env python3
"""
parse_npcs.py - reader for extracted/defaultdata/defaultdata_npcs (91 NPC
records: referees AND coaches - the game keeps both in one database, and
academy_mixin.lua's getCoachManager() literally returns the refereeManager).
Lives in M3MP entry 39954, alongside defaultdata_leagues. Each NPC also has
a standalone NNNNNN.npcdata appearance file in the same entry.

Format: same self-describing-schema + sparse flag-per-field convention as
defaultdata_players/clubs/leagues (see parse_players.py's docstring). Each
record is "01" (list-slot flag) then id (flag+u32), firstname and surname
(flag + 1-byte length + ASCII), then, in order:
    sex (flag+u32), npcType (flag+u32), isWorldCup (flag+u8),
    shirtNumber, height, weight, country (flag+u32 each)
followed by a few unnamed bytes and the embedded visual blob (magic
0xBCED3412) running to the next record. ethnicity/visualType are declared
in the schema but never written.

npcType is native.CNpcType, whose values come from the exe's enum
registration (rugbyleague1.exe 0x1405c4e6c): Referee=0, Coach=1, Hidden=2.
Stock data has NO Coach-type NPCs - every real coach (Ricky Stuart,
Ciraldo, Payten, Peet, ...) plus female referees Kasey Badger and Belinda
Sharpe ship as Hidden, so they never show in the Academy/career coach or
referee lists. See mods/unhide-coaches.

Usage:
    python parse_npcs.py --list
    python parse_npcs.py --export
"""

import argparse
import json
import os
import struct

DEFAULT_PATH = r"D:\galaxsi\projects\games\modding\rugby-league-26-modding\extracted\defaultdata\defaultdata_npcs"
DEFAULT_EXPORT_DIR = r"D:\galaxsi\projects\games\modding\rugby-league-26-modding\decompiled\defaultdata\defaultdata_npcs"

NPC_TYPES = {0: "Referee", 1: "Coach", 2: "Hidden"}

FIELD_ORDER = ["sex", "npcType", "isWorldCup", "shirtNumber", "height", "weight", "country"]
WIDTH_HINTS = {name: ("u32",) for name in FIELD_ORDER}
WIDTH_HINTS["isWorldCup"] = ("u8",)


def _try_str(data, pos):
    if pos + 1 >= len(data) or data[pos] != 1:
        return None
    length = data[pos + 1]
    if not (1 <= length <= 20):
        return None
    start = pos + 2
    chunk = data[start:start + length]
    if len(chunk) != length or not all(32 <= b < 127 for b in chunk):
        return None
    return chunk.decode("latin1"), start + length


def find_anchors(data):
    """Left-to-right scan (not a regex - see parse_leagues.py for why) for
    01 01 <id u32> 01 <firstname> 01 <surname>. Returns
    [(start, end, id, firstname, surname), ...] where start is the id's flag
    byte and end is just past the surname."""
    matches = []
    pos = 0
    while pos < len(data) - 10:
        if data[pos] != 1 or data[pos + 1] != 1:
            pos += 1
            continue
        id_val = struct.unpack_from("<I", data, pos + 2)[0]
        if not (1 <= id_val <= 100000):
            pos += 1
            continue
        r1 = _try_str(data, pos + 6)
        r2 = r1 and _try_str(data, r1[1])
        if r2 is None or not r1[0][:1].isalpha():
            pos += 1
            continue
        matches.append((pos + 1, r2[1], id_val, r1[0], r2[0]))
        pos = r2[1]
    return matches


def parse_record(data, end, bound):
    p = end
    fields = {}
    for name in FIELD_ORDER:
        if p >= bound:
            break
        if data[p] == 0:
            fields[name] = None
            p += 1
        elif WIDTH_HINTS[name][0] == "u8":
            fields[name] = data[p + 1]
            p += 2
        else:
            fields[name] = struct.unpack_from("<I", data, p + 1)[0]
            p += 5
    return fields, p


def locate_field(data, anchor_end, bound, field_name):
    """Returns (flag_pos, value, width) for field_name, or None."""
    p = anchor_end
    for name in FIELD_ORDER:
        width = WIDTH_HINTS[name][0]
        flag_pos = p
        if data[p] == 0:
            val = None
            p += 1
        elif width == "u8":
            val = data[p + 1]
            p += 2
        else:
            val = struct.unpack_from("<I", data, p + 1)[0]
            p += 5
        if name == field_name:
            return flag_pos, val, width
    return None


def load_npcs(path=DEFAULT_PATH):
    data = open(path, "rb").read()
    anchors = find_anchors(data)
    npcs = []
    for idx, (start, end, id_val, first, sur) in enumerate(anchors):
        bound = anchors[idx + 1][0] if idx + 1 < len(anchors) else len(data)
        fields, _ = parse_record(data, end, bound)
        npcs.append({"id": id_val, "firstname": first, "surname": sur, **fields})
    return npcs


def export_json(npcs, out_dir):
    os.makedirs(out_dir, exist_ok=True)
    for n in npcs:
        label = n["surname"].strip().replace(" ", "_")
        with open(os.path.join(out_dir, f"{n['id']:06d}_{label}.json"), "w") as f:
            json.dump(n, f, indent=2)
    print(f"Wrote {len(npcs)} NPC records to {out_dir}")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--path", default=DEFAULT_PATH)
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--export", action="store_true")
    ap.add_argument("--out", default=DEFAULT_EXPORT_DIR)
    args = ap.parse_args()

    npcs = load_npcs(args.path)
    if args.list or not args.export:
        for n in npcs:
            kind = NPC_TYPES.get(n["npcType"], n["npcType"])
            sex = "F" if n["sex"] == 1 else "M"
            print(f"{n['id']:>5}  {kind:<8} {sex}  {n['firstname']} {n['surname']}")
        print(f"{len(npcs)} NPCs")
    if args.export:
        export_json(npcs, args.out)


if __name__ == "__main__":
    main()
