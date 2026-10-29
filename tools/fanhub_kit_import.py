"""Turn a jersey captured from the game into a custom kit for rll4-legacy-kits.

Per jersey (see tools/renderdoc_kit.py):
  1. In game, LB on the jersey in a club's Uniforms list (Academy or FanHub)
     writes Documents/RL26Jersey_<club>_<kit>.json (design items).
  2. F12 under RenderDoc, then `renderdoc_kit.py extract` writes the composited
     textures next to it: _top.png 4096x2048, _shorts.png 2048x2048,
     _socks.png 1024x1024 (decals included, number and name left out).
  3. This script flips them upright, writes resources/custom-kits/<name>/
     {top,shorts,socks}.png + preview.png, and with --club adds or updates the
     kits.json "custom" row. Its "templates" are the design's own items, so the
     kit keeps that design's models and UV layouts (a V-neck stays a V-neck).
     --install then runs the install steps (game closed). Only new or changed
     kits are baked and written, so that takes a minute or two, not 10+.

Batch several jerseys by leaving --install off the others and adding it to the last.

    python tools/fanhub_kit_import.py "%USERPROFILE%/Documents/RL26Jersey_storm_jersey_3.json" \
        --name storm_indigenous_2026 --club 9 --kit-name "INDIGENOUS 2026" --install
"""
import argparse
import json
import os
import re
import sys

from PIL import Image

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(REPO, "tools"))
import jersey_template as jt  # noqa: E402

CUSTOM = os.path.join(REPO, "resources", "custom-kits")
MANIFEST = os.path.join(REPO, "mods", "rll4-legacy-kits", "kits.json")
# 60001+ RLL4 kits, 61001-61109 team-coaches' polos, 62001+ referee kits:
# a clash means the second item is never registered (WCC 2026 on 61001 wore
# the black coach polo, 2026-10-29)
FIRST_CUSTOM_GUID = 64001


def mod_item_guids():
    """Design guids that mods register in Lua ({ guid, ... } rows and guid = N
    fields), so a new kit never reuses one."""
    used = set()
    for root, _dirs, files in os.walk(os.path.join(REPO, "mods")):
        for name in files:
            if name.endswith(".lua"):
                with open(os.path.join(root, name), encoding="utf-8-sig", errors="replace") as f:
                    text = f.read()
                used.update(int(g) for g in re.findall(r"\{ (\d{5}),", text))
                used.update(int(g) for g in re.findall(r"\bguid = (\d{5})\b", text))
    return used
# export part -> (design option, mesh name pattern for the preview)
PARTS = {
    "top": ("uniformTop", "{item}_short_{sex}"),
    "shorts": ("uniformBottom", "{item}_{sex}"),
    "socks": ("uniformSocks", "{item}_long_{sex}"),
}


def load_export(path):
    with open(path, encoding="utf-8") as f:
        info = json.load(f)
    base = path[:-len(".json")] if path.lower().endswith(".json") else path
    images = {}
    for part in PARTS:
        entry = info.get("parts", {}).get(part, {})
        png = entry.get("file") or f"{base}_{part}.png"
        if not os.path.exists(png):  # the export may have been moved with its JSON
            png = f"{base}_{part}.png"
        if not os.path.exists(png):
            raise SystemExit(f"missing {part}: {png} (export errors: {info.get('errors') or 'none'})")
        if entry.get("raw"):
            raise SystemExit(f"{part}: the game handed back {entry.get('bufferBytes')} bytes for a "
                             f"{entry.get('width')}x{entry.get('textureHeight')} texture - not RGBA8 "
                             f"(compressed?), which this script can't decode yet")
        images[part] = Image.open(png)
    return info, images


def prepare(images, flip, swap_rb):
    """{part: upright RGB image at the installed size}."""
    out = {}
    for part, im in images.items():
        size = jt.PARTS[part][2]
        im = im.convert("RGBA")
        if swap_rb:
            r, g, b, a = im.split()
            im = Image.merge("RGBA", (b, g, r, a))
        im = im.convert("RGB")
        if flip:
            im = im.transpose(Image.FLIP_TOP_BOTTOM)
        if im.size != size:
            print(f"  {part}: {im.size[0]}x{im.size[1]} resized to {size[0]}x{size[1]}"
                  + (" (upscaled - set character quality to high before exporting)" if im.size[0] < size[0] else ""))
            im = im.resize(size, Image.LANCZOS)
        out[part] = im
    return out


def preview(images, info, out):
    """jersey_template's 3D preview, on the exported design's own meshes when
    they're known and in the index (else the default round05/shorts01/socks01)."""
    import bigant_mesh as bm
    sex = "Female" if info.get("sex") == 1 else "Male"
    saved = dict(jt.PARTS)
    try:
        for part, (option, pattern) in PARTS.items():
            item = info.get(option + "Item")
            if not item:
                continue
            name = pattern.format(item=item, sex=sex)
            try:
                bm.load_rl26(jt.PARTS[part][0], name)
            except SystemExit:
                print(f"  preview: {name} isn't in the index, using {jt.PARTS[part][1]}")
                continue
            jt.PARTS[part] = (jt.PARTS[part][0], name) + tuple(jt.PARTS[part][2:])
        jt.render(images).save(out)
    finally:
        jt.PARTS.clear()
        jt.PARTS.update(saved)


def update_manifest(name, club, kit_name, info, guid):
    with open(MANIFEST, encoding="utf-8") as f:
        manifest = json.load(f)
    kits = manifest["kits"]
    templates = {option: info[option] for option, _ in PARTS.values() if isinstance(info.get(option), int)}
    row = next((k for k in kits if k.get("custom") == name), None)
    if row is None:
        used = {k["guid"] for k in kits} | mod_item_guids()
        if guid is None:
            guid = max([FIRST_CUSTOM_GUID - 1] + [k["guid"] for k in kits if k["guid"] >= FIRST_CUSTOM_GUID]) + 1
            while guid in used:
                guid += 1
        if guid in used:
            raise SystemExit(f"guid {guid} is already used (kits.json or another mod's items)")
        row = {"guid": guid, "custom": name}
        kits.append(row)
        action = "added"
    else:
        action = "updated"
    row.update({"club": club, "name": kit_name, "texture": row.get("texture", name)})
    if templates:
        row["templates"] = templates
    with open(MANIFEST, "w", encoding="utf-8", newline="\n") as f:
        json.dump(manifest, f, indent=1)
        f.write("\n")
    print(f"{action} kits.json row: {json.dumps(row)}")
    return row


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("export", help="the RL26Jersey_*.json the game wrote (its PNGs next to it)")
    ap.add_argument("--name", help="resources/custom-kits folder and texture name (default: from the export)")
    ap.add_argument("--club", type=int, help="RL26 club id: also add/update the kits.json row")
    ap.add_argument("--kit-name", help="kit name in game (default: the exported kit's name, upper case)")
    ap.add_argument("--guid", type=int, help=f"design guid for a new row (default: next free from {FIRST_CUSTOM_GUID})")
    ap.add_argument("--no-flip", action="store_true", help="keep the rows as read back (the game's textures are stored upside down)")
    ap.add_argument("--swap-rb", action="store_true", help="swap red and blue (if the colours come out wrong)")
    ap.add_argument("--install", action="store_true", help="then install it (the game must be closed; with --club)")
    args = ap.parse_args()

    info, images = load_export(args.export)
    name = args.name or re.sub(r"[^a-z0-9]+", "_", os.path.basename(args.export).lower()
                               .replace("rl26jersey_", "").replace(".json", "")).strip("_")
    print(f"{info.get('club')} / {info.get('kit')}: top {info.get('uniformTopItem') or info.get('uniformTop')}, "
          f"shorts {info.get('uniformBottomItem') or info.get('uniformBottom')}, "
          f"socks {info.get('uniformSocksItem') or info.get('uniformSocks')}")
    if info.get("sex") == 1:
        print("  note: a women's design - rll4-legacy-kits' kit rows are only tested on men's clubs")

    upright = prepare(images, not args.no_flip, args.swap_rb)
    out = os.path.join(CUSTOM, name)
    os.makedirs(out, exist_ok=True)
    for part, im in upright.items():
        im.save(os.path.join(out, f"{part}.png"))
    with open(os.path.join(out, "export.json"), "w", encoding="utf-8") as f:
        json.dump(info, f, indent=1)
    preview(upright, info, os.path.join(out, "preview.png"))
    print(f"wrote {os.path.relpath(out, REPO)} (check preview.png: if the kit is upside down, rerun with --no-flip)")

    if args.club is not None:
        kit_name = args.kit_name or str(info.get("kit") or name).upper()
        update_manifest(name, args.club, kit_name, info, args.guid)
        if args.install:
            install()
        else:
            print(f"next: rerun with --install, or: python tools/install_revamp.py --only {' '.join(INSTALL_STEPS)} --confirm")
    elif args.install:
        raise SystemExit("--install needs --club (the kit has to be added to a club)")


# the install_revamp steps a new kit touches: textures, texsrc registration,
# the club's kit slot, the clubs bundle, crowd kit lists, and the script
# bundle (the design item); bake/install skip the kits that haven't changed
INSTALL_STEPS = ("kits", "texsrc", "kit-slots", "data", "crowd", "scripts")


def install():
    import subprocess
    running = subprocess.run(["tasklist", "/FI", "IMAGENAME eq rugbyleague1.exe"], capture_output=True, text=True)
    if "rugbyleague1.exe" in running.stdout.lower():
        raise SystemExit("close the game first, then rerun with --install")
    cmd = [sys.executable, os.path.join(REPO, "tools", "install_revamp.py"), "--only", *INSTALL_STEPS, "--confirm"]
    print("installing:", " ".join(INSTALL_STEPS))
    result = subprocess.run(cmd)
    if result.returncode:
        raise SystemExit(f"install failed (see _build/install_revamp.log); fix it and rerun: {' '.join(cmd)}")
    print("installed - start the game and look for the kit in the club's list")


if __name__ == "__main__":
    main()
