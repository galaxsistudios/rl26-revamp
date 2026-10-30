#!/usr/bin/env python3
"""
build_kits.py - turn Rugby League Live 4 kit textures (one 2048x2048 image
holding shirt, shorts and socks in RLL4's UV layout, see
resources/old-jerseys) into RL26 kits: separate top / shorts / socks
textures in RL26's layouts, new design items, and new kit slots on the
2026 NRL clubs. kits.json lists every kit.

How the layout conversion works: both games use the same skeleton and
pose, so their kit meshes line up in 3D (tools/bigant_mesh.py reads them).
For every texel of RL26's top_round05 / shorts01 / socks01 textures (laid
out by those models' own UVs, verified in-game with a labelled test grid),
the texel's 3D point on the RL26 mesh is found, then the nearest point with a
matching normal on the same part (shirt / shorts / socks) of RLL4's kit
mesh, and the RLL4 texture is sampled at that point's UV. That texel ->
RLL4-UV map doesn't depend on the kit, so it is computed once and cached.
Two fix-ups: RL26's sleeves are longer than RLL4's cap sleeves, so sleeve
texels skip RLL4's cuff fold (else the underarm picks up the cuff colour)
except for RL26's last 2 cm, which is moved onto RLL4's cuff; and texels
outside every UV island are filled from the nearest island texel.

RLL4 kit textures are read as stored (RLL4 samples them that way - they
look upside down in an image viewer). The baked images are upright (the
texture y = (1 - v) * height convention) and RL26 stores its kit textures
upside down, so they are flipped when written.

Texture sizes follow the stock kits: top 4096x2048 (every stock jersey's
size; baked at 2048x1024 and upscaled), shorts 2048x2048 and socks
1024x1024 (the sizes most stock kits use), each plus a half-size _2 level.

Usage (repo root):
    python mods/rll4-legacy-kits/build_kits.py bake       # textures + previews into _build/rll4-legacy-kits
    python mods/rll4-legacy-kits/build_kits.py sheet      # one contact sheet of every preview
    python mods/rll4-legacy-kits/build_kits.py generate --clubs <stock 39957>/defaultdata/defaultdata_clubs
    python mods/rll4-legacy-kits/build_kits.py install [--replace] [--confirm]   # game closed
    python mods/rll4-legacy-kits/build_kits.py texsrc [--confirm]               # game closed
"""

import argparse
import hashlib
import json
import os
import struct
import sys

import numba
import numpy as np
from PIL import Image
from scipy import ndimage
from scipy.spatial import cKDTree

MOD = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(MOD))
sys.path.insert(0, os.path.join(REPO, "tools"))
import bigant_mesh as bm  # noqa: E402
import pack  # noqa: E402

WORK = os.path.join(REPO, "_build", "rll4-legacy-kits")
SOURCES = os.path.join(REPO, "resources", "old-jerseys")


def _source_path(kit):
    """A resources/old-jerseys kit's file: the lossless .png next to the .dds
    when there is one (the PNGs are what git keeps, ~17x smaller), else the
    "src" file as named."""
    path = os.path.join(SOURCES, kit["src"])
    png = os.path.splitext(path)[0] + ".png"
    return png if os.path.exists(png) else path
# kits painted in RL26's own layout (tools/jersey_template.py): <name>/top.png, shorts.png, socks.png
CUSTOM = os.path.join(REPO, "resources", "custom-kits")
MANIFEST = os.path.join(MOD, "kits.json")
CACHE = os.path.join(WORK, "correspondence.npz")

# part: (RL26 models, bake size W x H, RLL4 part id, final _1 size). The
# models are the ones the template items below resolve to for a male player.
SOCKS = [f"socks01_{t}{h}_{s}" for t in ("long", "short") for h in ("", "_down") for s in ("Male", "Female")]
PARTS = {
    "top": (["top_round05_short_Male"], (2048, 1024), 0, (4096, 2048)),
    "shorts": (["shorts01_Male"], (1024, 1024), 1, (2048, 2048)),
    "socks": (SOCKS, (1024, 1024), 2, (1024, 1024)),
}
PREVIEW_MODELS = (("top", "top_round05_short_Male"), ("shorts", "shorts01_Male"), ("socks", "socks01_long_Male"))
TEXTURE_PREFIX = {"top": "m_top_", "shorts": "m_shorts_", "socks": "m_socks_"}
# Templates for the new design items: the Broncos' 2026 home kit items, which
# use the models in PARTS (top_round05, shorts01, socks01).
TEMPLATE_GUID = {"uniformTop": 105, "uniformBottom": 104, "uniformSocks": 104}
REF_COLOURS = {"Blue": (20, 70, 190), "Yellow": (240, 210, 20), "Orange": (235, 120, 20),
               "Red": (200, 20, 30), "Green": (10, 140, 60), "White": (235, 235, 235)}


# --------------------------------------------------------------------------
# geometry


@numba.njit(cache=True)
def _raster(px, attr, tris, W, H, out, mask, depth, use_depth):
    """Rasterise triangles at pixel coords px, interpolating attr into out.
    Without depth the first triangle to cover a pixel wins; with it the
    largest depth does."""
    K = attr.shape[1]
    for t in range(tris.shape[0]):
        a, b, c = tris[t, 0], tris[t, 1], tris[t, 2]
        ax, ay, bx, by, cx, cy = px[a, 0], px[a, 1], px[b, 0], px[b, 1], px[c, 0], px[c, 1]
        den = (by - cy) * (ax - cx) + (cx - bx) * (ay - cy)
        if abs(den) < 1e-12:
            continue
        x0 = max(int(np.floor(min(ax, bx, cx))) - 1, 0)
        x1 = min(int(np.ceil(max(ax, bx, cx))) + 1, W - 1)
        y0 = max(int(np.floor(min(ay, by, cy))) - 1, 0)
        y1 = min(int(np.ceil(max(ay, by, cy))) + 1, H - 1)
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                if mask[y, x] and not use_depth:
                    continue
                w0 = ((by - cy) * (x + 0.5 - cx) + (cx - bx) * (y + 0.5 - cy)) / den
                w1 = ((cy - ay) * (x + 0.5 - cx) + (ax - cx) * (y + 0.5 - cy)) / den
                w2 = 1.0 - w0 - w1
                e = -0.02 if not use_depth else 0.0
                if w0 >= e and w1 >= e and w2 >= e:
                    if use_depth:
                        z = w0 * attr[a, 0] + w1 * attr[b, 0] + w2 * attr[c, 0]
                        if mask[y, x] and z <= depth[y, x]:
                            continue
                        depth[y, x] = z
                    for k in range(K):
                        out[y, x, k] = w0 * attr[a, k] + w1 * attr[b, k] + w2 * attr[c, k]
                    mask[y, x] = True


def _surface_samples(P, N, UV, tris, per_metre=63.0):
    """Dense barycentric samples over every triangle (about 1.6 cm apart at
    most, never fewer than a 2x2 grid per triangle)."""
    pts, nrm, uvs = [], [], []
    A, B, C = P[tris[:, 0]], P[tris[:, 1]], P[tris[:, 2]]
    longest = np.maximum(np.linalg.norm(B - A, axis=1), np.maximum(np.linalg.norm(C - B, axis=1), np.linalg.norm(A - C, axis=1)))
    for t, edge in zip(tris, longest):
        n = int(np.clip(edge * per_metre * 10, 2, 40))
        s = np.linspace(0, 1, n + 1)
        u, v = np.meshgrid(s, s)
        keep = (u + v) <= 1 + 1e-9
        u, v = u[keep][:, None], v[keep][:, None]
        w = 1 - u - v
        a, b, c = t
        pts.append(w * P[a] + u * P[b] + v * P[c])
        nrm.append(w * N[a] + u * N[b] + v * N[c])
        uvs.append(w * UV[a] + u * UV[b] + v * UV[c])
    nrm = np.concatenate(nrm)
    nrm /= np.linalg.norm(nrm, axis=1, keepdims=True) + 1e-9
    return np.concatenate(pts), nrm, np.concatenate(uvs)


class _Lookup:
    def __init__(self, pts, nrm, uv):
        self.tree, self.nrm, self.uv = cKDTree(pts), nrm, uv

    def __call__(self, q, qn, k=32, mindot=0.5):
        """UV of the nearest sample whose normal faces the same way as qn."""
        _, idx = self.tree.query(q, k=k, workers=-1)
        ok = np.einsum("qkc,qc->qk", self.nrm[idx], qn) > mindot
        first = np.where(ok.any(1), ok.argmax(1), 0)
        return self.uv[idx[np.arange(len(q)), first]]


def _rll4_parts(UV, tris):
    """RLL4's kit texture: shirt = the big cross-shaped island, shorts = the
    top/bottom right blocks, socks = the right middle block."""
    c = UV[tris].mean(1)
    um, v = c[:, 0] % 1, c[:, 1]
    return np.where((um >= 0.72) & (v > 0.22) & (v < 0.77), 2,
                    np.where((um >= 0.57) & ((v <= 0.22) | (v >= 0.77)), 1, 0))


def _arm(P, side):
    """Pivot + direction of one arm, and how far the mesh reaches along it."""
    pivot = np.array([0.16 * side, 1.45, 0.0])
    tip = P[(P[:, 0] * side) > 0.95 * np.abs(P[:, 0]).max()].mean(0)
    d = tip - pivot
    d[2] = 0
    d /= np.linalg.norm(d)
    reach = ((P[(P[:, 0] * side) > 0.16] - pivot) @ d).max()
    return pivot, d, reach


def build_correspondence():
    print("reading meshes ...")
    P4, N4, I4, UV4 = bm.load_rll4()
    part4 = _rll4_parts(UV4, I4)
    lookups = {}
    for k in range(3):
        lookups[k] = _Lookup(*_surface_samples(P4, N4, UV4, I4[part4 == k]))
    # shirt without the cuff fold (u at the ends of the cross arms)
    pts, nrm, uv = _surface_samples(P4, N4, UV4, I4[part4 == 0])
    su = uv[:, 0] % 1
    fold = ((su < 0.05) | (su > 0.65)) & (uv[:, 1] > 0.28) & (uv[:, 1] < 0.75)
    lookups["body"] = _Lookup(pts[~fold], nrm[~fold], uv[~fold])
    shirt4 = P4[np.unique(I4[part4 == 0])]

    out = {}
    for part, (meshes, (W, H), k, _final) in PARTS.items():
        print(f"mapping {part} ...")
        attr = np.zeros((H, W, 6))
        mask = np.zeros((H, W), bool)
        depth = np.zeros((H, W))
        top_mesh = None
        for name in meshes:
            P, N, I, UV = bm.load_rl26(part, name)
            top_mesh = P if part == "top" else None
            # texture x = (u mod 1) * W, y = (1 - v) * H (bigant_mesh docstring);
            # draw at u and u - 1 so islands past u = 1 wrap without splitting triangles
            for shift in (0, -1):
                _raster(np.c_[(UV[:, 0] + shift) * W, (1 - UV[:, 1]) * H], np.c_[P, N], I, W, H, attr, mask, depth, False)
        q = attr[mask][:, :3]
        qn = attr[mask][:, 3:]
        qn /= np.linalg.norm(qn, axis=1, keepdims=True) + 1e-9
        uv = lookups[k](q, qn)
        if part == "top":
            body = np.ones(len(q), bool)
            shifted = q.copy()
            for side in (1, -1):
                pivot, d, reach = _arm(top_mesh, side)
                _, _, reach4 = _arm(shirt4, side)
                hem = ((q[:, 0] * side) > 0.16) & (((q - pivot) @ d) >= reach - 0.02)
                body &= ~hem
                shifted[hem] -= d * (reach - reach4)
            uv[body] = lookups["body"](q[body], qn[body])
            uv[~body] = lookups[0](shifted[~body], qn[~body])
            # where the back number sits (the models face -z)
            out["top_number"] = ((qn[:, 2] > 0.6) & (np.abs(q[:, 0]) < 0.09) & (q[:, 1] > 1.18) & (q[:, 1] < 1.40))
        _, fill = ndimage.distance_transform_edt(~mask, return_indices=True)
        out[f"{part}_mask"] = mask
        out[f"{part}_uv"] = uv.astype(np.float32)
        out[f"{part}_fill"] = (fill[0] * W + fill[1]).astype(np.int32)
    # RL26 meshes for previews
    for part, name in PREVIEW_MODELS:
        P, N, I, UV = bm.load_rl26(part, name)
        out[f"mesh_{name}_P"], out[f"mesh_{name}_I"], out[f"mesh_{name}_UV"] = P, I, UV
    os.makedirs(WORK, exist_ok=True)
    np.savez_compressed(CACHE, **out)
    print(f"wrote {CACHE}")


def load_correspondence():
    if not os.path.exists(CACHE):
        build_correspondence()
    return dict(np.load(CACHE))


# --------------------------------------------------------------------------
# baking


def _bilinear(img, x, y):
    H, W = img.shape[:2]
    x = np.clip(x - 0.5, 0, W - 1.001)
    y = np.clip(y - 0.5, 0, H - 1.001)
    x0, y0 = x.astype(int), y.astype(int)
    fx, fy = (x - x0)[:, None], (y - y0)[:, None]
    return (img[y0, x0] * (1 - fx) * (1 - fy) + img[y0, x0 + 1] * fx * (1 - fy)
            + img[y0 + 1, x0] * (1 - fx) * fy + img[y0 + 1, x0 + 1] * fx * fy)


_RLL4 = None


def source_image(kit, rll4_dir=None):
    """A kit's RLL4-layout texture, as stored: a file in resources/old-jerseys
    ("src") or a texture read from the installed RLL4 ("rll4")."""
    global _RLL4
    if "rll4" not in kit:
        return Image.open(_source_path(kit))
    if _RLL4 is None:
        import rll4_source
        _RLL4 = rll4_source.RLL4(rll4_dir)
    return _RLL4.texture(f"characters/uniforms/textures/{kit['rll4']}")


def bake_kit(src_img, corr):
    """-> {part: PIL image at final _1 size, upright}, stats."""
    src = np.asarray(src_img.convert("RGB"), dtype=np.float32)
    SH, SW = src.shape[:2]
    images, stats = {}, {}
    for part, (_meshes, (W, H), _k, final) in PARTS.items():
        mask, uv, fill = corr[f"{part}_mask"], corr[f"{part}_uv"], corr[f"{part}_fill"]
        colours = _bilinear(src, (uv[:, 0] % 1) * SW, np.clip(uv[:, 1], 0, 1) * SH)
        flat = np.zeros((H * W, 3), np.float32)
        flat[mask.ravel()] = colours
        img = flat[fill.ravel()].reshape(H, W, 3)
        im = Image.fromarray(img.clip(0, 255).astype(np.uint8))
        if im.size != final:
            im = im.resize(final, Image.LANCZOS)
        images[part] = im
        if part == "top":
            back = colours[corr["top_number"]]
            stats["number_area_rgb"] = [int(c) for c in np.median(back, 0)]
            dist = {n: np.linalg.norm(colours - np.array(rgb), axis=1) for n, rgb in REF_COLOURS.items()}
            stats["clash"] = [n for n, d in dist.items() if (d < 70).mean() > 0.12]
    return images, stats


def _custom_source(kit):
    return os.path.join(CUSTOM, kit["custom"])


def bake_custom(kit):
    """A kit painted on the jersey templates: already in RL26's layouts, so
    the bake is only a resize to the installed sizes, plus the same stats as
    bake_kit from the RL26 top mesh."""
    import jersey_template as jt
    images = jt.load_kit(_custom_source(kit))
    top = jt.Mesh("top")
    src = np.asarray(images["top"], np.float32)
    H, W = src.shape[:2]

    def sample(tris):
        c = top.px[tris].mean(1)
        return src[c[:, 1].astype(int).clip(0, H - 1), c[:, 0].astype(int).clip(0, W - 1)]
    x, y = top.centre[:, 0], top.centre[:, 1]
    number = ~top.inside & (top.normal[:, 2] < -0.6) & (np.abs(x) < 0.09) & (y > 1.18) & (y < 1.40)  # back faces -z
    colours = src[np.asarray(top.mask(~top.inside)) > 0]
    dist = {n: np.linalg.norm(colours - np.array(rgb), axis=1) for n, rgb in REF_COLOURS.items()}
    stats = {"number_area_rgb": [int(c) for c in np.median(sample(number), 0)],
             "clash": [n for n, d in dist.items() if (d < 70).mean() > 0.12]}
    return images, stats


def _preview(images, corr, size=260):
    """Front / back / side renders of the baked kit on the RL26 meshes."""
    rows = []
    for part, name in PREVIEW_MODELS:
        P, I, UV = corr[f"mesh_{name}_P"], corr[f"mesh_{name}_I"], corr[f"mesh_{name}_UV"]
        tex = np.asarray(images[part])
        th, tw = tex.shape[:2]
        tiles = []
        for view in ("front", "back", "side"):
            x, y, z = P[:, 0], P[:, 1], P[:, 2]
            if view == "front":  # the models face -z
                x, z = -x, -z
            elif view == "side":
                x, z = z, -x
            span = max(np.ptp(P[:, 0]), np.ptp(P[:, 1]), np.ptp(P[:, 2]))
            sc = (size - 10) / span
            px = np.c_[(x - (x.min() + x.max()) / 2) * sc + size / 2, (y.max() - y) * sc + 5]
            out = np.zeros((size, size, 3))
            mask = np.zeros((size, size), bool)
            _raster(px, np.c_[z, UV[:, 0], 1 - UV[:, 1]], I, size, size, out, mask, np.zeros((size, size)), True)
            img = np.full((size, size, 3), 40, np.uint8)
            tu = ((out[..., 1][mask] % 1) * tw).astype(int).clip(0, tw - 1)
            tv = (out[..., 2][mask] * th).astype(int).clip(0, th - 1)
            img[mask] = tex[tv, tu]
            tiles.append(img)
        rows.append(np.concatenate(tiles, 1))
    return Image.fromarray(np.concatenate(rows, 0))


def active_kits(manifest=None):
    """The kits this machine builds: every resources/old-jerseys kit, plus the
    rows read from Rugby League Live 4 only when the installer enabled RLL4
    and it is installed (tools/games.py, revamp_install.json). A resources
    kit whose source image is missing (and was never baked here) is left out
    with a warning rather than failing the whole install."""
    import games
    kits = (manifest or load_manifest())["kits"]
    rll4 = games.enabled("rll4")
    out = []
    for k in kits:
        if "rll4" in k:
            if rll4:
                out.append(k)
        elif "custom" in k:
            if os.path.isdir(_custom_source(k)) or os.path.isdir(os.path.join(WORK, k["texture"])):
                out.append(k)
            elif k["texture"] not in _warned:
                _warned.add(k["texture"])
                print(f"  warning: skipping {k['texture']} - resources/custom-kits/{k['custom']} is missing")
        elif os.path.exists(_source_path(k)) or os.path.isdir(os.path.join(WORK, k["texture"])):
            out.append(k)
        elif k["texture"] not in _warned:
            _warned.add(k["texture"])
            print(f"  warning: skipping {k['texture']} - resources/old-jerseys/{k['src']} is missing")
    return out


_warned = set()


def load_manifest():
    with open(MANIFEST) as f:
        return json.load(f)


# Bump to re-bake every kit after changing how bakes are made (bake_kit,
# bake_custom, the correspondence); `bake --force` does the same once.
BAKE_VERSION = 1


def _bake_key(kit):
    """What a kit's bake depends on: its source image and the kits.json fields
    that pick it (not name/club/guid, which only the later steps use)."""
    h = hashlib.sha1(f"v{BAKE_VERSION}".encode())
    h.update(json.dumps({k: v for k, v in kit.items() if k not in ("name", "club", "guid")},
                        sort_keys=True).encode())
    if "custom" in kit:
        for part in PARTS:
            path = os.path.join(_custom_source(kit), f"{part}.png")
            h.update(open(path, "rb").read() if os.path.exists(path) else b"-")
    elif "src" in kit:
        src = _source_path(kit)
        h.update(open(src, "rb").read() if os.path.exists(src) else b"-")
    return h.hexdigest()  # "rll4" rows: the texture name is enough, RLL4 doesn't change


def _bake_current(kit, stats):
    out = os.path.join(WORK, kit["texture"])
    try:
        stamp = json.load(open(os.path.join(out, "bake.json")))
    except (OSError, ValueError):
        return False
    return (stamp.get("key") == _bake_key(kit) and kit["texture"] in stats
            and all(os.path.exists(os.path.join(out, f"{part}.png")) for part in PARTS))


def cmd_bake(args):
    import jersey_template as jt
    corr = None  # the RLL4 texel map, only loaded when an RLL4-layout kit is baked
    stats = {}
    path = os.path.join(WORK, "stats.json")
    old = json.load(open(path)) if os.path.exists(path) else {}
    skipped = 0
    for kit in active_kits():
        if args.only and kit["texture"] not in args.only:
            continue
        missing = (not os.path.isdir(_custom_source(kit)) if "custom" in kit
                   else "rll4" not in kit and not os.path.exists(_source_path(kit)))
        if missing:
            print(f"  {kit['texture']}: source missing, keeping the earlier bake")  # see active_kits()
            continue
        if not args.force and _bake_current(kit, old):
            skipped += 1
            continue
        if "custom" in kit:
            images, st = bake_custom(kit)
            preview = jt.render(images)
        else:
            corr = corr or load_correspondence()
            images, st = bake_kit(source_image(kit, args.rll4), corr)
            preview = _preview(images, corr)
        out = os.path.join(WORK, kit["texture"])
        os.makedirs(out, exist_ok=True)
        for part, im in images.items():
            im.save(os.path.join(out, f"{part}.png"))
        preview.save(os.path.join(out, "preview.png"))
        with open(os.path.join(out, "bake.json"), "w") as f:
            json.dump({"key": _bake_key(kit)}, f)
        stats[kit["texture"]] = st
        print(f"  {kit['texture']}: number area {st['number_area_rgb']}, referee clash {st['clash']}")
    if skipped:
        print(f"  {skipped} kits already baked (unchanged; --force re-bakes them)")
    old.update(stats)
    with open(path, "w") as f:
        json.dump(old, f, indent=1)


def cmd_add_rll4(args):
    """Append a kits.json row for every kit in the installed RLL4 that
    rll4_game_kits.json maps to an RL26 club (rows already there are kept)."""
    import rll4_source
    spec = json.load(open(os.path.join(MOD, "rll4_game_kits.json")))
    game = rll4_source.RLL4(args.rll4)
    manifest = load_manifest()
    have = {k.get("rll4") for k in manifest["kits"]}
    guid = max(k["guid"] for k in manifest["kits"] if "custom" not in k) + 1  # custom kits use 64001+ (61001-61109: team-coaches polos)
    prefixes = sorted(spec["clubs"], key=len, reverse=True)
    added = skipped = 0
    folder = "characters/uniforms/textures/"
    for path in sorted(game.cat["textures"]):
        if not (path.startswith(folder) and path.endswith("_col")):
            continue
        name = path[len(folder):]
        stem = name[:-len("_col")]
        prefix = next((p for p in prefixes if stem == p or stem.startswith(p + "_")), None)
        kit = stem[len(prefix) + 1:] if prefix else None
        if prefix is None or kit not in spec["kits"]:
            skipped += 1
            continue
        if name in have:
            continue
        label = spec["rep_names"].get(prefix, spec["kits"][kit])
        league = prefix.split("_")[0]
        if league in spec["labels"]:
            label = f"{spec['labels'][league]} {label}"
        kit_name = f"{label} {spec['season']}"
        assert len(kit_name) <= 24, kit_name
        manifest["kits"].append({"guid": guid, "rll4": name, "club": spec["clubs"][prefix], "name": kit_name,
                                 "texture": f"{stem}_rll4_{spec['season']}"})
        print(f"  {guid}  {name:<44} -> club {spec['clubs'][prefix]:>3}  {kit_name}")
        guid += 1
        added += 1
    print(f"{added} kits added, {skipped} RLL4 kit textures not mapped")
    if added:
        with open(MANIFEST, "w") as f:
            json.dump(manifest, f, indent=1)
            f.write("\n")


def cmd_sheet(args):
    from PIL import ImageDraw
    kits = active_kits()
    tiles = []
    for kit in kits:
        im = Image.open(os.path.join(WORK, kit["texture"], "preview.png"))
        im = im.resize((im.width // 2, im.height // 2))
        ImageDraw.Draw(im).text((4, 2), f"{kit['texture']}", fill=(255, 255, 0))
        tiles.append(im)
    cols = args.cols
    w, h = tiles[0].size
    sheet = Image.new("RGB", (w * cols, h * ((len(tiles) + cols - 1) // cols)), (20, 20, 20))
    for i, t in enumerate(tiles):
        sheet.paste(t, ((i % cols) * w, (i // cols) * h))
    sheet.save(args.out)
    print(f"wrote {args.out}")


# --------------------------------------------------------------------------
# game data


def _club_kits(clubs_path):
    """{club id: {kit name: (r, g, b) number colour}} from a stock defaultdata_clubs."""
    import data_mods as dm
    import parse_club_jersey as pcj
    import parse_clubs as pc
    data = open(clubs_path, "rb").read()
    anchors = pc.find_anchors(data)
    starts = sorted(a[0] for a in anchors)
    out = {}
    for start, end, cid, *names in anchors:
        bound = next((s for s in starts if s > start), len(data))
        lay = dm._uniform_layout(data, end, bound)
        if not lay:
            continue
        name_f = lay["record_fields"][pcj.fnv1a32("name")]
        kits = {}
        for i in range(struct.unpack_from("<H", data, lay["count_pos"])[0]):
            r = lay["records_pos"] + i * lay["record_size"]
            name = data[r + name_f[0]:r + name_f[0] + name_f[2]].split(b"\0")[0].decode("latin1")
            rgb = []
            for ch in "rgb":
                f = lay["config_fields"][pcj.fnv1a32(f"numberColour1_{ch}")]
                rgb.append(struct.unpack_from(dm.UNIFORM_TAG_FMT[f[1]], data, r + lay["config_off"] + f[0])[0])
            kits[name] = tuple(rgb)
        out[cid] = (names[0], kits)
    return out


def _luma(rgb):
    return 0.299 * rgb[0] + 0.587 * rgb[1] + 0.114 * rgb[2]


LUA_HEADER = """
-- rll4-legacy-kits: design items for the kits converted from Rugby League
-- Live 4 textures (generated by mods/rll4-legacy-kits/build_kits.py from
-- kits.json - edit those, not this block). assetmap imports this file right
-- after assetmapitems, so the items land before the native asset map reads
-- ItemMaps. Each item copies a stock template (same model) with a new guid
-- and colTexture, and is added to the guid lookup and the _col list that
-- assetmapitems builds before this runs.
do
\tlocal ItemMaps = import("design.characters.assetmapitems").ItemMaps

\tlocal function addItem(mapName, templateGuid, guid, colTexture, overrides)
\t\tlocal map = ItemMaps[mapName]
\t\tlocal lookup = map.item_setup_lookup
\t\tlocal template = lookup[templateGuid]

\t\tif template == nil or lookup[guid] ~= nil then
\t\t\treturn
\t\tend

\t\tif template.colTexture == nil then
\t\t\t-- an Academy design (captured kits): its material is made for the
\t\t\t-- tinted Academy layers and turns a full-colour texture near-black
\t\t\t-- (WCC 2026 on top_soft02, 2026-10-29), so copy a licensed item on
\t\t\t-- the same model and sex instead when there is one
\t\t\tfor _, candidate in ipairs(map.item_setup) do
\t\t\t\tif candidate.colTexture ~= nil and candidate.name == template.name and candidate.sex == template.sex then
\t\t\t\t\ttemplate = candidate

\t\t\t\t\tbreak
\t\t\t\tend
\t\t\tend
\t\tend

\t\tlocal item = {}

\t\tfor key, value in pairs(template) do
\t\t\titem[key] = value
\t\tend

\t\tif template.colTexture == nil then
\t\t\t-- an Academy design: the captured texture already has its collar
\t\t\t-- colours, and the copy isn't one of the Academy's choices
\t\t\titem.collarLayer = nil
\t\t\titem.academy = nil
\t\tend

\t\titem.guid = guid
\t\titem.colTexture = colTexture

\t\tfor key, value in pairs(overrides or {}) do
\t\t\titem[key] = value
\t\tend

\t\ttable.insert(map.item_setup, item)

\t\tlookup[guid] = item

\t\tlocal colMap = ItemMaps[mapName .. "_col"]

\t\tif colMap.item_setup_lookup[colTexture] == nil then
\t\t\tlocal entry = {
\t\t\t\tname = colTexture,
\t\t\t\tblend = colMap.blend
\t\t\t}

\t\t\ttable.insert(colMap.item_setup, entry)

\t\t\tcolMap.item_setup_lookup[colTexture] = entry
\t\tend
\tend

\tlocal kits = {
"""

LUA_FOOTER = """\t}

\tfor _, kit in ipairs(kits) do
\t\tlocal templates = kit[4] or {}

\t\taddItem("uniformTop", templates.top or %d, kit[1], "m_top_" .. kit[2] .. "_col", #kit[3] > 0 and {
\t\t\trefereeUniformClashColourList = kit[3]
\t\t} or nil)

\t\tif templates.number then
\t\t\t-- number/name placement from another top item (numberFrom)
\t\t\tlocal tops = ItemMaps.uniformTop.item_setup_lookup
\t\t\tlocal item, source = tops[kit[1]], tops[templates.number]

\t\t\tif item ~= nil and source ~= nil then
\t\t\t\titem.numberOffset = source.numberOffset
\t\t\t\titem.nameOffset = source.nameOffset
\t\t\tend
\t\tend

\t\taddItem("uniformBottom", templates.bottom or %d, kit[1], "m_shorts_" .. kit[2] .. "_col")
\t\taddItem("uniformSocks", templates.socks or %d, kit[1], "m_socks_" .. kit[2] .. "_col")
\tend
end
""" % (TEMPLATE_GUID["uniformTop"], TEMPLATE_GUID["uniformBottom"], TEMPLATE_GUID["uniformSocks"])


def _stock_lua(decompiled_path, generated_path, marker):
    """The stock file a generated override starts from: the decompiled copy
    when there is one (developer machines), else the stock part of the
    committed generated file - everything before its generated block - so the
    installer can regenerate on a player's machine, which has no decompiled/."""
    if os.path.exists(decompiled_path):
        return open(decompiled_path, encoding="utf-8-sig").read().rstrip("\n")
    text = open(generated_path, encoding="utf-8-sig").read()
    if marker not in text:
        raise SystemExit(f"{generated_path} has no generated block ({marker!r}) to regenerate from")
    return text[:text.index(marker)].rstrip("\n")


def cmd_generate(args):
    manifest = load_manifest()
    stats = json.load(open(os.path.join(WORK, "stats.json")))
    clubs = _club_kits(args.clubs)

    # Lua: stock jigglyjointsconfig + the registration block
    lua_path = os.path.join(MOD, "src", "script-game", "intermediatelua", "data", "jigglyjointsconfig.lua")
    stock = _stock_lua(os.path.join(REPO, "decompiled", "src", "script-game", "intermediatelua", "data",
                                    "jigglyjointsconfig.lua"), lua_path, LUA_HEADER.strip().splitlines()[0])
    rows = []
    for kit in active_kits(manifest):
        clash = ", ".join(f'"{c}"' for c in stats[kit["texture"]]["clash"])
        # "templates": the design items to copy (model and UVs) for a kit captured
        # from another design (tools/fanhub_kit_import.py); TEMPLATE_GUID otherwise
        tpl = kit.get("templates", {})
        tpl = ", ".join(f"{key} = {tpl[m]}" for key, m in (("top", "uniformTop"), ("bottom", "uniformBottom"),
                                                          ("socks", "uniformSocks")) if m in tpl)
        # "numberFrom": a top item whose number/name placement the kit uses
        # instead of its template's (e.g. a club kit on England's top_flat01
        # keeping the club's number layout)
        if "numberFrom" in kit:
            tpl = (tpl + ", " if tpl else "") + f"number = {kit['numberFrom']}"
        tpl = f", {{ {tpl} }}" if tpl else ""
        rows.append(f'\t\t{{ {kit["guid"]}, "{kit["texture"]}", {{ {clash} }}{tpl} }}, -- {kit["name"]}, club {kit["club"]}')

    # each kit's slot: copy HOME or AWAY, whichever's number colour stands out
    # more against the new kit's back where the number sits. Rows marked
    # "library" don't take one of the club's 20 kit slots (the game holds at
    # most 20 per club, inline in the club object): they go to KitLibrary,
    # which the match jersey picker offers after the club's own kits
    # (copy-academy-jerseys' KIT LIBRARY entry in a club's Uniforms list adds
    # them to the club, into a free slot or over a kit you pick)
    by_club, library = {}, {}
    for kit in active_kits(manifest):
        by_club.setdefault(kit["club"], []).append(kit)
    out_dir = os.path.join(MOD, "defaultdata", "defaultdata_clubs")
    os.makedirs(out_dir, exist_ok=True)
    for cid, kits in sorted(by_club.items()):
        # captured/painted kits first: the game shows only a club's first 20
        # kits (WCC 2026 as the Broncos' 21st didn't show, 2026-10-29), and
        # the RLL4 2017 rows are the ones to lose
        kits = sorted(kits, key=lambda k: "custom" not in k)
        club_name, existing = clubs[cid]
        adds, renames = [], {}
        for kit in kits:
            if "renameExisting" in kit:
                # the new kit takes over a stock kit's name, place and number
                # styling (e.g. the Cowboys' 2026 HOME); the stock one is kept
                # under the new name. Renames run before adds (kit_blob.apply_spec)
                renames[kit["name"]] = kit["renameExisting"]
                adds.append({"name": kit["name"], "copyOf": kit["renameExisting"],
                             "index": list(existing).index(kit["name"]),
                             "set": {"uniformTop": kit["guid"], "uniformBottom": kit["guid"],
                                     "uniformSocks": kit["guid"]}})
                continue
            back = _luma(stats[kit["texture"]]["number_area_rgb"])
            # the World Cup sides only have "HOME RLWC"
            options = [n for n in ("HOME", "AWAY") if n in existing] or list(existing)
            copy_of = max(options, key=lambda n: abs(_luma(existing[n]) - back))
            fields = {"uniformTop": kit["guid"], "uniformBottom": kit["guid"], "uniformSocks": kit["guid"]}
            if abs(_luma(existing[copy_of]) - back) < 90:
                # neither kit's numbers would stand out: white on dark, near-black on light
                rgb = (230, 230, 230) if back < 128 else (20, 20, 28)
                fields.update({f"numberColour1_{ch}": v for ch, v in zip("rgb", rgb)})
            entry = {"name": kit["name"], "copyOf": copy_of, "set": fields}
            if "index" in kit:
                entry["index"] = kit["index"]
            # RLL4 kits (installed RLL4 or resources/old-jerseys) live in the
            # library unless a row says "library": false; captured/painted
            # ("custom") kits take a club slot unless it says "library": true
            if kit.get("library", "custom" not in kit):
                library.setdefault(cid, []).append(entry)
            else:
                adds.append(entry)
        fname = f"{cid:06d}_{club_name.replace(' ', '_')}.json"
        path = os.path.join(out_dir, fname)
        if adds:
            # inserts in list order, so each lands at its index
            adds.sort(key=lambda a: a.get("index", len(existing) + len(adds)))
            spec = {"rename": renames, "add": adds} if renames else {"add": adds}
            with open(path, "w") as f:
                json.dump({"uniforms": spec}, f, indent=2)
                f.write("\n")
        elif os.path.exists(path):
            os.remove(path)
        print(f"  {fname}: {', '.join(a['name'] + ' (' + a['copyOf'] + ')' for a in adds) or '-'}"
              + (f"; library: {', '.join(e['name'] for e in library[cid])}" if cid in library else ""))

    lua = stock + "\n" + LUA_HEADER + "\n".join(rows) + "\n" + LUA_FOOTER + _library_lua(library)
    os.makedirs(os.path.dirname(lua_path), exist_ok=True)
    with open(lua_path, "w", encoding="ascii", newline="\n") as f:
        f.write(lua)
    print(f"wrote {os.path.relpath(lua_path, REPO)} ({sum(map(len, library.values()))} library kits)")


def _library_lua(library):
    """KitLibrary = { [club id] = { { name, copyOf, set = { option = value } } } }:
    read by copy-academy-jerseys' academy_club_jersey_state.lua through
    import("intermediatelua.data.jigglyjointsconfig").KitLibrary."""
    out = ["", "-- rll4-legacy-kits: kits kept out of the clubs' 20 kit slots (\"library\" rows in",
           "-- kits.json). KIT LIBRARY in a club's Uniforms list adds one to the club: a copy of the",
           "-- club's copyOf kit with the set options (design guids, number colour).",
           "KitLibrary = {"]
    for cid, entries in sorted(library.items()):
        out.append(f"\t[{cid}] = {{")
        for e in entries:
            sets = ", ".join(f"{k} = {v}" for k, v in e["set"].items())
            out.append(f'\t\t{{ name = "{e["name"]}", copyOf = "{e["copyOf"]}", set = {{ {sets} }} }},')
        out.append("\t},")
    out.append("}")
    return "\n".join(out) + "\n"


def _dds_bgra(img):
    """Uncompressed 32-bit BGRA DDS, no mips, stored upside down like the
    stock kit textures."""
    w, h = img.size
    header = bytearray(128)
    struct.pack_into("<4s7I", header, 0, b"DDS ", 124, 0x1007, h, w, 0, 1, 0)
    struct.pack_into("<2I4s5I", header, 76, 32, 0x41, b"\0\0\0\0", 32, 0xFF0000, 0xFF00, 0xFF, 0xFF000000)
    struct.pack_into("<I", header, 108, 0x1000)
    rgba = img.convert("RGBA").transpose(Image.FLIP_TOP_BOTTOM)
    return bytes(header) + rgba.tobytes("raw", "BGRA")


def cmd_install(args):
    """Add (or with --replace, update) each kit's _1/_2 texture entries. An
    entry whose image hasn't changed since it was last written (sha1 kept in
    the add_entries registry as "image_sha1", entry still in the index, blob
    the recorded size) is skipped unless --force."""
    import add_entries
    import club_icons
    data, count, hash_off, _ = pack.read_index(args.blobset)
    in_index = {h: i for i, h in enumerate(add_entries.load_hashes(data, count, hash_off))}
    registry = {e["path"]: e for e in (add_entries.load_registry() or {"entries": []})["entries"]}
    written, skipped = {}, 0

    def unchanged(path, sha):
        rec = registry.get(path.lower())
        return (rec is not None and rec.get("image_sha1") == sha
                and in_index.get(add_entries.path_hash(path)) == rec["entry_index"]
                and os.path.exists(rec["blob_path"])
                and os.path.getsize(rec["blob_path"]) == rec["sizes"][0] + rec["sizes"][2])

    for kit in active_kits():
        if args.only and kit["texture"] not in args.only:
            continue
        for part in args.parts or PARTS:
            png = os.path.join(args.source or WORK, kit["texture"], f"{part}.png")
            png_sha = hashlib.sha1(open(png, "rb").read()).hexdigest()
            img = None
            for level in (1, 2):
                path = f"characters/uniforms/textures/{TEXTURE_PREFIX[part]}{kit['texture']}_col_{level}.texture"
                sha = f"{png_sha}:{level}"
                if not args.force and unchanged(path, sha):
                    skipped += 1
                    continue
                img = img or Image.open(png)
                im = img if level == 1 else img.resize((img.width // 2, img.height // 2), Image.LANCZOS)
                blob, sizes = club_icons.make_blob(path, _dds_bgra(im))
                origin = (kit["src"] if "src" in kit else f"custom {kit['custom']}" if "custom" in kit
                          else f"RLL4 {kit['rll4']}")
                add_entries.add_entry(args.blobset, path, blob, sizes, f"rll4-legacy-kits {origin}",
                                      args.confirm, replace=args.replace)
                written[path.lower()] = sha
    if skipped:
        print(f"  {skipped} texture entries unchanged, not rewritten (--force rewrites them)")
    if not args.confirm:
        print("dry run - pass --confirm to write (close the game first)")
        return
    if written:  # add_entry saved its own records; add the image hashes to them
        reg = add_entries.load_registry()
        for e in reg["entries"]:
            if e["path"] in written:
                e["image_sha1"] = written[e["path"]]
        add_entries.save_registry(reg)


TEXSRC_PATH = "characters/player/global.texsrc"


def cmd_texsrc(args):
    """Register the new textures in characters/player/global.texsrc.

    The character texture compositor only uses source textures listed in
    that table (an unlisted one composites as black). Layout: u32 count,
    then count x 8 u32 records [FNV-1a32 of the logical path without
    extension, type, x, y, w, h, texture width, texture height] - x/y/w/h is
    the used rectangle (whole image, type 0, for kit textures). Records are
    unsorted, so new ones are appended to a stock copy."""
    import add_entries
    import classify_entries as ce
    data, count, hash_off, _ = pack.read_index(args.blobset)
    entry = add_entries.find_entry(data, count, hash_off, TEXSRC_PATH)
    meta_path = pack.backup_meta_path(entry)
    if os.path.exists(meta_path):  # read the stock table from the backup
        meta = json.load(open(meta_path))
        raw = open(meta["blob_backup"], "rb").read()
        if meta["main_compressed_size"] != meta["main_uncompressed_size"]:
            raw = ce.decode_outer_zstd_frames(raw)
    else:
        ce.load_index(args.blobset)
        raw = ce.read_blob_full(args.blobset, entry)[0]
    stock_count = struct.unpack_from("<I", raw, 0)[0]
    if len(raw) != 4 + 32 * stock_count:
        raise SystemExit(f"{TEXSRC_PATH} (entry {entry}) isn't the expected record table")
    known = set(struct.unpack_from(f"<{stock_count * 8}I", raw, 4)[0::8])

    records = []
    for kit in active_kits():
        for part, (*_, (w, h)) in PARTS.items():
            for level in (1, 2):
                name = f"characters/uniforms/textures/{TEXTURE_PREFIX[part]}{kit['texture']}_col_{level}"
                lw, lh = w >> (level - 1), h >> (level - 1)
                key = _fnv1a32(name)
                if key in known:
                    raise SystemExit(f"{name} is already in {TEXSRC_PATH}")
                records.append(struct.pack("<8I", key, 0, 0, 0, lw, lh, lw, lh))
    table = struct.pack("<I", stock_count + len(records)) + raw[4:] + b"".join(records)
    out = os.path.join(WORK, "global.texsrc")
    with open(out, "wb") as f:
        f.write(table)
    print(f"{TEXSRC_PATH} (entry {entry}): {stock_count} stock + {len(records)} new records -> {out}")
    if not args.confirm:
        print("dry run - pass --confirm to install (close the game first)")
        return
    if os.path.exists(meta_path):
        pack.do_restore(args.blobset, entry)
    pack.do_install(args.blobset, entry, out, True)
    print(f"installed entry {entry} (undo: python tools/pack.py restore --entry {entry})")


def _fnv1a32(text):
    h = 0x811C9DC5
    for c in text.lower().encode("utf-8"):
        h = ((h ^ c) * 0x01000193) & 0xFFFFFFFF
    return h


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--rll4", help="Rugby League Live 4 install folder (default: found via Steam)")
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("add-rll4")
    p.set_defaults(func=cmd_add_rll4)
    p = sub.add_parser("bake")
    p.add_argument("--only", nargs="*", help="texture names from kits.json")
    p.add_argument("--remap", action="store_true", help="rebuild the cached texel correspondence")
    p.add_argument("--force", action="store_true", help="re-bake kits even when their bake is current")
    p.set_defaults(func=cmd_bake)
    p = sub.add_parser("sheet")
    p.add_argument("--out", default=os.path.join(WORK, "sheet.png"))
    p.add_argument("--cols", type=int, default=6)
    p.set_defaults(func=cmd_sheet)
    p = sub.add_parser("generate")
    p.add_argument("--clubs", required=True, help="a STOCK defaultdata/defaultdata_clubs (fresh extraction of 39957)")
    p.set_defaults(func=cmd_generate)
    p = sub.add_parser("texsrc")
    p.add_argument("--blobset", default=pack.BLOBSET_PATH)
    p.add_argument("--confirm", action="store_true")
    p.set_defaults(func=cmd_texsrc)
    p = sub.add_parser("install")
    p.add_argument("--blobset", default=pack.BLOBSET_PATH)
    p.add_argument("--replace", action="store_true", help="overwrite textures this mod added before")
    p.add_argument("--parts", nargs="*", choices=list(PARTS), help="only these parts (default all)")
    p.add_argument("--only", nargs="*", help="texture names from kits.json")
    p.add_argument("--source", help="folder of <texture>/<part>.png to install instead of the bakes (e.g. test grids)")
    p.add_argument("--force", action="store_true", help="rewrite entries even when their image is unchanged")
    p.add_argument("--confirm", action="store_true")
    p.set_defaults(func=cmd_install)
    args = ap.parse_args()
    if getattr(args, "remap", False) and os.path.exists(CACHE):
        os.remove(CACHE)
    args.func(args)


if __name__ == "__main__":
    sys.exit(main())
