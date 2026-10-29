# nrl-referee-2026-kits

Adds the 2026 NRL referee jerseys as three **new** referee kits: **NRL 2026 Orange**, **NRL 2026
Yellow** and **NRL 2026 Blue**. The stock referee kits (NRL 2025 green, orange and white, and the
others) stay as they are.

The jerseys are made by [resources/ref-jerseys/make_ref_jerseys.py](../../resources/ref-jerseys/make_ref_jerseys.py)
(layered PSDs + `top.png` in `resources/ref-jerseys/2026/<colour>/`): body colour, black yoke,
side panels, sleeves and collar, with the Classic, NRL Telstra Premiership, youi and Witzer
sponsors.

## Where they show up

Play Now → Match Settings → **Match Officials** → **Referee Jersey** (from
[choose-play-now-referee](../choose-play-now-referee/)). The three kits come after the 15 stock
ones. The stock automatic pick (Auto, career, competitions) is unchanged.

## Pieces

| Part | Where | Installed by |
|---|---|---|
| 6 textures `characters/uniforms/textures/m_top_referee_nrl_2026_<colour>_col_{1,2}` (4096x2048 / 2048x1024) | appended blobset entries | `install.py install` (install_revamp step `ref-kits`) |
| the same names in `characters/player/global.texsrc` | live entry + records appended | `install.py texsrc` (install_revamp step `texsrc`, after rll4-legacy-kits) |
| design items guid 62001-62003 in `uniformTop`, copies of the stock NRL 2025 orange referee top (guid 51, `top_vneck06_tucked`) with the new colTexture | `src/script-game/design/characters/realisticcolour.lua` (stock file + block) | `build.py` (scripts) |
| the kit list for the picker | `_G.MOD_EXTRA_REFEREE_KITS` (set by the same block) | |

There's no `EUmpireUniform` value for a new kit (a native enum), so a picked kit dresses the
officials in its base stock kit (`RefereeMale_NRL_Orange`: shorts, socks, number style) and then
sets every official's `uniformTop` to the new guid once `matchin.setupLobbyMatch` has finished.

`realisticcolour.lua` is used because assetmap imports it first, and no other mod owns it.
The block imports `assetmapitems` (which imports nothing) and adds the items before the native
asset map reads `ItemMaps`, the same window rll4-legacy-kits uses through `jigglyjointsconfig.lua`.

## Install (game closed)

```powershell
python resources\ref-jerseys\make_ref_jerseys.py          # only after changing the design
python mods\nrl-referee-2026-kits\install.py install --replace --confirm
python mods\nrl-referee-2026-kits\install.py texsrc --confirm
python tools\pack.py restore --entry scripts
python tools\build.py full --confirm
```

Status: installed 2026-10-29, not yet checked in game.
