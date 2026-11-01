# injury-cutscene-variety

Source: [mods/injury-cutscene-variety](../../../mods/injury-cutscene-variety/) - [README](../../../mods/injury-cutscene-variety/README.md)

RL26 ships two injury cutscene animations it never plays: a 12.7 s **concussion** and a 9.0 s **hamstring** (`injury_concussion_01` / `injury_hamstring_01` in `animations/cutsceneInjuries`, with motion-set records). This mod gives them cutscene definitions and lets the injury cameo pick them.

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/intermediatelua/cutscenes/data/cs_injury_data.lua](../../../mods/injury-cutscene-variety/src/script-game/intermediatelua/cutscenes/data/cs_injury_data.lua) | 613 | 175 | 0 |
| [script-game/rules/injury/injurycameo_rulestate.lua](../../../mods/injury-cutscene-variety/src/script-game/rules/injury/injurycameo_rulestate.lua) | 168 | 7 | 3 |

