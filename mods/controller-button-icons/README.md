# controller-button-icons

Shows PlayStation (or any other console's) button prompts instead of Xbox ones,
and lets you switch back.

On PC, prompts come from two systems, and both default to Xbox for any gamepad
(a DualSense included):

1. **Noesis icons** (in-match hints, `|ACCEPT|`, `|L1|`, … tokens). The PS5,
   PS4 and Switch sets ship with the game and are always loaded
   (`noesis/workspace/resources/tooltipicons/*.xaml`). Which set is used comes
   from a startup setting, `environmentTooltips` (`pc` = auto: keyboard → PC,
   pad → Xbox). [install.py](install.py) patches `rugbyleague1.exe` (4 bytes)
   so its default is the style you pick. Button names in localised text
   switch too.
2. **The menu prompt atlas** (bottom prompt bar, dialog buttons like
   "(A) Yes, Do It!", "(B) Cancel"). Lua swaps between
   `extrasymbols_keyboard` and `extrasymbols_gamepad` textures based on the
   last input device. Only an Xbox gamepad atlas ships, so
   [atlas.py](atlas.py) builds a PlayStation one: Cross/Circle/Triangle/Square,
   L1/L2/R1/R2 and Create, rendered from the game's own PS5 vector icons. It
   then installs it over entry 102661 (`ui/textures/extrasymbols_gamepad`).
   Keyboard prompts still show while you use the keyboard.
3. **The controls menu** (Settings > Controls, pause menu > Controls). It's the
   legacy Lua screen, which draws `ui/textures/controller` (the pad picture)
   and a badge legend from `ui/textures/controller_lines` (LT/LB/Y/B/A/X …).
   Neither exists in a PlayStation version on PC, so
   [controls_art.py](controls_art.py) draws a DualSense in the same flat style
   and swaps the legend to L2/L1/R2/R1/△/○/✕/□ (entries 102575 and 102581).

## Switching (game closed)

```powershell
python mods\controller-button-icons\install.py --icons detect --apply # auto-detect (default)
python mods\controller-button-icons\install.py --icons ps5 --apply    # PlayStation 5
python mods\controller-button-icons\install.py --icons xbox --apply   # Xbox
python mods\controller-button-icons\install.py --icons ps4 --apply    # PlayStation 4
python mods\controller-button-icons\install.py --restore              # stock (keyboard=PC, pad=Xbox)
python mods\controller-button-icons\install.py --status
```

`detect` checks the connected HID devices for a Sony pad (USB or Bluetooth).
DualSense / DualSense Edge → `ps5`, DualShock 4 → `ps4`, none → stock `auto`.
It runs whenever the patch is applied, i.e. before every launch through
`launch.py`, so plug the pad in before pressing Play. The game itself can't
tell pads apart: it reads them through XInput/DirectInput, where a DualSense on
Steam Input looks exactly like an Xbox pad, so swapping pads mid-session needs
a relaunch.

`ps4`/`ps5` install all the PlayStation textures (2 and 3). Every other style
puts the stock ones back (via `pack.py`'s backups). Your choice is saved to
`_backup\controller-button-icons.json`.
[unlock-all-kits/launch.py](../unlock-all-kits/launch.py), if it's your Steam
launch option, re-applies everything before every launch, so it survives game
updates. If an update resets a texture, its stale `pack.py` backup record is
dropped and the texture is reinstalled.

## Notes

- The forced icon style applies to Noesis prompts even on keyboard. Use
  `--icons auto` / `--restore` if you play on keyboard.
- Not changed: the small player pads on the side-select screen
  (`ui/textures/controller_1..4`, `controller_empty`) are still Xbox-shaped.
  The `ui/loading/controller/*.dds` tip images are Xbox too, but the game
  doesn't use them.
- `python mods\controller-button-icons\atlas.py` writes every PS texture plus
  a preview PNG to `_build\controller-button-icons\` without installing. They
  always go there, never under `mods\`, so `build.py` doesn't see them.
- The exe site is found by instruction pattern, and the value strings are read
  from the game's own parser. If an update changes that code, the tool refuses
  to patch instead of guessing.
- Exe-patch order: `unlock-all-kits --restore` is md5-keyed, so run this mod's
  `--restore` first (the same applies to `skip-intro-to-main-menu`).
- Unknown effect on online play. `--restore` before playing online to be safe.
- Prompts verified in-game 2026-10-24. Controls-menu art installed and
  switching tested, not yet checked on screen.
