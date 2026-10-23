# restore-cut-try-celebrations

Plays try-celebration animations that ship with the game but never play. All three Lua
overrides are generated from the stock decompiled sources by `generate.py`. Edit the
settings at its top and re-run it (`python mods\restore-cut-try-celebrations\generate.py`)
rather than hand-editing the Lua.

## Restored legacy celebrations

Three animsets are loaded by `intermediatelua/animations/animationlist.lua` but no cutscene
ever used them:

| Cutscene | Animset | Players | Cameras |
|---|---|---|---|
| `cs_trycelebrate_tapshoulder_01` | `cutsceneTryCelebrateTapshoulder01` | 2 | 4 |
| `cs_trycelebrate_scruffhair_02` | `cutsceneTryCelebrateScruffleHair02` | 2 | 4 |
| `cs_tryneutral_tapchest_01` | `cutsceneTryNeutralTapchest01` | 1 | 4 |

The other legacy `cutsceneTryCelebrate*` animsets (hug 01-08, hug runoff, low-5 hug,
scruffhair 01) were remade as the `rl1_og_*` cutscenes and already play.

The definitions copy `rl1_cs_trycelebrate_mr_bow_arrow_01`, the one cutscene still using a
legacy animset: clips `pN_<file name>`, camera joints `cs_cameraNN` on the p1 clip, plus
the same crowd and flame effects. The anim files store clip and joint names as hashes, so
the player and camera counts are guesses (Mr Bow & Arrow has 3 and 4; every stock cutscene
has at least 2 players). They're added to `TryCelebrateStanding`, `_low` and `_high`
(standing tries only).

## Storm players' own celebrations

`cs_storm_promo.lua` defines per-player celebrations for 15 Melbourne Storm players
(animset `cutsceneStormPromo`, clips `<first>_<last>_celebration`). No group uses them. The
stock definitions are studio shots: world origin, academy lighting, stadium lights and sun
switched off. So `generate.py` writes match-style `rl1_try_<clip>` cutscenes anchored on
the scorer instead. All 15 are added to the standing-try groups, so any player can get
one. On top of that, `trycelebrate_rulestate.lua` checks the scorer's `identity.fullName`
(letters only, lowercased): if it's one of the 15 Storm players, they play their own
celebration `STORM_CHANCE_PERCENT` of the time.

## Camera motion

The Storm promo cameras are locked off. `game/camera/animated_camera.lua` gets three
optional per-camera fields, applied in `evaluateCamera` with a smoothstep over the clip's
length:

- `motionPushInFovScale`: FOV multiplier at the end (0.82 = slow zoom in)
- `motionDollyDistance`: metres drifted forward along the view (0.6)
- `motionSway`: metres of slow handheld drift (0.04)

Stock cameras don't set these fields, so they're unaffected. Only the Storm cutscenes use
them (`STORM_CAMERA_MOTION`); `LEGACY_CAMERA_MOTION` is empty.

## Test settings

- `LEGACY_WEIGHT = 1000` and `STORM_POOL_WEIGHT = 1000`: the 18 modded celebrations play on
  almost every standing try. Use 1 for normal play (stock weights are 0.5-1; Mr Bow & Arrow
  is 10).
- `STORM_CHANCE_PERCENT = 50`: how often a Storm player uses their own celebration before
  the random pick.
