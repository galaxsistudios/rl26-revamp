#!/usr/bin/env python3
"""
kit_studio.py - custom kits designed as code + a layered PSD, installed through
mods/rll4-legacy-kits. The workflow and house rules are in
resources/custom-kits/RULES.md; the /design-jersey skill drives this tool.

A kit is a folder resources/custom-kits/<kit>/:
  kit.json     config: install row (club, guid, kit name, templates...), colour
               palette, canvas sizes, preview model and the sponsor list
  design.py    the painted design: top(kit) / shorts(kit) / socks(kit) return
               [(layer name, image), ...] bottom to top - base colours,
               patterns, trims. No sponsors: they come from kit.json.
  logos/       the real logo artwork the sponsors use (never generated)
  kit.psd      Top / Shorts / Socks artboards, each with Design, Sponsors and
               Guides groups, one layer per design layer / sponsor / patch
  .studio.json what the last build wrote (per-layer hashes), to spot PSD edits
  top.png shorts.png socks.png preview.png   the exported textures + 3D preview

build order: sponsors are resolved first (kit.json + rules), so design.py can
see where they sit (kit.sponsor_mask(part)); then the design layers; then the
PSD is written or merged and the textures exported.

PSD edits (3-way merge, per layer, against the hashes in .studio.json):
  - a layer the code didn't change keeps whatever is in the PSD (edited or not)
  - a layer the code changed (design.py / kit.json / rules / logo edits, i.e.
    a change asked of Claude) is replaced in the PSD - if it had been edited
    there too, that edit is lost and reported; the PSD is backed up first
  - layers added in Photoshop are kept and exported
  - if the PSD has any edits, the textures are composited from the PSD (it is
    the source of truth); otherwise straight from the code's layers
  - --reset throws the PSD edits away (after a backup)

Usage (repo root):
    python tools/kit_studio.py new <kit> --club 134 --kit-name "HOME 2027" [--like <kit>]
    python tools/kit_studio.py build <kit> [--reset] [--no-preview]
    python tools/kit_studio.py status <kit>
    python tools/kit_studio.py install <kit> [<kit> ...]     (game closed)
"""

import argparse
import datetime
import hashlib
import importlib.util
import json
import os
import shutil
import sys

import numpy as np
from PIL import Image, ImageDraw

TOOLS = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, TOOLS)
import kit_design as kd  # noqa: E402

REPO = os.path.dirname(TOOLS)
CUSTOM = os.path.join(REPO, "resources", "custom-kits")
RULES = os.path.join(CUSTOM, "rules.json")
TEMPLATE = os.path.join(TOOLS, "kit_studio_template")
WORK = os.path.join(REPO, "_build", "kit-studio")

PARTS = ("top", "shorts", "socks")
TITLES = {"top": "Top", "shorts": "Shorts", "socks": "Socks"}
DEFAULT_CANVAS = {"top": (4096, 2048), "shorts": (2048, 2048), "socks": (1024, 1024)}
DEFAULT_MODELS = {"top": "top_round05_short_Male", "shorts": "shorts01_Male", "socks": "socks01_long_Male"}
DESIGN, SPONSORS, GUIDES = "Design", "Sponsors", "Guides"
GROUPS = (DESIGN, SPONSORS, GUIDES)  # bottom to top
GAP = 128  # between artboards
STUDIO_VERSION = 1


def load_rules():
    with open(RULES, encoding="utf-8") as f:
        return json.load(f)


# --------------------------------------------------------------------------
# layers


class Layer:
    """One PSD layer: an RGBA image the size of its part's canvas."""

    def __init__(self, part, group, name, image, visible=True):
        self.part, self.group, self.name, self.visible = part, group, name, visible
        self.image = image.convert("RGBA")

    @property
    def id(self):
        return f"{self.part}/{self.group}/{self.name}"

    def cropped(self):
        """(left, top, RGBA crop) of the visible pixels, or None when empty."""
        return crop_alpha(self.image)

    def sig(self):
        return signature(self.cropped(), self.visible, 255, "normal")


def crop_alpha(im):
    a = np.asarray(im)
    alpha = a[..., 3]
    ys, xs = np.nonzero(alpha)
    if not len(ys):
        return None
    l, t, r, b = xs.min(), ys.min(), xs.max() + 1, ys.max() + 1
    c = a[t:b, l:r].copy()
    c[c[..., 3] == 0, :3] = 0
    return int(l), int(t), Image.fromarray(c, "RGBA")


def signature(cropped, visible, opacity, blend):
    h = hashlib.sha1(f"{bool(visible)}|{int(opacity)}|{blend}|".encode())
    if cropped is not None:
        l, t, im = cropped
        h.update(f"{l},{t},{im.width},{im.height}|".encode())
        h.update(np.asarray(im).tobytes())
    return h.hexdigest()


def as_rgba(image, size):
    if isinstance(image, np.ndarray):
        a = image.clip(0, 255).astype(np.uint8)
        image = Image.fromarray(a, "RGBA" if a.ndim == 3 and a.shape[2] == 4 else "RGB")
    image = image.convert("RGBA")
    if image.size != tuple(size):
        raise SystemExit(f"layer is {image.size}, the canvas is {tuple(size)}")
    return image


def composite(layers, size):
    out = Image.new("RGBA", size, (0, 0, 0, 255))
    for layer in layers:
        if layer.visible and layer.group != GUIDES:
            out.alpha_composite(layer.image)
    return out.convert("RGB")


# --------------------------------------------------------------------------
# kit


class Kit:
    def __init__(self, name):
        self.name = name
        self.dir = os.path.join(CUSTOM, name)
        with open(os.path.join(self.dir, "kit.json"), encoding="utf-8") as f:
            self.cfg = json.load(f)
        self.rules = load_rules()
        self.palette = {k: tuple(v) for k, v in self.cfg.get("colours", {}).items()}
        self._design = None
        self._sponsors = None

    # -- config
    def colour(self, c):
        """A palette name ('main', 'white'...), [r, g, b] or None."""
        if c is None or isinstance(c, (list, tuple)):
            return tuple(c) if c is not None else None
        if c in self.palette:
            return self.palette[c]
        if c in self.rules["colours"]:
            return tuple(self.rules["colours"][c])
        raise SystemExit(f"{self.name}: unknown colour {c!r} (add it to kit.json colours)")

    def size(self, part):
        return tuple(self.cfg.get("canvas", {}).get(part, DEFAULT_CANVAS[part]))

    def model(self, part):
        return self.cfg.get("models", {}).get(part, DEFAULT_MODELS[part])

    def file(self, rel):
        """A path in the kit folder; '@/x' = resources/custom-kits/x (shared)."""
        if rel.startswith("@/"):
            return os.path.join(CUSTOM, rel[2:])
        return os.path.join(self.dir, rel)

    def stock(self, name):
        return kd.stock(name)

    def canvas(self, part, colour=None):
        return Image.new("RGBA", self.size(part), (colour or (0, 0, 0)) + (255 if colour else 0,))

    def grid(self, part):
        w, h = self.size(part)
        return np.mgrid[0:h, 0:w].astype(np.float32)

    @property
    def design(self):
        if self._design is None:
            path = os.path.join(self.dir, "design.py")
            spec = importlib.util.spec_from_file_location(f"kitdesign_{self.name}", path)
            mod = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(mod)
            self._design = mod
        return self._design

    # -- sponsors (resolved before any design layer)
    def sponsors(self, part=None):
        if self._sponsors is None:
            self._sponsors = resolve_sponsors(self)
        return [s for s in self._sponsors if part is None or s.part == part]

    def sponsor_mask(self, part, grow=0):
        """Where this part's sponsors (and their patches) cover the kit."""
        m = np.zeros(self.size(part)[::-1], bool)
        for s in self.sponsors(part):
            for im in (s.image, s.patch):
                if im is not None:
                    m |= np.asarray(im.getchannel("A")) > 0
        if grow:
            from scipy import ndimage
            m = ndimage.binary_dilation(m, iterations=grow)
        return m

    # -- layers
    def layers(self, part, guides=True):
        size = self.size(part)
        fn = getattr(self.design, part, None)
        if fn is None:
            raise SystemExit(f"{self.name}: design.py has no {part}(kit)")
        out = []
        for name, image in fn(self):
            out.append(Layer(part, DESIGN, name, as_rgba(image, size)))
        for s in self.sponsors(part):
            if s.patch is not None:
                out.append(Layer(part, SPONSORS, f"{s.name} patch", s.patch))
            out.append(Layer(part, SPONSORS, s.name, s.image))
        if guides:
            out += guide_layers(self, part)
        seen = set()
        for layer in out:
            if layer.id in seen:
                raise SystemExit(f"{self.name}: two layers named {layer.id}")
            seen.add(layer.id)
        return out


# --------------------------------------------------------------------------
# sponsors


class Sponsor:
    def __init__(self, part, name, image, patch=None):
        self.part, self.name, self.image, self.patch = part, name, image, patch


def load_source(kit, spec, colour):
    """A sponsor's artwork -> RGBA (trimmed), recoloured when colour is set."""
    src = spec["source"]
    if "file" in src:
        im = Image.open(kit.file(src["file"])).convert("RGBA")
        if "crop" in src:
            im = im.crop(tuple(src["crop"]))
        im = kd.trim(im)
        return kd.solid(im.getchannel("A"), colour) if colour else im
    if "stock" in src:
        img = kit.stock(src["stock"])
        box = tuple(src["box"])
        if src.get("raw"):  # copied as is (e.g. a stock product tag)
            return img.crop(box).convert("RGBA")
        alpha = kd.key(img, box, lo=src.get("lo", 45), hi=src.get("hi", 185), channel=src.get("channel"))
        return kd.solid(alpha, colour or kit.colour(kit.rules["sponsors"]["default_colour"]))
    if "python" in src:
        im = getattr(kit.design, src["python"])(kit, *src.get("args", []))
        return kd.solid(im.getchannel("A"), colour) if colour else im.convert("RGBA")
    raise SystemExit(f"{kit.name}: sponsor {spec['name']!r} has no file/stock/python source")


def scaled(im, width=None, height=None):
    if not (width or height):
        return im
    s = (width / im.width) if width else (height / im.height)
    return im.resize((max(1, round(im.width * s)), max(1, round(im.height * s))), Image.LANCZOS)


def stamp(canvas, im, centre=None, pos=None):
    if pos is None:
        pos = (round(centre[0] - im.width / 2), round(centre[1] - im.height / 2))
    canvas.alpha_composite(im, tuple(int(v) for v in pos))


def hug_patch(logo, pad, colour):
    """A flat patch of one colour hugging a logo's alpha (no effects)."""
    from scipy import ndimage
    a = np.zeros((logo.height + 4 * pad, logo.width + 4 * pad), bool)
    a[2 * pad:2 * pad + logo.height, 2 * pad:2 * pad + logo.width] = np.asarray(logo.getchannel("A")) > 60
    m = ndimage.binary_fill_holes(kd._hug(a, pad))
    return kd.solid(Image.fromarray((m * 255).astype(np.uint8)), colour)


def nrl_images(kit, spec):
    """The NRL Telstra Premiership logo + its flat patch, per the rules."""
    rule = kit.rules["nrl"]
    shield_h = spec.get("shield_height", rule["shield_height"])
    patch, logo, centre = kd.nrl_parts(shield_h, kit.colour(spec.get("patch_colour", rule["patch_colour"])),
                                       kit.colour(spec.get("colour", rule["colour"])),
                                       pad=rule["patch_pad_shield"], text_pad=rule["patch_pad_text"],
                                       logo=kit.file(rule["logo"]))
    return patch, logo, centre, shield_h


def resolve_sponsors(kit):
    rules = kit.rules
    out = []
    nrl_at = {}  # part -> (shield centre, shield height), for crest alignment
    specs = kit.cfg.get("sponsors", [])
    # the NRL logo first: the crest rule lines up on it
    order = sorted(range(len(specs)), key=lambda i: specs[i].get("rule") != "nrl")
    resolved = {}
    for i in order:
        spec = specs[i]
        part = spec.get("part", "top")
        size = kit.size(part)
        layer = Image.new("RGBA", size)
        patch_layer = None
        rule = spec.get("rule")
        if rule == "nrl":
            patch, logo, (cx, cy), shield_h = nrl_images(kit, spec)
            x, y = spec["at"]
            if abs(x - kd.FRONT_CX) > rules["nrl"]["max_from_front_centre"]:
                print(f"  !! rule: the NRL logo is {abs(x - kd.FRONT_CX)} px from the front centre "
                      f"(max {rules['nrl']['max_from_front_centre']}): it will look like it's on the edge")
            pos = (round(x - cx), round(y - cy))
            patch_layer = Image.new("RGBA", size)
            patch_layer.alpha_composite(patch, pos)
            layer.alpha_composite(logo, pos)
            nrl_at[part] = ((x, y), shield_h)
        else:
            colour = kit.colour(spec.get("colour", rules["sponsors"]["default_colour"]
                                         if "stock" in spec["source"] else None))
            art = load_source(kit, spec, colour)
            places = spec.get("place") or [{}]
            if rule == "crest":
                (nx, ny), shield_h = nrl_at.get(part, (None, None))
                if nx is None:
                    raise SystemExit(f"{kit.name}: the crest rule needs an NRL logo on {part}")
                crest = rules["crest"]
                places = [dict(p) for p in places]
                for p in places:
                    p.setdefault("height", round(shield_h * crest["height_vs_nrl_shield"]))
                    p.setdefault("at", [2 * kd.FRONT_CX - nx, ny])
                    if crest.get("align_shield_centre", True):
                        p["at"] = [p["at"][0], ny]
            card = spec.get("card")
            hug = spec.get("patch")
            if card or hug:
                patch_layer = Image.new("RGBA", size)
            for p in places:
                im = scaled(art, p.get("width"), p.get("height"))
                if spec.get("outline"):  # a sticker border, e.g. a crest's white edge
                    o = spec["outline"]
                    im = kd.outline(im, o["px"], kit.colour(o.get("colour", "white")))
                if p.get("angle"):
                    im = im.rotate(p["angle"], Image.BICUBIC, expand=True)
                if "pos" in p:
                    centre, pos = None, p["pos"]
                elif "at" in p:
                    centre, pos = p["at"], None
                elif "stock" in spec["source"]:  # where it sits on the stock texture
                    centre, pos = None, spec["source"]["box"][:2]
                else:
                    raise SystemExit(f"{kit.name}: sponsor {spec['name']!r} needs place 'at' or 'pos'")
                if card:
                    cw, ch = card["size"]
                    c = Image.new("RGBA", (cw, ch))
                    ImageDraw.Draw(c).rounded_rectangle((0, 0, cw - 1, ch - 1), card.get("radius", 0),
                                                        fill=kit.colour(card.get("colour", "white")))
                    stamp(patch_layer, c, centre=centre or (pos[0] + im.width / 2, pos[1] + im.height / 2))
                if hug:
                    pad = hug.get("pad", rules["sponsors"]["patch_pad"])
                    pim = hug_patch(im, pad, kit.colour(hug.get("colour", "main")))
                    c = centre or (pos[0] + im.width / 2, pos[1] + im.height / 2)
                    stamp(patch_layer, pim, centre=c)
                off = p.get("offset", [0, 0])
                if centre is not None:
                    stamp(layer, im, centre=(centre[0] + off[0], centre[1] + off[1]))
                else:
                    stamp(layer, im, pos=(pos[0] + off[0], pos[1] + off[1]))
        resolved[i] = Sponsor(part, spec["name"], layer, patch_layer)
    out = [resolved[i] for i in range(len(specs))]
    return out


# --------------------------------------------------------------------------
# guides


def guide_layers(kit, part):
    """UV outlines of the part's model (cached), never exported."""
    model = kit.model(part)
    size = kit.size(part)
    path = os.path.join(WORK, "guides", f"{model}_{size[0]}x{size[1]}.png")
    if not os.path.exists(path):
        import jersey_template as jt
        old = jt.PARTS[part]
        jt.PARTS[part] = (old[0], model, size) + old[3:]
        try:
            mesh = jt.Mesh(part)
            im = mesh.boundary_lines(max(2, size[1] // 512), (0, 255, 255, 255))
        finally:
            jt.PARTS[part] = old
        os.makedirs(os.path.dirname(path), exist_ok=True)
        im.save(path)
    return [Layer(part, GUIDES, "UV outlines (never exported)", Image.open(path))]


# --------------------------------------------------------------------------
# PSD


def layout(kit):
    """Artboard rectangles (left, top, right, bottom) and the canvas size."""
    tw, th = kit.size("top")
    sw, sh = kit.size("shorts")
    kw, kh = kit.size("socks")
    rects = {"top": (0, 0, tw, th),
             "shorts": (0, th + GAP, sw, th + GAP + sh),
             "socks": (sw + GAP, th + GAP, sw + GAP + kw, th + GAP + kh)}
    return rects, (max(tw, sw + GAP + kw), th + GAP + max(sh, kh))


def artboard_block(rect):
    from psd_tools.psd.descriptor import Descriptor, DescriptorBlock, Double, Integer, List, String
    l, t, r, b = rect
    box = Descriptor(classID=b"classFloatRect")
    for k, v in ((b"Top ", t), (b"Left", l), (b"Btom", b), (b"Rght", r)):
        box[k] = Double(v)
    clr = Descriptor(classID=b"RGBC")
    for k in (b"Rd  ", b"Grn ", b"Bl  "):
        clr[k] = Double(255.0)
    d = DescriptorBlock(classID=b"artboard")
    d[b"artboardRect"] = box
    d[b"guideIndeces"] = List([])
    d[b"artboardPresetName"] = String("")
    d[b"Clr "] = clr
    d[b"artboardBackgroundType"] = Integer(1)
    return d


def new_pixel_layer(parent, layer, origin):
    from psd_tools.api.layers import PixelLayer
    c = layer.cropped()
    if c is None:
        l, t, im = 0, 0, Image.new("RGBA", (1, 1))
    else:
        l, t, im = c
    pl = PixelLayer.frompil(im, parent, name=layer.name, top=origin[1] + t, left=origin[0] + l)
    pl.visible = layer.visible
    return pl


def write_psd(kit, layers_by_part, path):
    from psd_tools import PSDImage
    from psd_tools.api.layers import Group
    from psd_tools.constants import Compression, Tag
    rects, size = layout(kit)
    psd = PSDImage.new("RGBA", size)
    for part in PARTS:
        rect = rects[part]
        board = Group.new(psd, name=TITLES[part])
        board.tagged_blocks.set_data(Tag.ARTBOARD_DATA1, artboard_block(rect))
        for gname in GROUPS:
            g = Group.new(board, name=gname)
            for layer in layers_by_part[part]:
                if layer.group == gname:
                    new_pixel_layer(g, layer, rect[:2])
    psd._record.image_data.compression = Compression.RLE
    psd.save(path)


def open_psd(path):
    from psd_tools import PSDImage
    return PSDImage.open(path)


def psd_layers(psd):
    """{layer id: psd layer} for the generated structure (artboard/group/layer),
    plus [psd layers] that aren't in it (added in Photoshop)."""
    found, extra = {}, []
    parts = {v: k for k, v in TITLES.items()}
    for board in psd:
        part = parts.get(board.name)
        if part is None:
            extra.append(board)
            continue
        for g in board:
            if not g.is_group() or g.name not in GROUPS:
                extra.append(g)
                continue
            for layer in g:
                lid = f"{part}/{g.name}/{layer.name}"
                if lid in found or layer.is_group():
                    extra.append(layer)
                else:
                    found[lid] = layer
    return found, extra


def psd_sig(layer, origin):
    if layer.kind != "pixel":
        return f"{layer.kind}:{layer.name}"
    im = layer.topil()
    cropped = None
    if im is not None and layer.width and layer.height:
        im = im.convert("RGBA")
        c = crop_alpha(im)
        if c is not None:
            l, t, ci = c
            cropped = (layer.left - origin[0] + l, layer.top - origin[1] + t, ci)
    blend = getattr(layer.blend_mode, "name", str(layer.blend_mode)).lower()
    sig = signature(cropped, layer.visible, layer.opacity, blend)
    if layer.has_mask() or layer.has_effects() or layer.clipping:
        sig += "+fx"
    return sig


def export_from_psd(kit, psd):
    rects, _ = layout(kit)
    parts = {v: k for k, v in TITLES.items()}
    out = {}
    guides = set()
    for board in psd:
        for g in board.descendants() if board.is_group() else []:
            if g.is_group() and g.name == GUIDES:
                guides.add(id(g))
                guides.update(id(x) for x in g.descendants())

    def keep(layer):
        return id(layer) not in guides and layer.is_visible()

    for board in psd:
        part = parts.get(board.name)
        if part is None:
            continue
        im = board.composite(layer_filter=keep, color=0.0, alpha=1.0)
        l, t, r, b = rects[part]
        if im.size != (r - l, b - t):
            full = Image.new("RGBA", (r - l, b - t), (0, 0, 0, 255))
            full.alpha_composite(im.convert("RGBA"), (board.left - l, board.top - t))
            im = full
        out[part] = im.convert("RGB")
    missing = [p for p in PARTS if p not in out]
    if missing:
        raise SystemExit(f"{kit.name}: the PSD has no {', '.join(TITLES[p] for p in missing)} artboard")
    return out


# --------------------------------------------------------------------------
# manifest


def manifest_path(kit):
    return os.path.join(kit.dir, ".studio.json")


def load_manifest(kit):
    try:
        with open(manifest_path(kit), encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        return None


def save_manifest(kit, data):
    with open(manifest_path(kit), "w", encoding="utf-8", newline="\n") as f:
        json.dump(data, f, indent=1, sort_keys=True)
        f.write("\n")


def file_sha1(path):
    h = hashlib.sha1()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def backup(kit, path):
    stamp_ = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    dst = os.path.join(WORK, kit.name, "backups", f"kit-{stamp_}.psd")
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    shutil.copy2(path, dst)
    return dst


def psd_edits(kit, man, psd):
    """Compare the PSD against the hashes the last build wrote."""
    rects, _ = layout(kit)
    found, extra = psd_layers(psd)
    edited, deleted = [], []
    for lid, sig in man["layers"].items():
        if lid not in found:
            deleted.append(lid)
        elif psd_sig(found[lid], rects[lid.split("/")[0]][:2]) != sig:
            edited.append(lid)
    added = [f"{x.name}" for x in extra] + [lid for lid in found if lid not in man["layers"]]
    return edited, deleted, added, found


# --------------------------------------------------------------------------
# commands


def build(name, reset=False, preview=True):
    kit = Kit(name)
    psd_path = os.path.join(kit.dir, "kit.psd")
    rects, _ = layout(kit)
    print(f"{name}: sponsors")
    kit.sponsors()
    layers = {}
    for part in PARTS:
        print(f"{name}: {part} layers")
        layers[part] = kit.layers(part)
    new_sigs = {layer.id: layer.sig() for part in PARTS for layer in layers[part]}
    man = load_manifest(kit)
    have_psd = os.path.exists(psd_path)

    edited = []
    if have_psd and man and not reset:
        if file_sha1(psd_path) == man.get("psd_sha1") and not man.get("psd_edited"):
            psd = None
        else:
            psd = open_psd(psd_path)
            edited, deleted, added, found = psd_edits(kit, man, psd)
            edited += deleted
            if added:
                print("  added in the PSD (kept):", ", ".join(added))
        changed = [lid for lid, sig in new_sigs.items() if man["layers"].get(lid) != sig]
        removed = [lid for lid in man["layers"] if lid not in new_sigs]
        if psd is None or not (edited or added):
            # nothing to keep from the PSD: rewrite it if the code changed
            if changed or removed or psd is not None and not os.path.exists(psd_path):
                print(f"  code changed {len(changed) + len(removed)} layer(s): rewriting kit.psd")
                write_psd(kit, layers, psd_path)
            source = "code"
            psd_edited = False
        else:
            print("  PSD edits:", ", ".join(edited + added) or "-")
            if changed or removed:
                lost = sorted(set(edited) & (set(changed) | set(removed)))
                b = backup(kit, psd_path)
                merge(kit, psd, layers, found, changed, removed, set(edited), rects)
                psd.save(psd_path)
                print(f"  merged {len(changed) + len(removed)} code change(s) into kit.psd (backup: {b})")
                if lost:
                    print("  !! these PSD edits were replaced by the code change:", ", ".join(lost))
                psd = open_psd(psd_path)
            source = "psd"
            psd_edited = True
    else:
        if have_psd:
            b = backup(kit, psd_path)
            print(f"  {'--reset' if reset else 'no .studio.json'}: kit.psd rewritten from code (backup: {b})")
        write_psd(kit, layers, psd_path)
        source = "code"
        psd_edited = False

    if source == "code":
        textures = {part: composite(layers[part], kit.size(part)) for part in PARTS}
    else:
        print("  exporting from kit.psd (it has edits: it is the source of truth)")
        textures = export_from_psd(kit, psd)
    for part in PARTS:
        textures[part].save(os.path.join(kit.dir, f"{part}.png"))
    save_manifest(kit, {"version": STUDIO_VERSION, "layers": new_sigs, "psd_sha1": file_sha1(psd_path),
                        "psd_edited": psd_edited, "source": source})
    print(f"  wrote top/shorts/socks.png from {source}")
    if preview:
        write_preview(kit, textures)


def merge(kit, psd, layers, found, changed, removed, edited, rects):
    """Put the code's changed layers into the user's PSD, in place."""
    from psd_tools.api.layers import Group
    from psd_tools.constants import Tag
    by_id = {layer.id: layer for part in PARTS for layer in layers[part]}
    boards = {b.name: b for b in psd}
    for lid in removed:
        if lid in found and lid not in edited:
            found[lid].parent.remove(found[lid])
    for part in PARTS:
        board = boards.get(TITLES[part])
        if board is None:
            board = Group.new(psd, name=TITLES[part])
            board.tagged_blocks.set_data(Tag.ARTBOARD_DATA1, artboard_block(rects[part]))
            boards[TITLES[part]] = board
        groups = {g.name: g for g in board if g.is_group()}
        for gname in GROUPS:
            if gname not in groups:
                groups[gname] = Group.new(board, name=gname)
        order = [lid for lid in (layer.id for layer in layers[part])]
        for lid in order:
            if lid not in changed:
                continue
            layer = by_id[lid]
            g = groups[layer.group]
            old = found.get(lid)
            new = new_pixel_layer(g, layer, rects[part][:2])
            g.remove(new)
            if old is not None and old.parent is g:
                idx = g.index(old)
                g.remove(old)
            else:
                # below the next layer (in code order) that is in the group
                idx = len(g)
                later = order[order.index(lid) + 1:]
                names = [x.name for x in g]
                for nid in later:
                    n = by_id[nid]
                    if n.group == layer.group and n.name in names:
                        idx = names.index(n.name)
                        break
            g.insert(idx, new)


def write_preview(kit, textures):
    import jersey_template as jt
    saved = dict(jt.PARTS)
    try:
        for part in PARTS:
            old = jt.PARTS[part]
            jt.PARTS[part] = (old[0], kit.model(part)) + old[2:]
        tex = {p: textures[p].resize(jt.PARTS[p][2], Image.LANCZOS) for p in PARTS}
        jt.render(tex).save(os.path.join(kit.dir, "preview.png"))
    finally:
        jt.PARTS.clear()
        jt.PARTS.update(saved)
    print("  wrote preview.png")


def status(name):
    kit = Kit(name)
    man = load_manifest(kit)
    psd_path = os.path.join(kit.dir, "kit.psd")
    if not man or not os.path.exists(psd_path):
        print(f"{name}: not built yet")
        return
    if file_sha1(psd_path) == man["psd_sha1"] and not man.get("psd_edited"):
        print(f"{name}: kit.psd untouched since the last build")
        return
    psd = open_psd(psd_path)
    rects, _ = layout(kit)
    edited, deleted, added, found = psd_edits(kit, man, psd)
    print(f"{name}: kit.psd differs from the code's layers (exports come from the PSD)")
    for lid in edited:
        layer = found[lid]
        o = rects[lid.split("/")[0]]
        print(f"  edited  {lid}: now at x {layer.left - o[0]}..{layer.right - o[0]}, "
              f"y {layer.top - o[1]}..{layer.bottom - o[1]}, visible={layer.visible}, opacity={layer.opacity}")
    for lid in deleted:
        print(f"  deleted {lid}")
    for lid in added:
        print(f"  added   {lid}")


def new(name, club, kit_name, like=None, guid=None):
    dst = os.path.join(CUSTOM, name)
    if os.path.exists(os.path.join(dst, "kit.json")):
        raise SystemExit(f"{dst} already has a kit.json")
    os.makedirs(os.path.join(dst, "logos"), exist_ok=True)
    src = os.path.join(CUSTOM, like) if like else TEMPLATE
    with open(os.path.join(src, "kit.json"), encoding="utf-8") as f:
        cfg = json.load(f)
    cfg["title"] = kit_name.title() if not like else cfg.get("title", name)
    cfg["install"] = {"club": club, "name": kit_name, "texture": name,
                      **{k: v for k, v in cfg.get("install", {}).items() if k not in ("club", "name", "texture", "guid")}}
    if guid:
        cfg["install"]["guid"] = guid
    with open(os.path.join(dst, "kit.json"), "w", encoding="utf-8", newline="\n") as f:
        json.dump(cfg, f, indent=1)
        f.write("\n")
    shutil.copy2(os.path.join(src, "design.py"), os.path.join(dst, "design.py"))
    print(f"created {dst} (kit.json + design.py from {'kit ' + like if like else 'the template'})")


def install(names):
    import fanhub_kit_import as fk
    with open(fk.MANIFEST, encoding="utf-8") as f:
        manifest = json.load(f)
    rows = manifest["kits"]
    used = {k["guid"] for k in rows} | fk.mod_item_guids()
    for name in names:
        kit = Kit(name)
        for part in PARTS:
            if not os.path.exists(os.path.join(kit.dir, f"{part}.png")):
                raise SystemExit(f"{name}: build it first (no {part}.png)")
        inst = dict(kit.cfg["install"])
        row = next((k for k in rows if k.get("custom") == name), None)
        if row is None:
            guid = inst.pop("guid", None)
            if guid is None:
                guid = max([fk.FIRST_CUSTOM_GUID - 1] + [k["guid"] for k in rows if k["guid"] >= fk.FIRST_CUSTOM_GUID]) + 1
                while guid in used:
                    guid += 1
            elif guid in used:
                raise SystemExit(f"{name}: guid {guid} is already used")
            row = {"guid": guid, "custom": name}
            rows.append(row)
            used.add(guid)
            kit.cfg["install"]["guid"] = guid
            with open(os.path.join(kit.dir, "kit.json"), "w", encoding="utf-8", newline="\n") as f:
                json.dump(kit.cfg, f, indent=1)
                f.write("\n")
        else:
            inst.pop("guid", None)
        for k in ("templates", "numberFrom", "library"):
            row.pop(k, None)
        row.update(inst)
        print(f"kits.json row: {json.dumps(row)}")
    with open(fk.MANIFEST, "w", encoding="utf-8", newline="\n") as f:
        json.dump(manifest, f, indent=1)
        f.write("\n")
    fk.install()


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("new", help="start a kit folder from the template (or --like another kit)")
    p.add_argument("kit")
    p.add_argument("--club", type=int, required=True)
    p.add_argument("--kit-name", required=True, help="name in game, at most 24 characters")
    p.add_argument("--like")
    p.add_argument("--guid", type=int)
    p = sub.add_parser("build", help="render the layers, write/merge kit.psd, export the textures + preview")
    p.add_argument("kit", nargs="+")
    p.add_argument("--reset", action="store_true", help="discard edits made in kit.psd (it is backed up)")
    p.add_argument("--no-preview", action="store_true")
    p = sub.add_parser("status", help="list the layers edited in kit.psd since the last build")
    p.add_argument("kit", nargs="+")
    p = sub.add_parser("install", help="add/update the kits.json rows and install (game closed)")
    p.add_argument("kit", nargs="+")
    args = ap.parse_args()
    if args.cmd == "new":
        new(args.kit, args.club, args.kit_name, args.like, args.guid)
    elif args.cmd == "build":
        for k in args.kit:
            build(k, args.reset, not args.no_preview)
    elif args.cmd == "status":
        for k in args.kit:
            status(k)
    elif args.cmd == "install":
        install(args.kit)


if __name__ == "__main__":
    main()
