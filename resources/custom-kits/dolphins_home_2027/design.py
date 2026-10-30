"""
design.py - Dolphins 2027 home kit (Oxen): the painted layers. Sponsors, the
NRL logo and the crest are in kit.json; build with
    python tools/kit_studio.py build dolphins_home_2027

Base design: red body with a darker tonal "echo" pattern (echo(): interlocking
teardrops of upward-bowing bands, matched to a close-up of the shirt), strongest
at the hem, faint over the chest and faintest through the middle. Gold collar
with a red lip and a gold back-neck band (PHINS UP); side panels between white
piping lines under each arm with a gold diagonal wedge towards the hem; orange
raglan stitching; darker ribbed cuffs; the sleeves/shoulders a deeper red.

Logo sources (kit.json): logos/budget_direct.png (resources/Goal Posts/
new-sponsors/budget-direct-logo-leafless.svg); ../sponsors/Oxen_Stacker_Logo_
Horizontal_White.png (Oxen, restacked by oxen_stacked()); WAHL, the dolphin,
Anglo American, PHINS UP and the sleeve Budget Direct patches are keyed out of
the stock Dolphins 2026 textures.
"""

import os

import numpy as np
from PIL import Image, ImageDraw, ImageFont
from scipy import ndimage

import kit_design as kd

HERE = os.path.dirname(os.path.abspath(__file__))
HOME = "m_top_dolphins_nrl_home_26_col_1"
ECHO_SCALE = 0.86            # echo motif size on the shirt vs the reference close-up
SIDE_W, PIPE_W = 95, 10      # side panel width from the seam, white piping width
# gold side panel: a straight diagonal top edge, high at the front piping and
# low at the back one (40% / 63% of armpit -> hem on the side photo)
GOLD_TOP_BACK, GOLD_TOP_FRONT = 1468, 1235


def echo(y, x, scale=1.0):
    """The "echo" motif -> soft 0..1 mask. Teardrops in columns, alternate
    columns shifted half a drop so they interlock. Each drop widens from a
    point (a triangle) to its widest, then narrows to a point again, and is
    filled with bands that all bow upwards (same curvature, so the narrow
    top bands read as flat and the tips break off as small solid triangles).
    Sizes are in px of the reference close-up, times scale."""
    col_w, period, band = 122 * scale, 295 * scale, 27 * scale
    tri, tail, half = 115 * scale, 140 * scale, 61 * scale
    radius = 95 * scale
    col = np.floor(x / col_w)
    dx = x - (col + 0.5) * col_w
    s = (y - (col % 2) * period / 2) % period          # 0 at the drop's top point
    u = np.clip((s - tri) / tail, 0, 1)
    w = np.where(s < tri, s / tri * half, half * (1 - u ** 2))
    shape = np.clip(w - np.abs(dx) + 0.5, 0, 1) * (s < tri + tail)
    v = s - dx ** 2 / (2 * radius)                     # bands bow upwards (ends lower)
    thick = band * np.interp(s, [0, tri, tri + tail], [0.44, 0.36, 0.26])
    dist = np.abs((v / band) % 1 - 0.5) * band         # 0 mid-band
    stripe = np.clip(thick / 2 - dist + 0.5, 0, 1)
    return ndimage.gaussian_filter(shape * stripe, 0.9 * scale)


def flat_collar_mask(model):
    """Texels the top_flat01 collar samples: its u > 1 faces around the neck
    (the hem/cuff linings are left out by the area bounds)."""
    import bigant_mesh as bm
    _P, _N, I, UV = bm.load_rl26("top", model)
    im = Image.new("L", (kd.W, kd.H), 0)
    d = ImageDraw.Draw(im)
    for t in I:
        u = UV[t, 0]
        if u.min() < 1:
            continue
        pts = [((uu - 1) * kd.W, (1 - vv) * kd.H) for uu, vv in UV[t]]
        if max(p[0] for p in pts) < 2300 and max(p[1] for p in pts) < 700:
            d.polygon(pts, fill=255)
    return np.asarray(im) > 0


def side_distance(panel):
    """Per texel: distance from the nearer side seam of its panel row (inf
    outside), using the row's leftmost/rightmost panel texel."""
    out = np.full(panel.shape, np.inf, np.float32)
    x = np.arange(panel.shape[1])
    for yy in np.flatnonzero(panel.any(1)):
        xs = np.flatnonzero(panel[yy])
        lo, hi = xs[0], xs[-1]
        out[yy, lo:hi + 1] = np.minimum(x[lo:hi + 1] - lo, hi - x[lo:hi + 1])
    return out


def paint(mask, colour, alpha=None):
    """An RGBA layer: colour where mask (or with a 0..1 alpha map)."""
    a = mask.astype(np.float32) if alpha is None else alpha * mask
    out = np.zeros(mask.shape + (4,), np.float32)
    out[..., :3] = colour
    out[..., 3] = np.round(a * 255)
    return out


# --------------------------------------------------------------------------
# layers (bottom to top)


def top(kit):
    y, x = kit.grid("top")
    masks = kd.top_masks()
    front, back, sleeves = masks["front"], masks["back"], masks["sleeves"]
    torso = front | back
    everywhere = np.ones_like(front)

    base = paint(everywhere, kit.colour("main"))
    base[x > 2290, :3] = kit.colour("sleeve")     # raglan sleeves = the shoulders, a deeper red

    # tonal "echo" pattern: strongest at the hem, faint over the chest and
    # shoulders, faintest through the middle (as on the shirt)
    pattern = echo(y, x, ECHO_SCALE)
    torso_amt = np.interp(y, [200, 700, 1100, 1450, kd.HEM_Y], [0.5, 0.42, 0.18, 0.45, 1.0])
    sleeve_amt = np.interp(y, [230, 500, kd.CUFF_Y], [0.42, 0.3, 0.8])
    amount = np.where(sleeves, sleeve_amt, np.where(torso, torso_amt, 0)) * pattern
    echo_layer = paint(everywhere, kit.colour("dark"), amount)

    # side panels: white piping SIDE_W in from each side seam below the
    # armpit, gold diagonal wedge between the piping lines towards the hem
    side = np.zeros((kd.H, kd.W, 4), np.float32)
    for panel, sign in ((front, 1), (back, -1)):
        d = side_distance(panel)
        below = y > kd.ARMPIT_Y - 10
        wedge = panel & below & (d < SIDE_W)
        u = sign * d / SIDE_W                  # -1 back piping .. 0 seam .. +1 front piping
        top_y = (GOLD_TOP_BACK + GOLD_TOP_FRONT) / 2 + u * (GOLD_TOP_FRONT - GOLD_TOP_BACK) / 2
        side[wedge & (y > top_y)] = kit.colour("gold") + (255,)
        side[panel & below & (d >= SIDE_W) & (d < SIDE_W + PIPE_W)] = kit.colour("white") + (255,)

    # orange raglan stitching on the panels and sleeves above the armpit
    stitch = np.zeros((kd.H, kd.W), bool)
    for part, low in ((back, kd.ARMPIT_Y - 20), (front & (y > 215), kd.ARMPIT_Y - 20), (sleeves, 540)):
        dist = ndimage.distance_transform_edt(part)
        stitch |= part & (dist < 7) & (dist > 2) & (y < low) & (y > 120)

    # back-neck gold band under the collar (PHINS UP sits on it)
    top_row = np.argmax(back, axis=0).astype(np.float32)
    band = back & (x > 330) & (x < 760) & (y < top_row[None, :] + 100)

    # ribbed cuffs
    cuffs = paint(sleeves & (y >= kd.CUFF_Y), kit.colour("cuff"))
    cuffs[(x > 2290) & (y >= kd.CUFF_Y) & ((y % 14) < 5)] = tuple(np.array(kit.colour("cuff")) * 0.9) + (255,)

    # collar: top_round05's collar strip, plus top_flat01's (the England RLWC
    # item this kit is installed on): its collar faces (u > 1) sample a thin
    # band along each panel's neck edge. Gold, with a red lip on the side away
    # from the panel.
    collar = np.zeros((kd.H, kd.W, 4), np.float32)
    strip = (x > 1110) & (x < 2160) & (y < 205)
    collar[strip] = kit.colour("gold") + (255,)
    collar[strip & (y < 40)] = kit.colour("main") + (255,)
    flat = flat_collar_mask(kit.model("top"))
    away = ndimage.distance_transform_edt(~(front | back))
    inward = ndimage.distance_transform_edt(flat)
    lip = flat & (away / np.maximum(away + inward, 1) > 0.62)
    collar[flat] = kit.colour("gold") + (255,)
    collar[lip] = kit.colour("main") + (255,)

    return [
        ("Base", base),
        ("Echo pattern", echo_layer),
        ("Side panels", side),
        ("Raglan stitching", paint(stitch, kit.colour("stitch"))),
        ("Back-neck band", paint(band, kit.colour("gold"))),
        ("Cuffs", cuffs),
        ("Collar", collar),
    ]


def shorts(kit):
    """Stock 2026 home shorts with the Classic logo painted out (Oxen goes on
    as a sponsor)."""
    im = kit.stock("m_shorts_dolphins_nrl_home_26_col_1").convert("RGBA")
    a = np.asarray(im.convert("RGB"))
    ImageDraw.Draw(im).rectangle((730, 1456, 914, 1512), fill=tuple(int(v) for v in a[1440, 700]) + (255,))
    return [("Shorts (stock 2026 home, Classic removed)", im)]


def socks(kit):
    return [("Socks (stock 2025 home)", kit.stock("m_socks_dolphins_nrl_home_25_col_1"))]


# --------------------------------------------------------------------------
# sponsor artwork made from real logos (kit.json "python" sources)


def oxen_stacked(kit):
    """Oxen's horizontal logo restacked: symbol over the wordmark."""
    im = Image.open(kit.file("@/sponsors/Oxen_Stacker_Logo_Horizontal_White.png")).convert("RGBA")
    symbol, word = kd.trim(im.crop((0, 0, 700, im.height))), kd.trim(im.crop((740, 0, im.width, im.height)))
    symbol = symbol.resize((round(word.width * 0.42), round(symbol.height * word.width * 0.42 / symbol.width)),
                           Image.LANCZOS)
    out = Image.new("RGBA", (word.width, symbol.height + 40 + word.height))
    out.alpha_composite(symbol, ((word.width - symbol.width) // 2, 0))
    out.alpha_composite(word, (0, symbol.height + 40))
    return out


def product_tag(kit):
    """The official product tag: NRL badge | Oxen, with the product line."""
    white = kit.colour("white")
    nrl = Image.open(kit.file("@/bulldogs_alternate_2026/logos/nrl_badge_light.png")).convert("RGBA")
    nrl = kd.solid(nrl.resize((round(52 * nrl.width / nrl.height), 52), Image.LANCZOS).getchannel("A"), white)
    tag = Image.new("RGBA", (170, 104), kit.colour("tag") + (255,))
    kd.place(tag, nrl, (42, 36))
    ImageDraw.Draw(tag).line((84, 10, 84, 62), fill=white, width=2)
    kd.place(tag, oxen_stacked(kit), (127, 36), width=58)
    small = ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf", 11)
    td = ImageDraw.Draw(tag)
    for text, yy in (("NRL TELSTRA PREMIERSHIP", 70), ("OFFICIAL PRODUCT", 85)):
        td.text((85 - td.textlength(text, font=small) / 2, yy), text, font=small, fill=white)
    return tag


def white_patch(kit, box):
    """A stock sponsor patch on a light-grey card -> RGBA with a white card
    and the card's outside (the jersey colour) transparent."""
    a = np.asarray(kit.stock(HOME).crop(tuple(box)), np.float32)
    grey = (a.min(2) > 150) & (a.max(2) - a.min(2) < 30)
    red = (a[..., 0] > 150) & (a[..., 1] < 70)
    card = ndimage.binary_fill_holes(ndimage.binary_closing(~red, iterations=2))
    card = ndimage.binary_opening(card, iterations=2)
    rgb = np.where(grey[..., None], np.array(kit.colour("white"), np.float32), a)
    alpha = ndimage.gaussian_filter(card.astype(np.float32), 0.8) * 255
    return Image.fromarray(np.dstack([rgb, alpha]).clip(0, 255).astype(np.uint8), "RGBA")
