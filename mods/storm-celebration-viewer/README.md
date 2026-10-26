# storm-celebration-viewer

Adds a **Celebrations** tile to the Academy player view hub (Identity / Appearance / Skills /
Team / Sharing, and the read-only hub's tile list). It opens a small menu that plays one of
the 15 Melbourne Storm promo try celebrations on the menu player model and loops it until
you change it or back out. Use it to grab thumbnails.

- **Celebration**: left/right to pick a clip. It defaults to the viewed player's own
  celebration when that player is one of the 15 Storm players (matched on `identity.fullName`, letters only).
- **Face**: "Auto" plays the celebration's own Storm face clip. The rest of the list is every
  face clip named in `emotiongroups.lua` and `emotiongroups_ui.lua` that the menu has loaded
  (except `face_zero` and the test pose), sorted, without the `face_` prefix.
- **Club** / **Kit**: preview any club's jersey (every club with a kit; a user-created override
  of a club replaces the on-disc one). Kit lists all of that club's kits, hidden ones marked
  "(hidden)", and starts on the club's default (category 0) kit. The jersey is preview-only:
  the player's own uniform and club identity are copied on entry and put back on exit.
- **Framing**: Full Body, Full Body (Centred), or Head & Shoulders. These are the stock
  `playermodel_camera_aide` presets. The cutscene cameras are not used.
- **X**: pause / resume (freezes the pose). Picking another clip resumes.
- The stick still rotates the model as usual.

## How it works

- `app/playermodel/playermodel_resources.lua` loads `animations/cutsceneStormPromo.animset`
  into the frontend animation provider next to `ui.animset`, and unloads it on dispose. The
  frontend player model waits for the provider to finish loading, so the clips are ready
  before the model is shown.
- `app/academy/academy_player_viewstate_tiles.lua` defines `AcademyPlayerViewCelebrationState`
  (an `OptionMenuState` with two `ValueList` rows, like the Identity tile) and appends its tile
  to `CreateTiles` and `ReadOnlyTiles`. The script bundle can't take new files, so the state
  lives in this override.
- Each frame the state checks the model's primary body command. If it isn't the picked clip,
  or the clip has finished, it calls `playBodyAnim(clip, ..., true)` again (10-frame
  crossblend). That covers the first play, clip changes, the loop restart, and the idle that
  the hub or a camera change queues over it. The framing changes set `cameraInfo` directly,
  because `setCameraInfo` also queues the camera's idle animation.
- Root motion is off for menu models (`moveEnabled` false), so the player stays in place.

## Faces

Each Storm clip fires an `emotion_cs_storm_<player>` event. In a match that selects the
`cs_storm_<player>` group from `emotiongroups.lua`, which plays `face_storm_<player>_01`.
The menu's emotion system (`playermodel_animation_emotion.lua`) only loads
`emotiongroups_ui.lua`, so the event does nothing and the face stays on `face_idle_01`.
The face clips are still loaded in the menu, because `uiPlayerFacialAnimList = facialAnimList`
(`face/face_cs/face_storm_promo_01.anim`).

The tiles file wraps `PlayerModelAnimationEmotion.update` once at import. While an instance has
`forcedFaceAnim` set, the wrapper plays that clip as a looping emotion command (7-frame blend)
instead of the group, and `forcedFaceRestart` restarts it whenever the body loop restarts, so the
face stays in sync. Leaving the menu clears it and forces a re-evaluate back to the UI group.
Face clips per player are in the `face` field of the celebration list. Joe Chan and Xavier
Coates use `face_storm_31_joe_chan` / `face_storm_37_xavier_coates`. Tui Kamikamica has no face
group, so that clip uses the shoot's generic `face_storm_idle_01`.

The animset also has `<clip>_screenshot` variants (presumably single poses for promo stills).
They aren't in the list yet.

## Hub layout (Noesis, entry 57662)

The hub's tiles aren't a free list: `PlayerViewHub` in `views/academy/paacademyhubview.xaml`
binds exactly five buttons to `ButtonCollection[0]`-`[4]`, so a sixth tile never showed.
`noesis/workspace/views/academy/paacademyhubview.xaml` adds a `Celebrations` button bound to
`ButtonCollection[5]` in the empty slot next to Sharing (and `[4]` in `AcademyPlayerReadOnly`).
The shared button style collapses a button whose binding is empty, so hubs with fewer tiles
are unaffected.

Install both entries (game closed), each from a stock extraction:

```powershell
python tools\build.py full --confirm
python tools\build.py full --list manifests\57662.xml --extracted <stock 57662> --out _build\entry_57662.m3mp --confirm
```
