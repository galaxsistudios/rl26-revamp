#!/usr/bin/env python3
"""
install.py - let Lua set the crowd's home/away split by patching
rugbyleague1.exe (6 bytes at the crowd's side compare + a 23-byte code cave
in int3 padding).

Every crowd seat (80-byte node) holds two random numbers. One, in [0, 1),
decides whether the seat is filled at the current attendance percentage
(setWantCrowdPercentage). The other, in [-1, 1], decides the side. The
populate function (CCrowdScene, 1.0.5933 @0x140bb3d90) zeroes xmm10 once and
then, per seat:

    comiss xmm10, [rdi+r12+24h]   ; 0 >= value ?
    jae    away                   ; yes: away tags/colours, else home

so about half the fans support each team, mixed through every stand. The
patch replaces only that comiss with a jump to a cave that compares the
seat's value with a threshold from the crowd scene, then returns to the jae:

    stock   comiss xmm10, [rdi+r12+24h]               46 0f 2f 54 27 24
    patched jmp    cave / nop                         e9 <rel32> 90
    cave    mov    rcx, [rbp+960h]                    48 8b 8d 60 09 00 00   ; this (spilled at entry)
            movss  xmm1, [rcx+1ch]                    f3 0f 10 49 1c         ; the threshold
            comiss xmm1, [rdi+r12+24h]                42 0f 2f 4c 27 24
            jmp    back                               e9 <rel32>             ; -> the stock jae

rcx and xmm1 are dead there (both branches load ecx next; xmm1 is volatile
across the call just before). xmm10 stays 0: the function uses it as a 0.0
constant in later clamps (0x140bb5e98..0x140bb614b), so loading the threshold
into xmm10 itself - the second version - turned fans round in their seats.

The threshold is the crowd scene's padding dword at +0x1c. The scene starts
with 6 LOD ratio floats (+0x00..0x17, setLODRatio 0..5), a byte at +0x18
and a qword at +0x20; no crowd code touches +0x19..0x1f. Lua writes it with
CCrowdScene:setLODRatio(7, t), whose index isn't bounds checked (it stores a
float at scene + 4 * index). For a home share H the threshold is t = 1 - 2H;
0 is the stock split. Padding isn't initialised, so every crowd scene the
game builds (crowd_rugby.lua, crowd_frontend.lua) writes it.

Earlier versions (both 2026-11-01) patched the xorps that zeroes xmm10:
v1 loaded +0x1027194, the top half of a heap pointer (crashed the next match
load); v2 loaded +0x1c into xmm10 (fans facing backwards). Both are
recognised: apply replaces them and restore removes them.

The cave goes in the first int3 run of the code section that's long enough
(only one in 1.0.5933: 28 bytes after a ret at 0x1401e3ab3); the patched
site's jump points at it, so status and restore find it again.

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

SIDE_SLOT = 0x1C                # crowd scene padding dword with the threshold (Lua: setLODRatio(SIDE_SLOT / 4, t))

# the side compare: mov rcx,rax / call ... / mov byte [rax+1ch],1 | comiss | jae away / mov eax,1021d30h / mov ecx,1021d40h
SITE_HEAD = "48 8b c8 e8 ?? ?? ?? ?? c6 40 1c 01"
SITE_STOCK = "46 0f 2f 54 27 24"
SITE_TAIL = "73 ?? b8 30 1d 02 01 b9 40 1d 02 01"
CAVE_CODE = (bytes.fromhex("48 8b 8d 60 09 00 00")          # mov rcx, [rbp+960h]
             + bytes.fromhex("f3 0f 10 49") + bytes([SIDE_SLOT])  # movss xmm1, [rcx+1ch]
             + bytes.fromhex("42 0f 2f 4c 27 24"))           # comiss xmm1, [rdi+r12+24h]
CAVE_SIZE = len(CAVE_CODE) + 5

# v1/v2 patched the xorps that zeroes xmm10 (+ the movaps after it) instead
OLD_SITE_HEAD = "44 0f 29 94 24 c0 09 00 00"                 # movaps [rsp+9c0h], xmm10
OLD_SITE_STOCK = "45 0f 57 d2 44 0f 29 9c 24 b0 09 00 00"    # xorps xmm10,xmm10 / movaps [rsp+9b0h], xmm11
OLD_SITE_TAIL = "f3 44 0f 10 1d ?? ?? ?? ??"
OLD_CAVES = [(bytes.fromhex("f3 45 0f 10 95 94 71 02 01"), 23),   # v1: [r13+1027194h]
             (bytes.fromhex("f3 45 0f 10 55 1c"), 20)]            # v2: [r13+1ch]

# constructor: mov byte [rdi+18h], 0 / mov [rdi+20h], r12 - the padding is still +0x19..0x1f
SLOT_LAYOUT = "c6 47 18 00 4c 89 67 20"


def _pattern(hex_with_wildcards):
    """'33 c9 ?? 05' -> compiled bytes regex ('??' matches any byte)."""
    parts = [b"." if t == "??" else re.escape(bytes([int(t, 16)])) for t in hex_with_wildcards.split()]
    return re.compile(b"".join(parts), re.DOTALL)


RE_STOCK = _pattern(f"{SITE_HEAD} {SITE_STOCK} {SITE_TAIL}")
RE_PATCHED = _pattern(f"{SITE_HEAD} e9 ?? ?? ?? ?? 90 {SITE_TAIL}")
RE_OLD_PATCHED = _pattern(f"{OLD_SITE_HEAD} e9 ?? ?? ?? ?? 90 90 90 90 90 90 90 90 {OLD_SITE_TAIL}")
RE_SLOT_LAYOUT = _pattern(SLOT_LAYOUT)
SITE_AT = len(SITE_HEAD.split())
SITE_LEN = len(SITE_STOCK.split())
OLD_SITE_AT = len(OLD_SITE_HEAD.split())
OLD_SITE_LEN = len(OLD_SITE_STOCK.split())


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


def rel32(frm, to, length=5):
    """rel32 for a jump of `length` bytes at file offset frm to file offset to (same section)."""
    return struct.pack("<i", to - (frm + length))


def jump_target(data, at):
    return at + 5 + struct.unpack_from("<i", data, at + 1)[0]


def old_patch(data):
    """(site, cave, cave size) of a v1/v2 patch, or None."""
    sites = [m.start() + OLD_SITE_AT for m in RE_OLD_PATCHED.finditer(data)]
    if len(sites) != 1:
        return None
    cave = jump_target(data, sites[0])
    for load, size in OLD_CAVES:
        if data[cave:cave + len(load)] == load:
            return sites[0], cave, size
    raise PatchError("an old crowd split patch jumps to an unrecognised code cave")


def analyse(data):
    """(state, site, cave, old) with state 'stock' | 'patched' | 'outdated'
    (a v1/v2 patch is present; old = its (site, cave, size)). Raises
    PatchError if the exe isn't recognised."""
    if len(list(RE_SLOT_LAYOUT.finditer(data))) != 1:
        raise PatchError("the crowd scene's layout changed (a game update changed CCrowdScene)")
    stock = [m.start() + SITE_AT for m in RE_STOCK.finditer(data)]
    patched = [m.start() + SITE_AT for m in RE_PATCHED.finditer(data)]
    if len(stock) + len(patched) != 1:
        raise PatchError(f"crowd side compare: expected exactly 1 match, found {len(stock)} unpatched + "
                         f"{len(patched)} patched (a game update probably changed this code)")
    old = old_patch(data)
    if patched:
        cave = jump_target(data, patched[0])
        if data[cave:cave + len(CAVE_CODE)] != CAVE_CODE:
            raise PatchError("the patched side compare jumps to an unrecognised code cave")
        return ("outdated" if old else "patched"), patched[0], cave, old
    return ("outdated" if old else "stock"), stock[0], None, old


def undo_old(data, old, log):
    site, cave, size = old
    data[site:site + OLD_SITE_LEN] = bytes.fromhex(OLD_SITE_STOCK)
    data[cave:cave + size] = b"\xcc" * size
    log(f"  {site:#09x}  removed an earlier version of this patch (cave {cave:#x}, {size} bytes)")


def status(exe):
    """('stock'|'patched'|'outdated'|'unrecognised', detail) - never raises PatchError."""
    data = open(exe, "rb").read()
    try:
        state, site, cave, _old = analyse(data)
        return state, f"md5 {md5(data)}, site {site:#x}" + (f", cave {cave:#x}" if cave is not None else "")
    except PatchError as e:
        return "unrecognised", str(e)


def apply(exe, write=True, log=print):
    """Patch exe (replacing an earlier version). Returns 'applied', 'already
    patched' or 'dry run'. Raises PatchError if the exe isn't recognised."""
    data = bytearray(open(exe, "rb").read())
    before = md5(data)
    state, site, cave, old = analyse(data)
    log(f"{exe}\n  md5 {before}  {NAME}: {state}")
    if state == "patched":
        return "already patched"
    if old:
        undo_old(data, old, log)
    if cave is None:
        cave = find_cave(data)
        new_site = b"\xe9" + rel32(site, cave) + b"\x90" * (SITE_LEN - 5)
        jmp_at = cave + len(CAVE_CODE)
        new_cave = CAVE_CODE + b"\xe9" + rel32(jmp_at, site + SITE_LEN)
        log(f"  {site:#09x}  {bytes(data[site:site + SITE_LEN]).hex(' ')}  ->  {new_site.hex(' ')}  (jump to the cave)")
        log(f"  {cave:#09x}  {bytes(data[cave:cave + CAVE_SIZE]).hex(' ')}  ->  {new_cave.hex(' ')}  (compare with the threshold)")
        data[site:site + SITE_LEN] = new_site
        data[cave:cave + CAVE_SIZE] = new_cave
    if not write:
        return "dry run"
    backup = os.path.join(BACKUP_DIR, f"rugbyleague1.exe.{before}.bak")
    if not os.path.exists(backup):
        os.makedirs(BACKUP_DIR, exist_ok=True)
        shutil.copy2(exe, backup)
        log(f"  backup written: {backup}")
    with open(exe, "wb") as f:
        f.write(data)
    log(f"  patched - new md5 {md5(data)}")
    return "applied"


def restore(exe, log=print):
    data = bytearray(open(exe, "rb").read())
    try:
        state, site, cave, old = analyse(data)
    except PatchError as e:
        sys.exit(f"not restoring: {e}. Use Steam's 'Verify integrity of game files'.")
    if state == "stock":
        log(f"{exe} isn't patched - nothing to undo")
        return
    if old:
        undo_old(data, old, log)
    if cave is not None:
        data[site:site + SITE_LEN] = bytes.fromhex(SITE_STOCK)
        data[cave:cave + CAVE_SIZE] = b"\xcc" * CAVE_SIZE
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
