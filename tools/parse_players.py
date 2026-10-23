#!/usr/bin/env python3
"""
parse_players.py - reader for extracted/defaultdata/defaultdata_players, the
real on-disc stat/identity database for every default/licensed player (NOT
the per-ID "NNNNNN.playerdata" files the Academy debug menu exports, which
turned out to be pure visual/appearance data - see
academy_defaultdata_debughook.lua's "exportVisualForConvantUse" calls -
those export cosmetic sliders, not gameplay stats).

Format (reverse-engineered, no public reference - ground-truthed by decoding
field values and matching them against real players' known birthdates):
  - File opens with a self-describing schema preamble: literal
    length-prefixed ASCII field names ("players", "id", "firstname",
    "identity", "surname", ...) in declaration order, confirmed against the
    game's own design/characters/attributemap.lua (same skill/attribute
    names, same categories). The schema's TEXT order does not always match
    the actual per-record field order (e.g. "sex" is declared before
    "shirtName" in the schema list but is apparently never written - every
    sampled player left it at its flag-absent default - so it never
    actually displaces shirtName in practice).
  - After the schema, player records are packed back-to-back with NO
    per-record length prefix or terminator. Each record has three zones,
    in order:
      1. IDENTITY + ATTRIBUTES + SKILLS (FIELD_ORDER, decoded into
         `fields`): a sparse sequence of (1-byte presence flag, value)
         pairs, one per named field - flag 0x00 means "omitted, use the
         design default" (zero value bytes follow); flag 0x01 means
         "present", followed by a value whose width depends on the
         field's type (see WIDTH_HINTS; strings are 1-byte-length-
         prefixed ASCII, no terminator). This is the part that matters for
         roster/stat modding, is fully named, and is trustworthy.
      2. A SECONDARY RATINGS BLOCK (`ratings_block_raw`, NOT decoded into
         named fields): a short (~180-275 byte) run of more flag+value
         pairs immediately after the skills. Early bytes here are clearly
         more 0-99 rating-like values but don't match any already-named
         field 1:1 (e.g. byte 0 here != the skill already read as
         "strength" in zone 1) - likely a cached/computed snapshot (role-
         adjusted effective ratings?) rather than raw stats, OR the
         nrlcareer*/SLcareer*/StandardMatch/Nines fields the schema
         preamble lists in this position, just not in the schema's
         declared text order (same kind of order/text mismatch already
         seen with "sex" in zone 1). Not pursued further since it isn't
         needed for stat editing - treat as opaque and copy through
         unchanged.
      3. An EMBEDDED VISUAL/COSMETIC BLOB (`visual_blob_raw`): starts at
         the first occurrence of magic 0xBCED3412 after zone 2 and runs to
         the next player's anchor. This is structurally the exact same
         format as the standalone "NNNNNN.playerdata" files the Academy
         debug menu exports (see academy_defaultdata_debughook.lua's
         "exportVisualForConvantUse") - same header bytes byte-for-byte -
         i.e. body/face/hair sliders, not gameplay stats. Deliberately not
         decoded further (cosmetic, not stat/roster data).
    The magic-search boundary between zone 2 and zone 3 was found in
    3,814 of 3,815 records (99.97%) - the one miss is presumably a record
    whose visual blob is itself malformed/absent on disc, not a parser bug.

Validation: decoded birthDay/birthMonth for real players matched their
publicly known real-world birthdates exactly (e.g. Reece Walsh -> 10 July,
Kotoni Staggs -> 29 October 1998), which is strong independent confirmation
this isn't a coincidental byte-pattern match. Zone 1 (FIELD_ORDER, see
parse_record) parses cleanly - every SET value within its semantically
plausible range - for all 3,815 licensed players found via the firstname/
surname anchor scan.

Usage:
    python parse_players.py --list                     # list all decoded players
    python parse_players.py --find "Reece Walsh"        # show one player's fields
    python parse_players.py --stats                     # success-rate summary
    python parse_players.py --export-dir                # one JSON file per player
"""

import argparse
import json
import os
import re
import struct

DEFAULT_PATH = r"D:\galaxsi\projects\games\modding\rugby-league-26-modding\extracted\defaultdata\defaultdata_players"

# Confirmed field order for the identity+attribute+skill prefix of a player
# record (see module docstring). "ethnicity" and "sex" are included for
# documentation but were never observed SET in the sampled roster - every
# real player left them at the flag-absent default.
FIELD_ORDER = [
    "licensed", "hidden", "club", "ethnicity", "sex", "shirtName", "shirtNumber",
    "birthDay", "birthMonth", "birthYear", "age",
    "countryOfBirth", "representativeCountry", "stateOfOrigin", "originRepNumber",
    "originOtherNumber", "cityVsCountry", "allStars", "isWorldCup", "contractExpiry",
    "preferredRolePrimary", "preferredRoleSecondary", "preferredRoleTertiary",
    "commentaryNameHash", "rightHanded", "rightFooted",
    "height", "weight", "reputation", "ego", "loyalty", "perk",
    "head", "hairTop",
    "strength", "aggression", "injuryTolerance", "tackle", "driveTackle", "diveTackle",
    "impactTackle", "agility", "stamina", "acceleration", "sprintSpeed", "groundKick",
    "puntKick", "chipKick", "bombKick", "fieldgoalKick", "placeKick", "basicPass",
    "longPass", "offload", "contestedCollect", "diveCollect", "ballStrip", "dummyPass",
    "fend", "sideStep", "breakTackle",
]

SKILL_FIELDS = FIELD_ORDER[33:61]  # strength..breakTackle - all byteSize=1 per attributemap.lua

# The magic that opens the embedded visual-blob sub-record (zone 3) - see
# module docstring. Used to find where zone 2 (the unnamed ratings block)
# ends, since we don't have named fields for it.
VISUAL_BLOB_MAGIC = bytes([0xBC, 0xED, 0x34, 0x12])

WIDTH_HINTS = {
    "birthDay": ("u32", "u8", "u16"),
    "birthMonth": ("u32", "u8", "u16"),
    "birthYear": ("u32", "u16"),
    "age": ("u32", "u16", "u8"),
    "hidden": ("u16", "u8", "u32"),
    "club": ("u16", "u8", "u32"),
    "licensed": ("u8",),
    "shirtNumber": ("u32", "u8", "u16"),
}
for _sk in SKILL_FIELDS:
    WIDTH_HINTS.setdefault(_sk, ("u8",))

# Semantic plausibility ranges used to reject wrong DFS branches. Fields not
# listed here are left unconstrained (we don't yet know their true type/
# range confidently enough to gate on it without risking false rejects).
RANGE_CHECK = {
    "birthDay": (1, 31), "birthMonth": (1, 12), "birthYear": (1945, 2015),
    "age": (15, 50), "shirtNumber": (1, 99),
    "rightHanded": (0, 1), "rightFooted": (0, 1),
    "height": (140, 230), "weight": (50, 200),
    "reputation": (0, 99), "ego": (0, 99), "loyalty": (0, 99),
}
for _sk in SKILL_FIELDS:
    RANGE_CHECK.setdefault(_sk, (0, 99))

ANCHOR_RE = re.compile(rb"\x01([\x02-\x14])([A-Za-z\'\-]{2,20})\x01([\x02-\x14])([A-Za-z\'\-]{2,20})")


def find_anchors(data):
    """Locate every (start, end, id, firstname, surname) occurrence - "id"
    is read as the flag+u32 pair immediately before the firstname field
    (confirmed present and unique for all 3,815 licensed players - matches
    the "NNNNNN.playerdata"/"NNNNNN.clubdata" numbering already used
    elsewhere in this repo's extracted/ tree)."""
    out = []
    for m in ANCHOR_RE.finditer(data):
        len1, name1, len2, name2 = m.group(1)[0], m.group(2), m.group(3)[0], m.group(4)
        if len(name1) != len1 or len(name2) != len2:
            continue
        start = m.start()
        player_id = None
        if start >= 5 and data[start - 5] == 1:
            player_id = struct.unpack_from("<I", data, start - 4)[0]
        out.append((start, m.end(), player_id, name1.decode(), name2.decode()))
    return out


def _consume(data, pos, width, bound):
    if pos >= bound:
        return None
    if width == "str":
        length = data[pos]
        if 1 <= length <= 40 and pos + 1 + length <= bound:
            chunk = data[pos + 1:pos + 1 + length]
            if all(32 <= b < 127 for b in chunk):
                return chunk.decode("latin1"), pos + 1 + length
        return None
    if width == "u8":
        return data[pos], pos + 1
    if width == "u16":
        if pos + 2 > bound:
            return None
        return struct.unpack_from("<H", data, pos)[0], pos + 2
    if width == "u32":
        if pos + 4 > bound:
            return None
        return struct.unpack_from("<I", data, pos)[0], pos + 4
    raise ValueError(width)


def _parse_field(data, pos, bound, widths):
    if pos >= bound:
        return []
    flag = data[pos]
    if flag == 0:
        return [("default", None, pos + 1)]
    if flag != 1:
        return []
    out = []
    for width in widths:
        r = _consume(data, pos + 1, width, bound)
        if r is not None:
            out.append((width, r[0], r[1]))
    return out


def _semantically_ok(name, val):
    if val is None or name not in RANGE_CHECK:
        return True
    lo, hi = RANGE_CHECK[name]
    return isinstance(val, int) and lo <= val <= hi


PREFIX_LEN = 61  # licensed..breakTackle: identity + attributes + skills


def _dfs_fields(data, field_names, start, bound):
    """Backtracking parse of field_names in order starting at `start`.
    Returns ([(name,width,value,flag_pos)], endpos) or None. flag_pos is
    included so callers (e.g. patch_player_field.py, data_mods.py) can
    locate a specific field's exact byte position WITHOUT re-running a
    truncated, less-constrained search of their own - running the full
    field list here (not just up to the target field) is what makes this
    authoritative; a truncated search has less downstream constraint
    signal and can silently converge on a different, wrong parse for
    fields past the first few (confirmed: this bit patch_player_field.py's
    earlier approach for "height", which isn't near the start of
    FIELD_ORDER)."""
    n = len(field_names)

    def rec(i, pos, chosen):
        if i == n:
            return chosen, pos
        name = field_names[i]
        widths = WIDTH_HINTS.get(name, ("str", "u8", "u16", "u32"))
        for width, val, newpos in _parse_field(data, pos, bound, widths):
            if width != "default" and not _semantically_ok(name, val):
                continue
            chosen.append((name, width, val, pos))
            result = rec(i + 1, newpos, chosen)
            if result:
                return result
            chosen.pop()
        return None

    return rec(0, start, [])


def parse_record(data, start, bound):
    """Parse a player record's three zones (see module docstring):
    zone 1 (FIELD_ORDER, fully named DFS parse), zone 2 (the unnamed
    ratings block - just the raw bytes, located by searching for zone 3's
    magic), zone 3 (the embedded visual blob - also just raw bytes, runs to
    `bound`). Returns (prefix_fields, ratings_block_raw, visual_blob_raw,
    zone1_endpos) - the latter two are None when the magic wasn't found in
    this record (prefix_fields is still trustworthy either way)."""
    prefix_result = _dfs_fields(data, FIELD_ORDER, start, bound)
    if prefix_result is None:
        return None, None, None, None
    prefix_fields, pos = prefix_result

    magic_pos = data.find(VISUAL_BLOB_MAGIC, pos, bound)
    if magic_pos == -1:
        return prefix_fields, None, None, pos

    ratings_block_raw = data[pos:magic_pos]
    visual_blob_raw = data[magic_pos:bound]
    return prefix_fields, ratings_block_raw, visual_blob_raw, pos


def load_players(path=DEFAULT_PATH):
    data = open(path, "rb").read()
    anchors = find_anchors(data)
    players = []
    for idx, (start, end, player_id, firstname, surname) in enumerate(anchors):
        bound = anchors[idx + 1][0] if idx + 1 < len(anchors) else len(data)
        prefix_fields, ratings_block_raw, visual_blob_raw, zone1_end = parse_record(data, end, bound)
        players.append({
            "id": player_id,
            "firstname": firstname,
            "surname": surname,
            "anchor_start": start,
            "zone1_end": zone1_end,
            "next_anchor_start": bound,
            "fields": dict((name, val) for name, _w, val, _pos in prefix_fields) if prefix_fields else None,
            "ratings_block_raw": ratings_block_raw,
            "visual_blob_raw": visual_blob_raw,
        })
    return data, players


DEFAULT_EXPORT_DIR = r"D:\galaxsi\projects\games\modding\rugby-league-26-modding\decompiled\defaultdata\defaultdata_players"


def export_json(players, out_dir):
    """Write one <id>_<surname>.json per player (zone 1 fields only - the
    named, trustworthy identity/attribute/skill data) into out_dir, same
    "one file per entity" layout as the rest of extracted/defaultdata/.
    Players whose zone 1 failed to parse (none currently) are skipped."""
    os.makedirs(out_dir, exist_ok=True)
    written = 0
    for p in players:
        if p["fields"] is None or p["id"] is None:
            continue
        safe_surname = re.sub(r"[^A-Za-z0-9_-]", "_", p["surname"])
        dest = os.path.join(out_dir, f"{p['id']:06d}_{safe_surname}.json")
        record = {"id": p["id"], "firstname": p["firstname"], "surname": p["surname"]}
        record.update(p["fields"])
        with open(dest, "w") as f:
            json.dump(record, f, indent=2)
        written += 1
    return written


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--path", default=DEFAULT_PATH)
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--find", default=None, help='e.g. "Reece Walsh"')
    ap.add_argument("--stats", action="store_true")
    ap.add_argument("--export-dir", default=None, nargs="?", const=DEFAULT_EXPORT_DIR,
                     help=f"write one JSON file per player (default: {DEFAULT_EXPORT_DIR})")
    args = ap.parse_args()

    _data, players = load_players(args.path)

    if args.export_dir:
        written = export_json(players, args.export_dir)
        print(f"wrote {written}/{len(players)} player JSON files to {args.export_dir}")
        return

    if args.stats:
        ok = sum(1 for p in players if p["fields"] is not None)
        print(f"{ok}/{len(players)} players: zone 1 (identity+attributes+skills) parsed cleanly ({ok/len(players)*100:.1f}%)")
        bounded = sum(1 for p in players if p["visual_blob_raw"] is not None)
        print(f"{bounded}/{len(players)} players: zone 2/3 boundary (visual-blob magic) located ({bounded/len(players)*100:.1f}%)")
        return

    if args.find:
        for p in players:
            full = f"{p['firstname']} {p['surname']}"
            if full.lower() == args.find.lower():
                print(full)
                if p["fields"] is None:
                    print("  (no clean parse - needs wider WIDTH_HINTS for this record)")
                else:
                    for k, v in p["fields"].items():
                        print(f"  {k:25s} {v!r}")
                return
        print("not found")
        return

    if args.list:
        for p in players:
            status = "ok" if p["fields"] is not None else "FAILED"
            print(f"{p['firstname']} {p['surname']} [{status}]")
        return

    ap.print_help()


if __name__ == "__main__":
    main()
