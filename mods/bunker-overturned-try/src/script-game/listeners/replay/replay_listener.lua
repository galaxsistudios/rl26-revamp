import("core.foundation.tablex")
import("game.replay.replaycameraselection")
import("sim.replay.replay_ustate")
import("sim.replay.interactivereplay_ustate")
import("design.replaymoments_config")
import("design.replaymoments_selection")
import("script-config.rules.rules.rulesenvironment")
import("core.profile.profile")

-- bunker-overturned-try: shared state, see rules/try/tryattemptoutcomes.lua.
local function provisionalTry()
	local var_state = rawget(_G, "ProvisionalTryState")

	if not var_state then
		var_state = {}

		rawset(_G, "ProvisionalTryState", var_state)
	end

	return var_state
end

-- Moments the provisional try's first replay must not pick: it should look like an
-- ordinary try replay, and the bunker replay comes later.
local ProvisionalTryHiddenAliases = {
	"videoref",
	"ballstrip",
	"knockon",
	"unsuccessfultryattempt"
}

local var_0_0 = native.getEnvironment()
local var_0_1 = var_0_0:argExists("noreplays")
local var_0_2 = var_0_0:argExists("interactiveReplays")
local var_0_3 = {
	Mark = 2,
	Kill = 4,
	Start = 1,
	Stop = 3
}
local var_0_4 = {
	CollectTestRuleState = var_0_3.Start,
	TackleTestRuleState = var_0_3.Start,
	TackleTrainingActiveRuleState = var_0_3.Start,
	TackleDemoRuleState = var_0_3.Start,
	TryTestBedRuleState = var_0_3.Start,
	PassingTestRuleState = var_0_3.Start,
	PlayTheBallTrainingRuleState = var_0_3.Start,
	GeneralGameplayRuleState = var_0_3.Start,
	TapRestartRuleState = var_0_3.Start,
	ScrumRuleState = var_0_3.Start,
	TryCelebrateRuleState = var_0_3.Stop
}
local var_0_5 = {
	CollectTestRuleState = var_0_3.Stop,
	TackleTestRuleState = var_0_3.Stop,
	TackleTrainingActiveRuleState = var_0_3.Stop,
	TackleDemoRuleState = var_0_3.Stop,
	TryTestBedRuleState = var_0_3.Stop,
	PassingTestRuleState = var_0_3.Stop,
	PlayTheBallTrainingRuleState = var_0_3.Stop
}

Class("ReplayListener", function(arg_1_0, arg_1_1)
	arg_1_0.enabled = not arg_1_1.noreplays
end)

function ReplayListener.registerWithMatchSim(arg_2_0, arg_2_1)
	arg_2_1:registerRuleStateListener(arg_2_0)

	local function var_2_0(arg_3_0)
		return function(...)
			profile.push(arg_3_0)

			local var_4_0 = arg_2_0[arg_3_0](arg_2_0, ...)

			profile.pop(arg_3_0)

			return var_4_0
		end
	end

	local var_2_1 = {
		AvoidBeingTackledEvent = var_2_0("onAvoidBeingTackled"),
		BeAProSkipEvent = var_2_0("onBeAProSkip"),
		CollectBallEvent = var_2_0("onCollectBall"),
		ConversionOutcomeEvent = var_2_0("onConversionOutcome"),
		DisposalEvent = var_2_0("onDisposal"),
		FieldGoalSuccessEvent = var_2_0("onFieldGoalSuccess"),
		ForceStartRecordEvent = var_2_0("onForceStartRecord"),
		ForceStopRecordEvent = var_2_0("onForceStopRecord"),
		GameOverEvent = var_2_0("onGameOver"),
		InTouchEvent = var_2_0("onInTouch"),
		LineBreakEvent = var_2_0("onLineBreak"),
		PenaltyGoalSuccessEvent = var_2_0("onPenaltyGoalSuccess"),
		PlacedKickInitiatedEvent = var_2_0("onPlacedKickInitiated"),
		QueueReplayEvent = var_2_0("onQueueReplay"),
		ReplayMarkerEvent = var_2_0("onReplayMarker"),
		IncrementTackleCountEvent = var_2_0("onIncrementTackleCountEvent"),
		TackleCompletedEvent = var_2_0("onTackleCompletedEvent"),
		BallStripEvent = var_2_0("onBallStrip"),
		TryAttemptEvent = var_2_0("onTryAttempt"),
		TryScoredEvent = var_2_0("onTryScored"),
		PlaceKickStateChangeEvent = var_2_0("onPlaceKickStateChange"),
		BigHitEvent = var_2_0("onBigHit"),
		KnockOnEvent = var_2_0("onKnockOnEvent"),
		ContestedCollectFailEvent = var_2_0("onContestedCollect"),
		CutscenePlayEvent = var_2_0("onCutscenePlay")
	}

	arg_2_1:registerUpdateable(function(...)
		arg_2_0:update(...)
	end)

	for iter_2_0, iter_2_1 in pairs(var_2_1) do
		arg_2_1:registerSolidEventListener(iter_2_1, iter_2_0)
	end

	arg_2_1:registerOnPreWipe(function(...)
		return arg_2_0:onPreWipe(...)
	end)

	arg_2_0.matchSim = arg_2_1
end

local var_0_6 = {}
local var_0_7 = 0

for iter_0_0, iter_0_1 in pairs(replaymoments_config.Moments) do
	local var_0_8 = iter_0_1.name

	if not var_0_6[var_0_8] then
		var_0_6[var_0_8] = {
			var_0_8
		}
		var_0_7 = var_0_7 + 1
	end

	local var_0_9 = iter_0_1.alias

	if var_0_9 then
		for iter_0_2, iter_0_3 in ipairs(var_0_9) do
			local var_0_10 = var_0_6[iter_0_3]

			if not var_0_10 then
				var_0_10 = {
					iter_0_1.name
				}
				var_0_6[iter_0_3] = var_0_10
				var_0_7 = var_0_7 + 1
			else
				table.insert(var_0_10, iter_0_1.name)
			end
		end
	end
end

local function var_0_11(arg_7_0, arg_7_1)
	print("[Replay] selecting moments")
	assert(arg_7_1)

	local var_7_0 = native.createTable(0, var_0_7)
	local var_7_1

	for iter_7_0, iter_7_1 in pairs(var_0_6) do
		local var_7_2 = tablex.clone(iter_7_1)

		while #var_7_2 > 0 do
			local var_7_3 = arg_7_1:randomInteger(#var_7_2) + 1
			local var_7_4 = VERIFY(var_7_2[var_7_3])

			var_7_1 = native.CReplayMoments()
			var_7_1 = arg_7_0:findMoments(var_7_4, var_7_1)

			if var_7_1.count > 0 then
				var_7_0[iter_7_0] = var_7_1

				break
			else
				var_7_1:dispose()
				table.remove(var_7_2, var_7_3)
			end
		end

		if not var_7_0[iter_7_0] then
			print("[Replay] No available replay moments for alias \"" .. iter_7_0 .. "\"")
		else
			for iter_7_2, iter_7_3 in var_7_1.moments:iter() do
				print("[Replay] Selected moment \"" .. iter_7_3.name .. "\" for alias \"" .. iter_7_0 .. "\"")
			end
		end
	end

	return var_7_0
end

function ReplayListener.startRecording(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5)
	if arg_8_3:getComponent("matchInData").gameMode == native.EGameMode.Practice then
		return
	end

	profile.push("startRecording")

	local var_8_0 = arg_8_4.replayManager

	if not var_8_0:isRecording() then
		formatPrintT("[Replay] ReplayListener:startRecording - Time:%t, wipeGuid:%t", arg_8_5, var_8_0.wipeGuid)
		var_8_0:beginSegment(arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5)
	else
		formatPrintT("[Replay] ReplayListener:startRecording - ALREADY RECORDING - Time:%t, wipeGuid:%t", arg_8_5, var_8_0.wipeGuid)
	end

	arg_8_4.simTimeSystem:addImportantSimTime(arg_8_5)
	profile.pop("startRecording")
end

function ReplayListener.stopRecording(arg_9_0, arg_9_1, arg_9_2, arg_9_3, arg_9_4)
	profile.push("stopRecording")

	local var_9_0 = arg_9_3.replayManager

	arg_9_0.pendingSegmentBreakTime = nil

	if arg_9_4 then
		formatPrintT("[Replay] ReplayListener:stopRecording - Time:%t, wipeGuid:%t", arg_9_4, var_9_0.wipeGuid)
	else
		formatPrintT("[Replay] ReplayListener:stopRecording - Time:nil, wipeGuid:%t", var_9_0.wipeGuid)
	end

	local var_9_1 = var_9_0.segment

	var_9_0:endSegment(arg_9_2, arg_9_4)

	if var_9_1 then
		local var_9_2 = arg_9_3.replaySaveSystem

		for iter_9_0, iter_9_1 in var_9_1.replayMoments.moments:iter() do
			iter_9_1:captureReplayData(var_9_2.replaySaveSystem, var_9_1)
			ASSERT(iter_9_1.saveData)

			local var_9_3 = VERIFY(var_9_0.replayHighlights)
			local var_9_4 = VERIFY(arg_9_1:getMatchProgressionEntity())

			var_9_3:addMoment(iter_9_1, var_9_4)
		end
	end

	arg_9_0.lineBroken = nil

	arg_9_3.simTimeSystem:addImportantSimTime(arg_9_4)
	formatPrint("[Replay] calling addImportantSimTime at time %0.2f", arg_9_4:ToSeconds())
	profile.pop("stopRecording")
end

function ReplayListener.mark(arg_10_0, arg_10_1, arg_10_2, arg_10_3, arg_10_4, arg_10_5)
	arg_10_0:stopRecording(arg_10_1, arg_10_2, arg_10_4, arg_10_5)
	arg_10_0:startRecording(arg_10_1, arg_10_2, arg_10_3, arg_10_4, arg_10_5)
end

function ReplayListener.killCurrentSegment(arg_11_0, arg_11_1, arg_11_2, arg_11_3, arg_11_4, arg_11_5)
	local var_11_0 = arg_11_4.replayManager

	var_11_0:endSegment(arg_11_2, arg_11_5)
	var_11_0:deleteLastSegment()
end

function ReplayListener.addMoment(arg_12_0, arg_12_1, arg_12_2, arg_12_3, arg_12_4, arg_12_5, arg_12_6, arg_12_7, arg_12_8, arg_12_9)
	local var_12_0 = {
		{
			time = arg_12_3,
			trackingId = VERIFY(arg_12_2)
		}
	}

	formatPrint("[Replay] Adding moment %s", arg_12_1)

	local var_12_1 = arg_12_8.replayManager
	local var_12_2 = arg_12_0.matchSim and arg_12_0.matchSim:getSimulationTime() or arg_12_4
	local var_12_3 = replaycameraselection.createMomentShotsFromConfig(arg_12_1, arg_12_3, arg_12_5, var_12_0, arg_12_6, var_12_2, arg_12_7, arg_12_8)
	local var_12_4, var_12_5 = var_12_1:addMoment(arg_12_1, var_12_3, arg_12_4, arg_12_9)

	arg_12_8.simTimeSystem:addImportantSimTime(arg_12_4)
	formatPrint("[Replay] calling addImportantSimTime at time %0.2f", arg_12_4:ToSeconds())

	return var_12_4
end

function ReplayListener.queueReplay(arg_13_0, arg_13_1, arg_13_2, arg_13_3, arg_13_4, arg_13_5, arg_13_6, arg_13_7, arg_13_8, arg_13_9)
	local var_13_0 = arg_13_2.matchSim
	local var_13_1 = VERIFY(arg_13_4.network)
	local var_13_2 = arg_13_4.replayManager
	local var_13_3 = arg_13_6:getComponent("matchInData")
	local var_13_4 = arg_13_6:getComponent("matchInProgressData")

	if not var_13_2 or not arg_13_0.enabled then
		return
	end

	local var_13_5 = arg_13_2.engine
	local var_13_6 = var_13_5:getParty():getPrimaryPartyMember()
	local var_13_7 = var_13_6 and var_13_6.settings.replays or native.EReplaySettings.all

	if not var_13_3.onlineMultiplayer and (var_13_7 == native.EReplaySettings.none:toInt() or var_13_7 == native.EReplaySettings.videorefonly:toInt() and not arg_13_1.isVideoReferee) then
		return
	end

	local var_13_8 = native.Random(var_13_4.matchSeed)
	local var_13_9
	local var_13_10 = var_0_11(var_13_2, var_13_8)

	-- bunker-overturned-try: the celebration's replay of a provisional try.
	local var_p_0 = not arg_13_1.isVideoReferee and provisionalTry().replayPending

	if var_p_0 then
		for iter_p_0, iter_p_1 in ipairs(ProvisionalTryHiddenAliases) do
			var_13_10[iter_p_1] = nil
		end
	end
	local var_13_11 = replaymoments_selection.Select(var_13_10, var_13_8)

	if not var_13_11 or var_13_11.count == 0 then
		print("[Replay] Failed to find any suitable replay moment for playback")
	end

	local var_13_12 = false

	if var_13_11 then
		var_13_2:endSegment(arg_13_8, arg_13_1.time)

		local var_13_13 = var_13_2:createReplayInstance(var_13_11)

		if not var_13_13 then
			print("[Replay] Failed to create replay instance.")
		else
			var_13_12 = true
		end

		if var_13_12 and arg_13_0.matchSim then
			if var_0_2 then
				var_13_0:queueUniverseStateNoPreload(arg_13_0.engine, interactivereplay_ustate.InteractiveReplayUniverseState(var_13_5, var_13_2, nil, {
					skipRuleName = "ManuallyLaunchedRulestate",
					continueGameplay = true,
					skipStateProvider = arg_13_4.skipStateProvider,
					skipConfig = {}
				}))
			end

			local var_p_1 = replay_ustate.ReplayUniverseState({
				skipRuleName = "Default",
				loopPlayBack = false,
				hudFeature = "Replay",
				engine = VERIFY(var_13_5),
				network = VERIFY(var_13_1),
				services = arg_13_4,
				gameobjects = arg_13_8,
				replayManager = var_13_2,
				replayInstance = var_13_13,
				skipStateProvider = arg_13_4.skipStateProvider,
				skipConfig = {}
			})

			-- bunker-overturned-try: replay-team-stinger's screenwipe.lua stingers out of
			-- this replay back to the referee.
			if var_p_0 then
				var_p_1.provisionalTryReplay = true
			end

			arg_13_0.matchSim:queueUniverseStateNoPreload(arg_13_0.engine, var_p_1)
		end

		local var_p_2 = provisionalTry().log

		if var_p_2 and (var_p_0 or provisionalTry().side) then
			var_p_2(string.format("replay queued: %s, video referee %s, instance %s", var_p_0 and "provisional try" or "bunker", tostring(arg_13_1.isVideoReferee), tostring(var_13_12)))
		end
	end

	if var_13_3.onlineMultiplayer and arg_13_0.matchSim and not var_13_12 then
		arg_13_0.matchSim:queueUniverseStateNoPreload(arg_13_0.engine, replay_ustate.ReplayUniverseState({
			skipRuleName = "Default",
			loopPlayBack = false,
			hudFeature = "Replay",
			engine = VERIFY(var_13_5),
			network = VERIFY(var_13_1),
			services = arg_13_4,
			gameobjects = arg_13_8,
			replayManager = var_13_2,
			skipStateProvider = arg_13_4.skipStateProvider,
			skipConfig = {}
		}))
	end
end

function ReplayListener.onPreWipe(arg_14_0, arg_14_1, arg_14_2, arg_14_3, arg_14_4, arg_14_5, arg_14_6, arg_14_7, arg_14_8, arg_14_9, arg_14_10, arg_14_11)
	arg_14_0:stopRecording(arg_14_8, arg_14_9, arg_14_4, arg_14_10)
	arg_14_4.replayManager:onWipe(arg_14_6)
end

function ReplayListener.onRuleStateChanged(arg_15_0, arg_15_1, arg_15_2, arg_15_3, arg_15_4, arg_15_5, arg_15_6, arg_15_7)
	assert(not arg_15_1 or not arg_15_2)

	local var_15_0 = arg_15_1 and var_0_4[type(arg_15_1)]
	local var_15_1 = arg_15_2 and var_0_5[type(arg_15_2)]
	local var_15_2 = var_15_0 or var_15_1

	if var_15_2 then
		if var_15_2 == var_0_3.Start then
			arg_15_0:startRecording(arg_15_5, arg_15_6, arg_15_4, arg_15_3, arg_15_7)
		elseif var_15_2 == var_0_3.Mark then
			arg_15_0:mark(arg_15_5, arg_15_6, arg_15_4, arg_15_3, arg_15_7)
		elseif var_15_2 == var_0_3.Stop then
			arg_15_0:stopRecording(arg_15_5, arg_15_6, arg_15_3, arg_15_7)
		end
	end
end

function ReplayListener.addPendingSegmentBreak(arg_16_0, arg_16_1, arg_16_2, arg_16_3)
	local var_16_0 = arg_16_2 + arg_16_3

	if not arg_16_0.pendingSegmentBreakTime or var_16_0 < arg_16_0.pendingSegmentBreakTime then
		arg_16_1.simTimeSystem:addImportantSimTime(var_16_0)

		arg_16_0.pendingSegmentBreakTime = var_16_0
	end
end

function ReplayListener.update(arg_17_0, arg_17_1, arg_17_2, arg_17_3, arg_17_4, arg_17_5, arg_17_6, arg_17_7, arg_17_8, arg_17_9, arg_17_10)
	if arg_17_0.pendingSegmentBreakTime and arg_17_9 >= arg_17_0.pendingSegmentBreakTime then
		if arg_17_3.replayManager:isRecording() then
			arg_17_0:stopRecording(arg_17_6, arg_17_7, arg_17_3, arg_17_9)
			arg_17_0:startRecording(arg_17_6, arg_17_7, arg_17_5, arg_17_3, arg_17_9)
		end

		arg_17_0.pendingSegmentBreakTime = nil
	end
end

function ReplayListener.onQueueReplay(arg_18_0, arg_18_1, arg_18_2, arg_18_3, arg_18_4, arg_18_5, arg_18_6, arg_18_7, arg_18_8, arg_18_9)
	arg_18_0:stopRecording(arg_18_7, arg_18_8, arg_18_4, arg_18_1.time)
	arg_18_0:queueReplay(arg_18_1, arg_18_2, arg_18_3, arg_18_4, arg_18_5, arg_18_6, arg_18_7, arg_18_8, arg_18_9)
end

function ReplayListener.onAvoidBeingTackled(arg_19_0, arg_19_1, arg_19_2, arg_19_3, arg_19_4, arg_19_5, arg_19_6, arg_19_7, arg_19_8, arg_19_9)
	local var_19_0 = arg_19_0.lineBroken and replaymoments_config.Moments.EvasionLineUnbroken.name or replaymoments_config.Moments.EvasionLineBroken.name

	arg_19_0:addMoment(var_19_0, arg_19_1.maker, arg_19_1.time, arg_19_1.time, arg_19_1.position, arg_19_6, arg_19_8, arg_19_4)
end

function ReplayListener.onBeAProSkip(arg_20_0, arg_20_1, arg_20_2, arg_20_3, arg_20_4, arg_20_5, arg_20_6, arg_20_7, arg_20_8, arg_20_9)
	arg_20_0:killCurrentSegment(arg_20_7, arg_20_8, arg_20_6, arg_20_4, arg_20_1.time)
end

function ReplayListener.onCollectBall(arg_21_0, arg_21_1, arg_21_2, arg_21_3, arg_21_4, arg_21_5, arg_21_6, arg_21_7, arg_21_8, arg_21_9)
	local var_21_0 = arg_21_1.disposalInfo

	if not var_21_0 then
		return
	end

	if var_21_0.disposalType == native.EDisposalType.Kick and var_21_0.disposalSubType ~= native.EDisposalSubType.PlayTheBall then
		arg_21_0:addMoment(replaymoments_config.Moments.KickCollect.name, arg_21_1.maker, arg_21_1.time, arg_21_1.time, arg_21_1.position, arg_21_6, arg_21_8, arg_21_4)
	end
end

function ReplayListener.onConversionOutcome(arg_22_0, arg_22_1, arg_22_2, arg_22_3, arg_22_4, arg_22_5, arg_22_6, arg_22_7, arg_22_8, arg_22_9)
	arg_22_0:addMoment(replaymoments_config.Moments.Goal.name, arg_22_1.kickerId, arg_22_1.time, arg_22_1.time, arg_22_1.ballPosition:tovec2(), arg_22_6, arg_22_8, arg_22_4)
end

function ReplayListener.onDisposal(arg_23_0, arg_23_1, arg_23_2, arg_23_3, arg_23_4, arg_23_5, arg_23_6, arg_23_7, arg_23_8, arg_23_9)
	if arg_23_1.disposalType == native.EDisposalType.Kick then
		if arg_23_1.disposalSubType ~= native.EDisposalSubType.PlayTheBall then
			local var_23_0 = arg_23_8:getBallObject():getBallTrajectory()
			local var_23_1 = var_23_0 and var_23_0:getTailTime()
			local var_23_2 = var_23_0 and var_23_0:getNextBouncePos(var_23_1)

			if not var_23_2 or math.abs(var_23_2.x) > rulesenvironment.deadBallLine or math.abs(var_23_2.y) > rulesenvironment.halfFieldWidth then
				arg_23_0:addMoment(replaymoments_config.Moments.KickToTouch.name, arg_23_1.maker, arg_23_1.time, arg_23_1.time, arg_23_1.originPos, arg_23_6, arg_23_8, arg_23_4)
			else
				arg_23_0:addMoment(replaymoments_config.Moments.Kick.name, arg_23_1.maker, arg_23_1.time, arg_23_1.time, arg_23_1.originPos, arg_23_6, arg_23_8, arg_23_4)
			end
		else
			arg_23_0:mark(arg_23_7, arg_23_8, arg_23_6, arg_23_4, arg_23_1.time)
		end
	elseif arg_23_1.disposalType == native.EDisposalType.Pass and arg_23_1.disposalSubType == native.EDisposalSubType.Offload then
		local var_23_3 = arg_23_0.lineBroken and replaymoments_config.Moments.OffloadLineUnbroken.name or replaymoments_config.Moments.OffloadLineBroken.name

		arg_23_0:addMoment(var_23_3, arg_23_1.maker, arg_23_1.time, arg_23_1.time, arg_23_1.originPos, arg_23_6, arg_23_8, arg_23_4)
	end
end

function ReplayListener.onFieldGoalSuccess(arg_24_0, arg_24_1, arg_24_2, arg_24_3, arg_24_4, arg_24_5, arg_24_6, arg_24_7, arg_24_8, arg_24_9)
	arg_24_0:addMoment(replaymoments_config.Moments.Goal.name, arg_24_1.scorer, arg_24_1.time, arg_24_1.time, arg_24_1.kickOrigin, arg_24_6, arg_24_8, arg_24_4)
end

function ReplayListener.onForceStartRecord(arg_25_0, arg_25_1, arg_25_2, arg_25_3, arg_25_4, arg_25_5, arg_25_6, arg_25_7, arg_25_8, arg_25_9)
	arg_25_0:startRecording(arg_25_7, arg_25_8, arg_25_6, arg_25_4, arg_25_1.time)
end

function ReplayListener.onForceStopRecord(arg_26_0, arg_26_1, arg_26_2, arg_26_3, arg_26_4, arg_26_5, arg_26_6, arg_26_7, arg_26_8, arg_26_9)
	arg_26_0:stopRecording(arg_26_7, arg_26_8, arg_26_4, arg_26_1.time)
end

function ReplayListener.onGameOver(arg_27_0, arg_27_1, arg_27_2, arg_27_3, arg_27_4, arg_27_5, arg_27_6, arg_27_7, arg_27_8, arg_27_9)
	return
end

function ReplayListener.onInTouch(arg_28_0, arg_28_1, arg_28_2, arg_28_3, arg_28_4, arg_28_5, arg_28_6, arg_28_7, arg_28_8, arg_28_9)
	if not arg_28_1.offenderId then
		return
	end

	if arg_28_7:getBallEntity():getOwnerId(arg_28_1.time) then
		arg_28_0:addMoment(replaymoments_config.Moments.InTouchBallOwned.name, arg_28_1.offenderId, arg_28_1.time, arg_28_1.time, arg_28_1.outPosition, arg_28_6, arg_28_8, arg_28_4)
	else
		arg_28_0:addMoment(replaymoments_config.Moments.InTouchBallNotOwned.name, arg_28_1.offenderId, arg_28_1.time, arg_28_1.time, arg_28_1.outPosition, arg_28_6, arg_28_8, arg_28_4)
	end
end

function ReplayListener.onKnockOnEvent(arg_29_0, arg_29_1, arg_29_2, arg_29_3, arg_29_4, arg_29_5, arg_29_6, arg_29_7, arg_29_8, arg_29_9)
	arg_29_0:addMoment(replaymoments_config.Moments.KnockOn.name, arg_29_1.offenderId, arg_29_1.time, arg_29_1.time, arg_29_1.position, arg_29_6, arg_29_8, arg_29_4)
end

function ReplayListener.onBigHit(arg_30_0, arg_30_1, arg_30_2, arg_30_3, arg_30_4, arg_30_5, arg_30_6, arg_30_7, arg_30_8, arg_30_9)
	local var_30_0 = VERIFY(arg_30_1.maker)
	local var_30_1 = arg_30_8:getGameObject(var_30_0).pos

	arg_30_0:addMoment(replaymoments_config.Moments.BigHit.name, var_30_0, arg_30_1.time, arg_30_1.time, var_30_1, arg_30_6, arg_30_8, arg_30_4)
end

function ReplayListener.onContestedCollect(arg_31_0, arg_31_1, arg_31_2, arg_31_3, arg_31_4, arg_31_5, arg_31_6, arg_31_7, arg_31_8, arg_31_9)
	local var_31_0 = VERIFY(arg_31_1.maker)
	local var_31_1 = arg_31_8:getGameObject(var_31_0).pos

	arg_31_0:addMoment(replaymoments_config.Moments.ContestedCollect.name, var_31_0, arg_31_1.time, arg_31_1.time, var_31_1, arg_31_6, arg_31_8, arg_31_4)
end

function ReplayListener.onCutscenePlay(arg_32_0, arg_32_1, arg_32_2, arg_32_3, arg_32_4, arg_32_5, arg_32_6, arg_32_7, arg_32_8, arg_32_9)
	ASSERT(arg_32_1.time)
	arg_32_0:stopRecording(arg_32_7, arg_32_8, arg_32_4, arg_32_1.time)
end

function ReplayListener.onLineBreak(arg_33_0, arg_33_1, arg_33_2, arg_33_3, arg_33_4, arg_33_5, arg_33_6, arg_33_7, arg_33_8, arg_33_9)
	arg_33_0:addMoment(replaymoments_config.Moments.LineBreak.name, arg_33_1.ballCarrierId, arg_33_1.time, arg_33_1.time, arg_33_1.position, arg_33_6, arg_33_8, arg_33_4)

	arg_33_0.lineBroken = true
end

function ReplayListener.onPenaltyGoalSuccess(arg_34_0, arg_34_1, arg_34_2, arg_34_3, arg_34_4, arg_34_5, arg_34_6, arg_34_7, arg_34_8, arg_34_9)
	arg_34_0:addMoment(replaymoments_config.Moments.Goal.name, arg_34_1.kickerId, arg_34_1.time, arg_34_1.time, arg_34_1.kickPosition, arg_34_6, arg_34_8, arg_34_4)
end

function ReplayListener.onPlacedKickInitiated(arg_35_0, arg_35_1, arg_35_2, arg_35_3, arg_35_4, arg_35_5, arg_35_6, arg_35_7, arg_35_8, arg_35_9)
	local var_35_0 = arg_35_6:getComponent("matchInData")

	arg_35_0:startRecording(arg_35_7, arg_35_8, arg_35_6, arg_35_4, arg_35_1.time)
end

function ReplayListener.onPlaceKickStateChange(arg_36_0, arg_36_1, arg_36_2, arg_36_3, arg_36_4, arg_36_5, arg_36_6, arg_36_7, arg_36_8, arg_36_9)
	if arg_36_6:getComponent("matchInData").gameMode == native.EGameMode.Practice then
		return
	end

	if arg_36_1.state == native.EPlaceKickState.Windup or arg_36_1.state == native.EPlaceKickState.Kick then
		arg_36_0:startRecording(arg_36_7, arg_36_8, arg_36_6, arg_36_4, arg_36_1.time)
	end
end

function ReplayListener.onReplayMarker(arg_37_0, arg_37_1, arg_37_2, arg_37_3, arg_37_4, arg_37_5, arg_37_6, arg_37_7, arg_37_8, arg_37_9)
	arg_37_0:mark(arg_37_7, arg_37_8, arg_37_6, arg_37_4, arg_37_1.time)
end

function ReplayListener.onIncrementTackleCountEvent(arg_38_0, arg_38_1, arg_38_2, arg_38_3, arg_38_4, arg_38_5, arg_38_6, arg_38_7, arg_38_8, arg_38_9)
	return
end

function ReplayListener.onTackleCompletedEvent(arg_39_0, arg_39_1, arg_39_2, arg_39_3, arg_39_4, arg_39_5, arg_39_6, arg_39_7, arg_39_8, arg_39_9)
	ASSERT(arg_39_1.maker)
	ASSERT(arg_39_1.time)
	ASSERT(arg_39_1.position)

	if arg_39_7:getBallEntity():getOwnerId(arg_39_1.time) ~= arg_39_1.maker then
		return
	end

	arg_39_0:addMoment(replaymoments_config.Moments.TackleComplete.name, arg_39_1.maker, arg_39_1.time, arg_39_1.time, arg_39_1.position, arg_39_6, arg_39_8, arg_39_4)
end

function ReplayListener.onBallStrip(arg_40_0, arg_40_1, arg_40_2, arg_40_3, arg_40_4, arg_40_5, arg_40_6, arg_40_7, arg_40_8, arg_40_9)
	arg_40_0:addMoment(replaymoments_config.Moments.BallStrip.name, arg_40_1.maker, arg_40_1.time, arg_40_1.time, arg_40_1.position, arg_40_6, arg_40_8, arg_40_4)
end

function ReplayListener.onTryAttempt(arg_41_0, arg_41_1, arg_41_2, arg_41_3, arg_41_4, arg_41_5, arg_41_6, arg_41_7, arg_41_8, arg_41_9)
	if arg_41_1.tryAttemptOutcome == native.ETryAttemptOutcome.HeldUp then
		arg_41_0:addMoment(replaymoments_config.Moments.UnsuccessfulTryAttempt.name, arg_41_1.attemptById, arg_41_1.time, arg_41_1.time, arg_41_1.position, arg_41_6, arg_41_8, arg_41_4)
	end
end

function ReplayListener.onTryScored(arg_42_0, arg_42_1, arg_42_2, arg_42_3, arg_42_4, arg_42_5, arg_42_6, arg_42_7, arg_42_8, arg_42_9)
	-- bunker-overturned-try: record it like a stock bunker try, so the first replay has
	-- try moments and the bunker replay has its video referee moment.
	if arg_42_1.provisionalTry then
		arg_42_0:addMoment(replaymoments_config.Moments.TryScored.name, arg_42_1.scorer, arg_42_1.time, arg_42_1.time, arg_42_1.scoringPosition, arg_42_6, arg_42_8, arg_42_4)
		arg_42_0:addMoment(replaymoments_config.Moments.TryScoredHighlight.name, arg_42_1.scorer, arg_42_1.time, arg_42_1.time, arg_42_1.scoringPosition, arg_42_6, arg_42_8, arg_42_4)
		arg_42_0:addMoment(replaymoments_config.Moments.VideoReferee.name, arg_42_1.scorer, arg_42_1.time, arg_42_1.time, arg_42_1.scoringPosition, arg_42_6, arg_42_8, arg_42_4)

		return
	end

	if arg_42_1.unsuccessfulAttempt and not arg_42_1.videoRefereeRequired then
		arg_42_0:addMoment(replaymoments_config.Moments.UnsuccessfulTryAttempt.name, arg_42_1.scorer, arg_42_1.time, arg_42_1.time, arg_42_1.scoringPosition, arg_42_6, arg_42_8, arg_42_4)
	else
		arg_42_0:addMoment(replaymoments_config.Moments.TryScored.name, arg_42_1.scorer, arg_42_1.time, arg_42_1.time, arg_42_1.scoringPosition, arg_42_6, arg_42_8, arg_42_4)
		arg_42_0:addMoment(replaymoments_config.Moments.TryScoredHighlight.name, arg_42_1.scorer, arg_42_1.time, arg_42_1.time, arg_42_1.scoringPosition, arg_42_6, arg_42_8, arg_42_4)
	end

	if arg_42_1.videoRefereeRequired then
		arg_42_0:addMoment(replaymoments_config.Moments.VideoReferee.name, arg_42_1.scorer, arg_42_1.time, arg_42_1.time, arg_42_1.scoringPosition, arg_42_6, arg_42_8, arg_42_4)
	end
end
