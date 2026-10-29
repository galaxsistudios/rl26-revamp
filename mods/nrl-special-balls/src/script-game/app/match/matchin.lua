import("ai.officials.refereehelper")
import("app.match.matchin_refereeuniform")
import("app.match.stadium_helper")
import("app.settings.setting_data")
import("base.side.sidehelper")
import("core.foundation.func")
import("core.foundation.stringx")
import("core.foundation.tablex")
import("design.playerbalance_cconfig")
import("design.slider_config_custom_difficulties")
import("design.evaluate_cconfig")
import("design.gameplaybalance_cconfig")
import("design.rugby.placekick_cconfig")
import("design.tackle_cconfig")
import("design.tackle.tacklequery_cconfig")
import("design.injury_cconfig")
import("intermediatelua.convant.stadiums")
import("rendering.stadium.stadiumconfig")
import("script-config.ai.rugby.officials.referee_config")
import("design.stamina_cconfig")
import("script-config.design.timeofday_config")
import("design.characters.assetmap")
import("script-config.game.metrics.metrics_config")
import("design.forcedirectedgraph_cconfig")

local var_0_0 = forcedirectedgraph_cconfig.cForceDirectedGraphConfig
local var_0_1 = playerbalance_cconfig.cPlayerBalanceConfig
local var_0_2 = slider_config_custom_difficulties.cDifficultySliderConfig
local var_0_3 = evaluate_cconfig.cPlayerFlowchartConfig
local var_0_4 = tackle_cconfig.cTackleConfig
local var_0_5 = tacklequery_cconfig.cTackleQueryConfig
local var_0_6 = placekick_cconfig.cPlaceKickConfig
local var_0_7 = injury_cconfig.cInjuryConfig
local var_0_8 = stamina_cconfig.cStaminaConfig
local var_0_9 = gameplaybalance_cconfig.cGameplayBalance
local var_0_10 = stadium_helper.getStadiumUIOrder
local var_0_11 = assetmap.AssetMapItems
local var_0_12 = 32
local var_0_13 = "intermediatelua.visualconfig.stadium-cfg"
local var_0_14 = load(var_0_13)
local var_0_15 = native.CGameConfig.MAX_UMPIRES
local var_0_16 = {
	nets = {
		weather = native.EWeatherType.Clear,
		pitchCondition = native.MatchSettingsPitchCondition.Pristine,
		pitchType = native.MatchSettingsPitchType.Crumbly,
		pitchHardness = native.MatchSettingsPitchHardness.Hard,
		pitchCracks = native.MatchSettingsPitchCracks.None,
		quickPitchWear = native.MatchSettingsQuickPitchWear.Off
	},
	scg = {
		weather = native.EWeatherType.Clear,
		pitchCondition = native.MatchSettingsPitchCondition.Pristine,
		pitchType = native.MatchSettingsPitchType.Crumbly,
		pitchHardness = native.MatchSettingsPitchHardness.Hard,
		pitchCracks = native.MatchSettingsPitchCracks.None,
		quickPitchWear = native.MatchSettingsQuickPitchWear.Off
	}
}
local var_0_17 = {
	awayClub = "away",
	homeClub = "home",
	leftTeamGround = "home",
	rightTeamGround = "away"
}
local var_0_18 = setting_data.NumericalRepresentationOfRandom
local var_0_19 = {
	[native.MatchSettingsTimeOfDay.morning] = timeofday_config.matchStartTimes.morning,
	[native.MatchSettingsTimeOfDay.day] = timeofday_config.matchStartTimes.day,
	[native.MatchSettingsTimeOfDay.afternoon] = timeofday_config.matchStartTimes.afternoon,
	[native.MatchSettingsTimeOfDay.dusk] = timeofday_config.matchStartTimes.dusk,
	[native.MatchSettingsTimeOfDay.night] = timeofday_config.matchStartTimes.night
}

function getTimeOfDayFromHour(arg_1_0)
	if arg_1_0 >= timeofday_config.matchStartTimes.night then
		return native.MatchSettingsTimeOfDay.night
	end

	if arg_1_0 >= timeofday_config.matchStartTimes.dusk then
		return native.MatchSettingsTimeOfDay.dusk
	end

	if arg_1_0 >= timeofday_config.matchStartTimes.afternoon then
		return native.MatchSettingsTimeOfDay.afternoon
	end

	if arg_1_0 >= timeofday_config.matchStartTimes.day then
		return native.MatchSettingsTimeOfDay.day
	end

	if arg_1_0 >= timeofday_config.matchStartTimes.morning then
		return native.MatchSettingsTimeOfDay.morning
	end

	return native.MatchSettingsTimeOfDay.night
end

local var_0_20 = {
	{
		refereehelper.referee,
		refereehelper.region.east
	},
	{
		refereehelper.referee,
		refereehelper.region.west
	},
	{
		refereehelper.touchjudge,
		refereehelper.region.north
	},
	{
		refereehelper.touchjudge,
		refereehelper.region.south
	}
}

function setupReferees(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5)
	if not arg_2_4 then
		local var_2_0 = not arg_2_0.playGo
		local var_2_1 = native.Random(arg_2_1.matchSeed)

		arg_2_4 = arg_2_2:getRandomIdsOfType(var_2_1, var_0_15, native.CNpcType.Referee, native.CSex.Male, var_2_0)
	end

	assert(#arg_2_4 == var_0_15)
	assert(#arg_2_4 == #referee_config.officialRole)

	local var_2_2 = arg_2_0.umpireConfig

	var_2_2:clear()

	for iter_2_0, iter_2_1 in ipairs(arg_2_4) do
		local var_2_3 = arg_2_2:getReferee(iter_2_1)
		local var_2_4 = var_2_2:registerUmpire() or var_2_2:getUmpire(iter_2_0)

		var_2_4:setFromFrontendReferee(var_2_3)
		var_2_4:setOfficialRole(referee_config.officialRole[iter_2_0])

		local var_2_5 = var_0_20[iter_2_0]

		var_2_4.type, var_2_4.region = unpack(var_2_5)
	end

	var_2_2:fillDecalDatabase(arg_2_3)
end

function applyGroundOverride(arg_3_0, arg_3_1)
	for iter_3_0, iter_3_1 in pairs(arg_3_1) do
		arg_3_0[iter_3_0] = iter_3_1
	end
end

local function var_0_21(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7, arg_4_8)
	local var_4_0 = native.Random(arg_4_3.matchSeed)

	if arg_4_2.gameMode == native.EGameMode.Practice then
		local var_4_1 = native.Stadiums.getFromString(arg_4_4.ground)

		arg_4_4.groundInfo.stadium = var_4_1

		arg_4_2.groundInfo.groundInfo:set(arg_4_4.groundInfo)
	end

	local var_4_2 = arg_4_4.groundInfo
	local var_4_3 = var_4_2.key
	local var_4_4 = var_4_2:getOption("stadiumId")

	if var_4_4 and var_4_4 >= native.CLevelDataStore.MinLevelId and var_4_4 < native.CLevelDataStore.MinLevelId + native.CLevelDataStore.MaxLevels then
		var_4_3 = "creator"
	end

	local var_4_5 = arg_4_4.groundId
	local var_4_6

	if var_4_3 == "random" then
		local var_4_7 = {}

		for iter_4_0, iter_4_1 in pairs(stadiums.ValidForRandomMap) do
			if iter_4_1 then
				table.insert(var_4_7, iter_4_0)
			end
		end

		ASSERT(#var_4_7 > 0)

		var_4_3 = tablex.irandomelement(var_4_7, var_4_0)

		ASSERT(var_4_3)
	elseif var_0_17[var_4_3] then
		var_4_2 = arg_4_2[var_0_17[var_4_3]].identity:getGround(1)
		var_4_3 = var_4_2.key
	end

	arg_4_2.groundInfo.ground = var_4_3

	if var_4_3 == "creator" then
		if not arg_4_6 then
			var_4_3 = "moorePark"
			arg_4_2.groundInfo.ground = var_4_3
		else
			local var_4_8 = arg_4_2.groundInfo

			var_4_8.groundInfo:set(var_4_2)
			var_4_8:storeLevelData(arg_4_6)
			var_4_8:storeLevelDecals(arg_4_7, arg_4_1)

			local var_4_9 = arg_4_5

			if string.len(var_4_9) > var_0_12 then
				var_4_9 = string.sub(var_4_9, 1, var_0_12 - 1)
			end

			var_4_8.groundInfo:setOption("customName", var_4_9)
			var_4_8.groundInfo:setOption("wantCustomName", true)

			if arg_4_8 and arg_4_8.isConsideredToBeUserCreatedContent then
				local var_4_10 = arg_4_8.sharing

				if not var_4_10.isOnSharingServer then
					var_4_8.levelCreator = -1
				else
					var_4_8.levelCreator = var_4_10.currentAuthor
				end
			end

			var_4_6 = arg_4_6.weatherZone
		end
	end

	var_4_6 = var_4_6 or stadiumconfig.getStadiumWeatherZone(var_4_3)

	ASSERT(var_4_6)
	arg_4_4.groundInfo:setOption("weatherZone", var_4_6:toInt())
	arg_4_2.groundInfo.groundInfo:setOption("weatherZone", var_4_6:toInt())
end

-- nrl-special-balls: extra ball textures (props/balls/textures/<texture>, added by the mod's
-- install.py). ballfactory.lua loads one in place of the stock texture of `base`.
-- MOD_EXTRA_BALLS is listed in Play Now's Ball row (enable-casual-fieldmarkings).
modSpecialEventBalls = {
	[native.CareerFixtureSpecialEvent.MagicRound] = "ball_nrl_magicround_col",
	[native.CareerFixtureSpecialEvent.GrandFinal] = "ball_nrl_grandfinal_col"
}

rawset(_G, "MOD_EXTRA_BALLS", {
	{
		label = "NRL Magic Round",
		texture = "ball_nrl_magicround_col",
		base = native.MatchSettingsBall.nrl
	},
	{
		label = "NRL Grand Final",
		texture = "ball_nrl_grandfinal_col",
		base = native.MatchSettingsBall.nrl
	},
	{
		label = "Pacific Test",
		texture = "ball_nrl_pacific_test_col",
		base = native.MatchSettingsBall.nrl
	}
})

function setupBall(arg_5_0, arg_5_1, arg_5_2, arg_5_3)
	if arg_5_0.ball then
		arg_5_1.matchType.ball = arg_5_0.ball
	end

	local var_5_0 = {
		[native.CareerFixtureSpecialEvent.Vegas] = native.MatchSettingsBall.vegas
	}
	local var_5_1 = {
		[native.CareerCompetitionIdEnum.League_NRL] = native.MatchSettingsBall.nrl,
		[native.CareerCompetitionIdEnum.League_NRLW] = native.MatchSettingsBall.nrlw,
		[native.CareerCompetitionIdEnum.League_SuperLeague] = native.MatchSettingsBall.superleague,
		[native.CareerCompetitionIdEnum.League_WSL] = native.MatchSettingsBall.superleague,
		[native.CareerCompetitionIdEnum.League_QLDCup] = native.MatchSettingsBall.qldcup,
		[native.CareerCompetitionIdEnum.Tournament_StateOfOrigin] = native.MatchSettingsBall.soo1,
		[native.CareerCompetitionIdEnum.Tournament_ChallengeCup] = native.MatchSettingsBall.challengecup,
		[native.CareerCompetitionIdEnum.Tournament_WomensChallengeCup] = native.MatchSettingsBall.challengecup,
		[native.CareerCompetitionIdEnum.League_BetfredLeague1] = native.MatchSettingsBall.league1,
		[native.CareerCompetitionIdEnum.Tournament_StateOfOriginWomens] = native.MatchSettingsBall.soo2,
		[native.CareerCompetitionIdEnum.Tournament_RLWC2026Men] = native.MatchSettingsBall.rlwc26Male,
		[native.CareerCompetitionIdEnum.Tournament_RLWC2026Women] = native.MatchSettingsBall.rlwc26Female
	}
	local var_5_2 = arg_5_3 and arg_5_3.isCasual
	local var_5_3 = arg_5_1.stateOfTheSeason.specialEvent
	local var_5_4 = arg_5_1.stateOfTheSeason.competitionId

	arg_5_1.matchType.ball = var_5_2 and arg_5_1.matchType.ball or var_5_0[var_5_3] or var_5_1[var_5_4] or arg_5_1.matchType.ball

	-- nrl-special-balls: Play Now uses the Ball row's pick (_G.MOD_PLAYNOW_BALL, a texture
	-- name from MOD_EXTRA_BALLS), career NRL fixtures the special event's ball.
	local var_5_5

	if var_5_2 then
		var_5_5 = rawget(_G, "MOD_PLAYNOW_BALL")
	elseif var_5_4 == native.CareerCompetitionIdEnum.League_NRL then
		var_5_5 = modSpecialEventBalls[var_5_3]
	end

	rawset(_G, "MOD_SPECIAL_BALL", var_5_5 and {
		ball = arg_5_1.matchType.ball,
		texture = var_5_5
	} or nil)
end

function setGroundAdvertising(arg_6_0)
	arg_6_0.advertisingHoardings = native.MatchSettingsAdvertisingHoardings.standard
end

function addMatchSettings(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7, arg_7_8, arg_7_9, arg_7_10)
	if arg_7_4.matchSeed then
		arg_7_3.matchSeed = arg_7_4.matchSeed
	end

	if arg_7_4.matchGuid then
		arg_7_2.matchGuid = arg_7_4.matchGuid
	end

	var_0_21(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7, arg_7_8)

	if arg_7_4.advertisingHoardings then
		arg_7_2.advertisingHoardings = arg_7_4.advertisingHoardings
	end

	setGroundAdvertising(arg_7_2)

	local var_7_0 = arg_7_4.matchType

	if not arg_7_9 then
		arg_7_2.matchType:set(var_7_0)
	end

	setupBall(arg_7_4, arg_7_2, arg_7_6, arg_7_10)

	if arg_7_4.difficulty then
		arg_7_2.difficulty = arg_7_4.difficulty == native.EDifficulty.Multiplayer and native.EDifficulty.Medium or arg_7_4.difficulty
	end

	if arg_7_4.difficultyIndex then
		arg_7_2.difficultyIndex = arg_7_4.difficultyIndex
	end

	if arg_7_4.injuries then
		arg_7_2:setInjuryLevel(arg_7_4.injuries)
	end

	if arg_7_4.timeOfDay then
		local var_7_1 = arg_7_4.timeOfDay
		local var_7_2 = native.Random(arg_7_3.matchSeed)

		while var_7_1 == native.MatchSettingsTimeOfDay.random do
			local var_7_3 = var_7_2:next(1, native.MatchSettingsTimeOfDay.Count - 2)

			var_7_1 = native.MatchSettingsTimeOfDay:fromInt(var_7_3)
		end

		arg_7_2.startTime = var_0_19[var_7_1]
		arg_7_2.timeOfDay = var_0_19[var_7_1]
	end

	if arg_7_4.rules ~= arg_7_4.matchType.rules then
		arg_7_2.matchType.rules = arg_7_4.matchType.rules
	else
		arg_7_2.matchType.rules = arg_7_4.rules
	end

	if arg_7_4.extraTime then
		arg_7_2.matchType.extraTime = arg_7_4.extraTime
	end

	if arg_7_4.sinBinsAndSendOffsEnabled ~= nil then
		arg_7_2.sinBinsAndSendOffsEnabled = arg_7_4.sinBinsAndSendOffsEnabled
	end

	if arg_7_4.captainsChallengeEnabled ~= nil then
		arg_7_2.captainsChallengeEnabled = arg_7_4.captainsChallengeEnabled
	end

	if arg_7_4.fieldMarkings then
		arg_7_2.matchType.fieldMarkings = arg_7_4.fieldMarkings
	end

	local var_7_4 = var_7_0.categorisedMatchType == native.EMatchType.MT_Nines

	if var_7_4 and arg_7_4.halfLengthNines then
		arg_7_2.matchType.halfLengthRealTime = arg_7_4.halfLengthNines
	elseif not var_7_4 and arg_7_4.halfLength and not arg_7_9 then
		arg_7_2.matchType.halfLengthRealTime = arg_7_4.halfLength
	end

	if arg_7_4.commentaryPair then
		arg_7_2.commentaryPair = arg_7_4.commentaryPair
	end

	if arg_7_4.refereePair then
		arg_7_2.refereePair = arg_7_4.refereePair
	end

	if arg_7_4.weather then
		arg_7_2.weatherType = arg_7_4.weather
	end
end

function addGamer(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5, arg_8_6, arg_8_7)
	local var_8_0 = arg_8_0.gamerInformation:addNew()

	var_8_0.isSet = true
	var_8_0.localGamerIndex = arg_8_4
	var_8_0.side = sidehelper[arg_8_1]
	var_8_0.userId = arg_8_5
	var_8_0.isLocal = arg_8_6
	var_8_0.name = arg_8_3

	if arg_8_2 then
		local var_8_1 = arg_8_2.stats

		var_8_0.controllerInfo = arg_8_2:getControllerInfo()
		var_8_0.partyMemberUniqueId = arg_8_2.uniqueId
		var_8_0.partyMemberStats = var_8_1
		var_8_0.partyMemberSettings = arg_8_2.settings
		var_8_0.matchmakingRank.rankMean = var_8_1:getStat("matchmakingSkillMean")
		var_8_0.matchmakingRank.rankStdDev = var_8_1:getStat("matchmakingSkillStdDev")
	else
		local var_8_2 = native.CMatchmakingPlayerSkill()

		var_8_0.controllerInfo = native.CInputControllerInfo.Create(nil, 1, native.EDeviceType.Pad)
		var_8_0.partyMemberUniqueId = -1
		var_8_0.matchmakingRank.rankMean = var_8_2.rankMean
		var_8_0.matchmakingRank.rankStdDev = var_8_2.rankStdDev
	end
end

function addLobbyGamers(arg_9_0, arg_9_1, arg_9_2)
	local var_9_0 = arg_9_1:getParty()

	arg_9_0.gamerInformation:clear()

	for iter_9_0 in arg_9_2.lobbyService:allObjectsOfType("LobbyPartyMember") do
		local var_9_1 = iter_9_0.isSet and iter_9_0.isLocal and var_9_0:getPartyMemberForUniqueId(iter_9_0.uniqueId)

		addGamer(arg_9_0, iter_9_0.localSide, var_9_1, iter_9_0.name, iter_9_0.localGamerIndex, iter_9_0.userId, iter_9_0.isLocal, iter_9_0.objectives)
	end

	local var_9_2 = arg_9_0.gamerInformation
	local var_9_3 = 0
	local var_9_4 = 0

	for iter_9_1, iter_9_2 in var_9_2:iter() do
		if iter_9_2.side == sidehelper.home then
			var_9_3 = var_9_3 + 1
		elseif iter_9_2.side == sidehelper.away then
			var_9_4 = var_9_4 + 1
		end
	end

	arg_9_0.localMultiplayer = var_9_3 + var_9_4 > 1 and true or false
	arg_9_0.localCoopMultiplayer = (var_9_3 > 1 or var_9_4 > 1) and true or false
end

function processCommandLine(arg_10_0, arg_10_1)
	for iter_10_0, iter_10_1 in pairs(arg_10_1) do
		if #iter_10_0 > 0 then
			local var_10_0 = stringx.split(iter_10_0, "%.")
			local var_10_1 = arg_10_0

			for iter_10_2 = 1, #var_10_0 - 1 do
				local var_10_2 = var_10_0[iter_10_2]

				formatPrint("grabbing config object %s from matchInData", tostring(var_10_2))

				var_10_1 = assert(var_10_1[var_10_2])
			end

			local var_10_3 = var_10_0[#var_10_0]

			ASSERT(type(var_10_3) == "string")

			if var_10_1:hasProperty(var_10_3) then
				formatPrint("overriding \"%s\" with command line value \"%s\" (old value \"%s\")", iter_10_0, tostring(iter_10_1), tostring(var_10_1[var_10_3]))

				var_10_1[var_10_3] = iter_10_1
			end
		end
	end

	if arg_10_1.forceBeAPro then
		local var_10_4 = tonumber(arg_10_1.forceBeAPro)

		if not var_10_4 or var_10_4 < native.AssignedRole.FullBack:toInt() or var_10_4 >= native.AssignedRole.Count then
			assert(false, "forceBeAPro must be set along with a value between " .. native.AssignedRole.FullBack:toInt() .. " and " .. native.AssignedRole.Count - 1)
		end

		arg_10_0.beAProAssetId = arg_10_0.homeTeamConfig.matchClub.lineup:getPlayerFillingRole(native.AssignedRole:fromInt(var_10_4))
	end

	if arg_10_1.ground then
		arg_10_0.groundInfo.groundInfo.key = arg_10_1.ground
	end
end

local function var_0_22(arg_11_0)
	local var_11_0 = native.UTCTime.now()
	local var_11_1 = native.CDateTime(var_11_0)
	local var_11_2 = var_11_1:getYear()
	local var_11_3 = var_11_1:getMonth()
	local var_11_4 = var_11_1:getDay()

	arg_11_0.homeTeamConfig:resolvePlayerAges(var_11_2, var_11_3, var_11_4)
	arg_11_0.awayTeamConfig:resolvePlayerAges(var_11_2, var_11_3, var_11_4)
end

function resolveGround(arg_12_0, arg_12_1, arg_12_2, arg_12_3, arg_12_4)
	local var_12_0 = arg_12_1.groundInfo
	local var_12_1 = var_12_0.groundInfo.key
	local var_12_2

	if arg_12_4 and arg_12_4.ground == native.EStadiums.homeClub then
		var_12_1 = arg_12_3.groundKey
		var_12_2 = arg_12_3.groundName

		if var_12_2 == "" then
			var_12_2 = nil
		end
	elseif var_12_1 == "random" then
		local var_12_3 = native.Random(arg_12_2.matchSeed)

		var_12_1 = tablex.irandomelement(var_0_10(arg_12_0), var_12_3)
	elseif var_12_1 == "homeClub" then
		var_12_1 = arg_12_3.groundKey

		if arg_12_1.gameMode ~= native.EGameMode.Casual then
			var_12_2 = arg_12_3.groundName
		end

		if var_12_2 == "" then
			var_12_2 = nil
		end
	else
		var_12_1 = var_12_1 == "homeClubFinals" and "moorePark" or arg_12_1.groundInfo.ground
	end

	if var_12_1 == "trainingfacility" then
		var_12_0.hasCrowd = false
	else
		var_12_0.hasCrowd = true
	end

	var_12_0.groundInfo.stadium = native.EStadiums[var_12_1]

	if var_12_2 then
		var_12_0.groundInfo:setOption("wantCustomName", true)
		var_12_0.groundInfo:setOption("customName", var_12_2)
	end
end

local function var_0_23(arg_13_0, arg_13_1, arg_13_2)
	local var_13_0 = matchin_refereeuniform.determineUniformType(arg_13_0, arg_13_1)
	local var_13_1 = VERIFY(var_13_0)
	local var_13_2 = tostring(var_13_1)
	local var_13_3 = string.format("RefereeMale_%s", var_13_2)
	local var_13_4 = arg_13_2:get(native.DefaultTeamVisuals[var_13_3])
	local var_13_5 = arg_13_0.umpireConfig

	for iter_13_0 = 1, var_13_5:getUmpireCount() do
		var_13_5:getUmpire(iter_13_0).uniform:copy(var_13_4)
	end
end

local function var_0_24(arg_14_0, arg_14_1, arg_14_2)
	local var_14_0 = arg_14_0:getClub(sidehelper.home)
	local var_14_1 = arg_14_0:getClub(sidehelper.away)

	var_14_0:resolveJerseyNumbers()
	var_14_1:resolveJerseyNumbers()
end

local function var_0_25(arg_15_0, arg_15_1, arg_15_2, arg_15_3)
	local var_15_0
	local var_15_1

	if arg_15_3 then
		local var_15_2 = arg_15_2.id

		var_15_1 = arg_15_3:getClub(var_15_2).academyId
		var_15_0 = var_15_1
	else
		var_15_0, var_15_1 = arg_15_2.id, arg_15_2.academyId
	end

	ASSERT(var_15_0 and var_15_1)

	local var_15_3 = 97
	local var_15_4 = 102
	local var_15_5 = 103

	if var_15_0 == var_15_3 or var_15_1 == var_15_3 then
		return arg_15_0.origin
	end

	if var_15_0 == var_15_4 or var_15_1 == var_15_4 then
		return arg_15_0.indigenous
	end

	if var_15_0 == var_15_5 or var_15_1 == var_15_5 then
		return arg_15_0.australia
	end

	if arg_15_2.uniform.isNines then
		return arg_15_0.nines
	end
end

local function var_0_26(arg_16_0, arg_16_1, arg_16_2, arg_16_3, arg_16_4)
	local var_16_0 = arg_16_3:getPlayer(arg_16_0)

	if var_16_0 then
		local var_16_1 = var_0_25(arg_16_1, arg_16_2, arg_16_3, arg_16_4)

		if var_16_1 then
			local var_16_2 = var_16_0.visual

			for iter_16_0, iter_16_1 in pairs(var_16_1) do
				var_16_2:setOption(iter_16_0, iter_16_1)
			end
		end
	end
end

local function var_0_27(arg_17_0, arg_17_1, arg_17_2)
	if arg_17_2.matchStarted then
		return
	end

	local var_17_0 = arg_17_0.matchType

	for iter_17_0, iter_17_1 in ipairs(sidehelper.sides) do
		local var_17_1 = arg_17_0:getTeamConfig(iter_17_1)
		local var_17_2 = arg_17_1:getTeamState(iter_17_1)
		local var_17_3 = var_17_1.matchClub.lineup

		var_17_2:initialiseStateMap(func.map(function(arg_18_0, arg_18_1)
			local var_18_0 = native.CPlayerState()

			return arg_18_1, var_18_0
		end, var_17_3:iterPlayers()))
	end
end

local function var_0_28(arg_19_0, arg_19_1)
	local var_19_0 = {}

	table.insert(var_19_0, "guid")
	table.insert(var_19_0, arg_19_0.matchGuid)

	local var_19_1 = arg_19_0.sex.isMale and "Male" or "Female"

	table.insert(var_19_0, "sex")
	table.insert(var_19_0, var_19_1)

	local var_19_2 = arg_19_0.groundInfo.ground

	table.insert(var_19_0, "ground")
	table.insert(var_19_0, var_19_2)

	local var_19_3
	local var_19_4

	for iter_19_0, iter_19_1 in arg_19_0.gamerInformation:iter() do
		if iter_19_1.side == 1 then
			var_19_3 = true
		end

		if iter_19_1.side == 2 then
			var_19_4 = true
		end
	end

	table.insert(var_19_0, "human_home")
	table.insert(var_19_0, var_19_3 and "true" or "false")
	table.insert(var_19_0, "human_away")
	table.insert(var_19_0, var_19_4 and "true" or "false")

	local var_19_5 = arg_19_0.home
	local var_19_6 = var_19_5.isOnDiscClub
	local var_19_7 = var_19_5.fullName

	table.insert(var_19_0, "name_home")
	table.insert(var_19_0, var_19_7)

	local var_19_8 = arg_19_0.away
	local var_19_9 = var_19_8.isOnDiscClub
	local var_19_10 = var_19_8.fullName

	table.insert(var_19_0, "name_away")
	table.insert(var_19_0, var_19_10)

	local var_19_11 = arg_19_0.matchType
	local var_19_12 = var_19_11.isOnDisc and var_19_11.name or "Custom"
	local var_19_13 = arg_19_0.gameMode
	local var_19_14 = var_19_13 and native.EGameMode.toString(var_19_13) or "Unset"

	table.insert(var_19_0, "matchtype")
	table.insert(var_19_0, var_19_12)
	table.insert(var_19_0, "gamemode")
	table.insert(var_19_0, var_19_14)

	if var_19_13 == native.EGameMode.Career then
		local var_19_15 = arg_19_1 and arg_19_1.user
		local var_19_16
		local var_19_17 = var_19_15.playerStartedAsRookie > 0 and "Rookie" or var_19_15.isCoach and "Coach" or "Star"

		table.insert(var_19_0, "career_type")
		table.insert(var_19_0, var_19_17)
		table.insert(var_19_0, "career_is_player")
		table.insert(var_19_0, var_19_15.playAsPro and "true" or "false")
	end

	native.Metrics.addMetricData(metrics_config.MatchStart, var_19_0)
end

function finalise(arg_20_0, arg_20_1, arg_20_2, arg_20_3, arg_20_4, arg_20_5, arg_20_6, arg_20_7)
	resolveGround(arg_20_0, arg_20_1, arg_20_3, arg_20_1.homeTeamConfig.matchClub)
	var_0_23(arg_20_1, arg_20_3, arg_20_4)
	var_0_22(arg_20_1)
	var_0_27(arg_20_1, arg_20_2, arg_20_3)
	var_0_24(arg_20_1, arg_20_6, arg_20_7)
	var_0_28(arg_20_1, arg_20_5)
end

function processLobbySideInfo(arg_21_0, arg_21_1, arg_21_2, arg_21_3, arg_21_4, arg_21_5, arg_21_6, arg_21_7, arg_21_8)
	arg_21_3 = arg_21_3 or arg_21_8:getSideInfo(arg_21_4)

	local var_21_0 = arg_21_3:getMatchClub()
	local var_21_1 = arg_21_8 and arg_21_8:getDynastyUniform(arg_21_4)

	if var_21_1 then
		var_21_0:changeUniform(var_21_1)
	end

	arg_21_2:setMatchClub(var_21_0)
	arg_21_2:setTeamOVR(arg_21_3.rating)
	arg_21_2:fillDecalDatabase(arg_21_5, true)

	if arg_21_3.beAProRole then
		arg_21_0.beAProAssetId = arg_21_2.matchClub.lineup:getPlayerFillingRole(native.AssignedRole:fromInt(arg_21_3.beAProRole))
	end
end

function setupWeather(arg_22_0, arg_22_1, arg_22_2, arg_22_3, arg_22_4)
	local var_22_0 = arg_22_0:getLocationManager()
	local var_22_1 = native.CWeather(var_22_0)
	local var_22_2 = var_0_14.Stadiums[arg_22_4]
	local var_22_3

	if arg_22_2.ground ~= "random" then
		var_22_3 = stadiumconfig.getLocationEnum(arg_22_2.ground)
	else
		local var_22_4 = arg_22_1.groundInfo.ground

		var_22_3 = stadiumconfig.getLocationEnum(var_22_4)
	end

	local var_22_5 = var_22_2.northOffset or 0
	local var_22_6 = var_22_2.isIndoors or false
	local var_22_7 = true
	local var_22_8 = native.CareerDateTime.FromSystemTime()

	var_22_1:generateForecastFromSeed(arg_22_1.weatherForecast, var_22_3, var_22_8.month - 1, var_22_8.day, 1, 24, arg_22_1.startTime, arg_22_2.rain, var_22_7, arg_22_1.weatherType, var_22_6, var_22_5, arg_22_3.matchSeed)
end

function setupLobbyMatch(arg_23_0, arg_23_1, arg_23_2, arg_23_3, arg_23_4, arg_23_5, arg_23_6, arg_23_7, arg_23_8, arg_23_9, arg_23_10, arg_23_11)
	local var_23_0, var_23_1 = arg_23_5:getMatchSettings()
	local var_23_2 = arg_23_9:getRefereeManager()
	local var_23_3 = arg_23_9:getDecalManager()
	local var_23_4 = arg_23_9:getClubManager()
	local var_23_5 = arg_23_9:getPlayerManager()
	local var_23_6 = arg_23_9:getLeagueManager()

	processLobbySideInfo(arg_23_0, var_23_0, arg_23_0.homeTeamConfig, nil, "home", var_23_3, var_23_4, var_23_5, arg_23_5)
	processLobbySideInfo(arg_23_0, var_23_0, arg_23_0.awayTeamConfig, nil, "away", var_23_3, var_23_4, var_23_5, arg_23_5)

	local var_23_7
	local var_23_8
	local var_23_9
	local var_23_10

	if var_23_1.levelDataSerialisable then
		var_23_7, var_23_8, var_23_9, var_23_10 = var_23_1.levelName, var_23_1.levelDataSerialisable.levelData, var_23_1.decalIdMap, var_23_1.localLevel
	end

	local var_23_11 = arg_23_6.isDynasty

	if arg_23_6.matchID then
		local var_23_12 = arg_23_3:getParty():getPrimaryPartyMember()
		local var_23_13 = var_23_12.serverMatch

		arg_23_0.matchReportingMatchId = native.CMatchId.fromString(arg_23_6.matchID)

		if var_23_11 then
			arg_23_0.gameMode = VERIFY(arg_23_6.gameMode)

			arg_23_0.homeTeamConfig:setMatchDynastyCards(VERIFY(arg_23_6.homeDynastyCards))
			arg_23_0.awayTeamConfig:setMatchDynastyCards(VERIFY(arg_23_6.awayDynastyCards))

			local var_23_14 = arg_23_0.homeTeamConfig:getMatchDynastyCards()
			local var_23_15 = arg_23_0.awayTeamConfig:getMatchDynastyCards()

			var_23_13:fillAssetIdMapsFromDynastyCards(var_23_14, var_23_15)

			if arg_23_6.opponentBadge then
				arg_23_0.opponentBadge = arg_23_6.opponentBadge
			end

			if arg_23_6.badge then
				arg_23_0.badge = arg_23_6.badge
			end
		else
			local var_23_16 = arg_23_0.home.playerIds.asTable
			local var_23_17 = arg_23_0.away.playerIds.asTable

			var_23_13:fillAssetIdMapsDefault(var_23_16, var_23_17)
		end

		arg_23_9:profileSaveSettings(var_23_12)
		formatPrintT("setupLobbyMatch: matchInData.matchReportingMatchId = %t", arg_23_0.matchReportingMatchId)
	end

	addMatchSettings(arg_23_3, var_23_3, arg_23_0, arg_23_2, var_23_0, var_23_7, var_23_8, var_23_9, var_23_10, nil, arg_23_6)

	if arg_23_8 then
		arg_23_1:setMatchObjectives(arg_23_8)
	end

	if not arg_23_6.fakeMatch then
		setupReferees(arg_23_0, arg_23_2, var_23_2, var_23_3, arg_23_7.refereeIds, arg_23_6.sex)
	end

	addLobbyGamers(arg_23_0, arg_23_3, arg_23_5)

	if arg_23_6.isBeAPro then
		ASSERT(arg_23_6.beAProPlayerId ~= 0)
		ASSERT(arg_23_6.beAProPlayerId ~= nil)

		arg_23_0.beAProAssetId = arg_23_6.beAProPlayerId
	end

	processCommandLine(arg_23_0, arg_23_4)
	setupWeather(arg_23_3, arg_23_0, var_23_0, arg_23_2, arg_23_0.groundInfo.ground)
	finalise(arg_23_9, arg_23_0, arg_23_1, arg_23_2, arg_23_9:getDefaultTeamVisualManager(), arg_23_11, var_23_6, var_23_4)
end

function resumeMatch(arg_24_0, arg_24_1, arg_24_2, arg_24_3, arg_24_4, arg_24_5, arg_24_6, arg_24_7)
	local var_24_0 = arg_24_5:getDecalManager()

	arg_24_0:set(arg_24_3.matchInData)
	arg_24_1:set(arg_24_3.matchOutData)
	arg_24_2:set(arg_24_3.matchInProgressData)
	arg_24_0.homeTeamConfig:fillDecalDatabase(var_24_0, arg_24_7)
	arg_24_0.awayTeamConfig:fillDecalDatabase(var_24_0, arg_24_7)
	addLobbyGamers(arg_24_0, arg_24_4, arg_24_6)
end
