# bunker-overturned-try

Source: [mods/bunker-overturned-try](../../../mods/bunker-overturned-try/) - [README](../../../mods/bunker-overturned-try/README.md)

Try attempts that the stock game rules out are awarded on the field first, then overturned by the bunker. The flow:

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/app/noesis/hud/nvm_scorecard.lua](../../../mods/bunker-overturned-try/src/script-game/app/noesis/hud/nvm_scorecard.lua) | 212 | 81 | 1 |
| [script-game/listeners/replay/replay_listener.lua](../../../mods/bunker-overturned-try/src/script-game/listeners/replay/replay_listener.lua) | 564 | 370 | 13 |
| [script-game/rendering/props/propfactory.lua](../../../mods/bunker-overturned-try/src/script-game/rendering/props/propfactory.lua) | 213 | 2 | 1 |
| [script-game/rules/cameo/refereecameo_rulestate.lua](../../../mods/bunker-overturned-try/src/script-game/rules/cameo/refereecameo_rulestate.lua) | 203 | 337 | 2 |
| [script-game/rules/cutscenes/trydecisionpending_rulestate.lua](../../../mods/bunker-overturned-try/src/script-game/rules/cutscenes/trydecisionpending_rulestate.lua) | 119 | 480 | 3 |
| [script-game/rules/match/generalgameplay_rulestate.lua](../../../mods/bunker-overturned-try/src/script-game/rules/match/generalgameplay_rulestate.lua) | 960 | 96 | 1 |
| [script-game/rules/tackle/tackleoutcomes.lua](../../../mods/bunker-overturned-try/src/script-game/rules/tackle/tackleoutcomes.lua) | 339 | 134 | 1 |
| [script-game/rules/try/tryattemptoutcomes.lua](../../../mods/bunker-overturned-try/src/script-game/rules/try/tryattemptoutcomes.lua) | 164 | 188 | 0 |
| [script-game/rules/try/tryscored_request.lua](../../../mods/bunker-overturned-try/src/script-game/rules/try/tryscored_request.lua) | 175 | 44 | 4 |

