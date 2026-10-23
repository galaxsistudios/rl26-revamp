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
