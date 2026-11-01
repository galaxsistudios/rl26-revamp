#!/usr/bin/env python3
"""
showcase.py - one shareable image of every crowd flag design in
resources/flags/<icon>/*.png, in a captioned grid (club name + design).

Writes resources/flags/flags_showcase.png and a smaller .jpg for sharing.

    python mods\\crowd-flags\\showcase.py [--columns 12]
"""

import argparse
import os
import re
import sys

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, "tools"))
sys.path.insert(0, HERE)
import build_flags as bf  # noqa: E402

OUT = os.path.join(ROOT, "resources", "flags")
TILE_W = 300
TILE_H = round(TILE_W * bf.CLOTH_HEIGHT / bf.CLOTH_WIDTH)
CAPTION = 46
GAP = 18
MARGIN = 60
HEADER = 170
BG = (18, 20, 24)
TEXT = (240, 240, 240)
SUBTLE = (150, 156, 166)
ACCENT = (0, 200, 120)
DESIGN_NAMES = {"default": "Default", "inverted": "Inverted", "huge": "Huge", "wordmark": "Wordmark"}


def font(size):
    for path in (os.path.join(ROOT, "Maison-Neue-Extended-Bold.ttf"), "arialbd.ttf"):
        try:
            return ImageFont.truetype(path, size)
        except OSError:
            continue
    return ImageFont.load_default()


def club_names():
    """icon -> the club's display name: the plain senior club over its 2025 /
    GF / Decider / women's copies that share the icon (shortest name on a tie)."""
    def rank(name):
        return (bool(re.search(r"2025|^GF |^Decider ", name)), bool(re.search(r"\bWomen\b", name)), len(name))
    names = {}
    for _cid, name, icon, _p, _s in bf.load_clubs():
        if icon not in names or rank(name) < rank(names[icon]):
            names[icon] = name
    return names


def design_name(variant):
    if variant in DESIGN_NAMES:
        return DESIGN_NAMES[variant]
    m = re.match(r"classic_(\d+)$", variant)
    return f"Classic #{m.group(1)}" if m else variant.replace("_", " ").title()


def fit(draw, text, fnt, width):
    while draw.textlength(text, font=fnt) > width and len(text) > 4:
        text = text[:-2] + "…" if not text.endswith("…") else text[:-2] + "…"
    return text


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--columns", type=int, default=12)
    args = ap.parse_args()

    names = club_names()
    faces = bf.flag_faces()
    order = sorted(faces, key=lambda icon: names.get(icon, icon).lower())
    tiles = [(icon, variant, path) for icon in order for variant, path in faces[icon]]
    cols = args.columns
    rows = -(-len(tiles) // cols)
    width = MARGIN * 2 + cols * TILE_W + (cols - 1) * GAP
    height = HEADER + MARGIN + rows * (TILE_H + CAPTION) + (rows - 1) * GAP

    sheet = Image.new("RGB", (width, height), BG)
    d = ImageDraw.Draw(sheet)
    d.text((MARGIN, 52), "RL26 REVAMP  •  CROWD FLAGS", font=font(54), fill=TEXT)
    d.text((MARGIN, 122), f"{len(tiles)} flag designs for {len(faces)} clubs, waved by fans in the stands",
           font=font(26), fill=SUBTLE)
    d.rectangle([MARGIN, HEADER - 14, width - MARGIN, HEADER - 11], fill=ACCENT)

    club_font, design_font = font(17), font(14)
    for n, (icon, variant, path) in enumerate(tiles):
        r, c = divmod(n, cols)
        x = MARGIN + c * (TILE_W + GAP)
        y = HEADER + r * (TILE_H + CAPTION + GAP)
        flag = Image.open(path).convert("RGB").resize((TILE_W, TILE_H), Image.LANCZOS)
        sheet.paste(flag, (x, y))
        d.rectangle([x, y, x + TILE_W - 1, y + TILE_H - 1], outline=(60, 64, 72))
        d.text((x, y + TILE_H + 7), fit(d, names.get(icon, icon), club_font, TILE_W), font=club_font, fill=TEXT)
        d.text((x, y + TILE_H + 28), design_name(variant), font=design_font, fill=SUBTLE)

    png = os.path.join(OUT, "flags_showcase.png")
    sheet.save(png, optimize=True)
    small = sheet.resize((width // 2, height // 2), Image.LANCZOS)
    jpg = os.path.join(OUT, "flags_showcase.jpg")
    small.save(jpg, quality=90)
    print(f"{len(tiles)} flags, {cols} x {rows}: {png} ({width}x{height}), {jpg} ({small.width}x{small.height})")


if __name__ == "__main__":
    main()
