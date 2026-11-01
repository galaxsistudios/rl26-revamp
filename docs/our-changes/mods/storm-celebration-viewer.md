# storm-celebration-viewer

Source: [mods/storm-celebration-viewer](../../../mods/storm-celebration-viewer/) - [README](../../../mods/storm-celebration-viewer/README.md)

Adds a **Celebrations** tile to the Academy player view hub (Identity / Appearance / Skills / Team / Sharing, and the read-only hub's tile list). It opens a small menu that plays one of the 15 Melbourne Storm promo try celebrations on the menu player model and loops it until you change it or back out. Use it to grab thumbnails.

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/app/academy/academy_player_viewstate_tiles.lua](../../../mods/storm-celebration-viewer/src/script-game/app/academy/academy_player_viewstate_tiles.lua) | 215 | 729 | 2 |
| [script-game/app/playermodel/playermodel_resources.lua](../../../mods/storm-celebration-viewer/src/script-game/app/playermodel/playermodel_resources.lua) | 154 | 9 | 0 |

## Noesis UI overrides (xamls / fonts bundles)

| File | Stock lines | + | - |
|---|---:|---:|---:|
| noesis/workspace/views/academy/paacademyhubview.xaml | 342 | 12 | 0 |

