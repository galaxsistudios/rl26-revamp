#!/usr/bin/env python3
"""
Generates main-menu-revamp's two Noesis XAML overrides (bundle 57662) from the
stock files, so the tile list, icons and code-behind hooks stay in step with
the game:

  noesis/workspace/views/homescreen/pahomescreenview.xaml
      The home screen: tabs and a vertical stack of menu boxes on the left, the
      right half left clear for the 3D player (see the Lua hook). The tile rows
      are inlined from the stock pa*TileRow.xaml files (same DataContext keys
      and icons), so those four files stay untouched (about-rl26-revamped owns
      paextratilerow.xaml).

  noesis/workspace/genericcontrols/paaccordionbutton.xaml
      Stock file plus Tag="MenuBox" triggers inside the stock AccordionTemplate:
      the box look for the main button, and the sub-menu flying out to the
      right of the box instead of popping up above the tile. Pause menu / dynasty / everything else keeps
      the stock template.

    python mods\\main-menu-revamp\\make_xaml.py [--stock <extracted noesis/workspace>]

Run it against a stock extraction of entry 57662 (extracted\\noesis\\workspace
by default). build.py skips *.py, so this file is never packed.
"""

import argparse
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.normpath(os.path.join(HERE, "..", ".."))
DEFAULT_STOCK = os.path.join(REPO, "extracted", "noesis", "workspace")
ABOUT_EXTRA_ROW = os.path.join(REPO, "mods", "about-rl26-revamped", "noesis", "workspace", "views", "homescreen", "paextratilerow.xaml")
OUT_HOME = os.path.join(HERE, "noesis", "workspace", "views", "homescreen", "pahomescreenview.xaml")
OUT_ACCORDION = os.path.join(HERE, "noesis", "workspace", "genericcontrols", "paaccordionbutton.xaml")

# Stock tile rows: read for their icons (and the Academy row's tiles).
ROW_FILES = ["pahometilerow.xaml", "pacompetitiontilerow.xaml", "paacademytilerow.xaml", "paextratilerow.xaml"]

# Box kinds: "acc" = accordion (has a sub-menu), "btn" = plain button.
# (kind, binding path, icon key, x:Name or None). Binding paths are relative
# to the tab's DataContext. Keys and pages must match the Lua side
# (mainMenuReorganise / MainMenuPages in compresssavedata_state.lua).
SETTINGS_SLOTS = 12

PLAY_PAGES = [
    (None, [
        ("btn", "Main.CasualGame", "Casual", "CasualGameBox"),
        ("btn", "Main.Competitions", "@trophy", "CompetitionsBox"),
        ("acc", "Main.Career", "Career", None),
        ("acc", "Main.OnlineMenu", "Online", None),
        ("btn", "Main.CommsTasks", "CommsTasks", None),
    ]),
    ("Casual", [
        ("acc", "Main.CasualTeam", "Casual", "CasualTeamBox"),
        ("acc", "Main.CasualPlayer", "Career", None),
        ("btn", "Main.PageBack", "@back", None),
    ]),
    ("Competitions", [
        ("acc", "Competition.NRL", "@trophy", "NRLBox"),
        ("acc", "Competition.SuperLeague", "@trophy", None),
        ("acc", "Competition.NRLW", "@trophy", None),
        ("acc", "Competition.WSL", "@trophy", None),
        ("acc", "Competition.CompetitionHub", "@trophy", None),
        ("acc", "Main.RLWC2026", "RLWC2026", None),
        ("btn", "Main.PageBack", "@back", None),
    ]),
]

# Focus on page changes: Lua sets Main.FocusRequest two frames after the page
# changes (so the target is laid out), then clears it. "@Page" = back on the
# main page, returning to the box that opened it. Triggering on Main.Page
# itself fired while the page was still collapsed (focus landed one box down),
# and FocusElementIdentifier changes at runtime didn't move focus.
PAGE_FOCUS = {
    "Casual": "CasualTeamBox",
    "Competitions": "NRLBox",
    "@Casual": "CasualGameBox",
    "@Competitions": "CompetitionsBox",
}

BACK_PATH = "M10 0 12.8 2.8 7.6 8H24v4H7.6l5.2 5.2L10 20 0 10Z"

BOX_WIDTH = 440
BOX_HEIGHT = 50
BOX_GAP = 6
FOCUS_SLIDE = 14
FLYOUT_WIDTH = 310

# Icon shown when a tile's command is inactive (stock paButtonTemplate's lock).
LOCK_PATH = ("M5.1 52.6c-1.4 0-2.6-.5-3.5-1.5-1-1-1.5-2.1-1.5-3.5v-25c0-1.4.5-2.6 1.5-3.5.9-1 2.1-1.5 3.5-1.5H7.6v-5c0-3.5 "
             "1.2-6.4 3.7-8.8C13.7 1.3 16.6.1 20.1.1s6.4 1.2 8.8 3.7c2.5 2.4 3.7 5.3 3.7 8.8v5h2.5c1.4 0 2.6.5 3.5 1.5 1 .9 "
             "1.5 2.1 1.5 3.5v25c0 1.4-.5 2.6-1.5 3.5-1 1-2.1 1.5-3.5 1.5H5.1Zm15-12.5c1.4 0 2.6-.5 3.5-1.5 1-1 1.5-2.1 "
             "1.5-3.5s-.5-2.6-1.5-3.5c-1-1-2.1-1.5-3.5-1.5-1.4 0-2.6.5-3.5 1.5-1 .9-1.5 2.1-1.5 3.5s.5 2.6 1.5 3.5c.9 1 "
             "2.1 1.5 3.5 1.5ZM12.6 17.6h15v-5c0-2.1-.7-3.9-2.2-5.3-1.4-1.5-3.2-2.2-5.3-2.2-2.1 0-3.9.7-5.3 2.2-1.5 1.4-2.2 "
             "3.2-2.2 5.3v5Z")


def read(path):
    with open(path, "r", encoding="utf-8-sig") as f:
        return f.read().replace("\r\n", "\n")


def write(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8-sig", newline="\r\n") as f:
        f.write(text)


def attr(tag_text, name):
    m = re.search(r'\s' + re.escape(name) + r'="([^"]*)"', tag_text)
    return m.group(1) if m else None


def parse_row(text):
    """Returns [(kind, dataContextKey, pathData)] for the live (uncommented) tiles."""
    text = re.sub(r"<!--.*?-->", "", text, flags=re.S)
    tiles = []
    for m in re.finditer(r"<controls:(paAccordionButton|paButton)\b(.*?)(/>|>)", text, flags=re.S):
        kind, body = m.group(1), m.group(2)
        binding = attr(body, "DataContext")
        key = re.match(r"\{Binding (\w+)\}", binding or "")
        if not key:
            raise ValueError("tile without a DataContext binding: " + body[:80])
        tiles.append((kind, key.group(1), attr(body, "PathData")))
    return tiles


def visual_states(p, chevron):
    """Normal / focused / selected states for the box template. Names match the
    stock paButtonTemplate, which the native paButton drives."""

    def state(name, bg, border, fg, icon, accent, slide, angle, weight):
        anims = [
            ("BackgroundBorder", "Background.(SolidColorBrush.Color)", bg),
            ("BackgroundBorder", "BorderBrush.(SolidColorBrush.Color)", border),
            ("ButtonTextBlock", "Foreground.(SolidColorBrush.Color)", fg),
            ("Path", "Fill.(SolidColorBrush.Color)", icon),
        ]
        if chevron:
            anims.append(("Chevron", "Stroke.(SolidColorBrush.Color)", icon))
        out = ['                    <VisualState x:Name="%s">' % name, "                        <Storyboard>"]
        for target, prop, colour in anims:
            out.append('                            <ColorAnimation Storyboard.TargetName="%s" Storyboard.TargetProperty="%s" To="%s" Duration="0:0:0.15" />'
                       % (target, prop, colour))
        out.append('                            <DoubleAnimation Storyboard.TargetName="AccentBar" Storyboard.TargetProperty="Opacity" To="%s" Duration="0:0:0.15" />' % accent)
        out.append('                            <DoubleAnimation Storyboard.TargetName="RootGrid" Storyboard.TargetProperty="(UIElement.RenderTransform).(TranslateTransform.X)" To="%d" Duration="0:0:0.18">' % slide)
        out.append("                                <DoubleAnimation.EasingFunction>")
        out.append('                                    <QuadraticEase EasingMode="EaseOut" />')
        out.append("                                </DoubleAnimation.EasingFunction>")
        out.append("                            </DoubleAnimation>")
        if chevron:
            out.append('                            <DoubleAnimation Storyboard.TargetName="Chevron" Storyboard.TargetProperty="(UIElement.RenderTransform).(RotateTransform.Angle)" To="%d" Duration="0:0:0.15" />' % angle)
        out.append('                            <ObjectAnimationUsingKeyFrames Storyboard.TargetName="ButtonTextBlock" Storyboard.TargetProperty="(TextBlock.FontWeight)">')
        out.append('                                <DiscreteObjectKeyFrame KeyTime="00:00:00">')
        out.append("                                    <DiscreteObjectKeyFrame.Value>")
        out.append("                                        <FontWeight>%s</FontWeight>" % weight)
        out.append("                                    </DiscreteObjectKeyFrame.Value>")
        out.append("                                </DiscreteObjectKeyFrame>")
        out.append("                            </ObjectAnimationUsingKeyFrames>")
        out.append("                        </Storyboard>")
        out.append("                    </VisualState>")
        return "\n".join(out)

    return "\n".join([
        "            <VisualStateManager.VisualStateGroups>",
        "                <VisualStateGroup>",
        state("NormalVisualState", "{StaticResource RLBlack70Col}", "#303030", "{StaticResource RLWhite70Col}",
              "{StaticResource RLWhite70Col}", "0.4", 0, 0, "Normal"),
        state("IsFocusedVisualState", "{StaticResource RLWhiteCol}", "{StaticResource RLGreenCol}", "{StaticResource RLBlackCol}",
              "{StaticResource RLBlackCol}", "1", FOCUS_SLIDE, 0, "Bold"),
        state("IsSelectedVisualState", "{StaticResource RLBlack90Col}", "{StaticResource RLGreenCol}", "{StaticResource RLWhiteCol}",
              "{StaticResource RLGreenCol}", "1", FOCUS_SLIDE, 90, "Bold"),
        "                </VisualStateGroup>",
        "            </VisualStateManager.VisualStateGroups>",
    ])


def box_template(key, p, chevron):
    """A paButton template: a wide box with an accent bar, icon, title and (for
    accordions) a chevron. `p` is the XAML prefix of Workspace.Controls."""
    chevron_xml = ""
    if chevron:
        chevron_xml = """
                <Path x:Name="Chevron"
                      Grid.Column="2"
                      Width="9"
                      Height="15"
                      Stretch="Fill"
                      Data="M0,0 L8,8 L0,16"
                      StrokeThickness="2.5"
                      VerticalAlignment="Center"
                      RenderTransformOrigin="0.5,0.5">
                    <Path.Stroke>
                        <SolidColorBrush Color="{StaticResource RLWhite70Col}" />
                    </Path.Stroke>
                    <Path.RenderTransform>
                        <RotateTransform Angle="0" />
                    </Path.RenderTransform>
                </Path>"""
    return """    <!--main-menu-revamp: menu box (see mods/main-menu-revamp/make_xaml.py)-->
    <ControlTemplate x:Key="%(key)s"
                     TargetType="{x:Type %(p)s:paButton}">
        <Grid x:Name="RootGrid"
              Width="%(w)d"
              Height="%(h)d"
              HorizontalAlignment="Left"
              VerticalAlignment="Top">
            <Grid.RenderTransform>
                <TranslateTransform X="0" />
            </Grid.RenderTransform>

            <Border x:Name="BackgroundBorder"
                    BorderThickness="1">
                <Border.Background>
                    <SolidColorBrush Color="{StaticResource RLBlack70Col}" />
                </Border.Background>
                <Border.BorderBrush>
                    <SolidColorBrush Color="#303030" />
                </Border.BorderBrush>
            </Border>

            <Rectangle x:Name="AccentBar"
                       Width="5"
                       HorizontalAlignment="Left"
                       Fill="{StaticResource RLGreen}"
                       Opacity="0.4" />

            <Grid Margin="20,0,16,0">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="26" />
                    <ColumnDefinition Width="*" />
                    <ColumnDefinition Width="Auto" />
                </Grid.ColumnDefinitions>

                <Viewbox x:Name="PathViewbox"
                         Width="24"
                         Height="24"
                         VerticalAlignment="Center">
                    <Path x:Name="Path">
                        <Path.Fill>
                            <SolidColorBrush Color="{StaticResource RLWhite70Col}" />
                        </Path.Fill>
                        <Path.Style>
                            <Style TargetType="Path">
                                <Style.Triggers>
                                    <DataTrigger Binding="{Binding Command.IsActive}"
                                                 Value="True">
                                        <Setter Property="Data"
                                                Value="{Binding RelativeSource={RelativeSource AncestorType=%(p)s:paButtonBase}, Path=PathData}" />
                                    </DataTrigger>
                                    <DataTrigger Binding="{Binding Command.IsActive}"
                                                 Value="False">
                                        <Setter Property="Data"
                                                Value="%(lock)s" />
                                    </DataTrigger>
                                </Style.Triggers>
                            </Style>
                        </Path.Style>
                    </Path>
                </Viewbox>

                <TextBlock x:Name="ButtonTextBlock"
                           Grid.Column="1"
                           Margin="14,0,8,0"
                           VerticalAlignment="Center"
                           Style="{StaticResource Row_M}"
                           FontSize="20"
                           TextTrimming="CharacterEllipsis"
                           Text="{Binding RelativeSource={RelativeSource AncestorType=%(p)s:paButton}, Path=Title, Converter={StaticResource UppercaseConverter}}">
                    <TextBlock.Foreground>
                        <SolidColorBrush Color="{StaticResource RLWhite70Col}" />
                    </TextBlock.Foreground>
                </TextBlock>%(chevron)s
            </Grid>

            <Ellipse x:Name="UnreadIndicator"
                     Visibility="{Binding HasUnread, Converter={StaticResource BooleanToVisibilityConverter}, FallbackValue=Collapsed}"
                     Fill="{StaticResource RLGradientH}"
                     Width="15"
                     Height="15"
                     HorizontalAlignment="Right"
                     VerticalAlignment="Top"
                     Margin="-4"
                     Stroke="{StaticResource RLDarkGreen}" />

%(states)s
        </Grid>
    </ControlTemplate>
""" % {
        "key": key,
        "p": p,
        "w": BOX_WIDTH,
        "h": BOX_HEIGHT,
        "lock": LOCK_PATH,
        "chevron": chevron_xml,
        "states": visual_states(p, chevron),
    }


def indent(text, spaces):
    pad = " " * spaces
    return "\n".join(pad + line if line.strip() else line for line in text.split("\n"))


def tile_xaml(kind, binding, path_data, name=None):
    pad = "                                    "
    extra = ""
    if name:
        extra += '\n%sx:Name="%s"' % (pad, name)
    if path_data:
        extra += '\n%sPathData="%s"' % (pad, path_data)
    if kind == "acc":
        return ('<controls:paAccordionButton Tag="MenuBox"\n'
                '%sDataContext="{Binding %s}"%s />' % (pad, binding, extra))
    return ('<controls:paButton DataContext="{Binding %s}"\n'
            '%sTemplate="{StaticResource MenuBoxButtonTemplate}"\n'
            '%sMargin="0,0,0,%d"\n'
            '%sHorizontalAlignment="Left"\n'
            '%sVerticalAlignment="Top"%s />' % (binding, pad, pad, BOX_GAP, pad, pad, extra))


def page_style(page, pages):
    """Play tab: a named page shows while Main.Page equals its name; the main
    page (None) hides while any named page is open."""
    if page is None:
        triggers = "".join("""
                                            <DataTrigger Binding="{Binding Main.Page}"
                                                         Value="%s">
                                                <Setter Property="Visibility"
                                                        Value="Collapsed" />
                                            </DataTrigger>""" % name for name, _ in pages if name)
        setter = ""
    else:
        triggers = """
                                            <DataTrigger Binding="{Binding Main.Page}"
                                                         Value="%s">
                                                <Setter Property="Visibility"
                                                        Value="Visible" />
                                            </DataTrigger>""" % page
        setter = """
                                        <Setter Property="Visibility"
                                                Value="Collapsed" />"""
    return """
                                <StackPanel.Style>
                                    <Style TargetType="StackPanel">%s
                                        <Style.Triggers>%s
                                        </Style.Triggers>
                                    </Style>
                                </StackPanel.Style>""" % (setter, triggers)


def page_xaml(page, tiles, icons, pages):
    body = "\n\n".join("                                " + tile_xaml(kind, binding, icons.get(icon), name)
                         for kind, binding, icon, name in tiles)
    style = page_style(page, pages) if len(pages) > 1 else ""
    return """                            <StackPanel Orientation="Vertical"
                                        HorizontalAlignment="Left"
                                        VerticalAlignment="Top"
                                        KeyboardNavigation.DirectionalNavigation="Cycle">%(style)s

%(body)s
                            </StackPanel>""" % {"style": style, "body": body}


def tab_item(tag, header, data_context, pages, icons):
    stacks = "\n\n".join(page_xaml(page, tiles, icons, pages) for page, tiles in pages)
    return """                    <TabItem Tag="%(tag)s"
                             Header="%(header)s"
                             DataContext="%(dc)s"
                             IsTabStop="False">
                        <Grid HorizontalAlignment="Left"
                              VerticalAlignment="Top">
                            <Grid.RenderTransform>
                                <TranslateTransform />
                            </Grid.RenderTransform>
                            <Grid.Resources>
                                <Storyboard x:Key="MenuStackEnter">
                                    <DoubleAnimationUsingKeyFrames Storyboard.TargetProperty="(UIElement.RenderTransform).(TranslateTransform.X)">
                                        <DiscreteDoubleKeyFrame KeyTime="0:0:0"
                                                                Value="-60" />
                                        <EasingDoubleKeyFrame KeyTime="0:0:0.25"
                                                              Value="0">
                                            <EasingDoubleKeyFrame.EasingFunction>
                                                <QuadraticEase EasingMode="EaseOut" />
                                            </EasingDoubleKeyFrame.EasingFunction>
                                        </EasingDoubleKeyFrame>
                                    </DoubleAnimationUsingKeyFrames>
                                    <DoubleAnimationUsingKeyFrames Storyboard.TargetProperty="Opacity">
                                        <DiscreteDoubleKeyFrame KeyTime="0:0:0"
                                                                Value="0" />
                                        <EasingDoubleKeyFrame KeyTime="0:0:0.25"
                                                              Value="1" />
                                    </DoubleAnimationUsingKeyFrames>
                                </Storyboard>
                            </Grid.Resources>
                            <b:Interaction.Triggers>
                                <b:EventTrigger EventName="Loaded">
                                    <b:ControlStoryboardAction Storyboard="{StaticResource MenuStackEnter}"
                                                               ControlStoryboardOption="Play" />
                                </b:EventTrigger>
                            </b:Interaction.Triggers>

%(stacks)s
                        </Grid>
                    </TabItem>""" % {"tag": tag, "header": header, "dc": data_context, "stacks": stacks}


TAB_CONTROL_TEMPLATE = """            <!--main-menu-revamp: MainMenuTabControlTemplate (paTabControlStyles.xaml) with
                text tabs and a content row that grows with the stack (stock: 120 px).-->
            <ControlTemplate x:Key="MenuStackTabControlTemplate"
                             TargetType="{x:Type GenericControls:paTabControl}">
                <ControlTemplate.Resources>
                    <ControlTemplate x:Key="MenuTabItemTemplate"
                                     TargetType="TabItem">
                        <Grid Focusable="False"
                              Margin="0,0,6,0">
                            <Border x:Name="TabBorder"
                                    Height="40"
                                    Padding="18,0"
                                    BorderThickness="1"
                                    Background="{StaticResource RLBlack70}"
                                    BorderBrush="#303030">
                                <TextBlock x:Name="TabText"
                                           Text="{TemplateBinding Header}"
                                           Style="{StaticResource Row_M}"
                                           FontWeight="Bold"
                                           VerticalAlignment="Center"
                                           Foreground="{StaticResource RLWhite70}" />
                            </Border>

                            <Ellipse x:Name="UnreadIndicator"
                                     Fill="{StaticResource RLGradientH}"
                                     Width="12"
                                     Height="12"
                                     Margin="-4"
                                     HorizontalAlignment="Right"
                                     VerticalAlignment="Top"
                                     Stroke="{StaticResource RLDarkGreen}">
                                <Ellipse.Style>
                                    <Style TargetType="Ellipse">
                                        <Setter Property="Visibility"
                                                Value="Collapsed" />
                                        <Style.Triggers>
                                            <DataTrigger Binding="{Binding HasUnread}"
                                                         Value="True">
                                                <Setter Property="Visibility"
                                                        Value="Visible" />
                                            </DataTrigger>
                                        </Style.Triggers>
                                    </Style>
                                </Ellipse.Style>
                            </Ellipse>
                        </Grid>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsSelected"
                                     Value="True">
                                <Setter TargetName="TabBorder"
                                        Property="Background"
                                        Value="{StaticResource RLGreen}" />
                                <Setter TargetName="TabBorder"
                                        Property="BorderBrush"
                                        Value="{StaticResource RLGreen}" />
                                <Setter TargetName="TabText"
                                        Property="Foreground"
                                        Value="{StaticResource RLBlack}" />
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>

                    <Style TargetType="TabItem">
                        <Setter Property="Template"
                                Value="{StaticResource MenuTabItemTemplate}" />
                    </Style>

                    <Style TargetType="{x:Type controls:paNoesisTabItem}"
                           BasedOn="{StaticResource {x:Type TabItem}}" />
                </ControlTemplate.Resources>

                <Grid Focusable="False">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="40" />
                        <RowDefinition Height="18" />
                        <RowDefinition Height="*" />
                    </Grid.RowDefinitions>

                    <!--Fades while a sub-menu is open, like the stock tab strip.-->
                    <StackPanel x:Name="TabMenu"
                                Orientation="Horizontal"
                                HorizontalAlignment="Left">
                        <StackPanel.Style>
                            <Style TargetType="StackPanel">
                                <Style.Triggers>
                                    <DataTrigger Binding="{Binding subMenuOpen}"
                                                 Value="True">
                                        <Setter Property="Opacity"
                                                Value="0.35" />
                                    </DataTrigger>
                                </Style.Triggers>
                            </Style>
                        </StackPanel.Style>

                        <Viewbox Height="20"
                                 Margin="0,0,10,0"
                                 VerticalAlignment="Center">
                            <controls:paTextBlock FormattedText="|L1|" />
                        </Viewbox>

                        <TabPanel IsItemsHost="True"
                                  Focusable="False"
                                  VerticalAlignment="Center" />

                        <Viewbox Height="20"
                                 Margin="4,0,0,0"
                                 VerticalAlignment="Center">
                            <controls:paTextBlock FormattedText="|R1|" />
                        </Viewbox>
                    </StackPanel>

                    <Border Grid.Row="2"
                            x:Name="ContentBorder">
                        <ContentPresenter x:Name="PART_SelectedContentHost"
                                          ContentSource="SelectedContent"
                                          HorizontalAlignment="{TemplateBinding HorizontalContentAlignment}"
                                          VerticalAlignment="{TemplateBinding VerticalContentAlignment}" />
                    </Border>
                </Grid>
            </ControlTemplate>
"""


def build_home(stock, tabs):
    stock_home = read(os.path.join(stock, "views", "homescreen", "pahomescreenview.xaml"))

    # Keep the promo banner (its code-behind handlers and named parts) but hide it.
    start = stock_home.index('<Grid Grid.Row="1" x:Name="FeaturedBanner"')
    end = stock_home.index('<!--<Viewbox Grid.Row="1" HorizontalAlignment="Left" StretchDirection="DownOnly">')
    banner = stock_home[start:end].rstrip()
    banner = banner.replace('<Grid Grid.Row="1" x:Name="FeaturedBanner"',
                            '<Grid x:Name="FeaturedBanner"\n                  Visibility="Collapsed"', 1)
    banner = "\n".join(line[4:] if line.startswith("    ") else line for line in banner.split("\n"))

    header_end = stock_home.index("            <BitmapImage x:Key=\"FeatureImage\"")
    header = stock_home[:header_end]
    header = header.replace("<UserControl.Resources>",
                            "<!--main-menu-revamp: generated by mods/main-menu-revamp/make_xaml.py - edit that, not this.-->\n"
                            "    <UserControl.Resources>", 1)

    tab_items = "\n\n".join(tabs)
    focus_triggers = "".join("""
                        <b:DataTrigger Binding="{Binding Main.FocusRequest}"
                                       Value="%s">
                            <noesis:SetFocusAction TargetName="%s" />
                        </b:DataTrigger>""" % (page, target) for page, target in PAGE_FOCUS.items())

    return header + """            <paEx:paAdditionConverter x:Key="AdditionConverter" />

            <!--Button-->
            <DataTemplate DataType="{x:Type vm:paNVMButton}">
                <controls:paButton Content="{Binding Title}"
                                   ToolTip="{Binding ToolTip}"
                                   Command="{Binding Command}"
                                   Loaded="paButton_Loaded" />

            </DataTemplate>

            <!--Accordion-->
            <DataTemplate DataType="{x:Type vm:paNVMAccordionButton}">
                <controls:paAccordionButton Content="{Binding Title}"
                                            ToolTip="{Binding ToolTip}"
                                            ItemsSource="{Binding SubButtonVmCollection}"
                                            Loaded="paButton_Loaded" />

            </DataTemplate>

%(box)s
%(tabs_template)s        </ResourceDictionary>
    </UserControl.Resources>
    <UserControl.Style>
        <Style>
            <Setter Property="local:paHomeScreenView.MenuBannerStoryboardCompleteCommand" Value="{Binding MenuBannerStoryboardCompleteCommand}"/>
        </Style>
    </UserControl.Style>
    <controls:baScreenControl>

        <Grid>
            <!--Stock promo banner, hidden: the right half belongs to the 3D player.-->
            %(banner)s

            <!--Menu column: under the top-left logo of the background view, clear
                of the player on the right and the button prompts at the bottom.-->
            <Grid x:Name="ContentGrid"
                  HorizontalAlignment="Left"
                  Width="640"
                  Margin="150,172,0,130">
                <Grid.RowDefinitions>
                    <RowDefinition Height="*" />
                    <RowDefinition Height="Auto" />
                </Grid.RowDefinitions>

                <GenericControls:paTabControl x:Name="TabControl"
                                              Template="{StaticResource MenuStackTabControlTemplate}"
                                              Focusable="False"
                                              SelectedIndex="{Binding TabIndex, Mode=TwoWay}"
                                              InitialFocusedTab="{Binding TabIndex}"
                                              HorizontalContentAlignment="Left"
                                              VerticalContentAlignment="Top">

%(tab_items)s

                    <b:Interaction.Triggers>

                        <!--Focus the first button, so the user doesn't have to bump movement to do it themselves.-->
                        <b:EventTrigger EventName="Loaded">
                            <noesis:SetFocusAction TargetName="TabControl" />
                        </b:EventTrigger>

                        <!--Page focus, requested by the Lua hook once a page is laid out.-->%(focus_triggers)s
                    </b:Interaction.Triggers>
                </GenericControls:paTabControl>

                <TextBlock Grid.Row="1"
                           Text="{Binding Description}"
                           Margin="0,10,0,0"
                           MaxWidth="560"
                           HorizontalAlignment="Left"
                           TextWrapping="Wrap"
                           Style="{StaticResource Row_S}" />
            </Grid>

        </Grid>
    </controls:baScreenControl>

</controls:paUserControlView>
""" % {
        "box": indent(box_template("MenuBoxButtonTemplate", "controls", chevron=False), 8),
        "tabs_template": TAB_CONTROL_TEMPLATE,
        "banner": banner,
        "tab_items": tab_items,
        "focus_triggers": focus_triggers,
    }


# Added to the STOCK AccordionTemplate's ControlTemplate.Triggers: the template
# itself stays exactly as shipped (named parts, Canvas host, handlers). Two
# earlier versions swapped in a whole replacement template from the Style
# (sub-menu inline in a Grid row, then a Canvas flyout); in game neither showed
# any sub-buttons, and the native focus trap then locked the open box.
# Canvas.Top wins over the stock Canvas.Bottom, so nothing needs clearing.
ACCORDION_TEMPLATE_TRIGGER = """
                    <!--main-menu-revamp: home screen menu boxes. Box look for the main
                        button; the sub-menu flies out to the right of the box.-->
                    <Trigger Property="Tag"
                             Value="MenuBox">
                        <Setter TargetName="InternalButton"
                                Property="Template"
                                Value="{StaticResource MenuBoxAccordionButtonTemplate}" />
                        <Setter TargetName="AccordionItemsControl"
                                Property="Canvas.Top"
                                Value="0" />
                        <Setter TargetName="AccordionItemsControl"
                                Property="Canvas.Left"
                                Value="%(flyout_left)d" />
                        <Setter TargetName="AccordionItemsControl"
                                Property="Width"
                                Value="%(sub_width)d" />
                    </Trigger>
"""

ACCORDION_STYLE_TRIGGER = """
                    <!--main-menu-revamp: home screen menu boxes-->
                    <Trigger Property="Tag"
                             Value="MenuBox">
                        <Setter Property="Margin"
                                Value="0,0,0,%(gap)d" />
                        <Setter Property="HorizontalAlignment"
                                Value="Left" />
                        <Setter Property="VerticalAlignment"
                                Value="Top" />
                    </Trigger>
"""


def build_accordion(stock):
    text = read(os.path.join(stock, "genericcontrols", "paaccordionbutton.xaml"))

    # 1. The box template for InternalButton, defined before AccordionTemplate
    #    so the StaticResource in its trigger resolves.
    template_anchor = '            <ControlTemplate x:Key="AccordionTemplate"'
    if text.count(template_anchor) != 1:
        raise ValueError("AccordionTemplate anchor not found exactly once")
    text = text.replace(template_anchor,
                        indent(box_template("MenuBoxAccordionButtonTemplate", "local", chevron=True), 8) + "\n" + template_anchor, 1)

    # 2. The Tag trigger, last in AccordionTemplate's own triggers.
    template_start = text.index(template_anchor)
    template_triggers_end = text.index("                </ControlTemplate.Triggers>", template_start)
    text = (text[:template_triggers_end]
            + ACCORDION_TEMPLATE_TRIGGER.lstrip("\n") % {"flyout_left": BOX_WIDTH + FOCUS_SLIDE + 12, "sub_width": FLYOUT_WIDTH}
            + text[template_triggers_end:])

    # 3. Layout setters, last in the accordion Style's triggers.
    style_anchor = '            <Style TargetType="{x:Type local:paAccordionButton}">'
    if text.count(style_anchor) != 1:
        raise ValueError("accordion Style anchor not found exactly once")
    style_start = text.index(style_anchor)
    style_triggers_end = text.index("                </Style.Triggers>", style_start)
    text = text[:style_triggers_end] + ACCORDION_STYLE_TRIGGER.lstrip("\n") % {"gap": BOX_GAP} + text[style_triggers_end:]
    return text


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--stock", default=DEFAULT_STOCK, help="stock extraction of noesis/workspace (entry 57662)")
    args = parser.parse_args()

    tab_styles = read(os.path.join(args.stock, "resources", "styles", "patabcontrolstyles.xaml"))
    rows = {}
    icons = {}
    for row_file in ROW_FILES:
        tiles = parse_row(read(os.path.join(args.stock, "views", "homescreen", row_file)))
        rows[row_file] = tiles
        icons.update({key: path for _, key, path in tiles if path})
    if os.path.exists(ABOUT_EXTRA_ROW):
        # about-rl26-revamped puts an "info" icon on the NTS slot.
        icons.update({key: path for _, key, path in parse_row(read(ABOUT_EXTRA_ROW)) if key == "NTS" and path})
    trophy = re.search(r'Path=Tag\}"\s+Value="Competition">\s*<Setter Property="Data"\s+Value="([^"]+)"', tab_styles)
    icons["@trophy"] = trophy.group(1) if trophy else None
    icons["@back"] = BACK_PATH

    academy = [("acc" if kind == "paAccordionButton" else "btn", key, key, None)
               for kind, key, _ in rows["paacademytilerow.xaml"]]
    settings = [("btn", "SettingsItem%d" % i, "Settings", None) for i in range(1, SETTINGS_SLOTS + 1)]
    extras = [("btn", "Practice", "Practice", None), ("btn", "Credits", "Credits", None), ("btn", "NTS", "NTS", None)]

    tabs = [
        tab_item("Play", "PLAY", "{Binding}", PLAY_PAGES, icons),
        tab_item("Academy", "{Binding Converter={StaticResource UppercaseLocalise}, ConverterParameter=AcademyTab}",
                 "{Binding Academy}", [(None, academy)], icons),
        tab_item("Settings", "{Binding Converter={StaticResource UppercaseLocalise}, ConverterParameter=Settings}",
                 "{Binding Extra}", [(None, settings)], icons),
        tab_item("Extra", "{Binding Converter={StaticResource UppercaseLocalise}, ConverterParameter=ExtraTab}",
                 "{Binding Extra}", [(None, extras)], icons),
    ]
    for page, tiles in PLAY_PAGES:
        print("Play/%-12s %s" % (page or "main", ", ".join(b for _, b, _, _ in tiles)))
    print("Academy           " + ", ".join(b for _, b, _, _ in academy))
    print("Settings          SettingsItem1..%d" % SETTINGS_SLOTS)
    print("Extras            " + ", ".join(b for _, b, _, _ in extras))

    write(OUT_HOME, build_home(args.stock, tabs))
    write(OUT_ACCORDION, build_accordion(args.stock))
    print("wrote " + os.path.relpath(OUT_HOME, REPO))
    print("wrote " + os.path.relpath(OUT_ACCORDION, REPO))
    return 0


if __name__ == "__main__":
    sys.exit(main())
