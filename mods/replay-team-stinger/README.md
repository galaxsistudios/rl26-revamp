# replay-team-stinger

A broadcast-style stinger between a try celebration and its replay. Two skewed panels sweep in
from the right: a band in the scoring team's **secondary** colour, then a full-screen panel in its
**primary** colour. The club crest lands in the middle. The stinger covers the end of the
celebration, holds while the replay loads, then sweeps off to the left once the replay is playing.

Touches two bundles (see INSTRUCTIONS.md):

| Files | Entry |
|---|---|
| `src/script-game/base/transition/logotransition_hud.lua`, `.../screenwipe.lua` | 39959 (scripts) |
| `noesis/workspace/views/tests/matchintro.xaml` | 57662 (Noesis XAML) |

```powershell
python tools\pack.py restore --entry 39959
python tools\build.py full --confirm

python tools\pack.py restore --entry 57662
python tools\extract_m3mp.py --entry 57662 --out <tmp>
python tools\build.py full --list manifests\57662.xml --extracted <tmp> --out _build\entry_57662.m3mp --confirm
```

## Which replays get it

Tries (including the cheerleader celebration after a try) and field goals, both the 1-point and the
40m 2-point kind (both celebrate in `FieldGoalCelebrateRuleState`). Bunker and referee-cameo
replays keep the stock crossfade, and so does everything when replays are off in
settings.

## How it works

- **The view:** `views/tests/matchintro.xaml` is an unused test view (`sim/hud/introversus_hud.lua`
  is never imported). Its content is replaced, because `build.py` can't add new files. It's loaded
  once per match on `POST_SCENE` / `HighPriority`, the same layer as the stock logo wipe, and
  stays collapsed until it's needed.
  - The view model is `NVMTeamStinger`, with `StingerState` (`hidden`/`in`/`out`, which drives the
    storyboards through `ei:DataTrigger`) and `Team`.
  - `Team` points at the HUD's own `homeTeamNVM`/`awayTeamNVM`, so colours and crest
    (`large_mirrored`) are the ones the scoreboard already loaded.
  - `NVMTeamStinger.dispose` clears `Team` first: `ViewModel.dispose` disposes every VM held in a
    property, and that would take the HUD's NVMTeam with it.
- **Owner:** the `TeamStinger` class lives in `logotransition_hud.lua`. `LogoTransitionHud` exists
  in every match HUD and is created, updated and disposed with it, so `hud_registration.lua`
  (owned by gf-intro-effects) doesn't need touching.
- **Spotting a try replay:** `TryCelebrateRuleState` queues its `ReplayUniverseState` into
  `matchSim.universeStateQueue` as the celebration *starts*. The queue is only pushed at the next
  barrier.
  - Each frame, `TeamStinger.update` tags any new queued replay with the scoring side's NVMTeam,
    but only if the solid rule state is `TryCelebrateRuleState`, `CheerleaderCelebrateRuleState`
    or `FieldGoalCelebrateRuleState` (`TeamStingerRuleStates`). Field goals work the same way:
    the replay is queued as the celebration starts.
  - The side comes from the cheerleader state's `scoringSide`, or from the try scorer's game
    object.
- **Slide in:** while a tagged replay is queued, it watches `cutsceneListener.currentCutscene`.
  When `duration - time` drops to `TeamStingerCoverTime` (0.5 s) + `TeamStingerLeadTime`, it kicks.
  The panel then finishes covering just as the celebration ends.
  - A cutscene only counts once it's been seen with more than that left, so a stale finished
    cutscene can't fire it early.
- **The barrier:** after the celebration, `ConversionKickSetupRuleState` (no `wipe`) hands straight
  to `PlaceKickPositionBallRuleState` (`wipe`). That barrier pushes the replay, using the stock
  `ScreenWipe` (Crossfade).
  - `ScreenWipeOut` sees the tagged replay on top of `nextStack`.
  - `acceptBarrierComplete` waits until the stinger is `covered`.
  - If the celebration was skipped (so nothing kicked), the barrier kicks the stinger itself and
    `capture()`s, freezing the last frame under the slide-in.
- **Slide out:** `ScreenWipeIn` sits above the replay state. Once its `replayPresenter:isInPlayback()`
  goes true (or the replay state is gone), it waits `TeamStingerRevealDelay` (0.15 s) for the replay
  camera to settle, then releases the stinger. It removes itself after the 0.5 s slide-out.
- **Never hangs a transition:** every stinger call from the barrier states is `pcall`ed.
  - The barrier stops waiting after 1.2 s and the wipe-in after 7 s.
  - The stinger releases itself if it's been covering for 5 s (`TeamStingerMaxHold`).
  - At worst, a failure loses the effect, never the match.

## Big hit / strip before a try

The stock replay picker (`design/replaymoments_selection.lua`, `Select`) returns a `ballstrip` or
`knockon` moment on its own, ahead of `tryscored` and `goal`. Those moments also use the video
referee's 8-angle sequence. So a strip just before a try replayed only the strip, several times
over. Now the hit plays once, the stinger plays between, and then the try replays:

```
celebration -> stinger -> hit replay (once) -> stinger -> try replay -> stock logo wipe back
```

All of this lives in `listeners/replay/replay_listener.lua`. **That file belongs to
bunker-overturned-try**, because two mods can't override one file, so build both. Without
replay-team-stinger the hit cuts straight to the try.

- **Single pass:** `onBallStrip`/`onKnockOnEvent` also record a `bighit` moment at the same time
  (`Sequences.BigHit`: one close tripod shot, 1 s either side, half speed). `leadUpSinglePass`
  swaps it in for the lead-up.
- **Split:** when a `tryscored` or `goal` moment is there too, the `ballstrip`/`knockon` moments are
  taken out (`LeadUpReplayAliases`). The hit replay is queued, carrying the scoring replay as
  `followUpReplay`, a function that builds it on demand. Video referee, provisional-try and online
  replays are left alone.
- **No barrier between the replays:** a try replay's end barrier is the RL26 logo wipe into the
  conversion (`LogoScreenWipeOut`), not `ScreenWipeOut`, so a barrier hook never fired. The hit
  replay instead gets per-instance overrides:
  - `endState` builds the try replay, kicks the stinger with it and holds the last frame
    (`stateEnded`, so no barrier).
  - `update` waits for `isCovered` (or `LeadUpCoverTimeout`, 1.5 s). It then removes itself and
    inserts the try replay at the same stack index, marked solid.
  - The try replay's own `update` override calls `TeamStinger:updateReveal`, which releases the
    stinger once it plays.
  - The try replay then ends the stock way. The sim's pending wipe and the logo wipe run once, as
    after any replay.
- **Skipping:** skipping the hit replay ends it the stock way, without the try replay. If the swap
  can't happen, it ends the stock way too and the stinger is released.

`replaymoments_debug.txt` (`ReplayMomentsDebug` in that file) logs:
- every replay event, and where recording starts and stops;
- the moments found and selected;
- `lead-up replay ending, stinger kicked into the try replay` → `swapped in the try replay at N of M`.

`teamstinger_debug.txt` logs each replay's playback window.

## Outro for bunker-overturned-try

A replay flagged `provisionalTryReplay` (set by bunker-overturned-try's `replay_listener.lua`)
also gets the stinger on its way **out**. That cuts back to the referee, who sends the try upstairs.

- When `ScreenWipeIn` releases the intro into a flagged replay, the outro is armed
  (`TeamStinger.pendingOutroTeam`). The next `ScreenWipeOut` is that replay's end barrier: it
  calls `TeamStinger:kickOutro(team)` and `capture()`s. A first version searched the universe
  stacks for the ended replay, and never found it in-game.
- The usual `acceptBarrierComplete` cover wait and `ScreenWipeIn` release apply. With no replay to
  wait for, the release comes `TeamStingerOutroRevealDelay` (0.35 s) after the barrier, while the
  referee cameo camera takes over.

Nothing else sets the flag, so without bunker-overturned-try this path never runs.

`TeamStingerOutroStyle` in `screenwipe.lua` picks the outro:
- `"logo"` (default): the stock Rugby League 26 logo wipe. `LogoTransitionHud:kick()` runs at the
  end barrier, which waits for `readyToTransition()`. `ScreenWipeIn` calls `setNextStateIsReady()`
  `LogoOutroRevealDelay` (0.35 s) later.
- `"team"`: the team stinger again.

## Conversion logo wipe (earlier start)

This is the stock logo wipe after a conversion, also in `logotransition_hud.lua`.

**The problem:** the conversion result cutscene hands to `KickoffSetupRuleState` (no `wipe`), then to
`PositionPlayersTransitionRulestate`. That state's `LogoScreenWipeOut` `capture()`s, freezing the
frame the moment the barrier starts, and only then kicks the wipe. So the cutscene visibly stopped
while the wipe slid in.

**The fix:** while the solid rule state is `ConversionCutsceneRuleState` and its `nextState` is
`KickoffSetupRuleState`, the HUD kicks the logo wipe `LogoPreKickLeadTime` (1 s) before the cutscene
ends. The freeze then happens under an already-covering wipe.
- `LogoScreenWipeOut` (`checkWipeState`) doesn't re-kick a running wipe, and waits for it to cover.
  The stock flow releases it as before.
- End-of-half conversions (`TimePeriodExpiredIdleRuleState` next) are left alone.
- Safety: if no `LogoScreenWipeOut` appears within `LogoPreKickTimeout` (3 s) of the early kick,
  the HUD releases the wipe itself.

The log line `conversion wipe: barrier arrived Xs after kick, covered: true/false` shows whether
the lead was long enough. `false` means raise `LogoPreKickLeadTime`. To give other cutscene →
logo-wipe hand-offs an early kick, add them to `LogoPreKickRuleStates`.

## Tuning

| Setting | Where | Default |
|---|---|---|
| `TeamStingerCoverTime` / `TeamStingerOutTime` | logotransition_hud.lua | 0.5 s. Must be at or above the `StingerIn`/`StingerOut` storyboards (0.46 s) |
| `TeamStingerLeadTime` | logotransition_hud.lua | 0.05 s extra head start before the cutscene ends |
| `TeamStingerRevealDelay` | logotransition_hud.lua | 0.15 s hold after replay playback starts |
| `TeamStingerMaxHold` | logotransition_hud.lua | 5 s safety release |
| `TeamStingerRuleStates` | logotransition_hud.lua | which rule states' replays get it |
| Panel shapes, skew, crest size, easing | matchintro.xaml | see the comment at its top |

## Debugging

`TeamStingerDebug = true` (currently **on**) appends to `teamstinger_debug.txt` in the game folder:

- view creation;
- each tagged replay (rule state, team);
- the watched cutscene and kick time;
- barrier attach/kick;
- release reason and finish;
- any error.

A normal try logs `replay queued during TryCelebrateRuleState, stinger for <club>` →
`watching cutscene ...` → `kick from cutscene` → `covered` → `barrier: stinger already in` →
`replay playing, releasing` → `finished`.

If the log shows `has no usable time` for the cutscene, the pre-kick can't run, and the stinger
falls back to starting at the barrier.

A stubbed LuaJIT harness covers the normal, skipped-celebration, referee-cameo and stalled-HUD
flows. It isn't kept in the repo. Rebuild it from these notes if the logic changes.
