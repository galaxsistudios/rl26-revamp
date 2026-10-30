"""
design.py - <Club> <kit> <year>: the painted layers. Sponsors, the NRL logo and
the crest are in kit.json; build with
    python tools/kit_studio.py build <kit>

Base design: describe it here (what the photos show and how it was measured).

Logo sources: list each logos/ file and where it came from.

Each part function returns [(layer name, image), ...] bottom to top. An image
is the part's full canvas (kit.size(part)): a PIL image or a numpy array, RGB
(opaque) or RGBA (transparent where the layers below show). Keep one idea per
layer (base, each pattern, each trim) so each can be edited in kit.psd.
kit.sponsor_mask(part) is where the sponsors sit, if a pattern must stop there.
"""

import numpy as np

import kit_design as kd


def solid_layer(mask, colour):
    out = np.zeros(mask.shape + (4,), np.uint8)
    out[mask] = tuple(colour) + (255,)
    return out


def top(kit):
    y, x = kit.grid("top")
    W, H = kit.size("top")
    masks = kd.top_masks()  # all / back / front / sleeves (top_round05 layout)
    return [
        ("Base", solid_layer(np.ones((H, W), bool), kit.colour("main"))),
        ("Cuffs", solid_layer(masks["sleeves"] & (y >= kd.CUFF_Y), kit.colour("second"))),
        ("Collar", solid_layer((x > 1110) & (x < 2160) & (y < 205), kit.colour("second"))),
    ]


def shorts(kit):
    W, H = kit.size("shorts")
    return [("Base", solid_layer(np.ones((H, W), bool), kit.colour("main")))]


def socks(kit):
    W, H = kit.size("socks")
    return [("Base", solid_layer(np.ones((H, W), bool), kit.colour("main")))]
