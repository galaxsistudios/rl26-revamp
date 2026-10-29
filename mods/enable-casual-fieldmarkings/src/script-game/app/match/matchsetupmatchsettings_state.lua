import("app.match.matchsettings_options")
import("app.match.matchsetup_stadium_select")
import("app.match.stadium_helper")
import("app.network.lobby.lobby_sideinfo")
import("base.side.sidehelper")
import("base.ui.optionmenu.optionmenu_aide")
import("core.foundation.tablex")
import("script-config.design.timeofday_config")
import("app.noesis.playnow.nvm_preMatchSettings")
import("app.competition.competition_neworload_new_options")

local var_0_0 = native.getEnvironment():argExists("useProfileSettings")
local var_0_1 = competition_neworload_new_options
local var_0_2 = native.InputTypes
local var_0_3 = native.Stadiums
local var_0_4 = GAME_CRICKET
local var_0_5 = optionmenu_aide.EditTypes
local var_0_6 = optionmenu_aide.DisplayTypes
local var_0_7 = var_0_5.Toggle
local var_0_8 = var_0_5.ValueList
local var_0_9 = var_0_6.ValueList
local var_0_10 = var_0_6.Toggle
local var_0_11 = var_0_6.Button
local var_0_12 = lobby_sideinfo.setReady
local var_0_13 = optionmenu_aide.createLeftRight
local var_0_14 = optionmenu_aide.createValueListFromEnums
local var_0_15 = optionmenu_aide.valueListFromEnum
local var_0_16 = sidehelper.home
local var_0_17 = sidehelper.away
local var_0_18 = sidehelper.getSideString
local var_0_19 = stadium_helper.getClubGroundInfo
local var_0_20 = stadium_helper.getOnDiscAndCustomStadiums
local var_0_21 = var_0_3.getDisplayName
local var_0_22 = var_0_3.getGroundTextureString
local var_0_23 = var_0_3.getUnlicensedDisplayNameFromKey
local var_0_24 = native.Localise("FieldMarkings")

import("app.noesis.ns")
import("app.noesis.ns_viewmodel")

local var_0_25 = ns_viewmodel.ViewModel

ns.Class("NVMBeAProButton", var_0_25, function(arg_1_0, arg_1_1, arg_1_2)
	var_0_25.init(arg_1_0)
	arg_1_0:populatePlayer(arg_1_1, arg_1_2)
end).Bindings = {
	Namespace = "Workspace.ViewModels",
	Properties = {
		FirstName = ns.String,
		Surname = ns.String,
		Role = ns.String,
		OVR = ns.String,
		IsCaptain = ns.Bool,
		IsGoalKicker = ns.Bool,
		IsPlayMaker1 = ns.Bool,
		IsPlayMaker2 = ns.Bool
	}
}

function NVMBeAProButton.populatePlayer(arg_2_0, arg_2_1, arg_2_2)
	local var_2_0 = arg_2_2.lineup
	local var_2_1 = var_2_0:getSpecialRolesForPlayer(arg_2_1.id)

	for iter_2_0, iter_2_1 in ipairs(var_2_1) do
		if iter_2_1 == native.EClubLineupSpecialRole.Captain then
			arg_2_0.IsCaptain = true
		elseif iter_2_1 == native.EClubLineupSpecialRole.GoalKicker then
			arg_2_0.IsGoalKicker = true
		elseif iter_2_1 == native.EClubLineupSpecialRole.PlayMaker1 then
			arg_2_0.IsPlayMaker1 = true
		elseif iter_2_1 == native.EClubLineupSpecialRole.PlayMaker2 then
			arg_2_0.IsPlayMaker2 = true
		end
	end

	local var_2_2 = var_2_0:getAssignedRole(arg_2_1.id)

	arg_2_0.Role = native.Localise(tostring(var_2_2))
	arg_2_0.OVR = arg_2_1:getOverallForPrimaryRole()
	arg_2_0.FirstName = arg_2_1.identity.firstName
	arg_2_0.Surname = arg_2_1.identity.surname
end

local function var_0_26(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4)
	local var_3_0 = {
		key = arg_3_0,
		label = arg_3_0,
		editable = not native.veryearlyaccess or arg_3_4,
		editType = var_0_8,
		displayType = var_0_9,
		tooltip = native.InputTypes.LJoyLeftRight,
		tooltipText = native.Localise("Select"),
		valueList = arg_3_2
	}

	if arg_3_3 then
		function var_3_0.getValue(arg_4_0)
			local var_4_0 = arg_3_2

			for iter_4_0, iter_4_1 in ipairs(arg_3_2) do
				if arg_3_3[arg_3_1] == iter_4_1.value then
					return iter_4_0 - 1
				end
			end
		end

		function var_3_0.setValue(arg_5_0, arg_5_1)
			local var_5_0

			if type(arg_5_0) == "number" then
				var_5_0 = arg_3_2[arg_5_0 + 1].value
			else
				var_5_0 = arg_3_2[arg_5_0:toInt() + 1].value
			end

			arg_3_3[arg_3_1] = var_5_0
		end
	else
		function var_3_0.getValue(arg_6_0, arg_6_1)
			local var_6_0 = arg_6_1:getMatchSettings()[arg_3_1]

			for iter_6_0, iter_6_1 in ipairs(arg_6_0) do
				if iter_6_1.value == var_6_0 then
					return iter_6_0 - 1
				end
			end
		end

		function var_3_0.setValue(arg_7_0, arg_7_1, arg_7_2)
			if arg_7_0 == -1 then
				return
			end

			local var_7_0

			if type(arg_7_0) == "number" then
				var_7_0 = arg_7_1[arg_7_0 + 1].value
			else
				var_7_0 = arg_7_1[arg_7_0:toInt() + 1].value
			end

			arg_7_2:setMatchSettings({
				[arg_3_1] = var_7_0
			})
		end
	end

	return var_3_0
end

local function var_0_27(arg_8_0, arg_8_1, arg_8_2)
	return {
		key = arg_8_0,
		label = arg_8_0,
		editable = not native.veryearlyaccess or arg_8_2,
		editType = var_0_8,
		displayType = var_0_9,
		tooltip = native.InputTypes.LJoyLeftRight,
		tooltipText = native.Localise("Select"),
		valueList = arg_8_1,
		getValue = function(arg_9_0, arg_9_1)
			local var_9_0 = arg_9_1:getMatchSettings().difficultyIndex

			for iter_9_0, iter_9_1 in ipairs(arg_9_0) do
				if iter_9_1.value == var_9_0 then
					return iter_9_0 - 1
				end
			end
		end,
		setValue = function(arg_10_0, arg_10_1, arg_10_2)
			if arg_10_0 == -1 then
				return
			end

			local var_10_0
			local var_10_1 = arg_10_1[arg_10_0 + 1].value
			local var_10_2 = var_10_1
			local var_10_3

			if var_10_1 > native.EDifficulty.Hardest:toInt() then
				var_10_3 = native.EDifficulty.Custom
			else
				var_10_3 = native.EDifficulty:fromInt(var_10_1)
			end

			arg_10_2:setMatchSettings({
				difficultyIndex = var_10_2,
				difficulty = var_10_3
			})
		end
	}
end

local function var_0_28(arg_11_0, arg_11_1)
	local var_11_0 = {
		editable = true,
		editType = var_0_5.Button,
		label = arg_11_0,
		displayType = var_0_6.Button,
		tooltip = native.InputTypes.Accept,
		tooltipText = native.Localise("Select")
	}

	if arg_11_1 then
		tablex.mergeInto(var_11_0, arg_11_1)
	end

	return var_11_0
end

local function var_0_29(arg_12_0, arg_12_1)
	local var_12_0 = {
		editable = true,
		displayType = "StartButton",
		editType = var_0_5.Button,
		label = arg_12_0,
		tooltip = native.InputTypes.Accept,
		tooltipText = native.Localise("Select")
	}

	if arg_12_1 then
		tablex.mergeInto(var_12_0, arg_12_1)
	end

	return var_12_0
end

local function var_0_30(arg_13_0, arg_13_1)
	local var_13_0 = {
		editable = true,
		editType = var_0_5.Button,
		label = arg_13_0,
		displayType = var_0_6.DisplayableButton,
		tooltip = native.InputTypes.Accept,
		tooltipText = native.Localise("Select")
	}

	if arg_13_1 then
		tablex.mergeInto(var_13_0, arg_13_1)
	end

	return var_13_0
end

local function var_0_31(arg_14_0, arg_14_1, arg_14_2)
	return {
		tooltipText = "OptionToggle",
		key = arg_14_0,
		label = arg_14_0,
		editable = not native.veryearlyaccess or arg_14_2,
		editType = var_0_7,
		displayType = var_0_10,
		tooltip = native.InputTypes.Accept,
		getValue = function(arg_15_0)
			return arg_15_0:getMatchSettings()[arg_14_1]
		end,
		setValue = function(arg_16_0, arg_16_1)
			arg_16_1:setMatchSettings({
				[arg_14_1] = arg_16_0
			})
		end
	}
end

-- Debug log (game folder): which field-markings options/rounds were used.
local function var_0_FMLog(arg_0_0)
	pcall(function()
		local var_0_0 = io.open("fieldmarkings_debug.txt", "a")

		if var_0_0 then
			var_0_0:write(os.date("%H:%M:%S") .. " " .. arg_0_0 .. "\n")
			var_0_0:close()
		end
	end)
end

local function var_0_32(arg_17_0, arg_17_1, arg_17_2)
	local var_17_0 = {
		native.MatchSettingsFieldMarkings.NRL_GrandFinal_Post2017
	}

	if not arg_17_2 then
		table.insert(var_17_0, native.MatchSettingsFieldMarkings.WorldCup)
		table.insert(var_17_0, native.MatchSettingsFieldMarkings.WorldCupWomens)
	end

	local var_17_1 = optionmenu_aide.valueListFromEnum(native.MatchSettingsFieldMarkings, {
		excludeValues = var_17_0,
		includeValues = {
			native.MatchSettingsFieldMarkings.NRL_Season_Thursday,
			native.MatchSettingsFieldMarkings.NRL_Season_Friday,
			native.MatchSettingsFieldMarkings.NRL_Season_Saturday,
			native.MatchSettingsFieldMarkings.NRL_Season_Sunday,
			native.MatchSettingsFieldMarkings.NRL_Season_Monday,
			native.MatchSettingsFieldMarkings.SuperLeague_Season,
			native.MatchSettingsFieldMarkings.AucklandNines,
			native.MatchSettingsFieldMarkings.NRL_Rep_StateOfOrigin,
			native.MatchSettingsFieldMarkings.NRL_GrandFinal,
			native.MatchSettingsFieldMarkings.SuperLeague_GrandFinal
		}
	})

	-- Sponsor-round markings (nrl-field-sponsor-markings' config/rounds,
	-- wired up in its stadiumgrass.lua). Labelled here because these enum
	-- names have no localisation; several reuse unused values (PlayNRL =
	-- Multicultural Round, Tuesday = Magic Round).
	local var_17_FM = native.MatchSettingsFieldMarkings

	for iter_17_0, iter_17_1 in ipairs({
		-- BEGIN generated by fieldmarkings.py from nrl-field-sponsor-markings/config/rounds/*.json (menu_label)
		{
			"NRL_Rep_AllStarsMatch",
			"NRL All Stars"
		},
		{
			"NRL_Round_Anzac",
			"NRL ANZAC Round"
		},
		{
			"NRL_Rep_CityVsCountry",
			"NRL Country Round"
		},
		{
			"NRL_Finals",
			"NRL Finals Series"
		},
		{
			"NRL_Round_Indigenous",
			"NRL Indigenous Round"
		},
		{
			"NRL_Season_Wednesday",
			"Rugby League Las Vegas"
		},
		{
			"NRL_Season_Tuesday",
			"NRL Magic Round"
		},
		{
			"NRL_Round_PlayNRL",
			"NRL Multicultural Round"
		},
		{
			"NRL_Rep_AnzacTest",
			"Pacific Championships"
		},
		{
			"NRL_Round_WomenInLeague",
			"NRL Women In League Round"
		},
		{
			"WorldCup",
			"Rugby League World Cup"
		},
		{
			"WorldCupWomens",
			"Women's Rugby League World Cup"
		},
		-- END generated by fieldmarkings.py
	}) do
		local var_17_FMOk, var_17_FMValue = pcall(function()
			return var_17_FM[iter_17_1[1]]
		end)

		var_0_FMLog("menu " .. tostring(iter_17_1[1]) .. " -> " .. (var_17_FMOk and tostring(var_17_FMValue) or "error") .. " (" .. tostring(iter_17_1[2]) .. ")")

		if var_17_FMOk and var_17_FMValue ~= nil then
			table.insert(var_17_1, {
				label = iter_17_1[2],
				value = var_17_FMValue
			})
		end
	end

	-- Round picker (nrl-field-sponsor-markings): rounds with no field-markings
	-- value of their own. Each sets the native setting to its base value (so
	-- day-of-week etc. still work) and remembers the round in
	-- MOD_FIELD_ROUND_PICK; casual_newmatch_begin hands it to the grass.
	-- BEGIN fieldmarkings.py picker (rounds with a menu_label and no markings)
	local var_17_Picker = {
		{
			round = "nswcup",
			label = "Knock-On Effect NSW Cup",
			base = "NRL_Season_Friday"
		},
		{
			round = "preseason",
			label = "NRL Pre-Season Challenge",
			base = "NRL_Season_Friday"
		},
		{
			round = "qldcup",
			label = "Hostplus Cup (QLD Cup)",
			base = "NRL_Season_Friday"
		}
	}
	-- END fieldmarkings.py picker

	for iter_17_P0, iter_17_P1 in ipairs(var_17_Picker) do
		local var_17_POk, var_17_PValue = pcall(function()
			return var_17_FM[iter_17_P1.base]
		end)

		var_0_FMLog("picker " .. iter_17_P1.round .. " base " .. iter_17_P1.base .. " -> " .. (var_17_POk and tostring(var_17_PValue) or "error"))

		if var_17_POk and var_17_PValue ~= nil then
			table.insert(var_17_1, {
				label = iter_17_P1.label,
				value = var_17_PValue,
				round = iter_17_P1.round
			})
		end
	end

	var_0_FMLog("menu has " .. #var_17_1 .. " options")

	table.sort(var_17_1, function(arg_17_FM0, arg_17_FM1)
		return arg_17_FM0.label < arg_17_FM1.label
	end)

	local var_17_2 = var_0_26(var_0_24, "fieldMarkings", var_17_1)

	var_17_2.location = native.getMiniStack()
	var_17_2.valueListAllowFail = true

	-- Picker entries share their base value with a native option, so the
	-- current entry is the one whose round matches the remembered pick.
	local var_17_PSet = var_17_2.setValue

	function var_17_2.getValue(arg_17_P0, arg_17_P1)
		local var_17_P0 = arg_17_P1:getMatchSettings().fieldMarkings
		local var_17_P1 = rawget(_G, "MOD_FIELD_ROUND_PICK")
		local var_17_P2 = var_17_P1 and var_17_P1.value == var_17_P0 and var_17_P1.round or nil

		for iter_17_P2, iter_17_P3 in ipairs(arg_17_P0) do
			if iter_17_P3.value == var_17_P0 and iter_17_P3.round == var_17_P2 then
				return iter_17_P2 - 1
			end
		end
	end

	function var_17_2.setValue(arg_17_P0, arg_17_P1, arg_17_P2)
		if type(arg_17_P0) == "number" and arg_17_P0 >= 0 and arg_17_P1[arg_17_P0 + 1] then
			local var_17_P3 = arg_17_P1[arg_17_P0 + 1]

			rawset(_G, "MOD_FIELD_ROUND_PICK", var_17_P3.round and {
				round = var_17_P3.round,
				value = var_17_P3.value
			} or nil)
		elseif arg_17_P0 ~= -1 then
			rawset(_G, "MOD_FIELD_ROUND_PICK", nil)
		end

		return var_17_PSet(arg_17_P0, arg_17_P1, arg_17_P2)
	end

	local var_17_3 = arg_17_1 and arg_17_1.defaultFieldMarkings or nil

	if var_17_3 then
		local var_17_4 = arg_17_0.matchSettingsSynchroniser

		ASSERT(var_17_4)
		var_17_2.setValue(var_17_3, var_17_1, var_17_4)
	end

	return var_17_2
end

local function var_0_33(arg_18_0, arg_18_1, arg_18_2, arg_18_3, arg_18_4, arg_18_5, arg_18_6)
	local var_18_0 = arg_18_4.matchSettingsSynchroniser
	local var_18_1 = var_18_0:getMatchSettings()
	local var_18_2 = var_18_1.country

	ASSERT(var_18_2)

	local var_18_3 = {
		usingCountryFilter = var_0_4,
		country = var_18_2,
		optionsGround = arg_18_5 and arg_18_5.optionsGround
	}
	local var_18_4 = {}

	table.insert(var_18_4, {
		value = 1,
		stadium = "random",
		stadiumId = native.INVALID_LEVEL_ID,
		label = native.Localise("Random")
	})
	var_0_20(arg_18_1, var_18_4, var_18_3)

	local function var_18_5(arg_19_0, arg_19_1, arg_19_2)
		arg_19_0 = arg_19_0 + 1
		arg_18_4.stadiumIndex = arg_19_0

		ASSERT(arg_19_1[arg_19_0])

		local var_19_0 = arg_19_1[arg_19_0]

		arg_19_2:setMatchSettings({
			ground = var_19_0.stadium,
			groundId = var_19_0.stadiumId,
			groundSharingId = var_19_0.stadiumSharingId
		})
		arg_18_6:updateStadium(arg_18_0, var_19_0)
	end

	local var_18_6 = {
		editable = true,
		key = arg_18_2,
		label = arg_18_2,
		editType = var_0_8,
		displayType = var_0_9,
		tooltip = native.InputTypes.LJoyLeftRight,
		tooltipText = native.Localise("Select"),
		valueList = var_18_4,
		getValue = function()
			return arg_18_4.stadiumIndex - 1
		end,
		setValue = var_18_5
	}

	local function var_18_7(arg_21_0, arg_21_1)
		for iter_21_0, iter_21_1 in ipairs(arg_21_0) do
			if iter_21_1.stadium == arg_21_1 then
				return iter_21_0
			end
		end

		return nil
	end

	local function var_18_8(arg_22_0, arg_22_1)
		if not arg_22_0 then
			return 1
		end

		local var_22_0 = var_18_7(arg_22_1, arg_22_0)

		if not var_22_0 then
			formatPrint("Warning: Could not find stadium '%s' in list, defaulting to first stadium", arg_22_0)

			return 1
		end

		return var_22_0
	end

	local var_18_9 = (function(arg_23_0, arg_23_1, arg_23_2, arg_23_3)
		local var_23_0

		if var_0_0 then
			var_23_0 = VERIFY(arg_23_0.ground)
		else
			local var_23_1 = arg_23_3.matchSettingsSynchroniser:getSideInfo("home")

			if var_23_1 then
				local var_23_2 = var_23_1:getMatchClub().identity:getGround(1).stadium

				var_23_0 = tostring(var_23_2)
			else
				formatPrint("Warning: Home side info not found, defaulting to first stadium")

				var_23_0 = arg_23_2[1].stadium
			end
		end

		local var_23_3 = var_18_7(arg_23_2, var_23_0)

		if var_23_3 then
			arg_23_3.stadiumIndex = var_23_3 - 1
		else
			formatPrint("Warning: Current stadium '%s' not found in list, defaulting to first stadium", var_23_0)

			arg_23_3.stadiumIndex = 1
		end

		if arg_23_1 then
			if arg_23_1.resetStadium then
				arg_23_3.stadiumIndex = 1
			elseif arg_23_1.defaultGround then
				arg_23_3.stadiumIndex = var_18_8(arg_23_1.defaultGround, arg_23_2)
			end
		end

		if arg_23_3.stadiumIndex > #arg_23_2 then
			formatPrint("Warning: Stadium index %d exceeds list size %d, defaulting to first stadium", arg_23_3.stadiumIndex, #arg_23_2)

			arg_23_3.stadiumIndex = 1
		end

		return arg_23_3.stadiumIndex
	end)(var_18_1, arg_18_5, var_18_4, arg_18_4)

	var_18_6.setValue(var_18_9, var_18_4, var_18_0)

	return var_18_6
end

Class("MatchSettingsLineupSelectSubstate")

function MatchSettingsLineupSelectSubstate.enter(arg_24_0, arg_24_1, arg_24_2, arg_24_3, arg_24_4, arg_24_5)
	ASSERT(arg_24_5)
	ASSERT(arg_24_5.matchSetupData)
	ASSERT(arg_24_5.matchData)
	ASSERT(arg_24_5.metagameModeData)
	ASSERT(arg_24_5.stateMachine)

	local var_24_0 = arg_24_5.matchSetupData

	arg_24_0.matchSetupData = var_24_0

	local var_24_1 = arg_24_5.matchData

	arg_24_0.matchData = var_24_1

	local var_24_2 = arg_24_5.metagameModeData

	arg_24_0.metagameModeData = var_24_2

	local var_24_3 = arg_24_5.stateMachine

	arg_24_0.stateMachine = var_24_3

	arg_24_4:playerModelUpdate(1, {
		draw = false
	})

	local var_24_4 = var_24_0.stateFactoryMap.LineupSetup()

	arg_24_0.lineupSetup = var_24_4

	var_24_4:enter(var_24_3, arg_24_1, arg_24_2, arg_24_3, arg_24_4, var_24_2, var_24_1, var_24_0)
end

function MatchSettingsLineupSelectSubstate.update(arg_25_0, arg_25_1, arg_25_2, arg_25_3, arg_25_4, arg_25_5, arg_25_6)
	ASSERT(arg_25_0.lineupSetup)
	ASSERT(arg_25_0.stateMachine)
	ASSERT(arg_25_0.metagameModeData)
	ASSERT(arg_25_0.matchData)
	ASSERT(arg_25_0.matchSetupData)
	arg_25_0.lineupSetup:update(arg_25_0.stateMachine, arg_25_1, arg_25_2, arg_25_3, arg_25_4, arg_25_5, arg_25_6, arg_25_0.metagameModeData, arg_25_0.matchData, arg_25_0.matchSetupData)
end

function MatchSettingsLineupSelectSubstate.render(arg_26_0, arg_26_1, arg_26_2, arg_26_3, arg_26_4)
	ASSERT(arg_26_0.lineupSetup)
	ASSERT(arg_26_0.matchSetupData)
	arg_26_0.lineupSetup:render(arg_26_1, arg_26_2, arg_26_3, arg_26_4, arg_26_0.matchSetupData)
end

function MatchSettingsLineupSelectSubstate.exit(arg_27_0, arg_27_1, arg_27_2, arg_27_3, arg_27_4)
	ASSERT(arg_27_0.lineupSetup)
	ASSERT(arg_27_0.metagameModeData)
	arg_27_0.lineupSetup:exit(arg_27_1, arg_27_2, arg_27_3, arg_27_4, arg_27_0.metagameModeData)
end

Class("MatchSetupMatchSettingsState")

function MatchSetupMatchSettingsState.enter(arg_28_0, arg_28_1, arg_28_2, arg_28_3, arg_28_4, arg_28_5, arg_28_6, arg_28_7, arg_28_8)
	arg_28_5:sceneObjectSetVisible("teamBoxes", false)
	arg_28_5:setBackgroundVisual("data")

	arg_28_0.fallbackDate = native.CareerDateTime.FromSystemTime()
	arg_28_0.worldCupMode = arg_28_6.worldCupMode
	arg_28_0.allowInputAfter = arg_28_3 + 0.3

	local var_28_0 = arg_28_5:getMatchTypeManager()
	local var_28_1 = arg_28_7.matchSettingsSynchroniser
	local var_28_2 = var_28_1:getMatchSettings()

	if not arg_28_6.career then
		local var_28_3 = arg_28_5:getClubManager()
		local var_28_4 = arg_28_5:getLeagueManager()
		local var_28_5 = var_28_1:getSideInfo("home"):getMatchClub()
		local var_28_6 = var_28_3:getClub(var_28_5.id)
		local var_28_7 = var_28_4:getLeagueIdsContainingClub(var_28_6)
		local var_28_8

		if var_28_7 then
			local var_28_9 = var_28_7[1]
			local var_28_10 = var_28_4:getLeague(var_28_9)
			local var_28_11 = tostring(var_28_10.onDiscLeague)
			local var_28_12 = native.CareerCompetitionIdEnum[tostring(var_28_10.onDiscLeague)]

			if var_28_12 then
				arg_28_7.compId = var_28_12
			end
		end

		if not arg_28_8.hasSetMatchTypeSettings and not arg_28_7.matchTypeSet then
			if arg_28_7.compId then
				local var_28_13 = arg_28_5:getMatchTypeManager()
				local var_28_14 = {
					[native.CareerCompetitionIdEnum.League_NRL] = 8,
					[native.CareerCompetitionIdEnum.League_SuperLeague] = 2,
					[native.CareerCompetitionIdEnum.League_QLDCup] = 5,
					[native.CareerCompetitionIdEnum.League_NRLW] = 9,
					[native.CareerCompetitionIdEnum.League_WSL] = 7
				}
				local var_28_15 = var_28_14[arg_28_7.compId] or var_28_14[native.CareerCompetitionIdEnum.League_NRL]

				if var_28_15 then
					local var_28_16 = var_28_13:getMatchType(var_28_15)

					var_28_1:setMatchType(var_28_16)
					var_28_1:setMatchSettings({
						ball = var_28_16.ball,
						extraTime = var_28_16.extraTime,
						matchType = var_28_16,
						fieldMarkings = var_28_16.fieldMarkings,
						rules = var_28_16.rules
					})

					var_28_2.matchType = var_28_16
					arg_28_8.hasSetMatchTypeSettings = true
				end
			else
				local var_28_17 = var_28_0:getMatchType(8)

				var_28_1:setMatchType(var_28_17)
				var_28_1:setMatchSettings({
					ball = var_28_17.ball,
					extraTime = var_28_17.extraTime,
					matchType = var_28_17,
					fieldMarkings = var_28_17.fieldMarkings,
					rules = var_28_17.rules
				})

				var_28_2.matchType = var_28_17
				arg_28_8.hasSetMatchTypeSettings = true
			end
		end
	end

	if arg_28_7.isBeAPro then
		local var_28_18 = #var_28_1:getPartyMembersSplitBySide().home ~= 0 and "home" or "away"
		local var_28_19 = var_28_1:getSideInfo(var_28_18):getMatchClub()

		arg_28_0.beAProClub = var_28_19

		if not arg_28_7.beAProPlayerId then
			arg_28_7.beAProPlayerId = var_28_19.lineup:getSpecialRole(native.EClubLineupSpecialRole.Captain)
		end

		local var_28_20 = arg_28_5:getPlayerManager():getPlayer(arg_28_7.beAProPlayerId)

		arg_28_5:playerModelUpdate(1, {
			refresh = true,
			camera = "FullBody_OutsideOfAppearance",
			rotationEnabled = false,
			draw = true,
			player = var_28_20,
			club = var_28_19,
			position = native.vec3(0.4, 0, -0.1)
		})
	end

	ASSERT(var_28_2.matchType)

	local var_28_21 = {}

	arg_28_0.menuItemParams = var_28_21

	if not GAME_CRICKET then
		ASSERT(arg_28_1)
		ASSERT(arg_28_6)
		ASSERT(arg_28_7)
		ASSERT(arg_28_8)

		var_28_21.lineupSubStateData = {
			stateMachine = arg_28_1,
			metagameModeData = arg_28_6,
			matchData = arg_28_7,
			matchSetupData = arg_28_8
		}
	end

	ASSERT(arg_28_7)
	arg_28_0:refreshMenuItems(arg_28_1, arg_28_2, arg_28_3, arg_28_4, arg_28_5, arg_28_7, arg_28_8, arg_28_6, tablex.merge(var_28_21, {
		resetStadium = arg_28_7.settingRestrictions and arg_28_7.settingRestrictions.optionsGround and true,
		defaultGround = arg_28_7.settingsInfo and arg_28_7.settingsInfo.ground,
		defaultFieldMarkings = arg_28_7.settingsInfo and arg_28_7.settingsInfo.fieldMarkings
	}))

	arg_28_0.censoringAllUGC = native.getCensorAllUGC()
end

function MatchSetupMatchSettingsState.createMenuItems(arg_29_0, arg_29_1, arg_29_2, arg_29_3, arg_29_4, arg_29_5, arg_29_6, arg_29_7, arg_29_8, arg_29_9)
	local var_29_0 = arg_29_6.matchSettingsSynchroniser
	local var_29_1 = var_29_0:getMatchSettings()
	local var_29_2 = arg_29_6.localMatchSettings
	local var_29_3 = arg_29_6.settingRestrictions

	if native.precert then
		var_29_3 = var_29_3 or {}
		var_29_3.lockedWeather = true
		var_29_3.lockedInjuries = true
		var_29_3.lockedHalfLengthNormal = true
		var_29_3.lockedHalfLengthNines = true
		var_29_3.lockedExtraTime = true
		var_29_3.lockedSinBins = true
		var_29_3.lockedCaptainsChallenge = true
		var_29_3.lockedPitchType = true
		var_29_3.lockedPitchHardness = true
		var_29_3.lockedPitchCondition = true
		var_29_3.lockedPitchCracks = true
		var_29_3.lockedLawnStriping = true
		var_29_3.lockedQuickPitchWear = true
		var_29_3.lockedTimeOfDay = true
		var_29_3.lockedCountry = true
		var_29_3.lockedAdvertisingHoardings = true
		var_29_3.lockedReferee = true
		var_29_3.lockedBall = true
		var_29_3.lockedLineupSelect = true
		var_29_3.lockedCommentaryPair = true
		var_29_3.lockedRefereePair = true
	elseif native.publicfacing then
		var_29_3 = var_29_3 or {}
		var_29_3.lockedInjuries = true
		var_29_3.lockedAdvertisingHoardings = true
		var_29_3.lockedReferee = true
	end

	local var_29_4 = {}

	tablex.mergeInto(var_29_4, matchsettings_options.DifficultyInt)

	local var_29_5 = arg_29_2:getParty():getPrimaryPartyMember().settings

	for iter_29_0 = 1, var_29_5.gameplayModifiers_count do
		local var_29_6 = var_29_5:gameplayModifiers_get(iter_29_0)

		if var_29_6.custom then
			table.insert(var_29_4, {
				value = iter_29_0 - 1,
				label = var_29_6.name
			})
		end
	end

	local var_29_7 = var_0_26(native.Localise("Weather"), "weather", matchsettings_options.Weather)
	local var_29_8 = var_0_26(native.Localise("Injuries"), "injuries", matchsettings_options.Injuries)
	local var_29_9 = var_0_27(native.Localise("Difficulty"), var_29_4)
	local var_29_10 = var_0_29(native.Localise("MatchSettingsAccept"), {
		selectSelectsItem = true,
		acceptButton = true,
		execute = function()
			return arg_29_0:AcceptExecute(arg_29_1, arg_29_2, arg_29_3, arg_29_4, arg_29_5, var_29_0, arg_29_6, arg_29_7, arg_29_8)
		end
	})

	arg_29_7.isGrandFinal = arg_29_6.isGrandFinal and arg_29_6.isGrandFinal

	local var_29_11 = var_0_28(native.Localise("StadiumSelect"), {
		execute = function()
			return arg_29_0:transitionToStadiumSelect(arg_29_1, arg_29_2, arg_29_3, arg_29_4, arg_29_5, arg_29_7)
		end
	})
	local var_29_12 = var_0_26(native.Localise("HalfLengthNormal"), "halfLength", matchsettings_options.HalfLengthNormal)
	local var_29_13 = var_0_26(native.Localise("HalfLengthNormal"), "halfLength", matchsettings_options.HalfLengthNRLW)
	local var_29_14 = var_0_26(native.Localise("HalfLengthNines"), "halfLengthNines", matchsettings_options.HalfLengthNines)
	local var_29_15 = var_0_26(native.Localise("ExtraTime"), "extraTime", matchsettings_options.ExtraTime)
	local var_29_16 = var_0_26(native.Localise("SinBins"), "sinBinsAndSendOffsEnabled", matchsettings_options.SinBinsAndSendOffsEnabled)
	local var_29_17 = var_0_26(native.Localise("CaptainsChallenge"), "captainsChallengeEnabled", matchsettings_options.CaptainsChallengeEnabled)
	local var_29_18 = var_0_26(native.Localise("CommentaryPair"), "commentaryPair", matchsettings_options.CommentaryPair)
	local var_29_19 = var_0_26(native.Localise("RefereePair"), "refereePair", matchsettings_options.RefereePair)
	local var_29_20
	local var_29_21
	local var_29_22
	local var_29_23
	local var_29_24
	local var_29_25
	local var_29_26
	local var_29_27
	local var_29_28

	if GAME_CRICKET then
		var_29_20 = var_0_26(native.Localise("PitchType"), "pitchType", matchsettings_options.PitchType)
		var_29_21 = var_0_26(native.Localise("PitchHardness"), "pitchHardness", matchsettings_options.PitchHardness)
		var_29_22 = var_0_26(native.Localise("PitchCondition"), "pitchCondition", matchsettings_options.PitchCondition)
		var_29_23 = var_0_26(native.Localise("PitchCracks"), "pitchCracks", matchsettings_options.PitchCracks)
		var_29_24 = var_0_26(native.Localise("LawnStriping"), "lawnStriping", matchsettings_options.LawnStriping)
		var_29_25 = var_0_26(native.Localise("QuickPitchWear"), "quickPitchWear", matchsettings_options.QuickPitchWear)
	else
		var_29_27 = var_0_26(native.Localise("TimeOfDay"), "timeOfDay", matchsettings_options.TimeOfDay)
	end

	if var_0_4 then
		var_29_26 = var_0_26(native.Localise("Country"), "country", matchsettings_options.Country)
	end

	local var_29_29 = {
		native.Localise("RefereeA"),
		native.Localise("RefereeB"),
		native.Localise("RefereeC"),
		native.Localise("RefereeD")
	}
	local var_29_30
	local var_29_31
	local var_29_32
	local var_29_33
	local var_29_34
	local var_29_35
	local var_29_36
	local var_29_37
	local var_29_38
	local var_29_39
	local var_29_40
	local var_29_41
	local var_29_42
	local var_29_43
	local var_29_44
	local var_29_45
	local var_29_46
	local var_29_47
	local var_29_48
	local var_29_49
	local var_29_50
	local var_29_51
	local var_29_52
	local var_29_53

	ASSERT(arg_29_6)

	arg_29_6.stadiumIndex = arg_29_6.stadiumIndex or 1

	local var_29_54 = arg_29_5:getDlc1Enabled()

	if not var_29_3 or not var_29_3.lockedBall then
		local var_29_55
		local var_29_56 = var_29_3 and var_29_3.optionsBall

		if var_29_56 then
			var_29_55 = var_0_14(var_29_56)
		else
			local var_29_57

			if not var_29_54 then
				var_29_57 = {
					native.MatchSettingsBall.worldcup,
					native.MatchSettingsBall.worldcupwomens
				}
			end

			var_29_55 = optionmenu_aide.valueListFromEnum(native.MatchSettingsBall, {
				excludeValues = var_29_57
			})
		end

		ASSERT(var_29_55)

		var_29_30 = var_0_26(native.Localise("Ball"), "ball", var_29_55)
		var_29_30.location = native.getMiniStack()
		var_29_30.valueListAllowFail = true
	end

	if not var_29_3 or not var_29_3.lockedGrassType then
		local var_29_58 = matchsettings_options.GrassType

		if var_29_3 and var_29_3.optionsGrassType then
			var_29_58 = var_0_14(var_29_3.optionsGrassType)
		end

		var_29_32 = GAME_CRICKET and var_0_26(native.Localise("GrassType"), "grassType", var_29_58)
	end

	if var_29_2.trophyId and (not var_29_3 or not var_29_3.lockedTrophy) then
		var_29_33 = var_0_26(native.Localise("Trophy"), "trophyId", var_0_1.getTrophyValueList(), var_29_2)
	end

	if not var_29_3 or not var_29_3.lockedWeather then
		var_29_36 = var_29_7
	end

	if var_29_20 and (not var_29_3 or not var_29_3.lockedPitchType) then
		var_29_39 = var_29_20
	end

	if not var_29_3 or not var_29_3.lockedPitchHardness then
		var_29_40 = var_29_21
	end

	if not var_29_3 or not var_29_3.lockedPitchCondition then
		var_29_41 = var_29_22
	end

	if not var_29_3 or not var_29_3.lockedPitchCracks then
		var_29_42 = var_29_23
	end

	if not var_29_3 or not var_29_3.lockedLawnStriping then
		var_29_43 = var_29_24
	end

	if not var_29_3 or not var_29_3.lockedQuickPitchWear then
		var_29_44 = var_29_25
	end

	if not var_29_3 or not var_29_3.lockedCountry then
		var_29_46 = var_29_26
	end

	if not var_29_3 or not var_29_3.lockedCommentaryPair then
		var_29_47 = var_29_18
	end

	if not var_29_3 or not var_29_3.lockedRefereePair then
		var_29_48 = var_29_19
	end

	if var_29_27 and (not var_29_3 or not var_29_3.lockedTimeOfDay) then
		var_29_35 = var_29_27
	end

	if not var_29_3 or not var_29_3.lockedLineupSelect then
		ASSERT(arg_29_9.lineupSubStateData)

		var_29_49 = (arg_29_6.isBeAPro and var_0_30 or var_0_28)(native.Localise("MatchSettingsManageLineup"), {
			selectSelectsItem = true,
			execute = function()
				return arg_29_0:buttonExecute(arg_29_2, arg_29_3, arg_29_4, arg_29_5, MatchSettingsLineupSelectSubstate, arg_29_9.lineupSubStateData)
			end
		})

		if arg_29_6.isBeAPro then
			var_29_49.dataNVM = NVMBeAProButton(arg_29_5:getPlayerManager():getPlayer(arg_29_6.beAProPlayerId), arg_29_0.beAProClub)
		end
	end

	if not var_29_3 or not var_29_3.lockedAccept then
		var_29_50 = var_29_10
	end

	if not var_29_3 or not var_29_3.lockedHalfLength then
		local var_29_59 = var_29_1.matchType
		local var_29_60 = var_29_59.categorisedMatchType == native.EMatchType.MT_Nines

		var_29_51 = var_29_60 and var_29_14 or var_29_12

		if var_29_59.id == 6 then
			var_29_51 = var_29_13
		end

		if arg_29_9.resetHalfLength then
			local var_29_61
			local var_29_62 = var_29_60 and 2 or 2

			ASSERT(var_29_62)
			var_29_51.setValue(var_29_62, arg_29_0.menuItems[6].valueList, var_29_0)
		end
	end

	if not var_29_3 or not var_29_3.lockedInjuries then
		var_29_37 = var_29_8
	end

	if not var_29_3 or not var_29_3.lockedFieldMarkings then
		var_29_31 = var_0_32(arg_29_6, arg_29_9, var_29_54)
	end

	if not var_29_3 or not var_29_3.lockedExtraTime then
		var_29_34 = var_29_15
	end

	if not var_29_3 or not var_29_3.lockedSinBins then
		var_29_52 = var_29_16
	end

	if not var_29_3 or not var_29_3.lockedCaptainsChallenge then
		var_29_53 = var_29_17
	end

	local var_29_63 = arg_29_5:getClubManager()
	local var_29_64 = arg_29_5:getPlayerManager()

	arg_29_0.settingRestrictions = var_29_3

	if not var_29_3 or not var_29_3.lockedMatchType then
		local var_29_65 = arg_29_5:getMatchTypeManager():getMatchSettingsMatchTypeValueList()

		table.remove(var_29_65, 4)
		table.remove(var_29_65, 3)

		var_29_38 = var_0_13(native.Localise("MatchType"), "matchType", var_29_65, {
			getValue = function(arg_33_0, arg_33_1)
				local var_33_0 = arg_33_1:getMatchSettings().matchType
				local var_33_1 = 1

				for iter_33_0, iter_33_1 in ipairs(arg_33_0) do
					if iter_33_1.value.name == var_33_0.name then
						return iter_33_0 - 1
					end
				end

				ASSERT(false)

				return 1
			end,
			setValue = function(arg_34_0, arg_34_1, arg_34_2)
				local var_34_0 = arg_34_1[arg_34_0 + 1].value
				local var_34_1 = arg_34_2:getMatchSettings()
				local var_34_2 = var_34_1.matchType

				var_34_1.matchType = var_34_0

				if var_34_2.categorisedMatchType ~= var_34_0.categorisedMatchType then
					arg_29_0:changeMatchClubLineupIfRequired(arg_29_2, arg_29_5, "home", var_34_0.categorisedMatchType, arg_34_2, var_29_63, var_29_64)
					arg_29_0:changeMatchClubLineupIfRequired(arg_29_2, arg_29_5, "away", var_34_0.categorisedMatchType, arg_34_2, var_29_63, var_29_64)
				end
			end
		})
	end

	if GAME_CRICKET and (not var_29_3 or not var_29_3.lockedStartTime) then
		local var_29_66 = "startTime"

		var_29_45 = var_0_13(native.Localise("StartTime"), var_29_66, nil, {
			getValue = function(arg_35_0)
				return arg_35_0:getMatchSettings()[var_29_66]
			end,
			setValue = function(arg_36_0, arg_36_1)
				arg_36_1:setStartTimeAndIndex(arg_36_0)
			end,
			valueListGetFn = function(arg_37_0)
				return (arg_37_0:getMatchSettings():getMatchSettingsStartTimeValueList())
			end
		})
	end

	local var_29_67 = {}

	if var_29_50 then
		table.insert(var_29_67, var_29_50)
	end

	if arg_29_6.isBeAPro and var_29_49 then
		table.insert(var_29_67, var_29_49)
	end

	if var_29_46 then
		table.insert(var_29_67, var_29_46)
	end

	if arg_29_8 and not arg_29_8.career then
		table.insert(var_29_67, var_29_11)
	end

	if var_29_38 then
		table.insert(var_29_67, var_29_38)
	end

	if not var_29_3 or not var_29_3.lockedDifficulty then
		table.insert(var_29_67, var_29_9)
	end

	if not arg_29_6.isBeAPro and var_29_49 then
		table.insert(var_29_67, var_29_49)
	end

	if var_29_51 then
		table.insert(var_29_67, var_29_51)
	end

	if var_29_30 then
		table.insert(var_29_67, var_29_30)
	end

	if var_29_31 then
		table.insert(var_29_67, var_29_31)
	end

	if var_29_34 then
		table.insert(var_29_67, var_29_34)
	end

	if var_29_52 then
		table.insert(var_29_67, var_29_52)
	end

	if var_29_53 then
		table.insert(var_29_67, var_29_53)
	end

	if var_29_45 then
		table.insert(var_29_67, var_29_45)
	end

	if var_29_39 then
		table.insert(var_29_67, var_29_39)
	end

	if var_29_40 then
		table.insert(var_29_67, var_29_40)
	end

	if var_29_41 then
		table.insert(var_29_67, var_29_41)
	end

	if var_29_42 then
		table.insert(var_29_67, var_29_42)
	end

	if var_29_43 then
		table.insert(var_29_67, var_29_43)
	end

	if var_29_44 then
		table.insert(var_29_67, var_29_44)
	end

	if var_29_36 then
		table.insert(var_29_67, var_29_36)
	end

	if var_29_35 then
		table.insert(var_29_67, var_29_35)
	end

	if var_29_37 then
		table.insert(var_29_67, var_29_37)
	end

	if var_29_33 then
		table.insert(var_29_67, var_29_33)
	end

	if var_29_32 then
		table.insert(var_29_67, var_29_32)
	end

	if native.debughooks and (not var_29_3 or not var_29_3.lockedAdvertisingHoardings) then
		local var_29_68 = var_0_26(native.Localise("AdvertisingHoardings"), "advertisingHoardings", matchsettings_options.AdvertisingHoardings)

		var_29_68.label = string.format("[debug] %s", native.Localise("AdvertisingHoardings"))

		table.insert(var_29_67, var_29_68)
	end

	if var_29_47 then
		table.insert(var_29_67, var_29_47)
	end

	if var_29_48 then
		table.insert(var_29_67, var_29_48)
	end

	if var_29_2.refereeIds and (not var_29_3 or not var_29_3.lockedReferee) then
		local var_29_69 = var_29_2.refereeIds
		local var_29_70 = arg_29_5:getRefereeManager()

		for iter_29_1, iter_29_2 in ipairs(var_29_69) do
			local var_29_71 = var_29_70:getReferee(iter_29_2)

			table.insert(var_29_67, {
				editable = true,
				label = var_29_29[iter_29_1],
				displayType = optionmenu_aide.DisplayTypes.Value,
				editType = optionmenu_aide.EditTypes.CustomLeftRight,
				getValue = function(arg_38_0)
					return var_29_71.fullName
				end,
				setValue = function(arg_39_0, arg_39_1)
					var_29_69[iter_29_1] = arg_39_0
				end,
				editAdjustFn = function(arg_40_0, arg_40_1, arg_40_2)
					return var_29_70:getRelativeNPCIdOfType(iter_29_2, native.CNpcType.Referee, arg_29_6.sex, arg_40_1)
				end
			})
		end
	end

	return var_29_67
end

function MatchSetupMatchSettingsState.buttonExecute(arg_41_0, arg_41_1, arg_41_2, arg_41_3, arg_41_4, arg_41_5, arg_41_6)
	arg_41_5 = arg_41_5()
	arg_41_0.subState = arg_41_5

	arg_41_5:enter(arg_41_1, arg_41_2, arg_41_3, arg_41_4, arg_41_6)
end

function MatchSetupMatchSettingsState.refreshMenuItems(arg_42_0, arg_42_1, arg_42_2, arg_42_3, arg_42_4, arg_42_5, arg_42_6, arg_42_7, arg_42_8, arg_42_9)
	local var_42_0 = arg_42_6.matchSettingsSynchroniser

	if not arg_42_0.menuViewModel then
		local var_42_1

		arg_42_0.menuViewModel, var_42_1 = nvm_preMatchSettings.NVMPreMatchSettings(arg_42_2, arg_42_5, arg_42_6), arg_42_6.match ~= nil
	end

	arg_42_0.menuItems, arg_42_0.stadiumList = arg_42_0:createMenuItems(arg_42_1, arg_42_2, arg_42_3, arg_42_4, arg_42_5, arg_42_6, arg_42_7, arg_42_8, arg_42_9)

	if not arg_42_0.menuView then
		local var_42_2 = arg_42_2:getNoesis():loadViewWithVM("Workspace/Views/General/paPreMatchSettingsView", arg_42_0.menuViewModel, native.ENoesisViewManagerLayer.PRE_SCENE, native.CNoesisViewManager.DefaultPriority)

		arg_42_0.menuViewModel.CompetitionSeparatorBarVisible = arg_42_0.competitionLogo ~= nil

		arg_42_0.menuViewModel.OptionMenuNVM:populateMenu(arg_42_0.menuItems, var_42_0)

		arg_42_0.menuViewModel.OptionMenuNVM.HeadingText = native.Localise("MatchSettings")
		arg_42_0.menuView = var_42_2
	else
		arg_42_0.menuViewModel.OptionMenuNVM:populateMenu(arg_42_0.menuItems, var_42_0)
	end

	arg_42_0.cachedMatchTypeName = arg_42_6.matchSettingsSynchroniser:getMatchSettings().matchType.name

	arg_42_0:refreshGroundInfo(arg_42_2, arg_42_5, var_42_0)
	arg_42_0:UpdateDateTimeText(arg_42_6)
end

function MatchSetupMatchSettingsState.reconstruct(arg_43_0, arg_43_1, arg_43_2, arg_43_3, arg_43_4, arg_43_5, arg_43_6, arg_43_7, arg_43_8, arg_43_9)
	local var_43_0 = arg_43_6.matchSettingsSynchroniser

	arg_43_0.menuView:release()
	arg_43_0.menuViewModel:dispose()

	local var_43_1

	arg_43_0.menuViewModel, var_43_1 = nvm_preMatchSettings.NVMPreMatchSettings(arg_43_2, arg_43_5, arg_43_6), arg_43_6.match ~= nil
	arg_43_0.menuItems, arg_43_0.stadiumList = arg_43_0:createMenuItems(arg_43_1, arg_43_2, arg_43_3, arg_43_4, arg_43_5, arg_43_6, arg_43_7, arg_43_8, arg_43_9)

	local var_43_2 = arg_43_2:getNoesis():loadViewWithVM("Workspace/Views/General/paPreMatchSettingsView", arg_43_0.menuViewModel, native.ENoesisViewManagerLayer.PRE_SCENE, native.CNoesisViewManager.DefaultPriority)

	arg_43_0.menuViewModel.CompetitionSeparatorBarVisible = arg_43_0.competitionLogo ~= nil

	arg_43_0.menuViewModel.OptionMenuNVM:populateMenu(arg_43_0.menuItems, var_43_0)

	arg_43_0.menuViewModel.OptionMenuNVM.HeadingText = native.Localise("MatchSettings")
	arg_43_0.menuView = var_43_2
	arg_43_0.cachedMatchTypeName = arg_43_6.matchSettingsSynchroniser:getMatchSettings().matchType.name
end

function MatchSetupMatchSettingsState.update(arg_44_0, arg_44_1, arg_44_2, arg_44_3, arg_44_4, arg_44_5, arg_44_6, arg_44_7, arg_44_8, arg_44_9, arg_44_10)
	if arg_44_0.exitAt then
		return arg_44_3 >= arg_44_0.exitAt
	end

	arg_44_0.menuViewModel:update(arg_44_2, arg_44_4)

	if arg_44_6:updateBlockingMixins(arg_44_2, arg_44_3, arg_44_4, arg_44_5, arg_44_7) then
		return
	end

	if arg_44_0.menuViewModel.OptionMenuNVM.toolTip and arg_44_0.menuViewModel.OptionMenuNVM.toolTipText then
		arg_44_6:addTooltip(nil, arg_44_0.menuViewModel.OptionMenuNVM.toolTip, native.Localise(arg_44_0.menuViewModel.OptionMenuNVM.toolTipText), 1)
	end

	local var_44_0 = arg_44_9.matchSettingsSynchroniser

	if arg_44_0.homeDecal and arg_44_0.homeDecal:isLoaded() then
		arg_44_0.menuViewModel.HomeLogo = native.CNoesisTextureSource(arg_44_0.homeDecal)

		arg_44_0.homeDecal:unload()

		arg_44_0.homeDecal = nil
	end

	if arg_44_0.awayDecal and arg_44_0.awayDecal:isLoaded() then
		arg_44_0.menuViewModel.AwayLogo = native.CNoesisTextureSource(arg_44_0.awayDecal)

		arg_44_0.awayDecal:unload()

		arg_44_0.awayDecal = nil
	end

	if arg_44_0.competitionLogo and arg_44_0.competitionLogo:isLoaded() then
		arg_44_0.menuViewModel.CompetitionLogo = native.CNoesisTextureSource(arg_44_0.competitionLogo)

		arg_44_0.competitionLogo:unload()

		arg_44_0.competitionLogo = nil
	end

	if arg_44_3 < arg_44_0.allowInputAfter or not arg_44_6:getInputAllowed() then
		return
	end

	if arg_44_0.censoringAllUGC ~= native.getCensorAllUGC() then
		arg_44_0.censoringAllUGC = not arg_44_0.censoringAllUGC

		arg_44_0:refreshMenuItems(arg_44_1, arg_44_2, arg_44_3, arg_44_5, arg_44_6, arg_44_9, arg_44_10, arg_44_8, tablex.merge(arg_44_0.menuItemParams, {
			resetStadium = true
		}))

		return
	end

	if arg_44_0.subState then
		arg_44_0.subState:update(arg_44_2, arg_44_3, arg_44_4, arg_44_5, arg_44_6, arg_44_7)

		if arg_44_0.menuViewModel then
			arg_44_0.menuViewModel.Visible = false
		end

		return
	elseif not arg_44_0.subState and not arg_44_0.menuViewModel.Visible then
		arg_44_0.menuViewModel.Visible = true
	end

	arg_44_0:UpdateDateTimeText(arg_44_9)

	local var_44_1 = arg_44_0.menuItemParams

	if (not arg_44_0.settingRestrictions or not arg_44_0.settingRestrictions.lockedMatchType) and not native.precert and not native.publicfacing then
		arg_44_6:addTooltip(nil, var_0_2.Start, native.Localise("LoadPreset"))

		local var_44_2 = arg_44_8.partyMember

		if arg_44_6:checkForRelease(var_44_2, var_0_2.Start) then
			local var_44_3 = arg_44_6:getMatchTypeManager():getMatchSettingsMatchTypeValueList()

			arg_44_6:playSound("Select")

			arg_44_0.menuItemParams.resetHalfLength = true

			table.remove(var_44_3, 4)
			table.remove(var_44_3, 3)
			arg_44_6:blockingAlert(arg_44_2, arg_44_3, {
				canCancel = true,
				text = native.Localise("LoadPreset"),
				options = var_44_3,
				input = var_44_2:getInput(),
				onSelected = function(arg_45_0, arg_45_1, arg_45_2, arg_45_3)
					if arg_45_2 and arg_45_2.value then
						ASSERT(var_44_0)
						var_44_0:setMatchType(arg_45_2.value)
						var_44_0:setMatchSettings({
							ball = arg_45_2.value.ball,
							extraTime = arg_45_2.value.extraTime,
							matchType = arg_45_2.value,
							halfLength = arg_45_2.value.halfLength or native.CGameConfig.HALF_LENGTH_REAL_TIME,
							fieldMarkings = arg_45_2.value.fieldMarkings,
							rules = arg_45_2.value.rules
						})
						arg_44_0:reconstruct(arg_44_1, arg_45_0, arg_45_1, arg_44_5, arg_44_6, arg_44_9, arg_44_10, arg_44_8, var_44_1)
					end
				end
			})
		end
	end

	if arg_44_0.cachedMatchTypeName ~= arg_44_9.matchSettingsSynchroniser:getMatchSettings().matchType.name then
		arg_44_0.menuItemParams.resetHalfLength = true

		local var_44_4 = arg_44_0.menuViewModel.OptionMenuNVM.OptionCollection:getComponent(6)
	end

	local var_44_5 = arg_44_2:getParty()
	local var_44_6 = arg_44_2:getInputControlDistributor():getControlManager(native.EInputControlFocusLevel.Game)
	local var_44_7 = arg_44_0.dropDownArea

	arg_44_6:addTooltip(nil, var_0_2.Decline, native.Localise("Back"), 20)

	if arg_44_6:checkForRelease(var_44_5, var_0_2.Decline) then
		for iter_44_0, iter_44_1 in ipairs(sidehelper.sideStrings) do
			var_44_0:setClubSelectionMade(iter_44_1, false)
		end

		arg_44_6:playSound("Back")

		local var_44_8 = arg_44_10.stateFactoryMap.SideSetup

		arg_44_9.beAProPlayerId = nil
		arg_44_9.removeView = true

		if var_44_8 then
			arg_44_1:changeState(var_44_8(), arg_44_2, arg_44_3, arg_44_5, arg_44_6, arg_44_8, arg_44_9, arg_44_10, true)
		else
			arg_44_9.returnToTop(arg_44_3, true)
		end

		return
	end
end

function MatchSetupMatchSettingsState.render(arg_46_0, arg_46_1, arg_46_2, arg_46_3, arg_46_4)
	if arg_46_0.subState then
		arg_46_0.subState:render(arg_46_1, arg_46_2, arg_46_3, arg_46_4)

		return
	end
end

function MatchSetupMatchSettingsState.exit(arg_47_0, arg_47_1, arg_47_2, arg_47_3, arg_47_4, arg_47_5, arg_47_6, arg_47_7)
	if arg_47_0.subState then
		arg_47_0.subState:exit(arg_47_1, arg_47_2, arg_47_3, arg_47_4)
	end

	if arg_47_0.menuView then
		arg_47_0.menuView:release()

		arg_47_0.menuView = nil
	end

	if arg_47_0.menuViewModel then
		arg_47_0.menuViewModel:dispose()

		arg_47_0.menuViewModel = nil
	end

	ASSERT(arg_47_5)

	if arg_47_0.homeDecal then
		arg_47_0.homeDecal:unload()

		arg_47_0.homeDecal = nil
	end

	if arg_47_0.awayDecal then
		arg_47_0.awayDecal:unload()

		arg_47_0.awayDecal = nil
	end

	if arg_47_0.competitionLogo then
		arg_47_0.competitionLogo:unload()

		arg_47_0.competitionLogo = nil
	end

	if arg_47_0.viewModel then
		arg_47_0.viewModel:dispose()

		arg_47_0.viewModel = nil
	end

	if arg_47_0.view then
		arg_47_0.view:release()

		arg_47_0.view = nil
	end

	if arg_47_0.stadiumTexture then
		arg_47_0.stadiumTexture:unload()

		arg_47_0.stadiumTexture = nil
	end

	arg_47_4:playerModelUpdate(1, {
		draw = false
	})
end

function MatchSetupMatchSettingsState.refreshGroundInfo(arg_48_0, arg_48_1, arg_48_2, arg_48_3)
	return
end

function MatchSetupMatchSettingsState.transitionToStadiumSelect(arg_49_0, arg_49_1, arg_49_2, arg_49_3, arg_49_4, arg_49_5, arg_49_6)
	arg_49_1:changeState(matchsetup_stadium_select.MatchSetupStadiumSelect(), arg_49_2, arg_49_3, arg_49_4, arg_49_5, arg_49_6)
end

function MatchSetupMatchSettingsState.AcceptExecute(arg_50_0, arg_50_1, arg_50_2, arg_50_3, arg_50_4, arg_50_5, arg_50_6, arg_50_7, arg_50_8, arg_50_9)
	local var_50_0 = arg_50_6:getMatchSettings()

	arg_50_7.removeView = true

	local var_50_1 = var_50_0.ground
	local var_50_2 = var_50_0.groundId
	local var_50_3 = var_50_0.groundSharingId
	local var_50_4 = var_50_0.matchType

	arg_50_6:setMatchType(var_50_4)
	arg_50_6:setMatchSettings({
		ground = var_50_1,
		groundId = var_50_2,
		groundSharingId = var_50_3
	})

	for iter_50_0, iter_50_1 in ipairs(sidehelper.sideStrings) do
		local var_50_5 = sidehelper[iter_50_1]
		local var_50_6 = arg_50_6:getSideInfo(iter_50_1)
		local var_50_7 = var_50_6.matchClubSerialisable.matchClub.lineup
		local var_50_8 = var_50_7.category
		local var_50_9 = native.CClubLineupDefintions.getLineupSizeMax(var_50_8)

		if var_50_7.playerCount ~= var_50_9 then
			local var_50_10 = var_50_4.categorisedMatchType
			local var_50_11 = var_50_6.localClub

			var_50_11:create9sLineupFromNormalLineupIfRequired()

			local var_50_12 = var_50_11:getDefaultLineupIndex(var_50_10)
			local var_50_13 = var_50_11:getLineup(var_50_12)
			local var_50_14 = arg_50_5:getPlayerManager()
			local var_50_15 = arg_50_9.career

			arg_50_6:updateClubLineupAndSubstitutes(iter_50_1, var_50_13, var_50_4)
		end
	end

	local var_50_16 = arg_50_7.usingLineupScreen and arg_50_8.stateFactoryMap.LineupSetup

	var_50_16 = var_50_16 or arg_50_8.stateFactoryMap.ObjectiveSetup
	var_50_16 = var_50_16 or arg_50_8.stateFactoryMap.Lockdown

	ASSERT(var_50_16)
	arg_50_5:playSound("Play")
	arg_50_1:changeState(var_50_16(), arg_50_2, arg_50_3, arg_50_4, arg_50_5, arg_50_9, arg_50_7, arg_50_8, arg_50_6)
end

function MatchSetupMatchSettingsState.UpdateDateTimeText(arg_51_0, arg_51_1)
	local var_51_0 = arg_51_1.matchSettingsSynchroniser:getMatchSettings()
	local var_51_1 = var_51_0.timeOfDay == native.MatchSettingsTimeOfDay.random
	local var_51_2 = var_51_1 and "RANDOM" or timeofday_config.matchStartTimes[tostring(var_51_0.timeOfDay)]
	local var_51_3 = var_51_1 and "" or "00"
	local var_51_4 = arg_51_1.match ~= nil
	local var_51_5 = arg_51_1.match
	local var_51_6 = var_51_4 and "" or stringFormatT(var_51_1 and "%s" or "%s:%s", var_51_2, var_51_3)

	if arg_51_0.menuViewModel.TimeString ~= var_51_6 then
		arg_51_0.menuViewModel.TimeString = var_51_6
	end

	local var_51_7 = var_51_4 and tostring(var_51_5.date) or arg_51_0.fallbackDate.dateString

	if arg_51_0.menuViewModel.DateString ~= var_51_7 then
		arg_51_0.menuViewModel.DateString = var_51_7
	end
end

function MatchSetupMatchSettingsState.changeMatchClubLineupIfRequired(arg_52_0, arg_52_1, arg_52_2, arg_52_3, arg_52_4, arg_52_5, arg_52_6, arg_52_7)
	local var_52_0 = arg_52_5.lobbyService.lobbyObjects[arg_52_3]:getMatchClub()
	local var_52_1 = var_52_0.lineup
	local var_52_2 = arg_52_6:getClub(var_52_0.id)
	local var_52_3 = var_52_2:getDefaultLineupIndex(arg_52_4)
	local var_52_4 = var_52_2:getLineup(var_52_3)

	if var_52_4.playerCount ~= var_52_1.playerCount then
		arg_52_5:updateClubLineup(arg_52_3, var_52_4, var_52_2, arg_52_7)
	end
end
