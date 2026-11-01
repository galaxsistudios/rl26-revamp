# Gameplay AI

## Controllers, flowcharts and decision trees

Each AI player runs a **controller** (`ai/**/*_ai.lua`, e.g. `HitGapAi`, `DummyHalfCollectBallAi`,
`PrimaryDefensiveMovementAi`). Which controller runs is picked by text flowcharts:

- `ai/flowcharts_ai/master_flowchart_ai.flow` (+ `action_overrides_flowchart_ai.flow`): `conditions =>
  Controller`, first match wins. Set pieces swap in their own flowchart; kick-offs use
  `placekick_flowchart_ai.flow` for everyone.
- `ai/decisionmaking/decisiontree_ai.flow`: picks a **mechanic** (scoot, pass, kick...) into
  `knowledgeBank.playerMechanicDecisionPool`, which the `*_ai_mixin.lua` controllers obey. Deterministic, no
  random numbers.
- Conditions (`isPostDummyHalf`, `shouldScoot`, `isInGreenZone`, ...) are computed natively and share one
  registry across both file types. An unknown name crashes at boot.

Controllers get re-entered often (they drop out and come back), so per-play decisions need timed state, not
`onEnter` resets. Controller time arguments are native `Time` userdata.

## Attack plays

The game reads the compiled `plays/playset.dat` (193 plays) and `plays/formationset.dat` (44 set-piece layouts)
through a native play set manager. The `intermediatelua/plays/*.lua` files are authoring copies the game never
loads. Each play has a field slice (0-13 across the width), zone and tactic tags, and participants with ruck-relative
roles (EPlayRole: 0-12 positions, 14 dummy half, 15 first receiver). Selection weights are in
`design/playselection_config.lua`. The weight for the called tactic's tag is native.

## Formations

Open-play and defensive positions come from **force-directed graphs**
(`intermediatelua/forcedirectedgraphs/forcedirectedgraphs_rugby.lua`, 63 graphs). The native pool is fixed,
so adding a 64th graph crashes the match load. Native code picks `...10m` and `...LastTackle` variants by name suffix.

## Native-only systems

- **Interchanges** for AI sides run on a fixed clock (props around 20/38/60', hooker 55', lock 65'). Lua
  substitution requests for an AI side are ignored unless the match is Be a Pro. `interchange_config.lua` isn't
  read natively.
- Stamina, fatigue, tackle physics and the line-break gap finding are native. Lua reads derived attributes such as
  `maxStamina`.
- EAssignedRole ids: FB 0, WL 1, CL 2, CR 3, WR 4, 5/8 5, HB 6, PropL 7, Hooker 8, PropR 9, 2RL 10, 2RR 11,
  Lock 12, Sub 13.

## Rule states

The referee flow (tries, video referee, conversions, scrums, penalties, sin bins) is Lua rule states in
`rules/`. A no-try call always goes to the video referee. There's no API to take back a score once it's given.
Scrums, play-the-ball speed and discipline are partly Lua (timings, events) and partly native (contests).
