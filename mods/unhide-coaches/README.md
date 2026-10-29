# unhide-coaches

Unhides the 72 coaches and referees that ship flagged as hidden in `defaultdata/defaultdata_npcs`
(entry **39954**, built with `manifests/gamedata.xml`).

- Coaches and referees share one NPC database. Each record has an `npcType`
  (`native.CNpcType`, from the exe: Referee=0, Coach=1, Hidden=2). Stock data has no
  Coach-type NPCs at all, so the Academy coach lists and the career "list academy" coach
  appearance picker only ever showed user-created coaches.
- 70 NPCs go 2 -> 1 (Coach). These are the real NRL/SL coaches (Ricky Stuart, Cameron Ciraldo,
  Jason Ryles, Todd Payten, Matthew Peet, ...) plus about 60 generic/dev names.
- 2 NPCs go 2 -> 0 (Referee): Kasey Badger (545) and Belinda Sharpe (558), the only female
  referees in the data.
- One `{"npcType": N}` file per record, applied by `tools/data_mods.py` (parser:
  `tools/parse_npcs.py`). Delete a file to leave that NPC hidden.

Build from a fresh extraction of the stock entry (restore 39954 first if it's installed, since
the leagues mod shares this entry):

```powershell
python tools\pack.py restore --entry gamedata
python tools\extract_m3mp.py --entry gamedata --out <tmp>
python tools\build.py full --list manifests\gamedata.xml --extracted <tmp> --out _build\gamedata.m3mp --confirm
```

Default clubs have no coach linked (`coachId` only exists for Academy clubs), so unhiding doesn't
put coaches with their clubs. Assign them in Academy > club > coach.
