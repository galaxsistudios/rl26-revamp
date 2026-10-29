# defence-tactics-hud

Three tweaks to the in-match tactics (D-pad) HUD:

1. **Tactics panel width matches the player plate.** `paTacticsControl` sized itself to its four
   tiles (about 262 wide in design units) while the player plate below it is 350
   (`PlayerPlateTemplate`, the same in every HUD theme). The panel's border is now `Width="350"`, so
   both line up at any resolution. Attack and defence use the same control, so both are fixed.
2. **Defence tactic resets when you win the ball.** A defence tactic (Slide Left / Compress /
   Drop Wingers / Slide Right) stayed on until changed, so Drop Wingers picked for the last play
   carried into the next defensive set. `TacticsHud.update` now puts a human side's defence graphs
   back to `BasicDefence` / `BasicPlayTheBallDefence` the moment that side is the attacking side.
   The "tactic on" flag is also tracked per side now (stock shared one flag between both teams).
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
