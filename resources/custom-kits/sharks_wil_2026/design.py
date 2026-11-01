"""
design.py - Sharks 2026 Women in League kit, painted by code from the user's product shots
(photos/src_front, src_back): the photos are wrapped onto the shirt
(tools/kit_photo.py) and every texel is given the nearest kit colour
(kit_photo.flat). Under the sponsors (their own layers, kit.json) the design
takes the colour around them.

Logo sources (kit.json): the stock Sharks 2026 home top (Zambrero, Up Up
Cronulla, Reozone, pilot, crest, Aramex, Classic, Ace Cutters, product tag),
recoloured.
"""

import kit_photo

COLOURS = ["main", "lightblue"]


def top(kit):
    return kit_photo.flat(kit, "top", COLOURS, ignore=kit.sponsor_mask("top", grow=14), symmetric=True)


def shorts(kit):
    return [("Shorts (stock 2025 home)", kit.stock("m_shorts_sharks_nrl_home_25_col_1").resize(kit.size("shorts")))]


def socks(kit):
    return [("Socks (stock 2025 home)", kit.stock("m_socks_sharks_nrl_home_25_col_1").resize(kit.size("socks")))]
