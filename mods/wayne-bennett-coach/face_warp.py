#!/usr/bin/env python3
"""
face_warp.py - fit an AI-generated face texture onto the shared tier-1 head
UV layout.

Every scanned head (players and coaches, 3226 verts) uses the SAME UV
layout, so any head colour map works on any head mesh as long as the
features sit where the template expects them. The source image got the
teeth / tongue / lip strips and ears right, but its eyes, nose and mouth sit
~90-145 px low (in 1024 px) and the face is ~35% too long. This closes the
open mouth, then thin-plate-spline warps landmark pairs (template <- source)
with the atlas pieces and outer border pinned.

Template landmarks were read off the UV wireframe (eye rings, nostrils, lip
line, ear rings) and the donor mesh's midline (nose tip v=382, chin front
v=552). Source landmarks are for wayne_bennett_face.png.

    python face_warp.py <in.png> <out.png>
"""

import sys

import numpy as np
from PIL import Image
from scipy.interpolate import RBFInterpolator
from scipy.ndimage import binary_dilation, gaussian_filter, map_coordinates, zoom

# (template x, y) <- (source x, y), 1024 px space
PAIRS = [
    ((392, 315), (380, 408)), ((462, 315), (455, 408)), ((562, 315), (568, 408)), ((632, 315), (645, 408)),  # eye corners
    ((427, 300), (418, 392)), ((597, 300), (605, 392)), ((427, 330), (418, 422)), ((597, 330), (605, 422)),  # lids
    ((427, 285), (418, 370)), ((597, 285), (605, 370)), ((512, 300), (512, 395)),                           # brows, bridge
    ((512, 382), (512, 505)), ((512, 415), (512, 538)), ((478, 405), (470, 530)), ((546, 405), (554, 530)),  # nose
    ((458, 466), (440, 612)), ((566, 466), (590, 612)), ((512, 446), (512, 592)), ((512, 488), (512, 640)),  # mouth
    ((512, 552), (512, 735)), ((440, 535), (425, 705)), ((584, 535), (600, 705)),                           # chin
    ((360, 480), (335, 620)), ((664, 480), (690, 620)),                                                     # jaw
    ((228, 430), (220, 465)), ((796, 430), (805, 465)), ((228, 385), (220, 385)), ((796, 385), (805, 385)),  # ears
    ((228, 480), (222, 545)), ((796, 480), (802, 545)),
    ((512, 650), (512, 800)), ((512, 760), (512, 880)), ((380, 690), (365, 820)), ((644, 690), (659, 820)),  # under chin
    ((512, 200), (512, 250)), ((380, 220), (380, 260)), ((644, 220), (644, 260)),                           # forehead
]
# pinned: scalp top, atlas pieces (lip strips, teeth, tongue), outer border
PINNED = [
    (512, 40), (250, 80), (774, 80), (150, 250), (874, 250), (150, 620), (874, 620),
    (0, 0), (1023, 0), (0, 1023), (1023, 1023), (512, 0), (512, 1023), (0, 512), (1023, 512),
    (256, 0), (768, 0), (256, 1023), (768, 1023), (0, 256), (0, 768), (1023, 256), (1023, 768),
    (60, 60), (964, 60), (120, 900), (860, 900), (300, 900), (724, 900), (250, 1000), (774, 1000),
]
MOUTH_BOX = (585, 640, 430, 600)  # y0, y1, x0, x1 of the open-mouth gap in the source


def close_mouth(im, s):
    y0, y1, x0, x1 = (int(v * s) for v in MOUTH_BOX)
    reg = im[y0:y1, x0:x1]
    gap = binary_dilation(reg.mean(-1) < 70, iterations=2)
    fill, known = reg.copy(), ~gap
    for _ in range(200):  # diffuse the lip colour into the gap
        w = gaussian_filter(known.astype(np.float32), 2)
        blur = np.stack([gaussian_filter(fill[..., c] * known, 2) for c in range(3)], -1) / np.maximum(w, 1e-4)[..., None]
        fill[gap] = blur[gap]
        known = known | (w > 0.25)
    reg[gap] = fill[gap] * 0.85  # a touch darker: closed-lip crease
    im[y0:y1, x0:x1] = reg


def warp(src):
    im = np.asarray(src.convert("RGB")).astype(np.float32)
    n = im.shape[0]
    s = n / 1024.0
    close_mouth(im, s)
    pairs = PAIRS + [(p, p) for p in PINNED]
    t = np.array([p[0] for p in pairs], float) * s
    d = np.array([p[1] for p in pairs], float) * s - t
    rbf = RBFInterpolator(t, d, kernel="thin_plate_spline", smoothing=1.0)
    step = 4  # evaluate on a coarse grid, then upsample the displacement
    ax = np.arange(0, n + step, step)
    coarse = rbf(np.stack(np.meshgrid(ax, ax), -1).reshape(-1, 2).astype(float)).reshape(len(ax), len(ax), 2)
    dx = zoom(coarse[..., 0], step, order=1)[:n, :n]
    dy = zoom(coarse[..., 1], step, order=1)[:n, :n]
    x, y = np.meshgrid(np.arange(n), np.arange(n))
    out = np.stack([map_coordinates(im[..., c], [y + dy, x + dx], order=1, mode="nearest") for c in range(3)], -1)
    return Image.fromarray(np.clip(out, 0, 255).astype(np.uint8))


if __name__ == "__main__":
    warp(Image.open(sys.argv[1])).save(sys.argv[2])
