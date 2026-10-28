#!/usr/bin/env python3
"""
stats_sync.py - refresh the rl26-revamped-stats submodule (teams.json,
players.json) from in-game exports made with mods/player-import-export.

The save files themselves (Saved Games/Rugby League 26/**/*.SAV) can't be read
offline: after the 16-byte CDABCDAB header the body is encrypted (entropy
~7.9 bits/byte, no zlib/zstd stream). The game decrypts them itself, so the
export mod dumps what is loaded, Academy edits included:
    Players submenu > Export Players > All Players  -> Players_All_<n>_<date>.json
    Clubs submenu   > Export Teams   > All Teams    -> Teams_All_<n>_<date>.json
                                       (or Base Game Teams -> Teams_BaseGame_...)

players.json keeps the RL26PlayersExport format, so Import Players reads it
back. teams.json keeps the teams only: their players are already in
players.json, and roster / lineups refer to them by id. Both are sorted by id
with one record per line, so a git diff shows which records changed.

version.json holds each file's SHA-256 and chunk count. Both files are also
split into players/NNN.json and teams/NNN.json (256 KB each, same format):
mods/revamp-stats-sync fetches version.json when the game reaches the home
screen and downloads the chunks of a file whose hash differs from the one it
last applied (the game crashes on a single multi-megabyte response).

Usage: python tools\\stats_sync.py --version-only rebuilds just version.json and
the chunks from the files already in the repo.

Usage:
    python tools\\stats_sync.py                       # newest exports in Documents
    python tools\\stats_sync.py --players X.json --teams Y.json
"""

import argparse
import glob
import hashlib
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
STATS_DIR = os.path.join(ROOT, "rl26-revamped-stats")
DOCUMENTS = os.path.join(os.path.expanduser("~"), "Documents")
# Records per chunk, about 250 KB a chunk (players ~6.6 KB each).
CHUNK_RECORDS = {"players": 40, "teams": 40}
# Team chunks carry only what revamp-stats-sync applies: kit designs and home
# grounds (most of teams.json, up to 155 KB a club) stay in teams.json only.
CHUNK_FIELDS = {"teams": ["id", "name", "sex", "baseGame", "academyId", "identity", "emblem", "coachId",
                          "uniformDefaults", "roster", "lineups"]}
MAX_CHUNK_BYTES = 400 * 1024
# The appearance options revamp-stats-sync applies to scanned (tier-1)
# players: headgear and hair. Same list as StatsSyncTier1Appearance in the mod.
TIER1_APPEARANCE = (
    ["helmet"]
    + [f"headwearColour{i}_{c}" for i in range(1, 5) for c in "rgb"]
    + [f"headStrappingColour{i}_{c}" for i in range(1, 3) for c in "rgb"]
    + ["hair", "hairTop", "hairSide", "hairSide2", "hairTexture_cap", "hairTipsOption", "hairColour1", "hairColour2"]
)


def newest(pattern):
    paths = glob.glob(os.path.join(DOCUMENTS, pattern))
    return max(paths, key=os.path.getmtime) if paths else None


def load(path, fmt):
    with open(path, encoding="utf-8") as f:
        data = json.load(f)
    if data.get("format") != fmt:
        sys.exit(f"{path}: expected format {fmt}, got {data.get('format')!r}")
    return data


def write_records(path, header, key, records):
    """header fields pretty-printed, then `key` as a list with one compact record per line."""
    records = sorted(records, key=lambda r: r["id"])
    lines = ["{"]
    for k, v in header.items():
        lines.append(f"  {json.dumps(k)}: {json.dumps(v, ensure_ascii=False)},")
    lines.append(f"  {json.dumps(key)}: [")
    for i, r in enumerate(records):
        sep = "," if i < len(records) - 1 else ""
        lines.append("    " + json.dumps(r, ensure_ascii=False, separators=(",", ":")) + sep)
    lines.append("  ]")
    lines.append("}")
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(lines) + "\n")
    print(f"wrote {path}: {len(records)} {key} ({os.path.getsize(path) / 1e6:.1f} MB)")


def sync_players(src):
    data = load(src, "RL26PlayersExport")
    header = {k: data[k] for k in ("format", "version", "game", "exportedAt")}
    header["source"] = os.path.basename(src)
    header["count"] = len(data["players"])
    write_records(os.path.join(STATS_DIR, "players.json"), header, "players", data["players"])


def sync_teams(src):
    data = load(src, "RL26TeamsExport")
    header = {k: data[k] for k in ("format", "version", "game", "exportedAt") if k in data}
    header["source"] = os.path.basename(src)
    header["count"] = len(data["teams"])
    write_records(os.path.join(STATS_DIR, "teams.json"), header, "teams", data["teams"])


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--players", help="Players export (default: newest Documents/Players_All_*.json)")
    ap.add_argument("--teams", help="Teams export (default: newest Documents/Teams_All_*.json, "
                                    "else Teams_BaseGame_*.json)")
    ap.add_argument("--version-only", action="store_true",
                    help="only rebuild version.json and the chunks from the repo's players.json / teams.json")
    args = ap.parse_args()

    if args.version_only:
        write_version()
        return

    players = args.players or newest("Players_All_*.json")
    # Base Game Teams is every on-disc club (edits included); All adds Academy-made clubs.
    teams = args.teams or newest("Teams_All_*.json") or newest("Teams_BaseGame_*.json")
    if not players and not teams:
        sys.exit(f"no Players_All_*.json or Teams_All_*.json in {DOCUMENTS}")
    if players:
        sync_players(players)
    else:
        print("no players export found, players.json left as is")
    if teams:
        sync_teams(teams)
    else:
        print("no teams export found, teams.json left as is")
    write_version()


def tier1_slim(record):
    """A tier-1 player's chunk entry: everything but appearance, plus the
    hair/headgear appearance options (the scan drives the rest of the look)."""
    out = {k: v for k, v in record.items() if k != "appearance"}
    appearance = record.get("appearance") or {}
    out["appearance"] = {k: appearance[k] for k in TIER1_APPEARANCE if k in appearance}
    return out


def write_chunks(name, data):
    """Splits data[name] (sorted by id) into <name>/NNN.json files of
    CHUNK_RECORDS[name] records each. Returns [(sha256, bytes)] per chunk.

    The game can't take a big HTTP response: a 27 MB players.json corrupted
    its native heap and crashed it (2026-10-28), so revamp-stats-sync only
    downloads these chunks (about 250 KB each). They are cut by record count
    and hold nothing but their records, so editing one player changes one
    chunk: the game keeps each chunk's hash and only downloads changed ones.
    """
    folder = os.path.join(STATS_DIR, name)
    os.makedirs(folder, exist_ok=True)
    for old in glob.glob(os.path.join(folder, "*.json")):
        os.remove(old)
    header = {k: data[k] for k in ("format", "version") if k in data}
    records = sorted(data[name], key=lambda r: r["id"])
    fields = CHUNK_FIELDS.get(name)
    if fields:
        records = [{k: r[k] for k in fields if k in r} for r in records]
    if name == "players":
        # A scanned (tier-1) player only gets hair and headgear from the sync.
        records = [tier1_slim(r) if r.get("tier1") else r for r in records]
    size = CHUNK_RECORDS[name]
    chunks = []
    for index in range(0, len(records), size):
        lines = [json.dumps(r, ensure_ascii=False, separators=(",", ":")) for r in records[index:index + size]]
        out = ["{"]
        for k, v in header.items():
            out.append(f"  {json.dumps(k)}: {json.dumps(v, ensure_ascii=False)},")
        out.append(f"  {json.dumps(name)}: [")
        out.append(",\n".join("    " + line for line in lines))
        out.append("  ]")
        out.append("}")
        raw = ("\n".join(out) + "\n").encode("utf-8")
        with open(os.path.join(folder, f"{len(chunks):03d}.json"), "wb") as f:
            f.write(raw)
        chunks.append((hashlib.sha256(raw).hexdigest(), len(raw)))
    largest = max(b for _, b in chunks) if chunks else 0
    print(f"wrote {folder}: {len(chunks)} chunks, largest {largest / 1024:.0f} KB")
    if largest > MAX_CHUNK_BYTES:
        sys.exit(f"{name}: a chunk is {largest} bytes, over {MAX_CHUNK_BYTES}; lower CHUNK_RECORDS[{name!r}]")
    return chunks


def write_version():
    version = {"format": "RL26RevampStatsVersion", "version": 1}
    for name in ("players", "teams"):
        path = os.path.join(STATS_DIR, name + ".json")
        with open(path, "rb") as f:
            raw = f.read()
        entry = {"sha256": hashlib.sha256(raw).hexdigest(), "bytes": len(raw)}
        try:
            data = json.loads(raw)
            entry["exportedAt"] = data["exportedAt"]
            entry["count"] = data["count"]
            chunks = write_chunks(name, data)
            # The version hash covers the chunks too, so a change in what they
            # carry (e.g. tier-1 hair/headgear added) counts as a new version.
            entry["sha256"] = hashlib.sha256(raw + "".join(sha for sha, _ in chunks).encode()).hexdigest()
            entry["parts"] = len(chunks)
            entry["chunks"] = [sha for sha, _ in chunks]
            entry["chunkBytes"] = [size for _, size in chunks]
        except (ValueError, KeyError, TypeError):
            pass  # still the empty placeholder
        version[name] = entry
    path = os.path.join(STATS_DIR, "version.json")
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        json.dump(version, f, indent=2)
        f.write("\n")
    print(f"wrote {path}")


if __name__ == "__main__":
    main()
