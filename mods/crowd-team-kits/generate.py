#!/usr/bin/env python3
"""
generate.py - regenerate the club kit table inside this mod's
crowd_item_config.lua override (the block between the GENERATED markers).

For every club in defaultdata_clubs it records the top colour texture of
each kit, in club order (uniformTop design guid -> colTexture from
design/characters/assetmapitems.lua, plus rll4-legacy-kits' tops).

The crowd does NOT use the player uniform textures: it loads its own copy,
crowd/characters/textures/<name>.texture, and the engine aborts the match
load (0xC0000409) if that file is missing. Only the 2025 kits ship crowd
copies, so kits without one are left out until bake_crowd_jerseys.py adds
it. The check runs against the live blobset index.

Clubs are grouped into "families" by name - "Brisbane Broncos 2025",
"Brisbane Broncos" and "GF Brisbane Broncos" are one family - so a club's fans
can wear the other seasons' jerseys and borrow merch (polos, caps, beanies,
scarves) the shipped crowd data only has for the 2025 ids.

Reads the clubs data from the INSTALLED entry 39957 by default (so kits added
by data mods are included); rerun after changing club kit mods or adding
crowd textures, then rebuild entry 39959.

    python mods\\crowd-team-kits\\generate.py            # installed 39957
    python mods\\crowd-team-kits\\generate.py --clubs <extracted defaultdata_clubs>
"""

import argparse
import os
import re
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import classify_entries as ce  # noqa: E402
import data_mods as dm  # noqa: E402
import add_entries as ae  # noqa: E402
import extract_m3mp as em  # noqa: E402
import pack  # noqa: E402
import entries  # noqa: E402
import parse_club_jersey as pcj  # noqa: E402
import parse_clubs as pc  # noqa: E402

CLUBS_ENTRY = entries.index_of("licenseddata")  # defaultdata_clubs (1.0.5887: 39957)
ASSETMAP_ITEMS = os.path.join(ROOT, "decompiled", "src", "script-game", "design", "characters", "assetmapitems.lua")
STADIUMS = os.path.join(ROOT, "decompiled", "src", "script-game", "intermediatelua", "convant", "stadiums.lua")
TARGET = os.path.join(HERE, "src", "script-game", "intermediatelua", "crowd", "crowd_item_config.lua")
BEGIN, END = "-- BEGIN GENERATED (generate.py)", "-- END GENERATED"

# names that don't line up after stripping prefixes/suffixes
FAMILY_ALIASES = {
    "St George Dragons Women": "St George Illawarra Dragons Women",
    "York Valkyrie Women": "York Valkyrie",
    "Salford RLFC": "Salford Red Devils",
}
TOP_TEXTURE = re.compile(r"^[mf]_top_.+_col$")


def family_name(full_name):
    name = re.sub(r"^(GF|Decider) ", "", full_name)
    name = re.sub(r" 2025$", "", name)
    return FAMILY_ALIASES.get(name, name)


def load_clubs(path):
    if path:
        with open(path, "rb") as f:
            return f.read()
    ce.load_index(pack.BLOBSET_PATH)
    raw, _folder, _hash, bpath = ce.read_blob_full(pack.BLOBSET_PATH, CLUBS_ENTRY)
    if raw is None:
        raise RuntimeError(f"entry {CLUBS_ENTRY}: blob not found at {bpath}")
    _records, files = em.decode_m3mp(raw)
    return next(v for k, v in files.items() if k.replace("\\", "/").endswith("defaultdata/defaultdata_clubs"))


def load_top_textures():
    """uniformTop guid -> colTexture from the stock asset map."""
    with open(ASSETMAP_ITEMS, encoding="utf-8-sig") as f:
        lines = f.read().split("\n")
    tops, cur = {}, {}
    for line in lines[lines.index("\tuniformTop = {") + 1:]:
        if re.match(r"^\t\w+ = \{", line):
            break
        m = re.match(r"^\t\t\t\t(guid|colTexture) = (.*),$", line)
        if m:
            cur[m.group(1)] = m.group(2).strip('"')
        elif line in ("\t\t\t}", "\t\t\t},"):
            if "guid" in cur:
                tops[int(cur["guid"])] = cur.get("colTexture")
            cur = {}
    # tops added by mods: rll4-legacy-kits' kits table in jigglyjointsconfig.lua,
    # rows like { 60001, "broncos_rll4_home_2024", ... } -> m_top_<name>_col
    mod_config = os.path.join(ROOT, "mods", "rll4-legacy-kits", "src", "script-game", "intermediatelua", "data",
                              "jigglyjointsconfig.lua")
    if os.path.exists(mod_config):
        with open(mod_config, encoding="utf-8-sig") as f:
            for guid, name in re.findall(r'\{ (\d+), "(\w+)", \{', f.read()):
                tops.setdefault(int(guid), f"m_top_{name}_col")
    return tops


def crowd_texture_exists():
    """Returns a predicate: can the crowd load this texture? It needs both the
    crowd copy in the live index (keyed by the hash of the lowercased logical
    path) and a record in the crowd texture table, entry 39871 - the crowd
    aborts the match load on a name the table doesn't list."""
    import bake_crowd_jerseys as bake
    data, files_count, hash_off, _size_off = pack.read_index(pack.BLOBSET_PATH)
    hashes = set(ae.load_hashes(data, files_count, hash_off))
    ce.load_index(pack.BLOBSET_PATH)
    _version, records = bake.crowd_texture_table(ce.read_blob_full(pack.BLOBSET_PATH, bake.TEXTURE_TABLE_ENTRY)[0])
    registered = {r[0] for r in records}
    return lambda tex: (ae.path_hash(f"crowd/characters/textures/{tex}.texture") in hashes
                        and bake.fnv1a32(tex) in registered)


def stadium_node_counts():
    """Node file -> crowd node count, for every stadium name in
    intermediatelua/convant/stadiums.lua (plus "stadium", the creator's).
    A node file is crowd/nodefiles/<stadium>_crowdnodes.nodefile (see
    rendering/modules/stadium_module.lua); its u32 at offset 16 is the node
    count (80-byte records follow)."""
    with open(STADIUMS, encoding="utf-8-sig") as f:
        names = set(re.findall(r'"([A-Za-z0-9_]+)"', f.read())) | {"stadium"}
    data, files_count, hash_off, _size_off = pack.read_index(pack.BLOBSET_PATH)
    entries = {h: i for i, h in enumerate(ae.load_hashes(data, files_count, hash_off))}
    ce.load_index(pack.BLOBSET_PATH)
    counts = {}
    for name in names:
        path = f"crowd/nodefiles/{name}_crowdnodes.nodefile".lower()
        entry = entries.get(ae.path_hash(path))
        if entry is not None:
            counts[path] = struct.unpack_from("<I", ce.read_blob_full(pack.BLOBSET_PATH, entry)[0], 16)[0]
    return counts


def read_kits(data):
    name_h, top_h = pcj.fnv1a32("name"), pcj.fnv1a32("uniformTop")
    anchors = pc.find_anchors(data)
    clubs = []
    for i, a in enumerate(anchors):
        bound = anchors[i + 1][0] if i + 1 < len(anchors) else len(data)
        lay = dm._uniform_layout(data, a[1], bound)
        kits = []
        if lay:
            count = struct.unpack_from("<H", data, lay["count_pos"])[0]
            name_f, top_f = lay["record_fields"][name_h], lay["config_fields"][top_h]
            for k in range(count):
                rec = lay["records_pos"] + k * lay["record_size"]
                kit_name = data[rec + name_f[0]:rec + name_f[0] + name_f[2]].split(b"\0")[0].decode("latin1")
                guid = struct.unpack_from(dm.UNIFORM_TAG_FMT[top_f[1]], data, rec + lay["config_off"] + top_f[0])[0]
                kits.append((kit_name, guid))
        clubs.append((a[2], a[3], kits))
    return clubs


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--clubs", help="extracted defaultdata_clubs file (default: read installed entry 39957)")
    args = ap.parse_args()

    tops = load_top_textures()
    has_crowd_copy = crowd_texture_exists()
    clubs = read_kits(load_clubs(args.clubs))

    family_ids = {}
    for club_id, full_name, _kits in clubs:
        family_ids.setdefault(family_name(full_name), club_id)

    out = [BEGIN,
           "-- club id -> family id (lowest club id sharing the name) and the top",
           "-- textures of its kits that have a crowd copy, in club order",
           "local clubKits = {"]
    skipped = []
    for club_id, full_name, kits in clubs:
        entries = []
        for kit_name, guid in kits:
            tex = tops.get(guid)
            if not tex or not TOP_TEXTURE.match(tex) or not has_crowd_copy(tex):
                skipped.append(f"{club_id} {full_name}: {kit_name} ({guid} {tex})")
                continue
            entries.append(f'"{tex}"')
        out.append(f"\t[{club_id}] = {{ family = {family_ids[family_name(full_name)]}, kits = {{ {', '.join(entries)} }} }}, -- {full_name}")
    out += ["}",
            "-- crowd node count per stadium node file (lowercased path), for the Souths guy odds",
            "local stadiumNodes = {"]
    for path, count in sorted(stadium_node_counts().items()):
        out.append(f'\t["{path}"] = {count},')
    out += ["}", END]

    with open(TARGET, encoding="utf-8") as f:
        src = f.read()
    start, stop = src.index(BEGIN), src.index(END) + len(END)
    with open(TARGET, "w", encoding="utf-8", newline="\n") as f:
        f.write(src[:start] + "\n".join(out) + src[stop:])

    families = len(set(family_ids.values()))
    print(f"{len(clubs)} clubs in {families} families -> {os.path.relpath(TARGET, ROOT)}")
    print(f"{len(skipped)} kits skipped (no crowd texture):")
    for s in skipped:
        print("  ", s)


if __name__ == "__main__":
    main()
