#!/usr/bin/env python3
"""
playset.py - read/write RL26's compiled play sets (plays/playset.dat, plays/formationset.dat).

The game never reads intermediatelua/plays/*.lua: universe.lua loads these binaries through the native play
set manager. Both use one layout (little-endian u32/f32; MARK = 0x80081350 starts each object; offsets inside
an object are relative to that object's MARK, root offsets to the file start):

  0x00 u32 10, MARK, u32 strings, u32 names, u32 records(0x14)
  records: u32 abs offset per play (count = names count), then the plays:
    MARK, u32 name (string-table index), slice, startingRole, focusRole, nParticipants, participantList,
         required, preferred, unpreferred, banned            (tag lists; 0 = none)
    participantList: u32 offset per participant
    participant: MARK, u32 role, f32 delay, u32 nStates, then nStates x
                 (MARK, f32 x, f32 y, f32 radius, u32 gait, u32 mechanic, u32 target)
    tag list: MARK, u32 offset to the string table, u32 count, u32 string-table index per tag
  string table (all names + tags, first-use order) and name table (play names, record order), each:
    u32 n, u32 fnv1a32 hash x n, u32 offset (from the table start) x n, NUL-terminated strings

The Lua files' `fixed`, `subRole` and `requirePerfectSliceMatch` aren't stored. Stock plays are sorted by
name, case-insensitively.
"""

import struct

MARK = 0x80081350
TAG_KEYS = ('requiredTags', 'preferredTags', 'unpreferredTags', 'bannedTags')


def fnv1a32(text):
    h = 0x811c9dc5
    for c in text.encode('utf-8'):
        h = ((h ^ c) * 0x01000193) & 0xffffffff
    return h


def _u(d, o):
    return struct.unpack_from('<I', d, o)[0]


def _f(d, o):
    return struct.unpack_from('<f', d, o)[0]


def _mark(d, o):
    if _u(d, o) != MARK:
        raise ValueError('no object marker at 0x%x' % o)


def _read_table(d, o):
    n = _u(d, o)
    hashes = [_u(d, o + 4 + 4 * i) for i in range(n)]
    strings = []
    for i in range(n):
        s = o + _u(d, o + 4 + 4 * n + 4 * i)
        strings.append(d[s:d.index(b'\0', s)].decode('utf-8'))
    for h, s in zip(hashes, strings):
        if fnv1a32(s) != h:
            raise ValueError('hash mismatch for %r' % s)
    return strings


def read(data):
    if _u(data, 0) != 10:
        raise ValueError('unexpected version %d' % _u(data, 0))
    _mark(data, 4)
    strings = _read_table(data, _u(data, 8))
    names = _read_table(data, _u(data, 12))
    rec = _u(data, 16)
    plays = []
    for i, name in enumerate(names):
        r = _u(data, rec + 4 * i)
        _mark(data, r)
        if strings[_u(data, r + 4)] != name:
            raise ValueError('record %d name index mismatch' % i)
        play = {'name': name, 'slice': _u(data, r + 8),
                'startingRole': _u(data, r + 12), 'focusRole': _u(data, r + 16)}
        n_part, plist = _u(data, r + 20), r + _u(data, r + 24)
        for k, key in enumerate(TAG_KEYS):
            off = _u(data, r + 28 + 4 * k)
            if off:
                t = r + off
                _mark(data, t)
                play[key] = [strings[_u(data, t + 12 + 4 * j)] for j in range(_u(data, t + 8))]
        parts = []
        for j in range(n_part):
            p = r + _u(data, plist + 4 * j)
            _mark(data, p)
            states = []
            for s in range(_u(data, p + 12)):
                q = p + 16 + 28 * s
                _mark(data, q)
                states.append({'xPosition': _f(data, q + 4), 'yPosition': _f(data, q + 8), 'radius': _f(data, q + 12),
                               'gait': _u(data, q + 16), 'mechanic': _u(data, q + 20), 'target': _u(data, q + 24)})
            parts.append({'role': _u(data, p + 4), 'delay': _f(data, p + 8), 'states': states})
        play['participants'] = parts
        plays.append(play)
    return plays


def _table(strings):
    n = len(strings)
    out = bytearray(struct.pack('<I', n))
    for s in strings:
        out += struct.pack('<I', fnv1a32(s))
    blobs = [s.encode('utf-8') + b'\0' for s in strings]
    pos = 4 + 8 * n
    for b in blobs:
        out += struct.pack('<I', pos)
        pos += len(b)
    for b in blobs:
        out += b
    return bytes(out)


def write(plays):
    """Plays are written in the order given (keep them sorted by name, as stock is)."""
    strings, index = [], {}

    def intern(s):
        if s not in index:
            index[s] = len(strings)
            strings.append(s)
        return index[s]

    records = []
    for play in plays:
        intern(play['name'])
        parts = play['participants']
        head = 44 + 4 * len(parts)
        part_blobs = []
        for p in parts:
            b = bytearray(struct.pack('<IIfI', MARK, p['role'], p['delay'], len(p['states'])))
            for st in p['states']:
                b += struct.pack('<IfffIII', MARK, st['xPosition'], st['yPosition'], st['radius'], st['gait'],
                                 st['mechanic'], st['target'])
            part_blobs.append(bytes(b))
        part_offs, pos = [], head
        for b in part_blobs:
            part_offs.append(pos)
            pos += len(b)
        tag_lists = []
        for key in TAG_KEYS:
            tags = play.get(key)
            tag_lists.append([intern(t) for t in tags] if tags else None)
        records.append([play, head, part_offs, part_blobs, pos, tag_lists])

    rec_table = 20
    first = rec_table + 4 * len(plays)
    # tag lists point at the string table, so lay the records out first
    starts, pos = [], first
    sizes = []
    for play, head, part_offs, part_blobs, body_end, tag_lists in records:
        size = body_end + sum(12 + 4 * len(t) for t in tag_lists if t is not None)
        starts.append(pos)
        sizes.append(size)
        pos += size
    str_off = pos
    str_blob = _table(strings)
    name_off = str_off + len(str_blob)
    name_blob = _table([p['name'] for p in plays])

    out = bytearray(struct.pack('<IIIII', 10, MARK, str_off, name_off, rec_table))
    for s in starts:
        out += struct.pack('<I', s)
    for (play, head, part_offs, part_blobs, body_end, tag_lists), start in zip(records, starts):
        tag_offs, t = [], body_end
        for tl in tag_lists:
            if tl is None:
                tag_offs.append(0)
            else:
                tag_offs.append(t)
                t += 12 + 4 * len(tl)
        out += struct.pack('<IIIIIII', MARK, index[play['name']], play['slice'],
                           play.get('startingRole', 0), play['focusRole'], len(part_offs), 44)
        out += struct.pack('<IIII', *tag_offs)
        for o in part_offs:
            out += struct.pack('<I', o)
        for b in part_blobs:
            out += b
        for tl, toff in zip(tag_lists, tag_offs):
            if tl is not None:
                out += struct.pack('<III', MARK, str_off - (start + toff), len(tl))
                out += struct.pack('<%dI' % len(tl), *tl)
    out += str_blob + name_blob
    return bytes(out)
