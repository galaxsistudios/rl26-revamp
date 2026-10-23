#!/usr/bin/env python3
"""
add_texture.py - add a NEW texture (any image) to the game at a logical
path, e.g. ui/textures/mods/gf_smoke.texture, by appending a blobset entry
(add_entries.py; undo with its remove-all).

Written as uncompressed 32-bit BGRA with PREMULTIPLIED alpha, like the
shipped UI textures (checked 2026-10-23: legends.texture, club logos and
extrasymbols never have colour > alpha, and colour is 0 wherever alpha is 0).

--screen turns an opaque greyscale image meant for a screen blend (black = no
effect) into white with alpha = brightness. Under premultiplied blending that
is result = L + dst * (1 - L): exactly a screen blend. --black/--white set the
brightness mapped to fully clear / fully opaque, and --gamma shapes the ramp.
If the image has its own alpha (a soft-edged puff), that is multiplied in.

Usage:
    python add_texture.py preview --image smoke.png --screen --size 1024 --out preview.png
    python add_texture.py add --path ui/textures/mods/gf_smoke.texture --image smoke.png --screen --size 1024 [--replace] [--confirm]
"""

import argparse
import os
import sys

from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import add_entries  # noqa: E402
import club_icons  # noqa: E402
import pack  # noqa: E402

# Any shipped uncompressed texture works as the DDS header template.
HEADER_TEMPLATE_ICON = "cus_01"


def build_image(args):
    img = Image.open(args.image)
    if args.size:
        img = img.resize((args.size, args.size) if not args.keep_aspect else
                         (args.size, round(img.height * args.size / img.width)), Image.LANCZOS)
    if args.screen:
        lum = img.convert("L")
        span = max(1, args.white - args.black)
        alpha = lum.point(lambda v: round(255 * (min(max(v - args.black, 0), span) / span) ** args.gamma))
        if "A" in img.getbands():
            # Respect the image's own transparency (e.g. a soft-edged puff).
            from PIL import ImageChops
            alpha = ImageChops.multiply(alpha, img.getchannel("A"))
        # premultiplied white: colour == alpha
        return Image.merge("RGBA", (alpha, alpha, alpha, alpha))
    img = img.convert("RGBA")
    return Image.merge("RGBA", (*img.convert("RGBa").split()[:3], img.getchannel("A")))


def cmd_preview(args):
    import numpy as np
    src = np.asarray(build_image(args), dtype=np.float32)
    bg = np.empty_like(src[..., :3])
    bg[:] = (30, 70, 35)  # pitch-green test background
    # premultiplied "over": src + dst * (1 - a)
    out = src[..., :3] + bg * (1 - src[..., 3:] / 255)
    Image.fromarray(out.clip(0, 255).astype(np.uint8)).save(args.out)
    print(f"wrote {args.out} (over a green test background)")


def cmd_add(args):
    img = build_image(args)
    _sizes, legacy_header, _shield = club_icons.template_info(args.blobset, HEADER_TEMPLATE_ICON)
    dds = club_icons.make_dds(img, legacy_header)
    blob, sizes = club_icons.make_blob(args.path.lower(), dds)
    add_entries.add_entry(args.blobset, args.path, blob, sizes, f"{os.path.basename(args.image)} {img.width}x{img.height}",
                          args.confirm, replace=args.replace)
    if not args.confirm:
        print("dry run - pass --confirm to write (close the game first)")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--blobset", default=pack.BLOBSET_PATH)
    sub = ap.add_subparsers(dest="cmd", required=True)
    for name, fn in (("preview", cmd_preview), ("add", cmd_add)):
        p = sub.add_parser(name)
        p.add_argument("--image", required=True)
        p.add_argument("--size", type=int, help="resize to SIZE x SIZE (or SIZE wide with --keep-aspect)")
        p.add_argument("--keep-aspect", action="store_true")
        p.add_argument("--screen", action="store_true", help="greyscale screen-blend image -> premultiplied white + alpha")
        p.add_argument("--black", type=int, default=0, help="--screen: brightness that becomes fully clear")
        p.add_argument("--white", type=int, default=255, help="--screen: brightness that becomes fully opaque")
        p.add_argument("--gamma", type=float, default=1.0, help="--screen: ramp shape (>1 = wispier)")
        if name == "preview":
            p.add_argument("--out", required=True)
        else:
            p.add_argument("--path", required=True, help="new logical path, e.g. ui/textures/mods/gf_smoke.texture")
            p.add_argument("--replace", action="store_true", help="overwrite a texture this tool added before")
            p.add_argument("--confirm", action="store_true", help="required to actually write")
        p.set_defaults(func=fn)
    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    sys.exit(main())
