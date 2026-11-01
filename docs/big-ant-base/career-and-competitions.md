# Career and competition data

## The careerdata bundle

`careerdata` holds about 58 binary files under `career/`: one league structure, a fixture file per competition
(`career_<comp>_fixture_season`, `_trials`, World Cup pools), career club settings, and tuning (salary caps,
sponsors, boosts, training, morale, form, retirement, recruiting, transfers, start dates).

### `career_leaguestructure`

One record per competition (26): an internal name (`NRL`, `SuperLeague`, `SuperLeague2026`, `QLDCup`,
`NSWCup`, `RLWC2026Men`, ...), a localisation key, settings, a display name, then `u32 count, count × u32 club
id`. **The club ids are the "2025" club records.** NRL is 1-17, Super League 20-31, QLD Cup 52-66, NSW Cup 67-79,
Championship 80-92, and Super League 2026 is 20-30 plus 84/82/87. So career mode plays with the 2025 squads and
kits, whatever the Quick Match lists show.

### `career_clubs_domestic`

`u8 5, u32 n`, then n × 87-byte records: `u32 club id`, a 32-byte name, then the club's career settings (budget
and sponsor ids). It has records for both the 2025 (1-102) and 2026 (118-183) clubs.

### Fixture files

```
u8 4, u32 1, u32 rounds
per round: u32 n, n × <HHBHBBBB>  home, away, venue, year, month, day, hour, minute
```

`home`/`away` index into the competition's club list. Venue 2 means the home team's ground; other values are
specific grounds (20 = Las Vegas). The 2026 NRL draw is the real one: 27 rounds, 17 teams, 24 games and 3 byes
each. Every round has one bye, except Origin rounds 13/16/19 (3 byes) and 12/15/18 (7 byes).

## Competition hub

Career and standalone competitions share `app/competition/competition_hub.lua`: one tab per fixture, a ladder tab
where the fixture has one, and stats. Ladder data comes from `competition:getLadder(native.CareerLadder(),
fixtureIndex)` and `getLadderConfig`. The career home screen has its own mini-ladder.

## Stadium ids

Clubs' home grounds and venues use `native.EStadiums`, which no Lua lists. Matching clubs' known grounds against
the exe's `MatchSettings_Ground_*` string order gives (partial):

| Id | Ground | Id | Ground |
|---:|---|---:|---|
| 5 | moorePark (Allianz) | 24 | redcliffeStadium |
| 6 | brisbane (Suncorp) | 25 | mtSmartStadium |
| 7 | belmoreSportsGround | 26 | townsvilleStadium |
| 8 | brookvaleOval | 29 | perthRectangularStadium (HBF Park) |
| 9 | campbelltownSportsStadium | 30 | perthStadium (Optus) |
| 10 | canberraStadium | 31 | robinaStadium |
| 12 | endeavourField | 34 | perpignanStadium |
| 15 | hunterStadium | 35 | stadiumAustralia (Accor) |
| 18 | kogarahOval | 37 | parramattaStadium (CommBank) |
| 20 | lasVegasStadium | 40 | wollongongShowground |
| 23 | melbourneRectangularStadium | 65 | northSydneyOval |

`intermediatelua/convant/stadiums.lua` holds menu order (`StadiumUIOrder`), the public-facing list and random-map
validity, but not the ids.
