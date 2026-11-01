# fix-touch-referee-cameo

Source: [mods/fix-touch-referee-cameo](../../../mods/fix-touch-referee-cameo/) - [README](../../../mods/fix-touch-referee-cameo/README.md)

When the ball bounces into touch, the stock game blows a short whistle (correct), idles for 1.5 s, and then cuts to a referee cameo. The cameo signals handover (or scrum), which is a second, long whistle. This mod skips the cameo. The player who last touched the ball (the kicker, or whoever carried it out) plays a short "disappointed" reaction cutscene instead.

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/rules/cutscenes/conversion_cutscene_rulestate.lua](../../../mods/fix-touch-referee-cameo/src/script-game/rules/cutscenes/conversion_cutscene_rulestate.lua) | 62 | 38 | 0 |
| [script-game/rules/intouch/intouchoutcomes.lua](../../../mods/fix-touch-referee-cameo/src/script-game/rules/intouch/intouchoutcomes.lua) | 308 | 14 | 1 |
| [script-game/rules/ruleactions/ruleactionhandler.lua](../../../mods/fix-touch-referee-cameo/src/script-game/rules/ruleactions/ruleactionhandler.lua) | 305 | 11 | 0 |

