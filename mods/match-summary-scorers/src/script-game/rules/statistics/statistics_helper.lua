import("app.noesis.ingame.nvm_match_summary")
import("app.noesis.ingame.nvm_player_statistics")
import("app.noesis.ingame.nvm_team_statistics")

ScoreStrings = {
	[4] = "Fours",
	[6] = "Sixes"
}

local var_0_0 = {
	battingStrikeRate = function(arg_1_0)
		local var_1_0 = arg_1_0.runsScored
		local var_1_1 = arg_1_0.ballsFaced

		if var_1_1 == 0 then
			return 0
		end

		return var_1_0 / var_1_1 * 100
	end,
	bowlingStrikeRate = function(arg_2_0)
		return arg_2_0.runsConceded / arg_2_0.wicketsTaken
	end,
	economyRate = function(arg_3_0)
		return arg_3_0.runsConceded / (arg_3_0.ballsBowled / 6)
	end
}

function GetStatistic(arg_4_0, arg_4_1)
	local var_4_0
	local var_4_1 = var_0_0[arg_4_0]

	if var_4_1 then
		var_4_0 = var_4_1(arg_4_1)
	else
		var_4_0 = arg_4_1[arg_4_0]
	end

	return var_4_0
end

PercentageStatsParamsMap = {
	possessionPercentage = function(arg_5_0, arg_5_1)
		local var_5_0 = arg_5_0.statistics.timeInPossession
		local var_5_1 = var_5_0 + arg_5_1.statistics.timeInPossession

		return var_5_0, var_5_1, "Stat_possessionPercentage"
	end,
	territoryPercentage = function(arg_6_0, arg_6_1)
		local var_6_0 = arg_6_0.statistics.timeInPossession
		local var_6_1 = var_6_0 + arg_6_1.statistics.timeInPossession
		local var_6_2 = arg_6_0.statistics.timeInDefensiveHalf
		local var_6_3 = arg_6_1.statistics.timeInDefensiveHalf

		return var_6_0 - var_6_2 + var_6_3, var_6_1, "Stat_territoryPercentage"
	end
}
CustomStatsParamsMap = {
	completionRate = function(arg_7_0, arg_7_1)
		local var_7_0 = arg_7_0.statistics.completions
		local var_7_1 = arg_7_0.statistics.sets
		local var_7_2 = arg_7_1.statistics.completions
		local var_7_3 = arg_7_1.statistics.sets
		local var_7_4 = string.format("%s/%s", var_7_0, var_7_1)
		local var_7_5 = string.format("%s/%s", var_7_2, var_7_3)

		return var_7_4, var_7_5, native.Localise("Stat_completionRate")
	end
}

function spairs(arg_8_0, arg_8_1)
	local var_8_0 = {}

	for iter_8_0 in pairs(arg_8_0) do
		var_8_0[#var_8_0 + 1] = iter_8_0
	end

	if arg_8_1 then
		table.sort(var_8_0, function(arg_9_0, arg_9_1)
			return arg_8_1(arg_8_0, arg_9_0, arg_9_1)
		end)
	else
		table.sort(var_8_0)
	end

	local var_8_1 = 0

	return function()
		var_8_1 = var_8_1 + 1

		if var_8_0[var_8_1] then
			return var_8_0[var_8_1], arg_8_0[var_8_0[var_8_1]]
		end
	end
end

local function var_0_1(arg_11_0)
	local var_11_0 = "("

	-- match-summary-scorers: list a player's minutes first to last (sorted copy, the source list is left alone)
	local var_sorted = {}

	for _, iter_time in ipairs(arg_11_0) do
		table.insert(var_sorted, iter_time)
	end

	table.sort(var_sorted, function(arg_a, arg_b)
		return (tonumber(arg_a) or math.huge) < (tonumber(arg_b) or math.huge)
	end)

	arg_11_0 = var_sorted

	for iter_11_0, iter_11_1 in ipairs(arg_11_0) do
		var_11_0 = var_11_0 .. tostring(iter_11_1) .. "'"

		if iter_11_0 ~= #arg_11_0 then
			var_11_0 = var_11_0 .. ", "
		end
	end

	return var_11_0 .. ")"
end

-- match-summary-scorers: order each scorer list by the minute of the player's first score
-- (stock sorted by count, and pairs() order made ties random)
local function firstScoreTime(arg_list)
	local var_first

	for _, iter_time in ipairs(arg_list) do
		local var_time = tonumber(iter_time)

		if var_time and (var_first == nil or var_time < var_first) then
			var_first = var_time
		end
	end

	return var_first or math.huge
end

local function byFirstScore(arg_field)
	return function(arg_players, arg_a, arg_b)
		local var_a = firstScoreTime(arg_players[arg_a][arg_field])
		local var_b = firstScoreTime(arg_players[arg_b][arg_field])

		if var_a ~= var_b then
			return var_a < var_b
		end

		local var_nameA = tostring(arg_players[arg_a].fullName)
		local var_nameB = tostring(arg_players[arg_b].fullName)

		if var_nameA ~= var_nameB then
			return var_nameA < var_nameB
		end

		return tostring(arg_a) < tostring(arg_b)
	end
end

local function var_0_2(arg_12_0, arg_12_1, arg_12_2)
	local var_12_0 = {}

	for iter_12_0, iter_12_1 in spairs(arg_12_0, byFirstScore("tries")) do
		print(iter_12_0, iter_12_1)
		table.insert(var_12_0, iter_12_1)
	end

	for iter_12_2, iter_12_3 in ipairs(var_12_0) do
		if #iter_12_3.tries ~= 0 then
			local var_12_1 = nvm_player_statistics.NVMPlayerStatistics()

			var_12_1.Tries = var_0_1(iter_12_3.tries)
			var_12_1.FullName = iter_12_3.fullName

			arg_12_1.ShowTries = true

			if arg_12_2 == "home" then
				arg_12_1:addPlayerToHomeTriesCollection(var_12_1)
			else
				arg_12_1:addPlayerToAwayTriesCollection(var_12_1)
			end
		end
	end

	local var_12_2 = {}

	for iter_12_4, iter_12_5 in spairs(arg_12_0, byFirstScore("conversions")) do
		print(iter_12_4, iter_12_5)
		table.insert(var_12_2, iter_12_5)
	end

	for iter_12_6, iter_12_7 in ipairs(var_12_2) do
		if #iter_12_7.conversions ~= 0 then
			local var_12_3 = nvm_player_statistics.NVMPlayerStatistics()

			var_12_3.Conversions = var_0_1(iter_12_7.conversions)
			var_12_3.FullName = iter_12_7.fullName

			arg_12_1.ShowConversions = true

			if arg_12_2 == "home" then
				arg_12_1:addPlayerToHomeConversionsCollection(var_12_3)
			else
				arg_12_1:addPlayerToAwayConversionsCollection(var_12_3)
			end
		end
	end

	local var_12_4 = {}

	for iter_12_8, iter_12_9 in spairs(arg_12_0, byFirstScore("fieldGoals")) do
		print(iter_12_8, iter_12_9)
		table.insert(var_12_4, iter_12_9)
	end

	for iter_12_10, iter_12_11 in ipairs(var_12_4) do
		if #iter_12_11.fieldGoals ~= 0 then
			local var_12_5 = nvm_player_statistics.NVMPlayerStatistics()

			var_12_5.FieldGoals = var_0_1(iter_12_11.fieldGoals)
			var_12_5.FullName = iter_12_11.fullName

			arg_12_1.ShowFieldGoals = true

			if arg_12_2 == "home" then
				arg_12_1:addPlayerToHomeFieldGoalsCollection(var_12_5)
			else
				arg_12_1:addPlayerToAwayFieldGoalsCollection(var_12_5)
			end
		end
	end

	local var_12_6 = {}

	for iter_12_12, iter_12_13 in spairs(arg_12_0, byFirstScore("fieldGoals40m")) do
		print(iter_12_12, iter_12_13)
		table.insert(var_12_6, iter_12_13)
	end

	for iter_12_14, iter_12_15 in ipairs(var_12_6) do
		if #iter_12_15.fieldGoals40m ~= 0 then
			local var_12_7 = nvm_player_statistics.NVMPlayerStatistics()

			var_12_7.FieldGoals40m = var_0_1(iter_12_15.fieldGoals40m)
			var_12_7.FullName = iter_12_15.fullName

			arg_12_1.ShowFieldGoals40m = true

			if arg_12_2 == "home" then
				arg_12_1:addPlayerToHomeFieldGoals40mCollection(var_12_7)
			else
				arg_12_1:addPlayerToAwayFieldGoals40mCollection(var_12_7)
			end
		end
	end

	local var_12_8 = {}

	for iter_12_16, iter_12_17 in spairs(arg_12_0, byFirstScore("penaltyGoals")) do
		print(iter_12_16, iter_12_17)
		table.insert(var_12_8, iter_12_17)
	end

	for iter_12_18, iter_12_19 in ipairs(var_12_8) do
		if #iter_12_19.penaltyGoals ~= 0 then
			local var_12_9 = nvm_player_statistics.NVMPlayerStatistics()

			var_12_9.PenaltyGoals = var_0_1(iter_12_19.penaltyGoals)
			var_12_9.FullName = iter_12_19.fullName

			arg_12_1.ShowPenaltyGoals = true

			if arg_12_2 == "home" then
				arg_12_1:addPlayerToHomePenaltiesCollection(var_12_9)
			else
				arg_12_1:addPlayerToAwayPenaltiesCollection(var_12_9)
			end
		end
	end

	for iter_12_20, iter_12_21 in pairs(arg_12_0) do
		if iter_12_21.stats then
			local var_12_10 = nvm_player_statistics.NVMPlayerStatistics()

			var_12_10.FullName = iter_12_21.fullName

			local var_12_11 = nvm_player_statistics.NVMPlayerStat(native.Localise("PreferredPositionAbbr"), native.Localise("Role" .. tostring(iter_12_21.role) .. "Abbr") or "")

			var_12_10.PlayerStatistics:addComponent(var_12_11)

			local var_12_12 = {
				"minutesPlayed",
				"metresRun",
				"passes",
				"tackles",
				"missedTackles",
				"tackleBreaks",
				"lineBreaks",
				"kicksInPlay",
				"kickMetresGained",
				"tryAssists",
				"handlingErrors",
				"penaltiesConceded",
				"tries",
				"conversions",
				"fieldGoals",
				"penaltyGoals",
				"fortyTwenties"
			}

			for iter_12_22, iter_12_23 in ipairs(var_12_12) do
				local var_12_13 = native.Localise(string.format("StatAbbr_%s", iter_12_23))
				local var_12_14 = nvm_player_statistics.NVMPlayerStat(var_12_13, iter_12_21.stats[iter_12_23])

				var_12_10.PlayerStatistics:addComponent(var_12_14)
			end

			if arg_12_2 == "home" then
				arg_12_1.HomePlayers:addComponent(var_12_10)
			else
				arg_12_1.AwayPlayers:addComponent(var_12_10)
			end
		end
	end
end

local function var_0_3(arg_18_0, arg_18_1, arg_18_2, arg_18_3)
	local var_18_0 = nvm_team_statistics.NVMTeamStat()

	ASSERT(arg_18_2 >= 0, "Negative statistic detected. Call over Brandon M to investigate")

	if arg_18_2 > 0 then
		local var_18_1 = arg_18_1 / arg_18_2

		if arg_18_2 < arg_18_1 then
			native.breakpoint()
			print("Negative statistic detected. Call over Brandon M to investigate")

			var_18_1 = 1
		end

		local var_18_2 = 100 * var_18_1
		local var_18_3 = var_18_2 <= 0.5 and 0 or var_18_2 > 50 and math.floor(var_18_2 + 0.5) or math.ceil(var_18_2 - 0.5)

		var_18_0.HomeValue = var_18_3 .. "%"
		var_18_0.AwayValue = 100 - var_18_3 .. "%"
	else
		var_18_0.HomeValue = 0
		var_18_0.AwayValue = 0
	end

	var_18_0.StatName = native.Localise(arg_18_3)

	arg_18_0:addStatisticsToCollection(var_18_0)
end

function getNVMStatSummary(arg_19_0, arg_19_1, arg_19_2, arg_19_3, arg_19_4, arg_19_5, arg_19_6, arg_19_7, arg_19_8, arg_19_9, arg_19_10)
	local var_19_0 = nvm_match_summary.NVMMatchSummary()

	var_0_2(arg_19_1, var_19_0, "home")
	var_0_2(arg_19_2, var_19_0, "away")

	local var_19_1 = arg_19_7.primaryRGBColour
	local var_19_2 = arg_19_8.primaryRGBColour
	local var_19_3 = arg_19_7.secondaryRGBColour
	local var_19_4 = arg_19_8.secondaryRGBColour
	local var_19_5 = nvm_team_statistics.NVMTeamStatistics(arg_19_0, arg_19_10)

	var_19_0.TeamStats = var_19_5
	var_19_5.HomeTeamScore = arg_19_3
	var_19_5.AwayTeamScore = arg_19_4
	var_19_5.HomeTeamName = arg_19_7.fullName
	var_19_5.HomeTeamShortName = arg_19_7.nickname
	var_19_5.HomeTeamColour = var_19_1
	var_19_5.AwayTeamName = arg_19_8.fullName
	var_19_5.AwayTeamShortName = arg_19_8.nickname
	var_19_5.AwayTeamColour = var_19_2

	for iter_19_0, iter_19_1 in ipairs(arg_19_9) do
		if PercentageStatsParamsMap[iter_19_1] then
			local var_19_6, var_19_7, var_19_8 = PercentageStatsParamsMap[iter_19_1](arg_19_5, arg_19_6)

			var_0_3(var_19_5, var_19_6, var_19_7, var_19_8)
		elseif CustomStatsParamsMap[iter_19_1] then
			local var_19_9, var_19_10, var_19_11 = CustomStatsParamsMap[iter_19_1](arg_19_5, arg_19_6)
			local var_19_12 = nvm_team_statistics.NVMTeamStat()

			var_19_12.HomeValue = var_19_9
			var_19_12.AwayValue = var_19_10
			var_19_12.StatName = var_19_11

			var_19_5:addStatisticsToCollection(var_19_12)
			var_19_12:dispose()
		else
			local var_19_13 = arg_19_5.statistics[iter_19_1] or arg_19_5["playerTotalStatistic_" .. iter_19_1]

			if var_19_13 then
				local var_19_14 = nvm_team_statistics.NVMTeamStat()

				var_19_14.HomeValue = var_19_13
				var_19_14.AwayValue = arg_19_6.statistics[iter_19_1] or arg_19_6["playerTotalStatistic_" .. iter_19_1]
				var_19_14.StatName = native.Localise("Stat_" .. iter_19_1)

				var_19_5:addStatisticsToCollection(var_19_14)
				var_19_14:dispose()
			end
		end
	end

	return var_19_0, var_19_5
end
