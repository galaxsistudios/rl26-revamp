# realistic-pitch-grass

Makes the pitch read more like real broadcast turf: less lime, and
different grass at different kinds of ground.

## How the stock grass works

`rendering/stadium/stadiumgrass.lua` builds the pitch from
`fields/textures/grass/<grassType>.texture`, where `grassType` comes from
the ground's entry in `intermediatelua/visualconfig/stadium-cfg.lua`. Every
stock ground uses `grass_lush_col`, so every pitch looks the same.
`field-cfg.lua`'s `grassTex` / `pitchTex` fields are never read.

Of the five grass colour textures (2048², 12 mips):

| Texture | Stock | Used by |
|---|---|---|
| `grass_lush_col` | BC7, the only one with real blade detail | every ground |
| `grass_standard_col` | BC7, byte-identical to `grass_dry_col` | Stadium Creator |
| `grass_dry_col` | BC7 | every ground: the worn-grass blend (`grass2_col`) |
| `grass_verylush_col` | BC1, flat placeholder | Stadium Creator |
| `grass_verydry_col` | BC1, flat placeholder | Stadium Creator |

Mowing stripes come from shader globals. `rendering/scene/scene_config.lua`
always passes the `verticalstripe` pattern (3 m bands, faint), so the
LawnStriping match setting does nothing in rugby.

## What it changes

- **Grass textures** ([make_grass.py](make_grass.py) → `textures/`). All four
  are re-tinted copies of lush's blades, so they tile exactly like stock:
  - `grass_lush_col` "broadcast": a cooler, deeper green (hue ~106° vs
    stock ~87°) at the same brightness, with crisper blades and yellower
    sun-lit tips.
  - `grass_verylush_col` "ryegrass": dark, cool winter rye.
  - `grass_standard_col` "couch": warmer couch/bermuda, a few dry patches.
  - `grass_verydry_col` "suburban": tired turf with brown patches.
  - `grass_dry_col` (the wear layer) is left stock.
  - The DDS files are game-derived, so git ignores them (`*.dds`). The Revamp
    install's `textures` step runs make_grass.py (it needs texconv) before
    `texture_mods.py apply`.
  - make_grass.py also writes a local preview to
    `resources/pitch-grass/preview.png` (not in git).
- **Per-ground grass** ([stadium_module.lua](src/script-game/rendering/modules/stadium_module.lua)).
  `StadiumModule.load` passes the grass loader a copy of the ground's config
  with `grassType` swapped from the `var_0_GroundGrass` table. The real
  config is untouched.
  - Ryegrass: England, Wales, France, New Zealand, Melbourne, Canberra.
  - Couch: the tropics (Townsville, Darwin, Port Moresby, Cairns and so on),
    the Gold and Sunshine Coasts, Redcliffe, Las Vegas.
  - Suburban: park grounds (Henson Park, Redfern, Kellyville and so on).
  - Everything else keeps the repainted lush.
  - This file is hooked because `stadiumgrass.lua`, `stadiumfactory.lua` and
    `stadium-cfg.lua` are already owned by other mods.
- **Stripes are left stock.** 5 m bands at 0.24 / 0.08 strength were tried
  first (2026-10-29). In game they showed as dark, streaky lines broken up by
  the grass noise rather than clean mowing bands, so they were dropped.
- **[shaderglobals-game.lua](src/script-game/intermediatelua/visualconfig/shaderglobals-game.lua)**
  `GrassGlobals`:
  - `g_grass_envSaturate` 0.7 → 0.6: less lime from the sky light.
  - `g_grass_colourID_strength` 0.13 → 0.2: more per-blade colour on the
    3D grass (Grass graphics setting = High Quality).

Stadium Creator grounds also see the new textures for their grass type.

## Tuning

- Colours: edit `VARIANTS` in make_grass.py and rerun it. It reads stock
  lush from the game, or from the pack.py backup once this mod's lush is
  installed. `--source <stock grass_lush_col .dds>` overrides both.
- Stripes: `g_grass_amountInner/Outer` and `g_field_stripeWidth`. Set them
  in stadium_module.lua (it overrides the pattern after load) and in
  `GrassGlobals`.

## Install / undo (game closed)

```powershell
python mods\realistic-pitch-grass\make_grass.py            # writes textures\*.dds (not in git)
python tools\texture_mods.py apply --mod realistic-pitch-grass --confirm
python tools\build.py full --confirm                        # restore the scripts entry first if installed
```

Undo: `python tools\pack.py restore --entry <n>` for entries
`fields/textures/grass/grass_{lush,standard,verydry,verylush}_col.texture`,
then rebuild the scripts without this mod.
