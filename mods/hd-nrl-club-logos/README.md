# hd-nrl-club-logos

Replaces 95 club emblems with HD renders of the current nrl.com vector badges
(`resources/nrl-site-logos/<comp>/<team>/`, pulled by `tools/nrl_site_logos.py`) and, for British clubs,
Gallery of League's ~1000px PNGs (`resources/gallery-of-league-logos/<section>/<club>/badge.png`, pulled by
`tools/gol_logos.py`). Layouts come from
`tools/club_icons.py`, but the stock entries are **replaced**, not appended.

| Comp | Icons | Source folder |
|---|---|---|
| NRL | all 17 `nrl_*` clubs | `nrl/` |
| NSW Cup | `nsw_bears`, `nsw_jets`, `nsw_westernsuburbs` | `nswrl/` |
| QLD Cup | `qld_capras`, `qld_clydesdales`, `qld_cutters`, `qld_dolphins`, `qld_falcons`, `qld_gullsmanly`, `qld_hunters`, `qld_jets`, `qld_magpies`, `qld_seagulls`, `qld_tigers` | `qrl/` |
| State of Origin | `rep_nsw` (Blues), `rep_qld` (Maroons) | `state-of-origin/` |
| Internationals (crest icons) | `rep_australia_2`, `rep_nz_2`, `rep_england_2`, `rep_fiji_2`, `rep_france_2`, `rep_ireland_2`, `rep_lebanon_2`, `rep_png_2`, `rep_scotland_2`, `rep_usa_2`, `rep_wales_2`, `rep_cookislands_2`, `cookislands` | `world-cup/` (2026 + 2022 + 2017 World Cups) |
| | `rep_tonga_2` (Mate Ma'a Tonga) | `internationals/` |
| Women's internationals | `rep_australia_w`, `aus_jillaroos` (Jillaroos), `rep_png_w` (PNG Orchids 50 years) | `womens-world-cup/` |
| Super League | `sl_castleford`, `sl_catalans`, `sl_huddersfield`, `sl_hullfc`, `sl_hullkr`, `sl_leeds`, `sl_leigh`, `sl_salford`, `sl_sthelens`, `sl_wakefield`, `sl_widnes`, `sl_wigan` | `gol/...` |
| Super League Women | `slw_huddersfield`, `slw_leeds`, `slw_leigh`, `slw_sthelens`, `slw_wigan` (club crests) | `gol/...` |
| Championship (`king_*`) | London Broncos, Batley, Bradford, Sheffield, Featherstone, Halifax, Rochdale, Hull KR, Swinton, Oldham, Toulouse, Dewsbury | `gol/...` |
| League One (`king1_*`) | All Golds, Coventry, Keighley, North Wales, Doncaster, Hunslet, Midlands, South Wales, York, Barrow, Skolars, Hemel, Newcastle, Goole, Whitehaven, Workington | `gol/...` |

`TEAMS` in `generate.py` maps each icon to its folder.

**Kept stock:**
- No logo on nrl.com: `nsw_magpies` (Wentworthville), `nsw_mounties`, `nsw_seaeagles` (Blacktown Workers),
  `qld_pride`, `rep_city`, `rep_country` and the women's Origin `soow_*`.
- Only a one-colour silhouette on nrl.com: `qld_bears`, `qld_blackhawks`, `nsw_blackhawks`, `qld_devils`.
- NSW Cup sides of NRL clubs use the `nrl_*` icons, so they're already covered.
- The plain `rep_<nation>` icons are flag shields, so they stay as they are.
- Only a 336px PNG on nrl.com: Samoa, the new Tonga logo, Kiwi Ferns, Fiji Bulikula, Malta and PNG PM's XIII.
  Their icons (`rep_samoa_2`, `rep_nz_w`, `nz_ferns`, `rep_fiji_w`, ...) keep stock.
- The `world-cup-2021-*` themes (Greece, Italy, Jamaica, Brazil, Canada) are tournament artwork, not team crests.
- `rep_nz_3`, `rep_italy_2`, `canada_ravens`, `maori`, `rep_indigenous` and `rep_allstars` have no match on nrl.com.
- Junior Kangaroos, Junior Kiwis and the PM's XIIIs have no game icon.
- British: `sl_warrington` / `slw_warrington` (the current logo is the 150-year anniversary badge),
  `king_centurions` (the old Leigh Centurions), `king1_oxford`, `slw_barrow` (Raiders Ladies) and
  `slw_valkyrie` have no usable Gallery of League logo.
- The `slw_*` icons have no dynasty texture, so they get 7 replacements each.

**Eels and Sea Eagles:** nrl.com only has their 80-year anniversary badges, so `LOGO_OVERRIDE` points them at
hand-supplied 1280x1280 images in their folders: `eels/proper-logo.webp` and `sea-eagles/manly-proper.webp`.
The Sea Eagles variants shown over dark backgrounds use `manly-proper-light.png`: the same logo with its
text (rows 944+) turned white. The white field tile keeps the maroon text.
These are used for every variant except the dynasty shield.

## What's replaced (10 textures per icon, plus strips for every other icon: 1225 total)

| Variant | Stock size | New size | Source |
|---|---|---|---|
| `ui/club_logos/64`, `small` | 64², 172x192 | 2x | `badge-light.svg`, else `badge.svg` |
| `ui/club_logos/large_mirrored` | 308x312 | **1232x1248** (`VARIANT_SIZE`) | `badge-light.svg`, else `badge.svg` |
| `ui/club_logos/bg_logo/<icon>_l`, `_r` | 420x496 | 2x | `badge-light.svg`, else `badge.svg` |
| `noesis/.../club_logos/256` | 256² BC7 | 512² BGRA | `badge-light.svg`, else `badge.svg` |
| `ui/club_logos/field` (white tile) | 160x128 | 2x | `badge.svg` (light badges vanish on white) |
| `noesis/.../dynasty/icons/club_logos` (shield) | 256² BC7 | 512² BGRA | `badge-basic24(-light).svg`, zoomed on a detail |
| `ui/club_logos/hud_player`, `noesis/.../club_logos/advance_tile` (wide club-list strips) | 168x64, 360x140 BC7 | 2x | the whole logo fitted as big as the strip allows (`STRIP_BOX`), centred on a team-colour gradient (the logo that contrasts more with the fill) |

- `NO_LIGHT`: Dolphins, Dragons and the Kangaroos always use `badge.svg`, because their light badges are plain white.
- Roosters and Titans have no `badge-light`, so they use `badge.svg` everywhere.
- British clubs use their single `badge.png` everywhere. Hull FC and Newcastle Thunder are all-white logos,
  so `LOGO_OVERRIDE` gives the white field tile a near-black copy (`badge-dark.png`).
- **Dynasty shield:**
  - The fill is the stock shield's most common colour.
  - The badge is whichever of `badge-basic24` and `badge-basic24-light` contrasts more with that fill.
    Clubs without a basic badge (all the NSW, QLD and Origin ones) choose between `badge` and `badge-light`.
  - It's zoomed on a key detail (face, eye, visor) set per club in `DYNASTY_FOCUS`: x and y as fractions
    of the badge, plus the zoom as a multiple of the shield's inner height.
  - `DYNASTY_FILL` overrides the fill: Scotland's single-blue logo sits on a white shield, and the All Golds'
    gold fern sits on black.
  - `DYNASTY_SOURCE` overrides the file. The Cowboys' basic badge has no star, so their shield crops
    `badge.svg`. The Eels' basic badge is the anniversary one, so theirs crops `proper-logo.webp`.
  - The Sea Eagles' shield uses their basic badge, which has no anniversary marks.

**Not replaced:** the licensed hand-made crops (`plinths`, `flags`, `hud_intro`, `hud_lineup`) keep their stock art. `hud_score` belongs to
[nrl-broadcast-scoreboard](../nrl-broadcast-scoreboard/README.md).

## Rebuild / install (game closed)

`generate.py` reads the stock textures from the live blobset, so restore this mod's entries first. Restore them
newest first:

```powershell
python -c "import sys; sys.path.insert(0,'tools'); import texture_mods as tm, pack; [pack.do_restore(pack.BLOBSET_PATH, e) for e in sorted((e for e, v in tm.scan_texture_mod_overrides().items() if v[1] == 'hd-nrl-club-logos'), reverse=True)]"
python mods\hd-nrl-club-logos\generate.py            # every icon (or list some, e.g. qld_capras); --scale 1 = stock sizes
python tools\texture_mods.py apply --mod hd-nrl-club-logos --confirm
```

`previews/<icon>.png` show stock (top) against new (bottom).

## Team loading screen (exe patch)

The team loading screen doesn't draw the logo texture directly. `native.setTeamsLoadingProps` point-copies
each team image (nearest sampling, no filtering) into a native render target, `homeTeamTexture` /
`awayTeamTexture`. The exe hard-codes that target at 308x312, the stock `large_mirrored` size. The XAML
then stretches it to fill the logo box: 542x550 of the 1080p layout in stock, 680x688 with
[loading-screen-secondary-arrows](../loading-screen-secondary-arrows/README.md) (`LOGO_SIZE`), which is 1360x1376 at 4K. Without the patch, any bigger logo is
crushed back to 308x312 and looks jagged. This was measured in-game with a stripe chart: the 1, 2 and 3px
stripes aliased exactly as a 308px copy predicts.

`install.py` patches the 3 sites that set that size (found by pattern) to 1232x1248. `large_mirrored` ignores
`--scale` and is always rendered at exactly that size (`VARIANT_SIZE`, including the icons whose stock
canvas is 304 wide), so the copy is 1:1. Stock logos this mod doesn't cover are quadrupled by the same point copy.
They keep stock detail, just with blockier edges. `unlock-all-kits/launch.py` re-applies the patch on every
launch, and the installer's exe step applies it too.

```powershell
python mods\hd-nrl-club-logos\install.py --apply     # --status / --restore (also upgrades an older 924x936 patch)
python mods\hd-nrl-club-logos\generate.py --variants large_mirrored
```

The other users of `large_mirrored` (the scoreboard and the crowd-flags build) size the image themselves.

## Risk

The canvases are 2x the stock size with the same aspect ratio. Screens that size the image themselves get
the extra detail. A screen that shows a logo at its natural pixel size would draw it twice as big. If that
happens, rebuild with `--scale 1`: it still gets the clean vector render, and the 256/dynasty files lose
their BC7 compression artefacts.

## Strips for every icon (`--all-icons`)

The club lists show `hud_player` / `advance_tile` for every club icon, not just the 95 above. `--all-icons`
also writes those two strips for the other 142 icons that ship them. The logo comes from the icon's own stock
`large_mirrored` texture, and the fill from its stock dynasty colour. That covers Warrington, the
women's sides, the flags, the generic and holiday emblems and the icons appended by
[new-club-icons](../new-club-icons/README.md).

```powershell
python mods\hd-nrl-club-logos\generate.py --all-icons --variants hud_player advance_tile
```

The appended icons (`nrl_bears`, `nrl_chiefs`, `nrl_*_classic_*`) are replaced like stock entries. After
re-rendering them with `club_icons.py add --replace`, run `--all-icons` again and reinstall.
