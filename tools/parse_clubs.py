#!/usr/bin/env python3
"""
parse_clubs.py - reader for extracted/defaultdata/defaultdata_clubs (219
club records: every NRL/Super League/Championship/League1/NSW Cup/Hostplus
Cup/women's-competition/international-representative club, plus a handful
of "GF"/"Decider"/"Pro Team" special-match duplicates).

Format: same self-describing-schema + sparse flag-per-field convention as
defaultdata_players (see parse_players.py's module docstring for the
general mechanics - magic header, schema preamble, flag-per-field records,
backtracking DFS over WIDTH_HINTS candidates gated by RANGE_CHECK).

Anchors on id (flag+u32) immediately followed by FOUR consecutive length-
prefixed strings: fullName, shortName, nickname, hudName (e.g. "Brisbane
Broncos 2025" / "Brisbane" / "Broncos" / "BRI"). Confirmed by exact match
against real club names across all 219 records. Uses the same hand-rolled
left-to-right scan as parse_leagues.py (not regex - see that module's
docstring for why finditer's "consumed span" behavior silently skips real
records here too).

FIELD_ORDER below, in order, with how each was confirmed:
  - frontendVisible (u8 bool): the club-level visibility gate (separate
    from the club's LEAGUE needing its own visibility - see
    parse_leagues.py). This is what the "unhide NSW Cup/women's clubs"
    mod flips.
  - defaultLineupCategory (u32): position confirmed (always present,
    always 0 so far), semantic meaning NOT confirmed.
  - shirtName (str): position confirmed (always absent/default so far -
    every sampled club uses the design default, i.e. probably "shortName
    in caps", same pattern as players).
  - sex (u32): EMPIRICALLY confirmed by diffing "Brisbane Broncos 2025"
    (id=1, this field=0) against "Brisbane Broncos Women" (id=184, this
    field=1) - byte-for-byte identical record otherwise. Note this is 4
    bytes wide, not the 1 byte identitymap.lua's ClubIdentity.sex entry
    declares - same kind of schema-metadata/actual-width mismatch already
    seen elsewhere (e.g. birthYear).
  - icon, worldCupIcon (str): confirmed directly - both decode to resource
    names like "nrl_broncos" (matches design/characters/assetmapitems.lua
    naming conventions).
  - supporters, commentaryTeamLocationHash, commentaryTeamMascotHash,
    primaryRGBColour (r/g/b), secondaryRGBColour (r/g/b), hudTextRGBColour
    (r/g/b), clubType, affiliations, isWorldCup: positions found via
    backtracking search (same technique as parse_players.py), typed per
    identitymap.lua's ClubIdentity declarations where available (colours
    are byteSize=1 x3 per identitymap.lua's arraySize=3, so stored as 3
    separately-flagged bytes, not one packed value). Colour values cross-
    checked against real club colours (e.g. Broncos primary reads as a
    maroon-range RGB) as a sanity check, not just "did it parse".

Roster ("teamlist"): a variable-length array of player ids, found via
find_roster() - NOT schema-positioned (too much undecoded stuff before it
varies in size per club), but found by scanning for a long run of valid
player ids. See find_roster()'s own docstring for the validation (all 219
clubs produced plausible squads; Brisbane Broncos' first 19 slots are
exactly ids 1-19, the same players already identified by name early in
this project). Editable per-slot via data_mods.py (swap which player id
occupies an existing slot - same safe "value change only" rule as every
other field; can't change the slot COUNT).

Not yet decoded: home ground info (3 slots + grand final ground),
feederClubs/fedFromClubs (7-slot arrays), and the lineup-by-competition-
type starting-XV slots (who starts at fullback/halfback/etc, as opposed to
who's simply ON the roster).

Usage:
    python parse_clubs.py --list
    python parse_clubs.py --find "Newtown Jets"
    python parse_clubs.py --stats
"""

import argparse
import json
import os
import re
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import parse_players as pp

DEFAULT_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "extracted", "defaultdata", "defaultdata_clubs")
DEFAULT_EXPORT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "decompiled", "defaultdata", "defaultdata_clubs")
DEFAULT_PLAYERS_PATH = pp.DEFAULT_PATH

FIELD_ORDER = [
    "frontendVisible", "defaultLineupCategory", "shirtName", "sex", "icon", "worldCupIcon",
    "supporters", "commentaryTeamLocationHash", "commentaryTeamMascotHash",
    "primaryRGBColour", "secondaryRGBColour", "hudTextRGBColour",
    "clubType", "affiliations", "isWorldCup",
]

COLOUR_FIELDS = {"primaryRGBColour", "secondaryRGBColour", "hudTextRGBColour"}

WIDTH_HINTS = {
    "frontendVisible": ("u8",),
    "defaultLineupCategory": ("u32",),
    "shirtName": ("str",),
    "sex": ("u32", "u8"),
    "icon": ("str",),
    "worldCupIcon": ("str",),
    "supporters": ("u32", "u8", "u16"),
    "commentaryTeamLocationHash": ("u32",),
    "commentaryTeamMascotHash": ("u32",),
    "primaryRGBColour": ("rgb3",),
    "secondaryRGBColour": ("rgb3",),
    "hudTextRGBColour": ("rgb3",),
    "clubType": ("u8",),
    "affiliations": ("u16", "u8", "u32"),
    "isWorldCup": ("u8",),
}

RANGE_CHECK = {
    "frontendVisible": (0, 1),
    "sex": (0, 1),
    "isWorldCup": (0, 1),
    "clubType": (0, 15),
    "affiliations": (0, 2000),
}


def _try_str(data, pos):
    if pos >= len(data) or data[pos] != 1:
        return None
    length = data[pos + 1]
    if not (1 <= length <= 64):
        return None
    start = pos + 2
    chunk = data[start:start + length]
    if len(chunk) != length or not all(32 <= b < 127 for b in chunk):
        return None
    return chunk.decode("latin1"), start + length


def find_anchors(data):
    """Hand-rolled left-to-right scan (not regex - see module docstring).
    Returns [(start, end, id, fullName, shortName, nickname, hudName), ...]."""
    matches = []
    pos = 0
    while pos < len(data) - 10:
        if data[pos] != 1:
            pos += 1
            continue
        id_val = struct.unpack_from("<I", data, pos + 1)[0]
        p = pos + 5
        texts = []
        ok = True
        for _ in range(4):
            r = _try_str(data, p)
            if r is None:
                ok = False
                break
            text, p = r
            texts.append(text)
        if not ok:
            pos += 1
            continue
        matches.append((pos, p, id_val, *texts))
        pos = p
    return matches


def _consume(data, pos, width, bound):
    if pos >= bound:
        return None
    if width == "str":
        length = data[pos]
        if 1 <= length <= 64 and pos + 1 + length <= bound:
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
    if width == "rgb3":
        # one flag (already consumed by caller) then 3 raw bytes R,G,B -
        # NOT 3 independently-flagged channels (confirmed: Broncos'
        # secondaryRGBColour decodes to (253,197,19), real Broncos gold).
        if pos + 3 > bound:
            return None
        return list(data[pos:pos + 3]), pos + 3
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


def _dfs_fields(data, field_names, start, bound):
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


def parse_record(data, end, bound):
    """Returns (fields_dict, endpos) or (None, end) if no valid parse."""
    result = _dfs_fields(data, FIELD_ORDER, end, bound)
    if result is None:
        return None, end
    chosen, pos = result
    return dict((name, val) for name, _w, val, _p in chosen), pos


def _scan_u32_array(data, start, bound):
    """Every consecutive flag(0x01)+u32 slot starting at `start`, stopping
    at the first flag==0 or malformed byte. Returns (values, start, endpos)."""
    pos = start
    vals = []
    while pos + 5 <= bound and data[pos] == 1:
        vals.append(struct.unpack_from("<I", data, pos + 1)[0])
        pos += 5
    return vals, start, pos


def find_roster(data, start, bound, valid_player_ids):
    """The club's "teamlist" - a variable-length array of player ids, found
    (not schema-positioned - too much undecoded stuff before it varies in
    size per club: home grounds, feeder/fed-from club arrays, numbering
    system, none of which are decoded yet) by scanning forward for the
    first run of >=10 consecutive flag+u32 slots where most values are
    real player ids. One leading slot is sometimes NOT a player id (an
    undecoded field immediately before the roster that coincidentally also
    looks like a u32 array entry) - trimmed by dropping any leading value
    that's both not a known id AND implausibly large (>10,000; real player
    ids top out around 3,900). Returns (roster_start_pos, [player_id, ...])
    or (None, None) if no such run is found before `bound`.

    Validated across all 219 clubs: every one produced a plausible squad
    size (19-49 players) and the ids matched real rostered players (e.g.
    Brisbane Broncos' first 19 roster slots are exactly ids 1-19, which are
    Reece Walsh, Jesse Arthars, Selwyn Cobbo, Kotoni Staggs, ... - the same
    players already confirmed by name early in this project's player-
    database work). A handful of ids per club (usually 1-4) don't match any
    known player - consistently the SAME id(s) across variant records of
    the same club (e.g. id 17 is "invalid" for both "Brisbane Broncos 2025"
    and the GF-duplicate "GF Brisbane Broncos" record), so this looks like
    a player our anchor scanner misses (short/unusual name?) rather than a
    roster-decoding bug - not chased down further yet."""
    p = start
    while p < bound:
        vals, rstart, _endp = _scan_u32_array(data, p, bound)
        if len(vals) >= 10 and sum(1 for v in vals if v in valid_player_ids) / len(vals) > 0.5:
            while vals and vals[0] not in valid_player_ids and vals[0] > 10000:
                rstart += 5
                vals.pop(0)
            return rstart, vals
        p += 1
    return None, None


LINEUP_NAMED_SLOTS = ("captain", "goalKicker", "playMaker1", "playMaker2")


def find_lineup(data, start, bound, valid_player_ids):
    """The starting lineup immediately after the roster (for the primary/
    "StandardMatch" competition type - a club has more lineup blocks after
    this one, one per competition type e.g. Nines, not decoded yet).

    Structure (found empirically, not schema-positioned - same reasoning
    as find_roster): 4 NAMED slots (captain, goalKicker, playMaker1,
    playMaker2), each a plain flag+u32 (5 bytes, no tag) - then up to 17
    POSITIONAL slots, each flag+u32+u8 (6 bytes: player id, then a trailing
    tag byte whose exact meaning isn't confirmed, but empirically the tag
    sequence for Brisbane Broncos was 1,5,4,3,2,6,7,8,9,...,17 - a clean
    ascending run from 6 onward, with 1-5 covering fullBack/the four other
    backs in some fixed-but-not-schema-order permutation). The positional
    run reliably ends where tag==0, which is where the NEXT lineup block
    (a different competition type) begins - confirmed on Brisbane Broncos:
    stops at exactly 17 positional slots there, matching 13 named positions
    (fullBack/wingLeft/centreLeft/centreRight/wingRight/fiveEighth/
    halfBack/propLeft/hooker/propRight/secondRowLeft/secondRowRight/Lock)
    + 4 substitutes.

    Validated: fullBack (the first positional slot) decoded to Reece Walsh
    (id 1, Brisbane's actual real-life fullback) and later slots included
    id 4 (Kotoni Staggs, a real Broncos centre) and id 5 (Deine Mariner, a
    real Broncos winger) - not just structurally valid, semantically
    correct.

    Returns (start_pos, [(slot_name, player_id), ...]) or (None, None).
    Per-position NAMES beyond the first 4 are NOT assigned (position0..N
    placeholders) since the tag's exact position-to-name mapping isn't
    confirmed - only that these are, in order, real players who start in
    some back/forward/bench role."""
    def plausible(val):
        # prefer a confirmed real player id, but tolerate ids our player
        # anchor scanner missed (confirmed real gap - e.g. id 627 for
        # Huddersfield Giants - rather than reject the whole lineup over it)
        return val in valid_player_ids or 1 <= val <= 4000

    p = start
    while p < bound:
        pos = p
        slots = []  # (name, value, value_byte_pos)
        ok = True
        for name in LINEUP_NAMED_SLOTS:
            if pos + 5 > bound or data[pos] != 1:
                ok = False
                break
            val = struct.unpack_from("<I", data, pos + 1)[0]
            if not plausible(val):
                ok = False
                break
            slots.append((name, val, pos + 1))
            pos += 5
        if ok:
            i = 0
            while pos + 6 <= bound and data[pos] == 1:
                val = struct.unpack_from("<I", data, pos + 1)[0]
                if not plausible(val):
                    break
                tag = data[pos + 5]
                if tag == 0 and i > 0:
                    break
                slots.append((f"position{i}", val, pos + 1))
                pos += 6
                i += 1
            if len(slots) >= 4 + 10:
                return p, slots
        p += 1
    return None, None


def find_alternative_numbering(data, roster_start):
    """alternativeNumberingSystem (EClubAlternativeNumberingSystems enum) -
    found at a FIXED offset of exactly 7 bytes before the roster's own
    start (flag at roster_start-7, value at roster_start-6), unlike
    stadium/roster/lineup which all needed a forward scan. Validated
    structurally clean (flag byte was 0 or 1, as expected) across all 219
    clubs; value diversity is low (either unset/default, or 1 - "standard"
    numbering - for the large majority) but genuine, not noise - this
    isn't an exciting modding target but is correctly decoded.

    Returns (value_byte_pos, value) - value is None if unset (default)."""
    flag_pos = roster_start - 7
    if data[flag_pos] == 1:
        return flag_pos + 1, data[flag_pos + 1]
    return None, None


def find_stadium(data, pos, bound):
    """The club's primary home stadium (an EStadiums enum value) - found
    (not FIELD_ORDER-positioned, like roster/lineup) right after the main
    FIELD_ORDER fields end, via a confirmed-stable 9-byte prefix pattern:
    bytes [0,1,0,1,?,0,0,0,1] (byte 4 varies per club - 1, 2 or 3 seen so
    far, meaning isn't the stadium) followed immediately by the stadium
    value itself as a plain u8.

    Validated: matches 191/219 clubs, and critically the 28 non-matches
    are EVERY representative/all-star side (Queensland Maroons, NSW Blues,
    Australia Kangaroos, England Three Lions, Indigenous All Stars, Maori
    All Stars, ...) - teams that genuinely don't have a fixed home venue,
    so the absence of a match there is semantically correct, not a parse
    failure. Across the 191 matches, values cluster into 54 distinct,
    plausible stadium ids (5-94) - not noise.

    Returns (value_byte_pos, stadium_id) or (None, None)."""
    p = data[pos:pos + 9]
    if len(p) == 9 and p[0:4] == bytes([0, 1, 0, 1]) and p[5:9] == bytes([0, 0, 0, 1]):
        return pos + 9, data[pos + 9]
    return None, None


def locate_field(data, anchor_end, bound, field_name):
    """Returns (flag_pos, value, width) for field_name, derived from the
    full FIELD_ORDER parse - see parse_players.py's _dfs_fields docstring
    for why a truncated search isn't safe (same risk applies here)."""
    result = _dfs_fields(data, FIELD_ORDER, anchor_end, bound)
    if result is None:
        return None
    chosen, _endpos = result
    for name, width, val, flag_pos in chosen:
        if name == field_name:
            return flag_pos, val, width
    return None


def load_clubs(path=DEFAULT_PATH, players_path=DEFAULT_PLAYERS_PATH, with_roster=True):
    data = open(path, "rb").read()
    anchors = find_anchors(data)

    valid_player_ids = set()
    if with_roster:
        players_data = open(players_path, "rb").read()
        valid_player_ids = {a[2] for a in pp.find_anchors(players_data)}

    clubs = []
    for idx, (start, end, id_val, full, short, nick, hud) in enumerate(anchors):
        bound = anchors[idx + 1][0] if idx + 1 < len(anchors) else len(data)
        fields, pos = parse_record(data, end, bound)
        stadium = None
        if fields is not None:
            _spos, stadium = find_stadium(data, pos, bound)

        roster = None
        lineup = None
        altNumbering = None
        if with_roster and fields is not None:
            rstart, roster = find_roster(data, pos, bound, valid_player_ids)
            if roster is not None:
                _anpos, altNumbering = find_alternative_numbering(data, rstart)
                rend = rstart + len(roster) * 5
                _lstart, lineup_slots = find_lineup(data, rend, bound, valid_player_ids)
                if lineup_slots is not None:
                    lineup = dict((name, val) for name, val, _pos in lineup_slots)
        clubs.append({
            "id": id_val, "fullName": full, "shortName": short,
            "nickname": nick, "hudName": hud, "anchor_end": end,
            **(fields or {}),
            "stadium": stadium,
            "alternativeNumberingSystem": altNumbering,
            "roster": roster,
            "lineup": lineup,
        })
    return data, clubs


def export_json(clubs, out_dir):
    os.makedirs(out_dir, exist_ok=True)
    written = 0
    for c in clubs:
        safe = re.sub(r"[^A-Za-z0-9_-]", "_", c["shortName"])
        dest = os.path.join(out_dir, f"{c['id']:06d}_{safe}.json")
        record = {k: v for k, v in c.items() if k != "anchor_end"}
        with open(dest, "w") as f:
            json.dump(record, f, indent=2)
        written += 1
    return written


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--path", default=DEFAULT_PATH)
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--find", default=None, help='matches fullName, case-insensitive substring')
    ap.add_argument("--stats", action="store_true")
    ap.add_argument("--export-dir", default=None, nargs="?", const=DEFAULT_EXPORT_DIR,
                     help=f"write one JSON file per club (default: {DEFAULT_EXPORT_DIR})")
    args = ap.parse_args()

    _data, clubs = load_clubs(args.path)

    if args.stats:
        ok = sum(1 for c in clubs if c.get("frontendVisible") is not None or "frontendVisible" in c)
        full_ok = sum(1 for c in clubs if "clubType" in c)
        print(f"{len(clubs)} clubs total, {full_ok} parsed the full FIELD_ORDER cleanly")
        return

    if args.export_dir:
        written = export_json(clubs, args.export_dir)
        print(f"wrote {written} club JSON files to {args.export_dir}")
        return

    if args.find:
        needle = args.find.lower()
        for c in clubs:
            if needle in c["fullName"].lower():
                print(c)
        return

    for c in clubs:
        print(f"id={c['id']:3d} frontendVisible={c.get('frontendVisible')} {c['fullName']!r}")


if __name__ == "__main__":
    main()
