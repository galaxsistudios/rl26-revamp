# nrl-special-balls

Three extra NRL Steeden balls, used automatically in career and selectable in Play Now:

| Ball | Texture | Career | Play Now |
| --- | --- | --- | --- |
| NRL Magic Round | `ball_nrl_magicround_col` | NRL fixtures with the Magic Round special event | Ball row |
| NRL Grand Final | `ball_nrl_grandfinal_col` | the NRL Grand Final | Ball row |
| Pacific Test | `ball_nrl_pacific_test_col` | - | Ball row |

## How the stock ball works

`game/ball/ballfactory.lua` maps the match's `native.MatchSettingsBall` to
`props/balls/textures/<name>.texture` (anything unmapped gets `ball_generic_col`). The enum is
native, so new balls can't be added to it. `app/match/matchin.lua`'s `setupBall` picks the
career ball from the competition (only Las Vegas has a special-event ball). Play Now keeps the
Ball row's pick.

## What it changes

- **Textures** ([install.py](install.py)): three new entries next to the stock balls, in the same
  format (2048x1024 BC1, 12 mips, stored upside down). The stock balls are not changed.
  - Magic Round is built from the live game's `ball_nrl_col`. Each swoosh (its green/black
    blocks) is repainted as 16 thin lines of club-colour segments that converge into the tail.
    The shield moves left, with MAGIC ROUND / BRISBANE beside it in place of NRL TELSTRA
    PREMIERSHIP (Bahnschrift, from Windows). Built at install time, not stored in git.
  - Grand Final and Pacific Test are `textures/*.png`, imported once with `art` from the
    supplied DDS files. Those were much darker than the stock balls (leather 150 / 109 against
    192), so `art` maps their leather and print levels onto the stock ones.
- **`app/match/matchin.lua`** (whole-file override): `setupBall` stores the match's special ball
  in `_G.MOD_SPECIAL_BALL = {ball, texture}`. For career NRL fixtures this comes from the special
  event (MagicRound or GrandFinal). For Play Now it comes from `_G.MOD_PLAYNOW_BALL`. It also
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

Installed 2026-10-29, untested in-game.
