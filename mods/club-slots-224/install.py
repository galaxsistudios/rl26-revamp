#!/usr/bin/env python3
"""
install.py - room for 4 more on-disc clubs (ids 220-223) by patching
rugbyleague1.exe (11 dwords, 220 -> 224).

On-disc clubs are ids 1-219 (0 is INVALID_CLUB_ID) and stock uses all of
them. The limit isn't the club array (a growable vector, already 256 big) but:

  - the defaultdata_clubs loader constructs exactly 220 slots before it reads
    the records (mov edi, 0DCh), and then stores each record at slot[id]: a
    record with id 220 lands in an unconstructed slot and the first roster
    push writes through a null pointer (boot crash, 2026-11-02);
  - "on disc or user-made?" tests: (disc id or id) < 220, also the Lua
    constant MAX_CLUBS_ON_DISC and isOnDisc. User-made (Academy) clubs take
    ids from 1000 (addClub), so 220-999 are free;
  - the on-disc count loop.

The custom-licensed save dict (edited official clubs, 220 keys) is left at
220: its size is part of the save format (see _SITES).

The pool's id bitset is inline in its header, 7 dwords = ids 0-223, so 224 is
as far as this patch goes. Past that the bitset has to move (64 access sites):
see the club-pool notes in docs/big-ant-base/native-exe.md.

Each site is found by the bytes around its immediate, with 220 or 224 as the
wildcard, so --restore works whatever other exe patches are applied. The first
apply keeps a copy of the exe as _backup/rugbyleague1.exe.<md5>.bak.

Clubs in 220-223 need this patch: an unpatched exe crashes at boot with them,
so tools/data_mods.py only allows them while this mod is present.

Usage (game closed):
    python mods\\club-slots-224\\install.py            # dry run
    python mods\\club-slots-224\\install.py --apply    # back up, then patch
    python mods\\club-slots-224\\install.py --status
    python mods\\club-slots-224\\install.py --restore  # back to 220
"""

import argparse
import hashlib
import os
import re
import shutil
import sys

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO_ROOT, "tools"))
import games  # noqa: E402  (finds the RL26 install)

DEFAULT_EXE = games.rl26_path("rugbyleague1.exe")
BACKUP_DIR = os.path.join(REPO_ROOT, "_backup")

STOCK, SLOTS = 220, 224
MAX_CLUB_ID = SLOTS  # read by tools/data_mods.py

# (name, bytes before the imm32, bytes after it); RVAs are 1.0.5933's
_SITES = [
    ("loader slot count (0xa90736 mov edi)", "01ff50384898bf", "48014308"),
    ("loader disc id (0xa90b5c cmp r12d)", "03314589264181fc", "73044589"),
    ("club flags custom (0xa8e15d cmp ecx)", "85c975028b0881f9", "720e80a0"),
    ("club info custom (0xdcc082 cmp ecx)", "85c975028b0e81f9", "89482848"),
    ("set id disc id (0xfad938 cmp eax)", "dab7560089073d", "73038947"),
    ("club list custom (0xfb069c cmp eax)", "c07503418b003d", "720d498b"),
    ("isOnDisc (0xfb1817 cmp eax)", "560085c0741f3d", "7318ba01"),
    ("isOnDisc (0xfb9a18 cmp edx)", "8b1085d2742081fa", "7318ba01"),
    ("copy disc id (0x5ba3cd cmp eax)", "0424418947083d", "73044189"),
    ("Lua MAX_CLUBS_ON_DISC (0xfb17b7 mov edx)", "cbe849925600ba", "488bcbe8"),
    ("on-disc count loop (0xa893c6 mov r11d)", "aa1e014533d241bb", "458bca48"),
]
# NOT patched: 0xa8bd62 / 0xa8c9d8 are the save schema of
# paClubDatabaseUserCreated.m_customLicensedClubDatabaseDict (u16 Keys[220] /
# u32 Values[220], edited official clubs). 224 there changes the save format:
# existing saves loaded shifted (2026-11-02: the Kangaroos' team-select preview
# showed an edited Roosters women's club). The dict only holds edited clubs.


class PatchError(Exception):
    """The exe doesn't look like a version this patch understands."""


def md5(data):
    return hashlib.md5(data).hexdigest()


def analyse(data):
    """[(name, imm offset, value)] for every site. Raises PatchError unless
    each pattern matches exactly once."""
    sites = []
    for name, pre, post in _SITES:
        regex = re.compile(re.escape(bytes.fromhex(pre)) + rb"([\xdc\xe0])\x00\x00\x00" +
                           re.escape(bytes.fromhex(post)), re.DOTALL)
        found = list(regex.finditer(data))
        if len(found) != 1:
            raise PatchError(f"{name}: expected 1 site, found {len(found)} (a game update probably changed this code)")
        sites.append((name, found[0].start(1), found[0].group(1)[0]))
    return sites


def state(sites):
    values = {v for _n, _o, v in sites}
    if values == {STOCK}:
        return "stock"
    if values == {SLOTS}:
        return "patched"
    return "mixed"


def status(exe):
    """('stock'|'patched'|'mixed'|'unrecognised', detail) - never raises."""
    data = open(exe, "rb").read()
    try:
        return state(analyse(data)), md5(data)
    except PatchError as e:
        return "unrecognised", str(e)


def _write(exe, data, sites, value):
    for _name, off, _old in sites:
        data[off] = value
    with open(exe, "wb") as f:
        f.write(data)


def apply(exe, write=True, log=print):
    """Patch exe to 224 club slots. Returns 'applied', 'already patched' or
    'dry run'. Raises PatchError if the exe isn't recognised."""
    data = bytearray(open(exe, "rb").read())
    before = md5(data)
    sites = analyse(data)
    st = state(sites)
    log(f"{exe}\n  md5 {before}  club slots: {st}")
    if st == "patched":
        return "already patched"
    for name, off, value in sites:
        log(f"  {off:#09x}  {name}: {value} -> {SLOTS}")
    if not write:
        return "dry run"

    backup = os.path.join(BACKUP_DIR, f"rugbyleague1.exe.{before}.bak")
    if not os.path.exists(backup):
        os.makedirs(BACKUP_DIR, exist_ok=True)
        shutil.copy2(exe, backup)
        log(f"  backup written: {backup}")
    _write(exe, data, sites, SLOTS)
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
    log(f"restored 220 club slots in {exe} (md5 {md5(data)})")
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
        print(f"{args.exe}\n  club slots: {st}  ({detail})")
        return
    try:
        result = apply(args.exe, write=args.apply)
    except PatchError as e:
        sys.exit(f"refusing to patch: {e}")
    print(result if result != "dry run" else "dry run - pass --apply to write (game must be closed)")


if __name__ == "__main__":
    main()
