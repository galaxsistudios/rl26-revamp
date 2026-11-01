# hia-protocol

Head Injury Assessments, NRL style. **Pilot:** head-high tackles only, Category 2 HIAs only.

RL26 has no HIA, no concussion and no concussion injury type (issue I-32). Its only head injuries
are FracturedSkull and NeckSprain, rolled like any other injury, and an injury interchange uses up a
normal interchange.

## What happens

1. A head-high tackle (penalised as `HighTackle`) sends the tackled player off for an HIA
   `HighTackleHIAChance` (25%) of the time, × the HIA Frequency slider × the stock Injury
   Probability slider.
2. **Concussion cutscene:** injury-cutscene-variety's `InjuryConcussion_01` (the game's unused
   `injury_concussion_01` animation) plays in front of the penalty, then the referee's high tackle
   close-up, then the penalty choice:
   `PenaltyIdle -> InjuryCameo(HIA concussion) -> RefereeCameo(HighTackle [+ Report]) -> PenaltySelectSetup`.
   The HIA is decided the moment the tackle is detected, so the penalty, which can come later
   (advantage), knows to play it. It waits up to `HIACutsceneWindow` (180 match-clock seconds);
   `HIACutscene = false` turns it off.
3. **`<SURNAME> OFF FOR HIA`** slides out under the scoreboard once it's back on screen. He goes off at the next stoppage on
   a **free interchange** for the best available bench player in his position (overall for the role
   × role fit × stamina, the same scoring as ai-interchange-rotation; the original-bench limit is
   obeyed).
4. He sits out **15 minutes of match clock** (`HIAMinutes`), scaled to the half length the same way
   the match clock is: 15 of a 40-minute half.
5. The assessment is rolled against the HIA Fail Rate:
   - **Pass:** `<SURNAME> PASSED HIA`, and he comes back on for his replacement at the next
     stoppage, again on a free interchange. If the replacement has left the field in the meantime
     (sin bin, injury...), he waits on the bench like any other bench player.
   - **Fail:** `<SURNAME> FAILED HIA`, and he is out for the rest of the match.
6. While a player is in an HIA, ai-interchange-rotation never brings him on or takes his replacement
   off, and HIA swaps don't count towards its 4-per-half cap.

"Free" means the side gets one extra interchange for every HIA swap: a `HIAFreeInterchangeRequest`
calls `addSubstitutionAdditions(1)` on the side's substitution entity (the call golden point uses
for its added interchanges), queued with the swap. The swap's `SubstitutionRequest` is sent with
`unlimitedSubstitutions` so its limit check can't reject it.

Not in the pilot: no HIA if the player is the Be a Pro player, if the side has no bench player left
(he plays on, logged), and none in practice or training. Online isn't handled at all.

## Settings

The custom difficulty edit screen's MODDED section (mods/discipline-meter's
`app/academy/customdifficulty_edit_state.lua`) gets three rows, saved in
`rl26_revamp_sliders.ini` in the game folder under the difficulty's name:

| Row | ini key | Range |
|---|---|---|
| HIA Protocol | `hia` | on / off |
| HIA Frequency | `hia_frequency` | 0–5 × |
| HIA Fail Rate | `hia_fail_rate` | 0–100 % |

A slider that's never changed isn't saved, so it follows the custom difficulty's Misc base
difficulty. Presets use `HIADifficulty` at the top of `injuryevent_listener.lua`:

| | Easiest | Easy | Medium | Hard | Hardest |
|---|---|---|---|---|---|
| Frequency | 0.6× | 0.8× | 1.0× | 1.2× | 1.4× |
| Fail rate | 25% | 30% | 40% | 50% | 60% |

Both teams are treated the same at every difficulty.

## Files

| File | Change |
|---|---|
| `src/script-game/game/injury/injuryevent_listener.lua` (this mod) | Stock listener + `HIAManager`, an updateable registered with the match sim (every 0.25 s). Shares `_G.HIAState` (`onHighTackle`, `isLocked`, `banners`, `freeSwaps`, `log`). |
| `rules/penalty/penalty.lua` in **mods/referee-on-report** | For a high tackle penalty, `HIAState.takeConcussionCutscene` gives the HIA player (once per HIA), and an `InjuryCameoRuleState` with `hiaConcussion` goes in front of the referee close-up. |
| `rules/injury/injurycameo_rulestate.lua` in **mods/injury-cutscene-variety** | `hiaConcussion` member: plays `HIAConcussionCutscene` (`InjuryConcussion_01`) without needing an injury, and queues no stock interchange. |
| `rules/tackle/tackle_detect.lua` in **mods/referee-on-report** | Calls `HIAState.onHighTackle(tackledId, tacklerId)` when a high tackle penalty is detected. |
| `sim/hud/gameplayscore_hud.lua` in **mods/referee-on-report** | Shows `HIAState.banners` one at a time in the on report banner slot, when it and the interchange banner are free. |
| `ai/substitutions/substitution_listener.lua` in **mods/ai-interchange-rotation** | Skips `HIAState.isLocked` players; leaves `HIAState.freeSwaps` out of the per-half count. |
| `app/academy/customdifficulty_edit_state.lua` in **mods/discipline-meter** | The three HIA rows (only shown when this mod is installed). |

Those mods own the files, so the HIA hooks live in their copies. Each hook does nothing without
this mod. **Needs ai-interchange-rotation's exe patch:** without it, Lua-queued interchanges for
AI-run sides are never carried out.

The banner only exists on the default scoreboard (nrl-broadcast-scoreboard), like on report:
Super League, Origin, QLD Cup and RLWC have their own scoreboards.

Script mod, entry `scripts`: `python tools\pack.py restore --entry scripts`, then
`python tools\build.py full --confirm` (game closed).

## Testing

`HIADebugLog` (on) appends to `hia_debug.txt` in the game folder:

```
settings [preset] base Hard: on, frequency x1.20, fail rate 50%, stock injury probability x1.00
side 1 SMITH: HIA after a high tackle (rolled 10 < 30.0). Interchanges before: 8 left (0 made)
side 1: free interchange queued, OFF 1234 ON 1240
side 1 SMITH: off for his HIA at 23:10 (JONES on). Interchanges now: 8 left (1 made)
side 1 SMITH: passed his HIA (rolled 90 >= 50%)
side 1 SMITH: back on for JONES at 38:42. Interchanges now: 8 left (2 made)
```

**The key check:** "Interchanges now" should stay at the "before" number after each HIA swap. If it
drops by one, `addSubstitutionAdditions` doesn't do what golden point suggests, and the free
interchange needs another approach.

### In-game test mode (off)

| Switch | File | Test | Play |
|---|---|---|---|
| `HIATestEveryHighTackle` | `injuryevent_listener.lua` (this mod) | `true`: every high tackle is an HIA | `false` |
| `HIATestMinutes` | `injuryevent_listener.lua` (this mod) | `2`: 2 match-clock minutes off | `nil` |
| `OnReportTestEveryTackleHigh` | referee-on-report's `rules/tackle/tackle_detect.lua` | `true`: every tackle is a high tackle | `false` |

With all three on, the first tackle sends the ball carrier off for an HIA. Every tackle is also a
penalty (and sometimes an on report close-up), so play is stop-start. Each new tackle on another
player starts another HIA until the bench runs out (then "no bench player is available, he plays on"
is logged). Rebuild after changing them: `python tools\pack.py restore --entry scripts`, then
`python toolsuild.py full --confirm`.

What to check, in `hia_debug.txt` and on screen:

1. `settings [...]` at kick-off shows the difficulty's frequency and fail rate.
2. `OFF FOR HIA` banner; the player leaves at the next stoppage for a bench player in his position
   (`off for his HIA ... (<NAME> on)`).
3. **"Interchanges now" equals "Interchanges before"** after the swap. This is the free
   interchange; if it drops by one, it isn't free.
4. The concussion cutscene plays before the referee's close-up (`concussion cutscene for ...` in
   `hia_debug.txt`, `penalty flow: HIA concussion cutscene first` in `onreport_debug.txt`).
5. About 2 clock minutes later: `PASSED HIA` (he comes back on for his replacement at the next
   stoppage, `back on for ...`, interchanges unchanged again) or `FAILED HIA` (he never returns).
6. CPU sides too (needs ai-interchange-rotation's exe patch), and ai-interchange-rotation never
   swaps an HIA player or his replacement (`ai_interchange_debug.txt`).
7. The custom difficulty screen's MODDED rows (HIA Protocol / Frequency / Fail Rate) save to
   `rl26_revamp_sliders.ini` and show in the `settings` line of the next match.

### Offline tests

`python mods\hia-protocol\test_hia.py` (`-v` also prints the log) runs the manager under LuaJIT with
stubbed natives: 15 tests covering the concussion cutscene hand-off, the off switch, pass, fail, no roll, difficulty presets, custom difficulty ini,
short halves, empty bench, replacement leaving, repeat tackles, two HIAs at once, unlimited
interchanges and a dropped swap. Its gamestate/gameobjects stubs fail if used outside the frame they were handed out in, as the
engine's do (keeping one between frames broke every HIA once), and any ERROR in the log fails the
run. It forces the in-game test switches off in its copy, so it works
whatever they're set to. It assumes the native interchange count works as golden point's suggests,
which only the in-game check (3) can confirm.

**Untested in game.**

## Later phases

1. Category 1 (no assessment, out for the match), playing a man short when the bench is empty,
   missed concussions (plays on with errors), and big hits / head-region injuries as triggers.
2. Career: 11-day stand-down through `matchOutData:addNewInjuryFromValues`, a concussion history,
   and a "Concussion" label (no such injury type exists, so one has to be relabelled in the string
   tables).
3. Foul play: an HIA from a high tackle raises the sin bin / report chance.
4. The 18th man.
5. Keep the human interchange menu from bringing an HIA player back on early (it doesn't check
   `HIAState.isLocked` yet).
