import("base.side.sidehelper")
import("core.foundation.class")
import("core.foundation.tablex")
import("game.injury.injury_helper")
import("rules.handover.handover")
import("rules.match.matchtime")
import("rules.match.resettacklecount_request")
import("rules.penalty.penalty")
import("rules.penalty.penaltytypes")
import("rules.playtheball.playtheballwipesetup_helper")
import("rules.playtheball.playtheballentity_request")
import("rules.sixagain.sixagain_request")
import("rules.sixagain.resetconsecutivesixagains_request")
import("rules.sixagain.resetsixagaininfringement_request")
import("rules.referee.refereedelaycallevent_request")
import("rules.rulestate.rulestate_request")
import("rules.tackle.tackledingoal_request")
import("script-config.rules.rules.rulesenvironment")
import("rules.try.tryscored_request")
import("script-config.design.cutscene_config")

-- bunker-overturned-try: shared state, see rules/try/tryattemptoutcomes.lua.
local function provisionalTry()
	local var_state = rawget(_G, "ProvisionalTryState")

	if not var_state then
		var_state = {}

		rawset(_G, "ProvisionalTryState", var_state)
	end

	return var_state
end

-- bunker-overturned-try: a held-up tackle in the in-goal is awarded as a try first. Issues the
-- provisional TryScoredRequest (scoreboard, replay moments, try presentation) and returns the
-- ReactToScore that starts the celebration, or nil to keep the stock flow.
local function provisionalHeldUpTry(arg_gamers, arg_services, arg_guids, arg_match, arg_gamestate, arg_gameobjects, arg_time, arg_requests, arg_event, arg_extra, arg_outcomeState, arg_seed)
	local var_state = provisionalTry()

	if not var_state.roll or not var_state.buildReview then
		return nil
	end

	if not var_state.roll(native.ETryAttemptOutcome.HeldUp, false, arg_match, arg_gamestate, "held-up tackle") then
		return nil
	end

	local var_scorer = arg_extra.heldUpId or arg_event.maker or arg_event.attemptById
	local var_scorerObject = var_scorer and arg_gameobjects:getGameObject(var_scorer)

	if not var_scorerObject then
		if var_state.log then
			var_state.log("held-up tackle: no scorer object, stock flow")
		end

		return nil
	end

	local var_side = var_scorerObject.side
	local var_position = arg_event.position or var_scorerObject.pos
	local var_assetId = arg_match:getSide(var_side).assetIdMap[var_scorer]
	local var_gamerId = arg_gamers:getGamerIdFor(var_scorer)
	local var_progression = arg_gamestate:getMatchProgressionEntity()
	local var_scoreTime = arg_match:getComponent("matchInfo"):getMatchSecondsElapsed(arg_gamestate, arg_time)

	local var_matchInData = arg_match:getComponent("matchInData")

	local var_reactToScore = class.instantiate("ReactToScoreRuleState", {
		isBonusTry = false,
		quickCutToCutscene = false,
		decisionPending = false,
		unsuccessfulAttempt = false,
		maxDelayBeforeCutscene = cutscene_config.MaxTimeToDelayBeforeEnteringCutscene,
		minDelayBeforeCutscene = cutscene_config.MinTimeToDelayBeforeEnteringCutscene,
		randomSeed = arg_seed,
		scoringSide = var_side,
		scoringGamer = var_gamerId,
		scorer = var_scorer,
		scorePosition = var_position,
		tryAttemptOutcome = native.ETryAttemptOutcome.Try,
		playCheerleaderCameo = not var_matchInData.isWorldCup and (var_matchInData.cutsceneInfo.playGFIntroCutscene or var_side == sidehelper.home),
		nextState = var_state.buildReview(arg_outcomeState, var_scoreTime, nil)
	})

	if var_state.snapshotPlayers then
		var_state.snapshotPlayers(arg_gameobjects, var_position)
	end

	arg_requests:add(tryscored_request.TryScoredRequest({
		diveOnLooseBall = false,
		divingTry = false,
		canEndCurrentPeriod = false,
		videoRefereeRequired = true,
		isKnockOn = false,
		isBonusTry = false,
		isDropDownTry = false,
		provisionalTry = true,
		assetId = var_assetId,
		scorer = var_scorer,
		scoringSide = var_side,
		scoringPosition = var_position,
		tryAttemptOutcome = native.ETryAttemptOutcome.HeldUp,
		currentTackleCount = var_progression.tackleCount,
		tackleSetStartPosition = var_progression.tackleSetStartPosition,
		gamerId = var_gamerId,
		scoreTime = var_scoreTime
	}))

	return var_reactToScore
end

function tackledInGoalRequestFactory(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7, arg_1_8)
	local var_1_0 = {
		tackledSide = arg_1_8.tackledSide,
		primaryTacklerId = arg_1_8.primaryTacklerId,
		targetId = arg_1_8.tackledId,
		position = arg_1_8.position
	}

	arg_1_7:add(tackledingoal_request.TackledInGoalRequest(var_1_0))

	local var_1_1 = native.Random.FromSystemTime():nextAsSeed()
	local var_1_2 = arg_1_4:getMatchTimeEntity()
	local var_1_3 = matchtime.canEndCurrentPeriod(arg_1_3, var_1_2)
	local var_1_4

	if var_1_3 then
		local var_1_5 = {
			idleDuration = 1,
			endedWithScore = false,
			randomSeed = var_1_1
		}

		var_1_4 = class.instantiate("TimePeriodExpiredIdleRuleState", var_1_5)
	else
		local var_1_6 = {
			restartAtTwentyMetres = false,
			kickerSide = arg_1_8.tackledSide,
			actionGuid = arg_1_2:alloc()
		}
		local var_1_7 = class.instantiate("LineDropOutSetupRuleState", var_1_6)
		local var_1_8 = {
			activateStoppageTime = true,
			lineDropOut = true,
			enablePlayerSwitching = false,
			blockGamerSwitching = false,
			expireTime = arg_1_6 + 1,
			randomSeed = var_1_1,
			nextState = var_1_7,
			guid = arg_1_2:alloc(),
			idleTime = arg_1_6
		}

		var_1_4 = class.instantiate("IdleAllPlayersRuleState", var_1_8)
	end

	local var_1_9 = {
		refereeEvent = "RefereeCalledTackledInGoalEvent",
		triggerTime = arg_1_8.tackleEndTime or arg_1_6,
		offendingSide = arg_1_8.tackledSide,
		targetId = arg_1_8.tackledId
	}

	arg_1_7:add(refereedelaycallevent_request.RefereeDelayCallEventRequest(var_1_9))
	arg_1_7:addRuleStateRequest(var_1_4, arg_1_2:alloc())
end

function playTheBallRuleStateRequestFactory(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7)
	local var_2_0 = arg_2_1.knowledgeBank.playTheBallKnowledge
	local var_2_1 = arg_2_4:getMatchProgressionEntity()
	local var_2_2 = var_2_1.attackingSide
	local var_2_3 = var_2_0.playTheBallId
	local var_2_4 = arg_2_4:getActiveTackleEntity()

	if var_2_4 == nil then
		formatPrint("[playTheBallRuleStateRequestFactory] activeTackleEntity is nil....skipping PlayTheBallSetupRuleState request")

		return
	end

	local var_2_5 = var_2_4:getTackleForTackleeId(var_2_3)

	if not var_2_5 then
		local var_2_6 = var_2_0.activeTackleId

		if not var_2_6 then
			formatPrint("[playTheBallRuleStateRequestFactory] No longer in active tackle or activeTackleEntity has been cleared...skipping PlayTheBallSetupRuleState request.")

			return
		end

		ASSERT(var_2_6)

		var_2_5 = var_2_4:getTackle(var_2_6)
	end

	ASSERT(var_2_5)

	if not var_2_5 then
		formatPrint("[playTheBallRuleStateRequestFactory] activeTackle is nil....skipping PlayTheBallSetupRuleState request")

		return
	end

	local var_2_7 = var_2_5:getParticipantId(native.ETackleParticipantType.Tackler1)
	local var_2_8 = native.Random.FromTimeValue(arg_2_6)
	local var_2_9, var_2_10 = injury_helper.evaluateInjuries(arg_2_1, arg_2_3, var_2_2, var_2_3, var_2_7, arg_2_4, arg_2_5, var_2_8, arg_2_7)
	local var_2_11
	local var_2_12 = var_2_4:getTackleBlock(var_2_5.tackleGuid, var_2_5.activeBlockGuid)
	local var_2_13 = sidehelper.getOtherSide(var_2_2)
	local var_2_14 = var_2_12.startPosition
	local var_2_15 = penaltytypes.infringementTypes
	local var_2_16 = penaltytypes.infringementTypes.HeldInTackle
	local var_2_17 = native.EUmpireSignalTypes.HeldInTackle
	local var_2_18 = arg_2_5:getGameObject(var_2_7):getPlayDir().x
	local var_2_19 = {
		offendingSide = var_2_13,
		penaltyPosition = var_2_14,
		offenderId = var_2_7,
		penaltyAwardedToSide = var_2_2,
		infringementTypes = var_2_15,
		penaltyType = var_2_16,
		refereeSignal = var_2_17
	}
	local var_2_20 = arg_2_4:getPenaltyEntity()

	if var_2_20.isSinBin or var_2_20.isSentOff then
		var_2_11 = penalty.generatePenaltyAwardedState(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, var_2_19)
	elseif var_2_1.consecutiveSixAgainsAwarded + 1 > var_2_1.maxConsecutiveSixAgainsBeforePenalty and var_2_1.sixAgainInfringementCommittedThisTackle then
		arg_2_7:add(resetconsecutivesixagains_request.ResetConsecutiveSixAgainsRequest())

		var_2_11 = penalty.generatePenaltyAwardedState(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, var_2_19)
	else
		if var_2_1.sixAgainInfringementCommittedThisTackle then
			arg_2_7:add(sixagain_request.SixAgainRequest({
				penaltyType = var_2_16,
				infringementById = var_2_7
			}))
			arg_2_7:add(resettacklecount_request.ResetTackleCountRequest({
				continueConsecutiveSixAgains = true
			}))
		end

		local var_2_21 = {
			attackingSide = var_2_2,
			playTheBallId = var_2_3,
			dummyHalfId = var_2_0.dummyHalfId,
			primaryMarkerId = var_2_0.primaryMarkerId,
			secondaryMarkerId = var_2_0.secondaryMarkerId,
			playTheBallPosition = var_2_0.playTheBallPosition,
			primaryTacklerId = var_2_7,
			stopPlayForInjuryId = var_2_9,
			stopPlayForInjurySide = var_2_10,
			guid = arg_2_2:alloc()
		}

		var_2_11 = class.instantiate("PlayTheBallSetupRuleState", var_2_21)
	end

	arg_2_7:add(resetsixagaininfringement_request.ResetSixAgainInfringementRequest())
	arg_2_7:addRuleStateRequest(var_2_11, arg_2_2:alloc())
end

function heldUpRequestFactory(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9)
	ASSERT(arg_3_9)
	arg_3_7:add(playtheballentity_request.ClearPlayTheBallEntityRequest({}))

	local var_3_0 = arg_3_4:getMatchTimeEntity()
	local var_3_1 = matchtime.canEndCurrentPeriod(arg_3_3, var_3_0)
	local var_3_2 = native.Random.FromSystemTime()
	local var_3_3 = var_3_2:nextAsSeed()
	local var_3_4

	if var_3_1 then
		local var_3_5 = {
			idleDuration = 1,
			endedWithScore = false,
			randomSeed = var_3_3
		}

		var_3_4 = class.instantiate("TimePeriodExpiredIdleRuleState", var_3_5)
	else
		local var_3_6 = arg_3_8.position
		local var_3_7 = rulesenvironment.halfFieldLength - 10
		local var_3_8 = native.clamp1(var_3_6.x, -var_3_7, var_3_7)
		local var_3_9 = native.vec2(var_3_8, var_3_6.y)
		local var_3_10 = arg_3_4:getMatchProgressionEntity().tackleCount
		local var_3_11 = arg_3_1.knowledgeBank.playTheBallKnowledge

		ASSERT(var_3_11)

		local var_3_12 = {
			skipTackleReset = true,
			attackingSide = arg_3_8.side,
			playTheBallPosition = var_3_9,
			newTackleCount = var_3_10 + 1,
			randomSeed = var_3_3,
			playTheBallKnowledge = var_3_11,
			heldUpId = arg_3_9.heldUpId
		}

		print("[9464]  tackleoutcomes:heldUpRequestFactory: GetPlayTheBallWipeSetupState")

		local var_3_13 = playtheballwipesetup_helper.GetPlayTheBallWipeSetupState(var_3_12, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7)

		-- bunker-overturned-try
		local var_p_0, var_p_1 = pcall(provisionalHeldUpTry, arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, var_3_13, var_3_3)

		if not var_p_0 and provisionalTry().log then
			provisionalTry().log("held-up tackle error: " .. tostring(var_p_1))
		end

		if var_p_0 and var_p_1 then
			arg_3_7:addRuleStateRequest(var_p_1, arg_3_2:alloc())

			return
		end

		local var_3_14
		local var_3_15

		var_3_15 = arg_3_3:getComponent("matchInData").matchType.rules == native.MatchSettingsRules.aucklandnines

		local var_3_16 = var_3_2:next(0, 100)

		if not (arg_3_5:getBallObject().pos3.y > 0.8) then
			local var_3_17 = arg_3_3:getComponent("matchInfo"):getMatchSecondsElapsed(arg_3_4, arg_3_6)
			local var_3_18 = {
				isSuccessfulTry = false,
				nextState = var_3_13,
				scoreTime = var_3_17
			}
			local var_3_19 = class.instantiate("TryDecisionPendingRuleState", var_3_18)
			local var_3_20 = {
				activateStoppageTime = true,
				isVideoReferee = true,
				enablePlayerSwitching = false,
				delayBeforeSignal = 1,
				skipReplayEvent = false,
				blockGamerSwitching = false,
				nextState = var_3_19,
				refereeSignal = native.EUmpireSignalTypes.VideoReferee
			}

			var_3_14 = class.instantiate("RefereeCameoRuleState", var_3_20)
		else
			local var_3_21 = {
				activateStoppageTime = true,
				isVideoReferee = false,
				enablePlayerSwitching = false,
				delayBeforeSignal = 1,
				skipReplayEvent = true,
				blockGamerSwitching = false,
				nextState = var_3_13,
				refereeSignal = native.EUmpireSignalTypes.HeldUp
			}

			var_3_14 = class.instantiate("RefereeCameoRuleState", var_3_21)
		end

		ASSERT(var_3_14)

		local var_3_22 = {
			activateStoppageTime = true,
			blockGamerSwitching = false,
			enablePlayerSwitching = false,
			isHandover = false,
			expireTime = arg_3_6 + 1,
			randomSeed = var_3_3,
			nextState = var_3_14,
			guid = arg_3_2:alloc(),
			idleTime = arg_3_6
		}

		var_3_4 = class.instantiate("IdleAllPlayersRuleState", var_3_22)
	end

	arg_3_7:addRuleStateRequest(var_3_4, arg_3_2:alloc())
end

function handoverRequestFactory(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7, arg_4_8)
	arg_4_7:add(playtheballentity_request.ClearPlayTheBallEntityRequest({}))

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
		local var_4_5 = tablex.clone(arg_4_8)

		arg_4_7:add(handover.createRequest(var_4_5, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6))

		local var_4_6 = arg_4_1.knowledgeBank.playTheBallKnowledge

		ASSERT(var_4_6)

		local var_4_7 = arg_4_4:getMatchProgressionEntity()
		local var_4_8 = {
			newTackleCount = 0,
			attackingSide = arg_4_8.restartSide,
			primaryTacklerId = arg_4_8.primaryTacklerId,
			tackledId = arg_4_8.tackledId,
			playTheBallPosition = arg_4_8.restartPosition,
			tackleSetStartPosition = var_4_7.tackleSetStartPosition,
			randomSeed = var_4_0,
			playTheBallKnowledge = var_4_6
		}

		print("[9464]  tackleoutcomes:handoverRequestFactory: GetPlayTheBallWipeSetupState")

		local var_4_9 = playtheballwipesetup_helper.GetPlayTheBallWipeSetupState(var_4_8, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7)
		local var_4_10 = native.Random.FromSystemTime():nextAsSeed()
		local var_4_11 = {
			activateStoppageTime = true,
			blockGamerSwitching = false,
			enablePlayerSwitching = false,
			isHandover = true,
			expireTime = arg_4_6 + 2,
			randomSeed = var_4_10,
			nextState = var_4_9,
			guid = arg_4_2:alloc(),
			idleTime = arg_4_6
		}
		local var_4_12 = class.instantiate("IdleAllPlayersRuleState", var_4_11)
		local var_4_13 = {
			delayBeforeSignal = 0,
			isVideoReferee = false,
			nextState = var_4_12,
			refereeSignal = native.EUmpireSignalTypes.HandOver
		}

		var_4_3 = class.instantiate("RefereeCameoRuleState", var_4_13)
	end

	return rulestate_request.RuleStateRequest(var_4_3, arg_4_2:alloc())
end
