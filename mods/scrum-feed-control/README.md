# scrum-feed-control

Scrums you have to run yourself:

1. **Position.** When a human has the feed, the penalty bar becomes `SCRUM | □ LEFT  △ MIDDLE  ○ RIGHT`
   with a `SCRUM  5` countdown in its title. Pick one in time, or the scrum goes where the
   stock game puts it. That option is marked `(AUTO)`.
2. **Feed.** Once the pack is set, the bar shows `SCRUM  10 | ✕ FEED | L1 R1 FEED`, counting
   down (red for the last 3 seconds). Press cross / A or either pass button (L1 / R1, LB / RB) to feed. If the clock runs out,
   the other side gets a penalty at the scrum mark (the stock `TimerExpired` infringement, as for a
   slow line dropout).
3. **AI feed.** The AI feeds at a random moment, 0.8-2.5 s into the clock (human feeds land at about 1.5-2 s). On a small share of scrums
   it lets the clock run out: 10 % on Easiest, 7 % Easy, 4 % Medium, 2 % Hard, 1 % Hardest.
4. **Players outside the scrum.** You can switch to any player not in the scrum and move him
   during the feed clock and the scrum. Each of those players gets an **offside line**: the x he
   stands on when the pack is set. Going more than 0.5 m past it before the ball is out of the
   scrum flags him offside (the bar's title flashes `OFFSIDE` while it is up). The flag sticks. If he makes a
   tackle before the first tackle is completed, or within 10 s of the ball coming out, it is a
   full offside penalty anywhere on the field, never a six again.
   **AI lining:** while the scrum is fed, AI players outside it adjust their line. In 60 % of
   scrums 1-3 of them shift sideways or drop back (legal). Now and then an AI defender creeps
   1.5-3 m up instead (15 % of scrums on Easiest, 12 % Easy, 8 % Medium, 5 % Hard, 3 % Hardest).
   He is flagged offside like a human, so if he makes the first tackle it's a penalty to you.
   Log lines: `AI line: player N adjusts / CREEPS ...`. Test switch: `ScrumTestAiAlwaysCreeps`.
5. **Repack.** After a scrum offside penalty, the side awarded it also gets `✕ SCRUM` on the penalty
   choice: the scrum is packed again at the same spot (no position pick), with their feed. Scrum
   infringements (the feed clock running out) never offer it, and the AI never picks it.
6. **Repeat offender.** Offences in a row by one side, each off the scrum repacked after the last:
   2nd - the tackler goes straight to the sin bin; 3rd - he is sent off (red card) and the repack
   option isn't offered. The penalty then goes on as normal, and the sin bin / send-off cutscene
   plays when an option is picked (repack included).

7. **Defence line-up.** When the AI has the feed and you're defending, the bar shows
   `DEFENCE  5 | □ STACK LEFT  △ STANDARD  ○ STACK RIGHT` before the pack goes down. A stack shifts
   the defending side's formation focus 6 m towards that side for the positioning wipe
   (`ScrumDefenceStackShift`, `defenceShiftY` in `GetScrumState`). **Don't add force-directed graphs
   for this:** the native graph container is a fixed pool, and two extra graphs (65) crashed match
   load (exe+0x69ca6d, 2026-11-01; the removed graphs are in docs/scrum-defence-stack-graphs.lua.txt).
8. **AI picks its lane.** The AI with the feed packs away from your stack 75 % of the time (it
   reads it), favours the middle in the attacking 20 m, and otherwise keeps the stock spot half the
   time and mixes it up the rest (`aiLane`; log `AI lane, ...`).
9. **Set plays.** On the feed clock the bar also shows `◄ ► PLAY: AUTO`. D-pad left / right picks
   `ScrumOffenceLeft` / `ScrumOffenceRight` (`...Nines` in Nines), again for AUTO. It's forced
   through the play selection knowledge's `DEBUG_playNameOverride` + `playSelectionDisabled` (what the
   play debug menu sets) and cleared at the first tackle, a turnover, ~25 s or the next scrum
   (`afterScrumUpdate`, called from GeneralGameplayRuleState.updateSolid). The log line
   `set play: side is running ...` shows whether the play took.
10. **Offside line on the pitch.** While the line is live, your controlled player's offside line is
   drawn across the field (white, red once he's offside) on the field HUD lines
   (`services.hudLines:addLine`).
11. **Referee.** The feed clock penalty now has the referee's scrum signal (call + whistle) instead
   of none. Scrum offside penalties already use the offside signal; the 2nd / 3rd offence sin bin /
   send-off cutscenes are the stock ones.
12. **discipline-meter.** The AI creep chance is scaled by the least disciplined defender's
   discipline (x0.5 at full, x2 at empty, x1.5 more when rattled) and he's the likeliest creeper;
   the AI feeder's discipline scales the feed clock violation chance the same way
   (`ScrumUseDiscipline`). Penalties already drain discipline in that mod.

Online matches and training keep the stock scrum.

Installed 2026-11-01 (scripts + xamls), untested in game.

## Test switch

`ScrumTestEveryTackle` (top of `scrum_helper.lua`, currently **true**) turns every completed
tackle into a scrum at the tackle spot, fed by the side in possession, instead of a
play-the-ball. Tackles where play stops for an injury are left alone. The hook is in
bunker-overturned-try's `rules/tackle/tackleoutcomes.lua` (`playTheBallRuleStateRequestFactory`
asks `ScrumControlState.testTackleScrum`). Set it to false for normal play and reinstall scripts.

`ScrumTestAlwaysOffside` (currently **true**) flags every player on the defending side offside when
the ball comes out, so the first tackle after a scrum is a full offside penalty. Log line:
`TEST: every defender flagged offside`.

## Install

Touches three bundles. Install all of them with the game closed (see INSTRUCTIONS.md):

| Files | Entry |
|---|---|
| this mod's `src/script-game/...` + the edits listed under "Other mods" | scripts |
| nrl-broadcast-scoreboard's `papenaltycontrol.xaml` | xamls |

```powershell
python tools\pack.py restore --entry scripts
python tools\build.py full --confirm
python tools\pack.py restore --entry xamls
python tools\build.py full --list manifests\xamls.xml --extracted _build\stock\xamls --out _build\xamls.m3mp --confirm
```

## How it works

Stock: every scrum goes through `scrum_helper.GetScrumState` (forward pass, knock-on, in touch,
captain's challenge, etc.). That returns the positioning wipe, then `ScrumSetupRuleState`, then
`ScrumRuleState`. `ScrumRuleState` starts one synchronized clip per scrum player straight away,
with the bind, feed and collect all in it.

Modded:

```
GetScrumState -> ScrumPositionSelectRuleState   (human feed only)
              -> GetScrumState again             (positioning wipe at the chosen spot)
              -> ScrumSetupRuleState
              -> ScrumFeedPendingRuleState      (pack set, feed clock)
              -> ScrumRuleState                 (stock scrum animation)  | penalty on timeout
```

| File | Change |
|---|---|
| `game/scrum/scrum_helper.lua` | Settings, shared `_G.ScrumControlState`, debug log. `GetScrumState` returns the position select first (`scrumPositionChosen` skips it on the second call). Scrum players stay incapacitated for 20 s + the feed clock. |
| `rules/scrum/scrum_setup_rulestate.lua` | Hands off to `ScrumFeedPendingRuleState`. Also defines the new classes (build.py can't add script files; this module is registered at boot): `ScrumPositionSelectRuleState`, `ScrumFeedPendingRuleState`, `ScrumControlGameController` (input), `ScrumControlDetect` (per-frame clock, HUD and transitions), and the offside line. |
| `rules/scrum/scrum_rulestate.lua` | Switching isn't blocked after the feed. Offside tracking runs until the ball is collected (`scrumBallOut`). |
| `rules/penalty/penaltyselectpending_rulestate.lua`, `game/penalty/penaltyselect_gamecontroller.lua` | `✕ SCRUM` on the penalty choice when a repack is offered; cross / A sets `repackChosen`, `ScrumRepackDetect` (in `scrum_setup_rulestate.lua`) packs it, sin bin cutscene first if one is due |
| `ai/flowcharts_human/scrum_flowchart_human.flow` | A human-controlled player outside the scrum gets `AttackingFreeRoamHuman` / `DefendingFreeRoamHuman` instead of `IdleHuman`. No BOM. |

- **Lanes**: 20 m in from either touchline (`scrum_config.offsetFromSideLine`, ±14 m), or 0.
  "Left" is the feeding side's left as it attacks (the first version was mirrored; fixed and
  confirmed in game 2026-11-01). `ScrumFlipLeftRight` flips it again.
- **Holding the pack**: the scrum clips can't be paused, so during the feed clock the scrum
  players stand on their clip start spots (`Idle` behaviour) and bind once the ball is fed.
  They are moved to the spots where `ScrumBase` would snap them, so the snap isn't visible.
- **Input** reuses actions every pad map already has, so no input file changes:
  `PenaltySelect.TapRestart` / `KickToTouch` / `PenaltyGoalAttempt` (square / triangle / circle)
  for the lanes, and `PlaceKick.AcceptBallPosition`, `Contest.Collect` or `AntVision.Skip` (cross / A)
  for the feed. The glyphs follow the controller (`|SQUARE|` etc.).
- **Offside**: only players a human is controlling are flagged (`ScrumOffsideAiPlayers = false`),
  so the AI's formation drift never is. The penalty comes from the stock TackleDetect offside path:
  `flaggedOffside or isScrumOffside(tackler)`.
- **Prompt and clock**: the countdown is in the prompt bar's title, so nothing shows when no
  human has to act (AI feed). The scoreboard is untouched (an earlier tab under the clock was
  dropped 2026-11-01). The bar is set directly (`hud:getElement("penaltySelect")`), not through
  the HUD feature stack. The feature stack disables
  every feature outside its top frame whenever a frame is pushed or popped (`processTopFrame`).
  That hid the first version's prompt right after it showed, so `PenaltySelectHud.hide` now ignores
  it while a scrum prompt is up.

Settings are at the top of `scrum_helper.lua`. The debug log is `scrumcontrol_debug.txt` in the
game folder (`ScrumControlDebug`).

## Other mods

| Mod | File | Change |
|---|---|---|
| nrl-broadcast-scoreboard | `app/noesis/hud/nvm_penaltyhud.lua`, `sim/hud/penaltyselect_hud.lua`, `views/hud/rugby/papenaltycontrol.xaml` | Scrum mode on the penalty bar (`IsScrumPrompt`, `ScrumTitle`, `ScrumUrgent`, `setScrumOptionText`, `ScrumOpt1-3Glyph/Text/Visible`; `showScrumPrompt` / `setScrumTitle` / `hideScrumPrompt`; `hide()` ignored during a scrum prompt) |
| bunker-overturned-try | `rules/tackle/tackleoutcomes.lua` | Test switch hook (every tackle -> scrum) |
| bunker-overturned-try | `rules/match/generalgameplay_rulestate.lua` | `updateSolid` calls `afterScrumUpdate` (ends a forced set play); `scrumOffside` skips the six-again branch: always a full penalty |
| bunker-overturned-try | `rules/match/generalgameplay_rulestate.lua` | Offers the repack (`offerRepack`); repeat offsides after repacks: 2nd sin bins the tackler, 3rd sends him off with no repack (`scrumOffenceNumber`, `scrumSinBin`: discipline-meter's `SinBinSystem.sendPlayerToSinBin`, or the send-off requests) |
| referee-on-report | `rules/tackle/tackle_detect.lua` | Scrum offside tacklers are penalised as offside; a completed tackle clears the flags |

Without this mod those edits do nothing. Without nrl-broadcast-scoreboard there is no prompt or clock,
but the rules still apply. The prompt bar works under every HUD theme.

## Things to check in game

- The prompt and clock show during the position select (it runs straight after the referee's
  signal, before the positioning wipe).
- Left / right match what you expect.
- The pack standing on its clip start spots looks right, and the bind starts cleanly on the feed.
- A switched-to player moves, and crossing the line shows `OFFSIDE`.
- Feed clock timeout: the penalty flow starts, and nobody plays the scrum animation afterwards.
- Defence stack sides vs `aiLane`: stack y uses the same lane maths as the attack pick (defender's
  left). Check the defence leans the way you picked, and the AI packs away from it.
- Set plays: check `set play: side is running ScrumOffence...` in the log; if it shows the stock
  play, the debug override isn't honoured in retail.
- Offside line: drawn across the field at your player's line; if it runs along the field instead,
  the control point axes are swapped.
