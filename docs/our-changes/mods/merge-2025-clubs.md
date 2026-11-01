# merge-2025-clubs

Source: [mods/merge-2025-clubs](../../../mods/merge-2025-clubs/) - [README](../../../mods/merge-2025-clubs/README.md)

RL26 ships most clubs twice: a "2025" club (Brisbane Broncos 2025, ids 1-102, and the women's 32-51) and its 2026 club (Brisbane Broncos, 118-183, women's 184-203). This mod folds each 2025 club into its 2026 club, so every team appears once with all its kits:

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/app/academy/academy_clubselect_state.lua](../../../mods/merge-2025-clubs/src/script-game/app/academy/academy_clubselect_state.lua) | 216 | 100 | 1 |
| [script-game/app/academy/academy_helper.lua](../../../mods/merge-2025-clubs/src/script-game/app/academy/academy_helper.lua) | 1142 | 1 | 1 |
| [script-game/app/casual/casual_hub.lua](../../../mods/merge-2025-clubs/src/script-game/app/casual/casual_hub.lua) | 433 | 2 | 2 |
| [script-game/design/app/online/online_config.lua](../../../mods/merge-2025-clubs/src/script-game/design/app/online/online_config.lua) | 22 | 2 | 2 |

## Database records

| Database | Patched records | New records |
|---|---:|---:|
| defaultdata_clubs | 154 | 0 |
| defaultdata_leagues | 26 | 0 |

## Programs

Generators, installers and exe patchers the mod runs itself (see its README):

- [generate.py](../../../mods/merge-2025-clubs/generate.py)

