"""Build the About page art: two NEW texture entries (no stock art is replaced) and the page's view XAML.

    noesis/workspace/images/textures/credits/rl26revamped.texture  <- resources/rl26-revamp/rl26-revamped-logo.png
    noesis/workspace/images/textures/credits/galaxsi.texture       <- resources/rl26-revamp/gs-logo-light-long.svg
    noesis/workspace/views/testscreens/dynastycardtest.xaml        <- stock views/credits/credits.xaml, with the
                                                                      Big Ant watermark swapped for the GS mark
                                                                      (resources/rl26-revamp/galaxsi-studios-logo.svg)

The Galaxsi logo is used as supplied, just filled white (the source is dark, for light backgrounds).
Textures are uncompressed premultiplied BGRA, like the other added UI textures (club_icons.py).

The About page loads dynastycardtest.xaml instead of the shared credits view, so the real Credits
screen keeps its Big Ant watermark. That file is otherwise only loaded by the dev-only NoesisTestState
(-noesisTest), whose tile slot the About tile already borrows.

    python mods\\about-rl26-revamped\\make_logos.py preview                      # PNGs on a dark background
    python mods\\about-rl26-revamped\\make_logos.py install [--confirm]           # add (or update) the entries
    python mods\\about-rl26-revamped\\make_logos.py watermark --extracted <57662>  # write the view XAML

Needs pip install resvg-py potracer.
"""
import argparse
import io
import os
import re
import sys

import numpy as np
import potrace  # pip install potracer
import resvg_py  # pip install resvg-py
from PIL import Image

MOD_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(MOD_DIR))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import add_entries  # noqa: E402
import club_icons  # noqa: E402

RESOURCES = os.path.join(ROOT, "resources", "rl26-revamp")
REVAMP_LOGO = os.path.join(RESOURCES, "rl26-revamped-logo.png")
GALAXSI_SVG = os.path.join(RESOURCES, "gs-logo-light-long.svg")
DDS_HEADER_TEMPLATE = os.path.join(ROOT, "mods", "nrl-broadcast-scoreboard", "textures",
                                   "31e185be65e0bcf5_hud_score_nrl_broncos.dds")
sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), "tools"))
import games  # noqa: E402  (finds the RL26 install)

DEFAULT_BLOBSET = games.rl26_path("data", "data-0.blobset.pc")
CREDITS_DIR = "noesis/workspace/images/textures/credits/"
CREDITS_XAML = os.path.join("views", "credits", "credits.xaml")
VIEW_OUT = os.path.join(MOD_DIR, "noesis", "workspace", "views", "testscreens", "dynastycardtest.xaml")

WHITE = (255, 255, 255)

# the watermark is the GS mark on its own, like the stock one is the ant without the wordmark.
# Stock box: 550x710 for the portrait ant. The GS mark is about 2:1, so the box is a little wider and
# sits slightly further right, keeping the same vertical placement, fill and 10% opacity
WATERMARK_SVG = os.path.join(RESOURCES, "galaxsi-studios-logo.svg")
WATERMARK_WIDTH = 640
WATERMARK_MARGIN = "0,0,140,101"


def render_svg(path, scale=1):
    data = resvg_py.svg_to_bytes(svg_path=path, zoom=scale) if scale != 1 else resvg_py.svg_to_bytes(svg_path=path)
    img = Image.open(io.BytesIO(bytes(data))).convert("RGBA")
    return img.crop(img.getbbox())


def fill(img, colour):
    """Same alpha (the art's shapes), new flat colour."""
    out = Image.new("RGBA", img.size, colour + (0,))
    out.putalpha(img.getchannel("A"))
    return out


def galaxsi_logo():
    return fill(render_svg(GALAXSI_SVG), WHITE)


def revamp_logo():
    return Image.open(REVAMP_LOGO).convert("RGBA")


def fit_width(img, width):
    """Resample premultiplied so edges don't pick up dark fringes."""
    img = img.convert("RGBa")
    img = img.resize((width, round(img.height * width / img.width)), Image.LANCZOS)
    return Image.frombytes("RGBA", img.size, img.tobytes())  # premultiplied bytes, as stored


LOGOS = [
    ("rl26revamped", revamp_logo, 1200),
    ("galaxsi", galaxsi_logo, 1200),
]


def fmt(v):
    return f"{v:.1f}".rstrip("0").rstrip(".")


def trace(mask):
    """EvenOdd path data for a boolean mask (potracer traces False pixels), as in rl26-revamp-branding."""
    plist = potrace.Bitmap(~mask).trace(turdsize=4, alphamax=1.0, opticurve=True, opttolerance=0.2)
    parts = []
    for curve in plist:
        sp = curve.start_point
        d = [f"M{fmt(sp.x)} {fmt(sp.y)}"]
        for seg in curve.segments:
            if seg.is_corner:
                d.append(f"L{fmt(seg.c.x)} {fmt(seg.c.y)}L{fmt(seg.end_point.x)} {fmt(seg.end_point.y)}")
            else:
                d.append(f"C{fmt(seg.c1.x)} {fmt(seg.c1.y)} {fmt(seg.c2.x)} {fmt(seg.c2.y)} "
                         f"{fmt(seg.end_point.x)} {fmt(seg.end_point.y)}")
        parts.append("".join(d) + "Z")
    return "F0 " + "".join(parts)


def cmd_preview(args):
    os.makedirs(args.out, exist_ok=True)
    for name, build, _ in LOGOS:
        img = build()
        bg = Image.new("RGBA", (img.width + 120, img.height + 120), (30, 30, 40, 255))
        bg.alpha_composite(img, (60, 60))
        path = os.path.join(args.out, f"{name}_preview.png")
        bg.convert("RGB").save(path)
        print(f"wrote {path} ({img.width}x{img.height})")


def cmd_install(args):
    with open(DDS_HEADER_TEMPLATE, "rb") as fh:
        header = fh.read(128)
    for name, build, width in LOGOS:
        img = fit_width(build(), width)
        path = CREDITS_DIR + name + ".texture"
        blob, sizes = club_icons.make_blob(path, club_icons.make_dds(img, header))
        add_entries.add_entry(args.blobset, path, blob, sizes, f"about-rl26-revamped {name} {img.width}x{img.height}",
                              args.confirm, replace=True)
    if not args.confirm:
        print("dry run - pass --confirm to write (close the game first)")


def cmd_watermark(args):
    src = os.path.join(args.extracted, "noesis", "workspace", CREDITS_XAML)
    with open(src, "rb") as fh:
        raw = fh.read()
    bom = raw.startswith(b"\xef\xbb\xbf")
    text = raw.decode("utf-8-sig")

    alpha = np.asarray(render_svg(WATERMARK_SVG).getchannel("A"))
    data = trace(alpha >= 128)

    # the watermark is the only Path in the stock view
    pattern = re.compile(r'(<Path Height=")710("\s+Width=")550("[^>]*?Margin=")0,0,178,101("[^>]*?Data=")[^"]*(")', re.S)
    height = round(WATERMARK_WIDTH * alpha.shape[0] / alpha.shape[1])
    text, n = pattern.subn(lambda m: f"{m[1]}{height}{m[2]}{WATERMARK_WIDTH}{m[3]}{WATERMARK_MARGIN}{m[4]}{data}{m[5]}",
                           text)
    if n != 1:
        raise SystemExit(f"expected one watermark Path in {src}, matched {n}")
    # inside the root element: stock views start directly with it, so nothing goes before it
    note = ("\n    <!-- about-rl26-revamped: generated by make_logos.py from views/credits/credits.xaml for the About page.\n"
            "         Same view, with the Big Ant watermark replaced by the Galaxsi Studios logo. -->")
    root = re.search(r"<Grid\b[^>]*>", text)
    text = text[:root.end()] + note + text[root.end():]
    os.makedirs(os.path.dirname(VIEW_OUT), exist_ok=True)
    with open(VIEW_OUT, "wb") as fh:
        fh.write((b"\xef\xbb\xbf" if bom else b"") + text.encode("utf-8"))
    print(f"wrote {os.path.relpath(VIEW_OUT, ROOT)} (watermark {WATERMARK_WIDTH}x{height}, {len(data)} chars of path)")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("preview")
    p.add_argument("--out", default=os.path.join(MOD_DIR, "_preview"))
    p.set_defaults(fn=cmd_preview)
    p = sub.add_parser("install")
    p.add_argument("--blobset", default=DEFAULT_BLOBSET)
    p.add_argument("--confirm", action="store_true")
    p.set_defaults(fn=cmd_install)
    p = sub.add_parser("watermark")
    p.add_argument("--extracted", required=True, help="fresh extract_m3mp.py extraction of stock entry 57662")
    p.set_defaults(fn=cmd_watermark)
    args = ap.parse_args()
    args.fn(args)


if __name__ == "__main__":
    main()
