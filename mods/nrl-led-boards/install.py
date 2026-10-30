#!/usr/bin/env python3
"""
install.py - per-home-team LED sponsor boards, built from config/boards/*/board.json.

Every board is one new texture, stadiums/textures/sponsors/lcd/revamp/
lcd_revamp_<board>_col.texture: a stack of 2048x128 rows (16:1, the row
size every stock LED texture uses), one sponsor per row. The stadium's own
LED material (technique es2_lcdsign) shows one row at a time, holds it for
persistTime seconds and wipes/fades to the next over transitionTime; its
gridRows / gridRows_active say how many rows the texture holds. Stock
textures set those per ground (Knights 4/3, NRL 8/8, Accor 12/9), so the
Lua side (stadiummodel.lua) sets them for ours.

config/sponsors/ holds every sponsor once, shared by all boards:
    <id>.png        the sponsor's finished 2048x128 row - what gets installed
    logos/          the source logos
    sponsors.json   per sponsor: name, logo (or a stock LED row), background,
                    repeat, margin - the recipe `rows` makes <id>.png from.
                    "manual": true = a hand-made PNG `rows` never overwrites.
config/boards/<board>/board.json lists sponsor ids in order:
    default/      the mod's own sponsors (added to every board), the timing,
                  the row order, and the fallback competition
    <comp>/       "type": "competition" - its sponsors, and the stadium
                  sponsorTypes it covers (stadium-cfg.lua, e.g. "nrl")
    <team>/       "type": "team" - its sponsors, its competition, and the
                  club full names it matches (any of them, case-insensitive)
Board textures: every team (team + competition + default rows), every
competition (competition + default rows, for home clubs without a team
board) and default (fallback competition + default rows).

Which board loads (stadiumconfig.lua): the home club's team board, else the
competition board for the ground's sponsorType, else default. Magic Round,
Challenge Cup, Women's Super League and RLWC matches keep the stock boards.
Grounds whose hoardings have no LED panels (e.g. Penrith Stadium,
Leichhardt, Campbelltown, WIN Stadium) show nothing different.

The Lua table that maps clubs to boards lives between the GENERATED markers
in stadiumconfig.lua and lists only boards whose texture is in the live
index (`lua`), so a board that failed to build is never loaded.

Usage (repo root, game closed):
    python mods/nrl-led-boards/install.py rows [ID ...]          # sponsor PNGs from sponsors.json
    python mods/nrl-led-boards/install.py sheet                  # _build/nrl-led-boards/sponsors.png
    python mods/nrl-led-boards/install.py build [--texconv PATH] [--board NAME ...]
    python mods/nrl-led-boards/install.py install [--replace] [--confirm]
    python mods/nrl-led-boards/install.py lua
Previews: _build/nrl-led-boards/<board>.png (upright, as it reads in game).
"""

import argparse
import glob
import io
import json
import os
import re
import subprocess
import sys
import tempfile

import numpy as np
import resvg_py
from PIL import Image, ImageDraw

MOD = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(MOD))
sys.path.insert(0, os.path.join(REPO, "tools"))
import classify_entries as ce  # noqa: E402
import dump_led_boards  # noqa: E402
import entries  # noqa: E402
import games  # noqa: E402
import pack  # noqa: E402

BOARDS_DIR = os.path.join(MOD, "config", "boards")
SPONSORS_DIR = os.path.join(MOD, "config", "sponsors")
BUILD_DIR = os.path.join(REPO, "_build", "nrl-led-boards")
LUA = os.path.join(MOD, "src", "script-game", "rendering", "stadium", "stadiumconfig.lua")
BEGIN, END = "-- BEGIN GENERATED (install.py lua)", "-- END GENERATED"
TEXDIR = "stadiums/textures/sponsors/lcd/revamp"
ROW_W, ROW_H = 2048, 128
DARK = (14, 14, 18)
# an event board's "match" keys: enum-name lists, stadium keys, or a flag
EVENT_MATCH_KEYS = ("specialEvent", "competition", "fieldMarkings", "ground", "isFinal")


def texture_path(board):
    return f"{TEXDIR}/lcd_revamp_{board}_col.texture"


# ---- config -----------------------------------------------------------------

def load_sponsors():
    return {k: v for k, v in json.load(open(os.path.join(SPONSORS_DIR, "sponsors.json"), encoding="utf-8")).items()
            if not k.startswith("_")}


def load_boards():
    sponsors = load_sponsors()
    boards = {}
    for path in sorted(glob.glob(os.path.join(BOARDS_DIR, "*", "board.json"))):
        name = os.path.basename(os.path.dirname(path))
        if not re.fullmatch(r"[a-z0-9_]+", name):
            raise SystemExit(f"{path}: board folder names must be lowercase a-z, 0-9, _")
        boards[name] = json.load(open(path, encoding="utf-8"))
    if "default" not in boards:
        raise SystemExit("boards/default/board.json is missing")
    for name, cfg in boards.items():
        kind = cfg.get("type", "default" if name == "default" else None)
        if kind not in ("default", "competition", "team", "event"):
            raise SystemExit(f"boards/{name}: type must be \"team\", \"competition\" or \"event\"")
        if kind == "event":
            unknown = set(cfg.get("match", {})) - set(EVENT_MATCH_KEYS)
            if unknown or not cfg.get("match"):
                raise SystemExit(f"boards/{name}: match needs some of {EVENT_MATCH_KEYS} (got {sorted(cfg.get('match', {}))})")
        cfg["type"] = kind
        comp = cfg.get("competition")
        if comp and boards.get(comp, {}).get("type") != "competition":
            raise SystemExit(f"boards/{name}: competition {comp!r} has no boards/{comp}/board.json of type competition")
        for sid in cfg.get("sponsors", []):
            if sid not in sponsors:
                raise SystemExit(f"boards/{name}: sponsor {sid!r} is not in sponsors/sponsors.json")
    return boards


def sponsor_path(sid):
    return os.path.join(SPONSORS_DIR, sid + ".png")


def club_path(board):
    return os.path.join(BOARDS_DIR, board, "club.png")


def board_rows(boards, name):
    """Row image paths for a board, in the default board's order."""
    default = boards["default"]
    cfg = boards[name]
    mod = [sponsor_path(s) for s in default.get("sponsors", [])]
    if cfg["type"] == "event":
        return [sponsor_path(s) for s in cfg.get("sponsors", [])] + mod
    groups = {"club": [], "team": [], "competition": [], "mod": mod}
    comp = name if cfg["type"] == "competition" else cfg.get("competition", default.get("competition"))
    if comp:
        groups["competition"] = [sponsor_path(s) for s in boards[comp].get("sponsors", [])]
    if cfg["type"] == "team":
        groups["team"] = [sponsor_path(s) for s in cfg.get("sponsors", [])]
        if cfg.get("identity"):
            groups["club"] = [club_path(name)]
    rows = [p for group in default.get("order", ["club", "team", "competition", "mod"]) for p in groups[group]]
    if not rows:
        raise SystemExit(f"boards/{name}: no rows")
    return rows


# ---- sponsor rows -----------------------------------------------------------

_stock_cache = {}


def stock_texture(name):
    """A stock LED texture by name (e.g. lcd_sponsor_nrl_col), upright RGB."""
    if name not in _stock_cache:
        for _ground, _variant, texpack in dump_led_boards.hoarding_variants():
            try:
                members = dump_led_boards.stock_txpk(entries.index_of(texpack))
            except KeyError:
                continue
            for path, dds in members:
                if path.rsplit("/", 1)[-1] == name:
                    _stock_cache[name] = Image.open(io.BytesIO(dds)).convert("RGB").transpose(Image.FLIP_TOP_BOTTOM)
                    break
            if name in _stock_cache:
                break
        else:
            raise SystemExit(f"stock LED texture {name!r} not found in any stadium hoarding bundle")
    return _stock_cache[name]


def stock_row(texture, row):
    """Row `row` (0 = top) of a stock LED texture, as a 2048x128 row."""
    src = stock_texture(texture)
    scale = src.width / ROW_W
    y = round(row * ROW_H * scale)
    if y + round(ROW_H * scale) > src.height:
        raise SystemExit(f"{texture} has only {src.height // round(ROW_H * scale)} rows")
    return src.crop((0, y, src.width, y + round(ROW_H * scale))).resize((ROW_W, ROW_H), Image.LANCZOS)


def load_logo(path):
    """The logo as RGBA, uncropped."""
    head = open(path, "rb").read(256).lstrip()
    if path.lower().endswith(".svg") or head.startswith(b"<svg") or head.startswith(b"<?xml"):
        return Image.open(io.BytesIO(bytes(resvg_py.svg_to_bytes(svg_path=path, width=2048)))).convert("RGBA")
    return Image.open(path).convert("RGBA")


def edge_colour(logo):
    """The logo's own background (e.g. a white tile) when its whole border is
    one opaque colour, else None."""
    a = np.asarray(logo).astype(np.int32)
    border = np.concatenate([a[0], a[-1], a[:, 0], a[:, -1]])
    if (border[:, 3] < 250).mean() > 0.05:
        return None
    rgb = border[:, :3]
    med = np.median(rgb, axis=0)
    if (np.abs(rgb - med).max(axis=1) > 24).mean() > 0.1:
        return None
    return tuple(int(v) for v in med)


def trim(logo, background):
    """Crop to the artwork: alpha, or (on an opaque tile) the pixels that
    differ from the tile colour."""
    a = np.asarray(logo).astype(np.int32)
    if background is None:
        mask = a[..., 3] > 8
    else:
        mask = (np.abs(a[..., :3] - np.array(background)).max(axis=2) > 24) & (a[..., 3] > 8)
    ys, xs = np.nonzero(mask)
    if not len(xs):
        return logo
    return logo.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))


def auto_background(logo):
    """White behind a dark logo, near-black behind a light one."""
    a = np.asarray(logo).astype(np.float32)
    w = a[..., 3] / 255
    lum = (a[..., :3] @ np.array([0.299, 0.587, 0.114], np.float32))
    mean = (lum * w).sum() / max(w.sum(), 1)
    return DARK if mean > 170 else (255, 255, 255)


def lighten(logo):
    """Dark, colourless parts (black/grey lettering) become white; coloured
    parts keep their colour - for putting a dark logo on a dark brand colour."""
    a = np.asarray(logo).astype(np.float32)
    rgb = a[..., :3]
    sat = rgb.max(axis=2) - rgb.min(axis=2)
    lum = rgb @ np.array([0.299, 0.587, 0.114], np.float32)
    grey = (sat < 48) & (lum < 200)
    a[grey, :3] = 255
    return Image.fromarray(a.astype(np.uint8))


def logo_row(logo, background, repeat, margin, white=False, light=False):
    """A 2048x128 row: the logo `repeat` times, centred in equal cells."""
    if white:
        a = np.array(logo)
        a[..., :3] = 255
        logo = Image.fromarray(a)
    elif light:
        logo = lighten(logo)
    out = Image.new("RGBA", (ROW_W, ROW_H), tuple(background) + (255,))
    cell_w = ROW_W / repeat
    pad = margin * ROW_H
    scale = min((cell_w - 2 * pad) / logo.width, (ROW_H - 2 * pad) / logo.height)
    logo = logo.resize((max(1, round(logo.width * scale)), max(1, round(logo.height * scale))), Image.LANCZOS)
    for k in range(repeat):
        out.alpha_composite(logo, (round(cell_w * k + (cell_w - logo.width) / 2), round((ROW_H - logo.height) / 2)))
    return out.convert("RGB")


def auto_repeat(logo, margin):
    """As many copies as fill the row with a gap of about one logo height
    between them: a square badge repeats ~8 times, a wide wordmark 2-3."""
    h = ROW_H * (1 - 2 * margin)
    w = h * logo.width / logo.height
    return max(2, min(8, int(ROW_W // (w + 1.1 * h))))


def make_row(spec):
    if "stock" in spec:
        return stock_row(spec["stock"], spec.get("row", 0))
    logo = load_logo(os.path.join(SPONSORS_DIR, "logos", spec["logo"]))
    if spec.get("knockout"):
        # a card behind the logo (e.g. a rounded white tile): that colour goes see-through
        a = np.asarray(logo).astype(np.int32)
        diff = np.abs(a[..., :3] - np.array(spec["knockout"])).max(axis=2)
        a[..., 3] = np.minimum(a[..., 3], np.clip((diff - 16) * 255 // 48, 0, 255))
        logo = Image.fromarray(a.astype(np.uint8))
    tile = edge_colour(logo)
    logo = trim(logo, tile)
    if tile is not None:
        # an opaque tile: make the tile colour see-through so the row is one colour
        a = np.asarray(logo).astype(np.int32)
        diff = np.abs(a[..., :3] - np.array(tile)).max(axis=2)
        a[..., 3] = np.minimum(a[..., 3], np.clip(diff * 255 // 48, 0, 255))
        logo = Image.fromarray(a.astype(np.uint8))
    margin = spec.get("margin", 0.12)
    background = spec.get("background") or tile or auto_background(logo)
    repeat = spec.get("repeat") or auto_repeat(logo, margin)
    return logo_row(logo, background, repeat, margin, spec.get("white", False), spec.get("light", False))


def load_row(path):
    """An installed row image, as 2048x128."""
    if not os.path.exists(path):
        raise SystemExit(f"{path} missing - run `install.py rows`")
    im = Image.open(path).convert("RGB")
    if abs(im.width / im.height - ROW_W / ROW_H) > 0.5:
        raise SystemExit(f"{path} is {im.width}x{im.height}; a row is 2048x128 (16:1)")
    return im.resize((ROW_W, ROW_H), Image.LANCZOS) if im.size != (ROW_W, ROW_H) else im


def res_path(rel):
    return os.path.join(REPO, "resources", rel[4:]) if rel.startswith("res:") else os.path.join(MOD, rel)


def recolour(im, rgb):
    a = np.array(im)
    a[..., :3] = rgb
    return Image.fromarray(a)


def club_row(identity):
    """The club's badge and wordmark (recoloured to its secondary colour) on
    its primary colour, `repeat` times across the row, as big as they go:
    the badge is taller than the row (badge_height, x row height) and is
    cropped evenly top and bottom; the wordmark fills wordmark_height of the
    row. A pair wider than its cell shrinks to fit, wordmark first (the
    badge keeps at least the full row height)."""
    primary, secondary = identity["colours"]
    badge = trim(load_logo(res_path(identity["badge"])), None)
    crop = identity.get("crop")
    if crop:
        # [x0, y0, x1, y1] as fractions of the badge: the part around the
        # eyes, which then fills the row's height
        x0, y0, x1, y1 = crop
        badge = badge.crop((round(x0 * badge.width), round(y0 * badge.height),
                            round(x1 * badge.width), round(y1 * badge.height)))
        # a side the crop cut through fades out instead of ending in a hard edge
        feather = identity.get("feather", 0.14)
        a = np.array(badge)
        n = max(1, round(badge.width * feather))
        ramp = np.linspace(0, 1, n, dtype=np.float32)
        alpha = a[..., 3].astype(np.float32)
        if x0 > 0:
            alpha[:, :n] *= ramp
        if x1 < 1:
            alpha[:, -n:] *= ramp[::-1]
        a[..., 3] = alpha.astype(np.uint8)
        badge = Image.fromarray(a)
    word = recolour(trim(load_logo(res_path(identity["wordmark"])), None), secondary)
    repeat = identity.get("repeat", 2)
    cell = ROW_W / repeat
    if identity.get("focus"):
        return focus_row(badge, word, primary, repeat, cell, identity)
    room = cell * 0.92
    bh = ROW_H * identity.get("badge_height", 1.0 if crop else 1.3)
    wh = ROW_H * identity.get("wordmark_height", 0.78)
    gap = ROW_H * 0.2

    def widths(bh, wh):
        return bh * badge.width / badge.height, wh * word.width / word.height

    bw, ww = widths(bh, wh)
    if bw + gap + ww > room:
        # shrink the wordmark first, down to half its height, then both
        ww = max(room - bw - gap, ww * 0.5)
        wh = ww * word.height / word.width
        if bw + gap + ww > room:
            s = room / (bw + gap + ww)
            bh, wh, gap = max(ROW_H, bh * s), wh * s, gap * s
            bw, ww = widths(bh, wh)
            if bw + gap + ww > room:
                ww = room - bw - gap
                wh = ww * word.height / word.width
    badge = badge.resize((max(1, round(bw)), max(1, round(bh))), Image.LANCZOS)
    word = word.resize((max(1, round(ww)), max(1, round(wh))), Image.LANCZOS)
    unit_w = badge.width + round(gap) + word.width
    out = Image.new("RGBA", (ROW_W, ROW_H), tuple(primary) + (255,))
    for k in range(repeat):
        x = round(cell * k + (cell - unit_w) / 2)
        # paste() crops what falls outside the row: the badge's top and bottom
        out.paste(badge, (x, round((ROW_H - badge.height) / 2)), badge)
        out.alpha_composite(word, (x + badge.width + round(gap), round((ROW_H - word.height) / 2)))
    return out.convert("RGB")


def focus_row(badge, word, primary, repeat, cell, identity):
    """Club row zoomed on the badge's eyes: focus = {"eye": [x, y], "span": h}
    (fractions of the badge). The badge fills the left badge_width of each
    cell: the window shown is h of the badge's height, at the shape of that
    area, centred on the eye; its left and right edges fade out. The wordmark
    fills the rest of the cell."""
    (ex, ey), span = identity["focus"]["eye"], identity["focus"]["span"]
    bw = round(cell * identity.get("badge_width", 0.4))
    win_h = span * badge.height
    win_w = win_h * bw / ROW_H
    # nudge = [dx, dy] in row pixels: moves the logo right/down within its area
    dx, dy = identity["focus"].get("nudge", [0, 0])
    cx = ex * badge.width - dx * win_h / ROW_H
    cy = ey * badge.height - dy * win_h / ROW_H
    box = (round(cx - win_w / 2), round(cy - win_h / 2), round(cx + win_w / 2), round(cy + win_h / 2))
    badge = badge.crop(box).resize((bw, ROW_H), Image.LANCZOS)  # outside the badge = transparent
    a = np.array(badge)
    n = max(1, round(bw * identity.get("feather", 0.12)))
    ramp = np.linspace(0, 1, n, dtype=np.float32)
    alpha = a[..., 3].astype(np.float32)
    alpha[:, :n] *= ramp
    alpha[:, -n:] *= ramp[::-1]
    a[..., 3] = alpha.astype(np.uint8)
    badge = Image.fromarray(a)
    area = cell - badge.width
    wh = ROW_H * identity.get("wordmark_height", 0.82)
    ww = wh * word.width / word.height
    if ww > area * 0.9:
        ww = area * 0.9
        wh = ww * word.height / word.width
    word = word.resize((max(1, round(ww)), max(1, round(wh))), Image.LANCZOS)
    out = Image.new("RGBA", (ROW_W, ROW_H), tuple(primary) + (255,))
    for k in range(repeat):
        x = round(cell * k)
        out.paste(badge, (x, round((ROW_H - badge.height) / 2)), badge)
        out.alpha_composite(word, (round(x + badge.width + (area - word.width) / 2), round((ROW_H - word.height) / 2)))
    return out.convert("RGB")


def render_board(boards, name):
    rows = board_rows(boards, name)
    upright = Image.new("RGB", (ROW_W, ROW_H * len(rows)))
    # stored row k (the texture is kept V-flipped) = config row k, so the
    # stack is drawn bottom-up here
    for k, path in enumerate(rows):
        upright.paste(load_row(path), (0, (len(rows) - 1 - k) * ROW_H))
    return upright, len(rows)


# ---- commands ---------------------------------------------------------------

def find_texconv(arg):
    for path in (arg, games.toolchain("texconv", "texconv.exe"),
                 os.path.join(REPO, "_build", "package_cache", "texconv.exe")):
        if path and os.path.exists(path):
            return os.path.abspath(path)
    raise SystemExit("texconv.exe not found - pass --texconv")


def cmd_rows(args):
    sponsors = load_sponsors()
    if args.clubs or not args.ids:
        # club identity rows: config/boards/<team>/club.png from board.json "identity"
        for name, cfg in load_boards().items():
            identity = cfg.get("identity")
            if identity and not identity.get("manual"):
                club_row(identity).save(club_path(name))
                print(f"{name}: {club_path(name)}")
        if args.clubs:
            return
    ids = args.ids or [k for k, v in sponsors.items() if not v.get("manual")]
    if any("stock" in sponsors[i] for i in ids):
        ce.load_index(pack.BLOBSET_PATH)
    for sid in ids:
        if sid not in sponsors:
            raise SystemExit(f"{sid}: not in sponsors.json")
        if sponsors[sid].get("manual"):
            print(f"{sid}: manual - skipped")
            continue
        make_row(sponsors[sid]).save(os.path.join(SPONSORS_DIR, sid + ".png"))
        print(f"{sid}: {os.path.join(SPONSORS_DIR, sid + '.png')}")


def cmd_sheet(args):
    """Every sponsor row with its name, on one page, for checking."""
    sponsors = load_sponsors()
    os.makedirs(BUILD_DIR, exist_ok=True)
    w, h, label = ROW_W // 2, ROW_H // 2, 18
    sheet = Image.new("RGB", (w, len(sponsors) * (h + label)), (60, 60, 60))
    draw = ImageDraw.Draw(sheet)
    for k, (sid, spec) in enumerate(sponsors.items()):
        y = k * (h + label)
        draw.text((4, y + 3), f"{sid}  ({spec.get('name', '')})", fill=(255, 255, 255))
        sheet.paste(load_row(sponsor_path(sid)).resize((w, h), Image.LANCZOS), (0, y + label))
    out = os.path.join(BUILD_DIR, "sponsors.png")
    sheet.save(out)
    print(out)


def cmd_build(args):
    texconv = find_texconv(args.texconv)
    boards = load_boards()
    names = args.board or list(boards)
    os.makedirs(BUILD_DIR, exist_ok=True)
    rows_path = os.path.join(BUILD_DIR, "rows.json")
    meta = json.load(open(rows_path)) if os.path.exists(rows_path) else {}
    with tempfile.TemporaryDirectory() as tmp:
        for name in names:
            upright, n = render_board(boards, name)
            upright.save(os.path.join(BUILD_DIR, f"{name}.png"))
            src = os.path.join(tmp, f"lcd_revamp_{name}_col.png")
            upright.transpose(Image.FLIP_TOP_BOTTOM).save(src)
            subprocess.run([texconv, "-nologo", "-y", "-f", "BC1_UNORM", "-dx9", "-m", "0", "--ignore-srgb",
                            "-o", BUILD_DIR, src], check=True, stdout=subprocess.DEVNULL)
            meta[name] = n
            print(f"{name}: {n} rows -> {os.path.join(BUILD_DIR, name + '.png')}")
    json.dump({k: v for k, v in meta.items() if k in boards}, open(rows_path, "w"), indent=1)


def cmd_install(args):
    import add_entries
    import club_icons
    boards = load_boards()
    for name in boards:
        dds_path = os.path.join(BUILD_DIR, f"lcd_revamp_{name}_col.dds")
        if not os.path.exists(dds_path):
            raise SystemExit(f"{dds_path} missing - run build first")
        dds = open(dds_path, "rb").read()
        blob, sizes = club_icons.make_blob(texture_path(name), dds)
        add_entries.add_entry(args.blobset, texture_path(name), blob, sizes, f"nrl-led-boards {name}",
                              args.confirm, replace=args.replace)
    if not args.confirm:
        print("dry run - pass --confirm to write (close the game first)")


def lua_string(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def cmd_lua(args):
    boards = load_boards()
    rows = json.load(open(os.path.join(BUILD_DIR, "rows.json"))) if os.path.exists(
        os.path.join(BUILD_DIR, "rows.json")) else {}
    live = []
    for name in boards:
        try:
            entries.index_of(texture_path(name))
        except KeyError:
            print(f"  {name}: texture not installed - left out")
            continue
        if name not in rows:
            print(f"  {name}: no build/rows.json entry - left out (run build)")
            continue
        live.append(name)
    timing = boards["default"].get("timing", {})
    lines = [BEGIN, "LED_BOARD_TIMING = {",
             f"\tpersistTime = {float(timing.get('persistTime', 5))},",
             f"\ttransitionTime = {float(timing.get('transitionTime', 0.5))}", "}", "LED_BOARDS = {"]
    lines += [f"\t{name} = {{ texture = {lua_string(texture_path(name))}, rows = {rows[name]} }}," for name in live]
    lines += ["}", "LED_BOARD_CLUBS = {"]
    for name in live:
        if boards[name]["type"] == "team":
            lines += [f"\t[{lua_string(club.lower())}] = {lua_string(name)}," for club in boards[name].get("clubs", [])]
    lines += ["}", "LED_BOARD_SPONSOR_TYPES = {"]
    for name in live:
        if boards[name]["type"] == "competition":
            lines += [f"\t[{lua_string(t)}] = {lua_string(name)}," for t in boards[name].get("sponsorTypes", [name])]
    lines += ["}", "-- checked in order, before the team/competition boards", "LED_BOARD_EVENTS = {"]
    events = sorted((n for n in live if boards[n]["type"] == "event"), key=lambda n: (boards[n].get("priority", 99), n))
    for name in events:
        cfg = boards[name]
        fields = [f"board = {lua_string(name)}"]
        for key in EVENT_MATCH_KEYS:
            value = cfg["match"].get(key)
            if value is True:
                fields.append(f"{key} = true")
            elif value:
                fields.append(f"{key} = {{ {', '.join(lua_string(v) for v in value)} }}")
        if cfg.get("sponsorTypes"):
            fields.append(f"sponsorTypes = {{ {', '.join(lua_string(v) for v in cfg['sponsorTypes'])} }}")
        lines.append("\t{ " + ", ".join(fields) + " },")
    lines += ["}", END]
    src = open(LUA, encoding="utf-8").read()
    start, stop = src.index(BEGIN), src.index(END) + len(END)
    with open(LUA, "w", encoding="utf-8", newline="\n") as f:
        f.write(src[:start] + "\n".join(lines) + src[stop:])
    print(f"{LUA}: {len(live)} boards ({', '.join(live) or 'none'})")


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)
    r = sub.add_parser("rows")
    r.add_argument("ids", nargs="*")
    r.add_argument("--clubs", action="store_true", help="only the club identity rows")
    sub.add_parser("sheet")
    b = sub.add_parser("build")
    b.add_argument("--texconv")
    b.add_argument("--board", nargs="*")
    i = sub.add_parser("install")
    i.add_argument("--blobset", default=pack.BLOBSET_PATH)
    i.add_argument("--replace", action="store_true")
    i.add_argument("--confirm", action="store_true")
    sub.add_parser("lua")
    args = p.parse_args()
    {"rows": cmd_rows, "sheet": cmd_sheet, "build": cmd_build, "install": cmd_install, "lua": cmd_lua}[args.cmd](args)


if __name__ == "__main__":
    main()
