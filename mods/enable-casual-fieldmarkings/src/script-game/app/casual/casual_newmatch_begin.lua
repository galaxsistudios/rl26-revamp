import("app.transition.transition_strings")
import("app.match.matchin")

local var_0_0 = {
	[native.ETrophy.NRL] = {
		isGrandFinal = true,
		compId = native.CareerCompetitionIdEnum.League_NRL
	},
	[native.ETrophy.SuperLeague] = {
		isGrandFinal = true,
		compId = native.CareerCompetitionIdEnum.League_SuperLeague
	},
	[native.ETrophy.AnzacTest] = {
		isGrandFinal = true,
		compId = native.CareerCompetitionIdEnum.AnzacTest
	},
	[native.ETrophy.StateOfOrigin] = {
		isGrandFinal = true,
		compId = native.CareerCompetitionIdEnum.Tournament_StateOfOrigin
	},
	[native.ETrophy.ClubChallenge] = {
		isGrandFinal = true,
		compId = native.CareerCompetitionIdEnum.Torunament_WorldClubChallenge
	},
	[native.ETrophy.AucklandNines] = {
		isGrandFinal = true,
		compId = native.CareerCompetitionIdEnum.AucklandNines
	},
	[native.ETrophy.CustomOne] = {
		isGrandFinal = true,
		compId = native.CareerCompetitionIdEnum.NRL
	},
	[native.ETrophy.ChallengeCup] = {
		isGrandFinal = true,
		compId = native.CareerCompetitionIdEnum.Tournament_ChallengeCup
	},
	[native.ETrophy.QLDCup] = {
		isGrandFinal = true,
		compId = native.CareerCompetitionIdEnum.League_QLDCup
	},
	[native.ETrophy.IndigenousVsMaori] = {
		isGrandFinal = true,
		compId = native.CareerCompetitionIdEnum.Tournament_IndigenousVsMaori
	},
	[native.ETrophy.Ashes] = {
		isGrandFinal = true,
		compId = native.CareerCompetitionIdEnum.Tournament_Ashes
	},
	[native.ETrophy.NRLW] = {
		isGrandFinal = true,
		compId = native.CareerCompetitionIdEnum.League_NRLW
	},
	[native.ETrophy.WSL] = {
		isGrandFinal = true,
		compId = native.CareerCompetitionIdEnum.League_WSL
	},
	[native.ETrophy.StateOfOriginWomens] = {
		isGrandFinal = true,
		compId = native.CareerCompetitionIdEnum.Tournament_StateOfOriginWomens
	},
	[native.ETrophy.WomensChallengeCup] = {
		isGrandFinal = true,
		compId = native.CareerCompetitionIdEnum.Tournament_WomensChallengeCup
	},
	[native.ETrophy.BetfredChampionship] = {
		isGrandFinal = true,
		compId = native.CareerCompetitionIdEnum.League_BetfredChampionship
	},
	[native.ETrophy.EighteenNinteyFiveCup] = {
		isGrandFinal = true,
		compId = native.CareerCompetitionIdEnum.Tournament_EighteenNinteyFiveCup
	}
}

function beginMatch(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6)
	local var_1_0 = arg_1_3:getTransitionCreateParams()
	local var_1_1 = var_1_0.matchStateData

	var_1_1:reset()

	local var_1_2 = var_1_1.matchInData

	var_1_2.sex = arg_1_6.sex

	local var_1_3 = var_1_1.matchOutData
	local var_1_4 = var_1_1.matchInProgressData
	local var_1_5 = arg_1_4.partyMember

	if arg_1_6.resumingMatch then
		local var_1_6 = VERIFY(arg_1_6.newOrLoadData).saveData.matchSaveData

		matchin.resumeMatch(var_1_2, var_1_3, var_1_4, var_1_6, arg_1_0, arg_1_3, arg_1_5, true)
	else
		local var_1_7 = VERIFY(arg_1_6.localMatchSettings)
		local var_1_8 = VERIFY(arg_1_6.matchObjectives)
		local var_1_9 = var_1_7.trophyId
		local var_1_FMHandled = false

		if not var_1_9 and arg_1_6.matchSettingsSynchroniser then
			local var_1_FM = arg_1_6.matchSettingsSynchroniser:getMatchSettings().fieldMarkings

			if var_1_FM == native.MatchSettingsFieldMarkings.NRL_GrandFinal then
				var_1_2:casualMimicSeason(native.CareerCompetitionIdEnum.League_NRL, native.ETrophy.NRL, false)
				var_1_FMHandled = true
			elseif var_1_FM == native.MatchSettingsFieldMarkings.SuperLeague_GrandFinal then
				var_1_2:casualMimicSeason(native.CareerCompetitionIdEnum.League_SuperLeague, native.ETrophy.SuperLeague, false)
				var_1_FMHandled = true
			end
		end

		if var_1_FMHandled then
		elseif var_1_9 then
			local var_1_10 = VERIFY(var_0_0[var_1_9])

			var_1_2:casualMimicSeason(var_1_10.compId, var_1_9, var_1_10.isGrandFinal)
		elseif arg_1_6.compId then
			var_1_2:casualMimicSeason(arg_1_6.compId, native.ETrophy.NRL, false)
		end

		var_1_4.matchSeed = native.Random.FromSystemTime():nextAsSeed()
		var_1_2.gameMode = native.EGameMode.Casual

		matchin.setupLobbyMatch(var_1_2, var_1_3, var_1_4, arg_1_0, arg_1_2, arg_1_5, arg_1_6, var_1_7, var_1_8, arg_1_3, var_1_5)
	end

	var_1_2:setDayOfTheWeekFromFieldMarkings()

	if arg_1_6.usingOffensiveRef ~= nil then
		var_1_2.usingOffensiveRef = arg_1_6.usingOffensiveRef
	end

	local var_1_11 = var_1_0.frontendReturnParams

	arg_1_3:transitionEngineState(arg_1_0, arg_1_1, arg_1_2, {
		nextStateFactory = transition_strings.GameplayState,
		exitGameplayStateFactory = arg_1_3.exitGameplayStateFactory,
		frontEndSubStateFactory = arg_1_4.returnFromMatchFactory,
		partyMember = var_1_5
	})
end
