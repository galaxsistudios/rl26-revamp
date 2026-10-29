#!/usr/bin/env python3
"""
generate.py - write this mod's club and league overrides from the STOCK
defaultdata_clubs (entry 39957) and defaultdata_leagues (entry 39954).

RL26 ships most clubs twice: a "2025" club (ids 1-102 and the women's 32-51)
and its 2026 counterpart (118-183, women's 184-203). This folds every 2025
club into its 2026 club and hides the 2025 one:

- Men's clubs: each 2025 kit the 2026 club doesn't already have (same top /
  shorts / socks design guids = same kit) is copied onto the 2026 club as
  "<NAME> 2025", after its own kits.
- Women's clubs: the hidden 2026 clubs are clones of the 2025 ones (same
  rosters, and the 2025 designs as HOME/AWAY), stored with a thinner kit
  schema, while the 2025 clubs carry the real 2026 kits as "HOME 26" /
  "AWAY 2026". So the 2026 club takes the 2025 club's whole kit list: its
  2026 kits become HOME / AWAY (the defaults) and the rest get " 2025". The
  2026 women's clubs are unhidden.
- 2025 clubs with a 2026 counterpart are hidden (frontendVisible 0). Clubs
  without one stay: Featherstone Rovers 2025 (91), Warrington Wolves Women (49).
- Leagues: the 2025 leagues that have a 2026 version are hidden. NRLW 2026
  and WSL 2026 (hidden, but listing the 2025 women's clubs) are pointed at
  the 2026 clubs and shown; the women's Challenge Cup and the 1895 Cup (no
  2026 version) are pointed at the 2026 clubs.

    python tools\\extract_m3mp.py --entry licenseddata --out <tmp>\\39957   # STOCK entries
    python tools\\extract_m3mp.py --entry gamedata --out <tmp>\\39954
    python mods\\merge-2025-clubs\\generate.py --clubs <tmp>\\39957\\defaultdata\\defaultdata_clubs ^
        --leagues <tmp>\\39954\\defaultdata\\defaultdata_leagues
"""

import argparse
import glob
import json
import os
import re
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import bigant_db  # noqa: E402
import kit_blob  # noqa: E402

CLUBS_DIR = os.path.join(HERE, "defaultdata", "defaultdata_clubs")
LEAGUES_DIR = os.path.join(HERE, "defaultdata", "defaultdata_leagues")

# 2025 club name -> 2026 club name, where they don't match after stripping " 2025"
ALIASES = {
    "Salford Red Devils": "Salford RLFC",
    "St George Illawarra Dragons Women": "St George Dragons Women",
    "York Valkyrie": "York Valkyrie Women",
}
FIRST_2026_ID = 118
# leagues with a 2026 version: hidden
HIDE_LEAGUES = {1: "NRL 2025", 2: "QLD 2025", 4: "SL 2025", 5: "CHAMPIONSHIP 2025", 6: "LEAGUE1 2025",
                9: "NRLW", 10: "WSL", 11: "CHALLENGE CUP (M)"}
# leagues pointed at the 2026 clubs (and shown)
REPOINT_LEAGUES = {21: "NRLW 2026", 20: "WSL 2026", 12: "CHALLENGE CUP (W)", 15: "1895 CUP"}
SHOW_LEAGUES = {21, 20}
# WSL 2026 is the 2026 women's Super League clubs as authored (Featherstone
# 197 in, Warrington 49 has no 2026 club), not a 1:1 swap of the 2025 list
LEAGUE_CLUBS = {20: list(range(196, 204))}
# menu order of the shown leagues (sort index 1, 2, ...); the hidden ones follow
LEAGUE_ORDER = [
    (18, "NRL 2026"), (21, "NRLW 2026"), (19, "QLD 2026"), (3, "NSW 2025"),
    (7, "REP"), (14, "REPW"),
    (16, "SL2026"), (20, "WSL 2026"), (23, "CHAMPIONSHIP2026"), (24, "CHALLENGE CUP 26"),
    (12, "CHALLENGE CUP (W)"), (15, "1895 CUP"),
    (13, "INT"), (25, "RLWC MEN"), (26, "RLWC WOMEN"),
]
LEAGUE_NAMES = {7: ("NRL REPRESENTATIVE", "NRL REP"), 14: ("NRLW REPRESENTATIVE", "NRLW REP")}
# shown leagues lose their season year ("NATIONAL RUGBY LEAGUE 2026" -> "... LEAGUE")
SEASON_SUFFIX = re.compile(r"\s*(?:20)?2[56]$")
DESIGN_FIELDS = ("uniformTop", "uniformBottom", "uniformSocks")
SEASON_KIT = re.compile(r"^(HOME|AWAY|HERITAGE) (26|2026)$")


def design(kits, kit):
    cfg = kit[kit_blob.H_CONFIG][0]
    fields = kits.schema.fields(kit_blob.CONFIG)
    return tuple(cfg[fields[kit_blob.fnv1a32(f)][0]] for f in DESIGN_FIELDS)


def hidden(kit):
    return kit.get(kit_blob.H_HIDDEN) == b"\x01"


def slug(name):
    return re.sub(r"[^A-Za-z0-9.-]+", "_", name).strip("_")


def pair_clubs(clubs):
    """{2025 id: 2026 id} by name (and sex)."""
    by_name = {}
    for cid, c in clubs.items():
        if cid >= FIRST_2026_ID:
            by_name.setdefault((c["fullName"], c.get("sex")), cid)
    pairs = {}
    for cid, c in clubs.items():
        if cid >= FIRST_2026_ID:
            continue
        name = re.sub(r" 2025$", "", c["fullName"])
        new = by_name.get((ALIASES.get(name, name), c.get("sex")))
        if new is not None and (name != c["fullName"] or c.get("sex") == 1):
            pairs[cid] = new
    return pairs


def men_spec(old_id, new_id, blobs):
    old, new = kit_blob.KitList(blobs[old_id]), kit_blob.KitList(blobs[new_id])
    have = {design(new, k) for k in new.kits}
    adds = []
    for kit in old.kits:
        name = old.name(kit)
        if design(old, kit) in have:
            continue
        if SEASON_KIT.match(name):
            raise ValueError(f"club {old_id} kit {name!r} is a 2026 kit the 2026 club doesn't have")
        add = {"name": f"{name} 2025", "copyOf": name, "fromClub": old_id}
        if hidden(kit):
            add["hidden"] = True
        adds.append(add)
    return {"uniforms": {"add": adds}} if adds else None


def women_spec(old_id, blobs):
    old = kit_blob.KitList(blobs[old_id])
    names = old.names()
    season = {n: SEASON_KIT.match(n).group(1) for n in names
              if SEASON_KIT.match(n) and not hidden(old.get(n))}
    spec = {"from": old_id}
    if season:
        # HOME / AWAY only become "... 2025" when a 2026 one takes the name
        spec["rename"] = {n: f"{n} 2025" for n in names
                          if not SEASON_KIT.match(n) and (n not in ("HOME", "AWAY") or n in season.values())}
        spec["rename"].update(season)
        spec["order"] = [n for n in ("HOME", "AWAY") if n in names or n in season.values()]
    return {"uniforms": spec}


def write(directory, rid, label, data):
    path = os.path.join(directory, f"{rid:06d}_{slug(label)}.json")
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        json.dump(data, f, indent=2)
        f.write("\n")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--clubs", required=True, help="STOCK defaultdata_clubs (entry 39957)")
    ap.add_argument("--leagues", required=True, help="STOCK defaultdata_leagues (entry 39954)")
    args = ap.parse_args()

    db = bigant_db.load(open(args.clubs, "rb").read())
    clubs = {r["tables"][0]["id"]: r["tables"][0] for r in db.records}
    blobs = {r["tables"][0]["id"]: r["blob"] for r in db.records}
    pairs = pair_clubs(clubs)

    for d in (CLUBS_DIR, LEAGUES_DIR):
        os.makedirs(d, exist_ok=True)
        for f in glob.glob(os.path.join(d, "*.json")):
            os.remove(f)

    overrides = {}  # club id -> override
    moved = 0
    for old_id, new_id in sorted(pairs.items()):
        old, new = clubs[old_id], clubs[new_id]
        overrides[old_id] = {"frontendVisible": 0}
        if new.get("sex") == 1:
            spec = women_spec(old_id, blobs)
        else:
            spec = men_spec(old_id, new_id, blobs)
        if spec:
            overrides[new_id] = spec
            adds = spec["uniforms"].get("add", [])
            moved += len(adds)
            what = ([a["name"] for a in adds] if adds else
                    f"kit list of {old_id}, renamed {spec['uniforms'].get('rename', {})}")
        else:
            what = "no new kits"
        print(f"{old_id:3d} {old['fullName']!r:40} -> {new_id:3d}: {what}")
    paired_women = {old for old, new in pairs.items() if clubs[new].get("sex") == 1}
    left = sorted(cid for cid, c in clubs.items() if cid < FIRST_2026_ID and cid not in pairs and (
        c["fullName"].endswith(" 2025") or (paired_women and min(paired_women) <= cid <= max(paired_women))))
    print(f"\n{len(pairs)} clubs folded, {moved} men's kits moved. 2025 clubs without a 2026 club (kept): "
          f"{[clubs[c]['fullName'] for c in left]}")

    leagues = bigant_db.load(open(args.leagues, "rb").read())
    table = leagues.tables[0]
    slots = [key for (_t, name, _c), key in zip(table.fields, table.keys) if name == "clubs"]
    by_lid = {r["tables"][0]["id"]: r["tables"][0] for r in leagues.records}
    league_overrides = {}
    shown = [lid for lid, _ in LEAGUE_ORDER]
    hidden_rest = sorted((lid for lid in by_lid if lid not in shown), key=lambda lid: by_lid[lid]["sort index"])
    for index, lid in enumerate(shown + hidden_rest, 1):
        lg, data = by_lid[lid], league_overrides.setdefault(lid, {})
        if lid in shown:
            assert lg["shortName"] == dict(LEAGUE_ORDER)[lid], lg["shortName"]
            name, short = LEAGUE_NAMES.get(lid, (SEASON_SUFFIX.sub("", lg["name"]), SEASON_SUFFIX.sub("", lg["shortName"])))
            if name != lg["name"]:
                data["name"] = name
            if short != lg["shortName"]:
                data["shortName"] = short
            print(f"league {lid}: #{index} {name!r} ({short})")
        if lg["sort index"] != index:
            data["sortIndex"] = index
    for rec in leagues.records:
        lg = rec["tables"][0]
        lid = lg["id"]
        if lid in HIDE_LEAGUES:
            assert lg["shortName"] == HIDE_LEAGUES[lid], lg["shortName"]
            league_overrides[lid]["B"] = 0
            print(f"league {lid} {lg['shortName']!r}: hidden")
        elif lid in REPOINT_LEAGUES:
            assert lg["shortName"] == REPOINT_LEAGUES[lid], lg["shortName"]
            old = [lg[k] for k in slots if lg.get(k) is not None]
            new = LEAGUE_CLUBS.get(lid) or [pairs.get(c, c) for c in old]
            data = league_overrides[lid]
            data["clubs"] = new
            if lid in SHOW_LEAGUES:
                data["B"] = 1
                for cid in new:  # a shown league's clubs must be shown too
                    if clubs[cid].get("frontendVisible") == 0:
                        overrides.setdefault(cid, {})["frontendVisible"] = 1
            print(f"league {lid} {lg['shortName']!r}: {old} -> {new}{' (shown)' if lid in SHOW_LEAGUES else ''}")

    for lid, data in sorted(league_overrides.items()):
        if data:
            write(LEAGUES_DIR, lid, by_lid[lid]["shortName"], data)
    for cid, data in sorted(overrides.items()):
        write(CLUBS_DIR, cid, clubs[cid]["fullName"], dict(sorted(data.items(), key=lambda kv: kv[0] != "frontendVisible")))


if __name__ == "__main__":
    sys.exit(main())
