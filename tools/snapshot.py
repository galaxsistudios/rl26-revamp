#!/usr/bin/env python3
"""
snapshot.py - snapshot the game install (+ saves + _backup) before a game
update, and afterwards report what the update changed.

    python tools\\snapshot.py take [--label NAME]     # before an update (any time)
    python tools\\snapshot.py list
    python tools\\snapshot.py check [--snapshot DIR]  # after an update (+ Steam verify)

`take` writes _snapshots/build_<buildid>_<YYYYMMDD_HHMMSS>[_label]/:
  game/            mirror of the install. Untouched stock blobs are HARD LINKS
                   (free: the install is ~80GB); everything else - the index,
                   exe, dlls, loose files and every blob a mod has replaced -
                   is a real copy, because Steam verify / pack.py rewrite those.
                   Steam stages updates and moves them in, so linked files
                   keep the old build's content. pack.py/add_entries.py write
                   blobs via temp file + os.replace so they never edit a link.
  stock_index.pc   the index with every pack.py-modded record put back to stock
                   and appended entries (add_entries.py) cut off = the clean
                   index of this build, for `check` to diff against.
  saves/           copy of Saved Games/Rugby League 26
  backup/          copy of _backup/ (per-entry stock blobs, exe .baks, registry)
  _listing.json    {relpath: [size, mtime_ns]} of game/ (same format as the
                   older build_26072201 snapshot)
  _info.json       build id, depot manifest, version.txt, modded entries, ...

Rollback from Steam instead: steam://open/console then
    download_depot 3468660 3468661 <manifest from _info.json>

`check` compares the live install against a snapshot (default: newest) and
prints: build/version change, whether the index grew or shifted, which stock
entries the update changed (and which of those we mod), dropped appended
entries, and whether the exe is new. Run it after Steam's "Verify integrity"
so the install is fully stock; it still works on a modded install but then
lists modded entries as "still modded".
"""

import argparse
import hashlib
import json
import os
import re
import shutil
import struct
import subprocess
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pack  # noqa: E402

REPO_ROOT = pack.REPO_ROOT
SNAP_ROOT = os.path.join(REPO_ROOT, "_snapshots")
GAME_DIR = os.path.dirname(os.path.dirname(pack.BLOBSET_PATH))
ACF_PATH = os.path.join(os.path.dirname(os.path.dirname(GAME_DIR)), "appmanifest_3468660.acf")
SAVES_DIR = os.path.join(os.path.expanduser("~"), "Saved Games", "Rugby League 26")
EXE_NAME = "rugbyleague1.exe"
INDEX_REL = os.path.join("data", "data-0.blobset.pc")
BLOB_REL_RE = re.compile(r"^data[\\/][0-9a-f]{2}[\\/][0-9a-f]{14}$")


def md5(path):
    h = hashlib.md5()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def steam_build():
    with open(ACF_PATH, encoding="utf-8") as f:
        acf = f.read()
    build = re.search(r'"buildid"\s+"(\d+)"', acf).group(1)
    manifest = re.search(r'"3468661"\s*\{\s*"manifest"\s+"(\d+)"', acf).group(1)
    staging = re.search(r'"StagingSize"\s+"(\d+)"', acf).group(1)
    return build, manifest, staging != "0"


def game_version():
    path = os.path.join(GAME_DIR, "version.txt")
    with open(path, encoding="utf-8", errors="replace") as f:
        return f.read().strip()


def game_running():
    out = subprocess.run(["tasklist", "/FI", f"IMAGENAME eq {EXE_NAME}", "/NH"],
                         capture_output=True, text=True).stdout
    return EXE_NAME.lower() in out.lower()


def modded_entries(backup_dir):
    """{entry_index: backup meta} for every un-restored pack.py install."""
    out = {}
    for name in os.listdir(backup_dir):
        m = re.match(r"entry_(\d+)\.backup\.json$", name)
        if m:
            with open(os.path.join(backup_dir, name)) as f:
                out[int(m.group(1))] = json.load(f)
    return out


def added_registry(backup_dir):
    path = os.path.join(backup_dir, "added_entries.json")
    if not os.path.exists(path):
        return None
    with open(path) as f:
        return json.load(f)


def record(data, hash_off, size_off, i):
    return (data[hash_off + i * 8: hash_off + i * 8 + 8],
            data[size_off + i * 16: size_off + i * 16 + 16])


def build_stock_index(live_index_path, modded, base_count):
    """Live index with modded records reverted from their own backups,
    truncated to base_count entries (drops appended entries)."""
    data, count, hash_off, size_off = pack.read_index(live_index_path)
    data = bytearray(data)
    for i, meta in modded.items():
        bdata, bcount, bhash, bsize = pack.read_index(meta["blobset_backup"])
        h, s = record(bdata, bhash, bsize, i)
        data[hash_off + i * 8: hash_off + i * 8 + 8] = h
        data[size_off + i * 16: size_off + i * 16 + 16] = s
    if base_count is None or base_count >= count:
        return bytes(data), count
    hashes = data[hash_off: hash_off + base_count * 8]
    sizes = data[size_off: size_off + base_count * 16]
    return struct.pack("<2I", pack.MAGIC_V4, base_count) + bytes(hashes) + bytes(sizes), base_count


# --------------------------------------------------------------------------
# take
# --------------------------------------------------------------------------

def cmd_take(args):
    if game_running():
        sys.exit("the game is running - close it first")
    build, manifest, staging = steam_build()
    if staging:
        sys.exit("Steam has an update staged/in progress - snapshot before it starts, or after it finishes")
    name = f"build_{build}_{time.strftime('%Y%m%d_%H%M%S')}" + (f"_{args.label}" if args.label else "")
    snap = os.path.join(SNAP_ROOT, name)
    game_out = os.path.join(snap, "game")
    os.makedirs(game_out)

    modded = modded_entries(pack.BACKUP_DIR)
    copy_blobs = {os.path.normcase(os.path.abspath(m["blob_path"])) for m in modded.values()}

    print(f"snapshot -> {snap}")
    listing, linked, copied, t0 = {}, 0, 0, time.time()
    for root, dirs, files in os.walk(GAME_DIR):
        dirs.sort()
        rel_root = os.path.relpath(root, GAME_DIR)
        os.makedirs(os.path.join(game_out, rel_root), exist_ok=True)
        for fn in files:
            src = os.path.join(root, fn)
            rel = os.path.normpath(os.path.join(rel_root, fn))
            dst = os.path.join(game_out, rel)
            st = os.stat(src)
            listing[rel.replace("\\", "/")] = [st.st_size, st.st_mtime_ns]
            if BLOB_REL_RE.match(rel) and os.path.normcase(src) not in copy_blobs:
                os.link(src, dst)
                linked += 1
            else:
                shutil.copy2(src, dst)
                copied += 1
            if (linked + copied) % 20000 == 0:
                print(f"  {linked + copied} files...")
    with open(os.path.join(snap, "_listing.json"), "w") as f:
        json.dump(listing, f)
    print(f"  game: {linked} hard-linked, {copied} copied ({time.time() - t0:.0f}s)")

    reg = added_registry(pack.BACKUP_DIR)
    base_count = reg["base_files_count"] if reg else None
    stock, stock_count = build_stock_index(os.path.join(GAME_DIR, INDEX_REL), modded, base_count)
    with open(os.path.join(snap, "stock_index.pc"), "wb") as f:
        f.write(stock)

    if os.path.isdir(SAVES_DIR):
        shutil.copytree(SAVES_DIR, os.path.join(snap, "saves"))
        print(f"  saves: copied {SAVES_DIR}")
    else:
        print(f"  saves: {SAVES_DIR} not found, skipped")
    shutil.copytree(pack.BACKUP_DIR, os.path.join(snap, "backup"))
    print("  backup: copied _backup/")

    git = subprocess.run(["git", "-C", REPO_ROOT, "rev-parse", "HEAD"], capture_output=True, text=True).stdout.strip()
    _d, live_count, _h, _s = pack.read_index(os.path.join(GAME_DIR, INDEX_REL))
    info = {
        "taken": time.strftime("%Y-%m-%d %H:%M:%S"),
        "buildid": build,
        "manifest": manifest,
        "version": game_version(),
        "exe_md5": md5(os.path.join(GAME_DIR, EXE_NAME)),
        "index_files_count": live_count,
        "stock_files_count": stock_count,
        "added_entries": len(reg["entries"]) if reg else 0,
        "modded_entries": sorted(modded),
        "git_head": git,
        "rollback": f"download_depot 3468660 3468661 {manifest}",
    }
    with open(os.path.join(snap, "_info.json"), "w") as f:
        json.dump(info, f, indent=2)
    print(f"done: build {build} ({info['version']}), {len(modded)} modded entries, "
          f"{info['added_entries']} appended entries")
    print(f"rollback if needed: Steam console -> {info['rollback']}")


# --------------------------------------------------------------------------
# list / check
# --------------------------------------------------------------------------

def snapshots():
    out = []
    for name in sorted(os.listdir(SNAP_ROOT)) if os.path.isdir(SNAP_ROOT) else []:
        info_path = os.path.join(SNAP_ROOT, name, "_info.json")
        if os.path.exists(info_path):
            with open(info_path) as f:
                out.append((name, json.load(f)))
    return sorted(out, key=lambda x: x[1]["taken"])


def cmd_list(_args):
    for name, info in snapshots():
        print(f"{name}  build {info['buildid']}  {info['version']}  taken {info['taken']}  "
              f"manifest {info['manifest']}")


def cmd_check(args):
    snaps = snapshots()
    if args.snapshot:
        snap = os.path.join(SNAP_ROOT, os.path.basename(args.snapshot.rstrip("\\/")))
        with open(os.path.join(snap, "_info.json")) as f:
            info = json.load(f)
    elif snaps:
        snap, info = os.path.join(SNAP_ROOT, snaps[-1][0]), snaps[-1][1]
    else:
        sys.exit("no snapshots taken with this tool yet")
    with open(os.path.join(snap, "_listing.json")) as f:
        listing = json.load(f)
    modded_then = set(info["modded_entries"])
    print(f"comparing live install against {os.path.basename(snap)}")

    # 1. build / version
    build, manifest, staging = steam_build()
    version = game_version()
    print(f"\n[build]  {info['buildid']} -> {build}" + ("   (UPDATED)" if build != info["buildid"] else "   (same build)"))
    print(f"[version] {info['version']} -> {version}")
    if staging:
        print("  ! Steam still has an update staged - let it finish first")

    # 2. snapshot integrity (a hard link that got edited in place shows up here)
    bad = []
    for rel, (size, mtime) in listing.items():
        p = os.path.join(snap, "game", rel)
        if os.path.exists(p):
            st = os.stat(p)
            if st.st_size != size or st.st_mtime_ns != mtime:
                bad.append(rel)
        else:
            bad.append(rel)
    print(f"[snapshot integrity] {'OK' if not bad else f'{len(bad)} files no longer match - snapshot is NOT a clean copy'}")
    for rel in bad[:10]:
        print(f"    {rel}")

    # 3. index
    stock, scount, shash, ssize = pack.read_index(os.path.join(snap, "stock_index.pc"))
    raw, rcount, rhash, rsize = pack.read_index(os.path.join(snap, "game", INDEX_REL))
    live, lcount, lhash, lsize = pack.read_index(os.path.join(GAME_DIR, INDEX_REL))
    print(f"\n[index] stock entries {scount}, appended {rcount - scount} (snapshot)  ->  live index has {lcount}")
    shifted, changed, still_modded = [], [], []
    for i in range(min(scount, lcount)):
        sh, ss = record(stock, shash, ssize, i)
        lh, ls = record(live, lhash, lsize, i)
        if sh != lh:
            shifted.append(i)
        elif ss != ls:
            if i in modded_then and record(raw, rhash, rsize, i) == (lh, ls):
                still_modded.append(i)
            else:
                changed.append(i)
    if lcount < scount:
        print(f"  ! live index has FEWER entries than stock ({scount - lcount} removed by the update)")
    elif lcount == scount and rcount > scount:
        print(f"  appended entries dropped from the index ({rcount - scount}) - re-add them before installing mods "
              f"(see memory/reapply-mods-procedure)")
    elif lcount > scount:
        if lcount == rcount and live[lhash + scount * 8: lhash + lcount * 8] == raw[rhash + scount * 8: rhash + rcount * 8]:
            print("  appended entries still present")
        else:
            print(f"  ! index grew differently from the snapshot ({lcount} vs {rcount}) - the update may have added "
                  f"its own entries; appended-entry positions need checking")
    if shifted:
        print(f"  ! {len(shifted)} entries now hold a DIFFERENT file (index shifted) - manifests/ and every "
              f"hard-coded entry number need re-checking. first: {shifted[:15]}")
    else:
        print("  no entry changed position (manifests/ entry numbers still valid)")
    if still_modded:
        print(f"  {len(still_modded)} entries still hold our mods (run Steam 'Verify integrity' for a clean compare)")

    # 4. blob content changes with the same index record (e.g. 39959 repacked to the same size)
    data_dir = os.path.join(GAME_DIR, "data")
    for i in range(min(scount, lcount)):
        if i in changed or i in shifted or i in still_modded:
            continue
        folder, fh = pack.entry_hash(live, lhash, i)
        rel = f"data/{folder}/{fh}"
        if i in modded_then:
            # snapshot holds our modded blob; the stock one is in backup/
            bak = os.path.join(snap, "backup", f"entry_{i}.blob.bak")
            live_blob = os.path.join(data_dir, folder, fh)
            if os.path.exists(bak) and os.path.exists(live_blob) and (
                    os.path.getsize(bak) != os.path.getsize(live_blob) or md5(bak) != md5(live_blob)):
                changed.append(i)
        elif rel in listing:
            try:
                st = os.stat(os.path.join(data_dir, folder, fh))
            except FileNotFoundError:
                continue
            size, mtime = listing[rel]
            if st.st_size != size or st.st_mtime_ns != mtime:
                changed.append(i)
    changed.sort()
    ours = [i for i in changed if i in modded_then]
    print(f"\n[entries changed by the update] {len(changed)}")
    print(f"  ones we mod ({len(ours)}): {ours if ours else 'none'}")
    other = [i for i in changed if i not in modded_then]
    if other:
        print(f"  others: {other[:40]}{' ...' if len(other) > 40 else ''}")
    if 39959 in changed:
        old = os.path.join(snap, "backup", "entry_39959.blob.bak")
        folder, fh = pack.entry_hash(live, lhash, 39959)
        print("  scripts (39959) changed - see which of our overridden Lua files the devs touched:")
        print(f'    python tools\\diff_bundle.py "{old}" "{os.path.join(data_dir, folder, fh)}" --decompile --out _build\\update_diff')

    # 5. loose files (exe, dlls, version.txt, ...)
    print("\n[loose files]")
    live_md5 = md5(os.path.join(GAME_DIR, EXE_NAME))
    exe_baks = {n.split(".")[2] for n in os.listdir(os.path.join(snap, "backup")) if n.startswith(EXE_NAME + ".")}
    if live_md5 == info["exe_md5"]:
        print("  exe: same file as at snapshot time (patches still applied)")
    elif live_md5 in exe_baks:
        print("  exe: an OLD-build exe (stock or partly patched) - not changed by the update")
    else:
        print("  exe: NEW exe - the update changed it; re-run exe patch tools (they find code by pattern)")
    for root, _dirs, files in os.walk(GAME_DIR):
        for fn in files:
            rel = os.path.relpath(os.path.join(root, fn), GAME_DIR).replace("\\", "/")
            if BLOB_REL_RE.match(rel) or rel in ("data/data-0.blobset.pc", EXE_NAME) or rel.endswith(".txt") and "_debug" in rel:
                continue
            st = os.stat(os.path.join(root, fn))
            if rel not in listing:
                print(f"  new: {rel}")
            elif listing[rel][0] != st.st_size or listing[rel][1] != st.st_mtime_ns:
                print(f"  changed: {rel}")

    print("\nnext: Steam verify (if not done) -> move _backup to _backup_build_<old> -> re-add appended entries "
          "-> reinstall mods (memory/reapply-mods-procedure) -> test in-game")
    print(f"rollback: Steam console -> {info['rollback']}")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    t = sub.add_parser("take", help="snapshot install + saves + _backup")
    t.add_argument("--label", help="suffix for the snapshot folder name")
    sub.add_parser("list", help="list snapshots taken with this tool")
    c = sub.add_parser("check", help="report what changed since a snapshot")
    c.add_argument("--snapshot", help="snapshot folder name (default: newest)")
    args = ap.parse_args()
    {"take": cmd_take, "list": cmd_list, "check": cmd_check}[args.cmd](args)


if __name__ == "__main__":
    main()
