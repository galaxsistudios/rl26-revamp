"""
design.py - Roosters 2026 heritage kit (navy, a red/white/red V yoke front and
back, white rugby collar and cuffs), painted by code on the top_vneck02 shirt
(the user's pick of "Manufacturer" for this kit in game: cut #79 = item 7100,
PNG's World Cup shirt with the collar and V placket).

Measured from the user's photos (photos/user_front_player.png,
user_back_player.png; on a player, so used for measuring only). Front and
back are the same three nested chevrons running over the shoulders, all at
slope ~1.25 (texture px down per px across): inner red from the neck, then
white, then the outer red, navy beyond. Photo -> texture is ~3.5 px a photo
px; the bands' half widths at the neck line come out the same on both sides
(front 323 / 505 / 642, back 346 / 525 / 620), so one set, BANDS. The front V
tips are at photo y 478 / 545 / 595 (neck 360). The back yoke is cut flat at
photo y 258 (collar 183, hem ~560). Collar and placket white (RULES.md 19: the model's
own collar), cuffs white (the PNG stock texture's black cuff and placket areas
give the exact texels on this model).

Logo sources (kit.json): the NRL rule; the club crest is the user's photo of
the heritage shirt's embroidered rooster patch (logos/rooster_patch_photo.png,
cut out along its navy border); adidas, Adapt Ovate and Reosteel from the stock
Roosters 2026 home top. The heritage-only "BYD AUTO" felt lettering has no
source artwork, so it is set in the game's own Barlow Semi Condensed ExtraBold
(heavy, rounded and condensed like the felt letters on the user's close-up;
user OK'd drawing it, 2026-11-01). Left off: the tonal sleeve marks.
"""

import os

import numpy as np
from PIL import Image
from scipy import ndimage

import kit_design as kd
import kit_photo

SLOPE = 1.25
BANDS = [("Inner red", 335, "red"), ("White V", 515, "white"), ("Outer red", 630, "red")]  # half widths at the neck
FRONT = (1645, 476)  # centre x, neck y (top_vneck02)
BACK = (535, 209)
YOKE_BOTTOM = 545  # the back yoke's flat bottom: a fifth of the way from collar to hem (photo y 258, collar 183, hem ~560)


def _masks(kit):
    P, N, covered = kit_photo.surface("top", kit.model("top"), kit.size("top"))
    H, W = covered.shape
    y, x = np.mgrid[0:H, 0:W]
    collar = kit_photo.collar_mask(P, covered)
    torso = covered & ~collar & (x < 2290)
    front = torso & (x > 1080)
    back = torso & (x <= 1080)
    stock = np.asarray(kd.stock("m_top_png_rlwc_home_26_col_1")).astype(int)
    black = (stock.max(-1) < 60) & covered
    placket = black & front & (y < 620) & (np.abs(x - FRONT[0]) < 160)
    cuff = black & (x >= 2290) & (y >= 700)
    return covered, collar, front, back, placket, cuff, x, y


def top(kit):
    covered, collar, front, back, placket, cuff, x, y = _masks(kit)
    H, W = covered.shape
    reach = np.full((H, W), -1e9, np.float32)  # how far out from the centre a texel may be and still be in the band
    for side, (cx, ny), extra in ((front, FRONT, True), (back, BACK, False)):
        d = np.abs(x - cx) + (y - ny) / SLOPE
        reach[side] = d[side]
    out = []

    def layer(name, m, colour):
        im = np.zeros((H, W, 4), np.uint8)
        im[m] = kit.colour(colour) + (255,)
        out.append((name, im))

    layer("Base (navy)", covered, "main")
    yoke_ok = front | (back & (y < YOKE_BOTTOM))
    for name, half, colour in reversed(BANDS):  # outer first, inner on top
        layer(name, yoke_ok & (reach < half), colour)
    layer("Cuffs (white)", cuff, "white")
    layer("Collar and placket (white)", collar | placket, "white")
    return out


def crest(kit):
    """The rooster patch cut out of the user's photo along its navy border."""
    a = np.asarray(Image.open(kit.file("logos/rooster_patch_photo.png")).convert("RGB"), np.float32)
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    navy = (b > r + 8) & (a.max(-1) < 110)
    lab, n = ndimage.label(ndimage.binary_closing(navy, iterations=2))
    border = lab == (np.argmax(ndimage.sum(navy, lab, range(1, n + 1))) + 1)
    shield = ndimage.binary_fill_holes(ndimage.binary_closing(border, iterations=6))
    alpha = ndimage.gaussian_filter(shield.astype(np.float32), 1.0) * 255
    im = Image.fromarray(np.dstack([a, alpha]).clip(0, 255).astype(np.uint8), "RGBA")
    return kd.trim(im)


FELT_FONT = os.path.join(kd.ROOT, "extracted", "noesis", "workspace", "fonts", "barlowsemicondensed-extrabold.ttf")


def felt_text(kit, text, height, weight=0.0):
    """White block letters like the shirt's felt BYD AUTO: Barlow Semi
    Condensed ExtraBold at `height` px cap height, strokes thickened by
    `weight` x height (0 = as the font draws them)."""
    from PIL import ImageDraw, ImageFilter, ImageFont
    font = ImageFont.truetype(FELT_FONT, int(height * 1.38))
    w = int(font.getlength(text) + height)
    im = Image.new("L", (w, int(height * 2)))
    ImageDraw.Draw(im).text((height / 2, height * 0.1), text, font=font, fill=255)
    if weight:
        im = im.filter(ImageFilter.MaxFilter(max(3, int(height * weight) | 1)))
    return kd.trim(kd.solid(im, (255, 255, 255)))


def shorts(kit):
    return [("Shorts (stock 2026 home)", kit.stock("m_shorts_roosters_nrl_home_26_col_1").resize(kit.size("shorts")))]


def socks(kit):
    return [("Socks (stock 2026 home)", kit.stock("m_socks_roosters_nrl_home_26_col_1").resize(kit.size("socks")))]
