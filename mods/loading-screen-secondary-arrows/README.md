# loading-screen-secondary-arrows

On the team loading screen (home vs away), every second chevron arrow on each side is drawn in the
club's secondary colour (primary, secondary, primary, ... from the centre out). Stock draws them all in
the primary colour. Background glows and gradients keep the primary colour.

| Files | Entry |
|---|---|
| `src/script-game/design/loading_setup_helper.lua` | 39959 (scripts) |
| `noesis/workspace/views/loadingscreen/loadingscreen_rugby.xaml` | 57662 (Noesis XAML) |

Both files are generated. Edit `generate.py`, not the outputs:

```powershell
python mods\loading-screen-secondary-arrows\generate.py
```

## How it works

The loading screen's view model is native (`paNVMGameplayLoadingScreen`). It only binds
`HomeTeamColour`, `AwayTeamColour` and the two images, and `CTeamLoadingScreenData` has no field for
a secondary colour. So the colour carries the information itself:

- **Lua** (`SetupLoadingScreen`): sends each side's primary with the low 2 bits of every channel
  replaced by a 6-bit hash of the secondary (at most 3/255 off, not visible). That makes the colour
  unique per (primary, secondary) pair. Broncos and Manly share a primary but get different keys.
- **XAML**: `HomeSecondaryArrow` / `AwaySecondaryArrow` styles map each stock club's key colour to its
  secondary with a `DataTrigger` (87 pairs, generated from `defaultdata_clubs` plus any club overrides
  under `mods/`). The stock arrows 2/4/6 use those styles.
- Each 1s `GlowyLines` cycle moves every arrow one slot outward and then resets, so fixed per-slot
  colours would make every arrow change colour at the reset. A copy of each side's arrows (following
  the stock thickness, opacity and margin) has the opposite pattern (1/3/5 secondary), and the
  `SecondaryArrows` storyboard swaps the stock arrows and the copy at each reset. Each arrow keeps
  its colour as it travels outward.

The generator exits if two pairs hash to the same key. If that happens, change `HASH_MULS`.

## Limits

- Custom/user-edited clubs, or a stock club with edited colours, have no table entry, so their arrows
  stay primary (the stock look).
- Online and pro-team lobbies go through `SetupLoadingScreenFromSideInfo`. That path only networks
  the primary colour, so it is left unchanged.
