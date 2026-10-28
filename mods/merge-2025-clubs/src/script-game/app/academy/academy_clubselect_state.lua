import("core.foundation.func")
import("core.foundation.tablex")
import("uicore.uiutil")
import("game.ui.clubselect.clubselect_state")

local var_0_0 = native.getEnvironment():argExists("wantsortedleagues")

local function var_0_1(arg_1_0, arg_1_1)
	return arg_1_0:getClub(arg_1_1):getLineupIsValid_Academy(arg_1_0)
end

function adjustClubIdBy(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5)
	if arg_2_3 then
		local var_2_0 = arg_2_0:getLeague(arg_2_3)
		local var_2_1 = true

		return var_2_0:getRelativeClubId(arg_2_1, arg_2_4, arg_2_5, var_2_1, arg_2_2, false)
	else
		local var_2_2 = arg_2_0:getListOfLeaguelessClubIds(arg_2_1, arg_2_2)
		local var_2_3 = tablex.indexOf(var_2_2, arg_2_4)

		return var_2_2[uiutil.wrapIndex(var_2_3 + arg_2_5, 1, #var_2_2)]
	end
end

-- merge-2025-clubs: every league native getRelativeLeagueId cycles through
-- from arg_mc_2 (same filters), sorted by sort index. nil if there's no start.
local function var_mc_sortedLeagueIds(arg_mc_0, arg_mc_1, arg_mc_2, arg_mc_3, arg_mc_4, arg_mc_5)
	if not arg_mc_2 or not arg_mc_0:getLeague(arg_mc_2) then
		return nil
	end

	local var_mc_3 = {
		arg_mc_2
	}
	local var_mc_4 = {
		[arg_mc_2] = true
	}
	local var_mc_5 = arg_mc_2

	for iter_mc_1 = 1, 256 do
		var_mc_5 = arg_mc_0:getRelativeLeagueId(arg_mc_1, var_mc_5, 1, arg_mc_3, arg_mc_4, arg_mc_5)

		if not var_mc_5 or var_mc_4[var_mc_5] then
			break
		end

		var_mc_4[var_mc_5] = true

		table.insert(var_mc_3, var_mc_5)
	end

	local function var_mc_6(arg_mc_6)
		local var_mc_7 = arg_mc_0:getLeague(arg_mc_6)

		return var_mc_7 and var_mc_7.sortIndex or math.huge
	end

	table.sort(var_mc_3, function(arg_mc_7, arg_mc_8)
		local var_mc_8, var_mc_9 = var_mc_6(arg_mc_7), var_mc_6(arg_mc_8)

		if var_mc_8 ~= var_mc_9 then
			return var_mc_8 < var_mc_9
		end

		return arg_mc_7 < arg_mc_8
	end)

	return var_mc_3
end

function adjustLeagueIdBy(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7)
	local var_3_0 = true

	if arg_3_3 and arg_3_5 and arg_3_0:getRelativeLeagueIdIsLeagueless(arg_3_1, arg_3_5, arg_3_7, var_3_0, arg_3_2, arg_3_4) and arg_3_0:getDoAnyLeaguelessClubsExist(arg_3_1, arg_3_4) then
		local var_3_1 = arg_3_0:getListOfLeaguelessClubIds(arg_3_1, arg_3_4)
		local var_3_2 = assert(var_3_1[1])

		return nil, var_3_2
	else
		local var_3_3
		local var_3_4
		-- merge-2025-clubs: step through the leagues in sort index order (the
		-- order Quick Match's team select uses), not the native id order
		local var_mc_0 = var_mc_sortedLeagueIds(arg_3_0, arg_3_1, arg_3_5, var_3_0, arg_3_2, arg_3_4)
		local var_mc_1 = var_mc_0 and tablex.indexOf(var_mc_0, arg_3_5)
		local var_mc_2 = arg_3_7 < 0 and -1 or 1

		for iter_mc_0 = 1, var_mc_0 and #var_mc_0 or 0 do
			local var_3_5 = var_mc_0[uiutil.wrapIndex(var_mc_1 + var_mc_2 * iter_mc_0, 1, #var_mc_0)]
			local var_3_6 = arg_3_0:getLeague(var_3_5)

			if var_3_6.isVisibleInFrontEnd then
				var_3_4 = var_3_6:containsClub(arg_3_6) and arg_3_6 or var_3_6:getFirstClubId(arg_3_1)

				if arg_3_4 and not var_0_1(arg_3_1, var_3_4) then
					var_3_4 = adjustClubIdBy(arg_3_0, arg_3_1, arg_3_4, var_3_5, var_3_4, 1)
				end

				var_3_3 = var_3_5

				break
			end
		end

		while not var_3_3 do
			local var_3_5 = arg_3_0:getRelativeLeagueId(arg_3_1, arg_3_5, arg_3_7, var_3_0, arg_3_2, arg_3_4)

			if not var_3_5 then
				return arg_3_5, arg_3_6
			end

			local var_3_6 = arg_3_0:getLeague(var_3_5)

			if var_3_6.isVisibleInFrontEnd then
				var_3_4 = var_3_6:containsClub(arg_3_6) and arg_3_6 or var_3_6:getFirstClubId(arg_3_1)

				if arg_3_4 and not var_0_1(arg_3_1, var_3_4) then
					var_3_4 = adjustClubIdBy(arg_3_0, arg_3_1, arg_3_4, var_3_5, var_3_4, 1)
				end

				var_3_3 = var_3_5
			else
				arg_3_5 = var_3_5
			end
		end

		return var_3_3, var_3_4
	end
end

local var_0_2 = clubselect_state.ClubSelectState

Class("AcademyClubSelectState", var_0_2)

AcademyClubSelectState.AllowLeagueSelect = true
AcademyClubSelectState.WantRatingInfo = true
AcademyClubSelectState.LeagueMustBeAbleToContainFavouriteClub = true

local function var_mc_leagueSortKey(arg_mc_10)
	return arg_mc_10.league and arg_mc_10.league.sortIndex or math.huge
end

-- merge-2025-clubs: the base class steps LB/RB through validLeagueList, which
-- is in native id order unless the game runs with -wantsortedleagues
local function var_mc_sortValidLeagues(arg_mc_11)
	local var_mc_11 = arg_mc_11.validLeagueList

	if not var_mc_11 then
		return
	end

	for iter_mc_2, iter_mc_3 in ipairs(var_mc_11) do
		iter_mc_3.mcOrder = iter_mc_2
	end

	table.sort(var_mc_11, function(arg_mc_13, arg_mc_14)
		local var_mc_12, var_mc_13 = var_mc_leagueSortKey(arg_mc_13), var_mc_leagueSortKey(arg_mc_14)

		if var_mc_12 ~= var_mc_13 then
			return var_mc_12 < var_mc_13
		end

		return arg_mc_13.mcOrder < arg_mc_14.mcOrder
	end)
end

function AcademyClubSelectState.setInitialSelection(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4)
	var_mc_sortValidLeagues(arg_4_0)

	local var_4_0 = arg_4_1:getLeagueManager()
	local var_4_1 = arg_4_1:getClubManager()
	local var_4_2 = arg_4_4

	if arg_4_3 then
		arg_4_0.leagueId = arg_4_3
	else
		local var_4_3

		if not var_4_2 or var_4_2 == native.CClub.INVALID_CLUB_ID or not var_4_1:getClub(var_4_2) then
			-- merge-2025-clubs: default to NRL 2026 (stock: only with -wantsortedleagues)
			local var_4_4 = native.AcademyLeagues.League_NRL2026

			var_4_3 = var_4_0.onDisc:getLeagueIdBasedOff(var_4_4)

			local var_4_5 = var_4_3 and var_4_0:getLeague(var_4_3)

			var_4_2 = var_4_5 and var_4_5:getFirstClubId(var_4_1)
		else
			local var_4_6 = var_4_1:getClub(var_4_2)
			local var_4_7 = arg_4_0.LeagueMustBeAbleToContainFavouriteClub or false
			local var_4_8 = var_4_0.onDisc:getLeagueIdsContainingClub(var_4_6, var_4_7)

			var_4_3 = var_4_8 and var_4_8[1] or nil

			if not var_4_3 then
				local var_4_9 = var_4_0:getLeagueIdsContainingClub(var_4_6, var_4_7)

				var_4_3 = var_4_9 and var_4_9[1] or nil
			end
		end

		if not tablex.contains(arg_4_0.validLeagueList, var_4_3, function(arg_5_0, arg_5_1)
			return arg_5_0.id == arg_5_1
		end) then
			var_4_3 = arg_4_0.validLeagueList[1] and arg_4_0.validLeagueList[1].id
		end

		arg_4_0.leagueId = var_4_3
	end

	var_4_2 = var_4_2 or var_4_1:getOnDiscClubIds()[1]

	local var_4_10 = var_4_1:getClub(var_4_2)

	arg_4_0.showClubFn(arg_4_0.leagueId, var_4_10)

	local var_4_11 = arg_4_0.area:find("titleBoxLabel")

	if var_4_11 then
		if arg_4_0.leagueId then
			ASSERT(var_4_0)
			var_4_11:setText(var_4_0:getLeague(arg_4_0.leagueId).name)
		else
			var_4_11:setText(native.Localise("Leagueless"))
		end
	end

	ASSERT(#arg_4_0.validLeagueList > 0)

	arg_4_0.leagueIndex = func.find(function(arg_6_0, arg_6_1)
		return arg_6_1.id == arg_4_0.leagueId
	end, ipairs(arg_4_0.validLeagueList))
end

function AcademyClubSelectState.refreshClubInformation(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4)
	local var_7_0 = arg_7_2:getLeagueManager()
	local var_7_1 = arg_7_2:getPlayerManager()
	local var_7_2 = arg_7_0.sideInfo.menu.highlightedClub

	if not var_7_2 then
		return
	end

	local var_7_3 = var_7_2.clubId
	local var_7_4 = arg_7_0.leagueId
	local var_7_5 = var_7_4 and var_7_0:getLeague(var_7_4)

	if var_7_5 == arg_7_0.showingLeagueId and var_7_3 == arg_7_0.showingClubId and not arg_7_4 then
		return
	end

	if not var_7_5 or not var_7_5.name then
		local var_7_6 = native.Localise("LeaguelessClubsLeague")
	end

	local var_7_7, var_7_8 = var_7_2:getDisplayInfo_Academy(var_7_1)

	arg_7_0.showClubFn(var_7_4, var_7_2, var_7_7, var_7_8, arg_7_2:getDecalManager())

	arg_7_0.showingClubId = var_7_3
	arg_7_0.showingLeagueId = var_7_4
end

function AcademyClubSelectState.getPlayerModelInfo(arg_8_0, arg_8_1, arg_8_2)
	local var_8_0 = arg_8_1:getPlayerManager()
	local var_8_1 = arg_8_0.sideInfo.menu.highlightedClub

	if not var_8_1 then
		return
	end

	local var_8_2

	if var_8_1 and var_8_1.playerCount > 0 and var_8_1:getLineupCount() > 0 then
		local var_8_3 = var_8_1:getLineup(1):getSpecialRole(native.EClubLineupSpecialRole.Captain)

		if var_8_1:containsPlayer(var_8_3) then
			var_8_2 = var_8_0:getPlayer(var_8_3)
		else
			var_8_2 = var_8_0:getPlayer(var_8_1:getPlayerIdAt(1))
		end
	end

	arg_8_1.currentAcademyClub = var_8_1

	return var_8_1, var_8_2
end

function AcademyClubSelectState.scrollLeagueBy(arg_9_0, arg_9_1, arg_9_2, arg_9_3, arg_9_4, arg_9_5)
	local var_9_0 = arg_9_1:getLeagueManager()
	local var_9_1 = arg_9_1:getClubManager()
	local var_9_2 = true
	local var_9_3 = arg_9_0.LeagueMustBeAbleToContainFavouriteClub or false
	local var_9_4 = arg_9_0.LeaguelessClubsEnabled or false
	local var_9_5 = arg_9_0.ClubsMustHaveValidLineup or false
	local var_9_6, var_9_7 = adjustLeagueIdBy(var_9_0, var_9_1, var_9_3, var_9_4, var_9_5, arg_9_3, arg_9_4, arg_9_5)

	arg_9_0.leagueId = var_9_6

	arg_9_0.sideInfo.menu:highlightClubId(var_9_7)

	return true
end

function AcademyClubSelectState.scrollClubBy(arg_10_0, arg_10_1, arg_10_2, arg_10_3, arg_10_4, arg_10_5)
	arg_10_0.sideInfo.menu:scrollEnsureValid(arg_10_5)

	return true
end

function AcademyClubSelectState.setShowingClubAndLeagueId(arg_11_0, arg_11_1, arg_11_2)
	arg_11_0.leagueId = arg_11_1
	arg_11_0.clubId = arg_11_2
end
