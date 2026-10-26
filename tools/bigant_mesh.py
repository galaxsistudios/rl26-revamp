#!/usr/bin/env python3
"""
bigant_mesh.py - read the skinned character meshes (kit tops, shorts, socks)
of RL26 and Rugby League Live 4: positions, normals, triangles and UVs.
Enough to move a texture from one game's UV layout to the other's through
3D (see mods/rll4-legacy-kits).

RL26 (worked out 2026-10-24). A character model is two entries,
<basePath>/models/<name>/<name>.blendshapes and .modelcomponent, where <name>
is the asset-map item name plus its permutation names (assetmap.lua
getModelFileNameByItem), e.g. characters/tops/models/top_round05_short_Male/
top_round05_short_Male.modelcomponent. Index hashes are FNV-1a 64 of the
lowercased path, so models are found by path:

  .blendshapes  magic 0x2480137F. u32[11] header, then the base vertices of
                every LOD back to back from 0x2c, 48 bytes each:
                pos f32x3, w0 w1 u16, nrm f32x3, w2 w3 u16, tan f32x3,
                w4 u16, sign u16 (w0..w4 = skin weights summing to 65534).
                Body-shape morph deltas and their names follow.
  .modelcomponent magic 0x12345678. u32[9] header (h[3] = LOD count,
                h[7] + 28 = index buffer, h[8] + 32 = vertex buffer), then
                one 0x90-byte record per LOD from 0x24:
                [flag, 0, lod, vtxByteOff, nVerts, 0, idxByteOff, nIdx, ...]
                Each LOD's vertices are struct-of-arrays: 48*n zero bytes
                (pos/nrm/tan, filled from the blendshapes at runtime), 10*n
                bone indices (5 x u16), then n UV records - half2, plus 4
                more bytes on wrinkle-decal meshes (stride 66 vs 62).
                Indices are u16 triangle lists.

  UV -> kit texture (checked in-game with a labelled grid, 2026-10-24): texture
  x = (u mod 1) * width and y = (1 - v) * height of the upright image (the
  stored DDS is that image flipped), for tops, shorts and socks alike. The
  models face -z with the player's right at +x. Every kit texture of an item
  is in that item's model layout; stock tops are all top_round05/01-style
  raglan layouts (back panel, front panel, then the two sleeves).

RLL4 uses the same component/vertex formats split differently: the
component (v16) only holds the skeleton, materials and LOD records
(0x4c bytes each from 0xb8: [lod, vtxByteOff, nVerts, idxByteOff, nIdx,
...]), and a separate entry holds the geometry - u16 indices in its
description part, vertices in its data part: 48*n bytes pos/nrm/tan as
above, 5*n bone index bytes, then n x 8 bytes (two half2 UV sets).
The kit textures are read as stored (no flip) with u wrapping.
"""

import os
import struct
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import classify_entries as ce  # noqa: E402
import pack  # noqa: E402

RLL4_ROOT = r"D:\SteamLibrary\steamapps\common\Rugby League Live 4"
RLL4_TOOLS = r"D:\galaxsi\projects\games\rugby-league-live-4\tools"

# Model folders by asset-map basePath (see the docstring for the naming).
RL26_KIND = {"top": "characters/tops", "shorts": "characters/bottoms", "socks": "characters/socks"}
# RLL4's combined kit mesh (shirt + shorts + socks, one texture): geometry
# entry and its expected description/data sizes.
RLL4_UNIFORM = (7865, 97344, 603656, 2905, 14772)


def parse_rl26(comp, bs, lod=0):
    """Return (P, N, I, UV) for one LOD of an RL26 character model."""
    h = struct.unpack_from("<9I", comp, 0)
    if h[0] != 0x12345678 or struct.unpack_from("<I", bs, 0)[0] != 0x2480137F:
        raise ValueError("not a modelcomponent + blendshapes pair")
    recs = [struct.unpack_from("<36I", comp, 0x24 + 0x90 * k) for k in range(h[3])]
    idx0, vtx0 = h[7] + 28, h[8] + 32
    stride = (len(comp) - vtx0) // sum(r[4] for r in recs)
    voff, nv, ioff, ni = recs[lod][3], recs[lod][4], recs[lod][6], recs[lod][7]
    I = np.frombuffer(comp, np.uint16, ni, idx0 + ioff).reshape(-1, 3).astype(np.int64)
    base = vtx0 + voff
    if any(comp[base:base + 48 * nv]):
        raise ValueError("expected a zeroed dynamic vertex stream")
    rec = np.frombuffer(comp, np.uint8, (stride - 58) * nv, base + 58 * nv).reshape(nv, stride - 58)
    UV = rec[:, :4].copy().view(np.float16).reshape(nv, 2).astype(np.float64)
    V = np.frombuffer(bs, np.float32, 12 * nv, 0x2c + 48 * sum(r[4] for r in recs[:lod])).reshape(nv, 12)
    return V[:, :3].astype(np.float64), V[:, 4:7].astype(np.float64), I, UV


def load_rl26(kind, name, blobset=pack.BLOBSET_PATH):
    """(P, N, I, UV) of RL26 model <name> (e.g. "top_round05_short_Male") of
    kind "top" / "shorts" / "socks"."""
    import add_entries
    base = f"{RL26_KIND[kind]}/models/{name}/{name}"
    data, count, hash_off, _ = pack.read_index(blobset)
    entries = [add_entries.find_entry(data, count, hash_off, base + ext) for ext in (".modelcomponent", ".blendshapes")]
    if None in entries:
        raise SystemExit(f"RL26 model {base} is not in the index")
    ce.load_index(blobset)
    comp, bs = (ce.read_blob_full(blobset, e)[0] for e in entries)
    return parse_rl26(comp, bs)


def load_rll4():
    """RLL4's combined kit mesh: (P, N, I, UV)."""
    sys.path.insert(0, RLL4_TOOLS)
    import extract as rx  # the RLL4 project's blobset reader
    _, _, _, entries = rx.read_blobset_index(os.path.join(RLL4_ROOT, "data-0.blobset.pc"))
    index, isize, vsize, nv, ni = RLL4_UNIFORM
    e = entries[index]
    if (e.desc_size, e.data_size) != (isize, vsize):
        raise SystemExit(f"RLL4 entry {index} isn't the kit mesh (sizes {e.desc_size}/{e.data_size})")
    vol = os.path.join(RLL4_ROOT, f"data-{e.volume}.blobset.pc")
    ib = rx.decode_outer_part(vol, e)

    class _Data:  # decode_outer_part reads the description triple; point it at the data part
        desc_offset, desc_stored, desc_size = e.data_offset, e.data_stored, e.data_size
    vb = rx.decode_outer_part(vol, _Data)
    I = np.frombuffer(ib, np.uint16, ni).reshape(-1, 3).astype(np.int64)
    V = np.frombuffer(vb, np.float32, 12 * nv).reshape(nv, 12)
    UV = np.frombuffer(vb, np.uint8, 8 * nv, 53 * nv).reshape(nv, 8)[:, :4].copy().view(np.float16)
    return V[:, :3].astype(np.float64), V[:, 4:7].astype(np.float64), I, UV.reshape(nv, 2).astype(np.float64)
