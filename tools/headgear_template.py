#!/usr/bin/env python3
"""
headgear_template.py - build a layered Photoshop template for painting a
headgear (helmet) pattern, from the game's own mesh UVs and tint masks.

How headgear is coloured (assetmap.lua helmetColourLayers): the col texture
of the player's `helmet` item is a 4-channel tint mask. R (the whole shell) is
tinted with headwearColour1, G with headwearColour2, B with headwearColour3
and A with headwearColour4. A "special" pattern like Kalyn Ponga's (helmet
101, helmet_madisonAirFlo_custom02_col) is just a mask whose G channel holds
a design; custom01 is the same mask with a plain G. Scanned players wear their
own fitted mesh (<head>_headwear) but it keeps the stock item's UV layout,
so one template covers both.

The PSD has the UV layout as guide layers, the fixed trim channels of the
stock mask, an empty "YOUR PATTERN" layer (paint in white) and Ponga's design
as a hidden example. Texture space is the upright image (x = u mod 1,
y = 1 - v), checked against the stock mask.

Usage:
    python tools/headgear_template.py [--model madisonAirFlo_Male]
        [--mask resources/headgear-templates/raw/helmet_madisonairflo_custom01_col.png]
        [--example resources/headgear-templates/raw/helmet_madisonairflo_custom02_col.png]
        [--out resources/headgear-templates]
"""

import argparse
import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont
import packbits
from pytoshop import codecs, enums
from pytoshop.user import nested_layers

# pytoshop's compiled RLE codec has no build for newer Pythons; the pure
# packbits package has the same encode/decode API.
codecs.packbits = packbits

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import bigant_mesh as bm  # noqa: E402

SIZE = 2048
# Preview tints (in game these come from the player's headwearColour1-4).
BASE = (20, 45, 95)
PATTERN = (230, 190, 40)
TRIM3 = (235, 235, 235)
TRIM4 = (25, 25, 25)
UNUSED = (70, 70, 70)
# madisonAirFlo layout, upright texture pixels at 2048 (found from the mesh:
# the model's front is +z, so the player's right is -x).
LABELS = [
    ((1024, 1300), "TOP OF HEAD"),
    ((1024, 860), "FRONT (forehead)"),
    ((1024, 1940), "BACK"),
    ((560, 1400), "player's\nLEFT"),
    ((1490, 1400), "player's\nRIGHT"),
    ((470, 330), "RIGHT SIDE PANEL"),
    ((880, 120), "front →"),
    ((190, 120), "← back"),
    ((1580, 330), "LEFT SIDE PANEL"),
    ((1170, 120), "← front"),
    ((1860, 120), "back →"),
    ((1026, 590), "FOREHEAD PAD"),
    ((1760, 900), "RIGHT EAR"),
    ((1820, 1770), "LEFT EAR"),
    ((300, 1700), "CHIN\nSTRAP"),
    ((100, 1940), "BACK\nSTRAPS"),
]


def uv_pixels(UV):
    return np.c_[(UV[:, 0] % 1) * SIZE, (1 - UV[:, 1]) * SIZE]


def tri_points(xy, UV, t):
    # Triangles straddling u = 1 are drawn shifted back by a whole tile.
    u = UV[t, 0]
    pts = np.c_[(u - np.floor(u.min())) * SIZE, xy[t, 1]]
    return [tuple(p) for p in pts]


def coverage(xy, UV, I):
    im = Image.new("L", (SIZE, SIZE), 0)
    d = ImageDraw.Draw(im)
    for t in I:
        d.polygon(tri_points(xy, UV, t), fill=255)
    return im.filter(ImageFilter.MaxFilter(5))


def boundary_edges(UV, I):
    _, uid = np.unique(np.round(UV, 5), axis=0, return_inverse=True)
    uid = uid.ravel()
    e = np.r_[I[:, [0, 1]], I[:, [1, 2]], I[:, [2, 0]]]
    k = np.sort(uid[e], axis=1)
    _, inv, cnt = np.unique(k, axis=0, return_inverse=True, return_counts=True)
    return e[cnt[inv.ravel()] == 1]


def lines(xy, UV, edges, width, colour):
    im = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    for a, b in edges:
        p = tri_points(xy, UV, np.array([a, b]))
        d.line(p, fill=colour, width=width)
    return im


def labels():
    im = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    font = ImageFont.truetype("arialbd.ttf", 34)
    for (x, y), text in LABELS:
        d.multiline_text((x, y), text, font=font, fill=(0, 255, 255, 255), anchor="mm", align="center",
                         stroke_width=4, stroke_fill=(0, 0, 0, 255))
    return im


def solid(colour, alpha):
    a = np.asarray(alpha, np.uint8)
    rgb = np.empty(a.shape + (3,), np.uint8)
    rgb[:] = colour
    return Image.fromarray(np.dstack([rgb, a]), "RGBA")


def psd_layer(name, im, visible=True):
    a = np.asarray(im.convert("RGBA"))
    return nested_layers.Image(name=name, visible=visible, opacity=255,
                               channels={0: a[..., 0], 1: a[..., 1], 2: a[..., 2], -1: a[..., 3]})


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--model", default="madisonAirFlo_Male")
    ap.add_argument("--mask", default="resources/headgear-templates/raw/helmet_madisonairflo_custom01_col.png")
    ap.add_argument("--example", default="resources/headgear-templates/raw/helmet_madisonairflo_custom02_col.png")
    ap.add_argument("--out", default="resources/headgear-templates")
    args = ap.parse_args()

    bm.RL26_KIND["helmet"] = "characters/helmets"
    _P, _N, I, UV = bm.load_rl26("helmet", args.model)
    xy = uv_pixels(UV)
    cov = coverage(xy, UV, I)
    mask = np.asarray(Image.open(args.mask).convert("RGBA").resize((SIZE, SIZE)))
    example = np.asarray(Image.open(args.example).convert("RGBA").resize((SIZE, SIZE)))
    c = np.asarray(cov) > 0

    layers = {
        "unused": solid(UNUSED, np.where(c, 0, 255)),
        "base": solid(BASE, np.where(c, 255, 0)),
        "example": solid(PATTERN, np.where(c, example[..., 1], 0)),
        "pattern": Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0)),
        "trim3": solid(TRIM3, np.where(c, mask[..., 2], 0)),
        "trim4": solid(TRIM4, np.where(c, mask[..., 3], 0)),
        "wire": lines(xy, UV, I[:, [0, 1, 1, 2, 2, 0]].reshape(-1, 2), 1, (0, 0, 0, 110)),
        "outline": lines(xy, UV, boundary_edges(UV, I), 4, (0, 255, 255, 255)),
        "labels": labels(),
    }
    psd_layers = [  # top of the Photoshop layer stack first
        psd_layer("LABELS (hide before exporting)", layers["labels"]),
        psd_layer("UV OUTLINES (hide before exporting)", layers["outline"]),
        psd_layer("UV wireframe", layers["wire"], visible=False),
        psd_layer("Trim - colour 4 (fixed, don't edit)", layers["trim4"]),
        psd_layer("Trim - colour 3 (fixed, don't edit)", layers["trim3"]),
        psd_layer("YOUR PATTERN - colour 2 (paint white here)", layers["pattern"]),
        psd_layer("Example - Kalyn Ponga pattern", layers["example"], visible=False),
        psd_layer("Base - colour 1", layers["base"]),
        psd_layer("Unused area (not on the helmet)", layers["unused"]),
    ]
    os.makedirs(args.out, exist_ok=True)
    psd = nested_layers.nested_layers_to_psd(psd_layers, color_mode=enums.ColorMode.rgb,
                                             size=(SIZE, SIZE), compression=enums.Compression.rle)
    psd_path = os.path.join(args.out, "headgear_template.psd")
    with open(psd_path, "wb") as f:
        psd.write(f)

    # Flattened previews: the blank template and the Ponga example.
    def flat(pattern):
        out = Image.new("RGBA", (SIZE, SIZE))
        for k in ("unused", "base", pattern, "trim3", "trim4", "outline", "labels"):
            out.alpha_composite(layers[k])
        return out.convert("RGB")
    flat("pattern").save(os.path.join(args.out, "preview_blank_template.png"))
    flat("example").save(os.path.join(args.out, "preview_ponga_example.png"))
    print("wrote", psd_path)


if __name__ == "__main__":
    main()
