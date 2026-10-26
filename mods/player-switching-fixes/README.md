# player-switching-fixes

Defensive player switching picks the player nearest the ball carrier, avoids offside players,
and the switch button fires reliably while you hold sprint or controlled movement.

## Selection (who you switch to)

Switching is native (`native.CPlayerSwitching`); it scores every candidate with weights from
`script-config/design/playerswitching_config.lua`, merged into the native config by
`design/playerswitching_cconfig.lua`. This mod overrides the latter and adjusts two weights just
before the merge:

| Weight | Stock | Now | Why |
|---|---|---|---|
| `onCameraBonus` | 6 | 0.5 | stock, being on screen was worth as much as being 30 m closer (`distanceWeight` -0.2/m), so "best" often skipped the nearest player |
| `offsideWeight` | -0.05 | -6 | stock, offside players were picked freely; now one only wins if he's ~30 m closer than the nearest onside player |

The recently-controlled penalty (`historyTimeWeight` -10 for `historyExpiryTime` 1.4 s) is left
alone, so pressing again moves on to the next closest player.

## Input (the button not firing)

Button 10 (R1/RB) carries `SwitchToBest` / `ClassicSwitchRight` and button 11 (L1/LB) carries
`CycleBest` / `ClassicSwitchLeft`, all triggered on **release**. The same buttons also carry
`StickSwitching1/2`, triggered on **hold** after `controlGracePeriod` (0.2 s). A press that lasted
longer than 0.2 s (common while holding R2 sprint or L2 controlled movement) became a hold, and the
release switch never fired. `design/input/input_actions.lua` now triggers those four on **press**.
Holding the bumper still enters stick switching afterwards. The fullback switch (both bumpers) is
unchanged; it may switch to "best" first, then to the fullback on release.

## Files

`src/script-game/design/playerswitching_cconfig.lua`, `src/script-game/design/input/input_actions.lua`
(entry 39959): `python tools\build.py full --confirm` (game closed).
