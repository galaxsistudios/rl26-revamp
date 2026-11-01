# reduce-ai-dummy-half-scoots

Source: [mods/reduce-ai-dummy-half-scoots](../../../mods/reduce-ai-dummy-half-scoots/) - [README](../../../mods/reduce-ai-dummy-half-scoots/README.md)

**2026-11-01 situational scoot chance** (`hitgap_ai.lua`, `situationalScootChance`): 6 % base times each factor that applies, capped at 50 %. Every decision logs its factors, e.g. `chance=0.18 [nearLine*3.00 speed1.05*1.25] -> veto`.

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/ai/collect/dummyhalfcollectball_ai.lua](../../../mods/reduce-ai-dummy-half-scoots/src/script-game/ai/collect/dummyhalfcollectball_ai.lua) | 42 | 176 | 0 |
| [script-game/ai/collect/dummyhalfcollectmonitor_ai.lua](../../../mods/reduce-ai-dummy-half-scoots/src/script-game/ai/collect/dummyhalfcollectmonitor_ai.lua) | 41 | 205 | 9 |
| [script-game/ai/generalgameplay/hitgap_ai.lua](../../../mods/reduce-ai-dummy-half-scoots/src/script-game/ai/generalgameplay/hitgap_ai.lua) | 63 | 404 | 3 |
| [script-game/ai/playtheball/tacklemarker_ai.lua](../../../mods/reduce-ai-dummy-half-scoots/src/script-game/ai/playtheball/tacklemarker_ai.lua) | 35 | 81 | 0 |
| [script-game/design/playtheball_config.lua](../../../mods/reduce-ai-dummy-half-scoots/src/script-game/design/playtheball_config.lua) | 73 | 7 | 2 |

