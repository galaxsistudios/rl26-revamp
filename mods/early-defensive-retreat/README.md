# early-defensive-retreat

Defensive lines start getting back 10 m as soon as a tackle is certain, instead of waiting for the
hold-down / "held" call. The human "double-tap left trigger to retreat" control works again.

## What it does

1. **Early retreat (both teams' AI-controlled defenders).** The game already has a rule that sends
   every free defender back 10 m at sprint: `isDefenseHeldTackle => QuickDefensiveOnsideAi` in
   `ai/flowcharts_ai/master_flowchart_ai.flow`. Stock only raises that flag when the tackler enters
   the hold-down (`TackleHoldMonitorAi/Human`). This mod also raises it on `TackleCommittedEvent`,
   which the tackle animations fire on their **"committed" frame** (the point the tackle can no longer
   fail), while the ball carrier still has the ball.
2. **Broken tackles cancel it.** `TackleBrokenEvent` / `TackleBreakEvent` clear the held flag and the
   double-tap flag, so a busted tackle doesn't leave the line running backwards. Offloads and fends
   already clear the play-the-ball entity (stock).
3. **Sprint.** `QuickDefensiveOnsideAi` sprints back (`defensivePlayTheBallSpeed`) for the held flag
   too; stock only sprinted for the double-tap.
4. **Double-tap left trigger (human).** Stock checked it only in `DefendingFreeRoamHuman`, and only
   after the tackle had collapsed and was 1/6 s into its block. The first tap of the trigger switches
   you to controlled movement (`DefendingControlledRoamHuman`), and while you're the tackler you're in
   a `Tackle*MonitorHuman` controller, so the second tap was never seen. The mixin now runs in
   controlled movement and every tackler controller (contact, drive, drag, hold, collapse, standing
   release, dive), and accepts the double-tap at any point of a tackle on the ball carrier.

## Files

| File | Change |
|---|---|
| `rules/playtheball/playtheball_listener.lua` | listens for TackleCommitted/Broken/Break events |
| `ai/playtheball/quickdefensiveonside_ai.lua` | sprint for the held flag too |
| `ai/playtheball/quickdefensiveplaytheballhuman_mixin.lua` | double-tap accepted during the whole tackle |
| `ai/generalgameplay/defendingcontrolledroam_human.lua`, `ai/tackle/tackle*monitor_human.lua` | run the double-tap mixin |

All entry 39959: `python tools\build.py full --confirm` (game closed).

Debug: `RetreatDebugLog` in `playtheball_listener.lua` writes `early_retreat_debug.txt` to the game
folder (one line per committed / broken tackle). Turn off for release.
