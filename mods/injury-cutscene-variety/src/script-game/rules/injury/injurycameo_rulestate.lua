import("ai.substitutions.substitution_request")
import("base.rulestate.rulestateclass")
import("core.marshalling.types")
import("game.humanoid.humanoidtype")
import("game.cutscenes.cutsceneplayevent_request")

local var_0_0 = native.EInjuryRegion
local var_0_1 = {
	[var_0_0.Arm] = {
		"InjuryArm_01"
	},
	[var_0_0.LowerLeg] = {
		"InjuryAnkle_01"
	},
	[var_0_0.UpperLeg] = {
		"InjuryKnee_01",
		"InjuryHamstring_01"
	},
	[var_0_0.Back] = {
		"InjuryBack_01"
	},
	[var_0_0.Head] = {
		"InjuryHead_01",
		"InjuryConcussion_01"
	},
	[var_0_0.Torso] = {
		"InjuryTorso_01"
	}
}

rulestateclass.rulestateclass("InjuryCameoRuleState", function(arg_1_0, arg_1_1)
	for iter_1_0, iter_1_1 in pairs(InjuryCameoRuleState.MemberDefinitions) do
		arg_1_0[iter_1_0] = arg_1_1[iter_1_0]
	end
end).MemberDefinitions = {
	nextState = types.RuleState,
	injuredId = types.ObjectId,
	guid = types.Guid
}
InjuryCameoRuleState.HidePlayerMarkers = true
InjuryCameoRuleState.HideBallMarkers = true

function InjuryCameoRuleState.onEnterSolid(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	local var_2_0 = arg_2_3.hud and arg_2_3.hud.featureStack

	if var_2_0 then
		var_2_0:push("cutscene")
	end
end

function InjuryCameoRuleState.onExitSolid(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10)
	local var_3_0 = arg_3_3.hud and arg_3_3.hud.featureStack

	if var_3_0 then
		var_3_0:pop("cutscene")
	end
end

function InjuryCameoRuleState.updateSolid(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7, arg_4_8, arg_4_9, arg_4_10, arg_4_11)
	if arg_4_0.haveSentRulestateRequest then
		return
	end

	if not VERIFY(arg_4_3.network):isMaster() then
		return
	end

	local var_4_0 = arg_4_0.injuredId

	if not arg_4_6:getActiveTackleEntity():getTackleForId(var_4_0) then
		arg_4_0.haveSentRulestateRequest = true

		local var_4_1, var_4_2, var_4_3 = arg_4_6:getOfficialEntity():getRefereesIds()
		local var_4_4 = {
			var_4_0,
			var_4_1
		}
		local var_4_5 = arg_4_6:getInjuryPool():get(var_4_0)
		local var_4_6 = native.CInjury.getRegion(var_4_5.injuryType)
		-- injury-cutscene-variety: a random scene for the region (stock always took the first)
		local var_4_r = var_0_1[var_4_6]
		local var_4_7 = var_4_r[native.Random.FromSystemTime():next(1, #var_4_r)]
		local var_4_8 = arg_4_0.guid
		local var_4_9 = native.createTable(64, 0)

		for iter_4_0, iter_4_1 in arg_4_7:activeObjects(humanoidtype.TypeId) do
			table.insert(var_4_9, iter_4_0)
		end

		local var_4_10 = {
			cutsceneName = var_4_7,
			targetIds = var_4_4,
			hideIds = var_4_9,
			guid = var_4_8:derive(69),
			onFinishedState = arg_4_0.nextState
		}

		arg_4_11:add(cutsceneplayevent_request.CutscenePlayEventRequest(var_4_10))

		local var_4_11 = arg_4_7:getGameObject(var_4_0).side
		local var_4_12 = arg_4_6:getGamerSideEntity()

		ASSERT(var_4_12)

		local var_4_13 = var_4_12:isAnyGamerOnSide(var_4_11)

		ASSERT(var_4_13 ~= nil)

		local var_4_14 = arg_4_5:getComponent("matchInData")
		local var_4_15 = arg_4_3.primaryPartyMemberSettings.automaticInterchanges or var_4_14:isBeAProMode()

		if var_4_13 and not var_4_15 then
			local var_4_16 = var_4_14.matchType.maxSubstitutionCount
			local var_4_17 = var_4_16 == native.EMaxSubstitutionCounts.Unlimited
			local var_4_18 = var_4_16:toInt()
			local var_4_19 = arg_4_3.knowledgeBank
			local var_4_20 = var_4_19.teamSubstitutionDecisionKnowledgePair

			ASSERT(var_4_20)

			local var_4_21 = var_4_20:get(var_4_11)

			ASSERT(var_4_21)

			local var_4_22 = var_4_19.teamSubstitutionOrderKnowledgePair

			ASSERT(var_4_22)

			local var_4_23 = var_4_22:get(var_4_11)

			ASSERT(var_4_23)

			local var_4_24 = VERIFY(arg_4_6:getTeamSubstitutionEntityPair()):get(var_4_11)

			ASSERT(var_4_24)

			local var_4_25 = var_4_19.inPlayInfoPool

			ASSERT(var_4_25)

			local var_4_26 = var_4_23:subOnOrderList()

			ASSERT(var_4_26)

			local var_4_27

			for iter_4_2, iter_4_3 in pairs(var_4_26) do
				local var_4_28 = var_4_25:get(iter_4_3)

				if not var_4_21:queuedSubstitutionsContains(iter_4_3) and not var_4_24:queuedSubstitutionsContains(iter_4_3) and var_4_28.role == native.EAssignedRole.Substitute and var_4_28.inPlayState == native.EInPlayState.Sideline then
					var_4_27 = iter_4_3
				end
			end

			ASSERT(var_4_27 ~= nil)

			if not var_4_27 then
				return
			end

			local var_4_29 = {
				side = var_4_11,
				offId = var_4_0,
				onId = var_4_27,
				maxSubstitutions = var_4_18,
				unlimitedSubstitutions = var_4_17
			}

			arg_4_11:add(substitution_request.SubstitutionRequest(var_4_29))
		end
	end
end
