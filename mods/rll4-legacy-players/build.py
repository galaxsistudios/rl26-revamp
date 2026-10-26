#!/usr/bin/env python3
"""
build.py - bring Rugby League Live 4's face-scanned players that RL26
doesn't have into RL26 as free agents, with their RLL4 face scans converted
to RL26 heads. Everything is read from the user's installed RLL4
(tools/rll4_source.py), so no RLL4 content ships with the mod.

Players: RLL4's defaultdata_players and RL26's are the same self-describing
format (tools/bigant_db.py). A player is imported when RLL4 has a face scan
for them (a head component whose material is "<first><last>_mat") and RL26
has no player with the same name and birth year (or the same surname and
birth date with a similar first name - nicknames like Matt / Matthew). New
player ids continue on from the highest stock id (3902, ...): the native
loader aborts at boot on an id far past the record count. Each head's guid
(and asset names) is 10000 + the RLL4 id, which has no such limit. The
records are appended to defaultdata_players by tools/data_mods.py; being on
no club's roster makes them free agents.

Heads (worked out 2026-10-26): every RLL4 tier-1 head shares one topology,
vertex order and UV layout (2806-vertex skin, metres, the head running down
to the shoulders); every RL26 tier-1 head shares one UV layout (3226-vertex
skin, vertex order differs per head, matched by UV). So the conversion is
computed once between the two templates and reused for every player:
  - prepare: average RL26 skin (in Bailey Hayward's vertex order) and
    average RLL4 skin; a similarity transform of RLL4 onto RL26 (ICP on the
    face, RLL4 heads come out about 9% bigger); for each RL26 vertex and
    each RL26 head texel the nearest RLL4 surface point (normal-checked),
    as triangle + barycentric weights / RLL4 UV.
  - heads, per player: a donor RL26 head is picked by skin colour (its
    modelcomponent, eyes, mouth, blendshape morphs, normal and material
    maps and its player visual are reused, so the body's skin texture
    matches). The donor's skin moves to
        RL26 mean + (the player's RLL4 skin - RLL4 mean), rotated + scaled,
    faded to the donor's own shape at the neck seam (y < 1.465 m) so it
    still meets the body; every other vertex (other LODs, eyelashes) moves
    with its nearest skin vertices, eyes and mouth rigidly; normals and
    tangents are rotated by the change of the surface normal. The colour
    texture is the donor's with every skin texel replaced by the RLL4
    scan's colour at the corresponding point.
  - The new head item is registered in ItemMaps.tier1head (and the
    tier1head_textures_* lists assetmapitems builds from it) from
    design/characters/texturedefinitions.lua, which assetmap imports at load,
    after assetmapitems. It has no hair items: the scan's hair is painted on.

Usage (repo root; game closed for install/texsrc):
    python mods/rll4-legacy-players/build.py select
    python mods/rll4-legacy-players/build.py prepare
    python mods/rll4-legacy-players/build.py heads [--only <id> ...]
    python mods/rll4-legacy-players/build.py sheet
    python mods/rll4-legacy-players/build.py generate
    python mods/rll4-legacy-players/build.py install [--replace] [--confirm]
    python mods/rll4-legacy-players/build.py texsrc [--confirm]
then rebuild entries 39959 (scripts) and 39957 (players) - see README.md.
"""

import argparse
import io
import json
import os
import re
import struct
import sys

import numpy as np
from PIL import Image
from scipy.spatial import cKDTree

MOD = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(MOD))
sys.path.insert(0, os.path.join(REPO, "tools"))
sys.path.insert(0, os.path.join(REPO, "mods", "rll4-legacy-kits"))
import add_entries  # noqa: E402
import bigant_db  # noqa: E402
import bigant_mesh as bm  # noqa: E402
import build_kits as bk  # noqa: E402  (rasteriser, bilinear sampling, DDS writer)
import classify_entries as ce  # noqa: E402
import pack  # noqa: E402
import parse_npcs as pn  # noqa: E402
import rll4_source  # noqa: E402

WORK = os.path.join(REPO, "_build", "rll4-legacy-players")
SELECTION = os.path.join(MOD, "players.json")
CACHE = os.path.join(WORK, "templates.npz")
PLAYERS_DIR = os.path.join(MOD, "defaultdata", "defaultdata_players")
LUA_REL = "design/characters/texturedefinitions.lua"
STOCK_LUA = os.path.join(REPO, "decompiled", "src", "script-game", *LUA_REL.split("/"))
STOCK_ASSETMAPITEMS = os.path.join(REPO, "decompiled", "src", "script-game", "design", "characters",
                                   "assetmapitems.lua")

ID_OFFSET = 10000
REFERENCE_HEAD = "baileyHayward_83"
TEX = 2048  # head texture _1 size (then 1024, 512)
NECK_FADE = (1.415, 1.465)  # metres: donor shape below, converted shape above
# RL26 visual body sliders from record height (cm) / weight (kg), fitted
# over every stock male player (residual std 12 / 15 slider steps)
HEIGHT_SLIDER = (-2.983, 689.9)
WEIGHT_SLIDER = (2.054, -98.8)
# options cleared in the donor's visual: the new heads have no hair meshes
# "hair" / "hairTop" stay the donor's: a tier-1 head's hair MODEL is always
# hairTop item head + 1000, but its TEXTURES come from the visual's hairTop
# item (assetmap var_0_53), so clearing it to 0 ("none") left the hair blank.
CLEAR_VISUAL = ("hairSide", "hairSide2", "hairTexture_cap", "beard", "beardTexture_cap",
                "chinhair", "sideburns", "moustache")
# RLL4 EAffiliations -> RL26, by majority vote over the 621 players in both
# games (birth country counted 3x, representative country 1x)
COUNTRY = {0: 0, 2: 2, 3: 26, 6: 9, 7: 11, 8: 12, 12: 9, 13: 17, 14: 18, 16: 0, 17: 0, 20: 26, 22: 29,
           24: 32, 25: 9, 26: 0, 30: 39, 31: 40, 33: 9}
# RLL4 field -> RL26 field where the name changed
RENAME = {"fitness": "stamina", "grubberKick": "groundKick"}
COPY_FIELDS = ["firstname", "surname", "sex", "shirtName", "birthDay", "birthMonth", "birthYear",
               "stateOfOrigin", "cityVsCountry", "allStars", "preferredRolePrimary", "preferredRoleSecondary",
               "preferredRoleTertiary", "rightHanded", "rightFooted", "height", "weight", "reputation", "ego",
               "loyalty", "strength", "aggression", "injuryTolerance", "tackle", "driveTackle", "diveTackle",
               "impactTackle", "agility", "fitness", "acceleration", "sprintSpeed", "grubberKick", "puntKick",
               "chipKick", "bombKick", "fieldgoalKick", "placeKick", "basicPass", "longPass", "offload",
               "contestedCollect", "diveCollect", "ballStrip", "dummyPass", "fend", "sideStep", "breakTackle",
               "nrlcareerappearances", "nrlcareertriesscored", "nrlcareergoals", "nrlcareergoalsattempted",
               "nrlcareerpoints", "SLcareerappearances", "SLcareertriesscored", "SLcareergoals",
               "SLcareergoalsattempted", "SLcareerpoints"]
GENERIC_MATS = {"head_mat", "eyes_mat", "eyes_clear_mat", "eyelashes_mat"}


def norm(s):
    return re.sub(r"[^a-z]", "", s.lower())


# --------------------------------------------------------------------------
# RL26 stock data

class RL26:
    def __init__(self, blobset=pack.BLOBSET_PATH):
        self.blobset = blobset
        self.index = pack.read_index(blobset)
        ce.load_index(blobset)

    def entry(self, path):
        data, count, hash_off, _ = self.index
        return add_entries.find_entry(data, count, hash_off, path)

    def read(self, path):
        e = self.entry(path)
        if e is None:
            return None
        meta = pack.backup_meta_path(e)
        if os.path.exists(meta):  # stock bytes of a replaced entry
            m = json.load(open(meta))
            raw = open(m["blob_backup"], "rb").read()
            if m["main_compressed_size"] != m["main_uncompressed_size"]:
                raw = ce.decode_outer_zstd_frames(raw)
            return raw
        return ce.read_blob_full(self.blobset, e)[0]

    def bundle_file(self, name, entry):
        """A file from a stock M3MP bundle (backup if the entry is modded)."""
        import extract_m3mp
        meta = pack.backup_meta_path(entry)
        if os.path.exists(meta):
            raw = open(json.load(open(meta))["blob_backup"], "rb").read()
        else:
            raw = ce.read_blob_full(self.blobset, entry)[0]
        return extract_m3mp.decode_m3mp(raw)[1][name]

    def players(self):
        return bigant_db.load(self.bundle_file("defaultdata/defaultdata_players", 39957))

    def head_model(self, name):
        base = f"characters/heads/models/{name}/{name}"
        comp, bs = self.read(base + ".modelcomponent"), self.read(base + ".blendshapes")
        return None if comp is None or bs is None else (comp, bs)

    def head_texture(self, name, kind, level):
        blob = self.read(f"characters/heads/textures/{name}_{kind}_{level}.texture")
        return None if blob is None else blob[blob.find(b"DDS "):]


def tier1_items():
    src = open(STOCK_ASSETMAPITEMS, encoding="utf-8-sig").read()
    i = src.index("\ttier1head = {")
    j = src.index("\n\t},\n", i)
    items = []
    for blk in re.findall(r"\{([^{}]*)\}", src[i:j]):
        d = dict(re.findall(r'(\w+) = "?([^",\n]+)"?', blk))
        if "guid" in d:
            d["guid"] = int(d["guid"])
            items.append(d)
    return items


def model_records(comp):
    """[(index, lod, nverts)] of an RL26 character model's LOD records."""
    h = struct.unpack_from("<9I", comp, 0)
    return [(k, r[2], r[4]) for k, r in
            enumerate(struct.unpack_from("<36I", comp, 0x24 + 0x90 * k) for k in range(h[3]))]


# --------------------------------------------------------------------------
# RLL4 heads

def _rll4_records(desc):
    """Submesh records of an RLL4 model component: [ffffffff, material, 0,
    bbox (6 f32, cm), ..., lod, vtx byte offset, nverts, idx byte offset,
    nidx] (19 u32)."""
    ints = struct.unpack_from(f"<{len(desc) // 4}I", desc, 0)
    out = []
    for a in range(20, len(ints) - 19):
        if ints[a] == 0xFFFFFFFF and ints[a + 2] == 0 and ints[a + 1] < 16:
            lod, vo, nv, io, ni = ints[a + 14:a + 19]
            if nv and ni and ni % 3 == 0 and lod < 8:
                out.append({"mat": ints[a + 1], "lod": lod, "vo": vo, "nv": nv, "io": io, "ni": ni,
                            "bbox": np.array(struct.unpack_from("<6f", desc, 4 * (a + 3))) / 100})
    return out


def rll4_heads(game):
    """{material name: {"component", "geometry", "pack", "skin"}} for every
    RLL4 scanned head whose geometry and textures were found. Geometry
    entries carry no names; each one is the entry whose LOD0 vertices have
    exactly the component's stored bounding box (cm there, m here)."""
    comps = {}
    for c, mats in game.cat["components"].items():
        if "head_mat" not in mats:
            continue
        names = [m[:-4] for m in mats if m.endswith("_mat") and m not in GENERIC_MATS]
        if len(names) == 1:
            comps[c] = names[0]
    packs = {}
    for e, paths in game.cat["packs"].items():
        for p in paths:
            m = re.match(r"characters/heads/textures/(\w+)_col$", p)
            if m:
                packs[m.group(1)] = e
    by_size = {}
    for e in game.bs.entries:
        if e.data_size and e.desc_size > 100000:
            by_size.setdefault(e.desc_size, []).append(e.index)
    bbox_cache = {}
    out = {}
    for c, name in comps.items():
        recs = _rll4_records(game.bs.desc(c))
        skin = [r for r in recs if r["lod"] == 0 and r["nv"] > 1000]
        if not skin or name not in packs:
            continue
        lod0 = [r for r in recs if r["lod"] == 0]
        isize = max(r["io"] + 2 * r["ni"] for r in recs)
        key = tuple((r["vo"], r["nv"]) for r in lod0)
        best = None
        for gi in by_size.get(isize, []):
            if (gi, key) not in bbox_cache:
                vb = game.bs.data(gi)
                try:
                    P = np.concatenate([np.frombuffer(vb, np.float32, 12 * r["nv"], r["vo"]).reshape(-1, 12)[:, :3]
                                        for r in lod0])
                except ValueError:
                    continue
                bbox_cache[(gi, key)] = np.r_[P.min(0), P.max(0)]
            d = np.abs(bbox_cache[(gi, key)] - lod0[0]["bbox"]).max()
            if best is None or d < best[0]:
                best = (d, gi)
        if best and best[0] < 1e-5:
            out[name] = {"component": c, "geometry": best[1], "pack": packs[name], "skin": skin[0]}
    return out


def rll4_skin(game, head):
    s = head["skin"]
    vb, ib = game.bs.data(head["geometry"]), game.bs.desc(head["geometry"])
    V = np.frombuffer(vb, np.float32, 12 * s["nv"], s["vo"]).reshape(-1, 12)
    UV = np.frombuffer(vb, np.uint8, 4 * s["nv"], s["vo"] + 53 * s["nv"]).reshape(-1, 4).copy().view(np.float16)
    I = np.frombuffer(ib, np.uint16, s["ni"], s["io"]).reshape(-1, 3).astype(np.int64)
    return V[:, :3].astype(np.float64), UV.reshape(-1, 2).astype(np.float64), I


# --------------------------------------------------------------------------
# select

def same_person(a, b):
    """RL26 player b is RLL4 player a: same name and birth year, or same
    surname and birth date with first names sharing their first 3 letters."""
    if norm(a["surname"]) != norm(b.get("surname", "")):
        return False
    if norm(a["firstname"]) == norm(b.get("firstname", "")) and a.get("birthYear") == b.get("birthYear"):
        return True
    dob = lambda m: (m.get("birthDay"), m.get("birthMonth"), m.get("birthYear"))
    return dob(a) == dob(b) and norm(a["firstname"])[:3] == norm(b.get("firstname", ""))[:3]


def cmd_select(args):
    game = rll4_source.RLL4(args.rll4)
    heads = rll4_heads(game)
    print(f"RLL4: {len(heads)} scanned heads with geometry + textures")
    r4 = bigant_db.load(game.m3mp_file("defaultdata/defaultdata_players"))
    r26 = RL26().players()
    by_surname = {}
    for rec in r26.records:
        by_surname.setdefault(norm(rec["tables"][0].get("surname", "")), []).append(rec["tables"][0])
    chosen, existing = [], 0
    for rec in r4.records:
        m = rec["tables"][0]
        name = norm(m["firstname"]) + norm(m["surname"])
        if name not in heads:
            continue
        if any(same_person(m, b) for b in by_surname.get(norm(m["surname"]), [])):
            existing += 1
            continue
        chosen.append({"rll4_id": m["id"], "id": ID_OFFSET + m["id"], "name": f"{m['firstname']} {m['surname']}",
                       "head": name, **{k: heads[name][k] for k in ("component", "geometry", "pack")}})
    used = {}
    for c in chosen:  # two RLL4 players can share a name; keep the first
        used.setdefault(c["head"], c)
    chosen = list(used.values())
    with open(SELECTION, "w") as f:
        json.dump({"_comment": "Generated by build.py select from the installed RLL4: RLL4 players with a face "
                               "scan that RL26 doesn't have. id = new RL26 player id (= head guid).",
                   "players": chosen}, f, indent=1)
        f.write("\n")
    print(f"{len(chosen)} players to import ({existing} scanned RLL4 players are already in RL26) -> "
          f"{os.path.relpath(SELECTION, REPO)}")


def load_selection():
    return json.load(open(SELECTION))["players"]


# --------------------------------------------------------------------------
# prepare: template correspondence

def vnormals(P, I):
    N = np.zeros_like(P)
    f = np.cross(P[I[:, 1]] - P[I[:, 0]], P[I[:, 2]] - P[I[:, 0]])
    for c in range(3):
        np.add.at(N, I[:, c], f)
    return N / (np.linalg.norm(N, axis=1, keepdims=True) + 1e-12)


def uv_order(UV0, P0, UV, P):
    """k with UV[i] == UV0[k[i]] (heads share UVs, not vertex order); groups
    of duplicate UVs are matched one to one by position."""
    d, kk = cKDTree(UV0).query(UV, k=4)
    if d[:, 0].max() > 1e-6:
        return None
    k = kk[:, 0].copy()
    groups = {}
    for i in np.where(d[:, 1] < 1e-9)[0]:
        groups.setdefault(tuple(sorted(kk[i][d[i] < 1e-9])), []).append(i)
    for cands, qs in groups.items():
        cands = list(cands)
        for i in sorted(qs, key=lambda q: min(np.linalg.norm(P0[cands] - P[q], axis=1))):
            j = min(cands, key=lambda c: np.linalg.norm(P0[c] - P[i]))
            k[i] = j
            cands.remove(j)
    return k if len(set(k)) == len(k) else None


def similarity(A, B):
    """s, R, T minimising |s R B + T - A|."""
    ca, cb = A.mean(0), B.mean(0)
    U, S, Vt = np.linalg.svd((B - cb).T @ (A - ca))
    D = np.eye(3)
    D[2, 2] = np.sign(np.linalg.det(Vt.T @ U.T))
    R = Vt.T @ D @ U.T
    s = (S * np.diag(D)).sum() / ((B - cb) ** 2).sum()
    return s, R, ca - s * R @ cb


def dense_samples(P, N, I, per_metre=400):
    """Dense barycentric samples of a mesh: points, normals, triangle, weights."""
    pts, nrm, tri, wts = [], [], [], []
    for t, (a, b, c) in enumerate(I):
        e = max(np.linalg.norm(P[b] - P[a]), np.linalg.norm(P[c] - P[b]), np.linalg.norm(P[a] - P[c]))
        n = int(np.clip(e * per_metre, 2, 30))
        s = np.linspace(0, 1, n + 1)
        u, v = np.meshgrid(s, s)
        m = (u + v) <= 1 + 1e-9
        W = np.c_[1 - u[m] - v[m], u[m], v[m]]
        pts.append(W @ P[[a, b, c]])
        nrm.append(W @ N[[a, b, c]])
        tri.append(np.full(len(W), t))
        wts.append(W)
    nrm = np.concatenate(nrm)
    nrm /= np.linalg.norm(nrm, axis=1, keepdims=True) + 1e-12
    return np.concatenate(pts), nrm, np.concatenate(tri), np.concatenate(wts)


class Nearest:
    """Nearest surface sample whose normal faces the query's way."""

    def __init__(self, pts, nrm, tri, wts):
        self.tree, self.nrm, self.tri, self.wts = cKDTree(pts), nrm, tri, wts

    def __call__(self, q, qn, k=24, mindot=0.3, chunk=400000):
        tri, wts = np.empty(len(q), np.int64), np.empty((len(q), 3))
        for a in range(0, len(q), chunk):
            _, idx = self.tree.query(q[a:a + chunk], k=k, workers=-1)
            ok = np.einsum("qkc,qc->qk", self.nrm[idx], qn[a:a + chunk]) > mindot
            j = idx[np.arange(len(idx)), np.where(ok.any(1), ok.argmax(1), 0)]
            tri[a:a + chunk], wts[a:a + chunk] = self.tri[j], self.wts[j]
        return tri, wts


def cmd_prepare(args):
    rl = RL26()
    game = rll4_source.RLL4(args.rll4)
    comp, bs = rl.head_model(REFERENCE_HEAD)
    P0, _N0, I0, UV0 = bm.parse_rl26(comp, bs, lod=0)
    print("averaging RL26 heads ...")
    items = [it for it in tier1_items() if it.get("sex") == "m" and it.get("team") != "m_npcs"]
    skins = []
    for it in items[::max(1, len(items) // args.rl26_heads)]:
        h = rl.head_model(it.get("modelName", it["name"]))
        if h is None:
            continue
        P, _N, _I, UV = bm.parse_rl26(*h, lod=0)
        k = uv_order(UV0, P0, UV, P) if len(P) == len(P0) else None
        if k is not None:
            Q = np.empty_like(P)
            Q[k] = P
            skins.append(Q)
    M26 = np.mean(skins, 0)
    print(f"  {len(skins)} RL26 heads")

    print("averaging RLL4 heads ...")
    heads = rll4_heads(game)
    ref4 = None
    skins4 = []
    for name, h in heads.items():
        P, UV, I = rll4_skin(game, h)
        if ref4 is None:
            ref4 = (UV, I)
        if len(UV) == len(ref4[0]) and np.array_equal(UV, ref4[0]) and np.array_equal(I, ref4[1]):
            skins4.append(P)
    M4 = np.mean(skins4, 0)
    UV4, I4 = ref4
    print(f"  {len(skins4)} RLL4 heads share the template layout")

    print("aligning ...")
    face4 = (UV4[:, 0] < 1) & (M4[:, 1] > 1.5)  # u >= 1 is the mouth interior
    src, dst = M4[face4], M26[M26[:, 1] > 1.5]
    tree = cKDTree(dst)
    s, R, T = 1.0, np.eye(3), np.zeros(3)
    for _ in range(40):
        d, k = tree.query(s * src @ R.T + T)
        keep = d < np.percentile(d, 85)
        s, R, T = similarity(dst[k[keep]], src[keep])
    d, _ = tree.query(s * src @ R.T + T)
    print(f"  scale {s:.4f}, mean gap {d.mean() * 1000:.1f} mm")

    print("corresponding vertices and texels ...")
    X4 = s * M4 @ R.T + T
    skinT = I4[(UV4[I4][:, :, 0] < 1).all(1)]
    near = Nearest(*dense_samples(X4, vnormals(X4, skinT), skinT))
    N26 = vnormals(M26, I0.astype(np.int64))
    vtri, vw = near(M26, N26)
    attr = np.zeros((TEX, TEX, 6))
    mask = np.zeros((TEX, TEX), bool)
    bk._raster(np.c_[UV0[:, 0] * TEX, (1 - UV0[:, 1]) * TEX], np.c_[M26, N26], I0.astype(np.int64), TEX, TEX,
               attr, mask, np.zeros((TEX, TEX)), False)
    q, qn = attr[mask][:, :3], attr[mask][:, 3:]
    qn /= np.linalg.norm(qn, axis=1, keepdims=True) + 1e-12
    ttri, tw = near(q, qn)
    uv4 = np.einsum("qk,qkc->qc", tw, UV4[skinT[ttri]])
    # texels used for picking a donor by skin colour: forehead and front of the neck
    sample = ((q[:, 1] > 1.70) & (q[:, 1] < 1.74) & (q[:, 2] > 0.02)) | \
             ((q[:, 1] > 1.43) & (q[:, 1] < 1.48) & (q[:, 2] > 0.0))
    os.makedirs(WORK, exist_ok=True)
    np.savez_compressed(CACHE, M26=M26, UV26=UV0, I26=I0, M4=M4, UV4=UV4, I4=I4, s=s, R=R, T=T, skinT=skinT,
                        vtri=vtri, vw=vw, mask=mask, uv4=uv4.astype(np.float32), sample=sample)
    print(f"wrote {os.path.relpath(CACHE, REPO)}")


def load_templates():
    if not os.path.exists(CACHE):
        raise SystemExit("run `build.py prepare` first")
    return dict(np.load(CACHE))


# --------------------------------------------------------------------------
# heads

def _rgb(dds):
    return np.asarray(Image.open(io.BytesIO(dds)).convert("RGB"), np.float32)


def donor_pool(rl, tpl, step):
    """[(name, guid, mean skin colour)] of stock scanned male player heads."""
    path = os.path.join(WORK, "donors.json")
    if os.path.exists(path):
        return json.load(open(path))
    mask, sample = tpl["mask"], tpl["sample"]
    pool = []
    items = [it for it in tier1_items() if it.get("sex") == "m" and it.get("team") != "m_npcs" and it["guid"] < 10000]
    for it in items[::step]:
        name = it.get("modelName", it["name"])
        if rl.entry(f"characters/heads/models/{name}/{name}.blendshapes") is None or any(
                rl.entry(f"characters/heads/textures/{name}_{k}_{lv}.texture") is None
                for k in ("col", "nrm", "mat") for lv in (1, 2, 3)):
            continue
        dds = rl.head_texture(name, "col", 3)
        if dds is None:
            continue
        img = np.asarray(Image.fromarray(_rgb(dds).astype(np.uint8)).transpose(Image.FLIP_TOP_BOTTOM)
                         .resize((TEX, TEX), Image.BILINEAR), np.float32)
        pool.append((name, it["guid"], img[mask][sample].mean(0).tolist()))
    with open(path, "w") as f:
        json.dump(pool, f)
    return pool


def _rotate(vecs, a, b):
    """Rotate each vecs[i] by the rotation taking unit a[i] to unit b[i]."""
    v = np.cross(a, b)
    c = np.einsum("ij,ij->i", a, b)[:, None]
    k = 1.0 / (1.0 + c + 1e-9)
    return vecs * c + np.cross(v, vecs) + v * np.einsum("ij,ij->i", v, vecs)[:, None] * k


def bake_head(rl, game, tpl, player, pool):
    """-> (modelcomponent, blendshapes, {"col"/"nrm"/"mat": {level: DDS}}, donor name, preview)."""
    s, R = float(tpl["s"]), tpl["R"]
    head = {"geometry": player["geometry"], "skin": None}
    recs = _rll4_records(game.bs.desc(player["component"]))
    head["skin"] = [r for r in recs if r["lod"] == 0 and r["nv"] > 1000][0]
    P4, UV4, I4 = rll4_skin(game, head)
    if not (len(UV4) == len(tpl["UV4"]) and np.array_equal(UV4, tpl["UV4"])):
        raise ValueError("RLL4 head isn't in the template layout")
    pack4 = game.pack_textures(player["pack"])
    col4 = np.asarray(pack4[f"characters/heads/textures/{player['head']}_col"].convert("RGB"), np.float32)
    SH, SW = col4.shape[:2]
    uv4 = tpl["uv4"]
    colours = bk._bilinear(col4, (uv4[:, 0] % 1) * SW, np.clip(uv4[:, 1], 0, 1) * SH)

    # donor: closest skin colour among heads in the standard RL26 layout
    tone = colours[tpl["sample"]].mean(0)
    for name, _guid, _c in sorted(pool, key=lambda p: np.linalg.norm(np.array(p[2]) - tone)):
        comp, bs = rl.head_model(name)
        Pd, _Nd, Id, UVd = bm.parse_rl26(comp, bs, lod=0)
        k = uv_order(tpl["UV26"], tpl["M26"], UVd, Pd) if len(Pd) == len(tpl["M26"]) else None
        if k is not None:
            break
    else:
        raise ValueError("no donor head in the standard layout")

    # target skin = RL26 mean + the player's deviation from the RLL4 mean
    d4 = s * (P4 - tpl["M4"]) @ R.T
    delta = np.einsum("vk,vkc->vc", tpl["vw"], d4[tpl["skinT"][tpl["vtri"]]])
    target = (tpl["M26"] + delta)[k]  # donor vertex order
    w = np.clip((Pd[:, 1] - NECK_FADE[0]) / (NECK_FADE[1] - NECK_FADE[0]), 0, 1)[:, None]
    D0 = w * (target - Pd)

    # Move every vertex of every LOD record: by the inverse-distance mean of
    # its nearest LOD0 skin vertices' moves, except eyes (UVs in tile 1, one
    # rigid move per side) and the mouth interior (one rigid move). Records
    # come in groups of LODs (lod 0, 1, ...); a group's kind is decided from
    # its LOD0 record.
    bs = bytearray(bs)
    tree = cKDTree(Pd)

    def moves(P):
        dist, nn = tree.query(P, k=6)
        w = 1.0 / (dist + 1e-4)
        return np.einsum("vk,vkc->vc", w, D0[nn]) / w.sum(1, keepdims=True)

    base = 0x2C
    preview = None
    kind = rigid = None
    for idx, lod, nv in model_records(comp):
        P, _N, I, UV = bm.parse_rl26(comp, bytes(bs), lod=idx)
        if lod == 0:
            if idx == 0:
                kind = "skin"
            elif UV[:, 0].max() > 1.0:
                kind = "eyes"
                D = moves(P)
                rigid = {side: D[np.sign(P[:, 0]) == side].mean(0) for side in (-1, 1)}
            elif P[:, 1].mean() < 1.64 and np.ptp(P[:, 0]) < 0.08:
                kind = "mouth"
                rigid = moves(P).mean(0)
            else:
                kind = "lashes"
        if kind == "eyes":
            D = np.where(P[:, :1] < 0, rigid[-1], rigid[1])
        elif kind == "mouth":
            D = np.broadcast_to(rigid, P.shape)
        else:
            D = moves(P)
        newP = P + D
        # rows: pos f32x3, packed u16 weights, normal f32x3, weights, tangent f32x3, weight + sign;
        # only the float columns are written so the weight bits stay exactly as they were
        V = np.frombuffer(bs, np.float32, 12 * nv, base).reshape(nv, 12)
        if kind == "skin":  # turn normals / tangents with the surface
            n0, n1 = vnormals(P, I), vnormals(newP, I)
            V[:, 4:7] = _rotate(V[:, 4:7].astype(np.float64), n0, n1)
            V[:, 8:11] = _rotate(V[:, 8:11].astype(np.float64), n0, n1)
        V[:, 0:3] = newP
        base += 48 * nv
        if idx == 0:
            preview = (newP, I, UV)

    # colour: donor texture with the scan's skin
    dcol = _rgb(rl.head_texture(name, "col", 1))
    up = np.asarray(Image.fromarray(dcol.astype(np.uint8)).transpose(Image.FLIP_TOP_BOTTOM).resize((TEX, TEX)),
                    np.float32).copy()
    up[tpl["mask"]] = colours
    col = Image.fromarray(up.clip(0, 255).astype(np.uint8))
    nrm = _transfer_normals(game, tpl, player, head, pack4, rl.head_texture(name, "nrm", 1), comp, bytes(bs))
    mat = _transfer_material(tpl, pack4[f"characters/heads/textures/{player['head']}_mat"],
                             rl.head_texture(name, "mat", 1))
    textures = {kind: {lv: bk._dds_bgra(img.resize((TEX >> (lv - 1),) * 2, Image.LANCZOS)) for lv in (1, 2, 3)}
                for kind, img in (("col", col), ("nrm", nrm), ("mat", mat))}
    return comp, bytes(bs), textures, name, (preview, col, (Pd, Id, UVd, dcol))


def _upright(dds):
    return np.asarray(Image.open(io.BytesIO(dds)).convert("RGBA").transpose(Image.FLIP_TOP_BOTTOM)
                      .resize((TEX, TEX)), np.float32)


def _frames(P, N, T, S, I, UV, flip_v):
    """Per-texel tangent, bitangent, normal of a mesh rasterised in its UV
    space (RL26 upright convention y = (1 - v) * H, or RLL4's as-stored y = v * H)."""
    Bt = np.cross(N, T) * S[:, None]
    attr = np.zeros((TEX, TEX, 9))
    mask = np.zeros((TEX, TEX), bool)
    y = (1 - UV[:, 1]) * TEX if flip_v else UV[:, 1] * TEX
    bk._raster(np.c_[(UV[:, 0] % 1) * TEX, y], np.c_[T, Bt, N], I, TEX, TEX, attr, mask, np.zeros((TEX, TEX)), False)
    return attr, mask


def _transfer_normals(game, tpl, player, head, pack4, donor_nrm, comp, bs):
    """The scan's normal map in the new head's tangent space. Tangent-space
    values can't be copied between the two UV layouts (their tangent frames
    point different ways), so each texel goes RLL4 tangent space -> object
    space (RLL4 mesh frames, rotated by the template alignment) -> RL26
    tangent space (the new head's frames). Conventions, found by testing all
    sign combinations against the donor's ears and nostrils (object-space
    agreement 0.80 vs 0.64 for the worst): RLL4 stores x in alpha, y in
    green, frame sign = u16 >= 0x8000; RL26 stores -x in red, -y in green,
    z in blue. The donor's map is kept outside the skin (teeth, mouth)."""
    s = head["skin"]
    vb = game.bs.data(head["geometry"])
    V4 = np.frombuffer(vb, np.float32, 12 * s["nv"], s["vo"]).reshape(-1, 12).astype(np.float64)
    S4 = np.where(np.frombuffer(vb, np.uint16, 24 * s["nv"], s["vo"]).reshape(-1, 24)[:, 23] >= 0x8000, -1.0, 1.0)
    _P4, UV4, I4 = rll4_skin(game, head)
    skin4 = I4[(UV4[I4][:, :, 0] < 1).all(1)]
    R = tpl["R"]
    f4, _m4 = _frames(None, V4[:, 4:7] @ R.T, V4[:, 8:11] @ R.T, S4, skin4, UV4, False)
    P, N, I, UV = bm.parse_rl26(comp, bs, lod=0)
    V = np.frombuffer(bs, np.float32, 12 * len(P), 0x2C).reshape(-1, 12).astype(np.float64)
    f26, _m26 = _frames(None, V[:, 4:7], V[:, 8:11], np.ones(len(P)), I, UV, True)
    mask, uv4 = tpl["mask"], tpl["uv4"]
    n4 = np.asarray(pack4[f"characters/heads/textures/{player['head']}_nrm"], np.float32)
    H4, W4 = n4.shape[:2]
    t4 = bk._bilinear(n4, (uv4[:, 0] % 1) * W4, np.clip(uv4[:, 1], 0, 1) * H4)
    x, y = t4[:, 3] / 127.5 - 1, t4[:, 1] / 127.5 - 1
    z = np.sqrt(np.clip(1 - x * x - y * y, 0, 1))
    fx = ((uv4[:, 0] % 1) * TEX).astype(int).clip(0, TEX - 1)
    fy = (np.clip(uv4[:, 1], 0, 1) * TEX).astype(int).clip(0, TEX - 1)
    a = f4[fy, fx]
    o = x[:, None] * a[:, 0:3] + y[:, None] * a[:, 3:6] + z[:, None] * a[:, 6:9]
    o /= np.linalg.norm(o, axis=1, keepdims=True) + 1e-9
    b = f26[mask]
    # keep only the scan's detail: turn it with the surface, from the RLL4
    # mesh's normal to the new head's (they differ, most near the neck seam)
    n_from = a[:, 6:9] / (np.linalg.norm(a[:, 6:9], axis=1, keepdims=True) + 1e-9)
    n_to = b[:, 6:9] / (np.linalg.norm(b[:, 6:9], axis=1, keepdims=True) + 1e-9)
    o = _rotate(o, n_from, n_to)
    n = np.c_[-np.einsum("ij,ij->i", o, b[:, 0:3]), -np.einsum("ij,ij->i", o, b[:, 3:6]),
              np.einsum("ij,ij->i", o, b[:, 6:9])]
    n[:, 2] = np.abs(n[:, 2])
    n /= np.linalg.norm(n, axis=1, keepdims=True) + 1e-9
    out = _upright(donor_nrm)
    out[mask, :3] = (n + 1) * 127.5
    return Image.fromarray(out.clip(0, 255).astype(np.uint8), "RGBA")


def _transfer_material(tpl, mat4, donor_mat):
    """The scan's material map (RLL4 and RL26 use the same channels at
    different scales), each channel matched to the donor's mean / spread on
    the skin so the values stay in RL26's range."""
    mask, uv4 = tpl["mask"], tpl["uv4"]
    m4 = np.asarray(mat4.convert("RGBA"), np.float32)
    H4, W4 = m4.shape[:2]
    t = bk._bilinear(m4, (uv4[:, 0] % 1) * W4, np.clip(uv4[:, 1], 0, 1) * H4)
    out = _upright(donor_mat)
    d = out[mask]
    t = (t - t.mean(0)) / (t.std(0) + 1e-6) * d.std(0) + d.mean(0)
    out[mask] = t
    return Image.fromarray(out.clip(0, 255).astype(np.uint8), "RGBA")


def render(P, I, UV, tex, view, size=320):
    """Orthographic textured render (tex upright, RL26 UV convention); heads face +z."""
    X, Z = (P[:, 0], P[:, 2]) if view == "front" else (P[:, 2], -P[:, 0])
    y = P[:, 1]
    span = max(np.ptp(X), np.ptp(y)) * 1.05
    px = np.c_[(X - (X.min() + X.max()) / 2) / span * size + size / 2, (y.max() - y) / span * size + size * 0.02]
    out = np.zeros((size, size, 3))
    mask = np.zeros((size, size), bool)
    bk._raster(px, np.c_[Z, UV[:, 0], 1 - UV[:, 1]], I, size, size, out, mask, np.zeros((size, size)), True)
    th, tw = tex.shape[:2]
    img = np.full((size, size, 3), 40, np.uint8)
    img[mask] = tex[(out[..., 2][mask] * th).astype(int).clip(0, th - 1),
                    ((out[..., 1][mask] % 1) * tw).astype(int).clip(0, tw - 1)][:, :3]
    return img


def head_name(player):
    return f"rll4_{player['head']}_{player['id']}"


def cmd_heads(args):
    rl = RL26()
    game = rll4_source.RLL4(args.rll4)
    tpl = load_templates()
    pool = donor_pool(rl, tpl, args.donor_step)
    print(f"{len(pool)} donor heads")
    done = json.load(open(os.path.join(WORK, "heads.json"))) if os.path.exists(os.path.join(WORK, "heads.json")) else {}
    for p in load_selection():
        if args.only and p["id"] not in args.only:
            continue
        try:
            comp, bs, textures, donor, (pv, col, (Pd, Id, UVd, dcol)) = bake_head(rl, game, tpl, p, pool)
        except ValueError as e:
            print(f"  {p['name']}: skipped ({e})")
            done.pop(str(p["id"]), None)
            continue
        out = os.path.join(WORK, head_name(p))
        os.makedirs(out, exist_ok=True)
        open(os.path.join(out, "head.modelcomponent"), "wb").write(comp)
        open(os.path.join(out, "head.blendshapes"), "wb").write(bs)
        for kind, levels in textures.items():
            for lv, dds in levels.items():
                open(os.path.join(out, f"{kind}_{lv}.dds"), "wb").write(dds)
        P, I, UV = pv
        tex = np.asarray(col)
        d = np.asarray(Image.fromarray(dcol.astype(np.uint8)).transpose(Image.FLIP_TOP_BOTTOM))
        Image.fromarray(np.concatenate([render(P, I, UV, tex, "front"), render(P, I, UV, tex, "side"),
                                        render(Pd, Id, UVd, d, "front")], 1)).save(os.path.join(out, "preview.png"))
        done[str(p["id"])] = {"name": head_name(p), "donor": donor}
        print(f"  {p['id']} {p['name']}: donor {donor}")
    with open(os.path.join(WORK, "heads.json"), "w") as f:
        json.dump(done, f, indent=1)


def cmd_sheet(args):
    from PIL import ImageDraw
    done = json.load(open(os.path.join(WORK, "heads.json")))
    tiles = []
    for p in load_selection():
        if str(p["id"]) not in done:
            continue
        im = Image.open(os.path.join(WORK, head_name(p), "preview.png"))
        im = im.crop((0, 0, im.width * 2 // 3, im.height)).resize((im.width // 3, im.height // 2))
        ImageDraw.Draw(im).text((3, 2), p["name"], fill=(255, 255, 0))
        tiles.append(im)
    cols = args.cols
    w, h = tiles[0].size
    sheet = Image.new("RGB", (w * cols, h * ((len(tiles) + cols - 1) // cols)), (20, 20, 20))
    for i, t in enumerate(tiles):
        sheet.paste(t, ((i % cols) * w, (i // cols) * h))
    sheet.save(args.out)
    print(f"wrote {args.out}")


# --------------------------------------------------------------------------
# hair

HAIR_TEMPLATE = "blakeWilson_92"  # stock tier-1 hair: one joint (Head), one material, no morphs


def hair_colours():
    """[(guid, (r, g, b))] of RL26's ItemMaps.hairColours."""
    src = open(STOCK_ASSETMAPITEMS, encoding="utf-8-sig").read()
    i = src.index("\thairColours = {")
    j = src.index("\n\t},\n", i)
    out = []
    for m in re.finditer(r"guid = (\d+),(?:(?!guid =).)*?colour = \{\s*(\d+),\s*(\d+),\s*(\d+)", src[i:j], re.S):
        out.append((int(m.group(1)), tuple(int(x) for x in m.group(2, 3, 4))))
    return out


def cmd_hair(args):
    """Bring over each player's own RLL4 hair (hair.py), unless their RLL4
    visual is explicitly bald:
      - the strand cards become the RL26 hair model (vertices closer than
        1.5 mm to the new head, or under it, are pushed out along its normal),
        drawn with the RLL4 strand textures they were made for (ported as
        rll4_<name>: colour + alpha kept, a neutral RL26-style direction map
        with the strand alpha; RL26's flat straight_short_mat);
      - the scalp cap (a painted hairline in a coverage texture) is baked into
        the head's colour texture, tinted with the hair colour.
    Hair colour: RLL4's hair_colour_r/g/b (0, 127, 255 is its unset default,
    which becomes dark brown), nearest RL26 hairColours entry."""
    import hair as hm
    rl = RL26()
    game = rll4_source.RLL4(args.rll4)
    tpl = load_templates()
    s, R, T = float(tpl["s"]), tpl["R"], tpl["T"]
    # the converted heads are the RL26 mean + the RLL4 difference, so they sit
    # off the aligned RLL4 head by the template residual; hair moves with it
    X4 = s * tpl["M4"] @ R.T + T
    resid = tpl["M26"] - np.einsum("vk,vkc->vc", tpl["vw"], X4[tpl["skinT"][tpl["vtri"]]])
    rtree = cKDTree(tpl["M26"])
    base = f"characters/hair/models/{HAIR_TEMPLATE}/{HAIR_TEMPLATE}"
    tcomp, tbs = rl.read(base + ".modelcomponent"), rl.read(base + ".blendshapes")
    colours = hair_colours()
    shared = game.pack_textures(hm.rll4_entry(game, "characters/hair/textures/shared.texpack"))
    r4 = bigant_db.load(game.m3mp_file("defaultdata/defaultdata_players")).by_id()
    done = json.load(open(os.path.join(WORK, "heads.json")))
    texdir = os.path.join(WORK, "hairtex")
    os.makedirs(texdir, exist_ok=True)

    def to_rl26(P):
        P = s * P @ R.T + T
        dist, nn = rtree.query(P, k=8)
        w = 1.0 / (dist + 1e-3)
        return P + np.einsum("vk,vkc->vc", w, resid[nn]) / w.sum(1, keepdims=True)

    out = {}
    for p in load_selection():
        if str(p["id"]) not in done or (args.only and p["id"] not in args.only):
            continue
        d = os.path.join(WORK, done[str(p["id"])]["name"])
        vis = hm.rll4_visual(r4[p["rll4_id"]]["visual"])
        rgb = [vis.get(hm.option_hash(f"hair_colour_{c}")) for c in "rgb"]
        if None in rgb or rgb == [0, 127, 255]:
            rgb = [55, 40, 30]
        guid, hair_rgb = min(colours, key=lambda gc: sum((a - b) ** 2 for a, b in zip(gc[1], rgb)))
        info = {"hair": False, "colour": guid}
        for f in ("hair.modelcomponent", "hair.blendshapes"):
            if os.path.exists(os.path.join(d, f)):
                os.remove(os.path.join(d, f))
        head = {"geometry": p["geometry"],
                "skin": [r for r in _rll4_records(game.bs.desc(p["component"])) if r["lod"] == 0 and r["nv"] > 1000][0]}
        P4, UV4, I4 = rll4_skin(game, head)
        got = None if vis.get(hm.option_hash("hairTop")) == 0 else hm.rll4_hair(game, p["head"], P4)
        comp, hbs = open(os.path.join(d, "head.modelcomponent"), "rb").read(), open(os.path.join(d, "head.blendshapes"), "rb").read()
        Ph, _Nh, Ih, _UVh = bm.parse_rl26(comp, hbs, lod=0)
        Nh = vnormals(Ph, Ih)
        htree = cKDTree(Ph)
        if got:
            cards, cap, tex = got
            if cards and tex["col"]:
                conv = []
                for lod in sorted(cards)[:5]:
                    V, S, UV, I = cards[lod]
                    P = to_rl26(V[:, :3])
                    _, k = htree.query(P)
                    gap = np.einsum("ij,ij->i", P - Ph[k], Nh[k])
                    P = P + np.maximum(0.0015 - gap, 0)[:, None] * Nh[k]
                    conv.append((P, V[:, 4:7] @ R.T, V[:, 8:11] @ R.T, S, UV, I))
                while len(conv) < 5:
                    conv.append(conv[-1])
                hc, hb = hm.build_rl26_hair(tcomp, tbs, conv)
                open(os.path.join(d, "hair.modelcomponent"), "wb").write(hc)
                open(os.path.join(d, "hair.blendshapes"), "wb").write(hb)
                info.update(hair=True, col=f"rll4_{tex['col']}", dir=f"rll4_{tex['col'][:-4]}_dir")
                _port_strand_texture(shared, tex["col"], texdir)
            if cap is not None and tex["cap_col"]:
                _bake_cap(d, tpl, P4, UV4, I4, cap, shared[f"characters/hair/textures/{tex['cap_col']}"], hair_rgb)
                info["cap"] = tex["cap_col"]
        out[str(p["id"])] = info
        print(f"  {p['name']}: {'cards ' + info['col'] if info['hair'] else 'no cards'}"
              f"{', cap ' + info['cap'] if 'cap' in info else ''}, colour {guid}")
    path = os.path.join(WORK, "hair.json")
    old = json.load(open(path)) if os.path.exists(path) else {}
    old.update(out)
    with open(path, "w") as f:
        json.dump(old, f, indent=1)


HAIR_DIR_RGB = (186, 255, 184)  # RL26 straight_short_dir's average (flow along the strand)


def _port_strand_texture(shared, col_name, texdir):
    """rll4_<col>.dds (RLL4 strand alpha, black RGB) and rll4_<name>_dir.dds
    (neutral direction, same alpha), uncompressed BGRA, stored upright like
    RLL4 samples them (y = v * H) - RL26 hair UVs are passed through unchanged."""
    out_col = os.path.join(texdir, f"rll4_{col_name}.dds")
    if os.path.exists(out_col):
        return
    a = np.asarray(shared[f"characters/hair/textures/{col_name}"].convert("RGBA")).copy()
    # RLL4 keeps per-strand masks in RGB (green/orange), which RL26 shows as
    # colour (green hair); RL26's strand textures have black RGB and the
    # strand shape in alpha only, the colour coming from hairColour1/2
    a[..., :3] = 0
    im = Image.fromarray(a, "RGBA")
    dirimg = np.zeros_like(a)
    dirimg[..., :3] = HAIR_DIR_RGB
    dirimg[..., 3] = a[..., 3]
    # _dds_bgra flips (it expects upright RL26 images); flip first so the stored
    # rows match RLL4's as-stored layout
    open(out_col, "wb").write(bk._dds_bgra(im.transpose(Image.FLIP_TOP_BOTTOM)))
    open(os.path.join(texdir, f"rll4_{col_name[:-4]}_dir.dds"), "wb").write(
        bk._dds_bgra(Image.fromarray(dirimg, "RGBA").transpose(Image.FLIP_TOP_BOTTOM)))


def _bake_cap(d, tpl, P4, UV4, I4, cap, cap_tex, hair_rgb, strength=0.4):
    """Paint the RLL4 scalp cap into the head's colour texture: each skin
    texel's RLL4 head point -> nearest cap point (within 8 mm) -> cap UV ->
    coverage (alpha) and shade (brightest channel), tinted with the hair
    colour. The unbaked colour is kept as col_base.png so re-runs don't stack."""
    base = os.path.join(d, "col_base.png")
    if not os.path.exists(base):
        dds = open(os.path.join(d, "col_1.dds"), "rb").read()
        Image.open(io.BytesIO(dds)).convert("RGB").transpose(Image.FLIP_TOP_BOTTOM).save(base)
    col = np.asarray(Image.open(base).convert("RGB"), np.float32).copy()
    # 3D point on the RLL4 head for every RL26 skin texel (RLL4 UVs as stored: y = v * H)
    W = 1024
    attr = np.zeros((W, W, 3))
    m = np.zeros((W, W), bool)
    skin = I4[(UV4[I4][:, :, 0] < 1).all(1)]
    bk._raster(np.c_[(UV4[:, 0] % 1) * W, UV4[:, 1] * W], P4, skin, W, W, attr, m, np.zeros((W, W)), False)
    uv4 = tpl["uv4"]
    q = attr[(np.clip(uv4[:, 1], 0, 1) * W).astype(int).clip(0, W - 1), ((uv4[:, 0] % 1) * W).astype(int).clip(0, W - 1)]
    V, _S, UVc, Ic = cap
    Pc = V[:, :3]
    pts, _nrm, tri, wts = dense_samples(Pc, vnormals(Pc, Ic), Ic, per_metre=600)
    uvs = np.einsum("qk,qkc->qc", wts, UVc[Ic[tri]])
    dist, j = cKDTree(pts).query(q)
    t = np.asarray(cap_tex.convert("RGBA"), np.float32)
    H, Wt = t.shape[:2]
    smp = bk._bilinear(t, (uvs[j, 0] % 1) * Wt, np.clip(uvs[j, 1], 0, 1) * H)
    a = smp[:, 3] / 255.0 * (dist < 0.008) * strength
    shade = smp[:, :3].max(1) / 255.0
    mask = tpl["mask"]
    cur = col[mask]
    # the scans already carry painted hair: keep their detail (luminance) and
    # only pull its tone toward the hair colour where the cap has coverage
    lum = cur.mean(1, keepdims=True) / max(float(np.mean(hair_rgb)), 1.0)
    paint = np.array(hair_rgb, np.float32)[None, :] * np.clip(lum, 0.3, 1.2) * (0.7 + 0.3 * shade)[:, None]
    col[mask] = cur * (1 - a[:, None]) + paint * a[:, None]
    img = Image.fromarray(col.clip(0, 255).astype(np.uint8))
    for lv in (1, 2, 3):
        open(os.path.join(d, f"col_{lv}.dds"), "wb").write(bk._dds_bgra(img.resize((TEX >> (lv - 1),) * 2, Image.LANCZOS)))


# --------------------------------------------------------------------------
# generate: player records + Lua

LUA_BLOCK = """
-- rll4-legacy-players: tier-1 head items for the face scans converted from
-- Rugby League Live 4 (generated by mods/rll4-legacy-players/build.py - edit
-- that, not this block). assetmap imports this file (after
-- assetmapitems) before the native asset map reads ItemMaps, so the items
-- are added to tier1head and to the texture lists assetmapitems built from it.
do
\tlocal ItemMaps = import("design.characters.assetmapitems").ItemMaps

\tlocal function add(mapName, item)
\t\tlocal map = ItemMaps[mapName]

\t\tif map.item_setup_lookup[item.guid] ~= nil or map.item_setup_lookup[item.name] ~= nil then
\t\t\treturn
\t\tend

\t\ttable.insert(map.item_setup, item)

\t\tmap.item_setup_lookup[item.guid] = item
\t\tmap.item_setup_lookup[item.name] = item
\tend

\t-- name-only items (texture lists): no guid, lookup by name if the map has one
\tlocal function addNamed(mapName, item)
\t\tlocal map = ItemMaps[mapName]
\t\tlocal lookup = map.item_setup_lookup

\t\tif lookup then
\t\t\tif lookup[item.name] ~= nil then
\t\t\t\treturn
\t\t\tend

\t\t\tlookup[item.name] = item
\t\telse
\t\t\tfor _, existing in ipairs(map.item_setup) do
\t\t\t\tif existing.name == item.name then
\t\t\t\t\treturn
\t\t\t\tend
\t\t\tend
\t\tend

\t\ttable.insert(map.item_setup, item)
\tend

\tlocal heads = {
%s
\t}

\tfor _, head in ipairs(heads) do
\t\tadd("tier1head", {
\t\t\tguid = head[1],
\t\t\tname = head[2],
\t\t\tsex = "m",
\t\t\tteam = "rll4",
\t\t\twrinkleConfig = "tier1_head_male"
\t\t})
\t\tadd("tier1head_textures_col", { guid = head[1], name = head[2] .. "_col", blend = "creator_copy_rgb" })
\t\tadd("tier1head_textures_mat", { guid = head[1], name = head[2] .. "_mat", blend = "creator_overlay_mat" })
\t\tadd("tier1head_textures_nrm", { guid = head[1], name = head[2] .. "_nrm", blend = "creator_copy_rgb" })

\t\t-- a tier-1 head's hair is always hairTop item (head guid + 1000), see
\t\t-- assetmap's hairTop filename; the model is the player's RLL4 strand
\t\t-- cards, drawn with the RLL4 strand texture they were made for
\t\tif head[3] then
\t\t\taddNamed("hairColMap_textures", { name = head[3], blend = "creator_copy" })
\t\t\taddNamed("hairDirMap_textures", { name = head[4], blend = "creator_copy" })
\t\t\tadd("hairTop", {
\t\t\t\tguid = head[1] + 1000,
\t\t\t\tname = head[2],
\t\t\t\ttier1 = true,
\t\t\t\tcolTexture = head[3],
\t\t\t\tmatTexture = "straight_short_mat",
\t\t\t\tdirTexture = head[4],
\t\t\t\tpermutations = {
\t\t\t\t\thairGear = "",
\t\t\t\t\tsex = ""
\t\t\t\t}
\t\t\t})
\t\tend
\tend
end
"""


def _slider(coef, x):
    return int(np.clip(round(coef[0] * x + coef[1]), 0, 255))


def cmd_generate(args):
    game = rll4_source.RLL4(args.rll4)
    rl = RL26()
    r4 = bigant_db.load(game.m3mp_file("defaultdata/defaultdata_players")).by_id()
    r26 = rl.players()
    fields26 = set(bigant_db.field_names(r26))
    by_head = {}
    for rec in r26.records:
        try:
            by_head.setdefault(pn.visual_get(bytearray(rec["visual"]), "head")[0], rec)
        except KeyError:
            pass
    done = json.load(open(os.path.join(WORK, "heads.json")))
    pool = {name: guid for name, guid, _ in json.load(open(os.path.join(WORK, "donors.json")))}
    hair_path = os.path.join(WORK, "hair.json")
    hairs = json.load(open(hair_path)) if os.path.exists(hair_path) else {}
    os.makedirs(os.path.join(PLAYERS_DIR, "visuals"), exist_ok=True)
    for d in (PLAYERS_DIR, os.path.join(PLAYERS_DIR, "visuals")):
        for f in os.listdir(d):
            if f.endswith((".json", ".visual")):
                os.remove(os.path.join(d, f))
    # The native loader aborts at boot on a player id much past the record
    # count (tested 2026-10-26: one extra record boots at id 3950, crashes at
    # 3999 / 4090 / 10002; 177 extra records at 3902-4078 boot), so players
    # take the next ids after the highest stock one. Heads keep guid p["id"].
    next_id = max(r26.by_id()) + 1
    rows = []
    for p in load_selection():
        if str(p["id"]) not in done:
            continue
        pid = next_id
        next_id += 1
        src = r4[p["rll4_id"]]["tables"][0]
        rec = {"id": pid, "licensed": 1, "hidden": 0, "photogrammetryStatus": 2, "contractExpiry": 2026}
        for f in COPY_FIELDS:
            if src.get(f) is not None:
                rec[RENAME.get(f, f)] = src[f]
        for f in ("countryOfBirth", "representativeCountry"):
            rec[f] = COUNTRY.get(src.get(f, 0), 0)
        if "birthYear" in rec:
            rec["age"] = 2025 - rec["birthYear"]
        rec = {k: v for k, v in rec.items() if k in fields26}
        donor_rec = by_head[pool[done[str(p["id"])]["donor"]]]
        visual = bytearray(donor_rec["visual"])
        pn.visual_set(visual, "head", p["id"])
        for opt in CLEAR_VISUAL:
            try:
                pn.visual_set(visual, opt, 0)
            except KeyError:
                pass
        hair_info = hairs.get(str(p["id"]), {})
        if hair_info.get("hair") and pn.visual_get(visual, "hairTop")[0] == 0:
            pn.visual_set(visual, "hairTop", 20)  # bald donor: borrow shaved03_fade's (straight_short) textures
        if hair_info.get("colour") is not None:
            for opt in ("hairColour1", "hairColour2"):
                try:
                    pn.visual_set(visual, opt, hair_info["colour"])
                except KeyError:
                    pass
        if "height" in rec:
            pn.visual_set(visual, "height", _slider(HEIGHT_SLIDER, rec["height"]))
        if "weight" in rec:
            pn.visual_set(visual, "weight", _slider(WEIGHT_SLIDER, rec["weight"]))
        label = re.sub(r"[^A-Za-z]", "", src["surname"])
        vname = f"visuals/{pid:06d}.visual"
        open(os.path.join(PLAYERS_DIR, vname), "wb").write(visual)
        with open(os.path.join(PLAYERS_DIR, f"{pid:06d}_{label}.json"), "w") as f:
            json.dump({"new": True, "players": rec, "StandardMatch": {}, "Nines": {}, "visual": vname}, f, indent=1)
            f.write("\n")
        tex = f'"{hair_info["col"]}", "{hair_info["dir"]}"' if hair_info.get("hair") and "col" in hair_info else "nil, nil"
        rows.append(f'\t\t{{ {p["id"]}, "{done[str(p["id"])]["name"]}", {tex} }}, -- {p["name"]}')
    stock = open(STOCK_LUA, encoding="utf-8-sig").read().rstrip("\n")
    lua_path = os.path.join(MOD, "src", "script-game", *LUA_REL.split("/"))
    os.makedirs(os.path.dirname(lua_path), exist_ok=True)
    with open(lua_path, "w", encoding="ascii", newline="\n") as f:
        f.write(stock + "\n" + LUA_BLOCK % "\n".join(rows))
    print(f"{len(rows)} players -> {os.path.relpath(PLAYERS_DIR, REPO)}, {os.path.relpath(lua_path, REPO)}")


# --------------------------------------------------------------------------
# install

def _head_entries(p, done):
    """[(logical path, file in WORK)] of one head's 12 new entries. Besides
    the model and textures, every tier-1 head needs a helper-joint offsets
    file (characters/helperjoints/<name>.hjoffsets, compiled face-rig joint
    offsets; loading the player model aborts without it) - the donor's is
    used, since the head is built on the donor's rig."""
    n = done[str(p["id"])]["name"]
    d = os.path.join(WORK, n)
    out = [(f"characters/heads/models/{n}/{n}.modelcomponent", os.path.join(d, "head.modelcomponent")),
           (f"characters/heads/models/{n}/{n}.blendshapes", os.path.join(d, "head.blendshapes")),
           (f"characters/helperjoints/{n}.hjoffsets", os.path.join(d, "head.hjoffsets"))]
    for kind in ("col", "nrm", "mat"):
        for lv in (1, 2, 3):
            out.append((f"characters/heads/textures/{n}_{kind}_{lv}.texture", os.path.join(d, f"{kind}_{lv}.dds")))
    if os.path.exists(os.path.join(d, "hair.modelcomponent")):
        out += [(f"characters/hair/models/{n}/{n}.{ext}", os.path.join(d, f"hair.{ext}"))
                for ext in ("modelcomponent", "blendshapes")]
    return out


def _model_blob(raw):
    """Character model entries are a main part only (stock ones zstd-framed;
    stored raw here, which the index allows: main stored == main size)."""
    return raw, (len(raw), len(raw), 0, 0)


def cmd_install(args):
    import club_icons
    done = json.load(open(os.path.join(WORK, "heads.json")))
    data, count, hash_off, _ = pack.read_index(args.blobset)
    present = set(add_entries.load_hashes(data, count, hash_off))
    rl = RL26(args.blobset)
    for p in load_selection():
        if str(p["id"]) not in done:
            continue
        hj = os.path.join(WORK, done[str(p["id"])]["name"], "head.hjoffsets")
        if not os.path.exists(hj):
            donor = done[str(p["id"])]["donor"]
            raw = rl.read(f"characters/helperjoints/{donor}.hjoffsets")
            if raw is None:
                raise SystemExit(f"donor {donor} has no helper-joint offsets file")
            open(hj, "wb").write(raw)
        for path, src in _head_entries(p, done):
            if args.hair_only and "/hair/models/" not in path:
                continue
            if not args.replace and add_entries.path_hash(path) in present:
                continue  # added by an earlier (interrupted) run
            raw = open(src, "rb").read()
            if path.endswith(".texture"):
                blob, sizes = club_icons.make_blob(path, raw)
            else:
                blob, sizes = _model_blob(raw)
            add_entries.add_entry(args.blobset, path, blob, sizes, f"rll4-legacy-players {p['name']}",
                                  args.confirm, replace=args.replace)
    texdir = os.path.join(WORK, "hairtex")
    for f in sorted(os.listdir(texdir)) if os.path.isdir(texdir) else []:
        path = f"characters/hair/textures/{f[:-4]}.texture"
        if not args.replace and add_entries.path_hash(path) in present:
            continue
        blob, sizes = club_icons.make_blob(path, open(os.path.join(texdir, f), "rb").read())
        add_entries.add_entry(args.blobset, path, blob, sizes, "rll4-legacy-players RLL4 strand texture",
                              args.confirm, replace=args.replace)
    if not args.confirm:
        print("dry run - pass --confirm to write (close the game first)")


TEXSRC_PATH = "characters/player/global.texsrc"


def cmd_texsrc(args):
    """Append every new head texture to the LIVE characters/player/global.texsrc
    (run after rll4-legacy-kits' texsrc, which rebuilds it from stock)."""
    ce.load_index(args.blobset)
    data, count, hash_off, _ = pack.read_index(args.blobset)
    entry = add_entries.find_entry(data, count, hash_off, TEXSRC_PATH)
    raw = ce.read_blob_full(args.blobset, entry)[0]
    live = struct.unpack_from("<I", raw, 0)[0]
    if len(raw) != 4 + 32 * live:
        raise SystemExit(f"{TEXSRC_PATH} (entry {entry}) isn't the expected record table")
    known = set(struct.unpack_from(f"<{live * 8}I", raw, 4)[0::8])
    done = json.load(open(os.path.join(WORK, "heads.json")))
    records = []
    for p in load_selection():
        if str(p["id"]) not in done:
            continue
        for kind in ("col", "nrm", "mat"):
            for lv in (1, 2, 3):
                size = TEX >> (lv - 1)
                key = bk._fnv1a32(f"characters/heads/textures/{done[str(p['id'])]['name']}_{kind}_{lv}")
                if key not in known:
                    records.append(struct.pack("<8I", key, 0, 0, 0, size, size, size, size))
    print(f"{TEXSRC_PATH} (entry {entry}): {live} live records, {len(records)} to add")
    if not records:
        return
    out = os.path.join(WORK, "global.texsrc")
    with open(out, "wb") as f:
        f.write(struct.pack("<I", live + len(records)) + raw[4:] + b"".join(records))
    if not args.confirm:
        print("dry run - pass --confirm to install (close the game first)")
        return
    if os.path.exists(pack.backup_meta_path(entry)):
        pack.do_restore(args.blobset, entry)  # keeps the one stock backup; `out` already has the live records
    pack.do_install(args.blobset, entry, out, True)
    print(f"installed entry {entry} (undo: python tools/pack.py restore --entry {entry})")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--rll4", help="Rugby League Live 4 install folder (default: found via Steam)")
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("select").set_defaults(func=cmd_select)
    p = sub.add_parser("prepare")
    p.add_argument("--rl26-heads", type=int, default=80, help="RL26 heads averaged for the template")
    p.set_defaults(func=cmd_prepare)
    p = sub.add_parser("heads")
    p.add_argument("--only", nargs="*", type=int, help="new player ids")
    p.add_argument("--donor-step", type=int, default=3, help="use every Nth stock scanned head as a donor candidate")
    p.set_defaults(func=cmd_heads)
    p = sub.add_parser("sheet")
    p.add_argument("--out", default=os.path.join(WORK, "sheet.png"))
    p.add_argument("--cols", type=int, default=8)
    p.set_defaults(func=cmd_sheet)
    p = sub.add_parser("hair")
    p.add_argument("--only", nargs="*", type=int, help="new player ids (head guids)")
    p.set_defaults(func=cmd_hair)
    sub.add_parser("generate").set_defaults(func=cmd_generate)
    p = sub.add_parser("install")
    p.add_argument("--blobset", default=pack.BLOBSET_PATH)
    p.add_argument("--replace", action="store_true")
    p.add_argument("--hair-only", action="store_true", help="only the hair model entries")
    p.add_argument("--confirm", action="store_true")
    p.set_defaults(func=cmd_install)
    p = sub.add_parser("texsrc")
    p.add_argument("--blobset", default=pack.BLOBSET_PATH)
    p.add_argument("--confirm", action="store_true")
    p.set_defaults(func=cmd_texsrc)
    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    sys.exit(main())
