#!/usr/bin/env python3
"""
fangear.py - extra crowd merchandise per club: fan tees, polos and scarves in
the club's colours with its logos and wordmark, worn by that club's fans.

Every design is a *sheet*: a PNG of artboards drawn as the gear is seen,
upright and unstretched, at PX_PER_M pixels per metre. The installer bakes a
sheet onto the crowd mesh's own UV layout, so nobody paints in texture space:

  tee, polo (crowd t-shirt / short-sleeve models, 1024x1024 DXT1)
    front   the chest panel as seen from the pitch: x -0.21..0.21 m (the
            wearer's left is on the right), y 1.62 m (top row) .. 0.93 m
    back    the back panel as seen from behind, same box
    sleeve  both sleeves, unrolled: hem at the bottom row, shoulder at the top
    collar  the polo collar (tees have none)
  scarf (crowd scarf model, 512x512 DXT1)
    tail    one hanging end as seen from the pitch: fringe at the bottom, the
            neck at the top. Both ends get it, and the side against the chest
            gets it mirrored so it lines up at the folds.
    neck    the band round the neck, unrolled: the long axis goes round.

Texture layout (from the models' UVs): tops store the front panel at u 0-0.42
and the back at u 0.43-0.85 (v 0.5-1, the collar at v = 1, so upside down),
sleeves top right (hem at the low-v edge), the polo collar at u 0.92-0.98.
Scarf ends: v 0.189-0.344 (chest side) and 0.344-0.497 (outer side), length
along u, fringe at the outer u ends; the neck band v 0.514-0.827, two faces
folded at 0.67. Front/back texels are mapped through the triangles' 3D
positions (barycentric), the others through their UVs.

Commands:
    templates          resources/fangear/templates: layered PSDs + guide PNGs
    designs [icon ...] generate the default sheets into resources/fangear/<icon>/
                       (+ fangear.json, previews)
    preview [icon ...] re-render resources/fangear/<icon>/preview.png from the
                       sheets (3D, front and back)
    bake [icon ...] [--force]
                       bake the sheets into finished DDS kept beside them:
                       resources/fangear/<icon>/dds/<item>_<variant>.dds, keyed in
                       dds/keys.json by sheet hash + BAKE_VERSION. Only new or
                       edited sheets bake.
    install [--confirm] write every sheet's DDS (stored, or baked now) as
                       crowd/characters/textures/crowd_fan_<item>_<icon>_<variant>_col
                       (append, replace, or skip when the blob is unchanged)
                       and write the library table into crowd_items.lua. Then
                       run crowd-team-kits' `bake_crowd_jerseys.py register
                       --confirm` (the crowd texture table) and rebuild scripts.

Sheet files are resources/fangear/<icon>/<item>_<variant>.png with item tee,
polo or scarf. Hand-made ones (from the templates) just need that name; their
library label comes from the variant (tee_my_design -> "My Design").
"""

import argparse
import hashlib
import io
import json
import os
import re
import struct
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFont
from scipy import ndimage as ndi

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, "tools"))
sys.path.insert(0, os.path.join(ROOT, "mods", "crowd-flags"))
import add_entries as ae  # noqa: E402
import build_flags as bf  # noqa: E402
import club_icons  # noqa: E402
import pack  # noqa: E402

WORK = os.path.join(ROOT, "_build", "crowd-fangear")
GEAR = os.path.join(ROOT, "resources", "fangear")
TEXTURE_DIR = "crowd/characters/textures"
CROWD_ITEMS = os.path.join(HERE, "src", "script-game", "intermediatelua", "crowd", "crowd_items.lua")
GEN_BEGIN, GEN_END = "-- BEGIN GENERATED (crowd-fangear: fangear.py install)", "-- END GENERATED (crowd-fangear)"
PX_PER_M = 2000
SUPERSAMPLE = 2
BAKE_VERSION = 1             # bump when the bake or the texel maps change: stored DDS are re-baked

# ---- sheets -------------------------------------------------------------------

TOP_X = (-0.21, 0.21)
TOP_Y = (0.93, 1.62)
PANEL_W, PANEL_H = round((TOP_X[1] - TOP_X[0]) * PX_PER_M), round((TOP_Y[1] - TOP_Y[0]) * PX_PER_M)
TOP_BOARDS = {"front": (0, 0, PANEL_W, PANEL_H), "back": (PANEL_W + 40, 0, PANEL_W, PANEL_H),
              "sleeve": (2 * PANEL_W + 80, 0, 500, 600), "collar": (2 * PANEL_W + 80, 640, 500, 200)}
TOP_SHEET = (2 * PANEL_W + 580, PANEL_H)

TAIL_W, TAIL_H = 250, 740       # 0.125 x 0.37 m, the hanging end
SCARF_BOARDS = {"tail": (0, 0, TAIL_W, TAIL_H), "neck": (TAIL_W + 50, 0, 1000, 160)}
SCARF_SHEET = (TAIL_W + 1050, TAIL_H)
FRINGE = 0.075                  # m of tail at the bottom that is fringe (u 0.019-0.118 in the texture)

ITEMS = {
    # item: model (LOD 0 UVs), texture size, stock texture whose DDS header is reused, layout
    "tee": ("m_crowd_clothing_tshirt", 1024, "crowd_clothes_m_tshirt01_col", "top"),
    "polo": ("m_crowd_clothing_shortSleeve", 1024, "crowd_clothes_polo01_nrl_broncos_col", "top"),
    "scarf": ("m_crowd_scarf01", 512, "crowd_scarf01_nrl_broncos_col", "scarf"),
}
ITEM_LABELS = {"tee": "Tee", "polo": "Polo", "scarf": "Scarf"}


def boards(item):
    return TOP_BOARDS if ITEMS[item][3] == "top" else SCARF_BOARDS


def sheet_size(item):
    return TOP_SHEET if ITEMS[item][3] == "top" else SCARF_SHEET


# ---- meshes and UV maps --------------------------------------------------------

_index = None


def index():
    global _index
    if _index is None:
        _index = bf.Index()
    return _index


def load_mesh(model):
    """LOD 0 of a crowd model: pos (n,3), u, v, normal (n,3), triangles (t,3)."""
    raw = bf.read_entry(index().entry(f"crowd/characters/models/{model}.model"))
    sec = bf.sections(raw)
    parts = []
    base = 0
    for rec in bf.rel_targets(raw, sec[6]):
        f = struct.unpack_from("<12i", raw, rec)
        if f[4] != 0:
            continue
        V = np.frombuffer(raw, np.uint8, f[8] * 36, sec[10] + 36 * f[7]).reshape(-1, 36)
        h = V[:, :16].copy().view(np.float16).astype(np.float64)
        ioff = struct.unpack_from("<I", raw, sec[2] + 8)[0]
        tris = np.frombuffer(raw, np.uint16, f[11], sec[10] + ioff + 2 * f[10]).reshape(-1, 3).astype(int)
        parts.append((h[:, :3], h[:, 3], h[:, 7], h[:, 4:7], tris + base))
        base += len(V)
    pos, u, v, nrm, tris = (np.concatenate(p) for p in zip(*parts))
    return pos, u % 1, v % 1, nrm, tris


def rasterise(points, tris, shape, keep=None):
    """Triangles over a pixel grid: per pixel the triangle index (-1 = none)
    and barycentrics. points are pixel coordinates (x, y) per vertex. keep(t)
    may veto triangles; where triangles overlap, the later one wins unless
    depth (per vertex) is given through keep returning a z to keep the
    largest of."""
    H, W = shape
    tri_of = np.full((H, W), -1, np.int32)
    bary = np.zeros((H, W, 3), np.float32)
    depth = np.full((H, W), -np.inf, np.float32)
    for t, (a, b, c) in enumerate(tris):
        z = keep(t) if keep else 0.0
        if z is None:
            continue
        p = points[[a, b, c]]
        x0, y0 = np.floor(p.min(0)).astype(int)
        x1, y1 = np.ceil(p.max(0)).astype(int)
        x0, y0, x1, y1 = max(x0, 0), max(y0, 0), min(x1, W - 1), min(y1, H - 1)
        if x0 > x1 or y0 > y1:
            continue
        ys, xs = np.mgrid[y0:y1 + 1, x0:x1 + 1] + 0.5
        d = (p[1, 0] - p[0, 0]) * (p[2, 1] - p[0, 1]) - (p[2, 0] - p[0, 0]) * (p[1, 1] - p[0, 1])
        if abs(d) < 1e-12:
            continue
        w1 = ((xs - p[0, 0]) * (p[2, 1] - p[0, 1]) - (p[2, 0] - p[0, 0]) * (ys - p[0, 1])) / d
        w2 = ((p[1, 0] - p[0, 0]) * (ys - p[0, 1]) - (xs - p[0, 0]) * (p[1, 1] - p[0, 1])) / d
        w0 = 1 - w1 - w2
        inside = (w0 >= -1e-4) & (w1 >= -1e-4) & (w2 >= -1e-4)
        zz = z if np.isscalar(z) else w0 * z[0] + w1 * z[1] + w2 * z[2]
        if not np.isscalar(z):
            inside &= zz > depth[y0:y1 + 1, x0:x1 + 1]
        if not inside.any():
            continue
        sub = (slice(y0, y1 + 1), slice(x0, x1 + 1))
        tri_of[sub][inside] = t
        bary[sub][inside] = np.stack([w0, w1, w2], -1)[inside]
        if not np.isscalar(z):
            depth[sub][inside] = np.asarray(zz)[inside] if not np.isscalar(zz) else zz
    return tri_of, bary


def top_region(cu, cv):
    if cv >= 0.5:
        if cu < 0.43:
            return "front"
        if cu < 0.87:
            return "back"
        return "collar"
    return "sleeve"


def scarf_region(cu, cv):
    return "neck" if cv >= 0.5 else "tail"


def texel_map(item):
    """Per texel of the item's texture (at SUPERSAMPLE x its size): the sheet
    pixel it shows (sx, sy), and the covered mask. Cached in _build."""
    model, size, _donor, layout = ITEMS[item]
    path = os.path.join(WORK, f"map_{item}.npz")
    if os.path.exists(path):
        z = np.load(path)
        return z["sx"], z["sy"], z["covered"]
    N = size * SUPERSAMPLE
    pos, u, v, _nrm, tris = load_mesh(model)
    uv_px = np.c_[u * N, v * N]
    tri_of, bary = rasterise(uv_px, tris, (N, N))
    covered = tri_of >= 0
    ys, xs = np.nonzero(covered)
    t = tri_of[ys, xs]
    b = bary[ys, xs]
    tu = (xs + 0.5) / N
    tv = (ys + 0.5) / N
    cu = u[tris].mean(1)[t]
    cv = v[tris].mean(1)[t]
    region_of = top_region if layout == "top" else scarf_region
    regions = np.array([region_of(a, c) for a, c in zip(cu, cv)])
    sx = np.zeros(len(xs))
    sy = np.zeros(len(xs))
    bds = boards(item)
    if layout == "top":
        p = (pos[tris[t]] * b[..., None]).sum(1)
        for name, sign in (("front", 1), ("back", -1)):
            m = regions == name
            bx, by, _w, _h = bds[name]
            sx[m] = bx + (sign * p[m, 0] - TOP_X[0]) * PX_PER_M
            sy[m] = by + (TOP_Y[1] - p[m, 1]) * PX_PER_M
        # sleeves: one island each side of v 0.295, hem at the island's low-v edge
        for m in ((regions == "sleeve") & (cv < 0.295), (regions == "sleeve") & (cv >= 0.295)):
            if not m.any():
                continue
            sel = np.isin(np.arange(len(tris)), np.unique(t[m]))
            vu, vv = u[tris[sel]].ravel(), v[tris[sel]].ravel()
            bx, by, w, h = bds["sleeve"]
            sx[m] = bx + (tu[m] - vu.min()) / (vu.max() - vu.min()) * w
            sy[m] = by + (1 - (tv[m] - vv.min()) / (vv.max() - vv.min())) * h
        m = regions == "collar"
        if m.any():
            sel = np.isin(np.arange(len(tris)), np.unique(t[m]))
            vu, vv = u[tris[sel]].ravel(), v[tris[sel]].ravel()
            bx, by, w, h = bds["collar"]
            sx[m] = bx + (tu[m] - vu.min()) / (vu.max() - vu.min()) * w
            sy[m] = by + (tv[m] - vv.min()) / (vv.max() - vv.min()) * h
    else:
        tail = regions == "tail"
        tv_ = v[tris[np.unique(t[tail])]].ravel()
        v0, v1 = tv_.min(), tv_.max()
        fold = scarf_fold(pos, v, _nrm, tris)
        for left in (True, False):
            m = tail & ((cu < 0.5) if left else (cu >= 0.5))
            uu = u[tris[np.unique(t[m])]].ravel()
            u0, u1 = uu.min(), uu.max()
            along = (tu[m] - u0) / (u1 - u0) if left else (u1 - tu[m]) / (u1 - u0)
            outer = tv[m] >= fold
            if left:
                across = np.where(outer, (v1 - tv[m]) / (v1 - fold), (tv[m] - v0) / (fold - v0))
            else:
                across = np.where(outer, (tv[m] - fold) / (v1 - fold), (fold - tv[m]) / (fold - v0))
            bx, by, w, h = bds["tail"]
            sx[m] = bx + np.clip(across, 0, 1) * w
            sy[m] = by + (1 - np.clip(along, 0, 1)) * h
        m = regions == "neck"
        nu = u[tris[np.unique(t[m])]].ravel()
        nv = v[tris[np.unique(t[m])]].ravel()
        mid = (nv.min() + nv.max()) / 2
        bx, by, w, h = bds["neck"]
        sx[m] = bx + (tu[m] - nu.min()) / (nu.max() - nu.min()) * w
        row = np.where(tv[m] < mid, (tv[m] - nv.min()) / (mid - nv.min()), (nv.max() - tv[m]) / (nv.max() - mid))
        sy[m] = by + np.clip(row, 0, 1) * h
    SX = np.zeros((N, N), np.float32)
    SY = np.zeros((N, N), np.float32)
    SX[ys, xs] = sx
    SY[ys, xs] = sy
    # padding: every uncovered texel shows its nearest covered one (mips, bleeding)
    _d, (iy, ix) = ndi.distance_transform_edt(~covered, return_indices=True)
    SX, SY = SX[iy, ix], SY[iy, ix]
    os.makedirs(WORK, exist_ok=True)
    np.savez_compressed(path, sx=SX, sy=SY, covered=covered)
    return SX, SY, covered


def scarf_fold(pos, v, nrm, tris):
    """v where a scarf end's chest-side face turns into its outer face."""
    tail = v < 0.5
    rows = np.unique(np.round(v[tail], 3))
    inner = [r for r in rows if nrm[tail & (np.round(v, 3) == r), 2].mean() < -0.5]
    outer = [r for r in rows if nrm[tail & (np.round(v, 3) == r), 2].mean() > 0.5]
    return (max(r for r in inner if r < min(outer)) + min(outer)) / 2 if inner and outer else 0.344


def bake(item, sheet):
    """A design sheet (PIL image) -> the item's crowd texture (RGB)."""
    _model, size, _donor, _layout = ITEMS[item]
    if sheet.size != sheet_size(item):
        raise SystemExit(f"{item} sheet must be {sheet_size(item)}, got {sheet.size}")
    sx, sy, _covered = texel_map(item)
    a = np.asarray(sheet.convert("RGB")).astype(np.float32)
    out = np.stack([ndi.map_coordinates(a[..., c], [sy - 0.5, sx - 0.5], order=1, mode="nearest") for c in range(3)], -1)
    img = Image.fromarray(np.clip(out, 0, 255).astype(np.uint8), "RGB")
    return img.resize((size, size), Image.BOX)


# ---- 3D previews ---------------------------------------------------------------

def view_map(item, view, px_per_m=700):
    """Screen pixel -> texture uv for an orthographic front or back view of
    the item's mesh, plus a shade (lambert) and the covered mask. Cached."""
    path = os.path.join(WORK, f"view_{item}_{view}.npz")
    if os.path.exists(path):
        z = np.load(path)
        return z["u"], z["v"], z["shade"], z["covered"]
    pos, u, v, nrm, tris = load_mesh(ITEMS[item][0])
    sign = 1 if view == "front" else -1
    x0, x1 = (sign * pos[:, 0]).min() - 0.02, (sign * pos[:, 0]).max() + 0.02
    y0, y1 = pos[:, 1].min() - 0.02, pos[:, 1].max() + 0.02
    W, H = round((x1 - x0) * px_per_m), round((y1 - y0) * px_per_m)
    pts = np.c_[(sign * pos[:, 0] - x0) * px_per_m, (y1 - pos[:, 1]) * px_per_m]
    depth = sign * pos[:, 2]
    tri_of, bary = rasterise(pts, tris, (H, W), keep=lambda t: depth[tris[t]])
    covered = tri_of >= 0
    t = np.where(covered, tri_of, 0)
    U = (u[tris[t]] * bary).sum(-1)
    V = (v[tris[t]] * bary).sum(-1)
    n = (nrm[tris[t]] * bary[..., None]).sum(-2)
    n /= np.maximum(np.linalg.norm(n, axis=-1, keepdims=True), 1e-6)
    light = np.array([0.3 * sign, 0.5, 0.8 * sign])
    light /= np.linalg.norm(light)
    shade = 0.45 + 0.55 * np.clip(np.abs(n @ light), 0, 1)
    os.makedirs(WORK, exist_ok=True)
    np.savez_compressed(path, u=U, v=V, shade=shade, covered=covered)
    return U, V, shade, covered


def render(item, texture, view, background=(48, 48, 52)):
    U, V, shade, covered = view_map(item, view)
    tex = np.asarray(texture.convert("RGB")).astype(np.float32)
    s = tex.shape[0]
    rgb = tex[np.clip((V * s).astype(int), 0, s - 1), np.clip((U * s).astype(int), 0, s - 1)] * shade[..., None]
    out = np.where(covered[..., None], rgb, np.array(background, np.float32))
    return Image.fromarray(np.clip(out, 0, 255).astype(np.uint8), "RGB")


def preview_tile(item, texture, height=300):
    views = [render(item, texture, v) for v in ("front", "back")]
    views = [im.resize((max(1, round(im.width * height / im.height)), height), Image.LANCZOS) for im in views]
    tile = Image.new("RGB", (sum(im.width for im in views) + 6, height), (48, 48, 52))
    tile.paste(views[0], (0, 0))
    tile.paste(views[1], (views[0].width + 6, 0))
    return tile


# ---- designs -------------------------------------------------------------------

WHITE = (255, 255, 255)
BLACK = (20, 20, 22)

_df = None


def flags_module():
    """mods/crowd-flags/default_flags.py: club colours, HD logos, wordmarks, classics."""
    global _df
    if _df is None:
        import default_flags
        _df = default_flags
    return _df


def fit(logo, w, h):
    scale = min(w / logo.width, h / logo.height)
    return logo.resize((max(1, round(logo.width * scale)), max(1, round(logo.height * scale))), Image.LANCZOS)


class Sheet:
    """A design sheet; artboard coordinates are metres for the panels (x right
    as seen, y up) and fractions for the other boards."""

    def __init__(self, item, fill):
        self.item = item
        self.boards = boards(item)
        self.img = Image.new("RGBA", sheet_size(item), (0, 0, 0, 0))
        for name in self.boards:
            self.fill(name, fill)

    def box(self, name):
        x, y, w, h = self.boards[name]
        return x, y, w, h

    def fill(self, name, colour, frac=(0, 0, 1, 1)):
        x, y, w, h = self.box(name)
        ImageDraw.Draw(self.img).rectangle([x + frac[0] * w, y + frac[1] * h, x + frac[2] * w - 1, y + frac[3] * h - 1],
                                           fill=tuple(colour) + (255,))

    def panel_px(self, name, mx, my):
        x, y, _w, _h = self.box(name)
        return x + (mx - TOP_X[0]) * PX_PER_M, y + (TOP_Y[1] - my) * PX_PER_M

    def logo_m(self, name, logo, cx, cy, w, h):
        """Logo fitted in a w x h m box centred at (cx, cy) m on a panel."""
        if logo is None:
            return
        logo = fit(logo, w * PX_PER_M, h * PX_PER_M)
        px, py = self.panel_px(name, cx, cy)
        self.img.alpha_composite(logo, (round(px - logo.width / 2), round(py - logo.height / 2)))

    def logo_frac(self, name, logo, cx, cy, w, h):
        """Logo fitted in a box given as fractions of the board."""
        if logo is None:
            return
        x, y, bw, bh = self.box(name)
        logo = fit(logo, w * bw, h * bh)
        self.img.alpha_composite(logo, (round(x + cx * bw - logo.width / 2), round(y + cy * bh - logo.height / 2)))

    def save(self, path):
        self.img.convert("RGB").save(path)


class Club:
    """One club icon's colours and art (via default_flags)."""

    def __init__(self, icon, primary, secondary, classics):
        df = flags_module()
        self.icon = icon
        self.p, self.s = primary, secondary
        self.logos = df.Logos(index(), icon)
        self.word = self.logos.word
        self.classics = []
        for filename in classics:
            img = df.trim(Image.open(os.path.join(df.classic.SRC_DIR, filename)).convert("RGBA"))
            self.classics.append((filename, img))

    def logo(self, bg, one_colour):
        return self.logos.best(bg, one_colour)

    def wordmark(self, bg, prefer):
        """The wordmark in whichever of prefer / white / black reads best on bg."""
        df = flags_module()
        if self.word is None:
            return None, None
        options = [(c, df.recolour(self.word, c)) for c in (prefer, WHITE, BLACK)]
        colour, img = max(options, key=lambda o: df.visibility(o[1], bg, whole=True) * (1 if o[0] == prefer else 0.8))
        return "text.svg in #%02x%02x%02x" % colour, img

    def classic_on(self, img):
        """(background, trim) of the team colours a full-colour classic reads best on."""
        df = flags_module()
        return max(((self.p, self.s), (self.s, self.p)), key=lambda c: df.visibility(img, c[0], whole=True))


def contrast_colour(bg, options):
    df = flags_module()
    return max(options, key=lambda c: float(df.contrast(np.array([c], np.float32), bg)[0]))


def tee(club, body, trim, art):
    """art: list of (kind, ...) placements on the front; the back gets the
    wordmark across the shoulders when the club has one, else a small logo."""
    sh = Sheet("tee", body)
    sh.fill("sleeve", trim, (0, 0.86, 1, 1))
    used = []
    for kind in art:
        if kind == "chest_logo":
            name, img = club.logo(body, trim)
            sh.logo_m("front", img, 0, 1.31, 0.21, 0.19)
        elif kind == "left_chest":
            name, img = club.logo(body, trim)
            sh.logo_m("front", img, 0.085, 1.42, 0.075, 0.075)
        elif kind == "chest_word":
            name, img = club.wordmark(body, trim)
            sh.logo_m("front", img, 0, 1.36, 0.28, 0.09)
        elif kind == "logo_word":
            name, img = club.logo(body, trim)
            sh.logo_m("front", img, 0, 1.38, 0.16, 0.14)
            used.append(name)
            name, img = club.wordmark(body, trim)
            sh.logo_m("front", img, 0, 1.22, 0.26, 0.07)
        elif kind.startswith("classic:"):
            name, img = club.classics[int(kind.split(":")[1])]
            sh.logo_m("front", img, 0, 1.31, 0.21, 0.19)
        used.append(name)
    name, img = club.wordmark(body, trim)
    if img is not None:
        sh.logo_m("back", img, 0, 1.44, 0.26, 0.07)
    else:
        name, img = club.logo(body, trim)
        sh.logo_m("back", img, 0, 1.47, 0.06, 0.06)
    used.append(name)
    return sh, used


def polo(club, body, trim):
    sh = Sheet("polo", body)
    sh.fill("sleeve", trim, (0, 0.88, 1, 1))
    sh.fill("sleeve", trim, (0, 0.80, 1, 0.83))
    sh.fill("collar", trim)
    name, img = club.logo(body, trim)
    sh.logo_m("front", img, 0.085, 1.42, 0.07, 0.07)
    _n, small = club.logo(body, trim)
    sh.logo_m("back", small, 0, 1.49, 0.05, 0.05)
    return sh, [name]


def scarf(club, kind, a, b):
    """a = body colour, b = the other colour."""
    sh = Sheet("scarf", a)
    x, y, w, h = sh.box("tail")
    fringe = round(FRINGE * PX_PER_M)
    d = ImageDraw.Draw(sh.img)
    used = []
    if kind == "bars":
        band = round(0.055 * PX_PER_M)
        top = h - fringe
        k = 0
        while top > 0:
            d.rectangle([x, y + max(0, top - band), x + w - 1, y + top - 1], fill=(b if k % 2 == 0 else a) + (255,))
            top -= band
            k += 1
        nx, ny, nw, nh = sh.box("neck")
        for i in range(0, nw, 110):
            if (i // 110) % 2 == 0:
                d.rectangle([nx + i, ny, nx + min(nw, i + 110) - 1, ny + nh - 1], fill=b + (255,))
    else:
        # body colour with the other colour along both edges
        edge = round(0.12 * w)
        d.rectangle([x, y, x + edge - 1, y + h - fringe - 1], fill=b + (255,))
        d.rectangle([x + w - edge, y, x + w - 1, y + h - fringe - 1], fill=b + (255,))
        nx, ny, nw, nh = sh.box("neck")
        d.rectangle([nx, ny, nx + nw - 1, ny + round(0.14 * nh) - 1], fill=b + (255,))
        d.rectangle([nx, ny + nh - round(0.14 * nh), nx + nw - 1, ny + nh - 1], fill=b + (255,))
        if kind == "wordmark":
            name, img = club.wordmark(a, b)
            if img is None:
                return None, []
            img = img.rotate(90, expand=True)     # reads bottom to top on the hanging end
            sh.logo_frac("tail", img, 0.5, 0.44, 0.62, 0.62)     # clear of the fringe (bottom 0.2)
            used.append(name)
        elif kind == "logo":
            name, img = club.logo(a, b)
            sh.logo_frac("tail", img, 0.5, 0.66, 0.66, 0.26)
            band = round(0.025 * PX_PER_M)
            d.rectangle([x, y + h - fringe - 2 * band, x + w - 1, y + h - fringe - band - 1], fill=b + (255,))
            used.append(name)
    # fringe: threads in both colours
    for i in range(0, w, 10):
        d.rectangle([x + i, y + h - fringe, x + i + 9, y + h - 1], fill=(a if (i // 10) % 2 == 0 else b) + (255,))
    return sh, used


def designs_for(club):
    """variant name -> (item, label, Sheet, logos used)."""
    p, s = club.p, club.s
    out = {}
    word = club.word is not None

    def add(item, variant, label, made):
        sh, used = made
        if sh is not None:
            out[f"{item}_{variant}"] = (item, label, sh, [u for u in used if u])

    white_trim = contrast_colour(WHITE, (p, s))
    # a white tee/polo only adds something when neither club colour is white already
    white = min(p) < 225 and min(s) < 225
    add("tee", "plain_primary", "Plain Tee (Primary)", tee(club, p, s, []))
    add("tee", "plain_secondary", "Plain Tee (Secondary)", tee(club, s, p, []))
    add("tee", "logo_primary", "Logo Tee (Primary)", tee(club, p, s, ["chest_logo"]))
    add("tee", "logo_secondary", "Logo Tee (Secondary)", tee(club, s, p, ["chest_logo"]))
    if white:
        add("tee", "logo_white", "Logo Tee (White)", tee(club, WHITE, white_trim, ["chest_logo"]))
    add("tee", "badge_white", "Badge Tee (White)", tee(club, WHITE, white_trim, ["left_chest"]))
    if word:
        add("tee", "wordmark_primary", "Wordmark Tee (Primary)", tee(club, p, s, ["chest_word"]))
        add("tee", "wordmark_secondary", "Wordmark Tee (Secondary)", tee(club, s, p, ["chest_word"]))
        add("tee", "logo_wordmark_primary", "Logo + Wordmark Tee (Primary)", tee(club, p, s, ["logo_word"]))
        add("tee", "logo_wordmark_secondary", "Logo + Wordmark Tee (Secondary)", tee(club, s, p, ["logo_word"]))
    for n, (_f, img) in enumerate(club.classics):
        body, trim = club.classic_on(img)
        add("tee", f"classic_{n + 1}", f"Classic Logo Tee #{n + 1}", tee(club, body, trim, [f"classic:{n}"]))
    add("polo", "primary", "Polo (Primary)", polo(club, p, s))
    add("polo", "secondary", "Polo (Secondary)", polo(club, s, p))
    if white:
        add("polo", "white", "Polo (White)", polo(club, WHITE, white_trim))
    add("scarf", "bars", "Bar Scarf", scarf(club, "bars", p, s))
    add("scarf", "bars_inverted", "Bar Scarf (Inverted)", scarf(club, "bars", s, p))
    add("scarf", "logo", "Logo Scarf", scarf(club, "logo", p, s))
    if word:
        add("scarf", "wordmark", "Wordmark Scarf", scarf(club, "wordmark", p, s))
        add("scarf", "wordmark_inverted", "Wordmark Scarf (Inverted)", scarf(club, "wordmark", s, p))
    return out


def cmd_designs(args):
    df = flags_module()
    colours = df.club_colours()
    classics = {}
    for icon, filename, _label, _fill in df.classic.CLASSICS:
        classics.setdefault(icon.rsplit("_classic_", 1)[0], []).append(filename)
    icons = args.icons or sorted(i for i in colours if os.path.isdir(os.path.join(ROOT, "resources", "flags", i)))
    manifest_path = os.path.join(GEAR, "fangear.json")
    manifest = json.load(open(manifest_path)) if os.path.exists(manifest_path) else {}
    for icon in icons:
        primary, secondary = colours[icon]
        club = Club(icon, primary, secondary, classics.get(icon, []))
        folder = os.path.join(GEAR, icon)
        os.makedirs(folder, exist_ok=True)
        entry = manifest.setdefault(icon, {})
        entry.update({"primary": "#%02x%02x%02x" % primary, "secondary": "#%02x%02x%02x" % secondary})
        labels = entry.setdefault("labels", {})
        logos = entry.setdefault("logos", {})
        made = designs_for(club)
        # generated designs that no longer apply go (hand-made sheets aren't in labels)
        for name in [n for n in labels if n not in made]:
            path = os.path.join(folder, name + ".png")
            if os.path.exists(path):
                os.remove(path)
            labels.pop(name)
            logos.pop(name, None)
        for name, (_item, label, sh, used) in made.items():
            sh.save(os.path.join(folder, name + ".png"))
            labels[name] = label
            logos[name] = used
        with open(manifest_path, "w") as f:
            json.dump(manifest, f, indent=1, sort_keys=True)
        write_preview(icon)
        print(f"{icon}: {len(labels)} designs")
    if not args.icons:
        contact_sheet()     # slow (bakes every sheet); `preview` with no icons rebuilds it


# ---- sheets on disk ------------------------------------------------------------

def label_for(name, labels):
    if name in labels:
        return labels[name]
    item, variant = name.split("_", 1)
    return f"{variant.replace('_', ' ').title()} {ITEM_LABELS[item]}"


def gear_sheets():
    """icon -> [(name, item, path)] from resources/fangear/<icon>/<item>_<variant>.png."""
    out = {}
    for icon in sorted(os.listdir(GEAR)) if os.path.isdir(GEAR) else []:
        folder = os.path.join(GEAR, icon)
        if not os.path.isdir(folder) or icon == "templates":
            continue
        rows = []
        for f in sorted(os.listdir(folder)):
            m = re.fullmatch(r"(tee|polo|scarf)_([a-z0-9_]+)\.png", f.lower())
            if m:
                rows.append((f[:-4].lower(), m.group(1), os.path.join(folder, f)))
        order = {"tee": 0, "polo": 1, "scarf": 2}
        rows.sort(key=lambda r: (order[r[1]], r[0]))
        if rows:
            out[icon] = rows
    return out


def manifest_labels():
    path = os.path.join(GEAR, "fangear.json")
    data = json.load(open(path)) if os.path.exists(path) else {}
    return {icon: d.get("labels", {}) for icon, d in data.items()}


def write_preview(icon):
    rows = gear_sheets().get(icon, [])
    labels = manifest_labels().get(icon, {})
    tiles = []
    for name, item, path in rows:
        tile = preview_tile(item, bake(item, Image.open(path)), 260)
        canvas = Image.new("RGB", (tile.width, tile.height + 26), (30, 30, 34))
        canvas.paste(tile, (0, 26))
        ImageDraw.Draw(canvas).text((6, 6), label_for(name, labels), fill=WHITE)
        tiles.append(canvas)
    if not tiles:
        return
    per_row = 6
    cw = max(t.width for t in tiles)
    ch = max(t.height for t in tiles)
    sheet = Image.new("RGB", (cw * min(per_row, len(tiles)), ch * ((len(tiles) + per_row - 1) // per_row)), (30, 30, 34))
    for k, t in enumerate(tiles):
        sheet.paste(t, ((k % per_row) * cw, (k // per_row) * ch))
    sheet.save(os.path.join(GEAR, icon, "preview.png"))


def contact_sheet(tile_h=120):
    """resources/fangear/fangear_sheet.png: every icon's designs, front views."""
    sheets = gear_sheets()
    rows = []
    for icon, items in sheets.items():
        tiles = []
        for name, item, path in items:
            im = render(item, bake(item, Image.open(path)), "front")
            tiles.append(im.resize((max(1, round(im.width * tile_h / im.height)), tile_h), Image.LANCZOS))
        rows.append((icon, tiles))
    width = 170 + max(sum(t.width + 4 for t in tiles) for _i, tiles in rows)
    out = Image.new("RGB", (width, (tile_h + 6) * len(rows)), (30, 30, 34))
    d = ImageDraw.Draw(out)
    for r, (icon, tiles) in enumerate(rows):
        y = r * (tile_h + 6)
        d.text((6, y + tile_h // 2), icon, fill=WHITE, anchor="lm")
        x = 170
        for t in tiles:
            out.paste(t, (x, y))
            x += t.width + 4
    out.save(os.path.join(GEAR, "fangear_sheet.png"))


def cmd_preview(args):
    for icon in args.icons or sorted(gear_sheets()):
        write_preview(icon)
        print(icon)
    contact_sheet()


# ---- templates -----------------------------------------------------------------

def guides(item):
    """Guide overlay for a sheet: each board's outline, the mesh's coverage
    (where the art actually lands) and labels."""
    pos, u, v, _nrm, tris = load_mesh(ITEMS[item][0])
    sx, sy, covered = texel_map(item)
    img = Image.new("RGBA", sheet_size(item), (0, 0, 0, 0))
    # coverage: splat every covered texel's sheet position
    land = np.zeros(sheet_size(item)[::-1], bool)
    xs = np.clip(sx[covered].astype(int), 0, land.shape[1] - 1)
    ys = np.clip(sy[covered].astype(int), 0, land.shape[0] - 1)
    land[ys, xs] = True
    land = ndi.binary_closing(ndi.binary_dilation(land, iterations=2), iterations=6)
    edge = land & ~ndi.binary_erosion(land, iterations=3)
    a = np.zeros(land.shape + (4,), np.uint8)
    a[~land] = (0, 0, 0, 110)
    a[edge] = (0, 255, 255, 255)
    img = Image.fromarray(a, "RGBA")
    d = ImageDraw.Draw(img)
    try:
        font = ImageFont.truetype("arialbd.ttf", 28)
    except OSError:
        font = ImageFont.load_default()
    notes = {
        "front": "FRONT - as seen from the pitch",
        "back": "BACK - as seen from behind",
        "sleeve": "SLEEVES - hem at the bottom",
        "collar": "COLLAR (polo only)",
        "tail": "SCARF END",
        "neck": "NECK BAND - goes round the neck",
    }
    for name, (x, y, w, h) in boards(item).items():
        d.rectangle([x, y, x + w - 1, y + h - 1], outline=(255, 0, 255, 255), width=3)
        d.text((x + 10, y + 8), notes[name], fill=(255, 0, 255, 255), font=font)
    if ITEMS[item][3] == "top":
        for name in ("front", "back"):
            for my, text in ((1.31, "chest logo centre"), (1.44, "upper back")):
                if (name == "back") != (text == "upper back"):
                    continue
                px, py = Sheet(item, (0, 0, 0)).panel_px(name, 0, my)
                d.line([px - 40, py, px + 40, py], fill=(255, 255, 0, 255), width=3)
                d.line([px, py - 40, px, py + 40], fill=(255, 255, 0, 255), width=3)
                d.text((px + 48, py - 14), text, fill=(255, 255, 0, 255), font=font)
    else:
        x, y, w, h = boards(item)["tail"]
        fy = y + h - round(FRINGE * PX_PER_M)
        d.line([x, fy, x + w, fy], fill=(255, 255, 0, 255), width=3)
        d.text((x + 6, fy + 8), "fringe", fill=(255, 255, 0, 255), font=font)
        d.text((x + 6, y + 44), "neck end", fill=(255, 255, 0, 255), font=font)
    return img


def cmd_templates(args):
    sys.path.insert(0, os.path.join(ROOT, "tools"))
    import flag_template as ft
    from pytoshop.user import nested_layers
    out = os.path.join(GEAR, "templates")
    os.makedirs(out, exist_ok=True)
    df = flags_module()
    colours = df.club_colours()
    icon = args.icon
    club = Club(icon, *colours[icon], [])
    made = {name: sh.img for name, (_item, _label, sh, _used) in designs_for(club).items()}
    tee_sample = "tee_logo_wordmark_primary" if club.word else "tee_logo_primary"
    # template: guides from the model with every board (the polo has the collar), the
    # visible sample, hidden extra samples, and the items its preview shows
    templates = [
        ("top", "polo", "polo_primary", [("Tee sample", tee_sample)], [("tee", tee_sample), ("polo", "polo_primary")]),
        ("scarf", "scarf", "scarf_wordmark" if club.word else "scarf_bars", [], None),
    ]
    for kind, item, sample_name, extras, shown in templates:
        sample = made[sample_name]
        shown = shown or [(item, sample_name)]
        guide = guides(item)
        base = Image.new("RGBA", sheet_size(item), tuple(club.p) + (255,))
        layers = [ft.psd_layer("GUIDES (hide before exporting)", guide),
                  ft.psd_layer(f"Design ({icon} sample)", sample)]
        layers += [ft.psd_layer(f"{label} ({icon})", made[name], visible=False) for label, name in extras]
        layers.append(ft.psd_layer("Base colour", base))
        psd = nested_layers.nested_layers_to_psd(layers, color_mode=3)
        with open(os.path.join(out, f"{kind}_template.psd"), "wb") as f:
            psd.write(f)
        flat = sample.copy()
        flat.alpha_composite(guide)
        flat.convert("RGB").save(os.path.join(out, f"{kind}_template_guides.png"))
        tiles = [preview_tile(i, bake(i, made[name]), 360) for i, name in shown]
        strip = Image.new("RGB", (sum(t.width + 10 for t in tiles), 360), (48, 48, 52))
        x = 0
        for t in tiles:
            strip.paste(t, (x, 0))
            x += t.width + 10
        strip.save(os.path.join(out, f"{kind}_template_preview.png"))
        print(f"{kind}_template.psd ({sheet_size(item)[0]} x {sheet_size(item)[1]})")


# ---- install -------------------------------------------------------------------

def texture_name(icon, name):
    item, variant = name.split("_", 1)
    return f"crowd_fan_{item}_{icon}_{variant}_col".lower()


def write_library(clubs, library):
    with open(CROWD_ITEMS, encoding="utf-8") as f:
        src = f.read()
    lines = [GEN_BEGIN,
             "-- club id -> club icon, for the clubs whose icon has fangear",
             "FangearClubs = {"]
    lines += [f"\t[{cid}] = \"{icon}\", -- {name}" for cid, icon, name in clubs]
    lines += ["}", "-- icon -> the gear its fans can wear: item (tee, polo, scarf), library label, crowd texture",
              "FangearLibrary = {"]
    for icon, rows in library.items():
        lines.append(f"\t{icon} = {{")
        lines += [f"\t\t{{ item = \"{item}\", name = \"{label}\", texture = \"{tex}\" }}," for item, label, tex in rows]
        lines.append("\t},")
    lines += ["}", GEN_END]
    start, end = src.index(GEN_BEGIN), src.index(GEN_END) + len(GEN_END)
    with open(CROWD_ITEMS, "w", encoding="utf-8", newline="\n") as f:
        f.write(src[:start] + "\n".join(lines) + src[end:])


def donor_headers():
    """item -> the 128-byte DDS header of its stock donor texture (DXT1, size, mips)."""
    idx = index()
    out = {}
    for item, (_model, size, donor, _layout) in ITEMS.items():
        dds = idx.texture(f"{TEXTURE_DIR}/{donor}.texture")
        if dds[84:88] != b"DXT1" or struct.unpack_from("<2I", dds, 12) != (size, size):
            raise SystemExit(f"unexpected donor texture format: {donor}")
        out[item] = (dds[:128], len(dds))
    return out


class ReadyDds:
    """Finished textures kept beside each club's sheets, as the exact DDS bytes
    install writes: resources/fangear/<icon>/dds/<item>_<variant>.dds, with
    dds/keys.json holding each one's key (sheet hash + BAKE_VERSION). A
    stored DDS whose key matches is used as it is; others are baked and saved."""

    def __init__(self, icon, donors):
        self.folder = os.path.join(GEAR, icon, "dds")
        self.donors = donors
        self.keys_path = os.path.join(self.folder, "keys.json")
        try:
            self.keys = json.load(open(self.keys_path))
        except (OSError, ValueError):
            self.keys = {}
        self.dirty = False

    @staticmethod
    def key(item, path):
        return hashlib.sha1(f"{BAKE_VERSION}:{item}:".encode() + open(path, "rb").read()).hexdigest()

    def get(self, name, item, path, force=False):
        """(DDS bytes, baked now?)"""
        dds_path = os.path.join(self.folder, name + ".dds")
        key = self.key(item, path)
        if not force and self.keys.get(name) == key and os.path.exists(dds_path):
            return open(dds_path, "rb").read(), False
        header, length = self.donors[item]
        dds = bf.dxt1_with_mips(bake(item, Image.open(path)), header)
        if len(dds) != length:
            raise SystemExit(f"{name}: DDS is {len(dds)} bytes, the donor is {length}")
        os.makedirs(self.folder, exist_ok=True)
        with open(dds_path, "wb") as f:
            f.write(dds)
        self.keys[name] = key
        self.dirty = True
        return dds, True

    def prune(self, names):
        """Drop stored DDS whose sheet is gone."""
        for name in [n for n in self.keys if n not in names]:
            self.keys.pop(name)
            self.dirty = True
            path = os.path.join(self.folder, name + ".dds")
            if os.path.exists(path):
                os.remove(path)

    def save(self):
        if self.dirty:
            with open(self.keys_path, "w") as f:
                json.dump(self.keys, f, indent=1, sort_keys=True)


def cmd_bake(args):
    donors = donor_headers()
    baked = kept = 0
    for icon, rows in gear_sheets().items():
        if args.icons and icon not in args.icons:
            continue
        ready = ReadyDds(icon, donors)
        for name, item, path in rows:
            _dds, fresh = ready.get(name, item, path, args.force)
            baked += fresh
            kept += not fresh
        ready.prune({name for name, _item, _path in rows})
        ready.save()
    print(f"{baked} baked, {kept} already current (resources/fangear/<icon>/dds; --force re-bakes)")


def cmd_install(args):
    idx = index()
    donors = donor_headers()
    registry = {e["path"]: e for e in (ae.load_registry() or {"entries": []})["entries"]}
    sheets = gear_sheets()
    labels = manifest_labels()
    library = {}
    added = replaced = unchanged = baked = 0
    for icon, rows in sheets.items():
        library[icon] = []
        ready = ReadyDds(icon, donors)
        for name, item, path in rows:
            tex = texture_name(icon, name)
            library[icon].append((item, label_for(name, labels.get(icon, {})), tex))
            entry_path = f"{TEXTURE_DIR}/{tex}.texture"
            exists = idx.entry(entry_path) is not None
            if not args.confirm:
                replaced += exists
                added += not exists
                continue
            dds, fresh = ready.get(name, item, path)
            baked += fresh
            blob, sizes = club_icons.make_blob(entry_path, dds)
            rec = registry.get(entry_path.lower())
            if exists and rec and os.path.exists(rec["blob_path"]) and open(rec["blob_path"], "rb").read() == blob:
                unchanged += 1
                continue
            ae.add_entry(pack.BLOBSET_PATH, entry_path, blob, sizes, f"crowd-fangear {icon} {name}", True, replace=exists)
            replaced += exists
            added += not exists
        ready.prune({name for name, _item, _path in rows})
        ready.save()
    clubs = [(cid, icon, name) for cid, name, icon, _p, _s in bf.load_clubs() if icon in library]
    write_library(clubs, library)
    total = sum(len(r) for r in library.values())
    print(f"{total} fangear textures ({added} new, {replaced} replaced, {unchanged} unchanged; {baked} baked) "
          f"for {len(library)} icons, {len(clubs)} clubs; library written to {os.path.relpath(CROWD_ITEMS, ROOT)}")
    if args.confirm:
        print("next: python mods\\crowd-team-kits\\bake_crowd_jerseys.py register --confirm, then rebuild scripts")
    else:
        print("dry run - pass --confirm to write the textures (close the game first)")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("templates")
    p.add_argument("--icon", default="nrl_broncos")
    p = sub.add_parser("designs")
    p.add_argument("icons", nargs="*")
    p = sub.add_parser("preview")
    p.add_argument("icons", nargs="*")
    p = sub.add_parser("bake")
    p.add_argument("icons", nargs="*")
    p.add_argument("--force", action="store_true")
    p = sub.add_parser("install")
    p.add_argument("--confirm", action="store_true")
    args = ap.parse_args()
    {"templates": cmd_templates, "designs": cmd_designs, "preview": cmd_preview, "bake": cmd_bake,
     "install": cmd_install}[args.cmd](args)


if __name__ == "__main__":
    main()
