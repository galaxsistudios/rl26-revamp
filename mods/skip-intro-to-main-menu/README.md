# skip-intro-to-main-menu

Boots straight to the main menu: no splash logos (Nacon, Rugby League 26, BigAnt, legal/autosave
notices) and no "press start" screen. Also adds **RL26 Revamped Mod v1.0** in white under the
version number in the bottom-right corner of the menus.

Touches three things:

| Files | Where |
|---|---|
| `src/script-game/app/signin/waitforsignin_state.lua` | entry 39959 (scripts) |
| `noesis/workspace/views/utils/menuoverlay.xaml` | entry 57662 (Noesis XAML) |
| `install.py` | patches `rugbyleague1.exe` (2 bytes) |

```powershell
python tools\pack.py restore --entry 39959
python tools\build.py full --confirm

python tools\pack.py restore --entry 57662
python tools\extract_m3mp.py --entry 57662 --out <tmp>
python tools\build.py full --list manifests\57662.xml --extracted <tmp> --out _build\entry_57662.m3mp --confirm

python mods\skip-intro-to-main-menu\install.py --apply
```

`unlock-all-kits/launch.py` (the Steam launch option) re-applies the exe patch after updates. To
undo the exe patch, run `install.py --restore`. Do that **before** `unlock-all-kits\install.py
--restore`, because that tool's restore only accepts the exact exe md5 it produced.

## How it works

- **Splash screens (exe):** these are native. Lua polls `native.destroyLegalScreens()` every
  frame from `WaitForSignInState.update`, but the native returns false until every queued
  screen has played. The patch NOPs that `jne`, so the first poll (once the front end has
  loaded) tears the splash down. This is the same teardown the game always does, just earlier.
  Any splash time spent while the front end is still loading stays, because Lua isn't running
  yet.
- **Press start (Lua):** on the boot path only (`attractModeEnabled`), `WaitForSignInState` calls
  `activateBlockingMixin` with the default pad, which is what pressing Enter does. It retries
  each frame until the sign-in mixin accepts. A sign-out still lands on the normal "press start"
  screen. First-time boots still go through the first-boot flow (gamma, favourite club).
- **Version label (XAML):** `menuoverlay.xaml`'s version `TextBlock` now sits in a `StackPanel`
  with a second white `TextBlock`. Both use the existing `IsVersionTextVisible` binding, so the
  label shows and hides with the version number.
