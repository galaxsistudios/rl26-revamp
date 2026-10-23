import("base.rulestate.rulestateclass")
import("core.marshalling.types")
import("base.side.sidehelper")
import("game.cutscenes.cutscene_helper")
import("game.cutscenes.cutsceneplayevent_request")
import("ai.officials.touchjudgeconversionflag_request")

rulestateclass.rulestateclass("ConversionCutsceneRuleState", function(arg_1_0, arg_1_1)
	for iter_1_0, iter_1_1 in pairs(ConversionCutsceneRuleState.MemberDefinitions) do
		arg_1_0[iter_1_0] = arg_1_1[iter_1_0]
	end
end).MemberDefinitions = {
	nextState = types.RuleState,
	kickerId = types.ObjectId,
	randomSeed = types.SignedInteger,
	conversionKickSuccess = types.Boolean,
	ballPosition = types.Vec3
}
ConversionCutsceneRuleState.HidePlayerMarkers = true
ConversionCutsceneRuleState.HideBallMarkers = true

function ConversionCutsceneRuleState.onEnterSolid(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	local var_2_0 = arg_2_6:getMatchTimeEntity()
	local var_2_1 = arg_2_6:getMatchProgressionEntity()
	local var_2_2 = arg_2_6:getScoreEntity()
	local var_2_3 = arg_2_5:getComponent("matchInData")
	local var_2_4 = var_2_2:getScoreForSide(var_2_3, sidehelper.home)
	local var_2_5 = var_2_2:getScoreForSide(var_2_3, sidehelper.away)
	local var_2_6 = 600
	local var_2_7 = var_2_1:isApproachingEndOfMatch(var_2_0, arg_2_8, 600)
	local var_2_8 = 8 >= math.abs(var_2_4 - var_2_5)
	local var_2_9 = {
		arg_2_0.kickerId
	}
	local var_2_10

	if var_2_7 or var_2_8 then
		var_2_10 = arg_2_0.conversionKickSuccess and "Conversion_Success" or "Conversion_Fail"
	else
		var_2_10 = arg_2_0.conversionKickSuccess and "Conversion_Neutral_Success" or "Conversion_Neutral"
	end

	var_2_10 = var_2_3.matchType.conversionType == native.EMTKickType.DropKick and var_2_10 .. "_NoTee" or var_2_10

	local var_2_11 = arg_2_1.ruleStateGuidManager:alloc()

	arg_2_10:add(cutsceneplayevent_request.CutscenePlayEventRequest({
		cutsceneName = var_2_10,
		targetIds = var_2_9,
		guid = var_2_11,
		constrainBounds = cutscene_helper.getSafeCutsceneConstrainBounds(),
		onFinishedState = arg_2_0.nextState,
		time = arg_2_8,
		randomSeed = arg_2_0.randomSeed
	}))
end

function ConversionCutsceneRuleState.onExitSolid(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10)
	arg_3_10:add(touchjudgeconversionflag_request.TouchJudgeConversionFlagRequest({
		isConversionResultReceived = false
	}))
end

-- Ball into touch: the player who put it out reacts (a tee-less missed-conversion
-- cutscene) instead of the referee cameo. Defined here because this module is
-- already in rulestate_registration and new script files can't be added.
rulestateclass.rulestateclass("InTouchReactionRuleState", function(arg_4_0, arg_4_1)
	for iter_4_0, iter_4_1 in pairs(InTouchReactionRuleState.MemberDefinitions) do
		arg_4_0[iter_4_0] = arg_4_1[iter_4_0]
	end
end).MemberDefinitions = {
	nextState = types.RuleState,
	playerId = types.ObjectId,
	randomSeed = types.SignedInteger
}
InTouchReactionRuleState.HidePlayerMarkers = true
InTouchReactionRuleState.HideBallMarkers = true
InTouchReactionRuleState.CutsceneGroup = "Conversion_Fail_NoTee"

function InTouchReactionRuleState.onEnterSolid(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7, arg_5_8, arg_5_9, arg_5_10)
	arg_5_10:add(cutsceneplayevent_request.CutscenePlayEventRequest({
		cutsceneName = InTouchReactionRuleState.CutsceneGroup,
		targetIds = {
			arg_5_0.playerId
		},
		guid = arg_5_1.ruleStateGuidManager:alloc(),
		constrainBounds = cutscene_helper.getSafeCutsceneConstrainBounds(),
		onFinishedState = arg_5_0.nextState,
		time = arg_5_8,
		randomSeed = arg_5_0.randomSeed
	}))
end
