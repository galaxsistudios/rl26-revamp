# rll4-legacy-players

Adds the Rugby League Live 4 players who had a real face scan in RLL4 but aren't in RL26
(184 of them: Paul Gallen, Boyd Cordner, Andrew Fifita, Gareth Widdop, ...). They become
free agents with their RLL4 ratings, roles, birth dates, height and weight, and their
RLL4 face scan converted to an RL26 head.

Everything is read from **your installed copy of RLL4** (found through Steam, or pass
`--rll4 <folder>` / set `RLL4_DIR`), so the mod ships no RLL4 content. RLL4's kits are
brought over by [rll4-legacy-kits](../rll4-legacy-kits/) (`build_kits.py add-rll4`).

## How it works

[build.py](build.py)'s docstring has the details.

- **Who:** an RLL4 player with a face scan (a head whose material is `<first><last>_mat`)
  that RL26 doesn't have: no RL26 player with the same name and birth year, or the same
  surname and birth date with a similar first name (Matt / Matthew). The list is
  [players.json](players.json).
- **Ids:** players take the next ids after the highest stock one (3902-4078). The game aborts at
  boot (on the Big Ant logo) if a player id is far beyond the number of records: tested with one
  extra record, id 3950 boots and 3999 / 4090 / 10002 crash, while 177 extra records at 3902-4078
  boot. A future official roster update that adds ids from 3902 up would clash with these.
  The heads keep their own guid, 10000 + the RLL4 id (that's also in their asset names); head
  guids have no such limit.
- **Free agents:** club membership is stored in each club's roster, not on the player, so a
  player on no roster is a free agent.
- **Faces:** all RLL4 scans share one mesh layout, and all RL26 scans share one UV layout,
  so the two templates are matched once (`prepare`). For each player a stock RL26 head
  with the closest skin colour is the donor. Its skin is reshaped to the RLL4 scan (the
  RL26 average head plus the player's difference from the RLL4 average; RLL4 heads are
  about 8% larger, so the difference is scaled down). Near the neck seam it blends back to
  the donor's own shape so it still meets the body. Eyes, eyelashes, mouth and the
  lower-detail LODs move with the face. The donor's facial-animation blendshapes, normal
  and material maps, and its body skin and visual are kept. The colour texture is the
  donor's with every skin texel replaced by the scan's colour.
- **Hair:** the scans have their hair painted on, so the new heads have no hair meshes
  (hair, beard and hair-cap options are cleared in their visuals).

## Pieces

| Part | Where | Installed by |
|---|---|---|
| 12 entries per head: `characters/heads/models/rll4_<name>_<id>/...modelcomponent`, `.blendshapes`, `characters/helperjoints/rll4_<name>_<id>.hjoffsets` (the donor's face-rig offsets; the game aborts loading a head without one), `characters/heads/textures/rll4_<name>_<id>_{col,nrm,mat}_{1,2,3}.texture` | appended blobset entries | `build.py install` |
| the 9 head textures registered in `characters/player/global.texsrc` (entry 31558) | replaced entry (appended to the live table) | `build.py texsrc` |
| head items in `ItemMaps.tier1head` + `tier1head_textures_{col,mat,nrm}` | `src/script-game/design/characters/texturedefinitions.lua` (generated: stock file + a block) | `tools/build.py` (entry 39959) |
| new player records + visuals | `defaultdata/defaultdata_players/<id>_<surname>.json` + `visuals/` (generated; `"new": true` records are appended by `tools/data_mods.py`) | `tools/build.py` (entry 39957) |

## Build and install (game closed)

```powershell
python mods\rll4-legacy-players\build.py select      # -> players.json
python mods\rll4-legacy-players\build.py prepare     # template matching, cached in _build\rll4-legacy-players
python mods\rll4-legacy-players\build.py heads       # ~15 min; previews in _build\rll4-legacy-players\<head>\preview.png
python mods\rll4-legacy-players\build.py sheet       # _build\rll4-legacy-players\sheet.png
python mods\rll4-legacy-players\build.py generate    # player JSONs + visuals + texturedefinitions.lua

python mods\rll4-legacy-players\build.py install --confirm   # 177 x 12 appended entries
python mods\rll4-legacy-players\build.py texsrc --confirm    # AFTER rll4-legacy-kits' texsrc (which rebuilds 31558 from stock)
# then rebuild 39959 and 39957 (39957 from a STOCK extraction, it's shared with the kit/club mods):
python tools\pack.py restore --entry scripts
python tools\build.py full --confirm
python tools\pack.py restore --entry licenseddata
python tools\build.py full --list manifests\licenseddata.xml --extracted <stock 39957> --out _build\licenseddata.m3mp --confirm
```

Undo: remove this folder's generated `defaultdata` and `src`, rebuild 39959 and 39957, re-run the
other mods' texsrc steps, and `add_entries.py remove-all` (which also removes every other appended
entry, so re-add the other mods' entries afterwards).

## Test

- Academy > players, or any player search with the free-agent filter, should list the imported
  players with their club shown as Free Agent.
- Put one in a team and check the face in a match and in the player model view: eyes in their
  sockets, mouth and teeth when talking or celebrating, and the neck seam against the body.

## Known gaps

- Only players RLL4 scanned. The other ~2,700 RLL4-only players aren't imported (by choice, and
  RLL4's appearance sliders are stored under a hash that hasn't been worked out, so their looks
  couldn't be carried over anyway).
- Birth countries use a mapping voted from players who are in both games, so it may be wrong for a
  few smaller nations.
- Long hair is painted on, so it looks cropped.
- The normal and material maps are the donor's, so fine skin detail (pores, wrinkles) is the
  donor's.
- Ratings are RLL4's 2017 values; ages come from the real birth dates, so many players are now
  in their thirties.
