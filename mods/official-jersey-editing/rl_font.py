"""Puts RL Font (the NRL's typeface) in the Arvo Bold jersey-font slot, for the chest text.

The exe hard-codes its Noesis font files (paNoesisFontProvider), so a font can only
replace a stock file. arvo-bold.ttf is the "UniformArvoBold" jersey name font (no stock
kit uses it, no menu uses it); fonts.xaml loads it as `arvo-bold.ttf#Font`, so the copy
is renamed to the family "Font" (typographic names 16/17 stripped) and marked a regular
weight, as the stock file is.

The generated file (noesis/workspace/fonts/arvo-bold.ttf) is committed and ships with
the mod (the user's call, 2026-10-30); this script only needs re-running to change the
weight. It reads RL Font from the fonts installed on this PC.

    python mods/official-jersey-editing/rl_font.py [--weight Bold]

Then build the fonts bundle (manifests/fonts.xml, see INSTRUCTIONS.md).
"""
import argparse
import os
import sys

from fontTools.ttLib import TTFont

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "noesis", "workspace", "fonts", "arvo-bold.ttf")
FAMILY = "Font"
SEARCH = [
    os.path.expandvars(r"%LOCALAPPDATA%\Microsoft\Windows\Fonts"),
    os.path.expandvars(r"%WINDIR%\Fonts"),
]


def find(weight):
    name = "RLFont%s.ttf" % weight
    for folder in SEARCH:
        path = os.path.join(folder, name)
        if os.path.isfile(path):
            return path
    return None


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--weight", default="Bold", help="Regular, Bold, Black, ... (RLFont<weight>.ttf)")
    args = ap.parse_args()

    src = find(args.weight)
    if not src:
        sys.exit("RLFont%s.ttf isn't installed on this PC (looked in %s)" % (args.weight, ", ".join(SEARCH)))

    font = TTFont(src)
    names = font["name"]
    names.names = [r for r in names.names if r.nameID not in (16, 17, 21, 22)]
    for nid, value in ((1, FAMILY), (2, "Regular"), (4, FAMILY), (6, FAMILY)):
        names.setName(value, nid, 3, 1, 0x409)
        names.setName(value, nid, 1, 0, 0)
    font["OS/2"].usWeightClass = 400
    font["OS/2"].fsSelection = (font["OS/2"].fsSelection & ~0b100001) | 0b1000000  # regular, not bold/italic
    font["head"].macStyle = 0

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    font.save(OUT)
    print("%s -> %s (family %r)" % (src, OUT, FAMILY))


if __name__ == "__main__":
    main()
