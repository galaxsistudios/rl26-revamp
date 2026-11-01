import("base.controller.controller")
import("ai.kicking.kickoffidle_ai")

local var_0_0 = controller.Controller

controller.controllerclass("KickOffRunUpAi", var_0_0, function(arg_1_0)
	var_0_0.init(arg_1_0)
end)

function KickOffRunUpAi.onEnter(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	-- attack-play-coverage: a re-entry once the ball is in the air keeps chasing instead of restarting the jog.
	if kickoffidle_ai.kickOffInAir(arg_2_2, arg_2_7, arg_2_9) then
		arg_2_0.nextChase = nil

		return
	end

	local var_2_0 = arg_2_6.pos + arg_2_6.facing * 20
	local var_2_1 = native.CMoveToTarget(arg_2_5, var_2_0, arg_2_9, arg_2_2)

	var_2_1.facing = arg_2_6.facing
	var_2_1.speed = arg_2_6:getDerivedAttribute("jog_speed")

	arg_2_10:add(native.CMovementRequest(arg_2_5, arg_2_3:alloc(), var_2_1))

	arg_2_0.nextChase = nil
end

function KickOffRunUpAi.update(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	-- attack-play-coverage: stock did nothing here, so after the 20 m jog the chasers stopped while the
	-- kick-off was still in the air (the flowchart keeps them in this controller). Sprint at the landing spot.
	pcall(kickoffidle_ai.kickOffChase, arg_3_0, arg_3_2, arg_3_3, arg_3_5, arg_3_6, arg_3_7, arg_3_10, arg_3_11)

	return arg_3_0
end
