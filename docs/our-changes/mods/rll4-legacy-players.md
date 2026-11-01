# rll4-legacy-players

Source: [mods/rll4-legacy-players](../../../mods/rll4-legacy-players/) - [README](../../../mods/rll4-legacy-players/README.md)

Adds the Rugby League Live 4 players who had a real face scan in RLL4 but aren't in RL26 (184 of them: Paul Gallen, Boyd Cordner, Andrew Fifita, Gareth Widdop, ...). They become free agents with their RLL4 ratings, roles, birth dates, height and weight, and their RLL4 face scan converted to an RL26 head.

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/design/characters/texturedefinitions.lua](../../../mods/rll4-legacy-players/src/script-game/design/characters/texturedefinitions.lua) | 442 | 257 | 0 |

## Database records

| Database | Patched records | New records |
|---|---:|---:|
| defaultdata_players | 0 | 177 |

## Programs

Generators, installers and exe patchers the mod runs itself (see its README):

- [build.py](../../../mods/rll4-legacy-players/build.py)
- [hair.py](../../../mods/rll4-legacy-players/hair.py)

