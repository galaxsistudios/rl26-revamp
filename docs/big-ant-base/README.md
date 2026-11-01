# Big Ant's game: how RL26 is put together

Rugby League 26 runs on Big Ant Studios' in-house engine (the same one as Rugby 25 and, in an older form, Rugby
League Live 4). Most game logic is Lua run by LuaJIT on top of a native C++ core (`rugbyleague1.exe`); the
front end is NoesisGUI (XAML); data lives in Big Ant's own self-describing databases; everything ships in one
big content archive.

What we know comes from decompiling the scripts, decoding file formats byte-for-byte (every tool in `tools/`
round-trips its format exactly), reading the exe, and in-game tests. "Confirmed" below means seen in game;
anything else is from code or data only.

| Topic | Page |
|---|---|
| The content archive, entries, hashes, bundles, updates | [archive-and-entries.md](archive-and-entries.md) |
| The Lua script layer: modules, classes, states, the native API, hooking | [lua-scripting.md](lua-scripting.md) |
| NoesisGUI front end and HUD: XAML, view models, limits | [noesis-ui.md](noesis-ui.md) |
| Databases: players, clubs (rosters, lineups, kits), leagues, NPCs, stadiums | [databases.md](databases.md) |
| Career and competition data: league structure, draws, career clubs | [career-and-competitions.md](career-and-competitions.md) |
| Art and audio: textures, kits and meshes, crowd, logos, sound banks | [art-audio-assets.md](art-audio-assets.md) |
| Gameplay AI: flowcharts, decision trees, plays, formations | [gameplay-ai.md](gameplay-ai.md) |
| Match presentation: cutscenes, lighting, intros, replays, music | [presentation.md](presentation.md) |
| The exe: native-only behaviour and the patches we make | [native-exe.md](native-exe.md) |
| Career mode's hard limits: club ids, 204 matches a season, the 46-entry container | [career-limits.md](career-limits.md) |
| Debugging: logs, crash dumps, test harnesses | [debugging.md](debugging.md) |

For where each of these is changed by a mod, see [../our-changes/](../our-changes/README.md).
