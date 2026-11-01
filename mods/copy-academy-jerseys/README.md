# copy-academy-jerseys

Adds **COPY ACADEMY UNIFORM** to an Academy club's jersey list (under "New Licensed Uniform").
It lists every club of the same sex (stock official, Academy-edited official, user-created
and downloaded/FanHub). Pick a club, then a jersey, and a copy is added to the club you're
editing as "Jersey N".

- Uses a plain option menu, not the native club picker grid. That grid's search options
  are tri-state and can't show on-disc and user clubs together; see the replaced
  `allow-fanhub-jersey-copy` mod in `_disabled_mods/`.
- Clubs come from `CClubManager:getAllClubsWithSex(true, true, sex, dlcManager, true)`
  (found by disassembly: it returns an array of CClub; the meaning of the bool flags is
  not confirmed). If that call fails, it falls back to the on-disc clubs only and prints
  a message.
- Each club is re-read via `getClub(id)` (the merged manager), so edited official clubs
  show their edited jerseys.
- The copied jersey keeps the source's `uniformEditable` flag. The stock licensed copy
  forces it to 0.

## FanHub: copy a jersey into your club

Viewing a club in FanHub/community now has a **Uniforms** tile (in the empty slot under
Sharing). It opens the stock jersey screen in read-only mode. Selecting a jersey lists
your clubs of the same sex; picking one adds the jersey to that club as "Jersey N".
Official targets get their Academy-edited version (`editOrCreateUserCreatedVersionOfClub` +
`saveCustomLicensed`), as editing them in Academy does. The profile is saved by the FanHub
club view's dirty-save helper when you leave the view.

**Browser shortcut:** in the FanHub team browser, **X (Uniforms)** on a highlighted team
goes the same way as View (including the player fetch), but the club hub opens the Uniforms
tile by itself (`clubViewInfo.autoOpenTileKey`). When you back out of Uniforms the hub
closes itself (`autoCloseOnReturn`), so you land back in the browser.

**Logos/decals:** after you pick the target club, the FanHub club's decals are downloaded
through the stock decal downloader (`addDecalToDownloadList` + `AcademyCommunityBaseDownloadSubState`,
the same as "Download with decals", including its prompts and profile save). The jersey is then
copied from a temporary `CClub` copy with `replaceDecalIdsWithLocalIds()` applied, so its decal
ids point at your local copies. All of the club's decals are fetched, not only the ones this jersey
uses, and they count against your decal storage. If the download is cancelled, nothing is copied.

Files: `app/academy/academy_club_jersey_state.lua` (new states; `CopyAcademy` / `CopyToClub`
factories; passes `inCommunity`), `app/academy/academy_club_jerseystate_list_state.lua`
(menu entry; FanHub jerseys selectable), `app/academy/academy_club_viewstate_tiles.lua`
(FanHub Uniforms tile), `app/academy/academy_communitystate_clubstate_list_state.lua` (X
shortcut), `app/academy/academy_communitystate_clubstate_viewstate_view_state.lua` (passes the
shortcut flag), `app/club/club_viewstate_hub_state.lua` (auto-open/auto-close tile).

## Export a jersey (LB)

In any club's Uniforms list (your clubs, official clubs, or a FanHub club's read-only list),
**LB (Export Jersey)** saves the highlighted jersey's design info to
`Documents\RL26Jersey_<club>_<kit>.json`: club, kit name, sex, and the design items (guid and
item name) for the top, shorts and socks.

The pixels come from a RenderDoc capture of the same screen:

1. `python tools/renderdoc_kit.py launch`: starts the game under RenderDoc. Highlight the
   jersey, press LB, then F12 to capture.
2. `python tools/renderdoc_kit.py extract`: saves the composited colour maps (top 4096x2048,
   shorts 2048x2048, socks 1024x1024, decals included, no number or name) next to the JSON.
3. `python tools/fanhub_kit_import.py <json> --name <name> --club <id> --kit-name "NAME"`: makes
   a [rll4-legacy-kits](../rll4-legacy-kits/README.md) custom kit, with `templates` that keep the
   design's own models so the UVs match.

Reading the textures back from Lua was tried and dropped. `CCharacterVisual:getTexture("top",
"top_wrinkle_SS", "col_map")` does return the composited texture, but
`CRenderUtils.textureToDataBuffer` gave zeros or stale data for every texture, including stock
ones. That happened both from the menu update and from the frame setup.

## KIT LIBRARY

A club holds at most 20 kits: the native club object stores them inline (`+0x408` count,
`+0x40c` max = 20, 0x324 bytes each, exe 1.0.5933), so the cap can't be raised. rll4-legacy-kits rows
marked `"library": true` stay out of the club's slots. They go into `KitLibrary`, generated into
`intermediatelua/data/jigglyjointsconfig.lua` as `[club id] = { { name, copyOf, set } }`.

A club's Uniforms list shows **KIT LIBRARY (n)** when you can edit the club and it has library kits.
Picking a kit adds it to the club, or, when the club is full, asks which kit it replaces. The new kit is
a copy of the club's `copyOf` kit with the entry's options (design guids, number colour), built on a
scratch `CUniformSerialisable`. It's then an ordinary club kit, saved with the club, so Play Now,
competitions, career and the crowd use it.

Library kits can't be offered straight from the match setup: Play Now's team select is a native
widget (`ESimpleClubAndJerseys`) that steps through the club's own kits and builds the match club by
kit index. crowd-team-kits also puts library kits in their club's crowd list.

## FANGEAR LIBRARY

When crowd-fangear is installed, a club's Uniforms list also shows **FANGEAR LIBRARY (n)**: the fan tees,
polos and scarves its crowd wears (`FangearLibrary` in `intermediatelua/crowd/crowd_items.lua`), grouped by
item, each marked ON or OFF. Picking a row switches it. The switched-off designs are saved to
`rl26_revamp_fangear.txt` in the game folder, which crowd-team-kits reads at the next match load. The row
is there for every club with fangear, editable or not, and not in the community browser. See
`mods/crowd-fangear/README.md`.
