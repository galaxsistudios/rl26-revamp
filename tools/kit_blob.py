#!/usr/bin/env python3
"""
kit_blob.py - exact reader/writer for a club's kit (uniform) list: the
BC ED 34 12 blob that trails each club record in defaultdata_clubs (the same
bytes ship as 39954's NNNNNN.clubdata). data_mods.py's "uniforms" overrides
go through this, so kits can be copied between clubs, renamed, reordered and
added past a club's stored capacity. `encode(decode(x)) == x` for every
stock club.

Layout (worked out 2026-10-22..26, see data_mods._uniform_layout too):
    magic u32, u16 version (1), u16 type count,
    per type: u32 name hash, u16 index      (paUniform, paTeamVisualConfig,
                                             the club root, paUuid)
    per type: u16 field count, u32 byte size, fields:
        u32 FNV-1a32 name, u32 byte offset, u16 tag, u16 count
        tag 0xFDEB u8, 0xFDE8 bool, 0xFDED u16, 0xFDEF u32, 0xFDF1 8-byte
        ref; a small tag is the index of a nested type.
    then one instance of the root type (index 2):
        u16 kit count, `capacity` kit records (type 0: 25-byte name,
        m_config = the kit's visual config (type 1), m_isNines, and on newer
        clubs isHidden), u16 7, 7 per-category default kit indices
        (Home = 0, Away = 1, ...).
Fields are packed in offset order with no gaps.

The schema is per club: 8 different field sets ship (231-382 config fields;
a field a club doesn't store takes the engine default). Kit capacity is the
array count in the schema: 20 on most current clubs, 8 on older ones. The
engine's own limit is a runtime field (native uniformCanCreateCount =
[list+0x31c] - [list+0x318], rugbyleague1.exe 0xfad360) set to 20 by its
constructor (0x5b9af9); whether a club saved with more than 20 loads them
all is untested, so growing past NATIVE_CAPACITY prints a warning.

Usage:
    python tools/kit_blob.py list <defaultdata_clubs> [club id ...]
"""

import argparse
import collections
import struct
import sys

MAGIC = b"\xBC\xED\x34\x12"
TAG_WIDTH = {0xFDEB: 1, 0xFDE8: 1, 0xFDED: 2, 0xFDEF: 4, 0xFDF1: 8}
TAG_FMT = {0xFDEB: "<B", 0xFDE8: "<B", 0xFDED: "<H", 0xFDEF: "<I"}
KIT, CONFIG, ROOT = 0, 1, 2  # type indices
NAME_LEN = 25
NATIVE_CAPACITY = 20


def fnv1a32(s):
    h = 0x811C9DC5
    for c in s.encode():
        h = ((h ^ c) * 0x01000193) & 0xFFFFFFFF
    return h


H_NAME, H_CONFIG = fnv1a32("name"), fnv1a32("m_config")
H_HIDDEN, H_NINES = fnv1a32("isHidden"), fnv1a32("m_isNines")
# root fields (names unknown, hashes only)
H_COUNT, H_KITS, H_NDEFAULTS, H_DEFAULTS = 0xE7B5BC4F, 0x85C85886, 0xF2F84E62, 0xB9828109


class Schema:
    def __init__(self, version, type_names, types):
        self.version = version
        self.type_names = type_names  # [(hash, index)]
        self.types = types            # [[size, [[hash, offset, tag, count], ...]]]

    def fields(self, t):
        return {f[0]: f for f in self.types[t][1]}

    def width(self, tag, count):
        if tag in TAG_WIDTH:
            return TAG_WIDTH[tag] * count
        return self.types[tag][0] * count

    def repack(self):
        """Recompute every offset and size from field order (nested types
        first), after a field count changed."""
        def pack(t, done):
            if t in done:
                return
            for f in self.types[t][1]:
                if f[2] not in TAG_WIDTH:
                    pack(f[2], done)
            off = 0
            for f in sorted(self.types[t][1], key=lambda f: f[1]):
                f[1] = off
                off += self.width(f[2], f[3])
            self.types[t][0] = off
            done.add(t)
        done = set()
        for t in range(len(self.types)):
            pack(t, done)

    def copy(self):
        return Schema(self.version, list(self.type_names),
                      [[size, [list(f) for f in fields]] for size, fields in self.types])

    def to_bytes(self):
        out = bytearray(MAGIC) + struct.pack("<HH", self.version, len(self.types))
        for h, i in self.type_names:
            out += struct.pack("<IH", h, i)
        for size, fields in self.types:
            out += struct.pack("<HI", len(fields), size)
            for h, off, tag, count in fields:
                out += struct.pack("<IIHH", h, off, tag, count)
        return bytes(out)


def _read_schema(blob):
    if blob[:4] != MAGIC:
        raise ValueError("not a kit blob (no BC ED 34 12 magic)")
    version, ntypes = struct.unpack_from("<HH", blob, 4)
    p = 8
    type_names = [struct.unpack_from("<IH", blob, p + 6 * i) for i in range(ntypes)]
    p += 6 * ntypes
    types = []
    for _ in range(ntypes):
        nfields, size = struct.unpack_from("<HI", blob, p)
        p += 6
        fields = [list(struct.unpack_from("<IIHH", blob, p + 12 * i)) for i in range(nfields)]
        p += 12 * nfields
        types.append([size, fields])
    return Schema(version, type_names, types), p


def _read_struct(schema, t, blob, pos):
    """{hash: bytes} for leaf fields, {hash: [struct, ...]} for nested ones."""
    out = {}
    for h, off, tag, count in schema.types[t][1]:
        if tag in TAG_WIDTH:
            w = TAG_WIDTH[tag] * count
            out[h] = bytes(blob[pos + off:pos + off + w])
        else:
            size = schema.types[tag][0]
            out[h] = [_read_struct(schema, tag, blob, pos + off + i * size) for i in range(count)]
    return out


def _write_struct(schema, t, value, out, pos):
    for h, off, tag, count in schema.types[t][1]:
        v = value[h]
        if tag in TAG_WIDTH:
            out[pos + off:pos + off + len(v)] = v
        else:
            size = schema.types[tag][0]
            for i, item in enumerate(v):
                _write_struct(schema, tag, item, out, pos + off + i * size)


def decode(blob):
    schema, p = _read_schema(blob)
    root = _read_struct(schema, ROOT, blob, p)
    if p + schema.types[ROOT][0] != len(blob):
        raise ValueError(f"kit blob is {len(blob)} bytes, schema says {p + schema.types[ROOT][0]}")
    return schema, root


def encode(schema, root):
    head = schema.to_bytes()
    out = bytearray(len(head) + schema.types[ROOT][0])
    out[:len(head)] = head
    _write_struct(schema, ROOT, root, out, len(head))
    return bytes(out)


def zero_struct(schema, t):
    return _read_struct(schema, t, bytes(schema.types[t][0]), 0)


def field_defaults(blobs):
    """Most common value of every kit / kit-config field across these kit
    blobs (one per club): {(type, hash): bytes}. A field a club's schema
    doesn't store takes the engine default; this is the best guess at it."""
    seen = collections.defaultdict(collections.Counter)
    for blob in blobs:
        kits = KitList(blob)
        for kit in kits.kits:
            for t, rec in ((KIT, kit), (CONFIG, kit[H_CONFIG][0])):
                for h, v in rec.items():
                    if isinstance(v, bytes):
                        seen[(t, h)][v] += 1
    return {key: c.most_common(1)[0][0] for key, c in seen.items()}


class KitList:
    """A club's kits as an editable list. self.kits holds the used records
    (dicts from _read_struct); unused capacity is rebuilt on to_bytes()."""

    def __init__(self, blob):
        self.schema, root = decode(blob)
        self.root = root
        count = struct.unpack("<H", root[H_COUNT])[0]
        self.kits = root[H_KITS][:count]
        self.spare = root[H_KITS][count:]  # kept as-is while the count fits
        self.defaults = list(root[H_DEFAULTS])
        self.default_names = [self.name(self.kits[i]) if i < len(self.kits) else None for i in self.defaults]
        self.default_kits = [self.kits[i] if i < len(self.kits) else None for i in self.defaults]

    @property
    def capacity(self):
        return self.schema.fields(ROOT)[H_KITS][3]

    @staticmethod
    def name(kit):
        return kit[H_NAME].split(b"\0")[0].decode("latin1")

    def names(self):
        return [self.name(k) for k in self.kits]

    def index(self, name):
        names = self.names()
        if name not in names:
            raise KeyError(f"no kit {name!r} (has {names})")
        return names.index(name)

    def get(self, name):
        return self.kits[self.index(name)]

    def set_name(self, kit, name):
        raw = name.encode("latin1")
        if len(raw) >= NAME_LEN:
            raise ValueError(f"kit name {name!r} is longer than {NAME_LEN - 1} characters")
        kit[H_NAME] = raw.ljust(NAME_LEN, b"\0")

    def set_hidden(self, kit, hidden):
        if H_HIDDEN in kit:
            kit[H_HIDDEN] = bytes([1 if hidden else 0])
        elif hidden:
            raise ValueError("this club's kit schema has no isHidden field, so a kit can't be hidden")

    def set_config(self, kit, field_name, value):
        f = self.schema.fields(CONFIG).get(fnv1a32(field_name))
        if f is None or f[2] not in TAG_FMT:
            raise KeyError(f"kit config has no plain field {field_name!r}")
        kit[H_CONFIG][0][f[0]] = struct.pack(TAG_FMT[f[2]], value)

    def adopt(self, kit, other, fill):
        """A copy of `kit` (from KitList `other`) in this list's schema.
        Fields this schema lacks are dropped - but only if the kit holds the
        default value there, otherwise the copy would change its look.
        Fields only this schema has get `fill` (field_defaults)."""
        if other.schema.types == self.schema.types:
            return _deep_copy(kit)

        def convert(t, value, src_schema):
            dst = self.schema.fields(t)
            src = src_schema.fields(t)
            out = {}
            for h, (_h, _off, tag, count) in dst.items():
                if h in value:
                    v = value[h]
                    out[h] = [convert(tag, item, src_schema) for item in v] if tag not in TAG_WIDTH else v
                elif tag in TAG_WIDTH:
                    out[h] = fill.get((t, h), bytes(TAG_WIDTH[tag] * count))
                else:
                    out[h] = [zero_struct(self.schema, tag) for _ in range(count)]
            for h, v in value.items():
                if h not in dst and isinstance(v, bytes) and v != fill.get((t, h), v):
                    raise ValueError(
                        f"kit {self.name(kit)!r}: field {h:#010x} = {v.hex()} isn't in the target club's kit "
                        f"schema and isn't the default ({fill[(t, h)].hex()}) - copying would change the kit")
            return out
        return convert(KIT, kit, other.schema)

    def insert(self, kit, index=None):
        if index is None:
            self.kits.append(kit)
        else:
            self.kits.insert(index, kit)

    def remap_defaults(self):
        """Point each category default at the kit now carrying the name it
        pointed at before (so a kit promoted to "HOME" becomes the Home
        default), else at the same kit as before, else at kit 0."""
        names = self.names()
        for i, (name, kit) in enumerate(zip(self.default_names, self.default_kits)):
            if name in names:
                self.defaults[i] = names.index(name)
            elif any(k is kit for k in self.kits):
                self.defaults[i] = next(j for j, k in enumerate(self.kits) if k is kit)
            else:
                self.defaults[i] = 0

    def to_bytes(self):
        self.remap_defaults()
        count = len(self.kits)
        cap = self.capacity
        if count > cap:
            if count > NATIVE_CAPACITY:
                print(f"    WARNING: kit capacity {cap} -> {count}: past the engine's {NATIVE_CAPACITY} "
                      f"(untested - check every kit shows in-game)")
            schema = self.schema.copy()
            schema.fields(ROOT)[H_KITS][3] = count
            schema.repack()
            self.schema, cap, self.spare = schema, count, []
        spare = self.spare[:cap - count]
        spare += [zero_struct(self.schema, KIT) for _ in range(cap - count - len(spare))]
        root = dict(self.root)
        root[H_COUNT] = struct.pack("<H", count)
        root[H_KITS] = self.kits + spare
        root[H_DEFAULTS] = bytes(self.defaults)
        return encode(self.schema, root)


def _deep_copy(v):
    if isinstance(v, dict):
        return {k: _deep_copy(x) for k, x in v.items()}
    if isinstance(v, list):
        return [_deep_copy(x) for x in v]
    return v


def apply_spec(blob, spec, club_blob, fill, label="", verbose=True):
    """Apply one data mod "uniforms" spec to a club's kit blob, in order:
        "from": <club id>   start from that club's stock kit list instead
        "rename": {old: new, ...}   all at once, so names can be swapped
        "add": [{"name": ..., "copyOf": <kit name>, "fromClub": <club id>,
                 "index": <position>, "hidden": bool, "set": {field: value}}]
              a copy of kit copyOf (from club fromClub, default this one),
              renamed, inserted at index (default: the end), with isHidden
              set (default false) and `set` applied to its config
        "order": [names]    move these kits to the front, in this order
        "hide": [names]     set isHidden on these kits (clubs whose schema
                            stores it)
    The per-category defaults follow names (see KitList.remap_defaults).
    club_blob(id) returns a club's stock kit blob. Returns the new blob."""
    kits = KitList(club_blob(spec["from"]) if "from" in spec else blob)
    if "from" in spec and verbose:
        print(f"    {label} kits from club {spec['from']}: {kits.names()}")
    renames = spec.get("rename", {})
    targets = [kits.get(old) for old in renames]
    for kit, new in zip(targets, renames.values()):
        kits.set_name(kit, new)
    if renames and verbose:
        print(f"    {label} renamed {renames}")
    for add in spec.get("add", []):
        if add["name"] in kits.names():
            raise ValueError(f"{label} already has a kit named {add['name']!r}")
        source = KitList(club_blob(add["fromClub"])) if "fromClub" in add else kits
        kit = kits.adopt(source.get(add["copyOf"]), source, fill)
        kits.set_name(kit, add["name"])
        kits.set_hidden(kit, add.get("hidden", False))
        for field_name, value in add.get("set", {}).items():
            kits.set_config(kit, field_name, value)
        kits.insert(kit, add.get("index"))
        if verbose:
            src = f"club {add['fromClub']} " if "fromClub" in add else ""
            print(f"    {label} kit {kits.names().index(add['name'])}: {add['name']!r} "
                  f"(copy of {src}{add['copyOf']!r}{', hidden' if add.get('hidden') else ''}"
                  f"{', ' + str(add['set']) if add.get('set') else ''})")
    if "order" in spec:
        front = [kits.get(n) for n in spec["order"]]
        kits.kits = front + [k for k in kits.kits if not any(k is f for f in front)]
        if verbose:
            print(f"    {label} order: {kits.names()}")
    for name in spec.get("hide", []):
        kits.set_hidden(kits.get(name), True)
    if spec.get("hide") and verbose:
        print(f"    {label} hidden: {spec['hide']}")
    return kits.to_bytes()


def main():
    sys.path.insert(0, __file__.rsplit("\\", 1)[0].rsplit("/", 1)[0])
    import bigant_db
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("list", help="each club's kits (and check the codec round-trips)")
    p.add_argument("clubs")
    p.add_argument("ids", nargs="*", type=int)
    args = ap.parse_args()
    db = bigant_db.load(open(args.clubs, "rb").read())
    for rec in db.records:
        cid = rec["tables"][0]["id"]
        if args.ids and cid not in args.ids:
            continue
        kits = KitList(rec["blob"])
        ok = "" if kits.to_bytes() == rec["blob"] else "  ROUND TRIP MISMATCH"
        hidden = {kits.name(k) for k in kits.kits if k.get(H_HIDDEN) == b"\x01"}
        names = [n + (" (hidden)" if n in hidden else "") for n in kits.names()]
        print(f"{cid:4d} {rec['tables'][0].get('fullName')!r}: {len(kits.kits)}/{kits.capacity} {names}{ok}")


if __name__ == "__main__":
    sys.exit(main())
