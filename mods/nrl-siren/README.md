# nrl-siren

At half time and full time, stadiums outside the UK sound the proper NRL siren. UK stadiums keep the
stock siren.

| Stadium | Siren |
|---|---|
| England or Wales (35 English grounds and Colwyn Bay) | Stock `Siren_default` |
| Anywhere else (Australia, NZ, PNG, France, USA) | New `siren_nrl` (`resources/new-sfx/siren.ogg`) |
| Custom (creator) grounds | New `siren_nrl`. They aren't in `stadium-cfg`, and the game treats custom stadiums as Australian anyway. |

| Files | Entry |
|---|---|
| `src/script-game/simlisteners/sound/listeners/soundlistener_sfx.lua` | 39959 |
| `sound/siren_nrl.bnk` | appended entry 108668 |

This mod owns `soundlistener_sfx.lua`.

## Stock sirens

The `OnField` bank holds three siren events, all embedded Wwise Vorbis. Decoded copies are in
`resources/new-sfx/stock-sirens/`.

| Event | Length | Used by stock |
|---|---|---|
| `Siren_default` | 5.8 s, stereo | Yes. `onTimePeriodExpiredEvent` plays it at the end of every period. |
| `Siren_AAMI` | 3.7 s, stereo | No |
| `Siren_MtSmart` | 3.1 s, mono | No |

The stock game plays the same siren at every stadium. `Siren_AAMI` and `Siren_MtSmart` stay unused.

## How it works

- **Country:** the constructor looks up `matchInData.groundInfo.ground` in
  `stadium-cfg.Stadiums[...].countryEnum`. That is the same lookup `soundlistener_environment.lua`
  uses for its country ambience switch. UK means `ECountry` England, Wales, Scotland, Ireland or
  NorthernIreland, but only the first two have stadiums.
- **Loading:** for a non-UK ground, `siren_nrl` is added to the listener's bank list as a `Complete`
  bank. The stock loader loads it with the match and unloads it after.
- **Playing:** `onTimePeriodExpiredEvent` queues `siren_nrl` (`wwiseEvent` override) on the `Sfx`
  tag instead of `siren_default`.

## The bank

```powershell
python tools\add_sound_bank.py add --name siren_nrl --audio resources\new-sfx\siren.ogg --fade-in-ms 0 --loudness -14.3 --volume-db 0 --confirm
```

- `-14.3 LUFS` matches the stock `Siren_default`. The source file is at -6.1 LUFS.
- The bank is cloned from a menu song, so it goes through the music mixer. It isn't positional, and
  the music volume setting affects it. Change `--volume-db` and add `--replace` to adjust the level.
  Scripts don't need a rebuild for that.
- `NrlSirenEnabled` at the top of the Lua must stay `false` unless the bank is installed. Loading a
  missing bank is a native crash that `pcall` can't catch.

## Install

Bank first (above), then the script mod, entry 39959:

```powershell
python tools\pack.py restore --entry scripts
python tools\build.py full --confirm
```
