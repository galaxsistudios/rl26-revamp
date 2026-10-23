#!/usr/bin/env python3
"""
generate.py - Rebuilds this mod's overrides from the stock sources.

Run from the repo root:  python mods\\loading-screen-secondary-arrows\\generate.py
(build.py skips *.py files, so this script never ends up in a bundle.)

Writes:
  src/script-game/design/loading_setup_helper.lua             team colours sent as an arrow key
  noesis/workspace/views/loadingscreen/loadingscreen_rugby.xaml  every second arrow in the secondary colour

The native loading-screen view model only has HomeTeamColour/AwayTeamColour, so
there is no way to hand it a secondary colour. Instead the Lua sends the primary
with the low 2 bits of each channel replaced by a 6-bit hash of the secondary
(at most 3/255 off, invisible). That colour is unique per (primary, secondary)
pair, and the XAML maps it back to the secondary with one DataTrigger per stock
club. Anything not in the table (custom clubs, online sides) keeps primary-only
arrows.
"""
import glob
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(ROOT))

STOCK_LUA = os.path.join(REPO, "decompiled", "src", "script-game", "design", "loading_setup_helper.lua")
STOCK_XAML = os.path.join(REPO, "extracted", "noesis", "workspace", "views", "loadingscreen", "loadingscreen_rugby.xaml")
STOCK_CLUBS = os.path.join(REPO, "decompiled", "defaultdata", "defaultdata_clubs")

OUT_LUA = os.path.join(ROOT, "src", "script-game", "design", "loading_setup_helper.lua")
OUT_XAML = os.path.join(ROOT, "noesis", "workspace", "views", "loadingscreen", "loadingscreen_rugby.xaml")

# Must match ArrowKeyColour in the Lua below.
HASH_MULS = (1, 3, 5)


def secondary_hash(s):
    return (s[0] * HASH_MULS[0] + s[1] * HASH_MULS[1] + s[2] * HASH_MULS[2]) % 64


def arrow_key(p, s):
    h = secondary_hash(s)
    return (p[0] - p[0] % 4 + h % 4, p[1] - p[1] % 4 + (h // 4) % 4, p[2] - p[2] % 4 + h // 16)


def hex_colour(c):
    return "#FF%02X%02X%02X" % tuple(c)


# ---------------------------------------------------------------- club colours

def load_clubs():
    """Stock club records, with any mods/*/defaultdata_clubs overrides merged on top."""
    clubs = {}
    for f in sorted(glob.glob(os.path.join(STOCK_CLUBS, "*.json"))):
        with open(f, encoding="utf-8") as fh:
            clubs[os.path.basename(f)] = json.load(fh)
    for f in sorted(glob.glob(os.path.join(REPO, "mods", "*", "defaultdata", "defaultdata_clubs", "*.json"))):
        name = os.path.basename(f)
        with open(f, encoding="utf-8") as fh:
            clubs.setdefault(name, {}).update(json.load(fh))
    return clubs


def build_table():
    """{key colour: (secondary, [club names])} for every pair with a distinct secondary."""
    table = {}
    for rec in load_clubs().values():
        p = tuple(rec.get("primaryRGBColour") or ())
        s = tuple(rec.get("secondaryRGBColour") or ())
        if len(p) != 3 or len(s) != 3 or p == s:
            continue
        key = arrow_key(p, s)
        if key in table and table[key][0] != s:
            sys.exit("arrow key collision %s: %s vs %s (%s) - change HASH_MULS"
                     % (hex_colour(key), hex_colour(s), hex_colour(table[key][0]), rec["fullName"]))
        table.setdefault(key, (s, []))[1].append(rec["fullName"])
    return table


# ---------------------------------------------------------------- Lua

LUA_HELPER = """\
local function ArrowKeyColour(arg_0_0, arg_0_1)
	local var_0_0 = math.floor(arg_0_0.r)
	local var_0_1 = math.floor(arg_0_0.g)
	local var_0_2 = math.floor(arg_0_0.b)
	local var_0_3 = (math.floor(arg_0_1.r) * %d + math.floor(arg_0_1.g) * %d + math.floor(arg_0_1.b) * %d) %% 64

	return native.NsColor(var_0_0 - var_0_0 %% 4 + var_0_3 %% 4, var_0_1 - var_0_1 %% 4 + math.floor(var_0_3 / 4) %% 4, var_0_2 - var_0_2 %% 4 + math.floor(var_0_3 / 16), 255)
end

""" % HASH_MULS


def replace_once(text, old, new, what):
    if text.count(old) != 1:
        sys.exit("expected exactly one %s in stock source" % what)
    return text.replace(old, new)


def build_lua():
    with open(STOCK_LUA, encoding="utf-8-sig", newline="") as fh:
        text = fh.read()
    nl = "\r\n" if "\r\n" in text else "\n"
    text = text.replace("\r\n", "\n")

    text = LUA_HELPER + text
    text = replace_once(
        text,
        "\t\tvar_1_5.homeTeamColour = native.NsColor(var_1_6.r, var_1_6.g, var_1_6.b, 255)\n"
        "\t\tvar_1_5.awayTeamColour = native.NsColor(var_1_7.r, var_1_7.g, var_1_7.b, 255)\n",
        "\t\tvar_1_5.homeTeamColour = ArrowKeyColour(var_1_6, arg_1_2.identity.secondaryRGBColour)\n"
        "\t\tvar_1_5.awayTeamColour = ArrowKeyColour(var_1_7, arg_1_3.identity.secondaryRGBColour)\n",
        "SetupLoadingScreen colour block")
    return "﻿" + text.replace("\n", nl)


# ---------------------------------------------------------------- XAML

def arrow_style(side, table):
    out = [
        '            <Style x:Key="%sSecondaryArrow"' % side,
        '                   TargetType="Path">',
        '                <Setter Property="Stroke"',
        '                        Value="{StaticResource %sTeamBrush}" />' % side,
        '                <Style.Triggers>',
    ]
    for key in sorted(table):
        sec, names = table[key]
        out += [
            '                    <!--%s-->' % ", ".join(sorted(set(names))).replace("--", "-"),
            '                    <DataTrigger Binding="{Binding %sTeamColour}">' % side,
            '                        <DataTrigger.Value>',
            '                            <Color>%s</Color>' % hex_colour(key),
            '                        </DataTrigger.Value>',
            '                        <Setter Property="Stroke"',
            '                                Value="%s" />' % hex_colour(sec),
            '                    </DataTrigger>',
        ]
    out += [
        '                </Style.Triggers>',
        '            </Style>',
        '',
    ]
    return "\n".join(out) + "\n"


# Every other GlowyLines cycle shows the copy (opposite slot pattern) instead of the stock arrows.
SECONDARY_STORYBOARD = """\
            <Storyboard x:Key="SecondaryArrows"
                        Duration="00:00:02"
                        RepeatBehavior="Forever">
%s            </Storyboard>

"""

SB_TRACK = """\
                <DoubleAnimationUsingKeyFrames Storyboard.TargetName="%s"
                                               Storyboard.TargetProperty="Opacity">
                    <DiscreteDoubleKeyFrame KeyTime="00:00:00"
                                            Value="%d" />
                    <DiscreteDoubleKeyFrame KeyTime="00:00:01"
                                            Value="%d" />
                </DoubleAnimationUsingKeyFrames>
"""


def secondary_style(side):
    return 'Style="{StaticResource %sSecondaryArrow}"' % side


def recolour_even(block, side):
    """Stock StackPanel: paths RL2/RL4/RL6 (LL2/...) get the secondary style."""
    def path(m):
        tag = m.group(0)
        if int(m.group(1)[-1]) % 2:
            return tag
        return tag.replace('Stroke="{StaticResource %sTeamBrush}"' % side, secondary_style(side))

    return re.sub(r'<Path x:Name="(\w+)".*?/>', path, block, flags=re.S)


def secondary_copy(block, sp_name, side):
    """Copy of a lines StackPanel whose paths follow the originals, with the odd paths secondary.

    Each GlowyLines cycle moves every arrow one slot outward and then resets, so the slot
    pattern swaps between the stock panel and this copy every cycle to keep each arrow's colour.
    """
    block = re.sub(r"[ \t]*<!--.*?-->\n", "", block, flags=re.S)
    block = replace_once(block, 'x:Name="%s"' % sp_name, 'x:Name="%sSecondary"' % sp_name, sp_name + " name")
    block = re.sub(r'(<StackPanel[^>]*?)Margin="[^"]*"',
                   r'\1Margin="{Binding ElementName=%s, Path=Margin}"\n                            Opacity="0"' % sp_name,
                   block, count=1, flags=re.S)

    def path(m):
        tag, name = m.group(0), m.group(1)
        tag = re.sub(r'\s*Opacity="[^"]*"', "", tag)
        if int(name[-1]) % 2:
            tag = tag.replace('Stroke="{StaticResource %sTeamBrush}"' % side, secondary_style(side))
        tag = re.sub(r'StrokeThickness="[^"]*"',
                     'StrokeThickness="{Binding ElementName=%s, Path=StrokeThickness}"\n'
                     '                              Opacity="{Binding ElementName=%s, Path=Opacity}"' % (name, name),
                     tag)
        return tag.replace('x:Name="%s"' % name, 'x:Name="%sSecondary"' % name)

    block, n = re.subn(r'<Path x:Name="(\w+)".*?/>', path, block, flags=re.S)
    if n != 6:
        sys.exit("expected 6 arrow paths in %s, found %d" % (sp_name, n))
    return block


def build_xaml(table):
    with open(STOCK_XAML, encoding="utf-8-sig", newline="") as fh:
        text = fh.read()
    nl = "\r\n" if "\r\n" in text else "\n"
    text = text.replace("\r\n", "\n")

    anchor = ('            <SolidColorBrush x:Key="AwayTeamBrush"\n'
              '                             Color="{Binding AwayTeamColour}"\n'
              '                             d:Color="Blue" />\n\n')
    text = replace_once(text, anchor, anchor + arrow_style("Home", table) + arrow_style("Away", table),
                        "AwayTeamBrush resource")

    tracks = "".join(SB_TRACK % (name, a, b) for name, a, b in (
        ("RightLinesSP", 1, 0), ("LeftLinesSP", 1, 0),
        ("RightLinesSPSecondary", 0, 1), ("LeftLinesSPSecondary", 0, 1)))
    anchor = '            <Storyboard x:Key="BGImageAnim"'
    text = replace_once(text, anchor, SECONDARY_STORYBOARD % tracks + anchor, "BGImageAnim storyboard")

    anchor = '            <BeginStoryboard Storyboard="{StaticResource GlowyLines}" />\n'
    text = replace_once(text, anchor,
                        anchor + '            <BeginStoryboard Storyboard="{StaticResource SecondaryArrows}" />\n',
                        "GlowyLines BeginStoryboard")

    for sp_name, side in (("RightLinesSP", "Away"), ("LeftLinesSP", "Home")):
        m = re.search(r'[ \t]*<StackPanel x:Name="%s".*?</StackPanel>\n' % sp_name, text, flags=re.S)
        if not m:
            sys.exit("no %s StackPanel in stock XAML" % sp_name)
        text = (text[:m.start()] + recolour_even(m.group(0), side) + "\n"
                + secondary_copy(m.group(0), sp_name, side) + text[m.end():])

    return "﻿" + text.replace("\n", nl)


def write(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="") as fh:
        fh.write(text)
    print("wrote", os.path.relpath(path, REPO))


def main():
    table = build_table()
    print("%d arrow colour entries" % len(table))
    write(OUT_LUA, build_lua())
    write(OUT_XAML, build_xaml(table))


if __name__ == "__main__":
    main()
