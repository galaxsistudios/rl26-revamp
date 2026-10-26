import("base.barrier.barrier_ustate")
import("base.universe.universestate")
import("base.transition.logotransition_hud")

local var_0_0 = barrier_ustate.BarrierUniverseState

-- replay-team-stinger: the barrier into a try replay waits for the team stinger
-- (logotransition_hud.lua) to cover the screen, and the wipe-in releases it once the
-- replay is playing. The timeouts mean a stinger that stops updating can only cost
-- the effect, never hang the barrier.
local TeamStingerBarrierTimeout = 1.2
local TeamStingerWipeInTimeout = 7

-- bunker-overturned-try outro: "logo" = the stock Rugby League 26 logo wipe (LogoTransitionHud,
-- as used after conversions), "team" = the team stinger again.
local TeamStingerOutroStyle = "logo"
-- Logo outro: longest the barrier waits for the logo to cover, and how long after the
-- barrier it holds before sliding off (the referee cameo camera takes over meanwhile).
local LogoOutroBarrierTimeout = 3
local LogoOutroRevealDelay = 0.35

local function teamStingerCall(arg_c_0, arg_c_1, ...)
	local var_c_0, var_c_1 = pcall(arg_c_0[arg_c_1], arg_c_0, ...)

	if not var_c_0 then
		logotransition_hud.teamStingerLog(arg_c_1 .. " error: " .. tostring(var_c_1))
	end

	return var_c_0, var_c_1
end

Class("ScreenWipeOut", var_0_0, function(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5)
	arg_1_0.name = arg_1_5.name

	print("Created ScreenWipeOut")

	local var_1_0 = arg_1_5.transition or arg_1_5.name
	local var_1_1 = arg_1_1:getInstance("ScreenWipeVisual", var_1_0)

	arg_1_0.screenWipe = var_1_1
	arg_1_0.timeInBarrier = 0

	var_0_0.init(arg_1_0, arg_1_2, arg_1_3, arg_1_4, {
		waitFor = assert(var_1_1.barrierLength)
	})

	-- replay-team-stinger: the state this barrier leads to is the top of nextStack;
	-- only a replay tagged with a scoring team gets the stinger. A replay that has already
	-- started (its camera is set) is still on top at its own end barrier, so skip those.
	local var_1_2 = arg_1_0.logoTransition and arg_1_0.logoTransition.teamStinger
	local var_1_3 = arg_1_1.nextStack
	local var_1_4 = var_1_3 and var_1_3[#var_1_3]

	if var_1_2 and var_1_4 and var_1_4.teamStingerTeam and not var_1_4.camera then
		arg_1_0.teamStinger = var_1_2
		arg_1_0.teamStingerReplay = var_1_4
	end

	-- bunker-overturned-try: debug, every barrier while a provisional try is on.
	local var_1_6 = rawget(_G, "ProvisionalTryState")

	if var_1_6 and var_1_6.side then
		pcall(function()
			local var_1_7 = arg_1_1.currentStack or {}

			logotransition_hud.teamStingerLog(string.format("barrier (%s): next top %s, current top %s, outro armed %s, logo enabled %s", tostring(arg_1_5.transition or arg_1_5.name), tostring(var_1_4 and type(var_1_4)), tostring(var_1_7[#var_1_7] and type(var_1_7[#var_1_7])), tostring(var_1_2 and var_1_2.pendingOutroTeam ~= nil), tostring(arg_1_0.logoTransition and arg_1_0.logoTransition.enabled)))
		end)
	end

	-- bunker-overturned-try: once the provisional try replay is playing, the outro is armed
	-- (logotransition_hud.lua) and the next barrier is that replay's end.
	if var_1_2 and not arg_1_0.teamStingerReplay and var_1_2.pendingOutroTeam then
		local var_1_5 = var_1_2.pendingOutroTeam

		var_1_2.pendingOutroTeam = nil

		if TeamStingerOutroStyle == "logo" and arg_1_0.logoTransition then
			arg_1_0.logoOutro = arg_1_0.logoTransition

			logotransition_hud.teamStingerLog("outro: end-of-replay barrier, logo wipe")
		else
			arg_1_0.teamStinger = var_1_2
			arg_1_0.teamStingerOutroTeam = var_1_5

			logotransition_hud.teamStingerLog("outro: end-of-replay barrier, team stinger")
		end
	end
end)

function ScreenWipeOut.onFirstFocus(arg_2_0, arg_2_1, arg_2_2)
	arg_2_0.screenWipe:enter()

	-- replay-team-stinger: normally the stinger slid in during the celebration. If the
	-- celebration was skipped it starts here, over a frozen last frame.
	local var_2_0 = arg_2_0.teamStinger

	if arg_2_0.logoOutro then
		local var_2_8, var_2_9 = pcall(arg_2_0.logoOutro.kick, arg_2_0.logoOutro)

		if var_2_8 then
			logotransition_hud.teamStingerLog("outro: logo wipe kicked over the end of the provisional try replay")
			arg_2_0.screenWipe:capture()
		else
			logotransition_hud.teamStingerLog("outro: logo wipe kick error: " .. tostring(var_2_9))

			arg_2_0.logoOutro = nil
		end
	elseif var_2_0 and arg_2_0.teamStingerOutroTeam then
		local var_2_6, var_2_7 = teamStingerCall(var_2_0, "kickOutro", arg_2_0.teamStingerOutroTeam)

		if var_2_6 and var_2_7 then
			logotransition_hud.teamStingerLog("outro: kicked over the end of the provisional try replay")
			arg_2_0.screenWipe:capture()
		else
			logotransition_hud.teamStingerLog("outro: stinger busy, no outro")

			arg_2_0.teamStinger = nil
		end
	elseif var_2_0 then
		local var_2_1 = arg_2_0.teamStingerReplay
		local var_2_2, var_2_3 = teamStingerCall(var_2_0, "isActiveFor", var_2_1)
		local var_2_4, var_2_5 = false, false

		if not (var_2_2 and var_2_3) and not var_2_1.teamStingerKicked then
			var_2_4, var_2_5 = teamStingerCall(var_2_0, "kick", var_2_1)
		end

		if var_2_2 and var_2_3 then
			logotransition_hud.teamStingerLog("barrier: stinger already in")
		elseif var_2_4 and var_2_5 then
			logotransition_hud.teamStingerLog("barrier: kicked stinger (celebration skipped or too short)")
			arg_2_0.screenWipe:capture()
		else
			arg_2_0.teamStinger = nil
		end
	end
end

function ScreenWipeOut.update(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9)
	arg_3_0.timeInBarrier = arg_3_0.timeInBarrier + arg_3_5

	if arg_3_0.timeInBarrier > 1.5 and not arg_3_0.showingConnectivityWidget then
		ASSERT(arg_3_0.showingConnectivityWidget == nil)

		arg_3_0.showingConnectivityWidget = true

		local var_3_0 = arg_3_1:getWidgetController()

		if var_3_0 then
			var_3_0:showConnectivityWidget()
		end
	end

	arg_3_0.screenWipe:update(arg_3_5)
	arg_3_1:getUniverseStateStack():updateBelow(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9)
	var_0_0.update(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9)
end

-- replay-team-stinger
function ScreenWipeOut.acceptBarrierComplete(arg_15_0, arg_15_1, arg_15_2)
	-- bunker-overturned-try: hold until the logo covers the screen.
	if arg_15_0.logoOutro and arg_15_0.timeInBarrier <= LogoOutroBarrierTimeout then
		local var_15_5, var_15_6 = pcall(arg_15_0.logoOutro.readyToTransition, arg_15_0.logoOutro)

		if var_15_5 and not var_15_6 then
			return false
		end
	end

	local var_15_0 = arg_15_0.teamStinger

	if not var_15_0 or arg_15_0.timeInBarrier > TeamStingerBarrierTimeout then
		return true
	end

	local var_15_1, var_15_2 = teamStingerCall(var_15_0, "isCovered")
	local var_15_3, var_15_4 = teamStingerCall(var_15_0, "isBusy")

	return not var_15_1 or var_15_2 or not var_15_3 or not var_15_4
end

function ScreenWipeOut.onBarrierComplete(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5)
	if arg_4_0.showingConnectivityWidget then
		local var_4_0 = arg_4_1:getWidgetController()

		if var_4_0 then
			var_4_0:hideConnectivityWidget()
		end

		arg_4_0.showingConnectivityWidget = false
	end

	local var_4_1 = arg_4_1:getUniverseStateStack()
	local var_4_2 = ScreenWipeIn(var_4_1, arg_4_2, {
		name = arg_4_0.name,
		screenWipe = arg_4_0.screenWipe,
		teamStinger = arg_4_0.teamStinger,
		logoOutro = arg_4_0.logoOutro
	})

	var_4_1:pushStateAtBarrierEnd(var_4_2)
end

function ScreenWipeOut.render(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7)
	local var_5_0 = arg_5_0.screenWipe

	arg_5_7:renderSceneFull(arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6)
	var_5_0:render(arg_5_5)
end

local var_0_1 = universestate.UniverseState

Class("ScreenWipeIn", var_0_1, function(arg_6_0, arg_6_1, arg_6_2, arg_6_3)
	arg_6_0.name = arg_6_3.name
	arg_6_0.screenWipe = arg_6_3.screenWipe
	arg_6_0.oneBlackFrame = false

	-- replay-team-stinger
	arg_6_0.teamStinger = arg_6_3.teamStinger
	arg_6_0.teamStingerTime = 0

	-- bunker-overturned-try
	arg_6_0.logoOutro = arg_6_3.logoOutro
	arg_6_0.logoOutroTime = 0

	print("Created ScreenWipeIn")
end)

function ScreenWipeIn.onFirstFocus(arg_7_0)
	arg_7_0.screenWipe:exit()
end

function ScreenWipeIn.onPush(arg_8_0, arg_8_1)
	arg_8_0.screenWipe:capture()
	var_0_0.onPush(arg_8_0, arg_8_1)
end

-- bunker-overturned-try: lets the logo wipe slide off.
local function releaseLogoOutro(arg_r_0, arg_r_1)
	local var_r_0 = arg_r_0.logoOutro

	if var_r_0 then
		arg_r_0.logoOutro = nil

		pcall(var_r_0.setNextStateIsReady, var_r_0)

		local var_r_2, var_r_3 = pcall(var_r_0.readyToTransition, var_r_0)

		logotransition_hud.teamStingerLog("outro: logo covering at release: " .. tostring(var_r_3) .. ", enabled " .. tostring(var_r_0.enabled))

		-- bunker-overturned-try: the referee cameo waits for this (refereecameo_rulestate.lua).
		local var_r_1 = rawget(_G, "ProvisionalTryState")

		if var_r_1 then
			var_r_1.outroReleased = true
		end
		logotransition_hud.teamStingerLog("outro: logo wipe released (" .. arg_r_1 .. ")")
	end
end

function ScreenWipeIn.onRemove(arg_9_0, arg_9_1, arg_9_2)
	releaseLogoOutro(arg_9_0, "wipe-in removed")
	-- replay-team-stinger: removed early (e.g. replay skipped): slide the stinger out.
	if arg_9_0.teamStinger then
		teamStingerCall(arg_9_0.teamStinger, "release")

		arg_9_0.teamStinger = nil
	end

	local var_9_0 = arg_9_0.screenWipe

	if var_9_0 then
		arg_9_0.screenWipe = nil

		var_9_0:dispose(arg_9_2)
	end
end

function ScreenWipeIn.isFinished(arg_10_0)
	local var_10_0 = arg_10_0.screenWipe

	if arg_10_0.logoOutro then
		return false
	end

	-- replay-team-stinger: stay until the stinger has slid out.
	if arg_10_0.teamStinger then
		local var_10_1, var_10_2 = teamStingerCall(arg_10_0.teamStinger, "isBusy")

		if var_10_1 and var_10_2 then
			return false
		end
	end

	return arg_10_0.screenWipe:isFinished()
end

function ScreenWipeIn.getPauseActivationInputEnabled(arg_11_0, arg_11_1)
	local var_11_0 = arg_11_1:getUniverseStateStack():getStateBelow(arg_11_0)

	return var_11_0 and var_11_0:getPauseActivationInputEnabled(arg_11_1)
end

function ScreenWipeIn.update(arg_12_0, arg_12_1, arg_12_2, arg_12_3, arg_12_4, arg_12_5, arg_12_6, arg_12_7, arg_12_8, arg_12_9)
	local var_12_0 = arg_12_1:getUniverseStateStack()

	var_12_0:updateBelow(arg_12_0, arg_12_1, arg_12_2, arg_12_3, arg_12_4, arg_12_5, arg_12_6, arg_12_7, arg_12_8, arg_12_9)

	-- replay-team-stinger debug: the time window the replay under us actually plays.
	pcall(function()
		local var_12_10 = var_12_0:getStateBelow(arg_12_0)
		local var_12_11 = var_12_10 and var_12_10.replayPresenter and var_12_10.replayPresenter.playbackContext

		if var_12_11 and not var_12_10.teamStingerLoggedWindow then
			var_12_10.teamStingerLoggedWindow = true

			logotransition_hud.teamStingerLog(string.format("replay playback window %.2f..%.2f", var_12_11.startTime:ToSeconds(), var_12_11.endTime:ToSeconds()))
		end
	end)

	-- bunker-overturned-try: logo outro hold.
	if arg_12_0.logoOutro then
		arg_12_0.logoOutroTime = arg_12_0.logoOutroTime + arg_12_5

		if arg_12_0.logoOutroTime >= LogoOutroRevealDelay then
			releaseLogoOutro(arg_12_0, "reveal")
		end
	end

	-- replay-team-stinger: release the stinger once the replay under us is playing.
	local var_12_1 = arg_12_0.teamStinger

	if var_12_1 then
		arg_12_0.teamStingerTime = arg_12_0.teamStingerTime + arg_12_5

		local var_12_2 = teamStingerCall(var_12_1, "updateReveal", var_12_0:getStateBelow(arg_12_0), arg_12_5)

		if not var_12_2 or arg_12_0.teamStingerTime > TeamStingerWipeInTimeout then
			logotransition_hud.teamStingerLog("wipe-in timed out, hiding stinger")
			teamStingerCall(var_12_1, "reset")

			arg_12_0.teamStinger = nil
		end
	end

	if arg_12_0:isFinished() then
		print("ScreenWipeIn:update() universeStateStack:removeState(self)")
		var_12_0:removeState(arg_12_0, arg_12_1, arg_12_2)

		return
	end

	arg_12_0.screenWipe:update(arg_12_5)
end

function ScreenWipeIn.render(arg_13_0, arg_13_1, arg_13_2, arg_13_3, arg_13_4, arg_13_5, arg_13_6, arg_13_7)
	arg_13_7:getUniverseStateStack():renderBelow(arg_13_0, arg_13_7, arg_13_1, arg_13_5, arg_13_6, arg_13_2, arg_13_4, arg_13_3)

	local var_13_0 = arg_13_0.screenWipe

	if var_13_0 then
		var_13_0:render(arg_13_5)
	end
end

function ScreenWipeIn.onEphemeral(arg_14_0)
	return nil
end
