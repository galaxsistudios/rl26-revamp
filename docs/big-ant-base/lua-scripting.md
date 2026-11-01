# The Lua script layer

## What's in the script bundle

About 5,000 LuaJIT 2.1 bytecode files (debug info stripped), plus `.flow` text files for the AI. The whole bundle
is decompiled into [decompiled/src/](../../decompiled/src/) (known gaps in `decompiled/_decompile_failures.txt`).
Decompiled names are positional (`arg_1_0`, `var_0_3`), but the structure is faithful. Top-level folders under
`script-game/`, with rough file counts:

| Folder | Files | What |
|---|---:|---|
| `app/` | ~1,280 | Front-end and mode logic: home screen, academy (editors), career, competition, dynasty, casual (Play Now), match setup, settings, `noesis/` view models |
| `intermediatelua/` | ~1,470 | Generated/converted data as Lua: cutscene data, crowd archetypes/items, stadium lists, lighting, plays (authoring copies only, see [gameplay-ai.md](gameplay-ai.md)), force-directed graphs |
| `ai/` | ~675 | Player AI controllers (`*_ai.lua`), flowcharts and decision trees (`.flow`) |
| `game/` | ~320 | Match objects: players, referee, coach, cheerleaders, plays listeners |
| `rules/` | ~290 | Match rule states (kick-offs, tries, conversions, scrums, sin bins, cutscene rule states), statistics |
| `design/` | ~220 | Tuning tables: characters/assets (`assetmapitems.lua`, `texturedefinitions.lua`), play selection, online config |
| `script-config/` | ~170 | More tuning, e.g. match player ratings |
| `base/`, `core/`, `uicore/` | ~235 | Framework: `import`, classes, state machines, profiling, old widget UI |
| `simlisteners/`, `listeners/` | ~75 | Event listeners: sound, music, commentary hooks, HUD |
| `rendering/`, `sim/`, `actor/`, `attributes/`, `tools/` | | Rendering helpers, simulation glue, dev tools |

## Modules and classes

- `import("app.career.careerstate_hub")` loads a module once (`core`'s import keeps `LOADED`/`LOADING` in its own
  environment, not `_G`). Each module runs in its own environment, and its globals become the module table.
- `Class("Name", Base)` (`core/foundation/class.lua`) creates or **reuses** `_G._CLASSES[Name]`. While front-end
  modules load, classes go into `_G.TEMP_CLASSES` instead. Noesis view models use `ns.Class(name, base, ctor)`
  with a `Bindings` table (see [noesis-ui.md](noesis-ui.md)).
- Methods are looked up through the class table, so wrapping a method from another file at import time works.
  This is how two mods change one class without both overriding its file.

## States

Screens and modes are state machines (`core.statemachine`, `statepool`): a state has `enter`, `exit`, `update`,
`render`, and changes state with `changeState(factory, ...)`. The home screen's tiles carry `stateFactory`
functions. Most of a front-end state's arguments are positional: engine, time, frontend (decal manager, input,
tooltips, sounds), shared data (`career`, `partyMember`, `goBackStack`).

## The native API

Lua reaches C++ through `native.*`: classes (`native.CClub`, `CareerLadder`, `CNoesisTextureSource`, ...), enums
(`native.EStadiums`, `CareerCompetitionIdEnum`, `InputTypes`), managers (club, player, referee/NPC, texture,
decal) and helpers (`native.Localise`, `native.Random`). Native enum values are not listed anywhere in Lua; they
have to be inferred from data or the exe (see [career-and-competitions.md](career-and-competitions.md) for the
stadium ids). Retail runs with `native.publicfacing` set, which hides dev-only screens and locks some options;
`native.isArtist` gates artist tools.

The standard Lua `io` and `os` libraries are present in retail, so scripts can read and write files in the game
folder. This is how our mods log and keep settings (`rl26_revamp.ini`).

## Rules we work within

- **Only whole files can be replaced**, and the build can't add new files to the bundle. New code lives in stock
  files the game never imports, loaded with one `import` from a file we own.
- **One owner per file.** `tools/build.py` refuses two mods overriding the same file. A second mod hooks the
  first one's functions at runtime instead: by wrapping class methods, pre-seeding `_G._CLASSES[name]` with a
  `__newindex` trap, wrapping `_G.import`, or walking `getfenv` to a module that's still loading. Front-end modules
  are re-imported after a match while `_CLASSES` persists, so traps must survive redefinition.
- Front-end and AI code get different time types: AI controller times are native `Time` userdata
  (`t:ToSeconds()`), while listeners get plain numbers.
- `.flow` files must not have a UTF-8 BOM, and may only use condition names the game registers. Either mistake
  crashes the game at boot.
