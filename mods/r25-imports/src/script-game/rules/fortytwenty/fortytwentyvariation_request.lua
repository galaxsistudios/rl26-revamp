import("core.marshalling.types")
import("core.requestmodel.request")

local var_0_0 = native.CSimulationRequest

request.requestclass("FortyTwentyVariationRequest", var_0_0, function(arg_1_0, arg_1_1)
	var_0_0.init(arg_1_0)

	for iter_1_0, iter_1_1 in pairs(FortyTwentyVariationRequest.MemberDefinitions) do
		arg_1_0[iter_1_0] = arg_1_1[iter_1_0]
	end
end).MemberDefinitions = {
	restartSide = types.Team,
	outPosition = types.Vec2,
	restartPosition = types.Vec2,
	kicker = types.ObjectId,
	gamerId = types.Nilable(types.GamerId),
	eventType = types.String("EventType")
}

function FortyTwentyVariationRequest.validate(arg_2_0, arg_2_1, arg_2_2, arg_2_3)
	return not arg_2_2:getMatchProgressionEntity().ballIsDead
end

function FortyTwentyVariationRequest.apply(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4)
	local var_3_0 = arg_3_0.restartSide
	local var_3_1 = arg_3_0.outPosition
	local var_3_2 = arg_3_0.restartPosition
	local var_3_3 = arg_3_0.kicker
	local var_3_4 = arg_3_0.gamerId
	local var_3_5 = var_3_0
	local var_3_6 = {
		type = arg_3_0.eventType,
		restartSide = var_3_0,
		outPosition = var_3_1,
		restartPosition = var_3_2,
		kicker = var_3_3,
		gamerId = var_3_4,
		time = arg_3_1
	}

	table.insert(arg_3_3, var_3_6)

	-- r25-imports: queue the kicker's 40/20 celebration (Rugby 25's FiftyTwentyTwo scenes). The
	-- IdleAllPlayersRuleState that runs next plays it before the restart
	-- (rules/idleplayers/idleallplayers_rulestate.lua). The 40/20 restart goes to the kicker's side.
	if var_3_3 then
		rawset(_G, "R25QueuedCutscene", {
			cutsceneGroup = "FortyTwentyCelebrate",
			targetIds = {
				var_3_3
			},
			primarySide = var_3_0,
			queuedAt = os.clock()
		})
	end
end
