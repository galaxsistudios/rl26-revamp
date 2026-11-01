import("base.gamecontroller.gamecontroller")
import("base.side.sidehelper")
import("rules.penalty.penaltytypes")
import("rules.penalty.penaltyoptionselected_request")

local var_0_0 = penaltytypes.penaltyOptions
local var_0_1 = {
	{
		withinKickDistance = 40,
		withinTime = 10,
		trailingBy = native.CRange(-2, 0),
		decision = var_0_0.GoalKick
	},
	{
		withinKickDistance = 30,
		leadingBy = native.CRange(5, 6),
		trailingBy = native.CRange(-2, 0),
		decision = var_0_0.GoalKick
	},
	{
		withinTryDistance = 20,
		decision = var_0_0.TapRestart
	},
	{
		decision = var_0_0.KickToTouch
	}
}
local var_0_2 = gamecontroller.GameController

Class("PenaltySelectGameController", var_0_2, function(arg_1_0, arg_1_1)
	arg_1_0.sideAwardedPenalty = arg_1_1.sideAwardedPenalty
	arg_1_0.penaltyPosition = arg_1_1.penaltyPosition
	arg_1_0.penaltyFor = arg_1_1.penaltyFor
	arg_1_0.availableOptions = arg_1_1.availableOptions
	arg_1_0.infringementById = arg_1_1.infringementById
	arg_1_0.allowScrum = arg_1_1.allowScrum
end)

-- scrum-feed-control: cross / A packs the scrum again (only offered after an offside penalty off
-- a scrum; the rule state's ScrumRepackDetect does the rest).
local var_0_scrumInputs = {
	{
		"PlaceKick",
		"AcceptBallPosition"
	},
	{
		"Contest",
		"Collect"
	},
	{
		"AntVision",
		"Skip"
	}
}

local function var_0_scrumPressed(arg_gamer)
	for iter_0, iter_input in ipairs(var_0_scrumInputs) do
		local var_ok, var_event = pcall(function()
			return arg_gamer:getInputEvent(iter_input[1], iter_input[2])
		end)

		if var_ok and var_event then
			return true
		end
	end

	return false
end

function PenaltySelectGameController.onEnter(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9)
	return
end

function PenaltySelectGameController.update(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10)
	if arg_3_0.requestSent then
		return
	end

	local var_3_0 = arg_3_0.penaltyFor
	local var_3_1 = arg_3_0.infringementById
	local var_3_2 = arg_3_0.penaltyPosition
	local var_3_3 = arg_3_0.sideAwardedPenalty
	local var_3_4 = arg_3_0.availableOptions

	ASSERT(var_3_0)
	ASSERT(var_3_1)
	ASSERT(var_3_2)
	ASSERT(var_3_3)
	ASSERT(var_3_4)

	local var_3_5 = arg_3_2:getGamer(var_3_0)
	local var_3_6 = var_3_5 and var_3_5:getGamerId() or nil

	if var_3_5 then
		local var_3_7 = var_3_5:getInputEvent("PenaltySelect", "TapRestart")
		local var_3_8 = var_3_5:getInputEvent("PenaltySelect", "KickToTouch")
		local var_3_9 = var_3_5:getInputEvent("PenaltySelect", "PenaltyGoalAttempt")
		local var_3_10 = var_3_7 and var_0_0.TapRestart or var_3_8 and var_0_0.KickToTouch or var_3_9 and var_0_0.GoalKick
		local var_3_control = rawget(_G, "ScrumControlState")

		if not var_3_10 and arg_3_0.allowScrum and var_3_control and var_0_scrumPressed(var_3_5) then
			arg_3_3.uiServices:playSound("Select_No_Vib")
			print("[Penalty Select Human] - decision: scrum (scrum-feed-control repack)")

			var_3_control.repackChosen = true
			arg_3_0.requestSent = true

			return arg_3_0
		end

		if var_3_10 then
			arg_3_3.uiServices:playSound("Select_No_Vib")
			print("[Penalty Select Human] - decision: {1}" % {
				var_3_10
			})
			ASSERT(var_3_6)

			if not var_3_4[var_3_10] then
				print("[Penalty Select Human] - Warning: Selected disabled option")
			else
				arg_3_10:add(penaltyoptionselected_request.PenaltyOptionSelectedRequest(var_3_10, var_3_3, var_3_2, var_3_0, var_3_1, var_3_6))

				arg_3_0.requestSent = true
			end
		end
	else
		local var_3_11 = arg_3_5:getSide(var_3_3)
		local var_3_12 = var_3_11:getGoalPos()
		local var_3_13 = native.distance2(var_3_2, var_3_12)
		local var_3_14 = native.vec2(var_3_12.x, var_3_2.y)
		local var_3_15 = native.distance2(var_3_2, var_3_14)
		local var_3_16 = arg_3_5:getComponent("matchInfo"):getMatchSecondsRemaining(arg_3_6, arg_3_9) / 60
		local var_3_17 = native.ScoreInfo
		local var_3_18 = sidehelper.getOtherSide(var_3_3)
		local var_3_19 = arg_3_5:getComponent("matchInData")
		local var_3_20 = arg_3_6:getScoreEntity()
		local var_3_21 = (var_3_11 == sidehelper.home and var_3_17.getHomeScore(var_3_19, var_3_20) or var_3_17.getAwayScore(var_3_19, var_3_20)) - (var_3_18 == sidehelper.home and var_3_17.getHomeScore(var_3_19, var_3_20) or var_3_17.getAwayScore(var_3_19, var_3_20))
		local var_3_22 = var_0_0.TapRestart

		for iter_3_0, iter_3_1 in ipairs(var_0_1) do
			if (not iter_3_1.withinKickDistance or var_3_13 < iter_3_1.withinKickDistance) and (not iter_3_1.withinTryDistance or var_3_15 < iter_3_1.withinTryDistance) and (not iter_3_1.withinTime or var_3_16 < iter_3_1.withinTime) and (not iter_3_1.trailingBy and not iter_3_1.leadingBy or iter_3_1.trailingBy and iter_3_1.trailingBy:contains(var_3_21) or iter_3_1.leadingBy and iter_3_1.leadingBy:contains(var_3_21)) then
				var_3_22 = iter_3_1.decision

				break
			end
		end

		formatPrint("[Penalty Select AI] - kickDistance: %.2f, tryDistance: %.2f, timeLeft: %.2f, margin: %i, decision: %s", var_3_13, var_3_15, var_3_16, var_3_21, var_3_22)
		arg_3_10:add(penaltyoptionselected_request.PenaltyOptionSelectedRequest(var_3_22, var_3_3, var_3_2, var_3_0, var_3_1, var_3_6))

		arg_3_0.requestSent = true
	end

	return arg_3_0
end
