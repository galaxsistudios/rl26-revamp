# las-vegas-stadium

Gives Allegiant Stadium (`lasVegasStadium`) an NFL-style look, and adds a
"Rugby League Las Vegas" field markings option.

At Allegiant Stadium only:

- **Mustard goal posts.** The uprights and crossbar are retextured mustard
  yellow. The pads keep the stadium's stock Fiji Airways art.
- **Black in-goals.** Both in-goals are painted black. The paint stops just
  inside the try line, dead-ball line and touchlines, so every line stays
  visible. Sponsor banners from any field markings still draw on top.

- **Vegas cloth wrap.** The grey draped cloth along the foot of the stands
  becomes a black Rugby League Las Vegas wrap: gold line arrows, the logo and
  wordmark, Telstra and JD (`boards.build_cloth`).
  - The cloth is material `tarpA_ATP250in_SSAO` in `stadium_t1.model`. Its
    `col_map` `tarpa_atp250in_col` was a flat grey (46); the swag folds come
    from its normal map, which is kept, so the logos sit on the folds.
  - `stadium_model.py` re-maps the cloth's UVs in `stadium_t1.model` (see
    **Stadium model** below), so the texture spans the cloth's height once
    and one tile is 4× that height along the wall.
  - It's BC1-encoded with 11 mips, the same size as stock, and replaced in
    place in Allegiant's `stadium_t1.texpack` (a shipped entry, with a pack.py
    backup).
  - The same material also covers a large upper-tier curtain.

- **Vegas board wrap.** The tall dark boards around the field, the strips
  under the cloth and the tunnel walls carry the same wrap as the cloth.
  - Most of them were the matrix material `fabric_screen01_matrix_SSAO`.
    Replacement art never showed through its colour matrix in-game, whatever
    Lua set the matrix to.
  - So `stadium_model.py` switches those submeshes to the cloth's material,
    which uses its `col_map` directly.
  - On the 2.6 m boards the art covers the part above the 1.2 m LED boards
    (`LED_TOP` = 1.3 m).
  - The cloth's normal map is replaced with a flat one, so cloth and boards
    read as tight printed wraps.

- **Stadium model** (`stadium_model.py`, a shipped entry with a pack.py
  backup). The stock UV0 was inconsistent: one whole side of the cloth and a
  tunnel wall ran backwards, which mirrored the text, and the boards tiled
  the texture about 16× vertically. Every cloth, board and tunnel-wall piece
  now gets a fresh planar mapping, per connected component:
  - u runs along the wall to the right of a viewer facing it, so the text
    is never mirrored.
  - One tile is 4× (cloth) or 3× (boards) the piece's height.
  - v runs from the top edge (0) to the bottom (−1).
  - Strips under 0.5 m tall are mapped to plain black.
  - The layout notes are in the module's docstring. Vertex group 2 is its
    own interleaved buffer, indexed directly by `vtxStart`.
- **LED boards** show the game's own default NRL LED ads. At Allegiant the
  default LED texture (`lcd_sponsor_rugby_generic_col`) ships blank, so the
  boards rendered black.
  - `install.py` copies `lcd_sponsor_nrl_col` byte for byte into Allegiant's
    `sponsors_standard_t1.texpack` under the generic member's path. It's the
    same file at every NRL ground: 2048×1024 DXT1, eight cycling rows of
    Telstra, Hostplus, Kia and KFC.
  - This is a shipped entry, with a pack.py backup.

- **KFC banners baked into the black in-goals.** The field markings' in-goal
  KFC banners were a second coplanar decal on top of the black and
  flickered. The in-goal texture now has them painted in
  (`install.baked_banners`): every triangle of the stock NRL banner strip
  (the Monday model the in-goal layer is cloned from) is warped into the
  in-goal rectangle's UV space. Where the field markings still draw their own
  banners, they land on identical art in the identical place. The in-goal
  quads sit 1 cm below the banners, in the sponsor decal pass.

At any ground:

- **"Rugby League Las Vegas" field markings** (Play Now → Match Settings →
  Field Markings). This is a round in nrl-field-sponsor-markings' config
  ([rounds/lasvegas.json](../nrl-field-sponsor-markings/config/rounds/lasvegas.json)),
  built by its `fieldmarkings.py`. It has the NRL logo on one side of
  halfway and the Rugby League Las Vegas logo opposite, plus the four
  Telstra/KFC squares. There are no in-goal panels.
  - At Allegiant, `stadiumfactory.lua` forces this round, whatever was picked
    (`grass.fieldRoundOverride = "lasvegas"`), so nothing draws over the
    black in-goals.
  - This option reuses the unused `NRL_Season_Wednesday` value (there is no
    Las Vegas value), so the match counts as a Wednesday game.

## How it works

| Part | File |
|---|---|
| Mustard uprights at lasVegasStadium: `goalposts01_mustard_col` on the `goalPosts_SS` material of `fieldposts/goalpostsN/S` | `src/.../rendering/props/fieldposts.lua` |
| Extra grass decal layers. The grass's `dispose()` frees them | `src/.../rendering/stadium/stadiumfactory.lua` |

The in-goal layer needed three changes after the first in-game test:

- **Too faint.** The sponsor shader turns its `detail_map` into coverage
  between `g_fieldMarkings_minAlpha` 0.2 and `maxAlpha` 0.8. The stock map is
  dark grass noise (RGB mean about 30), so the black only tinted the grass.
  The in-goal now uses an appended solid-white
  `sponsor_alphadetail_solid_col`, which gives 0.8 coverage.
- **Still not black enough.** The layer is drawn twice, which raises coverage
  to about 96%.
- **Flicker.** In the sponsor pass the in-goal was coplanar with the sponsor
  models' KFC in-goal banners, and the two flickered over each other. It now
  goes in the field-lines decal pass (`fieldDecals`) instead.

| New assets (appended entries) | `install.py` |

`goalpost.model` has three materials: `goalPosts_SS` (white uprights, a flat
16×16 `goalposts01_white_col`), `goalPosts_black_SS` and `goalPads_SS`. Stock
`fieldposts.lua` only swaps the pads texture, and Allegiant already gets
`goalpost_lasvegas_col` for them.

Every appended asset is new. No shipped file is changed:

| Path | What it is |
|---|---|
| `props/goalposts/textures/goalposts01_mustard_col.texture` | 16×16 BGRA, RGB (225, 170, 20) |
| `fields/default/sponsor_field_lasvegasingoal[_flipped].model` + `.texpack` | Clone of the stock Monday model. Each in-goal banner strip becomes one rectangle covering x 50.17–57.93 and z ±33.93, textured near-black (14, 14, 14). The other meshes are collapsed |

Notes:

- **Bundle path.** A sponsor model's texture bundle is
  `<model path without .model>.texpack`. The stock Monday bundle's hash
  matches that path.
- **Unique names.** The clones get same-length new model names
  (`lasvegasingoal`), which also renames their
  material paths. Their texture names are new too. This stops a path-keyed
  cache from sharing a material or texture with a shipped sponsor model drawn
  at the same time.
- **Line positions.** These come from `fields/default/lines`: the try line is
  at x 49.95–50.15, the dead-ball line at 57.95–58.15, and the touchlines at
  z ±33.95–34.15.

## Install (game closed)

```powershell
python mods\las-vegas-stadium\install.py install --confirm [--texconv PATH\texconv.exe]
python tools\build.py full --confirm      # script bundle (both Lua files + the label)
```

Notes:

- `install.py` reads the stock Monday and Thursday models and bundles from
  pack.py's backups when nrl-field-sponsor-markings has replaced them.
- Re-running it replaces the appended entries in place.
- It needs texconv (BC7) and resvg-py, the same as nrl-field-sponsor-markings.
- `install_revamp.py` runs it in the `textures` step.
- The Lua loads these assets by path. Without them, a match at Allegiant
  Stadium or with the Las Vegas markings would abort, so don't build this
  mod's Lua without running the asset install.

To remove the mod, delete it from `mods/` and rebuild the script bundle. The
appended entries are then unused. `add_entries.py remove-all` drops every
appended entry.

Status:

- Mustard posts: confirmed in-game.
- In-goal fix (opacity and flicker): installed, not yet checked.
- Cloth and board wraps show in-game. The UV re-map (mirroring, aspect,
  tunnel walls) is installed but not yet checked.
