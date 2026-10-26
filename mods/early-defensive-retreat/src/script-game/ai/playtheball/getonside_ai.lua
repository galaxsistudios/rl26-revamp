import("base.controller.controller")
import("base.side.sidehelper")
import("script-config.rules.rules.rulesenvironment")
import("design.playtheball_config")

local var_0_0 = controller.Controller

controller.controllerclass("GetOnsideAi", var_0_0, function(arg_1_0)
	var_0_0.init(arg_1_0)
end)

function GetOnsideAi.onEnter(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	return
end

function GetOnsideAi.update(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	local var_3_0 = arg_3_7:getMatchProgressionEntity().attackingSide
	local var_3_1 = arg_3_6:getDefensiveKnowledge()
	local var_3_2 = arg_3_6:getOffensiveKnowledge()
	local var_3_3 = arg_3_6.side
	local var_3_4 = var_3_3 == var_3_0 and var_3_2 or var_3_1

	ASSERT(var_3_4.targetPosition)

	local var_3_5 = var_3_4.targetPosition
	local var_3_6 = arg_3_6.onsidePosition
	local var_3_7 = arg_3_6.pos
	local var_3_8 = arg_3_4:getSide(sidehelper.getOtherSide(var_3_0))
	local var_3_9 = arg_3_4:getSide(var_3_0)
	local var_3_10 = (var_3_3 == var_3_0 and var_3_9 or var_3_8):getPlayDir()
	local var_3_11 = math.abs(var_3_5.y - var_3_7.y)

	if var_3_11 <= 0 then
		var_3_11 = 0.01
	end

	local var_3_12 = native.clamp1(var_3_11 / 25, 0, 1)
	local var_3_13 = native.lerp1(var_3_12, var_3_5.y, var_3_7.y)
	local var_3_14 = 1
	local var_3_15 = var_3_6.x
	local var_3_16 = arg_3_8:getBallObject().pos2

	if var_3_6 ~= var_3_7 and var_3_16 ~= var_3_7 then
		local var_3_17, var_3_18 = native.dirlen2(var_3_6, var_3_7)
		local var_3_19, var_3_20 = native.dirlen2(var_3_16, var_3_7)
		local var_3_21 = native.dot2(var_3_17, var_3_19)
		local var_3_22

		if var_3_10.x < 0 then
			var_3_22 = var_3_7.x < var_3_16.x - var_3_14 * var_3_10.x
		else
			var_3_22 = var_3_7.x > var_3_16.x - var_3_14 * var_3_10.x
		end

		if math.abs(var_3_21) > 0.95 and var_3_20 < var_3_18 and var_3_22 then
			local var_3_23 = var_3_16.y > var_3_7.y and -1 or 1
			local var_3_24 = 4

			var_3_13 = var_3_16.y + var_3_24 * var_3_23
			var_3_15 = var_3_16.x - var_3_14 * var_3_10.x

			print("[Offside] Overriding position X for offside to create a path around the ball.")
		end
	end

	local var_3_25 = native.vec2(var_3_15 - var_3_14 * var_3_10.x, var_3_13)
	local var_3_26 = math.abs(var_3_25.x) > math.abs(var_3_7.x) and math.abs(var_3_16.x) > math.abs(var_3_7.x) or math.abs(var_3_25.x) < math.abs(var_3_7.x) and math.abs(var_3_16.x) < math.abs(var_3_7.x)

	ASSERT(var_3_4.targetFacing)

	local var_3_27 = var_3_7.x < var_3_16.x and native.vec2.XAxis(1) or native.vec2.XAxis(-1)
	local var_3_28 = var_3_26 and var_3_27 or var_3_4.targetFacing

	ASSERT(var_3_4.movementSpeed)

	local var_3_29 = var_3_4.movementSpeed

	ASSERT(var_3_4.targetSpeed)

	local var_3_30 = var_3_4.targetSpeed
	local var_3_31 = arg_3_7:getPlayTheBallEntity()
	-- early-defensive-retreat: sprint while the tackle is held too (raised early
	-- on TackleCommittedEvent), not only on the human double-tap.
	local var_3_32 = var_3_31 and (var_3_31.isQuickDefensivePlayTheBall or var_3_31.defenseHeldTackle)

	if var_3_3 ~= var_3_0 and var_3_32 then
		var_3_29 = arg_3_6:getDerivedAttribute(playtheball_config.defensivePlayTheBallSpeed)
	end

	local var_3_33 = arg_3_2.hooks
	local var_3_34 = var_3_33 and var_3_33:getHook("DefensiveMovementDebugHook")

	if var_3_34 and var_3_34.lockDefenseMovement then
		local var_3_35 = arg_3_6:getPlayDir()
		local var_3_36 = rulesenvironment.deadBallLine * -var_3_35.x

		var_3_25 = native.vec2(var_3_36, var_3_25.y)
	end

	arg_3_6:setMovementTarget(var_3_25, var_3_28)
	arg_3_6:setMovementSpeed(var_3_29, var_3_30)

	return arg_3_0
end
