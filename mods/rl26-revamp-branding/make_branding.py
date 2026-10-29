#!/usr/bin/env python3
"""
make_branding.py - regenerates the rl26-revamp-branding mod files from
resources/rl26-revamp/rl26-revamped-logo.png and a fresh extraction of the
Noesis XAML bundle (entry 57662).

  - RLL26_Logo / RLL26_Logo_White (resourcedictionary.xaml) get the revamp
    logo, traced to vector paths with potracer. The "26" keeps
    Fill=RLGreen, which is now the revamp blue.
  - colours_bigant.xaml: RLGreen / RLGreen10 / RLDarkGreen -> revamp blue.
  - Hard-coded brand greens (menu background title gradient, generic + NRL
    screen wipes) -> blue.
  - The new logo is ~2.8:1 instead of ~6.3:1, so every place that sized the
    old logo by width alone gets an explicit height.
  - textures/322eabdb8b82c1bf_rll_logo.dds (entry hash): the screen-wipe centre logo bitmap
    (3784x600, logo centred, uncompressed premultiplied BGRA).
  - Lua copies of the green (script bundle 39959, from decompiled/src):
    uicolours.rlgreencol (menu background stripes) and the native skin
    colour RLLMainColour (focus outlines).
  - The start screen (menubackgroundview.xaml LogoRSV + visual states):
    see title_screen.py, which also installs its three new textures.

build.py skips *.py, so this script lives alongside the mod files.

Usage (from the repo root; needs `pip install potracer`):
    python tools\\extract_m3mp.py --entry xamls --out <tmp>
    python mods\\rl26-revamp-branding\\make_branding.py --extracted <tmp>
"""

import argparse
import os
import re
import sys

import numpy as np
import potrace
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
MOD_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import club_icons  # noqa: E402

sys.path.insert(0, MOD_DIR)
import title_screen  # noqa: E402

LOGO = os.path.join(ROOT, "resources", "rl26-revamp", "rl26-revamped-logo.png")
# any shipped-style uncompressed BGRA DDS works as the header template
DDS_HEADER_TEMPLATE = os.path.join(ROOT, "mods", "nrl-broadcast-scoreboard", "textures",
                                   "31e185be65e0bcf5_hud_score_nrl_broncos.dds")
WIPE_LOGO_SIZE = (3784, 600)

BLUE = "1E6FD9"       # the "26" in the revamp logo
DARK_BLUE = "0C2E59"  # same value ratio as stock RLDarkGreen (#095A24) to RLGreen (#24DB61)

# (file, [(old, new, expected_count)])
COLOUR_EDITS = [
    ("resources/colours_bigant.xaml", [
        ('<Color x:Key="RLGreenCol">#FF24DB61</Color>', f'<Color x:Key="RLGreenCol">#FF{BLUE}</Color>', 1),
        ('<Color x:Key="RLGreen10Col">#1A24DB61</Color>', f'<Color x:Key="RLGreen10Col">#1A{BLUE}</Color>', 1),
        ('<Color x:Key="RLDarkGreenCol">#FF095A24</Color>', f'<Color x:Key="RLDarkGreenCol">#FF{DARK_BLUE}</Color>', 1),
    ]),
    ("views/background/menubackgroundview.xaml", [
        ('"#153E31"', '"#0F2A4A"', 2),
        ('"#068D33"', '"#0A4FA8"', 2),
        ('"#26FF55"', '"#4C9BFF"', 1),
    ]),
    ("resources/stylethemes/screenwipes/rl26_wipe_generic.xaml", [
        ("#17E95D", f"#{BLUE}", 1),
    ]),
    ("resources/stylethemes/screenwipes/rl26_wipe_nrl.xaml", [
        ("#17E95D", f"#{BLUE}", 1),
        ("#0D3C1D", f"#{DARK_BLUE}", 1),
    ]),
]

# (file, regex, replacement, expected_count) - give width-only logo slots a height
SIZE_EDITS = [
    # (the title screen logo panel is rebuilt by title_screen.py)
    # menu corner logo (was 250x40 at y=100): 72 tall, raised to y=70 so it
    # clears the home screen featured slider (top edge ~y=158)
    ("views/background/menubackgroundview.xaml",
     r'(<RowDefinition Height=")100("\s*/>\s*<RowDefinition />\s*</Grid.RowDefinitions>\s*'
     r'<ContentPresenter ContentTemplate="\{StaticResource RLL26_Logo\}"\s+Width="250"\s+Height=")40"',
     r'\g<1>70\g<2>72"', 1),
    # bunker decision banner (was 525 wide, ~83 tall): Height="150" now lives in
    # bunker-broadcast-decision's copy of views/hud/rugby/pabunkercontrol.xaml, which
    # owns that file (two mods can't override one file)
    # dynasty card watermarks (130/150 wide, ~21-24 tall); [^<>]* keeps Width
    # inside the tag that directly wraps the logo
    ("resources/cards/dynastycard.xaml",
     r'(Width="1[35]0")([^<>]*>\s*<ContentPresenter ContentTemplate="\{StaticResource RLL26_Logo_White\}" />)',
     r'\1 Height="30"\2', 22),
]


# Chroma-key backdrop: a solid blue / green rectangle over the whole menu
# background (the 3D player model draws on top), switched on by
# storm-celebration-viewer's Backdrop option for thumbnail captures. Off by
# default; NVMBackground.setChromaKey({r, g, b}) shows it, setChromaKey(nil)
# hides it.
CHROMA_KEY_PROPS = "\t\tChromaKeyVisible = ns.Bool,\n\t\tChromaKeyColour = ns.Color,\n"
CHROMA_KEY_LUA = (
    "-- rl26-revamp-branding: chroma-key backdrop (blue / green screen) over the\n"
    "-- whole menu background, for storm-celebration-viewer's thumbnails.\n"
    "-- arg_ck_1 = {r, g, b} (0-255), or nil to hide it.\n"
    "function NVMBackground.setChromaKey(arg_ck_0, arg_ck_1)\n"
    "\tif arg_ck_1 then\n"
    "\t\targ_ck_0.ChromaKeyColour = native.NsColor(arg_ck_1[1], arg_ck_1[2], arg_ck_1[3], 255)\n"
    "\tend\n\n"
    "\targ_ck_0.ChromaKeyVisible = arg_ck_1 ~= nil\n"
    "end\n\n")
CHROMA_KEY_XAML = """        <!--rl26-revamp-branding: chroma-key backdrop (blue / green screen) for
            storm-celebration-viewer's thumbnails. Covers the whole menu background;
            the 3D player model draws over it. Hidden unless ChromaKeyVisible.-->
        <Rectangle x:Name="ChromaKeyBackdrop"
                   Grid.RowSpan="99"
                   Grid.ColumnSpan="99"
                   IsHitTestVisible="False">
            <Rectangle.Fill>
                <SolidColorBrush Color="{Binding ChromaKeyColour}" />
            </Rectangle.Fill>
            <Rectangle.Style>
                <Style TargetType="Rectangle">
                    <Setter Property="Visibility"
                            Value="Collapsed" />
                    <Style.Triggers>
                        <DataTrigger Binding="{Binding ChromaKeyVisible}"
                                     Value="True">
                            <Setter Property="Visibility"
                                    Value="Visible" />
                        </DataTrigger>
                    </Style.Triggers>
                </Style>
            </Rectangle.Style>
        </Rectangle>

"""

# Lua-side copies of the brand green (script bundle 39959, sources from
# decompiled/src): (file, old, new, expected_count)
LUA_EDITS = [
    # MainColour of the menu background (the neon stripes) and the dynasty background
    ("uicore/uicolours.lua",
     "rlgreencol = var_0_0(0.1411764705882353, 0.8588235294117647, 0.3803921568627451, 1)",
     "rlgreencol = var_0_0(0.11764705882352941, 0.43529411764705883, 0.8509803921568627, 1)", 1),
    # native SkinColours.RLLMainColour: list/button focus outlines, text and
    # date inputs, replay HUD
    ("intermediatelua/skin/colour_map.lua",
     "RLLMainColour = {\n\t36,\n\t218,\n\t97,\n\t255\n}",
     "RLLMainColour = {\n\t30,\n\t111,\n\t217,\n\t255\n}", 1),
    # start screen art: bindable texture properties + their loader (title_screen.py)
    ("app/noesis/homescreen/nvm_background.lua",
     "\t\tLightMode = ns.Bool\n\t}\n}",
     "\t\tLightMode = ns.Bool,\n" + CHROMA_KEY_PROPS + title_screen.lua_title_art()[0].rstrip(",\n") + "\n\t}\n}", 1),
    ("app/noesis/homescreen/nvm_background.lua",
     "function NVMBackground.setVisualKey(",
     title_screen.lua_title_art()[1] + "function NVMBackground.setVisualKey(", 1),
    # chroma-key backdrop (blue / green screen), see CHROMA_KEY_XAML
    ("app/noesis/homescreen/nvm_background.lua",
     "function NVMBackground.setBackgroundColour(",
     CHROMA_KEY_LUA + "function NVMBackground.setBackgroundColour(", 1),
]


def fmt(v):
    return f"{v:.1f}".rstrip("0").rstrip(".")


def trace(mask):
    """EvenOdd path data for a boolean mask (potracer traces False pixels)."""
    plist = potrace.Bitmap(~mask).trace(turdsize=4, alphamax=1.0, opticurve=True, opttolerance=0.2)
    parts = []
    for curve in plist:
        sp = curve.start_point
        d = [f"M{fmt(sp.x)} {fmt(sp.y)}"]
        for seg in curve.segments:
            if seg.is_corner:
                d.append(f"L{fmt(seg.c.x)} {fmt(seg.c.y)}L{fmt(seg.end_point.x)} {fmt(seg.end_point.y)}")
            else:
                d.append(f"C{fmt(seg.c1.x)} {fmt(seg.c1.y)} {fmt(seg.c2.x)} {fmt(seg.c2.y)} "
                         f"{fmt(seg.end_point.x)} {fmt(seg.end_point.y)}")
        parts.append("".join(d) + "Z")
    return "F0 " + "".join(parts)


def logo_paths():
    px = np.asarray(Image.open(LOGO).convert("RGBA")).astype(int)
    opaque = px[..., 3] >= 128
    blue = opaque & (px[..., 2] - px[..., 0] > 80)
    return trace(opaque & ~blue), trace(blue)


def logo_template(key, white, blue, blue_fill):
    # the transparent full-canvas rectangle keeps the PNG's own padding so
    # both paths share one coordinate space inside the Viewbox
    h, w = Image.open(LOGO).size[::-1]
    return (f'<DataTemplate x:Key="{key}">\n'
            f'        <Viewbox>\n'
            f'            <Grid Width="{w}" Height="{h}">\n'
            f'                <Path Data="{white}"\n'
            f'                      Fill="White" />\n'
            f'                <Path Data="{blue}"\n'
            f'                      Fill="{blue_fill}" />\n'
            f'            </Grid>\n'
            f'        </Viewbox>\n'
            f'    </DataTemplate>')


class XamlFiles:
    """Read-modify-write of extracted XAML, keeping BOM and line endings."""

    def __init__(self, extracted):
        self.extracted = extracted
        self.texts = {}

    def get(self, rel):
        if rel not in self.texts:
            with open(os.path.join(self.extracted, rel), "rb") as fh:
                self.texts[rel] = fh.read().decode("utf-8")
        return self.texts[rel]

    def set(self, rel, text):
        self.texts[rel] = text

    def write(self, out_root):
        for rel, text in self.texts.items():
            path = os.path.join(out_root, rel)
            os.makedirs(os.path.dirname(path), exist_ok=True)
            with open(path, "wb") as fh:
                fh.write(text.encode("utf-8"))
            print(f"  wrote {os.path.relpath(path, ROOT)}")


def find_workspace(extracted):
    for cand in (os.path.join(extracted, "noesis", "workspace"), os.path.join(extracted, "workspace"), extracted):
        if os.path.isfile(os.path.join(cand, "resources", "colours_bigant.xaml")):
            return cand
    raise SystemExit(f"no noesis workspace under {extracted}")


def build_xaml(extracted):
    files = XamlFiles(find_workspace(extracted))

    for rel, edits in COLOUR_EDITS:
        text = files.get(rel)
        for old, new, count in edits:
            if text.count(old) != count:
                raise SystemExit(f"{rel}: expected {count}x {old!r}, found {text.count(old)}")
            text = text.replace(old, new)
        files.set(rel, text)

    for rel, pattern, repl, count in SIZE_EDITS:
        text, n = re.subn(pattern, repl, files.get(rel))
        if n != count:
            raise SystemExit(f"{rel}: expected {count} matches of {pattern!r}, found {n}")
        files.set(rel, text)

    rel = "views/background/menubackgroundview.xaml"
    text = title_screen.apply_xaml(files.get(rel))
    # chroma-key backdrop: last child of RootGrid, so it covers everything in the view
    nl = "\r\n" if "\r\n" in text else "\n"
    anchor = nl + "        <!--VISUAL STATES-->"
    if text.count(anchor) != 1:
        raise SystemExit(f"{rel}: expected one VISUAL STATES comment, found {text.count(anchor)}")
    text = text.replace(anchor, nl + CHROMA_KEY_XAML.replace("\n", nl).rstrip(nl) + nl + anchor, 1)
    files.set(rel, text)

    white, blue = logo_paths()
    rel = "resources/resourcedictionary.xaml"
    text = files.get(rel)
    for key, blue_fill in (("RLL26_Logo", "{StaticResource RLGreen}"), ("RLL26_Logo_White", "White")):
        pattern = r'<DataTemplate x:Key="' + key + r'">.*?</DataTemplate>'
        text, n = re.subn(pattern, lambda _m: logo_template(key, white, blue, blue_fill), text, flags=re.S)
        if n != 1:
            raise SystemExit(f"{rel}: expected one {key} DataTemplate, found {n}")
    files.set(rel, text)

    files.write(os.path.join(MOD_DIR, "noesis", "workspace"))


def build_lua():
    src_root = os.path.join(ROOT, "decompiled", "src", "script-game")
    out_root = os.path.join(MOD_DIR, "src", "script-game")
    for rel in dict.fromkeys(e[0] for e in LUA_EDITS):  # every edit to a file, then write it once
        with open(os.path.join(src_root, rel), "rb") as fh:
            raw = fh.read().decode("utf-8")
        crlf = "\r\n" in raw
        text = raw.replace("\r\n", "\n")
        for _rel, old, new, count in (e for e in LUA_EDITS if e[0] == rel):
            if text.count(old) != count:
                raise SystemExit(f"{rel}: expected {count}x {old!r}, found {text.count(old)}")
            text = text.replace(old, new)
        if crlf:
            text = text.replace("\n", "\r\n")
        path = os.path.join(out_root, rel)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "wb") as fh:
            fh.write(text.encode("utf-8"))
        print(f"  wrote {os.path.relpath(path, ROOT)}")


def build_wipe_texture():
    w, h = WIPE_LOGO_SIZE
    logo = Image.open(LOGO).convert("RGBA").convert("RGBa")  # resample premultiplied: no dark fringes
    scale = min(w / logo.width, h / logo.height)
    logo = logo.resize((round(logo.width * scale), round(logo.height * scale)), Image.LANCZOS)
    canvas = Image.new("RGBa", (w, h))
    canvas.paste(logo, ((w - logo.width) // 2, (h - logo.height) // 2))
    # premultiplied channels as stored bytes, the same as club_icons.premultiply output
    img = Image.frombytes("RGBA", canvas.size, canvas.tobytes())
    with open(DDS_HEADER_TEMPLATE, "rb") as fh:
        header = fh.read(128)
    out = os.path.join(MOD_DIR, "textures", "322eabdb8b82c1bf_rll_logo.dds")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    with open(out, "wb") as fh:
        fh.write(club_icons.make_dds(img, header))
    print(f"  wrote {os.path.relpath(out, ROOT)}")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--extracted", required=True, help="fresh extract_m3mp.py --entry xamls output dir")
    args = ap.parse_args()
    build_xaml(args.extracted)
    build_lua()
    build_wipe_texture()


if __name__ == "__main__":
    main()
