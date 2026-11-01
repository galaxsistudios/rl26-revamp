# main-menu-revamp

Source: [mods/main-menu-revamp](../../../mods/main-menu-revamp/) - [README](../../../mods/main-menu-revamp/README.md)

Redesigns the home screen:

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/app/save/compresssavedata_state.lua](../../../mods/main-menu-revamp/src/script-game/app/save/compresssavedata_state.lua) | 627 | 1223 | 0 |

## Noesis UI overrides (xamls / fonts bundles)

| File | Stock lines | + | - |
|---|---:|---:|---:|
| noesis/workspace/genericcontrols/paaccordionbutton.xaml | 297 | 205 | 0 |
| noesis/workspace/views/homescreen/pahomescreenview.xaml | 359 | 899 | 248 |

## Programs

Generators, installers and exe patchers the mod runs itself (see its README):

- [make_xaml.py](../../../mods/main-menu-revamp/make_xaml.py)

