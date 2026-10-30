#!/usr/bin/env python3
"""
make_floor.py - turn the menu background floor into a strip of grass.

Every front-end screen that stands a player on a floor (home screen, player
edit, team select, ...) draws the same flat image under the 3D model:
noesis/workspace/images/background/rugbyleague_mainmenu/floor_image (3840x720
BC7, no mips), the bottom third of MenuBackgroundView's grid. Stock it's dark
concrete under a soft spotlight.

This rebuilds it from the game's own pitch grass (stock grass_lush_col, the
blade detail every ground uses), laid on a ground plane in perspective:

- A pinhole camera CAM_HEIGHT m above the grass, horizon HORIZON_PX above the
  image's top edge. Each output row samples the 2048 tile (TILE_M metres)
  from a box-filtered mip pyramid picked by the lateral footprint, with
  V_SAMPLES vertical sub-samples for the foreshortening (cheap anisotropic
  filtering), so blades are crisp at the front and soften toward the back.
- Mowing stripes STRIPE_M wide running away from the camera (they converge on
  the vanishing point), +/- STRIPE_AMOUNT.
- The stock floor's lighting is kept: its luminance, blurred to drop the
  concrete grain, scales the grass, so the spotlight pool and the fade into
  the dark backdrop at the top edge look the same as stock.

Writes mods/menu-grass-floor/textures/<entry hash>_floor_image.dds (installed
by tools/texture_mods.py) and resources/menu-grass-floor/preview.png.

Usage:
    python mods/menu-grass-floor/make_floor.py [--texconv PATH]
"""

import argparse
import importlib.util
import json
import os
import subprocess
import sys
import tempfile

import numpy as np
from PIL import Image, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO_ROOT, "tools"))
import classify_entries as ce  # noqa: E402
import entries  # noqa: E402
import extract_textures as et  # noqa: E402
import games  # noqa: E402
import pack  # noqa: E402

FLOOR_PATH = "noesis/workspace/images/background/rugbyleague_mainmenu/floor_image.texture"
LUSH_PATH = "fields/textures/grass/grass_lush_col.texture"
OUT_DIR = os.path.join(HERE, "textures")
PREVIEW = os.path.join(REPO_ROOT, "resources", "menu-grass-floor", "preview.png")

W, H = 3840, 720
TILE = 2048
TILE_M = 0.85           # metres covered by one grass tile
CAM_HEIGHT = 2.6        # metres
HORIZON_PX = 320        # horizon distance above the image's top row
FOCAL_PX = 1500
V_SAMPLES = 6
STRIPE_M = 1.6
STRIPE_AMOUNT = 0.09
TARGET = (60, 102, 46)  # mean sRGB of the grass before lighting
CONTRAST = 1.15         # exponent on the blades' luminance detail
CHROMA = 0.8            # how much of lush's per-pixel colour variation is kept
LIGHT_GAIN = 1.15       # lighting = stock floor luminance / its 99th percentile * gain
LIGHT_GAMMA = 0.85
FADE = 0.6              # top fraction of the image that fades to transparent
FADE_POWER = 1.6        # > 1 keeps the far grass fainter for longer
FORMAT = "BC7_UNORM"


def stock_dds(path):
    """A Mini_TXPK entry's stock DDS bytes: from the pack.py backup once a mod
    has replaced it (a reinstall), else from the live game."""
    index = entries.index_of(path)
    meta_path = pack.backup_meta_path(index)
    if os.path.exists(meta_path):
        with open(meta_path) as f:
            meta = json.load(f)
        with open(meta["blob_backup"], "rb") as f:
            blob = f.read()
        # same branching as ce.read_blob_full: if either component is raw the
        # main is a verbatim prefix, otherwise the outer frames start at byte 0
        main_raw = meta["main_compressed_size"] == meta["main_uncompressed_size"]
        vram_raw = meta["vram_compressed_size"] == meta["vram_uncompressed_size"]
        main_u = meta["main_uncompressed_size"]
        if main_raw and vram_raw:
            raw = blob
        elif main_raw or vram_raw:
            raw = blob[:main_u] + ce.decode_outer_zstd_frames(blob[main_u:])
        else:
            raw = ce.decode_outer_zstd_frames(blob)
    else:
        ce.load_index(pack.BLOBSET_PATH)
        raw, *_ = ce.read_blob_full(pack.BLOBSET_PATH, index)
    _path, dds, *_ = et.parse_mini_txpk(raw)
    return dds


def decode(texconv, dds_bytes, tmp, name):
    src = os.path.join(tmp, name + ".dds")
    open(src, "wb").write(dds_bytes)
    subprocess.run([texconv, "-nologo", "-y", "-ft", "png", "-f", "R8G8B8A8_UNORM", "-m", "1",
                    "--ignore-srgb", "-o", tmp, src], check=True, stdout=subprocess.DEVNULL)
    return np.asarray(Image.open(os.path.join(tmp, name + ".png")).convert("RGB")).astype(np.float32)


def grass_albedo(lush):
    """Lush's blades re-tinted to TARGET (same recipe as realistic-pitch-grass)."""
    lum = lush @ np.array([0.2126, 0.7152, 0.0722], np.float32)
    d = lum / lum.mean()
    chroma = lush - lum[..., None]
    chroma -= chroma.reshape(-1, 3).mean(0)
    target = np.array(TARGET, np.float32)
    out = target * d[..., None] ** CONTRAST + chroma * CHROMA
    tip = np.clip(d - 1.1, 0, None)[..., None]
    out += 0.08 * tip * target.mean() * np.array([1.0, 0.6, -0.8], np.float32)
    return np.clip(out, 0, 255)


def pyramid(tile):
    levels = [tile]
    while levels[-1].shape[0] > 1:
        t = levels[-1]
        levels.append((t[0::2, 0::2] + t[1::2, 0::2] + t[0::2, 1::2] + t[1::2, 1::2]) / 4)
    return levels


def bilinear(img, u, v):
    """Wrap-around bilinear sample of img at texel coords (u, v) (arrays)."""
    n = img.shape[0]
    u = u - 0.5
    v = v - 0.5
    u0 = np.floor(u).astype(np.int64)
    v0 = np.floor(v).astype(np.int64)
    fu = (u - u0)[..., None]
    fv = (v - v0)[..., None]
    u0 %= n
    v0 %= n
    u1 = (u0 + 1) % n
    v1 = (v0 + 1) % n
    top = img[v0, u0] * (1 - fu) + img[v0, u1] * fu
    bot = img[v1, u0] * (1 - fu) + img[v1, u1] * fu
    return top * (1 - fv) + bot * fv


def render_grass(albedo):
    levels = pyramid(albedo)
    xs = np.arange(W, dtype=np.float64) + 0.5 - W / 2
    out = np.zeros((H, W, 3), np.float32)
    texel_per_m = TILE / TILE_M
    for y in range(H):
        acc = np.zeros((W, 3), np.float64)
        for s in range(V_SAMPLES):
            t = y + (s + 0.5) / V_SAMPLES + HORIZON_PX   # rows below the horizon
            z = FOCAL_PX * CAM_HEIGHT / t                 # depth, metres
            x_m = xs * CAM_HEIGHT / t                     # lateral, metres
            footprint = texel_per_m * CAM_HEIGHT / t      # tile texels per output pixel, across
            lod = max(0.0, np.log2(max(footprint, 1e-6)))
            l0 = min(int(lod), len(levels) - 1)
            l1 = min(l0 + 1, len(levels) - 1)
            f = lod - int(lod)
            u = x_m * texel_per_m
            v = np.full_like(u, z * texel_per_m)
            c = bilinear(levels[l0], u / 2 ** l0, v / 2 ** l0) * (1 - f)
            c += bilinear(levels[l1], u / 2 ** l1, v / 2 ** l1) * f
            # mowing stripes, soft-edged, converging on the vanishing point
            phase = x_m / STRIPE_M
            tri = np.abs((phase % 2.0) - 1.0)             # 0..1 triangle across two stripes
            stripe = np.clip((tri - 0.5) * 10, -1, 1)
            c *= (1 + STRIPE_AMOUNT * stripe)[:, None]
            acc += c
        out[y] = acc / V_SAMPLES
    return out


def lighting(stock_floor):
    lum = stock_floor @ np.array([0.2126, 0.7152, 0.0722], np.float32)
    img = Image.fromarray(np.clip(lum, 0, 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(70))
    light = np.asarray(img).astype(np.float32)
    light = light / np.percentile(light, 99)
    return (np.clip(light, 0, None) ** LIGHT_GAMMA * LIGHT_GAIN)[..., None]


def fade():
    """Alpha ramp: 0 at the top edge to 1 at FADE of the way down (smoothstep),
    so the grass dissolves into the backdrop instead of stopping at the grid
    row's edge."""
    t = np.clip((np.arange(H, dtype=np.float32) + 0.5) / (H * FADE), 0, 1)
    a = (t * t * (3 - 2 * t)) ** FADE_POWER
    return a[:, None, None] * np.ones((1, W, 1), np.float32)


def encode(texconv, img, tmp):
    os.makedirs(OUT_DIR, exist_ok=True)
    label = f"{entries.hash_of(FLOOR_PATH):016x}_floor_image"
    src = os.path.join(tmp, label + ".png")
    Image.fromarray(img).save(src)
    subprocess.run([texconv, "-nologo", "-y", "-f", FORMAT, "-m", "1", "--ignore-srgb",
                    "-o", OUT_DIR, src], check=True, stdout=subprocess.DEVNULL)
    return os.path.join(OUT_DIR, label + ".dds")


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--texconv", help="texconv.exe (default: the bundled toolchain one)")
    args = p.parse_args()
    texconv = os.path.abspath(args.texconv or games.toolchain("texconv", "texconv.exe"))
    if not os.path.exists(texconv):
        raise SystemExit("texconv.exe not found - pass --texconv")

    with tempfile.TemporaryDirectory() as tmp:
        lush = decode(texconv, stock_dds(LUSH_PATH), tmp, "lush")
        floor = decode(texconv, stock_dds(FLOOR_PATH), tmp, "floor")
        if floor.shape[:2] != (H, W):
            raise SystemExit(f"stock floor is {floor.shape[1]}x{floor.shape[0]}, expected {W}x{H}")
        rgb = render_grass(grass_albedo(lush)) * lighting(floor)
        a = fade()
        # premultiplied: fades the same whether Noesis blends it as premultiplied or straight
        img = np.clip(np.dstack([rgb * a, a * 255]), 0, 255).round().astype(np.uint8)
        out = encode(texconv, img, tmp)
    os.makedirs(os.path.dirname(PREVIEW), exist_ok=True)
    Image.fromarray(img).save(PREVIEW)
    print(f"floor mean {img[..., :3].reshape(-1, 3).mean(0).round(1)} -> {out}")
    print(f"preview -> {PREVIEW}")


if __name__ == "__main__":
    main()
