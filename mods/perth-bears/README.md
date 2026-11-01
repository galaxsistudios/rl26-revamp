# perth-bears

The Perth Bears join the NRL as its 18th club (2027) in the main **NATIONAL RUGBY LEAGUE**. Career mode keeps a hidden 17-club NRL (see below).

| Part | What | Entry |
|---|---|---|
| `defaultdata/defaultdata_clubs/000220_Perth_Bears.json` | New club 220 (data_mods `"cloneOf"`; needs the `club-slots-224` exe patch): a copy of the Dolphins (134) with Perth's names, the `nrl_bears` icon (new-club-icons), red / black, the North Sydney Bears' commentary mascot ("Bears", no location line), **HBF Park** (`perthRectangularStadium`, 29) and **North Sydney Oval** (65) as home grounds (HBF Park for finals), the North Sydney Bears' kits, and the squad from `squad.json` (29 signings from the movements tracker) | licenseddata |
| `defaultdata/defaultdata_leagues/000001_NRL_main_perth.json` | League 1 (the stock hidden NRL 2025) becomes the visible **NATIONAL RUGBY LEAGUE**, sorted first: the 17 clubs + 220 | gamedata |
| `defaultdata/defaultdata_leagues/000018_NRL_2026_career.json` | League 18 becomes the hidden **NATIONAL RUGBY LEAGUE 2026** with the stock 17 clubs. Career and Dynasty load it (`AcademyLeagues.League_NRL2026`, fixed in the exe) | gamedata |

## Why id 220 needs an exe patch

The stock game holds on-disc clubs 0-219 only, and stock uses all of them. The first install of Perth at 220
crashed at boot: the native club loader only sets up 220 slots. `mods/club-slots-224` patches the exe to 224
slots. Without it, a club has to take over an existing id (data_mods `"replaces"`; Perth was briefly 113).

## Career mode (out for now)

Career builds its NRL from **league 18's** club list, not from careerdata, which is why Perth turned up in career
even before there was any career data for it. Career can't hold an 18th NRL club:

- **204 matches per competition season.** The stock 17-team draw is exactly 204 (fixture parser pool; see The draw).
- **46 clubs in career's club-list type.** It's a fixed-size list built into career objects and copied in 52 places
  in the exe. The end-of-season pass (player allocation) joins NRL + QLD Cup + Super League = 17 + 15 + 14 = 46 in
  stock, so Perth as the 47th overflowed it and crashed at the end of year 1.

So the leagues swap roles: league 18 (the one career loads) is a hidden stock "NRL 2026", and league 1 is the visible NRL with Perth. Competition mode runs on the career engine (`CareerCompetitionIdEnum.League_NRL`), so Perth isn't in competition mode either until the career limits are solved. `generate.py --career` still
writes the 18-team career data (`career/`, a 198-match draw) for when the 46-club list is solved. The career-revamp
audit of those lists is under way. `src/.../careernews.lua` keeps a guard: when the coached club has no ladder entry
(for example the pre-season trials draw), it logs to `careerladder_debug.txt` and skips that round report instead of
crashing.

## The draw

The 2026 draw (`career_nrl_fixture_season`): u8 4, u32 1, u32 rounds, then per round a u32 match count and
11-byte matches `u16 home, u16 away (indexes into the NRL list), u8 venue (2 = home ground, 20 = Las Vegas, other
stadium ids for neutral games), u16 year, u8 month, day, hour, minute`.

**Career holds at most 204 matches per competition season.** That's the stock 17-team draw exactly (17 x 24 / 2),
and the exe has about 50 hard-coded 204s in its career code, some of them save format. A draw with Perth added to
the stock rounds (216 matches) crashed career creation: the fixture parser's 204-match pool ran out. So
`generate.py` writes a new draw: an 18-team round robin plus 5 return rounds, 22 rounds of 9 = **198 matches,
22 games per club, no byes**, on the stock round dates minus 5 Origin weekends (stock rounds 12, 13, 15, 16, 18).
Magic Round keeps Suncorp for all 9 games, and the Las Vegas slots stay in Las Vegas. Other neutral-ground games
became home games, because they belonged to stock pairings. `perth_draw.txt` lists it.

## Stadium ids

`native.EStadiums` isn't in the Lua. The values were matched from the clubs' home grounds (Belmore 7,
Brookvale 8, Robina 31, Accor 35, CommBank 37, Wollongong 40, ...), which run in the order of the exe's
`MatchSettings_Ground_*` strings: perthRectangularStadium 29, perthStadium 30. North Sydney Oval is 65, the North
Sydney Bears' home ground.

## Build and install

```powershell
python mods\nrl-2027-player-movements\generate.py build   # writes squad.json
python mods\perth-bears\generate.py                       # --career also needs _build\stock\careerdata
```

Then rebuild **licenseddata** and **gamedata** (and **careerdata** with `--career`) from stock extractions. Then run the crowd chain: `default_flags.py nrl_bears`, `fangear.py designs nrl_bears`,
then bake / variants / install / register / `crowd-team-kits\generate.py`. Then rebuild scripts.

## Untested / to check in-game

- Perth in Quick Match and NRL competitions, with the 2027 home kit.
- Boot with the club-slots-224 patch (see its README).
