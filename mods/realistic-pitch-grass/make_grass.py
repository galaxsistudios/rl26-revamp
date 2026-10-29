#!/usr/bin/env python3
"""
make_grass.py - build the four pitch grass colour textures from the stock
`grass_lush_col` blade detail.

Stock state (fields/textures/grass/, all 2048x2048, 12 mips):
    grass_lush_col      BC7  the only one with real blade detail; every stock
                             ground uses it
    grass_standard_col  BC7  byte-identical to grass_dry_col (the wear layer)
    grass_verylush_col  BC1  flat, almost detail-free placeholder
    grass_verydry_col   BC1  flat grey-brown placeholder

Every variant here keeps lush's blades (luminance detail and per-pixel
chroma) and re-tints them toward a target turf colour, so all four tile
exactly like stock. Pointwise ops plus FFT-periodic noise keep them seamless.
grass_dry_col (the worn-grass blend every ground shares) is left alone.

Writes mods/realistic-pitch-grass/textures/<entry hash>_<label>.dds (installed
by tools/texture_mods.py) and resources/pitch-grass/preview.png.

Usage:
    python mods/realistic-pitch-grass/make_grass.py [--source stock_lush.dds] [--texconv PATH]
"""

import argparse
import json
import os
import subprocess
import sys
import tempfile

import numpy as np
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO_ROOT, "tools"))
import classify_entries as ce  # noqa: E402
import entries  # noqa: E402
import extract_textures as et  # noqa: E402
import games  # noqa: E402
import pack  # noqa: E402

LUSH_PATH = "fields/textures/grass/grass_lush_col.texture"
OUT_DIR = os.path.join(HERE, "textures")
PREVIEW = os.path.join(REPO_ROOT, "resources", "pitch-grass", "preview.png")
SIZE = 2048
MIPS = 12

# target   - mean sRGB colour of the texture. Stock lush is (69, 84, 51), hue
#            ~87 deg, which the grass shader lifts into the lime green seen
#            in-game. Luminance stays close to stock (~78) so exposure doesn't
#            move; only hue and saturation do.
# contrast - exponent on the blade luminance detail (1 = stock).
# chroma   - how much of lush's per-pixel colour variation is kept.
# tips     - yellowing of the brightest blades (sun-lit tips).
# macro    - strength of soft tileable tonal patches (+/- fraction).
# patches  - (amount, colour): dry/brown patches blended in by a noise mask.
# format   - match the stock entry's DXGI format.
VARIANTS = [
    dict(name="grass_lush_col", label="broadcast",
         target=(60, 87, 52), contrast=1.12, chroma=0.8, tips=0.10, macro=0.04,
         patches=None, format="BC7_UNORM"),
    dict(name="grass_verylush_col", label="ryegrass",
         target=(50, 80, 47), contrast=1.15, chroma=0.7, tips=0.06, macro=0.035,
         patches=None, format="BC1_UNORM"),
    dict(name="grass_standard_col", label="couch",
         target=(70, 88, 50), contrast=1.10, chroma=0.9, tips=0.14, macro=0.05,
         patches=(0.18, (92, 90, 56)), format="BC7_UNORM"),
    dict(name="grass_verydry_col", label="suburban",
         target=(76, 85, 54), contrast=1.10, chroma=0.9, tips=0.16, macro=0.07,
         patches=(0.45, (104, 92, 60)), format="BC1_UNORM"),
]


def stock_lush_dds():
    """Stock grass_lush_col DDS bytes: from the pack.py backup once this mod's
    lush is installed (a reinstall), else from the live game."""
    index = entries.index_of(LUSH_PATH)
    meta_path = pack.backup_meta_path(index)
    if os.path.exists(meta_path):
        with open(meta_path) as f:
            meta = json.load(f)
        with open(meta["blob_backup"], "rb") as f:
            blob = f.read()
        # stock Mini_TXPKs: raw main header + outer-chunked vram (see read_blob_full)
        main_u = meta["main_uncompressed_size"]
        if meta["main_compressed_size"] != main_u or meta["vram_compressed_size"] == meta["vram_uncompressed_size"]:
            raise SystemExit(f"{meta['blob_backup']}: unexpected layout - pass --source <stock grass_lush_col .dds>")
        raw = blob[:main_u] + ce.decode_outer_zstd_frames(blob[main_u:])
    else:
        ce.load_index(pack.BLOBSET_PATH)
        raw, *_ = ce.read_blob_full(pack.BLOBSET_PATH, index)
    _path, dds, *_ = et.parse_mini_txpk(raw)
    return dds


def decode(texconv, dds_bytes, tmp):
    src = os.path.join(tmp, "src.dds")
    open(src, "wb").write(dds_bytes)
    subprocess.run([texconv, "-nologo", "-y", "-ft", "png", "-f", "R8G8B8A8_UNORM", "-m", "1",
                    "--ignore-srgb", "-o", tmp, src], check=True, stdout=subprocess.DEVNULL)
    return np.asarray(Image.open(os.path.join(tmp, "src.png")).convert("RGB")).astype(np.float32)


def tile_noise(seed, cutoff, n=SIZE):
    """Seamlessly tiling noise, std 1: white noise low-passed in the
    frequency domain (so it is periodic over the n x n tile). cutoff is in
    cycles per tile."""
    rng = np.random.default_rng(seed)
    f = np.fft.fft2(rng.standard_normal((n, n)))
    k = np.fft.fftfreq(n) * n
    r2 = k[:, None] ** 2 + k[None, :] ** 2
    v = np.real(np.fft.ifft2(f * np.exp(-r2 / (2 * cutoff ** 2))))
    return (v - v.mean()) / v.std()


def make_variant(base, v, seed):
    lum = base @ np.array([0.2126, 0.7152, 0.0722], np.float32)
    d = lum / lum.mean()
    chroma = base - lum[..., None]
    chroma -= chroma.reshape(-1, 3).mean(0)  # keep lush's variation, not its tint
    target = np.array(v["target"], np.float32)

    out = target * d[..., None] ** v["contrast"] + chroma * v["chroma"]
    tip = np.clip(d - 1.1, 0, None)[..., None]
    out += v["tips"] * tip * target.mean() * np.array([1.0, 0.6, -0.8], np.float32)

    macro = 0.6 * tile_noise(seed, 3) + 0.4 * tile_noise(seed + 1, 9)
    out *= 1 + v["macro"] * macro[..., None]

    if v["patches"]:
        amount, colour = v["patches"]
        mask = np.clip((tile_noise(seed + 2, 5) - 0.4) / 1.2, 0, 1) ** 1.5 * amount
        out = out * (1 - mask[..., None]) + np.array(colour, np.float32) * d[..., None] * mask[..., None]

    return np.clip(out, 0, 255).round().astype(np.uint8)


def encode(texconv, img, v, tmp):
    stem = f"{entries.hash_of(f'fields/textures/grass/{v['name']}.texture'):016x}_{v['label']}"
    png = os.path.join(tmp, stem + ".png")
    Image.fromarray(img).save(png)
    subprocess.run([texconv, "-nologo", "-y", "-f", v["format"], "-m", str(MIPS), "--ignore-srgb",
                    "-o", OUT_DIR, png], check=True, stdout=subprocess.DEVNULL)
    return os.path.join(OUT_DIR, stem + ".dds")


def preview(base, made):
    tiles = [("stock lush", base.astype(np.uint8))] + [(f"{v['name']} ({v['label']})", img) for v, img in made]
    sheet = Image.new("RGB", (384 * len(tiles), 404), (0, 0, 0))
    for i, (title, img) in enumerate(tiles):
        sheet.paste(Image.fromarray(img[:768, :768]).resize((384, 384)), (384 * i, 20))
        ImageDraw.Draw(sheet).text((384 * i + 6, 4), title, fill=(255, 255, 255))
    os.makedirs(os.path.dirname(PREVIEW), exist_ok=True)
    sheet.save(PREVIEW)


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--source", help="stock grass_lush_col .dds (default: read from the game)")
    p.add_argument("--texconv", help="texconv.exe (default: the bundled toolchain one)")
    args = p.parse_args()
    texconv = os.path.abspath(args.texconv or games.toolchain("texconv", "texconv.exe"))
    if not os.path.exists(texconv):
        raise SystemExit("texconv.exe not found - pass --texconv")

    dds = open(args.source, "rb").read() if args.source else stock_lush_dds()
    os.makedirs(OUT_DIR, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        base = decode(texconv, dds, tmp)
        assert base.shape == (SIZE, SIZE, 3), base.shape
        made = []
        for i, v in enumerate(VARIANTS):
            img = make_variant(base, v, seed=100 * (i + 1))
            print(f"{v['name']:<20} mean {img.reshape(-1, 3).mean(0).round(1)} -> {encode(texconv, img, v, tmp)}")
            made.append((v, img))
    preview(base, made)
    print(f"preview: {PREVIEW}")


if __name__ == "__main__":
    main()
