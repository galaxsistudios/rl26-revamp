#!/usr/bin/env python3
"""
title_screen.py - the RL26 Revamped start screen ("press start"), part of
rl26-revamp-branding.

Layout (1080p units, the space baResolutionScaledViewbox scales from):
Herbie (resources/rl26-revamp/main-menu-herbie.png) bottom-left, Jesse
(main-menu-jesse.png) bottom-right, each with two drifting smoke layers
(resources/smoke.png, one white, one revamp blue) behind them, a full-screen
stadium image (resources/rl26-revamp/bg.png) behind all of that, and the revamp
logo centred between them with "PRESS |ACCEPT| TO CONTINUE" under it
(|ACCEPT| is the accept glyph for the active pad / keyboard).

The players and smoke slide/fade in when VisualStateKey becomes "title"
(TitleIntroSB), which skip-intro-to-main-menu's waitforsignin_state.lua sets
as the splash screens are torn down. SignOn only hides them: the view enters
SignOn on Loaded, behind the splash. Every other state (Main, Data,
TeamSelect, ...) slides them out sideways while the home screen builds its
menu. All animations target the named viewboxes (Opacity, Margin), like the
stock LogoRSV / RightLinesSP ones.

The images are NEW Noesis textures, appended to the blobset index
(tools/add_entries.py, undo with its remove-all):
    noesis/workspace/images/background/rl26revamp_title_{herbie,jesse,smoke,smoke_blue,bg}.texture
which XAML in views/background/ loads as ../../Images/Background/<name>.png.

make_branding.py calls apply_xaml() on menubackgroundview.xaml.

Usage (from the repo root, game closed for --add-art):
    python mods\\rl26-revamp-branding\\title_screen.py --preview <out.png>
    python mods\\rl26-revamp-branding\\title_screen.py --add-art [--confirm]
"""

import argparse
import os
import re
import sys

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, "tools"))

ART_DIR = os.path.join(ROOT, "resources", "rl26-revamp")
LOGO = os.path.join(ART_DIR, "rl26-revamped-logo.png")
TEXTURE_DIR = "noesis/workspace/images/background"
XAML_IMAGE_DIR = "../../Images/Background"

# name -> (source image, texture height). Players are cropped to their opaque
# bounds first. Textures are ~1.35x their 1080p display size so 1440p stays sharp.
ART = {
    "herbie": (os.path.join(ART_DIR, "main-menu-herbie.png"), 1270),
    "jesse": (os.path.join(ART_DIR, "main-menu-jesse.png"), 1160),
    "smoke": (os.path.join(ROOT, "resources", "smoke.png"), 768),
    "smoke_blue": (os.path.join(ROOT, "resources", "smoke.png"), 768),
    # full-screen backdrop behind the smoke; its oval edge is already faded to
    # transparent, so it's shown whole (Stretch Uniform) over the menu background
    "bg": (os.path.join(ART_DIR, "bg.png"), 1080),
}
BG_OPACITY = 1.0
# The backdrop always fills the screen height: a negative side margin widens
# its layout slot past the screen, so the uniform scale is set by height alone
# (the sides crop on screens narrower than the image, ~1.89:1).
BG_SIDE_BLEED = 2000
# Drop shadow under the logo and the "press start" prompt.
LOGO_SHADOW = dict(BlurRadius=28, ShadowDepth=6, Direction=270, Opacity=0.85)

BLUE = "#1E6FD9"
SMOKE_TINT = {None: "smoke", BLUE: "smoke_blue"}  # smoke layer tint -> texture

# Each side is a Canvas anchored to a bottom corner of the screen.
# image: (height, left, top) inside the canvas; left < 0 hangs off the edge.
# smoke: (tint, size, left, top, opacity, seconds) - tint None = white.
SIDES = {
    # images hang ~30 px below the screen so the idle bob never shows their cut edge
    "Herbie": dict(align="Left", width=700, image=(960, -80, 150), slide=-1,
                   float=(14, 12, 1.025, (6.5, 5.0, 7.5)),
                   smoke=[(BLUE, 1200, -420, 260, 0.85, 11),
                          (None, 1000, 60, 20, 0.70, 8)]),
    "Jesse": dict(align="Right", width=800, image=(880, -140, 230), slide=1,
                  float=(12, 14, 1.03, (7.0, 5.5, 8.5)),
                  smoke=[(BLUE, 1200, 60, 280, 0.85, 12),
                         (None, 1000, -330, 60, 0.70, 9)]),
}
# float: (sway px, bob px, breathe scale, (sway s, bob s, breathe s)) - the idle
# drift of each player, eased and auto-reversed, scaled from their feet
LOGO_HEIGHT = 240
PROMPT_SIZE = 42
SLIDE_IN = 380    # screen px the players travel in
SLIDE_OUT = 1400  # screen px they travel out when the start screen is left


def texture_path(name):
    return f"{TEXTURE_DIR}/rl26revamp_title_{name}.texture"


def binding_name(name):
    """NVMBackground property holding the texture: smoke_blue -> TitleSmokeBlueImage."""
    return "Title" + "".join(p.title() for p in name.split("_")) + "Image"


def xaml_image(name):
    # Noesis can't resolve an appended texture from a static Source URI (first
    # two in-game tests: nothing drew). Like stock's career logos, Lua loads
    # it and binds a CNoesisTextureSource (nvm_background.lua, LUA_EDITS).
    return f"{{Binding {binding_name(name)}}}"


def lua_title_art():
    """NVMBackground additions (make_branding LUA_EDITS on nvm_background.lua)."""
    props = "".join(f"\t\t{binding_name(n)} = ns.typeOf(native.CNoesisTextureSource),\n" for n in ART)
    paths = "".join(f'\t{binding_name(n)} = "{texture_path(n)}",\n' for n in ART)
    methods = (
        "-- rl26-revamp-branding: start screen art (title_screen.py). Noesis can't\n"
        "-- load these appended textures from a XAML Source URI, so they're loaded\n"
        "-- here and bound, like the career club logos. Called by skip-intro's\n"
        "-- waitforsignin_state.lua.\n"
        "NVMBackgroundTitleArt = {\n" + paths + "}\n\n"
        "function NVMBackground.loadTitleArt(arg_ta_0, arg_ta_1)\n"
        "\tif arg_ta_0.titleArtTextures then\n"
        "\t\treturn\n"
        "\tend\n\n"
        "\tlocal var_ta_0 = arg_ta_1:getTextureManager()\n\n"
        "\targ_ta_0.titleArtTextures = {}\n\n"
        "\tfor iter_ta_0, iter_ta_1 in pairs(NVMBackgroundTitleArt) do\n"
        "\t\targ_ta_0.titleArtTextures[iter_ta_0] = var_ta_0:load(iter_ta_1)\n"
        "\tend\n"
        "end\n\n"
        "-- Binds each texture once it has loaded; true when all are bound.\n"
        "function NVMBackground.updateTitleArt(arg_tu_0)\n"
        "\tlocal var_tu_0 = arg_tu_0.titleArtTextures\n\n"
        "\tif not var_tu_0 then\n"
        "\t\treturn false\n"
        "\tend\n\n"
        "\tlocal var_tu_1 = true\n\n"
        "\tfor iter_tu_0, iter_tu_1 in pairs(var_tu_0) do\n"
        "\t\tif iter_tu_1:isLoaded() then\n"
        "\t\t\targ_tu_0[iter_tu_0] = native.CNoesisTextureSource(iter_tu_1)\n\n"
        "\t\t\titer_tu_1:unload()\n\n"
        "\t\t\tvar_tu_0[iter_tu_0] = nil\n"
        "\t\telse\n"
        "\t\t\tvar_tu_1 = false\n"
        "\t\tend\n"
        "\tend\n\n"
        "\treturn var_tu_1\n"
        "end\n\n")
    return props, methods


def load_art(name):
    """Straight-alpha RGBA image at texture resolution."""
    src, height = ART[name]
    img = Image.open(src).convert("RGBA")
    img = img.crop(img.getchannel("A").getbbox())
    width = round(img.width * height / img.height)
    # resample premultiplied so edges don't pick up dark fringes
    img = img.convert("RGBa").resize((width, height), Image.LANCZOS).convert("RGBA")
    if name.startswith("smoke"):
        # smoke.png's alpha doesn't reach 0 at its border (square edges on
        # screen): fade it out radially, fully clear before the edge
        import numpy as np
        yy, xx = np.mgrid[0:height, 0:width]
        r = np.hypot((xx + 0.5) / width - 0.5, (yy + 0.5) / height - 0.5) * 2
        t = np.clip((0.95 - r) / 0.6, 0, 1)
        a = np.asarray(img.getchannel("A"), dtype=np.float32) * (t * t * (3 - 2 * t))
        img.putalpha(Image.fromarray(a.round().astype(np.uint8)))
        if name == "smoke_blue":
            # revamp blue, keeping a little of the smoke's own shading
            rgb = np.asarray(img.convert("RGB"), dtype=np.float32)
            blue = np.array([int(BLUE[i:i + 2], 16) for i in (1, 3, 5)], dtype=np.float32)
            tinted = (blue * 0.75 + rgb * 0.25).clip(0, 255).astype(np.uint8)
            img = Image.merge("RGBA", (*Image.fromarray(tinted).split(), img.getchannel("A")))
    return img


def image_aspect(name):
    img = load_art(name) if not name.startswith("smoke") else None
    return img.width / img.height if img else 1.0


# ----------------------------------------------------------------- XAML

def _smoke_xaml(name, tint, size, left, top, opacity, seconds, ind):
    """One drifting smoke puff (the tint is baked into its texture)."""
    tag = "Image"
    fill = f'Source="{xaml_image(SMOKE_TINT[tint])}"'
    mask = ""
    drift = 30 + size // 25
    tp = "(UIElement.RenderTransform).(TransformGroup.Children)"
    return (
        f'{ind}<{tag} x:Name="{name}" {fill} Width="{size}" Height="{size}" Canvas.Left="{left}" Canvas.Top="{top}"\n'
        f'{ind}       Opacity="{opacity}" RenderTransformOrigin="0.5,0.5">\n'
        f'{mask}'
        f'{ind}    <{tag}.RenderTransform>\n'
        f'{ind}        <TransformGroup>\n'
        f'{ind}            <ScaleTransform />\n'
        f'{ind}            <RotateTransform />\n'
        f'{ind}            <TranslateTransform />\n'
        f'{ind}        </TransformGroup>\n'
        f'{ind}    </{tag}.RenderTransform>\n'
        f'{ind}    <{tag}.Triggers>\n'
        f'{ind}        <EventTrigger RoutedEvent="Loaded">\n'
        f'{ind}            <BeginStoryboard>\n'
        f'{ind}                <Storyboard RepeatBehavior="Forever" AutoReverse="True">\n'
        f'{ind}                    <DoubleAnimation Storyboard.TargetProperty="{tp}[0].(ScaleTransform.ScaleX)" From="1" To="1.18" Duration="0:0:{seconds}" />\n'
        f'{ind}                    <DoubleAnimation Storyboard.TargetProperty="{tp}[0].(ScaleTransform.ScaleY)" From="1" To="1.12" Duration="0:0:{seconds}" />\n'
        f'{ind}                    <DoubleAnimation Storyboard.TargetProperty="{tp}[1].(RotateTransform.Angle)" From="-4" To="9" Duration="0:0:{seconds}" />\n'
        f'{ind}                    <DoubleAnimation Storyboard.TargetProperty="{tp}[2].(TranslateTransform.X)" From="0" To="{drift}" Duration="0:0:{seconds - 2}" />\n'
        f'{ind}                    <DoubleAnimation Storyboard.TargetProperty="{tp}[2].(TranslateTransform.Y)" From="0" To="-{drift}" Duration="0:0:{seconds + 1}" />\n'
        f'{ind}                    <DoubleAnimation Storyboard.TargetProperty="(UIElement.Opacity)" From="{opacity}" To="{round(opacity * 0.6, 2)}" Duration="0:0:{seconds - 3}" />\n'
        f'{ind}                </Storyboard>\n'
        f'{ind}            </BeginStoryboard>\n'
        f'{ind}        </EventTrigger>\n'
        f'{ind}    </{tag}.Triggers>\n'
        f'{ind}</{tag}>\n')


def _side_xaml(side, cfg, ind):
    height, left, top = cfg["image"]
    width = round(height * image_aspect(side.lower()))
    smoke = "".join(_smoke_xaml(f"Title{side}Smoke{i}", *s, ind + "        ")
                    for i, s in enumerate(cfg["smoke"]))
    return (
        f'{ind}<!--RL26 Revamp title screen: {side}-->\n'
        f'{ind}<controls:baResolutionScaledViewbox x:Name="Title{side}RSV"\n'
        f'{ind}                                    Grid.RowSpan="2"\n'
        f'{ind}                                    HorizontalAlignment="{cfg["align"]}"\n'
        f'{ind}                                    VerticalAlignment="Bottom"\n'
        f'{ind}                                    Margin="{_margin(cfg, SLIDE_IN)}"\n'
        f'{ind}                                    Opacity="0"\n'
        f'{ind}                                    IsHitTestVisible="False">\n'
        f'{ind}    <Canvas Width="{cfg["width"]}" Height="1080">\n'
        f'{smoke}'
        f'{ind}        <Image Source="{xaml_image(side.lower())}" Width="{width}" Height="{height}"\n'
        f'{ind}               Canvas.Left="{left}" Canvas.Top="{top}" RenderTransformOrigin="0.5,1">\n'
        f'{_float_xaml(cfg["float"], ind + "            ")}'
        f'{ind}        </Image>\n'
        f'{ind}    </Canvas>\n'
        f'{ind}</controls:baResolutionScaledViewbox>\n')


def _float_xaml(spec, ind):
    """Idle drift for a player Image: sway, bob and breathe on separate eased,
    auto-reversed loops (different lengths, so the motion never repeats exactly)."""
    sway, bob, scale, (t_sway, t_bob, t_scale) = spec
    tp = "(UIElement.RenderTransform).(TransformGroup.Children)"

    def loop(prop, frm, to, secs):
        return (f'{ind}                <DoubleAnimation Storyboard.TargetProperty="{tp}{prop}" From="{frm}" To="{to}"\n'
                f'{ind}                                 Duration="0:0:{secs}" AutoReverse="True" RepeatBehavior="Forever">\n'
                f'{ind}                    <DoubleAnimation.EasingFunction>\n'
                f'{ind}                        <SineEase EasingMode="EaseInOut" />\n'
                f'{ind}                    </DoubleAnimation.EasingFunction>\n'
                f'{ind}                </DoubleAnimation>\n')

    return (
        f'{ind}<Image.RenderTransform>\n'
        f'{ind}    <TransformGroup>\n'
        f'{ind}        <ScaleTransform />\n'
        f'{ind}        <TranslateTransform />\n'
        f'{ind}    </TransformGroup>\n'
        f'{ind}</Image.RenderTransform>\n'
        f'{ind}<Image.Triggers>\n'
        f'{ind}    <EventTrigger RoutedEvent="Loaded">\n'
        f'{ind}        <BeginStoryboard>\n'
        f'{ind}            <Storyboard>\n'
        + loop("[1].(TranslateTransform.X)", -sway / 2, sway / 2, t_sway)
        + loop("[1].(TranslateTransform.Y)", 0, -bob, t_bob)
        + loop("[0].(ScaleTransform.ScaleX)", 1, scale, t_scale)
        + loop("[0].(ScaleTransform.ScaleY)", 1, scale, t_scale)
        + f'{ind}            </Storyboard>\n'
        f'{ind}        </BeginStoryboard>\n'
        f'{ind}    </EventTrigger>\n'
        f'{ind}</Image.Triggers>\n')


def _bg_xaml(ind):
    """Screen-height stadium backdrop, behind both smoke stacks and players."""
    width = round(1080 * image_aspect("bg"))
    return (
        f'{ind}<!--RL26 Revamp title screen: backdrop behind the smoke-->\n'
        f'{ind}<Viewbox x:Name="TitleBgVB"\n'
        f'{ind}         Grid.RowSpan="2"\n'
        f'{ind}         Stretch="Uniform"\n'
        f'{ind}         HorizontalAlignment="Center"\n'
        f'{ind}         VerticalAlignment="Stretch"\n'
        f'{ind}         Margin="-{BG_SIDE_BLEED},0"\n'
        f'{ind}         Opacity="0"\n'
        f'{ind}         IsHitTestVisible="False">\n'
        f'{ind}    <Image Source="{xaml_image("bg")}" Width="{width}" Height="1080" />\n'
        f'{ind}</Viewbox>\n')


def _shadow_attrs():
    return " ".join(f'{key}="{value}"' for key, value in LOGO_SHADOW.items())


def _logo_xaml(ind):
    return (
        f'{ind}<controls:baResolutionScaledViewbox x:Name="LogoRSV">\n'
        f'{ind}\n'
        f'{ind}    <StackPanel VerticalAlignment="Center"\n'
        f'{ind}                HorizontalAlignment="Center">\n'
        f'{ind}\n'
        f'{ind}        <ContentPresenter ContentTemplate="{{StaticResource RLL26_Logo}}" Height="{LOGO_HEIGHT}">\n'
        f'{ind}            <ContentPresenter.Effect>\n'
        f'{ind}                <DropShadowEffect Color="Black" {_shadow_attrs()} />\n'
        f'{ind}            </ContentPresenter.Effect>\n'
        f'{ind}        </ContentPresenter>\n'
        f'{ind}\n'
        f'{ind}        <controls:paTextBlock x:Name="TitlePrompt"\n'
        f'{ind}                              FormattedText="PRESS |ACCEPT| TO CONTINUE"\n'
        f'{ind}                              FontSize="{PROMPT_SIZE}"\n'
        f'{ind}                              GlowyTooltipEnabled="True"\n'
        f'{ind}                              Style="{{StaticResource Display_XL}}"\n'
        f'{ind}                              HorizontalAlignment="Center"\n'
        f'{ind}                              Margin="0,50,0,0">\n'
        f'{ind}            <controls:paTextBlock.Effect>\n'
        f'{ind}                <DropShadowEffect Color="Black" {_shadow_attrs()} />\n'
        f'{ind}            </controls:paTextBlock.Effect>\n'
        f'{ind}            <controls:paTextBlock.Triggers>\n'
        f'{ind}                <EventTrigger RoutedEvent="Loaded">\n'
        f'{ind}                    <BeginStoryboard>\n'
        f'{ind}                        <Storyboard RepeatBehavior="Forever" AutoReverse="True">\n'
        f'{ind}                            <DoubleAnimation Storyboard.TargetProperty="(UIElement.Opacity)" From="1" To="0.45" Duration="0:0:1.1" BeginTime="0:0:1.2">\n'
        f'{ind}                                <DoubleAnimation.EasingFunction>\n'
        f'{ind}                                    <SineEase EasingMode="EaseInOut" />\n'
        f'{ind}                                </DoubleAnimation.EasingFunction>\n'
        f'{ind}                            </DoubleAnimation>\n'
        f'{ind}                        </Storyboard>\n'
        f'{ind}                    </BeginStoryboard>\n'
        f'{ind}                </EventTrigger>\n'
        f'{ind}            </controls:paTextBlock.Triggers>\n'
        f'{ind}        </controls:paTextBlock>\n'
        f'{ind}    </StackPanel>\n'
        f'{ind}</controls:baResolutionScaledViewbox>\n')


def _key(time, value, ease=None, ind=""):
    if not ease:
        return f'{ind}    <EasingDoubleKeyFrame KeyTime="{time}" Value="{value}" />\n'
    return (f'{ind}    <EasingDoubleKeyFrame KeyTime="{time}" Value="{value}">\n'
            f'{ind}        <EasingDoubleKeyFrame.EasingFunction>\n'
            f'{ind}            <{ease[0]} EasingMode="{ease[1]}" />\n'
            f'{ind}        </EasingDoubleKeyFrame.EasingFunction>\n'
            f'{ind}    </EasingDoubleKeyFrame>\n')


def _anim(target, prop, keys, ind):
    return (f'{ind}<DoubleAnimationUsingKeyFrames Storyboard.TargetName="{target}"\n'
            f'{ind}                               Storyboard.TargetProperty="{prop}">\n'
            + "".join(_key(*k, ind=ind) for k in keys)
            + f'{ind}</DoubleAnimationUsingKeyFrames>\n')


OPACITY = "(UIElement.Opacity)"


def _margin(cfg, offset):
    """Margin that pushes a side `offset` screen px out past its own edge."""
    return f"-{offset},0,0,0" if cfg["align"] == "Left" else f"0,0,-{offset},0"


def _margin_anim(target, keys, ind):
    """Like _anim, for (FrameworkElement.Margin); keys = (time, margin, ease?)."""
    out = (f'{ind}<ThicknessAnimationUsingKeyFrames Storyboard.TargetName="{target}"\n'
           f'{ind}                                  Storyboard.TargetProperty="(FrameworkElement.Margin)">\n')
    for time, value, *ease in keys:
        if not ease:
            out += f'{ind}    <EasingThicknessKeyFrame KeyTime="{time}" Value="{value}" />\n'
        else:
            out += (f'{ind}    <EasingThicknessKeyFrame KeyTime="{time}" Value="{value}">\n'
                    f'{ind}        <EasingThicknessKeyFrame.EasingFunction>\n'
                    f'{ind}            <{ease[0][0]} EasingMode="{ease[0][1]}" />\n'
                    f'{ind}        </EasingThicknessKeyFrame.EasingFunction>\n'
                    f'{ind}    </EasingThicknessKeyFrame>\n')
    return out + f'{ind}</ThicknessAnimationUsingKeyFrames>\n'


# The intro is a resource storyboard played by VisualStateKey "title", which
# waitforsignin_state.lua (skip-intro-to-main-menu) sets once the splash
# screens are gone. SignOn itself only resets the players: the view loads
# (and enters SignOn) behind the splash, and nothing in the game ever sets
# "signon", so a SignOn slide-in would never be seen.
INTRO_KEY = "title"


def _intro_storyboard(ind):
    """Players slide in from their edge, Jesse a beat after Herbie."""
    out = f'{ind}<!--RL26 Revamp title screen: players in (VisualStateKey "{INTRO_KEY}")-->\n'
    out += f'{ind}<Storyboard x:Key="TitleIntroSB">\n'
    out += _anim("TitleBgVB", OPACITY, [
        ("00:00:00", 0), ("00:00:00.6", BG_OPACITY, ("SineEase", "EaseOut"))], ind + "    ")
    for i, (side, cfg) in enumerate(SIDES.items()):
        start = 0.15 + 0.15 * i
        out += _anim(f"Title{side}RSV", OPACITY, [
            ("00:00:00", 0), (f"00:00:{start:.2f}", 0), (f"00:00:{start + 0.6:.2f}", 1)], ind + "    ")
        out += _margin_anim(f"Title{side}RSV", [
            ("00:00:00", _margin(cfg, SLIDE_IN)), (f"00:00:{start:.2f}", _margin(cfg, SLIDE_IN)),
            (f"00:00:{start + 0.9:.2f}", "0", ("QuinticEase", "EaseOut"))], ind + "    ")
    return out + f'{ind}</Storyboard>\n'


def _reset_xaml(ind):
    """SignOn: players hidden and pushed out, ready for the intro."""
    out = f"{ind}<!--RL26 Revamp title screen: players reset (the intro is TitleIntroSB)-->\n"
    out += _anim("TitleBgVB", OPACITY, [("00:00:00", 0)], ind)
    for side, cfg in SIDES.items():
        out += _anim(f"Title{side}RSV", OPACITY, [("00:00:00", 0)], ind)
        out += _margin_anim(f"Title{side}RSV", [("00:00:00", _margin(cfg, SLIDE_IN))], ind)
    # the background's bottom-right stripes sit behind Jesse: hidden on the start screen
    out += _anim("RightLinesGrid", OPACITY, [("00:00:00", 0)], ind)
    return out


def _outro_xaml(ind):
    """Any other state: players pushed out sideways, fading as they go."""
    out = f"{ind}<!--RL26 Revamp title screen: players out-->\n"
    out += _anim("TitleBgVB", OPACITY, [("00:00:00.45", 0)], ind)
    for side, cfg in SIDES.items():
        out += _anim(f"Title{side}RSV", OPACITY, [("00:00:00.45", 0)], ind)
        out += _margin_anim(f"Title{side}RSV", [
            ("00:00:00.5", _margin(cfg, SLIDE_OUT), ("CubicEase", "EaseIn"))], ind)
    # bottom-right stripes back for the menus (stock never animates them; 1 = stock)
    out += _anim("RightLinesGrid", OPACITY, [("00:00:00.3", 0), ("00:00:00.8", 1)], ind)
    return out


def apply_xaml(text):
    """menubackgroundview.xaml (after make_branding's other edits) -> with the
    revamp title screen."""
    nl = "\r\n" if "\r\n" in text else "\n"
    text = text.replace("\r\n", "\n")

    m = re.search(r'\n( *)<controls:baResolutionScaledViewbox x:Name="LogoRSV">.*?</controls:baResolutionScaledViewbox>\n',
                  text, flags=re.S)
    if not m:
        raise SystemExit("menubackgroundview.xaml: LogoRSV block not found")
    ind = m.group(1)
    block = (_bg_xaml(ind) + "\n"
             + "".join(_side_xaml(side, cfg, ind) + "\n" for side, cfg in SIDES.items())
             + _logo_xaml(ind))
    text = text[:m.start()] + "\n" + block + text[m.end():]

    m = re.search(r'\n( *)<!--After the menu text has completed changing', text)
    if not m:
        raise SystemExit("menubackgroundview.xaml: MenuTextIntroSB comment not found")
    text = text[:m.start()] + "\n" + _intro_storyboard(m.group(1)) + text[m.start():]

    m = re.search(r'\n( *)<i:EventTrigger EventName="Loaded">\s*<ei:GoToStateAction StateName="SignOn" />', text)
    if not m:
        raise SystemExit("menubackgroundview.xaml: Loaded -> SignOn trigger not found")
    i = m.group(1)
    trigger = (f'{i}<ei:DataTrigger Binding="{{Binding VisualStateKey}}"\n'
               f'{i}                Value="{INTRO_KEY}">\n'
               f'{i}    <ei:ControlStoryboardAction Storyboard="{{StaticResource TitleIntroSB}}"\n'
               f'{i}                                ControlStoryboardOption="Play" />\n'
               f'{i}</ei:DataTrigger>\n')
    text = text[:m.start()] + "\n" + trigger + text[m.start():]

    def add_to_state(match):
        hook = _reset_xaml if match.group(2) == "SignOn" else _outro_xaml
        return match.group(1) + hook(match.group(3)) + match.group(3)

    # TeamSelect's storyboard repeats forever; the players are already gone by then
    text, n = re.subn(r'(<VisualState x:Name="(\w+)">\s*<Storyboard[^>]*>[ \t]*\n(?:[ \t]*\n)*)( *)(?=<)',
                      add_to_state, text)
    if n != 6:
        raise SystemExit(f"menubackgroundview.xaml: expected 6 visual states, found {n}")
    return text.replace("\n", nl)


# ----------------------------------------------------------------- textures

def add_art(confirm, blobset=None):
    import add_entries
    import club_icons
    import pack
    blobset = blobset or pack.BLOBSET_PATH
    _sizes, header, _shield = club_icons.template_info(blobset, "cus_01")
    for name in ART:
        img = load_art(name)
        premul = Image.merge("RGBA", (*img.convert("RGBa").split()[:3], img.getchannel("A")))
        path = texture_path(name)
        blob, sizes = club_icons.make_blob(path.lower(), club_icons.make_dds(premul, header))
        add_entries.add_entry(blobset, path, blob, sizes, f"title_screen {name} {img.width}x{img.height}",
                              confirm, replace=True)
    if not confirm:
        print("dry run - pass --confirm to write (close the game first)")


# ----------------------------------------------------------------- preview

def preview(out):
    """Rough 1920x1080 render of the SignOn layout (static, no menu background)."""
    W, H = 1920, 1080
    canvas = Image.new("RGBA", (W, H))
    grad = ImageDraw.Draw(canvas)
    for y in range(H):
        t = y / H
        grad.line([(0, y), (W, y)], fill=(int(10 - 6 * t), int(24 - 14 * t), int(52 - 30 * t), 255))
    bg = load_art("bg")
    scale = H / bg.height  # screen height (BG_SIDE_BLEED)
    bg = bg.resize((round(bg.width * scale), round(bg.height * scale)), Image.LANCZOS)
    if BG_OPACITY < 1:
        bg.putalpha(bg.getchannel("A").point(lambda a: round(a * BG_OPACITY)))
    canvas.alpha_composite(bg, ((W - bg.width) // 2, (H - bg.height) // 2))
    smoke = load_art("smoke")
    for side, cfg in SIDES.items():
        x0 = 0 if cfg["align"] == "Left" else W - cfg["width"]
        for tint, size, left, top, opacity, _s in cfg["smoke"]:
            puff = smoke.resize((size, size), Image.LANCZOS)
            alpha = puff.getchannel("A").point(lambda a, o=opacity: round(a * o))
            colour = Image.new("RGBA", puff.size, tint or "#FFFFFF") if tint else puff
            colour.putalpha(alpha)
            canvas.alpha_composite(colour, (x0 + left, top))
        height, left, top = cfg["image"]
        img = load_art(side.lower())
        img = img.resize((round(height * img.width / img.height), height), Image.LANCZOS)
        layer = Image.new("RGBA", (W, H))
        layer.paste(img, (x0 + left, top))
        canvas.alpha_composite(layer)
    logo = Image.open(LOGO).convert("RGBA")
    logo = logo.resize((round(LOGO_HEIGHT * logo.width / logo.height), LOGO_HEIGHT), Image.LANCZOS)
    font_path = os.path.join(ROOT, "Maison-Neue-Extended-Bold.ttf")
    font = ImageFont.truetype(font_path, PROMPT_SIZE) if os.path.exists(font_path) else ImageFont.load_default()
    text = "PRESS (A) TO CONTINUE"
    tw = ImageDraw.Draw(canvas).textlength(text, font=font)
    block_h = LOGO_HEIGHT + 50 + PROMPT_SIZE
    top = (H - block_h) // 2
    canvas.alpha_composite(logo, ((W - logo.width) // 2, top))
    ImageDraw.Draw(canvas).text(((W - tw) / 2, top + LOGO_HEIGHT + 50), text, font=font, fill="white")
    canvas.convert("RGB").save(out)
    print(f"wrote {out}")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument("--preview", metavar="OUT_PNG", help="render the layout to a PNG")
    g.add_argument("--add-art", action="store_true", help="append/replace the title textures")
    ap.add_argument("--confirm", action="store_true", help="--add-art: actually write (game closed)")
    ap.add_argument("--blobset", default=None)
    args = ap.parse_args()
    if args.preview:
        preview(args.preview)
    else:
        add_art(args.confirm, args.blobset)


if __name__ == "__main__":
    main()
