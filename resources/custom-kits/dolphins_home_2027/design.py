#!/usr/bin/env python3
"""
design.py - Dolphins 2027 home kit (Oxen), painted in RL26's kit layout with
tools/kit_design.py, then the sponsors laid on top.

Base design: red body with a darker tonal "echo" pattern (echo(): interlocking
teardrops of upward-bowing bands, matched to a close-up of the shirt), strongest
at the hem, faint over the chest and faintest through the middle. Gold collar with a red lip
and a gold back-neck band (PHINS UP); side
panels between white piping lines under each arm with a gold diagonal wedge
towards the hem; orange raglan stitching; darker ribbed cuffs.

Sponsors:
  logos/budget_direct.png   resources/Goal Posts/new-sponsors/budget-direct-logo-leafless.svg
  ../sponsors/Oxen_Stacker_Logo_Horizontal_White.png (Oxen, symbol stacked over the wordmark)
  ../bulldogs_alternate_2026/logos/nrl_badge_light.png (product tag badge)
  ../logos/nrl_telstra_premiership.png (chest logo, kit_design.nrl_patch)
  WAHL, the dolphin, Anglo American, PHINS UP and the sleeve Budget Direct
  patches are keyed out of the stock Dolphins 2026 textures; the Betr back
  sponsor is left off on purpose.

Usage (repo root):
    python resources/custom-kits/dolphins_home_2027/design.py
    python tools/jersey_template.py preview resources/custom-kits/dolphins_home_2027 --top-model top_flat01_short_Male
"""

import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFont
from scipy import ndimage

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import kit_design as kd  # noqa: E402
from kit_design import key, place, solid, stock, trim  # noqa: E402

RED = (212, 24, 30)
DARK = (150, 12, 22)        # tonal pattern
SLEEVE_RED = (188, 18, 26)  # sleeves/shoulders are a deeper red than the body on the shirt
CUFF = (164, 14, 22)
GOLD = (222, 194, 140)
STITCH = (240, 96, 64)
WHITE = (244, 244, 244)
TAG = (28, 28, 30)

HOME = "m_top_dolphins_nrl_home_26_col_1"
TOP_MODEL = "top_flat01_short_Male"   # England RLWC "manufacturer" (item 7020), see kits.json templates
ECHO_SCALE = 0.86            # echo motif size on the shirt vs the reference close-up
SIDE_W, PIPE_W = 95, 10      # side panel width from the seam, white piping width
# gold side panel: a straight diagonal top edge, high at the front piping and
# low at the back one (40% / 63% of armpit -> hem on the side photo)
GOLD_TOP_BACK, GOLD_TOP_FRONT = 1468, 1235


def echo(y, x, scale=1.0):
    """The "echo" motif -> soft 0..1 mask. Teardrops in columns, alternate
    columns shifted half a drop so they interlock. Each drop widens from a
    point (a triangle) to its widest, then narrows to a point again, and is
    filled with bands that all bow upwards (same curvature, so the narrow
    top bands read as flat and the tips break off as small solid triangles).
    Sizes are in px of the reference close-up, times scale."""
    col_w, period, band = 122 * scale, 295 * scale, 27 * scale
    tri, tail, half = 115 * scale, 140 * scale, 61 * scale
    radius = 95 * scale
    col = np.floor(x / col_w)
    dx = x - (col + 0.5) * col_w
    s = (y - (col % 2) * period / 2) % period          # 0 at the drop's top point
    u = np.clip((s - tri) / tail, 0, 1)
    w = np.where(s < tri, s / tri * half, half * (1 - u ** 2))
    shape = np.clip(w - np.abs(dx) + 0.5, 0, 1) * (s < tri + tail)
    v = s - dx ** 2 / (2 * radius)                     # bands bow upwards (ends lower)
    thick = band * np.interp(s, [0, tri, tri + tail], [0.44, 0.36, 0.26])
    dist = np.abs((v / band) % 1 - 0.5) * band         # 0 mid-band
    stripe = np.clip(thick / 2 - dist + 0.5, 0, 1)
    return ndimage.gaussian_filter(shape * stripe, 0.9 * scale)


def flat_collar_mask():
    """Texels the top_flat01 collar samples: its u > 1 faces around the neck
    (the hem/cuff linings are left out by the area bounds)."""
    import bigant_mesh as bm
    from PIL import ImageDraw
    _P, _N, I, UV = bm.load_rl26("top", TOP_MODEL)
    im = Image.new("L", (kd.W, kd.H), 0)
    d = ImageDraw.Draw(im)
    for t in I:
        u = UV[t, 0]
        if u.min() < 1:
            continue
        pts = [((uu - 1) * kd.W, (1 - vv) * kd.H) for uu, vv in UV[t]]
        if max(p[0] for p in pts) < 2300 and max(p[1] for p in pts) < 700:
            d.polygon(pts, fill=255)
    return np.asarray(im) > 0


def side_distance(panel):
    """Per texel: distance from the nearer side seam of its panel row (inf
    outside), using the row's leftmost/rightmost panel texel."""
    out = np.full(panel.shape, np.inf, np.float32)
    x = np.arange(panel.shape[1])
    for yy in np.flatnonzero(panel.any(1)):
        xs = np.flatnonzero(panel[yy])
        lo, hi = xs[0], xs[-1]
        out[yy, lo:hi + 1] = np.minimum(x[lo:hi + 1] - lo, hi - x[lo:hi + 1])
    return out


def top():
    y, x = kd.grid()
    masks = kd.top_masks()
    front, back, sleeves = masks["front"], masks["back"], masks["sleeves"]
    torso = front | back
    img = np.empty((kd.H, kd.W, 3), np.float32)
    img[:] = RED
    img[x > 2290] = SLEEVE_RED          # raglan sleeves = the shoulders, a deeper red

    # tonal "echo" pattern: strongest at the hem, faint over the chest and
    # shoulders, faintest through the middle (as on the shirt)
    pattern = echo(y, x, ECHO_SCALE)
    torso_amt = np.interp(y, [200, 700, 1100, 1450, kd.HEM_Y], [0.5, 0.42, 0.18, 0.45, 1.0])
    sleeve_amt = np.interp(y, [230, 500, kd.CUFF_Y], [0.42, 0.3, 0.8])
    amount = np.where(sleeves, sleeve_amt, np.where(torso, torso_amt, 0)) * pattern
    img[:] = img * (1 - amount[..., None]) + np.array(DARK, np.float32) * amount[..., None]

    # side panels: white piping SIDE_W in from each side seam below the
    # armpit, gold diagonal wedge between the piping lines towards the hem
    for panel, sign in ((front, 1), (back, -1)):
        d = side_distance(panel)
        below = y > kd.ARMPIT_Y - 10
        side = panel & below & (d < SIDE_W)
        u = sign * d / SIDE_W                  # -1 back piping .. 0 seam .. +1 front piping
        top_y = (GOLD_TOP_BACK + GOLD_TOP_FRONT) / 2 + u * (GOLD_TOP_FRONT - GOLD_TOP_BACK) / 2
        img[side & (y > top_y)] = GOLD
        img[panel & below & (d >= SIDE_W) & (d < SIDE_W + PIPE_W)] = WHITE

    # orange raglan stitching on the panels and sleeves above the armpit
    for part, low in ((back, kd.ARMPIT_Y - 20), (front & (y > 215), kd.ARMPIT_Y - 20), (sleeves, 540)):
        dist = ndimage.distance_transform_edt(part)
        img[part & (dist < 7) & (dist > 2) & (y < low) & (y > 120)] = STITCH


    # back-neck gold band under the collar
    top_row = np.argmax(back, axis=0).astype(np.float32)
    band = back & (x > 330) & (x < 760) & (y < top_row[None, :] + 100)
    img[band] = GOLD

    # cuffs, collar
    img[sleeves & (y >= kd.CUFF_Y)] = CUFF
    img[(x > 2290) & (y >= kd.CUFF_Y) & ((y % 14) < 5)] = np.array(CUFF) * 0.9
    collar = (x > 1110) & (x < 2160) & (y < 205)         # top_round05's collar strip
    img[collar] = GOLD
    img[collar & (y < 40)] = RED
    # top_flat01 (the England RLWC item this kit is installed on) has no
    # collar strip: its collar faces (u > 1) sample a thin band along each
    # panel's neck edge. Gold, with a red lip on the side away from the panel.
    flat = flat_collar_mask()
    away = ndimage.distance_transform_edt(~(front | back))
    inward = ndimage.distance_transform_edt(flat)
    lip = flat & (away / np.maximum(away + inward, 1) > 0.62)
    img[flat] = GOLD
    img[lip] = RED

    canvas = Image.fromarray(img.clip(0, 255).astype(np.uint8)).convert("RGBA")
    logos(canvas)
    return canvas.convert("RGB")


def oxen_stacked():
    im = Image.open(os.path.join(HERE, "..", "sponsors", "Oxen_Stacker_Logo_Horizontal_White.png")).convert("RGBA")
    symbol, word = trim(im.crop((0, 0, 700, im.height))), trim(im.crop((740, 0, im.width, im.height)))
    symbol = symbol.resize((round(word.width * 0.42), round(symbol.height * word.width * 0.42 / symbol.width)),
                           Image.LANCZOS)
    out = Image.new("RGBA", (word.width, symbol.height + 40 + word.height))
    out.alpha_composite(symbol, ((word.width - symbol.width) // 2, 0))
    out.alpha_composite(word, (0, symbol.height + 40))
    return out


def badge(nrl_h, colour=WHITE):
    nrl = Image.open(os.path.join(HERE, "..", "bulldogs_alternate_2026", "logos", "nrl_badge_light.png")).convert("RGBA")
    nrl = nrl.resize((round(nrl_h * nrl.width / nrl.height), nrl_h), Image.LANCZOS)
    return solid(nrl.getchannel("A"), colour)


def white_patch(im, box):
    """A stock sponsor patch on a light-grey card -> RGBA with a white card
    and the card's outside (the jersey colour) transparent."""
    a = np.asarray(im.crop(box), np.float32)
    grey = (a.min(2) > 150) & (a.max(2) - a.min(2) < 30)
    red = (a[..., 0] > 150) & (a[..., 1] < 70)
    card = ndimage.binary_fill_holes(ndimage.binary_closing(~red, iterations=2))
    card = ndimage.binary_opening(card, iterations=2)
    rgb = np.where(grey[..., None], np.array(WHITE, np.float32), a)
    alpha = ndimage.gaussian_filter(card.astype(np.float32), 0.8) * 255
    return Image.fromarray(np.dstack([rgb, alpha]).clip(0, 255).astype(np.uint8), "RGBA")


def card(size, radius, colour=WHITE):
    im = Image.new("RGBA", size)
    ImageDraw.Draw(im).rounded_rectangle((0, 0, size[0] - 1, size[1] - 1), radius, fill=colour)
    return im


def logos(c):
    home = stock(HOME)

    # front: big Budget Direct card
    bd = trim(Image.open(os.path.join(HERE, "logos", "budget_direct.png")).convert("RGBA"))
    cw, ch = 650, 330
    box = card((cw, ch), 42)
    place(box, bd, (cw // 2, ch // 2 + 4), width=cw - 90)
    place(c, box, (kd.FRONT_CX, 1060))

    place(c, solid(key(home, (1548, 552, 1738, 619), lo=60, hi=200), WHITE), (kd.FRONT_CX, 560), width=220)  # WAHL
    place(c, solid(key(home, (1768, 592, 1952, 737)), WHITE), (1905, 676), height=140)  # dolphin, ~ the NRL badge height

    kd.place_nrl_patch(c, (1420, 676), 132, RED, WHITE)  # on a flat red patch over the echo

    ox = oxen_stacked()
    place(c, ox, (1290, 448), width=186, angle=8)    # upper chest, clear of the shoulder
    place(c, ox, (2000, 448), width=186, angle=-8)

    # product tag: NRL badge | Oxen, with the official product line
    tag = Image.new("RGBA", (170, 104), TAG + (255,))
    place(tag, badge(52), (42, 36))
    ImageDraw.Draw(tag).line((84, 10, 84, 62), fill=WHITE, width=2)
    place(tag, ox, (127, 36), width=58)
    small = ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf", 11)
    td = ImageDraw.Draw(tag)
    for text, yy in (("NRL TELSTRA PREMIERSHIP", 70), ("OFFICIAL PRODUCT", 85)):
        td.text((85 - td.textlength(text, font=small) / 2, yy), text, font=small, fill=WHITE)
    c.alpha_composite(tag, (1214, 1634))

    # back
    place(c, solid(key(home, (236, 1086, 834, 1258)), WHITE), (535, 1200), width=640)  # Anglo American
    place(c, solid(key(home, (400, 368, 702, 430), lo=40, hi=180, channel=1), RED), (543, 262), width=210)  # PHINS UP

    # sleeves: Budget Direct patches on white cards
    for bx in ((2536, 395, 2949, 612), (3422, 395, 3836, 612)):
        c.alpha_composite(white_patch(home, bx), bx[:2])


def shorts():
    """Stock 2026 home shorts with the Classic logo swapped for Oxen."""
    im = stock("m_shorts_dolphins_nrl_home_26_col_1").convert("RGBA")
    a = np.asarray(im.convert("RGB"))
    ImageDraw.Draw(im).rectangle((730, 1456, 914, 1512), fill=tuple(int(v) for v in a[1440, 700]) + (255,))
    place(im, oxen_stacked(), (822, 1470), width=84)
    return im.convert("RGB")


def socks():
    return stock("m_socks_dolphins_nrl_home_25_col_1")


def main():
    jobs = {"top": top, "shorts": shorts, "socks": socks}
    for part in sys.argv[1:] or jobs:
        jobs[part]().save(os.path.join(HERE, f"{part}.png"))
        print("wrote", part)


if __name__ == "__main__":
    main()
