#!/usr/bin/env python3
"""
national_flags.py - real national flags for the international teams' crowds.

Downloads each country's flag SVG (public domain, flagcdn.com / Wikimedia
Commons) into resources/national-flags/<code>.svg, then renders it as a
crowd flag face resources/flags/<icon>/national.png at the template's shape
(1560 x 1020, pole edge on the left = the flag's hoist).

The flag is stretched to the cloth's 0.52 x 0.34 shape rather than cropped,
so nothing (the Southern Cross, the Union Jack) is cut off. build_flags.py
`variants` gives national designs about half of a team's crowd flags.

    python mods\\crowd-flags\\national_flags.py [--download]

then install as resources/flags/README.md says (variants, register, scripts).
"""

import argparse
import io
import os
import sys
import urllib.request

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import flag_template as ft  # noqa: E402

SRC = os.path.join(ROOT, "resources", "national-flags")
FLAGS = os.path.join(ROOT, "resources", "flags")
FLAGCDN = "https://flagcdn.com/{}.svg"
COMMONS = "https://commons.wikimedia.org/wiki/Special:FilePath/{}"

# flag code -> download URL
SOURCES = {
    "au": FLAGCDN.format("au"),
    "gb-eng": FLAGCDN.format("gb-eng"),
    "gb-wls": FLAGCDN.format("gb-wls"),
    "nz": FLAGCDN.format("nz"),
    "ws": FLAGCDN.format("ws"),
    "fr": FLAGCDN.format("fr"),
    "pg": FLAGCDN.format("pg"),
    "lb": FLAGCDN.format("lb"),
    "to": FLAGCDN.format("to"),
    "fj": FLAGCDN.format("fj"),
    "ck": FLAGCDN.format("ck"),
    "maori": COMMONS.format("Tino_Rangatiratanga_Maori_sovereignty_movement_flag.svg"),
    "aboriginal": COMMONS.format("Australian_Aboriginal_Flag.svg"),
    # The Torres Strait Islander flag is copyrighted (no free copy), so the
    # Indigenous All Stars only wave the Aboriginal flag.
}

# game club icon -> flag code (men's and women's sides share icons or have _w ones)
ICONS = {
    "rep_australia_2": "au",
    "rep_australia_w": "au",
    "rep_england_2": "gb-eng",
    "rep_wales_2": "gb-wls",
    "rep_nz_2": "nz",
    "rep_nz_w": "nz",
    "rep_samoa_2": "ws",
    "rep_france_2": "fr",
    "rep_png_2": "pg",
    "rep_png_w": "pg",
    "rep_lebanon_2": "lb",
    "rep_tonga_2": "to",
    "rep_fiji_2": "fj",
    "rep_fiji_w": "fj",
    "rep_cookislands_2": "ck",
    "maori": "maori",
    "rep_indigenous": "aboriginal",
}


def download():
    os.makedirs(SRC, exist_ok=True)
    for code, url in SOURCES.items():
        req = urllib.request.Request(url, headers={"User-Agent": "RL26-Revamp-flags/1.0"})
        with urllib.request.urlopen(req, timeout=30) as r:
            data = r.read()
        if b"<svg" not in data[:2000]:
            raise SystemExit(f"{code}: {url} did not return an SVG")
        with open(os.path.join(SRC, f"{code}.svg"), "wb") as f:
            f.write(data)
        print(f"{code}: {len(data)} bytes")


def render(code):
    import resvg_py
    with open(os.path.join(SRC, f"{code}.svg"), encoding="utf-8") as f:
        svg = f.read()
    img = Image.open(io.BytesIO(bytes(resvg_py.svg_to_bytes(svg_string=svg, width=ft.W * 2)))).convert("RGB")
    return img.resize((ft.W, ft.H), Image.LANCZOS)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--download", action="store_true", help="fetch the SVGs again")
    args = ap.parse_args()
    if args.download or not os.path.isdir(SRC):
        download()
    faces = {}
    for icon, code in ICONS.items():
        face = faces.get(code) or faces.setdefault(code, render(code))
        os.makedirs(os.path.join(FLAGS, icon), exist_ok=True)
        face.save(os.path.join(FLAGS, icon, "national.png"))
        print(f"{icon}: national.png ({code})")


if __name__ == "__main__":
    main()
