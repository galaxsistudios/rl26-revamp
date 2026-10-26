import("ai.playtheball.quickdefensiveplaytheballhuman_mixin")
import("base.controller.controller")
import("ai.humancontroller.movehuman_mixin")
import("ai.humancontroller.moveonsidemovement_mixin")
import("ai.tackle.pushtacklehuman_mixin")
import("ai.tackle.ballstriptacklehuman_mixin")
import("ai.tackle.tacklehuman_mixin")

local var_0_0 = controller.Controller

controller.controllerclass("DefendingControlledRoamHuman", var_0_0, function(arg_1_0)
	var_0_0.init(arg_1_0)

	-- early-defensive-retreat: double-tap left trigger to retreat the line, checked here too
	arg_1_0.quickDefensivePlayTheBallHumanMixin = quickdefensiveplaytheballhuman_mixin.QuickDefensivePlayTheBallHumanMixin()

	arg_1_0.moveMixin = movehuman_mixin.MoveHumanMixin()
	arg_1_0.pushTackleHumanMixin = pushtacklehuman_mixin.PushTackleHumanMixin()
	arg_1_0.ballStripTackleHumanMixin = ballstriptacklehuman_mixin.BallStripTackleHumanMixin()
	arg_1_0.tackleMixin = tacklehuman_mixin.TackleHumanMixin()
	arg_1_0.moveOnsideMovementMixin = moveonsidemovement_mixin.MoveOnsideMovementMixin()
end)

function DefendingControlledRoamHuman.onEnter(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10, arg_2_11)
	arg_2_0.moveMixin:onEnter(arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	arg_2_0.pushTackleHumanMixin:onEnter(arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	arg_2_0.ballStripTackleHumanMixin:onEnter(arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	arg_2_0.tackleMixin:onEnter(arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)

	arg_2_0.deferControl = true
end

function DefendingControlledRoamHuman.update(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	local var_3_0 = arg_3_1:getGamer(arg_3_5)

	ASSERT(var_3_0)

	if not var_3_0 then
		return nil
	end

	local var_3_1 = arg_3_2.knowledgeBank.forceDirectedGraphControlPool

	ASSERT(var_3_1)

	local var_3_2 = var_3_1:get(arg_3_5)

	var_3_2:setActive()

	local var_3_3 = arg_3_6:getDefensiveKnowledge()

	ASSERT(var_3_3.graphNodeBasePosition)

	var_3_2.basePosition = var_3_3.graphNodeBasePosition

	local var_3_4 = var_3_0:getInputEvent("Global", "MovePlayer")

	if var_3_4 and var_3_4:getStickDir("left") then
		arg_3_0.deferControl = false
	else
		arg_3_0.deferControl = true
	end

	local var_3_5 = arg_3_6.offsideInfo

	ASSERT(var_3_5)

	local var_3_6 = var_3_5.flaggedOffside
	local var_3_7 = arg_3_6.onsidePosition
	local var_3_8 = var_3_0:getAutoOnside() and var_3_6

	if arg_3_0.deferControl then
		local var_3_9 = var_3_0:getInputEvent("DontHaveBall", "ControlledMovement") and true or false

		arg_3_6:setHumanControlledMovement(var_3_9)

		if var_3_8 then
			arg_3_0.moveOnsideMovementMixin:update(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
		elseif var_3_9 then
			ASSERT(var_3_3.targetPosition)

			local var_3_10 = var_3_3.graphNodeBasePosition

			ASSERT(var_3_3.targetFacing)

			local var_3_11 = var_3_3.targetFacing

			ASSERT(var_3_3.movementSpeed)

			local var_3_12 = var_3_3.movementSpeed

			ASSERT(var_3_3.targetSpeed)

			local var_3_13 = var_3_3.targetSpeed

			arg_3_6:setMovementTarget(var_3_10, var_3_11)
			arg_3_6:setMovementSpeed(var_3_12, var_3_13)
		else
			arg_3_0.moveMixin:update(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
		end
	else
		arg_3_0.moveMixin:update(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	end

	arg_3_0.pushTackleHumanMixin:update(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	arg_3_0.ballStripTackleHumanMixin:update(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	arg_3_0.tackleMixin:update(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)

	arg_3_0.quickDefensivePlayTheBallHumanMixin:update(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)

	return arg_3_0
end

function DefendingControlledRoamHuman.onExit(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7, arg_4_8, arg_4_9, arg_4_10)
	local var_4_0 = arg_4_2.knowledgeBank

	ASSERT(var_4_0)

	local var_4_1 = var_4_0.forceDirectedGraphControlPool

	ASSERT(var_4_1)
	var_4_1:get(arg_4_5):setInactive()
end
