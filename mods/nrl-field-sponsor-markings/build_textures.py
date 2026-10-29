#!/usr/bin/env python3
"""
build_textures.py - render resources/field-markings/ into the NRL sponsor
field-decal texture slots and write replacement .dds files for every sponsor
TXPK bundle (see SLOTS / BUNDLES below), ready for install.py.

The sponsor decals are models under fields/default/sponsor_field_<name>.model,
each paired with its own TXPK texture bundle in the very next blobset entry
(model N, TXPK N+1). Shipped, every NRL bundle carries byte-identical copies of
the same six textures, so Thursday/Friday/Saturday/... all looked the same.
This gives each bundle its own art.

Slot meanings (texture name -> what it is on the pitch):
    leaguestars01            512x512   day-of-week badge   <- field-center-top/
    nrltelstrapremiership01  1024^2    centre logo         (kept as shipped)
    indigenousround01        1024x256  centre logo         <- field-centers/
    multiculturalround01     1024x512  centre logo         <- field-centers/
    kiatasman01 / 02         512x512   mid-field squares   <- field-mid/
    wideleft/right_nrlfantasy 1024x256 in-goal banners     <- try-zones/

Shipped textures are stored vertically flipped (V-up UVs), so every image is
composed upright and flipped as the last step. Every replacement keeps the
original width/height/format/mip count, so each .dds is the exact byte size
of the member it replaces (install.py relies on that to patch in place).

Needs texconv.exe (Microsoft DirectXTex) for BC7 encoding, and resvg-py for
the SVG sources:
    pip install resvg-py
    python mods/nrl-field-sponsor-markings/build_textures.py --texconv PATH\\texconv.exe

Writes _build/nrl-field-sponsor-markings/<entry>/fields/textures/sponsors/*.dds
plus a preview contact sheet next to them.
"""

import argparse
import io
import os
import shutil
import subprocess
import sys
import tempfile

import numpy as np
import resvg_py
from PIL import Image

MOD_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(os.path.dirname(MOD_DIR))
sys.path.insert(0, os.path.join(REPO_ROOT, "tools"))
import classify_entries as ce  # noqa: E402
import extract_textures as et  # noqa: E402
import pack  # noqa: E402
import entries  # noqa: E402

RES = os.path.join(REPO_ROOT, "resources", "field-markings")
OUT = os.path.join(REPO_ROOT, "_build", "nrl-field-sponsor-markings")
SPONSOR_DIR = "fields/textures/sponsors/"
KFC_RED = (228, 0, 43, 255)


def load_art(rel):
    path = os.path.join(RES, rel)
    if path.lower().endswith(".svg"):
        png = bytes(resvg_py.svg_to_bytes(svg_path=path, width=2048))
        return Image.open(io.BytesIO(png)).convert("RGBA")
    return Image.open(path).convert("RGBA")


def crop_alpha(im, threshold=8):
    bbox = im.getchannel("A").point(lambda v: 255 if v > threshold else 0).getbbox()
    return im.crop(bbox) if bbox else im


def whiten(im):
    """Solid white, keeping the artwork's own alpha."""
    a = np.array(im)
    a[..., :3] = 255
    return Image.fromarray(a)


def white_mark_from_background(im, lo, hi):
    """For a white logo printed on a solid colour (Kia on black, Westpac on
    red): alpha = how white each pixel is, judged by its darkest channel,
    ramped from lo..hi. Result is a white mark on transparency."""
    a = np.array(im).astype(np.float32)
    m = a[..., :3].min(axis=2)
    alpha = np.clip((m - lo) / (hi - lo), 0, 1) * 255
    out = np.zeros(a.shape, np.uint8)
    out[..., :3] = 255
    out[..., 3] = alpha.astype(np.uint8)
    return crop_alpha(Image.fromarray(out))


def fit_into(canvas, art, box):
    """Paste art (aspect kept) centred inside box=(x0,y0,x1,y1) of canvas."""
    x0, y0, x1, y1 = box
    s = min((x1 - x0) / art.width, (y1 - y0) / art.height)
    w, h = max(1, round(art.width * s)), max(1, round(art.height * s))
    art = art.convert("RGBa").resize((w, h), Image.LANCZOS).convert("RGBA")
    canvas.alpha_composite(art, (x0 + (x1 - x0 - w) // 2, y0 + (y1 - y0 - h) // 2))
    return canvas


def bleed_white(im):
    """Fully transparent pixels get white RGB so mip filtering never pulls a
    dark fringe into white artwork."""
    a = np.array(im)
    a[a[..., 3] == 0, :3] = 255
    return Image.fromarray(a)


# ---- slot compositors: each returns the UPRIGHT image for one slot ----------

def centred(art, margin):
    def make(size, _orig):
        c = Image.new("RGBA", size, (255, 255, 255, 0))
        return fit_into(c, art, (margin, margin, size[0] - margin, size[1] - margin))
    return make


def stretched(art, margin):
    """Fill the whole slot, ignoring the art's aspect - for a slot whose quad
    on the pitch (see install.py's MODEL_PATCHES "resize") already has the
    art's shape."""
    def make(size, _orig):
        w, h = size[0] - 2 * margin, size[1] - 2 * margin
        c = Image.new("RGBA", size, (255, 255, 255, 0))
        c.alpha_composite(art.convert("RGBa").resize((w, h), Image.LANCZOS).convert("RGBA"), (margin, margin))
        return c
    return make


def banner(art, colour, pad_div=14):
    """Keep the shipped banner silhouette (incl. its folded corner) and
    replace the flat body with `colour` + the logo."""
    def make(size, orig_upright):
        a = np.array(orig_upright)
        body = (a[..., 3] > 200) & (a[..., 1] > 200)  # light banner body
        ys, xs = np.where(body)
        x0, x1, y0, y1 = xs.min(), xs.max() + 1, ys.min(), ys.max() + 1
        c = orig_upright.copy()
        c.paste(Image.new("RGBA", (x1 - x0, y1 - y0), colour), (x0, y0))
        pad = (y1 - y0) // pad_div
        return fit_into(c, art, (x0 + pad, y0 + pad, x1 - pad, y1 - pad))
    return make


def build_art():
    day = {n: crop_alpha(load_art(f"field-center-top/{n}.svg")) for n in
           ("thursday-night-footy", "friday-night-footy", "saturday-footy", "sunday-footy")}
    telstra = crop_alpha(load_art("field-mid/telstra.png"))
    kia = white_mark_from_background(load_art("field-mid/kia.jpg"), 60, 200)
    westpac = white_mark_from_background(load_art("field-mid/westpac.png"), 70, 220)
    kfc = load_art("try-zones/kfc-logo-fb.jpg")
    indigenous = crop_alpha(load_art("field-center-top/nrl-indigenous-round.svg"))
    multicultural = whiten(crop_alpha(load_art("field-centers/nrl-multicultural-round.svg")))

    nrl_common = {
        "kiatasman01": centred(telstra, 56),
        "wideleft_nrlfantasy": banner(kfc, KFC_RED),
        "wideright_nrlfantasy": banner(kfc, KFC_RED),
    }
    grand_final = whiten(crop_alpha(load_art("field-centers/nrl-grand-final.svg")))
    with_kia = dict(nrl_common, kiatasman02=centred(kia, 24))
    with_westpac = dict(nrl_common, kiatasman02=centred(westpac, 48))

    def day_set(name):
        return dict(with_kia, leaguestars01=centred(day[name], 8))

    # (label, [entries]) -> slot compositors. Each label is one model + its
    # _flipped twin; both bundles get identical textures.
    return [
        ("anzac", [entries.legacy(39883), entries.legacy(39885)], with_westpac),
        ("fridayNightFootball", [entries.legacy(39887), entries.legacy(39889)], day_set("friday-night-footy")),
        ("indigenous", [entries.legacy(39891), entries.legacy(39893)],
         dict(with_westpac, indigenousround01=centred(indigenous, 12))),
        # Monday's badge is hidden (install.py); it doubles as the Grand
        # Final's mid-field/in-goal layer, so both squares are Westpac.
        ("mondayFootball", [entries.legacy(39895), entries.legacy(39897)], dict(with_westpac, kiatasman01=centred(westpac, 48))),
        ("multicultural", [entries.legacy(39899), entries.legacy(39901)],
         dict(with_westpac, multiculturalround01=centred(multicultural, 12))),
        ("sundayFootball", [entries.legacy(39911), entries.legacy(39913)], day_set("sunday-footy")),
        ("superSaturday", [entries.legacy(39915), entries.legacy(39917)], day_set("saturday-footy")),
        ("thursdayNightFootball", [entries.legacy(39919), entries.legacy(39921)], day_set("thursday-night-footy")),
        ("womenInLeague", [entries.legacy(39923), entries.legacy(39925)], with_westpac),
        # The women's RLWC pair, repurposed for the Grand Final centre (see
        # install.py MODEL_PATCHES / stadiumgrass.lua); its banners are hidden.
        ("grandFinal", [entries.legacy(39903), entries.legacy(39905)], {
            "rlwc01": stretched(grand_final, 16),
        }),
    ]


# ---- DDS encoding -----------------------------------------------------------

def dds_header_len(dds):
    return 148 if dds[84:88] == b"DX10" else 128


def encode_like(orig_dds, upright, texconv, tmp):
    """BC7-encode `upright` (flipped to storage order) with the same mip
    count as orig_dds, and return orig_dds's header + the new payload."""
    h, w = int.from_bytes(orig_dds[12:16], "little"), int.from_bytes(orig_dds[16:20], "little")
    mips = int.from_bytes(orig_dds[28:32], "little")
    assert upright.size == (w, h), (upright.size, (w, h))
    src = os.path.join(tmp, "slot.png")
    bleed_white(upright).transpose(Image.FLIP_TOP_BOTTOM).save(src)
    subprocess.run([texconv, "-nologo", "-y", "-f", "BC7_UNORM", "-m", str(mips),
                    "--ignore-srgb", "-o", tmp, src], check=True, stdout=subprocess.DEVNULL)
    new = open(os.path.join(tmp, "slot.dds"), "rb").read()
    hl_o, hl_n = dds_header_len(orig_dds), dds_header_len(new)
    payload = new[hl_n:]
    if len(payload) != len(orig_dds) - hl_o:
        raise RuntimeError(f"encoded payload {len(payload)} != original {len(orig_dds) - hl_o}")
    return orig_dds[:hl_o] + payload


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--texconv", required=True)
    ap.add_argument("--blobset", default=pack.BLOBSET_PATH)
    args = ap.parse_args()

    ce.load_index(args.blobset)
    installed = [e for _l, entries, _s in build_art() for e in entries if os.path.exists(pack.backup_meta_path(e))]
    if installed:
        raise SystemExit(f"entries {installed} are installed - this reads the stock bundles, "
                         f"so run 'install.py restore' first")
    if os.path.isdir(OUT):
        shutil.rmtree(OUT)
    previews = []
    with tempfile.TemporaryDirectory() as tmp:
        for label, entries, slots in build_art():
            for entry in entries:
                raw, *_ = ce.read_blob_full(args.blobset, entry)
                if raw is None or ce.classify(raw[:65536])[0] != "txpk":
                    raise RuntimeError(f"entry {entry} ({label}) is not a TXPK bundle - index shifted?")
                main_u = pack.entry_sizes(ce._INDEX_DATA, ce._SIZE_TABLE_OFF, entry)[1]
                members = dict(et.parse_txpk(raw, main_u))
                for slot, make in slots.items():
                    path = f"{SPONSOR_DIR}sponsor_field_{slot}_col.dds"
                    if path not in members:
                        raise RuntimeError(f"entry {entry} ({label}) has no member {path}")
                    orig = members[path]
                    w, h = int.from_bytes(orig[16:20], "little"), int.from_bytes(orig[12:16], "little")
                    with open(os.path.join(tmp, "orig.dds"), "wb") as f:
                        f.write(orig)
                    orig_upright = Image.open(os.path.join(tmp, "orig.dds")).convert("RGBA") \
                        .transpose(Image.FLIP_TOP_BOTTOM)
                    upright = make((w, h), orig_upright)
                    dds = encode_like(orig, upright, args.texconv, tmp)
                    dst = os.path.join(OUT, str(entry), *path.split("/"))
                    os.makedirs(os.path.dirname(dst), exist_ok=True)
                    with open(dst, "wb") as f:
                        f.write(dds)
                    if entry == entries[0]:
                        previews.append((f"{label}: {slot}", dst))
                print(f"  {entry} {label}: {', '.join(slots)}")

    # Preview sheet: decode the encoded DDS back, upright, on grass green.
    tiles = []
    for name, dst in previews:
        im = Image.open(dst).convert("RGBA").transpose(Image.FLIP_TOP_BOTTOM)
        im.thumbnail((400, 200))
        bg = Image.new("RGBA", (410, 230), (46, 110, 46, 255))
        bg.alpha_composite(im, (5, 25))
        from PIL import ImageDraw
        ImageDraw.Draw(bg).text((5, 5), name, fill=(255, 255, 0, 255))
        tiles.append(bg)
    cols = 3
    sheet = Image.new("RGB", (410 * cols, 230 * ((len(tiles) + cols - 1) // cols)))
    for i, t in enumerate(tiles):
        sheet.paste(t, ((i % cols) * 410, (i // cols) * 230))
    sheet.save(os.path.join(OUT, "preview.png"))
    print(f"Wrote {OUT} (preview.png = decoded result)")


if __name__ == "__main__":
    main()
