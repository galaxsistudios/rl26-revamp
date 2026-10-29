#!/usr/bin/env python3
"""
controls_art.py - PlayStation art for the controls menu (Settings > Controls,
and the pause menu's controls page).

That screen is the legacy Lua UI (app/settings/settings_controls_aide.lua):
it draws ui/textures/controller.texture (the pad, 960x580) with
ui/textures/controller_lines.texture (1920x1160) on top, cutting pieces of
the second one out by the ControllerLabels[platform] rects in
intermediatelua/convant/uitextures.lua. On PC the platform is hardcoded to
"xbsx", whose rects are just a badge legend down each side (LT, LB, L, D-pad
| RT, RB, Y, B, A, X, R) - no pointer lines - so a PlayStation version only
needs a DualSense picture and PS badges in the same spots. The PC build ships
neither, so both are drawn here.
"""

import io
import os

import resvg_py
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(os.path.dirname(HERE))
FONT = os.path.join(REPO_ROOT, "extracted", "noesis", "workspace", "fonts", "texgyreheroscondensed-bold.ttf")

import sys
sys.path.insert(0, os.path.join(REPO_ROOT, "tools"))
import entries  # noqa: E402

CONTROLLER_ENTRY = entries.index_of("controller-art")  # ui/textures/controller.pc.dds  960x580 (1.0.5887: 102575)
LINES_ENTRY = entries.index_of("controller-lines")  # controller_lines.pc.dds  1920x1160 (1.0.5887: 102581)

# Badge boxes in the stock lines texture (found from its alpha), -> PS badge.
BADGES = {
    (158, 66, 242, 167): ("trigger", "L2"),
    (140, 217, 242, 290): ("bumper", "L1"),
    (1669, 65, 1752, 166): ("trigger", "R2"),
    (1669, 219, 1771, 292): ("bumper", "R1"),
    (1685, 339, 1770, 424): ("face", "triangle"),
    (1685, 472, 1770, 557): ("face", "circle"),
    (1685, 612, 1770, 697): ("face", "cross"),
    (1685, 754, 1770, 839): ("face", "square"),
}

INK = "#121212"

_FACE = {
    "triangle": '<path d="M 50 27 L 72 66 L 28 66 Z" fill="none" stroke="{ink}" stroke-width="7" stroke-linejoin="round"/>',
    "circle": '<circle cx="50" cy="50" r="21" fill="none" stroke="{ink}" stroke-width="7"/>',
    "cross": '<path d="M 31 31 L 69 69 M 69 31 L 31 69" stroke="{ink}" stroke-width="7" stroke-linecap="round"/>',
    "square": '<rect x="31" y="31" width="38" height="38" fill="none" stroke="{ink}" stroke-width="7"/>',
}

# DualSense, front view, same flat dark style as the stock Xbox picture.
DUALSENSE_SVG = """
<svg xmlns="http://www.w3.org/2000/svg" width="960" height="580" viewBox="0 0 960 580">
  <defs>
    <linearGradient id="body" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#2a2a2c"/><stop offset="1" stop-color="#121213"/>
    </linearGradient>
    <linearGradient id="pad" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#1c1c1e"/><stop offset="1" stop-color="#0c0c0d"/>
    </linearGradient>
    <radialGradient id="stick" cx="0.5" cy="0.45" r="0.6">
      <stop offset="0" stop-color="#3a3a3d"/><stop offset="1" stop-color="#151516"/>
    </radialGradient>
  </defs>

  <!-- shoulder buttons peeking over the top -->
  <path d="M 212 128 C 228 100 270 88 330 90 L 352 92 L 352 110 L 240 122 Z" fill="#1b1b1c" stroke="#d9d9d9" stroke-width="2"/>
  <path d="M 748 128 C 732 100 690 88 630 90 L 608 92 L 608 110 L 720 122 Z" fill="#1b1b1c" stroke="#d9d9d9" stroke-width="2"/>

  <!-- body -->
  <path d="M 480 104 L 345 104 C 300 104 262 110 232 121 C 192 136 172 166 162 212
           C 147 282 136 368 146 448 C 154 508 178 552 226 554 C 265 556 286 526 304 490
           C 326 450 352 424 398 422 L 562 422 C 608 424 634 450 656 490 C 674 526 695 556 734 554
           C 782 552 806 508 814 448 C 824 368 813 282 798 212 C 788 166 768 136 728 121
           C 698 110 660 104 615 104 Z"
        fill="url(#body)" stroke="#e6e6e6" stroke-width="2.5"/>
  <!-- touch pad + light bar -->
  <path d="M 366 106 L 594 106 L 590 196 C 588 218 576 228 556 229 L 404 229 C 384 228 372 218 370 196 Z"
        fill="url(#pad)" stroke="#bfbfbf" stroke-width="2"/>
  <path d="M 361 112 L 365 200" stroke="#5b8cff" stroke-width="3" stroke-linecap="round" opacity="0.9"/>
  <path d="M 599 112 L 595 200" stroke="#5b8cff" stroke-width="3" stroke-linecap="round" opacity="0.9"/>

  <!-- create / options -->
  <rect x="331" y="124" width="11" height="28" rx="5.5" fill="#0f0f10" stroke="#cfcfcf" stroke-width="2"/>
  <rect x="618" y="124" width="11" height="28" rx="5.5" fill="#0f0f10" stroke="#cfcfcf" stroke-width="2"/>

  <!-- d-pad -->
  <g fill="#161617" stroke="#d9d9d9" stroke-width="2" stroke-linejoin="round">
    <path d="M 270 160 L 300 160 L 300 190 L 285 205 L 270 190 Z"/>
    <path d="M 270 270 L 300 270 L 300 240 L 285 225 L 270 240 Z"/>
    <path d="M 230 200 L 230 230 L 260 230 L 275 215 L 260 200 Z"/>
    <path d="M 340 200 L 340 230 L 310 230 L 295 215 L 310 200 Z"/>
  </g>

  <!-- face buttons -->
  <g fill="#161617" stroke="#d9d9d9" stroke-width="2">
    <circle cx="675" cy="165" r="23"/><circle cx="725" cy="215" r="23"/>
    <circle cx="675" cy="265" r="23"/><circle cx="625" cy="215" r="23"/>
  </g>
  <g fill="none" stroke="#e8e8e8" stroke-width="3.5" stroke-linejoin="round" stroke-linecap="round">
    <path d="M 675 153 L 687 174 L 663 174 Z"/>
    <circle cx="725" cy="215" r="11"/>
    <path d="M 666 256 L 684 274 M 684 256 L 666 274"/>
    <rect x="615" y="205" width="20" height="20"/>
  </g>

  <!-- sticks -->
  <g>
    <circle cx="385" cy="322" r="47" fill="#0e0e0f" stroke="#d9d9d9" stroke-width="2"/>
    <circle cx="385" cy="322" r="35" fill="url(#stick)" stroke="#6a6a6d" stroke-width="2"/>
    <circle cx="575" cy="322" r="47" fill="#0e0e0f" stroke="#d9d9d9" stroke-width="2"/>
    <circle cx="575" cy="322" r="35" fill="url(#stick)" stroke="#6a6a6d" stroke-width="2"/>
  </g>

  <!-- PS button + mute -->
  <circle cx="480" cy="330" r="15" fill="#0f0f10" stroke="#d9d9d9" stroke-width="2"/>
  <path d="M 476 322 L 476 339 M 476 322 C 488 322 488 331 476 331" fill="none" stroke="#e8e8e8" stroke-width="2.5" stroke-linecap="round"/>
  <rect x="466" y="366" width="28" height="7" rx="3.5" fill="#0f0f10" stroke="#cfcfcf" stroke-width="1.5"/>
</svg>
"""


def _png(svg):
    return Image.open(io.BytesIO(bytes(resvg_py.svg_to_bytes(svg_string=svg)))).convert("RGBA")


def controller_image():
    return _png(DUALSENSE_SVG)


def _badge(kind, label, w, h):
    if kind == "face":
        d = min(w, h)
        svg = (f'<svg xmlns="http://www.w3.org/2000/svg" width="{d}" height="{d}" viewBox="0 0 100 100">'
               f'<circle cx="50" cy="50" r="46" fill="#ffffff" stroke="{INK}" stroke-width="4"/>'
               f'{_FACE[label].format(ink=INK)}</svg>')
        return _png(svg)
    if kind == "trigger":
        shape = (f'<path d="M 6 30 C 6 12 18 4 34 4 L 50 4 C 66 4 78 12 78 30 L 78 86 C 78 92 74 96 68 96 '
                 f'L 16 96 C 10 96 6 92 6 86 Z" fill="#ffffff" stroke="{INK}" stroke-width="4"/>')
        vb, size = "0 0 84 100", 52
    else:
        shape = (f'<path d="M 4 24 C 4 12 12 4 24 4 L 78 4 C 90 4 98 12 98 24 L 98 52 C 98 62 92 68 82 68 '
                 f'L 20 68 C 10 68 4 62 4 52 Z" fill="#ffffff" stroke="{INK}" stroke-width="4"/>')
        vb, size = "0 0 102 72", 50
    img = _png(f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="{vb}">{shape}</svg>')
    draw = ImageDraw.Draw(img)
    font = ImageFont.truetype(FONT, size)
    l, t, r, b = draw.textbbox((0, 0), label, font=font)
    cy = h * (0.58 if kind == "trigger" else 0.5)
    draw.text(((w - (r - l)) / 2 - l, cy - (b - t) / 2 - t), label, font=font, fill=INK)
    return img


def lines_image(stock_lines):
    img = stock_lines.copy()
    for (x0, y0, x1, y1), (kind, label) in BADGES.items():
        img.paste((0, 0, 0, 0), (x0 - 2, y0 - 2, x1 + 2, y1 + 2))
        badge = _badge(kind, label, x1 - x0, y1 - y0)
        img.alpha_composite(badge, (x0 + (x1 - x0 - badge.width) // 2, y0 + (y1 - y0 - badge.height) // 2))
    return img
