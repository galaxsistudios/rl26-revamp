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

## hia-protocol

`InjuryCameoRuleState` has a `hiaConcussion` member for [hia-protocol](../hia-protocol/): set by
referee-on-report's `penalty.lua` in front of a high tackle penalty that started an HIA, it plays
`HIAConcussionCutscene` (`InjuryConcussion_01`) for that player without reading the injury pool
(an HIA player has no injury), and skips the stock interchange (hia-protocol makes its own free one).

### Shorter HIA scene (start offset)

The HIA plays about half of the 12.7 s concussion clip: `HIAConcussionStartSeconds` (3.5) in, and
`HIAConcussionEndSeconds` (3.0) cut off the end, about 6.2 s (constants at the top of
`rules/injury/injurycameo_rulestate.lua`). Normal head injuries still play it whole.

- The end uses the play event's stock `waneTime` (the cutscene's duration is its longest animation
  minus `waneTime`).
- The start needs two stock-file overrides here: `game/cutscenes/cutsceneplayevent_request.lua`
  adds a `startOffset` member, and `game/cutscenes/cutscene_listener.lua` backdates the start time it
  sends in `CutsceneLoadedRequest` by that much. Actors and cameras are both timed from that start,
  so they begin `startOffset` seconds in, in sync, and the scene ends that much sooner. Only events
  with a `startOffset` are affected. If a cutscene is already queued ahead of it, the native queue
  chains it after that one and the offset is lost.
- hia-protocol's `hia_debug.txt` logs `cutscene InjuryConcussion_01: starting 3.50 s in (ok), 6.20 s
  long` (or the error if backdating failed).

Untested in game.
