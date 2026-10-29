"""
stadium_model.py - re-map the board / cloth / tunnel-wall UVs of Allegiant
Stadium's stadiums/lasvegasstadium/stadium_t1.model (used by install.py).

Layout of that model, worked out 2026-10-29 (decompressed main; stored as
outer chunk frames, main compressed, no vram):
    0x08              12 uint32 section offsets
    section[6]+0x20   uint32 n, n uint32 offsets, 8 bytes, then n * 12 int32
                      submesh records [material, node, submesh, 0, 0,
                      vtxStart, vtxCount, -1, idxStart, idxCount, group, x]
    material index    order of first appearance of the material path strings
    vertex group 1    struct-of-arrays at 0x27ead: pos f32x3, nrm f32x3
                      (24 B), tangent 8 B, uv half2, colour 4 B
    vertex group 2    ("PosNrmTan_2UV", which the walls/cloth use) at
                      G2_BASE: G2_COUNT interleaved 32 B records (pos f32x3,
                      nrm f32x3, tangent 8 B), then per vertex uv0 half2 +
                      uv1 half2 (uv1 = lightmap). vtxStart indexes it
                      directly. y is up; x runs along the pitch.
    indices           uint16 at IB, relative to each submesh's vtxStart

Stock UV0 here is inconsistent - one cloth side and a tunnel wall run
backwards (mirrored text), and the boards tile the texture ~16x vertically
- so every target piece gets a fresh planar mapping: per connected
component, u runs along the wall to the right of a viewer facing it
(dir = up x horizontal normal), one tile = aspect x the piece's height,
and v = (y - bottom) / height: v 1 at the top edge, 0 at the bottom.
Textures are stored upside down, so v reads upright row 1 - v and the
art's top row lands on the top edge. v stays inside 0..1 because the board
material clamps v: the first re-map used v -1..0, which the cloth wrapped
fine but which left every board on one (black) edge row of the texture.
"""

import struct

import numpy as np

G2_BASE = 0xC7BFC1
G2_COUNT = 96201
IB = 0x1027731

CLOTH = (572, 573, 574, 575, 576, 577)                       # tarpA_ATP250in_SSAO
# fabric_screen01_matrix_SSAO: the tall boards behind the LED boards, the
# strips under the cloth and the tunnel back/side walls
BOARDS = (365, 425, 426, 427, 428, 429, 430, 431, 432, 510, 511, 512)
TUNNEL_WALLS = (371, 522)                                    # concrete_paintedWall02_matrix_SSAO
# All of BOARDS and TUNNEL_WALLS are switched to the cloth's material. The
# board material is a colour-matrix material that never showed the new art
# in-game however its matrix was set from Lua; the cloth material samples
# its col_map directly and is proven to show it.
TARP_MATERIAL = 48
MIN_HEIGHT = 0.5  # metres; shorter pieces are trim, shown plain black
# Every piece maps its full height to one tile (one row of sponsors). Mapping
# only the part above the LED boards made the wrapping texture repeat below
# it - two rows on the tall boards.


def records(d):
    sec6 = struct.unpack_from("<12I", d, 8)[6]
    n = struct.unpack_from("<I", d, sec6 + 0x20)[0]
    base = sec6 + 0x20 + 4 + 4 * n + 8
    return base, [list(struct.unpack_from("<12i", d, base + 48 * k)) for k in range(n)]


def _components(tris, count):
    parent = list(range(count))

    def find(a):
        while parent[a] != a:
            parent[a] = parent[parent[a]]
            a = parent[a]
        return a

    for a, b, c in tris:
        ra, rb, rc = find(a), find(b), find(c)
        parent[rb] = ra
        parent[find(rc)] = ra
    groups = {}
    for v in range(count):
        groups.setdefault(find(v), []).append(v)
    return list(groups.values())


def remap(d, aspect):
    """Rewrite uv0 of CLOTH, BOARDS and TUNNEL_WALLS in place (bytearray d)
    and switch BOARDS and TUNNEL_WALLS to the cloth material. One tile is
    `aspect` x the mapped height. Returns a list of (submesh, components)."""
    base, recs = records(d)
    by_sub = {r[2]: (k, r) for k, r in enumerate(recs)}
    pos = np.frombuffer(bytes(d[G2_BASE:G2_BASE + 32 * G2_COUNT]), np.float32).reshape(G2_COUNT, 8)
    uv_base = G2_BASE + 32 * G2_COUNT
    done = []
    for sub in CLOTH + BOARDS + TUNNEL_WALLS:
        k, r = by_sub[sub]
        if r[10] != 2 or r[5] + r[6] > G2_COUNT:
            raise ValueError(f"submesh {sub} is not in vertex group 2")
        p = pos[r[5]:r[5] + r[6], :3].astype(np.float64)
        n = pos[r[5]:r[5] + r[6], 3:6].astype(np.float64)
        if not np.allclose(np.linalg.norm(n, axis=1), 1, atol=0.02):
            raise ValueError(f"submesh {sub}: normals are not unit length - model layout changed?")
        tris = np.frombuffer(bytes(d[IB + 2 * r[8]:IB + 2 * (r[8] + r[9])]), np.uint16).reshape(-1, 3)
        if tris.max() >= r[6]:
            raise ValueError(f"submesh {sub}: index out of range")
        comps = _components(tris, r[6])
        for comp in comps:
            q, m = p[comp], n[comp]
            nh = np.array([m[:, 0].sum(), 0.0, m[:, 2].sum()])
            if np.linalg.norm(nh) < 1e-6:
                continue  # a flat (floor/ceiling) bit - leave it
            nh /= np.linalg.norm(nh)
            direction = np.cross([0.0, 1.0, 0.0], nh)  # viewer's right when facing the wall
            top, bottom = q[:, 1].max(), q[:, 1].min()
            height = top - bottom
            if height < MIN_HEIGHT:
                # trim / edge strips: one texel of the art's plain black top
                # margin, not a run of tiny logos
                u = np.full(len(comp), 0.02)
                v = np.full(len(comp), 0.97)
            else:
                u = (q @ direction) / (aspect * height)
                u -= np.floor(u.min())
                # v 1 at the top edge, 0 at the bottom (textures are stored
                # upside down, so v reads upright row 1 - v), kept inside
                # 0..1: the board material clamps v - v -1..0 read only one
                # edge row of the texture, so the boards stayed blank
                v = (q[:, 1] - bottom) / height
            for vi, uu, vv in zip(comp, u, v):
                off = uv_base + 8 * (r[5] + vi)
                d[off:off + 4] = np.array([uu, vv], np.float16).tobytes()
        if sub in BOARDS + TUNNEL_WALLS:
            struct.pack_into("<i", d, base + 48 * k, TARP_MATERIAL)
        done.append((sub, len(comps)))
    return done

