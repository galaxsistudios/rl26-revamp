"""
hair.py - convert a Rugby League Live 4 scanned player's own hair mesh into
an RL26 hair model (worked out 2026-10-26; used by build.py).

RLL4 side (tools/rll4_source.py): the hair item named after the player
(e.g. "trentMerrin") is characters/hair/models/<name>/<name>.modelcomponent
(skeleton, materials, LOD records) + <name>.vbo (indices in the description
part, vertices in the data part), path hash MurmurHash2 seed 0xDEADBEEF of
the lowercased path + ".pc". Records are 19 u32 ending in (lod, vertex byte
offset, nverts, index byte offset, nindices); the first record has no
ffffffff marker, so records are read by their tails. Each LOD has two
submeshes: the hair itself and a smaller scalp "cap". A submesh's vertices
are 48*n bytes (pos f32x3, w0 w1 u16, normal f32x3, w2 w3, tangent f32x3,
w4, sign i16) + 5*n bone bytes + 4*n (one half2 UV): 57 bytes each.

RL26 side: a hair model is <name>.modelcomponent + <name>.blendshapes, see
tools/bigant_mesh.py. The component is built on a stock hair model with one
joint (Head) and one material (hairMaterial): header (h[8] = vertex buffer
start - 32), 0x90-byte LOD records [flag, 1, lod, vtx byte off, nverts, 0,
idx byte off, nidx, 0, bbox f32 x6 (cm), nverts, ...], the template's
skeleton/material block, u16 indices of every LOD, then per LOD 48*n zero
bytes, 5 x u16 bone indices (full-body joint numbers, 311 = Head), two
half2 UVs (UV1 holds per-vertex hair shader values; 0.5, 0 is neutral).
Round trip: the template's own geometry rebuilt through this writer gives a
byte-identical blendshapes file and a component differing only in UV1. The blendshapes file: u32 header [magic, 4, 36,
base size, then self-relative pointers into the tail], base vertices
(48 bytes each, all weight on bone 0 = Head), then the tail: per LOD
(48*n, n, component vertex offset), two zero words, per LOD a self-relative
offset + count of a u16 vertex remap (identity here: no morphs).
"""

import struct

import numpy as np

HAIR_STRIDE = 66
# vertex bone indices are full-body skeleton joints, not the component's own
# joint list: every stock hair vertex is (311, 0, 0, 0, 0) with all weight on
# slot 0, 311 = Head. Index 0 (the root) left the hair off the head, unseen.
HEAD_JOINT = 311


def _murmur2(data, seed=0xDEADBEEF):
    m, h, i, M = 0x5BD1E995, (seed ^ len(data)) & 0xFFFFFFFF, 0, 0xFFFFFFFF
    while len(data) - i >= 4:
        k = struct.unpack_from("<I", data, i)[0]
        k = (k * m) & M
        k ^= k >> 24
        k = (k * m) & M
        h = ((h * m) & M) ^ k
        i += 4
    r = len(data) - i
    if r >= 3:
        h ^= data[i + 2] << 16
    if r >= 2:
        h ^= data[i + 1] << 8
    if r >= 1:
        h ^= data[i]
        h = (h * m) & M
    h ^= h >> 13
    h = (h * m) & M
    return h ^ (h >> 15)


def rll4_entry(game, path):
    """Index of an RLL4 asset by its logical path (no .pc)."""
    if not hasattr(game, "_by_id"):
        game._by_id = {e.id: e.index for e in game.bs.entries}
    return game._by_id.get(_murmur2((path.lower() + ".pc").encode()))


def rll4_visual(blob):
    """{option name hash: int value} of an RLL4 player visual: magic 12 34 ED
    BC, u32, then 12-byte big-endian entries [MurmurHash2(name, seed
    0xDEADBEEF), data offset, u16 type (0 = container, 0xFFFF = value), u16
    byte count], then the data (values little-endian)."""
    p, ents = 8, []
    while p + 12 <= len(blob):
        h, off, typ, count = struct.unpack_from(">IIHH", blob, p)
        if typ not in (0xFFFF, 0):
            break
        ents.append((h, off, count))
        p += 12
    return {h: int.from_bytes(blob[p + off:p + off + c], "little") for h, off, c in ents[1:] if c <= 4}


def option_hash(name):
    return _murmur2(name.encode())


def _records(desc):
    ints = struct.unpack_from(f"<{len(desc) // 4}I", desc, 0)
    marks = [a for a in range(len(ints) - 19) if ints[a] == 0xFFFFFFFF and ints[a + 2] == 0 and ints[a + 1] < 16]
    tails = [ints[marks[0] - 5:marks[0]]] + [ints[a + 14:a + 19] for a in marks]
    out = []
    for lod, vo, nv, io, ni in tails:
        if nv and ni and ni % 3 == 0 and lod < 8:
            out.append({"lod": lod, "vo": vo, "nv": nv, "io": io, "ni": ni})
    return out


def rll4_hair(game, name, scalp):
    """The player's RLL4 hair split into its two parts:
    ({lod: (V float rows (n, 12), sign, UV, I)} of the strand cards, or {}
     when there are none, the LOD0 scalp cap (V, sign, UV, I) or None,
     texture names {"cap_col", "col", "dir"}) - or None without a hair model.
    The cap is the submesh hugging the scalp (median gap under 3 mm; it is
    textured with a painted hairline, e.g. short_shaved01_cap_hl2_col, full
    0-1 UVs), the cards stand off it (~10 mm) and use strand textures
    (hair_short_col / _dir). scalp: the player's RLL4 head points."""
    import re
    from scipy.spatial import cKDTree
    base = f"characters/hair/models/{name}/{name}"
    c, v = rll4_entry(game, base + ".modelcomponent"), rll4_entry(game, base + ".vbo")
    if c is None or v is None:
        return None
    desc = game.bs.desc(c)
    vb, ib = game.bs.data(v), game.bs.desc(v)
    tree = cKDTree(scalp)
    cards, cap = {}, None
    for r in _records(desc):
        n = r["nv"]
        V = np.frombuffer(vb, np.float32, 12 * n, r["vo"]).reshape(n, 12).astype(np.float64)
        S = np.frombuffer(vb, np.int16, 24 * n, r["vo"]).reshape(n, 24)[:, 23].astype(np.float64)
        UV = np.frombuffer(vb, np.float16, 2 * n, r["vo"] + 53 * n).reshape(n, 2).astype(np.float64)
        I = np.frombuffer(ib, np.uint16, r["ni"], r["io"]).reshape(-1, 3).astype(np.int64)
        part = (V, np.where(S < 0, -1.0, 1.0), UV, I)
        if np.median(tree.query(V[:, :3])[0]) < 0.003:
            if r["lod"] == 0:
                cap = part
        elif r["lod"] not in cards or n > len(cards[r["lod"]][0]):
            cards[r["lod"]] = part
    names = [x.decode() for x in re.findall(rb"[a-z][a-z0-9_]{3,}", desc)]
    tex = {"cap_col": next((x for x in names if "_cap" in x and x.endswith("_col")), None),
           "col": next((x for x in names if "_cap" not in x and x.endswith("_col")), None),
           "dir": next((x for x in names if x.endswith("_dir") and x not in ("cap_dir", "maya_directional1_dir")), None)}
    return cards, cap, tex


def build_rl26_hair(template_comp, template_bs, lods):
    """lods: [(P (n,3) m, N, T, sign, UV, I)] for each of the template's LOD
    records, in RL26 space. -> (modelcomponent bytes, blendshapes bytes)."""
    h = list(struct.unpack_from("<9I", template_comp, 0))
    nrec = h[3]
    if len(lods) != nrec:
        raise ValueError(f"template has {nrec} LOD records, got {len(lods)} LODs")
    idx_start = h[7] + 28
    head = bytearray(template_comp[:idx_start])
    idx = bytearray()
    vtx = bytearray()
    voffs = []
    for k, (P, N, T, S, UV, I) in enumerate(lods):
        n = len(P)
        if n > 65535:
            raise ValueError("too many vertices for u16 indices")
        rec = list(struct.unpack_from("<36I", head, 0x24 + 0x90 * k))
        rec[3], rec[4], rec[6], rec[7], rec[15] = len(vtx), n, len(idx), I.size, n
        struct.pack_into("<36I", head, 0x24 + 0x90 * k, *rec)
        bbox = np.r_[P.min(0), P.max(0)] * 100.0
        struct.pack_into("<6f", head, 0x24 + 0x90 * k + 9 * 4, *bbox)
        voffs.append(len(vtx))
        idx += I.astype(np.uint16).tobytes()
        uv = np.zeros((n, 4), np.float16)
        uv[:, 0:2] = UV
        uv[:, 2] = 0.5
        bones = np.zeros((n, 5), np.uint16)
        bones[:, 0] = HEAD_JOINT
        vtx += bytes(48 * n) + bones.tobytes() + uv.tobytes()
    h[8] = idx_start + len(idx) - 32
    struct.pack_into("<9I", head, 0, *h)
    comp = bytes(head) + bytes(idx) + bytes(vtx)

    # blendshapes: header, base vertices, tail
    rows = []
    for P, N, T, S, UV, I in lods:
        n = len(P)
        r = np.zeros((n, 12), np.float32)
        r[:, 0:3], r[:, 4:7], r[:, 8:11] = P, N, T
        u = r.view(np.uint16).reshape(n, 24)
        u[:, 6], u[:, 7], u[:, 14], u[:, 15], u[:, 22] = 65535, 0, 0, 0, 0  # all weight on bone 0 (Head)
        u[:, 23] = np.where(S < 0, 0xFFFF, 1)
        rows.append(r.tobytes())
    base = b"".join(rows)
    B = len(base)
    tail = bytearray()
    for (P, *_), off in zip(lods, voffs):
        tail += struct.pack("<3I", 48 * len(P), len(P), off)
    tail += struct.pack("<2I", 0, 0)
    pairs_at = len(tail)
    counts = [len(P) for P, *_ in lods]
    arrays_at = pairs_at + 8 * len(lods)
    pos = arrays_at
    for k, n in enumerate(counts):
        field = pairs_at + 8 * k
        tail += struct.pack("<2I", pos - field, n)
        pos += 2 * n
    for n in counts:
        tail += np.arange(n, dtype=np.uint16).tobytes()
    hb = [0x2480137F, 4, 36, B, B + 28, 0, B + 20, nrec, 0, B + 76, nrec]
    bs = struct.pack("<11I", *hb) + base + bytes(tail)
    return comp, bs
