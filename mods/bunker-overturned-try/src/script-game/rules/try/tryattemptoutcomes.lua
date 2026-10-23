import("base.side.sidehelper")
import("core.foundation.class")
import("rules.match.matchtime")
import("rules.rulestate.rulestate_request")
import("rules.try.tryoutcome")
import("rules.try.tryscored_request")
import("script-config.design.cutscene_config")
import("game.player.playertype")

local var_0_0 = cutscene_config.MinTimeToDelayBeforeEnteringCutscene
local var_0_1 = cutscene_config.MaxTimeToDelayBeforeEnteringCutscene

-- bunker-overturned-try: a try attempt that the stock game sends straight to the bunker
-- as a no-try is instead awarded on the field first. The scorer celebrates, the scoreboard
-- shows the points and the try replay plays. Then a stinger cuts back to the referee, who
-- sends it upstairs, the bunker replay plays and the video referee rules NO TRY.
--
-- Rule state chain (stock no-try: ReactToScore(decisionPending) -> RefereeCameo(VideoReferee)
-- -> TryDecisionPending -> restart):
--   ReactToScore (as a try) -> [RefereeCameo(Try)] -> TryCelebrate (queues the try replay)
--   -> ProvisionalTryReview (wipe: the try replay plays) -> RefereeCameo(VideoReferee, queues
--   the bunker replay) -> TryDecisionPending (wipe: the bunker replay plays; NO TRY) -> restart
--
-- The match score never changes: the points are only added on the scoreboard
-- (nvm_scorecard.lua) and come off when the NO TRY decision shows. TryScoredEvent still has
-- unsuccessfulAttempt = true, so player/team stats never count the try.
--
-- ProvisionalTryChance: percent of eligible no-tries that are awarded first (100 = always).
local ProvisionalTryChance = 100
local ProvisionalTryOutcomes = {
	[native.ETryAttemptOutcome.HeldUp] = true,
	[native.ETryAttemptOutcome.KnockOn] = true,
	[native.ETryAttemptOutcome.OutsideTryArea] = true,
	[native.ETryAttemptOutcome.DoubleMovement] = true
}
-- Appends to provisionaltry_debug.txt in the game folder.
local ProvisionalTryDebug = true
-- TEST ONLY: turns every real try (not penalty tries) into this outcome, so the flow can be
-- tested on demand. "KnockOn" or "HeldUp"; nil for normal play.
local ProvisionalTryTestOutcome = nil

-- Shared state for the other bunker-overturned-try files: scoreboard points, the replay
-- selection flag and the debug log. Modules have their own environments, so it lives in _G.
local function provisionalTry()
	local var_state = rawget(_G, "ProvisionalTryState")

	if not var_state then
		var_state = {}

		rawset(_G, "ProvisionalTryState", var_state)
	end

	return var_state
end

local provisionalTryLogFile
local provisionalTryLogTried = false

local function provisionalTryLog(arg_text)
	if not ProvisionalTryDebug then
		return
	end

	pcall(function()
		if not provisionalTryLogTried then
			provisionalTryLogTried = true

			if io and io.open then
				provisionalTryLogFile = io.open("provisionaltry_debug.txt", "a")
			end
		end

		if provisionalTryLogFile then
			provisionalTryLogFile:write(tostring(arg_text) .. "\n")
			provisionalTryLogFile:flush()
		end
	end)
end

provisionalTry().log = provisionalTryLog

provisionalTryLog("tryattemptoutcomes loaded, chance " .. ProvisionalTryChance)

-- Also used by tackleoutcomes.heldUpRequestFactory (held-up tackles in the in-goal never
-- come through trySuccessRequestFactory), via provisionalTry().roll.
local function rollProvisionalTry(arg_outcome, arg_heldUpOutside, arg_match, arg_gamestate, arg_from)
	local var_reason

	if not ProvisionalTryOutcomes[arg_outcome] then
		var_reason = "outcome not eligible"
	elseif arg_heldUpOutside then
		var_reason = "held up outside the try area"
	else
		local var_matchInData = arg_match.matchInData or arg_match:getComponent("matchInData")

		if var_matchInData.onlineMultiplayer then
			var_reason = "online"
		elseif var_matchInData.gameMode == native.EGameMode.Practice then
			var_reason = "practice"
		elseif arg_gamestate:getTrainingEntity().trainingActive then
			var_reason = "training"
		elseif ProvisionalTryChance < 100 and native.Random.FromSystemTime():next(0, 100) >= ProvisionalTryChance then
			var_reason = "chance roll"
		end
	end

	provisionalTryLog(string.format("%s: outcome %s -> %s", tostring(arg_from), tostring(arg_outcome), var_reason and "stock (" .. var_reason .. ")" or "PROVISIONAL TRY"))

	return var_reason == nil
end

-- The states after the celebration: review (try replay) -> referee sends it upstairs
-- (bunker replay) -> NO TRY -> arg_outcomeState.
local function buildProvisionalTryReview(arg_outcomeState, arg_scoreTime, arg_knockOnPosition)
	local var_decision = class.instantiate("TryDecisionPendingRuleState", {
		isSuccessfulTry = false,
		provisionalTry = true,
		nextState = arg_outcomeState,
		scoreTime = arg_scoreTime,
		knockOnPosition = arg_knockOnPosition
	})
	local var_bunker = class.instantiate("RefereeCameoRuleState", {
		activateStoppageTime = true,
		isVideoReferee = true,
		delayBeforeSignal = 0,
		skipReplayEvent = false,
		waitForProvisionalOutro = true,
		nextState = var_decision,
		refereeSignal = native.EUmpireSignalTypes.VideoReferee
	})

	return class.instantiate("ProvisionalTryReviewRuleState", {
		nextState = var_bunker
	})
end

-- Where every player stood when the try was awarded. The celebration pulls everyone in to the
-- scorer, so ProvisionalTryReviewRuleState's wipe spreads them back out from here.
local function snapshotProvisionalTryPlayers(arg_gameobjects, arg_tryPosition)
	local var_players = {}

	for iter_0, iter_1 in arg_gameobjects:activeObjects(playertype.TypeId) do
		table.insert(var_players, {
			id = iter_0,
			pos = native.vec2(iter_1.pos.x, iter_1.pos.y)
		})
	end

	local var_state = provisionalTry()

	var_state.players = var_players
	var_state.tryPosition = native.vec2(arg_tryPosition.x, arg_tryPosition.y)
end

provisionalTry().roll = rollProvisionalTry
provisionalTry().snapshotPlayers = snapshotProvisionalTryPlayers
provisionalTry().buildReview = buildProvisionalTryReview

function trySuccessRequestFactory(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7, arg_1_8)
	local var_1_0 = assert(arg_1_8.scorer)
	local var_1_1 = arg_1_8.gamerId
	local var_1_2 = arg_1_8.scoringSide
	local var_1_3 = arg_1_8.scoringPosition
	local var_1_4 = arg_1_8.attemptGuid
	local var_1_5 = arg_1_8.diveOnLooseBall
	local var_1_6 = false
	local var_1_7 = native.Random.FromSystemTime():nextAsSeed()
	local var_1_8 = arg_1_8.tryAttemptOutcome

	-- bunker-overturned-try: test override
	if ProvisionalTryTestOutcome and var_1_8 == native.ETryAttemptOutcome.Try and not arg_1_8.forceProvisional then
		var_1_8 = native.ETryAttemptOutcome[ProvisionalTryTestOutcome]

		provisionalTryLog("TEST: try turned into " .. ProvisionalTryTestOutcome)
	end
	local var_1_9 = arg_1_8.ballHeldUpOutsideTryArea
	local var_1_10 = arg_1_3:getSide(var_1_2):getPlayDir()
	local var_1_11 = arg_1_8.divingTry
	local var_1_12 = arg_1_4:getMatchProgressionEntity()
	local var_1_13 = var_1_12.tackleCount
	local var_1_14 = var_1_12.tackleSetStartPosition
	local var_1_15 = arg_1_8.isBonusTry
	local var_1_16 = arg_1_8.isDropDownTry
	local var_1_17 = arg_1_4:getMatchTimeEntity()
	local var_1_18 = var_1_17.goldenPointActive
	local var_1_19 = var_1_17.goldenTryActive
	local var_1_20 = var_1_8 == native.ETryAttemptOutcome.Try or var_1_8 == native.ETryAttemptOutcome.PenaltyTry
	local var_1_21 = arg_1_3.matchInData
	local var_1_22 = var_1_21.isWorldCup

	ASSERT(var_1_22 ~= nil)

	local var_1_23 = var_1_20 and not var_1_22 and (var_1_21.cutsceneInfo.playGFIntroCutscene or var_1_2 == sidehelper.home)
	local var_1_24 = var_1_20 and (var_1_18 or var_1_19) or matchtime.canEndCurrentPeriod(arg_1_3, var_1_17)
	local var_1_25 = var_1_20 and not var_1_18 and not var_1_19
	local var_1_26 = arg_1_1.hooks
	local var_1_27 = var_1_26 and var_1_26:getHook("TryDebugHook")

	if var_1_27 then
		var_1_27:setAttemptPosition(var_1_3)
	end

	local var_1_28 = VERIFY(arg_1_3:getSide(var_1_2)).assetIdMap[var_1_0]

	ASSERT(var_1_28)

	if not var_1_20 then
		var_1_6 = true
	elseif arg_1_4:getActiveTackleEntity():getMostRecentActiveTackle() then
		var_1_6 = native.Random.FromSystemTime():next(0, 100) <= 25
	end

	if var_1_27 and var_1_27.forceVideoReferee then
		var_1_6 = true
	end

	local var_1_29 = arg_1_3:getComponent("matchInfo"):getMatchSecondsElapsed(arg_1_4, arg_1_6)
	local var_1_30 = {
		assetId = var_1_28,
		attemptGuid = var_1_4,
		currentTackleCount = var_1_13,
		canEndCurrentPeriod = var_1_24,
		tryAttemptOutcome = var_1_8,
		isTry = var_1_20,
		scorer = var_1_0,
		scoringSide = var_1_2,
		scoringPosition = var_1_3,
		diveOnLooseBall = var_1_5,
		divingTry = var_1_11,
		tackleSetStartPosition = var_1_14,
		videoRefereeRequired = var_1_6,
		allowConversionKick = var_1_25,
		gamerId = var_1_1,
		ballHeldUpOutsideTryArea = var_1_9,
		randomSeed = var_1_7,
		isBonusTry = var_1_15,
		scoreTime = var_1_29,
		isDropDownTry = var_1_16
	}
	local var_1_31 = tryoutcome.getTryAttemptOutcomeRulestate(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, var_1_30, arg_1_7)

	var_1_30.isKnockOn = var_1_31.isKnockOn

	-- bunker-overturned-try
	-- forceProvisional: already rolled (generalgameplay_rulestate.lua's knock-on in goal).
	local var_p_0 = not var_1_20 and (arg_1_8.forceProvisional or rollProvisionalTry(var_1_8, var_1_9, arg_1_3, arg_1_4, "try attempt"))

	if var_p_0 then
		var_1_30.provisionalTry = true

		snapshotProvisionalTryPlayers(arg_1_5, var_1_3)

		provisionalTryLog(string.format("provisional try: outcome %s, side %s, knock-on %s, next %s", tostring(var_1_8), tostring(var_1_2), tostring(var_1_31.isKnockOn), type(var_1_31.outcomeState)))
	end

	arg_1_7:add(tryscored_request.TryScoredRequest(var_1_30))

	local var_1_32 = arg_1_8.quickCutToCutscene
	local var_1_33 = arg_1_8.delayBeforeQuickCut

	if var_1_32 then
		ASSERT(var_1_33)
	end

	local var_1_34 = var_1_32 and var_1_33 or var_0_1
	local var_1_35 = var_1_32 and var_1_33 or var_0_0
	local var_1_36 = {
		isTryAttempt = true,
		maxDelayBeforeCutscene = var_1_34,
		minDelayBeforeCutscene = var_1_35,
		quickCutToCutscene = var_1_32,
		randomSeed = var_1_7,
		decisionPending = var_1_6,
		scoringSide = var_1_2,
		scoringGamer = var_1_1,
		scorer = var_1_0,
		scorePosition = var_1_3,
		nextState = var_1_31.outcomeState,
		unsuccessfulAttempt = not var_1_20,
		tryAttemptOutcome = var_1_8,
		playCheerleaderCameo = var_1_23,
		isBonusTry = var_1_15
	}

	-- bunker-overturned-try: react as if it's a try, then review it after the celebration.
	if var_p_0 then
		local var_p_3 = buildProvisionalTryReview(var_1_31.outcomeState, var_1_29, var_1_31.isKnockOn and var_1_3 or nil)

		var_1_36.decisionPending = false
		var_1_36.unsuccessfulAttempt = false
		var_1_36.tryAttemptOutcome = native.ETryAttemptOutcome.Try
		var_1_36.playCheerleaderCameo = not var_1_22 and (var_1_21.cutsceneInfo.playGFIntroCutscene or var_1_2 == sidehelper.home)
		var_1_36.nextState = var_p_3
	end

	local var_1_37 = class.instantiate("ReactToScoreRuleState", var_1_36)

	arg_1_7:addRuleStateRequest(var_1_37, arg_1_2:alloc())
end

function touchedInGoalRequestFactory(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8)
	local var_2_0 = native.Random.FromSystemTime():nextAsSeed()
	local var_2_1 = arg_2_4:getMatchTimeEntity()
	local var_2_2 = matchtime.canEndCurrentPeriod(arg_2_3, var_2_1)
	local var_2_3

	if var_2_2 then
		local var_2_4 = {
			idleDuration = 1,
			endedWithScore = false,
			randomSeed = var_2_0
		}

		var_2_3 = class.instantiate("TimePeriodExpiredIdleRuleState", var_2_4)
	else
		local var_2_5 = {
			restartAtTwentyMetres = arg_2_8.restartAtTwentyMetres,
			kickerSide = arg_2_8.offendingSide,
			actionGuid = arg_2_2:alloc()
		}
		local var_2_6 = class.instantiate("LineDropOutSetupRuleState", var_2_5)
		local var_2_7 = {
			activateStoppageTime = true,
			blockGamerSwitching = false,
			enablePlayerSwitching = false,
			idlePeriod = 1.5,
			randomSeed = var_2_0,
			nextState = var_2_6
		}

		var_2_3 = class.instantiate("InTouchIdlePlayersRuleState", var_2_7)
	end

	local var_2_8 = arg_2_1.hud
	local var_2_9 = var_2_8 and var_2_8:getElement("playernamefieldhud")

	if var_2_9 then
		var_2_9:hide()
	end

	return rulestate_request.RuleStateRequest(var_2_3, arg_2_2:alloc())
end
