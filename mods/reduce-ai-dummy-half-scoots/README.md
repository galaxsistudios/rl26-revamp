# reduce-ai-dummy-half-scoots

AI scoots follow two rules instead of happening on every play-the-ball where the markers aren't square:

1. **Markers offside:** the dummy half scoots only `ScootChance` of the time (default 10%) and passes otherwise.
2. **Own 40:** a winger or centre at dummy half, within 40 m of their own try line and on tackles 1–3,
   scoots `OwnFortyScootChance` of the time (default 25%), whether the markers are square or not.
   The stock AI never does this.

Anything else that isn't one of those two cases is a pass.

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
- Tune the rates with the constants at the top of the Lua file (`ScootChance`, `OwnFortyScootChance`,
  `OwnFortyDistance`, `OwnFortyMaxTackleCount`). Setting `ScootChance = 1.0` and `OwnFortyScootChance = 0`
  gives stock behaviour (apart from the flowchart line).
- Unverified: the scripted scoot plays (`Slice_2_Hooker_scoot`, `Slice_13_Dummy_half_scoot`,
  `Slice_6_Greenzone_Crashball_for_lock_(Scoot)`) may also be cut down to `ScootChance`, if they reach
  the scoot through the same `preferredMechanic == Scoot` path.
