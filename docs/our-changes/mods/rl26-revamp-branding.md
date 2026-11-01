# rl26-revamp-branding

Source: [mods/rl26-revamp-branding](../../../mods/rl26-revamp-branding/) - [README](../../../mods/rl26-revamp-branding/README.md)

Replaces the Rugby League 26 logo with the RL26 Revamped logo (`resources/rl26-revamp/rl26-revamped-logo.png`) and swaps the brand green (#24DB61) for the revamp blue (#1E6FD9).

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/app/noesis/homescreen/nvm_background.lua](../../../mods/rl26-revamp-branding/src/script-game/app/noesis/homescreen/nvm_background.lua) | 85 | 70 | 1 |
| [script-game/intermediatelua/skin/colour_map.lua](../../../mods/rl26-revamp-branding/src/script-game/intermediatelua/skin/colour_map.lua) | 3014 | 3 | 3 |
| [script-game/uicore/uicolours.lua](../../../mods/rl26-revamp-branding/src/script-game/uicore/uicolours.lua) | 132 | 1 | 1 |

## Noesis UI overrides (xamls / fonts bundles)

| File | Stock lines | + | - |
|---|---:|---:|---:|
| noesis/workspace/resources/cards/dynastycard.xaml | 7746 | 22 | 22 |
| noesis/workspace/resources/colours_bigant.xaml | 209 | 3 | 3 |
| noesis/workspace/resources/resourcedictionary.xaml | 880 | 8 | 10 |
| noesis/workspace/resources/stylethemes/screenwipes/rl26_wipe_generic.xaml | 25 | 1 | 1 |
| noesis/workspace/resources/stylethemes/screenwipes/rl26_wipe_nrl.xaml | 29 | 2 | 2 |
| noesis/workspace/views/background/menubackgroundview.xaml | 1521 | 522 | 18 |

## Texture replacements: 1

- `textures/322eabdb8b82c1bf_rll_logo.dds`

## Programs

Generators, installers and exe patchers the mod runs itself (see its README):

- [make_branding.py](../../../mods/rl26-revamp-branding/make_branding.py)
- [title_screen.py](../../../mods/rl26-revamp-branding/title_screen.py)

