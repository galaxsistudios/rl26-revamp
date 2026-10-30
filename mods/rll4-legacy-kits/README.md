# rll4-legacy-kits

Adds 323 older kits to RL26 clubs:

- **80 from RLL4 kit mods** in `resources/old-jerseys/`: 2021-2024 home/away/alternate sets, plus
  ANZAC, Indigenous, City, Heritage, Pride and Community kits, for the 17 current NRL clubs
  (ids 118-134) and the State of Origin sides (Queensland 18, New South Wales 19).
- **243 from the installed Rugby League Live 4 itself** (`add-rll4`, below), all 2017:
  - NRL home/away/ANZAC/Indigenous/heritage/Nines/clash/Women in League kits, plus the Holden
    Cup kits as `U20 HOME/AWAY 2017`, on clubs 118-133;
  - NSW Cup and QLD Cup clubs;
  - Super League, Championship and League 1 clubs;
  - Origin, Indigenous All Stars and the men's World Cup sides.

Each source is a single texture in RLL4's layout, with shirt, shorts and socks together. The
conversion to RL26's three separate textures is done through the 3D meshes, not by cutting up
the image.
[build_kits.py](build_kits.py)'s docstring explains how. The kit list (source file → club,
kit name, design guid) is [kits.json](kits.json).

## Pieces

| Part | Where | Installed by |
|---|---|---|
| 6 textures per kit (`characters/uniforms/textures/m_{top,shorts,socks}_<club>_rll4_<kit>_col_{1,2}`) | appended blobset entries | `build_kits.py install` |
| every new texture name registered in `characters/player/global.texsrc` (entry 31558; the compositor draws unlisted source textures as black) | replaced entry, backed up | `build_kits.py texsrc` |
| design items (guid 60001-60080 in `uniformTop` / `uniformBottom` / `uniformSocks`) | `src/script-game/intermediatelua/data/jigglyjointsconfig.lua` (generated) | `build.py` (entry 39959) |
| kit slots on clubs 118-134, 18 and 19 (`uniforms.add`, copying HOME or AWAY for number/name styling) | `defaultdata/defaultdata_clubs/*.json` (generated) | `build.py` (entry 39957) |

The new kit names (e.g. `HOME 2024`) only show up with [unlock-all-kits](../unlock-all-kits/)
applied, because the exe drops any kit whose name isn't on its built-in list.

Design items copy the Broncos' 2026 home items (guid 105 top, 104 shorts, 104 socks). Those use
the `top_round05` / `shorts01` / `socks01` models, which are the meshes the textures are baked for.
Each new kit copies whichever of the club's HOME or AWAY kit has the number colour that stands out
more against the new jersey's back. Referee clash colours are guessed from the jersey's colours.

## Build and install (game closed)

```powershell
# 0. (once) add the installed RLL4's own kits to kits.json
python mods\rll4-legacy-kits\build_kits.py add-rll4

# 1. textures + previews (into _build\rll4-legacy-kits; first run caches the mesh mapping)
python mods\rll4-legacy-kits\build_kits.py bake
python mods\rll4-legacy-kits\build_kits.py sheet            # _build\rll4-legacy-kits\sheet.png

# 2. regenerate the Lua + club overrides (needs a STOCK clubs file)
python tools\extract_m3mp.py --entry licenseddata --out <tmp>\39957   # or decode _backup\entry_39957.blob.bak
python mods\rll4-legacy-kits\build_kits.py generate --clubs <tmp>\39957\defaultdata\defaultdata_clubs

# 3. append the textures (6 per kit) (--replace re-writes ones added before)
python mods\rll4-legacy-kits\build_kits.py install --confirm

# 3b. register them in the compositor's texture table (entry 31558)
python mods\rll4-legacy-kits\build_kits.py texsrc --confirm

# 4. rebuild the script and clubs bundles
python tools\pack.py restore --entry scripts
python tools\build.py full --confirm
python tools\pack.py restore --entry licenseddata
python tools\build.py full --list manifests\licenseddata.xml --extracted <tmp>\39957 --out _build\licenseddata.m3mp --confirm
```

Undo: remove this folder, `pack.py restore --entry global-texsrc`, rebuild 39959 and 39957, and `add_entries.py remove-all` (that also
removes every other appended entry, so re-add the other mods' entries afterwards).

## Kits from the installed RLL4

`python mods\rll4-legacy-kits\build_kits.py add-rll4` finds RLL4 through Steam (or `--rll4 <folder>`
/ `RLL4_DIR`) and appends a `kits.json` row with `"rll4": "<texture>"` for every RLL4 kit texture
([rll4_game_kits.json](rll4_game_kits.json) maps to a club: `characters/uniforms/textures/<team
prefix>_<kit>_col`). Rows already in `kits.json` are kept, so it's safe to re-run. `bake` then
reads those textures straight from the game (`tools/rll4_source.py`), so RLL4's kits never ship
with the mod. Skipped:

- referee and cheerleader kits;
- the women's sides (the bake is male-only);
- RLL4 teams RL26 doesn't have, e.g. Wyong, Mounties, Wentworthville, Coventry, Oxford,
  Toronto, and the smaller nations.

The NSW Cup kits land on RL26's NSW Cup clubs, which only show up with the NSW Cup unhide mods.
Featherstone has no current-season club in RL26, so its kits go on "Featherstone Rovers 2025"
(91).

## Adding more kits

Drop the RLL4 texture in `resources/old-jerseys/`, add a row to `kits.json` (next free guid,
club id, a name of at most 24 characters, a unique `texture` slug), then run steps 1-4 above
(`bake --only <slug>` is enough for step 1).

Git keeps these jerseys as lossless PNGs next to the `.dds` originals. `*.dds` is ignored, and the 78
PNGs total about 44 MB against 594 MB of DDS. `build_kits.py` reads `<name>.png` when it exists and
the `src` file otherwise, so `kits.json` can keep naming the `.dds`. After adding a DDS, save a PNG
copy too (`Image.open(dds).save(png)`), or a fresh checkout can't bake it. The release ships the PNGs
only.

## Custom kits (painted on the jersey templates)

Kits painted on the templates in `resources/jersey-templates/` (`tools/jersey_template.py`) are
already in RL26's layout, so they skip the RLL4 conversion. Put `top.png`, `shorts.png` and
`socks.png` in `resources/custom-kits/<kit-name>/`, then add a row with `custom` in place of
`src`:

```json
{"guid": 64001, "custom": "<kit-name>", "club": 118, "name": "CUSTOM 2026", "texture": "broncos_custom_2026"}
```

A row may also have `"templates": {"uniformTop": g, "uniformBottom": g, "uniformSocks": g}`: the
design items the new items copy (model, UVs, material). It defaults to the Broncos 2026 home items
(top 105 = `top_round05`, shorts and socks 104). `tools/fanhub_kit_import.py` sets it to the
exported design's items for kits captured in game (copy-academy-jerseys, LB in a Uniforms list).
A copied Academy top loses its collar tint layer and its Academy flag, because the captured
texture already has the collar colours. `bake`'s preview and number-area sample still use the
default meshes.

Kits designed in code (photos -> layers + real sponsor logos + an editable `kit.psd`) are made with
[tools/kit_studio.py](../../tools/kit_studio.py), which keeps their row here in step with the kit's
`kit.json` (`kit_studio.py install <kit>`). See
[resources/custom-kits/RULES.md](../../resources/custom-kits/RULES.md).

`"numberFrom": g` takes the number and name placement (`numberOffset`, `nameOffset`) from top item
`g` instead of the top template. Use it when a kit borrows another team's model but should keep
its club's number layout, e.g. the Dolphins HOME 2027 on England's `top_flat01` (7020) with
`"numberFrom": 185` (Dolphins 2026 home).

`bake` and `install` skip kits that haven't changed. A kit's `bake.json` stamp
(`_build/rll4-legacy-kits/<texture>/`) hashes its source image and texture fields, and each texture
entry's `image_sha1` in the add_entries registry records the image it was written from. `--force`
redoes them; bump `BAKE_VERSION` in build_kits.py after changing how bakes are made. An entry missing
from the index (after a game update or Steam verify) is always written again.

A row with `"library": true` doesn't take one of the club's kit slots. The game holds at most 20 kits
per club, so it goes into the generated `KitLibrary` instead, and a player adds it from the club's
Uniforms list (copy-academy-jerseys' KIT LIBRARY). Captured and painted (`custom`) kits are added to
a club before the RLL4 ones, so they're never the kits past slot 20.

Use guids from 64001 up for custom kits, so they stay clear of the RLL4 rows. `bake` only resizes
them to the installed sizes and renders `preview.png` on the RL26 meshes. It doesn't need RLL4 or
the cached texel map. Every other step (install, texsrc, generate, the bundles) is the same as for
the other kits, and the installer's `kits` step picks the rows up automatically.
`tools/package_revamp.py` ships `resources/custom-kits/` with the release.

## Known gaps

- Male models only (`top_round05` m, `shorts01` m). The women's clubs don't get these kits.
- RLL4's sleeves are short cap sleeves, so the underside of RL26's longer sleeves takes the
  nearest shirt colour, and thin RLL4 cuff trims mostly disappear.
- RL26's collar is taller than RLL4's neckline, so it takes the neckline's colour.
- `holden_sharks_away_col.pc.dds` is actually the Sea Eagles' 2022 Pride jersey (TripADeal,
  PointsBet, KFC, URM sponsors), so it's added to Manly as `PRIDE 2022`.
