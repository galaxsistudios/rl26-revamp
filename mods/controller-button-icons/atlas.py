#!/usr/bin/env python3
"""
atlas.py - PlayStation versions of the textures behind the menu prompts and
the controls menu, and installing / restoring them (TEXTURES below).

The menu prompt bar and dialog buttons (e.g. "(A) Yes, Do It!", "(B) Cancel")
are not Noesis icons. They're drawn from a texture atlas that Lua swaps by
input device (app/frontend/tooltip_mixin.lua): extrasymbols_keyboard until
the pad is used, then extrasymbols_gamepad (entry 102661). The PC build only
ships the Xbox gamepad atlas, so this rebuilds it with the game's own PS5
vector icons (resources/tooltipicons/ps5.xaml) in the Xbox-specific cells.

Atlas: 512x512 uncompressed BGRA, 8x8 cells of 64px, cell (row, col) per
intermediatelua/skin/extrasymbols_uvs.lua. Stick, D-pad and spin cells are
generic and stay as they are.

The stock atlas is read straight from the live blobset entry's backup when
one exists (so a re-run never stacks on an already-PS5 atlas), else from the
live entry.
"""

import io
import os
import re
import struct
import sys
import xml.etree.ElementTree as ET

import resvg_py
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO_ROOT, "tools"))
sys.path.insert(0, HERE)
import controls_art  # noqa: E402

ATLAS_ENTRY = 102661                       # ui/textures/extrasymbols_gamepad.pc.dds
PS5_XAML = os.path.join(REPO_ROOT, "extracted", "noesis", "workspace", "resources", "tooltipicons", "ps5.xaml")
OUT_DIR = os.path.join(REPO_ROOT, "_build", "controller-button-icons")
CELL = 64

# (row, col) -> (PS5 template, box size the icon is fitted into)
CELLS = {
    (0, 0): ("PS5_FaceDown", 56),    # Cross    (Xbox A)
    (0, 1): ("PS5_FaceRight", 56),   # Circle   (Xbox B)
    (0, 2): ("PS5_FaceUp", 56),      # Triangle (Xbox Y)
    (0, 3): ("PS5_FaceLeft", 56),    # Square   (Xbox X)
    (7, 0): ("PS5_FaceLeft", 56),    # spare Square cell (Xbox X)
    (1, 0): ("PS5_LB", 56),          # L1
    (1, 1): ("PS5_LT", 56),          # L2
    (1, 2): ("PS5_RB", 56),          # R1
    (1, 3): ("PS5_RT", 56),          # R2
    # Start keeps the stock three-line Menu glyph, which is also what
    # PlayStation prompts use for Options. ps5.xaml's Start/Back are
    # controller-part outlines that don't read at 64px, so Create (Xbox View)
    # is drawn here in the same round style as the other cells.
    (3, 2): (None, 56),
}

CREATE_SVG = ('<svg xmlns="http://www.w3.org/2000/svg" width="56" height="56" viewBox="0 0 146 146">'
              '<ellipse cx="73" cy="73" rx="70" ry="70" fill="#0d0d0e" stroke="#434343" stroke-width="6"/>'
              '<rect x="38" y="52" width="70" height="42" rx="12" fill="none" stroke="#fdfefe" stroke-width="9"/>'
              '<path d="M 48 40 L 98 40" stroke="#fdfefe" stroke-width="9" stroke-linecap="round"/>'
              '</svg>')

NS = "{http://schemas.microsoft.com/winfx/2006/xaml/presentation}"
XKEY = "{http://schemas.microsoft.com/winfx/2006/xaml}Key"


def _colour(c):
    """XAML #AARRGGBB / #RRGGBB -> (svg rgb, opacity)."""
    c = c.lstrip("#")
    if len(c) == 8:
        return "#" + c[2:], int(c[:2], 16) / 255
    return "#" + c, 1.0


def _paint(attr, el, defs, tag):
    """Fill/Stroke from an attribute or a <Path.Fill> brush -> svg attrs."""
    if attr is not None:
        rgb, a = _colour(attr)
        return f'{tag}="{rgb}" {tag}-opacity="{a:.3f}"'
    brush = el.find(f"{NS}{el.tag[len(NS):]}.{tag.capitalize()}")
    if brush is None:
        return f'{tag}="none"'
    lg = brush.find(f"{NS}LinearGradientBrush")
    if lg is None:
        return f'{tag}="none"'
    gid = f"g{len(defs)}"
    sx, sy = lg.get("StartPoint", "0,0").split(",")
    ex, ey = lg.get("EndPoint", "1,1").split(",")
    units = "userSpaceOnUse" if lg.get("MappingMode") == "Absolute" else "objectBoundingBox"
    xf = ""
    mt = lg.find(f"{NS}LinearGradientBrush.Transform/{NS}MatrixTransform")
    if mt is not None:
        xf = f' gradientTransform="matrix({mt.get("Matrix")})"'
    stops = ""
    for gs in lg.iter(f"{NS}GradientStop"):
        rgb, a = _colour(gs.get("Color"))
        stops += f'<stop offset="{gs.get("Offset", "0")}" stop-color="{rgb}" stop-opacity="{a:.3f}"/>'
    defs.append(f'<linearGradient id="{gid}" gradientUnits="{units}" x1="{sx}" y1="{sy}" x2="{ex}" y2="{ey}"{xf}>{stops}</linearGradient>')
    return f'{tag}="url(#{gid})"'


def _shape(el, defs):
    tag = el.tag[len(NS):]
    stroke = ""
    if el.get("Stroke"):
        rgb, a = _colour(el.get("Stroke"))
        stroke = f' stroke="{rgb}" stroke-opacity="{a:.3f}" stroke-width="{el.get("StrokeThickness", "1")}"'
        if el.get("StrokeMiterLimit"):
            stroke += f' stroke-miterlimit="{el.get("StrokeMiterLimit")}"'
    fill = _paint(el.get("Fill"), el, defs, "fill")
    if tag == "Path":
        data = el.get("Data", "").strip()
        rule = "evenodd" if data.startswith("F0") else "nonzero"
        data = re.sub(r"^F[01]\s*", "", data)
        return f'<path d="{data}" fill-rule="{rule}" {fill}{stroke}/>'
    if tag == "Ellipse":
        # WPF draws an ellipse's stroke inside its Width x Height box.
        w, h = float(el.get("Width")), float(el.get("Height"))
        st = float(el.get("StrokeThickness", "0")) if el.get("Stroke") else 0
        return (f'<ellipse cx="{w / 2}" cy="{h / 2}" rx="{(w - st) / 2}" ry="{(h - st) / 2}" '
                f'{fill}{stroke}/>')
    return ""


def template_svg(root, key):
    tpl = next((t for t in root.iter(f"{NS}ControlTemplate") if t.get(XKEY) == key), None)
    if tpl is None:
        raise KeyError(f"{key} not found in {PS5_XAML}")
    canvas = tpl.find(f"{NS}Canvas")
    w, h = float(canvas.get("Width")), float(canvas.get("Height"))
    defs, body = [], []
    for el in canvas.iter():
        if el.tag in (f"{NS}Path", f"{NS}Ellipse"):
            body.append(_shape(el, defs))
    return w, h, defs, body


def render_icon(root, key, box):
    if key is None:
        svg = CREATE_SVG
    else:
        w, h, defs, body = template_svg(root, key)
        scale = box / max(w, h)
        pw, ph = round(w * scale), round(h * scale)
        svg = (f'<svg xmlns="http://www.w3.org/2000/svg" width="{pw}" height="{ph}" viewBox="0 0 {w} {h}">'
               f'<defs>{"".join(defs)}</defs>{"".join(body)}</svg>')
    png = bytes(resvg_py.svg_to_bytes(svg_string=svg))
    return Image.open(io.BytesIO(png)).convert("RGBA")


def read_dds_rgba(dds):
    h, w = struct.unpack_from("<2I", dds, 12)
    if dds[84:88] != b"\0\0\0\0" or struct.unpack_from("<I", dds, 88)[0] != 32:
        raise ValueError("expected an uncompressed 32-bit DDS")
    return Image.frombuffer("RGBA", (w, h), dds[128:128 + w * h * 4], "raw", "BGRA", 0, 1).copy()


def write_dds(header_from, img):
    return header_from[:128] + img.tobytes("raw", "BGRA")


def atlas_image(stock):
    atlas = stock.copy()
    root = ET.parse(PS5_XAML).getroot()
    for (row, col), (key, box) in CELLS.items():
        x0, y0 = col * CELL, row * CELL
        atlas.paste((0, 0, 0, 0), (x0, y0, x0 + CELL, y0 + CELL))
        icon = render_icon(root, key, box)
        atlas.alpha_composite(icon, (x0 + (CELL - icon.width) // 2, y0 + (CELL - icon.height) // 2))
    return atlas


# Every texture this mod swaps for PlayStation styles:
# entry -> (description, builder(stock RGBA) -> new RGBA)
TEXTURES = {
    ATLAS_ENTRY: ("menu prompt atlas", atlas_image),
    controls_art.CONTROLLER_ENTRY: ("controls-menu controller", lambda stock: controls_art.controller_image()),
    controls_art.LINES_ENTRY: ("controls-menu badges", controls_art.lines_image),
}


def out_path(entry):
    return os.path.join(OUT_DIR, f"{entry}_ps.dds")


def _decode_blob(raw, main_c, main_u, vram_c, vram_u):
    """Same branching as classify_entries.read_blob_full, for a blob file
    read from pack.py's backup with the sizes it recorded."""
    import classify_entries as ce
    if main_c == main_u and vram_c == vram_u:
        return raw
    if main_c != main_u and vram_u == 0:
        return ce.decode_outer_zstd_frames(raw)
    if main_c == main_u or vram_c == vram_u:
        return raw[:main_u] + ce.decode_outer_zstd_frames(raw[main_u:])
    return ce.decode_outer_zstd_frames(raw)


def live_dds(entry):
    import classify_entries as ce
    import extract_textures as et
    import pack
    ce.load_index(pack.BLOBSET_PATH)
    raw, *_ = ce.read_blob_full(pack.BLOBSET_PATH, entry)
    return et.parse_mini_txpk(raw)[1]


def stock_dds(entry):
    """The stock DDS bytes: from pack.py's backup if the entry is already
    installed, else from the live entry."""
    import json
    import extract_textures as et
    import pack
    meta_path = pack.backup_meta_path(entry)
    if not os.path.exists(meta_path):
        return live_dds(entry)
    with open(meta_path) as f:
        m = json.load(f)
    with open(m["blob_backup"], "rb") as f:
        raw = _decode_blob(f.read(), m["main_compressed_size"], m["main_uncompressed_size"],
                           m["vram_compressed_size"], m["vram_uncompressed_size"])
    return et.parse_mini_txpk(raw)[1]


def build(entry, log=print):
    dds = stock_dds(entry)
    img = TEXTURES[entry][1](read_dds_rgba(dds))
    out = out_path(entry)
    os.makedirs(OUT_DIR, exist_ok=True)
    with open(out, "wb") as f:
        f.write(write_dds(dds, img))
    return out


def entry_state(entry):
    """'ps' if the live texture is this mod's, 'stock' if it's the game's
    own, 'stale-backup' if an update/verify reset it under our backup record,
    else 'other' (another mod replaced it)."""
    import pack
    live = live_dds(entry)
    installed = os.path.exists(pack.backup_meta_path(entry))
    if live == stock_dds(entry):
        return "stale-backup" if installed else "stock"
    if installed and os.path.exists(out_path(entry)) and live == open(out_path(entry), "rb").read():
        return "ps"
    return "other"


def state():
    """'ps' / 'stock' when every texture agrees, else a per-entry summary."""
    states = {e: entry_state(e) for e in TEXTURES}
    kinds = {"stock" if s == "stale-backup" else s for s in states.values()}
    if len(kinds) == 1:
        return kinds.pop()
    return "mixed (" + ", ".join(f"{e}={s}" for e, s in states.items()) + ")"


def _drop_stale_backup(entry, log):
    """A Steam update / verify put the stock texture back under our backup
    record. Forget the record (and its copies) so the next install works."""
    import json
    import pack
    meta_path = pack.backup_meta_path(entry)
    with open(meta_path) as f:
        m = json.load(f)
    for p in (m.get("blobset_backup"), m.get("blob_backup"), meta_path):
        if p and os.path.exists(p):
            os.remove(p)
    log(f"  {TEXTURES[entry][0]}: game files were reset (update/verify) - dropped the stale backup record")


def install(log=print):
    import pack
    import texture_mods
    done = []
    for entry, (desc, _) in TEXTURES.items():
        st = entry_state(entry)
        if st == "ps":
            continue
        if st == "other":
            log(f"  {desc}: entry {entry} was replaced by something else - not touching it")
            continue
        if st == "stale-backup":
            _drop_stale_backup(entry, log)
        dds = build(entry, log)
        blob, sizes, _ = texture_mods.build_texture_blob(pack.BLOBSET_PATH, entry, dds)
        bin_path = os.path.join(OUT_DIR, f"entry_{entry}.miniTxpk.bin")
        with open(bin_path, "wb") as f:
            f.write(blob)
        pack.do_install(pack.BLOBSET_PATH, entry, bin_path, confirm=True, sizes=sizes)
        log(f"  {desc}: PlayStation version installed (entry {entry})")
        done.append(desc)
    return "installed " + ", ".join(done) if done else "already installed"


def restore(log=print):
    import pack
    done = []
    for entry, (desc, _) in TEXTURES.items():
        st = entry_state(entry)
        if st == "stale-backup":
            _drop_stale_backup(entry, log)
        if st != "ps":
            if st == "other":
                log(f"  {desc}: entry {entry} was replaced by something else - not touching it")
            continue
        pack.do_restore(pack.BLOBSET_PATH, entry)
        log(f"  {desc}: stock version restored (entry {entry})")
        done.append(desc)
    return "restored " + ", ".join(done) if done else "already stock"


if __name__ == "__main__":
    # Preview only: builds every PS texture into _build\controller-button-icons\ without installing.
    for entry, (desc, _) in TEXTURES.items():
        path = build(entry)
        img = read_dds_rgba(open(path, "rb").read())
        bg = Image.new("RGBA", img.size, (60, 60, 60, 255))
        bg.alpha_composite(img)
        bg.save(os.path.splitext(path)[0] + "_preview.png")
        print(f"  {desc}: {path}")
