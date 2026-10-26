# bunker-overturned-try

Try attempts that the stock game rules out are awarded on the field first, then overturned by the
bunker. The flow:

1. The referee awards the try: whistle, "Try!", TRY banner, commentary, crowd and try music.
2. The scorer celebrates and the scoreboard shows the points.
3. The try replay plays, with replay-team-stinger's stinger in.
4. After the replay, the stinger cuts back to the referee, who signals for the video referee.
5. The bunker replay plays (stock video referee look and HUD).
6. The decision comes up **NO TRY**, the points come off the scoreboard, and play restarts the way
   the stock no-try would (play-the-ball, tap, penalty...). For a knock-on, the knock-on is called
   with the decision.

Script mod, entry 39959: `python tools\pack.py restore --entry 39959`, then
`python tools\build.py full --confirm` (game closed). The step 4 stinger needs replay-team-stinger
(its `screenwipe.lua`/`logotransition_hud.lua` have the outro). Without it, step 4 is a stock
crossfade.

## Which attempts

`ProvisionalTryOutcomes` in `rules/try/tryattemptoutcomes.lua` lists them: held up, knock-on,
outside the try area and double movement. A ball held up outside the try area is left alone.
`ProvisionalTryChance` (currently **100**, so every one) is the percentage that get the
award-then-overturn. Online matches, practice and training always keep the stock flow.

Real tries are untouched. The stock game already sends 25% of tackled tries to the bunker, and
those still come back "Try".

## How it works

| File | Change |
|---|---|
| `rules/try/tryattemptoutcomes.lua` | Rolls for it and builds the rule state chain (below). Settings and debug log. Snapshots player positions at the try. Shares `roll`/`buildReview`/`snapshotPlayers` through `_G.ProvisionalTryState`. |
| `rules/match/generalgameplay_rulestate.lua` | A plain knock-on by the attacking side that lands in the in-goal (not a grounding attempt) normally becomes a `KnockOnRequest`. It's sent through `trySuccessRequestFactory` as a KnockOn attempt with `forceProvisional` instead. |
| `rules/cameo/refereecameo_rulestate.lua` | The sim reaches the "send it upstairs" referee cameo while the try replay is still playing. With `waitForProvisionalOutro`, it holds the referee's signal, the cameo timer and skip until the RL26 logo wipe out of the replay starts sliding off (`ProvisionalTryState.outroReleased`, set by replay-team-stinger's `screenwipe.lua`), plus `ProvisionalTrySignalDelay` (0 s). Fallbacks: no replay or wipe left on the universe stack, or 40 s. After the signal, the cameo runs `ProvisionalTryCameoLength` (2.4 s) and cuts to the bunker before the referee crosses his arms (`referee_thebunker_notry` is 6.33 s). |
| `rules/tackle/tackleoutcomes.lua` | Held-up tackles in the in-goal skip `trySuccessRequestFactory` and go straight to the video referee in `heldUpRequestFactory`. They get the same flow: a provisional `TryScoredRequest` (allowed past `validate` when the ball is dead) plus `ReactToScore`. |
| `rules/try/tryscored_request.lua` | `TryScoredEvent` looks like a try (`tryAttemptOutcome = Try`, `videoRefereeRequired = false`, `provisionalTry = true`). `unsuccessfulAttempt` stays true, so stats never count it. Sets the scoreboard points. The `KnockOnEvent` is held back. |
| `rules/cutscenes/trydecisionpending_rulestate.lua` | New `ProvisionalTryReviewRuleState`. Its wipe puts players back where they were at the try, at least `ProvisionalTrySpacing` (3 m) apart and `ProvisionalTryRefClearance` (7 m) from officials, facing the try spot. The celebration pulls everyone in to the scorer, so without this they bunch up around the referee. The other officials go to the touchlines (`ProvisionalTryTouchJudgeInfield`), so only the referee is in the cameo. Provisional mode: emits the held-back knock-on, then takes the points off 3 s in (when VideoRefHud swaps Pending for the decision). |
| `listeners/replay/replay_listener.lua` | Records try + video referee moments. The first replay hides the `videoref`/`knockon`/`ballstrip`/`unsuccessfultryattempt` moments so it's an ordinary try replay. Flags that replay `provisionalTryReplay` for the stinger outro. Also holds replay-team-stinger's lead-up replay: a ball strip/knock-on before a try or field goal is replayed once first, then the try (see that README). Debug log: `replaymoments_debug.txt`. |
| `app/noesis/hud/nvm_scorecard.lua` | Adds the provisional points in `updateScores` (display only; the jumbotron follows). |
| `rendering/props/propfactory.lua` | Stadium props fire for a provisional try. The try music for it lives in `soundlistener_ingame_music.lua`, now owned by [team-try-songs](../team-try-songs/) (two mods can't override one file). |

Rule states:

```
stock:  ReactToScore(decisionPending) -> RefereeCameo(VideoReferee) -> TryDecisionPending -> restart
mod:    ReactToScore(as a try) -> [RefereeCameo(Try) if the ref is close] -> TryCelebrate
        -> ProvisionalTryReview  (wipe barrier: the try replay plays, stinger out)
        -> RefereeCameo(VideoReferee, queues the bunker replay)
        -> TryDecisionPending(provisionalTry, NO TRY)  (wipe barrier: the bunker replay plays)
        -> restart
```

- **Score:** the real match score never changes. `CScoreEntity` has no way to remove a score, and a
  real `ScoreRequest` would also go into the score timeline and match stats. The points live in
  `_G.ProvisionalTryState` (`side`, `points`), which `NVMScoreCard` adds on. A new match HUD clears it.
- **Second replay:** `RefereeCameo`'s stock `QueueReplayEvent` builds the bunker replay from the
  same recording after the first replay's wipe. Captain's challenge already does that. If it
  ever finds no moments, the flow carries on without the bunker replay.

## Debugging

`ProvisionalTryDebug` (currently **on**) appends to `provisionaltry_debug.txt` in the game
folder. A normal run logs:

```
tryattemptoutcomes loaded, chance 100
held-up tackle: outcome HeldUp -> PROVISIONAL TRY      (or "try attempt: ...")
provisional try: outcome ..., side ..., knock-on ..., next ...   (try attempts only)
try scored: side N shows +4, scorer ...
replay queued: provisional try, video referee false, instance true
review: spread N players around the try, M officials kept clear
review: try replay done, sending it upstairs
replay queued: bunker, video referee true, instance true
decision pending: NO TRY[, calling knock-on]
decision shown, points removed
```

`instance false` on the bunker line means no bunker replay could be built. The stinger outro logs
to `teamstinger_debug.txt` (`outro: kicked over the end of the provisional try replay`) when
`TeamStingerDebug` is on. Look for `outro: armed ...` then `outro: end-of-replay barrier`.

## Testing

`ProvisionalTryTestOutcome` in `tryattemptoutcomes.lua` (`"KnockOn"` or `"HeldUp"`, normally
`nil`) turns every real try into that outcome, so the flow plays on demand. **Set it back to
`nil` before real play**, or no try can stand.

Tested in-game 2026-10-23: held-up tackles and knock-ons while grounding (via the test switch),
the player spread, the touch judges and the logo-wipe outro. A plain dropped ball in the in-goal
can't be forced; from the knock-on onwards it runs the same flow.
