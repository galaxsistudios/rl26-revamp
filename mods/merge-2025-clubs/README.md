# merge-2025-clubs

RL26 ships most clubs twice: a "2025" club (Brisbane Broncos 2025, ids 1-102, and the women's 32-51) and its
2026 club (Brisbane Broncos, 118-183, women's 184-203). This mod folds each 2025 club into its 2026 club, so
every team appears once with all its kits:

- **Men's clubs:** each 2025 kit the 2026 club doesn't already have is copied onto it as `<NAME> 2025` (e.g.
  `HOME 2025`, `NORTHERN LIGHTS 2025`), right after the club's own kits. Kits are compared by their top /
  shorts / socks design guids, so the 2025 clubs' `HOME 26` / `AWAY 26` (the 2026 kits) and the identical QLD
  Cup, Hull FC and Leigh kits are skipped. 154 kits on 49 clubs.
- **Women's clubs:** the 2026 women's clubs were hidden, unused clones of the 2025 ones (same rosters, the 2025
  designs as HOME/AWAY, a thinner kit schema). The 2025 clubs are the ones players saw, and they carry the
  real 2026 kits as `HOME 26` / `AWAY 2026`. So each 2026 club takes its 2025 club's whole kit list: the 2026
  kits become `HOME` / `AWAY` (and the Home/Away defaults), and the kits they replace plus the rest get
  ` 2025`. HOME and AWAY keep their names where no 2026 version exists (Roosters Women: only a 2026 AWAY). The
  Titans Women's `AWAY 26` stays hidden, as shipped. All 20 women's 2026 clubs are unhidden.
- **2025 clubs** with a 2026 club are hidden (`frontendVisible` 0). Kept, as they have no 2026 club:
  Featherstone Rovers 2025 (91) and Warrington Wolves Women (49).
- **Leagues** (entry 39954):

  | League | Change |
  |---|---|
  | NRL 2025, QLD 2025, SL 2025, Championship 2025, League 1 2025, NRLW, WSL, Challenge Cup (M) | hidden (each has a 2026 version) |
  | NRLW 2026 (21), WSL 2026 (20) | shown, and pointed at the 2026 clubs (they listed the 2025 women's clubs) |
  | Women's Challenge Cup (12), 1895 Cup (15) | pointed at the 2026 clubs (no 2026 version) |

  WSL 2026 gets Big Ant's 2026 line-up, 196-203 (Featherstone Women in, Warrington Women out).

  Shown leagues are re-sorted (`sortIndex`, ascending) to: NRL, NRLW, QLD Cup, NSW Cup, NRL Representative,
  NRLW Representative, Super League, Women's Super League, Championship, Challenge Cup, Women's Challenge Cup,
  1895 Cup, then International and the World Cups; the hidden leagues follow. Their names lose the season
  year ("NATIONAL RUGBY LEAGUE 2026" -> "NATIONAL RUGBY LEAGUE"), and REPRESENTATIVE / REPRESENTATIVE WOMENS
  become NRL REPRESENTATIVE / NRLW REPRESENTATIVE. Competition logos are keyed by tournament, not name.
- **Scripts that hard-coded 2025 club ids** now use the 2026 ones:

  | File | Was | Now |
  |---|---|---|
  | `design/app/online/online_config.lua` | default online women's teams 32 / 33 | 184 / 185 |
  | `app/casual/casual_hub.lua` | Women's 13s tile 1 / 2 | 118 / 119 |
  | `app/academy/academy_helper.lua` | academy featured player wears club 1's home kit | club 118 |
  | `app/homescreen/homescreenstate_config.lua` (**coach-editor's** copy, which already overrides it) | Grand Final tiles 13 v 1, 42 v 32 | 130 v 118, 194 v 184 |

  Left alone: `getClub(1)` fallbacks in `match_aide.lua` / `matchsetup_clubselect_state.lua` (only hit when a
  club is missing; the hidden club still exists) and a debug `testEnter` in `nvm_playerstatisticshud.lua`.

Nothing is deleted: the 2025 clubs and leagues are only hidden, so saves that use them keep working.

## Kit limit (test)

Four clubs end up with more than 20 kits once rll4-legacy-kits' kits are counted: Broncos (21), Cowboys
(21), Titans (21) and Manly (25). Every current club is saved with room for 20, and the engine's editor
treats 20 as its capacity (`uniformCanCreateCount`). The build grows those clubs' kit arrays past 20 and
prints a `WARNING: kit capacity` line for each. **Check in-game** that all of them show (the last ones are the
rll4 `... 2017` kits). If they don't, or a match won't load, the fallback is dropping rll4 kits on those 4
clubs.

## Pieces

| Part | Where | Installed by |
|---|---|---|
| kit moves, 2025 clubs hidden, women's 2026 clubs shown | `defaultdata/defaultdata_clubs/*.json` (generated) | `build.py` (entry 39957) |
| leagues hidden / repointed | `defaultdata/defaultdata_leagues/*.json` (generated) | `build.py` (entry 39954) |
| 2026 club ids in scripts | `src/script-game/...` (+ coach-editor's `homescreenstate_config.lua`) | `build.py` (entry 39959) |

The kit edits use `uniforms` overrides with `from` / `fromClub` / `rename` / `order`, which
[tools/kit_blob.py](../../tools/kit_blob.py) applies (see `apply_spec`). A kit copied between clubs is mapped
field by field onto the target club's kit schema; the build refuses if that would drop a non-default value.

New kit names (`HOME 2025` ...) need [unlock-all-kits](../unlock-all-kits/): the exe drops kits whose name isn't
on its built-in list.

## Build and install (game closed)

```powershell
# 0. regenerate the overrides (only needed if the generator changes) - from STOCK data
python tools\extract_m3mp.py --entry 39957 --out <tmp>\39957
python tools\extract_m3mp.py --entry 39954 --out <tmp>\39954
python mods\merge-2025-clubs\generate.py --clubs <tmp>\39957\defaultdata\defaultdata_clubs --leagues <tmp>\39954\defaultdata\defaultdata_leagues

# 1. clubs (39957) and leagues (39954), from stock extractions
python tools\pack.py restore --entry 39957
python tools\build.py full --list manifests\39957.xml --extracted <tmp>\39957 --out _build\entry_39957.m3mp --confirm
python tools\pack.py restore --entry 39954
python tools\build.py full --list manifests\39954.xml --extracted <tmp>\39954 --out _build\entry_39954.m3mp --confirm

# 2. crowd-team-kits reads the installed clubs, so regenerate it, then the scripts (39959)
python mods\crowd-team-kits\generate.py
python tools\pack.py restore --entry 39959
python tools\build.py full --confirm
```

If the live entries are already modded, `extract_m3mp.py` gives the modded data: decode the stock
`_backup\entry_<N>.blob.bak` instead (see INSTRUCTIONS.md).

Undo: move this folder out of `mods\`, revert coach-editor's four club ids, and rebuild 39957, 39954 and 39959.

## Not changed

- 39954's `NNNNNN.clubdata` files hold a second copy of each club's kit list (byte-identical to the one in
  defaultdata_clubs). rll4-legacy-kits doesn't touch them either and its kits show, so the game reads
  defaultdata_clubs; the copies may be what Academy's "reset to on-disc kits" uses.
- `unhide-nsw-cup-and-womens-clubs` also unhides the 2026 women's clubs; the two agree, so either works alone.
- team-coaches' own coach assignments are keyed by club id, so one made for a 2025 club doesn't follow to its
  2026 club.
