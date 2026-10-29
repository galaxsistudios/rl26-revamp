#!/usr/bin/env python3
"""
make_atlas.py - draw the pitch line numbers (0-4 and the direction arrow) in
a new font, as the fieldmarkings_numbers_col atlas install.py ships.

The numbers are not text: the field lines model (fields/default/lines and its
_flipped twin) places 48 quads on the grass, each showing one cell of a
2048x2048 BC7 atlas. Cell rectangles below are the model's UVs (identical in
both models). Rows are counted from the top of the UPRIGHT image; the shipped
texture is that image flipped vertically, like the sponsor decals.

    row 0: unused       row 1: 3 4 >       row 2: 0 1 2

Each new digit is centred where the stock digit was and drawn at the stock
digit's height (~526 px), so two-digit pairs keep their spacing and the
numbers stay the same size on the pitch. The colour channels are the stock
flat grey (the shader lights it); only the alpha carries the glyph, roughened
a little so it reads as paint on grass. The arrow comes from
resources/field-markings/arrows/default.png.

The output PNG is committed (resources/field-numbers/), so installs don't
need the font. Rerun this only to change the font:

    python mods/field-numbers-font/make_atlas.py
    python mods/field-numbers-font/make_atlas.py --font path/to/other.otf
"""

import argparse
import glob
import os

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont
from scipy import ndimage

MOD_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(os.path.dirname(MOD_DIR))
OUT = os.path.join(REPO_ROOT, "resources", "field-numbers", "fieldmarkings_numbers_col.png")

SIZE = 2048
GREY = 140          # stock RGB is a flat ~134-144 grey
GLYPH_H = 526       # stock digit height in px
SS = 4              # supersampling for the glyph masks

# glyph -> (u0, u1, v0, v1) from the model UVs, v in storage order, and the
# stock glyph's centre within its cell (px, upright).
CELLS = {
    "0": ((0.045, 0.281, 0.667, 1.000), (246, 344)),
    "1": ((0.424, 0.606, 0.667, 1.000), (144, 347)),
    "2": ((0.722, 0.954, 0.667, 1.000), (222, 342)),
    "3": ((0.052, 0.286, 0.333, 0.667), (224, 345)),
    "4": ((0.374, 0.625, 0.333, 0.667), (246, 348)),
}
ARROW = ((0.761, 0.902, 0.398, 0.602), 208)  # cell, stock centre y
# The arrow quad's left edge (cell x 0) touches its number on the pitch and
# the tip (right) points at the try line; 1 px = 2.46 mm. Stock: 384 px tall,
# 71 px from the number edge.
ARROW_H = 326
ARROW_GAP = 70
# Arrow art, drawn pointing DOWN; turned to point right like the stock '>'
# (the field quads mirror it so each arrow points at the nearer try line).
ARROW_ART = os.path.join(REPO_ROOT, "resources", "field-markings", "arrows", "default.png")

FONT_GLOBS = ["*Rigid_Square_Bold.otf", "*rigid-square-bold.otf"]


def find_font():
    dirs = [os.path.expandvars(r"%LOCALAPPDATA%\Microsoft\Windows\Fonts"), r"C:\Windows\Fonts"]
    for d in dirs:
        for g in FONT_GLOBS:
            hits = sorted(glob.glob(os.path.join(d, g)))
            if hits:
                return hits[0]
    raise SystemExit("Rigid Square Bold not found in the Windows font folders - pass --font")


def cell_box(uv):
    """Upright pixel box (x0, y0, x1, y1) of a cell from its storage-order UVs."""
    u0, u1, v0, v1 = uv
    return round(u0 * SIZE), round((1 - v1) * SIZE), round(u1 * SIZE), round((1 - v0) * SIZE)


def glyph_mask(font_path, ch, height):
    """Antialiased mask of ch cropped to its ink, scaled to `height` px tall."""
    font = ImageFont.truetype(font_path, 400 * SS)
    l, t, r, b = font.getbbox(ch)
    im = Image.new("L", (r - l + 8, b - t + 8), 0)
    ImageDraw.Draw(im).text((4 - l, 4 - t), ch, font=font, fill=255)
    im = im.crop(im.getbbox())
    w = round(im.width * height / im.height)
    return im.resize((w, height), Image.LANCZOS)


def arrow_mask(path, height, max_w):
    """ARROW_ART's alpha turned to point right, `height` px tall (narrower if
    it would exceed max_w)."""
    im = Image.open(path).convert("RGBA").getchannel("A")
    im = im.crop(im.getbbox()).transpose(Image.ROTATE_90)  # down -> right
    w = round(im.width * height / im.height)
    if w > max_w:
        w, height = max_w, round(im.height * max_w / im.width)
    return im.resize((w, height), Image.LANCZOS)


def paint_wear(alpha, seed):
    """Rough the edges and thin the paint slightly, like the stock lettering."""
    rng = np.random.default_rng(seed)
    a = alpha.astype(np.float32) / 255
    # edge: displace the threshold with fine noise
    n = ndimage.gaussian_filter(rng.standard_normal(a.shape).astype(np.float32), 1.5)
    n /= n.std() + 1e-6
    soft = ndimage.gaussian_filter(a, 2.0)
    edge = np.clip((soft - 0.5 + 0.08 * n) * 6 + 0.5, 0, 1)
    # body: faint blotchy coverage, ~0.9-1.0
    body = ndimage.gaussian_filter(rng.standard_normal(a.shape).astype(np.float32), 6)
    body = 0.95 + 0.05 * np.clip(body / (body.std() + 1e-6), -1, 1)
    return (edge * body * 255).round().astype(np.uint8)


def build(font_path, arrow_path):
    alpha = Image.new("L", (SIZE, SIZE), 0)
    for i, (ch, (uv, (cx, cy))) in enumerate(CELLS.items()):
        x0, y0, x1, y1 = cell_box(uv)
        g = glyph_mask(font_path, ch, GLYPH_H)
        room = (x1 - x0) - 2 * 24
        if g.width > room:  # too wide for its quad: shrink to fit, keep aspect
            g = g.resize((room, round(g.height * room / g.width)), Image.LANCZOS)
        gx = min(max(x0 + cx - g.width // 2, x0 + 24), x1 - 24 - g.width)
        alpha.paste(g, (gx, y0 + cy - g.height // 2))
    uv, cy = ARROW
    x0, y0, x1, y1 = cell_box(uv)
    g = arrow_mask(arrow_path, ARROW_H, (x1 - x0) - ARROW_GAP - 16)
    alpha.paste(g, (x0 + ARROW_GAP, y0 + cy - g.height // 2))

    a = paint_wear(np.array(alpha), seed=26)
    rgba = np.empty((SIZE, SIZE, 4), np.uint8)
    rgba[..., :3] = GREY
    rgba[..., 3] = a
    return Image.fromarray(rgba, "RGBA")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--font", help="font file (default: Rigid Square Bold from the Windows font folders)")
    ap.add_argument("--arrow", default=ARROW_ART, help="arrow art pointing down (default: %(default)s)")
    ap.add_argument("--out", default=OUT)
    args = ap.parse_args()
    font = args.font or find_font()
    im = build(font, args.arrow)
    os.makedirs(os.path.dirname(args.out), exist_ok=True)
    im.save(args.out, optimize=True)
    preview = Image.new("RGB", im.size, (38, 92, 40))
    preview.paste(Image.new("RGB", im.size, (235, 235, 235)), mask=im.getchannel("A"))
    preview.resize((1024, 1024), Image.LANCZOS).save(os.path.splitext(args.out)[0] + "_preview.png")
    print(f"wrote {args.out} ({os.path.basename(font)})")


if __name__ == "__main__":
    main()
