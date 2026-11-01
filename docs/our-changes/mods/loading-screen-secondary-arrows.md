# loading-screen-secondary-arrows

Source: [mods/loading-screen-secondary-arrows](../../../mods/loading-screen-secondary-arrows/) - [README](../../../mods/loading-screen-secondary-arrows/README.md)

On the team loading screen (home vs away), every second chevron arrow on each side is drawn in the club's secondary colour (primary, secondary, primary, ... from the centre out). Stock draws them all in the primary colour. Background glows and gradients keep the primary colour.

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/app/gameplay/gameplay_loadingscreen_helper.lua](../../../mods/loading-screen-secondary-arrows/src/script-game/app/gameplay/gameplay_loadingscreen_helper.lua) | 9 | 8 | 0 |
| [script-game/app/match/matchsetup_lockdown.lua](../../../mods/loading-screen-secondary-arrows/src/script-game/app/match/matchsetup_lockdown.lua) | 184 | 5 | 0 |
| [script-game/design/loading_setup_helper.lua](../../../mods/loading-screen-secondary-arrows/src/script-game/design/loading_setup_helper.lua) | 121 | 426 | 4 |

## Noesis UI overrides (xamls / fonts bundles)

| File | Stock lines | + | - |
|---|---:|---:|---:|
| noesis/workspace/views/loadingscreen/loadingscreen_rugby.xaml | 1097 | 7941 | 51 |

## Programs

Generators, installers and exe patchers the mod runs itself (see its README):

- [generate.py](../../../mods/loading-screen-secondary-arrows/generate.py)
- [install.py](../../../mods/loading-screen-secondary-arrows/install.py)

