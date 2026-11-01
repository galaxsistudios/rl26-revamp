# realistic-pitch-grass

Source: [mods/realistic-pitch-grass](../../../mods/realistic-pitch-grass/) - [README](../../../mods/realistic-pitch-grass/README.md)

Makes the pitch read more like real broadcast turf: less lime, and different grass at different kinds of ground.

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/intermediatelua/visualconfig/shaderglobals-game.lua](../../../mods/realistic-pitch-grass/src/script-game/intermediatelua/visualconfig/shaderglobals-game.lua) | 290 | 4 | 2 |
| [script-game/rendering/modules/stadium_module.lua](../../../mods/realistic-pitch-grass/src/script-game/rendering/modules/stadium_module.lua) | 218 | 115 | 1 |

## Texture replacements: 4

- `textures/62672700848e53e6_ryegrass.dds`
- `textures/74bb5eebc8465a33_suburban.dds`
- `textures/7e287bb34d7c364a_broadcast.dds`
- `textures/fd6a2a377030c7af_couch.dds`

## Programs

Generators, installers and exe patchers the mod runs itself (see its README):

- [make_grass.py](../../../mods/realistic-pitch-grass/make_grass.py)

