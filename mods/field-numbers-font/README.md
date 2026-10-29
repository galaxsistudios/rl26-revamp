# field-numbers-font

Repaints the 10/20/30/40 metre numbers and their direction arrows on the
pitch in **Rigid Square Bold**.

## How the numbers are drawn

They aren't text. The field lines model `fields/default/lines` (and its
`lines_flipped` twin) places 48 quads on the grass. Each quad shows one cell
of a 2048×2048 BC7 atlas, `fields/textures/fieldmarkings_numbers_col`:

```
row 0: unused      row 1: 3  4  >      row 2: 0  1  2
```

So "40" is the 4 cell and the 0 cell side by side. The quads sit 19.1 m
either side of the long axis. The atlas is stored vertically flipped, like
the sponsor decals. Its RGB is a flat grey that the shader lights, and the
alpha carries the glyph.

Each model ships its own copy of the atlas, in its own TXPK alongside
`fieldlines01_col` / `fieldlines01_red_col`:

| Model | TXPK (v5887) |
|---|---|
| `fields/default/lines` | 39879 |
| `fields/default/lines_flipped` | 39881 |

## What it changes

- [make_atlas.py](make_atlas.py) renders the five digits from the font.
  - Each digit is centred where the stock digit was, at the stock height
    (526 px), so pairs keep their spacing and size on the pitch. A digit
    too wide for its quad is shrunk to fit.
  - The arrow is `resources/field-markings/arrows/default.png` (drawn
    pointing down), turned to point right like the stock `>`; the field
    quads mirror it per half. Its size and its gap from the number are
    `ARROW_H` / `ARROW_GAP` in make_atlas.py (1 px = 2.46 mm on the pitch).
  - Edges are roughened slightly so the numbers read as paint.
  - It writes `resources/field-numbers/fieldmarkings_numbers_col.png`. That
    file is committed, so installs don't need the font.
- [install.py](install.py) BC7-encodes that PNG (12 mips, like stock) and
  replaces only the numbers member in both TXPKs. It keeps the stock
  main/vram split (see `nrl-field-sponsor-markings`).

It is part of the Revamp install (`textures` step in
`tools/install_revamp.py`, which needs texconv).

## Rebuild / install / undo (game closed)

```powershell
python mods\field-numbers-font\make_atlas.py                  # only to change the font (--font path)
python mods\field-numbers-font\install.py restore
python mods\field-numbers-font\install.py install --confirm   # --texconv <path> if not bundled
```
