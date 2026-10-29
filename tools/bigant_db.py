#!/usr/bin/env python3
"""
bigant_db.py - exact reader/writer for Big Ant's self-describing record
databases: defaultdata_players, _npcs, _clubs and _leagues. Works for RL26
and Rugby League Live 4 alike. Unlike
the heuristic parse_*.py readers (anchor search + backtracking widths), this
decodes the file from its own schema, so every record and field is found
exactly and `dump(load(x)) == x` byte for byte (checked on both games'
defaultdata_players, and on RL26's _npcs, _clubs and _leagues). That makes
whole records addable or resizable, which the in-place patching in
data_mods.py can't do.

Layout (worked out 2026-10-26):
    u8 version (RL26 16, RLL4 12), u8 table count, then per table:
        u8 table id, u8-len name, u32 field count,
        fields: u8 type, u8-len name, u8-len category
    u32 record count, then per record, one of two forms:
        players / npcs: u32 80085 (record tag), u32 visual size, visual blob
            (the record's CCharacterVisualConfig, magic BC ED 34 12 in RL26),
            then the tables;
        clubs / leagues: u32 80085, the tables, then (clubs only) u32 size +
            a trailing blob: the club's kit list (BC ED 34 12, see
            kit_blob.py). The same bytes ship as 39954's NNNNNN.clubdata.
    Tables, in order: u8 present flag, and if 1 the table's fields as u8
    present flag + value.
Field types: 0 = never written, 1 = u8, 2 / 3 / 5 / 7 = u32 (int, enum,
hash), 4 = u8-length latin-1 string, 6 = RGB (3 bytes), 8 = 5 bytes (a
lineup slot: u32 player id + u8 position tag). An absent field (flag 0)
takes the design default. A name repeated within a table (leagues' "clubs",
lineups' "Substitute") is keyed "name", "name[1]", "name[2]", ...

Clubs: table 0 is "clubList" (id, names, frontendVisible, colours, ...), then
the roster and one lineup table per match type. Leagues: one "identity"
table, whose "clubs" fields list the member club ids.

Players: table 0 is "players" (id, firstname, surname, ... skills), tables 1
and 2 are the StandardMatch / Nines career stats. Club membership is not a
player field: it lives in each club's roster in defaultdata_clubs, so a
player on no roster is a free agent.

Usage:
    python tools/bigant_db.py schema <file>
    python tools/bigant_db.py show <file> <id>
"""

import argparse
import struct
import sys

RECORD_TAG = 80085
WIDTH = {1: 1, 2: 4, 3: 4, 5: 4, 6: 3, 7: 4, 8: 5}
BLOB_MAGIC = b"\xBC\xED\x34\x12"


class Table:
    def __init__(self, tid, name, fields):
        self.tid, self.name, self.fields = tid, name, fields  # fields: [(type, name, category)]
        seen = {}
        self.keys = []  # unique per-field dict keys (a repeated name gets "[n]")
        for _typ, fname, _cat in fields:
            n = seen.get(fname, 0)
            seen[fname] = n + 1
            self.keys.append(fname if n == 0 else f"{fname}[{n}]")


class Database:
    def __init__(self, header, tables, records, trailer=b"", table_flags=True):
        self.header = header    # schema bytes (everything before the record count)
        self.tables = tables
        self.table_flags = table_flags  # False for leagues: no per-table present byte
        # [{"visual": bytes | None, "tables": [dict | None, ...], "blob": bytes | None}]
        # (visual: players/npcs, before the tables; blob: clubs, after them)
        self.records = records
        self.trailer = trailer

    def by_id(self):
        return {r["tables"][0]["id"]: r for r in self.records if r["tables"][0] and "id" in r["tables"][0]}


class _Reader:
    def __init__(self, data, pos=0):
        self.d, self.p = data, pos

    def u8(self):
        self.p += 1
        return self.d[self.p - 1]

    def u32(self):
        self.p += 4
        return struct.unpack_from("<I", self.d, self.p - 4)[0]

    def string(self):
        n = self.u8()
        self.p += n
        return self.d[self.p - n:self.p].decode("latin1")


def _read_fields(r, table):
    out = {}
    for (typ, name, _cat), key in zip(table.fields, table.keys):
        if typ == 0:
            continue
        flag = r.u8()
        if flag == 0:
            continue
        if flag != 1:
            raise ValueError(f"bad presence flag {flag} for {name!r} at {r.p - 1}")
        if typ == 4:
            out[key] = r.string()
        else:
            w = WIDTH[typ]
            out[key] = int.from_bytes(r.d[r.p:r.p + w], "little")
            r.p += w
    return out


def _sized_blob(r):
    """A u32-size-prefixed BC ED 34 12 blob at the read position, or None."""
    if r.d[r.p + 4:r.p + 8] not in (BLOB_MAGIC, BLOB_MAGIC[::-1]):  # RLL4 visuals are big-endian
        return None
    size = r.u32()
    r.p += size
    return r.d[r.p - size:r.p]


def load(data):
    r = _Reader(data)
    r.u8()
    tables = []
    for _ in range(r.u8()):
        tid, name, n = r.u8(), r.string(), r.u32()
        tables.append(Table(tid, name, [(r.u8(), r.string(), r.string()) for _ in range(n)]))
    header = data[:r.p]
    records_pos = r.p
    # Every table is preceded by a present byte, except in defaultdata_leagues
    # (one table, always written) - try the common form first.
    for table_flags in (True, False):
        r.p = records_pos
        try:
            records = _read_records(r, tables, table_flags)
            break
        except ValueError:
            if not table_flags:
                raise
    return Database(header, tables, records, data[r.p:], table_flags)


def _read_records(r, tables, table_flags):
    records = []
    for _ in range(r.u32()):
        tag = r.u32()
        if tag != RECORD_TAG:
            raise ValueError(f"record tag {tag} at {r.p - 4}, expected {RECORD_TAG}")
        visual = _sized_blob(r)
        vals = []
        for t in tables:
            flag = r.u8() if table_flags else 1
            vals.append(_read_fields(r, t) if flag else None)
        records.append({"visual": visual, "tables": vals, "blob": _sized_blob(r)})
    return records


def _write_fields(out, table, vals):
    for (typ, _name, _cat), key in zip(table.fields, table.keys):
        if typ == 0:
            continue
        if key not in vals or vals[key] is None:
            out.append(0)
            continue
        out.append(1)
        v = vals[key]
        if typ == 4:
            b = v.encode("latin1")
            if len(b) > 255:
                raise ValueError(f"{key!r} is longer than 255 bytes")
            out.append(len(b))
            out += b
        else:
            out += int(v).to_bytes(WIDTH[typ], "little")


def dump(db):
    out = bytearray(db.header)
    out += struct.pack("<I", len(db.records))
    for rec in db.records:
        out += struct.pack("<I", RECORD_TAG)
        if rec.get("visual") is not None:
            out += struct.pack("<I", len(rec["visual"])) + rec["visual"]
        for t, vals in zip(db.tables, rec["tables"]):
            if not db.table_flags:
                _write_fields(out, t, vals or {})
            elif vals is None:
                out.append(0)
            else:
                out.append(1)
                _write_fields(out, t, vals)
        if rec.get("blob") is not None:
            out += struct.pack("<I", len(rec["blob"])) + rec["blob"]
    out += db.trailer
    return bytes(out)


def field_names(db, table=0):
    t = db.tables[table]
    return [key for (typ, _name, _cat), key in zip(t.fields, t.keys) if typ]


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("schema")
    p.add_argument("file")
    p = sub.add_parser("show")
    p.add_argument("file")
    p.add_argument("id", type=int)
    args = ap.parse_args()
    data = open(args.file, "rb").read()
    db = load(data)
    if args.cmd == "schema":
        print(f"{len(db.records)} records, round trip {'OK' if dump(db) == data else 'MISMATCH'}")
        for t in db.tables:
            print(f"table {t.tid} {t.name}: " + ", ".join(f"{k}({typ})" for (typ, _n, _c), k in zip(t.fields, t.keys)))
    else:
        rec = db.by_id()[args.id]
        for part in ("visual", "blob"):
            if rec.get(part) is not None:
                print(f"{part}: {len(rec[part])} bytes")
        for t, vals in zip(db.tables, rec["tables"]):
            print(f"[{t.name}] {vals}")


if __name__ == "__main__":
    sys.exit(main())
