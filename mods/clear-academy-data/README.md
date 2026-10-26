# clear-academy-data

On the home screen's **Academy** row, **Y / Triangle** (shown as "Clear Academy Data" in the
button bar) opens a menu where you can choose which Academy content to delete from your save:

- **Created Clubs** deletes your own clubs (`userCreated:deleteClub` per club; official ids and the
  online ranked club are skipped). If the club list can't be iterated, it falls back to the stock
  `clearNonRanked`.
- **Reset Edited Official Clubs** restores official clubs edited in the Academy or with a saved casual
  lineup (`saveCustomLicensed` / `saveCustomLicensedMatchClubLineup`). In game these live in the
  native custom-licensed store, not `userCreated`. `userCreated:containsClub` and
  `isCustomLicensedData` are true for every official club, and `clubManager.onDisc` already has the
  edits merged in, so none of them can detect edits. An edit is detected by comparing a signature
  (name, nickname, kit count, roster, and each lineup's category/slots/captain) of
  `clubManager:getClub(id)` against `clubManager.onDiscDatabase:getClub(id)`, the raw disc data.
  Only `CClubLineup.getLineupSize(category)` slots are read; slots past the end hold uninitialised
  memory. To reset, it copies the raw club into a new `CClub` (`:set`) and calls
  `saveCustomLicensed` on it. Confirmed in game: Dolphins lineup edit detected (1 club) and back to
  stock ("matches stock").

Rows: Created Players, Reset Edited Official Players, Created Clubs, Reset Edited Official Clubs, Logos, Referees, Coaches, Stadiums, Leagues,
Match Types, Custom Difficulties.

- **Created Players** deletes players made in the Academy (or downloaded). Entries that keep an on-disc
  id (edits to official players) are skipped.
- **Reset Edited Official Players** puts every edited official player back to the base-game version.
  It finds them two ways: user-created entries with an on-disc id
  (`CPlayerDatabaseOnDisc.getIsOnDiscPlayerId`), and a scan of `playerManager.onDisc` using
  `containsUserCreatedVersionOfPlayer`. Each one goes through the stock Academy player-list action:
  tier-1 scanned players use **Reset** (`resetCustomLicensedPlayer`); everyone else uses **Delete**
  (`tryDeletePlayerRepairLineups` with `academyId`, then
  `academyPlayerManager:deleteUserCreatedVersionOfPlayer`), which restores the on-disc player.
  Counts are worked out when the menu opens and after a clear, not on every toggle, because of the
  on-disc scan.

Each row shows how many items you have. **Select All** ticks every row (it then reads **Deselect All**).
**Clear Selected Data** asks for confirmation (No is the default). The prompt lists what will be deleted
and says it can't be undone. After you confirm, a busy screen ("Clearing Academy Data") stays up while
each type is cleared and the profile is saved, then a summary appears.

## Local only

Nothing here calls the sharing service. Only the local save is changed, so anything uploaded to the
Big Ant servers stays there. Downloaded FanHub copies stored in your save are deleted along with
everything else of that type, but the online originals are untouched. Also deliberately left alone:

- **User statistics** (stock Reset Academy offers these, but they're synced with the sharing service).
- **Your online ranked club**: clubs are cleared with the stock `clearNonRanked(onlineRankedClub)`.

## Behaviour notes

- **Clubs takes Leagues with it.** A user league can contain user clubs, so when Clubs is ticked and you
  have user leagues, Leagues is cleared too. The confirmation prompt says so. `leagues.userCreated:clear()`
  also reverts Academy edits to official leagues.
- **Players** are deleted one by one through `ClubLineupHelper.tryDeletePlayerRepairLineups`, the same as the
  stock Delete Player screen. If a club (for example the kept ranked club) can't fill its lineup without a
  player, that player is kept and the summary says how many were kept. It processes 20 players per frame.
- **Referees / Coaches** share the NPC store (`getRefereeManager().userCreated`), so they are split by
  `identity.npcType`. Hidden NPCs are never touched.
- **Custom Difficulties** removes only `custom` gameplay modifiers. If casual play was set to a custom
  difficulty, it goes back to Medium.
- **Logos / Stadiums / Match Types** use the stock Reset Academy functions: `setToDefault` plus a
  datastore save, and `clearUserCreatedMatchTypes`. The busy screen waits for `profileSaveInProgress`
  and both datastores' `isBusy` before it closes, and stays up for at least 1.5 s.
- Casual home/away teams that pointed at deleted clubs are reset by stock `AcademyState.exit`
  (`verifySavedTeams`) when you leave the screen.
- If a step throws an error, it's skipped and the summary names it ("Could not clear: ...").
- Text is English. Stock localisation keys are used where they exist (Players, Clubs, Leagues, ...).

## How it hooks in

- File: `app/academy/resetacademy_state.lua` (stock content plus the new code appended). Nothing else
  overrides it, and `homescreenstate_config` already imports it. The stock `ResetAcademyState` (only
  reachable in non-retail builds) still works.
- `homescreen_state.lua` belongs to allow-exit-any-menu-tab, so `HomeScreenState.update` is wrapped,
  not overridden. `Class(name)` reuses any existing `_G._CLASSES[name]` table. This file is imported
  before `homescreen_state` runs `Class("HomeScreenState")`, so it puts a `__newindex` trap on that
  entry and wraps `update` when it is defined. If the class already exists, it wraps `update` directly.
  The hook runs inside `pcall`, so if it fails the stock home screen keeps working.
- The menu runs inside `AcademyState`
  (`changeState(AcademyState(), ..., {nextState = ClearAcademyDataState})`), the same route the
  Academy tiles use. Backing out goes through `AcademyState`'s normal return to the home screen.

## Status

Working in game (2026-10-26): Y opens the menu from the Academy row, created data is cleared,
edited official players are reset (tier-1 Zac Lomax 99 back to stock), and edited official clubs
are reset (Dolphins lineup).

- `clearacademy_debug.txt` (game folder) always gets real errors with a traceback. Set
  `ClearAcademyDebug = true` for verbose tracing: player/club dumps when the menu opens, Y input,
  and each reset.
- In-game pitfalls found while building: front-end classes live in `_G.TEMP_CLASSES`, not
  `_G._CLASSES`, so `AcademyState` comes from the Academy row tile's `stateFactory`.
  `playerManager:containsUserCreatedVersionOfPlayer` is nil in retail. Tier-1 player edits live in the
  custom-licensed store, and `resetCustomLicensedPlayer` is run on every tier-1 player.
