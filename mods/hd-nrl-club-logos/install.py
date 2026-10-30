#!/usr/bin/env python3
"""
install.py - make the team loading screen show the HD club logos at full
resolution by patching rugbyleague1.exe (6 dwords).

native.setTeamsLoadingProps doesn't hand the team images straight to the
XAML. It point-copies each one (no filtering) into a native render target,
homeTeamTexture / awayTeamTexture, that is hard-coded to the stock
large_mirrored size, 308x312. The XAML then stretches that to 542x550 of a
1080p layout. Any bigger texture is shrunk back to 308x312 by nearest
sampling, which is why the HD logos came out jagged. (Measured in-game with a
stripe chart: 1/2/3px stripes aliased exactly as a 308px copy predicts.)

The target's size is written at three sites (the creation descriptor, then the
home and away texture objects):

    mov dword [rbp+X], 3          ; format
    mov dword [rbp+X], 134h       ; width  308
    mov dword [rbp+X], 138h       ; height 312
    mov byte  [rbp+X], 1

    mov dword [rbx+28h], 3        ; format          (x2)
    mov dword [rbx+34h], 134h     ; width  308
    mov dword [rbx+38h], 138h     ; height 312
    mov dword [rbx+3Ch], 1        ; mips

This patch sets all three to SIZE (1232x1248), which is what generate.py
renders large_mirrored at (VARIANT_SIZE), so the copy is 1:1. The XAML
(loading-screen-secondary-arrows LOGO_SIZE) draws it at 680x688 of the 1080p
layout, 1360x1376 at 4K. Stock 308x312 logos (clubs this mod doesn't cover, custom
decal clubs) are tripled by the same point copy: they look like stock,
just with crisper pixel edges.

The sites are found by instruction pattern with the size as a wildcard, so
--restore puts 308x312 back whatever other exe patches are applied. The first
apply keeps a copy of the exe as _backup/rugbyleague1.exe.<md5>.bak.

Usage (game closed):
    python mods\\hd-nrl-club-logos\\install.py            # dry run
    python mods\\hd-nrl-club-logos\\install.py --apply    # back up, then patch
    python mods\\hd-nrl-club-logos\\install.py --status   # current size
    python mods\\hd-nrl-club-logos\\install.py --restore  # back to 308x312
"""

import argparse
import hashlib
import os
import re
import shutil
import struct
import sys

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO_ROOT, "tools"))
import games  # noqa: E402  (finds the RL26 install)

DEFAULT_EXE = games.rl26_path("rugbyleague1.exe")
BACKUP_DIR = os.path.join(REPO_ROOT, "_backup")

STOCK = (308, 312)
SIZE = (1232, 1248)  # = generate.py VARIANT_SIZE["large_mirrored"]
OLD_SIZES = [(924, 936)]  # earlier versions of this patch, recognised so they can be upgraded or restored

# (regex, offset of the width dword, offset of the height dword, expected matches)
_SITES = [
    # creation descriptor on the stack
    (re.compile(rb"\xc7\x45.\x03\x00\x00\x00\xc7\x45.(....)\xc7\x45.(....)\xc6\x45.\x01", re.DOTALL), 1),
    # home / away texture objects
    (re.compile(rb"\xc7\x43\x28\x03\x00\x00\x00\xc7\x43\x34(....)\xc7\x43\x38(....)\xc7\x43\x3c\x01\x00\x00\x00",
                re.DOTALL), 2),
]
KNOWN = {STOCK, SIZE, *OLD_SIZES}


class PatchError(Exception):
    """The exe doesn't look like a version this patch understands."""


def md5(data):
    return hashlib.md5(data).hexdigest()


def analyse(data):
    """[(width offset, height offset, (w, h))] for the 3 sites. Only matches
    whose size is stock or SIZE count, so unrelated code can't match. Raises
    PatchError unless exactly the expected sites are found."""
    sites = []
    for regex, expected in _SITES:
        found = []
        for m in regex.finditer(data):
            wh = (struct.unpack("<I", m.group(1))[0], struct.unpack("<I", m.group(2))[0])
            if wh in KNOWN:
                found.append((m.start(1), m.start(2), wh))
        if len(found) != expected:
            raise PatchError(f"loading screen team texture: expected {expected} site(s) for one pattern, found "
                             f"{len(found)} (a game update probably changed this code)")
        sites += found
    return sites


def state(sites):
    sizes = {wh for _w, _h, wh in sites}
    if sizes == {STOCK}:
        return "stock"
    if sizes == {SIZE}:
        return "patched"
    return "other size"


def status(exe):
    """('stock'|'patched'|'other size'|'unrecognised', detail) - never raises."""
    data = open(exe, "rb").read()
    try:
        return state(analyse(data)), md5(data)
    except PatchError as e:
        return "unrecognised", str(e)


def _write(exe, data, sites, wh):
    for w_off, h_off, _old in sites:
        data[w_off:w_off + 4] = struct.pack("<I", wh[0])
        data[h_off:h_off + 4] = struct.pack("<I", wh[1])
    with open(exe, "wb") as f:
        f.write(data)


def apply(exe, write=True, log=print):
    """Patch exe to SIZE. Returns 'applied', 'already patched' or 'dry run'.
    Raises PatchError if the exe isn't recognised."""
    data = bytearray(open(exe, "rb").read())
    before = md5(data)
    sites = analyse(data)
    st = state(sites)
    log(f"{exe}\n  md5 {before}  loading screen team texture: {st}")
    if st == "patched":
        return "already patched"
    for w_off, h_off, wh in sites:
        log(f"  {w_off:#09x}/{h_off:#09x}  {wh[0]}x{wh[1]}  ->  {SIZE[0]}x{SIZE[1]}")
    if not write:
        return "dry run"

    backup = os.path.join(BACKUP_DIR, f"rugbyleague1.exe.{before}.bak")
    if not os.path.exists(backup):
        os.makedirs(BACKUP_DIR, exist_ok=True)
        shutil.copy2(exe, backup)
        log(f"  backup written: {backup}")
    _write(exe, data, sites, SIZE)
    log(f"  patched - new md5 {md5(data)}")
    return "applied"


def restore(exe, log=print):
    data = bytearray(open(exe, "rb").read())
    try:
        sites = analyse(data)
    except PatchError as e:
        sys.exit(f"not restoring: {e}. Use Steam's 'Verify integrity of game files'.")
    if state(sites) == "stock":
        log(f"{exe} isn't patched - nothing to undo")
        return "not patched"
    _write(exe, data, sites, STOCK)
    log(f"restored the 308x312 loading screen team texture in {exe} (md5 {md5(data)})")
    return "restored"


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--exe", default=DEFAULT_EXE)
    g = ap.add_mutually_exclusive_group()
    g.add_argument("--apply", action="store_true", help="back up the exe, then patch it")
    g.add_argument("--restore", action="store_true", help="undo this patch")
    g.add_argument("--status", action="store_true", help="report whether the exe is patched")
    args = ap.parse_args()

    if args.restore:
        restore(args.exe)
        return
    if args.status:
        st, detail = status(args.exe)
        print(f"{args.exe}\n  loading screen team texture: {st}  ({detail})")
        return
    try:
        result = apply(args.exe, write=args.apply)
    except PatchError as e:
        sys.exit(f"refusing to patch: {e}")
    print(result if result != "dry run" else "dry run - pass --apply to write (game must be closed)")


if __name__ == "__main__":
    main()
