"""
models.py - patch the sponsor decal models (fields/default/sponsor_field_*.model,
the entry right before each TXPK bundle) used by install.py.

Model layout (decompressed main; checked on the 3-, 5- and 6-mesh models):
    0x08          12 uint32 section offsets
    0x90          uint32 mesh count n, then n uint32 offsets, then
                  n * (min xyz, max xyz) float32 bounding boxes, in metres;
                  x runs along the pitch (try lines at +-50), z across it
    section[6]+0x20  uint32 n, n uint32 offsets, 8 bytes, then
                  n * 12 int32 mesh records:
                  [material, 2, mesh, 0, 0, vtxStart, vtxCount, -1,
                   idxStart, idxCount, 0, 0]
    material paths "fields/default/<model>/sponsor_field_<X>_SS[1]\0", in
                  material-index order; the vertex buffer starts right after
                  the NUL of the last one
    vertex buffer 32-byte vertices (float xyz at +0), then 4-byte half-float
                  UV pairs, then uint16 indices (relative to each mesh)
    texture paths "fields/textures/sponsors/<name>_col\0" (plain strings,
                  no stored hash - same-length renames are safe)

On disk a model is one outer frame: [uint32 frameLen incl. itself][zstd].
"""

import re
import struct

import numpy as np
import zstandard

VERTEX_STRIDE = 32
MATERIAL_RE = re.compile(rb"fields/default/[^/\x00]+/sponsor_field_([A-Za-z0-9_]+?)_SS1?\x00")


def in_goal_uv(x, z, x_range, z_half):
    """Where a pitch point lands in an in-goal texture (Model.in_goal_rect):
    u across the field, v from the try line side to the dead-ball side."""
    return (z + z_half) / (2 * z_half), (abs(x) - x_range[0]) / (x_range[1] - x_range[0])


def decode(stored):
    (frame_len,) = struct.unpack_from("<I", stored, 0)
    if frame_len != len(stored):
        raise ValueError("model is not a single outer frame")
    return zstandard.ZstdDecompressor().decompress(stored[4:], max_output_size=1 << 24)


def encode(model):
    """Same single-frame layout the game ships. Returns (stored, sizes)."""
    c = zstandard.ZstdCompressor(level=19).compress(model)
    stored = struct.pack("<I", 4 + len(c)) + c
    return stored, (len(stored), len(model), 0, 0)


class Model:
    def __init__(self, data):
        self.d = bytearray(data)
        (self.n,) = struct.unpack_from("<I", self.d, 0x90)
        sec6 = struct.unpack_from("<12I", self.d, 8)[6]
        if struct.unpack_from("<I", self.d, sec6 + 0x20)[0] != self.n:
            raise ValueError("mesh counts disagree")
        self.bboxes = 0x94 + 4 * self.n
        records = sec6 + 0x20 + 4 + 4 * self.n + 8
        self.meshes = [struct.unpack_from("<12i", self.d, records + 48 * k) for k in range(self.n)]
        for k, r in enumerate(self.meshes):
            if r[1] != 2 or r[2] != k or r[7] != -1:
                raise ValueError(f"unexpected mesh record {k}: {r}")
        mats = list(MATERIAL_RE.finditer(self.d))[:self.n]
        self.materials = [m.group(1).decode() for m in mats]
        self.vb = mats[-1].end()
        nverts = sum(r[6] for r in self.meshes)
        self.uv = self.vb + VERTEX_STRIDE * nverts

    def mesh_for(self, material):
        mat = self.materials.index(material)
        return next(k for k, r in enumerate(self.meshes) if r[0] == mat)

    def pos(self, v):
        return struct.unpack_from("<3f", self.d, self.vb + VERTEX_STRIDE * v)

    def quads_ok(self, k):
        """Every quad of mesh k uses the 0,1,2 / 0,2,3 corner order."""
        r = self.meshes[k]
        idx = struct.unpack_from(f"<{r[9]}H", self.d, self.uv + 4 * sum(m[6] for m in self.meshes) + 2 * r[8])
        return all(idx[i:i + 6] == (q, q + 1, q + 2, q, q + 2, q + 3)
                   for i, q in zip(range(0, len(idx), 6), range(0, r[6], 4)))

    def move_badge_opposite(self, badge="leagueStars01", anchor="nrlTelstraPremiership02"):
        """Put the badge's first quad where the anchor (centre logo) quad is,
        shifted to the other side of the pitch across z=0 - same size and
        orientation, winding untouched - and collapse its other quads."""
        a, b = self.mesh_for(anchor), self.mesh_for(badge)
        ra, rb = self.meshes[a], self.meshes[b]
        if ra[6] != 4 or rb[6] < 4 or not self.quads_ok(a) or not self.quads_ok(b):
            raise ValueError("anchor/badge meshes are not plain quads")
        bb = struct.unpack_from("<6f", self.d, self.bboxes + 24 * a)
        dz = -(bb[2] + bb[5])
        for i in range(4):
            va, vb = ra[5] + i, rb[5] + i
            src = self.vb + VERTEX_STRIDE * va
            dst = self.vb + VERTEX_STRIDE * vb
            self.d[dst:dst + VERTEX_STRIDE] = self.d[src:src + VERTEX_STRIDE]
            x, y, z = struct.unpack_from("<3f", self.d, dst)
            struct.pack_into("<3f", self.d, dst, x, y, z + dz)
            self.d[self.uv + 4 * vb:self.uv + 4 * vb + 4] = self.d[self.uv + 4 * va:self.uv + 4 * va + 4]
        first = self.pos(rb[5])
        for v in range(rb[5] + 4, rb[5] + rb[6]):
            struct.pack_into("<3f", self.d, self.vb + VERTEX_STRIDE * v, *first)
        struct.pack_into("<6f", self.d, self.bboxes + 24 * b, bb[0], bb[1], bb[2] + dz, bb[3], bb[4], bb[5] + dz)

    def resize_quad(self, material, width_x, depth_z, centre_abs_z=None):
        """Resize a single-quad mesh to width_x (along the pitch) by depth_z
        (across it), keeping orientation and UVs. It stays centred where it
        was, unless centre_abs_z moves it to that distance from the pitch's
        long axis on its own side."""
        k = self.mesh_for(material)
        r = self.meshes[k]
        if r[6] != 4 or not self.quads_ok(k):
            raise ValueError(f"{material} is not a single quad")
        bb = struct.unpack_from("<6f", self.d, self.bboxes + 24 * k)
        cx, cz = (bb[0] + bb[3]) / 2, (bb[2] + bb[5]) / 2
        nz = cz if centre_abs_z is None else (centre_abs_z if cz >= 0 else -centre_abs_z)
        sx, sz = width_x / (bb[3] - bb[0]), depth_z / (bb[5] - bb[2])
        for v in range(r[5], r[5] + 4):
            x, y, z = self.pos(v)
            struct.pack_into("<3f", self.d, self.vb + VERTEX_STRIDE * v, cx + (x - cx) * sx, y, nz + (z - cz) * sz)
        struct.pack_into("<6f", self.d, self.bboxes + 24 * k, cx - width_x / 2, bb[1], nz - depth_z / 2,
                         cx + width_x / 2, bb[4], nz + depth_z / 2)

    def full_uv(self, material):
        """Stretch a mesh's UVs to the whole 0..1 texture (orientation kept).
        Stock quads often show only a window of their texture - e.g. the RLWC
        centre maps u 0.16-0.84 - which crops replacement art at the sides."""
        r = self.meshes[self.mesh_for(material)]
        lo, hi = self.uv + 4 * r[5], self.uv + 4 * (r[5] + r[6])
        uv = np.frombuffer(bytes(self.d[lo:hi]), np.float16).reshape(-1, 2).astype(np.float32)
        mn, mx = uv.min(axis=0), uv.max(axis=0)
        self.d[lo:hi] = ((uv - mn) / (mx - mn)).astype(np.float16).tobytes()

    def collapse(self, material):
        """Hide a mesh by collapsing every vertex onto its first one."""
        r = self.meshes[self.mesh_for(material)]
        first = self.pos(r[5])
        for v in range(r[5] + 1, r[5] + r[6]):
            struct.pack_into("<3f", self.d, self.vb + VERTEX_STRIDE * v, *first)

    def quad_count(self, material):
        k = self.mesh_for(material)
        if not self.quads_ok(k):
            raise ValueError(f"{material} is not made of plain quads")
        return self.meshes[k][6] // 4

    def quad_centre_x(self, material, q):
        r = self.meshes[self.mesh_for(material)]
        return sum(self.pos(r[5] + 4 * q + i)[0] for i in range(4)) / 4

    def place_quad(self, material, q, rect, flipped):
        """Lay quad q of a mesh flat over rect = (x0, x1, z0, z1) in this
        model's own coordinates, showing the whole texture. Each corner goes
        where its (snapped) UV says: u runs along +x and v=0 is the +z side on
        a normal model; a _flipped model is the same turned 180 degrees. That
        is the stock orientation (art reads upright from the main camera) and
        it keeps every quad's winding. Vertex heights are kept."""
        r = self.meshes[self.mesh_for(material)]
        x0, x1, z0, z1 = rect
        for i in range(4):
            v = r[5] + 4 * q + i
            uv_off = self.uv + 4 * v
            u, w = (float(c) >= 0.5 for c in np.frombuffer(bytes(self.d[uv_off:uv_off + 4]), np.float16))
            if flipped:
                x, z = x1 - u * (x1 - x0), z0 + w * (z1 - z0)
            else:
                x, z = x0 + u * (x1 - x0), z1 - w * (z1 - z0)
            y = self.pos(v)[1]
            struct.pack_into("<3f", self.d, self.vb + VERTEX_STRIDE * v, x, y, z)
            self.d[uv_off:uv_off + 4] = np.array((u, w), np.float16).tobytes()
        self.update_bbox(material)

    def in_goal_rect(self, material, x_range, z_half, y=0.0):
        """Turn a stock in-goal banner strip (6 skewed panels) into one flat
        rectangle over the whole in-goal on its end: |x| in x_range, z in
        +-z_half. UV: u across the field (z -z_half..z_half), v from the try
        line side (0) to the dead-ball side (1) - see in_goal_uv. The first
        panel's four corners become the rectangle (kept per edge, so its
        winding holds); every other vertex is parked on one corner with that
        corner's UV, so leftover triangles are degenerate or lie inside the
        rectangle showing the same texture. Returns +1 / -1 for the end."""
        k = self.mesh_for(material)
        r = self.meshes[k]
        nverts = sum(m[6] for m in self.meshes)
        idx = struct.unpack_from("<6H", self.d, self.uv + 4 * nverts + 2 * r[8])
        panel = sorted(set(idx))
        if len(panel) != 4:
            raise ValueError(f"{material}: first two triangles don't form one panel ({idx})")
        pos = {i: self.pos(r[5] + i) for i in panel}
        sign = 1 if pos[panel[0]][0] > 0 else -1
        by_x = sorted(panel, key=lambda i: abs(pos[i][0]))
        new = {}
        for pair, ax in ((by_x[:2], x_range[0]), (by_x[2:], x_range[1])):
            lo, hi = sorted(pair, key=lambda i: pos[i][2])
            new[lo] = (sign * ax, y, -z_half)
            new[hi] = (sign * ax, y, z_half)

        def uv_of(p):
            return np.array(in_goal_uv(p[0], p[2], x_range, z_half), np.float16).tobytes()

        for i in range(r[6]):
            p = new.get(i, new[panel[0]])
            struct.pack_into("<3f", self.d, self.vb + VERTEX_STRIDE * (r[5] + i), *p)
            self.d[self.uv + 4 * (r[5] + i):self.uv + 4 * (r[5] + i) + 4] = uv_of(p)
        self.update_bbox(material)
        return sign

    def update_bbox(self, material):
        k = self.mesh_for(material)
        r = self.meshes[k]
        p = np.array([self.pos(v) for v in range(r[5], r[5] + r[6])], np.float32)
        struct.pack_into("<6f", self.d, self.bboxes + 24 * k, *p.min(axis=0), *p.max(axis=0))

    def swap_model_name(self, base, new):
        """Same-length swap of the model name inside its material paths, so a
        clone never shares a material with the model it was cloned from."""
        if len(base) != len(new):
            raise ValueError("model name swaps must keep the same length")
        out, n = re.subn(re.escape(base.encode()), new.encode(), bytes(self.d), flags=re.I)
        if n == 0:
            raise ValueError(f"model name {base} not found")
        self.d = bytearray(out)

    def rename_texture(self, old, new):
        old_b = f"fields/textures/sponsors/{old}\x00".encode()
        new_b = f"fields/textures/sponsors/{new}\x00".encode()
        if len(old_b) != len(new_b):
            raise ValueError("texture renames must keep the same length")
        if self.d.count(old_b) != 1:
            raise ValueError(f"expected exactly one reference to {old}")
        i = self.d.index(old_b)
        self.d[i:i + len(old_b)] = new_b

    def bytes(self):
        return bytes(self.d)
