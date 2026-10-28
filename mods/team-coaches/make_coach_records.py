#!/usr/bin/env python3
"""
make_coach_records.py - write the default club coaches the game doesn't ship
as new stock NPC records (entry 39954, defaultdata_npcs), so every save has
them.

The coaches come from DefaultClubCoaches (and FemaleCoaches) in
coach_helper_block.lua. Every name the stock NPC database doesn't have (names
compared like the Lua nameKey: lowercase letters only) gets a record. Ids
come from coach_ids.json, which only ever grows: a coach keeps its id across
rebuilds (Identity picks are saved by NPC id), and a new coach gets the next
free id from 7001.

Each new coach copies a generic placeholder NPC's record (cycling through the
male or female templates by id) with the new id, the coach's name, sex and
npcType Coach. The look is built with the character creator's own options
(coach_look.py): it starts from look_base_{male,female}.visual.bin (a
non-scanned player layout with the hair / beard slots the generic NPC looks
lack), sets the face (the coach's "face" features, or a random face seeded
by id so no two coaches match), then coach_looks.json's _default_male /
_default_female and the coach's own entry. Every look stays editable in
Academy > Referees & Coaches. Output:
defaultdata/defaultdata_npcs/<id>_<Surname>.json ({"new": true, ...},
appended by tools/data_mods.py) plus <id>.visual.bin.

Usage (repo root), with a STOCK copy of 39954's defaultdata_npcs:
    python mods/team-coaches/make_coach_records.py --npcs <stock>/defaultdata/defaultdata_npcs
"""

import argparse
import json
import os
import re
import sys

MOD = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(MOD))
sys.path.insert(0, os.path.join(REPO, "tools"))
import bigant_db  # noqa: E402

import coach_look  # noqa: E402

OUT = os.path.join(MOD, "defaultdata", "defaultdata_npcs")
LUA = os.path.join(MOD, "coach_helper_block.lua")
IDS = os.path.join(MOD, "coach_ids.json")
FIRST_ID = 7001
NPC_TYPE_COACH = 1
SEX_MALE, SEX_FEMALE = 0, 1

LOOKS = os.path.join(MOD, "coach_looks.json")

# generic placeholder NPCs, the only stock NPCs without a scanned head
# (every other NPC's head is 50000+id)
MALE_TEMPLATES = [455, 457, 460, 461, 462, 463, 464]
FEMALE_TEMPLATES = [456, 458, 459, 465, 466, 467, 468, 469]


def name_key(name):
    return re.sub(r"[^a-z]", "", name.lower())


def lua_table(src, name):
    m = re.search(r"^%s = \{(.*?)^\}" % name, src, re.S | re.M)
    if not m:
        raise SystemExit(f"{name} not found in {LUA}")
    return m.group(1)


def default_coaches():
    src = open(LUA, encoding="utf-8").read()
    names = []
    for name in re.findall(r'^\s*\[\d+\] = "([^"]+)"', lua_table(src, "DefaultClubCoaches"), re.M):
        if name not in names:
            names.append(name)
    female = set(re.findall(r'^\s*\["([^"]+)"\] = true', lua_table(src, "FemaleCoaches"), re.M))
    unknown = female - set(names)
    if unknown:
        raise SystemExit(f"FemaleCoaches not in DefaultClubCoaches: {sorted(unknown)}")
    return names, female


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--npcs", required=True, help="a STOCK defaultdata_npcs (fresh extraction of 39954)")
    args = ap.parse_args()
    data = open(args.npcs, "rb").read()
    db = bigant_db.load(data)
    if bigant_db.dump(db) != data:
        raise SystemExit("defaultdata_npcs doesn't round-trip through bigant_db")
    by_id = db.by_id()
    names_by_id = {i: f'{r["tables"][0]["firstname"]} {r["tables"][0]["surname"]}' for i, r in by_id.items()}
    # other mods' renames (wayne-bennett-coach turns NPC 503 into Wayne Bennett)
    for mod in sorted(os.listdir(os.path.join(REPO, "mods"))):
        folder = os.path.join(REPO, "mods", mod, "defaultdata", "defaultdata_npcs")
        if mod == os.path.basename(MOD) or not os.path.isdir(folder):
            continue
        for fn in os.listdir(folder):
            m = re.match(r"(\d+)_.*\.json$", fn)
            if m and int(m.group(1)) in names_by_id:
                spec = json.load(open(os.path.join(folder, fn), encoding="utf-8"))
                if "firstname" in spec or "surname" in spec:
                    first, last = names_by_id[int(m.group(1))].split(" ", 1)
                    names_by_id[int(m.group(1))] = f'{spec.get("firstname", first)} {spec.get("surname", last)}'
    stock_names = {name_key(n) for n in names_by_id.values()}

    names, female = default_coaches()
    ids = json.load(open(IDS, encoding="utf-8")) if os.path.exists(IDS) else {}
    next_id = max([FIRST_ID - 1] + list(ids.values())) + 1
    missing = [n for n in names if name_key(n) not in stock_names]
    for name in missing:
        if name not in ids:
            ids[name] = next_id
            next_id += 1
    with open(IDS, "w", encoding="utf-8") as f:
        json.dump(dict(sorted(ids.items(), key=lambda kv: kv[1])), f, indent=2)
        f.write("\n")

    looks = json.load(open(LOOKS, encoding="utf-8"))
    bases = {sex: open(path, "rb").read() for sex, path in coach_look.BASES.items()}
    os.makedirs(OUT, exist_ok=True)
    for old in os.listdir(OUT):
        if old.endswith((".json", ".visual.bin")):
            os.remove(os.path.join(OUT, old))
    for name in sorted(missing, key=lambda n: ids[n]):
        new_id = ids[name]
        if new_id in by_id:
            raise SystemExit(f"id {new_id} already exists in defaultdata_npcs")
        first, last = name.split(" ", 1)
        is_female = name in female
        pool = FEMALE_TEMPLATES if is_female else MALE_TEMPLATES
        template_id = pool[(new_id - FIRST_ID) % len(pool)]
        template = by_id[template_id]
        tables = [dict(t) if t is not None else None for t in template["tables"]]
        tables[0].update({"id": new_id, "firstname": first, "surname": last,
                          "sex": SEX_FEMALE if is_female else SEX_MALE, "npcType": NPC_TYPE_COACH})
        look = dict(looks.get("_default_female" if is_female else "_default_male", {}))
        look.update(looks.get(name, {}))
        sex = SEX_FEMALE if is_female else SEX_MALE
        visual, skipped = coach_look.apply(bases[sex], look, sex, new_id)
        if skipped:
            print(f"  {name}: look options not in this layout: {', '.join(skipped)}")
        for key, field in (("height_cm", "height"), ("weight_kg", "weight")):
            if key in look:
                tables[0][field] = look[key]
        spec = {"new": True, "visual": f"{new_id}.visual.bin"}
        for table, values in zip(db.tables, tables):
            spec[table.name] = values
        with open(os.path.join(OUT, f"{new_id}.visual.bin"), "wb") as f:
            f.write(visual)
        safe = re.sub(r"[^A-Za-z]", "", last)
        with open(os.path.join(OUT, f"{new_id:06d}_{safe}.json"), "w", encoding="utf-8") as f:
            json.dump(spec, f, indent=2)
            f.write("\n")
        t0 = template["tables"][0]
        print(f"{new_id} {name}{' (F)' if is_female else ''} (record of NPC {template_id} {t0['firstname']} "
              f"{t0['surname']}{', own look' if name in looks else ''})")
    print(f"{len(missing)} new coach records ({len(names) - len(missing)} defaults already in the stock data)")


if __name__ == "__main__":
    main()
