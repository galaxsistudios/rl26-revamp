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

-- Debug: append one line per AI play-the-ball decision to
-- reduce_scoots_debug.txt in the game folder. Turn off for release.
local DebugLog = true
local MechanicNames = {}

for iter_0_0, iter_0_1 in ipairs({ "None", "Scoot", "PassQuick", "PassFlat", "PassDeep", "PassBack", "Kick", "HitUp" }) do
	if native.CGameplayMechanic[iter_0_1] ~= nil then
		MechanicNames[native.CGameplayMechanic[iter_0_1]] = iter_0_1
	end
end

local function debugWrite(arg_0_0)
	if not DebugLog then
		return
	end

	pcall(function()
		local var_0_2 = io.open("reduce_scoots_debug.txt", "a")

		if var_0_2 then
			var_0_2:write(os.date("%H:%M:%S"), " ", arg_0_0, "\n")
			var_0_2:flush()
			var_0_2:close()
		end
	end)
end

-- Marker offset from the ball player along the attacking direction (+ = towards
-- the attacking side's own try line, i.e. onside side for defenders is negative).
local function markerInfo(arg_0_0, arg_0_1, arg_0_2, arg_0_3)
	if not arg_0_1 then
		return "-"
	end

	local var_0_4 = arg_0_2:getGameObject(arg_0_1, playertype.TypeId)

	if not var_0_4 then
		return tostring(arg_0_1) .. "@?"
	end

	local var_0_5 = arg_0_3:getPlayDir().x

	return string.format("%s@dx%.2f,dy%.2f", tostring(arg_0_1), (var_0_4.pos.x - arg_0_3.pos.x) * var_0_5, var_0_4.pos.y - arg_0_3.pos.y)
end

local function logDecision(arg_0_0, arg_0_1, arg_0_2, arg_0_3, arg_0_4, arg_0_5, arg_0_6, arg_0_7, arg_0_8)
	if not DebugLog then
		return
	end

	pcall(function()
		local var_0_9 = arg_0_1.knowledgeBank
		local var_0_10 = var_0_9.teamTackleMarkerKnowledge
		local var_0_11 = var_0_9.playerMechanicDecisionPool:get(arg_0_2).preferredMechanic

		debugWrite(string.format("PTB t=%.2f dh=%s side=%s tackle=%s pref=%s roll=%.2f mkr1=%s off1=%s mkr2=%s off2=%s branch=%s", arg_0_6, tostring(arg_0_2), tostring(arg_0_3.side), tostring(arg_0_4:getMatchProgressionEntity().tackleCount), MechanicNames[var_0_11] or tostring(var_0_11), arg_0_0.scootRoll or -1, markerInfo(arg_0_0, var_0_10.primaryId, arg_0_5, arg_0_3), tostring(var_0_10.primaryOffside), markerInfo(arg_0_0, var_0_10.secondaryId, arg_0_5, arg_0_3), tostring(var_0_10.secondaryOffside), arg_0_7))
	end)
end

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

			logDecision(arg_6_0, arg_6_2, arg_6_5, arg_6_6, arg_6_7, arg_6_8, arg_6_10, "ownforty-scoot")

			return arg_6_0
		end

		local var_6_5 = "stock"

		if var_6_2 and not var_6_3 and arg_6_0.scootRoll >= ScootChance then
			arg_6_0.passed = forceDummyHalfPass(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8, arg_6_9, arg_6_10, arg_6_11)

			if arg_6_0.passed then
				logDecision(arg_6_0, arg_6_2, arg_6_5, arg_6_6, arg_6_7, arg_6_8, arg_6_10, "veto-pass")

				return arg_6_0
			end

			var_6_5 = "veto-nopass"
		end

		arg_6_0.scooted = arg_6_0.scootMixin:update(arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8, arg_6_9, arg_6_10, arg_6_11, var_6_1)

		if not arg_6_0.scooted then
			local var_6_4 = {
				isDummyHalf = true
			}

			arg_6_0.passed = arg_6_0.passMixin:update(arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8, arg_6_9, arg_6_10, arg_6_11, var_6_4)
		end

		-- Only log once something happened, so a frame with no pass ready
		-- doesn't spam the file.
		if arg_6_0.scooted or arg_6_0.passed or not arg_6_0.loggedWait then
			logDecision(arg_6_0, arg_6_2, arg_6_5, arg_6_6, arg_6_7, arg_6_8, arg_6_10, var_6_5 .. (arg_6_0.scooted and "-scoot" or arg_6_0.passed and "-pass" or "-wait"))

			arg_6_0.loggedWait = true
		end
	end

	return arg_6_0
end
