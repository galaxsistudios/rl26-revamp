import("app.playermodel.playermodel_camera_aide")
import("app.academy.academy_editgroup_helper")
import("design.characters.assetmap")
import("app.academy.academy_helper")
import("app.academy.editassistant_helper")
import("core.foundation.tablex")

local var_0_0 = native.standalone
local var_0_1 = assetmap.AssetMapItems
local var_0_2 = assetmap.getItemByGuid
local var_0_3 = academy_editgroup_helper.createTopTierGroup
local var_0_4 = academy_editgroup_helper.createColourItem
local var_0_5 = academy_editgroup_helper.createColourBars
local var_0_6 = academy_editgroup_helper.createSecondTierGroup
local var_0_7 = academy_editgroup_helper.createOptionItem
local var_0_8 = academy_editgroup_helper.createSliderItem
local var_0_9 = academy_editgroup_helper.createLeftRightItem
local var_0_10 = academy_editgroup_helper.createToggleItem
local var_0_11 = academy_editgroup_helper.createColourBarsFromOptions
local var_0_12 = academy_editgroup_helper.createColourPickerTriangleFromOptions
local var_0_13 = academy_editgroup_helper.resetPlayerDefaults
local var_0_14 = academy_editgroup_helper.createDecalList
local var_0_15 = academy_editgroup_helper.createDecalListWithMinIndex
local var_0_16 = academy_editgroup_helper.createDecalMultiMenu
local var_0_17 = academy_editgroup_helper.createDecalAsymmetryList
local var_0_18 = academy_editgroup_helper.getEquipmentAdjustFn
local var_0_19 = academy_editgroup_helper.getLREquipmentAdjustFn
local var_0_20 = academy_editgroup_helper.getDecalsEnabledFn
local var_0_21 = academy_editgroup_helper.getColoursEnabledFn
local var_0_22 = academy_helper.ensureOptionIsValid

local function var_0_23(arg_1_0, arg_1_1, arg_1_2)
	return arg_1_0 and arg_1_0.debugHook and arg_1_0.debugHook.isArtist
end

local function var_0_24(arg_2_0, arg_2_1, arg_2_2)
	return var_0_23(arg_2_2) or arg_2_0.academy
end

-- official-jersey-editing: Manufacturer lists every player jersey, not only the ten
-- Academy cuts: the Academy ones plus each designed top (official, legacy and modded
-- kits) on a jersey mesh. Referee (tucked), polo, jacket, shirt and blouse tops stay out.
local function var_0_ojeIsJerseyTop(arg_item)
	local var_name = arg_item.name

	return var_name ~= nil and (var_name:match("^top_round%d+$") or var_name:match("^top_vneck%d+$") or var_name:match("^top_soft%d+$") or var_name:match("^top_flat%d+$")) ~= nil
end

local function var_0_ojeTopFilter(arg_item, arg_cfg, arg_info)
	return var_0_24(arg_item, arg_cfg, arg_info) or arg_item.colTexture ~= nil and var_0_ojeIsJerseyTop(arg_item)
end

-- picking a designed top resets its cut (the cut index shares an option with the
-- Academy collar's second colour, which a designed top doesn't use)
local function var_0_ojeSetTop(arg_value, arg_1, arg_viewInfo, arg_info, arg_item)
	local var_cfg = arg_viewInfo.getCurrentConfig()

	var_cfg:setOption("uniformTop", arg_value)

	if assetmap.setUniformTopTemplateIndex and assetmap.isUniformTopDesign(var_0_2(var_0_1.uniformTop, arg_value)) then
		assetmap.setUniformTopTemplateIndex(var_cfg, 0)
	end
end

-- official kits: Manufacturer picks a cut (UniformTopTemplates, in assetmap) for the
-- kit's own design, so the pattern can't change. First entry = the design's own cut.
local function var_0_ojeIsSameCut(arg_template, arg_design)
	return arg_template.name == arg_design.name and arg_template.nrmTexture == arg_design.nrmTexture and arg_template.matTexture == arg_design.matTexture
end

local function var_0_ojeCutList(arg_cfg, arg_info, arg_2)
	local var_list = {
		{
			guid = 0
		}
	}
	local var_design = var_0_2(var_0_1.uniformTop, arg_cfg:getOption("uniformTop"))

	if assetmap.isUniformTopDesign and assetmap.isUniformTopDesign(var_design) then
		for iter_index in ipairs(assetmap.UniformTopTemplates) do
			local var_template = assetmap.getUniformTopTemplate(iter_index)

			if var_template ~= nil and var_template.sex == var_design.sex and not var_0_ojeIsSameCut(var_template, var_design) then
				table.insert(var_list, {
					guid = iter_index
				})
			end
		end
	end

	return var_list, var_0_1.uniformTop
end

local function var_0_ojeGetCut(arg_1, arg_viewInfo)
	return assetmap.getUniformTopTemplateIndex(arg_viewInfo.getCurrentConfig())
end

local function var_0_ojeSetCut(arg_value, arg_1, arg_viewInfo)
	assetmap.setUniformTopTemplateIndex(arg_viewInfo.getCurrentConfig(), arg_value)
end

local function var_0_ojeCutLabel(arg_1, arg_viewInfo, arg_info)
	if not arg_viewInfo.getCurrentConfig then
		return ""
	end

	local var_cfg = arg_viewInfo.getCurrentConfig()
	local var_value = assetmap.getUniformTopTemplateIndex(var_cfg)

	for iter_position, iter_item in ipairs((var_0_ojeCutList(var_cfg, arg_info, arg_1))) do
		if iter_item.guid == var_value then
			return string.format("#%d", iter_position)
		end
	end

	return "#1"
end

local var_0_25 = trueFn
local var_0_26 = assetmap.NumDecalsOnTop / 6
local var_0_27 = {
	var_0_9(native.Localise("Manufacturer"), "uniformTop", {
		optionMap = "uniformTop",
		filterFn = var_0_ojeTopFilter,
		setValue = var_0_ojeSetTop,
		editLeftRightSpeedUp = true
	}),
	var_0_9(native.Localise("Team_Uniform_topPatternLayer01"), "uniformTop_patternLayer01", {
		optionMap = "uniformTop_patternLayers01_col"
	}),
	var_0_12(native.Localise("Team_Uniform_TopColour1"), "uniformTop_layer1_colour_r", "uniformTop_layer1_colour_g", "uniformTop_layer1_colour_b"),
	var_0_12(native.Localise("Team_Uniform_TopColour2"), "uniformTop_layer2_colour_r", "uniformTop_layer2_colour_g", "uniformTop_layer2_colour_b"),
	var_0_12(native.Localise("Team_Uniform_TopColour3"), "uniformTop_layer3_colour_r", "uniformTop_layer3_colour_g", "uniformTop_layer3_colour_b"),
	var_0_12(native.Localise("Team_Uniform_TopColour4"), "uniformTop_layer4_colour_r", "uniformTop_layer4_colour_g", "uniformTop_layer4_colour_b"),
	var_0_12(native.Localise("Team_Uniform_TopColour5"), "uniformTop_layer5_colour_r", "uniformTop_layer5_colour_g", "uniformTop_layer5_colour_b"),
	var_0_12(native.Localise("Team_Uniform_TopColour6"), "uniformTop_layer6_colour_r", "uniformTop_layer6_colour_g", "uniformTop_layer6_colour_b")
}
local var_0_28 = {
	var_0_16(native.Localise("EditDecals"), "decal", var_0_26, "Decal", var_0_25, 1),
	var_0_16(native.Localise("EditDecals"), "decal", var_0_26, "Decal", var_0_25, var_0_26 + 1),
	var_0_16(native.Localise("EditDecals"), "decal", var_0_26, "Decal", var_0_25, 2 * var_0_26 + 1),
	var_0_16(native.Localise("EditDecals"), "decal", var_0_26, "Decal", var_0_25, 3 * var_0_26 + 1),
	var_0_16(native.Localise("EditDecals"), "decal", var_0_26, "Decal", var_0_25, 4 * var_0_26 + 1),
	var_0_16(native.Localise("EditDecals"), "decal", var_0_26, "Decal", var_0_25, 5 * var_0_26 + 1)
}

tablex.iconcatInto(var_0_27, var_0_28)

-- official-jersey-editing: every number font (stock hides the NRL, QLD, NSW and Super
-- League logo fonts, guids 1, 3, 4 and 5, which most official kits use)
local var_0_29 = {
	var_0_10(native.Localise("Team_Uniform_NumberEnabled"), "hasNumber"),
	var_0_9(native.Localise("Team_Uniform_Font"), "numberFont", {
		optionMap = "numberFont"
	}),
	var_0_10(native.Localise("Team_Uniform_ShowLeadingZero"), "showLeadingZero"),
	var_0_12(native.Localise("Team_Uniform_NumberColour"), "numberColour1_r", "numberColour1_g", "numberColour1_b"),
	var_0_8(native.Localise("Team_Uniform_NumberKeylineWeight1"), {
		x = {
			"numberKeylineWeight",
			0,
			1
		}
	}),
	var_0_12(native.Localise("Team_Uniform_NumberKeylineColour"), "numberKeylineColour1_r", "numberKeylineColour1_g", "numberKeylineColour1_b"),
	var_0_8(native.Localise("Team_Uniform_NumberKeylineWeight2"), {
		x = {
			"numberKeylineWeight2",
			0,
			1
		}
	}),
	var_0_12(native.Localise("Team_Uniform_NumberKeylineColour2"), "numberKeylineColour2_r", "numberKeylineColour2_g", "numberKeylineColour2_b")
}
-- official-jersey-editing: the name on the back (player's Jersey Name; stock only had
-- these rows in the artist debug group) and the chest text for special matches (grand
-- finals, milestone games: the words are filled in on match day, the editor shows a
-- sample). Both are placed like a logo: the placement row hands the sticks to
-- updateTextPlacement (called by the jersey edit state while previewMode is set).
-- Labels are plain text: the string tables have no keys for them.
local var_0_ojeInput = editassistant_helper
local var_0_ojeMoveSpeed = 0.0035
local var_0_ojeSizeSpeed = 0.009

local function var_0_ojeLog(arg_text)
	pcall(function()
		local var_file = io.open("occasion_text_debug.txt", "a")

		if var_file then
			var_file:write(os.date("%H:%M:%S ") .. tostring(arg_text) .. "\n")
			var_file:close()
		end
	end)
end

local function var_0_ojePlacementRow(arg_label, arg_which)
	return academy_editgroup_helper.createDecalModifier(arg_label, {
		ojeTextPlacement = arg_which
	}, {
		onActivate = function(arg_1, arg_2, arg_3, arg_4, arg_5, arg_6, arg_viewInfo)
			-- placing the text switches it on (there'd be nothing to see otherwise)
			local var_cfg = arg_viewInfo.getCurrentConfig and arg_viewInfo.getCurrentConfig()
			local var_option = arg_which == "chest" and assetmap.OccasionTextOption or "hasPlayerName"

			if var_cfg and var_cfg:getOption(var_option) ~= 1 then
				var_cfg:setOption(var_option, 1)
				arg_viewInfo.refreshVisual()
			end

			arg_viewInfo.previewMode = true
			arg_viewInfo.visualProperties = {
				ojeTextPlacement = arg_which
			}
			arg_viewInfo.ojePlacementChanged = nil
		end
	})
end

local function var_0_ojeUpdatePlacement(arg_universe, arg_uiServices, arg_viewInfo)
	local var_which = arg_viewInfo.visualProperties.ojeTextPlacement
	local var_member = arg_universe:getParty():getPrimaryPartyMember()

	if var_0_ojeInput.backInputDetected(arg_uiServices, var_member) then
		arg_viewInfo.previewMode = nil

		if arg_viewInfo.ojePlacementChanged and arg_viewInfo.justCommittedToAChange then
			arg_viewInfo.justCommittedToAChange()
		end

		arg_viewInfo.ojePlacementChanged = nil

		return
	end

	local var_control = arg_universe:getGameControlManager()

	arg_uiServices:addTooltip(nil, native.InputTypes.LJoy, native.Localise("DecalPreviewPosition"), 10)
	arg_uiServices:addTooltip(nil, native.InputTypes.RJoyUpDown, native.Localise("DecalPreviewScale"), 25)
	arg_uiServices:addTooltip(nil, native.InputTypes.L3, "Reset", 45)
	arg_uiServices:addTooltip(nil, native.InputTypes.Decline, native.Localise("DecalAccept"), 50)

	local var_cfg = arg_viewInfo.getCurrentConfig()

	if var_0_ojeInput.l3InputDetected(var_member, var_control, true) then
		assetmap.resetJerseyTextPlacement(var_cfg, var_which)

		arg_viewInfo.ojePlacementChanged = true

		arg_viewInfo.refreshVisual()

		return
	end

	-- positive = right / up (as the colour picker reads them)
	local var_right = var_0_ojeInput.leftInputDetected(var_member, var_control, true) + var_0_ojeInput.rightInputDetected(var_member, var_control, true)
	local var_up = var_0_ojeInput.upInputDetected(var_member, var_control, true) + var_0_ojeInput.downInputDetected(var_member, var_control, true)
	local var_grow = var_0_ojeInput.rightStickUpInputDetected(var_member, var_control, true) + var_0_ojeInput.rightStickDownInputDetected(var_member, var_control, true)

	if var_right == 0 and var_up == 0 and var_grow == 0 then
		return
	end

	local var_x, var_y, var_scale = assetmap.getJerseyTextSliders(var_cfg, var_which)

	assetmap.setJerseyTextSliders(var_cfg, var_which, var_x + var_right * var_0_ojeMoveSpeed, var_y + var_up * var_0_ojeMoveSpeed, var_scale + var_grow * var_0_ojeSizeSpeed)

	arg_viewInfo.ojePlacementChanged = true

	arg_viewInfo.refreshVisual()
end

-- true while a placement row has the sticks; leaves the mode (and logs) on a failure
-- rather than locking the editor
function updateTextPlacement(arg_universe, arg_uiServices, arg_viewInfo)
	local var_properties = arg_viewInfo.visualProperties

	if not arg_viewInfo.previewMode or not var_properties or not var_properties.ojeTextPlacement then
		return false
	end

	local var_ok, var_error = pcall(var_0_ojeUpdatePlacement, arg_universe, arg_uiServices, arg_viewInfo)

	if not var_ok then
		var_0_ojeLog("text placement failed: " .. tostring(var_error))

		arg_viewInfo.previewMode = nil
	end

	return true
end

local var_0_ojeName = {
	var_0_10("Show name", "hasPlayerName"),
	var_0_9(native.Localise("Font"), "playerNameFont", {
		optionMap = "nameFont"
	}),
	var_0_12("Name colour", "nameColour1_r", "nameColour1_g", "nameColour1_b"),
	var_0_8("Name keyline weight", {
		x = {
			"nameKeylineWeight",
			0,
			1
		}
	}),
	var_0_12("Name keyline colour", "nameKeylineColour1_r", "nameKeylineColour1_g", "nameKeylineColour1_b")
}

if assetmap.JerseyTextPlacements then
	table.insert(var_0_ojeName, var_0_ojePlacementRow("Name placement", "name"))
end

-- "Placement test" is a session-only switch between the texture conventions until
-- one is confirmed in game
local var_0_ojeOccasion = {}

if assetmap.OccasionTextColour then
	var_0_ojeOccasion = {
		var_0_10("Chest text (special matches)", assetmap.OccasionTextOption),
		var_0_ojePlacementRow("Chest text placement", "chest"),
		var_0_10("Chest text auto colour (black/white)", assetmap.OccasionTextColourAuto),
		-- picking a colour turns auto colour off
		academy_editgroup_helper.createColourPickerTriangle("Chest text colour", {
			getValue = function(arg_1, arg_viewInfo)
				local var_cfg = arg_viewInfo.getCurrentConfig()
				local var_name = assetmap.OccasionTextColour

				return {
					x = var_cfg:getOption(var_name .. "_r"),
					y = var_cfg:getOption(var_name .. "_g"),
					z = var_cfg:getOption(var_name .. "_b")
				}
			end,
			onAdjustFn = function(arg_1, arg_viewInfo, arg_info, arg_colour)
				local var_cfg = arg_viewInfo.getCurrentConfig()
				local var_name = assetmap.OccasionTextColour

				var_cfg:setOption(var_name .. "_r", arg_colour.x)
				var_cfg:setOption(var_name .. "_g", arg_colour.y)
				var_cfg:setOption(var_name .. "_b", arg_colour.z)
				var_cfg:setOption(assetmap.OccasionTextColourAuto, 0)
			end
		}),
		var_0_8("Chest text keyline weight", {
			x = {
				assetmap.OccasionTextKeylineWeight,
				0,
				1
			}
		}),
		var_0_12("Chest text keyline colour", assetmap.OccasionTextKeylineColour .. "_r", assetmap.OccasionTextKeylineColour .. "_g", assetmap.OccasionTextKeylineColour .. "_b"),
		var_0_9("Placement test", assetmap.OccasionTextOption, {
			getUnfilteredList = function()
				return {
					{
						guid = 1
					},
					{
						guid = 2
					},
					{
						guid = 3
					},
					{
						guid = 4
					}
				}, nil
			end,
			getValue = function()
				return assetmap.getOccasionTextMode()
			end,
			setValue = function(arg_value)
				rawset(_G, "MOD_OCCASION_TEXT_MODE", arg_value)
			end,
			getAdditionalLabelFn = function()
				return tostring(assetmap.getOccasionTextMode())
			end
		})
	}
end

local var_0_30 = assetmap.NumDecalsOnBottom / 3
local var_0_31 = {
	var_0_9(native.Localise("Team_Uniform_bottomPatternLayer01"), "uniformBottom_patternLayer01", {
		optionMap = "uniformBottom_patternLayers01_col"
	}),
	var_0_12(native.Localise("Team_Uniform_BottomColour1"), "uniformBottom_layer1_colour_r", "uniformBottom_layer1_colour_g", "uniformBottom_layer1_colour_b"),
	var_0_12(native.Localise("Team_Uniform_BottomColour2"), "uniformBottom_layer2_colour_r", "uniformBottom_layer2_colour_g", "uniformBottom_layer2_colour_b"),
	var_0_12(native.Localise("Team_Uniform_BottomColour3"), "uniformBottom_layer3_colour_r", "uniformBottom_layer3_colour_g", "uniformBottom_layer3_colour_b"),
	var_0_12(native.Localise("Team_Uniform_BottomColour4"), "uniformBottom_layer4_colour_r", "uniformBottom_layer4_colour_g", "uniformBottom_layer4_colour_b")
}
local var_0_32 = {
	var_0_16(native.Localise("EditDecals"), "pantsDecal", var_0_30, "Decal", var_0_25, 1),
	var_0_16(native.Localise("EditDecals"), "pantsDecal", var_0_30, "Decal", var_0_25, var_0_30 + 1),
	var_0_16(native.Localise("EditDecals"), "pantsDecal", var_0_30, "Decal", var_0_25, 2 * var_0_30 + 1)
}

tablex.iconcatInto(var_0_31, var_0_32)

local var_0_33 = {
	var_0_9(native.Localise("Team_Uniform_socksPatternLayer01"), "uniformSocks_patternLayer01", {
		optionMap = "uniformSocks_patternLayers01_col"
	}),
	var_0_12(native.Localise("Team_Uniform_SocksColour1"), "uniformSocks_layer1_colour_r", "uniformSocks_layer1_colour_g", "uniformSocks_layer1_colour_b"),
	var_0_12(native.Localise("Team_Uniform_SocksColour2"), "uniformSocks_layer2_colour_r", "uniformSocks_layer2_colour_g", "uniformSocks_layer2_colour_b"),
	var_0_12(native.Localise("Team_Uniform_SocksColour3"), "uniformSocks_layer3_colour_r", "uniformSocks_layer3_colour_g", "uniformSocks_layer3_colour_b"),
	var_0_12(native.Localise("Team_Uniform_SocksColour4"), "uniformSocks_layer4_colour_r", "uniformSocks_layer4_colour_g", "uniformSocks_layer4_colour_b")
}
local var_0_34 = {
	var_0_9(native.Localise("Bottoms Manufacturer"), "uniformBottom", {
		optionMap = "uniformBottom",
		filterFn = var_0_24
	}),
	var_0_9(native.Localise("Socks Manufacturer"), "uniformSocks", {
		optionMap = "uniformSocks",
		filterFn = var_0_24
	}),
	var_0_10(native.Localise("Enabled"), "hasPlayerName"),
	var_0_9(native.Localise("Font"), "playerNameFont", {
		optionMap = "nameFont"
	}),
	var_0_11(native.Localise("NameColour"), "nameColour1_r", "nameColour1_g", "nameColour1_b"),
	var_0_8(native.Localise("nameKeylineWeight"), {
		x = {
			"nameKeylineWeight",
			0,
			1
		}
	}),
	var_0_11(native.Localise("NameKeylineColour"), "nameKeylineColour1_r", "nameKeylineColour1_g", "nameKeylineColour1_b")
}
local var_0_35 = {
	var_0_6("Jersey", "icon_jerseymodel", playermodel_camera_aide.ChestCloseUp, var_0_27),
	var_0_6("Jersey", "icon_jerseymodel", playermodel_camera_aide.ChestCloseUp, var_0_29),
	var_0_6("Name", "icon_jerseymodel", playermodel_camera_aide.ChestCloseUp, var_0_ojeName)
}

if #var_0_ojeOccasion > 0 then
	table.insert(var_0_35, var_0_6("Chest text", "icon_jerseymodel", playermodel_camera_aide.ChestCloseUp, var_0_ojeOccasion))
end

local var_0_36 = {
	var_0_6("Shorts", "icon_shorts", playermodel_camera_aide.LegsCloseUp, var_0_31)
}
local var_0_37 = {
	var_0_6("Socks", "icon_socks", playermodel_camera_aide.Boots, var_0_33)
}
local var_0_38 = {
	var_0_6("Debug", "icon_jerseymodel", playermodel_camera_aide.FullBody_NotRelativeToPlayerHeight, var_0_34)
}
local var_0_39 = var_0_3("Jersey", "app_jersey", false, var_0_35)
local var_0_40 = var_0_3("Trouser", "app_shorts", false, var_0_36)
local var_0_41 = var_0_3("Socks", "app_socks", false, var_0_37)

-- official-jersey-editing: official kits (and licensed copies) get the Jersey tab only,
-- with Manufacturer (cut, when jesse-southwell-hair's assetmap has the resolver) and the
-- number rows. Patterns, colours, logos, shorts and socks stay as designed.
local var_0_ojeOfficialJersey = {}

if assetmap.getUniformTopVariant then
	table.insert(var_0_ojeOfficialJersey, var_0_6("Jersey", "icon_jerseymodel", playermodel_camera_aide.ChestCloseUp, {
		var_0_9(native.Localise("Manufacturer"), assetmap.UniformTopTemplateOption, {
			getUnfilteredList = var_0_ojeCutList,
			getValue = var_0_ojeGetCut,
			setValue = var_0_ojeSetCut,
			getAdditionalLabelFn = var_0_ojeCutLabel
		})
	}))
end

table.insert(var_0_ojeOfficialJersey, var_0_6("Jersey", "icon_jerseymodel", playermodel_camera_aide.ChestCloseUp, var_0_29))
table.insert(var_0_ojeOfficialJersey, var_0_6("Name", "icon_jerseymodel", playermodel_camera_aide.ChestCloseUp, var_0_ojeName))

if #var_0_ojeOccasion > 0 then
	table.insert(var_0_ojeOfficialJersey, var_0_6("Chest text", "icon_jerseymodel", playermodel_camera_aide.ChestCloseUp, var_0_ojeOccasion))
end

-- read by copy-academy-jerseys' list state (official kits open in the editor) and by
-- the jersey edit state (which group list to use)
OfficialKitEditing = true
DebugGroup = var_0_3("Debug", "app_jersey", false, var_0_38)
LicensedGroupList = {
	var_0_3("Jersey", "app_jersey", false, var_0_ojeOfficialJersey)
}
CustomGroupList = {
	var_0_39,
	var_0_40,
	var_0_41
}
