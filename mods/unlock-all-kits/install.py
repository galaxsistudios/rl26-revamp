#!/usr/bin/env python3
"""
install.py - unlock every club's hidden kits (jerseys) by patching
rugbyleague1.exe, keeping each kit's real name.

Why kits go missing: the game rebuilds each club's kit list at load time in a
native function. It walks the club's kits and keeps one only if its exact
name is recognised - HOME, AWAY, BLACK, WHITE, ... always; ALTERNATE,
INDIGENOUS, ANZAC ROUND, HERITAGE, ... only if the club id is in a
hard-coded list (every Cowboys club is left out of all of them). Any other
name ("HOME 26", "THIRD", "NORTHERN LIGHTS", "CHARITY", "MAGIC-WEEKEND", ...)
is dropped. On the stock game (Steam build 26072201) that hides 64 kits
across 41 clubs, even though their data and textures ship with the game.

The patch makes that function keep every kit exactly once, in data order:
  A. the HOME name check's "not HOME" jump becomes NOPs, so the HOME branch
     copies every kit;
  B. the instruction that jump used to land on (the start of the AWAY check)
     becomes a jump to C;
  C. the loop's next-kit step.

The sites are found by instruction pattern, not fixed file offsets, so the
patch survives game updates that only move code around. Each site is
cross-checked against the others (B must be exactly where A's jump lands, C
must be the block that loops back to A); if anything doesn't line up - e.g.
an update changed the kit filter itself - nothing is written.

Undo: every apply records the exact bytes it changed, keyed by the patched
exe's md5, in _backup/unlock-all-kits.json, and keeps a copy of the
unpatched exe as _backup/rugbyleague1.exe.<md5>.bak. --restore reverses the
recorded bytes only if the current exe is one this tool patched, so it can
never put an older game version back over a newer one.

A Steam update or "Verify integrity of game files" restores the original
exe; launch.py (set as the game's Steam launch option) re-applies the patch
automatically before each launch. It's unknown whether a modified exe
affects online play - --restore before playing online to be safe.

Usage (game closed):
    python mods\\unlock-all-kits\\install.py            # dry run
    python mods\\unlock-all-kits\\install.py --apply    # back up, then patch
    python mods\\unlock-all-kits\\install.py --status   # patched or not
    python mods\\unlock-all-kits\\install.py --restore  # undo this tool's patch
"""

import argparse
import hashlib
import json
import os
import re
import shutil
import struct
import sys

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), "tools"))
import games  # noqa: E402  (finds the RL26 install)

DEFAULT_EXE = games.rl26_path("rugbyleague1.exe")
BACKUP_DIR = os.path.join(REPO_ROOT, "_backup")
RECORDS = os.path.join(BACKUP_DIR, "unlock-all-kits.json")


def _pattern(hex_with_wildcards):
    """'33 c9 ?? 05' -> compiled bytes regex ('??' matches any byte)."""
    parts = [b"." if t == "??" else re.escape(bytes([int(t, 16)])) for t in hex_with_wildcards.split()]
    return re.compile(b"".join(parts), re.DOTALL)


# Site A: compare the kit name against "HOME" (5 bytes incl. NUL) one byte at
# a time. The 6 bytes at offset 13 are the "not HOME" jump (jne rel32) on a
# stock exe, or NOPs once patched.
_A_HEAD = "33 c9 0f b6 04 08 48 ff c1 3a 44 0a ff"          # xor ecx,ecx / movzx eax,[rax+rcx] / inc rcx / cmp al,[rdx+rcx-1]
_A_TAIL = "48 8b 85 ?? ?? ?? ?? 48 83 f9 05 75 ??"          # mov rax,[rbp+X] / cmp rcx,5 / jne loop
SITE_A_STOCK = _pattern(f"{_A_HEAD} 0f 85 ?? ?? ?? ?? {_A_TAIL}")
SITE_A_PATCHED = _pattern(f"{_A_HEAD} 90 90 90 90 90 90 {_A_TAIL}")
A_JUMP_AT = 13
# Site B: start of the AWAY check - lea rbx,[rdi+X] / xor ecx,ecx.
SITE_B_STOCK = _pattern("48 8d 9f ?? ?? ?? ?? 33 c9")
# Site C: next-kit step; ends with jne rel32 back to site A's loop top.
SITE_C = _pattern("48 8b 85 ?? ?? ?? ?? 48 8d 15 ?? ?? ?? ?? 48 05 ?? ?? ?? ?? "
                  "4c 8d 05 ?? ?? ?? ?? 48 81 c7 ?? ?? ?? ?? 48 89 85 ?? ?? ?? ?? "
                  "48 3b bd ?? ?? ?? ?? 0f 85 ?? ?? ?? ??")
C_LOOP_JUMP_AT = 48


class PatchError(Exception):
    """The exe doesn't look like a version this patch understands."""


def md5(data):
    return hashlib.md5(data).hexdigest()


def _rel32_target(data, jump_off, insn_len):
    return jump_off + insn_len + struct.unpack_from("<i", data, jump_off + insn_len - 4)[0]


def _find_c(data, loop_top):
    hits = [m.start() for m in SITE_C.finditer(data)
            if _rel32_target(data, m.start() + C_LOOP_JUMP_AT, 6) == loop_top]
    if len(hits) != 1:
        raise PatchError(f"next-kit step: expected 1 match looping back to the name check, found {len(hits)}")
    return hits[0]


def analyse(data):
    """Return ('stock', changes) with the changes to apply, or ('patched', None).
    Raises PatchError if the exe isn't recognised."""
    stock = [m.start() for m in SITE_A_STOCK.finditer(data)]
    patched = [m.start() for m in SITE_A_PATCHED.finditer(data)]
    if len(stock) + len(patched) != 1:
        raise PatchError(f"kit name check: expected exactly 1 match, found {len(stock)} unpatched + {len(patched)} patched "
                         "(a game update probably changed this code)")
    if patched:
        a = patched[0]
        c = _find_c(data, a)
        b = data.find(b"\xe9", a, a + 0x400)
        while b != -1 and not (data[b + 5:b + 7] == b"\x90\x90" and _rel32_target(data, b, 5) == c):
            b = data.find(b"\xe9", b + 1, a + 0x400)
        if b == -1:
            raise PatchError("kit name check is patched but the matching jump to the next kit wasn't found")
        return "patched", None

    a = stock[0]
    jump = a + A_JUMP_AT
    b = _rel32_target(data, jump, 6)
    if not SITE_B_STOCK.match(data, b):
        raise PatchError(f"the 'not HOME' jump lands on unexpected code at {b:#x}")
    c = _find_c(data, a)
    rel = c - (b + 5)
    changes = [
        (jump, bytes(data[jump:jump + 6]), b"\x90" * 6),
        (b, bytes(data[b:b + 7]), b"\xe9" + struct.pack("<i", rel) + b"\x90\x90"),
    ]
    return "stock", changes


def _load_records():
    if os.path.exists(RECORDS):
        with open(RECORDS) as f:
            return json.load(f)
    return {}


def _save_records(records):
    os.makedirs(BACKUP_DIR, exist_ok=True)
    with open(RECORDS, "w") as f:
        json.dump(records, f, indent=1)


def status(exe):
    """('stock'|'patched'|'unrecognised', detail) - never raises PatchError."""
    data = open(exe, "rb").read()
    try:
        st, _ = analyse(data)
        return st, md5(data)
    except PatchError as e:
        return "unrecognised", str(e)


def apply(exe, write=True, log=print):
    """Patch exe if it's stock. Returns 'applied', 'already patched' or
    'dry run'. Raises PatchError if the exe isn't recognised."""
    data = bytearray(open(exe, "rb").read())
    stock_md5 = md5(data)
    st, changes = analyse(data)
    log(f"{exe}\n  md5 {stock_md5}  kit filter: {st}")
    if st == "patched":
        return "already patched"
    for off, old, new in changes:
        log(f"  {off:#09x}  {old.hex(' ')}  ->  {new.hex(' ')}")
    if not write:
        return "dry run"

    backup = os.path.join(BACKUP_DIR, f"rugbyleague1.exe.{stock_md5}.bak")
    if not os.path.exists(backup):
        os.makedirs(BACKUP_DIR, exist_ok=True)
        shutil.copy2(exe, backup)
        log(f"  backup written: {backup}")
    for off, _old, new in changes:
        data[off:off + len(new)] = new
    with open(exe, "wb") as f:
        f.write(data)
    patched_md5 = md5(data)
    records = _load_records()
    records[patched_md5] = {"stock_md5": stock_md5,
                            "changes": [[off, old.hex(), new.hex()] for off, old, new in changes]}
    _save_records(records)
    log(f"  patched - new md5 {patched_md5}")
    return "applied"


def restore(exe, log=print):
    data = bytearray(open(exe, "rb").read())
    cur = md5(data)
    rec = _load_records().get(cur)
    if rec is None:
        sys.exit(f"{exe} (md5 {cur}) isn't an exe this tool patched - nothing to undo. "
                 "If the game misbehaves, use Steam's 'Verify integrity of game files'.")
    for off, old_hex, new_hex in rec["changes"]:
        if data[off:off + len(bytes.fromhex(new_hex))] != bytes.fromhex(new_hex):
            sys.exit(f"unexpected bytes at {off:#x} - not restoring. Use Steam's 'Verify integrity of game files'.")
        old = bytes.fromhex(old_hex)
        data[off:off + len(old)] = old
    if md5(data) != rec["stock_md5"]:
        sys.exit("restored bytes don't reproduce the recorded original - not writing. "
                 "Use Steam's 'Verify integrity of game files'.")
    with open(exe, "wb") as f:
        f.write(data)
    log(f"restored {exe} to md5 {rec['stock_md5']}")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--exe", default=DEFAULT_EXE)
    g = ap.add_mutually_exclusive_group()
    g.add_argument("--apply", action="store_true", help="back up the exe, then patch it")
    g.add_argument("--restore", action="store_true", help="undo this tool's patch")
    g.add_argument("--status", action="store_true", help="report whether the exe is patched")
    args = ap.parse_args()

    if args.restore:
        restore(args.exe)
        return
    if args.status:
        st, detail = status(args.exe)
        print(f"{args.exe}\n  kit filter: {st}  ({detail})")
        return
    try:
        result = apply(args.exe, write=args.apply)
    except PatchError as e:
        sys.exit(f"refusing to patch: {e}")
    print(result if result != "dry run" else "dry run - pass --apply to write (game must be closed)")


if __name__ == "__main__":
    main()
