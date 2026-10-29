# stadium-name-fixes

Corrects 24 Australasian and US stadium names on stadium select, match summaries, career previews,
club home grounds and anywhere else the UI shows a ground. Where the in-game name disagreed with the
commentary, the commentary name wins. The full list, with the stock names, is
[docs/nrl-stadium-names.txt](../../docs/nrl-stadium-names.txt).

| Files | Entry |
|---|---|
| `strings/strings_en` (English UI string table) | `strings-en` (1.0.5933: 98358) |
| `strings/strings_fr` (French UI string table) | `strings-fr` (1.0.5933: 98359) |

Both entries are replaced through pack.py backups, so `install_revamp.py` uninstall restores them.

## Install

Close the game first.

```
python mods/stadium-name-fixes/install.py show                # dry run: every string it changes
python mods/stadium-name-fixes/install.py install --confirm   # restores any earlier install first
python mods/stadium-name-fixes/install.py restore
```

`install_revamp.py` runs it as the `strings` step.

## How it works

- **Format:** a string table is a `uint32` count, then that many pairs of (`uint32` length + UTF-8 key,
  `uint32` length + UTF-8 value), with nothing after. Stock tables are zstd-framed. The patched table is
  stored raw.
- **Keys:** each stadium's name sits under `MatchSettings_Ground_<id>`, `Ground_<id>` and `<id>`.
  `Ground_canberra` is a one-off older key. Lua reads the first one (`native.Localise` in
  `nvm_prematchsettings.lua` and `match_summary_helper.lua`); `native.Stadiums.getDisplayName` resolves
  natively.
- **Only stock values change:** a key is rewritten only when its value is still the stock English name.
  The French table keeps its own translations ("Stade Polytec", "Stade sportif Glen Willow").
  `Ground_waikato_Unlicensed` is left alone on purpose.

## Not changed

- **Commentary audio:** recorded lines already say the commentary names.
- **Academy stadium cards** (`dynastydata` in `gamedata`): these hold their own copy of each name, e.g.
  "Sharks Stadium", "TIO", "Port Moresby Stadium" and "Brookvale Oval".
- **Ocean Protect Stadium, One NZ Stadium, Penrith Reserve:** kept as they are.

## Adding a rename

Add the stadium id and new name to `RENAMES` in `install.py`, run `show` to check it, then
`install --confirm`.
