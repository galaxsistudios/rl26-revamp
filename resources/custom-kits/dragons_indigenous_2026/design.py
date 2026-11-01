"""
design.py - Dragons Indigenous 2026. An artwork kit (RULES.md 16-17): the design is never
painted by code. The top is the product photos (photos/src_front, src_back
from resources/missing-jerseys/2026/dragons-indigenous) wrapped onto the top_round05 shirt
with tools/kit_photo.py (`kit_photo.py prep` cleans them into photos/front,
back and reads the landmarks). Sponsors replaced over blurry ones are in
kit.json, the photo softened under them.

Shorts and socks: the stock Dragons home ones until photos of the real ones
are supplied.
"""

import kit_photo


def top(kit):
    return [("Artwork (photos)", kit_photo.layer(kit, "top"))]


def shorts(kit):
    return [("Stock shorts", kit.stock("m_shorts_dragons_nrl_home_26_col_1").resize(kit.size("shorts")))]


def socks(kit):
    return [("Stock socks", kit.stock("m_socks_dragons_nrl_home_26_col_1").resize(kit.size("socks")))]
