"""
boards.py - the Rugby League Las Vegas wrap art for Allegiant Stadium's
cloth (tarpA_ATP250in_SSAO), which stadium_model.py also puts on the tall
boards and tunnel walls; see install.py.

After the reference broadcast: black wraps with gold diagonal "line
arrows", the Rugby League Las Vegas lockup, Telstra and JD. The LCD/LED
boards are left stock.
"""

import os

import numpy as np
from PIL import Image, ImageDraw, ImageFont

MOD_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(os.path.dirname(MOD_DIR))
RES = os.path.join(REPO_ROOT, "resources", "field-markings")
FONT = os.path.join(REPO_ROOT, "Maison-Neue-Extended-Bold.ttf")

W, ROW = 2048, 128
GOLD = (201, 162, 74)
BLACK = (8, 8, 8)
WHITE = (255, 255, 255)


def _alpha_crop(im):
    return im.crop(im.getchannel("A").point(lambda v: 255 if v > 8 else 0).getbbox())


def _tint(im, rgb):
    a = np.array(im)
    a[..., :3] = rgb
    return Image.fromarray(a)


def vegas_logo():
    """resources/.../nrl-vegas.png: black artwork on transparency."""
    return _alpha_crop(Image.open(os.path.join(RES, "field-centers", "nrl-vegas.png")).convert("RGBA"))


def jd_mark():
    """The JD roundel, cut from the bottom-right of the Vegas logo."""
    logo = vegas_logo()
    w, h = logo.size
    return _alpha_crop(logo.crop((int(w * 0.56), int(h * 0.80), w, h)))


def telstra_mark():
    """Telstra T + blob with the blue square keyed out."""
    a = np.array(Image.open(os.path.join(RES, "field-mid", "telstra.png")).convert("RGBA")).astype(np.int32)
    # the blue square, plus the purple-ish anti-aliased edge where it meets the
    # orange blob (anything bluer than it is red, and clearly bluer than green)
    blue = (((a[..., 2] > 180) & (a[..., 0] < 90) & (a[..., 1] < 140))
            | ((a[..., 2] > a[..., 0]) & (a[..., 2] > a[..., 1] + 25)))
    a[blue, 3] = 0
    return _alpha_crop(Image.fromarray(a.astype(np.uint8)))


def _fit(art, h):
    s = h / art.height
    return art.resize((max(1, round(art.width * s)), max(1, round(h))), Image.LANCZOS)


def line_arrows(w, h, colour, lines=5):
    """A block of parallel chevron strokes pointing right - the gold
    'line arrows' between the logos on the Vegas boards."""
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    dr = ImageDraw.Draw(im)
    depth = h * 0.45
    gap = (w - depth) / lines
    stroke = gap * 0.42
    for k in range(lines):
        x = k * gap
        dr.polygon([(x, 0), (x + stroke, 0), (x + stroke + depth, h / 2), (x + stroke, h), (x, h), (x + depth, h / 2)],
                   fill=colour)
    return im


def lockup(h, logo_rgb, text_rgb):
    """Vegas logo + 'RUGBY LEAGUE / LAS VEGAS' set beside it."""
    h = int(h)
    logo = _fit(_tint(vegas_logo(), logo_rgb), h)
    font = ImageFont.truetype(FONT, int(h * 0.36))
    lines = ["RUGBY LEAGUE", "LAS VEGAS"]
    tw = max(font.getbbox(t)[2] for t in lines)
    im = Image.new("RGBA", (logo.width + int(h * 0.25) + tw, h), (0, 0, 0, 0))
    im.alpha_composite(logo, (0, 0))
    dr = ImageDraw.Draw(im)
    x = logo.width + int(h * 0.25)
    dr.text((x, h * 0.08), lines[0], font=font, fill=text_rgb)
    dr.text((x, h * 0.52), lines[1], font=font, fill=text_rgb)
    return im


def text(s, h, rgb):
    font = ImageFont.truetype(FONT, int(h))
    l, t, r, b = font.getbbox(s)
    im = Image.new("RGBA", (r - l, b - t), (0, 0, 0, 0))
    ImageDraw.Draw(im).text((-l, -t), s, font=font, fill=rgb)
    return im


def row(bg, items, offset=0.0):
    """One 2048x128 row: items laid left to right with equal gaps, shifted
    by `offset` of the row width so a row's twin isn't identical. Items
    wrap around the edges - the boards tile the row horizontally."""
    im = Image.new("RGBA", (W, ROW), (*bg, 255))
    gap = (W - sum(a.width for a in items)) / len(items)
    if gap < ROW * 0.15:
        raise ValueError(f"row too crowded (gap {gap:.0f}px)")
    x = offset * W + gap / 2
    for art in items:
        y = (ROW - art.height) // 2
        for dx in (-W, 0, W):
            im.alpha_composite(art, (int(x) % W + dx, y)) if -art.width < int(x) % W + dx < W else None
        x += art.width + gap
    return im


# The draped cloth along the foot of the stands is tarpA_ATP250in_SSAO in
# stadium_t1.model: a flat grey (46) col_map with the swag folds in its
# normal map. install.py re-maps its UVs (stadium_model.py) so the texture
# spans the cloth's full height once and one tile is CLOTH_ASPECT x that
# height along the wall; the art is one band centred on that tile.
CLOTH_ASPECT = 6  # 6:1 since the Allegiant Stadium logo joined the row
CLOTH_W, CLOTH_H, CLOTH_SIZE = 1024 * CLOTH_ASPECT, 1024, 1024
ALLEGIANT_SVG = os.path.join(REPO_ROOT, "resources", "las-vegas-stadium", "Allegiant_Stadium.svg")


def allegiant_mark(h):
    """The "allegiant stadium" logo h px tall: its black lettering drawn
    white for the black wraps, the sun keeping its colours."""
    import io
    import resvg_py
    png = bytes(resvg_py.svg_to_bytes(svg_path=ALLEGIANT_SVG, width=2048))
    a = np.array(Image.open(io.BytesIO(png)).convert("RGBA"))
    dark = (a[..., :3].max(axis=2) < 90) & (a[..., 3] > 0)
    a[dark, :3] = 255
    return _fit(_alpha_crop(Image.fromarray(a)), h)
CLOTH_BAND_H, CLOTH_BAND_CY = 780, 0.5


def build_cloth():
    """The upright 1024x1024 tarp col_map: a black Vegas wrap with gold
    line arrows, the Rugby League Las Vegas lockup, Telstra, JD and the
    Allegiant Stadium logo."""
    global W, ROW
    saved = W, ROW
    W, ROW = CLOTH_W, CLOTH_BAND_H
    try:
        h = CLOTH_BAND_H * 0.72
        arrows = line_arrows(int(CLOTH_BAND_H * 0.95), int(CLOTH_BAND_H * 0.42), GOLD)
        mark = lockup(h * 0.8, GOLD, WHITE)
        tel = _fit(telstra_mark(), h * 0.85)
        jd = _fit(_tint(jd_mark(), WHITE), h * 0.75)
        allegiant = allegiant_mark(h * 0.5)
        band = row(BLACK, [arrows, mark, tel, jd, allegiant])
    finally:
        W, ROW = saved
    im = Image.new("RGBA", (CLOTH_W, CLOTH_H), (*BLACK, 255))
    im.alpha_composite(band, (0, int(CLOTH_BAND_CY * CLOTH_H - CLOTH_BAND_H / 2)))
    return im.convert("RGB").resize((CLOTH_SIZE, CLOTH_SIZE), Image.LANCZOS)


# The game's default NRL LED texture (lcd_sponsor_nrl_col, 2048x1024, upright
# here) is four sponsors, each two stacked 16:1 rows (Telstra, Hostplus,
# Kia Sportage/Sorento, KFC). Allegiant's LED panels show a whole two-row
# block at once, so every sponsor appeared twice. Each block becomes one
# line: the first row's repeating unit scaled up to the block's height and
# tiled a whole number of times across, so it still wraps seamlessly.
NRL_LED_REPEATS = (2, 2, 3, 2)  # logo repeats per row in each block, top to bottom
# The panels show the art about 0.77x as wide as drawn (the Kia logo came
# out condensed in-game), so each unit is pre-stretched horizontally.
LED_STRETCH = 1.3


def nrl_led_single_line(upright):
    w, h = upright.size
    row_h = h // 8
    out = Image.new("RGB", (w, h))
    for b, repeats in enumerate(NRL_LED_REPEATS):
        row = upright.crop((0, 2 * b * row_h, w, (2 * b + 1) * row_h)).convert("RGB")
        unit = row.crop((0, 0, w // repeats, row_h))
        block_h = 2 * row_h
        copies = max(1, round(w / (unit.width * LED_STRETCH * block_h / row_h)))
        slot_w = w // copies
        s = min(block_h / row_h, slot_w / (unit.width * LED_STRETCH))
        scaled = unit.resize((round(unit.width * s * LED_STRETCH), round(row_h * s)), Image.LANCZOS)
        block = Image.new("RGB", (w, block_h), row.getpixel((2, row_h // 2)))
        for c in range(copies):
            block.paste(scaled, (c * slot_w + (slot_w - scaled.width) // 2, (block_h - scaled.height) // 2))
        out.paste(block, (0, b * block_h))
    return out


if __name__ == "__main__":
    out = os.path.join(REPO_ROOT, "_build", "las-vegas-stadium")
    os.makedirs(out, exist_ok=True)
    cloth = build_cloth()
    cloth.save(os.path.join(out, "cloth.png"))
    # what shows on the wall: two tiles at the in-game aspect
    tile = cloth.resize((CLOTH_W // 4, CLOTH_H // 4))
    wall = Image.new("RGB", (tile.width * 2, tile.height))
    wall.paste(tile, (0, 0))
    wall.paste(tile, (tile.width, 0))
    wall.save(os.path.join(out, "cloth_wall.png"))
    print(out)
