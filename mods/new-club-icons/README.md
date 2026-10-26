# new-club-icons

Adds brand-new club emblems, selectable in the academy emblem picker (and anywhere else club icons
are listed): `nrl_bears` (North Sydney Bears), `nrl_chiefs` (PNG Chiefs), and 24 **classic** pre-rebrand
NRL emblems (`nrl_<club>_classic_<n>`, shown as e.g. "Parramatta Eels Classic #2"). These are **new files**,
not replacements. How that works is in [research/adding-new-assets.md](../../research/adding-new-assets.md).

## Pieces

| Part | Where | Installed by |
|---|---|---|
| 15 textures per icon (`ui/club_logos/*/<icon>`, `noesis/.../club_logos/{256,advance_tile}/<icon>`, `noesis/.../dynasty/icons/club_logos/<icon>`) | appended blobset entries | `tools/club_icons.py add` |
| icon names appended to `ClubIconsPreload` / `ClubIcons` / `ClubIconsNoDlc` (the `ModClubIcons` list) | `src/script-game/intermediatelua/convant/clublist.lua` | `build.py` (entry 39959) |
| colour set per icon (`ClubIconColourSetMap`, generic sets like `dark_red`, `gold`) | `src/script-game/intermediatelua/convant/icons.lua` | `build.py` (entry 39959) |
| scoreboard crest (`hud_score`) in the nrl-broadcast-scoreboard style | `resources/scorebug_img/<icon>.png` | `club_icons.py add --hud-score-image` |
| display names (`ModClubIconLabels`, served by wrapping `native.Localise` for `Club_<icon>` keys) | `icons.lua` | `build.py` (entry 39959) |
| classic emblems: icon / source / label / fill table, batch scorebug + preview + add | `classic_logos.py` | run by hand |

Source logos are in `resources/new-team-logos/`. Rendered previews of every installed texture are in
`resources/new-team-logos/previews/`.

The new names go at the **end** of every list, so no shipped icon changes position.
`preloadassets.lua` registers `ClubIconsPreload` with the native `CIconNames`, which builds the texture
paths from the names.

## Classic emblems

Sources are in `resources/new-team-logos/classic-nrl-logos/`, numbered oldest first per club. Everything
is driven by the `CLASSICS` table in [classic_logos.py](classic_logos.py), which must stay in step with
`ModClubIcons` (clublist.lua) and `ClubIconColourSetMap` / `ModClubIconLabels` (icons.lua). Each one
reuses its club's colour set. Install (game closed):

```powershell
python mods\new-club-icons\classic_logos.py scorebug      # regenerate resources\scorebug_img\nrl_*_classic_*.png
python mods\new-club-icons\classic_logos.py preview       # resources\new-team-logos\previews\classic_sheet.png
python mods\new-club-icons\classic_logos.py add --confirm # 24 x 15 appended textures (--replace to re-render)
python tools\pack.py restore --entry 39959
python tools\build.py full --confirm
```

## Adding another emblem

```powershell
python tools\club_icons.py preview --icon nrl_newteam --image logo.svg --out sheet.png
python tools\club_icons.py scorebug --image logo.svg --out resources\scorebug_img\nrl_newteam.png   # optional, NRL clubs
python tools\club_icons.py add --icon nrl_newteam --image logo.svg --hud-score-image resources\scorebug_img\nrl_newteam.png --confirm
```

1. Add `"nrl_newteam"` to `ModClubIcons` in `clublist.lua`.
2. Add `nrl_newteam = "<colour set>"` to `ClubIconColourSetMap` and `Club_nrl_newteam = "Name"` to
   `ModClubIconLabels` in `icons.lua`.
3. Rebuild 39959: `pack.py restore --entry 39959`, then `build.py full --confirm`.

Use `--replace` to re-render an emblem that was added before (in place, no rebuild needed).

## Known gaps
- Labels come from the Lua `native.Localise` wrapper. A few screens cache `native.Localise` in a local at
  load time (e.g. career club select). If such a file loads before icons.lua, it would still show the raw
  `Club_<icon>` key. The academy emblem picker and club identity screens call it live.
- Licensed NRL clubs have hand-drawn alternates for some variants (e.g. single-colour logos); the
  tool uses the measured generic layouts instead.

## Undo
`python tools\add_entries.py remove-all --confirm` removes every appended texture. Do it after
restoring any entry installed later; the tool says so if needed. Then move this folder out of `mods\`
and rebuild 39959.
