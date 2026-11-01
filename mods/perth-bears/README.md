# perth-bears

The Perth Bears join the NRL as its 18th club (2027): Quick Match / competition team lists and career mode.

| Part | What | Entry |
|---|---|---|
| `defaultdata/defaultdata_clubs/000220_Perth_Bears.json` | New club 220 (data_mods `"cloneOf"`): a copy of the Dolphins (134) with Perth's names, the `nrl_bears` icon (new-club-icons), red / black, the North Sydney Bears' commentary mascot ("Bears", no location line), **HBF Park** (`perthRectangularStadium`, 29) and **North Sydney Oval** (65) as home grounds (HBF Park for finals), the North Sydney Bears' kits, and the squad from `squad.json` (29 signings from the movements tracker) | licenseddata |
| `defaultdata/defaultdata_leagues/000018_NRL_2026_perth.json` | The NRL 2026 league lists club 220 | gamedata |
| `career/career_leaguestructure` | Career NRL club list 1-17 + 220 | careerdata |
| `career/career_clubs_domestic` | Perth's career settings record (87 bytes, a copy of the Dolphins') | careerdata |
| `career/career_nrl_fixture_season` | The NRL draw with Perth's 24 games ([perth_draw.txt](perth_draw.txt)) | careerdata |

## The draw

The 2026 draw (`career_nrl_fixture_season`): u8 4, u32 1, u32 rounds, then per round a u32 match count and
11-byte matches `u16 home, u16 away (indexes into the NRL list), u8 venue (2 = home ground, 20 = Las Vegas...),
u16 year, u8 month, day, hour, minute`. With 17 teams, every round has one bye, except the Origin rounds: 3 byes in
rounds 13, 16 and 19, and 7 in 12, 15 and 18. Perth plays the bye team in each one-bye round and one of the three
in rounds 13/16/19, and has its own byes in 12/15/18. That gives Perth 24 games and 3 byes like every other club,
which get 24-26 games. Perth's games go on the round's last day, at a time no other game has.

## Stadium ids

`native.EStadiums` isn't in the Lua. The values were matched from the clubs' home grounds (Belmore 7,
Brookvale 8, Robina 31, Accor 35, CommBank 37, Wollongong 40, ...), which run in the order of the exe's
`MatchSettings_Ground_*` strings: perthRectangularStadium 29, perthStadium 30. North Sydney Oval is 65, the North
Sydney Bears' home ground.

## Build and install

```powershell
python mods\nrl-2027-player-movements\generate.py build   # writes squad.json
python mods\perth-bears\generate.py                       # needs _build\stock\careerdata (install_revamp's stock step)
```

Then rebuild **licenseddata**, **gamedata** and **careerdata** from stock extractions (careerdata is now one of
install_revamp's bundles). Then run the crowd chain: `default_flags.py nrl_bears`, `fangear.py designs nrl_bears`,
then bake / variants / install / register / `crowd-team-kits\generate.py`. Then rebuild scripts.

## Untested / to check in-game

- **Career start with 18 NRL clubs** is the riskiest part (native career code). If career won't start, move
  `career/` out of the mod and rebuild careerdata (the club then still exists for Quick Match).
- Kits are the North Sydney Bears' until Perth has its own.
- Club id 220 sits one past the last record, the same rule that keeps new player ids safe.
