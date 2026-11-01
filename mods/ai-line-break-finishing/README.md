# ai-line-break-finishing

When the AI makes a clean line break, the runner no longer always runs round to the posts. In 10 % of breaks
he still goes to the posts, and if nobody can catch him he showboats (taunts) on the way in.

Issue tracker: F-02.

## Why it always went to the middle

`master_flowchart_ai.flow` sends an AI ball carrier who has broken the line (`iveBrokenLine`) to
`LineBreakerAi`. That controller only ran to the native `lineBreakerKnowledge:getBestInterception()`.
The native score for each candidate run includes `weightedDistanceToGoalCentre`
(`distanceWeight = 2` in `design/linebreakerknowledge_config.lua`), so the best candidate always bent
towards the posts. The controller also had no try mixin, so he kept running in goal until he was
under the posts.

## What it does now

One roll per line break (`PostsChance` = 0.1):

| Roll | Run | Grounds the ball |
|---|---|---|
| 10 % "posts" | Stock target (to the posts) | Once he is between the posts (±2.75 m) or 6 m deep in goal |
| 90 % "direct" | The same candidate runs the native job scores, picked without the middle-of-goal term, so defender avoidance and time-to-line still count | As soon as the decision tree says `TryAttempt` / `DiveTryAttempt` (within 2 m of the line) |

**Taunt** (posts runs only): once, between 20 m (`taunt_config.TauntDistanceFromTryLine`, same as the
human taunt) and 6 m from the line, when every defender is at least 4 m behind him and none is within
7 m. It's the same `Taunts` upper-body blend (`ball_hold_showboat_*`) the human gets on Y, so he keeps
sprinting. The blend is cleared before the try is grounded.

All the numbers are constants at the top of
[linebreaker_ai.lua](src/script-game/ai/generalgameplay/linebreaker_ai.lua).

## Sideways cost (2026-11-01)

Without the middle-of-goal term many candidate runs score the same (one log: 1000.0 vs 1000.0), and the tie
sent a runner from y = -10 to y = 30.7 (4 m from touch). Direct runs now lose `LateralCostPerMetre` (0.5) per
metre between the runner and the candidate, so near-ties go to the straighter run.

## Posts runs go straight first (2026-11-01)

A posts run used to head for the posts from the moment of the break, so a winger who broke 13 m out and 25 m
wide cut across the field and was caught. Posts runs now take the direct (straight) pick while still in the
field of play and only bend to the posts once in goal (then ground under the posts or 6 m deep).

## Debug log

`DebugLog = true` writes `line_break_debug.txt` in the game folder: one line per break (roll, mode,
distance to line), the stock vs chosen target on direct runs, and each taunt. Turn it off for release.

## Status

Untested in game. Check:
- Direct runs score where they break (or a little in-field), not under the posts.
- The `pick:` line only appears when we change the native pick. The middle-of-goal term is a penalty
  (<= 0) that is only non-zero near the line. While it is 0 the stock pick is kept (the native pick isn't
  simply the highest weight). The roll is kept per runner for 10 s, since the controller can be re-entered
  during one break.
- Posts runs: the taunt shows and the try still grounds.
