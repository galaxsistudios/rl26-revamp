#!/usr/bin/env python3
"""
install.py - choose which controller's button icons the game shows (PS5,
Xbox, PS4, Switch, or the stock auto mode) by patching rugbyleague1.exe
(4 bytes).

Why a DualSense shows Xbox buttons: every icon set ships with the PC build
and is always loaded (resources/tooltipicons/{xboxone,ps4,ps5,
nintendoswitch,pc}.xaml, keys Xbox_FaceDown, PS5_FaceDown, ...). The native
code that resolves an icon builds "<prefix><button>", picking the prefix from
a global icon style:

    0 auto    keyboard -> PC_, any gamepad -> Xbox_   (PC default)
    1 xbox    Xbox_
    2 ps4     PS4_
    3 ps5     PS5_
    4 switch  NintendoSwitch_

The same style also picks the PC/XB/PS/SW variant of localised button names.
It's set once at startup from the environment arg "environmentTooltips",
which defaults to "pc" (auto) when the arg is absent:

    lea  rax, ["pc"]        ; <- patched to point at "ps5" / "xbox" / ...
    mov  [rbp-10h], rax
    call parse_tooltip_env  ; "xbox"->1 "ps4"->2 "ps5"->3 "switch"->4, else 0

The patch only retargets that default string at another one the parser
already compares against, so the game takes its own console code path. A
forced style applies to every prompt, including keyboard/mouse play.

The site is found by instruction pattern, and the strings are read from the
parser itself, so updates that only move code around are fine. The first
apply keeps a copy of the exe it patched as _backup/rugbyleague1.exe.<md5>.bak.
The chosen style is saved in _backup/controller-button-icons.json so
unlock-all-kits/launch.py (the Steam launch option) re-applies it after a
Steam update or "Verify integrity of game files".

Usage (game closed):
    python mods\\controller-button-icons\\install.py                    # dry run (saved style, default ps5)
    python mods\\controller-button-icons\\install.py --icons ps5 --apply
    python mods\\controller-button-icons\\install.py --icons xbox --apply
    python mods\\controller-button-icons\\install.py --status
    python mods\\controller-button-icons\\install.py --restore          # back to stock auto
"""

import argparse
import hashlib
import json
import os
import re
import shutil
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import atlas  # noqa: E402

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), "tools"))
import games  # noqa: E402  (finds the RL26 install)

DEFAULT_EXE = games.rl26_path("rugbyleague1.exe")
BACKUP_DIR = os.path.join(REPO_ROOT, "_backup")
SETTINGS = os.path.join(BACKUP_DIR, "controller-button-icons.json")  # not under mods/ - build.py would treat it as a bundle file

# Icon style name -> the environmentTooltips value the game parses for it.
STYLES = {"auto": "pc", "xbox": "xbox", "ps4": "ps4", "ps5": "ps5", "switch": "switch"}
PS_STYLES = {"ps4", "ps5"}
# "detect" isn't a game value: it picks one of STYLES from the pads plugged
# in when the patch is applied (launch.py does that before every launch).
CHOICES = ["detect", *STYLES]
DEFAULT_STYLE = "detect"

# Sony HID product ids -> style. Any other Sony pad counts as ps5.
SONY_VID = "054C"
SONY_PADS = {"05C4": "ps4", "09CC": "ps4", "0BA0": "ps4",   # DualShock 4 v1/v2, wireless adapter
             "0CE6": "ps5", "0DF2": "ps5"}                  # DualSense, DualSense Edge
# USB:       HID\VID_054C&PID_0CE6&MI_03\...
# Bluetooth: HID\{00001124-...}_VID&0002054C_PID&0CE6\...
_HID_ID = re.compile(r"VID[_&](?:0002)?([0-9A-F]{4})[&_]PID[_&]([0-9A-F]{4})", re.I)


def present_hid_ids():
    """Device instance ids of every HID device currently connected."""
    import ctypes
    import ctypes.wintypes as w
    cm = ctypes.WinDLL("cfgmgr32")
    flags = 0x1 | 0x100  # CM_GETIDLIST_FILTER_ENUMERATOR | CM_GETIDLIST_FILTER_PRESENT
    n = w.ULONG()
    if cm.CM_Get_Device_ID_List_SizeW(ctypes.byref(n), "HID", flags) != 0:
        return []
    buf = ctypes.create_unicode_buffer(n.value)
    if cm.CM_Get_Device_ID_ListW("HID", buf, n.value, flags) != 0:
        return []
    return [s for s in buf[:n.value].split("\0") if s]


def detect_style(log=print):
    """ps5/ps4 if a PlayStation pad is connected, else stock auto."""
    found = []
    for dev in present_hid_ids():
        m = _HID_ID.search(dev)
        if m and m.group(1).upper() == SONY_VID:
            found.append(SONY_PADS.get(m.group(2).upper(), "ps5"))
    style = "ps5" if "ps5" in found else "ps4" if found else "auto"
    log(f"  detect: {'PlayStation pad ' + style if found else 'no PlayStation pad'} -> {style}")
    return style

# lea rax,[rip+X] / mov [rbp-10h],rax / call parse_tooltip_env
SITE = re.compile(rb"\x48\x8d\x05(....)\x48\x89\x45\xf0\xe8(....)", re.DOTALL)
PARSER_SCAN = 0x200
# Rip-relative leas the parser uses to load its comparison strings.
PARSER_LEA = re.compile(rb"[\x48\x4c]\x8d[\x05\x0d\x15\x1d\x25\x2d\x35\x3d](....)", re.DOTALL)


class PatchError(Exception):
    """The exe doesn't look like a version this patch understands."""


def md5(data):
    return hashlib.md5(data).hexdigest()


class _Image:
    """Minimal PE section map for file offset <-> RVA conversion."""

    def __init__(self, data):
        pe = struct.unpack_from("<I", data, 0x3C)[0]
        nsec = struct.unpack_from("<H", data, pe + 6)[0]
        opt = struct.unpack_from("<H", data, pe + 20)[0]
        self.sections = []
        for i in range(nsec):
            s = pe + 24 + opt + i * 40
            vsize, va, rsize, raw = struct.unpack_from("<IIII", data, s + 8)
            self.sections.append((va, max(vsize, rsize), raw, rsize))

    def rva(self, off):
        for va, _vs, raw, rs in self.sections:
            if raw <= off < raw + rs:
                return off - raw + va
        return None

    def off(self, rva):
        for va, vs, raw, rs in self.sections:
            if va <= rva < va + vs and rva - va < rs:
                return rva - va + raw
        return None


def _cstr(data, off, limit=16):
    end = data.find(b"\0", off, off + limit)
    return None if end == -1 else bytes(data[off:end])


def analyse(data):
    """Return (current_value, lea_offset, {value: string_rva}). Raises
    PatchError if the exe isn't recognised."""
    img = _Image(data)
    known = {v.encode() for v in STYLES.values()}
    hits = []
    for m in SITE.finditer(data):
        lea = m.start()
        lea_rva = img.rva(lea)
        if lea_rva is None:
            continue
        s_off = img.off(lea_rva + 7 + struct.unpack("<i", m.group(1))[0])
        cur = _cstr(data, s_off) if s_off is not None else None
        if cur not in known:
            continue
        parser = img.off(lea_rva + 16 + struct.unpack("<i", m.group(2))[0])
        if parser is None:
            continue
        strings = {}
        for pm in PARSER_LEA.finditer(data, parser, parser + PARSER_SCAN):
            t_rva = img.rva(pm.start()) + 7 + struct.unpack("<i", pm.group(1))[0]
            t_off = img.off(t_rva)
            s = _cstr(data, t_off) if t_off is not None else None
            if s in known:
                strings.setdefault(s.decode(), t_rva)
        if set(strings) >= set(STYLES.values()) - {"pc"}:
            strings.setdefault(cur.decode(), lea_rva + 7 + struct.unpack("<i", m.group(1))[0])
            hits.append((cur.decode(), lea, strings))
    if len(hits) != 1:
        raise PatchError(f"environmentTooltips default: expected exactly 1 match, found {len(hits)} "
                         "(a game update probably changed this code)")
    cur, lea, strings = hits[0]
    if "pc" not in strings:
        raise PatchError("couldn't find the stock \"pc\" string - restore the exe first "
                         "(Steam 'Verify integrity of game files')")
    return cur, lea, strings


def _style_of(value):
    return next(k for k, v in STYLES.items() if v == value)


def saved_style():
    try:
        with open(SETTINGS) as f:
            style = json.load(f).get("icons", DEFAULT_STYLE)
        return style if style in CHOICES else DEFAULT_STYLE
    except (OSError, ValueError):
        return DEFAULT_STYLE


def save_style(style):
    os.makedirs(BACKUP_DIR, exist_ok=True)
    with open(SETTINGS, "w") as f:
        json.dump({"icons": style}, f, indent=1)


def status(exe):
    """(style|'unrecognised', detail) - never raises PatchError."""
    data = open(exe, "rb").read()
    try:
        cur, _, _ = analyse(data)
        return _style_of(cur), md5(data)
    except PatchError as e:
        return "unrecognised", str(e)


def _write(exe, data, lea, strings, style, log):
    img = _Image(data)
    lea_rva = img.rva(lea)
    old = bytes(data[lea + 3:lea + 7])
    new = struct.pack("<i", strings[STYLES[style]] - (lea_rva + 7))
    log(f"  {lea + 3:#09x}  {old.hex(' ')}  ->  {new.hex(' ')}")
    data[lea + 3:lea + 7] = new
    with open(exe, "wb") as f:
        f.write(data)
    log(f"  patched - new md5 {md5(data)}")


def sync_atlas(style, log=print):
    """Menu prompt bar / dialog buttons use a texture atlas, not the icon
    style (see atlas.py): PlayStation styles get the PS atlas, others stock."""
    try:
        if style in PS_STYLES:
            return atlas.install(log=log)
        return atlas.restore(log=log)
    except Exception as e:  # the exe patch is still useful without it
        log(f"  atlas FAILED: {e}")
        return f"failed: {e}"


def apply(exe, write=True, log=print, style=None):
    """Set the icon style (default: the saved one). Returns 'applied',
    'already patched' or 'dry run'. Raises PatchError if the exe isn't
    recognised."""
    style = style or saved_style()
    if style == "detect":
        style = detect_style(log)
    data = bytearray(open(exe, "rb").read())
    before = md5(data)
    cur, lea, strings = analyse(data)
    log(f"{exe}\n  md5 {before}  button icons: {_style_of(cur)} (want {style})")
    if not write:
        return "dry run"
    log(f"  atlas: {sync_atlas(style, log)}")
    if STYLES[style] == cur:
        return "already patched"

    backup = os.path.join(BACKUP_DIR, f"rugbyleague1.exe.{before}.bak")
    if cur == "pc" and not os.path.exists(backup):
        os.makedirs(BACKUP_DIR, exist_ok=True)
        shutil.copy2(exe, backup)
        log(f"  backup written: {backup}")
    _write(exe, data, lea, strings, style, log)
    return "applied"


def restore(exe, log=print):
    log(f"  atlas: {sync_atlas('auto', log)}")
    data = bytearray(open(exe, "rb").read())
    try:
        cur, lea, strings = analyse(data)
    except PatchError as e:
        sys.exit(f"not restoring: {e}. Use Steam's 'Verify integrity of game files'.")
    if cur == "pc":
        log(f"{exe} already uses the stock auto icons - nothing to undo")
        return
    log(exe)
    _write(exe, data, lea, strings, "auto", log)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--exe", default=DEFAULT_EXE)
    ap.add_argument("--icons", choices=CHOICES, help=f"icon style to set and remember (saved: {saved_style()}); "
                    "detect = PlayStation icons if a PS pad is plugged in at launch, else stock")
    g = ap.add_mutually_exclusive_group()
    g.add_argument("--apply", action="store_true", help="back up the exe, then patch it")
    g.add_argument("--restore", action="store_true", help="put the stock auto icons back")
    g.add_argument("--status", action="store_true", help="report the current icon style")
    args = ap.parse_args()

    if args.restore:
        restore(args.exe)
        return
    if args.status:
        st, detail = status(args.exe)
        try:
            atlas_st = atlas.state()
        except Exception as e:
            atlas_st = f"unreadable ({e})"
        print(f"{args.exe}\n  button icons: {st}  ({detail})\n  PS textures:  {atlas_st}\n  saved choice: {saved_style()}")
        return
    try:
        result = apply(args.exe, write=args.apply, style=args.icons)
    except PatchError as e:
        sys.exit(f"refusing to patch: {e}")
    if args.apply and args.icons:
        save_style(args.icons)
    print(result if result != "dry run" else "dry run - pass --apply to write (game must be closed)")


if __name__ == "__main__":
    main()
