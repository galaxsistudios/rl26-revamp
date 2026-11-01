# discipline-meter

Every player now has a **discipline** meter alongside stamina. It's the mental side of the game: it
drops when things go wrong, faster when the player is tired, rattled, under siege or chasing the
score, and comes back slowly when his team is in control. A player who runs out makes mistakes and
gives away penalties, and at the very bottom he gets binned or sent off.

The meter is shown as a thin vertical bar on the right edge of the player plate's card, filling
from the bottom (ice blue when settled, then yellow / orange / red at the stamina bands), so it
doesn't clash with the stamina underline. A red **RATTLED** tag shows while he is rattled.

**Status:** built and installed 2026-11-01, untested in game.

## How the meter moves

Every player starts the match at 100%.

**Who he is**

| | Drain | Recovery | Fatigue hits |
|---|---|---|---|
| Age 20 and under | ×1.35 | ×1.3 | ×1 |
| 21–23 | ×1.15 | ×1.15 | ×1 |
| 24–28 | ×1 | ×1 | ×1 |
| 29–31 | ×0.85 | ×0.95 | ×1.15 |
| 32+ | ×0.75 | ×0.9 | ×1.3 |

- **Aggression** (an attribute the stock game never uses on the field): drain ×0.8 at 0 up to ×1.3
  at 99. Unset (most shipped players) counts as average. It also raises the send-off chance.
- **Captain:** drain ×0.8, recovery ×1.1.

**Events** (cost or gain as a share of the full bar, before multipliers)

| Event | Effect |
|---|---|
| Penalty conceded | offender −14%, rattled, his team under more siege |
| Six again conceded | offender −7%, rattled |
| Try conceded | every defender −6%, big siege |
| Try scored | every scorer +10%, siege relieved |
| Line break conceded | every defender −3% (breaker +5%) |
| Fended | the tacklers −5%, rattled (the fender +2%) |
| Big hit | hitter +6%; the player hit −7%, rattled |
| Knock-on | −8%, his team under siege, the other team relieved |
| Half time | +35% for everyone, siege and rattled cleared |

**Multipliers on every cost**

- **Fatigue:** ×1 above 70% stamina, up to ×3 when empty (more for veterans).
- **Team siege** (0 = in control, 1 = under siege): ×0.5 to ×2. Penalties, six-agains, tries and
  line breaks against build it, penalties won, tries scored and big hits relieve it, and it fades
  with time.
- **Rattled** (about 2½ minutes of match clock after being penalised, fended or big-hit): ×1.6,
  and no recovery.
- **Scoreboard:** trailing by 18+ is fully "chasing" (×1.5 early, ×2 late), leading by 18+ is
  calming (×0.6), and a game within 6 points in the last 20% adds up to ×1.6 for both teams.

**Over time:** a player recovers slowly (up to 80% of the bar over a whole match) while his team
isn't under siege, he has over 50% stamina and isn't rattled. He drains slowly when he's under 40%
stamina, and when his team is chasing a big deficit late.

## Sliders and difficulty

**Academy > Custom Difficulties**, edit a custom difficulty: a **MODDED** section at the bottom
(for Revamp-only settings) has

- **Discipline** (on/off). Off: everyone stays at 100%, no bar, no errors, penalties or bins.
- **Discipline Strength** (x0.25 to x3, default x1): scales every drain for both teams.

They're saved on Back to `rl26_revamp_sliders.ini` in the game folder, one `[section]` per custom
difficulty name (the native gameplay modifiers can't take new fields). Renaming a difficulty
starts it fresh at on / x1. The preset difficulties (Rookie to Legend) always run it on at x1.

**Difficulty** scales the drain on top (a custom difficulty uses its Misc base difficulty):

| Difficulty | Your team | CPU team |
|---|---|---|
| Rookie (Easiest) | x0.5 | x1.25 |
| Amateur (Easy) | x0.75 | x1.1 |
| Pro (Medium) | x1 | x1 |
| Veteran (Hard) | x1.25 | x0.9 |
| Legend (Hardest) | x1.5 | x0.8 |

So the harder it gets, the more your players crack and the fewer gifts the CPU hands you.
"Your team" is any side with a human player on it.

## What low discipline does

- **Illegal tackles (CPU players only).** Under 50%, each tackle he makes can become an illegal
  tackle, up to a 10% chance at 0. The animation stays the same, the referee pings it. It's a
  penalty only, a sin bin (under 15%, 40% of the time) or a send-off (under 7%, rarer, more likely
  for aggressive players). Stock illegal tackles still always go to the bin.
- **Straight to the bin.** A CPU player who gives away a high tackle under 15% skips the team's
  warnings and goes straight to the bin (or off, same rule as above).
- **Errors (everyone, including you).** Under 50%, his basic pass, long pass, offload, dive
  collect, contested collect, place kick and field goal skills drop, by up to 25% at 0. The game's
  own knock-on, bad pass and kicking rolls then do the rest.

Players you control never get forced penalties. You still get the errors.

## Files

| File | Change |
|---|---|
| `rules/sinbin/sinbinsystem.lua` | the meter (per frame in `update`, events in `onDisciplineEvent`), `_G.DisciplineState`, bin/send-off escalation |
| `ai/tackle/tackle_arbitrator.lua` | rolls the illegal tackle before the tackle request is built |
| `app/academy/customdifficulty_edit_state.lua` | MODDED slider section, reads/writes `rl26_revamp_sliders.ini` |
| `nrl-broadcast-scoreboard`: `nvm_playerplate.lua`, `playerinfo_hud.lua`, `defaulthudresources.xaml` | the bar and RATTLED tag (`HasDiscipline` hides the bar when this mod isn't installed) |

All tuning numbers are in `var_0_disc_config` at the top of `sinbinsystem.lua`.

## Debug log

`DisciplineDebug = true` (top of `sinbinsystem.lua`) writes `discipline_debug.txt` to the game
folder: every player's traits, every hit with its multipliers, every illegal tackle roll that
fires, and a summary every 5% of the match (score, siege, players under 60%, R = rattled).

## Install

Two bundles (game closed; see INSTRUCTIONS.md):

| Files | Bundle |
|---|---|
| `src/script-game/...` (this mod and the scoreboard mod's Lua) | scripts: `python tools\build.py full --confirm` |
| plate bar in `mods/nrl-broadcast-scoreboard/.../defaulthudresources.xaml` | xamls |

Without the XAML part the meter and its effects still work, there's just no bar.

## Open questions for the first test

- Do mid-match skill changes really feed the native error rolls? The developers' attribute testbed
  does the same thing, but it's unconfirmed.
- `timeModifier / 8` (the stamina listener's event scaling) is assumed to be 1 at 5 minute halves.
- Is the drain too fast? One penalty while tired and under siege costs about 20%.

## hia-protocol rows

The MODDED section also shows [hia-protocol](../hia-protocol/)'s HIA Protocol / HIA Frequency /
HIA Fail Rate rows when that mod is installed (`var_0_hia_rows`, keys `hia`, `hia_frequency`,
`hia_fail_rate`). A row left alone isn't saved, so it follows the Misc base difficulty's default.
