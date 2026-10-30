#!/usr/bin/env python3
"""
jersey_template.py - layered Photoshop templates for painting a kit (jersey,
shorts, socks) in RL26's own UV layouts, plus a 3D preview of painted kits.

Kit textures are full-colour images (unlike headgear, which is a tint mask):
what you paint is what the player wears. Every stock NRL kit uses the same
three models - top_round05 (jersey), shorts01, socks01 - so one template per
part fits them all, and the kits made from them go in through
mods/rll4-legacy-kits ("custom" rows in kits.json, see its README).

Layout facts (from the meshes, checked against the stock Broncos 2026 home
textures): texture x = (u mod 1) * width, y = (1 - v) * height of the upright
image. The models' front is +z, so the player's right is -x. Triangles with
u > 1 are inside faces (hem, collar and cuff linings, the inside of the
waistband) that reuse texels of the outside, so they are drawn but not
labelled. The female top uses the same UVs as the male one.

The PSD for each part has the labels and UV outlines as guide layers, a
"YOUR DESIGN" layer over a plain base, the stock Broncos 2026 home kit as a
hidden example, and a shaded overlay on the texels that never show.

Usage (repo root):
    python tools/jersey_template.py [--out resources/jersey-templates]
    python tools/jersey_template.py preview <folder with top.png shorts.png socks.png> [--out preview.png]
"""

import argparse
import io
import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import bigant_mesh as bm  # noqa: E402
import pack  # noqa: E402

TEXDIR = "characters/uniforms/textures"
# part: (mesh kind, model, texture size, stock example texture, PSD name).
# Sizes are what mods/rll4-legacy-kits installs (top = every stock jersey).
PARTS = {
    "top": ("top", "top_round05_short_Male", (4096, 2048), "m_top_broncos_nrl_home_26_col_1", "jersey"),
    "shorts": ("shorts", "shorts01_Male", (2048, 2048), "m_shorts_broncos_nrl_home_26_col_1", "shorts"),
    "socks": ("socks", "socks01_long_Male", (1024, 1024), "m_socks_broncos_nrl_home_26_col_1", "socks"),
}
BASE = (235, 235, 235)
UNUSED = (60, 60, 60, 170)
LABEL = (0, 255, 255, 255)
HINT = (255, 230, 0, 255)


# --------------------------------------------------------------------------
# mesh


class Mesh:
    """One part's mesh in texture space: per-triangle 3D centre, normal,
    UV island and pixel corners (u > 1 triangles shifted back a tile)."""

    def __init__(self, part):
        kind, model, (self.W, self.H), *_ = PARTS[part]
        self.part = part
        self.P, self.N, self.I, self.UV = bm.load_rl26(kind, model)
        self.centre = self.P[self.I].mean(1)
        self.normal = self.N[self.I].mean(1)
        u = self.UV[self.I, 0]
        self.inside = u.min(1) >= 1
        self.px = np.dstack([(u - np.floor(u.min(1, keepdims=True))) * self.W,
                             (1 - self.UV[self.I, 1]) * self.H])
        self.island = self._islands()

    def _islands(self):
        from scipy.sparse import coo_matrix
        from scipy.sparse.csgraph import connected_components
        _, uid = np.unique(np.round(self.UV, 5), axis=0, return_inverse=True)
        uid = uid.ravel()
        e = np.r_[self.I[:, [0, 1]], self.I[:, [1, 2]]]
        n = uid.max() + 1
        _, lab = connected_components(coo_matrix((np.ones(len(e)), (uid[e[:, 0]], uid[e[:, 1]])), shape=(n, n)),
                                      directed=False)
        return lab[uid[self.I[:, 0]]]

    def mask(self, tris=None, grow=0):
        im = Image.new("L", (self.W, self.H), 0)
        d = ImageDraw.Draw(im)
        for t in np.flatnonzero(tris) if tris is not None else range(len(self.I)):
            d.polygon([tuple(p) for p in self.px[t]], fill=255)
        return im.filter(ImageFilter.MaxFilter(grow * 2 + 1)) if grow else im

    def anchor(self, tris):
        """Area-weighted centre of some triangles, snapped onto the nearest one."""
        p = self.px[tris]
        d1, d2 = p[:, 1] - p[:, 0], p[:, 2] - p[:, 0]
        a = np.abs(d1[:, 0] * d2[:, 1] - d1[:, 1] * d2[:, 0]) + 1e-9
        c = p.mean(1)
        mid = (c * a[:, None]).sum(0) / a.sum()
        return tuple(c[np.argmin(((c - mid) ** 2).sum(1))])

    def regions(self):
        """[(text, triangle mask, is a hint)] - the labels for this part."""
        x, y = self.centre[:, 0], self.centre[:, 1]
        front = self.normal[:, 2] > 0
        out = []
        islands = [k for k in np.unique(self.island[~self.inside])]
        size = {k: (self.island == k).sum() for k in islands}
        if self.part == "top":
            body = max(islands, key=size.get)
            on = self.island == body
            low = (y > 1.0) & (y < 1.12) & (np.abs(x) < 0.08)
            out += [("FRONT\n(as seen from the front)", on & front & low, False),
                    ("BACK\n(as seen from behind)", on & ~front & low, False)]
            for side, sel in (("RIGHT", x < -0.12), ("LEFT", x > 0.12)):
                out += [(f"player's\n{side}", on & front & sel & (y > 1.2) & (y < 1.32), True),
                        (f"player's\n{side}", on & ~front & sel & (y > 1.2) & (y < 1.32), True)]
            out += [("neck", on & (y > 1.44) & (np.abs(x) < 0.12) & front, True),
                    ("neck", on & (y > 1.44) & (np.abs(x) < 0.12) & ~front, True),
                    ("hem", on & (y < 1.0) & front & (np.abs(x) < 0.05), True),
                    ("hem", on & (y < 1.0) & ~front & (np.abs(x) < 0.05), True)]
            for k in islands:
                if k == body:
                    continue
                on = self.island == k
                mx = x[on].mean()
                if abs(mx) < 0.15:
                    out.append(("COLLAR", on, False))
                    continue
                out += [(f"{'RIGHT' if mx < 0 else 'LEFT'} SLEEVE", on & (y > 1.29) & (y < 1.34), False),
                        ("shoulder", on & (y > 1.44), True), ("cuff", on & (y < 1.28), True),
                        ("front", on & front & (y > 1.37) & (y < 1.42), True),
                        ("back", on & ~front & (y > 1.37) & (y < 1.42), True)]
        elif self.part == "shorts":
            for k in islands:
                on = self.island == k
                side = "RIGHT" if x[on].mean() < 0 else "LEFT"
                if size[k] < 100:
                    out.append((f"{side}\nleg-hole cap\n(rarely seen)", on, True))
                    continue
                out += [(f"{side} LEG - FRONT", on & front & (np.abs(x) < 0.14), False),
                        (f"{side} LEG - BACK", on & ~front & (np.abs(x) < 0.14), False),
                        ("outer side", on & (np.abs(x) > 0.16), True),
                        ("waistband", on & (y > 0.97) & front & (np.abs(x) < 0.12), True),
                        ("waistband", on & (y > 0.97) & ~front & (np.abs(x) < 0.12), True),
                        ("hem", on & (y < 0.71) & (np.abs(x) > 0.15), True)]
        else:
            for k in islands:
                on = self.island == k
                side = "RIGHT" if x[on].mean() < 0 else "LEFT"
                out += [(f"{side} SOCK\nshin (front)", on & front & (y > 0.15) & (y < 0.35), False),
                        ("calf\n(back)", on & ~front & (y > 0.15) & (y < 0.35) & (x * np.sign(x[on].mean()) > 0.13), True),
                        ("top (folded)", on & (y > 0.41) & front, True),
                        ("into the boot", on & (y < 0.08) & front, True)]
        return [r for r in out if r[1].any()]

    def _edges(self):
        """Every triangle edge as (triangle, corner a, corner b)."""
        n = len(self.I)
        tri = np.tile(np.arange(n), 3)
        corner = np.repeat([[0, 1], [1, 2], [2, 0]], n, axis=0)
        return tri, corner

    def boundary_lines(self, width, colour):
        """Island outlines (edges used by one triangle), outside faces only."""
        _, uid = np.unique(np.round(self.UV, 5), axis=0, return_inverse=True)
        uid = uid.ravel()
        tri, corner = self._edges()
        k = np.sort(uid[self.I[tri[:, None], corner]], axis=1)
        _, inv, cnt = np.unique(k, axis=0, return_inverse=True, return_counts=True)
        edge = (cnt[inv.ravel()] == 1) & ~self.inside[tri]
        return self._lines(tri[edge], corner[edge], width, colour)

    def wire_lines(self, width, colour):
        return self._lines(*self._edges(), width, colour)

    def _lines(self, tri, corner, width, colour):
        im = Image.new("RGBA", (self.W, self.H), (0, 0, 0, 0))
        d = ImageDraw.Draw(im)
        for t, (a, b) in zip(tri, corner):
            d.line([tuple(self.px[t, a]), tuple(self.px[t, b])], fill=colour, width=width)
        return im


# --------------------------------------------------------------------------
# template


def read_texture(name, blobset=pack.BLOBSET_PATH):
    """A stock texture, upright (the game stores kit textures upside down)."""
    import add_entries
    import classify_entries as ce
    import extract_textures as et
    ce.load_index(blobset)
    data, count, hash_off, _ = pack.read_index(blobset)
    entry = add_entries.find_entry(data, count, hash_off, f"{TEXDIR}/{name}.texture")
    if entry is None:
        raise SystemExit(f"{TEXDIR}/{name} is not in the index")
    raw = ce.read_blob_full(blobset, entry)[0]
    return Image.open(io.BytesIO(et.parse_mini_txpk(raw)[1])).transpose(Image.FLIP_TOP_BOTTOM)


def labels(mesh):
    im = Image.new("RGBA", (mesh.W, mesh.H), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    big = ImageFont.truetype("arialbd.ttf", max(18, mesh.H // 32))
    small = ImageFont.truetype("arialbd.ttf", max(14, mesh.H // 52))
    stroke = max(2, mesh.H // 512)
    for text, tris, hint in mesh.regions():
        font = small if hint else big
        x, y = mesh.anchor(tris)
        # keep the whole label on the image (islands at the texture edge)
        l, t, r, b = d.multiline_textbbox((x, y), text, font=font, anchor="mm", align="center", stroke_width=stroke)
        x += max(0, -l) - max(0, r - mesh.W)
        y += max(0, -t) - max(0, b - mesh.H)
        d.multiline_text((x, y), text, font=font, fill=HINT if hint else LABEL, anchor="mm", align="center",
                         stroke_width=stroke, stroke_fill=(0, 0, 0, 255))
    return im


def solid(colour, alpha):
    a = np.asarray(alpha, np.uint8)
    rgb = np.empty(a.shape + (3,), np.uint8)
    rgb[:] = colour[:3]
    return Image.fromarray(np.dstack([rgb, a]), "RGBA")


def psd_layer(name, im, visible=True):
    from pytoshop.user import nested_layers
    a = np.asarray(im.convert("RGBA"))
    return nested_layers.Image(name=name, visible=visible, opacity=255,
                               channels={0: a[..., 0], 1: a[..., 1], 2: a[..., 2], -1: a[..., 3]})


def build_template(part, out):
    # pytoshop only here: the installer runs bake_custom/render without it
    import packbits
    from pytoshop import codecs, enums
    from pytoshop.user import nested_layers
    # pytoshop's compiled RLE codec has no build for newer Pythons; the pure
    # packbits package has the same encode/decode API.
    codecs.packbits = packbits
    *_, (W, H), example_name, title = PARTS[part]
    mesh = Mesh(part)
    cov = np.asarray(mesh.mask(~mesh.inside, grow=2)) > 0
    example = read_texture(example_name).convert("RGBA").resize((W, H), Image.LANCZOS)
    line = max(2, H // 512)
    layers = {
        "base": solid(BASE, np.full((H, W), 255)),
        "example": example,
        "design": Image.new("RGBA", (W, H), (0, 0, 0, 0)),
        "unused": solid(UNUSED, np.where(cov, 0, UNUSED[3])),
        "wire": mesh.wire_lines(1, (0, 0, 0, 110)),
        "outline": mesh.boundary_lines(line, (0, 255, 255, 255)),
        "labels": labels(mesh),
    }
    psd_layers = [  # top of the Photoshop layer stack first
        psd_layer("LABELS (hide before exporting)", layers["labels"]),
        psd_layer("UV OUTLINES (hide before exporting)", layers["outline"]),
        psd_layer("UV wireframe (hide before exporting)", layers["wire"], visible=False),
        psd_layer("Not on the kit - shading (hide before exporting)", layers["unused"]),
        psd_layer("YOUR DESIGN (paint here)", layers["design"]),
        psd_layer("Example - Broncos 2026 home", layers["example"], visible=False),
        psd_layer("Base colour", layers["base"]),
    ]
    psd = nested_layers.nested_layers_to_psd(psd_layers, color_mode=enums.ColorMode.rgb,
                                             size=(W, H), compression=enums.Compression.rle)
    path = os.path.join(out, f"{title}_template.psd")
    with open(path, "wb") as f:
        psd.write(f)

    def flat(*keys):
        img = Image.new("RGBA", (W, H))
        for k in keys:
            img.alpha_composite(layers[k])
        return img.convert("RGB")
    flat("base", "unused", "outline", "labels").save(os.path.join(out, f"preview_{title}_blank.png"))
    flat("example", "unused", "outline", "labels").save(os.path.join(out, f"preview_{title}_example.png"))
    print("wrote", path)
    return example


# --------------------------------------------------------------------------
# 3D preview


def _raster(px, depth, attr, I, W, H, zbuf, out):
    """Z-buffered triangles: per pixel the nearest triangle's interpolated attr."""
    for t in I:
        p = px[t]
        x0, y0 = np.floor(p.min(0)).astype(int).clip(0, [W - 1, H - 1])
        x1, y1 = np.ceil(p.max(0)).astype(int).clip(0, [W - 1, H - 1])
        if x1 < x0 or y1 < y0:
            continue
        gx, gy = np.meshgrid(np.arange(x0, x1 + 1) + 0.5, np.arange(y0, y1 + 1) + 0.5)
        (ax, ay), (bx, by), (cx, cy) = p
        den = (by - cy) * (ax - cx) + (cx - bx) * (ay - cy)
        if abs(den) < 1e-12:
            continue
        w0 = ((by - cy) * (gx - cx) + (cx - bx) * (gy - cy)) / den
        w1 = ((cy - ay) * (gx - cx) + (ax - cx) * (gy - cy)) / den
        w2 = 1 - w0 - w1
        inside = (w0 >= -1e-6) & (w1 >= -1e-6) & (w2 >= -1e-6)
        if not inside.any():
            continue
        z = w0 * depth[t[0]] + w1 * depth[t[1]] + w2 * depth[t[2]]
        zb = zbuf[y0:y1 + 1, x0:x1 + 1]
        hit = inside & (z > zb)
        if not hit.any():
            continue
        zb[hit] = z[hit]
        a = w0[..., None] * attr[t[0]] + w1[..., None] * attr[t[1]] + w2[..., None] * attr[t[2]]
        out[y0:y1 + 1, x0:x1 + 1][hit] = a[hit]


def render(textures, size=420):
    """Front / back / side views of a kit: {part: upright PIL texture}."""
    meshes = [(part, *bm.load_rl26(PARTS[part][0], PARTS[part][1])) for part in PARTS]
    tex = {part: np.asarray(textures[part].convert("RGB"), np.float32) for part in PARTS}
    allP = np.concatenate([m[1] for m in meshes])
    lo, hi = allP.min(0), allP.max(0)
    scale = (size - 20) / (hi[1] - lo[1])
    light = np.array([0.3, 0.5, 0.8])
    views = []
    for view in ("front", "back", "side"):
        zbuf = np.full((size, size), -np.inf)
        out = np.zeros((size, size, 5))  # part id + 1, u, v, shade, unused
        # screen x, depth (towards the camera) and their normal components
        axes = {"front": lambda v: (v[:, 0], v[:, 2]), "back": lambda v: (-v[:, 0], -v[:, 2]),
                "side": lambda v: (-v[:, 2], v[:, 0])}[view]  # side: from the player's left (+x)
        sx = axes(allP)[0]
        mid = (sx.min() + sx.max()) / 2
        for k, (part, P, N, I, UV) in enumerate(meshes):
            (x, z), (nx, nz) = axes(P), axes(N)
            px = np.c_[(x - mid) * scale + size / 2, (hi[1] - P[:, 1]) * scale + 10]
            n = np.c_[nx, N[:, 1], nz]
            shade = 0.35 + 0.65 * np.clip((n / np.linalg.norm(n, axis=1, keepdims=True)) @ light, 0, 1)
            attr = np.c_[np.full(len(P), k + 1.0), UV % [1, 2], shade, np.zeros(len(P))]
            _raster(px, z, attr, I, size, size, zbuf, out)
        img = np.full((size, size, 3), 45, np.float32)
        for k, (part, *_rest) in enumerate(meshes):
            sel = np.round(out[..., 0]) == k + 1
            t = tex[part]
            th, tw = t.shape[:2]
            tu = ((out[..., 1][sel] % 1) * tw).astype(int).clip(0, tw - 1)
            tv = ((1 - out[..., 2][sel]) * th).astype(int).clip(0, th - 1)
            img[sel] = t[tv, tu] * out[..., 3][sel, None]
        views.append(img.clip(0, 255).astype(np.uint8))
    return Image.fromarray(np.concatenate(views, 1))


def load_kit(folder):
    """{part: upright image} from <folder>/top.png, shorts.png, socks.png,
    each resized to the installed size."""
    out = {}
    for part, (*_, size, _ex, _t) in PARTS.items():
        path = os.path.join(folder, f"{part}.png")
        if not os.path.exists(path):
            raise SystemExit(f"missing {path}")
        im = Image.open(path).convert("RGB")
        out[part] = im if im.size == size else im.resize(size, Image.LANCZOS)
    return out


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd")
    p = sub.add_parser("preview", help="render a painted kit (top.png, shorts.png, socks.png) on the 3D meshes")
    p.add_argument("folder")
    p.add_argument("--out")
    p.add_argument("--size", type=int, default=420)
    p.add_argument("--top-model", help="jersey model to preview on, e.g. top_flat01_short_Male (default top_round05)")
    ap.add_argument("--out", default="resources/jersey-templates")
    args = ap.parse_args()

    if args.cmd == "preview":
        if args.top_model:
            PARTS["top"] = (PARTS["top"][0], args.top_model) + PARTS["top"][2:]
        out = args.out or os.path.join(args.folder, "preview.png")
        render(load_kit(args.folder), args.size).save(out)
        print("wrote", out)
        return
    os.makedirs(args.out, exist_ok=True)
    examples = {part: build_template(part, args.out) for part in PARTS}
    render(examples).save(os.path.join(args.out, "preview_example_3d.png"))
    print("wrote", os.path.join(args.out, "preview_example_3d.png"))


if __name__ == "__main__":
    main()
