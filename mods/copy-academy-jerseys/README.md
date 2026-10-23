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
