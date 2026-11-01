# referee-on-report

High tackle penalties get the referee's close-ups before the penalty choice, and **30%** of them
put the offender on report:

1. Close-up of the referee's high tackle signal (`referee_high_tackle_01`).
2. If on report: in the same close-up, with no cut, he turns to the camera and gives the
   **Report** signal (`referee_report_01`, never used by the stock game), starting at the arm
   cross (the whistle blow is cut off).
3. The penalty choice (kick for goal / touch / tap) as normal. With a report, `<SURNAME> ON
   REPORT` slides out under the scoreboard once it's back on screen, like the try confirmed
   banner but without the arrows, for 4 seconds.

Stock, the referee signals from wherever he is while the choice comes up at once, and the CPU
picks instantly, so the signal is never seen. Sin bins and send-offs still happen on their own
rules (their cutscene comes after the choice). Online matches, practice and training keep the
stock flow.

Two bundles (game closed; see INSTRUCTIONS.md):

| Files | Entry |
|---|---|
| `src/script-game/...` (this mod) | 39959 (scripts): `python tools\build.py full --confirm` |
| banner in `mods/nrl-broadcast-scoreboard/.../defaulthudresources.xaml` | 57662 (Noesis XAML) |

The banner lives in nrl-broadcast-scoreboard's copy of `defaulthudresources.xaml`, because two
mods can't override the same file. Without the XAML part, the close-ups and report still
happen but there's no banner. Only the default scoreboard (NRL and others with no HUD theme) has
the banner. Super League, Origin, QLD Cup and RLWC use their own scoreboard templates.

## How it works

```
stock:  PenaltyIdle (1 s, ref signals far away) -> PenaltySelectSetup -> PenaltySelectPending
mod:    PenaltyIdle -> RefereeCameo(HighTackle [+ Report]) -> PenaltySelectSetup
        -> PenaltySelectPending
```

| File | Change |
|---|---|
| `rules/penalty/penalty.lua` | `generatePenaltyAwardedState`: for a `HighTackle` penalty, rolls `OnReportChance` and puts a `RefereeCameoRuleState` (the stock referee close-up state used for tries and the video referee; `skipReplayEvent`, so no replay) in front of `PenaltySelectSetup`. The `PenaltyAwardedRequest` sets no referee signal, so he doesn't also signal from afar. A report goes into `_G.OnReportState.pending` and `.reports`. Settings and debug log are at the top. |
| `sim/hud/gameplayscore_hud.lua` | Listens for `RefereeSignalEvent`. On `Report` with a pending report, queues `<SURNAME> ON REPORT`. Once the scoreboard is back on screen after the close-ups (plus `OnReportBannerDelay`, 0.75 s), it sets the scorecard's `MatchStateMessage` and `ShowMatchState`, and clears them after `OnReportBannerSeconds` (4). Those two bindings exist on `NVMScoreCard` but the stock game never sets them, so `nvm_scorecard.lua` (owned by bunker-overturned-try) is untouched. A new match HUD clears `OnReportState`. |
| `ai/officials/refereesignal_action.lua` | When the high tackle signal wanes with a report pending, keeps the close-up open (`OnReportHoldSeconds`, 8, as a fallback) and queues the Report signal (new `RefereeReportSignalRequest`). That Report signal starts no camera of its own: the high tackle shot holds its last frame (an `AnimatedCamera` stops updating past its animation), so there's no cut. It faces the referee towards that camera (`services.camera.pos`), blending over `OnReportTurnFrames` (15), and starts `OnReportSkipFrames` (30 fps) into `referee_report_01` (`offsetFrameCount`), skipping the whistle blow. Logs the animation's length to tune against. |
| `rules/tackle/tackle_detect.lua` | Test switch only (below). |

Only `HighTackle` penalties count. Illegal tackles and tackles off the ball also use the high
tackle signal, but keep the stock flow.

`RefereeCameoRuleState` is overridden by bunker-overturned-try; this mod only creates it
(nothing set that mod's `waitForProvisionalOutro`).

## Career mode

`_G.OnReportState.reports` keeps every report of the match (`playerId`, `side`, `surname`,
`matchSeconds`), ready for a judiciary/suspension feature. The stock game already logs a
judiciary charge for each high tackle in `sinbinsystem.onHighTacklePenaltyEvent`
(`matchOutData:addNewChargeFromValues`: careless/reckless/intentional plus a grade), but only
when sin bins are on.

## Debugging

`OnReportDebug` (currently **on**) appends to `onreport_debug.txt` in the game folder:

```
high tackle by 1234: not on report (chance roll)
high tackle by 1234 (Munster, side 1): ON REPORT at 1520s
penalty flow: high tackle close-up + report signal, then penalty choice
high tackle signal done, Report signal next in the same close-up
report signal: referee_report_01 is 4.2 s long, starting 30 frames in, in the high tackle close-up
report signalled, banner queued: MUNSTER ON REPORT
scoreboard: MUNSTER ON REPORT
```

For testing: set `OnReportChance = 100` in `rules/penalty/penalty.lua` (every high tackle goes
on report) and `OnReportTestEveryTackleHigh = true` in `rules/tackle/tackle_detect.lua` (every
contact tackle is penalised as a high tackle). Normal play: 30 / `false` (current).

Tested in game 2026-10-24 (test mode): high tackle close-up, Report signal in the same close-up
with no cut, whistle skipped, referee turning to camera, banner after the scoreboard returns.

## With the Rugby 25 expansion (r25-imports)

r25-imports plays a referee's word with the offender before some penalty choices. This mod
works with it in two ways:

- **On report:** when the offender goes on report, `rules/penalty/penalty.lua` sets
  `OnReportState.reportedOffender`. The talk is then skipped, because the report close-up says it.
- **Sin bin or send-off:** when the same penalty sin-bins or sends off the offender, the report is
  dropped in `ai/officials/refereesignal_action.lua`: no report signal, no banner. The sin-bin /
  send-off cutscene covers it.

Test switch: `OnReportTestEveryTackleHigh` in `rules/tackle/tackle_detect.lua` (false for play).

## Also in tackle_detect.lua

scrum-feed-control: a tackler flagged offside at a scrum (`_G.ScrumControlState.isScrumOffside`)
takes the stock offside penalty path, and `onTackleCompleted` clears the scrum flags. Without
scrum-feed-control this does nothing.
