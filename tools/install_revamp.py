#!/usr/bin/env python3
"""
install_revamp.py - install the whole RL26 Revamp on this machine, in order.
This is what the installer runs. It builds everything from the player's own
games: RL26 always, Rugby League Live 4 and Rugby 25 only when asked for (and
installed), so the Revamp package itself never carries another game's content.

    python tools/install_revamp.py                      # print the plan (nothing changes)
    python tools/install_revamp.py --rll4 --r25 --confirm
    python tools/install_revamp.py --confirm --from scripts   # resume at a step
    python tools/install_revamp.py --list               # step ids
    python tools/install_revamp.py --uninstall [--confirm]   # back to stock (see uninstall())
    python tools/install_revamp.py --list-saves | --backup-saves | --restore-saves latest [--confirm]

Every --confirm install or uninstall first copies Saved Games/Rugby League 26
to _backup/saves/<time>_<reason> (newest 10 kept).

Options (saved to revamp_install.json, which tools/games.py reads):
    --rll4 / --no-rll4    Rugby League Live 4 kits
    --rll4-players / --no-rll4-players
                          also the 184 face-scanned RLL4 players (needs --rll4; off by
                          default - the head/hair bake is the slowest part of the install)
    --r25  / --no-r25     the Rugby 25 Expansion (animations, cutscenes)
    --controller ICONS    detect | auto | xbox | ps4 | ps5 | switch  (button icons)
    --no-skip-intro       keep the boot splash screens
    --texconv PATH        texconv.exe (DirectXTex) for the field sponsor markings and line numbers
                          (default: toolchain/texconv/texconv.exe; without one that step is skipped)
    --rl26-dir / --rll4-dir / --r25-dir PATH   game folders, when Steam can't find them
Unset options keep their saved value (both games default to off).

The game must be closed. Each step runs the mods' own tools (see the step
table below); the log is _build/install_revamp.log and the completed steps
are recorded in _build/install_revamp_state.json, so a failed run can be
resumed with --from <step>. The stock bundles are extracted once, first, from
the pack.py backups when a bundle was already modded, so every data bundle is
rebuilt from stock with all mods' data.

The step order is the reapply procedure: appended assets -> the shared
texture tables (rll4-legacy-kits rebuilds global.texsrc from stock, the
others append) -> kit slots -> data bundles -> crowd (it reads the installed
clubs) -> script bundle -> texture replacements -> exe patches.
"""

import argparse
import datetime
import hashlib
import json
import os
import shutil
import subprocess
import sys

TOOLS = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(TOOLS)
sys.path.insert(0, TOOLS)
import games  # noqa: E402

PY = sys.executable
BUILD = os.path.join(REPO, "_build")
STOCK = os.path.join(BUILD, "stock")
LOG = os.path.join(BUILD, "install_revamp.log")
STATE = os.path.join(BUILD, "install_revamp_state.json")
DECOMPILED = os.path.join(REPO, "decompiled")
# M3MP bundles rebuilt from stock, by entries.py name (their index moves with updates)
BUNDLES = ["gamedata", "licenseddata", "scripts", "fonts", "xamls"]


def idx(name):
    import entries
    return entries.index_of(name)


def mod(*parts):
    return os.path.join(REPO, "mods", *parts)


def tool(name):
    return os.path.join(TOOLS, name)


def stock_dir(name):
    return os.path.join(STOCK, name)


# --------------------------------------------------------------------------
# steps: (id, title, condition(opts) -> bool, callable(opts) -> [argv lists] | None)

def bundle(name):
    """Restore (if installed) and rebuild an M3MP bundle from its stock copy."""
    def cmds(_opts):
        out = []
        if os.path.exists(os.path.join(REPO, "_backup", f"entry_{idx(name)}.backup.json")):
            out.append([PY, tool("pack.py"), "restore", "--entry", name])
        out.append([PY, tool("build.py"), "full", "--list", os.path.join(REPO, "manifests", f"{name}.xml"),
                    "--extracted", stock_dir(name), "--out", os.path.join(BUILD, f"{name}.m3mp"), "--confirm"])
        return out
    return cmds


def always(_opts):
    return True


def dev(_opts):
    return os.path.isdir(os.path.join(REPO, ".git"))


def rll4(opts):
    return opts["games"].get("rll4", False)


def rll4_players(opts):
    return rll4(opts) and opts["features"].get("rll4-players", False)


def r25(opts):
    return opts["games"].get("r25", False)


def _asset_cmds(_opts):
    """Appended files the Lua mods load by path. A missing one aborts the game
    natively (gf_smoke.texture crashed the match loading screen, 1.0.5933
    reinstall), so every one of them must be installed here."""
    res = os.path.join(REPO, "resources")
    icons = tool("club_icons.py")
    out = [[PY, icons, "add", "--icon", icon, "--image", os.path.join(res, "new-team-logos", src),
            "--hud-score-image", os.path.join(res, "scorebug_img", f"{icon}.png"), "--replace", "--confirm"]
           for icon, src in (("nrl_bears", "nrl-bears.svg"), ("nrl_chiefs", "nrl-chiefs.avif"))]
    # gf-intro-effects (see its README for the settings)
    out.append([PY, tool("add_texture.py"), "add", "--path", "ui/textures/mods/gf_smoke.texture",
                "--image", os.path.join(res, "smoke.png"), "--screen", "--size", "1024", "--black", "80",
                "--white", "220", "--gamma", "1.2", "--replace", "--confirm"])
    bank = tool("add_sound_bank.py")
    out.append([PY, bank, "add", "--name", "siren_nrl", "--audio", os.path.join(res, "new-sfx", "siren.ogg"),
                "--fade-in-ms", "0", "--loudness", "-14.3", "--volume-db", "0", "--replace", "--confirm"])  # nrl-siren
    for folder, prefix, extra in (("try-songs", "try_song_", ["--fade-in-ms", "250"]),  # team-try-songs
                                  ("intro-songs", "intro_song_", [])):  # gf-intro-effects
        d = os.path.join(res, folder)
        for name in sorted(os.listdir(d)) if os.path.isdir(d) else []:
            if name.lower().endswith(".ogg"):
                out.append([PY, bank, "add", "--name", prefix + os.path.splitext(name)[0],
                            "--audio", os.path.join(d, name)] + extra + ["--replace", "--confirm"])
    return out


def _steps():
    kits = mod("rll4-legacy-kits", "build_kits.py")
    players = mod("rll4-legacy-players", "build.py")
    polos = mod("team-coaches", "build_polos.py")
    refkits = mod("nrl-referee-2026-kits", "install.py")
    headgear = mod("headgear-patterns", "install.py")
    crowd = mod("crowd-team-kits", "bake_crowd_jerseys.py")
    flags = mod("crowd-flags", "build_flags.py")
    fangear = mod("crowd-fangear", "fangear.py")
    return [
        ("snapshot", "snapshot the game install (dev checkouts only: hard links need the game's drive)", dev,
         lambda o: [[PY, tool("snapshot.py"), "take", "--label", "pre_revamp"]]),
        ("stock", "extract stock bundles, manifests and scripts from your game", always, None),  # built in
        ("icons", "classic club emblems", always,
         lambda o: [[PY, mod("new-club-icons", "classic_logos.py"), "add", "--replace", "--confirm"]]),
        ("assets", "new club emblems, GF smoke texture, siren and team song banks", always, _asset_cmds),
        ("kits-rll4", "find Rugby League Live 4's kits", rll4,
         lambda o: [[PY, kits, "add-rll4"]]),
        ("kits", "bake and add the legacy kits", always,
         lambda o: [[PY, kits, "bake"], [PY, kits, "install", "--replace", "--confirm"]]),
        ("players", "Rugby League Live 4 players, faces and hair", rll4_players,
         lambda o: [[PY, players, c] for c in ("select", "prepare", "heads", "hair", "generate")]
         + [[PY, players, "install", "--replace", "--confirm"]]),
        ("coaches", "coach polos and Wayne Bennett", always,
         lambda o: [[PY, polos, "bake"], [PY, polos, "install", "--replace", "--confirm"],
                    [PY, mod("wayne-bennett-coach", "install.py"), "build"],
                    [PY, mod("wayne-bennett-coach", "install.py"), "install", "--confirm"]]),
        ("ref-kits", "2026 NRL referee jerseys", always,
         lambda o: [[PY, refkits, "install", "--replace", "--confirm"]]),
        ("headgear", "headgear patterns (Jahrome Hughes lightning)", always,
         lambda o: [[PY, headgear, "install", "--replace", "--confirm"]]),
        ("branding", "Revamp title screen and About page art", always,
         lambda o: [[PY, mod("rl26-revamp-branding", "title_screen.py"), "--add-art", "--confirm"],
                    [PY, mod("about-rl26-revamped", "make_logos.py"), "install", "--confirm"]]),
        ("r25", "Rugby 25 Expansion (animations, cutscenes)", r25,
         lambda o: [[PY, tool("r25_import.py"), "setup"], [PY, tool("r25_import.py"), "import", "--confirm"],
                    [PY, tool("r25_import.py"), "motionset", "--confirm"],
                    [PY, tool("r25_import.py"), "tackleset", "--confirm"],
                    [PY, tool("r25_import.py"), "gen-mod"]]),
        ("texsrc", "register character textures (global.texsrc)", always,
         lambda o: [[PY, kits, "texsrc", "--confirm"], [PY, polos, "texsrc", "--confirm"],
                    [PY, refkits, "texsrc", "--confirm"], [PY, headgear, "texsrc", "--confirm"]]
         + ([[PY, players, "texsrc", "--confirm"]] if rll4_players(o) else [])),
        ("kit-slots", "club kit slots for the kits that were built", always,
         lambda o: [[PY, kits, "generate", "--clubs",
                     os.path.join(stock_dir("licenseddata"), "defaultdata", "defaultdata_clubs")]]),
        ("data", "leagues/NPCs, clubs/players, Noesis UI and fonts", always,
         lambda o: bundle("gamedata")(o) + bundle("licenseddata")(o) + bundle("xamls")(o) + bundle("fonts")(o)),
        ("crowd", "crowd jerseys, flags, fangear and kit lists", always,
         lambda o: [[PY, crowd, "bake", "--confirm"], [PY, flags, "model", "--confirm"],
                    [PY, flags, "variants", "--confirm"], [PY, fangear, "install", "--confirm"],
                    [PY, crowd, "register", "--confirm"],
                    [PY, flags, "bank", "--confirm"], [PY, mod("crowd-team-kits", "generate.py")]]),
        # before scripts: `lua` writes the club -> board table from the installed textures
        ("led-boards", "home-team LED sponsor boards", always,
         lambda o: ([[PY, mod("nrl-led-boards", "install.py"), "build", "--texconv", o["texconv"]],
                     [PY, mod("nrl-led-boards", "install.py"), "install", "--replace", "--confirm"]]
                    if o.get("texconv") else [])
         + [[PY, mod("nrl-led-boards", "install.py"), "lua"]]),
        ("scripts", "script bundle (all Lua mods)", always, bundle("scripts")),
        ("plays", "attack play coverage and kick-off receive layout (compiled play sets)", always,
         lambda o: [[PY, mod("attack-play-coverage", "install.py"), "install", "--confirm"]]),
        ("strings", "corrected stadium names (UI string tables)", always,
         lambda o: [[PY, mod("stadium-name-fixes", "install.py"), "install", "--confirm"]]),
        ("textures", "texture replacements, field sponsor markings, line numbers and special balls", always,
         # realistic-pitch-grass's and menu-grass-floor's DDS are game-derived (not in git): build them before apply
         lambda o: ([[PY, mod("realistic-pitch-grass", "make_grass.py"), "--texconv", o["texconv"]],
                     [PY, mod("menu-grass-floor", "make_floor.py"), "--texconv", o["texconv"]]]
                    if o.get("texconv") else [])
         # hd-nrl-club-logos' DDS (1.7 GB, not in git) are rendered from resources/nrl-site-logos +
         # gallery-of-league-logos and the stock emblems
         + [[PY, mod("hd-nrl-club-logos", "generate.py"), "--all-icons"],
            [PY, tool("texture_mods.py"), "apply", "--confirm"],
            # competition logos preloaded for the team loading screen's background logo
            [PY, mod("loading-screen-secondary-arrows", "install.py"), "install", "--confirm"]]
         + ([[PY, mod("nrl-field-sponsor-markings", "fieldmarkings.py"), "build", "--texconv", o["texconv"]],
             [PY, mod("nrl-field-sponsor-markings", "fieldmarkings.py"), "install", "--confirm"],
             [PY, mod("field-numbers-font", "install.py"), "install", "--confirm", "--texconv", o["texconv"]],
             [PY, mod("las-vegas-stadium", "install.py"), "install", "--confirm", "--texconv", o["texconv"]],
             [PY, mod("nrl-special-balls", "install.py"), "build", "--texconv", o["texconv"]],
             [PY, mod("nrl-special-balls", "install.py"), "install", "--replace", "--confirm"]]
            if o.get("texconv") else [])),
        ("exe", "game exe patches", always,
         lambda o: [[PY, mod("unlock-all-kits", "install.py"), "--apply"],
                    [PY, mod("ai-interchange-rotation", "install.py"), "--apply"],
                    [PY, mod("play-now-crowd-settings", "install.py"), "--apply"],
                    [PY, mod("hd-nrl-club-logos", "install.py"), "--apply"],
                    [PY, mod("controller-button-icons", "install.py"), "--icons", o.get("controller", "detect"), "--apply"]]
         + ([[PY, mod("skip-intro-to-main-menu", "install.py"), "--apply"]] if o.get("skip_intro", True) else [])),
    ]


# --------------------------------------------------------------------------
# helpers

def log(text):
    os.makedirs(BUILD, exist_ok=True)
    line = f"{datetime.datetime.now():%H:%M:%S} {text}"
    print(line, flush=True)
    with open(LOG, "a", encoding="utf-8") as f:
        f.write(line + "\n")


def game_running():
    try:
        out = subprocess.run(["tasklist", "/FI", "IMAGENAME eq rugbyleague1.exe"], capture_output=True, text=True).stdout
        return "rugbyleague1.exe" in out
    except OSError:
        return False


def extract_stock():
    """Stock copies of every rebuilt bundle, from the pack.py backup when the
    live entry is already modded (it is stock otherwise)."""
    import classify_entries as ce
    import extract_m3mp
    import gen_m3mp_list
    import pack
    ce.load_index(pack.BLOBSET_PATH)
    digests = {}
    for name in BUNDLES:
        entry = idx(name)
        out = stock_dir(name)
        meta = pack.backup_meta_path(entry)
        if os.path.exists(meta):
            m = json.load(open(meta))
            raw = open(m["blob_backup"], "rb").read()
            if m["main_compressed_size"] != m["main_uncompressed_size"]:
                raw = ce.decode_outer_zstd_frames(raw)
            source = "backup"
        else:
            raw = ce.read_blob_full(pack.BLOBSET_PATH, entry)[0]
            source = "live (stock)"
        records, files = extract_m3mp.decode_m3mp(raw)
        for path, data in files.items():
            dest = os.path.join(out, *path.replace("\\", "/").lstrip("/").split("/"))
            os.makedirs(os.path.dirname(dest), exist_ok=True)
            with open(dest, "wb") as f:
                f.write(data)
        log(f"  stock {name} (entry {entry}): {len(files)} files from {source} -> {os.path.relpath(out, REPO)}")
        digests[name] = hashlib.md5(raw).hexdigest()
        # always rewritten: an update can add files to a bundle (1.0.5933 added one to scripts)
        manifest = os.path.join(REPO, "manifests", f"{name}.xml")
        os.makedirs(os.path.dirname(manifest), exist_ok=True)
        _d, folder, file_hash, _p = ce.read_blob_full(pack.BLOBSET_PATH, entry) if source != "backup" else \
            (None, m["folder"], m["file_hash"], None)
        xml = gen_m3mp_list.build_manifest_xml(entry, records, int(folder + file_hash, 16))
        if not os.path.exists(manifest) or open(manifest, "rb").read() != xml:
            with open(manifest, "wb") as f:
                f.write(xml)
            log(f"  wrote {os.path.relpath(manifest, REPO)}")
    prepare_work_files(digests)


def prepare_work_files(digests):
    """The game-derived working copies the mods' tools read, rebuilt from this
    player's own game (they never ship): extracted/ (stock bundle files) and
    decompiled/ (the script bundle as Lua source). Redone whenever a bundle
    changed since the last install (a game update); a dev checkout that has
    them already just records the digests the first time."""
    marker = os.path.join(BUILD, "work_files.json")
    done = json.load(open(marker)) if os.path.exists(marker) else {}
    dev_tree = not done and os.path.isdir(os.path.join(REPO, ".git"))  # extracted/ + decompiled/ kept by hand
    for key in BUNDLES:
        have = os.path.isdir(os.path.join(REPO, "extracted")) and (key != "scripts" or os.path.isdir(DECOMPILED))
        if done.get(key) == digests[key] or (dev_tree and have):
            done[key] = digests[key]
            continue
        n = _copy_tree(stock_dir(key), os.path.join(REPO, "extracted"))
        log(f"  extracted/: {n} files from {key}")
        if key == "scripts":
            decompile_scripts()
        done[key] = digests[key]
        with open(marker, "w") as f:
            json.dump(done, f, indent=1)
    with open(marker, "w") as f:
        json.dump(done, f, indent=1)


def _copy_tree(src, dst):
    n = 0
    for root, _dirs, names in os.walk(src):
        out = os.path.join(dst, os.path.relpath(root, src))
        os.makedirs(out, exist_ok=True)
        for name in names:
            shutil.copyfile(os.path.join(root, name), os.path.join(out, name))
            n += 1
    return n


def decompile_scripts():
    """decompiled/ = the stock script bundle with every LuaJIT bytecode file
    turned back into source by toolchain/decompiler (byte-identical to the
    dev tree's decompiled/), other files copied as they are. The decompiler
    isn't long-path aware, so it runs in a short temp folder."""
    import tempfile
    exe = games.toolchain("decompiler", "luajit-decompiler-v2.exe")
    if not os.path.exists(exe):
        raise SystemExit(f"the LuaJIT decompiler is missing ({exe})")
    tmp = tempfile.mkdtemp(prefix="rv")
    try:
        src = os.path.join(tmp, "i")
        _copy_tree(stock_dir("scripts"), src)
        os.makedirs(os.path.join(tmp, "o"))  # the decompiler won't create it
        r = subprocess.run([exe, src, "-s", "-f", "-o", os.path.join(tmp, "o")], stdin=subprocess.DEVNULL,
                           capture_output=True, text=True, errors="replace", timeout=1800)
        if r.returncode != 0:
            log(f"  decompiler exit {r.returncode}: {(r.stdout + r.stderr).strip()[-500:]}")
        lua = _copy_tree(os.path.join(tmp, "o"), DECOMPILED) if os.path.isdir(os.path.join(tmp, "o")) else 0
        other = failed = 0
        for root, _dirs, names in os.walk(stock_dir("scripts")):
            for name in names:
                path = os.path.join(root, name)
                rel = os.path.relpath(path, stock_dir("scripts"))
                with open(path, "rb") as f:
                    bytecode = f.read(3) == b"\x1bLJ"
                if bytecode:
                    failed += not os.path.exists(os.path.join(tmp, "o", rel))
                    continue
                os.makedirs(os.path.dirname(os.path.join(DECOMPILED, rel)), exist_ok=True)
                shutil.copyfile(path, os.path.join(DECOMPILED, rel))
                other += 1
        log(f"  decompiled/: {lua} scripts decompiled, {other} copied, {failed} failed "
            "(uniformsetup_state.lua always does; nothing in the install reads it)")
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


SAVES = os.path.join(os.path.expanduser("~"), "Saved Games", "Rugby League 26")
SAVE_BACKUPS = os.path.join(REPO, "_backup", "saves")
KEEP_SAVE_BACKUPS = 10


def save_backups():
    return sorted(d for d in os.listdir(SAVE_BACKUPS) if os.path.isdir(os.path.join(SAVE_BACKUPS, d))) \
        if os.path.isdir(SAVE_BACKUPS) else []


def backup_saves(reason):
    """Copy the whole save folder (careers, competitions, profile, settings,
    custom textures) to _backup/saves/<time>_<reason>, keeping the newest
    KEEP_SAVE_BACKUPS. Runs before anything is written to the game."""
    import shutil
    if not os.path.isdir(SAVES):
        log(f"  no save folder at {SAVES} - nothing to back up")
        return None
    dest = os.path.join(SAVE_BACKUPS, f"{datetime.datetime.now():%Y%m%d-%H%M%S}_{reason}")
    shutil.copytree(SAVES, dest)
    n = sum(len(fs) for _, _, fs in os.walk(dest))
    log(f"  saves backed up: {n} files -> {os.path.relpath(dest, REPO)}")
    for old in save_backups()[:-KEEP_SAVE_BACKUPS]:
        shutil.rmtree(os.path.join(SAVE_BACKUPS, old))
        log(f"  removed old save backup {old}")
    return dest


def restore_saves(name, confirm):
    """Put a save backup back ('latest' or a folder name from --list-saves).
    The current saves are backed up first, so a restore can be undone too."""
    import shutil
    backups = save_backups()
    if not backups:
        raise SystemExit(f"no save backups in {os.path.relpath(SAVE_BACKUPS, REPO)}")
    pick = backups[-1] if name == "latest" else name
    if pick not in backups:
        raise SystemExit(f"no save backup {pick!r}; see --list-saves")
    print(f"restore saves from {pick} -> {SAVES}")
    if not confirm:
        print("dry run - pass --confirm to restore (close the game first; Steam Cloud may sync the old saves back"
              " unless it's off for Rugby League 26)")
        return
    if game_running():
        raise SystemExit("Rugby League 26 is running - close it first.")
    backup_saves("before_restore")
    if os.path.isdir(SAVES):
        shutil.rmtree(SAVES)
    shutil.copytree(os.path.join(SAVE_BACKUPS, pick), SAVES)
    log(f"saves restored from {pick}")


EXE_PATCHERS = ["skip-intro-to-main-menu", "controller-button-icons", "ai-interchange-rotation", "hd-nrl-club-logos",
                "play-now-crowd-settings", "unlock-all-kits"]


def uninstall(confirm):
    """Put the game back to stock, in the only order that works:
      1. exe patches: each tool keys its saved original by the exe's md5 when it
         patched, so they only undo in reverse application order - keep cycling
         through them until a pass changes nothing;
      2. every pack.py backup (replaced entries: bundles, texture tables, crowd
         animation, texture swaps, motion sets ...), newest install first, since
         a backup holds the whole index as it was at that install;
      3. every appended entry (add_entries.py remove-all, which refuses while a
         backup newer than the appended entries is still installed)."""
    import add_entries
    import pack
    exe = games.rl26_path("rugbyleague1.exe")
    metas = sorted((os.path.join(pack.BACKUP_DIR, f) for f in os.listdir(pack.BACKUP_DIR)
                    if f.startswith("entry_") and f.endswith(".backup.json")), key=os.path.getmtime, reverse=True) \
        if os.path.isdir(pack.BACKUP_DIR) else []
    reg = add_entries.load_registry()
    print(f"exe patch tools: {', '.join(EXE_PATCHERS)}")
    print(f"replaced entries to restore: {len(metas)}")
    print(f"appended entries to remove: {len(reg['entries']) if reg else 0}")
    if not confirm:
        print("dry run - pass --confirm to uninstall (close the game first)")
        return
    if game_running():
        raise SystemExit("Rugby League 26 is running - close it first.")
    log("uninstall started")
    backup_saves("pre_uninstall")
    for _ in range(len(EXE_PATCHERS) + 1):
        before = open(exe, "rb").read()
        for m in EXE_PATCHERS:
            r = subprocess.run([PY, mod(m, "install.py"), "--restore"], cwd=REPO, capture_output=True, text=True)
            msg = (r.stdout + r.stderr).strip().splitlines()
            log(f"  {m} --restore: {msg[-1] if msg else r.returncode}")
        if open(exe, "rb").read() == before:
            break
    for meta in metas:
        if not os.path.exists(meta):  # already put back by a tool above (controller-button-icons atlases)
            continue
        entry = int(os.path.basename(meta).split("_")[1].split(".")[0])
        pack.do_restore(pack.BLOBSET_PATH, entry)
        log(f"  restored entry {entry}")
    if add_entries.load_registry():
        r = subprocess.run([PY, tool("add_entries.py"), "remove-all", "--confirm"], cwd=REPO, capture_output=True, text=True)
        log("  " + (r.stdout + r.stderr).strip().splitlines()[-1])
        if r.returncode != 0:
            raise SystemExit(f"remove-all failed - see {os.path.relpath(LOG, REPO)}")
    if os.path.exists(STATE):
        os.remove(STATE)
    left = [f for f in os.listdir(pack.BACKUP_DIR) if f.endswith(".backup.json")] if os.path.isdir(pack.BACKUP_DIR) else []
    log(f"uninstall finished: {len(left)} backups left, appended entries "
        f"{'left' if add_entries.load_registry() else 'removed'}"
        + ("" if not left else " - anything left needs Steam's 'Verify integrity of game files'"))


def load_options(args):
    cfg = games.load_config()
    cfg.setdefault("games", {})
    for game in ("rll4", "r25"):
        val = getattr(args, game)
        if val is not None:
            cfg["games"][game] = val
        cfg["games"].setdefault(game, False)
    features = cfg.setdefault("features", {})
    if args.rll4_players is not None:
        features["rll4-players"] = args.rll4_players
    features.setdefault("rll4-players", False)
    opts = cfg.setdefault("options", {})
    if args.controller:
        opts["controller"] = args.controller
    if args.no_skip_intro:
        opts["skip_intro"] = False
    if args.texconv:
        opts["texconv"] = os.path.abspath(args.texconv)  # the builder runs it from a temp folder
    paths = cfg.setdefault("paths", {})
    for game in ("rl26", "rll4", "r25"):
        val = getattr(args, f"{game}_dir")
        if val:
            paths[game] = os.path.abspath(val)
    return cfg


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    for game, label in (("rll4", "Rugby League Live 4"), ("r25", "Rugby 25")):
        g = ap.add_mutually_exclusive_group()
        g.add_argument(f"--{game}", dest=game, action="store_true", default=None, help=f"use your {label}")
        g.add_argument(f"--no-{game}", dest=game, action="store_false", help=f"don't use {label}")
    g = ap.add_mutually_exclusive_group()
    g.add_argument("--rll4-players", dest="rll4_players", action="store_true", default=None,
                   help="also import RLL4's face-scanned players (slow; needs --rll4)")
    g.add_argument("--no-rll4-players", dest="rll4_players", action="store_false", help="don't import RLL4 players")
    ap.add_argument("--controller", choices=["detect", "auto", "xbox", "ps4", "ps5", "switch"])
    ap.add_argument("--no-skip-intro", action="store_true")
    ap.add_argument("--texconv", help="texconv.exe for the field sponsor markings and line numbers (default: the bundled one)")
    for game in ("rl26", "rll4", "r25"):
        ap.add_argument(f"--{game}-dir", help=f"the {games.GAMES[game]['name']} folder (default: found through Steam)")
    ap.add_argument("--from", dest="start", help="start at this step id")
    ap.add_argument("--only", nargs="+", help="run only these step ids")
    ap.add_argument("--list", action="store_true", help="list the steps")
    ap.add_argument("--uninstall", action="store_true", help="put the game back to stock (exe, replaced and appended entries)")
    ap.add_argument("--backup-saves", action="store_true", help="just back up the save folder")
    ap.add_argument("--list-saves", action="store_true", help="list the save backups")
    ap.add_argument("--restore-saves", metavar="NAME", help="put a save backup back ('latest' or a --list-saves name)")
    ap.add_argument("--confirm", action="store_true", help="actually install (otherwise print the plan)")
    args = ap.parse_args()
    for var in ("PYTHONHOME", "PYTHONPATH"):  # the steps run on this Python, never a system one's paths
        os.environ.pop(var, None)

    if args.backup_saves:
        backup_saves("manual")
        return
    if args.list_saves:
        for b in save_backups():
            print(f"  {b}")
        return
    if args.restore_saves:
        restore_saves(args.restore_saves, args.confirm)
        return
    if args.uninstall:
        uninstall(args.confirm)
        return
    steps = _steps()
    if args.list:
        for sid, title, *_ in steps:
            print(f"  {sid:<10} {title}")
        return

    cfg = load_options(args)
    opts = dict(cfg["options"], games=cfg["games"], features=cfg["features"])
    if not opts.get("texconv") and os.path.exists(games.toolchain("texconv", "texconv.exe")):
        opts["texconv"] = games.toolchain("texconv", "texconv.exe")
    rl26 = games.find("rl26", cfg)
    if rl26 is None:
        raise SystemExit("Rugby League 26 isn't installed where expected (set RL26_DIR or \"paths\" in revamp_install.json).")
    for game in ("rll4", "r25"):
        if cfg["games"][game] and games.find(game, cfg) is None:
            raise SystemExit(f"{games.GAMES[game]['name']} was selected but isn't installed where expected "
                             f"(set {games.ENV[game]} or \"paths\" in revamp_install.json, or pass --no-{game}).")

    ids = [s[0] for s in steps]
    chosen = steps
    if args.only:
        bad = [s for s in args.only if s not in ids]
        if bad:
            raise SystemExit(f"unknown step(s) {bad}; see --list")
        chosen = [s for s in steps if s[0] in args.only]
    elif args.start:
        if args.start not in ids:
            raise SystemExit(f"unknown step {args.start!r}; see --list")
        chosen = steps[ids.index(args.start):]

    print(f"Rugby League 26: {rl26}")
    for game in ("rll4", "r25"):
        print(f"{games.GAMES[game]['name']}: {'yes - ' + games.find(game, cfg) if cfg['games'][game] else 'no'}")
    print(f"RLL4 players: {'yes' if rll4_players(opts) else 'no'}")
    print("plan:")
    for sid, title, cond, cmds in chosen:
        on = cond(opts)
        print(f"  {'*' if on else '-'} {sid:<10} {title}{'' if on else '  (skipped)'}")
        if on and cmds and not args.confirm:
            for c in cmds(opts):
                print("        " + " ".join(os.path.relpath(x, REPO) if os.path.isabs(x) and x.startswith(REPO) else x
                                          for x in c[1:]))
    if not args.confirm:
        print("dry run - pass --confirm to install (close the game first)")
        return
    if game_running():
        raise SystemExit("Rugby League 26 is running - close it first (installs can't write the game's index while it's open).")

    with open(games.CONFIG, "w", encoding="utf-8") as f:
        json.dump(cfg, f, indent=1)
        f.write("\n")
    state = json.load(open(STATE)) if os.path.exists(STATE) else {"done": []}
    log(f"install started: games {cfg['games']}, features {cfg['features']}, options {cfg['options']}")
    backup_saves("pre_install")
    for sid, title, cond, cmds in chosen:
        if not cond(opts):
            continue
        log(f"== {sid}: {title}")
        if game_running():
            raise SystemExit(f"Rugby League 26 was started during the install - close it and rerun with --from {sid}")
        if sid == "stock":
            extract_stock()
        else:
            for c in cmds(opts):
                log("   " + " ".join(c[1:]))
                with open(LOG, "a", encoding="utf-8") as f:
                    r = subprocess.run(c, cwd=REPO, stdout=f, stderr=subprocess.STDOUT)
                if r.returncode != 0:
                    log(f"FAILED ({r.returncode}) - see {os.path.relpath(LOG, REPO)}; fix and rerun with --from {sid}")
                    raise SystemExit(1)
        state["done"].append(sid)
        with open(STATE, "w") as f:
            json.dump(state, f, indent=1)
    log("install finished")


if __name__ == "__main__":
    sys.exit(main())
