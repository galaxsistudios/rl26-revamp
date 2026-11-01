# fix-field-goal-referee-call

Stops the referee from blowing two whistles and shouting "Try!" after a successful field goal.
He now blows one whistle and, if the `sfx_ref_field_goal` bank is installed, calls "Field goal".

## The stock bug

A successful field goal makes two referee sound cues:

1. `FieldGoalSuccessEvent` plays `Whistle_Penalty` (0.2 s delay) in `soundlistener_referee.lua`.
2. `ReactToScoreRuleState` (`rules/scoring/reacttoscore_rulestate.lua`) handles tries and field
   goals with the same code. When no referee is within `tryCameoDistance` of the ball (always true
   for a field goal, since the ball is over the crossbar), it sends a sound-only
   `TryCelebrateEvent`. That event plays `Whistle_Try` and `sfxRefTry` ("Try!").

When a referee *is* close enough, the cameo path runs instead. A field goal has no
`tryAttemptOutcome`, so that path sends no signal and no sound.

## What the mod changes

- `reacttoscore_rulestate.lua`: `TryCelebrateEvent` is only sent when `isFieldGoalAttempt` is false.
- `soundlistener_referee.lua`: `onFieldGoalSuccessEvent` clears the referee's queued chatter, plays
  the one `Whistle_Penalty`, then posts the `sfx_ref_field_goal` event after `FieldGoalCallDelay`
  (0.8 s). The bank is loaded with the referee's sound object and unloaded with it (not in practice
  mode). Golden-point and full-time field goals skip `ReactToScoreRuleState`, but they still get
  this call because it hangs off `FieldGoalSuccessEvent`.

## The "Field goal" voice line

`OnfieldRefereeVocals` has 22 events, and every event hash matches a known `sfxRef*` name. There
is no field goal line, so the call has to come from a new bank:

```powershell
python tools\add_sound_bank.py add --name sfx_ref_field_goal --audio resources\referee-calls\field_goal.wav --fade-in-ms 0 --no-normalize --volume-db 0 --confirm
```

- Use a short, dry clip of a referee shouting "Field goal" (any format ffmpeg reads).
- Use `--replace` to swap the clip later. Scripts don't need a rebuild for that.
- The bank clones a menu-song bank, so the call goes through the music mixer. It isn't positional,
  and the music volume setting affects it. Adjust `--volume-db` to match the stock calls.
- Then set `FieldGoalCallEnabled = true` in `soundlistener_referee.lua` and rebuild 39959. It ships
  `false`: loading a bank that isn't in the blobset is a native fatal error (0xC0000409, the crash
  stack shows `sound/sfx_ref_field_goal.bnk`), and `pcall` can't catch it. It crashes on "continue"
  into a match. With the flag off, the field goal just gets its single whistle.

## Also carries bunker-broadcast-decision

`onVideoRefereeDecisionEvent` blows `Whistle_Try` `BunkerTryWhistleDelay` (3.25 s) after a bunker
TRY decision, when the event carries `bunkerBroadcast`. That is as the TRY text lands. See
[bunker-broadcast-decision](../bunker-broadcast-decision/).

## Handover whistle

Stock handover cameos (sixth-tackle handover, last-tackle kick out on the full) have no whistle.
`onRefereeSignalEvent` now plays `HandOverWhistle` (`Whistle_Out_Of_Play`, the short touch whistle)
when the `HandOver` signal starts. It uses `playEvent`, not `queueEvent`: queued referee events
share one tag and wait for each other, so a queued whistle would sit behind the "Handover" call
that `HandOverEvent` queues just before the cameo.

## Install

Script mod, entry 39959: `python tools\build.py full --confirm` (game closed).
