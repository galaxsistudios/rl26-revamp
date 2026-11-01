# crowd-flags

Fans in the crowd hold and wave flags, as they did in Rugby League Live 4.

**Status:** team flags confirmed in-game (2026-11-01). The per-fan mix of both teams' flags is installed but not yet
seen in-game. 40% of default and Grand Final fans carry a flag, a high rate for testing.

## How it works

RL26 has no crowd flag. RLL4 drew its flags as separate stadium models waving through an `fx_flag` vertex
shader, which RL26 doesn't have. RL26's crowd rig does still carry ten spare joints, `flagSmall_joint01..10`,
that no animation moves. This mod uses them:

- **Model:** `crowd/characters/models/prop_flagSmall.model` is a new crowd prop, a copy of `prop_camera02`
  (entry 39167) with the geometry swapped. The pole is skinned to `RightHand`. The double-sided cloth (0.52 ×
  0.34 m) is skinned along the ten flag joints, blending between neighbours. It has 7 LODs with the
  template's max weights per LOD (4, 3, 2, 2, 1, 1, 1). From LOD 4 down, the cloth columns sit exactly on the
  joints, so single-weight skinning stays exact. The pole direction is chosen so the pole points as
  upward as possible on average across every crowd animation frame, and the cloth faces the pitch.
- **Animation:** the crowd's baked animation (entry 39122) stores 94 joint rows per frame (10,233 frames,
  103 clips), each a skinning delta (quaternion + translation). The ten flag rows are rewritten for every
  frame: the right hand's delta, composed with a chain wave about the pole (bend that grows toward the free
  end, slight droop, a vertical ripple). Each clip gets a whole number of wave cycles (~1.4 Hz at 30 fps),
  so loops are seamless. No other row changes. The tool refuses to patch if any stock crowd model is
  skinned to those joints.
- **Textures:** every flag face in `resources/flags/<icon>/*.png` (1560 x 1020, the template's shape; see
  `resources/flags/README.md`) becomes `crowd_flag_<icon>_<variant>_col`: squashed into a 512² DXT1 texture with
  mips by `face_to_texture` (face in the top 7/8, pole colour below). `default_flags.py` generates the defaults
  (default, inverted, huge, wordmark, classic logos: 341 for 100 icons). Each club gets all its icon's designs,
  and its 16 crowd slots cycle through them, so a stand mixes designs. Clubs without a folder fall back to
  `crowd_flag_default01_col`, a red/yellow mask the engine tints with the club colours. They use the scarf's
  fabric normal and material maps. The back face of the cloth runs u the other way, so the flag reads
  correctly from both sides.
- **Script:** `intermediatelua/crowd/crowd_archetypes.lua` is the stock file plus a marked block at the
  end. The club id → flag-list table between the `GENERATED` markers is written by `variants`. It adds `prop_flagSmall` to the shared `crowd_items` table and puts it in the **scarf slot** of
  default and GF fans: scarf 30% (stock), flag 40% (`CROWD_FLAGS_PERCENT`), neither 30%. It isn't a prop
  because props only ever use their `base` variant (no team tags), so a prop flag can't follow the fan's
  team. Scarf-slot items resolve `teamID<club>` per fan, like the jerseys. GF fans keep their stock
  wristband props.

The crowd model and animation formats are documented in `build_flags.py`'s docstring.

## Both teams in every stand

The crowd can't be dressed fan by fan. Each fan's item picks a variant by crowd tag (`teamID<academyId>` for the
two playing teams, `homeDefault`/`awayDefault`, `base`), then a random entry of that variant's `cols` list.
Team is resolved per fan (home and away fans sit mixed in the same stands), and a fan's team tag picks the variant for their clothing slots, so jerseys, scarves and flags agree. Each match load
rebuilds the flag's variants as 16-entry lists (the native `cols` capacity):

| variant | home flags | away flags |
|---|---|---|
| home team (`teamID<home>`, `homeDefault`) | 16 | 0 |
| away team (`teamID<away>`, `awayDefault`) | 0 | 16 |
| neutral (`base`) | 8 | 8 |

Both teams' flags appear because both sides' fans are in the ground. The first version mixed 10/6 per side,
which put Rabbitohs flags in Roosters fans' hands.

Each side's slots cycle through its club's designs (default, inverted, huge, wordmark, classics), so a stand
mixes designs; the neutral list alternates the two clubs. A club without a flag of its own uses the tinted
mask. When both teams are the same club, everyone gets that club's flags. The shares are `CROWD_FLAGS_HOME_SHARE` in `crowd_archetypes.lua`.

How it runs: `crowd_archetypes.lua` stays imported, so it only defines the global `crowdFlagsPerMatch`.
crowd-team-kits' `crowd_rugby.lua` publishes the playing teams (`crowdTeamKitsTeams`) just before the crowd
loads. Its `crowd_item_config.lua`, which reruns every match, calls the hook (under `pcall`) and logs the
mix to `crowdteamkits_debug.txt` (`crowd-flags: home ... away ...`). Without crowd-team-kits, the flags fall
back to the static one-club-per-variant table.

## Install (game closed)

```powershell
python mods\crowd-flags\build_flags.py preview                       # optional: _build\crowd-flags\preview_clip47.png
python mods\crowd-flags\build_flags.py model --confirm               # appends the model entry
python mods\crowd-flags\build_flags.py variants --confirm            # resources/flags PNGs -> textures + the club table
python mods\crowd-team-kits\bake_crowd_jerseys.py register --confirm # crowd texture table (crowd-textureinfo)
python mods\crowd-flags\build_flags.py bank --confirm                # patches crowd-anim-bank (30 MB)
python tools\pack.py restore --entry scripts
python tools\build.py full --confirm                                 # script bundle with the archetypes
```

Undo: `pack.py restore --entry crowd-anim-bank` (animation), `--entry scripts` (scripts). The appended model and
textures are tracked in `_backup/added_entries.json` and harmless while unused. If you remove them, also
rerun `register` so the table drops the flags.

Rerun `variants --confirm` (then `register --confirm` and the 39959 build) after changing club data or adding clubs or emblems.

## Things to check in-game

- Match loads at all. A crash means the model is rejected, or a texture or table record is missing.
- Is the flag attached to the right hand and upright when fans cheer? Is the emblem upright, not mirrored?
- Does it wave, and is the motion believable? The tuning knobs are `WAVE_*`, `FLUTTER_AMP` and `DROOP` in
  `build_flags.py`. Rebuild with `bank --confirm`, which restores and repatches.
- Size and frequency. The flag size is `CLOTH_*`/`POLE_*` (rebuild `model --confirm`, which replaces in
  place); frequency is `CROWD_FLAGS_PERCENT` (rebuild `scripts`).
