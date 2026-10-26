# crowd-team-kits

Dresses the crowd in the jerseys and merch of the two teams that are playing, for every club, including the
2026 clubs. Before this mod, the 2026 clubs' fans wore generic clothing.

## Why the 2026 clubs had no colours

`rendering/crowd/crowd_rugby.lua` hands the native crowd the tags `"teamID" .. academyId` for home and away.
Each crowd clothing item (`intermediatelua/crowd/crowd_items.lua`) picks its texture from the variant with
that tag. The shipped data only has tags for the 2025-era club ids 1-109. The 2026 clubs are ids 118-183 and
the internationals are ids 204-219, so their fans got generic tops. For polos, caps, beanies and scarves the
native fallback is `homeDefault`/`awayDefault`. Those are red/yellow mask textures (red = primary, yellow =
secondary) that the engine tints with the club colours.

## The crowd has its own jersey textures

The crowd does **not** use the player uniform textures. It loads its own 1024² copies from
`crowd/characters/textures/<name>.texture`. Only the 2025 **home and away** jerseys have crowd copies (152
textures). There are none for 2026 kits, alternates, Indigenous and the like, or rll4-legacy-kits. If a team
variant names a texture that has no crowd copy, the engine aborts the match load (exception `0xC0000409`). The
crash dump showed `crowd/characters/textures/m_top_roosters_nrl_home_26_col.texture` on the stack.

## What it does

Overrides `intermediatelua/crowd/crowd_item_config.lua`, the module the crowd loads at every match
(`loadTemp`). It patches the shared `crowd_items` tables in place:

- **Jerseys** (`m_crowd_clothing_tshirt`, used by male and female fans): each club's list is built from its
  kits that have a crowd copy, plus those of the other seasons of the same club. A club's seasons form one
  *family*: `Brisbane Broncos 2025`, `Brisbane Broncos` and `GF Brisbane Broncos` are one family. Weights:
  - HOME ×3 and AWAY ×2. A 2026 club has no crowd jerseys of its own, so it uses the family's.
  - every other kit ×1

  The list holds up to 16 entries, the native `cols` capacity (`rugbyleague1.exe` 0xbb0ae9; one more is
  written through a null pointer). The game's own lists stop at 8, but 16 leaves room after home/away
  for older and legacy kits: every rll4-legacy-kits 2024/2023/2022 jersey makes it in.
- **Fallback:** a club still without jerseys or merch borrows its family's existing entry. The women's clubs
  get the men's crowd jerseys this way, as the shipped data already does for ids 32+. Clubs with nothing
  anywhere keep the native fallback: generic tops, and tinted polos, caps and scarves. That covers the
  internationals.
- `SPRINKLE_TINTED_POLOS` (off by default, **untested**): also adds the tinted default polos to clubs that
  have their own polo. If the engine only tints them on the fallback path, those fans wear raw red/yellow.

## Random Souths guy

Whoever is playing, a few fans somewhere in the crowd wear a South Sydney jersey. It can be any Souths jersey
the crowd has (2025, 2026, alternates, legacy kits), re-picked every match. The crowd can't be dressed fan by
fan, only through weights, so it works like this:

- A new top, `m_crowd_clothing_tshirt_southsguy`, uses the t-shirt model. Its `base` list (no team tags,
  so it shows up in any stand) holds `k` random Souths jerseys among 16 entries; the rest are the stock
  plain tees.
- It's added to the default male fans' tops (and the GF archetype's) with weight `b`. Tops weights are
  integers kept as a running **byte** total (`rugbyleague1.exe` 0xbb1ef9), so the shipped weights are
  rescaled to fill 255 around it, keeping their proportions.
- Odds per male fan = b/255 × k/16, so the floor is 1 in 4,080. `crowd_rugby.lua` (a copy of the stock file
  with two marked additions) passes the stadium node file to the config. `b` and `k` are then sized from
  that ground's node count, generated from the node files' header, for `SOUTHS_GUY_TARGET` (3) expected at
  a full house.

Expected at a **full** ground: ~3 at small and mid grounds, ~5.5 at Suncorp, ~8 at Accor, ~10 at Perth or
Wembley (the 1-in-4,080 floor). Real attendance is usually lower. Each match load appends the maths and the
crowd's actual potential attendance to `crowdteamkits_debug.txt` in the game folder, for recalibrating
`MALE_FAN_SHARE` or the target.

## Regenerating

`generate.py` writes the kit table between the `GENERATED` markers. It reads the **installed**
`defaultdata_clubs` (entry 39957), and checks each crowd texture against the live blobset index, so it picks
up crowd copies added later. Rerun it after changing club-kit mods or adding crowd textures:

```powershell
python mods\crowd-team-kits\generate.py
```

## Install

Script bundle, entry 39959 (game closed):

```powershell
python tools\pack.py restore --entry 39959
python tools\build.py full --confirm
```

## Baking crowd copies of 2026 and legacy jerseys

A crowd copy is **not** a downscaled player texture. It is a re-bake onto the crowd t-shirt mesh's own UV
layout: 1024² DXT1 with 11 mips. Sleeves sit top-right, the front and back panels across the bottom, and the
gaps are smeared. [bake_crowd_jerseys.py](bake_crowd_jerseys.py) makes them without decoding the crowd mesh:

- `learn`: learns the crowd-texel → player-texel mapping from the 146 jerseys that exist in both layouts. Each
  crowd texel is matched to the player texel whose colours agree across all of them (PCA + KD-tree at
  256², then a ±5 texel search at full size). Texels that reproduce the training jerseys form the 3 UV
  islands; the rest is padding. On 20 held-out jerseys the bake is within **~4/255** of the real crowd copy
  inside the islands. Saved as `crowd_tshirt_map.npz` (~7 min).
- `bake`: bakes every men's top a club uses that has a player texture but no crowd copy: 2026 kits,
  alternates, Indigenous and the like, and rll4-legacy-kits (whose tops `generate.py` reads from that mod's
  kit table). It skips flat tint-only textures and writes previews to `_build\crowd-team-kits\`, which later
  runs reuse unless `--rebake`. With `--confirm` it appends the new entries through `tools/add_entries.py`.

- `register`: adds the new jerseys to the **crowd texture table**, entry 39871: u32 version 8, u32 count, then
  `{FNV-1a32(lowercase name), width, height, format}` records (format 1 = DXT1). The crowd loader
  (`rugbyleague1.exe` 0xbad380) looks every crowd texture up there by hash and dereferences null on a miss.
  That is the `0xC0000409` match-load abort, the same crash whether the file is missing or just
  unregistered. It is installed through `pack.py`, so `pack.py restore --entry 39871` undoes it.
  `generate.py` only uses textures that are in both the index and this table.

```powershell
python mods\crowd-team-kits\bake_crowd_jerseys.py learn               # only if the game's jerseys change
python mods\crowd-team-kits\bake_crowd_jerseys.py bake                # dry run + previews
python mods\crowd-team-kits\bake_crowd_jerseys.py bake --confirm      # game closed
python mods\crowd-team-kits\bake_crowd_jerseys.py register --confirm  # game closed
python mods\crowd-team-kits\generate.py
python tools\pack.py restore --entry 39959
python tools\build.py full --confirm
```

Women's tops aren't baked: the crowd dresses women's clubs in the men's jerseys, like the stock data does.
The appended entries are tracked in `_backup/added_entries.json` with every other added asset.
`add_entries.py remove-all` removes **all** of them (club icons and legacy kits too), so there is no
per-mod uninstall yet.

## Caveats

- This assumes a stock club's `academyId` equals its club id. The shipped tags (teamID62 = Falcons,
  teamID67 = Manly NSW Cup, ...) line up with the club ids.
- User-made academy clubs have their own ids, so they still get the native fallback.
