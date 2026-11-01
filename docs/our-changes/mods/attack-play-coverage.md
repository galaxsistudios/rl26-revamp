# attack-play-coverage

Source: [mods/attack-play-coverage](../../../mods/attack-play-coverage/) - [README](../../../mods/attack-play-coverage/README.md)

Makes the attack tactic you call (CrossOver, HitUp, Out The Back, Inside Ball, Kick) actually run in most of the field. It also stops plays written for another part of the field from scattering the runners, fixes the kick-off receive layout, and stops the last-tackle kicker running a gap.

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/ai/kicking/kickchase_ai.lua](../../../mods/attack-play-coverage/src/script-game/ai/kicking/kickchase_ai.lua) | 34 | 246 | 13 |
| [script-game/ai/kicking/kickoffidle_ai.lua](../../../mods/attack-play-coverage/src/script-game/ai/kicking/kickoffidle_ai.lua) | 19 | 180 | 3 |
| [script-game/ai/kicking/kickoffrunup_ai.lua](../../../mods/attack-play-coverage/src/script-game/ai/kicking/kickoffrunup_ai.lua) | 21 | 14 | 0 |
| [script-game/design/playroleassignment_config.lua](../../../mods/attack-play-coverage/src/script-game/design/playroleassignment_config.lua) | 14 | 4 | 1 |
| [script-game/design/playselection_config.lua](../../../mods/attack-play-coverage/src/script-game/design/playselection_config.lua) | 10 | 4 | 1 |
| [script-game/game/plays/play_listener.lua](../../../mods/attack-play-coverage/src/script-game/game/plays/play_listener.lua) | 152 | 402 | 0 |

## Programs

Generators, installers and exe patchers the mod runs itself (see its README):

- [install.py](../../../mods/attack-play-coverage/install.py)
- [playset.py](../../../mods/attack-play-coverage/playset.py)

