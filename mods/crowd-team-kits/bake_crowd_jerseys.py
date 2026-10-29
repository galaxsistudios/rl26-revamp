#!/usr/bin/env python3
"""
bake_crowd_jerseys.py - make crowd copies of jerseys that only exist as
player textures (2026 kits, alternates, rll4-legacy-kits, ...), so
crowd-team-kits can dress fans in them.

The crowd t-shirt mesh has its own UV layout: a crowd jersey is a 1024x1024
DXT1 texture with mips at crowd/characters/textures/<name>.texture, a re-bake
of the player texture (characters/uniforms/textures/<name>_1/_2, raglan
layout) with the gaps between UV islands smeared. Only the 2025 home/away
jerseys ship one.

Rather than decoding the crowd mesh, `learn` derives the texel mapping from
the ~146 jerseys that exist in both layouts: each crowd texel is matched to
the player texel whose colours agree across all of them (PCA + KD-tree at
low resolution, then a local search at full resolution). Texels the mapping
predicts well form the UV islands (the mask); everything else is padding,
filled by smearing the nearest island colour outward as the stock bakes do.
On held-out jerseys the bake is within ~4/255 of the real crowd copy inside
the islands. The result is saved next to this script (crowd_tshirt_map.npz).

`bake` applies it to every men's top a club uses that has a player texture
but no crowd copy (skipping flat, tint-only textures), writes previews to
_build/crowd-team-kits/ (reused by later runs unless --rebake), and with
--confirm appends the textures as new blobset entries (tools/add_entries.py
bookkeeping, so `add_entries.py remove-all` undoes them).

`register` then adds them to the crowd texture table (entry 39871). The crowd
only loads textures listed there and aborts the match load on any other name,
so an appended texture is unusable until it's registered. Then rerun
generate.py (which only uses textures that are both present and registered)
and rebuild entry 39959. Women's tops are skipped: the crowd
dresses women's clubs in the men's jerseys, like the stock data does.

    python mods\\crowd-team-kits\\bake_crowd_jerseys.py learn
    python mods\\crowd-team-kits\\bake_crowd_jerseys.py bake [--only NAME ...]
    python mods\\crowd-team-kits\\bake_crowd_jerseys.py bake --confirm      (game closed)
    python mods\\crowd-team-kits\\bake_crowd_jerseys.py register --confirm  (game closed)
"""

import argparse
import csv
import io
import os
import re
import struct
import sys

import numpy as np
from PIL import Image
from scipy import ndimage as ndi
from scipy.spatial import cKDTree

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, "tools"))
sys.path.insert(0, HERE)
import add_entries as ae  # noqa: E402
import classify_entries as ce  # noqa: E402
import club_icons  # noqa: E402
import extract_textures as et  # noqa: E402
import generate  # noqa: E402
import pack  # noqa: E402
import entries  # noqa: E402

MAP_PATH = os.path.join(HERE, "crowd_tshirt_map.npz")
WORK = os.path.join(ROOT, "_build", "crowd-team-kits")
ENTRY_INDEX = os.path.join(ROOT, "manifests", "entry_index_1.0.5887.csv")  # only its texture paths are used
STOCK_JERSEYS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "stock_crowd_jerseys.txt")  # fallback
CROWD_SIZE = 1024             # crowd jersey textures are 1024x1024
PLAYER_SIZE = (1024, 512)     # player _2 textures (2048x1024), box-downsampled to this
COARSE_CROWD, COARSE_PLAYER = (256, 256), (512, 256)
PCA_COARSE, PCA_FINE = 32, 48
SEARCH_RADIUS = 5             # full-res search window around the coarse match, in player texels
MASK_ERROR = 12               # mean abs error (0-255) below which a texel counts as on the mesh
HOLDOUT = 20
TEXTURE_TABLE_ENTRY = entries.index_of("crowd-textureinfo")  # crowd texture info table (1.0.5887: 39871)
TEXTURE_TABLE_VERSION = 8


def crowd_path(name):
    return f"crowd/characters/textures/{name}.texture"


def player_path(name):
    return f"characters/uniforms/textures/{name}_2.texture"


class Index:
    """Live blobset index, looked up by logical path (stock and appended entries alike)."""

    def __init__(self):
        ce.load_index(pack.BLOBSET_PATH)
        data, files_count, hash_off, _size_off = pack.read_index(pack.BLOBSET_PATH)
        self.entries = {h: i for i, h in enumerate(ae.load_hashes(data, files_count, hash_off))}

    def entry(self, logical_path):
        return self.entries.get(ae.path_hash(logical_path))

    def texture(self, logical_path):
        raw = ce.read_blob_full(pack.BLOBSET_PATH, self.entry(logical_path))[0]
        _path, dds, _raw_path, _w, _h, _type = et.parse_mini_txpk(raw)
        return dds

    def image(self, logical_path):
        return Image.open(io.BytesIO(self.texture(logical_path))).convert("RGB")

    def player(self, name):
        return np.asarray(self.image(player_path(name)).resize(PLAYER_SIZE, Image.BOX))


# ---- learn -----------------------------------------------------------------

def load_pairs(index):
    """Every shipped men's crowd jersey with its player texture."""
    if os.path.exists(ENTRY_INDEX):
        with open(ENTRY_INDEX, newline="") as f:
            names = sorted({m.group(1) for row in csv.reader(f) if len(row) > 4
                            for m in [re.match(r"crowd/characters/textures/(m_top_\w+_col)\.pc\.dds$", row[4])] if m})
    else:
        names = [n.strip() for n in open(STOCK_JERSEYS) if n.strip() and not n.startswith("#")]
    names = [n for n in names if index.entry(crowd_path(n)) is not None and index.entry(player_path(n)) is not None]
    print(f"loading {len(names)} crowd/player jersey pairs...")
    crowd = np.stack([np.asarray(index.image(crowd_path(n))) for n in names])
    player = np.stack([index.player(n) for n in names])
    return names, crowd, player


def _pca(samples, dims):
    mean = samples.mean(0)
    _, _, vt = np.linalg.svd(samples - mean, full_matrices=False)
    return mean, vt[:dims].T.astype(np.float32)


def _project(pixels, mean, basis, chunk=65536):
    out = np.empty((len(pixels), basis.shape[1]), np.float32)
    for i in range(0, len(pixels), chunk):
        out[i:i + chunk] = (pixels[i:i + chunk].astype(np.float32) - mean) @ basis
    return out


def _texels(stack):
    """(k, h, w, 3) -> (h*w, k*3): each texel's colours across all jerseys."""
    k, h, w, _ = stack.shape
    return stack.transpose(1, 2, 0, 3).reshape(h * w, k * 3)


def learn_map(crowd, player, rng):
    """Crowd texel -> player texel (x, y in PLAYER_SIZE space), 1024x1024x2."""
    def down(stack, size):
        return np.stack([np.asarray(Image.fromarray(a).resize(size, Image.BOX)) for a in stack]).astype(np.float32)

    # coarse: nearest neighbour over the whole player texture
    dc, dp = _texels(down(crowd, COARSE_CROWD)), _texels(down(player, COARSE_PLAYER))
    mean, basis = _pca(dp[rng.choice(len(dp), 20000, replace=False)], PCA_COARSE)
    _, idx = cKDTree(_project(dp, mean, basis)).query(_project(dc, mean, basis), workers=-1)
    cy, cx = np.divmod(idx, COARSE_PLAYER[0])

    # fine: search a window around the scaled-up coarse match
    pw, ph = PLAYER_SIZE
    fc, fp = _texels(crowd), _texels(player)
    mean, basis = _pca(fp[rng.choice(len(fp), 30000, replace=False)].astype(np.float32), PCA_FINE)
    qc, qp = _project(fc, mean, basis), _project(fp, mean, basis).reshape(ph, pw, -1)
    up = CROWD_SIZE // COARSE_CROWD[0]
    sx, sy = pw // COARSE_PLAYER[0], ph // COARSE_PLAYER[1]
    ix = np.repeat(np.repeat(cx.reshape(COARSE_CROWD) * sx + sx // 2, up, 0), up, 1).reshape(-1)
    iy = np.repeat(np.repeat(cy.reshape(COARSE_CROWD) * sy + sy // 2, up, 0), up, 1).reshape(-1)
    n = CROWD_SIZE * CROWD_SIZE
    best = np.full(n, np.inf, np.float32)
    bx, by = ix.copy(), iy.copy()
    for dy in range(-SEARCH_RADIUS, SEARCH_RADIUS + 1):
        for dx in range(-SEARCH_RADIUS, SEARCH_RADIUS + 1):
            x, y = np.clip(ix + dx, 0, pw - 1), np.clip(iy + dy, 0, ph - 1)
            d = np.empty(n, np.float32)
            for i in range(0, n, 131072):
                s = slice(i, i + 131072)
                diff = qp[y[s], x[s]] - qc[s]
                d[s] = np.einsum("ij,ij->i", diff, diff)
            better = d < best
            best[better], bx[better], by[better] = d[better], x[better], y[better]
    m = np.stack([bx, by], -1).reshape(CROWD_SIZE, CROWD_SIZE, 2)
    return np.stack([ndi.median_filter(m[..., 0], 3), ndi.median_filter(m[..., 1], 3)], -1)


def learn_mask(mapping, crowd, player):
    """UV islands: texels where the mapping reproduces the training jerseys."""
    err = np.zeros(mapping.shape[:2], np.float32)
    for c, p in zip(crowd, player):
        err += np.abs(p[mapping[..., 1], mapping[..., 0]].astype(np.int16) - c).mean(-1)
    mask = ndi.median_filter(err / len(crowd), 5) < MASK_ERROR
    mask = ndi.binary_opening(mask, iterations=2)
    labels, count = ndi.label(mask)
    sizes = ndi.sum(mask, labels, range(1, count + 1))
    mask = np.isin(labels, 1 + np.nonzero(sizes > 5000)[0])
    return ndi.binary_fill_holes(ndi.binary_closing(mask, iterations=3))


def make_baker(mapping, mask):
    _, (fy, fx) = ndi.distance_transform_edt(~mask, return_indices=True)

    def bake(player):
        img = player[mapping[..., 1], mapping[..., 0]][fy, fx].astype(np.float32)
        blur = ndi.gaussian_filter(img, (6, 6, 0))
        img[~mask] = blur[~mask]
        return img.clip(0, 255).astype(np.uint8)
    return bake


def cmd_learn(args):
    index = Index()
    names, crowd, player = load_pairs(index)
    rng = np.random.default_rng(0)
    order = rng.permutation(len(names))
    test, train = order[:HOLDOUT], order[HOLDOUT:]

    print(f"learning on {len(train)}, testing on {len(test)} held-out jerseys...")
    mapping = learn_map(crowd[train], player[train], rng)
    mask = learn_mask(mapping, crowd[train], player[train])
    bake = make_baker(mapping, mask)
    inside = [np.abs(bake(player[i]).astype(np.int16) - crowd[i]).mean(-1)[mask].mean() for i in test]
    print(f"held-out error inside the UV islands: mean {np.mean(inside):.2f}, worst {np.max(inside):.2f} (0-255)")

    print(f"final map from all {len(names)} jerseys...")
    mapping = learn_map(crowd, player, rng)
    mask = learn_mask(mapping, crowd, player)
    np.savez_compressed(MAP_PATH, map=mapping.astype(np.uint16), mask=mask)
    if os.path.isdir(WORK):  # previews double as the bake cache; they're stale now
        for fn in os.listdir(WORK):
            if fn.endswith(".png"):
                os.remove(os.path.join(WORK, fn))
    print(f"islands {ndi.label(mask)[1]}, coverage {mask.mean():.3f} -> {os.path.relpath(MAP_PATH, ROOT)}")


# ---- bake ------------------------------------------------------------------

def dxt1_with_mips(img, header):
    """DXT1 DDS with a full mip chain, using a stock crowd jersey's header."""
    payload, level = bytearray(), img
    while True:
        buf = io.BytesIO()
        level.save(buf, "DDS", pixel_format="DXT1")
        payload += buf.getvalue()[128:]
        if level.size == (1, 1):
            break
        level = level.resize((max(1, level.width // 2), max(1, level.height // 2)), Image.BOX)
    return header + bytes(payload)


def wanted_textures():
    """Men's tops used by any club's kits."""
    tops = generate.load_top_textures()
    names = set()
    for _club_id, _name, kits in generate.read_kits(generate.load_clubs(None)):
        for _kit_name, guid in kits:
            tex = tops.get(guid)
            if tex and re.match(r"^m_top_.+_col$", tex):
                names.add(tex)
    return sorted(names)


def cmd_bake(args):
    if not os.path.exists(MAP_PATH):
        sys.exit(f"{os.path.relpath(MAP_PATH, ROOT)} missing - run `learn` first")
    z = np.load(MAP_PATH)
    bake = make_baker(z["map"].astype(np.int64), z["mask"])
    index = Index()
    stock = index.texture(crowd_path("m_top_broncos_nrl_home_25_col"))
    header = stock[:128]
    if stock[84:88] != b"DXT1" or struct.unpack_from("<3I", stock, 12)[:2] != (CROWD_SIZE, CROWD_SIZE):
        sys.exit("unexpected stock crowd jersey format")

    added = {e["path"] for e in (ae.load_registry() or {"entries": []})["entries"]}
    todo, missing = [], []
    for name in args.only or wanted_textures():
        if index.entry(player_path(name)) is None:
            missing.append(name)
        elif index.entry(crowd_path(name)) is None or (args.replace and crowd_path(name).lower() in added):
            todo.append(name)
    for name in missing:
        print(f"  no player texture, skipped: {name}")
    print(f"{len(todo)} crowd jerseys to bake")

    os.makedirs(WORK, exist_ok=True)
    for name in todo:
        preview = os.path.join(WORK, f"{name}.png")
        if os.path.exists(preview) and not args.rebake:
            img = Image.open(preview).convert("RGB")
        else:
            img = Image.fromarray(bake(index.player(name)))
            img.save(preview)
        if all(lo == hi for lo, hi in img.getextrema()):
            # e.g. m_top_seaEagles_nsw_away_25_col is plain white (its colours
            # come from tint layers), which would only give fans a blank shirt
            print(f"  flat player texture, skipped: {name}")
            continue
        dds = dxt1_with_mips(img, header)
        if len(dds) != len(stock):
            sys.exit(f"{name}: DDS is {len(dds)} bytes, stock crowd jerseys are {len(stock)}")
        path = crowd_path(name)
        blob, sizes = club_icons.make_blob(path, dds)
        ae.add_entry(pack.BLOBSET_PATH, path, blob, sizes, f"crowd-team-kits bake of {player_path(name)}",
                     args.confirm, replace=index.entry(path) is not None)
    print(f"previews in {os.path.relpath(WORK, ROOT)}")
    if not args.confirm:
        print("dry run - pass --confirm to write (close the game first), then run generate.py and rebuild 39959")


# ---- register --------------------------------------------------------------

def crowd_texture_table(raw):
    """Entry 39871, the crowd's texture info table: u32 version (8), u32
    count, then count x {u32 FNV-1a32(lowercase texture name), u32 width,
    u32 height, u32 format (1 = DXT1)}. The crowd loader (rugbyleague1.exe
    0xbad380) looks every crowd texture up here by hash and dereferences null
    when it's missing - the 0xC0000409 abort at match load."""
    version, count = struct.unpack_from("<2I", raw, 0)
    if version != TEXTURE_TABLE_VERSION or len(raw) != 8 + 16 * count:
        raise ValueError(f"unexpected crowd texture table (version {version}, count {count}, {len(raw)} bytes)")
    return version, [struct.unpack_from("<4I", raw, 8 + 16 * i) for i in range(count)]


def fnv1a32(text):
    h = 0x811C9DC5
    for c in text.lower().encode("latin1"):
        h = ((h ^ c) * 0x01000193) & 0xFFFFFFFF
    return h


def cmd_register(args):
    """Add a texture-table record for every appended crowd texture: this tool's
    jerseys and other mods' (crowd-flags' flags). The table is rebuilt from
    stock each time, so anything left out here would vanish from it."""
    added = sorted((e["path"], e["blob_path"]) for e in (ae.load_registry() or {"entries": []})["entries"]
                   if re.match(r"crowd/characters/textures/\w+\.texture$", e["path"]))
    if os.path.exists(pack.backup_meta_path(TEXTURE_TABLE_ENTRY)):
        if args.confirm:
            pack.do_restore(pack.BLOBSET_PATH, TEXTURE_TABLE_ENTRY)  # rebuild from the stock table
        else:
            print(f"(entry {TEXTURE_TABLE_ENTRY} is installed; --confirm restores it before rebuilding)")
    ce.load_index(pack.BLOBSET_PATH)
    version, records = crowd_texture_table(ce.read_blob_full(pack.BLOBSET_PATH, TEXTURE_TABLE_ENTRY)[0])
    known = {r[0] for r in records}
    new = []
    for path, blob_path in added:
        h = fnv1a32(path[len("crowd/characters/textures/"):-len(".texture")])
        if h not in known:
            with open(blob_path, "rb") as f:
                width, height = struct.unpack("<2I", f.read(8))  # Mini_TXPK main header (all added ones are DXT1)
            known.add(h)
            new.append((h, width, height, 1))
    raw = struct.pack("<2I", version, len(records) + len(new)) + b"".join(struct.pack("<4I", *r) for r in records + new)
    print(f"crowd texture table: {len(records)} stock records + {len(new)} for added crowd textures")
    if not args.confirm:
        print("dry run - pass --confirm to install (close the game first)")
        return
    os.makedirs(WORK, exist_ok=True)
    out = os.path.join(WORK, f"entry_{TEXTURE_TABLE_ENTRY}.bin")
    with open(out, "wb") as f:
        f.write(raw)
    pack.do_install(pack.BLOBSET_PATH, TEXTURE_TABLE_ENTRY, out, True)
    print(f"installed entry {TEXTURE_TABLE_ENTRY} (undo: python tools\\pack.py restore --entry {TEXTURE_TABLE_ENTRY})")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("learn", help="learn the crowd/player texel mapping from the shipped jerseys")
    p = sub.add_parser("register", help="add the added crowd jerseys to the crowd texture table (entry 39871)")
    p.add_argument("--confirm", action="store_true", help="install the rebuilt table (game closed)")
    p = sub.add_parser("bake", help="bake crowd copies of jerseys that lack one")
    p.add_argument("--only", nargs="+", metavar="NAME", help="top texture names, e.g. m_top_broncos_nrl_home_26_col")
    p.add_argument("--replace", action="store_true", help="also redo jerseys that already have a crowd copy we added")
    p.add_argument("--rebake", action="store_true", help="ignore the previews in _build/crowd-team-kits (the bake cache)")
    p.add_argument("--confirm", action="store_true", help="write the new entries (game closed)")
    args = ap.parse_args()
    {"learn": cmd_learn, "bake": cmd_bake, "register": cmd_register}[args.cmd](args)


if __name__ == "__main__":
    main()
