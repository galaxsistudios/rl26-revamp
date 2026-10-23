#!/usr/bin/env python3
"""
install.py - install / restore the sponsor field-decal textures built by
build_textures.py (one TXPK bundle entry per sponsor model, see its
docstring for the slot layout).

Why not build_texture.py inject-bundle: that stores the whole rebuilt bundle
raw in "main" (vram 0/0). Pristine TXPK entries are split exactly like
Mini_TXPK ones - the TXPK header/path table is "main" and the concatenated
DDS payloads are "vram" - and texture_mods.py documents that collapsing that
split stops textures loading in game. So this mirrors texture_mods'
ground-truthed layout instead: main = the entry's original header bytes,
stored raw (main_c == main_u); vram = the payload with our members patched
in place, through texture_mods.encode_outer_chunks. Every replacement .dds is
the exact size of the member it replaces (build_textures.py asserts it), so
the header's offsets stay valid byte-for-byte.

Usage (game closed):
    python mods/nrl-field-sponsor-markings/install.py install --confirm
    python mods/nrl-field-sponsor-markings/install.py restore
    python mods/nrl-field-sponsor-markings/install.py status
"""

import argparse
import os
import struct
import sys

MOD_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(os.path.dirname(MOD_DIR))
sys.path.insert(0, os.path.join(REPO_ROOT, "tools"))
import classify_entries as ce  # noqa: E402
import extract_textures as et  # noqa: E402
import pack  # noqa: E402
import texture_mods  # noqa: E402

sys.path.insert(0, MOD_DIR)
import models  # noqa: E402

BUILD_DIR = os.path.join(REPO_ROOT, "_build", "nrl-field-sponsor-markings")

# Model entry -> patches; its TXPK is always the next entry.
#   move_badge: day badge (leagueStars01 mesh) moved from the two tilted
#               quads near each 20 m to halfway, opposite the NRL centre logo.
#   renames:    same-length texture renames, applied to the model's reference
#               AND the TXPK member, so no two bundles share a texture path
#               with different art (a path-keyed texture cache could
#               otherwise show one day's badge on another day).
#   resize:     (material, width_x, depth_z[, centre |z|]) for a single-quad mesh.
#   full_uv:    meshes whose UVs are stretched to the whole texture - stock
#               quads only show a window of it, cropping our art's edges.
#   collapse:   meshes hidden by collapsing them to a point.
_DAY = {"th": (39918, 39920), "fr": (39886, 39888), "sa": (39914, 39916), "su": (39910, 39912)}
_WESTPAC = (39882, 39884, 39890, 39892, 39898, 39900, 39922, 39924)
_MID = ["kiaTasman01", "kiaTasman02"]
MODEL_PATCHES = {}
for _tag, _entries in _DAY.items():
    for _e in _entries:
        MODEL_PATCHES[_e] = {"move_badge": True, "full_uv": _MID,
                             "renames": {"sponsor_field_leaguestars01_col": f"sponsor_field_leaguestars{_tag}_col"}}
for _e in _WESTPAC:
    MODEL_PATCHES[_e] = {"full_uv": _MID,
                         "renames": {"sponsor_field_kiatasman02_col": "sponsor_field_kiatasmanwp_col"}}
# Grand Final takes over the women's RLWC model pair (geometry identical to
# the men's, which stadiumgrass.lua now uses for both World Cups). Its centre
# quad is widened for the wide GF wordmark: 26 m along halfway, depth with the
# same ~1.38x broadcast-angle stretch the stock NRL logo uses. It's centred
# 26 m off the long axis (z 22-30, 4 m inside the touchline at 34), clear of
# the 40 m numbers - they sit inside the 10 m-from-touchline dashes at z 24,
# and the stock centre position (z 19-27) painted over them. Its in-goal
# banners are hidden: the Monday model below is drawn as a second layer for
# the GF (stadiumgrass.lua) and supplies Westpac mid-field + KFC in-goal.
for _e in (39902, 39904):
    MODEL_PATCHES[_e] = {"resize": ("rlwc01", 26.0, 7.9, 26.0), "full_uv": ["rlwc01"],
                         "collapse": ["wideLeft_RLWC26", "wideRight_RLWC26"],
                         "renames": {"sponsor_field_rlwc01_col": "sponsor_field_nrlgf1_col"}}
for _e in (39894, 39896):
    MODEL_PATCHES[_e] = {"full_uv": _MID, "collapse": ["leagueStars01"],
                         "renames": {"sponsor_field_kiatasman01_col": "sponsor_field_kiatasmanw1_col",
                                     "sponsor_field_kiatasman02_col": "sponsor_field_kiatasmanwp_col"}}


def built_entries():
    if not os.path.isdir(BUILD_DIR):
        raise SystemExit(f"{BUILD_DIR} not found - run build_textures.py first")
    return sorted(int(d) for d in os.listdir(BUILD_DIR) if d.isdigit())


def all_entries():
    return sorted(set(built_entries()) | set(MODEL_PATCHES))


# Every sponsor model/TXPK entry this mod can touch - restore/status use this
# so they work even when _build/ is gone.
SPONSOR_ENTRIES = range(39882, 39926)


def build_model(blobset, entry):
    stored, *_ = ce.read_blob_full(blobset, entry)
    sizes = pack.entry_sizes(ce._INDEX_DATA, ce._SIZE_TABLE_OFF, entry)
    if sizes[0] != len(stored) or sizes[2] != 0:
        raise RuntimeError(f"model {entry} is not pristine (sizes {sizes}) - restore it first")
    m = models.Model(models.decode(stored))
    patch = MODEL_PATCHES[entry]
    if patch.get("move_badge"):
        m.move_badge_opposite()
    if "resize" in patch:
        m.resize_quad(*patch["resize"])
    for material in patch.get("full_uv", []):
        m.full_uv(material)
    for material in patch.get("collapse", []):
        m.collapse(material)
    for old, new in patch["renames"].items():
        m.rename_texture(old, new)
    return models.encode(m.bytes())


def member_table(raw):
    """{path_with_.dds: (data_off, data_size)} from a TXPK header."""
    magic, count = struct.unpack_from("<2I", raw, 0)
    if magic != et.TXPK_MAGIC:
        raise ValueError("not a TXPK")
    out = {}
    for i in range(count):
        path_off, _path_size, data_off, data_size = struct.unpack_from("<4I", raw, 8 + i * 16)
        end = raw.index(b"\x00", path_off + 20)
        path = raw[path_off + 20:end].decode("latin1").replace("\\", "/")
        out[path + ".dds"] = (data_off, data_size)
    return out


def build_blob(blobset, entry):
    raw, *_ = ce.read_blob_full(blobset, entry)
    if raw is None or ce.classify(raw[:65536])[0] != "txpk":
        raise RuntimeError(f"entry {entry} is not a TXPK bundle")
    main_c, main_u, vram_c, vram_u = pack.entry_sizes(ce._INDEX_DATA, ce._SIZE_TABLE_OFF, entry)
    if vram_u == 0 or main_u + vram_u != len(raw):
        raise RuntimeError(f"entry {entry} is not a pristine main/vram TXPK (sizes {main_c, main_u, vram_c, vram_u}) "
                           f"- restore it first")
    header, payload = raw[:main_u], bytearray(raw[main_u:])
    table = member_table(header)
    changed = []
    src_root = os.path.join(BUILD_DIR, str(entry))
    for dirpath, _dirs, files in os.walk(src_root):
        for fn in files:
            rel = os.path.relpath(os.path.join(dirpath, fn), src_root).replace(os.sep, "/")
            if rel not in table:
                raise RuntimeError(f"entry {entry} has no member {rel}")
            off, size = table[rel]
            dds = open(os.path.join(dirpath, fn), "rb").read()
            if len(dds) != size:
                raise RuntimeError(f"{rel}: {len(dds)} bytes, member is {size}")
            payload[off:off + size] = dds
            changed.append(rel)
    for old, new in MODEL_PATCHES.get(entry - 1, {}).get("renames", {}).items():
        old_b, new_b = f"/{old}\x00".encode(), f"/{new}\x00".encode()
        if header.count(old_b) != 1:
            raise RuntimeError(f"entry {entry}: expected one member named {old}")
        header = header.replace(old_b, new_b)
    vram = texture_mods.encode_outer_chunks(bytes(payload))
    sizes = (len(header), len(header), len(vram), len(payload))
    return header + vram, sizes, changed


def cmd_install(args):
    ce.load_index(args.blobset)
    entries = all_entries()
    already = [e for e in entries if os.path.exists(pack.backup_meta_path(e))]
    if already:
        raise SystemExit(f"entries {already} already have a backup - run 'install.py restore' first")
    builds = []
    for entry in entries:  # build everything before touching the game
        if entry in MODEL_PATCHES:
            blob, sizes = build_model(args.blobset, entry)
            out = os.path.join(BUILD_DIR, f"entry_{entry}.model.bin")
            p = MODEL_PATCHES[entry]
            what = "model " + ", ".join(
                (["badge moved"] if p.get("move_badge") else []) +
                (["%s resized" % p["resize"][0]] if "resize" in p else []) +
                [f"full uv {m}" for m in p.get("full_uv", [])] +
                [f"hide {m}" for m in p.get("collapse", [])] +
                [f"{o} -> {n}" for o, n in p["renames"].items()])
        else:
            blob, sizes, changed = build_blob(args.blobset, entry)
            out = os.path.join(BUILD_DIR, f"entry_{entry}.txpk.bin")
            what = f"{len(changed)} textures, vram {sizes[2]} bytes"
        with open(out, "wb") as f:
            f.write(blob)
        builds.append((entry, out, sizes))
        print(f"  built {entry}: {what}")
    if not args.confirm:
        print("Dry run - pass --confirm to install.")
        return
    for entry, out, sizes in builds:
        pack.do_install(args.blobset, entry, out, confirm=True, sizes=sizes)
        print(f"  installed {entry}")
    print("Done. Undo with: python mods/nrl-field-sponsor-markings/install.py restore")


def cmd_restore(args):
    for entry in SPONSOR_ENTRIES:
        if os.path.exists(pack.backup_meta_path(entry)):
            pack.do_restore(args.blobset, entry)
            print(f"  restored {entry}")


def cmd_status(args):
    for entry in SPONSOR_ENTRIES:
        if os.path.exists(pack.backup_meta_path(entry)):
            print(f"  {entry}: installed")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--blobset", default=pack.BLOBSET_PATH)
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("install")
    p.add_argument("--confirm", action="store_true")
    p.set_defaults(func=cmd_install)
    sub.add_parser("restore").set_defaults(func=cmd_restore)
    sub.add_parser("status").set_defaults(func=cmd_status)
    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
