"""
design.py - Raiders 2026 alternate (white) kit, painted by code from the
user's product shots (photos/src_front, src_back): the photos are wrapped onto
the vneck01 shirt (tools/kit_photo.py) and every texel is given the nearest of
the kit's colours (kit_photo.flat), so the yoke, the lime band, the cuffs and
the collar trim are measured straight off the photos. Under the sponsors (their
own layers, kit.json) the design takes the colour around them.

Logo sources (kit.json): the stock Raiders 2026 home top (crest, Canberra
Airport, both Toyota Forklifts, Club Lime, CDC, product tag).
"""

import kit_design as kd
import kit_photo

COLOURS = ["white", "main", "green"]


def top(kit):
    return kit_photo.flat(kit, "top", COLOURS, ignore=kit.sponsor_mask("top", grow=14), symmetric=True, level=(0.16, (0.9, 1.45)))


def shorts(kit):
    return [("Shorts (stock 2026 home)", kit.stock("m_shorts_raiders_nrl_home_26_col_1").resize(kit.size("shorts")))]


def socks(kit):
    return [("Socks (stock 2026 home)", kit.stock("m_socks_raiders_nrl_home_26_col_1").resize(kit.size("socks")))]
