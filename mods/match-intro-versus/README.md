# match-intro-versus

A broadcast-style opening for the match intro. The stock intro cuts straight into the home sheds. Now
it runs like this:

```
stadium establishing shots (all three, random order per match, ~10 s)
  + both crests fly in from the sides, VS in the middle, venue / kick-off bar underneath
-> home team stinger -> home sheds
-> away team stinger -> away sheds
-> stock intro from there (away walkout, corridor, crowd, home walkout, anthem)
```

## Grand Final trailer intro

Each Grand Final has a random chance (50% by default, picked from the match seed) of a trailer-style
intro, built from footage that ships in the game but is never shown:

- **Locker rooms, re-edited.** The p1 clip of each locker animset (`rl1_intro_lockers_home/away`) holds
  14 camera tracks, but the stock scenes show one random camera for the whole 6 s take (away 01-04,
  home 01/03). Cameras away 05-07 and home 02/04-07 are never seen (06/07 even have authored focus
  pulls; away 06 is a low close-up). `rl1_intro_lockers_away_trailer` / `_home_trailer` (generated at
  the end of `cs_lockerroom_data.lua`, stadium-cloned like the stock ones) cut between them:
  - away: cam06 (0) -> cam07 (48) -> cam05 (96) -> cam03 (138)
  - home: cam07 (0) -> cam02 (66) -> cam06 (105) -> cam04 (135)

  Frames are 30 fps. Edit `LockerTrailerEdits` to re-cut them. A camera the base scene doesn't define
  goes in `addCameras`.
- **Trailer corridor walks.** `cs_trailer_data.lua` ships slow, dramatic 13-man corridor walks
  (`rl1_trailer_corridor_dramatic_*`). They bring their own corridor set (`corridor01.model`) and
  lighting, and gf-tunnel-team-colour-lights recolours their accent lights to the walking team. They
  go in **front of** the stock GF corridor shots, which stay, because gf-intro-effects starts each
  team's walk-out song on `rl1_corridor_<side>`. In the Super League GF both walks come before the
  joint corridor shot.

The alternatives are registered as `trailer_gf_intro_*` in `cutscenedata_config.SequenceAlternatives`
and picked by `introVersusAlternativeFor`. The settings are the `IntroTrailer*` tables at the top of
`initial_cutscene.lua`: `IntroTrailerWeight` / `IntroTrailerStockWeight` set the odds (stock weight 0
= always, handy for testing), and `IntroTrailerEnabled = false` turns it off. The other trailer pieces
(`tunnel_walk_*`, `gf_runout_*`) duplicate what the GF intro already shows, with the same GF props.

The stinger is replay-team-stinger's sweep (secondary band, primary panel, crest), in the colours of the
team whose locker room comes next.

Touches two bundles (see INSTRUCTIONS.md):

| Files | Entry |
|---|---|
| `src/script-game/rules/cutscenes/initial_cutscene.lua` | 39959 (scripts) |
| `src/script-game/intermediatelua/cutscenes/data/cs_lockerroom_data.lua` (stock copy + trailer locker edits) | 39959 (scripts) |
| `noesis/workspace/views/testscreens/testscreen.xaml` | 57662 (Noesis XAML) |

**Needs** gf-tunnel-team-colour-lights (its `teamshield_rulestate.lua` has the hooks that drive this) and
replay-team-stinger (the stinger). Without replay-team-stinger the overlay still plays and the locker
cuts stay stock. The fonts come from nrl-broadcast-scoreboard. Without it the text falls back to the
default font.

```powershell
python tools\pack.py restore --entry scripts
python tools\build.py full --confirm

python tools\pack.py restore --entry xamls
python tools\extract_m3mp.py --entry xamls --out <tmp>
python tools\build.py full --list manifests\xamls.xml --extracted <tmp> --out _build\xamls.m3mp --confirm
```

## Which intros

| Intro | Establishing shot | Overlay + stingers |
|---|---|---|
| Regular match (`home/away_is_kickoff_intro`, with or without anthem) | added | yes |
| Finals (`finals_intro`, `_anthem`) | stock `rl1_stadium_wide_cam02` already opens it | yes (away sheds come first there) |
| Grand Final | stock | no (gf-intro-effects owns that one) |

Edit `IntroVersusSequences` (gets the shot) and `IntroVersusOverlaySequences` (gets the overlay) at the
top of `initial_cutscene.lua` to change this.

## How it works

- **The establishing shots:** each one is only 3-4 s (the in-game log measured `crowd_away_cam04` at
  2.7 s and `crowd_home_cam07` at 3.5 s), so all three play back to back in a random order:
  `rl1_stadium_wide_cam02` (cloned per stadium), `rl1_stadium_crowd_away_cam04` and
  `rl1_stadium_crowd_home_cam07`. They're the finals intro's stadium shots (animset
  `cutsceneStadiumShots`, the same as the stock `rl1_intro_stadium_crowd_cam12`, flame jets included).
  - `initial_cutscene.lua` registers one copy of each generic sequence per shot order:
    `versus_<1-6>_home_is_kickoff_intro`, and so on. `getInitialCutsceneName` picks the order from
    `matchInProgressData.matchSeed`. The preload (`GameplayLoadingInitialCutscene`) and the playback
    (`TeamShieldRuleState`) both call it, so they agree.
  - `SequenceList` is the same table `CutsceneConfigLoader` holds, so adding keys at import is enough. No
    cutscene data file is touched, which matters because r25-imports and restore-cut-try-celebrations
    already own `cutscenedata_config.lua`/`cutscenegroupdata_config.lua`.
  - A first version picked one shot through a cutscene group. That left the overlay a 3 s window and
    it was gone before it finished animating in.
- **The overlay:** `views/testscreens/testscreen.xaml` is an unused test view. Nothing loads it. Its
  content is replaced, because `build.py` can't add files. The view model is `NVMMatchIntroVersus`:
  - `IntroState` (`hidden`/`in`/`out`) drives the storyboards through `ei:DataTrigger`.
  - `HomeTeam`/`AwayTeam` are the HUD's own NVMTeams, for colours and crests. `dispose` clears them
    first, the same pitfall as the stinger.
  - `VenueName` is `groundInfo.groundDisplayName`, falling back to `Ground_<key>`. `VenueCity` is
    `Location_<locationEnum>` from `stadium-cfg`.
  - `KickOffTime` comes from `matchInData.startTime`. The stock hours show as the match settings menu
    labels them (10AM, 2PM, 4:30PM, 7:00PM, 8:30PM); any other hour is formatted.
- **The driver:** `MatchIntroVersus` (also in `initial_cutscene.lua`) is created in
  `TeamShieldRuleState.onEnterSolid`, updated in `updateSolid` and disposed in `onExitSolid`.
  Each frame it reads `services.cutsceneListener.currentCutscene`:
  - First cutscene is an establishing shot: overlay `in`. It stays up across the following establishing
    shots and goes `out` `IntroVersusOutLead` (1.1 s) before the last one ends.
  - When the cutscene after the current one in `cutsceneQueue` is a locker room (`lockers_home` /
    `lockers_away` in its name), it calls `TeamStinger:kickOutro(team)` `IntroVersusStingerLead`
    (0.55 s) before the cut. Then it calls `release()` once the locker shot has played
    `IntroVersusRevealDelay` (0.15 s).
  - A cutscene only counts once it's been seen with more than the lead left, so a stale finished one
    can't kick early.
- **Never breaks the intro:** every hook in `teamshield_rulestate.lua` is `pcall`ed. An update error
  disposes the overlay. A skipped intro disposes it and releases a covering stinger. The stinger also
  releases itself after 5 s covered (`TeamStingerMaxHold`).

## Tuning

| Setting | Where | Default |
|---|---|---|
| `IntroVersusEstablishingShots` | initial_cutscene.lua | the three shots above (every order is registered) |
| `IntroVersusOutLead` | initial_cutscene.lua | 1.1 s. Keep it above `VersusOut` (0.5 s) + `IntroVersusStingerLead` |
| `IntroVersusStingerLead` | initial_cutscene.lua | 0.55 s. Stinger `TeamStingerCoverTime` (0.5) + a little |
| `IntroVersusRevealDelay` | initial_cutscene.lua | 0.15 s of locker shot under the stinger |
| Layout, timings, easing | testscreen.xaml | see the comment at its top |

## Debugging

`IntroVersusDebug = true` (currently **off**) appends to `matchintroversus_debug.txt` in the game folder.
A normal regular-season intro logs:

```
intro versus_3_home_is_kickoff_intro
view loaded, venue Accor Stadium / Sydney / 7:00PM
cutscene 1: rl1_stadium_crowd_away_cam04 (2.7)
overlay in
cutscene 2: rl1_stadium_wide_cam02_...
cutscene 3: rl1_stadium_crowd_home_cam07 (3.5)
overlay out
stinger kick for <home>, 0.55s before rl1_intro_lockers_home_02...
cutscene 2: rl1_intro_lockers_home_02...
stinger release into rl1_intro_lockers_home_02...
stinger kick for <away>, ...
...
disposed
```

The cutscene lines include each shot's real duration, which helps with tuning. `stinger unavailable or
busy` means replay-team-stinger isn't installed or its stinger was mid-animation.

First in-game test (2026-10-24): the script side worked, but the overlay didn't show because entry 57662
hadn't been rebuilt (the stock test view appeared instead: an empty lineup frame with "Manage Lineup"),
and the single shot was too short. Both fixed. Second in-game test: confirmed
working.

## Ideas not done

- `rl1_trailer_stadium_camera_*` are flyovers made for single stadiums (Accor, Suncorp, Manchester,
  Wembley). They'd make great establishing shots at those grounds, but they use other animsets. That
  would mean picking per stadium in `getInitialCutsceneName`, so they're left out for now.
- Shot length can't be trimmed from config: a cutscene's duration is its longest actor animation.
