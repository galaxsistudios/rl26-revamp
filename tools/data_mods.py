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

# league override keys applied by _apply_whole_record_patches
LEAGUE_WHOLE_RECORD_KEYS = ("clubs", "name", "shortName", "sortIndex")
# club override keys applied by _apply_whole_record_patches (they resize records)
CLUB_WHOLE_RECORD_KEYS = ("uniforms", "rosterList", "lineupTables")

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
    import games
    found = {}
    if not os.path.isdir(mods_dir):
        return found
    for mod_name in sorted(os.listdir(mods_dir)):
        mod_path = os.path.join(mods_dir, mod_name)
        if not os.path.isdir(mod_path) or not games.mod_enabled(mod_path)[0]:
            continue  # mods needing a game that isn't enabled (tools/games.py)
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


UNIFORM_BLOB_MAGIC = b"\xBC\xED\x34\x12"
# value width per schema tag in the uniform blob (see _uniform_layout)
UNIFORM_TAG_FMT = {0xFDEB: "<B", 0xFDE8: "<B", 0xFDED: "<H", 0xFDEF: "<I"}


def _uniform_layout(data, end, bound):
    """Decode a club's kit (uniform) blob: the BC ED 34 12 serializer that
    follows the lineup. Layout (worked out 2026-10-22/24):
        magic u32, u16 version, u16 ntypes, ntypes x (u32 name hash, u16 index)
        ntypes x type: u16 nfields, u32 byte size, nfields x
            (u32 FNV-1a32 field name, u32 byte offset, u16 tag, u16 count)
            tag 0xFDEB u8, 0xFDE8 bool, 0xFDED u16, 0xFDEF u32; a small tag is
            the index of a nested type.
        then the type-2 instance: u16 kit count, then `capacity` fixed-size kit
        records (type 0: 25-byte name, the kit config struct (type 1), optional
        isHidden bool), then the per-category default kit indices.
    Capacity is fixed per club (20 for most NRL clubs) and unused slots are
    zero, so adding a kit doesn't resize anything."""
    m = data.find(UNIFORM_BLOB_MAGIC, end, bound)
    if m < 0:
        return None
    ntypes = struct.unpack_from("<H", data, m + 6)[0]
    p = m + 8 + 6 * ntypes
    types = []
    for _ in range(ntypes):
        nfields, size = struct.unpack_from("<HI", data, p)
        p += 6
        fields = {}
        for _ in range(nfields):
            h, off, tag, count = struct.unpack_from("<IIHH", data, p)
            fields[h] = (off, tag, count)
            p += 12
        types.append((size, fields))
    record_size, record_fields = types[0]
    arrays = [f for f in types[2][1].values() if f[1] == 0]  # array of type 0 = the kits
    if len(arrays) != 1:
        raise ValueError("unexpected uniform blob layout (no single kit array)")
    array_off, _tag, capacity = arrays[0]
    config_off = next(f[0] for f in record_fields.values() if f[1] == 1)
    return {
        "count_pos": p,
        "records_pos": p + array_off,
        "record_size": record_size,
        "capacity": capacity,
        "record_fields": record_fields,
        "config_off": config_off,
        "config_fields": types[1][1],
    }


def _patch_npc(data, anchors, by_id, record_id, override, fname, verbose):
    """defaultdata_npcs extras: same-length firstname/surname renames (in
    place, so no record moves) and "visual": {option: value} patches to the
    record's CCharacterVisualConfig blob (parse_npcs.visual_layout)."""
    applied = 0
    start, end, _id = by_id[record_id]
    first, sur = next(a[3:5] for a in pn.find_anchors(bytes(data)) if a[2] == record_id)
    pos = start + 5  # past the id's flag + u32: firstname flag, length, chars
    for key, cur in (("firstname", first), ("surname", sur)):
        new = override.get(key, cur)
        if new != cur:
            if len(new) != len(cur) or not new.isascii():
                raise ValueError(
                    f"defaultdata_npcs: id {record_id} {key} {cur!r} -> {new!r} in {fname!r}: only "
                    f"same-length ASCII renames are supported (a new length would resize the record)"
                )
            data[pos + 2:pos + 2 + len(cur)] = new.encode("ascii")
            applied += 1
            if verbose:
                print(f"    [defaultdata/defaultdata_npcs] id={record_id} {key}: {cur!r} -> {new!r}")
        pos += 2 + len(cur)
    if override.get("visual"):
        applied += _patch_visual(data, anchors, record_id, override["visual"], "defaultdata/defaultdata_npcs", verbose)
    return applied


def _patch_visual(data, anchors, record_id, visual, bundle_path, verbose):
    """{option: value} patches to the CCharacterVisualConfig blob that
    precedes a player or NPC record (same layout in both databases). Every
    option has a fixed slot, so the blob never changes size."""
    applied = 0
    index = [a[2] for a in anchors].index(record_id)
    vstart, vend = pn.record_visual_span(bytes(data), anchors, index)
    blob = bytearray(data[vstart:vend])
    for name, value in visual.items():
        old = pn.visual_set(blob, name, value)
        if old != value:
            applied += 1
            if verbose:
                print(f"    [{bundle_path}] id={record_id} visual.{name}: {old} -> {value}")
    data[vstart:vend] = blob
    return applied


def _all_player_ids():
    """Every player id (bigant_db's exact reader: parse_players' anchor search
    misses ~70 records)."""
    import bigant_db
    return set(bigant_db.load(open(pp.DEFAULT_PATH, "rb").read()).by_id())


def _set_squad(db, rec, override, player_ids, label, verbose):
    """A club's "rosterList": [player ids] (replaces the roster table,
    player1..player64, any length up to 64) and "lineupTables": {table name:
    {field: value}} (replaces those lineup tables whole; NRL lineup slots are
    (position tag << 32) | player id, as bigant_db reads them)."""
    names = [t.name for t in db.tables]
    applied = 0
    if "rosterList" in override:
        roster = override["rosterList"]
        idx = names.index("roster")
        table = db.tables[idx]
        slots = [k for (_typ, name, _cat), k in zip(table.fields, table.keys) if name.startswith("player")]
        if len(roster) > len(slots) or len(set(roster)) != len(roster):
            raise ValueError(f"{label}: rosterList has {len(roster)} players ({len(set(roster))} distinct), "
                             f"a roster holds {len(slots)}")
        unknown = [p for p in roster if p not in player_ids]
        if unknown:
            raise ValueError(f"{label}: rosterList players not in defaultdata_players: {unknown}")
        vals = dict(rec["tables"][idx] or {})
        for i, key in enumerate(slots):
            vals[key] = roster[i] if i < len(roster) else None
        rec["tables"][idx] = vals
        applied += 1
        if verbose:
            print(f"    {label} roster: {len(roster)} players")
    squad = set(override.get("rosterList", []))
    for tname, tvals in override.get("lineupTables", {}).items():
        for key, val in tvals.items():
            if squad and isinstance(val, int) and (val & 0xFFFFFFFF) not in squad:
                raise ValueError(f"{label}: lineup {tname}.{key} = player {val & 0xFFFFFFFF}, not in rosterList")
        rec["tables"][names.index(tname)] = dict(tvals)
        applied += 1
    return applied


def _apply_whole_record_patches(bundle_path, data, pristine, patches, verbose):
    """Overrides that can resize a record, applied through bigant_db's exact
    reader/writer after every in-place patch:
      clubs   "uniforms": kit list edits (kit_blob.apply_spec - copy kits
              from other clubs, rename, reorder, add past the stored capacity)
      leagues "clubs": [club ids] - the league's member clubs, replacing all;
              "name" / "shortName" (any length) and "sortIndex" (menu order,
              ascending)
    `patches` is [(record_id, override, fname)] in override-file order."""
    import bigant_db
    import kit_blob
    db = bigant_db.load(data)
    by_id = db.by_id()
    applied = 0
    if bundle_path == "defaultdata/defaultdata_clubs":
        stock = {r["tables"][0]["id"]: r["blob"] for r in bigant_db.load(pristine).records}
        fill = kit_blob.field_defaults(stock.values())
        player_ids = None
        for record_id, override, fname in patches:
            rec = by_id[record_id]
            label = f"[{bundle_path}] id={record_id}"
            if "uniforms" in override:
                try:
                    rec["blob"] = kit_blob.apply_spec(rec["blob"], override["uniforms"], stock.__getitem__, fill,
                                                      label, verbose)
                except (KeyError, ValueError) as e:
                    raise ValueError(f"{bundle_path}: id {record_id} uniforms (override {fname!r}): {e}") from None
                applied += 1
            if "rosterList" in override or "lineupTables" in override:
                if player_ids is None:
                    player_ids = _all_player_ids()
                applied += _set_squad(db, rec, override, player_ids, f"{label} ({fname})", verbose)
    elif bundle_path == "defaultdata/defaultdata_leagues":
        table = db.tables[0]
        slots = [key for (_typ, name, _cat), key in zip(table.fields, table.keys) if name == "clubs"]
        for record_id, override, fname in patches:
            vals = by_id[record_id]["tables"][0]
            for key, field in (("name", "name"), ("shortName", "shortName"), ("sortIndex", "sort index")):
                if key in override and vals.get(field) != override[key]:
                    if verbose:
                        print(f"    [{bundle_path}] id={record_id} {key}: {vals.get(field)!r} -> {override[key]!r}")
                    vals[field] = override[key]
                    applied += 1
            if "clubs" not in override:
                continue
            clubs = override["clubs"]
            if len(clubs) > len(slots):
                raise ValueError(f"{bundle_path}: id {record_id} lists {len(clubs)} clubs, a league holds "
                                 f"at most {len(slots)} (override {fname!r})")
            old = [vals[k] for k in slots if vals.get(k) is not None]
            for i, key in enumerate(slots):
                vals[key] = clubs[i] if i < len(clubs) else None
            applied += 1
            if verbose:
                print(f"    [{bundle_path}] id={record_id} clubs: {old} -> {clubs}")
    if verbose and applied:
        print(f"  applied {applied} whole-record override(s) to {bundle_path}")
    return bigant_db.dump(db)


def apply_overrides(bundle_path, pristine_bytes, override_files, verbose=True):
    """Return a patched copy of pristine_bytes with every override file in
    override_files (a list of absolute *.json paths, e.g. one directory's
    worth via glob, or several mods' worth combined by the caller) applied.
    Each override file's basename must start with the record's id (e.g.
    "000233_Ponga.json" or just "233.json") - only the leading integer is
    used to find the matching record."""
    bundle = DATA_BUNDLES[bundle_path]
    data = bytearray(pristine_bytes)

    # whole new records ({"new": true, ...}) are appended after the patches
    new_files = [f for f in override_files if json.load(open(f)).get("new")]
    override_files = [f for f in override_files if f not in new_files]

    anchors = bundle["find_anchors"](bytes(data))
    by_id = {a[2]: a for a in anchors}  # id -> (start, end, id)

    # overrides of a club another mod adds ({"new": true}) wait until it exists
    # (e.g. rll4-legacy-kits' kit rows for perth-bears' club 220); only the
    # whole-record keys can be applied to it
    new_ids = set()
    if bundle_path == "defaultdata/defaultdata_clubs":
        new_ids = {json.load(open(f))["clubList"]["id"] for f in new_files}
    for_new = {}

    applied = 0
    whole_record = []  # (id, override, fname) for _apply_whole_record_patches
    for fpath in sorted(override_files):
        fname = os.path.basename(fpath)
        record_id = int(fname.split("_", 1)[0].split(".")[0])
        if record_id not in by_id and record_id in new_ids:
            override = json.load(open(fpath))
            extra = [k for k in override if k not in CLUB_WHOLE_RECORD_KEYS and not k.startswith("_")]
            if extra:
                raise ValueError(f"{bundle_path}: override {fname!r} of new club {record_id} sets {extra}; "
                                 f"only {CLUB_WHOLE_RECORD_KEYS} can be applied to a new club")
            for_new.setdefault(record_id, []).append((override, fname))
            continue
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

        if (bundle_path == "defaultdata/defaultdata_clubs" and any(k in override for k in CLUB_WHOLE_RECORD_KEYS)) or \
                (bundle_path == "defaultdata/defaultdata_leagues" and
                 any(k in override for k in LEAGUE_WHOLE_RECORD_KEYS)):
            whole_record.append((record_id, override, fname))

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

        if bundle_path == "defaultdata/defaultdata_npcs":
            applied += _patch_npc(data, anchors, by_id, record_id, override, fname, verbose)

        if bundle_path == "defaultdata/defaultdata_players" and override.get("visual"):
            applied += _patch_visual(data, anchors, record_id, override["visual"], bundle_path, verbose)

        for key, new_val in override.items():
            if key in IDENTITY_KEYS or key in ("roster", "lineup", "stadium", "alternativeNumberingSystem", "jersey", "visual") \
                    or key.startswith("_"):
                continue
            if bundle_path == "defaultdata/defaultdata_clubs" and key in CLUB_WHOLE_RECORD_KEYS:
                continue
            if bundle_path == "defaultdata/defaultdata_leagues" and key in LEAGUE_WHOLE_RECORD_KEYS:
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
    if whole_record:
        data = bytearray(_apply_whole_record_patches(bundle_path, bytes(data), pristine_bytes, whole_record, verbose))
    if new_files:
        data = bytearray(_append_records(bundle_path, bytes(data), new_files, verbose, for_new))
    return bytes(data)


def _append_clubs(data, files, verbose, for_new):
    """New clubs: {"new": true, "cloneOf": <club id>, "clubList": {field:
    value, null removes it}, "rosterList": [...], "lineupTables": {...},
    "uniforms": <kit_blob spec>}. The club starts as a copy of cloneOf (every
    table and its kit list), as the record carries far more than a JSON would
    want to spell out. The clubList id must be new, and should be the next
    free id: like players, ids far past the record count may abort the game."""
    import copy
    import bigant_db
    import kit_blob
    label_base = "[defaultdata/defaultdata_clubs]"
    db = bigant_db.load(data)
    by_id = db.by_id()
    stock = {cid: rec["blob"] for cid, rec in by_id.items()}
    fill = kit_blob.field_defaults(stock.values())
    player_ids = _all_player_ids()
    for fpath in sorted(files):
        spec = json.load(open(fpath))
        fname = os.path.basename(fpath)
        rec = copy.deepcopy(by_id[spec["cloneOf"]])
        main = rec["tables"][0]
        for key, val in spec.get("clubList", {}).items():
            if val is None:
                main.pop(key, None)
            else:
                main[key] = val
        cid = main["id"]
        if cid in by_id:
            raise ValueError(f"{label_base}: new club {fname} uses id {cid}, which exists")
        label = f"{label_base} new id={cid}"
        if "uniforms" in spec:
            rec["blob"] = kit_blob.apply_spec(rec["blob"], spec["uniforms"], stock.__getitem__, fill, label, verbose)
        _set_squad(db, rec, spec, player_ids, f"{label} ({fname})", verbose)
        # other mods' overrides of this club (kit rows), in file order
        for override, oname in for_new.get(cid, []):
            if "uniforms" in override:
                rec["blob"] = kit_blob.apply_spec(rec["blob"], override["uniforms"], stock.__getitem__, fill,
                                                  f"{label} ({oname})", verbose)
            if "rosterList" in override or "lineupTables" in override:
                _set_squad(db, rec, override, player_ids, f"{label} ({oname})", verbose)
        db.records.append(rec)
        by_id[cid] = rec
        if verbose:
            print(f"  added club {cid} {main.get('fullName')!r} (copy of {spec['cloneOf']})")
    return bigant_db.dump(db)


def _append_records(bundle_path, data, files, verbose, for_new=None):
    """Append whole records to a database via bigant_db (exact schema
    reader/writer). Each file is {"new": true, "<table name>": {field:
    value}, ...} with one key per schema table (a missing table is written
    as absent) and "visual": the record's visual blob, a file path relative
    to the JSON. The id must not exist yet. Works for players and NPCs
    (referees/coaches), which share the visual-before-tables record form
    (defaultdata_npcs added 2026-10-27 for team-coaches' default coaches)."""
    import bigant_db
    if bundle_path == "defaultdata/defaultdata_clubs":
        return _append_clubs(data, files, verbose, for_new or {})
    if bundle_path not in ("defaultdata/defaultdata_players", "defaultdata/defaultdata_npcs"):
        raise ValueError(f"{bundle_path}: adding new records is only supported for defaultdata_players, "
                         f"defaultdata_npcs and defaultdata_clubs")
    db = bigant_db.load(data)
    ids = set(db.by_id())
    for fpath in sorted(files):
        spec = json.load(open(fpath))
        main = spec[db.tables[0].name]
        if main["id"] in ids:
            raise ValueError(f"{bundle_path}: new record {os.path.basename(fpath)} uses id {main['id']}, which exists")
        known = set(bigant_db.field_names(db))
        unknown = set(main) - known
        if unknown:
            raise ValueError(f"{bundle_path}: {os.path.basename(fpath)} has fields the schema doesn't: {sorted(unknown)}")
        with open(os.path.join(os.path.dirname(fpath), spec["visual"]), "rb") as f:
            visual = f.read()
        db.records.append({"visual": visual, "tables": [spec.get(t.name) for t in db.tables]})
        ids.add(main["id"])
    if verbose:
        print(f"  added {len(files)} new record(s) to {bundle_path}")
    return bigant_db.dump(db)
