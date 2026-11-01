# fullback-sweeper-defence

Source: [mods/fullback-sweeper-defence](../../../mods/fullback-sweeper-defence/) - [README](../../../mods/fullback-sweeper-defence/README.md)

The defending AI fullback plays as a sweeper. His depth behind the line depends on the tackle count and field position, and he holds it when the ball is played. He only goes after the ball carrier on a line break, or when a carrier gets right up to him. Near his own try line he stands in the line, level with the ball.

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/ai/generalgameplay/defensivemovementpassive_ai.lua](../../../mods/fullback-sweeper-defence/src/script-game/ai/generalgameplay/defensivemovementpassive_ai.lua) | 15 | 155 | 0 |
| [script-game/intermediatelua/forcedirectedgraphs/forcedirectedgraphs_rugby.lua](../../../mods/fullback-sweeper-defence/src/script-game/intermediatelua/forcedirectedgraphs/forcedirectedgraphs_rugby.lua) | 12001 | 8 | 8 |

