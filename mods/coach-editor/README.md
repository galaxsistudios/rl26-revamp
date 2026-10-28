# coach-editor

Adds a **Referees & Coaches** tile to the Academy row of the home screen. Its submenu has
Edit/Create (Man)/Create (Woman)/Delete for referees, then the same four for coaches.
Script mod, entry **39959**. Pair it with `unhide-coaches` (entry 39954), or the coach lists
only show coaches you create yourself.

Why the stock game has no coach editor:
- The Referees tile (`var_0_32` in `homescreenstate_config.lua`) is only added when
  `native.isArtist` is set, so retail never shows it. The XAML slot (`Referees` in
  `paacademytilerow.xaml`) and the view-model property already exist, so reusing that tile
  needs no Noesis changes.
- The old `academy_coach_*` states are dead code from an earlier version (stale `enter`
  signatures, old tile-menu UI), so this mod doesn't use them. Coaches are NPCs in the same
  manager as referees, so the mod reuses the maintained referee screens with an `npcType`
  passed through `stateData`.
- `playergenerator.createBogStandardNPCWithEthnicity` uses `DefaultPlayerVisuals.CoachCreator`
  for coaches, and that doesn't exist in this build's exe. The mod uses the chosen ethnicity's
  face instead. The generator's `Coach_Suit`/`Coach_TrackSuit` are `DefaultUniforms` values
  Lua can't load, so new coaches get the civilian polo and black jeans (guids 20001/20002,
  female 20101/20102).

Files (whole-file overrides of the decompiled stock files):

| File | Change |
|---|---|
| `app/homescreen/homescreenstate_config.lua` | tile retitled, 4 coach submenu items, tile added to the retail (`publicfacing`) and dev Academy rows |
| `app/academy/academy_referee_hub_edit.lua` | list filter uses `stateData.npcType` (default Referee), coach box title |
| `app/academy/academy_referee_hub_delete.lua` | same, for delete |
| `app/academy/academyrefereecreateethnicity_state.lua` | carries `npcType`, previews with it |
| `app/academy/academy_referee_hub_create.lua` | carries `npcType` into create and back-navigation |
| `app/referee/referee_view_state.lua` | creates the NPC with `npcType` |
| `game/player/playergenerator.lua` | coach branch uses the ethnicity visual and a polo + jeans uniform (the stock branch asked `DefaultTeamVisuals` for `Coach_Suit`, which is a `DefaultUniforms` value, so it crashed); adds `isCoachNPC` |
| `app/playermodel/playermodel_mixin.lua` | Coach-type NPCs passed as `referee` take the stock `coach` path (own uniform, no referee kit) |
| `app/playermodel/playermodel.lua` | `coach` role fills the body from the NPC identity and leaves the uniform alone |
| `app/academy/academy_referee_edit_hub.lua`, `app/referee/referee_viewstate_hub_state.lua` (+ create/edit/delete/view above) | coach wording: referee string keys run through `playergenerator.coachText`/`npcText`/`coachTiles` (Referee/Umpire -> Coach), so no new string-table keys are needed |
| `app/academy/academy_referee_appearancestate_edit_state.lua` | coaches only get Body/Skin/Head/Hair (no strapping, tattoos, headwear, boots) |
| `app/academy/refereelist_layout.lua`, `academy_referee_list.lua` | list frame title can be passed in (stock hard-codes "Referee"); coach lists say "Coach" |

All overrides are generated from the stock decompiled files by `generate.py` (build.py skips
`*.py`). Re-run it after a game update, from the repo root.

The list rows use the old native grid widget (`UIWidgetRefereeGridMenu`). Its font is chosen in
the exe and not exposed to Lua, which is why it looks different from the Noesis screens.

Menu text uses `native.Localise` with an English fallback, because keys like
`RefereesAndCoaches`/`CreateCoachMan` may not exist in the string tables.

Known limits / untested:
- Licensed NPCs with scanned faces may be flagged `isTier1`, in which case the game locks their
  Appearance and Sharing tiles (same rule as licensed players).
- Coaches are still not attached to clubs. Nothing in the retail UI calls `club:setCoachId`.
- Adding a button to the Academy row may push Community/League past the hard-coded scroll
  offset in `paacademytilerow.xaml`.
