# Databases

## Format

`defaultdata_players`, `_clubs`, `_leagues` and `_npcs` are Big Ant's self-describing record databases (the same
format as RLL4's). [tools/bigant_db.py](../../tools/bigant_db.py) reads and writes them exactly
(`dump(load(x)) == x`):

```
u8 version (RL26 16), u8 table count
per table:  u8 id, u8-len name, u32 field count, fields (u8 type, u8-len name, u8-len category)
u32 record count
per record: u32 80085 tag
            players/npcs: u32 visual size + visual blob (BC ED 34 12), then the tables
            clubs/leagues: the tables, then (clubs) u32 size + kit list blob
            tables: u8 present, then per field u8 present + value
```

Field types: 1 u8, 2/3/5/7 u32 (int, enum, hash), 4 u8-length latin-1 string, 6 RGB stored as an int
`R | G << 8 | B << 16`, 8 a five-byte lineup slot. An absent field takes the design default. Most edits
that change a record's size (adding roster players or kits, renaming) go through this exact writer.
The older heuristic readers (`parse_*.py`) still work for in-place patches but miss about 70 player records.

## Players

Table `players`: identity (names, birth date, country, Origin and rep eligibility), `preferredRolePrimary`/
`Secondary`/`Tertiary`, body (height, weight, head, hair), and skills (tackle, sprintSpeed, the kicking skills,
fend, ...). Two more tables hold career stats. **Club membership is not a player field.** A player belongs to
whichever club's roster lists them, and a player on no roster is a free agent. The game aborts at boot if a player
id is far past the record count. Ids up to about count + 180 work.

## Clubs

| Table | Contents |
|---|---|
| `clubList` | id, names (full, short, nickname, hud, shirt), `frontendVisible`, sex, `icon` (logo name), colours, supporters, commentary location/mascot hashes, `clubType` (rep sides), home grounds (`native.EStadiums` ids), feeder clubs, numbering |
| `roster` | `player1`..`player64`: the squad |
| `LeagueMatch`, `NinesMatch`, `NRL2026Match` | lineups: captain, goal kicker, playmakers and one slot per position. 13s slots pack `(position tag << 32) | player id` |
| (blob) | the kit list: a schema of FNV-hashed fields, then fixed-size kit records (name, design guids `uniformTop/Bottom/Socks`, number colours, ...) and per-category defaults. See `tools/kit_blob.py` |

RL26 ships most clubs twice: "2025" records (ids 1-102, hidden by our merge mod) and 2026 records (118-203).
**Career mode still uses the 2025 records** (see [career-and-competitions.md](career-and-competitions.md)).
Each kit is a set of design guids that map to models and textures in `design/characters/assetmapitems.lua`.
Which kits a club shows is decided natively by kit name (see [native-exe.md](native-exe.md)). A club holds at
most 20 kits inline.

## Leagues

One `identity` table: name, short name, `sex`, `sort index` (menu order), and `clubs` … `clubs[34]` (up to 35
member clubs). Quick Match's team select reads these; career mode doesn't.

## NPCs (referees and coaches)

`defaultdata_npcs` (in `gamedata`): the same scheme, with the visual blob before the record. `npcType` is
Referee 0, Coach 1, Hidden 2. Stock ships every coach as Hidden, and no retail screen edits coaches. The NPC
manager's `getRelativeNPCIdOfType` aborts natively when no NPC matches.

## Saves and edited official data

Saves (`Saved Games/Rugby League 26/*.SAV`) are encrypted. Edits to official players and clubs don't go to the
user-created store. They go to native "custom licensed" dictionaries (`saveCustomLicensed`,
`resetCustomLicensedPlayer`). The raw on-disc club stays readable through `clubManager.onDiscDatabase`.
