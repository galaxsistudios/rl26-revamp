#!/usr/bin/env python3
"""
r25_import.py - bring Rugby 25 cutscenes and their animations into RL26.

RELEASE: everything this tool produces is the optional "Rugby 25 Expansion",
not part of the main RL26 Revamp release. It runs on the player's machine
against their own Rugby 25 install, so no Rugby 25 data is redistributed. Mods
built from it carry "releaseChannel": "r25-expansion" in their imports.json
(see mods/r25-imports/README.md).

Rugby 25 runs on the same engine and data layout as RL26 (same BLOB v4 index,
same outer-ZSTD blob framing, same M3MP script bundle, same LuaJIT bytecode,
same CutsceneData schema), so its assets can be copied across rather than
rebuilt:

  - Animations: a cutscene names one animset, loaded from
    "animations/<animsetName>.animset" (cutscene_listener.loadAnimset). Each
    animset is ONE self-contained index entry, so `import` copies the R25 blob
    byte for byte and appends it to RL26 as animations/r25_<name>.animset (via
    add_entries.py, so `add_entries.py remove-all` undoes it). The r25_ prefix
    is needed: many R25 animsets share a name with a different RL26 one.
    Joints bind by name (fnv1a32 + string table at the animset's 5th header
    offset); R25's body rig is RL26's plus neck2 / left+right legroll /
    left+right inhandmiddle, and R25 sets have no facial fj_* joints or
    worldroot track.
  - Definitions: `scan` runs every R25 cutscene-data module in LuaJIT with
    native.* stubbed (r25_dump.lua) and catalogs the result. `gen-mod`
    writes the chosen ones back out as Lua inside RL26's own
    cs_test_cutscene_data.lua (build.py can't add new bundle files, and no
    other mod overrides that one), renamed r25_<cutscene> with animsetName
    r25_<animset>, and registers them in cutscene groups by appending to
    GroupList in an overridden cutscenedata_config.lua (so it stacks on top
    of whatever cutscenegroupdata_config.lua another mod installs).

The R25 workspace (extracted bytecode, optional decompile, catalog) lives in
r25/ at the repo root, which .gitignore already keeps local.

Usage:
    python r25_import.py setup                    # extract R25's lua bundle into r25/extracted
    python r25_import.py scan [--filter TEXT]     # catalog -> r25/catalog.json, print summary
    python r25_import.py show CUTSCENE            # print one converted definition
    python r25_import.py import [--mod DIR] [ANIMSET ...] [--confirm]
    python r25_import.py gen-mod [--mod DIR]      # write the mod's Lua from its imports.json
"""

import argparse
import copy
import json
import os
import re
import struct
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pack  # noqa: E402
import add_entries as ae  # noqa: E402
import classify_entries as ce  # noqa: E402
import extract_m3mp  # noqa: E402
import motionset  # noqa: E402
import animset as animset_mod  # noqa: E402
import tackleset  # noqa: E402
import games  # noqa: E402

REPO_ROOT = pack.REPO_ROOT
def _r25_blobset():
    """Rugby 25's data-0.blobset.pc via tools/games.py: only when the installer
    enabled Rugby 25 (revamp_install.json) and it is installed."""
    import games
    return os.path.join(games.require("r25"), "data", "data-0.blobset.pc")


R25_BLOBSET = None  # resolved on first use (_r25_blobset), so importing this module needs no Rugby 25
WORK_DIR = os.path.join(REPO_ROOT, "r25")
R25_EXTRACTED = os.path.join(WORK_DIR, "extracted")
R25_SCRIPTS = os.path.join(R25_EXTRACTED, "rugby22", "src", "script-game")
CATALOG_PATH = os.path.join(WORK_DIR, "catalog.json")
DEFAULT_MOD = os.path.join(REPO_ROOT, "mods", "r25-imports")

RL_STOCK = os.path.join(REPO_ROOT, "decompiled", "src", "script-game")
RL_EXTRACTED = os.path.join(REPO_ROOT, "extracted", "src", "script-game")
CUTSCENE_DATA_DIR = "intermediatelua/cutscenes/data"
CARRIER = CUTSCENE_DATA_DIR + "/cs_test_cutscene_data.lua"
CONFIG = CUTSCENE_DATA_DIR + "/cutscenedata_config.lua"

LUAJIT_EXE = games.toolchain("luajit", "bin", "luajit.exe")
DUMPER = os.path.join(os.path.dirname(os.path.abspath(__file__)), "r25_dump.lua")

LUA_BUNDLE = "mempacks/lua.mempack.retail"
PREFIX = "r25_"
CAMERA_JOINT = re.compile(r"cs_camera\d+$")
# RL26 animsets whose names make up the reference joint set for the rig check.
RL_RIG_ANIMSETS = ["master", "ingame", "tackle", "cutsceneinjuries", "cutscenetrycelebratehug01"]
# RL26 cutscene animsets whose constant bone offsets replace Rugby 25's.
RL_STATIC_REF_ANIMSETS = ["cutscenetrycelebratehug08", "cutscenetrycelebratehug01",
                          "rl1_og_trycelebrate_hug_01_animset", "cutsceneinjuries"]


# --------------------------------------------------------------------------
# index helpers


class Index:
    def __init__(self, blobset_path):
        self.path = blobset_path
        data, n, hash_off, size_off = pack.read_index(blobset_path)
        self.data, self.count, self.hash_off, self.size_off = data, n, hash_off, size_off
        self.by_hash = {h: i for i, h in enumerate(struct.unpack_from(f"<{n}Q", data, hash_off))}

    def find(self, logical_path):
        return self.by_hash.get(ae.path_hash(logical_path))

    def sizes(self, i):
        return pack.entry_sizes(self.data, self.size_off, i)

    def raw_blob(self, i):
        folder, file_hash = pack.entry_hash(self.data, self.hash_off, i)
        with open(pack.blob_path(self.path, folder, file_hash), "rb") as f:
            return f.read()

    def decoded_blob(self, i):
        ce.load_index(self.path)
        return ce.read_blob_full(self.path, i)[0]


def animset_path(name):
    return f"animations/{name}.animset"


def fnv1a32(text):
    h = 0x811C9DC5
    for c in text.encode("latin1"):
        h = ((h ^ c) * 0x01000193) & 0xFFFFFFFF
    return h


# (kind, encoding) pairs of the track records used by all 110 stock RL26
# cutscene animsets (kind 1 rotation, 2 translation, 4 scale, 8 float curve).
# R25 also uses 1/0x8, 1/0x4008, 2/0x4, 2/0x4004 (every set's hips) and 8/0x8
# (29 float curves per clip, probably the face). RL26 plays them without
# crashing but decodes them wrongly: stretched bodies, floaty feet, a wild
# camera, no facial expression (in-game test 2026-10-24).
RL26_TRACK_TYPES = {(1, 0x6), (1, 0x10), (1, 0x4006), (1, 0x4010), (1, 0xC010), (2, 0x6), (2, 0x10),
                    (2, 0x4006), (2, 0x4010), (2, 0xC010), (4, 0x10)}


def animset_track_types(raw):
    """{(kind, encoding): count} over every clip's track records."""
    a = animset_mod.AnimSet(raw)
    types = {}
    for clip in a.clips:
        tracks = struct.unpack_from("<H", clip.head, 4)[0]
        for i in range(tracks):
            kind, enc = struct.unpack_from("<HH", raw, clip.streams[3] + i * 16 + 8)
            types[(kind, enc)] = types.get((kind, enc), 0) + 1
    return types


def unsupported_track_types(raw):
    return sorted(t for t in animset_track_types(raw) if t not in RL26_TRACK_TYPES)


def animset_strings(raw):
    """Every string in the animset's name block: the hashed joint/event names
    plus the clip names (clip, clip_m pairs) stored after them."""
    off = struct.unpack_from("<I", raw, 20)[0]
    count = struct.unpack_from("<I", raw, off)[0]
    return [s.decode("latin1") for s in raw[off + 4 + count * 6:].split(b"\0") if s]


def animset_names(raw):
    """Joint/event names an animset binds to: count, count x fnv1a32, count x
    u16, then NUL-terminated strings, at the 5th header offset."""
    off = struct.unpack_from("<I", raw, 20)[0]
    count = struct.unpack_from("<I", raw, off)[0]
    hashes = struct.unpack_from(f"<{count}I", raw, off + 4)
    strings = raw[off + 4 + count * 6:].split(b"\0")
    by_hash = {fnv1a32(s.decode("latin1")): s.decode("latin1") for s in strings if s}
    return [by_hash.get(h, f"?{h:08x}") for h in hashes]


# --------------------------------------------------------------------------
# setup / dump


def cmd_setup(args):
    idx = Index(args.r25)
    i = idx.find(LUA_BUNDLE)
    if i is None:
        raise SystemExit(f"{LUA_BUNDLE} not found in {args.r25}")
    records, files = extract_m3mp.decode_m3mp(idx.decoded_blob(i))
    for name, content in files.items():
        dest = os.path.join(R25_EXTRACTED, *name.replace("\\", "/").lstrip("/").split("/"))
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        with open(dest, "wb") as f:
            f.write(content)
    print(f"extracted {len(files)} R25 scripts (entry {i}) to {os.path.relpath(R25_EXTRACTED, REPO_ROOT)}")


def dump_module(path, scripts_root=R25_SCRIPTS):
    res = subprocess.run([LUAJIT_EXE, DUMPER, path, scripts_root], capture_output=True, text=True)
    if res.returncode != 0:
        raise RuntimeError(f"{os.path.basename(path)}: {res.stderr.strip()}")
    return json.loads(res.stdout)


def r25_cutscene_modules():
    data_dir = os.path.join(R25_SCRIPTS, *CUTSCENE_DATA_DIR.split("/"))
    if not os.path.isdir(data_dir):
        raise SystemExit("R25 scripts not extracted yet - run: python r25_import.py setup")
    for fn in sorted(os.listdir(data_dir)):
        if fn.endswith(".lua") and fn not in ("cutscenedata_config.lua", "cutscenegroupdata_config.lua"):
            yield fn, os.path.join(data_dir, fn)


# R25's older design-time cutscene file: 253 cutscenes defined as globals
# (not in CutsceneData), used by its cutscene editor. It holds cut content
# whose animsets still ship - e.g. Post_Conversion_01-03 (kicker reactions)
# and Conversion_T_success_r24_01.
R25_LEGACY_CUTSCENES = "design/cutscenes/cutscenes_config.lua"


def load_all_r25_cutscenes():
    out = {}
    for fn, path in r25_cutscene_modules():
        try:
            for name, cs in dump_module(path).items():
                out[name] = (fn, cs)
        except RuntimeError as e:
            print(f"  warning: {e.args[0].splitlines()[0]}")
    legacy = os.path.join(R25_SCRIPTS, *R25_LEGACY_CUTSCENES.split("/"))
    if os.path.exists(legacy):
        res = subprocess.run([LUAJIT_EXE, DUMPER, legacy, R25_SCRIPTS, "*globals"], capture_output=True, text=True)
        if res.returncode == 0:
            for name, cs in json.loads(res.stdout).items():
                out.setdefault(name, (os.path.basename(R25_LEGACY_CUTSCENES) + " (legacy)", cs))
        else:
            print(f"  warning: {R25_LEGACY_CUTSCENES}: {res.stderr.strip().splitlines()[0]}")
    return out


def apply_item_options(cs, item):
    """imports.json per-cutscene tweaks: "overrides" sets definition fields
    (null removes one - e.g. to re-anchor a studio shot on its main actor),
    "cameraAnimFromActor" points every camera at the first actor's clip (R25's
    Post_Conversion_01/02 reuse clip 03's cameras)."""
    cs = json.loads(json.dumps(cs))
    from_rl = item.get("fromRL")
    if from_rl:
        # staging from an RL26 cutscene: e.g. its corridor model, lighting and
        # sounds in place of R25 assets RL26 doesn't ship
        src = rl_stock_cutscene(from_rl["cutscene"])
        for k in from_rl["fields"]:
            if k in src:
                cs[k] = json.loads(json.dumps(src[k]))
            else:
                cs.pop(k, None)
    # "retime": {event type / soundKey / playback event name: new frame}
    for key, frame in (item.get("retime") or {}).items():
        for e in (cs.get("soundEvents") or []) + (cs.get("playbackEvents") or []):
            t = e.get("eventTable") or {}
            if key in (t.get("type"), t.get("soundKey"), e.get("name")) and "frame" in e:
                e["frame"] = frame
    if item.get("sideToPrimary"):
        # R25 scenes hard-coded to one team: every side filter becomes the scoring side
        # (the request's primarySide)
        for actor in cs.get("actors") or []:
            if "side" in (actor.get("filter") or {}):
                actor["filter"]["side"] = "primary"
    if item.get("swapSides"):
        swap = {"sidehelper.home": "sidehelper.away", "sidehelper.away": "sidehelper.home"}
        for actor in cs.get("actors") or []:
            side = (actor.get("filter") or {}).get("side")
            if isinstance(side, dict) and side.get("$expr") in swap:
                side["$expr"] = swap[side["$expr"]]
    for k, v in (item.get("overrides") or {}).items():
        if v is None:
            cs.pop(k, None)
        else:
            cs[k] = v
    # "dropActors": [actor animName, ...] - optional slots RL26 would fill with a random player
    drop = set(item.get("dropActors") or [])
    if drop and cs.get("actors"):
        cs["actors"] = [a for a in cs["actors"] if a.get("animName") not in drop]
    # "actorFields": {actor animName: {field: value, null removes}} (e.g. give a
    # camera-followed slot the captain filter so it is always filled)
    for actor in cs.get("actors") or []:
        for k, v in ((item.get("actorFields") or {}).get(actor.get("animName")) or {}).items():
            if v is None:
                actor.pop(k, None)
            else:
                actor[k] = json.loads(json.dumps(v))
    # "cameraFields": {camera name: {field: value, null removes}}
    for cam in cs.get("cameras") or []:
        for k, v in ((item.get("cameraFields") or {}).get(cam.get("name")) or {}).items():
            if v is None:
                cam.pop(k, None)
            else:
                cam[k] = v
    if item.get("cameraAnimFromActor") and cs.get("actors"):
        for cam in cs.get("cameras") or []:
            cam["animName"] = cs["actors"][0]["animName"]
    return cs


# --------------------------------------------------------------------------
# RL26 reference data for the dependency checks


_RL_STOCK = {}


def rl_stock_cutscene(name):
    if not _RL_STOCK:
        _RL_STOCK.update(rl_stock_cutscenes())
    if name not in _RL_STOCK:
        raise SystemExit(f"fromRL: no stock RL26 cutscene {name}")
    return _RL_STOCK[name]


def rl_stock_cutscene_exists(name):
    try:
        rl_stock_cutscene(name)
        return True
    except SystemExit:
        return False


def rl_stock_group_names():
    path = os.path.join(RL_EXTRACTED, *CUTSCENE_DATA_DIR.split("/"), "cutscenegroupdata_config.lua")
    res = subprocess.run([LUAJIT_EXE, DUMPER, path, RL_EXTRACTED, "GroupList"], capture_output=True, text=True)
    if res.returncode != 0:
        raise RuntimeError(res.stderr.strip())
    return set(json.loads(res.stdout))


def rl_stock_cutscenes():
    """Every stock RL26 CutsceneData table, dumped the same way as R25's."""
    out = {}
    data_dir = os.path.join(RL_EXTRACTED, *CUTSCENE_DATA_DIR.split("/"))
    for fn in sorted(os.listdir(data_dir)):
        if fn.endswith("_data.lua") or fn.startswith("cs_"):
            try:
                out.update(dump_module(os.path.join(data_dir, fn), RL_EXTRACTED))
            except RuntimeError as e:
                print(f"  warning (RL26): {e.args[0].splitlines()[0]}")
    return out


def walk(v):
    if isinstance(v, dict):
        yield v
        for x in v.values():
            yield from walk(x)
    elif isinstance(v, list):
        for x in v:
            yield from walk(x)


def dependencies(cs):
    deps = {"animsets": [], "lighting": [], "props": [], "particles": [], "events": [], "sounds": [],
            "sequences": bool(cs.get("sequences"))}
    if cs.get("animsetName"):
        deps["animsets"].append(cs["animsetName"])
    deps["animsets"] += list(cs.get("additionalAnimSets") or [])
    for p in cs.get("props") or []:
        # cutscene_props.getPropPath takes name or propName (RL26 uses name, R25 propName)
        if isinstance(p, dict) and (p.get("name") or p.get("propName")):
            deps["props"].append(p.get("name") or p.get("propName"))
    for t in walk(cs):
        if t.get("name") and "frame" in t and isinstance(t["name"], str) and t["name"].endswith("Event"):
            deps["events"].append(t["name"])
        if "particleEvent" in t:
            deps["particles"].append(t["particleEvent"])
        if "soundKey" in t:
            deps["sounds"].append(t["soundKey"])
    ls = cs.get("lightingScenes")
    if isinstance(ls, list):
        deps["lighting"] = [x if isinstance(x, str) else x.get("name", "?") for x in ls]
    elif isinstance(ls, dict):
        deps["lighting"] = [x if isinstance(x, str) else k for k, x in ls.items()]
    for k in ("props", "particles", "events", "sounds", "lighting"):
        deps[k] = sorted(set(map(str, deps[k])))
    return deps


def rl_reference(rl_idx):
    stock = rl_stock_cutscenes()
    ref = {"props": set(), "particles": set(), "events": set(), "sounds": set()}
    for cs in stock.values():
        d = dependencies(cs)
        for k in ref:
            ref[k] |= set(d[k])
    lighting_dir = os.path.join(RL_EXTRACTED, "intermediatelua", "lighting")
    ref["lighting"] = {os.path.splitext(f)[0].lower() for f in os.listdir(lighting_dir)} if os.path.isdir(lighting_dir) else set()
    rig = set()
    for name in RL_RIG_ANIMSETS:
        i = rl_idx.find(animset_path(name))
        if i is not None:
            rig |= set(animset_names(rl_idx.decoded_blob(i)))
    ref["rig"] = rig
    return ref


# --------------------------------------------------------------------------
# scan


def cmd_scan(args):
    r25_idx, rl_idx = Index(args.r25), Index(args.blobset)
    print("dumping R25 cutscene data...")
    cutscenes = load_all_r25_cutscenes()
    print("building RL26 reference sets...")
    ref = rl_reference(rl_idx)

    animsets = {}
    catalog = {"cutscenes": {}, "animsets": animsets}
    for name, (fn, cs) in sorted(cutscenes.items()):
        d = dependencies(cs)
        missing = {k: [x for x in d[k] if x.lower() not in {y.lower() for y in ref[k]}]
                   for k in ("lighting", "props", "particles", "events", "sounds")}
        for a in d["animsets"]:
            if a in animsets:
                continue
            ri = r25_idx.find(animset_path(a))
            li = rl_idx.find(animset_path(a))
            imported = rl_idx.find(animset_path(PREFIX + a)) is not None
            entry = {"in_r25": ri is not None, "in_rl26": li is not None, "imported": imported}
            if ri is not None:
                sizes = r25_idx.sizes(ri)
                entry["r25_entry"], entry["size"] = ri, sizes[1]
                if li is not None:
                    entry["same_as_rl26"] = rl_idx.sizes(li) == sizes
                raw = r25_idx.decoded_blob(ri)
                entry["unsupported_tracks"] = [f"{k}/{e:#x}" for k, e in unsupported_track_types(raw)]
                names = animset_names(raw)
                entry["extra_joints"] = sorted(n for n in set(names) - ref["rig"]
                                               if not CAMERA_JOINT.match(n) and not n.startswith("?"))
            animsets[a] = entry
        catalog["cutscenes"][name] = {
            "file": fn,
            "actors": len(cs.get("actors") or []),
            "cameras": len(cs.get("cameras") or []),
            "deps": d,
            "missing_in_rl26": {k: v for k, v in missing.items() if v},
        }

    os.makedirs(WORK_DIR, exist_ok=True)
    with open(CATALOG_PATH, "w") as f:
        json.dump(catalog, f, indent=1)

    print(f"\n{len(cutscenes)} R25 cutscenes, {len(animsets)} animsets -> {os.path.relpath(CATALOG_PATH, REPO_ROOT)}\n")
    print(f"{'animset':42s} {'status':18s} {'MB':>6s}  cutscenes")
    for a, s in sorted(animsets.items()):
        users = [n for n, c in catalog["cutscenes"].items() if a in c["deps"]["animsets"]]
        mb = f"{s['size'] / 1e6:6.1f}" if "size" in s else "     -"
        print(f"{a:42s} {animset_status(s):18s} {mb}  {len(users):4d}  e.g. {', '.join(users[:3])}")

    if not (args.filter or args.all):
        print("\n(--filter TEXT or --all lists individual cutscenes with their missing dependencies)")
        return
    flt = (args.filter or "").lower()
    print(f"\n{'cutscene':52s} {'file':40s} act cam  animset status / missing in RL26")
    for name, c in catalog["cutscenes"].items():
        if flt and flt not in name.lower() and flt not in c["file"].lower():
            continue
        status = [f"{a}: {animset_status(animsets[a])}" for a in c["deps"]["animsets"]]
        miss = "; ".join(f"{k}={','.join(v[:4])}{'...' if len(v) > 4 else ''}" for k, v in c["missing_in_rl26"].items())
        print(f"{name:52s} {c['file'][:40]:40s} {c['actors']:3d} {c['cameras']:3d}  {' | '.join(status)}"
              + (f"  [missing: {miss}]" if miss else ""))


def animset_status(s):
    if not s["in_r25"]:
        return "NOT IN R25"
    if s.get("unsupported_tracks"):
        return "LOSSY " + ",".join(s["unsupported_tracks"])
    if s.get("imported"):
        return "imported"
    if s["in_rl26"]:
        return "same as RL26" if s.get("same_as_rl26") else "differs from RL26"
    return "new"


# --------------------------------------------------------------------------
# Lua output


LUA_IDENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")
KEY_ORDER = ["name", "animName", "animsetName", "propName", "frame", "weight"]


def lua_str(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n") + '"'


def lua_value(v, depth):
    pad = "\t" * depth
    if isinstance(v, dict):
        if "$expr" in v:
            return v["$expr"]
        if not v:
            return "{}"
        items = []
        for k in sorted(v, key=lambda k: (KEY_ORDER.index(k) if k in KEY_ORDER else len(KEY_ORDER), k)):
            key = k if LUA_IDENT.match(k) else (f"[{k}]" if k.isdigit() else f"[{lua_str(k)}]")
            items.append(f"{pad}\t{key} = {lua_value(v[k], depth + 1)}")
        return "{\n" + ",\n".join(items) + f"\n{pad}}}"
    if isinstance(v, list):
        if not v:
            return "{}"
        return "{\n" + ",\n".join(f"{pad}\t{lua_value(x, depth + 1)}" for x in v) + f"\n{pad}}}"
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, str):
        return lua_str(v)
    if v is None:
        return "nil"
    return repr(v) if isinstance(v, float) else str(v)


def convert(cs, keep_events, label=""):
    """R25 definition -> RL26 definition: animsets renamed to the imported
    r25_ copies, playback events of a type no stock RL26 cutscene uses
    (e.g. R25's ExcitementLevelEvent) dropped."""
    cs = json.loads(json.dumps(cs))
    if cs.get("animsetName"):
        cs["animsetName"] = PREFIX + cs["animsetName"]
    if cs.get("additionalAnimSets"):
        cs["additionalAnimSets"] = [PREFIX + a for a in cs["additionalAnimSets"]]
    # RL26 only shows the match ball for a prop *named* "ball" (setupSceneForCutscene);
    # R25 writes propName = "ball"
    for p in cs.get("props") or []:
        if isinstance(p, dict) and p.get("propName") == "ball" and "name" not in p:
            p["name"] = p.pop("propName")
    if isinstance(cs.get("playbackEvents"), list) and keep_events is not None:
        dropped = sorted({e.get("name") for e in cs["playbackEvents"] if e.get("name") not in keep_events})
        if dropped:
            print(f"  {label}: dropped playback events {dropped}")
        cs["playbackEvents"] = [e for e in cs["playbackEvents"] if e.get("name") in keep_events]
    return cs


def cmd_show(args):
    for fn, path in r25_cutscene_modules():
        data = dump_module(path)
        if args.cutscene in data:
            print(f"-- {fn}")
            print(f"{PREFIX}{args.cutscene} = {lua_value(convert(data[args.cutscene], None), 1)}")
            return
    raise SystemExit(f"{args.cutscene} not found in R25 cutscene data")


# --------------------------------------------------------------------------
# mod config


def load_mod_config(mod_dir):
    path = os.path.join(mod_dir, "imports.json")
    if not os.path.exists(path):
        raise SystemExit(f"{path} not found")
    with open(path) as f:
        return json.load(f)


# --------------------------------------------------------------------------
# facial animation (imports.json "faces")
#
# Both games drive faces the same way: 29 kind-8 tracks on hj_face_loc_driver
# (117 pose weights), played by the native emotion service from emotiongroups
# when a clip fires `emotion_<group>`. RL26 keeps those clips in
# facial.animset; its cutscene clips carry no face tracks. Rugby 25's cutscene
# clips do, and fire emotion_zero at 0 s to let them drive. So each such clip
# gets its face tracks copied into a face clip r25f_<clip> (r25_faces.animset,
# built in RL26's facial.animset container) and its emotion_zero retargeted
# to emotion_r25f_<clip>, a one-clip group: the authored face plays in sync.

FACE_ANIMSET_DEFAULT = "r25_faces"
FACE_PREFIX = "r25f_"
FACE_CONTAINER = "facial"
FACE_DONOR = "face_switchplay_wide_01"  # in both games' facial.animset


def faces_cfg(cfg):
    fc = cfg.get("faces") or {}
    return fc if fc and not fc.get("disabled") else None


def face_clip_name(clip):
    return FACE_PREFIX + strip_m(clip)


def cutscene_face_clips(a):
    """Clips of an (R25) AnimSet with face tracks and an emotion_zero event."""
    out = []
    for c in a.clips:
        if a.face_tracks(c) and "emotion_zero" in a.event_names(c):
            out.append(c)
    return out


def r25_face_sources(cfg, r25_idx, rl_idx):
    """[(face clip name, R25 AnimSet, clip)] for r25_faces.animset: every
    imported cutscene clip's face, then R25 facial.animset clips that
    faces.groups adds and RL26 lacks."""
    fc = faces_cfg(cfg)
    if not fc:
        return []
    out, seen = [], set()
    if fc.get("cutscenes", True):
        cutscenes = load_all_r25_cutscenes()
        sets = dict.fromkeys(a for _, cs in enabled_imports(cfg, cutscenes, r25_idx, verbose=False)
                             for a in dependencies(cs)["animsets"])
        for s in sets:
            a = animset_mod.AnimSet(r25_idx.decoded_blob(r25_idx.find(animset_path(s))))
            for c in cutscene_face_clips(a):
                name = face_clip_name(a.clip_name(c))
                if name not in seen:
                    seen.add(name)
                    out.append((name, a, c))
    wanted = [f for faces in (fc.get("groups") or {}).values() for f in faces]
    rl_faces = set(animset_strings(rl_idx.decoded_blob(rl_idx.find(animset_path(FACE_CONTAINER)))))
    missing = [f for f in dict.fromkeys(wanted) if f not in rl_faces]
    if missing:
        a = animset_mod.AnimSet(r25_idx.decoded_blob(r25_idx.find(animset_path(FACE_CONTAINER))))
        by_name = {a.clip_name(c): c for c in a.clips}
        for f in missing:
            if f not in by_name:
                raise SystemExit(f"faces.groups: {f} is in neither game's facial.animset")
            out.append((f, a, by_name[f]))
    return out


def import_face_animset(args, cfg, r25_idx, rl_idx):
    fc = faces_cfg(cfg)
    sources = r25_face_sources(cfg, r25_idx, rl_idx)
    if not sources:
        return
    fs = animset_mod.AnimSet(rl_idx.decoded_blob(rl_idx.find(animset_path(FACE_CONTAINER))))
    fs.keep_clips([FACE_DONOR])
    fs.transcode_tracks(add_worldroot=False)
    donor = fs.clips[0]
    for name, a, c in sources:
        fs.add_face_clip(donor, name, a.face_tracks(c), struct.unpack_from("<f", c.head, 0)[0])
    fs.drop_clip(donor)
    blob = fs.build()
    dest = animset_path(fc.get("animset", FACE_ANIMSET_DEFAULT))
    print(f"  faces: {len(sources)} R25 face clips -> {dest} "
          f"({sum(n.startswith(FACE_PREFIX) for n, _, _ in sources)} from cutscene clips)")
    ae.add_entry(args.blobset, dest, blob, (len(blob), len(blob), 0, 0),
                 f"Rugby 25 face animation: {len(sources)} clips", args.confirm, replace=True)


def used_clips(cfg, cutscenes, r25_idx, animset):
    """Clip names the enabled imports play from one animset (actors and cameras)."""
    used = set()
    for item, cs in enabled_imports(cfg, cutscenes, r25_idx, verbose=False):
        if animset in dependencies(cs)["animsets"]:
            cs = apply_item_options(cs, item)
            used |= {x["animName"] for x in (cs.get("actors") or []) + (cs.get("cameras") or [])
                     if x.get("animName")}
    return used


def cmd_import(args):
    names = list(args.animsets)
    cfg = load_mod_config(args.mod or DEFAULT_MOD) if (args.mod or not names) else {}
    if args.mod or not names:
        cutscenes = load_all_r25_cutscenes()
        for item in cfg["cutscenes"]:
            if item["name"] not in cutscenes:
                raise SystemExit(f"cutscene {item['name']} not in R25 data")
            if not item.get("disabled"):
                names += dependencies(cutscenes[item["name"]][1])["animsets"]
    r25_idx = Index(args.r25)
    rl_idx = Index(args.blobset)
    # RL26's constant bone offsets (R25's rig has extra roll joints and shorter
    # segments - applied as-is, legs end up ~0.2 m short)
    rl26_statics = animset_mod.rl26_static_offsets(
        rl_idx.decoded_blob(rl_idx.find(animset_path(s))) for s in RL_STATIC_REF_ANIMSETS
        if rl_idx.find(animset_path(s)) is not None)
    for name in dict.fromkeys(names):
        dest = animset_path(PREFIX + name)
        i = r25_idx.find(animset_path(name))
        if i is None:
            raise SystemExit(f"animset {name} not in R25")
        # R25 clip blocks have a 4th sub-block (header 0xB4); RL26 reads clip
        # names at a fixed header offset, so convert to the RL26 layout.
        a = animset_mod.AnimSet(r25_idx.decoded_blob(i))
        if name in (cfg.get("trimAnimsets") or []):
            # only the clips the enabled imports play (R25's walk-on set is 47 MB / 840 clips)
            used = used_clips(cfg, cutscenes, r25_idx, name)
            before = a.count
            a.keep_clips(sorted(used))
            print(f"  {name}: trimmed to the {a.count} of {before} clips the imports use (trimAnimsets)")
        a.to_rl26()
        # add_worldroot stays off: with a synthesized worldroot track the
        # cutscene cameras wander (in-game 2026-10-24); without one RL26 falls
        # back to the clip's root samples, which keeps animated_camera's
        # root-cancelling maths consistent. The players' float was the bone
        # offsets (rl26_statics), not the missing root.
        # imports.json "clipOffsets": {animset: {clip-name substring: [dx, dz]}} moves
        # those clips' scene placement and camera paths (e.g. onto RL26's corridor set;
        # a cutscene's worldPos would move its props and lighting scene with it)
        offsets = {}
        for sub, d in (cfg.get("clipOffsets") or {}).get(name, {}).items():
            offsets.update({a.clip_name(c): tuple(d) for c in a.clips if sub in a.clip_name(c)})
        converted = a.transcode_tracks(add_worldroot=args.worldroot, rl26_statics=rl26_statics,
                                       offsets=offsets)
        if offsets:
            print(f"  {name}: {len(offsets)} clips moved (clipOffsets)")
        faces = 0
        if faces_cfg(cfg) and faces_cfg(cfg).get("cutscenes", True):
            for c in cutscene_face_clips(a):
                faces += a.retarget_event(c, "emotion_zero", "emotion_" + face_clip_name(a.clip_name(c)))
        # R25 cutscene clips end on cutscene faces (cs_exert, cs_exhausted, ...) that stay on
        # the player into gameplay (RL26's end on gameplay faces): hand back to RL26's default
        # face just before each clip with emotion events ends
        reset = 0
        if cfg.get("resetEmotionAtEnd", True):
            for c in a.clips:
                if any(e.startswith("emotion_") for e in a.event_names(c)):
                    dur = struct.unpack_from("<f", c.head, 0)[0]
                    ev = c.subs[-1]
                    times = [struct.unpack_from("<f", ev, 24 + 8 * k)[0]
                             for k in range(struct.unpack_from("<I", ev, 20)[0]) if 32 + 8 * k <= len(ev)]
                    reset += a.add_event(c, "emotion_default", max(dur - 0.1, max(times, default=0.0) + 0.02))
        blob = a.build()
        print(f"  {name}: {converted} tracks re-packed{'/added (worldroot)' if args.worldroot else ''}, "
              f"{a.statics_replaced} bone offsets set to RL26's"
              f"{f', {faces} clips play their own R25 face' if faces else ''}"
              f"{f', {reset} end on the default face' if reset else ''}")
        ae.add_entry(args.blobset, dest, blob, (len(blob), len(blob), 0, 0),
                     f"Rugby 25 entry {i} ({animset_path(name)}), converted to RL26 layout",
                     args.confirm, replace=True)
    if args.mod or not args.animsets:
        import_tackle_animset(args, cfg, r25_idx, rl26_statics)
        import_face_animset(args, cfg, r25_idx, rl_idx)
    if not args.confirm:
        print("dry run - pass --confirm to write (close the game first)")


# --------------------------------------------------------------------------
# gameplay tackles (imports.json "tackles")
#
# RL26 picks tackles from the compiled actionset/tackleset.dat (tackleset.py);
# Rugby 25's own tackle database is a newer version this tool doesn't read.
# Every R25 ru24_X tackle used here has an RL26 counterpart X with the same
# naming, so its entry is a clone of RL26's: same group and tags (so it
# chains into RL26's drive / collapse / get-up stages), clip names prefixed
# ru24_. The clips go into one small animset loaded beside tackle.animset
# (playeranimationset.lua override; universe.lua adds every loaded set to the
# player animation provider). Mirrored entries are left out: RL26 stores
# pre-mirrored data for _m clips, R25 only flags them.

TACKLE_ANIMSET_DEFAULT = "r25_tackles"
PLAYER_ANIMSETS = "game/characteranimation/playeranimationset.lua"


_R25_TACKLE_CLIPS = {}


def r25_tackle_clips(source="tackle"):
    """Clip names in Rugby 25's tackle animset (cached)."""
    if source not in _R25_TACKLE_CLIPS:
        idx = Index(_r25_blobset())
        a = animset_mod.AnimSet(idx.decoded_blob(idx.find(animset_path(source))))
        _R25_TACKLE_CLIPS[source] = {a.clip_name(c) for c in a.clips}
    return _R25_TACKLE_CLIPS[source]


def tackle_plan(cfg, rl_ts):
    """[(r25 base name, group, rl entry node index, [(rl child node, r25 clip)])].
    "entries" lists R25 bases; "auto": true takes every RL26 (unmirrored)
    entry whose ru24_ version and child clips exist in R25 (optionally only
    the stages in "groups")."""
    tk = cfg.get("tackles") or {}
    by_name = {}
    for g, members in rl_ts.groups:
        for m in members:
            by_name.setdefault(rl_ts.nodes[m].name, (g, m))
    bases = list(tk.get("entries", []))
    if tk.get("auto"):
        clips = r25_tackle_clips(tk.get("sourceAnimset", "tackle"))
        want = set(tk.get("groups") or [])
        mirrored = tk.get("mirrored", True)
        for name, (g, m) in by_name.items():
            if (name.endswith("_m") and not mirrored) or (want and g not in want):
                continue
            kids = ["ru24_" + rl_ts.nodes[c].name for c in rl_ts.nodes[m].children]
            # an _m clip is generated from its base clip (add_mirrors)
            if kids and all(strip_m(k) in clips for k in kids) and "ru24_" + name not in bases:
                bases.append("ru24_" + name)
    plan = []
    for base in bases:
        rl_name = base[len("ru24_"):] if base.startswith("ru24_") else base
        if rl_name not in by_name:
            raise SystemExit(f"tackle {base}: no RL26 entry {rl_name} to clone")
        g, m = by_name[rl_name]
        kids = [(c, "ru24_" + rl_ts.nodes[c].name) for c in rl_ts.nodes[m].children]
        plan.append((base, g, m, kids, None))
    # "newTackles": R25 tackles RL26 has no version of (bc_X / t1_X clip
    # pairs), added beside RL26's own by cloning a template entry of the
    # right group and tags; template X_m gives the mirrored entry.
    clips = r25_tackle_clips(tk.get("sourceAnimset", "tackle")) if tk.get("newTackles") else set()
    for item in tk.get("newTackles") or []:
        if item.get("disabled"):
            continue
        tpl = item["template"]
        if tpl not in by_name:
            raise SystemExit(f"newTackles: no RL26 entry {tpl}")
        extra = {"swapTags": item.get("swapTags"), "renameEvents": item.get("renameEvents")}
        for clip in item["clips"]:
            for suffix in ("", "_m") if tk.get("mirrored", True) else ("",):
                if tpl + suffix not in by_name:
                    continue
                g, m = by_name[tpl + suffix]
                kids = []
                for c in rl_ts.nodes[m].children:
                    role = dict(rl_ts.nodes[c].params or []).get("type")
                    if role not in ROLE_PREFIX:
                        raise SystemExit(f"newTackles: {tpl} child {rl_ts.nodes[c].name} has role {role}")
                    kid = ROLE_PREFIX[role] + clip
                    if kid not in clips:
                        raise SystemExit(f"newTackles: {kid} not in R25's tackle animset")
                    kids.append((c, kid + suffix))
                plan.append((clip + suffix, g, m, kids, extra))
    return plan


ROLE_PREFIX = {"BallCarrier": "bc_", "Tackler1": "t1_", "Tackler2": "t2_"}


def strip_m(clip):
    return clip[:-2] if clip.endswith("_m") else clip


def tackle_clip_names(cfg, rl_ts):
    return [clip for _, _, _, kids, _ in tackle_plan(cfg, rl_ts) for _, clip in kids]


def rl_tackleset(blobset):
    idx = Index(blobset)
    return tackleset.TackleSet.parse(pristine_entry_blob(blobset, idx.find(tackleset.LOGICAL_PATH)))


def import_tackle_animset(args, cfg, r25_idx, rl26_statics):
    tk = cfg.get("tackles")
    if not tk or not (tk.get("entries") or tk.get("auto") or tk.get("newTackles")):
        return
    plan = tackle_plan(cfg, rl_tackleset(args.blobset))
    clips = list(dict.fromkeys(clip for _, _, _, kids, _ in plan for _, clip in kids))
    renames = {clip: extra["renameEvents"] for _, _, _, kids, extra in plan
               if extra and extra.get("renameEvents") for _, clip in kids}
    mirrors = [c for c in clips if c.endswith("_m")]
    src = tk.get("sourceAnimset", "tackle")
    i = r25_idx.find(animset_path(src))
    a = animset_mod.AnimSet(r25_idx.decoded_blob(i))
    a.keep_clips(dict.fromkeys(strip_m(c) for c in clips))
    a.to_rl26()
    converted = a.transcode_tracks(add_worldroot=False, rl26_statics=rl26_statics)
    made = a.add_mirrors(set(mirrors)) if mirrors else 0
    if made != len(mirrors):
        print(f"  warning: generated {made} of {len(mirrors)} mirrored clips")
    renamed = 0
    for c in a.clips:  # after add_mirrors: retarget_event's table copy isn't in the raw data mirrors read
        for old, new in (renames.get(a.clip_name(c)) or {}).items():
            renamed += a.retarget_event(c, old, new)
    if renames:
        print(f"  tackles: {renamed} events renamed (newTackles renameEvents)")
    clips = [a.clip_name(c) for c in a.clips]
    blob = a.build()
    dest = animset_path(tk.get("animset", TACKLE_ANIMSET_DEFAULT))
    print(f"  tackles: {len(clips)} clips from R25 {src}.animset -> {dest}, {converted} tracks re-packed, "
          f"{a.statics_replaced} bone offsets set to RL26's")
    ae.add_entry(args.blobset, dest, blob, (len(blob), len(blob), 0, 0),
                 f"Rugby 25 entry {i} ({animset_path(src)}): {len(clips)} tackle clips, converted",
                 args.confirm, replace=True)


# Contact selection (exe 0x9a11d0) gathers candidates into a fixed 128-entry
# stack array and writes through null once it is full. One search takes every
# BigHitContact entry, the matching Contact entries (about half: the unmirrored
# or the mirrored ones) and, near the line, ContactInTry. Stock peaks at 95.
TACKLE_POOL_LIMIT = 128
TACKLE_POOL_MARGIN = 8
TACKLE_POOL_GROUPS = ("BigHitContact", "Contact", "ContactInTry")
TACKLE_EXTRA_DEFAULT = 12


def tackle_pool_size(ts):
    """Worst case candidates for one contact search: entries with no required
    tags that don't ban the search's Mirrored state, plus all big hits."""
    groups = dict(ts.groups)
    worst = 0
    for q in (set(), {"Mirrored"}):
        n = len(groups.get("BigHitContact", []))
        for g in TACKLE_POOL_GROUPS[1:]:
            for i in groups.get(g, []):
                node = ts.nodes[i]
                req = set(node.lists.get(tackleset.TAG_FIELDS["requiredTags"], []))
                ban = set(node.lists.get(tackleset.TAG_FIELDS["bannedTags"], []))
                n += req <= q and not ban & q
        worst = max(worst, n)
    return worst


def build_tackleset(stock, plan, extra, verbose=False):
    """Stock tackle database plus the plan's entries. Counterpart clones
    (auto / entries) replace their RL26 entry except for up to `extra` per
    group, which stay selectable too (mixing); newTackles always add."""
    ts = copy.deepcopy(stock)
    groups = {g: list(members) for g, members in ts.groups}
    kept = {}
    for base, g, m, kids, new in plan:
        kept.setdefault(g, [])
        rl_base = strip_m(ts.nodes[m].name)
        if not new and rl_base not in kept[g] and len(kept[g]) < extra:
            kept[g].append(rl_base)
    for base, g, m, kids, new in plan:
        src = ts.nodes[m]
        lists = {f: list(v) for f, v in src.lists.items()}
        swap = (new or {}).get("swapTags")
        if swap:  # e.g. a left-handed R25 clip cloned from a right-handed template
            a, b = swap
            lists = {f: [b if t == a else a if t == b else t for t in v] for f, v in lists.items()}
        parent = len(ts.nodes)
        ts.nodes.append(tackleset.Node(base, base, src.f0c, [], src.params and list(src.params), lists))
        for c, clip in kids:
            ch = ts.nodes[c]
            ts.nodes[parent].children.append(len(ts.nodes))
            ts.nodes.append(tackleset.Node(base + clip, clip, ch.f0c, [], ch.params and list(ch.params),
                                           {f: list(v) for f, v in ch.lists.items()}))
        groups[g].append(parent)
        both = new or strip_m(src.name) in kept[g]
        if not both and m in groups[g]:
            groups[g].remove(m)  # only the R25 version is selectable
        if verbose:
            how = "new, template" if new else ("clone, RL26 kept" if both else "clone, replaces")
            print(f"  {g}: {base} ({how} {src.name}, tags {lists.get(tackleset.TAG_FIELDS['outTags'])})")
    ts.groups = [(g, groups[g]) for g, _ in ts.groups]
    return ts


def cmd_tackleset(args):
    """Clone the configured RL26 tackle entries with R25 clip names into RL26's
    tackleset.dat (rebuilt from stock each run) and install it."""
    cfg = load_mod_config(args.mod or DEFAULT_MOD)
    rl_idx = Index(args.blobset)
    entry = rl_idx.find(tackleset.LOGICAL_PATH)
    stock = rl_tackleset(args.blobset)
    plan = tackle_plan(cfg, stock)
    test_mode = bool(cfg.get("testMode"))
    # Mixing: up to extraPerGroup tackles per group keep their RL26 counterpart
    # selectable too, lowered until the contact search fits (TACKLE_POOL_LIMIT).
    want = 0 if test_mode else int((cfg.get("tackles") or {}).get("extraPerGroup", TACKLE_EXTRA_DEFAULT))
    limit = TACKLE_POOL_LIMIT - TACKLE_POOL_MARGIN
    for extra in range(want, -1, -1):
        ts = build_tackleset(stock, plan, extra)
        pool = tackle_pool_size(ts)
        if pool <= limit:
            break
    else:
        raise SystemExit(f"too many selectable contact tackles ({pool} > {limit}) even with no RL26 "
                         "counterparts kept: drop some newTackles (BigHitContact / ContactInTry)")
    ts = build_tackleset(stock, plan, extra, verbose=True)
    print(f"contact search: up to {pool} candidates (limit {limit} of the native {TACKLE_POOL_LIMIT}, "
          f"stock {tackle_pool_size(stock)}); RL26 counterparts kept per group: {extra}"
          f"{f' (lowered from extraPerGroup {want})' if extra < want else ''}")
    out_path = os.path.join(REPO_ROOT, "_build", "tackleset_r25.dat")
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    blob = ts.build()
    tackleset.TackleSet.parse(blob)  # sanity: it must read back
    with open(out_path, "wb") as f:
        f.write(blob)
    print(f"{len(plan)} R25 tackles added{' (test mode: RL26 counterparts unselectable)' if test_mode else ''}, "
          f"{len(ts.nodes)} nodes")
    if not args.confirm:
        print(f"wrote {os.path.relpath(out_path, REPO_ROOT)} - dry run, pass --confirm to install (game closed)")
        return
    if os.path.exists(pack.backup_meta_path(entry)):
        pack.do_restore(args.blobset, entry)
    if not plan:
        print("no tackles configured - tackle database left stock")
        return
    pack.do_install(args.blobset, entry, out_path, True)
    print(f"installed; undo with: python pack.py restore --entry {entry}")


TACKLE_CONTACT_ACTION = "ai/tackle/tacklecontact_action.lua"


def tackle_contact_log_lua(cfg):
    """debugLog: tacklecontact_action.lua that appends every contact clip it
    plays to <game>/r25_imports_log.txt (tackle selection is native, so this
    is the only way to see whether an R25 tackle was picked)."""
    if not (cfg.get("debugLog") and (cfg.get("tackles") or {}).get("entries") or
            cfg.get("debugLog") and (cfg.get("tackles") or {}).get("auto")):
        return None
    text = read_stock(TACKLE_CONTACT_ACTION).replace("\r\n", "\n")
    anchor = "\tlocal var_5_1 = var_5_0.animName\n"
    assert text.count(anchor) == 1, "animName anchor not found in " + TACKLE_CONTACT_ACTION
    log = ('\tpcall(function() -- r25-imports debug log (tools/r25_import.py)\n'
           '\t\tlocal var_5_r25Log = io.open("r25_imports_log.txt", "a")\n\n'
           '\t\tif var_5_r25Log then\n'
           '\t\t\tvar_5_r25Log:write(os.date("%H:%M:%S "), "[Tackle] contact ", tostring(var_5_1), "\\n")\n'
           '\t\t\tvar_5_r25Log:close()\n'
           '\t\tend\n'
           '\tend)\n')
    return text.replace(anchor, anchor + log, 1)


def player_animsets_lua(cfg):
    """playeranimationset.lua with the R25 tackle animset loaded beside RL26's."""
    tk = cfg.get("tackles")
    tackles = tk and (tk.get("entries") or tk.get("auto") or tk.get("newTackles"))
    fc = faces_cfg(cfg)
    if not tackles and not fc:
        return None
    text = read_stock(PLAYER_ANIMSETS).replace("\r\n", "\n")
    anchor = '\t\ttackleAnimSet = arg_15_0:load("animations/tackle.animset"),\n'
    assert text.count(anchor) == 1, "tackleAnimSet anchor not found in " + PLAYER_ANIMSETS
    lines = ""
    if tackles:
        lines += f'\t\tr25TackleAnimSet = arg_15_0:load("{animset_path(tk.get("animset", TACKLE_ANIMSET_DEFAULT))}"), ' \
                 f'-- Rugby 25 tackles (tools/r25_import.py)\n'
    if fc:
        lines += f'\t\tr25FacialAnimSet = arg_15_0:load("{animset_path(fc.get("animset", FACE_ANIMSET_DEFAULT))}"), ' \
                 f'-- Rugby 25 faces (tools/r25_import.py)\n'
    return text.replace(anchor, anchor + lines, 1)


def read_stock(rel):
    with open(os.path.join(RL_STOCK, *rel.split("/")), encoding="utf-8-sig", newline="") as f:
        return f.read()


def write_mod_file(mod_dir, rel, text):
    path = os.path.join(mod_dir, "src", "script-game", *rel.split("/"))
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8-sig", newline="") as f:
        f.write(text.replace("\r\n", "\n").replace("\n", "\r\n"))
    print("wrote", os.path.relpath(path, REPO_ROOT))


def enabled_imports(cfg, cutscenes, r25_idx, verbose=True):
    """(item, R25 definition) for every imports.json entry that isn't
    disabled. Track encodings RL26 lacks are reported, not skipped: they
    play, just wrongly (see RL26_TRACK_TYPES)."""
    out = []
    for item in cfg["cutscenes"]:
        name = item["name"]
        if item.get("disabled"):
            if verbose:
                print(f"  {name}: disabled in imports.json")
            continue
        if name not in cutscenes:
            raise SystemExit(f"cutscene {name} not in R25 data")
        cs = cutscenes[name][1]
        if verbose:
            for a in dependencies(cs)["animsets"]:
                i = r25_idx.find(animset_path(a))
                bad = unsupported_track_types(r25_idx.decoded_blob(i)) if i is not None else []
                if bad:
                    print(f"  {name}: {a} has track encodings RL26 decodes wrongly "
                          f"{[f'{k}/{e:#x}' for k, e in bad]} - will look off until converted")
        out.append((item, cs))
    return out


def pristine_entry_blob(blobset_path, entry_index):
    """Decoded stock bytes of an entry, from pack.py's backup if it's installed."""
    meta_path = pack.backup_meta_path(entry_index)
    if not os.path.exists(meta_path):
        return Index(blobset_path).decoded_blob(entry_index)
    with open(meta_path) as f:
        meta = json.load(f)
    with open(meta["blob_backup"], "rb") as f:
        raw = f.read()
    if meta["main_compressed_size"] == meta["main_uncompressed_size"]:
        return raw
    return ce.decode_outer_zstd_frames(raw)


# Stock RL26: 7013 clips. 8033 played fine; 8873 froze the game in native
# posing code while the match intro loaded (2026-10-24), most likely a 2^13
# limit somewhere in the engine.
MOTIONSET_LIMIT = 8192


def cmd_motionset(args):
    """Merge the motion-set records of every enabled import's clips into
    RL26's animations/motionset.motionset (rebuilt from stock each run)."""
    cfg = load_mod_config(args.mod or DEFAULT_MOD)
    cutscenes = load_all_r25_cutscenes()
    r25_idx, rl_idx = Index(args.r25), Index(args.blobset)
    rl_entry = rl_idx.find(motionset.LOGICAL_PATH)
    base = motionset.MotionSet.parse(pristine_entry_blob(args.blobset, rl_entry))
    r25_ms = motionset.MotionSet.parse(r25_idx.decoded_blob(r25_idx.find(motionset.LOGICAL_PATH)))
    r25_pos = {n: i for i, n in enumerate(r25_ms.names)}
    rl_names = set(base.names)

    added, clashes = [], []
    animsets = dict.fromkeys(a for _, cs in enabled_imports(cfg, cutscenes, r25_idx, verbose=False)
                             for a in dependencies(cs)["animsets"])
    for a in animsets:
        clips = [n for n in animset_strings(r25_idx.decoded_blob(r25_idx.find(animset_path(a)))) if n in r25_pos]
        if a in (cfg.get("trimAnimsets") or []):
            used = used_clips(cfg, cutscenes, r25_idx, a)
            clips = [n for n in clips if n in used]  # only what the trimmed animset ships
        for clip in clips:
            if clip in rl_names:
                if r25_ms.records[r25_pos[clip]] != base.records[base.index(clip)]:
                    clashes.append(clip)
                continue
            base.add(clip, r25_ms.records[r25_pos[clip]])
            rl_names.add(clip)
            added.append(clip)
        print(f"  {a}: {len(clips)} clips in R25's motion set")
    if cfg.get("tackles"):
        tclips = [c for c in tackle_clip_names(cfg, rl_tackleset(args.blobset)) if c in r25_pos]
        for clip in tclips:
            if clip not in rl_names:
                base.add(clip, r25_ms.records[r25_pos[clip]])
                rl_names.add(clip)
                added.append(clip)
        print(f"  tackles: {len(tclips)} clips in R25's motion set")
    print(f"adding {len(added)} clip records to RL26's motion set (entry {rl_entry}), "
          f"{len(base.names)} total (limit {MOTIONSET_LIMIT})")
    if len(base.names) > MOTIONSET_LIMIT:
        raise SystemExit(f"motion set would hold {len(base.names)} clips: over {MOTIONSET_LIMIT} the game "
                         "froze in the match intro (2026-10-24). Trim animsets (trimAnimsets) or drop imports.")
    if clashes:
        print(f"  warning: {len(clashes)} clip names already in RL26 with different data (kept RL26's): {clashes[:6]}")

    out_path = os.path.join(REPO_ROOT, "_build", "motionset_r25.motionset")
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, "wb") as f:
        f.write(base.build())
    if not args.confirm:
        print(f"wrote {os.path.relpath(out_path, REPO_ROOT)} - dry run, pass --confirm to install (game closed)")
        return
    if os.path.exists(pack.backup_meta_path(rl_entry)):
        pack.do_restore(args.blobset, rl_entry)
    if not added:
        print("nothing to add - motion set left stock")
        return
    pack.do_install(args.blobset, rl_entry, out_path, True)
    print(f"installed; undo with: python pack.py restore --entry {rl_entry}")


EMOTION_GROUPS = "intermediatelua/animations/emotiongroups.lua"


def emotion_groups_lua(r25_idx, rl_idx, animsets, emotion_map=None, emotion_loop=False,
                       face_clips=(), face_additions=None):
    """Stock emotiongroups.lua plus every group an imported clip fires as an
    `emotion_<group>` event but RL26 lacks (native lookup of a missing group
    is a null dereference at exe+0x878fcf). emotion_map (imports.json
    "emotionMap", {missing group: RL26 group}) picks the stand-in; otherwise
    R25's definition is used when RL26 has its face anims, else RL26's
    `default` group. R25 clips mostly just fire emotion_zero at the start
    ("neutral - the face-rig curves drive the face"), and RL26 can't play
    those curves, so a try celebration reads better with zero -> celebrate."""
    emotion_map = emotion_map or {}
    def groups_of(path, root):
        res = subprocess.run([LUAJIT_EXE, DUMPER, path, root, "groups"], capture_output=True, text=True)
        if res.returncode != 0:
            raise RuntimeError(res.stderr.strip())
        return json.loads(res.stdout)

    rl_groups = groups_of(os.path.join(RL_EXTRACTED, *EMOTION_GROUPS.split("/")), RL_EXTRACTED)
    r25_groups = groups_of(os.path.join(R25_SCRIPTS, *EMOTION_GROUPS.split("/")), R25_SCRIPTS)
    rl_faces = set(animset_strings(rl_idx.decoded_blob(rl_idx.find("animations/facial.animset"))))
    needed = []
    for a in animsets:
        raw = r25_idx.decoded_blob(r25_idx.find(animset_path(a)))
        for s in animset_strings(raw):
            g = s[len("emotion_"):] if s.startswith("emotion_") else None
            if g and g not in rl_groups and g not in needed:
                needed.append(g)
    face_additions = {g: f for g, f in (face_additions or {}).items() if f}
    if not needed and not face_clips and not face_additions:
        return None, []
    added = []
    for g in needed:
        src = r25_groups.get(g)
        mapped = emotion_map.get(g)
        mapped = [mapped] if isinstance(mapped, str) else (mapped or [])
        mapped = [m for m in mapped if m in rl_groups]
        if mapped:
            # several RL26 groups -> one pool the idle service picks from at random
            anims = {}
            for m in mapped:
                anims.update(json.loads(json.dumps(rl_groups[m].get("anims") or {})))
            if emotion_loop:
                for a in anims.values():
                    a.pop("maxLoopCount", None)  # keep cycling faces instead of settling
            added.append((g, {"anims": anims}, f"RL26 {'+'.join(mapped)} faces (emotionMap)"))
        elif src and all(face in rl_faces for face in (src.get("anims") or {})):
            added.append((g, src, "R25 definition"))
        else:
            added.append((g, rl_groups["default"], "RL26 default faces"))
    for clip in face_clips:  # a cutscene clip's own face, fired by its retargeted emotion_zero
        added.append((clip, {"anims": {clip: {"maxLoopCount": 1, "frequency": 1}}}, "Rugby 25 cutscene face"))
    for g in face_additions:
        if g not in rl_groups:
            raise SystemExit(f"faces.groups: RL26 has no emotion group {g}")
    text = read_stock(EMOTION_GROUPS).replace("\r\n", "\n").rstrip()
    assert text.startswith("groups = {"), "unexpected start of " + EMOTION_GROUPS
    # groups = { ... } is the file's only top-level table; add entries before its closing brace
    close = text.index("\n}")
    body = "".join(f",\n\t-- {why}, for Rugby 25 imports (tools/r25_import.py)\n\t{g} = {lua_value(d, 1)}"
                   for g, d, why in added)
    tail = ""
    if face_additions:
        # extra faces join RL26's groups with the options of the group's first face
        tail = ("\n\n-- Rugby 25 faces added to RL26 groups (imports.json faces.groups, tools/r25_import.py)\n"
                f"for iter_r25_g, iter_r25_faces in pairs({lua_value(face_additions, 0)}) do\n"
                "\tlocal var_r25_anims = groups[iter_r25_g].anims\n"
                "\tlocal var_r25_template = {}\n\n"
                "\tfor iter_r25_k, iter_r25_v in pairs(var_r25_anims) do\n"
                "\t\tvar_r25_template = iter_r25_v\n\n"
                "\t\tbreak\n"
                "\tend\n\n"
                "\tfor iter_r25_i, iter_r25_face in ipairs(iter_r25_faces) do\n"
                "\t\tlocal var_r25_options = {}\n\n"
                "\t\tfor iter_r25_k, iter_r25_v in pairs(var_r25_template) do\n"
                "\t\t\tvar_r25_options[iter_r25_k] = iter_r25_v\n"
                "\t\tend\n\n"
                "\t\tvar_r25_anims[iter_r25_face] = var_r25_options\n"
                "\tend\n"
                "end\n")
        added += [(g, None, f"+{len(f)} R25 faces") for g, f in face_additions.items()]
    return text[:close] + body + text[close:] + tail + "\n", [(g, why) for g, d, why in added]


def intro_sequences_lua(cfg):
    """imports.json "introSequences": alternative versions of stock intro
    sequences (e.g. the regular intro with the separate team run-outs swapped
    for R25's two-team run-out). Built at load time from whatever SequenceList
    holds and published as SequenceAlternatives = {stock name: {{name,
    weight}, ...}}; match-intro-versus' getInitialCutsceneName picks one per
    match from the match seed (stock RL26 ignores the table)."""
    specs = [s for s in cfg.get("introSequences") or [] if not s.get("disabled")]
    if not specs:
        return ""
    rows = []
    for s in specs:
        rows.append({"name": s["name"], "cutscene": PREFIX + s["cutscene"], "weight": s.get("weight", 1),
                     "stockWeight": s.get("stockWeight", 1), "sequences": s["sequences"],
                     "drop": {c: True for c in s.get("drop", [])}, "before": s.get("before", "")})
    return "\n".join([
        "",
        "-- Rugby 25 intro sequence alternatives (imports.json introSequences, tools/r25_import.py).",
        "-- match-intro-versus (getInitialCutsceneName) picks one per match from the match seed.",
        f"local var_0_r25IntroSequences = {lua_value(rows, 0)}",
        "",
        "SequenceAlternatives = SequenceAlternatives or {}",
        "",
        "for iter_0_r25Index, iter_0_r25Spec in ipairs(var_0_r25IntroSequences) do",
        "\tfor iter_0_r25Seq, iter_0_r25Base in ipairs(iter_0_r25Spec.sequences) do",
        "\t\tlocal var_0_r25Stock = SequenceList[iter_0_r25Base]",
        "",
        "\t\tif var_0_r25Stock and var_0_r25Stock.cutscenes then",
        "\t\t\tlocal var_0_r25List = {}",
        "\t\t\tlocal var_0_r25Inserted = false",
        "",
        "\t\t\tfor iter_0_r25C, iter_0_r25Name in ipairs(var_0_r25Stock.cutscenes) do",
        "\t\t\t\tif iter_0_r25Name == iter_0_r25Spec.before and not var_0_r25Inserted then",
        "\t\t\t\t\ttable.insert(var_0_r25List, iter_0_r25Spec.cutscene)",
        "",
        "\t\t\t\t\tvar_0_r25Inserted = true",
        "\t\t\t\tend",
        "",
        "\t\t\t\tif not iter_0_r25Spec.drop[iter_0_r25Name] then",
        "\t\t\t\t\ttable.insert(var_0_r25List, iter_0_r25Name)",
        "\t\t\t\tend",
        "\t\t\tend",
        "",
        "\t\t\tif not var_0_r25Inserted then",
        "\t\t\t\ttable.insert(var_0_r25List, iter_0_r25Spec.cutscene)",
        "\t\t\tend",
        "",
        "\t\t\tlocal var_0_r25Name = iter_0_r25Spec.name .. \"_\" .. iter_0_r25Base",
        "",
        "\t\t\tSequenceList[var_0_r25Name] = {",
        "\t\t\t\tcutscenes = var_0_r25List,",
        "\t\t\t\tlightingScenes = var_0_r25Stock.lightingScenes",
        "\t\t\t}",
        "",
        "\t\t\tif not SequenceAlternatives[iter_0_r25Base] then",
        "\t\t\t\tSequenceAlternatives[iter_0_r25Base] = {",
        "\t\t\t\t\t{",
        "\t\t\t\t\t\tname = iter_0_r25Base,",
        "\t\t\t\t\t\tweight = iter_0_r25Spec.stockWeight",
        "\t\t\t\t\t}",
        "\t\t\t\t}",
        "\t\t\tend",
        "",
        "\t\t\ttable.insert(SequenceAlternatives[iter_0_r25Base], {",
        "\t\t\t\tname = var_0_r25Name,",
        "\t\t\t\tweight = iter_0_r25Spec.weight",
        "\t\t\t})",
        "\t\tend",
        "\tend",
        "end",
        ""])


def cmd_gen_mod(args):
    mod_dir = args.mod or DEFAULT_MOD
    cfg = load_mod_config(mod_dir)
    cutscenes = load_all_r25_cutscenes()
    rl_idx = Index(args.blobset)
    stock = rl_stock_cutscenes()
    keep_events = {e for cs in stock.values() for e in dependencies(cs)["events"]}
    # plus every playback event name stock uses that doesn't end in "Event" (EnableLightGroup)
    keep_events |= {e.get("name") for cs in stock.values() for e in cs.get("playbackEvents") or []
                    if isinstance(e, dict) and isinstance(e.get("name"), str)}

    r25_idx = Index(args.r25)
    defs, groups = [], {}
    enabled = enabled_imports(cfg, cutscenes, r25_idx)

    fc = faces_cfg(cfg) or {}
    emotions_text, emotions = emotion_groups_lua(
        r25_idx, rl_idx, dict.fromkeys(a for _, cs in enabled for a in dependencies(cs)["animsets"]),
        cfg.get("emotionMap"), cfg.get("emotionLoop", False),
        [n for n, _, _ in r25_face_sources(cfg, r25_idx, rl_idx) if n.startswith(FACE_PREFIX)],
        fc.get("groups"))
    emotions_path = os.path.join(mod_dir, "src", "script-game", *EMOTION_GROUPS.split("/"))
    if emotions_text:
        write_mod_file(mod_dir, EMOTION_GROUPS, emotions_text)
        print(f"  added emotion groups: {emotions}")
    elif os.path.exists(emotions_path):
        os.remove(emotions_path)

    contact_lua = tackle_contact_log_lua(cfg)
    contact_path = os.path.join(mod_dir, "src", "script-game", *TACKLE_CONTACT_ACTION.split("/"))
    if contact_lua:
        write_mod_file(mod_dir, TACKLE_CONTACT_ACTION, contact_lua)
    elif os.path.exists(contact_path):
        os.remove(contact_path)

    player_lua = player_animsets_lua(cfg)
    player_path = os.path.join(mod_dir, "src", "script-game", *PLAYER_ANIMSETS.split("/"))
    if player_lua:
        write_mod_file(mod_dir, PLAYER_ANIMSETS, player_lua)
    elif os.path.exists(player_path):
        os.remove(player_path)

    stock_groups = rl_stock_group_names()
    exclusive = set()
    for item, cs in enabled:
        name = item["name"]
        for a in dependencies(cs)["animsets"]:
            if rl_idx.find(animset_path(PREFIX + a)) is None:
                print(f"  warning: animset {PREFIX + a} not imported yet - run `r25_import.py import --confirm`")
        defs.append(f"\t{PREFIX}{name} = {lua_value(convert(apply_item_options(cs, item), keep_events, name), 1)}")
        for g in item.get("groups", []):
            if g not in groups and g not in stock_groups and rl_stock_cutscene_exists(g):
                # a plain RL26 cutscene (e.g. rl1_corridor_home_02 in an intro
                # sequence) becomes a group: the stock shot stays a choice
                groups[g] = [(g, item["stockWeight"])] if item.get("stockWeight", 1) else []
            groups.setdefault(g, []).append((PREFIX + name, item.get("weight", 1)))
            if item.get("exclusive"):
                exclusive.add(g)  # the imports replace the group's stock entries

    carrier = read_stock(CARRIER).replace("\r\n", "\n").rstrip()
    assert carrier.endswith("}"), "unexpected end of " + CARRIER
    carrier = carrier[:-1].rstrip() + ",\n\t-- imported from Rugby 25 by tools/r25_import.py\n" + ",\n".join(defs) + "\n}\n"
    # modules the imported definitions reference (actor filters use sidehelper.home/away);
    # the stock carrier imports none, and a nil global aborts the boot
    for module, token in (("base.side.sidehelper", "sidehelper."),):
        line = f'import("{module}")\n'
        if token in "".join(defs) and line not in carrier:
            carrier = line + carrier
    write_mod_file(mod_dir, CARRIER, carrier)

    config = read_stock(CONFIG).replace("\r\n", "\n")
    anchor = "GroupList = cutscenegroupdata_config.GroupList\n"
    assert config.count(anchor) == 1, "GroupList anchor not found in " + CONFIG
    lines = ["", "-- Rugby 25 imports (tools/r25_import.py): appended to the stock groups at load time.",
             "local var_0_r25Groups = {"]
    for g, entries in groups.items():
        lines.append(f"\t{g} = {{")
        lines += [f'\t\t{{ name = "{n}", weight = {w} }},' for n, w in entries]
        lines.append("\t},")
    test_mode = bool(cfg.get("testMode"))
    lines += ["}", "",
              f"local var_0_r25TestMode = {'true' if test_mode else 'false'}",
              "-- groups whose stock entries an import replaces (imports.json \"exclusive\")",
              "local var_0_r25Exclusive = {" + "".join(f" {g} = true," for g in sorted(exclusive)) + " }", "",
              "for iter_0_r25Group, iter_0_r25Entries in pairs(var_0_r25Groups) do",
              "\t-- test mode: the imports become the only choices in their groups",
              "\tif var_0_r25TestMode or var_0_r25Exclusive[iter_0_r25Group] or not GroupList[iter_0_r25Group] then",
              "\t\tGroupList[iter_0_r25Group] = {}",
              "\tend",
              "",
              "\tfor iter_0_r25Index, iter_0_r25Entry in ipairs(iter_0_r25Entries) do",
              "\t\ttable.insert(GroupList[iter_0_r25Group], iter_0_r25Entry)",
              "\tend",
              "end", ""]
    if cfg.get("debugLog"):
        lines.append(DEBUG_LOG_LUA)
    config = config.replace(anchor, anchor + "\n".join(lines), 1)
    seq_lua = intro_sequences_lua(cfg)
    if seq_lua:
        config = config.rstrip("\n") + "\n" + seq_lua
    if cfg.get("debugLog"):
        # runs after the stock MappedNamesToFiles loop has loaded the carrier module
        config = config.rstrip("\n") + "\n\n" + "\n".join(
            [f'var_0_r25Write("  mapped {PREFIX}{item["name"]}: " .. tostring(MappedNamesToFiles["{PREFIX}{item["name"]}"]))'
             for item in cfg["cutscenes"]]) + "\n"
    write_mod_file(mod_dir, CONFIG, config)
    print(f"test mode {'ON' if test_mode else 'off'}, debug log {'ON' if cfg.get('debugLog') else 'off'}")


# Appended to cutscenedata_config.lua when imports.json has "debugLog": true.
# Retail print/formatPrint output goes nowhere (memory: lua-file-logging), so
# cutscene-related messages are copied to <game folder>/r25_imports_log.txt.
# Repeats of the same message (the per-frame "Waiting for ..." lines) are
# collapsed into one line with a count.
DEBUG_LOG_LUA = '''-- r25-imports debug log -> <game folder>/r25_imports_log.txt
local var_0_r25LogLast
local var_0_r25LogRepeats = 0

local function var_0_r25Write(arg_0_text)
	pcall(function()
		local var_0_file = io.open("r25_imports_log.txt", "a")

		if var_0_file then
			var_0_file:write(os.date("%H:%M:%S "), arg_0_text, "\\n")
			var_0_file:close()
		end
	end)
end

local function var_0_r25Log(arg_0_text)
	if arg_0_text == var_0_r25LogLast then
		var_0_r25LogRepeats = var_0_r25LogRepeats + 1

		if var_0_r25LogRepeats == 1 or var_0_r25LogRepeats % 300 == 0 then
			var_0_r25Write("  (repeated " .. var_0_r25LogRepeats .. "x)")
		end

		return
	end

	var_0_r25LogLast = arg_0_text
	var_0_r25LogRepeats = 0

	var_0_r25Write(arg_0_text)
end

local function var_0_r25Interesting(arg_0_text)
	local var_0_lower = string.lower(arg_0_text)

	return string.find(var_0_lower, "cutscene", 1, true) or string.find(var_0_lower, "animset", 1, true)
end

local function var_0_r25Wrap(arg_0_name, arg_0_format)
	local var_0_original = _G[arg_0_name]

	_G[arg_0_name] = function(...)
		local var_0_args = { ... }

		pcall(function()
			local var_0_text = arg_0_format(var_0_args)

			if var_0_r25Interesting(var_0_text) then
				var_0_r25Log(var_0_text)
			end
		end)

		if var_0_original then
			return var_0_original(...)
		end
	end
end

local function var_0_r25Concat(arg_0_args)
	local var_0_parts = {}

	for iter_0_index = 1, table.maxn(arg_0_args) do
		var_0_parts[iter_0_index] = tostring(arg_0_args[iter_0_index])
	end

	return table.concat(var_0_parts, " ")
end

var_0_r25Wrap("print", var_0_r25Concat)
var_0_r25Wrap("formatPrint", function(arg_0_args)
	local var_0_ok, var_0_text = pcall(string.format, unpack(arg_0_args))

	return var_0_ok and var_0_text or var_0_r25Concat(arg_0_args)
end)
var_0_r25Wrap("formatPrintT", function(arg_0_args)
	-- %t is the engine's "tostring anything" specifier
	local var_0_index = 1
	local var_0_text = string.gsub(tostring(arg_0_args[1]), "%%[ts]", function()
		var_0_index = var_0_index + 1

		return tostring(arg_0_args[var_0_index])
	end)

	return var_0_text
end)

var_0_r25Write("---- r25-imports loaded, test mode " .. tostring(var_0_r25TestMode))

for iter_0_r25Group, iter_0_r25Entries in pairs(var_0_r25Groups) do
	local var_0_names = {}

	for iter_0_index, iter_0_entry in ipairs(GroupList[iter_0_r25Group]) do
		table.insert(var_0_names, iter_0_entry.name .. "=" .. tostring(iter_0_entry.weight))
	end

	var_0_r25Write("  " .. iter_0_r25Group .. ": " .. table.concat(var_0_names, ", "))
end
'''


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--blobset", default=pack.BLOBSET_PATH, help="RL26 data-0.blobset.pc")
    ap.add_argument("--r25", default=None, help="Rugby 25 data-0.blobset.pc (default: found via tools/games.py)")
    sub = ap.add_subparsers(dest="cmd", required=True)

    sub.add_parser("setup", help="extract R25's lua bundle").set_defaults(func=cmd_setup)

    p = sub.add_parser("scan", help="catalog R25 cutscenes + animsets against RL26")
    p.add_argument("--filter", help="list cutscenes whose name/file contains this")
    p.add_argument("--all", action="store_true", help="list every cutscene")
    p.set_defaults(func=cmd_scan)

    p = sub.add_parser("show", help="print one R25 cutscene converted to RL26 Lua")
    p.add_argument("cutscene")
    p.set_defaults(func=cmd_show)

    p = sub.add_parser("import", help="append R25 animsets to RL26 as animations/r25_<name>.animset")
    p.add_argument("animsets", nargs="*", help="R25 animset names (default: everything the mod's imports.json needs)")
    p.add_argument("--mod", help=f"mod folder with imports.json (default {os.path.relpath(DEFAULT_MOD, REPO_ROOT)})")
    p.add_argument("--worldroot", action="store_true",
                   help="also synthesize a worldroot track (experimental: makes cutscene cameras wander)")
    p.add_argument("--confirm", action="store_true")
    p.set_defaults(func=cmd_import)

    p = sub.add_parser("motionset", help="merge the enabled imports' clip records into RL26's motion set")
    p.add_argument("--mod")
    p.add_argument("--confirm", action="store_true")
    p.set_defaults(func=cmd_motionset)

    p = sub.add_parser("tackleset", help="add the configured R25 tackles to RL26's tackle database")
    p.add_argument("--mod")
    p.add_argument("--confirm", action="store_true")
    p.set_defaults(func=cmd_tackleset)

    p = sub.add_parser("gen-mod", help="write the mod's Lua overrides from its imports.json")
    p.add_argument("--mod")
    p.set_defaults(func=cmd_gen_mod)

    args = ap.parse_args()
    if getattr(args, "r25", "") is None:
        args.r25 = _r25_blobset()
    args.func(args)


if __name__ == "__main__":
    main()
