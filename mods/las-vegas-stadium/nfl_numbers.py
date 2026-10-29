"""
nfl_numbers.py - Allegiant Stadium's NFL-style pitch numbers: the 0-4 digits
in the Revamp's field-numbers font (Rigid Square Bold), plain white (the red
outline tried first wasn't wanted), plus a long thin arrow (install.py stretches the arrow quads 3x along
the pitch in its clone of the lines model, so the slim triangle drawn in the
stock arrow cell comes out ~2.1 m long).

Uses mods/field-numbers-font/make_atlas.py's cell layout, glyph and wear
helpers. Colours: fill = the white pitch lines' paint (fieldlines01_col ink
~173), outline = the red lines' paint (fieldlines01_red_col ink 132, 21, 21).
Returns the UPRIGHT 2048x2048 RGBA atlas (install.py flips and BC7-encodes it).
"""

import importlib.util
import os

import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage

MOD_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(os.path.dirname(MOD_DIR))
_spec = importlib.util.spec_from_file_location(
    "field_numbers_atlas", os.path.join(REPO_ROOT, "mods", "field-numbers-font", "make_atlas.py"))
fa = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(fa)

FILL = (173, 175, 173)
OUTLINE = (132, 21, 21)
OUTLINE_PX = 0                  # red outline off (was 26 px, ~6.4 cm)
ARROW_GAP = 20                  # px from the number edge, before the 3x stretch
ARROW_HALF = 70                 # px half-thickness at the base (~0.34 m wide)


def build(font_path=None):
    font_path = font_path or fa.find_font()
    fill = Image.new("L", (fa.SIZE, fa.SIZE), 0)
    glyph_h = fa.GLYPH_H - 2 * OUTLINE_PX       # room for the outline
    for ch, (uv, (cx, cy)) in fa.CELLS.items():
        x0, y0, x1, y1 = fa.cell_box(uv)
        g = fa.glyph_mask(font_path, ch, glyph_h)
        room = (x1 - x0) - 2 * (24 + OUTLINE_PX)
        if g.width > room:
            g = g.resize((room, round(g.height * room / g.width)), Image.LANCZOS)
        m = 24 + OUTLINE_PX
        gx = min(max(x0 + cx - g.width // 2, x0 + m), x1 - m - g.width)
        fill.paste(g, (gx, y0 + cy - g.height // 2))
    uv, cy = fa.ARROW
    x0, y0, x1, y1 = fa.cell_box(uv)
    yc = y0 + cy
    tri = [(x0 + ARROW_GAP + OUTLINE_PX, yc - ARROW_HALF), (x1 - OUTLINE_PX - 6, yc),
           (x0 + ARROW_GAP + OUTLINE_PX, yc + ARROW_HALF)]
    ImageDraw.Draw(fill).polygon(tri, fill=255)

    f = np.array(fill, np.float32) / 255
    yy, xx = np.mgrid[-OUTLINE_PX:OUTLINE_PX + 1, -OUTLINE_PX:OUTLINE_PX + 1]
    disk = (xx * xx + yy * yy) <= OUTLINE_PX * OUTLINE_PX
    outer = ndimage.grey_dilation(f, footprint=disk)
    alpha = fa.paint_wear((outer * 255).astype(np.uint8), seed=88)
    rgba = np.empty((fa.SIZE, fa.SIZE, 4), np.uint8)
    # 1 inside the glyph, 0 in the outline ring; with no outline, all fill
    # (else the antialiased edges would blend towards the outline colour)
    w = f[..., None] if OUTLINE_PX else np.ones_like(f)[..., None]
    rgba[..., :3] = (w * np.array(FILL) + (1 - w) * np.array(OUTLINE)).round().astype(np.uint8)
    rgba[..., 3] = alpha
    return Image.fromarray(rgba, "RGBA")


if __name__ == "__main__":
    out = os.path.join(REPO_ROOT, "_build", "las-vegas-stadium")
    os.makedirs(out, exist_ok=True)
    im = build()
    im.save(os.path.join(out, "nfl_numbers.png"))
    bg = Image.new("RGB", im.size, (38, 92, 40))
    bg.paste(im.convert("RGB"), mask=im.getchannel("A"))
    bg.resize((1024, 1024), Image.LANCZOS).save(os.path.join(out, "nfl_numbers_preview.png"))
    print(out)
