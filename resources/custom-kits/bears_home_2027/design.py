"""
design.py - Perth Bears 2027 home (New Balance), the club's first jersey:
black with red hoops (a red band across the yoke, the chest band behind Cash
Converters, a mid hoop and a lower hoop; the back the same with Penrite and
ATLAS on the black), red collar and cuffs. Painted by code from the user's
product shots (photos/src_front, src_back): the photos are wrapped onto the
shirt (tools/kit_photo.py) and every texel is given the nearest kit colour
(kit_photo.flat), with the hoops levelled on the torso and sleeves. Under the
sponsors (their own layers, kit.json) the design takes the colour around them.

Logo sources (kit.json):
  - Cash Converters: Wikimedia Commons File:CashConvertersLogo.svg (a traced
    bitmap: yellow ground, maroon "cash" + swoosh, white "converters"),
    recoloured as on the shirt by cash_converters(): ground dropped, "cash" and
    the swoosh white, "converters" gold.
  - New Balance: Wikimedia Commons File:New_Balance_logo.svg, in white.
  - Perth Bears crest: the NRL site's light badge,
    resources/nrl-site-logos/nrl/perth-bears/badge-light.svg (PERTH BEARS +
    the bear), rasterised to logos/perth_bears_badge_light.png.
  - Budget Direct sleeves: the stock Rabbitohs 2026 home top's cards.
  - XFM, Penrite, ATLAS: no clean source found (not in the game, not on
    Commons, no logo file on penriteoil.com.au), so photo_logo() keys them out
    of the user's photos as placeholders.
"""

import numpy as np
from PIL import Image

import kit_design as kd
import kit_photo

# Red hoops round the torso, in model height (m). Measured down the centre of
# the prepped photos (photos/front.png, back.png) and converted through the
# neck/hem landmarks (front: px 122 = 1.462, 954 = 0.931; back: 45 = 1.547,
# 953 = 0.937). Front and back differ by up to 0.02, so each side keeps its own:
#   front px 169-283 / back 191-311  chest band (NRL, XFM, crest / Penrite)
#   front px 438-541 / back 427-553  middle hoop
#   front px 677-806 / back 682-814  lower hoop
HOOPS_FRONT = [(1.360, 1.432), (1.195, 1.261), (1.026, 1.108)]
HOOPS_BACK = [(1.368, 1.449), (1.206, 1.290), (1.030, 1.119)]
SLEEVE_X = 2290           # sleeves start here on the texture (kit_design layout)
CUFF_Y = 760              # thin red cuff trim: the sleeve island below this row
COLLAR_BOX = (1080, 0, 2130, 200)   # the collar's own UV island (top centre strip)


def top(kit):
    """Painted from the measurements above (the flat photo wrap put the hoops
    in the wrong place around the big chest sponsors)."""
    W, H = kit.size("top")
    P, _N, covered = kit_photo.surface("top", kit.model("top"), (W, H))
    y = P[..., 1]
    tex_x = np.arange(W)[None, :].repeat(H, 0)
    tex_y = np.arange(H)[:, None].repeat(W, 1)
    # front vs back by the side seams, not by z: the upper chest and the sides
    # of top_round05's front sit at z < 0 (down to -0.09), and taking them as
    # back stepped the hoops at the front panel's edges. Each row's seams are
    # its widest texels (max |x|) between the back centre (x 540), the front
    # centre (1645) and the sleeves
    wide = np.where(covered, np.abs(P[..., 0]), -1)
    seam_l = 540 + wide[:, 540:1645].argmax(1)
    seam_r = 1645 + wide[:, 1645:SLEEVE_X].argmax(1)
    front = (tex_x >= seam_l[:, None]) & (tex_x <= seam_r[:, None])
    x0, y0, x1, y1 = COLLAR_BOX
    collar = covered & (tex_x >= x0) & (tex_x < x1) & (tex_y >= y0) & (tex_y < y1)
    torso = covered & (tex_x < SLEEVE_X) & ~collar
    sleeve = covered & (tex_x >= SLEEVE_X)
    hoops = np.zeros((H, W), bool)
    for side, bands in ((front, HOOPS_FRONT), (~front, HOOPS_BACK)):
        for lo, hi in bands:
            hoops |= torso & side & (y >= lo) & (y < hi)
    cuffs = sleeve & (tex_y >= CUFF_Y)
    layer = lambda m, c: kd.solid(Image.fromarray((m * 255).astype(np.uint8)), kit.colour(c))  # noqa: E731
    return [("Base (black)", layer(covered, "black")),
            ("Red hoops", layer(hoops, "red")),
            ("Collar (red)", layer(collar, "red")),
            ("Cuffs (red)", layer(cuffs, "red"))]


# Shorts (user's photos: photos/src_shorts_front/side/back): black, a red hem
# band, and on the outer side of each leg two red chevrons pointing up (the
# claw marks between them are left off). shorts01 unwraps one leg per half of
# the texture, front facing +z; heights in model units (m), the shorts run
# 0.683 (hem) to 1.002 (waist), the photo ~0.00078 m/px:
SHORTS_HEM = 0.708        # red band: hem up to here (~32 px of 410 in the photos)
CHEVRONS = (0.858, 0.752) # apex heights (side photo px ~250 and ~390; the lower one kept clear of the hem)
CHEVRON_T = 0.020         # band thickness (~25 px)
CHEVRON_HALF = 0.045      # half width across the side seam
CHEVRON_SLOPE = 0.5       # drop per unit across (arms ~50 px wide, ~25 px down)


def shorts(kit):
    W, H = kit.size("shorts")
    P, N, covered = kit_photo.surface("shorts", kit.model("shorts"), (W, H))
    y = P[..., 1]
    hem = covered & (y < SHORTS_HEM)
    # outer side of each leg: the normal points away from the body's centre line
    outer = covered & (np.sign(P[..., 0]) * N[..., 0] > 0.55)
    zc = np.median(P[covered][:, 2])
    across = np.abs(P[..., 2] - zc)
    chev = np.zeros((H, W), bool)
    for apex in CHEVRONS:
        d = y - (apex - CHEVRON_SLOPE * across)
        chev |= outer & (across < CHEVRON_HALF) & (d <= 0) & (d > -CHEVRON_T)
    layer = lambda m, c: kd.solid(Image.fromarray((m * 255).astype(np.uint8)), kit.colour(c))  # noqa: E731
    return [("Shorts base (black)", Image.new("RGBA", (W, H), tuple(kit.colour("black")) + (255,))),
            ("Hem band (red)", layer(hem, "red")),
            ("Side chevrons (red)", layer(chev, "red"))]


def socks(kit):
    """Placeholder until Perth's socks are revealed: plain black."""
    return [("Socks (black, placeholder)", Image.new("RGBA", kit.size("socks"), tuple(kit.colour("black")) + (255,)))]


def cash_converters(kit):
    """The Commons logo as printed on the shirt: each texel's nearest of the
    logo's three colours; the yellow ground goes, maroon becomes white and
    white becomes gold."""
    a = np.asarray(Image.open(kit.file("logos/cash_converters.png")).convert("RGB"), np.float32)
    pal = np.array([[240, 179, 16], [152, 2, 46], [255, 255, 255]], np.float32)
    d = np.stack([np.sqrt(((a - c) ** 2).sum(-1)) for c in pal], -1)
    lab = d.argmin(-1)
    # soft edge: how much nearer the texel is to ink than to the ground
    ink = np.minimum(d[..., 1], d[..., 2])
    alpha = np.clip((d[..., 0] - ink) / 60 + 0.5, 0, 1)
    out = np.zeros(a.shape[:2] + (4,), np.float32)
    out[..., :3] = np.where((lab == 2)[..., None], np.array(kit.colour("gold"), np.float32),
                            np.array(kit.colour("white"), np.float32))
    out[..., 3] = alpha * 255
    return kd.trim(Image.fromarray(out.astype(np.uint8), "RGBA"))


def photo_logo(kit, side, box, white=False):
    """A logo keyed out of the user's photo (side "front"/"back", box in the
    source photo's pixels): the light (white / gold) parts, alpha from
    brightness. white=True keys on the darkest channel instead, so a white
    logo on the red band (XFM) leaves the red behind. 4x upscaled so it isn't
    blocky on the 4096 texture."""
    im = Image.open(kit.file(f"photos/src_{side}.png")).convert("RGB").crop(tuple(box))
    im = im.resize((im.width * 4, im.height * 4), Image.LANCZOS)
    a = np.asarray(im, np.float32)
    lum = a.min(-1) if white else a.max(-1)
    alpha = np.clip((lum - 110) / 90, 0, 1)
    out = np.dstack([a, alpha * 255])
    return kd.trim(Image.fromarray(out.clip(0, 255).astype(np.uint8), "RGBA"))
