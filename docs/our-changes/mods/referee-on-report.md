# referee-on-report

Source: [mods/referee-on-report](../../../mods/referee-on-report/) - [README](../../../mods/referee-on-report/README.md)

High tackle penalties get the referee's close-ups before the penalty choice, and **30%** of them put the offender on report:

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/ai/officials/refereesignal_action.lua](../../../mods/referee-on-report/src/script-game/ai/officials/refereesignal_action.lua) | 101 | 123 | 3 |
| [script-game/rules/penalty/penalty.lua](../../../mods/referee-on-report/src/script-game/rules/penalty/penalty.lua) | 234 | 145 | 0 |
| [script-game/rules/tackle/tackle_detect.lua](../../../mods/referee-on-report/src/script-game/rules/tackle/tackle_detect.lua) | 779 | 35 | 3 |
| [script-game/sim/hud/gameplayscore_hud.lua](../../../mods/referee-on-report/src/script-game/sim/hud/gameplayscore_hud.lua) | 547 | 658 | 1 |

