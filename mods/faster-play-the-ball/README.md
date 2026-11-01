# faster-play-the-ball

Work in progress (core issue #3, slow play-the-ball). AI side first.

## Change: AI own-end play-the-ball speed

A logged match (2026-10-25) showed the Red zone is the attacking side's **own** end (77-94 m from
the opposition line), where stock forced a slow play-the-ball on every tackle, so the AI crawled
out of its own end (about a third of its play-the-balls). Now, in its own end: quick on tackles
0-`OwnEndQuickMaxTackle` (1), slow from `OwnEndSlowFromTackle` (4), normal in between. Everything
else in `shouldQuickPlayTheBall` is stock.

Same log, for reference: hold-down (committed -> getup) median 1.3 s; getup -> ball played 2.2 s
quick / 3.7 s slow / 5.8 s normal (few samples); ball played -> dummy half pickup 0.1 s.

## Fix: quick / slow play-the-ball never changed the animation speed (stock bug)

`ai/playtheball/playtheball_action.lua` read `playrateQuickPTB` / `playrateSlowPTB` as fields of
the `design.playtheball_config` module, but they live inside its `cPlayTheBallConfig` table. Both
were nil, so every play-the-ball played at rate 1 (found from the debug log: a quick play-the-ball
logged `rate=1.00`). Stock "quick" only shortened the get-up (the early branch in
`TackledGetUpMonitor`). Now quick plays at 1.4 and slow at 0.9, as configured, for both teams.

**Dummy-half readiness (2026-11-01):** the logs showed the dummy half missing the ball on 15 of 232 AI quick
play-the-balls (0 of 40 normal/slow): played at 1.4 the ball came out before he arrived, and the defending
marker picked it up. A quick play-the-ball now only plays at 1.4 when the dummy half
(`playTheBallEntity.dummyHalfId`) is within `DummyHalfReadyDistance` (2.5 m) of the ball spot; otherwise at
1 (what stock "quick" really played at). Logged as `ACTION quick play-the-ball dummyHalf=.. dist=.. -> rate=..`.

Second pass (same day, after two more in game: ball rolled past the dummy half, who turned and jogged back):
the gate is now 1.5 m; the heel-back velocity is scaled by `RollBackVelocityScale` (0.7, logged `ROLLBACK
speed a -> b`) and `maxBallDisposalSpeed` is 1.8 (stock 2.5; set in reduce-ai-dummy-half-scoots'
`playtheball_config.lua`, its owner); and reduce-ai-dummy-half-scoots' `DummyHalfCollectBallAi` sprints to a
loose ball more than `ChaseBallDistance` (1.2 m) away (`CHASE` lines in reduce_scoots_debug.txt).

## Change: human quick play-the-ball (double-tap left trigger)

Stock read the double-tap only once the tackle had collapsed with no offload possible (and not
after a ground tackle), and only in `TackledContactMonitorHuman`, `TackledCollapseMonitorHuman`
and `DummyHalfHuman`. A double-tap during the contact phase or the hold-down was lost.

- `ai/playtheball/quickplaytheballhuman_mixin.lua`: reads the double-tap every frame of the tackle
  and remembers it per ball carrier (`PendingQuickPlayTheBall`, up to `PendingWindow` 4 s), then
  applies it as soon as the stock conditions allow. Ground tackles still never go quick (stock).
- `ai/tackle/tackled{hold,drag,drive,dive,getup}monitor_human.lua`: run the mixin too (update only,
  so no extra input barrier). In the get-up monitor it runs first, because that controller is the
  one that branches the get-up into a quick play-the-ball when the flag is set.

**Right trigger.** The attacking quick play-the-ball is a new action, `QuickPlayTheBallAttack`
(double-tap button 13, the right trigger), added to both gamepad layouts in
`design/input/default_input_actions.lua` (this mod) and given its double-tap trigger in
`design/input/input_actions.lua` (owned by `player-switching-fixes`; build.py allows one owner per
file). The stock `QuickPlayTheBall` (left trigger) stays the defensive retreat double-tap. Both the
human mixin and the human branch of `quickplaytheballai_mixin.lua` read the new action.

**Pass spam.** Pass presses (`HaveBall` PassLeft/PassRight and their DuringTackle variants) count
only once an offload is no longer possible (hold-down / get-up), because earlier the same buttons
offload. `PassSpamQuickPresses` (2) presses give a quick play-the-ball; each press past that adds
`PassSpamRatePerPress` (0.1) to the quick animation rate (stock 1.4), up to `PassSpamMaxRate`
(1.9). The rate is stored with the ball carrier's id (`QuickPlayTheBallRate`) and used by
`ai/playtheball/playtheball_action.lua` only for that carrier's quick play-the-ball; it logs an
`ACTION quick play-the-ball rate=... matched=...` line.

Each human request is logged to `ptb_decision_debug.txt` as `HUMAN carrier=... quick
play-the-ball (pressed X s before it was allowed)`.

## Debug logs

Two debug logs (game folder):

- `ptb_decision_debug.txt`: from `ai/playtheball/quickplaytheballai_mixin.lua` (this mod). One
  line per AI tackle: why the AI didn't ask for a quick/slow play-the-ball yet (`WAIT ...`:
  offload still possible / not collapsed / ground tackle), then its decision with field zone, ball
  x, direction, distance to the opposition line and tackle count.
- `ptb_timing_debug.txt`: from `rules/playtheball/playtheball_listener.lua`, which lives in
  `early-defensive-retreat` (build.py allows one owner per file). COMMITTED -> GETUP -> PLAYED ->
  COLLECT times per play-the-ball, with the quick/slow flags.

## What the stock AI does (`shouldQuickPlayTheBall`)

- Never decides until the tackle has collapsed, no offload is possible, and the first tackle
  block wasn't a ground tackle.
- Red zone: always slow. Green zone: quick on tackles 0-4. Yellow: depends on half/direction.
- Last 10 minutes: losing side always quick; winning side slows in its own half.
- Neither quick nor slow = normal speed. Animation rates (`design/playtheball_config.lua`):
  quick 1.4, slow 0.9 (tackle 1.2 / 0.9).

## Play-the-ball facing (2026-11-01)

Normal (non-quick) play-the-balls: the turn to face up-field lives in ai-last-tackle-kick's
`playtheball_ai.lua` (stock hard-coded "facing correct", so its own turn never ran), with the rare
low-discipline sideways play-the-ball called as a knock-on. A first attempt here (forcing the action's facing)
never fired, because the action is always handed the play direction, and was removed. `RollBackMinSpeed`
(1.4 m/s) keeps slow heels from being damped below what the dummy half can reach.

## Quick play-the-ball faces upfield

A quick play-the-ball branches straight out of the tackle get-up (`BranchToPlayTheBall` in
`ai/playtheball/playtheball_helper.lua`). Stock kept the facing the get-up left the player in and
picked the play-the-ball animation by its angle to upfield, so a player could play the ball side-on
to the sideline. With this mod making AI quick play-the-balls much more common (early tackles in
its own end), it showed up on the first play of a match. `QuickPlayTheBallFaceUpfield` (default
true) turns him to the team's attacking direction during the 8-frame transition and plays the
straight-on animation, as a normal play-the-ball does. Each correction logs a `FACING` line (how far
off upfield he was) to `ptb_decision_debug.txt`. Untested in game.
