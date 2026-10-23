# gf-intro-effects

Grand Final intro effects: **smoke over every outdoor shot** and **team walk-out songs**. Both live
in `sim/hud/blackscreen_hud.lua` plus `sim/hud/hud_registration.lua`, because two mods can't override the
same file (this folder was `gf-stadium-smoke-overlay`).

## Smoke

Post-fireworks haze over the Grand Final stadium wide shot (`rl1_gf_stadium_wide_cam01`, every
competition/stadium variant). It starts thick, drifts with parallax, and clears over about 10 s. This is
a 2D overlay, so it doesn't touch the cutscene data or the particle system. The earlier particle attempt
([_disabled_mods/gf-stadium-smoke](../../_disabled_mods/gf-stadium-smoke/)) crashed the game at boot.

## How it works

- **Texture:** `resources/smoke.png` is an opaque greyscale cloud image meant for a screen blend. It's
  installed as a **new** texture, `ui/textures/mods/gf_smoke.texture` (an appended blobset entry, 1024x1024):

  ```powershell
  python tools\add_texture.py add --path ui/textures/mods/gf_smoke.texture --image resources\smoke.png --screen --size 1024 --black 80 --white 220 --gamma 1.2 --replace --confirm
  ```

  The current `smoke.png` is a soft-edged RGBA puff; its own alpha is multiplied into the result.
  `--screen` stores white with alpha = brightness, premultiplied like every shipped UI texture. Under
  premultiplied blending that's `result = L + dst * (1 - L)`, an exact screen blend.
  - `--black` / `--white` set which brightness counts as fully clear / fully opaque.
  - The image's darkest areas are about 106/255. Without the remap the whole screen goes milky.
  - Use `add_texture.py preview ...` to check a setting, and `--replace` to reinstall it.
- **HUD element:** `GFSmokeHud` lives in `sim/hud/blackscreen_hud.lua`, because `build.py` can't add new
  files to the script bundle. `sim/hud/hud_registration.lua` registers it.
  - It's registered first, so it draws under the rest of the HUD.
  - It sits outside the `not native.publicfacing` block, which in retail skips the stock black-screen and
    cameo HUDs.
- **What it draws:** a legacy `UIWidgetArea` holding three `UIWidgetTexture` layers of the smoke texture.
  - Each frame it reads the cutscene listener's `currentCutscene`. While the cutscene's name contains
    `gf_stadium_wide_cam01`, it runs its own clock from the frame delta and animates the layers. For any
    other cutscene it draws nothing.
  - Every native call is in `pcall`, so a failure switches the effect off. It never breaks the HUD.
- **Finding the cutscene listener:** the HUD's `uiServices` has **no** `cutsceneListener`. That was the
  first in-game failure (logged as "attempt to index field 'cutsceneListener'"). The working route is
  `hud.uiServices.universe.cutsceneListener`. `GFSmokeListenerRoutes` tries the known routes in order and
  caches the first that works.

## Debugging

Set `GFSmokeDebug = true` at the top of the block.
- **Log:** it appends to `gfsmoke_debug.txt` in the game folder. Lua's `io` library *is* available in
  retail. The log records creation, the listener route, every cutscene change (name, animset,
  update/render counts) and errors.
- **Status square:** a 40px square appears top-left. White = running; light blue was meant for "wide
  shot active", but it stayed white in-game even while the log showed the wide shot, so trust the log.
- **Every cutscene:** `GFSmokeDebugAnyCutscene = true` shows the smoke in every cutscene.

The GF intro order, as logged (Stadium Australia, NRL):
1. `rl1_gf_stadium_wide_cam01_NRL_stadiumAustralia` (about 9 s)
2. `rl1_intro_lockers_away/home_stadiumAustralia`
3. `rl1_gf_stadium_trophy_cam05_NRL_stadiumAustralia`
4. `rl1_corridor_away_NRL`
5. `rl1_gf_stadium_crowd_away_cam04_stadiumAustralia`
6. `rl1_intro_gf_away_team_01_NRL_stadiumAustralia`
7. `rl1_corridor_home_NRL`
8. `rl1_gf_stadium_crowd_home_cam07_stadiumAustralia`
9. `rl1_intro_gf_home_team_01_NRL_stadiumAustralia`

## When the smoke shows

- It arms when the stadium wide shot (`gf_stadium_wide_cam01`) starts.
- It then shows in every cutscene that isn't indoors (`GFSmokeIndoor`: names containing `lockers` or
  `corridor`): the stadium/trophy/crowd shots and both walk-outs, plus an anthem shot if there is one.
- It disarms when the intro's cutscenes end, so normal matches never get it.
- Each shot fades it in over `GFSmokeShotFadeIn` (0.5 s) and starts at full `alpha`. Over
  `fadeStart`..`fadeEnd` it thins to `alpha * sustain`, which it holds for the rest of the shot, so a
  45 s walk-out keeps a steady haze.
- In a harness run through a 45 s walk-out, the layer edges never came closer than 0.13 screen widths.

## Tuning (`GFSmokeLayers` in blackscreen_hud.lua)

| Layer | size (x screen height) | grow /s | drift /s | peak alpha | sustain | thins (s) |
|---|---|---|---|---|---|---|
| far | 2.3 | 0.02 | +0.006, -0.002 | 0.55 | x0.6 | 1.5 -> 11 |
| mid | 2.7 | 0.05 | -0.012, -0.004 | 0.45 | x0.45 | 1 -> 8 |
| near | 3.2 | 0.14 | +0.02, +0.006 | 0.35 | x0.3 | 0.3 -> 5 |

- **Depth:** the near layer is biggest, grows fastest (pushing through the haze) and clears first.
  The opposite drift directions give the parallax.
- **Size limit:** every layer must stay wider than a 16:9 screen for the whole ~15 s shot, drift
  included: `(size / (16/9) - 1) / 2 > |driftX| * 15`. Otherwise its square edge comes into view.

## Limits
- It's screen-space, so it doesn't track the camera: a big pan won't move the haze with the stadium.
  The parallax drift hides this for the slow aerial shot.
- Widths assume 16:9.

## Walk-out songs

`GFIntroMusicHud` (also in blackscreen_hud.lua) drives the music from cutscene names. The order was
verified in-game (see the list above).

| Moment | What happens |
|---|---|
| `rl1_gf_stadium_wide_cam01` starts (GF intro begins) | arms; loads `intro_song_<icon>` banks for both clubs; stops the stock GF music (`sfx_cutscene_music_gf_01`) by queuing `StopSoundEvent` for 2 s, which also removes its still-queued Play |
| `rl1_corridor_<side>` (team leaves the change room) | fades out whatever plays (2 s) and starts that team's song, which has a 2 s fade-in baked in; restarted when it ends, so it loops |
| the second team's walk-out ends | fades out (2.5 s) before the anthem; banks unloaded 5 s later |

- **Teams without a song** get the stock GF music for their segment instead (`GFIntroSongFallbackEvent`).
- **Skipping the intro:** once armed, any cutscene that isn't a pre-anthem intro shot
  (`GFIntroPreAnthemCutscenes`), or no cutscene at all (what a skip leaves), ends the intro effects. The
  music fades over `GFIntroSkipFadeOut` (1 s), or the normal 2.5 s if both teams were already out. The
  crowd lights fade and the crowd lighting is restored.
- **Normal matches** are untouched: nothing arms without the GF wide shot.
- **How it plays:** songs are posted straight to `soundManager:postEvent(name, "DefaultObject")`. The
  SoundSystem's `StopSoundEvent` only stops events the SoundSystem queued itself, so it can't touch them.
  Fades use `stopEvent(playingId, seconds)`.

### Adding a team song

1. Name the file after the club icon: `resources/intro-songs/<icon>.ogg` (any format ffmpeg reads).
2. Build and append its bank:

   ```powershell
   python tools\add_sound_bank.py add --name intro_song_nrl_storm --audio resources\intro-songs\nrl_storm.ogg --confirm
   ```

   - `--fade-in-ms` sets the fade-in (default 2000).
   - Loudness: every song is normalised to `--loudness` (default -8 LUFS, true peak -1 dB), so songs
     match. It then gets `--volume-db` (default +4) as the Wwise Sound's Volume property (`0x00`),
     which adds gain in Wwise's float mix beyond what the 16-bit file can hold.
   - Raise `--volume-db` for louder (try +6 to +8; watch for clipping when the crowd peaks).
     `--no-normalize` keeps a file's own level.
   - Songs can be any length (about 5.4 MB per 28 s). Shorter than a team's turn means a loop,
     which replays the fade-in.
   - `--replace` rebuilds an existing song bank in place (no script rebuild needed).
3. Add the icon to `GFIntroSongs` in blackscreen_hud.lua, then rebuild 39959.

### How the banks work (tools/add_sound_bank.py)

- Banks are `sound/<name>.bnk` blobset entries, stored raw.
- Wwise IDs are FNV-1 32 of the lowercase name.
- Each licensed menu song is a one-event bank. The tool clones `music_ace_candy_apple_red`: same mixers
  and routing, with a new bank/event ID, a new Sound/Action/media ID, the mixer child list repointed,
  and the Play action given property `0x3A` (transition time, ms) as the fade-in.
- The audio is embedded as **16-bit PCM** (plugin `0x00010001`, Wwise-style extensible `.wem`). Stock
  audio is Wwise Vorbis, which needs Wwise's encoder. PCM costs about 5.4 MB per 28 s stereo song.

### Debugging
`GFSmokeDebug = true` (currently **on**) logs the music events too to `gfsmoke_debug.txt` in the game
folder: club icons and songs found, bank loads, each `postEvent` and its playing ID (0 = failed), and the
finish.

## Crowd lights

`GFCrowdLightsHud` (also in blackscreen_hud.lua) scatters coloured light blobs across the audience
during the GF intro and dims the crowd's own lighting.

- **The rig:** 32 soft `CSpotLight`s, using the stock walk-on spin rig's settings
  (`cinematic_generic_walkon_light_spin_01`).
  - They hang about 50 m above the middle of the ground. Each is aimed at a random point on a ring
    round the stands (x along the pitch: 66-88 m, z: 44-64 m, 4-26 m up).
  - Cone angles of 4-11 degrees give the blob sizes. No shadows.
  - The pitch always runs along x: stadium cutscene rotations are only 0 or 180 degrees.
- **Aiming:** spotlights shine along local **+Z**, checked against the stock rigs. Shipped lights never
  use `targetted`, so each rotation quaternion is computed from source -> target.
- **Animation:** there's no API to recolour a live light. The rig is its own lighting-scene layer,
  `gf_crowd_lights`, removed and re-imported 15 times a second with new colours and brightness, using
  the same `currentLightingScene:import` / `removeLayer` calls cutscenes use.
- **Colours:**
  - Wide shot (and trophy shot): green <-> blue, the blend flowing round the stadium.
  - From `rl1_corridor_<side>`: that team's primary and secondary colours, alternating between
    neighbouring lights and swapping every 1.2 s. Near-black club colours become white.
- **Flashing:** two bright bands chase round the stands (`GFCrowdWave*`), and random blobs blink off
  each tick (`GFCrowdFlickerChance`), so the lights look like they flow through the audience.
- **Fades, never pops:**
  - Each blob's level eases towards its target (`GFCrowdBlobFadeIn` 0.6 s / `GFCrowdBlobFadeOut` 0.9 s).
  - The bands have a wide soft edge (`GFCrowdWaveSoftness`), and flickers are eased dips
    (`GFCrowdDipDuration`).
  - Brightness follows level^2.2 (`GFCrowdBrightnessCurve`), because HDR exposure makes a linear ramp
    read as instantly on.
  - Each stadium shot ramps the whole rig up over `GFCrowdShotFadeIn`.
  - Measured in the harness: at most about a quarter of full brightness changes between updates.
- **Where it shows:** only in outdoor shots (`gf_stadium_*`, the walk-outs). The layer is removed for
  the lockers and corridors. It fades out with the music when the second walk-out ends.
- **Darker crowd:** `lightingModule.dynamicEnvironment` crowd ambient diffuse/specular multipliers are
  set to x0.35 (`GFCrowdDarken`) for every time slice, then restored afterwards.
- **Tuning:** all the constants are at the top of the block: count, ring size, cone sizes, brightness,
  update rate, darkening, colours, wave speed and flicker.
- **`resources/gf-light.png`:** not used. Engine lights have no projected-texture (gobo) field. A soft
  spotlight (`spotSharpness` -1.4, `spotVignette` 1) already throws that round falloff natively.
