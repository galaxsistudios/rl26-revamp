# replay-team-stinger

Source: [mods/replay-team-stinger](../../../mods/replay-team-stinger/) - [README](../../../mods/replay-team-stinger/README.md)

A broadcast-style stinger between a try celebration and its replay. Two skewed panels sweep in from the right: a band in the scoring team's **secondary** colour, then a full-screen panel in its **primary** colour. The club crest lands in the middle. The stinger covers the end of the celebration, holds while the replay loads, then sweeps off to the left once the replay is playing.

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/base/transition/logotransition_hud.lua](../../../mods/replay-team-stinger/src/script-game/base/transition/logotransition_hud.lua) | 122 | 710 | 0 |
| [script-game/base/transition/screenwipe.lua](../../../mods/replay-team-stinger/src/script-game/base/transition/screenwipe.lua) | 141 | 327 | 1 |

## Noesis UI overrides (xamls / fonts bundles)

| File | Stock lines | + | - |
|---|---:|---:|---:|
| noesis/workspace/views/tests/matchintro.xaml | 315 | 142 | 271 |

