#!/usr/bin/env python3
"""
make_patterns.py - build the headgear-patterns tint masks.

Each pattern is a copy of a stock helmet's custom01 col mask (R shell,
B trim, A straps) with a new G channel, the same way Kalyn Ponga's custom02
is custom01 with his design in G (see resources/headgear-templates). The game
tints G with headwearColour2.

"lightning" is a white thunderbolt / cracked-lightning print like the Steeden
headgear Jahrome Hughes wears: branching random-walk bolts, drawn at 2x and
downsampled for soft edges, kept inside the shell (off the trim, straps and
vent holes). It is fixed-seed, so a rebuild gives the same texture.

Outputs (mods/headgear-patterns/textures/, upright texture space):
    helmet_<layout>_lightning_col.png        2048x2048 RGBA mask
    preview_<layout>_lightning_flat.png      tinted UV layout
    preview_<layout>_lightning_3d.png        tinted mesh, three views

Usage:
    python mods/headgear-patterns/make_patterns.py [--seed N]
"""

import argparse
import math
import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

MOD = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(MOD))
sys.path.insert(0, os.path.join(REPO, "tools"))
import bigant_mesh as bm  # noqa: E402
import headgear_template as ht  # noqa: E402

RAW = os.path.join(REPO, "resources", "headgear-templates", "raw")
OUT = os.path.join(MOD, "textures")
SIZE = 2048
SS = 2  # supersampling for the bolt drawing

# layout -> (mesh used for UVs and the preview, stock custom01 mask)
LAYOUTS = {
    "adidas01": ("adidas01_Male", "helmet_adidas01_custom01_col.png"),
    "madisonAirFlo": ("madisonAirFlo_Male", "helmet_madisonairflo_custom01_col.png"),
}
# Preview tints = the colours given to Jahrome Hughes (defaultdata JSON).
TINTS = [(28, 4, 62), (245, 245, 245), (28, 4, 62), (20, 20, 20)]


def bolt(draw, rng, x, y, heading, length, width, depth):
    """One crack: a jittered walk that keeps roughly to `heading`, thinning
    as it goes and throwing off shorter, thinner branches."""
    angle = heading
    travelled = 0.0
    while travelled < length and width > 1.5 * SS:
        step = rng.uniform(12, 26) * SS
        angle = 0.75 * angle + 0.25 * heading + rng.normal(0, 0.55)
        nx, ny = x + math.cos(angle) * step, y + math.sin(angle) * step
        draw.line([(x, y), (nx, ny)], fill=255, width=max(1, int(round(width))))
        r = width / 2
        draw.ellipse([nx - r, ny - r, nx + r, ny + r], fill=255)
        if rng.random() < 0.08:  # ink splash at a joint
            r = width * rng.uniform(0.9, 1.6)
            draw.ellipse([nx - r, ny - r * rng.uniform(0.5, 1), nx + r, ny + r], fill=255)
        if depth < 2 and rng.random() < 0.16:
            side = rng.choice((-1, 1))
            bolt(draw, rng, nx, ny, angle + side * rng.uniform(0.45, 1.2),
                 (length - travelled) * rng.uniform(0.25, 0.6), width * rng.uniform(0.45, 0.7), depth + 1)
        x, y = nx, ny
        travelled += step
        width *= rng.uniform(0.95, 0.99)


def seed_points(area, rng, spacing):
    """Roughly even start points inside `area` (bool, texture res)."""
    ys, xs = np.nonzero(area)
    order = rng.permutation(len(xs))
    picked = []
    for k in order:
        p = (xs[k], ys[k])
        if all((p[0] - q[0]) ** 2 + (p[1] - q[1]) ** 2 > spacing ** 2 for q in picked):
            picked.append(p)
        if len(picked) > 400:
            break
    return picked


def lightning(area, rng, spacing=190):
    canvas = Image.new("L", (SIZE * SS, SIZE * SS), 0)
    draw = ImageDraw.Draw(canvas)
    for x, y in seed_points(area, rng, spacing):
        heading = rng.uniform(0, 2 * math.pi)
        for direction in (0, math.pi):  # grow both ways from the seed
            bolt(draw, rng, x * SS, y * SS, heading + direction + rng.normal(0, 0.3),
                 rng.uniform(140, 300) * SS, rng.uniform(8, 13) * SS, 0)
    return np.asarray(canvas.resize((SIZE, SIZE), Image.LANCZOS))


def build(layout, seed):
    model, mask_name = LAYOUTS[layout]
    bm.RL26_KIND["helmet"] = "characters/helmets"
    P, N, I, UV = bm.load_rl26("helmet", model)
    xy = ht.uv_pixels(UV)
    # Outer surface only: the inner liner has its own small islands, where a
    # bolt would come out as a big white blob.
    centre = (P.min(0) + P.max(0)) / 2
    outward = np.einsum("tij,tj->t", N[I], P[I].mean(1) - centre) > 0
    cov = np.asarray(ht.coverage(xy, UV, I[outward])) > 0
    stock = np.asarray(Image.open(os.path.join(RAW, mask_name)).convert("RGBA")).copy()
    # Shell only: on the mesh, not trim (B) / straps (A) / vent holes (R).
    shell = cov & (stock[..., 0] > 128) & (stock[..., 2] < 128) & (stock[..., 3] < 128)
    shell_img = Image.fromarray((shell * 255).astype(np.uint8)).filter(ImageFilter.MinFilter(5))
    shell_soft = np.asarray(shell_img.filter(ImageFilter.GaussianBlur(1.5))) / 255.0
    rng = np.random.default_rng(seed)
    g = lightning(np.asarray(shell_img) > 0, rng)
    mask = stock
    mask[..., 1] = np.round(g * shell_soft).astype(np.uint8)
    return mask, (P, N, I, UV)


def tint(mask):
    m = mask.astype(np.float32) / 255
    out = np.zeros(mask.shape[:2] + (3,), np.float32) + np.array(TINTS[0], np.float32)
    for ch in (1, 2, 3):
        out = out + (np.array(TINTS[ch], np.float32) - out) * m[..., ch:ch + 1]
    return out


def render(colour, mesh, yaw_deg, size=640):
    """Orthographic, Lambert-shaded, z-buffered render of the textured mesh."""
    P, N, I, UV = mesh
    a = math.radians(yaw_deg)
    rot = np.array([[math.cos(a), 0, math.sin(a)], [0, 1, 0], [-math.sin(a), 0, math.cos(a)]])
    V, Nr = P @ rot.T, N @ rot.T
    lo, hi = V.min(0), V.max(0)
    scale = 0.9 * size / max(hi[0] - lo[0], hi[1] - lo[1])
    sx = (V[:, 0] - (lo[0] + hi[0]) / 2) * scale + size / 2
    sy = size / 2 - (V[:, 1] - (lo[1] + hi[1]) / 2) * scale
    tex = ht.uv_pixels(UV)
    img = np.full((size, size, 3), 200, np.float32)
    zbuf = np.full((size, size), -np.inf)
    light = np.array([0.3, 0.5, 0.8]) / np.linalg.norm([0.3, 0.5, 0.8])
    for t in I:
        x, y, z = sx[t], sy[t], V[t, 2]
        x0, x1 = int(max(x.min(), 0)), int(min(math.ceil(x.max()), size - 1))
        y0, y1 = int(max(y.min(), 0)), int(min(math.ceil(y.max()), size - 1))
        if x1 < x0 or y1 < y0:
            continue
        den = (y[1] - y[2]) * (x[0] - x[2]) + (x[2] - x[1]) * (y[0] - y[2])
        if abs(den) < 1e-9:
            continue
        gx, gy = np.meshgrid(np.arange(x0, x1 + 1) + 0.5, np.arange(y0, y1 + 1) + 0.5)
        w0 = ((y[1] - y[2]) * (gx - x[2]) + (x[2] - x[1]) * (gy - y[2])) / den
        w1 = ((y[2] - y[0]) * (gx - x[2]) + (x[0] - x[2]) * (gy - y[2])) / den
        w2 = 1 - w0 - w1
        inside = (w0 >= 0) & (w1 >= 0) & (w2 >= 0)
        if not inside.any():
            continue
        zz = w0 * z[0] + w1 * z[1] + w2 * z[2]
        sub = zbuf[y0:y1 + 1, x0:x1 + 1]
        draw = inside & (zz > sub)
        if not draw.any():
            continue
        # Triangles straddling u = 1 sample as one piece, like the template.
        u = UV[t, 0] - math.floor(UV[t, 0].min())
        tu = (w0 * u[0] + w1 * u[1] + w2 * u[2]) * SIZE
        tv = w0 * tex[t[0], 1] + w1 * tex[t[1], 1] + w2 * tex[t[2], 1]
        c = colour[np.clip(tv.astype(int), 0, SIZE - 1), np.clip(tu.astype(int), 0, SIZE - 1)]
        n = w0[..., None] * Nr[t[0]] + w1[..., None] * Nr[t[1]] + w2[..., None] * Nr[t[2]]
        n /= np.linalg.norm(n, axis=-1, keepdims=True) + 1e-9
        shade = 0.35 + 0.65 * np.clip(np.abs(n @ light), 0, 1)
        sub[draw] = zz[draw]
        img[y0:y1 + 1, x0:x1 + 1][draw] = c[draw] * shade[draw][:, None]
    return Image.fromarray(np.clip(img, 0, 255).astype(np.uint8))


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--seed", type=int, default=211)
    ap.add_argument("--no-3d", action="store_true", help="skip the (slow) mesh previews")
    args = ap.parse_args()
    os.makedirs(OUT, exist_ok=True)
    for layout in LAYOUTS:
        mask, mesh = build(layout, args.seed)
        name = f"helmet_{layout.lower()}_lightning_col"
        Image.fromarray(mask, "RGBA").save(os.path.join(OUT, name + ".png"))
        colour = tint(mask)
        Image.fromarray(colour.astype(np.uint8)).resize((1024, 1024), Image.LANCZOS).save(
            os.path.join(OUT, f"preview_{layout.lower()}_lightning_flat.png"))
        if not args.no_3d:
            views = [render(colour, mesh, yaw) for yaw in (90, 30, -150)]
            sheet = Image.new("RGB", (640 * 3, 640), (200, 200, 200))
            for k, v in enumerate(views):
                sheet.paste(v, (640 * k, 0))
            sheet.save(os.path.join(OUT, f"preview_{layout.lower()}_lightning_3d.png"))
        print(f"{layout}: {name}.png")


if __name__ == "__main__":
    main()
