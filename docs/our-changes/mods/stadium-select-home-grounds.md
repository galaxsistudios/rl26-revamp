# stadium-select-home-grounds

Source: [mods/stadium-select-home-grounds](../../../mods/stadium-select-home-grounds/) - [README](../../../mods/stadium-select-home-grounds/README.md)

Match setup's **Stadium Select** screen (`MatchSetupStadiumSelect` → `paStadiumSelectView`) now opens with the two clubs' home grounds at the top of the on-disc **Stadiums** tab: home team first, then away team. Each row has the club's primary colour as its background and the club logo next to the stadium name. The text turns black on light colours (luma > 170) so it stays readable. When a row is focused it is inset 4px, so the stock white focus fill shows as a ring around it.

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/app/match/matchsetup_stadium_select.lua](../../../mods/stadium-select-home-grounds/src/script-game/app/match/matchsetup_stadium_select.lua) | 109 | 28 | 0 |
| [script-game/app/noesis/academy/nvm_stadium_list.lua](../../../mods/stadium-select-home-grounds/src/script-game/app/noesis/academy/nvm_stadium_list.lua) | 333 | 90 | 2 |

## Noesis UI overrides (xamls / fonts bundles)

| File | Stock lines | + | - |
|---|---:|---:|---:|
| noesis/workspace/views/academy/pastadiumselectview.xaml | 138 | 70 | 1 |

