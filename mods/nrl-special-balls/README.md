# nrl-special-balls

Six extra Steeden balls, used automatically in career and selectable in Play Now:

| Ball | Texture | Career | Play Now |
| --- | --- | --- | --- |
| NRL Magic Round | `ball_nrl_magicround_col` | NRL fixtures with the Magic Round special event | Ball row |
| NSW Cup | `ball_nswcup_hyundai_col` | NSW Cup fixtures | Ball row |
| NRLW Grand Final | `ball_nrlw_grandfinal_col` | the NRLW Grand Final | Ball row |
| NRL Grand Final | `ball_nrl_grandfinal_col` | the NRL Grand Final | Ball row |
| Ashes | `ball_ashes_col` | Ashes (`Tournament_Ashes`) fixtures | Ball row |
| Pacific Test | `ball_nrl_pacific_test_col` | - | Ball row |

## How the stock ball works

`game/ball/ballfactory.lua` maps the match's `native.MatchSettingsBall` to
`props/balls/textures/<name>.texture` (anything unmapped gets `ball_generic_col`). The enum is
native, so new balls can't be added to it. `app/match/matchin.lua`'s `setupBall` picks the
career ball from the competition (only Las Vegas has a special-event ball). NSW Cup has no ball
of its own, so its fixtures get whatever `matchType.ball` already was. Play Now keeps the
Ball row's pick.

## What it changes

- **Textures** ([install.py](install.py)): six new entries next to the stock balls, in the same
  format (2048x1024 BC1, 12 mips, stored upside down). The stock balls are not changed.
  - Magic Round is built from the live game's `ball_nrl_col`. Each swoosh (its green/black
    blocks) is filled with the Magic Round checker from `tools/magic_round_pattern.py`
    (corner-to-corner diagonal colour blocks on black, colours from the Magic Round Brisbane
    banner), turned so its stripes run horizontal and mirrored on the right-hand swoosh
    (`CHECK_COLUMN` / `CHECK_PERIOD` texels). Each stock line (black outer, green inner) is
    joined into one band, keeping the stock cut between the two lines and their slanted ends;
    the inner line is redrawn smooth (`smooth_band`) with a small block broken off its thick
    end (`END_PIECE`, the Ashes ball's size), as on the real ball.
    The checker colours are darkened (`CHECK_DIM`). The NRL shield and NRL TELSTRA PREMIERSHIP
    give way to the field markings' Magic Round logo
    (`resources/field-markings/field-centers/nrl-magic-round.avif`), printed under STEEDEN.
    Built at install time, not stored in git.
  - NSW Cup is also built from the live `ball_nrl_col` (the stock `ball_nswcup_col` is a blank
    placeholder that no `MatchSettingsBall` maps to, and there is no NSW Cup enum). STEEDEN /
    Est. 1958 stay; each swoosh line is redrawn as one smooth band (fitted edges, straight end
    cut, `smooth_band`) in NSW navy or sky blue (colours sampled from
    the reference photo); SYMMETRY, SIZE 5 and the NRL shield give way to ELITE MATCH, MOD,
    AUTHENTIC / MATCH BALL and the Knock-On Effect NSW Cup shield (the field markings' centre
    logo, `resources/field-markings/field-centers/nsw-cup.webp`); Hyundai
    (`resources/balls/nsw_cup/`) replaces Westpac on the sponsor panel.
  - NRLW Grand Final is the live `ball_nrlw_col` with every teal stripe and the whole NRLW logo
    (shield, Telstra T, NRL TELSTRA WOMEN'S PREMIERSHIP) in the NRL Grand Final ball's gold
    (120,110,63), the logo text redrawn as NRL TELSTRA WOMEN'S PREMIERSHIP over GRAND FINAL
    (lettering cut from the GF texture, WOMEN'S from the stock NRLW line) and the shield + Telstra T
    re-drawn from the clean vector `resources/balls/nrlw_ball/nrlw_logo.svg` (resvg-py). The teal is unmixed by its G-R share, so edges and the lighter teal shading
    keep their coverage. Built at install time.
  - Ashes is also built from the live `ball_nrl_col`: STEEDEN / SYMMETRY / SIZE 5 / Est. 1958
    stay, the left swoosh is England red over pale blue and the right Kangaroos green over gold
    (colours from the supplied shields) on both panels - beside STEEDEN the inner line's thick
    end breaks off into a block of the outer colour (`smooth_band(split=...)`) - the NRL shield gives way to the England and Kangaroos
    shields (`resources/balls/ashes/eng.svg`, `aus.svg`), and Westpac to ABK (emblem
    `abk-beer.png`) BEER / RUGBY LEAGUE / ASHES. No game texture has that lettering, so it is
    Josefin Sans (OFL, `resources/balls/ashes/fonts/`).
  - Grand Final and Pacific Test are `textures/*.png`, imported once with `art` from the
    supplied DDS files. Those were much darker than the stock balls (leather 150 / 109 against
    192), so `art` maps their leather and print levels onto the stock ones.
- **`app/match/matchin.lua`** (whole-file override): `setupBall` stores the match's special ball
  in `_G.MOD_SPECIAL_BALL = {ball, texture}`. For career NRL fixtures this comes from the special
  event (NRL MagicRound or GrandFinal, NRLW GrandFinal; `modSpecialEventBalls[competition][event]`), and for competitions in `modCompetitionBalls` (NSW Cup, Ashes; looked up by name under pcall) from
  that table. For Play Now it comes from `_G.MOD_PLAYNOW_BALL`. It also
  defines `_G.MOD_EXTRA_BALLS` (label, texture, base ball) for the Play Now row.
- **`game/ball/ballfactory.lua`** (whole-file override): loads `MOD_SPECIAL_BALL.texture` when
  the ball being loaded is still `MOD_SPECIAL_BALL.ball`. A later academy or practice ball of
  another kind keeps its stock texture.
- **Play Now Ball row**: the row lives in `enable-casual-fieldmarkings`'s
  `matchsetupmatchsettings_state.lua`, which appends `MOD_EXTRA_BALLS` to the full list
  (`modAddExtraBalls`). Picking one sets the match ball to its base (`nrl`) and the texture in
  `MOD_PLAYNOW_BALL`, remembered only until the game is closed. Picking a stock ball clears it,
  and so do modes where the Ball row is locked or restricted.

## Install

`install_revamp.py`'s textures step runs `build` + `install`. By hand (repo root, game closed):

    python mods/nrl-special-balls/install.py build [--texconv PATH]
    python mods/nrl-special-balls/install.py install --replace --confirm
    # then rebuild the scripts bundle (tools/build.py full)

The script override needs the texture entries. A ball texture that isn't in the index may
abort the match load.

## Status

Installed 2026-10-29, untested in-game. NSW Cup, NRLW Grand Final and Ashes balls added and installed 2026-10-30, untested.
