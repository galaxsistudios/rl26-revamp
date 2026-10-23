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
"""		boxTitle = native.Localise(arg_4_7.isCoach and "EditCoach" or "EditReferee"),
		listTitle = arg_4_7.isCoach and native.Localise("Coach") or nil,"""),
])

patch("app/academy/academy_referee_hub_delete.lua", [
("""	var_1_0.mustBeType = native.CNpcType.Referee
	var_1_0.onlyShowUserCreated = true""",
"""	local var_1_3 = arg_1_7 and arg_1_7.npcType or native.CNpcType.Referee

	var_1_0.mustBeType = var_1_3
	var_1_0.onlyShowUserCreated = true"""),
("""		boxTitle = native.Localise("DeleteReferee"),""",
"""		boxTitle = native.Localise(var_1_3 == native.CNpcType.Coach and "DeleteCoach" or "DeleteReferee"),
		listTitle = var_1_3 == native.CNpcType.Coach and native.Localise("Coach") or nil,"""),
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
])

# --- generator: DefaultPlayerVisuals.CoachCreator doesn't exist in this build ---
patch("game/player/playergenerator.lua", [
("""		var_7_3 = native.DefaultPlayerVisuals.CoachCreator
""",
"""		var_7_3 = arg_7_2
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
