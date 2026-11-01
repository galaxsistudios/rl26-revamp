# attack-play-coverage

Makes the attack tactic you call (CrossOver, HitUp, Out The Back, Inside Ball, Kick) actually run in most of
the field. It also stops plays written for another part of the field from scattering the runners, fixes the
kick-off receive layout, and stops the last-tackle kicker running a gap.

Issue tracker: N-22 to N-25.

## Where plays live

The game reads plays from two **compiled** entries, loaded in `sim/universe/universe.lua`:

- `plays/playset.dat` (entry 57837): the 193 attack plays.
- `plays/formationset.dat` (57836): the 44 set-piece layouts (kick-off, drop-out, tap, scrum...).

The `intermediatelua/plays/*.lua` files are only the authoring sources. Editing them does nothing (the first
version of this mod did that). [playset.py](playset.py) decodes and re-encodes both files byte for byte; the
format is in its docstring.

## The problem

Each play is written for one of 14 strips ("slices", 4.9 m each) across the field width, with ruck-relative
spots. The native selection rates every play:

- a cost per slice between the ruck and the play's slice (`sliceProximityWeight`, stock 1),
- a cost per zone (`zoneProximityWeight`, 10),
- tag bonuses: the tactic you call is only a `preferredTags` entry.

So when your strip has no play of the called type, a different play runs. The stock gaps (tackles 1-4):

| Type | Stock slices with a play |
|---|---|
| Kick | none (all 59 kick plays need `LastTackle`) |
| Inside Ball | 5, 8, 9 |
| CrossOver | all but 6, 7, 9, 12 |
| Out The Back | all but 1, 2, 6, 8, 11, 13 |

A slice-distance cost of 1 also made plays 3-5 strips away cheap. A play for the touchline strip has no
blind-side spots, so used elsewhere its runners started in odd places and crossed the non-play players.

## What it does

[install.py](install.py) (`show` = dry run, `install --confirm`, `restore`, `status`) builds both entries from
stock:

1. **Fills the open-play gaps** (CrossOver / Out The Back / Inside Ball): a stock play of that type is
   mirrored (slice s ↔ 13-s, y flipped, left/right roles, targets and `Left`/`Right` tags swapped) or moved
   from the nearest slice whose spots still fit inside the touchline. Names end in `(mirrored)`,
   `(from slice N)`, etc. 19 plays. Inside Ball still has none on slices 0, 1, 12, 13 (no stock inside-ball
   play fits near touch).
2. **Early-tackle Kick plays**: a copy of each slice's last-tackle punt and attacking kick (only plays with a
   kick mechanic, 36-40), with `requiredTags = {"Kick"}` and `LastTackle` banned. They should only run when
   Kick is called and don't compete with the last-tackle kicks. 26 plays (`(early kick)`).
3. **Slice 2 Hooker scoot**: the winger's start spot was 6 m over the touchline. Moved inside.
4. **Kick-off receive layout** (`KickOffOffence`, the *receiving* team): stock was a copy of the line drop-out
   kicking layout (props ~12 m in goal, second rowers on touch at the try line). New: second rowers and
   centres on the front line (13-15 m back, short-kick cover), hooker 24 m, halves 35 m, wingers 42 m,
   fullback 46 m, and the lock (52 m) and props (56 m) off the back fence so they take the catch running.

New plays are appended after the stock ones, so stock play indices don't move.

Script side (in the scripts bundle):

5. **`sliceProximityWeight` 1 → 4** (`design/playselection_config.lua`).
6. **Last-tackle gap runs**: two `master_flowchart_ai.flow` rules sent any carrier who saw a gap to `HitGapAi`
   with no last-tackle check (one of them before the "follow the running play" rule), so the punt play's
   kicker ran on tackle 5. They now skip the last tackle outside the green zone. The lines live in
   reduce-ai-dummy-half-scoots' copy of the flowchart (one owner per file).
7. **Kick-off chase**: during a kick-off everyone runs `placekick_flowchart_ai.flow` (the behaviour stays
   PlaceKick until the catch; the kick only clears the formations). The kicking team is in `KickOffRunUpAi`
   (one 20 m jog set on entry, nothing in update) or `KickOffIdleAi` (idle), so they stopped while the ball was
   in the air. Both copies here call `kickoffidle_ai.kickOffChase`: once a kick-off is in the air (`_G.APC_KickOffTime`,
   stamped by play_listener.lua on the kick-off disposal event, since the ball's own disposal info is nil for
   place kicks; kicked < 8 s ago so a re-kick's tee setup doesn't trigger it) they sprint at the
   landing spot (`ballInfo.nextBouncePosition`, then the ball once it bounces), fanned out (40 % of their
   sideways distance kept) and 2 m short. Logged as `CHASE kick-off` (or `... not chasing id=..: reason`).
   The kick-off time comes from play_listener's update (`KICKOFF stamp t=`), since the disposal event's time is
   nil too. History: a master-flowchart rule never fired; the first KickOffIdleAi-only version never ran because the
   chasers stay in KickOffRunUpAi.
7b. **General-play kick chase** (user request 2026-11-01): a `master_flowchart_ai.flow` rule
   (`isAttackingSide and isInPlayKick and not hasBall`, after the stock `isKickChaser` rule) sends the whole
   kicking team to `KickChaseAi`, whose copy here splits long kicks (25 m+): landing within 10 m of the
   middle -> the fullback charges it; otherwise everyone on that side of the field (|y| >= 4) sprints at it
   (30 % funnel, 2 m short); the rest run up to a line 10 m short, keeping their width. Short kicks stay stock
   (everyone in the controller sprints at it). Logged as `KICKCHASE` lines.
7c. **Kick-off chase from the listener (2026-11-01)**: the chasers left both kick-off controllers at the kick
   (no chase lines after the stamp), so `play_listener.lua` now drives it: for 6 s after a kick-off, while the
   ball is loose, every kicking-team player except the fullback and any human-controlled player gets a
   `CMoveToTarget` at max speed to the landing spot every 0.25 s (`CHASE kick-off team` lines). A
   `placekick_flowchart_ai.flow` rule (`isPlaceKickDisposed and isDefendingSide and not isFullBack =>
   KickOffIdleAi`, before the final IdleAi) is a second route. Pitfall: controller times are native Time
   objects (`:ToSeconds()`); formatting one with %f crashed the game twice.
7d. **General-play kick chase fix**: the in-play kick entity's `kickTargetPosition` is the aiming target, not the
   landing (it was (1, 0) for a punt from 29.5 m, so the team ran 35 m backwards). The landing spot is now
   `ballInfo.nextBouncePosition`, then the target, then the ball, and only if 3+ m ahead of the kicker; line
   runners never move back; side chasers go to the spot itself (StopShort 0) to contest the catch.
7e. **Offside interceptions**: the master flowchart's InterceptPassAi rule now needs `not isOffside` (a
   defender left lying on the wrong side of the ruck after a fend intercepted and ran free).
8. **Kicker assignment (C-49)**: `design/playroleassignment_config.lua` `nonPlayMakerPositionCost` 12.5 → 40.
   Every kick play gives the kick to the playmaker role (15), filled by cost: 1 per metre plus 12.5 for a
   non-playmaker, so a forward 13 m closer than the halves got it (and, before fix 6, ran it).
9. **Attack depth (N-25)**: in `BasicPlayTheBallOffence` the sideline anchors sat 14 m behind the ruck and
   the backs stood 12-14 m deep (SHAPE log, 40 rucks). Now 10 m. The edit lives in fullback-sweeper-defence's
   copy of `forcedirectedgraphs_rugby.lua` (one owner per file).

Set-piece spots are relative to the kick spot in each team's own attacking direction. Stock gives the
*receiving* team the `...Offence` layout: LineDropOutOffence already has a sensible receive shape (front line
20 m from the drop-out, props 60 m), so it is unchanged. Penalty goals (C-64: defenders behind their goal
line) follow the laws: opponents retire to their goal line or 10 m from the mark.

## Debug log

`play_listener.lua` (stock code + logging, `DebugLog = true`) writes `attack_plays_debug.txt`:

- `PLAY side=.. attacking=.. tackle=.. ballSlice=.. zone=.. tactic=.. play=..`: each time a side's play
  changes. Compare `ballSlice` with the `Slice N` in the name, and the play type with what you called.
  `tactic=` comes from `getSelectedPlay`, which doesn't exist in retail (always `?`).
- `SHAPE side=.. slice=.. play=.. | ROLE(dx,dy) ...`: every attacker 1.5 s after each play-the-ball, relative
  to the ruck in the attacking frame (+x = forwards), sorted left to right, `*` = in the play. This is the
  input for reworking the formation (N-25).
- `KICKOFF side=.. | ...`: both teams at each kick-off (x 0 = halfway, -50 = own try line).
- `DROPOUT +0/+2/+4s side=.. ball=.. owner=.. | ...`: both teams after each drop-out, for C-47.
- `CHASE kick-off ...`: each kicking-team player's first chase move.

Turn it off for release.

## Status

- 2026-11-01 first test (Lua play files only): stock plays and stock kick-off spots in the log, which is how
  the compiled entries were found. Seen: the CPU ran a gap on tackle 5 (fix 6).
- Compiled entries installed 2026-11-01, untested. Unknowns: whether the called type reaches the native as a
  tag (if `Kick` isn't one, the early-kick plays never run, which is harmless), and whether the CPU ever
  calls Kick early (it would now kick early; check the CPU's PLAY lines).
