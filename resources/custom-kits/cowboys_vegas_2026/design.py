"""
design.py - Cowboys 2026 Las Vegas kit (white with navy horn graphics),
painted by code (user, 2026-11-01: plain shapes, not artwork) from Rebel
Sport's product shots (photos/src_front, src_back): the photos are wrapped
onto the shirt (tools/kit_photo.py) only to measure the shapes, and every
texel is given the nearest kit colour (kit_photo.flat). Under the sponsors
(their own layers, kit.json) the design takes the colour around them. The
navy polo collar is the top_flat02 model's own collar (RULES.md 19), painted
flat navy; the photos' collar is left out of the design.

Logo sources (kit.json): the stock Cowboys 2025 home top (YETI, Toyota,
Dynasty, Make Great Happen + TAFE, Bravus, product tag); the crest from
cowboys_home_2026/top.png (the normal crest, kit_crest_swap.py).
"""

import numpy as np
from PIL import Image

import kit_design as kd
import kit_photo

COLOURS = ["main", "blue", "navy"]  # blue: the horns' lighter shading
# photo logos the kit leaves off (texture px): the Las Vegas match text under
# YETI and NORTH under the back collar; the photo's sleeve Bravus (the clean
# one is a kit.json sponsor), above the cuff bands (y 727)
LEFT_OFF = [(1540, 670, 1800, 745), (440, 290, 680, 420), (2330, 200, 3140, 700), (3230, 200, 4040, 700)]


def collar_zone(kit):
    """Where the photos' navy polo collar lies on the shirt: the shirt there
    takes the colours around it (the collar is the model's)."""
    P, N, covered = kit_photo.surface("top", kit.model("top"), kit.size("top"))
    below = np.where(N[..., 2] > 0, 1.40, 1.50)
    return covered & ~kit_photo.collar_mask(P, covered) & (P[..., 1] > below) & (np.abs(P[..., 0]) < 0.13)


def top(kit):
    ignore = kit.sponsor_mask("top", grow=34) | collar_zone(kit)
    for x0, y0, x1, y1 in LEFT_OFF:
        ignore[y0:y1, x0:x1] = True
    P, N, covered = kit_photo.surface("top", kit.model("top"), kit.size("top"))
    collar = np.zeros(covered.shape + (4,), np.uint8)
    collar[kit_photo.collar_mask(P, covered)] = kit.colour("navy") + (255,)
    return kit_photo.flat(kit, "top", COLOURS, ignore=ignore, fill="main", off_palette=0, smooth=1.5) + [("Collar (navy)", collar)]


def shorts(kit):
    return [("Shorts (stock 2025 home)", kit.stock("m_shorts_cowboys_nrl_home_25_col_1").resize(kit.size("shorts")))]


def socks(kit):
    return [("Socks (stock 2025 home)", kit.stock("m_socks_cowboys_nrl_home_25_col_1").resize(kit.size("socks")))]


def crest(kit):
    """The crest's shapes off its navy ground (one colour, set in kit.json)."""
    a = np.asarray(Image.open(kit.file("@/cowboys_home_2026/top.png")).convert("RGB").crop((1815, 580, 2005, 760)),
                   np.float32)
    navy = np.array([20, 36, 82], np.float32)
    alpha = np.clip((np.abs(a - navy).max(-1) - 40) * 4, 0, 255).astype(np.uint8)
    return kd.trim(kd.solid(Image.fromarray(alpha), (255, 255, 255)))
