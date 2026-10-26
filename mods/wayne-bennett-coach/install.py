#!/usr/bin/env python3
"""
install.py - put Wayne Bennett in the game as a coach by taking over the
tier-1 head slot of generic NPC 503 "Paddy Douglas" (see README.md).

Every asset a tier-1 head needs is keyed by the head item's name, and the
game already loads and registers all of Paddy's (global.texsrc included),
so nothing is appended - his existing entries are replaced:
  - head / hair-cap meshes: byte copies of Peter Gough's blobs (long, lean
    face; picked from in-texture renders; model blobs carry no names), with
    his index sizes. Hair-top / hair-side: his meshes with every triangle
    made degenerate, so the painted balding crown shows (HIDDEN_PARTS);
  - _nrm / _mat textures: Gough's DDS (baked from that same mesh), installed
    through texture_mods' Mini_TXPK layout so Paddy's own header and path
    are kept;
  - _col textures: wayne_bennett_face.png warped onto the shared UV layout
    (face_warp.py), as uncompressed BGRA like the stock head textures.
The NPC record (rename + grey hair) is a data mod in entry 39954:
defaultdata/defaultdata_npcs/000503_Bennett.json, plus the matching
defaultdata/000503.npcdata that `build` writes.

Usage (game closed):
    python mods/wayne-bennett-coach/install.py build      # warp + DDS + 000503.npcdata
    python mods/wayne-bennett-coach/install.py install --confirm
    python mods/wayne-bennett-coach/install.py restore
    python mods/wayne-bennett-coach/install.py status
then rebuild entry 39954 (README.md).
"""

import argparse
import json
import os
import struct
import sys

from PIL import Image

MOD_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(os.path.dirname(MOD_DIR))
sys.path.insert(0, os.path.join(REPO_ROOT, "tools"))
import add_entries  # noqa: E402
import classify_entries as ce  # noqa: E402
import extract_textures as et  # noqa: E402
import pack  # noqa: E402
import parse_npcs as pn  # noqa: E402
import texture_mods  # noqa: E402

sys.path.insert(0, MOD_DIR)
import face_warp  # noqa: E402

HOST = "paddyDouglas_npc503"
DONOR = "peterGough_npc550"
NPC_ID = 503
BUILD_DIR = os.path.join(REPO_ROOT, "_build", "wayne-bennett-coach")
FACE = os.path.join(MOD_DIR, "wayne_bennett_face.png")
RECORD_JSON = os.path.join(MOD_DIR, "defaultdata", "defaultdata_npcs", "000503_Bennett.json")
NPCDATA_OUT = os.path.join(MOD_DIR, "defaultdata", f"{NPC_ID:06d}.npcdata")
NPCDATA_STOCK = os.path.join(REPO_ROOT, "extracted", "defaultdata", f"{NPC_ID:06d}.npcdata")
LEVELS = {1: 2048, 2: 1024, 3: 512}


def model_paths(n):
    bases = [f"characters/heads/models/{n}/{n}", f"characters/hair/models/{n}/{n}",
             f"characters/hair/models/{n}_side/{n}_side", f"characters/hairCap/models/{n}_hairCap/{n}_hairCap"]
    return [b + ext for b in bases for ext in (".modelcomponent", ".blendshapes")]


# hair-top and hair-side meshes are hidden so the painted balding crown shows:
# every triangle of every LOD becomes degenerate (all indices 0)
HIDDEN_PARTS = ("characters/hair/models/{n}/{n}.modelcomponent",
                "characters/hair/models/{n}_side/{n}_side.modelcomponent")


def hidden_model(comp):
    """Copy of a .modelcomponent with no visible triangles (layout in
    tools/bigant_mesh.py), stored in the game's 256 KB chunked framing."""
    comp = bytearray(comp)
    h = struct.unpack_from("<9I", comp, 0)
    if h[0] != 0x12345678:
        raise SystemExit("not a modelcomponent")
    for lod in range(h[3]):
        rec = struct.unpack_from("<36I", comp, 0x24 + 0x90 * lod)
        start = h[7] + 28 + rec[6]
        comp[start:start + 2 * rec[7]] = bytes(2 * rec[7])
    stored = texture_mods.encode_outer_chunks(bytes(comp))
    return stored, (len(stored), len(comp), 0, 0)


def texture_path(n, kind, level):
    return f"characters/heads/textures/{n}_{kind}_{level}.texture"


class Index:
    def __init__(self, blobset):
        self.blobset = blobset
        self.data, self.count, self.hash_off, self.size_off = pack.read_index(blobset)
        ce.load_index(blobset)

    def entry(self, path):
        e = add_entries.find_entry(self.data, self.count, self.hash_off, path)
        if e is None:
            raise SystemExit(f"{path} is not in the index")
        return e

    def stock(self, entry):
        if os.path.exists(pack.backup_meta_path(entry)):
            raise SystemExit(f"entry {entry} is modified (backup exists) - restore it before reading it as stock")
        return ce.read_blob_full(self.blobset, entry)


def _bgra_dds(header, img):
    """Stock head textures are 32-bit uncompressed, no mips, stored upside
    down; reuse the stock header so the format bits match exactly."""
    h, w = struct.unpack_from("<2I", header, 12)
    if header[:4] != b"DDS " or struct.unpack_from("<I", header, 88)[0] != 32 or img.size != (w, h):
        raise SystemExit("unexpected stock head texture format")
    return header[:128] + img.convert("RGBA").transpose(Image.FLIP_TOP_BOTTOM).tobytes("raw", "BGRA")


def cmd_build(args):
    idx = Index(args.blobset)
    os.makedirs(BUILD_DIR, exist_ok=True)
    face = face_warp.warp(Image.open(FACE))
    face.save(os.path.join(BUILD_DIR, "face_col.png"))
    for level, size in LEVELS.items():
        e = idx.entry(texture_path(HOST, "col", level))
        header = et.parse_mini_txpk(ce.read_blob_full(args.blobset, e)[0])[1][:128]
        img = face.resize((size, size), Image.LANCZOS)
        with open(os.path.join(BUILD_DIR, f"col_{level}.dds"), "wb") as f:
            f.write(_bgra_dds(header, img))
        for kind in ("nrm", "mat"):
            raw = idx.stock(idx.entry(texture_path(DONOR, kind, level)))[0]
            with open(os.path.join(BUILD_DIR, f"{kind}_{level}.dds"), "wb") as f:
                f.write(et.parse_mini_txpk(raw)[1])
    print(f"textures -> {BUILD_DIR}")

    blob = bytearray(open(NPCDATA_STOCK, "rb").read())
    if pn.visual_get(blob, "head")[0] != 50000 + NPC_ID:
        raise SystemExit(f"{NPCDATA_STOCK} isn't NPC {NPC_ID}'s stock visual")
    for name, value in json.load(open(RECORD_JSON))["visual"].items():
        old = pn.visual_set(blob, name, value)
        print(f"  npcdata {name}: {old} -> {value}")
    with open(NPCDATA_OUT, "wb") as f:
        f.write(blob)
    print(f"wrote {NPCDATA_OUT}")


def _install(blobset, entry, src, sizes):
    if os.path.exists(pack.backup_meta_path(entry)):
        pack.do_restore(blobset, entry)
    pack.do_install(blobset, entry, src, True, sizes=sizes)


def cmd_install(args):
    idx = Index(args.blobset)
    plan = []
    os.makedirs(BUILD_DIR, exist_ok=True)
    hidden = {p.format(n=HOST) for p in HIDDEN_PARTS}
    for host, donor in zip(model_paths(HOST), model_paths(DONOR)):
        d = idx.entry(donor)
        raw, _folder, _hash, bpath = idx.stock(d)
        if host in hidden:
            stored, sizes = hidden_model(raw)
            bpath = os.path.join(BUILD_DIR, os.path.basename(host) + ".hidden")
            with open(bpath, "wb") as f:
                f.write(stored)
            plan.append((idx.entry(host), bpath, sizes, f"{host} <- {donor} (all triangles hidden)"))
        else:
            plan.append((idx.entry(host), bpath, pack.entry_sizes(idx.data, idx.size_off, d), f"{host} <- {donor}"))
    for kind in ("col", "nrm", "mat"):
        for level in LEVELS:
            e = idx.entry(texture_path(HOST, kind, level))
            dds = os.path.join(BUILD_DIR, f"{kind}_{level}.dds")
            if not os.path.exists(dds):
                raise SystemExit(f"{dds} missing - run build first")
            plan.append((e, dds, None, f"{texture_path(HOST, kind, level)} <- {os.path.basename(dds)}"))
    for e, src, sizes, desc in plan:
        print(f"entry {e}: {desc}")
    if not args.confirm:
        print("dry run - pass --confirm to install (close the game first)")
        return
    for e, src, sizes, _desc in plan:
        if sizes is None:  # texture: rebuild the Mini_TXPK around our DDS
            if os.path.exists(pack.backup_meta_path(e)):
                pack.do_restore(args.blobset, e)
            blob, sizes, _raw_path = texture_mods.build_texture_blob(args.blobset, e, src)
            src = os.path.join(BUILD_DIR, f"entry_{e}.bin")
            with open(src, "wb") as f:
                f.write(blob)
        _install(args.blobset, e, src, sizes)
    print(f"installed {len(plan)} entries - now rebuild entry 39954 (README.md)")


def _host_entries(idx):
    return [idx.entry(p) for p in model_paths(HOST)] + \
           [idx.entry(texture_path(HOST, k, l)) for k in ("col", "nrm", "mat") for l in LEVELS]


def cmd_restore(args):
    idx = Index(args.blobset)
    for e in _host_entries(idx):
        if os.path.exists(pack.backup_meta_path(e)):
            pack.do_restore(args.blobset, e)
            print(f"restored entry {e}")


def cmd_status(args):
    idx = Index(args.blobset)
    for e in _host_entries(idx):
        print(f"entry {e}: {'INSTALLED' if os.path.exists(pack.backup_meta_path(e)) else 'stock'}")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--blobset", default=pack.BLOBSET_PATH)
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("build").set_defaults(func=cmd_build)
    p = sub.add_parser("install")
    p.add_argument("--confirm", action="store_true")
    p.set_defaults(func=cmd_install)
    sub.add_parser("restore").set_defaults(func=cmd_restore)
    sub.add_parser("status").set_defaults(func=cmd_status)
    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
