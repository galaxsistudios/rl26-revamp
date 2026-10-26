import("app.academy.academy_helper")
import("app.academy.identity_helper")
import("app.academy.logooptionselect_substate")
import("app.club.club_helper")
import("app.club.club_viewstate_checkforprofanity_substate")
import("base.ui.optionmenu.optionmenu_state")
import("base.ui.optionmenu.optionmenu_aide")
import("base.ui.textinput.textinput_substate")
import("core.foundation.func")
import("app.academy.academy_referee_list")
import("design.academy_config")
import("game.coach.coach_helper")

local var_0_0 = native.InputTypes
local var_0_1 = 2
local var_0_2 = 1
local var_0_3 = academy_helper.HelpStr
local var_0_4 = academy_helper.getClubIcons
local var_0_5 = identity_helper.createDialogueWildcardsTeamsMascot
local var_0_6 = identity_helper.createDialogueWildcardsTeamsLocation
local var_0_7 = optionmenu_aide.createColourPickerTriangle

local function var_0_8(arg_1_0)
	return arg_1_0.canEdit and not arg_1_0.isOnDiscClub
end

local function var_0_9(arg_2_0, arg_2_1, arg_2_2)
	return {
		label = native.Localise(arg_2_0),
		helpText = native.Localise(string.format("%sHelpText", arg_2_0)),
		getValue = function(arg_3_0)
			local var_3_0 = VERIFY(arg_3_0.club)
			local var_3_1 = VERIFY(var_3_0.identity)
			local var_3_2 = var_3_0:bypassUgcCensorship()

			if arg_2_1 == "fullName" then
				return var_3_1:getFullNameUgcBypass(var_3_2)
			elseif arg_2_1 == "shortName" then
				return var_3_1:getShortNameUgcBypass(var_3_2)
			elseif arg_2_1 == "nickname" then
				return var_3_1:getNicknameUgcBypass(var_3_2)
			elseif arg_2_1 == "hudName" then
				return var_3_1:getHUDNameUgcBypass(var_3_2)
			end

			return var_3_1:getOption(arg_2_1)
		end,
		setValue = function(arg_4_0, arg_4_1)
			local var_4_0 = arg_4_1.club

			var_4_0.identity:setOption(arg_2_1, arg_4_0)

			var_4_0.stringsValidForOnline = false
			var_4_0.hasCustomStrings = true
			var_4_0.isUserEdited = true
			var_4_0.sharing.hasUnsharedModifications = true

			arg_4_1.setDirty()

			arg_4_1.updateClubEmblemDisplay = true
		end,
		editableGetFn = var_0_8,
		editType = optionmenu_aide.EditTypes.TextInput,
		displayType = optionmenu_aide.DisplayTypes.TextInput,
		subStateFactory = textinput_substate.TextInputSubState,
		textProperties = arg_2_2
	}
end

local function var_0_10(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4)
	return {
		editWrapAround = true,
		label = native.Localise(arg_5_0),
		getValue = function(arg_6_0)
			return arg_6_0.club.identity:getOption(arg_5_1)
		end,
		setValue = function(arg_7_0, arg_7_1)
			local var_7_0 = arg_7_1.club

			var_7_0.identity:setOption(arg_5_1, arg_7_0)

			var_7_0.sharing.hasUnsharedModifications = true

			arg_7_1.setDirty()
		end,
		editableGetFn = var_0_8,
		editType = optionmenu_aide.EditTypes.Number,
		displayType = optionmenu_aide.DisplayTypes.Value,
		displayFormatValue = arg_5_4,
		min = assert(arg_5_2),
		max = assert(arg_5_3)
	}
end

FullName = var_0_9("ClubFullName", "fullName", {
	maxLength = native.CClubIdentity.MAX_CLUB_FULL_NAME_LENGTH
})
ShortName = var_0_9("ClubShortName", "shortName", {
	maxLength = native.CClubIdentity.MAX_CLUB_SHORT_NAME_LENGTH
})
Nickname = var_0_9("Nickname", "nickname", {
	maxLength = native.CClubIdentity.MAX_CLUB_NICKNAME_LENGTH
})
AbbreviatedName = var_0_9("ClubAbbreviatedName", "hudName", {
	maxLength = native.CClubIdentity.MAX_HUD_NAME_LENGTH
})

local var_0_11
local var_0_12
local var_0_13 = {
	editableGetFn = var_0_8,
	getValue = function(arg_8_0)
		return arg_8_0.club.identity.primaryRGBColour
	end,
	setValue = function(arg_9_0, arg_9_1)
		local var_9_0 = arg_9_1.club

		if var_9_0 and var_9_0.identity then
			var_9_0.identity.primaryRGBColour = arg_9_0
			arg_9_1.hasChanges = true
		end
	end,
	onAdjustFn = function(arg_10_0, arg_10_1, arg_10_2, arg_10_3)
		local var_10_0 = arg_10_0.club

		if var_10_0 and var_10_0.identity then
			var_10_0.identity.primaryRGBColour = native.CRGB(arg_10_3.x * 255, arg_10_3.y * 255, arg_10_3.z * 255)
			arg_10_0.hasChanges = true
			arg_10_2.adjusted = true
		end
	end
}
local var_0_14 = {
	editableGetFn = var_0_8,
	getValue = function(arg_11_0)
		return arg_11_0.club.identity.secondaryRGBColour
	end,
	setValue = function(arg_12_0, arg_12_1)
		local var_12_0 = arg_12_1.club

		if var_12_0 and var_12_0.identity then
			var_12_0.identity.secondaryRGBColour = arg_12_0
			arg_12_1.hasChanges = true
		end
	end,
	onAdjustFn = function(arg_13_0, arg_13_1, arg_13_2, arg_13_3)
		local var_13_0 = arg_13_0.club

		if var_13_0 and var_13_0.identity then
			var_13_0.identity.secondaryRGBColour = native.CRGB(arg_13_3.x * 255, arg_13_3.y * 255, arg_13_3.z * 255)
			arg_13_0.hasChanges = true
			arg_13_2.adjusted = true
		end
	end
}
local var_0_15 = var_0_7("PrimaryColour", var_0_13)
local var_0_16 = var_0_7("SecondaryColour", var_0_14)

local function var_0_17(arg_14_0)
	native.CTeamDefaultVisualManager():loadDefaults(arg_14_0)

	local var_14_0 = native.CClubManager()

	var_14_0:setOnDiscDatabase(arg_14_0:getClubDatabaseOnDisc())

	local var_14_1 = var_14_0.onDisc
	local var_14_2 = native.createTable(native.CClubManager.MAX_CLUBS_ON_DISC, 0)

	table.insert(var_14_2, {
		label = "",
		value = native.INVALID_CLUB_ID
	})

	for iter_14_0, iter_14_1 in var_14_1:iterateAll() do
		table.insert(var_14_2, {
			label = iter_14_1.fullName,
			value = iter_14_1.id
		})
	end

	return {
		editWrapAround = true,
		label = native.Localise("OnDiscClubId"),
		getValue = function(arg_15_0)
			return arg_15_0.club.id or false
		end,
		setValue = function(arg_16_0, arg_16_1)
			ASSERT(false)
		end,
		displayType = optionmenu_aide.DisplayTypes.Value,
		editableGetFn = function(arg_17_0)
			return false
		end,
		disabledGetFn = function(arg_18_0)
			return arg_18_0.isOnDiscClub
		end,
		editType = optionmenu_aide.EditTypes.ValueList,
		valueList = var_14_2
	}
end

import("intermediatelua.convant.icons")

local function var_0_18(arg_19_0)
	local var_19_0 = var_0_4(arg_19_0)

	ASSERT(#var_19_0 > 0)

	local var_19_1 = func.imap(function(arg_20_0, arg_20_1)
		return {
			label = native.Localise(string.format("Club_%s", arg_20_1)),
			value = arg_20_1
		}
	end, ipairs(var_19_0))

	table.sort(var_19_1, function(arg_21_0, arg_21_1)
		return arg_21_0.label < arg_21_1.label
	end)

	return var_19_1
end

local function var_0_19(arg_22_0, arg_22_1)
	return {
		animateClubEmblem = true,
		label = native.Localise("ClubEmblem"),
		getValue = function(arg_23_0)
			local var_23_0 = arg_23_0.club.identity.decalIdOrIcon
			local var_23_1 = var_23_0.decalId

			if var_23_1 ~= nil then
				local var_23_2 = arg_22_1:getDecalManager()
				local var_23_3 = var_23_2:getDecal(var_23_1) or var_23_2:getDecal(1)

				ASSERT(var_23_3)

				return var_23_3.name
			else
				return var_23_0 and var_23_0.icon and native.Localise(string.format("Club_%s", var_23_0.icon)) or ""
			end
		end,
		setValue = function(arg_24_0, arg_24_1)
			local var_24_0 = VERIFY(arg_24_1.club)
			local var_24_1 = VERIFY(var_24_0.identity)
			local var_24_2 = arg_24_0.decalIdOrIcon
			local var_24_3 = var_24_2

			var_24_1.decalIdOrIcon = var_24_2

			if var_24_3 == nil then
				ASSERT(icons.ClubIconColourSetMap[var_24_2.icon])
			end

			var_24_0.sharing.hasUnsharedModifications = true
			arg_24_1.updateClubEmblemDisplay = true

			arg_24_1.setDirty()
		end,
		editableGetFn = var_0_8,
		editType = optionmenu_aide.EditTypes.DecalSelect,
		displayType = optionmenu_aide.DisplayTypes.DecalSelect,
		subStateFactory = logooptionselect_substate.LogoOptionSelectSubState
	}
end

local var_0_20 = {
	{
		value = true,
		label = native.Localise("Yes")
	},
	{
		value = false,
		label = native.Localise("No")
	}
}
local var_0_21 = {
	label = native.Localise("ClubEmblemDecal"),
	getValue = function(arg_25_0)
		return arg_25_0.club.identity.showUniformEmblemDecals
	end,
	setValue = function(arg_26_0, arg_26_1)
		local var_26_0 = arg_26_1.club

		var_26_0.identity.showUniformEmblemDecals = arg_26_0
		var_26_0.sharing.hasUnsharedModifications = true

		for iter_26_0 = 1, var_26_0.uniformCount do
			var_26_0:getUniform(iter_26_0).config:setOption("showTeamLogo", arg_26_0 and 1 or 0)
		end

		arg_26_1.setDirty()
	end,
	editableGetFn = var_0_8,
	editType = optionmenu_aide.EditTypes.ValueList,
	valueList = var_0_20,
	displayType = optionmenu_aide.DisplayTypes.ValueList
}

local function var_0_22(arg_27_0)
	local var_27_0 = native.CSupporters()

	var_27_0:load(arg_27_0)

	local var_27_1 = {}
	local var_27_2 = var_27_0.count - 1

	for iter_27_0 = 0, var_27_2 do
		local var_27_3 = var_27_0:getNameKey(iter_27_0)

		table.insert(var_27_1, {
			label = native.Localise(string.format("Club_%s", var_27_3)),
			value = iter_27_0
		})
	end

	table.sort(var_27_1, function(arg_28_0, arg_28_1)
		return arg_28_0.label < arg_28_1.label
	end)

	return {
		label = native.Localise("Supporters"),
		getValue = function(arg_29_0)
			return arg_29_0.club.identity.supporters
		end,
		setValue = function(arg_30_0, arg_30_1)
			arg_30_1.club.identity.supporters = arg_30_0
			arg_30_1.club.sharing.hasUnsharedModifications = true

			arg_30_1.setDirty()
		end,
		editableGetFn = var_0_8,
		editType = optionmenu_aide.EditTypes.ValueList,
		valueList = var_27_1,
		displayType = optionmenu_aide.DisplayTypes.ValueList
	}
end

local function var_0_23(arg_31_0)
	local var_31_0 = {}
	local var_31_1 = native.CClubCommentaryColour
	local var_31_2 = var_31_1.Count - 1

	for iter_31_0 = 0, var_31_2 do
		local var_31_3 = var_31_1:fromInt(iter_31_0)

		table.insert(var_31_0, {
			value = var_31_3,
			label = native.Localise(tostring(var_31_3))
		})
	end

	table.sort(var_31_0, function(arg_32_0, arg_32_1)
		return arg_32_0.label < arg_32_1.label
	end)

	return {
		label = native.Localise("CommentaryColour"),
		getValue = function(arg_33_0)
			return arg_33_0.club.identity.commentaryColour
		end,
		setValue = function(arg_34_0, arg_34_1)
			arg_34_1.club.sharing.hasUnsharedModifications = true
			arg_34_1.club.identity.commentaryColour = arg_34_0

			arg_34_1.setDirty()
		end,
		editableGetFn = var_0_8,
		editType = optionmenu_aide.EditTypes.ValueList,
		valueList = var_31_0,
		displayType = optionmenu_aide.DisplayTypes.ValueList
	}
end

local function var_0_24()
	local var_35_0 = "alternateNumbering"
	local var_35_1 = "AlternateNumbering"

	return (optionmenu_aide.createToggle(native.Localise(var_35_1), var_35_0, {
		getValue = function(arg_36_0)
			return arg_36_0.club.identity:getOption(var_35_0)
		end,
		setValue = function(arg_37_0, arg_37_1)
			arg_37_1.club.sharing.hasUnsharedModifications = true

			arg_37_1.club.identity:setOption(var_35_0, arg_37_0)
			arg_37_1.setDirty()
		end,
		editableGetFn = var_0_8,
		helpKey = string.format("Help%s", var_35_1)
	}))
end

-- team-coaches: "Coach: <name>" row; pressing it opens TeamCoachesPickerState
local function teamCoachesCoachRow(arg_tc_0, arg_tc_1)
	local var_tc_0, var_tc_2 = coach_helper.getClubCoach(arg_tc_0, arg_tc_1.club)
	local var_tc_1 = var_tc_0 and coach_helper.getCoachName(var_tc_0) or var_tc_2 and string.format("#%s (not found)", tostring(var_tc_2)) or coach_helper.localiseOr("None", "None")

	return optionmenu_aide.createButton(string.format("%s: %s", coach_helper.localiseOr("Coach", "Coach"), var_tc_1), {
		teamCoachesButton = true,
		editableGetFn = var_0_8,
		examinationFunction = function()
			return false
		end
	})
end

local function var_0_25(arg_38_0, arg_38_1, arg_38_2)
	local var_38_0 = {}

	if GAME_RUGBY then
		table.insert(var_38_0, var_0_17(arg_38_0))
	end

	table.insert(var_38_0, FullName)
	table.insert(var_38_0, ShortName)
	table.insert(var_38_0, Nickname)

	if GAME_CRICKET then
		local var_38_1 = optionmenu_aide.valueListFromEnum(native.ClubGrading, {})
		local var_38_2 = optionmenu_aide.createLeftRight(native.Localise("ClubGrading"), nil, var_38_1, {
			getValue = function(arg_39_0)
				ASSERT(arg_39_0.club.grading)

				return arg_39_0.club.grading
			end,
			setValue = function(arg_40_0, arg_40_1)
				ASSERT(arg_40_0 ~= nil)
				ASSERT(arg_40_1)

				local var_40_0 = arg_40_1.club

				ASSERT(var_40_0.grading)

				var_40_0.grading = arg_40_0
				var_40_0.usingCustomGrading = true

				arg_40_1.setDirty()
			end
		})

		table.insert(var_38_0, var_38_2)
	end

	table.insert(var_38_0, AbbreviatedName)
	table.insert(var_38_0, var_0_19(arg_38_0, arg_38_1))

	if GAME_RUGBY then
		table.insert(var_38_0, teamCoachesCoachRow(arg_38_1, arg_38_2))
	end

	if GAME_LACROSSE then
		table.insert(var_38_0, var_0_23(arg_38_0))
	end

	if GAME_RUGBY then
		table.insert(var_38_0, var_0_5(arg_38_0, var_0_8))
		table.insert(var_38_0, var_0_6(arg_38_0, var_0_8))
		table.insert(var_38_0, var_0_24())
	end

	table.insert(var_38_0, var_0_15)
	table.insert(var_38_0, var_0_16)

	return var_38_0
end

local var_0_26 = optionmenu_state.OptionMenuState

Class("ClubViewIdentityState", var_0_26)

function ClubViewIdentityState.enter(arg_41_0, arg_41_1, arg_41_2, arg_41_3, arg_41_4, arg_41_5, arg_41_6, arg_41_7, arg_41_8)
	arg_41_0.goBackFactory = arg_41_7.teamCoachesIdentityGoBack or arg_41_8
	arg_41_7.teamCoachesIdentityGoBack = nil

	pcall(function()
		local var_tc_0 = arg_41_7.club

		local var_tc_1 = coach_helper.tryGetField(var_tc_0, "academyId")

		coach_helper.sidelineLog("academy: Identity opened for %s (id %s, academyId %s, onDisc %s, canEdit %s), coachId %s, assignment %s", tostring(var_tc_0.fullName), tostring(var_tc_0.id), tostring(var_tc_1), tostring(arg_41_7.isOnDiscClub), tostring(arg_41_7.canEdit), tostring(var_tc_0.coachId), tostring(coach_helper.getAssignedCoachId(var_tc_1 or var_tc_0.id)))
	end)
	arg_41_0.partyMember = VERIFY(arg_41_6.partyMember)
	arg_41_0.decalManager = arg_41_5:getDecalManager()

	local var_41_0 = var_0_25(arg_41_2, arg_41_5, arg_41_7)
	local var_41_1 = {
		backInputAllowed = true,
		displayCount = 18,
		adjustedOnSubstateExit = true,
		noSpaceBeforePanel = true,
		itemParams = arg_41_7,
		titleBox = {
			title = native.Localise("Identity")
		}
	}
	local var_41_2

	var_0_26.enter(arg_41_0, arg_41_2, arg_41_3, arg_41_4, arg_41_5, var_41_0, var_41_2, var_41_1, arg_41_7)
	arg_41_0:refreshClubInfo(arg_41_2, arg_41_5, arg_41_7, true)

	arg_41_0.clubIsEditable = var_0_8(arg_41_7)
end

function ClubViewIdentityState.exit(arg_42_0, arg_42_1, arg_42_2, arg_42_3, arg_42_4)
	arg_42_0.clubIcon:unload()
	arg_42_0.playerPlate:dispose()
	var_0_26.exit(arg_42_0, arg_42_1, arg_42_2, arg_42_3, arg_42_4)
end

function ClubViewIdentityState.onCreateArea(arg_43_0, arg_43_1, arg_43_2, arg_43_3, arg_43_4, arg_43_5, arg_43_6, arg_43_7, arg_43_8, arg_43_9)
	arg_43_5:setY(0.6, 0)

	local var_43_0 = native.UIWidgetQuad(arg_43_1)

	var_43_0:setWidth(1, 0)
	var_43_0:setHeight(0, 160)
	var_43_0:setY(1, 25)
	var_43_0:setAnchorPoint(0, 1)

	var_43_0.colour = native.SkinColours.FullBlack

	arg_43_5:addChild(var_43_0)

	local var_43_1 = native.UIWidgetArea(arg_43_1)

	var_43_1:setAnchorPoint(0.5, 0)
	var_43_1:setX(0.5, -20)
	var_43_1:setY(0, -80)
	var_43_1:setWidth(1, -20)
	var_43_1:setHeight(0, 100)
	var_43_0:addChild(var_43_1)

	local var_43_2 = native.UIWidgetQuad(arg_43_1)

	var_43_2:setAnchorPoint(0.5, 0)
	var_43_2:setX(0.5, 0)
	var_43_2:setY(0, -10)
	var_43_2:setWidth(1, -20)
	var_43_2:setHeight(0, 1)

	var_43_2.colour = native.SkinColours.FullWhite

	var_43_0:addChild(var_43_2)

	local var_43_3 = native.UIWidgetText(arg_43_1)

	var_43_3:setAnchorPoint(0, 0.5)
	var_43_3:setX(0, 25)
	var_43_3:setY(0.5, 0)

	var_43_3.alignVertical = native.TextAlign.Centre
	var_43_3.font = native.Fonts.Row_M
	var_43_3.colour = native.SkinColours.TitleRowBlack_Title

	var_43_3:setText(native.Localise("HUDPreview"))
	var_43_1:addChild(var_43_3)

	local var_43_4 = 175
	local var_43_5 = native.UIWidgetTexture(arg_43_1)

	var_43_5:setX(0.01, 0)
	var_43_5:setY(0.5, 0)
	var_43_5:setAnchorPoint(0, 0.5)
	var_43_5:addStyle(var_43_4, var_43_4, 0, 0, 0, 1, 1)
	var_43_0:addChild(var_43_5)

	local var_43_6 = arg_43_0.decalManager

	ASSERT(var_43_6)

	local var_43_7 = arg_43_9.club

	ASSERT(var_43_7)

	local var_43_8 = var_43_5 and var_43_5.width or 0
	local var_43_9 = native.UIWidgetPlayerPlateHUD(arg_43_1)

	var_43_0:addChild(var_43_9)

	var_43_9.decalManager = var_43_6

	var_43_9:populateAcademy(var_43_7)
	var_43_9:setX(0, var_43_8 + 30)
	var_43_9:setY(0.5, 0)
	var_43_9:setAnchorPoint(0, 0.5)

	var_43_9.alpha = 1
	arg_43_0.clubTint = {}
	arg_43_0.clubIcon = var_43_5
	arg_43_0.playerPlate = var_43_9
end

function ClubViewIdentityState.refreshClubInfo(arg_44_0, arg_44_1, arg_44_2, arg_44_3, arg_44_4)
	local var_44_0 = arg_44_0.clubIcon

	var_44_0:unload()

	local var_44_1 = VERIFY(arg_44_3.club)
	local var_44_2 = club_helper.getIdentityDecalTexture(arg_44_1, arg_44_2, var_44_1.identity)

	var_44_0:setTexture(var_44_2)
	var_44_2:unload()

	if arg_44_4 then
		var_44_0:animationKillAllActive()
		var_44_0:animateAlpha(0, 1, 0, 0.3, native.EaseType.QuadraticOut)
		var_44_0:animateScale(0.4, 0.9, 0, 0.2, native.EaseType.QuadraticOut)
		var_44_0:animateScale(0.9, 0.8, 0.2, 0.2, native.EaseType.QuadraticInOut)
	end

	local var_44_3 = arg_44_0.playerPlate

	if var_44_3 then
		var_44_3:populateAcademy(var_44_1)
		var_44_3:invalidateRenderBuffers()
	end

	local var_44_4 = arg_44_1:getUIRenderAide().skin
	local var_44_5 = var_44_1.primaryColour

	for iter_44_0, iter_44_1 in ipairs(arg_44_0.clubTint) do
		iter_44_1.customColour:copy(var_44_5)
		iter_44_1:invalidateRenderBuffers()
	end
end

function ClubViewIdentityState.addCustomTooltips(arg_45_0, arg_45_1, arg_45_2, arg_45_3)
	local var_45_0 = assert(arg_45_0.menuItems)
	local var_45_1 = assert(arg_45_0.menuConfig)
	local var_45_2 = assert(var_45_1.itemParams)
	local var_45_3 = arg_45_0.clubIsEditable

	if not arg_45_0.subState and var_45_3 then
		local var_45_4 = arg_45_0.partyMember

		if var_45_4 and var_45_4:isSignedInToService() and var_45_4:isSignedInOnline() then
			arg_45_2:addTooltip(arg_45_0.tooltipsWidget, var_0_0.Y, native.Localise("CheckForProfanity"), 80)
		end
	end
end

function ClubViewIdentityState.update(arg_46_0, arg_46_1, arg_46_2, arg_46_3, arg_46_4, arg_46_5, arg_46_6, arg_46_7, arg_46_8, arg_46_9)
	local var_46_0 = assert(arg_46_8.partyMember)
	local var_46_1, var_46_2, var_46_3, var_46_4 = var_0_26.update(arg_46_0, arg_46_2, arg_46_3, arg_46_4, arg_46_5, arg_46_6, arg_46_7, var_46_0:getInput())

	if var_46_4 and var_46_4.teamCoachesButton then
		arg_46_6:playSound("Select")
		arg_46_6:clearNotification()

		arg_46_9.teamCoachesIdentityGoBack = arg_46_0.goBackFactory

		arg_46_1:changeState(TeamCoachesPickerState(), arg_46_2, arg_46_3, arg_46_5, arg_46_6, arg_46_8, arg_46_9, arg_46_0.__proto)

		return
	end

	if var_46_1 then
		arg_46_6:clearNotification()
		arg_46_9.saveIfDirty(arg_46_2)
		arg_46_1:changeState(arg_46_0.goBackFactory(), arg_46_2, arg_46_3, arg_46_5, arg_46_6, arg_46_8, arg_46_9, arg_46_0.__proto)
	else
		if var_46_3 or arg_46_9.updateClubEmblemDisplay then
			local var_46_5 = var_46_3 and (var_46_3.animateClubEmblem or var_46_3.adjusted) or arg_46_9 and arg_46_9.updateClubEmblemDisplay

			arg_46_0:refreshClubInfo(arg_46_2, arg_46_6, arg_46_9, var_46_5)

			arg_46_9.updateClubEmblemDisplay = false

			if var_46_3 and var_46_3.adjusted then
				arg_46_0:refreshMenuItems(arg_46_2, arg_46_6)
			end
		end

		if arg_46_9.canEdit and not arg_46_0.subState and arg_46_6:checkForRelease(var_46_0, var_0_0.Y) and var_46_0 and var_46_0:isSignedInToService() and var_46_0:isSignedInOnline() then
			arg_46_6:playSound("Select")

			arg_46_0.subState = club_viewstate_checkforprofanity_substate.ClubViewStateCheckForProfanitySubState()

			arg_46_0.subState:enter(arg_46_2, arg_46_3, arg_46_5, arg_46_6, arg_46_8, arg_46_9)
		end

		if var_46_3 and var_46_3.getCommentaryKey then
			arg_46_0.commentaryKey = var_46_3.getCommentaryKey(arg_46_9)
			arg_46_0.commentaryPlayAt = arg_46_0.commentaryKey and arg_46_3 + 0.4 or nil
		end

		if arg_46_0.commentaryPlayAt and arg_46_3 >= arg_46_0.commentaryPlayAt then
			arg_46_6:playCommentaryCategories(arg_46_0.commentaryKey)

			arg_46_0.commentaryPlayAt = nil
		end

		if var_46_2 then
			if var_46_2.showNotificationOnHighlight and arg_46_0.clubIsEditable then
				arg_46_6:showNotification("alert", var_46_2.showNotificationOnHighlight, 1, 99999)
			else
				arg_46_6:clearNotification()
			end
		end

		local var_46_6 = arg_46_0:getHighlightedItemInfo()
		local var_46_7 = var_46_6 and var_46_6.helpKey

		if var_46_7 then
			arg_46_6:addTooltip(nil, var_0_0.Start, var_0_3, 10)

			if arg_46_6:checkForRelease(var_46_0, var_0_0.Start) then
				arg_46_6:playSound("Select")
				arg_46_6:blockingAlert(arg_46_2, arg_46_3, {
					options = "ok",
					canCanel = false,
					text = native.Localise(var_46_7)
				})
			end
		end

		local var_46_8 = arg_46_0.activeMenuItems[arg_46_0.menu.activeItemIndex]
	end
end

-- team-coaches: coach picker opened from the Identity "Coach" row. Reuses the
-- maintained referee list (as coach-editor does) filtered to coaches, previews
-- the highlighted coach in this club's polo, and saves the pick to the club.
local var_tc_list = academy_referee_list.AcademyRefereeListState

Class("TeamCoachesPickerState", var_tc_list)

function TeamCoachesPickerState.enter(arg_tc_0, arg_tc_1, arg_tc_2, arg_tc_3, arg_tc_4, arg_tc_5, arg_tc_6, arg_tc_7, arg_tc_8)
	arg_tc_0.goBackFactory = arg_tc_8
	arg_tc_0.club = VERIFY(arg_tc_7.club)

	local var_tc_0 = native.CRefereeSearchOptions()

	var_tc_0.mustBeType = native.CNpcType.Coach

	local var_tc_1 = native.CRefereeSearchOptions()

	var_tc_1:set(var_tc_0)

	local var_tc_2 = coach_helper.getClubCoach(arg_tc_5, arg_tc_0.club)

	arg_tc_5:toggleLockerRoomVisibility(true)
	var_tc_list.enter(arg_tc_0, arg_tc_2, arg_tc_3, arg_tc_4, arg_tc_5, arg_tc_6.partyMember, var_tc_2 and var_tc_2.id or nil, {
		sortAllowed = true,
		filterAllowed = false,
		exitOnSelection = true,
		backInputAllowed = true,
		playerModelConfig = {
			uniformSet = true
		},
		columns = academy_config.RefereeColumns,
		columnInitialSort = academy_config.RefereeColumnsInitialSort,
		itemParams = {},
		boxTitle = coach_helper.localiseOr("Coach", "Coach"),
		listTitle = coach_helper.localiseOr("Coach", "Coach"),
		searchOptions = var_tc_0,
		searchOptionsReset = var_tc_1
	})
end

function TeamCoachesPickerState.delayedRefreshPlayerModel(arg_tc_0, arg_tc_1, arg_tc_2, arg_tc_3, arg_tc_4, arg_tc_5)
	if not arg_tc_5.playerModelConfig then
		return
	end

	if arg_tc_4 then
		if arg_tc_4 ~= arg_tc_0.pmShowingReferee then
			if arg_tc_4 == arg_tc_0.pmWantingReferee then
				if arg_tc_2 >= arg_tc_0.pmRefreshAt then
					local var_tc_3 = coach_helper.makePoloUniform(arg_tc_4, arg_tc_0.club.identity.primaryRGBColour)

					arg_tc_1:playerModelUpdate(1, {
						refresh = true,
						draw = true,
						coach = {
							visual = arg_tc_4.visual,
							identity = arg_tc_4.identity,
							uniform = var_tc_3
						}
					})

					arg_tc_0.pmShowingReferee = arg_tc_4
					arg_tc_0.pmWantingReferee = nil
					arg_tc_0.pmRefreshAt = nil
				end
			else
				arg_tc_0.pmWantingReferee = arg_tc_4
				arg_tc_0.pmRefreshAt = arg_tc_2 + 0.4
			end
		end
	else
		arg_tc_1:playerModelUpdate(1, {
			draw = false
		})

		arg_tc_0.pmShowingReferee = nil
		arg_tc_0.pmWantingReferee = nil
		arg_tc_0.pmRefreshAt = nil
	end
end

function TeamCoachesPickerState.update(arg_tc_0, arg_tc_1, arg_tc_2, arg_tc_3, arg_tc_4, arg_tc_5, arg_tc_6, arg_tc_7, arg_tc_8, arg_tc_9)
	local var_tc_4, var_tc_5, var_tc_6, var_tc_7 = var_tc_list.update(arg_tc_0, arg_tc_2, arg_tc_3, arg_tc_4, arg_tc_5, arg_tc_6, arg_tc_7, arg_tc_8.partyMember)

	if var_tc_4 then
		if var_tc_7 then
			local var_tc_8 = arg_tc_9.club
			local var_tc_9 = var_tc_8.coachId

			var_tc_8:setCoachId(var_tc_7.id)
			pcall(function()
				coach_helper.sidelineLog("academy: club %s (id %s) coachId %s -> %s (%s), reads back %s", tostring(var_tc_8.fullName), tostring(var_tc_8.id), tostring(var_tc_9), tostring(var_tc_7.id), coach_helper.getCoachName(var_tc_7), tostring(var_tc_8.coachId))
			end)

			-- Only user-created clubs are saved; a built-in club reloads from the
			-- disc database next launch. Like the stock AcademyCoachAssignClubState,
			-- make the club's user-created version first and set the coach on it.
			local var_tc_10, var_tc_11 = pcall(function()
				local var_tc_12 = arg_tc_6:getClubManager()
				local var_tc_13 = var_tc_8.id
				local var_tc_14 = var_tc_12.userCreated:getClub(var_tc_13)
				local var_tc_15 = "existing"

				if not var_tc_14 then
					local var_tc_16 = var_tc_12.onDisc:getClub(var_tc_13)

					if var_tc_16 then
						local var_tc_17 = native.CClub()

						var_tc_17:set(var_tc_16)

						var_tc_17.createdAt = native.UTCTime.now()

						var_tc_12.userCreated:addClub(var_tc_17, var_tc_13)

						var_tc_14 = var_tc_12:getClub(var_tc_13)
						var_tc_15 = "created"
					end
				end

				if var_tc_14 then
					var_tc_14:setCoachId(var_tc_7.id)
				end

				return string.format("%s user-created copy, coachId %s", var_tc_14 and var_tc_15 or "no", tostring(var_tc_14 and var_tc_14.coachId))
			end)

			coach_helper.sidelineLog("academy: persist: %s", tostring(var_tc_11))

			-- official clubs drop coachId when the editor reloads them, so the
			-- mod also keeps its own club -> coach record (read by Identity and
			-- by the sideline code in matches)
			coach_helper.setAssignedCoachId(coach_helper.tryGetField(var_tc_8, "academyId") or var_tc_8.id, var_tc_7.id, coach_helper.getCoachName(var_tc_7))

			var_tc_8.sharing.hasUnsharedModifications = true

			arg_tc_9.setDirty()
			arg_tc_9.saveIfDirty(arg_tc_2)
		end

		arg_tc_1:changeState(ClubViewIdentityState(), arg_tc_2, arg_tc_3, arg_tc_5, arg_tc_6, arg_tc_8, arg_tc_9, arg_tc_0.__proto)
	end
end

function TeamCoachesPickerState.exit(arg_tc_0, arg_tc_1, arg_tc_2, arg_tc_3, arg_tc_4)
	arg_tc_4:toggleLockerRoomVisibility(false)
	var_tc_list.exit(arg_tc_0, arg_tc_1, arg_tc_2, arg_tc_3, arg_tc_4)
end
