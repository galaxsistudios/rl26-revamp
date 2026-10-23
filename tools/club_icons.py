#!/usr/bin/env python3
"""
club_icons.py - add a NEW club emblem (icon) to the game from one image,
laid out the way the shipped art is.

An icon name (e.g. "nrl_warriors") resolves to 15 textures, the same set for
every shipped icon, licensed or generic (cus_01, nsw_bears, rep_bigant_male):
    ui/club_logos/{64,small,large_mirrored,plinths,field,flags,hud_intro,
                   hud_lineup,hud_player,hud_score}/<icon>.texture
    ui/club_logos/bg_logo/<icon>_l.texture, <icon>_r.texture (identical)
    noesis/workspace/images/club_logos/{256,advance_tile}/<icon>.texture
    noesis/workspace/images/dynasty/icons/club_logos/<icon>.texture
The native side builds these paths from the names Lua registers in
preloadassets.lua (native.CIconNames, path "ui/club_logos"), so a new icon
also needs its name added to clublist.lua's ClubIconsPreload / ClubIcons
lists and icons.lua's ClubIconColourSetMap - see mods/new-club-icons.

Layout (measured 2026-10-23 against cus_01, rep_nsw and sl_wigan by fitting
each variant to the clean large_mirrored logo):
  - Every variant is one "master square" - the logo fitted into a box 85%
    wide x 95% tall, centred - scaled to LAYOUTS[variant].scale x the
    canvas height, shifted by .dy x canvas height, on .bg. The per-variant
    scale is the same for every icon (hud_player / 64 = 2.60, 2.63, 2.59).
  - The dynasty icon is a fixed shield (alpha identical across every icon,
    so it's lifted from the template's own texture) with a ~5px white rim;
    inside, a vertical gradient of the fill colour and the master square
    zoomed to 1.8x the inner height, clipped.
  - Licensed NRL clubs ship hand-drawn colour-tile versions of some
    variants; generic clubs use the plain layouts above. --hud-score-tile
    makes hud_score a 128x128 NRL-style tile instead of the generic 48x80.

Each canvas size is read from a template icon (cus_01: generic sizes).
Every variant is written as uncompressed 32-bit BGRA with premultiplied
alpha (like the shipped UI textures), even the three the game ships as BC7:
the Mini_TXPK header's image_type is 1 for both, so the engine takes the
pixel format from the DDS header itself.

Entries are appended with add_entries.py (undo with its remove-all).

Usage:
    python club_icons.py preview --icon nrl_bears --image logo.svg --out sheet.png [--fill "#c8102e"]
    python club_icons.py add --icon nrl_bears --image logo.svg [--fill ...] [--hud-score-tile] [--replace] [--confirm]
"""

import argparse
import colorsys
import io
import os
import struct
import sys
from collections import namedtuple

from PIL import Image, ImageDraw, ImageFilter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import add_entries  # noqa: E402
import classify_entries as ce  # noqa: E402
import extract_textures as et  # noqa: E402
import pack  # noqa: E402
import texture_mods  # noqa: E402

Layout = namedtuple("Layout", "scale dy bg")

# (path template, layout key)
VARIANTS = [
    ("ui/club_logos/64/{icon}", "64"),
    ("ui/club_logos/small/{icon}", "small"),
    ("ui/club_logos/large_mirrored/{icon}", "large_mirrored"),
    ("ui/club_logos/plinths/{icon}", "plinths"),
    ("ui/club_logos/field/{icon}", "field"),
    ("ui/club_logos/flags/{icon}", "flags"),
    ("ui/club_logos/hud_intro/{icon}", "hud_intro"),
    ("ui/club_logos/hud_lineup/{icon}", "hud_lineup"),
    ("ui/club_logos/hud_player/{icon}", "hud_player"),
    ("ui/club_logos/hud_score/{icon}", "hud_score"),
    ("ui/club_logos/bg_logo/{icon}_l", "bg_logo"),
    ("ui/club_logos/bg_logo/{icon}_r", "bg_logo"),
    ("noesis/workspace/images/club_logos/256/{icon}", "256"),
    ("noesis/workspace/images/club_logos/advance_tile/{icon}", "advance_tile"),
    ("noesis/workspace/images/dynasty/icons/club_logos/{icon}", "dynasty"),
]

BLACK = (2, 2, 2, 255)
WHITE = (255, 255, 255, 255)
LAYOUTS = {
    "64": Layout(1.0, 0.0, None),
    "small": Layout(0.89, 0.0, None),
    "large_mirrored": Layout(1.0, 0.0, None),
    "plinths": Layout(1.05, -0.05, BLACK),
    "field": Layout(1.0, 0.0, WHITE),
    "flags": Layout(1.15, -0.03, WHITE),
    "hud_intro": Layout(2.0, -0.05, None),
    "hud_lineup": Layout(1.95, -0.10, BLACK),
    "hud_player": Layout(2.65, 0.0, None),
    "hud_score": Layout(1.18, -0.05, None),
    "bg_logo": Layout(0.83, 0.0, None),
    "256": Layout(1.0, 0.0, None),
    "advance_tile": Layout(2.6, 0.0, None),
}

# Master square: logo fitted into this fraction of the square's width / height.
MASTER_SIZE = 1024
MASTER_BOX = (0.85, 0.95)

# Dynasty shield: white rim width, logo zoom (x inner height) and offset.
SHIELD_RIM = 5
SHIELD_ZOOM = 1.8
SHIELD_DY = -0.05

# --hud-score-tile: NRL-style colour tile.
HUD_TILE_SIZE = (128, 128)
HUD_TILE_ZOOM = 1.8

# `scorebug` drafts: canvas size, logo zoom (x canvas) and vertical offset.
SCOREBUG_SIZE = 512
SCOREBUG_ZOOM = 1.6
SCOREBUG_DY = 0.0

DEFAULT_FILL = (225, 225, 228)


def load_logo(image_path):
    if image_path.lower().endswith(".svg"):
        import resvg_py
        with open(image_path, encoding="utf-8") as f:
            svg = f.read()
        img = Image.open(io.BytesIO(bytes(resvg_py.svg_to_bytes(svg_string=svg, width=MASTER_SIZE))))
    else:
        img = Image.open(image_path)
    img = img.convert("RGBA")
    bbox = img.getbbox()
    return img.crop(bbox) if bbox else img


def master_square(logo):
    n = MASTER_SIZE
    scale = min(n * MASTER_BOX[0] / logo.width, n * MASTER_BOX[1] / logo.height)
    size = (max(1, round(logo.width * scale)), max(1, round(logo.height * scale)))
    square = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    square.alpha_composite(logo.resize(size, Image.LANCZOS), ((n - size[0]) // 2, (n - size[1]) // 2))
    return square


def paste_square(canvas, square, side, cx, cy):
    """Composite the master square scaled to side px, centred at (cx, cy),
    clipped to the canvas."""
    side = max(1, round(side))
    scaled = square.resize((side, side), Image.LANCZOS)
    layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    layer.paste(scaled, (round(cx - side / 2), round(cy - side / 2)))
    canvas.alpha_composite(layer)


def render_layout(square, size, layout):
    w, h = size
    canvas = Image.new("RGBA", size, layout.bg or (0, 0, 0, 0))
    paste_square(canvas, square, layout.scale * h, w / 2, h / 2 + layout.dy * h)
    return canvas


def gradient(size, colour):
    """Vertical gradient: a little lighter at the top, darker at the bottom."""
    w, h = size
    img = Image.new("RGBA", size)
    draw = ImageDraw.Draw(img)
    for y in range(h):
        t = y / max(1, h - 1)
        f = 1.12 - 0.3 * t
        draw.line([(0, y), (w, y)], fill=tuple(min(255, round(c * f)) for c in colour) + (255,))
    return img


def render_dynasty(square, shield_alpha, fill):
    size = shield_alpha.size
    inner_alpha = shield_alpha.filter(ImageFilter.MinFilter(2 * SHIELD_RIM + 1))
    bbox = inner_alpha.getbbox()
    inner_h = bbox[3] - bbox[1]
    cx, cy = (bbox[0] + bbox[2]) / 2, (bbox[1] + bbox[3]) / 2

    inside = gradient(size, fill)
    paste_square(inside, square, SHIELD_ZOOM * inner_h, cx, cy + SHIELD_DY * inner_h)

    badge = Image.new("RGBA", size, (0, 0, 0, 0))
    badge.paste(Image.new("RGBA", size, WHITE), (0, 0), shield_alpha)
    badge.paste(inside, (0, 0), inner_alpha)
    return badge


def render_hud_tile(square, fill):
    tile = gradient(HUD_TILE_SIZE, fill)
    w, h = HUD_TILE_SIZE
    paste_square(tile, square, HUD_TILE_ZOOM * h, w / 2, h / 2 + SHIELD_DY * h)
    return tile


def render_scorebug(square, fill, zoom, dy):
    """Draft art in the nrl-broadcast-scoreboard style (resources/scorebug_img):
    a full-bleed square on a flat team colour with the logo zoomed in so it
    bleeds off the edges."""
    n = SCOREBUG_SIZE
    art = Image.new("RGBA", (n, n), tuple(fill) + (255,))
    paste_square(art, square, zoom * n, n / 2, n / 2 + dy * n)
    return art


def hud_score_from_art(path):
    """Scorebug art -> the 128x128 hud_score the scoreboard mod uses (512 has
    no mipmaps, so it would alias at ~45px). Premultiplied in cmd_add."""
    return Image.open(path).convert("RGBA").resize(HUD_TILE_SIZE, Image.LANCZOS)


def premultiply(img):
    """Shipped UI textures store premultiplied alpha (colour <= alpha, 0 where
    alpha is 0); Pillow's "RGBa" mode is exactly that."""
    return Image.merge("RGBA", (*img.convert("RGBa").split()[:3], img.getchannel("A")))


def auto_fill(logo):
    """Most common saturated colour in the logo, else a light grey (like the
    generic shield)."""
    small = logo.copy()
    small.thumbnail((128, 128))
    counts = {}
    pixels = small.get_flattened_data() if hasattr(small, "get_flattened_data") else small.getdata()
    for r, g, b, a in pixels:
        if a < 200:
            continue
        _h, l, s = colorsys.rgb_to_hls(r / 255, g / 255, b / 255)
        if s < 0.35 or l < 0.12 or l > 0.9:
            continue
        key = (r // 16 * 16 + 8, g // 16 * 16 + 8, b // 16 * 16 + 8)
        counts[key] = counts.get(key, 0) + 1
    if not counts:
        return DEFAULT_FILL
    return max(counts, key=counts.get)


def parse_colour(text):
    text = text.lstrip("#")
    return tuple(int(text[i:i + 2], 16) for i in (0, 2, 4))


def decode_dds(dds):
    h, w = struct.unpack_from("<2I", dds, 12)
    if dds[84:88] == b"DX10":
        import texture2ddecoder
        fmt = struct.unpack_from("<I", dds, 128)[0]
        if fmt not in (98, 99):
            raise SystemExit(f"unsupported template DXGI format {fmt}")
        return Image.frombytes("RGBA", (w, h), texture2ddecoder.decode_bc7(bytes(dds[148:]), w, h), "raw", "BGRA")
    return Image.frombytes("RGBA", (w, h), bytes(dds[128:128 + w * h * 4]), "raw", "BGRA")


def template_info(blobset_path, template_icon):
    """Per-variant canvas sizes from the template icon, one legacy
    uncompressed DDS header to reuse for every output, and the dynasty
    shield's alpha mask."""
    ce.load_index(blobset_path)
    data, files_count, hash_off, _ = pack.read_index(blobset_path)
    sizes = []
    legacy_header = None
    shield_alpha = None
    for variant, key in VARIANTS:
        path = variant.format(icon=template_icon) + ".texture"
        idx = add_entries.find_entry(data, files_count, hash_off, path)
        if idx is None:
            raise SystemExit(f"template texture {path} not found")
        raw, _, _, _ = ce.read_blob_full(blobset_path, idx)
        _path, dds, _raw_path, width, height, _image_type = et.parse_mini_txpk(raw)
        sizes.append((width, height))
        if legacy_header is None and dds[84:88] == b"\x00\x00\x00\x00":
            legacy_header = bytes(dds[:128])
        if key == "dynasty":
            shield_alpha = decode_dds(dds).getchannel("A")
    if legacy_header is None:
        raise SystemExit("template icon has no uncompressed variant to copy a DDS header from")
    return sizes, legacy_header, shield_alpha


def make_dds(img, legacy_header):
    w, h = img.size
    header = bytearray(legacy_header)
    struct.pack_into("<2I", header, 12, h, w)
    struct.pack_into("<I", header, 20, w * 4)  # pitch
    return bytes(header) + img.tobytes("raw", "BGRA")


def make_blob(logical_path, dds):
    h, w = struct.unpack_from("<2I", dds, 12)
    raw_path = "convant2-temp-intermediate/" + logical_path[: -len(".texture")] + ".pc.badds"
    main = struct.pack("<5I", w, h, 1, 20, len(dds)) + raw_path.encode("latin1") + b"\x00"
    vram = texture_mods.encode_outer_chunks(dds)
    return main + vram, (len(main), len(main), len(vram), len(dds))


def build_variants(args):
    sizes, legacy_header, shield_alpha = template_info(args.blobset, args.template)
    logo = load_logo(args.image)
    square = master_square(logo)
    fill = parse_colour(args.fill) if args.fill else auto_fill(logo)
    print(f"fill colour: #{fill[0]:02x}{fill[1]:02x}{fill[2]:02x}")
    out = []
    for (variant, key), size in zip(VARIANTS, sizes):
        if key == "dynasty":
            img = render_dynasty(square, shield_alpha, fill)
        elif key == "hud_score" and args.hud_score_image:
            img = hud_score_from_art(args.hud_score_image)
        elif key == "hud_score" and args.hud_score_tile:
            img = render_hud_tile(square, fill)
        else:
            img = render_layout(square, size, LAYOUTS[key])
        out.append((variant.format(icon=args.icon) + ".texture", img, legacy_header))
    return out


def cmd_preview(args):
    variants = build_variants(args)
    width = sum(img.width for _, img, _ in variants) + 10 * (len(variants) + 1)
    height = max(img.height for _, img, _ in variants) + 20
    sheet = Image.new("RGBA", (width, height), (90, 90, 90, 255))
    x = 10
    for _, img, _ in variants:
        sheet.alpha_composite(img, (x, 10))
        x += img.width + 10
    sheet.save(args.out)
    print(f"wrote {args.out}")


def cmd_scorebug(args):
    logo = load_logo(args.image)
    fill = parse_colour(args.fill) if args.fill else auto_fill(logo)
    art = render_scorebug(master_square(logo), fill, args.zoom, args.dy)
    art.save(args.out)
    print(f"fill colour: #{fill[0]:02x}{fill[1]:02x}{fill[2]:02x}")
    print(f"wrote {args.out}")


def cmd_add(args):
    if args.icon != args.icon.lower():
        raise SystemExit("icon names are lowercase")
    for path, img, legacy_header in build_variants(args):
        dds = make_dds(premultiply(img), legacy_header)
        blob, sizes = make_blob(path, dds)
        add_entries.add_entry(args.blobset, path, blob, sizes, f"{os.path.basename(args.image)} {img.width}x{img.height}", args.confirm, replace=args.replace)
    if not args.confirm:
        print("dry run - pass --confirm to write (close the game first)")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--blobset", default=pack.BLOBSET_PATH)
    sub = ap.add_subparsers(dest="cmd", required=True)
    for name, fn in (("preview", cmd_preview), ("add", cmd_add)):
        p = sub.add_parser(name)
        p.add_argument("--icon", required=True, help="new icon name, e.g. nrl_bears")
        p.add_argument("--image", required=True, help="source logo (.svg, .png, .avif, ...)")
        p.add_argument("--template", default="cus_01", help="existing icon to copy canvas sizes and the shield from")
        p.add_argument("--fill", help="badge/tile fill colour, e.g. '#c8102e' (default: the logo's main colour)")
        p.add_argument("--hud-score-tile", action="store_true", help="NRL-style 128x128 colour tile for hud_score")
        p.add_argument("--hud-score-image", help="square scorebug art for hud_score (e.g. resources/scorebug_img/<icon>.png)")
        if name == "preview":
            p.add_argument("--out", required=True)
        else:
            p.add_argument("--confirm", action="store_true", help="required to actually write")
            p.add_argument("--replace", action="store_true", help="overwrite an icon this tool added before")
        p.set_defaults(func=fn)

    p_bug = sub.add_parser("scorebug", help="draft 512x512 scoreboard crest art (nrl-broadcast-scoreboard style)")
    p_bug.add_argument("--image", required=True, help="source logo (.svg, .png, .avif, ...)")
    p_bug.add_argument("--out", required=True, help="e.g. resources/scorebug_img/nrl_bears.png")
    p_bug.add_argument("--fill", help="background colour (default: the logo's main colour)")
    p_bug.add_argument("--zoom", type=float, default=SCOREBUG_ZOOM, help="logo size as a multiple of the canvas")
    p_bug.add_argument("--dy", type=float, default=SCOREBUG_DY, help="vertical offset as a fraction of the canvas")
    p_bug.set_defaults(func=cmd_scorebug)
    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    sys.exit(main())
