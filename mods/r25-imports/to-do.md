# r25-imports to-do

## Later: package the Rugby 25 Expansion for release

R25-derived content never ships in the RL26 Revamp release. Each player generates it from their own
Rugby 25 install. The work:

- [ ] **One install command:** `python tools\r25_import.py install` would:
  - find both games and check their versions;
  - refuse while either game is running;
  - run every step in order: import, motionset, tackleset, gen-mod, restore 39959, build;
  - finish with the safety checks (tackle pool limit, missing emotion groups).
- [ ] **One uninstall command:**
  - restore entries 9, 91 and 39959;
  - remove the added r25_ entries: celebrations, conversions, tackles and `r25_faces`.
- [ ] **Player-facing guide:** what the expansion adds, what's required (a Rugby 25 install), and
  how to install and uninstall.
- [ ] **Build tie-in:** decide how the expansion's script changes coexist with the Revamp's
  `build.py full` (today the mod is just one of the mods it builds).

## anzac-cutscene (parked 2026-10-25)

Goal: a solemn intro for Anzac matches with both teams **walking** out together. Parked because the
last two camera shots go black.

**Where it stands:**
- **Clip:** R25 `IntroFinalsTournament_02` (animset `cutsceneIntroWalkon`, trimmed to its 30 clips,
  entry 104692). Both teams walk side by side out of the tunnel and form two lines (21 s, about
  2 m/s). The entry is still in the blobset, but nothing references it.
- **Config:** in imports.json the cutscene item and `introSequences` → `r25_anzac` are
  `"disabled": true`; set both back to enable.
- **Already working:**
  - stripped of fireworks, flames, trophy and ball props, with the crowd sound only;
  - shifted +25 m by `clipOffsets` so it stays inside RL26's run-out area;
  - plays without freezing now that the motion set stays under 8,192 clips.
- **The problem:** after the side-by-side tunnel shot (`cs_camera21`, frames 0–430), `cs_camera18`
  (430–535) and `cs_camera20` (535–end) show black. Both follow a player
  (`moveRelativeToActorLabel` p21 / p5). `cs_camera20` is a 2.5° telephoto locked on p5.
- **Tried, no fix:**
  - shifted static camera positions as well as animated ones;
  - dropped the player-following (`cameraFields`);
  - gave p5 / p21 the captain filters so the slots are always filled (`actorFields`).
- **Ideas to try next:**
  - Replace `cuts` so `cs_camera21` holds for the whole scene, or use RL26 cameras from
    `rl1_intro_gf_home_away_team_01` (RL26's own two-team walk-out).
  - Check in-game which actors actually spawn: log `cutsceneListener` actors through the
    r25-imports `debugLog`.
  - Try the scene without `clipOffsets` to see whether the shift breaks the follow-cam maths
    (`getOriginalWorldRootStartFrame`).
- **Trigger, still to do:** RL26 has `native.ETrophy.AnzacTest`
  (`matchInData.cutsceneInfo.trophyModel`). An Anzac Day club round would need a date or teams
  check.

## referee-card-cutscenes (later, for Super League teams)

R25 `RefereeCard_Yellow`, `RefereeCard_Yellow_Captain`, `RefereeCard_Red` and
`RefereeCard_Red_Captain` (legacy `cutscenes_config.lua`, animset `cutsceneRefereeCard`, 8.3 s).
Each has the referee, the captain and the offender, with talk, angry and disappointed faces. The
animations ship in R25.

- **Use:** as alternatives in RL26's `SinBin` / `SendOff` groups (one stock cutscene each), only for
  Super League (card) matches.
- **Missing props:** `props/objects/models/penaltyCard_yellow.model` and `penaltyCard_red.model` aren't
  in RL26. Import the R25 models and textures first (see adding-new-assets).
- **Placement:** no `cutsceneOrigin` (world), so they need re-anchoring on the offender
  (`PrimaryActor`, like the post-conversion shots).

## Other ideas

- [ ] More R25 cutscenes (injuries, trophy celebrations, walk-ons, formation cameras), with their
  R25 faces.
- [ ] Mirrored faces for `_m` cutscene clips (swap the left/right pose weights).
