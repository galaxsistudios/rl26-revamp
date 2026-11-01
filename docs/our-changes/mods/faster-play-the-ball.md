# faster-play-the-ball

Source: [mods/faster-play-the-ball](../../../mods/faster-play-the-ball/) - [README](../../../mods/faster-play-the-ball/README.md)

Work in progress (core issue #3, slow play-the-ball). AI side first.

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/ai/playtheball/playtheball_action.lua](../../../mods/faster-play-the-ball/src/script-game/ai/playtheball/playtheball_action.lua) | 170 | 101 | 2 |
| [script-game/ai/playtheball/playtheball_helper.lua](../../../mods/faster-play-the-ball/src/script-game/ai/playtheball/playtheball_helper.lua) | 56 | 20 | 0 |
| [script-game/ai/playtheball/quickplaytheballai_mixin.lua](../../../mods/faster-play-the-ball/src/script-game/ai/playtheball/quickplaytheballai_mixin.lua) | 151 | 59 | 3 |
| [script-game/ai/playtheball/quickplaytheballhuman_mixin.lua](../../../mods/faster-play-the-ball/src/script-game/ai/playtheball/quickplaytheballhuman_mixin.lua) | 73 | 130 | 22 |
| [script-game/ai/tackle/tackleddivemonitor_human.lua](../../../mods/faster-play-the-ball/src/script-game/ai/tackle/tackleddivemonitor_human.lua) | 15 | 6 | 0 |
| [script-game/ai/tackle/tackleddragmonitor_human.lua](../../../mods/faster-play-the-ball/src/script-game/ai/tackle/tackleddragmonitor_human.lua) | 24 | 6 | 0 |
| [script-game/ai/tackle/tackleddrivemonitor_human.lua](../../../mods/faster-play-the-ball/src/script-game/ai/tackle/tackleddrivemonitor_human.lua) | 28 | 6 | 0 |
| [script-game/ai/tackle/tackledgetupmonitor_human.lua](../../../mods/faster-play-the-ball/src/script-game/ai/tackle/tackledgetupmonitor_human.lua) | 118 | 8 | 0 |
| [script-game/ai/tackle/tackledholdmonitor_human.lua](../../../mods/faster-play-the-ball/src/script-game/ai/tackle/tackledholdmonitor_human.lua) | 15 | 6 | 0 |
| [script-game/design/input/default_input_actions.lua](../../../mods/faster-play-the-ball/src/script-game/design/input/default_input_actions.lua) | 574 | 6 | 0 |

