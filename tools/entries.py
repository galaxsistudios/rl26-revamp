#!/usr/bin/env python3
"""
entries.py - find blobset entries by NAME / logical path / hash instead of by
index position.

Positions are not stable: the index is sorted by path, so a game update that
adds files shifts every later entry (1.0.5933 inserted 257 files and moved
68,946 entries - 39959 became 40053). The u64 hash of an entry is FNV-1a 64 of
its lowercased logical path (see add_entries.py) and never changes, and the
game itself looks entries up by it. So code refers to entries as:

    entries.index_of("scripts")                          # a NAMED entry below
    entries.index_of("ui/textures/controller.texture")   # any logical path
    entries.index_of(0x4ebd868fc3afc1dc)                 # a raw hash
    entries.legacy(39882)                                # a 1.0.5887 entry number

legacy() maps an entry number as it was in build 1.0.5887 (the build most of
this repo's notes, file names and research were written against) through that
build's saved hash table (tools/index_hashes_1.0.5887.bin, tracked) to wherever
that file lives now - for the long lists of entries we only know by number.

On the command line, every --entry accepts the same forms via `entries.arg`:
a name, a path, 0x<hash>, v5887:<number>, or a plain number (= a CURRENT
position, as before).

    python tools\\entries.py scripts gamedata 0x4ebd868fc3afc1dc v5887:39122
"""

import argparse
import os
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pack  # noqa: E402

LEGACY_TABLE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "index_hashes_1.0.5887.bin")

# name -> logical path (or hash when the path is unknown). Paths recovered by
# hashing strings from rugbyleague1.exe against the index.
NAMED = {
    "careerdata": "mempacks/careerdata.mempack",        # 1.0.5887: 39952
    "decaldata": "mempacks/decaldata.mempack",          # 39953
    "gamedata": "mempacks/gamedata.mempack",            # 39954 defaultdata_leagues + npcs
    "heatmaps": "mempacks/heatmaps.mempack",            # 39955
    "leveldata": "mempacks/leveldata.mempack",          # 39956
    "licenseddata": "mempacks/licenseddata.mempack",    # 39957 defaultdata_clubs + players
    "locationdata": "mempacks/locationdata.mempack",    # 39958
    "scripts": "mempacks/lua.mempack.retail",           # 39959 Lua script bundle
    "objectivedata": "mempacks/objectivedata.mempack",  # 39960
    "fonts": "noesis/fonts.mempack",                    # 39962 Noesis fonts
    "xamls": "noesis/xamls.mempack",                    # 57662 Noesis XAML
    "frontend-effects": "particles/frontend-effects.mempack",  # 57663
    "gameplay-effects": "particles/gameplay-effects.mempack",  # 57665
    "dialogue": "sound/dialogue.mempack",               # 85342
    "global-texsrc": "characters/player/global.texsrc",  # 31558
    "crowd-textureinfo": "crowd/textureinfo.dat",       # 39871 crowd texture table
    "crowd-anim-bank": 0x4ebd868fc3afc1dc,              # 39122 crowd baked animation
    "crowd-flag-template": "crowd/characters/models/prop_camera02.model",  # 39167
    "controller-art": "ui/textures/controller.texture",  # 102575
    "controller-lines": "ui/textures/controller_lines.texture",  # 102581
    "extrasymbols-gamepad": "ui/textures/extrasymbols_gamepad.texture",  # 102661
    "strings-en": "strings/strings_en",                 # 1.0.5933: 98358 English UI string table
    "strings-fr": "strings/strings_fr",                 # 98359 French
}

# 1.0.5887 numbers of the M3MP bundles -> NAMED key (old manifest/backup names)
BUNDLE_NAMES = {39952: "careerdata", 39953: "decaldata", 39954: "gamedata", 39955: "heatmaps",
                39956: "leveldata", 39957: "licenseddata", 39958: "locationdata", 39959: "scripts",
                39960: "objectivedata", 39962: "fonts", 57662: "xamls", 57663: "frontend-effects",
                57665: "gameplay-effects", 85342: "dialogue"}


def fnv1a64(text):
    h = 0xCBF29CE484222325
    for b in text.lower().encode("utf-8"):
        h = ((h ^ b) * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return h


_cache = {}


def _hash_map(blobset_path):
    """{hash: index} of the live index, cached per (path, mtime, size)."""
    st = os.stat(blobset_path)
    key = (os.path.abspath(blobset_path), st.st_mtime_ns, st.st_size)
    if _cache.get("key") != key:
        data, count, hash_off, _size_off = pack.read_index(blobset_path)
        hashes = struct.unpack_from(f"<{count}Q", data, hash_off)
        _cache.update(key=key, map={h: i for i, h in enumerate(hashes)})
    return _cache["map"]


def hash_of(key):
    """Hash for a NAMED key, logical path, 0x string or int hash."""
    if isinstance(key, str) and key in NAMED:
        key = NAMED[key]
    if isinstance(key, int):
        return key
    if key.lower().startswith("0x"):
        return int(key, 16)
    return fnv1a64(key)


def legacy_hash(number):
    with open(LEGACY_TABLE, "rb") as f:
        f.seek(number * 8)
        raw = f.read(8)
    if len(raw) != 8:
        raise KeyError(f"{number} is past the end of the 1.0.5887 index")
    return struct.unpack("<Q", raw)[0]


def index_of(key, blobset_path=None):
    """Current index of an entry (see module docstring for accepted keys)."""
    h = hash_of(key)
    idx = _hash_map(blobset_path or pack.BLOBSET_PATH).get(h)
    if idx is None:
        raise KeyError(f"{key!r} (hash 0x{h:016x}) is not in the live index")
    return idx


def legacy(number, blobset_path=None):
    """Current index of the file that was entry `number` in build 1.0.5887."""
    return index_of(legacy_hash(number), blobset_path)


def hash_at(index, blobset_path=None):
    """16-hex hash of the live entry at `index` (texture_mods.py file prefix)."""
    data, _count, hash_off, _size_off = pack.read_index(blobset_path or pack.BLOBSET_PATH)
    return f"{struct.unpack_from('<Q', data, hash_off + index * 8)[0]:016x}"


def legacy_hex(number):
    return f"0x{legacy_hash(number):016x}"


def resolve(text, blobset_path=None):
    """CLI form -> current index: name | path | 0x<hash> | v5887:<n> | <current n>."""
    text = str(text).strip()
    if text.isdigit():
        return int(text)
    if text.lower().startswith("v5887:"):
        return legacy(int(text.split(":", 1)[1]), blobset_path)
    return index_of(text, blobset_path)


def arg(text):
    """argparse `type=` for --entry options."""
    try:
        return resolve(text)
    except (KeyError, OSError) as e:
        raise argparse.ArgumentTypeError(str(e))


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("keys", nargs="*", help="names / paths / 0x hashes / v5887:N (default: every NAMED entry)")
    args = ap.parse_args()
    for key in args.keys or NAMED:
        try:
            print(f"{key:24} -> {resolve(key)}")
        except KeyError as e:
            print(f"{key:24} -> MISSING ({e})")


if __name__ == "__main__":
    main()
