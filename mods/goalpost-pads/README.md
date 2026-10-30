# goalpost-pads

Replacement goal post pad textures (`props/goalposts/textures/goalpost_<team>_col`,
picked per home club / special round by `rendering/props/fieldposts.lua`).

| Pad | Change |
|---|---|
| Dolphins | Kinetic -> Budget Direct: red pad, white panel per face (top-right/bottom-left rounded), one-line two-colour logo |
| Bulldogs | plain blue -> Laundy: white upright letters stacked down each face (Arial Bold) |
| Sharks | Rinnai -> Nulon: black pad, white NULON + red swoosh reading down each face (art/nulon.png) |
| Rabbitohs | pink Stoke's -> Deicorp: blue pad, white DC emblem + DEICORP reading down each face (art/deicorp.png) |
| Roosters | stock Metro pad, purple background shifted to royal blue (logos untouched) |
| RLWC26 corner posts (men + women) | flat teal -> Harvey Norman: red, white one-line logo reading down each face (art/harvey-norman.png; grunge from the Cowboys corner post) |

## Texture layout (2048x2048 DXT1, 12 mips)

- x 0-1620: the four pad faces, 405 px each, full height.
- x 1620+: the top cap (y 0-430, octagon = post hole) and the plain white strip.
- Corner posts (cornerpost_<name>_col, 1024x1024 DXT1, 11 mips): four faces of 104 px down the left, same flip.
- The game shows these textures flipped top-to-bottom: stored row 0 is the
  bottom of the pad (the mud). Most stock pads (Macca's, Toyota, Ampol) are
  stored upside-down for that reason; Kinetic and Tasman are not, so they read
  mirrored in-game. `make_pads.py` draws in in-game orientation, then flips.

## Rebuilding

    python mods/goalpost-pads/make_pads.py [dolphins] [bulldogs] [sharks] [rabbitohs] [roosters] [rlwc26]

Recolours `art/stock_goalpost_dolphins_col.png` (stock grunge kept, the old
logo inpainted), draws `art/budget-direct.svg`, writes `art/goalpost_dolphins_col.png`
and the DDS under `textures/`. Installed by `texture_mods.py apply` (install_revamp's
textures step).
