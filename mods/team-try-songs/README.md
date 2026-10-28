# team-try-songs

A club's own try song plays instead of the stock try music.

| Match | Whose try gets their song |
|---|---|
| NRL finals or Grand Final | Either team |
| Any other match | Home team only. The away team gets the stock music. |

Clubs without a song always get the stock music. So do field goals.

Touches one file in 39959 (scripts) and adds one sound bank per song:

| Files | Entry |
|---|---|
| `src/script-game/simlisteners/sound/listeners/soundlistener_ingame_music.lua` | 39959 |
| `sound/try_song_<icon>.bnk` | appended entries (103474 Broncos, 103475 Roosters) |

This mod now owns `soundlistener_ingame_music.lua`, because two mods can't override the same file.
The file also carries [bunker-overturned-try](../bunker-overturned-try/)'s one-line change, which plays
the try music for a provisional try (`provisionalTry`).

## How it works

- **Who gets a song:** the listener's constructor reads both clubs' icons and checks them against
  `TrySongs`. It reads `matchInData.<side>.decalIdOrIcon`, the same route gf-intro-effects uses.
  The result is `self.trySongs[side int] = "try_song_<icon>"`. In a normal match only the home
  side is filled in.
- **Finals detection** (`trySongsIsNRLFinals`): `stateOfTheSeason.isFinal` or `isGrandFinal`, or
  `cutsceneInfo.playGFIntroCutscene` (the casual menu's Grand Final). If the match has a
  `competitionId`, it must be `League_NRL`. Without one (casual), Super League rules don't count.
  These are the same flags `initial_cutscene.lua` uses to pick the finals and GF intros.
- **Loading:** each song's bank is added to the listener's bank list as a `Complete` bank. The stock
  `soundbank_helper` loads it with the match (the loading screen waits for it) and unloads it after.
  Only clubs that get a song this match are loaded.
- **Playing:** `onTryScoredEvent` passes the scoring side's song to `startCelebrationMusic`. The
  stock condition is unchanged: no music for video-referee tries or no-tries. After the stock 2 s
  delay, the timer queues the song through the SoundSystem (`wwiseEvent` = the event name) with
  the stock `IngameMusic` tag. Every stock stop (conversion setup, kick-off, interactive replay)
  then fades it out with a 3 s fade, as it does for the stock music.
- **No clap-along:** the stock music turns on the crowd clap-along RTPC. A club song skips that,
  because the clapping wouldn't be in time with it.

### Bunker tries

[bunker-broadcast-decision](../bunker-broadcast-decision/) adds `onVideoRefereeDecisionEvent`. A
bunker TRY starts the try music (or the club's song) `BunkerTryMusicDelay` (3.6 s) after the
decision event, just after the try whistle. It only runs when the event carries `bunkerBroadcast`.
Stock bunker tries still have no music.

## Adding a club's song

1. Name the file after the club icon: `resources/try-songs/<icon>.ogg` (any format ffmpeg reads).
2. Build and append its bank:

   ```powershell
   python tools\add_sound_bank.py add --name try_song_nrl_storm --audio resources\try-songs\nrl_storm.ogg --fade-in-ms 250 --confirm
   ```

   It uses the same loudness options as the walk-out songs (see gf-intro-effects). `--replace`
   rebuilds a bank in place, with no script rebuild needed.
3. Add the icon to `TrySongs` at the top of the Lua file, then rebuild 39959:

   ```powershell
   python tools\pack.py restore --entry 39959
   python tools\build.py full --confirm
   ```

Only list icons whose bank is installed. Loading a missing bank crashes the game natively, and
`pcall` can't catch it.

## Debugging

Set `TrySongsDebug = true`. It appends to `trysongs_debug.txt` in the game folder: each side's
icon, the finals flag and the chosen song when the match loads, then each song played.

## Limits

- The songs are 39.5 s and don't loop. The stock music normally stops at the conversion setup well
  before that.
- The banks are cloned from a menu song, so they use the menu music's Wwise routing, not the
  stadium PA bus. They sound clean, without the stock music's loudspeaker colour.
