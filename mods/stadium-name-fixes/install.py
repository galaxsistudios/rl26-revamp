#!/usr/bin/env python3
"""
install.py - correct stadium display names in the UI string tables
(strings/strings_en and strings/strings_fr, see README.md).

A string table is a uint32 count followed by that many (uint32 length, UTF-8
key, uint32 length, UTF-8 value) pairs, nothing after. The stock entries are
stored zstd-framed; the patched table is installed raw (pack.py default).

Each stadium's name lives under three keys - MatchSettings_Ground_<id>,
Ground_<id> and <id> - plus a few one-offs (EXTRA_KEYS). A key is only
rewritten when its value is still the stock English name, so a French
translation ("Stade Polytec") is left alone.

Usage (game closed):
    python mods/stadium-name-fixes/install.py install --confirm
    python mods/stadium-name-fixes/install.py restore
    python mods/stadium-name-fixes/install.py status
    python mods/stadium-name-fixes/install.py show      # dry run: every change
"""

import argparse
import os
import struct
import sys

MOD_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(os.path.dirname(MOD_DIR))
sys.path.insert(0, os.path.join(REPO_ROOT, "tools"))
import classify_entries as ce  # noqa: E402
import entries  # noqa: E402
import pack  # noqa: E402

BUILD_DIR = os.path.join(REPO_ROOT, "_build", "stadium-name-fixes")
TABLES = ("strings-en", "strings-fr")

# stadium id -> corrected name (docs/nrl-stadium-names.txt)
RENAMES = {
    "brookvaleOval": "4 Pines Park",
    "canberraStadium": "GIO Stadium",
    "kogarahOval": "Netstrata Jubilee Stadium",
    "perthStadium": "Optus Stadium",
    "lasVegasStadium": "Allegiant Stadium",
    "waikatoStadium": "FMG Stadium Waikato",
    "wellingtonRegionalStadium": "Sky Stadium",
    "bokarinaStadium": "Sunshine Coast Stadium",
    "glenwillSportsStadium": "Glen Willow Oval",
    "industreeGroupStadium": "Industree Group Stadium",
    "marrickvilleRugbyPark": "Henson Park",
    "kellyvilleMemorialPark": "Kellyville Park",
    "blacktownSportingComplex": "H.E. Laybutt Sporting Complex",
    "manlyWestOval": "BMD Kougari Oval",
    "stonesCornerRugbyPark": "Totally Workwear Stadium",
    "miamiRugbyPark": "AutoNation Sports Field",
    "rockhamptonRugbyStadium": "Rugby Park Rockhampton",
    "ipswichReserve": "North Ipswich Reserve",
    "mackayStadium": "BB Print Stadium",
    "cairnsRugbyPark": "Barlow Park",
    "nundahRugbyPark": "Bishop Park",
    "westEndRugbyPark": "Davies Park",
    "kirwanOval": "Jack Manski Oval",
    "tweedHeadsWestSportsComplex": "Piggabeen Sports Complex",
}

# older keys that don't follow the <id> naming
EXTRA_KEYS = {"Ground_canberra": "canberraStadium"}


def parse(raw):
    count = struct.unpack_from("<I", raw, 0)[0]
    pos, pairs = 4, []
    for _ in range(count):
        item = []
        for _ in range(2):
            n = struct.unpack_from("<I", raw, pos)[0]
            item.append(raw[pos + 4:pos + 4 + n].decode("utf-8"))
            pos += 4 + n
        pairs.append(item)
    if pos != len(raw):
        raise SystemExit(f"string table has {len(raw) - pos} unexpected trailing bytes")
    return pairs


def serialise(pairs):
    out = [struct.pack("<I", len(pairs))]
    for item in pairs:
        for text in item:
            b = text.encode("utf-8")
            out.append(struct.pack("<I", len(b)) + b)
    return b"".join(out)


def stock_table(blobset, entry):
    if os.path.exists(pack.backup_meta_path(entry)):
        raise SystemExit(f"entry {entry} is modified (backup exists) - restore it before reading it as stock")
    ce.load_index(blobset)
    raw = ce.read_blob_full(blobset, entry)[0]
    if raw is None:
        raise SystemExit(f"entry {entry} blob is missing")
    return raw


def patch(pairs, english):
    """Rewrite names in place; english = the stock English table as a dict
    (the old names to match against). Returns [(key, old, new)]."""
    keys = {}
    for sid in RENAMES:
        for k in (f"MatchSettings_Ground_{sid}", f"Ground_{sid}", sid):
            keys[k] = sid
    keys.update(EXTRA_KEYS)
    changes = []
    for item in pairs:
        sid = keys.get(item[0])
        if sid is None:
            continue
        old = english.get(f"MatchSettings_Ground_{sid}")
        if item[1] == old and old != RENAMES[sid]:
            changes.append((item[0], item[1], RENAMES[sid]))
            item[1] = RENAMES[sid]
    return changes


def build(blobset):
    entry_en = entries.index_of("strings-en")
    english = dict(parse(stock_table(blobset, entry_en)))
    missing = [s for s in RENAMES if f"MatchSettings_Ground_{s}" not in english]
    if missing:
        raise SystemExit(f"no MatchSettings_Ground_ key for: {', '.join(missing)}")
    out = []
    for name in TABLES:
        entry = entries.index_of(name)
        pairs = parse(stock_table(blobset, entry))
        changes = patch(pairs, english)
        out.append((name, entry, serialise(pairs), changes))
    return out


def cmd_show(args):
    for name, entry, _blob, changes in build(args.blobset):
        print(f"{name} (entry {entry}): {len(changes)} strings")
        for key, old, new in changes:
            print(f"  {key}: {old!r} -> {new!r}")


def cmd_install(args):
    if not args.confirm:
        raise SystemExit("install requires --confirm (use `show` for a dry run)")
    for name in TABLES:
        entry = entries.index_of(name)
        if os.path.exists(pack.backup_meta_path(entry)):
            pack.do_restore(args.blobset, entry)
    os.makedirs(BUILD_DIR, exist_ok=True)
    for name, entry, blob, changes in build(args.blobset):
        src = os.path.join(BUILD_DIR, f"{name}.bin")
        with open(src, "wb") as f:
            f.write(blob)
        pack.do_install(args.blobset, entry, src, True)
        print(f"installed {name} (entry {entry}): {len(changes)} strings renamed")


def cmd_restore(args):
    for name in TABLES:
        entry = entries.index_of(name)
        if os.path.exists(pack.backup_meta_path(entry)):
            pack.do_restore(args.blobset, entry)
            print(f"restored {name} (entry {entry})")


def cmd_status(args):
    for name in TABLES:
        entry = entries.index_of(name)
        print(f"{name} (entry {entry}): {'INSTALLED' if os.path.exists(pack.backup_meta_path(entry)) else 'stock'}")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--blobset", default=pack.BLOBSET_PATH)
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("install")
    p.add_argument("--confirm", action="store_true")
    p.set_defaults(func=cmd_install)
    sub.add_parser("restore").set_defaults(func=cmd_restore)
    sub.add_parser("status").set_defaults(func=cmd_status)
    sub.add_parser("show").set_defaults(func=cmd_show)
    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
