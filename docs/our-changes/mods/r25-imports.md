# r25-imports

Source: [mods/r25-imports](../../../mods/r25-imports/) - [README](../../../mods/r25-imports/README.md)

> **Release: NOT part of the RL26 Revamp release.** This is the optional **Rugby 25 Expansion**: > leave this mod (and the entries `r25_import.py` appends) out of the main Revamp package. Ship it > separately, for players who own Rugby 25. Its assets are generated on the player's machine from > their own Rugby 25 install by `tools/r25_import.py`; no Rugby 25 data is redistributed. `imports.json` > carries `"releaseChannel": "r25-expansion"` so packaging can filter it. Any future R25-derived > content (e.g. the tackle pilot) belongs in this expansion too.

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/game/characteranimation/playeranimationset.lua](../../../mods/r25-imports/src/script-game/game/characteranimation/playeranimationset.lua) | 173 | 2 | 0 |
| [script-game/game/scoring/score_request.lua](../../../mods/r25-imports/src/script-game/game/scoring/score_request.lua) | 65 | 10 | 0 |
| [script-game/intermediatelua/animations/emotiongroups.lua](../../../mods/r25-imports/src/script-game/intermediatelua/animations/emotiongroups.lua) | 832 | 225 | 0 |
| [script-game/intermediatelua/cutscenes/data/cs_test_cutscene_data.lua](../../../mods/r25-imports/src/script-game/intermediatelua/cutscenes/data/cs_test_cutscene_data.lua) | 1001 | 14842 | 0 |
| [script-game/intermediatelua/cutscenes/data/cutscenedata_config.lua](../../../mods/r25-imports/src/script-game/intermediatelua/cutscenes/data/cutscenedata_config.lua) | 172 | 232 | 0 |
| [script-game/rules/conversion/conversionkick_setup_rulestate.lua](../../../mods/r25-imports/src/script-game/rules/conversion/conversionkick_setup_rulestate.lua) | 51 | 60 | 1 |
| [script-game/rules/fortytwenty/fortytwentyvariation_request.lua](../../../mods/r25-imports/src/script-game/rules/fortytwenty/fortytwentyvariation_request.lua) | 43 | 14 | 0 |
| [script-game/rules/idleplayers/idleallplayers_rulestate.lua](../../../mods/r25-imports/src/script-game/rules/idleplayers/idleallplayers_rulestate.lua) | 122 | 106 | 0 |
| [script-game/rules/penalty/penaltyselect_setup_rulestate.lua](../../../mods/r25-imports/src/script-game/rules/penalty/penaltyselect_setup_rulestate.lua) | 65 | 140 | 0 |

