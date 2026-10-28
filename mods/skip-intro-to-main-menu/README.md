# skip-intro-to-main-menu

Optional skip: with `skip_intro = true` in `rl26_revamp.ini` it boots straight to the main menu, with
no splash logos (Nacon, Rugby League 26, BigAnt, legal/autosave notices) and no "press start" screen.
**Off by default**, so the game boots normally to the start screen (see rl26-revamp-branding's
`title_screen.py`). Also adds **RL26 Revamped Mod v1.0** in white under the version number in the
bottom-right corner of the menus.

## Config

`rl26_revamp.ini` sits in the game folder (`D:\SteamLibrary\steamapps\common\Rugby League`). The game
writes it with the default on first boot if it's missing:

```ini
skip_intro = false
```

`true` / `1` / `yes` / `on` turn the skip on. Restart the game after changing it.

- The "press start" skip (Lua) reads the file every boot.
- The splash-logo skip is an exe patch. `install.py --sync` applies it when the skip is on and undoes it when
  it's off. `unlock-all-kits/launch.py` (the Steam launch option) runs that sync on every launch, so changing
  the ini and then pressing Play is enough. If the game is started some other way, the exe keeps whatever
  state the last sync left it in.

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

python mods\skip-intro-to-main-menu\install.py --sync
```

`unlock-all-kits/launch.py` (the Steam launch option) syncs the exe patch with the ini on every
launch, including after updates. To undo the exe patch by hand, run `install.py --restore`. Do that **before** `unlock-all-kits\install.py
--restore`, because that tool's restore only accepts the exact exe md5 it produced.

## How it works

- **Start screen intro (Lua):** once the splash is gone (where stock plays `SplashIntro`), `WaitForSignInState`
  calls `setBackgroundVisual("signon")` and then `("title")`. That plays rl26-revamp-branding's title art
  slide-in, and brings the logo back after a sign-out.

- **Splash screens (exe):** these are native. Lua polls `native.destroyLegalScreens()` every
  frame from `WaitForSignInState.update`, but the native returns false until every queued
  screen has played. The patch NOPs that `jne`, so the first poll (once the front end has
  loaded) tears the splash down. This is the same teardown the game always does, just earlier.
  Any splash time spent while the front end is still loading stays, because Lua isn't running
  yet.
- **Press start (Lua):** on the boot path only (`attractModeEnabled`) and only when `skipIntroEnabled()`
  reads `skip_intro = true`, `WaitForSignInState` calls
  `activateBlockingMixin` with the default pad, which is what pressing Enter does. It retries
  each frame until the sign-in mixin accepts. A sign-out still lands on the normal "press start"
  screen. First-time boots still go through the first-boot flow (gamma, favourite club).
- **Version label (XAML):** `menuoverlay.xaml`'s version `TextBlock` now sits in a `StackPanel`
  with a second white `TextBlock`. Both use the existing `IsVersionTextVisible` binding, so the
  label shows and hides with the version number.
