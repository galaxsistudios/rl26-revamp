#!/usr/bin/env python3
"""
install.py - let the game drop its boot splash screens (Nacon, Rugby League 26,
BigAnt, legal/autosave notices) as soon as the front end is ready, by patching
rugbyleague1.exe (2 bytes).

The splash sequence is native. Lua ends it by polling
native.destroyLegalScreens() from WaitForSignInState.update, but the native
only destroys the splash object once its queue of screens is empty - until
then it returns false and the "press start" screen waits behind it:

    mov  rcx, [rdi+250h]     ; legal screens object
    test rcx, rcx
    je   done                ; none -> return true
    mov  rax, [rcx+58h]
    xor  edx, edx
    cmp  [rax], rdx          ; screens still queued?
    jne  return_false        ; <- patched to NOPs
    mov  [rdi+250h], rdx     ; destroy it, return true
    ...

With the jne NOPed the first poll destroys the splash, which is the same
teardown the game always does, just earlier. The Lua half of the mod
(src/script-game/app/signin/waitforsignin_state.lua) then signs in straight
away, so the game boots to the main menu.

The site is found by instruction pattern, not file offset. Undo puts the jne
back by pattern too, so it works whatever other exe patches (unlock-all-kits)
are applied before or after this one. The first apply also keeps a copy of
the exe it patched as _backup/rugbyleague1.exe.<md5>.bak.

A Steam update or "Verify integrity of game files" restores the original exe;
unlock-all-kits/launch.py (the Steam launch option) re-applies this patch too.

Usage (game closed):
    python mods\\skip-intro-to-main-menu\\install.py            # dry run
    python mods\\skip-intro-to-main-menu\\install.py --apply    # back up, then patch
    python mods\\skip-intro-to-main-menu\\install.py --status   # patched or not
    python mods\\skip-intro-to-main-menu\\install.py --restore  # undo this patch
"""

import argparse
import hashlib
import os
import re
import shutil
import sys

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DEFAULT_EXE = r"D:\SteamLibrary\steamapps\common\Rugby League\rugbyleague1.exe"
BACKUP_DIR = os.path.join(REPO_ROOT, "_backup")


def _pattern(hex_with_wildcards):
    """'33 c9 ?? 05' -> compiled bytes regex ('??' matches any byte)."""
    parts = [b"." if t == "??" else re.escape(bytes([int(t, 16)])) for t in hex_with_wildcards.split()]
    return re.compile(b"".join(parts), re.DOTALL)


_HEAD = "48 8b 8f ?? ?? ?? ?? 48 85 c9 74 1c 48 8b 41 ?? 33 d2 48 39 10"   # mov rcx,[rdi+X] .. cmp [rax],rdx
_TAIL = "48 89 97 ?? ?? ?? ?? ba 01 00 00 00 48 8b 01 ff 10"               # mov [rdi+X],rdx / mov edx,1 / call [rax]
JUMP_STOCK = b"\x75\x16"      # jne return_false
JUMP_PATCHED = b"\x90\x90"
SITE_STOCK = _pattern(f"{_HEAD} 75 16 {_TAIL}")
SITE_PATCHED = _pattern(f"{_HEAD} 90 90 {_TAIL}")
JUMP_AT = 21


class PatchError(Exception):
    """The exe doesn't look like a version this patch understands."""


def md5(data):
    return hashlib.md5(data).hexdigest()


def analyse(data):
    """Return ('stock'|'patched', offset of the jne). Raises PatchError if the
    exe isn't recognised."""
    stock = [m.start() for m in SITE_STOCK.finditer(data)]
    patched = [m.start() for m in SITE_PATCHED.finditer(data)]
    if len(stock) + len(patched) != 1:
        raise PatchError(f"destroyLegalScreens: expected exactly 1 match, found {len(stock)} unpatched + "
                         f"{len(patched)} patched (a game update probably changed this code)")
    return ("stock", stock[0] + JUMP_AT) if stock else ("patched", patched[0] + JUMP_AT)


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
    before = md5(data)
    st, off = analyse(data)
    log(f"{exe}\n  md5 {before}  splash skip: {st}")
    if st == "patched":
        return "already patched"
    log(f"  {off:#09x}  {JUMP_STOCK.hex(' ')}  ->  {JUMP_PATCHED.hex(' ')}")
    if not write:
        return "dry run"

    backup = os.path.join(BACKUP_DIR, f"rugbyleague1.exe.{before}.bak")
    if not os.path.exists(backup):
        os.makedirs(BACKUP_DIR, exist_ok=True)
        shutil.copy2(exe, backup)
        log(f"  backup written: {backup}")
    data[off:off + 2] = JUMP_PATCHED
    with open(exe, "wb") as f:
        f.write(data)
    log(f"  patched - new md5 {md5(data)}")
    return "applied"


def restore(exe, log=print):
    data = bytearray(open(exe, "rb").read())
    try:
        st, off = analyse(data)
    except PatchError as e:
        sys.exit(f"not restoring: {e}. Use Steam's 'Verify integrity of game files'.")
    if st == "stock":
        log(f"{exe} isn't patched - nothing to undo")
        return
    data[off:off + 2] = JUMP_STOCK
    with open(exe, "wb") as f:
        f.write(data)
    log(f"restored the splash check in {exe} (md5 {md5(data)})")


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
        print(f"{args.exe}\n  splash skip: {st}  ({detail})")
        return
    try:
        result = apply(args.exe, write=args.apply)
    except PatchError as e:
        sys.exit(f"refusing to patch: {e}")
    print(result if result != "dry run" else "dry run - pass --apply to write (game must be closed)")


if __name__ == "__main__":
    main()
