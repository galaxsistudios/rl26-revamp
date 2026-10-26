# team-coaches

Gives clubs a head coach who wears a polo in the club's colour, and (pilot) puts both coaches on
the sideline during matches. Planned later: reaction close-ups of the coach for penalties, 40/20s
and the occasional try.

Pair with `unhide-coaches` (entry 39954). Without it the coach list only shows coaches you
create yourself with `coach-editor`.

## What it does

**Academy → Club → Identity** gets a `Coach: <name>` row. Pressing it opens the coach list
(the referee list, filtered to coaches, as coach-editor does). The highlighted coach is previewed
in this club's polo with black jeans. Pressing select saves the coach to the club
(`club:setCoachId`, the stock call used by the dead `AcademyClubCoachState`). Back leaves it
unchanged. Built-in (on-disc) clubs aren't saved by Academy, so for those the picker first creates the club's user-created copy (as the stock `AcademyCoachAssignClubState` does) and sets the coach on it; otherwise the pick is lost on the next launch.

**Polos.** The game has one civilian polo model, `top_polo01` (m_clothes / f_clothes), with only a
blue and a grey texture. [build_polos.py](build_polos.py) bakes one texture per
[palette.json](palette.json) colour from the grey one. The fabric detail is luminance divided by
the median, times the colour, and the dark neck label is kept. Each colour is registered as a
`uniformTop` item: male guid 61001-61016 (copying stock item 20001), female guid +100 (copying
20101). A coach gets the palette colour nearest the club's primary colour (redmean distance),
plus black jeans (`uniformBottom` 20002 male / 20102 female).

**Sideline pilot.** Every match spawns 16 pooled civilian `NPCObject`s (`Universe.loadNPCs`) that
only the tunnel walkout uses. Each time the game repositions the cheerleaders (every restart
wipe), the last two pooled NPCs are re-skinned once per match as the home and away coaches,
streamed in, activated (`activateGameObject` + `setBehaviour("Idle")`, as cutscenes do; `loadNPCs` adds them inactive, which is why they were invisible at first) and placed on the far touchline at x = ∓6, y = −36, facing the field. Confirmed in game 2026-10-25: visible, idle-animated, club-coloured polo. The coach comes from
`matchInData.home/away.coach` (what the unused `Universe.loadCoaches` expects), or failing that
from `coachId` through `npcManager:getReferee`. Neither is confirmed to be filled in yet; the log
will show it. While `SidelinePlaceWithoutCoach` is true (pilot), a side without a coach still
gets its pooled civilian placed, to show whether sideline NPCs render and animate at all. The
tunnel walkout is left alone: re-skinning is skipped when the call comes from teamshield.

Everything is logged to `teamcoaches_debug.txt` in the game folder.

## Saving coaches

Official (licensed) clubs are rebuilt by `editOrCreateUserCreatedVersionOfClub` every time the
club editor opens and are saved only as a "custom licensed" delta (`saveCustomLicensed`), which
drops `coachId`. So the mod also keeps its own record, `teamcoaches_assignments.txt` in the game
folder (`academyId=coachNpcId` per line). Identity and the match read it first. Deleting the file
clears every pick. Confirmed working across restarts 2026-10-26.

## Replays

Activating the coaches adds them to the replay recording list (`ReplayManager.activateId`). The
stock `activateId` raises an error if an id joins while a segment is recording, and activation is
deferred, so it can land mid-segment. The wrapper skips that case (logged). With that guard,
coaches are recorded and the pause-menu replay no longer freezes (2026-10-26). Set
`CoachesInReplays = false` in coach_helper_block.lua to keep them out of replays instead. While it's
true, the replay entry points log `REPLAY ERROR in <class>.<method>` with a traceback before
re-raising any error. Replay playback and its restore hide actor models not in the replay list,
so every reposition also forces the coaches visible.

## Reactions (pilot, 2026-10-26)

Reactions run through the unused stock `CheerleaderCelebrateRuleState`, flagged `coachReaction`
([reaction_rulestate_block.lua](reaction_rulestate_block.lua), appended to its file). Without the
flag the stock cheerleader code runs unchanged. Reusing it, rather than adding a class, means
replay-team-stinger (which only stings replays queued during the celebration states it lists,
this one included) shows its stinger after the coach shot. The state stops play, idles the
players and plays a close-up cutscene on one sideline coach, then continues. It skips straight on
if that side has no coach on the sideline, and gives up after 14 s.

The cutscenes are copies of the conversion reactions, appended to
`intermediatelua/cutscenes/data/cs_conversion_data.lua`, with the actor slot retyped to `npc`
(the native layout matches targets by type) and the kicking tee removed. Each has 8 alternative
one-camera `cuts`, chosen at random by default, and several look at the actor's back. So the
request passes a `cutIndex` from the front-facing ones, measured from the animsets' camera and
root tracks (`CoachReactionCutscenes` in coach_helper_block.lua). `waneTime` trims the long
disappointed clips to about 5.5 s. The log line `reaction camera: in front / BEHIND` checks the
live camera.

| Name | Copied from | Length | Cameras used |
|---|---|---|---|
| `teamcoaches_happy_01` | `rl1_conversion_very_positive_01` | 3.7 s | 3, 4, 6, 7 |
| `teamcoaches_happy_02` | `rl1_conversion_very_positive_02` | 4.0 s | 3, 4, 5, 7, 8 |
| `teamcoaches_gutted_01` | `rl1_conversion_negative_01` | 9.4 s, trimmed 3.9 s | 2, 4, 6, 8 |
| `teamcoaches_gutted_02` | `rl1_conversion_negative_02` | 10.5 s, trimmed 5 s | 4, 6, 8 |
| `teamcoaches_gutted_03` | `rl1_conversion_negative_03` | 11.1 s, trimmed 5.6 s | 4, 6, 8 |

The flows that trigger reactions are built in files other mods own, so `coach_helper` wraps them
at runtime (installed on the first reposition of a match). `ReactionChance` sets how often each
fires:

| Trigger | Wrapped | Inserted | Chance | Who reacts |
|---|---|---|---|---|
| Penalty | `penalty.generatePenaltyAwardedState` | before `PenaltySelectSetupRuleState` (after referee-on-report's close-up) | 50% | awarded side happy or penalised side gutted, 50/50 |
| 40/20 | `ruleactionhandler.processRuleAction` with `fortyTwentyVariationRequest` | at the front | 100% | kicking side happy 60%, else other side gutted |
| Try | `TryCelebrateRuleState.onEnterSolid` | after the celebration; the try replay moves to the reaction, so the order is celebration, coach, replay, conversion | 35% | scoring side happy 75%, else other side gutted |

Off in online matches. Log lines start with `reaction`.

## Match teardown

Stock always unloads a match with the pooled NPCs inactive (`GameObjectManager.dispose` doesn't
deactivate anything), and quitting with the coaches active crashed. A `Universe.unload` wrapper
deactivates them first (`deactivateGameObject` + `updateActivationRequests`).

## Files

| Part | Where | Installed by |
|---|---|---|
| 32 polo textures `characters/uniforms/textures/m_top_polo01_coach_<colour>_col_{1,2}` (2048² / 1024² BGRA) | appended blobset entries | `build_polos.py install` |
| the same names in `characters/player/global.texsrc` (entry 31558) | replaced entry, backed up | `build_polos.py texsrc` |
| polo design items | `design/characters/blendshapes.lua` (stock + generated block; assetmap imports it right after assetmapitems) | build.py (39959) |
| polo choice, outfit, sideline pilot, logging | `game/coach/coach_helper.lua` (stock + palette + [coach_helper_block.lua](coach_helper_block.lua)) | build.py |
| sideline hook | `game/cheerleader/cheerleader_helper.lua` (stock + wrapper of `positionCheerleaders`) | build.py |
| reaction cutscenes | `intermediatelua/cutscenes/data/cs_conversion_data.lua` (stock + copies) | build.py |
| coach reaction state | `rules/cutscenes/cheerleadercelebrate_rulestate.lua` (stock + [reaction_rulestate_block.lua](reaction_rulestate_block.lua)) | build.py |
| Identity row + `TeamCoachesPickerState` | `app/club/club_viewstate_identity_state.lua` (patched stock) | build.py |

Every Lua file under `src/` is generated. Edit `build_polos.py`, `coach_helper_block.lua` or
`palette.json`, then run `generate`.

## Build and install (game closed)

```powershell
python mods\team-coaches\build_polos.py bake        # _build\team-coaches\*.png + sheet.png
python mods\team-coaches\build_polos.py generate    # Lua overrides from decompiled\ + palette.json
python mods\team-coaches\build_polos.py install --confirm
python mods\team-coaches\build_polos.py texsrc --confirm   # AFTER rll4-legacy-kits' texsrc
python tools\pack.py restore --entry 39959
python tools\build.py full --confirm
```

`texsrc` appends to the live table, so rll4-legacy-kits' records are kept. rll4's own `texsrc`
rebuilds the table from stock, so rerun this one after it.

Undo: remove this folder, rebuild 39959, `pack.py restore --entry 31558` (then rerun rll4's
`texsrc`), and `add_entries.py remove-all` (that removes every appended entry; re-add the other
mods' entries afterwards).

## Test checklist

1. Academy → a club you made → Identity: the `Coach:` row is there, opens the list, the preview
   shows a polo in the club colour and black jeans, and the pick is saved (reopen Identity).
2. Quick match with that club. Check `teamcoaches_debug.txt`: either `home: npc id … <- <name>`
   or `home: no coach (coach=… coachId=…)`.
3. In the match, look along the near sideline around halfway after a restart. Is someone
   standing there? Are they animated or T-posed? Are they textured or black?
