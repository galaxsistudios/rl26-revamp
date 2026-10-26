import("app.academy.editassistant_helper")
import("app.alert.alert_aide")
import("app.frontend.tooltip_mixin")
import("app.sharing.sharing_searchtags_aide")
import("app.save.save_aide")
import("core.foundation.stringx")
import("core.foundation.tablex")
import("design.academy_config")
import("design.characters.assetmap")
import("design.matchtypesettings_config")
import("intermediatelua.convant.icons")
import("intermediatelua.data.creator")

local var_0_0 = assetmap.AssetMapItems
local var_0_1 = assetmap.getItemByGuid
local var_0_2 = assetmap.getItemByGuidName
local var_0_3 = academy_config.FeaturedPlayer
local var_0_4 = academy_config.SlowDownFactor
local var_0_5 = icons.Clubs
local var_0_6 = icons.ClubsNoDlc
local var_0_7 = native.EOnDiscLeagues
local var_0_8 = native.EClubLineupCategory
local var_0_9 = var_0_8.LeagueMatch
local var_0_10 = var_0_8.NinesMatch
local var_0_11 = var_0_8.NRL2026Match
local var_0_12 = native.InputTypes
local var_0_13 = native.TextAlign
local var_0_14 = native.DisplayableAspectsOfPlayer
local var_0_15 = VERIFY(sharing_searchtags_aide.Tags)
local var_0_16 = VERIFY(save_aide.addDirtySaveHelper)
local var_0_17 = GAME_RUGBY
local var_0_18 = native.Localise("LicensedPlayerCanOnlyBeLinkedToSelf")

ManageSquadInputs = {
	AddPlayerInput = var_0_12.RB,
	DeletePlayerInput = var_0_12.LB
}
VisualConfigSets = {
	PlayerDefault = {
		currentHeadwearType = "none",
		currentArmwearType = "none",
		overrideHandedness = "",
		currentLegwearType = "none",
		currentEyewearType = "none",
		currentHandwearType = "none"
	},
	RefereeDefault = {}
}
HelpStr = native.Localise("Help")

local var_0_19 = matchtypesettings_config.SettingKeyStringMap
local var_0_20 = matchtypesettings_config.SettingKeyToMatchTypeProperty
local var_0_21 = editassistant_helper.leftInputDetected
local var_0_22 = editassistant_helper.rightInputDetected
local var_0_23 = editassistant_helper.upInputDetected
local var_0_24 = editassistant_helper.downInputDetected
local var_0_25 = editassistant_helper.rightStickUpInputDetected
local var_0_26 = editassistant_helper.rightStickDownInputDetected
local var_0_27 = editassistant_helper.l3InputDetected
local var_0_28 = editassistant_helper.r3InputDetected
local var_0_29 = editassistant_helper.lbInputDown
local var_0_30 = editassistant_helper.rbInputDown
local var_0_31 = 150

NameAndClubColumns = {
	{
		var_0_14.PlayerOverall:toInt(),
		var_0_13.Centre,
		55,
		true,
		native.Localise("OverallAbbr")
	},
	{
		var_0_14.PlayerFullName:toInt(),
		var_0_13.Left,
		310,
		true,
		native.Localise("Name")
	},
	{
		var_0_14.AllClubNames:toInt(),
		var_0_13.Left,
		200,
		false,
		native.Localise("Club")
	},
	{
		var_0_14.PlayerPrimaryRoleColourAndAbbr:toInt(),
		var_0_13.Centre,
		90,
		true,
		native.Localise("Role")
	},
	{
		var_0_14.Sex:toInt(),
		var_0_13.Centre,
		50,
		true,
		native.Localise("Sex")
	}
}
NameAndClubColumnsInitialSort = 2
NameAndClubRosterColumns = {
	{
		var_0_14.PlayerOverall:toInt(),
		var_0_13.Centre,
		100,
		true,
		native.Localise("OverallAbbr")
	},
	{
		var_0_14.PlayerFullName:toInt(),
		var_0_13.Left,
		450,
		true,
		native.Localise("Name")
	},
	{
		var_0_14.PlayerPrimaryRoleColourAndAbbr:toInt(),
		var_0_13.Left,
		55,
		true,
		native.Localise("Role")
	}
}
NameAndClubRosterColumnsInitialSort = 2
NameClubAndOverallColumns = {
	{
		var_0_14.PlayerOverall:toInt(),
		var_0_13.Centre,
		55,
		true,
		native.Localise("OverallAbbr")
	},
	{
		var_0_14.PlayerFullName:toInt(),
		var_0_13.Left,
		240,
		true,
		native.Localise("Name")
	},
	{
		var_0_14.ClubNickname:toInt(),
		var_0_13.Left,
		180,
		true,
		native.Localise("Club")
	},
	{
		var_0_14.PlayerPrimaryRoleColourAndAbbr:toInt(),
		var_0_13.Left,
		90,
		true,
		native.Localise("Role")
	},
	{
		var_0_14.CareerPlayerAge:toInt(),
		var_0_13.Centre,
		70,
		true,
		native.Localise("Age")
	}
}
NameClubAndOverallColumnsInitialSort = 1
NameAndStrengthsColumns = {
	{
		var_0_14.PlayerOverall:toInt(),
		var_0_13.Centre,
		80,
		true,
		native.Localise("OverallAbbr")
	},
	{
		var_0_14.PlayerFullName:toInt(),
		var_0_13.Left,
		530,
		true,
		native.Localise("Name")
	}
}
NameAndStrengthsColumnsInitialSort = 2
OfflinePlayerDescription = {}

function currentlyUsingKeyboard(arg_1_0)
	return not tooltip_mixin.getAreGamepadTooltipsActive(arg_1_0)
end

function createDecalData(arg_2_0, arg_2_1)
	ASSERT(arg_2_0)

	local var_2_0 = {}
	local var_2_1 = {}

	return {
		canEdit = true,
		callstack = native.getLuaCallstack(),
		decal = arg_2_0,
		sharingInformation = arg_2_0.sharing,
		partyMember = arg_2_1,
		searchTagInfo = var_0_15,
		justCommittedToAChange = nop,
		undoList = var_2_0,
		redoList = var_2_1,
		undoChange = function()
			table.insert(var_2_1, {})
		end,
		redoChange = function()
			table.insert(var_2_0, {})
		end,
		getUndoListSizes = function()
			return #var_2_0
		end,
		getRedoListSizes = function()
			return #var_2_1
		end
	}
end

function createLevelMenuData(arg_7_0, arg_7_1, arg_7_2, arg_7_3)
	local var_7_0 = {
		help = "HelpVenueCreator",
		callstack = native.getLuaCallstack(),
		level = arg_7_1,
		sharingInformation = VERIFY(arg_7_1.sharing),
		partyMember = VERIFY(arg_7_2),
		searchTagInfo = var_0_15,
		undoChange = nop,
		redoChange = nop,
		getUndoListSizes = function()
			return 0
		end,
		getRedoListSizes = function()
			return 0
		end
	}

	if arg_7_3 then
		tablex.mergeInto(var_7_0, arg_7_3)
	end

	var_0_16(var_7_0, arg_7_0, arg_7_2, false, false, false, true)

	return var_7_0
end

function DefaultAdditionalLabelFn(arg_10_0, arg_10_1, arg_10_2)
	if arg_10_2.getItemEnabledFn and not arg_10_2.getItemEnabledFn(arg_10_0, arg_10_1, arg_10_2) or not arg_10_1.getCurrentConfig then
		return ""
	end

	local var_10_0 = arg_10_1.getCurrentConfig()
	local var_10_1 = arg_10_2.optionName
	local var_10_2 = var_10_0:getOption(var_10_1)
	local var_10_3 = arg_10_2.valueList or getAllowableItems(var_10_0, arg_10_2, arg_10_0)
	local var_10_4 = 0
	local var_10_5

	for iter_10_0, iter_10_1 in ipairs(var_10_3) do
		if iter_10_1.guid == var_10_2 then
			var_10_4 = iter_10_0
			var_10_5 = iter_10_1

			break
		end
	end

	if var_10_5 and var_10_5.uiName then
		return native.Localise(var_10_5.uiName)
	end

	return string.format("#%d", var_10_4)
end

function DefaultGetItemEnabledFn(arg_11_0, arg_11_1, arg_11_2)
	if arg_11_1.getCurrentConfig then
		if arg_11_2.sliders then
			return true
		end

		local var_11_0 = arg_11_1.getCurrentConfig()

		return #getAllowableItems(var_11_0, arg_11_2, arg_11_0) > 1
	else
		return false
	end
end

function DefaultSetVisualFunction(arg_12_0, arg_12_1, arg_12_2)
	if arg_12_2.getCurrentConfig and arg_12_2.getCurrentConfig().configType == "player" then
		arg_12_0:playerModelUpdate(1, {
			characterVisualOptions = VisualConfigSets.PlayerDefault
		})
	end
end

function getAllowableItems(arg_13_0, arg_13_1, arg_13_2)
	local function var_13_0()
		local var_14_0 = arg_13_1.baseCategory
		local var_14_1 = arg_13_1.baseCategoryMap or var_14_0
		local var_14_2 = arg_13_1.optionMap
		local var_14_3 = var_0_0[var_14_2]

		if not var_14_0 then
			ASSERT(var_14_3)

			return var_14_3.item_setup, var_14_3
		end

		local var_14_4 = var_0_0[var_14_1]

		ASSERT(var_14_4)

		local var_14_5 = arg_13_0:getOption(var_14_0)
		local var_14_6 = {}
		local var_14_7 = var_0_1(var_14_4, var_14_5)

		if not var_14_7 then
			return var_14_6, var_14_3
		end

		local var_14_8 = var_14_4 and var_14_4.permutationMap and var_14_4.permutationMap[var_14_2]

		if var_14_8 then
			local var_14_9 = var_14_7.permutations[var_14_2]

			string.gsub(var_14_9, ".", function(arg_15_0)
				table.insert(var_14_6, var_0_1(var_14_3, var_14_8[arg_15_0]))
			end)

			return var_14_6, var_14_3
		end

		local var_14_10 = var_14_4 and var_14_4.subOptions and var_14_4.subOptions[var_14_2]

		if var_14_10 then
			return var_14_10, var_14_3
		end

		ASSERT(var_14_7.variants)

		local var_14_11 = var_0_0[var_14_7.variants]

		return var_14_11.item_setup, var_14_11
	end

	local var_13_1
	local var_13_2

	if arg_13_1.getUnfilteredList then
		var_13_1, var_13_2 = arg_13_1.getUnfilteredList(arg_13_0, arg_13_1, arg_13_2)
	else
		var_13_1, var_13_2 = var_13_0()
	end

	local var_13_3 = assetmap.filterBySex(var_13_1, arg_13_0:getOption("sex"))
	local var_13_4 = arg_13_1.filterFn

	if var_13_4 then
		local var_13_5 = {}

		for iter_13_0, iter_13_1 in ipairs(var_13_3) do
			if var_13_4(iter_13_1, arg_13_0, arg_13_2) then
				table.insert(var_13_5, iter_13_1)
			end
		end

		var_13_3 = var_13_5
	end

	return var_13_3, var_13_2
end

function ensureOptionIsValid(arg_16_0, arg_16_1, arg_16_2, arg_16_3)
	local var_16_0 = getAllowableItems(arg_16_0, arg_16_3, arg_16_1)
	local var_16_1

	if arg_16_3.getValue then
		var_16_1 = arg_16_3.getValue(arg_16_1, arg_16_2, arg_16_3)
	else
		var_16_1 = arg_16_0:getOption(arg_16_3.optionName)
	end

	ASSERT(#var_16_0 > 0)

	for iter_16_0, iter_16_1 in ipairs(var_16_0) do
		if iter_16_1.guid == var_16_1 then
			return
		end
	end

	local var_16_2 = var_16_0[1].guid

	if arg_16_3.setValue then
		arg_16_3.setValue(var_16_2, arg_16_1, arg_16_2, arg_16_3)
	else
		arg_16_0:setOption(arg_16_3.optionName, var_16_2)
	end
end

function setupEditAssistant(arg_17_0, arg_17_1, arg_17_2, arg_17_3, arg_17_4, arg_17_5, arg_17_6)
	ASSERT(not arg_17_6)
	ASSERT(arg_17_0)
	ASSERT(arg_17_1)

	if not arg_17_0 or not arg_17_1 then
		return
	end

	local var_17_0 = arg_17_0.items

	ASSERT(var_17_0)

	if not var_17_0 then
		return
	end

	arg_17_1.activeItemIndex = arg_17_5

	local var_17_1 = var_17_0[arg_17_5]

	ASSERT(var_17_1)

	if not var_17_1 or var_17_1 and var_17_1.requireButtonToEdit then
		return
	end

	ASSERT(arg_17_4)

	local var_17_2 = var_17_1.editStateFactory(arg_17_2, arg_17_3, arg_17_4, var_17_1)

	ASSERT(var_17_2)

	var_17_2.refreshVisual = arg_17_4 and arg_17_4.refreshVisual

	ASSERT(var_17_2.hide)
	var_17_2:hide()

	return var_17_2
end

function setPlayerVisualOption(arg_18_0, arg_18_1, arg_18_2)
	arg_18_0:setOption(arg_18_1, arg_18_2)
end

function applyChangeToVisual(arg_19_0, arg_19_1, arg_19_2, arg_19_3, arg_19_4, arg_19_5)
	local var_19_0 = (arg_19_1.defaultDataKey or "") .. arg_19_2
	local var_19_1 = arg_19_0:getOption(arg_19_1[arg_19_2])
	local var_19_2 = arg_19_1.decalDefaultData
	local var_19_3 = 0
	local var_19_4 = 1

	if var_19_2 then
		local var_19_5 = arg_19_0:getOption(var_19_2.optionKey)
		local var_19_6 = arg_19_1.decalNum

		var_19_3 = var_19_2[var_19_5][var_19_6][var_19_0 .. "Min"]
		var_19_4 = var_19_2[var_19_5][var_19_6][var_19_0 .. "Max"]
	end

	local var_19_7 = arg_19_3 * var_0_4 * (arg_19_4 and arg_19_4 or 1)
	local var_19_8 = native.clamp1(var_19_1 + var_19_7, var_19_3, var_19_4)

	setPlayerVisualOption(arg_19_0, arg_19_1[arg_19_2], var_19_8)

	local var_19_9 = arg_19_5 and arg_19_5.debugHook

	if var_19_9 and var_19_2 and var_19_9.OptionToDataMap[var_19_2.optionKey] then
		local var_19_10 = var_19_9.OptionToDataMap[var_19_2.optionKey]
		local var_19_11 = var_19_9.defaultValues[var_19_10]
		local var_19_12 = arg_19_0:getOption(var_19_2.optionKey)
		local var_19_13 = arg_19_1.decalNum

		var_19_11[var_19_12][var_19_13][var_19_0 .. "Default"] = var_19_8
	end
end

function randomlyAdjustVisual(arg_20_0)
	local var_20_0 = arg_20_0:getOption("sex") == 0
	local var_20_1 = false

	if not var_20_1 then
		local var_20_2
		local var_20_3 = creator.GetCountryGroupOptions(var_20_2)
		local var_20_4 = var_20_0 and creator.RandomMaleGuidList or creator.RandomFemaleGuidList
		local var_20_5 = var_20_0 and creator.RandomMaleGuidList_body or creator.RandomFemaleGuidList_body
		local var_20_6 = var_20_0 and creator.RandomMaleSliderRangeList or creator.RandomFemaleSliderRangeList
		local var_20_7 = var_20_0 and creator.RandomMaleSliderRangeList_body or creator.RandomFemaleSliderRangeList_body
		local var_20_8, var_20_9 = creator.GetSkinColour(var_20_3.skinIndexList)

		arg_20_0:setOption("skinTexture", var_20_8)

		local var_20_10 = creator.GetEthnicitiesOption(var_20_9, var_20_3)

		arg_20_0:setOption("ethnicityShapeMorph_option", var_20_10)

		local var_20_11 = creator.GetEyeColourGuid(var_20_9, var_20_3.darkEyes)

		arg_20_0:setOption("eyeTexture", var_20_11)

		for iter_20_0, iter_20_1 in pairs(creator.RandomGuidList) do
			local var_20_12 = iter_20_1[math.random(#iter_20_1)]

			arg_20_0:setOption(iter_20_0, var_20_12)
		end

		for iter_20_2, iter_20_3 in pairs(creator.RandomGuidList_body) do
			local var_20_13 = iter_20_3[math.random(#iter_20_3)]

			arg_20_0:setOption(iter_20_2, var_20_13)
		end

		for iter_20_4, iter_20_5 in pairs(creator.RandomSliderRangeList) do
			local var_20_14 = iter_20_5[1] + math.random() * (iter_20_5[2] - iter_20_5[1])

			arg_20_0:setOption(iter_20_4, math.max(0, math.min(1, var_20_14)))
		end

		for iter_20_6, iter_20_7 in pairs(creator.RandomSliderRangeList_body) do
			local var_20_15 = iter_20_7[1] + math.random() * (iter_20_7[2] - iter_20_7[1])

			arg_20_0:setOption(iter_20_6, math.max(0, math.min(1, var_20_15)))
		end

		for iter_20_8, iter_20_9 in pairs(var_20_4) do
			local var_20_16 = iter_20_9[math.random(#iter_20_9)]

			arg_20_0:setOption(iter_20_8, var_20_16)
		end

		for iter_20_10, iter_20_11 in pairs(var_20_5) do
			local var_20_17 = iter_20_11[math.random(#iter_20_11)]

			arg_20_0:setOption(iter_20_10, var_20_17)
		end

		for iter_20_12, iter_20_13 in pairs(var_20_6) do
			local var_20_18 = iter_20_13[1] + math.random() * (iter_20_13[2] - iter_20_13[1])

			arg_20_0:setOption(iter_20_12, math.max(0, math.min(1, var_20_18)))
		end

		for iter_20_14, iter_20_15 in pairs(var_20_7) do
			local var_20_19 = iter_20_15[1] + math.random() * (iter_20_15[2] - iter_20_15[1])

			arg_20_0:setOption(iter_20_14, math.max(0, math.min(1, var_20_19)))
		end

		local var_20_20 = creator.GetDrivenSliderRangeList(arg_20_0)

		for iter_20_16, iter_20_17 in pairs(var_20_20) do
			local var_20_21 = iter_20_17[1] + math.random() * (iter_20_17[2] - iter_20_17[1])

			arg_20_0:setOption(iter_20_16, math.max(0, math.min(1, var_20_21)))
		end

		local var_20_22 = creator.GetDrivenGuidList(arg_20_0, var_20_9)

		for iter_20_18, iter_20_19 in pairs(var_20_22) do
			local var_20_23 = iter_20_19[math.random(#iter_20_19)]

			arg_20_0:setOption(iter_20_18, var_20_23)
		end
	else
		for iter_20_20, iter_20_21 in pairs(creator.RandomGuidList_test) do
			local var_20_24 = iter_20_21[math.random(#iter_20_21)]

			arg_20_0:setOption(iter_20_20, var_20_24)
		end

		for iter_20_22, iter_20_23 in pairs(creator.RandomSliderRangeList_test) do
			local var_20_25 = iter_20_23[1] + math.random() * (iter_20_23[2] - iter_20_23[1])

			arg_20_0:setOption(iter_20_22, math.max(0, math.min(1, var_20_25)))
		end

		local var_20_26 = creator.GetDrivenSliderRangeList(arg_20_0)

		for iter_20_24, iter_20_25 in pairs(var_20_26) do
			local var_20_27 = iter_20_25[1] + math.random() * (iter_20_25[2] - iter_20_25[1])

			arg_20_0:setOption(iter_20_24, math.max(0, math.min(1, var_20_27)))
		end
	end
end

local function var_0_32(arg_21_0, arg_21_1)
	local var_21_0 = currentlyUsingKeyboard(arg_21_1)
	local var_21_1 = native.Localise("DecalPreviewPosition")
	local var_21_2 = native.Localise("DecalPreviewScale")
	local var_21_3 = native.Localise("DecalPreviewFlip")
	local var_21_4 = native.Localise("DecalPreviewRotation")
	local var_21_5 = native.Localise("DecalAccept")

	if var_21_0 then
		arg_21_0:addTooltip(nil, var_0_12.KeyboardDecalPosition, var_21_1, 10)
		arg_21_0:addTooltip(nil, var_0_12.KeyboardDecalScale, var_21_2, 20)
		arg_21_0:addTooltip(nil, var_0_12.KeyboardDecalRotation, var_21_4, 30)
		arg_21_0:addTooltip(nil, var_0_12.KeyboardDecalFlip, var_21_3, 40)
		arg_21_0:addTooltip(nil, var_0_12.Decline, var_21_5, 50)
	else
		arg_21_0:addTooltip(nil, var_0_12.LJoy, var_21_1, 10)
		arg_21_0:addTooltip(nil, var_0_12.RJoyUpDown, var_21_2, 25)
		arg_21_0:addTooltip(nil, var_0_12.LB, "", 30)
		arg_21_0:addTooltip(nil, var_0_12.RB, var_21_4, 35)
		arg_21_0:addTooltip(nil, var_0_12.R3, var_21_3, 45)
		arg_21_0:addTooltip(nil, var_0_12.Decline, var_21_5, 50)
	end
end

function updateDecalPreviewMode(arg_22_0, arg_22_1, arg_22_2, arg_22_3, arg_22_4, arg_22_5)
	local var_22_0 = arg_22_0:getParty():getPrimaryPartyMember()

	if editassistant_helper.backInputDetected(arg_22_3, var_22_0) then
		arg_22_4.previewMode = nil

		return
	end

	local var_22_1 = true
	local var_22_2 = arg_22_0:getGameControlManager()

	var_0_32(arg_22_3, var_22_0)

	local var_22_3 = var_0_21(var_22_0, var_22_2, var_22_1)
	local var_22_4 = var_0_22(var_22_0, var_22_2, var_22_1)
	local var_22_5 = var_0_23(var_22_0, var_22_2, var_22_1)
	local var_22_6 = var_0_24(var_22_0, var_22_2, var_22_1)
	local var_22_7 = var_0_25(var_22_0, var_22_2, var_22_1)
	local var_22_8 = var_0_26(var_22_0, var_22_2, var_22_1)
	local var_22_9 = var_0_27(var_22_0, var_22_2, var_22_1)
	local var_22_10 = var_0_28(var_22_0, var_22_2, var_22_1)
	local var_22_11 = var_0_29(var_22_0, var_22_2, var_22_1)
	local var_22_12 = var_0_30(var_22_0, var_22_2, var_22_1)
	local var_22_13 = var_22_3 + var_22_4
	local var_22_14 = var_22_5 + var_22_6
	local var_22_15 = var_22_7 + var_22_8

	if var_22_13 == 0 and var_22_14 == 0 and var_22_15 == 0 and not var_22_11 and not var_22_12 and not var_22_9 and not var_22_10 then
		return
	end

	local var_22_16 = arg_22_4:getCurrentConfig()
	local var_22_17 = arg_22_4.visualProperties
	local var_22_18, var_22_19 = arg_22_3:playerModelGetVisualConfig(1)
	local var_22_20 = var_22_17.defaultDataKey == "left"
	local var_22_21 = 0.1

	if var_22_13 ~= 0 then
		applyChangeToVisual(var_22_16, var_22_17, "xPos", var_22_13, (var_22_20 and -1 or 1) * var_22_21, arg_22_5)
	end

	if var_22_14 ~= 0 then
		applyChangeToVisual(var_22_16, var_22_17, "yPos", var_22_14, -1 * var_22_21, arg_22_5)
	end

	if var_22_15 then
		applyChangeToVisual(var_22_16, var_22_17, "scale", var_22_15, var_22_21 * 5, arg_22_5)
	end

	if var_22_9 then
		local var_22_22 = var_22_17.flip
		local var_22_23 = var_22_16:getOption(var_22_22)

		setPlayerVisualOption(var_22_16, var_22_22, var_22_23 == 1 and 0 or 1)
	end

	if var_22_10 then
		local var_22_24 = var_22_17.flip
		local var_22_25 = var_22_16:getOption(var_22_24)

		setPlayerVisualOption(var_22_16, var_22_24, var_22_25 == 1 and 0 or 1)
	end

	if var_22_11 or var_22_12 then
		local var_22_26 = (var_22_11 and -1 or 0) + (var_22_12 and 1 or 0)

		applyChangeToVisual(var_22_16, var_22_17, "rot", var_22_26, 0.06, arg_22_5)
	end

	ASSERT(arg_22_4.refreshVisual)
	arg_22_4.refreshVisual()
end

function batEditorGoBack(arg_23_0, arg_23_1, arg_23_2, arg_23_3, arg_23_4, arg_23_5, arg_23_6, arg_23_7)
	arg_23_7.editGroups = nil

	local var_23_0 = arg_23_0.goBackFactoryStack
	local var_23_1 = var_23_0:pop()

	arg_23_1:changeState(var_23_1(), arg_23_2, arg_23_3, arg_23_4, arg_23_5, arg_23_6, arg_23_7, var_23_0)
end

local var_0_33 = {
	{
		469
	}
}
local var_0_34 = {}

for iter_0_0, iter_0_1 in ipairs(var_0_33) do
	for iter_0_2 = 1, 7 do
		local var_0_35 = iter_0_1[iter_0_2]

		if var_0_35 then
			table.insert(var_0_34, var_0_35)
		end
	end
end

math.randomseed(os.time())
tablex.ishuffle(var_0_34)

local var_0_36 = 1

function setupFeaturedPlayerModel(arg_24_0, arg_24_1, arg_24_2)
	local var_24_0 = var_0_36

	var_0_36 = var_0_36 % #var_0_34 + 1

	local var_24_1 = var_0_34[var_24_0]
	local var_24_2 = arg_24_0:getPlayerManager().onDisc:getPlayer(var_24_1)
	local var_24_3 = arg_24_0:getClubManager().onDisc:getClub(118)

	if var_24_3 then
		local var_24_4 = var_24_3:getHomeUniformVisual()

		arg_24_0:playerModelSetUniform(arg_24_1, var_24_4, var_24_3.identity)
	end

	arg_24_0:playerModelUpdate(arg_24_1, {
		refresh = true,
		resetOptions = true,
		rotationEnabled = true,
		draw = true,
		camera = "featuredPlayerHeadAndShoulders",
		cameraInstant = true,
		player = var_24_2,
		position = native.vec3.Zero(),
		rotation = arg_24_2 and var_0_3.Body.initialYRotationDegs
	})
end

function updateFeaturedPlayerModel(arg_25_0, arg_25_1, arg_25_2)
	local var_25_0 = arg_25_2:getSumOfChannel(native.EDeviceType.Pad, "rjoy-x")
	local var_25_1 = arg_25_2:getSumOfChannel(native.EDeviceType.Pad, "rjoy-y")
	local var_25_2 = var_25_0 ~= 0 or var_25_1 ~= 0
	local var_25_3 = arg_25_0:playerModelGetRotation(arg_25_1)

	if not var_25_3 then
		return
	end

	local var_25_4 = -((var_25_3 + 360 + 180) % 360 - 180) * var_0_3.Head.yRotationCentreRatio
	local var_25_5 = math.max(-var_0_3.Head.yRotationCentreLimit, math.min(var_25_4, var_0_3.Head.yRotationCentreLimit))

	arg_25_0:playerModelUpdate(arg_25_1, {
		lookAtManualXRotation = math.rad(-var_25_1 * var_0_3.Head.xRotationDegs),
		lookAtManualYRotation = math.rad(var_25_0 * var_0_3.Head.yRotationDegs + var_25_5),
		lookAtManualRelativeToModel = var_25_2
	})
end

function getVisualObject(arg_26_0, arg_26_1)
	local var_26_0 = arg_26_1.player
	local var_26_1

	if var_26_0 then
		var_26_1 = "player"
	else
		ASSERT(arg_26_1.selectedBatId)
		ASSERT(arg_26_0:getBatManager())

		var_26_0 = arg_26_0:getBatManager():getBat(arg_26_1.selectedBatId)
		var_26_1 = "bat"
	end

	ASSERT(var_26_0)
	ASSERT(var_26_1)

	return var_26_0, var_26_1
end

function getBatVisual(arg_27_0, arg_27_1)
	ASSERT(arg_27_1)
	ASSERT(arg_27_0.getBatManager)
	ASSERT(arg_27_0:getBatManager().getBat)
	ASSERT(arg_27_0:getBatManager():getBat(arg_27_1).visual)

	return arg_27_0:getBatManager():getBat(arg_27_1).visual
end

function refreshBatVisual(arg_28_0, arg_28_1)
	local var_28_0 = getBatVisual(arg_28_0, arg_28_1)

	ASSERT(var_28_0)
	arg_28_0:playerModelGetPlayer(1):setBatConfig(true, var_28_0)
	arg_28_0:playerModelUpdate(1, {
		refresh = true
	})
end

function getBatUndoPrivateFunctions(arg_29_0, arg_29_1)
	return {
		getFn = function()
			local var_30_0 = native.CVisualConfig("bat")
			local var_30_1, var_30_2, var_30_3 = arg_29_0:playerModelGetVisualConfig(1)

			var_30_0:copy(var_30_3)

			return var_30_0
		end,
		setFn = function(arg_31_0)
			local var_31_0, var_31_1, var_31_2 = arg_29_0:playerModelGetVisualConfig(1)

			var_31_2:copy(arg_31_0)
			arg_29_1:copy(var_31_2)
		end
	}
end

function getCanEdit(arg_32_0, arg_32_1)
	ASSERT(arg_32_1)

	local var_32_0 = not arg_32_1.readOnly or arg_32_1.currentAuthor == arg_32_0:sharingGetUserId()

	if not var_32_0 then
		arg_32_0:showNotification("alert", native.Localise("SharingReadOnly_CantEdit"))
	end

	return var_32_0
end

function findDownloadedInfo(arg_33_0, arg_33_1)
	if arg_33_1 then
		for iter_33_0, iter_33_1 in ipairs(arg_33_0) do
			if iter_33_1.object == arg_33_1 then
				return iter_33_1
			end
		end

		error("cant find guy in list of downloaded players!")
	end
end

function getValidLeaguesList(arg_34_0, arg_34_1, arg_34_2)
	local var_34_0 = {}
	local var_34_1 = arg_34_1:getLeagueManager()
	local var_34_2 = VERIFY(arg_34_0:getDlcManager())
	local var_34_3 = var_34_1:getAllLeagues(true, true, var_34_2)
	local var_34_4 = var_0_7.Count

	ASSERT(var_34_4 > 0)

	for iter_34_0, iter_34_1 in ipairs(var_34_3) do
		if iter_34_1 and (not arg_34_2 or iter_34_1.identity.sex == arg_34_2) and iter_34_1.isVisibleInFrontEnd then
			local var_34_5 = iter_34_1.id

			table.insert(var_34_0, {
				league = iter_34_1,
				enum = var_34_5 <= var_34_4 and var_0_7:fromInt(var_34_5 - 1) or nil,
				id = var_34_5
			})
		end
	end

	return var_34_0
end

function validateClubLineups(arg_35_0, arg_35_1, arg_35_2, arg_35_3, arg_35_4)
	if arg_35_4 <= arg_35_2.playerCount then
		if arg_35_2:getLineupCount() == 0 then
			local var_35_0 = arg_35_2:addNewLineup()

			var_35_0:setName(native.Localise("Lineup_STANDARD"))
			var_35_0:setCategory(var_0_9)

			if GAME_RUGBY then
				local var_35_1 = arg_35_2:addNewLineup()

				var_35_1:setName(native.Localise("Lineup_STANDARD"))
				var_35_1:setCategory(var_0_11)

				local var_35_2 = arg_35_2:addNewLineup()

				var_35_2:setName(native.Localise("Lineup_NINES"))
				var_35_2:setCategory(var_0_10)
			end
		end

		local var_35_3 = false

		if GAME_LACROSSE then
			var_35_3 = not arg_35_2:getLineupIsValidForCategory(var_0_9, arg_35_3)
		elseif GAME_RUGBY then
			var_35_3 = not arg_35_2:getLineupIsValidForCategory(var_0_9, arg_35_3) or not arg_35_2:getLineupIsValidForCategory(var_0_10, arg_35_3) or not arg_35_2:getLineupIsValidForCategory(var_0_11, arg_35_3)
		end

		if var_35_3 then
			local var_35_4 = VERIFY(arg_35_1.clubLineupGenerator)
			local var_35_5 = VERIFY(arg_35_0:getPlayerManager())

			native.ClubLineupHelper.setupBestLineups(var_35_4, arg_35_3, var_35_5, arg_35_2)
			arg_35_0:showNotification("alert", stringx.interp(native.Localise("AutoGeneratedStartingLineup"), {
				name = arg_35_2.nickname
			}))

			return true
		end
	end
end

function getCaptainForClub(arg_36_0, arg_36_1)
	local var_36_0 = arg_36_1:getLineup(1)
	local var_36_1 = var_36_0 and var_36_0:getSpecialRole(native.EClubLineupSpecialRole.Captain)

	return var_36_1 and arg_36_0:getPlayerManager():getPlayer(var_36_1)
end

function getThumbnailHeadshot(arg_37_0, arg_37_1, arg_37_2, arg_37_3)
	local var_37_0 = arg_37_0:getTexture(arg_37_3)

	if not var_37_0 then
		local var_37_1 = arg_37_2:getPlayer(arg_37_3)

		var_37_0 = arg_37_0:addPlayer(arg_37_1.club, var_37_1)
	end

	return var_37_0
end

function manageSquadOnHighlightedPlayerChanged(arg_38_0, arg_38_1, arg_38_2, arg_38_3, arg_38_4, arg_38_5)
	local var_38_0 = arg_38_1.onHighlightedPlayerChanged(arg_38_0, arg_38_2, arg_38_3, arg_38_4, arg_38_5)
	local var_38_1

	if var_38_0 then
		local var_38_2 = VERIFY(arg_38_0.manageSquadData)

		ASSERT(var_38_2.getHeadshot)

		local var_38_3 = VERIFY(arg_38_0.club)

		arg_38_3:playerModelSetUniform(1, var_38_3:getHomeUniformVisual())

		var_38_1 = {
			refresh = true,
			draw = true,
			player = var_38_0,
			club = arg_38_0.club,
			isNines = arg_38_0.isNines
		}
	else
		var_38_1 = {
			draw = false
		}
	end

	arg_38_3:playerModelUpdate(1, var_38_1)

	return var_38_0
end

function manageSquadOnEnter(arg_39_0, arg_39_1, arg_39_2, arg_39_3, arg_39_4, arg_39_5, arg_39_6, arg_39_7, arg_39_8, arg_39_9, arg_39_10)
	ASSERT(arg_39_8)

	arg_39_0.manageSquadData = arg_39_8

	local var_39_0 = arg_39_9.highlightPlayer and arg_39_9.highlightPlayer.id or nil

	ASSERT(arg_39_7)

	local var_39_1 = VERIFY(arg_39_7.club)

	arg_39_0.club = var_39_1

	local var_39_2 = false

	arg_39_0.isNines = var_39_2

	local var_39_3 = {
		exitOnSelection = false,
		backInputAllowed = true,
		showSelectButton = false,
		lockedSex = true,
		filterAllowed = true,
		sortAllowed = true,
		clubId = arg_39_7.clubId,
		club = var_39_1,
		boxTitle = arg_39_10,
		columns = NameAndClubRosterColumns,
		columnInitialSort = VERIFY(arg_39_9.sortColumnIndex),
		description = OfflinePlayerDescription,
		itemParams = {},
		searchOptions = VERIFY(arg_39_9.searchOptions),
		searchOptionsReset = VERIFY(arg_39_9.searchOptionsReset),
		viewPlayerStateFactory = arg_39_9.stateFactoryMap and arg_39_9.stateFactoryMap.View,
		params = {
			noPositionCounts = true,
			usingTitleBox = true
		}
	}

	arg_39_1.enter(arg_39_0, arg_39_2, arg_39_3, arg_39_4, arg_39_5, arg_39_6.partyMember, var_39_0, var_39_3)

	local var_39_4 = VERIFY(getUniformConfig(var_39_1, {
		isNines = var_39_2
	}))

	arg_39_5:playerModelSetUniform(1, var_39_4, var_39_1.identity)
	arg_39_5:playerModelUpdate(1, {
		rotationEnabled = false,
		useUniformOfLocalClub = true,
		camera = "FullBody_OutsideOfAppearance_Centred",
		position = native.vec3.Zero(),
		club = var_39_1,
		isNines = var_39_2
	})
end

function validateSquadLineups(arg_40_0)
	ASSERT(arg_40_0.club)

	local var_40_0 = arg_40_0.club

	if var_40_0:getLineupCount() > 0 then
		local var_40_1 = native.EClubLineupCategory.LeagueMatch

		for iter_40_0, iter_40_1 in ipairs(native.EMatchType) do
			local var_40_2 = var_40_0:getDefaultLineupIndex(iter_40_1)
			local var_40_3 = native.EClubLineupCategory:fromInt(var_40_2 - 1)

			if (not var_40_3 or not var_40_0:getLineupIsValid_Academy(var_40_2, var_40_3, arg_40_0.clubManager)) and native.CClubLineup.getLineupSize(var_40_1) <= var_40_0.playerCount then
				local var_40_4 = var_40_0:getLineupCount() > 0 and var_40_0:getLineup(1) or var_40_0:addNewLineup()

				native.CClubLineupGenerator.selectBestLineupSimple(var_40_0, var_40_4, var_40_1)
			end
		end
	end

	arg_40_0.setDirty()
end

function getMostRelevantClubForPlayer(arg_41_0, arg_41_1)
	local var_41_0 = arg_41_0:getClubManager()
	local var_41_1, var_41_2 = var_41_0:tryToGetMostRelevantClubIdContainingPlayer(arg_41_1)
	local var_41_3

	if var_41_1 then
		var_41_3 = var_41_0:getClub(var_41_1)
	elseif var_41_2 then
		formatPrint("player id: (%d) on multiple non-rep clubs - showing in free agents jersey", arg_41_1.id)
	end

	return var_41_3, var_41_1, var_41_2
end

function handlePlayerLinkFn(arg_42_0, arg_42_1, arg_42_2, arg_42_3, arg_42_4)
	ASSERT(arg_42_3)

	if arg_42_3.isLicensed then
		local var_42_0 = VERIFY(arg_42_1.systemTime)

		arg_42_1:blockingAlert(arg_42_0, var_42_0, {
			options = "ok",
			canCancel = false,
			text = var_0_18,
			input = arg_42_2
		})
	else
		ASSERT(arg_42_4)
		arg_42_4()
	end
end

function setAcademyDataOnAllMixins(arg_43_0, arg_43_1, arg_43_2)
	ASSERT(arg_43_0)
	ASSERT(arg_43_1)

	if not arg_43_2 then
		local var_43_0 = arg_43_1.settings

		ASSERT(var_43_0)

		arg_43_2 = var_43_0.academyClubsEnabled
	end

	ASSERT(arg_43_2 ~= nil)
	arg_43_0:runOnAllMixins("setAcademyData", arg_43_1.userAcademyData)
end

function getUniformConfig(arg_44_0, arg_44_1)
	if not arg_44_1.isNines then
		return arg_44_0:getHomeUniformVisual()
	end

	local var_44_0 = arg_44_0:getDefaultUniformIndex(native.CClubUniformCategory.Nines)

	return arg_44_0:getUniform(var_44_0).config
end

function showDeleteAlert(arg_45_0, arg_45_1, arg_45_2, arg_45_3, arg_45_4, arg_45_5, arg_45_6, arg_45_7, arg_45_8)
	ASSERT(arg_45_5 and arg_45_6 and arg_45_7 and arg_45_8)

	local var_45_0 = VERIFY(arg_45_5.name)
	local var_45_1
	local var_45_2
	local var_45_3
	local var_45_4

	if arg_45_8() then
		var_45_1 = native.Localise("CannotDeleteOnDiscDecal")
		var_45_2 = "ok"
		var_45_4 = 0
	else
		var_45_1 = stringx.interp(arg_45_6, {
			name = var_45_0
		})
		var_45_2 = "yesno"
		var_45_4 = var_45_0:len() * 15
	end

	ASSERT(var_45_1 and var_45_2 and var_45_4)
	arg_45_2:blockingAlert(arg_45_0, arg_45_1, {
		canCancel = true,
		text = var_45_1,
		options = var_45_2,
		width = math.max(alert_aide.DefaultWidth, var_45_4),
		input = arg_45_3:getInput(),
		onSelected = function(arg_46_0, arg_46_1, arg_46_2)
			if arg_46_2 and arg_46_2.val then
				arg_45_4(arg_46_1)
			end
		end
	})
end

function getClubIcons(arg_47_0)
	local var_47_0 = (not var_0_17 or arg_47_0:getDlc1Enabled()) and var_0_5 or var_0_6

	ASSERT(var_47_0)

	return var_47_0
end
