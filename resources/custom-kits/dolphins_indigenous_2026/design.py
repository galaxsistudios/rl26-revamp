"""
design.py - Dolphins Indigenous 2026. An artwork kit (RULES.md 16-17): the
design is never painted by code. The top is the user's two product photos
(photos/front.png, photos/back.png) wrapped onto the jersey with
tools/kit_photo.py (landmarks in kit.json "photos"). The sponsors that come
out blurry are replaced in kit.json (soften = the photo smoothed under them).

Logo sources: the game's stock Dolphins 2026 home top (WAHL, crest, Classic,
sleeve Budget Direct, Anglo American) and dolphins_home_2027/logos/budget_direct.png.
Shorts and socks: the stock Dolphins home ones until photos are supplied.
"""

import numpy as np
from PIL import Image
from scipy import ndimage

import kit_design as kd
import kit_photo

HOME = "m_top_dolphins_nrl_home_26_col_1"


def top(kit):
    return [("Artwork (photos)", kit_photo.layer(kit, "top"))]


def shorts(kit):
    return [("Stock shorts", kit.stock("m_shorts_dolphins_nrl_home_26_col_1"))]


def socks(kit):
    return [("Stock socks", kit.stock("m_socks_dolphins_nrl_home_25_col_1"))]


def wahl_badge(kit):
    """The stock WAHL badge (white outline + text on the red shirt) as worn on
    this kit: white badge, dark outline and text, a thin white edge."""
    box = (1548, 552, 1738, 619)
    lit = np.asarray(kd.key(kit.stock(HOME), box, lo=60, hi=200)) / 255.0
    badge = ndimage.binary_fill_holes(lit > 0.5)
    edge = ndimage.binary_dilation(badge, iterations=3)
    white, text = np.array(kit.colour("white"), float), np.array(kit.colour("text"), float)
    rgb = white * (1 - lit[..., None]) + text * lit[..., None]
    rgb[edge & ~badge] = white
    alpha = ndimage.gaussian_filter(edge.astype(float), 0.7) * 255
    return Image.fromarray(np.dstack([rgb, alpha]).clip(0, 255).astype(np.uint8), "RGBA")


def old_patch(kit, box, grow=10):
    """Where the photo's own (blurry) sleeve patch landed: the biggest light
    blob inside box, filled and grown, so the flat cover hides all of it but
    stops short of the gold cuff stripe."""
    a = kit_photo.layer(kit, "top")
    x0, y0, x1, y1 = box
    light = (a[y0:y1, x0:x1, :3].max(2) > 150) & (a[y0:y1, x0:x1, 3] > 0)
    lab, n = ndimage.label(ndimage.binary_closing(light, iterations=6))
    if not n:
        return np.zeros(a.shape[:2], bool)
    blob = lab == np.argmax(ndimage.sum(light, lab, range(1, n + 1))) + 1
    blob = ndimage.binary_dilation(ndimage.binary_fill_holes(blob), iterations=grow)
    out = np.zeros(a.shape[:2], bool)
    out[y0:y1, x0:x1] = blob
    return out


def white_patch(kit, box):
    """A stock sleeve sponsor patch on a light-grey card -> RGBA with a white
    card and the card's outside (the jersey colour) transparent."""
    a = np.asarray(kit.stock(HOME).crop(tuple(box)), np.float32)
    grey = (a.min(2) > 150) & (a.max(2) - a.min(2) < 30)
    red = (a[..., 0] > 150) & (a[..., 1] < 70)
    card = ndimage.binary_fill_holes(ndimage.binary_closing(~red, iterations=2))
    card = ndimage.binary_erosion(ndimage.binary_opening(card, iterations=2), iterations=3)  # no red rim
    rgb = np.where(grey[..., None], np.array(kit.colour("white"), np.float32), a)
    alpha = ndimage.gaussian_filter(card.astype(np.float32), 0.8) * 255
    return Image.fromarray(np.dstack([rgb, alpha]).clip(0, 255).astype(np.uint8), "RGBA")
