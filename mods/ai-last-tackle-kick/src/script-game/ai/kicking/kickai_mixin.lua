import("ai.kicking.executekick")
import("ai.kicking.kicking_functions")
import("base.action.action")
import("base.action.action_request")
import("base.action.nilaction_request")
import("design.kicking_cconfig")
import("script-config.design.network_config")
import("script-config.rules.rules.rulesenvironment")

local var_0_0 = network_config.ActionLatency

-- ai-last-tackle-kick: debug log of every AI kick (with tackle count, field
-- position and the side's active play) to last_tackle_debug.txt in the game
-- folder; playtheball_ai.lua logs the last-tackle starts and handovers.
-- Turn off for release.
local DebugLog = true

local function debugKick(arg_0_0, arg_0_1, arg_0_2, arg_0_3)
	if not DebugLog then
		return
	end

	pcall(function()
		local var_0_5 = arg_0_1:getSide()
		local var_0_6 = arg_0_2:getMatchProgressionEntity()
		local var_0_7 = arg_0_3:getComponent("matchInData").matchType.maxTackleCount
		local var_0_8 = "?"

		pcall(function()
			var_0_8 = arg_0_2:getPlayEntityPair():get(var_0_5):getPlayName()
		end)

		local var_0_9 = arg_0_1:getPlayDir().x >= 0 and 1 or -1
		local var_0_10 = rulesenvironment.halfFieldLength + arg_0_1.pos.x * var_0_9
		local var_0_11 = io.open("last_tackle_debug.txt", "a")

		if var_0_11 then
			var_0_11:write(os.date("%H:%M:%S"), string.format(" KICK side=%s id=%s kick=%s tackle=%s/%s fromOwnLine=%.0f play=%s\n", tostring(var_0_5), tostring(arg_0_1.id), tostring(arg_0_0), tostring(var_0_6.tackleCount), tostring(var_0_7), var_0_10, tostring(var_0_8)))
			var_0_11:flush()
			var_0_11:close()
		end
	end)
end

Class("KickAiMixin", function(arg_1_0, arg_1_1)
	return
end)

function executeKickCallback(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5)
	local var_2_0 = arg_2_1.kickConfig

	ASSERT(var_2_0)
	arg_2_5:add(nilaction_request.createBlendRequest(arg_2_3, arg_2_2))
	ASSERT(arg_2_0.isBodyAction)

	local var_2_1 = not arg_2_0.isCommitted and var_2_0.bodyActionNameNonCommitted or var_2_0.bodyActionNameCommitted

	ASSERT(var_2_1)

	local var_2_2 = action.createAction(var_2_1, arg_2_0)

	arg_2_5:add(action_request.requestAction(arg_2_3, arg_2_2, arg_2_4:alloc(), var_2_2))
end

function KickAiMixin.onEnter(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10)
	arg_3_0.disposalId = arg_3_3:alloc()
	arg_3_0.kickExecuted = false
	arg_3_0.zeroTackleVetoLogged = false
end

function KickAiMixin.update(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7, arg_4_8, arg_4_9, arg_4_10, arg_4_11, arg_4_12)
	ASSERT(arg_4_12, "We need a params table, even if it's empty!")

	local var_4_0 = arg_4_2.knowledgeBank
	local var_4_1 = var_4_0.playerMechanicDecisionPool:get(arg_4_5)
	local var_4_2 = var_4_1.preferredMechanic == native.CGameplayMechanic.KickGrubber
	local var_4_3 = var_4_1.preferredMechanic == native.CGameplayMechanic.KickChip
	local var_4_4 = var_4_1.preferredMechanic == native.CGameplayMechanic.KickBomb
	local var_4_5 = var_4_1.preferredMechanic == native.CGameplayMechanic.KickPunt
	local var_4_6 = var_4_1.preferredMechanic == native.CGameplayMechanic.KickFortyTwenty
	local var_4_7 = var_4_1.preferredMechanic == native.CGameplayMechanic.KickTwentyForty
	local var_4_8 = var_4_1.preferredMechanic == native.CGameplayMechanic.KickFortyThirty
	local var_4_9 = var_4_1.preferredMechanic == native.CGameplayMechanic.KickTwentyFifty
	local var_4_10 = var_4_1.preferredMechanic == native.CGameplayMechanic.KickFieldGoal
	local var_4_11
	local var_4_12
	local var_4_13

	if var_4_2 then
		var_4_11 = "GrubberKick"
		var_4_13 = var_4_0.teamGrubberTargetKnowledgePair
	elseif var_4_3 then
		var_4_11 = "ChipKick"
		var_4_13 = var_4_0.teamChipTargetKnowledgePair
	elseif var_4_4 then
		var_4_11 = "BombKick"
		var_4_13 = var_4_0.teamBombTargetKnowledgePair
	elseif var_4_6 then
		var_4_11 = "FortyTwentyKick"
		var_4_13 = var_4_0.teamFortyTwentyTargetKnowledgePair
	elseif var_4_7 then
		var_4_11 = "FortyTwentyKick"
		var_4_13 = var_4_0.teamTwentyFortyTargetKnowledgePair
	elseif var_4_8 then
		var_4_11 = "FortyTwentyKick"
		var_4_13 = var_4_0.teamFortyThirtyTargetKnowledgePair
	elseif var_4_9 then
		var_4_11 = "FortyTwentyKick"
		var_4_13 = var_4_0.teamTwentyFiftyTargetKnowledgePair
	elseif var_4_5 then
		var_4_11 = "PuntKick"
		var_4_13 = var_4_0.teamPuntTargetKnowledgePair
	elseif var_4_10 then
		var_4_11 = "FieldGoalKickAi"
		var_4_13 = var_4_0.teamFieldGoalTargetKnowledgePair
	end

	local var_4_14 = arg_4_7:getBallEntity():getOwnerId(arg_4_10)

	-- ai-last-tackle-kick: no punts on tackle 0. Catching a kick still reads as the kicking side's last tackle,
	-- so the returner (usually the fullback) punted straight back. Skipping the kick leaves him to run it.
	if var_4_11 and (var_4_5 or var_4_6 or var_4_7 or var_4_8 or var_4_9) and arg_4_7:getMatchProgressionEntity().tackleCount == 0 then
		if not arg_4_0.zeroTackleVetoLogged then
			arg_4_0.zeroTackleVetoLogged = true

			debugKick(var_4_11 .. " VETOED (tackle 0)", arg_4_6, arg_4_7, arg_4_4)
		end

		var_4_11 = nil
	end

	if var_4_14 and var_4_14 == arg_4_5 and var_4_11 and not arg_4_0.kickExecuted then
		local var_4_15 = arg_4_0.disposalId

		ASSERT(var_4_15)

		local var_4_16 = var_4_0.playerKickCandidateKnowledgePool:get(arg_4_5)
		local var_4_17 = arg_4_6:getSide()
		local var_4_18 = var_4_13:get(var_4_17)
		local var_4_19
		local var_4_20

		if var_4_11 ~= "GrubberKick" and var_4_11 ~= "FieldGoalKickAi" then
			var_4_19 = var_4_18.targetPosition
			var_4_20 = native.dirlen2(var_4_19, arg_4_6.pos)
		elseif var_4_11 == "FieldGoalKickAi" then
			var_4_19 = var_4_18.targetPosition
			var_4_20 = native.dirlen2(var_4_19:tovec2(), arg_4_6.pos)
		else
			var_4_20 = var_4_18.targetDirection
			var_4_19 = arg_4_6.pos + var_4_20 * 8
		end

		local var_4_21 = kicking_functions.getKickActionParamtersAI(arg_4_6, arg_4_2, var_4_11, arg_4_10, var_0_0)
		local var_4_22 = kicking_cconfig[var_4_11]

		var_4_21.kickConfig = var_4_22
		var_4_21.configName = var_4_11
		var_4_21.executeKickCallback = executeKickCallback
		var_4_21.disposalId = var_4_15
		var_4_21.kickStartTime = arg_4_10 + var_0_0
		var_4_21.isCommitted = true

		if var_4_19 ~= native.vec2.Zero() and var_4_20 ~= native.vec2.Zero() then
			var_4_21.targetPos = type(var_4_19) == "vec2" and var_4_19:tovec3(0.1) or var_4_19
			var_4_21.kickDirection = var_4_20

			local var_4_23 = native.angle_signed2(arg_4_6.facing, var_4_21.kickDirection)

			var_4_21.angleFromFacing = var_4_23

			local var_4_24 = -var_4_22.kickAngleClamp
			local var_4_25 = var_4_22.kickAngleClamp

			var_4_21.power = 1

			if var_4_24 <= var_4_23 and var_4_23 <= var_4_25 then
				executekick.executeKick(arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7, arg_4_8, arg_4_9, arg_4_10, arg_4_11, var_4_21)

				arg_4_0.kickExecuted = true

				debugKick(var_4_11, arg_4_6, arg_4_7, arg_4_4)

				local var_4_26 = action.createAction("PrepareKickAction", {})

				arg_4_11:add(action_request.requestBlendAction(arg_4_7, arg_4_5, arg_4_3:alloc(), var_4_26))
			end
		end
	end
end
