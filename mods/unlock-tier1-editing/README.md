# unlock-tier1-editing

Opens Academy editing of scanned (tier-1) players and official clubs.

## Players

Stock locks the **Appearance** tile of every scanned player ("Tier1Likeness"). With this mod,
scanned players get Appearance with the face-related tabs removed:

| Tab | Scanned players |
|---|---|
| Body | Yes, without Head Size, Neck Type and Neck (they reshape the scan or open a seam at the neck). Height stays locked, as for every licensed player |
| Skin | No (the scanned face texture is baked, so a new skin tone wouldn't match it) |
| Head (face morphs) | No |
| Hair / Beard / Eyebrows | No (scanned heads use their own hair meshes) |
| Accessories: arm sleeves, compression shorts, arm / finger / leg strapping | Yes |
| Tattoos (neck, arms, legs) | Yes |
| Accessories: headgear, boots | Yes |

**Preferred roles** (primary, secondary, tertiary, in Skills) are editable for every official
player, scanned or not. Stock locked them whenever `player.isLicensed`; they now follow the same
permission as the Perk row next to them. Preferred hand and foot stay locked.

Copy Appearance stays hidden for scanned players (it would replace the face). Skills, Team and the
existing Reset (Y) work as before. Edits are saved the same way as stock skill edits on scanned
players: `PlayerViewState.exit` calls `saveCustomLicensed`.

### Headgear

Stock ignores the `helmet` option on scanned heads. The headWear slot always loads the scan's own
`head + 1000` mesh, and loads nothing if the scan has none. Only 159 of the 1,578 scanned heads have
one, so headgear couldn't be added or removed. The slot now honours the option:

- `helmet` 0: no headgear.
- The chosen item is the same kind as the scan's fitted mesh: the fitted mesh (as stock). Kinds:
  headgear (guids 1, 2, 100, 101, 120, 130), strapping (20-24), ribbons (200-212).
- Anything else: the item's generic mesh, as on a created player.

The kind of each fitted mesh comes from the stock data (the item that scan's player wears):
149 heads, 66 headgear / 75 ribbons / 8 strapping. Nine fitted heads have no stock wearer kind
(164, 627, 807, 945, 952, 1170, 1268, 1752, 3265) and always use generic meshes. Head 1170
(Chelsea Savill) has `helmet` 0 in stock, so her fitted mesh no longer shows by default.

Apart from head 1170, stock players look the same in matches: every other scanned player with a
fitted mesh wears an item of one kind, and no scanned player without one has a non-zero `helmet`.
`generate.py` checks both.

## Clubs

Official clubs lock **Identity** (full / short / nickname / abbreviated / HUD names, emblem,
emblem decal, commentary location and mascot names, supporters, primary and secondary colours,
and team-coaches' Coach row) and **Home Grounds** through `isOnDiscClub`. Both are now editable
in Academy > Clubs > Edit. Edits are saved by the stock `ClubViewState.exit`
(`saveCustomLicensed`, keyed on the club id).

Official kits stay locked. They're texture kits, and the jersey editor would open them in the
custom kit editor. Use **New Licensed Uniform** (or copy-academy-jerseys' Copy Academy Uniform) to
make an editable copy.

## How it works

Script overrides (entry 39959), all decompiled stock plus the marked changes:

- `app/academy/academy_player_editstate_view_state.lua`: `canEdit` no longer excludes tier-1
  players, and the Appearance tile's `lockedGetFn` is replaced (locked only when `canEdit` is false).
  The tile list comes from storm-celebration-viewer's `academy_player_viewstate_tiles.lua`, which this
  mod doesn't touch. The tile is found by its `stateFactory`.
- `app/academy/academy_player_viewstate_appearance_state.lua`: tier-1 players get
  `Tier1GroupList` / `Tier1FemaleGroupList`.
- `app/academy/academy_player_appearancestate_edit_groups.lua`: defines those lists.
- `app/player/player_attributes_aide.lua`: the three Preferred Role rows in `var_0_17` take the
  passed edit permission (`arg_30_0`) instead of `not player.isLicensed`.
- `app/academy/academy_club_edit_state.lua`: after `ClubViewState.enter`, clears
  `clubViewInfo.isOnDiscClub` when the club is editable (`unlockTier1WasOnDiscClub` records it).
  The flag is read lazily by the identity and home ground menus.
- jesse-southwell-hair's `design/characters/assetmap.lua` (whole-file override, so the headgear
  rule lives there): `FittedHeadwearKinds`, `var_0_headwearKind` and the headWear `filename` check.

`generate.py` rebuilds the `FittedHeadwearKinds` block from the stock player database
(`_backup/entry_39957.blob.bak`) and `assetmapitems.lua`. It would also write `helmet: 0` player JSONs
(entry 39957) for any scanned player whose stored headgear stock never drew. There are none today,
so the mod has no data files.

## Install (game closed)

```powershell
python mods\unlock-tier1-editing\generate.py   # only if the data or tier-1 heads change
python tools\pack.py restore --entry scripts
python tools\build.py full --confirm
```

Needs jesse-southwell-hair installed (it carries the headgear rule).

## Limits

- Not yet tested in game.
- Generic headgear meshes are shaped for generated heads. On a scan they may float or clip, and the
  scan's own hair can show through, because scanned hair meshes are fixed.
- Removing headgear from a player who wears it shows their scanned hair, which may be modelled to
  sit under headgear.
- Names, jersey number and commentary name stay locked for all licensed players (stock rule,
  separate from the tier-1 lock).
