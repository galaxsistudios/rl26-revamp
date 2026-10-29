#!/usr/bin/env python3
"""
install.py - textures for nrl-special-balls.

Adds three ball colour textures as NEW entries next to the stock ones
(props/balls/textures/<name>.texture, the stock ball's 2048x1024 BC1 with
12 mips). Stock balls are not touched; ballfactory.lua picks these by name.

    ball_nrl_magicround_col   built here from the stock ball_nrl_col: the
                              green/black swoosh blocks repainted as thin club
                              colour lines, and "NRL TELSTRA PREMIERSHIP"
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
import pack  # noqa: E402

TEXDIR = "props/balls/textures"
BUILD_DIR = os.path.join(REPO, "_build", "nrl-special-balls")
BALLS = ("ball_nrl_magicround_col", "ball_nrl_grandfinal_col", "ball_nrl_pacific_test_col")
MIPS = 12  # stock ball_nrl_col: 2048x1024 BC1, 12 mips

# Stock ball_nrl_col levels: leather and printed (STEEDEN) grey.
LEATHER = np.array([192, 191, 192], np.float32)
PRINT = np.array([43, 40, 40], np.float32)
COPY_OFFSET = 1022  # the second copy of the panel art, in upright rows
LINES = 16  # Magic Round swoosh lines across each swoosh

# Club colours for the swoosh mosaic, ordered so neighbours differ.
MOSAIC = [
    (99, 47, 140),    # Storm purple
    (251, 178, 23),   # Broncos gold
    (0, 164, 209),    # Sharks cyan
    (227, 30, 36),    # Dragons red
    (154, 212, 0),    # Raiders lime
    (0, 62, 138),     # Knights blue
    (244, 121, 32),   # Tigers orange
    (235, 77, 156),   # Panthers pink
    (0, 123, 63),     # Rabbitohs green
    (115, 0, 48),     # Broncos maroon
    (255, 209, 0),    # Eels yellow
    (0, 35, 85),      # Cowboys navy
    (0, 155, 119),    # Warriors teal
    (240, 240, 236),  # white
    (20, 20, 20),     # black
]


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
    """Repaint each swoosh as the Magic Round ball's thin multicolour lines:
    the green/black blocks (and the gaps between them) become one band,
    filled with LINES lines running along the swoosh (converging into its
    tail), each broken into segments of different club colours. The band
    keeps the stock blocks' anti-aliased outer edge (coverage against the
    leather)."""
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
    # close the gaps between blocks so each swoosh is one continuous band
    disk = np.hypot(*np.mgrid[-10:11, -10:11]) <= 10
    band = ndimage.binary_fill_holes(ndimage.binary_closing(labels > 0, structure=disk))
    cover[band] = 1
    bands, nbands = ndimage.label(ndimage.binary_dilation(band, iterations=3))
    out = rgb.copy()
    rng = np.random.default_rng(2026)
    palette = np.array(MOSAIC, np.float32)
    for b in range(1, nbands + 1):
        ys, xs = np.nonzero((bands == b) & (cover > 0))
        if len(ys) < 200:
            continue
        # position along the swoosh (its principal axis) breaks each line
        # into short segments of different colours
        pts = np.column_stack([xs, ys]).astype(np.float64)
        centre = pts.mean(0)
        axis = np.linalg.svd(pts - centre, full_matrices=False)[2][0]
        along = (pts - centre) @ axis
        # across = where a pixel sits between the band's two long sides,
        # measured per slice of the swoosh's length (so the lines follow it
        # and converge into the tail)
        perp = (pts - centre) @ np.array([-axis[1], axis[0]])
        bins = ((along - along.min()) // 2).astype(int)
        lo = np.full(bins.max() + 1, np.inf)
        hi = np.full(bins.max() + 1, -np.inf)
        np.minimum.at(lo, bins, perp)
        np.maximum.at(hi, bins, perp)
        lo, hi = ndimage.median_filter(lo, 5, mode="nearest"), ndimage.median_filter(hi, 5, mode="nearest")
        across = np.clip((perp - lo[bins]) / np.maximum(hi[bins] - lo[bins], 1), 0, 1)
        line = np.minimum((across * LINES).astype(int), LINES - 1)
        seg_len = rng.integers(18, 90, LINES)
        seg_off = rng.integers(0, 90, LINES)
        seg = ((along - along.min() + seg_off[line]) // seg_len[line]).astype(int)
        base = rng.permutation(len(MOSAIC))
        pick = base[(line * 7 + seg * 4) % len(MOSAIC)]
        k = cover[ys, xs][:, None]
        out[ys, xs] = LEATHER + k * (palette[pick] - LEATHER)
    return out


def magic_round(stock_img):
    up = np.asarray(stock_img.transpose(Image.FLIP_TOP_BOTTOM)).astype(np.float32)
    out = recolour_swooshes(up)
    for dy in (0, COPY_OFFSET):
        # shield: lift it out by its coverage, then put it back 52 px left
        y0, y1, x0, x1 = 309 + dy, 418 + dy, 472, 552
        patch = out[y0:y1, x0:x1].copy()
        cover = np.clip((LEATHER.mean() - patch.mean(2)) / (LEATHER.mean() - PRINT.mean()), 0, 1)[..., None]
        # erase with clean leather from the same rows left of SIZE 5 (flat
        # grey showed as a box against the leather's grain)
        out[y0:y1, x0:x1] = up[y0:y1, 180:180 + x1 - x0]
        out[416 + dy:446 + dy, 460:566] = up[416 + dy:446 + dy, 180:286]  # NRL TELSTRA / PREMIERSHIP
        sx = x0 - 52
        region = out[y0:y1, sx:sx + (x1 - x0)]
        out[y0:y1, sx:sx + (x1 - x0)] = region * (1 - cover) + PRINT * cover
    img = Image.fromarray(np.clip(out, 0, 255).round().astype(np.uint8))
    # text as coverage masks, so it blends like the printed STEEDEN
    mask = Image.new("L", img.size, 0)
    d = ImageDraw.Draw(mask)
    big, small = _font(40, "Bold Condensed"), _font(17, "SemiBold SemiCondensed")
    for dy in (0, COPY_OFFSET):
        d.text((512, 318 + dy), "MAGIC", font=big, fill=255)
        d.text((512, 356 + dy), "ROUND", font=big, fill=255)
        d.text((514, 398 + dy), "B R I S B A N E", font=small, fill=255)
    a = np.asarray(mask).astype(np.float32)[..., None] / 255
    out = np.asarray(img).astype(np.float32) * (1 - a) + PRINT * a
    return Image.fromarray(np.clip(out, 0, 255).round().astype(np.uint8)).transpose(Image.FLIP_TOP_BOTTOM)


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
        images = {"ball_nrl_magicround_col": magic_round(stock)}
        for name in BALLS[1:]:
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
