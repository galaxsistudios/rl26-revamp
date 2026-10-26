import("base.rulestate.rulestateclass")
import("core.foundation.class")
import("core.marshalling.types")
import("script-config.rules.rugby.penaltygoal_config")
import("rules.penalty.penaltyselect")
import("rules.match.matchtime")
-- r25-imports: penalty talk
import("base.side.sidehelper")
import("game.cutscenes.cutsceneplayevent_request")

-- r25-imports (Rugby 25 expansion): before the penalty choice the referee sometimes has a word
-- with the offender (R25's cut RefereePenalty_01-04 scenes). Self-contained: needs no other mod.
--   PenaltyTalkCaptain (01, 03): referee, offender and the offending side's captain;
--     only when the offender isn't the captain.
--   PenaltyTalkSolo (02, 04): referee and offender.
-- No talk when the offender was sin-binned or sent off (their own cutscene follows the choice)
-- or, with referee-on-report installed, put on report (he gets the report close-up instead).
-- Online matches, practice and training keep the stock flow.
local PenaltyTalkChance = 50 -- percent of penalties that get a talk
local PenaltyTalkCaptainShare = 50 -- percent of talks that bring the captain in, when allowed

rulestateclass.rulestateclass("PenaltySelectSetupRuleState", function(arg_1_0, arg_1_1)
	for iter_1_0, iter_1_1 in pairs(PenaltySelectSetupRuleState.MemberDefinitions) do
		arg_1_0[iter_1_0] = arg_1_1[iter_1_0]
	end
end).MemberDefinitions = {
	uniquePlayGuid = types.Guid,
	sideAwardedPenalty = types.Team,
	penaltyPosition = types.Vec2,
	penaltyTakerId = types.ObjectId,
	infringmentType = types.SignedInteger,
	infringementById = types.ObjectId
}
PenaltySelectSetupRuleState.HideBallMarkers = true
PenaltySelectSetupRuleState.HidePlayerMarkers = true

function PenaltySelectSetupRuleState.getBlockSwitchingGamers(arg_2_0, arg_2_1)
	return true
end

function PenaltySelectSetupRuleState.switchingGetPriorityTargetForSide(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4)
	if arg_3_0.sideAwardedPenalty == arg_3_1 then
		return arg_3_0.penaltyTakerId
	end
end

function PenaltySelectSetupRuleState.apply(arg_4_0, arg_4_1, arg_4_2)
	matchtime.updateTime(arg_4_1, arg_4_2)
	matchtime.startStoppageTime(arg_4_1, arg_4_2)
end

-- r25-imports: which talk group (and captain) this penalty gets, or nil for none.
local function penaltyTalkFor(arg_state, arg_match, arg_gamestate)
	local var_offender = arg_state.infringementById

	if not var_offender then
		return nil
	end

	local var_matchInData = arg_match:getComponent("matchInData")

	if var_matchInData.onlineMultiplayer or var_matchInData.gameMode == native.EGameMode.Practice
		or arg_gamestate:getTrainingEntity().trainingActive then
		return nil
	end

	local var_penalty = arg_gamestate:getPenaltyEntity()

	if var_penalty.isSinBin or var_penalty.isSentOff then
		return nil, "sin bin / send-off"
	end

	-- referee-on-report records this penalty's offender when he goes on report
	local var_report = rawget(_G, "OnReportState")

	if var_report and var_report.reportedOffender == var_offender then
		return nil, "on report"
	end

	local var_random = native.Random.FromSystemTime()

	if var_random:next(0, 100) >= PenaltyTalkChance then
		return nil, "chance"
	end

	local var_offendingSide = sidehelper.getOtherSide(arg_state.sideAwardedPenalty)
	local var_captain = arg_match:getSide(var_offendingSide):getCaptainId()

	if var_captain and var_captain ~= var_offender and var_random:next(0, 100) < PenaltyTalkCaptainShare then
		return "PenaltyTalkCaptain", var_captain
	end

	return "PenaltyTalkSolo"
end

function PenaltySelectSetupRuleState.onEnterSolid(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7, arg_5_8, arg_5_9)
	local var_5_0 = arg_5_0.penaltyPosition
	local var_5_1 = arg_5_0.sideAwardedPenalty
	local var_5_2 = arg_5_0.penaltyTakerId
	local var_5_3 = true
	local var_5_4 = penaltygoal_config.goalKickEnableThreshold
	local var_5_5 = penaltyselect.allowGoalKickPenaltyOption(arg_5_5, arg_5_6, var_5_1, var_5_0, var_5_4)
	local var_5_6 = arg_5_5:getComponent("matchInfo"):getHumanInputTimerEnabled()
	local var_5_7 = {
		sideAwardedPenalty = var_5_1,
		penaltyPosition = var_5_0,
		penaltyFor = var_5_2,
		stopMatchTimeForPenaltySelect = var_5_3,
		allowGoalKick = var_5_5,
		timerEnabled = var_5_6,
		infringementById = arg_5_0.infringementById
	}

	arg_5_0.nextState = class.instantiate("PenaltySelectPendingRuleState", var_5_7)

	ASSERT(arg_5_0.nextState)

	-- r25-imports: the referee's word with the offender first, when it applies
	local var_5_ok, var_5_group, var_5_captain = pcall(penaltyTalkFor, arg_5_0, arg_5_5, arg_5_6)

	if var_5_ok and var_5_group then
		arg_5_0.nextState = class.instantiate("PenaltyTalkRuleState", {
			nextState = arg_5_0.nextState,
			playerId = arg_5_0.infringementById,
			captainId = var_5_captain or 0,
			cutsceneGroup = var_5_group,
			randomSeed = native.Random.FromSystemTime():nextAsSeed(),
			guid = arg_5_1.ruleStateGuidManager:alloc()
		})
	end
end

function PenaltySelectSetupRuleState.advanceRuleState(arg_6_0)
	ASSERT(arg_6_0.nextState)

	return arg_6_0.nextState
end

-- r25-imports: plays the talk (a PenaltyTalk* cutscene group) once the offender is out of the
-- tackle, like SinBinCutsceneRuleState. Targets: offender, referee (officials aren't cast
-- automatically; shouldPushSinBinCutscene passes him too) and, for PenaltyTalkCaptain, the captain.
rulestateclass.rulestateclass("PenaltyTalkRuleState", function(arg_7_0, arg_7_1)
	for iter_7_0, iter_7_1 in pairs(PenaltyTalkRuleState.MemberDefinitions) do
		arg_7_0[iter_7_0] = arg_7_1[iter_7_0]
	end
end).MemberDefinitions = {
	nextState = types.RuleState,
	playerId = types.ObjectId,
	captainId = types.ObjectId,
	cutsceneGroup = types.String("name"),
	randomSeed = types.Number,
	guid = types.Guid
}
PenaltyTalkRuleState.HidePlayerMarkers = true
PenaltyTalkRuleState.HideBallMarkers = true

function PenaltyTalkRuleState.onEnterSolid(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5, arg_8_6, arg_8_7, arg_8_8, arg_8_9, arg_8_10)
	local var_8_0 = arg_8_3.hud and arg_8_3.hud.featureStack

	if var_8_0 then
		var_8_0:push("cutscene")
	end
end

function PenaltyTalkRuleState.onExitSolid(arg_9_0, arg_9_1, arg_9_2, arg_9_3, arg_9_4, arg_9_5, arg_9_6, arg_9_7, arg_9_8, arg_9_9, arg_9_10)
	local var_9_0 = arg_9_3.hud and arg_9_3.hud.featureStack

	if var_9_0 then
		var_9_0:pop("cutscene")
	end
end

function PenaltyTalkRuleState.updateSolid(arg_10_0, arg_10_1, arg_10_2, arg_10_3, arg_10_4, arg_10_5, arg_10_6, arg_10_7, arg_10_8, arg_10_9, arg_10_10, arg_10_11)
	if arg_10_0.haveSentRulestateRequest then
		return
	end

	if not VERIFY(arg_10_3.network):isMaster() then
		return
	end

	if arg_10_6:getActiveTackleEntity():getTackleForId(arg_10_0.playerId) then
		return
	end

	arg_10_0.haveSentRulestateRequest = true

	local var_10_0 = {
		arg_10_0.playerId,
		(arg_10_6:getOfficialEntity():getRefereesIds())
	}

	if arg_10_0.captainId and arg_10_0.captainId ~= 0 then
		table.insert(var_10_0, arg_10_0.captainId)
	end

	arg_10_11:add(cutsceneplayevent_request.CutscenePlayEventRequest({
		cutsceneName = arg_10_0.cutsceneGroup,
		targetIds = var_10_0,
		hideIds = {},
		guid = arg_10_0.guid:derive(69),
		onFinishedState = arg_10_0.nextState,
		randomSeed = arg_10_0.randomSeed
	}))
end
