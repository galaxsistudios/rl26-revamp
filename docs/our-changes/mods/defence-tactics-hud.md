# defence-tactics-hud

Source: [mods/defence-tactics-hud](../../../mods/defence-tactics-hud/) - [README](../../../mods/defence-tactics-hud/README.md)

Three tweaks to the in-match tactics (D-pad) HUD:

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/app/noesis/hud/nvm_tactics.lua](../../../mods/defence-tactics-hud/src/script-game/app/noesis/hud/nvm_tactics.lua) | 161 | 150 | 1 |
| [script-game/sim/hud/tactics_hud.lua](../../../mods/defence-tactics-hud/src/script-game/sim/hud/tactics_hud.lua) | 424 | 176 | 3 |

## Noesis UI overrides (xamls / fonts bundles)

| File | Stock lines | + | - |
|---|---:|---:|---:|
| noesis/workspace/views/hud/rugby/pagameplayhudcontrol.xaml | 548 | 393 | 27 |
| noesis/workspace/views/hud/rugby/patacticscontrol.xaml | 146 | 222 | 75 |

