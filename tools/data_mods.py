#!/usr/bin/env python3
"""
data_mods.py - shared registry + merge-patch logic that lets mods/ override
individual records inside the big packed data files (defaultdata_players,
defaultdata_clubs, defaultdata_leagues) the same way mods/ already overrides
individual Lua scripts - see build.py's module docstring for the Lua side.

Why per-record, not whole-file: these bundle paths are single files holding
thousands of records (defaultdata_players alone is 3,815 players in one
16.7MB file). Overriding the whole file (like a Lua script override) would
mean every mod has to carry a full copy of everyone else's data just to
change one player. Instead, a mod supplies one small JSON file per record
it wants to touch, at:

    mods/<mod-name>/<bundle-path>/<id>_<label>.json

e.g. mods/unlock-ponga/defaultdata/defaultdata_players/000233_Ponga.json
containing just {"licensed": 0}. build.py's scan_mod_overrides recognizes
any mods/ subpath matching a DATA_BUNDLES key as a directory of per-record
overrides (not a literal whole-file override), and build_bundle merges them
onto a fresh decode of the CURRENT pristine extracted/ file at build time
(never a cached/baked-in byte offset - offsets can shift file to file, same
file across a game update even changed defaultdata_clubs' size slightly, so
every build recomputes positions from scratch via each parse_*.py module's
own find_anchors()).

Hard limit (see parse_players.py's patch note): only VALUE changes to
already-SET, fixed-width fields are supported. A field that's currently at
its design default (flag=0, decoded value None) can't be overridden this
way - setting it would grow the record and shift every later record's
bytes, which this merge logic does not attempt. Same for string fields
(firstname, shirtName, club names, ...): changing their length would also
resize the record. Overriding a None field or changing a string's length
raises a clear error rather than silently corrupting the file.

Usage (programmatic, called from build.py):
    patched_bytes = apply_overrides(bundle_path, pristine_bytes, override_files)
"""

import json
import os
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import parse_players as pp
import parse_clubs as pc
import parse_leagues as pl
import parse_npcs as pn
import parse_club_jersey as pcj
import patch_player_field as ppf

WIDTH_SIZE = {"u8": 1, "u16": 2, "u32": 4, "rgb3": 3}


def _players_locate(data, anchor_end, bound, field_name):
    return ppf.locate_field(data, anchor_end, bound, field_name)


def _simple_locate(data, anchor_end, bound, field_order, width_hints, field_name):
    """For clubs/leagues: fixed, unambiguous field widths, no DFS needed -
    just walk the known field order until we reach the target."""
    p = anchor_end
    for name in field_order:
        widths = width_hints.get(name, ("u8",))
        width = widths[0]
        flag_pos = p
        if data[p] == 0:
            val = None
            p += 1
        else:
            if width == "u8":
                val = data[p + 1]
            elif width == "u16":
                val = struct.unpack_from("<H", data, p + 1)[0]
            elif width == "u32":
                val = struct.unpack_from("<I", data, p + 1)[0]
            p += 1 + WIDTH_SIZE[width]
        if name == field_name:
            return flag_pos, val, width
    return None


DATA_BUNDLES = {
    "defaultdata/defaultdata_players": {
        "module": pp,
        "find_anchors": lambda data: [(a[0], a[1], a[2]) for a in pp.find_anchors(data)],  # (start,end,id)
        "locate": _players_locate,
        "record_label": lambda rec: f"{rec[3]}_{rec[4]}",  # unused here, kept for symmetry
    },
    "defaultdata/defaultdata_clubs": {
        "module": pc,
        "find_anchors": lambda data: [(a[0], a[1], a[2]) for a in pc.find_anchors(data)],
        "locate": pc.locate_field,
    },
    "defaultdata/defaultdata_leagues": {
        "module": pl,
        "find_anchors": lambda data: [(a[0], a[1], a[2]) for a in pl.find_anchors(data)],
        "locate": lambda data, end, bound, field: _simple_locate(
            data, end, bound, ["icon", "B", "C", "sortIndex"],
            {"icon": ("u32",), "B": ("u8",), "C": ("u8",), "sortIndex": ("u32",)}, field
        ),
    },
    "defaultdata/defaultdata_npcs": {
        "module": pn,
        "find_anchors": lambda data: [(a[0], a[1], a[2]) for a in pn.find_anchors(data)],
        "locate": pn.locate_field,
    },
}

IDENTITY_KEYS = {"id", "firstname", "surname", "fullName", "shortName", "nickname", "hudName", "name", "shortName"}


def scan_data_mod_overrides(mods_dir):
    """Walk mods_dir looking for per-record JSON overrides under any
    mods/<mod-name>/<bundle-path>/ directory that matches a DATA_BUNDLES
    key. Returns {bundle_path: [abs_json_path, ...]} (files from every mod
    that touches that bundle, combined - multiple mods editing different
    records of the same bundle is fine; data_mods.apply_overrides raises
    if two files would touch the exact same record+field conflictingly...
    actually it doesn't check that yet - last one wins if both set the
    same field. Fine for now, same as Lua mods' "last mod_name wins isn't
    even checked" non-problem since scan_mod_overrides DOES check that one
    - a future improvement could add the same conflict check here.)"""
    found = {}
    if not os.path.isdir(mods_dir):
        return found
    for mod_name in sorted(os.listdir(mods_dir)):
        mod_path = os.path.join(mods_dir, mod_name)
        if not os.path.isdir(mod_path):
            continue
        for bundle_path in DATA_BUNDLES:
            bundle_dir = os.path.join(mod_path, *bundle_path.split("/"))
            if not os.path.isdir(bundle_dir):
                continue
            for fn in os.listdir(bundle_dir):
                if fn.endswith(".json"):
                    found.setdefault(bundle_path, []).append(os.path.join(bundle_dir, fn))
    return found


def data_mod_dirs(mods_dir):
    """Return the set of (mod_path_prefix) directories that scan_mod_overrides
    should skip when walking mods/ for whole-file overrides, i.e. every
    mods/<mod-name>/<bundle-path>/ that actually exists and matches a
    DATA_BUNDLES key."""
    dirs = set()
    if not os.path.isdir(mods_dir):
        return dirs
    for mod_name in os.listdir(mods_dir):
        mod_path = os.path.join(mods_dir, mod_name)
        if not os.path.isdir(mod_path):
            continue
        for bundle_path in DATA_BUNDLES:
            bundle_dir = os.path.join(mod_path, *bundle_path.split("/"))
            if os.path.isdir(bundle_dir):
                dirs.add(os.path.normcase(os.path.abspath(bundle_dir)))
    return dirs


def apply_overrides(bundle_path, pristine_bytes, override_files, verbose=True):
    """Return a patched copy of pristine_bytes with every override file in
    override_files (a list of absolute *.json paths, e.g. one directory's
    worth via glob, or several mods' worth combined by the caller) applied.
    Each override file's basename must start with the record's id (e.g.
    "000233_Ponga.json" or just "233.json") - only the leading integer is
    used to find the matching record."""
    bundle = DATA_BUNDLES[bundle_path]
    data = bytearray(pristine_bytes)

    anchors = bundle["find_anchors"](bytes(data))
    by_id = {a[2]: a for a in anchors}  # id -> (start, end, id)

    applied = 0
    for fpath in sorted(override_files):
        fname = os.path.basename(fpath)
        record_id = int(fname.split("_", 1)[0].split(".")[0])
        if record_id not in by_id:
            raise ValueError(f"{bundle_path}: override {fname!r} references id {record_id}, not found")
        start, end, _id = by_id[record_id]
        next_ids = sorted(a[0] for a in anchors if a[0] > start)
        bound = next_ids[0] if next_ids else len(data)

        override = json.load(open(fpath))

        if bundle_path == "defaultdata/defaultdata_clubs" and "roster" in override:
            new_roster = override["roster"]
            if "_valid_player_ids" not in locals():
                players_data = open(pp.DEFAULT_PATH, "rb").read()
                _valid_player_ids = {a[2] for a in pp.find_anchors(players_data)}
            _parse_fields, pos_after_fields = pc.parse_record(bytes(data), end, bound)
            rstart, current_roster = pc.find_roster(bytes(data), pos_after_fields, bound, _valid_player_ids)
            if current_roster is None:
                raise ValueError(f"{bundle_path}: id {record_id}'s roster couldn't be located (override {fname!r})")
            if len(new_roster) != len(current_roster):
                raise ValueError(
                    f"{bundle_path}: id {record_id}'s roster has {len(current_roster)} slots - "
                    f"override {fname!r} supplies {len(new_roster)}. Changing the slot COUNT isn't "
                    f"supported (would resize the record); you can only swap which player id occupies "
                    f"an existing slot."
                )
            for i, (cur, new) in enumerate(zip(current_roster, new_roster)):
                if cur == new:
                    continue
                if new not in _valid_player_ids:
                    raise ValueError(
                        f"{bundle_path}: id {record_id}'s roster override {fname!r} sets slot {i} to "
                        f"player id {new}, which doesn't exist in defaultdata_players"
                    )
                slot_pos = rstart + i * 5 + 1
                struct.pack_into("<I", data, slot_pos, new & 0xFFFFFFFF)
                applied += 1
                if verbose:
                    print(f"    [{bundle_path}] id={record_id} roster[{i}]: {cur} -> {new}")

        if bundle_path == "defaultdata/defaultdata_clubs" and "lineup" in override:
            new_lineup = override["lineup"]
            if "_valid_player_ids" not in locals():
                players_data = open(pp.DEFAULT_PATH, "rb").read()
                _valid_player_ids = {a[2] for a in pp.find_anchors(players_data)}
            _parse_fields2, pos_after_fields2 = pc.parse_record(bytes(data), end, bound)
            _rstart2, current_roster2 = pc.find_roster(bytes(data), pos_after_fields2, bound, _valid_player_ids)
            if current_roster2 is None:
                raise ValueError(f"{bundle_path}: id {record_id}'s roster couldn't be located (needed to find lineup) (override {fname!r})")
            rend2 = _rstart2 + len(current_roster2) * 5
            _lstart2, lineup_slots = pc.find_lineup(bytes(data), rend2, bound, _valid_player_ids)
            if lineup_slots is None:
                raise ValueError(f"{bundle_path}: id {record_id}'s lineup couldn't be located (override {fname!r})")
            slot_pos_by_name = {name: pos for name, _val, pos in lineup_slots}
            current_lineup = {name: val for name, val, _pos in lineup_slots}
            for slot_name, new in new_lineup.items():
                if slot_name not in slot_pos_by_name:
                    raise ValueError(
                        f"{bundle_path}: id {record_id}'s lineup has no slot {slot_name!r} "
                        f"(override {fname!r}) - known slots: {sorted(slot_pos_by_name)}"
                    )
                cur = current_lineup[slot_name]
                if cur == new:
                    continue
                if not (new in _valid_player_ids or 1 <= new <= 4000):
                    raise ValueError(
                        f"{bundle_path}: id {record_id}'s lineup override {fname!r} sets {slot_name} "
                        f"to player id {new}, which doesn't look like a real player id"
                    )
                struct.pack_into("<I", data, slot_pos_by_name[slot_name], new & 0xFFFFFFFF)
                applied += 1
                if verbose:
                    print(f"    [{bundle_path}] id={record_id} lineup.{slot_name}: {cur} -> {new}")

        if bundle_path == "defaultdata/defaultdata_clubs" and "alternativeNumberingSystem" in override:
            new_ans = override["alternativeNumberingSystem"]
            if "_valid_player_ids" not in locals():
                players_data = open(pp.DEFAULT_PATH, "rb").read()
                _valid_player_ids = {a[2] for a in pp.find_anchors(players_data)}
            _parse_fields4, pos_after_fields4 = pc.parse_record(bytes(data), end, bound)
            rstart4, _roster4 = pc.find_roster(bytes(data), pos_after_fields4, bound, _valid_player_ids)
            if rstart4 is None:
                raise ValueError(f"{bundle_path}: id {record_id}'s roster couldn't be located (needed to find alternativeNumberingSystem) (override {fname!r})")
            ans_pos, cur_ans = pc.find_alternative_numbering(bytes(data), rstart4)
            if ans_pos is None:
                raise ValueError(
                    f"{bundle_path}: id {record_id}'s alternativeNumberingSystem is at its design "
                    f"default (not explicitly set) - override {fname!r} can't be applied."
                )
            if cur_ans != new_ans:
                if not (0 <= new_ans <= 255):
                    raise ValueError(f"{bundle_path}: id {record_id}'s alternativeNumberingSystem override {fname!r} value must be a byte (0-255)")
                data[ans_pos] = new_ans & 0xFF
                applied += 1
                if verbose:
                    print(f"    [{bundle_path}] id={record_id} alternativeNumberingSystem: {cur_ans} -> {new_ans}")

        if bundle_path == "defaultdata/defaultdata_clubs" and "jersey" in override:
            new_jersey = override["jersey"]
            for field_name, new_val in new_jersey.items():
                located = pcj.locate_field(bytes(data), end, bound, field_name)
                if located is None:
                    raise ValueError(
                        f"{bundle_path}: id {record_id} has no jersey field {field_name!r} "
                        f"(override {fname!r}) - known fields: python parse_club_jersey.py --list-fields"
                    )
                value_pos, cur_val = located
                if cur_val == new_val:
                    continue
                if not (0 <= new_val <= 0xFFFFFFFF):
                    raise ValueError(f"{bundle_path}: id {record_id}'s jersey.{field_name} override {fname!r} value must be a u32")
                struct.pack_into("<I", data, value_pos, new_val & 0xFFFFFFFF)
                applied += 1
                if verbose:
                    print(f"    [{bundle_path}] id={record_id} jersey.{field_name}: {cur_val} -> {new_val}")

        if bundle_path == "defaultdata/defaultdata_clubs" and "stadium" in override:
            new_stadium = override["stadium"]
            _parse_fields3, pos_after_fields3 = pc.parse_record(bytes(data), end, bound)
            stadium_pos, cur_stadium = pc.find_stadium(bytes(data), pos_after_fields3, bound)
            if stadium_pos is None:
                raise ValueError(
                    f"{bundle_path}: id {record_id} doesn't have a fixed home stadium in this file "
                    f"(true for representative/all-star sides) - override {fname!r} can't be applied."
                )
            if cur_stadium != new_stadium:
                if not (0 <= new_stadium <= 255):
                    raise ValueError(
                        f"{bundle_path}: id {record_id}'s stadium override {fname!r} value "
                        f"{new_stadium!r} must be a byte (0-255)"
                    )
                data[stadium_pos] = new_stadium & 0xFF
                applied += 1
                if verbose:
                    print(f"    [{bundle_path}] id={record_id} stadium: {cur_stadium} -> {new_stadium}")

        for key, new_val in override.items():
            if key in IDENTITY_KEYS or key in ("roster", "lineup", "stadium", "alternativeNumberingSystem", "jersey"):
                continue
            located = bundle["locate"](bytes(data), end, bound, key)
            if located is None:
                raise ValueError(f"{bundle_path}: unknown field {key!r} for id {record_id} (override {fname!r})")
            flag_pos, current_val, width = located
            value_pos = flag_pos + 1
            if current_val is None:
                raise ValueError(
                    f"{bundle_path}: id {record_id}'s {key!r} is at its design default (not explicitly "
                    f"set in the file) - this merge tool can only change values of already-SET fields, "
                    f"not add new ones (that would grow the record and shift every later record's "
                    f"bytes). Override in {fname!r} can't be applied."
                )
            if width == "str":
                raise ValueError(
                    f"{bundle_path}: id {record_id}'s {key!r} is a string field - changing string "
                    f"values isn't supported yet (a different length would resize the record). "
                    f"Override in {fname!r} can't be applied."
                )
            if current_val == new_val:
                continue
            if width == "u8":
                data[value_pos] = new_val & 0xFF
            elif width == "u16":
                struct.pack_into("<H", data, value_pos, new_val & 0xFFFF)
            elif width == "u32":
                struct.pack_into("<I", data, value_pos, new_val & 0xFFFFFFFF)
            elif width == "rgb3":
                if not (isinstance(new_val, list) and len(new_val) == 3 and all(isinstance(v, int) for v in new_val)):
                    raise ValueError(
                        f"{bundle_path}: id {record_id}'s {key!r} is an [R,G,B] colour - override "
                        f"value in {fname!r} must be a 3-element list of ints 0-255, got {new_val!r}"
                    )
                data[value_pos:value_pos + 3] = bytes(v & 0xFF for v in new_val)
            applied += 1
            if verbose:
                print(f"    [{bundle_path}] id={record_id} {key}: {current_val} -> {new_val}")

    if verbose and applied:
        print(f"  applied {applied} field override(s) to {bundle_path}")
    return bytes(data)
