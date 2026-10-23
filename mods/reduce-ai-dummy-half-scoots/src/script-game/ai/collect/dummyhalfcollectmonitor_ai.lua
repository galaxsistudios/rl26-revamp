import("ai.kicking.inplaykickentity_request")
import("ai.passing.executepass")
import("ai.passing.passai_mixin")
import("ai.scoot.scoot_helper")
import("ai.scoot.scootai_mixin")
import("base.controller.controller")
import("design.passing_cconfig")
import("game.player.playertype")
import("script-config.design.network_config")
import("script-config.rules.rules.rulesenvironment")

local var_0_0 = network_config.ActionLatency
local var_0_1 = controller.Controller

-- Chance (0..1) that an AI dummy half actually scoots when the decision tree
-- asks for it. Stock is effectively 1.0: decisiontree_ai.flow picks Scoot
-- whenever a marker is offside (not square), ahead of every dummy-half pass.
local ScootChance = 0.1

-- Chance (0..1) that a winger or centre at dummy half scoots out of their own
-- end, markers square or not. Stock AI never does this.
local OwnFortyScootChance = 0.25
local OwnFortyDistance = 40
local OwnFortyMaxTackleCount = 3

-- Passes tried, in order, when a scoot is vetoed.
local FallbackPasses = {
	{
		mechanic = native.CGameplayMechanic.PassQuick,
		configName = "DummyHalfQuickPass"
	},
	{
		mechanic = native.CGameplayMechanic.PassFlat,
		configName = "DummyHalfFlatPass"
	},
	{
		mechanic = native.CGameplayMechanic.PassDeep,
		configName = "DummyHalfDeepPass"
	}
}

controller.controllerclass("DummyHalfCollectMonitorAi", var_0_1, function(arg_1_0)
	var_0_1.init(arg_1_0)

	arg_1_0.passMixin = passai_mixin.PassAiMixin()
	arg_1_0.scootMixin = scootai_mixin.ScootAiMixin()
end)

function DummyHalfCollectMonitorAi.onEnter(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	arg_2_0.passMixin:onEnter(arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	arg_2_10:add(inplaykickentity_request.InPlayKickEntityResetKickedThisTackleRequest())

	-- One roll per play-the-ball, so the veto can't be re-rolled every frame.
	local var_2_0 = native.Random(native.Random.FromSystemTime():nextAsSeed())

	arg_2_0.scootRoll = var_2_0:randomFloatRange(0, 1)
end

-- Winger or centre at dummy half, within OwnFortyDistance of their own try
-- line, early in the set.
local function isOutsideBackInOwnForty(arg_3_0, arg_3_1, arg_3_2, arg_3_3)
	local var_3_0 = arg_3_0.knowledgeBank.playerRoleInfoPool:get(arg_3_1).assignedRole
	local var_3_1 = native.EAssignedRole

	if var_3_0 ~= var_3_1.WingerLeft and var_3_0 ~= var_3_1.WingerRight and var_3_0 ~= var_3_1.CentreLeft and var_3_0 ~= var_3_1.CentreRight then
		return false
	end

	local var_3_2 = rulesenvironment.halfFieldLength + arg_3_2.pos.x * arg_3_2:getPlayDir().x

	if var_3_2 > OwnFortyDistance then
		return false
	end

	return arg_3_3:getMatchProgressionEntity().tackleCount <= OwnFortyMaxTackleCount
end

-- Scoot towards the gap, as ScootAiMixin does when no marker is offside.
local function forceDummyHalfScoot(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7, arg_4_8, arg_4_9, arg_4_10, arg_4_11, arg_4_12)
	local var_4_0 = arg_4_2.knowledgeBank.playerGapKnowledgePool:get(arg_4_5).gapPosition.y
	local var_4_1 = arg_4_6.pos.y
	local var_4_2

	if arg_4_6:getPlayDir().x > 0 then
		var_4_2 = var_4_1 < var_4_0 and "right" or "left"
	else
		var_4_2 = var_4_1 < var_4_0 and "left" or "right"
	end

	scoot_helper.executeScoot(arg_4_12, var_4_2, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7, arg_4_8, arg_4_10, arg_4_11)

	return true
end

-- Same as PassAiMixin.update, but with the mechanic chosen here instead of
-- the decision tree (which still says Scoot).
local function forceDummyHalfPass(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7, arg_5_8, arg_5_9, arg_5_10, arg_5_11)
	local var_5_0 = arg_5_2.knowledgeBank.playerPassCandidateKnowledgePool:get(arg_5_5)

	for iter_5_0, iter_5_1 in ipairs(FallbackPasses) do
		local var_5_1 = var_5_0:getTargetPassCandidate(iter_5_1.mechanic)
		local var_5_2 = passing_cconfig[iter_5_1.configName]
		local var_5_3 = var_5_1 and var_5_1 ~= arg_5_5 and arg_5_8:getGameObject(var_5_1, playertype.TypeId)

		if var_5_2 and var_5_3 then
			local var_5_4 = native.dirlen2(var_5_3.pos, arg_5_6.pos)
			local var_5_5 = native.dot2(var_5_4, native.vec2.YAxis()) > 0 and native.vec2.YAxis() or native.vec2.NegYAxis()

			executepass.executePass(arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7, arg_5_8, arg_5_9, arg_5_10, arg_5_11, {
				passConfig = var_5_2,
				configName = iter_5_1.configName,
				targetId = var_5_1,
				passDirection = var_5_5,
				executePassCallback = passai_mixin.executePassCallback,
				disposalId = arg_5_0.passMixin.disposalId,
				passStartTime = arg_5_10 + var_0_0
			})

			arg_5_0.passMixin.passExecuted = true

			return true
		end
	end

	return false
end

function DummyHalfCollectMonitorAi.update(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8, arg_6_9, arg_6_10, arg_6_11)
	local var_6_0 = arg_6_6:getAction(arg_6_7)

	if var_6_0 and var_6_0.IsCollect and var_6_0:hasCollected(arg_6_10 + var_0_0) and not arg_6_0.passed and not arg_6_0.scooted then
		local var_6_1 = scoot_helper.getScootFoot(var_6_0, arg_6_2)
		local var_6_2 = arg_6_2.knowledgeBank.playerMechanicDecisionPool:get(arg_6_5).preferredMechanic == native.CGameplayMechanic.Scoot
		local var_6_3 = arg_6_0.scootRoll < OwnFortyScootChance and isOutsideBackInOwnForty(arg_6_2, arg_6_5, arg_6_6, arg_6_7)

		if var_6_3 and not var_6_2 then
			arg_6_0.scooted = forceDummyHalfScoot(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8, arg_6_9, arg_6_10, arg_6_11, var_6_1)

			return arg_6_0
		end

		if var_6_2 and not var_6_3 and arg_6_0.scootRoll >= ScootChance then
			arg_6_0.passed = forceDummyHalfPass(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8, arg_6_9, arg_6_10, arg_6_11)

			if arg_6_0.passed then
				return arg_6_0
			end
		end

		arg_6_0.scooted = arg_6_0.scootMixin:update(arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8, arg_6_9, arg_6_10, arg_6_11, var_6_1)

		if not arg_6_0.scooted then
			local var_6_4 = {
				isDummyHalf = true
			}

			arg_6_0.passed = arg_6_0.passMixin:update(arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8, arg_6_9, arg_6_10, arg_6_11, var_6_4)
		end
	end

	return arg_6_0
end
