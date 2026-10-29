#!/usr/bin/env python3
"""
build.py - compile mods/ overrides and rebuild entry 39959's M3MP bundle
entirely in Python, with no dependency on Blobset Tools' GUI.

Ground truth for the M3MP format and its ZSTD chunk compression came from
decompiling "Blobset Tools.dll" with ilspycmd (BlobsetIO/M3MP.cs's
Serialize()/Deserialize(), Blobset_Tools/M3MP_Creator.cs's CreateM3MP(), and
Blobset_Tools/ZSTD_IO.cs's CompressAndWrite()) and cross-checking against a
GUI-built bundle (which this file-count/structure matches exactly: 5,330
files, same chunking). Key facts not already in extract.py's own docstring:

- Inner M3MP chunks (<=32KB uncompressed each) are RAW zstd frames - just
  `ZstdCompressor().compress(chunk)` written back to back, no length prefix
  and no custom header of any kind (unlike RLL4's LZMA chunks, which have a
  5-byte propbyte+dictsize prefix this project's extract.py still expects -
  that's an RLL4-specific format detail that does NOT apply here, which is
  exactly why extract.py's decode_m3mp() can't read a real RL26 bundle).
  ZSTD_c_contentSizeFlag is set to 0 when compressing (no embedded size), so
  decompression here must cap output at the chunk table's own declared
  UnCompressedSize rather than relying on the frame header.
- "CompressedDataOffset" in the M3MP header (what extract.py calls
  chunk_table_off) is where the chunk TABLE starts, not where chunk DATA
  starts - each chunk table entry carries its own absolute data Offset, and
  M3MP_Creator always places that data immediately after the chunk table
  (header_total_size + running position in the compressed stream), but nothing
  in the reader requires that - we just replicate the real tool's own layout.
- Untouched files are never touched at the compressed-chunk level: the whole
  uncompressed data blob (every file's bytes, in M3MP_List.xml order) is
  concatenated fresh and re-chunked/re-compressed every build, exactly like
  M3MP_Creator.CreateM3MP does (it always rebuilds from scratch, never does
  incremental/byte-preserving patching the way RLL4's pack.py did for its
  older LZMA format). This means build() needs the full extracted/ content on
  disk (not just a diff), which this project already has.

Mod sources under mods/<mod-name>/<bundle-relative-path>.lua can be either
plain LuaJIT-bytecode-incompatible Lua source text (auto-compiled here via
the toolchain's luajit.exe) or already-compiled LuaJIT bytecode (detected by
the "\x1bLJ" magic and used as-is).

Usage:
    python build.py build   [--mods-dir DIR] [--extracted DIR] [--list M3MP_List.xml] [--out PATH]
    python build.py full    [--mods-dir DIR] [--blobset PATH] --confirm
"""

import argparse
import os
import struct
import subprocess
import sys
import xml.etree.ElementTree as ET

import zstandard

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pack  # noqa: E402  (reuse status/backup/install/restore - not re-derive it)
import entries  # noqa: E402
import data_mods  # noqa: E402  (per-record overrides for defaultdata_players/_clubs/_leagues)
import games  # noqa: E402  (mods that need another game, see mod.json)

MODS_DIR = os.path.join(REPO_ROOT, "mods")
EXTRACTED_DIR = os.path.join(REPO_ROOT, "extracted")
M3MP_LIST_XML = os.path.join(REPO_ROOT, "M3MP_List.xml")
BUILD_DIR = os.path.join(REPO_ROOT, "_build")
DEFAULT_BUNDLE_OUT = os.path.join(BUILD_DIR, "scripts.m3mp")

LUAJIT_EXE = games.toolchain("luajit", "bin", "luajit.exe")
LUAJIT_CWD = os.path.dirname(LUAJIT_EXE)  # bcsave needs cwd = its own dir (jit/ submodule lookup)

CHUNK_SIZE = 32768
M3MP_MAGIC = 1347236685  # b"M3MP" as a little-endian uint32
BYTECODE_MAGIC = b"\x1bLJ"


# --------------------------------------------------------------------------
# mod scanning + compiling
# --------------------------------------------------------------------------

def scan_mod_overrides(mods_dir):
    """Return {bundle_path: abs_file_path} for every file under mods/<mod>/,
    recursively. Bundle path uses forward slashes, matching M3MP_List.xml.
    Raises if two mods claim the same bundle path.

    Skips anything under a mods/<mod-name>/<bundle-path>/ directory that
    matches a known data_mods.DATA_BUNDLES entry - those are per-record JSON
    overrides (see data_mods.py's module docstring), handled separately in
    build_bundle via data_mods.scan_data_mod_overrides(), not whole-file
    replacement like everything else here."""
    overrides = {}
    owners = {}
    if not os.path.isdir(mods_dir):
        return overrides
    skip_dirs = data_mods.data_mod_dirs(mods_dir)
    for mod_name in sorted(os.listdir(mods_dir)):
        mod_path = os.path.join(mods_dir, mod_name)
        if not os.path.isdir(mod_path):
            continue
        # mods built from another game (mod.json "requires", tools/games.py)
        # only go in when the installer enabled that game and it's installed
        ok, missing = games.mod_enabled(mod_path)
        if not ok:
            print(f"  skipped mod {mod_name}: needs {', '.join(missing)} (tools/games.py)")
            continue
        for dirpath, dirnames, filenames in os.walk(mod_path):
            if os.path.normcase(os.path.abspath(dirpath)) in skip_dirs:
                dirnames[:] = []
                continue
            if "__pycache__" in dirnames:
                dirnames.remove("__pycache__")
            for fn in filenames:
                # README.md documents a mod; *.py is a program-style mod's
                # installer (e.g. mods/unlock-all-kits/install.py). Any file
                # at the mod root is a generator's config or data (e.g.
                # mods/r25-imports/imports.json, mods/crowd-team-kits/*.npz):
                # bundle paths always have directories, so none is a bundle file.
                if fn.lower() == "readme.md" or fn.lower().endswith(".py"):
                    continue
                if dirpath == mod_path:
                    continue
                abs_path = os.path.join(dirpath, fn)
                rel = os.path.relpath(abs_path, mod_path).replace(os.sep, "/")
                if rel in overrides and owners[rel] != mod_name:
                    raise ValueError(
                        f"bundle path {rel!r} is claimed by both "
                        f"mods/{owners[rel]}/ and mods/{mod_name}/"
                    )
                overrides[rel] = abs_path
                owners[rel] = mod_name
    return overrides


def compile_if_source(abs_path, bundle_path, compiled_cache_dir, verbose=True):
    """Return the path to LuaJIT bytecode for this override: the file itself
    if it's already bytecode, or a freshly-compiled copy in compiled_cache_dir
    if it's plain Lua source. Non-.lua overrides (Noesis .xaml, fonts, ...)
    are whole-file replacements used as-is."""
    if not bundle_path.lower().endswith(".lua"):
        return abs_path
    with open(abs_path, "rb") as f:
        head = f.read(3)
    if head == BYTECODE_MAGIC:
        return abs_path

    out_path = os.path.join(compiled_cache_dir, *bundle_path.split("/"))
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    if os.path.exists(out_path):
        os.remove(out_path)
    result = subprocess.run(
        [LUAJIT_EXE, "-b", os.path.abspath(abs_path), os.path.abspath(out_path)],
        cwd=LUAJIT_CWD, capture_output=True, text=True,
    )
    if result.returncode != 0 or not os.path.exists(out_path):
        raise RuntimeError(
            f"failed to compile {abs_path} -> {out_path}\n"
            f"stdout: {result.stdout}\nstderr: {result.stderr}"
        )
    if verbose:
        print(f"  compiled: {bundle_path}")
    return out_path


# --------------------------------------------------------------------------
# M3MP_List.xml (defines file order + count - must match the live entry's
# FilesCount exactly, same list this project's extracted/ was pulled from)
# --------------------------------------------------------------------------

def read_m3mp_list(list_xml_path):
    tree = ET.parse(list_xml_path)
    root = tree.getroot()
    if "Hash" in root.attrib:
        # Index shifts when an update adds files; the hash (= path) doesn't
        index = entries.index_of(root.attrib["Hash"])
    else:
        index = int(root.attrib["Index"])
    is_compressed = root.attrib.get("IsCompressed", "false")
    paths = [e.attrib["FilePath"] for e in root.find("Entries")]
    return index, is_compressed, paths


# --------------------------------------------------------------------------
# M3MP bundle builder
# --------------------------------------------------------------------------

_other_bundle_paths = None


def _skip_foreign(bundle_path, kind, entry_index, verbose):
    """True if bundle_path belongs to some other bundle's manifest under
    manifests/ (e.g. a defaultdata mod while building 39959) or is a
    textures/ mod (installed by texture_mods.py, not via a bundle) - those
    are skipped here rather than treated as errors, so every mod can live
    in mods/ at once."""
    global _other_bundle_paths
    if _other_bundle_paths is None:
        _other_bundle_paths = {}
        manifests_dir = os.path.join(REPO_ROOT, "manifests")
        for fn in sorted(os.listdir(manifests_dir)) if os.path.isdir(manifests_dir) else []:
            if fn.lower().endswith(".xml"):
                idx, _c, paths = read_m3mp_list(os.path.join(manifests_dir, fn))
                for p in paths:
                    _other_bundle_paths.setdefault(p, idx)
    if bundle_path.startswith("textures/"):
        owner = "texture_mods.py"
    elif _other_bundle_paths.get(bundle_path, entry_index) != entry_index:
        owner = f"entry {_other_bundle_paths[bundle_path]}"
    else:
        return False
    if verbose:
        print(f"  skipped {kind} (belongs to {owner}): {bundle_path}")
    return True


def zstd_compress_chunk(data):
    cctx = zstandard.ZstdCompressor(level=4)
    return cctx.compress(data)


def build_bundle(mods_dir, extracted_dir, list_xml_path, out_path, verbose=True):
    entry_index, is_compressed, bundle_paths = read_m3mp_list(list_xml_path)
    file_count = len(bundle_paths)

    compiled_cache_dir = os.path.join(BUILD_DIR, "compiled_mods")
    bundle_path_set = set(bundle_paths)
    overrides_raw = scan_mod_overrides(mods_dir)
    overrides_raw = {
        bp: p for bp, p in overrides_raw.items()
        if bp in bundle_path_set or not _skip_foreign(bp, "mod file", entry_index, verbose)
    }
    unmatched = [bp for bp in overrides_raw if bp not in bundle_path_set]
    if unmatched:
        raise ValueError(f"mod file(s) with no matching bundle entry: {unmatched}")

    overrides = {
        bp: compile_if_source(abs_path, bp, compiled_cache_dir, verbose)
        for bp, abs_path in overrides_raw.items()
    }

    data_overrides = data_mods.scan_data_mod_overrides(mods_dir)
    data_overrides = {
        bp: v for bp, v in data_overrides.items()
        if bp in bundle_path_set or not _skip_foreign(bp, "data mod", entry_index, verbose)
    }
    unmatched_data = [bp for bp in data_overrides if bp not in bundle_path_set]
    if unmatched_data:
        raise ValueError(f"data mod override(s) for bundle path(s) not in this entry: {unmatched_data}")

    # ---- file table + concatenated uncompressed data blob ----
    file_sizes = []
    file_contents = []  # read lazily below, same order as bundle_paths
    for bp in bundle_paths:
        if bp in data_overrides:
            pristine_path = os.path.join(extracted_dir, *bp.split("/"))
            with open(pristine_path, "rb") as f:
                pristine = f.read()
            if verbose:
                print(f"  data mod: {bp} ({len(data_overrides[bp])} record override file(s))")
            content = data_mods.apply_overrides(bp, pristine, data_overrides[bp], verbose=verbose)
        else:
            src = overrides.get(bp, os.path.join(extracted_dir, *bp.split("/")))
            with open(src, "rb") as f:
                content = f.read()
        file_contents.append(content)
        file_sizes.append(len(content))

    # ---- header sizing (matches M3MP_Creator.CreateM3MP's own running total) ----
    header_fixed = 16  # magic + filesCount + chunksCount + chunkTableOffset
    file_table_bytes_len = file_count * 16
    name_table_bytes = b"".join(bp.encode("latin1") + b"\x00" for bp in bundle_paths)
    chunk_table_off = header_fixed + file_table_bytes_len + len(name_table_bytes)

    total_uncompressed = sum(file_sizes)
    n_chunks = (total_uncompressed + CHUNK_SIZE - 1) // CHUNK_SIZE if total_uncompressed else 0
    chunk_table_bytes_len = n_chunks * 12
    header_total_size = chunk_table_off + chunk_table_bytes_len

    # ---- file table (offsets are cumulative positions in the uncompressed blob) ----
    file_table_buf = bytearray()
    cum = 0
    for size in file_sizes:
        name_offset = 0  # filled in below once name_table's real base is known; recomputed inline
        file_table_buf += struct.pack("<4I", cum, size, 0, 0)
        cum += size

    # FilePathOffset is an absolute position within the final file (header_fixed +
    # file_table region), matching Serialize()'s output.Position at write time.
    name_offsets = []
    pos = header_fixed + file_table_bytes_len
    for bp in bundle_paths:
        name_offsets.append(pos)
        pos += len(bp.encode("latin1")) + 1

    file_table_buf = bytearray()
    cum = 0
    for size, name_off in zip(file_sizes, name_offsets):
        file_table_buf += struct.pack("<4I", cum, size, name_off, 0)
        cum += size

    # ---- compress the concatenated blob in CHUNK_SIZE pieces ----
    full_blob = b"".join(file_contents)
    chunk_table_buf = bytearray()
    compressed_buf = bytearray()
    running_off = header_total_size
    pos = 0
    while pos < len(full_blob):
        piece = full_blob[pos:pos + CHUNK_SIZE]
        pos += len(piece)
        compressed = zstd_compress_chunk(piece)
        chunk_table_buf += struct.pack("<3I", running_off, len(compressed), len(piece))
        compressed_buf += compressed
        running_off += len(compressed)

    header_buf = bytearray()
    header_buf += struct.pack("<4I", M3MP_MAGIC, file_count, n_chunks, chunk_table_off)
    header_buf += file_table_buf
    header_buf += name_table_bytes
    header_buf += chunk_table_buf
    assert len(header_buf) == header_total_size, (len(header_buf), header_total_size)

    os.makedirs(os.path.dirname(out_path) or ".", exist_ok=True)
    with open(out_path, "wb") as f:
        f.write(header_buf)
        f.write(compressed_buf)

    if verbose:
        print(f"Rebuilt M3MP bundle -> {out_path} ({len(header_buf) + len(compressed_buf)} bytes)")
        print(f"  files: {file_count} total, {len(overrides)} from mods/, "
              f"{file_count - len(overrides)} from extracted/")
        print(f"  chunks: {n_chunks}")
        for bp in overrides:
            print(f"    modded: {bp}")

    return {
        "out_path": out_path,
        "entry_index": entry_index,
        "size": len(header_buf) + len(compressed_buf),
        "overrides": overrides,
    }


def self_verify_build(result):
    """Decode the freshly-built bundle with our own zstd-aware reader and
    confirm the file list + every modded file's content matches what we fed
    in. (Full byte-for-byte check of untouched files against extracted/ is
    skipped here since build() always re-reads them from the same source -
    nothing to diverge; the real risk is the chunking/compression round-trip,
    which this does check.)"""
    with open(result["out_path"], "rb") as f:
        buf = f.read()
    magic, file_count, chunk_count, chunk_table_off = struct.unpack_from("<4I", buf, 0)
    assert magic == M3MP_MAGIC

    names = []
    sizes = []
    cum_offs = []
    for i in range(file_count):
        off = 16 + i * 16
        cum_off, size, name_off, _reserved = struct.unpack_from("<4I", buf, off)
        end = buf.find(b"\x00", name_off)
        names.append(buf[name_off:end].decode("latin1"))
        sizes.append(size)
        cum_offs.append(cum_off)

    chunks = []
    for i in range(chunk_count):
        off = chunk_table_off + i * 12
        chunks.append(struct.unpack_from("<3I", buf, off))

    dctx = zstandard.ZstdDecompressor()
    data_blob = bytearray()
    for c_off, c_size, u_size in chunks:
        piece = dctx.decompress(buf[c_off:c_off + c_size], max_output_size=u_size)
        if len(piece) != u_size:
            raise AssertionError(f"chunk decompressed to {len(piece)} bytes, expected {u_size}")
        data_blob += piece

    bad = []
    for bp, abs_path in result["overrides"].items():
        idx = names.index(bp)
        content = bytes(data_blob[cum_offs[idx]:cum_offs[idx] + sizes[idx]])
        with open(abs_path, "rb") as f:
            expected = f.read()
        if content != expected:
            bad.append(bp)
    return {"file_count": file_count, "chunk_count": chunk_count, "mismatches": bad}


# --------------------------------------------------------------------------
# CLI
# --------------------------------------------------------------------------

def cmd_build(args):
    result = build_bundle(args.mods_dir, args.extracted, args.list, args.out)
    verify = self_verify_build(result)
    print()
    print(f"Self-verify: {verify['file_count']} files, {verify['chunk_count']} chunks decoded OK.")
    if verify["mismatches"]:
        print(f"MISMATCHED modded files: {verify['mismatches']}")
        sys.exit(1)
    print("BUILD OK - self-verification passed.")


def cmd_full(args):
    result = build_bundle(args.mods_dir, args.extracted, args.list, args.out)
    verify = self_verify_build(result)
    if verify["mismatches"]:
        print(f"MISMATCHED modded files: {verify['mismatches']}")
        sys.exit(1)
    print("Build OK. Installing...")
    install_result = pack.do_install(args.blobset, result["entry_index"], result["out_path"], args.confirm)
    print(f"Installed: entry {install_result['entry_index']}'s blob "
          f"({install_result['blob_path']}) replaced, new size {install_result['new_size']} bytes.")
    print(f"Backup recorded at {install_result['backup_meta']} - run 'python pack.py restore' to undo.")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)

    p_build = sub.add_parser("build", help="compile mods/ overrides and rebuild entry 39959's M3MP bundle")
    p_build.add_argument("--mods-dir", default=MODS_DIR)
    p_build.add_argument("--extracted", default=EXTRACTED_DIR)
    p_build.add_argument("--list", default=M3MP_LIST_XML)
    p_build.add_argument("--out", default=DEFAULT_BUNDLE_OUT)
    p_build.set_defaults(func=cmd_build)

    p_full = sub.add_parser("full", help="build, then install (back up + replace the live blob + update the index)")
    p_full.add_argument("--mods-dir", default=MODS_DIR)
    p_full.add_argument("--extracted", default=EXTRACTED_DIR)
    p_full.add_argument("--list", default=M3MP_LIST_XML)
    p_full.add_argument("--out", default=DEFAULT_BUNDLE_OUT)
    p_full.add_argument("--blobset", default=pack.BLOBSET_PATH)
    p_full.add_argument("--confirm", action="store_true", help="required to actually write")
    p_full.set_defaults(func=cmd_full)

    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
