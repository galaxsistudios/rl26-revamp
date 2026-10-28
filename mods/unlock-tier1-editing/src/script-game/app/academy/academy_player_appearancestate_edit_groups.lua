import("app.academy.academy_editgroup_helper")
import("app.academy.editassistant_imagebutton")
import("app.playermodel.playermodel_camera_aide")
import("core.foundation.tablex")
import("design.characters.assetmap")

local var_0_0 = native.Localise("Colour")
local var_0_1 = academy_editgroup_helper.createTopTierGroup
local var_0_2 = academy_editgroup_helper.createColourItem
local var_0_3 = academy_editgroup_helper.createSecondTierGroup
local var_0_4 = academy_editgroup_helper.createOptionItem
local var_0_5 = academy_editgroup_helper.createSliderItem
local var_0_6 = academy_editgroup_helper.createSliderColourItem
local var_0_7 = academy_editgroup_helper.createLeftRightItem
local var_0_8 = academy_editgroup_helper.createColourBarsFromOptions
local var_0_9 = academy_editgroup_helper.createColourPickerTriangleFromOptions
local var_0_10 = academy_editgroup_helper.resetPlayerDefaults
local var_0_11 = academy_editgroup_helper.createDecalItem
local var_0_12 = academy_editgroup_helper.createDecalList
local var_0_13 = academy_editgroup_helper.createSelectableLabel
local var_0_14 = academy_editgroup_helper.createToggleItem
local var_0_15 = assetmap.getItemByGuid
local var_0_16 = assetmap.getItemByGuidName
local var_0_17 = assetmap.AssetMapItems
local var_0_18 = academy_editgroup_helper.getEquipmentAdjustFn
local var_0_19 = academy_editgroup_helper.createDecalListWithMinIndex

local function var_0_20(arg_1_0, arg_1_1, arg_1_2)
	return arg_1_0 and arg_1_0.debugHook and arg_1_0.debugHook.isArtist
end

local function var_0_21(arg_2_0, arg_2_1, arg_2_2)
	return var_0_20(arg_2_2) or arg_2_0.academy
end

local function var_0_22(arg_3_0, arg_3_1, arg_3_2)
	return (var_0_20(arg_3_2) or arg_3_0.hidden == nil) and arg_3_0.tier1 == nil
end

local function var_0_23(arg_4_0, arg_4_1, arg_4_2)
	return arg_4_1.getCurrentConfig():getOption("isTier1") ~= 1
end

local function var_0_24(arg_5_0, arg_5_1)
	return (assetmap.ColourSwatches[arg_5_1]:getGuidAt(arg_5_0))
end

local function var_0_25(arg_6_0, arg_6_1, arg_6_2)
	return {
		trackChanges = false,
		requireButtonToEdit = false,
		label = arg_6_0,
		imageInfo = arg_6_1,
		subStateFactory = arg_6_2,
		editStateFactory = editassistant_imagebutton.EditAssistant_ImageButton
	}
end

local function var_0_26(arg_7_0, arg_7_1, arg_7_2, arg_7_3)
	ASSERT(arg_7_1 and (arg_7_1.player or arg_7_1.referee))

	local var_7_0 = arg_7_1.player or arg_7_1.referee

	var_7_0.visual:copy(arg_7_1:getCurrentConfig())

	if arg_7_1.player then
		var_7_0:heightWeight_SetAttributesFromVisual()
	elseif arg_7_1.referee then
		var_7_0:setNPCHeightWeightIdentityFromVisual()
	end

	return true
end

local function var_0_27(arg_8_0, arg_8_1, arg_8_2)
	local var_8_0 = arg_8_1.player and arg_8_1.player.attributes:getOption("weight") or arg_8_1.coach and arg_8_1.coach.weight or arg_8_1.referee and arg_8_1.referee.weight

	if arg_8_1.partyMember.settings.metric then
		return string.format("%dkg", var_8_0)
	else
		return native.CPlayerAttributes.weightInPounds(var_8_0)
	end
end

local function var_0_28(arg_9_0, arg_9_1, arg_9_2)
	local var_9_0 = arg_9_1.player and arg_9_1.player.attributes:getOption("height") or arg_9_1.coach and arg_9_1.coach.height or arg_9_1.referee and arg_9_1.referee.height

	if arg_9_1.partyMember.settings.metric then
		return string.format("%dcm", var_9_0)
	else
		return native.CPlayerAttributes.heightInFeet(var_9_0)
	end
end

local var_0_29 = var_0_5(native.Localise("Height"), {
	y = {
		"height",
		onAdjustFn = var_0_26
	}
}, {
	slowDownFactor = 0.005,
	getAdditionalLabelFn = var_0_28,
	getItemEnabledFn = function(arg_10_0, arg_10_1, arg_10_2)
		return not arg_10_1.isLicensed
	end
})
local var_0_30 = {
	var_0_29,
	var_0_5(native.Localise("Player_Appearance_HeadSize"), {
		x = {
			"headSize",
			0,
			1
		}
	}),
	var_0_7(native.Localise("Player_Appearance_NeckType"), "neckBodyMorph_option", {
		optionMap = "neckBodyMorphList"
	}),
	var_0_7(native.Localise("Player_AppearanceBody_BodyTypes"), "bodyShapeMorph_option", {
		optionMap = "bodyTypeMorphList"
	}),
	var_0_7(native.Localise("Player_Appearance_Body_BodyFigure"), "bodyFigureMorph_option", {
		optionMap = "bodyFigureMorphList"
	}),
	var_0_7(native.Localise("Player_Appearance_Body_BodyPhysique"), "bodyPhysiqueMorph_option", {
		optionMap = "bodyPhysiqueMorphList"
	}),
	var_0_5(native.Localise("Player_Appearance_Body_Neck"), {
		x = {
			"neckWidth_bodyShape"
		},
		y = {
			"neckLength_bodyShape"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Body_Traps"), {
		x = {
			"traps_bodyShape"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Body_UpperTorso"), {
		x = {
			"upperTorso_bodyShape"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Body_LowerTorso"), {
		x = {
			"lowerTorso_bodyShape"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Body_Arms"), {
		x = {
			"arms_thickness_option"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Body_UpperArms"), {
		x = {
			"armsUpper_bodyShape"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Body_LowerArms"), {
		x = {
			"armsLower_bodyShape"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Body_Legs"), {
		x = {
			"legs_thickness_option"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Body_UpperLegs"), {
		x = {
			"legsUpper_bodyShape"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Body_LowerLegs"), {
		x = {
			"legsLower_bodyShape"
		}
	})
}

local function var_0_31(arg_11_0, arg_11_1, arg_11_2, arg_11_3)
	local var_11_0 = arg_11_2.getCurrentConfig()
	local var_11_1 = arg_11_3.optionMap
	local var_11_2 = var_0_17[var_11_1]
	local var_11_3 = var_0_15(var_11_2, arg_11_0).optionListValues

	for iter_11_0, iter_11_1 in pairs(var_11_3) do
		var_11_0:setOption(iter_11_0, iter_11_1)
	end

	var_11_0:setOption(arg_11_3.optionName, arg_11_0)
end

local var_0_32 = {
	var_0_7(native.Localise("Player_AppearanceBody_BodyPreset"), "bodyPreset_option", {
		optionMap = "bodyPresetList_male",
		setValue = function(arg_12_0, arg_12_1, arg_12_2, arg_12_3)
			var_0_31(arg_12_0, arg_12_1, arg_12_2, arg_12_3)
		end
	})
}
local var_0_33 = {
	var_0_7(native.Localise("Player_AppearanceBody_BodyPreset"), "bodyPreset_option", {
		optionMap = "bodyPresetList_female",
		setValue = function(arg_13_0, arg_13_1, arg_13_2, arg_13_3)
			var_0_31(arg_13_0, arg_13_1, arg_13_2, arg_13_3)
		end
	})
}
local var_0_34 = {
	var_0_2(native.Localise("Player_Appearance_Advanced_SkinTone_SkinTone"), "skinTexture", "skinColourSwatches", {
		cols = 10,
		swatchScale = 1.1,
		setValue = function(arg_14_0, arg_14_1, arg_14_2, arg_14_3)
			local var_14_0 = var_0_24(arg_14_0, "skinColourSwatches")

			arg_14_2.getCurrentConfig():setOption(arg_14_3.optionName, var_14_0)
		end
	}),
	var_0_7(native.Localise("Player_Appearance_Advanced_SkinTone_CrowsFeet"), "crowsFeet_option", {
		optionMap = "crows_feet_col",
		camera = "HeadAndShoulders"
	}),
	var_0_7(native.Localise("Player_Appearance_Advanced_SkinTone_Scar"), "scar_type", {
		optionMap = "scar_head_col",
		camera = "HeadAndShoulders"
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_SkinTone_CheekRedness"), {
		x = {
			"redness_cheeks_amount"
		}
	}, {
		camera = "HeadAndShoulders"
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_SkinTone_NoseRedness"), {
		x = {
			"redness_nose_amount"
		}
	}, {
		camera = "HeadAndShoulders"
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_SkinTone_FaceRedness"), {
		x = {
			"redness_face_amount"
		}
	}, {
		camera = "HeadAndShoulders"
	}),
	var_0_7(native.Localise("Player_Appearance_Advanced_SkinTone_EyeSocketTintType"), "eyeSocketTint_type", {
		camera = "HeadAndShoulders"
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_SkinTone_LipTint"), {
		x = {
			"lipTint_amount"
		}
	}, {
		camera = "HeadAndShoulders"
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_SkinTone_BrowHighlight"), {
		x = {
			"highlightsBrow_amount"
		}
	}, {
		camera = "HeadAndShoulders"
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_SkinTone_cheekHighlight"), {
		x = {
			"highlightsCheeks_amount"
		}
	}, {
		camera = "HeadAndShoulders"
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_SkinTone_chinHighlight"), {
		x = {
			"highlightsChin_amount"
		}
	}, {
		camera = "HeadAndShoulders"
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_SkinTone_noseHighlight"), {
		x = {
			"highlightsNose_amount"
		}
	}, {
		camera = "HeadAndShoulders"
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_SkinTone_mouthHighlight"), {
		x = {
			"highlightsMouth_amount"
		}
	}, {
		camera = "HeadAndShoulders"
	}),
	var_0_7(native.Localise("Player_Appearance_Advanced_SkinTone_freckleTypeHighlight"), "freckles_type", {
		optionMap = "freckles_head_col",
		camera = "HeadAndShoulders"
	}),
	var_0_7(native.Localise("Player_Appearance_Advanced_SkinTone_moleHighlight"), "mole_head_type", {
		optionMap = "mole_head_col",
		camera = "HeadAndShoulders"
	})
}
local var_0_35 = {
	var_0_7(native.Localise("Player_Appearance_FaceShape"), "ethnicityShapeMorph_option", {
		optionMap = "ethnicityShapeMorphList"
	}),
	var_0_7(native.Localise("Player_Appearance_Advanced_Head_HeadShapes"), "headShapeMorph_option", {
		optionMap = "headShapeMorphList"
	}),
	var_0_7(native.Localise("Player_Appearance_Advanced_Head_JawShapes"), "jawShapeMorph_option", {
		optionMap = "jawShapeMorphList"
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Head_Head"), {
		x = {
			"head_width_option"
		},
		y = {
			"head_height"
		},
		x2 = {
			"head_depth"
		},
		y2 = {
			"headSize",
			1,
			0
		}
	}, {
		extraMorphHeight = 30
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Head_Head2"), {
		x = {
			"head_depth"
		},
		y = {
			"headSize",
			1,
			0
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Head_Skull"), {
		x = {
			"skull_width_option"
		},
		y = {
			"skull_height"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Head_Skull2"), {
		x = {
			"skull_depth"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Head_Temple"), {
		x = {
			"temple_width_option"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Head_Temple2"), {
		x = {
			"temporalis_width"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Head_Forehead"), {
		x = {
			"forehead_width"
		},
		y = {
			"forehead_height"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Head_Forehead2"), {
		x = {
			"forehead_depth"
		}
	})
}
local var_0_36 = {
	var_0_5(native.Localise("Player_Appearance_Advanced_Head_Brow"), {
		x = {
			"brow_width"
		},
		y = {
			"brow_height_option"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Head_Brow2"), {
		x = {
			"brow_depth"
		},
		y = {
			"brow_size"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Head_Cheekbone"), {
		x = {
			"cheekbone_width"
		},
		y = {
			"cheekbone_height"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Head_Cheekbone2"), {
		x = {
			"cheekbone_depth"
		},
		y = {
			"malar_depth"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Head_Cheek"), {
		x = {
			"cheek_width_option"
		},
		y = {
			"cheek_depth"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Head_Cheek2"), {
		x = {
			"mouth_jowl_width"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Head_Jaw"), {
		x = {
			"jaw_width"
		},
		y = {
			"jaw_height"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Head_Jaw2"), {
		x = {
			"jaw_depth"
		},
		y = {
			"jaw_angle_height"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Head_Chin"), {
		x = {
			"chin_width"
		},
		y = {
			"chin_height"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Head_Chin2"), {
		x = {
			"chin_depth_option"
		}
	})
}
local var_0_37 = {
	var_0_7(native.Localise("Player_Appearance_Advanced_Nose_NoseShapes"), "noseShapeMorph_option", {
		optionMap = "noseShapeMorphList"
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Nose_Nose"), {
		x = {
			"nose_width_option"
		},
		y = {
			"nose_height"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Nose_Nose2"), {
		x = {
			"nose_depth_option"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Nose_NoseRoot"), {
		x = {
			"nose_root_width_option"
		},
		y = {
			"nose_root_height_option"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Nose_NoseRoot2"), {
		x = {
			"nose_root_depth_option"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Nose_NoseBridge"), {
		x = {
			"nose_bridge_width"
		},
		y = {
			"nose_break_option"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Nose_NoseTip"), {
		x = {
			"nose_tip_width"
		},
		y = {
			"nose_tip_height_option"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Nose_NoseTip2"), {
		x = {
			"nose_tip_depth"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Nose_Septum"), {
		x = {
			"septum_width_option"
		},
		y = {
			"nose_septum_height"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Nose_Nostril"), {
		x = {
			"nose_nostril_width"
		},
		y = {
			"nostril_height_option"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Nose_Nostril2"), {
		x = {
			"nose_nostril_depth"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Nose_NostrilSize"), {
		x = {
			"nostril_size"
		},
		y = {
			"nostril_thickness"
		}
	})
}
local var_0_38 = {
	var_0_4(native.Localise("Player_Appearance_EyeColour"), "eyeTexture", {
		optionMap = "eye_textures_col",
		filterFn = var_0_22
	}),
	var_0_7(native.Localise("Player_Appearance_Advanced_Eyes_LimbalRing"), "limbal_ring_option", {
		optionMap = "limbal_ring_col"
	}),
	var_0_7(native.Localise("Player_Appearance_Advanced_Eyes_EyeShapes"), "eyesShapeMorph_option", {
		optionMap = "eyesShapeMorphList"
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Eyes_EyePosition"), {
		x = {
			"eyes_width_option"
		},
		y = {
			"eyes_height_option"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Eyes_EyePosition2"), {
		x = {
			"eyes_depth"
		},
		y = {
			"eyes_size"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Eyes_IrisSize"), {
		x = {
			"eyes_iris_size"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Eyes_InnerEyes"), {
		x = {
			"eye_inner_width_option"
		},
		y = {
			"eye_inner_height"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Eyes_InnerEyes2"), {
		y = {
			"eyelid_droop_option"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Eyes_EyesOffset"), {
		x = {
			"bottom_eyelid_height"
		},
		y = {
			"top_eyelid_height"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Eyes_EyesOffset2"), {
		x = {
			"eye_rotation_option"
		},
		y = {
			"eye_symmetry_option"
		}
	})
}
local var_0_39 = {
	var_0_7(native.Localise("Player_Appearance_Advanced_Ears_EarPosition"), "earsShapeMorph_option", {
		optionMap = "earsShapeMorphList"
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Ears_EarHeight"), {
		x = {
			"ears_angle_option"
		},
		y = {
			"ears_height_option"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Ears_EarHeight2"), {
		x = {
			"ear_depth_option"
		},
		y = {
			"ears_size"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Ears_EarExtra"), {
		x = {
			"ear_rotation_option"
		},
		y = {
			"ear_symmetry_option"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Ears_EarTopHeight"), {
		x = {
			"ears_bottom_height"
		},
		y = {
			"ears_top_height"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Ears_EarTopHeight2"), {
		x = {
			"ears_middle_width"
		}
	})
}
local var_0_40 = {
	var_0_7(native.Localise("Player_Appearance_Advanced_Mouth_MouthShapes"), "mouthShapeMorph_option", {
		optionMap = "mouthShapeMorphList"
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Mouth_Mouth"), {
		x = {
			"mouth_width_option"
		},
		y = {
			"mouth_height_option"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Mouth_Mouth2"), {
		x = {
			"mouth_depth"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Mouth_UpperLip"), {
		y = {
			"upper_lip_height_option"
		},
		x = {
			"philtrum_option"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Mouth_UpperLip2"), {
		x = {
			"upper_lip_depth"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Mouth_MiddleLip"), {
		x = {
			"middle_lip_width"
		},
		y = {
			"middle_lip_height"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Mouth_LowerLip"), {
		x = {
			"oris_depth"
		},
		y = {
			"lower_lip_height_option"
		}
	}),
	var_0_5(native.Localise("Player_Appearance_Advanced_Mouth_LowerLip2"), {
		x = {
			"lower_lip_depth"
		}
	})
}
local var_0_41 = {
	var_0_4(native.Localise("HairStyle1"), "hair", {
		optionMap = "hair",
		filterFn = var_0_22,
		setValue = function(arg_15_0, arg_15_1, arg_15_2, arg_15_3)
			local var_15_0 = arg_15_2.getCurrentConfig()
			local var_15_1 = arg_15_3.optionMap
			local var_15_2 = var_0_17[var_15_1]
			local var_15_3 = var_0_15(var_15_2, arg_15_0)
			local var_15_4 = var_15_2.presetOptionList

			if var_15_3 then
				for iter_15_0, iter_15_1 in pairs(var_15_4) do
					local var_15_5 = iter_15_1.option
					local var_15_6 = iter_15_1.optionMap or var_15_5
					local var_15_7 = iter_15_1.default or 0
					local var_15_8 = var_15_3[var_15_5]
					local var_15_9 = var_15_8 and assetmap.getItemByGuidName(var_0_17[var_15_6], var_15_8)
					local var_15_10 = var_15_9 and var_15_9.guid or var_15_7

					var_15_0:setOption(var_15_5, var_15_10)
				end
			end

			var_15_0:setOption(arg_15_3.optionName, arg_15_0)
		end,
		getItemEnabledFn = var_0_23
	})
}
local var_0_42 = {
	var_0_7(native.Localise("HairTop"), "hairTop", {
		optionMap = "hairTop",
		filterFn = var_0_22,
		getItemEnabledFn = var_0_23
	}),
	var_0_7(native.Localise("HairSide"), "hairSide", {
		optionMap = "hairSide",
		filterFn = var_0_22,
		getItemEnabledFn = var_0_23
	}),
	var_0_7(native.Localise("HairSide2"), "hairSide2", {
		optionMap = "hairSide2",
		filterFn = var_0_22,
		getItemEnabledFn = var_0_23
	}),
	var_0_7(native.Localise("hairTexture_cap"), "hairTexture_cap", {
		optionMap = "hairCap_col"
	})
}
local var_0_43 = {
	var_0_7(native.Localise("Moustache"), "moustache", {
		optionMap = "moustache",
		filterFn = var_0_22,
		getItemEnabledFn = var_0_23
	}),
	var_0_7(native.Localise("Chinhair"), "chinhair", {
		optionMap = "chinhair",
		filterFn = var_0_22,
		getItemEnabledFn = var_0_23
	}),
	var_0_7(native.Localise("Sideburns"), "sideburns", {
		optionMap = "sideburns",
		filterFn = var_0_22,
		getItemEnabledFn = var_0_23
	})
}
local var_0_44 = {
	var_0_2(native.Localise("Player_Appearance_HairColour"), "hairColour1", "hairColourSwatches", {
		setValue = function(arg_16_0, arg_16_1, arg_16_2, arg_16_3)
			local var_16_0 = var_0_24(arg_16_0, "hairColourSwatches")

			arg_16_2.getCurrentConfig():setOption(arg_16_3.optionName, var_16_0)
		end
	}),
	var_0_2(native.Localise("Player_Appearance_SecondaryHairColour"), "hairColour2", "hairColourSwatches", {
		setValue = function(arg_17_0, arg_17_1, arg_17_2, arg_17_3)
			local var_17_0 = var_0_24(arg_17_0, "hairColourSwatches")

			arg_17_2.getCurrentConfig():setOption(arg_17_3.optionName, var_17_0)
		end
	}),
	var_0_7(native.Localise("Player_Appearance_HairTipsOption"), "hairTipsOption", {
		optionMap = "hairTipsOptionList"
	})
}
local var_0_45 = tablex.iconcat(var_0_41, var_0_42)

tablex.iconcatInto(var_0_45, var_0_44)
tablex.iconcatInto(var_0_41, var_0_44)

local var_0_46 = {
	var_0_2(native.Localise("Player_Appearance_BeardColour"), "beardColour1", "hairColourSwatches", {
		setValue = function(arg_18_0, arg_18_1, arg_18_2, arg_18_3)
			local var_18_0 = var_0_24(arg_18_0, "hairColourSwatches")

			arg_18_2.getCurrentConfig():setOption(arg_18_3.optionName, var_18_0)
		end
	}),
	var_0_2(native.Localise("Player_Appearance_SecondaryBeardColour"), "beardColour2", "hairColourSwatches", {
		setValue = function(arg_19_0, arg_19_1, arg_19_2, arg_19_3)
			local var_19_0 = var_0_24(arg_19_0, "hairColourSwatches")

			arg_19_2.getCurrentConfig():setOption(arg_19_3.optionName, var_19_0)
		end
	}),
	var_0_7(native.Localise("Player_Appearance_BeardTipsOption"), "beardTipsOption", {
		optionMap = "hairTipsOptionList"
	}),
	var_0_7(native.Localise("Player_Appearance_BodyHairStyle"), "bodyHair_type", {
		optionMap = "bodyHair_head_col"
	})
}
local var_0_47 = {
	var_0_4(native.Localise("BeardStyle1"), "beard", {
		optionMap = "beard",
		filterFn = var_0_22,
		setValue = function(arg_20_0, arg_20_1, arg_20_2, arg_20_3)
			local var_20_0 = arg_20_2.getCurrentConfig()
			local var_20_1 = arg_20_3.optionMap
			local var_20_2 = var_0_17[var_20_1]
			local var_20_3 = var_0_15(var_0_17.beard, arg_20_0)
			local var_20_4 = var_20_2.presetOptionList

			if var_20_3 then
				for iter_20_0, iter_20_1 in pairs(var_20_4) do
					local var_20_5 = iter_20_1.option
					local var_20_6 = iter_20_1.optionMap or var_20_5
					local var_20_7 = iter_20_1.default or 0
					local var_20_8 = var_20_3[var_20_5]
					local var_20_9 = var_20_8 and assetmap.getItemByGuidName(var_0_17[var_20_6], var_20_8)
					local var_20_10 = var_20_9 and var_20_9.guid or var_20_7

					var_20_0:setOption(var_20_5, var_20_10)
				end
			end

			var_20_0:setOption(arg_20_3.optionName, arg_20_0)
		end
	})
}
local var_0_48 = tablex.iconcat(var_0_47, var_0_43)

tablex.iconcatInto(var_0_48, var_0_46)
tablex.iconcatInto(var_0_47, var_0_46)

local var_0_49 = var_0_3("BodyHair", "icon_bodyhair", playermodel_camera_aide.TorsoCloseUp, {
	var_0_9(var_0_0, "bodyHair_colour_r", "bodyHair_colour_g", "bodyHair_colour_b")
})
local var_0_50 = {
	var_0_7(native.Localise("EyeBrows"), "eyebrows_type", {
		optionMap = "eyebrows_head_col"
	}),
	var_0_2(native.Localise("Player_Appearance_BodyHairColour"), "bodyHair_colour", "hairNaturalColourSwatches", {
		cols = 13,
		swatchScale = 0.85,
		setValue = function(arg_21_0, arg_21_1, arg_21_2, arg_21_3)
			local var_21_0 = var_0_24(arg_21_0, "hairNaturalColourSwatches")

			arg_21_2.getCurrentConfig():setOption(arg_21_3.optionName, var_21_0)
		end
	})
}
local var_0_51 = var_0_7(native.Localise("TIER1 HEAD"), "head", {
	optionMap = "tier1head"
})
local var_0_52 = var_0_3("SizeFitness", "icon_body", playermodel_camera_aide.FullBody_NotRelativeToPlayerHeight, {
	var_0_4(native.Localise("HACK LOADDATA"), "hack", {
		optionMap = "hack",
		setValue = function(arg_22_0, arg_22_1, arg_22_2, arg_22_3)
			local var_22_0 = arg_22_2.getCurrentConfig()
			local var_22_1 = arg_22_1.uiServices
			local var_22_2 = 469
			local var_22_3 = var_22_1:getPlayerManager().OnDisc:getPlayer(var_22_2)

			var_22_1:playerModelUpdate(1, {
				refresh = true,
				player = var_22_3
			})
		end
	})
})
local var_0_53 = {
	var_0_7(native.Localise("Player_Appearance_LeftArmSleeves"), "skins_left_option", {
		optionMap = "skins_left_col"
	}),
	var_0_7(native.Localise("Player_Appearance_RightArmSleeves"), "skins_right_option", {
		optionMap = "skins_right_col"
	})
}
local var_0_54 = {
	var_0_7(native.Localise("Player_Appearance_CompressionShorts"), "compression_option", {
		optionMap = "compression_col"
	})
}
local var_0_55 = {
	var_0_7(native.Localise("Player_Appearance_LeftHandStrapping"), "strapping_handLeft_option", {
		optionMap = "strapping_handLeft_col"
	}),
	var_0_7(native.Localise("Player_Appearance_LeftLowerArmStrapping"), "strapping_wristLeft_option", {
		optionMap = "strapping_wristLeft_col"
	}),
	var_0_7(native.Localise("Player_Appearance_LeftUpperArmStrapping"), "strapping_elbowLeft_option", {
		optionMap = "strapping_elbowLeft_col"
	}),
	var_0_7(native.Localise("Player_Appearance_RightHandStrapping"), "strapping_handRight_option", {
		optionMap = "strapping_handRight_col"
	}),
	var_0_7(native.Localise("Player_Appearance_RightLowerArmStrapping"), "strapping_wristRight_option", {
		optionMap = "strapping_wristRight_col"
	}),
	var_0_7(native.Localise("Player_Appearance_RightUpperArmStrapping"), "strapping_elbowRight_option", {
		optionMap = "strapping_elbowRight_col"
	})
}
local var_0_56 = {
	var_0_7(native.Localise("Player_Appearance_LeftPinkyFingerStrapping"), "strapping_fingerpinkyLeft_option", {
		optionMap = "strapping_fingerpinkyLeft_col"
	}),
	var_0_7(native.Localise("Player_Appearance_LeftRingFingerStrapping"), "strapping_fingerringLeft_option", {
		optionMap = "strapping_fingerringLeft_col"
	}),
	var_0_7(native.Localise("Player_Appearance_LeftMiddleFingerStrapping"), "strapping_fingermiddleLeft_option", {
		optionMap = "strapping_fingermiddleLeft_col"
	}),
	var_0_7(native.Localise("Player_Appearance_LeftPointerFingerStrapping"), "strapping_fingerpointerLeft_option", {
		optionMap = "strapping_fingerpointerLeft_col"
	}),
	var_0_7(native.Localise("Player_Appearance_RightPinkyFingerStrapping"), "strapping_fingerpinkyRight_option", {
		optionMap = "strapping_fingerpinkyRight_col"
	}),
	var_0_7(native.Localise("Player_Appearance_RightRingFingerStrapping"), "strapping_fingerringRight_option", {
		optionMap = "strapping_fingerringRight_col"
	}),
	var_0_7(native.Localise("Player_Appearance_RightMiddleFingerStrapping"), "strapping_fingermiddleRight_option", {
		optionMap = "strapping_fingermiddleRight_col"
	}),
	var_0_7(native.Localise("Player_Appearance_RightPointerFingerStrapping"), "strapping_fingerpointerRight_option", {
		optionMap = "strapping_fingerpointerRight_col"
	})
}
local var_0_57 = {
	var_0_7(native.Localise("Player_Appearance_LeftKneeStrapping"), "strapping_kneeLeft_option", {
		optionMap = "strapping_kneeLeft_col"
	}),
	var_0_7(native.Localise("Player_Appearance_RightKneeStrapping"), "strapping_kneeRight_option", {
		optionMap = "strapping_kneeRight_col"
	}),
	var_0_7(native.Localise("Player_Appearance_RightThighStrapping"), "strapping_thighRight_option", {
		optionMap = "strapping_thighRight_col"
	}),
	var_0_7(native.Localise("Player_Appearance_LeftThighStrapping"), "strapping_thighLeft_option", {
		optionMap = "strapping_thighLeft_col"
	})
}
local var_0_58 = {
	var_0_7(native.Localise("Player_Appearance_Tattoo_LeftNeck"), "leftNeckTattoo_type", {
		optionMap = "leftNeckTattoo_head"
	}),
	var_0_7(native.Localise("Player_Appearance_Tattoo_RightNeck"), "rightNeckTattoo_type", {
		optionMap = "rightNeckTattoo_head"
	}),
	var_0_7(native.Localise("Player_Appearance_Tattoo_MidNeck"), "midNeckTattoo_type", {
		optionMap = "midNeckTattoo_head"
	})
}
local var_0_59 = {
	var_0_7(native.Localise("Player_Appearance_Tattoo_LeftArm"), "leftArmTattoo_type", {
		optionMap = "leftArmTattoo_body"
	}),
	var_0_7(native.Localise("Player_Appearance_Tattoo_RightArm"), "rightArmTattoo_type", {
		optionMap = "rightArmTattoo_body"
	})
}
local var_0_60 = {
	var_0_7(native.Localise("Player_Appearance_Tattoo_LeftLeg"), "leftLegTattoo_type", {
		optionMap = "leftLegTattoo_body"
	}),
	var_0_7(native.Localise("Player_Appearance_Tattoo_RightLeg"), "rightLegTattoo_type", {
		optionMap = "rightLegTattoo_body"
	})
}

local function var_0_61(arg_23_0, arg_23_1)
	local var_23_0 = arg_23_0.getCurrentConfig():getOption("helmet")
	local var_23_1 = var_0_15(var_0_17.helmet, var_23_0)

	if var_23_1 then
		if var_23_1.noModel then
			return false
		elseif var_23_1.headStrapping and arg_23_1 then
			return true
		elseif not var_23_1.headStrapping and not arg_23_1 then
			return true
		end
	end

	return false
end

local var_0_62 = {
	var_0_7(native.Localise("Player_Appearance_Helmet"), "helmet", {
		filterFn = var_0_21
	}),
	var_0_9(string.format("%s %d", native.Localise("Colour"), 1), "headwearColour1_r", "headwearColour1_g", "headwearColour1_b", {
		getItemEnabledFn = function(arg_24_0, arg_24_1, arg_24_2)
			return var_0_61(arg_24_1, false)
		end
	}),
	var_0_9(string.format("%s %d", native.Localise("Colour"), 2), "headwearColour2_r", "headwearColour2_g", "headwearColour2_b", {
		getItemEnabledFn = function(arg_25_0, arg_25_1, arg_25_2)
			return var_0_61(arg_25_1, false)
		end
	}),
	var_0_9(string.format("%s %d", native.Localise("Colour"), 3), "headwearColour3_r", "headwearColour3_g", "headwearColour3_b", {
		getItemEnabledFn = function(arg_26_0, arg_26_1, arg_26_2)
			return var_0_61(arg_26_1, false)
		end
	}),
	var_0_9(string.format("%s %d", native.Localise("Colour"), 4), "headwearColour4_r", "headwearColour4_g", "headwearColour4_b", {
		getItemEnabledFn = function(arg_27_0, arg_27_1, arg_27_2)
			return var_0_61(arg_27_1, false)
		end
	}),
	var_0_9(string.format("%s %d", native.Localise("Colour"), 1), "headStrappingColour1_r", "headStrappingColour1_g", "headStrappingColour1_b", {
		getItemEnabledFn = function(arg_28_0, arg_28_1, arg_28_2)
			return var_0_61(arg_28_1, true)
		end
	}),
	var_0_9(string.format("%s %d", native.Localise("Colour"), 2), "headStrappingColour2_r", "headStrappingColour2_g", "headStrappingColour2_b", {
		getItemEnabledFn = function(arg_29_0, arg_29_1, arg_29_2)
			return var_0_61(arg_29_1, true)
		end
	})
}
local var_0_63 = {
	var_0_9(string.format("%s %d", native.Localise("Colour"), 1), "shoeColour1_r", "shoeColour1_g", "shoeColour1_b"),
	var_0_9(string.format("%s %d", native.Localise("Colour"), 2), "shoeColour2_r", "shoeColour2_g", "shoeColour2_b"),
	var_0_9(string.format("%s %d", native.Localise("Colour"), 3), "shoeColour3_r", "shoeColour3_g", "shoeColour3_b"),
	var_0_9(string.format("%s %d", native.Localise("Colour"), 4), "shoeColour4_r", "shoeColour4_g", "shoeColour4_b"),
	var_0_7(native.Localise("Player_Appearance_SocksHeight"), "sockHeight", {
		optionMap = "sockHeight"
	})
}
local var_0_64 = {}

if PLATFORM_PC then
	function AttachCustomFaceCallBack(arg_30_0, arg_30_1, arg_30_2, arg_30_3, arg_30_4, arg_30_5, arg_30_6)
		local var_30_0 = arg_30_4:fileDialogGetData()
		local var_30_1 = true

		if var_30_0 then
			if #var_30_0 <= 0 then
				return
			end

			local var_30_2 = arg_30_0:getImageStore():importImage(var_30_0, native.EImageType.Playface)

			if var_30_2:isValid() then
				local var_30_3 = arg_30_6:getCurrentConfig()

				var_30_3:setOption("ugcHead", 1)
				var_30_3:setOption("headUuid", var_30_2)

				var_30_1 = false

				arg_30_6.setDirty()
				arg_30_6.justCommittedToAChange()

				;(arg_30_6.player or arg_30_6.referee).sharing.hasUnsharedModifications = true

				arg_30_4:playerModelUpdate(1, {
					refresh = true
				})
			end
		end

		if var_30_1 then
			arg_30_4:blockingAlert(arg_30_0, arg_30_1, {
				options = "ok",
				canCancel = false,
				text = native.Localise("Player_Appearance_CouldNotImportPlayface")
			})
		end
	end

	table.insert(var_0_64, 1, var_0_13("AttachCustomFace", {
		onActivate = function(arg_31_0, arg_31_1, arg_31_2, arg_31_3, arg_31_4, arg_31_5, arg_31_6)
			arg_31_4.showFileDialog("JPEG Images\x00*.jpg;*.jpeg\x00PNG Images\x00*.png\x00All\x00*.*\x00", false, "AttachCustomFace")

			return true
		end
	}))
	table.insert(var_0_64, 2, var_0_13("RemoveCustomFace", {
		onActivate = function(arg_32_0, arg_32_1, arg_32_2, arg_32_3, arg_32_4, arg_32_5, arg_32_6)
			local var_32_0 = arg_32_6:getCurrentConfig()

			var_32_0:setOption("headUuid", native.CUuidGenerator.invalidID())

			;(arg_32_6.player or arg_32_6.referee).sharing.hasUnsharedModifications = true

			var_32_0:setOption("ugcHead", 0)
			arg_32_6.setDirty()
			arg_32_6.justCommittedToAChange()
			arg_32_4:playerModelUpdate(1, {
				refresh = true
			})

			return true
		end
	}))
end

local var_0_65 = tablex.iconcatn(var_0_34, var_0_64)
local var_0_66 = var_0_1("Body", "app_body", false, {
	var_0_3("BodyGroupTab", "icon_body", playermodel_camera_aide.FullBody_NotRelativeToPlayerHeight, var_0_30)
})
local var_0_67 = var_0_1("Skin", "app_skin", false, {
	var_0_3("SkinGroupTab", "icon_skin", playermodel_camera_aide.FullBody_NotRelativeToPlayerHeight, var_0_65)
})
local var_0_68 = var_0_1("Head", "app_head", false, {
	var_0_3("HeadGroupTab", "icon_skull", playermodel_camera_aide.HeadAndShoulders, var_0_35),
	var_0_3("HeadGroupTab2", "icon_skull", playermodel_camera_aide.HeadAndShoulders, var_0_36),
	var_0_3("NoseGroupTab", "icon_nose", playermodel_camera_aide.HeadAndShoulders, var_0_37),
	var_0_3("EyesGroupTab", "icon_eye", playermodel_camera_aide.HeadAndShoulders, var_0_38),
	var_0_3("EarsGroupTab", "icon_ear", playermodel_camera_aide.HeadAndShoulders, var_0_39),
	var_0_3("MouthGroupTab", "icon_mouth", playermodel_camera_aide.HeadAndShoulders, var_0_40)
})
local var_0_69 = var_0_1("Hair", "app_hair", false, {
	var_0_3("Hair", "icon_hair", playermodel_camera_aide.HeadAndShoulders, var_0_41),
	var_0_3("Beard", "icon_beard", playermodel_camera_aide.HeadAndShoulders, var_0_47),
	var_0_3("EyeBrows", "icon_brow", playermodel_camera_aide.HeadAndShoulders, var_0_50)
})
local var_0_70 = var_0_1("Hair", "app_hair_w", false, {
	var_0_3("Hair", "icon_hair_female", playermodel_camera_aide.HeadAndShoulders, var_0_41),
	var_0_3("EyeBrows", "icon_brow", playermodel_camera_aide.HeadAndShoulders, var_0_50)
})
local var_0_71 = var_0_1("Accessories", "app_strapping", false, {
	var_0_3("SkinsItems", "icon_arm_compression", playermodel_camera_aide.FullBody_NotRelativeToPlayerHeight, var_0_53),
	var_0_3("CompressionItems", "icon_shorts_compression", playermodel_camera_aide.FullBody_NotRelativeToPlayerHeight, var_0_54),
	var_0_3("ArmStrappingItems", "icon_arm_strapping", playermodel_camera_aide.FullBody_NotRelativeToPlayerHeight, var_0_55),
	var_0_3("FingerStrappingItems", "icon_strapping_finger", playermodel_camera_aide.FullBody_NotRelativeToPlayerHeight, var_0_56),
	var_0_3("LegStrappingItems", "icon_leg_strapping", playermodel_camera_aide.FullBody_NotRelativeToPlayerHeight, var_0_57)
})
local var_0_72 = var_0_1("Tattoos", "app_tattoos", false, {
	var_0_3("HeadTattooItems", "icon_tattoo_head", playermodel_camera_aide.FullBody_NotRelativeToPlayerHeight, var_0_58),
	var_0_3("BodyTattoosItems", "icon_tattoo_body", playermodel_camera_aide.FullBody_NotRelativeToPlayerHeight, var_0_59),
	var_0_3("LegTattoosItems", "icon_tattoo_leg", playermodel_camera_aide.FullBody_NotRelativeToPlayerHeight, var_0_60)
})
local var_0_73 = var_0_1("Accessories", "app_accessories", false, {
	var_0_3("Headwear", "icon_helmet", playermodel_camera_aide.FullBody_NotRelativeToPlayerHeight, var_0_62),
	var_0_3("Feet", "icon_boots", playermodel_camera_aide.Boots, var_0_63)
})
local var_0_74 = var_0_1("Head", "app_head", false, {
	var_0_3("Hair", "icon_hair", playermodel_camera_aide.HeadAndShoulders, var_0_45),
	var_0_3("Hair", "icon_beard", playermodel_camera_aide.HeadAndShoulders, var_0_48)
})
local var_0_75 = var_0_1("Head", "app_head", false, {
	var_0_3("Hair", "icon_hair", playermodel_camera_aide.HeadAndShoulders, var_0_45)
})
local var_0_76 = var_0_1("Body", "app_body", false, {
	var_0_3("BodyGroupTab", "icon_body", playermodel_camera_aide.FullBody_NotRelativeToPlayerHeight, var_0_32)
})
local var_0_77 = var_0_1("Body", "app_body", false, {
	var_0_3("BodyGroupTab", "icon_body", playermodel_camera_aide.FullBody_NotRelativeToPlayerHeight, var_0_33)
})
local var_0_78 = var_0_1("Head", "app_head", false, {
	var_0_52
})

-- unlock-tier1-editing: Body tab for scanned (tier-1) players, without Head Size, Neck Type
-- and Neck (var_0_30[2], [3], [7]), which would reshape the scan or open a seam where
-- the scanned head meets the body.
local var_0_tier1BodySkip = {
	[var_0_30[2]] = true,
	[var_0_30[3]] = true,
	[var_0_30[7]] = true
}
local var_0_tier1Body = {}

for iter_0_0, iter_0_1 in ipairs(var_0_30) do
	if not var_0_tier1BodySkip[iter_0_1] then
		table.insert(var_0_tier1Body, iter_0_1)
	end
end

local var_0_tier1BodyGroup = var_0_1("Body", "app_body", false, {
	var_0_3("BodyGroupTab", "icon_body", playermodel_camera_aide.FullBody_NotRelativeToPlayerHeight, var_0_tier1Body)
})

GroupList = {
	var_0_66,
	var_0_67,
	var_0_68,
	var_0_69,
	var_0_71,
	var_0_72,
	var_0_73
}
DebugGroupListMale = {
	var_0_74,
	var_0_76,
	var_0_66,
	var_0_67,
	var_0_68,
	var_0_69,
	var_0_71,
	var_0_72,
	var_0_73
}
DebugGroupListFemale = {
	var_0_75,
	var_0_77,
	var_0_66,
	var_0_67,
	var_0_68,
	var_0_69,
	var_0_71,
	var_0_72,
	var_0_73
}
FemaleGroupList = {
	var_0_66,
	var_0_67,
	var_0_68,
	var_0_70,
	var_0_71,
	var_0_72,
	var_0_73
}
-- unlock-tier1-editing: scanned players get no Head (face morphs), Hair (the scan's own
-- hair meshes) or Skin (the face texture is baked) tabs. Strapping, compression,
-- tattoos (neck, arms, legs), headgear and boots stay editable.
Tier1GroupList = {
	var_0_tier1BodyGroup,
	var_0_71,
	var_0_72,
	var_0_73
}
Tier1FemaleGroupList = Tier1GroupList
CoachGroupList = {}
RefereeGroupList = {
	var_0_66,
	var_0_67,
	var_0_68,
	var_0_69,
	var_0_71,
	var_0_72,
	var_0_73
}
FemaleRefereeGroupList = {
	var_0_66,
	var_0_67,
	var_0_68,
	var_0_70,
	var_0_71,
	var_0_72,
	var_0_73
}
