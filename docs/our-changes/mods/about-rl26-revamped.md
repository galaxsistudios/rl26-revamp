# about-rl26-revamped

Source: [mods/about-rl26-revamped](../../../mods/about-rl26-revamped/) - [README](../../../mods/about-rl26-revamped/README.md)

Adds an **About RL26 Revamped** tile to the Extra row of the home screen, right after Credits. It opens a credits-style scrolling page with the revamp credits, AI usage statement, piracy and privacy notices, and a disclaimer.

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/app/settings/settings_credits_state.lua](../../../mods/about-rl26-revamped/src/script-game/app/settings/settings_credits_state.lua) | 61 | 3 | 0 |
| [script-game/app/settings/settings_creditsstate_company_external.lua](../../../mods/about-rl26-revamped/src/script-game/app/settings/settings_creditsstate_company_external.lua) | 122 | 317 | 90 |

## Noesis UI overrides (xamls / fonts bundles)

| File | Stock lines | + | - |
|---|---:|---:|---:|
| noesis/workspace/views/homescreen/paextratilerow.xaml | 35 | 2 | 1 |
| noesis/workspace/views/testscreens/dynastycardtest.xaml | 86 | 275 | 78 |

## Programs

Generators, installers and exe patchers the mod runs itself (see its README):

- [make_logos.py](../../../mods/about-rl26-revamped/make_logos.py)

