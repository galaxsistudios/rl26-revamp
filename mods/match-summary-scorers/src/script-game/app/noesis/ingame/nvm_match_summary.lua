import("app.noesis.ns")
import("app.noesis.ns_viewmodel")
import("app.noesis.ns_observablecollection")
import("app.noesis.ingame.nvm_team_statistics")
import("app.match.stadium_helper")

local var_0_0 = "intermediatelua.visualconfig.stadium-cfg"
local var_0_1 = load(var_0_0)
local var_0_2 = ns_viewmodel.ViewModel
local var_0_3 = ns_observablecollection.ObservableCollection

ns.Class("NVMMatchSummary", var_0_2, function(arg_1_0)
	var_0_2.init(arg_1_0)

	arg_1_0.HomePlayers = var_0_3()
	arg_1_0.AwayPlayers = var_0_3()
	arg_1_0.HomePlayersTries = var_0_3()
	arg_1_0.AwayPlayersTries = var_0_3()
	arg_1_0.HomePlayersFieldGoals = var_0_3()
	arg_1_0.AwayPlayersFieldGoals = var_0_3()
	arg_1_0.HomePlayersFieldGoals40m = var_0_3()
	arg_1_0.AwayPlayersFieldGoals40m = var_0_3()
	arg_1_0.HomePlayersConversions = var_0_3()
	arg_1_0.AwayPlayersConversions = var_0_3()
	arg_1_0.HomePlayersPenalties = var_0_3()
	arg_1_0.AwayPlayersPenalties = var_0_3()
	-- match-summary-scorers: a scoring section is only shown when either team has an entry in it
	arg_1_0.ShowTries = false
	arg_1_0.ShowConversions = false
	arg_1_0.ShowFieldGoals = false
	arg_1_0.ShowFieldGoals40m = false
	arg_1_0.ShowPenaltyGoals = false
	arg_1_0.MatchLocation = ""
	arg_1_0.MatchAttendance = ""
	arg_1_0.MatchStatus = ""
	arg_1_0.Round = ""
end).Bindings = {
	Properties = {
		TeamStats = ns.typeOf(nvm_team_statistics.NVMTeamStatistics),
		HomePlayers = ns.typeOf(var_0_3),
		AwayPlayers = ns.typeOf(var_0_3),
		HomePlayersTries = ns.typeOf(var_0_3),
		AwayPlayersTries = ns.typeOf(var_0_3),
		HomePlayersFieldGoals = ns.typeOf(var_0_3),
		AwayPlayersFieldGoals = ns.typeOf(var_0_3),
		HomePlayersFieldGoals40m = ns.typeOf(var_0_3),
		AwayPlayersFieldGoals40m = ns.typeOf(var_0_3),
		HomePlayersConversions = ns.typeOf(var_0_3),
		AwayPlayersConversions = ns.typeOf(var_0_3),
		HomePlayersPenalties = ns.typeOf(var_0_3),
		AwayPlayersPenalties = ns.typeOf(var_0_3),
		ShowTries = ns.Bool,
		ShowConversions = ns.Bool,
		ShowFieldGoals = ns.Bool,
		ShowFieldGoals40m = ns.Bool,
		ShowPenaltyGoals = ns.Bool,
		MatchLocation = ns.String,
		MatchAttendance = ns.String,
		MatchStatus = ns.String,
		Round = ns.String
	}
}

function NVMMatchSummary.update(arg_2_0)
	arg_2_0.TeamStats:update()
end

function NVMMatchSummary.dispose(arg_3_0)
	var_0_2.dispose(arg_3_0)
end

function NVMMatchSummary.addPlayerToHomeTriesCollection(arg_4_0, arg_4_1)
	arg_4_0.HomePlayersTries:addItem(arg_4_1)
end

function NVMMatchSummary.addPlayerToAwayTriesCollection(arg_5_0, arg_5_1)
	arg_5_0.AwayPlayersTries:addItem(arg_5_1)
end

function NVMMatchSummary.addPlayerToHomeConversionsCollection(arg_6_0, arg_6_1)
	arg_6_0.HomePlayersConversions:addItem(arg_6_1)
end

function NVMMatchSummary.addPlayerToAwayConversionsCollection(arg_7_0, arg_7_1)
	arg_7_0.AwayPlayersConversions:addItem(arg_7_1)
end

function NVMMatchSummary.addPlayerToHomeFieldGoalsCollection(arg_8_0, arg_8_1)
	arg_8_0.HomePlayersFieldGoals:addItem(arg_8_1)
end

function NVMMatchSummary.addPlayerToAwayFieldGoalsCollection(arg_9_0, arg_9_1)
	arg_9_0.AwayPlayersFieldGoals:addItem(arg_9_1)
end

function NVMMatchSummary.addPlayerToHomeFieldGoals40mCollection(arg_10_0, arg_10_1)
	arg_10_0.HomePlayersFieldGoals40m:addItem(arg_10_1)
end

function NVMMatchSummary.addPlayerToAwayFieldGoals40mCollection(arg_11_0, arg_11_1)
	arg_11_0.AwayPlayersFieldGoals40m:addItem(arg_11_1)
end

function NVMMatchSummary.addPlayerToHomePenaltiesCollection(arg_12_0, arg_12_1)
	arg_12_0.HomePlayersPenalties:addItem(arg_12_1)
end

function NVMMatchSummary.addPlayerToAwayPenaltiesCollection(arg_13_0, arg_13_1)
	arg_13_0.AwayPlayersPenalties:addItem(arg_13_1)
end

function NVMMatchSummary.setMatchLocationText(arg_14_0, arg_14_1, arg_14_2, arg_14_3)
	local var_14_0 = arg_14_1.groundInfo
	local var_14_1 = var_14_0.ground == "random"
	local var_14_2 = var_14_0.ground == "creator"
	local var_14_3 = "???"

	if var_14_1 then
		var_14_3 = native.Localise("MatchSettings_Ground_Random")
	elseif var_14_2 then
		var_14_3 = var_14_0.groundInfo:getOption("customName")
	else
		local var_14_4 = VERIFY(var_0_1.Stadiums) or {}
		local var_14_5 = var_14_0.ground
		local var_14_6 = var_14_4[var_14_5]
		local var_14_7 = stadium_helper.getStadiumFromName(var_14_5)

		if var_14_6 and var_14_7 then
			local var_14_8 = var_14_6.locationEnum

			if not var_14_8 then
				arg_14_0.MatchLocation = string.format("%s", native.Localise(string.format("MatchSettings_Ground_%s", var_14_5)))

				native.breakpoint()

				return
			end

			local var_14_9 = native.Localise(string.format("Location_%s", var_14_8))
			local var_14_10 = arg_14_2:getLocationManager():getCountryOfCity(var_14_8)

			var_14_3 = string.format("%s, %s, %s", native.Localise(string.format("MatchSettings_Ground_%s", var_14_5)), var_14_9, native.Localise(string.format("Countries::%s", var_14_10)))
		end
	end

	arg_14_0.MatchLocation = var_14_3
end
