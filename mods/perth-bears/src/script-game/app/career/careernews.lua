import("base.side.sidehelper")
import("app.career.careerseasonsummary")

local var_0_0 = native.ECareerNewsType
local var_0_1 = native.ECareerNewsImportance
local var_0_2 = native.ECareerNewsHeadline
local var_0_3 = native.ENewsStringType
local var_0_4 = native.CareerCompetitionIdEnum

function clear(arg_1_0)
	arg_1_0.news:clear()
end

function addWelcomeToCareer(arg_2_0)
	local var_2_0 = var_0_3.WelcomeToCareer_Title
	local var_2_1 = var_0_3.NewsBlank

	arg_2_0.news:tryAddGenericItem(var_0_0.Inbox, arg_2_0.date, var_2_0, var_2_1, 0, var_0_2.Welcome, native.INVALID_CLUB_ID, var_0_4.CareerCompetitionCount, 0)
end

function addWelcomeToYear(arg_3_0)
	local var_3_0 = arg_3_0:getClubIdBeingControlled()
	local var_3_1 = arg_3_0:getCompetitionIdContainingClubId(var_3_0)
	local var_3_2 = var_0_3.WelcomeToYear_Title
	local var_3_3 = var_0_3.NewsBlank
	local var_3_4 = native.INVALID_PLAYER_ID
	local var_3_5 = arg_3_0.user

	if var_3_5.isCoach then
		var_3_3 = var_0_3.WelcomeToYear_Additional
	else
		var_3_4 = var_3_5.playerId
	end

	arg_3_0.news:tryAddGenericItem(var_0_0.Inbox, arg_3_0.date, var_3_2, var_3_3, 0, var_0_2.Welcome, var_3_0, var_3_1, 0, var_3_4)
end

function lookingForwardToSeasonPlayer(arg_4_0, arg_4_1)
	local var_4_0 = arg_4_0:getPlayer(arg_4_1)
	local var_4_1 = arg_4_0:getClubIdContainingPlayerId(arg_4_1)
	local var_4_2 = arg_4_0:getCompetitionIdContainingClubId(var_4_1)
	local var_4_3 = var_0_3.WelcomeToYear_Title_Player
	local var_4_4 = var_0_3.NewsBlank

	arg_4_0.news:tryAddGenericItem(var_0_0.NewsFeed, arg_4_0.date, var_4_3, var_4_4, 0, var_0_2.Welcome, var_4_1, var_4_2, 0)
end

local function var_0_5(arg_5_0, arg_5_1, arg_5_2, arg_5_3)
	local var_5_0 = arg_5_1:getClub(arg_5_3).id
	local var_5_1 = arg_5_0:getClub(var_5_0)
	local var_5_2 = arg_5_2:getScore(arg_5_1, arg_5_3)

	return var_5_1, var_5_2
end

function reportOnCompetitionComplete(arg_6_0, arg_6_1)
	local var_6_0 = careerseasonsummary.getCompetitionCompleteText(arg_6_0, arg_6_1, true)
	local var_6_1 = ""
	local var_6_2
	local var_6_3 = var_0_3.NewsBlank
	local var_6_4 = arg_6_1:getWinningClubInfo()
	local var_6_5 = arg_6_1.id

	if var_6_4 ~= 0 and var_6_4 ~= nil then
		var_6_2 = var_0_3.CompetitionComplete_Title
	else
		var_6_2 = var_0_3.CompetitionCompleteDraw_Title
	end

	arg_6_0.news:tryAddGenericItem(var_0_0.NewsFeed, arg_6_0.date, var_6_2, var_6_3, 0, var_0_2.FixtureReport, var_6_4 and var_6_4 or 0, var_6_5, 0)
end

function reportOnFixtureProgression(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6)
	local var_7_0 = arg_7_0:getClubIdBeingControlled()
	local var_7_1 = arg_7_0:getClub(var_7_0)
	local var_7_2 = arg_7_1.preSeasonFixtureIndex
	local var_7_3 = arg_7_1.finalsFxitureIndex
	local var_7_4 = arg_7_1:getFixture(arg_7_2)
	local var_7_5 = native.CareerLadder()
	local var_7_6 = arg_7_0:getMatchType(var_7_4.matchTypeIndex)

	arg_7_1:getLadder(var_7_5, arg_7_2)

	local var_7_7 = var_0_3.RoundReport_Title
	local var_7_8
	local var_7_9 = var_7_5:getClubEntry(var_7_0)
	local var_7_10 = var_7_4.roundCount

	-- perth-bears: the coached club isn't on this ladder (a club the career
	-- data doesn't schedule): log what the career holds and skip the round
	-- report instead of crashing in getCanMakeFinals
	if var_7_9 == nil then
		pcall(function()
			local var_7_11 = {}

			for iter_7_0 = 1, arg_7_1.clubCount do
				local var_7_12 = arg_7_1:getClubIdAt(iter_7_0)

				table.insert(var_7_11, tostring(var_7_12) .. (var_7_5:getClubEntry(var_7_12) and "" or "(no entry)"))
			end

			local var_7_13 = io.open("careerladder_debug.txt", "a")

			if var_7_13 then
				var_7_13:write(os.date("%Y-%m-%d %H:%M:%S"), string.format(" coached club %s (%s) not on the ladder: competition %s fixture %s/%s preseason %s finals %s rounds %s; clubs %s\n", tostring(var_7_0), tostring(var_7_1 and var_7_1.fullName), tostring(arg_7_1.id), tostring(arg_7_2), tostring(arg_7_1.fixtureCount), tostring(var_7_2), tostring(var_7_3), tostring(var_7_10), table.concat(var_7_11, " ")))
				var_7_13:flush()
				var_7_13:close()
			end
		end)

		return
	end

	if arg_7_6 then
		return
	elseif arg_7_5 then
		if arg_7_2 == var_7_2 or arg_7_2 == var_7_3 then
			return
		elseif arg_7_1:getCanMakeFinals(var_7_5, var_7_9, var_7_10) then
			var_7_8 = var_0_3.RoundReport_MadeFinals
		else
			var_7_8 = var_0_3.RoundReport_MissedFinals
		end
	elseif arg_7_4 then
		if arg_7_2 == arg_7_1.preSeasonFixtureIndex then
			return
		elseif arg_7_2 == arg_7_1.finalsFixtureIndex then
			return
		else
			var_7_8 = var_0_3.RoundReport_Basic
		end
	else
		return
	end

	arg_7_0.news:tryAddGenericItem(var_0_0.Inbox, arg_7_0.date, var_7_7, var_7_8, arg_7_3, var_0_2.RoundReport, var_7_0, arg_7_1.id, 0)
end

function reportOnMatch(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5)
	local var_8_0, var_8_1 = var_0_5(arg_8_0, arg_8_2, arg_8_3, sidehelper.home)
	local var_8_2, var_8_3 = var_0_5(arg_8_0, arg_8_2, arg_8_3, sidehelper.away)
	local var_8_4 = arg_8_2.groundInfo.groundDisplayName
	local var_8_5 = arg_8_0.user
	local var_8_6

	if var_8_5.isCoach then
		local var_8_7 = var_8_5:getAllCoachedTeams()

		for iter_8_0, iter_8_1 in ipairs(var_8_7) do
			if var_8_0.id == iter_8_1 or var_8_2.id == iter_8_1 then
				var_8_6 = iter_8_1
			end
		end
	else
		local var_8_8 = arg_8_2:getSideContainingPlayerId(arg_8_0.user.playerId)

		var_8_6 = var_8_8 == sidehelper.home and var_8_0.id or var_8_2.id

		if var_8_8 == sidehelper.none then
			var_8_6 = arg_8_0:getClubIdContainingPlayerId(var_8_5.playerId, var_8_0.type)
		end
	end

	ASSERT(var_8_6 ~= native.INVALID_CLUB_ID)
	ASSERT(var_8_6 == var_8_0.id or var_8_6 == var_8_2.id)

	local var_8_9 = var_8_6 == var_8_0.id and var_8_0 or var_8_2
	local var_8_10 = var_0_3.MatchReportTitle

	if arg_8_1.finalsFixtureIndex == arg_8_4 then
		var_8_10 = var_0_3.MatchReportFinalsTitle
	elseif arg_8_1.preSeasonFixtureIndex == arg_8_4 then
		var_8_10 = var_0_3.MatchReportPreseasonTitle
	end

	local var_8_11

	if var_8_1 == var_8_3 then
		var_8_11 = var_0_3.MatchReport_Draw
	else
		local var_8_12 = var_8_3 < var_8_1 and var_8_0 or var_8_2
		local var_8_13

		var_8_13 = var_8_3 < var_8_1 and var_8_2 or var_8_0

		if var_8_12.id == var_8_9.id then
			var_8_11 = var_0_3.MatchReport_Win
		else
			var_8_11 = var_0_3.MatchReport_Lose
		end
	end

	arg_8_0.news:tryAddGenericItem(var_0_0.NewsFeed, arg_8_0.date, var_8_10, var_8_11, arg_8_5, var_0_2.MatchReport, var_8_9.id, arg_8_1.id, 0)
end

function reportOnSquadSelectionStatus(arg_9_0, arg_9_1, arg_9_2, arg_9_3)
	ASSERT(arg_9_0.user.isPlayer)

	local var_9_0 = arg_9_1.competition
	local var_9_1 = arg_9_1.match
	local var_9_2 = arg_9_1.additionalInformation
	local var_9_3 = var_0_3.SquadSelection_Title
	local var_9_4

	if arg_9_3 then
		var_9_4 = var_0_3.SquadSelection_Additional_In
	else
		var_9_4 = var_0_3.SquadSelection_Additional_Out
	end

	arg_9_0.news:tryAddGenericItem(var_0_0.NewsFeed, arg_9_0.date, var_9_3, var_9_4, var_9_1.matchPoolIndex, var_0_2.SquadSelection, var_9_2, var_9_0.id, 0)
end

function reportOnUserCoachedPlayersInSelectedSquad(arg_10_0, arg_10_1, arg_10_2, arg_10_3)
	local var_10_0 = arg_10_1.competition
	local var_10_1 = arg_10_1.match
	local var_10_2 = arg_10_1.additionalInformation
	local var_10_3 = var_0_3.SquadSelection_Title
	local var_10_4 = var_0_3.UserCoachedPlayersIncludedInSelectedSquad

	arg_10_0.news:tryAddGenericItem(var_0_0.NewsFeed, arg_10_0.date, var_10_3, var_10_4, 0, var_0_2.SquadSelection, var_10_2, var_10_0.id, arg_10_3)
end

function reportOnLineupSelectionStatus(arg_11_0, arg_11_1, arg_11_2, arg_11_3, arg_11_4)
	local var_11_0 = arg_11_1.competition

	ASSERT(arg_11_0.user.isPlayer)

	local var_11_1 = var_0_3.LineupSelection_Title
	local var_11_2

	if arg_11_3 then
		var_11_2 = var_0_3.LineupSelection_Additional_In
	else
		var_11_2 = var_0_3.LineupSelection_Additional_Out
	end

	arg_11_0.news:tryAddGenericItem(var_0_0.NewsFeed, arg_11_0.date, var_11_1, var_11_2, arg_11_4, var_0_2.SquadSelection, arg_11_2, var_11_0.id, 0)
end

function gotPaid(arg_12_0, arg_12_1)
	assert(arg_12_0.user.isPlayer)

	local var_12_0 = var_0_3.PlayerGotPaid_Title
	local var_12_1 = var_0_3.PlayerGotPaid_Additional

	arg_12_0.news:tryAddGenericItem(var_0_0.Inbox, arg_12_0.date, var_12_0, var_12_1, 0, var_0_2.Salary, native.INVALID_CLUB_ID, var_0_4.CareerCompetitionCount, arg_12_1)
end

function signedNewContract(arg_13_0, arg_13_1)
	assert(arg_13_0.user.isPlayer)

	local var_13_0 = arg_13_0.user.playerId
	local var_13_1 = arg_13_0:getCompetitionIdContainingClubId(arg_13_1.fromClubId)
	local var_13_2 = var_0_3.ContractSigned_Title
	local var_13_3 = var_0_3.ContractSigned_Additional

	arg_13_0.news:tryAddGenericItem(var_0_0.NewsFeed, arg_13_0.date, var_13_2, var_13_3, 0, var_0_2.Contract, arg_13_1.fromClubId, var_13_1, arg_13_1.lengthInYears)
end

function sponsorBonusEarned(arg_14_0)
	local var_14_0 = arg_14_0.user.coachClubId
	local var_14_1 = arg_14_0:getCompetitionIdContainingClubId(var_14_0)
	local var_14_2 = arg_14_0.userSponsor

	assert(var_14_2)

	local var_14_3 = var_0_3.SponsorshipObjectiveComplete_Title
	local var_14_4 = var_0_3.ObjectiveComplete_Additional

	arg_14_0.news:tryAddGenericItem(var_0_0.Inbox, arg_14_0.date, var_14_3, var_14_4, 0, var_0_2.ObjectiveComplete, var_14_0, var_14_1, var_14_2.bonusAmount)
end

function judiciaryResult(arg_15_0, arg_15_1, arg_15_2, arg_15_3, arg_15_4, arg_15_5)
	local var_15_0 = arg_15_0.user
	local var_15_1 = native.INVALID_CLUB_ID
	local var_15_2 = var_0_4.CareerCompetitionCount

	if var_15_0.isCoach then
		var_15_1 = var_15_0.coachClubId
		var_15_2 = arg_15_0:getCompetitionIdContainingClubId(var_15_1)
	elseif var_15_0.isPlayer then
		local var_15_3 = var_15_0.playerId

		var_15_1 = arg_15_0:getClubIdContainingPlayerId(var_15_3)
		var_15_2 = arg_15_0:getCompetitionIdContainingClubId(var_15_1)
	end

	local var_15_4 = arg_15_4 and var_0_3.JudiciaryResult_Title_Guilty or var_0_3.JudiciaryResult_Title_NotGuilty
	local var_15_5 = arg_15_4 and var_0_3.JudiciaryResult_Additional_Guilty or var_0_3.JudiciaryResult_Additional_NotGuilty

	if arg_15_1.id == nil then
		return
	else
		arg_15_0.news:tryAddGenericItem(var_0_0.Inbox, arg_15_0.date, var_15_4, var_15_5, 0, var_0_2.Judiciary, var_15_1, var_15_2, arg_15_5 and arg_15_5 or 0, arg_15_1.id, arg_15_2:toInt())
	end
end

function competitionAwardsDecided(arg_16_0, arg_16_1, arg_16_2)
	local var_16_0 = VERIFY(arg_16_1.awardsType)
	local var_16_1 = arg_16_2[1]
	local var_16_2
	local var_16_3
	local var_16_4 = native.CareerAwardsType

	if var_16_0 == var_16_4.None then
		return
	elseif var_16_0 == var_16_4.Generic then
		var_16_2 = var_0_3.LeagueAwards_Generic_Title
		var_16_3 = var_0_3.LeagueAwards_Generic_Additional
	elseif var_16_0 == var_16_4.DallyM then
		var_16_2 = var_0_3.LeagueAwards_DallyM_Title
		var_16_3 = var_0_3.LeagueAwards_DallyM_Additional
	elseif var_16_0 == var_16_4.ManOfSteel then
		if arg_16_1.sex == native.CSex.Male then
			var_16_2 = var_0_3.LeagueAwards_ManOfSteel_Title
			var_16_3 = var_0_3.LeagueAwards_ManOfSteel_Additional
		else
			var_16_2 = var_0_3.LeagueAwards_WomanOfSteel_Title
			var_16_3 = var_0_3.LeagueAwards_WomanOfSteel_Additional
		end
	else
		ASSERT(false)
	end

	arg_16_0.news:tryAddGenericItem(var_0_0.NewsFeed, arg_16_0.date, var_16_2, var_16_3, 0, var_0_2.Awards, native.INVALID_CLUB_ID, arg_16_1.id, 0, var_16_1)
end
