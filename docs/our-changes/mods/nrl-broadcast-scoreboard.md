# nrl-broadcast-scoreboard

Source: [mods/nrl-broadcast-scoreboard](../../../mods/nrl-broadcast-scoreboard/) - [README](../../../mods/nrl-broadcast-scoreboard/README.md)

Restyles the default in-game scoreboard (DefaultHUDResources `ScoreCardTemplate`, used for NRL and every competition without its own HUD theme) into the NRL broadcast layout:

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/app/noesis/hud/nvm_penaltyhud.lua](../../../mods/nrl-broadcast-scoreboard/src/script-game/app/noesis/hud/nvm_penaltyhud.lua) | 74 | 98 | 2 |
| [script-game/app/noesis/hud/nvm_playerplate.lua](../../../mods/nrl-broadcast-scoreboard/src/script-game/app/noesis/hud/nvm_playerplate.lua) | 78 | 148 | 0 |
| [script-game/app/noesis/hud/nvm_substitutionhud.lua](../../../mods/nrl-broadcast-scoreboard/src/script-game/app/noesis/hud/nvm_substitutionhud.lua) | 249 | 65 | 7 |
| [script-game/app/noesis/ingame/nvm_playerstatisticshud.lua](../../../mods/nrl-broadcast-scoreboard/src/script-game/app/noesis/ingame/nvm_playerstatisticshud.lua) | 424 | 69 | 1 |
| [script-game/app/noesis/util/nvm_team.lua](../../../mods/nrl-broadcast-scoreboard/src/script-game/app/noesis/util/nvm_team.lua) | 100 | 58 | 0 |
| [script-game/design/ui/playerstatisticshud_config.lua](../../../mods/nrl-broadcast-scoreboard/src/script-game/design/ui/playerstatisticshud_config.lua) | 523 | 20 | 0 |
| [script-game/sim/hud/hud.lua](../../../mods/nrl-broadcast-scoreboard/src/script-game/sim/hud/hud.lua) | 197 | 72 | 0 |
| [script-game/sim/hud/penaltyselect_hud.lua](../../../mods/nrl-broadcast-scoreboard/src/script-game/sim/hud/penaltyselect_hud.lua) | 62 | 47 | 1 |
| [script-game/sim/hud/playerinfo_hud.lua](../../../mods/nrl-broadcast-scoreboard/src/script-game/sim/hud/playerinfo_hud.lua) | 465 | 56 | 12 |
| [script-game/sim/hud/playerstatistics_hud.lua](../../../mods/nrl-broadcast-scoreboard/src/script-game/sim/hud/playerstatistics_hud.lua) | 346 | 54 | 4 |

## Noesis UI overrides (xamls / fonts bundles)

| File | Stock lines | + | - |
|---|---:|---:|---:|
| noesis/workspace/fonts/freeserifbolditalic.ttf | binary or new | |  |
| noesis/workspace/fonts/hundreddisplay-regular.ttf | binary or new | |  |
| noesis/workspace/resources/fonts.xaml | 235 | 14 | 0 |
| noesis/workspace/resources/stylethemes/hud/defaulthudresources.xaml | 659 | 1214 | 427 |
| noesis/workspace/views/hud/rugby/papenaltycontrol.xaml | 157 | 332 | 93 |
| noesis/workspace/views/hud/rugby/pareplacementcontrol.xaml | 646 | 418 | 566 |

## Texture replacements: 17

- `textures/0f0ee9f097a48903_hud_score_nrl_knights.dds`
- `textures/19cac4877aa06ef3_hud_score_nrl_bulldogs.dds`
- `textures/1c40a6ba5d112b89_hud_score_nrl_dragons.dds`
- `textures/31e185be65e0bcf5_hud_score_nrl_broncos.dds`
- `textures/3784314a9cc655f7_hud_score_nrl_seaeagles.dds`
- `textures/4728b8c35025978c_hud_score_nrl_dolphins.dds`
- `textures/55989c1d4a00f040_hud_score_nrl_storm.dds`
- `textures/61d4eef5b07f0225_hud_score_nrl_tigers.dds`
- `textures/690b98b530a04de2_hud_score_nrl_warriors.dds`
- `textures/6db67c16579acdad_hud_score_nrl_raiders.dds`
- `textures/819a268f99534402_hud_score_nrl_titans.dds`
- `textures/96f27562a8e51388_hud_score_nrl_panthers.dds`
- `textures/9cff45938f8ef655_hud_score_nrl_rabbitohs.dds`
- `textures/a8374f2a54984446_hud_score_nrl_eels.dds`
- `textures/b083718df3ebd758_hud_score_nrl_roosters.dds`
- `textures/bbc653375908ba99_hud_score_nrl_cowboys.dds`
- `textures/f4feceff218eb7db_hud_score_nrl_sharks.dds`

