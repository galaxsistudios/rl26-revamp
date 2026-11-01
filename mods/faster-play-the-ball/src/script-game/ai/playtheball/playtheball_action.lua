import("base.action.action")
import("base.action.actioncallback")
import("base.action.nilaction_request")
import("core.marshalling.types")
import("game.camera.providers.playtheball_cameraprovider")
import("rules.playtheball.ballplayed_request")
import("script-config.design.ball_config")
import("game.ball.disposal_request")
import("ai.playtheball.quickplaytheballhuman_mixin")

local var_0_0 = load("design.playtheball_config")
local var_0_1 = var_0_0.playTheBallInTouchImmuneWindow
-- faster-play-the-ball: stock read these as module fields, but they live in
-- the cPlayTheBallConfig table, so both were nil and every play-the-ball ran
-- at rate 1 (quick / slow never changed the animation speed).
local var_0_2 = var_0_0.cPlayTheBallConfig.playrateQuickPTB or 1.4
local var_0_3 = var_0_0.cPlayTheBallConfig.playrateSlowPTB or 0.9

-- Dummy half within this many metres of the ball spot = ready for a quick play-the-ball.
DummyHalfReadyDistance = 1.5

-- Scale on the ball's roll-back velocity at the play-the-ball (rolling distance goes with its square).
RollBackVelocityScale = 0.7
-- ...but never below this (m/s): slow heels (1.2-1.4) damped to ~0.9 stopped short and the dummy half
-- didn't reach them. Only the fast 2.15 heels that rolled past him get slowed.
RollBackMinSpeed = 1.4

local var_0_4 = action.Action

action.actionclass("PlayTheBallAction", var_0_4, function(arg_1_0, arg_1_1)
	var_0_4.init(arg_1_0, arg_1_1)

	for iter_1_0, iter_1_1 in pairs(PlayTheBallAction.MemberDefinitions) do
		arg_1_0[iter_1_0] = arg_1_1[iter_1_0]
	end
end).MemberDefinitions = {
	animName = types.String("AnimName"),
	startPosition = types.Vec2,
	startFacing = types.UnitVec2,
	startTime = types.Time,
	targetPosition = types.Nilable(types.Vec2),
	targetFacing = types.Nilable(types.UnitVec2),
	rollBackDisposalId = types.Guid,
	animDuration = types.Number,
	wasQuickPlayTheBall = types.Boolean
}
PlayTheBallAction.CanCollideWithBall = false

function PlayTheBallAction.getInTouchImmune(arg_2_0, arg_2_1)
	if not arg_2_0.startTime then
		return true
	end

	return arg_2_1 > arg_2_0.startTime + var_0_1
end

function PlayTheBallAction.validate(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4)
	return true
end

function PlayTheBallAction.apply(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4)
	local var_4_0 = arg_4_0.animDuration

	ASSERT(var_4_0)

	local var_4_1 = arg_4_1:getIncapacitatedInfoPool():get(arg_4_2)

	var_4_1.incapacitatedStartTime = arg_4_3
	var_4_1.incapacitatedStopTime = arg_4_3 + var_4_0 + var_0_0.IncapactionDuration
end

function PlayTheBallAction.executeRollBack(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7, arg_5_8, arg_5_9, arg_5_10, arg_5_11, arg_5_12)
	local var_5_0 = arg_5_0.rollBackDisposalId
	local var_5_1 = assert(arg_5_4:getBallObject())
	local var_5_2 = arg_5_2:getGamer()
	local var_5_3 = {
		gamerId = var_5_2 and var_5_2:getGamerId(),
		disposalType = native.EDisposalType.Kick,
		disposalSubType = native.EDisposalSubType.PlayTheBall,
		objectId = arg_5_1,
		disposalId = var_5_0
	}

	disposal_request.initDisposalInfoFromGameState(arg_5_6, var_5_3, var_5_1)

	local var_5_4 = arg_5_11.t
	local var_5_5 = arg_5_11.q
	local var_5_6 = var_5_1.ballPositionJobContext.jointToBallRotation

	var_5_3.originPos = var_5_4
	var_5_3.orientation = var_5_5 * var_5_6

	local var_5_7 = arg_5_9 + arg_5_12.detachOffsetTime

	var_5_3.disposalTime = var_5_7
	var_5_3.dontClearIntendedDisposal = true

	local var_5_8 = arg_5_12.detachBallVelocity
	local var_5_9 = native.vec3(var_5_8.x, 0, var_5_8.y)

	var_5_3.initialVelocity = native.quat.transform(arg_5_10.q, var_5_9)

	-- faster-play-the-ball: heel the ball back more softly so it stops at the dummy half's
	-- feet. At the animation's full speed it could roll past him and he had to turn and chase.
	pcall(function()
		local var_5_20 = native.length3(var_5_3.initialVelocity)

		local var_5_22 = math.max(var_5_20 * RollBackVelocityScale, math.min(var_5_20, RollBackMinSpeed))

		if var_5_20 > 0 then
			var_5_3.initialVelocity = var_5_3.initialVelocity * (var_5_22 / var_5_20)
		end

		local var_5_21 = io.open("ptb_decision_debug.txt", "a")

		if var_5_21 then
			var_5_21:write(os.date("%H:%M:%S"), string.format(" ROLLBACK speed %.2f -> %.2f", var_5_20, var_5_22), "\n")
			var_5_21:close()
		end
	end)

	local var_5_10 = arg_5_12.detachBallAngularVelocity
	local var_5_11 = native.quat.transform(arg_5_10.q, var_5_10)

	var_5_3.rollSpeed = native.length3(var_5_11)

	if var_5_3.rollSpeed > 0 then
		var_5_3.localRollAxis = native.normalize3(var_5_11)
	else
		var_5_3.localRollAxis = native.vec3.ZAxis()
	end

	formatPrint("[PlayTheBallAction:executeRollBack] localRollAxis: vec3(%.2f, %.2f, %.2f) rollSpeed: %.2f", var_5_3.localRollAxis.x, var_5_3.localRollAxis.y, var_5_3.localRollAxis.z, var_5_3.rollSpeed)
	arg_5_7:add(disposal_request.DisposalRequest(var_5_3))

	local var_5_12 = {
		ballPlayedPosition = var_5_4:tovec2(),
		ballPlayedTime = var_5_7
	}

	arg_5_7:add(ballplayed_request.BallPlayedRequest(var_5_12))

	local var_5_13 = arg_5_6.gameplayCameras:getGroup("gameplay").activeCamera

	var_5_13:removeInterpolationPointProvider("playtheball")
	var_5_13:removeZoomProvider("playTheBallZoomProvider")
	arg_5_3:getPenaltyEntity():reset()
	arg_5_3:getTackleEntity():setTacklesAllowed(true)

	if arg_5_0.gamepadHudRight then
		arg_5_0.gamepadHudRight:hide(true)
	end

	if arg_5_0.gamepadHudLeft then
		arg_5_0.gamepadHudLeft:hide(true)
	end
end

function PlayTheBallAction.addCallbacks(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8)
	local var_6_0 = arg_6_0.animName
	local var_6_1 = arg_6_0.startPosition
	local var_6_2 = arg_6_0.startFacing
	local var_6_3 = arg_6_0.startTime
	local var_6_4 = arg_6_0.targetPosition
	local var_6_5 = arg_6_0.targetFacing
	local var_6_6 = arg_6_0.rollBackDisposalId
	local var_6_7 = arg_6_0.wasQuickPlayTheBall and 8 or 15
	local var_6_8 = arg_6_0.startTime + var_6_7 / 30
	local var_6_9 = arg_6_5:getPlayTheBallEntity()
	local var_6_10 = var_6_9.isQuickPlayTheBall and var_0_2 or var_6_9.isSlowPlayTheBall and var_0_3 or 1


	-- faster-play-the-ball: the quick rate only once the dummy half is standing
	-- over the ruck. Played at 1.4 the ball came out before he arrived on ~6% of
	-- AI quick play-the-balls and the marker picked it up. Otherwise rate 1 (what
	-- stock quick really played at), which gives him the time to get there.
	if var_6_9.isQuickPlayTheBall then
		local var_6_34, var_6_36 = pcall(function()
			local var_6_30 = var_6_9.dummyHalfId
			local var_6_31 = var_6_30 and arg_6_2.knowledgeBank.positionInfoPool:get(var_6_30).position
			local var_6_32 = var_6_31 and native.length2(var_6_31 - var_6_1) or -1

			if not var_6_31 or var_6_32 > DummyHalfReadyDistance then
				var_6_10 = 1
			end

			local var_6_33 = io.open("ptb_decision_debug.txt", "a")

			if var_6_33 then
				var_6_33:write(os.date("%H:%M:%S"), string.format(" ACTION quick play-the-ball dummyHalf=%s dist=%.2f -> rate=%.2f", tostring(var_6_30), var_6_32, var_6_10), "\n")
				var_6_33:close()
			end
		end)

		if not var_6_34 then
			pcall(function()
				local var_6_35 = io.open("ptb_decision_debug.txt", "a")

				if var_6_35 then
					var_6_35:write(os.date("%H:%M:%S"), " ACTION quick play-the-ball dummy-half check failed: ", tostring(var_6_36), "\n")
					var_6_35:close()
				end
			end)
		end
	end

	-- faster-play-the-ball: a human ball carrier who spammed pass during the
	-- hold-down / get-up plays the ball faster than the stock quick rate.
	if var_6_9.isQuickPlayTheBall then
		pcall(function()
			local var_6_20 = quickplaytheballhuman_mixin.QuickPlayTheBallRate

			if not var_6_20 then
				return
			end

			-- Matched by time: the pass spam was within QuickPlayTheBallRateWindow
			-- of this play-the-ball starting (only the spammer's own play-the-ball
			-- can start that soon after).
			local var_6_21 = var_6_20.carrier
			local var_6_24 = var_6_3 and var_6_20.time and var_6_3 - var_6_20.time
			local var_6_22 = var_6_24 ~= nil and var_6_24 >= -0.5 and var_6_24 <= quickplaytheballhuman_mixin.QuickPlayTheBallRateWindow

			if var_6_22 then
				var_6_10 = var_6_20.rate
			end

			-- Debug (ptb_decision_debug.txt): which rate this quick play-the-ball used.
			local var_6_23 = io.open("ptb_decision_debug.txt", "a")

			if var_6_23 then
				var_6_23:write(os.date("%H:%M:%S"), string.format(" ACTION quick play-the-ball rate=%.2f (spam carrier=%s matched=%s)", var_6_10, tostring(var_6_21), tostring(var_6_22)), "\n")
				var_6_23:close()
			end
		end)
	end
	local var_6_11 = arg_6_7:addBodyCommand(var_6_0, arg_6_4, arg_6_6, {
		startPosition = var_6_1,
		startFacing = var_6_2,
		startTime = var_6_3,
		targetPosition = var_6_4,
		targetFacing = var_6_5,
		targetTime = var_6_8,
		transitionFrameCount = var_6_7,
		playRate = var_6_10
	})
	local var_6_12 = arg_6_4:getAnimationProvider()
	local var_6_13 = actioncallback.getEventTime(arg_6_4, arg_6_6, var_6_11, "detach_ball")

	ASSERT(var_6_13)

	arg_6_0.disposalTime = var_6_13

	arg_6_1:addEventCallback(actioncallback.atTime(arg_6_4, arg_6_6, var_6_11, arg_6_8, function(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6)
		local var_7_0 = arg_6_2.actionProducer:getPlayTheBallContainer():getAnimDataByName(var_6_0)
		local var_7_1 = var_7_0.detachOffsetPosition
		local var_7_2 = var_7_0.detachOffsetOrientation
		local var_7_3 = arg_7_1.scale or 1
		local var_7_4 = native.frame.fromQuatPos(var_7_2, var_7_1:tovec3() * var_7_3)
		local var_7_5 = native.frame.fromQuatPos(native.quat.fromDir2(var_6_2), var_6_1:tovec3(ball_config.minorDiameter / 2))
		local var_7_6 = var_7_5:transform(var_7_4)

		arg_6_2.gameplayCameras:getGroup("gameplay").activeCamera:pushInterpolationPointProviderBelow("defaultInterpolationPointProvider", playtheball_cameraprovider.PlayTheBallInterpolationPointProvider(), "playtheball")
		arg_6_0:executeRollBack(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_5, arg_6_2, arg_7_6, var_6_11, var_6_3, var_7_5, var_7_6, var_7_0)
	end))
	arg_6_1:addEventCallback(actioncallback.atAnimationWane(arg_6_6, var_6_11, function(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5, arg_8_6)
		arg_8_6:add(nilaction_request.createRequest(arg_8_2, arg_8_0))
	end))
end
