import("core.foundation.tablex")

local var_0_0 = native.getEnvironment():argExists("settingsForceHdrEdit")

CustomMatchOptions = {
	"ground",
	"isPublicSession"
}

import("script-config.design.sound.soundmap_banks")

local var_0_1 = soundmap_banks.MusicBanks
local var_0_2 = {}

for iter_0_0, iter_0_1 in pairs(var_0_1) do
	table.insert(var_0_2, iter_0_1.name)
end

table.sort(var_0_2)
table.insert(var_0_2, 1, "HeaderMusic")

local var_0_3 = {
	"mastervolume",
	"musicvolume",
	"ingamemusicvolume",
	"uivolume",
	"sfxvolume",
	"commentaryvolume",
	"environmentvolume",
	"crowdvolume",
	"refereevolume",
	"playervocalsvolume"
}
local var_0_4 = native.getPlatformString()

if var_0_4 == "ps4" or var_0_4 == "ps5" then
	table.insert(var_0_3, "controllerAudio")
end

local var_0_5 = {
	"HeaderCamera",
	"gameplayCamera",
	"gameplayCameraEndMode"
}
local var_0_6 = {
	"HeaderCamera",
	"gameplayCamera",
	"gameplayCameraPro",
	"gameplayCameraEndMode"
}
local var_0_7 = {
	"HeaderCamera",
	"gameplayCameraPro",
	"gameplayCameraEndMode"
}
local var_0_8 = {
	"HeaderGameplay",
	"replays",
	"offsideIndicator",
	"classicGameplaySwitching",
	"autoOnside",
	"stickSwitchingRate",
	"gameplayObjectiveNotifications",
	"showOwnTeamFieldNames",
	"showOtherTeamFieldNames",
	"showBallCarrierName",
	"showLineBrokenNames",
	"showCutoutPassNames",
	"fieldNameSurname",
	"fieldNamePosition",
	"fieldNameNumber"
}

if PLATFORM_PC then
	table.insert(var_0_8, "voiceChatEnabled")
end

local var_0_9 = {
	"HeaderGameplay",
	"replays",
	"offsideIndicator",
	"classicGameplaySwitching",
	"autoOnside",
	"stickSwitchingRate",
	"gameplayObjectiveNotifications",
	"skipToProNotifications",
	"showOwnTeamFieldNames",
	"showOtherTeamFieldNames",
	"showBallCarrierName",
	"showLineBrokenNames",
	"showCutoutPassNames",
	"fieldNameSurname",
	"fieldNamePosition",
	"fieldNameNumber"
}
local var_0_10 = {
	"HeaderOnline",
	"remotePlayerInfo"
}
local var_0_11 = {
	"HeaderOnline",
	"remotePlayerInfo"
}
local var_0_12 = {
	"HeaderController",
	"InGameControllerHelp",
	"controllerVibration"
}
local var_0_13 = {
	"HeaderController",
	"controllerVibration"
}
local var_0_14 = {
	"skipToProNotifications"
}

if not PLATFORM_SWITCH_ANY then
	table.insert(var_0_14, "enableCrossPlay")
end

function createGraphicsOptions(arg_1_0)
	local var_1_0 = {
		"HeaderGraphics",
		"monitor",
		"resolution",
		"characters",
		"shadows",
		"shadowContactHardening",
		"shadowSmoothing",
		"antialiasing",
		"dof",
		"bloom",
		"lightFlares",
		"crowdCapacity",
		"crowdVariance", -- crowd-fangear (settings_generalstate_graphics.lua)
		"grass",
		"ao",
		"fullscreen",
		"vsync",
		"fpsCap"
	}
	local var_1_1 = {
		"HeaderGraphics"
	}

	if not native.publicfacing and not PLATFORM_SWITCH_ANY then
		local var_1_2 = "autoletterboxing"

		table.insert(var_1_0, var_1_2)
		table.insert(var_1_1, var_1_2)
	end

	if arg_1_0:getGraphicsSettings().isHDR or var_0_0 then
		local var_1_3 = "hdrSettings"

		table.insert(var_1_0, var_1_3)
		table.insert(var_1_1, var_1_3)
	else
		local var_1_4 = "gamma"

		table.insert(var_1_0, var_1_4)
		table.insert(var_1_1, var_1_4)
	end

	if PLATFORM_PS4 or PLATFORM_XBONE then
		var_1_1 = {
			"HeaderGraphics",
			"gamma"
		}
	end

	return native.CGraphicsSettings.isAllowedToMakeChanges() and var_1_0 or var_1_1
end

function createFrontendOptions(arg_2_0)
	local var_2_0 = {}

	tablex.iconcatInto(var_2_0, createGraphicsOptions(arg_2_0))
	tablex.iconcatInto(var_2_0, var_0_8)
	tablex.iconcatInto(var_2_0, var_0_14)
	tablex.iconcatInto(var_2_0, var_0_11)
	tablex.iconcatInto(var_2_0, var_0_6)
	tablex.iconcatInto(var_2_0, var_0_13)

	return var_2_0
end

FrontendAudioOptions = {}

tablex.iconcatInto(FrontendAudioOptions, var_0_3)
tablex.iconcatInto(FrontendAudioOptions, var_0_2)

function createStandaloneOptions(arg_3_0)
	local var_3_0 = {}

	tablex.iconcatInto(var_3_0, createGraphicsOptions(arg_3_0))

	return var_3_0
end

StandaloneAudioOptions = {
	"mastervolume",
	"musicvolume",
	"uivolume"
}

tablex.iconcatInto(StandaloneAudioOptions, var_0_2)

InGameMatchOptions = {}

tablex.iconcatAllInto(InGameMatchOptions, {
	var_0_12,
	var_0_8,
	var_0_10,
	var_0_5,
	var_0_3
})

InGameMatchOptionsPro = {}

tablex.iconcatAllInto(InGameMatchOptionsPro, {
	var_0_12,
	var_0_9,
	var_0_10,
	var_0_7,
	var_0_3
})

InGameMatchOptionsNotOnline = {
	{
		value = "automaticInterchanges",
		index = tablex.indexOf(InGameMatchOptions, "gameplayObjectiveNotifications")
	},
	{
		value = "matchInfoGameMatchDiffculty",
		index = tablex.indexOf(InGameMatchOptions, "gameplayObjectiveNotifications") + 1
	}
}
InGameMatchOptionsIndoorStadia = {
	{
		value = "gameplayCameraIndoor",
		index = tablex.indexOf(InGameMatchOptions, "gameplayCamera")
	}
}
InGameMatchOptionsNonPrimaryMember = {
	"HeaderController",
	"InGameControllerHelp",
	"controllerVibration",
	"HeaderGameplay",
	"classicGameplaySwitching",
	"autoOnside",
	"stickSwitchingRate"
}
InGameDrillOptions = {
	"HeaderAudio",
	"mastervolume",
	"musicvolume",
	"uivolume",
	"sfxvolume"
}

tablex.iconcatInto(InGameDrillOptions, var_0_12)
tablex.iconcatInto(InGameDrillOptions, var_0_5)
