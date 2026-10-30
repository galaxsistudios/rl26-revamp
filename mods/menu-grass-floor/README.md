# menu-grass-floor

Turns the menu floor into grass. The player on the home screen (and on player edit, team select and the
other front-end screens that stand a model on the floor) now stands on a dark-lit strip of pitch with
mowing stripes running away from the camera, instead of grey concrete.

## How it works

The floor isn't 3D. It's one flat image, `noesis/workspace/images/background/rugbyleague_mainmenu/floor_image`
(3840x720 BC7, no mips), in the bottom row of `MenuBackgroundView`'s grid (`FloorVB`). The `Main`,
`MainNoTitles` and `Data` visual states give that row half the height of the top row, `TeamSelect` a quarter,
and `DataNoFloor` none. At 16:9 the whole image shows, about 1:1 at 4K. Replacing the texture changes every
screen that shows the floor, and the XAML is left alone (rl26-revamp-branding owns it).

`make_floor.py` builds the replacement:

- **Grass**: the stock pitch blades (`grass_lush_col`), re-tinted the same way realistic-pitch-grass does it,
  to `TARGET`. It's the stock texture, not that mod's, so the floor doesn't depend on it.
- **Perspective**: a pinhole camera `CAM_HEIGHT` m above the grass, with the horizon `HORIZON_PX` above the
  image's top edge. One tile covers `TILE_M` m. Rows sample a box-filtered mip pyramid, with `V_SAMPLES`
  vertical sub-samples for the foreshortening, so blades are sharp at the front and soften toward the back.
- **Stripes**: `STRIPE_M` m wide, +/-`STRIPE_AMOUNT`, converging on the vanishing point.
- **Lighting**: the stock floor's luminance, heavily blurred to drop the concrete grain, scales the grass. The
  spotlight pool stays where it was.
- **Fade**: the top `FADE` of the image fades to transparent (smoothstep, `FADE_POWER`), so the grass dissolves
  into the backdrop instead of stopping at the grid row's edge. The colour is premultiplied by the alpha, so the
  fade is smooth whether Noesis blends it as premultiplied or straight (straight just fades a little darker).

Both sources come from the pack.py backup when the floor is already installed, so a reinstall still starts
from stock.

## Files

| File | What |
|---|---|
| `make_floor.py` | builds `textures/<hash>_floor_image.dds` and `resources/menu-grass-floor/preview.png` |
| `textures/14e25d07e8204022_floor_image.dds` | generated (DDS is git-ignored); installed by `tools/texture_mods.py` |

`install_revamp.py` runs `make_floor.py` in its textures step (it needs texconv), then `texture_mods.py apply`
installs it.
