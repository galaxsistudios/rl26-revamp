# ai-interchange-rotation

Fixes issue C-80 ("the AI only ever uses two bench players"). AI-run sides now make interchanges when
players tire, instead of on a fixed clock:

- A forward (props, second rowers, lock) or the hooker comes off once his stamina drops below his own
  threshold, somewhere between **45% and 55%** (first tests at 20–30% gave one interchange a half: forwards sit at 60–85% in play, recover at stoppages, and dip to about 50%). Each player gets a different threshold each half, so the
  whole pack doesn't come off together.
- The replacement is the best available bench player for that position. The score is overall rating
  for the role × role fit (`interchange_config` Allocated*RoleWeight: primary 2, secondary 1.75,
  tertiary 1.5, other 0.5) × current stamina × `InjuryWeights`. The player must be at least 60% fresh,
  so a forward who just came off has to recover before he goes back on. Every bench forward rotates, and
  starters come back on in the second half.
- **Rotation checkpoints at 20', half time, 60' and 70'** (match minutes, scaled for short halves).
  These swap up to 2, 1, 1 and 1 players, on top of the fatigue swaps. At a checkpoint the most tired
  forwards (below `CheckpointMaxStamina` 90%) come off for a bench player who is at least
  `CheckpointMinGain` (10 points) fresher. The half-time checkpoint runs at the start of the second
  half and ignores the "no interchanges early in a period" window.
- **Turns:** each player's turns on the field are counted (starters count as one), and each turn
  multiplies his pick score by `TurnWeight` (0.6). So bench players who haven't been on go first, at
  checkpoints and on fatigue swaps alike, and most of the bench gets a turn. Checkpoints still obey
  the interchange budget: if nothing is left, the checkpoint is skipped (logged).
- **The utility never replaces a forward.** A bench player is the utility if his primary or secondary
  role is a spine position (fullback, five-eighth, halfback, hooker). He only comes on for the hooker
  (and stays the stock pick for injuries).
- Squad rules apply to 17- and 19-man squads alike:
  - `maxSubstitutionCount` is the interchange limit, and one interchange is held back for injuries.
  - Only `maxOriginalSubstitutesToSelect` of the original bench may ever take the field, the same rule
    the human lineup screen enforces. If the last free slot would go to a forward while the utility is
    still unused, it is kept for the utility.
  - At most 4 interchanges per half (`MaxPerPeriod`, injuries included). With 8 that gives 4 + 3,
    plus the one held back.
  - There are no fatigue interchanges in the opening part of each period (`interchange_config`
    `timePeriodStartNoInterchange`, scaled for short halves) or in its last 2 minutes.
- Sides it manages: those with no gamer, plus a gamer's side when **automatic interchanges** is on or
  in Be a Pro. That is the same split the native job uses. Be a Pro's own player is never picked;
  `CareerSubOffListener` still handles him.

| Files | Where |
|---|---|
| `src/script-game/ai/substitutions/substitution_listener.lua` | entry 39959 (scripts) |
| `install.py` | patches `rugbyleague1.exe` (7 bytes at 2 sites) |

```powershell
python tools\pack.py restore --entry 39959
python tools\build.py full --confirm
python mods\ai-interchange-rotation\install.py --apply
```

`unlock-all-kits/launch.py` (the Steam launch option) re-applies the exe patch after updates. To
undo it, run `install.py --restore` (do that before `unlock-all-kits\install.py --restore`).
**The Lua and exe halves need each other.** Without the exe patch the stock clock still runs, and the
Lua requests for AI sides are never carried out. Without the Lua, AI sides only make injury
interchanges.

## How the stock AI did it (found 2026-10-25, 1.0.5887)

AI interchanges are entirely native, in `paTeamSubstitutionDecisionKnowledge_job_` (the job function is
at `0x14074c980`). The table entry at `0x141bad408` is how it's found from the name string. Per side:

1. **Human side on manual interchanges** (gamer on the side, no automatic interchanges, not Be a Pro):
   the job copies `CSubstitutionEntity`'s queue (filled by Lua `SubstitutionRequest`s from the HUD or
   pause menu) into `CTeamSubstitutionDecisionKnowledge`. That knowledge is what
   `paTeamSubstitutionKnowledge_job_` carries out at the next stoppage.
2. **Any other side**: Lua-queued interchanges are merged in only if `CMatchInfo` byte +9 is set (Be a
   Pro). Then, for each player on the field, in `activeTeamPlayerIdList` order:
   - injured (any injury) → interchange now;
   - assigned role ≤ 6 (backs) → never;
   - otherwise a timed window, in match minutes (period seconds / 60, +40 in the second half), each
     firing once: **20', 38', 60' → PropLeft/PropRight (7/9); 55' → Hooker (8); 65' → Lock (12)**.
     Second rowers are never interchanged.
   - The player coming on (`0x14074d6e0`) is always the first entry in `subOnOrderList` whose role is
     `Substitute` and who isn't queued. Nothing about position or stamina is checked, so the same one
     or two bench players keep going back on.

`interchange_config.lua` (role weights, `timePeriodStartNoInterchange`, `shuffle*`, and so on) isn't
read by any native code. Only `getWeightInfo` in `interchange_helper.lua` uses it, and only for the Be a
Pro skip. This mod reuses its weights and time windows.

`EAssignedRole` values (enum table order): FullBack 0, WingerLeft 1, CentreLeft 2, CentreRight 3,
WingerRight 4, FiveEighth 5, HalfBack 6, PropLeft 7, Hooker 8, PropRight 9, SecondRowLeft 10,
SecondRowRight 11, Lock 12, Substitute 13.

### The exe patch

| Site | Stock | Patched | Effect |
|---|---|---|---|
| `cmp byte [rdi+9],0` / `mov [rsp+50h],rdx` / **`je skip_merge`** | `0f 84 1a 01 00 00` | 6× `90` | always merge Lua-queued interchanges for AI sides |
| `mov r11d,[role]` / `cmp r11d,6` / **`jle next_player`** | `7e` | `eb` | skip every timed window; the injury check before it still runs |

## Tuning

These are constants at the top of the `AiInterchangeManager` section of `substitution_listener.lua`:
`FatigueMin` / `FatigueMax` (0.45 / 0.55), `MinBenchStamina` (0.6), `ReserveInterchanges` (1),
`MaxPerPeriod` (4), `EndOfPeriodSeconds` (120), `RequestCooldown` (60 match seconds between one
side's interchanges), `MaxQueued` (2), `Checkpoints`, `CheckpointMaxStamina` (0.9), `CheckpointMinGain`
(0.1), `TurnWeight` (0.6).

## Testing

- `DebugLog = true` writes `ai_interchange_debug.txt` to the game folder. Every 5 match minutes it logs
  each side's forwards' and bench players' stamina and the interchanges left, and it logs every
  interchange it makes with the reason. Turn it off for release.
- A stub harness (LuaJIT, stubbed natives) ran four matches: 17-man/8 interchanges/4 originals,
  19-man/8/4, 17-man/10/unlimited, and low drain. All rules held: utility only on for the hooker, the
  19th man (a centre) never used, ≤ 4 originals used, 4 interchanges in the first half and 3 in the
  second, one kept in reserve, and nothing queued in a period's last 2 minutes.
- **Not yet verified in game.** Check how low forwards' stamina really gets in a full match (the
  snapshot lines show this). With short halves or low drain sliders, a forward may never drop below
  30%, and then no fatigue interchange happens.

## Not changed

- Injury interchanges stay native: the first bench player in `subOnOrderList`, whatever his position
  (issue C-84). They could move to Lua with the same picker by making the patched `jmp` sit before the
  injury check too.
- Positions aren't reshuffled. The player coming on takes the outgoing player's role, as with human
  interchanges.
