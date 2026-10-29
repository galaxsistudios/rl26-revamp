#!/usr/bin/env python3
"""
install.py - hand AI interchanges over to Lua by patching rugbyleague1.exe
(7 bytes at 2 sites in paTeamSubstitutionDecisionKnowledge_job_).

Stock, the AI's interchanges come from a native job that runs on a fixed clock
(match minutes): both props at 20', 38' and 60', the hooker at 55' and the
lock at 65'. Each one brings on the first player in subOnOrderList who is on
the bench, so the AI keeps using the same two bench players. Stamina plays no
part. Per side and per player, the job does:

    if player injured:                  queue injury interchange   (kept)
    mov  r11d, [rdx+rcx+18h]            ; assigned role
    cmp  r11d, 6
    jle  next_player                    ; backs never      <- patch 2: jmp
    ...20'/38'/55'/60'/65' windows...

Patch 2 makes that jle an unconditional jmp, so only the injury check is
left. The Lua half of the mod (ai/substitutions/substitution_listener.lua)
then queues fatigue interchanges with SubstitutionRequest.

Those requests land in the side's CSubstitutionEntity queue. For an AI side the
job only copies that queue into its decision knowledge when a CMatchInfo flag
(+9, set in Be a Pro) is on:

    cmp  byte [rdi+9], 0                ; CMatchInfo
    mov  [rsp+50h], rdx
    je   skip_merge                     <- patch 1: 6 NOPs

so patch 1 makes the merge unconditional. Human sides on manual interchanges
take a different branch and are unaffected.

Sites are found by instruction pattern, not file offset, and restore puts the
stock bytes back the same way, so this works whatever other exe patches are
applied before or after it. The first apply keeps a copy of the exe it patched
as _backup/rugbyleague1.exe.<md5>.bak.

A Steam update or "Verify integrity of game files" restores the original exe;
unlock-all-kits/launch.py (the Steam launch option) re-applies this patch too.

Usage (game closed):
    python mods\\ai-interchange-rotation\\install.py            # dry run
    python mods\\ai-interchange-rotation\\install.py --apply    # back up, then patch
    python mods\\ai-interchange-rotation\\install.py --status   # patched or not
    python mods\\ai-interchange-rotation\\install.py --restore  # undo this patch
"""

import argparse
import hashlib
import os
import re
import shutil
import sys

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), "tools"))
import games  # noqa: E402  (finds the RL26 install)

DEFAULT_EXE = games.rl26_path("rugbyleague1.exe")
BACKUP_DIR = os.path.join(REPO_ROOT, "_backup")


def _pattern(hex_with_wildcards):
    """'33 c9 ?? 05' -> compiled bytes regex ('??' matches any byte)."""
    parts = [b"." if t == "??" else re.escape(bytes([int(t, 16)])) for t in hex_with_wildcards.split()]
    return re.compile(b"".join(parts), re.DOTALL)


class Site:
    def __init__(self, name, head, stock, patched, tail):
        self.name = name
        self.stock = bytes.fromhex(stock)
        self.patched = bytes.fromhex(patched)
        self.at = len(head.split())
        self.re_stock = _pattern(f"{head} {stock} {tail}")
        self.re_patched = _pattern(f"{head} {patched} {tail}")


SITES = [
    # cmp byte [rdi+9],0 / mov [rsp+50h],rdx / je skip_merge / movsxd rcx,[rsi+28h] / lea rbx,[rsi+38h]
    # je -> jo: never taken after a cmp with 0 (no overflow), so the merge always
    # runs. Only the opcode changes - the rel32 differs per build (1.0.5887:
    # 1a 01 00 00, 1.0.5933: 21 01 00 00), so it stays a wildcard and restore
    # needs nothing but this byte.
    Site("merge Lua interchanges for AI sides",
         "80 7f 09 00 48 89 54 24 50", "0f 84", "0f 80",
         "?? ?? 00 00 48 63 4e 28 48 8d 5e 38"),
    # mov r11d,[rdx+rcx+18h] / cmp r11d,6 / jle next_player / comiss xmm6,xmm11
    Site("skip timed AI interchanges",
         "44 8b 5c 0a 18 41 83 fb 06", "7e", "eb",
         "8c 41 0f 2f f3"),
]


class PatchError(Exception):
    """The exe doesn't look like a version this patch understands."""


def md5(data):
    return hashlib.md5(data).hexdigest()


def analyse(data):
    """Return [(site, 'stock'|'patched', offset)]. Raises PatchError if any
    site isn't recognised."""
    out = []
    for site in SITES:
        stock = [m.start() for m in site.re_stock.finditer(data)]
        patched = [m.start() for m in site.re_patched.finditer(data)]
        if len(stock) + len(patched) != 1:
            raise PatchError(f"{site.name}: expected exactly 1 match, found {len(stock)} unpatched + "
                             f"{len(patched)} patched (a game update probably changed this code)")
        out.append((site, "stock", stock[0] + site.at) if stock else (site, "patched", patched[0] + site.at))
    return out


def _summary(sites):
    states = {st for _, st, _ in sites}
    return states.pop() if len(states) == 1 else "partly patched"


def status(exe):
    """('stock'|'patched'|'partly patched'|'unrecognised', detail) - never raises PatchError."""
    data = open(exe, "rb").read()
    try:
        return _summary(analyse(data)), md5(data)
    except PatchError as e:
        return "unrecognised", str(e)


def apply(exe, write=True, log=print):
    """Patch exe. Returns 'applied', 'already patched' or 'dry run'. Raises
    PatchError if the exe isn't recognised."""
    data = bytearray(open(exe, "rb").read())
    before = md5(data)
    sites = analyse(data)
    log(f"{exe}\n  md5 {before}  AI interchange rotation: {_summary(sites)}")
    todo = [(site, off) for site, st, off in sites if st == "stock"]
    if not todo:
        return "already patched"
    for site, off in todo:
        log(f"  {off:#09x}  {site.stock.hex(' ')}  ->  {site.patched.hex(' ')}  ({site.name})")
    if not write:
        return "dry run"

    backup = os.path.join(BACKUP_DIR, f"rugbyleague1.exe.{before}.bak")
    if not os.path.exists(backup):
        os.makedirs(BACKUP_DIR, exist_ok=True)
        shutil.copy2(exe, backup)
        log(f"  backup written: {backup}")
    for site, off in todo:
        data[off:off + len(site.patched)] = site.patched
    with open(exe, "wb") as f:
        f.write(data)
    log(f"  patched - new md5 {md5(data)}")
    return "applied"


def restore(exe, log=print):
    data = bytearray(open(exe, "rb").read())
    try:
        sites = analyse(data)
    except PatchError as e:
        sys.exit(f"not restoring: {e}. Use Steam's 'Verify integrity of game files'.")
    todo = [(site, off) for site, st, off in sites if st == "patched"]
    if not todo:
        log(f"{exe} isn't patched - nothing to undo")
        return
    for site, off in todo:
        data[off:off + len(site.stock)] = site.stock
    with open(exe, "wb") as f:
        f.write(data)
    log(f"restored the stock AI interchange code in {exe} (md5 {md5(data)})")


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
        print(f"{args.exe}\n  AI interchange rotation: {st}  ({detail})")
        return
    try:
        result = apply(args.exe, write=args.apply)
    except PatchError as e:
        sys.exit(f"refusing to patch: {e}")
    print(result if result != "dry run" else "dry run - pass --apply to write (game must be closed)")


if __name__ == "__main__":
    main()
