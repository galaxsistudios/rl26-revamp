# match-summary-scorers

Source: [mods/match-summary-scorers](../../../mods/match-summary-scorers/) - [README](../../../mods/match-summary-scorers/README.md)

Tidies the scoring summary (tries / conversions / field goals / penalty goals) shown on the pause menu, the in-game match report and the career / competition post-match summary. All three are built by `statistics_helper.getNVMStatSummary` and drawn by `paMatchSummaryView` (pause template + post-match `ScoringTab`).

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/app/noesis/ingame/nvm_match_summary.lua](../../../mods/match-summary-scorers/src/script-game/app/noesis/ingame/nvm_match_summary.lua) | 136 | 11 | 0 |
| [script-game/rules/statistics/statistics_helper.lua](../../../mods/match-summary-scorers/src/script-game/rules/statistics/statistics_helper.lua) | 362 | 64 | 15 |

## Noesis UI overrides (xamls / fonts bundles)

| File | Stock lines | + | - |
|---|---:|---:|---:|
| noesis/workspace/views/statistics/pamatchsummaryview.xaml | 1123 | 51 | 23 |

