import("core.foundation.class")
import("core.foundation.func")
import("core.foundation.tablex")
import("base.side.sidehelper")
import("game.player.playertype")
import("rules.penalty.penaltyawarded_request")
import("script-config.rules.rugby.penaltygoal_config")
import("script-config.rules.rules.rulesenvironment")
import("ai.common.control_helper")

-- referee-on-report: a high tackle penalty no longer lets the referee signal from wherever he
-- is while the penalty choice is made straight away (the CPU picks instantly, so the signal was
-- never seen). generatePenaltyAwardedState puts the referee close-up in front of the choice:
--   PenaltyIdle -> RefereeCameo(HighTackle [+ Report]) -> PenaltySelectSetup
-- OnReportChance percent of high tackles also put the offender on report: the Report signal in
-- the same close-up (ai/officials/refereesignal_action.lua), then "<NAME> ON REPORT" under the
-- scoreboard (sim/hud/gameplayscore_hud.lua). Shared through
-- _G.OnReportState:
--   pending = { playerId, side, surname, matchSeconds }  the report the scoreboard hasn't shown
--   reports = { ... }  every report this match (cleared by the scoreboard for a new match)
local OnReportChance = 30
-- Appends to onreport_debug.txt in the game folder.
local OnReportDebug = true

local function onReportState()
	local var_state = rawget(_G, "OnReportState")

	if not var_state then
		var_state = {
			reports = {}
		}

		rawset(_G, "OnReportState", var_state)
	end

	return var_state
end

local onReportLogFile
local onReportLogTried = false

local function onReportLog(arg_text)
	if not OnReportDebug then
		return
	end

	pcall(function()
		if not onReportLogTried then
			onReportLogTried = true

			if io and io.open then
				onReportLogFile = io.open("onreport_debug.txt", "a")
			end
		end

		if onReportLogFile then
			onReportLogFile:write(tostring(arg_text) .. "\n")
			onReportLogFile:flush()
		end
	end)
end

onReportState().log = onReportLog

-- Returns the report (and records it as pending) or nil.
local function rollOnReport(arg_offenderId, arg_match, arg_gamestate, arg_gameobjects, arg_time)
	local var_reason

	if native.Random.FromSystemTime():next(0, 100) >= OnReportChance then
		var_reason = "chance roll"
	end

	if var_reason then
		onReportLog(string.format("high tackle by %s: not on report (%s)", tostring(arg_offenderId), var_reason))

		return nil
	end

	local var_player = arg_gameobjects:getGameObject(arg_offenderId, playertype.TypeId)
	local var_identity = var_player and var_player.identity
	local var_report = {
		playerId = arg_offenderId,
		side = var_player and var_player:getSide(),
		surname = var_identity and var_identity.surname or "",
		matchSeconds = arg_match:getComponent("matchInfo"):getMatchSecondsElapsed(arg_gamestate, arg_time)
	}
	local var_state = onReportState()

	var_state.pending = var_report

	table.insert(var_state.reports, var_report)
	onReportLog(string.format("high tackle by %s (%s, side %s): ON REPORT at %ds", tostring(arg_offenderId), var_report.surname, tostring(var_report.side), math.floor(var_report.matchSeconds or 0)))

	return var_report
end

-- Online matches, practice and training keep the stock penalty flow.
local function onReportFlowAllowed(arg_match, arg_gamestate)
	local var_matchInData = arg_match:getComponent("matchInData")

	if var_matchInData.onlineMultiplayer then
		return false, "online"
	elseif var_matchInData.gameMode == native.EGameMode.Practice then
		return false, "practice"
	elseif arg_gamestate:getTrainingEntity().trainingActive then
		return false, "training"
	end

	return true
end

local function refereeCameoState(arg_signal, arg_offendingSide, arg_restartSide, arg_nextState)
	return class.instantiate("RefereeCameoRuleState", {
		delayBeforeSignal = 0,
		isVideoReferee = false,
		skipReplayEvent = true,
		refereeSignal = arg_signal,
		offendingSide = arg_offendingSide,
		restartSide = arg_restartSide,
		nextState = arg_nextState
	})
end

local function var_0_0(arg_1_0)
	local var_1_0 = arg_1_0.gamers
	local var_1_1 = arg_1_0.match
	local var_1_2 = arg_1_0.gameobjects
	local var_1_3 = arg_1_0.sideAwardedPenalty
	local var_1_4 = arg_1_0.penaltyPosition
	local var_1_5 = var_1_1:getSide(var_1_3):getAvailablePlayers(var_1_2)
	local var_1_6 = func.map(function(arg_2_0, arg_2_1)
		local var_2_0 = var_1_2:getGameObject(arg_2_0, playertype.TypeId).pos
		local var_2_1 = native.distance2(var_1_4, var_2_0)
		local var_2_2 = {
			id = arg_2_0,
			distance = var_2_1
		}

		return arg_2_0, var_2_2
	end, pairs(var_1_5))
	local var_1_7, var_1_8 = func.selectpair(function(arg_3_0, arg_3_1)
		return arg_3_0.distance < arg_3_1.distance
	end, pairs(var_1_6))
	local var_1_9 = var_1_8.id

	if not var_1_9 then
		print("[PenaltySelect] - AI Taker selection failed")
		print("sideAwardedPenalty: {1}" % {
			var_1_3
		})
		print("playersDistanceToPenalty Size: {1}" % {
			tablex.count(var_1_6)
		})

		for iter_1_0, iter_1_1 in pairs(var_1_6) do
			print("id: {id}   distance: {dist%.2f}" % {
				iter_1_1.id,
				iter_1_1.distance
			})
		end
	end

	return var_1_9
end

local function var_0_1(arg_4_0)
	local var_4_0 = arg_4_0.gamers
	local var_4_1 = arg_4_0.gameobjects
	local var_4_2 = arg_4_0.sideAwardedPenalty
	local var_4_3 = arg_4_0.penaltyPosition
	local var_4_4 = true
	local var_4_5, var_4_6 = var_4_0:getLocalGamersSplitBySide(var_4_4)
	local var_4_7, var_4_8 = var_4_0:getRemoteGamersSplitBySide(var_4_4)
	local var_4_9 = var_4_2 == sidehelper.home
	local var_4_10 = {
		localGamers = var_4_9 and var_4_5 or var_4_6,
		remoteGamers = var_4_9 and var_4_7 or var_4_8
	}

	local function var_4_11(arg_5_0, arg_5_1, arg_5_2)
		local var_5_0 = func.map(function(arg_6_0, arg_6_1)
			local var_6_0 = arg_6_1.objectId

			if var_6_0 then
				local var_6_1 = arg_6_1:getGamerId()
				local var_6_2 = var_4_1:getGameObject(var_6_0, playertype.TypeId).pos
				local var_6_3 = native.distance2(arg_5_2, var_6_2)
				local var_6_4 = {
					id = var_6_0,
					gamerId = var_6_1,
					distance = var_6_3
				}

				return arg_6_0, var_6_4
			end
		end, pairs(arg_5_1))
		local var_5_1, var_5_2 = func.selectpair(function(arg_7_0, arg_7_1)
			return arg_7_0.distance < arg_7_1.distance
		end, pairs(var_5_0))

		return var_5_2
	end

	local var_4_12 = var_4_11(var_4_1, var_4_10.localGamers, var_4_3)
	local var_4_13 = var_4_11(var_4_1, var_4_10.remoteGamers, var_4_3)
	local var_4_14 = (var_4_12 and var_4_12.distance or 999999) < (var_4_13 and var_4_13.distance or 999999) and var_4_12 or var_4_13

	if not var_4_14 then
		print("[PenaltySelect] - Human Taker selection failed")
		print("sideAwardedPenalty: {1}" % {
			var_4_2
		})
		print("closestLocalGamer: {1}" % {
			var_4_12 and var_4_12.gamerId or "NONE"
		})
		print("closestRemoteGamer: {1}" % {
			var_4_13 and var_4_13.gamerId or "NONE"
		})
		print("localGamers:")

		for iter_4_0, iter_4_1 in pairs(var_4_10.localGamers) do
			print("k: {k}   objectId: {id}" % {
				iter_4_0,
				iter_4_1.objectId and iter_4_1.objectId or "nil"
			})
		end

		print("remoteGamers:")

		for iter_4_2, iter_4_3 in pairs(var_4_10.remoteGamers) do
			print("k: {k}   objectId: {id}" % {
				iter_4_2,
				iter_4_3.objectId and iter_4_3.objectId or "nil"
			})
		end
	end

	return var_4_14 and var_4_14.id
end

function getPenaltyTakerId(arg_8_0)
	local var_8_0 = arg_8_0.match:getComponent("matchInData")
	local var_8_1 = arg_8_0.gamers
	local var_8_2 = arg_8_0.sideAwardedPenalty
	local var_8_3 = arg_8_0.gamestate
	local var_8_4 = var_8_1:isAnyOnSideLocal(var_8_2)
	local var_8_5 = arg_8_0.services
	local var_8_6 = (control_helper.getHumanPlayerIsOnFieldCaptain(var_8_5, var_8_2, var_8_0, var_8_1, var_8_3) and var_0_1 or var_0_0)(arg_8_0) or var_0_0(arg_8_0)

	print("objectId: {id} selected to take penalty" % {
		var_8_6 or "nil"
	})

	return var_8_6
end

function generatePenaltyAwardedState(arg_9_0, arg_9_1, arg_9_2, arg_9_3, arg_9_4, arg_9_5, arg_9_6, arg_9_7, arg_9_8)
	print("[9464] generatePenaltyAwardedState() called.")
	ASSERT(arg_9_8.offendingSide)
	ASSERT(arg_9_8.penaltyPosition)
	ASSERT(arg_9_8.offenderId)
	ASSERT(arg_9_8.penaltyAwardedToSide)
	ASSERT(arg_9_8.infringementTypes)
	ASSERT(arg_9_8.penaltyType)
	ASSERT(arg_9_8.refereeSignal)

	local var_9_0 = arg_9_8.penaltyAwardedToSide
	local var_9_1 = arg_9_8.offendingSide
	local var_9_2 = arg_9_8.penaltyPosition
	local var_9_3 = arg_9_8.penaltyType
	local var_9_4 = arg_9_8.offenderId
	local var_9_5 = arg_9_8.refereeSignal
	local var_9_6 = arg_9_8.isDebug

	ASSERT(var_9_0)
	ASSERT(var_9_1)
	ASSERT(var_9_2)
	ASSERT(var_9_3)
	ASSERT(var_9_4)
	ASSERT(var_9_5)

	local var_9_7 = native.Random.FromSystemTime():nextAsSeed()
	local var_9_8 = arg_9_6 + 1
	local var_9_9 = getPenaltyTakerId({
		gamers = arg_9_0,
		services = arg_9_1,
		match = arg_9_3,
		gameobjects = arg_9_5,
		sideAwardedPenalty = var_9_0,
		penaltyPosition = var_9_2,
		gamestate = arg_9_4
	})
	local var_9_10 = arg_9_3:getComponent("matchInfo"):getMatchSecondsElapsed(arg_9_4, arg_9_6)
	local var_9_11 = {
		activateStoppageTime = true,
		enablePlayerSwitching = true,
		blockGamerSwitching = true,
		uniquePlayGuid = arg_9_2:alloc(),
		sideAwardedPenalty = var_9_0,
		sideConcededPenalty = var_9_1,
		penaltyPosition = var_9_2,
		infringmentType = var_9_3,
		infringementById = var_9_4,
		penaltyTakerId = var_9_9,
		randomSeed = var_9_7,
		expireTime = var_9_8,
		refereeSignalType = var_9_5,
		guid = arg_9_2:alloc(),
		idleTime = arg_9_6,
		penaltyTime = var_9_10
	}

	-- referee-on-report: high tackles get the referee close-ups (and maybe a report) before
	-- the penalty choice. The award itself sets no signal, so he doesn't also signal from afar.
	local var_9_12 = nil

	-- Read by r25-imports' penalty talk (rules/penalty/penaltyselect_setup_rulestate.lua): no
	-- talk for an offender who goes on report, he gets the report close-up instead.
	onReportState().reportedOffender = nil

	if not var_9_6 and var_9_3 == arg_9_8.infringementTypes.HighTackle then
		local var_9_13, var_9_14 = onReportFlowAllowed(arg_9_3, arg_9_4)

		if var_9_13 then
			var_9_12 = rollOnReport(var_9_4, arg_9_3, arg_9_4, arg_9_5, arg_9_6) or false

			if var_9_12 then
				onReportState().reportedOffender = var_9_4
			end

			var_9_11.refereeSignalType = native.EUmpireSignalTypes.None
		else
			onReportLog("high tackle: stock penalty flow (" .. tostring(var_9_14) .. ")")
		end
	end

	if var_9_6 then
		arg_9_7:add(penaltyawarded_request.DebugPenaltyAwardedRequest(var_9_11))
	else
		arg_9_7:add(penaltyawarded_request.PenaltyAwardedRequest(var_9_11))
	end

	var_9_11.nextState = class.instantiate("PenaltySelectSetupRuleState", var_9_11)

	-- One close-up for both signals: with a report pending, refereesignal_action.lua keeps it
	-- open after the high tackle signal and plays the Report signal inside it (no camera cut).
	if var_9_12 ~= nil then
		var_9_11.nextState = refereeCameoState(var_9_5, var_9_1, var_9_0, var_9_11.nextState)

		onReportLog(string.format("penalty flow: high tackle close-up%s, then penalty choice", var_9_12 and " + report signal" or ""))
	end

	return (class.instantiate("PenaltyIdleAllPlayersRuleState", var_9_11))
end

function adjustPenaltyGoalKickPosition(arg_10_0)
	local var_10_0 = rulesenvironment.halfFieldLength
	local var_10_1 = rulesenvironment.halfFieldWidth
	local var_10_2 = penaltygoal_config.minKickDistance
	local var_10_3 = penaltygoal_config.maxKickDistance
	local var_10_4 = math.abs(arg_10_0.y)
	local var_10_5 = math.min(var_10_4, var_10_1) / var_10_1
	local var_10_6 = arg_10_0.x < 0 and -1 or 1
	local var_10_7 = func.linearInterpolate(var_10_5, var_10_2, var_10_3)
	local var_10_8 = 50 - math.abs(arg_10_0.x)
	local var_10_9 = (var_10_0 - (var_10_8 < var_10_7 and var_10_7 or var_10_8)) * var_10_6
	local var_10_10 = arg_10_0.y

	return (native.vec2(var_10_9, var_10_10))
end

function logOffside(arg_11_0, arg_11_1, arg_11_2, arg_11_3, arg_11_4)
	local var_11_0 = arg_11_0.hooks
	local var_11_1 = var_11_0 and var_11_0:getHook("OffsideDebugHook")

	if var_11_1 then
		var_11_1:onOffsideDecision(arg_11_1, arg_11_2, arg_11_3, arg_11_4)
	end
end
