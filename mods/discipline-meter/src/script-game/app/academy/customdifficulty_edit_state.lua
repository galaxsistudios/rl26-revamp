import("base.ui.optionmenu.optionmenu_state")
import("base.ui.optionmenu.optionmenu_aide")
import("app.settings.settings_gameplaymodifiers_helper")

-- discipline-meter: a MODDED section at the bottom of each custom difficulty, for settings that
-- only exist in the RL26 Revamp. The native gameplay modifiers can't take new fields, so these
-- live in rl26_revamp_sliders.ini in the game folder, one section per custom difficulty name
-- (rules/sinbin/sinbinsystem.lua reads it at kick-off; renaming a difficulty starts it fresh).
local ModdedSlidersFile = "rl26_revamp_sliders.ini"
local ModdedSlidersHeader = "# RL26 Revamp modded sliders, one [section] per custom difficulty (written by the game)"

local function var_0_modded_read()
	local var_sections, var_order = {}, {}

	pcall(function()
		local var_file = io.open(ModdedSlidersFile, "r")

		if not var_file then
			return
		end

		local var_section

		for iter_line in var_file:lines() do
			local var_name = iter_line:match("^%s*%[(.-)%]%s*$")

			if var_name then
				var_section = {}
				var_sections[var_name] = var_section

				table.insert(var_order, var_name)
			elseif var_section then
				local var_key, var_value = iter_line:match("^%s*([%w_]+)%s*=%s*(.-)%s*$")

				if var_key then
					var_section[var_key] = var_value
				end
			end
		end

		var_file:close()
	end)

	return var_sections, var_order
end

-- rewrites the whole file, keeping every other difficulty's section
local function var_0_modded_write(arg_name, arg_values)
	local var_sections, var_order = var_0_modded_read()

	if not var_sections[arg_name] then
		table.insert(var_order, arg_name)
	end

	var_sections[arg_name] = arg_values

	pcall(function()
		local var_file = io.open(ModdedSlidersFile, "w")

		if not var_file then
			return
		end

		var_file:write(ModdedSlidersHeader, "\n")

		for iter_i, iter_name in ipairs(var_order) do
			var_file:write("\n[", iter_name, "]\n")

			local var_keys = {}

			for iter_key in pairs(var_sections[iter_name]) do
				table.insert(var_keys, iter_key)
			end

			table.sort(var_keys)

			for iter_j, iter_key in ipairs(var_keys) do
				var_file:write(iter_key, " = ", tostring(var_sections[iter_name][iter_key]), "\n")
			end
		end

		var_file:close()
	end)
end

local function var_0_modded_rows(arg_values)
	return {
		{
			editable = false,
			label = "MODDED",
			displayType = optionmenu_aide.DisplayTypes.SubTitle
		},
		{
			editable = true,
			label = "Discipline",
			description = "ModdedDiscipline",
			key = "ModdedDiscipline",
			defaultVal = true,
			modDescription = "Every player has a discipline meter (the bar on the right of the player plate). It drops with fatigue, pressure, the scoreboard and mistakes, faster on harder base difficulties for your team, and low discipline means handling errors, penalties, sin bins and send-offs. Off: everyone stays at 100% and none of it happens.",
			getValue = function()
				return arg_values.discipline ~= "off"
			end,
			setValue = function(arg_value)
				arg_values.discipline = arg_value and "on" or "off"
			end,
			editType = optionmenu_aide.EditTypes.Toggle,
			displayType = optionmenu_aide.DisplayTypes.Toggle
		},
		{
			editable = true,
			label = "Discipline Strength",
			description = "ModdedDisciplineStrength",
			key = "ModdedDisciplineStrength",
			defaultVal = 1,
			editRestoreToDefault = true,
			editWrapAround = false,
			startFromMin = true,
			editBumpersJumpBy = 10,
			adjustBy = 1,
			smallGap = false,
			editLeftRightSpeedUp = true,
			renderFloatValue = true,
			min = 0.25,
			max = 3,
			editAdjustByMod = 0.05,
			modDescription = "How fast discipline drains, for both teams (x1 = normal, x2 = twice as fast, x0.5 = half). Stacks with the base difficulty: harder difficulties drain your team faster and keep the CPU calmer. Only used when Discipline is on.",
			getValue = function()
				return tonumber(arg_values.discipline_strength) or 1
			end,
			setValue = function(arg_value)
				arg_values.discipline_strength = string.format("%.2f", arg_value)
			end,
			editType = optionmenu_aide.EditTypes.Slider,
			displayType = optionmenu_aide.DisplayTypes.Slider
		}
	}
end

-- hia-protocol: HIA rows, shown when that mod is installed (its HIADifficulty table gives each
-- base difficulty's defaults). A slider left alone isn't saved, so it keeps following the Misc
-- base difficulty; game/injury/injuryevent_listener.lua reads hia / hia_frequency / hia_fail_rate.
local function var_0_hia_rows(arg_values, arg_difficulty)
	local var_ok, var_table = pcall(function()
		import("game.injury.injuryevent_listener")

		return injuryevent_listener.HIADifficulty
	end)

	if not var_ok or type(var_table) ~= "table" then
		return {}
	end

	local var_base

	pcall(function()
		var_base = tostring(native.EDifficulty:fromInt(arg_difficulty.sliderMiscDifficulty))
	end)

	local var_defaults = var_table[var_base or ""] or var_table.Medium or {
		frequency = 1,
		failRate = 40
	}

	return {
		{
			editable = true,
			label = "HIA Protocol",
			description = "ModdedHIA",
			key = "ModdedHIA",
			defaultVal = true,
			modDescription = "Head Injury Assessments. A head-high tackle can send the tackled player off for an HIA: he goes off on a free interchange for the best bench player in his position, sits out 15 minutes of match clock, then passes and comes back on, or fails and is out for the match. Off: no HIAs.",
			getValue = function()
				return arg_values.hia ~= "off"
			end,
			setValue = function(arg_value)
				arg_values.hia = arg_value and "on" or "off"
			end,
			editType = optionmenu_aide.EditTypes.Toggle,
			displayType = optionmenu_aide.DisplayTypes.Toggle
		},
		{
			editable = true,
			label = "HIA Frequency",
			description = "ModdedHIAFrequency",
			key = "ModdedHIAFrequency",
			defaultVal = var_defaults.frequency,
			editRestoreToDefault = true,
			editWrapAround = false,
			startFromMin = true,
			editBumpersJumpBy = 10,
			adjustBy = 1,
			smallGap = false,
			editLeftRightSpeedUp = true,
			renderFloatValue = true,
			min = 0,
			max = 5,
			editAdjustByMod = 0.05,
			modDescription = string.format("How often head-high tackles lead to an HIA, for both teams (x1 = a quarter of them; the base difficulty's default is x%.2f). Also scaled by Injury Probability. Only used when HIA Protocol is on.", var_defaults.frequency),
			getValue = function()
				return tonumber(arg_values.hia_frequency) or var_defaults.frequency
			end,
			setValue = function(arg_value)
				arg_values.hia_frequency = string.format("%.2f", arg_value)
			end,
			editType = optionmenu_aide.EditTypes.Slider,
			displayType = optionmenu_aide.DisplayTypes.Slider
		},
		{
			editable = true,
			label = "HIA Fail Rate",
			description = "ModdedHIAFailRate",
			key = "ModdedHIAFailRate",
			defaultVal = var_defaults.failRate,
			editRestoreToDefault = true,
			editWrapAround = false,
			startFromMin = true,
			editBumpersJumpBy = 4,
			adjustBy = 1,
			smallGap = false,
			editLeftRightSpeedUp = true,
			renderValue = true,
			min = 0,
			max = 100,
			editAdjustByMod = 5,
			modDescription = string.format("Percentage of HIAs the player fails, staying off for the rest of the match (the base difficulty's default is %d%%). The rest come back on after 15 minutes. Only used when HIA Protocol is on.", var_defaults.failRate),
			getValue = function()
				return tonumber(arg_values.hia_fail_rate) or var_defaults.failRate
			end,
			setValue = function(arg_value)
				arg_values.hia_fail_rate = string.format("%d", math.floor(arg_value + 0.5))
			end,
			editType = optionmenu_aide.EditTypes.Slider,
			displayType = optionmenu_aide.DisplayTypes.Slider
		}
	}
end

local var_0_0 = native.EDifficultySliderCategory
local var_0_1 = var_0_0.AI
local var_0_2 = var_0_0.Evades
local var_0_3 = var_0_0.Passing
local var_0_4 = var_0_0.Referee
local var_0_5 = var_0_0.Tackles
local var_0_6 = var_0_0.Kicks
local var_0_7 = var_0_0.Misc
local var_0_8 = optionmenu_state.OptionMenuState

Class("CustomDifficultyEditState", var_0_8)

function CustomDifficultyEditState.enter(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7)
	local var_1_0 = arg_1_7.currentDifficulty
	local var_1_1 = arg_1_7.modifierIndex

	arg_1_0.goBackFactoryStack = arg_1_7.goBackFactoryStack

	local var_1_2 = arg_1_6.partyMember.settings
	local var_1_3 = settings_gameplaymodifiers_helper.constructSliderMenuItemsList(arg_1_2, var_1_2, var_1_0, {
		name = true,
		[var_0_1] = true,
		[var_0_2] = true,
		[var_0_3] = true,
		[var_0_4] = true,
		[var_0_5] = true,
		[var_0_6] = true,
		[var_0_7] = true
	})

	-- discipline-meter: MODDED section, saved under this difficulty's name on Back
	arg_1_0.moddedDifficulty = var_1_0

	local var_1_modded_sections = var_0_modded_read()
	local var_1_modded_values = {}

	for iter_1_0, iter_1_1 in pairs(var_1_0 and var_1_modded_sections[var_1_0.name] or {}) do
		var_1_modded_values[iter_1_0] = iter_1_1
	end

	var_1_modded_values.discipline = var_1_modded_values.discipline or "on"
	var_1_modded_values.discipline_strength = var_1_modded_values.discipline_strength or "1.00"
	arg_1_0.moddedValues = var_1_modded_values

	for iter_1_2, iter_1_3 in ipairs(var_0_modded_rows(var_1_modded_values)) do
		table.insert(var_1_3, iter_1_3)
	end

	for iter_1_4, iter_1_5 in ipairs(var_0_hia_rows(var_1_modded_values, var_1_0)) do
		table.insert(var_1_3, iter_1_5)
	end

	local var_1_4 = {
		width = 1200,
		noSpaceBeforePanel = true,
		examineSelectionBeforeExit = true,
		noTitleBox = true,
		scrollBarRight = true,
		backInputAllowed = true,
		displayCount = 20,
		homeInputAllowed = true,
		itemParams = {},
		scrollBar = {},
		titleBox = {
			left = true,
			title = native.Localise("CustomDifficulties")
		}
	}

	var_0_8.enter(arg_1_0, arg_1_2, arg_1_3, arg_1_4, arg_1_5, var_1_3, nil, var_1_4)

	local var_1_5 = native.UIWidgetArea(arg_1_2)

	var_1_5:setX(0, 1250)
	var_1_5:setY(0, 0)
	var_1_5:setWidth(0, 500)
	var_1_5:setHeight(0, 900)
	arg_1_0.contentArea:addChild(var_1_5)

	local var_1_6 = native.UIWidgetText(arg_1_2)

	var_1_6:setX(0, 0)
	var_1_6:setY(0, 120)
	var_1_6:setWidth(0, 500)
	var_1_6:setHeight(0, 20)

	var_1_6.font = native.Fonts.Display_M
	var_1_6.colour = native.SkinColours.DecalEditorText
	var_1_6.dropShadow = true
	var_1_6.alignHorizontal = native.TextAlign.Left
	var_1_6.alignVertical = native.TextAlign.Centre
	var_1_6.wrapPolicy = native.WrapPolicy.WrapText

	var_1_6:setText("")
	var_1_5:addChild(var_1_6)

	local var_1_7 = native.UIWidgetText(arg_1_2)

	var_1_7:setX(0, 0)
	var_1_7:setY(0, 160)
	var_1_7:setWidth(0, 500)
	var_1_7:setHeight(0, 800)

	var_1_7.font = native.Fonts.Row_M
	var_1_7.colour = native.SkinColours.DecalEditorText
	var_1_7.dropShadow = true
	var_1_7.alignHorizontal = native.TextAlign.Left
	var_1_7.alignVertical = native.TextAlign.Left
	var_1_7.wrapPolicy = native.WrapPolicy.WrapText

	var_1_7:setText("")
	var_1_5:addChild(var_1_7)

	arg_1_0.sliderTitleText = var_1_6
	arg_1_0.sliderDescriptionText = var_1_7
end

function CustomDifficultyEditState.update(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8)
	local var_2_0 = VERIFY(arg_2_8.partyMember)

	if arg_2_6:updateBlockingMixins(arg_2_2, arg_2_3, arg_2_4, arg_2_5) then
		return
	end

	local var_2_1, var_2_2, var_2_3, var_2_4 = var_0_8.update(arg_2_0, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, var_2_0:getInput())

	if var_2_2 then
		arg_2_0:updateSliderInfo(var_2_2)
	end

	if arg_2_6:checkForRelease(var_2_0, native.InputTypes.Decline) then
		arg_2_6:profileSaveFull(var_2_0)

		-- discipline-meter: the name may have been edited on this screen, so save under the new one
		if arg_2_0.moddedDifficulty and arg_2_0.moddedValues then
			var_0_modded_write(arg_2_0.moddedDifficulty.name, arg_2_0.moddedValues)
		end

		local var_2_5 = table.remove(arg_2_0.goBackFactoryStack, #arg_2_0.goBackFactoryStack)

		arg_2_1:changeState(var_2_5(), arg_2_2, arg_2_3, arg_2_5, arg_2_6, arg_2_8, arg_2_0.__proto, arg_2_0.goBackFactoryStack)
	end
end

function CustomDifficultyEditState.updateSliderInfo(arg_3_0, arg_3_1)
	-- discipline-meter: MODDED rows carry their text as is (no string table entries)
	if arg_3_1.modDescription then
		arg_3_0.sliderTitleText:setText(arg_3_1.label)
		arg_3_0.sliderDescriptionText:setText(arg_3_1.modDescription)
	elseif arg_3_1.detailedDescription then
		arg_3_0.sliderTitleText:setText(arg_3_1.label)
		arg_3_0.sliderDescriptionText:setText(native.Localise(arg_3_1.detailedDescription))
	else
		arg_3_0.sliderTitleText:setText("")
		arg_3_0.sliderDescriptionText:setText("")
	end
end
