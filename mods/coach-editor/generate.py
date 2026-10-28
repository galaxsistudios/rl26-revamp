import os, shutil, sys
SRC = "decompiled/src/script-game"
DST = "mods/coach-editor/src/script-game"

def patch(rel, edits):
    src = os.path.join(SRC, rel); dst = os.path.join(DST, rel)
    text = open(src, encoding="utf-8").read()
    for old, new in edits:
        n = text.count(old)
        if n != 1:
            sys.exit(f"{rel}: expected 1 match, got {n}:\n{old}")
        text = text.replace(old, new)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    open(dst, "w", encoding="utf-8", newline="").write(text)
    print("wrote", dst)

# --- home screen: Referees tile (artist-only in retail) becomes "Referees & Coaches" ---
patch("app/homescreen/homescreenstate_config.lua", [
("""local var_0_32 = {
	dataContextKey = "Referees",
	locked = false,
	requiresStrictUGCPrivileges = true,
	title = var_0_6.Umpires,
	description = native.Localise("UmpiresDescription"),""",
"""local function coachEditorText(arg_ce_0, arg_ce_1)
	local var_ce_0 = native.Localise(arg_ce_0)

	if type(var_ce_0) ~= "string" or var_ce_0 == "" or var_ce_0 == arg_ce_0 or string.find(var_ce_0, "^[<#%[]") then
		return arg_ce_1
	end

	return var_ce_0
end

local var_0_32 = {
	dataContextKey = "Referees",
	locked = false,
	requiresStrictUGCPrivileges = true,
	title = coachEditorText("RefereesAndCoaches", "Referees & Coaches"),
	description = native.Localise("UmpiresDescription"),"""),
("""		{
			title = var_0_6.DeleteReferee,
			stateData = {
				nextState = academy_referee_hub_delete.AcademyRefereeDeleteState
			}
		}
	}
}""",
"""		{
			title = var_0_6.DeleteReferee,
			stateData = {
				nextState = academy_referee_hub_delete.AcademyRefereeDeleteState
			}
		},
		{
			title = coachEditorText("EditCoach", "Edit Coach"),
			stateData = {
				nextState = academy_referee_hub_edit.AcademyRefereeEditState,
				npcType = native.CNpcType.Coach
			}
		},
		{
			title = coachEditorText("CreateCoachMan", "Create Coach (Man)"),
			stateData = {
				nextState = academyrefereecreateethnicity_state.AcademyRefereeCreateEthnicityState,
				sex = native.CSex.Male,
				npcType = native.CNpcType.Coach
			}
		},
		{
			title = coachEditorText("CreateCoachWoman", "Create Coach (Woman)"),
			stateData = {
				nextState = academyrefereecreateethnicity_state.AcademyRefereeCreateEthnicityState,
				sex = native.CSex.Female,
				npcType = native.CNpcType.Coach
			}
		},
		{
			title = coachEditorText("DeleteCoach", "Delete Coach"),
			stateData = {
				nextState = academy_referee_hub_delete.AcademyRefereeDeleteState,
				npcType = native.CNpcType.Coach
			}
		}
	}
}"""),
("""		table.insert(var_4_1.tilesRows.Academy, var_0_30)
		table.insert(var_4_1.tilesRows.Academy, var_0_31)
		table.insert(var_4_1.tilesRows.Academy, var_0_22)
		table.insert(var_4_1.tilesRows.Academy, var_0_23)
		table.insert(var_4_1.tilesRows.Academy, var_0_33)
		table.insert(var_4_1.tilesRows.Academy, var_0_34)

		if not PLATFORM_SWITCH_ANY then""",
"""		table.insert(var_4_1.tilesRows.Academy, var_0_30)
		table.insert(var_4_1.tilesRows.Academy, var_0_31)
		table.insert(var_4_1.tilesRows.Academy, var_0_32)
		table.insert(var_4_1.tilesRows.Academy, var_0_22)
		table.insert(var_4_1.tilesRows.Academy, var_0_23)
		table.insert(var_4_1.tilesRows.Academy, var_0_33)
		table.insert(var_4_1.tilesRows.Academy, var_0_34)

		if not PLATFORM_SWITCH_ANY then"""),
("""		if native.isArtist then
			table.insert(var_4_1.tilesRows.Academy, var_0_32)
		end
""",
"""		table.insert(var_4_1.tilesRows.Academy, var_0_32)
"""),
# Play Now grand-final presets point at the merged 2026 club ids (see merge-2025-clubs)
("""clubId = 13,
""", """clubId = 130,
"""),
("""clubId = 1,
""", """clubId = 118,
"""),
("""clubId = 42,
""", """clubId = 194,
"""),
("""clubId = 32,
""", """clubId = 184,
"""),
])

# --- edit list: filter by the tile's npcType (Referee by default) ---
patch("app/academy/academy_referee_hub_edit.lua", [
("""	if not var_7_2 then
		var_7_3.mustBeType = native.CNpcType.Referee
	end""",
"""	local var_7_5 = arg_7_7 and arg_7_7.npcType or native.CNpcType.Referee

	if not var_7_2 then
		var_7_3.mustBeType = var_7_5
	end"""),
("""	arg_7_0.editInfo = {
		stateFactoryMap = var_7_0,""",
"""	arg_7_0.editInfo = {
		isCoach = var_7_5 == native.CNpcType.Coach,
		stateFactoryMap = var_7_0,"""),
("""		boxTitle = native.Localise("EditReferee"),""",
"""		boxTitle = arg_4_7.isCoach and playergenerator.coachText("EditReferee") or native.Localise("EditReferee"),
		listTitle = arg_4_7.isCoach and playergenerator.coachText("Referee") or nil,"""),
("""import("design.academy_config")
""",
"""import("design.academy_config")
import("game.player.playergenerator")
"""),
("""			text = native.Localise("AcademyEditBlockedRefereeDatabaseFull"),""",
"""			text = playergenerator.npcText(arg_1_7.referee, "AcademyEditBlockedRefereeDatabaseFull"),"""),
])

patch("app/academy/academy_referee_hub_delete.lua", [
("""	var_1_0.mustBeType = native.CNpcType.Referee
	var_1_0.onlyShowUserCreated = true""",
"""	local var_1_3 = arg_1_7 and arg_1_7.npcType or native.CNpcType.Referee

	var_1_0.mustBeType = var_1_3
	var_1_0.onlyShowUserCreated = true"""),
("""		boxTitle = native.Localise("DeleteReferee"),""",
"""		boxTitle = var_1_3 == native.CNpcType.Coach and playergenerator.coachText("DeleteReferee") or native.Localise("DeleteReferee"),
		listTitle = var_1_3 == native.CNpcType.Coach and playergenerator.coachText("Referee") or nil,"""),
("""import("design.academy_config")
""",
"""import("design.academy_config")
import("game.player.playergenerator")
"""),
("""			text = stringx.interp(native.Localise("RefereeDeleteConfirm"), {""",
"""			text = stringx.interp(playergenerator.npcText(var_2_3, "RefereeDeleteConfirm"), {"""),
])

# --- coach wording on the referee screens they reuse ---
patch("app/referee/referee_viewstate_hub_state.lua", [
("""import("core.foundation.stringx")
""",
"""import("core.foundation.stringx")
import("game.player.playergenerator")
"""),
("""				text = stringx.interp(native.Localise("RefereeDeleteConfirm"), {""",
"""				text = stringx.interp(playergenerator.npcText(arg_2_6.referee, "RefereeDeleteConfirm"), {"""),
("""							arg_2_4:showNotification("alert", native.Localise("UnchangedUmpireDeleted"))""",
"""							arg_2_4:showNotification("alert", playergenerator.npcText(arg_2_6.referee, "UnchangedUmpireDeleted"))"""),
])

patch("app/academy/academy_referee_edit_hub.lua", [
("""import("app.academy.academy_helper")
""",
"""import("app.academy.academy_helper")
import("game.player.playergenerator")
"""),
("""	local var_3_0 = var_0_0(arg_3_6.partyMember, arg_3_6)
""",
"""	local var_3_0 = var_0_0(arg_3_6.partyMember, arg_3_6)

	if playergenerator.isCoachNPC(arg_3_6.referee) then
		playergenerator.coachTiles(var_3_0)
	end
"""),
("""			text = native.Localise("DeleteUnchangedUmpire"),""",
"""			text = playergenerator.npcText(arg_5_6.referee, "DeleteUnchangedUmpire"),"""),
("""						arg_5_4:showNotification("alert", native.Localise("UnchangedUmpireDeleted"))""",
"""						arg_5_4:showNotification("alert", playergenerator.npcText(arg_5_6.referee, "UnchangedUmpireDeleted"))"""),
])

# --- create: carry npcType ethnicity -> create -> view, both ways ---
patch("app/academy/academyrefereecreateethnicity_state.lua", [
("""	arg_8_0.sex = var_8_3
""",
"""	arg_8_0.sex = var_8_3
	arg_8_0.npcType = arg_8_7.npcType or native.CNpcType.Referee
"""),
("""	local var_8_6 = playergenerator.createBogStandardNPCWithEthnicity(native.CNpcType.Referee, var_8_3, var_8_5, var_8_1, var_8_0)""",
"""	local var_8_6 = playergenerator.createBogStandardNPCWithEthnicity(arg_8_0.npcType, var_8_3, var_8_5, var_8_1, var_8_0)"""),
("""				sex = VERIFY(var_9_1.stateData.sex),
				ethnicity = VERIFY(var_9_1.stateData.ethnicity)
			}""",
"""				sex = VERIFY(var_9_1.stateData.sex),
				ethnicity = VERIFY(var_9_1.stateData.ethnicity),
				npcType = arg_9_0.npcType
			}"""),
("""		local var_9_8 = playergenerator.createBogStandardNPCWithEthnicity(native.CNpcType.Referee, var_9_2.stateData.sex, var_9_3, var_9_6, var_9_7)""",
"""		local var_9_8 = playergenerator.createBogStandardNPCWithEthnicity(arg_9_0.npcType, var_9_2.stateData.sex, var_9_3, var_9_6, var_9_7)"""),
])

patch("app/academy/academy_referee_hub_create.lua", [
("""import("design.academy_config")
""",
"""import("design.academy_config")
import("game.player.playergenerator")
"""),
("""	var_0_0.enter(arg_1_0, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, tablex.merge(arg_1_7, {
		canEdit = true,
		title = native.Localise("CreateReferee"),
		tiles = academy_referee_viewstate_tiles.CreateTiles(arg_1_6.partyMember, arg_1_6)
	}))""",
"""	local var_1_ce = arg_1_7.npcType == native.CNpcType.Coach
	local var_1_ce_tiles = academy_referee_viewstate_tiles.CreateTiles(arg_1_6.partyMember, arg_1_6)

	if var_1_ce then
		playergenerator.coachTiles(var_1_ce_tiles)
	end

	var_0_0.enter(arg_1_0, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, tablex.merge(arg_1_7, {
		canEdit = true,
		title = var_1_ce and playergenerator.coachText("CreateReferee") or native.Localise("CreateReferee"),
		tiles = var_1_ce_tiles
	}))"""),
("""		sex = arg_6_7.sex,
		ethnicity = arg_6_7.ethnicity
	}""",
"""		sex = arg_6_7.sex,
		ethnicity = arg_6_7.ethnicity,
		npcType = arg_6_7.npcType
	}"""),
("""			local var_7_6 = {
				sex = var_7_2,
				originalGoBackFactoryStack = arg_7_0.originalGoBackFactoryStack
			}""",
"""			local var_7_6 = {
				sex = var_7_2,
				npcType = var_7_1.npcType,
				originalGoBackFactoryStack = arg_7_0.originalGoBackFactoryStack
			}"""),
("""			local var_7_7 = {
				sex = var_7_2
			}""",
"""			local var_7_7 = {
				sex = var_7_2,
				npcType = var_7_1.npcType
			}"""),
])

patch("app/referee/referee_view_state.lua", [
("""		local var_1_7 = playergenerator.createBogStandardNPCWithEthnicity(native.CNpcType.Referee, var_1_3.sex, var_1_3.ethnicity, var_1_5, var_1_6)""",
"""		local var_1_7 = playergenerator.createBogStandardNPCWithEthnicity(arg_1_6.npcType or native.CNpcType.Referee, var_1_3.sex, var_1_3.ethnicity, var_1_5, var_1_6)"""),
("""				text = native.Localise("AcademyEditBlockedRefereeDatabaseFull"),""",
"""				text = arg_1_6.npcType == native.CNpcType.Coach and playergenerator.coachText("AcademyEditBlockedRefereeDatabaseFull") or native.Localise("AcademyEditBlockedRefereeDatabaseFull"),"""),
])

# --- generator: DefaultPlayerVisuals.CoachCreator doesn't exist in this build ---
patch("game/player/playergenerator.lua", [
("""		var_7_3 = native.DefaultPlayerVisuals.CoachCreator

		local var_7_5 = {
			native.DefaultTeamVisuals.Coach_Suit,
			native.DefaultTeamVisuals.Coach_TrackSuit
		}
		local var_7_6 = tablex.randomelement(var_7_5)

		var_7_4 = arg_7_4:get(var_7_6)
""",
# Coach_Suit/Coach_TrackSuit are DefaultUniforms values, not DefaultTeamVisuals, so
# get(nil) raised "DefaultTeamVisuals expected, got nil" and aborted the game. Lua can't
# reach the DefaultUniforms manager, so dress the referee creator's new-custom kit in the
# civilian polo + black jeans (same guids as team-coaches).
"""		var_7_3 = arg_7_2

		local var_7_5 = arg_7_1 == native.CSex.Female

		var_7_4 = native.CVisualConfig("team")

		var_7_4:copy(arg_7_4:get(var_7_5 and native.DefaultTeamVisuals.NewCustomFemale or native.DefaultTeamVisuals.NewCustomMale))
		var_7_4:setOption("uniformTop", var_7_5 and 20101 or 20001)
		var_7_4:setOption("uniformBottom", var_7_5 and 20102 or 20002)

		for iter_7_0, iter_7_1 in ipairs({
			"topType",
			"topPatternLayer01",
			"topPatternLayer02",
			"topPatternLayer03",
			"showTeamLogo"
		}) do
			pcall(var_7_4.setOption, var_7_4, iter_7_1, 0)
		end
"""),
("""function createBogStandardNPC(arg_6_0, arg_6_1, arg_6_2, arg_6_3)""",
"""-- coach-editor: true when an NPC (CReferee) is a coach. The identity's npcType can come back
-- as an int or an enum, depending on how the record was made.
function isCoachNPC(arg_ce_0)
	if arg_ce_0 == nil then
		return false
	end

	local var_ce_0, var_ce_1 = pcall(function()
		return arg_ce_0.identity:getOption("npcType")
	end)

	if not var_ce_0 or var_ce_1 == nil then
		var_ce_0, var_ce_1 = pcall(function()
			return arg_ce_0.identity.npcType
		end)
	end

	if not var_ce_0 or var_ce_1 == nil then
		return false
	end

	local var_ce_2, var_ce_3 = pcall(function()
		return var_ce_1:toInt()
	end)

	return (var_ce_2 and var_ce_3 or tonumber(var_ce_1)) == native.CNpcType.Coach:toInt()
end

-- coach-editor: the coach screens reuse referee string keys; swap the wording
local var_0_ce_words = {
	{ "An umpire", "A coach" },
	{ "an umpire", "a coach" },
	{ "Referees", "Coaches" },
	{ "referees", "coaches" },
	{ "REFEREES", "COACHES" },
	{ "Referee", "Coach" },
	{ "referee", "coach" },
	{ "REFEREE", "COACH" },
	{ "Umpires", "Coaches" },
	{ "umpires", "coaches" },
	{ "UMPIRES", "COACHES" },
	{ "Umpire", "Coach" },
	{ "umpire", "coach" },
	{ "UMPIRE", "COACH" }
}

local function var_0_ce_swap(arg_ce_1)
	if type(arg_ce_1) ~= "string" then
		return arg_ce_1
	end

	for iter_ce_0, iter_ce_1 in ipairs(var_0_ce_words) do
		arg_ce_1 = string.gsub(arg_ce_1, iter_ce_1[1], iter_ce_1[2])
	end

	return arg_ce_1
end

function coachText(arg_ce_2)
	return var_0_ce_swap(native.Localise(arg_ce_2))
end

-- localised text for an NPC: coach wording when it's a coach
function npcText(arg_ce_3, arg_ce_4)
	if isCoachNPC(arg_ce_3) then
		return coachText(arg_ce_4)
	end

	return native.Localise(arg_ce_4)
end

function coachTiles(arg_ce_5)
	for iter_ce_2, iter_ce_3 in ipairs(arg_ce_5) do
		iter_ce_3.title = var_0_ce_swap(iter_ce_3.title)
		iter_ce_3.description = var_0_ce_swap(iter_ce_3.description)
	end

	return arg_ce_5
end

function createBogStandardNPC(arg_6_0, arg_6_1, arg_6_2, arg_6_3)"""),
])

# --- player model: the referee screens pass coaches as `referee`, which forces the
# referee "NewCustom" kit + referee team fill (renders as a player kit for coaches).
# Route coach NPCs down the stock `coach` path so they wear their own uniform. ---
patch("app/playermodel/playermodel_mixin.lua", [
("""import("app.playermodel.playermodel_helper")
""",
"""import("app.playermodel.playermodel_helper")
import("game.player.playergenerator")
"""),
("""			local var_52_10 = VERIFY(var_52_8.identity)

			var_52_9:setOption("role", arg_52_2.referee and "referee" or "coach")
			var_52_0:setCharacterConfig(var_52_9)
			var_52_0:setRefereeIdentity(var_52_10)

			if arg_52_2.referee then""",
"""			local var_52_10 = VERIFY(var_52_8.identity)
			local var_52_ce = arg_52_2.coach ~= nil or playergenerator.isCoachNPC(var_52_8)

			var_52_9:setOption("role", var_52_ce and "coach" or "referee")
			var_52_0:setCharacterConfig(var_52_9)
			var_52_0:setRefereeIdentity(var_52_10)

			if not var_52_ce then"""),
])

# --- coach role: fill the body from the NPC's own identity (the stock "coach" branch
# used whatever player identity was last shown) and keep the coach's uniform as is ---
patch("app/playermodel/playermodel.lua", [
("""	if var_53_0:getOption("role") == "referee" then
		native.PlayerVisualUtils.fillRefereeVisualConfig(var_53_0, arg_53_0.refereeIdentity)
		native.PlayerVisualUtils.fillRefereeTeamVisualConfig(var_53_1, arg_53_0.refereeIdentity)
	else""",
"""	local var_53_ce = var_53_0:getOption("role")

	if var_53_ce == "referee" then
		native.PlayerVisualUtils.fillRefereeVisualConfig(var_53_0, arg_53_0.refereeIdentity)
		native.PlayerVisualUtils.fillRefereeTeamVisualConfig(var_53_1, arg_53_0.refereeIdentity)
	elseif var_53_ce == "coach" then
		native.PlayerVisualUtils.fillRefereeVisualConfig(var_53_0, arg_53_0.refereeIdentity)
		var_53_0:setOption("role", "coach")
	else"""),
])

# --- appearance editor: coaches only get Body / Skin / Head / Hair (the referee list
# also has strapping, tattoos, headwear and boots) ---
patch("app/academy/academy_referee_appearancestate_edit_state.lua", [
("""import("app.academy.academy_helper")
""",
"""import("app.academy.academy_helper")
import("game.player.playergenerator")
"""),
("""	arg_1_0.GroupList = arg_1_7.sex.isFemale and academy_player_appearancestate_edit_groups.FemaleRefereeGroupList or academy_player_appearancestate_edit_groups.RefereeGroupList
""",
"""	arg_1_0.GroupList = arg_1_7.sex.isFemale and academy_player_appearancestate_edit_groups.FemaleRefereeGroupList or academy_player_appearancestate_edit_groups.RefereeGroupList

	if playergenerator.isCoachNPC(arg_1_7.referee) then
		local var_1_ce = arg_1_0.GroupList

		-- Body, Skin, Head, Hair
		arg_1_0.GroupList = {
			var_1_ce[1],
			var_1_ce[2],
			var_1_ce[3],
			var_1_ce[4]
		}
	end
"""),
])

# --- list frame title: layout hard-codes "Referee"; let callers pass one ---
patch("app/academy/refereelist_layout.lua", [
("""function create(arg_1_0)""", """function create(arg_1_0, arg_1_1)"""),
("""			title = native.Localise("Referee")""", """			title = arg_1_1 or native.Localise("Referee")"""),
])

patch("app/academy/academy_referee_list.lua", [
("""refereelist_layout.create(arg_4_1)""", """refereelist_layout.create(arg_4_1, arg_4_6.listTitle)"""),
])
