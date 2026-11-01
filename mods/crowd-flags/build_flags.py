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
  variants every flag face in resources/flags/<icon>/*.png (template shape,
           see default_flags.py) as a crowd texture crowd_flag_<icon>_<variant>_col
           (512x512 DXT1 + mips, via face_to_texture), plus a red/yellow
           tint-mask default, as new entries; and the club id -> list of
           flags table in crowd_archetypes.lua (each club gets all its icon's
           variants). Like every crowd texture they must also be in the crowd
           texture table, or the match load aborts: run crowd-team-kits'
           `bake_crowd_jerseys.py register --confirm` afterwards.
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
bind (model) space; bank rows are skinning deltas. Front faces: cross(v1 - v0,
v2 - v0) agrees with the vertex normal (99%+ of stock crowd triangles).

Animation bank (entry 39122): main = 3000 B header {u32 total frames 10233,
frames x 94, joints 93, ?, clips 103, ?, then per clip u32 start | end << 16
and u32 frame count}; vram = 10233 x 94 rows of {quat xyzw, pos xyz, 1} f32,
row k = skeleton joint k. A posed vertex is sum(w * (rotate(q, p) + t)).

    python mods\\crowd-flags\\build_flags.py preview
    python mods\\crowd-flags\\build_flags.py model   [--confirm]
    python mods\\crowd-flags\\build_flags.py variants [--confirm]
    python mods\\crowd-flags\\build_flags.py bank    [--confirm]
"""

import argparse
import io
import json
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
import entries  # noqa: E402
import texture_mods  # noqa: E402

WORK = os.path.join(ROOT, "_build", "crowd-flags")
TEMPLATE_MODEL = entries.index_of("crowd-flag-template")  # prop_camera02.model (1.0.5887: 39167)
BANK_ENTRY = entries.index_of("crowd-anim-bank")         # crowd animation bank (1.0.5887: 39122)
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

# Physics (physics_rows): the wave is the rest pose the chain is pulled toward
PHYS_K_ROOT, PHYS_K_TIP = 400.0, 80.0   # pull-to-rest stiffness at the pole / at the free end (1/s^2)
PHYS_DAMPING = 10.0                     # velocity damping (1/s)
PHYS_MAX_SWING = math.radians(35)       # hard limit of each segment from its rest direction (no folding back;
                                        # a clamp between neighbouring segments made the tip jitter instead)
PHYS_GRAVITY = 2.0                      # m/s^2 - a light cloth droops less than full gravity
PHYS_SUBSTEPS = 4                       # per 30 fps frame
PHYS_PASSES = 3                         # loops per clip before the kept one (settling)

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
                # tangent = dP/du; handedness w makes w * cross(N, T) = dP/dv
                # (as stock), which is -d on both faces since v runs down
                add(p, n * sign, (*(c * sign), -1.0), (tex_u, v * TEX_FLAG_ROWS), infl)
        for i in range(cols):
            for r in range(nrows):
                a = start + i * (nrows + 1) + r
                b = a + nrows + 1
                quad = [(a, b, a + 1), (b, b + 1, a + 1)]   # winding normal = -n
                # front faces wind so that cross(v1 - v0, v2 - v0) points along
                # the vertex normal (as every stock crowd model does); the
                # wrong way round the visible face is lit from behind (dark)
                tris += quad if side == 1 else [(x, z, y) for x, y, z in quad]
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


def physics_rows(frame, rows, clips, rest=None):
    """Flag joint rows with spring-chain physics, baked offline: the touch
    judge's flag swings through the game's jiggly joints (pull to rest +
    stretch constraints, simulated per character on the CPU), which the
    GPU-instanced crowd can't run. So the same idea runs here, per clip, against
    the clip's real hand motion: the 11 chain nodes (pole top + 10 segment
    ends) are pulled toward the wave pose (wave_rows, the animated rest pose),
    stiff at the pole and loose at the tip, damped, with a little gravity,
    segment lengths held and each segment kept within PHYS_MAX_SWING of its
    rest direction (the jiggly system's hard constraints) so the cloth can't
    fold over itself. Each clip is simulated PHYS_PASSES times to settle;
    the last pass is kept, and its loop residual is spread across the clip so
    the loop is seamless. Rows keep wave_rows' convention: joint k is segment
    k's rigid transform, bind hinge pivot + c*k*seg_len -> posed node k."""
    from scipy.spatial.transform import Rotation
    grip, d, c, n = frame
    total = rows.shape[0]
    seg_len = CLOTH_WIDTH / SEGMENTS
    pivot = grip + d * (POLE_ABOVE - 0.01)
    rest = wave_rows(frame, rows, clips) if rest is None else rest
    bind = pivot + np.outer(np.arange(SEGMENTS + 1), c) * seg_len               # 11 bind nodes
    # rest pose: node 0 on the hand, node k+1 = end of segment k
    target = np.zeros((total, SEGMENTS + 1, 3))
    target[:, 0] = qrot(rows[:, HAND, :4].astype(np.float64), np.broadcast_to(pivot, (total, 3))) + rows[:, HAND, 4:7]
    for k in range(SEGMENTS):
        r = rest[:, k].astype(np.float64)
        target[:, k + 1] = qrot(r[:, :4], np.broadcast_to(bind[k + 1], (total, 3))) + r[:, 4:7]
    rest_normal = np.stack([qrot(rest[:, k, :4].astype(np.float64), np.broadcast_to(n, (total, 3)))
                            for k in range(SEGMENTS)], 1)

    stiffness = np.linspace(PHYS_K_ROOT, PHYS_K_TIP, SEGMENTS)[:, None]
    gravity = np.array([0.0, -PHYS_GRAVITY, 0.0])
    dt = 1.0 / FPS / PHYS_SUBSTEPS
    cos_swing, sin_swing = math.cos(PHYS_MAX_SWING), math.sin(PHYS_MAX_SWING)

    def clamp_dir(dirn, ref, cos, cos_limit, sin_limit):
        """dirn turned toward ref until the angle between them is the limit."""
        side = dirn - ref * cos
        side /= max(np.linalg.norm(side), 1e-9)
        return ref * cos_limit + side * sin_limit
    nodes = np.zeros((total, SEGMENTS + 1, 3))
    for s, e in clips:
        x = target[s, 1:].copy()
        v = np.zeros_like(x)
        for p in range(PHYS_PASSES):
            record = p == PHYS_PASSES - 1
            if record:
                nodes[s, 1:] = x                                                 # the last pass's frame s
            for f in range(s, e):
                nxt = f + 1 if f + 1 < e else s                                  # clips loop
                for sub in range(PHYS_SUBSTEPS):
                    a = (sub + 1) / PHYS_SUBSTEPS
                    goal = target[f] * (1 - a) + target[nxt] * a
                    old = x.copy()
                    v += (stiffness * (goal[1:] - x) - PHYS_DAMPING * v + gravity) * dt
                    x += v * dt
                    prev = goal[0]
                    for k in range(SEGMENTS):                                   # stretch + swing constraints
                        seg = x[k] - prev
                        dirn = seg / max(np.linalg.norm(seg), 1e-9)
                        rest_dir = goal[k + 1] - goal[k]
                        rest_dir /= max(np.linalg.norm(rest_dir), 1e-9)
                        cos = float(dirn @ rest_dir)
                        if cos < cos_swing:
                            dirn = clamp_dir(dirn, rest_dir, cos, cos_swing, sin_swing)
                        x[k] = prev + dirn * seg_len
                        prev = x[k]
                    v = (x - old) / dt
                if record and nxt != s:
                    nodes[nxt, 1:] = x
        # x is now where the loop wraps back into frame s; spread the difference
        # over the clip so the last frame flows into the first
        residual = x - nodes[s, 1:]
        ramp = (np.arange(e - s) / (e - s))[:, None, None]
        nodes[s:e, 1:] -= ramp * residual
    nodes[:, 0] = target[:, 0]

    out = np.zeros((total, SEGMENTS, 8), np.float32)
    bind_basis = np.stack([c, n, np.cross(c, n)], 1)                              # columns
    start = nodes[:, 0].copy()
    for k in range(SEGMENTS):
        seg = nodes[:, k + 1] - nodes[:, k]
        dirn = seg / np.linalg.norm(seg, axis=1, keepdims=True)
        # rebuild the chain from the pole out (exact lengths, no gaps between segments)
        nodes[:, k] = start
        start = start + dirn * seg_len
        nrm = rest_normal[:, k] - dirn * (rest_normal[:, k] * dirn).sum(1, keepdims=True)
        nrm /= np.linalg.norm(nrm, axis=1, keepdims=True)
        posed_basis = np.stack([dirn, nrm, np.cross(dirn, nrm)], 2)              # columns
        R = posed_basis @ bind_basis.T
        q = Rotation.from_matrix(R).as_quat()                                    # x, y, z, w
        out[:, k, :4] = q
        out[:, k, 4:7] = nodes[:, k] - qrot(q, np.broadcast_to(bind[k], (total, 3)))
        out[:, k, 7] = 1.0
    return out


def check_flag_joints_unused():
    """Refuse to patch the bank if any stock crowd model is skinned to the flag joints."""
    ce.load_index(pack.BLOBSET_PATH)
    data, count, hash_off, _ = pack.read_index(pack.BLOBSET_PATH)
    bad = []
    for e in (entries.legacy(n) for n in range(39123, 39168)):  # stock crowd models (1.0.5887 numbers)
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
    s, e = clips[args.clip]
    # only this clip's frames, so the physics doesn't simulate the whole bank
    rows = rows[s:e].copy()
    rows[:, FLAG_JOINTS] = (physics_rows if args.style == "physics" else wave_rows)(frame, rows, [(0, e - s)])
    verts, tris = build_lod(frame, *LODS[0][:3], 4)
    frames = [(e - s) * k // args.count for k in range(args.count)]
    W, H = 220, 300
    img = Image.new("RGB", (W * 2 * len(frames), H), "white")
    d = ImageDraw.Draw(img)
    body = [(entries.legacy(n), col) for n, col in  # 1.0.5887 numbers
            [(39149, (120, 120, 220)), (39147, (120, 180, 120)), (39142, (230, 170, 130)), (39160, (220, 120, 120))]]
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
        d.text((2 * k * W + 4, 4), f"{args.style} clip {args.clip} f{s + f}: front | side", fill="black")
    os.makedirs(WORK, exist_ok=True)
    out = os.path.join(WORK, f"preview_clip{args.clip}_{args.style}.png")
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


def stock_bank():
    """The stock animation bank: from pack.py's install backup when the bank is
    already patched (so a dry run works without restoring), else live."""
    meta_path = pack.backup_meta_path(BANK_ENTRY)
    if not os.path.exists(meta_path):
        return read_entry(BANK_ENTRY)
    with open(meta_path) as f:
        meta = json.load(f)
    with open(meta["blob_backup"], "rb") as f:
        raw = f.read()
    if meta["main_compressed_size"] == meta["main_uncompressed_size"]:
        main = meta["main_uncompressed_size"]
        return raw[:main] + ce.decode_outer_zstd_frames(raw[main:])
    return ce.decode_outer_zstd_frames(raw)


def cmd_bank(args):
    check_flag_joints_unused()
    raw = stock_bank()
    if args.confirm and os.path.exists(pack.backup_meta_path(BANK_ENTRY)):
        pack.do_restore(pack.BLOBSET_PATH, BANK_ENTRY)
    head, rows, clips = load_bank(raw)
    template = read_entry(TEMPLATE_MODEL)
    frame = flag_frame(skeleton(template), rows)
    # stock flag rows hold a rest pose for the whole of each clip
    moving = max(np.abs(rows[s:e, FLAG_JOINTS] - rows[s, FLAG_JOINTS]).max() for s, e in clips)
    if moving > 1e-6 and not args.force:
        raise SystemExit("flag joint rows move within a clip - is the bank already patched? (--force to ignore)")
    rows[:, FLAG_JOINTS] = (physics_rows if args.style == "physics" else wave_rows)(frame, rows, clips)
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
GEN_BEGIN, GEN_END = "-- GENERATED by build_flags.py variants: begin", "-- GENERATED by build_flags.py variants: end"
CROWD_COLS = 16                 # native cols capacity per variant


def face_to_texture(face, pole=POLE_COLOUR, size=512):
    """A flag face drawn at its in-game shape (CLOTH_WIDTH x CLOTH_HEIGHT, pole
    edge on the left, top up - resources/flags/flag_template.psd) -> the crowd
    texture: the face squashed into the top TEX_FLAG_ROWS, the pole colour below."""
    img = Image.new("RGB", (size, size), pole)
    rows = int(round(TEX_FLAG_ROWS * size))
    img.paste(face.convert("RGB").resize((size, rows), Image.LANCZOS), (0, 0))
    return img


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


FLAGS_DIR = os.path.join(ROOT, "resources", "flags")
VARIANT_ORDER = ["default", "inverted", "huge", "wordmark"]   # then classic_N, then anything else, by name


def write_generated(team_flags):
    """Club id -> list of flag textures, into crowd_archetypes.lua."""
    with open(ARCHETYPES, encoding="utf-8") as f:
        src = f.read()
    lines = [GEN_BEGIN, "local crowdFlagsTeams = {"]
    for cid, textures, name in team_flags:
        quoted = ", ".join(f'"{t}"' for t in textures)
        lines.append(f"\t[{cid}] = {{ {quoted} }}, -- {name}")
    lines += ["}", GEN_END]
    start, end = src.index(GEN_BEGIN), src.index(GEN_END) + len(GEN_END)
    src = src[:start] + "\n".join(lines) + src[end:]
    with open(ARCHETYPES, "w", encoding="utf-8", newline="\n") as f:
        f.write(src)


def variant_key(name):
    if name in VARIANT_ORDER:
        return (0, VARIANT_ORDER.index(name), name)
    return (1, 0, name) if name.startswith("classic_") else (2, 0, name)


def flag_faces():
    """icon -> [(variant, png path)] from resources/flags/<icon>/*.png, in VARIANT_ORDER."""
    faces = {}
    for icon in sorted(os.listdir(FLAGS_DIR)):
        folder = os.path.join(FLAGS_DIR, icon)
        if not os.path.isdir(folder):
            continue
        pngs = [f[:-4] for f in os.listdir(folder) if f.lower().endswith(".png")]
        if pngs:
            faces[icon] = [(v, os.path.join(folder, v + ".png")) for v in sorted(pngs, key=variant_key)]
    return faces


def crowd_list(textures):
    """A club's flag list as the crowd cycles it: national flags
    (national_flags.py) are repeated so they wave from about half the fans,
    interleaved with the club designs."""
    national = [t for t in textures if "_national" in t]
    club = [t for t in textures if t not in national]
    if not national or not club:
        return textures
    out = []
    for i in range(max(len(club), len(national))):
        if i < len(club):
            out.append(club[i])
        out.append(national[i % len(national)])
    return out


def cmd_variants(args):
    """Every flag face in resources/flags/<icon>/ -> a crowd texture
    crowd_flag_<icon>_<variant>_col (face_to_texture, 512x512 DXT1 + mips),
    appended or replaced, plus the tint-mask default; writes the club id ->
    flag list table. Clubs whose icon has no folder get the tint mask."""
    index = Index()
    stock = index.texture(f"{TEXTURE_DIR}/{STOCK_512_COL}.texture")
    if stock[84:88] != b"DXT1" or struct.unpack_from("<2I", stock, 12) != (512, 512):
        raise SystemExit("unexpected donor texture format")
    faces = flag_faces()
    textures = {icon: [f"crowd_flag_{icon}_{v}_col".lower() for v, _p in variants] for icon, variants in faces.items()}
    team_flags, missing = [], set()
    for cid, name, icon, _primary, _secondary in load_clubs():
        if icon in textures:
            team_flags.append((cid, crowd_list(textures[icon])[:CROWD_COLS], name))
        else:
            missing.add(icon)
    images = [(DEFAULT_FLAG, lambda: flag_image(None, MASK_PRIMARY, MASK_SECONDARY, pole=MASK_SECONDARY), "tint mask")]
    for icon, variants in faces.items():
        for (variant, path), tex in zip(variants, textures[icon]):
            images.append((tex, lambda path=path: face_to_texture(Image.open(path)), f"{icon} {variant}"))
    added = replaced = 0
    for tex, make, desc in images:
        path = f"{TEXTURE_DIR}/{tex}.texture"
        exists = index.entry(path) is not None
        if not args.confirm:
            replaced += exists
            added += not exists
            continue
        dds = dxt1_with_mips(make(), stock[:128])
        if len(dds) != len(stock):
            raise SystemExit(f"{tex}: DDS is {len(dds)} bytes, donor is {len(stock)}")
        blob, sizes = club_icons.make_blob(path, dds)
        ae.add_entry(pack.BLOBSET_PATH, path, blob, sizes, f"crowd-flags flag ({desc})", True, replace=exists)
        replaced += exists
        added += not exists
    write_generated(team_flags)
    print(f"{len(images)} flag textures ({added} new, {replaced} replaced) for {len(team_flags)} clubs, "
          f"{len(faces)} icons; club table written to {os.path.relpath(ARCHETYPES, ROOT)}")
    for icon in sorted(missing):
        print(f"  no resources/flags/{icon}/ - its clubs get the tint mask")
    if args.confirm:
        print("next: python mods\\crowd-team-kits\\bake_crowd_jerseys.py register --confirm, then rebuild scripts")
    else:
        print("dry run - pass --confirm to write the textures (close the game first)")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("preview")
    p.add_argument("--clip", type=int, default=47)
    p.add_argument("--count", type=int, default=5)
    p.add_argument("--style", choices=["physics", "wave"], default="physics")
    p = sub.add_parser("model")
    p.add_argument("--confirm", action="store_true")
    p = sub.add_parser("bank")
    p.add_argument("--style", choices=["physics", "wave"], default="physics")
    p.add_argument("--confirm", action="store_true")
    p.add_argument("--force", action="store_true")
    p = sub.add_parser("variants")
    p.add_argument("--confirm", action="store_true")
    args = ap.parse_args()
    {"preview": cmd_preview, "model": cmd_model, "bank": cmd_bank, "variants": cmd_variants}[args.cmd](args)


if __name__ == "__main__":
    main()
