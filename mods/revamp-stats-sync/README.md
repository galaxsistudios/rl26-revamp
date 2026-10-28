# revamp-stats-sync

Keeps the base game players and clubs up to date with the RL26 Revamped stats repo,
[galaxsistudios/rl26-revamped-stats](https://github.com/galaxsistudios/rl26-revamped-stats).
Script mod, entry **39959**. Needs **player-import-export**, whose JSON codec, player update
path and team field lists it reuses.

## What happens in game

1. The first time the home screen comes up in a session, the game fetches `version.json` in the
   background. That file holds, for each data file, its SHA-256, its chunk count, and each
   chunk's SHA-256 and size.
2. The game compares those with `rl26revamp_stats_state.txt` (the hashes it last applied, per
   file and per chunk). Only **chunks whose hash changed** are needed. Editing a few players
   changes one or two 40-player chunks, so the download is a few hundred KB, not the whole
   file. If any chunk is needed, a popup appears once the player is on the home screen with
   nothing else open. It says **"New RL26 Revamped data is available"** and lists the players
   / team lists with their update dates and the download size. It has **Download** and **Not
   now** buttons. Not now (or B) downloads nothing, and the popup appears again next session.
3. On Download, a loading screen (spinner and status line) shows the progress. First
   `Downloading players: 37 of 102 / 6.1 of 16.8 MB`, and so on, as the changed chunks come in,
   six at a time (one at a time took about 1.4 s each). A chunk that fails is fetched up to two
   more times before its part is dropped. Then it shows `Updating players: 1200 of 4060` while
   the downloaded entries are applied, **players** first, then **teams**, and `Saving...`. The
   profile is saved after each, and a notification shows how many were updated. If any **club**
   changed, a message (OK button) asks the player to **restart the game before playing a match**
   instead. In the chaos test, Play Now crashed in the same session as the restore
   (`lobby_sideinfo.lua: bad argument #1 to 'set' (CPlayer expected, got nil)`: the lineup's
   captain wasn't in the match screen's cached squad). After a restart the same save worked.

The chunks (`players/NNN.json`, `teams/NNN.json`) hold 40 records each and only what the sync
applies. Teams leave out kit designs and home grounds (up to 155 KB a club). Tier-1 players
keep only their hair/headgear appearance options. The version hash in `version.json` covers
`players.json` plus every chunk hash, so a change in what the chunks carry counts as a new
version. A full download is 102 player chunks
(16.8 MB) and 6 team chunks (0.3 MB). The full `players.json` / `teams.json` stay in the repo
as the source of truth.

The loading screen is `base.ui.busy.busy_layout`, drawn from `HomeScreenMixIn.renderAfterState`
(`RenderOrder` 1000.5, just above `AlertMixIn`'s 1000) on top of a blocking alert with no
options. The alert locks input during the download and is what shows if the busy layout can't
be made. An alert's text can't change once it's open, but the busy layout's status can.

### Settings > Sync Player & Team Data

A **Sync Player & Team Data** row in Settings runs the same flow by hand, as a **repair**. It
ignores what was applied before, so everything is downloaded (about 18 s) and re-applied, and
any base game player or club that drifted from the repo is put back. The prompt says so, and
the loading screen, apply and restart message are the same as the automatic sync. If the data
can't be fetched, a notification says so. It works even with `stats_sync = false`.

How it's wired: the row is a sub-item of the stock Settings tile, whose items are run by
`SettingsState` as `stateData.nextState`. On the mixin's first front-end frame,
`statsSyncAddSettingsRow` appends it to the shared Settings sub-menu. If main-menu-revamp has
already turned that sub-menu into `SettingsItem1..12` boxes, it adds the next free
`SettingsItemN` box instead. `RevampStatsSyncState` calls `uiServices:revampStatsSyncRequest()`
(a convenience function from this mixin) and ends at once, so `SettingsState` returns to the
home screen, where the forced sync (`sync.force`) asks, downloads and applies.

Only base game data is changed:

- **Players:** entries marked `baseGame` that match an on-disc player, by id plus name or date
  of birth (the same matching Import Players uses). Identical players are skipped. Scanned
  (tier-1) players get their identity, attributes and skills, plus **hair and headgear only**:
  `helmet`, `headwearColour1-4`, `headStrappingColour1-2`, `hair`, `hairTop`, `hairSide`,
  `hairSide2`, `hairTexture_cap`, `hairTipsOption` and `hairColour1-2`
  (`StatsSyncTier1Appearance`, the same list as `TIER1_APPEARANCE` in tools/stats_sync.py). A
  scanned player's head, hair and headwear meshes come from the scan (item `head + 1000`), but
  the headgear textures and colours, and the hair texture, come from these options. A scanned
  head with no `_headwear` mesh still shows no headgear, and a different hair shape needs the
  head in jesse-southwell-hair's `GenericHairHeads`. The rest of a scanned look is never
  changed. This works through player-import-export's `PlayerTransfer.tier1AppearanceFields`
  ("tier1Fields" mode), which the sync sets only while it applies players. Import Players
  still leaves scanned looks alone.
  Other official players also get their appearance, and are stored as the Academy stores an
  edit to an official player. Nothing is added, and Academy-made players are left alone.
- **Teams:** official clubs only. Identity (names, HUD name, supporters...), colours, badge,
  coach, kit defaults, roster and lineups (with captain and goal kicker) are applied, then the
  club is saved with `saveCustomLicensed`, as the Academy editor does. Kit designs and home
  grounds are not touched. A player a team lists who isn't in this game is left out of the
  roster, and their lineup slot keeps its current player.

Everything is logged to `revampstats_debug.txt` in the game folder. The hashes last applied are
kept in `rl26revamp_stats_state.txt` next to it. Delete that file to apply the data again (for
example after resetting the Academy).

`stats_sync = false` in `rl26_revamp.ini` (game folder) turns the sync off.
`stats_parallel = N` (1 to 16, default 6) sets how many chunks download at once.

## How the download works

There's no Lua HTTP API, but the game's `native.CBasCommsTask` (used for every Big Ant server
call) takes a `urlOverride` in its config. With it set, the task requests `urlOverride ..
endpoint` with the given verb and skips the BAS sign-in check (exe 1.0.5887: config read at
0x140b1e754, request built at 0x140b1fc49). The two strings are concatenated as they are
(0x140dfd545), so the base URL needs its trailing `/`. The `"%s %s/%s"` at 0x140b20f48 is only
a log description. The sync reads the body with `getResponseBody()`, and uses `fillInfo()`
when there's no body string.

Things learned testing it in game (2026-10-28):

- A **27 MB response crashes the game**: it corrupts the native heap and aborts in the
  allocator (0x140e45bf7). Responses of about 256 KB are fine, hence the chunks. The mod never
  fetches a part whose `version.json` entry has no chunk count.
- Plain `http://` URLs fail at once. Only https works.
- A large response can come back with an error status but an intact body. The mod logs it and
  lets the JSON decoder decide whether the body is complete.

Lineup slots are written with `CClubLineup:replacePlayerAt(slot, id, carryRoles)` (0x140f09180).
The slot is 1-based and **not bounds-checked** (a lineup holds 19 ids), so the sync clamps it
to `CClubLineup.getLineupSize(category)`.

## Publishing new data

1. In game: **Players > Export Players > All Players**, and **Clubs > Export Teams > All Teams**
   (or Base Game Teams). Save both to Documents.
2. `python tools\stats_sync.py` rewrites `rl26-revamped-stats/players.json`, `teams.json`,
   their chunk folders and `version.json` from the newest exports. After editing
   `players.json` / `teams.json` by hand, run `python tools\stats_sync.py --version-only`
   instead, which rebuilds just the chunks and `version.json`.
3. Commit and push the stats repo, chunk folders included. Every player gets the update the
   next time they reach the home screen. raw.githubusercontent.com caches files for up to 5
   minutes.

## Tests

`python mods\revamp-stats-sync\tests\run_tests.py` runs the mod in LuaJIT on top of
player-import-export's test harness, with stubbed downloads, player manager and clubs. It
covers the full flow, the Download / Not now prompt, the loading screen's progress lines,
skipping unchanged parts, per-chunk deltas (only changed chunks fetched, the state file
upgraded from per-file hashes), waiting for the home screen, a failed download, chunk count
checks and the ini switch.

**Chaos test, 2026-10-28** (`_disabled_mods/zz-stats-chaos-test`, a throwaway copy of this
mod). It scrambled every official player (names reversed, every rating random, body shape)
and every official club (names, colours, badges, kit defaults, random cross-club rosters and
lineups, random captains). With the sync state deleted, a re-sync restored it in 20 s:
4,060 players and 219 clubs updated, 0 failed. Players were matched by date of birth because
their names were scrambled. A fresh export was then identical to the pre-chaos one for all
4,060 players and 218 of 219 clubs. The Dolphins' Nines captain stayed different: the repo's
captain (507) isn't in the Nines lineup, and the game won't make him captain. Huddersfield
and Tweed have the same quirk in the stock data.

Known limits:

- The automatic sync only acts on a **new version on GitHub**. It doesn't notice a save that
  drifted locally after an update (that's why the chaos test deleted the state file). Use
  **Settings > Sync Player & Team Data** (or delete `rl26revamp_stats_state.txt`) to repair
  one.
- Play-maker roles aren't exported or synced.

**Confirmed working in game 2026-10-28.** A full first-time sync (102 player + 6 team chunks,
17.9 MB, 6 at a time) downloaded in **18 s**; Download to finished took 25 s. The old one-at-a-time
35 MB layout took about 3 minutes. One run updated a club in game (the Dolphins' lineups, which
had drifted from the repo) and the next run found it unchanged, so club writes persist. A
player write hasn't been seen in game yet: the offline tests cover that path.
