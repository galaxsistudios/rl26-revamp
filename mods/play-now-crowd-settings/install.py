#!/usr/bin/env python3
"""
install.py - let Lua set the crowd's home/away split by patching
rugbyleague1.exe (13 bytes in the crowd populate function + a 20-byte code
cave in int3 padding).

Every crowd seat (80-byte node) holds two random numbers. One, in [0, 1),
decides whether the seat is filled at the current attendance percentage
(setWantCrowdPercentage). The other, in [-1, 1], decides the side. The
populate function (CCrowdScene, 1.0.5933 @0x140bb3d90) zeroes xmm10 once and
then, per seat:

    comiss xmm10, [seat+24h]      ; 0 >= value ?
    jae    away                   ; yes: away tags/colours, else home

so about half the fans support each team, mixed through every stand. The
patch loads xmm10 from the crowd scene's padding dword at +0x1c instead. The
scene starts with 6 LOD ratio floats (+0x00..0x17, setLODRatio 0..5), a byte
at +0x18 and a qword at +0x20; no crowd code touches +0x19..0x1f. Lua writes
it with CCrowdScene:setLODRatio(7, t), whose index isn't bounds checked (it
stores a float at scene + 4 * index). For a home share H the threshold is
t = 1 - 2H; 0 is the stock split. Padding isn't initialised, so every crowd
scene the game builds (crowd_rugby.lua, crowd_frontend.lua) writes it.

    stock   xorps  xmm10, xmm10                       45 0f 57 d2
            movaps [rsp+9b0h], xmm11                  44 0f 29 9c 24 b0 09 00 00
    patched jmp    cave                               e9 <rel32>, 8 x nop
    cave    movss  xmm10, [r13+1ch]                   f3 45 0f 10 55 1c
            movaps [rsp+9b0h], xmm11                  (the moved instruction)
            jmp    back                               e9 <rel32>

r13 is the crowd scene there, and xmm10 is only used by that compare. The cave
goes in the first int3 run of the code section that's long enough (only one
in 1.0.5933: 28 bytes after a ret at 0x1401e3ab3); the patched site's jump
points at it, so status and restore find it again.

The first version (2026-11-01) read +0x1027194 - the top half of a heap
pointer at +0x1027190, which the scene's cleanup (0x140bbf510) frees - so the
Lua write crashed the next match load. Its cave is still recognised: apply
rewrites it and restore removes it.

A Steam update or "Verify integrity of game files" restores the original exe;
unlock-all-kits/launch.py (the Steam launch option) re-applies this patch too.
Without the patch the Lua write lands in padding and changes nothing.

Usage (game closed):
    python mods\\play-now-crowd-settings\\install.py            # dry run
    python mods\\play-now-crowd-settings\\install.py --apply    # back up, then patch
    python mods\\play-now-crowd-settings\\install.py --status   # patched or not
    python mods\\play-now-crowd-settings\\install.py --restore  # undo this patch
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
NAME = "Play Now crowd home/away split"

SIDE_SLOT = 0x1C                # crowd scene padding dword the cave reads (Lua: setLODRatio(SIDE_SLOT / 4, t))
SITE_HEAD = "44 0f 29 94 24 c0 09 00 00"                    # movaps [rsp+9c0h], xmm10
SITE_STOCK = "45 0f 57 d2 44 0f 29 9c 24 b0 09 00 00"       # xorps xmm10,xmm10 / movaps [rsp+9b0h], xmm11
SITE_TAIL = "f3 44 0f 10 1d ?? ?? ?? ??"                    # movss xmm11, [rip+...] (0.96)
MOVED = bytes.fromhex("44 0f 29 9c 24 b0 09 00 00")
CAVE_LOAD = bytes.fromhex("f3 45 0f 10 55") + bytes([SIDE_SLOT])
CAVE_SIZE = len(CAVE_LOAD) + len(MOVED) + 5
# the broken first version's cave (loaded the pointer half at +0x1027194) and its size
LEGACY_CAVES = [(bytes.fromhex("f3 45 0f 10 95 94 71 02 01"), 23)]
# constructor: mov byte [rdi+18h], 0 / mov [rdi+20h], r12 - the padding is still +0x19..0x1f
SLOT_LAYOUT = "c6 47 18 00 4c 89 67 20"


def _pattern(hex_with_wildcards):
    """'33 c9 ?? 05' -> compiled bytes regex ('??' matches any byte)."""
    parts = [b"." if t == "??" else re.escape(bytes([int(t, 16)])) for t in hex_with_wildcards.split()]
    return re.compile(b"".join(parts), re.DOTALL)


RE_STOCK = _pattern(f"{SITE_HEAD} {SITE_STOCK} {SITE_TAIL}")
RE_PATCHED = _pattern(f"{SITE_HEAD} e9 ?? ?? ?? ?? 90 90 90 90 90 90 90 90 {SITE_TAIL}")
RE_SLOT_LAYOUT = _pattern(SLOT_LAYOUT)
SITE_AT = len(SITE_HEAD.split())
SITE_LEN = len(SITE_STOCK.split())


class PatchError(Exception):
    """The exe doesn't look like a version this patch understands."""


def md5(data):
    return hashlib.md5(data).hexdigest()


def text_section(data):
    """(file offset, size) of the .text section."""
    pe = struct.unpack_from("<I", data, 0x3C)[0]
    count, opt_size = struct.unpack_from("<H", data, pe + 6)[0], struct.unpack_from("<H", data, pe + 20)[0]
    table = pe + 24 + opt_size
    for i in range(count):
        name, _vsize, _va, raw_size, raw_ptr = struct.unpack_from("<8sIIII", data, table + 40 * i)
        if name.rstrip(b"\0") == b".text":
            return raw_ptr, raw_size
    raise PatchError("no .text section")


def find_cave(data):
    start, size = text_section(data)
    m = re.compile(rb"\xcc{%d,}" % CAVE_SIZE).search(data, start, start + size)
    if not m:
        raise PatchError(f"no int3 padding of {CAVE_SIZE}+ bytes in the code section")
    return m.start()


def rel32(frm, to):
    """jmp rel32 at file offset frm (5 bytes) to file offset to (same section)."""
    return struct.pack("<i", to - (frm + 5))


def cave_bytes(cave, back):
    jmp_at = cave + len(CAVE_LOAD) + len(MOVED)
    return CAVE_LOAD + MOVED + b"\xe9" + rel32(jmp_at, back)


def analyse(data):
    """('stock'|'patched'|'outdated', site offset, cave offset, cave size).
    Raises PatchError if the exe isn't recognised."""
    stock = [m.start() + SITE_AT for m in RE_STOCK.finditer(data)]
    patched = [m.start() + SITE_AT for m in RE_PATCHED.finditer(data)]
    if len(stock) + len(patched) != 1:
        raise PatchError(f"crowd side compare: expected exactly 1 match, found {len(stock)} unpatched + "
                         f"{len(patched)} patched (a game update probably changed this code)")
    if len(list(RE_SLOT_LAYOUT.finditer(data))) != 1:
        raise PatchError("the crowd scene's layout changed (a game update changed CCrowdScene)")
    if stock:
        return "stock", stock[0], find_cave(data), CAVE_SIZE
    site = patched[0]
    cave = site + 5 + struct.unpack_from("<i", data, site + 1)[0]
    if data[cave:cave + len(CAVE_LOAD)] == CAVE_LOAD:
        return "patched", site, cave, CAVE_SIZE
    for load, size in LEGACY_CAVES:
        if data[cave:cave + len(load)] == load:
            return "outdated", site, cave, size
    raise PatchError("the patched site's jump doesn't lead to this patch's code cave")


def status(exe):
    """('stock'|'patched'|'outdated'|'unrecognised', detail) - never raises PatchError."""
    data = open(exe, "rb").read()
    try:
        state, site, cave, _size = analyse(data)
        return state, f"md5 {md5(data)}, site {site:#x}, cave {cave:#x}"
    except PatchError as e:
        return "unrecognised", str(e)


def apply(exe, write=True, log=print):
    """Patch exe (or update an outdated patch). Returns 'applied', 'already
    patched' or 'dry run'. Raises PatchError if the exe isn't recognised."""
    data = bytearray(open(exe, "rb").read())
    before = md5(data)
    state, site, cave, old_size = analyse(data)
    log(f"{exe}\n  md5 {before}  {NAME}: {state}")
    if state == "patched":
        return "already patched"
    back = site + SITE_LEN
    new_site = b"\xe9" + rel32(site, cave) + b"\x90" * (SITE_LEN - 5)
    new_cave = cave_bytes(cave, back) + b"\xcc" * max(0, old_size - CAVE_SIZE)
    log(f"  {site:#09x}  {bytes(data[site:site + SITE_LEN]).hex(' ')}  ->  {new_site.hex(' ')}  (jump to the cave)")
    log(f"  {cave:#09x}  {bytes(data[cave:cave + len(new_cave)]).hex(' ')}  ->  {new_cave.hex(' ')}  (load the split threshold)")
    if not write:
        return "dry run"
    backup = os.path.join(BACKUP_DIR, f"rugbyleague1.exe.{before}.bak")
    if not os.path.exists(backup):
        os.makedirs(BACKUP_DIR, exist_ok=True)
        shutil.copy2(exe, backup)
        log(f"  backup written: {backup}")
    data[site:site + SITE_LEN] = new_site
    data[cave:cave + len(new_cave)] = new_cave
    with open(exe, "wb") as f:
        f.write(data)
    log(f"  patched - new md5 {md5(data)}")
    return "applied"


def restore(exe, log=print):
    data = bytearray(open(exe, "rb").read())
    try:
        state, site, cave, size = analyse(data)
    except PatchError as e:
        sys.exit(f"not restoring: {e}. Use Steam's 'Verify integrity of game files'.")
    if state == "stock":
        log(f"{exe} isn't patched - nothing to undo")
        return
    data[site:site + SITE_LEN] = bytes.fromhex(SITE_STOCK)
    data[cave:cave + size] = b"\xcc" * size
    with open(exe, "wb") as f:
        f.write(data)
    log(f"restored the stock crowd side split in {exe} (md5 {md5(data)})")


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
        print(f"{args.exe}\n  {NAME}: {st}  ({detail})")
        return
    try:
        result = apply(args.exe, write=args.apply)
    except PatchError as e:
        sys.exit(f"refusing to patch: {e}")
    print(result if result != "dry run" else "dry run - pass --apply to write (game must be closed)")


if __name__ == "__main__":
    main()
