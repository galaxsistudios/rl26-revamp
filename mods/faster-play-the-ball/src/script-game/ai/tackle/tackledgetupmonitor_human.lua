import("ai.playtheball.quickplaytheballhuman_mixin")
import("ai.playtheball.playtheball_helper")
import("base.controller.controller")
import("design.playtheball_config")
import("script-config.rules.rules.rulesenvironment")

local var_0_0 = controller.Controller

controller.controllerclass("TackledGetUpMonitorHuman", var_0_0, function(arg_1_0)
	var_0_0.init(arg_1_0)

	-- faster-play-the-ball: read the quick play-the-ball double-tap here too
	arg_1_0.quickPlayTheBallMixin = quickplaytheballhuman_mixin.QuickPlayTheBallHumanMixin()
end)

function TackledGetUpMonitorHuman.onEnter(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	arg_2_0.hasBranched = false
	arg_2_0.hasBigHit = false
end

function TackledGetUpMonitorHuman.update(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	-- faster-play-the-ball: first, so a double-tap during the get-up still sets
	-- the quick flag before the branch-to-play-the-ball check below.
	arg_3_0.quickPlayTheBallMixin:update(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)

	local var_3_0 = arg_3_4:getComponent("matchInData")

	ASSERT(var_3_0)

	local var_3_1 = var_3_0.matchType

	ASSERT(var_3_1)

	local var_3_2 = var_3_1.maxTackleCount

	ASSERT(var_3_2)

	local var_3_3 = arg_3_7:getMatchProgressionEntity()

	ASSERT(var_3_3)

	if var_3_2 <= var_3_3.tackleCount then
		return arg_3_0
	end

	local var_3_4 = arg_3_7:getBallEntity()

	ASSERT(var_3_4)

	local var_3_5 = var_3_4:getOwnerId(arg_3_10)

	if not (var_3_5 and var_3_5 == arg_3_5) then
		return arg_3_0
	end

	local var_3_6 = arg_3_6:getAction(arg_3_7)
	local var_3_7 = arg_3_6:getActionName(arg_3_7)

	ASSERT(var_3_6)
	ASSERT(arg_3_6:getActionName(arg_3_7) == "TackledGetUpAction")

	local var_3_8 = var_3_6.params
	local var_3_9 = var_3_6:hasAnimationStarted(arg_3_10 - 0.1)
	local var_3_10 = var_3_8.tackleGuid
	local var_3_11 = var_3_8.blockGuid

	ASSERT(var_3_10)
	ASSERT(var_3_11)

	local var_3_12 = arg_3_2.knowledgeBank.playerActiveTackleKnowledgePool

	ASSERT(var_3_12)

	local var_3_13 = var_3_12:get(arg_3_5)

	ASSERT(var_3_13)

	if var_3_13.offloadPossible then
		return arg_3_0
	end

	local var_3_14 = arg_3_7:getActiveTackleEntity()
	local var_3_15 = var_3_14:getTackle(var_3_10)
	local var_3_16 = var_3_14:getTackleBlock(var_3_10, var_3_11)
	local var_3_17 = true

	if var_3_16 then
		var_3_17 = arg_3_10 > var_3_16.barrierTime
	end

	if var_3_15 and not arg_3_0.hasBigHit then
		local var_3_18 = var_3_15:getFirstTackleBlock()

		ASSERT(var_3_18)

		arg_3_0.hasBigHit = var_3_18.blockType == native.ETackleBlockType.Ground
	end

	local var_3_19 = var_3_15 and var_3_15:getParticipantId(native.ETackleParticipantType.Tackler1)

	if var_3_19 and arg_3_7:getHoldTackleIntentPool():get(var_3_19):hasHoldTackleIntent(arg_3_10) then
		return arg_3_0
	end

	local var_3_20 = var_3_15 and var_3_15.offloadGuid

	if var_3_20 and var_3_20.valid then
		return arg_3_0
	end

	if var_3_15 and var_3_15:hasBlockType(native.ETackleBlockType.Break) then
		return arg_3_0
	end

	local var_3_21 = arg_3_6.pos
	local var_3_22 = math.abs(var_3_21.x) < rulesenvironment.halfFieldLength - playtheball_config.checkInsideFieldOffset
	local var_3_23 = arg_3_7:getPlayTheBallEntity().isQuickPlayTheBall and not arg_3_0.hasBigHit and var_3_17 and var_3_6.playTheBallBranchTime and var_3_9 and var_3_22

	if arg_3_7:getBallEntity():getOwnerId(arg_3_10) == arg_3_5 and var_3_23 and not arg_3_0.hasBranched then
		formatPrint("[TackledGetUpMonitorHuman:update] branching to play the ball (time is %.3f)", arg_3_10:ToSeconds())

		arg_3_0.hasBranched = playtheball_helper.BranchToPlayTheBall(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_10, arg_3_11, var_3_6)
	end

	return arg_3_0
end
