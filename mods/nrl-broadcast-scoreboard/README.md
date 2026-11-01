# nrl-broadcast-scoreboard

Restyles the default in-game scoreboard (DefaultHUDResources `ScoreCardTemplate`,
used for NRL and every competition without its own HUD theme) into the NRL
broadcast layout:

`[crest][ABR][score] | [score][ABR][crest][1ST HALF / clock][tackle]`

Touches three bundles - build/install each one (see INSTRUCTIONS.md):

| Files | Entry |
|---|---|
| `src/script-game/sim/hud/hud.lua`, `src/script-game/app/noesis/util/nvm_team.lua`, `src/script-game/sim/hud/playerinfo_hud.lua`, `src/script-game/app/noesis/hud/nvm_playerplate.lua`, `src/script-game/app/noesis/hud/nvm_substitutionhud.lua`, `src/script-game/app/noesis/hud/nvm_penaltyhud.lua`, `src/script-game/sim/hud/penaltyselect_hud.lua`, `src/script-game/app/noesis/ingame/nvm_playerstatisticshud.lua`, `src/script-game/sim/hud/playerstatistics_hud.lua`, `src/script-game/design/ui/playerstatisticshud_config.lua` | 39959 (scripts) |
| `noesis/workspace/fonts/*.ttf` | 39962 (Noesis fonts) |
| `noesis/workspace/resources/fonts.xaml`, `.../stylethemes/hud/defaulthudresources.xaml`, `views/hud/rugby/pareplacementcontrol.xaml`, `views/hud/rugby/papenaltycontrol.xaml` | 57662 (Noesis XAML) |

## Player plate

`PlayerPlateTemplate` (same XAML file) is restyled into the broadcast lower third:
a slanted number box in the team's primary colour (number in `HudTextColour`),
a dark card with the name (Maison) over the position, and the stamina bar as an
underline coloured by `NVMPlayerPlate.StaminaLevel`: green >=60%, yellow >=40%,
orange >=20%, red below (thresholds in `nvm_playerplate.lua`).

- **Position**: `NVMPlayerPlate.PlayerPosition`, set every frame in
  `playerinfo_hud.lua` from the player's *current* role (`gamestate.roleInfoPool`,
  falling back to the lineup role). Names come from the stock `FullBack` / `Winger`
  / `Centre` / `FiveEighth` / `HalfBack` / `Prop` / `Hooker` / `SecondRow` / `Lock`
  strings. The stock scorer banner swaps halfback and five-eighth; this doesn't.
- **Animation**: two Int32 keys on `NVMPlayerPlate`, bumped by `refreshReveal` /
  `resetReveal` and played by `b:PropertyChangedTrigger`s. `RevealKey` = a hidden
  plate comes back: the box pops in (0-0.22s), then the card slides out from
  behind it (0.18-0.55s) and the text fades up. `SwitchKey` = a different player
  on a plate that's already up: box and card stay put, only the name/position
  slide in and the stamina bar wipes across. `HideKey` = the plate goes away: the
  intro in reverse (text fades, card slides back behind the box, box shrinks out,
  0.45s). playerinfo_hud.lua no longer writes `IsVisible`; it calls
  `setShown(bool)`, and `tick(dt)` (end of `PlayerInfoHud.update`) keeps the plate
  up until the outro has played (`var_0_outro_time`, keep in step with the XAML).
  Without the triggers the plate just
  shows fully, so a dead trigger degrades to a static plate.
- Other HUD themes (Origin, QLD Cup, Super League, RLWC) keep their own plates.

Full reveal confirmed in game 2026-11-01; the switch animation is untested.

## Quick interchange (d-pad)

`views/hud/rugby/pareplacementcontrol.xaml` is restyled to match the player plate, at
the same 400 width: a header plate (crest in the slanted team-colour box,
INTERCHANGE + forwards/backs, subs remaining, green underline), the on-field and
bench lists side by side as mini plates (jersey number box, name over full
position, stamina % + underline in the plate's four colours, injury icon), and a
button-hint bar. The list not being picked is dimmed (`ChoosingBench`).

- `nvm_substitutionhud.lua` adds `Position` (on-field: current spot via
  `PreferredRole_<assignedRole>`, e.g. Winger Left; bench: `PreferredRole_<primaryRole>`),
  `Number` (lineup shirt number), `StaminaValue`, `StaminaLevel`, plus `IsClosing` and
  `ChoosingBench` on the panel.
- Animations: intro on `isSubstitutionHudVisible`, lists slide down on
  `ManagingInterchange`, outro on `IsClosing`. `closeMenu` now keeps the panel up for
  0.35s (`var_0_outro_time`); `substitution_hud.lua` already refuses to reopen while
  `isClosing()`.
- Placement/size: it sits directly on the controlled player's (bottom) plate - the control
  lives in `LeftPlayerPlateGrid`/`RightPlayerPlateGrid` in **defence-tactics-hud's**
  `pagameplayhudcontrol.xaml` - and uses the same plain `baResolutionScaledViewbox` + 400
  width as the plate, so it renders at the plate's size (stock `DisableHeightScaling` drew
  it ~0.64x). The top plates (second local player) collapse when unused there.
- Green is hard-coded `#24DB61`: rl26-revamp-branding recolours `RLGreen` to the Revamp blue.
- The view loads under every HUD theme, so all its styles are local (only global
  resources like `FontFamily_ScoreMaison` and `HUD_*` are referenced).

Untested in game.

## Penalty choice

`views/hud/rugby/papenaltycontrol.xaml` is a horizontal lower third in the plate style:
crest in the slanted team-colour box, dark card with PENALTY | goal / tap / touch
(button glyphs, goal hidden when `ShowPenaltyGoal` is false), green underline. It sits
bottom centre, level with the plates (moved in defence-tactics-hud's
`pagameplayhudcontrol.xaml`). The stock controller-colour strip (`PartyMemberColour`)
is dropped.

- `nvm_penaltyhud.lua`: `RevealKey` (intro: box pops, card slides out, options pop in
  left to right) and `HideKey` (outro, reversed). `hide()` keeps `isVisible` for 0.35s
  (`var_0_outro_time`), counted down in `update(dt)`; `penaltyselect_hud.lua` now passes dt.

Confirmed in game 2026-11-01.

## Player statistics card

`PlayerStatisticsTemplate` (in `defaulthudresources.xaml`) uses the plate look: number in
the slanted team-colour box, name over position, crest on the right, green underline,
then the stat rows (dark cards with a team-colour edge, value in Maison on the right).

- The game's state logic reads `isPlayerStatisticVisible` and `clean()` wipes the data
  immediately (a new card can be built in the same call). So `show()` copies everything
  to `ShownName/ShownNumber/ShownPosition/ShownTeam/ShownStats` (rows copied, so
  `PlayerStatsHud` stays intact for the other themes), and the template binds those.
- `clean()` bumps `HideKey` and keeps `IsShown` for 0.3s (`var_0_outro_time`, counted in
  `update(dt)`; `playerstatistics_hud.lua` now passes dt). The control's visibility is bound
  to `IsShown` in defence-tactics-hud's `pagameplayhudcontrol.xaml`.
- Other HUD themes keep their own card, which may show blank for those 0.3s.
- Try card (same card: tries + minutes played) is built at the start of the celebration,
  while the cutscene/replay hide the HUD; stock had no `hideStates`, so the next rule state
  reset it unseen. `playerstatisticshud_config.lua` gives Try/BonusTry `hideStates`
  (conversion kick, play-go conversion kick, kick-off setup), `playerstatistics_hud.lua`
  only runs the 5s display timer while the HUD is up (`hudHidden`, from the feature-stack
  show/hide callbacks) and replays the intro when the HUD comes back.
- Debug: `var_0_debug_log` in `playerstatistics_hud.lua` logs states/show/reset to
  `playerstatistics_debug.txt` (game folder). Turn off once the try card is confirmed.

Untested in game.

## Team stat banner

TV-style team stats slide out under the scoreboard (same slot and slide as the interchange
banner): home abbreviation + value at the home team-colour end, the stat title in the middle,
away value + abbreviation at the away end, and a bar along the bottom split by the home team's
share in team colours. XAML `StatBanner` here; `StatTitle/StatHome/StatAway/StatHomeShare/
ShowStat` + `showStat`/`hideStat` in mods/bunker-overturned-try's `nvm_scorecard.lua`; the logic
in mods/referee-on-report's `gameplayscore_hud.lua`.

- Every `StatBannerEvery` (75) seconds of live play (general play, slot free) the next stat in
  `StatBannerOrder` shows for `StatBannerSeconds` (6): completion rate (`c/s  %`), possession,
  errors, red zone entries, line breaks, tackles in the red zone, missed tackles, penalties
  conceded, run metres. Stats both teams are still 0 on are skipped (completion needs 4+ sets).
- Live values are read from the statistics component's team listener tables
  (`statistics_listeners.team.stats[side][field]`), not `getTeamStat`, whose ASSERT would trip on
  a missing field; missing = 0.
- Red zone isn't a game stat: `trackRedZone` counts each play-the-ball within `RedZoneMetres` (20)
  of the attacking side's try line (`halfFieldLength - ruckX * playDir.x`, playDir from the dummy
  half). Entries = sets with at least one.
- Interchange and on report banners take priority (a stat banner is cut short and they wait out
  its 0.8 s gap). Detections log to `interchange_banner_debug.txt`.

Untested in game.

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

## On report banner

`defaulthudresources.xaml` also holds the "<NAME> ON REPORT" banner for
[mods/referee-on-report](../referee-on-report/README.md): a copy of the try confirmed banner
without the arrows, bound to the scorecard's `MatchStateMessage` / `ShowMatchState`. Nothing
sets those without referee-on-report, so the banner stays hidden.

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

## Scrum prompt (scrum-feed-control)

The penalty bar doubles as the scrum prompt, and it carries the scrum clock: while
`NVMPenaltyHud.IsScrumPrompt` is set, `papenaltycontrol.xaml` shows `ScrumTitle` ("SCRUM  4", red on
`ScrumUrgent`) and the three option slots show `ScrumOpt1-3Glyph/Text` (hidden when
`ScrumOpt<n>Visible` is false). `PenaltySelectHud.showScrumPrompt` / `setScrumTitle` /
`hideScrumPrompt` drive it. `hide()` (the HUD feature stack's disable) is ignored while a scrum
prompt is up, and `setup()` switches back to the penalty labels. The scoreboard is untouched. See
mods/scrum-feed-control.

## Interchange banner

When an interchange is made, a two-row banner slides out under the scoreboard for 4 s: a red left arrow + `OFF <number> <SURNAME>` and a green right arrow +
`ON <number> <SURNAME>`, with the side's team colour on the left edge. Both teams, human or AI.
Several interchanges made together show one after another, and the banner waits for the scoreboard
to be on screen and for the on report banner (same slot) to clear. Jersey numbers are cached at
`InterchangeQueuedEvent`, before the swap can reorder the lineup.

Detection: `SubstitutionClearEvent` never fired for AI interchanges in game (no banner at all
during a mass interchange, 2026-11-01), so `GameplayScoreHud.pollInterchanges` compares each
side's on-field set (`roleInfoPool` assigned role not `Substitute`) every 0.25 s. A player who left
is paired with the player now in his role. The two can change role in different polls, so
unpaired offs/ons wait up to 8 s (`InterchangePendingSeconds`) for a partner, then are dropped
(sin bin, send-off).
Numbers and surnames are cached at the first poll (shirt order) and from `InterchangeQueuedEvent`.
`onInterchangeMade` is inert. `InterchangeBannerDebugLog` writes `interchange_banner_debug.txt`.

The pieces live in other mods' copies of the files: the XAML is `InterchangeBanner` here, the view
model properties (`Interchange*`, `ShowInterchange`, `showInterchange`/`hideInterchange`) are in
mods/bunker-overturned-try's `nvm_scorecard.lua`, and the event handling is in
mods/referee-on-report's `gameplayscore_hud.lua`. Untested in-game (polling version installed 2026-11-01).
