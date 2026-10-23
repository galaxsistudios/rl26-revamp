# unlock-all-kits

Makes every kit (jersey) in the club data selectable, under its real name.
On the stock game 64 kits across 41 clubs are hidden even though their data
and textures ship with the game.

This mod is a **program**, not files for `build.py` (which skips `*.py`): it
patches `rugbyleague1.exe` (13 bytes, two sites). See the docstring in
[install.py](install.py) for exactly what it changes and why.

## Recommended: let Steam re-apply it automatically

In Steam: right-click **Rugby League 26** > **Properties** > **General** >
**Launch Options**, and paste:

```
"C:\Users\mat\AppData\Local\Programs\Python\Python314\pythonw.exe" "D:\galaxsi\projects\games\modding\rugby-league-26-modding\mods\unlock-all-kits\launch.py" %command%
```

Every time you press Play, [launch.py](launch.py) runs first (after Steam has
installed any update), applies the patch if the exe is stock, then starts the
game. If the patch can't be applied - most likely because an update changed
the code it patches - a dialog explains why and asks whether to launch the
game anyway. Each run is logged to `_backup\unlock-all-kits-launch.log`.

To stop using it, clear the launch option and run `install.py --restore`.

## Manual install / uninstall (game closed)

```powershell
python mods\unlock-all-kits\install.py            # dry run - shows the changes
python mods\unlock-all-kits\install.py --apply    # backs up the exe, then patches
python mods\unlock-all-kits\install.py --status   # stock / patched / unrecognised
python mods\unlock-all-kits\install.py --restore  # undoes this tool's patch
```

- The patch sites are found by instruction pattern, so updates that only move
  code around are fine. If an update changes the kit filter itself, the tool
  refuses instead of guessing.
- Each apply keeps a copy of the unpatched exe
  (`_backup\rugbyleague1.exe.<md5>.bak`) and records the exact bytes changed
  (`_backup\unlock-all-kits.json`). `--restore` only undoes an exe this tool
  patched, so it can't put an old game version back over a new one. For
  anything else, use Steam's "Verify integrity of game files".
- On this machine `--restore` also removes the earlier Cowboys-only patch
  (recorded together), which this mod makes unnecessary.
- Unknown effect on online play - `--restore` (and clear the launch option)
  before playing online to be safe.

## Kits it unlocks (stock game, build 26072201)

| Why hidden on stock | Kits | Clubs |
|---|---|---|
| 2026 kits named `HOME 26` / `AWAY 26` / `HERITAGE 26` (game only knows `HOME 2026` / `AWAY 2026`) | 21 | Raiders, Roosters, Sharks, Storm, Wests Tigers, Dolphins 2025; Broncos, Titans, Knights, Cowboys Women |
| Club not on the game's list for that name (INDIGENOUS, ALTERNATE, ANZAC ROUND, BLACK JERSEY, NSW MINING) | 26 | Cowboys 2025; Warriors 2025 (ANZAC); NRLW clubs 184-195 (INDIGENOUS); Titans Women; GF Broncos, GF Storm, GF Broncos/Roosters Women |
| Name the game doesn't recognise: `THIRD`, `CHARITY`, `MAGIC-WEEKEND`, `ALT`, `NORTHERN LIGHTS` | 17 | Castleford, Huddersfield, Hull FC, Hull KR, St Helens, Wigan, Catalans, Manly, Wakefield, Leigh, Warrington, Cowboys (2025 and 2026) |
