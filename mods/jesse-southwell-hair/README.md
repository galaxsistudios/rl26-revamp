# jesse-southwell-hair

Jesse Southwell (player 1068, Knights NRLW) plays without headgear and with a dark blonde mid ponytail
instead of her scanned hair: editor hair style #199 (preset guid 642, a plaited top,
`ponytail_mid_plait01`, with a straight mid ponytail, `side_ponytail_mid_medium_straight01`).

| Visual option | Stock | Mod |
|---|---|---|
| `helmet` | 2 (gilbertair) | 0 (none) |
| `hair` (preset) | 105 | 642 |
| `hairTop` | 405 | 440 `ponytail_mid_plait01` |
| `hairSide` | 216 | 211 `side_ponytail_mid_medium_straight01` |
| `hairTexture_cap` | 183 | 184 `haircap_ponytail_mid_plait_col` |
| `hairColour1` / `hairColour2` | 240 / 146 | 124 (168,135,109) / 400 (191,155,126), dark honey blonde |

## How it works

Two parts:

- **Player data** (entry 39957): [defaultdata/defaultdata_players/001068_Southwell.json](defaultdata/defaultdata_players/001068_Southwell.json)
  patches her visual blob (`"visual"` overrides, `tools/data_mods.py`).
- **Script** (entry 39959): a scanned (tier-1) head ignores those options. `assetmap.lua` loads the
  hairTop, hairSide, hairSide2, hairCap and headWear meshes from item `head + 1000` (her scan's own
  hair and headgear) whenever the head is tier-1. This override's `GenericHairHeads` table lists heads
  that use the visual's options instead, like a generic head. Her face stays the scan. Add head ids
  to the table to do the same for other players.

## Install (game closed)

```powershell
python tools\pack.py restore --entry 39957
python tools\extract_m3mp.py --entry 39957 --out <tmp>\39957
python tools\build.py full --list manifests\39957.xml --extracted <tmp>\39957 --out _build\entry_39957.m3mp --confirm
python tools\pack.py restore --entry 39959
python tools\build.py full --confirm
```

## Limits

- `assetmap.lua` is a whole-file override (decompiled stock + the table and five changed checks), so
  no other mod can override it.
- Not yet tested in game. Her scanned head texture may have some painted hair at the hairline that
  doesn't match the new style.
