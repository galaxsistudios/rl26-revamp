#!/usr/bin/env python3
"""
rll4_source.py - read-only access to an installed copy of Rugby League Live 4
(same Big Ant engine as RL26, older archive format). Used to bring RLL4 kits
and face-scanned players into RL26 (mods/rll4-legacy-kits, mods/rll4-legacy-players)
from the user's own copy of the game, so no RLL4 content ships with the mods.

Install discovery: --rll4 / the RLL4_DIR environment variable, else every
Steam library listed in steamapps/libraryfolders.vdf (Steam's path from the
registry) is checked for steamapps/common/Rugby League Live 4.

Archive (worked out 2026-10-26, Steam build of Oct 2026):
  data-0.blobset.pc: 20-byte hash, "BOLB", u32 version (4), u32 count, then
  count x 32-byte entries [descOffset, descStored, descSize, dataOffset,
  dataStored, dataSize, id, volume] (u32 LE). An entry's bytes live in
  data-<volume>.blobset.pc. A part is stored raw (stored == size) or as
  frames [u32 frameLen incl. itself][1-byte LZMA props, u32 dict size, raw
  LZMA1] each decoding to 32 KB (trim - raw LZMA1 has no end marker).
  `id` is a 32-bit hash of the asset path, but of an unknown function (not
  FNV, CRC32, murmur, djb2, sdbm, x65599 or one-at-a-time of the path, its
  upper case or backslash forms; the exe's code is encrypted so it can't be
  read out). So assets are found by what they contain instead:
    - standalone textures: description = Mini_TXPK header (u32 width,
      height, type, path offset 20, console offset, then the NUL-terminated
      "convant2-temp-intermediate/<path>.dds"); data = a whole DDS file.
    - model texture packs: description starts "KPXT" and lists the pack's
      texture paths (characters/heads/textures/<name>_col ...); data = the
      pixels.
    - model components: magic 0x12345678; their strings include material
      names (a scanned head's material is "<lowercase name>_mat").
    - M3MP packs (Lua bundle, defaultdata): magic "M3MP", see decode_m3mp.

Usage:
    python tools/rll4_source.py where                 # print the install found
    python tools/rll4_source.py scan                  # (re)build the catalog cache
    python tools/rll4_source.py textures [substring]  # list cataloged textures
"""

import argparse
import io
import json
import lzma
import os
import re
import struct
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CACHE_DIR = os.path.join(REPO, "_build", "rll4-source")
STEAM_APP_ID = 556480
FOLDER = "Rugby League Live 4"
CHUNK = 32768


# --------------------------------------------------------------------------
# install discovery

def _steam_root():
    try:
        import winreg
        for hive, key in ((winreg.HKEY_CURRENT_USER, r"Software\Valve\Steam"),
                          (winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\WOW6432Node\Valve\Steam")):
            try:
                with winreg.OpenKey(hive, key) as k:
                    for name in ("SteamPath", "InstallPath"):
                        try:
                            return winreg.QueryValueEx(k, name)[0]
                        except OSError:
                            pass
            except OSError:
                pass
    except ImportError:
        pass
    return r"C:\Program Files (x86)\Steam"


def _steam_libraries():
    root = _steam_root()
    libs = [root]
    vdf = os.path.join(root, "steamapps", "libraryfolders.vdf")
    if os.path.exists(vdf):
        text = open(vdf, encoding="utf-8", errors="replace").read()
        libs += [p.replace("\\\\", "\\") for p in re.findall(r'"path"\s+"([^"]+)"', text)]
    return libs


def find_install(explicit=None):
    """Folder holding data-0.blobset.pc, or SystemExit with what was tried."""
    tried = []
    for cand in [explicit, os.environ.get("RLL4_DIR")] + [
            os.path.join(lib, "steamapps", "common", FOLDER) for lib in _steam_libraries()]:
        if not cand:
            continue
        tried.append(cand)
        if os.path.exists(os.path.join(cand, "data-0.blobset.pc")):
            return os.path.abspath(cand)
    raise SystemExit("Rugby League Live 4 isn't installed where expected. Tried:\n  " + "\n  ".join(tried)
                     + "\nPass --rll4 <folder> or set RLL4_DIR.")


# --------------------------------------------------------------------------
# archive

class Entry:
    __slots__ = ("index", "desc_offset", "desc_stored", "desc_size", "data_offset", "data_stored",
                 "data_size", "id", "volume")

    def __init__(self, index, fields):
        self.index = index
        (self.desc_offset, self.desc_stored, self.desc_size, self.data_offset, self.data_stored,
         self.data_size, self.id, self.volume) = fields


def _lzma_chunk(body, size):
    props, dict_size = body[0], struct.unpack_from("<I", body, 1)[0]
    lc, rest = props % 9, props // 9
    lp, pb = rest % 5, rest // 5
    if 0 < dict_size <= 1 << 26 and lc + lp <= 4 and pb <= 4:
        try:
            dec = lzma.LZMADecompressor(lzma.FORMAT_RAW, filters=[
                {"id": lzma.FILTER_LZMA1, "dict_size": dict_size, "lc": lc, "lp": lp, "pb": pb}])
            out = dec.decompress(body[5:], size)
            if len(out) >= size:
                return out[:size]
        except lzma.LZMAError:
            pass
    return body[:size]  # stored raw


class Blobset:
    def __init__(self, root):
        self.root = root
        path = os.path.join(root, "data-0.blobset.pc")
        with open(path, "rb") as f:
            head = f.read(32)
            if head[20:24] != b"BOLB":
                raise SystemExit(f"{path} isn't a BOLB archive")
            count = struct.unpack_from("<I", head, 28)[0]
            table = f.read(32 * count)
        self.entries = [Entry(i, struct.unpack_from("<8I", table, 32 * i)) for i in range(count)]
        self._files = {}
        self.stamp = f"{os.path.getsize(path)}-{int(os.path.getmtime(path))}"

    def _file(self, volume):
        if volume not in self._files:
            self._files[volume] = open(os.path.join(self.root, f"data-{volume}.blobset.pc"), "rb")
        return self._files[volume]

    def _read(self, volume, offset, stored, size, limit=None):
        f = self._file(volume)
        f.seek(offset)
        if stored == size:
            return f.read(size if limit is None else min(size, limit))
        raw = f.read(stored)
        out = bytearray()
        pos = 0
        want = size if limit is None else min(size, limit)
        while len(out) < want and pos < len(raw):
            frame = struct.unpack_from("<I", raw, pos)[0]
            out += _lzma_chunk(raw[pos + 4:pos + frame], min(CHUNK, size - len(out)))
            pos += frame
        if limit is None and len(out) != size:
            raise ValueError(f"decoded {len(out)} of {size} bytes")
        return bytes(out[:want])

    def desc(self, i, limit=None):
        e = self.entries[i]
        return self._read(e.volume, e.desc_offset, e.desc_stored, e.desc_size, limit) if e.desc_size else b""

    def data(self, i):
        e = self.entries[i]
        return self._read(e.volume, e.data_offset, e.data_stored, e.data_size) if e.data_size else b""


def decode_m3mp(buf):
    """{path: bytes} of an M3MP pack (magic, u32 files, u32 chunks, u32 chunk
    table offset; 16-byte file records [offset, size, name offset, 0]; chunk
    records [offset, stored, size] of LZMA/raw chunks forming one blob)."""
    if buf[:4] != b"M3MP":
        raise ValueError("not an M3MP pack")
    nfiles, nchunks, ctab = struct.unpack_from("<3I", buf, 4)
    blob = bytearray()
    for k in range(nchunks):
        off, stored, size = struct.unpack_from("<3I", buf, ctab + 12 * k)
        blob += _lzma_chunk(buf[off:off + stored], size) if stored != size else buf[off:off + size]
    out = {}
    for k in range(nfiles):
        off, size, name_off, _ = struct.unpack_from("<4I", buf, 16 + 16 * k)
        name = buf[name_off:buf.index(b"\0", name_off)].decode("latin1")
        out[name] = bytes(blob[off:off + size])
    return out


# --------------------------------------------------------------------------
# catalog: what each entry is, by content (cached per install)

MINI_PATH = re.compile(rb"convant2-temp-intermediate[/\\]([^\x00]+?)(?:\.pc)?\.dds\x00")


def scan(bs, verbose=True):
    """{"textures": {path: entry}, "packs": {entry: [paths]},
    "components": {entry: [material names]}, "m3mp": {entry: [file paths]}}."""
    cat = {"stamp": bs.stamp, "textures": {}, "packs": {}, "components": {}, "m3mp": {}}
    for n, e in enumerate(bs.entries):
        if verbose and n % 2000 == 0:
            print(f"  scanning {n}/{len(bs.entries)}", flush=True)
        if e.desc_size < 8:
            continue
        head = bs.desc(e.index, limit=CHUNK)
        if head[20:24] == b"conv":
            m = MINI_PATH.search(head)
            if m:
                cat["textures"][m.group(1).decode("latin1").replace("\\", "/")] = e.index
        elif head[:4] == b"KPXT" and e.data_size:
            names = re.findall(rb"([A-Za-z0-9_/\-.]{4,})\x00", bs.desc(e.index))
            cat["packs"][e.index] = [x.decode() for x in names]
        elif head[:4] == b"\x78\x56\x34\x12":
            names = re.findall(rb"[A-Za-z_][A-Za-z0-9_]{3,}", bs.desc(e.index))
            cat["components"][e.index] = sorted({x.decode() for x in names if x.endswith((b"_mat", b"aterial", b"Material_cap"))})
        elif head[:4] == b"M3MP":
            cat["m3mp"][e.index] = sorted(decode_m3mp(bs.desc(e.index)))
    return cat


def catalog(bs, rescan=False):
    os.makedirs(CACHE_DIR, exist_ok=True)
    path = os.path.join(CACHE_DIR, "catalog.json")
    if not rescan and os.path.exists(path):
        cat = json.load(open(path))
        if cat.get("stamp") == bs.stamp:
            for key in ("packs", "components", "m3mp"):
                cat[key] = {int(k): v for k, v in cat[key].items()}
            return cat
    print(f"cataloging {bs.root} (once per install)...")
    cat = scan(bs)
    with open(path, "w") as f:
        json.dump(cat, f)
    return cat


class RLL4:
    """The installed game: archive + catalog + helpers."""

    def __init__(self, root=None, rescan=False):
        self.root = find_install(root)
        self.bs = Blobset(self.root)
        self.cat = catalog(self.bs, rescan)

    def texture(self, path):
        """PIL image of a standalone texture, e.g.
        "characters/uniforms/textures/nrl_broncos_home_col" (as stored: no flip)."""
        from PIL import Image
        if path not in self.cat["textures"]:
            raise KeyError(f"RLL4 has no texture {path}")
        return Image.open(io.BytesIO(self.bs.data(self.cat["textures"][path])))

    def m3mp_file(self, name):
        for entry, names in self.cat["m3mp"].items():
            if name in names:
                return decode_m3mp(self.bs.desc(entry))[name]
        raise KeyError(f"RLL4 has no packed file {name}")

    def pack_textures(self, entry):
        """{path: PIL image} of a KPXT model texture pack. Layout: "KPXT",
        u32 count, count x [u32 header offset, u32 header size, u32 data
        offset, u32 data size], then per texture [u32 w, u32 h, u32 1,
        u32 fmt, u32 data size, path\\0]; the pixels (full mip chains) are
        in the data part."""
        d = self.bs.desc(entry)
        n = struct.unpack_from("<I", d, 4)[0]
        hdrs = [struct.unpack_from("<4I", d, 8 + 16 * k) for k in range(n)]
        pix = self.bs.data(entry)
        out = {}
        for hoff, _hsize, doff, dsize in hdrs:
            w, h, _one, fmt, size2 = struct.unpack_from("<5I", d, hoff)
            path = d[hoff + 20:d.index(b"\0", hoff + 20)].decode()
            out[path] = _dds_image(w, h, fmt, pix[doff:doff + dsize])
        return out


FOURCC = {0x14: b"DXT5", 0x12: b"DXT1", 0x13: b"DXT3"}


def _dds_image(w, h, fmt, data):
    """Wrap raw top-mip pixels in a DDS header and decode with PIL."""
    from PIL import Image
    if fmt not in FOURCC:
        raise ValueError(f"unknown RLL4 texture format 0x{fmt:x}")
    block = 8 if FOURCC[fmt] == b"DXT1" else 16
    top = max(1, w // 4) * max(1, h // 4) * block
    hdr = bytearray(128)
    struct.pack_into("<4s7I", hdr, 0, b"DDS ", 124, 0x81007, h, w, top, 0, 1)
    struct.pack_into("<2I4s", hdr, 76, 32, 4, FOURCC[fmt])
    struct.pack_into("<I", hdr, 108, 0x1000)
    pixels = data[:top]
    pixels += bytes(top - len(pixels))  # a few packs end a block short of the top mip
    return Image.open(io.BytesIO(bytes(hdr) + pixels))


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--rll4", help="RLL4 install folder (default: found via Steam)")
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("where")
    sub.add_parser("scan")
    p = sub.add_parser("textures")
    p.add_argument("match", nargs="?", default="")
    args = ap.parse_args()
    if args.cmd == "where":
        print(find_install(args.rll4))
        return
    g = RLL4(args.rll4, rescan=args.cmd == "scan")
    if args.cmd == "scan":
        print(f"{len(g.cat['textures'])} textures, {len(g.cat['packs'])} texture packs, "
              f"{len(g.cat['components'])} components, {len(g.cat['m3mp'])} M3MP packs")
    elif args.cmd == "textures":
        for path in sorted(p for p in g.cat["textures"] if args.match in p):
            print(path)


if __name__ == "__main__":
    sys.exit(main())
