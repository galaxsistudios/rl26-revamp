#!/usr/bin/env python3
"""
classic_logos.py - the "Classic" NRL emblems (pre-rebrand club logos from
resources/new-team-logos/classic-nrl-logos), built with tools/club_icons.py.

The names here must match ModClubIcons in clublist.lua, ClubIconColourSetMap
and ModClubIconLabels in icons.lua.

Usage (from the repo root, game closed for `add`):
    python mods\\new-club-icons\\classic_logos.py scorebug            # resources/scorebug_img/<icon>.png
    python mods\\new-club-icons\\classic_logos.py preview             # previews/classic_sheet.png
    python mods\\new-club-icons\\classic_logos.py add [--replace] [--confirm]
"""

import argparse
import os
import sys
from types import SimpleNamespace

from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import club_icons  # noqa: E402
import pack  # noqa: E402

SRC_DIR = os.path.join(ROOT, "resources", "new-team-logos", "classic-nrl-logos")
SCOREBUG_DIR = os.path.join(ROOT, "resources", "scorebug_img")
PREVIEW = os.path.join(ROOT, "resources", "new-team-logos", "previews", "classic_sheet.png")

# (icon, source file, in-game label, fill colour for the dynasty shield / scorebug)
# Numbered oldest first within each club.
CLASSICS = [
    ("nrl_broncos_classic_1", "Brisbane_Broncos_Logo_1988-01a.png", "Brisbane Broncos Classic #1", "#530b2f"),
    ("nrl_broncos_classic_2", "Brisbane_Broncos_Logo_2007-01-1.png", "Brisbane Broncos Classic #2", "#fbb03b"),
    ("nrl_raiders_classic_1", "Canberra_Raiders_Logo_2000-01-2.png", "Canberra Raiders Classic #1", "#002856"),
    ("nrl_raiders_classic_2", "Canberra_Raiders_Logo_2020-01-2.png", "Canberra Raiders Classic #2", "#002856"),
    ("nrl_bulldogs_classic_1", "Canterbury_Bulldogs_Logo_2004-01-1.png", "Canterbury-Bankstown Bulldogs Classic #1", "#0057b8"),
    ("nrl_bulldogs_classic_2", "Canterbury_Bulldogs_Logo_2011-01-1.png", "Canterbury-Bankstown Bulldogs Classic #2", "#0057b8"),
    ("nrl_sharks_classic_1", "Cronulla_Sharks_Logo_1998-02.png", "Cronulla-Sutherland Sharks Classic #1", "#101010"),
    ("nrl_titans_classic_1", "Gold_Coast_Titans_Logo_2007-01-1.png", "Gold Coast Titans Classic #1", "#001341"),
    ("nrl_seaeagles_classic_1", "Manly_Warringah_Sea_Eagles_Logo_1998-03.png", "Manly Warringah Sea Eagles Classic #1", "#6c1d45"),
    ("nrl_seaeagles_classic_2", "Manly_Warringah_Sea_Eagles_Logo_2003-01-1.png", "Manly Warringah Sea Eagles Classic #2", "#f4f4f4"),
    ("nrl_storm_classic_1", "Melbourne_Storm_Logo_1998-01-1.png", "Melbourne Storm Classic #1", "#0a2341"),
    ("nrl_warriors_classic_1", "NZ_Warriors_Logo_2000-01-1.png", "New Zealand Warriors Classic #1", "#00205b"),
    ("nrl_warriors_classic_2", "NZ_Warriors_Logo_2002-01-1.png", "New Zealand Warriors Classic #2", "#f4f4f4"),
    ("nrl_knights_classic_1", "Newcastle_Knights_Logo_1998-01.png", "Newcastle Knights Classic #1", "#00349b"),
    ("nrl_knights_classic_2", "Newcastle_Knights_Logo_2008-01.png", "Newcastle Knights Classic #2", "#f4f4f4"),
    ("nrl_cowboys_classic_1", "North_Qld_Cowboys_Logo_1995-01-1.png", "North Queensland Cowboys Classic #1", "#fed114"),
    ("nrl_cowboys_classic_2", "North_Qld_Cowboys_Logo_1998-01-1.png", "North Queensland Cowboys Classic #2", "#002b5c"),
    ("nrl_eels_classic_1", "Parramatta_Eels_Logo_2000-01b.png", "Parramatta Eels Classic #1", "#ffd326"),
    ("nrl_eels_classic_2", "Parramatta_Eels_Logo_2004-01-1.png", "Parramatta Eels Classic #2", "#1b3668"),
    ("nrl_panthers_classic_1", "Penrith_Panthers_Logo_2000-01-1.png", "Penrith Panthers Classic #1", "#55565b"),
    ("nrl_panthers_classic_2", "Penrith_Panthers_Logo_2014-01-1.png", "Penrith Panthers Classic #2", "#f4f4f4"),
    ("nrl_rabbitohs_classic_1", "South_Sydney_Rabbitohs_Logo_2010-01-2.png", "South Sydney Rabbitohs Classic #1", "#f4f4f4"),
    ("nrl_roosters_classic_1", "Sydney_Roosters_Logo_1995-01-1.png", "Sydney Roosters Classic #1", "#e42c2f"),
    ("nrl_tigers_classic_1", "Wests_Tigers_Logo_2004-01-1.png", "Wests Tigers Classic #1", "#101010"),
]


def scorebug_path(icon):
    return os.path.join(SCOREBUG_DIR, icon + ".png")


def icon_args(icon, image, fill, **extra):
    return SimpleNamespace(blobset=pack.BLOBSET_PATH, icon=icon, image=os.path.join(SRC_DIR, image), template="cus_01",
                           fill=fill, hud_score_tile=False, hud_score_image=scorebug_path(icon), **extra)


def cmd_scorebug(args):
    for icon, image, _label, fill in CLASSICS:
        club_icons.cmd_scorebug(SimpleNamespace(image=os.path.join(SRC_DIR, image), out=scorebug_path(icon), fill=fill,
                                                zoom=club_icons.SCOREBUG_ZOOM, dy=club_icons.SCOREBUG_DY))


def cmd_preview(args):
    """One row per icon: the variants most visible in menus / HUD."""
    show = ("large_mirrored", "hud_score", "advance_tile", "dynasty", "plinths", "flags")
    rows = []
    for icon, image, label, fill in CLASSICS:
        variants = club_icons.build_variants(icon_args(icon, image, fill))
        imgs = [img for (path, img, _), (_, key) in zip(variants, club_icons.VARIANTS) if key in show]
        rows.append((label, imgs))
    row_h = 200
    width = 260 + sum(min(row_h * img.width // img.height, 400) + 10 for img in rows[0][1])
    sheet = Image.new("RGBA", (width, len(rows) * (row_h + 10) + 10), (90, 90, 90, 255))
    draw = ImageDraw.Draw(sheet)
    for r, (label, imgs) in enumerate(rows):
        y = 10 + r * (row_h + 10)
        draw.text((10, y + row_h // 2), label, fill=(255, 255, 255, 255))
        x = 260
        for img in imgs:
            img = img.copy()
            img.thumbnail((400, row_h))
            sheet.alpha_composite(img, (x, y))
            x += min(row_h * img.width // max(1, img.height), 400) + 10
    sheet.save(PREVIEW)
    print(f"wrote {PREVIEW}")


def cmd_add(args):
    for icon, image, _label, fill in CLASSICS:
        print(f"== {icon}")
        club_icons.cmd_add(icon_args(icon, image, fill, confirm=args.confirm, replace=args.replace))


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("scorebug").set_defaults(func=cmd_scorebug)
    sub.add_parser("preview").set_defaults(func=cmd_preview)
    p_add = sub.add_parser("add")
    p_add.add_argument("--confirm", action="store_true")
    p_add.add_argument("--replace", action="store_true")
    p_add.set_defaults(func=cmd_add)
    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    sys.exit(main())
