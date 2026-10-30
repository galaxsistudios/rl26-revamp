#!/usr/bin/env python3
"""
design.py - Bulldogs 2026 alternate (black) kit, painted procedurally in RL26's
kit layout (see resources/jersey-templates/README.md), then the sponsors laid
on top.

Base design: black body; a blue chevron yoke on the front made of V stripes
that are cut off at an angle towards the armpits; blue cuffs
on the sleeves. Black shorts and
socks with blue hoops, recoloured from the stock 2026 home ones.

Sponsors:
  logos/laundy_hotels.png        laundy.com.au (laundy-logo-black.png)
  logos/bulldogs_crest_2026.png  Wikipedia File:Canterbury-Bankstown_Bulldogs_logo_2026.svg
  ../logos/nrl_telstra_premiership.png  NRL Telstra Premiership logo (kit_design.nrl_patch)
  KFC, Wattyl, O'Neills, Future Form, Supporting Disabilities Australia and
  the official product tag are keyed out of the stock Bulldogs 2026 textures
  (same artwork and placement the game uses) and recoloured white.

Usage (repo root):
    python resources/custom-kits/bulldogs_alternate_2026/design.py
    python tools/jersey_template.py preview resources/custom-kits/bulldogs_alternate_2026
"""

import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFont
from scipy import ndimage

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "tools"))
from kit_design import key, outline, place, place_nrl_patch, recolour, solid, stock  # noqa: E402

BLACK = (20, 20, 22)
BLUE = (28, 60, 196)
WHITE = (240, 240, 240)
STOCK_BLUE, STOCK_GREY = (33, 53, 145), (190, 190, 190)

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
CUFF_Y = 727


# --------------------------------------------------------------------------
# top


def top():
    W, H = 4096, 2048
    y, x = np.mgrid[0:H, 0:W].astype(np.float32)
    img = np.empty((H, W, 3), np.float32)
    img[:] = BLACK

    # front yoke (front panel = 1100..2270), the shoulders are already on it
    front = (x > 1090) & (x < 2280) & (y > 190)
    dx = np.abs(x - CX)
    v = (y - NECK_Y) + SLOPE * dx
    cut = (dx < CUT_W - CUT_SLOPE * (y - CUT_Y)) & (y < FLAT_Y)
    bands = np.zeros_like(front)
    for v0, v1 in BLUE_BANDS:
        bands |= (v >= v0) & (v < v1)
    img[front & bands & cut] = BLUE

    # sleeves: plain black with blue cuffs (the cuff lining reuses texels
    # below the cuff too)
    sleeves = x > 2290
    img[sleeves & (y >= CUFF_Y)] = BLUE

    # collar black, with a thin blue edge where it meets the neckline
    img[(x > 1110) & (x < 2160) & (y < 205)] = BLACK
    img[(x > 1110) & (x < 2160) & (y > 180) & (y < 205)] = BLUE

    canvas = Image.fromarray(img.astype(np.uint8)).convert("RGBA")
    logos(canvas)
    return canvas.convert("RGB")


def logos(c):
    home = stock("m_top_bulldogs_nrl_home_26_col_1")
    away = stock("m_top_bulldogs_nrl_away_26_col_1")
    shorts = stock("m_shorts_bulldogs_nrl_home_26_col_1")

    # front
    laundy = Image.open(os.path.join(HERE, "logos", "laundy_hotels.png")).convert("RGBA")
    laundy = solid(laundy.getchannel("A").crop(laundy.getchannel("A").getbbox()), WHITE)
    place(c, laundy, (CX - 10, 1035), width=640)

    place(c, solid(key(home, (1565, 490, 1735, 605)), WHITE), at=(1565 + 8, 490 - 6))  # Future Form.

    oneills = solid(key(shorts, (1400, 2850, 1700, 3070)), WHITE)
    place(c, oneills, (1322, 392), width=150, angle=28)
    place(c, oneills, (1966, 392), width=150, angle=-28)

    crest = Image.open(os.path.join(HERE, "logos", "bulldogs_crest_2026.png")).convert("RGBA")
    crest = crest.crop(crest.getchannel("A").getbbox())
    crest = crest.resize((round(120 * crest.width / crest.height), 120), Image.LANCZOS)  # ~ the NRL badge height
    place(c, outline(crest, 6, WHITE), (1872, 634))

    place_nrl_patch(c, (1418, 632), 118, BLACK, WHITE)  # on a flat black patch over the yoke

    c.alpha_composite(home.crop((1216, 1636, 1381, 1732)).convert("RGBA"), (1216, 1636))  # product tag

    # back
    place(c, solid(key(home, (300, 395, 785, 565), lo=60, hi=180), WHITE), at=(300, 395))  # KFC
    place(c, solid(key(away, (215, 1195, 880, 1540)), WHITE), at=(215, 1195))  # SDA
    cb = Image.open(os.path.join(HERE, "logos", "bulldogs_crest_2026.png")).convert("RGBA")
    s = cb.width / 1200
    cb = cb.crop((round(520 * s), round(1010 * s), round(665 * s), round(1170 * s)))
    lum = np.asarray(cb.convert("L"), np.float32) * (np.asarray(cb.getchannel("A")) / 255)
    cb = solid(Image.fromarray(np.clip((lum - 120) * 3, 0, 255).astype(np.uint8)), WHITE)
    place(c, cb, (543, 268), height=62)  # CB monogram under the collar

    # sleeves
    place(c, solid(key(home, (2555, 440, 2975, 620)), WHITE), at=(2555, 440))
    place(c, solid(key(home, (3390, 430, 3805, 615)), WHITE), at=(3390, 430))


# --------------------------------------------------------------------------
# shorts / socks: stock home recoloured (blue -> black, light grey -> blue)


def shorts():
    im = stock("m_shorts_bulldogs_nrl_home_26_col_1")
    a = np.asarray(im, np.float32)
    # sponsors keep their light grey (white on black); only the ground goes black
    logo = a.min(2) > 120
    logo = ndimage.binary_dilation(logo, iterations=2) & (a.min(2) > 70)
    return recolour(im, STOCK_BLUE, STOCK_GREY, BLACK, WHITE, keep=logo)


def socks():
    return recolour(stock("m_socks_bulldogs_nrl_home_26_col_1"), STOCK_BLUE, STOCK_GREY, BLACK, BLUE)


def main():
    jobs = {"top": top, "shorts": shorts, "socks": socks}
    for part in sys.argv[1:] or jobs:
        jobs[part]().save(os.path.join(HERE, f"{part}.png"))
        print("wrote", part)


if __name__ == "__main__":
    main()
