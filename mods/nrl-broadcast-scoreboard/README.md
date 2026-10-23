# nrl-broadcast-scoreboard

Restyles the default in-game scoreboard (DefaultHUDResources `ScoreCardTemplate`,
used for NRL and every competition without its own HUD theme) into the NRL
broadcast layout:

`[crest][ABR][score] | [score][ABR][crest][1ST HALF / clock][tackle]`

Touches three bundles - build/install each one (see INSTRUCTIONS.md):

| Files | Entry |
|---|---|
| `src/script-game/sim/hud/hud.lua`, `src/script-game/app/noesis/util/nvm_team.lua` | 39959 (scripts) |
| `noesis/workspace/fonts/*.ttf` | 39962 (Noesis fonts) |
| `noesis/workspace/resources/fonts.xaml`, `.../stylethemes/hud/defaulthudresources.xaml` | 57662 (Noesis XAML) |

## Crests

Uses the game's unused `ui/club_logos/hud_score/<icon>.texture` crops (48x80
portrait, one per club icon - shipped alongside `hud_intro`/`hud_player`/
`hud_lineup` but never loaded). `hud.lua` loads them into a new
`NVMTeam.ScoreLogo` binding. Custom (decal) clubs have no icon and fall back
to the normal `TeamLogo`.

The crest columns are drawn at full bar height (45) with their width taken from
the texture's aspect ratio, and the team-name columns absorb the difference, so
replacement `hud_score` textures can be any shape (texture_mods.py).

Sin-bin / send-off counters sit behind the team panel (as in stock); each card
slides up 8px when added so only active cards show, above the bar.

### Custom crest textures (`textures/`)

`textures/<entry>_hud_score_<icon>.dds` replace the 17 NRL `hud_score`
textures (entries 101054-101070), made from `resources/scorebug_img/*.png`:
512x512 -> 128x128 (no mipmaps, so full res would alias at ~45px),
premultiplied alpha (stock hud_score textures are premultiplied), stored as
uncompressed 32-bit BGRA DDS like the stock files.

Install (`--mod` skips other mods' already-installed textures):

```powershell
python tools\texture_mods.py apply --mod nrl-broadcast-scoreboard --confirm
```

Restore with `python tools\pack.py restore --entry <N>`.

### New clubs (mods/new-club-icons)

Clubs added by [mods/new-club-icons](../new-club-icons/README.md) (`nrl_bears`, `nrl_chiefs`) have no
stock entry to replace. Their `hud_score` is an *appended* entry, written by `tools/club_icons.py`.
`hud.lua` loads `ui/club_logos/hud_score/<icon>.texture` for any icon, so they need no Lua or XAML
changes.

- Their art lives with the others: `resources/scorebug_img/nrl_bears.png`, `nrl_chiefs.png`.
- Drafts come from `club_icons.py scorebug` (flat team colour, logo zoomed to bleed off the edges). Hand
  edits are fine; the PNG is the source.
- Install (or reinstall after editing the PNG) with:

```powershell
python tools\club_icons.py scorebug --image resources\new-team-logos\nrl-bears.svg --fill "#e81838" --zoom 1.3 --dy 0.05 --out resources\scorebug_img\nrl_bears.png
python tools\club_icons.py add --icon nrl_bears --image resources\new-team-logos\nrl-bears.svg --hud-score-image resources\scorebug_img\nrl_bears.png --replace --confirm
```

`--hud-score-image` downsizes the art to 128x128 and premultiplies its alpha, the same as the textures
in `textures/`.

## Fonts

The exe hard-codes its Noesis font file list (`paNoesisFontProvider`), so new
files can't be added. Two stock jersey-name fonts are overwritten instead
(name records 16/17 stripped so the family lookup works):

| File | Now contains | Family | Used for |
|---|---|---|---|
| `hundreddisplay-regular.ttf` | JoyrideEXT.otf | `Joyride EXT` | scores, team abbreviations, 1ST/2ND HALF |
| `freeserifbolditalic.ttf` | Maison-Neue-Extended-Bold.ttf | `Maison Neue Extended Bold` | clock, tackle count |

Side effect: a jersey using the "Hundred Display" or "FreeSerif Bold Italic"
name font will print in Joyride / Maison instead.

`HalfAbbr` is mapped `H1`/`1ST` -> `1ST HALF` and `H2`/`2ND` -> `2ND HALF` in
XAML; anything else (golden point, extra time) shows as-is.
