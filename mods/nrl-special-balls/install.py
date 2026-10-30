#!/usr/bin/env python3
"""
install.py - textures for nrl-special-balls.

Adds six ball colour textures as NEW entries next to the stock ones
(props/balls/textures/<name>.texture, the stock ball's 2048x1024 BC1 with
12 mips). Stock balls are not touched; ballfactory.lua picks these by name.

    ball_nrl_magicround_col   built here from the stock ball_nrl_col: the
                              green/black swoosh blocks repainted with the
                              Magic Round checker, and "NRL TELSTRA PREMIERSHIP"
                              under the shield replaced by MAGIC ROUND /
                              BRISBANE beside it. Game-derived, so it is
                              rebuilt from the live game (not stored in git).
    ball_nrl_grandfinal_col   textures/*.png, imported once from the
    ball_nrl_pacific_test_col supplied DDS files with `art` (see below).

The texture is stored upside down (V flipped, not mirrored) like every stock
ball; all drawing below happens on the upright image, which holds the panel
artwork twice (rows 0-1023 and again 1022 rows lower).

The supplied Grand Final / Pacific Test DDS were much darker than the stock
balls (leather 150 and 109 against stock 192), which reads as a grey ball in
game, so `art` maps their leather and print levels onto the stock ones.

Usage (repo root, game closed):
    python mods/nrl-special-balls/install.py art --grandfinal X.dds --pacific Y.dds
    python mods/nrl-special-balls/install.py build [--texconv PATH]
    python mods/nrl-special-balls/install.py install [--replace] [--confirm]
"""

import argparse
import os
import subprocess
import sys
import tempfile

import numpy as np
from PIL import Image, ImageDraw, ImageFont

MOD = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(MOD))
sys.path.insert(0, os.path.join(REPO, "tools"))
import classify_entries as ce  # noqa: E402
import entries  # noqa: E402
import extract_textures as et  # noqa: E402
import games  # noqa: E402
import magic_round_pattern as mrp  # noqa: E402
import pack  # noqa: E402

TEXDIR = "props/balls/textures"
BUILD_DIR = os.path.join(REPO, "_build", "nrl-special-balls")
BALLS = ("ball_nrl_magicround_col", "ball_nswcup_hyundai_col", "ball_nrlw_grandfinal_col", "ball_ashes_col",
         "ball_nrl_grandfinal_col", "ball_nrl_pacific_test_col")
GENERATED = 4  # BALLS[:GENERATED] are built from the stock ball, the rest are textures/*.png
MIPS = 12  # stock ball_nrl_col: 2048x1024 BC1, 12 mips

# Stock ball_nrl_col levels: leather and printed (STEEDEN) grey.
LEATHER = np.array([192, 191, 192], np.float32)
PRINT = np.array([43, 40, 40], np.float32)
# NSW Cup: sampled from the reference photo (lit side), Hyundai sponsor blue
NSW_NAVY = (32, 42, 72)
NSW_SKY = (145, 180, 228)
HYUNDAI_BLUE = (30, 42, 96)
# NRLW Grand Final: the stock NRLW ball's teal, and its logo, in the GF ball's gold
NRLW_TEAL = np.array([0, 154, 145], np.float32)
GF_GOLD = np.array([120, 110, 63], np.float32)  # textures/ball_nrl_grandfinal_col.png swooshes/shield
NRLW_LOGO_SVG = os.path.join(REPO, "resources", "balls", "nrlw_ball", "nrlw_logo.svg")
NRLW_SHIELD = (482, 306, 63, 89)  # x, y, w, h of the stock NRLW shield (upright)
# Ashes: colours from the supplied shields (eng.svg red, aus.svg green/gold)
ASHES_DIR = os.path.join(REPO, "resources", "balls", "ashes")
ASHES_RED = (183, 46, 53)
ASHES_PALE_BLUE = (172, 196, 226)
ASHES_GREEN = (0, 109, 51)
ASHES_GOLD = (255, 230, 0)
JOSEFIN = os.path.join(ASHES_DIR, "fonts", "JosefinSans[wght].ttf")  # OFL, closest to the ball's lettering
SHIELD_TOP, SHIELD_HEIGHT = 310, 118
HYUNDAI_LOGO = "hyundai-motor-company-logo-png_seeklogo-69075.png"
COPY_OFFSET = 1022  # the second copy of the panel art, in upright rows
PANEL = 511  # the sponsor panel, in upright rows below the STEEDEN one
END_PIECE = (34, 7)  # Ashes: block broken off a swoosh line's thick end, and its gap
# Magic Round swoosh checker (tools/magic_round_pattern.py), in texels
CHECK_COLUMN = 40
CHECK_PERIOD = 14
CHECK_DIM = 0.75  # the checker's colours darkened so they don't overpower the ball
MR_LOGO = os.path.join(REPO, "resources", "field-markings", "field-centers", "nrl-magic-round.avif")
MR_LOGO_TOP, MR_LOGO_HEIGHT = 312, 116  # under STEEDEN / SIZE 5, centred on it


def stock_dds(name):
    ce.load_index(pack.BLOBSET_PATH)
    raw, *_ = ce.read_blob_full(pack.BLOBSET_PATH, entries.index_of(f"{TEXDIR}/{name}.texture"))
    _path, dds, *_ = et.parse_mini_txpk(raw)
    return dds


def decode(texconv, dds, tmp):
    src = os.path.join(tmp, "src.dds")
    with open(src, "wb") as f:
        f.write(dds)
    subprocess.run([texconv, "-nologo", "-y", "-ft", "png", "-f", "R8G8B8A8_UNORM", "-m", "1",
                    "--ignore-srgb", "-o", tmp, src], check=True, stdout=subprocess.DEVNULL)
    return Image.open(os.path.join(tmp, "src.png")).convert("RGB")


def _font(size, style):
    font = ImageFont.truetype(os.path.join(os.environ.get("WINDIR", r"C:\Windows"), "Fonts", "bahnschrift.ttf"), size)
    font.set_variation_by_name(style)
    return font


def recolour_swooshes(up):
    """Repaint each swoosh with the Magic Round checker: the blocks of each
    stock line (black outer, green inner) join into one band per line, keeping
    the cut between the lines, and are filled with tools/magic_round_pattern.py's
    corner-to-corner colour blocks. The bands keep the stock blocks'
    anti-aliased outer edge (coverage against the leather)."""
    from scipy import ndimage
    rgb = up.astype(np.float32)
    lum = rgb.mean(2)
    green = (rgb[..., 1] - rgb[..., 0] > 60) & (rgb[..., 1] > 150)
    black = (lum < 90) & (np.ptp(rgb, axis=2) < 30)
    # the printed text (43 grey) is kept out by area: STEEDEN, SIZE 5 /
    # Est. 1958, and the shield with NRL TELSTRA PREMIERSHIP
    for dy in (0, COPY_OFFSET):
        black[170 + dy:310 + dy, 250:780] = False
        black[300 + dy:450 + dy, 440:600] = False
    labels, count = ndimage.label(green | black)
    sizes = ndimage.sum(np.ones_like(lum), labels, range(1, count + 1))
    labels[np.isin(labels, np.flatnonzero(sizes < 6) + 1)] = 0
    labels, count = ndimage.label(labels > 0)
    # grow each block over its anti-aliased rim (nearest block wins) and
    # measure that rim's coverage toward the block's own ink
    dist, (iy, ix) = ndimage.distance_transform_edt(labels == 0, return_indices=True)
    grown = np.where(dist <= 3, labels[iy, ix], 0)
    cover = np.zeros(lum.shape, np.float32)
    for i in range(1, count + 1):
        rim = grown == i
        span = rgb[labels == i].mean(0) - LEATHER
        cover[rim] = np.clip(((rgb[rim] - LEATHER) @ span) / (span @ span), 0, 1)
    # close the gaps between blocks along each line (black outer, green
    # inner) but not between the lines, so the stock cut between them and the
    # lines' slanted ends stay. The inner line is redrawn smooth with a small
    # block broken off its thick end, like the real ball's little rectangle.
    disk = np.hypot(*np.mgrid[-10:11, -10:11]) <= 10
    wide = np.hypot(*np.mgrid[-20:21, -20:21]) <= 20
    is_green = np.zeros(count + 1, bool)
    is_green[1:] = ndimage.maximum(green, labels, range(1, count + 1)) > 0
    outer = (labels > 0) & ~is_green[labels]
    band = ndimage.binary_fill_holes(ndimage.binary_closing(outer, structure=wide))
    cover[band] = 1
    inner = ndimage.binary_fill_holes(ndimage.binary_closing((labels > 0) & is_green[labels], structure=wide))
    lines, nlines = ndimage.label(inner)
    for n in range(1, nlines + 1):
        rest, piece = smooth_band(lines == n, split=END_PIECE)
        region = ndimage.binary_dilation(lines == n, iterations=4) & ~band
        cover[region] = np.maximum(rest, piece)[region]
        band |= region
    # the checker in texture space, turned so its stripes run horizontal
    # (flat-topped parallelogram blocks), mirrored on the right-hand swooshes
    size = 1500
    pattern = mrp.render(size, size, round(size / CHECK_COLUMN), CHECK_PERIOD, 0.5, "#000000", 2026, 0.0)
    pattern = pattern.rotate(-np.degrees(np.arctan(mrp.SLOPE)), Image.BICUBIC)
    side = up.shape[1]
    c = (size - side) // 2
    pattern = np.asarray(pattern.crop((c, c, c + side, c + side))).astype(np.float32)
    bands, nbands = ndimage.label(ndimage.binary_dilation(ndimage.binary_closing(band, structure=disk), iterations=3))
    out = rgb.copy()
    out[(bands > 0) & (cover == 0)] = LEATHER  # stock ink left in the end piece's gap
    for b in range(1, nbands + 1):
        ys, xs = np.nonzero((bands == b) & (cover > 0))
        if len(ys) < 200:
            continue
        src = pattern[:, ::-1] if xs.mean() > up.shape[1] / 2 else pattern
        k = cover[ys, xs][:, None]
        out[ys, xs] = LEATHER + k * (src[ys % COPY_OFFSET, xs] * CHECK_DIM - LEATHER)
    return out


def _svg_cover(path, size):
    """Coverage of a one-colour SVG's shapes, cropped to them and fitted to
    size (w, h): rendered at 10x and box-filtered down."""
    import io
    import resvg_py  # pip install resvg-py
    img = Image.open(io.BytesIO(bytes(resvg_py.svg_to_bytes(svg_path=path, zoom=10)))).getchannel("A")
    img = img.crop(img.getbbox()).resize(size, Image.BOX)
    return np.asarray(img).astype(np.float32) / 255


def _gf_lettering(nrlw_up):
    """Coverage of the NRLW GF ball's two text lines, cut from real lettering
    (the font isn't available): NRL TELSTRA, PREMIERSHIP and GRAND FINAL from
    the NRL Grand Final texture, WOMEN'S from the stock NRLW ball (same face,
    9 px caps scaled to the GF ball's 8). Each cut has a 1 px margin row."""
    gf = np.asarray(Image.open(os.path.join(MOD, "textures", "ball_nrl_grandfinal_col.png")).convert("RGB")
                    .transpose(Image.FLIP_TOP_BOTTOM)).astype(np.float32)
    leather = np.median(gf[600:650, 400:600].reshape(-1, 3), 0)
    span = GF_GOLD - leather
    gf_cover = np.clip(((gf - leather) @ span) / (span @ span), 0, 1)
    nrl_telstra = gf_cover[409:419, 435:510]  # caps 410-417
    premiership = gf_cover[409:419, 511:589]
    grand_final = gf_cover[421:439, 439:585]  # caps 422-437
    women = np.clip(np.abs(nrlw_up[399:410, 523:581] - 192).max(2) / 150, 0, 1)  # caps 400-408
    women = np.asarray(Image.fromarray(women).resize((round(women.shape[1] * 8 / 9), 10), Image.LANCZOS)).clip(0, 1)
    # word gaps: the cuts' own side bearings plus a little, matching the GF ball's
    return np.hstack([nrl_telstra, women, np.zeros((10, 2), np.float32), premiership]), grand_final


def nrlw_grand_final(stock_img):
    """The stock ball_nrlw_col with every teal stripe and the NRLW logo (shield,
    Telstra mark) in the NRL Grand Final ball's gold, its text redrawn as NRL
    TELSTRA WOMEN'S PREMIERSHIP over GRAND FINAL like the real GF ball. Each pixel keeps its coverage, so the anti-aliasing and the
    leather under it are unchanged. The two panel copies differ slightly on
    this texture, so the whole image is recoloured rather than one copy."""
    up = np.asarray(stock_img.transpose(Image.FLIP_TOP_BOTTOM)).astype(np.float32)
    out = up.copy()
    shield = _svg_cover(NRLW_LOGO_SVG, NRLW_SHIELD[2:])
    # teal share of each pixel from G - R: 0 for leather and black print, 154
    # for the teal ink, so mixes (edges, the lighter teal shading) unmix exactly
    share = np.clip((up[..., 1] - up[..., 0]) / (NRLW_TEAL[1] - NRLW_TEAL[0]), 0, 1)
    out += share[..., None] * (GF_GOLD - NRLW_TEAL)
    # logo: every mark in its box, by distance from the box's own leather
    for dy in (0, COPY_OFFSET):
        y0, y1, x0, x1 = 300 + dy, 440 + dy, 425, 600
        box = up[y0:y1, x0:x1]
        leather = np.median(box.reshape(-1, 3), 0)
        # (coloured marks - the orange/blue Telstra T - count as solid by their chroma)
        k = np.clip(np.maximum(np.abs(box - leather).max(2) / 110, np.ptp(box, axis=2) / 40), 0, 1)[..., None]
        out[y0:y1, x0:x1] = box + k * (GF_GOLD - box)
        # NRL TELSTRA WOMEN'S / PREMIERSHIP -> NRL TELSTRA WOMEN'S PREMIERSHIP /
        # GRAND FINAL, laid out like the NRL GF ball with its own lettering
        out[395 + dy:434 + dy, x0:x1] = leather
        # the shield + Telstra T from the clean vector logo, over the stock one
        out[300 + dy:397 + dy, 470:560] = leather
        _paste_cover(out, shield, GF_GOLD, NRLW_SHIELD[0], NRLW_SHIELD[1] + dy)
        small, grand = _gf_lettering(up[dy:dy + COPY_OFFSET])
        for cover, top in ((small, 400), (grand, 412)):
            _paste_cover(out, cover, GF_GOLD, 513 - cover.shape[1] // 2, top - 1 + dy)
    return Image.fromarray(np.clip(out, 0, 255).round().astype(np.uint8)).transpose(Image.FLIP_TOP_BOTTOM)


def magic_round(stock_img):
    """The stock ball with the Magic Round checker in its swooshes, and the
    NRL shield + NRL TELSTRA PREMIERSHIP replaced by the field markings'
    Magic Round logo (printed like STEEDEN, by its coverage)."""
    up = np.asarray(stock_img.transpose(Image.FLIP_TOP_BOTTOM)).astype(np.float32)
    out = recolour_swooshes(up)
    logo = Image.open(MR_LOGO).convert("RGBA")
    ink = np.asarray(logo).astype(np.float32) / 255
    cover = Image.fromarray(ink[..., 3] * (1 - ink[..., :3].mean(2)))
    w = round(logo.width * MR_LOGO_HEIGHT / logo.height)
    cover = np.asarray(cover.resize((w, MR_LOGO_HEIGHT), Image.BOX)).clip(0, 1)
    for dy in (0, COPY_OFFSET):
        out[309 + dy:446 + dy, 440:600] = 192  # the stock shield + its text (flat leather)
        _paste_cover(out, cover, PRINT, 512 - w // 2, MR_LOGO_TOP + dy)
    return Image.fromarray(np.clip(out, 0, 255).round().astype(np.uint8)).transpose(Image.FLIP_TOP_BOTTOM)


def _paste_cover(out, cover, colour, x, y):
    """Blend `colour` into out (float upright image) by a coverage array."""
    h, w = cover.shape
    region = out[y:y + h, x:x + w]
    k = cover[..., None]
    out[y:y + h, x:x + w] = region * (1 - k) + np.array(colour, np.float32) * k


def _text_cover(text, font, spacing=0, shear=0.0):
    """Coverage mask of `text` (letter spacing in px, italic shear)."""
    widths = [font.getlength(c) + spacing for c in text]
    w, h = int(sum(widths)) + 40, font.size * 2
    mask = Image.new("L", (w, h), 0)
    d = ImageDraw.Draw(mask)
    x = 10
    for c, cw in zip(text, widths):
        d.text((x, font.size // 4), c, font=font, fill=255)
        x += cw
    if shear:
        mask = mask.transform(mask.size, Image.AFFINE, (1, shear, -shear * h / 2, 0, 1, 0), Image.BICUBIC)
    return np.asarray(mask.crop(mask.getbbox())).astype(np.float32) / 255


def smooth_band(band, ss=4, degree=4, split=None):
    """Coverage of a clean version of one swoosh line (a boolean mask of the
    stock blocks, gaps closed): its two long edges become polynomials along
    the line's principal axis, the thick end a straight cut through its two
    corners, the thin end a point. Rasterised at ss x ss supersampling.
    split=(piece, gap) breaks a block `piece` px long off the thick end,
    `gap` px from the rest (both cuts parallel to the end) and returns
    (rest, piece) coverages."""
    ys, xs = np.nonzero(band)
    pts = np.column_stack([xs, ys]).astype(np.float64)
    centre = pts.mean(0)
    axis = np.linalg.svd(pts - centre, full_matrices=False)[2][0]
    normal = np.array([-axis[1], axis[0]])
    along, perp = (pts - centre) @ axis, (pts - centre) @ normal
    # point the axis from the thick end to the tail
    a0, a1 = along.min(), along.max()
    if np.ptp(perp[along < a0 + 20]) < np.ptp(perp[along > a1 - 20]):
        axis, normal, along, perp = -axis, -normal, -along, -perp
        a0, a1 = along.min(), along.max()
    # thick end cut: the extreme pixels at each long edge's end
    across = (perp - perp.min()) / np.ptp(perp)
    lo_edge = perp < np.percentile(perp[along < a0 + 30], 15)
    hi_edge = perp > np.percentile(perp[along < a0 + 30], 85)
    near_end = along < a0 + 60
    c_lo = np.array([along[lo_edge & near_end].min(), perp[lo_edge & near_end].mean()])
    c_hi = np.array([along[hi_edge & near_end].min(), perp[hi_edge & near_end].mean()])
    # edge curves, fitted on 2px slices past the cut
    bins = ((along - a0) // 2).astype(int)
    lo = np.full(bins.max() + 1, np.inf)
    hi = np.full(bins.max() + 1, -np.inf)
    np.minimum.at(lo, bins, perp)
    np.maximum.at(hi, bins, perp)
    centres = a0 + 2 * np.arange(len(lo)) + 1
    ok = np.isfinite(lo) & (centres > max(c_lo[0], c_hi[0]) + 3)
    lo_fit = np.polynomial.Polynomial.fit(centres[ok], lo[ok], degree)
    hi_fit = np.polynomial.Polynomial.fit(centres[ok], hi[ok], degree)
    # rasterise over the band's bounding box (plus margin)
    y0, y1 = max(ys.min() - 4, 0), min(ys.max() + 5, band.shape[0])
    x0, x1 = max(xs.min() - 4, 0), min(xs.max() + 5, band.shape[1])
    gy, gx = np.mgrid[y0:y1:1 / ss, x0:x1:1 / ss] + (0.5 / ss - 0.5)
    rel = np.stack([gx - centre[0], gy - centre[1]], -1)
    a, p = rel @ axis, rel @ normal
    cut = c_hi - c_lo  # inside = the tail side of the cut line

    def side(a, p):
        return (a - c_lo[0]) * cut[1] - (p - c_lo[1]) * cut[0]

    tail = side(a1, (lo_fit(a1) + hi_fit(a1)) / 2)
    dist = side(a, p) * np.sign(tail) / np.hypot(*cut)  # px from the end cut, toward the tail
    inside = (p >= lo_fit(a)) & (p <= hi_fit(a)) & (a <= a1) & (dist >= 0)

    def cover_of(mask):
        cover = np.zeros(band.shape, np.float32)
        cover[y0:y1, x0:x1] = mask.reshape(y1 - y0, ss, x1 - x0, ss).mean((1, 3))
        return cover

    if split is None:
        return cover_of(inside)
    piece, gap = split
    return cover_of(inside & (dist >= piece + gap)), cover_of(inside & (dist < piece))


def _redraw_swooshes(up, out, colour_of, end_piece=None, offsets=(0,)):
    """Erase the stock NRL ball's swoosh blocks and redraw each line as one
    clean band (smooth_band). colour_of(kind, left) gives a band's colour:
    kind "black" is each swoosh's outer line, "green" its inner one; left is
    True for the swoosh left of STEEDEN. end_piece(kind, left), if given,
    returns a colour to break the line's thick end off in (or None), on the
    STEEDEN panel only (offset 0). The
    bands are drawn at each row offset (the sponsor panel is PANEL rows
    below the STEEDEN one)."""
    from scipy import ndimage
    lum = up.mean(2)
    green = (up[..., 1] - up[..., 0] > 30) & (up[..., 1] - up[..., 2] > 30)
    black = (lum < 150) & (np.ptp(up, axis=2) < 30)
    black[170:320, 250:780] = False  # STEEDEN and its small print
    black[300:450, 440:600] = False  # NRL shield
    disk = np.hypot(*np.mgrid[-7:8, -7:8]) <= 7
    out[ndimage.binary_dilation(black | green, iterations=3)] = 192
    for kind, mask in (("black", black), ("green", green)):
        labels, count = ndimage.label(ndimage.binary_closing(mask, structure=disk))
        for i in range(1, count + 1):
            band = labels == i
            if band.sum() <= 200:
                continue
            left = np.nonzero(band)[1].mean() < up.shape[1] / 2
            whole = ((smooth_band(band), colour_of(kind, left)),)
            piece_colour = end_piece and end_piece(kind, left)
            if piece_colour:
                rest, piece = smooth_band(band, split=END_PIECE)
                broken = ((rest, colour_of(kind, left)), (piece, piece_colour))
            for dy in offsets:
                for cover, colour in broken if piece_colour and dy == 0 else whole:
                    _paste_cover(out, cover[:cover.shape[0] - dy], colour, 0, dy)


def _svg_rgba(path, height):
    """A full-colour SVG cropped to its shapes and scaled to `height` px
    (rendered at 10x, box-filtered down), as float RGBA."""
    import io
    import resvg_py  # pip install resvg-py
    img = Image.open(io.BytesIO(bytes(resvg_py.svg_to_bytes(svg_path=path, zoom=10)))).convert("RGBA")
    img = img.crop(img.getbbox())
    img = img.resize((round(img.width * height / img.height), height), Image.BOX)
    return np.asarray(img).astype(np.float32)


def _paste_rgba(out, rgba, x, y):
    h, w = rgba.shape[:2]
    k = rgba[..., 3:] / 255
    out[y:y + h, x:x + w] = out[y:y + h, x:x + w] * (1 - k) + rgba[..., :3] * k


def _josefin(size, weight):
    font = ImageFont.truetype(JOSEFIN, size)
    font.set_variation_by_axes([weight])
    return font


def ashes(stock_img):
    """The Ashes (Australia v England) Steeden from the stock ball_nrl_col's
    layout: STEEDEN / SYMMETRY / SIZE 5 / Est. 1958 kept, the left swoosh
    England red over pale blue and the right one Kangaroos green over gold
    on both panels (beside STEEDEN the inner line's end is broken off in the
    outer colour),
    the NRL shield replaced by the England and Kangaroos shields side by
    side, and on the sponsor panel ABK (emblem) BEER / RUGBY LEAGUE / ASHES
    in Josefin Sans (no game texture has this lettering)."""
    up = np.asarray(stock_img.transpose(Image.FLIP_TOP_BOTTOM)).astype(np.float32)[:COPY_OFFSET]
    out = up.copy()
    # erase the NRL shield + NRL TELSTRA PREMIERSHIP, and Westpac
    for y0, y1, x0, x1 in ((306, 450, 455, 570), (688, 874, 296, 728)):
        out[y0:y1, x0:x1] = 192
    # swooshes on both panels; beside STEEDEN the inner (pale blue / gold)
    # line ends in a broken-off block of the outer line's colour
    _redraw_swooshes(up, out, lambda kind, left: (ASHES_RED if kind == "black" else ASHES_PALE_BLUE) if left
                     else (ASHES_GREEN if kind == "black" else ASHES_GOLD),
                     end_piece=lambda kind, left: None if kind == "black" else ASHES_RED if left else ASHES_GREEN,
                     offsets=(0, PANEL))
    # England and Kangaroos shields under STEEDEN
    eng, aus = _svg_rgba(os.path.join(ASHES_DIR, "eng.svg"), 92), _svg_rgba(os.path.join(ASHES_DIR, "aus.svg"), 96)
    gap = 22
    x = 512 - (eng.shape[1] + gap + aus.shape[1]) // 2
    _paste_rgba(out, eng, x, 318)
    _paste_rgba(out, aus, x + eng.shape[1] + gap, 316)
    # sponsor panel: ABK (emblem) BEER, RUGBY LEAGUE, ASHES
    bold = _josefin(56, 700)
    abk, beer = _text_cover("ABK", bold, spacing=2), _text_cover("BEER", bold, spacing=2)
    cap = abk.shape[0]
    emblem = Image.open(os.path.join(ASHES_DIR, "abk-beer.png")).convert("L")
    emblem = emblem.resize((round(emblem.width * cap * 1.35 / emblem.height), round(cap * 1.35)), Image.LANCZOS)
    emblem = 1 - np.asarray(emblem).astype(np.float32) / 255
    gap = 8
    width = abk.shape[1] + gap + emblem.shape[1] + gap + beer.shape[1]
    x, top = 512 - width // 2, 662
    mid = top + cap // 2
    _paste_cover(out, abk, PRINT, x, top)
    _paste_cover(out, emblem, PRINT, x + abk.shape[1] + gap, mid - emblem.shape[0] // 2)
    _paste_cover(out, beer, PRINT, x + abk.shape[1] + gap + emblem.shape[1] + gap, top)
    # sized to sit between the sponsor panel's swooshes
    league = _text_cover("RUGBY LEAGUE", _josefin(22, 500), spacing=8)
    _paste_cover(out, league, PRINT, 512 - league.shape[1] // 2, top + cap + 12)
    ashes_word = _text_cover("ASHES", _josefin(118, 100), spacing=20)
    _paste_cover(out, ashes_word, PRINT, 512 - ashes_word.shape[1] // 2, top + cap + 12 + league.shape[0] + 14)
    full = np.full((2048, up.shape[1], 3), 192, np.float32)
    full[:COPY_OFFSET] = out
    full[COPY_OFFSET:2 * COPY_OFFSET] = out
    return Image.fromarray(np.clip(full, 0, 255).round().astype(np.uint8)).transpose(Image.FLIP_TOP_BOTTOM)


def nsw_cup(stock_img):
    """The NSW Cup Steeden from the stock ball_nrl_col's layout (the stock
    ball_nswcup_col is a blank placeholder no ball maps to): STEEDEN / Est.
    1958 kept, the swooshes recoloured NSW navy and sky blue as solid bands,
    the NRL shield / SYMMETRY / SIZE 5 replaced by ELITE MATCH, the NSW Cup
    shield (the field markings' centre logo) between AUTHENTIC and MATCH
    BALL, and Hyundai on the sponsor panel in place of Westpac."""
    up = np.asarray(stock_img.transpose(Image.FLIP_TOP_BOTTOM)).astype(np.float32)[:COPY_OFFSET]
    out = up.copy()
    blank = np.float32(192)  # the stock ball's flat leather (LEATHER is a hair off and shows as a box)
    _redraw_swooshes(up, out, lambda kind, left: NSW_NAVY if kind == "black" else NSW_SKY)
    # erase SYMMETRY, SIZE 5, the NRL shield + NRL TELSTRA PREMIERSHIP, Westpac
    for y0, y1, x0, x1 in ((172, 196, 598, 751), (294, 312, 256, 310), (306, 450, 455, 570), (688, 874, 296, 728)):
        out[y0:y1, x0:x1] = blank
    bold = _font(19, "Bold")
    _paste_cover(out, _text_cover("ELITE MATCH", bold, spacing=2, shear=0.25), PRINT, 395, 172)
    _paste_cover(out, _text_cover("MOD", _font(12, "Bold")), PRINT, 262, 298)
    # AUTHENTIC / MATCH BALL either side of the shield, centred on its middle
    authentic, match_ball = _text_cover("AUTHENTIC", bold, spacing=1), _text_cover("MATCH BALL", bold, spacing=1)
    mid = SHIELD_TOP + SHIELD_HEIGHT // 2
    _paste_cover(out, authentic, PRINT, 455 - authentic.shape[1], mid - authentic.shape[0] // 2)
    _paste_cover(out, match_ball, PRINT, 569, mid - match_ball.shape[0] // 2)
    # NSW Cup shield in its own colours (alpha composite)
    shield = Image.open(os.path.join(REPO, "resources", "field-markings", "field-centers", "nsw-cup.webp")).convert("RGBA")
    shield = shield.crop(shield.getbbox())
    shield = shield.resize((round(shield.width * SHIELD_HEIGHT / shield.height), SHIELD_HEIGHT), Image.LANCZOS)
    s = np.asarray(shield).astype(np.float32)
    sx, sy = 512 - shield.width // 2, SHIELD_TOP
    k = s[..., 3:] / 255
    out[sy:sy + shield.height, sx:sx + shield.width] = out[sy:sy + shield.height, sx:sx + shield.width] * (1 - k) + s[..., :3] * k
    # Hyundai (emblem over wordmark), its alpha as coverage
    logo = Image.open(os.path.join(REPO, "resources", "balls", "nsw_cup", HYUNDAI_LOGO)).convert("RGBA")
    logo = logo.crop(logo.getbbox())
    scale = min(400 / logo.width, 200 / logo.height)
    logo = logo.resize((round(logo.width * scale), round(logo.height * scale)), Image.LANCZOS)
    _paste_cover(out, np.asarray(logo)[..., 3].astype(np.float32) / 255, HYUNDAI_BLUE,
                 512 - logo.width // 2, 781 - logo.height // 2)
    full = np.full((2048, up.shape[1], 3), blank, np.float32)
    full[:COPY_OFFSET] = out
    full[COPY_OFFSET:2 * COPY_OFFSET] = out
    return Image.fromarray(np.clip(full, 0, 255).round().astype(np.uint8)).transpose(Image.FLIP_TOP_BOTTOM)


def levels_to_stock(img):
    """Map a supplied texture's leather (most common grey) and darkest print
    (1st percentile) onto the stock ball's, per channel-neutral gain."""
    a = np.asarray(img.convert("RGB")).astype(np.float32)
    lum = a.mean(2)
    vals, counts = np.unique(lum.round(), return_counts=True)
    leather = vals[counts.argmax()]
    dark = np.percentile(lum, 1)
    gain = (LEATHER.mean() - PRINT.mean()) / (leather - dark)
    out = PRINT.mean() + (a - dark) * gain
    print(f"  leather {leather:.0f} print {dark:.0f} -> gain {gain:.2f}")
    return Image.fromarray(np.clip(out, 0, 255).round().astype(np.uint8))


def cmd_art(args):
    os.makedirs(os.path.join(MOD, "textures"), exist_ok=True)
    for name, src in (("ball_nrl_grandfinal_col", args.grandfinal), ("ball_nrl_pacific_test_col", args.pacific)):
        if not src:
            continue
        print(name)
        img = Image.open(src)
        if img.size != (1024, 2048):
            raise SystemExit(f"{src}: {img.size}, expected 1024x2048 like the stock balls")
        levels_to_stock(img).save(os.path.join(MOD, "textures", name + ".png"))


def cmd_build(args):
    texconv = os.path.abspath(args.texconv or games.toolchain("texconv", "texconv.exe"))
    if not os.path.exists(texconv):
        raise SystemExit("texconv.exe not found - pass --texconv")
    os.makedirs(BUILD_DIR, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        stock = decode(texconv, stock_dds("ball_nrl_col"), tmp)
        images = {"ball_nrl_magicround_col": magic_round(stock), "ball_nswcup_hyundai_col": nsw_cup(stock),
                  "ball_ashes_col": ashes(stock),
                  "ball_nrlw_grandfinal_col": nrlw_grand_final(decode(texconv, stock_dds("ball_nrlw_col"), tmp))}
        for name in BALLS[GENERATED:]:
            images[name] = Image.open(os.path.join(MOD, "textures", name + ".png")).convert("RGB")
        for name, img in images.items():
            png = os.path.join(tmp, name + ".png")
            img.save(png)
            img.save(os.path.join(BUILD_DIR, name + "_preview.png"))
            subprocess.run([texconv, "-nologo", "-y", "-f", "BC1_UNORM", "-dx9", "-m", str(MIPS), "--ignore-srgb",
                            "-o", BUILD_DIR, png], check=True, stdout=subprocess.DEVNULL)
            print(f"{name}: {os.path.join(BUILD_DIR, name + '.dds')}")


def cmd_install(args):
    import add_entries
    import club_icons
    for name in BALLS:
        dds_path = os.path.join(BUILD_DIR, name + ".dds")
        if not os.path.exists(dds_path):
            raise SystemExit(f"{dds_path} missing - run build first")
        with open(dds_path, "rb") as f:
            dds = f.read()
        path = f"{TEXDIR}/{name}.texture".lower()
        blob, sizes = club_icons.make_blob(path, dds)
        add_entries.add_entry(args.blobset, path, blob, sizes, f"nrl-special-balls {name}",
                              args.confirm, replace=args.replace)
    if not args.confirm:
        print("dry run - pass --confirm to write (close the game first)")


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)
    a = sub.add_parser("art")
    a.add_argument("--grandfinal")
    a.add_argument("--pacific")
    b = sub.add_parser("build")
    b.add_argument("--texconv")
    i = sub.add_parser("install")
    i.add_argument("--blobset", default=pack.BLOBSET_PATH)
    i.add_argument("--replace", action="store_true")
    i.add_argument("--confirm", action="store_true")
    args = p.parse_args()
    {"art": cmd_art, "build": cmd_build, "install": cmd_install}[args.cmd](args)


if __name__ == "__main__":
    main()
