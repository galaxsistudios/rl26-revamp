# early-defensive-retreat

Source: [mods/early-defensive-retreat](../../../mods/early-defensive-retreat/) - [README](../../../mods/early-defensive-retreat/README.md)

Defensive lines start getting back 10 m as soon as a tackle is certain, instead of waiting for the hold-down / "held" call. The human "double-tap left trigger to retreat" control works again.

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/ai/generalgameplay/defendingcontrolledroam_human.lua](../../../mods/early-defensive-retreat/src/script-game/ai/generalgameplay/defendingcontrolledroam_human.lua) | 117 | 6 | 0 |
| [script-game/ai/playtheball/getonside_ai.lua](../../../mods/early-defensive-retreat/src/script-game/ai/playtheball/getonside_ai.lua) | 102 | 3 | 1 |
| [script-game/ai/playtheball/quickdefensiveonside_ai.lua](../../../mods/early-defensive-retreat/src/script-game/ai/playtheball/quickdefensiveonside_ai.lua) | 105 | 21 | 2 |
| [script-game/ai/playtheball/quickdefensiveplaytheballhuman_mixin.lua](../../../mods/early-defensive-retreat/src/script-game/ai/playtheball/quickdefensiveplaytheballhuman_mixin.lua) | 46 | 10 | 8 |
| [script-game/ai/tackle/tacklecollapsemonitor_human.lua](../../../mods/early-defensive-retreat/src/script-game/ai/tackle/tacklecollapsemonitor_human.lua) | 28 | 6 | 0 |
| [script-game/ai/tackle/tacklecontactmonitor_human.lua](../../../mods/early-defensive-retreat/src/script-game/ai/tackle/tacklecontactmonitor_human.lua) | 28 | 6 | 0 |
| [script-game/ai/tackle/tackledivemonitor_human.lua](../../../mods/early-defensive-retreat/src/script-game/ai/tackle/tackledivemonitor_human.lua) | 15 | 6 | 0 |
| [script-game/ai/tackle/tackledragmonitor_human.lua](../../../mods/early-defensive-retreat/src/script-game/ai/tackle/tackledragmonitor_human.lua) | 28 | 6 | 0 |
| [script-game/ai/tackle/tackledrivemonitor_human.lua](../../../mods/early-defensive-retreat/src/script-game/ai/tackle/tackledrivemonitor_human.lua) | 24 | 6 | 0 |
| [script-game/ai/tackle/tackleholdmonitor_human.lua](../../../mods/early-defensive-retreat/src/script-game/ai/tackle/tackleholdmonitor_human.lua) | 30 | 6 | 0 |
| [script-game/ai/tackle/tacklestandingreleasemonitor_human.lua](../../../mods/early-defensive-retreat/src/script-game/ai/tackle/tacklestandingreleasemonitor_human.lua) | 24 | 6 | 0 |
| [script-game/rules/playtheball/playtheball_listener.lua](../../../mods/early-defensive-retreat/src/script-game/rules/playtheball/playtheball_listener.lua) | 178 | 86 | 1 |

