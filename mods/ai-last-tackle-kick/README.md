# ai-last-tackle-kick

The AI kicks on the last tackle instead of running it, and every AI kick, last-tackle start and handover is
logged so we can see where the runs came from.

Issue tracker: C-37 (AI runs the ball on the last tackle, about 50 % in its own half). Related: C-49.

## Why the AI ran the last tackle

`decisiontree_ai.flow` had no general last-tackle kick rule. The AI only kicks when the active set play
hands the ball holder a kick (`hasPuntKick`, `hasBombKick`, ...) or a team order does. 67 of the 68 plays
with `requiredTags = LastTackle` contain a kick, so the runs come from no play being active, or from the
ball reaching someone other than the play's kicker.

## What it does

One new rule, placed after the set-play kicks (so a play's own kick still wins):

```
hasBall and isLastTackle and not hasSideKickedThisTackle and not isDummyHalf and not isInGreenZone
  and (isHalf or isFiveEigth or isFullBack) => KickPunt
```

- Green zone = within 25 m of the opposition line (`evaluate_cconfig.greenZoneStart`). There the plays
  (grubbers, chips, bombs) or a run are left alone.
- Only the AI: the decision tree returns `None` for human-controlled sides earlier.
- The kick fires through the existing `KickAiMixin` (HoldBallAi / HitGapAi), aimed by the native punt
  target knowledge. If that knowledge has no target, the mixin skips the kick and he runs as before.

## Debug log

`last_tackle_debug.txt` in the game folder (`DebugLog = true` in both Lua files; turn off for release):

```
LAST     side=1 tackle=5/5 fromOwnLine=38 play=...    last tackle starts (AI tackled player)
KICK     side=1 id=.. kick=PuntKick tackle=5/5 fromOwnLine=41 play=...
HANDOVER side=1 tackle=6/5 fromOwnLine=52 play=...    a HANDOVER with no KICK since LAST = ran it
```

## Files

| File | Change |
|---|---|
| `ai/decisionmaking/decisiontree_ai.flow` | The rule above (stock copy, no BOM) |
| `ai/kicking/kickai_mixin.lua` | Stock + `KICK` log line |
| `ai/playtheball/playtheball_ai.lua` | Stock + `LAST` / `HANDOVER` log lines |

## Status

Untested in game. Watch for: punts from 26–50 m out from the opposition line going dead (if so, narrow the
rule to `isInRedZone`), and halves kicking when a set play wanted them to pass to the kicker.

## Tackle-0 punt veto

Catching a kick still reads as the kicking side's last tackle, so the decision tree's last-tackle punt (and
`not isFirstTackle` didn't stop it) made the returner, usually the fullback, punt straight back. `kickai_mixin.lua`
now skips punts and 40/20-style kicks when the tackle count is 0; the carrier runs it instead. Field goals,
grubbers and chips are untouched. Logged as `KICK ... VETOED (tackle 0)`.

## Play-the-ball facing (lives in playtheball_ai.lua, 2026-11-01)

Stock `PlayTheBallAi` hard-coded `facingCorrectDirection = true`, so its own turn-to-face-up-field branch never
ran and players played the ball facing the sideline. `facingCheck` now really checks the body facing (within
~25 deg, `FacingTolerance` 0.9); if he's off, update walk-turns him and he plays once square, or after
`FacingTurnTimeout` (1 s). Exception: a player whose discipline-meter value is below `LowDisciplineFacing` (0.35)
skips the turn with a chance of up to `BadFacingMaxChance` (25 % at zero discipline), and that sloppy
play-the-ball is called as an error: a stock `KnockOnRequest` (advantage to the defending side, then scrum /
handover). Logged as `FACING` lines in ptb_decision_debug.txt. AI tackled players only (human play-the-balls
use playtheball_human.lua).

## Going for the line (decisiontree_ai.flow, 2026-11-01)

An AI carrier a few metres out passed instead of diving (the set play's team-order pass, lines 6-9, comes
before every try rule). Now, for AI sides only (`not isHumanOnSide`), a carrier who isn't the dummy half and is
`isVeryNearOppositionTryLine`:
- dives (`DiveTryAttempt`) as soon as `withinDiveDistance`, ahead of any planned pass;
- otherwise doesn't take a team-order or pass-candidate-override pass, so he runs at the line (the set-play
  passes at lines 58-60 already excluded the near-line case).
Human sides keep their team-order passes. The native distance behind isVeryNearOppositionTryLine is unknown
(aimed at ~5 m); if AI carriers still pass at 3-5 m, it is shorter.
