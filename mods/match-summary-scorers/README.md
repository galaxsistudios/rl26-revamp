# match-summary-scorers

Tidies the scoring summary (tries / conversions / field goals / penalty goals)
shown on the pause menu, the in-game match report and the career / competition
post-match summary. All three are built by `statistics_helper.getNVMStatSummary`
and drawn by `paMatchSummaryView` (pause template + post-match `ScoringTab`).

- **"Penalties" renamed to "Penalty Goals"** in both templates (hardcoded text;
  the pause header used to go through `localise`).
- **Empty sections are hidden.** A section (header, divider and both team
  lists) only shows when either team has an entry in it. New `NVMMatchSummary`
  bools `ShowTries`, `ShowConversions`, `ShowFieldGoals`, `ShowFieldGoals40m`,
  `ShowPenaltyGoals` are set while the lists are filled. In the post-match tab
  the 50px spacer rows became a bottom margin on each section, so hidden
  sections don't leave gaps.
- **Lists sorted by first score.** Each list is ordered by the minute of the
  player's earliest score in that category (stock sorted by count, and ties
  came out in random `pairs()` order). Ties sort by name. Each player's own
  minutes, e.g. `(9', 17', 30')`, are also listed first to last.

## Files / entries

| Files | Entry |
|---|---|
| `src/script-game/rules/statistics/statistics_helper.lua`, `src/script-game/app/noesis/ingame/nvm_match_summary.lua` | 39959 (scripts) |
| `noesis/workspace/views/statistics/pamatchsummaryview.xaml` | 57662 (Noesis XAML) |

Install both entries (see INSTRUCTIONS.md). The XAML binds the new bools, so
with only the XAML installed the bindings fail and every section shows (with
the rename); with only the scripts installed you get the sorting but the stock
layout.
