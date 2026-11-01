import("core.foundation.tablex")
import("base.ui.optionmenu.optionmenu_aide")
import("app.settings.settings_generalstate_graphics_gamma")
import("app.settings.settings_generalstate_graphics_hdr")
import("app.gameplay.gameplaypaused_uistate_hub_settings_graphics_gamma")

local var_0_0 = native.getEnvironment():argExists("settingsForceHdrEdit")
local var_0_1 = {
	vsync = function(arg_1_0)
		return arg_1_0.graphicsSettings.vsync == native.EGraphicsSettingsVSync.Enabled and true or false
	end,
	autoletterboxing = function(arg_2_0)
		return arg_2_0.graphicsSettings.autoletterboxing == 1 and true or false
	end
}
local var_0_2 = {
	resolution = function(arg_3_0, arg_3_1)
		arg_3_1.graphicsSettings:setResolution(arg_3_0, nil)

		arg_3_1.restartMsgWanted.resolution = true
		arg_3_1.graphicsDirty = true

		arg_3_1.setDirty()
	end,
	fullscreen = function(arg_4_0, arg_4_1)
		arg_4_1.restartMsgWanted.fullscreen = true
		arg_4_1.graphicsSettings.fullscreen = arg_4_0
		arg_4_1.graphicsDirty = true

		arg_4_1.setDirty()
	end,
	autoletterboxing = function(arg_5_0, arg_5_1)
		arg_5_1.restartMsgWanted.autoletterboxing = true
		arg_5_1.graphicsSettings.autoletterboxing = arg_5_0 and 1 or 0
		arg_5_1.graphicsDirty = true

		arg_5_1.setDirty()
	end,
	vsync = function(arg_6_0, arg_6_1)
		arg_6_1.restartMsgWanted.vsync = true
		arg_6_1.graphicsSettings.vsync = arg_6_0
		arg_6_1.graphicsDirty = true

		arg_6_1.setDirty()
	end
}

if PLATFORM_PC then
	function var_0_2.characters(arg_7_0, arg_7_1)
		arg_7_1.graphicsSettings.characters = arg_7_0
		arg_7_1.graphicsSettings.frontendCharacters = native.EGraphicsSettingsCharacters[math.min(arg_7_0:toInt() + 1, native.EGraphicsSettingsCharacters.Count) - 1]
		arg_7_1.graphicsDirty = true

		arg_7_1.setDirty()
	end

	function var_0_2.monitor(arg_8_0, arg_8_1)
		arg_8_1.graphicsSettings.monitor = arg_8_0
		arg_8_1.restartMsgWanted.monitor = true
		arg_8_1.graphicsDirty = true

		arg_8_1.setDirty()
	end

	function var_0_2.fpsCap(arg_9_0, arg_9_1)
		arg_9_1.restartMsgWanted.fpsCap = true
		arg_9_1.graphicsSettings.fpsCap = arg_9_0
		arg_9_1.graphicsSettings.vsync = native.EGraphicsSettingsVSync.Disabled
		arg_9_1.graphicsDirty = true

		arg_9_1.setDirty()
	end
end

local function var_0_3(arg_10_0, arg_10_1, arg_10_2)
	return {
		editable = true,
		label = native.Localise(string.format("GraphicsSetting_%s", string.upper(arg_10_0))),
		getValue = function(arg_11_0)
			return arg_11_0.graphicsSettings[arg_10_0]
		end,
		setValue = var_0_2[arg_10_0] or function(arg_12_0, arg_12_1, arg_12_2)
			arg_12_1.graphicsSettings[arg_10_0] = arg_12_0
			arg_12_1.graphicsDirty = true

			arg_12_1.setDirty()
		end,
		displayType = optionmenu_aide.DisplayTypes.ValueList,
		valueList = arg_10_1,
		editType = optionmenu_aide.EditTypes.ValueList,
		tooltip = native.InputTypes.LJoyLeftRight,
		tooltipText = native.Localise("Select"),
		reCreateMenuItems = arg_10_2
	}
end

local function var_0_4(arg_13_0, arg_13_1, arg_13_2)
	return {
		editable = true,
		editWrapAround = false,
		editAdjustByMod = 0.00392156862745098,
		optionMenuFnKey = "addSlider",
		min = 0,
		max = 1,
		label = native.Localise(arg_13_0),
		defaultVal = assert(arg_13_2),
		getValue = function(arg_14_0)
			return arg_14_0.graphicsSettings[arg_13_1]
		end,
		setValue = function(arg_15_0, arg_15_1)
			arg_15_1.graphicsSettings[arg_13_1] = arg_15_0
			arg_15_1.graphicsDirty = true

			arg_15_1.setDirty()
		end,
		editType = optionmenu_aide.EditTypes.Slider,
		displayType = optionmenu_aide.DisplayTypes.Slider,
		tooltip = native.InputTypes.LJoyLeftRight,
		tooltipText = native.Localise("Select")
	}
end

local function var_0_5(arg_16_0, arg_16_1, arg_16_2)
	return {
		editable = true,
		label = native.Localise(string.format("GraphicsSetting_%s", string.upper(arg_16_0))),
		getValue = var_0_1[arg_16_0] or function(arg_17_0)
			return arg_17_0.graphicsSettings[arg_16_0] == 1
		end,
		setValue = var_0_2[arg_16_0] or function(arg_18_0, arg_18_1)
			arg_18_1.graphicsSettings[arg_16_0] = arg_18_0 and 1 or 0
			arg_18_1.graphicsDirty = true

			arg_18_1.setDirty()
		end,
		displayType = optionmenu_aide.DisplayTypes.Toggle,
		valueList = arg_16_1,
		editType = optionmenu_aide.EditTypes.Toggle,
		reCreateMenuItems = arg_16_2
	}
end

local var_0_6 = {
	{
		value = 1,
		label = native.Localise("GraphicsSetting_Option_Enabled")
	},
	{
		value = 0,
		label = native.Localise("GraphicsSetting_Option_Disabled")
	}
}
local var_0_7 = {
	{
		value = 0,
		label = native.Localise("SettingValue_Disabled")
	},
	{
		value = 1,
		label = native.Localise("SettingValue_Enabled")
	}
}
local var_0_8 = var_0_3("monitor", tablex.icreate(native.CGraphicsSettings:numberOfMonitors(), function(arg_19_0)
	return {
		value = arg_19_0 - 1,
		label = arg_19_0
	}
end))
local var_0_9 = var_0_3("sky", {
	{
		value = native.EGraphicsSettingsSky.LowQuality,
		label = native.Localise("SettingValue_LowQuality")
	},
	{
		value = native.EGraphicsSettingsSky.MediumQuality,
		label = native.Localise("SettingValue_MediumQuality")
	},
	{
		value = native.EGraphicsSettingsSky.HighQuality,
		label = native.Localise("SettingValue_HighQuality")
	}
})
local var_0_10 = var_0_3("resolution", tablex.icreate(native.CGraphicsSettings.getAvailableResolutionCount(), function(arg_20_0)
	local var_20_0 = native.CGraphicsSettings.getAvailableResolution(arg_20_0)

	return {
		value = var_20_0,
		label = var_20_0.display
	}
end))
local var_0_11 = var_0_3("characters", {
	{
		value = native.EGraphicsSettingsCharacters.Low,
		label = native.Localise("SettingValue_LowQuality")
	},
	{
		value = native.EGraphicsSettingsCharacters.Medium,
		label = native.Localise("SettingValue_MediumQuality")
	},
	{
		value = native.EGraphicsSettingsCharacters.High,
		label = native.Localise("SettingValue_HighQuality")
	},
	{
		value = native.EGraphicsSettingsCharacters.Highest,
		label = native.Localise("SettingValue_VeryHighQuality")
	}
})
local var_0_12 = {
	editable = true,
	label = native.Localise("Gamma"),
	displayType = optionmenu_aide.DisplayTypes.LabelOnly,
	editType = optionmenu_aide.EditTypes.SubMenu,
	stateFactory = settings_generalstate_graphics_gamma.SettingsGraphicsGammaState
}
local var_0_13 = var_0_3("antialiasing", {
	{
		value = native.EGraphicsSettingsAntialiasing.Disabled,
		label = native.Localise("SettingValue_Disabled")
	},
	{
		value = native.EGraphicsSettingsAntialiasing.Fxaa,
		label = native.Localise("SettingValue_FXAA")
	},
	{
		value = native.EGraphicsSettingsAntialiasing.Taa,
		label = native.Localise("SettingValue_TAA")
	}
})
local var_0_14 = var_0_3("bloom", {
	{
		value = native.EGraphicsSettingsBloom.Disabled,
		label = native.Localise("SettingValue_Disabled")
	},
	{
		value = native.EGraphicsSettingsBloom.LowQuality,
		label = native.Localise("SettingValue_LowQuality")
	},
	{
		value = native.EGraphicsSettingsBloom.HighQuality,
		label = native.Localise("SettingValue_HighQuality")
	}
}, true)
local var_0_15 = var_0_3("lightFlares", {
	{
		value = native.EGraphicsSettingsLightFlares.Disabled,
		label = native.Localise("SettingValue_Disabled")
	},
	{
		value = native.EGraphicsSettingsLightFlares.HighQuality,
		label = native.Localise("SettingValue_HighQuality")
	}
})
local var_0_16 = var_0_3("lightFlares", {
	{
		value = native.EGraphicsSettingsLightFlares.Disabled,
		label = native.Localise("SettingValue_Disabled")
	},
	{
		value = native.EGraphicsSettingsLightFlares.LowQuality,
		label = native.Localise("SettingValue_LowQualityViaBloom")
	},
	{
		value = native.EGraphicsSettingsLightFlares.HighQuality,
		label = native.Localise("SettingValue_HighQuality")
	}
})
local var_0_17 = var_0_3("shadows", {
	{
		value = native.EShadowQuality.Off,
		label = native.Localise("SettingValue_Disabled")
	},
	{
		value = native.EShadowQuality.Lowest,
		label = native.Localise("SettingValue_VeryLowQuality")
	},
	{
		value = native.EShadowQuality.Low,
		label = native.Localise("SettingValue_LowQuality")
	},
	{
		value = native.EShadowQuality.Medium,
		label = native.Localise("SettingValue_MediumQuality")
	},
	{
		value = native.EShadowQuality.High,
		label = native.Localise("SettingValue_HighQuality")
	},
	{
		value = native.EShadowQuality.Highest,
		label = native.Localise("SettingValue_VeryHighQuality")
	}
})
local var_0_18 = var_0_3("crowdCapacity", {
	{
		value = native.EGraphicsSettingsCrowdCapacity.VeryLow,
		label = native.Localise("SettingValue_VeryLow")
	},
	{
		value = native.EGraphicsSettingsCrowdCapacity.Low,
		label = native.Localise("SettingValue_Low")
	},
	{
		value = native.EGraphicsSettingsCrowdCapacity.Medium,
		label = native.Localise("SettingValue_Medium")
	},
	{
		value = native.EGraphicsSettingsCrowdCapacity.High,
		label = native.Localise("SettingValue_High")
	}
})
local var_0_19 = var_0_3("grass", {
	{
		value = native.EGraphicsSettingsGrass.HighQuality,
		label = native.Localise("SettingValue_High")
	},
	{
		value = native.EGraphicsSettingsGrass.LowQuality,
		label = native.Localise("SettingValue_Low")
	}
})
local var_0_20 = var_0_3("ao", {
	{
		value = native.EGraphicsSettingsAmbientOcclusion.On,
		label = native.Localise("SettingValue_Enabled")
	},
	{
		value = native.EGraphicsSettingsAmbientOcclusion.Sometimes,
		label = native.Localise("SettingValue_CinematicsOnly")
	},
	{
		value = native.EGraphicsSettingsAmbientOcclusion.Off,
		label = native.Localise("SettingValue_Disabled")
	}
})

vsync = var_0_3("vsync", {
	{
		value = native.EGraphicsSettingsVSync.Enabled,
		label = native.Localise("SettingValue_Enabled")
	},
	{
		value = native.EGraphicsSettingsVSync.Disabled,
		label = native.Localise("SettingValue_Disabled")
	}
})

local var_0_21 = var_0_3("dof", {
	{
		value = native.EGraphicsSettingsDOF.Enabled,
		label = native.Localise("SettingValue_Enabled")
	},
	{
		value = native.EGraphicsSettingsDOF.Disabled,
		label = native.Localise("SettingValue_Disabled")
	}
})
local var_0_22 = var_0_3("fullscreen", {
	{
		value = native.EGraphicsSettingsFullscreen.Enabled,
		label = native.Localise("SettingValue_Enabled")
	},
	{
		value = native.EGraphicsSettingsFullscreen.Disabled,
		label = native.Localise("SettingValue_Disabled")
	}
})
local var_0_23 = {
	editable = true,
	label = native.Localise("settings_hdr_edit"),
	disabledGetFn = function(arg_21_0)
		return not (arg_21_0.graphicsSettings.isHDR or var_0_0)
	end,
	displayType = optionmenu_aide.DisplayTypes.LabelOnly,
	editType = optionmenu_aide.EditTypes.SubMenu,
	stateFactory = settings_generalstate_graphics_hdr.SettingsGraphicsHdrState
}
local var_0_24 = var_0_3("lighting", {
	{
		value = native.EGraphicsSettingsLighting.Performance,
		label = native.Localise("SettingValue_LowQuality")
	},
	{
		value = native.EGraphicsSettingsLighting.Quality,
		label = native.Localise("SettingValue_MediumQuality")
	},
	{
		value = native.EGraphicsSettingsLighting.HighQuality,
		label = native.Localise("SettingValue_HighQuality")
	}
})
local var_0_25 = var_0_3("crowdQuality", {
	{
		value = native.EGraphicsSettingsCrowdQuality.VeryLow,
		label = native.Localise("SettingValue_VeryLowQuality")
	},
	{
		value = native.EGraphicsSettingsCrowdQuality.Low,
		label = native.Localise("SettingValue_LowQuality")
	},
	{
		value = native.EGraphicsSettingsCrowdQuality.Medium,
		label = native.Localise("SettingValue_MediumQuality")
	},
	{
		value = native.EGraphicsSettingsCrowdQuality.High,
		label = native.Localise("SettingValue_HighQuality")
	}
})
local var_0_26 = var_0_3("fpsCap", {
	{
		value = 0,
		label = native.Localise("SettingValue_Disabled")
	},
	{
		value = 30,
		label = native.Localise("SettingValue_30")
	},
	{
		value = 60,
		label = native.Localise("SettingValue_60")
	},
	{
		value = 100,
		label = native.Localise("SettingValue_100")
	},
	{
		value = 144,
		label = native.Localise("SettingValue_144")
	},
	{
		value = 240,
		label = native.Localise("SettingValue_240")
	}
})
local var_0_27 = {
	label = native.Localise("GraphicsSetting_Gamma_Label"),
	disabledGetFn = function(arg_22_0)
		return not arg_22_0.graphicsSettings.isHDR
	end,
	displayType = optionmenu_aide.DisplayTypes.LabelOnly,
	editType = optionmenu_aide.EditTypes.SubMenu,
	stateFactory = gameplaypaused_uistate_hub_settings_graphics_gamma.GameplayPausedUIStateSettingsGraphicsGamma
}
local var_0_28 = var_0_5("isHDR", var_0_7)
local var_0_29 = var_0_5("autoletterboxing", var_0_6)
local var_0_30 = var_0_5("shadowSmoothing", var_0_6)
local var_0_31 = var_0_5("shadowContactHardening", var_0_6)
-- crowd-fangear: CROWD VARIANCE, how much clothing variety the crowd gets
-- (crowd-team-kits' crowd_item_config.lua reads it at every match load: low =
-- stock-sized jersey lists and no fan tees, standard = fan tees share the
-- jersey lists, high = jerseys in full plus fan tees as their own top item).
-- Every distinct texture is loaded for the match, so higher needs more video
-- memory. Saved as crowd_variance in rl26_revamp.ini in the game folder (the
-- Revamp's settings file), keeping the file's other lines.
local var_0_cv_file = "rl26_revamp.ini"
local var_0_cv_names = {
	[0] = "low",
	[1] = "standard",
	[2] = "high"
}
local var_0_cv_value

local function var_0_cv_read()
	if var_0_cv_value == nil then
		var_0_cv_value = 1

		pcall(function()
			local file = io.open(var_0_cv_file, "r")

			if file then
				for line in file:lines() do
					local key, value = line:match("^%s*([%w_]+)%s*=%s*([%w_]+)")

					if key and key:lower() == "crowd_variance" then
						for index, name in pairs(var_0_cv_names) do
							if name == value:lower() then
								var_0_cv_value = index
							end
						end
					end
				end

				file:close()
			end
		end)
	end

	return var_0_cv_value
end

local function var_0_cv_write(arg_cv_0)
	pcall(function()
		local lines, found = {}, false
		local file = io.open(var_0_cv_file, "r")

		if file then
			for line in file:lines() do
				local key = line:match("^%s*([%w_]+)%s*=")

				if key and key:lower() == "crowd_variance" then
					line = "crowd_variance = " .. var_0_cv_names[arg_cv_0]
					found = true
				end

				table.insert(lines, line)
			end

			file:close()
		end

		if not found then
			table.insert(lines, "")
			table.insert(lines, "; Crowd variance (Settings > Graphics): low, standard or high. Applies from the")
			table.insert(lines, "; next match; higher loads more crowd clothing textures (video memory).")
			table.insert(lines, "crowd_variance = " .. var_0_cv_names[arg_cv_0])
		end

		file = assert(io.open(var_0_cv_file, "w"))

		file:write(table.concat(lines, "\n"), "\n")
		file:close()
	end)
end

local var_0_cv = {
	editable = true,
	label = "Crowd Variance",
	getValue = function(arg_cv_0)
		return var_0_cv_read()
	end,
	setValue = function(arg_cv_0, arg_cv_1)
		local var_cv_0 = type(arg_cv_0) == "number" and arg_cv_0 or arg_cv_0:toInt()

		if var_0_cv_names[var_cv_0] and var_cv_0 ~= var_0_cv_read() then
			var_0_cv_value = var_cv_0

			var_0_cv_write(var_cv_0)
		end
	end,
	displayType = optionmenu_aide.DisplayTypes.ValueList,
	valueList = {
		{
			value = 0,
			label = native.Localise("SettingValue_Low")
		},
		{
			value = 1,
			label = "Standard"
		},
		{
			value = 2,
			label = native.Localise("SettingValue_High")
		}
	},
	editType = optionmenu_aide.EditTypes.ValueList,
	tooltip = native.InputTypes.LJoyLeftRight,
	tooltipText = native.Localise("Select")
}
local var_0_32 = {
	crowdVariance = var_0_cv,
	resolution = var_0_10,
	characters = var_0_11,
	shadows = var_0_17,
	shadowContactHardening = var_0_31,
	shadowSmoothing = var_0_30,
	antialiasing = var_0_13,
	dof = var_0_21,
	bloom = var_0_14,
	crowdCapacity = var_0_18,
	grass = var_0_19,
	ao = var_0_20,
	fullscreen = var_0_22,
	vsync = vsync,
	autoletterboxing = var_0_29,
	gamma = var_0_12,
	hdrSettings = var_0_23,
	monitor = var_0_8,
	sky = var_0_9,
	lighting = var_0_24,
	hdrIsOn = var_0_28,
	crowdQuality = var_0_25,
	fpsCap = var_0_26,
	gammaGameplay = var_0_27
}

function createItem(arg_23_0, arg_23_1)
	if arg_23_1 == "lightFlares" then
		if arg_23_0.graphicsSettings.bloom == 0 then
			local var_23_0 = var_0_15

			if var_23_0.getValue(arg_23_0) == 1 then
				var_23_0.setValue(0, arg_23_0)
			end

			return var_23_0
		else
			return var_0_16
		end
	end

	return var_0_32[arg_23_1]
end
