# fix-field-goal-referee-call

Source: [mods/fix-field-goal-referee-call](../../../mods/fix-field-goal-referee-call/) - [README](../../../mods/fix-field-goal-referee-call/README.md)

Stops the referee from blowing two whistles and shouting "Try!" after a successful field goal. He now blows one whistle and, if the `sfx_ref_field_goal` bank is installed, calls "Field goal".

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/rules/scoring/reacttoscore_rulestate.lua](../../../mods/fix-field-goal-referee-call/src/script-game/rules/scoring/reacttoscore_rulestate.lua) | 314 | 9 | 4 |
| [script-game/simlisteners/sound/listeners/soundlistener_referee.lua](../../../mods/fix-field-goal-referee-call/src/script-game/simlisteners/sound/listeners/soundlistener_referee.lua) | 356 | 58 | 0 |

