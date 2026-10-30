#!/usr/bin/env python3
"""
kit_design.py - helpers for kits designed in code (resources/custom-kits/<kit>/design.py,
built by kit_studio.py):
the base design is painted with numpy masks in the kit's UV layout (see
resources/jersey-templates/README.md), then the sponsors are laid on top.

Sponsors usually come from two places:
  - the club's stock textures (stock()), which already hold most of the
    season's sponsors at the game's own placement: key() turns a light logo on
    a coloured ground into an alpha mask, solid() recolours it;
  - logos downloaded into the kit's logos/ folder (SVGs rasterised with
    headless Chrome, see rasterise_svg()).

Top layout (4096 x 2048 px): back panel x 40..1030, front panel 1100..2270
(neck centre x 1645, neck bottom y 444, armpits y ~829, hem 1843), collar
strip 1110..2160 x 0..205, right sleeve 2318..3150 (back | front halves),
left sleeve 3215..4049 (front | back), cuffs from y 727.
"""

import os
import subprocess
import sys

import numpy as np
from PIL import Image, ImageFilter
from scipy import ndimage

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import jersey_template as jt  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
STOCK_CACHE = os.path.join(ROOT, "_build", "kit-stock")
CHROME = r"C:\Program Files\Google\Chrome\Application\chrome.exe"

W, H = 4096, 2048
FRONT_CX, NECK_Y, ARMPIT_Y, HEM_Y, CUFF_Y = 1645, 444, 829, 1843, 727
RIGHT_SLEEVE_MID, LEFT_SLEEVE_MID = 2734, 3632


def stock(name):
    """A stock kit texture (upright RGB), cached in _build/kit-stock."""
    path = os.path.join(STOCK_CACHE, name + ".png")
    if not os.path.exists(path):
        os.makedirs(STOCK_CACHE, exist_ok=True)
        jt.read_texture(name).save(path)
    return Image.open(path).convert("RGB")


def grid():
    """y, x float arrays over the top texture."""
    return np.mgrid[0:H, 0:W].astype(np.float32)


def top_masks():
    """Boolean masks of the top's visible texels: all, back, front, sleeves."""
    mesh = jt.Mesh("top")
    m = np.asarray(mesh.mask(~mesh.inside)) > 0
    y, x = grid()
    return {"all": m, "back": m & (x < 1060), "front": m & (x > 1090) & (x < 2280) & (y > 215),
            "sleeves": m & (x > 2290)}


def key(im, box, lo=45, hi=185, channel=None):
    """Light logo on a dark/coloured ground -> alpha (L image) from the
    minimum channel (or one channel: 0/1/2)."""
    a = np.asarray(im.crop(box), np.float32)
    a = a[..., channel] if channel is not None else a.min(2)
    return Image.fromarray((np.clip((a - lo) / (hi - lo), 0, 1) * 255).astype(np.uint8))


def solid(alpha, colour):
    out = Image.new("RGBA", alpha.size, tuple(colour) + (0,))
    out.putalpha(alpha)
    return out


def place(canvas, im, centre=None, width=None, height=None, angle=0, at=None):
    if width or height:
        w, h = im.size
        s = (width / w) if width else (height / h)
        im = im.resize((max(1, round(w * s)), max(1, round(h * s))), Image.LANCZOS)
    if angle:
        im = im.rotate(angle, Image.BICUBIC, expand=True)
    if at is None:
        at = (round(centre[0] - im.width / 2), round(centre[1] - im.height / 2))
    canvas.alpha_composite(im, at)


def trim(im):
    return im.crop(im.getchannel("A").getbbox())


def outline(im, px, colour=(240, 240, 240)):
    """im with a solid outline of px around its alpha (sticker border)."""
    pad = px + 2
    big = Image.new("RGBA", (im.width + 2 * pad, im.height + 2 * pad))
    big.alpha_composite(im, (pad, pad))
    a = big.getchannel("A").point(lambda v: 255 if v > 40 else 0).filter(ImageFilter.MaxFilter(px * 2 + 1))
    out = solid(a.filter(ImageFilter.GaussianBlur(1)), colour)
    out.alpha_composite(big)
    return out


def filled(im, colour):
    """Fill the holes of a line-art logo's silhouette with colour, logo on top."""
    a = np.asarray(im.getchannel("A")) > 100
    sil = ndimage.binary_fill_holes(ndimage.binary_closing(a, iterations=3))
    out = solid(Image.fromarray((sil * 255).astype(np.uint8)), colour)
    out.alpha_composite(im)
    return out


def recolour(im, base, light, to_base, to_light, keep=None):
    """Two-colour remap along the base->light axis; off-axis pixels (logos in
    other colours) and `keep` pixels stay as they are."""
    a = np.asarray(im, np.float32)
    b, l = np.array(base, np.float32), np.array(light, np.float32)
    d = l - b
    t = np.clip(((a - b) @ d) / (d @ d), 0, 1)[..., None]
    resid = np.linalg.norm(a - (b + t * d), axis=2, keepdims=True)
    w = np.clip(1 - (resid - 25) / 40, 0, 1)
    out = np.array(to_base, np.float32) + t * (np.array(to_light, np.float32) - np.array(to_base, np.float32))
    res = a * (1 - w) + out * w
    if keep is not None:
        res = np.where(keep[..., None], a, res)
    return Image.fromarray(res.clip(0, 255).astype(np.uint8))


def rasterise_svg(svg, png, width):
    """SVG -> transparent PNG via headless Chrome (no SVG library here),
    trimmed to its content."""
    svg = os.path.abspath(svg)
    page = os.path.splitext(png)[0] + "_render.html"
    with open(page, "w") as fh:
        fh.write(f'<html><body style="margin:0"><img src="file:///{svg.replace(os.sep, "/")}" '
                 f'style="width:{width}px;display:block"></body></html>')
    subprocess.run([CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars",
                    "--default-background-color=00000000", f"--window-size={width},{width * 2}",
                    f"--screenshot={os.path.abspath(png)}", "file:///" + os.path.abspath(page).replace(os.sep, "/")],
                   check=True, capture_output=True)
    os.remove(page)
    trim(Image.open(png).convert("RGBA")).save(png)


def _hug(mask, pad):
    grown = ndimage.distance_transform_edt(~mask) < pad * 2
    return ~(ndimage.distance_transform_edt(grown) < pad)


NRL_LOGO = os.path.join(ROOT, "resources", "custom-kits", "logos", "nrl_telstra_premiership.png")
NRL_SHIELD_H = 284  # the shield's rows in NRL_LOGO; the wordmark sits below


def nrl_parts(shield_h, ground, colour=(240, 240, 240), pad=18, text_pad=7, logo=NRL_LOGO):
    """The NRL Telstra Premiership logo (shield + wordmark) in colour, and the
    flat patch of ground (the jersey's main colour) that hugs it, so the
    pattern underneath stops at the patch. shield_h = the shield's height in
    px. Returns (patch, logo, shield centre), both images the same size."""
    logo = Image.open(logo).getchannel("A")
    s = shield_h / NRL_SHIELD_H
    logo = logo.resize((round(logo.width * s), round(logo.height * s)), Image.LANCZOS)
    big = Image.new("L", (logo.width + 4 * pad, logo.height + 4 * pad))
    big.paste(logo, (2 * pad, 2 * pad))
    a = np.asarray(big) > 60
    # each part gets a smooth outline: grow well past its pad, then shrink back
    # (closes the gaps between the letters); the wordmark's border is thinner
    split = 2 * pad + round(shield_h)
    shield, text = a.copy(), a.copy()
    shield[split:] = False
    text[:split] = False
    patch = ndimage.binary_fill_holes(_hug(shield, pad) | _hug(text, text_pad))
    patch = solid(Image.fromarray((patch * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(1)), ground)
    return patch, solid(big, colour), (big.width / 2, 2 * pad + shield_h / 2)


def nrl_patch(shield_h, ground, colour=(240, 240, 240), pad=18, text_pad=7):
    """nrl_parts() flattened: (image, shield centre in the image)."""
    patch, logo, centre = nrl_parts(shield_h, ground, colour, pad, text_pad)
    patch.alpha_composite(logo)
    return patch, centre


def place_nrl_patch(canvas, shield_centre, shield_h, ground, colour=(240, 240, 240)):
    im, (cx, cy) = nrl_patch(shield_h, ground, colour)
    canvas.alpha_composite(im, (round(shield_centre[0] - cx), round(shield_centre[1] - cy)))
