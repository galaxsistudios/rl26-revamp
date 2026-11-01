# team-coaches

Source: [mods/team-coaches](../../../mods/team-coaches/) - [README](../../../mods/team-coaches/README.md)

Gives clubs a head coach who wears a polo in the club's colour, and (pilot) puts both coaches on the sideline during matches. Planned later: reaction close-ups of the coach for penalties, 40/20s and the occasional try.

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/app/club/club_viewstate_identity_state.lua](../../../mods/team-coaches/src/script-game/app/club/club_viewstate_identity_state.lua) | 678 | 206 | 1 |
| [script-game/design/characters/blendshapes.lua](../../../mods/team-coaches/src/script-game/design/characters/blendshapes.lua) | 702 | 65 | 0 |
| [script-game/game/cheerleader/cheerleader_helper.lua](../../../mods/team-coaches/src/script-game/game/cheerleader/cheerleader_helper.lua) | 75 | 16 | 0 |
| [script-game/game/coach/coach_helper.lua](../../../mods/team-coaches/src/script-game/game/coach/coach_helper.lua) | 19 | 1395 | 0 |
| [script-game/intermediatelua/cutscenes/data/cs_conversion_data.lua](../../../mods/team-coaches/src/script-game/intermediatelua/cutscenes/data/cs_conversion_data.lua) | 5321 | 46 | 0 |
| [script-game/rules/cutscenes/cheerleadercelebrate_rulestate.lua](../../../mods/team-coaches/src/script-game/rules/cutscenes/cheerleadercelebrate_rulestate.lua) | 106 | 171 | 0 |

## Database records

| Database | Patched records | New records |
|---|---:|---:|
| defaultdata_npcs | 0 | 77 |

## Programs

Generators, installers and exe patchers the mod runs itself (see its README):

- [build_polos.py](../../../mods/team-coaches/build_polos.py)
- [coach_look.py](../../../mods/team-coaches/coach_look.py)
- [make_coach_records.py](../../../mods/team-coaches/make_coach_records.py)

