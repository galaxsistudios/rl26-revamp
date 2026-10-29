#!/usr/bin/env python3
"""
install.py - put the field-numbers atlas (resources/field-numbers/, drawn by
make_atlas.py) into both field-lines texture bundles.

fields/default/lines and fields/default/lines_flipped each ship their own
TXPK (v5887:39879 / 39881) holding fieldlines01_col, fieldlines01_red_col
and fieldmarkings_numbers_col. Only the numbers member is replaced, in both,
using the stock main/vram split nrl-field-sponsor-markings/install.py
documents: main = the original header stored raw, vram = the payload with
the member patched in place, chunk-framed by texture_mods.encode_outer_chunks.

Usage (game closed):
    python mods/field-numbers-font/install.py install --confirm [--texconv PATH]
    python mods/field-numbers-font/install.py restore
    python mods/field-numbers-font/install.py status
"""

import argparse
import os
import struct
import subprocess
import sys
import tempfile

import numpy as np
from PIL import Image

MOD_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(os.path.dirname(MOD_DIR))
sys.path.insert(0, os.path.join(REPO_ROOT, "tools"))
import classify_entries as ce  # noqa: E402
import extract_textures as et  # noqa: E402
import entries  # noqa: E402
import games  # noqa: E402
import pack  # noqa: E402
import texture_mods  # noqa: E402

ATLAS = os.path.join(REPO_ROOT, "resources", "field-numbers", "fieldmarkings_numbers_col.png")
BUILD_DIR = os.path.join(REPO_ROOT, "_build", "field-numbers-font")
MEMBER = "fields/textures/fieldmarkings_numbers_col.dds"
# Entry numbers are 1.0.5887 positions, mapped to the live index by hash.
BUNDLES = [entries.legacy(39879), entries.legacy(39881)]  # lines, lines_flipped


def member_table(raw):
    """{path_with_.dds: (data_off, data_size)} from a TXPK header."""
    magic, count = struct.unpack_from("<2I", raw, 0)
    if magic != et.TXPK_MAGIC:
        raise ValueError("not a TXPK")
    out = {}
    for i in range(count):
        path_off, _path_size, data_off, data_size = struct.unpack_from("<4I", raw, 8 + i * 16)
        end = raw.index(b"\x00", path_off + 20)
        out[raw[path_off + 20:end].decode("latin1").replace("\\", "/") + ".dds"] = (data_off, data_size)
    return out


def dds_header_len(dds):
    return 148 if dds[84:88] == b"DX10" else 128


def encode_like(orig_dds, texconv, tmp):
    """BC7-encode the atlas (flipped to storage order) with orig_dds's mip
    count; return orig_dds's header + the new payload."""
    h, w = int.from_bytes(orig_dds[12:16], "little"), int.from_bytes(orig_dds[16:20], "little")
    mips = int.from_bytes(orig_dds[28:32], "little")
    im = Image.open(ATLAS).convert("RGBA")
    assert im.size == (w, h), (im.size, (w, h))
    a = np.array(im)
    a[a[..., 3] == 0, :3] = a[a[..., 3] > 0, :3].mean(0).round()  # no dark fringe in the mips
    src = os.path.join(tmp, "numbers.png")
    Image.fromarray(a).transpose(Image.FLIP_TOP_BOTTOM).save(src)
    subprocess.run([texconv, "-nologo", "-y", "-f", "BC7_UNORM", "-m", str(mips),
                    "--ignore-srgb", "-o", tmp, src], check=True, stdout=subprocess.DEVNULL)
    new = open(os.path.join(tmp, "numbers.dds"), "rb").read()
    payload = new[dds_header_len(new):]
    hl = dds_header_len(orig_dds)
    if len(payload) != len(orig_dds) - hl:
        raise RuntimeError(f"encoded payload {len(payload)} != original {len(orig_dds) - hl}")
    return orig_dds[:hl] + payload


def build_blob(blobset, entry, texconv, tmp):
    raw, *_ = ce.read_blob_full(blobset, entry)
    if raw is None or ce.classify(raw[:65536])[0] != "txpk":
        raise RuntimeError(f"entry {entry} is not a TXPK bundle")
    main_c, main_u, vram_c, vram_u = pack.entry_sizes(ce._INDEX_DATA, ce._SIZE_TABLE_OFF, entry)
    if vram_u == 0 or main_u + vram_u != len(raw):
        raise RuntimeError(f"entry {entry} is not a pristine main/vram TXPK (sizes {main_c, main_u, vram_c, vram_u}) "
                           f"- restore it first")
    header, payload = raw[:main_u], bytearray(raw[main_u:])
    table = member_table(header)
    if MEMBER not in table:
        raise RuntimeError(f"entry {entry} has no member {MEMBER}")
    off, size = table[MEMBER]
    payload[off:off + size] = encode_like(bytes(payload[off:off + size]), texconv, tmp)
    vram = texture_mods.encode_outer_chunks(bytes(payload))
    return header + vram, (len(header), len(header), len(vram), len(payload))


def cmd_install(args):
    texconv = os.path.abspath(args.texconv or games.toolchain("texconv", "texconv.exe"))
    if not os.path.exists(texconv):
        raise SystemExit("texconv.exe not found - pass --texconv")
    ce.load_index(args.blobset)
    already = [e for e in BUNDLES if os.path.exists(pack.backup_meta_path(e))]
    if already:
        raise SystemExit(f"entries {already} already have a backup - run 'install.py restore' first")
    os.makedirs(BUILD_DIR, exist_ok=True)
    builds = []
    with tempfile.TemporaryDirectory() as tmp:
        for entry in BUNDLES:  # build everything before touching the game
            blob, sizes = build_blob(args.blobset, entry, texconv, tmp)
            out = os.path.join(BUILD_DIR, f"entry_{entry}.txpk.bin")
            with open(out, "wb") as f:
                f.write(blob)
            builds.append((entry, out, sizes))
            print(f"  built {entry}: numbers atlas, vram {sizes[2]} bytes")
    if not args.confirm:
        print("Dry run - pass --confirm to install.")
        return
    for entry, out, sizes in builds:
        pack.do_install(args.blobset, entry, out, confirm=True, sizes=sizes)
        print(f"  installed {entry}")
    print("Done. Undo with: python mods/field-numbers-font/install.py restore")


def cmd_restore(args):
    for entry in BUNDLES:
        if os.path.exists(pack.backup_meta_path(entry)):
            pack.do_restore(args.blobset, entry)
            print(f"  restored {entry}")


def cmd_status(args):
    for entry in BUNDLES:
        state = "installed" if os.path.exists(pack.backup_meta_path(entry)) else "stock"
        print(f"  {entry}: {state}")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--blobset", default=pack.BLOBSET_PATH)
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("install")
    p.add_argument("--confirm", action="store_true")
    p.add_argument("--texconv", help="texconv.exe (default: the bundled toolchain one)")
    p.set_defaults(func=cmd_install)
    sub.add_parser("restore").set_defaults(func=cmd_restore)
    sub.add_parser("status").set_defaults(func=cmd_status)
    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
