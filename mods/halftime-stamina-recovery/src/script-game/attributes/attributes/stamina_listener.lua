import("core.foundation.func")
import("design.player_attribute_modifiers_cconfig")
import("game.player.playertype")

local var_0_0 = player_attribute_modifiers_cconfig.cPlayerAttributeModifiersConfig.staminaConfig

Class("StaminaListener", function(arg_1_0, arg_1_1)
	return
end)

function StaminaListener.registerWithMatchSim(arg_2_0, arg_2_1)
	arg_2_1:registerSolidEventListener(func.bindmethod(arg_2_0, arg_2_0.onTackleCompletedEvent), "TackleCompletedEvent")
	arg_2_1:registerSolidEventListener(func.bindmethod(arg_2_0, arg_2_0.onFendEvent), "FendEvent")
	arg_2_1:registerSolidEventListener(func.bindmethod(arg_2_0, arg_2_0.onSideStepEvent), "SideStepEvent")
	arg_2_1:registerSolidEventListener(func.bindmethod(arg_2_0, arg_2_0.onBreakTackleEvent), "BreakTackleEvent")
	arg_2_1:registerSolidEventListener(func.bindmethod(arg_2_0, arg_2_0.onBigHit), "BigHitEvent")
	arg_2_1:registerSolidEventListener(func.bindmethod(arg_2_0, arg_2_0.onHitUp), "HitUpKnockBackEvent")
	arg_2_1:registerSolidEventListener(func.bindmethod(arg_2_0, arg_2_0.onTimePeriodExpiredEvent), "TimePeriodExpiredCutsceneEvent")
end

function getStaminaModifierFromMatchTimeModifier(arg_3_0)
	local var_3_0 = arg_3_0:getMatchTimeEntity()

	ASSERT(var_3_0)

	return var_3_0.timeModifier / 8
end

function getDifficultyRegenDrainModifier(arg_4_0, arg_4_1, arg_4_2)
	local var_4_0 = arg_4_0.difficulty
	local var_4_1 = arg_4_2.party:getPrimaryPartyMember()
	local var_4_2 = arg_4_0.matchInData.difficultyIndex

	formatPrint("[CustomSliders] match.difficulty = %s", tostring(arg_4_0.difficulty))
	formatPrint("[CustomSliders] difficulty = %s", tostring(arg_4_0.matchInData.difficulty))

	if var_4_0 == native.EDifficulty.Custom then
		local var_4_3 = arg_4_0.matchInProgressData.gameplayModifiers
		local var_4_4 = var_4_3.staminaRegenSpeedCustom or 1
		local var_4_5 = var_4_3.staminaDrainSpeedCustom or 1

		return arg_4_1 and var_4_4 or var_4_5
	else
		return 1
	end
end

function StaminaListener.onTackleCompletedEvent(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7, arg_5_8, arg_5_9)
	local var_5_0 = getStaminaModifierFromMatchTimeModifier(arg_5_7)

	ASSERT(var_5_0)

	local var_5_1 = getDifficultyRegenDrainModifier(arg_5_6, false, arg_5_4)
	local var_5_2 = arg_5_1.maker
	local var_5_3 = arg_5_7:getActiveTackleEntity():getTackleForTackleeId(var_5_2)

	if var_5_3 then
		local var_5_4 = var_5_3:hasBlockType(native.ETackleBlockType.Drag) and var_0_0.staminaLossDrag or 0
		local var_5_5 = var_5_3:hasBlockType(native.ETackleBlockType.Drive) and var_0_0.staminaLossDrive or 0
		local var_5_6 = arg_5_8:getGameObject(var_5_2)

		ASSERT(var_5_6)

		local var_5_7 = var_5_6 and var_5_6:getDerivedAttribute("staminaLossDifficultyModifier") or 1
		local var_5_8 = (var_0_0.staminaLossTackleCompleteBC + var_5_4) * 0.01 * var_5_0 * var_5_7 * var_5_1
		local var_5_9 = arg_5_4.pools.staminaInfoPool
		local var_5_10 = var_5_9:get(var_5_2)
		local var_5_11 = var_5_10.stamina

		formatPrint("[Stamina] BC Tackle: current: %.2f loss: %.2f", var_5_11, var_5_8)

		var_5_10.stamina = var_5_11 - var_5_8

		local var_5_12 = var_5_3:getParticipantId(native.ETackleParticipantType.Tackler1)

		if var_5_12 then
			local var_5_13 = arg_5_8:getGameObject(var_5_12)

			ASSERT(var_5_13)

			local var_5_14 = var_5_13 and var_5_13:getDerivedAttribute("staminaLossDifficultyModifier") or 1
			local var_5_15 = (var_0_0.staminaLossTackleCompleteT1 + var_5_5) * 0.01 * var_5_0 * var_5_14 * var_5_1
			local var_5_16 = var_5_9:get(var_5_12)
			local var_5_17 = var_5_16.stamina

			formatPrint("[Stamina] T1 Tackle: current: %.2f loss: %.2f", var_5_17, var_5_15)

			var_5_16.stamina = var_5_17 - var_5_15
		end

		local var_5_18 = var_5_3:getParticipantId(native.ETackleParticipantType.Tackler2)

		if var_5_18 then
			local var_5_19 = arg_5_8:getGameObject(var_5_18)

			ASSERT(var_5_19)

			local var_5_20 = var_5_19 and var_5_19:getDerivedAttribute("staminaLossDifficultyModifier") or 1
			local var_5_21 = var_0_0.staminaLossTackleComplete * 0.01 * var_5_0 * var_5_20 * var_5_1
			local var_5_22 = var_5_9:get(var_5_18)
			local var_5_23 = var_5_22.stamina

			formatPrint("[Stamina] T2 Tackle: current: %.2f loss: %.2f", var_5_23, var_5_21)

			var_5_22.stamina = var_5_23 - var_5_21
		end

		local var_5_24 = var_5_3:getParticipantId(native.ETackleParticipantType.Tackler3)

		if var_5_24 then
			local var_5_25 = arg_5_8:getGameObject(var_5_24)

			ASSERT(var_5_25)

			local var_5_26 = var_5_25 and var_5_25:getDerivedAttribute("staminaLossDifficultyModifier") or 1
			local var_5_27 = var_0_0.staminaLossTackleComplete * 0.01 * var_5_0 * var_5_26 * var_5_1
			local var_5_28 = var_5_9:get(var_5_24)
			local var_5_29 = var_5_28.stamina

			formatPrint("[Stamina] T3 Tackle: current: %.2f loss: %.2f", var_5_11, var_5_8)

			var_5_28.stamina = var_5_29 - var_5_27
		end
	end
end

function StaminaListener.onFendEvent(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8, arg_6_9)
	local var_6_0 = getStaminaModifierFromMatchTimeModifier(arg_6_7)

	ASSERT(var_6_0)

	local var_6_1 = getDifficultyRegenDrainModifier(arg_6_6, false, arg_6_4)
	local var_6_2 = arg_6_1.maker
	local var_6_3 = arg_6_8:getGameObject(var_6_2)

	ASSERT(var_6_3)

	local var_6_4 = var_6_3 and var_6_3:getDerivedAttribute("staminaLossDifficultyModifier") or 1
	local var_6_5 = var_0_0.staminaLossFend * 0.01 * var_6_0 * var_6_4 * var_6_1
	local var_6_6 = arg_6_4.pools.staminaInfoPool:get(var_6_2)
	local var_6_7 = var_6_6.stamina

	formatPrint("[Stamina] BC Fend: current: %.2f loss: %.2f", var_6_7, var_6_5)

	var_6_6.stamina = var_6_7 - var_6_5
end

function StaminaListener.onSideStepEvent(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7, arg_7_8, arg_7_9)
	local var_7_0 = getStaminaModifierFromMatchTimeModifier(arg_7_7)
	local var_7_1 = getDifficultyRegenDrainModifier(arg_7_6, false, arg_7_4)
	local var_7_2 = arg_7_1.maker
	local var_7_3 = arg_7_8:getGameObject(var_7_2)

	ASSERT(var_7_3)

	local var_7_4 = var_7_3 and var_7_3:getDerivedAttribute("staminaLossDifficultyModifier") or 1
	local var_7_5 = var_0_0.staminaLossEvade * 0.01 * var_7_0 * var_7_4 * var_7_1
	local var_7_6 = arg_7_4.pools.staminaInfoPool:get(var_7_2)
	local var_7_7 = var_7_6.stamina

	formatPrint("[Stamina] BC Evade: current: %.2f loss: %.2f", var_7_7, var_7_5)

	var_7_6.stamina = var_7_7 - var_7_5
end

function StaminaListener.onBreakTackleEvent(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5, arg_8_6, arg_8_7, arg_8_8, arg_8_9)
	local var_8_0 = getStaminaModifierFromMatchTimeModifier(arg_8_7)

	ASSERT(var_8_0)

	local var_8_1 = getDifficultyRegenDrainModifier(arg_8_6, false, arg_8_4)
	local var_8_2 = arg_8_1.maker
	local var_8_3 = arg_8_8:getGameObject(var_8_2)

	ASSERT(var_8_3)

	local var_8_4 = var_8_3 and var_8_3:getDerivedAttribute("staminaLossDifficultyModifier") or 1
	local var_8_5 = var_0_0.staminaLossBreakTackleBC * 0.01 * var_8_0 * var_8_4 * var_8_1
	local var_8_6 = arg_8_4.pools.staminaInfoPool:get(var_8_2)
	local var_8_7 = var_8_6.stamina

	formatPrint("[Stamina] BC Break: current: %.2f loss: %.2f", var_8_7, var_8_5)

	var_8_6.stamina = var_8_7 - var_8_5
end

function StaminaListener.onBigHit(arg_9_0, arg_9_1, arg_9_2, arg_9_3, arg_9_4, arg_9_5, arg_9_6, arg_9_7, arg_9_8, arg_9_9)
	local var_9_0 = getStaminaModifierFromMatchTimeModifier(arg_9_7)

	ASSERT(var_9_0)

	local var_9_1 = getDifficultyRegenDrainModifier(arg_9_6, false, arg_9_4)
	local var_9_2 = arg_9_1.maker
	local var_9_3 = arg_9_8:getGameObject(var_9_2)

	ASSERT(var_9_3)

	local var_9_4 = var_9_3 and var_9_3:getDerivedAttribute("staminaLossDifficultyModifier") or 1
	local var_9_5 = var_0_0.staminaLossBigHit * 0.01 * var_9_0 * var_9_4 * var_9_1
	local var_9_6 = arg_9_4.pools.staminaInfoPool:get(var_9_2)
	local var_9_7 = var_9_6.stamina

	formatPrint("[Stamina] Big Hit: current: %.2f loss: %.2f", var_9_7, var_9_5)

	var_9_6.stamina = var_9_7 - var_9_5
end

function StaminaListener.onHitUp(arg_10_0, arg_10_1, arg_10_2, arg_10_3, arg_10_4, arg_10_5, arg_10_6, arg_10_7, arg_10_8, arg_10_9)
	local var_10_0 = getStaminaModifierFromMatchTimeModifier(arg_10_7)

	ASSERT(var_10_0)

	local var_10_1 = getDifficultyRegenDrainModifier(arg_10_6, false, arg_10_4)
	local var_10_2 = arg_10_1.maker
	local var_10_3 = arg_10_8:getGameObject(var_10_2)

	ASSERT(var_10_3)

	local var_10_4 = var_10_3 and var_10_3:getDerivedAttribute("staminaLossDifficultyModifier") or 1
	local var_10_5 = var_0_0.staminaLossHitUp * 0.01 * var_10_0 * var_10_4 * var_10_1
	local var_10_6 = arg_10_4.pools.staminaInfoPool:get(var_10_2)
	local var_10_7 = var_10_6.stamina

	formatPrint("[Stamina] Hit Up: current: %.2f loss: %.2f", var_10_7, var_10_5)

	var_10_6.stamina = var_10_7 - var_10_5
end

function StaminaListener.onTimePeriodExpiredEvent(arg_11_0, arg_11_1, arg_11_2, arg_11_3, arg_11_4, arg_11_5, arg_11_6, arg_11_7, arg_11_8, arg_11_9)
	local var_11_0 = arg_11_7:getGamerSideEntity()
	local var_11_1 = arg_11_4.pools.staminaInfoPool
	local var_11_2 = arg_11_6:getComponent("matchInfo"):getDifficultyLevel():toIndex()

	if not arg_11_1.matchCompleted then
		-- halftime-stamina-recovery: stock adds maxStamina * halfTimeStaminaGain
		-- (0.3-0.7 by difficulty, 0.5 default) to everyone, which refills almost
		-- every player. Instead a player gets back a share of the stamina he is
		-- missing, set by his fitness. Difficulty no longer scales it (the 0.7
		-- entry multiplied every share by 1.4 and refilled everyone again).
		local var_11_8 = 1
		local var_11_9, var_11_10 = FitnessRangeLow, FitnessRangeHigh

		for iter_11_0, iter_11_1 in arg_11_8:objects(playertype.TypeId) do
			local var_11_4 = iter_11_1:getDerivedAttribute("maxStamina")
			local var_11_6 = var_11_1:get(iter_11_0)
			local var_11_11 = var_11_6.stamina
			local var_11_12 = native.clamp1((getFitnessFromPeakStamina(var_11_4, getPeakStaminaRange()) - var_11_9) / (var_11_10 - var_11_9), 0, 1)
			local var_11_13 = native.clamp1((RecoveryShareLow + (RecoveryShareHigh - RecoveryShareLow) * var_11_12) * var_11_8, 0, 1)
			local var_11_7 = var_11_11 + (var_11_4 - var_11_11) * var_11_13

			var_11_6.stamina = native.clamp1(var_11_7, 0, var_11_4)

			if DebugLog then
				pcall(function()
					local var_11_14 = iter_11_1.identity and iter_11_1.identity.fullName or tostring(iter_11_0)

					debugWrite(string.format("side %s %-24s max %.3f fit(scaled) %.2f  %3.0f%% -> %3.0f%% (share %.2f)", tostring(iter_11_1.side), var_11_14, var_11_4, var_11_12, var_11_11 / var_11_4 * 100, var_11_6.stamina / var_11_4 * 100, var_11_13))
				end)
			end
		end
	end
end

-- ---------------------------------------------------------------------------
-- halftime-stamina-recovery
-- ---------------------------------------------------------------------------

-- Share of a player's missing stamina restored at half time, for the least
-- (fitness 0) and most (fitness 1) fit player, at the default difficulty.
-- Example at 60%: fitness 0 -> 70%, fitness 0.5 -> 78%, fitness 1 -> 86%.
RecoveryShareLow = 0.25
RecoveryShareHigh = 0.65

-- Raw fitness (from peak stamina) of real squads only spans about 0.6-0.9
-- (logged 2026-10-25), so this range is stretched to 0..1 before the shares
-- above are applied.
FitnessRangeLow = 0.6
FitnessRangeHigh = 0.95

-- Debug: one line per player at each break to halftime_stamina_debug.txt in
-- the game folder. Turn off for release.
DebugLog = true

function debugWrite(arg_12_0)
	pcall(function()
		local var_12_0 = io.open("halftime_stamina_debug.txt", "a")

		if var_12_0 then
			var_12_0:write(os.date("%H:%M:%S"), " ", arg_12_0, "\n")
			var_12_0:flush()
			var_12_0:close()
		end
	end)
end

-- maxStamina is the native peak stamina: peakStaminaMinFitness..MaxFitness
-- (0.7..1.0) by the player's fitness (his Stamina attribute), plus perks.
function getPeakStaminaRange()
	local var_13_0, var_13_1, var_13_2 = pcall(function()
		return var_0_0.peakStaminaMinFitness, var_0_0.peakStaminaMaxFitness
	end)

	if not var_13_0 or type(var_13_1) ~= "number" or type(var_13_2) ~= "number" or var_13_2 <= var_13_1 then
		return 0.7, 1
	end

	return var_13_1, var_13_2
end

function getFitnessFromPeakStamina(arg_14_0, arg_14_1, arg_14_2)
	return native.clamp1((arg_14_0 - arg_14_1) / (arg_14_2 - arg_14_1), 0, 1)
end
