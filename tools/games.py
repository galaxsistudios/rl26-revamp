#!/usr/bin/env python3
"""
games.py - which Big Ant games are installed on this machine, which ones the
person installing the Revamp said they own, and therefore which mods may be
built. The Revamp ships only RL26 content; anything made from another game
(Rugby League Live 4 kits and players, Rugby 25 animations) is built on the
player's own machine from their own copy, and only when they opt in.

Games (Steam app id, install folder under steamapps/common, a file that must exist):
    rl26  Rugby League 26        3468660  "Rugby League"          data/data-0.blobset.pc
    rll4  Rugby League Live 4    556480   "Rugby League Live 4"   data-0.blobset.pc
    r25   Rugby 25               2340870  "Rugby 25"              data/data-0.blobset.pc

A game is *enabled* when it is found AND revamp_install.json (repo root,
written by the installer) turns it on:
    {"games": {"rll4": true, "r25": false}, "paths": {"rll4": "D:/Games/RLL4"}}
RL26 itself is always required. Without revamp_install.json the optional
games are off, so a plain build never pulls in another game's content.
Paths: revamp_install.json "paths", then env RL26_DIR / RLL4_DIR / R25_DIR,
then every Steam library (steamapps/libraryfolders.vdf).

Mods declare what they need in mods/<mod>/mod.json:
    {"requires": ["rll4"], "releaseChannel": "...", "generated": ["players.json", ...]}
"requires" lists games (rl26 is implied) and opt-in FEATURES (e.g.
"rll4-players", switched on by "features" in revamp_install.json); "generated" lists files or folders
the mod's tools write from another game's data - they are built locally and
must never go into a release package. A mod with no mod.json needs only RL26.

Usage:
    python tools/games.py               # status of every game and every mod
"""

import json
import os
import re
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONFIG = os.path.join(REPO, "revamp_install.json")
MODS = os.path.join(REPO, "mods")

GAMES = {
    "rl26": {"name": "Rugby League 26", "appid": 3468660, "folder": "Rugby League", "marker": "data/data-0.blobset.pc"},
    "rll4": {"name": "Rugby League Live 4", "appid": 556480, "folder": "Rugby League Live 4", "marker": "data-0.blobset.pc"},
    "r25": {"name": "Rugby 25", "appid": 2340870, "folder": "Rugby 25", "marker": "data/data-0.blobset.pc"},
}
ENV = {"rl26": "RL26_DIR", "rll4": "RLL4_DIR", "r25": "R25_DIR"}


def load_config():
    if os.path.exists(CONFIG):
        with open(CONFIG, encoding="utf-8") as f:
            return json.load(f)
    return {}


def _steam_libraries():
    roots = []
    try:
        import winreg
        for hive, key in ((winreg.HKEY_CURRENT_USER, r"Software\Valve\Steam"),
                          (winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\WOW6432Node\Valve\Steam")):
            try:
                with winreg.OpenKey(hive, key) as k:
                    for name in ("SteamPath", "InstallPath"):
                        try:
                            roots.append(winreg.QueryValueEx(k, name)[0])
                        except OSError:
                            pass
            except OSError:
                pass
    except ImportError:
        pass
    roots.append(r"C:\Program Files (x86)\Steam")
    libs = []
    for root in roots:
        libs.append(root)
        vdf = os.path.join(root, "steamapps", "libraryfolders.vdf")
        if os.path.exists(vdf):
            text = open(vdf, encoding="utf-8", errors="replace").read()
            libs += [p.replace("\\\\", "\\") for p in re.findall(r'"path"\s+"([^"]+)"', text)]
    seen, out = set(), []
    for lib in libs:
        key = os.path.normcase(os.path.abspath(lib))
        if key not in seen:
            seen.add(key)
            out.append(lib)
    return out


def find(game, config=None):
    """Install folder of a game, or None."""
    info = GAMES[game]
    config = load_config() if config is None else config
    cands = [config.get("paths", {}).get(game), os.environ.get(ENV[game])]
    cands += [os.path.join(lib, "steamapps", "common", info["folder"]) for lib in _steam_libraries()]
    for cand in cands:
        if cand and os.path.exists(os.path.join(cand, *info["marker"].split("/"))):
            return os.path.abspath(cand)
    return None


FALLBACK_RL26 = r"D:\SteamLibrary\steamapps\common\Rugby League"  # this project's dev machine


def rl26_path(*parts):
    """A path inside the RL26 install (found via find("rl26"), else the dev
    machine's folder) - the default for every tool's --blobset / --exe."""
    return os.path.join(find("rl26") or FALLBACK_RL26, *parts)


def toolchain(*parts):
    """A bundled third-party tool (LuaJIT, the LuaJIT decompiler, texconv):
    toolchain/ inside the Revamp package, else the dev machine's sibling
    toolchain/ folder next to the repo."""
    for root in (os.path.join(REPO, "toolchain"), os.path.join(os.path.dirname(REPO), "toolchain")):
        if os.path.exists(os.path.join(root, *parts)):
            return os.path.join(root, *parts)
    return os.path.join(REPO, "toolchain", *parts)


# Opt-in parts of an optional game's content, off unless "features" in
# revamp_install.json switches them on: feature -> the game it needs.
FEATURES = {
    "rll4-players": "rll4",  # the 184 face-scanned RLL4 players (slow head/hair bake)
}


def enabled(game, config=None):
    """True if the game may be used: found, and (for the optional ones) switched
    on. Also answers for a FEATURES name: switched on and its game enabled."""
    config = load_config() if config is None else config
    if game in FEATURES:
        return bool(config.get("features", {}).get(game, False)) and enabled(FEATURES[game], config)
    if game != "rl26" and not config.get("games", {}).get(game, False):
        return False
    return find(game, config) is not None


def require(game):
    """Install folder of an enabled game, or exit with why it can't be used."""
    config = load_config()
    path = find(game, config)
    if path is None:
        raise SystemExit(f"{GAMES[game]['name']} isn't installed where expected (set {ENV[game]} or "
                         f'"paths" in revamp_install.json).')
    if game != "rl26" and not config.get("games", {}).get(game, False):
        raise SystemExit(f'{GAMES[game]["name"]} is installed but not enabled: set "games": {{"{game}": true}} '
                         f"in revamp_install.json (the installer does this when you tick it).")
    return path


def mod_manifest(mod_path):
    path = os.path.join(mod_path, "mod.json")
    if os.path.exists(path):
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    return {}


def mod_enabled(mod_path, config=None):
    """(ok, missing games) for a mod folder."""
    config = load_config() if config is None else config
    missing = [g for g in mod_manifest(mod_path).get("requires", []) if not enabled(g, config)]
    return not missing, missing


def main():
    config = load_config()
    print(f"config: {CONFIG if os.path.exists(CONFIG) else '(none - optional games off)'}")
    for game, info in GAMES.items():
        path = find(game, config)
        on = enabled(game, config)
        print(f"  {game:<5} {info['name']:<22} {'enabled' if on else 'off':<8} {path or 'not found'}")
    print("mods needing another game:")
    for mod in sorted(os.listdir(MODS)):
        mp = os.path.join(MODS, mod)
        if os.path.isdir(mp) and mod_manifest(mp).get("requires"):
            ok, missing = mod_enabled(mp, config)
            print(f"  {mod:<28} requires {', '.join(mod_manifest(mp)['requires']):<10} "
                  f"{'built' if ok else 'SKIPPED (' + ', '.join(missing) + ')'}")


if __name__ == "__main__":
    sys.exit(main())
