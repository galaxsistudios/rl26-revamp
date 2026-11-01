# Art and audio

## Player kits

- **Design guids → models and textures.** A kit names design guids for top, shorts and socks. Each guid maps
  to an item in `design/characters/assetmapitems.lua`: a model (`characters/tops/models/top_round05_short_Male`,
  `characters/bottoms/models/shorts01_Male`, ...) and colour, normal and material textures
  `characters/uniforms/textures/m_top_<name>_col_1`. New kits register their items from Lua
  (`jigglyjointsconfig.lua` is where our kit mods hook in).
- **Every character texture must be in `characters/player/global.texsrc`** (u32 count, then 32-byte records
  keyed by FNV-1a-32 of the path without extension). Without it the texture renders black, even when the entry
  exists.
- **Meshes:** `.modelcomponent` + `.blendshapes` per item, decoded in
  [tools/bigant_mesh.py](../../tools/bigant_mesh.py). Texture x = (u mod 1)·W, y = (1 − v)·H. Models face +z,
  so the wearer's left is +x. Stock NRL tops share one raglan layout (back panel left, front panel next to it,
  sleeves on the right half). Shorts unwrap one leg per half of the texture.
- Licensed kits keep their tint layers white. Their look comes entirely from the textures.

## Club logos ("icons")

A club's `icon` names a set of textures under `ui/club_logos/<variant>/<icon>.texture`: `64`, `small`,
`large_mirrored`, `256`, `bg_logo` l/r, `field`, `dynasty`, `hud_score`, `hud_player`, `hud_lineup`,
`hud_intro`, and more. Most variants are uncompressed BGRA with premultiplied alpha and no mips. Some
per-club HUD crops ship but are never loaded. The Academy emblem list comes from `clublist.lua`.
`icons.lua` maps icons to colour sets.

## Crowd

- The crowd is GPU-instanced (`CCrowdScene`). Lua passes per-match tags (`teamID<academyId>`) and team colours,
  plus archetype and item tables (`intermediatelua/crowd/crowd_archetypes.lua`, `crowd_items.lua`,
  `crowd_item_config.lua`), which are reloaded each match.
- The crowd uses its **own** texture copies under `crowd/characters/textures/` (1024², baked to the crowd mesh
  UVs). Naming a texture that has no crowd copy aborts the match load natively.
- Native limits: at most 16 textures per item list; archetype weights add up to at most 255.
- Crowd motion is a baked bone animation bank (`crowd-anim-bank`): about 10,000 frames × 94 joint rows. The
  rig's ten `flagSmall` joints were unused, which is how our crowd flags work.
- The stock crowd only knows clubs 1-109. The 2026 clubs (118+) and the internationals got generic gear.

## Stadiums and pitch

Stadiums are levels with their own props, LED boards (`es2_lcdsign` flipper parameters), lighting
(`intermediatelua/lighting/*.lua`), field markings (round configs plus texture layers) and grass. Every ground
shares one grass texture (`grass_lush_col`). Field line numbers are a glyph atlas inside the line TXPKs.

## Audio

Wwise banks are `sound/<name>.bnk` entries, and event ids are FNV-1 32 of the lowercased name. Lua loads banks
(`soundManager:loadTransitionBank`) and posts events. **Loading a bank that isn't in the archive is a native
fatal error** that `pcall` can't catch. Music and SFX listeners live in `simlisteners/sound/listeners/`, and the
half- and full-time siren is `Siren_default`.

## Front-end art

The title screen, menu backgrounds (a 2D floor image), promo banners (server-fed JPEGs cached in Saved Games),
loading screens (team colours and images) and controller prompt atlases are separate textures. Several are drawn
at fixed native sizes.
