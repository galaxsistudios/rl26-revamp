#!/usr/bin/env python3
"""
install.py - preload the competition logos for the team loading screen.

A Noesis Image with a static Source ("../../Images/logos_competition/1080/
nrl.png") only shows textures the engine already has. The engine preloads
each view's "<view>.texpack" bundle, but stock
noesis/workspace/views/loadingscreen/loadingscreen_rugby.texpack is an empty
placeholder (8-byte TXPK, no members, no blob file). The screen wipe themes
show the same logos because their texpacks contain them (e.g.
rl26_wipe_nrl.texpack = one member, noesis/workspace/images/logos_competition/
1080/nrl, byte-identical to the standalone nrl.texture).

This fills the loading screen's texpack with every logo generate.py's
COMPETITION_LOGOS uses, so the CompetitionLogo images can show. Stock logos
are copied from the standalone 1080x1080 entries (~1.2 MB each, BC7).
NEW_LOGOS (Pacific Championships, NSW Cup, Country Round) are rendered from
their sources as premultiplied BGRA (~4.7 MB each). They exist only as
texpack members, with no standalone entry.

It also holds the stadium backgrounds: every "<stadium>_<day|night>" of the
shipped ui/textures/stadium_images (generate.py stadium_keys(), ~183), cut down
from 1120x740 BGRA to STADIUM_SIZE DXT1 (~135 KB each) under STADIUM_DIR.

The stock entry has no blob file, so the first install writes the empty TXPK
the index describes (magic + 0 members) as the stock blob, which lets
pack.py back it up and restore it like any other entry.

Usage (game closed):
    python mods\\loading-screen-secondary-arrows\\install.py install [--confirm]
    python mods\\loading-screen-secondary-arrows\\install.py restore
"""

import argparse
import importlib.util
import io
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, "tools"))

import numpy as np  # noqa: E402
from PIL import Image  # noqa: E402

import classify_entries as ce  # noqa: E402
import club_icons  # noqa: E402
import entries  # noqa: E402
import extract_textures as et  # noqa: E402
import pack  # noqa: E402
import texture_mods  # noqa: E402

TEXPACK = "noesis/workspace/views/loadingscreen/loadingscreen_rugby.texpack"
LOGO_DIR = "noesis/workspace/images/logos_competition/1080"
BUILD = os.path.join(REPO, "_build", "loadingscreen_rugby.texpack.bin")
EMPTY_TXPK = struct.pack("<2I", et.TXPK_MAGIC, 0)
LOGO_SIZE = 1080  # the stock logos_competition/1080 canvas
LOGO_FILL = 0.94  # share of the canvas a new logo's longer side fills


def generator():
    spec = importlib.util.spec_from_file_location("lssa_generate", os.path.join(HERE, "generate.py"))
    gen = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(gen)
    return gen


def stock_logo(name):
    """A stock logos_competition/1080 logo as straight-alpha RGBA."""
    path = f"{LOGO_DIR}/{name}.texture"
    _p, dds, _r, _w, _h, _t = et.parse_mini_txpk(ce.read_blob_full(pack.BLOBSET_PATH, entries.index_of(path))[0])
    # stored premultiplied: undo it so the resample and re-premultiply are exact
    px = np.asarray(club_icons.decode_dds(dds).convert("RGBA")).astype(np.float32)
    alpha = px[..., 3:4]
    px[..., :3] = np.where(alpha > 0, np.minimum(255, px[..., :3] * 255 / np.maximum(alpha, 1)), 0)
    return Image.fromarray(px.round().astype(np.uint8), "RGBA")


def render_logo(source):
    """A NEW_LOGOS source fitted into LOGO_SIZE x LOGO_SIZE with the stock
    logos' small margin, premultiplied BGRA like the stock set. The source is a
    PNG/WebP/SVG under the repo, or "stock:<logo>@<top>-<bottom>" (those rows
    of a stock logo)."""
    if source.startswith("stock:"):
        name, rows = source[len("stock:"):].split("@")
        top, bottom = (int(v) for v in rows.split("-"))
        logo = stock_logo(name)
        logo = logo.crop((0, top, logo.width, bottom + 1))
    else:
        logo = club_icons.load_logo(os.path.join(REPO, source))
    logo = logo.crop(logo.getbbox())
    box = round(LOGO_SIZE * LOGO_FILL)
    k = min(box / logo.width, box / logo.height)
    logo = logo.resize((max(1, round(logo.width * k)), max(1, round(logo.height * k))), Image.LANCZOS)
    canvas = Image.new("RGBA", (LOGO_SIZE, LOGO_SIZE), (0, 0, 0, 0))
    canvas.alpha_composite(logo, ((LOGO_SIZE - logo.width) // 2, (LOGO_SIZE - logo.height) // 2))
    _sizes, legacy_header, _shield = club_icons.template_info(pack.BLOBSET_PATH, "cus_01")
    return club_icons.make_dds(club_icons.premultiply(canvas), legacy_header)


def stadium_dds(key, size):
    """A shipped ui/textures/stadium_images/<key> photo downscaled to size, as
    a DXT1 DDS (the background shows at 10% opacity, so small and lossy is
    fine)."""
    path = f"ui/textures/stadium_images/{key}.texture"
    _p, dds, _r, _w, _h, _t = et.parse_mini_txpk(ce.read_blob_full(pack.BLOBSET_PATH, entries.index_of(path))[0])
    img = club_icons.decode_dds(dds).convert("RGB").resize(size, Image.LANCZOS)
    buf = io.BytesIO()
    img.save(buf, "DDS", pixel_format="DXT1")
    return buf.getvalue()


def build():
    """(blob, sizes): TXPK header stored raw + payload chunk-framed, like the
    shipped wipe texpacks. Stock logos are copied from their standalone
    entries; NEW_LOGOS are rendered from their sources; the stadium
    backgrounds are downscaled from the shipped stadium images."""
    ce.load_index(pack.BLOBSET_PATH)
    gen = generator()
    members = []
    for key in gen.stadium_keys():
        members.append((f"{gen.STADIUM_DIR}/{key}", stadium_dds(key, gen.STADIUM_SIZE), *gen.STADIUM_SIZE))
    for name in sorted(set(gen.COMPETITION_LOGOS.values())):
        path = f"{LOGO_DIR}/{name}"
        if name in gen.NEW_LOGOS:
            members.append((path, render_logo(gen.NEW_LOGOS[name]), LOGO_SIZE, LOGO_SIZE))
            continue
        _p, dds, _r, w, h, _t = et.parse_mini_txpk(ce.read_blob_full(pack.BLOBSET_PATH, entries.index_of(path + ".texture"))[0])
        members.append((path, bytes(dds), w, h))

    header = bytearray(struct.pack("<2I", et.TXPK_MAGIC, len(members)))
    paths = [p.encode("latin1") + b"\0" for p, _d, _w, _h in members]
    pos = 8 + 16 * len(members)
    path_offs = []
    for pb in paths:
        path_offs.append(pos)
        pos += 20 + len(pb)
    data_off = 0
    for (p, dds, w, h), pb, po in zip(members, paths, path_offs):
        header += struct.pack("<4I", po, 20 + len(pb), data_off, len(dds))
        data_off += len(dds)
    for (p, dds, w, h), pb in zip(members, paths):
        header += struct.pack("<5I", w, h, 1, 20, len(dds)) + pb
    payload = b"".join(dds for _p, dds, _w, _h in members)
    vram = texture_mods.encode_outer_chunks(payload)
    return bytes(header) + vram, (len(header), len(header), len(vram), len(payload)), [m[0] for m in members]


def ensure_stock_blob(entry):
    """Write the stock entry's empty TXPK as its blob file if the game ships none."""
    info = pack.do_status(pack.BLOBSET_PATH, entry)
    if info["blob_exists"]:
        return
    if (info["main_compressed_size"], info["main_uncompressed_size"], info["vram_uncompressed_size"]) != (8, 8, 0):
        raise SystemExit(f"entry {entry} has no blob file but isn't the 8-byte empty placeholder - not touching it")
    os.makedirs(os.path.dirname(info["blob_path"]), exist_ok=True)
    with open(info["blob_path"], "wb") as f:
        f.write(EMPTY_TXPK)
    print(f"  wrote the stock empty TXPK as {info['blob_path']}")


def cmd_install(args):
    entry = entries.index_of(TEXPACK)
    blob, sizes, members = build()
    print(f"{TEXPACK} (entry {entry}): {len(members)} images (logos + stadium backgrounds), {sizes[3] / 1e6:.1f} MB")
    for m in members:
        print("   ", m)
    if not args.confirm:
        print("dry run - pass --confirm to install (game closed)")
        return
    if os.path.exists(pack.backup_meta_path(entry)):
        pack.do_restore(pack.BLOBSET_PATH, entry)
    ensure_stock_blob(entry)
    os.makedirs(os.path.dirname(BUILD), exist_ok=True)
    with open(BUILD, "wb") as f:
        f.write(blob)
    pack.do_install(pack.BLOBSET_PATH, entry, BUILD, confirm=True, sizes=sizes)
    print("  installed")


def cmd_restore(_args):
    entry = entries.index_of(TEXPACK)
    if os.path.exists(pack.backup_meta_path(entry)):
        pack.do_restore(pack.BLOBSET_PATH, entry)
        print(f"  restored entry {entry}")
    else:
        print("  not installed")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("install")
    p.add_argument("--confirm", action="store_true")
    p.set_defaults(func=cmd_install)
    sub.add_parser("restore").set_defaults(func=cmd_restore)
    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
