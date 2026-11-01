# Career mode's hard limits

Found while adding the Perth Bears as an 18th NRL club (2026-11-02). RVAs are 1.0.5933's. All three crashed the
game when exceeded. None can be raised with a simple byte patch.

| Limit | Value | Where | What happens past it |
|---|---|---|---|
| Clubs on disc | ids 0-219 | `defaultdata_clubs` loader `0xa90510` | Boot crash. `mods/club-slots-224` raises it to 224 (see [native-exe.md](native-exe.md)) |
| Matches per competition season | 204 | fixture parser node pool (`0xa29030`, allocated from `0xa2fe20`), ~50 `0xCC` immediates in career code | Crash creating a career. The stock 17-team NRL draw is exactly 204 (17 x 24 / 2) |
| Entries in career's fixed container | 46 | `count, cap=46, 8 bytes` header + 46 inline elements | Silent memory overwrite, then a crash wherever the damage lands |

## The 46-entry container

Career keeps its lists in one fixed-size container type: a 16-byte header (`i32 count`, `i32 capacity = 46`, 8 bytes)
followed by 46 inline elements. It's used for club ids (46 x 4 bytes) and for 64-byte records (`0xa32bd0` /
`0xa34240` clear 46 x 64 = `0xb80` bytes, e.g. ladder rows).

- **56 `capacity = 46` initialisations in 52 functions**, 13 of them in the career code range (`0xa00000-0xab0000`).
  Most are stack copies of one competition's list (a single copy loop).
- **No bounds checks.** There's no `cmp ..., 46` anywhere in career code: adds and copies trust the count.
- **Competitions are objects in a registry.** `vfunc +0x58` = active?, `vfunc +0x98` = the competition's club list
  (helpers `0x5b63d0`, `0x5b6490`, `0x5b6540` walk the registry). A competition object stores its list inline
  (for example `+0x110` count, `+0x120` ids; `0xa13990` copies it out and shuffles it).
- **One competition's list is safe** (the biggest is the NRL with 17-18 clubs). The danger is a list that **joins
  competitions**. The end-of-season pass (`0xa40d80`, random club picker `0xa653a0`) works on the men's pro pool,
  NRL + QLD Cup + Super League = 17 + 15 + 14 = **46 in stock, exactly full**. With an 18th NRL club it held 47:
  the copy overwrote the stack, and the picker read a garbage club id and crashed at the end of year 1.

### Why it can't simply be made bigger

- The container sits inline inside the competition objects, so a bigger one moves every field after it. Every
  instruction that uses those fields has its offset compiled in.
- Competitions are saved with their lists, so the container size is part of the save format. A size change
  misreads old saves, as happened when club-slots-224 briefly changed the custom-licensed club dict.
- The stack copies have fixed frame space. A bigger copy overwrites the neighbouring locals.

### Options for the career revamp

1. **Clamp the joining functions** (byte patch / code cave): stop at 46. That ends the memory corruption. Clubs past
   46 are left out of that one process (for example the end-of-season player allocation).
2. **Replace the joining functions with our own code** through a small DLL loaded with the game that hooks
   specific exe functions. That allows real dynamic lists. Nothing in the project does this yet.
3. **Keep every joined pool at 46 or fewer** in data: drop a club from one of the pooled competitions.

Still to do: name the competition object behind the joined pool (the one `0xa40d80` reads through
`[+0x1ef0]` / `vfunc +0x98`) and list every caller that joins competitions. NSW Cup isn't in the pool because the
career doesn't create it. Adding NSW Cup (13 clubs) would overflow it the same way.

## Career facts that came with this

- **Career's NRL is built from gamedata league 18's club list**, not from careerdata's `career_leaguestructure`.
  A club added to league 18 joins career even with no career data for it. Dynasty also loads 18. So 18 is now a
  hidden stock "NRL 2026", and league 1 is the visible NRL with Perth.
- **Career renumbers clubs.** Its club table (0x4b90-byte entries: `+0` disc id, `+4` career id) maps NRL to career
  ids 54-71, QLD Cup to 39-53 and Super League to 72-85 + 21.
- The pre-season trials draw (`career_nrl_fixture_trials`) is separate from the season draw.
