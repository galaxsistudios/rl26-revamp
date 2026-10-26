local var_0_0 = import("design.characters.realisticcolour")
local var_0_1 = import("design.characters.assetmapitems")

blendShapes = import("design.characters.blendshapes").blendShapes

local var_0_2 = import("intermediatelua.data.jigglyjointsconfig").configs

AssetMapItems = var_0_1.ItemMaps

local var_0_3
local var_0_4 = {}
local var_0_5 = "rugby"
local var_0_6

var_0_6 = var_0_5 == "cricket"

local var_0_7

var_0_7 = var_0_5 == "lacrosse"

local var_0_8

var_0_8 = var_0_5 == "rugby"

local var_0_9

var_0_9 = var_0_5 == "tennis"

local var_0_10 = 2
local var_0_11 = 1
local var_0_12 = 1
local var_0_13 = 20
local var_0_14 = 10
local var_0_15 = 0

NumDecalsOnHead = 4
NumDecalsOnUpperBody = 4
NumDecalsOnLowerBody = 4
NumDecalsOnTop = 24
NumDecalsOnBottom = 12
ColourSwatches = {}

if native.CPlayerCollisionJoint then
	ASSERT(var_0_10 == native.CCharacterVisualConfig.CURRENT_VERSION)
	ASSERT(var_0_11 == native.CTeamVisualConfig.CURRENT_VERSION)

	var_0_3 = import("design.characters.texturedefinitions").Definitions
	var_0_4 = native.ECompositeTargetType
	ETextFit = native.ETextFit

	for iter_0_0, iter_0_1 in pairs(var_0_1.ColourSwatches) do
		local var_0_16 = native.CColourSwatch()

		var_0_16:append(iter_0_1)

		ColourSwatches[iter_0_0] = var_0_16
	end
end

local function var_0_17(arg_1_0)
	local var_1_0 = arg_1_0:getOption("head")

	return (getItemByGuid(AssetMapItems.tier1head, var_1_0))
end

-- jesse-southwell-hair: scanned heads listed here keep their face but take
-- their hair and headgear from the visual's hairTop/hairSide/hairSide2/
-- hairTexture_cap/helmet options, like a generic head, instead of the scan's
-- own head + 1000 items (1068 = Jesse Southwell)
GenericHairHeads = {
	[1068] = true
}

local function var_0_17_scanHair(arg_1_0)
	return var_0_17(arg_1_0) and not GenericHairHeads[arg_1_0:getOption("head")]
end

local function var_0_18(arg_2_0)
	return arg_2_0:getOption("head") ~= 0
end

local function var_0_19(arg_3_0)
	local var_3_0 = var_0_17(arg_3_0)

	return var_3_0 and var_3_0.tier2 and true or false
end

local function var_0_20(arg_4_0)
	local var_4_0 = "hairTop"
	local var_4_1 = arg_4_0:getOption(var_4_0)

	return (getItemByGuid(AssetMapItems.hairTop, var_4_1))
end

local function var_0_21(arg_5_0)
	local var_5_0 = "hairSide"
	local var_5_1 = arg_5_0:getOption(var_5_0)

	return (getItemByGuid(AssetMapItems.hairSide, var_5_1))
end

local function var_0_22(arg_6_0)
	local var_6_0 = "hairSide2"
	local var_6_1 = arg_6_0:getOption(var_6_0)

	return (getItemByGuid(AssetMapItems.hairSide2, var_6_1))
end

local function var_0_23(arg_7_0)
	local var_7_0 = "hairTexture_cap"
	local var_7_1 = arg_7_0:getOption(var_7_0)

	return (getItemByGuid(AssetMapItems.hairCap_col, var_7_1))
end

local function var_0_24(arg_8_0)
	local var_8_0 = "moustache"
	local var_8_1 = arg_8_0:getOption(var_8_0)

	return (getItemByGuid(AssetMapItems.moustache, var_8_1))
end

local function var_0_25(arg_9_0)
	local var_9_0 = "chinhair"
	local var_9_1 = arg_9_0:getOption(var_9_0)

	return (getItemByGuid(AssetMapItems.chinhair, var_9_1))
end

local function var_0_26(arg_10_0)
	local var_10_0 = "sideburns"
	local var_10_1 = arg_10_0:getOption(var_10_0)

	return (getItemByGuid(AssetMapItems.sideburns, var_10_1))
end

local function var_0_27(arg_11_0)
	local var_11_0 = arg_11_0:getOption("uniformTop")

	return (getItemByGuid(AssetMapItems.uniformTop, var_11_0))
end

local function var_0_28(arg_12_0)
	local var_12_0 = arg_12_0:getOption("uniformBottom")

	return (getItemByGuid(AssetMapItems.uniformBottom, var_12_0))
end

local function var_0_29(arg_13_0)
	local var_13_0 = arg_13_0:getOption("uniformSocks")

	return (getItemByGuid(AssetMapItems.uniformSocks, var_13_0))
end

local function var_0_30(arg_14_0)
	local var_14_0 = arg_14_0:getOption("shoes")

	return (getItemByGuid(AssetMapItems.shoes, var_14_0))
end

local function var_0_31(arg_15_0)
	local var_15_0 = arg_15_0:getOption("helmet")

	return (getItemByGuid(AssetMapItems.helmet, var_15_0))
end

local function var_0_32(arg_16_0, arg_16_1)
	local var_16_0 = arg_16_0 and arg_16_0.baseItemName

	if var_16_0 then
		arg_16_0 = getItemByGuidName(AssetMapItems[arg_16_1], var_16_0)
	end

	return arg_16_0
end

local function var_0_33(arg_17_0)
	if arg_17_0:getOption("sex") == 1 then
		return false
	end

	local var_17_0 = var_0_24(arg_17_0)
	local var_17_1 = var_0_25(arg_17_0)
	local var_17_2 = var_0_26(arg_17_0)
	local var_17_3 = var_17_0 and not var_17_0.noModel
	local var_17_4 = var_17_1 and not var_17_1.noModel
	local var_17_5 = var_17_2 and not var_17_2.noModel

	return var_17_3 or var_17_4 or var_17_5
end

local var_0_34 = {
	0.22,
	0.44999999999999996,
	0.78,
	0.55
}

local function var_0_35(arg_18_0, arg_18_1, arg_18_2, arg_18_3)
	local var_18_0 = arg_18_0:getOption("sex")
	local var_18_1 = var_0_27(arg_18_1).nameOffset
	local var_18_2 = 0
	local var_18_3 = var_18_1 and var_18_1.offsetY or 0
	local var_18_4 = var_18_1 and var_18_1.scale or 1
	local var_18_5 = (var_0_34[4] - var_0_34[2]) / 2
	local var_18_6 = var_18_4 - 1
	local var_18_7 = var_0_34[2] - var_18_5 * var_18_6
	local var_18_8 = var_0_34[4] + var_18_5 * var_18_6
	local var_18_9 = var_18_7 - var_18_3
	local var_18_10 = var_18_8 - var_18_3

	return (native.vec4(var_0_34[1], var_18_9, var_0_34[3], var_18_10))
end

local function var_0_36(arg_19_0, arg_19_1)
	local var_19_0 = arg_19_0:getOption("shirtNumber")
	local var_19_1 = var_19_0 % 10
	local var_19_2 = math.floor(var_19_0 / 10)
	local var_19_3 = {
		var_19_1,
		var_19_2
	}

	if var_19_0 < 10 and arg_19_1:getOption("showLeadingZero") == 0 then
		var_19_3[2] = nil
	end

	return var_19_3
end

local function var_0_37(arg_20_0, arg_20_1, arg_20_2)
	if arg_20_1:getOption("hasNumber") == 0 then
		return nil
	end

	local var_20_0 = var_0_36(arg_20_0, arg_20_1)[arg_20_2]

	return var_20_0 and "top_number" .. var_20_0 .. "_col"
end

local function var_0_38(arg_21_0, arg_21_1, arg_21_2, arg_21_3)
	local var_21_0 = var_0_37(arg_21_0, arg_21_1, arg_21_2)

	if var_21_0 == nil then
		return nil
	end

	return (getItemByGuid(AssetMapItems[var_21_0], arg_21_3))
end

local function var_0_39(arg_22_0, arg_22_1, arg_22_2)
	if arg_22_1:getOption("hasNumber") == 0 then
		return nil
	end

	local var_22_0 = arg_22_1:getOption("numberFont")
	local var_22_1 = getItemByGuid(AssetMapItems.numberFont, var_22_0)
	local var_22_2 = var_0_36(arg_22_0, arg_22_1)[arg_22_2]

	if var_22_2 and var_22_1 and var_22_1.logo then
		local var_22_3 = var_22_1.overrides and var_22_1.overrides[var_22_2] and var_22_1.overrides[var_22_2].logo

		return "shirtNumber_" .. var_22_1.logo .. "_logo" .. (var_22_3 and "_" .. var_22_2 or "") .. "_col"
	end
end

local function var_0_40(arg_23_0, arg_23_1, arg_23_2, arg_23_3)
	local var_23_0 = {}
	local var_23_1 = arg_23_0:getOption("sex")
	local var_23_2 = var_0_27(arg_23_1).numberOffset
	local var_23_3 = 0
	local var_23_4 = var_23_2 and var_23_2.offsetY or 0
	local var_23_5 = var_23_2 and var_23_2.scale or 1
	local var_23_6 = var_0_36(arg_23_0, arg_23_1)
	local var_23_7 = arg_23_2 == 1 and 2 or 1
	local var_23_8 = var_23_6[arg_23_2]
	local var_23_9 = var_23_6[var_23_7]
	local var_23_10 = var_23_2 and var_23_2.aspect or 1
	local var_23_11 = 0
	local var_23_12 = arg_23_2 == 1 and 1 or -1
	local var_23_13

	var_23_13 = var_23_7 == 1 and 1 or -1

	if var_23_6[2] ~= nil then
		local var_23_14 = arg_23_1:getOption("numberFont")
		local var_23_15 = getItemByGuid(AssetMapItems.numberFont, var_23_14)

		if var_23_9 and var_23_15 and var_23_15.offset then
			var_23_11 = var_23_15.overrides and var_23_15.overrides[var_23_9] and var_23_15.overrides[var_23_9].offset or var_23_15.offset
		end
	end

	var_23_0.offsetX = var_23_3 + var_23_11 * var_23_5 * var_23_10 * var_23_12
	var_23_0.offsetY = var_23_4
	var_23_0.scale = var_23_5
	var_23_0.aspect = var_23_10

	return var_23_0
end

local function var_0_41(arg_24_0)
	return var_0_27(arg_24_0).academy and true or false
end

headColourLayers = {
	{
		map = "head_thickness",
		guid = 0
	},
	{
		map = "head_col",
		option = "skinTexture"
	},
	{
		map = "ugc_player_head_col",
		option = "ugcHead"
	},
	{
		option = "ethnicityShapeMorph_option",
		map = function(arg_25_0)
			return arg_25_0:getOption("sex") == 0 and "m_ethnicity_col" or "f_ethnicity_col"
		end
	},
	{
		guid = 0,
		map = "redness_head_col",
		intensity = "redness_cheeks_amount"
	},
	{
		guid = 1,
		map = "redness_head_col",
		intensity = "redness_face_amount"
	},
	{
		guid = 2,
		map = "redness_head_col",
		intensity = "redness_nose_amount"
	},
	{
		guid = 0,
		map = "highlights_head_col",
		intensity = "highlightsBrow_amount"
	},
	{
		guid = 1,
		map = "highlights_head_col",
		intensity = "highlightsCheeks_amount"
	},
	{
		guid = 2,
		map = "highlights_head_col",
		intensity = "highlightsChin_amount"
	},
	{
		guid = 3,
		map = "highlights_head_col",
		intensity = "highlightsMouth_amount"
	},
	{
		guid = 4,
		map = "highlights_head_col",
		intensity = "highlightsNose_amount"
	},
	{
		guid = 0,
		map = "liptint_head_col",
		intensity = "lipTint_amount"
	},
	{
		map = "eyeSocketTint_type",
		option = "eyeSocketTint_type"
	},
	{
		map = "freckles_head_col",
		option = "freckles_type"
	},
	{
		map = "mole_head_col",
		option = "mole_head_type"
	},
	{
		map = "scar_head_col",
		option = "scar_type"
	},
	{
		map = "crows_feet_col",
		option = "crowsFeet_option"
	},
	{
		map = "leftNeckTattoo_head",
		option = "leftNeckTattoo_type"
	},
	{
		map = "rightNeckTattoo_head",
		option = "rightNeckTattoo_type"
	},
	{
		map = "midNeckTattoo_head",
		option = "midNeckTattoo_type"
	},
	{
		map = "bodyHair_head_col",
		option = "bodyHair_type",
		tints = function(arg_26_0)
			local var_26_0 = arg_26_0:getOption("bodyHair_colour")
			local var_26_1 = AssetMapItems.hairColours
			local var_26_2 = getHairColorTableByGuid(var_26_1, var_26_0)

			return {
				{
					A = 1,
					r = var_26_2[1] / 255,
					g = var_26_2[2] / 255,
					b = var_26_2[3] / 255
				},
				{
					A = 1,
					r = var_26_2[1] / 255,
					g = var_26_2[2] / 255,
					b = var_26_2[3] / 255
				}
			}
		end
	},
	{
		map = "eyebrows_head_col",
		option = "eyebrows_type",
		tints = function(arg_27_0)
			local var_27_0 = arg_27_0:getOption("bodyHair_colour")
			local var_27_1 = AssetMapItems.hairColours
			local var_27_2 = getHairColorTableByGuid(var_27_1, var_27_0)

			return {
				{
					A = 1,
					r = var_27_2[1] / 255,
					g = var_27_2[2] / 255,
					b = var_27_2[3] / 255
				},
				{
					A = 1,
					r = var_27_2[1] / 255,
					g = var_27_2[2] / 255,
					b = var_27_2[3] / 255
				}
			}
		end
	},
	{
		map = "leftNeckTattoo_head",
		option = "leftNeckTattoo_type"
	},
	{
		map = "rightNeckTattoo_head",
		option = "rightNeckTattoo_type"
	},
	{
		map = "midNeckTattoo_head",
		option = "midNeckTattoo_type"
	},
	{
		map = "player_head_teeth_col",
		guid = 0
	}
}
headMaterialLayers = {
	{
		map = "head_base_mat",
		guid = 0
	},
	{
		option = "ethnicityShapeMorph_option",
		map = function(arg_28_0)
			return arg_28_0:getOption("sex") == 0 and "m_ethnicity_mat" or "f_ethnicity_mat"
		end
	},
	{
		map = "eyebrows_head_mat",
		option = "eyebrows_type"
	},
	{
		map = "player_head_teeth_mat",
		guid = 0
	}
}
headNormalLayers = {
	{
		option = "bodyPhysiqueMorph_option",
		map = function(arg_29_0)
			return arg_29_0:getOption("sex") == 0 and "m_player_head_overlay_nrm" or "f_player_head_overlay_nrm"
		end
	},
	{
		option = "ethnicityShapeMorph_option",
		map = function(arg_30_0)
			return arg_30_0:getOption("sex") == 0 and "m_ethnicity_nrm" or "f_ethnicity_nrm"
		end
	},
	{
		map = "scar_head_nrm",
		option = "scar_type"
	},
	{
		map = "mole_head_nrm",
		option = "mole_head_type"
	},
	{
		map = "eyebrows_head_nrm",
		option = "eyebrows_type"
	},
	{
		map = "bodyHair_head_nrm",
		option = "bodyHair_type"
	},
	{
		map = "player_head_teeth_nrm",
		guid = 0
	}
}
headMskLayers = {
	{
		map = "head_msk",
		guid = 0
	}
}
tier1_headColourLayers = {
	{
		map = "head_thickness",
		guid = 0
	},
	{
		map = "tier1head_textures_col",
		option = "head"
	},
	{
		map = "leftNeckTattoo_head",
		option = "leftNeckTattoo_type"
	},
	{
		map = "rightNeckTattoo_head",
		option = "rightNeckTattoo_type"
	},
	{
		map = "midNeckTattoo_head",
		option = "midNeckTattoo_type"
	},
	{
		map = "bodyHair_head_col",
		option = "bodyHair_type",
		tints = function(arg_31_0)
			local var_31_0 = arg_31_0:getOption("bodyHair_colour")
			local var_31_1 = AssetMapItems.hairColours
			local var_31_2 = getHairColorTableByGuid(var_31_1, var_31_0)

			return {
				{
					A = 1,
					r = var_31_2[1] / 255,
					g = var_31_2[2] / 255,
					b = var_31_2[3] / 255
				},
				{
					A = 1,
					r = var_31_2[1] / 255,
					g = var_31_2[2] / 255,
					b = var_31_2[3] / 255
				}
			}
		end
	},
	{
		map = "player_head_teeth_col",
		guid = 0
	}
}
tier1_headMaterialLayers = {
	{
		map = "head_base_mat",
		guid = 0
	},
	{
		map = "tier1head_textures_mat",
		option = "head"
	},
	{
		map = "bodyHair_head_mat",
		option = "bodyHair_type"
	},
	{
		map = "player_head_teeth_mat",
		guid = 0
	}
}
tier1_headNormalLayers = {
	{
		map = "tier1head_textures_nrm",
		option = "head"
	},
	{
		map = "bodyHair_head_nrm",
		option = "bodyHair_type"
	},
	{
		map = "player_head_teeth_nrm",
		guid = 0
	}
}
eyesColourLayers = {
	{
		map = "eye_textures_base_col",
		guidName = "eye_thickness"
	},
	{
		map = "eye_textures_col",
		option = "eyeTexture"
	},
	{
		map = "limbal_ring_col",
		option = "limbal_ring_option"
	},
	{
		map = "eye_textures_base_col",
		guidName = function(arg_32_0)
			local var_32_0 = "eyeTexture"

			return arg_32_0:getOption(var_32_0) == 99 and "" or "sclera_col"
		end
	},
	{
		map = "eye_textures_base_col",
		guidName = "shadow_col"
	}
}
bodyColourLayers = {
	{
		map = "body_thickness",
		guid = 0
	},
	{
		map = "body_col",
		option = "skinTexture"
	},
	{
		map = "freckles_body_col",
		option = "freckles_type"
	},
	{
		map = "leftArmTattoo_body",
		option = "leftArmTattoo_type"
	},
	{
		map = "rightArmTattoo_body",
		option = "rightArmTattoo_type"
	},
	{
		map = "leftLegTattoo_body",
		option = "leftLegTattoo_type"
	},
	{
		map = "rightLegTattoo_body",
		option = "rightLegTattoo_type"
	},
	{
		map = "bodyHair_body_col",
		option = "bodyHair_type",
		tints = function(arg_33_0)
			local var_33_0 = arg_33_0:getOption("bodyHair_colour")
			local var_33_1 = AssetMapItems.hairColours
			local var_33_2 = getHairColorTableByGuid(var_33_1, var_33_0)

			return {
				{
					A = 1,
					r = var_33_2[1] / 255,
					g = var_33_2[2] / 255,
					b = var_33_2[3] / 255
				},
				{
					A = 1,
					r = var_33_2[1] / 255,
					g = var_33_2[2] / 255,
					b = var_33_2[3] / 255
				}
			}
		end
	},
	{
		map = "strapping_shoulderRight_col",
		option = "strapping_shoulderRight_option"
	},
	{
		map = "strapping_shoulderLeft_col",
		option = "strapping_shoulderLeft_option"
	},
	{
		map = "strapping_elbowRight_col",
		option = "strapping_elbowRight_option"
	},
	{
		map = "strapping_elbowLeft_col",
		option = "strapping_elbowLeft_option"
	},
	{
		map = "strapping_handRight_col",
		option = "strapping_handRight_option"
	},
	{
		map = "strapping_handLeft_col",
		option = "strapping_handLeft_option"
	},
	{
		map = "strapping_wristRight_col",
		option = "strapping_wristRight_option"
	},
	{
		map = "strapping_wristLeft_col",
		option = "strapping_wristLeft_option"
	},
	{
		map = "strapping_fingerpinkyRight_col",
		option = "strapping_fingerpinkyRight_option"
	},
	{
		map = "strapping_fingerringRight_col",
		option = "strapping_fingerringRight_option"
	},
	{
		map = "strapping_fingermiddleRight_col",
		option = "strapping_fingermiddleRight_option"
	},
	{
		map = "strapping_fingerpointerRight_col",
		option = "strapping_fingerpointerRight_option"
	},
	{
		map = "strapping_fingerpinkyLeft_col",
		option = "strapping_fingerpinkyLeft_option"
	},
	{
		map = "strapping_fingerringLeft_col",
		option = "strapping_fingerringLeft_option"
	},
	{
		map = "strapping_fingermiddleLeft_col",
		option = "strapping_fingermiddleLeft_option"
	},
	{
		map = "strapping_fingerpointerLeft_col",
		option = "strapping_fingerpointerLeft_option"
	},
	{
		map = "strapping_kneeRight_col",
		option = "strapping_kneeRight_option"
	},
	{
		map = "strapping_kneeLeft_col",
		option = "strapping_kneeLeft_option"
	},
	{
		map = "strapping_armbandLeft_col",
		option = "strapping_armbandLeft_option"
	},
	{
		map = "strapping_armbandRight_col",
		option = "strapping_armbandRight_option"
	},
	{
		map = "strapping_thighRight_col",
		option = "strapping_thighRight_option"
	},
	{
		map = "strapping_thighLeft_col",
		option = "strapping_thighLeft_option"
	},
	{
		map = "compression_col",
		option = "compression_option"
	},
	{
		map = "skins_left_col",
		option = "skins_left_option"
	},
	{
		map = "skins_right_col",
		option = "skins_right_option"
	}
}
bodyMaterialLayers = {
	{
		map = "body_base_mat",
		guid = 0
	},
	{
		map = "strapping_shoulderRight_mat",
		option = "strapping_shoulderRight_option"
	},
	{
		map = "strapping_shoulderLeft_mat",
		option = "strapping_shoulderLeft_option"
	},
	{
		map = "strapping_elbowRight_mat",
		option = "strapping_elbowRight_option"
	},
	{
		map = "strapping_elbowLeft_mat",
		option = "strapping_elbowLeft_option"
	},
	{
		map = "strapping_handRight_mat",
		option = "strapping_handRight_option"
	},
	{
		map = "strapping_handLeft_mat",
		option = "strapping_handLeft_option"
	},
	{
		map = "strapping_wristRight_mat",
		option = "strapping_wristRight_option"
	},
	{
		map = "strapping_wristLeft_mat",
		option = "strapping_wristLeft_option"
	},
	{
		map = "strapping_fingerpinkyRight_mat",
		option = "strapping_fingerpinkyRight_option"
	},
	{
		map = "strapping_fingerringRight_mat",
		option = "strapping_fingerringRight_option"
	},
	{
		map = "strapping_fingermiddleRight_mat",
		option = "strapping_fingermiddleRight_option"
	},
	{
		map = "strapping_fingerpointerRight_mat",
		option = "strapping_fingerpointerRight_option"
	},
	{
		map = "strapping_fingerpinkyLeft_mat",
		option = "strapping_fingerpinkyLeft_option"
	},
	{
		map = "strapping_fingerringLeft_mat",
		option = "strapping_fingerringLeft_option"
	},
	{
		map = "strapping_fingermiddleLeft_mat",
		option = "strapping_fingermiddleLeft_option"
	},
	{
		map = "strapping_fingerpointerLeft_mat",
		option = "strapping_fingerpointerLeft_option"
	},
	{
		map = "strapping_kneeRight_mat",
		option = "strapping_kneeRight_option"
	},
	{
		map = "strapping_kneeLeft_mat",
		option = "strapping_kneeLeft_option"
	},
	{
		map = "strapping_armbandLeft_mat",
		option = "strapping_armbandLeft_option"
	},
	{
		map = "strapping_armbandRight_mat",
		option = "strapping_armbandRight_option"
	},
	{
		map = "strapping_thighRight_mat",
		option = "strapping_thighRight_option"
	},
	{
		map = "strapping_thighLeft_mat",
		option = "strapping_thighLeft_option"
	},
	{
		map = "compression_mat",
		option = "compression_option"
	},
	{
		map = "skins_left_mat",
		option = "skins_left_option"
	},
	{
		map = "skins_right_mat",
		option = "skins_right_option"
	}
}
bodyNormalLayers = {
	{
		option = "bodyPhysiqueMorph_option",
		map = function(arg_34_0)
			return arg_34_0:getOption("sex") == 0 and "m_body_nrm" or "f_body_nrm"
		end
	},
	{
		map = "bodyHair_body_nrm",
		option = "bodyHair_type"
	},
	{
		map = "strapping_shoulderRight_nrm",
		option = "strapping_shoulderRight_option"
	},
	{
		map = "strapping_shoulderLeft_nrm",
		option = "strapping_shoulderLeft_option"
	},
	{
		map = "strapping_elbowRight_nrm",
		option = "strapping_elbowRight_option"
	},
	{
		map = "strapping_elbowLeft_nrm",
		option = "strapping_elbowLeft_option"
	},
	{
		map = "strapping_handRight_nrm",
		option = "strapping_handRight_option"
	},
	{
		map = "strapping_handLeft_nrm",
		option = "strapping_handLeft_option"
	},
	{
		map = "strapping_wristRight_nrm",
		option = "strapping_wristRight_option"
	},
	{
		map = "strapping_wristLeft_nrm",
		option = "strapping_wristLeft_option"
	},
	{
		map = "strapping_fingerpinkyRight_nrm",
		option = "strapping_fingerpinkyRight_option"
	},
	{
		map = "strapping_fingerringRight_nrm",
		option = "strapping_fingerringRight_option"
	},
	{
		map = "strapping_fingermiddleRight_nrm",
		option = "strapping_fingermiddleRight_option"
	},
	{
		map = "strapping_fingerpointerRight_nrm",
		option = "strapping_fingerpointerRight_option"
	},
	{
		map = "strapping_fingerpinkyLeft_nrm",
		option = "strapping_fingerpinkyLeft_option"
	},
	{
		map = "strapping_fingerringLeft_nrm",
		option = "strapping_fingerringLeft_option"
	},
	{
		map = "strapping_fingermiddleLeft_nrm",
		option = "strapping_fingermiddleLeft_option"
	},
	{
		map = "strapping_fingerpointerLeft_nrm",
		option = "strapping_fingerpointerLeft_option"
	},
	{
		map = "strapping_kneeRight_nrm",
		option = "strapping_kneeRight_option"
	},
	{
		map = "strapping_kneeLeft_nrm",
		option = "strapping_kneeLeft_option"
	},
	{
		map = "strapping_armbandLeft_nrm",
		option = "strapping_armbandLeft_option"
	},
	{
		map = "strapping_armbandRight_nrm",
		option = "strapping_armbandRight_option"
	},
	{
		map = "strapping_thighRight_nrm",
		option = "strapping_thighRight_option"
	},
	{
		map = "strapping_thighLeft_nrm",
		option = "strapping_thighLeft_option"
	},
	{
		map = "compression_nrm",
		option = "compression_option"
	},
	{
		map = "skins_left_nrm",
		option = "skins_left_option"
	},
	{
		map = "skins_right_nrm",
		option = "skins_right_option"
	}
}
bodyMskLayers = {
	{
		map = "body_msk",
		guid = 0
	},
	{
		map = "strapping_shoulderRight_msk",
		option = "strapping_shoulderRight_option"
	},
	{
		map = "strapping_shoulderLeft_msk",
		option = "strapping_shoulderLeft_option"
	},
	{
		map = "strapping_elbowRight_msk",
		option = "strapping_elbowRight_option"
	},
	{
		map = "strapping_elbowLeft_msk",
		option = "strapping_elbowLeft_option"
	},
	{
		map = "strapping_handRight_msk",
		option = "strapping_handRight_option"
	},
	{
		map = "strapping_handLeft_msk",
		option = "strapping_handLeft_option"
	},
	{
		map = "strapping_wristRight_msk",
		option = "strapping_wristRight_option"
	},
	{
		map = "strapping_wristLeft_msk",
		option = "strapping_wristLeft_option"
	},
	{
		map = "strapping_fingerpinkyRight_msk",
		option = "strapping_fingerpinkyRight_option"
	},
	{
		map = "strapping_fingerringRight_msk",
		option = "strapping_fingerringRight_option"
	},
	{
		map = "strapping_fingermiddleRight_msk",
		option = "strapping_fingermiddleRight_option"
	},
	{
		map = "strapping_fingerpointerRight_msk",
		option = "strapping_fingerpointerRight_option"
	},
	{
		map = "strapping_fingerpinkyLeft_msk",
		option = "strapping_fingerpinkyLeft_option"
	},
	{
		map = "strapping_fingerringLeft_msk",
		option = "strapping_fingerringLeft_option"
	},
	{
		map = "strapping_fingermiddleLeft_msk",
		option = "strapping_fingermiddleLeft_option"
	},
	{
		map = "strapping_fingerpointerLeft_msk",
		option = "strapping_fingerpointerLeft_option"
	},
	{
		map = "strapping_kneeRight_msk",
		option = "strapping_kneeRight_option"
	},
	{
		map = "strapping_kneeLeft_msk",
		option = "strapping_kneeLeft_option"
	},
	{
		map = "strapping_armbandLeft_msk",
		option = "strapping_armbandLeft_option"
	},
	{
		map = "strapping_armbandRight_msk",
		option = "strapping_armbandRight_option"
	},
	{
		map = "strapping_thighRight_msk",
		option = "strapping_thighRight_option"
	},
	{
		map = "strapping_thighLeft_msk",
		option = "strapping_thighLeft_option"
	},
	{
		map = "compression_msk",
		option = "compression_option"
	},
	{
		map = "skins_left_nrm",
		option = "skins_left_option"
	},
	{
		map = "skins_right_nrm",
		option = "skins_right_option"
	}
}
beardCapColourLayers = {
	{
		map = "beardCap_col",
		guidName = function(arg_35_0)
			local var_35_0 = var_0_24(arg_35_0)

			return var_35_0 and var_35_0.colTexture_cap
		end
	},
	{
		map = "beardCap_col",
		guidName = function(arg_36_0)
			local var_36_0 = var_0_25(arg_36_0)

			return var_36_0 and var_36_0.colTexture_cap
		end
	},
	{
		map = "beardCap_col",
		guidName = function(arg_37_0)
			local var_37_0 = var_0_26(arg_37_0)

			return var_37_0 and var_37_0.colTexture_cap
		end
	}
}
uniformTopColourLayers = {
	{
		map = "uniformTop_col",
		cfg = "t",
		guidName = function(arg_38_0, arg_38_1, arg_38_2)
			local var_38_0 = var_0_27(arg_38_2)

			return var_38_0 and var_38_0.colTexture
		end
	},
	{
		guid = 0,
		cfg = "t",
		map = function(arg_39_0, arg_39_1, arg_39_2)
			if var_0_27(arg_39_2).colTexture then
				return nil
			end

			return "uniformTop_patternBase_col"
		end,
		tints = {
			{
				g = "uniformTop_layer1_colour_g",
				b = "uniformTop_layer1_colour_b",
				r = "uniformTop_layer1_colour_r"
			}
		}
	},
	{
		option = "uniformTop_patternLayer01",
		cfg = "t",
		map = function(arg_40_0, arg_40_1, arg_40_2)
			if var_0_27(arg_40_2).colTexture then
				return nil
			end

			return "uniformTop_patternLayers01_col"
		end,
		tints = {
			{
				g = "uniformTop_layer2_colour_g",
				b = "uniformTop_layer2_colour_b",
				r = "uniformTop_layer2_colour_r"
			},
			{
				g = "uniformTop_layer3_colour_g",
				b = "uniformTop_layer3_colour_b",
				r = "uniformTop_layer3_colour_r"
			},
			{
				g = "uniformTop_layer4_colour_g",
				b = "uniformTop_layer4_colour_b",
				r = "uniformTop_layer4_colour_r"
			}
		}
	},
	{
		map = "uniformTop_collarLayers01_col",
		cfg = "t",
		guidName = function(arg_41_0, arg_41_1, arg_41_2)
			local var_41_0 = var_0_27(arg_41_2)

			return var_41_0 and var_41_0.collarLayer
		end,
		tints = {
			{
				g = "uniformTop_layer5_colour_g",
				b = "uniformTop_layer5_colour_b",
				r = "uniformTop_layer5_colour_r"
			},
			{
				g = "uniformTop_layer6_colour_g",
				b = "uniformTop_layer6_colour_b",
				r = "uniformTop_layer6_colour_r"
			}
		}
	},
	{
		tattooEffect = false,
		potentialAsymmetry = false,
		decalName = "decal",
		cfg = "t",
		decalCount = NumDecalsOnTop
	}
}
uniformTopMaterialLayers = {
	{
		map = "uniformTop_mat",
		cfg = "t",
		guidName = function(arg_42_0)
			local var_42_0 = var_0_27(arg_42_0)

			return var_42_0.sex .. "_" .. var_42_0.name .. "_base_mat"
		end
	},
	{
		map = "uniformTop_mat",
		cfg = "t",
		guidName = function(arg_43_0, arg_43_1, arg_43_2)
			local var_43_0 = var_0_27(arg_43_2)

			return arg_43_1:getOption("topType") == 1 and var_43_0.matTexture2 or var_43_0.matTexture
		end
	}
}
uniformTopNormalLayers = {
	{
		map = "uniformTop_nrm",
		cfg = "t",
		guidName = function(arg_44_0)
			local var_44_0 = var_0_27(arg_44_0)

			return var_44_0.sex .. "_" .. var_44_0.name .. "_base_nrm"
		end
	},
	{
		map = "uniformTop_nrm",
		cfg = "t",
		guidName = function(arg_45_0, arg_45_1, arg_45_2)
			local var_45_0 = var_0_27(arg_45_2)

			return arg_45_1:getOption("topType") == 1 and var_45_0.nrmTexture2 or var_45_0.nrmTexture
		end
	}
}
uniformNumberLayers = {
	{
		map = "top_number_base_col",
		tintCfg = "t",
		guidName = "shirtNumber_base_col",
		baseTint = function(arg_46_0, arg_46_1, arg_46_2)
			return arg_46_2:getOption("numberKeylineWeight") > 0 and "numberKeylineColour1" or "numberColour1"
		end,
		tintColourRealistic = function(arg_47_0, arg_47_1, arg_47_2)
			return var_0_41(arg_47_2)
		end
	},
	{
		colour1Intensity = "numberKeylineWeight",
		blend = "creator_uniformnumber_keyline_tint",
		option = "numberFont",
		colour2Intensity = "numberKeylineWeight2",
		cfg = "t",
		map = function(arg_48_0, arg_48_1, arg_48_2)
			return (var_0_37(arg_48_1, arg_48_2, 1))
		end,
		tintPosition = function(arg_49_0, arg_49_1, arg_49_2)
			local var_49_0 = var_0_40(arg_49_1, arg_49_2, 1)

			return {
				"numberKeylineColour1",
				"numberKeylineColour2",
				{
					x = var_49_0.offsetX,
					y = var_49_0.offsetY,
					z = var_49_0.scale,
					w = var_49_0.aspect
				}
			}
		end,
		tintColourRealistic = function(arg_50_0, arg_50_1, arg_50_2)
			return var_0_41(arg_50_2)
		end
	},
	{
		colour1Intensity = "numberKeylineWeight",
		blend = "creator_uniformnumber_keyline_tint",
		option = "numberFont",
		colour2Intensity = "numberKeylineWeight2",
		cfg = "t",
		map = function(arg_51_0, arg_51_1, arg_51_2)
			return (var_0_37(arg_51_1, arg_51_2, 2))
		end,
		tintPosition = function(arg_52_0, arg_52_1, arg_52_2)
			local var_52_0 = var_0_40(arg_52_1, arg_52_2, 2)

			return {
				"numberKeylineColour1",
				"numberKeylineColour2",
				{
					x = var_52_0.offsetX,
					y = var_52_0.offsetY,
					z = var_52_0.scale,
					w = var_52_0.aspect
				}
			}
		end,
		tintColourRealistic = function(arg_53_0, arg_53_1, arg_53_2)
			return var_0_41(arg_53_2)
		end
	},
	{
		option = "numberFont",
		cfg = "t",
		map = function(arg_54_0, arg_54_1, arg_54_2)
			return (var_0_37(arg_54_1, arg_54_2, 1))
		end,
		tintPosition = function(arg_55_0, arg_55_1, arg_55_2)
			local var_55_0 = var_0_40(arg_55_1, arg_55_2, 1)

			return {
				"numberColour1",
				"numberColour2",
				{
					x = var_55_0.offsetX,
					y = var_55_0.offsetY,
					z = var_55_0.scale,
					w = var_55_0.aspect
				}
			}
		end,
		tintColourRealistic = function(arg_56_0, arg_56_1, arg_56_2)
			return var_0_41(arg_56_2)
		end
	},
	{
		map = "top_number_logo_col",
		cfg = "t",
		guidName = function(arg_57_0, arg_57_1, arg_57_2)
			return (var_0_39(arg_57_1, arg_57_2, 1))
		end,
		tintPosition = function(arg_58_0, arg_58_1, arg_58_2)
			local var_58_0 = var_0_40(arg_58_1, arg_58_2, 1, "logo")

			return {
				"numberLogoColour1",
				"numberLogoColour2",
				{
					x = var_58_0.offsetX,
					y = var_58_0.offsetY,
					z = var_58_0.scale,
					w = var_58_0.aspect
				}
			}
		end
	},
	{
		option = "numberFont",
		cfg = "t",
		map = function(arg_59_0, arg_59_1, arg_59_2)
			return (var_0_37(arg_59_1, arg_59_2, 2))
		end,
		tintPosition = function(arg_60_0, arg_60_1, arg_60_2)
			local var_60_0 = var_0_40(arg_60_1, arg_60_2, 2)

			return {
				"numberColour1",
				"numberColour2",
				{
					x = var_60_0.offsetX,
					y = var_60_0.offsetY,
					z = var_60_0.scale,
					w = var_60_0.aspect
				}
			}
		end,
		tintColourRealistic = function(arg_61_0, arg_61_1, arg_61_2)
			return var_0_41(arg_61_2)
		end
	},
	{
		map = "top_number_logo_col",
		cfg = "t",
		guidName = function(arg_62_0, arg_62_1, arg_62_2)
			return (var_0_39(arg_62_1, arg_62_2, 2))
		end,
		tintPosition = function(arg_63_0, arg_63_1, arg_63_2)
			local var_63_0 = var_0_40(arg_63_1, arg_63_2, 2, "logo")

			return {
				"numberLogoColour1",
				"numberLogoColour2",
				{
					x = var_63_0.offsetX,
					y = var_63_0.offsetY,
					z = var_63_0.scale,
					w = var_63_0.aspect
				}
			}
		end
	},
	{
		uvWindow = function(arg_64_0, arg_64_1)
			return (var_0_35(arg_64_0, arg_64_1))
		end,
		enabled = function(arg_65_0, arg_65_1)
			return arg_65_1:getOption("hasPlayerName") == 1
		end,
		text = function(arg_66_0, arg_66_1)
			return (arg_66_0:getOption("shirtName"))
		end,
		rotation = function(arg_67_0, arg_67_1)
			return 0
		end,
		textFit = function(arg_68_0, arg_68_1)
			return ETextFit.Min
		end,
		fontName = function(arg_69_0, arg_69_1)
			local var_69_0 = getItemByGuid(AssetMapItems.nameFont, arg_69_1:getOption("playerNameFont"))

			return var_69_0 and var_69_0.name or ""
		end,
		fontScale = function(arg_70_0, arg_70_1)
			return 1
		end,
		fontYOffset = function(arg_71_0, arg_71_1)
			return 0
		end,
		fontWeight = function(arg_72_0, arg_72_1)
			return 1
		end,
		baseColour = function(arg_73_0, arg_73_1)
			local var_73_0 = var_0_41(arg_73_1)

			return ColourFullRangeOptionToVec(arg_73_1, "nameColour1", var_73_0)
		end,
		fillColour = function(arg_74_0, arg_74_1)
			local var_74_0 = var_0_41(arg_74_1)

			return ColourFullRangeOptionToVec(arg_74_1, "nameColour1", var_74_0)
		end,
		keylineWeight = function(arg_75_0, arg_75_1)
			return (arg_75_1:getOption("nameKeylineWeight"))
		end,
		keylineColour = function(arg_76_0, arg_76_1)
			local var_76_0 = var_0_41(arg_76_1)

			return ColourFullRangeOptionToVec(arg_76_1, "nameKeylineColour1", var_76_0)
		end
	}
}
uniformBottomColourLayers = {
	{
		map = "uniformBottom_col",
		cfg = "t",
		guidName = function(arg_77_0, arg_77_1, arg_77_2)
			local var_77_0 = var_0_28(arg_77_2)

			return var_77_0 and var_77_0.colTexture
		end
	},
	{
		guid = 0,
		cfg = "t",
		map = function(arg_78_0, arg_78_1, arg_78_2)
			if var_0_28(arg_78_2).colTexture then
				return nil
			end

			return "uniformBottom_patternBase_col"
		end,
		tints = {
			{
				g = "uniformBottom_layer1_colour_g",
				b = "uniformBottom_layer1_colour_b",
				r = "uniformBottom_layer1_colour_r"
			}
		}
	},
	{
		option = "uniformBottom_patternLayer01",
		cfg = "t",
		map = function(arg_79_0, arg_79_1, arg_79_2)
			if var_0_28(arg_79_2).colTexture then
				return nil
			end

			return "uniformBottom_patternLayers01_col"
		end,
		tints = {
			{
				g = "uniformBottom_layer2_colour_g",
				b = "uniformBottom_layer2_colour_b",
				r = "uniformBottom_layer2_colour_r"
			},
			{
				g = "uniformBottom_layer3_colour_g",
				b = "uniformBottom_layer3_colour_b",
				r = "uniformBottom_layer3_colour_r"
			},
			{
				g = "uniformBottom_layer4_colour_g",
				b = "uniformBottom_layer4_colour_b",
				r = "uniformBottom_layer4_colour_r"
			}
		}
	},
	{
		tattooEffect = false,
		potentialAsymmetry = false,
		decalName = "pantsDecal",
		cfg = "t",
		decalCount = NumDecalsOnBottom
	}
}
uniformBottomMaterialLayers = {
	{
		map = "uniformBottom_mat",
		cfg = "t",
		guidName = function(arg_80_0)
			local var_80_0 = var_0_28(arg_80_0)

			return var_80_0.sex .. "_" .. var_80_0.name .. "_base_mat"
		end
	},
	{
		map = "uniformBottom_mat",
		cfg = "t",
		guidName = function(arg_81_0, arg_81_1, arg_81_2)
			return var_0_28(arg_81_2).matTexture
		end
	}
}
uniformBottomNormalLayers = {
	{
		map = "uniformBottom_nrm",
		cfg = "t",
		guidName = function(arg_82_0)
			local var_82_0 = var_0_28(arg_82_0)

			return var_82_0.sex .. "_" .. var_82_0.name .. "_base_nrm"
		end
	},
	{
		map = "uniformBottom_nrm",
		cfg = "t",
		guidName = function(arg_83_0, arg_83_1, arg_83_2)
			return var_0_28(arg_83_2).nrmTexture
		end
	}
}
uniformSocksColourLayers = {
	{
		map = "uniformSocks_col",
		cfg = "t",
		guidName = function(arg_84_0, arg_84_1, arg_84_2)
			local var_84_0 = var_0_29(arg_84_2)

			return var_84_0 and var_84_0.colTexture
		end
	},
	{
		guid = 0,
		cfg = "t",
		map = function(arg_85_0, arg_85_1, arg_85_2)
			if var_0_29(arg_85_2).colTexture then
				return nil
			end

			return "uniformSocks_patternBase_col"
		end,
		tints = {
			{
				g = "uniformSocks_layer1_colour_g",
				b = "uniformSocks_layer1_colour_b",
				r = "uniformSocks_layer1_colour_r"
			}
		}
	},
	{
		option = "uniformSocks_patternLayer01",
		cfg = "t",
		map = function(arg_86_0, arg_86_1, arg_86_2)
			if var_0_29(arg_86_2).colTexture then
				return nil
			end

			return "uniformSocks_patternLayers01_col"
		end,
		tints = {
			{
				g = "uniformSocks_layer2_colour_g",
				b = "uniformSocks_layer2_colour_b",
				r = "uniformSocks_layer2_colour_r"
			},
			{
				g = "uniformSocks_layer3_colour_g",
				b = "uniformSocks_layer3_colour_b",
				r = "uniformSocks_layer3_colour_r"
			},
			{
				g = "uniformSocks_layer4_colour_g",
				b = "uniformSocks_layer4_colour_b",
				r = "uniformSocks_layer4_colour_r"
			}
		}
	}
}
uniformSocksMaterialLayers = {
	{
		map = "uniformSocks_mat",
		cfg = "t",
		guidName = function(arg_87_0, arg_87_1, arg_87_2)
			return var_0_29(arg_87_2).matTexture
		end
	}
}
uniformSocksNormalLayers = {
	{
		map = "uniformSocks_nrm",
		cfg = "t",
		guidName = function(arg_88_0, arg_88_1, arg_88_2)
			return var_0_29(arg_88_2).nrmTexture
		end
	}
}
helmetColourLayers = {
	{
		map = "helmet_col",
		guidName = function(arg_89_0, arg_89_1, arg_89_2)
			return var_0_31(arg_89_0).colTexture
		end,
		tints = function(arg_90_0, arg_90_1, arg_90_2)
			local var_90_0 = var_0_31(arg_90_0)
			local var_90_1 = {
				{
					g = "headwearColour1_g",
					b = "headwearColour1_b",
					r = "headwearColour1_r"
				},
				{
					g = "headwearColour2_g",
					b = "headwearColour2_b",
					r = "headwearColour2_r"
				},
				{
					g = "headwearColour3_g",
					b = "headwearColour3_b",
					r = "headwearColour3_r"
				},
				{
					g = "headwearColour4_g",
					b = "headwearColour4_b",
					r = "headwearColour4_r"
				}
			}
			local var_90_2 = {
				{
					g = "headStrappingColour1_g",
					b = "headStrappingColour1_b",
					r = "headStrappingColour1_r"
				},
				{
					g = "headStrappingColour2_g",
					b = "headStrappingColour2_b",
					r = "headStrappingColour2_r"
				}
			}

			return var_90_0.headStrapping and var_90_2 or var_90_1
		end
	}
}
helmetMaterialLayers = {
	{
		map = "helmet_mat",
		guidName = function(arg_91_0, arg_91_1, arg_91_2)
			return var_0_31(arg_91_0).matTexture
		end
	}
}
helmetNormalLayers = {
	{
		map = "helmet_nrm",
		guidName = function(arg_92_0, arg_92_1, arg_92_2)
			return var_0_31(arg_92_0).nrmTexture
		end
	}
}
shoesColourLayers = {
	{
		map = "shoes_col",
		guidName = function(arg_93_0, arg_93_1, arg_93_2)
			return var_0_30(arg_93_1).colTexture
		end,
		tints = {
			{
				g = "shoeColour1_g",
				b = "shoeColour1_b",
				r = "shoeColour1_r"
			},
			{
				g = "shoeColour2_g",
				b = "shoeColour2_b",
				r = "shoeColour2_r"
			},
			{
				g = "shoeColour3_g",
				b = "shoeColour3_b",
				r = "shoeColour3_r"
			},
			{
				g = "shoeColour4_g",
				b = "shoeColour4_b",
				r = "shoeColour4_r"
			}
		}
	}
}

local function var_0_42(arg_94_0, arg_94_1, arg_94_2)
	for iter_94_0, iter_94_1 in pairs(arg_94_0) do
		if arg_94_2 and arg_94_2(iter_94_1, arg_94_1) or iter_94_1 == arg_94_1 then
			return true
		end
	end
end

function getItemByOption(arg_95_0, arg_95_1, arg_95_2)
	local var_95_0 = arg_95_0:getOption(arg_95_1)

	return getItemByGuid(AssetMapItems[arg_95_2 or arg_95_1], var_95_0)
end

function getItemByGuid(arg_96_0, arg_96_1)
	if not arg_96_0 then
		native.breakpoint()

		return
	end

	local var_96_0 = arg_96_0.item_setup_lookup

	if var_96_0 then
		return var_96_0[arg_96_1]
	else
		local var_96_1 = arg_96_0.item_setup or arg_96_0

		for iter_96_0, iter_96_1 in ipairs(var_96_1) do
			if iter_96_1.guid == arg_96_1 then
				return iter_96_1
			end
		end
	end
end

function getItemByGuidName(arg_97_0, arg_97_1)
	local var_97_0 = arg_97_0.item_setup_lookup

	if var_97_0 then
		return var_97_0[arg_97_1]
	else
		for iter_97_0, iter_97_1 in ipairs(arg_97_0.item_setup) do
			if iter_97_1.name == arg_97_1 then
				return iter_97_1
			end
		end
	end
end

function getHairColorTableByGuid(arg_98_0, arg_98_1)
	for iter_98_0, iter_98_1 in ipairs(arg_98_0) do
		if iter_98_1.guid == arg_98_1 then
			return iter_98_1.colour
		end
	end
end

function ifilter(arg_99_0, arg_99_1, arg_99_2, arg_99_3)
	local var_99_0 = {}

	for iter_99_0, iter_99_1 in arg_99_1, arg_99_2, arg_99_3 do
		if arg_99_0(iter_99_0, iter_99_1) then
			table.insert(var_99_0, iter_99_1)
		end
	end

	return var_99_0
end

function filterBySex(arg_100_0, arg_100_1)
	local var_100_0 = getItemByGuidName(AssetMapItems.sex, "Male").guid
	local var_100_1 = getItemByGuidName(AssetMapItems.sex, "Female").guid

	return ifilter(function(arg_101_0, arg_101_1)
		local var_101_0 = arg_101_1.sex

		if var_101_0 then
			if arg_100_1 == var_100_0 and not var_101_0:find("m", 1, true) then
				return false
			end

			if arg_100_1 == var_100_1 and not var_101_0:find("f", 1, true) then
				return false
			end
		end

		return true
	end, ipairs(arg_100_0))
end

function validatePermutationGuid(arg_102_0, arg_102_1, arg_102_2)
	for iter_102_0, iter_102_1 in pairs(arg_102_1) do
		if iter_102_1 == arg_102_0 and string.find(arg_102_2, iter_102_0) then
			return true
		end
	end

	return false
end

function getPermutationItemByGuid(arg_103_0, arg_103_1, arg_103_2, arg_103_3)
	local var_103_0 = AssetMapItems[arg_103_3]
	local var_103_1 = arg_103_0.permutationMap[arg_103_3]
	local var_103_2 = arg_103_2.permutations[arg_103_3]

	if var_103_2 == "" then
		return {}
	end

	local var_103_3 = validatePermutationGuid(arg_103_1, var_103_1, var_103_2)

	if not var_103_3 then
		local var_103_4 = arg_103_2.backupPermutations or arg_103_0.backupPermutations
		local var_103_5 = var_103_4 and var_103_4[arg_103_3]

		if var_103_5 then
			arg_103_1 = var_103_1[var_103_5[arg_103_1]]
			var_103_3 = validatePermutationGuid(arg_103_1, var_103_1, var_103_2)
		end
	end

	if not var_103_3 then
		if arg_103_2.noModelMissingPermutations then
			return nil
		else
			arg_103_1 = var_103_1[var_103_2:sub(1, 1)]
		end
	end

	return getItemByGuid(var_103_0, arg_103_1)
end

function getModelFileNameByGuidName(arg_104_0, arg_104_1, arg_104_2, arg_104_3, arg_104_4, arg_104_5)
	local var_104_0 = getItemByGuidName(arg_104_1, arg_104_0)
	local var_104_1, var_104_2, var_104_3 = getModelFileNameByItem(var_104_0, arg_104_1, arg_104_2, arg_104_3, arg_104_4, arg_104_5)

	return var_104_1, var_104_2, var_104_3
end

function getModelFileNameByGuid(arg_105_0, arg_105_1, arg_105_2, arg_105_3, arg_105_4, arg_105_5)
	local var_105_0 = getItemByGuid(arg_105_1, arg_105_0)
	local var_105_1, var_105_2, var_105_3 = getModelFileNameByItem(var_105_0, arg_105_1, arg_105_2, arg_105_3, arg_105_4, arg_105_5)

	return var_105_1, var_105_2, var_105_3
end

function getModelFileNameByItem(arg_106_0, arg_106_1, arg_106_2, arg_106_3, arg_106_4, arg_106_5)
	if not arg_106_0 or arg_106_0.noModel then
		return nil
	end

	if arg_106_0.sex then
		local var_106_0 = arg_106_2:getOption("sex") == getItemByGuidName(AssetMapItems.sex, "Male").guid

		if var_106_0 and not arg_106_0.sex:find("m", 1, true) then
			return nil
		end

		if not var_106_0 and not arg_106_0.sex:find("f", 1, true) then
			return nil
		end
	end

	local var_106_1 = arg_106_1.namePrefix or ""
	local var_106_2 = var_106_1 .. (arg_106_0.modelName or arg_106_0.name)
	local var_106_3 = arg_106_1.permutationOrder

	if var_106_3 then
		for iter_106_0, iter_106_1 in pairs(var_106_3) do
			local var_106_4 = arg_106_5 and arg_106_5[iter_106_1] or arg_106_4 and arg_106_4[iter_106_1] and arg_106_3:getOption(iter_106_1) or arg_106_2:getOption(iter_106_1)
			local var_106_5 = getPermutationItemByGuid(arg_106_1, var_106_4, arg_106_0, iter_106_1)

			if var_106_5 == nil and arg_106_0.noModelMissingPermutations then
				return nil
			end

			if var_106_5 and var_106_5.name and var_106_5.name ~= "" then
				var_106_2 = var_106_2 .. "_" .. var_106_5.name
			end
		end
	end

	local var_106_6 = arg_106_1.basePath .. "/models/" .. var_106_2 .. "/" .. var_106_2
	local var_106_7 = arg_106_0.collision and arg_106_1.basePath .. "/collision/" .. var_106_1 .. arg_106_0.collision or ""
	local var_106_8 = arg_106_0.wrinkleConfigUseName and string.sub(var_106_6, var_106_6:match("^.*()/") + 1) or arg_106_0.wrinkleConfig and arg_106_0.wrinkleConfig or ""

	return var_106_6, var_106_7, var_106_8
end

function getModelGuid(arg_107_0, arg_107_1, arg_107_2, arg_107_3, arg_107_4, arg_107_5, arg_107_6, arg_107_7)
	local var_107_0 = AssetMapItems[arg_107_1]

	ASSERT(var_107_0)

	local var_107_1 = arg_107_5 and arg_107_5[arg_107_0] or arg_107_4 and arg_107_4[arg_107_0] and arg_107_3:getOption(arg_107_0) or arg_107_2:getOption(arg_107_0)

	if arg_107_6 then
		arg_107_7 = arg_107_7 or arg_107_6

		local var_107_2 = arg_107_5 and arg_107_5[arg_107_6] or arg_107_4 and arg_107_4[arg_107_6] and arg_107_3:getOption(arg_107_6) or arg_107_2:getOption(arg_107_6)
		local var_107_3 = getItemByGuid(AssetMapItems[arg_107_7], var_107_2).subOptions[arg_107_1]

		if var_107_3 and not var_0_42(var_107_3, var_107_1) then
			var_107_1 = var_107_3[1]
		end
	end

	return var_107_1, var_107_0
end

function getModelFileName(arg_108_0, arg_108_1, arg_108_2, arg_108_3, arg_108_4, arg_108_5, arg_108_6, arg_108_7)
	local var_108_0, var_108_1 = getModelGuid(arg_108_0, arg_108_1, arg_108_2, arg_108_3, arg_108_4, arg_108_5, arg_108_6, arg_108_7)

	return getModelFileNameByGuid(var_108_0, var_108_1, arg_108_2, arg_108_3, arg_108_4, arg_108_5)
end

function getItemByOption(arg_109_0, arg_109_1, arg_109_2)
	local var_109_0 = arg_109_0:getOption(arg_109_1)

	return getItemByGuid(AssetMapItems[arg_109_2 or arg_109_1], var_109_0)
end

function range2(arg_110_0, arg_110_1, arg_110_2)
	local var_110_0 = arg_110_0:getOption(arg_110_1)

	ASSERT(var_110_0, string.format("Need to have option named %s", arg_110_1))
	ASSERT(var_110_0 >= 0 and var_110_0 <= 1)

	return native.lerp1(var_110_0, arg_110_2[1], arg_110_2[2])
end

function clampScale(arg_111_0, arg_111_1, arg_111_2, arg_111_3)
	local var_111_0 = arg_111_0:getOption(arg_111_1)

	ASSERT(var_111_0, string.format("Need to have option named %s", arg_111_1))

	local var_111_1 = math.max(arg_111_2[1], var_111_0)
	local var_111_2 = (math.min(arg_111_2[2], var_111_1) - arg_111_2[1]) / (arg_111_2[2] - arg_111_2[1])

	return native.lerp1(var_111_2, arg_111_3[1], arg_111_3[2])
end

function ColourOptionToVec(arg_112_0, arg_112_1, arg_112_2)
	local var_112_0 = arg_112_0:getOption(arg_112_1)
	local var_112_1 = ColourSwatches[arg_112_2]

	return var_112_1 and var_112_1:getAt(var_112_0)
end

function YCrCbToRGB(arg_113_0)
	local var_113_0 = arg_113_0.x
	local var_113_1 = arg_113_0.y - 0.5
	local var_113_2 = arg_113_0.z - 0.5

	return native.vec3(native.clamp1(var_113_0 + 1.402 * var_113_2, 0, 1), native.clamp1(var_113_0 - 0.344136 * var_113_1 - 0.714136 * var_113_2, 0, 1), native.clamp1(var_113_0 + 1.772 * var_113_1, 0, 1))
end

function RGBToYCrCb(arg_114_0)
	local var_114_0 = arg_114_0.x * 0.299 + arg_114_0.y * 0.587 + arg_114_0.z * 0.114
	local var_114_1 = 0.5 + arg_114_0.x * -0.168736 + arg_114_0.y * -0.331264 + arg_114_0.z * 0.5
	local var_114_2 = 0.5 + arg_114_0.x * 0.5 + arg_114_0.y * -0.418688 + arg_114_0.z * -0.081312

	return native.vec3(native.clamp1(var_114_0, 0, 1), native.clamp1(var_114_1, 0, 1), native.clamp1(var_114_2, 0, 1))
end

function ColourFullRangeOptionToVec(arg_115_0, arg_115_1, arg_115_2)
	local var_115_0 = arg_115_0:getOption(arg_115_1 .. "_r")
	local var_115_1 = arg_115_0:getOption(arg_115_1 .. "_g")
	local var_115_2 = arg_115_0:getOption(arg_115_1 .. "_b")

	ASSERT(var_115_0 and var_115_1 and var_115_2)

	local var_115_3 = native.vec4(var_115_0, var_115_1, var_115_2, 1)

	return arg_115_2 and var_0_0.make(var_115_3) or native.vec4(var_115_3.x, var_115_3.y, var_115_3.z, 1)
end

function ColourFullRangeOptionToVec2(arg_116_0, arg_116_1, arg_116_2)
	local var_116_0 = arg_116_0:getOption(arg_116_1 .. "_r")
	local var_116_1 = arg_116_0:getOption(arg_116_1 .. "_g")
	local var_116_2 = arg_116_0:getOption(arg_116_1 .. "_b")

	ASSERT(var_116_0 and var_116_1 and var_116_2)

	local var_116_3 = native.vec4(var_116_0, var_116_1, var_116_2, 1)

	return arg_116_2 and var_0_0.make(var_116_3) or native.vec4(var_116_3.x, var_116_3.y, var_116_3.z, 1)
end

function AppendTexSrcLayers(arg_117_0, arg_117_1, arg_117_2, arg_117_3)
	assert(not arg_117_2[arg_117_3])

	local var_117_0 = {}

	arg_117_2[arg_117_3] = var_117_0

	local var_117_1 = getItemByGuidName(AssetMapItems.sex, "Male").guid
	local var_117_2 = getItemByGuidName(AssetMapItems.sex, "Female").guid

	local function var_117_3(arg_118_0)
		local var_118_0 = arg_118_0.configSelectFn or function(arg_119_0, arg_119_1)
			local var_119_0 = arg_118_0.cfg or "p"
			local var_119_1 = arg_118_0.cfgSelectOption
			local var_119_2 = arg_118_0.tintCfg or var_119_0
			local var_119_3 = arg_118_0.tintCfgSelectOption
			local var_119_4 = var_119_0 == "p" and arg_119_0 or arg_119_1

			if var_119_1 then
				var_119_4 = arg_119_0:getOption(var_119_1) == 0 and arg_119_0 or arg_119_1
			end

			local var_119_5 = var_119_2 and (var_119_2 == "p" and arg_119_0 or arg_119_1) or var_119_4

			if var_119_3 then
				var_119_5 = arg_119_0:getOption(var_119_3) == 0 and arg_119_0 or arg_119_1
			end

			return var_119_4, var_119_5
		end

		local function var_118_1(arg_120_0, arg_120_1)
			local var_120_0 = arg_118_0.guidName
			local var_120_1 = arg_118_0.option
			local var_120_2 = arg_118_0.map
			local var_120_3 = arg_118_0.guid
			local var_120_4 = arg_118_0.intensity
			local var_120_5 = arg_118_0.intensityRange
			local var_120_6 = arg_118_0.tints
			local var_120_7 = arg_118_0.baseTint
			local var_120_8 = arg_118_0.position
			local var_120_9 = arg_118_0.tintPosition
			local var_120_10 = arg_118_0.alpha
			local var_120_11 = arg_118_0.tintColourRealistic and arg_118_0.tintColourRealistic or false
			local var_120_12 = arg_118_0.blend

			ASSERT(var_120_2)

			local var_120_13, var_120_14 = var_118_0(arg_120_0, arg_120_1)
			local var_120_15 = 1

			if var_120_4 then
				if type(var_120_4) == "function" then
					var_120_4 = var_120_4(var_120_13, arg_120_0, arg_120_1)
				end

				if type(var_120_4) == "number" then
					var_120_15 = var_120_4
				else
					var_120_15 = var_120_13:getOption(var_120_4) or 0

					local var_120_16 = options.player[var_120_4]

					if type(var_120_16) == "table" and var_120_5 then
						local var_120_17 = var_120_16.range

						if var_120_17 then
							local var_120_18 = native.lerp1(var_120_15, var_120_17[1], var_120_17[2])

							if var_120_5 == "pos" then
								var_120_15 = var_120_18 / math.max(var_120_17[1], var_120_17[2])
							else
								var_120_15 = var_120_18 / math.min(var_120_17[1], var_120_17[2])
							end
						end
					end
				end

				if var_120_15 <= 0 then
					return
				end
			end

			if var_120_11 and type(var_120_11) == "function" then
				var_120_11 = var_120_11(var_120_13, arg_120_0, arg_120_1)
			end

			if type(var_120_2) == "function" then
				var_120_2 = var_120_2(var_120_13, arg_120_0, arg_120_1)
			end

			if type(var_120_2) == "string" then
				var_120_2 = AssetMapItems[var_120_2]
			end

			if var_120_2 == nil then
				return
			end

			local var_120_19

			if var_120_3 then
				if type(var_120_3) == "function" then
					var_120_3 = var_120_3(var_120_13, arg_120_0, arg_120_1)
				end

				var_120_19 = getItemByGuid(var_120_2, var_120_3)
			elseif var_120_1 then
				if type(var_120_1) == "function" then
					var_120_1 = var_120_1(var_120_13, arg_120_0, arg_120_1)
				end

				local var_120_20 = var_120_13:getOption(var_120_1)

				var_120_19 = getItemByGuid(var_120_2, var_120_20)
			elseif var_120_0 then
				if type(var_120_0) == "function" then
					var_120_0 = var_120_0(var_120_13, arg_120_0, arg_120_1)
				end

				var_120_19 = getItemByGuidName(var_120_2, var_120_0)
			end

			if not var_120_19 or var_120_19.noLayer then
				return
			end

			local var_120_21 = var_120_13:getOption("sex")
			local var_120_22 = var_120_19.sex

			if var_120_22 then
				if var_120_21 == var_117_1 and not var_120_22:find("m", 1, true) then
					return
				end

				if var_120_21 == var_117_2 and not var_120_22:find("f", 1, true) then
					return
				end
			end

			local var_120_23 = native.CTexSrcDef()

			var_120_23.technique = var_120_12 or var_120_19.blend
			var_120_23.amount = var_120_15

			local var_120_24 = var_120_2.namePrefix or ""

			var_120_23.fileName = string.format("%s/%s%s", var_120_2.basePath, var_120_24, var_120_19.name)

			if var_120_19.entryOnly then
				ASSERT(var_120_19.uuidOption)

				local var_120_25 = var_120_13:getOption(var_120_19.uuidOption)

				var_120_23.uuidName = tostring(var_120_25)
			end

			local var_120_26 = native.vec4.One()

			if var_120_6 then
				if type(var_120_6) == "function" then
					var_120_6 = var_120_6(var_120_13, arg_120_0, arg_120_1)
				end

				for iter_120_0 = 1, 4 do
					local var_120_27 = var_120_26
					local var_120_28 = var_120_6[iter_120_0]

					if var_120_28 then
						if var_120_28.option then
							local var_120_29 = var_120_14:getOption(var_120_28.option)

							assert(var_120_29)

							if var_120_29 then
								var_120_27 = ColourSwatches[var_120_28.swatch]:getAt(var_120_29)
							else
								local var_120_30 = native.vec4(var_120_14:getOption(var_120_28.r), var_120_14:getOption(var_120_28.g), var_120_14:getOption(var_120_28.b), var_120_28.a and var_120_14:getOption(var_120_28.a) or 1)

								var_120_27 = var_0_0.make(var_120_30)
							end
						elseif var_120_28.array then
							var_120_27 = var_0_0.make(var_120_14:getVec4Option(var_120_28.array, 1, 1))
						else
							local var_120_31 = type(var_120_28.r) == "string" and var_120_14:getOption(var_120_28.r) or var_120_28.r
							local var_120_32 = type(var_120_28.g) == "string" and var_120_14:getOption(var_120_28.g) or var_120_28.g
							local var_120_33 = type(var_120_28.b) == "string" and var_120_14:getOption(var_120_28.b) or var_120_28.b
							local var_120_34 = type(var_120_28.a) == "string" and var_120_14:getOption(var_120_28.a) or var_120_28.a
							local var_120_35 = native.vec4(var_120_31, var_120_32, var_120_33, var_120_34 and var_120_34 or 1)

							var_120_27 = var_0_0.make(var_120_35)
						end
					end

					var_120_23[string.format("tint%d", iter_120_0)] = var_120_27
				end
			elseif var_120_8 then
				if type(var_120_8) == "function" then
					var_120_8 = var_120_8(var_120_13, arg_120_0, arg_120_1)
				end

				local var_120_36 = var_120_8.x
				local var_120_37 = var_120_8.y
				local var_120_38 = var_120_8.z
				local var_120_39 = var_120_8.w

				if type(var_120_36) == "string" then
					var_120_36 = var_120_14:getOption(var_120_36)
				end

				if type(var_120_37) == "string" then
					var_120_37 = var_120_14:getOption(var_120_37)
				end

				if type(var_120_38) == "string" then
					var_120_38 = var_120_14:getOption(var_120_38)
				end

				if type(var_120_39) == "string" then
					var_120_39 = var_120_14:getOption(var_120_39)
				end

				var_120_23.tint1 = native.vec4(var_120_36, var_120_37, var_120_38, var_120_39)
			elseif var_120_9 then
				if type(var_120_9) == "function" then
					var_120_9 = var_120_9(var_120_13, arg_120_0, arg_120_1)
				end

				local var_120_40
				local var_120_41

				if type(var_120_9[1]) == "string" then
					var_120_40 = ColourFullRangeOptionToVec(arg_120_1, var_120_9[1], var_120_11)
				else
					var_120_40 = native.vec4(var_120_9[1].r, var_120_9[1].g, var_120_9[1].b, var_120_9[1].a)
				end

				if type(var_120_9[2]) == "string" then
					var_120_41 = ColourFullRangeOptionToVec(arg_120_1, var_120_9[2], var_120_11)
				else
					var_120_41 = native.vec4(var_120_9[2].r, var_120_9[2].g, var_120_9[2].b, var_120_9[2].a)
				end

				local var_120_42 = arg_118_0.colour1Intensity and var_120_13:getOption(arg_118_0.colour1Intensity) or 1
				local var_120_43 = arg_118_0.colour2Intensity and var_120_13:getOption(arg_118_0.colour2Intensity) or 1
				local var_120_44 = native.vec4(var_120_40.x, var_120_40.y, var_120_40.z, var_120_42)
				local var_120_45 = native.vec4(var_120_41.x, var_120_41.y, var_120_41.z, var_120_43)
				local var_120_46 = var_120_9[3].x
				local var_120_47 = var_120_9[3].y
				local var_120_48 = var_120_9[3].z
				local var_120_49 = var_120_9[3].w
				local var_120_50 = native.vec4(var_120_46, var_120_47, var_120_48, var_120_49)

				var_120_23.tint1 = var_120_44
				var_120_23.tint2 = var_120_45
				var_120_23.tint3 = var_120_50
				var_120_23.tint4 = var_120_26
			else
				var_120_23.tint1 = var_120_26
				var_120_23.tint2 = var_120_26
				var_120_23.tint3 = var_120_26
				var_120_23.tint4 = var_120_26
			end

			return var_120_23
		end

		table.insert(var_117_0, var_118_1)
	end

	local function var_117_4(arg_121_0)
		local var_121_0 = arg_121_0.configSelectFn or function(arg_122_0, arg_122_1)
			local var_122_0 = arg_121_0.cfg
			local var_122_1 = arg_121_0.cfgSelectOption
			local var_122_2 = var_122_0 == "p" and arg_122_0 or arg_122_1
			local var_122_3 = var_122_0 == "p" and arg_122_1 or arg_122_0

			if var_122_1 then
				if type(var_122_1) == "function" then
					var_122_1 = var_122_1(var_122_2, arg_122_0, arg_122_1)
				end

				local var_122_4 = arg_122_0:getOption(var_122_1)

				var_122_2 = var_122_4 == 0 and arg_122_0 or arg_122_1
				var_122_3 = var_122_4 == 0 and arg_122_1 or arg_122_0
			end

			return var_122_2, var_122_3
		end

		for iter_121_0 = 1, arg_121_0.decalCount do
			local function var_121_1(arg_123_0, arg_123_1)
				local var_123_0 = arg_121_0.decalName
				local var_123_1 = arg_121_0.decalCount
				local var_123_2 = false
				local var_123_3, var_123_4 = var_121_0(arg_123_0, arg_123_1)

				if type(var_123_0) == "function" then
					var_123_0 = var_123_0(var_123_3, arg_123_0, arg_123_1)
				end

				local var_123_5 = string.format("%s%d", var_123_0, iter_121_0)

				if not var_123_3:getOption(var_123_5) then
					var_123_3 = var_123_4

					local var_123_6 = var_123_3:getOption(var_123_5)

					ASSERT(var_123_6)
				end

				local var_123_7 = var_123_3:getOption(var_123_5 .. "Flip")
				local var_123_8 = var_123_3:getInterpolatedOption(var_123_5 .. "Rotation")

				if arg_121_0.potentialAsymmetry and getHandedness(arg_123_0) == 1 and var_123_3:getOption(var_123_5 .. "Asymmetry") == 1 then
					var_123_7 = 1 - var_123_7
					var_123_8 = -var_123_8
				end

				local var_123_9 = native.CTexSrcDecalDef()

				var_123_9.id = var_123_3:getOption(var_123_5)
				var_123_9.scale = var_123_3:getInterpolatedOption(var_123_5 .. "Scale")
				var_123_9.rotation = var_123_8
				var_123_9.positionX = var_123_3:getInterpolatedOption(var_123_5 .. "PositionX")
				var_123_9.positionY = var_123_3:getInterpolatedOption(var_123_5 .. "PositionY")
				var_123_9.flip = var_123_7 == 1
				var_123_9.tattooEffect = arg_121_0.tattooEffect == true

				return var_123_9, var_123_2
			end

			table.insert(var_117_0, var_121_1)
		end
	end

	local function var_117_5(arg_124_0)
		local function var_124_0(arg_125_0, arg_125_1)
			local var_125_0 = false
			local var_125_1 = native.CTexSrcTextDef()

			var_125_1.uvWindow = arg_124_0.uvWindow(arg_125_0, arg_125_1)
			var_125_1.enabled = arg_124_0.enabled(arg_125_0, arg_125_1)
			var_125_1.text = arg_124_0.text(arg_125_0, arg_125_1)
			var_125_1.rotation = arg_124_0.rotation(arg_125_0, arg_125_1)
			var_125_1.textFit = arg_124_0.textFit(arg_125_0, arg_125_1)
			var_125_1.fontName = arg_124_0.fontName(arg_125_0, arg_125_1)
			var_125_1.fontScale = arg_124_0.fontScale(arg_125_0, arg_125_1)
			var_125_1.fontYOffset = arg_124_0.fontYOffset(arg_125_0, arg_125_1)
			var_125_1.fontWeight = arg_124_0.fontWeight(arg_125_0, arg_125_1)
			var_125_1.fillColour = arg_124_0.fillColour(arg_125_0, arg_125_1)
			var_125_1.keylineWeight = arg_124_0.keylineWeight(arg_125_0, arg_125_1)
			var_125_1.keylineColour = arg_124_0.keylineColour(arg_125_0, arg_125_1)

			return var_125_1, var_125_0
		end

		table.insert(var_117_0, var_124_0)
	end

	local var_117_6 = getfenv()[arg_117_3]

	for iter_117_0, iter_117_1 in ipairs(var_117_6) do
		if iter_117_1.decalName then
			var_117_4(iter_117_1)
		elseif iter_117_1.uvWindow then
			var_117_5(iter_117_1)
		else
			var_117_3(iter_117_1)
		end
	end
end

DecalIds = {
	player = {},
	team = {},
	umpire = {},
	bat = {}
}

local function var_0_43(arg_126_0, arg_126_1)
	return arg_126_0
end

local function var_0_44(arg_127_0, arg_127_1)
	return arg_127_1
end

headColourDecalLayers = {}

function AppendHeadDecals(arg_128_0)
	for iter_128_0 = 1, NumDecalsOnHead do
		local var_128_0 = string.format("headDecal%d", iter_128_0)

		arg_128_0[var_128_0] = {
			byteSize = 4,
			default = 0,
			type = "guid"
		}
		arg_128_0[string.format("headDecal%dScale", iter_128_0)] = {
			default = 0.2,
			type = "slider",
			range = {
				0.025,
				0.65
			}
		}
		arg_128_0[string.format("headDecal%dRotation", iter_128_0)] = {
			default = 180,
			type = "slider",
			range = {
				-180,
				180
			}
		}
		arg_128_0[string.format("headDecal%dPositionX", iter_128_0)] = {
			default = 0.5,
			type = "slider",
			range = {
				0.05,
				1
			}
		}
		arg_128_0[string.format("headDecal%dPositionY", iter_128_0)] = {
			default = 0.35,
			type = "slider",
			range = {
				1,
				0.05
			}
		}
		arg_128_0[string.format("headDecal%dFlip", iter_128_0)] = {
			default = 1,
			type = "guid"
		}

		table.insert(headColourDecalLayers, {
			name = var_128_0,
			selectConfig = var_0_43
		})
		table.insert(DecalIds.player, var_128_0)
		table.insert(DecalIds.umpire, var_128_0)
	end
end

bodyColourDecalLayers = {}

function AppendUpperBodyDecals(arg_129_0)
	for iter_129_0 = 1, NumDecalsOnUpperBody do
		local var_129_0 = string.format("upperBodyDecal%d", iter_129_0)

		arg_129_0[var_129_0] = {
			byteSize = 4,
			default = 0,
			type = "guid"
		}
		arg_129_0[string.format("upperBodyDecal%dScale", iter_129_0)] = {
			default = 0.2,
			type = "slider",
			range = {
				0.025,
				0.75
			}
		}
		arg_129_0[string.format("upperBodyDecal%dRotation", iter_129_0)] = {
			default = 180,
			type = "slider",
			range = {
				-180,
				180
			}
		}
		arg_129_0[string.format("upperBodyDecal%dPositionX", iter_129_0)] = {
			default = 0.7,
			type = "slider",
			range = {
				0.6,
				0.95
			}
		}
		arg_129_0[string.format("upperBodyDecal%dPositionY", iter_129_0)] = {
			default = 0.6,
			type = "slider",
			range = {
				0.7,
				0
			}
		}
		arg_129_0[string.format("upperBodyDecal%dFlip", iter_129_0)] = {
			default = 1,
			type = "guid"
		}

		table.insert(bodyColourDecalLayers, {
			name = var_129_0,
			selectConfig = var_0_43
		})
		table.insert(DecalIds.player, var_129_0)
		table.insert(DecalIds.umpire, var_129_0)
	end
end

function AppendLowerBodyDecals(arg_130_0)
	for iter_130_0 = 1, NumDecalsOnLowerBody do
		local var_130_0 = string.format("lowerBodyDecal%d", iter_130_0)

		arg_130_0[var_130_0] = {
			byteSize = 4,
			default = 0,
			type = "guid"
		}
		arg_130_0[string.format("lowerBodyDecal%dScale", iter_130_0)] = {
			default = 0.2,
			type = "slider",
			range = {
				0.025,
				0.75
			}
		}
		arg_130_0[string.format("lowerBodyDecal%dRotation", iter_130_0)] = {
			default = 180,
			type = "slider",
			range = {
				-180,
				180
			}
		}
		arg_130_0[string.format("lowerBodyDecal%dPositionX", iter_130_0)] = {
			default = 0.2,
			type = "slider",
			range = {
				0,
				0.4
			}
		}
		arg_130_0[string.format("lowerBodyDecal%dPositionY", iter_130_0)] = {
			default = 0.6,
			type = "slider",
			range = {
				0.7,
				0.1
			}
		}
		arg_130_0[string.format("lowerBodyDecal%dFlip", iter_130_0)] = {
			default = 1,
			type = "guid"
		}

		table.insert(bodyColourDecalLayers, {
			name = var_130_0,
			selectConfig = var_0_43
		})
		table.insert(DecalIds.player, var_130_0)
		table.insert(DecalIds.umpire, var_130_0)
	end
end

uniformColourDecalLayers = {}

function AppendUniformDecals(arg_131_0)
	for iter_131_0 = 1, NumDecalsOnTop do
		local var_131_0 = string.format("decal%d", iter_131_0)

		arg_131_0[var_131_0] = {
			byteSize = 4,
			default = 0,
			type = "guid"
		}
		arg_131_0[string.format("decal%dScale", iter_131_0)] = {
			default = 0.2,
			type = "slider",
			range = {
				0.025,
				0.975
			}
		}
		arg_131_0[string.format("decal%dRotation", iter_131_0)] = {
			default = 180,
			type = "slider",
			range = {
				-180,
				180
			}
		}
		arg_131_0[string.format("decal%dPositionX", iter_131_0)] = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		}
		arg_131_0[string.format("decal%dPositionY", iter_131_0)] = {
			default = 0.2,
			type = "slider",
			range = {
				1,
				0
			}
		}
		arg_131_0[string.format("decal%dFlip", iter_131_0)] = {
			default = 1,
			type = "guid"
		}

		table.insert(uniformColourDecalLayers, {
			name = var_131_0,
			selectConfig = var_0_44
		})
		table.insert(DecalIds.team, var_131_0)
	end
end

pantsColourDecalLayers = {}

function AppendPantsDecals(arg_132_0)
	for iter_132_0 = 1, NumDecalsOnBottom do
		local var_132_0 = string.format("pantsDecal%d", iter_132_0)

		arg_132_0[var_132_0] = {
			byteSize = 4,
			default = 0,
			type = "guid"
		}
		arg_132_0[string.format("pantsDecal%dScale", iter_132_0)] = {
			default = 0.5,
			type = "slider",
			range = {
				0.025,
				0.975
			}
		}
		arg_132_0[string.format("pantsDecal%dRotation", iter_132_0)] = {
			default = 180,
			type = "slider",
			range = {
				-180,
				180
			}
		}
		arg_132_0[string.format("pantsDecal%dPositionX", iter_132_0)] = {
			default = 0.7,
			type = "slider",
			range = {
				0,
				1
			}
		}
		arg_132_0[string.format("pantsDecal%dPositionY", iter_132_0)] = {
			default = 0.3,
			type = "slider",
			range = {
				1,
				0
			}
		}
		arg_132_0[string.format("pantsDecal%dFlip", iter_132_0)] = {
			default = 1,
			type = "guid"
		}

		table.insert(uniformColourDecalLayers, {
			name = var_132_0,
			selectConfig = var_0_44
		})
		table.insert(DecalIds.team, var_132_0)
	end
end

local function var_0_45(arg_133_0)
	return function(arg_134_0, arg_134_1)
		if arg_134_0:getOption(arg_133_0) ~= 0 then
			return arg_134_1
		end

		return arg_134_0
	end
end

function getHandedness(arg_135_0)
	local var_135_0 = arg_135_0:getOption("overrideHandedness")
	local var_135_1 = var_135_0 ~= "" and var_135_0 or arg_135_0:getOption("handedness")

	assert(var_135_1 == "left" or var_135_1 == "right")

	return var_135_1 == "left" and 1 or 2
end

function optionMatchesName(arg_136_0, arg_136_1, arg_136_2, arg_136_3)
	local var_136_0 = getItemByGuid(AssetMapItems[arg_136_2], arg_136_0:getOption(arg_136_1))

	return var_136_0 and var_136_0.name == arg_136_3
end

local function var_0_46(arg_137_0, arg_137_1, arg_137_2)
	local var_137_0 = arg_137_0:getOption(arg_137_1)

	return getItemByGuid(AssetMapItems[arg_137_2], var_137_0).name
end

options = {
	team = {
		version = {
			type = "guid",
			default = var_0_11
		},
		sex = {
			default = "Male",
			type = "guid"
		},
		uniformEditable = {
			default = 1,
			type = "guid"
		},
		uniformTop = {
			byteSize = 2,
			default = 0,
			type = "guid"
		},
		uniformBottom = {
			byteSize = 2,
			default = 0,
			type = "guid"
		},
		uniformSocks = {
			byteSize = 2,
			default = 0,
			type = "guid"
		},
		uniformTop_patternLayer01 = {
			default = 0,
			type = "guid"
		},
		uniformBottom_patternLayer01 = {
			default = 0,
			type = "guid"
		},
		uniformSocks_patternLayer01 = {
			default = 0,
			type = "guid"
		},
		uniformTop_layer1_colour_r = {
			default = 0,
			type = "slider"
		},
		uniformTop_layer1_colour_g = {
			default = 0,
			type = "slider"
		},
		uniformTop_layer1_colour_b = {
			default = 0,
			type = "slider"
		},
		uniformTop_layer2_colour_r = {
			default = 0,
			type = "slider"
		},
		uniformTop_layer2_colour_g = {
			default = 0,
			type = "slider"
		},
		uniformTop_layer2_colour_b = {
			default = 0,
			type = "slider"
		},
		uniformTop_layer3_colour_r = {
			default = 0,
			type = "slider"
		},
		uniformTop_layer3_colour_g = {
			default = 0,
			type = "slider"
		},
		uniformTop_layer3_colour_b = {
			default = 0,
			type = "slider"
		},
		uniformTop_layer4_colour_r = {
			default = 0,
			type = "slider"
		},
		uniformTop_layer4_colour_g = {
			default = 0,
			type = "slider"
		},
		uniformTop_layer4_colour_b = {
			default = 0,
			type = "slider"
		},
		uniformTop_layer5_colour_r = {
			default = 0,
			type = "slider"
		},
		uniformTop_layer5_colour_g = {
			default = 0,
			type = "slider"
		},
		uniformTop_layer5_colour_b = {
			default = 0,
			type = "slider"
		},
		uniformTop_layer6_colour_r = {
			default = 0,
			type = "slider"
		},
		uniformTop_layer6_colour_g = {
			default = 0,
			type = "slider"
		},
		uniformTop_layer6_colour_b = {
			default = 0,
			type = "slider"
		},
		uniformBottom_layer1_colour_r = {
			default = 0,
			type = "slider"
		},
		uniformBottom_layer1_colour_g = {
			default = 0,
			type = "slider"
		},
		uniformBottom_layer1_colour_b = {
			default = 0,
			type = "slider"
		},
		uniformBottom_layer2_colour_r = {
			default = 0,
			type = "slider"
		},
		uniformBottom_layer2_colour_g = {
			default = 0,
			type = "slider"
		},
		uniformBottom_layer2_colour_b = {
			default = 0,
			type = "slider"
		},
		uniformBottom_layer3_colour_r = {
			default = 0,
			type = "slider"
		},
		uniformBottom_layer3_colour_g = {
			default = 0,
			type = "slider"
		},
		uniformBottom_layer3_colour_b = {
			default = 0,
			type = "slider"
		},
		uniformBottom_layer4_colour_r = {
			default = 0,
			type = "slider"
		},
		uniformBottom_layer4_colour_g = {
			default = 0,
			type = "slider"
		},
		uniformBottom_layer4_colour_b = {
			default = 0,
			type = "slider"
		},
		uniformSocks_layer1_colour_r = {
			default = 0,
			type = "slider"
		},
		uniformSocks_layer1_colour_g = {
			default = 0,
			type = "slider"
		},
		uniformSocks_layer1_colour_b = {
			default = 0,
			type = "slider"
		},
		uniformSocks_layer2_colour_r = {
			default = 0,
			type = "slider"
		},
		uniformSocks_layer2_colour_g = {
			default = 0,
			type = "slider"
		},
		uniformSocks_layer2_colour_b = {
			default = 0,
			type = "slider"
		},
		uniformSocks_layer3_colour_r = {
			default = 0,
			type = "slider"
		},
		uniformSocks_layer3_colour_g = {
			default = 0,
			type = "slider"
		},
		uniformSocks_layer3_colour_b = {
			default = 0,
			type = "slider"
		},
		uniformSocks_layer4_colour_r = {
			default = 0,
			type = "slider"
		},
		uniformSocks_layer4_colour_g = {
			default = 0,
			type = "slider"
		},
		uniformSocks_layer4_colour_b = {
			default = 0,
			type = "slider"
		},
		sockType = {
			default = 0,
			type = "guid"
		},
		whistle = {
			default = 0,
			type = "guid"
		},
		flag_col = {
			default = 0,
			type = "guid"
		},
		showTeamLogo = {
			default = 0,
			type = "guid"
		},
		hasPlayerName = {
			default = 0,
			type = "guid"
		},
		hasNumber = {
			default = 0,
			type = "guid"
		},
		showLeadingZero = {
			default = 0,
			type = "guid"
		},
		playerNameFont = {
			default = 0,
			type = "guid"
		},
		numberFont = {
			default = 0,
			type = "guid"
		},
		nameColour1_r = {
			default = 0,
			type = "slider"
		},
		nameColour1_g = {
			default = 0,
			type = "slider"
		},
		nameColour1_b = {
			default = 0,
			type = "slider"
		},
		nameKeylineColour1_r = {
			default = 0,
			type = "slider"
		},
		nameKeylineColour1_g = {
			default = 0,
			type = "slider"
		},
		nameKeylineColour1_b = {
			default = 0,
			type = "slider"
		},
		numberColour1_r = {
			default = 0,
			type = "slider"
		},
		numberColour1_g = {
			default = 0,
			type = "slider"
		},
		numberColour1_b = {
			default = 0,
			type = "slider"
		},
		numberColour2_r = {
			default = 0,
			type = "slider"
		},
		numberColour2_g = {
			default = 0,
			type = "slider"
		},
		numberColour2_b = {
			default = 0,
			type = "slider"
		},
		numberKeylineColour1_r = {
			default = 0,
			type = "slider"
		},
		numberKeylineColour1_g = {
			default = 0,
			type = "slider"
		},
		numberKeylineColour1_b = {
			default = 0,
			type = "slider"
		},
		numberKeylineColour2_r = {
			default = 0,
			type = "slider"
		},
		numberKeylineColour2_g = {
			default = 0,
			type = "slider"
		},
		numberKeylineColour2_b = {
			default = 0,
			type = "slider"
		},
		numberLogoColour1_r = {
			default = 0,
			type = "slider"
		},
		numberLogoColour1_g = {
			default = 0,
			type = "slider"
		},
		numberLogoColour1_b = {
			default = 0,
			type = "slider"
		},
		numberLogoColour2_r = {
			default = 0,
			type = "slider"
		},
		numberLogoColour2_g = {
			default = 0,
			type = "slider"
		},
		numberLogoColour2_b = {
			default = 0,
			type = "slider"
		},
		nameKeylineWeight = {
			default = 0,
			type = "slider"
		},
		numberKeylineWeight = {
			default = 0,
			type = "slider"
		},
		numberKeylineWeight2 = {
			default = 0,
			type = "slider"
		},
		shortName = {
			default = 0,
			byteSize = 22,
			noSave = true,
			type = "string"
		},
		nickname = {
			default = 0,
			byteSize = 19,
			noSave = true,
			type = "string"
		},
		icon = {
			default = 0,
			byteSize = 16,
			noSave = true,
			type = "string"
		},
		showJerseyIcon = {
			default = 0,
			type = "guid"
		},
		jerseyIcon = function(arg_138_0)
			return arg_138_0:getOption("showJerseyIcon") == 1 and arg_138_0:getOption("icon") or ""
		end
	},
	player = {
		tag = {
			byteSize = 40,
			noSave = true,
			type = "string"
		},
		noLoad = {
			default = 0,
			noSave = true,
			type = "guid"
		},
		version = {
			type = "guid",
			default = var_0_10
		},
		sex = {
			default = "Male",
			type = "guid"
		},
		sexSlider = function(arg_139_0)
			return optionMatchesName(arg_139_0, "sex", "sex", "Female") and 1 or 0
		end,
		isTier1 = function(arg_140_0)
			return var_0_18(arg_140_0) and 1 or 0
		end,
		role = {
			default = 0,
			byteSize = 8,
			noSave = true,
			type = "string"
		},
		currentHeadwearType = {
			default = 0,
			byteSize = 8,
			noSave = true,
			type = "string"
		},
		currentEyewearType = {
			default = 0,
			byteSize = 9,
			noSave = true,
			type = "string"
		},
		handedness = {
			default = 0,
			byteSize = 6,
			noSave = true,
			type = "string"
		},
		overrideHandedness = {
			default = 0,
			byteSize = 6,
			noSave = true,
			type = "string"
		},
		currentTopType = {
			default = 0,
			noSave = true,
			type = "guid"
		},
		currentFlagType = {
			default = 0,
			byteSize = 9,
			noSave = true,
			type = "string"
		},
		currentTrophyType = {
			default = 0,
			byteSize = 32,
			noSave = true,
			type = "string"
		},
		forceUseOfDefaultHeight = {
			default = 0,
			noSave = true,
			type = "guid"
		},
		currentGearType = {
			default = 0,
			noSave = true,
			type = "guid"
		},
		head = {
			byteSize = 2,
			default = "player_master_head",
			type = "guid"
		},
		body = {
			default = "player_master_body",
			type = "guid"
		},
		hideBody = {
			default = 0,
			noSave = true,
			type = "guid"
		},
		helmet = {
			default = 0,
			byteSize = 2,
			type = "guid"
		},
		headwearColour1_r = {
			default = 0,
			type = "slider"
		},
		headwearColour1_g = {
			default = 0,
			type = "slider"
		},
		headwearColour1_b = {
			default = 0,
			type = "slider"
		},
		headwearColour2_r = {
			default = 0,
			type = "slider"
		},
		headwearColour2_g = {
			default = 0,
			type = "slider"
		},
		headwearColour2_b = {
			default = 0,
			type = "slider"
		},
		headwearColour3_r = {
			default = 0,
			type = "slider"
		},
		headwearColour3_g = {
			default = 0,
			type = "slider"
		},
		headwearColour3_b = {
			default = 0,
			type = "slider"
		},
		headwearColour4_r = {
			default = 0,
			type = "slider"
		},
		headwearColour4_g = {
			default = 0,
			type = "slider"
		},
		headwearColour4_b = {
			default = 0,
			type = "slider"
		},
		headStrappingColour1_r = {
			default = 0,
			type = "slider"
		},
		headStrappingColour1_g = {
			default = 0,
			type = "slider"
		},
		headStrappingColour1_b = {
			default = 0,
			type = "slider"
		},
		headStrappingColour2_r = {
			default = 0,
			type = "slider"
		},
		headStrappingColour2_g = {
			default = 0,
			type = "slider"
		},
		headStrappingColour2_b = {
			default = 0,
			type = "slider"
		},
		height = {
			default = 0.5,
			type = "slider"
		},
		weight = {
			default = 0.5,
			type = "slider"
		},
		fitness = {
			default = 0.5,
			type = "slider"
		},
		mouthguard = {
			default = 0,
			type = "guid"
		},
		mouthguardColour1_r = {
			default = 1,
			type = "slider"
		},
		mouthguardColour1_g = {
			default = 1,
			type = "slider"
		},
		mouthguardColour1_b = {
			default = 1,
			type = "slider"
		},
		shoes = {
			default = 0,
			type = "guid"
		},
		shoeColour1_r = {
			default = 1,
			type = "slider"
		},
		shoeColour1_g = {
			default = 1,
			type = "slider"
		},
		shoeColour1_b = {
			default = 1,
			type = "slider"
		},
		shoeColour2_r = {
			default = 1,
			type = "slider"
		},
		shoeColour2_g = {
			default = 1,
			type = "slider"
		},
		shoeColour2_b = {
			default = 1,
			type = "slider"
		},
		shoeColour3_r = {
			default = 1,
			type = "slider"
		},
		shoeColour3_g = {
			default = 1,
			type = "slider"
		},
		shoeColour3_b = {
			default = 1,
			type = "slider"
		},
		shoeColour4_r = {
			default = 1,
			type = "slider"
		},
		shoeColour4_g = {
			default = 1,
			type = "slider"
		},
		shoeColour4_b = {
			default = 1,
			type = "slider"
		},
		sockHeight = {
			default = 0,
			type = "guid"
		},
		topType = {
			default = 1,
			type = "guid"
		},
		skinTexture = {
			default = 0,
			type = "guid"
		},
		eyeTexture = {
			default = 0,
			type = "guid"
		},
		limbal_ring_option = {
			default = 0,
			type = "guid"
		},
		hair = {
			byteSize = 2,
			default = 0,
			type = "guid"
		},
		hairTop = {
			byteSize = 2,
			default = 0,
			type = "guid"
		},
		hairSide = {
			byteSize = 2,
			default = 0,
			type = "guid"
		},
		hairSide2 = {
			byteSize = 2,
			default = 0,
			type = "guid"
		},
		hairTexture_cap = {
			default = 0,
			type = "guid"
		},
		hairColour1 = {
			default = 0,
			byteSize = 2,
			type = "guid"
		},
		hairColour2 = {
			default = 0,
			byteSize = 2,
			type = "guid"
		},
		beardColour1 = {
			default = 0,
			byteSize = 2,
			type = "guid"
		},
		beardColour2 = {
			default = 0,
			byteSize = 2,
			type = "guid"
		},
		hairTipsOption = {
			default = 0,
			type = "guid"
		},
		beardTipsOption = {
			default = 0,
			type = "guid"
		},
		tipFalloffValue = {
			default = 1,
			noSave = true,
			type = "slider"
		},
		tipOffsetValue = {
			default = 0,
			noSave = true,
			type = "slider"
		},
		tipOffsetBiasValue = {
			default = 0,
			noSave = true,
			type = "slider"
		},
		beard = {
			byteSize = 2,
			default = 0,
			type = "guid"
		},
		moustache = {
			byteSize = 2,
			default = 0,
			type = "guid"
		},
		sideburns = {
			byteSize = 2,
			default = 0,
			type = "guid"
		},
		chinhair = {
			byteSize = 2,
			default = 0,
			type = "guid"
		},
		beardTexture_cap = {
			default = 0,
			type = "guid"
		},
		debug_setColour = {
			default = 0,
			noSave = true,
			type = "guid"
		},
		debug_hairColour_r = {
			default = 1,
			noSave = true,
			type = "slider"
		},
		debug_hairColour_g = {
			default = 1,
			noSave = true,
			type = "slider"
		},
		debug_hairColour_b = {
			default = 1,
			noSave = true,
			type = "slider"
		},
		eyebrows_type = {
			default = 0,
			type = "guid"
		},
		bodyHair_type = {
			default = 0,
			type = "guid"
		},
		bodyHair_colour = {
			default = 0,
			byteSize = 2,
			type = "guid"
		},
		skins_left_option = {
			default = 0,
			type = "guid"
		},
		skins_right_option = {
			default = 0,
			type = "guid"
		},
		strapping_shoulderRight_option = {
			default = 0,
			type = "guid"
		},
		strapping_shoulderLeft_option = {
			default = 0,
			type = "guid"
		},
		strapping_elbowRight_option = {
			default = 0,
			type = "guid"
		},
		strapping_elbowLeft_option = {
			default = 0,
			type = "guid"
		},
		strapping_wristRight_option = {
			default = 0,
			type = "guid"
		},
		strapping_wristLeft_option = {
			default = 0,
			type = "guid"
		},
		strapping_handRight_option = {
			default = 0,
			type = "guid"
		},
		strapping_handLeft_option = {
			default = 0,
			type = "guid"
		},
		strapping_fingerpointerLeft_option = {
			default = 0,
			type = "guid"
		},
		strapping_fingermiddleLeft_option = {
			default = 0,
			type = "guid"
		},
		strapping_fingerringLeft_option = {
			default = 0,
			type = "guid"
		},
		strapping_fingerpinkyLeft_option = {
			default = 0,
			type = "guid"
		},
		strapping_fingerpointerRight_option = {
			default = 0,
			type = "guid"
		},
		strapping_fingermiddleRight_option = {
			default = 0,
			type = "guid"
		},
		strapping_fingerringRight_option = {
			default = 0,
			type = "guid"
		},
		strapping_fingerpinkyRight_option = {
			default = 0,
			type = "guid"
		},
		strapping_kneeRight_option = {
			default = 0,
			type = "guid"
		},
		strapping_kneeLeft_option = {
			default = 0,
			type = "guid"
		},
		strapping_thighLeft_option = {
			default = 0,
			type = "guid"
		},
		strapping_thighRight_option = {
			default = 0,
			type = "guid"
		},
		strapping_armbandLeft_option = {
			default = 0,
			type = "guid"
		},
		strapping_armbandRight_option = {
			default = 0,
			type = "guid"
		},
		compression_option = {
			default = 0,
			type = "guid"
		},
		leftNeckTattoo_type = {
			default = 0,
			type = "guid"
		},
		rightNeckTattoo_type = {
			default = 0,
			type = "guid"
		},
		midNeckTattoo_type = {
			default = 0,
			type = "guid"
		},
		leftArmTattoo_type = {
			default = 0,
			type = "guid"
		},
		rightArmTattoo_type = {
			default = 0,
			type = "guid"
		},
		leftLegTattoo_type = {
			default = 0,
			type = "guid"
		},
		rightLegTattoo_type = {
			default = 0,
			type = "guid"
		},
		headSize = {
			default = 0.5,
			type = "slider"
		},
		neckLength_bodyShape = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		bodyPreset_option = {
			default = 0,
			noSave = true,
			type = "guid"
		},
		bodyShapeMorph_option = {
			default = 0,
			type = "guid"
		},
		ectomorph_bodyShape = function(arg_141_0)
			return optionMatchesName(arg_141_0, "bodyShapeMorph_option", "bodyTypeMorphList", "ectomorph_bodyShape") and 1 or 0
		end,
		endomorph_bodyShape = function(arg_142_0)
			return optionMatchesName(arg_142_0, "bodyShapeMorph_option", "bodyTypeMorphList", "endomorph_bodyShape") and 1 or 0
		end,
		bodyFigureMorph_option = {
			default = 1,
			type = "guid"
		},
		invTriangle_bodyShape = function(arg_143_0)
			return optionMatchesName(arg_143_0, "bodyFigureMorph_option", "bodyFigureMorphList", "invTriangle_bodyShape") and 0.8 or 0
		end,
		hourglass_bodyShape = function(arg_144_0)
			return optionMatchesName(arg_144_0, "bodyFigureMorph_option", "bodyFigureMorphList", "hourglass_bodyShape") and 0.8 or 0
		end,
		pear_bodyShape = function(arg_145_0)
			return optionMatchesName(arg_145_0, "bodyFigureMorph_option", "bodyFigureMorphList", "pear_bodyShape") and 0.8 or 0
		end,
		apple_bodyShape = function(arg_146_0)
			return optionMatchesName(arg_146_0, "bodyFigureMorph_option", "bodyFigureMorphList", "apple_bodyShape") and 0.8 or 0
		end,
		bodyPhysiqueMorph_option = {
			default = 0,
			type = "guid"
		},
		athletique_bodyShape = function(arg_147_0)
			return optionMatchesName(arg_147_0, "bodyPhysiqueMorph_option", "bodyPhysiqueMorphList", "athletique_bodyShape") and 0.1 or 0
		end,
		heavy_bodyShape = function(arg_148_0)
			return optionMatchesName(arg_148_0, "bodyPhysiqueMorph_option", "bodyPhysiqueMorphList", "heavy_bodyShape") and 0.3 or 0
		end,
		neckWidth_bodyShape = {
			default = 0,
			type = "slider",
			range = {
				-0.5,
				1
			}
		},
		traps_bodyShape = {
			default = 0,
			type = "slider",
			range = {
				0,
				1
			}
		},
		upperTorso_bodyShape = {
			default = 0,
			type = "slider",
			range = {
				0,
				1
			}
		},
		lowerTorso_bodyShape = {
			default = 0,
			type = "slider",
			range = {
				0,
				1
			}
		},
		armsUpper_bodyShape = {
			default = 0.25,
			type = "slider",
			range = {
				0,
				1
			}
		},
		armsLower_bodyShape = {
			default = 0.25,
			type = "slider",
			range = {
				0,
				1
			}
		},
		legsUpper_bodyShape = {
			default = 0.25,
			type = "slider",
			range = {
				0,
				1
			}
		},
		legsLower_bodyShape = {
			default = 0.25,
			type = "slider",
			range = {
				0,
				1
			}
		},
		arms_bodyShape = {
			default = 0.25,
			type = "slider",
			range = {
				-0.5,
				1.25
			}
		},
		legs_bodyShape = {
			default = 0.25,
			type = "slider",
			range = {
				-0.5,
				1.5
			}
		},
		arms_thickness_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		armsMin_bodyShape = function(arg_149_0)
			return clampScale(arg_149_0, "arms_thickness_option", {
				0,
				0.285
			}, {
				1,
				0
			})
		end,
		arms_bodyShapeOption = function(arg_150_0)
			return clampScale(arg_150_0, "arms_thickness_option", {
				0.285,
				1
			}, {
				0,
				1.25
			})
		end,
		legs_thickness_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		legsMin_bodyShape = function(arg_151_0)
			return clampScale(arg_151_0, "legs_thickness_option", {
				0,
				0.25
			}, {
				1,
				0
			})
		end,
		legs_bodyShapeOption = function(arg_152_0)
			return clampScale(arg_152_0, "legs_thickness_option", {
				0.25,
				1
			}, {
				0,
				1.5
			})
		end,
		neckBodyMorph_option = {
			default = 0,
			type = "guid"
		},
		neck01_bodyShape = function(arg_153_0)
			return optionMatchesName(arg_153_0, "neckBodyMorph_option", "neckBodyMorphList", "neck01_bodyShape") and 1 or 0
		end,
		neck02_bodyShape = function(arg_154_0)
			return optionMatchesName(arg_154_0, "neckBodyMorph_option", "neckBodyMorphList", "neck02_bodyShape") and 1 or 0
		end,
		ethnicityShapeMorph_option = {
			default = 0,
			type = "guid"
		},
		ethnicityShape_caucasian = function(arg_155_0)
			return optionMatchesName(arg_155_0, "ethnicityShapeMorph_option", "ethnicityShapeMorphList", "ethnicityShape_caucasian") and 1 or 0
		end,
		ethnicityShape_african = function(arg_156_0)
			return optionMatchesName(arg_156_0, "ethnicityShapeMorph_option", "ethnicityShapeMorphList", "ethnicityShape_african") and 1 or 0
		end,
		ethnicityShape_asian = function(arg_157_0)
			return optionMatchesName(arg_157_0, "ethnicityShapeMorph_option", "ethnicityShapeMorphList", "ethnicityShape_asian") and 1 or 0
		end,
		ethnicityShape_indian = function(arg_158_0)
			return optionMatchesName(arg_158_0, "ethnicityShapeMorph_option", "ethnicityShapeMorphList", "ethnicityShape_indian") and 1 or 0
		end,
		ethnicityShape_islander = function(arg_159_0)
			return optionMatchesName(arg_159_0, "ethnicityShapeMorph_option", "ethnicityShapeMorphList", "ethnicityShape_islander") and 1 or 0
		end,
		ethnicityShape_middleEastern = function(arg_160_0)
			return optionMatchesName(arg_160_0, "ethnicityShapeMorph_option", "ethnicityShapeMorphList", "ethnicityShape_middleEastern") and 1 or 0
		end,
		headShapeMorph_option = {
			default = 0,
			type = "guid"
		},
		headShape_oblong = function(arg_161_0)
			return optionMatchesName(arg_161_0, "headShapeMorph_option", "headShapeMorphList", "headShape_oblong") and 1 or 0
		end,
		headShape_round = function(arg_162_0)
			return optionMatchesName(arg_162_0, "headShapeMorph_option", "headShapeMorphList", "headShape_round") and 1 or 0
		end,
		headShape_square = function(arg_163_0)
			return optionMatchesName(arg_163_0, "headShapeMorph_option", "headShapeMorphList", "headShape_square") and 1 or 0
		end,
		headShape_diamond = function(arg_164_0)
			return optionMatchesName(arg_164_0, "headShapeMorph_option", "headShapeMorphList", "headShape_diamond") and 1 or 0
		end,
		jawShapeMorph_option = {
			default = 0,
			type = "guid"
		},
		jawShape_oblong = function(arg_165_0)
			return optionMatchesName(arg_165_0, "jawShapeMorph_option", "jawShapeMorphList", "jawShape_oblong") and 1 or 0
		end,
		jawShape_round = function(arg_166_0)
			return optionMatchesName(arg_166_0, "jawShapeMorph_option", "jawShapeMorphList", "jawShape_round") and 1 or 0
		end,
		jawShape_square = function(arg_167_0)
			return optionMatchesName(arg_167_0, "jawShapeMorph_option", "jawShapeMorphList", "jawShape_square") and 1 or 0
		end,
		jawShape_diamond = function(arg_168_0)
			return optionMatchesName(arg_168_0, "jawShapeMorph_option", "jawShapeMorphList", "jawShape_diamond") and 1 or 0
		end,
		jawShape_oval = function(arg_169_0)
			return optionMatchesName(arg_169_0, "jawShapeMorph_option", "jawShapeMorphList", "jawShape_oval") and 1 or 0
		end,
		eyesShapeMorph_option = {
			default = 0,
			type = "guid"
		},
		eyesShape_almond = function(arg_170_0)
			return optionMatchesName(arg_170_0, "eyesShapeMorph_option", "eyesShapeMorphList", "eyesShape_almond") and 1 or 0
		end,
		eyesShape_round = function(arg_171_0)
			return optionMatchesName(arg_171_0, "eyesShapeMorph_option", "eyesShapeMorphList", "eyesShape_round") and 1 or 0
		end,
		eyesShape_downturned = function(arg_172_0)
			return optionMatchesName(arg_172_0, "eyesShapeMorph_option", "eyesShapeMorphList", "eyesShape_downturned") and 1 or 0
		end,
		eyesShape_hooded = function(arg_173_0)
			return optionMatchesName(arg_173_0, "eyesShapeMorph_option", "eyesShapeMorphList", "eyesShape_hooded") and 1 or 0
		end,
		eyesShape_monolid = function(arg_174_0)
			return optionMatchesName(arg_174_0, "eyesShapeMorph_option", "eyesShapeMorphList", "eyesShape_monolid") and 1 or 0
		end,
		eyesShape_upturned = function(arg_175_0)
			return optionMatchesName(arg_175_0, "eyesShapeMorph_option", "eyesShapeMorphList", "eyesShape_upturned") and 1 or 0
		end,
		earsShapeMorph_option = {
			default = 0,
			type = "guid"
		},
		earsShape_square = function(arg_176_0)
			return optionMatchesName(arg_176_0, "earsShapeMorph_option", "earsShapeMorphList", "earsShape_square") and 1 or 0
		end,
		earsShape_pointed = function(arg_177_0)
			return optionMatchesName(arg_177_0, "earsShapeMorph_option", "earsShapeMorphList", "earsShape_pointed") and 1 or 0
		end,
		earsShape_narrow = function(arg_178_0)
			return optionMatchesName(arg_178_0, "earsShapeMorph_option", "earsShapeMorphList", "earsShape_narrow") and 1 or 0
		end,
		earsShape_broadLobe = function(arg_179_0)
			return optionMatchesName(arg_179_0, "earsShapeMorph_option", "earsShapeMorphList", "earsShape_broadLobe") and 1 or 0
		end,
		earsShape_curled = function(arg_180_0)
			return optionMatchesName(arg_180_0, "earsShapeMorph_option", "earsShapeMorphList", "earsShape_curled") and 1 or 0
		end,
		noseShapeMorph_option = {
			default = 0,
			type = "guid"
		},
		noseShape_long = function(arg_181_0)
			return optionMatchesName(arg_181_0, "noseShapeMorph_option", "noseShapeMorphList", "noseShape_long") and 1 or 0
		end,
		noseShape_upturned = function(arg_182_0)
			return optionMatchesName(arg_182_0, "noseShapeMorph_option", "noseShapeMorphList", "noseShape_upturned") and 1 or 0
		end,
		noseShape_downturned = function(arg_183_0)
			return optionMatchesName(arg_183_0, "noseShapeMorph_option", "noseShapeMorphList", "noseShape_downturned") and 1 or 0
		end,
		noseShape_hook = function(arg_184_0)
			return optionMatchesName(arg_184_0, "noseShapeMorph_option", "noseShapeMorphList", "noseShape_hook") and 1 or 0
		end,
		noseShape_snub = function(arg_185_0)
			return optionMatchesName(arg_185_0, "noseShapeMorph_option", "noseShapeMorphList", "noseShape_snub") and 1 or 0
		end,
		nose_curved = function(arg_186_0)
			return optionMatchesName(arg_186_0, "noseShapeMorph_option", "noseShapeMorphList", "nose_curved") and 1 or 0
		end,
		mouthShapeMorph_option = {
			default = 0,
			type = "guid"
		},
		mouthShape_downturned = function(arg_187_0)
			return optionMatchesName(arg_187_0, "mouthShapeMorph_option", "mouthShapeMorphList", "mouthShape_downturned") and 1 or 0
		end,
		mouthShape_upturned = function(arg_188_0)
			return optionMatchesName(arg_188_0, "mouthShapeMorph_option", "mouthShapeMorphList", "mouthShape_upturned") and 1 or 0
		end,
		mouthShape_cupid = function(arg_189_0)
			return optionMatchesName(arg_189_0, "mouthShapeMorph_option", "mouthShapeMorphList", "mouthShape_cupid") and 1 or 0
		end,
		mouthShape_oval = function(arg_190_0)
			return optionMatchesName(arg_190_0, "mouthShapeMorph_option", "mouthShapeMorphList", "mouthShape_oval") and 1 or 0
		end,
		mouthShape_large = function(arg_191_0)
			return optionMatchesName(arg_191_0, "mouthShapeMorph_option", "mouthShapeMorphList", "mouthShape_large") and 1 or 0
		end,
		mouthShape_thin = function(arg_192_0)
			return optionMatchesName(arg_192_0, "mouthShapeMorph_option", "mouthShapeMorphList", "mouthShape_thin") and 1 or 0
		end,
		head_height = {
			default = 0,
			type = "slider",
			range = {
				1,
				0
			}
		},
		head_width_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		head_width_min = function(arg_193_0)
			return clampScale(arg_193_0, "head_width_option", {
				0,
				0.5
			}, {
				1,
				0
			})
		end,
		head_width_max = function(arg_194_0)
			return clampScale(arg_194_0, "head_width_option", {
				0.5,
				1
			}, {
				0,
				1
			})
		end,
		head_depth = {
			default = 0,
			type = "slider",
			range = {
				1,
				0
			}
		},
		skull_height = {
			default = 0,
			type = "slider",
			range = {
				1,
				0
			}
		},
		skull_width_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		skull_width_min = function(arg_195_0)
			return clampScale(arg_195_0, "skull_width_option", {
				0,
				0.5
			}, {
				1,
				0
			})
		end,
		skull_width_max = function(arg_196_0)
			return clampScale(arg_196_0, "skull_width_option", {
				0.5,
				1
			}, {
				0,
				1
			})
		end,
		skull_depth = {
			default = 0,
			type = "slider",
			range = {
				0,
				1
			}
		},
		temple_width_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		temple_width_min = function(arg_197_0)
			return clampScale(arg_197_0, "temple_width_option", {
				0,
				0.5
			}, {
				1,
				0
			})
		end,
		temple_width_max = function(arg_198_0)
			return clampScale(arg_198_0, "temple_width_option", {
				0.5,
				1
			}, {
				0,
				1
			})
		end,
		temporalis_width = {
			default = 0,
			type = "slider",
			range = {
				0,
				1
			}
		},
		forehead_height = {
			default = 0,
			type = "slider",
			range = {
				1,
				0
			}
		},
		forehead_width = {
			default = 0,
			type = "slider",
			range = {
				0,
				1
			}
		},
		forehead_depth = {
			default = 0,
			type = "slider",
			range = {
				1,
				0
			}
		},
		brow_size = {
			default = 0,
			type = "slider",
			range = {
				0,
				1
			}
		},
		brow_height_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		brow_height_min = function(arg_199_0)
			return clampScale(arg_199_0, "brow_height_option", {
				0.5,
				1
			}, {
				0,
				1
			})
		end,
		brow_height_max = function(arg_200_0)
			return clampScale(arg_200_0, "brow_height_option", {
				0,
				0.5
			}, {
				1,
				0
			})
		end,
		brow_width = {
			default = 0,
			type = "slider",
			range = {
				0,
				1
			}
		},
		brow_depth = {
			default = 0,
			type = "slider",
			range = {
				0,
				2
			}
		},
		cheekbone_height = {
			default = 0,
			type = "slider",
			range = {
				1,
				0
			}
		},
		cheekbone_width = {
			default = 0,
			type = "slider",
			range = {
				0,
				2
			}
		},
		cheekbone_depth = {
			default = 0,
			type = "slider",
			range = {
				0,
				2
			}
		},
		malar_depth = {
			default = 0,
			type = "slider",
			range = {
				1,
				0
			}
		},
		cheek_depth = {
			default = 0,
			type = "slider",
			range = {
				1,
				0
			}
		},
		cheek_width_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		cheek_width_min = function(arg_201_0)
			return clampScale(arg_201_0, "cheek_width_option", {
				0,
				0.5
			}, {
				1,
				0
			})
		end,
		cheek_width_max = function(arg_202_0)
			return clampScale(arg_202_0, "cheek_width_option", {
				0.5,
				1
			}, {
				0,
				1
			})
		end,
		jaw_height = {
			default = 0.15,
			type = "slider",
			range = {
				-0.7,
				1
			}
		},
		jaw_width = {
			default = 0.5,
			type = "slider",
			range = {
				-1,
				1
			}
		},
		jaw_depth = {
			default = 0,
			type = "slider",
			range = {
				0,
				1
			}
		},
		jaw_angle_height = {
			default = 0,
			type = "slider",
			range = {
				1,
				0
			}
		},
		chin_height = {
			default = 0.5,
			type = "slider",
			range = {
				-1,
				1
			}
		},
		chin_width = {
			default = 0.5,
			type = "slider",
			range = {
				-1,
				1
			}
		},
		chin_depth_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		chin_depth_min = function(arg_203_0)
			return clampScale(arg_203_0, "chin_depth_option", {
				0,
				0.5
			}, {
				1,
				0
			})
		end,
		chin_depth_max = function(arg_204_0)
			return clampScale(arg_204_0, "chin_depth_option", {
				0.5,
				1
			}, {
				0,
				1
			})
		end,
		mouth_jowl_width = {
			default = 0,
			type = "slider",
			range = {
				0,
				1
			}
		},
		eyes_size = {
			default = 0,
			type = "slider",
			range = {
				1,
				0
			}
		},
		eyes_iris_size = {
			default = 0,
			type = "slider",
			range = {
				1,
				0
			}
		},
		eyes_height_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		eyes_height_min = function(arg_205_0)
			return clampScale(arg_205_0, "eyes_height_option", {
				0.5,
				1
			}, {
				0,
				1
			})
		end,
		eyes_height_max = function(arg_206_0)
			return clampScale(arg_206_0, "eyes_height_option", {
				0,
				0.5
			}, {
				1,
				0
			})
		end,
		eyes_width_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		eyes_width_min = function(arg_207_0)
			return clampScale(arg_207_0, "eyes_width_option", {
				0,
				0.5
			}, {
				1,
				0
			})
		end,
		eyes_width_max = function(arg_208_0)
			return clampScale(arg_208_0, "eyes_width_option", {
				0.5,
				1
			}, {
				0,
				1
			})
		end,
		eyes_depth = {
			default = 0,
			type = "slider",
			range = {
				0,
				1
			}
		},
		eye_inner_size = {
			default = 0,
			type = "slider"
		},
		eye_inner_height = {
			default = 0.5,
			type = "slider",
			range = {
				1,
				-1
			}
		},
		eye_inner_width_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		eye_inner_width_min = function(arg_209_0)
			return clampScale(arg_209_0, "eye_inner_width_option", {
				0,
				0.5
			}, {
				1,
				0
			})
		end,
		eye_inner_width_max = function(arg_210_0)
			return clampScale(arg_210_0, "eye_inner_width_option", {
				0.5,
				1
			}, {
				0,
				1
			})
		end,
		eye_symmetry_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		eye_symmetry_min = function(arg_211_0)
			return clampScale(arg_211_0, "eye_symmetry_option", {
				0,
				0.5
			}, {
				0.3,
				0
			})
		end,
		eye_symmetry_max = function(arg_212_0)
			return clampScale(arg_212_0, "eye_symmetry_option", {
				0.5,
				1
			}, {
				0,
				0.3
			})
		end,
		eye_rotation_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		eye_rotation_min = function(arg_213_0)
			return clampScale(arg_213_0, "eye_rotation_option", {
				0.5,
				1
			}, {
				0,
				0.5
			})
		end,
		eye_rotation_max = function(arg_214_0)
			return clampScale(arg_214_0, "eye_rotation_option", {
				0,
				0.5
			}, {
				0.5,
				0
			})
		end,
		eyelid_droop_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		eyelid_droop_min = function(arg_215_0)
			return clampScale(arg_215_0, "eyelid_droop_option", {
				0.5,
				1
			}, {
				0,
				1
			})
		end,
		eyelid_droop_max = function(arg_216_0)
			return clampScale(arg_216_0, "eyelid_droop_option", {
				0,
				0.5
			}, {
				1,
				0
			})
		end,
		top_eyelid_height = {
			default = 0,
			type = "slider",
			range = {
				0,
				2
			}
		},
		bottom_eyelid_height = {
			default = 0,
			type = "slider",
			range = {
				2,
				0
			}
		},
		nose_height = {
			default = 0.1,
			type = "slider",
			range = {
				1,
				-0.2
			}
		},
		nose_width_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		nose_width_min = function(arg_217_0)
			return clampScale(arg_217_0, "nose_width_option", {
				0,
				0.5
			}, {
				1.5,
				0
			})
		end,
		nose_width_max = function(arg_218_0)
			return clampScale(arg_218_0, "nose_width_option", {
				0.5,
				1
			}, {
				0,
				1.5
			})
		end,
		nose_depth_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		nose_depth_min = function(arg_219_0)
			return clampScale(arg_219_0, "nose_depth_option", {
				0,
				0.5
			}, {
				1,
				0
			})
		end,
		nose_depth_max = function(arg_220_0)
			return clampScale(arg_220_0, "nose_depth_option", {
				0.5,
				1
			}, {
				0,
				1
			})
		end,
		nose_root_width_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		nose_root_width_min = function(arg_221_0)
			return clampScale(arg_221_0, "nose_root_width_option", {
				0,
				0.5
			}, {
				1,
				0
			})
		end,
		nose_root_width_max = function(arg_222_0)
			return clampScale(arg_222_0, "nose_root_width_option", {
				0.5,
				1
			}, {
				0,
				1
			})
		end,
		nose_root_depth_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		nose_root_depth_min = function(arg_223_0)
			return clampScale(arg_223_0, "nose_root_depth_option", {
				0,
				0.5
			}, {
				1,
				0
			})
		end,
		nose_root_depth_max = function(arg_224_0)
			return clampScale(arg_224_0, "nose_root_depth_option", {
				0.5,
				1
			}, {
				0,
				1
			})
		end,
		nose_bridge_width = {
			default = 0,
			type = "slider",
			range = {
				0,
				1
			}
		},
		nose_break_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		nose_break_left = function(arg_225_0)
			return clampScale(arg_225_0, "nose_break_option", {
				0,
				0.5
			}, {
				1,
				0
			})
		end,
		nose_break_right = function(arg_226_0)
			return clampScale(arg_226_0, "nose_break_option", {
				0.5,
				1
			}, {
				0,
				1
			})
		end,
		nose_tip_height_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		nose_tip_height_min = function(arg_227_0)
			return clampScale(arg_227_0, "nose_tip_height_option", {
				0.5,
				1
			}, {
				0,
				1
			})
		end,
		nose_tip_height_max = function(arg_228_0)
			return clampScale(arg_228_0, "nose_tip_height_option", {
				0,
				0.5
			}, {
				1,
				0
			})
		end,
		nose_tip_width = {
			default = 0,
			type = "slider",
			range = {
				0,
				1
			}
		},
		nose_tip_depth = {
			default = 0.25,
			type = "slider",
			range = {
				-0.5,
				1.5
			}
		},
		nose_septum_height = {
			default = 0,
			type = "slider",
			range = {
				0,
				1.5
			}
		},
		nostril_size = {
			default = 0,
			type = "slider",
			range = {
				0,
				1
			}
		},
		nostril_height_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		nostril_height_min = function(arg_229_0)
			return clampScale(arg_229_0, "nostril_height_option", {
				0.5,
				1
			}, {
				0,
				1
			})
		end,
		nostril_height_max = function(arg_230_0)
			return clampScale(arg_230_0, "nostril_height_option", {
				0,
				0.5
			}, {
				1,
				0
			})
		end,
		nose_nostril_width = {
			default = 0,
			type = "slider",
			range = {
				0,
				1
			}
		},
		nose_nostril_depth = {
			default = 0,
			type = "slider",
			range = {
				1,
				0
			}
		},
		septum_width_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		septum_width_min = function(arg_231_0)
			return clampScale(arg_231_0, "septum_width_option", {
				0,
				0.5
			}, {
				1,
				0
			})
		end,
		septum_width_max = function(arg_232_0)
			return clampScale(arg_232_0, "septum_width_option", {
				0.5,
				1
			}, {
				0,
				1.5
			})
		end,
		nose_root_height_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		nose_root_height_min = function(arg_233_0)
			return clampScale(arg_233_0, "nose_root_height_option", {
				0.5,
				1
			}, {
				0,
				1
			})
		end,
		nose_root_height_max = function(arg_234_0)
			return clampScale(arg_234_0, "nose_root_height_option", {
				0,
				0.5
			}, {
				1,
				0
			})
		end,
		nostril_thickness = {
			default = 0,
			type = "slider",
			range = {
				1,
				0
			}
		},
		ears_size = {
			default = 0.5,
			type = "slider",
			range = {
				1,
				-1
			}
		},
		ears_height_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		ears_height_min = function(arg_235_0)
			return clampScale(arg_235_0, "ears_height_option", {
				0.5,
				1
			}, {
				0,
				1
			})
		end,
		ears_height_max = function(arg_236_0)
			return clampScale(arg_236_0, "ears_height_option", {
				0,
				0.5
			}, {
				1,
				0
			})
		end,
		ears_angle_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		ears_angle_min = function(arg_237_0)
			return clampScale(arg_237_0, "ears_angle_option", {
				0,
				0.5
			}, {
				1,
				0
			})
		end,
		ears_angle_max = function(arg_238_0)
			return clampScale(arg_238_0, "ears_angle_option", {
				0.5,
				1
			}, {
				0,
				1
			})
		end,
		ears_top_height = {
			default = 0,
			type = "slider",
			range = {
				1,
				0
			}
		},
		ears_middle_width = {
			default = 0,
			type = "slider",
			range = {
				0,
				1
			}
		},
		ears_bottom_height = {
			default = 0,
			type = "slider",
			range = {
				0,
				1
			}
		},
		ear_depth_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		ear_depth_min = function(arg_239_0)
			return clampScale(arg_239_0, "ear_depth_option", {
				0.5,
				1
			}, {
				0,
				1
			})
		end,
		ear_depth_max = function(arg_240_0)
			return clampScale(arg_240_0, "ear_depth_option", {
				0,
				0.5
			}, {
				1,
				0
			})
		end,
		ear_rotation_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		ear_rotation_min = function(arg_241_0)
			return clampScale(arg_241_0, "ear_rotation_option", {
				0.5,
				1
			}, {
				0,
				1
			})
		end,
		ear_rotation_max = function(arg_242_0)
			return clampScale(arg_242_0, "ear_rotation_option", {
				0,
				0.5
			}, {
				1,
				0
			})
		end,
		ear_symmetry_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		ear_symmetry_min = function(arg_243_0)
			return clampScale(arg_243_0, "ear_symmetry_option", {
				0.5,
				1
			}, {
				0,
				0.5
			})
		end,
		ear_symmetry_max = function(arg_244_0)
			return clampScale(arg_244_0, "ear_symmetry_option", {
				0,
				0.5
			}, {
				0.5,
				0
			})
		end,
		mouth_height_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		mouth_height_min = function(arg_245_0)
			return clampScale(arg_245_0, "mouth_height_option", {
				0.5,
				1
			}, {
				0,
				1
			})
		end,
		mouth_height_max = function(arg_246_0)
			return clampScale(arg_246_0, "mouth_height_option", {
				0,
				0.5
			}, {
				1,
				0
			})
		end,
		mouth_width_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		mouth_width_min = function(arg_247_0)
			return clampScale(arg_247_0, "mouth_width_option", {
				0,
				0.5
			}, {
				1,
				0
			})
		end,
		mouth_width_max = function(arg_248_0)
			return clampScale(arg_248_0, "mouth_width_option", {
				0.5,
				1
			}, {
				0,
				1
			})
		end,
		mouth_depth = {
			default = 0,
			type = "slider"
		},
		upper_lip_height_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		upper_lip_height_min = function(arg_249_0)
			return clampScale(arg_249_0, "upper_lip_height_option", {
				0.5,
				1
			}, {
				0,
				1
			})
		end,
		upper_lip_height_max = function(arg_250_0)
			return clampScale(arg_250_0, "upper_lip_height_option", {
				0,
				0.5
			}, {
				1,
				0
			})
		end,
		upper_lip_depth = {
			default = 0,
			type = "slider",
			range = {
				0,
				2
			}
		},
		middle_lip_height = {
			default = 0,
			type = "slider",
			range = {
				0,
				1
			}
		},
		middle_lip_width = {
			default = 0,
			type = "slider",
			range = {
				1,
				0
			}
		},
		lower_lip_height_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		lower_lip_height_min = function(arg_251_0)
			return clampScale(arg_251_0, "lower_lip_height_option", {
				0,
				0.5
			}, {
				1,
				0
			})
		end,
		lower_lip_height_max = function(arg_252_0)
			return clampScale(arg_252_0, "lower_lip_height_option", {
				0.5,
				1
			}, {
				0,
				1
			})
		end,
		lower_lip_depth = {
			default = 0,
			type = "slider",
			range = {
				0,
				1.5
			}
		},
		oris_depth = {
			default = 0,
			type = "slider",
			range = {
				0,
				2
			}
		},
		philtrum_option = {
			default = 0.5,
			type = "slider",
			range = {
				0,
				1
			}
		},
		philtrum_width_min = function(arg_253_0)
			return clampScale(arg_253_0, "philtrum_option", {
				0,
				0.5
			}, {
				1,
				0
			})
		end,
		philtrum_width_max = function(arg_254_0)
			return clampScale(arg_254_0, "philtrum_option", {
				0.5,
				1
			}, {
				0,
				1
			})
		end,
		ears_pinned = function(arg_255_0)
			local var_255_0 = var_0_31(arg_255_0)

			if var_255_0 and var_255_0.ears_pinned then
				return 1.3
			end

			return 0
		end,
		ears_headstrapping = function(arg_256_0)
			local var_256_0 = var_0_31(arg_256_0)

			if var_256_0 and var_256_0.ears_headstrapping then
				return 1
			end

			return 0
		end,
		headwear_hair_long01 = function(arg_257_0)
			local var_257_0 = var_0_20(arg_257_0)
			local var_257_1 = var_257_0 and var_257_0.headwearBlendshape or ""
			local var_257_2 = var_0_21(arg_257_0)
			local var_257_3 = var_257_2 and var_257_2.headwearBlendshape or ""

			return (var_257_1 == "headwear_hair_long01" or var_257_3 == "headwear_hair_long01") and 1 or 0
		end,
		headwear_hair_mullet_curly01 = function(arg_258_0)
			local var_258_0 = var_0_20(arg_258_0)
			local var_258_1 = var_258_0 and var_258_0.headwearBlendshape or ""
			local var_258_2 = var_0_21(arg_258_0)
			local var_258_3 = var_258_2 and var_258_2.headwearBlendshape or ""

			return (var_258_1 == "headwear_hair_mullet_curly01" or var_258_3 == "headwear_hair_mullet_curly01") and 1 or 0
		end,
		ugcHead = {
			default = 0,
			type = "guid"
		},
		headUuid = {
			byteSize = 16,
			type = "uuid"
		},
		eyeSocketTint_type = {
			default = 0,
			type = "guid"
		},
		freckles_type = {
			default = 0,
			type = "guid"
		},
		mole_head_type = {
			default = 0,
			type = "guid"
		},
		scar_type = {
			default = 0,
			type = "guid"
		},
		pockmarks_option = {
			default = 0,
			type = "guid"
		},
		crowsFeet_option = {
			default = 0,
			type = "guid"
		},
		highlightsBrow_amount = {
			default = 0,
			type = "slider"
		},
		highlightsCheeks_amount = {
			default = 0,
			type = "slider"
		},
		highlightsChin_amount = {
			default = 0,
			type = "slider"
		},
		highlightsMouth_amount = {
			default = 0,
			type = "slider"
		},
		highlightsNose_amount = {
			default = 0,
			type = "slider"
		},
		lipTint_amount = {
			default = 0,
			type = "slider"
		},
		redness_cheeks_amount = {
			default = 0.5,
			type = "slider"
		},
		redness_face_amount = {
			default = 0.2,
			type = "slider"
		},
		redness_nose_amount = {
			default = 0.1,
			type = "slider"
		},
		shirtName = {
			byteSize = 32,
			noSave = true,
			type = "string"
		},
		shirtNumber = {
			noSave = true,
			default = 0,
			type = "guid"
		}
	},
	bat = {}
}

local var_0_47 = options.player
local var_0_48 = options.team

texSrcRules = {}

AppendTexSrcLayers(var_0_47, var_0_48, texSrcRules, "headColourLayers")
AppendTexSrcLayers(var_0_47, var_0_48, texSrcRules, "headMaterialLayers")
AppendTexSrcLayers(var_0_47, var_0_48, texSrcRules, "headNormalLayers")
AppendTexSrcLayers(var_0_47, var_0_48, texSrcRules, "headMskLayers")
AppendTexSrcLayers(var_0_47, var_0_48, texSrcRules, "tier1_headColourLayers")
AppendTexSrcLayers(var_0_47, var_0_48, texSrcRules, "tier1_headMaterialLayers")
AppendTexSrcLayers(var_0_47, var_0_48, texSrcRules, "tier1_headNormalLayers")
AppendTexSrcLayers(var_0_47, var_0_48, texSrcRules, "eyesColourLayers")
AppendTexSrcLayers(var_0_47, var_0_48, texSrcRules, "bodyColourLayers")
AppendTexSrcLayers(var_0_47, var_0_48, texSrcRules, "bodyMaterialLayers")
AppendTexSrcLayers(var_0_47, var_0_48, texSrcRules, "bodyNormalLayers")
AppendTexSrcLayers(var_0_47, var_0_48, texSrcRules, "bodyMskLayers")
AppendTexSrcLayers(var_0_47, var_0_48, texSrcRules, "beardCapColourLayers")
AppendTexSrcLayers(var_0_47, var_0_48, texSrcRules, "uniformTopColourLayers")
AppendTexSrcLayers(var_0_47, var_0_48, texSrcRules, "uniformTopMaterialLayers")
AppendTexSrcLayers(var_0_47, var_0_48, texSrcRules, "uniformTopNormalLayers")
AppendTexSrcLayers(var_0_47, var_0_48, texSrcRules, "uniformNumberLayers")
AppendTexSrcLayers(var_0_47, var_0_48, texSrcRules, "uniformBottomColourLayers")
AppendTexSrcLayers(var_0_47, var_0_48, texSrcRules, "uniformBottomMaterialLayers")
AppendTexSrcLayers(var_0_47, var_0_48, texSrcRules, "uniformBottomNormalLayers")
AppendTexSrcLayers(var_0_47, var_0_48, texSrcRules, "uniformSocksColourLayers")
AppendTexSrcLayers(var_0_47, var_0_48, texSrcRules, "uniformSocksMaterialLayers")
AppendTexSrcLayers(var_0_47, var_0_48, texSrcRules, "uniformSocksNormalLayers")
AppendTexSrcLayers(var_0_47, var_0_48, texSrcRules, "helmetColourLayers")
AppendTexSrcLayers(var_0_47, var_0_48, texSrcRules, "helmetMaterialLayers")
AppendTexSrcLayers(var_0_47, var_0_48, texSrcRules, "helmetNormalLayers")
AppendTexSrcLayers(var_0_47, var_0_48, texSrcRules, "shoesColourLayers")
AppendUniformDecals(var_0_48)
AppendPantsDecals(var_0_48)

local function var_0_49(arg_259_0)
	return function(arg_260_0, arg_260_1, arg_260_2, arg_260_3)
		local var_260_0 = arg_260_3[arg_259_0]

		return var_260_0.height, var_260_0.width, var_260_0.level
	end
end

local function var_0_50()
	return function(arg_262_0, arg_262_1, arg_262_2, arg_262_3)
		local var_262_0 = arg_262_3.uniformSocksLongRes

		return var_262_0.height, var_262_0.width, var_262_0.level
	end
end

local function var_0_51(arg_263_0)
	local var_263_0 = var_0_31(arg_263_0)

	return var_263_0 and var_263_0.gear or 0
end

local function var_0_52(arg_264_0, arg_264_1)
	if not arg_264_1 then
		return ""
	end

	local var_264_0 = AssetMapItems[arg_264_0]
	local var_264_1 = getItemByGuidName(var_264_0, arg_264_1)

	return var_264_0.basePath .. "/" .. var_264_1.name .. ".texture"
end

local function var_0_53(arg_265_0, arg_265_1, arg_265_2)
	local var_265_0 = var_0_20(arg_265_0)
	local var_265_1
	local var_265_2 = var_0_51(arg_265_0)
	local var_265_3 = var_265_0 and var_265_0.gear_top

	if var_265_2 == 1 and var_265_3 then
		local var_265_4 = AssetMapItems.hairTop_gear
		local var_265_5 = getItemByGuidName(var_265_4, var_265_3)

		var_265_1 = var_265_5 and var_265_5[arg_265_1]
	else
		var_265_1 = var_265_0 and var_265_0[arg_265_1]
	end

	return (var_0_52(arg_265_2, var_265_1))
end

local function var_0_54(arg_266_0, arg_266_1, arg_266_2)
	local var_266_0 = var_0_20(arg_266_0)
	local var_266_1 = var_0_21(arg_266_0)
	local var_266_2
	local var_266_3 = var_0_51(arg_266_0)
	local var_266_4 = var_266_1 and var_266_1.gear_side or var_266_0 and var_266_0.gear_side

	if var_266_3 == 1 and var_266_4 then
		local var_266_5 = AssetMapItems.hairSide_gear
		local var_266_6 = getItemByGuidName(var_266_5, var_266_4)

		var_266_2 = var_266_6 and var_266_6[arg_266_1]
	else
		var_266_2 = var_266_1 and var_266_1[arg_266_1]
	end

	return (var_0_52(arg_266_2, var_266_2))
end

local function var_0_55(arg_267_0, arg_267_1)
	local var_267_0 = arg_267_0:getOption(arg_267_1)
	local var_267_1 = AssetMapItems.hairColours
	local var_267_2 = getHairColorTableByGuid(var_267_1, var_267_0) or getHairColorTableByGuid(var_267_1, 0)

	return native.vec4(var_267_2[1] / 255, var_267_2[2] / 255, var_267_2[3] / 255, 1)
end

local function var_0_56(arg_268_0, arg_268_1)
	local var_268_0 = var_0_20(arg_268_0)

	if var_268_0 and var_268_0.noModel == nil then
		local var_268_1 = arg_268_0:getOption("hairTipsOption")

		return AssetMapItems[var_268_0.hairTipsOptions][var_268_1 + 1][arg_268_1]
	end

	return 0
end

local function var_0_57(arg_269_0, arg_269_1)
	local var_269_0 = arg_269_0:getOption("beardTipsOption")

	return AssetMapItems.beardTipsOptions[var_269_0 + 1][arg_269_1]
end

function getHairJigglyConfigTable(arg_270_0, arg_270_1, arg_270_2, arg_270_3, arg_270_4)
	local var_270_0 = arg_270_0:getOption(arg_270_2)
	local var_270_1 = getItemByGuid(AssetMapItems[arg_270_3], var_270_0)
	local var_270_2 = arg_270_0:getOption("sex") == 0 and "_male" or "_female"

	if arg_270_4 and arg_270_4.jigglyConfig then
		local var_270_3 = arg_270_4.jigglyConfig .. var_270_2

		return {
			var_0_2[var_270_3]
		}
	end

	if var_270_1 and var_270_1.jigglyConfig then
		local var_270_4 = getPermutationItemByGuid(AssetMapItems[arg_270_3], arg_270_1, var_270_1, "hairGear")

		if var_270_4 and var_270_4.guid then
			local var_270_5 = getItemByGuid(AssetMapItems.hairGear, var_270_4.guid).name
			local var_270_6 = var_270_5 ~= "" and "_" .. var_270_5 or ""
			local var_270_7 = var_270_1.jigglyConfig .. var_270_6 .. var_270_2

			return {
				var_0_2[var_270_7]
			}
		end
	end

	return {}
end

function getBeardJigglyConfigTable(arg_271_0, arg_271_1)
	local var_271_0 = arg_271_0:getOption("sideburns")
	local var_271_1 = getItemByGuid(AssetMapItems.sideburns, var_271_0)

	if var_271_1 and var_271_1.jigglyConfig then
		if arg_271_1 == "sideburns" then
			return {
				var_0_2.beard
			}
		else
			return {}
		end
	end

	local var_271_2 = arg_271_0:getOption("chinhair")
	local var_271_3 = getItemByGuid(AssetMapItems.chinhair, var_271_2)

	if var_271_3 and var_271_3.jigglyConfig then
		if arg_271_1 == "chinhair" then
			return {
				var_0_2.beard
			}
		else
			return {}
		end
	end

	return {}
end

function getHeadwearJigglyConfigTable(arg_272_0)
	if arg_272_0 then
		return {
			var_0_2[arg_272_0.name]
		}
	end

	return {}
end

function getFlagJigglyConfigTable(arg_273_0, arg_273_1, arg_273_2)
	local var_273_0 = getItemByGuid(AssetMapItems[arg_273_2], arg_273_1)

	if var_273_0 and var_273_0.jigglyConfig then
		local var_273_1 = var_273_0.jigglyConfig

		return {
			var_0_2[var_273_1]
		}
	end

	return {}
end

function getTrophyJigglyConfigTable(arg_274_0)
	if arg_274_0 then
		return {
			var_0_2[arg_274_0]
		}
	end

	return {}
end

local function var_0_58(arg_275_0, arg_275_1, arg_275_2, arg_275_3, arg_275_4)
	local var_275_0 = {}

	for iter_275_0, iter_275_1 in ipairs(arg_275_1) do
		table.insert(var_275_0, iter_275_1)
	end

	for iter_275_2, iter_275_3 in ipairs(arg_275_2) do
		table.insert(var_275_0, iter_275_3 .. "_r")
		table.insert(var_275_0, iter_275_3 .. "_g")
		table.insert(var_275_0, iter_275_3 .. "_b")
	end

	for iter_275_4 = 1, arg_275_4 do
		local var_275_1 = string.format("%s%d", arg_275_3, iter_275_4)

		table.insert(var_275_0, var_275_1)
		table.insert(var_275_0, var_275_1 .. "Scale")
		table.insert(var_275_0, var_275_1 .. "Rotation")
		table.insert(var_275_0, var_275_1 .. "PositionX")
		table.insert(var_275_0, var_275_1 .. "PositionY")
		table.insert(var_275_0, var_275_1 .. "Flip")
	end

	return arg_275_0:getOptionHash(var_275_0)
end

local function var_0_59(arg_276_0, arg_276_1)
	local var_276_0 = {
		"sex",
		"uniformTop",
		"uniformTop_patternLayer01",
		"icon"
	}
	local var_276_1 = {
		"uniformTop_layer1_colour",
		"uniformTop_layer2_colour",
		"uniformTop_layer3_colour",
		"uniformTop_layer4_colour",
		"uniformTop_layer5_colour",
		"uniformTop_layer6_colour"
	}
	local var_276_2 = var_0_58(arg_276_1, var_276_0, var_276_1, "decal", NumDecalsOnTop)
	local var_276_3 = arg_276_0:getOptionHash({
		"topType"
	})

	return string.format("%d %d", var_276_2, var_276_3)
end

local function var_0_60(arg_277_0, arg_277_1)
	local var_277_0 = {
		"sex",
		"uniformBottom",
		"uniformBottom_patternLayer01"
	}
	local var_277_1 = {
		"uniformBottom_layer1_colour",
		"uniformBottom_layer2_colour",
		"uniformBottom_layer3_colour",
		"uniformBottom_layer4_colour"
	}
	local var_277_2 = var_0_58(arg_277_1, var_277_0, var_277_1, "pantsDecal", NumDecalsOnBottom)

	return string.format("bottom: %d", var_277_2)
end

local function var_0_61(arg_278_0, arg_278_1)
	local var_278_0 = {
		"sex",
		"uniformSocks",
		"uniformSocks_patternLayer01",
		"sockType"
	}
	local var_278_1 = {
		"uniformSocks_layer1_colour",
		"uniformSocks_layer2_colour",
		"uniformSocks_layer3_colour",
		"uniformSocks_layer4_colour"
	}
	local var_278_2 = arg_278_0:getOptionHash({
		"sockHeight"
	})
	local var_278_3 = var_0_58(arg_278_1, var_278_0, var_278_1, nil, 0)

	return string.format("socks: %d %d", var_278_3, var_278_2)
end

local function var_0_62(arg_279_0, arg_279_1)
	local var_279_0 = {
		"shoes"
	}
	local var_279_1 = {
		"shoeColour1",
		"shoeColour2",
		"shoeColour3",
		"shoeColour4"
	}
	local var_279_2 = var_0_58(arg_279_0, var_279_0, var_279_1, nil, 0)

	return string.format("shoes: %d", var_279_2)
end

modelSlots = {
	head = {
		filename = function(arg_280_0, arg_280_1, arg_280_2)
			if arg_280_0:getOption("hideBody") == 1 then
				return nil
			end

			local var_280_0 = var_0_17(arg_280_0)
			local var_280_1 = var_280_0 and "tier1head" or "head"
			local var_280_2 = var_280_0 and arg_280_0:getOption("head") or 0
			local var_280_3 = AssetMapItems[var_280_1]
			local var_280_4, var_280_5, var_280_6 = getModelFileNameByGuid(var_280_2, var_280_3, arg_280_0, arg_280_1)
			local var_280_7 = var_280_0 and var_280_0.name or ""

			return var_280_4, "", {}, var_280_7, var_280_6
		end,
		materialContextFn = function(arg_281_0, arg_281_1, arg_281_2)
			return {
				headRes = VERIFY(var_0_3.head[arg_281_2]),
				eyesRes = VERIFY(var_0_3.eyes[arg_281_2])
			}
		end,
		materialConfig = {
			head_wrinkle_mat = {
				col_map = {
					type = "texture",
					resolution = var_0_49("headRes"),
					compositingGroup = function(arg_282_0)
						return var_0_17(arg_282_0) and "tier1_headColourLayers" or "headColourLayers"
					end,
					param = function(arg_283_0, arg_283_1, arg_283_2)
						return string.format("head_col_%s", arg_283_2.addressString)
					end,
					targetType = var_0_4.ColourMap
				},
				mat_map = {
					type = "texture",
					resolution = var_0_49("headRes"),
					compositingGroup = function(arg_284_0)
						return var_0_17(arg_284_0) and not var_0_19(arg_284_0) and "tier1_headMaterialLayers" or "headMaterialLayers"
					end,
					param = function(arg_285_0, arg_285_1, arg_285_2)
						return string.format("head_mat_%s", arg_285_2.addressString)
					end,
					targetType = var_0_4.MatMap
				},
				nrm_map = {
					type = "texture",
					resolution = var_0_49("headRes"),
					compositingGroup = function(arg_286_0)
						return var_0_17(arg_286_0) and not var_0_19(arg_286_0) and "tier1_headNormalLayers" or "headNormalLayers"
					end,
					param = function(arg_287_0, arg_287_1, arg_287_2)
						return string.format("head_nrm_%s", arg_287_2.addressString)
					end,
					targetType = var_0_4.NormalMap
				},
				msk_map = {
					compositingGroup = "headMskLayers",
					type = "texture",
					resolution = var_0_49("headRes"),
					targetType = var_0_4.MaskMap
				},
				bmp_map = {
					type = "texture",
					param = function(arg_288_0, arg_288_1, arg_288_2)
						return (var_0_52("skinmicrodetail_nrm", "skinmicrodetail_nrm"))
					end
				},
				dirt_map = {
					type = "texture",
					param = function(arg_289_0, arg_289_1, arg_289_2)
						return (var_0_52("head_dirt", "player_dirt_head_col"))
					end
				},
				sweat_nrm = {
					type = "texture",
					param = function(arg_290_0, arg_290_1, arg_290_2)
						return (var_0_52("head_sweat_nrm", "player_sweat_head_nrm"))
					end
				},
				wrinkle1_nrm_map = {
					type = "texture",
					param = function(arg_291_0, arg_291_1, arg_291_2)
						return "characters/player/textures/base/m_player_head_wrinkle01_nrm.texture"
					end
				},
				wrinkle2_nrm_map = {
					type = "texture",
					param = function(arg_292_0, arg_292_1, arg_292_2)
						return "characters/player/textures/base/m_player_head_wrinkle02_nrm.texture"
					end
				},
				wrinkle3_nrm_map = {
					type = "texture",
					param = function(arg_293_0, arg_293_1, arg_293_2)
						return "characters/player/textures/base/m_player_head_wrinkle03_nrm.texture"
					end
				},
				wrinkle4_nrm_map = {
					type = "texture",
					param = function(arg_294_0, arg_294_1, arg_294_2)
						return "characters/player/textures/base/m_player_head_wrinkle04_nrm.texture"
					end
				},
				wrinkle_mat_map = {
					type = "texture",
					param = function(arg_295_0, arg_295_1, arg_295_2)
						return "characters/player/textures/base/m_player_head_wrinkle_mat.texture"
					end
				}
			},
			head_mat = {
				col_map = {
					type = "texture",
					resolution = var_0_49("headRes"),
					compositingGroup = function(arg_296_0)
						return var_0_17(arg_296_0) and "tier1_headColourLayers" or "headColourLayers"
					end,
					param = function(arg_297_0, arg_297_1, arg_297_2)
						return string.format("head_col_%s", arg_297_2.addressString)
					end,
					targetType = var_0_4.ColourMap
				},
				mat_map = {
					type = "texture",
					resolution = var_0_49("headRes"),
					compositingGroup = function(arg_298_0)
						return var_0_17(arg_298_0) and not var_0_19(arg_298_0) and "tier1_headMaterialLayers" or "headMaterialLayers"
					end,
					param = function(arg_299_0, arg_299_1, arg_299_2)
						return string.format("head_mat_%s", arg_299_2.addressString)
					end,
					targetType = var_0_4.MatMap
				},
				nrm_map = {
					type = "texture",
					resolution = var_0_49("headRes"),
					compositingGroup = function(arg_300_0)
						return var_0_17(arg_300_0) and not var_0_19(arg_300_0) and "tier1_headNormalLayers" or "headNormalLayers"
					end,
					param = function(arg_301_0, arg_301_1, arg_301_2)
						return string.format("head_nrm_%s", arg_301_2.addressString)
					end,
					targetType = var_0_4.NormalMap
				},
				msk_map = {
					compositingGroup = "headMskLayers",
					type = "texture",
					resolution = var_0_49("headRes"),
					targetType = var_0_4.MaskMap
				},
				bmp_map = {
					type = "texture",
					param = function(arg_302_0, arg_302_1, arg_302_2)
						return (var_0_52("skinmicrodetail_nrm", "skinmicrodetail_nrm"))
					end
				},
				dirt_map = {
					type = "texture",
					param = function(arg_303_0, arg_303_1, arg_303_2)
						return (var_0_52("head_dirt", "player_dirt_head_col"))
					end
				},
				sweat_nrm = {
					type = "texture",
					param = function(arg_304_0, arg_304_1, arg_304_2)
						return (var_0_52("head_sweat_nrm", "player_sweat_head_nrm"))
					end
				}
			},
			eyes_mat = {
				col_map = {
					type = "texture",
					resolution = var_0_49("eyesRes"),
					compositingGroup = function(arg_305_0, arg_305_1, arg_305_2)
						return "eyesColourLayers"
					end,
					param = function(arg_306_0, arg_306_1, arg_306_2)
						return string.format("eyes_col_%s", arg_306_2.addressString)
					end,
					targetType = var_0_4.ColourMap
				},
				mat_map = {
					type = "texture",
					param = function(arg_307_0, arg_307_1, arg_307_2)
						return (var_0_52("eye_textures_base", "eye_mat"))
					end
				},
				nrm_map = {
					type = "texture",
					param = function(arg_308_0, arg_308_1, arg_308_2)
						return (var_0_52("eye_textures_base", "eye_nrm"))
					end
				},
				height_map = {
					type = "texture",
					param = function(arg_309_0, arg_309_1, arg_309_2)
						return (var_0_52("eye_textures_base", "eye_height"))
					end
				}
			},
			eyelashes_mat = {
				col_map = {
					type = "texture",
					param = function(arg_310_0, arg_310_1, arg_310_2)
						return (var_0_52("eyelashStrand_col", "eyelashStrand_straight_col"))
					end
				},
				RedColour = {
					type = "vec4",
					param = function(arg_311_0, arg_311_1, arg_311_2)
						return native.vec4(0, 0, 0, 1)
					end
				}
			},
			eyes_clear_mat = {
				clrnrm_map = {
					type = "texture",
					param = function(arg_312_0, arg_312_1, arg_312_2)
						return (var_0_52("eye_textures_base", "eye_clear_nrm"))
					end
				},
				mat_map = {
					type = "texture",
					param = function(arg_313_0, arg_313_1, arg_313_2)
						return (var_0_52("eye_textures_base", "eye_mat"))
					end
				}
			}
		}
	},
	body = {
		filename = function(arg_314_0, arg_314_1, arg_314_2)
			if arg_314_0:getOption("hideBody") == 1 then
				return nil
			end

			local var_314_0 = {}
			local var_314_1 = {}
			local var_314_2 = 0
			local var_314_3 = arg_314_0:getOption("shoes")
			local var_314_4 = getItemByGuid(AssetMapItems.shoes, var_314_3)

			if var_314_4 and var_314_4.noSocks then
				var_314_2 = 2
			end

			local var_314_5, var_314_6, var_314_7 = getModelFileNameByGuid(var_314_2, AssetMapItems.body, arg_314_0, arg_314_1, var_314_0, var_314_1)

			return var_314_5, "", {}, "", ""
		end,
		materialContextFn = function(arg_315_0, arg_315_1, arg_315_2)
			return {
				bodyRes = VERIFY(var_0_3.body[arg_315_2])
			}
		end,
		materialConfig = {
			body_mat = {
				col_map = {
					type = "texture",
					compositingGroup = "bodyColourLayers",
					resolution = var_0_49("bodyRes"),
					param = function(arg_316_0, arg_316_1, arg_316_2)
						return string.format("body_col_%s", arg_316_2.addressString)
					end,
					targetType = var_0_4.ColourMap
				},
				mat_map = {
					type = "texture",
					compositingGroup = "bodyMaterialLayers",
					resolution = var_0_49("bodyRes"),
					param = function(arg_317_0, arg_317_1, arg_317_2)
						return string.format("body_mat_%s", arg_317_2.addressString)
					end,
					targetType = var_0_4.MatMap
				},
				nrm_map = {
					type = "texture",
					compositingGroup = "bodyNormalLayers",
					resolution = var_0_49("bodyRes"),
					param = function(arg_318_0, arg_318_1, arg_318_2)
						return string.format("body_nrm_%s", arg_318_2.addressString)
					end,
					targetType = var_0_4.NormalMap
				},
				msk_map = {
					compositingGroup = "bodyMskLayers",
					type = "texture",
					resolution = var_0_49("bodyRes"),
					targetType = var_0_4.MaskMap
				},
				bmp_map = {
					type = "texture",
					param = function(arg_319_0, arg_319_1, arg_319_2)
						return (var_0_52("head_bmp", "skinmicrodetail_nrm"))
					end
				},
				dirt_map = {
					type = "texture",
					param = function(arg_320_0, arg_320_1, arg_320_2)
						return (var_0_52("body_dirt", "player_dirt_body_col"))
					end
				},
				sweat_nrm = {
					type = "texture",
					param = function(arg_321_0, arg_321_1, arg_321_2)
						return (var_0_52("body_sweat_nrm", "player_sweat_body_nrm"))
					end
				}
			}
		}
	},
	top = {
		filename = function(arg_322_0, arg_322_1)
			local var_322_0 = {
				uniformTop = true
			}
			local var_322_1, var_322_2, var_322_3 = getModelFileName("uniformTop", "uniformTop", arg_322_0, arg_322_1, var_322_0)

			return var_322_1, "", {}, "", var_322_3
		end,
		materialContextFn = function(arg_323_0, arg_323_1, arg_323_2)
			return {
				uniformTopRes = VERIFY(var_0_3.uniformTop[arg_323_2]),
				uniformNumberPlateRes = VERIFY(var_0_3.uniformNumberPlate[arg_323_2])
			}
		end,
		materialConfig = {
			top_wrinkle_SS = {
				col_map = {
					type = "texture",
					compositingGroup = "uniformTopColourLayers",
					resolution = var_0_49("uniformTopRes"),
					targetType = var_0_4.ColourMap,
					useShared = function(arg_324_0, arg_324_1, arg_324_2)
						return true
					end,
					param = function(arg_325_0, arg_325_1, arg_325_2, arg_325_3)
						return "top col: " .. var_0_59(arg_325_0, arg_325_1)
					end
				},
				mat_map = {
					type = "texture",
					compositingGroup = "uniformTopMaterialLayers",
					resolution = var_0_49("uniformTopRes"),
					targetType = var_0_4.MatMap,
					useShared = function(arg_326_0, arg_326_1, arg_326_2)
						return true
					end,
					param = function(arg_327_0, arg_327_1, arg_327_2, arg_327_3)
						return "top mat: " .. var_0_59(arg_327_0, arg_327_1)
					end
				},
				nrm_map = {
					type = "texture",
					compositingGroup = "uniformTopNormalLayers",
					resolution = var_0_49("uniformTopRes"),
					targetType = var_0_4.NormalMap,
					useShared = function(arg_328_0, arg_328_1, arg_328_2)
						return true
					end,
					param = function(arg_329_0, arg_329_1, arg_329_2, arg_329_3)
						return "top nrm: " .. var_0_59(arg_329_0, arg_329_1)
					end
				},
				dirt_map = {
					type = "texture",
					param = function(arg_330_0, arg_330_1, arg_330_2)
						return (var_0_52("uniformTop_dirt", "uniformTop_dirt_col"))
					end
				},
				bmp_map = {
					type = "texture",
					param = function(arg_331_0, arg_331_1, arg_331_2)
						return (var_0_52("top_bmp", "topMicroDetail_nrm"))
					end
				},
				number_plate = {
					type = "texture",
					resolution = var_0_49("uniformNumberPlateRes"),
					targetType = var_0_4.ColourMap,
					compositingGroup = function(arg_332_0, arg_332_1, arg_332_2)
						return "uniformNumberLayers"
					end
				},
				wrinkle1_nrm_map = {
					type = "texture",
					param = function(arg_333_0, arg_333_1, arg_333_2)
						return "characters/uniforms/textures/m_top_wrinkle_01_nrm.texture"
					end
				},
				wrinkle2_nrm_map = {
					type = "texture",
					param = function(arg_334_0, arg_334_1, arg_334_2)
						return "characters/uniforms/textures/m_top_wrinkle_02_nrm.texture"
					end
				},
				wrinkle3_nrm_map = {
					type = "texture",
					param = function(arg_335_0, arg_335_1, arg_335_2)
						return "characters/uniforms/textures/m_top_wrinkle_03_nrm.texture"
					end
				}
			},
			top_SS = {
				col_map = {
					type = "texture",
					compositingGroup = "uniformTopColourLayers",
					resolution = var_0_49("uniformTopRes"),
					targetType = var_0_4.ColourMap,
					useShared = function(arg_336_0, arg_336_1, arg_336_2)
						return true
					end,
					param = function(arg_337_0, arg_337_1, arg_337_2, arg_337_3)
						return "top col: " .. var_0_59(arg_337_0, arg_337_1)
					end
				},
				mat_map = {
					type = "texture",
					compositingGroup = "uniformTopMaterialLayers",
					resolution = var_0_49("uniformTopRes"),
					targetType = var_0_4.MatMap,
					useShared = function(arg_338_0, arg_338_1, arg_338_2)
						return true
					end,
					param = function(arg_339_0, arg_339_1, arg_339_2, arg_339_3)
						return "top mat: " .. var_0_59(arg_339_0, arg_339_1)
					end
				},
				nrm_map = {
					type = "texture",
					compositingGroup = "uniformTopNormalLayers",
					resolution = var_0_49("uniformTopRes"),
					targetType = var_0_4.NormalMap,
					useShared = function(arg_340_0, arg_340_1, arg_340_2)
						return true
					end,
					param = function(arg_341_0, arg_341_1, arg_341_2, arg_341_3)
						return "top nrm: " .. var_0_59(arg_341_0, arg_341_1)
					end
				},
				dirt_map = {
					type = "texture",
					param = function(arg_342_0, arg_342_1, arg_342_2)
						return (var_0_52("uniformTop_dirt", "uniformTop_dirt_col"))
					end
				},
				bmp_map = {
					type = "texture",
					param = function(arg_343_0, arg_343_1, arg_343_2)
						return (var_0_52("top_bmp", "topMicroDetail_nrm"))
					end
				},
				number_plate = {
					type = "texture",
					resolution = var_0_49("uniformNumberPlateRes"),
					targetType = var_0_4.ColourMap,
					compositingGroup = function(arg_344_0, arg_344_1, arg_344_2)
						return "uniformNumberLayers"
					end
				}
			}
		}
	},
	bottom = {
		filename = function(arg_345_0, arg_345_1)
			local var_345_0 = {
				uniformBottom = true
			}
			local var_345_1, var_345_2, var_345_3 = getModelFileName("uniformBottom", "uniformBottom", arg_345_0, arg_345_1, var_345_0)

			return var_345_1, "", {}, "", var_345_3
		end,
		materialContextFn = function(arg_346_0, arg_346_1, arg_346_2)
			return {
				uniformBottomRes = VERIFY(var_0_3.uniformBottom[arg_346_2])
			}
		end,
		materialConfig = {
			bottom_wrinkle_SS = {
				col_map = {
					type = "texture",
					compositingGroup = "uniformBottomColourLayers",
					resolution = var_0_49("uniformBottomRes"),
					targetType = var_0_4.ColourMap,
					useShared = function(arg_347_0, arg_347_1, arg_347_2)
						return true
					end,
					param = function(arg_348_0, arg_348_1, arg_348_2, arg_348_3)
						return "bottom col: " .. var_0_60(arg_348_0, arg_348_1)
					end
				},
				mat_map = {
					type = "texture",
					compositingGroup = "uniformBottomMaterialLayers",
					resolution = var_0_49("uniformBottomRes"),
					targetType = var_0_4.MatMap,
					useShared = function(arg_349_0, arg_349_1, arg_349_2)
						return true
					end,
					param = function(arg_350_0, arg_350_1, arg_350_2, arg_350_3)
						return "bottom mat: " .. var_0_60(arg_350_0, arg_350_1)
					end
				},
				nrm_map = {
					type = "texture",
					compositingGroup = "uniformBottomNormalLayers",
					resolution = var_0_49("uniformBottomRes"),
					targetType = var_0_4.NormalMap,
					useShared = function(arg_351_0, arg_351_1, arg_351_2)
						return true
					end,
					param = function(arg_352_0, arg_352_1, arg_352_2, arg_352_3)
						return "bottom nrm: " .. var_0_60(arg_352_0, arg_352_1)
					end
				},
				dirt_map = {
					type = "texture",
					param = function(arg_353_0, arg_353_1, arg_353_2)
						return (var_0_52("uniformBottom_dirt", "uniformBottom_dirt_col"))
					end
				},
				wrinkle1_nrm_map = {
					type = "texture",
					param = function(arg_354_0, arg_354_1, arg_354_2)
						return "characters/uniforms/textures/m_shorts_wrinkle_01_nrm.texture"
					end
				},
				wrinkle2_nrm_map = {
					type = "texture",
					param = function(arg_355_0, arg_355_1, arg_355_2)
						return "characters/uniforms/textures/m_shorts_wrinkle_02_nrm.texture"
					end
				},
				wrinkle3_nrm_map = {
					type = "texture",
					param = function(arg_356_0, arg_356_1, arg_356_2)
						return "characters/uniforms/textures/m_shorts_wrinkle_03_nrm.texture"
					end
				}
			},
			bottom_SS = {
				col_map = {
					type = "texture",
					compositingGroup = "uniformBottomColourLayers",
					resolution = var_0_49("uniformBottomRes"),
					targetType = var_0_4.ColourMap,
					useShared = function(arg_357_0, arg_357_1, arg_357_2)
						return true
					end,
					param = function(arg_358_0, arg_358_1, arg_358_2, arg_358_3)
						return "bottom col: " .. var_0_60(arg_358_0, arg_358_1)
					end
				},
				mat_map = {
					type = "texture",
					compositingGroup = "uniformBottomMaterialLayers",
					resolution = var_0_49("uniformBottomRes"),
					targetType = var_0_4.MatMap,
					useShared = function(arg_359_0, arg_359_1, arg_359_2)
						return true
					end,
					param = function(arg_360_0, arg_360_1, arg_360_2, arg_360_3)
						return "bottom mat: " .. var_0_60(arg_360_0, arg_360_1)
					end
				},
				nrm_map = {
					type = "texture",
					compositingGroup = "uniformBottomNormalLayers",
					resolution = var_0_49("uniformBottomRes"),
					targetType = var_0_4.NormalMap,
					useShared = function(arg_361_0, arg_361_1, arg_361_2)
						return true
					end,
					param = function(arg_362_0, arg_362_1, arg_362_2, arg_362_3)
						return "bottom nrm: " .. var_0_60(arg_362_0, arg_362_1)
					end
				},
				dirt_map = {
					type = "texture",
					param = function(arg_363_0, arg_363_1, arg_363_2)
						return (var_0_52("uniformBottom_dirt", "uniformBottom_dirt_col"))
					end
				}
			}
		}
	},
	socks = {
		filename = function(arg_364_0, arg_364_1)
			local var_364_0 = {
				sockType = true,
				uniformSocks = true
			}
			local var_364_1 = arg_364_0:getOption("shoes")
			local var_364_2 = getItemByGuid(AssetMapItems.shoes, var_364_1)

			if var_364_2 and var_364_2.noSocks then
				return nil
			end

			return getModelFileName("uniformSocks", "uniformSocks", arg_364_0, arg_364_1, var_364_0), "", {}, "", ""
		end,
		materialContextFn = function(arg_365_0, arg_365_1, arg_365_2)
			return {
				uniformSocksShortRes = VERIFY(var_0_3.uniformSocksShort[arg_365_2]),
				uniformSocksLongRes = VERIFY(var_0_3.uniformSocksLong[arg_365_2])
			}
		end,
		materialConfig = {
			socks_SS = {
				col_map = {
					type = "texture",
					compositingGroup = "uniformSocksColourLayers",
					resolution = var_0_50(),
					targetType = var_0_4.ColourMap,
					useShared = function(arg_366_0, arg_366_1, arg_366_2)
						return true
					end,
					param = function(arg_367_0, arg_367_1, arg_367_2, arg_367_3)
						return "socks col: " .. var_0_61(arg_367_0, arg_367_1)
					end
				},
				mat_map = {
					type = "texture",
					compositingGroup = "uniformSocksMaterialLayers",
					resolution = var_0_50(),
					targetType = var_0_4.MatMap,
					useShared = function(arg_368_0, arg_368_1, arg_368_2)
						return true
					end,
					param = function(arg_369_0, arg_369_1, arg_369_2, arg_369_3)
						return "socks mat: " .. var_0_61(arg_369_0, arg_369_1)
					end
				},
				nrm_map = {
					type = "texture",
					compositingGroup = "uniformSocksNormalLayers",
					resolution = var_0_50(),
					targetType = var_0_4.NormalMap,
					useShared = function(arg_370_0, arg_370_1, arg_370_2)
						return true
					end,
					param = function(arg_371_0, arg_371_1, arg_371_2, arg_371_3)
						return "socks nrm: " .. var_0_61(arg_371_0, arg_371_1)
					end
				},
				dirt_map = {
					type = "texture",
					param = function(arg_372_0, arg_372_1, arg_372_2)
						return (var_0_52("uniformSocks_dirt", "uniformSocks_dirt_col"))
					end
				}
			}
		}
	},
	shoes = {
		filename = function(arg_373_0, arg_373_1)
			return getModelFileName("shoes", "shoes", arg_373_0, arg_373_1), "", {}, "", ""
		end,
		materialContextFn = function(arg_374_0, arg_374_1, arg_374_2)
			return {
				shoesRes = VERIFY(var_0_3.shoes[arg_374_2])
			}
		end,
		materialConfig = {
			shoesLeft_SS = {
				col_map = {
					type = "texture",
					compositingGroup = "shoesColourLayers",
					resolution = var_0_49("shoesRes"),
					targetType = var_0_4.ColourMap,
					useShared = function(arg_375_0, arg_375_1, arg_375_2)
						return true
					end,
					param = function(arg_376_0, arg_376_1, arg_376_2, arg_376_3)
						return "shoes col: " .. var_0_62(arg_376_0, arg_376_1)
					end
				},
				mat_map = {
					type = "texture",
					param = function(arg_377_0, arg_377_1, arg_377_2)
						local var_377_0 = var_0_30(arg_377_0)
						local var_377_1 = var_377_0 and var_377_0.matTexture

						return (var_0_52("shoes_mat", var_377_1))
					end
				},
				nrm_map = {
					type = "texture",
					param = function(arg_378_0, arg_378_1, arg_378_2)
						local var_378_0 = var_0_30(arg_378_0)
						local var_378_1 = var_378_0 and var_378_0.nrmTexture

						return (var_0_52("shoes_nrm", var_378_1))
					end
				},
				dirt_map = {
					type = "texture",
					param = function(arg_379_0, arg_379_1, arg_379_2)
						return (var_0_52("shoes_dirt", "boot_dirt_col"))
					end
				}
			},
			shoesRight_SS = {
				col_map = {
					type = "texture",
					compositingGroup = "shoesColourLayers",
					resolution = var_0_49("shoesRes"),
					targetType = var_0_4.ColourMap,
					useShared = function(arg_380_0, arg_380_1, arg_380_2)
						return true
					end,
					param = function(arg_381_0, arg_381_1, arg_381_2, arg_381_3)
						return "shoes col: " .. var_0_62(arg_381_0, arg_381_1)
					end
				},
				mat_map = {
					type = "texture",
					param = function(arg_382_0, arg_382_1, arg_382_2)
						local var_382_0 = var_0_30(arg_382_0)
						local var_382_1 = var_382_0 and var_382_0.matTexture

						return (var_0_52("shoes_mat", var_382_1))
					end
				},
				nrm_map = {
					type = "texture",
					param = function(arg_383_0, arg_383_1, arg_383_2)
						local var_383_0 = var_0_30(arg_383_0)
						local var_383_1 = var_383_0 and var_383_0.nrmTexture

						return (var_0_52("shoes_nrm", var_383_1))
					end
				},
				dirt_map = {
					type = "texture",
					param = function(arg_384_0, arg_384_1, arg_384_2)
						return (var_0_52("shoes_dirt", "boot_dirt_col"))
					end
				}
			}
		}
	},
	hairTop = {
		filename = function(arg_385_0, arg_385_1)
			if arg_385_0:getOption("hideBody") ~= 0 then
				return nil
			end

			local var_385_0 = var_0_51(arg_385_0)
			local var_385_1 = {
				hairGear = var_385_0
			}
			local var_385_2
			local var_385_3 = "hairTop"
			local var_385_4 = "hairTop"
			local var_385_5 = var_0_17_scanHair(arg_385_0)

			if var_385_5 then
				var_385_2 = arg_385_0:getOption("head") + 1000
			else
				var_385_2 = arg_385_0:getOption("hairTop")
			end

			if var_385_0 == 1 then
				local var_385_6 = var_0_20(arg_385_0)

				if var_385_6 and var_385_6.gear_top then
					local var_385_7 = AssetMapItems.hairTop_gear
					local var_385_8

					if var_385_5 then
						var_385_8 = getItemByGuid(var_385_7, var_385_2)
					else
						var_385_8 = getItemByGuidName(var_385_7, var_385_6.gear_top)
					end

					local var_385_9 = getModelFileNameByItem(var_385_8, var_385_7, arg_385_0, arg_385_1, nil, nil)
					local var_385_10 = getHairJigglyConfigTable(arg_385_0, var_385_0, var_385_3, var_385_4, var_385_8)

					return var_385_9, "", var_385_10, "", ""
				end

				return nil
			end

			local var_385_11 = getModelFileNameByGuid(var_385_2, AssetMapItems[var_385_4], arg_385_0, arg_385_1, nil, var_385_1)
			local var_385_12 = getHairJigglyConfigTable(arg_385_0, var_385_0, var_385_3, var_385_4)

			return var_385_11, "", var_385_12, "", ""
		end,
		materialConfig = {
			hairMaterial = {
				col_map = {
					type = "texture",
					param = function(arg_386_0, arg_386_1, arg_386_2)
						return (var_0_53(arg_386_0, "colTexture", "hairColMap_textures"))
					end
				},
				mat_map = {
					type = "texture",
					param = function(arg_387_0, arg_387_1, arg_387_2)
						return (var_0_53(arg_387_0, "matTexture", "hairMatMap_textures"))
					end
				},
				dir_map = {
					type = "texture",
					param = function(arg_388_0, arg_388_1, arg_388_2)
						return (var_0_53(arg_388_0, "dirTexture", "hairDirMap_textures"))
					end
				},
				hairColour1 = {
					type = "vec4",
					param = function(arg_389_0, arg_389_1, arg_389_2)
						return (var_0_55(arg_389_0, "hairColour1"))
					end
				},
				hairColour2 = {
					type = "vec4",
					param = function(arg_390_0, arg_390_1, arg_390_2)
						return (var_0_55(arg_390_0, "hairColour2"))
					end
				},
				tipFalloffValue = {
					type = "float",
					param = function(arg_391_0, arg_391_1, arg_391_2)
						local var_391_0 = var_0_56(arg_391_0, "tipFalloffValue")

						return var_391_0 > 0.01 and var_391_0 or 0.01
					end
				},
				tipOffsetValue = {
					type = "float",
					param = function(arg_392_0, arg_392_1, arg_392_2)
						return (var_0_56(arg_392_0, "tipOffsetValue"))
					end
				},
				tipOffsetBiasValue = {
					type = "float",
					param = function(arg_393_0, arg_393_1, arg_393_2)
						return (var_0_56(arg_393_0, "tipOffsetBiasValue"))
					end
				}
			},
			hairMaterial02 = {
				col_map = {
					type = "texture",
					param = function(arg_394_0, arg_394_1, arg_394_2)
						return (var_0_53(arg_394_0, "colTexture2", "hairColMap_textures"))
					end
				},
				mat_map = {
					type = "texture",
					param = function(arg_395_0, arg_395_1, arg_395_2)
						return (var_0_53(arg_395_0, "matTexture2", "hairMatMap_textures"))
					end
				},
				dir_map = {
					type = "texture",
					param = function(arg_396_0, arg_396_1, arg_396_2)
						return (var_0_53(arg_396_0, "dirTexture2", "hairDirMap_textures"))
					end
				},
				hairColour1 = {
					type = "vec4",
					param = function(arg_397_0, arg_397_1, arg_397_2)
						return (var_0_55(arg_397_0, "hairColour1"))
					end
				},
				hairColour2 = {
					type = "vec4",
					param = function(arg_398_0, arg_398_1, arg_398_2)
						return (var_0_55(arg_398_0, "hairColour2"))
					end
				},
				tipFalloffValue = {
					type = "float",
					param = function(arg_399_0, arg_399_1, arg_399_2)
						local var_399_0 = var_0_56(arg_399_0, "tipFalloffValue")

						return var_399_0 > 0.01 and var_399_0 or 0.01
					end
				},
				tipOffsetValue = {
					type = "float",
					param = function(arg_400_0, arg_400_1, arg_400_2)
						return (var_0_56(arg_400_0, "tipOffsetValue"))
					end
				},
				tipOffsetBiasValue = {
					type = "float",
					param = function(arg_401_0, arg_401_1, arg_401_2)
						return (var_0_56(arg_401_0, "tipOffsetBiasValue"))
					end
				}
			},
			hairMaterial_extra = {
				col_map = {
					type = "texture",
					param = function(arg_402_0, arg_402_1, arg_402_2)
						local var_402_0
						local var_402_1 = var_0_20(arg_402_0)

						if var_402_1 then
							if var_402_1.hairBand then
								var_402_0 = var_0_52("headBand_textures_col", "headBand01_matrix_col")
							else
								var_402_0 = var_0_52("hairTie_textures_col", "hairtie_col")
							end
						end

						return var_402_0
					end
				},
				mat_map = {
					type = "texture",
					param = function(arg_403_0, arg_403_1, arg_403_2)
						local var_403_0
						local var_403_1 = var_0_20(arg_403_0)

						if var_403_1 then
							if var_403_1.hairBand then
								var_403_0 = var_0_52("hairAccessory_textures", "headband01_mat")
							else
								var_403_0 = var_0_52("hairAccessory_textures", "hairtie_mat")
							end
						end

						return var_403_0
					end
				},
				nrm_map = {
					type = "texture",
					param = function(arg_404_0, arg_404_1, arg_404_2)
						local var_404_0
						local var_404_1 = var_0_20(arg_404_0)

						if var_404_1 then
							if var_404_1.hairBand then
								var_404_0 = var_0_52("hairAccessory_textures", "headband01_nrm")
							else
								var_404_0 = var_0_52("hairAccessory_textures", "hairtie_nrm")
							end
						end

						return var_404_0
					end
				}
			}
		}
	},
	hairSide = {
		filename = function(arg_405_0, arg_405_1)
			if arg_405_0:getOption("hideBody") ~= 0 then
				return nil
			end

			local var_405_0 = var_0_51(arg_405_0)
			local var_405_1 = {
				hairGear = var_405_0
			}
			local var_405_2
			local var_405_3 = "hairSide"
			local var_405_4 = "hairSide"
			local var_405_5 = var_0_17_scanHair(arg_405_0)

			if var_405_5 then
				var_405_2 = arg_405_0:getOption("head") + 1000
			else
				var_405_2 = arg_405_0:getOption(var_405_3)
			end

			if var_405_0 == 1 then
				local var_405_6 = var_0_20(arg_405_0)
				local var_405_7 = var_0_21(arg_405_0)
				local var_405_8 = var_405_7 and var_405_7.gear_side or var_405_6 and var_405_6.gear_side

				if var_405_8 then
					local var_405_9 = AssetMapItems.hairSide_gear
					local var_405_10
					local var_405_11 = getItemByGuidName(var_405_9, var_405_8)
					local var_405_12 = getItemByGuid(var_405_9, var_405_2)

					if var_405_5 then
						var_405_10 = var_405_12
					else
						var_405_10 = var_405_11
					end

					local var_405_13 = getModelFileNameByItem(var_405_10, var_405_9, arg_405_0, arg_405_1, nil, nil)
					local var_405_14 = getHairJigglyConfigTable(arg_405_0, var_405_0, var_405_3, var_405_4, var_405_11)

					return var_405_13, "", var_405_14, "", ""
				end

				return nil
			end

			local var_405_15 = getModelFileNameByGuid(var_405_2, AssetMapItems[var_405_4], arg_405_0, arg_405_1, nil, var_405_1)
			local var_405_16 = getHairJigglyConfigTable(arg_405_0, var_405_0, var_405_3, var_405_4)

			return var_405_15, "", var_405_16, "", ""
		end,
		materialConfig = {
			hairMaterial = {
				col_map = {
					type = "texture",
					param = function(arg_406_0, arg_406_1, arg_406_2)
						return (var_0_54(arg_406_0, "colTexture", "hairColMap_textures"))
					end
				},
				mat_map = {
					type = "texture",
					param = function(arg_407_0, arg_407_1, arg_407_2)
						return (var_0_54(arg_407_0, "matTexture", "hairMatMap_textures"))
					end
				},
				dir_map = {
					type = "texture",
					param = function(arg_408_0, arg_408_1, arg_408_2)
						return (var_0_54(arg_408_0, "dirTexture", "hairDirMap_textures"))
					end
				},
				hairColour1 = {
					type = "vec4",
					param = function(arg_409_0, arg_409_1, arg_409_2)
						return (var_0_55(arg_409_0, "hairColour1"))
					end
				},
				hairColour2 = {
					type = "vec4",
					param = function(arg_410_0, arg_410_1, arg_410_2)
						return (var_0_55(arg_410_0, "hairColour2"))
					end
				},
				tipFalloffValue = {
					type = "float",
					param = function(arg_411_0, arg_411_1, arg_411_2)
						local var_411_0 = var_0_56(arg_411_0, "tipFalloffValue")

						return var_411_0 > 0.01 and var_411_0 or 0.01
					end
				},
				tipOffsetValue = {
					type = "float",
					param = function(arg_412_0, arg_412_1, arg_412_2)
						return (var_0_56(arg_412_0, "tipOffsetValue"))
					end
				},
				tipOffsetBiasValue = {
					type = "float",
					param = function(arg_413_0, arg_413_1, arg_413_2)
						return (var_0_56(arg_413_0, "tipOffsetBiasValue"))
					end
				}
			},
			hairMaterial02 = {
				col_map = {
					type = "texture",
					param = function(arg_414_0, arg_414_1, arg_414_2)
						return (var_0_54(arg_414_0, "colTexture2", "hairColMap_textures"))
					end
				},
				mat_map = {
					type = "texture",
					param = function(arg_415_0, arg_415_1, arg_415_2)
						return (var_0_54(arg_415_0, "matTexture2", "hairMatMap_textures"))
					end
				},
				dir_map = {
					type = "texture",
					param = function(arg_416_0, arg_416_1, arg_416_2)
						return (var_0_54(arg_416_0, "dirTexture2", "hairDirMap_textures"))
					end
				},
				hairColour1 = {
					type = "vec4",
					param = function(arg_417_0, arg_417_1, arg_417_2)
						return (var_0_55(arg_417_0, "hairColour1"))
					end
				},
				hairColour2 = {
					type = "vec4",
					param = function(arg_418_0, arg_418_1, arg_418_2)
						return (var_0_55(arg_418_0, "hairColour2"))
					end
				},
				tipFalloffValue = {
					type = "float",
					param = function(arg_419_0, arg_419_1, arg_419_2)
						local var_419_0 = var_0_56(arg_419_0, "tipFalloffValue")

						return var_419_0 > 0.01 and var_419_0 or 0.01
					end
				},
				tipOffsetValue = {
					type = "float",
					param = function(arg_420_0, arg_420_1, arg_420_2)
						return (var_0_56(arg_420_0, "tipOffsetValue"))
					end
				},
				tipOffsetBiasValue = {
					type = "float",
					param = function(arg_421_0, arg_421_1, arg_421_2)
						return (var_0_56(arg_421_0, "tipOffsetBiasValue"))
					end
				}
			},
			hairMaterial_extra = {
				col_map = {
					type = "texture",
					param = function(arg_422_0, arg_422_1, arg_422_2)
						return (var_0_52("hairTie_textures_col", "hairtie_col"))
					end
				},
				mat_map = {
					type = "texture",
					param = function(arg_423_0, arg_423_1, arg_423_2)
						return (var_0_52("hairAccessory_textures", "hairtie_mat"))
					end
				},
				nrm_map = {
					type = "texture",
					param = function(arg_424_0, arg_424_1, arg_424_2)
						return (var_0_52("hairAccessory_textures", "hairtie_nrm"))
					end
				}
			}
		}
	},
	hairSide2 = {
		filename = function(arg_425_0, arg_425_1)
			if arg_425_0:getOption("hideBody") ~= 0 then
				return nil
			end

			local var_425_0 = var_0_51(arg_425_0)
			local var_425_1 = {
				hairGear = var_425_0
			}
			local var_425_2
			local var_425_3 = "hairSide2"
			local var_425_4 = "hairSide2"

			if var_0_17_scanHair(arg_425_0) then
				var_425_2 = arg_425_0:getOption("head") + 1000
			else
				var_425_2 = arg_425_0:getOption("hairSide2")
			end

			if var_425_0 == 1 then
				return nil
			end

			local var_425_5 = getModelFileNameByGuid(var_425_2, AssetMapItems[var_425_4], arg_425_0, arg_425_1, nil, var_425_1)
			local var_425_6 = getHairJigglyConfigTable(arg_425_0, var_425_0, var_425_3, var_425_4)

			return var_425_5, "", var_425_6, "", ""
		end,
		materialConfig = {
			hairMaterial03 = {
				col_map = {
					type = "texture",
					param = function(arg_426_0, arg_426_1, arg_426_2)
						local var_426_0 = var_0_22(arg_426_0)
						local var_426_1 = var_426_0 and var_426_0.colTexture3

						return (var_0_52("hairColMap_textures", var_426_1))
					end
				},
				mat_map = {
					type = "texture",
					param = function(arg_427_0, arg_427_1, arg_427_2)
						local var_427_0 = var_0_22(arg_427_0)
						local var_427_1 = var_427_0 and var_427_0.matTexture3

						return (var_0_52("hairMatMap_textures", var_427_1))
					end
				},
				dir_map = {
					type = "texture",
					param = function(arg_428_0, arg_428_1, arg_428_2)
						local var_428_0 = var_0_22(arg_428_0)
						local var_428_1 = var_428_0 and var_428_0.dirTexture3

						return (var_0_52("hairDirMap_textures", var_428_1))
					end
				},
				hairColour1 = {
					type = "vec4",
					param = function(arg_429_0, arg_429_1, arg_429_2)
						return (var_0_55(arg_429_0, "hairColour1"))
					end
				},
				hairColour2 = {
					type = "vec4",
					param = function(arg_430_0, arg_430_1, arg_430_2)
						return (var_0_55(arg_430_0, "hairColour2"))
					end
				},
				tipFalloffValue = {
					type = "float",
					param = function(arg_431_0, arg_431_1, arg_431_2)
						local var_431_0 = var_0_56(arg_431_0, "tipFalloffValue")

						return var_431_0 > 0.01 and var_431_0 or 0.01
					end
				},
				tipOffsetValue = {
					type = "float",
					param = function(arg_432_0, arg_432_1, arg_432_2)
						return (var_0_56(arg_432_0, "tipOffsetValue"))
					end
				},
				tipOffsetBiasValue = {
					type = "float",
					param = function(arg_433_0, arg_433_1, arg_433_2)
						return (var_0_56(arg_433_0, "tipOffsetBiasValue"))
					end
				}
			},
			hairMaterial_extra = {
				col_map = {
					type = "texture",
					param = function(arg_434_0, arg_434_1, arg_434_2)
						return (var_0_52("hairTie_textures_col", "hairtie_col"))
					end
				},
				mat_map = {
					type = "texture",
					param = function(arg_435_0, arg_435_1, arg_435_2)
						return (var_0_52("hairAccessory_textures", "hairtie_mat"))
					end
				},
				nrm_map = {
					type = "texture",
					param = function(arg_436_0, arg_436_1, arg_436_2)
						return (var_0_52("hairAccessory_textures", "hairtie_nrm"))
					end
				}
			}
		}
	},
	hairCap = {
		filename = function(arg_437_0, arg_437_1)
			if arg_437_0:getOption("hideBody") ~= 0 then
				return nil
			end

			local var_437_0 = AssetMapItems.hairCap
			local var_437_1
			local var_437_2 = "hairCap_col"
			local var_437_3 = "hairTexture_cap"
			local var_437_4 = arg_437_0:getOption(var_437_3)
			local var_437_5 = getItemByGuid(AssetMapItems[var_437_2], var_437_4)
			local var_437_6 = var_437_5 and var_437_5.noLayer == nil

			if var_0_17_scanHair(arg_437_0) then
				var_437_1 = var_437_6 and arg_437_0:getOption("head") + 1000
			else
				local var_437_7 = var_0_33(arg_437_0)

				var_437_1 = var_437_6 and var_437_7 and 2 or var_437_6 and 0 or var_437_7 and 1
			end

			return getModelFileNameByGuid(var_437_1, var_437_0, arg_437_0, arg_437_1), "", {}, "", ""
		end,
		materialContextFn = function(arg_438_0, arg_438_1, arg_438_2)
			return {
				headRes = VERIFY(var_0_3.head[arg_438_2])
			}
		end,
		materialConfig = {
			hairCap_mat = {
				col_map = {
					type = "texture",
					param = function(arg_439_0, arg_439_1, arg_439_2)
						local var_439_0 = var_0_23(arg_439_0)
						local var_439_1 = var_439_0 and var_439_0.noLayer == nil and var_439_0.name

						return (var_0_52("hairCap_col", var_439_1))
					end
				},
				mat_map = {
					type = "texture",
					param = function(arg_440_0, arg_440_1, arg_440_2)
						return (var_0_52("hairCap_mat", "haircap_mat"))
					end
				},
				hairColour1 = {
					type = "vec4",
					param = function(arg_441_0, arg_441_1, arg_441_2)
						return (var_0_55(arg_441_0, "hairColour1"))
					end
				}
			},
			beardCap_mat = {
				col_map = {
					type = "texture",
					resolution = var_0_49("headRes"),
					compositingGroup = function(arg_442_0, arg_442_1, arg_442_2)
						if var_0_33(arg_442_0) then
							return "beardCapColourLayers"
						end
					end,
					targetType = var_0_4.ColourMap,
					param = function(arg_443_0, arg_443_1, arg_443_2)
						return ""
					end
				},
				mat_map = {
					type = "texture",
					param = function(arg_444_0, arg_444_1, arg_444_2)
						return (var_0_52("hairCap_mat", "haircap_mat"))
					end
				},
				hairColour1 = {
					type = "vec4",
					param = function(arg_445_0, arg_445_1, arg_445_2)
						return (var_0_55(arg_445_0, "beardColour1"))
					end
				}
			}
		}
	},
	moustache = {
		filename = function(arg_446_0, arg_446_1)
			if arg_446_0:getOption("hideBody") ~= 0 then
				return nil
			end

			local var_446_0

			if var_0_17(arg_446_0) then
				var_446_0 = arg_446_0:getOption("head") + 1000
			else
				var_446_0 = arg_446_0:getOption("moustache")
			end

			local var_446_1 = getModelFileNameByGuid(var_446_0, AssetMapItems.moustache, arg_446_0, arg_446_1)
			local var_446_2 = {}

			return var_446_1, "", {}, "", ""
		end,
		materialConfig = {
			beardMaterial = {
				col_map = {
					type = "texture",
					param = function(arg_447_0, arg_447_1, arg_447_2)
						local var_447_0 = var_0_24(arg_447_0)
						local var_447_1 = var_447_0 and var_447_0.colTexture

						return (var_0_52("beardColMap_textures", var_447_1))
					end
				},
				mat_map = {
					type = "texture",
					param = function(arg_448_0, arg_448_1, arg_448_2)
						local var_448_0 = var_0_24(arg_448_0)
						local var_448_1 = var_448_0 and var_448_0.matTexture

						return (var_0_52("beardMatMap_textures", var_448_1))
					end
				},
				dir_map = {
					type = "texture",
					param = function(arg_449_0, arg_449_1, arg_449_2)
						local var_449_0 = var_0_24(arg_449_0)
						local var_449_1 = var_449_0 and var_449_0.dirTexture

						return (var_0_52("beardDirMap_textures", var_449_1))
					end
				},
				hairColour1 = {
					type = "vec4",
					param = function(arg_450_0, arg_450_1, arg_450_2)
						return (var_0_55(arg_450_0, "beardColour1"))
					end
				},
				hairColour2 = {
					type = "vec4",
					param = function(arg_451_0, arg_451_1, arg_451_2)
						return (var_0_55(arg_451_0, "beardColour2"))
					end
				},
				tipFalloffValue = {
					type = "float",
					param = function(arg_452_0, arg_452_1, arg_452_2)
						local var_452_0 = var_0_57(arg_452_0, "tipFalloffValue")

						return var_452_0 > 0.01 and var_452_0 or 0.01
					end
				},
				tipOffsetValue = {
					type = "float",
					param = function(arg_453_0, arg_453_1, arg_453_2)
						return (var_0_57(arg_453_0, "tipOffsetValue"))
					end
				},
				tipOffsetBiasValue = {
					type = "float",
					param = function(arg_454_0, arg_454_1, arg_454_2)
						return (var_0_57(arg_454_0, "tipOffsetBiasValue"))
					end
				}
			}
		}
	},
	chinhair = {
		filename = function(arg_455_0, arg_455_1)
			if arg_455_0:getOption("hideBody") ~= 0 then
				return nil
			end

			local var_455_0

			if var_0_17(arg_455_0) then
				var_455_0 = arg_455_0:getOption("head") + 1000
			else
				var_455_0 = arg_455_0:getOption("chinhair")
			end

			local var_455_1 = getModelFileNameByGuid(var_455_0, AssetMapItems.chinhair, arg_455_0, arg_455_1)
			local var_455_2 = getBeardJigglyConfigTable(arg_455_0, "chinhair")

			return var_455_1, "", {}, "", ""
		end,
		materialConfig = {
			beardMaterial = {
				col_map = {
					type = "texture",
					param = function(arg_456_0, arg_456_1, arg_456_2)
						local var_456_0 = var_0_25(arg_456_0)
						local var_456_1 = var_456_0 and var_456_0.colTexture

						return (var_0_52("beardColMap_textures", var_456_1))
					end
				},
				mat_map = {
					type = "texture",
					param = function(arg_457_0, arg_457_1, arg_457_2)
						local var_457_0 = var_0_25(arg_457_0)
						local var_457_1 = var_457_0 and var_457_0.matTexture

						return (var_0_52("beardMatMap_textures", var_457_1))
					end
				},
				dir_map = {
					type = "texture",
					param = function(arg_458_0, arg_458_1, arg_458_2)
						local var_458_0 = var_0_25(arg_458_0)
						local var_458_1 = var_458_0 and var_458_0.dirTexture

						return (var_0_52("beardDirMap_textures", var_458_1))
					end
				},
				hairColour1 = {
					type = "vec4",
					param = function(arg_459_0, arg_459_1, arg_459_2)
						return (var_0_55(arg_459_0, "beardColour1"))
					end
				},
				hairColour2 = {
					type = "vec4",
					param = function(arg_460_0, arg_460_1, arg_460_2)
						return (var_0_55(arg_460_0, "beardColour2"))
					end
				},
				tipFalloffValue = {
					type = "float",
					param = function(arg_461_0, arg_461_1, arg_461_2)
						local var_461_0 = var_0_57(arg_461_0, "tipFalloffValue")

						return var_461_0 > 0.01 and var_461_0 or 0.01
					end
				},
				tipOffsetValue = {
					type = "float",
					param = function(arg_462_0, arg_462_1, arg_462_2)
						return (var_0_57(arg_462_0, "tipOffsetValue"))
					end
				},
				tipOffsetBiasValue = {
					type = "float",
					param = function(arg_463_0, arg_463_1, arg_463_2)
						return (var_0_57(arg_463_0, "tipOffsetBiasValue"))
					end
				}
			}
		}
	},
	sideburns = {
		filename = function(arg_464_0, arg_464_1)
			if arg_464_0:getOption("hideBody") ~= 0 then
				return nil
			end

			local var_464_0

			if var_0_17(arg_464_0) then
				var_464_0 = arg_464_0:getOption("head") + 1000
			else
				var_464_0 = arg_464_0:getOption("sideburns")
			end

			local var_464_1 = getModelFileNameByGuid(var_464_0, AssetMapItems.sideburns, arg_464_0, arg_464_1)
			local var_464_2 = getBeardJigglyConfigTable(arg_464_0, "sideburns")

			return var_464_1, "", var_464_2, "", ""
		end,
		materialConfig = {
			beardMaterial = {
				col_map = {
					type = "texture",
					param = function(arg_465_0, arg_465_1, arg_465_2)
						local var_465_0 = var_0_26(arg_465_0)
						local var_465_1 = var_465_0 and var_465_0.colTexture

						return (var_0_52("beardColMap_textures", var_465_1))
					end
				},
				mat_map = {
					type = "texture",
					param = function(arg_466_0, arg_466_1, arg_466_2)
						local var_466_0 = var_0_26(arg_466_0)
						local var_466_1 = var_466_0 and var_466_0.matTexture

						return (var_0_52("beardMatMap_textures", var_466_1))
					end
				},
				dir_map = {
					type = "texture",
					param = function(arg_467_0, arg_467_1, arg_467_2)
						local var_467_0 = var_0_26(arg_467_0)
						local var_467_1 = var_467_0 and var_467_0.dirTexture

						return (var_0_52("beardDirMap_textures", var_467_1))
					end
				},
				hairColour1 = {
					type = "vec4",
					param = function(arg_468_0, arg_468_1, arg_468_2)
						return (var_0_55(arg_468_0, "beardColour1"))
					end
				},
				hairColour2 = {
					type = "vec4",
					param = function(arg_469_0, arg_469_1, arg_469_2)
						return (var_0_55(arg_469_0, "beardColour2"))
					end
				},
				tipFalloffValue = {
					type = "float",
					param = function(arg_470_0, arg_470_1, arg_470_2)
						local var_470_0 = var_0_57(arg_470_0, "tipFalloffValue")

						return var_470_0 > 0.01 and var_470_0 or 0.01
					end
				},
				tipOffsetValue = {
					type = "float",
					param = function(arg_471_0, arg_471_1, arg_471_2)
						return (var_0_57(arg_471_0, "tipOffsetValue"))
					end
				},
				tipOffsetBiasValue = {
					type = "float",
					param = function(arg_472_0, arg_472_1, arg_472_2)
						return (var_0_57(arg_472_0, "tipOffsetBiasValue"))
					end
				}
			}
		}
	},
	headWear = {
		filename = function(arg_473_0, arg_473_1)
			if arg_473_0:getOption("hideBody") == 1 then
				return nil
			end

			local var_473_0 = arg_473_0:getOption("helmet")
			local var_473_1 = arg_473_0:getOption("head") + 1000
			local var_473_2 = var_0_17_scanHair(arg_473_0)
			local var_473_3
			local var_473_4 = getItemByGuid(AssetMapItems.helmet, var_473_0)
			local var_473_5 = getItemByGuid(AssetMapItems.helmet, var_473_1)

			if var_473_2 then
				var_473_3 = var_473_5
			else
				var_473_3 = var_473_4
			end

			local var_473_6 = getModelFileNameByItem(var_473_3, AssetMapItems.helmet, arg_473_0, arg_473_1)
			local var_473_7 = getHeadwearJigglyConfigTable(var_473_4)

			return var_473_6, "", var_473_7, "", ""
		end,
		materialContextFn = function(arg_474_0, arg_474_1, arg_474_2)
			return {
				headwearRes = VERIFY(var_0_3.helmet[arg_474_2]),
				logoRes = VERIFY(var_0_3.logo[arg_474_2])
			}
		end,
		materialConfig = {
			headwear_SS = {
				col_map = {
					compositingGroup = "helmetColourLayers",
					type = "texture",
					resolution = var_0_49("headwearRes"),
					targetType = var_0_4.ColourMap
				},
				mat_map = {
					compositingGroup = "helmetMaterialLayers",
					type = "texture",
					resolution = var_0_49("headwearRes"),
					targetType = var_0_4.MatMap
				},
				nrm_map = {
					compositingGroup = "helmetNormalLayers",
					type = "texture",
					resolution = var_0_49("headwearRes"),
					targetType = var_0_4.NormalMap
				}
			}
		}
	},
	whistle = {
		filename = function(arg_475_0, arg_475_1, arg_475_2)
			local var_475_0 = {
				whistle = true
			}

			return getModelFileName("whistle", "whistle", arg_475_0, arg_475_1, var_475_0), "", {}, "", ""
		end,
		materialConfig = {
			whistle_SS = {
				col_map = {
					type = "texture",
					param = function(arg_476_0, arg_476_1, arg_476_2)
						return "characters/whistle/textures/whistle_col.texture"
					end
				},
				mat_map = {
					type = "texture",
					param = function(arg_477_0, arg_477_1, arg_477_2)
						return "characters/whistle/textures/whistle_mat.texture"
					end
				},
				nrm_map = {
					type = "texture",
					param = function(arg_478_0, arg_478_1, arg_478_2)
						return "characters/whistle/textures/whistle_nrm.texture"
					end
				}
			}
		}
	},
	flag = {
		filename = function(arg_479_0, arg_479_1, arg_479_2)
			local var_479_0
			local var_479_1
			local var_479_2 = arg_479_0:getOption("currentFlagType")

			if var_479_2 == "static" or var_479_2 == "dynamic" then
				var_479_1 = 2
				var_479_0 = "flag"
			else
				return
			end

			local var_479_3 = {
				flag = true
			}
			local var_479_4 = getModelFileNameByGuid(var_479_1, AssetMapItems[var_479_0], arg_479_0, arg_479_1, var_479_3)
			local var_479_5 = getFlagJigglyConfigTable(arg_479_1, var_479_1, var_479_0)

			return var_479_4, "", var_479_5, "", ""
		end,
		materialConfig = {
			flag_SS = {
				col_map = {
					type = "texture",
					param = function(arg_480_0, arg_480_1, arg_480_2)
						local var_480_0 = arg_480_1:getOption("flag_col")
						local var_480_1 = getItemByGuid(AssetMapItems.flag_col, var_480_0)

						return "characters/flag/textures/" .. var_480_1.name .. ".texture"
					end
				},
				mat_map = {
					type = "texture",
					param = function(arg_481_0, arg_481_1, arg_481_2)
						return "characters/flag/textures/flag_mat.texture"
					end
				},
				nrm_map = {
					type = "texture",
					param = function(arg_482_0, arg_482_1, arg_482_2)
						return "characters/flag/textures/flag_nrm.texture"
					end
				}
			}
		}
	},
	flag_static = {
		filename = function(arg_483_0, arg_483_1, arg_483_2)
			local var_483_0
			local var_483_1
			local var_483_2 = arg_483_0:getOption("currentFlagType")

			if var_483_2 == "static" or var_483_2 == "dynamic" then
				var_483_1 = 1
				var_483_0 = "flag"
			else
				return
			end

			local var_483_3 = {
				flag = true
			}
			local var_483_4 = getModelFileNameByGuid(var_483_1, AssetMapItems[var_483_0], arg_483_0, arg_483_1, var_483_3)
			local var_483_5 = getFlagJigglyConfigTable(arg_483_1, var_483_1, var_483_0)

			return var_483_4, "", var_483_5, "", ""
		end,
		materialConfig = {
			flag_SS = {
				col_map = {
					type = "texture",
					param = function(arg_484_0, arg_484_1, arg_484_2)
						local var_484_0 = arg_484_1:getOption("flag_col")
						local var_484_1 = getItemByGuid(AssetMapItems.flag_col, var_484_0)

						return "characters/flag/textures/" .. var_484_1.name .. ".texture"
					end
				},
				mat_map = {
					type = "texture",
					param = function(arg_485_0, arg_485_1, arg_485_2)
						return "characters/flag/textures/flag_mat.texture"
					end
				},
				nrm_map = {
					type = "texture",
					param = function(arg_486_0, arg_486_1, arg_486_2)
						return "characters/flag/textures/flag_nrm.texture"
					end
				}
			}
		}
	},
	trophy = {
		filename = function(arg_487_0, arg_487_1, arg_487_2)
			local var_487_0 = arg_487_0:getOption("currentTrophyType")
			local var_487_1 = getModelFileNameByGuidName(var_487_0, AssetMapItems.trophy, arg_487_0, arg_487_1)
			local var_487_2 = getTrophyJigglyConfigTable(var_487_0)

			return var_487_1, "", var_487_2, "", ""
		end,
		materialConfig = {
			trophy_SS = {
				col_map = {
					type = "texture",
					param = function(arg_488_0, arg_488_1, arg_488_2)
						local var_488_0 = arg_488_0:getOption("currentTrophyType")

						return "characters/trophies/textures/" .. var_488_0 .. "_col.texture"
					end
				},
				mat_map = {
					type = "texture",
					param = function(arg_489_0, arg_489_1, arg_489_2)
						local var_489_0 = arg_489_0:getOption("currentTrophyType")

						return "characters/trophies/textures/" .. var_489_0 .. "_mat.texture"
					end
				},
				nrm_map = {
					type = "texture",
					param = function(arg_490_0, arg_490_1, arg_490_2)
						local var_490_0 = arg_490_0:getOption("currentTrophyType")

						return "characters/trophies/textures/" .. var_490_0 .. "_nrm.texture"
					end
				}
			}
		}
	}
}

function upgradePlayerFunction1(arg_491_0)
	local var_491_0 = arg_491_0:getOption("arms_bodyShape")

	arg_491_0:getOption("arms_thickness_option", var_491_0)

	local var_491_1 = arg_491_0:getOption("legs_bodyShape")

	arg_491_0:getOption("legs_thickness_option", var_491_1)
end

local var_0_63 = {
	function(arg_492_0)
		upgradePlayerFunction1(arg_492_0)
	end
}
local var_0_64 = {}

local function var_0_65(arg_493_0, arg_493_1, arg_493_2, arg_493_3)
	for iter_493_0 = arg_493_2, arg_493_3 - 1 do
		arg_493_0[iter_493_0](arg_493_1)
	end

	return arg_493_3
end

PatchFunctions = {
	bat = function(arg_494_0, arg_494_1)
		return arg_494_1
	end,
	player = function(arg_495_0, arg_495_1)
		return var_0_65(var_0_63, arg_495_0, arg_495_1, var_0_10)
	end,
	team = function(arg_496_0, arg_496_1)
		return arg_496_1
	end
}
