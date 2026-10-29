#!/usr/bin/env python3
"""
art.py - art loaders, slot compositors and the BC7 encoder shared by
fieldmarkings.py and las-vegas-stadium's install.py.

Shipped sponsor textures are stored vertically flipped (V-up UVs), so every
image is composed upright and flipped as the last step (encode_like). Every
replacement keeps the original width/height/format/mip count, so each .dds is
the exact byte size of the member it replaces.

Needs texconv.exe (Microsoft DirectXTex) for BC7 and resvg-py for SVG art.
"""

import io
import os
import subprocess

import numpy as np
import resvg_py
from PIL import Image

MOD_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(os.path.dirname(MOD_DIR))
RES = os.path.join(REPO_ROOT, "resources", "field-markings")
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


def invert_cutout(im):
    """Swap a cut-out logo (e.g. JD: a black disc with the letters cut out):
    the solid shape becomes white and the holes it encloses (transparent
    areas not reachable from the image edge) become solid black."""
    from scipy import ndimage
    solid = np.array(im.getchannel("A")) > 127
    labels, _n = ndimage.label(~solid)
    outside = np.unique(np.concatenate([labels[0], labels[-1], labels[:, 0], labels[:, -1]]))
    holes = ~solid & ~np.isin(labels, outside)
    out = np.zeros(solid.shape + (4,), np.uint8)
    out[solid] = (255, 255, 255, 255)
    out[holes] = (0, 0, 0, 255)
    return Image.fromarray(out)


def with_caption(im, text, font_path, colour=(255, 255, 255), scale=0.42, gap=0.18):
    """The art with `text` set to its right, the text's cap height about
    `scale` x the art's height, vertically centred, `gap` x height apart."""
    from PIL import ImageDraw, ImageFont
    h = im.height
    font = ImageFont.truetype(font_path, max(8, round(h * scale * 1.35)))
    box = font.getbbox(text)
    tw, th = box[2] - box[0], box[3] - box[1]
    g = round(h * gap)
    out = Image.new("RGBA", (im.width + g + tw, max(h, th)), (255, 255, 255, 0))
    out.alpha_composite(im, (0, (out.height - h) // 2))
    ImageDraw.Draw(out).text((im.width + g - box[0], (out.height - th) // 2 - box[1]), text,
                             font=font, fill=tuple(colour) + (255,))
    return out


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
    on the pitch (see fieldmarkings.py) already has the
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
