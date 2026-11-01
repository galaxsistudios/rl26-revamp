# reduce-ai-dummy-half-scoots

**2026-11-01 situational scoot chance** (`hitgap_ai.lua`, `situationalScootChance`): 6 % base times each factor
that applies, capped at 50 %. Every decision logs its factors, e.g.
`chance=0.18 [nearLine*3.00 speed1.05*1.25] -> veto`.

| Situation | Factor | Constant(s) |
|---|---|---|
| 3+ defenders offside on one side | ×6 | `CrowdFactor` |
| 3+ defenders within 10 m in front of the ruck moving back > 1.5 m/s | ×2.5 | `RetreatFactor`, `RetreatCount/Zone/Speed` |
| Within 10 m of the opposition line | ×3 | `NearLineFactor` |
| Ruck within 15 m of touch: ≤1 defender on that side ×2, more ×0.5 | | `BlindSide*` |
| Own 20 m, tackle count < 3 | ×0.5 | `OwnEnd*` |
| Dummy half's max speed vs team average | ×0.6–1.5 | `Speed*` |
| Last 10 min: trailing by 1–12 ×1.5, leading ×0.5 | | `Late*` |
| Each scoot already this set | ×0.4 each | `RepeatScootFactor` |
| Last play, more than 5 m out | ×0 | `LastPlayLineDistance` |

The old flat 10 % / 60 % are only a fallback if the calculation errors (logged `fallback (...)`).

**2026-11-01 leak fix** (`hitgap_ai.lua`): a vetoed scoot cleared the pickup record, so when the
flowchart dropped the dummy half out of `HitGapAi` and back in a moment later he counted as "not a
dummy half" and ran (8 of 47 dummy-half runs in the logs). A veto now sticks for `VetoHoldTime` (4 s,
logged `veto-reentry, still vetoed`), and the pass wait before giving up is `VetoPassTimeout` 1.5 s
(was 0.5 s, which caused `veto-timeout, running`).

AI scoots follow two rules instead of happening on every play-the-ball where the markers aren't square:

1. **Markers offside:** the dummy half scoots only `ScootChance` of the time (default 10%) and passes otherwise.
2. **Own 40:** a winger or centre at dummy half, within 40 m of their own try line and on tackles 1–3,
   scoots `OwnFortyScootChance` of the time (default 25%), whether the markers are square or not.
   The stock AI never does this.

Anything else that isn't one of those two cases is a pass.

- **Where the AI scoot really happens (found 2026-10-25 with a debug log):** the AI dummy half usually
  collects with a plain collect action, so `DummyHalfCollectMonitorAi` (below) never runs. Instead it
  stays in `DummyHalfCollectBallAi` (`ai/collect/dummyhalfcollectball_ai.lua`) while picking up. With
  `preferredMechanic == Scoot` nothing passes, and once it holds the ball the flowchart rule
  `isPostDummyHalf and shouldScoot => HitGapAi` runs it at the gap. That run *is* the scoot. The veto
  now lives in `DummyHalfCollectBallAi`: one roll in `onEnter`, and if it fails, a dummy-half pass is
  started during the pickup (`executePassCallback` turns it into a collect-and-pass).
- That flowchart rule now also needs `hasBall`. `HitGapAi.onEnter` sends a `ClearPlayRequest`, so a
  dummy half who had already passed could still enter it and wipe the attacking side's set play.
- Debug logging (`DebugLog` in `dummyhalfcollectball_ai.lua`, `dummyhalfcollectmonitor_ai.lua` and
  `generalgameplay/hitgap_ai.lua`) writes `reduce_scoots_debug.txt` to the game folder. The
  `hitgap_ai.lua` override exists only for that log line; drop it for release.
- Why the AI always scooted: in `ai/decisionmaking/decisiontree_ai.flow` the rule
  `isPlayTheBallInProgress and not isNines and (isDummyHalf or isPostDummyHalf) and shouldScoot => Scoot`
  sits above every dummy-half pass rule. The tree takes the first rule that matches and has no
  randomness. `shouldScoot` is a native condition that is set when a marker is offside (`ScootAiMixin`
  asserts `primaryOffside or secondaryOffside`), so the result was a scoot every time. It is the same on
  all difficulties, and only AI sides are affected (`isHumanOnSide and not isBeAPro => None`).
- `ai/collect/dummyhalfcollectmonitor_ai.lua` is the controller the AI dummy half runs while picking up
  the ball (`DummyHalfCollectBallAction`). It rolls once per play-the-ball in `onEnter`.
  - Rule 1: when the tree wants a scoot and the roll fails, it passes instead: quick, then flat, then
    deep, using `getTargetPassCandidate`, so a receiver chosen by an active play is still respected. If no
    receiver is available, it scoots as stock.
  - Rule 2: position comes from `knowledgeBank.playerRoleInfoPool` (`EAssignedRole` Winger/Centre
    Left/Right). Distance comes from `halfFieldLength + pos.x * playDir.x`, and the tackle number from
    `getMatchProgressionEntity().tackleCount`. When the markers are square it calls
    `scoot_helper.executeScoot` itself, using the same gap-side direction `ScootAiMixin` uses. That is the
    path human scoots take, and they don't need offside markers either.
- `ai/flowcharts_ai/master_flowchart_ai.flow` adds one line,
  `isPlayTheBallInProgress and isPostDummyHalf and hasBall and (isWinger or isCentre) => HitGapAi`.
  Without it, a rule-2 scoot with square markers (where `shouldScoot` is false) would hand the ball
  carrier to `DummyHalfAi` instead of running the gap.
  This copy of the flowchart also carries lines from other mods (tagged in comments), because build.py
  allows only one owner per file: `early-defensive-retreat` (QuickDefensiveOnsideAi rules) and
  `fullback-sweeper-defence` (the fullback rules before the primary/important defender rules).
- Tune the rates with the constants at the top of the Lua file (`ScootChance`, `OwnFortyScootChance`,
  `OwnFortyDistance`, `OwnFortyMaxTackleCount`). Setting `ScootChance = 1.0` and `OwnFortyScootChance = 0`
  gives stock behaviour (apart from the flowchart line).
- Unverified: the scripted scoot plays (`Slice_2_Hooker_scoot`, `Slice_13_Dummy_half_scoot`,
  `Slice_6_Greenzone_Crashball_for_lock_(Scoot)`) may also be cut down to `ScootChance`, if they reach
  the scoot through the same `preferredMechanic == Scoot` path.

## Second scoot path closed (2026-11-01)

`decisiontree_ai.flow` had its own rule, `(isDummyHalf or isPostDummyHalf) and shouldScoot => Scoot`, which let
the dummy half pick the Scoot mechanic straight from the pickup, bypassing master_flowchart's HitGapAi rule and
this mod's situational chance (a match had 38 play-the-balls, no HITGAP decision, and still scoots). It's
commented out in ai-last-tackle-kick's copy of the decision tree (one owner per file), so every scoot now goes
through HitGapAi. Base chance also lowered 6 % -> 5 %, cap 50 % -> 40 %.
