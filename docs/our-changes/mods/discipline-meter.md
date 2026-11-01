# discipline-meter

Source: [mods/discipline-meter](../../../mods/discipline-meter/) - [README](../../../mods/discipline-meter/README.md)

Every player now has a **discipline** meter alongside stamina. It's the mental side of the game: it drops when things go wrong, faster when the player is tired, rattled, under siege or chasing the score, and comes back slowly when his team is in control. A player who runs out makes mistakes and gives away penalties, and at the very bottom he gets binned or sent off.

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/ai/tackle/tackle_arbitrator.lua](../../../mods/discipline-meter/src/script-game/ai/tackle/tackle_arbitrator.lua) | 620 | 13 | 1 |
| [script-game/app/academy/customdifficulty_edit_state.lua](../../../mods/discipline-meter/src/script-game/app/academy/customdifficulty_edit_state.lua) | 128 | 164 | 1 |
| [script-game/rules/sinbin/sinbinsystem.lua](../../../mods/discipline-meter/src/script-game/rules/sinbin/sinbinsystem.lua) | 702 | 824 | 8 |

