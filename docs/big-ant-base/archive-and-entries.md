# The content archive

## Blobset

All game content is in one archive: `data/data-0.blobset.pc` (the index) plus one blob file per entry under
`data/<xx>/<hash>` in the Steam install. The index is a table of entries; each entry is one logical file
(a texture, a model, a sound bank) or one **bundle** of many files.

- **An entry is identified by a hash**: `FNV-1a 64` of its lowercased logical path, e.g.
  `characters/uniforms/textures/m_top_<name>_col_1.texture`, `sound/<bank>.bnk`, `mempacks/lua.mempack.retail`.
  The engine lowercases paths before hashing and looks entries up by hash, so the table order doesn't matter.
- **Entry positions are not stable.** A game update that adds files shifts every later entry (1.0.5933 moved
  everything from 34486 on: the script bundle went 39959 → 40053). Our tools therefore never store positions:
  [tools/entries.py](../../tools/entries.py) names the entries we use (`scripts`, `gamedata`, `licenseddata`,
  `careerdata`, `xamls`, `fonts`, `crowd-textureinfo`, `crowd-anim-bank`, `global-texsrc`, ...) and resolves them
  by hash. Older notes write 1.0.5887 positions as `v5887:N`.
- **New entries can be appended.** Appending an entry with the right hash works in game (confirmed with a test
  sponsor texture, then hundreds of kit, crowd, logo and sound entries). This is how new art is added without
  replacing anything ([tools/add_entries.py](../../tools/add_entries.py)).
- A Steam "verify files" keeps appended blob files on disk but drops their index records; they have to be
  re-added in order.

## Bundles (M3MP mempacks)

Scripts and data ship as M3MP bundles: one entry holding many files, compressed in chunks.

| Name | Logical path | Contents |
|---|---|---|
| `scripts` | `mempacks/lua.mempack.retail` | every `.lua` (LuaJIT bytecode) and `.flow` script |
| `gamedata` | | `defaultdata_leagues`, `_npcs`, `_stadiums`, supporters, match types, per-club `.clubdata` exports |
| `licenseddata` | | `defaultdata_clubs`, `defaultdata_players` |
| `careerdata` | | `career/career_*`: league structure, draws, career club settings, career tuning |
| `xamls` | | NoesisGUI `.xaml` views, styles and themes |
| `fonts` | | Noesis fonts |

Files inside a bundle are replaced whole. [tools/build.py](../../tools/build.py) rebuilds a bundle from a stock
extraction plus every mod's files, self-verifies it, and [tools/pack.py](../../tools/pack.py) installs it with a
per-entry backup.

## Textures and models

- Textures are `.texture` entries: a small header plus a DDS (BC1/BC3/BC7 or raw BGRA) with mips. Some are
  multi-texture TXPK packs (e.g. pitch line numbers). Character textures must also be listed in
  `characters/player/global.texsrc` or they render black.
- Models (`.model`) are Big Ant's own format: self-relative sections, several LODs, packed vertices. Kit and crowd
  meshes are decoded in [tools/bigant_mesh.py](../../tools/bigant_mesh.py) and `mods/crowd-flags/build_flags.py`.
- UI images referenced by XAML as `Images/x.png` resolve to `noesis/workspace/images/x.texture`.

## Updates

Steam build and manifest ids, how to roll back, and what each update changed are in
[../game-updates/](../game-updates/) and `tools/snapshot.py`. After an update, the stock bundles are re-extracted
(`install_revamp.py`'s `stock` step) and every mod is rebuilt against them.
