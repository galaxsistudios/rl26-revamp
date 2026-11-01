import("base.action.action")
import("base.action.action_request")
import("ai.tackle.activetackle_request")
import("rules.playtheball.playtheballentity_request")
import("rules.playtheball.playtheballstate_request")

-- faster-play-the-ball: a quick play-the-ball (branched out of the get-up) kept the facing the
-- tackle left the player in, so he could play the ball side-on to the sideline. Now he turns to
-- face upfield during the transition and plays the straight-on animation, as a normal
-- play-the-ball does. Set false for stock.
QuickPlayTheBallFaceUpfield = true

function BranchToPlayTheBall(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7, arg_1_8, arg_1_9, arg_1_10)
	local var_1_0 = arg_1_10.params
	local var_1_1 = VERIFY(var_1_0.startPosition)
	local var_1_2 = VERIFY(var_1_0.startFacing)
	local var_1_3 = VERIFY(var_1_0.ptbBranchPosition)
	local var_1_4 = VERIFY(var_1_0.ptbBranchFacing)
	local var_1_5 = VERIFY(arg_1_10.playTheBallBranchTime)
	local var_1_6 = VERIFY(var_1_0.tackleGuid)
	local var_1_7 = var_1_1 + native.rotateByDir2(var_1_2, var_1_3)
	local var_1_8 = native.rotateByDir2(var_1_2, var_1_4)
	local var_1_9 = arg_1_5:getPlayDir()
	local var_1_10 = native.angle_signed2(var_1_8, var_1_9)

	if QuickPlayTheBallFaceUpfield then
		pcall(function()
			local var_1_20 = io.open("ptb_decision_debug.txt", "a")

			if var_1_20 then
				var_1_20:write(os.date("%H:%M:%S"), string.format(" FACING quick play-the-ball was %.0f deg off upfield -> turned upfield", math.deg(var_1_10)), "\n")
				var_1_20:close()
			end
		end)

		var_1_8 = var_1_9
		var_1_10 = 0
	end
	local var_1_11 = {
		"down",
		"quick",
		"getup"
	}
	local var_1_12 = arg_1_1.actionProducer:getPlayTheBallContainer():filterAnimations(var_1_10, var_1_11)[1]

	ASSERT(var_1_12)

	local var_1_13 = arg_1_1.animationProvider:getAnimationDuration(var_1_12)
	local var_1_14 = {
		transitionFrameCount = 8,
		wasQuickPlayTheBall = true,
		animName = var_1_12,
		startPosition = var_1_7,
		startFacing = var_1_2,
		startTime = var_1_5,
		targetPosition = var_1_7,
		targetFacing = var_1_8,
		targetTime = var_1_5 + 0.26666666666666666,
		rollBackDisposalId = arg_1_2:alloc(),
		animDuration = var_1_13
	}
	local var_1_15 = action.createAction("PlayTheBallAction", var_1_14)

	arg_1_9:add(playtheballentity_request.PlayTheBallActionSentRequest())

	local var_1_16 = {
		playTheBallState = native.EPlayTheBallState.PlayingTheBall,
		stateChangeTime = arg_1_8
	}

	arg_1_9:add(playtheballstate_request.PlayTheBallStateRequest(var_1_16))
	arg_1_9:add(action_request.requestAction(arg_1_6, arg_1_4, arg_1_2:alloc(), var_1_15))
	arg_1_9:add(activetackle_request.RemoveActiveTackleParticipantRequest(var_1_6, arg_1_4))

	return true
end
