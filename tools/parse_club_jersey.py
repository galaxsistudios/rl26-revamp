#!/usr/bin/env python3
"""
parse_club_jersey.py - reader/patcher for the jersey/uniform visual blob
embedded in each defaultdata_clubs record (the ~12.6KB chunk after the
lineup that we deliberately left opaque in parse_clubs.py - this module is
what actually cracks it).

Format: a GENERIC property-bag serializer, completely different from the
flag-per-named-field convention used everywhere else in this project (see
parse_players.py's module docstring for that one). Starts with the same
magic 0xBCED3412 we found embedded in player records too (same underlying
visual-config format, shared between players' appearance and clubs'
jerseys). After a short fixed header, the body is a flat run of 12-byte
entries:

    [4-byte type tag][4-byte FNV-1a(32) hash of the field's option name][4-byte value]

The three tags seen so far (0x0001fdeb, 0x0001fded, 0x0001fdef) all use the
same 12-byte shape - no evidence yet that the tag changes the value width,
just something else (maybe the underlying C++ property type: int/float/
enum - not pinned down, doesn't matter for safe value-only editing).

The hash function was reverse-engineered by brute-force testing candidate
option names (pulled directly from the game's own jersey-editor Lua code,
academy_club_jerseystate_appearancestate_edit_groups.lua, which calls
:getOption()/:setOption() with these exact strings) against standard hash
functions - FNV-1a 32-bit matched 71 of our ~71 candidate names outright
(the only 2 non-matches from the broader "every field we know of" list,
primaryRGBColour/secondaryRGBColour, are club-identity fields from the
OTHER format, not jersey fields - their absence here is expected, not a
miss). That is about as strong a confirmation as reverse-engineering a
hash function gets without the original source.

Validated further: decoded colour values land in a plausible 0-255 byte
range (not floats, despite other schema files describing similar-looking
colour options as "type=float" - same kind of schema-metadata/actual-
encoding mismatch already seen elsewhere in this project, e.g. birthYear),
and Brisbane Broncos' uniformTop_layer1_colour (their main jersey colour)
decodes to a dark maroon-ish shade, thematically consistent with (if not
identical to - it's a different render layer) their primaryRGBColour.

NOT fully nailed down: "hasNumber"/"hasPlayerName" (expected to be a
simple 0/1 bool) decode to large, non-boolean-looking integers (372, 385
for Brisbane Broncos) - possibly these particular entries encode something
packed/bit-flagged rather than a plain bool, or the value needs a
different mask/shift than everything else. Left as a known rough edge;
every colour field (the overwhelming majority of what's interesting for
jersey modding) decodes cleanly.

Not attempted: the decal slots (NumDecalsOnTop/NumDecalsOnBottom-many
numbered sponsor/logo decal options per club) - the Lua only gives us the
*shape* of those names (a count pulled from a native constant we don't
have the value of), not concrete strings to hash-test yet.

Usage:
    python parse_club_jersey.py --list-fields          # show the hash table
    python parse_club_jersey.py --club 1                # decode one club's jersey
"""

import argparse
import struct
import sys

sys.path.insert(0, __file__.rsplit("\\", 1)[0])
import parse_clubs as pc

VISUAL_BLOB_MAGIC = bytes([0xBC, 0xED, 0x34, 0x12])
ENTRY_TAGS = (bytes([0xEB, 0xFD, 0x01, 0x00]), bytes([0xED, 0xFD, 0x01, 0x00]), bytes([0xEF, 0xFD, 0x01, 0x00]))


def fnv1a32(s):
    h = 0x811C9DC5
    for b in s.encode():
        h ^= b
        h = (h * 0x01000193) & 0xFFFFFFFF
    return h


def _build_names():
    names = ["uniformTop", "uniformTop_patternLayer01"]
    for layer in range(1, 7):
        for ch in "rgb":
            names.append(f"uniformTop_layer{layer}_colour_{ch}")
    names += ["hasNumber", "numberFont", "showLeadingZero"]
    for ch in "rgb":
        names.append(f"numberColour1_{ch}")
    names.append("numberKeylineWeight")
    for ch in "rgb":
        names.append(f"numberKeylineColour1_{ch}")
    names.append("numberKeylineWeight2")
    for ch in "rgb":
        names.append(f"numberKeylineColour2_{ch}")
    names.append("uniformBottom_patternLayer01")
    for layer in range(1, 5):
        for ch in "rgb":
            names.append(f"uniformBottom_layer{layer}_colour_{ch}")
    names.append("uniformSocks_patternLayer01")
    for layer in range(1, 5):
        for ch in "rgb":
            names.append(f"uniformSocks_layer{layer}_colour_{ch}")
    names += ["uniformBottom", "uniformSocks", "hasPlayerName", "playerNameFont"]
    for ch in "rgb":
        names.append(f"nameColour1_{ch}")
    names.append("nameKeylineWeight")
    for ch in "rgb":
        names.append(f"nameKeylineColour1_{ch}")
    return names


KNOWN_NAMES = _build_names()
HASH_TO_NAME = {fnv1a32(n): n for n in KNOWN_NAMES}
NAME_TO_HASH = {n: h for h, n in HASH_TO_NAME.items()}


def find_blob(data, start, bound):
    """Locate the embedded visual blob (magic-prefixed) between start and
    bound. Returns (blob_start, blob_end) or (None, None)."""
    pos = data.find(VISUAL_BLOB_MAGIC, start, bound)
    if pos == -1:
        return None, None
    return pos, bound


def decode_entries(data, blob_start, blob_end):
    """Scan the whole blob for 12-byte tag+hash+value entries. Returns
    [(entry_byte_pos, tag, hash, value), ...] - entry_byte_pos is where the
    VALUE's 4 bytes start (pos+8), for direct patching."""
    entries = []
    pos = blob_start
    while pos + 12 <= blob_end:
        tag = data[pos:pos + 4]
        if tag in ENTRY_TAGS:
            h = struct.unpack_from("<I", data, pos + 4)[0]
            v = struct.unpack_from("<I", data, pos + 8)[0]
            entries.append((pos + 8, tag, h, v))
            pos += 12
        else:
            pos += 1
    return entries


def decode_named(data, blob_start, blob_end):
    """Returns {field_name: (value, value_byte_pos)} for every entry whose
    hash matches a KNOWN_NAME. Unknown hashes are silently skipped (not
    every field in the blob is named yet - see module docstring)."""
    out = {}
    for value_pos, _tag, h, v in decode_entries(data, blob_start, blob_end):
        name = HASH_TO_NAME.get(h)
        if name is not None:
            out[name] = (v, value_pos)
    return out


def locate_field(data, club_anchor_end, club_bound, field_name):
    """Returns (value_byte_pos, value) for a named jersey field within one
    club's record, or None if not found."""
    target_hash = NAME_TO_HASH.get(field_name)
    if target_hash is None:
        return None
    bstart, bend = find_blob(data, club_anchor_end, club_bound)
    if bstart is None:
        return None
    for value_pos, _tag, h, v in decode_entries(data, bstart, bend):
        if h == target_hash:
            return value_pos, v
    return None


def get_jersey(data, club_anchor_end, club_bound):
    """High-level helper: given a club record's (anchor_end, bound) - same
    as returned by parse_clubs.find_anchors - decode its jersey fields.
    Returns {field_name: value} or {} if no blob was found."""
    bstart, bend = find_blob(data, club_anchor_end, club_bound)
    if bstart is None:
        return {}
    named = decode_named(data, bstart, bend)
    return {name: val for name, (val, _pos) in named.items()}


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--path", default=pc.DEFAULT_PATH)
    ap.add_argument("--club", type=int, default=None, help="club id to decode")
    ap.add_argument("--list-fields", action="store_true")
    args = ap.parse_args()

    if args.list_fields:
        for name in sorted(KNOWN_NAMES):
            print(f"{name:35s} hash=0x{NAME_TO_HASH[name]:08x}")
        return

    data = open(args.path, "rb").read()
    anchors = pc.find_anchors(data)
    for idx, (start, end, cid, full, short, nick, hud) in enumerate(anchors):
        if cid == args.club:
            bound = anchors[idx + 1][0] if idx + 1 < len(anchors) else len(data)
            jersey = get_jersey(data, end, bound)
            print(f"{full!r} ({len(jersey)}/{len(KNOWN_NAMES)} known fields found)")
            for k in sorted(jersey):
                print(f"  {k:35s} {jersey[k]}")
            return
    print("club not found")


if __name__ == "__main__":
    main()
