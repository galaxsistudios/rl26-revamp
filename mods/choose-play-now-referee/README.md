# choose-play-now-referee

Adds a **Referee** row to Play Now's Match Settings screen (after team selection). The
pick is saved to the profile at lockdown and pre-selected next time, so the referee is no
longer random every match. Touch judges are still random each match.

- Overrides `app/casual/casual_newmatch.lua` only. It seeds `localMatchSettings.refereeIds`
  (slot 1 = the profile's saved `casualReferees{Male,Female}[1]` if that referee still
  exists, otherwise random). `matchin.setupReferees` uses those ids instead of rolling
  random ones, and the stock `matchsetup_aide.saveSettingsForFutureMatches` saves them.
- The row is added by wrapping `MatchSetupMatchSettingsState.createMenuItems` at load,
  because `enable-casual-fieldmarkings` already overrides that file. The stock referee rows
  there are never shown: public builds lock them (`lockedReferee`), and their `Value` display
  type isn't one the Noesis option menu can render. This mod uses a `ValueList` row instead.
- The list is every referee of the match's sex (Academy-created ones included), found by
  stepping `getRelativeNPCIdOfType` until it wraps, then sorted by name.
- Women's matches list female and male referees together. The game only ships two female
  referees (Kasey Badger, Belinda Sharpe, unhidden by `unhide-coaches`), fewer than the 3 officials
  a match needs, so the row used to vanish. A female referee is pre-picked when one exists, and the
  touch judges are male (stock `matchin.setupReferees` always rolls male officials).
