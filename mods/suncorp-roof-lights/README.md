# Suncorp roof lights

Recolours Suncorp Stadium's red light band under the roof's front edges (ground key `brisbane`, night matches) and the floodlight glows for each match:

| Match | Roof light band | Floodlight glows |
|---|---|---|
| Broncos home game | alternating maroon / gold segments | crossfade maroon <-> gold |
| Dolphins home game | alternating red / gold segments | crossfade red <-> gold |
| Magic Round (season fixture, or Play Now's Magic Round field markings) | segments alternate home / away primary | crossfade home <-> away |
| anything else | stock red | stock white |

- Magic Round wins over a Broncos or Dolphins home game.
- If the two primaries are too alike (`ROOF_LIGHTS_SIMILAR`), the away side uses its secondary colour.

## How it works

The red band is lighting, not a model. It's the `RoofLights` group in `intermediatelua/lighting/background_brisbane_01.lua`: four `CPlanarLight`s coloured (255, 66, 59), one under each side and end of the roof at about 34 m.

- When that file loads, each light is replaced by segments about `ROOF_LIGHTS_SEGMENT_M` (10 m) wide, alternating between the two colours (r b r b). That makes 25 segments.
- Dark colours get extra brightness (`ROOF_LIGHTS_DARK_BOOST`), so the band doesn't go dim.
- The glows are the shader global `glow_stadium_colour01` (the Glowbals in shaderglobals-game.lua, white in stock).
  - It is set per frame for a crossfade: hold `ROOF_LIGHTS_GLOW_HOLD` s, fade over `ROOF_LIGHTS_GLOW_FADE` s.
  - It goes back to stock when the stadium is disposed.
  - Glow colours are normalised to full brightness, so maroon reads as a deep pink-crimson.

## Queensland Country Bank Stadium (townsvilleStadium)

The stock rainbow in the roof triangles comes from the `ColouredRoofLights` group in `background_townsvilleStadium_01.lua`: 23 spotlights, one per triangle. Every match, they're recoloured blue (0, 120, 255; (0, 25, 255) and (0, 80, 255) rendered purple under the warm floodlight wash) and yellow (255, 196, 0), alternating in order around the roof rather than file order (`STADIUM_LIGHT_PATTERNS`). Other grounds can be added to the same table.

## Code

- **The mod's code** lives in `rendering/util/shaderglobalbinding.lua`, a stock file the game never imports. All config is at the top of the block.
- **Hooks** live in other mods' files, because every stadium and lighting Lua file was already owned:
  - realistic-pitch-grass `rendering/modules/stadium_module.lua`:
    - `setRoofLightsMatch` at stadium load (the stadium loads before the lighting, `universe.lua` 545 vs 602);
    - `clearRoofLights` at dispose.
  - gf-tunnel-team-colour-lights `rendering/modules/lighting_module.lua`:
    - `recolourRoofLights` on each lighting file before it's imported;
    - `tickRoofLights` in `LightingModule.update`, which runs every frame.
  - With this mod off, the host file is stock and the hooks find nothing.
- **Log:** `roofLights_debug.txt` in the game folder records the scheme and the segment count.

## History

The first version recoloured the 392 red floodlight housings (material `concretered_SS`) through a stadium model edit. Those are about 40 cm each and weren't the band, so the model edit was reverted.

## Status

Installed 2026-10-30, untested in game. The probe build confirmed that `glow_stadium_colour01` drives the floodlight glows (they turned green).
