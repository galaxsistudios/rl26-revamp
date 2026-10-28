# stadium-select-home-grounds

Match setup's **Stadium Select** screen (`MatchSetupStadiumSelect` →
`paStadiumSelectView`) now opens with the two clubs' home grounds at the top of
the on-disc **Stadiums** tab: home team first, then away team. Each row has the
club's primary colour as its background and the club logo next to the stadium
name. The text turns black on light colours (luma > 170) so it stays readable.
When a row is focused it is inset 4px, so the stock white focus fill shows as a
ring around it.

- Every home ground of each club is listed, in the club's own order
  (`identity:getGround(1..groundCount)`): all of the home club's grounds,
  then all of the away club's. Only grounds in the on-disc list
  (`getUIStadiumsAsTable`) are shown. Custom (creator) grounds and grounds
  hidden on this build are skipped. If neither club has an available ground,
  the list stays stock.
- A ground both clubs use is listed once, in the home club's colours.
- The grounds still appear in their normal alphabetical place below.
- The rows hold the same on-disc stadium data as the stock rows, so selecting
  one sets the match ground exactly as the stock rows do.
- The rows are added on the first `update` frame, because that is where the
  state gets `matchSettingsSynchroniser` (`getLobbyClub("home"/"away")`). The
  tab is rebuilt, focus is forced back to row 0 and the preview image is
  refreshed.
- The Grand Final list (`isGrandFinal`) and the academy level list
  (`level_list.lua`, the same view model with no clubs) are unchanged.

## Files / entries

| Files | Entry |
|---|---|
| `src/script-game/app/match/matchsetup_stadium_select.lua`, `src/script-game/app/noesis/academy/nvm_stadium_list.lua` | 39959 (scripts) |
| `noesis/workspace/views/academy/pastadiumselectview.xaml` | 57662 (Noesis XAML) |

Install both. With only the scripts installed, the club rows show at the top as
plain rows (the XAML is what draws the colour and logo).
