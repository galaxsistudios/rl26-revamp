import("ai.collect.collect_mixin")
import("ai.collect.collecttransitionblend_mixin")
import("ai.collect.collectanticipate_mixin")
import("ai.collect.collectapproach_mixin")
import("ai.passing.executepass")
import("ai.passing.passai_mixin")
import("ai.playtheball.dummyhalfmovement_mixin")
import("base.controller.controller")
import("design.passing_cconfig")
import("game.player.playertype")
import("script-config.design.network_config")

local var_0_0 = controller.Controller
local var_0_1 = network_config.ActionLatency

-- reduce-ai-dummy-half-scoots: this is the controller the AI dummy half
-- normally runs while picking up the ball. No pass receivers exist yet, and the
-- AI may only decide to scoot once he holds the ball, at which point
-- master_flowchart_ai.flow sends him to HitGapAi (the scoot run). So this file
-- only records the pickup (who, when, one dice roll); hitgap_ai.lua makes the
-- scoot/pass decision when the run would start.

-- Dummy halves picking up the ball, by player id -> { expires = sim time,
-- roll = 0..1 }. Read (and cleared) by HitGapAi.onEnter.
DummyHalfPickups = {}
PickupWindow = 3
-- Loose ball further than this (m) from the dummy half: he sprints to it.
ChaseBallDistance = 1.2

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

-- Debug: one line per AI play-the-ball to reduce_scoots_debug.txt in the game
-- folder. Turn off for release.
local DebugLog = true

local function debugWrite(arg_0_0)
	if not DebugLog then
		return
	end

	pcall(function()
		local var_0_1 = io.open("reduce_scoots_debug.txt", "a")

		if var_0_1 then
			var_0_1:write(os.date("%H:%M:%S"), " ", arg_0_0, "\n")
			var_0_1:flush()
			var_0_1:close()
		end
	end)
end

-- Marker offset from the dummy half along the attacking direction, plus how
-- far he still is from his own marker spot (spot=) and his offside flag.
local function markerInfo(arg_0_0, arg_0_1, arg_0_2, arg_0_3)
	if not arg_0_0 then
		return "-"
	end

	local var_0_4 = arg_0_1:getGameObject(arg_0_0, playertype.TypeId)

	if not var_0_4 then
		return tostring(arg_0_0) .. "@?"
	end

	local var_0_5 = "?"

	pcall(function()
		local var_0_6 = arg_0_3.knowledgeBank.playerTackleMarkerKnowledgePool:get(arg_0_0).markerPosition
		local var_0_7 = arg_0_2:getPlayDir().x

		var_0_5 = string.format("%.2f(dx%.2f,dy%.2f)", native.length2(var_0_4.pos - var_0_6), (var_0_4.pos.x - var_0_6.x) * var_0_7, var_0_4.pos.y - var_0_6.y)
	end)

	return string.format("%s@dx%.2f,dy%.2f,spot=%s,flag=%s", tostring(arg_0_0), (var_0_4.pos.x - arg_0_2.pos.x) * arg_0_2:getPlayDir().x, var_0_4.pos.y - arg_0_2.pos.y, var_0_5, tostring(var_0_4.offsideInfo.flaggedOffside))
end

local function logDecision(arg_0_0, arg_0_1, arg_0_2, arg_0_3, arg_0_4, arg_0_5, arg_0_6, arg_0_7)
	if not DebugLog then
		return
	end

	local var_0_9, var_0_10 = pcall(function()
		local var_0_8 = arg_0_1.knowledgeBank.teamTackleMarkerKnowledge

		debugWrite(string.format("PTB t=%s dh=%s side=%s tackle=%s roll=%s mkr1=%s off1=%s mkr2=%s off2=%s branch=%s", tostring(arg_0_6), tostring(arg_0_2), tostring(arg_0_3.side), tostring(arg_0_4:getMatchProgressionEntity().tackleCount), tostring(arg_0_0.scootRoll), markerInfo(var_0_8.primaryId, arg_0_5, arg_0_3, arg_0_1), tostring(var_0_8.primaryOffside), markerInfo(var_0_8.secondaryId, arg_0_5, arg_0_3, arg_0_1), tostring(var_0_8.secondaryOffside), arg_0_7))
	end)

	if not var_0_9 then
		debugWrite("PTB log error (" .. tostring(arg_0_7) .. "): " .. tostring(var_0_10))
	end
end

-- Same as PassAiMixin.update, but with the mechanic chosen here instead of
-- the decision tree (which still says Scoot).
-- arg_0_12 (optional): +1/-1 to only pass to a receiver on that side of the
-- passer (field y). arg_0_13: true while running (uses the open-play pass
-- configs instead of the dummy-half pick-up ones).
function ForceDummyHalfPass(arg_0_0, arg_0_1, arg_0_2, arg_0_3, arg_0_4, arg_0_5, arg_0_6, arg_0_7, arg_0_8, arg_0_9, arg_0_10, arg_0_11, arg_0_12, arg_0_13)
	local var_0_12 = arg_0_2.knowledgeBank.playerPassCandidateKnowledgePool:get(arg_0_5)

	for iter_0_0, iter_0_1 in ipairs(FallbackPasses) do
		local var_0_13 = var_0_12:getTargetPassCandidate(iter_0_1.mechanic)
		local var_0_18 = arg_0_13 and iter_0_1.configName:gsub("^DummyHalf", "") or iter_0_1.configName
		local var_0_14 = passing_cconfig[var_0_18]
		local var_0_15 = var_0_13 and var_0_13 ~= arg_0_5 and arg_0_8:getGameObject(var_0_13, playertype.TypeId)

		if var_0_15 and arg_0_12 and (var_0_15.pos.y - arg_0_6.pos.y) * arg_0_12 <= 0 then
			var_0_15 = nil
		end

		if var_0_14 and var_0_15 then
			local var_0_16 = native.dirlen2(var_0_15.pos, arg_0_6.pos)
			local var_0_17 = native.dot2(var_0_16, native.vec2.YAxis()) > 0 and native.vec2.YAxis() or native.vec2.NegYAxis()

			executepass.executePass(arg_0_1, arg_0_2, arg_0_3, arg_0_4, arg_0_5, arg_0_6, arg_0_7, arg_0_8, arg_0_9, arg_0_10, arg_0_11, {
				passConfig = var_0_14,
				configName = var_0_18,
				targetId = var_0_13,
				passDirection = var_0_17,
				executePassCallback = passai_mixin.executePassCallback,
				disposalId = arg_0_0.passMixin.disposalId,
				passStartTime = arg_0_10 + var_0_1
			})

			arg_0_0.passMixin.passExecuted = true

			return true
		end
	end

	return false
end

controller.controllerclass("DummyHalfCollectBallAi", var_0_0, function(arg_1_0)
	var_0_0.init(arg_1_0)

	arg_1_0.passMixin = passai_mixin.PassAiMixin()
	arg_1_0.collectMixin = collect_mixin.CollectMixin()
	arg_1_0.collectTransitionBlendMixin = collecttransitionblend_mixin.CollectTransitionBlendMixin()
	arg_1_0.collectAnticipateMixin = collectanticipate_mixin.CollectAnticipateMixin()
	arg_1_0.collectApproachMixin = collectapproach_mixin.CollectApproachMixin()
	arg_1_0.dummyHalfMovementMixin = dummyhalfmovement_mixin.DummyHalfMovementMixin()
end)

function DummyHalfCollectBallAi.onEnter(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	arg_2_0.passMixin:onEnter(arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	arg_2_0.collectMixin:onEnter(arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	arg_2_0.collectTransitionBlendMixin:onEnter(arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	arg_2_0.collectAnticipateMixin:onEnter(arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	arg_2_0.collectApproachMixin:onEnter(arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	arg_2_0.dummyHalfMovementMixin:onEnter(arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)

	-- One roll per play-the-ball, so the veto can't be re-rolled every frame.
	arg_2_0.scootRoll = native.Random(native.Random.FromSystemTime():nextAsSeed()):randomFloatRange(0, 1)
	arg_2_0.enterLogged = false
	arg_2_0.chaseLogged = false

	DummyHalfPickups[arg_2_5] = {
		expires = arg_2_9 + PickupWindow,
		roll = arg_2_0.scootRoll
	}
end

function DummyHalfCollectBallAi.update(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	local var_3_0 = {}

	if DebugLog and not arg_3_0.enterLogged then
		arg_3_0.enterLogged = true

		logDecision(arg_3_0, arg_3_2, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_10, "pickup")
	end

	arg_3_0.passMixin:update(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11, var_3_0)
	arg_3_0.collectMixin:update(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	arg_3_0.collectTransitionBlendMixin:update(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	arg_3_0.collectAnticipateMixin:update(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	arg_3_0.collectApproachMixin:update(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	arg_3_0.dummyHalfMovementMixin:update(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)

	-- Loose ball away from him (rolled past, or played before he got there): go and get it at
	-- full speed instead of the stock jog/strafe, so the markers can't beat him to it.
	pcall(function()
		if arg_3_7:getBallEntity():getOwnerId(arg_3_10) then
			return
		end

		local var_3_20 = arg_3_8:getBallObject().pos2
		local var_3_21 = native.length2(var_3_20 - arg_3_6.pos)

		if var_3_21 > ChaseBallDistance then
			local var_3_22 = arg_3_6:getDerivedAttribute("max_speed")

			arg_3_6:setMovementSpeed(var_3_22, var_3_22)

			if not arg_3_0.chaseLogged then
				arg_3_0.chaseLogged = true

				debugWrite(string.format("CHASE dh=%s ball %.2f m away -> full speed", tostring(arg_3_5), var_3_21))
			end
		end
	end)

	return arg_3_0
end
