# restore-cut-try-celebrations

Source: [mods/restore-cut-try-celebrations](../../../mods/restore-cut-try-celebrations/) - [README](../../../mods/restore-cut-try-celebrations/README.md)

Plays try-celebration animations that ship with the game but never play. All three Lua overrides are generated from the stock decompiled sources by `generate.py`. Edit the settings at its top and re-run it (`python mods\restore-cut-try-celebrations\generate.py`) rather than hand-editing the Lua.

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/game/camera/animated_camera.lua](../../../mods/restore-cut-try-celebrations/src/script-game/game/camera/animated_camera.lua) | 825 | 19 | 0 |
| [script-game/intermediatelua/cutscenes/data/cs_try_celebrate_data.lua](../../../mods/restore-cut-try-celebrations/src/script-game/intermediatelua/cutscenes/data/cs_try_celebrate_data.lua) | 15063 | 2606 | 0 |
| [script-game/intermediatelua/cutscenes/data/cutscenegroupdata_config.lua](../../../mods/restore-cut-try-celebrations/src/script-game/intermediatelua/cutscenes/data/cutscenegroupdata_config.lua) | 828 | 216 | 0 |
| [script-game/rules/cutscenes/trycelebrate_rulestate.lua](../../../mods/restore-cut-try-celebrations/src/script-game/rules/cutscenes/trycelebrate_rulestate.lua) | 169 | 43 | 0 |

## Programs

Generators, installers and exe patchers the mod runs itself (see its README):

- [generate.py](../../../mods/restore-cut-try-celebrations/generate.py)

