# about-rl26-revamped

Adds an **About RL26 Revamped** tile to the Extra row of the home screen, right after
Credits. It opens a credits-style scrolling page with the revamp credits, AI usage
statement, piracy and privacy notices, and a disclaimer.

Needs script bundle **39959**, Noesis bundle **57662** and two new texture entries added by
`make_logos.py`. The page text is in `settings_creditsstate_company_external.lua` (`var_0_5`).

## How it works

- **Page**: reuses the stock credits roll (`SettingsCreditsCompany` and the
  `Workspace/Views/Credits/Credits` view) with its own `Credits` table. The redeem-code
  prompt is removed. Rows don't wrap, so each string is one complete, short line. Don't split
  a sentence across rows, because every row is centred on its own.
- **No new files**: `build.py` can't add script files, so the code lives in
  `app/settings/settings_creditsstate_company_external.lua`. The stock game never loads
  that file (the credits only roll the Big Ant page). `settings_credits_state.lua` is stock
  plus one `import` at the end, which loads it.
- **Tile**: coach-editor already overrides `homescreenstate_config.lua`, so this mod doesn't
  touch it. It wraps `createFirstPageTiles` instead. `homescreenstate_config` imports
  `settings_credits_state` before it defines that function. If the config module is loading
  when this file runs, the hook finds its env on the call stack (`getfenv`) and wraps on a
  one-shot `__newindex`. Otherwise it wraps `_G.import` to catch the module when it loads.
  `LOADED` can't be used: it is private to `import.lua`, and reading it crashed the game at
  boot.
- **XAML slot**: Noesis drops tiles that have no named button. `paextratilerow.xaml`
  already has a spare `NTS` button after Credits (the dev-only Noesis test tile, which
  needs `-noesisTest`), and `ExtraNVM` already binds it. The tile uses
  `dataContextKey = "NTS"`, and the XAML override only gives that button an "info" icon.
  Without the XAML override the tile still works, but it shows the Credits icon.
- **Logos**: the page shows three logos with the same layout as the stock credits. The
  RL26 Revamped logo is at the top, and Big Ant's and Galaxsi Studios' logos head their
  sections. The Big Ant one is the stock `credits/bigant` texture, unchanged. The other two
  are NEW entries added by `make_logos.py` (no stock art is replaced):
  - `credits/rl26revamped`, from `resources/rl26-revamp/rl26-revamped-logo.png`.
  - `credits/galaxsi`, from `resources/rl26-revamp/gs-logo-light-long.svg`, used as supplied
    but filled white (the source is dark, for light backgrounds).

  Both are uncompressed premultiplied BGRA, like the other added UI textures. A missing entry
  just leaves a gap on the page.
- **Watermark**: the stock credits view has a faded Big Ant mark behind the roll (a white
  `Path` at 10% opacity). The About page swaps in its own copy of that view, so the real
  Credits screen keeps Big Ant's. `make_logos.py watermark` copies `views/credits/credits.xaml`,
  traces the GS mark (`resources/rl26-revamp/galaxsi-studios-logo.svg`, the mark on its own,
  as the stock watermark is the ant without the wordmark) into that `Path` (same fill and
  opacity, 640 wide) and writes the copy as `views/testscreens/dynastycardtest.xaml`. Only the
  dev-only `NoesisTestState` (`-noesisTest`) uses that file, and the About tile already
  borrows its slot. `SettingsCreditsCompanyRevamp.enter` is a copy of the stock enter that
  loads the copy directly, falling back to the stock view if it doesn't load. An earlier
  version loaded the stock view, released it and loaded the copy with the same view model,
  and that gave a blank page.

## Files

| File | Bundle | Change |
|---|---|---|
| `src/script-game/app/settings/settings_creditsstate_company_external.lua` | 39959 | About page, its state, and the tile wrap |
| `src/script-game/app/settings/settings_credits_state.lua` | 39959 | stock file, plus an import of the file above |
| `noesis/workspace/views/homescreen/paextratilerow.xaml` | 57662 | info icon on the `NTS` slot |
| `noesis/workspace/views/testscreens/dynastycardtest.xaml` | 57662 | About copy of the credits view with the Galaxsi watermark (generated) |
| `make_logos.py` | new entries, 57662 | `install` adds `credits/rl26revamped` and `credits/galaxsi`; `watermark` writes the view above; `preview` writes PNGs |

## Install

```powershell
# script bundle (all script mods together)
python tools\build.py full --confirm

# Noesis bundle: build from a fresh extraction of stock 57662
python tools\pack.py restore --entry xamls
python tools\extract_m3mp.py --entry xamls --out <tmp>\57662
python mods\about-rl26-revamped\make_logos.py watermark --extracted <tmp>\57662   # only if the logo changed
python tools\build.py full --list manifests\xamls.xml --extracted <tmp>\57662 --out _build\xamls.m3mp --confirm

# logos: new entries (needs pip install resvg-py potracer); rerun to update them in place
python mods\about-rl26-revamped\make_logos.py install --confirm
```
