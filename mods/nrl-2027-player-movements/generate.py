#!/usr/bin/env python3
"""
generate.py - NRL 2027 player movements (Zero Tackle's tracker) applied to the
club rosters, plus the Perth Bears' squad.

Input: resources/player-movements/zerotackle_<date>.json (`fetch` writes it
from https://www.zerotackle.com/nrl/player-movements/): per NRL club, the
"2027 Gains" (with the club they come from), "2027 Losses" (with where they
go, or retired / released / rugby union), "Re-Signed" and "Off Contract".

Rules (the user's, 2026-11-01):
  - gains join the club; losses leave it, joining their new club when that
    club is in the game (Super League, Championship, QLD Cup, Perth Bears),
    else becoming free agents;
  - retired players become free agents (off every roster, rep sides too);
  - no player on two club rosters (rep and international sides excepted):
    a player keeps the club a movement put him at, else the highest tier
    (NRL > Super League / Championship / League 1 > QLD Cup > NSW Cup >
    stale clubs). Stock has ~110 such duplicates, mostly the NSW Cup sides,
    which still carry 2025 squads;
  - squads left short (under MIN_SQUAD) are topped up with unsigned players
    who were at the club's own 2025 record, then any unsigned men;
  - lineups (LeagueMatch / NinesMatch / NRL2026Match) keep their slots: a
    slot whose player left takes a squad member with the same preferred role,
    else any squad member not already picked;
  - career mode plays with the hidden "2025" club records (career data's
    leaguestructure lists ids 1-17 for the NRL), so every hidden 2025 men's
    club takes its 2026 club's final squad and lineups.

Writes defaultdata/defaultdata_clubs/<id>_<name>.json overrides with
"rosterList" / "lineupTables" (applied by tools/data_mods.py through
bigant_db, as they resize records), and movements_report.md.

    python mods\\nrl-2027-player-movements\\generate.py fetch
    python mods\\nrl-2027-player-movements\\generate.py build [--source resources\\player-movements\\x.json]
"""

import argparse
import datetime
import glob
import html
import json
import os
import re
import sys
import unicodedata
import urllib.request
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import bigant_db  # noqa: E402

STOCK = os.path.join(ROOT, "_build", "stock", "licenseddata", "defaultdata")
SRC_DIR = os.path.join(ROOT, "resources", "player-movements")
OUT_DIR = os.path.join(HERE, "defaultdata", "defaultdata_clubs")
URL = "https://www.zerotackle.com/nrl/player-movements/"

PERTH_ID = 220          # mods/perth-bears' club record (a club-slots-224 slot)
MIN_SQUAD = 26          # NRL2026Match needs 19; a few spare for injuries
ROSTER_SLOTS = 64
LINEUP_TABLES = ("LeagueMatch", "NinesMatch", "NRL2026Match")

# Zero Tackle team slug -> 2026 club id
NRL = {
    "brisbane-broncos": 118, "canterbury-bankstown-bulldogs": 119, "north-queensland-cowboys": 120,
    "st-george-illawarra-dragons": 121, "parramatta-eels": 122, "newcastle-knights": 123,
    "penrith-panthers": 124, "south-sydney-rabbitohs": 125, "canberra-raiders": 126,
    "sydney-roosters": 127, "manly-sea-eagles": 128, "cronulla-sharks": 129, "melbourne-storm": 130,
    "wests-tigers": 131, "gold-coast-titans": 132, "new-zealand-warriors": 133, "dolphins": 134,
    "perth-bears": PERTH_ID,
}
# destination / origin names as Zero Tackle writes them -> club id (None: not in the game)
CLUB_NAMES = {
    "Brisbane Broncos": 118, "Canterbury-Bankstown Bulldogs": 119, "North Queensland Cowboys": 120,
    "St George Illawarra Dragons": 121, "Parramatta Eels": 122, "Newcastle Knights": 123,
    "Penrith Panthers": 124, "South Sydney Rabbitohs": 125, "Canberra Raiders": 126,
    "Sydney Roosters": 127, "Manly Sea Eagles": 128, "Cronulla Sharks": 129, "Melbourne Storm": 130,
    "Wests Tigers": 131, "Gold Coast Titans": 132, "New Zealand Warriors": 133, "Dolphins": 134,
    "Perth Bears": PERTH_ID,
    "Castleford Tigers": 135, "Huddersfield Giants": 136, "Hull FC": 137, "Hull Kingston Rovers": 138,
    "Leeds Rhinos": 139, "St Helens Saints": 140, "Wakefield Trinity": 141, "Warrington Wolves": 142,
    "Wigan Warriors": 143, "Leigh Leopards": 144, "Catalans Dragons": 145, "Bradford Bulls": 146,
    "Toulouse Olympique": 147, "York Knights": 148, "London Broncos": 170,
    "Townsville Blackhawk": 160, "Townsville Blackhawks": 160,
}
FREE = ("released", "rugby union", "")
RETIRED = ("retired",)


# ---- fetch ---------------------------------------------------------------------

def parse_page(page):
    """{team slug: {section title: [{slug, name, note}]}} from the tracker's HTML."""
    out = {}
    parts = re.split(r"<a name='([a-z0-9-]+)'></a><div class='shadowBox'>", page)
    for i in range(1, len(parts), 2):
        slug, body = parts[i], parts[i + 1].split("</table>")[0]
        data = {}
        for title, content in re.findall(r"<td class='td-full-width-title'>(.*?)</td></tr><tr><td>(.*?)</td></tr>",
                                         body, re.S):
            items = []
            for m in re.finditer(r"<a href='/players/([^/']+)/'>([^<]+)</a>(\s*\((.*?)\))?(?=,\s*<a href='/players/|$)",
                                 content.strip(), re.S):
                pslug, name, _, extra = m.groups()
                items.append({"slug": pslug, "name": html.unescape(name),
                              "note": html.unescape(re.sub(r"<[^>]+>", "", extra or "")).strip()})
            data[title.strip()] = items
        out[slug] = data
    return out


def cmd_fetch(_args):
    req = urllib.request.Request(URL, headers={"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"})
    page = urllib.request.urlopen(req, timeout=60).read().decode("utf-8")
    data = parse_page(page)
    if len(data) < 17:
        raise SystemExit(f"only {len(data)} teams parsed - the page layout changed?")
    stamp = datetime.date.today().isoformat()
    os.makedirs(SRC_DIR, exist_ok=True)
    with open(os.path.join(SRC_DIR, f"zerotackle_{stamp}.html"), "w", encoding="utf-8") as f:
        f.write(page)
    path = os.path.join(SRC_DIR, f"zerotackle_{stamp}.json")
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=1)
    print(f"{len(data)} teams -> {os.path.relpath(path, ROOT)}")


# ---- database -------------------------------------------------------------------

def norm(s):
    s = unicodedata.normalize("NFKD", s).encode("ascii", "ignore").decode().lower()
    return re.sub(r"[^a-z]", "", s)


class World:
    def __init__(self):
        self.cdb = bigant_db.load(open(os.path.join(STOCK, "defaultdata_clubs"), "rb").read())
        pdb = bigant_db.load(open(os.path.join(STOCK, "defaultdata_players"), "rb").read())
        self.players = {r["tables"][0]["id"]: r["tables"][0] for r in pdb.records}
        self.clubs = self.cdb.by_id()
        self.rosters = {cid: [v for v in (rec["tables"][1] or {}).values() if v]
                        for cid, rec in self.clubs.items()}
        self.rosters[PERTH_ID] = []
        self.by_name = defaultdict(list)
        self.by_surname = defaultdict(list)
        for pid, p in self.players.items():
            self.by_name[norm(f"{p.get('firstname', '')}{p.get('surname', '')}")].append(pid)
            self.by_surname[norm(p.get("surname", ""))].append(pid)

    def info(self, cid):
        if cid == PERTH_ID:
            return {"fullName": "Perth Bears", "sex": 0}
        return self.clubs[cid]["tables"][0]

    def name(self, cid):
        return self.info(cid)["fullName"]

    def pname(self, pid):
        p = self.players[pid]
        return f"{p.get('firstname', '')} {p.get('surname', '')}"

    def is_rep(self, cid):
        return cid != PERTH_ID and (self.info(cid).get("clubType") is not None or cid >= 204)

    def active(self):
        """Club sides a player can only be at one of: the visible 2026 clubs,
        NSW Cup, and the two 2025 clubs merge-2025-clubs keeps (no rep sides)."""
        ids = [i for i in self.clubs if 118 <= i <= 203 or 67 <= i <= 79 or i in (49, 91)]
        return ids + [PERTH_ID]

    def tier(self, cid):
        if 118 <= cid <= 134 or cid == PERTH_ID:
            return 0
        if 135 <= cid <= 148:
            return 1        # Super League (2026)
        if 149 <= cid <= 163:
            return 3        # QLD Cup
        if 164 <= cid <= 203:
            return 2        # Championship / League 1 / women's
        if 67 <= cid <= 79:
            return 4        # NSW Cup
        return 5

    def find(self, name, hint_clubs=()):
        """Player id for a Zero Tackle name, preferring one on hint_clubs."""
        key = norm(name)
        cands = list(self.by_name.get(key, []))
        if not cands:
            # same surname at one of the hinted clubs, first name a prefix either way (Tom / Thomas)
            first, _, surname = name.partition(" ")
            for pid in self.by_surname.get(norm(surname), []):
                f = norm(self.players[pid].get("firstname", ""))
                if f and (f.startswith(norm(first)[:3]) or norm(first).startswith(f[:3])):
                    cands.append(pid)
        if len(cands) > 1 and hint_clubs:
            hinted = [p for p in cands if any(p in self.rosters.get(c, []) for c in hint_clubs)]
            cands = hinted or cands
        if len(cands) > 1:
            # prefer men on any current roster
            men = [p for p in cands if self.players[p].get("sex", 0) == 0]
            cands = men or cands
        return cands[0] if cands else None


# ---- movements -------------------------------------------------------------------

def destination(note):
    """(kind, club id) for a loss note: ("club", id) / ("free", None) / ("retired", None)."""
    note = re.sub(r",?\s*\d{4}$", "", note).strip()
    if note.lower() in RETIRED:
        return "retired", None
    if note.lower() in FREE:
        return "free", None
    cid = CLUB_NAMES.get(note)
    return ("club", cid) if cid else ("free", None)


def plan(world, data):
    """[(pid, from club | None, to club | None, kind, text)] and unmatched names."""
    moves, unmatched, seen = [], [], {}
    for slug, sections in data.items():
        club = NRL.get(slug)
        if club is None:
            continue
        for item in sections.get("2027 Gains", []):
            origin = CLUB_NAMES.get(re.sub(r",?\s*\d{4}$", "", item["note"]).strip())
            pid = world.find(item["name"], [c for c in (origin, club) if c])
            if pid is None:
                unmatched.append((item["name"], f"gain for {world.name(club)} from {item['note'] or '?'}"))
                continue
            seen.setdefault(pid, []).append(("to", club))
            moves.append((pid, origin, club, "gain", f"{item['name']}: {item['note'] or 'new'} -> {world.name(club)}"))
        for item in sections.get("2027 Losses", []):
            kind, to = destination(item["note"])
            pid = world.find(item["name"], [club])
            if pid is None:
                unmatched.append((item["name"], f"loss from {world.name(club)} ({item['note']})"))
                continue
            moves.append((pid, club, to, kind, f"{item['name']}: {world.name(club)} -> "
                          f"{world.name(to) if to else kind}"))
    return moves, unmatched


def apply(world, moves):
    rosters = {cid: list(r) for cid, r in world.rosters.items()}
    pinned = {}          # pid -> club a movement put him at (None = free agent)
    retired = set()
    released = []        # (pid, club) - only leaves that club (the DB may already have him elsewhere)
    for pid, origin, to, kind, _text in moves:
        if kind == "retired":
            retired.add(pid)
            pinned[pid] = None
        elif kind == "gain" or to is not None:
            pinned[pid] = to
        else:
            released.append((pid, origin))
    # a gain listed by the new club wins over a loss listed by the old one
    for pid, origin, to, kind, _text in moves:
        if kind == "gain":
            pinned[pid] = to
    active = set(world.active())
    for pid, club in released:
        if pid in pinned:
            continue
        # off the club and its NSW Cup side (same icon)
        icon = world.info(club).get("icon")
        for cid in active:
            if pid in rosters[cid] and world.info(cid).get("icon") == icon:
                rosters[cid].remove(pid)
    log = []
    for pid, club in pinned.items():
        for cid in list(rosters):
            if pid in rosters[cid] and cid != club and (cid in active or pid in retired):
                rosters[cid].remove(pid)
        if club is not None and pid not in rosters[club]:
            rosters[club].append(pid)
    # one club side per player
    where = defaultdict(list)
    for cid in active:
        for pid in rosters[cid]:
            where[pid].append(cid)
    for pid, cids in where.items():
        if len(cids) < 2:
            continue
        keep = pinned.get(pid) if pinned.get(pid) in cids else min(cids, key=lambda c: (world.tier(c), -c))
        for cid in cids:
            if cid != keep:
                rosters[cid].remove(pid)
                log.append(f"{world.pname(pid)}: off {world.name(cid)} (stays at {world.name(keep)})")
    return rosters, retired, log


def top_up(world, rosters, retired):
    """Squads under MIN_SQUAD take unsigned players, first from the club's own
    stale (2025 / same-name) records, then any unsigned man."""
    active = world.active()
    signed = {pid for cid in active for pid in rosters[cid]}
    log = []
    pool = sorted(pid for pid, p in world.players.items()
                  if pid not in signed and pid not in retired and p.get("sex", 0) == 0 and pid <= 3901)
    for cid in active:
        if cid == PERTH_ID or len(rosters[cid]) >= MIN_SQUAD or world.info(cid).get("sex", 0) != 0:
            continue
        icon = world.info(cid).get("icon")
        own = [pid for oid, r in world.rosters.items() if oid not in active and world.info(oid).get("icon") == icon
               for pid in r if pid in pool]
        for pid in own + pool:
            if len(rosters[cid]) >= MIN_SQUAD:
                break
            if pid in signed:
                continue
            rosters[cid].append(pid)
            signed.add(pid)
            log.append(f"{world.name(cid)}: + {world.pname(pid)}")
    return log


SKILLS = ("strength", "tackle", "agility", "stamina", "acceleration", "sprintSpeed", "groundKick", "puntKick",
          "placeKick", "basicPass", "longPass", "offload", "fend", "sideStep", "breakTackle", "diveCollect")


def role(world, pid):
    return world.players.get(pid, {}).get("preferredRolePrimary")


def slot_roles(world, tname):
    """Lineup slot -> the preferred role most NRL clubs' players in it have
    (starting slots only)."""
    cache = world.__dict__.setdefault("_slot_roles", {})
    if tname not in cache:
        from collections import Counter
        names = [t.name for t in world.cdb.tables]
        counts = defaultdict(Counter)
        for cid in range(118, 135):
            for k, v in (world.clubs[cid]["tables"][names.index(tname)] or {}).items():
                if v and not k.startswith(("Substitute", "captain", "goalKicker", "playMaker")):
                    r = role(world, v & 0xFFFFFFFF)
                    if r is not None:
                        counts[k][r] += 1
        cache[tname] = {k: c.most_common(1)[0][0] for k, c in counts.items()}
    return cache[tname]


def rating(world, pid):
    p = world.players.get(pid, {})
    vals = [p[k] for k in SKILLS if isinstance(p.get(k), int)]
    return sum(vals) / len(vals) if vals else 0


def fix_lineups(world, cid, roster, template=None):
    """The club's lineup tables with every player not in roster replaced."""
    rec = world.clubs.get(cid) or world.clubs[template]
    names = [t.name for t in world.cdb.tables]
    out = {}
    for tname in LINEUP_TABLES:
        idx = names.index(tname)
        table = dict(rec["tables"][idx] or {})
        squad = set(roster)
        slots = [k for k, v in table.items() if k not in ("captain", "goalKicker", "playMaker1", "playMaker2")]
        wide = {k: (v >> 32, v & 0xFFFFFFFF) for k, v in table.items() if k in slots and v is not None and v > 0xFFFFFFFF}
        ids = {k: (wide[k][1] if k in wide else v) for k, v in table.items() if v is not None}
        picked = {ids[k] for k in slots if k in ids and ids[k] in squad}
        spare = sorted((p for p in roster if p not in picked), key=lambda p: -rating(world, p))
        for k in slots:
            cur = ids.get(k)
            if cur in squad:
                continue
            roles = slot_roles(world, tname)
            want = roles[k] if k in roles else role(world, cur)
            pick = next((p for p in spare if want is not None and role(world, p) == want), None) or \
                next((p for p in spare if want is not None and want in (
                    world.players[p].get("preferredRoleSecondary"), world.players[p].get("preferredRoleTertiary"))),
                    None) or (spare[0] if spare else None)
            if pick is None:
                continue
            spare.remove(pick)
            picked.add(pick)
            ids[k] = pick
            table[k] = (wide[k][0] << 32 | pick) if k in wide else pick
        lineup = [ids[k] for k in slots if k in ids]
        for k in ("captain", "goalKicker", "playMaker1", "playMaker2"):
            if k in table and table[k] not in lineup and lineup:
                # the halves (or whoever plays there) for playmakers / kicker, else the first pick
                prefer = {"playMaker1": "halfBack", "playMaker2": "fiveEighth", "goalKicker": "halfBack"}.get(k)
                starters = [ids[s] for s in slots[:13] if s in ids]
                table[k] = ids.get(prefer) if ids.get(prefer) in lineup else                     max(starters or lineup, key=lambda p: rating(world, p))
        out[tname] = table
    return out


def stale_twins(world):
    """2026 men's club id -> hidden 2025 club ids with its icon (career's records)."""
    active = set(world.active())
    twins = defaultdict(list)
    for cid, rec in world.clubs.items():
        t = rec["tables"][0]
        if cid in active or world.is_rep(cid) or t.get("sex", 0) != 0 or t.get("frontendVisible") == 0:
            continue
        if not re.search(r" 2025$", t["fullName"]):
            continue
        for nid in active:
            if nid != PERTH_ID and 118 <= nid <= 183 and world.info(nid).get("icon") == t.get("icon"):
                twins[nid].append(cid)
    return twins


def write_override(cid, name, roster, tables):
    if len(roster) > ROSTER_SLOTS:
        raise SystemExit(f"{name}: {len(roster)} players, a roster holds {ROSTER_SLOTS}")
    safe = re.sub(r"[^A-Za-z0-9]+", "_", name).strip("_")
    with open(os.path.join(OUT_DIR, f"{cid:06d}_{safe}.json"), "w", encoding="utf-8") as f:
        json.dump({"_comment": "nrl-2027-player-movements (generated)", "rosterList": roster,
                   "lineupTables": tables}, f, indent=1)


def cmd_build(args):
    source = args.source or sorted(glob.glob(os.path.join(SRC_DIR, "zerotackle_*.json")))[-1]
    data = json.load(open(source, encoding="utf-8"))
    world = World()
    moves, unmatched = plan(world, data)
    rosters, retired, dedupe_log = apply(world, moves)
    topup_log = top_up(world, rosters, retired)
    os.makedirs(OUT_DIR, exist_ok=True)
    for f in glob.glob(os.path.join(OUT_DIR, "*.json")):
        if json.load(open(f)).get("_comment", "").startswith("nrl-2027-player-movements"):
            os.remove(f)
    changed = [cid for cid in rosters if cid != PERTH_ID and rosters[cid] != world.rosters.get(cid)]
    twins = stale_twins(world)
    written = 0
    finals = {}
    for cid in changed + [c for c in twins if c not in changed]:
        tables = fix_lineups(world, cid, rosters[cid])
        finals[cid] = (rosters[cid], tables)
        write_override(cid, world.name(cid), rosters[cid], tables)
        written += 1
    for nid, olds in twins.items():
        roster, tables = finals[nid]
        for oid in olds:
            write_override(oid, world.name(oid), roster, tables)
            written += 1
    # Perth Bears: mods/perth-bears owns the record; its squad and lineups go there
    perth = rosters[PERTH_ID]
    perth_path = os.path.join(ROOT, "mods", "perth-bears", "squad.json")
    os.makedirs(os.path.dirname(perth_path), exist_ok=True)
    with open(perth_path, "w", encoding="utf-8") as f:
        json.dump({"_comment": "written by nrl-2027-player-movements/generate.py",
                   "roster": perth, "names": [world.pname(p) for p in perth]}, f, indent=1)
    report(world, source, moves, unmatched, rosters, retired, dedupe_log, topup_log, written)


def report(world, source, moves, unmatched, rosters, retired, dedupe_log, topup_log, written):
    lines = ["# NRL 2027 player movements", "",
             f"Source: `{os.path.relpath(source, ROOT)}` (Zero Tackle). {written} club records written.", "",
             "## Movements applied", ""]
    lines += [f"- {text}" for _pid, _o, _t, _k, text in moves]
    lines += ["", f"## Retired (free agents, off every roster): {len(retired)}", ""]
    lines += [f"- {world.pname(p)}" for p in sorted(retired, key=world.pname)]
    lines += ["", "## Not in the game's database (skipped)", ""]
    lines += [f"- {n}: {why}" for n, why in unmatched] or ["- none"]
    lines += ["", f"## Duplicates removed: {len(dedupe_log)}", ""] + [f"- {x}" for x in dedupe_log]
    lines += ["", f"## Short squads topped up (to {MIN_SQUAD}): {len(topup_log)}", ""] + [f"- {x}" for x in topup_log]
    lines += ["", "## Squad sizes", ""]
    for cid in sorted(c for c in world.active()):
        lines.append(f"- {world.name(cid)}: {len(rosters[cid])}")
    with open(os.path.join(HERE, "movements_report.md"), "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    print(f"{len(moves)} movements, {len(unmatched)} unmatched, {len(retired)} retired, "
          f"{len(dedupe_log)} duplicates removed, {len(topup_log)} top-ups, {written} records")
    for n, why in unmatched:
        print(f"  unmatched: {n} ({why})")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("fetch")
    p = sub.add_parser("build")
    p.add_argument("--source")
    args = ap.parse_args()
    {"fetch": cmd_fetch, "build": cmd_build}[args.cmd](args)


if __name__ == "__main__":
    main()
