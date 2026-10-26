import("ai.formation.refereeformationchange_request")
import("ai.officials.refereehelper")
import("base.rulestate.rulestateclass")
import("core.foundation.tablex")
import("core.marshalling.types")
-- r25-imports
import("core.foundation.class")
import("rules.placekick.placekick_setup_rulestate")

local var_0_0 = placekick_setup_rulestate.PlaceKickSetupRuleState

-- r25-imports (Rugby 25 expansion): after the try (and its replay), before the conversion is
-- set up, R25PostReplayChance percent of tries get a post-replay scene: the scorer walking back
-- with teammates or a team huddle (group PostReplay, R25's PostReplayScorerWalksBack /
-- PostReplayTeamHuddle). The try comes from game/scoring/score_request.lua (R25LastTry); the
-- conversion setup then runs from a fresh copy of this state (r25PostReplayDone).
local R25PostReplayChance = 35
local R25PostReplayMaxAge = 120

local function r25PostReplayFor(arg_state)
	if arg_state.r25PostReplayDone or arg_state.isFromVideoReferee then
		return nil
	end

	local var_try = rawget(_G, "R25LastTry")

	rawset(_G, "R25LastTry", nil)

	if not var_try or os.clock() - (var_try.at or 0) > R25PostReplayMaxAge or var_try.side ~= arg_state.kickerSide then
		return nil
	end

	if native.Random.FromSystemTime():next(0, 100) >= R25PostReplayChance then
		return nil
	end

	return var_try
end

rulestateclass.rulestateclass("ConversionKickSetupRuleState", var_0_0, function(arg_1_0, arg_1_1)
	for iter_1_0, iter_1_1 in pairs(ConversionKickSetupRuleState.MemberDefinitions) do
		arg_1_0[iter_1_0] = arg_1_1[iter_1_0]
	end
end).MemberDefinitions = {
	kickPosition = types.Vec2,
	isFromVideoReferee = types.Nilable(types.Boolean),
	showTryConfirmed = types.Nilable(types.Boolean),
	r25PostReplayDone = types.Nilable(types.Boolean)
}
ConversionKickSetupRuleState.MemberDefinitions = tablex.mergeInto(ConversionKickSetupRuleState.MemberDefinitions, var_0_0.MemberDefinitions)
ConversionKickSetupRuleState.NextStateName = "PlaceKickPositionBallRuleState"
ConversionKickSetupRuleState.FinalStateName = "ConversionKickRuleState"
ConversionKickSetupRuleState.OffenceFormation = "ConversionOffence"
ConversionKickSetupRuleState.DefenceFormation = "ConversionDefence"

function ConversionKickSetupRuleState.onEnterSolid(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	-- r25-imports: the post-replay scene first, then this setup again (see r25PostReplayFor)
	local var_2_ok, var_2_try = pcall(r25PostReplayFor, arg_2_0)

	if var_2_ok and var_2_try then
		local var_2_args = {
			r25PostReplayDone = true
		}

		for iter_2_0 in pairs(ConversionKickSetupRuleState.MemberDefinitions) do
			if iter_2_0 ~= "r25PostReplayDone" then
				var_2_args[iter_2_0] = arg_2_0[iter_2_0]
			end
		end

		arg_2_0.nextState = class.instantiate("R25CutsceneRuleState", {
			nextState = class.instantiate("ConversionKickSetupRuleState", var_2_args),
			targetIds = {
				var_2_try.scorerId
			},
			primarySide = var_2_try.side,
			cutsceneGroup = "PostReplay",
			randomSeed = native.Random.FromSystemTime():nextAsSeed(),
			guid = arg_2_1.ruleStateGuidManager:alloc()
		})

		return
	end

	if arg_2_0.isFromVideoReferee then
		local var_2_0 = arg_2_3.hud and arg_2_3.hud:getElement("logotransition")

		if var_2_0 then
			var_2_0:kick()
		end
	end

	if arg_2_0.kickType == nil then
		arg_2_0.kickType = native.EDisposalSubType.Conversion
	end

	var_0_0.onEnterSolid(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)

	local var_2_1 = arg_2_5:getComponent("matchInData").matchType
	local var_2_2 = arg_2_5:getSide(arg_2_0.kickerSide):getPlayDir().x * arg_2_0.kickPosition.y > 0 and native.EForceDirectedGraphType.RefereeConversionKickRight or native.EForceDirectedGraphType.RefereeConversionKickLeft
	local var_2_3 = var_2_1.categorisedMatchType == native.EMatchType.MT_StandardMatch
	local var_2_4 = refereehelper.getRefereeGraphName(var_2_2, var_2_3)
	local var_2_5 = {
		refereeGraphName = var_2_4,
		refereeFormationFocus = native.EFormationFocus.Manual,
		refereeManualFocusPoint = arg_2_0.kickPosition
	}

	arg_2_10:add(refereeformationchange_request.RefereeFormationChangeRequest(var_2_5))
end
