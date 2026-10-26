# crowd-flags

Fans in the crowd hold and wave flags, as they did in Rugby League Live 4.

**Status:** loads in-game (confirmed 2026-10-24 with a single test flag). Per-team flags and the back-face fix
are installed, but not yet seen in-game. 40% of default and Grand Final fans carry one, a high rate for
testing.

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
- **Textures:** one 512² DXT1 flag (with mips) per distinct club emblem + colours in the installed club data
  (110 flags for 219 clubs; 2025 and 2026 versions of a club share one), named `crowd_flag_<icon>_col`. The
  top 7/8 is the flag: the primary colour with secondary stripes and the `large_mirrored` emblem. The grey band
  below colours the pole. Fans get their club's flag through `teamID<club id>` variants, like the scarves.
  Clubs without one (user academy clubs) fall back to `crowd_flag_default01_col`, a red/yellow mask the
  engine tints with the club colours (the scarves' `homeDefault`/`awayDefault` pattern). The back face of the
  cloth runs u the other way, so the flag reads correctly from both sides. The flag uses the scarf's
  fabric normal and material maps. Like every crowd texture, it must be in the crowd texture table
  (entry 39871), or the match load aborts. crowd-team-kits' `register` now re-adds **every** appended crowd
  texture with its real size, not only jerseys.
- **Script:** `intermediatelua/crowd/crowd_archetypes.lua` is the stock file plus a marked block at the
  end. The club id → flag table between the `GENERATED` markers is written by `teams`. It adds `prop_flagSmall` to the shared `crowd_items` table and gives it as a prop to default fans
  (`CROWD_FLAGS_PERCENT`). GF fans keep their wristbands, with flags added alongside.

The crowd model and animation formats are documented in `build_flags.py`'s docstring.

## Install (game closed)

```powershell
python mods\crowd-flags\build_flags.py preview                       # optional: _build\crowd-flags\preview_clip47.png
python mods\crowd-flags\build_flags.py model --confirm               # appends the model entry
python mods\crowd-flags\build_flags.py teams --confirm               # appends/replaces the team flags + writes the club table
python mods\crowd-team-kits\bake_crowd_jerseys.py register --confirm # crowd texture table (39871)
python mods\crowd-flags\build_flags.py bank --confirm                # patches entry 39122 (30 MB)
python tools\pack.py restore --entry 39959
python tools\build.py full --confirm                                 # script bundle with the archetypes
```

Undo: `pack.py restore --entry 39122` (animation), `--entry 39959` (scripts). The appended model and
textures are tracked in `_backup/added_entries.json` and harmless while unused. If you remove them, also
rerun `register` so the table drops the flags.

Rerun `teams --confirm` (then `register --confirm` and the 39959 build) after changing club data or adding clubs or emblems.

## Things to check in-game

- Match loads at all. A crash means the model is rejected, or a texture or table record is missing.
- Is the flag attached to the right hand and upright when fans cheer? Is the emblem upright, not mirrored?
- Does it wave, and is the motion believable? The tuning knobs are `WAVE_*`, `FLUTTER_AMP` and `DROOP` in
  `build_flags.py`. Rebuild with `bank --confirm`, which restores and repatches.
- Size and frequency. The flag size is `CLOTH_*`/`POLE_*` (rebuild `model --confirm`, which replaces in
  place); frequency is `CROWD_FLAGS_PERCENT` (rebuild 39959).
