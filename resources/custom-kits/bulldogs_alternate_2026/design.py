"""
design.py - Bulldogs 2026 alternate (black) kit: the painted layers. Sponsors,
the NRL logo and the crest are in kit.json; build with
    python tools/kit_studio.py build bulldogs_alternate_2026

Base design: black body; a blue chevron yoke on the front made of V stripes,
cut off at an angle towards the armpits and flat across the bottom; plain
black sleeves with blue cuffs. Black shorts and socks with blue hoops,
recoloured from the stock 2026 home ones.

Logo sources (kit.json): logos/laundy_hotels.png (laundy.com.au,
laundy-logo-black.png); logos/bulldogs_crest_2026.png (Wikipedia File:
Canterbury-Bankstown_Bulldogs_logo_2026.svg, also the CB monogram); KFC,
Wattyl, O'Neills, Future Form, Supporting Disabilities Australia and the
product tag are keyed out of the stock Bulldogs 2026 textures.
"""

import numpy as np
from PIL import Image
from scipy import ndimage

import kit_design as kd

# Front chevron: v = (y - NECK_Y) + SLOPE * |x - CX| (UV px). Bands (v0, v1)
# that are blue; everything else in the yoke is black. Measured down the
# centre of the product shot (photo px from the neck x 1.18, slope 0.56 in
# the photo): the Future Form panel, a black band, two thin blue lines, then
# wide blue/black stripes. The V stripes run on below and are cut off by a
# flat horizontal line (FLAT_Y), so the yoke has a flat bottom, never a point.
CX, NECK_Y, SLOPE = 1645, 444, 0.48
BLUE_BANDS = [(-500, -78), (-58, -38), (-18, 170), (212, 223), (252, 264), (303, 356),
              (393, 438), (487, 530), (579, 622)]
# the flat line cuts through the lower tip of the wide (303, 356) band, giving
# it a flat bottom ~60 px wide at the centre, as on the shirt
FLAT_Y = 786
# the outer ends of the stripes are cut on a diagonal near the bottom:
# |dx| < CUT_W - CUT_SLOPE * (y - CUT_Y)  (wide to the panel edge higher up)
CUT_W, CUT_Y, CUT_SLOPE = 520, 692, 0.85


def solid_layer(mask, colour):
    out = np.zeros(mask.shape + (4,), np.uint8)
    out[mask] = tuple(colour) + (255,)
    return out


def top(kit):
    y, x = kit.grid("top")
    W, H = kit.size("top")

    # front yoke (front panel = 1100..2270), the shoulders are already on it
    front = (x > 1090) & (x < 2280) & (y > 190)
    dx = np.abs(x - CX)
    v = (y - NECK_Y) + SLOPE * dx
    cut = (dx < CUT_W - CUT_SLOPE * (y - CUT_Y)) & (y < FLAT_Y)
    bands = np.zeros_like(front)
    for v0, v1 in BLUE_BANDS:
        bands |= (v >= v0) & (v < v1)

    # collar black, with a thin blue edge where it meets the neckline
    strip = (x > 1110) & (x < 2160)
    collar = solid_layer(strip & (y < 205), kit.colour("main"))
    collar[strip & (y > 180) & (y < 205)] = kit.colour("blue") + (255,)

    return [
        ("Base", solid_layer(np.ones((H, W), bool), kit.colour("main"))),
        ("Chest chevrons", solid_layer(front & bands & cut, kit.colour("blue"))),
        # sleeves are plain black; blue cuffs (the cuff lining reuses texels below the cuff too)
        ("Cuffs", solid_layer((x > 2290) & (y >= kd.CUFF_Y), kit.colour("blue"))),
        ("Collar", collar),
    ]


def shorts(kit):
    """Stock home shorts recoloured: blue -> black, light grey -> white."""
    im = kit.stock("m_shorts_bulldogs_nrl_home_26_col_1")
    a = np.asarray(im, np.float32)
    # sponsors keep their light grey (white on black); only the ground goes black
    logo = a.min(2) > 120
    logo = ndimage.binary_dilation(logo, iterations=2) & (a.min(2) > 70)
    return [("Shorts (stock 2026 home, recoloured)",
             kd.recolour(im, kit.colour("stock_blue"), kit.colour("stock_grey"),
                         kit.colour("main"), kit.colour("white"), keep=logo))]


def socks(kit):
    """Stock home socks recoloured: blue -> black, grey hoops -> blue."""
    return [("Socks (stock 2026 home, recoloured)",
             kd.recolour(kit.stock("m_socks_bulldogs_nrl_home_26_col_1"), kit.colour("stock_blue"),
                         kit.colour("stock_grey"), kit.colour("main"), kit.colour("blue")))]


def cb_monogram(kit):
    """The CB monogram from the 2026 crest's collar tag."""
    cb = Image.open(kit.file("logos/bulldogs_crest_2026.png")).convert("RGBA")
    s = cb.width / 1200
    cb = cb.crop((round(520 * s), round(1010 * s), round(665 * s), round(1170 * s)))
    lum = np.asarray(cb.convert("L"), np.float32) * (np.asarray(cb.getchannel("A")) / 255)
    return kd.solid(Image.fromarray(np.clip((lum - 120) * 3, 0, 255).astype(np.uint8)), (255, 255, 255))
