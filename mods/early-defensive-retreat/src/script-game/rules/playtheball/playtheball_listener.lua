import("core.foundation.func")
import("rules.playtheball.playtheballstate_request")
import("rules.playtheball.playtheballentity_request")
import("design.playtheball_config")

local var_0_0 = playtheball_config.cPlayTheBallConfig
local var_0_1 = var_0_0.playTheBallNotProgressingTime
local var_0_2 = var_0_0.playTheBallCompleteTime

Class("PlayTheBallListener", function(arg_1_0, arg_1_1, arg_1_2, arg_1_3)
	return
end)

function PlayTheBallListener.registerWithMatchSim(arg_2_0, arg_2_1)
	arg_2_1:registerUpdateable(function(...)
		arg_2_0:update(...)
	end)
	arg_2_1:registerSolidEventListener(func.bindmethod(arg_2_0, arg_2_0.onTackleGetupEvent), "TackleGetupEvent")
	arg_2_1:registerSolidEventListener(func.bindmethod(arg_2_0, arg_2_0.onDisposalEvent), "DisposalEvent")
	arg_2_1:registerSolidEventListener(func.bindmethod(arg_2_0, arg_2_0.onCollectEvent), "CollectBallEvent")
	arg_2_1:registerSolidEventListener(func.bindmethod(arg_2_0, arg_2_0.onTimePeriodBreakEvent), "TimePeriodBreakEvent")
	arg_2_1:registerSolidEventListener(func.bindmethod(arg_2_0, arg_2_0.onScootEvent), "DummyHalfScootEvent")
	arg_2_1:registerSolidEventListener(func.bindmethod(arg_2_0, arg_2_0.onPenaltyOptionSelectedEvent), "PenaltyOptionSelectedEvent")
	arg_2_1:registerSolidEventListener(func.bindmethod(arg_2_0, arg_2_0.onOffloadEvent), "OffloadEvent")
	arg_2_1:registerSolidEventListener(func.bindmethod(arg_2_0, arg_2_0.onOffloadEvent), "FendEvent")
	-- early-defensive-retreat
	arg_2_1:registerSolidEventListener(func.bindmethod(arg_2_0, arg_2_0.onTackleCommittedEvent), "TackleCommittedEvent")
	arg_2_1:registerSolidEventListener(func.bindmethod(arg_2_0, arg_2_0.onTackleBrokenEvent), "TackleBrokenEvent")
	arg_2_1:registerSolidEventListener(func.bindmethod(arg_2_0, arg_2_0.onTackleBrokenEvent), "TackleBreakEvent")
end

-- early-defensive-retreat debug: log committed/broken events to
-- early_retreat_debug.txt (game folder). Turn off for release.
local RetreatDebugLog = true

local function retreatLog(arg_0_0, arg_0_1)
	if not RetreatDebugLog then
		return
	end

	pcall(function()
		local var_0_2 = io.open("early_retreat_debug.txt", "a")

		if var_0_2 then
			var_0_2:write(os.date("%H:%M:%S"), " ", arg_0_0, " t=", tostring(arg_0_1.time), " maker=", tostring(arg_0_1.maker), "\n")
			var_0_2:flush()
			var_0_2:close()
		end
	end)
end

-- faster-play-the-ball debug (lives here because build.py allows one owner per
-- file): play-the-ball phase timings to ptb_timing_debug.txt (game folder),
-- one line per event: committed -> getup -> played -> collect. Turn off for
-- release.
local PtbTimingDebugLog = true

local function ptbLog(arg_0_0, arg_0_1, arg_0_2)
	if not PtbTimingDebugLog then
		return
	end

	pcall(function()
		local var_0_3 = arg_0_2:getMatchProgressionEntity()
		local var_0_4 = arg_0_2:getPlayTheBallEntity()
		local var_0_5 = var_0_3.attackingSide
		local var_0_6 = "?"

		pcall(function()
			var_0_6 = tostring(arg_0_2:getGamerSideEntity():isAnyGamerOnSide(var_0_5))
		end)

		local var_0_7 = io.open("ptb_timing_debug.txt", "a")

		if var_0_7 then
			var_0_7:write(os.date("%H:%M:%S"), string.format(" %s t=%s att=%s human=%s tackle=%s quick=%s slow=%s state=%s maker=%s", arg_0_0, tostring(arg_0_1.time), tostring(var_0_5), var_0_6, tostring(var_0_3.tackleCount), tostring(var_0_4.isQuickPlayTheBall), tostring(var_0_4.isSlowPlayTheBall), tostring(var_0_4.playTheBallState), tostring(arg_0_1.maker)), "\n")
			var_0_7:flush()
			var_0_7:close()
		end
	end)
end

-- early-defensive-retreat: TackleCommittedEvent fires on the tackle
-- animation's "committed" frame, while the ball carrier still has the ball:
-- the tackle can no longer fail. Raise the same "defence held tackle" flag the
-- hold-down sets (TackleHoldMonitorAi/Human), so master_flowchart_ai.flow's
-- isDefenseHeldTackle rule sends every free defender back 10 m now instead of
-- at the hold-down.
function PlayTheBallListener.onTackleCommittedEvent(arg_20_0, arg_20_1, arg_20_2, arg_20_3, arg_20_4, arg_20_5, arg_20_6, arg_20_7, arg_20_8, arg_20_9)
	retreatLog("COMMITTED", arg_20_1)
	ptbLog("COMMITTED", arg_20_1, arg_20_7)
	arg_20_9:add(playtheballentity_request.DefenseHeldTacklePlayTheBallRequest({
		defenseHeldTackle = true
	}))
end

-- The tackle was broken after all: stop the retreat (early held flag and the
-- human double-tap flag).
function PlayTheBallListener.onTackleBrokenEvent(arg_21_0, arg_21_1, arg_21_2, arg_21_3, arg_21_4, arg_21_5, arg_21_6, arg_21_7, arg_21_8, arg_21_9)
	retreatLog("BROKEN", arg_21_1)
	arg_21_9:add(playtheballentity_request.QuickDefensivePlayTheBallRequest({
		isDefensiveQuickPlayTheBall = false
	}))
	arg_21_9:add(playtheballentity_request.DefenseHeldTacklePlayTheBallRequest({
		defenseHeldTackle = false
	}))
end

function PlayTheBallListener.update(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7, arg_4_8, arg_4_9, arg_4_10)
	local var_4_0 = arg_4_6:getPlayTheBallEntity()
	local var_4_1 = var_4_0.playTheBallState

	if var_4_1 == native.EPlayTheBallState.Complete then
		arg_4_10:add(playtheballentity_request.ClearPlayTheBallEntityRequest({}))

		return
	end

	if var_4_1 == native.EPlayTheBallState.BallPlayed or var_4_1 == native.EPlayTheBallState.BallCollected then
		if arg_4_9 - var_4_0.stateChangeTime > var_0_1 then
			local var_4_2 = {
				playTheBallState = native.EPlayTheBallState.PlayNotProgressing,
				stateChangeTime = arg_4_9
			}

			arg_4_10:add(playtheballstate_request.PlayTheBallStateRequest(var_4_2))
		end

		return
	end

	if var_4_1 == native.EPlayTheBallState.PlayNotProgressing or var_4_1 == native.EPlayTheBallState.DirectionKnown then
		if arg_4_9 - var_4_0.stateChangeTime > var_0_2 then
			local var_4_3 = {
				playTheBallState = native.EPlayTheBallState.Complete,
				stateChangeTime = arg_4_9
			}

			arg_4_10:add(playtheballstate_request.PlayTheBallStateRequest(var_4_3))
		end

		return
	end
end

function PlayTheBallListener.onTackleGetupEvent(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7, arg_5_8, arg_5_9)
	ptbLog("GETUP", arg_5_1, arg_5_7)
end

function PlayTheBallListener.onDisposalEvent(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8, arg_6_9)
	ASSERT(arg_6_1.time)

	local var_6_0 = arg_6_7:getPlayTheBallEntity().playTheBallState

	arg_6_9:add(playtheballentity_request.QuickDefensivePlayTheBallRequest({
		isDefensiveQuickPlayTheBall = false
	}))
	arg_6_9:add(playtheballentity_request.DefenseHeldTacklePlayTheBallRequest({
		defenseHeldTackle = false
	}))
	ASSERT(arg_6_1.disposalType)

	if not arg_6_1.disposalSubType then
		return
	end

	local var_6_1 = arg_6_1.disposalType
	local var_6_2 = arg_6_1.disposalSubType

	if var_6_1 == native.EDisposalType.Kick and var_6_2 == native.EDisposalSubType.PlayTheBall then
		ptbLog("PLAYED", arg_6_1, arg_6_7)

		local var_6_3 = {
			playTheBallState = native.EPlayTheBallState.BallPlayed,
			stateChangeTime = arg_6_1.time
		}

		arg_6_9:add(playtheballstate_request.PlayTheBallStateRequest(var_6_3))
	else
		local var_6_4 = {
			playTheBallState = native.EPlayTheBallState.None,
			stateChangeTime = arg_6_1.time
		}

		arg_6_9:add(playtheballstate_request.PlayTheBallStateRequest(var_6_4))
	end
end

function PlayTheBallListener.onCollectEvent(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7, arg_7_8, arg_7_9)
	ASSERT(arg_7_1.time)

	if arg_7_7:getPlayTheBallEntity().playTheBallState == native.EPlayTheBallState.BallPlayed then
		ptbLog("COLLECT", arg_7_1, arg_7_7)

		local var_7_0 = {
			playTheBallState = native.EPlayTheBallState.BallCollected,
			stateChangeTime = arg_7_1.time
		}

		arg_7_9:add(playtheballstate_request.PlayTheBallStateRequest(var_7_0))
	end

	arg_7_9:add(playtheballentity_request.QuickDefensivePlayTheBallRequest({
		isDefensiveQuickPlayTheBall = false
	}))
	arg_7_9:add(playtheballentity_request.DefenseHeldTacklePlayTheBallRequest({
		defenseHeldTackle = false
	}))
end

function PlayTheBallListener.onScootEvent(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5, arg_8_6, arg_8_7, arg_8_8, arg_8_9)
	ASSERT(arg_8_1.time)

	local var_8_0 = arg_8_7:getPlayTheBallEntity().playTheBallState

	if var_8_0 == native.EPlayTheBallState.PlayingTheBall or var_8_0 == native.EPlayTheBallState.BallPlayed or var_8_0 == native.EPlayTheBallState.BallCollected then
		local var_8_1 = {
			playTheBallState = native.EPlayTheBallState.DirectionKnown,
			stateChangeTime = arg_8_1.time,
			scootDirection = arg_8_1.position
		}

		arg_8_9:add(playtheballstate_request.PlayTheBallStateRequest(var_8_1))
	end
end

function PlayTheBallListener.onTimePeriodBreakEvent(arg_9_0, arg_9_1, arg_9_2, arg_9_3, arg_9_4, arg_9_5, arg_9_6, arg_9_7, arg_9_8, arg_9_9)
	ASSERT(arg_9_1.time)

	local var_9_0 = {
		playTheBallState = native.EPlayTheBallState.None,
		stateChangeTime = arg_9_1.time
	}

	arg_9_9:add(playtheballstate_request.PlayTheBallStateRequest(var_9_0))
	arg_9_9:add(playtheballentity_request.QuickDefensivePlayTheBallRequest({
		isDefensiveQuickPlayTheBall = false
	}))
	arg_9_9:add(playtheballentity_request.DefenseHeldTacklePlayTheBallRequest({
		defenseHeldTackle = false
	}))
end

function PlayTheBallListener.onPenaltyOptionSelectedEvent(arg_10_0, arg_10_1, arg_10_2, arg_10_3, arg_10_4, arg_10_5, arg_10_6, arg_10_7, arg_10_8, arg_10_9)
	ASSERT(arg_10_1.time)

	local var_10_0 = {
		playTheBallState = native.EPlayTheBallState.None,
		stateChangeTime = arg_10_1.time
	}

	arg_10_9:add(playtheballstate_request.PlayTheBallStateRequest(var_10_0))
	arg_10_9:add(playtheballentity_request.QuickDefensivePlayTheBallRequest({
		isDefensiveQuickPlayTheBall = false
	}))
	arg_10_9:add(playtheballentity_request.DefenseHeldTacklePlayTheBallRequest({
		defenseHeldTackle = false
	}))
end

function PlayTheBallListener.onOffloadEvent(arg_11_0, arg_11_1, arg_11_2, arg_11_3, arg_11_4, arg_11_5, arg_11_6, arg_11_7, arg_11_8, arg_11_9)
	arg_11_9:add(playtheballentity_request.ClearPlayTheBallEntityRequest({}))
end
