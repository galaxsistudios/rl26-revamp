# fix-touch-referee-cameo

When the ball bounces into touch, the stock game blows a short whistle (correct), idles for 1.5 s, and then
cuts to a referee cameo. The cameo signals handover (or scrum), which is a second, long whistle. This mod
skips the cameo. The player who last touched the ball (the kicker, or whoever carried it out) plays a short
"disappointed" reaction cutscene instead.

## Stock flow (`rules/intouch/intouchoutcomes.lua`, `inTouchOnBounceRequestFactory`)

1. `InTouchRequest` fires `InTouchEvent`, which plays `Whistle_Out_Of_Play` (the short whistle).
2. `InTouchIdlePlayersRuleState` runs for 1.5 s. The touch judge raises the flag here.
3. `RefereeCameoRuleState` sets `refereeSignal = HandOver` (or `Scrum` when the match uses scrums). Both
   play the `Action_Group_Referee_Whistle_Blow_01` / scrum signal animation, and `Scrum` also queues
   another `Whistle_Out_Of_Play`.
4. The restart: tap, play-the-ball wipe, or scrum.

The mod replaces step 3 with `InTouchReactionRuleState`. When `lastTouched` is missing, it falls back to
the stock cameo.

## The reaction

`InTouchReactionRuleState` plays the `Conversion_Fail_NoTee` cutscene group on that player. It is the
kicker's reaction to a missed conversion: one player, anchored on them (`PrimaryActor`), with no kicking
tee prop. The cutscene system picks one of its four cutscenes (`rl1_conversion_l_fail_01/02`,
`rl1_conversion_l_01/03`) from the play's random seed. To try another group, change
`InTouchReactionRuleState.CutsceneGroup`.

Both this reaction and the stock conversion cutscene request pass the player's side as `primarySide`.
Stock RL26 leaves it unset, which breaks any cutscene whose actors filter on `side = "primary"`, such as
Rugby 25's post-conversion reactions (`r25-imports`). No actor matches, the duration comes out at −0.5 s,
and the camera pans away without playing anything. RL26's own conversion cutscenes don't filter on side,
so this changes nothing for them.

The class lives in `rules/cutscenes/conversion_cutscene_rulestate.lua`. That module is already in
`rulestate_registration.lua`, and build.py can't add new script files.

## Out on the full

`inTouchOnFullRequestFactory` runs the match type's `onFullTouchGeneralGameplayAction` through
`rules/ruleactions/ruleactionhandler.lua`. `onFullTouchGeneralGameplay` queues a `refereeCameo` action
with `TapRestart`, which plays `Whistle_Penalty` (the penalty-style whistle), or `HandOver` on the last
tackle. The mod's `refereeCameo` action returns `InTouchReactionRuleState` for the offender whenever
`isInTouchInFull` is set.

## Not changed

- Touch-in-goal / dead ball (line drop-out, 20 m tap), 40/20 variations and kick-off out on the full
  keep their stock flows.

## Install

Script mod, entry 39959: `python tools\build.py full --confirm` (game closed).
