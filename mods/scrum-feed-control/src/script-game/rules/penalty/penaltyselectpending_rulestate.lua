import("base.rulestate.rulestateclass")
import("base.side.sidehelper")
import("core.marshalling.types")
import("game.taprestart.taprestart_helper")
import("game.kicktotouch.kicktotouch_helper")
import("rules.penalty.penalty")
import("script-config.rules.rugby.penalty_config")
import("rules.penalty.penaltytypes")
import("rules.penaltygoal.penaltygoalsetup_request")
import("rules.sinbin.sinbinsystem")
import("rules.rules.rules")
import("game.penalty.penaltyselect_gamecontroller")
import("game.penaltygoal.penaltygoal_helper")
import("rules.penalty.penaltyselect_detect")
import("rules.penalty.penaltyselecttimeout_detect")
import("rules.time.timer_detect")
import("script-config.rules.rules.rulesenvironment")
import("rules.scrum.scrum_setup_rulestate")

local var_0_0 = rulesenvironment.halfFieldLength

rulestateclass.rulestateclass("PenaltySelectPendingRuleState", function(arg_1_0, arg_1_1)
	for iter_1_0, iter_1_1 in pairs(PenaltySelectPendingRuleState.MemberDefinitions) do
		arg_1_0[iter_1_0] = arg_1_1[iter_1_0]
	end
end).MemberDefinitions = {
	sideAwardedPenalty = types.Team,
	penaltyPosition = types.Vec2,
	penaltyFor = types.ObjectId,
	stopMatchTimeForPenaltySelect = types.Boolean,
	allowGoalKick = types.Boolean,
	timerEnabled = types.Boolean,
	infringementById = types.ObjectId
}
PenaltySelectPendingRuleState.HideBallMarkers = true
PenaltySelectPendingRuleState.HidePlayerMarkers = true

local function var_0_1(arg_2_0, arg_2_1)
	local var_2_0 = sidehelper.getOtherSide(arg_2_1)

	return (arg_2_0.sinBinSystem:checkAndResetPlayerPenalised(var_2_0))
end

function PenaltySelectPendingRuleState.switchingGetPriorityTargetForSide(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4)
	if arg_3_0.sideAwardedPenalty == arg_3_1 then
		return arg_3_0.penaltyFor
	end
end

function PenaltySelectPendingRuleState.getBlockSwitchingGamers(arg_4_0, arg_4_1)
	return true
end

function PenaltySelectPendingRuleState.apply(arg_5_0, arg_5_1, arg_5_2)
	return
end

function PenaltySelectPendingRuleState.hideHud(arg_6_0, arg_6_1)
	local var_6_0 = arg_6_1.hud and arg_6_1.hud.featureStack

	if var_6_0 then
		var_6_0:pop("penaltySelectHuman")
	end
end

-- scrum-feed-control: after an offside penalty off a scrum, the side awarded it can also pack
-- the scrum again at the same spot (SCRUM; ScrumRepackDetect in scrum_setup_rulestate.lua).
function PenaltySelectPendingRuleState.scrumRepackAllowed(arg_self)
	local var_control = rawget(_G, "ScrumControlState")

	return var_control ~= nil and var_control.repackOfferFor ~= nil and var_control.repackOfferFor(arg_self.sideAwardedPenalty) ~= nil
end

function PenaltySelectPendingRuleState.onEnterSolid(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7, arg_7_8, arg_7_9, arg_7_10)
	local var_7_0 = arg_7_2:getGamer(arg_7_0.penaltyFor)
	local var_7_1 = var_7_0 and var_7_0:getGamerId() or nil
	local var_7_2 = var_7_0 and var_7_0:isRemote() or nil
	local var_7_3 = penaltytypes.penaltyOptions
	local var_7_4 = {
		[var_7_3.GoalKick] = arg_7_0.allowGoalKick,
		[var_7_3.TapRestart] = true,
		[var_7_3.KickToTouch] = true
	}
	local var_7_5 = {
		sideAwardedPenalty = arg_7_0.sideAwardedPenalty,
		penaltyPosition = arg_7_0.penaltyPosition,
		penaltyFor = arg_7_0.penaltyFor,
		infringementById = arg_7_0.infringementById,
		availableOptions = var_7_4,
		allowScrum = arg_7_0:scrumRepackAllowed()
	}
	local var_7_6 = VERIFY(arg_7_1.gameControllerSet)

	ASSERT(not var_7_6:get("penaltySelect"))

	local var_7_7 = arg_7_7:getGameObject(arg_7_0.penaltyFor):hasAuthority(arg_7_6)

	if not var_7_6:get("penaltySelect") and var_7_7 then
		var_7_6:add("penaltySelect", penaltyselect_gamecontroller.PenaltySelectGameController(var_7_5))
	end

	local var_7_8 = arg_7_3.hud

	ASSERT(var_7_8)

	local var_7_9 = var_7_8.featureStack
	local var_7_10 = var_7_1 and not var_7_2

	if var_7_9 and var_7_10 then
		local var_7_11 = VERIFY(arg_7_5:getComponent("matchInData"))
		local var_7_12 = arg_7_0.sideAwardedPenalty

		var_7_9:push("penaltySelectHuman", {
			gamer = var_7_0,
			allowKick = arg_7_0.allowGoalKick,
			allowScrum = arg_7_0:scrumRepackAllowed(),
			sideAwardedPenalty = var_7_12
		})
	end
end

function PenaltySelectPendingRuleState.updateSolid(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5, arg_8_6, arg_8_7, arg_8_8, arg_8_9, arg_8_10, arg_8_11, arg_8_12)
	return
end

function PenaltySelectPendingRuleState.createRules(arg_9_0, arg_9_1, arg_9_2)
	local function var_9_0(arg_10_0, arg_10_1, arg_10_2, arg_10_3, arg_10_4, arg_10_5, arg_10_6, arg_10_7, arg_10_8)
		if arg_9_0.haveSentRulestateRequest then
			return
		end

		arg_9_0.haveSentRulestateRequest = true

		arg_9_0:hideHud(arg_10_1)

		local var_10_0 = arg_10_0:getGamer(arg_9_0.penaltyFor)

		if not arg_10_8.gamerId then
			local var_10_1

			var_10_1 = var_10_0 and var_10_0:getGamerId()
		end

		local var_10_2 = arg_10_8.sideAwardedPenalty or arg_9_0.sideAwardedPenalty
		local var_10_3 = arg_10_8.restartPosition or arg_9_0.penaltyPosition
		local var_10_4 = 10
		local var_10_5 = var_0_0 - var_10_4
		local var_10_6 = native.vec2(native.clamp1(var_10_3.x, -var_10_5, var_10_5), var_10_3.y)
		local var_10_7 = arg_10_4:getGamerSideEntity():isAnyGamerOnSide(sidehelper.getOtherSide(var_10_2))
		local var_10_8 = native.Random.FromSystemTime():nextAsSeed()
		local var_10_9 = {
			restartSide = var_10_2,
			restartPosition = var_10_6,
			randomSeed = var_10_8
		}
		local var_10_10 = taprestart_helper.GetTapRestartState(var_10_9, arg_10_3, arg_10_4, arg_10_1, arg_10_7)
		local var_10_11 = arg_10_3:getComponent("matchInData")

		return sinbinsystem.shouldPushSinBinCutscene(arg_10_1, var_10_10, var_10_11, arg_10_4, arg_10_5, arg_10_7, arg_10_2:alloc(), arg_9_0.infringementById)
	end

	local function var_9_1(arg_11_0, arg_11_1, arg_11_2, arg_11_3, arg_11_4, arg_11_5, arg_11_6, arg_11_7, arg_11_8)
		if arg_9_0.haveSentRulestateRequest then
			return
		end

		arg_9_0.haveSentRulestateRequest = true

		arg_9_0:hideHud(arg_11_1)

		local var_11_0 = arg_11_8.sideAwardedPenalty
		local var_11_1 = arg_11_4:getGamerSideEntity()
		local var_11_2 = var_11_1:isAnyGamerOnSide(var_11_0)
		local var_11_3 = var_11_1:isAnyGamerOnSide(sidehelper.getOtherSide(var_11_0))
		local var_11_4 = arg_11_8.restartPosition
		local var_11_5 = arg_11_8.gamerId

		if not var_11_2 then
			var_11_4 = penalty.adjustPenaltyGoalKickPosition(var_11_4)
		else
			var_11_4 = native.vec2(native.clamp1(var_11_4.x, -40, 40), var_11_4.y)
		end

		local var_11_6 = native.Random.FromSystemTime():nextAsSeed()
		local var_11_7 = {
			clampPosition = true,
			kickerSide = var_11_0,
			penaltyPosition = var_11_4
		}

		arg_11_7:add(penaltygoalsetup_request.PenaltyGoalSetupRequest(var_11_7))

		local var_11_8 = {
			clampPosition = true,
			takenFromPenalty = true,
			kickerSide = var_11_0,
			kickPosition = var_11_4,
			randomSeed = var_11_6,
			actionGuid = arg_11_2:alloc()
		}
		local var_11_9 = penaltygoal_helper.GetPenaltyGoalState(var_11_8, arg_11_3, arg_11_4, arg_11_1)
		local var_11_10 = arg_11_3:getComponent("matchInData")

		return sinbinsystem.shouldPushSinBinCutscene(arg_11_1, var_11_9, var_11_10, arg_11_4, arg_11_5, arg_11_7, arg_11_2:alloc(), arg_9_0.infringementById)
	end

	local function var_9_2(arg_12_0, arg_12_1, arg_12_2, arg_12_3, arg_12_4, arg_12_5, arg_12_6, arg_12_7, arg_12_8)
		if arg_9_0.haveSentRulestateRequest then
			return
		end

		arg_9_0.haveSentRulestateRequest = true

		arg_9_0:hideHud(arg_12_1)

		local var_12_0 = native.Random.FromSystemTime():nextAsSeed()
		local var_12_1 = {
			takenFromPenalty = true,
			kickerSide = arg_12_8.sideAwardedPenalty,
			kickPosition = arg_12_8.restartPosition,
			gamerId = arg_12_8.gamerId,
			randomSeed = var_12_0,
			actionGuid = arg_12_2:alloc()
		}
		local var_12_2 = kicktotouch_helper.GetKickToTouchState(var_12_1, arg_12_3, arg_12_4, arg_12_1, arg_12_7)
		local var_12_3 = arg_12_3:getComponent("matchInData")

		return sinbinsystem.shouldPushSinBinCutscene(arg_12_1, var_12_2, var_12_3, arg_12_4, arg_12_5, arg_12_7, arg_12_2:alloc(), arg_9_0.infringementById)
	end

	local var_9_3 = penaltytypes.penaltyOptions
	local var_9_4 = {
		[var_9_3.GoalKick] = arg_9_0.allowGoalKick,
		[var_9_3.TapRestart] = true,
		[var_9_3.KickToTouch] = true
	}
	local var_9_5 = rules.Rules()

	var_9_5:add(penaltyselect_detect.PenaltyOptionSelectedDetect(var_9_4, var_9_0, var_9_1, var_9_2))

	if arg_9_0:scrumRepackAllowed() then
		var_9_5:add(scrum_setup_rulestate.ScrumRepackDetect(arg_9_0))
	end
	formatPrint("[11712] TimerEnabled: %s", arg_9_0.timerEnabled)

	if arg_9_0.timerEnabled then
		local var_9_6 = penalty_config.penaltyOptionTimeOut
		local var_9_7 = arg_9_0.penaltyFor

		ASSERT(var_9_7)

		local var_9_8 = arg_9_2 + native.Time.FromSeconds(var_9_6)

		formatPrint("[11712] penaltyOptionTimeOut: %d, penaltyFor Id: %d, advanceTime: %0.2f, resetFactory: %s", var_9_6, var_9_7, var_9_8:ToSeconds(), var_9_0 ~= nil and "valid" or "invalid")
		var_9_5:add(penaltyselecttimeout_detect.PenaltySelectTimeoutDetect(var_9_8, var_9_7, var_9_0))
		var_9_5:add(timer_detect.TimerDetect({
			onlyShowOnline = true
		}, var_9_6, nil))
	end

	return var_9_5
end

function PenaltySelectPendingRuleState.onExitSolid(arg_13_0, arg_13_1, arg_13_2, arg_13_3, arg_13_4, arg_13_5, arg_13_6, arg_13_7, arg_13_8, arg_13_9, arg_13_10)
	-- scrum-feed-control: the repack offer is only for this penalty.
	local var_13_control = rawget(_G, "ScrumControlState")

	if var_13_control then
		var_13_control.repackOffer = nil
		var_13_control.repackChosen = nil
	end

	local var_13_0 = arg_13_3.hud

	VERIFY(var_13_0:getElement("countdowntimer")):hide()
end
