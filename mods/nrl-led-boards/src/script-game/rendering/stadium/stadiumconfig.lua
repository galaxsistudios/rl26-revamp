import("core.foundation.tablex")
import("core.foundation.func")
import("core.foundation.deepclone")

local var_0_0 = "intermediatelua.visualconfig.stadium-cfg"
local var_0_1 = "intermediatelua.visualconfig.field-cfg"
local var_0_2 = "intermediatelua.data.boundarysizes"
local var_0_3 = load(var_0_0)
local var_0_4 = load(var_0_2)
local var_0_5 = load(var_0_1)

local function var_0_6(arg_1_0)
	assert(var_0_3.Stadiums)

	local var_1_0 = var_0_3.Stadiums[arg_1_0]

	assert(var_1_0, "Missing config for " .. arg_1_0)
	assert(var_1_0.ModelCfg, "Missing ModelCfg for " .. arg_1_0)

	return tablex.clone(var_1_0)
end

function stadiumExists(arg_2_0)
	return var_0_3.Stadiums[arg_2_0] ~= nil
end

function getLocationEnum(arg_3_0)
	local var_3_0 = var_0_3.Stadiums[arg_3_0]

	return var_3_0 and var_3_0.locationEnum or native.ECities.Melbourne
end

function getStadiumModelCfg(arg_4_0)
	local var_4_0 = var_0_6(arg_4_0)

	assert(type(var_4_0) == "table", "Config was of wrong type(" .. type(var_4_0) .. ") for stadium: " .. arg_4_0)
	assert(var_4_0.ModelCfg, "Missing ModelCfg for " .. arg_4_0)

	return var_4_0.ModelCfg
end

function getStadiumName(arg_5_0, arg_5_1)
	local var_5_0 = arg_5_0.stadium

	return var_5_0 == native.EStadiums.creator and arg_5_1:getNameForLevel(arg_5_0.stadiumId) or native.Stadiums.getDisplayName(var_5_0)
end

function getTimePostfix(arg_6_0)
	assert(var_0_3.TimeCodes)

	local var_6_0 = var_0_3.TimeCodes[arg_6_0]

	if not var_6_0 then
		error("stadium-viusal.lua did not contain a TimeCode for time of day \"" .. arg_6_0 .. "\"")
	end

	return var_6_0
end

function getCutscenePositions(arg_7_0)
	assert(var_0_3.Stadiums)

	return var_0_3.Stadiums[arg_7_0].CutscenePositions or {}
end

function getBoundaryLine(arg_8_0, arg_8_1)
	local var_8_0 = assert(var_0_4.BoundarySizes[arg_8_0])
	local var_8_1 = assert(var_8_0[arg_8_1])

	return native.CEllipse(native.vec2(var_8_1.x, var_8_1.y), var_8_1.width, var_8_1.height)
end

function getFenceLine(arg_9_0, arg_9_1)
	local var_9_0 = assert(var_0_4.BoundarySizes[arg_9_0])
	local var_9_1 = assert(arg_9_1 and var_9_0[arg_9_1] or var_9_0.fence)

	return native.CEllipse(native.vec2(var_9_1.x, var_9_1.y), var_9_1.width, var_9_1.height)
end

-- nrl-led-boards: the LED board (a texture of 2048x128 sponsor rows) for the
-- home club. The tables below are written by mods/nrl-led-boards/install.py
-- lua from config/boards/*/board.json and list only installed textures.
-- BEGIN GENERATED (install.py lua)
LED_BOARD_TIMING = {
	persistTime = 5.0,
	transitionTime = 0.5
}
LED_BOARDS = {
	broncos = { texture = "stadiums/textures/sponsors/lcd/revamp/lcd_revamp_broncos_col.texture", rows = 11 },
	bulldogs = { texture = "stadiums/textures/sponsors/lcd/revamp/lcd_revamp_bulldogs_col.texture", rows = 11 },
	cowboys = { texture = "stadiums/textures/sponsors/lcd/revamp/lcd_revamp_cowboys_col.texture", rows = 11 },
	default = { texture = "stadiums/textures/sponsors/lcd/revamp/lcd_revamp_default_col.texture", rows = 6 },
	dolphins = { texture = "stadiums/textures/sponsors/lcd/revamp/lcd_revamp_dolphins_col.texture", rows = 11 },
	dragons = { texture = "stadiums/textures/sponsors/lcd/revamp/lcd_revamp_dragons_col.texture", rows = 11 },
	eels = { texture = "stadiums/textures/sponsors/lcd/revamp/lcd_revamp_eels_col.texture", rows = 11 },
	finals = { texture = "stadiums/textures/sponsors/lcd/revamp/lcd_revamp_finals_col.texture", rows = 8 },
	grand_final = { texture = "stadiums/textures/sponsors/lcd/revamp/lcd_revamp_grand_final_col.texture", rows = 8 },
	knights = { texture = "stadiums/textures/sponsors/lcd/revamp/lcd_revamp_knights_col.texture", rows = 11 },
	magic_round = { texture = "stadiums/textures/sponsors/lcd/revamp/lcd_revamp_magic_round_col.texture", rows = 7 },
	nrl = { texture = "stadiums/textures/sponsors/lcd/revamp/lcd_revamp_nrl_col.texture", rows = 6 },
	panthers = { texture = "stadiums/textures/sponsors/lcd/revamp/lcd_revamp_panthers_col.texture", rows = 11 },
	rabbitohs = { texture = "stadiums/textures/sponsors/lcd/revamp/lcd_revamp_rabbitohs_col.texture", rows = 11 },
	raiders = { texture = "stadiums/textures/sponsors/lcd/revamp/lcd_revamp_raiders_col.texture", rows = 11 },
	roosters = { texture = "stadiums/textures/sponsors/lcd/revamp/lcd_revamp_roosters_col.texture", rows = 11 },
	sea_eagles = { texture = "stadiums/textures/sponsors/lcd/revamp/lcd_revamp_sea_eagles_col.texture", rows = 11 },
	sharks = { texture = "stadiums/textures/sponsors/lcd/revamp/lcd_revamp_sharks_col.texture", rows = 11 },
	state_of_origin = { texture = "stadiums/textures/sponsors/lcd/revamp/lcd_revamp_state_of_origin_col.texture", rows = 9 },
	storm = { texture = "stadiums/textures/sponsors/lcd/revamp/lcd_revamp_storm_col.texture", rows = 11 },
	titans = { texture = "stadiums/textures/sponsors/lcd/revamp/lcd_revamp_titans_col.texture", rows = 11 },
	vegas = { texture = "stadiums/textures/sponsors/lcd/revamp/lcd_revamp_vegas_col.texture", rows = 7 },
	warriors = { texture = "stadiums/textures/sponsors/lcd/revamp/lcd_revamp_warriors_col.texture", rows = 11 },
	wests_tigers = { texture = "stadiums/textures/sponsors/lcd/revamp/lcd_revamp_wests_tigers_col.texture", rows = 11 },
}
LED_BOARD_CLUBS = {
	["brisbane broncos"] = "broncos",
	["brisbane broncos 2025"] = "broncos",
	["gf brisbane broncos"] = "broncos",
	["canterbury-bankstown bulldogs"] = "bulldogs",
	["canterbury-bankstown bulldogs 2025"] = "bulldogs",
	["north queensland cowboys"] = "cowboys",
	["north queensland cowboys 2025"] = "cowboys",
	["dolphins"] = "dolphins",
	["dolphins 2025"] = "dolphins",
	["st george illawarra dragons"] = "dragons",
	["st george illawarra dragons 2025"] = "dragons",
	["parramatta eels"] = "eels",
	["parramatta eels 2025"] = "eels",
	["newcastle knights"] = "knights",
	["newcastle knights 2025"] = "knights",
	["penrith panthers"] = "panthers",
	["penrith panthers 2025"] = "panthers",
	["south sydney rabbitohs"] = "rabbitohs",
	["south sydney rabbitohs 2025"] = "rabbitohs",
	["canberra raiders"] = "raiders",
	["canberra raiders 2025"] = "raiders",
	["sydney roosters"] = "roosters",
	["sydney roosters 2025"] = "roosters",
	["manly-warringah sea eagles"] = "sea_eagles",
	["manly-warringah sea eagles 2025"] = "sea_eagles",
	["cronulla-sutherland sharks"] = "sharks",
	["cronulla-sutherland sharks 2025"] = "sharks",
	["melbourne storm"] = "storm",
	["melbourne storm 2025"] = "storm",
	["gf melbourne storm"] = "storm",
	["gold coast titans"] = "titans",
	["gold coast titans 2025"] = "titans",
	["new zealand warriors"] = "warriors",
	["new zealand warriors 2025"] = "warriors",
	["wests tigers"] = "wests_tigers",
	["wests tigers 2025"] = "wests_tigers",
}
LED_BOARD_SPONSOR_TYPES = {
	["nrl"] = "nrl",
}
-- checked in order, before the team/competition boards
LED_BOARD_EVENTS = {
	{ board = "grand_final", specialEvent = { "GrandFinal" }, fieldMarkings = { "NRL_GrandFinal", "NRL_GrandFinal_Post2017" }, sponsorTypes = { "nrl" } },
	{ board = "finals", specialEvent = { "QualifyingFinal", "EliminationFinal", "SemiFinal", "PreliminaryFinal", "Final" }, fieldMarkings = { "NRL_Finals" }, isFinal = true, sponsorTypes = { "nrl" } },
	{ board = "state_of_origin", competition = { "Tournament_StateOfOrigin" }, fieldMarkings = { "NRL_Rep_StateOfOrigin" } },
	{ board = "magic_round", specialEvent = { "MagicRound" }, fieldMarkings = { "NRL_Season_Tuesday" } },
	{ board = "vegas", specialEvent = { "Vegas" }, fieldMarkings = { "NRL_Season_Wednesday" }, ground = { "lasVegasStadium" } },
}
-- END GENERATED

-- a package ships the block above empty (the installer fills it)
LED_BOARD_TIMING = LED_BOARD_TIMING or { persistTime = 5, transitionTime = 0.5 }
LED_BOARDS = LED_BOARDS or {}
LED_BOARD_CLUBS = LED_BOARD_CLUBS or {}
LED_BOARD_SPONSOR_TYPES = LED_BOARD_SPONSOR_TYPES or {}
LED_BOARD_EVENTS = LED_BOARD_EVENTS or {}

-- true when arg_value is one of the named members of a native enum. Names are
-- looked up under pcall, so one missing from this build just never matches.
local function ledEnumIs(arg_enum, arg_names, arg_value)
	if arg_value == nil or not arg_names then
		return false
	end

	for iter_i, iter_name in ipairs(arg_names) do
		local ok, value = pcall(function()
			return arg_enum[iter_name]
		end)

		if ok and value ~= nil and value == arg_value then
			return true
		end
	end

	return false
end

local function ledListHas(arg_list, arg_value)
	for iter_i, iter_v in ipairs(arg_list or {}) do
		if iter_v == arg_value then
			return true
		end
	end

	return false
end

-- The first LED_BOARD_EVENTS entry this match is (finals, Origin, ...).
local function ledEventFor(arg_groundKey, arg_ground, arg_match)
	local season = arg_match.stateOfTheSeason
	local markings = arg_match.matchType and arg_match.matchType.fieldMarkings

	for iter_i, iter_event in ipairs(LED_BOARD_EVENTS) do
		local hit = ledEnumIs(native.CareerFixtureSpecialEvent, iter_event.specialEvent, season.specialEvent)
			or ledEnumIs(native.CareerCompetitionIdEnum, iter_event.competition, season.competitionId)
			or ledEnumIs(native.MatchSettingsFieldMarkings, iter_event.fieldMarkings, markings)
			or ledListHas(iter_event.ground, arg_groundKey)
			or iter_event.isFinal == true and season.isFinal == true

		if hit and (not iter_event.sponsorTypes or ledListHas(iter_event.sponsorTypes, arg_ground.sponsorType)) then
			return iter_event.board
		end
	end

	return nil
end

-- {texture, rows, persistTime, transitionTime, name} or nil (keep the stock
-- boards): an event board first, then the home club's, the ground's
-- competition's, or default. Competitions without boards of their own
-- (Challenge Cup, Women's Super League, World Cup) and a Magic Round with
-- no event board keep the stock boards, like the hoarding choice below.
local function ledBoardFor(arg_groundKey, arg_ground, arg_match)
	if not arg_match or not arg_match.home or not arg_match.stateOfTheSeason then
		return nil
	end

	local name = ledEventFor(arg_groundKey, arg_ground, arg_match)

	if not name then
		local competition = arg_match.stateOfTheSeason.competitionId
		local special = arg_match.stateOfTheSeason.specialEvent == native.CareerFixtureSpecialEvent.MagicRound
			or competition == native.CareerCompetitionIdEnum.Tournament_ChallengeCup
			or competition == native.CareerCompetitionIdEnum.Tournament_WomensChallengeCup
			or competition == native.CareerCompetitionIdEnum.League_WSL
			or competition == native.CareerCompetitionIdEnum.Tournament_RLWC2026Men
			or competition == native.CareerCompetitionIdEnum.Tournament_RLWC2026Women

		if special then
			return nil
		end

		local ok, fullName = pcall(function()
			return arg_match.home.identity.fullName
		end)

		name = ok and type(fullName) == "string" and LED_BOARD_CLUBS[string.lower(fullName)]
		name = name or LED_BOARD_SPONSOR_TYPES[arg_ground.sponsorType or ""] or "default"
	end

	local board = LED_BOARDS[name]

	if not board then
		return nil
	end

	return {
		name = name,
		texture = board.texture,
		rows = board.rows,
		persistTime = LED_BOARD_TIMING.persistTime,
		transitionTime = LED_BOARD_TIMING.transitionTime
	}
end

function getStadiumModelFilenames(arg_10_0, arg_10_1)
	local var_10_0 = var_0_6(arg_10_0)
	local var_10_1 = getStadiumModelCfg(arg_10_0)
	local var_10_2 = var_10_1.basePath
	local var_10_3 = var_10_1.commonTexpack ~= false and var_10_2 .. "common_t1.texpack"
	local var_10_4 = func.map(function(arg_11_0, arg_11_1)
		return arg_11_1, var_10_2 .. arg_11_1 .. "_t1.model"
	end, ipairs(var_10_1.models))

	func.mapInto(var_10_4, function(arg_12_0, arg_12_1)
		return arg_12_1, arg_12_1
	end, ipairs(var_10_1.additionalModels))

	local var_10_5 = var_10_1.sponsorHoardingModels

	if var_10_5 then
		local var_10_6
		local var_10_7 = arg_10_1.stateOfTheSeason.competitionId
		local var_10_8 = arg_10_1.stateOfTheSeason.specialEvent
		local var_10_9 = arg_10_1.home
		local var_10_10 = string.lower(var_10_9.nickname)
		local var_10_11 = var_10_8 == native.CareerFixtureSpecialEvent.MagicRound and "magicRound_" .. var_10_10
		local var_10_12 = (var_10_7 == native.CareerCompetitionIdEnum.Tournament_ChallengeCup or var_10_7 == native.CareerCompetitionIdEnum.Tournament_WomensChallengeCup) and "challengeCup"
		local var_10_13 = var_10_7 == native.CareerCompetitionIdEnum.League_WSL and "superLeagueWomens"
		local var_10_14 = var_10_7 == native.CareerCompetitionIdEnum.Tournament_RLWC2026Men and "rlwcMale"
		local var_10_15 = var_10_7 == native.CareerCompetitionIdEnum.Tournament_RLWC2026Women and "rlwcFemale"
		local var_10_16 = var_10_9.identity:getGround(1)
		local var_10_17 = var_10_9.identity:getGround(2)
		local var_10_18 = var_10_9.identity:getGround(3)
		local var_10_19 = (var_10_16.key == arg_10_0 or var_10_17.key == arg_10_0 or var_10_18.key == arg_10_0) and var_10_10
		local var_10_20 = var_10_5[var_10_0.sponsorType] and var_10_0.sponsorType
		local var_10_21 = var_10_11 or var_10_12 or var_10_14 or var_10_15 or var_10_5[var_10_19] and var_10_19 or var_10_13 or var_10_20

		if not var_10_5[var_10_21] then
			var_10_21 = tostring(native.MatchSettingsAdvertisingHoardings.standard)
		end

		if var_10_5[var_10_21] then
			var_10_4[var_10_21] = var_10_2 .. var_10_5[var_10_21] .. "_t1.model"
		end
	end

	local ledBoard = var_10_5 and ledBoardFor(arg_10_0, var_10_0, arg_10_1)

	return {
		models = var_10_4,
		texpack = var_10_3,
		ledBoard = ledBoard
	}
end

function getStadiumCollisionBlob(arg_13_0)
	return "collision/stadiums/" .. arg_13_0 .. "/collision.collision"
end

function appendStadiumConfig(arg_14_0, arg_14_1)
	local var_14_0 = var_0_6(arg_14_1)

	assert(type(var_14_0) == "table")

	local var_14_1 = {}
	local var_14_2 = var_14_0.AppendConfig

	if var_14_2 then
		for iter_14_0, iter_14_1 in pairs(var_14_2) do
			local var_14_3 = arg_14_0[iter_14_0]

			if var_14_3 == nil then
				var_14_1[iter_14_0] = iter_14_1
			else
				var_14_1[iter_14_0] = var_14_3
			end
		end
	end

	return var_14_1
end

local function var_0_7(arg_15_0, arg_15_1, arg_15_2)
	local var_15_0 = var_0_6(arg_15_0)[arg_15_1]

	if not var_15_0 then
		error("stadium-visual.lua entry for \"" .. arg_15_0 .. "\" did not have a table for \"" .. arg_15_1 .. "\"")
	end

	for iter_15_0, iter_15_1 in pairs(var_15_0) do
		local var_15_1 = true

		for iter_15_2, iter_15_3 in pairs(arg_15_2) do
			if iter_15_3 ~= iter_15_0[iter_15_2] then
				var_15_1 = false

				break
			end
		end

		if var_15_1 then
			return iter_15_1
		end
	end

	local var_15_2 = "stadium-visual.lua entry for \"" .. arg_15_0 .. "\" did not have a " .. arg_15_1 .. " for { "

	for iter_15_4, iter_15_5 in pairs(arg_15_2) do
		var_15_2 = var_15_2 .. iter_15_4 .. "=\"" .. iter_15_5 .. "\" "
	end

	local var_15_3 = var_15_2 .. "}"

	error(var_15_3)
end

function getPostFxID(arg_16_0, arg_16_1, arg_16_2)
	if arg_16_0 == "nets" then
		return "nets"
	end

	assert(type(arg_16_1) == "string")
	assert(type(arg_16_2) == "string")

	local var_16_0 = {
		weather = "fine",
		time = arg_16_2
	}

	return var_0_7(arg_16_0, "PostFxID", var_16_0)
end

function getStadiumSunArc(arg_17_0)
	local var_17_0 = var_0_6(arg_17_0)

	assert(type(var_17_0) == "table")

	return var_17_0.SunArcAzimuth or 0, var_17_0.SunArcPhi or 30
end

function getStadiumLightPositions(arg_18_0, arg_18_1)
	local var_18_0 = var_0_6(arg_18_0)

	assert(type(var_18_0) == "table")
	assert(type(arg_18_1) == "string")

	local var_18_1 = {
		time = arg_18_1
	}
	local var_18_2 = var_18_0.SceneLightPositions

	for iter_18_0, iter_18_1 in pairs(var_18_2) do
		local var_18_3 = true

		for iter_18_2, iter_18_3 in pairs(var_18_1) do
			if iter_18_3 ~= iter_18_0[iter_18_2] then
				var_18_3 = false

				break
			end
		end

		if var_18_3 then
			return iter_18_1
		end
	end

	error("stadium-visual.lua entry for \"" .. arg_18_0 .. "\" did not have a lightingPositions for {time=\"" .. arg_18_1 .. "\" }")
end

function getGrassId(arg_19_0, arg_19_1, arg_19_2)
	ASSERT(arg_19_0 or arg_19_1)

	local var_19_0 = var_0_5
	local var_19_1 = VERIFY(var_19_0.Grass)
	local var_19_2 = var_19_0.GrassTypes

	if arg_19_1 and type(arg_19_1) ~= "string" then
		arg_19_1 = tostring(arg_19_1)
	end

	if arg_19_2 and type(arg_19_2) ~= "string" then
		arg_19_2 = tostring(arg_19_2)
	end

	if arg_19_0 and type(arg_19_0) ~= "string" then
		arg_19_0 = tostring(arg_19_0)
	end

	local var_19_3

	for iter_19_0, iter_19_1 in pairs(var_19_2) do
		if arg_19_0 and iter_19_0.type == arg_19_0 or arg_19_0 and iter_19_1 == arg_19_0 or arg_19_1 and iter_19_0.type == arg_19_1 and iter_19_0.cracks == arg_19_2 then
			var_19_3 = iter_19_1

			break
		end
	end

	ASSERT(var_19_3)

	local var_19_4 = VERIFY(var_19_1[var_19_3], "no such grass: " .. var_19_3)

	return var_19_3, var_19_4
end

function getFieldConfig(arg_20_0, arg_20_1, arg_20_2, arg_20_3, arg_20_4)
	local var_20_0 = var_0_5
	local var_20_1, var_20_2 = getGrassId(arg_20_0, arg_20_1, arg_20_2)
	local var_20_3 = deepclone.deepCloneTable(var_20_2)
	local var_20_4 = var_0_3.Stadiums[arg_20_4]

	if arg_20_3 then
		arg_20_1 = tostring(arg_20_1)

		local var_20_5 = var_20_0.Conditions
		local var_20_6 = assert(var_20_5[arg_20_1])
		local var_20_7 = assert(var_20_6[tostring(arg_20_3)])

		var_20_3.field.wearTex = assert(var_20_7.wearTex)
		var_20_3.noGrass = var_20_4.noGrass
	end

	var_20_3.dimensions = var_20_4.GrassDimensions

	return var_20_3, var_20_1
end

function getFieldPattern(arg_21_0)
	local var_21_0 = var_0_5
	local var_21_1 = assert(var_21_0.GrassPatterns)
	local var_21_2 = assert(var_21_1[arg_21_0])
	local var_21_3 = math.rad(var_21_2.angle1)
	local var_21_4 = math.rad(var_21_2.angle2)
	local var_21_5 = var_21_2.tableDimensions

	return {
		stripeWidth = var_21_2.width,
		stripeDirection = native.vec4(math.sin(var_21_3), math.cos(var_21_3), math.sin(var_21_4), math.cos(var_21_4)),
		outerAmount = var_21_2.outerAmount,
		innerAmount = var_21_2.innerAmount
	}
end

function getStadiumWeatherZone(arg_22_0)
	local var_22_0 = var_0_6(arg_22_0)

	assert(type(var_22_0) == "table", "Config was of wrong type(" .. type(var_22_0) .. ") for stadium: " .. arg_22_0)

	return var_22_0.WeatherZone or native.EWeatherZone.Temperate
end
