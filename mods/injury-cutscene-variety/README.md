# injury-cutscene-variety

RL26 ships two injury cutscene animations it never plays: a 12.7 s **concussion** and a 9.0 s
**hamstring** (`injury_concussion_01` / `injury_hamstring_01` in `animations/cutsceneInjuries`, with
motion-set records). This mod gives them cutscene definitions and lets the injury cameo pick them.

| Injury region | Cutscenes (random pick) |
|---|---|
| Head | `InjuryHead_01` (stock), `InjuryConcussion_01` |
| Upper leg | `InjuryKnee_01` (stock), `InjuryHamstring_01` |
| Lower leg, arm, back, torso | stock only |

It uses only RL26's own animations, so it belongs to the main Revamp, not the Rugby 25 expansion.
The two definitions are modelled on Rugby 25's `InjuryConcussion_01` / `InjuryHamstring_01`.

## Files

- **`intermediatelua/cutscenes/data/cs_injury_data.lua`:** the stock file plus the two definitions.
  - They are built from stock `InjuryHead_01`: one player actor, cameras following him, anchored on
    him.
  - The concussion clip only animates `cs_camera01`/`02`, so `cs_camera03` and its cut are left out.
- **`rules/injury/injurycameo_rulestate.lua`:** stock keeps a list of cutscenes per region but always
  played the first. This mod picks one at random
  (`native.Random.FromSystemTime():next(1, #list)`).

The injury flow itself is stock: a player hurt in a tackle →
`PlayTheBallSetupRuleState` → `InjuryStopPlayRuleState` → `InjuryCameoRuleState`.

RL26 also ships older `injury_<region>_01` clips (3.3 s, alongside the `p1_rl1_*` ones it plays).
They look like earlier takes of the same scenes, so they aren't used.

## Install

Script mod, entry 39959: `python tools\build.py full --confirm` (game closed).
