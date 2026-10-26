#!/usr/bin/env python3
"""
animset.py - parse / rebuild / convert animation sets (animations/<name>.animset).

Reverse-engineered 2026-10-24 from RL26 and Rugby 25 files plus RL26's clip
registration code (rugbyleague1.exe 0xde5aa0: a clip's name is read through a
self-relative int32 at clip header +0xAC). `verify` proves the RL26 layout by
rebuilding stock files byte for byte; `convert` turns a Rugby 25 set into the
RL26 layout.

File layout (little endian, offsets absolute unless "rel"):
  0x00  u32 clip count, u32 A, B, C, D, E (section offsets), 8 zero bytes
  0x20  keyframe region: per-clip track records (16 bytes) + key streams.
        Kept verbatim and in place (clip headers point into it).
  ...   clip blocks, one per clip, back to back, then:
  A     clip count x u32: clip block offsets
  B     clip count x f32 durations + 12 bytes
  C     u32 n + n x 8: channel map (u16 kind 1 rot / 2 trans / 4 scale /
        8 float - R25 only in cutscene sets, u16 name index, u32 slot)
  D     u32 n + n x 72: per-joint setup
  E     u32 n + n x u32 fnv1a32(name) + n x u16 string offset, then
        NUL-terminated strings: the n joint/event names, then the clip names
        (clip i = string n + i), then event names.

Clip block (pointers "rel" = relative to the clip block start):
  +0x00 f32 duration, u16 tracks, u16 ?, u16 samples (N), u16 ?,
        u8 fps (RL26 cutscenes 15, R25 30), u8 ?, u8 flags (0x20: R25 extra
        per-sample channel present, 0x40: the clip's _m motion twin), u8 0
  +0x88 4 x rel int32: key stream pointers (into the keyframe region)
  +0x98 sub-block rel offsets: RL26 3 (header 0xB0), R25 4 (header 0xB4)
  then  rel int32: E section, rel int32: first clip name, rel int32: own name
  sub-blocks: N x 24 (root samples), N x 8, [R25: N x 4 floats, dropped by
        convert], events (first u32 is relative to the events start and
        points at the event-name strings).

Usage:
    python animset.py info NAME [--blobset PATH]
    python animset.py verify [NAME ...] [--blobset PATH]   # rebuild == stock?
"""

import argparse
import math
import os
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pack  # noqa: E402

RL26_HEADER = 0xB0
R25_HEADER = 0xB4
FLAG_EXTRA_CHANNEL = 0x20

# Track key packings Rugby 25 uses that RL26 decodes wrongly. Both decoders
# are transcribed from Rugby 25's own exe (rugby24.exe):
#   0x4 / 0x4004 translation, 4 bytes - exe 0x3ef280 (linear) / 0x3f1400:
#       x = bits 20-28 / 511, y = bits 10-19 / 1023, z = bits 0-9 / 1023,
#       each times the record's f32 `a` (the track's max |value|), negative
#       unless sign bit 31 / 30 / 29 is set.
#   0x8 / 0x4008 rotation, 8 bytes - exe 0x3e2ca0: smallest-three quaternion,
#       three 20-bit fields from bit 0 (minus 0x7ffff, times
#       1/(0x7ffff*sqrt2)), dropped-component index at bits 60-61, w
#       negated if bit 62; component order by index: 3 (c,b,a,w),
#       2 (c,b,w,a), 1 (c,w,b,a), 0 (w,c,b,a).
# Verified against RL26's float tracks for the same mocap
# (cutscenetrycelebratehug08 hips/foot, hug04 / low5hug01 hands: dot > 0.99).
ROT_K = 1.3487000387613080e-06


def fnv1a32(text):
    h = 0x811C9DC5
    for c in text.encode("latin1"):
        h = ((h ^ c) * 0x01000193) & 0xFFFFFFFF
    return h


def decode_translation4(key, scale):
    v = struct.unpack("<I", key)[0]
    x = ((v >> 20) & 0x1FF) / 511 * scale
    y = ((v >> 10) & 0x3FF) / 1023 * scale
    z = (v & 0x3FF) / 1023 * scale
    return (x if v >> 31 & 1 else -x, y if v >> 30 & 1 else -y, z if v >> 29 & 1 else -z, 0.0)


def decode_rotation8(key):
    v = int.from_bytes(key, "little")
    a = ((v & 0xFFFFF) - 0x7FFFF) * ROT_K
    v >>= 20
    b = ((v & 0xFFFFF) - 0x7FFFF) * ROT_K
    v >>= 20
    c = ((v & 0xFFFFF) - 0x7FFFF) * ROT_K
    v >>= 20
    w = max(0.0, 1.0 - a * a - b * b - c * c) ** 0.5
    if (v >> 2) & 1:
        w = -w
    return {3: (c, b, a, w), 2: (c, b, w, a), 1: (c, w, b, a), 0: (w, c, b, a)}[v & 3]


def transcodable(kind, enc):
    return (kind, enc & 0xFF) in ((2, 0x4), (1, 0x8))


# RL26 places a character by its `worldroot` track (rotation + translation,
# encoding 0xC010; hips etc. are relative to it). Rugby 25 clips have no such
# track - its engine derives the root from the clip block's root samples -
# so RL26 leaves the root at rest and the body floats / slides. The root is
# rebuilt from the same samples RL26 clips also carry, fitted on RL26 data
# (cutscenetrycelebratehug08 p1, exact):
#   header +0x40: f32 start x, start z, start rotation quat (x, y, z, w)
#   sub-block 1, per frame: f32 dx, dy, dz, yaw (degrees), cos, sin
#   root yaw = start yaw - yaw;  root pos = start + (dx cos0 + dz sin0, 0,
#   -dx sin0 + dz cos0) with cos0/sin0 of the start yaw.
WORLDROOT = "worldroot"
# R25-only joints (not in RL26's rig) that cutscene clips never animate:
# their name slot is renamed to worldroot so no table has to grow.
WORLDROOT_DONOR_SLOTS = ("rightinhandmiddle", "leftinhandmiddle")
ENC_WORLDROOT = 0xC010


# Static channels (stream 2 = (kind, joint) list, stream 1 = one 16-byte value
# each) hold a joint's constant local offset - effectively its bone length.
# Rugby 25's rig splits shin and forearm with extra roll joints, so its
# offsets are shorter (leftfoot -0.20 vs RL26 -0.415, relative to a legroll
# RL26 doesn't have): applied to RL26's skeleton the legs come out ~0.2 m
# short and players float with toes down. RL26 clips only carry translation
# statics (kinds 2 / 0x4001 / 0x4002), never rotation (1) or scale (4).
STATIC_KEEP_PREFIXES = ("cs_camera",)

# Face animation: kind 8 tracks on hj_face_loc_driver, 4 x u16 pose weights
# per 8-byte key (animationrules.lua faceNodeAttributes, 117 poses). Rugby 25
# and RL26 share the format byte for byte (face_switchplay_wide_01 ships in
# both facial.animsets with identical keys); RL26 only flags the encoding
# 0x4008 where Rugby 25 writes 0x8.
FACE_DRIVER = "hj_face_loc_driver"
FACE_ENC_FLAG = 0x4000


# Mirroring (_m clips). RL26 stores each _m clip as real mirrored data;
# Rugby 25 only flags its _m clips to be mirrored at runtime, which RL26 doesn't
# do. Rules derived from RL26's own tackle.animset base/_m pairs (all joints
# match exactly): mirror across X -
#   tracks / statics: left<->right joint (names swap "left"/"right" anywhere),
#     rotation (x, y, z, w) -> (x, -y, -z, w), translation (x, y, z) -> (-x, y, z)
#   header +0x10..+0x37: 4-byte vectors in two (left1, right1, left2, right2,
#     centre) groups -> swap each left/right pair, flip x sign (bit 31) when x != 0; +0x40 / +0x58 start /
#     end x negated, +0x48 / +0x60 their quats mirrored; +0x78 negated
#   sub-block 1 (dx, dy, dz, yaw, cos, sin) -> dx, yaw, sin negated;
#   sub-block 2 (a, b) -> a negated; events -> mirrored event name's index
# All done on the packed values (6-byte rotation fields negated / w-sign bit
# toggled, sign bits flipped), so nothing is re-quantised.
def mirror_name(name):
    out, i = [], 0
    while i < len(name):
        if name.startswith("left", i):
            out.append("right")
            i += 4
        elif name.startswith("right", i):
            out.append("left")
            i += 5
        else:
            out.append(name[i])
            i += 1
    return "".join(out)


def _neg_field15(f):
    t = (f * 2) & 0xFFFF
    t = (t - 0x10000) if t & 0x8000 else t
    return ((-t) & 0xFFFF) >> 1 & 0x7FFF


def mirror_rotation6(key):
    w0, w1, w2 = struct.unpack("<3H", key)
    v = (w0 << 32) | (w1 << 16) | w2
    a, b, c = v & 0x7FFF, (v >> 15) & 0x7FFF, (v >> 30) & 0x7FFF
    idx, neg = (v >> 45) & 3, (v >> 47) & 1
    # which stored field holds y / z for each dropped-component index
    if idx == 3:      # (c, b, a, w): y=b z=a
        b, a = _neg_field15(b), _neg_field15(a)
    elif idx == 2:    # (c, b, w, a): y=b, z dropped
        b, neg = _neg_field15(b), neg ^ 1
    elif idx == 1:    # (c, w, b, a): y dropped, z=b
        neg, b = neg ^ 1, _neg_field15(b)
    else:             # (w, c, b, a): y=c z=b
        c, b = _neg_field15(c), _neg_field15(b)
    v = (v & ~((1 << 48) - 1)) | a | (b << 15) | (c << 30) | (idx << 45) | (neg << 47)
    return struct.pack("<3H", (v >> 32) & 0xFFFF, (v >> 16) & 0xFFFF, v & 0xFFFF)


def mirror_key(kind, enc, key):
    size = enc & 0xFF
    if kind == 1:
        if size == 0x10:
            x, y, z, w = struct.unpack("<4f", key)
            return struct.pack("<4f", x, -y, -z, w)
        if size == 6:
            return mirror_rotation6(key)
    elif kind == 2:
        if size == 0x10:
            x, y, z, w = struct.unpack("<4f", key)
            return struct.pack("<4f", -x, y, z, w)
        if size == 6:
            u = list(struct.unpack("<3H", key))
            u[0] ^= 0x8000  # sign-magnitude: bit 15 set = positive
            return struct.pack("<3H", *u)
    return key  # scale (camera FOV), float curves: no handedness


def _mirror_vec4byte(v):
    return v ^ 0x80000000 if (v >> 20) & 0x1FF else v


def shift_start(head, dx, dz):
    """Move a clip's scene placement by (dx, dz): header +0x40 start x / z,
    and +0x58, which holds the inverse of the start transform (position
    -(R^T p), checked exact on every R25 and RL26 corridor clip)."""
    x, z, _, qy, _, qw = struct.unpack_from("<6f", head, 0x40)
    x, z = x + dx, z + dz
    t = 2 * math.atan2(qy, qw)
    struct.pack_into("<2f", head, 0x40, x, z)
    struct.pack_into("<2f", head, 0x58, -(x * math.cos(t) - z * math.sin(t)), -(x * math.sin(t) + z * math.cos(t)))


def shift_translation(key, enc, a, shift):
    """A translation key (6-byte sign-magnitude or float) as floats, moved by (dx, dz)."""
    if enc & 0xFF == 0x10:
        x, y, z, w = struct.unpack("<4f", key)
    else:
        scale = struct.unpack("<f", struct.pack("<I", a))[0]
        x, y, z = ((v & 0x7FFF) / 32767 * scale * (1 if v & 0x8000 else -1) for v in struct.unpack("<3H", key))
        w = 0.0
    return x + shift[0], y, z + shift[1], w


def rl26_static_offsets(rl26_animsets):
    """{(joint name, kind): 16-byte value} from RL26 animsets (raw blobs),
    first occurrence wins."""
    ref = {}
    for raw in rl26_animsets:
        a = AnimSet(raw)
        names = a.names()
        for c in a.clips:
            n2 = struct.unpack_from("<H", c.head, 6)[0]
            s0, s1, s2, s3 = c.streams
            for i in range(n2):
                kind, j = struct.unpack_from("<HH", raw, s2 + i * 4)
                if j < len(names):
                    ref.setdefault((names[j], kind), raw[s1 + i * 16:s1 + (i + 1) * 16])
    return ref


def worldroot_keys(head, root_samples, frames):
    sx, sz, qx, qy, qz, qw = struct.unpack_from("<6f", head, 0x40)
    yaw0 = 2 * math.atan2(qy, qw)
    c0, s0 = math.cos(yaw0), math.sin(yaw0)
    rots, poss, prev = [], [], None
    for f in range(frames):
        dx, dy, dz, yaw_deg, _, _ = struct.unpack_from("<6f", root_samples, f * 24)
        yaw = yaw0 - math.radians(yaw_deg)
        q = (0.0, math.sin(yaw / 2), 0.0, math.cos(yaw / 2))
        if prev is not None and q[1] * prev[1] + q[3] * prev[3] < 0:
            q = tuple(-x for x in q)  # keep the quaternion track continuous
        prev = q
        rots.append(q)
        poss.append((sx + dx * c0 + dz * s0, 0.0, sz - dx * s0 + dz * c0, 0.0))
    return rots, poss


class Clip:
    def __init__(self, raw, start, end):
        self.start = start
        self.header_size = struct.unpack_from("<I", raw, start + 0x98)[0]
        if self.header_size not in (RL26_HEADER, R25_HEADER):
            raise ValueError(f"clip at {start:#x}: unknown header size {self.header_size:#x}")
        nsub = 3 if self.header_size == RL26_HEADER else 4
        self.sub_offsets = list(struct.unpack_from(f"<{nsub}I", raw, start + 0x98))
        ptr_base = 0x98 + nsub * 4
        rels = struct.unpack_from("<3i", raw, start + ptr_base)
        # absolute targets of the self-relative pointers
        self.streams = [start + v for v in struct.unpack_from("<4i", raw, start + 0x88)]
        self.e_target, self.first_name_target, self.name_target = (start + v for v in rels)
        self.head = raw[start:start + 0x88]  # duration .. key stream pointers (exclusive)
        bounds = self.sub_offsets + [end - start]
        self.subs = [raw[start + bounds[i]:start + bounds[i + 1]] for i in range(nsub)]
        events_start = start + self.sub_offsets[-1]
        self.events_target = events_start + struct.unpack_from("<i", raw, events_start)[0]

    @property
    def flags(self):
        return self.head[0x0E]

    def to_rl26(self):
        """Drop R25's extra per-sample channel (sub-block 3) and its flag."""
        if self.header_size == RL26_HEADER:
            return
        del self.subs[2]
        self.header_size = RL26_HEADER
        head = bytearray(self.head)
        head[0x0E] &= ~FLAG_EXTRA_CHANNEL & 0xFF
        self.head = bytes(head)

    def build(self, start, relocate):
        """Bytes of this clip block placed at `start`; relocate(abs) maps an
        old absolute target to its new position."""
        nsub = len(self.subs)
        header_size = 0x98 + nsub * 4 + 12
        out = bytearray(self.head)
        out += struct.pack("<4i", *(relocate(t) - start for t in self.streams))
        offsets, pos = [], header_size
        for s in self.subs:
            offsets.append(pos)
            pos += len(s)
        out += struct.pack(f"<{nsub}I", *offsets)
        out += struct.pack("<3i", relocate(self.e_target) - start,
                           relocate(self.first_name_target) - start, relocate(self.name_target) - start)
        assert len(out) == header_size
        for s in self.subs[:-1]:
            out += s
        events_start = start + len(out)
        ev = bytearray(self.subs[-1])
        struct.pack_into("<i", ev, 0, relocate(self.events_target) - events_start)
        out += ev
        return bytes(out)


class AnimSet:
    """Keyframe data and clip blocks can interleave (groups of clips' data,
    then those clips' blocks, ...): everything between clip blocks is kept
    verbatim as data chunks, in order, and pointers are relocated by the
    chunk they land in."""

    def __init__(self, raw):
        self.raw = raw
        self.count, A, B, C, D, E = struct.unpack_from("<6I", raw, 0)
        self.pad = raw[0x18:0x20]
        offs = list(struct.unpack_from(f"<{self.count}I", raw, A))
        if offs != sorted(offs):
            raise ValueError("clip blocks are not in file order")
        # A clip block ends where the next piece (another block, or data) starts:
        # the end of its events sub-block is the next block / data / A.
        self.clips = []
        self.pieces = []  # ("data", start, bytes) | ("clip", Clip)
        targets = sorted({s + v for s in offs for v in struct.unpack_from("<4i", raw, s + 0x88)})
        pos = 0x20
        for k, s in enumerate(offs):
            if s > pos:
                self.pieces.append(("data", pos, raw[pos:s]))
            limit = offs[k + 1] if k + 1 < len(offs) else A
            end = min([t for t in targets if s < t < limit] + [limit])
            clip = Clip(raw, s, end)
            self.clips.append(clip)
            self.pieces.append(("clip", clip))
            pos = end
        if A > pos:
            self.pieces.append(("data", pos, raw[pos:A]))
        self.sections = {"A_tail": raw[A + self.count * 4:B], "B": raw[B:C], "C": raw[C:D], "D": raw[D:E], "E": raw[E:]}
        self.old = {"A": A, "B": B, "C": C, "D": D, "E": E}

    def to_rl26(self):
        for c in self.clips:
            c.to_rl26()

    def clip_name(self, clip):
        return self.raw[clip.name_target:self.raw.index(b"\0", clip.name_target)].decode("latin1")

    def keep_clips(self, names):
        """Reduce the set to the named clips (e.g. a handful of gameplay clips
        out of a 70 MB tackle set). Call before transcode_tracks - only kept
        clips' data is laid out. Section B (one f32 duration per clip, padded
        so C stays 16-byte aligned) is regenerated; E/C/D are kept whole."""
        wanted = set(names)
        self.clips = [c for c in self.clips if self.clip_name(c) in wanted]
        missing = wanted - {self.clip_name(c) for c in self.clips}
        if missing:
            raise ValueError(f"clips not in set: {sorted(missing)[:5]}")
        self.count = len(self.clips)
        durations = b"".join(c.head[0:4] for c in self.clips)
        self.sections["A_tail"] = b""
        self.sections["B_durations"] = durations

    def _worldroot_slot(self):
        """Name index to carry the synthesized worldroot track, renaming a
        donor slot in the E section if needed; None if the set already has
        one or no donor fits."""
        names, E = self.names(), bytearray(self.sections["E"])
        if WORLDROOT in names:
            return None
        n = struct.unpack_from("<I", E, 0)[0]
        used = {struct.unpack_from("<IHHHHI", self.raw, c.streams[3] + i * 16)[2]
                for c in self.clips for i in range(struct.unpack_from("<H", c.head, 4)[0])}
        C = self.sections["C"]
        channels = {}
        for i in range(struct.unpack_from("<I", C, 0)[0]):
            kind, name_idx, _ = struct.unpack_from("<HHI", C, 4 + i * 8)
            channels.setdefault(name_idx, set()).add(kind)
        # then spare camera joints, highest first (R25 sets carry cs_camera01-40)
        cameras = sorted((x for x in names if x.startswith("cs_camera")), reverse=True)
        for donor in list(WORLDROOT_DONOR_SLOTS) + cameras:
            if donor not in names:
                continue
            i = names.index(donor)
            if i in used or not {1, 2} <= channels.get(i, set()) or len(donor) < len(WORLDROOT):
                continue
            struct.pack_into("<I", E, 4 + i * 4, fnv1a32(WORLDROOT))
            str_off = struct.unpack_from("<H", E, 4 + n * 4 + i * 2)[0]  # relative to E
            E[str_off:str_off + len(WORLDROOT) + 1] = WORLDROOT.encode() + b"\0"
            self.sections["E"] = bytes(E)
            return i
        return None

    def names(self):
        """Hashed joint/event names by index (E section), as the engine
        resolves them through the u16 string offsets."""
        E = self.sections["E"]
        n = struct.unpack_from("<I", E, 0)[0]
        out = []
        for i in range(n):
            o = struct.unpack_from("<H", E, 4 + n * 4 + i * 2)[0]  # offsets are relative to E
            out.append(E[o:E.index(b"\0", o)].decode("latin1"))
        return out

    def transcode_tracks(self, add_worldroot=True, rl26_statics=None, offsets=None):
        """Re-pack every Rugby 25 track RL26 can't decode (see transcodable)
        as 16-byte floats (encoding low byte 0x10, other flag bits kept),
        (add_worldroot) give every clip the worldroot track RL26 needs, and
        (rl26_statics, from rl26_static_offsets) swap R25's constant bone
        offsets for RL26's and drop static kinds RL26 never uses. Rebuilds
        each clip's keyframe data. Returns the number of tracks converted or
        added. Clips that share data (R25 _m twins) stay shared. After this,
        build() lays the data out afresh (build_relaid)."""
        raw = self.raw
        starts = sorted({s for c in self.clips for s in c.streams} | {c.start for c in self.clips} | {self.old["A"]})
        root_slot = self._worldroot_slot() if add_worldroot else None
        names = self.names()
        rl_kinds = {k for _, k in rl26_statics} if rl26_statics else None
        self.statics_replaced = self.statics_dropped = 0
        self.chunks = {}  # old streams tuple -> dict
        converted = 0
        for c in self.clips:
            key = tuple(c.streams)
            if key in self.chunks:
                continue
            s0, s1, s2, s3 = c.streams
            _, tracks, n2, frames, stride = struct.unpack_from("<fHHHH", c.head, 0)
            recs = [list(struct.unpack_from("<IHHHHI", raw, s3 + i * 16)) for i in range(tracks)]
            keyframes = [raw[s0 + f * stride:s0 + (f + 1) * stride] for f in range(frames)]
            s2_end = min(s for s in starts if s > s2)
            static_kinds = [struct.unpack_from("<HH", raw, s2 + i * 4) for i in range(n2)]
            static_vals = [raw[s1 + i * 16:s1 + (i + 1) * 16] for i in range(n2)]
            # per track: list of per-frame key bytes in the new encoding
            per_track = []
            shift = (offsets or {}).get(self.clip_name(c))
            for r in recs:
                a, off, joint, kind, enc, z = r
                size = enc & 0xFF
                keys = [k[off:off + size] for k in keyframes]
                if shift and kind == 2 and joint < len(names) and names[joint].startswith("cs_camera") \
                        and size in (6, 0x10):
                    # cameras are placed in scene space (animated_camera cancels the
                    # clip's start), so a moved scene moves its camera paths too
                    keys = [struct.pack("<4f", *shift_translation(k, enc, a, shift)) for k in keys]
                    r[4] = (enc & 0xFF00) | 0x10
                    r[0] = struct.unpack("<I", struct.pack("<f", max(
                        abs(v) for k in keys for v in struct.unpack("<3f", k[:12])) or 0.0))[0]
                    per_track.append(keys)
                    converted += 1
                    continue
                if transcodable(kind, enc):
                    if kind == 2:
                        scale = struct.unpack("<f", struct.pack("<I", a))[0]
                        keys = [struct.pack("<4f", *decode_translation4(k, scale)) for k in keys]
                    else:
                        keys = [struct.pack("<4f", *decode_rotation8(k)) for k in keys]
                    r[4] = (enc & 0xFF00) | 0x10
                    converted += 1
                per_track.append(keys)
            if root_slot is not None:
                rots, poss = worldroot_keys(c.head, c.subs[0], frames)
                extent = max(abs(v) for p in poss for v in p[:3]) or 0.0
                recs.append([0, 0, root_slot, 1, ENC_WORLDROOT, 0])
                per_track.append([struct.pack("<4f", *q) for q in rots])
                recs.append([struct.unpack("<I", struct.pack("<f", extent))[0], 0, root_slot, 2, ENC_WORLDROOT, 0])
                per_track.append([struct.pack("<4f", *p) for p in poss])
                keep = [i for i, (_, j) in enumerate(static_kinds) if j != root_slot]
                static_kinds = [static_kinds[i] for i in keep]
                static_vals = [static_vals[i] for i in keep]
                converted += 2
            if rl26_statics:
                kinds, vals = [], []
                for (kind, j), val in zip(static_kinds, static_vals):
                    if kind not in rl_kinds:
                        self.statics_dropped += 1
                        continue
                    name = names[j] if j < len(names) else None
                    # bones only: a camera's constant translation is its shot
                    # position (R25 cs_camera01 sits at e.g. (11.3, 1.3, 35.6)),
                    # and scale channels are camera FOV - RL26's values for the
                    # same camera names put the camera in the crowd or the turf
                    ref = None if (name or "").startswith(STATIC_KEEP_PREFIXES) or (kind & 0xFF) == 4 \
                        else rl26_statics.get((name, kind))
                    if ref is not None and ref != val:
                        val = ref
                        self.statics_replaced += 1
                    kinds.append((kind, j))
                    vals.append(val)
                static_kinds, static_vals = kinds, vals
            if shift:
                # a camera that holds still keeps its position as a constant channel
                for i, (kind, j) in enumerate(static_kinds):
                    if kind & 0xFF == 2 and j < len(names) and names[j].startswith("cs_camera"):
                        x, y, z, w = struct.unpack("<4f", static_vals[i])
                        static_vals[i] = struct.pack("<4f", x + shift[0], y, z + shift[1], w)
            # new frame layout: biggest keys first so 16-byte keys stay aligned
            order = sorted(range(len(recs)), key=lambda i: -(recs[i][4] & 0xFF))
            pos = 0
            for i in order:
                recs[i][1] = pos
                pos += recs[i][4] & 0xFF
            new_stride = (pos + 15) & ~15
            frames_out = bytearray()
            for f in range(frames):
                fr = bytearray(new_stride)
                for i, r in enumerate(recs):
                    fr[r[1]:r[1] + (r[4] & 0xFF)] = per_track[i][f]
                frames_out += fr
            if root_slot is None and not rl26_statics and not shift:
                s1_bytes, s2_bytes = raw[s1:s2], raw[s2:s2_end]
            else:
                s1_bytes = b"".join(static_vals)
                s2_bytes = b"".join(struct.pack("<HH", *k) for k in static_kinds)
                s2_bytes += bytes(-len(s2_bytes) % 16)
            self.chunks[key] = {
                "records": b"".join(struct.pack("<IHHHHI", *r) for r in recs),
                "keys": bytes(frames_out),
                "s1": s1_bytes,
                "s2": s2_bytes,
                "stride": new_stride,
                "tracks": len(recs),
                "statics": len(static_kinds),
            }
        for c in self.clips:
            ch = self.chunks[tuple(c.streams)]
            head = bytearray(c.head)
            struct.pack_into("<HH", head, 4, ch["tracks"], ch["statics"])
            struct.pack_into("<H", head, 0x0A, ch["stride"])
            shift = (offsets or {}).get(self.clip_name(c))
            if shift:
                shift_start(head, *shift)
            c.head = bytes(head)
        return converted

    def add_mirrors(self, wanted=None):
        """Append a mirrored "<clip>_m" for every clip (or those whose _m name
        is in `wanted`), with real mirrored data as RL26 expects. Call after
        transcode_tracks. The _m name must already be in the E strings (Rugby
        25 sets carry them). Returns the number of clips added."""
        names = self.names()
        index_of = {n: i for i, n in enumerate(names)}
        joint_mirror = [index_of.get(mirror_name(n), i) for i, n in enumerate(names)]
        E, e0 = self.sections["E"], self.old["E"]
        string_at = {}
        n = struct.unpack_from("<I", E, 0)[0]
        p = 4 + n * 6
        while p < len(E):
            end = E.find(b"\0", p)
            if end < 0:
                break
            string_at.setdefault(E[p:end].decode("latin1"), e0 + p)
            p = end + 1
        added = 0
        for base in list(self.clips):
            mname = self.clip_name(base) + "_m"
            if (wanted is not None and mname not in wanted) or mname not in string_at:
                continue
            ch = self.chunks[tuple(base.streams)]
            mkey = tuple(-(len(self.chunks) * 4 + k + 1) for k in range(4))  # fake addresses
            self.chunks[mkey] = self._mirror_chunk(ch, joint_mirror)
            clip = Clip.__new__(Clip)
            clip.start, clip.header_size = base.start, base.header_size
            clip.sub_offsets = list(base.sub_offsets)
            clip.streams = list(mkey)
            clip.e_target, clip.first_name_target = base.e_target, base.first_name_target
            clip.name_target = string_at[mname]
            clip.head = self._mirror_head(base.head)
            clip.subs = self._mirror_subs(base, names)
            clip.events_target = base.events_target
            self.clips.append(clip)
            added += 1
        self.count = len(self.clips)
        if "B_durations" in self.sections:
            self.sections["B_durations"] = b"".join(c.head[0:4] for c in self.clips)
        return added

    @staticmethod
    def _mirror_chunk(ch, joint_mirror):
        recs = [list(struct.unpack_from("<IHHHHI", ch["records"], i * 16)) for i in range(len(ch["records"]) // 16)]
        keys = bytearray(ch["keys"])
        stride = ch["stride"]
        for r in recs:
            _, off, joint, kind, enc, _ = r
            size = enc & 0xFF
            for f in range(len(keys) // stride):
                p = f * stride + off
                keys[p:p + size] = mirror_key(kind, enc, bytes(keys[p:p + size]))
            r[2] = joint_mirror[joint] if joint < len(joint_mirror) else joint
        n2 = len(ch["s1"]) // 16
        s1, s2 = bytearray(ch["s1"]), bytearray(ch["s2"])
        for i in range(n2):
            kind, joint = struct.unpack_from("<HH", s2, i * 4)
            struct.pack_into("<H", s2, i * 4 + 2, joint_mirror[joint] if joint < len(joint_mirror) else joint)
            s1[i * 16:(i + 1) * 16] = mirror_key(kind & 0xFF, 0x10, bytes(s1[i * 16:(i + 1) * 16]))
        out = dict(ch)
        out.update(records=b"".join(struct.pack("<IHHHHI", *r) for r in recs), keys=bytes(keys),
                   s1=bytes(s1), s2=bytes(s2))
        return out

    @staticmethod
    def _mirror_head(head):
        h = bytearray(head)
        words = list(struct.unpack_from("<10I", h, 0x10))
        for t in (0, 5):  # (left1, right1, left2, right2, centre) at +0x10 and +0x24
            l1, r1, l2, r2, c = words[t:t + 5]
            words[t:t + 5] = [_mirror_vec4byte(v) for v in (r1, l1, r2, l2, c)]
        struct.pack_into("<10I", h, 0x10, *words)
        for pos, quat in ((0x40, 0x48), (0x58, 0x60)):
            struct.pack_into("<f", h, pos, -struct.unpack_from("<f", h, pos)[0])
            x, y, z, w = struct.unpack_from("<4f", h, quat)
            struct.pack_into("<4f", h, quat, x, -y, -z, w)
        struct.pack_into("<f", h, 0x78, -struct.unpack_from("<f", h, 0x78)[0])
        return bytes(h)

    def _mirror_subs(self, base, names):
        subs = [bytearray(s) for s in base.subs]
        s1, s2 = subs[0], subs[1]
        for f in range(len(s1) // 24):
            dx, dy, dz, yaw, cos, sin = struct.unpack_from("<6f", s1, f * 24)
            struct.pack_into("<6f", s1, f * 24, -dx, dy, dz, -yaw, cos, -sin)
        for f in range(len(s2) // 8):
            a, b = struct.unpack_from("<2f", s2, f * 8)
            struct.pack_into("<2f", s2, f * 8, -a, b)
        ev = subs[-1]
        if len(ev) >= 24:
            table = self.event_names(base)
            index = {nm: i for i, nm in enumerate(table)}
            count = struct.unpack_from("<I", ev, 20)[0]
            for k in range(count):
                o = 24 + 8 * k
                if o + 8 > len(ev):
                    break
                i = struct.unpack_from("<I", ev, o + 4)[0]
                if i < len(table):
                    struct.pack_into("<I", ev, o + 4, index.get(mirror_name(table[i]), i))
        return [bytes(s) for s in subs]

    def event_names(self, clip):
        """Event names by index for a clip's events (table in section E:
        count, fnv1a32 hashes, ... - resolved by hash against all strings)."""
        E, t = self.sections["E"], clip.events_target - self.old["E"]
        if not 0 <= t < len(E):  # table outside E: fall back to the raw data
            t, n = clip.events_target, struct.unpack_from("<I", self.raw, clip.events_target)[0]
            hashes = struct.unpack_from(f"<{n}I", self.raw, t + 4)
            by_hash = {fnv1a32(s): s for s in self.strings()}
            return [by_hash.get(h, "") for h in hashes]
        n = struct.unpack_from("<I", E, t)[0]
        offs = struct.unpack_from(f"<{n}H", E, t + 4 + n * 4)
        return [E[t + o:E.index(b"\0", t + o)].decode("latin1") for o in offs]

    def face_tracks(self, clip):
        """[(a, enc, z, per-frame key bytes)] of a clip's face-pose tracks
        (kind 8 on hj_face_loc_driver), in record order - track k carries
        attributes 4k..4k+3 of animationrules' faceNodeAttributes."""
        raw = self.raw
        _, tracks, _, frames, stride = struct.unpack_from("<fHHHH", clip.head, 0)
        s0, s3 = clip.streams[0], clip.streams[3]
        out = []
        for i in range(tracks):
            a, off, _, kind, enc, z = struct.unpack_from("<IHHHHI", raw, s3 + i * 16)
            if kind == 8:
                size = enc & 0xFF
                out.append((a, enc, z, [raw[s0 + f * stride + off:s0 + f * stride + off + size]
                                        for f in range(frames)]))
        return out

    def add_string(self, s):
        """Append a NUL-terminated string to section E; returns its (old-layout)
        absolute position, which build() relocates like any E pointer."""
        E = self.sections["E"]
        pos = self.old["E"] + len(E)
        self.sections["E"] = E + s.encode("latin1") + b"\0"
        return pos

    def add_face_clip(self, donor, name, tracks, duration):
        """Append clip `name` playing `tracks` (face_tracks() of any set, same
        format in RL26 and Rugby 25) on this set's face rig. Header and
        constant channels (head, RL26's fj_* joints) come from `donor`, one of
        this set's clips; face keys are flagged 0x4000 as RL26 stores them.
        Call after transcode_tracks."""
        driver = self.names().index(FACE_DRIVER)
        ch = self.chunks[tuple(donor.streams)]
        recs, pos = [], 0
        for a, enc, z, _ in tracks:
            recs.append((a, pos, driver, 8, enc | FACE_ENC_FLAG, z))
            pos += enc & 0xFF
        stride = (pos + 15) & ~15
        frames = len(tracks[0][3])
        keys = bytearray()
        for f in range(frames):
            fr = bytearray(stride)
            for r, (_, _, _, k) in zip(recs, tracks):
                fr[r[1]:r[1] + len(k[f])] = k[f]
            keys += fr
        mkey = tuple(-(len(self.chunks) * 4 + k + 1) for k in range(4))  # fake addresses
        self.chunks[mkey] = dict(ch, records=b"".join(struct.pack("<IHHHHI", *r) for r in recs),
                                 keys=bytes(keys), stride=stride, tracks=len(recs))
        clip = Clip.__new__(Clip)
        clip.start, clip.header_size = donor.start, donor.header_size
        clip.sub_offsets = list(donor.sub_offsets)
        clip.streams = list(mkey)
        clip.e_target, clip.first_name_target = donor.e_target, donor.first_name_target
        clip.name_target = self.add_string(name)
        head = bytearray(donor.head)
        struct.pack_into("<fHHHH", head, 0, duration, len(recs), ch["statics"], frames, stride)
        clip.head = bytes(head)
        clip.subs = list(donor.subs)
        clip.events_target = donor.events_target
        self.clips.append(clip)
        self.count = len(self.clips)
        if "B_durations" in self.sections:
            self.sections["B_durations"] = b"".join(c.head[0:4] for c in self.clips)
        return clip

    def drop_clip(self, clip):
        self.clips.remove(clip)
        if not any(tuple(c.streams) == tuple(clip.streams) for c in self.clips):
            self.chunks.pop(tuple(clip.streams), None)
        self.count = len(self.clips)
        if "B_durations" in self.sections:
            self.sections["B_durations"] = b"".join(c.head[0:4] for c in self.clips)

    def retarget_event(self, clip, old, new):
        """Make `clip` fire event `new` wherever it fires `old`. Event tables
        (u32 n, n fnv1a32 hashes, n u16 string offsets relative to the table,
        strings) live in E and are shared by a set's clips, so the clip gets
        its own copy, with `new` appended, at the end of E. Returns the number
        of events changed."""
        raw, t = self.raw, clip.events_target
        n = struct.unpack_from("<I", raw, t)[0]
        offs = struct.unpack_from(f"<{n}H", raw, t + 4 + n * 4)
        table = [raw[t + o:raw.index(b"\0", t + o)].decode("latin1") for o in offs]
        if old not in table:
            return 0
        ev = bytearray(clip.subs[-1])
        count = struct.unpack_from("<I", ev, 20)[0] if len(ev) >= 24 else 0
        hits = [24 + 8 * k for k in range(count) if 32 + 8 * k <= len(ev)
                and struct.unpack_from("<I", ev, 28 + 8 * k)[0] == table.index(old)]
        if not hits:
            return 0
        names = table + [new]
        m = len(names)
        head = 4 + m * 6
        strings, offsets = bytearray(), []
        for s in names:
            offsets.append(head + len(strings))
            strings += s.encode("latin1") + b"\0"
        E = self.sections["E"]
        E += bytes(-(self.old["E"] + len(E)) % 4)
        start = self.old["E"] + len(E)
        self.sections["E"] = E + struct.pack(f"<I{m}I{m}H", m, *(fnv1a32(s) for s in names), *offsets) + strings
        for o in hits:
            struct.pack_into("<I", ev, o + 4, m - 1)
        clip.subs[-1] = bytes(ev)
        clip.events_target = start
        return len(hits)

    def add_event(self, clip, name, time):
        """Append event `name` at `time` (seconds) to `clip`: a copy of its event
        table (with `name` added if missing) at the end of E, and one more
        (time, index) pair in its events sub-block (count at +20, pairs from
        +24). Call after retarget_event if both are used on a clip."""
        # event tables live in E; read the current one from the live section (retarget_event
        # may already have moved this clip's table past the original E)
        E, t = self.sections["E"], clip.events_target - self.old["E"]
        n = struct.unpack_from("<I", E, t)[0]
        offs = struct.unpack_from(f"<{n}H", E, t + 4 + n * 4)
        table = [E[t + o:E.index(b"\0", t + o)].decode("latin1") for o in offs]
        ev = bytearray(clip.subs[-1])
        if len(ev) < 24:
            return False
        count = struct.unpack_from("<I", ev, 20)[0]
        if name not in table:
            table.append(name)
            m = len(table)
            head = 4 + m * 6
            strings, offsets = bytearray(), []
            for s in table:
                offsets.append(head + len(strings))
                strings += s.encode("latin1") + b"\0"
            E = self.sections["E"]
            E += bytes(-(self.old["E"] + len(E)) % 4)
            start = self.old["E"] + len(E)
            self.sections["E"] = E + struct.pack(f"<I{m}I{m}H", m, *(fnv1a32(s) for s in table), *offsets) + strings
            clip.events_target = start
        pos = 24 + 8 * count
        ev[pos:pos] = struct.pack("<fI", time, table.index(name))
        struct.pack_into("<I", ev, 20, count + 1)
        clip.subs[-1] = bytes(ev)
        return True

    def build(self):
        if getattr(self, "chunks", None):
            return self.build_relaid()
        return self.build_inplace()

    def build_relaid(self):
        """Layout after transcode_tracks: header, every clip's data chunk
        (records, keys, stream 1, stream 2; 16-byte aligned), clip blocks,
        then A-E."""
        out = bytearray(0x20)
        moved = {}  # old absolute stream target -> new
        for key, ch in self.chunks.items():
            s0, s1, s2, s3 = key
            for name, old in (("records", s3), ("keys", s0), ("s1", s1), ("s2", s2)):
                while len(out) % 16:
                    out.append(0)
                moved[old] = len(out)
                out += ch[name]
        while len(out) % 16:
            out.append(0)
        pos = len(out)
        for c in self.clips:
            c.new_start = pos
            pos += 0x98 + len(c.subs) * 4 + 12 + sum(len(s) for s in c.subs)
        A = pos
        B = A + self.count * 4 + len(self.sections["A_tail"])
        if "B_durations" in self.sections:  # keep_clips: durations, padded so C is 16-aligned
            durations = self.sections["B_durations"]
            self.sections["B"] = durations + bytes(-(B + len(durations)) % 16)
        C = B + len(self.sections["B"])
        D = C + len(self.sections["C"])
        E = D + len(self.sections["D"])
        old_e = self.old["E"]

        def relocate(t):
            if t in moved:
                return moved[t]
            if old_e <= t <= old_e + len(self.sections["E"]):
                return E + (t - old_e)
            raise ValueError(f"pointer to {t:#x} has no new location")

        for c in self.clips:
            assert len(out) == c.new_start
            out += c.build(c.new_start, relocate)
        out += struct.pack(f"<{self.count}I", *(c.new_start for c in self.clips)) + self.sections["A_tail"]
        out += self.sections["B"] + self.sections["C"] + self.sections["D"] + self.sections["E"]
        struct.pack_into("<6I", out, 0, self.count, A, B, C, D, E)
        out[0x18:0x20] = self.pad
        return bytes(out)

    def build_inplace(self):
        old = self.old
        layout = []  # (old_start, old_end, new_start)
        pos = 0x20
        for p in self.pieces:
            if p[0] == "data":
                layout.append((p[1], p[1] + len(p[2]), pos))
                pos += len(p[2])
            else:
                c = p[1]
                size = 0x98 + len(c.subs) * 4 + 12 + sum(len(s) for s in c.subs)
                c.new_start = pos
                pos += size
        A = pos
        B = A + self.count * 4 + len(self.sections["A_tail"])
        C = B + len(self.sections["B"])
        D = C + len(self.sections["C"])
        E = D + len(self.sections["D"])
        layout.append((old["E"], old["E"] + len(self.sections["E"]) + 1, E))

        def relocate(t):
            if t < 0x20:
                return t
            for s, e, n in layout:
                if s <= t < e:
                    return n + (t - s)
            raise ValueError(f"pointer into a clip/section area: {t:#x}")

        out = bytearray(struct.pack("<6I", self.count, A, B, C, D, E)) + self.pad
        for p in self.pieces:
            if p[0] == "data":
                out += p[2]
            else:
                assert len(out) == p[1].new_start
                out += p[1].build(p[1].new_start, relocate)
        out += struct.pack(f"<{self.count}I", *(c.new_start for c in self.clips)) + self.sections["A_tail"]
        out += self.sections["B"] + self.sections["C"] + self.sections["D"] + self.sections["E"]
        return bytes(out)

    def strings(self):
        E = self.old["E"]
        n = struct.unpack_from("<I", self.raw, E)[0]
        return [s.decode("latin1") for s in self.raw[E + 4 + n * 6:].split(b"\0") if s]


def load(blobset_path, name):
    import r25_import as ri
    idx = ri.Index(blobset_path)
    i = idx.find(ri.animset_path(name))
    if i is None:
        raise SystemExit(f"{name} not in {blobset_path}")
    return i, idx.decoded_blob(i)


def cmd_info(args):
    i, raw = load(args.blobset, args.name)
    a = AnimSet(raw)
    chunks = [p for p in a.pieces if p[0] == "data"]
    print(f"entry {i}: {a.count} clips, {len(chunks)} keyframe chunks ({sum(len(p[2]) for p in chunks)} bytes), sections {a.old}")
    for k, c in enumerate(a.clips):
        dur, tracks, x, n, y = struct.unpack_from("<fHHHH", c.head, 0)
        print(f"  clip {k}: header {c.header_size:#x} dur {dur:.3f} tracks {tracks} samples {n} fps {c.head[0x0C]} "
              f"flags {c.flags:#04x} subs {[len(s) for s in c.subs]}")


def cmd_verify(args):
    import r25_import as ri
    import glob
    import re
    names = args.names
    if not names:
        names = sorted(set(re.findall(r'animsetName = "([^"]+)"', "".join(
            open(f, encoding="utf-8-sig").read()
            for f in glob.glob(os.path.join(ri.RL_STOCK, "intermediatelua", "cutscenes", "data", "*.lua"))))))
    ok = bad = 0
    for name in names:
        try:
            _, raw = load(args.blobset, name)
        except SystemExit:
            continue
        try:
            rebuilt = AnimSet(raw).build()
        except Exception as e:
            print(f"  {name}: {e}")
            bad += 1
            continue
        if rebuilt == raw:
            ok += 1
        else:
            bad += 1
            first = next((k for k in range(min(len(raw), len(rebuilt))) if raw[k] != rebuilt[k]), None)
            print(f"  {name}: MISMATCH sizes {len(raw)} vs {len(rebuilt)}, first diff {first}")
    print(f"{ok} rebuilt byte for byte, {bad} failed")
    if bad:
        sys.exit(1)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--blobset", default=pack.BLOBSET_PATH)
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("info")
    p.add_argument("name")
    p.set_defaults(func=cmd_info)
    p = sub.add_parser("verify")
    p.add_argument("names", nargs="*")
    p.set_defaults(func=cmd_verify)
    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
