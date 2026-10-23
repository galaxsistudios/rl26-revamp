import("ai.formation.formation_helper")
import("ai.formation.formationchange_request")
import("ai.formation.refereeformationchange_request")
import("ai.officials.refereehelper")
import("ai.plays.clearplay_request")
import("ai.plays.playinitiatedevent_request")
import("ai.plays.playselect_request")
import("base.rulestate.rulestateclass")
import("base.side.sidehelper")
import("core.foundation.class")
import("core.profile.profile")
import("game.camera.camerahelper")
import("game.kickoff.kickoff_helper")
import("game.scrum.scrum_helper")
import("game.helpers.inplay_helper")
import("game.taprestart.taprestart_helper")
import("rules.advantage.advantage_detect")
import("rules.caughtingoal.caughtingoal_detect")
import("rules.caughtingoal.caughtingoal_request")
import("rules.collision.ballcollision_detect")
import("rules.deadball.deadball_request")
import("rules.fieldgoal.fieldgoalsuccess_request")
import("rules.forwardpass.forwardpass_detect")
import("rules.heldintackle.heldintackle_detect")
import("rules.heldintackle.heldintacklewarning_request")
import("rules.gameevent.tacklecompleted_detect")
import("rules.gameevent.tacklegrounded_detect")
import("rules.intouch.intouch_cornerpost_detect")
import("rules.intouch.intouch_detect")
import("rules.intouch.intouchoutcomes")
import("rules.knockon.knockon_detect")
import("rules.knockon.knockon_request")
import("rules.match.matchtime")
import("rules.match.possessionchange_detect")
import("rules.match.resettacklecount_request")
import("rules.match.settacklecountdisabled_request")
import("rules.match.timeperiodexpired_detect")
import("rules.match.timeperiodexpired_request")
import("rules.offside.offside_detect")
import("rules.offside.offsideendtimeperiod_request")
import("rules.penalty.penalty")
import("rules.penalty.penaltytypes")
import("rules.plays.playinitiated_detect")
import("rules.playtheball.heldup_detect")
import("rules.playtheball.playtheballwipesetup_helper")
import("rules.playtheball.tacklebreak_detect")
import("rules.playtheball.tacklecommitted_detect")
import("rules.restart.restart")
import("rules.rules.conditionalrule")
import("rules.rules.rules")
import("rules.rulestate.rulestate_request")
import("rules.scoring.goal_detect")
import("rules.sixagain.resetconsecutivesixagains_request")
import("rules.sixagain.sixagain_request")
import("rules.sixagain.processsixagaininfringement_request")
import("rules.tackle.tackle_detect")
import("rules.tackle.tackleoutcomes")
import("rules.taprestart.taprestart")
import("rules.try.tryattemptoutcomes")
import("script-config.design.cutscene_config")
import("script-config.rules.rugby.scrum_config")
import("script-config.rules.rules.rulesenvironment")
import("rules.rules.rulesenvironment_cconfig")

-- bunker-overturned-try: an attacker's knock-on that lands in the in-goal is awarded as a try
-- first, then overturned by the bunker (see rules/try/tryattemptoutcomes.lua). It goes through
-- trySuccessRequestFactory as a KnockOn attempt, so the restart afterwards is the stock bunker
-- knock-on one. Returns true when it took over from the stock KnockOnRequest.
local function provisionalKnockOnInGoal(arg_gamers, arg_services, arg_guids, arg_match, arg_gamestate, arg_gameobjects, arg_time, arg_requests, arg_params)
	local var_state = rawget(_G, "ProvisionalTryState")

	if not var_state or not var_state.roll then
		return false
	end

	local var_side = arg_params.offendingSide
	local var_position = arg_params.knockOnPosition
	local var_scorer = arg_params.spiltById

	if not var_side or not var_position or not var_scorer or var_side ~= arg_gamestate:getMatchProgressionEntity().attackingSide then
		return false
	end

	local var_depth = var_position.x * arg_match:getSide(var_side):getPlayDir().x

	if var_depth <= rulesenvironment.halfFieldLength or var_depth >= rulesenvironment.deadBallLine then
		return false
	end

	local var_scorerObject = arg_gameobjects:getGameObject(var_scorer)

	if not var_scorerObject or var_scorerObject.side ~= var_side then
		return false
	end

	if not var_state.roll(native.ETryAttemptOutcome.KnockOn, false, arg_match, arg_gamestate, "knock-on in goal") then
		return false
	end

	tryattemptoutcomes.trySuccessRequestFactory(arg_gamers, arg_services, arg_guids, arg_match, arg_gamestate, arg_gameobjects, arg_time, arg_requests, {
		diveOnLooseBall = false,
		divingTry = false,
		ballHeldUpOutsideTryArea = false,
		isBonusTry = false,
		isDropDownTry = false,
		quickCutToCutscene = false,
		forceProvisional = true,
		scorer = var_scorer,
		gamerId = arg_gamers:getGamerIdFor(var_scorer),
		scoringSide = var_side,
		scoringPosition = var_position,
		tryAttemptOutcome = native.ETryAttemptOutcome.KnockOn
	})

	return true
end

local var_0_0 = rulesenvironment_cconfig.cBoundaryConfig
local var_0_1 = cutscene_config.MinTimeToDelayBeforeEnteringCutscene
local var_0_2 = cutscene_config.MaxTimeToDelayBeforeEnteringCutscene

rulestateclass.rulestateclass("GeneralGameplayRuleState", function(arg_1_0, arg_1_1)
	for iter_1_0, iter_1_1 in pairs(GeneralGameplayRuleState.MemberDefinitions) do
		arg_1_0[iter_1_0] = arg_1_1[iter_1_0]
	end
end).MemberDefinitions = {}
GeneralGameplayRuleState.AllowPlayerDegradation = true

function GeneralGameplayRuleState.apply(arg_2_0, arg_2_1, arg_2_2)
	arg_2_1:getInTouchEntity():reset()
	matchtime.updateTime(arg_2_1, arg_2_2)
	matchtime.stopStoppageTime(arg_2_1, arg_2_2)
	matchtime.stopRealTime(arg_2_1, arg_2_2)
end

function GeneralGameplayRuleState.onEnterSolid(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10)
	profile.push("1")

	local var_3_0 = arg_3_3.pools
	local var_3_1 = arg_3_3.activePlayerIdList
	local var_3_2 = arg_3_3.activeCoachIdList
	local var_3_3 = arg_3_3.activeUmpireIdList

	native.CPoolWipeHandler.batchSetVisibility(var_3_1, var_3_0.actorModelPool, true)
	native.CPoolWipeHandler.batchSetVisibility(var_3_2, var_3_0.actorModelPool, true)
	native.CPoolWipeHandler.batchSetBehaviour(var_3_1, var_3_0.behaviourNamePool, "Master")
	native.CPoolWipeHandler.batchSetBehaviour(var_3_3, var_3_0.behaviourNamePool, "Master")
	profile.pop("1")
	profile.push("1.5")
	camerahelper.SetActiveCameraGroupGameplay(arg_3_3, arg_3_5, arg_3_7)

	local var_3_4 = arg_3_6:getMatchProgressionEntity()

	var_3_4:setGeneralGameplayActive(true)

	local var_3_5 = arg_3_6:getTeamTacticsEntityPair()
	local var_3_6 = var_3_4.attackingSide
	local var_3_7 = sidehelper.getOtherSide(var_3_6)
	local var_3_8 = var_3_5:get(var_3_6)
	local var_3_9 = var_3_5:get(var_3_7)
	local var_3_10 = native.EForceDirectedGraphType.Offence
	local var_3_11 = var_3_8:getGraphName(var_3_10)
	local var_3_12 = native.EForceDirectedGraphType.Defence
	local var_3_13 = var_3_9:getGraphName(var_3_12)
	local var_3_14 = {
		attackingSide = var_3_6,
		attackingGraphName = var_3_11,
		attackingGraphType = var_3_10,
		attackingFormationFocus = native.EFormationFocus.Ball,
		defendingGraphName = var_3_13,
		defendingGraphType = var_3_12,
		defendingFormationFocus = native.EFormationFocus.Ball
	}

	if arg_3_6:getScrumEntity().scrumEndTime ~= native.Time.NullTime() then
		formatPrint("[ScrumEntity.endTime] is active, entered generalGameplay, cancelling formation change")
		formatPrint("Formations ignored: Attacking: %s, Defending: %s", var_3_11, var_3_13)

		local var_3_15 = native.EForceDirectedGraphType.ScrumDefence
		local var_3_16 = var_3_9:getGraphName(var_3_15)
		local var_3_17 = {
			attackingSide = var_3_6,
			attackingGraphName = var_3_11,
			attackingGraphType = var_3_10,
			attackingFormationFocus = native.EFormationFocus.Ball,
			defendingGraphName = var_3_16,
			defendingGraphType = var_3_15,
			defendingFormationFocus = native.EFormationFocus.Ball
		}

		formatPrint("New formations applied: Attacking: %s, Defending: %s", var_3_11, var_3_16)
		formation_helper.ChangeFormations(arg_3_6, var_3_17)
	else
		formation_helper.ChangeFormations(arg_3_6, var_3_14)
	end

	profile.pop("1.5")
	profile.push("2")

	local var_3_18 = arg_3_5:getComponent("matchInData").matchType.categorisedMatchType == native.EMatchType.MT_StandardMatch
	local var_3_19 = refereehelper.getRefereeGraphName(native.EForceDirectedGraphType.RefereeGeneralGameplay, var_3_18)
	local var_3_20 = {
		refereeGraphName = var_3_19,
		refereeFormationFocus = native.EFormationFocus.Ball
	}

	arg_3_10:add(refereeformationchange_request.RefereeFormationChangeRequest(var_3_20))
	arg_3_6:getPenaltyEntity():reset()

	arg_3_5:getComponent("matchInProgressData").gameplayStarted = true

	local var_3_21 = arg_3_6:getCaptainsChallengeEntity()

	var_3_21:setCaptainsChallengeEnabled(var_3_6, true)
	var_3_21:setCaptainsChallengeEnabled(var_3_7, true)
	profile.pop("2")
end

function GeneralGameplayRuleState.onExitSolid(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7, arg_4_8, arg_4_9, arg_4_10)
	print("GeneralGameplayRuleState:onExitSolid")
	arg_4_6:getMatchProgressionEntity():setGeneralGameplayActive(false)

	if arg_4_0.skipStateMixin then
		arg_4_0.skipStateMixin:release()
	end

	if arg_4_0.gamepadHudRight then
		arg_4_0.gamepadHudRight:hide(true)
	end

	if arg_4_0.gamepadHudLeft then
		arg_4_0.gamepadHudLeft:hide(true)
	end
end

function GeneralGameplayRuleState.updateSolid(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7, arg_5_8, arg_5_9, arg_5_10, arg_5_11)
	if arg_5_0.allowPocketPlayMaker then
		local var_5_0 = arg_5_2:getLocalGamersOnSide(arg_5_0.playTheBallSide)
		local var_5_1 = inplay_helper.IsAnyGamerInPlay(arg_5_2, arg_5_3, arg_5_6, arg_5_0.playTheBallSide)

		if var_5_0 and #var_5_0 > 0 and var_5_1 then
			local var_5_2

			for iter_5_0, iter_5_1 in ipairs(var_5_0) do
				var_5_2 = iter_5_1:getInputEvent("DummyHalf", "SetPocketPlay")
			end

			local var_5_3 = VERIFY(arg_5_3.hud)

			if not arg_5_0.gamepadHudRight then
				arg_5_0.gamepadHudRight = var_5_3:getElement("gamepadButtonFaceHintsRight")
			end

			if not arg_5_0.gamepadHudLeft then
				arg_5_0.gamepadHudLeft = var_5_3:getElement("gamepadButtonFaceHintsLeft")
			end

			if arg_5_0.playTheBallSide == sidehelper.away then
				if not arg_5_0.gamepadHudRight.enabled then
					arg_5_0.gamepadHudRight:show()
					arg_5_0.gamepadHudLeft:hide()
					arg_5_0.gamepadHudRight:DropPocketHints()
				end
			elseif not arg_5_0.gamepadHudLeft.enabled then
				arg_5_0.gamepadHudLeft:show()
				arg_5_0.gamepadHudRight:hide()
				arg_5_0.gamepadHudLeft:DropPocketHints()
			end

			if var_5_2 then
				local var_5_4 = {
					side = arg_5_0.playTheBallSide
				}

				arg_5_11:add(playselect_request.InPocketPlayRequest(var_5_4))
			end
		end
	end

	local var_5_5 = arg_5_3.hud
	local var_5_6 = var_5_5:getElement("CaptainsChallengeHud")

	if var_5_6 then
		var_5_6:hide()
		arg_5_6:getCaptainsChallengeEntity():setShowCaptainsChallengesRemaining(false)
	end

	local var_5_7 = var_5_5 and var_5_5:getElement("playernamefieldhud")

	if var_5_7 and var_5_7:isHidden() then
		var_5_7:show()
	end
end

function GeneralGameplayRuleState.addSolidRules(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5)
	local var_6_0 = arg_6_5 or rules.Rules()

	profile.push("makeFns")

	local function var_6_1(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7, arg_7_8)
		local var_7_0 = arg_7_4:getMatchProgressionEntity()
		local var_7_1 = arg_7_4:getTeamTacticsEntityPair()

		ASSERT(var_7_1)

		local var_7_2 = var_7_0.attackingSide
		local var_7_3 = sidehelper.getOtherSide(var_7_2)
		local var_7_4 = var_7_1:get(var_7_2)
		local var_7_5 = var_7_1:get(var_7_3)
		local var_7_6 = native.EForceDirectedGraphType.Offence
		local var_7_7 = var_7_4:getGraphName(var_7_6)
		local var_7_8 = native.EForceDirectedGraphType.Defence
		local var_7_9 = var_7_5:getGraphName(var_7_8)
		local var_7_10 = {
			attackingSide = var_7_0.attackingSide,
			attackingGraphName = var_7_7,
			attackingGraphType = var_7_6,
			attackingFormationFocus = native.EFormationFocus.Ball,
			defendingGraphName = var_7_9,
			defendingGraphType = var_7_8,
			defendingFormationFocus = native.EFormationFocus.Ball
		}

		arg_7_7:add(formationchange_request.FormationChangeRequest(var_7_10))
		arg_7_7:add(clearplay_request.ClearPlayRequest({
			side = sidehelper.home
		}))
		arg_7_7:add(clearplay_request.ClearPlayRequest({
			side = sidehelper.away
		}))
	end

	local function var_6_2(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5, arg_8_6, arg_8_7, arg_8_8)
		arg_8_7:add(deadball_request.DeadBallRequest())
		arg_8_7:add(clearplay_request.ClearPlayRequest({
			side = sidehelper.home
		}))
		arg_8_7:add(clearplay_request.ClearPlayRequest({
			side = sidehelper.away
		}))
	end

	local function var_6_3(arg_9_0, arg_9_1, arg_9_2, arg_9_3, arg_9_4, arg_9_5, arg_9_6, arg_9_7, arg_9_8)
		local var_9_0 = arg_9_4:getMatchProgressionEntity()
		local var_9_1 = arg_9_4:getTeamTacticsEntityPair()

		ASSERT(var_9_1)

		local var_9_2 = var_9_0.attackingSide

		arg_6_0.playTheBallSide = var_9_2
		arg_6_0.allowPocketPlayMaker = true

		local var_9_3 = sidehelper.getOtherSide(var_9_2)
		local var_9_4 = var_9_1:get(var_9_2)
		local var_9_5 = var_9_1:get(var_9_3)
		local var_9_6 = native.EForceDirectedGraphType.PlayTheBallOffence
		local var_9_7 = var_9_4:getGraphName(var_9_6)
		local var_9_8 = native.EForceDirectedGraphType.PlayTheBallDefence
		local var_9_9 = var_9_5:getGraphName(var_9_8)
		local var_9_10 = {
			attackingSide = var_9_0.attackingSide,
			attackingGraphName = var_9_7,
			attackingGraphType = var_9_6,
			attackingFormationFocus = native.EFormationFocus.Ball,
			defendingGraphName = var_9_9,
			defendingGraphType = var_9_8,
			defendingFormationFocus = native.EFormationFocus.Ball
		}

		arg_9_7:add(formationchange_request.FormationChangeRequest(var_9_10))

		local var_9_11 = arg_9_3:getComponent("matchInData").matchType.categorisedMatchType == native.EMatchType.MT_StandardMatch
		local var_9_12 = refereehelper.getRefereeGraphName(native.EForceDirectedGraphType.RefereePlayTheBall, var_9_11)
		local var_9_13 = {
			refereeGraphName = var_9_12,
			refereeFormationFocus = native.EFormationFocus.Ball
		}

		arg_9_7:add(refereeformationchange_request.RefereeFormationChangeRequest(var_9_13))
	end

	local function var_6_4(arg_10_0, arg_10_1, arg_10_2, arg_10_3, arg_10_4, arg_10_5, arg_10_6, arg_10_7, arg_10_8)
		local var_10_0 = arg_10_4:getMatchProgressionEntity()
		local var_10_1 = arg_10_4:getTeamTacticsEntityPair()

		ASSERT(var_10_1)

		local var_10_2 = var_10_0.attackingSide
		local var_10_3 = sidehelper.getOtherSide(var_10_2)
		local var_10_4 = var_10_1:get(var_10_2)
		local var_10_5 = var_10_1:get(var_10_3)
		local var_10_6 = native.EForceDirectedGraphType.Offence
		local var_10_7 = var_10_4:getGraphName(var_10_6)
		local var_10_8 = native.EForceDirectedGraphType.Defence
		local var_10_9 = var_10_5:getGraphName(var_10_8)
		local var_10_10 = {
			attackingSide = var_10_0.attackingSide,
			attackingGraphName = var_10_7,
			attackingGraphType = var_10_6,
			attackingFormationFocus = native.EFormationFocus.Ball,
			defendingGraphName = var_10_9,
			defendingGraphType = var_10_8,
			defendingFormationFocus = native.EFormationFocus.Ball
		}

		arg_10_7:add(formationchange_request.FormationChangeRequest(var_10_10))
	end

	local function var_6_5(arg_11_0, arg_11_1, arg_11_2, arg_11_3, arg_11_4, arg_11_5, arg_11_6, arg_11_7, arg_11_8)
		arg_11_7:add(playinitiatedevent_request.PlayInitiatedEventRequest({
			playId = arg_11_8.playId
		}))
	end

	local function var_6_6(arg_12_0, arg_12_1, arg_12_2, arg_12_3, arg_12_4, arg_12_5, arg_12_6, arg_12_7, arg_12_8)
		return intouchoutcomes.inTouchOnFullRequestFactory(arg_12_0, arg_12_1, arg_12_2, arg_12_3, arg_12_4, arg_12_5, arg_12_6, arg_12_7, arg_12_8)
	end

	local function var_6_7(arg_13_0, arg_13_1, arg_13_2, arg_13_3, arg_13_4, arg_13_5, arg_13_6, arg_13_7, arg_13_8)
		if arg_6_0.rulestateRequestSent then
			return
		end

		return intouchoutcomes.inTouchInGoalOnFullRequestFactory(arg_13_0, arg_13_1, arg_13_2, arg_13_3, arg_13_4, arg_13_5, arg_13_6, arg_13_7, arg_13_8)
	end

	local function var_6_8(arg_14_0, arg_14_1, arg_14_2, arg_14_3, arg_14_4, arg_14_5, arg_14_6, arg_14_7, arg_14_8)
		return intouchoutcomes.inTouchOnBounceRequestFactory(arg_14_0, arg_14_1, arg_14_2, arg_14_3, arg_14_4, arg_14_5, arg_14_6, arg_14_7, arg_14_8)
	end

	local function var_6_9(arg_15_0, arg_15_1, arg_15_2, arg_15_3, arg_15_4, arg_15_5, arg_15_6, arg_15_7, arg_15_8)
		if arg_6_0.rulestateRequestSent then
			return
		end

		return intouchoutcomes.inTouchInGoalOnBounceRequestFactory(arg_15_0, arg_15_1, arg_15_2, arg_15_3, arg_15_4, arg_15_5, arg_15_6, arg_15_7, arg_15_8)
	end

	local function var_6_10(arg_16_0, arg_16_1, arg_16_2, arg_16_3, arg_16_4, arg_16_5, arg_16_6, arg_16_7, arg_16_8)
		return intouchoutcomes.fortyTwentyVariationRequestFactory(arg_16_0, arg_16_1, arg_16_2, arg_16_3, arg_16_4, arg_16_5, arg_16_6, arg_16_7, arg_16_8)
	end

	local function var_6_11(arg_17_0, arg_17_1, arg_17_2, arg_17_3, arg_17_4, arg_17_5, arg_17_6, arg_17_7, arg_17_8)
		formatPrint("[AdvantageDetect][Final]")

		arg_6_0.rulestateRequestSent = true
	end

	local function var_6_12(arg_18_0, arg_18_1, arg_18_2, arg_18_3, arg_18_4, arg_18_5, arg_18_6, arg_18_7, arg_18_8)
		-- bunker-overturned-try
		if not arg_6_0.rulestateRequestSent then
			local var_p_0, var_p_1 = pcall(provisionalKnockOnInGoal, arg_18_0, arg_18_1, arg_18_2, arg_18_3, arg_18_4, arg_18_5, arg_18_6, arg_18_7, arg_18_8)

			if var_p_0 and var_p_1 then
				arg_6_0.rulestateRequestSent = true

				return nil
			elseif not var_p_0 then
				local var_p_2 = rawget(_G, "ProvisionalTryState")

				if var_p_2 and var_p_2.log then
					var_p_2.log("knock-on in goal error: " .. tostring(var_p_1))
				end
			end
		end

		local var_18_0 = arg_18_8.guid or arg_18_2:alloc()
		local var_18_1 = assert(arg_18_8.offendingSide)
		local var_18_2 = arg_18_8.knockOnPosition
		local var_18_3 = arg_18_8.accidentalKnockOn
		local var_18_4 = arg_18_8.accidentalOffside
		local var_18_5 = arg_18_8.spiltById
		local var_18_6 = arg_18_4:getMatchProgressionEntity().tackleCount
		local var_18_7 = arg_18_8.isUmpireWrongCall
		local var_18_8 = arg_18_8.isGreyAreaUmpireCall
		local var_18_9 = {
			guid = var_18_0,
			knockOnSide = var_18_1,
			knockOnPosition = var_18_2,
			tackleCount = var_18_6,
			startTime = arg_18_6,
			offenderId = var_18_5,
			accidentalKnockOn = var_18_3,
			accidentalOffside = var_18_4,
			isUmpireWrongCall = var_18_7,
			isGreyAreaUmpireCall = var_18_8
		}

		return knockon_request.KnockOnRequest(var_18_9)
	end

	local function var_6_13(arg_19_0, arg_19_1, arg_19_2, arg_19_3, arg_19_4, arg_19_5, arg_19_6, arg_19_7, arg_19_8)
		local var_19_0 = native.Random.FromSystemTime():nextAsSeed()
		local var_19_1 = arg_19_4:getMatchTimeEntity()
		local var_19_2 = matchtime.canEndCurrentPeriod(arg_19_3, var_19_1)
		local var_19_3 = arg_19_3:getComponent("matchInData")
		local var_19_4

		if var_19_2 then
			local var_19_5 = {
				idleDuration = 1,
				endedWithScore = false,
				randomSeed = var_19_0
			}

			var_19_4 = class.instantiate("TimePeriodExpiredIdleRuleState", var_19_5)
		else
			local var_19_6 = arg_19_8.passOrigin
			local var_19_7 = arg_19_8.offendingSide
			local var_19_8 = arg_19_3:getSide(var_19_7):getGoalPos().x * -1
			local var_19_9

			if var_19_8 < 0 and var_19_6.x < rulesenvironment.westGoalPosX or var_19_8 > 0 and var_19_6.x > rulesenvironment.eastGoalPosX then
				local var_19_10 = {
					restartAtTwentyMetres = false,
					kickerSide = var_19_7,
					actionGuid = arg_19_2:alloc()
				}

				var_19_9 = class.instantiate("LineDropOutSetupRuleState", var_19_10)
			end

			if not var_19_3.matchType.usingScrums then
				if var_19_9 then
					var_19_4 = var_19_9
				else
					local var_19_11 = restart.adjustRestartPositionInToFieldOfPlay(var_19_6, scrum_config)
					local var_19_12 = sidehelper.getOtherSide(arg_19_8.offendingSide)
					local var_19_13 = native.Random.FromSystemTime():nextAsSeed()
					local var_19_14 = arg_19_1.knowledgeBank.playTheBallKnowledge

					ASSERT(var_19_14)

					local var_19_15 = {
						newTackleCount = 0,
						attackingSide = var_19_12,
						playTheBallPosition = var_19_11,
						tackleSetStartPosition = var_19_11,
						randomSeed = var_19_13,
						playTheBallKnowledge = var_19_14
					}

					print("[9464] generalgameplay_rulestate:forwardPassRequestFactory: GetPlayTheBallWipeSetupState")

					local var_19_16 = playtheballwipesetup_helper.GetPlayTheBallWipeSetupState(var_19_15, arg_19_1, arg_19_2, arg_19_3, arg_19_4, arg_19_5, arg_19_6, arg_19_7)
					local var_19_17 = {
						activateStoppageTime = true,
						blockGamerSwitching = false,
						enablePlayerSwitching = false,
						isHandover = true,
						expireTime = arg_19_6 + 2,
						randomSeed = var_19_13,
						nextState = var_19_16,
						guid = arg_19_2:alloc(),
						idleTime = arg_19_6
					}

					var_19_4 = class.instantiate("IdleAllPlayersRuleState", var_19_17)
				end
			else
				if not var_19_9 then
					local var_19_18 = sidehelper.getOtherSide(var_19_7)
					local var_19_19 = restart.adjustRestartPositionInToFieldOfPlay(var_19_6, scrum_config)
					local var_19_20 = {
						sideWithFeed = var_19_18,
						scrumPosition = var_19_19,
						randomSeed = var_19_0
					}

					print("[9464] generalgameplay_rulestate:forwardPassRequestFactory: GetScrumState")

					var_19_9 = scrum_helper.GetScrumState(var_19_20, arg_19_1, arg_19_2, arg_19_3, arg_19_4, arg_19_5, arg_19_6, arg_19_7)
				end

				local var_19_21 = {
					delayBeforeSignal = 1,
					isVideoReferee = false,
					enablePlayerSwitching = false,
					blockGamerSwitching = false,
					lastAttackingSide = var_19_7,
					nextState = var_19_9,
					refereeSignal = native.EUmpireSignalTypes.ForwardPass
				}
				local var_19_22 = class.instantiate("RefereeCameoRuleState", var_19_21)
				local var_19_23 = {
					activateStoppageTime = true,
					blockGamerSwitching = false,
					enablePlayerSwitching = false,
					isHandover = true,
					expireTime = arg_19_6 + 2,
					randomSeed = var_19_0,
					nextState = var_19_22,
					guid = arg_19_2:alloc(),
					idleTime = arg_19_6
				}

				var_19_4 = class.instantiate("IdleAllPlayersRuleState", var_19_23)
			end
		end

		return rulestate_request.RuleStateRequest(var_19_4, arg_19_2:alloc())
	end

	local function var_6_14(arg_20_0, arg_20_1, arg_20_2, arg_20_3, arg_20_4, arg_20_5, arg_20_6, arg_20_7, arg_20_8)
		local var_20_0 = native.Random.FromSystemTime():nextAsSeed()
		local var_20_1 = arg_20_4:getMatchTimeEntity()
		local var_20_2 = matchtime.canEndCurrentPeriod(arg_20_3, var_20_1)
		local var_20_3

		if var_20_2 and not arg_20_8.defensiveOffside then
			local var_20_4 = {
				guid = arg_20_2:alloc()
			}

			arg_20_7:add(offsideendtimeperiod_request.OffsideEndTimePeriodRequest(var_20_4))

			local var_20_5 = {
				idleDuration = 1,
				endedWithScore = false,
				randomSeed = var_20_0
			}

			var_20_3 = class.instantiate("TimePeriodExpiredIdleRuleState", var_20_5)
		else
			local var_20_6 = arg_20_8.offendingSide
			local var_20_7 = arg_20_8.position
			local var_20_8 = arg_20_8.offenderId
			local var_20_9 = sidehelper.getOtherSide(var_20_6)
			local var_20_10 = penaltytypes.infringementTypes
			local var_20_11 = arg_20_8.penaltyType
			local var_20_12 = arg_20_8.refereeSignalType
			local var_20_13 = arg_20_5:getGameObject(var_20_8):getPlayDir().x
			local var_20_14 = arg_20_3:getComponent("matchInData").matchType.name
			local var_20_15

			if var_20_14 ~= "NRL2026" then
				-- block empty
			end

			local var_20_16 = var_0_0:inAttackingTwentyMetreZone(var_20_7, 0, var_20_13)

			if false then
				var_20_16 = var_0_0:inAttackingFortyMetreZone(var_20_7, 0, var_20_13)
			end

			local var_20_17 = {
				offendingSide = var_20_6,
				penaltyPosition = var_20_7,
				offenderId = var_20_8,
				penaltyAwardedToSide = var_20_9,
				infringementTypes = var_20_10,
				penaltyType = var_20_11,
				refereeSignal = var_20_12
			}
			local var_20_18 = arg_20_4:getBallEntity():getOwnerId(arg_20_6)
			local var_20_19 = var_20_18 == nil or var_20_18 == var_20_8

			if var_20_11 == penaltytypes.infringementTypes.OffSide then
				if var_20_16 or var_20_19 then
					var_20_3 = penalty.generatePenaltyAwardedState(arg_20_0, arg_20_1, arg_20_2, arg_20_3, arg_20_4, arg_20_5, arg_20_6, arg_20_7, var_20_17)
				else
					local var_20_20 = arg_20_4:getMatchProgressionEntity()

					if var_20_20.consecutiveSixAgainsAwarded + 1 > var_20_20.maxConsecutiveSixAgainsBeforePenalty then
						arg_20_7:add(resetconsecutivesixagains_request.ResetConsecutiveSixAgainsRequest())

						var_20_3 = penalty.generatePenaltyAwardedState(arg_20_0, arg_20_1, arg_20_2, arg_20_3, arg_20_4, arg_20_5, arg_20_6, arg_20_7, var_20_17)
					else
						arg_20_7:add(sixagain_request.SixAgainRequest({
							penaltyType = var_20_11,
							infringementById = var_20_8
						}))
						arg_20_7:add(resettacklecount_request.ResetTackleCountRequest({
							continueConsecutiveSixAgains = true
						}))

						if arg_20_8.tackledPlayerHasBall == nil or arg_20_8.tackledPlayerHasBall then
							arg_20_7:add(settacklecountdisabled_request.SetTackleCountDisabledRequest({
								disable = true
							}))
						end

						return
					end
				end
			else
				var_20_3 = penalty.generatePenaltyAwardedState(arg_20_0, arg_20_1, arg_20_2, arg_20_3, arg_20_4, arg_20_5, arg_20_6, arg_20_7, var_20_17)
			end
		end

		return rulestate_request.RuleStateRequest(var_20_3, arg_20_2:alloc())
	end

	local function var_6_15(arg_21_0, arg_21_1, arg_21_2, arg_21_3, arg_21_4, arg_21_5, arg_21_6, arg_21_7, arg_21_8)
		arg_6_0.rulestateRequestSent = true

		return tackleoutcomes.tackledInGoalRequestFactory(arg_21_0, arg_21_1, arg_21_2, arg_21_3, arg_21_4, arg_21_5, arg_21_6, arg_21_7, arg_21_8)
	end

	local function var_6_16(arg_22_0, arg_22_1, arg_22_2, arg_22_3, arg_22_4, arg_22_5, arg_22_6, arg_22_7, arg_22_8)
		arg_6_0.rulestateRequestSent = true

		return tackleoutcomes.playTheBallRuleStateRequestFactory(arg_22_0, arg_22_1, arg_22_2, arg_22_3, arg_22_4, arg_22_5, arg_22_6, arg_22_7, arg_22_8)
	end

	local function var_6_17(arg_23_0, arg_23_1, arg_23_2, arg_23_3, arg_23_4, arg_23_5, arg_23_6, arg_23_7, arg_23_8)
		arg_6_0.rulestateRequestSent = true

		return tackleoutcomes.handoverRequestFactory(arg_23_0, arg_23_1, arg_23_2, arg_23_3, arg_23_4, arg_23_5, arg_23_6, arg_23_7, arg_23_8)
	end

	local function var_6_18(arg_24_0, arg_24_1, arg_24_2, arg_24_3, arg_24_4, arg_24_5, arg_24_6, arg_24_7, arg_24_8)
		local var_24_0 = {
			heldUpId = arg_24_8.maker
		}

		arg_6_0.rulestateRequestSent = true

		return tackleoutcomes.heldUpRequestFactory(arg_24_0, arg_24_1, arg_24_2, arg_24_3, arg_24_4, arg_24_5, arg_24_6, arg_24_7, arg_24_8, var_24_0)
	end

	local function var_6_19(arg_25_0, arg_25_1, arg_25_2, arg_25_3, arg_25_4, arg_25_5, arg_25_6, arg_25_7, arg_25_8)
		if not arg_25_8.success then
			return
		end

		local var_25_0 = arg_25_8.scoringSide
		local var_25_1 = arg_25_8.distFromGoal
		local var_25_2 = arg_25_8.scorer
		local var_25_3 = arg_25_0:getGamerIdFor(var_25_2)
		local var_25_4 = arg_25_8.kickOrigin
		local var_25_5 = arg_25_8.timePeriodExpired
		local var_25_6 = arg_25_4:getMatchTimeEntity().goldenPointActive
		local var_25_7 = native.Random.FromSystemTime():nextAsSeed()
		local var_25_8 = var_0_2
		local var_25_9 = var_0_1
		local var_25_10 = VERIFY(arg_25_3:getSide(var_25_0)).assetIdMap[var_25_2]

		ASSERT(var_25_10)

		local var_25_11 = arg_25_3:getComponent("matchInfo"):getMatchSecondsElapsed(arg_25_4, arg_25_6)
		local var_25_12 = {
			assetId = var_25_10,
			distFromGoal = var_25_1,
			scoringSide = var_25_0,
			scorer = var_25_2,
			gamerId = var_25_3,
			kickOrigin = var_25_4,
			timeExpired = var_25_5,
			goldenPointActive = var_25_6,
			scoreTime = var_25_11
		}

		arg_25_7:add(fieldgoalsuccess_request.FieldGoalSuccessRequest(var_25_12))

		local var_25_13

		if var_25_5 or var_25_6 then
			local var_25_14 = {
				endedWithScore = true,
				idleDuration = var_25_8,
				randomSeed = var_25_7
			}

			var_25_13 = class.instantiate("TimePeriodExpiredIdleRuleState", var_25_14)
		else
			local var_25_15 = false
			local var_25_16 = false
			local var_25_17 = arg_25_3:getComponent("matchInData").matchType.handoverOnGoal and sidehelper.getOtherSide(var_25_0) or var_25_0
			local var_25_18 = {
				kickOffBeginsTimePeriod = false,
				kickerSide = var_25_17,
				actionGuid = arg_25_2:alloc()
			}
			local var_25_19 = kickoff_helper.GetKickOffState(var_25_18, arg_25_3, arg_25_4, arg_25_1)
			local var_25_20 = {
				isFieldGoalAttempt = true,
				isBonusTry = false,
				unsuccessfulAttempt = false,
				quickCutToCutscene = false,
				maxDelayBeforeCutscene = var_25_8,
				minDelayBeforeCutscene = var_25_9,
				randomSeed = var_25_7,
				decisionPending = var_25_15,
				scoringSide = var_25_0,
				scoringGamer = var_25_3,
				scorer = var_25_2,
				scorePosition = var_25_4,
				nextState = var_25_19
			}

			var_25_13 = class.instantiate("ReactToScoreRuleState", var_25_20)
		end

		arg_25_7:add(rulestate_request.RuleStateRequest(var_25_13, arg_25_2:alloc()))
	end

	local function var_6_20(arg_26_0, arg_26_1, arg_26_2, arg_26_3, arg_26_4, arg_26_5, arg_26_6, arg_26_7, arg_26_8)
		local var_26_0 = native.Random.FromSystemTime():nextAsSeed()
		local var_26_1 = arg_26_4:getMatchTimeEntity()
		local var_26_2 = matchtime.canEndCurrentPeriod(arg_26_3, var_26_1)
		local var_26_3 = arg_26_8.disposalInfo

		ASSERT(var_26_3)

		local var_26_4 = var_26_3.disposalType == native.EDisposalType.Collision and var_26_3.originalDisposalSubType or var_26_3.disposalSubType

		if var_26_4 == native.EDisposalSubType.PenaltyGoal or var_26_4 == native.EDisposalSubType.PenaltyGoalDrop then
			return
		end

		local var_26_5

		if var_26_2 then
			local var_26_6 = {
				idleDuration = 1,
				endedWithScore = false,
				randomSeed = var_26_0
			}

			var_26_5 = class.instantiate("TimePeriodExpiredIdleRuleState", var_26_6)
		else
			local var_26_7 = arg_26_8.caughtById
			local var_26_8 = arg_26_8.caughtBySide
			local var_26_9 = arg_26_8.catchPosition
			local var_26_10 = taprestart.getTapPositionFromCaughtInGoal(arg_26_3, var_26_8)
			local var_26_11 = {
				catchPosition = var_26_9,
				caughtById = var_26_7,
				restartPosition = var_26_10,
				restartSide = var_26_8
			}

			arg_26_7:add(caughtingoal_request.CaughtInGoalRequest(var_26_11))

			local var_26_12 = native.Random.FromSystemTime():nextAsSeed()
			local var_26_13 = arg_26_3:getComponent("matchInData")
			local var_26_14 = {
				restartSide = var_26_8,
				restartPosition = var_26_10,
				nextTackleIsZeroTackle = var_26_13.matchType.zeroTackleOnTwentyMetreRestart,
				randomSeed = var_26_12
			}
			local var_26_15 = taprestart_helper.GetTapRestartState(var_26_14, arg_26_3, arg_26_4, arg_26_1, arg_26_7)
			local var_26_16 = {
				activateStoppageTime = true,
				blockGamerSwitching = false,
				enablePlayerSwitching = false,
				isHandover = true,
				expireTime = arg_26_6 + 1.5,
				randomSeed = var_26_12,
				nextState = var_26_15,
				guid = arg_26_2:alloc(),
				idleTime = arg_26_6
			}

			var_26_5 = class.instantiate("IdleAllPlayersRuleState", var_26_16)
		end

		return rulestate_request.RuleStateRequest(var_26_5, arg_26_2:alloc())
	end

	local function var_6_21(arg_27_0, arg_27_1, arg_27_2, arg_27_3, arg_27_4, arg_27_5, arg_27_6, arg_27_7, arg_27_8)
		arg_6_0.rulestateRequestSent = true

		return tryattemptoutcomes.trySuccessRequestFactory(arg_27_0, arg_27_1, arg_27_2, arg_27_3, arg_27_4, arg_27_5, arg_27_6, arg_27_7, arg_27_8)
	end

	local function var_6_22(arg_28_0, arg_28_1, arg_28_2, arg_28_3, arg_28_4, arg_28_5, arg_28_6, arg_28_7, arg_28_8)
		local var_28_0 = arg_28_8.colliderType == native.CPhysicsEnum.Player
		local var_28_1 = arg_28_8.disposalType and arg_28_8.disposalType == native.EDisposalType.Pass or false
		local var_28_2 = arg_28_8.disposalSubType and arg_28_8.disposalSubType == native.EDisposalSubType.Offload
		local var_28_3 = var_28_1 and not var_28_2
		local var_28_4 = arg_28_4:getChargeDownInfoPool()

		ASSERT(var_28_4)

		local var_28_5 = var_28_4:get(arg_28_8.colliderId)
		local var_28_6 = var_28_5 and var_28_5:wasRecentlyInChargeDown(arg_28_6:ToSeconds()) or false
		local var_28_7 = (arg_28_8.disposalType and arg_28_8.disposalType == native.EDisposalType.Kick or false) and var_28_6
		local var_28_8 = arg_28_5:getGameObject(arg_28_8.colliderId)
		local var_28_9 = var_28_8:getAction(arg_28_4)
		local var_28_10 = var_28_8:getBlendAction(arg_28_4)
		local var_28_11 = var_28_9 and type(var_28_9) == "ChargeDownAction" or var_28_10 and type(var_28_10) == "PrepareChargeDownAction"

		if var_28_0 and (var_28_3 or var_28_11 or var_28_7) then
			local var_28_12 = arg_28_1.knowledgeBank

			ASSERT(var_28_12)

			local var_28_13 = var_28_12.activeTeamPlayerIdListPair

			ASSERT(var_28_13)

			local var_28_14 = arg_28_4:getMatchProgressionEntity().defendingSide
			local var_28_15 = var_28_13:get(var_28_14)

			ASSERT(var_28_15)

			for iter_28_0, iter_28_1 in var_28_15:iter() do
				ASSERT(arg_28_8.colliderId)

				if iter_28_1 == arg_28_8.colliderId then
					arg_28_7:add(resettacklecount_request.ResetAndZeroTackleCountRequest())
				end
			end
		end
	end

	local function var_6_23(arg_29_0, arg_29_1, arg_29_2, arg_29_3, arg_29_4, arg_29_5, arg_29_6, arg_29_7, arg_29_8)
		local var_29_0 = arg_29_4:getMatchProgressionEntity()
		local var_29_1 = arg_29_4:getActiveTackleEntity()
		local var_29_2 = var_29_1:getMostRecentActiveTackle()
		local var_29_3 = var_29_2:getParticipantId(native.ETackleParticipantType.Tackler1)
		local var_29_4 = var_29_1:getTackleBlock(var_29_2.tackleGuid, var_29_2.activeBlockGuid)
		local var_29_5 = var_29_0.attackingSide
		local var_29_6 = sidehelper.getOtherSide(var_29_5)
		local var_29_7 = var_29_4.startPosition
		local var_29_8 = var_29_3
		local var_29_9 = penaltytypes.infringementTypes
		local var_29_10 = penaltytypes.infringementTypes.HeldInTackle
		local var_29_11 = native.EUmpireSignalTypes.HeldInTackle
		local var_29_12 = arg_29_5:getGameObject(var_29_8):getPlayDir().x
		local var_29_13 = {
			offendingSide = var_29_6,
			penaltyPosition = var_29_7,
			offenderId = var_29_8,
			penaltyAwardedToSide = var_29_5,
			infringementTypes = var_29_9,
			penaltyType = var_29_10,
			refereeSignal = var_29_11
		}
		local var_29_14 = arg_29_3:getComponent("matchInData").matchType.name
		local var_29_15

		if var_29_14 ~= "NRL2026" then
			-- block empty
		end

		local var_29_16 = var_0_0:inAttackingTwentyMetreZone(var_29_7, 0, var_29_12)

		if false then
			var_29_16 = var_0_0:inAttackingFortyMetreZone(var_29_7, 0, var_29_12)
		end

		if var_29_16 then
			print("Held in tackle penalty request sent")

			local var_29_17 = penalty.generatePenaltyAwardedState(arg_29_0, arg_29_1, arg_29_2, arg_29_3, arg_29_4, arg_29_5, arg_29_6, arg_29_7, var_29_13)

			arg_29_7:addRuleStateRequest(var_29_17, arg_29_2:alloc())
		else
			arg_29_7:add(processsixagaininfringement_request.ProcessSixAgainInfringementRequest({
				penaltyType = var_29_10,
				infringementById = var_29_8
			}))

			return
		end
	end

	local function var_6_24(arg_30_0, arg_30_1, arg_30_2, arg_30_3, arg_30_4, arg_30_5, arg_30_6, arg_30_7, arg_30_8)
		arg_30_7:add(heldintacklewarning_request.HeldInTackleWarningRequest(arg_30_8))
	end

	local function var_6_25(arg_31_0, arg_31_1, arg_31_2, arg_31_3, arg_31_4, arg_31_5, arg_31_6, arg_31_7)
		local var_31_0 = arg_31_3:getComponent("matchInData").matchType.categorisedMatchType == native.EMatchType.MT_StandardMatch
		local var_31_1 = refereehelper.getRefereeGraphName(native.EForceDirectedGraphType.RefereeGeneralGameplay, var_31_0)
		local var_31_2 = {
			refereeGraphName = var_31_1,
			refereeFormationFocus = native.EFormationFocus.Ball
		}

		arg_31_7:add(refereeformationchange_request.RefereeFormationChangeRequest(var_31_2))

		local var_31_3 = arg_31_4:getMatchTimeEntity()

		if matchtime.canEndCurrentPeriod(arg_31_3, var_31_3) then
			local var_31_4 = native.Random.FromSystemTime():nextAsSeed()
			local var_31_5 = {
				idleDuration = 1,
				endedWithScore = false,
				randomSeed = var_31_4
			}
			local var_31_6 = class.instantiate("TimePeriodExpiredIdleRuleState", var_31_5)

			arg_31_7:addRuleStateRequest(var_31_6, arg_31_2:alloc())
		end
	end

	local function var_6_26(arg_32_0, arg_32_1, arg_32_2, arg_32_3, arg_32_4, arg_32_5, arg_32_6, arg_32_7)
		return
	end

	local function var_6_27()
		return arg_6_0.rulestateRequestSent == nil
	end

	profile.pop("makeFns")
	profile.push("add rules")
	var_6_0:add(tacklebreak_detect.TackleBreakDetect(var_6_4))
	var_6_0:add(tacklecommitted_detect.TackleCommittedDetect(var_6_3))
	var_6_0:add(caughtingoal_detect.CaughtInGoalDetect(var_6_20))
	var_6_0:add(timeperiodexpired_detect.TimePeriodExpiredDetect(timeperiodexpired_request.timePeriodExpiredRequestFactory))
	var_6_0:add(knockon_detect.KnockOnDetect(var_6_12))
	var_6_0:add(advantage_detect.AdvantageDetect(var_6_11))
	var_6_0:add(goal_detect.GoalDetect(native.EDisposalSubType.FieldGoal, native.EScoreType.FieldGoal, var_6_19))
	var_6_0:add(goal_detect.GoalDetect(native.EDisposalSubType.FieldGoal, native.EScoreType.FieldGoal40m, var_6_19))
	var_6_0:add(offside_detect.OffsideDetect(var_6_14))
	var_6_0:add(forwardpass_detect.ForwardPassDetect(var_6_13))
	var_6_0:add(intouch_detect.InTouchDetect(var_6_6, var_6_8, var_6_7, var_6_9, var_6_10))
	var_6_0:add(intouch_cornerpost_detect.InTouchCornerPostDetect(var_6_7, var_6_9))
	var_6_0:add(possessionchange_detect.PossessionChangeDetect(var_6_1))
	var_6_0:add(native.CTryAttemptDetect(var_6_21, tryattemptoutcomes.touchedInGoalRequestFactory))
	var_6_0:add(playinitiated_detect.PlayInitiatedDetect(var_6_5))
	var_6_0:add(ballcollision_detect.BallCollisionDetect(var_6_22))
	var_6_0:add(heldintackle_detect.HeldInTackleDetect(var_6_23, var_6_24))
	var_6_0:add(conditionalrule.ConditionalRule({
		var_6_27
	}, tackle_detect.TackleDetect(var_6_14, var_6_15, var_6_16, var_6_17, var_6_18)))
	var_6_0:add(conditionalrule.ConditionalRule({
		var_6_27
	}, heldup_detect.HeldUpDetect(var_6_18, var_6_15)))
	var_6_0:add(tacklecompleted_detect.TackleCompletedDetect(var_6_25))
	var_6_0:add(tacklegrounded_detect.TackleGroundedDetect(var_6_26))
	profile.pop("add rules")

	return var_6_0
end
