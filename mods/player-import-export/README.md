# player-import-export

Share players as JSON files, one at a time or in bulk, so OVR and skill edits can be passed
between saves and users. Script mod, entry **39959**.

- **Export Player**: in the Academy player view (the Identity / Appearance / Skills / Team /
  Sharing hub), **X / Square** shows "Export Player". It opens a Save dialog with the name
  `Player_<First>_<Surname>_<Id>.json` already filled in (it starts in `Documents`, then in the
  last folder used). It isn't shown on community (downloaded) previews.
- **Import Player** / **Import Players** / **Export Players**: three new rows at the bottom of
  the home screen's **Players** submenu.
  - *Import Player* takes a file with one player. A bulk file with more than one is refused
    with a hint to use Import Players.
  - *Import Players* takes a bulk file, or a single-player file.
  - *Export Players* has two buttons with counts: **Edited & Created Players** and
    **All Players**. It saves `Players_<Edited|All>_<count>_<date>.json`.

Clubs and lineups are never touched. A new player comes in as a free agent.

## Teams (export only)

- **Export Team**: on a club's hub (Identity / Uniforms / Lineups... tiles, e.g. Academy
  **Clubs > Club Manager**), **X / Square** shows "Export Team". It saves
  `Team_<Full_Name>_<Id>.json`. It only shows on the hub itself (the kit list uses X for
  Delete) and not on community previews.
- **Export Teams**: a new row at the bottom of the home screen's **Clubs** submenu, with three
  buttons and counts:
  - **Created & Edited Teams**: Academy-made (and downloaded) clubs, plus official clubs whose
    identity, emblem, grounds, kit list, roster or lineups differ from the stock copy
    (`clubManager.onDiscDatabase`).
  - **Base Game Teams**: every on-disc club, as it is now (edits included).
  - **All Teams**: both, once each.

  It saves `Teams_<Created|BaseGame|All>_<count>_<date>.json`. Teams are read 3 a frame, then
  their players 40 a frame, under a busy screen.

There's no team import yet. The format is versioned so one can be added.

```json
{
  "format": "RL26TeamExport",
  "version": 1,
  "game": "Rugby League 26",
  "exportedAt": "2026-10-28T03:12:45Z",
  "team": {
    "id": 1, "name": "Brisbane Broncos", "sex": "Male", "baseGame": true, "edited": false,
    "identity": { "fullName": "...", "nickname": "Broncos", "hudName": "BRI", "clubType": 0,
                  "primaryRGBColour": { "r": 98, "g": 0, "b": 51 }, "colourSet": 4, "...": "..." },
    "emblem": { "icon": "nrl_broncos" },
    "homeGrounds": [ { "stadium": 12, "customName": "...", "label": "Suncorp Stadium", "...": "..." } ],
    "uniforms": [ { "name": "HOME", "hidden": false, "options": { "uniformTop": 105, "...": "..." } } ],
    "uniformDefaults": { "Home": 1, "Away": 2, "...": 1 },
    "coachId": 4,
    "roster": [ 339, 341 ],
    "lineups": [ { "category": "LeagueMatch", "players": [ 339, 341 ], "captain": 339, "goalKicker": 341 } ]
  },
  "playerCount": 2,
  "players": [ { "id": 339, "name": "Zac Lomax", "...": "same as a player export" } ]
}
```

A bulk file uses `"format": "RL26TeamsExport"`, `count` and `"teams": [ ... ]`. Players in more
than one team (e.g. Origin and their club) are written once. `players` has every player in a
roster or lineup, in the player export's format, so a file stands on its own.

| Section | Source |
|---|---|
| identity | `identitymap` `ClubIdentity` (strings, numbers, bools; array fields like feeder clubs are left out), the three RGB colours, `colourSet`, `showUniformEmblemDecals` |
| emblem | `identity.decalIdOrIcon`: `icon` (stock badge name) or `decalId` + `customLogo` |
| homeGrounds | `identity:getGround(1..groundCount)` with `ClubHomeGroundInfo`'s fields, plus a readable `label` |
| uniforms | `club:getUniform(i)`: name, hidden, nines, and `config` read with `assetmap.options.team` (saved guid/slider options, except `version` and `sex`) |
| uniformDefaults | `club:getDefaultUniformIndex(category)` for each `CClubUniformCategory` except Nines (like the stock Set Defaults menu) |
| roster / lineups | `club:getPlayerIdAt`, `club:getLineup(i)` (only `CClubLineup.getLineupSize(category)` slots are read, see clear-academy-data), captain / goal kicker / playmaker |

A logo made in the Logo editor lives in the local decal store, so only its id is written. The
export summary says how many teams have one.

## What's in a file

```json
{
  "format": "RL26PlayerExport",
  "version": 1,
  "game": "Rugby League 26",
  "exportedAt": "2026-10-27T03:12:45Z",
  "player": {
    "id": 339, "name": "Zac Lomax", "sex": "Male", "baseGame": true, "tier1": true, "overall": 85,
    "identity":   { "firstname": "Zac", "surname": "Lomax", "birthYear": 1999, "...": "..." },
    "attributes": { "height": 190, "strength": 80, "perk": 3, "...": "..." },
    "skills":     { "tackle": 75, "placeKick": 88, "...": "..." },
    "appearance": { "head": 339, "hairTop": 12, "nose_height": 0.501960814, "...": "..." }
  }
}
```

A bulk file uses `"format": "RL26PlayersExport"`, a `count` and a `"players": [ ... ]` list of
the same player objects. `overall` and `name` are only for people reading the file. The
importer ignores them.

The field lists come from the game's own design tables, read when the game runs. Edits to those
tables by other mods are picked up too.

| Section | Source | Read / written with |
|---|---|---|
| identity | `identitymap.Data[1].PlayerIdentity`, except `sex` and `photogrammetryStatus` | `player.identity:getOption/setOption` |
| attributes | `attributemap.PlayerAttributesDoNotCountTowardsBudget` + `...CountTowardsBudget` | `player.attributes` |
| skills | `attributemap.PlayerSkills` | `player.skills` |
| appearance | `assetmap.options.player`: saved `guid`/`slider` options, except `version`, `sex`, `ugcHead`, `headUuid` | `player.visual` |

`ugcHead` / `headUuid` (an imported face photo) are left out because the photo lives in the
local image store and doesn't exist on another machine. Career match statistics aren't exported.

## Import rules

Every entry is checked before anything changes, then a confirmation lists what will be updated
and added, plus the entries that will be skipped and why. Existing players are only overwritten
after **Yes** (No is the default).

- **Which player gets updated:**
  1. If the entry's `id` is a base game id here, it's the same person (same sex, and the same
     name, stock or edited, or the same date of birth), so that player is updated. Mods that add
     players can give the same id to different people, so the id alone isn't enough.
  2. A `baseGame` entry whose id doesn't match is looked up by name (`onDisc:getIdFromName`).
  3. Otherwise, an Academy-made player with the same name, date of birth and sex is updated, so
     importing the same file twice doesn't make duplicates. Downloaded read-only players are
     skipped here.
  4. Otherwise the entry is added as a new player.
- **How it's written** (mirrors `PlayerViewState`):
  - Official players are edited through `userCreated:editPlayer`. Licensed non-tier-1 players
    first get `editOrCreateUserCreatedVersionOfPlayer`.
  - Tier-1 (scanned) players are stored with `saveCustomLicensed`.
  - New players use `playergenerator.bogStandardPlayerWithEthnicity` + `userCreated:addPlayer`.
  - The profile is saved with `profileSaveFrontEndData`.
- **Scanned likenesses stay where they are.** A tier-1 player's appearance is locked in the
  stock game, so it's never changed. A tier-1 export added as a *new* player only takes height,
  weight and fitness from the appearance section, because the stock game never copies a scanned
  likeness (no "Copy Appearance" for tier-1 players).
- **Appearance items from mods the importer doesn't have are dropped.** The options that pick
  a model (`head`, `body`, `hair`, `hairTop`, `hairSide`, `hairSide2`, `beard`, `moustache`,
  `chinhair`, `sideburns`, `helmet`, `shoes`, `sockHeight`, `topType`, `eyeSocketTint_type`)
  are looked up in the importing game's live `assetmap.AssetMapItems`, which includes
  whatever mods it has installed. `head` is looked up in `tier1head`, and 0 means the generic
  face. A value that isn't found is left out, so that part keeps the player's current or
  default look, because a missing head asset (e.g. its `.hjoffsets`) aborts the game. The
  confirmation and summary say how many players this affected, and the log lists each item.
  Scanned players don't count, because their look is never copied anyway. Checked against a
  4,060-player export from this setup: every stock value is in its list. The only misses are
  mod-added scanned heads (rll4-legacy-players, 10002-13824, plus 1448/1543/1742/2908/2916)
  and six hair values, all on tier-1 players.
- Example: Johnathan Thurston (RLL4 import, id 3982, `tier1`, head 10208). In a game with
  rll4-legacy-players he updates his own record. Without it, id 3982 and his name aren't in
  the game, so he's added as a new free agent. He keeps his identity, attributes and skills,
  and takes only height, weight and fitness from his appearance, on a default face.
- `sex` is fixed when a player is created and is never changed on an update. An entry whose sex
  doesn't match the player it would update is added as a new player instead.
- **Already up to date**: if the file matches the player's current values, nothing is written.
  This stops an All Players re-import from filling the Academy database with copies.
- A full Academy player database (`userCreated.canCreateCount == 0`) stops new players and new
  official-player edits. That entry is reported as not imported.

### Error checking

| Problem | Result |
|---|---|
| File can't be read, is empty or is over 128 MB | Message, nothing changed |
| Not valid JSON | Message with line and column, nothing changed |
| Not this mod's format, no `version`, or a newer `version` | Message, nothing changed |
| No players, or more than 10,000 | Message, nothing changed |
| An entry isn't an object, has no `identity`/`attributes`/`skills`, a bad `sex`, a blank surname, a wrong type (text for a number, a fraction for a whole-number field, `null`), an attribute or skill out of its design range (e.g. `skills.tackle` 120), text too long or with control characters, a non-finite number | That entry is skipped with the reason, e.g. `Player 3 (John Smith): skills.tackle must be from 0 to 99 (got 120)` |
| An identity number out of `identitymap`'s range (e.g. `shirtNumber` 150) | That one field is left out and logged. The rest is imported, because those ranges are editor limits that stock data doesn't always keep to |
| An appearance item that isn't installed in this game | That option is left out. The rest is imported. The confirmation and summary give a count, and the log lists each item |
| A field the game refuses when it's set | The rest of the player is imported. The field is listed in the log |
| Unknown keys | Ignored (so files from newer versions with extra fields still load) |

Up to 6 problems are shown on screen. Every one is written to `playertransfer_debug.txt` in the
game folder.

## How it hooks in

| File | Change |
|---|---|
| `app/player/player_viewstate_hub_state.lua` | Stock content, plus: the JSON codec, field specs, validation, matching, import/export, the X prompt (`PlayerViewHubState.update`/`exit`), `AcademyPlayerImportState` and `AcademyPlayerExportAllState`. Nothing else overrides this file, and `player_view_state` and `npc_view_state` already import it. |
| `app/club/club_view_state.lua` | Stock content, plus the team export: field specs, `TeamTransfer.serialiseTeam`, the export lists, the X prompt (wraps `ClubViewState.update`/`exit`, because `club_viewstate_hub_state.lua` is owned by copy-academy-jerseys) and `AcademyTeamExportAllState`. It uses the codec, dialog and busy helpers from the player file through `PlayerTransfer.shared`. Nothing else overrides this file. |
| `app/noesis/homescreen/nvm_homescreen.lua` | Stock content, plus a block at the end that adds the three rows to the Players tile's `subMenu` and Export Teams to the Clubs tile's. `homescreen_state` imports `homescreenstate_config` (owned by coach-editor) right before this file, so the config is fully loaded and can be imported without a cycle. `createFirstPageTiles()` returns the shared tile tables, which the home screen deep-clones on each visit, so adding the rows once is enough. |

- The rows run inside `AcademyState` through `stateData.nextState`, like the stock rows, so
  backing out returns to the home screen.
- Export Player is a button prompt rather than a hub tile, because the hub only draws the tiles
  that have a `ButtonCollection[n]` slot in `paacademyhubview.xaml`, and storm-celebration-viewer
  already owns that XAML and the tiles file.
- **File dialog**: `native.showFileDialog(filter, isSave, CLuaDialogBoxConfig)`. It blocks while
  open and can pre-fill the file name and folder. It's registered in the retail exe (the worker
  turns `|` in the filter into NULs), but the stock retail UI never calls it. If it's missing or
  errors, the mod falls back to the async `openFileDialogTask` that the retail custom-face import
  uses, which has no pre-filled name. A name typed without an extension gets `.json`. Set
  `PlayerTransferUseBlockingDialog = false` to always use the async task.
- **Files** are written and read with `io.open`, with `engine:getFileSystem():fopen` as a fallback.
- **Edited & Created** = every `userCreated` entry (Academy players plus non-tier-1 official
  edits), plus tier-1 players whose live identity, attributes or skills differ from the on-disc
  copy (their edits live in the native custom-licensed store, see clear-academy-data).
- Bulk export writes 40 players a frame and bulk import applies 12 a frame, under a busy screen.
  Offline timing: 4,000 players ≈ 28 MB, about 1.5 s to parse (one frame, after the busy screen
  has drawn).

## Tests

`python mods\player-import-export\tests\run_tests.py` compiles the three files with the toolchain's
LuaJIT. It then loads the player and club files with stubbed game objects and runs 135 checks: the JSON
round trip and every rejection case, validation messages, file parsing, id/name/DOB matching,
tier-1, licensed and new-player writes, dedupe, a full database, partial writes, items that
aren't installed (including the Thurston case), the export lists, and the team export (identity,
colours, emblem, grounds, kits and their options, defaults, roster, lineups, the embedded
players, and the created / edited / base game lists). build.py skips `*.py`.

## Status

Built 2026-10-27, dry-run build OK, offline tests pass. **Not yet tested in game.** Things to
confirm first:

- The blocking `native.showFileDialog` opens (and pre-fills the name), and the async fallback
  works if it doesn't.
- An exported tier-1 player re-imports onto itself as "Already up to date", and an edited one
  updates through `saveCustomLicensed`.
- New players show up in All Players as free agents, with their appearance.
- Teams (added 2026-10-28): X on a club hub saves a file, and the Clubs > Export Teams counts
  look right (an edited official club shows up in Created & Edited). Unverified native reads to
  check in a file: colours (`identity.primaryRGBColour.r/g/b`), `getGround` fields, kit
  `config:getOption`, `getDefaultUniformIndex`, lineup `category` / special roles. Any read that
  fails is just left out of the file.
- `playertransfer_debug.txt` stays empty apart from skipped-entry lines. Set
  `PlayerTransferDebug = true` for verbose tracing.
