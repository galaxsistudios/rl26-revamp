#!/usr/bin/env python3
"""
default_flags.py - generate the default crowd flag variants for every club
into resources/flags/<icon>/, at the template's shape (see
resources/flags/flag_template.psd and tools/flag_template.py: 1560 x 1020,
pole edge on the left).

Per game club icon (the club's colours from the installed defaultdata_clubs):
  default     primary background, secondary stripes, the club badge
  inverted    secondary background, primary stripes, the badge
  huge        solid primary, the badge as big as the flag allows
  wordmark    primary background, the club's wordmark (nrl.com text.svg),
              only for clubs that have one
  classic_N   the default design with each classic logo the club has
              (mods/new-club-icons/classic_logos.py)

Logos come from the HD sources mods/hd-nrl-club-logos uses (nrl.com SVGs,
Gallery of League PNGs, the user-supplied Eels/Sea Eagles overrides), falling
back to the game's own large_mirrored emblem. Each variant tries the colour
badges and one-colour recolours of the mono/silhouette art (or of the badge's
shape) in the other team colour, and keeps the one that stands out most from
its background; colour badges win unless they're clearly worse.

Writes resources/flags/<icon>/<variant>.png, resources/flags/flags.json (the
colours and the logo picked per variant) and resources/flags/defaults_sheet.png.

    python mods\\crowd-flags\\default_flags.py [icon ...]
"""

import argparse
import importlib.util
import io
import json
import os
import re
import sys
from collections import Counter

import numpy as np
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, "tools"))
sys.path.insert(0, HERE)
import build_flags as bf  # noqa: E402
import club_icons as ci  # noqa: E402
import flag_template as ft  # noqa: E402


def load_module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


hd = load_module("hd_logos", os.path.join(ROOT, "mods", "hd-nrl-club-logos", "generate.py"))
classic = load_module("classic_logos", os.path.join(ROOT, "mods", "new-club-icons", "classic_logos.py"))

OUT = os.path.join(ROOT, "resources", "flags")
W, H = ft.W, ft.H
SAFE = ft.SAFE
STRIPE = ft.STRIPE
LOGO_PX = 1600                  # SVG render size before fitting
EMBLEM_BOX = (0.80, ft.EMBLEM)  # default/inverted/classic: logo box (share of W, share of H)
HUGE_BOX = (0.90, 0.96)
WORD_BOX = (0.80, 0.42)
MONO_PENALTY = 0.7              # a one-colour recolour must beat the colour badge by this much
NEUTRAL_PENALTY = 0.62         # ... and a white/black one the team-colour recolour
WHITE = (255, 255, 255)
BLACK = (20, 20, 22)


# ---- logos --------------------------------------------------------------------

def trim(img):
    box = img.getchannel("A").point(lambda a: 255 if a > 8 else 0).getbbox()
    return img.crop(box) if box else img


def render(path):
    ci.MASTER_SIZE = LOGO_PX
    return trim(ci.load_logo(path).convert("RGBA"))


def recolour(img, colour):
    """One-colour version in colour, keeping the art's detail: white art keeps
    its shape (alpha x brightness); a colour badge is knocked out by its
    brightness (light parts stay, dark parts drop), not flattened into a blob."""
    a = np.asarray(img).astype(np.float32)
    lum = (0.299 * a[..., 0] + 0.587 * a[..., 1] + 0.114 * a[..., 2]) / 255
    solid = a[..., 3] > 128
    if lum[solid].mean() <= 0.9:
        lo, hi = np.percentile(lum[solid], [10, 90])
        lum = np.clip((lum - lo) / max(hi - lo, 1e-3), 0, 1)
    out = np.zeros_like(a)
    out[..., :3] = colour
    out[..., 3] = a[..., 3] * lum
    return Image.fromarray(out.astype(np.uint8), "RGBA")


def contrast(rgb, bg):
    """Per-pixel legibility against bg, 0..1: mostly brightness difference
    (what reads at a distance; red on navy differs in hue but barely in
    brightness), with a little credit for hue."""
    y = rgb @ np.array([0.299, 0.587, 0.114], np.float32) / 255
    y_bg = float(np.dot(bg, [0.299, 0.587, 0.114])) / 255
    hue = np.sqrt(((rgb - np.array(bg, np.float32)) ** 2).sum(-1)) / 255
    return np.clip(np.abs(y - y_bg) / 0.4 + 0.25 * np.minimum(hue, 1), 0, 1)


def visibility(img, bg, whole=False):
    """How well the logo reads against the background at a distance, 0..1:
    the contrast of its outer edge band (a badge with a white or black rim
    reads well even when its middle is the background colour); with whole,
    averaged with the contrast of all of it (for logos with text inside)."""
    from scipy import ndimage
    a = np.asarray(img.resize((200, max(1, round(200 * img.height / img.width))))).astype(np.float32)
    solid = a[..., 3] > 128
    if solid.sum() < 20:
        return 0.0
    rim = solid & ~ndimage.binary_erosion(solid, iterations=5)
    c = contrast(a[..., :3], bg)
    score = float(c[rim].mean())
    return (score + float(c[solid].mean())) / 2 if whole else score


class Logos:
    """The logo sources one club icon has."""

    def __init__(self, index, icon):
        self.icon = icon
        self.team = hd.TEAMS.get(icon)
        folder = hd.team_dir(self.team) if self.team else None
        self.colour = []        # (name, image) full-colour badges
        self.mono = []          # (name, image) white one-colour art
        self.word = None
        if self.team:
            seen = set()
            for kind in ("light", "colour"):
                path = hd.badge(self.team, kind)
                if path not in seen:
                    seen.add(path)
                    img = render(path)
                    # light badges that are all white are mono art, not colour badges
                    target = self.mono if self.is_white(img) else self.colour
                    target.append((os.path.basename(path), img))
            for name in ("badge-basic24-mono.svg", "silhouette.svg"):
                path = os.path.join(folder, name)
                if os.path.exists(path):
                    self.mono.append((name, render(path)))
            path = os.path.join(folder, "text.svg")
            if os.path.exists(path):
                self.word = render(path)
        if not self.colour:
            path = f"ui/club_logos/large_mirrored/{icon}.texture"
            if index.entry(path) is not None:
                self.colour.append(("game large_mirrored", trim(Image.open(io.BytesIO(index.texture(path))).convert("RGBA"))))

    @staticmethod
    def is_white(img):
        a = np.asarray(img).astype(np.float32)
        solid = a[..., 3] > 128
        return solid.any() and (a[..., :3][solid].min(axis=1) > 225).mean() > 0.97

    def best(self, bg, one_colour):
        """(name, image) of the logo that reads best on bg; one-colour options
        are drawn in one_colour (white art keeps its detail, badges become
        silhouettes)."""
        options = [(name, img, visibility(img, bg)) for name, img in self.colour]
        sources = self.mono or self.colour[:1]
        for colour, penalty in ((one_colour, MONO_PENALTY), (WHITE, NEUTRAL_PENALTY), (BLACK, NEUTRAL_PENALTY)):
            for name, img in sources:
                tinted = recolour(img, colour)
                options.append((f"{name} in {'#%02x%02x%02x' % colour}", tinted, visibility(tinted, bg) * penalty))
        if not options:
            return None, None
        name, img, _score = max(options, key=lambda o: o[2])
        return name, img


# ---- faces --------------------------------------------------------------------

def place(face, logo, box):
    # fit the box both ways (thumbnail() only shrinks, which left the ~300px
    # game emblems tiny)
    scale = min(box[0] * W / logo.width, box[1] * H / logo.height)
    logo = logo.resize((max(1, round(logo.width * scale)), max(1, round(logo.height * scale))), Image.LANCZOS)
    face.alpha_composite(logo, ((W - logo.width) // 2, (H - logo.height) // 2))


def base(background, stripes=None):
    face = Image.new("RGBA", (W, H), background + (255,))
    if stripes:
        d = ImageDraw.Draw(face)
        s = round(STRIPE * H)
        d.rectangle([0, 0, W, s], fill=stripes + (255,))
        d.rectangle([0, H - s, W, H], fill=stripes + (255,))
    return face


def faces_for(logos, primary, secondary, classics):
    out = {}

    def emit(variant, background, stripes, logo_bg, one_colour, box, chooser=None):
        name, logo = chooser() if chooser else logos.best(logo_bg, one_colour)
        if logo is None:
            return
        face = base(background, stripes)
        place(face, logo, box)
        out[variant] = (face, name)

    emit("default", primary, secondary, primary, secondary, EMBLEM_BOX)
    emit("inverted", secondary, primary, secondary, primary, EMBLEM_BOX)
    emit("huge", primary, None, primary, secondary, HUGE_BOX)
    if logos.word is not None:
        def word():
            options = [(c, recolour(logos.word, c)) for c in (secondary, WHITE)]
            colour, img = max(options, key=lambda o: visibility(o[1], primary))
            return f"text.svg in {'#%02x%02x%02x' % colour}", img
        emit("wordmark", primary, None, primary, None, WORD_BOX, word)
    for n, (_icon, filename) in enumerate(classics, 1):
        img = trim(Image.open(os.path.join(classic.SRC_DIR, filename)).convert("RGBA"))
        # full-colour art as drawn: on whichever team colour it reads best
        background, stripes = max(((primary, secondary), (secondary, primary)), key=lambda c: visibility(img, c[0], whole=True))
        face = base(background, stripes)
        place(face, img, EMBLEM_BOX)
        out[f"classic_{n}"] = (face, filename)
    return out


# ---- clubs --------------------------------------------------------------------

def club_colours():
    """icon -> (primary, secondary): the colours most of the icon's clubs use,
    preferring the current senior clubs over 2025 / GF / Decider copies."""
    by_icon = {}
    for _cid, name, icon, primary, secondary in bf.load_clubs():
        weight = 1 if re.search(r"2025|^GF |^Decider ", name) else 3
        by_icon.setdefault(icon, Counter())[(primary, secondary)] += weight
    return {icon: counts.most_common(1)[0][0] for icon, counts in by_icon.items()}


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("icons", nargs="*")
    args = ap.parse_args()

    index = bf.Index()
    colours = club_colours()
    classics_by_club = {}
    for icon, filename, _label, _fill in classic.CLASSICS:
        classics_by_club.setdefault(icon.rsplit("_classic_", 1)[0], []).append((icon, filename))
    manifest_path = os.path.join(OUT, "flags.json")
    manifest = json.load(open(manifest_path)) if args.icons and os.path.exists(manifest_path) else {}
    for icon in args.icons or sorted(colours):
        primary, secondary = colours[icon]
        logos = Logos(index, icon)
        faces = faces_for(logos, primary, secondary, classics_by_club.get(icon, []))
        os.makedirs(os.path.join(OUT, icon), exist_ok=True)
        for variant, (face, _logo) in faces.items():
            face.convert("RGB").save(os.path.join(OUT, icon, f"{variant}.png"))
        manifest[icon] = {
            "primary": "#%02x%02x%02x" % primary,
            "secondary": "#%02x%02x%02x" % secondary,
            "logos": {variant: logo for variant, (_face, logo) in faces.items()},
        }
        print(f"{icon}: {', '.join(faces)}")
    with open(manifest_path, "w") as f:
        json.dump(manifest, f, indent=1, sort_keys=True)
    contact_sheet(manifest)


def contact_sheet(manifest, tile=(195, 128)):
    order = ["default", "inverted", "huge", "wordmark", "classic_1", "classic_2"]
    icons = sorted(manifest)
    sheet = Image.new("RGB", (tile[0] * (len(order) + 1), tile[1] * len(icons)), (40, 40, 40))
    d = ImageDraw.Draw(sheet)
    for r, icon in enumerate(icons):
        d.text((6, r * tile[1] + tile[1] // 2), icon, fill=WHITE, anchor="lm")
        for c, variant in enumerate(order, 1):
            path = os.path.join(OUT, icon, f"{variant}.png")
            if os.path.exists(path):
                sheet.paste(Image.open(path).resize((tile[0] - 6, tile[1] - 6)), (c * tile[0] + 3, r * tile[1] + 3))
    sheet.save(os.path.join(OUT, "defaults_sheet.png"))


if __name__ == "__main__":
    main()
