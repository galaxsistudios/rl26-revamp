#!/usr/bin/env python3
"""
flag_template.py - build the layered Photoshop template for crowd flags
(mods/crowd-flags) in resources/flags/.

The canvas is the flag face at its in-game shape: the cloth is CLOTH_WIDTH x
CLOTH_HEIGHT (0.52 x 0.34 m), pole edge on the left, top up, as a fan facing
the pitch shows it. The cloth is double-sided and the back runs the texture
the other way, so the design reads correctly from both sides. Installing
squashes the face into the crowd texture with build_flags.face_to_texture
(512x512 DXT1: the face fills the top 7/8, the pole colour the band below), so
designs never have to be painted stretched.

Layers (top first): GUIDES (pole edge, top, safe area, the waving end; hide
before exporting), Emblem, Secondary stripes, Primary colour - the stock
crowd-flags design, shown with the Broncos - and a hidden reference of the
raw game texture. Previews: preview_template.png (with guides) and
preview_texture.png (as the game stores it).

Usage:
    python tools/flag_template.py [--icon nrl_broncos] [--out resources/flags]
"""

import argparse
import io
import os
import sys

import numpy as np
import packbits
from PIL import Image, ImageDraw, ImageFont
from pytoshop import codecs, enums
from pytoshop.user import nested_layers

# pytoshop's compiled RLE codec has no build for newer Pythons; the pure
# packbits package has the same encode/decode API.
codecs.packbits = packbits

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "mods", "crowd-flags"))
import build_flags as bf  # noqa: E402

PX_PER_M = 3000                 # 1560 x 1020 canvas, about 3x the texture's density
W, H = round(bf.CLOTH_WIDTH * PX_PER_M), round(bf.CLOTH_HEIGHT * PX_PER_M)
STRIPE = 1 / 7                  # stock design: secondary stripes top and bottom, each 1/7 of the height
EMBLEM = 0.62                   # stock design: emblem box, as a share of the height
SAFE = 0.07                     # keep text and logos this far from the edges (share of the height)
SAMPLE = {"nrl_broncos": ((101, 0, 56), (253, 197, 19))}   # defaultdata_clubs primary/secondary
GUIDE = (0, 255, 255, 255)


def psd_layer(name, im, visible=True):
    a = np.asarray(im.convert("RGBA"))
    return nested_layers.Image(name=name, visible=visible, opacity=255,
                               channels={0: a[..., 0], 1: a[..., 1], 2: a[..., 2], -1: a[..., 3]})


def blank():
    return Image.new("RGBA", (W, H), (0, 0, 0, 0))


def guides():
    im = blank()
    d = ImageDraw.Draw(im)
    big = ImageFont.truetype("arialbd.ttf", 44)
    small = ImageFont.truetype("arialbd.ttf", 30)
    pad = round(SAFE * H)
    for x in range(pad, W - pad, 40):           # dashed safe area
        d.line([(x, pad), (min(x + 20, W - pad), pad)], fill=GUIDE, width=3)
        d.line([(x, H - pad), (min(x + 20, W - pad), H - pad)], fill=GUIDE, width=3)
    for y in range(pad, H - pad, 40):
        d.line([(pad, y), (pad, min(y + 20, H - pad))], fill=GUIDE, width=3)
        d.line([(W - pad, y), (W - pad, min(y + 20, H - pad))], fill=GUIDE, width=3)
    d.rectangle([0, 0, 14, H], fill=GUIDE)      # the pole edge
    d.text((30, H / 2), "POLE\nSIDE", font=big, fill=GUIDE, anchor="lm", stroke_width=4, stroke_fill=(0, 0, 0, 255))
    d.text((W / 2, 18), "TOP", font=small, fill=GUIDE, anchor="mt", stroke_width=4, stroke_fill=(0, 0, 0, 255))
    d.text((W - 30, H / 2), "waves\nmost", font=small, fill=GUIDE, anchor="rm", align="right",
           stroke_width=4, stroke_fill=(0, 0, 0, 255))
    d.text((W / 2, H - pad - 12), "keep text and logos inside the dashed line", font=small, fill=GUIDE,
           anchor="mb", stroke_width=4, stroke_fill=(0, 0, 0, 255))
    return im


def stock_layers(index, icon, primary, secondary):
    """The stock crowd-flags design as separate layers."""
    base = Image.new("RGBA", (W, H), primary + (255,))
    stripes = blank()
    d = ImageDraw.Draw(stripes)
    s = round(STRIPE * H)
    d.rectangle([0, 0, W, s], fill=secondary + (255,))
    d.rectangle([0, H - s, W, H], fill=secondary + (255,))
    emblem = blank()
    logo = Image.open(io.BytesIO(index.texture(f"ui/club_logos/large_mirrored/{icon}.texture"))).convert("RGBA")
    box = round(EMBLEM * H)
    logo.thumbnail((box, box), Image.LANCZOS)
    emblem.alpha_composite(logo, ((W - logo.width) // 2, (H - logo.height) // 2))
    return base, stripes, emblem


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--icon", default="nrl_broncos")
    ap.add_argument("--out", default=os.path.join(ROOT, "resources", "flags"))
    args = ap.parse_args()
    if args.icon not in SAMPLE:
        raise SystemExit(f"no sample colours for {args.icon}; add them to SAMPLE")

    index = bf.Index()
    base, stripes, emblem = stock_layers(index, args.icon, *SAMPLE[args.icon])
    face = Image.new("RGBA", (W, H))
    for layer in (base, stripes, emblem):
        face.alpha_composite(layer)
    texture = bf.face_to_texture(face)
    reference = blank()     # the raw game texture, stretched back over the face for comparison
    reference.paste(texture.crop((0, 0, texture.width, round(bf.TEX_FLAG_ROWS * texture.height))).resize((W, H)))
    guide = guides()

    psd_layers = [  # top of the Photoshop layer stack first
        psd_layer("GUIDES (hide before exporting)", guide),
        psd_layer("Emblem", emblem),
        psd_layer("Secondary stripes", stripes),
        psd_layer("Primary colour", base),
        psd_layer("Reference - game texture (hidden)", reference, visible=False),
    ]
    os.makedirs(args.out, exist_ok=True)
    psd = nested_layers.nested_layers_to_psd(psd_layers, color_mode=enums.ColorMode.rgb,
                                             size=(W, H), compression=enums.Compression.rle)
    psd_path = os.path.join(args.out, "flag_template.psd")
    with open(psd_path, "wb") as f:
        psd.write(f)
    with_guides = face.copy()
    with_guides.alpha_composite(guide)
    with_guides.convert("RGB").save(os.path.join(args.out, "preview_template.png"))
    texture.save(os.path.join(args.out, "preview_texture.png"))
    print(f"wrote {psd_path} ({W}x{H})")


if __name__ == "__main__":
    main()
