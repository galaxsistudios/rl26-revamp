import("base.side.sidehelper")
import("core.foundation.class")
import("design.playtheball_config")
import("game.scrum.scrum_helper")
import("game.player.playertype")
import("game.taprestart.taprestart_helper")
import("rules.intouch.intouch_request")
import("rules.fortytwenty.fortytwentyvariation_request")
import("rules.penalty.penalty")
import("rules.penalty.penaltytypes")
import("rules.playtheball.playtheballwipesetup_helper")
import("rules.restart.restart")
import("script-config.rules.rugby.intouch_config")
import("script-config.rules.rugby.scrum_config")
import("rules.rules.rulesenvironment_cconfig")

local var_0_0 = rulesenvironment_cconfig.cBoundaryConfig
local var_0_1 = {
	onFullTouchKickOffNRL2025 = function(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7, arg_1_8)
		table.insert(arg_1_8.requests, "inTouchRequest")

		arg_1_8.isInTouchInFull = true

		local var_1_0 = arg_1_5:getGameObject(arg_1_8.lastTouched):getPlayDir().x
		local var_1_1 = var_0_0.halfFieldWidth - 10
		local var_1_2 = var_1_0 == 1 and 10 or -10
		local var_1_3 = arg_1_8.outPosition.y > 0 and var_1_1 or -var_1_1

		arg_1_8.restartPosition = native.vec2(var_1_2, var_1_3)
		arg_1_8.inTouchOutcome = intouch_config.PlayTheBall

		return {
			"playTheBall"
		}
	end,
	onFullTouchLineDropOutNRL2025 = function(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8)
		table.insert(arg_2_8.requests, "inTouchRequest")

		arg_2_8.isInTouchInFull = true

		local var_2_0 = arg_2_3:getComponent("matchInData").matchType.zeroTackleOnTwentyMetreRestart
		local var_2_1 = var_0_0.halfFieldWidth - 10
		local var_2_2 = var_0_0.halfFieldLength - 10
		local var_2_3 = arg_2_5:getGameObject(arg_2_8.lastTouched):getPlayDir().x == 1 and -var_2_2 or var_2_2
		local var_2_4 = arg_2_8.outPosition.y > 0 and var_2_1 or -var_2_1

		arg_2_8.restartPosition = native.vec2(var_2_3, var_2_4)
		arg_2_8.inTouchOutcome = intouch_config.PlayTheBall

		return {
			"playTheBall"
		}
	end,
	onFullTouchLineDropOutSuperLeague2025 = function(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8)
		table.insert(arg_3_8.requests, "inTouchRequest")

		arg_3_8.isInTouchInFull = true
		arg_3_8.inTouchOutcome = intouch_config.PlayTheBall

		if arg_3_8.disposalOrigin then
			local var_3_0 = arg_3_8.disposalOrigin
			local var_3_1 = arg_3_8.outPosition
			local var_3_2 = arg_3_3:getSide(arg_3_8.offendingSide):getGoalPos()

			arg_3_8.restartPosition = var_3_2.x - var_3_1.x > var_3_2.x - var_3_0.x and restart.adjustRestartPositionInToFieldOfPlay(var_3_1, playtheball_config) or restart.adjustRestartPositionInToFieldOfPlay(var_3_0, playtheball_config)
		else
			arg_3_8.restartPosition = restart.adjustRestartPositionInToFieldOfPlay(arg_3_8.outPosition, playtheball_config)
		end

		return {
			"playTheBall"
		}
	end,
	onFullTouchGeneralGameplay = function(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7, arg_4_8)
		local var_4_0 = {}
		local var_4_1 = arg_4_3:getComponent("matchInData")
		local var_4_2 = var_4_1.matchType.name
		local var_4_3 = arg_4_8.disposalOrigin
		local var_4_4 = arg_4_3:getSide(arg_4_8.offendingSide):getGoalPos()
		local var_4_5 = arg_4_4:getMatchProgressionEntity()
		local var_4_6 = var_4_5.tackleCount
		local var_4_7 = var_4_1.matchType.maxTackleCount

		ASSERT(var_4_7)

		local var_4_8 = arg_4_4:getBallEntity():getDisposalInfo(arg_4_4, arg_4_6)

		if var_4_8 then
			if var_4_8.disposalType ~= native.EDisposalType.Collision or not var_4_8.originalDisposalType then
				local var_4_9 = var_4_8.disposalType
			end

			if var_4_8.disposalType ~= native.EDisposalType.Collision or not var_4_8.originalDisposalSubType then
				local var_4_10 = var_4_8.disposalSubType
			end

			local var_4_11 = arg_4_8.disposalType == native.EDisposalType.Collision and arg_4_8.disposalSubType == native.EDisposalSubType.PlayerBody
			local var_4_12 = true
			local var_4_13 = var_4_4.x - arg_4_8.outPosition.x < var_4_4.x - var_4_3.x
			local var_4_14 = arg_4_5:getGameObject(var_4_8.objectId, playertype.TypeId)

			if var_4_11 and var_4_12 and var_4_13 then
				arg_4_8.offendingSide = sidehelper.getOtherSide(var_4_14.side)
			end
		end

		local var_4_15 = var_4_3 or arg_4_8.outPosition
		local var_4_16 = var_4_5.tackleCount == var_4_7

		if var_4_16 then
			table.insert(var_4_0, "playTheBall")

			arg_4_8.inTouchOutcome = intouch_config.PlayTheBall
			arg_4_8.restartPosition = restart.adjustRestartPositionInToFieldOfPlay(var_4_15, playtheball_config)
		elseif var_4_2 == "SuperLeague" then
			table.insert(var_4_0, "scrum")

			arg_4_8.restartPosition = restart.adjustRestartPositionInToFieldOfPlay(var_4_15, scrum_config)
			arg_4_8.inTouchOutcome = intouch_config.Scrum
		else
			table.insert(var_4_0, "playTheBall")

			arg_4_8.inTouchOutcome = intouch_config.PlayTheBall
			arg_4_8.restartPosition = restart.adjustRestartPositionInToFieldOfPlay(var_4_15, playtheball_config, false, 20)
		end

		table.insert(arg_4_8.requests, "inTouchRequest")

		arg_4_8.isInTouchInFull = true
		arg_4_8.offenderId = arg_4_8.lastTouched

		table.insert(var_4_0, "refereeCameo")

		arg_4_8.refereeSignal = not var_4_16 and native.EUmpireSignalTypes.TapRestart or native.EUmpireSignalTypes.HandOver
		arg_4_8.touchJudgeSignal = native.EUmpireSignalTypes.InTouchOnFull

		return var_4_0
	end,
	onFullTouchKickOffSuperLeague2025 = function(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7, arg_5_8)
		arg_5_8.offenderId = arg_5_8.lastTouched
		arg_5_8.penaltyType = penaltytypes.infringementTypes.InTouchOnFull

		return {
			"penalty"
		}
	end
}
local var_0_2 = {
	tapRestart = function(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8)
		local var_6_0 = {
			nextState = arg_6_8.nextState or nil,
			restartSide = arg_6_8.restartSide or sidehelper.getOtherSide(arg_6_8.offendingSide),
			restartPosition = arg_6_8.restartPosition or native.vec2.Zero()
		}

		if arg_6_8.nextTackleIsZeroTackle == nil then
			-- block empty
		end

		var_6_0.nextTackleIsZeroTackle = arg_6_8.nextTackleIsZeroTackle
		var_6_0.randomSeed = arg_6_8.randomSeed or native.Random.FromSystemTime():nextAsSeed()

		print("[9464]  ruleactionhandler:initializeRuleAction: GetTapRestartState")

		return taprestart_helper.GetTapRestartState(var_6_0, arg_6_3, arg_6_4, arg_6_1, arg_6_7)
	end,
	playTheBall = function(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7, arg_7_8)
		local var_7_0 = {
			nextState = arg_7_8.nextState or nil,
			attackingSide = arg_7_8.restartSide or sidehelper.getOtherSide(arg_7_8.offendingSide),
			playTheBallPosition = arg_7_8.restartPosition or native.vec2.Zero(),
			newTackleCount = arg_7_8.newTackleCount or 0,
			randomSeed = arg_7_8.randomSeed or native.Random.FromSystemTime():nextAsSeed(),
			playTheBallKnowledge = arg_7_8.playTheBallKnowledge or arg_7_1.knowledgeBank.playTheBallKnowledge
		}

		print("[9464]  ruleactionhandler:initializeRuleAction: GetPlayTheBallWipeSetupState")

		return playtheballwipesetup_helper.GetPlayTheBallWipeSetupState(var_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7)
	end,
	scrum = function(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5, arg_8_6, arg_8_7, arg_8_8)
		local var_8_0 = {
			nextState = arg_8_8.nextState or nil,
			sideWithFeed = arg_8_8.restartSide or sidehelper.getOtherSide(arg_8_8.offendingSide),
			scrumPosition = arg_8_8.restartPosition or native.vec2.Zero(),
			randomSeed = arg_8_8.randomSeed or native.Random.FromSystemTime():nextAsSeed()
		}

		print("[9464]  ruleactionhandler:initializeRuleAction: GetScrumState")

		return scrum_helper.GetScrumState(var_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5, arg_8_6, arg_8_7)
	end,
	penalty = function(arg_9_0, arg_9_1, arg_9_2, arg_9_3, arg_9_4, arg_9_5, arg_9_6, arg_9_7, arg_9_8)
		local var_9_0 = {
			nextState = arg_9_8.nextState or nil,
			offendingSide = arg_9_8.offendingSide,
			offenderId = arg_9_8.offenderId,
			penaltyType = arg_9_8.penaltyType,
			penaltyAwardedToSide = arg_9_8.penaltyAwardedToSide or sidehelper.getOtherSide(arg_9_8.offendingSide),
			penaltyPosition = arg_9_8.penaltyPosition or native.vec2.Zero(),
			infringementTypes = arg_9_8.infringementTypes or penaltytypes.infringementTypes,
			refereeSignal = arg_9_8.refereeSignal or native.EUmpireSignalTypes.None
		}

		print("[9646] penalty.generatePenaltyAwardedState")

		return penalty.generatePenaltyAwardedState(arg_9_0, arg_9_1, arg_9_2, arg_9_3, arg_9_4, arg_9_5, arg_9_6, arg_9_7, var_9_0)
	end,
	idleallplayers = function(arg_10_0, arg_10_1, arg_10_2, arg_10_3, arg_10_4, arg_10_5, arg_10_6, arg_10_7, arg_10_8)
		local var_10_0 = {
			nextState = arg_10_8.nextState or nil,
			idleTime = arg_10_6,
			expireTime = arg_10_8.expireTime or arg_10_6 + 1.5,
			randomSeed = arg_10_8.randomSeed or native.Random.FromSystemTime():nextAsSeed(),
			enablePlayerSwitching = arg_10_8.enablePlayerSwitching or false,
			blockGamerSwitching = arg_10_8.blockGamerSwitching or false,
			activateStoppageTime = arg_10_8.activateStoppageTime == nil and true or arg_10_8.activateStoppageTime,
			guid = arg_10_2:alloc()
		}

		return class.instantiate("IdleAllPlayersRuleState", var_10_0)
	end,
	refereeCameo = function(arg_11_0, arg_11_1, arg_11_2, arg_11_3, arg_11_4, arg_11_5, arg_11_6, arg_11_7, arg_11_8)
		-- Out on the full: the cameo's tap restart / handover signal is a long
		-- penalty-style whistle after the touch whistle; show the player who put
		-- it out reacting instead.
		if arg_11_8.isInTouchInFull and arg_11_8.offenderId and arg_11_5:getGameObject(arg_11_8.offenderId) then
			return class.instantiate("InTouchReactionRuleState", {
				nextState = arg_11_8.nextState,
				playerId = arg_11_8.offenderId,
				randomSeed = arg_11_8.randomSeed or native.Random.FromSystemTime():nextAsSeed()
			})
		end

		local var_11_0 = {
			offendingSide = arg_11_8.offendingSide,
			refereeSignal = arg_11_8.refereeSignal,
			touchJudgeSignal = arg_11_8.touchJudgeSignal,
			restartSide = arg_11_8.restartSide or sidehelper.getOtherSide(arg_11_8.offendingSide),
			delayBeforeSignal = arg_11_8.delayBeforeSignal or 1.5,
			nextState = arg_11_8.nextState or nil,
			outPosition = arg_11_8.outPosition or native.vec2.Zero(),
			isVideoReferee = arg_11_8.isVideoReferee or false
		}

		return class.instantiate("RefereeCameoRuleState", var_11_0)
	end
}
local var_0_3 = {
	inTouchRequest = function(arg_12_0, arg_12_1, arg_12_2, arg_12_3, arg_12_4, arg_12_5, arg_12_6, arg_12_7, arg_12_8)
		local var_12_0 = {
			offendingSide = arg_12_8.offendingSide,
			inTouchOutcome = arg_12_8.inTouchOutcome,
			offenderId = arg_12_8.lastTouched,
			isDeadBall = arg_12_8.isDeadBall or false,
			outPosition = arg_12_8.outPosition or native.vec2.Zero(),
			restartSide = arg_12_8.restartSide or sidehelper.getOtherSide(arg_12_8.offendingSide),
			isInTouchInGoal = arg_12_8.isInTouchInGoal or nil,
			isInTouchOnFull = arg_12_8.isInTouchOnFull or nil
		}

		arg_12_7:add(intouch_request.InTouchRequest(var_12_0))
	end,
	fortyTwentyVariationRequest = function(arg_13_0, arg_13_1, arg_13_2, arg_13_3, arg_13_4, arg_13_5, arg_13_6, arg_13_7, arg_13_8)
		local var_13_0 = {
			restartSide = arg_13_8.offendingSide,
			outPosition = arg_13_8.outPosition,
			kicker = arg_13_8.lastTouched,
			gamerId = arg_13_8.gamerId,
			eventType = arg_13_8.eventType,
			restartPosition = arg_13_8.restartPosition or native.vec2.Zero()
		}

		arg_13_7:add(fortytwentyvariation_request.FortyTwentyVariationRequest(var_13_0))
	end
}

function processRuleAction(arg_14_0, arg_14_1, arg_14_2, arg_14_3, arg_14_4, arg_14_5, arg_14_6, arg_14_7, arg_14_8, arg_14_9)
	if arg_14_8.requests == nil then
		arg_14_8.requests = {}
	end

	local var_14_0 = tostring(arg_14_9)
	local var_14_1

	if var_0_1[var_14_0] ~= nil then
		var_14_1 = var_0_1[var_14_0](arg_14_0, arg_14_1, arg_14_2, arg_14_3, arg_14_4, arg_14_5, arg_14_6, arg_14_7, arg_14_8)
	else
		var_14_1 = {
			var_14_0
		}
	end

	processRequests(arg_14_0, arg_14_1, arg_14_2, arg_14_3, arg_14_4, arg_14_5, arg_14_6, arg_14_7, arg_14_8, arg_14_8.requests)
	table.insert(var_14_1, "idleallplayers")

	return (processRulestateRequests(arg_14_0, arg_14_1, arg_14_2, arg_14_3, arg_14_4, arg_14_5, arg_14_6, arg_14_7, arg_14_8, var_14_1))
end

function processRequests(arg_15_0, arg_15_1, arg_15_2, arg_15_3, arg_15_4, arg_15_5, arg_15_6, arg_15_7, arg_15_8, arg_15_9)
	for iter_15_0, iter_15_1 in ipairs(arg_15_9) do
		if var_0_3[iter_15_1] ~= nil then
			var_0_3[iter_15_1](arg_15_0, arg_15_1, arg_15_2, arg_15_3, arg_15_4, arg_15_5, arg_15_6, arg_15_7, arg_15_8)
		end
	end
end

function processRulestateRequests(arg_16_0, arg_16_1, arg_16_2, arg_16_3, arg_16_4, arg_16_5, arg_16_6, arg_16_7, arg_16_8, arg_16_9)
	for iter_16_0, iter_16_1 in ipairs(arg_16_9) do
		ASSERT(var_0_2[iter_16_1] ~= nil, "No action found")

		arg_16_8.nextState = var_0_2[iter_16_1](arg_16_0, arg_16_1, arg_16_2, arg_16_3, arg_16_4, arg_16_5, arg_16_6, arg_16_7, arg_16_8)
	end

	return arg_16_8.nextState
end
