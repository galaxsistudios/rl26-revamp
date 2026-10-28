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
| `teamcoaches_happy_01` | `rl1_conversion_very_positive_01` | 3.7 s | 1, 2, 5, 8 |
| `teamcoaches_happy_02` | `rl1_conversion_very_positive_02` | 4.0 s | 1, 2 |
| `teamcoaches_happy_03` (weight 3: milder) | `rl1_conversion_positive_02` | 7.0 s, trimmed 2 s | 1, 5, 7 |
| `teamcoaches_gutted_01` | `rl1_conversion_negative_01` | 9.4 s, trimmed 3.9 s | 1, 3, 5 |
| `teamcoaches_gutted_02` | `rl1_conversion_negative_02` | 10.5 s, trimmed 5 s | 1, 3, 5 |
| `teamcoaches_gutted_03` | `rl1_conversion_negative_03` | 11.1 s, trimmed 5.6 s | 1, 5 |

The flows that trigger reactions are built in files other mods own, so `coach_helper` wraps them
at runtime (installed on the first reposition of a match). `ReactionChance` sets how often each
fires:

| Trigger | Wrapped | Inserted | Chance | Who reacts |
|---|---|---|---|---|
| Penalty | `penalty.generatePenaltyAwardedState` | before `PenaltySelectSetupRuleState` (after referee-on-report's close-up) | 50% | awarded side happy or penalised side gutted, 50/50 |
| 40/20 | `ruleactionhandler.processRuleAction` with `fortyTwentyVariationRequest` | at the front | 100% | kicking side happy 60%, else other side gutted |
| Try | `TryCelebrateRuleState.onEnterSolid` | after the celebration; the try replay moves to the reaction, so the order is celebration, coach, replay, conversion | 35% | scoring side happy 75%, else other side gutted |

Off in online matches. Log lines start with `reaction`.

## Referee cameos

The referee's close-ups (try, penalty, video referee, touch judge) look across the field at the
far touchline, where the coaches just stand idle. `installReactionHooks` also wraps
`RefereeCameoRuleState.onEnterSolid` and `onExitSolid` at runtime: entering hides both sideline
coaches' actor models, and exiting shows again only the ones it hid. The log line
`referee cameo: coach hiding installed` confirms the wrap. Each cameo then logs
`referee cameo (<signal>): 56=hidden, 57=hidden` and `referee cameo ended: 2 coach(es) shown again`.
Confirmed working in game 2026-10-27 (video referee cameo).

## Match teardown

Stock always unloads a match with the pooled NPCs inactive (`GameObjectManager.dispose` doesn't
deactivate anything), and quitting with the coaches active crashed. A `Universe.unload` wrapper
deactivates them first (`deactivateGameObject` + `updateActivationRequests`).

## Default coaches

`DefaultClubCoaches` in coach_helper_block.lua maps each club (academyId) to its head coach at the end
of the 2026 season (researched 2026-10-27; where an interim coach finished the season, they're the
default). It covers the NRL (118-134), Super League (135-148), the Championship (164-183), NRLW
(184-195), Women's Super League (196-203), men's and women's Origin (18, 19, 108, 109), the 2026 World
Cup nations (103, 104, 204-219) and the GF / Decider specials (110-117). The QLD Cup, NSW Cup and All
Stars sides and the hidden 2025 clubs have no default. A pick made in Identity always wins. The
Identity row shows `(default)` for a default coach.

**The 77 coaches the game lacks are stock NPCs added by this mod** (entry 39954, defaultdata_npcs,
ids 7001-7077; `FemaleCoaches` lists the five women). [make_coach_records.py](make_coach_records.py)
reads the two Lua tables, skips names the stock data has (counting other mods' renames, e.g.
wayne-bennett-coach's NPC 503), and writes `{"new": true}` records, which `tools/data_mods.py`
appends through `bigant_db`. Ids are kept in [coach_ids.json](coach_ids.json), which only grows, so a
coach keeps their id across rebuilds (Identity picks are saved by NPC id). Each record copies a generic
placeholder NPC's record (stock NPCs 455-469, the only ones without a scanned head); the look is
built as described below. The stock data spells two names its own way:
`Matthew Peet` and `Dennis Betts`. To change a default, edit the Lua table, rerun the script and
rebuild 39954 and 39959.

### Looks (pilot, 2026-10-27)

The added coaches' looks are built from the character creator's own options, not copied faces. The
only non-scanned stock NPCs (455-469) have bald placeholder looks, and the men's lack the hair and beard
slots, so men start from `look_base_male.visual.bin`: a non-scanned player's full option layout
(player 166) with NPC 455's face values and no player gear. [coach_looks.json](coach_looks.json) holds each
coach's look in readable form (hair and beard presets as the editor lists them, hair colour, stubble,
skin tone, eyebrows, crow's feet, face-shape presets, height and weight), and
[coach_look.py](coach_look.py) turns that into option values. A preset is resolved to its
hairTop / hairSide / hairSide2 / cap or moustache / chinhair / sideburns items, because the renderer
reads those. Height and weight use a fit over the stock players (the visual height slider falls as
real height rises). Names and guids come from `look_item_maps.json`, dumped from assetmapitems.lua by
`look_dump_item_maps.lua`. Bellamy, Cleary, Robinson, Burgess and Woolf have full looks from photos. Another
39 well-known coaches have hair, colouring, facial hair, skin tone, ethnicity, age and build from what they
look like, with a seeded random face. The rest (lesser-known Championship, NRLW and WSL coaches) are fully
seeded random (`coach_look.vary`). All stay editable in Academy > Referees & Coaches.

Faces: a look's `face` scores (-1..1) features such as faceWidth, jawWidth, chinLength, cheekbones,
noseWidth, eyeDepth and mouthWidth (`FACE_FEATURES` in coach_look.py lists the advanced sliders each one
moves). Every face slider starts at the typical value for that sex (the median over the stock
non-scanned players, `look_face_neutral.json`) and moves by the score times the players' 5-95% spread.
A coach without `face` gets a random one seeded by their id, so no two coaches match. Women use their
own base (`look_base_female.visual.bin`, a non-scanned female player's layout), since the generic female
NPCs use an older slider set. Slider directions are inferred from the editor's pads (x = width,
y = height) and not confirmed in game. Some sliders sit at their maximum on almost every player
(head_height, forehead_height), so faceLength can only shorten. Rebuild the bases and neutral faces
with `python coach_look.py --players <stock players> --npcs <stock npcs>`.

Age and build (first screenshots, 2026-10-27: faces varied, but everyone looked about 25 and gym-built, in
white boots): RL26 renders no age option (`age_amount` only survives in the cricket-era upgrade code) and
the four skin textures per tone (a-d) differ only in undertone. So a look's `age` sets crow's feet and
adds eyelid droop and jowls. `build` (lean / average / heavy / muscular) sets the body type, figure and
muscle sliders; the player base was athletic with an hourglass figure. The shoes slot only has boots and
novelty items, so the boots are coloured dark.

Variety (2026-10-27, the faces still read as one face): the goal is that no two coaches look alike.
`coach_look.vary` fills whatever a look leaves out with picks seeded by the coach's id: a shape preset
for head, jaw, nose, eyes, mouth and ears (the presets change the face far more than the fine
sliders), a natural eye colour, eyebrows and the skin undertone (variants a-d of the same tone). Face
scores are multiplied by `FACE_GAIN` (1.6), and random faces use the full -1..1 range.

Second pass (the faces still looked alike: in the preview the face is ~60 px tall, so slider changes
barely register, while every unnamed coach shared one hair style, colour and stubble): `vary` also picks
hair from `MALE_HAIR` / `FEMALE_HAIR`, hair colour (greyer the older the coach), facial hair from
`MALE_FACIAL_HAIR`, skin tone (`SKIN_TONE_WEIGHTS`), age and build, and every random face gets a strong
jawline, chin and face width. `_default_male` / `_default_female` are empty so these show.

Coaches are matched by name. The lookup reads the 91 stock NPC ids with `getReferee`, then steps
`getRelativeNPCIdOfType` through the Coach NPCs, which picks up user-created coaches and the ids 7001+.
It only steps a type and sex a stock NPC has, starting from that NPC: with no NPC of that kind
the native stepper aborts the game (crash 2026-10-27). Ids outside the stock list are never read
directly, so a 39954 without the new records can't crash it. If a default coach is still missing
(39954 rebuilt without this mod), it is created as a user-created coach. That's skipped unless the
stepping worked, so it can't duplicate coaches.

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

Entry 39954 must be rebuilt from a STOCK extraction with every mod's data (it's shared with
unhide-coaches, wayne-bennett-coach and the league mods):

```powershell
python mods\team-coaches\make_coach_records.py --npcs <stock 39954>\defaultdata\defaultdata_npcs
python tools\pack.py restore --entry 39954
python tools\build.py full --list manifests\39954.xml --extracted <stock 39954> --out _build\entry_39954.m3mp --confirm
```

Then the scripts and polos:

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
