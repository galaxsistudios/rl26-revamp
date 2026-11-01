#!/usr/bin/env python3
"""
kit_photo.py - wrap product photos of a real kit onto a kit texture, for the
artwork kits (Indigenous, ANZAC...) whose designs are never painted by code
(resources/custom-kits/RULES.md 16-17).

Every texel of the part's model gets its 3D position and normal (rasterised
in UV space, cached in _build/kit-studio/surface). A photo is an orthographic
front or back view of the shirt, so a texel's (x, y) on the model maps to a
spot in the photo; a thin-plate spline through matching landmarks (model
point -> photo pixel) absorbs the difference in pose (arms down in the photo,
out on the model) and the lens. Front-facing texels read the front photo,
back-facing ones the back photo, blended across the sides.

kit.json "photos": {"<part>": {"front": {"file": ..., "points": [[mx, my, px, py], ...]},
                                "back":  {...}, "blend": 0.25, "graze": 0.15,
                                "collar": <colour> | "photo", "collar_zone": true | {...}}}
(collar and collar_zone: see _layer; RULES.md 19).
Model points are (x, y) in the model's own units as seen from that side:
front = (x, y), back = (-x, y). `python tools/kit_photo.py points <kit>` draws
the model's silhouette with a grid in model units next to each photo, to read
landmarks from.

Used by design.py: kit_photo.layer(kit, "top") -> RGBA layer (transparent
where neither photo sees the texel).

`python tools/kit_photo.py prep <kit>` gets a kit's photos ready: each side's
"source" (any product shot) has its background removed (flood-filled from the
edges in the background's own colour, so grey and black studio backdrops work
too), its "erase" boxes cleared (retailer badges, gallery counters), and is
cropped and centred on a 1000x1000 transparent canvas as "file". Then its
landmarks are read off the shirt's outline (auto_points) and written to
kit.json, where they can be corrected by hand.
"""

import os
import sys

import numpy as np
from PIL import Image, ImageDraw

TOOLS = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, TOOLS)
import bigant_mesh as bm  # noqa: E402
import jersey_template as jt  # noqa: E402

REPO = os.path.dirname(TOOLS)
CACHE = os.path.join(REPO, "_build", "kit-studio", "surface")
KIND = {"top": "top", "shorts": "shorts", "socks": "socks"}


def surface(part, model, size):
    """(P, N, covered) per texel: 3D position, unit normal and a coverage mask."""
    W, H = size
    path = os.path.join(CACHE, f"{model}_{W}x{H}.npz")
    if os.path.exists(path):
        z = np.load(path)
        return z["P"], z["N"], z["covered"]
    P, N, I, UV = bm.load_rl26(KIND[part], model)
    u = UV[I, 0]
    inside = u.min(1) >= 1  # linings that reuse outside texels: the outside wins
    px = np.dstack([(u - np.floor(u.min(1, keepdims=True))) * W, (1 - UV[I, 1]) * H])
    zbuf = np.full((H, W), -np.inf)
    out = np.zeros((H, W, 6))
    for flag in (True, False):
        sel = inside == flag
        # per-triangle vertex copies so each triangle uses its own (shifted) UVs
        T = np.flatnonzero(sel)
        vpx = px[T].reshape(-1, 2)
        attr = np.c_[P[I[T]].reshape(-1, 3), N[I[T]].reshape(-1, 3)]
        depth = np.full(len(vpx), 0.0 if flag else 1.0)
        jt._raster(vpx, depth, attr, np.arange(len(vpx)).reshape(-1, 3), W, H, zbuf, out)
    covered = np.isfinite(zbuf)
    Pm = out[..., :3].astype(np.float32)
    Nm = out[..., 3:].astype(np.float32)
    Nm /= np.linalg.norm(Nm, axis=-1, keepdims=True) + 1e-9
    os.makedirs(CACHE, exist_ok=True)
    np.savez_compressed(path, P=Pm, N=Nm, covered=covered)
    return Pm, Nm, covered


def collar_mask(P, covered):
    """The texels of the collar's own UV island (the strip at the top of the
    top's texture): an island lying wholly around the neck."""
    from scipy import ndimage
    lab, n = ndimage.label(covered)
    out = np.zeros(covered.shape, bool)
    for i in range(1, n + 1):
        isl = lab == i
        if isl.sum() > 200 and np.percentile(P[..., 1][isl], 2) > 1.43:
            out |= isl
    return out


def view_xy(P, side):
    return np.dstack([P[..., 0] if side == "front" else -P[..., 0], P[..., 1]])


def visible(P, covered, side, cells=600, eps=0.02):
    """Texels the camera sees from that side (not behind an arm or the body):
    a depth buffer splatted from the texels themselves."""
    xy = view_xy(P, side)
    depth = P[..., 2] if side == "front" else -P[..., 2]
    pts, d = xy[covered], depth[covered]
    lo, hi = pts.min(0), pts.max(0)
    sc = (cells - 1) / (hi - lo).max()
    ij = ((pts - lo) * sc).astype(int)
    zb = np.full((cells, cells), -np.inf, np.float32)
    np.maximum.at(zb, (ij[:, 1], ij[:, 0]), d)
    out = np.zeros(covered.shape, np.float32)
    out[covered] = d >= zb[ij[:, 1], ij[:, 0]] - eps
    return out


def warp(points):
    """Thin-plate spline: model (x, y) -> photo (px, py)."""
    from scipy.interpolate import RBFInterpolator
    pts = np.asarray(points, np.float64)
    return RBFInterpolator(pts[:, :2], pts[:, 2:], kernel="thin_plate_spline", smoothing=0.0)


def sample(photo, xy):
    """Bilinear RGBA samples of photo at pixel coords xy (n, 2); alpha 0 outside."""
    a = np.asarray(photo.convert("RGBA"), np.float32)
    h, w = a.shape[:2]
    x, y = xy[:, 0] - 0.5, xy[:, 1] - 0.5
    x0, y0 = np.floor(x).astype(int), np.floor(y).astype(int)
    fx, fy = (x - x0)[:, None], (y - y0)[:, None]
    ok = (x0 >= 0) & (y0 >= 0) & (x0 < w - 1) & (y0 < h - 1)
    x0, y0 = x0.clip(0, w - 2), y0.clip(0, h - 2)
    a[..., :3] *= a[..., 3:] / 255  # premultiplied, so the background never bleeds in
    c = (a[y0, x0] * (1 - fx) * (1 - fy) + a[y0, x0 + 1] * fx * (1 - fy)
         + a[y0 + 1, x0] * (1 - fx) * fy + a[y0 + 1, x0 + 1] * fx * fy)
    c[~ok] = 0
    c[:, :3] /= np.maximum(c[:, 3:], 1e-3) / 255
    return c


def layer(kit, part):
    """The photos wrapped onto the part's texture, as an RGBA array (cached on the kit)."""
    cache = kit.__dict__.setdefault("_photo_layers", {})
    if part not in cache:
        cache[part] = _layer(kit, part)
    return cache[part]


def fill_holes(rgb, known, covered):
    """Colours for the covered texels no photo saw (side seams, under the arms,
    the outer sleeve), filled smoothly from the seen colours around them
    (pull-push: averaged down a pyramid, then blended back up), within each
    UV island so one piece of the shirt never bleeds into another."""
    from scipy import ndimage
    out = rgb.astype(np.float32).copy()
    lab, n = ndimage.label(covered)
    for sl, i in zip(ndimage.find_objects(lab), range(1, n + 1)):
        isl = lab[sl] == i
        k = known[sl] & isl
        if not k.any() or k[isl].all():
            continue
        c = out[sl] * k[..., None]
        out[sl][isl & ~k] = _pull_push(c, k.astype(np.float32))[isl & ~k]
    return out


def _pull_push(c, w):
    h, wd = w.shape
    if min(h, wd) <= 2 or w.min() > 0:
        return c / np.maximum(w, 1e-6)[..., None]
    ph, pw = h + h % 2, wd + wd % 2
    cp = np.zeros((ph, pw, 3), np.float32)
    wp = np.zeros((ph, pw), np.float32)
    cp[:h, :wd], wp[:h, :wd] = c, w
    cs = cp.reshape(ph // 2, 2, pw // 2, 2, 3).sum((1, 3))
    ws = wp.reshape(ph // 2, 2, pw // 2, 2).sum((1, 3))
    norm = np.minimum(ws, 1)  # a coarse texel counts as known once any of its 4 are
    coarse = _pull_push(cs / np.maximum(ws, 1e-6)[..., None] * norm[..., None], norm)
    up = np.repeat(np.repeat(coarse, 2, 0), 2, 1)[:h, :wd]
    up = ndimage_smooth(up)
    a = np.minimum(w, 1)[..., None]
    return c / np.maximum(w, 1e-6)[..., None] * a + up * (1 - a)


def ndimage_smooth(a):
    from scipy import ndimage
    return ndimage.uniform_filter(a, size=(3, 3, 1), mode="nearest")


def _layer(kit, part):
    spec = kit.cfg["photos"][part]
    W, H = kit.size(part)
    P, N, covered = surface(part, kit.model(part), (W, H))
    blend = spec.get("blend", 0.25)
    # texels a photo sees nearly edge-on (|normal z| under graze) take no colour
    # from it: they'd stretch the photo's last few pixels across the side
    graze = spec.get("graze", 0.15)
    acc = np.zeros((H, W, 4), np.float32)
    wsum = np.zeros((H, W), np.float32)
    for side, sign in (("front", 1), ("back", -1)):
        if side not in spec:
            continue
        s = spec[side]
        photo = Image.open(kit.file(s["file"])).convert("RGBA")
        if s.get("white_is_background", True):
            photo = knock_out_white(photo)
        # and not the outline's last few pixels: the studio's light halo
        from scipy import ndimage
        a = np.array(photo)
        a[..., 3] = np.where(ndimage.binary_erosion(a[..., 3] > 0, iterations=s.get("halo", 3)), a[..., 3], 0)
        photo = Image.fromarray(a, "RGBA")
        nz = N[..., 2] * sign
        wgt = np.clip((nz + blend) / (2 * blend), 0, 1) * (np.abs(N[..., 2]) >= graze)
        wgt = wgt * covered * visible(P, covered, side)
        sel = wgt > 0
        xy = view_xy(P, side)[sel]
        c = sample(photo, warp(s["points"])(xy))
        # only solid shirt: the photo's antialiased rim (half-transparent, with
        # unpremultiplied colours gone wild) would smear junk along the seams
        wgt_sel = wgt[sel] * (c[:, 3] >= 250)
        acc[sel] += c * wgt_sel[:, None]
        wsum[sel] += wgt_sel
    out = np.zeros((H, W, 4), np.uint8)
    ok = wsum > 1e-4
    rgb = np.zeros((H, W, 3), np.float32)
    rgb[ok] = acc[ok, :3] / wsum[ok, None]
    # the collar is one flat colour (RULES.md 19): a front photo shows the inside
    # of the back (and its label) where the model's collar is. "collar": a
    # kit colour or [r, g, b]; default the median of what the back photo
    # shows on the collar; "photo" keeps the wrap
    collar = collar_mask(P, covered)
    cz = spec.get("collar_zone")
    if cz:  # a polo collar lying on the shirt in the photos (and its placket): the
        # model has its own collar (RULES.md 19), so the shirt there is filled
        # in from the artwork around it
        cz = cz if isinstance(cz, dict) else {}
        below = np.where(N[..., 2] > 0, cz.get("below", 1.41), cz.get("back_below", 1.50))  # the back: just the neck
        ok &= ~((P[..., 1] > below) & (np.abs(P[..., 0]) < cz.get("half_width", 0.14)) & ~collar)
    if collar.any() and spec.get("collar") != "photo":
        if spec.get("collar"):
            c = kit.colour(spec["collar"])
        else:
            # the back photo's collar, near the body: above it a back shot shows the
            # inside of the front collar
            low = P[..., 1] < np.percentile(P[..., 1][collar], 30)
            seen = collar & ok & (N[..., 2] < -0.3) & low
            c = np.median(rgb[seen], 0) if seen.any() else np.median(rgb[collar & ok], 0)
        rgb[collar] = c
        ok |= collar
    out[..., :3] = fill_holes(rgb, ok, covered).clip(0, 255)
    out[~covered, :3] = 0
    out[covered, 3] = 255
    return out


def mirror_index(part, model, size, axis=0):
    """For each covered texel, the flat index of the texel at the mirrored
    3D point on the same model (cached): axis 0 = (-x, y, z), left <-> right;
    axis 2 = (x, y, -z), front <-> back."""
    W, H = size
    path = os.path.join(CACHE, f"{model}_{W}x{H}_mirror{'' if axis == 0 else axis}.npy")
    if os.path.exists(path):
        return np.load(path)
    from scipy.spatial import cKDTree
    P, N, covered = surface(part, model, size)
    if axis == 2:  # front -> back: the back-facing texel at the same (x, y)
        out = np.arange(W * H)
        nz = N[..., 2].ravel()
        src = np.flatnonzero(covered.ravel() & (nz > 0))
        dst = np.flatnonzero(covered.ravel() & (nz < 0))
        xy = P.reshape(-1, 3)[:, :2]
        _, j = cKDTree(xy[dst]).query(xy[src], workers=-1)
        out[src] = dst[j]
        np.save(path, out)
        return out
    idx = np.flatnonzero(covered.ravel())
    pts = np.c_[P.reshape(-1, 3)[idx], N.reshape(-1, 3)[idx] * 0.02]  # normals keep the inside/outside apart
    q = pts.copy()
    q[:, axis] *= -1
    q[:, 3 + axis] *= -1
    _, j = cKDTree(pts).query(q, workers=-1)
    out = np.arange(W * H)
    out[idx] = idx[j]
    np.save(path, out)
    return out


def flat(kit, part, colours, smooth=2.5, ignore=None, symmetric=False, source=None, off_palette=70,
         level=None, front_from_back=False, fill=None):
    """A code-painted design measured from the photos: every texel of the
    wrapped photos (or `source`, an RGBA array) is given the nearest kit
    colour (names from kit.json colours), the colour regions are smoothed
    (sigma `smooth` texels at 1024 high, scaled) so edges come out clean, and
    texels under `ignore` (a bool mask: the sponsors, which are their own
    layers) and photo texels more than `off_palette` from every kit colour
    (the photo's logos) take the colour around them. symmetric: average each side with
    its mirror (a design that is the same left and right). level: (half
    width, y range) in model units - on the torso within that half width,
    each texel takes the colours found at its height on its side (front or
    back) across the middle of the shirt, so bands and hoops come out level
    instead of following the photo's folds; a third item True does the same
    for the sleeves (bands around the arm). front_from_back: the front takes
    the back's design (only a back photo is clean). fill: a colour name that
    the `ignore` texels take instead of the nearest colour around them (a
    plain ground behind big logos, where thin lines would otherwise spread). -> [(name, RGBA)]
    one flat layer per colour, bottom to top in the order given."""
    from scipy import ndimage
    a = source if source is not None else layer(kit, part)
    W, H = kit.size(part)
    pal = np.array([kit.colour(c) for c in colours], np.float32)
    rgb = a[..., :3].astype(np.float32)
    dist = np.stack([((rgb - c) ** 2).sum(-1) for c in pal], -1)
    lab = dist.argmin(-1)
    known = a[..., 3] > 0
    if ignore is not None:
        known &= ~ignore
    if off_palette:  # the photo's own logos in colours the design doesn't use
        known &= ~ndimage.binary_dilation(dist.min(-1) > off_palette ** 2, iterations=6)
    _, (iy, ix) = ndimage.distance_transform_edt(~known, return_indices=True)
    lab = lab[iy, ix]
    if fill is not None and ignore is not None:  # behind the sponsors: the ground colour,
        lab[ignore] = colours.index(fill)  # not the nearest line spread across the hole
    sig = smooth * H / 1024
    prob = np.stack([ndimage.gaussian_filter((lab == i).astype(np.float32), sig) for i in range(len(pal))], -1)
    if front_from_back:
        _, N, _ = surface(part, kit.model(part), (W, H))
        m = mirror_index(part, kit.model(part), (W, H), axis=2)
        flatp = prob.reshape(-1, len(pal))
        front = (N[..., 2] > 0).ravel()
        flatp[front] = flatp[m[front]]
        prob = flatp.reshape(prob.shape)
    if symmetric:
        m = mirror_index(part, kit.model(part), (W, H))
        flatp = prob.reshape(-1, len(pal))
        prob = ((flatp + flatp[m]) / 2).reshape(prob.shape)
    if level:
        hw, (ylo, yhi), *arms = level
        P, N, covered = surface(part, kit.model(part), (W, H))
        if arms and arms[0]:  # sleeves: bands around the arm, i.e. by distance out along it
            ax = np.abs(P[..., 0])
            sl = covered & (ax >= hw) & (P[..., 1] > 1.15)
            xb = np.clip(((ax - hw) / (0.33 - hw) * 200).astype(int), 0, 199)
            core = sl & known
            acc = np.zeros((200, len(pal)), np.float32)
            cnt = np.zeros(200, np.float32)
            np.add.at(acc, xb[core], prob[core])
            np.add.at(cnt, xb[core], 1)
            sel = sl & (cnt[xb] > 0)
            prob[sel] = (acc / np.maximum(cnt, 1)[:, None])[xb[sel]]
        side = (N[..., 2] < 0).astype(int)
        yb = np.clip(((P[..., 1] - ylo) / (yhi - ylo) * 400).astype(int), 0, 399)
        torso = covered & (np.abs(P[..., 0]) < hw) & (P[..., 1] > ylo) & (P[..., 1] < yhi)
        core = torso & (np.abs(P[..., 0]) < hw * 0.6) & known
        acc = np.zeros((2, 400, len(pal)), np.float32)
        cnt = np.zeros((2, 400), np.float32)
        np.add.at(acc, (side[core], yb[core]), prob[core])
        np.add.at(cnt, (side[core], yb[core]), 1)
        rows = acc / np.maximum(cnt, 1)[..., None]
        has = cnt[side, yb] > 0
        sel = torso & has
        prob[sel] = rows[side[sel], yb[sel]]
    best = prob.argmax(-1)
    out = []
    for i, name in enumerate(colours):
        im = np.zeros((H, W, 4), np.uint8)
        im[best == i] = tuple(int(v) for v in pal[i]) + (255,)
        out.append((name.replace("_", " ").capitalize(), im))
    return out


def knock_out_white(photo, lo=236):
    """Make the studio's white background transparent (only where it touches the edge)."""
    from scipy import ndimage
    a = np.array(photo)
    white = a[..., :3].min(-1) >= lo
    lab, _ = ndimage.label(white)
    edge = np.unique(np.r_[lab[0], lab[-1], lab[:, 0], lab[:, -1]])
    bg = np.isin(lab, edge[edge > 0])
    bg = ndimage.binary_dilation(bg, iterations=2)  # and the light antialiased rim
    a[bg, 3] = 0
    return Image.fromarray(a, "RGBA")


def clean(photo, erase=(), tol=6, size=1000, margin=(60, 45)):
    """Product shot -> the shirt alone on a transparent size x size canvas.
    The background is whatever touches the image edge in the edge's own
    colour (median of the border pixels), within tol. erase: boxes
    (x0, y0, x1, y1, in source pixels) to clear first, e.g. a SALE badge;
    a fifth item "grey" clears only the box's grey/white pixels, an [r, g, b]
    only that colour and what it encloses (a SALE badge with its text)."""
    from scipy import ndimage
    a = np.array(photo.convert("RGBA"), np.float32)
    for x0, y0, x1, y1, *grey in erase:
        box = a[y0:y1, x0:x1]
        # [.., "grey"]: only the unsaturated pixels (a grey badge over a coloured shirt)
        if not grey:
            hit = True
        elif grey[0] == "grey":
            hit = box[..., :3].max(-1) - box[..., :3].min(-1) < 30
        else:  # [r, g, b]: that colour (a SALE badge) and the white text on it
            near = np.abs(box[..., :3] - np.array(grey[0], np.float32)).max(-1) < 70
            hit = ndimage.binary_dilation(ndimage.binary_closing(near, iterations=6) | near, iterations=4)  # + its rim
        box[..., 3] = np.where(hit, 0, box[..., 3])
    rgb = a[..., :3]
    border = np.r_[rgb[0], rgb[-1], rgb[:, 0], rgb[:, -1]]
    bgc = np.median(border, 0)
    near = (np.abs(rgb - bgc).max(-1) <= tol) | (a[..., 3] == 0)
    lab, _ = ndimage.label(near)
    edge = np.unique(np.r_[lab[0], lab[-1], lab[:, 0], lab[:, -1]])
    bg = np.isin(lab, edge[edge > 0])
    bg = ndimage.binary_dilation(bg, iterations=2)  # the antialiased rim
    # the shirt is the biggest piece left; specks and stray labels go
    lab, n = ndimage.label(~bg)
    if n:
        bg |= lab != np.argmax(ndimage.sum(np.ones_like(lab), lab, range(1, n + 1))) + 1
    # light patches touching the edge (a white collar on a white backdrop) that the
    # flood ran into: close the outline and fill it back in
    bg = ~ndimage.binary_fill_holes(ndimage.binary_closing(~bg, iterations=8))
    a[..., 3] = np.where(bg, 0, 255)
    ys, xs = np.nonzero(~bg)
    crop = a[ys.min():ys.max() + 1, xs.min():xs.max() + 1]
    h, w = crop.shape[:2]
    sc = min((size - 2 * margin[0]) / w, (size - 2 * margin[1]) / h)
    im = Image.fromarray(crop.astype(np.uint8), "RGBA").resize((round(w * sc), round(h * sc)), Image.LANCZOS)
    out = Image.new("RGBA", (size, size), (255, 255, 255, 0))
    out.paste(im, ((size - im.width) // 2, (size - im.height) // 2))
    return out


# Landmark model points (as seen from that side) and how each is found on the
# photo's outline; calibrated on dolphins_indigenous_2026's hand-placed points.
MODEL_POINTS = {
    "front": {"neck": (0.068, 1.53), "shoulder": (0.2, 1.463), "cuff_out": (0.293, 1.323),
              "cuff_in": (0.235, 1.262), "armpit": (0.1675, 1.305), "waist": (0.15, 1.1),
              "hem": (0.162, 0.963), "hem_c": (0, 0.931), "neck_c": (0, 1.462),
              "neck_lo": (0.05, 1.472), "neck_mid": (0.085, 1.505)},
    "back": {"neck": (0.078, 1.525), "shoulder": (0.2, 1.472), "cuff_out": (0.293, 1.329),
             "cuff_in": (0.227, 1.265), "armpit": (0.173, 1.307), "waist": (0.143, 1.1),
             "hem": (0.161, 0.972), "hem_c": (0, 0.937), "neck_c": (0, 1.547)},
}


def auto_points(photo, side, trust=None, neck_y=None):
    """Landmarks [[mx, my, px, py], ...] read off a cleaned photo's outline:
    collar ends (top row), shoulder (outline at 10% height), cuff (the sleeve
    opening's corners, _cuff), armpit (where the outline leaves the body's side
    line), waist, hem corners (where the side meets the hem) and hem centre.
    neck_y: the photo row where the front collar meets the body at the centre,
    when the photo shows the inside of the back above it (the default guess,
    from the collar's width, then lands in the label)."""
    m = np.asarray(photo)[..., 3] > 0
    ys, xs = np.nonzero(m)
    top, bot = ys.min(), ys.max()
    H = bot - top
    # the centre line: the collar's middle (a shirt shot a little turned isn't
    # centred in its own outline)
    r = np.flatnonzero(m[int(top + 0.007 * H)])
    cx = (r[0] + r[-1]) / 2 if len(r) else (xs.min() + xs.max()) / 2
    if trust:  # one side is cut (a badge was erased over it): the collar gives the centre,
        # and the trusted side ("left"/"right" as seen) is mirrored onto the other
        r = np.flatnonzero(m[int(top + 0.007 * H)])
        cx = (r[0] + r[-1]) / 2
        keep = m[:, int(cx):] if trust == "right" else m[:, :int(cx) + 1]
        half = keep if trust == "right" else keep[:, ::-1]
        m = np.zeros_like(m)
        w = min(half.shape[1], int(cx) + 1, m.shape[1] - int(cx))
        m[:, int(cx):int(cx) + w] = half[:, :w]
        m[:, int(cx) - w + 1:int(cx) + 1] = half[:, :w][:, ::-1]
    pts = []

    def edges(y):
        r = np.flatnonzero(m[int(y)])
        return (r[0], r[-1]) if len(r) else (cx, cx)

    for sgn in (-1, 1):
        ext = (lambda y: edges(y)[0]) if sgn < 0 else (lambda y: edges(y)[1])
        rows = np.arange(top, bot + 1)
        e = np.array([ext(y) for y in rows], float)
        far = np.abs(e - cx)
        Wd = far.max() * 2
        neck_row = top + 0.007 * H
        n0 = np.flatnonzero(m[int(neck_row)])
        neck_half = (n0[-1] - n0[0]) / 2 if len(n0) else 0.1 * Wd
        # the body's side: a line through the outline of the body's middle; the
        # armpit is where the outline (going up) leaves it for the sleeve
        mid = (rows > top + 0.5 * H) & (rows < top + 0.75 * H)
        a, b = np.polyfit(rows[mid], far[mid], 1)
        line = a * rows + b
        out = far > line + 0.03 * Wd
        i0 = np.flatnonzero(rows > top + 0.5 * H)[0]
        j = i0
        while j > 0 and not out[j]:
            j -= 1
        ja = min(j + 2, len(rows) - 1)  # the body's outline just under the sleeve
        arm_y = rows[ja]
        armpit = (cx + sgn * far[ja], arm_y)
        cuff_out, cuff_in = _cuff(m, cx, sgn, rows, line, arm_y, armpit, Wd)
        # hem corner: the widest point of the body's lower half (the sides flare
        # out to the hem, then the hem curves in)
        low = rows > arm_y + 0.5 * (bot - arm_y)
        lf = far[low]
        i = np.flatnonzero(lf >= lf.max() - 0.015 * Wd)[-1]  # the lowest of the near-widest rows
        hy, hx = rows[low][i], lf[i]
        mid_y = arm_y + 0.57 * (hy - arm_y)
        found = {
            "neck": (cx + sgn * neck_half, neck_row),
            "shoulder": (ext(top + 0.1 * H), top + 0.1 * H),
            "cuff_out": cuff_out,
            "cuff_in": cuff_in,
            "armpit": armpit,
            "waist": (cx + sgn * (abs(ext(mid_y) - cx) + 0.008 * Wd), mid_y),
            "hem": (cx + sgn * hx, hy),
        }
        if side == "front":
            depth = (neck_y - top) if neck_y else 0.495 * 2 * neck_half
            found["neck_lo"] = (cx + sgn * 0.28 * 2 * neck_half, top + depth)
            found["neck_mid"] = (cx + sgn * 0.96 * neck_half, top + depth * 0.495)
        for name, (px, py) in found.items():
            mx, my = MODEL_POINTS[side][name]
            pts.append([round(sgn * mx, 4), my, round(float(px), 1), round(float(py), 1)])
    c = np.flatnonzero(m[:, int(cx)])
    pts.append([0, MODEL_POINTS[side]["hem_c"][1], round(cx, 1), float(c[-1])])
    if side == "front":
        depth = (neck_y - top) if neck_y else 0.495 * 2 * neck_half
        pts.append([0, MODEL_POINTS[side]["neck_c"][1], round(cx, 1), round(float(top + depth), 1)])
    else:
        pts.append([0, MODEL_POINTS[side]["neck_c"][1], round(cx, 1), float(c[0])])
    return pts


def _cuff(m, cx, sgn, rows, line, arm_y, armpit, Wd):
    """The sleeve opening's two corners (outer, inner) on one side of a photo:
    the sleeve is the shirt beyond the body's side line above the armpit; its
    tip is its outermost point, and the opening is the straight
    run of the sleeve's outline (convex hull) from the tip whose far end lies
    nearer the armpit (the other run from the tip is the sleeve's top edge).
    Works for flat lays (opening = the sleeve's bottom edge) and arms-out
    mannequins (opening = the sleeve's end)."""
    from scipy.spatial import ConvexHull
    ys, xs = np.nonzero(m)
    lim = np.interp(ys, rows, line)
    sel = (np.abs(xs - cx) > lim + 0.01 * Wd) & (np.sign(xs - cx) == sgn) & (ys <= arm_y)
    pts = np.c_[xs[sel], ys[sel]].astype(float)
    ap = np.array(armpit, float)
    hull = pts[ConvexHull(pts).vertices]
    # the tip: the outermost point (a little in favour of points away from the
    # armpit, so an arms-out sleeve's end gives its top corner)
    t = np.argmax(np.abs(hull[:, 0] - cx) + 0.25 * np.hypot(*(hull - ap).T))
    tip = hull[t]

    def run(step):  # walk the hull from the tip while the chord from the tip stays straight (< 20 deg)
        k, d0 = t, None
        while True:
            n = (k + step) % len(hull)
            if n == t:
                return hull[k]
            c = hull[n] - tip
            L = np.hypot(*c)
            if d0 is None:
                if L > 0.04 * Wd:  # the first chord long enough to give a direction
                    d0 = c / L
            elif (c / L) @ d0 < np.cos(np.radians(20)):
                return hull[k]
            k = n
    ends = [run(1), run(-1)]
    inner = min(ends, key=lambda p: ((p - ap) ** 2).sum())
    return (float(tip[0]), float(tip[1])), (float(inner[0]), float(inner[1]))


def flatten_light(photo, sigma=40):
    """Take the studio lighting out of a shot lit from one side (dark folds, a
    shaded far side): each pixel divided by the shirt's brightness around it
    (sigma px), scaled back to the shirt's median. Only for designs on a
    plain ground, whose large-scale tone is light, not design."""
    from scipy import ndimage
    a = np.asarray(photo, np.float32).copy()
    m = a[..., 3] > 0
    lum = a[..., :3].mean(-1) * m
    w = ndimage.gaussian_filter(m.astype(np.float32), sigma)
    low = ndimage.gaussian_filter(lum, sigma) / np.maximum(w, 1e-3)
    gain = np.median(lum[m]) / np.maximum(low, 1)
    a[..., :3] = np.where(m[..., None], (a[..., :3] * gain[..., None]).clip(0, 255), a[..., :3])
    return Image.fromarray(a.astype(np.uint8), "RGBA")


def prep(kit, part="top"):
    """Clean each side's "source" photo into "file" and fill in its "points"
    (kept when "points_locked" is set, e.g. after correcting them by hand)."""
    spec = kit.cfg["photos"][part]
    for side in ("front", "back"):
        s = spec.get(side)
        if not s or "source" not in s:
            continue
        im = clean(Image.open(kit.file(s["source"])), s.get("erase", ()), s.get("tol", 6))
        if s.get("flatten_light"):
            im = flatten_light(im, s["flatten_light"])
        im.save(kit.file(s["file"]))
        s["white_is_background"] = False
        if not s.get("points_locked"):
            s["points"] = auto_points(im, side, s.get("trust"), s.get("neck_y"))
        print(f"  {side}: {s['file']} ({len(s['points'])} points)")


def points_sheet(kit, part, out):
    """Model silhouettes (front, back) with a grid in model units, beside the photos."""
    W, H = kit.size(part)
    P, N, covered = surface(part, kit.model(part), (W, H))
    spec = kit.cfg.get("photos", {}).get(part, {})
    tiles = []
    for side, sign in (("front", 1), ("back", -1)):
        xy = view_xy(P, side)[covered & (N[..., 2] * sign > 0)]
        lo, hi = xy.min(0), xy.max(0)
        S = 1000
        sc = (S - 80) / (hi - lo).max()
        arr = np.full((S, S, 3), 255, np.uint8)
        ix = ((xy - lo) * sc + 40).astype(int).clip(0, S - 1)
        arr[S - 1 - ix[:, 1], ix[:, 0]] = 90
        im = Image.fromarray(arr)
        d = ImageDraw.Draw(im)
        step = 0.05
        for gx in np.arange(np.floor(lo[0] / step) * step, hi[0] + step, step):
            X = (gx - lo[0]) * sc + 40
            d.line([(X, 0), (X, S)], fill=(255, 0, 0) if abs(gx) < 1e-6 else (255, 170, 170))
            d.text((X + 2, 2), f"{gx:+.2f}", fill=(200, 0, 0))
        for gy in np.arange(np.floor(lo[1] / step) * step, hi[1] + step, step):
            Y = S - 1 - ((gy - lo[1]) * sc + 40)
            d.line([(0, Y), (S, Y)], fill=(170, 170, 255))
            d.text((2, Y + 2), f"{gy:.2f}", fill=(0, 0, 200))
        tiles.append(im)
        if side in spec:
            ph = Image.open(kit.file(spec[side]["file"])).convert("RGB").resize((S, S))
            d = ImageDraw.Draw(ph)
            for x in range(0, S, 50):
                d.line([(x, 0), (x, S)], fill=(255, 170, 170))
                d.text((x + 2, 2), str(x), fill=(200, 0, 0))
            for y in range(0, S, 50):
                d.line([(0, y), (S, y)], fill=(170, 170, 255))
                d.text((2, y + 2), str(y), fill=(0, 0, 200))
            for mx, my, px, py in spec[side].get("points", []):  # the landmarks, labelled in model units
                d.ellipse((px - 5, py - 5, px + 5, py + 5), outline=(255, 0, 255), width=2)
                d.text((px + 6, py - 6), f"{mx:+.2f},{my:.2f}", fill=(160, 0, 160))
            tiles.append(ph)
    sheet = Image.new("RGB", (sum(t.width for t in tiles), 1000), (255, 255, 255))
    x = 0
    for t in tiles:
        sheet.paste(t, (x, 0))
        x += t.width
    os.makedirs(os.path.dirname(out), exist_ok=True)
    sheet.save(out)
    print(out)


if __name__ == "__main__":
    import argparse
    import kit_studio as ks
    ap = argparse.ArgumentParser()
    ap.add_argument("cmd", choices=["points", "prep"])
    ap.add_argument("kit")
    ap.add_argument("--part", default="top")
    ap.add_argument("--out")
    a = ap.parse_args()
    k = ks.Kit(a.kit)
    if a.cmd == "prep":
        prep(k, a.part)
        k.save_cfg()
        raise SystemExit
    points_sheet(k, a.part, a.out or os.path.join(ks.WORK, a.kit, f"points_{a.part}.png"))
