import("base.ui.frame.frame_aide")
import("base.ui.optionmenu.optionmenu_aide")
import("design.characters.attributemap")
import("core.foundation.tablex")
import("base.ui.defaults")

local var_0_0 = attributemap.Data
local var_0_1 = attributemap.PlayerSkills
local var_0_2 = native.CGameConfig.ACADEMY_CAN_MODIFY_ON_DISC_PLAYERS
local var_0_3 = native.CPlayerAttributes.PLAYER_ATTRIBUTE_MIN
local var_0_4 = 1
local var_0_5 = frame_aide.AttributeOverallTitleBoxName
local var_0_6 = defaults.RowHeight
local var_0_7 = native.EPlayerSkill

PlayerSkillTabs = {
	Attributes = 3,
	SkillsPgTwo = 2,
	Skills = 1
}
PlayerSkillTabTitles = {
	"Skills",
	"SkillsPgTwo",
	"Attributes"
}

local var_0_8 = {
	[PlayerSkillTabs.Skills] = {
		{
			label = native.Localise("KickingSkills"),
			skills = {
				"groundKick",
				"puntKick",
				"chipKick",
				"bombKick",
				"fieldgoalKick",
				"placeKick"
			}
		},
		{
			label = native.Localise("HandlingSkills"),
			skills = {
				"basicPass",
				"longPass",
				"offload",
				"contestedCollect",
				"diveCollect",
				"ballStrip"
			}
		}
	},
	[PlayerSkillTabs.SkillsPgTwo] = {
		{
			label = native.Localise("EvasionSkills"),
			skills = {
				"dummyPass",
				"fend",
				"sideStep",
				"breakTackle"
			}
		},
		{
			label = native.Localise("PhysicalitySkills"),
			attributes = {
				"strength",
				"aggression",
				"injuryTolerance"
			},
			skills = {
				"tackle",
				"driveTackle",
				"diveTackle",
				"impactTackle"
			}
		}
	}
}
local var_0_9 = {
	[PlayerSkillTabs.Skills] = {
		{
			label = native.Localise("Dynasty_Skills_PageOne_Heading"),
			skills = {
				"grubberKick",
				"puntKick",
				"chipKick",
				"bombKick",
				"fieldgoalKick",
				"placeKick",
				"dropKick",
				"kickForTouch",
				"basicPass",
				"longPass",
				"offload",
				"ballStrip"
			}
		}
	},
	[PlayerSkillTabs.SkillsPgTwo] = {
		{
			label = native.Localise("Dynasty_Skills_PageTwo_Heading"),
			skills = {
				"dummyPass",
				"fend",
				"sideStep",
				"breakTackle",
				"tackle",
				"driveTackle",
				"diveTackle",
				"impactTackle",
				"contestedCollect",
				"diveCollect",
				"toePoke"
			}
		}
	},
	[PlayerSkillTabs.Attributes] = {
		{
			label = native.Localise("Dynasty_Skills_PageThree_Heading"),
			skills = {
				"acceleration",
				"agility",
				"discipline",
				"durability",
				"sprint",
				"stamina",
				"strength"
			}
		}
	}
}

function onCreateArea(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7)
	local var_1_0 = 28
	local var_1_1 = 408
	local var_1_2 = 100
	local var_1_3

	if not arg_1_6 then
		var_1_3 = native.UIWidgetText(arg_1_0)

		var_1_3:setWidth(1, -10)
		var_1_3:setHeight(1, 0)

		var_1_3.alignHorizontal = native.TextAlign.Right
		var_1_3.alignVertical = native.TextAlign.Centre
		var_1_3.font = native.Fonts.ReplaceMePleaseStyle
		var_1_3.colour = native.SkinColours.MenuLabelAndValueNormal

		var_1_3:setText("")

		local var_1_4 = arg_1_2:find(var_0_5)

		if var_1_4 then
			var_1_4:addChild(var_1_3)
		else
			arg_1_4:addChild(var_1_3)
		end
	end

	local var_1_5, var_1_6, var_1_7, var_1_8, var_1_9, var_1_10 = frame_aide.create(arg_1_0, {
		isNotTopLevel = true,
		titleBoxNoImage = true,
		noDropShadow = true,
		noTitleBox = true,
		noTitle = true,
		anchorTopLeft = true,
		noSpaceBeforePanel = true,
		displayCount = 16,
		width = arg_1_7 and arg_1_7.width or arg_1_3.width,
		height = arg_1_7 and arg_1_7.height or arg_1_3.height,
		titleBox = {
			centre = true,
			title = native.Localise("Skills"),
			triggers = {}
		}
	})
	local var_1_11 = native.UIWidgetOptionMenu(arg_1_0)
	local var_1_12 = arg_1_7 and arg_1_7.rowHeight or var_1_11.rowHeight

	var_1_11:setY(0, 0)
	var_1_11:setWidth(1, 0)

	var_1_11.displayCount = 15
	var_1_11.rowHeight = var_1_12

	if var_1_7 then
		var_1_7:addChild(var_1_11)
	else
		var_1_6:addChild(var_1_11)
	end

	arg_1_2:addChild(var_1_5)

	return var_1_3, var_1_11, var_1_5, var_1_6, var_1_7, var_1_10
end

local function var_0_10(arg_2_0, arg_2_1)
	return native.CPlayerSkillsHelper.getCap(arg_2_0, arg_2_1) + native.CPlayerSkillsHelper.getModifier(arg_2_0, arg_2_1)
end

local function var_0_11(arg_3_0)
	local var_3_0 = VERIFY(arg_3_0.player)
	local var_3_1 = var_3_0.primaryRole
	local var_3_2 = var_3_0:getOverallForPrimaryRole(var_3_1)
	local var_3_3 = var_3_2
	local var_3_4 = native.CPlayerRating.OverallMax
	local var_3_5 = native.CPlayer()

	return {
		editWrapAround = false,
		editBumpersJumpBy = 10,
		renderValue = true,
		adjustBy1 = true,
		label = native.Localise("OverallRating"),
		defaultVal = assert(var_3_2),
		getHelpString = function(arg_4_0)
			return "OverallRating"
		end,
		getValue = function(arg_5_0)
			local var_5_0 = var_3_0.primaryRole

			return var_3_0:getOverallForPrimaryRole(var_5_0)
		end,
		setValue = function(arg_6_0, arg_6_1)
			var_3_5:set(var_3_0)
			var_3_5:distributeAttributesAndSkillsForRating(arg_6_0)

			local var_6_0 = var_3_5.attributes.totalSpent

			if var_6_0 <= arg_6_1.attributePointsToSpend then
				var_3_0:set(var_3_5)

				arg_6_1.attributePointsSpentSoFar = var_6_0
				var_3_0.sharing.hasUnsharedModifications = true
			end
		end,
		editable = arg_3_0.canEdit or arg_3_0.canEditSkills and arg_3_0.canEditAttributes,
		editType = optionmenu_aide.EditTypes.Slider,
		displayType = optionmenu_aide.DisplayTypes.Slider,
		cap = var_3_4,
		min = native.CPlayerRating.RatingMin,
		max = var_3_4
	}
end

local function var_0_12(arg_7_0, arg_7_1, arg_7_2, arg_7_3)
	ASSERT(type(arg_7_2) == "string")

	local var_7_0 = string.format("Attribute_%s", arg_7_2)
	local var_7_1 = math.max(arg_7_0.attributePointsToSpend - arg_7_0.attributePointsSpentSoFar, 0)
	local var_7_2 = arg_7_0.playerViewInfo
	local var_7_3 = var_7_2.player
	local var_7_4 = var_7_3.primaryRole
	local var_7_5 = var_7_3.attributes:getOption(arg_7_2)
	local var_7_6 = var_0_10(var_7_4, arg_7_2)
	local var_7_7 = var_7_2.isOnDiscPlayer and math.max(var_7_6, var_7_5) or var_7_6

	ASSERT(var_7_7)

	local function var_7_8(arg_8_0, arg_8_1)
		local var_8_0 = math.min(var_7_5 + var_7_1, var_7_7)

		arg_8_0 = math.min(arg_8_0, var_7_2.isOnDiscPlayer and math.max(var_8_0, var_7_5) or var_8_0)

		local var_8_1 = VERIFY(var_7_2.player)
		local var_8_2 = VERIFY(var_8_1.attributes)

		var_8_2:setOption(arg_7_2, arg_8_0)

		var_8_1.sharing.hasUnsharedModifications = true

		if var_7_2.setDirty then
			var_7_2.setDirty()
		end

		arg_8_1.attributePointsSpentSoFar = var_8_2.totalSpent
	end

	local var_7_9 = {
		editBumpersJumpBy = 10,
		editWrapAround = false,
		renderValue = true,
		smallGap = true,
		adjustBy1 = true,
		label = native.Localise(var_7_0),
		getHelpString = function(arg_9_0)
			return var_7_0
		end,
		getValue = function(arg_10_0)
			return (math.min(var_7_7, VERIFY(arg_10_0.playerViewInfo.player.attributes:getOption(arg_7_2))))
		end,
		setValue = var_7_8,
		editable = arg_7_1,
		editType = optionmenu_aide.EditTypes.Slider,
		displayType = optionmenu_aide.DisplayTypes.Slider,
		displayFormatValue = function(arg_11_0, arg_11_1)
			return string.format("%d / %d", arg_11_0, var_7_7)
		end,
		cap = var_7_7,
		min = var_0_3,
		max = native.CPlayerRating.OverallMax
	}

	var_7_8(math.min(var_7_5, var_7_7), arg_7_0)

	if arg_7_3 then
		tablex.mergeInto(var_7_9, arg_7_3)
	end

	return var_7_9
end

local function var_0_13(arg_12_0, arg_12_1, arg_12_2, arg_12_3, arg_12_4)
	local var_12_0 = {}

	for iter_12_0 = 1, arg_12_2.Count do
		local var_12_1 = iter_12_0 - 1
		local var_12_2 = arg_12_2:fromInt(var_12_1)

		table.insert(var_12_0, {
			value = var_12_2,
			label = native.Localise(tostring(var_12_2))
		})
	end

	local var_12_3 = {
		label = arg_12_0,
		getValue = function(arg_13_0)
			ASSERT(arg_12_2:fromInt(arg_13_0.playerViewInfo.player.identity:getOption(arg_12_1)))

			return arg_12_2:fromInt(arg_13_0.playerViewInfo.player.identity:getOption(arg_12_1))
		end,
		setValue = function(arg_14_0, arg_14_1)
			ASSERT(arg_14_1.playerViewInfo)

			local var_14_0 = arg_14_1.playerViewInfo
			local var_14_1 = var_14_0.player

			var_14_1.identity:setOption(arg_12_1, arg_14_0:toInt())

			var_14_1.sharing.hasUnsharedModifications = true

			var_14_0.setDirty()
		end,
		editable = arg_12_3,
		editType = optionmenu_aide.EditTypes.ValueList,
		valueList = var_12_0,
		displayType = optionmenu_aide.DisplayTypes.ValueList
	}

	function var_12_3.getHelpString(arg_15_0)
		local var_15_0 = var_12_3.getValue(arg_15_0)

		ASSERT(var_15_0)

		return (string.format("%s_%s", arg_12_1, tostring(var_15_0)))
	end

	if arg_12_4 then
		tablex.mergeInto(var_12_3, arg_12_4)
	end

	return var_12_3
end

local function var_0_14(arg_16_0, arg_16_1, arg_16_2)
	return {
		label = arg_16_0,
		getHelpString = function(arg_17_0)
			local var_17_0 = assert(arg_17_0.playerViewInfo).player.identity:getOption(arg_16_1)

			return (string.format("%s_%s", arg_16_1, var_17_0 and "Right" or "Left"))
		end,
		getValue = function(arg_18_0)
			return assert(arg_18_0.playerViewInfo).player.identity:getOption(arg_16_1)
		end,
		setValue = function(arg_19_0, arg_19_1)
			local var_19_0 = assert(arg_19_1.playerViewInfo)
			local var_19_1 = var_19_0.player

			var_19_0.player.identity:setOption(arg_16_1, arg_19_0)

			var_19_1.sharing.hasUnsharedModifications = true

			var_19_0.setDirty()
		end,
		editable = arg_16_2,
		editType = optionmenu_aide.EditTypes.Toggle,
		displayType = optionmenu_aide.DisplayTypes.Value,
		displayFormatValue = function(arg_20_0, arg_20_1)
			return native.Localise(arg_20_0 and "Right" or "Left")
		end
	}
end

local function var_0_15(arg_21_0)
	return {
		editable = false,
		centre = true,
		label = arg_21_0,
		displayType = optionmenu_aide.DisplayTypes.SubTitle
	}
end

local function var_0_16(arg_22_0, arg_22_1, arg_22_2, arg_22_3, arg_22_4)
	ASSERT(arg_22_0)

	local var_22_0 = VERIFY(arg_22_0.player)
	local var_22_1 = var_22_0.primaryRole
	local var_22_2 = arg_22_0.skillBase and arg_22_0.skillBase[arg_22_2]
	local var_22_3 = arg_22_0.skillMax and arg_22_0.skillMax[arg_22_2] or arg_22_3.max

	ASSERT(var_22_3)

	local var_22_4 = arg_22_0.skillLimit and arg_22_0.skillLimit[arg_22_2] or arg_22_3.max

	ASSERT(var_22_4)

	local var_22_5 = var_0_10(var_22_1, arg_22_2)

	ASSERT(arg_22_3.default)

	return {
		editWrapAround = false,
		editBumpersJumpBy = 10,
		smallGap = true,
		renderValue = true,
		adjustBy1 = true,
		label = native.Localise(arg_22_2),
		defaultVal = arg_22_3.default,
		getHelpString = function(arg_23_0)
			return arg_22_2
		end,
		getValue = function(arg_24_0)
			local var_24_0 = assert(arg_24_0.playerViewInfo)
			local var_24_1 = var_24_0.player.skills:getOption(arg_22_2)

			return (math.min(var_24_0.isOnDiscPlayer and math.max(var_22_5, var_24_1) or var_22_5, var_24_1))
		end,
		setValue = function(arg_25_0, arg_25_1)
			local var_25_0 = assert(arg_25_1.playerViewInfo)

			var_25_0.setDirty()

			var_22_0.sharing.hasUnsharedModifications = true

			local var_25_1 = var_25_0.player
			local var_25_2 = var_22_2 or 0
			local var_25_3 = var_25_1.skills:getOption(arg_22_2)
			local var_25_4 = native.clamp1(arg_25_0, var_25_2, var_25_0.isOnDiscPlayer and math.max(var_22_5, var_25_3) or var_22_5)

			return var_25_1.skills:setOption(arg_22_2, var_25_4)
		end,
		editable = arg_22_1,
		editType = optionmenu_aide.EditTypes.Slider,
		displayType = optionmenu_aide.DisplayTypes.Slider,
		base = var_22_2,
		hiddenMax = var_22_3,
		cap = arg_22_0.isOnDiscPlayer and math.max(var_22_5, var_22_0.skills:getOption(arg_22_2)) or var_22_5,
		min = arg_22_3.min,
		max = arg_22_3.max
	}
end

function createContinueButtonItem()
	return {
		editable = true,
		label = native.Localise("Continue"),
		displayType = optionmenu_aide.DisplayTypes.LabelOnly,
		editType = optionmenu_aide.EditTypes.SubMenu,
		getHelpString = function(arg_27_0)
			return "Continue"
		end
	}
end

function createLabelItem(arg_28_0)
	return {
		rightAlignLabel = true,
		label = arg_28_0,
		displayType = optionmenu_aide.DisplayTypes.LabelOnly
	}
end

function createLabelItem(arg_29_0)
	return {
		editable = false,
		smallGap = true,
		rightAlignLabel = true,
		label = arg_29_0,
		displayType = optionmenu_aide.DisplayTypes.LabelOnly
	}
end

local function var_0_17(arg_30_0, arg_30_1, arg_30_2, arg_30_3)
	ASSERT(arg_30_2.player)

	local var_30_0 = "perk"
	local var_30_1 = not arg_30_2.player.isLicensed

	-- unlock-tier1-editing: preferred roles follow the same edit permission as Perk
	-- (stock locked them for every licensed player)
	tablex.iconcatInto(arg_30_1, {
		var_0_13(native.Localise("PreferredRolePrimary"), "preferredRolePrimary", native.EPreferredRole, arg_30_0),
		var_0_13(native.Localise("PreferredRoleSecondary"), "preferredRoleSecondary", native.EPreferredRole, arg_30_0),
		var_0_13(native.Localise("PreferredRoleTertiary"), "preferredRoleTertiary", native.EPreferredRole, arg_30_0),
		var_0_14(native.Localise("PreferredHand"), "rightHanded", var_30_1),
		var_0_14(native.Localise("PreferredFoot"), "rightFooted", var_30_1),
		var_0_13(native.Localise("Perk"), var_30_0, native.CPlayerAttributePerk, arg_30_0, {
			perk = true,
			getValue = function(arg_31_0)
				ASSERT(arg_31_0.playerViewInfo.player.attributes:getOption(var_30_0))

				return native.CPlayerAttributePerk:fromInt(arg_31_0.playerViewInfo.player.attributes:getOption(var_30_0))
			end,
			setValue = function(arg_32_0, arg_32_1)
				local var_32_0 = arg_30_2.player

				var_32_0.attributes:setOption(var_30_0, arg_32_0:toInt())

				var_32_0.sharing.hasUnsharedModifications = true

				arg_30_2.setDirty()
			end
		})
	})
end

function createAcademyIdentityMenuItems(arg_33_0, arg_33_1)
	local var_33_0 = arg_33_1.canEditAttributes and (not arg_33_1.isOnDiscPlayer or var_0_2)
	local var_33_1 = {
		var_0_11(arg_33_1)
	}
	local var_33_2 = false

	var_0_17(var_33_0, var_33_1, arg_33_1, var_33_2)

	return var_33_1
end

function createCareerRookieIdentityMenuItems(arg_34_0, arg_34_1)
	local var_34_0 = arg_34_1.canEdit and (not arg_34_1.isOnDiscPlayer or var_0_2)
	local var_34_1 = {}
	local var_34_2 = true

	var_0_17(var_34_0, var_34_1, arg_34_1, var_34_2)

	return var_34_1
end

function createCareerLevelUpIdentityMenuItems(arg_35_0, arg_35_1)
	local var_35_0 = false

	return {
		var_0_13(native.Localise("PreferredRolePrimary"), "preferredRolePrimary", native.EPreferredRole, var_35_0),
		var_0_13(native.Localise("PreferredRoleSecondary"), "preferredRoleSecondary", native.EPreferredRole, var_35_0),
		var_0_13(native.Localise("PreferredRoleTertiary"), "preferredRoleTertiary", native.EPreferredRole, var_35_0),
		var_0_14(native.Localise("PreferredHand"), "rightHanded", var_35_0),
		var_0_14(native.Localise("PreferredFoot"), "rightFooted", var_35_0)
	}
end

function createAttributeMenuItems(arg_36_0, arg_36_1)
	local var_36_0 = arg_36_1.playerViewInfo
	local var_36_1 = var_36_0.canEditAttributes and (not var_36_0.isOnDiscPlayer or var_0_2)
	local var_36_2 = {}

	ASSERT(attributemap.Data[1])

	local var_36_3 = attributemap.Data[1].PlayerAttributesCountTowardsBudget

	ASSERT(var_36_3)

	for iter_36_0, iter_36_1 in pairs(var_36_3) do
		ASSERT(iter_36_1.type == "integer", stringFormatT("Entry Type %t not implemented", iter_36_1.type))

		local var_36_4 = var_0_12(arg_36_1, var_36_1, iter_36_0)

		table.insert(var_36_2, var_36_4)
	end

	if GAME_CRICKET then
		local var_36_5 = math.max(arg_36_1.attributePointsToSpend - arg_36_1.attributePointsSpentSoFar, 0)
		local var_36_6 = string.format("%s: %d", native.Localise("PointsToSpend"), var_36_5)

		table.insert(var_36_2, 1, var_0_15(var_36_6))
	end

	return var_36_2
end

function createSkillMenuItems(arg_37_0, arg_37_1, arg_37_2)
	local var_37_0 = arg_37_2.player
	local var_37_1 = var_37_0.identity
	local var_37_2 = arg_37_2.canEditSkills and (not arg_37_2.isOnDiscPlayer or var_0_2)
	local var_37_3 = {}
	local var_37_4 = attributemap.Data[1].PlayerSkills

	for iter_37_0, iter_37_1 in ipairs(var_0_8[arg_37_1]) do
		table.insert(var_37_3, var_0_15(iter_37_1.label))

		for iter_37_2, iter_37_3 in ipairs(iter_37_1.skills) do
			local var_37_5 = var_37_0.skills:getOption(iter_37_3)

			table.insert(var_37_3, var_0_16(arg_37_2, var_37_2, iter_37_3, var_37_4[iter_37_3]))
		end
	end

	return var_37_3
end

local function var_0_18(arg_38_0)
	return tostring(arg_38_0):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

function createCostMenuItems(arg_39_0, arg_39_1, arg_39_2)
	local var_39_0 = arg_39_2.playerViewInfo
	local var_39_1 = var_39_0.player
	local var_39_2 = var_39_1.identity
	local var_39_3 = var_39_1.primaryRole
	local var_39_4 = var_39_1.identity.bowlType
	local var_39_5 = var_39_1.identity.bowlRightHanded
	local var_39_6 = {}
	local var_39_7 = var_39_0.skillBase
	local var_39_8 = var_39_1.skills
	local var_39_9 = arg_39_2.career
	local var_39_10 = var_39_9.points
	local var_39_11 = native.CPlayerAttributePerk:fromInt(var_39_1.attributes:getOption("perk"))

	for iter_39_0, iter_39_1 in ipairs(var_0_8[arg_39_1]) do
		table.insert(var_39_6, var_0_15(native.Localise("COST")))

		for iter_39_2, iter_39_3 in ipairs(iter_39_1.skills) do
			local var_39_12 = var_39_7[iter_39_3]
			local var_39_13 = var_39_8:getOption(iter_39_3)
			local var_39_14 = var_39_10:getCostForSkill(var_39_13 + 1, iter_39_3, var_39_11)
			local var_39_15 = var_39_13 == native.CPlayerSkillsHelper.getCap(var_39_3, iter_39_3) and "N/A" or var_39_9:getCurrencyString(var_39_14)

			table.insert(var_39_6, createLabelItem(var_39_15))
		end
	end

	return var_39_6
end

function getDisciplineSkillMenuMap()
	return var_0_9
end

function getSkillMaxes(arg_41_0, arg_41_1, arg_41_2, arg_41_3, arg_41_4, arg_41_5, arg_41_6)
	local var_41_0 = {}

	for iter_41_0 in pairs(attributemap.PlayerSkills) do
		local var_41_1 = native.CPlayerSkillsHelper.getCap(arg_41_0, iter_41_0)
		local var_41_2 = arg_41_3:getOption(iter_41_0)
		local var_41_3 = arg_41_1:getOption(iter_41_0)
		local var_41_4 = arg_41_2:getOption(iter_41_0)
		local var_41_5 = var_41_2 - var_41_3
		local var_41_6 = native.CPlayerAttributePerk:fromInt(arg_41_4:getOption("perk"))
		local var_41_7 = arg_41_5:levelMaxSkillLevelWithPoints(arg_41_6, var_41_5, iter_41_0, var_41_6)

		var_41_0[iter_41_0] = math.min(var_41_1, var_41_3 + var_41_7)
	end

	return var_41_0
end

function getCurrentSkills(arg_42_0)
	local var_42_0 = {}

	for iter_42_0 in pairs(attributemap.PlayerSkills) do
		var_42_0[iter_42_0] = arg_42_0:getOption(iter_42_0)
	end

	return var_42_0
end

function getSkillCaps(arg_43_0)
	local var_43_0 = {}

	for iter_43_0 in pairs(attributemap.PlayerSkills) do
		var_43_0[iter_43_0] = var_0_10(arg_43_0, iter_43_0)
	end

	return var_43_0
end
