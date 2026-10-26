import("base.controller.controller")
import("script-config.rules.rules.rulesenvironment")
import("design.playtheball_config")
import("rules.rules.rulesenvironment_cconfig")

local var_0_0 = rulesenvironment_cconfig.cBoundaryConfig
local var_0_1 = controller.Controller

controller.controllerclass("QuickDefensiveOnsideAi", var_0_1, function(arg_1_0)
	var_0_1.init(arg_1_0)
end)

-- Debug: one line per defender starting the retreat, to early_retreat_debug.txt
-- (game folder). Turn off for release.
local RetreatDebugLog = true

function QuickDefensiveOnsideAi.onEnter(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	if not RetreatDebugLog then
		return
	end

	pcall(function()
		local var_2_0 = arg_2_7:getPlayTheBallEntity()
		local var_2_1 = io.open("early_retreat_debug.txt", "a")

		if var_2_1 then
			var_2_1:write(os.date("%H:%M:%S"), string.format(" RETREAT id=%s side=%s flagged=%s held=%s quick=%s", tostring(arg_2_5), tostring(arg_2_6.side), tostring(arg_2_6.offsideInfo.flaggedOffside), tostring(var_2_0 and var_2_0.defenseHeldTackle), tostring(var_2_0 and var_2_0.isQuickDefensivePlayTheBall)), "\n")
			var_2_1:flush()
			var_2_1:close()
		end
	end)
end

function QuickDefensiveOnsideAi.update(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	local var_3_0 = arg_3_7:getMatchProgressionEntity().attackingSide
	local var_3_1 = arg_3_6:getDefensiveKnowledge()
	local var_3_2 = arg_3_6:getOffensiveKnowledge()
	local var_3_3 = arg_3_6.side
	local var_3_4 = var_3_3 == var_3_0 and var_3_2 or var_3_1

	ASSERT(var_3_4.targetPosition)

	local var_3_5 = var_3_4.targetPosition
	local var_3_6 = arg_3_6.pos
	local var_3_7 = arg_3_8:getBallObject().pos2
	local var_3_8 = var_3_7.x
	local var_3_9 = arg_3_4:getSide(var_3_0):getPlayDir()
	local var_3_10 = var_3_8 + var_3_9.x * 10
	local var_3_11 = var_0_0.halfFieldLength
	local var_3_12 = native.clamp1(var_3_10, -var_3_11, var_3_11)
	local var_3_13 = native.vec2(var_3_12, var_3_6.y)
	local var_3_14 = math.abs(var_3_5.y - var_3_6.y)

	if var_3_14 <= 0 then
		var_3_14 = 0.01
	end

	local var_3_15 = native.clamp1(var_3_14 / 25, 0, 1)
	local var_3_16 = native.lerp1(var_3_15, var_3_5.y, var_3_6.y)
	local var_3_17 = 1
	local var_3_18 = var_3_13.x

	if var_3_13 ~= var_3_6 and var_3_7 ~= var_3_6 then
		local var_3_19, var_3_20 = native.dirlen2(var_3_13, var_3_6)
		local var_3_21, var_3_22 = native.dirlen2(var_3_7, var_3_6)
		local var_3_23 = native.dot2(var_3_19, var_3_21)
		local var_3_24

		if var_3_9.x < 0 then
			var_3_24 = var_3_6.x < var_3_7.x - var_3_17 * var_3_9.x
		else
			var_3_24 = var_3_6.x > var_3_7.x - var_3_17 * var_3_9.x
		end

		if math.abs(var_3_23) > 0.95 and var_3_22 < var_3_20 and var_3_24 then
			local var_3_25 = var_3_7.y > var_3_6.y and -1 or 1
			local var_3_26 = 4

			var_3_16 = var_3_7.y + var_3_26 * var_3_25
			var_3_18 = var_3_7.x - var_3_17 * var_3_9.x

			print("[Offside] Overriding position X for offside to create a path around the ball.")
		end
	end

	local var_3_27 = native.vec2(var_3_18 - var_3_17 * var_3_9.x, var_3_16)
	local var_3_28 = math.abs(var_3_27.x) > math.abs(var_3_6.x) and math.abs(var_3_7.x) > math.abs(var_3_6.x) or math.abs(var_3_27.x) < math.abs(var_3_6.x) and math.abs(var_3_7.x) < math.abs(var_3_6.x)

	ASSERT(var_3_4.targetFacing)

	local var_3_29 = var_3_6.x < var_3_7.x and native.vec2.XAxis(1) or native.vec2.XAxis(-1)
	local var_3_30 = var_3_28 and var_3_29 or var_3_4.targetFacing

	ASSERT(var_3_4.movementSpeed)

	local var_3_31 = var_3_4.movementSpeed

	ASSERT(var_3_4.targetSpeed)

	local var_3_32 = var_3_4.targetSpeed
	local var_3_33 = arg_3_7:getPlayTheBallEntity()
	-- early-defensive-retreat: also sprint back when the tackle is held
	-- (raised early on TackleCommittedEvent), not only on the human double-tap.
	local var_3_34 = var_3_33 and (var_3_33.isQuickDefensivePlayTheBall or var_3_33.defenseHeldTackle)

	if var_3_3 ~= var_3_0 and var_3_34 then
		var_3_31 = arg_3_6:getDerivedAttribute(playtheball_config.defensivePlayTheBallSpeed)
	end

	local var_3_35 = arg_3_2.hooks
	local var_3_36 = var_3_35 and var_3_35:getHook("DefensiveMovementDebugHook")

	if var_3_36 and var_3_36.lockDefenseMovement then
		local var_3_37 = arg_3_6:getPlayDir()
		local var_3_38 = rulesenvironment.deadBallLine * -var_3_37.x

		var_3_27 = native.vec2(var_3_38, var_3_27.y)
	end

	arg_3_6:setMovementTarget(var_3_27, var_3_30)
	arg_3_6:setMovementSpeed(var_3_31, var_3_32)

	return arg_3_0
end
