# skip-intro-to-main-menu

Source: [mods/skip-intro-to-main-menu](../../../mods/skip-intro-to-main-menu/) - [README](../../../mods/skip-intro-to-main-menu/README.md)

Optional skip: with `skip_intro = true` in `rl26_revamp.ini` it boots straight to the main menu, with no splash logos (Nacon, Rugby League 26, BigAnt, legal/autosave notices) and no "press start" screen. **Off by default**, so the game boots normally to the start screen (see rl26-revamp-branding's `title_screen.py`). Also adds **RL26 Revamped Mod v1.0** in white under the version number in the bottom-right corner of the menus.

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/app/signin/waitforsignin_state.lua](../../../mods/skip-intro-to-main-menu/src/script-game/app/signin/waitforsignin_state.lua) | 257 | 136 | 0 |

## Noesis UI overrides (xamls / fonts bundles)

| File | Stock lines | + | - |
|---|---:|---:|---:|
| noesis/workspace/views/utils/menuoverlay.xaml | 412 | 10 | 4 |

## Programs

Generators, installers and exe patchers the mod runs itself (see its README):

- [install.py](../../../mods/skip-intro-to-main-menu/install.py)

