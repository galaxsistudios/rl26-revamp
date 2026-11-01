# defence-tactics-hud

Three tweaks to the in-match tactics (D-pad) HUD:

1. **Tactics menu in the broadcast plate style** (matches nrl-broadcast-scoreboard's player plate,
   interchange and penalty bar). `patacticscontrol.xaml`: a header plate (team crest in the slanted
   team-colour box, TACTICS over "ATTACK / CROSS OVER", green underline) over a strip of tiles
   (dark cards; selected = white with a green bar, since the shared TacticsIcons style turns icons
   black when selected; confirmed = solid green). 400 wide like the plate, and the defence label
   pill is 400 too. `nvm_tactics.lua` adds `Team` (set in `TacticsHud`'s constructor, as
   substitution_hud does), `Subtitle` (card set name + selected tactic, keys split from CamelCase
   when there's no label) and `RevealKey`/`HideKey`. Kept fast for mid-play use: 0.22 s intro,
   0.15 s outro that starts inside the existing close delay (`var_0_outro_time`), so the menu never
   stays up longer than stock. Spacing above the label tightened from 25 to 6.
2. **Defence tactic resets when you win the ball.** A defence tactic (Slide Left / Compress /
   Drop Wingers / Slide Right) stayed on until changed, so Drop Wingers picked for the last play
   carried into the next defensive set. `TacticsHud.update` now puts a human side's defence graphs
   back to `BasicDefence` / `BasicPlayTheBallDefence` the moment that side is the attacking side.
   It also resets when the opposition starts a new set without this side touching the ball (try + kick-off, six-again, dropout): any drop in the tackle count while defending. Checked against the last update's values, so a change during a cutscene is still caught. Each reset logs `RESET side=N (reason)`. The last-tackle warning now ignores the play-the-ball position once the game clears it to (0,0). The "tactic on" flag is also tracked per side now (stock shared one flag between both teams).
3. **Defence tactic label.** A small pill just above the player plate shows the defence tactic,
   with a D-pad whose lit arm is the button for it (Up = Compress, Down = Drop Wingers,
   Left/Right = Slide Left/Right), or "STANDARD" with no arm lit on the default defence. It only
   shows for human-controlled sides, and only while that side is defending: `TacticsHud.update`
   (which only visits local gamers' sides) sets `DefenceTacticVisible`, and the XAML fades the pill
   in and out over 0.25 s. It shows whether or not the tactics menu is open. "Live play" =
   general play (`getGeneralGameplayActive()`) or a play-the-ball under way, so it's hidden at
   tries, conversions, penalties, kick-off setup, scrums and breaks. Same 350 width as the tactics
   window.
4. **Last-tackle warning.** On the opposition's last tackle (`tackleCount >= maxTackleCount - 1`,
   the same count the scoreboard uses), with the ruck more than `LastTackleWarnDistance` (20 m) from
   the line being defended, the label turns red and flashes: "LAST TACKLE: PRESS DOWN TO SEND
   WINGERS BACK", Down arm lit. Not shown if Drop Wingers is already on. The ruck position comes
   from the last play-the-ball (`playTheBallPosition`).

Debug: `DefenceTacticDebugLog` in `nvm_tactics.lua` logs every label change to
`defence_tactics_debug.txt` (game folder). Turn off for release.

## Files

| File | Entry |
|---|---|
| `src/script-game/sim/hud/tactics_hud.lua` (labels, per-side flag, reset) | 39959 |
| `src/script-game/app/noesis/hud/nvm_tactics.lua` (new `DefenceTacticKey/Text/Visible` properties) | 39959 |
| `noesis/workspace/views/hud/rugby/patacticscontrol.xaml` (width) | 57662 |
| `noesis/workspace/views/hud/rugby/pagameplayhudcontrol.xaml` (label) | 57662 |

Install both entries (scripts with `python tools\build.py full --confirm`, XAML with
`build.py full --list manifests\xamls.xml --extracted <stock 57662> ...`, see INSTRUCTIONS.md). With
only the XAML installed the label never shows (its bindings have nothing to read).

## Also carries nrl-broadcast-scoreboard layout changes

This mod owns `pagameplayhudcontrol.xaml`, so two changes for
[nrl-broadcast-scoreboard](../nrl-broadcast-scoreboard/README.md) live in its copy:
`Home/AwaySubstitutionHud` (quick interchange) moved from the HUD stack's row 2 into the
player plate grids, directly above the bottom plate; and the top plates collapse
(`BooleanToVisibilityConverter`) instead of staying Hidden when unused; and `paPenaltyControl` moved to bottom centre
(RowSpan 2, VerticalAlignment Bottom) for the horizontal penalty bar; and both `PlayerStatisticsControl`s bind
`Visibility` to `IsShown` (so the stats card can animate out); and the right plate grid and away stats grid
get a 40-unit scaled spacer column on their right, because baResolutionScaledViewbox
reports ~9% less width than it draws and right-aligned plates were clipped at the safe area.
