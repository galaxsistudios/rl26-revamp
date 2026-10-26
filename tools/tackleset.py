#!/usr/bin/env python3
"""
tackleset.py - read / write actionset/tackleset.dat, the compiled tackle
database the game loads at runtime (sim/universe/universe.lua). The Lua files
under intermediatelua/animations/tackles/ are only its build-time source.

Layout (RL26, version 7; little endian; reverse-engineered 2026-10-24 against
the Lua sources and verified by a byte-for-byte rebuild, see `verify`):

  0x00 header, 8 x u32: version, MAGIC, string table A, string table B,
       string table C, node offset table (0x1c), group table, first node
  0x1c node offset table: N x u32 absolute offsets (one per node)
       nodes: N x 0x38 bytes, back to back
  data area: small objects, back to back, referenced by the nodes
  group table: 24 x u32 absolute offsets, then the group objects
  string tables A (every string: clip names, tags, param keys/values, group
       names), B (group names), C (one path per node: entry name, or
       parent name + child clip name)

Every object starts with MAGIC. Pointers are self-relative: in a node they
are relative to the node start; in an object, relative to the object start.

  node (0x38): MAGIC, ->A, clip name (A index), -1, child count, +14 params, +18 tags
       (children only), entry tag lists +1c requiredTags, +20 preferredTags,
       +24 unpreferredTags, +28 bannedTags, +2c outTags, +30 (unused), +34
       child offset array (u32 offsets of the child nodes relative to this
       node, no header)
  list:   MAGIC, ->A, count, count x u32 A index
  params: MAGIC, ->A, count, count x pair (MAGIC, key A index, type 3
          (string), value A index)
  group:  MAGIC, name A index, entry count, 0, ->file start, ->A, ->first
          node, 0x24 (start of the index list), 0x24 + 4 x count (its end),
          entry count x u32 node index
  string table: count, count x u32 fnv1a32(string), count x u32 offset
          (relative to the table), NUL-terminated strings

Mirrored variants are separate nodes: clip names gain "_m", required tags
gain "Mirrored", and the unmirrored entry bans "Mirrored".

Usage:
    python tackleset.py info  [--blobset PATH]
    python tackleset.py verify [--blobset PATH]
    python tackleset.py dump [--blobset PATH] [--group NAME]
"""

import argparse
import os
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pack  # noqa: E402

LOGICAL_PATH = "actionset/tackleset.dat"
MAGIC = 0x80081350
NODE_SIZE = 0x38
NODE_LIST_FIELDS = (0x18, 0x1C, 0x20, 0x24, 0x28, 0x2C, 0x30)
# entry tag lists by Lua key (children use 0x18 for their `tags`)
TAG_FIELDS = {"requiredTags": 0x1C, "preferredTags": 0x20, "unpreferredTags": 0x24,
              "bannedTags": 0x28, "outTags": 0x2C}


def fnv1a32(text):
    h = 0x811C9DC5
    for c in text.encode("latin1"):
        h = ((h ^ c) * 0x01000193) & 0xFFFFFFFF
    return h


def read_strtab(raw, off):
    n = struct.unpack_from("<I", raw, off)[0]
    offs = struct.unpack_from(f"<{n}I", raw, off + 4 + 4 * n)
    return [raw[off + o:raw.index(b"\0", off + o)].decode("latin1") for o in offs]


def build_strtab(strings):
    n = len(strings)
    out = bytearray(struct.pack("<I", n))
    out += struct.pack(f"<{n}I", *(fnv1a32(s) for s in strings))
    pos = 4 + 8 * n
    offs, blob = [], bytearray()
    for s in strings:
        offs.append(pos + len(blob))
        blob += s.encode("latin1") + b"\0"
    out += struct.pack(f"<{n}I", *offs) + blob
    return bytes(out)


class Node:
    __slots__ = ("path", "name", "f0c", "children", "params", "lists")

    def __init__(self, path, name, f0c=-1, children=None, params=None, lists=None):
        self.path = path            # table C string
        self.name = name            # clip name
        self.f0c = f0c
        self.children = children or []   # node indices
        self.params = params        # list of (key, value) strings, or None
        self.lists = lists or {}    # field offset -> list of strings


class TackleSet:
    def __init__(self, version, strings, groups_b, nodes, groups, order):
        self.version = version
        self.strings = strings      # table A
        self.groups_b = groups_b    # table B
        self.nodes = nodes
        self.groups = groups        # list of (name, [node indices])
        self.order = order          # data-area object order: (node index, field)

    @classmethod
    def parse(cls, raw):
        version, magic, a_off, b_off, c_off, nt_off, g_off, first = struct.unpack_from("<8I", raw, 0)
        assert magic == MAGIC and nt_off == 0x1C
        A = read_strtab(raw, a_off)
        B = read_strtab(raw, b_off)
        C = read_strtab(raw, c_off)
        n = len(C)
        node_offs = struct.unpack_from(f"<{n}I", raw, nt_off)
        by_off = {o: i for i, o in enumerate(node_offs)}
        nodes, spans = [], []
        for i, o in enumerate(node_offs):
            m, _, name, f0c, nchild = struct.unpack_from("<IiIiI", raw, o)
            assert m == MAGIC
            node = Node(C[i], A[name], f0c)
            for f in range(0x14, NODE_SIZE, 4):
                v = struct.unpack_from("<i", raw, o + f)[0]
                if not v:
                    continue
                t = o + v
                spans.append((t, i, f))
                if f == 0x34:
                    node.children = [by_off[o + c] for c in struct.unpack_from(f"<{nchild}I", raw, t)]
                elif f == 0x14:
                    cnt = struct.unpack_from("<I", raw, t + 8)[0]
                    pairs = []
                    for k in range(cnt):
                        pm, key, typ, val = struct.unpack_from("<4I", raw, t + 12 + 16 * k)
                        assert pm == MAGIC and typ == 3
                        pairs.append((A[key], A[val]))
                    node.params = pairs
                else:
                    cnt = struct.unpack_from("<I", raw, t + 8)[0]
                    node.lists[f] = [A[x] for x in struct.unpack_from(f"<{cnt}I", raw, t + 12)]
            nodes.append(node)
        order = [(i, f) for _, i, f in sorted(spans)]
        group_offs = struct.unpack_from(f"<{len(B)}I", raw, g_off)
        groups = []
        for go in group_offs:
            m, name, cnt = struct.unpack_from("<3I", raw, go)
            groups.append((A[name], list(struct.unpack_from(f"<{cnt}I", raw, go + 0x24))))
        return cls(version, A, B, nodes, groups, order)

    def build(self):
        A = list(self.strings)
        a_idx = {s: i for i, s in enumerate(A)}

        def idx(s):
            if s not in a_idx:
                a_idx[s] = len(A)
                A.append(s)
            return a_idx[s]

        n = len(self.nodes)
        nt_off = 0x1C
        first = nt_off + 4 * n
        data0 = first + NODE_SIZE * n
        node_off = [first + NODE_SIZE * i for i in range(n)]
        # every node field that holds an object, in the original order first
        seen = set(self.order)
        order = list(self.order)
        for i, node in enumerate(self.nodes):
            fields = ([0x14] if node.params is not None else []) + sorted(node.lists) + \
                     ([0x34] if node.children else [])
            for f in fields:
                if (i, f) not in seen:
                    order.append((i, f))

        # lay the data area out; string table A's position is only known after
        # this, so collect objects as (offset, builder) and fix ->A later
        objs, pos, ptrs = [], data0, {}
        for i, f in order:
            node = self.nodes[i]
            if f == 0x34:
                size = 4 * len(node.children)
            elif f == 0x14:
                size = 12 + 16 * len(node.params)
            else:
                size = 12 + 4 * len(node.lists[f])
            ptrs[(i, f)] = pos
            objs.append((pos, i, f))
            pos += size
        g_off = pos
        group_objs, gpos = [], g_off + 4 * len(self.groups)
        for name, members in self.groups:
            group_objs.append(gpos)
            gpos += 0x24 + 4 * len(members)
        for name, _ in self.groups:
            idx(name)
        for node in self.nodes:
            idx(node.name)
            if node.params:
                for k, v in node.params:
                    idx(k), idx(v)
            for lst in node.lists.values():
                for s in lst:
                    idx(s)
        a_off = gpos
        a_bytes = build_strtab(A)
        b_off = a_off + len(a_bytes)
        b_bytes = build_strtab(list(self.groups_b) + [g for g, _ in self.groups if g not in self.groups_b])
        c_off = b_off + len(b_bytes)
        c_bytes = build_strtab([node.path for node in self.nodes])

        out = bytearray(c_off + len(c_bytes))
        struct.pack_into("<8I", out, 0, self.version, MAGIC, a_off, b_off, c_off, nt_off, g_off, first)
        struct.pack_into(f"<{n}I", out, nt_off, *node_off)
        for i, node in enumerate(self.nodes):
            o = node_off[i]
            struct.pack_into("<IiIiI", out, o, MAGIC, a_off - o, a_idx[node.name], node.f0c, len(node.children))
            for f in range(0x14, NODE_SIZE, 4):
                if (i, f) in ptrs:
                    struct.pack_into("<i", out, o + f, ptrs[(i, f)] - o)
        for t, i, f in objs:
            node = self.nodes[i]
            if f == 0x34:
                struct.pack_into(f"<{len(node.children)}I", out, t,
                                 *(node_off[c] - node_off[i] for c in node.children))
            elif f == 0x14:
                struct.pack_into("<IiI", out, t, MAGIC, a_off - t, len(node.params))
                for k, (key, val) in enumerate(node.params):
                    struct.pack_into("<4I", out, t + 12 + 16 * k, MAGIC, a_idx[key], 3, a_idx[val])
            else:
                lst = node.lists[f]
                struct.pack_into(f"<IiI{len(lst)}I", out, t, MAGIC, a_off - t, len(lst), *(a_idx[s] for s in lst))
        struct.pack_into(f"<{len(group_objs)}I", out, g_off, *group_objs)
        for go, (name, members) in zip(group_objs, self.groups):
            struct.pack_into(f"<4I5i{len(members)}I", out, go, MAGIC, a_idx[name], len(members), 0,
                             -go, a_off - go, first - go, 0x24, 0x24 + 4 * len(members), *members)
        out[a_off:a_off + len(a_bytes)] = a_bytes
        out[b_off:b_off + len(b_bytes)] = b_bytes
        out[c_off:] = c_bytes
        return bytes(out)


def read_from_index(blobset_path):
    import r25_import as ri
    idx = ri.Index(blobset_path)
    i = idx.find(LOGICAL_PATH)
    return i, idx.decoded_blob(i)


def cmd_info(args):
    i, raw = read_from_index(args.blobset)
    ts = TackleSet.parse(raw)
    print(f"entry {i}: version {ts.version}, {len(ts.nodes)} nodes, {len(ts.strings)} strings, {len(raw)} bytes")
    for name, members in ts.groups:
        print(f"  {name:18s} {len(members):4d} entries")


def cmd_dump(args):
    _, raw = read_from_index(args.blobset)
    ts = TackleSet.parse(raw)
    for name, members in ts.groups:
        if args.group and name != args.group:
            continue
        print(f"== {name}")
        for m in members:
            node = ts.nodes[m]
            lists = {f"+{f:02x}": v for f, v in sorted(node.lists.items())}
            print(f"  [{m}] {node.path} {lists} params={node.params}")
            for c in node.children:
                ch = ts.nodes[c]
                print(f"      - {ch.path[len(node.path):]} params={ch.params} tags={ch.lists.get(0x18)}")


def cmd_verify(args):
    i, raw = read_from_index(args.blobset)
    rebuilt = TackleSet.parse(raw).build()
    if rebuilt == raw:
        print(f"OK: entry {i} rebuilt byte for byte ({len(raw)} bytes)")
        return
    first = next((k for k in range(min(len(raw), len(rebuilt))) if raw[k] != rebuilt[k]), None)
    print(f"MISMATCH: sizes {len(raw)} vs {len(rebuilt)}, first difference at {first:#x}" if first is not None
          else f"MISMATCH: sizes {len(raw)} vs {len(rebuilt)}")
    sys.exit(1)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--blobset", default=pack.BLOBSET_PATH)
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("info").set_defaults(func=cmd_info)
    sub.add_parser("verify").set_defaults(func=cmd_verify)
    p = sub.add_parser("dump")
    p.add_argument("--group")
    p.set_defaults(func=cmd_dump)
    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
