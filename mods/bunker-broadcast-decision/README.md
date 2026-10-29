# bunker-broadcast-decision

A broadcast-style video referee (bunker) sequence:

1. The referee sends the try upstairs (stock cameo).
2. **Wipe in:** the stock RL26 logo wipe slides in over the end of the cameo.
3. The bunker replay plays as normal, and the wipe slides off once it is playing.
4. The bunker card shows "Decision pending", then the decision slams in big:
   - **TRY**: white with a green outline and a pulsing green glow. The referee blows the try
     whistle as it lands, then the stock "Try!" call, the crowd, and the try music (or the club's
     song, see [team-try-songs](../team-try-songs/)).
   - **NO TRY**: white with a red outline and a pulsing red glow (stock: flat white).
5. **Wipe out:** on a TRY, the scoring team's stinger (replay-team-stinger's
   `TeamStinger.kickCover`, through `LogoTransitionHud.bunkerTeamCoverCut`) covers the bunker
   card. If the stinger is busy or missing, the logo wipe covers it instead. On a NO TRY, the
   logo wipe covers it...
6. ...and slides off once the next shot is playing:
   - TRY: a try celebration. Stock bunker tries had none and went straight to the conversion.
   - NO TRY: a disappointed reaction shot. It uses the captain's challenge "lost" cutscene: the
     referee, the attacking captain and two team-mates. Then play restarts the stock way.

Online matches and training keep the stock bunker flow.

## Files

This mod owns one file. The rest of its code lives in files other mods already override (two mods
can't override one file). Each of those changes is marked `bunker-broadcast-decision`.

| File | Mod | Entry | Change |
|---|---|---|---|
| `noesis/workspace/views/hud/rugby/pabunkercontrol.xaml` | **this mod** | 57662 | The decision visuals. Taken over from rl26-revamp-branding with its `Height="150"` logo fix kept. `make_branding.py` no longer writes it. |
| `rules/cameo/refereecameo_rulestate.lua` | bunker-overturned-try | 39959 | Decides if the presentation runs and publishes `BunkerBroadcastState`. Starts the stinger in, holds the cut to the bunker until it covers. Owns the debug log. |
| `rules/cutscenes/trydecisionpending_rulestate.lua` | bunker-overturned-try | 39959 | Shorter decision hold. Tags the decision sound event. Stinger out. Picks the celebration or reaction. New `BunkerNoTryReactionRuleState`. |
| `app/noesis/hud/nvm_scorecard.lua` | bunker-overturned-try | 39959 | `showTryConfirmed` is a no-op, so there's no "Try Confirmed" banner under the scoreboard (`ShowTryConfirmedBanner = true` brings it back). |
| `base/transition/logotransition_hud.lua` | replay-team-stinger | 39959 | `LogoTransitionHud.bunkerKick` / `bunkerIsCovered` / `bunkerCoverCut` / `bunkerRelease`, and `bunkerCoverUpdate` (slides the wipe off once a new cutscene plays). The team-stinger variant (`kickBunkerReplay`, `kickCover`) is still there, switched off by `BunkerTeamStinger = false`. |
| `base/transition/screenwipe.lua` | replay-team-stinger | 39959 | The bunker replay's barrier waits for the logo to cover; the wipe-in slides it off once the replay plays. |
| `simlisteners/sound/listeners/soundlistener_referee.lua` | fix-field-goal-referee-call | 39959 | The try whistle. |
| `simlisteners/sound/listeners/soundlistener_ingame_music.lua` | team-try-songs | 39959 | The try music. |

Install (game closed):

```powershell
python tools\pack.py restore --entry scripts
python tools\build.py full --confirm

python tools\pack.py restore --entry xamls
python tools\extract_m3mp.py --entry xamls --out <tmp>
python tools\build.py full --list manifests\xamls.xml --extracted <tmp> --out _build\xamls.m3mp --confirm
```

## Transition style (changed 2026-10-27)

The first build used replay-team-stinger's team stinger for both transitions. After the first
in-game test the user asked for the default one, so both now use the stock RL26 logo wipe
(`LogoTransitionHud`, the conversion wipe). It takes about 1 s to cover, so the cameo kicks it
`BunkerStingerLead` = 1 s before it ends (hold timeout 1.5 s), and the decision exit waits up to
1.5 s. The cameo flags the queued bunker replay `bunkerLogoWipe`. `ScreenWipeOut` holds its
barrier until the logo covers (kicking it there over a frozen frame if the cameo didn't), and
`ScreenWipeIn` releases it 0.15 s after the replay is visibly playing (7 s timeout). "Visibly
playing" means the presenter's playhead (`pools.replayTime`, written by `presentFrame`) has moved.
`isInPlayback()` goes true before any replay frame is on screen. `ScreenWipeOut` also sets
`bunkerHold` on the logo, so the stock `setNextStateIsReady()` that `ReplayUStatePlayingState`
calls as soon as loading completes is ignored. Before this, the logo could slide off to show
the bunker frame over the frozen referee cameo. The section below
still describes the stinger version in places; the timings and hand-offs are the same apart
from the cover time.

## How it works

```
ReactToScore(decisionPending)
  -> RefereeCameo(VideoReferee)        publishes BunkerBroadcastState, queues the bunker replay
       stinger in 0.55 s before the cameo ends; the cut waits until it covers
  -> [barrier: bunker replay]          ScreenWipeOut finds the stinger already in;
                                       ScreenWipeIn slides it off once the replay plays
  -> TryDecisionPending                Pending 3 s -> TRY / NO TRY, card held 6.5 s in total
       stinger in (kickCover); the next state is requested once it covers
  -> TryCelebrate (TRY)                    or  BunkerNoTryReaction (NO TRY)
       stinger reveals once the new cutscene is playing
  -> stock nextState (conversion / restart)
```

- **Who's on:** `RefereeCameoRuleState.onEnterSolid` checks every video-referee cameo whose next
  state is `TryDecisionPendingRuleState`.
  - The presentation runs unless the match is online, in training, or has no valid attacking
    side.
  - It then sets `_G.BunkerBroadcastState = {side, scorerId}` (from the try decision entity), or
    clears it.
  - Everything else only acts when that state is set, so the stock flow is untouched otherwise.
  - `TryDecisionPending.onExitSolid` clears it.
- **Stinger in:** the cameo tracks its own time: the stock 5 s, or bunker-overturned-try's 2.4 s
  after the signal.
  - `BunkerStingerLead` (0.55 s) before the end, it calls `TeamStinger:kickBunkerReplay`. That
    kicks the stinger for the tagged, queued bunker replay.
  - At the end it waits for `isCovered`, at most `BunkerStingerHoldTimeout` (1.2 s), before it
    requests the next state.
  - A skip latches (`bunkerLeaving`) and kicks straight away.
  - From the barrier on, replay-team-stinger's normal replay path takes over. If the cameo never
    kicked, the barrier kicks it over a frozen frame.
- **Decision:** `VideoRefHud` is unchanged. It shows Pending, then the decision after 3 s; the new
  XAML states do the rest.
  - `VideoRefereeDecisionEvent` also carries `bunkerBroadcast` and `scoringSide`.
  - The referee listener queues `Whistle_Try` at `BunkerTryWhistleDelay` (3.25 s). The stock
    "Try!" call stays at 4 s.
  - The music listener starts the celebration music at `BunkerTryMusicDelay` (3.6 s), with the
    scoring club's song when it has one. The stock stop points (conversion setup, kick-off) fade
    it out as usual.
- **Stinger out:** the card is held `BunkerDecisionHoldTime` (6.5 s, stock 8 s), then skips.
  - Leaving (or a skip by the player) kicks `TeamStinger:kickCover(team)` and waits for it to
    cover (at most 1.2 s). Only then does it request the follow-up state.
  - The card is hidden under the stinger.
  - There is no barrier at this cut. So the stinger reveals itself once a cutscene that wasn't
    current at the kick has been playing 0.2 s, or after 3 s.
- **Follow-up states:**
  - TRY: a `BunkerTryCelebrateRuleState`. It plays the stock `TryCelebrateRuleState` (`queueReplay = false`, standing celebration, the scorer from
    the decision entity) but sets every player to `Idle` and skips the stock `updateSolid`. That one sends everyone to `TeamScored`/`finalMove` with targets that are stale after the bunker, so the off-camera players ran across the field. Its `nextState` is the stock one. If the scorer can't be found, it goes
    straight to the stock `nextState`.
  - NO TRY: `BunkerNoTryReactionRuleState` plays `rl1_captains_challenge_lose_01` the way
    `CaptainsChallengeOutcomeCutsceneRulestate` does, without the challenge count or HUD. It
    hands on to the stock `nextState` when the cutscene finishes, or after 12 s.
- **bunker-overturned-try:** its provisional tries end in a bunker NO TRY. They get the same
  stinger in, decision, stinger out and reaction.

## The XAML

Rebuilt 2026-10-27 after the first version crashed the game. That version stacked four
`BlurEffect` text layers (radius 35-60 on 340 px text) and an extra forever animation, and the
crashes were heap corruption that only showed up later. It is kept for reference as
`_disabled_mods/bunker-broadcast-decision/pabunkercontrol.CRASHED-blur-version.xaml`.

The current card sticks to what the stock card already does safely:

- **Text:** `TryText` (green) and `NoTryText` (red) replace the stock `DecisionTextBlock`. Each is
  built exactly like it (same transform group, a `DropShadowEffect` glow, a stroke), at 340 px with
  a 10 px coloured outline.
- **Entrance:** the `Try` / `NoTry` states fade the text in over 0.15 s and scale it from 0.75 to 1
  over 0.3 s, once. The stock flicker loop is gone.
- **Glow:** the glow pulses 0.5 -> 1 -> 0.5 forever, as stock does.
- **Background:** `TryWash` / `NoTryWash` are full-card gradient rectangles behind everything,
  clear at the top and green or red toward the bottom. `TryFrame` / `NoTryFrame` are 6 px coloured
  outlines over the replay frame's border. All four fade in over 0.3 s with the result. The side
  stripes, floor glow and "THE BUNKER" title keep the brand blue.
- **Effects:** no `BlurEffect` beyond the stock three (the build script checks this), and fewer
  forever animations than stock.
- **Colours:** explicit, `BunkerTryCol` `#27F06E` and `BunkerNoTryCol` `#FF2E3F`.
  rl26-revamp-branding recolours `RLGreen` to blue.

The file is generated by a scratch script from the stock (branding) copy, so to change it, edit
the XAML directly.

## Tuning

| Setting | File | Default |
|---|---|---|
| `BunkerBroadcastEnabled` | refereecameo_rulestate.lua | `true`. `false` = the stock bunker everywhere |
| `BunkerStingerLead` / `BunkerStingerHoldTimeout` | refereecameo_rulestate.lua | 0.55 s / 1.2 s |
| `BunkerDecisionHoldTime` | trydecisionpending_rulestate.lua | 6.5 s from the decision state starting (Pending is the first 3 s) |
| `BunkerNoTryReactionCutscene` / `...Timeout` | trydecisionpending_rulestate.lua | `rl1_captains_challenge_lose_01` / 12 s |
| `BunkerTryWhistleDelay` | soundlistener_referee.lua | 3.25 s |
| `BunkerTryMusicDelay` | soundlistener_ingame_music.lua | 3.6 s |
| `BunkerCoverRevealDelay` / `BunkerCoverMaxHold` | logotransition_hud.lua | 0.2 s / 3 s |
| Text size, colours, washes, glow | pabunkercontrol.xaml | see above |

## Debugging

`BunkerBroadcastDebug` (refereecameo_rulestate.lua, currently **on**) appends to
`bunkerbroadcast_debug.txt` in the game folder. A bunker TRY logs:

```
cameo: sending it upstairs, bunker presentation on, attacking side N
cameo: cameo ending, stinger kicked
decision pending: TRY, next ConversionKickSetupRuleState
decision: leaving, stinger kicked
decision: on to the try celebration
```

A NO TRY logs `on to the no-try reaction` and then `no-try reaction: rl1_captains_challenge_lose_01
for side N`. The stinger's side of it goes to `teamstinger_debug.txt`:

- `replay queued during RefereeCameoRuleState (bunker), stinger for <club>`
- `barrier: stinger already in`
- `cover: cutscene <name> playing after Xs`
- `cover: releasing`

To force a bunker on every try, use bunker-overturned-try's `ProvisionalTryTestOutcome` (NO TRY). For
a bunker TRY, the stock `TryDebugHook.forceVideoReferee` or the 25% tackled-try roll in
`trySuccessRequestFactory`.

## Status

Built 2026-10-27. Both bundles build and self-verify. A stubbed LuaJIT harness passes (33 checks):

- tagging;
- cameo kick timing and skip;
- the cover/reveal timing;
- the decision follow-up states;
- the reaction state's finish and timeout;
- the stock fallbacks.

**First in-game test (2026-10-27, team stinger build):** it crashed as the bunker replay
started playing, in a provisional (held-up) try flow. The dump
(`_crashdumps/rugbyleague1.exe.55428.dmp`) shows a native access violation in an animation job
thread (exe+0xe428ba, a pose copy). Its destination pointer was ASCII text ("redictab"), and
commentary data (`c:winning_team`) sat in that block. That's a use-after-free of character
animation memory. No new Lua passed anything to native animation code, so it isn't tied to this
mod yet. The logo-wipe build is installed for a retest. If it crashes again at the same point, set
`BunkerBroadcastEnabled = false` and repeat, to see whether it's this mod at all.

**Logo-wipe build: not yet tested in game** (logo-wipe harness: 18 checks pass). Things to watch for:

- that the HUD can see the referee cameo's replay queue (the barrier fallback covers it if not);
- how the captain's challenge "lost" cutscene reads as a no-try reaction (its referee animation
  was made for a challenge);
- whether the whistle and music timing lands on the text.
