# fullback-sweeper-defence

The defending AI fullback plays as a sweeper. His depth behind the line depends on the tackle count
and field position, and he holds it when the ball is played. He only goes after the ball carrier on
a line break, or when a carrier gets right up to him. Near his own try line he stands in the line,
level with the ball.

Issue tracker: C-27 (fullback sprints up to every tackle), related to C-26.

## Depth

Depth is measured behind the defensive line. The line is taken as `RuckLineGap` (10 m) behind the
ruck.

| Situation | Behind the line | Constant |
|---|---|---|
| Tackles 1–3 | 20 m | `EarlyDepth` |
| Tackles 4–6 (end-of-set kick) | 35 m | `LateDepth` |
| Ruck 70 m+ from our line (pressing them in their half), tackles 1–3 / 4–6 | 15 / 22 m | `OppositionEarlyDepth` / `OppositionLateDepth`, `OppositionTerritory` |
| Ruck within 15 m of our line | in the line (formation spot) | `GoalLineDistance` |
| Within 8 m (`isSomewhatNearOwnTryLine`) | stock line defender | flowchart |

- "Tackles 4–6" means `tackleCount >= maxTackleCount - 2`. At the play-the-ball, `tackleCount` is the
  number of tackles made (1–5).
- He never stands more than `MaxInGoalDepth` (2 m) into the in-goal. So between 15 and about 35 m out,
  the try line limits how deep he goes.
- Sideways he follows 75 % of the ball's distance from the middle (`LateralFollow`).

## Why he charged the ruck

1. **`QuickDefensiveOnsideAi`** targets exactly 10 m behind the ball, whatever depth the defender
   is at. Stock only used it on the human double-tap. `early-defensive-retreat` fires it on every
   committed tackle, so a deep fullback was sprinted *forward* to the 10 m line every play.
   The fullback is now excluded from both rules.
2. **Primary/important defender rules.** Nothing excluded the fullback. Straight behind the ruck,
   he had the cleanest line to the dummy half, so he was picked and ran at him at full speed.
3. **Formation swing.** In the play-the-ball formations `FullbackControl` sits 40 m behind the
   ruck, and in general play 20 m behind the ball, so the switch ran him about 20 m forward. The
   controller below now sets his position outside the goal-line zone. The data change (-40 → -25)
   only matters where the formation is still used.

## Files

| Change | File | Owner |
|---|---|---|
| Sweeper controller. Stock registers `DefensiveMovementPassiveAi` but no flowchart uses it (it was empty); build.py won't add new script files. The reference point is the current ruck. In general play it follows a carrier who gains ground, by up to `MaxRetreatPastRuck` (5 m), but never a backward pass. A carrier within `CloseDownDistance` (10 m) of him in open play: he goes at him. `TackleAiMixin` runs every frame and checks `canTackle` itself. | `ai/generalgameplay/defensivemovementpassive_ai.lua` | this mod |
| Fullback → `DefensiveMovementPassiveAi` unless `lineBroken`, `ballCarrierInGoal`, `isInPlayKick` or `isSomewhatNearOwnTryLine`. The rule sits after the line-break rules, so `CutOffLineBreakerAi` / `PursueLineBreakerAi` still fire. `not isFullBack` added to both `QuickDefensiveOnsideAi` rules. | `ai/flowcharts_ai/master_flowchart_ai.flow` | **mods/reduce-ai-dummy-half-scoots** (one owner per file; lines tagged `fullback-sweeper-defence`) |
| `FullbackControl` xOffset -40 → -25 in `BasicPlayTheBallDefence`, `…Compress`, `…SlideLeft`, `…SlideRight`, `…DropWings`, `TapRestartDefence` | `intermediatelua/forcedirectedgraphs/forcedirectedgraphs_rugby.lua` | this mod |

The game switches to the near-line formations by itself. `CTeamTacticsProcess` (about 0x140730417
on 1.0.5887) appends `10m` to the defence graph name when `ballX * playDir < -35` (within about
15 m). Every `*10m` graph puts `FullBack` in the line between `Hooker` and `Lock`. `*10mLastTackle`
keeps him 14–15 m back for the kick.

## Pitfall: the reset play-the-ball entity

About 2 s after each play-the-ball, the play-the-ball entity is reset: no dummy half, position
(0, 0), but the state is still not `None`. v2 read that as a new ruck at halfway, so between plays
he ran to a wrong spot, then ran back at the next play-the-ball. A ruck now counts only when
`playTheBallId` is set, the state is neither `None` nor `Complete`, and the position isn't (0, 0).
`playTheBallId` is the tackled player, not a unique play ID, so a new ruck is detected by a change
of position. The defence-tactics-hud log shows the same reset entries (`ruckX=0.0`).

## Debug

`DebugLog` in the controller writes one line per play-the-ball per fullback to
`fullback_sweeper_debug.txt` (game folder): tackle count, ruck distance from his line, depth used,
mode (`sweep` / `closedown` / `formation`), target and position. Turn it off for release.

## To check in game

- Midfield tackles 1–3: about 30 m behind the ruck (20 m behind the line). Tackles 4–6: about
  45 m, or the try line, whichever comes first. No run at the ruck when the ball is played.
- A line break: he goes after the carrier.
- A carrier who busts a tackle without a line break being flagged: he should come up from about
  10 m away and tackle.
- Kicks: stock behaviour (collect / respond).
- Inside 15 m: in the line at the ball.

Entry 39959: `python tools\pack.py restore --entry scripts` then `python tools\build.py full --confirm` (game closed).
