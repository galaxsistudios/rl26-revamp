#!/usr/bin/env python3
"""
install.py - attack-play-coverage's play data (see README.md).

The game reads its plays from two compiled entries, plays/playset.dat (attack plays) and plays/formationset.dat
(kick-off, drop-out, tap... layouts); the intermediatelua/plays/*.lua files are only authoring sources. This
reads both stock entries (playset.py decodes them), then:

  1. fills every open-play (tackles 1-4) slice x type gap for CrossOver / OutTheBack / InsideBall with a stock
     play of that type, mirrored (slice s <-> 13-s, left/right roles, targets and tags swapped) or moved from
     the nearest slice whose spots still fit on the field there;
  2. adds early-tackle Kick plays (each slice's last-tackle punt and attacking kick) that need the "Kick" tag,
     so they only run when Kick is called and never replace the last-tackle kicks;
  3. fixes Slice 2 Hooker scoot's winger spot (6 m over the touchline);
  4. rewrites KickOffOffence (the receiving team at a kick-off; stock is a copy of the drop-out kicking layout,
     props 12 m in goal) into a real receive shape.

New plays are appended after the stock ones, so stock play indices don't move.

Usage (game closed):
    python mods/attack-play-coverage/install.py show               # dry run: what would be added
    python mods/attack-play-coverage/install.py install --confirm
    python mods/attack-play-coverage/install.py restore
    python mods/attack-play-coverage/install.py status
"""

import argparse
import copy
import os
import re
import sys

MOD_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(os.path.dirname(MOD_DIR))
sys.path.insert(0, os.path.join(REPO_ROOT, "tools"))
sys.path.insert(0, MOD_DIR)
import classify_entries as ce  # noqa: E402
import entries  # noqa: E402
import pack  # noqa: E402
import playset  # noqa: E402

BUILD_DIR = os.path.join(REPO_ROOT, "_build", "attack-play-coverage")
ENTRIES = ("plays/playset.dat", "plays/formationset.dat")

SLICES = 14
HALF_WIDTH = 34.0
SLICE_WIDTH = HALF_WIDTH * 2 / SLICES
FIELD_LIMIT = 33.5  # spots must stay this far inside the touchline (ruck at the strip centre)
GAP_TYPES = ("CrossOver", "OutTheBack", "InsideBall")
# EPlayRole: FB0 WL1 CL2 CR3 WR4 5/8=5 HB6 PropL7 Hook8 PropR9 2RL10 2RR11 Lock12; 14 = dummy half,
# 15 = first receiver (no side); state target 19 = none.
MIRROR_ROLE = {1: 4, 4: 1, 2: 3, 3: 2, 5: 6, 6: 5, 7: 9, 9: 7, 10: 11, 11: 10}
MIRROR_TAG = {"Left": "Right", "Right": "Left"}
TAG_KEYS = playset.TAG_KEYS

# Receiving team's frame: halfway = 0, own try line = -50; they must stay behind -10 until the kick.
# Role 14 = whoever the play-role assignment makes "dummy half" (the hooker).
# Props and lock start off the back fence (in goal) so they take the catch running onto it.
KICKOFF_RECEIVE = {
    10: (-13, -16),    # second rowers: front line, short-kick cover
    11: (-13, 16),
    2: (-15, -27),     # centres: front line, wide short-kick cover
    3: (-15, 27),
    14: (-24, 0),      # hooker
    5: (-35, -16),     # halves
    6: (-35, 16),
    1: (-42, -26),     # wingers
    4: (-42, 26),
    0: (-46, 0),       # fullback
    12: (-52, 0),      # lock: deep, running onto it
    7: (-56, -9),      # props: off the back fence, the usual kick-off catchers
    9: (-56, 9),
}


def tags(play, key):
    return play.get(key) or []


def is_open_play(play):
    req = tags(play, "requiredTags")
    return not any(t in req for t in ("Tap", "Scrum", "InPocket", "Scoot", "LastTackle"))


def has_kick(play):
    # Play mechanics 36-40 are the kicks (punt/bomb/grubber/chip/40-20); 28-31 passes, 14 hit-up.
    return any(st["mechanic"] >= 36 for p in play["participants"] for st in p["states"])


def strip_centre(s):
    return -HALF_WIDTH + SLICE_WIDTH * (s + 0.5)


def fits(play, s):
    ys = [st["yPosition"] for p in play["participants"] for st in p["states"]]
    c = strip_centre(s)
    return c + min(ys) >= -FIELD_LIMIT and c + max(ys) <= FIELD_LIMIT


def mirror(play):
    out = copy.deepcopy(play)
    out["slice"] = SLICES - 1 - play["slice"]
    for key in ("focusRole", "startingRole"):
        out[key] = MIRROR_ROLE.get(play[key], play[key])
    for key in TAG_KEYS:
        if key in play:
            out[key] = [MIRROR_TAG.get(t, t) for t in play[key]]
    for p in out["participants"]:
        p["role"] = MIRROR_ROLE.get(p["role"], p["role"])
        for st in p["states"]:
            st["yPosition"] = -st["yPosition"]
            st["target"] = MIRROR_ROLE.get(st["target"], st["target"])
    return out


def retitle(play, s, note):
    out = copy.deepcopy(play)
    base = re.sub(r"^slice\s*_?\s*\d+\s*", "", play["name"], flags=re.I).strip(" _") or play["name"]
    out["name"] = "Slice %d %s (%s)" % (s, base, note)
    out["slice"] = s
    return out


def new_plays(stock, log):
    added = []
    variants = []
    for p in stock:
        if is_open_play(p):
            variants.append((p, "moved"))
            variants.append((mirror(p), "mirrored"))
    for t in GAP_TYPES:
        for s in range(SLICES):
            if any(p["slice"] == s and t in tags(p, "preferredTags") and is_open_play(p) for p in stock):
                continue
            best = None
            for v, how in variants:
                if t not in tags(v, "preferredTags") or not fits(v, s):
                    continue
                key = (abs(v["slice"] - s), how != "mirrored", v["name"])
                if best is None or key < best[0]:
                    best = (key, v, how)
            if best is None:
                log("GAP  %-10s slice %2d: no stock play fits" % (t, s))
                continue
            (d, _, _), v, how = best
            note = "mirrored" if d == 0 else ("mirrored, " if how == "mirrored" else "") + "from slice %d" % v["slice"]
            added.append(retitle(v, s, note))
            log("GAP  %-10s slice %2d <- %s [%s]" % (t, s, v["name"], note))

    for s in range(SLICES):
        kicks = [p for p in stock if p["slice"] == s and "LastTackle" in tags(p, "requiredTags")
                 and "Kick" in tags(p, "preferredTags") and has_kick(p)]
        punts = [p for p in kicks if "punt" in p["name"].lower()]
        attack = [p for p in kicks if "punt" not in p["name"].lower() and "field goa" not in p["name"].lower()]
        for group in (punts, attack):
            if not group:
                continue
            src = sorted(group, key=lambda p: p["name"])[0]
            out = retitle(src, s, "early kick")
            out["requiredTags"] = [x for x in tags(src, "requiredTags") if x != "LastTackle"] + ["Kick"]
            out["bannedTags"] = tags(src, "bannedTags") + ["LastTackle"]
            out["unpreferredTags"] = [x for x in tags(src, "unpreferredTags") if x != "LastTackle"]
            if not out["unpreferredTags"]:
                del out["unpreferredTags"]
            added.append(out)
            log("KICK slice %2d <- %s" % (s, src["name"]))
    return added


def fix_hooker_scoot(plays, log):
    for p in plays:
        if p["name"] == "Slice 2 Hooker scoot":
            c = strip_centre(p["slice"])
            for part in p["participants"]:
                for st in part["states"]:
                    if c + st["yPosition"] > FIELD_LIMIT:
                        log("FIX  Hooker scoot role %d y %.1f -> %.1f" % (part["role"], st["yPosition"], FIELD_LIMIT - 1 - c))
                        st["yPosition"] = FIELD_LIMIT - 1.0 - c
            return
    raise SystemExit("Slice 2 Hooker scoot not found")


def fix_kickoff(formations, log):
    ko = next(f for f in formations if f["name"] == "KickOffOffence")
    roles = {p["role"] for p in ko["participants"]}
    if roles != set(KICKOFF_RECEIVE):
        raise SystemExit("KickOffOffence roles changed: %s" % sorted(roles))
    for p in ko["participants"]:
        x, y = KICKOFF_RECEIVE[p["role"]]
        p["states"][0]["xPosition"] = float(x)
        p["states"][0]["yPosition"] = float(y)
    log("FIX  KickOffOffence: %d receive spots" % len(ko["participants"]))


def stock_entry(blobset, name):
    entry = entries.index_of(name)
    if os.path.exists(pack.backup_meta_path(entry)):
        raise SystemExit(f"{name} (entry {entry}) is modified (backup exists) - restore it before reading it as stock")
    ce.load_index(blobset)
    raw = ce.read_blob_full(blobset, entry)[0]
    if raw is None:
        raise SystemExit(f"{name} (entry {entry}) blob is missing")
    return raw


def build(blobset, log=print):
    raw_plays = stock_entry(blobset, ENTRIES[0])
    raw_forms = stock_entry(blobset, ENTRIES[1])
    plays = playset.read(raw_plays)
    forms = playset.read(raw_forms)
    if playset.write(plays) != raw_plays or playset.write(forms) != raw_forms:
        raise SystemExit("stock play sets don't round-trip - format changed, update playset.py")
    names = {p["name"] for p in plays}
    added = new_plays(plays, log)
    for p in added:
        if p["name"] in names:
            raise SystemExit("duplicate play name " + p["name"])
        names.add(p["name"])
    fix_hooker_scoot(plays, log)
    fix_kickoff(forms, log)
    log("%d stock plays + %d new" % (len(plays), len(added)))
    out_plays = playset.write(plays + added)
    out_forms = playset.write(forms)
    if len(playset.read(out_plays)) != len(plays) + len(added):
        raise SystemExit("re-read check failed")
    return [(ENTRIES[0], out_plays), (ENTRIES[1], out_forms)]


def cmd_show(args):
    build(args.blobset)


def cmd_install(args):
    if not args.confirm:
        raise SystemExit("install requires --confirm (use `show` for a dry run)")
    for name in ENTRIES:
        entry = entries.index_of(name)
        if os.path.exists(pack.backup_meta_path(entry)):
            pack.do_restore(args.blobset, entry)
    os.makedirs(BUILD_DIR, exist_ok=True)
    for name, blob in build(args.blobset):
        entry = entries.index_of(name)
        src = os.path.join(BUILD_DIR, os.path.basename(name))
        with open(src, "wb") as f:
            f.write(blob)
        pack.do_install(args.blobset, entry, src, True)
        print(f"installed {name} (entry {entry}): {len(blob)} bytes")


def cmd_restore(args):
    for name in ENTRIES:
        entry = entries.index_of(name)
        if os.path.exists(pack.backup_meta_path(entry)):
            pack.do_restore(args.blobset, entry)
            print(f"restored {name} (entry {entry})")


def cmd_status(args):
    for name in ENTRIES:
        entry = entries.index_of(name)
        print(f"{name} (entry {entry}): {'INSTALLED' if os.path.exists(pack.backup_meta_path(entry)) else 'stock'}")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--blobset", default=pack.BLOBSET_PATH)
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("install")
    p.add_argument("--confirm", action="store_true")
    p.set_defaults(func=cmd_install)
    sub.add_parser("restore").set_defaults(func=cmd_restore)
    sub.add_parser("status").set_defaults(func=cmd_status)
    sub.add_parser("show").set_defaults(func=cmd_show)
    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
