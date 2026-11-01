# coach-editor

Source: [mods/coach-editor](../../../mods/coach-editor/) - [README](../../../mods/coach-editor/README.md)

Adds a **Referees & Coaches** tile to the Academy row of the home screen. Its submenu has Edit/Create (Man)/Create (Woman)/Delete for referees, then the same four for coaches. Script mod, entry **39959**. Pair it with `unhide-coaches` (entry 39954), or the coach lists only show coaches you create yourself.

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/app/academy/academy_referee_appearancestate_edit_state.lua](../../../mods/coach-editor/src/script-game/app/academy/academy_referee_appearancestate_edit_state.lua) | 45 | 13 | 0 |
| [script-game/app/academy/academy_referee_edit_hub.lua](../../../mods/coach-editor/src/script-game/app/academy/academy_referee_edit_hub.lua) | 116 | 7 | 2 |
| [script-game/app/academy/academy_referee_hub_create.lua](../../../mods/coach-editor/src/script-game/app/academy/academy_referee_hub_create.lua) | 118 | 15 | 4 |
| [script-game/app/academy/academy_referee_hub_delete.lua](../../../mods/coach-editor/src/script-game/app/academy/academy_referee_hub_delete.lua) | 78 | 7 | 3 |
| [script-game/app/academy/academy_referee_hub_edit.lua](../../../mods/coach-editor/src/script-game/app/academy/academy_referee_hub_edit.lua) | 157 | 8 | 3 |
| [script-game/app/academy/academy_referee_list.lua](../../../mods/coach-editor/src/script-game/app/academy/academy_referee_list.lua) | 300 | 1 | 1 |
| [script-game/app/academy/academyrefereecreateethnicity_state.lua](../../../mods/coach-editor/src/script-game/app/academy/academyrefereecreateethnicity_state.lua) | 205 | 5 | 3 |
| [script-game/app/academy/refereelist_layout.lua](../../../mods/coach-editor/src/script-game/app/academy/refereelist_layout.lua) | 85 | 2 | 2 |
| [script-game/app/homescreen/homescreenstate_config.lua](../../../mods/coach-editor/src/script-game/app/homescreen/homescreenstate_config.lua) | 1198 | 47 | 8 |
| [script-game/app/playermodel/playermodel.lua](../../../mods/coach-editor/src/script-game/app/playermodel/playermodel.lua) | 904 | 6 | 1 |
| [script-game/app/playermodel/playermodel_mixin.lua](../../../mods/coach-editor/src/script-game/app/playermodel/playermodel_mixin.lua) | 926 | 4 | 2 |
| [script-game/app/referee/referee_view_state.lua](../../../mods/coach-editor/src/script-game/app/referee/referee_view_state.lua) | 168 | 2 | 2 |
| [script-game/app/referee/referee_viewstate_hub_state.lua](../../../mods/coach-editor/src/script-game/app/referee/referee_viewstate_hub_state.lua) | 47 | 3 | 2 |
| [script-game/game/player/playergenerator.lua](../../../mods/coach-editor/src/script-game/game/player/playergenerator.lua) | 96 | 97 | 7 |

## Programs

Generators, installers and exe patchers the mod runs itself (see its README):

- [generate.py](../../../mods/coach-editor/generate.py)

