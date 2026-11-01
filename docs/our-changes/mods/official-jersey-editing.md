# official-jersey-editing

Source: [mods/official-jersey-editing](../../../mods/official-jersey-editing/) - [README](../../../mods/official-jersey-editing/README.md)

Opens official jerseys in the Academy jersey editor, limited to the **Manufacturer** and the **numbering on the back**. It also unlocks every number font and every jersey manufacturer for player-made jerseys.

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/app/academy/academy_club_jerseystate_appearance_state.lua](../../../mods/official-jersey-editing/src/script-game/app/academy/academy_club_jerseystate_appearance_state.lua) | 102 | 50 | 0 |
| [script-game/app/academy/academy_club_jerseystate_appearancestate_edit_groups.lua](../../../mods/official-jersey-editing/src/script-game/app/academy/academy_club_jerseystate_appearancestate_edit_groups.lua) | 169 | 354 | 6 |
| [script-game/app/academy/academy_club_jerseystate_appearancestate_edit_state.lua](../../../mods/official-jersey-editing/src/script-game/app/academy/academy_club_jerseystate_appearancestate_edit_state.lua) | 72 | 39 | 2 |
| [script-game/app/frontend/frontend_state.lua](../../../mods/official-jersey-editing/src/script-game/app/frontend/frontend_state.lua) | 427 | 3 | 0 |
| [script-game/app/frontend/partymember_aide.lua](../../../mods/official-jersey-editing/src/script-game/app/frontend/partymember_aide.lua) | 63 | 242 | 0 |

## Noesis UI overrides (xamls / fonts bundles)

| File | Stock lines | + | - |
|---|---:|---:|---:|
| noesis/workspace/fonts/arvo-bold.ttf | binary or new | |  |

## Programs

Generators, installers and exe patchers the mod runs itself (see its README):

- [chest_colours.py](../../../mods/official-jersey-editing/chest_colours.py)
- [generate.py](../../../mods/official-jersey-editing/generate.py)
- [rl_font.py](../../../mods/official-jersey-editing/rl_font.py)

