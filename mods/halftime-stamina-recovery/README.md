# halftime-stamina-recovery

Half-time stamina recovery now depends on a player's fitness (his **Stamina** attribute), instead of
refilling almost everyone.

**Stock:** on `TimePeriodExpiredCutsceneEvent`, `StaminaListener.onTimePeriodExpiredEvent` adds
`maxStamina × halfTimeStaminaGain[difficulty]` to every player. That is +70% on the easiest
difficulty, +30% on the hardest, and +50% otherwise (`stamina_config.lua`). In-game logs show forwards
going into the break at 60–85%, so a flat +50% puts nearly everyone at 100% (issue C-81).

**Now:** a player gets back a share of the stamina he is *missing*:

```
raw      = (maxStamina - peakStaminaMinFitness) / (peakStaminaMaxFitness - peakStaminaMinFitness)
fitness  = (raw - FitnessRangeLow 0.6) / (FitnessRangeHigh 0.95 - 0.6)          (clamped 0..1)
share    = lerp(RecoveryShareLow 0.25, RecoveryShareHigh 0.65, fitness)
stamina += (maxStamina - stamina) × share
```

- **Fitness is the Stamina rating (confirmed in game 2026-10-25).** `maxStamina` is the native peak
  stamina, interpolated between 0.7 and 1.0 by the player's fitness. In the log, raw fitness ranged from
  0.61 to 0.91 and followed the players' Stamina ratings. Real squads only span about 0.6–0.9, so that
  range is stretched to 0..1, which keeps fit and unfit players clearly apart.
- **Difficulty has no effect.** The first version scaled the share by
  `halfTimeStaminaGain[difficulty] / 0.5`. On the test difficulty that was ×1.4 (the 0.7 entry), and it
  refilled everyone to 87–97% again.

Same match, before and after the change:

| Player | In | First version | Now |
|---|---|---|---|
| Moses Leota | 45% | 88% | 69% |
| Brendan Piakura | 48% | 87% | 67% |
| Payne Haas | 65% | 93% | 83% |
| Dylan Edwards | 60% | 93% | 81% |
| Isaah Yeo | 66% | 95% | 87% |

- **Interaction with ai-interchange-rotation:** players start the second half part-tired, so the
  second-half interchanges come earlier, within the same 4-per-half cap.

| Files | Where |
|---|---|
| `src/script-game/attributes/attributes/stamina_listener.lua` | entry 39959 (scripts); only `onTimePeriodExpiredEvent` changed |

```powershell
python tools\pack.py restore --entry 39959
python tools\build.py full --confirm
```

## Tuning / testing

- `RecoveryShareLow` / `RecoveryShareHigh` and `FitnessRangeLow` / `FitnessRangeHigh` are at the bottom of the file.
- `DebugLog = true` writes `halftime_stamina_debug.txt` to the game folder: one line per player at
  each break, with `maxStamina`, scaled fitness, stamina before → after, and the share used.
