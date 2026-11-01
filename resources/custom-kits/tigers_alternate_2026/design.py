"""
design.py - Wests Tigers 2026 alternate kit (orange, black raglan sleeves with
blue panels, tiger stripes on the lower body), painted by code from the user's
product shots (photos/src_front, src_back): the photos are wrapped onto the
shirt (tools/kit_photo.py) and every texel is given the nearest kit colour
(kit_photo.flat), so the stripes are the photo's own, flattened to the kit's
colours. Under the sponsors (their own layers, kit.json) the design takes the
colour around them. The black is only the raglan shoulders and sleeves
(painted from the seam line, RAGLAN), the sleeves with an orange cuff and the
blue Zurich panel; the photo's stripes are kept on the lower body only.

Logo sources (kit.json): the stock Wests Tigers 2026 home top (PAMA, Pepper
Money, Canterbury, Zurich, product tag); the crest is logos/wests_tigers_2022.svg
(Wikipedia File:Wests_Tigers_2022_Logo.svg; the stock one sits on a stripe and
can't be cut out), its wordmark coloured as on the stock shirt.
"""

import numpy as np
from PIL import Image

import kit_photo

# areas of the photo with logos the kit leaves off (texture px): the back's
# Chris O'Brien Lifehouse and the two small badges under the back collar
LEFT_OFF = [(130, 470, 920, 700), (360, 320, 720, 440)]

COLOURS = ["main", "black", "tan", "blue", "white"]


# black only on the shoulders (user, 2026-11-01): the raglan seam runs from the
# collar (|x| 0.075, y 1.53) to the armpit (|x| 0.17, y 1.30); below the
# armpits the torso is orange, with the photo's tiger stripes below a sloped
# line (measured on the photos, x as seen from that side): the front's rise
# from y 1.13 on the viewer's left to 1.22 on the right, the back's sweep down
# from 1.37 on the viewer's left to 0.98 on the right
RAGLAN = ((0.075, 1.53), (0.17, 1.30))
STRIPES_TOP = {"front": ((-0.18, 1.13), (0.18, 1.22)), "back": ((-0.18, 1.37), (0.18, 0.98))}
CUFF_PX = 80  # the orange cuff band, from the sleeve's bottom edge (texture px)


def zones(kit):
    P, N, covered = kit_photo.surface("top", kit.model("top"), kit.size("top"))
    H, W = covered.shape
    x = np.mgrid[0:H, 0:W][1]
    sleeve = covered & (x >= 2290)
    torso = covered & ~sleeve
    (x0, y0), (x1, y1) = RAGLAN
    seam = x0 + (y0 - P[..., 1]) / (y0 - y1) * (x1 - x0)
    shoulder = torso & (P[..., 1] > y1) & (np.abs(P[..., 0]) > seam)
    rows = np.arange(H)[:, None]
    bottom = np.where(sleeve, rows, -1).max(0)  # each column's lowest sleeve texel
    cuff = sleeve & (rows > bottom[None, :] - CUFF_PX)
    return torso, shoulder, sleeve, cuff, P


def top(kit):
    ignore = kit.sponsor_mask("top", grow=34)
    for x0, y0, x1, y1 in LEFT_OFF:
        ignore[y0:y1, x0:x1] = True
    layers = kit_photo.flat(kit, "top", COLOURS, ignore=ignore, smooth=1.8)
    torso, shoulder, sleeve, cuff, P = zones(kit)
    main, black = kit.colour("main") + (255,), kit.colour("black") + (255,)
    N = kit_photo.surface("top", kit.model("top"), kit.size("top"))[1]
    top_y = np.zeros(P.shape[:2], np.float32)
    for side, sel in (("front", N[..., 2] >= 0), ("back", N[..., 2] < 0)):
        (xa, ya), (xb, yb) = STRIPES_TOP[side]
        xv = P[..., 0] if side == "front" else -P[..., 0]
        top_y[sel] = (ya + (xv - xa) / (xb - xa) * (yb - ya))[sel]
    plain = torso & ~shoulder & (P[..., 1] > top_y)  # orange, no stripes
    for name, im in layers:
        im[plain | shoulder | sleeve] = 0
    shoulders = np.zeros(sleeve.shape + (4,), np.uint8)
    shoulders[shoulder | (sleeve & ~cuff)] = black
    body = np.zeros_like(shoulders)
    body[plain | cuff] = main
    return layers + [("Upper body (orange)", body), ("Shoulders and sleeves (black)", shoulders)]


def shorts(kit):
    return [("Shorts (stock 2026 home)", kit.stock("m_shorts_tigers_nrl_home_26_col_1").resize(kit.size("shorts")))]


def socks(kit):
    return [("Socks (stock 2026 home)", kit.stock("m_socks_tigers_nrl_home_26_col_1").resize(kit.size("socks")))]


def crest(kit):
    """The 2022 crest with the wordmark as worn on orange: WESTS white, TIGERS black."""
    a = np.array(Image.open(kit.file("logos/wests_tigers_2022.png")).convert("RGBA"), np.float32)
    h = a.shape[0]
    rgb = a[..., :3]
    words = np.zeros(a.shape[:2], bool)
    words[int(h * 0.80):] = True
    wests = words & (rgb.max(-1) < 80)
    wests[int(h * 0.905):] = False
    tigers = words & (rgb[..., 0] > 150) & (rgb[..., 2] < 120)
    rgb[wests] = kit.colour("white")
    rgb[tigers] = kit.colour("black")
    return Image.fromarray(a.clip(0, 255).astype(np.uint8), "RGBA")
