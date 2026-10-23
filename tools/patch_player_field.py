#!/usr/bin/env python3
"""
patch_player_field.py - in-place single-field editor for
extracted/defaultdata/defaultdata_players (see parse_players.py for the
full format writeup).

Only supports changing the VALUE of a field that is already explicitly SET
(flag byte == 0x01) to a new value of the SAME width. This is deliberately
the simplest, safest edit: it never touches the presence flag, so the
record's total byte length - and therefore every subsequent player's
offset - is completely unaffected. Flipping a field from "default" (flag
0x00, zero value bytes) to "explicitly set" (flag 0x01, N value bytes)
would grow the record and shift every later record's data; that's a real
feature to add later (requires either growing the file and gaining write
access to pack.py's blobset patching, or shrinking a nearby field to make
room), not something this script attempts.

Usage:
    python patch_player_field.py --name "Kalyn Ponga" --field licensed --value 0
    python patch_player_field.py --id 233 --field licensed --value 0 --dry-run
"""

import argparse
import shutil
import struct
import sys

sys.path.insert(0, __file__.rsplit("\\", 1)[0])
import parse_players as pp


def locate_field(data, anchor_end, bound, field_name):
    """Returns (flag_pos, value, width) for field_name, derived from the
    FULL FIELD_ORDER parse (pp._dfs_fields), never a truncated one - see
    that function's docstring for why a truncated search isn't safe here
    (it diverged from the true parse for "height", confirmed by testing)."""
    result = pp._dfs_fields(data, pp.FIELD_ORDER, anchor_end, bound)
    if result is None:
        return None
    chosen, _endpos = result
    for name, width, val, flag_pos in chosen:
        if name == field_name:
            return flag_pos, val, width
    return None


WIDTH_SIZE = {"u8": 1, "u16": 2, "u32": 4}


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--path", default=pp.DEFAULT_PATH)
    ap.add_argument("--id", type=int, default=None)
    ap.add_argument("--name", default=None, help='"Firstname Surname"')
    ap.add_argument("--field", required=True)
    ap.add_argument("--value", type=int, required=True)
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--no-backup", action="store_true")
    args = ap.parse_args()

    if args.field not in pp.FIELD_ORDER:
        print(f"unknown field {args.field!r} - must be one of: {', '.join(pp.FIELD_ORDER)}")
        return 1

    data = bytearray(open(args.path, "rb").read())
    anchors = pp.find_anchors(data)

    target = None
    for idx, (start, end, player_id, firstname, surname) in enumerate(anchors):
        if args.id is not None and player_id == args.id:
            target = (idx, start, end, player_id, firstname, surname)
            break
        if args.name is not None and f"{firstname} {surname}".lower() == args.name.lower():
            target = (idx, start, end, player_id, firstname, surname)
            break

    if target is None:
        print("player not found")
        return 1

    idx, start, end, player_id, firstname, surname = target
    bound = anchors[idx + 1][0] if idx + 1 < len(anchors) else len(data)

    located = locate_field(data, end, bound, args.field)
    if located is None:
        print(f"could not locate field {args.field!r} for {firstname} {surname} (id={player_id})")
        return 1

    flag_pos, current_val, width = located
    print(f"{firstname} {surname} (id={player_id}): {args.field} currently = {current_val!r}")

    if current_val is None:
        print(f"field {args.field!r} is at its design default (flag=0) for this player - "
              f"this script only edits already-SET fields (see module docstring), can't proceed")
        return 1

    size = WIDTH_SIZE[width]
    value_pos = flag_pos + 1

    if args.dry_run:
        print(f"(dry run) would write {args.value} ({width}, {size} bytes) at offset {value_pos}")
        return 0

    if not args.no_backup:
        backup_path = args.path + ".bak"
        shutil.copyfile(args.path, backup_path)
        print(f"backed up original to {backup_path}")

    if width == "u8":
        data[value_pos] = args.value & 0xFF
    elif width == "u16":
        struct.pack_into("<H", data, value_pos, args.value & 0xFFFF)
    elif width == "u32":
        struct.pack_into("<I", data, value_pos, args.value & 0xFFFFFFFF)

    with open(args.path, "wb") as f:
        f.write(data)

    print(f"wrote {args.field} = {args.value} at offset {value_pos} ({width})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
