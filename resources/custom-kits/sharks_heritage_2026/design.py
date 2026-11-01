"""
design.py - Sharks 2026 heritage kit, painted by code from the user's product shots
(photos/src_front, src_back): the photos are wrapped onto the shirt
(tools/kit_photo.py) and every texel is given the nearest kit colour
(kit_photo.flat). Under the sponsors (their own layers, kit.json) the design
takes the colour around them. Mirrored left/right: a SALE badge hid one side of both photos.
The white polo collar is the top_flat02 model's collar (RULES.md 19), painted
flat white; the photos' collar is left out of the design.

Logo sources (kit.json): the stock Sharks 2026 home top (Zambrero, Up Up
Cronulla, Reozone, pilot, crest, Aramex, Classic, Ace Cutters, product tag),
recoloured.
"""

import numpy as np

import kit_photo

COLOURS = ["main", "white", "black"]
# the photos' own Zambrero and Reozone cards (texture px), wider and taller than
# the clean ones: the shirt there takes the colour around them
PHOTO_CARDS = [(60, 380, 1010, 600), (60, 950, 1010, 1290)]


def collar_zone(kit):
    """Where the photos' white polo collar lies on the shirt (round the neck,
    down to the collar points): the collar is the top_flat02 model's own
    (RULES.md 19), so the shirt there takes the colours around it."""
    P, N, covered = kit_photo.surface("top", kit.model("top"), kit.size("top"))
    return covered & ~kit_photo.collar_mask(P, covered) & (P[..., 1] > 1.41) & (np.abs(P[..., 0]) < 0.14)


def top(kit):
    ignore = kit.sponsor_mask("top", grow=34) | collar_zone(kit)  # the photos' cards are bigger
    for x0, y0, x1, y1 in PHOTO_CARDS:
        ignore[y0:y1, x0:x1] = True
    return kit_photo.flat(kit, "top", COLOURS, ignore=ignore, symmetric=True) + [("Collar", collar(kit))]


def collar(kit):
    P, N, covered = kit_photo.surface("top", kit.model("top"), kit.size("top"))
    im = np.zeros(covered.shape + (4,), np.uint8)
    im[kit_photo.collar_mask(P, covered)] = kit.colour("white") + (255,)
    return im


def shorts(kit):
    return [("Shorts (stock 2025 home)", kit.stock("m_shorts_sharks_nrl_home_25_col_1").resize(kit.size("shorts")))]


def socks(kit):
    return [("Socks (stock 2025 home)", kit.stock("m_socks_sharks_nrl_home_25_col_1").resize(kit.size("socks")))]
