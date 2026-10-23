# new-club-icons

Adds brand-new club emblems, selectable in the academy emblem picker (and anywhere else club icons
are listed): `nrl_bears` (North Sydney Bears) and `nrl_chiefs` (PNG Chiefs). These are **new files**,
not replacements. How that works is in [research/adding-new-assets.md](../../research/adding-new-assets.md).

## Pieces

| Part | Where | Installed by |
|---|---|---|
| 15 textures per icon (`ui/club_logos/*/<icon>`, `noesis/.../club_logos/{256,advance_tile}/<icon>`, `noesis/.../dynasty/icons/club_logos/<icon>`) | appended blobset entries | `tools/club_icons.py add` |
| icon names appended to `ClubIconsPreload` / `ClubIcons` / `ClubIconsNoDlc` (the `ModClubIcons` list) | `src/script-game/intermediatelua/convant/clublist.lua` | `build.py` (entry 39959) |
| colour set per icon (`ClubIconColourSetMap`, generic sets like `dark_red`, `gold`) | `src/script-game/intermediatelua/convant/icons.lua` | `build.py` (entry 39959) |
| scoreboard crest (`hud_score`) in the nrl-broadcast-scoreboard style | `resources/scorebug_img/<icon>.png` | `club_icons.py add --hud-score-image` |

Source logos are in `resources/new-team-logos/`. Rendered previews of every installed texture are in
`resources/new-team-logos/previews/`.

The new names go at the **end** of every list, so no shipped icon changes position.
`preloadassets.lua` registers `ClubIconsPreload` with the native `CIconNames`, which builds the texture
paths from the names.

## Adding another emblem

```powershell
python tools\club_icons.py preview --icon nrl_newteam --image logo.svg --out sheet.png
python tools\club_icons.py scorebug --image logo.svg --out resources\scorebug_img\nrl_newteam.png   # optional, NRL clubs
python tools\club_icons.py add --icon nrl_newteam --image logo.svg --hud-score-image resources\scorebug_img\nrl_newteam.png --confirm
```

1. Add `"nrl_newteam"` to `ModClubIcons` in `clublist.lua`.
2. Add `nrl_newteam = "<colour set>"` to `ClubIconColourSetMap` in `icons.lua`.
3. Rebuild 39959: `pack.py restore --entry 39959`, then `build.py full --confirm`.

Use `--replace` to re-render an emblem that was added before (in place, no rebuild needed).

## Known gaps
- Labels show as raw `Club_nrl_bears` / `Club_nrl_chiefs`, because there's no localisation entry yet.
- Licensed NRL clubs have hand-drawn alternates for some variants (e.g. single-colour logos); the
  tool uses the measured generic layouts instead.

## Undo
`python tools\add_entries.py remove-all --confirm` removes every appended texture. Do it after
restoring any entry installed later; the tool says so if needed. Then move this folder out of `mods\`
and rebuild 39959.
