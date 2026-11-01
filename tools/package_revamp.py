#!/usr/bin/env python3
"""
package_revamp.py - build the RL26 Revamp release: a folder players install
from, plus the Inno Setup script that wraps it in a Windows installer.

    python tools/package_revamp.py                 # build _dist/RL26-Revamp + installer script
    python tools/package_revamp.py --installer     # ...and compile it (needs Inno Setup 6)
    python tools/package_revamp.py --list          # print what would go in, change nothing

What goes in (_dist/RL26-Revamp/):
  runtime/     a private Python (python.org's embeddable build, same version
               as the one running this) with the install steps' packages in
               Lib/site-packages - players don't install Python
  toolchain/   LuaJIT (compiles the Lua mods), the LuaJIT decompiler
               (turns the player's own script bundle into source for the
               generators) and texconv (field sponsor markings, line numbers)
  tools/, mods/   every tracked or new (not git-ignored) file, minus each
               mod.json's "generated" paths and mods that need another game's
               content baked in, plus the git-ignored mod textures in PREBUILT
  resources/   only the art the install steps read (RESOURCES); custom kits
               as their exported textures (kit.psd stays here)

Never packaged: anything built from Rugby League Live 4 or Rugby 25, the game
working copies (extracted/, decompiled/, manifests/ - the installer rebuilds
them from the player's game), _build/, _backup/, revamp_install.json.
"""

import argparse
import fnmatch
import json
import os
import shutil
import subprocess
import sys
import urllib.request
import zipfile

TOOLS = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(TOOLS)
sys.path.insert(0, TOOLS)
import games  # noqa: E402

DIST = os.path.join(REPO, "_dist")
OUT = os.path.join(DIST, "RL26-Revamp")
CACHE = os.path.join(REPO, "_build", "package_cache")
ISS = os.path.join(TOOLS, "installer", "rl26_revamp.iss")

PY_VERSION = "{0}.{1}.{2}".format(*sys.version_info)
PY_TAG = "{0}{1}".format(*sys.version_info)
PY_EMBED = f"https://www.python.org/ftp/python/{PY_VERSION}/python-{PY_VERSION}-embed-amd64.zip"
TEXCONV = "https://github.com/microsoft/DirectXTex/releases/latest/download/texconv.exe"
TEXCONV_LICENSE = "https://raw.githubusercontent.com/microsoft/DirectXTex/main/LICENSE"

# The third-party packages the install steps import (traced from every step's
# script), pinned to what the Revamp was built and tested with.
PACKAGES = ["pillow", "numpy", "scipy", "numba", "zstandard", "texture2ddecoder", "resvg-py", "potracer"]

# Art the install steps read from resources/ (repo-relative globs).
RESOURCES = [
    "resources/rl26-revamp/*.png", "resources/rl26-revamp/*.svg",   # title screen, About page
    "resources/smoke.png",
    "resources/new-team-logos/classic-nrl-logos/**", "resources/scorebug_img/**",  # classic club emblems
    "resources/field-markings/**",                                   # sponsor markings
    "resources/las-vegas-stadium/**",                                # las-vegas-stadium (Allegiant logo)
    "resources/field-numbers/fieldmarkings_numbers_col.png",         # field-numbers-font
    "resources/old-jerseys/*.png",                                   # legacy kits (community jerseys, lossless PNG; * spans subfolders)
    "resources/custom-kits/*/top.png", "resources/custom-kits/*/shorts.png",  # kits painted on the jersey
    "resources/custom-kits/*/socks.png",                             # templates (kit.psd: custom_kit_textures)
    "resources/ref-jerseys/2026/*/top.png",                          # nrl-referee-2026-kits
    "resources/balls/nsw_cup/**", "resources/balls/nrlw_ball/**",    # nrl-special-balls logos
    "resources/balls/ashes/**",                                      # (+ Josefin Sans, OFL)
    "resources/fangear/*/tee_*.png", "resources/fangear/*/polo_*.png",  # crowd-fangear design sheets
    "resources/fangear/*/scarf_*.png", "resources/fangear/fangear.json",
    "resources/fangear/templates/*",
    "resources/flags/*/*.png",                                       # crowd-flags faces (+ fangear's club list)
    "resources/nrl-site-logos/**", "resources/gallery-of-league-logos/**",  # hd-nrl-club-logos sources
    "Maison-Neue-Extended-Bold.ttf",                                 # title screen lettering
]

# Finished mod textures that are git-ignored (*.dds) and that no install step
# rebuilds: their sources are game-derived or need the dev tree.
PREBUILT = [
    "mods/goalpost-pads/textures/*.dds",
    "mods/nrl-broadcast-scoreboard/textures/*.dds",                  # hud_score crests
    "mods/rl26-revamp-branding/textures/*.dds",                      # screen-wipe logo
]

TOOLCHAIN = [
    ("luajit/bin", "luajit/bin"),
    ("luajit/src/COPYRIGHT", "luajit/COPYRIGHT"),
    ("decompiler/luajit-decompiler-v2.exe", "decompiler/luajit-decompiler-v2.exe"),
]

SKIP_NAMES = {"__pycache__", ".pytest_cache"}


def tracked_files(*roots):
    """Files git would commit under roots: tracked plus new, never ignored."""
    out = subprocess.run(["git", "ls-files", "--cached", "--others", "--exclude-standard", "-z", "--", *roots],
                         cwd=REPO, capture_output=True, check=True).stdout.decode("utf-8")
    return sorted(p for p in out.split("\0") if p and os.path.isfile(os.path.join(REPO, p)))


def mod_files():
    """(files, notes, blocks): mods/ + tools/ minus each mod.json's
    "generated" paths; blocks = "generatedBlocks" files, shipped with the
    machine-specific table between their GENERATED markers emptied."""
    files, skipped, blocks = [], [], set()
    manifests = {}
    for rel in tracked_files("mods", "tools"):
        parts = rel.split("/")
        if SKIP_NAMES & set(parts):
            continue
        if parts[0] == "mods" and len(parts) > 2:
            name = parts[1]
            if name not in manifests:
                manifests[name] = games.mod_manifest(os.path.join(REPO, "mods", name))
            m = manifests[name]
            inner = "/".join(parts[2:])
            if any(inner == g or inner.startswith(g.rstrip("/") + "/") for g in m.get("generated", [])):
                continue
            if inner in m.get("generatedBlocks", []):
                blocks.add(rel)
        files.append(rel)
    for name, m in sorted(manifests.items()):
        if m.get("generated"):
            skipped.append(f"{name}: left out {m['generated']} (rebuilt by the installer)")
        if m.get("generatedBlocks"):
            skipped.append(f"{name}: emptied the GENERATED table in {m['generatedBlocks']}")
    return files, skipped, blocks


def strip_generated(path):
    """Empty every '-- BEGIN GENERATED' ... '-- END GENERATED' block in place."""
    lines = open(path, encoding="utf-8").read().split("\n")
    out, inside = [], False
    for line in lines:
        if line.lstrip().startswith("-- END GENERATED"):
            inside = False
        if not inside:
            out.append(line)
        if line.lstrip().startswith("-- BEGIN GENERATED"):
            inside = True
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(out))


def resource_files():
    out = []
    for pattern in RESOURCES + PREBUILT:
        base = pattern.split("*")[0].rstrip("/")
        root = os.path.join(REPO, base)
        if os.path.isfile(root):
            out.append(base)
            continue
        for dirpath, _dirs, names in os.walk(root):
            if SKIP_NAMES & set(dirpath.replace("\\", "/").split("/")):
                continue
            for n in names:
                rel = os.path.relpath(os.path.join(dirpath, n), REPO).replace("\\", "/")
                if fnmatch.fnmatch(rel, pattern.replace("/**", "/*")) or pattern.endswith("/**"):
                    out.append(rel)
    return sorted(set(out))


def custom_kit_textures(dest):
    """Custom kits ship as the top/shorts/socks.png the install bakes, never
    kit.psd. Those PNGs are the PSD's export unless the PSD was saved after
    the last kit_studio build; then they're exported from it again here (the
    PSD is the source of truth, as in kit_studio build)."""
    import kit_studio as ks
    redone = []
    for name in sorted(os.listdir(ks.CUSTOM)):
        psd_path = os.path.join(ks.CUSTOM, name, "kit.psd")
        if not os.path.exists(psd_path):
            continue
        kit = ks.Kit(name)
        man = ks.load_manifest(kit)
        if man and ks.file_sha1(psd_path) == man.get("psd_sha1"):
            continue
        for part, im in ks.export_from_psd(kit, ks.open_psd(psd_path)).items():
            im.save(os.path.join(dest, "resources", "custom-kits", name, f"{part}.png"))
        redone.append(name)
    if redone:
        print(f"  custom kits exported from kit.psd (saved since their last build): {', '.join(redone)}")


def fetch(url, name):
    os.makedirs(CACHE, exist_ok=True)
    path = os.path.join(CACHE, name)
    if not os.path.exists(path):
        print(f"  downloading {url}")
        with urllib.request.urlopen(url) as r, open(path + ".part", "wb") as f:
            shutil.copyfileobj(r, f)
        os.replace(path + ".part", path)
    return path


def build_runtime(dest):
    """python.org's embeddable Python + PACKAGES. Its ._pth file is removed:
    with it Python ignores the script's own folder, which every mod tool
    relies on to import its neighbours. install_revamp.py clears PYTHONHOME/
    PYTHONPATH and the installer runs it with -E -s, so a system Python's
    settings never leak in."""
    with zipfile.ZipFile(fetch(PY_EMBED, os.path.basename(PY_EMBED))) as z:
        z.extractall(dest)
    for n in os.listdir(dest):
        if n.endswith("._pth"):
            os.remove(os.path.join(dest, n))
    site = os.path.join(dest, "Lib", "site-packages")
    pins = []
    import importlib.metadata as md
    for p in PACKAGES:
        try:
            pins.append(f"{p}=={md.version(p)}")
        except md.PackageNotFoundError:
            pins.append(p)
    subprocess.run([sys.executable, "-m", "pip", "install", "--quiet", "--disable-pip-version-check",
                    "--target", site, "--platform", "win_amd64", "--python-version", PY_TAG,
                    "--implementation", "cp", "--only-binary=:all:", *pins], check=True)
    return pins


def copy(rel_src, dest_root, rel_dest=None):
    src = os.path.join(REPO, rel_src)
    dst = os.path.join(dest_root, rel_dest or rel_src)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    shutil.copy2(src, dst)


def build(args):
    files, skipped, blocks = mod_files()
    res = resource_files()
    size = sum(os.path.getsize(os.path.join(REPO, f)) for f in files + res)
    print(f"tools + mods: {len(files)} files; resources: {len(res)} files; {size / 2**20:.0f} MB before the runtime")
    for s in skipped:
        print(f"  {s}")
    if args.list:
        return
    if os.path.isdir(OUT):
        shutil.rmtree(OUT)
    os.makedirs(OUT)
    for rel in files + res:
        copy(rel, OUT)
    for rel in blocks:
        strip_generated(os.path.join(OUT, rel))
    custom_kit_textures(OUT)
    tc = os.path.join(OUT, "toolchain")
    for src, dst in TOOLCHAIN:
        path = games.toolchain(*src.split("/"))
        if os.path.isdir(path):
            shutil.copytree(path, os.path.join(tc, dst))
        else:
            os.makedirs(os.path.dirname(os.path.join(tc, dst)), exist_ok=True)
            shutil.copy2(path, os.path.join(tc, dst))
    os.makedirs(os.path.join(tc, "texconv"))
    shutil.copy2(fetch(TEXCONV, "texconv.exe"), os.path.join(tc, "texconv", "texconv.exe"))
    shutil.copy2(fetch(TEXCONV_LICENSE, "DirectXTex-LICENSE.txt"), os.path.join(tc, "texconv", "LICENSE.txt"))
    print("building the runtime...")
    pins = build_runtime(os.path.join(OUT, "runtime"))
    with open(os.path.join(OUT, "package.json"), "w") as f:
        json.dump({"python": PY_VERSION, "packages": pins, "files": len(files) + len(res)}, f, indent=1)
    check = subprocess.run([os.path.join(OUT, "runtime", "python.exe"), "-E", "-s",
                            os.path.join(OUT, "tools", "install_revamp.py"), "--list"],
                           cwd=OUT, capture_output=True, text=True)
    print(check.stdout.strip() if check.returncode == 0 else check.stderr)
    if check.returncode != 0:
        raise SystemExit("the packaged runtime can't run the installer")
    total = sum(os.path.getsize(os.path.join(d, n)) for d, _, ns in os.walk(OUT) for n in ns)
    print(f"package: {OUT} ({total / 2**20:.0f} MB)")
    if args.installer:
        iscc = shutil.which("ISCC") or next((p for p in (
            os.path.expandvars(r"%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"),
            os.path.expandvars(r"%LocalAppData%\Programs\Inno Setup 6\ISCC.exe")) if os.path.exists(p)), None)
        if not iscc:
            raise SystemExit("Inno Setup 6 isn't installed (https://jrsoftware.org/isdl.php) - "
                             f"the package folder is ready; compile {os.path.relpath(ISS, REPO)} later")
        subprocess.run([iscc, f"/DSourceDir={OUT}", f"/DOutputDir={DIST}", ISS], check=True)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--list", action="store_true", help="print what would be packaged")
    ap.add_argument("--installer", action="store_true", help="also compile the Inno Setup installer")
    build(ap.parse_args())


if __name__ == "__main__":
    main()
