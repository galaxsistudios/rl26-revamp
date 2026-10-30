# nrl-led-boards

The stadium LED ribbons (field-level ring and stand fascia) show the **home club's** board at any ground
that has LED panels. A board is the team's 4 sponsors, then its competition's 4, then the mod's 2
(RL26 Revamp, Galaxsi Studios).

## Config

**Sponsors, each once** (`config/sponsors/`), shared by every board that lists them:
- `<id>.png`: the finished 2048x128 row, exactly what shows on the LED. This is the installed art.
- `logos/`: the source logos.
- `sponsors.json`: each sponsor's recipe (logo or stock LED row, background, repeat, margin, source).

`python mods/nrl-led-boards/install.py rows [id ...]` remakes the PNGs from the recipes. Without an
explicit background/repeat it uses the logo's own tile colour (or white/near-black by brightness) and
repeats the logo until the row is filled. `"manual": true` marks a hand-made PNG (the Revamp and Galaxsi
rows), which is never overwritten. `install.py sheet` writes every row on one page
(`_build/nrl-led-boards/sponsors.png`).

**Boards** (`config/boards/<name>/board.json`) list sponsor ids in order:

| Folder | Type | Holds |
|---|---|---|
| `default/` | default | the mod's sponsors (on every board), timing, row order, fallback competition |
| `nrl/` | competition | Telstra, KFC, DrinkWise, Kayo + the stadium `sponsorTypes` it covers |
| `broncos/`, `bulldogs/`, ... (17 clubs) | team | 4 sponsors, `competition`, the club full names it matches |

Each team board opens with a **club row** (`config/boards/<team>/club.png`, from the board's `identity`): the
club badge and its official wordmark (both from `resources/nrl-site-logos/nrl/`), the wordmark recoloured
to the club's secondary colour, on its primary colour. Colours come from the game's club data
(`primaryRGBColour` / `secondaryRGBColour`), except that the Roosters are swapped to navy + red and the
Warriors' green is brightened to read on navy. `install.py rows --clubs` remakes them.
Badges are drawn larger than the row and cropped top and bottom. Seven clubs use the NRL's text-free
`badge-basic24` mark so the crop doesn't cut words. Eight clubs (Cowboys, Dolphins, Raiders, Roosters,
Storm, Titans, Eels, Wests Tigers) instead use `focus: {"eye": [x, y], "span": h}`: the badge fills
the left `badge_width` (0.4) of each half, zoomed to show h of its height centred on the eyes, with its
edges faded. The wordmark fills the rest. `nudge: [dx, dy]` (row pixels) shifts the logo inside its area.

Team sponsors are each club's top four partners by tier on its official partners page (2026-10-30). Gambling,
casino and lottery partners are left out (The Star, TAB, Betr, Palmerbet, Picklebet, Unibet, PointsBet,
Nextbet, KenoGo, The Lottery Office), as are leagues clubs (poker-machine venues). The Rabbitohs list is the
user's own (MG, Budget Direct, Menulog, Hostplus).

Logos come mostly from those partners pages. The ones that were only square or stacked there come from the
brand's own site where it has a horizontal version (Bravus, Budget Direct, Squadron, McDonald Jones,
Toyota Forklifts, Shaw and Partners, 4 Pines, Voltx, Ocean Protect, MG). Kia, Hostplus, Telstra and KFC
are rows from the game's own NRL LED texture (stock rows are counted in `resources/LED Boards/lcd/`).

**Event boards** (`"type": "event"`) replace the team board for special games. Each has a `priority`,
a `match` (any of: `specialEvent`, `competition`, `fieldMarkings` enum names, `ground` keys, `isFinal`),
optional `sponsorTypes` (the ground's must be one of them), and its `sponsors`. The default board's rows
always follow.

| Folder | Priority | Matches | Rows |
|---|---|---|---|
| `grand_final/` | 1 | GrandFinal event, NRL_GrandFinal(_Post2017) markings; NRL grounds | GF logo, Accor, Telstra, KFC, Hostplus, Kia |
| `finals/` | 2 | Qualifying/Elimination/Semi/Preliminary/Final events, `isFinal`, NRL_Finals markings; NRL grounds | Finals Series logo, Westpac, Telstra, KFC, Hostplus, Kia |
| `state_of_origin/` | 3 | Tournament_StateOfOrigin, NRL_Rep_StateOfOrigin markings | Origin logo, Westpac, Accor, Ampol, Harvey Norman, Telstra, KFC |
| `magic_round/` | 4 | MagicRound event, NRL_Season_Tuesday (Play Now Magic Round markings) | Magic Round logo, Telstra, KFC, Hostplus, Kia |
| `vegas/` | 5 | Vegas event, NRL_Season_Wednesday (Las Vegas markings), Allegiant Stadium | Las Vegas logo, Allegiant, JD Sports, Telstra, KFC |

Which board loads, per match: the first matching event board, else the home club's team board, else the
competition board for the ground's `sponsorType`, else `default`. Challenge Cup, Women's Super League and
RLWC matches keep the stock boards (so does Magic Round if its event board is removed). Grounds without LED panels (Penrith Stadium, Leichhardt, Campbelltown, WIN Stadium, Port
Moresby and most UK grounds) are unchanged.

## How it works

- LED panels use the `es2_lcdsign` shader: the texture is a grid of `gridRows` rows (2048x128 each, 16:1).
  The panel shows one row, holds it `persistTime` (5 s), then wipes/fades to the next over `transitionTime`
  (0.5 s). Each stock material carries its own `gridRows` / `gridRows_active` (Knights 4/3, NRL 8/8, Accor 12/9).
- `stadiumconfig.lua` picks the board in `getStadiumModelFilenames` (it has the match data) and passes it
  in the stadium model table. `stadiummodel.lua` loads the texture with the stadium. Once everything has
  loaded (an asset-join callback) it sets `col_map` and the row parameters on every `lcdsign` material.
  The game does the same `col_map` swap for the intro team shields.
- Logs to `ledboards_debug.txt` in the game folder: board name, row count, LED materials touched, and any
  row parameter `setFloat` rejected.

## Building

    python mods/nrl-led-boards/install.py build [--texconv PATH]   # previews in _build/nrl-led-boards/
    python mods/nrl-led-boards/install.py install --replace --confirm
    python mods/nrl-led-boards/install.py lua                      # club -> board table (installed boards only)

then rebuild the script bundle. `install_revamp.py`'s `led-boards` step does all three before `scripts`.

## Status

Installed 2026-10-30, untested in game.
