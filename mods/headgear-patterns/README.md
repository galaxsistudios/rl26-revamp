# headgear-patterns

New headgear designs as extra helmet items. The first one is the white **lightning** print on the
Steeden headgear Jahrome Hughes wears, and Hughes (player 211) now wears it in dark purple and white.

| Helmet | Shell | For |
|---|---|---|
| 102 | adidas01 layout | Jahrome Hughes. His scanned fitted headgear (`jahromeHughes_211_headwear`) is an adidas01 copy, so its texture has to be on that layout. |
| 103 | Madison Air Flo layout | Anyone. Its segmented pads look the most like the Steeden. |

Both are marked `academy`, so they show up in the Academy headgear picker for any player.
Colour 1 tints the shell, colour 3 the edging and colour 4 the straps. The lightning is always white
(`patternTint` in the `HeadgearPatterns` block), so the colour 2 picker does nothing on these helmets.

## How it works

A helmet's col texture is a four-channel tint mask (see
[resources/headgear-templates](../../resources/headgear-templates/README.md)). Each pattern is the stock
custom01 mask with a new G channel, the same way Kalyn Ponga's helmet 101 works.
[make_patterns.py](make_patterns.py) draws the lightning procedurally: branching random-walk bolts
with a fixed seed, drawn only on the outer shell (off the trim, straps, vent holes and inner liner).
It also writes the flat and 3D previews in `textures/`.

| Part | Where | Installed by |
|---|---|---|
| masks `characters/helmets/textures/helmet_<layout>_lightning_col_{1,2,3}` (2048/1024/512) | appended blobset entries | `install.py install` (install_revamp step `headgear`) |
| the same names in `characters/player/global.texsrc` | live entry + records appended | `install.py texsrc` (install_revamp step `texsrc`) |
| items 102/103, copies of stock 1 / 100 with the new colTexture. The colTexture names are also added to `helmet_col`; without that the game drops the tint layer and no pattern shows (first test, 2026-10-29) | `HeadgearPatterns` block in [jesse-southwell-hair's assetmap.lua](../jesse-southwell-hair/src/script-game/design/characters/assetmap.lua). That file owns the headgear rules. The block also adds the guids to `var_0_headgearGuids`, so scanned heads keep their fitted mesh. | `build.py` (scripts) |
| Hughes: helmet 102 + colours | `defaultdata/defaultdata_players/000211_Hughes.json` | data bundle (licenseddata) |

To add another design, add a generator to make_patterns.py, a row to `PATTERNS` in install.py and a
row to `HeadgearPatterns`. Pick a scanned player's layout by loading their `<name>_headwear` mesh.
Most scans use adidas01 or madisonAirFlo.

## Install (game closed)

```powershell
python mods\headgear-patterns\make_patterns.py      # only after changing a design
python tools\install_revamp.py --confirm --only headgear texsrc data scripts
```

Two bugs found in game testing, both fixed:
- The `helmet_col` entry was missing, so no pattern was drawn.
- The helmet came out black: the smaller texture copies (_2/_3), which the game samples in menus and matches, were resized as RGBA. That premultiplied the channels by A (the strap mask), which wiped out the shell. install.py now resizes each channel on its own.

A test copy of the stock adidas mask (`helmet_adidas01_clonetest_col_*`) is still appended to the index and global.texsrc. It's harmless.

Status: confirmed working in game 2026-10-29 (Jahrome Hughes, helmet 102).
