import os
import subprocess
import sys
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont
import svgelements as se
from scipy.ndimage import gaussian_filter

HERE = os.path.dirname(os.path.abspath(__file__))
ART = os.path.join(HERE, "art")
FACE_W, FACES, H = 405, 4, 2048
FW = FACE_W * FACES  # x past this: top cap + white strip


def blur(a, r):
    return gaussian_filter(np.float32(a), r)


def load_stock(team):
    """Stock pad in in-game orientation: the game shows these textures flipped
    top-to-bottom (mud along the ground, Macca's/Toyota stored upside-down), so
    flip in, draw, flip out. Returns (rgb float array, grunge shade, blue mask)."""
    stock = np.asarray(Image.open(os.path.join(ART, f"stock_goalpost_{team}_col.png")).convert("RGB")
                       .transpose(Image.FLIP_TOP_BOTTOM)).astype(np.float32)
    lum = stock @ np.array((0.3, 0.59, 0.11), np.float32)
    blue = np.clip((stock[..., 2] - stock[..., 0] - 5) / 30, 0, 1)   # how "pad blue" a pixel is
    base_lum = np.median(lum[blue > 0.99])
    shade = 1 + (np.clip(lum / base_lum, 0.4, 1.6) - 1) * 0.55
    return stock, shade, blue


# Stock encodings: goal pads 2048x2048 DXT1 12 mips, corner posts 1024x1024 DXT1 11 mips.
STOCK_DDS = {"goalpost": (12, 2796344), "cornerpost": (11, 699192)}


def save(team, entry_hash, img, kind="goalpost"):
    """Flip back to stored orientation, write the PNG and encode like the stock entry."""
    mips, size = STOCK_DDS[kind]
    out = os.path.join(ART, f"{kind}_{team}_col.png")
    img.transpose(Image.FLIP_TOP_BOTTOM).save(out)
    subprocess.run([texconv, "-nologo", "-y", "-f", "BC1_UNORM", "-m", str(mips), "--ignore-srgb", "-o", ART, out],
                   check=True, stdout=subprocess.DEVNULL)
    dds = open(os.path.splitext(out)[0] + ".dds", "rb").read()
    if dds[84:88] != b"DXT1" or len(dds) != size:
        raise SystemExit(f"encoded {kind} {team} is {len(dds)} bytes ({dds[84:88]}), stock is {size} DXT1")
    os.replace(os.path.splitext(out)[0] + ".dds", os.path.join(HERE, "textures", f"{entry_hash}_{kind}_{team}_col.dds"))
    print(f"{kind} {team}: {out}")


# ---- Dolphins: Budget Direct -------------------------------------------------

def budget_direct_one_line(height):
    """Budget Direct on one line (Direct moved beside Budget, (R) dropped), RGBA, in the logo's colours."""
    paths = [e for e in se.SVG.parse(os.path.join(ART, "budget-direct.svg")).elements() if isinstance(e, se.Path)]
    budget = [paths[i] for i in (0, 1, 2, 3, 10, 11)]
    direct = [paths[i] for i in (4, 5, 6, 7, 8, 9)]
    placed = [(p, 0, 0) for p in budget] + [(p, 590 + 45 - 57, 126 - 267) for p in direct]
    x0, y0, x1, y1 = 0, 0, 559 + 578, 163
    ss = 4
    k = height * ss / (y1 - y0)
    W, Hh = int((x1 - x0) * k) + 4, height * ss + 4
    masks = {}  # the logo's own fills: "Bud" dark grey, "get Direct" red
    for p, dx, dy in placed:
        m = np.zeros((Hh, W), bool)
        for sub in p.as_subpaths():
            sp = se.Path(sub)
            n = max(32, int(sp.length() * k / 2))
            pts = [((q.x + dx) * k + 2, (q.y + dy) * k + 2) for q in (sp.point(t) for t in np.linspace(0, 1, n))]
            im = Image.new("1", (W, Hh), 0)
            ImageDraw.Draw(im).polygon(pts, fill=1)
            m ^= np.asarray(im)
        colour = (p.fill.red, p.fill.green, p.fill.blue)
        masks[colour] = masks.get(colour, np.zeros((Hh, W), bool)) | m
    img = Image.new("RGBA", (W // ss, Hh // ss), (0, 0, 0, 0))
    for colour, mask in masks.items():
        layer = Image.new("RGBA", img.size, colour + (255,))
        layer.putalpha(Image.fromarray(np.uint8(mask) * 255).resize(img.size, Image.LANCZOS))
        img.alpha_composite(layer)
    return img


def dolphins():
    red = np.array((198, 20, 34), np.float32)
    stock, shade, blue = load_stock("dolphins")
    # Faces: whole area red, shaded by the stock grunge. Inpaint the old Kinetic
    # logo: keep only solidly blue pixels (logo edges eroded away) and fill the
    # holes with a normalised blur of the surrounding grunge.
    keep = np.asarray(Image.fromarray(np.uint8(blue > 0.95) * 255).filter(ImageFilter.MinFilter(9))) > 0
    fill = blur(shade * keep, 40) / np.maximum(blur(keep.astype(np.float32), 40), 1e-3)
    face_shade = np.where(keep, shade, fill)
    out = stock.copy()
    out[:, :FW] = red * face_shade[:, :FW, None]
    # Cap / edge strips on the right: recolour only the blue.
    rc = red * shade[..., None]
    out[:, FW:] = stock[:, FW:] * (1 - blue[:, FW:, None]) + rc[:, FW:] * blue[:, FW:, None]

    img = Image.fromarray(np.uint8(np.clip(out, 0, 255)), "RGB").convert("RGBA")
    panel_x, panel_top, panel_bot, radius = 48, 250, 1730, 46
    logo = budget_direct_one_line(178).rotate(-90, expand=True)     # reads top to bottom, like the photo
    over = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(over)
    for f in range(FACES):
        x = f * FACE_W
        # Only top-right and bottom-left are rounded on the real pads (in-game view).
        d.rounded_rectangle((x + panel_x, panel_top, x + FACE_W - panel_x, panel_bot), radius, fill=(238, 238, 236, 255),
                            corners=(False, True, False, True))
        lx = x + (FACE_W - logo.width) // 2
        ly = panel_top + (panel_bot - panel_top - logo.height) // 2
        over.alpha_composite(logo, (lx, ly))
    img = Image.alpha_composite(img, over)
    # A little of the stock grunge back over the white panels so they aren't flat.
    arr = np.asarray(img).astype(np.float32)
    g = np.clip(1 + (blur(face_shade, 6) - 1) * 0.5, 0.9, 1.05)[..., None]
    arr[:, :FW, :3] *= g[:, :FW]
    save("dolphins", "26d854d6718835e1", Image.fromarray(np.uint8(np.clip(arr, 0, 255)), "RGBA"))


# ---- Bulldogs: Laundy ----------------------------------------------------------

def bulldogs():
    # The stock pad is already plain Bulldogs blue with grunge; just letter it.
    stock, shade, _ = load_stock("bulldogs")
    img = Image.fromarray(np.uint8(np.clip(stock, 0, 255)), "RGB").convert("RGBA")
    font = ImageFont.truetype(r"C:\Windows\Fonts\arialbd.ttf", 300)
    word, top, bot, cap_w = "LAUNDY", 170, 1830, 250   # upright letters stacked top to bottom
    step = (bot - top) / len(word)
    over = Image.new("RGBA", img.size, (0, 0, 0, 0))
    for f in range(FACES):
        cx = f * FACE_W + FACE_W / 2
        for i, ch in enumerate(word):
            # Each letter on its own canvas, squeezed to a uniform cap height.
            x0, y0, x1, y1 = font.getbbox(ch)
            glyph = Image.new("L", (x1 - x0, y1 - y0), 0)
            ImageDraw.Draw(glyph).text((-x0, -y0), ch, font=font, fill=255)
            gh = int(step * 0.8)
            gw = min(cap_w, int(glyph.width * gh / glyph.height * 0.95))
            glyph = glyph.resize((gw, gh), Image.LANCZOS)
            layer = Image.new("RGBA", glyph.size, (240, 240, 238, 255))
            layer.putalpha(glyph)
            over.alpha_composite(layer, (int(cx - gw / 2), int(top + i * step + (step - gh) / 2)))
    img = Image.alpha_composite(img, over)
    # Stock grunge over the lettering too.
    arr = np.asarray(img).astype(np.float32)
    g = np.clip(1 + (blur(shade, 6) - 1) * 0.5, 0.9, 1.05)[..., None]
    arr[:, :FW, :3] *= g[:, :FW]
    save("bulldogs", "d5dbf56836cd11a2", Image.fromarray(np.uint8(np.clip(arr, 0, 255)), "RGBA"))


# ---- Sharks: Nulon ---------------------------------------------------------------

def nulon_logo():
    """art/nulon.png (white NULON + red swoosh on black) cropped, black keyed to transparent."""
    rgb = np.asarray(Image.open(os.path.join(ART, "nulon.png")).convert("RGB")).astype(np.float32)
    a = rgb.max(axis=2) / 255
    ys, xs = np.nonzero(a > 0.05)
    rgb, a = rgb[ys.min():ys.max() + 1, xs.min():xs.max() + 1], a[ys.min():ys.max() + 1, xs.min():xs.max() + 1]
    col = np.clip(rgb / np.maximum(a, 1e-3)[..., None], 0, 255)
    return Image.fromarray(np.uint8(np.dstack([col, a * 255])), "RGBA")


def sharks():
    black = np.array((20, 20, 22), np.float32)
    stock = np.asarray(Image.open(os.path.join(ART, "stock_goalpost_sharks_col.png")).convert("RGB")
                       .transpose(Image.FLIP_TOP_BOTTOM)).astype(np.float32)
    lum = stock @ np.array((0.3, 0.59, 0.11), np.float32)
    # The stock pad is white with red Rinnai lettering; grunge = how much darker
    # than the clean white a pixel is, with the red lettering inpainted.
    red = (stock[..., 0] - stock[..., 2]) > 30
    keep = ~(np.asarray(Image.fromarray(np.uint8(red) * 255).filter(ImageFilter.MaxFilter(9))) > 0)
    dirt = np.clip(1 - lum / np.median(lum[:, :FW][keep[:, :FW]]), 0, 1)
    fill = blur(dirt * keep, 40) / np.maximum(blur(keep.astype(np.float32), 40), 1e-3)
    dirt = np.where(keep, dirt, fill)
    # Black faces and cap; dirt shows as a faint brown-grey lift on the black.
    mud = np.array((70, 60, 50), np.float32)
    base = black + (mud - black) * np.clip(dirt * 3, 0, 1)[..., None]
    out = stock.copy()
    out[:, :FW] = base[:, :FW]
    cap = (slice(H - 430, H), slice(FW, H))   # in-game orientation: stored top rows
    out[cap] = base[cap] + (stock[cap] - stock[cap].mean()) * 0.25   # keep the cap's crease shading

    img = Image.fromarray(np.uint8(np.clip(out, 0, 255)), "RGB").convert("RGBA")
    logo = nulon_logo()
    length = 1250
    logo = logo.resize((length, int(logo.height * length / logo.width)), Image.LANCZOS).rotate(-90, expand=True)
    for f in range(FACES):
        img.alpha_composite(logo, (f * FACE_W + (FACE_W - logo.width) // 2, (H - logo.height) // 2))
    save("sharks", "0c4dda836ac0055a", img)


# ---- Rabbitohs: Deicorp ------------------------------------------------------------

def rabbitohs():
    blue = np.array((30, 72, 168), np.float32)
    stock = np.asarray(Image.open(os.path.join(ART, "stock_goalpost_rabbitohs_col.png")).convert("RGB")
                       .transpose(Image.FLIP_TOP_BOTTOM)).astype(np.float32)
    lum = stock @ np.array((0.3, 0.59, 0.11), np.float32)
    # Stock = pink pad with white Stoke's ovals: keep the pink's grunge, inpaint the ovals.
    pink = np.clip((stock[..., 0] - stock[..., 1] - 30) / 30, 0, 1)
    keep = np.asarray(Image.fromarray(np.uint8(pink > 0.95) * 255).filter(ImageFilter.MinFilter(9))) > 0
    shade = 1 + (np.clip(lum / np.median(lum[keep]), 0.4, 1.6) - 1) * 0.55
    fill = blur(shade * keep, 40) / np.maximum(blur(keep.astype(np.float32), 40), 1e-3)
    face_shade = np.where(keep, shade, fill)
    out = stock.copy()
    out[:, :FW] = blue * face_shade[:, :FW, None]
    cap = (slice(H - 430, H), slice(FW, H))   # in-game orientation: stored top rows
    # Recolour the cap's light cover, keep its crease shading and the dark post hole.
    cover = np.clip((lum[cap] - 95) / 25, 0, 1)[..., None]   # hole ~83, cover ~136
    crease = (lum[cap] - np.median(lum[cap][cover[..., 0] > 0.99]))[..., None] * 0.25   # grey, not the cap's pink
    out[cap] = stock[cap] * (1 - cover) + (blue + crease) * cover

    img = Image.fromarray(np.uint8(np.clip(out, 0, 255)), "RGB").convert("RGBA")
    # art/deicorp.png: navy on transparent. White version, emblem and wordmark apart
    # (the tagline is left off, as on the real pads).
    src = Image.open(os.path.join(ART, "deicorp.png")).convert("RGBA")
    white = Image.new("RGBA", src.size, (240, 240, 238, 255))
    white.putalpha(src.getchannel("A"))
    emblem = white.crop((118, 479, 359, 720)).resize((270, 270), Image.LANCZOS)
    word = white.crop((436, 507, 1082, 623))
    length = 1120
    word = word.resize((length, int(word.height * length / word.width)), Image.LANCZOS).rotate(-90, expand=True)
    for f in range(FACES):
        x = f * FACE_W
        img.alpha_composite(emblem, (x + (FACE_W - emblem.width) // 2, 300))
        img.alpha_composite(word, (x + (FACE_W - word.width) // 2, 660))
    save("rabbitohs", "b26f9755b31a2bc8", img)


# ---- Roosters: Metro on blue instead of purple ------------------------------------------

def roosters():
    # Stored orientation is fine here: nothing is drawn, only the background is shifted.
    stock = np.asarray(Image.open(os.path.join(ART, "stock_goalpost_roosters_col.png")).convert("RGB")).astype(np.float32)
    purple, blue = np.array((82, 48, 126), np.float32), np.array((28, 44, 150), np.float32)
    # How much of each pixel is the purple: by colour distance, soft so the
    # antialiased logo edges shift part way (no purple fringe).
    dist = np.linalg.norm(stock - purple, axis=2)
    share = np.clip(1 - (dist - 25) / 60, 0, 1)[..., None]
    lum = stock @ np.array((0.3, 0.59, 0.11), np.float32)
    shade = np.clip(lum / (purple @ np.array((0.3, 0.59, 0.11), np.float32)), 0.5, 1.5)[..., None]
    out = stock + share * (blue - purple) * shade
    save("roosters", "32ac744e305af7a5",
         Image.fromarray(np.uint8(np.clip(out, 0, 255)), "RGB").transpose(Image.FLIP_TOP_BOTTOM))


# ---- World Cup corner posts: Harvey Norman --------------------------------------------
# Corner posts (1024x1024) use the same scheme as the pads: four faces of
# CORNER_FACE_W px down the left of the texture, stored flipped top-to-bottom.
CORNER_FACE_W = 104


def harvey_norman_one_line():
    """art/harvey-norman.png (white on red, two lines) as one line, white on transparent."""
    rgb = np.asarray(Image.open(os.path.join(ART, "harvey-norman.png")).convert("RGB")).astype(np.float32)
    a = np.clip((rgb[..., 1] - 9) / 246, 0, 1)    # background (235, 9, 11) -> white
    lines = []
    for y0, y1 in ((60, 182), (182, 290)):         # Harvey / Norman, split in the gap at rows 178-187
        band = a[y0:y1]
        xs = np.nonzero(band.max(axis=0) > 0.1)[0]
        lines.append(band[:, xs.min():xs.max() + 1])
    space = 40
    h = max(l.shape[0] for l in lines)
    w = sum(l.shape[1] for l in lines) + space
    out = np.zeros((h, w), np.float32)
    # Baselines: Harvey's band has the y descender below its baseline (~row 158 of 60-182);
    # Norman's baseline is ~row 268 of 182-290. Align both.
    out[0:lines[0].shape[0], :lines[0].shape[1]] = lines[0]
    dy = (158 - 60) - (268 - 182)
    out[dy:dy + lines[1].shape[0], lines[0].shape[1] + space:] = np.maximum(
        out[dy:dy + lines[1].shape[0], lines[0].shape[1] + space:], lines[1][:h - dy])
    ys = np.nonzero(out.max(axis=1) > 0.1)[0]
    out = out[ys.min():ys.max() + 1]
    img = Image.new("RGBA", (out.shape[1], out.shape[0]), (245, 245, 243, 255))
    img.putalpha(Image.fromarray(np.uint8(out * 255)))
    return img


def rlwc26_corners():
    red = np.array((228, 12, 20), np.float32)
    # Grunge from the Cowboys corner post (red, Toyota logos inpainted); the
    # World Cup posts themselves are a flat teal with none.
    stock = np.asarray(Image.open(os.path.join(ART, "stock_cornerpost_cowboys_col.png")).convert("RGB")
                       .transpose(Image.FLIP_TOP_BOTTOM)).astype(np.float32)
    lum = stock @ np.array((0.3, 0.59, 0.11), np.float32)
    plain = np.clip((stock[..., 0] - stock[..., 1] - 60) / 30, 0, 1)
    keep = np.asarray(Image.fromarray(np.uint8(plain > 0.95) * 255).filter(ImageFilter.MinFilter(9))) > 0
    shade = 1 + (np.clip(lum / np.median(lum[keep]), 0.4, 1.6) - 1) * 0.55
    fill = blur(shade * keep, 30) / np.maximum(blur(keep.astype(np.float32), 30), 1e-3)
    out = red * np.where(keep, shade, fill)[..., None]
    img = Image.fromarray(np.uint8(np.clip(out, 0, 255)), "RGB").convert("RGBA")
    logo = harvey_norman_one_line()
    thick = 66
    logo = logo.resize((int(logo.width * thick / logo.height), thick), Image.LANCZOS).rotate(-90, expand=True)
    for f in range(4):   # reads top to bottom, centred on each face
        img.alpha_composite(logo, (f * CORNER_FACE_W + (CORNER_FACE_W - logo.width) // 2, (1024 - logo.height) // 2))
    save("rlwc26_male", "6ae1b4312d3975a2", img, "cornerpost")
    save("rlwc26_female", "ef93f622fcecda4f", img, "cornerpost")


sys.path.insert(0, os.path.join(HERE, "..", "..", "tools"))
import games  # noqa: E402
texconv = games.toolchain("texconv", "texconv.exe")
if not os.path.exists(texconv):  # dev machine: the copy package_revamp downloaded
    texconv = os.path.join(HERE, "..", "..", "_build", "package_cache", "texconv.exe")

PADS = {"dolphins": dolphins, "bulldogs": bulldogs, "sharks": sharks, "rabbitohs": rabbitohs, "roosters": roosters, "rlwc26": rlwc26_corners}
if __name__ == "__main__":
    for name in sys.argv[1:] or PADS:
        PADS[name]()
