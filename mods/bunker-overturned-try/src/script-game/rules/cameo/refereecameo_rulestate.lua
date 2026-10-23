import("ai.officials.refereehelper")
import("ai.officials.touchjudgesignal_request")
import("core.marshalling.types")
import("game.player.playertype")
import("rules.match.matchtime")
import("base.rulestate.rulestateclass")

-- bunker-overturned-try: the referee cameo that sends a provisional try upstairs starts while
-- the try replay is still playing (the sim runs under it). With waitForProvisionalOutro it
-- holds the referee's signal, the cameo timer and skip until the logo wipe out of the replay
-- starts sliding off (screenwipe.lua sets ProvisionalTryState.outroReleased), plus
-- ProvisionalTrySignalDelay. Fallback: once no replay or wipe is on the universe stack and
-- the logo isn't running, or after ProvisionalTryOutroTimeout.
local ProvisionalTrySignalDelay = 0
-- Seconds from the signal to the cut to the bunker replay (stock cameo: 5 s, which runs on
-- into the referee crossing his arms). The debug log prints the signal animation's length
-- and events 0.3 s in, to tune this against.
local ProvisionalTryCameoLength = 2.4
local ProvisionalTryOutroTimeout = 40
local ProvisionalTryTransitionStates = {
	ReplayUniverseState = true,
	InteractiveReplayUniverseState = true,
	ScreenWipeOut = true,
	ScreenWipeIn = true,
	LogoScreenWipeOut = true,
	LogoScreenWipeIn = true
}

local function provisionalTryOutroDone(arg_universe, arg_services)
	local var_state = rawget(_G, "ProvisionalTryState")

	if var_state and var_state.outroReleased then
		return true, "logo wipe sliding off"
	end

	local var_stack = arg_universe and arg_universe:getUniverseStateStack()

	if not var_stack then
		return false
	end

	for iter_0, iter_1 in ipairs({
		var_stack.currentStack or {},
		var_stack.nextStack or {}
	}) do
		for iter_2, iter_3 in ipairs(iter_1) do
			if ProvisionalTryTransitionStates[type(iter_3)] then
				return false
			end
		end
	end

	local var_logo = arg_services.hud and arg_services.hud:getElement("logotransition")

	if var_logo and not var_logo:isFinished() then
		return false
	end

	return true, "no replay or wipe left"
end

local function provisionalTryLogRefereeAnim(arg_gamestate, arg_gameobjects, arg_log)
	local var_refereeId = arg_gamestate:getOfficialEntity():getRefereesIds()
	local var_referee = arg_gameobjects:getGameObject(var_refereeId)
	local var_player = var_referee:getAnimPlayer()
	local var_name = var_player:getBodyAnimName()
	local var_time = var_player:getPrimaryCommand():getAnimationTime()
	local var_provider = var_referee:getAnimationProvider()
	local var_text = string.format("referee cameo: signal anim %s at %.2fs", tostring(var_name), var_time or -1)
	local var_anim = var_provider:getAnimationByName(var_name)

	if var_anim then
		for iter_0, iter_1 in ipairs({
			"getDuration",
			"getLength",
			"duration",
			"length"
		}) do
			local var_ok, var_value = pcall(function()
				local var_field = var_anim[iter_1]

				return rawtype(var_field) == "function" and var_field(var_anim) or var_field
			end)

			if var_ok and var_value ~= nil then
				var_text = var_text .. ", " .. iter_1 .. " " .. tostring(var_value)

				break
			end
		end

		local var_ok, var_events = pcall(var_provider.getAllEvents, var_provider, var_name)

		if var_ok and rawtype(var_events) == "table" then
			local var_parts = {}

			for iter_2, iter_3 in pairs(var_events) do
				local var_eventName = rawtype(iter_3) == "table" and (iter_3.name or iter_3.eventName) or iter_3
				local var_eventTime = rawtype(var_eventName) == "string" and var_provider:getEventAnimTime(var_name, var_eventName)

				table.insert(var_parts, tostring(var_eventName) .. (var_eventTime and string.format("@%.2f", var_eventTime) or ""))
			end

			var_text = var_text .. ", events: " .. table.concat(var_parts, " ")
		end
	end

	arg_log(var_text)
end

rulestateclass.rulestateclass("RefereeCameoRuleState", function(arg_1_0, arg_1_1)
	for iter_1_0, iter_1_1 in pairs(RefereeCameoRuleState.MemberDefinitions) do
		arg_1_0[iter_1_0] = arg_1_1[iter_1_0]
	end
end).MemberDefinitions = {
	nextState = types.RuleState,
	delayBeforeSignal = types.Number,
	isVideoReferee = types.Boolean,
	isCaptainsChallenge = types.Nilable(types.Boolean),
	activateStoppageTime = types.Nilable(types.Boolean),
	offendingSide = types.Nilable(types.Team),
	restartSide = types.Nilable(types.Team),
	outPosition = types.Nilable(types.Vec2),
	refereeSignal = types.Nilable(types.OfficialSignalType),
	touchJudgeSignal = types.Nilable(types.OfficialSignalType),
	skipReplayEvent = types.Nilable(types.Boolean),
	waitForProvisionalOutro = types.Nilable(types.Boolean)
}
RefereeCameoRuleState.HidePlayerMarkers = true
RefereeCameoRuleState.HideBallMarkers = true

function RefereeCameoRuleState.getSwitchingEnabledForSide(arg_2_0, arg_2_1, arg_2_2)
	return arg_2_0.enablePlayerSwitching
end

function RefereeCameoRuleState.getBlockSwitchingGamers(arg_3_0, arg_3_1)
	return arg_3_0.blockGamerSwitching
end

function RefereeCameoRuleState.apply(arg_4_0, arg_4_1, arg_4_2)
	matchtime.updateTime(arg_4_1, arg_4_2)
	matchtime.startStoppageTime(arg_4_1, arg_4_2)
end

function RefereeCameoRuleState.onEnterSolid(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7, arg_5_8, arg_5_9, arg_5_10)
	local var_5_0, var_5_1, var_5_2 = arg_5_6:getOfficialEntity():getRefereesIds()
	local var_5_3 = arg_5_7:getGameObject(var_5_0)
	local var_5_4 = arg_5_0.refereeSignal

	if not var_5_4 then
		return
	end

	local var_5_5

	if var_5_3 then
		local var_5_6 = arg_5_6:getMatchProgressionEntity().directionOfPlay
		local var_5_7 = refereehelper.getRefereeFacing(arg_5_6, var_5_3, var_5_4, var_5_6)

		var_5_3:resetTo(var_5_3.pos, var_5_7, arg_5_8)

		var_5_3.actorModel.visible = true
	end

	for iter_5_0, iter_5_1 in arg_5_7:activeObjects(playertype.TypeId) do
		iter_5_1:setBehaviour("Idle", arg_5_8)
	end

	local var_5_8 = arg_5_3.hud and arg_5_3.hud.featureStack

	if var_5_8 then
		var_5_8:push("cameo")
	end

	arg_5_0.skipStateMixin = arg_5_3.skipStateProvider:createMixinFromConfig("Default")

	local var_5_9 = arg_5_3.cameoCamera

	var_5_9:setTimer(5)
	var_5_9:setPendingCameos(1)
	arg_5_3.cameoCamera:enable()

	if not arg_5_0.skipReplayEvent then
		table.insert(arg_5_9, {
			type = "QueueReplayEvent",
			isVideoReferee = arg_5_0.isVideoReferee,
			time = arg_5_8
		})
	end
end

function RefereeCameoRuleState.onExitSolid(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8, arg_6_9, arg_6_10)
	local var_6_0 = arg_6_3.hud and arg_6_3.hud.featureStack

	if var_6_0 then
		var_6_0:pop("cameo")
	end

	if arg_6_0.skipStateMixin then
		arg_6_0.skipStateMixin:release()
	end

	arg_6_3.cameoCamera:disable(arg_6_7)

	local var_6_1 = arg_6_3.hud

	if arg_6_0.isVideoReferee then
		local var_6_2 = var_6_1 and var_6_1:getElement("videoRef")

		if var_6_2 then
			var_6_2:show()
			var_6_2:SetVisualKey("Default")
		end
	end

	local var_6_3 = arg_6_6:getCaptainsChallengeEntity()
	local var_6_4 = var_6_1:getElement("CaptainsChallengeHud")

	if arg_6_0.isCaptainsChallenge and var_6_4 then
		local var_6_5 = false
		local var_6_6 = true
		local var_6_7 = false

		var_6_3.lastChallengeSide = arg_6_0.offendingSide

		var_6_4:setDecidingSide(arg_6_0.offendingSide)
		var_6_4:show(var_6_5, var_6_6, var_6_7)
		var_6_3:setShowCaptainsChallengesRemaining(true)
	end

	local var_6_8 = var_6_3:getShowCaptainsChallengesRemaining()

	if not arg_6_0.isCaptainsChallenge and var_6_8 then
		var_6_4:setDecidingSide(arg_6_0.offendingSide)
		var_6_4:setRemaining(var_6_3.lastChallengeSide, var_6_3:getCaptainsChallengeRemaining(var_6_3.lastChallengeSide))
		var_6_4:show(false, false, true)

		local var_6_9 = arg_6_3.hooks

		if var_6_9 then
			local var_6_10 = var_6_9 and var_6_9:getHook("CaptainsChallengeDebugHook")

			if var_6_10 and var_6_10.forceUnlimitedChallenges then
				return
			end
		end

		var_6_3:setShowCaptainsChallengesRemaining(false)
	end
end

function RefereeCameoRuleState.updateSolid(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7, arg_7_8, arg_7_9, arg_7_10, arg_7_11)
	-- bunker-overturned-try
	if arg_7_0.waitForProvisionalOutro then
		arg_7_0.provisionalWait = (arg_7_0.provisionalWait or 0) + arg_7_8

		local var_p_0, var_p_1, var_p_2 = pcall(provisionalTryOutroDone, arg_7_1 and arg_7_1.universe, arg_7_3)
		local var_p_3 = var_p_0 and var_p_1

		if not var_p_3 and arg_7_0.provisionalWait >= ProvisionalTryOutroTimeout then
			var_p_3, var_p_2 = true, "timed out"
		end

		if var_p_3 and not arg_7_0.provisionalOutroTime then
			arg_7_0.provisionalOutroTime = arg_7_0.provisionalWait

			local var_p_4 = rawget(_G, "ProvisionalTryState")

			if var_p_4 and var_p_4.log then
				var_p_4.log(string.format("referee cameo: starting after %.2fs (%s)", arg_7_0.provisionalWait, tostring(var_p_0 and var_p_2 or var_p_1)))
			end
		end

		if not arg_7_0.provisionalOutroTime or arg_7_0.provisionalWait < arg_7_0.provisionalOutroTime + ProvisionalTrySignalDelay then
			arg_7_3.cameoCamera:setTimer(5)

			if arg_7_0.skipStateMixin then
				arg_7_0.skipStateMixin:checkForSkip()
			end

			return
		end

		arg_7_0.waitForProvisionalOutro = nil
		arg_7_0.provisionalSinceSignal = 0

		arg_7_3.cameoCamera:setTimer(ProvisionalTryCameoLength)
	end

	if arg_7_0.provisionalSinceSignal then
		local var_p_5 = arg_7_0.provisionalSinceSignal

		arg_7_0.provisionalSinceSignal = var_p_5 + arg_7_8

		local var_p_6 = rawget(_G, "ProvisionalTryState")

		if var_p_5 < 0.3 and arg_7_0.provisionalSinceSignal >= 0.3 and var_p_6 and var_p_6.log then
			local var_p_7, var_p_8 = pcall(provisionalTryLogRefereeAnim, arg_7_6, arg_7_7, var_p_6.log)

			if not var_p_7 then
				var_p_6.log("referee cameo: anim log error: " .. tostring(var_p_8))
			end
		end
	end

	local var_7_0 = arg_7_0.refereeSignal

	if var_7_0 and not arg_7_0.refereeSignalSent then
		arg_7_11:add(native.COfficialSignalRequest(var_7_0))

		arg_7_0.refereeSignalSent = true
	end

	if arg_7_0.touchJudgeSignal and arg_7_0.outPosition and not arg_7_0.touchJudgeSignalSent then
		arg_7_11:add(touchjudgesignal_request.TouchJudgeSignalRequest({
			signalId = arg_7_0.touchJudgeSignal,
			position = arg_7_0.outPosition
		}))

		arg_7_0.touchJudgeSignalSent = true
	end

	local var_7_1 = false

	if arg_7_0.skipStateMixin and arg_7_0.skipStateMixin:checkForSkip() then
		local var_7_2 = arg_7_3.soundSystem

		if var_7_2 then
			var_7_2:stopRefereeDialogue()
		end

		var_7_1 = true
	end

	if not arg_7_3.network:isMaster() then
		return
	end

	if arg_7_0.haveSentRequest then
		return
	end

	local var_7_3 = arg_7_3.cameoCamera
	local var_7_4 = false

	if var_7_1 or var_7_3:isFinished() then
		var_7_4 = true
	end

	if not var_7_4 then
		print("Early out if the request has been sent")

		return
	end

	arg_7_0.haveSentRequest = true

	print("Go to next state ..... %s", tostring(arg_7_0.nextState))
	arg_7_11:addRuleStateRequest(arg_7_0.nextState, arg_7_4:alloc())
end
