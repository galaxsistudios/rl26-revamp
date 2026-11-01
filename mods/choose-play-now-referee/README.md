# choose-play-now-referee

Adds a **Match Officials** button to Play Now's Match Settings screen (after team selection),
right after Manage Lineup. It swaps the settings panel to its own page, and Back returns to the
settings:

| Row | Choices |
| --- | --- |
| Referee | every referee of the match's sex (Academy-created ones included), by name |
| Touch Judge 1 | same list |
| Touch Judge 2 | same list |
| Referee Jersey | Auto (the stock pick) or any of the 15 referee kits: NRL Green/Orange/White, Super League Yellow/Blue/Green/Red, State of Origin White, Generic Yellow/Blue/Green/Red, World Cup Blue/Pink/White, plus extra kits from other mods (NRL 2026 Orange/Yellow/Blue from nrl-referee-2026-kits) |

The three officials are always distinct: picking someone who already has another role swaps
the two. All three are saved to the profile at lockdown and pre-selected next time. The jersey
has no profile field, so it is remembered only until the game is closed.

- Overrides `app/casual/casual_newmatch.lua` only. It seeds `localMatchSettings.refereeIds`
  (slot 1 = referee, 2-3 = touch judges) from the profile's saved `casualReferees{Male,Female}`
  when those referees still exist, otherwise random. `matchin.setupReferees` uses those ids
  instead of rolling random ones, and the stock `matchsetup_aide.saveSettingsForFutureMatches`
  saves them.
- The button and page are added by wrapping `MatchSetupMatchSettingsState.createMenuItems` and
  `update` at load, because `enable-casual-fieldmarkings` already overrides that file. While the
  officials page is up, the wrapped `update` handles Back itself instead of leaving the screen.
  Switching pages repopulates the live option menu in place (as the stock `refreshMenuItems`
  does). Reloading `paPreMatchSettingsView` with the same view model left an empty panel in game,
  and a fresh view model (stock `reconstruct`) re-runs `setGrounds`, which resets the stadium.
  Page swaps and failures are logged to `playnow_officials_debug.txt` in the game folder.
- The stock referee rows in that file are never shown: public builds lock them
  (`lockedReferee`), and their `Value` display type isn't one the Noesis option menu can render.
  This mod uses `ValueList` rows instead.
- Jersey: the pick goes in `localMatchSettings.modRefereeUniform` (an `EUmpireUniform` int, nil =
  Auto). `matchin.setupLobbyMatch` is wrapped so that while it runs with that set,
  `matchin_refereeuniform.determineUniformType` returns the pick. Other modes (career,
  competitions, online) never set it and keep the stock pick. All officials wear the
  `RefereeMale_<kit>` visual, as in the stock game.
- Extra kits: another mod can list `{guid, label, base}` in `_G.MOD_EXTRA_REFEREE_KITS`. They
  appear after the stock kits (value 1000 + index). The pick returns the `base` kit's enum, and once
  `setupLobbyMatch` is done every official's `uniform` (the team visual config itself) `uniformTop` is set to `guid`.
- Women's matches list female and male referees together. The game only ships two female
  referees (Kasey Badger, Belinda Sharpe, unhidden by `unhide-coaches`), fewer than the 3 officials
  a match needs. A female referee is pre-picked when one exists, and the touch judges default to
  male (stock `matchin.setupReferees` always rolls male officials).

## Crowd Settings (play-now-crowd-settings)

The same file also adds a **Crowd Settings** button after Match Officials, using the same in-place page
swap. The page holds Attendance plus a Fans row for each team, in 5% steps; the two Fans rows always add
up to 100%. The page is rebuilt each time it opens, so the Fans rows carry the teams currently picked. The
values go to `_G.modPlayNowCrowd` and to `playnow_attendance` / `playnow_home_fans` in `rl26_revamp.ini`.
Applying them to the match (seats, home/away split, sound) is mods/play-now-crowd-settings and
crowd-team-kits' `crowd_rugby.lua`; see that README.
