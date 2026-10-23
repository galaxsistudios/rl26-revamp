import("base.side.sidehelper")
import("core.foundation.class")
import("game.taprestart.taprestart_helper")
import("game.scrum.scrum_helper")
import("rules.intouch.intouch_request")
import("rules.match.matchtime")
import("rules.playtheball.playtheballwipesetup_helper")
import("rules.restart.restart")
import("rules.ruleactions.ruleactionhandler")
import("rules.rulestate.rulestate_request")
import("rules.taprestart.taprestart")
import("script-config.rules.rugby.intouch_config")
import("script-config.rules.rules.rulesenvironment")
import("script-config.rules.rugby.scrum_config")

local function var_0_0(arg_1_0, arg_1_1, arg_1_2)
	local var_1_0 = rulesenvironment.fieldLength * 0.5
	local var_1_1 = arg_1_0:getSide(arg_1_1):getGoalPos().x < 0

	return not var_1_1 and arg_1_2.x < -var_1_0 or var_1_1 and var_1_0 < arg_1_2.x
end

function inTouchOnFullRequestFactory(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8)
	local var_2_0 = native.Random.FromSystemTime():nextAsSeed()
	local var_2_1 = arg_2_4:getMatchTimeEntity()
	local var_2_2 = matchtime.canEndCurrentPeriod(arg_2_3, var_2_1)
	local var_2_3 = arg_2_1.knowledgeBank.playTheBallKnowledge

	ASSERT(var_2_3)

	local var_2_4

	if var_2_2 then
		local var_2_5 = {
			idleDuration = 1,
			endedWithScore = false,
			randomSeed = var_2_0
		}

		var_2_4 = class.instantiate("TimePeriodExpiredIdleRuleState", var_2_5)
	else
		local var_2_6 = arg_2_3:getComponent("matchInData").matchType.onFullTouchGeneralGameplayAction

		var_2_4 = ruleactionhandler.processRuleAction(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, var_2_6)
	end

	return rulestate_request.RuleStateRequest(var_2_4, arg_2_2:alloc())
end

function inTouchOnBounceRequestFactory(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8)
	local var_3_0 = native.Random.FromSystemTime():nextAsSeed()
	local var_3_1 = arg_3_4:getMatchTimeEntity()
	local var_3_2 = matchtime.canEndCurrentPeriod(arg_3_3, var_3_1)
	local var_3_3

	if var_3_2 then
		local var_3_4 = {
			idleDuration = 1,
			endedWithScore = false,
			randomSeed = var_3_0
		}

		var_3_3 = class.instantiate("TimePeriodExpiredIdleRuleState", var_3_4)
	else
		local var_3_5 = arg_3_8.offendingSide
		local var_3_6 = arg_3_8.outPosition
		local var_3_7 = arg_3_4:getMatchProgressionEntity().tackleCount
		local var_3_8 = arg_3_3:getComponent("matchInData")

		ASSERT(var_3_8)

		local var_3_9 = var_3_8.matchType

		ASSERT(var_3_9)

		local var_3_10 = var_3_9.name
		local var_3_11 = var_3_9.maxTackleCount

		ASSERT(var_3_11)

		local var_3_12 = var_3_11
		local var_3_13 = not var_3_8.matchType.usingScrums
		local var_3_14 = arg_3_2:alloc()
		local var_3_15 = arg_3_2:alloc()
		local var_3_16 = sidehelper.getOtherSide(var_3_5)
		local var_3_17 = intouch_config.Scrum
		local var_3_18 = {
			offendingSide = var_3_5,
			restartSide = var_3_16,
			outPosition = var_3_6,
			offenderId = arg_3_8.lastTouched,
			inTouchOutcome = var_3_17,
			isDeadBall = arg_3_8.isDeadBall,
			isInTouchInGoal = arg_3_8.isInTouchInGoal
		}

		arg_3_7:add(intouch_request.InTouchRequest(var_3_18))

		local var_3_19

		if var_3_13 then
			local var_3_20 = taprestart.getTapPositionFromOutPosition(arg_3_3, var_3_16, var_3_6)
			local var_3_21 = {
				restartSide = var_3_16,
				restartPosition = var_3_20,
				uniquePlayGuid = var_3_15,
				randomSeed = var_3_0
			}

			print("[9464] intouchoutcomes:inTouchOnBounceRequestFactory: GetTapRestartState")

			var_3_19 = taprestart_helper.GetTapRestartState(var_3_21, arg_3_3, arg_3_4, arg_3_1, arg_3_7)
		elseif var_3_10 == "NRL" then
			local var_3_22 = restart.adjustRestartPositionInToFieldOfPlay(var_3_6, scrum_config)
			local var_3_23 = {
				newTackleCount = 0,
				attackingSide = var_3_16,
				playTheBallPosition = var_3_22,
				randomSeed = var_3_0,
				playTheBallKnowledge = arg_3_1.knowledgeBank.playTheBallKnowledge
			}

			print("[9464] intouchoutcomes:inTouchOnBounceRequestFactory: GetPlayTheBallWipeSetupState")

			var_3_19 = playtheballwipesetup_helper.GetPlayTheBallWipeSetupState(var_3_23, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7)
		else
			local var_3_24 = restart.adjustRestartPositionInToFieldOfPlay(var_3_6, scrum_config)
			local var_3_25 = {
				scrumPosition = var_3_24,
				sideWithFeed = var_3_16,
				uniquePlayGuid = var_3_15,
				randomSeed = var_3_0
			}

			print("[9464] intouchoutcomes:inTouchOnBounceRequestFactory: GetScrumState")

			var_3_19 = scrum_helper.GetScrumState(var_3_25, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7)
		end

		local var_3_26 = rulestate_request.RuleStateRequest(var_3_19, arg_3_2:alloc())
		local var_3_27 = {
			isVideoReferee = false,
			delayBeforeSignal = 0.5,
			nextState = var_3_26,
			offendingSide = var_3_5,
			restartSide = var_3_16,
			outPosition = var_3_6,
			offenderId = arg_3_8.lastTouched,
			isDeadBall = arg_3_8.isDeadBall,
			isInTouchInGoal = arg_3_8.isInTouchInGoal,
			refereeSignal = not var_3_13 and native.EUmpireSignalTypes.Scrum or native.EUmpireSignalTypes.HandOver,
			touchJudgeSignal = native.EUmpireSignalTypes.InTouch
		}
		local var_3_28

		-- The cameo's handover/scrum signal is a second, long whistle after the
		-- touch whistle; show the player who put it out reacting instead.
		if arg_3_8.lastTouched and arg_3_5:getGameObject(arg_3_8.lastTouched) then
			var_3_28 = class.instantiate("InTouchReactionRuleState", {
				nextState = var_3_19,
				playerId = arg_3_8.lastTouched,
				randomSeed = var_3_0
			})
		else
			var_3_28 = class.instantiate("RefereeCameoRuleState", var_3_27)
		end

		local var_3_29 = {
			idlePeriod = 1.5,
			nextState = var_3_28,
			restartSide = var_3_16,
			outPosition = var_3_6,
			touchJudgeSignal = native.EUmpireSignalTypes.InTouch
		}

		var_3_3 = class.instantiate("InTouchIdlePlayersRuleState", var_3_29)
	end

	return rulestate_request.RuleStateRequest(var_3_3, arg_3_2:alloc())
end

function inTouchInGoalOnBounceRequestFactory(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7, arg_4_8)
	local var_4_0 = native.Random.FromSystemTime():nextAsSeed()
	local var_4_1 = arg_4_4:getMatchTimeEntity()
	local var_4_2 = matchtime.canEndCurrentPeriod(arg_4_3, var_4_1)
	local var_4_3

	if var_4_2 then
		local var_4_4 = {
			idleDuration = 1,
			endedWithScore = false,
			randomSeed = var_4_0
		}

		var_4_3 = class.instantiate("TimePeriodExpiredIdleRuleState", var_4_4)
	else
		local var_4_5 = arg_4_4:getMatchProgressionEntity()
		local var_4_6 = arg_4_8.offendingSide
		local var_4_7 = arg_4_8.outPosition
		local var_4_8 = arg_4_8.inDefensive50, var_4_5.tackleCount
		local var_4_9 = arg_4_3:getComponent("matchInData")

		ASSERT(var_4_9)

		local var_4_10 = var_4_9.matchType

		ASSERT(var_4_10)

		local var_4_11 = var_4_10.maxTackleCount

		ASSERT(var_4_11)

		local var_4_12 = var_4_11
		local var_4_13
		local var_4_14
		local var_4_15 = var_4_8 and intouch_config.LineDropOut or intouch_config.TapRestart
		local var_4_16 = arg_4_2:alloc()

		if var_4_8 then
			var_4_13 = var_4_6

			local var_4_17 = false
			local var_4_18 = {
				kickerSide = var_4_13,
				uniquePlayGuid = var_4_16,
				randomSeed = var_4_0,
				restartAtTwentyMetres = var_4_17,
				actionGuid = arg_4_2:alloc()
			}

			var_4_14 = class.instantiate("LineDropOutSetupRuleState", var_4_18)
		else
			var_4_13 = sidehelper.getOtherSide(var_4_6)

			local var_4_19 = taprestart.getTapPositionFromDeadBallInGoal(arg_4_3, var_4_13)
			local var_4_20 = arg_4_3:getComponent("matchInData")
			local var_4_21 = {
				restartAtTwentyMetres = true,
				restartSide = var_4_13,
				restartPosition = var_4_19,
				uniquePlayGuid = var_4_16,
				randomSeed = var_4_0,
				nextTackleIsZeroTackle = var_4_20.matchType.zeroTackleOnTwentyMetreRestart
			}

			var_4_14 = taprestart_helper.GetTapRestartState(var_4_21, arg_4_3, arg_4_4, arg_4_1, arg_4_7)
		end

		local var_4_22 = {
			offendingSide = var_4_6,
			restartSide = var_4_13,
			outPosition = var_4_7,
			inTouchOutcome = var_4_15,
			offenderId = arg_4_8.lastTouched,
			isDeadBall = arg_4_8.isDeadBall,
			isInTouchInGoal = arg_4_8.isInTouchInGoal
		}

		arg_4_7:add(intouch_request.InTouchRequest(var_4_22))

		local var_4_23 = {
			isVideoReferee = false,
			delayBeforeSignal = 1.5,
			nextState = var_4_14,
			randomSeed = var_4_0,
			offendingSide = var_4_6,
			restartSide = var_4_13,
			outPosition = var_4_7,
			inTouchOutcome = var_4_15,
			offenderId = arg_4_8.lastTouched,
			isDeadBall = arg_4_8.isDeadBall,
			isInTouchInGoal = arg_4_8.isInTouchInGoal,
			touchJudgeSignal = native.EUmpireSignalTypes.InTouchInGoal
		}
		local var_4_24 = class.instantiate("RefereeCameoRuleState", var_4_23)
		local var_4_25 = {
			idlePeriod = 1.5,
			nextState = var_4_24,
			restartSide = var_4_13,
			outPosition = var_4_7,
			touchJudgeSignal = native.EUmpireSignalTypes.InTouch
		}

		var_4_3 = class.instantiate("InTouchIdlePlayersRuleState", var_4_25)
	end

	return rulestate_request.RuleStateRequest(var_4_3, arg_4_2:alloc())
end

function inTouchInGoalOnFullRequestFactory(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7, arg_5_8)
	return inTouchInGoalOnBounceRequestFactory(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7, arg_5_8)
end

function fortyTwentyVariationRequestFactory(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8)
	local var_6_0 = native.Random.FromSystemTime():nextAsSeed()
	local var_6_1 = arg_6_4:getMatchTimeEntity()
	local var_6_2 = matchtime.canEndCurrentPeriod(arg_6_3, var_6_1)
	local var_6_3

	if var_6_2 then
		local var_6_4 = {
			idleDuration = 1,
			endedWithScore = false,
			randomSeed = var_6_0
		}

		var_6_3 = class.instantiate("TimePeriodExpiredIdleRuleState", var_6_4)
	else
		arg_6_8.restartPosition = restart.adjustRestartPositionInToFieldOfPlay(arg_6_8.outPosition, scrum_config)
		arg_6_8.restartSide = arg_6_8.offendingSide

		local var_6_5 = arg_6_3:getComponent("matchInData").matchType.fortyTwentyVariationAction

		arg_6_8.requests = {
			"fortyTwentyVariationRequest"
		}
		var_6_3 = ruleactionhandler.processRuleAction(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8, var_6_5)
	end

	return rulestate_request.RuleStateRequest(var_6_3, arg_6_2:alloc())
end
