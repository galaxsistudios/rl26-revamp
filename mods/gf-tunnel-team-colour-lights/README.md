# gf-tunnel-team-colour-lights

The coloured lights in the Grand Final walkout tunnel take the club colours of the side walking out,
instead of the stock lime green. Odd-numbered lights use the primary colour and even-numbered ones use
the secondary, so the floor lights form alternating bands down the tunnel and the four uplights on the
players go primary / secondary / primary / secondary.

- The tunnel lights are the lighting scene `intermediatelua/lighting/cs_corridor_nrl_01.lua`, which both
  `rl1_intro_gf_home_team_01` and `rl1_intro_gf_away_team_01` (and every competition/stadium clone) load.
  It has 26 coloured lights, all `native.Colour(131, 255, 0)`: 4 shadow-casting `CSpotLight`s
  `up_01`..`up_04` pointing up at the players, and 22 `CPlanarLight`s `floor_left_NN` / `floor_right_NN`
  (01..11, numbered in order along the tunnel). The other lights in the scene are white and stay white.
- State of Origin swaps in `cs_corridor_nrl_qld_01` (maroon) or `cs_corridor_nrl_blues_01` (cyan), chosen
  per **stadium**, not per team. Those scenes are recoloured the same way, so Origin now follows the
  team that's actually walking out.
- Lighting scenes are Lua modules that `LightingModule` `load`s, `import`s, then `unloadPackage`s every
  time a cutscene starts. That means the `lighting2` table can be edited between `load` and `import` with no
  stale state carried over.
- `rules/cutscenes/teamshield_rulestate.lua` also carries the hooks for **match-intro-versus** (two mods
  can't override one file). The hooks create, update and dispose `initial_cutscene.MatchIntroVersus`,
  all `pcall`ed. Without that mod the stock `initial_cutscene` has no `MatchIntroVersus`, so they do
  nothing.
- `rules/cutscenes/teamshield_rulestate.lua`: `onEnterSolid` copies `matchInData.home/.away`
  `primaryColour`/`secondaryColour` into `_G.GFTunnelTeamColours`, before it queues the intro.
- `rendering/modules/lighting_module.lua`: for the three tunnel scenes, when the cutscene name contains
  `intro_gf_home_team` or `intro_gf_away_team`, the `up_NN` / `floor_*_NN` lights are recoloured by number
  parity. This runs in a `pcall`, so on any error the tunnel just keeps its stock colour.
- The constants at the top of `lighting_module.lua` control the look:
  - `AlternateColours = false` gives primary everywhere.
  - `NormaliseBrightness` scales each colour so its brightest channel is 255, like the stock lime, so navy
    or maroon clubs don't get a dim tunnel. Turn it off for exact club RGB.
  - `MinUsableChannel` is the cutoff below which a colour such as black counts as unusable, and the
    other club colour is used instead.
- Script mod, entry 39959: `python tools\build.py full --confirm` (restore 39959 first if it's already
  installed).

## Trailer corridor walks

match-intro-versus plays the trailer's `rl1_trailer_corridor_dramatic_*` walks in its Grand Final trailer intro. Their
lighting scenes (`cs_corridor_dramatic_nrl_01`, `_home_stephen_crichton`, `_home`, `_away`) are
recoloured too: the side comes from `_home` / `_away` in the cutscene name, the `SpotLight70` and
`glitch_rim_*` lights take the primary colour and the three `roof` panels the secondary. The white
`glitch_spot/fill` and `PlanarLight_*` lights are left alone. Light names repeat in these scenes, so
lights are matched by name, not by number.
