import("app.noesis.ns")
import("app.noesis.ns_viewmodel")
import("app.noesis.ns_observablecollection")
import("app.noesis.util.nvm_team")
import("sim.hud.hud_helper")

local var_0_0 = ns_viewmodel.ViewModel
local var_0_1 = ns_observablecollection.ObservableCollection

ns.Class("NVMEvent", var_0_0, function(arg_1_0)
	var_0_0.init(arg_1_0)

	arg_1_0.Text = " "
	arg_1_0.BGText = " "
	arg_1_0.VisualKey = "Default"
	arg_1_0.fallBackTeam = nvm_team.NVMTeam()
	arg_1_0.fallBackTeam.PrimaryColour = native.NsColor(8, 8, 8, 255)
	arg_1_0.fallBackTeam.SecondaryColour = native.NsColor(8, 8, 8, 255)
	arg_1_0.timer = 0
end).Bindings = {
	Properties = {
		Team = ns.typeOf(nvm_team.NVMTeam),
		Text = ns.String,
		BGText = ns.String,
		VisualKey = ns.String
	}
}

function NVMEvent.addNotification(arg_2_0, arg_2_1, arg_2_2, arg_2_3)
	arg_2_0.Team = nil
	arg_2_0.Text = arg_2_1
	arg_2_0.BGText = arg_2_1
	arg_2_0.VisualKey = arg_2_2 and "Score" or "Event"
	arg_2_0.Team = arg_2_3 or arg_2_0.fallBackTeam
end

function NVMEvent.update(arg_3_0, arg_3_1)
	if arg_3_0.VisualKey ~= "Default" then
		arg_3_0.timer = arg_3_0.timer + arg_3_1

		if arg_3_0.timer > 3 then
			arg_3_0.VisualKey = "Default"
			arg_3_0.timer = 0
		end
	end
end

function NVMEvent.dispose(arg_4_0)
	arg_4_0.fallBackTeam:dispose(true)
	var_0_0.dispose(arg_4_0)
end

ns.Class("NVMScoreCard", var_0_0, function(arg_5_0, arg_5_1, arg_5_2)
	var_0_0.init(arg_5_0)

	local var_5_0 = arg_5_2.stateOfTheSeason.competitionId
	local var_5_1 = {
		[native.CareerCompetitionIdEnum.League_SuperLeague] = "Mens",
		[native.CareerCompetitionIdEnum.League_BetfredChampionship] = "Championship",
		[native.CareerCompetitionIdEnum.League_BetfredLeague1] = "LeagueOne",
		[native.CareerCompetitionIdEnum.League_WSL] = "Womens"
	}

	arg_5_0.HomeTeam = hud_helper.getSideHudNVMTeam(arg_5_1, hud_helper.HOME_SIDE)
	arg_5_0.AwayTeam = hud_helper.getSideHudNVMTeam(arg_5_1, hud_helper.AWAY_SIDE)
	arg_5_0.EventViewDC = NVMEvent()
	arg_5_0.ElapsedSeconds = 55
	arg_5_0.TackleCounter = "ZERO"
	arg_5_0.HalfAbbr = ""
	arg_5_0.Notification = "NOTIFICATION"
	arg_5_0.sides = {
		arg_5_0.HomeTeam,
		arg_5_0.AwayTeam
	}
	arg_5_0.HomeScore = 0
	arg_5_0.AwayScore = 0
	arg_5_0.IsVisible = false
	arg_5_0.TackleCountVisiblity = false
	arg_5_0.MatchStateMessage = " "
	arg_5_0.ShowMatchState = false
	arg_5_0.ShowTryConfirmed = false
	arg_5_0.SuperLeagueType = var_5_1[var_5_0] or ""

	-- nrl-broadcast-scoreboard: interchange banner under the scoreboard (OFF / ON rows), set by
	-- showInterchange() from sim/hud/gameplayscore_hud.lua (mods/referee-on-report).
	arg_5_0.InterchangeTeam = arg_5_0.HomeTeam
	arg_5_0.InterchangeOffNumber = " "
	arg_5_0.InterchangeOffName = " "
	arg_5_0.InterchangeOnNumber = " "
	arg_5_0.InterchangeOnName = " "
	arg_5_0.ShowInterchange = false

	-- bunker-overturned-try: a new match HUD starts with no provisional try left over.
	local var_p_0 = rawget(_G, "ProvisionalTryState")

	if var_p_0 then
		var_p_0.points = nil
		var_p_0.side = nil
		var_p_0.replayPending = nil
	end
end).Bindings = {
	Properties = {
		HomeTeam = ns.typeOf(nvm_team.NVMTeam),
		AwayTeam = ns.typeOf(nvm_team.NVMTeam),
		EventViewDC = ns.typeOf(NVMEvent),
		ElapsedSeconds = ns.Single,
		TackleCounter = ns.String,
		HalfAbbr = ns.String,
		Notification = ns.String,
		HomeScore = ns.Int32,
		AwayScore = ns.Int32,
		IsVisible = ns.Bool,
		FadeOutTackleRed = ns.Bool,
		TackleCountVisiblity = ns.Bool,
		MatchStateMessage = ns.String,
		ShowMatchState = ns.Bool,
		SuperLeagueType = ns.String,
		ShowTryConfirmed = ns.Bool,
		InterchangeTeam = ns.typeOf(nvm_team.NVMTeam),
		InterchangeOffNumber = ns.String,
		InterchangeOffName = ns.String,
		InterchangeOnNumber = ns.String,
		InterchangeOnName = ns.String,
		ShowInterchange = ns.Bool
	}
}

-- nrl-broadcast-scoreboard: fills the interchange banner; side 1 home, 2 away.
function NVMScoreCard.showInterchange(arg_i_0, arg_i_1, arg_i_2, arg_i_3, arg_i_4, arg_i_5)
	arg_i_0.InterchangeTeam = arg_i_0.sides[arg_i_1] or arg_i_0.HomeTeam
	arg_i_0.InterchangeOffNumber = arg_i_2
	arg_i_0.InterchangeOffName = arg_i_3
	arg_i_0.InterchangeOnNumber = arg_i_4
	arg_i_0.InterchangeOnName = arg_i_5
	arg_i_0.ShowInterchange = true
end

function NVMScoreCard.hideInterchange(arg_h_0)
	arg_h_0.ShowInterchange = false
end

function NVMScoreCard.updateScores(arg_6_0, arg_6_1, arg_6_2)
	local var_6_0 = false

	-- bunker-overturned-try: a provisional try's points are shown but never added to the
	-- match score (see rules/try/tryattemptoutcomes.lua).
	local var_p_0 = rawget(_G, "ProvisionalTryState")

	for iter_6_0, iter_6_1 in ipairs(arg_6_0.sides) do
		local var_6_1 = arg_6_2:getScoreForSide(arg_6_1, iter_6_0)

		if var_p_0 and var_p_0.points and var_p_0.side == iter_6_0 then
			var_6_1 = var_6_1 + var_p_0.points
		end

		if var_6_1 ~= arg_6_0[(iter_6_0 == 1 and "Home" or "Away") .. "Score"] then
			arg_6_0[(iter_6_0 == 1 and "Home" or "Away") .. "Score"] = var_6_1
			var_6_0 = true
		end
	end

	return var_6_0
end

function NVMScoreCard.setTackleCount(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4)
	if arg_7_0.TackleCounter ~= arg_7_1 or arg_7_2 or arg_7_3 then
		if arg_7_1 > 0 then
			arg_7_0.TackleCountVisiblity = true

			if arg_7_1 == arg_7_4 then
				arg_7_0.FadeOutTackleRed = true
			elseif arg_7_4 < arg_7_1 then
				arg_7_0.TackleCountVisiblity = false
			else
				arg_7_0.FadeOutTackleRed = false
			end
		elseif arg_7_2 then
			arg_7_0.FadeOutTackleRed = false
			arg_7_0.TackleCountVisiblity = true
		else
			arg_7_0.FadeOutTackleRed = false
			arg_7_0.TackleCountVisiblity = false
		end

		if arg_7_1 == 0 then
			arg_7_1 = "ZERO"
		else
			local var_7_0 = "TH"

			if arg_7_1 < 10 or arg_7_1 > 20 then
				local var_7_1 = arg_7_1 % 10

				if var_7_1 == 1 then
					var_7_0 = "ST"
				elseif var_7_1 == 2 then
					var_7_0 = "ND"
				elseif var_7_1 == 3 then
					var_7_0 = "RD"
				end
			end

			arg_7_1 = arg_7_1 .. var_7_0
		end

		arg_7_0.TackleCounter = arg_7_1
	end
end

function NVMScoreCard.displayEventInfo(arg_8_0, arg_8_1, arg_8_2, arg_8_3)
	local var_8_0

	if arg_8_3 == 1 then
		var_8_0 = arg_8_0.HomeTeam
	elseif arg_8_3 == 2 then
		var_8_0 = arg_8_0.AwayTeam
	end

	formatPrint("[NVMScoreCard:displayEventInfo] text: %s, isScore: %s, side: %d", arg_8_1, arg_8_2 and "true" or "false", arg_8_3 or 0)
	arg_8_0.EventViewDC:addNotification(arg_8_1, arg_8_2, var_8_0)
end

function NVMScoreCard.setGoldenPointActive(arg_9_0, arg_9_1)
	arg_9_0.gp = arg_9_1
end

function NVMScoreCard.addYellowCard(arg_10_0, arg_10_1)
	arg_10_0.sides[arg_10_1]:addYellowCard()
end

function NVMScoreCard.removeYellowCard(arg_11_0, arg_11_1)
	arg_11_0.sides[arg_11_1]:removeYellowCard()
end

function NVMScoreCard.addRedCard(arg_12_0, arg_12_1)
	arg_12_0.sides[arg_12_1]:addRedCard()
end

-- bunker-broadcast-decision: no "Try Confirmed" banner under the scoreboard. The bunker card
-- already shows the decision. Set ShowTryConfirmedBanner = true for the stock banner.
local ShowTryConfirmedBanner = false

function NVMScoreCard.showTryConfirmed(arg_13_0)
	if not ShowTryConfirmedBanner then
		return
	end

	arg_13_0.ShowTryConfirmed = true
	arg_13_0.showTryConfirmedTimer = 4
end

function NVMScoreCard.update(arg_14_0, arg_14_1)
	arg_14_0.EventViewDC:update(arg_14_1)

	if arg_14_0.showTryConfirmedTimer then
		arg_14_0.showTryConfirmedTimer = arg_14_0.showTryConfirmedTimer - arg_14_1

		if arg_14_0.showTryConfirmedTimer <= 0 then
			arg_14_0.ShowTryConfirmed = false
			arg_14_0.showTryConfirmedTimer = nil
		end
	end
end

function NVMScoreCard.dispose(arg_15_0)
	var_0_0.dispose(arg_15_0)
end
