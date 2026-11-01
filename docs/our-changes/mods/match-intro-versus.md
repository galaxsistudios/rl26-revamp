# match-intro-versus

Source: [mods/match-intro-versus](../../../mods/match-intro-versus/) - [README](../../../mods/match-intro-versus/README.md)

A broadcast-style opening for the match intro. The stock intro cuts straight into the home sheds. Now it runs like this:

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/intermediatelua/cutscenes/data/cs_lockerroom_data.lua](../../../mods/match-intro-versus/src/script-game/intermediatelua/cutscenes/data/cs_lockerroom_data.lua) | 1499 | 94 | 0 |
| [script-game/rules/cutscenes/initial_cutscene.lua](../../../mods/match-intro-versus/src/script-game/rules/cutscenes/initial_cutscene.lua) | 62 | 775 | 0 |

## Noesis UI overrides (xamls / fonts bundles)

| File | Stock lines | + | - |
|---|---:|---:|---:|
| noesis/workspace/views/testscreens/testscreen.xaml | 41 | 336 | 26 |

