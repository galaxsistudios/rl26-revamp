# The exe (`rugbyleague1.exe`)

Some behaviour is native only and can't be changed from Lua. Where we had to, we patch the exe. Every patch is
pattern-based (it finds its code by bytes, not by address, so it survives code moving between updates), keeps a
per-md5 backup, and is re-applied after Steam updates by `mods/unlock-all-kits/launch.py` (a Steam launch-option
wrapper with an `EXTRA_PATCHES` list).

## Native behaviour we've mapped

| Behaviour | Where | Notes |
|---|---|---|
| Which kits a club shows | kit list rebuild (RVA ~0xa8dd40 on 1.0.5887) | Keeps kits by **exact name** (HOME, AWAY, HOME 2026, VEGAS, ...). Others are gated by hard-coded club-id lists (INDIGENOUS, ANZAC ROUND, ALTERNATE...) or dropped |
| AI interchanges | `paTeamSubstitutionDecisionKnowledge` job | Fixed match-minute clock; Lua requests ignored outside Be a Pro |
| Loading-screen logos | `setTeamsLoadingProps` | Point-copied into 308x312 render targets |
| Controller prompt style | startup env arg `environmentTooltips` | Defaults to `pc`; launch options don't change it |
| Crowd | `CCrowdScene` | 16-entry texture lists, team tags, side assignment |
| Noesis fonts | `paNoesisFontProvider` | Font file names hard-coded; a new font file never loads |
| NPC lookup | `getRelativeNPCIdOfType` | Aborts when no NPC matches the type and sex |
| Defence graph choice | `CTeamTacticsProcess` | Adds `10m` / `LastTackle` to graph names |
| AI conditions | flowchart condition registry | Unknown names crash at boot |
| Club slots | `defaultdata_clubs` loader (RVA ~0xa90510 on 1.0.5933) | Sets up 220 on-disc club slots (ids 0-219, all used by stock), and `id < 220` means built-in. A record with id 220+ crashes at boot. Academy clubs use ids from 1000. The id bitset is inline and holds 224 |

## Patches we apply

| Mod | Patch |
|---|---|
| unlock-all-kits | Keep every kit, whatever its name |
| controller-button-icons | Default tooltip style (PS5 / Xbox / ...), with auto-detect of a Sony pad |
| ai-interchange-rotation | Merge Lua substitution requests for AI sides, and allow forwards |
| hd-nrl-club-logos | Loading-screen logo render-target size |
| play-now-crowd-settings | Crowd side threshold (home/away fan split) |
| club-slots-224 | 224 on-disc club slots instead of 220 (11 sites; never the custom-licensed save dict, whose size is save format), for the Perth Bears at 220 |
| skip-intro-to-main-menu | Optional boot straight to the main menu (`skip_intro` in `rl26_revamp.ini`) |

Each mod's README has its exact sites. Finding native code: the exe registers Lua bindings next to their
name strings, so a binding is found from its string's cross-reference. Job functions sit in `{fnptr, nameptr}`
tables.
