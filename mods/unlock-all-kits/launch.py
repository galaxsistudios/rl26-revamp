#!/usr/bin/env python3
"""
launch.py - make sure the unlock-all-kits patch is in place, then start the
game. Meant to be set as the game's Steam launch option, so it runs every
time you press Play - after Steam has finished any update:

    "C:\\Users\\mat\\AppData\\Local\\Programs\\Python\\Python314\\pythonw.exe" "D:\\galaxsi\\projects\\games\\modding\\rugby-league-26-modding\\mods\\unlock-all-kits\\launch.py" %command%

Steam replaces %command% with the game's own command line; this script
patches that exe if needed and then runs the command, waiting for the game
to exit so Steam still sees it as running.

- Already patched: launches straight away.
- Stock exe (e.g. just updated): applies the patch, then launches.
- Patch can't be applied (an update changed the kit filter, the exe is in
  use, ...): a Windows dialog says what went wrong and asks whether to
  launch the game anyway, without the hidden kits.

Run with no arguments (e.g. double-click) to check/patch and then start the
game through Steam instead (Steam may then install a pending update after
this check - the launch-option route doesn't have that gap). Every run is
logged to _backup/unlock-all-kits-launch.log.
"""

import ctypes
import datetime
import importlib.util
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import install  # noqa: E402

# Other mods' exe patches, applied after the kit patch (so unlock-all-kits'
# md5-keyed --restore still works once these are restored first).
EXTRA_PATCHES = ["skip-intro-to-main-menu", "controller-button-icons", "ai-interchange-rotation", "hd-nrl-club-logos",
                 "play-now-crowd-settings"]


def load_patch(mod):
    path = os.path.join(os.path.dirname(HERE), mod, "install.py")
    if not os.path.exists(path):
        return None
    spec = importlib.util.spec_from_file_location(f"{mod}_install", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

LOG = os.path.join(install.BACKUP_DIR, "unlock-all-kits-launch.log")  # not under mods/ - build.py would treat it as a bundle file
STEAM_APP_ID = 3468660
TITLE = "Rugby League 26 - unlock-all-kits"
MB_YESNO, MB_ICONWARNING, MB_ICONERROR, IDYES = 0x04, 0x30, 0x10, 6


def log(msg):
    os.makedirs(os.path.dirname(LOG), exist_ok=True)
    with open(LOG, "a", encoding="utf-8") as f:
        f.write(f"{datetime.datetime.now():%Y-%m-%d %H:%M:%S}  {msg}\n")


def ask_launch_anyway(reason):
    text = (f"The hidden-kits patch couldn't be applied:\n\n{reason}\n\n"
            "This usually means a game update changed the code the mod patches, "
            "so the mod needs updating. The game itself is untouched.\n\n"
            "Launch the game anyway (without the extra kits)?")
    return ctypes.windll.user32.MessageBoxW(None, text, TITLE, MB_YESNO | MB_ICONWARNING) == IDYES


def exe_from_command(cmd):
    for arg in cmd:
        if os.path.basename(arg).lower() == "rugbyleague1.exe":
            return arg
    return install.DEFAULT_EXE


def main():
    cmd = sys.argv[1:]
    exe = exe_from_command(cmd)
    log(f"start: exe={exe} command={'(none - via Steam)' if not cmd else ' '.join(cmd)}")

    try:
        result = install.apply(exe, log=log)
        log(f"patch: {result}")
    except Exception as e:  # PatchError, or e.g. the exe being locked
        log(f"patch FAILED: {e}")
        if not ask_launch_anyway(str(e)):
            log("user chose not to launch")
            return 1
        log("user chose to launch anyway")

    for mod in EXTRA_PATCHES:
        try:
            patch = load_patch(mod)
            if patch is None:
                log(f"{mod}: not present, skipped")
                continue
            # sync() = the patch follows a setting (skip-intro's rl26_revamp.ini)
            log(f"{mod}: {getattr(patch, 'sync', patch.apply)(exe, log=log)}")
        except Exception as e:
            log(f"{mod} FAILED: {e}")  # the game still runs fine without it

    try:
        if cmd:
            rc = subprocess.call(cmd)
            log(f"game exited with code {rc}")
            return rc
        os.startfile(f"steam://rungameid/{STEAM_APP_ID}")
        log("launched via Steam")
        return 0
    except Exception as e:
        log(f"launch FAILED: {e}")
        ctypes.windll.user32.MessageBoxW(None, f"Couldn't start the game:\n\n{e}", TITLE, MB_ICONERROR)
        return 1


if __name__ == "__main__":
    sys.exit(main())
