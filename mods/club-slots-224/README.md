# club-slots-224

An exe patch that gives the game 4 more on-disc club slots, ids 220-223. Stock has 220 (ids 0-219, 0 = no club),
and every one is used. The Perth Bears (`mods/perth-bears`) take 220.

## Why 220

| What | Where (1.0.5933 RVA) | Stock behaviour |
|---|---|---|
| Club slots | `defaultdata_clubs` loader `0xa90510`, `mov edi, 0DCh` at `0xa90736` | Constructs exactly 220 slots, then stores each record at `slot[id]`. A record with id 220 lands in an unconstructed slot and crashes at boot (roster push through a null pointer) |
| On disc or user-made | `0xa8e15d`, `0xdcc082`, `0xfad938`, `0xfb069c`, `0x5ba3cd`, `0xa90b5c`; `isOnDisc` `0xfb1817` / `0xfb9a18` | `(disc id or id) < 220` means a built-in club. User-made Academy clubs get ids from **1000** (`addClub` `0xa89510`), so 220-999 are free |
| Lua constant | `MAX_CLUBS_ON_DISC` `0xfb17b7` | 220 |
| On-disc count | `0xa893c6` | Counts 220 bits of the id bitset |

The patch makes these 11 sites 224. **Not patched:** `0xa8bd62` / `0xa8c9d8`, the save schema of
`paClubDatabaseUserCreated.m_customLicensedClubDatabaseDict` (u16 `Keys[220]` / u32 `Values[220]`: official club
id -> your edited copy). That size is part of the save format. The first version patched it, and existing saves
then loaded shifted: the Kangaroos' team-select preview showed an edited Roosters women's club. The dict only
holds clubs you've edited, so 220 is plenty. The club array is a growable vector (already 256 big), so it needs no
patch.

## Why only 224

The pool's id bitset is inline in its 0x3c0-byte header (`+0x18`, 7 dwords = ids 0-223), followed by an inline
220-int id list. Past 223 the bitset has to move: 64 access sites in 54 functions. Removing the 2025 duplicate
clubs (career would then play on the 2026 records) frees about 100 ids with no exe work.

## Use

```powershell
python mods\club-slots-224\install.py            # dry run
python mods\club-slots-224\install.py --apply    # game closed
python mods\club-slots-224\install.py --status
python mods\club-slots-224\install.py --restore
```

`install_revamp.py` applies it in its exe step, and `unlock-all-kits/launch.py` re-applies it after Steam updates.
`tools/data_mods.py` only accepts club ids 220-223 while this mod is present.

**A club in 220-223 needs the patch.** If a Steam update moves this code and the patch can't find its sites, the
launcher logs it and the game crashes at boot until the patch is updated or the club is moved.

## Untested / to check in-game

- Boot with Perth at 220.
- Perth in Quick Match, competitions, team edit (should count as built-in, not user-made) and saving an edit.
- About 70 other `0xDC` immediates in the exe aren't classified yet. Some may be per-club tables elsewhere
  (career, saves).
