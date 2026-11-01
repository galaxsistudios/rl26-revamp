# ai-last-tackle-kick

Source: [mods/ai-last-tackle-kick](../../../mods/ai-last-tackle-kick/) - [README](../../../mods/ai-last-tackle-kick/README.md)

The AI kicks on the last tackle instead of running it, and every AI kick, last-tackle start and handover is logged so we can see where the runs came from.

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/ai/kicking/kickai_mixin.lua](../../../mods/ai-last-tackle-kick/src/script-game/ai/kicking/kickai_mixin.lua) | 141 | 49 | 0 |
| [script-game/ai/playtheball/playtheball_ai.lua](../../../mods/ai-last-tackle-kick/src/script-game/ai/playtheball/playtheball_ai.lua) | 132 | 168 | 7 |

