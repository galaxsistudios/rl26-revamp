# play-now-crowd-settings

Play Now's Match Settings get a **Crowd Settings** page, after Match Officials:

| Row | Default | What it does |
|---|---|---|
| Attendance | 70% | How full the ground is. 0% is an empty ground with no crowd sound at all. |
| *Home team* Fans | 80% | Share of the crowd supporting the home team: shirts, flags, scarves and cheering. |
| *Away team* Fans | 20% | The rest. Changing either fan row moves the other, so they always add up to 100%. |

The rows step in 5%. The values last for the session and are saved as `playnow_attendance` /
`playnow_home_fans` in `rl26_revamp.ini` in the game folder, so they're remembered next time. Only Play Now
matches (`EGameMode.Casual`) use them. Career keeps its own attendance (the match's `crowdCapacity`),
and the other modes stay stock.

The Graphics option **Crowd Capacity** is still there. It isn't attendance: it caps how many crowd
characters the game draws at all (0, 25,600, 51,200 or 102,400), for performance. Attendance is a
percentage of the seats within that cap.

**Status:** built and installed; not yet seen in game.

## How the crowd works

Each seat in a ground's node file (80 bytes per node) holds two random numbers:

- one in [0, 1): the seat is filled when it's at least `1 - percent / 100`. The percentage is
  `CCrowdScene:setWantCrowdPercentage`, stock 95 (practice mode sets 0, career sets the match capacity).
- one in [-1, 1]: the side. The populate function (`rugbyleague1.exe` 1.0.5933 @0x140bb3d90) compares it with
  a zeroed register: above 0 = home tags and colours, else away. That's why both teams' fans are mixed
  through every stand, about half each.

## What this mod changes

- **Attendance** (Lua only): crowd-team-kits' `rendering/crowd/crowd_rugby.lua` calls
  `setWantCrowdPercentage(attendance)` for Play Now.
- **Home/away split** (exe patch + Lua): `install.py` patches the populate function to read the threshold
  from the crowd scene's padding dword at `+0x1c` through a 20-byte code cave in int3 padding. The scene
  starts with 6 LOD ratio floats, a byte at `+0x18` and a qword at `+0x20`; no crowd code touches
  `+0x19`–`+0x1f`. The docstring has the bytes. `crowd_rugby.lua` writes it before `init` with
  `setLODRatio(7, 1 - 2H)`, which stores a float at `scene + 4 * index` without checking the index. For a
  home share H (0–1) the threshold is `1 - 2H`: 80% gives -0.6. Padding isn't initialised, so it's written
  for every match (0, the stock split, outside Play Now) and for the menu crowd (this mod's
  `rendering/crowd/crowd_frontend.lua`). Without the patch nothing reads it.
- **The first version crashed** (2026-11-01): it used `+0x1027194`, which is the top half of a heap
  pointer at `+0x1027190` that the scene's cleanup frees, so the next match load died in the allocator
  (dump: access violation reading `0xffffffffffffffff` in the allocator's free, called from
  `0x140bbf541`). `install.py` still recognises that version's cave: `--apply` replaces it and
  `--restore` removes it.
- **Sound** (`simlisteners/sound/listeners/soundlistener_crowd.lua`, the stock file plus marked blocks):
  - At 0% attendance the listener stays disabled. No ambience loops, chants or reactions play, and
    `Crowd.setCrowdSound` already ignores a disabled listener. `respondToQuietPeriod`, which
    `sound_system.lua` calls directly, gets an `enabled` guard.
  - The home/away chant loudness (`crowdBiasPercentage`, stock 65/45) follows the split.
  - The listener holds the shared reader `modPlayNowCrowdSettings(matchInData)`: the session values,
    else the ini, else 70/80. `crowd_rugby.lua` imports it.
- **Menu**: `choose-play-now-referee`'s `app/casual/casual_newmatch.lua` (that mod owns the Play Now
  match settings screen) adds the button and page with the same in-place page swap as Match Officials.
  It logs to `playnow_officials_debug.txt`.

Each Play Now match load logs `play now crowd: attendance N%, home fans N%` to `crowdteamkits_debug.txt`.

## Install (game closed)

```powershell
python mods\play-now-crowd-settings\install.py            # dry run
python mods\play-now-crowd-settings\install.py --apply    # back up the exe, then patch
python tools\pack.py restore --entry scripts
python tools\build.py full --confirm
```

`install.py --status` reports the patch and `--restore` undoes it. The patch finds its site by byte pattern
and refuses an exe it doesn't recognise. The unlock-all-kits Steam launch option (`launch.py`) re-applies
it after a game update, and `install_revamp.py` runs it in its exe step.

## Caveats

- Not tested in game yet.
- The code cave uses the only int3 run of 20+ bytes in the 1.0.5933 code section, at 0x1401e3ab4. A future
  exe patch that needs a cave has to find another spot, or share this one.
- Seat side values are close to uniform on [-1, 1], so the split is close to the slider; it was 54/46 at
  Brookvale at the stock 0.
