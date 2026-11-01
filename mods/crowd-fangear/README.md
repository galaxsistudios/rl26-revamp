# crowd-fangear

Gives every club's fans more merchandise than the one polo, cap and scarf the game ships: fan tees, polos
and scarves in the club's colours, carrying its current and classic logos and its wordmark. A **Fangear
Library** in the club's Uniforms list shows what a club's crowd wears and turns each design on or off.

**Status:** generated and installed; not yet seen in game.

## What fans get

For every club icon that has a `resources/flags/<icon>/` folder (the same clubs as crowd-flags), using the
club's colours from the installed `defaultdata_clubs`:

| Item | Designs |
|---|---|
| Fan tee | plain (primary / secondary, sleeve hems in the other colour), big chest logo (primary / secondary / white), white tee with a small left-chest badge, wordmark across the chest, logo above wordmark (both colours), one tee per classic logo. The back shows the wordmark across the shoulders, or a small logo when the club has no wordmark. |
| Polo | primary, secondary and white, with a trim-coloured collar and double sleeve stripes, a left-chest badge and a small logo below the collar at the back |
| Scarf | bar scarf, inverted bar scarf, logo scarf, wordmark scarf and inverted wordmark scarf, with two-colour fringes |

Wordmarks exist for the 17 NRL clubs (nrl.com `text.svg`). Logos are chosen the same way as for the flags
(`mods/crowd-flags/default_flags.py`): the version that stands out most against the garment colour.
`resources/fangear/<icon>/preview.png` shows every design of a club rendered on the crowd meshes (front and
back), and `resources/fangear/fangear_sheet.png` shows all clubs.

## Design sheets

Designs aren't painted in texture space. Each one is a **sheet**: artboards showing the garment as you'd
see it, upright and unstretched, at 2000 px per metre. `fangear.py` bakes the sheet onto the crowd model's
own UV layout. Templates are in `resources/fangear/templates/` (see the README there).

- **Tops** (tee and polo, 2260 x 1380): front (as seen from the pitch), back (as seen from behind), sleeves
  (hem at the bottom) and collar (polo only).
- **Scarves** (1300 x 740): one hanging end (fringe at the bottom; both ends get it) and the neck band.

The bake works from the models (`m_crowd_clothing_tshirt`, `m_crowd_clothing_shortSleeve`,
`m_crowd_scarf01`, LOD 0). Front and back texels go through their triangles' 3D positions, so the art lands
where the sheet puts it on the body. Sleeves, collar and scarf go through their UVs. Women fans use the same
textures on their own meshes, which are close enough. Texture layouts are in `fangear.py`'s docstring.

Sheets are `resources/fangear/<icon>/<item>_<variant>.png`. To add a design, save a sheet with that name
(`tee_`, `polo_` or `scarf_`) and reinstall. Generated designs take their library label from
`fangear.json`; hand-made ones from the file name (`tee_heritage_1908.png` becomes "Heritage 1908 Tee").

## Finished textures

Each club's finished textures sit beside its sheets: `resources/fangear/<icon>/dds/<item>_<variant>.dds`,
the exact DDS bytes the installer writes (1024² DXT1 with mips for tops, 512² for scarves). `dds/keys.json`
holds each one's key: a hash of its sheet plus `BAKE_VERSION`. `bake` and `install` reuse a stored DDS whose
key still matches. They only bake sheets that are new or edited, and drop DDS whose sheet is gone. Bump
`BAKE_VERSION` in `fangear.py` when the bake itself changes; `bake --force` re-bakes everything.
`install --confirm` also skips entries whose appended blob is already byte-identical, so a reinstall only
rewrites what changed. Like the rest of `resources/`, the DDS files are git-ignored. The release ships the
sheets, and the user's installer bakes them.

## In the game

- **Textures:** each sheet becomes `crowd/characters/textures/crowd_fan_<item>_<icon>_<variant>_col`
  (tops 1024 x 1024 DXT1, scarves 512 x 512, with mips, the stock sizes), as appended entries. Like every
  crowd texture, it must also be in the crowd texture table (entry 39871). crowd-team-kits'
  `bake_crowd_jerseys.py register` re-adds all appended crowd textures, fangear included.
- **Library table:** `intermediatelua/crowd/crowd_items.lua` is the stock file plus a generated block:
  `FangearClubs` (club id → icon) and `FangearLibrary` (icon → item, label, texture). No other mod
  overrides that file. The crowd config imports it, and so does the front end.
- **Mixing:** crowd-team-kits' `crowd_item_config.lua` adds each club's enabled designs to its lists at
  every match load. Team tags are per fan, so the gear shows only on that club's fans. How much goes in is
  the **Crowd Variance** setting (below). When a club has more designs than slots, each match shows a
  different random selection. The lists are rebuilt from the pre-fangear ones every load, so settings and
  toggles apply at the next match. Each load logs a `crowd-fangear: crowd variance ...` line to
  `crowdteamkits_debug.txt`.
- **Crowd Variance** (Settings → Graphics, under Crowd Capacity; this mod overrides `setting_groups.lua`
  and `settings_generalstate_graphics.lua`). Every list holds at most 16 entries per team, and every
  distinct texture in them is loaded for the match, so higher variance needs more video memory:

  | Level | Jerseys (t-shirt list) | Fan tees | Polos / scarves | Extra texture memory per match (rough) |
  |---|---|---|---|---|
  | Low | cut to 8 entries (stock size) | none | stock ×2 + up to 3 designs | ~0–10 MB |
  | Standard (default) | 10–16 entries | up to 6 of the 16 jersey entries | stock ×2 + designs, up to 16 | ~10–20 MB |
  | High | all 16 (every legacy/special kit fits again) | own top item, 16 more | stock ×2 + designs, up to 16 | ~60–70 MB |

  On High, `m_crowd_clothing_fantee` / `f_crowd_clothing_fantee` (copies of the crowd t-shirt items) take
  `FANTEE_SHARE` of fans' tops: about 15% of men and 20% of women. A club without fan tees wears its
  jerseys through them. The setting is saved as `crowd_variance = low|standard|high` in `rl26_revamp.ini`
  in the game folder; the file's other lines are kept. Tops weights (Souths guy, fan tees) are rebuilt
  from the shipped weights every load, keyed by the tops table. The Grand Final archetypes share it, which
  previously double-counted the Souths guy item.
- **Fangear Library** (copy-academy-jerseys, club → Uniforms → FANGEAR LIBRARY (n)): rows grouped into fan
  tees, polos and scarves, each with ON/OFF. Pressing a row switches it. The designs that are off are saved
  to `rl26_revamp_fangear.txt` in the game folder, one texture per line; delete the file to turn everything
  back on. A row can't show the design itself: the Uniforms preview is the 3D player model, which can't wear
  crowd textures. The `preview.png` sheets are the picture reference.

## Install (game closed)

```powershell
python mods\crowd-fangear\fangear.py designs                     # regenerate the default sheets (optional)
python mods\crowd-fangear\fangear.py bake                        # finished DDS into resources/fangear/<icon>/dds (optional)
python mods\crowd-fangear\fangear.py install                     # dry run
python mods\crowd-fangear\fangear.py install --confirm
python mods\crowd-team-kits\bake_crowd_jerseys.py register --confirm
python tools\pack.py restore --entry scripts
python tools\build.py full --confirm
```

`install_revamp.py` runs `install --confirm` in its crowd step, before `register`.

Other commands: `templates [--icon nrl_broncos]` rebuilds the PSD templates, and `preview [icon ...]`
re-renders previews after hand edits.

## Caveats

- Not tested in game yet. If a match load aborts after installing, check that `register` ran: a crowd texture
  missing from entry 39871 aborts the load (`0xC0000409`).
- Caps and beanies aren't covered yet: their UV layouts haven't been mapped.
- User-made academy clubs have their own icons and get no fangear.
