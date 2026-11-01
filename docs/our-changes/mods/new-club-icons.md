# new-club-icons

Source: [mods/new-club-icons](../../../mods/new-club-icons/) - [README](../../../mods/new-club-icons/README.md)

Adds brand-new club emblems, selectable in the academy emblem picker (and anywhere else club icons are listed): `nrl_bears` (North Sydney Bears), `nrl_chiefs` (PNG Chiefs), and 24 **classic** pre-rebrand NRL emblems (`nrl_<club>_classic_<n>`, shown as e.g. "Parramatta Eels Classic #2"). These are **new files**, not replacements. How that works is in [research/adding-new-assets.md](../../research/adding-new-assets.md).

## Lua overrides (whole-file, scripts bundle)

Diff against Big Ant's decompiled file: lines added / removed of the stock total.

| Stock file | Stock lines | + | - |
|---|---:|---:|---:|
| [script-game/intermediatelua/convant/clublist.lua](../../../mods/new-club-icons/src/script-game/intermediatelua/convant/clublist.lua) | 294 | 36 | 3 |
| [script-game/intermediatelua/convant/icons.lua](../../../mods/new-club-icons/src/script-game/intermediatelua/convant/icons.lua) | 644 | 76 | 0 |

## Programs

Generators, installers and exe patchers the mod runs itself (see its README):

- [classic_logos.py](../../../mods/new-club-icons/classic_logos.py)

