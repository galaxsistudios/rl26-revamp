# ladder-team-logos

Shows each club's logo on the ladder tab of the competition hub, which both
career mode (`careerstate_compview_hub`) and competition mode use.

Stock `paCompetitionLadderView` already has a 24x24 `Image` bound to
`NVMLadderRow.TeamLogo`, and `NVMLadderRow` already has
`createTeamLogoTexture` / `update`, but only the career home mini-ladder ever
called them. The hub ladder left the image empty.

- `competition_hub_ladder.lua`: `enter` hands the engine and frontend to the
  view model (`setLogoContext`), as the textures need the decal manager,
  decal render and texture manager.
- `nvm_competitionladder.lua`: `populateLadder` loads the "64" club icon per
  row. Rows are positional, so when a refresh re-sorts the ladder a row is
  given a new club. Each row remembers `logoClubId` and reloads only when it
  changes. A new `update()` (which `NVMCompetitionHub:update` already calls on
  every tab) swaps in each logo once it has loaded. `dispose` unloads any logo
  still loading.

The row class itself is stock, as the career home shares it.

## Files / entries

| Files | Entry |
|---|---|
| `src/script-game/app/competition/competition_hub_ladder.lua`, `src/script-game/app/noesis/competition/nvm_competitionladder.lua` | scripts |
