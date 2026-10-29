# headgear-team-colours

Kalyn Ponga's headgear always shows Queensland maroon, whoever he's playing for. Headgear colours are
fixed per player (`headwearColour1-4` in his player record: maroon base, white pattern), and the game
has no "use team colours" switch for headgear. The cricket-era `helmetUseTeam` option is never read
in RL26.

This mod recolours his headgear for the club he's playing for in each match:

| | Base (colour 1) | Pattern (colour 2) |
|---|---|---|
| Knights | navy (0,74,153) | red (228,30,19) |
| Queensland | maroon (131,1,62) | white |

The colours come from the club's primary and secondary colours, so this also works for custom
clubs and transfers. The white edging and black straps (colours 3 and 4) keep his own colours.

Script mod, entry 39959: `python tools\pack.py restore --entry scripts`, then
`python tools\build.py full --confirm` (game closed).

## How it works

`sim/universe/universe.lua`, `Universe.createProcesses`: right after the stock
`fillPlayerVisualConfig` / `fillClubVisualConfig` for each match player, `applyHeadgearTeamColours`
overwrites `headwearColour1/2` from the side's club identity (`primaryRGBColour` /
`secondaryRGBColour`, which are 0-255 and are divided by 255 because visual colour options are 0-1). Players are matched by scanned head id. To add more players, put their head
ids in `HeadgearTeamColourHeads` (233 = Ponga).

## Limits

- In-match only. Menus (team sheets, player view) still show his stock maroon headgear, because
  they're built by `PlayerModel.refresh` with no club.
- Not yet tested in-game. If replays rebuild player visuals from start info, his headgear may
  show maroon in replays.
