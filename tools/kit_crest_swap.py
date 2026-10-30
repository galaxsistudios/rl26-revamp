"""Make a custom kit from a stock one with its chest crest swapped for another logo.

For kits Big Ant only ships with a one-off crest (the Cowboys' 2025 kits carry
the "30 YEARS" badge; their 2026 kits are the same designs with the normal
crest). Reads the stock kit's top/shorts/socks from the game, finds the old
crest on --mask-kit (a kit where it stands out cleanly against a plain
background) inside --box, fills it in, draws --logo centred where it was, and
writes resources/custom-kits/<name>/ + preview.png like fanhub_kit_import.py.
"templates" are the stock design's own items, so the kit keeps its models.

Filling the old crest:
  diffuse      smooth fill from the surrounding colour (plain backgrounds)
  shift:<dx>   copy the same rows from dx pixels across (stripes or a
               repeating pattern behind the crest: use a whole number of
               pattern periods)

    python tools/kit_crest_swap.py --stock cowboys_nrl_home_25 --design 280 \\
        --logo resources/nrl-site-logos/nrl/cowboys/badge.svg --box 1800 560 2020 790 \\
        --name cowboys_home_2026 --club 120 --kit-name HOME --rename-existing "HOME 2025"
"""
import argparse
import io
import os
import sys

import numpy as np
from PIL import Image
from scipy import ndimage

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(REPO, "tools"))
import fanhub_kit_import as fki  # noqa: E402
import jersey_template as jt  # noqa: E402


def stock_design(guid):
    """{option: (item model name, colTexture)} for a stock design guid."""
    import re
    path = os.path.join(REPO, "decompiled", "src", "script-game", "design", "characters", "assetmapitems.lua")
    text = open(path, encoding="utf-8", errors="replace").read()
    out = {}
    for option in ("uniformTop", "uniformBottom", "uniformSocks"):
        start = text.index(f"\t{option} = {{")
        m = re.search(r"\{[^{}]*\bguid = %d,[^{}]*" % guid, text[start:])
        if not m:
            raise SystemExit(f"no {option} item with guid {guid}")
        fields = dict(re.findall(r'(\w+) = "([^"]*)"', m.group(0)))
        out[option] = (fields["name"], fields["colTexture"])
    return out


def crest_mask(top, box):
    """The old crest inside box: the largest blob that differs from the box's
    border colour, holes filled, grown a few pixels to take its antialiasing."""
    x0, y0, x1, y1 = box
    a = np.asarray(top.convert("RGB"), np.float32)[y0:y1, x0:x1]
    border = np.concatenate([a[0], a[-1], a[:, 0], a[:, -1]])
    m = np.linalg.norm(a - np.median(border, 0), axis=2) > 45
    m = ndimage.binary_fill_holes(ndimage.binary_closing(m, iterations=3))
    lab, n = ndimage.label(m)
    if not n:
        raise SystemExit(f"no crest found in box {box}")
    m = lab == 1 + int(np.argmax(ndimage.sum(m, lab, range(1, n + 1))))
    full = np.zeros((top.height, top.width), bool)
    full[y0:y1, x0:x1] = m
    return ndimage.binary_dilation(full, iterations=4)


def fill(top, mask, how):
    a = np.asarray(top.convert("RGB"), np.float32).copy()
    ys, xs = np.nonzero(mask)
    y0, y1, x0, x1 = ys.min() - 10, ys.max() + 11, xs.min() - 10, xs.max() + 11
    if how.startswith("shift:"):
        dx = int(how.split(":", 1)[1])
        a[ys, xs] = a[ys, xs + dx]
    elif how == "diffuse":
        sub, m = a[y0:y1, x0:x1], mask[y0:y1, x0:x1]
        idx = ndimage.distance_transform_edt(m, return_distances=False, return_indices=True)
        sub = sub[idx[0], idx[1]]  # seed with the nearest outside pixel, then smooth
        for _ in range(1500):
            sub[m] = ndimage.uniform_filter(sub, size=(3, 3, 1))[m]
        a[y0:y1, x0:x1] = sub
    else:
        raise SystemExit(f"unknown --fill {how!r} (diffuse or shift:<dx>)")
    return Image.fromarray(a.clip(0, 255).astype(np.uint8))


def load_logo(path, height):
    if path.lower().endswith(".svg"):
        import resvg_py
        svg = open(path, encoding="utf-8").read()
        logo = Image.open(io.BytesIO(bytes(resvg_py.svg_to_bytes(svg_string=svg, width=height * 12))))
    else:
        logo = Image.open(path)
    logo = logo.convert("RGBA")
    logo = logo.crop(logo.getchannel("A").getbbox())
    return logo.resize((round(logo.width * height / logo.height), height), Image.LANCZOS)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--design", type=int, required=True, help="stock design guid (top, shorts and socks items)")
    ap.add_argument("--shorts-design", type=int, help="design for the shorts and socks, when the kit wears another "
                                                      "design's (the stock kit's uniformBottom/Socks; default --design)")
    ap.add_argument("--mask-design", type=int, help="design whose top shows the crest most cleanly (default --design)")
    ap.add_argument("--logo", required=True, help="new crest (.svg or an image with alpha)")
    ap.add_argument("--box", type=int, nargs=4, required=True, metavar=("X0", "Y0", "X1", "Y1"),
                    help="area around the old crest on the upright 4096x2048 top")
    ap.add_argument("--height", type=int, default=180, help="new crest height in texels")
    ap.add_argument("--fill", default="diffuse", help="diffuse | shift:<dx>")
    ap.add_argument("--name", required=True, help="resources/custom-kits folder and texture name")
    ap.add_argument("--club", type=int, help="also add/update the kits.json row for this club")
    ap.add_argument("--kit-name", help="kit name in game")
    ap.add_argument("--rename-existing", help="the club's kit already called --kit-name is renamed to this "
                                              "(the new kit takes its name, place and number styling)")
    ap.add_argument("--guid", type=int, help=f"design guid for a new row (default: next free from {fki.FIRST_CUSTOM_GUID})")
    args = ap.parse_args()

    design = stock_design(args.design)
    guids = {"uniformTop": args.design}
    if args.shorts_design:
        lower = stock_design(args.shorts_design)
        design.update({o: lower[o] for o in ("uniformBottom", "uniformSocks")})
    guids.update({o: args.shorts_design or args.design for o in ("uniformBottom", "uniformSocks")})
    images = {part: jt.read_texture(design[option][1] + "_1").convert("RGB")
              for part, (option, _pattern) in fki.PARTS.items()}
    mask_top = (jt.read_texture(stock_design(args.mask_design)["uniformTop"][1] + "_1")
                if args.mask_design else images["top"])
    mask = crest_mask(mask_top, args.box)
    ys, xs = np.nonzero(mask)
    top = fill(images["top"], mask, args.fill)
    logo = load_logo(args.logo, args.height)
    top.paste(logo, (round((xs.min() + xs.max()) / 2 - logo.width / 2),
                     round((ys.min() + ys.max()) / 2 - logo.height / 2)), logo)
    images["top"] = top

    out = os.path.join(fki.CUSTOM, args.name)
    os.makedirs(out, exist_ok=True)
    for part, im in images.items():
        im.save(os.path.join(out, f"{part}.png"))
    info = {"sex": 0}
    for option, (item, _tex) in design.items():
        info[option] = guids[option]
        info[option + "Item"] = item
    fki.preview(images, info, os.path.join(out, "preview.png"))
    print(f"wrote {os.path.relpath(out, REPO)} (old crest {xs.max() - xs.min() + 1}x{ys.max() - ys.min() + 1} "
          f"at {xs.min()},{ys.min()}; new {logo.width}x{logo.height})")

    if args.club is not None:
        row = fki.update_manifest(args.name, args.club, args.kit_name or args.name.upper(), info, args.guid)
        if args.rename_existing:
            import json
            manifest = json.load(open(fki.MANIFEST, encoding="utf-8"))
            for k in manifest["kits"]:
                if k.get("custom") == args.name:
                    k["renameExisting"] = args.rename_existing
            with open(fki.MANIFEST, "w", encoding="utf-8", newline="\n") as f:
                json.dump(manifest, f, indent=1)
                f.write("\n")
            print(f"  takes over {row['name']!r} (the old one becomes {args.rename_existing!r})")
        print(f"next: python tools/install_revamp.py --only {' '.join(fki.INSTALL_STEPS)} --confirm")


if __name__ == "__main__":
    main()
