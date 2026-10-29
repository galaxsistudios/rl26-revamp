# rl26-revamp-branding

Replaces the Rugby League 26 logo with the RL26 Revamped logo
(`resources/rl26-revamp/rl26-revamped-logo.png`) and swaps the brand green
(#24DB61) for the revamp blue (#1E6FD9).

## What changes

| Where | File / entry |
|---|---|
| Logo (title screen, menu corner, bunker decision banner, dynasty card watermark) | `RLL26_Logo` / `RLL26_Logo_White` vector templates in `resources/resourcedictionary.xaml`, traced from the PNG |
| UI accent colour (all `RLGreen` / `RLGreen10` / `RLDarkGreen` uses, ~200) | `resources/colours_bigant.xaml` -> #1E6FD9 / #0C2E59 |
| Menu background title gradient | `views/background/menubackgroundview.xaml` |
| Generic + NRL screen-wipe colours | `resources/stylethemes/screenwipes/rl26_wipe_{generic,nrl}.xaml` |
| Screen-wipe centre logo bitmap | texture entry 57399 (`textures/57399_rll_logo.dds`) |
| Focus outlines on lists/buttons, text and date inputs, replay HUD | native `SkinColours.RLLMainColour` in `src/script-game/intermediatelua/skin/colour_map.lua` (script bundle 39959) |
| Menu background neon stripes (`MainColour`), dynasty background | `uicolours.rlgreencol` in `src/script-game/uicore/uicolours.lua` (39959) |

The revamp logo is about 2.8:1, compared with 6.3:1 for the old one, so
each slot has explicit sizes:

| Slot | Size |
|---|---|
| Title screen | 240 tall, between Herbie and Jesse (see below) |
| Menu corner | 250x72, moved up from y=100 to y=70 to clear the featured slider |
| Bunker banner | 525x150 (set in [bunker-broadcast-decision](../bunker-broadcast-decision/)'s `pabunkercontrol.xaml`, which now owns that file) |
| Dynasty cards | 30 tall |

Semantic greens are left alone, e.g. ladder qualifiers, the kicking power
meter and event highlights.

## Start screen

`title_screen.py` rebuilds the start screen ("press start", the `LogoRSV` panel and the visual states in
`views/background/menubackgroundview.xaml`):

- Herbie (`resources/rl26-revamp/main-menu-herbie.png`) bottom-left and Jesse (`main-menu-jesse.png`)
  bottom-right. Each sits in its own `baResolutionScaledViewbox` anchored to its bottom corner, so wider screens
  push them apart instead of cropping them.
- Behind each player, two smoke puffs (`resources/smoke.png`, one white Image and one revamp-blue Rectangle
  masked by it) drift, rotate and breathe forever.
- Behind the smoke, a stadium backdrop (`resources/rl26-revamp/bg.png`, `TitleBgVB`) that always fills the screen
  height at any aspect ratio. A `-2000` side margin (`BG_SIDE_BLEED`) widens its layout slot, so the Uniform scale
  is set by height alone. On screens narrower than the image (~1.89:1, e.g. 16:9) the faded oval sides crop
  slightly. It fades in and out with the players (`BG_OPACITY`).
- The logo and the `PRESS |ACCEPT| TO CONTINUE` prompt share a soft drop shadow (`LOGO_SHADOW`, a `DropShadowEffect` on each).
- The revamp logo (240 tall) is centred between them, with `PRESS |ACCEPT| TO CONTINUE` under it (`|ACCEPT|` is
  the accept glyph for the active pad or keyboard) pulsing gently.
- **In:** `TitleIntroSB` slides Herbie in from the left and Jesse from the right, a beat apart. It plays when
  `VisualStateKey` becomes `"title"`, which skip-intro-to-main-menu's `waitforsignin_state.lua` sets as the
  splash screens are torn down. The `SignOn` state only hides them, because the view enters SignOn on Loaded,
  behind the splash, and nothing in the game ever sets `"signon"`. A SignOn slide-in was never seen (first
  in-game test, 2026-10-27).
- All animations target the named viewboxes `TitleHerbieRSV` / `TitleJesseRSV` (Opacity, Margin), like stock's
  `LogoRSV` / `RightLinesSP`.
- **Out:** every other state (`Main`, `MainNoTitles`, `Data`, `DataNoFloor`, `TeamSelect`) pushes them off
  sideways and fades them in 0.5 s, while the stock fade takes the logo out and the home screen slides its menu
  in (main-menu-revamp's `MenuStackEnter`).
- The images are **new** textures appended to the blobset
  (`noesis/workspace/images/background/rl26revamp_title_{herbie,jesse,smoke,smoke_blue,bg}.texture`). A static XAML
  `Source="....png"` never drew them in game, so they're bound the way stock binds career club logos.
  `nvm_background.lua` (a generated `LUA_EDITS` override) adds `Title*Image` properties
  (`native.CNoesisTextureSource`) and `loadTitleArt` / `updateTitleArt`. Those load each texture, wait for
  `isLoaded()`, wrap it, then unload. XAML binds `Source="{Binding TitleHerbieImage}"`. The blue smoke is baked
  into its own texture, so no ImageBrush binding is needed. The smoke gets a radial alpha fade, because the source
  PNG's alpha doesn't reach zero at its border.
- Layout knobs (sizes, positions, smoke, slide distances) are the constants at the top of `title_screen.py`.
  `--preview <png>` renders a static 1920x1080 mock-up to check a change before launching the game.

With `skip_intro = true` (skip-intro-to-main-menu) the start screen is skipped entirely.

## Chroma-key backdrop

`make_branding.py` also adds a hidden full-screen `ChromaKeyBackdrop` rectangle as the last child of
`menubackgroundview.xaml`'s RootGrid, plus `ChromaKeyVisible` / `ChromaKeyColour` properties and
`NVMBackground.setChromaKey({r, g, b} | nil)` in `nvm_background.lua`. storm-celebration-viewer's Backdrop
option uses it for blue / green screen thumbnails.

## Rebuild / install

The XAML and DDS are generated, so don't hand-edit them. Rerun the
generator instead (it needs `pip install potracer`):

```powershell
python tools\pack.py restore --entry xamls
python tools\extract_m3mp.py --entry xamls --out <tmp>
python mods\rl26-revamp-branding\make_branding.py --extracted <tmp>
python tools\build.py full --list manifests\xamls.xml --extracted <tmp> --out _build\xamls.m3mp --confirm
python tools\pack.py restore --entry scripts
python tools\build.py full --confirm
python tools\texture_mods.py apply --mod rl26-revamp-branding --confirm
python mods\rl26-revamp-branding\title_screen.py --add-art --confirm
```

make_branding.py can also run from the stock blob backup instead of a fresh extraction: decode
`_backup/entry_57662.blob.bak` with `extract_m3mp.decode_m3mp`.

To uninstall, run `pack.py restore --entry v5887:57399` (the title textures go with `add_entries.py remove-all`), move this folder out of
`mods\`, then rebuild 57662.
