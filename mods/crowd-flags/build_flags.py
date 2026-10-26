#!/usr/bin/env python3
"""
build_flags.py - waving flags held by crowd fans (RLL4 had them, RL26 doesn't).

RL26's crowd has no flag prop, but its shared 93-joint rig still carries ten
spare joints, flagSmall_joint01..10, that no clip animates. This tool builds:

  model    a new crowd prop, crowd/characters/models/prop_flagSmall.model: a
           pole skinned to RightHand and a double-sided cloth skinned across
           the ten flag joints. It's a copy of prop_camera02 (entry 39167)
           with the geometry swapped (see the format notes below).
  bank     entry 39122, the crowd's baked animation, with the ten flag joint
           rows rewritten for every frame: the right hand's motion composed
           with a travelling wave about the pole, a whole number of wave
           cycles per clip so the loops are seamless.
  teams    a flag texture (512x512 DXT1 + mips) per distinct club emblem +
           colours in the installed club data, plus a red/yellow tint-mask
           default, as new entries, and the club id -> texture table in
           crowd_archetypes.lua. Like every crowd texture they must also be
           in the crowd texture table (entry 39871), or the match load
           aborts: run crowd-team-kits' `bake_crowd_jerseys.py register
           --confirm` afterwards.
  preview  renders the posed flag on a fan over a few frames (no game writes).

Crowd model format (0xFEDCBA02, reverse-engineered 2026-10-24): u32 magic, u32
section count (12), then 12 self-relative int32s to the sections:
  0 stream names {1, 4, rel -> "crowdStreamSkinned"}
  1 vertex buffer {1, 4, 1, 0, byte size, stride 36, ...}
  2 index buffer {1, 4, byte offset in section 10 (16-aligned), 2, count}
  4 per-LOD bounds: count, rel ptrs, 6 floats (min xyz, max xyz) each
  5 nodes: count x 72 B {rel name, parent, mat4}
  6 meshes: count, rel ptrs, 12 ints {0,0,0, node, lod, lod, max weights,
    vertex start, vertex count, -1, index start, index count}
  8 skeleton: 94 joints x 160 B {rel name, parent, 6 floats, mat4 inverse
    bind, mat4 bind}, same order as the animation bank's rows
  9 strings, 10 vertex + index data, 11 material (self-contained block)
Vertex (36 B): pos xyz + u (f16 x4), normal xyz + v (f16 x4), tangent
(snorm16 x4), weights (u16 x4, sum 65535), bone indices (u8 x4). Texture row
= v * height (checked against the crowd t-shirt's UV mask). Positions are in
bind (model) space; bank rows are skinning deltas.

Animation bank (entry 39122): main = 3000 B header {u32 total frames 10233,
frames x 94, joints 93, ?, clips 103, ?, then per clip u32 start | end << 16
and u32 frame count}; vram = 10233 x 94 rows of {quat xyzw, pos xyz, 1} f32,
row k = skeleton joint k. A posed vertex is sum(w * (rotate(q, p) + t)).

    python mods\\crowd-flags\\build_flags.py preview
    python mods\\crowd-flags\\build_flags.py model   [--confirm]
    python mods\\crowd-flags\\build_flags.py teams   [--confirm]
    python mods\\crowd-flags\\build_flags.py bank    [--confirm]
"""

import argparse
import io
import math
import os
import struct
import sys

import numpy as np
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import add_entries as ae  # noqa: E402
import classify_entries as ce  # noqa: E402
import club_icons  # noqa: E402
import extract_textures as et  # noqa: E402
import pack  # noqa: E402
import texture_mods  # noqa: E402

WORK = os.path.join(ROOT, "_build", "crowd-flags")
TEMPLATE_MODEL = 39167          # crowd/characters/models/prop_camera02.model
BANK_ENTRY = 39122              # crowd animation bank
MODEL_PATH = "crowd/characters/models/prop_flagSmall.model"
TEXTURE_DIR = "crowd/characters/textures"
STOCK_512_COL = "crowd_scarf01_default01_col"   # header donor for 512x512 DXT1 + mips

HAND = 64                       # RightHand
HAND_MIDDLE = 69                # RightInHandMiddle, for the grip point
FLAG_JOINTS = list(range(2, 12))  # flagSmall_joint01..10
SEGMENTS = len(FLAG_JOINTS)

# Flag shape (metres, bind space)
POLE_BELOW, POLE_ABOVE, POLE_RADIUS = 0.10, 0.78, 0.007
CLOTH_WIDTH, CLOTH_HEIGHT = 0.52, 0.34
TEX_FLAG_ROWS = 448 / 512       # texture rows [0, this) hold the flag art; below is the pole colour
POLE_UV = (0.5, 0.95)

# Wave
FPS = 30.0
WAVE_HZ = 1.4
WAVE_K = 0.75                   # phase lag per segment (rad)
WAVE_AMP0, WAVE_AMP1 = 0.10, 0.22   # per-segment bend amplitude at the pole / at the free end (rad)
FLUTTER_AMP = 0.05              # secondary vertical ripple (rad per segment)
DROOP = 0.035                   # constant downward bend per segment (rad)

# Per-LOD geometry: (cloth columns, cloth rows, pole sides). The template's
# max-weights per LOD are 4,3,2,2,1,1,1; from LOD 4 the columns sit exactly
# on the joints so one weight is exact.
LODS = [(20, 6, 8), (16, 5, 6), (10, 4, 6), (10, 3, 5), (10, 2, 4), (5, 1, 3), (5, 1, 3)]


# ---- game data ----------------------------------------------------------------

def read_entry(entry):
    ce.load_index(pack.BLOBSET_PATH)
    return ce.read_blob_full(pack.BLOBSET_PATH, entry)[0]


def sections(model):
    if struct.unpack_from("<I", model, 0)[0] != 0xFEDCBA02:
        raise SystemExit("not a crowd model")
    n = struct.unpack_from("<I", model, 4)[0]
    return [8 + 4 * i + struct.unpack_from("<i", model, 8 + 4 * i)[0] for i in range(n)]


def rel_targets(model, table):
    n = struct.unpack_from("<I", model, table)[0]
    return [table + 4 + 4 * k + struct.unpack_from("<i", model, table + 4 + 4 * k)[0] for k in range(n)]


def skeleton(model):
    """[(name, parent, bind 4x4 row-vector matrix)] in bank-row order."""
    sk = sections(model)[8]
    count = struct.unpack_from("<I", model, sk + 16)[0]
    joints = []
    for i in range(count):
        a = sk + 20 + 160 * i
        rel, parent = struct.unpack_from("<ii", model, a)
        name = model[a + rel:model.index(b"\0", a + rel)].decode()
        bind = np.array(struct.unpack_from("<16f", model, a + 8 + 24 + 64), np.float64).reshape(4, 4)
        joints.append((name, parent, bind))
    return joints


def load_bank(raw=None):
    raw = raw if raw is not None else read_entry(BANK_ENTRY)
    total, slots, joints = struct.unpack_from("<3I", raw, 0)
    if slots != total * 94 or joints != 93:
        raise SystemExit("unexpected crowd animation bank header")
    nclips = struct.unpack_from("<I", raw, 16)[0]
    clips = []
    for k in range(nclips):
        packed = struct.unpack_from("<I", raw, 28 + 8 * k)[0]
        clips.append((packed & 0xFFFF, packed >> 16))
    head = len(raw) - total * 94 * 32
    rows = np.frombuffer(raw, np.float32, total * 94 * 8, head).reshape(total, 94, 8).copy()
    if clips[-1][1] != total or clips[0][0] != 0:
        raise SystemExit("unexpected clip table")
    return raw[:head], rows, clips


# ---- quaternions (x, y, z, w) -------------------------------------------------

def qmul(a, b):
    ax, ay, az, aw = np.moveaxis(a, -1, 0)
    bx, by, bz, bw = np.moveaxis(b, -1, 0)
    return np.stack([aw * bx + ax * bw + ay * bz - az * by,
                     aw * by - ax * bz + ay * bw + az * bx,
                     aw * bz + ax * by - ay * bx + az * bw,
                     aw * bw - ax * bx - ay * by - az * bz], -1)


def qrot(q, v):
    u, w = q[..., :3], q[..., 3:4]
    t = 2 * np.cross(u, v)
    return v + w * t + np.cross(u, t)


def qaxis(axis, angle):
    angle = np.asarray(angle, np.float64)[..., None]
    return np.concatenate([np.sin(angle / 2) * axis, np.cos(angle / 2)], -1)


# ---- flag frame ---------------------------------------------------------------

def flag_frame(joints, rows):
    """Grip point, pole direction d and cloth direction c in bind space: d is
    the direction that, carried by the hand, points most upward on average
    over every frame; c (the cloth) the one pointing most sideways, so the
    flag faces the pitch."""
    grip = (joints[HAND][2][3, :3] + joints[HAND_MIDDLE][2][3, :3]) / 2
    q = rows[:, HAND, :4].astype(np.float64)
    inv = q * np.array([-1, -1, -1, 1])
    d = qrot(inv, np.array([0.0, 1.0, 0.0])).mean(0)
    d /= np.linalg.norm(d)
    c = qrot(inv, np.array([-1.0, 0.0, 0.0])).mean(0)
    c -= d * (c @ d)
    c /= np.linalg.norm(c)
    return grip, d, c, np.cross(c, d)


# ---- geometry -----------------------------------------------------------------

def build_lod(frame, cols, nrows, sides, max_weights):
    """Vertices (pos, nrm, tan(4), uv, bones(4), weights(4)) and triangles."""
    grip, d, c, n = frame
    verts, tris = [], []

    def add(p, nr, tg, uv, infl):
        infl = sorted(infl, key=lambda x: -x[1])[:max_weights]
        s = sum(w for _, w in infl)
        infl = [(b, w / s) for b, w in infl]
        verts.append((p, nr, tg, uv, infl))
        return len(verts) - 1

    # pole: open cylinder plus a top cap, rigid on the hand
    e1 = c
    e2 = np.cross(d, c)
    base = len(verts)
    for k in range(sides + 1):
        a = 2 * math.pi * k / sides
        radial = math.cos(a) * e1 + math.sin(a) * e2
        tangent = -math.sin(a) * e1 + math.cos(a) * e2
        for h in (-POLE_BELOW, POLE_ABOVE):
            add(grip + d * h + radial * POLE_RADIUS, radial, (*tangent, 1.0), POLE_UV, [(HAND, 1.0)])
    for k in range(sides):
        a, b = base + 2 * k, base + 2 * (k + 1)
        tris += [(a, b, a + 1), (b, b + 1, a + 1)]
    top = add(grip + d * (POLE_ABOVE + POLE_RADIUS), d, (*c, 1.0), POLE_UV, [(HAND, 1.0)])
    for k in range(sides):
        tris.append((base + 2 * k + 1, base + 2 * (k + 1) + 1, top))

    # cloth: columns along c (u), rows down the pole (v); influences blend
    # the neighbouring chain joints (joint 0 = the pole itself, i.e. the hand)
    top_y = POLE_ABOVE - 0.01
    for side, sign in ((0, 1.0), (1, -1.0)):
        start = len(verts)
        for i in range(cols + 1):
            u = i / cols
            seg = u * SEGMENTS
            j0 = min(int(seg), SEGMENTS - 1)
            f = seg - j0
            bones = [HAND if j0 == 0 else FLAG_JOINTS[j0 - 1], FLAG_JOINTS[j0]]
            infl = [(bones[0], 1 - f), (bones[1], f)] if f > 1e-6 else [(bones[0], 1.0)]
            infl = [(b, w) for b, w in infl if w > 1e-6]
            # the back face runs u the other way, so the flag reads correctly from both sides
            tex_u = u if side == 0 else 1 - u
            for r in range(nrows + 1):
                v = r / nrows
                p = grip + d * (top_y - v * CLOTH_HEIGHT) + c * (u * CLOTH_WIDTH)
                add(p, n * sign, (*(c * sign), 1.0), (tex_u, v * TEX_FLAG_ROWS), infl)
        for i in range(cols):
            for r in range(nrows):
                a = start + i * (nrows + 1) + r
                b = a + nrows + 1
                quad = [(a, b, a + 1), (b, b + 1, a + 1)]
                tris += quad if side == 0 else [(x, z, y) for x, y, z in quad]
    return verts, tris


def encode_vertices(verts):
    out = bytearray()
    for p, nr, tg, uv, infl in verts:
        out += np.array([*p, uv[0], *nr, uv[1]], np.float16).tobytes()
        out += np.clip(np.round(np.array(tg) * 32767), -32767, 32767).astype(np.int16).tobytes()
        weights = [round(w * 65535) for _, w in infl]
        weights[0] += 65535 - sum(weights)
        bones = [b for b, _ in infl]
        weights += [0] * (4 - len(weights))
        bones += [0] * (4 - len(bones))
        out += struct.pack("<4H4B", *weights, *bones)
    return bytes(out)


def build_model(template, frame):
    sec = sections(template)
    meshes = rel_targets(template, sec[6])
    bounds = rel_targets(template, sec[4])
    if len(meshes) != len(LODS) or len(bounds) != len(LODS):
        raise SystemExit("template doesn't have 7 LODs")
    out = bytearray(template[:sec[10]])
    vbuf, ibuf = bytearray(), bytearray()
    vstart = istart = 0
    for k, (rec, box, (cols, nrows, sides)) in enumerate(zip(meshes, bounds, LODS)):
        fields = list(struct.unpack_from("<12i", template, rec))
        verts, tris = build_lod(frame, cols, nrows, sides, fields[6])
        vbuf += encode_vertices(verts)
        ibuf += np.array(tris, np.uint16).tobytes()
        fields[7:12] = [vstart, len(verts), -1, istart, 3 * len(tris)]
        struct.pack_into("<12i", out, rec, *fields)
        P = np.array([v[0] for v in verts])
        struct.pack_into("<6f", out, box, *P.min(0), *P.max(0))
        vstart += len(verts)
        istart += 3 * len(tris)
    ioff = (len(vbuf) + 15) & ~15
    struct.pack_into("<I", out, sec[1] + 16, len(vbuf))
    struct.pack_into("<I", out, sec[2] + 8, ioff)
    struct.pack_into("<I", out, sec[2] + 16, istart)
    data = bytes(vbuf) + b"\0" * (ioff - len(vbuf)) + bytes(ibuf)
    out += data
    material = template[sec[11]:]
    struct.pack_into("<i", out, 8 + 4 * 11, len(out) - (8 + 4 * 11))
    out += material
    return bytes(out)


# ---- animation ----------------------------------------------------------------

def wave_rows(frame, rows, clips):
    """New flag joint rows (frames x 10 x 8) for every frame of the bank."""
    grip, d, c, n = frame
    total = rows.shape[0]
    seg_len = CLOTH_WIDTH / SEGMENTS
    pivot = grip + d * (POLE_ABOVE - 0.01)
    rng = np.random.default_rng(26)
    tau = np.zeros(total)
    for s, e in clips:
        length = e - s
        cycles = max(1, round(length / FPS * WAVE_HZ))
        tau[s:e] = 2 * math.pi * cycles * np.arange(length) / length + rng.uniform(0, 2 * math.pi)
    i = np.arange(1, SEGMENTS + 1)
    amp = WAVE_AMP0 + (WAVE_AMP1 - WAVE_AMP0) * (i - 1) / (SEGMENTS - 1)
    yaw = np.cumsum(amp * np.sin(tau[:, None] - WAVE_K * i), axis=1)                  # about the pole
    pitch = np.cumsum(-DROOP + FLUTTER_AMP * np.sin(2 * tau[:, None] - 1.3 * WAVE_K * i), axis=1)
    hinges = np.zeros((total, SEGMENTS, 3))
    rots = np.zeros((total, SEGMENTS, 4))
    prev = np.broadcast_to(pivot, (total, 3)).copy()
    for j in range(SEGMENTS):
        # each segment: pitch about the cloth normal (droop + ripple), then yaw about the pole
        r = qmul(qaxis(d, yaw[:, j]), qaxis(n, pitch[:, j]))
        hinges[:, j] = prev
        rots[:, j] = r
        prev = prev + qrot(r, np.broadcast_to(c * seg_len, (total, 3)))
    # W_j maps bind point p to R_j (p - b_j) + h_j, where b_j is joint j's bind
    # hinge (pivot + c * j * seg_len) and h_j the posed one; then the hand row.
    qh = rows[:, HAND, :4].astype(np.float64)
    th = rows[:, HAND, 4:7].astype(np.float64)
    out = np.zeros((total, SEGMENTS, 8), np.float32)
    for j in range(SEGMENTS):
        b = pivot + c * (j * seg_len)
        r = rots[:, j]
        tw = hinges[:, j] - qrot(r, np.broadcast_to(b, (total, 3)))
        q = qmul(qh, r)
        t = qrot(qh, tw) + th
        out[:, j, :4] = q / np.linalg.norm(q, axis=1, keepdims=True)
        out[:, j, 4:7] = t
        out[:, j, 7] = 1.0
    return out


def check_flag_joints_unused():
    """Refuse to patch the bank if any stock crowd model is skinned to the flag joints."""
    ce.load_index(pack.BLOBSET_PATH)
    data, count, hash_off, _ = pack.read_index(pack.BLOBSET_PATH)
    bad = []
    for e in range(39123, 39168):
        raw = ce.read_blob_full(pack.BLOBSET_PATH, e)[0]
        if raw is None or struct.unpack_from("<I", raw, 0)[0] != 0xFEDCBA02:
            continue
        sec = sections(raw)
        nv = struct.unpack_from("<I", raw, sec[1] + 16)[0] // 36
        V = np.frombuffer(raw, np.uint8, nv * 36, sec[10]).reshape(nv, 36)
        w = V[:, 24:32].copy().view(np.uint16)
        b = V[:, 32:36]
        used = np.isin(b, FLAG_JOINTS) & (w > 0)
        if used.any():
            bad.append(e)
    if bad:
        raise SystemExit(f"stock crowd models skinned to the flag joints: {bad} - not patching the bank")


# ---- preview ------------------------------------------------------------------

def skin(verts, rows, f):
    P = np.array([v[0] for v in verts])
    out = np.zeros_like(P)
    for k, (p, *_rest) in enumerate(verts):
        infl = verts[k][4]
        for b, w in infl:
            out[k] += w * (qrot(rows[f, b, :4].astype(np.float64), p) + rows[f, b, 4:7])
    return out


def model_lod0_points(entry, rows, f):
    raw = read_entry(entry)
    sec = sections(raw)
    rec = rel_targets(raw, sec[6])[0]
    fields = struct.unpack_from("<12i", raw, rec)
    V = np.frombuffer(raw, np.uint8, fields[8] * 36, sec[10] + 36 * fields[7]).reshape(-1, 36)
    pos = V[:, :8].copy().view(np.float16)[:, :3].astype(np.float64)
    w = V[:, 24:32].copy().view(np.uint16).astype(np.float64) / 65535
    b = V[:, 32:36].astype(int)
    out = np.zeros_like(pos)
    for j in range(4):
        r = rows[f, b[:, j]].astype(np.float64)
        out += w[:, j:j + 1] * (qrot(r[:, :4], pos) + r[:, 4:7])
    return out


def cmd_preview(args):
    template = read_entry(TEMPLATE_MODEL)
    joints = skeleton(template)
    _head, rows, clips = load_bank()
    frame = flag_frame(joints, rows)
    rows[:, FLAG_JOINTS] = wave_rows(frame, rows, clips)
    verts, tris = build_lod(frame, *LODS[0][:3], 4)
    s, e = clips[args.clip]
    frames = [s + (e - s) * k // args.count for k in range(args.count)]
    W, H = 220, 300
    img = Image.new("RGB", (W * 2 * len(frames), H), "white")
    d = ImageDraw.Draw(img)
    body = [(39149, (120, 120, 220)), (39147, (120, 180, 120)), (39142, (230, 170, 130)), (39160, (220, 120, 120))]
    for k, f in enumerate(frames):
        layers = [(model_lod0_points(e_, rows, f), col) for e_, col in body]
        flag = skin(verts, rows, f)
        for view in (0, 1):
            x0 = (2 * k + view) * W

            def xy(p):
                return ((p[:, 0] if view == 0 else p[:, 2]) * 110 + W / 2 + x0, H - 15 - p[:, 1] * 110)
            for pts, col in layers:
                for x, y in zip(*xy(pts[::3])):
                    d.point((x, y), fill=col)
            fx, fy = xy(flag)
            for t in tris:
                d.polygon([(fx[i], fy[i]) for i in t], outline=(200, 30, 30))
        d.text((2 * k * W + 4, 4), f"clip {args.clip} f{f}: front | side", fill="black")
    os.makedirs(WORK, exist_ok=True)
    out = os.path.join(WORK, f"preview_clip{args.clip}.png")
    img.save(out)
    print(out)


# ---- writers ------------------------------------------------------------------

def cmd_model(args):
    template = read_entry(TEMPLATE_MODEL)
    _head, rows, _clips = load_bank()
    model = build_model(template, flag_frame(skeleton(template), rows))
    os.makedirs(WORK, exist_ok=True)
    with open(os.path.join(WORK, "prop_flagSmall.model"), "wb") as f:
        f.write(model)
    print(f"model: {len(model)} bytes")
    index = Index()
    ae.add_entry(pack.BLOBSET_PATH, MODEL_PATH, model, (len(model), len(model), 0, 0),
                 "crowd-flags build_flags.py model", args.confirm, replace=index.entry(MODEL_PATH) is not None)


def cmd_bank(args):
    check_flag_joints_unused()
    if os.path.exists(pack.backup_meta_path(BANK_ENTRY)):
        if not args.confirm:
            print(f"(entry {BANK_ENTRY} is installed; --confirm restores it before rebuilding)")
        else:
            pack.do_restore(pack.BLOBSET_PATH, BANK_ENTRY)
    raw = read_entry(BANK_ENTRY)
    head, rows, clips = load_bank(raw)
    template = read_entry(TEMPLATE_MODEL)
    frame = flag_frame(skeleton(template), rows)
    # stock flag rows hold a rest pose for the whole of each clip
    moving = max(np.abs(rows[s:e, FLAG_JOINTS] - rows[s, FLAG_JOINTS]).max() for s, e in clips)
    if moving > 1e-6 and not args.force:
        raise SystemExit("flag joint rows move within a clip - is the bank already patched? (--force to ignore)")
    rows[:, FLAG_JOINTS] = wave_rows(frame, rows, clips)
    vram = rows.astype(np.float32).tobytes()
    enc = texture_mods.encode_outer_chunks(vram)
    blob = head + enc
    sizes = (len(head), len(head), len(enc), len(vram))
    os.makedirs(WORK, exist_ok=True)
    out = os.path.join(WORK, f"entry_{BANK_ENTRY}.bin")
    with open(out, "wb") as f:
        f.write(blob)
    print(f"bank: {len(clips)} clips, {rows.shape[0]} frames, blob {len(blob)} bytes, sizes {sizes}")
    if not args.confirm:
        print("dry run - pass --confirm to install (close the game first)")
        return
    pack.do_install(pack.BLOBSET_PATH, BANK_ENTRY, out, True, sizes=sizes)
    print(f"installed entry {BANK_ENTRY} (undo: python tools\\pack.py restore --entry {BANK_ENTRY})")


class Index:
    def __init__(self):
        ce.load_index(pack.BLOBSET_PATH)
        data, count, hash_off, _ = pack.read_index(pack.BLOBSET_PATH)
        self.entries = {h: i for i, h in enumerate(ae.load_hashes(data, count, hash_off))}

    def entry(self, path):
        return self.entries.get(ae.path_hash(path))

    def texture(self, path):
        raw = ce.read_blob_full(pack.BLOBSET_PATH, self.entry(path))[0]
        return et.parse_mini_txpk(raw)[1]


def dxt1_with_mips(img, header):
    payload, level = bytearray(), img
    while True:
        buf = io.BytesIO()
        level.save(buf, "DDS", pixel_format="DXT1")
        payload += buf.getvalue()[128:]
        if level.size == (1, 1):
            break
        level = level.resize((max(1, level.width // 2), max(1, level.height // 2)), Image.BOX)
    return header + bytes(payload)


POLE_COLOUR = (200, 200, 205)
MASK_PRIMARY, MASK_SECONDARY = (255, 0, 0), (255, 255, 0)   # the crowd's tint masks (see crowd_scarf01_default01_col)
DEFAULT_FLAG = "crowd_flag_default01_col"
ARCHETYPES = os.path.join(HERE, "src", "script-game", "intermediatelua", "crowd", "crowd_archetypes.lua")
GEN_BEGIN, GEN_END = "-- GENERATED by build_flags.py teams: begin", "-- GENERATED by build_flags.py teams: end"


def flag_image(logo, primary, secondary, pole=POLE_COLOUR, size=512):
    """Two-tone flag (secondary stripes top and bottom) with the club emblem in
    the middle; the bottom band (below TEX_FLAG_ROWS) is the pole colour."""
    img = Image.new("RGB", (size, size), pole)
    rows = int(round(TEX_FLAG_ROWS * size))
    art = Image.new("RGB", (size, rows), primary)
    d = ImageDraw.Draw(art)
    stripe = rows // 7
    d.rectangle([0, 0, size, stripe], fill=secondary)
    d.rectangle([0, rows - stripe, size, rows], fill=secondary)
    if logo is not None:
        logo = logo.copy()
        box = int(rows * 0.62)
        logo.thumbnail((box, box), Image.LANCZOS)
        art.paste(logo, ((size - logo.width) // 2, (rows - logo.height) // 2), logo)
    img.paste(art, (0, 0))
    return img


def load_clubs():
    """(id, fullName, icon, primary, secondary) of every club in the installed
    defaultdata_clubs (entry 39957), mod clubs included."""
    sys.path.insert(0, os.path.join(ROOT, "mods", "crowd-team-kits"))
    import generate
    import parse_clubs
    os.makedirs(WORK, exist_ok=True)
    path = os.path.join(WORK, "defaultdata_clubs.bin")
    with open(path, "wb") as f:
        f.write(generate.load_clubs(None))
    _data, clubs = parse_clubs.load_clubs(path, with_roster=False)
    return [(c["id"], c["fullName"], c["icon"], tuple(c["primaryRGBColour"]), tuple(c["secondaryRGBColour"]))
            for c in clubs if c.get("icon")]


def write_generated(team_flags):
    """Club id -> texture name table into crowd_archetypes.lua."""
    with open(ARCHETYPES, encoding="utf-8") as f:
        src = f.read()
    lines = [GEN_BEGIN, "local crowdFlagsTeams = {"]
    lines += [f'\t[{cid}] = "{tex}", -- {name}' for cid, tex, name in team_flags]
    lines += ["}", GEN_END]
    start, end = src.index(GEN_BEGIN), src.index(GEN_END) + len(GEN_END)
    src = src[:start] + "\n".join(lines) + src[end:]
    with open(ARCHETYPES, "w", encoding="utf-8", newline="\n") as f:
        f.write(src)


def cmd_teams(args):
    """A flag per distinct (emblem, colours) across all clubs, plus the tint-mask
    default; appends/replaces the textures and writes the club table."""
    index = Index()
    stock = index.texture(f"{TEXTURE_DIR}/{STOCK_512_COL}.texture")
    if stock[84:88] != b"DXT1" or struct.unpack_from("<2I", stock, 12) != (512, 512):
        raise SystemExit("unexpected donor texture format")
    flags, team_flags = {}, []
    for cid, name, icon, primary, secondary in load_clubs():
        key = (icon, primary, secondary)
        if key not in flags:
            tex = f"crowd_flag_{icon}_col".lower()
            n = sum(1 for k in flags if k[0] == icon)
            flags[key] = tex if n == 0 else tex.replace("_col", f"_{n + 1}_col")
        team_flags.append((cid, flags[key], name))
    os.makedirs(os.path.join(WORK, "flags"), exist_ok=True)
    images = [(DEFAULT_FLAG, flag_image(None, MASK_PRIMARY, MASK_SECONDARY, pole=MASK_SECONDARY), "tint mask")]
    for (icon, primary, secondary), tex in flags.items():
        logo_path = f"ui/club_logos/large_mirrored/{icon}.texture"
        if index.entry(logo_path) is None:
            print(f"  no emblem for {icon}, plain flag")
            logo = None
        else:
            logo = Image.open(io.BytesIO(index.texture(logo_path))).convert("RGBA")
        images.append((tex, flag_image(logo, primary, secondary), icon))
    for tex, img, desc in images:
        img.save(os.path.join(WORK, "flags", f"{tex}.png"))
        dds = dxt1_with_mips(img, stock[:128])
        if len(dds) != len(stock):
            raise SystemExit(f"{tex}: DDS is {len(dds)} bytes, donor is {len(stock)}")
        path = f"{TEXTURE_DIR}/{tex}.texture"
        blob, sizes = club_icons.make_blob(path, dds)
        if args.confirm:
            ae.add_entry(pack.BLOBSET_PATH, path, blob, sizes, f"crowd-flags flag ({desc})",
                         True, replace=index.entry(path) is not None)
    write_generated(team_flags)
    print(f"{len(images)} flag textures for {len(team_flags)} clubs; previews in {os.path.join(WORK, 'flags')}")
    print(f"club table written to {os.path.relpath(ARCHETYPES, ROOT)}")
    if args.confirm:
        print("next: python mods\\crowd-team-kits\\bake_crowd_jerseys.py register --confirm, then rebuild 39959")
    else:
        print("dry run - pass --confirm to append the textures (close the game first)")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("preview")
    p.add_argument("--clip", type=int, default=47)
    p.add_argument("--count", type=int, default=5)
    p = sub.add_parser("model")
    p.add_argument("--confirm", action="store_true")
    p = sub.add_parser("bank")
    p.add_argument("--confirm", action="store_true")
    p.add_argument("--force", action="store_true")
    p = sub.add_parser("teams")
    p.add_argument("--confirm", action="store_true")
    args = ap.parse_args()
    {"preview": cmd_preview, "model": cmd_model, "bank": cmd_bank, "teams": cmd_teams}[args.cmd](args)


if __name__ == "__main__":
    main()
