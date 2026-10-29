#!/usr/bin/env python3
"""
install.py - textures for headgear-patterns.

Appends each pattern's tint mask (textures/<name>.png, made by
make_patterns.py) as new texture entries
characters/helmets/textures/<name>_{1,2,3} (2048 / 1024 / 512, uncompressed
BGRA DDS stored upside down, like the stock helmet masks), and registers them
in characters/player/global.texsrc. Stock helmet textures are not touched.

Usage (repo root, game closed):
    python mods/headgear-patterns/install.py install [--replace] [--confirm]
    python mods/headgear-patterns/install.py texsrc [--confirm]   # AFTER rll4-legacy-kits texsrc

texsrc reads the LIVE global.texsrc (so the other mods' records stay) and
reinstalls it with these records appended, like nrl-referee-2026-kits.
"""

import argparse
import os
import struct
import sys

from PIL import Image

MOD = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(MOD))
sys.path.insert(0, os.path.join(REPO, "tools"))
import pack  # noqa: E402

# colTexture names of the items in jesse-southwell-hair's assetmap.lua
# (HeadgearPatterns block); the files are textures/<name lowercased>.png.
PATTERNS = ("helmet_adidas01_lightning_col", "helmet_madisonAirFlo_lightning_col")
TEXDIR = "characters/helmets/textures"
SIZES = {1: 2048, 2: 1024, 3: 512}
TEXSRC_PATH = "characters/player/global.texsrc"


def _dds_bgra(img):
    """Uncompressed 32-bit BGRA DDS, no mips, stored upside down (the same
    writer as nrl-referee-2026-kits; the stock helmet masks match)."""
    w, h = img.size
    header = bytearray(128)
    struct.pack_into("<4s7I", header, 0, b"DDS ", 124, 0x1007, h, w, 0, 1, 0)
    struct.pack_into("<2I4s5I", header, 76, 32, 0x41, b"\0\0\0\0", 32, 0xFF0000, 0xFF00, 0xFF, 0xFF000000)
    struct.pack_into("<I", header, 108, 0x1000)
    return bytes(header) + img.convert("RGBA").transpose(Image.FLIP_TOP_BOTTOM).tobytes("raw", "BGRA")


def cmd_install(args):
    import add_entries
    import club_icons
    for name in PATTERNS:
        img = Image.open(os.path.join(MOD, "textures", name.lower() + ".png")).convert("RGBA")  # upright
        for level, size in SIZES.items():
            # Per channel: A is a tint mask (straps), not transparency, and an
            # RGBA resize premultiplies by it, which blacked out the shell in
            # _2/_3 (the levels the game actually samples).
            im = img if img.size == (size, size) else Image.merge(
                "RGBA", [band.resize((size, size), Image.LANCZOS) for band in img.split()])
            path = f"{TEXDIR}/{name}_{level}.texture".lower()
            blob, sizes = club_icons.make_blob(path, _dds_bgra(im))
            add_entries.add_entry(args.blobset, path, blob, sizes, f"headgear-patterns {name}",
                                  args.confirm, replace=args.replace)
    if not args.confirm:
        print("dry run - pass --confirm to write (close the game first)")


def _fnv1a32(text):
    h = 0x811C9DC5
    for c in text.lower().encode("utf-8"):
        h = ((h ^ c) * 0x01000193) & 0xFFFFFFFF
    return h


def cmd_texsrc(args):
    """Layout (see rll4-legacy-kits/build_kits.py): u32 count, then count x
    8 u32 [fnv1a32(path without extension), type, x, y, w, h, tex w, tex h]."""
    import add_entries
    import classify_entries as ce
    ce.load_index(args.blobset)
    data, count, hash_off, _ = pack.read_index(args.blobset)
    entry = add_entries.find_entry(data, count, hash_off, TEXSRC_PATH)
    raw = ce.read_blob_full(args.blobset, entry)[0]
    live_count = struct.unpack_from("<I", raw, 0)[0]
    if len(raw) != 4 + 32 * live_count:
        raise SystemExit(f"{TEXSRC_PATH} (entry {entry}) isn't the expected record table")
    known = set(struct.unpack_from(f"<{live_count * 8}I", raw, 4)[0::8])
    records = []
    for name in PATTERNS:
        for level, size in SIZES.items():
            key = _fnv1a32(f"{TEXDIR}/{name}_{level}")
            if key not in known:
                records.append(struct.pack("<8I", key, 0, 0, 0, size, size, size, size))
    print(f"{TEXSRC_PATH} (entry {entry}): {live_count} live records, {len(records)} to add")
    if not records:
        return
    work = os.path.join(REPO, "_build", "headgear-patterns")
    os.makedirs(work, exist_ok=True)
    out = os.path.join(work, "global.texsrc")
    with open(out, "wb") as f:
        f.write(struct.pack("<I", live_count + len(records)) + raw[4:] + b"".join(records))
    if not args.confirm:
        print("dry run - pass --confirm to install (close the game first)")
        return
    if os.path.exists(pack.backup_meta_path(entry)):
        pack.do_restore(args.blobset, entry)
    pack.do_install(args.blobset, entry, out, True)
    print(f"installed entry {entry} (undo: python tools/pack.py restore --entry {entry})")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--blobset", default=pack.BLOBSET_PATH)
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("install")
    p.add_argument("--replace", action="store_true", help="re-write entries added before")
    p.add_argument("--confirm", action="store_true")
    p.set_defaults(func=cmd_install)
    p = sub.add_parser("texsrc")
    p.add_argument("--confirm", action="store_true")
    p.set_defaults(func=cmd_texsrc)
    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
