"""
generate.py - HD replacements for club emblems (17 NRL clubs, NSW Cup and
QLD Cup clubs, NSW/QLD Origin, international federation crests, British
clubs from Gallery of League), rendered from the nrl.com vector badges in
resources/nrl-site-logos/<comp>/<team>/ with tools/club_icons.py's measured
layouts.

Source per variant:
  - transparent variants (shown over dark UI): badge-light.svg, else badge.svg
    (Dolphins and Dragons always badge.svg: their light badges are all white;
    Eels and Sea Eagles use the hand-supplied LOGO_OVERRIDE images)
  - field (white tile): badge.svg, since the light badges are white/pale
  - dynasty (team-colour shield): badge-basic24(-light).svg, else
    badge(-light).svg (DYNASTY_SOURCE overrides), whichever stands out more
    against the shield fill, zoomed in on a key detail (DYNASTY_FOCUS)

hud_player / advance_tile (the wide strips in club lists) get the whole badge
centred on a team-colour gradient. The remaining hand-made licensed crops
(plinths, flags, hud_intro, hud_lineup) keep their stock art, and hud_score
belongs to nrl-broadcast-scoreboard.

Each canvas is the stock size x SCALE (same aspect ratio). The dynasty fill
is the stock dynasty's most common colour, so the badge keeps its club tint.

Stock textures are read from pack.py's install backups when an entry is
already modded, so regenerating never needs a restore first.

Writes textures/<entry hash>_<variant>_<icon>.dds (installed by
texture_mods.py apply) and previews/<icon>.png (stock row above new row).

Usage:
    python mods/hd-nrl-club-logos/generate.py [--scale 2] [icon ...]
"""

import argparse
import json
import os
import re
import sys
from collections import Counter

from PIL import Image, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, "tools"))
import add_entries  # noqa: E402
import classify_entries as ce  # noqa: E402
import club_icons as ci  # noqa: E402
import entries  # noqa: E402
import extract_textures as et  # noqa: E402
import pack  # noqa: E402

LOGOS = os.path.join(REPO, "resources", "nrl-site-logos")
# "gol/<section>/<club>" teams come from Gallery of League's British index
# (tools/gol_logos.py): one ~1000px PNG per club, saved as badge.png.
GOL_LOGOS = os.path.join(REPO, "resources", "gallery-of-league-logos")

# game icon -> <comp folder>/<nrl.com theme key>. Not covered (no usable logo
# on nrl.com): nsw_magpies (Wentworthville), nsw_mounties, nsw_seaeagles
# (Blacktown Workers), qld_pride, rep_city/rep_country, soow_* (women's
# Origin); qld_bears/qld_blackhawks/nsw_blackhawks/qld_devils only have a
# one-colour silhouette there, so they keep their stock colour logos.
# Internationals: the plain rep_<nation> icons are flag shields and keep
# stock; the crest icons (_2, _w, ...) get the federation badges. Samoa, the
# new Tonga logo, Kiwi Ferns, Fiji Bulikula and Malta are PNG-only (336px) on
# nrl.com, and the world-cup-2021-* themes are tournament art, not crests.
TEAMS = {
    "nrl_broncos": "nrl/broncos",
    "nrl_bulldogs": "nrl/bulldogs",
    "nrl_cowboys": "nrl/cowboys",
    "nrl_dolphins": "nrl/dolphins",
    "nrl_dragons": "nrl/dragons",
    "nrl_eels": "nrl/eels",
    "nrl_knights": "nrl/knights",
    "nrl_panthers": "nrl/panthers",
    "nrl_rabbitohs": "nrl/rabbitohs",
    "nrl_raiders": "nrl/raiders",
    "nrl_roosters": "nrl/roosters",
    "nrl_seaeagles": "nrl/sea-eagles",
    "nrl_sharks": "nrl/sharks",
    "nrl_storm": "nrl/storm",
    "nrl_tigers": "nrl/wests-tigers",
    "nrl_titans": "nrl/titans",
    "nrl_warriors": "nrl/warriors",
    "nsw_bears": "nswrl/north-sydney-bears",
    "nsw_jets": "nswrl/jets",
    "nsw_westernsuburbs": "nswrl/western-suburbs-magpies",
    "qld_capras": "qrl/capras",
    "qld_clydesdales": "qrl/western-clydesdales",
    "qld_cutters": "qrl/cutters",
    "qld_dolphins": "qrl/redcliffe-dolphins",
    "qld_falcons": "qrl/falcons",
    "qld_gullsmanly": "qrl/wynnum-seagulls",
    "qld_hunters": "qrl/hunters",
    "qld_jets": "qrl/ipswich-jets",
    "qld_magpies": "qrl/magpies",
    "qld_seagulls": "qrl/tweed-heads-seagulls",
    "qld_tigers": "qrl/brisbane-tigers",
    "rep_nsw": "state-of-origin/blues",
    "rep_qld": "state-of-origin/maroons",
    "rep_australia_2": "world-cup/australia",
    "rep_australia_w": "womens-world-cup/australian-jillaroos",
    "aus_jillaroos": "womens-world-cup/australian-jillaroos",
    "rep_nz_2": "world-cup/new-zealand",
    "rep_england_2": "world-cup/england",
    "rep_fiji_2": "world-cup/fiji",
    "rep_france_2": "world-cup/france",
    "rep_ireland_2": "world-cup/ireland",
    "rep_lebanon_2": "world-cup/lebanon",
    "rep_png_2": "world-cup/papua-new-guinea",
    "rep_png_w": "womens-world-cup/papua-new-guinea-womens",
    "rep_scotland_2": "world-cup/scotland",
    "rep_tonga_2": "internationals/tonga",
    "rep_usa_2": "world-cup/usa",
    "rep_wales_2": "world-cup/wales",
    "rep_cookislands_2": "world-cup/cook-islands",
    "cookislands": "world-cup/cook-islands",
    # British clubs (Gallery of League). Kept stock: sl/slw_warrington (the
    # current logo is the 150-year anniversary badge), king_centurions,
    # king1_oxford, slw_barrow (Raiders Ladies), slw_valkyrie.
    "sl_castleford": "gol/super-league/castleford-tigers",
    "sl_catalans": "gol/super-league/catalans-dragons",
    "sl_huddersfield": "gol/super-league/huddersfield-giants",
    "sl_hullfc": "gol/super-league/hull-fc",
    "sl_hullkr": "gol/super-league/hull-kr",
    "sl_leeds": "gol/super-league/leeds-rhinos",
    "sl_leigh": "gol/super-league/leigh-leopards",
    "sl_salford": "gol/championship/salford-red-devils",
    "sl_sthelens": "gol/super-league/st-helens",
    "sl_wakefield": "gol/super-league/wakefield-trinity",
    "sl_widnes": "gol/championship/widnes-vikings",
    "sl_wigan": "gol/super-league/wigan-warriors",
    "slw_huddersfield": "gol/super-league/huddersfield-giants",
    "slw_leeds": "gol/super-league/leeds-rhinos",
    "slw_leigh": "gol/super-league/leigh-leopards",
    "slw_sthelens": "gol/super-league/st-helens",
    "slw_wigan": "gol/super-league/wigan-warriors",
    "king_broncos": "gol/championship/london-broncos",
    "king_bulldogs": "gol/championship/batley-bulldogs",
    "king_bulls": "gol/super-league/bradford-bulls",
    "king_eagles": "gol/championship/sheffield-eagles",
    "king_feather": "gol/other-clubs/featherstone-rovers",
    "king_halifax": "gol/other-clubs/halifax",
    "king_hornets": "gol/championship/rochdale-hornets",
    "king_hullkingston": "gol/super-league/hull-kr",
    "king_lions": "gol/championship/swinton-lions",
    "king_oldham": "gol/championship/oldham",
    "king_olympique": "gol/super-league/toulouse-olympique",
    "king_rams": "gol/championship/dewsbury-rams",
    "king1_allgolds": "gol/other-clubs/all-golds",
    "king1_bears": "gol/other-clubs/coventry-bears",
    "king1_cougers": "gol/championship/keighley-cougars",
    "king1_crusaders": "gol/championship/north-wales-crusaders",
    "king1_doncaster": "gol/championship/doncaster",
    "king1_hawks": "gol/championship/hunslet",
    "king1_hurricanes": "gol/championship/midlands-hurricanes",
    "king1_ironmen": "gol/other-clubs/south-wales-ironmen",
    "king1_knights": "gol/super-league/york-knights",
    "king1_raiders": "gol/championship/barrow-raiders",
    "king1_skolars": "gol/other-clubs/london-skolars",
    "king1_stags": "gol/other-clubs/hemel-stags",
    "king1_thunder": "gol/championship/newcastle-thunder",
    "king1_vikings": "gol/championship/goole-vikings",
    "king1_whitehaven": "gol/championship/whitehaven",
    "king1_workington": "gol/championship/workington-town",
}

# layout key -> source ("light" = badge-light first, "colour" = badge)
REPLACED = {
    "64": "light",
    "small": "light",
    "large_mirrored": "light",
    "bg_logo": "light",
    "256": "light",
    "field": "colour",
    "dynasty": "contrast",
    "hud_player": "strip",
    "advance_tile": "strip",
}

# Layout keys rendered at a fixed canvas size instead of stock x --scale.
# The team loading screen point-copies large_mirrored into a native render
# target (homeTeamTexture/awayTeamTexture, stock 308x312) before drawing it at
# 680x688 of a 1080p layout (loading-screen-secondary-arrows' LOGO_SIZE;
# 1360x1376 at 4K). install.py patches that target to this size, so
# every large_mirrored must match it exactly (some stock canvases are 304 wide)
# for a 1:1 copy.
VARIANT_SIZE = {"large_mirrored": (1232, 1248)}

# Clubs whose badge-light is unusable (plain white silhouette).
NO_LIGHT = {"nrl/dolphins", "nrl/dragons", "world-cup/australia"}

# Hand-supplied logos for every non-dynasty variant ("light" -> transparent
# variants, "colour" -> field): nrl.com only has the Eels' and Sea Eagles'
# 80-year anniversary badges. manly-proper-light.png is manly-proper.webp with
# the text (rows 944+) turned white for dark backgrounds.
LOGO_OVERRIDE = {
    "nrl/eels": {"light": "proper-logo.webp", "colour": "proper-logo.webp"},
    "nrl/sea-eagles": {"light": "manly-proper-light.png", "colour": "manly-proper.webp"},
    # All-white logos: badge-dark.png (same alpha, near-black) for the white field tile.
    "gol/super-league/hull-fc": {"light": "badge.png", "colour": "badge-dark.png"},
    "gol/championship/newcastle-thunder": {"light": "badge.png", "colour": "badge-dark.png"},
}

# Dynasty crop per club: (x, y) of the detail to centre, as fractions of the
# source's master square, and the square's size as a multiple of the shield's
# inner height.
DYNASTY_FOCUS = {
    "nrl/broncos": (0.64, 0.42, 1.6),      # horse's head
    "nrl/bulldogs": (0.50, 0.45, 1.7),     # face
    "nrl/cowboys": (0.50, 0.35, 1.9),      # star and horns (badge.svg)
    "nrl/dolphins": (0.32, 0.40, 2.0),     # head
    "nrl/dragons": (0.45, 0.32, 2.0),      # head
    "nrl/eels": (0.42, 0.55, 2.5),         # eel's head (proper-logo.webp)
    "nrl/knights": (0.58, 0.62, 1.7),      # visor
    "nrl/panthers": (0.62, 0.45, 2.6),     # head
    "nrl/rabbitohs": (0.32, 0.45, 2.0),    # head
    "nrl/raiders": (0.50, 0.55, 1.6),      # face
    "nrl/roosters": (0.55, 0.42, 1.8),     # head and beak
    "nrl/sea-eagles": (0.62, 0.42, 1.4),   # eye and beak
    "nrl/sharks": (0.42, 0.58, 1.8),       # head
    "nrl/storm": (0.60, 0.60, 1.4),        # head
    "nrl/titans": (0.50, 0.45, 1.6),       # visor
    "nrl/warriors": (0.50, 0.55, 1.5),     # eyes
    "nrl/wests-tigers": (0.50, 0.52, 1.6), # face
    "nswrl/north-sydney-bears": (0.45, 0.55, 2.1),     # bear's face
    "nswrl/jets": (0.50, 0.45, 1.1),                   # whole oval
    "nswrl/western-suburbs-magpies": (0.50, 0.62, 1.6),  # magpie
    "qrl/capras": (0.42, 0.66, 2.0),                   # ram's head
    "qrl/western-clydesdales": (0.45, 0.24, 2.2),      # horse's head
    "qrl/cutters": (0.60, 0.28, 2.0),                  # cutter's face
    "qrl/redcliffe-dolphins": (0.62, 0.32, 2.4),       # dolphin's head
    "qrl/falcons": (0.55, 0.58, 1.8),                  # falcon's head
    "qrl/wynnum-seagulls": (0.62, 0.45, 2.0),          # gull's head
    "qrl/hunters": (0.62, 0.33, 2.0),                  # arrow
    "qrl/ipswich-jets": (0.50, 0.45, 1.3),             # JETS
    "qrl/magpies": (0.62, 0.25, 2.6),                  # magpie's head
    "qrl/tweed-heads-seagulls": (0.60, 0.47, 1.9),     # gull's head
    "qrl/brisbane-tigers": (0.50, 0.38, 1.6),          # tiger's face
    "state-of-origin/blues": (0.50, 0.55, 1.2),        # NSW BLUES
    "state-of-origin/maroons": (0.50, 0.66, 1.6),       # kangaroo and Q
    "world-cup/australia": (0.50, 0.555, 2.6),          # kangaroo
    "womens-world-cup/australian-jillaroos": (0.50, 0.58, 1.7),  # kangaroo
    "world-cup/new-zealand": (0.50, 0.60, 1.7),        # kiwi
    "world-cup/england": (0.50, 0.45, 1.5),            # lions
    "world-cup/fiji": (0.50, 0.50, 1.4),               # warrior
    "world-cup/france": (0.50, 0.40, 1.7),             # rooster
    "world-cup/ireland": (0.50, 0.50, 1.2),            # RLI
    "world-cup/lebanon": (0.50, 0.40, 1.9),            # cedar
    "world-cup/papua-new-guinea": (0.58, 0.60, 1.9),   # bird of paradise
    "womens-world-cup/papua-new-guinea-womens": (0.50, 0.62, 1.6),  # orchid
    "world-cup/scotland": (0.50, 0.30, 1.3),           # emblem
    "internationals/tonga": (0.50, 0.50, 1.3),         # crest
    "world-cup/usa": (0.50, 0.55, 1.6),                # hawk
    "world-cup/wales": (0.50, 0.56, 1.8),              # dragon
    "world-cup/cook-islands": (0.40, 0.42, 3.0),       # emblem
    "gol/super-league/castleford-tigers": (0.50, 0.55, 1.7),  # tiger
    "gol/super-league/catalans-dragons": (0.40, 0.45, 2.0),  # dragon's head
    "gol/super-league/huddersfield-giants": (0.50, 0.25, 2.0),  # giant's face
    "gol/super-league/hull-fc": (0.50, 0.50, 1.6),  # crowns
    "gol/super-league/hull-kr": (0.50, 0.55, 1.3),  # emblem
    "gol/super-league/leeds-rhinos": (0.48, 0.72, 2.0),  # rhino
    "gol/super-league/leigh-leopards": (0.50, 0.60, 1.6),  # leopard's face
    "gol/championship/salford-red-devils": (0.50, 0.50, 1.4),  # S
    "gol/super-league/st-helens": (0.50, 0.60, 1.5),  # V and monogram
    "gol/super-league/wakefield-trinity": (0.50, 0.55, 1.4),  # fleur-de-lis
    "gol/championship/widnes-vikings": (0.50, 0.45, 2.4),  # viking
    "gol/super-league/wigan-warriors": (0.50, 0.48, 2.0),  # warrior
    "gol/championship/london-broncos": (0.55, 0.45, 1.3),  # horse
    "gol/championship/batley-bulldogs": (0.50, 0.35, 2.2),  # bulldog
    "gol/super-league/bradford-bulls": (0.50, 0.50, 2.4),  # bull
    "gol/championship/sheffield-eagles": (0.40, 0.30, 2.0),  # eagle
    "gol/other-clubs/featherstone-rovers": (0.50, 0.55, 1.6),  # crest
    "gol/other-clubs/halifax": (0.55, 0.62, 1.8),  # panther
    "gol/championship/rochdale-hornets": (0.50, 0.32, 1.8),  # hornet
    "gol/championship/swinton-lions": (0.50, 0.38, 1.6),  # lion
    "gol/championship/oldham": (0.50, 0.42, 1.8),  # crest
    "gol/super-league/toulouse-olympique": (0.50, 0.56, 1.6),  # TO
    "gol/championship/dewsbury-rams": (0.50, 0.66, 2.1),  # ram
    "gol/other-clubs/all-golds": (0.52, 0.36, 1.4),  # fern
    "gol/other-clubs/coventry-bears": (0.50, 0.25, 3.0),  # bear
    "gol/championship/keighley-cougars": (0.50, 0.30, 2.0),  # cougar
    "gol/championship/north-wales-crusaders": (0.50, 0.35, 1.7),  # feathers
    "gol/championship/doncaster": (0.50, 0.47, 1.7),  # crest
    "gol/championship/hunslet": (0.50, 0.45, 2.5),  # lion
    "gol/championship/midlands-hurricanes": (0.50, 0.50, 1.1),  # wordmark
    "gol/other-clubs/south-wales-ironmen": (0.50, 0.30, 2.2),  # ironman
    "gol/super-league/york-knights": (0.50, 0.50, 1.8),  # knight
    "gol/championship/barrow-raiders": (0.45, 0.60, 1.5),  # fireball
    "gol/other-clubs/london-skolars": (0.50, 0.55, 1.6),  # cross
    "gol/other-clubs/hemel-stags": (0.50, 0.55, 1.2),  # stag
    "gol/championship/newcastle-thunder": (0.50, 0.50, 1.0),  # wordmark
    "gol/championship/goole-vikings": (0.50, 0.50, 1.3),  # viking
    "gol/championship/whitehaven": (0.50, 0.50, 1.4),  # crest
    "gol/championship/workington-town": (0.50, 0.42, 1.8),  # crest
}

# Clubs whose badge-basic24 lacks the detail worth zooming on (the Cowboys'
# basic badge has no star, the Eels' is the anniversary badge): crop this
# file instead.
DYNASTY_SOURCE = {"nrl/cowboys": ["badge.svg"], "nrl/eels": ["proper-logo.webp"]}

# Dynasty fill overrides (single-colour logos that match their stock fill).
DYNASTY_FILL = {"world-cup/scotland": (255, 255, 255), "gol/other-clubs/all-golds": (24, 24, 28)}

ci.MASTER_SIZE = 2048


def team_dir(team):
    if team.startswith("gol/"):
        return os.path.join(GOL_LOGOS, team[len("gol/"):])
    return os.path.join(LOGOS, team)


def badge(team, kind):
    if team in LOGO_OVERRIDE:
        return os.path.join(team_dir(team), LOGO_OVERRIDE[team][kind])
    names = ["badge-light.svg", "badge.svg"] if kind == "light" and team not in NO_LIGHT else ["badge.svg"]
    names.append("badge.png")
    for name in names:
        path = os.path.join(team_dir(team), name)
        if os.path.exists(path):
            return path
    raise SystemExit(f"{team}: no {' / '.join(names)}")


def stock_blob(blobset, idx):
    """The entry's stock blob: from pack.py's install backup when the entry is
    already modded (so regenerating never needs a restore), else live."""
    meta_path = pack.backup_meta_path(idx)
    if not os.path.exists(meta_path):
        return ce.read_blob_full(blobset, idx)[0]
    with open(meta_path) as f:
        meta = json.load(f)
    with open(meta["blob_backup"], "rb") as f:
        raw = f.read()
    main_c, main_u = meta["main_compressed_size"], meta["main_uncompressed_size"]
    vram_c, vram_u = meta["vram_compressed_size"], meta["vram_uncompressed_size"]
    # same branching as classify_entries.read_blob_full
    if main_c == main_u and vram_c == vram_u:
        return raw
    if main_c != main_u and vram_u == 0:
        return ce.decode_outer_zstd_frames(raw)
    if main_c == main_u or vram_c == vram_u:
        return raw[:main_u] + ce.decode_outer_zstd_frames(raw[main_u:])
    return ce.decode_outer_zstd_frames(raw)


def stock_textures(blobset, icon):
    """[(logical path, layout key, stock image)] for every variant."""
    data, files_count, hash_off, _ = pack.read_index(blobset)
    out = []
    for variant, key in ci.VARIANTS:
        path = variant.format(icon=icon) + ".texture"
        idx = add_entries.find_entry(data, files_count, hash_off, path)
        if idx is None:
            continue  # a few icons don't ship every variant
        _p, dds, _r, _w, _h, _t = et.parse_mini_txpk(stock_blob(blobset, idx))
        out.append((path, key, ci.decode_dds(dds)))
    return out


def main_colour(img):
    counts = Counter()
    small = img.copy()
    small.thumbnail((128, 128))
    pixels = small.get_flattened_data() if hasattr(small, "get_flattened_data") else small.getdata()
    for r, g, b, a in pixels:
        if a == 255 and not (r > 235 and g > 235 and b > 235):
            counts[(r // 8 * 8 + 4, g // 8 * 8 + 4, b // 8 * 8 + 4)] += 1
    return counts.most_common(1)[0][0]


def contrast(square, fill):
    """Mean colour distance between the logo's opaque pixels and the fill."""
    small = square.copy()
    small.thumbnail((128, 128))
    pixels = small.get_flattened_data() if hasattr(small, "get_flattened_data") else small.getdata()
    dists = [sum((c - f) ** 2 for c, f in zip((r, g, b), fill)) ** 0.5 for r, g, b, a in pixels if a > 200]
    return sum(dists) / max(1, len(dists))


def render_dynasty(square, shield_alpha, fill, focus, scale):
    """club_icons.render_dynasty, but with the master square scaled to
    zoom x the inner height and shifted so the focus point sits at the
    shield's centre. The white rim scales with the canvas."""
    fx, fy, zoom = focus
    inner_alpha = shield_alpha.filter(ImageFilter.MinFilter(2 * ci.SHIELD_RIM * scale + 1))
    bbox = inner_alpha.getbbox()
    side = zoom * (bbox[3] - bbox[1])
    cx, cy = (bbox[0] + bbox[2]) / 2, (bbox[1] + bbox[3]) / 2

    inside = ci.gradient(shield_alpha.size, fill)
    ci.paste_square(inside, square, side, cx + (0.5 - fx) * side, cy + (0.5 - fy) * side)

    out = Image.new("RGBA", shield_alpha.size, (0, 0, 0, 0))
    out.paste(Image.new("RGBA", shield_alpha.size, ci.WHITE), (0, 0), shield_alpha)
    out.paste(inside, (0, 0), inner_alpha)
    return out


# Strip logo box as a fraction of the canvas (width, height). The logo's own
# outline is fitted (no square padding), so tall badges fill the height and
# wide logos use the width.
STRIP_BOX = (0.92, 1.0)


def render_strip(logos, size, fill):
    """hud_player / advance_tile (wide club-list strips): the whole logo as
    big as fits, centred on a team-colour gradient - whichever logo stands
    out more against the fill."""
    logo = max(logos, key=lambda im: contrast(im, fill))
    w, h = size
    k = min(w * STRIP_BOX[0] / logo.width, h * STRIP_BOX[1] / logo.height)
    fitted = logo.resize((max(1, round(logo.width * k)), max(1, round(logo.height * k))), Image.LANCZOS)
    img = ci.gradient(size, fill)
    img.alpha_composite(fitted, ((w - fitted.width) // 2, (h - fitted.height) // 2))
    return img


def strip_size(key, stock_img, scale):
    return VARIANT_SIZE.get(key) or (stock_img.width * scale, stock_img.height * scale)


def render_stock_strips(stock, scale):
    """Strips for icons with no new source art, built from the icon's own
    stock large_mirrored logo (its cleanest whole-logo texture)."""
    by_key = {k: img for _p, k, img in stock}
    logo = by_key["large_mirrored"]
    logo = logo.crop(logo.getbbox()) if logo.getbbox() else logo
    fill = main_colour(by_key["dynasty"]) if "dynasty" in by_key else ci.auto_fill(logo)
    return [(path, key, img, render_strip([logo], strip_size(key, img, scale), fill))
            for path, key, img in stock if key in ("hud_player", "advance_tile")]


def render(icon, team, stock, scale, legacy_header):
    logos = {kind: ci.load_logo(badge(team, kind)) for kind in ("light", "colour")}
    squares = {kind: ci.master_square(logo) for kind, logo in logos.items()}
    basics = [ci.master_square(ci.load_logo(os.path.join(team_dir(team), name)))
              for name in DYNASTY_SOURCE.get(team, ["badge-basic24.svg", "badge-basic24-light.svg"])
              if os.path.exists(os.path.join(team_dir(team), name))]
    if not basics:
        basics = list({badge(team, "light"): squares["light"], badge(team, "colour"): squares["colour"]}.values())
    stock_dynasty = next((img for _p, k, img in stock if k == "dynasty"), None)
    results = []
    for path, key, stock_img in stock:
        if key not in REPLACED:
            continue
        size = strip_size(key, stock_img, scale)
        if key == "dynasty":
            fill = DYNASTY_FILL.get(team) or main_colour(stock_img)
            square = max(basics, key=lambda sq: contrast(sq, fill))
            shield = stock_img.getchannel("A").resize(size, Image.LANCZOS)
            img = render_dynasty(square, shield, fill, DYNASTY_FOCUS[team], scale)
        elif key in ("hud_player", "advance_tile"):
            fill = DYNASTY_FILL.get(team) or main_colour(stock_dynasty if stock_dynasty is not None else stock_img)
            img = render_strip(list(logos.values()), size, fill)
        else:
            img = ci.render_layout(squares[REPLACED[key]], size, ci.LAYOUTS[key])
        results.append((path, key, stock_img, img))
    return results


def write_preview(icon, results):
    pad = 10
    width = sum(new.width for _, _, _, new in results) + pad * (len(results) + 1)
    height = max(new.height for _, _, _, new in results) * 2 + pad * 3
    sheet = Image.new("RGBA", (width, height), (40, 40, 44, 255))
    top = max(new.height for _, _, _, new in results) + 2 * pad
    x = pad
    for _, _, stock_img, new in results:
        sheet.alpha_composite(stock_img.resize(new.size, Image.LANCZOS), (x, pad))
        sheet.alpha_composite(new, (x, top))
        x += new.width + pad
    os.makedirs(os.path.join(HERE, "previews"), exist_ok=True)
    sheet.save(os.path.join(HERE, "previews", f"{icon}.png"))


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--blobset", default=pack.BLOBSET_PATH)
    ap.add_argument("--scale", type=int, default=2, help="canvas size as a multiple of the stock size")
    ap.add_argument("--variants", nargs="+", help="only write these layout keys (e.g. hud_player advance_tile); previews still show all")
    ap.add_argument("--all-icons", action="store_true",
                    help="also write hud_player / advance_tile strips for every other club icon in the game, from its stock logo")
    ap.add_argument("icons", nargs="*", help="default: every icon in TEAMS")
    args = ap.parse_args()

    _sizes, legacy_header, _shield = ci.template_info(args.blobset, "cus_01")
    tex_dir = os.path.join(HERE, "textures")
    os.makedirs(tex_dir, exist_ok=True)
    for icon in args.icons or TEAMS:
        results = render(icon, TEAMS[icon], stock_textures(args.blobset, icon), args.scale, legacy_header)
        for path, key, _stock, img in results:
            if args.variants and key not in args.variants:
                continue
            write_texture(tex_dir, path, key, img, legacy_header)
        write_preview(icon, results)
        print(f"{icon}: {len(results)} textures ({TEAMS[icon]})")
    if args.all_icons:
        for icon in other_icons(args.blobset):
            results = render_stock_strips(stock_textures(args.blobset, icon), args.scale)
            for path, key, _stock, img in results:
                write_texture(tex_dir, path, key, img, legacy_header)
            write_preview(icon, results)
            print(f"{icon}: {len(results)} strips (stock logo)")


def write_texture(tex_dir, path, key, img, legacy_header):
    name = f"{entries.fnv1a64(path.lower()):016x}_{path.split('/')[-2] if key != 'dynasty' else 'dynasty'}_{path.split('/')[-1][:-len('.texture')]}.dds"
    with open(os.path.join(tex_dir, name), "wb") as f:
        f.write(ci.make_dds(ci.premultiply(img), legacy_header))


def other_icons(blobset):
    """Every club icon named in the stock or modded clublist.lua that ships a
    hud_player strip and isn't in TEAMS."""
    names = set()
    for rel in ("decompiled/src/script-game/intermediatelua/convant/clublist.lua",
                "mods/new-club-icons/src/script-game/intermediatelua/convant/clublist.lua"):
        with open(os.path.join(REPO, rel), encoding="utf-8-sig") as f:
            names |= set(re.findall(r'"([a-z0-9_]+)"', f.read()))
    data, files_count, hash_off, _ = pack.read_index(blobset)
    return sorted(n for n in names if n not in TEAMS and
                  add_entries.find_entry(data, files_count, hash_off, f"ui/club_logos/hud_player/{n}.texture") is not None)


if __name__ == "__main__":
    main()
