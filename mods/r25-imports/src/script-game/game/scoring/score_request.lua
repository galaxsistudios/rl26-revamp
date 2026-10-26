import("core.marshalling.types")
import("core.requestmodel.request")
import("game.scoring.scoreincrement")

local var_0_0 = native.CSimulationRequest

request.requestclass("ScoreRequest", var_0_0, function(arg_1_0, arg_1_1)
	var_0_0.init(arg_1_0)

	for iter_1_0, iter_1_1 in pairs(ScoreRequest.MemberDefinitions) do
		arg_1_0[iter_1_0] = arg_1_1[iter_1_0]
	end
end).MemberDefinitions = {
	scoreTime = types.Number,
	scoringSide = types.SignedInteger,
	scorerId = types.ObjectId,
	scorerAssetId = types.SignedInteger,
	scoreType = types.SignedInteger,
	gamerId = types.Nilable(types.GamerId)
}

function ScoreRequest.validate(arg_2_0, arg_2_1, arg_2_2)
	return true
end

function ScoreRequest.apply(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5)
	local var_3_0 = arg_3_0.scoringSide

	ASSERT(var_3_0)

	local var_3_1 = arg_3_0.scorerId

	ASSERT(var_3_1)

	local var_3_2 = arg_3_0.scorerAssetId

	ASSERT(var_3_2)

	local var_3_3 = arg_3_0.scoreType

	ASSERT(var_3_3)

	local var_3_4 = arg_3_0.gamerId
	local var_3_5 = arg_3_0.scoreTime

	ASSERT(var_3_5)

	local var_3_6 = math.ceil(var_3_5 / 60)
	local var_3_7 = VERIFY(arg_3_2:getScoreEntity())
	local var_3_8 = native.EScoreType:fromInt(var_3_3)

	ASSERT(var_3_8)

	local var_3_9 = arg_3_2:getMatchProgressionEntity()
	local var_3_10 = var_3_9.currentTimePeriod

	if var_3_9.currentExtraTimePeriod == 0 then
		local var_3_11 = var_3_10 * 40

		var_3_6 = native.clamp1(var_3_6, 0, var_3_11)
	end

	var_3_7:addScoreInformation(var_3_8, var_3_0, var_3_2, var_3_6, var_3_10)
	scoreincrement.generateScoreIncrementEvent(arg_3_1, arg_3_3, var_3_1, var_3_2, var_3_4, var_3_0, var_3_3, var_3_6)

	-- r25-imports: remember the try for the post-replay scene played before the conversion
	-- (rules/conversion/conversionkick_setup_rulestate.lua)
	if var_3_8 == native.EScoreType.Try then
		rawset(_G, "R25LastTry", {
			scorerId = var_3_1,
			side = var_3_0,
			at = os.clock()
		})
	end
end
