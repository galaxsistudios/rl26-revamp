"""
design.py - Rabbitohs 2026 alternate ('An Ode to Redfern', cream with red and
green hoops on the yoke), painted by code from the user's product shots
(photos/src_front, src_back): the photos are wrapped onto the shirt
(tools/kit_photo.py) and every texel is given the nearest kit colour
(kit_photo.flat), with the torso hoops levelled. Under the sponsors (their own
layers, kit.json) the design takes the colour around them.

Logo sources (kit.json): the stock Rabbitohs 2026 home top (crest, wotif, MG,
Classic, Ingenia, Budget Direct, product tag); logos/deicorp.svg from
deicorp.com.au (/photos/SVG/deicorp-navy.svg), its tagline cut off as on the
shirt.
"""

import numpy as np
from PIL import Image

import kit_design as kd
import kit_photo

COLOURS = ["cream", "red", "green"]


def top(kit):
    return kit_photo.flat(kit, "top", COLOURS, ignore=kit.sponsor_mask("top", grow=14), symmetric=True,
                          level=(0.16, (0.9, 1.45), True))


def shorts(kit):
    return [("Shorts (stock 2026 home)", kit.stock("m_shorts_rabbitohs_nrl_home_26_col_1").resize(kit.size("shorts")))]


def socks(kit):
    return [("Socks (stock 2026 home)", kit.stock("m_socks_rabbitohs_nrl_home_26_col_1").resize(kit.size("socks")))]


def deicorp(kit):
    """DC roundel + DEICORP, without the 'Design. Develop. Deliver.' line."""
    im = Image.open(kit.file("logos/deicorp.png")).convert("RGBA")
    a = np.array(im)
    a[int(im.height * 0.64):, int(im.width * 0.29):, 3] = 0
    return kd.trim(Image.fromarray(a))


def mg_badge(kit):
    """The stock MG badge (light letters on black) as worn on this kit: a dark
    outline and dark letters on a white octagon."""
    from scipy import ndimage
    a = np.asarray(kit.stock("m_top_rabbitohs_nrl_home_26_col_1").crop((1384, 846, 1834, 1300)), np.float32)
    dark = a.max(-1) < 70
    shape = ndimage.binary_fill_holes(ndimage.binary_closing(dark, iterations=3))
    lab, n = ndimage.label(shape)
    shape = lab == np.argmax(ndimage.sum(shape, lab, range(1, n + 1))) + 1
    rim = shape & ~ndimage.binary_erosion(shape, iterations=9)
    inner = ndimage.binary_erosion(shape, iterations=30)
    letters = inner & (a.min(-1) > 120)
    ink = (rim | letters)
    rgb = np.where(ink[..., None], np.array(kit.colour("text"), np.float32), np.array(kit.colour("cream"), np.float32))
    alpha = ndimage.gaussian_filter(shape.astype(np.float32), 0.7) * 255
    return Image.fromarray(np.dstack([rgb, alpha]).clip(0, 255).astype(np.uint8), "RGBA")
