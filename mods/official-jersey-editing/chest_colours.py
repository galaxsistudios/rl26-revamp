"""Black or white chest text for each designed jersey.

Samples every designed top's colour texture (stock items in decompiled
assetmapitems.lua, plus rll4-legacy-kits' kits, which are only measured when installed)
under the chest text's default box, and lists the ones whose background is light
enough for black text (more contrast against black than white: linear luminance above
0.179). The list is the OccasionTextBlackTops block in jesse-southwell-hair's
assetmap.lua; tops not in it get white text. Academy (tinted) tops are decided in Lua
from their base colour.

Run from the repo root after new kits are installed:
    python mods/official-jersey-editing/chest_colours.py
"""
import os
import re
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, "tools"))
sys.path.insert(0, HERE)
import add_entries  # noqa: E402
import classify_entries as ce  # noqa: E402
import extract_textures as et  # noqa: E402
import pack  # noqa: E402
from generate import ASSETMAP, top_items  # noqa: E402

LEGACY = os.path.join(ROOT, "mods", "rll4-legacy-kits", "src", "script-game", "intermediatelua", "data", "jigglyjointsconfig.lua")
TEXDIR = "characters/uniforms/textures"
BLOCK = re.compile(r"(-- BEGIN OccasionTextBlackTops[^\n]*\n).*?(\n-- END OccasionTextBlackTops)", re.S)
THRESHOLD = 0.179

# the default text box in upright texture coordinates (x0, y0, x1, y1), as
# getOccasionTextWindow draws it at 100%, padded a little; top_round06/07 remapped
BOX = (0.370, 0.338, 0.434, 0.372)


def remap(box, mesh):
    if not re.match(r"^top_round0[67]", mesh or ""):
        return box
    x0, y0, x1, y1 = box
    return (0.298 + (x0 - 0.401) * 1.63, 0.588 + (y0 - 0.427) * 0.725,
            0.298 + (x1 - 0.401) * 1.63, 0.588 + (y1 - 0.427) * 0.725)


def tops():
    """[(colTexture, mesh)] for every designed top."""
    out = {}
    for item in top_items():
        if "colTexture" in item:
            out.setdefault(item["colTexture"], item.get("name"))
    if os.path.isfile(LEGACY):
        for name in re.findall(r'^\t\t\{ \d+, "([a-z0-9_]+)"', open(LEGACY, encoding="utf-8-sig").read(), re.M):
            out.setdefault("m_top_%s_col" % name, None)
    return sorted(out.items())


def luminance(dds, box):
    """Mean linear luminance of an uncompressed BGRA DDS under box (upright coords)."""
    h, w = int.from_bytes(dds[12:16], "little"), int.from_bytes(dds[16:20], "little")
    if dds[84:88] != b"\0\0\0\0" or int.from_bytes(dds[88:92], "little") != 32:
        return None
    px = np.frombuffer(dds, np.uint8, w * h * 4, 128).reshape(h, w, 4)
    x0, y0, x1, y1 = box
    # stored upside down: upright row y is stored row h - 1 - y
    rows = px[h - int(y1 * h):h - int(y0 * h), int(x0 * w):int(x1 * w), 2::-1].astype(np.float64) / 255
    lin = np.where(rows <= 0.04045, rows / 12.92, ((rows + 0.055) / 1.055) ** 2.4)
    return float((lin @ [0.2126, 0.7152, 0.0722]).mean())


def main():
    bs = pack.BLOBSET_PATH
    ce.load_index(bs)
    data, count, hash_off, _ = pack.read_index(bs)
    black, white, missing = [], 0, []
    for col, mesh in tops():
        entry = add_entries.find_entry(data, count, hash_off, f"{TEXDIR}/{col}_1.texture")
        if entry is None:
            missing.append(col)
            continue
        lum = luminance(et.parse_mini_txpk(ce.read_blob_full(bs, entry)[0])[1], remap(BOX, mesh))
        if lum is None:
            missing.append(col)
        elif lum > THRESHOLD:
            black.append(col)
        else:
            white += 1

    body = "OccasionTextBlackTops = {\n" + "".join("\t%s = true,\n" % c for c in black) + "}"
    text = open(ASSETMAP, encoding="utf-8-sig").read()
    if not BLOCK.search(text):
        raise SystemExit("no OccasionTextBlackTops block in " + ASSETMAP)
    text = BLOCK.sub(lambda m: m.group(1) + body + m.group(2), text)
    with open(ASSETMAP, "wb") as f:
        f.write(b"\xef\xbb\xbf" + text.encode("utf-8"))
    print("%d black, %d white, %d not measured%s" % (len(black), white, len(missing),
          (": " + ", ".join(missing[:10]) + (" ..." if len(missing) > 10 else "")) if missing else ""))


if __name__ == "__main__":
    main()
