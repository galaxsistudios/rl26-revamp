function bindLinearColourHDR(arg_1_0, arg_1_1, arg_1_2)
	arg_1_0:bindGetSetClosures(arg_1_1, function()
		local var_2_0 = native.getShaderGlobalVec3(arg_1_1)

		return arg_1_2 and arg_1_2.get(var_2_0) or var_2_0
	end, function(arg_3_0)
		local var_3_0 = arg_1_2 and arg_1_2.set(arg_3_0) or arg_3_0

		native.setShaderGlobalVec3(arg_1_1, var_3_0)
	end, {
		editor = "hdrcolour"
	})
end

function bindLinearColour(arg_4_0, arg_4_1, arg_4_2)
	arg_4_0:bindGetSetClosures(arg_4_1, function()
		local var_5_0 = native.getShaderGlobalVec3(arg_4_1)

		return arg_4_2 and arg_4_2.get(var_5_0) or var_5_0
	end, function(arg_6_0)
		local var_6_0 = arg_4_2 and arg_4_2.set(arg_6_0) or arg_6_0

		native.setShaderGlobalVec3(arg_4_1, var_6_0)
	end, {
		editor = "colour"
	})
end

function bindColourSRGB(arg_7_0, arg_7_1, arg_7_2)
	arg_7_0:bindGetSetClosures(arg_7_1, function()
		local var_8_0 = native.getShaderGlobalSRGB(arg_7_1)

		return arg_7_2 and arg_7_2.get(var_8_0) or var_8_0
	end, function(arg_9_0)
		local var_9_0 = arg_7_2 and arg_7_2.set(arg_9_0) or arg_9_0

		native.setShaderGlobalSRGB(arg_7_1, var_9_0)
	end, {
		editor = "colour"
	})
end

function bindSlider(arg_10_0, arg_10_1, arg_10_2, arg_10_3, arg_10_4)
	arg_10_0:bindGetSetClosures(arg_10_1, function()
		local var_11_0 = native.getShaderGlobalFloat(arg_10_1)

		return arg_10_4 and arg_10_4.get(var_11_0) or var_11_0
	end, function(arg_12_0)
		local var_12_0 = arg_10_4 and arg_10_4.set(arg_12_0) or arg_12_0

		native.setShaderGlobalFloat(arg_10_1, var_12_0)
	end, {
		editor = "slider",
		minimum = arg_10_2 or 0,
		maximum = arg_10_3 or 1
	})
end

-- suncorp-roof-lights: this stock file is never imported by the game, so it
-- hosts the roof light code. The hooks:
--   rendering/modules/stadium_module.lua (realistic-pitch-grass) calls
--     setRoofLightsMatch at stadium load and clearRoofLights at dispose;
--   rendering/modules/lighting_module.lua (gf-tunnel-team-colour-lights) calls
--     recolourRoofLights on every lighting file before it is imported, and
--     tickRoofLights every frame.
-- With this mod off the file is stock and the hooks find no functions.
--
-- Suncorp's red band under the roof's front edges is the "RoofLights" group of
-- intermediatelua/lighting/background_brisbane_01.lua: four CPlanarLights
-- (one per side / end, colour 255,66,59) at ~34 m. Each is split into
-- segments of about ROOF_LIGHTS_SEGMENT_M along its width, alternating r b r b
-- in turn. The floodlight glows (shader global glow_stadium_colour01, white
-- in stock) crossfade between the scheme's two colours.
-- Colours are sRGB 0-255.
ROOF_LIGHTS_GROUNDS = {
	brisbane = {
		file = "background_brisbane_01",
		group = "RoofLights",
		-- the group's children in file order: centre, and the width axis
		-- (the light's local x after its rotation)
		lights = {
			{ pos = { -1.5887941122055, 34.346729278564, -61.026908874512 }, axis = { 1, 0, 0 } },
			{ pos = { -0.3541374206543, 34.768657684326, 63.367252349854 }, axis = { 1, 0, 0 } },
			{ pos = { 91.591995239258, 36.800556182861, 0.05348539352417 }, axis = { 0, 0, -1 } },
			{ pos = { -87.008804321289, 32.702243804932, -0.043967749923468 }, axis = { 0, 0, -1 } }
		}
	}
}
ROOF_LIGHTS_SEGMENT_M = 10
ROOF_LIGHTS_PATTERN = { "r", "b" }
ROOF_LIGHTS_CLUBS = {
	-- segments maroon, gold, maroon, gold ...; glows maroon <-> gold
	broncos = { r = { 118, 1, 53 }, g = { 118, 1, 53 }, b = { 255, 184, 28 }, glow = { { 118, 1, 53 }, { 255, 184, 28 } } },
	-- segments red, gold, red, gold ...; glows red <-> gold
	dolphins = { r = { 226, 35, 26 }, g = { 226, 35, 26 }, b = { 255, 184, 28 }, glow = { { 226, 35, 26 }, { 255, 184, 28 } } }
}
-- Magic Round: segments alternate home / away primary, glows likewise. When
-- the two primaries are this close (sum of channel differences) the away
-- side's secondary is used instead.
ROOF_LIGHTS_SIMILAR = 90
-- A dark colour makes a dim light. Brightness is scaled up by this share of
-- (255 / brightest channel): 0 = as dark as the colour, 1 = as bright as stock.
ROOF_LIGHTS_DARK_BOOST = 0.6
-- Glow crossfade: hold each colour this many seconds, then fade.
ROOF_LIGHTS_GLOW_HOLD = 5
ROOF_LIGHTS_GLOW_FADE = 1.5
ROOF_LIGHTS_GLOW_STOCK = { 1, 1, 1 }

-- Fixed recolours, every match: lighting file (lower case) -> a group of
-- separate lights that take `colours` in turn. `order` lists the children
-- (file order numbers) going round the roof, so neighbours alternate; the
-- group must have exactly that many children or it is left stock.
STADIUM_LIGHT_PATTERNS = {
	-- Queensland Country Bank Stadium: 23 spotlights, one per roof triangle,
	-- stock rainbow -> dark blue / yellow (Cowboys). File order runs from the
	-- end (1) along one side (2-17), then the other side (18-23).
	background_townsvillestadium_01 = {
		group = "ColouredRoofLights",
		order = { 23, 22, 21, 20, 19, 18, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17 },
		colours = { { 0, 120, 255 }, { 255, 196, 0 } }
	}
}

local function roofLightsLog(arg_msg)
	pcall(function()
		local file = io.open("roofLights_debug.txt", "a")

		if file then
			file:write(os.date("%H:%M:%S") .. " " .. arg_msg .. "\n")
			file:close()
		end
	end)
end

local function roofColour(arg_colour)
	if not arg_colour then
		return nil
	end

	local ok, rgb = pcall(function()
		return { arg_colour.r, arg_colour.g, arg_colour.b }
	end)

	if ok and type(rgb[1]) == "number" and type(rgb[2]) == "number" and type(rgb[3]) == "number" then
		return rgb
	end

	return nil
end

local function roofDistance(arg_a, arg_b)
	return math.abs(arg_a[1] - arg_b[1]) + math.abs(arg_a[2] - arg_b[2]) + math.abs(arg_a[3] - arg_b[3])
end

local function isMagicRound(arg_match)
	local ok, hit = pcall(function()
		local season = arg_match.stateOfTheSeason

		if season and season.specialEvent == native.CareerFixtureSpecialEvent.MagicRound then
			return true
		end

		-- Play Now's "Magic Round" field markings (the NRL_Season_Tuesday value)
		local markings = arg_match.matchType and arg_match.matchType.fieldMarkings

		return markings ~= nil and markings == native.MatchSettingsFieldMarkings.NRL_Season_Tuesday
	end)

	return ok and hit == true
end

-- {r, g, b, glow = {a, b}} and a name for the log; nil scheme = stock lights
local function roofLightsScheme(arg_match)
	if not arg_match then
		return nil, "stock (no match data)"
	end

	if isMagicRound(arg_match) then
		local home = roofColour(arg_match.home and arg_match.home.primaryColour)
		local away = roofColour(arg_match.away and arg_match.away.primaryColour)

		if home and away then
			if roofDistance(home, away) < ROOF_LIGHTS_SIMILAR then
				away = roofColour(arg_match.away.secondaryColour) or away
			end

			return { r = home, g = away, b = away, glow = { home, away } }, "magic round"
		end
	end

	local ok, nickname = pcall(function()
		return string.lower(arg_match.home.nickname)
	end)
	local club = ok and ROOF_LIGHTS_CLUBS[nickname]

	if club then
		return club, nickname
	end

	return nil, "stock"
end

local function setGlowColour(arg_rgb)
	return pcall(function()
		native.setShaderGlobalVec3("glow_stadium_colour01", native.vec3(arg_rgb[1], arg_rgb[2], arg_rgb[3]))
	end)
end

-- 0-1 with the brightest channel at 1, so a glow keeps its brightness
local function glowRgb(arg_rgb)
	local top = math.max(arg_rgb[1], arg_rgb[2], arg_rgb[3], 1)

	return { arg_rgb[1] / top, arg_rgb[2] / top, arg_rgb[3] / top }
end

-- Stadium load (before the lighting loads): pick this match's scheme.
function setRoofLightsMatch(arg_groundKey, arg_match)
	local ground = ROOF_LIGHTS_GROUNDS[arg_groundKey]
	local scheme, name

	if ground then
		scheme, name = roofLightsScheme(arg_match)
	end

	_G.RoofLightsState = scheme and {
		ground = ground,
		scheme = scheme,
		glowA = glowRgb(scheme.glow[1]),
		glowB = glowRgb(scheme.glow[2]),
		start = os.clock()
	} or nil

	setGlowColour(_G.RoofLightsState and _G.RoofLightsState.glowA or ROOF_LIGHTS_GLOW_STOCK)

	if ground then
		roofLightsLog(arg_groundKey .. ": " .. tostring(name))
	end
end

-- Stadium dispose: back to stock, so front-end scenes and other grounds
-- never see a match's colours.
function clearRoofLights()
	_G.RoofLightsState = nil

	setGlowColour(ROOF_LIGHTS_GLOW_STOCK)
end

local function findGroup(arg_lights, arg_name)
	for iter_i, iter_light in ipairs(arg_lights or {}) do
		local data = iter_light.data

		if data and data.name == arg_name then
			return data
		end

		local found = data and findGroup(data.children, arg_name)

		if found then
			return found
		end
	end

	return nil
end

local function applyLightPattern(arg_fileName, arg_lighting2)
	local pattern = type(arg_fileName) == "string" and STADIUM_LIGHT_PATTERNS[string.lower(arg_fileName)]

	if not pattern then
		return
	end

	local group = findGroup(arg_lighting2, pattern.group)

	if not group or not group.children or #group.children ~= #pattern.order then
		roofLightsLog(pattern.group .. " not as expected in " .. arg_fileName .. " - left stock")

		return
	end

	for iter_k, iter_index in ipairs(pattern.order) do
		local rgb = pattern.colours[(iter_k - 1) % #pattern.colours + 1]

		group.children[iter_index].data.colour = native.Colour(rgb[1], rgb[2], rgb[3])
	end

	roofLightsLog(arg_fileName .. ": " .. #pattern.order .. " " .. pattern.group .. " recoloured")
end

-- Lighting file load: fixed patterns, then this match's roof light segments.
function recolourRoofLights(arg_fileName, arg_lighting2)
	applyLightPattern(arg_fileName, arg_lighting2)

	local state = _G.RoofLightsState

	if not state or arg_fileName ~= state.ground.file then
		return
	end

	local group = findGroup(arg_lighting2, state.ground.group)
	local layout = state.ground.lights

	if not group or not group.children or #group.children ~= #layout then
		roofLightsLog("roof light group not as expected in " .. arg_fileName .. " - left stock")

		return
	end

	local segments = {}
	local slot = 0

	for iter_i, iter_light in ipairs(group.children) do
		local data = iter_light.data
		local spec = layout[iter_i]
		local width = data.width or 0
		local count = math.max(1, math.floor(width / ROOF_LIGHTS_SEGMENT_M + 0.5))
		local step = width / count

		for iter_k = 0, count - 1 do
			local rgb = state.scheme[ROOF_LIGHTS_PATTERN[slot % #ROOF_LIGHTS_PATTERN + 1]]
			local top = math.max(rgb[1], rgb[2], rgb[3], 1)
			local boost = 1 + ROOF_LIGHTS_DARK_BOOST * (255 / top - 1)
			local offset = -width / 2 + (iter_k + 0.5) * step
			local copy = {}

			for iter_key, iter_value in pairs(data) do
				copy[iter_key] = iter_value
			end

			copy.width = step
			copy.brightness = (data.brightness or 1) * boost
			copy.colour = native.Colour(rgb[1], rgb[2], rgb[3])
			copy.position = native.vec3(spec.pos[1] + spec.axis[1] * offset, spec.pos[2] + spec.axis[2] * offset, spec.pos[3] + spec.axis[3] * offset)

			table.insert(segments, {
				class = iter_light.class,
				data = copy
			})

			slot = slot + 1
		end
	end

	group.children = segments

	roofLightsLog(arg_fileName .. ": " .. #segments .. " roof light segments")
end

-- Every frame: crossfade the floodlight glows between the scheme's colours.
function tickRoofLights()
	local state = _G.RoofLightsState

	if not state then
		return
	end

	local period = ROOF_LIGHTS_GLOW_HOLD + ROOF_LIGHTS_GLOW_FADE
	local t = (os.clock() - state.start) % (2 * period)
	local mix

	if t < ROOF_LIGHTS_GLOW_HOLD then
		mix = 0
	elseif t < period then
		mix = (t - ROOF_LIGHTS_GLOW_HOLD) / ROOF_LIGHTS_GLOW_FADE
	elseif t < period + ROOF_LIGHTS_GLOW_HOLD then
		mix = 1
	else
		mix = 1 - (t - period - ROOF_LIGHTS_GLOW_HOLD) / ROOF_LIGHTS_GLOW_FADE
	end

	if state.lastMix == mix then
		return
	end

	state.lastMix = mix

	local a, b = state.glowA, state.glowB

	setGlowColour({ a[1] + (b[1] - a[1]) * mix, a[2] + (b[2] - a[2]) * mix, a[3] + (b[3] - a[3]) * mix })
end
