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
| Title screen | 500 tall, in a panel widened from 1200x350 to 1600x700 |
| Menu corner | 250x72, moved up from y=100 to y=70 to clear the featured slider |
| Bunker banner | 525x150 |
| Dynasty cards | 30 tall |

Semantic greens are left alone, e.g. ladder qualifiers, the kicking power
meter and event highlights.

## Rebuild / install

The XAML and DDS are generated, so don't hand-edit them. Rerun the
generator instead (it needs `pip install potracer`):

```powershell
python tools\pack.py restore --entry 57662
python tools\extract_m3mp.py --entry 57662 --out <tmp>
python mods\rl26-revamp-branding\make_branding.py --extracted <tmp>
python tools\build.py full --list manifests\57662.xml --extracted <tmp> --out _build\entry_57662.m3mp --confirm
python tools\pack.py restore --entry 39959
python tools\build.py full --confirm
python tools\texture_mods.py apply --mod rl26-revamp-branding --confirm
```

To uninstall, run `pack.py restore --entry 57399`, move this folder out of
`mods\`, then rebuild 57662.
