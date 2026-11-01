"""
design.py - Panthers 2026 60th anniversary alternate (1967 colours: brown
yoke, cream body, red/white/blue shoulder stripes). Commemorative, but plain
colour blocks, so painted by code (RULES.md 16), measured from the user's
back product shot (photos/src_back; the only front photo is on a player and
shows the same yoke): a cream body, the brown yoke above a level line, brown
sleeves with cream cuffs, a cream collar.

The shoulder stripes run along the top of the shoulder from the collar to the
end of the sleeve (user, 2026-11-01), painted in 3D from each texel's distance
to that ridge (BANDS); the front sees red then cream, the back blue, red,
cream.

Logo sources (kit.json): the stock Panthers 2026 home top (crest, MyPlaceIQ,
O'Neills, Allam, Hertz, product tag); logos/picklebet.svg, the wordmark from
picklebet.com's own page; logos/westfund.png from westfund.com.au. The
milestone text under westfund (the player's debut number and name: "149 JOHN
FARRAGHER" on the launch photo) is set in the game's own chest-text font, RL
Font Bold (mods/official-jersey-editing/noesis/workspace/fonts/arvo-bold.ttf).
"""

import os

import numpy as np
from PIL import Image, ImageDraw, ImageFont

import kit_design as kd
import kit_photo

FONT = os.path.join(kd.ROOT, "mods", "official-jersey-editing", "noesis", "workspace", "fonts", "arvo-bold.ttf")

# shoulder bands, model units from the ridge (+ = towards the back), measured on
# the back photo wrapped onto the shirt (majority colour by distance from the
# ridge: brown from +0.050; blue : red : cream about 8 : 10 : 25 px on the photo)
# and the player photo for the front (red, then a cream band as wide)
BANDS = {"blue": [(-0.003, 0.009)], "red": [(-0.012, -0.003), (0.009, 0.021)],
         "white": [(-0.040, -0.012), (0.021, 0.050)]}


def ridge_distance(kit):
    """Signed distance (z, + towards the back) from the top of the shoulder and
    sleeve, and where the stripes run (the shoulder and the sleeve's outer half,
    from the collar out)."""
    P, N, covered = kit_photo.surface("top", kit.model("top"), kit.size("top"))
    ax = np.abs(P[..., 0])
    up = covered & (P[..., 1] > 1.30) & (ax > 0.06) & (N[..., 1] + np.abs(N[..., 0]) > 0.35)
    bins = np.clip(((ax - 0.06) / 0.25 * 60).astype(int), 0, 59)
    side = (P[..., 0] > 0).astype(int)
    ridge = np.zeros((2, 60), np.float32)
    on = up & (np.abs(N[..., 2]) < 0.12)
    for sd in (0, 1):
        for b in range(60):
            sel = on & (bins == b) & (side == sd)
            if sel.any():
                ridge[sd, b] = np.median(P[..., 2][sel])
    for sd in (0, 1):  # bins with no ridge texel take their neighbour's
        ok = np.flatnonzero(ridge[sd] != 0)
        ridge[sd] = np.interp(np.arange(60), ok, ridge[sd][ok])
    s = -(P[..., 2] - ridge[side, bins])
    return s, up


def stripes(kit):
    s, up = ridge_distance(kit)
    out = []
    for name, colour in (("Shoulder cream", "white"), ("Shoulder red", "red"), ("Shoulder blue", "blue")):
        im = np.zeros(s.shape + (4,), np.uint8)
        for lo, hi in BANDS[colour]:
            im[up & (s >= lo) & (s < hi)] = kit.colour(colour) + (255,)
        out.append((name, im))
    return out


# the yoke's bottom edge, level all round: back photo y 385 between the collar
# (60 = model 1.547) and the hem (945 = 0.937)
YOKE_Y = 1.547 - (385 - 60) / (945 - 60) * (1.547 - 0.937)


def blocks(kit):
    """Cream body and collar, brown yoke and sleeves, cream cuffs."""
    P, N, covered = kit_photo.surface("top", kit.model("top"), kit.size("top"))
    H, W = covered.shape
    y, x = np.mgrid[0:H, 0:W]
    sleeve = covered & (x >= kd.W * 2290 // 4096)
    cuff = sleeve & (y >= kd.CUFF_Y * H // kd.H)
    collar = kit_photo.collar_mask(P, covered)
    brown = (covered & ~sleeve & ~collar & (P[..., 1] > YOKE_Y)) | (sleeve & ~cuff)
    out = []
    for name, m, colour in (("Body (cream)", covered, "cream"), ("Yoke and sleeves (brown)", brown, "main")):
        im = np.zeros((H, W, 4), np.uint8)
        im[m] = kit.colour(colour) + (255,)
        out.append((name, im))
    return out


def top(kit):
    return blocks(kit) + stripes(kit)


def text(kit, s, height, tracking=0.0):
    """One line of text in RL Font Bold, `height` px cap height, as RGBA."""
    font = ImageFont.truetype(FONT, int(height * 1.45))
    w = int(font.getlength(s) + tracking * height * len(s) + height)
    im = Image.new("RGBA", (w, int(height * 2.4)))
    d = ImageDraw.Draw(im)
    x = height / 2
    for ch in s:
        d.text((x, height * 0.3), ch, font=font, fill=(255, 255, 255, 255))
        x += font.getlength(ch) + tracking * height
    return kd.trim(im)


def shorts(kit):
    # the 1967 brown shorts: the stock 2026 home shorts with black taken to brown
    im = kit.stock("m_shorts_panthers_nrl_home_26_col_1").resize(kit.size("shorts"))
    return [("Shorts (stock 2026 home, brown)", kd.recolour(im, (13, 13, 13), (235, 235, 235),
                                                            kit.colour("main"), (235, 235, 235)))]


def socks(kit):
    return [("Socks (stock 2026 home)", kit.stock("m_socks_panthers_nrl_home_26_col_1").resize(kit.size("socks")))]
