# Debugging

The retail game writes no log, and `print` goes nowhere.

- **File logs.** `io.open("<name>.txt", "a")` from a mod writes to the game folder. Wrap it in `pcall` and flush
  after each write. Most of our mods keep a `*_debug.txt`.
- **Crash dumps.** A crash or force-quit leaves `_crashdumps/rugbyleague1.exe.<pid>.dmp`. A Lua error's message
  and traceback are often in the dump's memory as plain text. Our Lua is compiled without debug info, so there's
  no file:line, but the crash thread's stack strings usually name the file. Native aborts (0xC0000409, param 7)
  come from a missing asset, a missing sound bank, an uncaught Lua error or an overflowed native pool. The
  original exception record can still be found on the crash thread's stack.
- **Harness first.** Mod logic is checked in a stubbed LuaJIT harness (`toolchain/luajit`) before spending a
  game launch. Formats are checked by round-tripping (`dump(load(x)) == x`) and by rendering previews (kits,
  flags, fangear, 3D crowd previews).
- **Known traps**: a BOM in a `.flow` file; an unknown flowchart condition; a 64th formation graph; a crowd
  texture without a crowd copy; loading an absent sound bank; reading lineup slots past `getLineupSize`
  (garbage); `native.*` names seen once in decompiled code that don't exist in retail (e.g. `EGamestate`).

Installing and restoring are covered in [INSTRUCTIONS.md](../../INSTRUCTIONS.md).
