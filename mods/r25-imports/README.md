# r25-imports

> **Release: NOT part of the RL26 Revamp release.** This is the optional **Rugby 25 Expansion**:
> leave this mod (and the entries `r25_import.py` appends) out of the main Revamp package. Ship it
> separately, for players who own Rugby 25. Its assets are generated on the player's machine from
> their own Rugby 25 install by `tools/r25_import.py`; no Rugby 25 data is redistributed. `imports.json`
> carries `"releaseChannel": "r25-expansion"` so packaging can filter it. Any future R25-derived
> content (e.g. the tackle pilot) belongs in this expansion too.

Plays cutscenes taken from **Rugby 25** (same Big Ant engine) in RL26. The animations are pulled
from the player's own Rugby 25 install and converted by [tools/r25_import.py](../../tools/r25_import.py).
Nothing from Rugby 25 is stored in this folder, and only animation data is imported. Player models,
kits and faces stay RL26's.

## What's imported

| Cutscene | Plays as | Players |
|---|---|---|
| `TryCelebrate_roll_hug` | try celebration (standing/ground, all tiers) | 5 |
| `TryCelebrate_intense_slide_yell` | try celebration | 3 |
| `TryCelebrate_ball_throw_group` | try celebration | 4 |
| `TryCelebrate_ball_throw_hug_group` | try celebration | 4 |
| `Post_Conversion_01` | `Conversion_Success(_NoTee)`: kicker + teammate | 2 |
| `Post_Conversion_02` | `Conversion_Success(_NoTee)`: solo kicker | 1 |
| `Post_Conversion_03` | `Conversion_Fail(_NoTee)`: kicker disappointment | 1 |
| `Conversion_T_success_r24_01` | `Conversion_Success(_NoTee)` | 1 |

- **R25-only cutscenes:** the four try celebrations are the only R25 ones RL26 has no version of.
  R25's other 14 are re-exports of celebrations RL26 already has.
- **Cut content:** the post-conversion shots are cut content from R25's legacy
  `design/cutscenes/cutscenes_config.lua`, but their animations still ship. They were studio shots
  at world origin. `overrides` re-anchors them on the kicker, and `cameraAnimFromActor` gives each
  shot its own cameras.
- **Touch reactions:** `Conversion_Fail_NoTee` is also the group `fix-touch-referee-cameo` uses for
  its ball-into-touch reaction, so the disappointment can play there too.

## Penalty talks

Before the penalty choice, the referee has a word with the offender in **50%** of penalties
(`PenaltyTalkChance`). These are R25's cut `RefereePenalty_01–04` scenes, 8–9 s, with no whistle.

- **Self-contained:** r25-imports overrides `rules/penalty/penaltyselect_setup_rulestate.lua` and
  defines `PenaltyTalkRuleState` in it, so it needs no other mod.
- **Who's in it:** the cutscene targets the offender and the referee. Officials aren't cast
  automatically, so the referee is passed in, as RL26's sin-bin cutscene does.
  - `PenaltyTalkCaptain` (`01`, `03`) also brings in the offending side's captain, who fills the
    scene's optional player slot (`actorFields` restricts that slot to captains). Never used when
    the offender is the captain.
  - `PenaltyTalkSolo` (`02`, `04`) is the referee and the offender only.
- **Skipped when:**
  - the offender is sin-binned or sent off (their own cutscene follows the choice);
  - with referee-on-report installed, the offender is put on report (he gets the report close-up
    instead; referee-on-report sets `OnReportState.reportedOffender`);
  - the match is online, practice or training.

## Corridor walks

R25's `IntroCorridorWalkTeam_01` / `_02` join RL26's regular-season corridor shot
(`rl1_corridor_home_02`), which the generator turns into a weighted group. The stock shot has weight
2 and each R25 walk weight 1.

- **Staging:** RL26 builds its corridor from `props/cutscene/models/corridor01.model`, placed at the
  field centre with the stadium lights and sun switched off. R25's hallway model and lighting scene
  aren't in RL26.
  - `fromRL` copies RL26's props, lighting, sounds, playback events, `playerPosY` and
    `cutsceneOrigin`.
  - `clipOffsets` moves R25's walking paths and camera paths onto RL26's corridor (team 02 by
    (−7.3, −8.0), team 01 by (−7.3, +6.8) so its side entrance meets RL26's).
  - A cutscene's `worldPos` can't do this: it is the origin for the props and the lighting scene
    too, so the whole set moves with the players.
  - The shift edits each clip's start (header `+0x40`, and the inverse at `+0x58`) and its
    `cs_camera*` translation tracks. Cameras are placed in scene space.
  - RL26's corridor is narrower, so team 02's off-centre camera 02 is left out of its `cuts`.
- **Sides:** team 01 is R25's away team. `swapSides` makes it the home team, because regular-season
  intros only show the home corridor.
- **Groups from a cutscene:** a `groups` name that is a stock cutscene rather than a group becomes a
  group that keeps the stock shot as a choice (`stockWeight`).

## Tackles

`tackles.auto` clones every RL26 tackle that has an R25 version (100 tackles, plus 100 mirrored)
into `actionset/tackleset.dat` (entry 9), with the clips in `animations/r25_tackles.animset`.

- **Mirrored clips:** R25 mirrors tackles at runtime and ships no `_m` clips, so `add_mirrors` in
  [animset.py](../../tools/animset.py) generates them from the base clips. They match RL26's own
  `_m` clips. Turn this off with `"mirrored": false`.
- **Mixing:** contact selection (exe `0x9a11d0`) gathers candidates into a fixed 128-entry array and
  crashes once it overflows. Adding every R25 tackle on top of RL26's took one search from 95 to 155
  candidates.
  - Up to `extraPerGroup` (default 12) tackles per group keep their RL26 counterpart selectable; the
    other R25 tackles replace theirs.
  - `tackleset` works out the worst case: all big hits, plus Contact and ContactInTry entries with no
    required tags. It lowers `extraPerGroup` until that fits in 120, and refuses to build if nothing
    fits. With the new tackles below, it peaks at 120 and keeps 11.
- **New tackles** (`newTackles`): R25 tackles RL26 has no version of (`bc_X` / `t1_X` clip pairs).
  Each clones a template RL26 entry, keeping its group and tags (the mirrored version comes from the
  template's `_m`), and is added on top of RL26's own.

  | R25 clips | RL26 group (template) |
  |---|---|
  | `tackle_front_illegal_01/02` (high shots) | BigHitContact (`tackle_bighit_01`) |
  | `tackle_fend_big_front_*` ×9 | Fend, BigWin (`tackle_fend_big_01`) |
  | `tackle_sidestep_big_01_left/right` | SideStep, BigWin (`tackle_sidestep_run_big_01`); `swapTags` makes the left one DirectionLeft |
  | `tackle_evade_bump/knee/back` ×6 | Bump, one tackler (`hf_bump_2t_01_bc_1tk`) |
  | `tackle_try_*` ×10 | ContactInTry, Try (`tackle_quicktry_front_ball_righthand_01`) |

  - `renameEvents` retargets clip events: the high shots' `ground` becomes `hitground`, which
    `bighitted_action` turns into a HitGroundEvent.
  - The `groundstart` / `groundend` events are optional there, and the R25 clips don't have them.
  - R25 has no `tackle_bighit_*` clips of its own (it has no big-hit system).
- **Sized variants** (`_small_bc` / `_tall_bc`) aren't imported: RL26 has no height tags.

## Faces

Both games use the same face rig: 29 tracks on `hj_face_loc_driver` holding 117 pose weights. RL26
plays them from `facial.animset` through `emotiongroups` when a clip fires `emotion_<group>`.
Rugby 25's cutscene clips carry their own face tracks and fire `emotion_zero` at 0 s. The key data
is byte-identical; RL26 only flags the encoding `0x4008` where R25 writes `0x8`.

- **Cutscene faces:** each R25 cutscene clip with face tracks (14 across the try celebrations) gets
  a face clip `r25f_<clip>` in `animations/r25_faces.animset`, built in RL26's `facial.animset`
  container.
  - The clip's `emotion_zero` becomes `emotion_r25f_<clip>`, a one-clip group, so the authored face
    plays in sync with the body.
  - Clips without their own face still use `emotionMap`.
- **Gameplay faces:** `faces.groups` adds faces to RL26's own groups. R25 has no tackle faces, but
  RL26 tackles fire `emotion_strain` (1,246 events), `disappointed`, `celebrate`, and others.
  - Faces RL26 lacks (`face_ss_exert_01/02`, `face_angry_01`, `face_ooh_01`) are copied from R25's
    `facial.animset`.
  - `face_idle_active_01–03` already ship unused in RL26 (R25's `default` group).
- `r25_faces.animset` loads beside `facial.animset` (`playeranimationset.lua`, `r25FacialAnimSet`).

## imports.json

- `testMode`: imports become the *only* entries in their groups. Use it for testing; set `false` for
  normal play, where they mix in by `weight`.
- `debugLog`: copies cutscene log output to `<game>/r25_imports_log.txt`.
- `emotionMap` / `emotionLoop`: which RL26 face groups stand in for an R25 emotion RL26 lacks.
  - R25 clips mostly fire `emotion_zero` ("let the face-rig curves drive"), and RL26 can't play
    those curves.
  - `zero` is mapped to a looping mix of RL26 celebration faces.
- Per cutscene:
  - `groups` and `weight`: which RL26 cutscene groups it joins, and how often it's picked.
  - `disabled`: leave it out.
  - `overrides`: set definition fields; `null` removes one.
  - `cameraAnimFromActor`: point every camera at the first actor's clip.

## Rebuild / install

Run these with the game closed.

```powershell
python tools\r25_import.py setup                  # once: extract R25's scripts to r25\
python tools\r25_import.py scan [--filter TEXT]   # catalog -> r25\catalog.json
python tools\r25_import.py import --confirm       # convert + append the animsets imports.json needs
python tools\r25_import.py motionset --confirm    # merge their clips into RL26's motion set (entry 91)
python tools\r25_import.py tackleset --confirm    # add the R25 tackles to RL26's tackle database (entry 9)
python tools\r25_import.py gen-mod                # regenerate this mod's Lua
python tools\pack.py restore --entry 39959
python tools\build.py full --confirm
```

## How the conversion works

Rugby 25's files share RL26's container formats, but a few details changed. The tools cover each:

- **Clip headers:** R25 clip blocks have a 4th sub-block (header `0xB4` vs `0xB0`). RL26 reads a
  clip's name at a fixed header offset, so without conversion it registers the wrong names and the
  cutscene layout crashes.
  - Handled by [animset.py](../../tools/animset.py) `to_rl26`.
  - The rebuild matches all 110 stock RL26 cutscene animsets byte for byte.
- **Key packings:** R25 adds 4-byte translations and 8-byte rotations that RL26 misdecodes.
  `transcode_tracks` re-packs them as floats, using decoders transcribed from Rugby 25's exe and
  checked against mocap that ships in both games.
- **Bone offsets:** R25's rig has extra roll joints, which makes its shins about 0.2 m short on
  RL26's skeleton, so players float with their toes down. RL26's constant bone offsets are swapped
  in. Camera constants and FOV stay R25's.
- **Motion set:** RL26 looks every clip up in `animations/motionset.motionset`.
  [motionset.py](../../tools/motionset.py) merges R25's records.
- **Emotion groups:** an emotion RL26 lacks crashes natively, so an `emotiongroups.lua` override
  adds the missing ones.
- **Ball prop:** R25 writes `propName = "ball"`, but RL26 only shows a prop named `ball`, so it's
  renamed.

## Known limits

- **Faces:** the post-conversion clips have no face tracks, so they keep RL26 expression groups.
  Mirrored (`_m`) cutscene clips reuse the unmirrored face.
- **Foot planting:** R25 clips have no foot-pin events, so there may be slight foot slide.
- **Root track:** `import --worldroot` synthesizes a `worldroot` track. It's off by default; the
  players look right without it.

## Undo

- Animsets: `python tools\add_entries.py remove-all --confirm`. This also removes the other appended
  entries, such as the club icons.
- Motion set: `python tools\pack.py restore --entry 91`.
