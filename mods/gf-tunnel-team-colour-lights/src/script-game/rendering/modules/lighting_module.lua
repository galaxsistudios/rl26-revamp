import("core.foundation.func")
import("core.foundation.tablex")
import("intermediatelua.lighting.clut")

local var_0_0 = load("intermediatelua.visualconfig.stadium-cfg")
local var_0_1 = load("intermediatelua.lighting.list")

Class("LightingModule", function(arg_1_0)
	arg_1_0.lightingScene = nil
	arg_1_0.lightingScenes = nil
	arg_1_0.lightingList = nil
	arg_1_0.groundName = nil
	arg_1_0.dynamicEnvironment = nil
	arg_1_0.currentLightingSceneName = nil
	arg_1_0.currentLightingScene = nil
	arg_1_0.stadiumCfg = nil
end)

-- GF walkout tunnel scenes whose coloured lights take the walking side's club
-- colours. Stock colours: nrl_01 lime (131,255,0), qld maroon, blues cyan.
local TunnelLightScenes = {
	cs_corridor_nrl_01 = true,
	cs_corridor_nrl_qld_01 = true,
	cs_corridor_nrl_blues_01 = true
}

-- Odd-numbered lights (up_01, floor_left_01/floor_right_01, ...) get the
-- primary colour and even-numbered ones the secondary, so the floor pairs form
-- alternating bands down the tunnel. false = primary everywhere.
local AlternateColours = true

-- Scale each colour so its brightest channel is 255, like the stock lime.
-- Keeps dark club colours (navy, maroon) from making the tunnel dim.
local NormaliseBrightness = true

-- A colour whose brightest channel is below this (e.g. black) is unusable as
-- a light; the other club colour is used instead.
local MinUsableChannel = 24

local function tunnelLightColour(arg_rgb)
	if not arg_rgb then
		return nil
	end

	local r, g, b = arg_rgb[1] or 0, arg_rgb[2] or 0, arg_rgb[3] or 0
	local maxChannel = math.max(r, g, b)

	if maxChannel < MinUsableChannel then
		return nil
	end

	if NormaliseBrightness then
		local scale = 255 / maxChannel

		r, g, b = r * scale, g * scale, b * scale
	end

	return native.Colour(math.floor(r + 0.5), math.floor(g + 0.5), math.floor(b + 0.5))
end

local function tunnelSideColours(arg_cutsceneName)
	local colours = _G.GFTunnelTeamColours

	if not colours or type(arg_cutsceneName) ~= "string" then
		return nil
	end

	local name = arg_cutsceneName:lower()
	local side

	if name:find("intro_gf_home_team", 1, true) then
		side = colours.home
	elseif name:find("intro_gf_away_team", 1, true) then
		side = colours.away
	end

	if not side then
		return nil
	end

	local primary = tunnelLightColour(side.primary)
	local secondary = tunnelLightColour(side.secondary)

	primary = primary or secondary
	secondary = secondary or primary

	if not primary then
		return nil
	end

	return primary, AlternateColours and secondary or primary
end

local function recolourTunnelLights(arg_lights, arg_primary, arg_secondary)
	for _, light in ipairs(arg_lights) do
		local data = light.data

		if data then
			local lightName = data.name or ""
			local number = lightName:match("^up_(%d+)$") or lightName:match("^floor_%a+_(%d+)$")

			if number and data.colour then
				data.colour = tonumber(number) % 2 == 1 and arg_primary or arg_secondary
			end

			if data.children then
				recolourTunnelLights(data.children, arg_primary, arg_secondary)
			end
		end
	end
end

local function var_0_2(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4)
	arg_2_3 = arg_2_3 or native.vec3.Zero()
	arg_2_4 = arg_2_4 or native.vec3.Zero()

	for iter_2_0, iter_2_1 in ipairs(arg_2_1) do
		local var_2_0 = "intermediatelua.lighting." .. iter_2_1
		local var_2_1 = load(var_2_0)

		if TunnelLightScenes[iter_2_1] then
			pcall(function()
				local primary, secondary = tunnelSideColours(arg_2_2)

				if primary then
					recolourTunnelLights(var_2_1.lighting2, primary, secondary)
				end
			end)
		end

		arg_2_0:import(var_2_1.lighting2, arg_2_2, var_2_0, arg_2_3, arg_2_4)
		_G.unloadPackage(var_2_0)
	end
end

function LightingModule.loadLightingScene(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4)
	local var_3_0 = VERIFY(arg_3_0.currentLightingScene)
	local var_3_1 = VERIFY(arg_3_0.currentLightingSceneName)

	var_0_2(var_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4)

	local var_3_2 = VERIFY(arg_3_0.lightingList[var_3_1])

	for iter_3_0, iter_3_1 in ipairs(arg_3_1) do
		table.insert(var_3_2, iter_3_1)
	end
end

function LightingModule.unloadLightingScene(arg_4_0, arg_4_1)
	local var_4_0 = VERIFY(arg_4_0.currentLightingScene)
	local var_4_1 = VERIFY(arg_4_0.currentLightingSceneName)

	var_4_0:removeLayer(arg_4_1)

	local var_4_2 = VERIFY(arg_4_0.lightingList[var_4_1])
	local var_4_3

	for iter_4_0, iter_4_1 in ipairs(var_4_2) do
		if iter_4_1 == arg_4_1 then
			var_4_3 = iter_4_0

			break
		end
	end

	ASSERT(var_4_3)
	table.remove(var_4_2, var_4_3)
end

local function var_0_3(arg_5_0, arg_5_1)
	local var_5_0 = arg_5_0:getTextureManager()
	local var_5_1 = PLATFORM_SWITCH and {
		var_0_1.selection[arg_5_1][1]
	} or var_0_1.selection[arg_5_1]
	local var_5_2 = {
		default = tablex.clone(var_5_1),
		creatorRoofClosed = {
			"creatorRoofClosed"
		},
		trophy = {
			"rla_trophy"
		},
		corridor = {
			"corridor"
		}
	}

	return func.map(function(arg_6_0, arg_6_1)
		local var_6_0 = native.CLightingScene(var_5_0)

		var_0_2(var_6_0, arg_6_1, arg_5_1)

		return arg_6_0, var_6_0
	end, pairs(var_5_2)), var_5_2
end

function LightingModule.load(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7)
	local var_7_0 = var_0_0.Stadiums[arg_7_3]
	local var_7_1 = arg_7_1:getTextureManager()

	arg_7_0.groundName = arg_7_3
	arg_7_0.stadiumCfg = var_7_0
	arg_7_0.lightingScenes, arg_7_0.lightingList = var_0_3(arg_7_1, arg_7_3)

	arg_7_0:setLightingScene("default")

	local var_7_2 = native.CDynamicEnvironment()
	local var_7_3 = VERIFY(var_7_0.dynamicenv_lighting, string.format("Missing dynamicenv_lighting in stadium %s", arg_7_3))

	ASSERT(var_7_3)

	local var_7_4 = load("intermediatelua.visualconfig." .. var_7_3).BaseLightingValues
	local var_7_5 = load("intermediatelua.visualconfig.dynamicenv_weather").BaseRainValues

	var_7_2:init(arg_7_4, arg_7_5, arg_7_6, arg_7_7, var_7_4, var_7_5, var_7_1, clut.Clut, arg_7_2.skyRenderer)

	var_7_2.alwaysUpdate = native.getEnvironment():argExists("editorBeta")

	var_7_2:pokeTonemapper()

	arg_7_0.dynamicEnvironment = var_7_2
	arg_7_0.lightingScenes.default.dynamicEnvironment = var_7_2
end

function LightingModule.reloadLightingScene(arg_8_0, arg_8_1)
	local var_8_0 = arg_8_0.groundName
	local var_8_1 = arg_8_0.currentLightingSceneName
	local var_8_2 = tablex.clone(VERIFY(arg_8_0.lightingList[var_8_1]))

	for iter_8_0, iter_8_1 in ipairs(var_8_2) do
		arg_8_0:unloadLightingScene(iter_8_1)
	end

	arg_8_0:loadLightingScene(var_8_2, var_8_0)
	arg_8_0.dynamicEnvironment:onPostWipe()
end

function LightingModule.setLightingScene(arg_9_0, arg_9_1)
	ASSERT(arg_9_0.lightingScenes)

	local var_9_0 = arg_9_0.currentLightingScene
	local var_9_1 = VERIFY(arg_9_0.lightingScenes[arg_9_1])

	arg_9_0.currentLightingSceneName = arg_9_1
	arg_9_0.currentLightingScene = var_9_1

	return var_9_0, var_9_1
end

function LightingModule.dispose(arg_10_0)
	arg_10_0.dynamicEnvironment:dispose()

	arg_10_0.lightingScenes.default.dynamicEnvironment = nil

	for iter_10_0, iter_10_1 in pairs(arg_10_0.lightingScenes) do
		iter_10_1:dispose()
	end
end

function LightingModule.isLoaded(arg_11_0)
	return true
end

function LightingModule.update(arg_12_0, arg_12_1)
	VERIFY(arg_12_0.currentLightingScene):update(arg_12_1)
end
