#!/usr/bin/env python3
"""
install.py - build and append the Allegiant Stadium / Rugby League Las Vegas
assets the Lua side of this mod loads by path (all NEW entries, appended with
add_entries.py; nothing shipped is modified):

  props/goalposts/textures/goalposts01_mustard_col.texture
      Mustard copy of the flat 16x16 goalposts01_white_col that the goalpost
      uprights (material goalPosts_SS) use. fieldposts.lua puts it on the
      uprights at lasVegasStadium only.

  fields/default/sponsor_field_lasvegasingoal[_flipped].model + .texpack
      Black in-goals. A clone of the stock Monday sponsor model: its two in-goal
      banner meshes become one rectangle per in-goal, inside the try line and
      dead-ball line (measured from fields/default/lines: try line x 49.95-50.15,
      dead-ball line 57.95-58.15, touchlines z +-33.95-34.15), textured solid
      near-black; every other mesh is collapsed. Drawn at lasVegasStadium only.

  The "Rugby League Las Vegas" field markings are a round in
  nrl-field-sponsor-markings' config (rounds/lasvegas.json), built and
  installed by its fieldmarkings.py; stadiumfactory.lua forces that round at
  Allegiant. (Older versions appended sponsor_field_lasvegasrugbyleague
  clones; they are no longer loaded.)

A sponsor model's texture bundle is "<model path minus .model>.texpack" (the
shipped Monday bundle's hash matches that name). The clones get their own
model name (material paths) and texture names, so no material or texture can
be shared through a path-keyed cache with a shipped model that is drawn at
the same time. All renames are same-length (plain strings, no stored hash).

Stock models/bundles are read from pack.py's backups when
nrl-field-sponsor-markings has replaced them, so this works either way.

Usage (game closed):
    python mods/las-vegas-stadium/install.py install [--confirm] [--texconv PATH]
"""

import argparse
import json
import os
import re
import struct
import subprocess
import sys
import tempfile

import numpy as np
from PIL import Image

MOD_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(os.path.dirname(MOD_DIR))
sys.path.insert(0, os.path.join(REPO_ROOT, "tools"))
import add_entries  # noqa: E402
import classify_entries as ce  # noqa: E402
import club_icons  # noqa: E402
import entries  # noqa: E402
import extract_textures as et  # noqa: E402
import games  # noqa: E402
import pack  # noqa: E402
import texture_mods  # noqa: E402

SPONSOR_MOD = os.path.join(REPO_ROOT, "mods", "nrl-field-sponsor-markings")
sys.path.insert(0, SPONSOR_MOD)
import art as bt  # noqa: E402  (art loaders, slot compositors, BC7 encode)
import models  # noqa: E402

sys.path.insert(0, MOD_DIR)
import boards  # noqa: E402
import nfl_numbers  # noqa: E402
import stadium_model  # noqa: E402

# Allegiant's LCD boards (field-level ring + stand-fascia ribbons) show
# lcd_sponsor_rugby_generic_col, which ships blank (they render black). They
# get the game's own default NRL LED ads instead: lcd_sponsor_nrl_col, the
# same bytes at every NRL ground (2048x1024 DXT1, 8 cycling 16:1 rows),
# copied verbatim into Allegiant's bundle under the generic member's path.
LCD_TEXPACK = "stadiums/lasvegasstadium/sponsors_standard_t1.texpack"
LCD_MEMBER = "stadiums/textures/sponsors/lcd/lcd_sponsor_rugby_generic_col"
NRL_LCD_TEXPACK = "stadiums/brisbane/sponsors_nrl_t1.texpack"
NRL_LCD_MEMBER = "stadiums/textures/sponsors/lcd/lcd_sponsor_nrl_col"
# The draped cloth along the foot of the stands (boards.build_cloth). A
# shipped entry; the member is replaced in place at its stock size.
CLOTH_TEXPACK = "stadiums/lasvegasstadium/stadium_t1.texpack"
CLOTH_MEMBER = "stadiums/textures/tarpa_atp250in_col"
# Its normal map (the draped swags) is replaced with a flat one, so the
# cloth and the boards (which stadium_model.py switches to the cloth's
# material) read as tight printed wraps.
CLOTH_NRM_MEMBER = "stadiums/textures/tarpa_atp250in_nrm"
# The UVs and materials are changed in the stadium model, also a shipped
# entry - stadium_model.py.
STADIUM_MODEL = "stadiums/lasvegasstadium/stadium_t1.model"
SHIPPED = (LCD_TEXPACK, CLOTH_TEXPACK, STADIUM_MODEL)

# NFL-style pitch numbers at Allegiant only: appended clones of the field lines
# model (and its _flipped twin) with their own texpacks, which
# stadiumfactory.lua draws there in place of the stock lines. Clone name ->
# stock model (its texpack is the next entry).
LINES_LAYERS = {"lines_lasvegas": entries.legacy(39878), "lines_lasvegas_flipped": entries.legacy(39880)}
# Same-length, Allegiant-only names that keep their place in the texpack's
# alphabetical member order; the material-path rename stops the clone sharing
# materials with the stock lines model loaded alongside it.
LINES_NUMBERS_RENAME = ("fields/textures/fieldmarkings_numbers_col", "fields/textures/fieldmarkings_nfl_lv0_col")
LINES_MATERIAL_RENAME = ("fields/default/lines", "fields/default/lnslv")
LINES_NUMBER_VERTS = 192  # 48 quads: digits + 16 arrows
ARROW_STRETCH = 3.0  # the arrow quads, along the pitch from the number edge (~0.7 m -> ~2.1 m)

BUILD_DIR = os.path.join(REPO_ROOT, "_build", "las-vegas-stadium")

MUSTARD_PATH = "props/goalposts/textures/goalposts01_mustard_col.texture"
MUSTARD_RGB = (225, 170, 20)  # NFL-style goalpost yellow; stock white is (217, 215, 211)

# Solid white stand-in for sponsor_alphaDetail_col (the in-goal layer's
# detail_map). The stock detail map is dark grass noise (RGB mean ~30) that
# the sponsor shader turns into coverage between g_fieldMarkings_minAlpha 0.2
# and maxAlpha 0.8, so a black decal only tinted the grass; white gives the
# full 0.8 everywhere (stadiumfactory.lua draws the layer twice: ~96%).
SOLID_DETAIL_PATH = "fields/textures/sponsors/sponsor_alphadetail_solid_col.texture"

# In-goal rectangle: 0.02 m clear of the inner edges of the try line,
# dead-ball line and touchlines, so the black never covers a line.
IN_GOAL_X = (50.17, 57.93)
IN_GOAL_Z = 33.93
# Level with the grass, like every pitch decal. Nothing else draws over the
# in-goals at Allegiant: the grass's own field markings are hidden there and
# the Las Vegas markings have no in-goal banners (stadiumfactory.lua).
IN_GOAL_Y = 0.0
IN_GOAL_RGB = (14, 14, 14)
# KFC FLG panels painted into each black in-goal - part of this layer, not the
# game's field markings (whose in-goal banners flickered over the black and
# are hidden at Allegiant). Axis-aligned and in true proportion: centres
# across the field, size (across, deep) in metres.
IN_GOAL_LOGO_Z = (-16.0, 16.0)
IN_GOAL_LOGO_SIZE = (14.0, 5.6)

_L = entries.legacy  # 1.0.5887 entry numbers -> live index (by hash)

# name -> (stock model entry, new model name, same-length model-name swap,
#          texture renames, mesh edits)
LAYERS = {
    "sponsor_field_lasvegasingoal": {
        "stock": _L(39894), "base": "mondayfootball", "swap": "lasvegasingoal",
        "renames": {"wideleft_nrlfantasy": "wideleft_vegasblack", "wideright_nrlfantasy": "wideright_vegasblack",
                    "leaguestars01": "leaguestarsv3", "kiatasman01": "kiatasmanv3", "kiatasman02": "kiatasmanv4"},
        "in_goal": ("wideLeft_NRLFantasy", "wideRight_NRLFantasy"),
        "collapse": ["leagueStars01", "kiaTasman01", "kiaTasman02"],
    },
    "sponsor_field_lasvegasingoal_flipped": {
        "stock": _L(39896), "base": "mondayfootball", "swap": "lasvegasingoal",
        "renames": {"wideleft_nrlfantasy": "wideleft_vegasblack", "wideright_nrlfantasy": "wideright_vegasblack",
                    "leaguestars01": "leaguestarsv3", "kiatasman01": "kiatasmanv3", "kiatasman02": "kiatasmanv4"},
        "in_goal": ("wideLeft_NRLFantasy", "wideRight_NRLFantasy"),
        "collapse": ["leagueStars01", "kiaTasman01", "kiaTasman02"],
    },
}


def solid(rgb):
    def make(size, _orig):
        return Image.new("RGBA", size, (*rgb, 255))
    return make


def slot_art():
    """Stock texture name (without sponsor_field_/_col) -> compositor, per layer kind."""
    kfc = bt.load_art("try-zones/kfc-logo-fb.jpg")
    return {
        "ingoal": {"wideleft_nrlfantasy": solid(IN_GOAL_RGB), "wideright_nrlfantasy": solid(IN_GOAL_RGB)},
        "kfc": kfc,
    }


# ---- stock blobs ------------------------------------------------------------

def stock_blob(entry):
    """(stored bytes, (main_c, main_u, vram_c, vram_u)) of the SHIPPED entry:
    pack.py's backup if a mod replaced it, else the live blob."""
    meta_path = pack.backup_meta_path(entry)
    if os.path.exists(meta_path):
        meta = json.load(open(meta_path))
        sizes = tuple(meta[k] for k in ("main_compressed_size", "main_uncompressed_size",
                                         "vram_compressed_size", "vram_uncompressed_size"))
        return open(meta["blob_backup"], "rb").read(), sizes
    *_, bpath = ce.read_blob_full(pack.BLOBSET_PATH, entry)
    return open(bpath, "rb").read(), pack.entry_sizes(ce._INDEX_DATA, ce._SIZE_TABLE_OFF, entry)


def stock_txpk(entry):
    """(header, payload) of a shipped TXPK, decoded with read_blob_full's
    rules: a raw component is a verbatim prefix, otherwise the whole stored
    blob is chunk-framed. Written back as main raw + vram chunk-framed (the
    layout nrl-field-sponsor-markings' install.py documents)."""
    stored, (main_c, main_u, vram_c, vram_u) = stock_blob(entry)
    if vram_u == 0:
        raise RuntimeError(f"entry {entry} has no vram component - not a TXPK bundle")
    if main_c == main_u and vram_c == vram_u:
        raw = stored
    elif main_c == main_u or vram_c == vram_u:
        raw = stored[:main_u] + ce.decode_outer_zstd_frames(stored[main_u:])
    else:
        raw = ce.decode_outer_zstd_frames(stored)
    header, payload = raw[:main_u], raw[main_u:]
    if struct.unpack_from("<I", header, 0)[0] != et.TXPK_MAGIC or len(payload) != vram_u:
        raise RuntimeError(f"entry {entry} did not decode as a TXPK")
    return header, bytearray(payload)


# ---- models -----------------------------------------------------------------

def swap_model_name(data, base, new):
    if len(base) != len(new):
        raise ValueError("model name swaps must keep the same length")
    out, n = re.subn(re.escape(base.encode()), new.encode(), bytes(data), flags=re.I)
    if n == 0:
        raise ValueError(f"model name {base} not found")
    return bytearray(out)


def in_goal_uv(x, z):
    """Where a pitch point lands in the in-goal texture: u across the field
    (z -IN_GOAL_Z..IN_GOAL_Z), v from the try-line side to the dead-ball side."""
    return ((z + IN_GOAL_Z) / (2 * IN_GOAL_Z), (abs(x) - IN_GOAL_X[0]) / (IN_GOAL_X[1] - IN_GOAL_X[0]))


def in_goal_end(spec, material):
    """+1 / -1: which end of the pitch this stock in-goal banner mesh is on
    (the _flipped twins swap them)."""
    stored, _sizes = stock_blob(spec["stock"])
    m = models.Model(models.decode(stored))
    r = m.meshes[m.mesh_for(material)]
    return 1 if np.mean([m.pos(v)[0] for v in range(r[5], r[5] + r[6])]) > 0 else -1


def in_goal_logos(sign, kfc):
    """Compositor for an in-goal texture: near-black with IN_GOAL_LOGO_SIZE
    KFC FLG panels at IN_GOAL_LOGO_Z, laid out in metres and resampled into
    the texture's uneven scale (in_goal_uv: 68 m across x 7.8 m deep), so
    they are undistorted on the pitch. They read left to right for someone on
    the field facing the in-goal, top towards the dead-ball line; on the -x
    end in_goal_uv's abs() mirrors the mapping, so the art is mirrored too.
    UV -> upright pixel is (u * w, (1 - v) * h)."""
    def make(size, _orig_upright):
        w, h = size
        out = Image.new("RGBA", size, (*IN_GOAL_RGB, 255))
        length, depth = IN_GOAL_LOGO_SIZE
        ppm = 100  # art drawn at 1 cm per pixel, then resampled
        panel = bt.fit_into(Image.new("RGBA", (int(length * ppm), int(depth * ppm)), bt.KFC_RED), kfc,
                            (int(0.4 * ppm), int(0.4 * ppm), int((length - 0.4) * ppm), int((depth - 0.4) * ppm)))
        if sign < 0:
            panel = panel.transpose(Image.FLIP_LEFT_RIGHT)
        mid = (IN_GOAL_X[0] + IN_GOAL_X[1]) / 2
        for zc in IN_GOAL_LOGO_Z:
            u0, v_top = in_goal_uv(sign * (mid + depth / 2), zc - length / 2)
            u1, v_bot = in_goal_uv(sign * (mid - depth / 2), zc + length / 2)
            box = (round(u0 * w), round((1 - v_top) * h), round(u1 * w), round((1 - v_bot) * h))
            out.alpha_composite(panel.resize((box[2] - box[0], box[3] - box[1]), Image.LANCZOS), box[:2])
        return out
    return make


def in_goal_rect(m, material):
    """Stretch the banner strip's first panel (the four corners its first two
    triangles use) over the whole in-goal on its end of the pitch, and collapse
    every other vertex onto one of those corners - the strip's remaining
    triangles then become degenerate or lie inside the rectangle.

    The banner panels are skewed (parallelograms along the touchline), so a
    corner's rectangle corner is picked per edge: try-line side or dead-ball
    side by |x|, then the lower/higher z of that pair. That keeps the
    topology, and so the winding, of the original panel."""
    k = m.mesh_for(material)
    r = m.meshes[k]
    nverts = sum(mr[6] for mr in m.meshes)
    idx = struct.unpack_from("<6H", m.d, m.uv + 4 * nverts + 2 * r[8])
    panel = sorted(set(idx))
    if len(panel) != 4:
        raise ValueError(f"{material}: first two triangles don't form one panel ({idx})")
    pos = {i: m.pos(r[5] + i) for i in panel}
    sign = 1 if pos[panel[0]][0] > 0 else -1
    by_x = sorted(panel, key=lambda i: abs(pos[i][0]))
    new = {}
    for pair, x in ((by_x[:2], sign * IN_GOAL_X[0]), (by_x[2:], sign * IN_GOAL_X[1])):
        lo, hi = sorted(pair, key=lambda i: pos[i][2])
        new[lo] = (x, IN_GOAL_Y, -IN_GOAL_Z)
        new[hi] = (x, IN_GOAL_Y, IN_GOAL_Z)
    for i, p in new.items():
        struct.pack_into("<3f", m.d, m.vb + models.VERTEX_STRIDE * (r[5] + i), *p)
        uv = m.uv + 4 * (r[5] + i)
        m.d[uv:uv + 4] = np.array(in_goal_uv(p[0], p[2]), np.float16).tobytes()
    anchor = new[panel[0]]
    # Parked vertices take the anchor corner's UV too: some leftover strip
    # triangles join two rectangle corners to a parked vertex and so cover half
    # the in-goal - with the parked vertex's stock banner UV they smeared a
    # warped copy of the texture over it (invisible on plain black, a stray
    # skewed KFC banner once the panels were painted in).
    anchor_uv = np.array(in_goal_uv(anchor[0], anchor[2]), np.float16).tobytes()
    for i in range(r[6]):
        if i not in new:
            struct.pack_into("<3f", m.d, m.vb + models.VERTEX_STRIDE * (r[5] + i), *anchor)
            uv = m.uv + 4 * (r[5] + i)
            m.d[uv:uv + 4] = anchor_uv
    lo_x, hi_x = sorted((sign * IN_GOAL_X[0], sign * IN_GOAL_X[1]))
    struct.pack_into("<6f", m.d, m.bboxes + 24 * k, lo_x, 0.0, -IN_GOAL_Z, hi_x, 0.0, IN_GOAL_Z)


def build_model(name, spec):
    stored, sizes = stock_blob(spec["stock"])
    if sizes[0] != len(stored) or sizes[2] != 0:
        raise RuntimeError(f"stock model {spec['stock']} has unexpected sizes {sizes}")
    m = models.Model(models.decode(stored))
    if spec.get("move_badge"):
        m.move_badge_opposite()
    for material in spec.get("full_uv", []):
        m.full_uv(material)
    for material in spec.get("in_goal", []):
        in_goal_rect(m, material)
    for material in spec.get("collapse", []):
        m.collapse(material)
    for old, new in spec["renames"].items():
        m.rename_texture(f"sponsor_field_{old}_col", f"sponsor_field_{new}_col")
    m.d = swap_model_name(m.d, spec["base"], spec["swap"])
    return models.encode(m.bytes())


# ---- texture bundles --------------------------------------------------------

def member_table(header):
    """{member path without .dds: (data_off, data_size, path_off)}."""
    count = struct.unpack_from("<I", header, 4)[0]
    out = {}
    for i in range(count):
        path_off, _size, data_off, data_size = struct.unpack_from("<4I", header, 8 + i * 16)
        end = header.index(b"\x00", path_off + 20)
        out[header[path_off + 20:end].decode("latin1").replace("\\", "/")] = (data_off, data_size)
    return out


def build_texpack(spec, slots, texconv, tmp, previews, label):
    header, payload = stock_txpk(spec["stock"] + 1)
    table = member_table(header)
    for old, make in slots.items():
        key = f"fields/textures/sponsors/sponsor_field_{old}_col"
        if key not in table:
            raise RuntimeError(f"bundle {spec['stock'] + 1} has no member {key}")
        off, size = table[key]
        orig = bytes(payload[off:off + size])
        w, h = int.from_bytes(orig[16:20], "little"), int.from_bytes(orig[12:16], "little")
        with open(os.path.join(tmp, "orig.dds"), "wb") as f:
            f.write(orig)
        orig_upright = Image.open(os.path.join(tmp, "orig.dds")).convert("RGBA").transpose(Image.FLIP_TOP_BOTTOM)
        dds = bt.encode_like(orig, make((w, h), orig_upright), texconv, tmp)
        payload[off:off + size] = dds
        if label:
            previews.append((f"{label}: {old}", dds))
    for old, new in spec["renames"].items():
        old_b, new_b = f"/sponsor_field_{old}_col\x00".encode(), f"/sponsor_field_{new}_col\x00".encode()
        if header.count(old_b) != 1:
            raise RuntimeError(f"bundle {spec['stock'] + 1}: expected one member named {old}")
        header = header.replace(old_b, new_b)
    vram = texture_mods.encode_outer_chunks(bytes(payload))
    return header + vram, (len(header), len(header), len(vram), len(payload))


def build_flat(path, rgb, alpha=255):
    """16x16 uncompressed BGRA texture of one colour."""
    img = Image.new("RGBA", (16, 16), (*rgb, alpha))
    header = bytearray(128)
    struct.pack_into("<4s7I", header, 0, b"DDS ", 124, 0x100F, 16, 16, 16 * 4, 1, 0)
    struct.pack_into("<2I4s5I", header, 76, 32, 0x41, b"\0\0\0\0", 32, 0xFF0000, 0xFF00, 0xFF, 0xFF000000)
    struct.pack_into("<I", header, 108, 0x1000)
    return club_icons.make_blob(path, bytes(header) + img.tobytes("raw", "BGRA"))


def _numbers_stream(d):
    """Offset of the lines model's numbers vertex stream: LINES_NUMBER_VERTS
    32-byte vertices (on the ground, |x| < 45, |z| < 21) directly followed by
    their half2 UVs, 16 quads of which map the arrow cell. Found by content -
    the _flipped twin's strings shift it."""
    n = LINES_NUMBER_VERTS
    for off in range(0x400, len(d) - 36 * n, 1):
        if struct.unpack_from("<f", d, off + 4)[0] != 0.0:
            continue
        try:
            pos = np.frombuffer(bytes(d[off:off + 32 * n]), np.float32).reshape(n, 8)[:, :3]
        except ValueError:
            continue
        if not (np.isfinite(pos).all() and (pos[:, 1] == 0).all() and np.abs(pos[:, 0]).max() < 45
                and np.abs(pos[:, 2]).max() < 21):
            continue
        uv = np.frombuffer(bytes(d[off + 32 * n:off + 36 * n]), np.float16).reshape(n, 2).astype(float)
        arrows = [q for q in range(0, n, 4) if 0.74 < uv[q:q + 4, 0].min() and uv[q:q + 4, 0].max() < 0.92]
        if len(arrows) == 16:
            return off, uv, arrows
    raise RuntimeError("lines model: numbers stream not found")


def build_lines_model(entry):
    stored, sizes = stock_blob(entry)
    if sizes[0] != len(stored) or sizes[2] != 0:
        raise RuntimeError(f"stock lines model {entry} has unexpected sizes {sizes}")
    d = bytearray(models.decode(stored))
    off, uv, arrows = _numbers_stream(d)
    for q in arrows:  # stretch each arrow: base edge (u ~0.76) stays, tip edge (u ~0.90) moves out
        base = [v for v in range(q, q + 4) if uv[v, 0] < 0.83]
        tip = [v for v in range(q, q + 4) if uv[v, 0] >= 0.83]
        bx = struct.unpack_from("<f", d, off + 32 * base[0])[0]
        for v in tip:
            x = struct.unpack_from("<f", d, off + 32 * v)[0]
            struct.pack_into("<f", d, off + 32 * v, bx + (x - bx) * ARROW_STRETCH)
    old, new = (x.encode() + bytes(1) for x in LINES_NUMBERS_RENAME)
    if d.count(old) != 1:
        raise RuntimeError("lines model: expected one numbers texture reference")
    d = bytearray(bytes(d).replace(old, new))
    old_m, new_m = (x.encode() for x in LINES_MATERIAL_RENAME)
    if d.count(old_m) < 3:
        raise RuntimeError("lines model: material paths not found")
    d = bytearray(bytes(d).replace(old_m, new_m))
    return models.encode(bytes(d))


def build_lines_texpack(entry, texconv, tmp):
    """The stock lines texpack with the NFL numbers atlas (nfl_numbers.build)
    BC7-encoded over the numbers member, renamed to LINES_NUMBERS_RENAME."""
    header, payload = stock_txpk(entry)
    table = member_table(header)
    off, size = table[LINES_NUMBERS_RENAME[0]]
    payload[off:off + size] = bt.encode_like(bytes(payload[off:off + size]), nfl_numbers.build(), texconv, tmp)
    old, new = (x.encode() + bytes(1) for x in LINES_NUMBERS_RENAME)
    if header.count(old) != 1:
        raise RuntimeError("lines texpack: expected one numbers member")
    header = bytes(header).replace(old, new)
    vram = texture_mods.encode_outer_chunks(bytes(payload))
    return header + vram, (len(header), len(header), len(vram), len(payload))


def build_lcd_texpack(texconv, tmp):
    """Allegiant's sponsors_standard bundle with the stock NRL LED texture,
    re-laid out one line per sponsor (boards.nrl_led_single_line), in place
    of the blank generic one. Same member order and paths; only the LCD
    member's table size and its 20-byte prefix (width, height, size)
    change, and it keeps its stock data offset, so ledbulb is untouched."""
    nrl_header, nrl_payload = stock_txpk(entries.index_of(NRL_LCD_TEXPACK))
    off, size = member_table(nrl_header)[NRL_LCD_MEMBER]
    orig = bytes(nrl_payload[off:off + size])
    if orig[84:88] != b"DXT1":
        raise RuntimeError(f"{NRL_LCD_MEMBER} is not DXT1")
    w, h = int.from_bytes(orig[16:20], "little"), int.from_bytes(orig[12:16], "little")
    mips = int.from_bytes(orig[28:32], "little")
    with open(os.path.join(tmp, "nrl_led.dds"), "wb") as f:
        f.write(orig)
    upright = Image.open(os.path.join(tmp, "nrl_led.dds")).convert("RGB").transpose(Image.FLIP_TOP_BOTTOM)
    src = os.path.join(tmp, "nrl_led_single.png")
    boards.nrl_led_single_line(upright).transpose(Image.FLIP_TOP_BOTTOM).save(src)
    subprocess.run([texconv, "-nologo", "-y", "-f", "BC1_UNORM", "-m", str(mips), "--ignore-srgb", "-o", tmp, src],
                   check=True, stdout=subprocess.DEVNULL)
    dds = open(os.path.join(tmp, "nrl_led_single.dds"), "rb").read()
    if dds[84:88] != b"DXT1" or len(dds) != len(orig):
        raise RuntimeError(f"encoded LED texture is {len(dds)} bytes ({dds[84:88]}), stock is {len(orig)}")
    entry = entries.index_of(LCD_TEXPACK)
    header, payload = stock_txpk(entry)
    header = bytearray(header)
    count = struct.unpack_from("<I", header, 4)[0]
    for i in range(count):
        path_off, path_size, data_off, data_size = struct.unpack_from("<4I", header, 8 + 16 * i)
        if header[path_off + 20:path_off + path_size - 1].decode("latin1") == LCD_MEMBER:
            break
    else:
        raise RuntimeError(f"{LCD_TEXPACK} has no member {LCD_MEMBER}")
    if data_off + data_size != len(payload):
        raise RuntimeError("the LCD member is not the last one in the bundle")
    struct.pack_into("<I", header, 8 + 16 * i + 12, len(dds))
    struct.pack_into("<5I", header, path_off, w, h, 1, 20, len(dds))
    payload = bytes(payload[:data_off]) + dds
    vram = texture_mods.encode_outer_chunks(payload)
    return entry, bytes(header) + vram, (len(header), len(header), len(vram), len(payload))


def build_stadium_model():
    """Allegiant's stadium model with the cloth, boards and tunnel walls
    re-mapped (see stadium_model.py). Stored like stock: main compressed as
    outer chunk frames, no vram."""
    entry = entries.index_of(STADIUM_MODEL)
    stored, (main_c, main_u, vram_c, vram_u) = stock_blob(entry)
    if vram_u != 0 or main_c == main_u:
        raise RuntimeError(f"{STADIUM_MODEL}: unexpected sizes {main_c, main_u, vram_c, vram_u}")
    raw = bytearray(ce.decode_outer_zstd_frames(stored))
    if len(raw) != main_u:
        raise RuntimeError(f"{STADIUM_MODEL} did not decode to {main_u} bytes")
    done = stadium_model.remap(raw, boards.CLOTH_ASPECT)
    blob = texture_mods.encode_outer_chunks(bytes(raw))
    if ce.decode_outer_zstd_frames(blob) != bytes(raw):
        raise RuntimeError("stadium model did not round-trip")
    return entry, blob, (len(blob), len(raw), 0, 0), done


def build_cloth_texpack(texconv, tmp):
    """Allegiant's stadium bundle with the cloth wrap (boards.build_cloth)
    BC1-encoded over tarpa_atp250in_col and a flat BC5 normal map over its
    _nrm member - each at its stock size and mip count, so nothing else
    moves."""
    entry = entries.index_of(CLOTH_TEXPACK)
    header, payload = stock_txpk(entry)
    table = member_table(header)
    for member in (CLOTH_MEMBER, CLOTH_NRM_MEMBER):
        if member not in table:
            raise RuntimeError(f"{CLOTH_TEXPACK} has no member {member}")

    def flat_normal(member):
        off, size = table[member]
        orig = bytes(payload[off:off + size])
        if orig[84:88] != b"DX10" or int.from_bytes(orig[128:132], "little") != 83:
            raise RuntimeError(f"{member} is not BC5")
        w, h = int.from_bytes(orig[16:20], "little"), int.from_bytes(orig[12:16], "little")
        src = os.path.join(tmp, "flat_nrm.png")
        Image.new("RGB", (w, h), (128, 128, 255)).save(src)
        subprocess.run([texconv, "-nologo", "-y", "-f", "BC5_UNORM", "-m", str(int.from_bytes(orig[28:32], "little")),
                        "-o", tmp, src], check=True, stdout=subprocess.DEVNULL)
        new = open(os.path.join(tmp, "flat_nrm.dds"), "rb").read()
        new_payload = new[bt.dds_header_len(new):]  # texconv writes BC5 with a legacy (128-byte) header
        if len(new_payload) != size - 148:
            raise RuntimeError(f"{member}: flat normal payload {len(new_payload)} != {size - 148}")
        payload[off:off + size] = orig[:148] + new_payload

    def bc1(member, upright, name):
        off, size = table[member]
        orig = bytes(payload[off:off + size])
        if orig[84:88] != b"DXT1":
            raise RuntimeError(f"{member} is not DXT1")
        src = os.path.join(tmp, f"{name}.png")
        upright.transpose(Image.FLIP_TOP_BOTTOM).save(src)  # stored V-flipped
        subprocess.run([texconv, "-nologo", "-y", "-f", "BC1_UNORM", "-m", str(int.from_bytes(orig[28:32], "little")),
                        "--ignore-srgb", "-o", tmp, src], check=True, stdout=subprocess.DEVNULL)
        new = open(os.path.join(tmp, f"{name}.dds"), "rb").read()
        if len(new) != size or new[84:88] != b"DXT1":
            raise RuntimeError(f"{member}: encoded {len(new)} bytes, member is {size}")
        payload[off:off + size] = orig[:128] + new[128:]

    flat_normal(CLOTH_NRM_MEMBER)
    bc1(CLOTH_MEMBER, boards.build_cloth(), "cloth")
    vram = texture_mods.encode_outer_chunks(bytes(payload))
    return entry, bytes(header) + vram, (len(header), len(header), len(vram), len(payload))


def install_shipped(blobset, entry, blob, sizes, name):
    out = os.path.join(BUILD_DIR, f"{name}.bin")
    with open(out, "wb") as f:
        f.write(blob)
    if os.path.exists(pack.backup_meta_path(entry)):
        pack.do_restore(blobset, entry)
    pack.do_install(blobset, entry, out, confirm=True, sizes=sizes)
    print(f"  installed {name} into entry {entry}")


def save_preview(previews):
    from PIL import ImageDraw
    tiles = []
    for name, dds in previews:
        path = os.path.join(BUILD_DIR, "_preview.dds")
        with open(path, "wb") as f:
            f.write(dds)
        im = Image.open(path).convert("RGBA").transpose(Image.FLIP_TOP_BOTTOM)
        im.thumbnail((400, 200))
        bg = Image.new("RGBA", (410, 230), (46, 110, 46, 255))
        bg.alpha_composite(im, (5, 25))
        ImageDraw.Draw(bg).text((5, 5), name, fill=(255, 255, 0, 255))
        tiles.append(bg)
    os.remove(os.path.join(BUILD_DIR, "_preview.dds"))
    sheet = Image.new("RGB", (410 * 3, 230 * ((len(tiles) + 2) // 3)))
    for i, t in enumerate(tiles):
        sheet.paste(t, ((i % 3) * 410, (i // 3) * 230))
    sheet.save(os.path.join(BUILD_DIR, "preview.png"))


def cmd_install(args):
    texconv = os.path.abspath(args.texconv or games.toolchain("texconv", "texconv.exe"))
    if not os.path.exists(texconv):
        raise SystemExit("texconv.exe not found - pass --texconv")
    ce.load_index(args.blobset)
    os.makedirs(BUILD_DIR, exist_ok=True)
    art = slot_art()
    builds = [(MUSTARD_PATH, *build_flat(MUSTARD_PATH, MUSTARD_RGB), "las-vegas-stadium mustard goalposts"),
              (SOLID_DETAIL_PATH, *build_flat(SOLID_DETAIL_PATH, (255, 255, 255)),
               "las-vegas-stadium solid in-goal detail map")]
    previews = []
    with tempfile.TemporaryDirectory() as tmp:
        for name, spec in LAYERS.items():
            model, msizes = build_model(name, spec)
            label = None if name.endswith("_flipped") else "ingoal"
            slots = {old: in_goal_logos(in_goal_end(spec, material), art["kfc"])
                     for old, material in (("wideleft_nrlfantasy", "wideLeft_NRLFantasy"),
                                           ("wideright_nrlfantasy", "wideRight_NRLFantasy"))}
            txpk, tsizes = build_texpack(spec, slots, texconv, tmp, previews, label)
            builds.append((f"fields/default/{name}.model", model, msizes, f"las-vegas-stadium {name} model"))
            builds.append((f"fields/default/{name}.texpack", txpk, tsizes, f"las-vegas-stadium {name} textures"))
            print(f"  built {name}")
        shipped = [(*build_cloth_texpack(texconv, tmp), "stadium textures"),
                   (*build_lcd_texpack(texconv, tmp), "NRL LED boards")]
        model_entry, model_blob, model_sizes, done = build_stadium_model()
        shipped.append((model_entry, model_blob, model_sizes, "stadium model"))
        for name, entry in LINES_LAYERS.items():
            model, msizes = build_lines_model(entry)
            txpk, tsizes = build_lines_texpack(entry + 1, texconv, tmp)
            builds.append((f"fields/default/{name}.model", model, msizes, f"las-vegas-stadium {name} model"))
            builds.append((f"fields/default/{name}.texpack", txpk, tsizes, f"las-vegas-stadium {name} textures"))
            print(f"  built {name}")
        for entry, _blob, _sizes, name in shipped:
            print(f"  built {name} (entry {entry})")
        print("  re-mapped submeshes (components): " + ", ".join(f"{s} ({c})" for s, c in done))
    save_preview(previews)
    boards.build_cloth().save(os.path.join(BUILD_DIR, "cloth.png"))
    for path, blob, sizes, desc in builds:
        add_entries.add_entry(args.blobset, path, blob, sizes, desc, args.confirm, replace=True)
    if not args.confirm:
        print(f"Dry run - pass --confirm to install. Previews in {BUILD_DIR}")
        return
    for entry, blob, sizes, name in shipped:
        install_shipped(args.blobset, entry, blob, sizes, name)


def cmd_restore(args):
    """Put Allegiant's stock bundles and stadium model back (the appended
    entries stay; they are unused once this mod's Lua is gone)."""
    for path in SHIPPED:
        entry = entries.index_of(path)
        if os.path.exists(pack.backup_meta_path(entry)):
            pack.do_restore(args.blobset, entry)
            print(f"  restored {entry} ({path})")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--blobset", default=pack.BLOBSET_PATH)
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("install")
    p.add_argument("--confirm", action="store_true")
    p.add_argument("--texconv", help="texconv.exe (default: the bundled toolchain one)")
    p.set_defaults(func=cmd_install)
    sub.add_parser("restore").set_defaults(func=cmd_restore)
    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
