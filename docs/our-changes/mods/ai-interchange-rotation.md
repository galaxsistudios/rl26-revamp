# ai-interchange-rotation

Source: [mods/ai-interchange-rotation](../../../mods/ai-interchange-rotation/) - [README](../../../mods/ai-interchange-rotation/README.md)

Fixes issue C-80 ("the AI only ever uses two bench players"). AI-run sides now make interchanges when players tire, instead of on a fixed clock:

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/ai/substitutions/substitution_listener.lua](../../../mods/ai-interchange-rotation/src/script-game/ai/substitutions/substitution_listener.lua) | 76 | 642 | 0 |

## Programs

Generators, installers and exe patchers the mod runs itself (see its README):

- [install.py](../../../mods/ai-interchange-rotation/install.py)

