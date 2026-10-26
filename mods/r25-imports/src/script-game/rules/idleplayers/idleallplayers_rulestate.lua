import("base.rulestate.rulestateclass")
import("core.foundation.class")
import("core.marshalling.types")
import("game.player.playertype")
import("game.umpire.umpiretype")
import("rules.match.matchtime")
import("rules.rules.rules")
import("rules.advance.timedelay_detect")
import("rules.rulestate.rulestate_request")
-- r25-imports
import("game.cutscenes.cutsceneplayevent_request")

local var_0_0 = 4

-- r25-imports (Rugby 25 expansion): R25QueuedCutscene = {cutsceneGroup, targetIds, primarySide,
-- queuedAt} is set by the request that ends a play (rules/fortytwenty/fortytwentyvariation_request.lua);
-- taken once, and only while fresh, so a stale one never plays later. Online / practice /
-- training keep the stock flow (checked by R25CutsceneRuleState).
local R25QueuedCutsceneMaxAge = 10

function r25TakeQueuedCutscene()
	local var_queued = rawget(_G, "R25QueuedCutscene")

	rawset(_G, "R25QueuedCutscene", nil)

	if var_queued and os.clock() - (var_queued.queuedAt or 0) <= R25QueuedCutsceneMaxAge then
		return var_queued
	end
end

rulestateclass.rulestateclass("IdleAllPlayersRuleState", function(arg_1_0, arg_1_1)
	for iter_1_0, iter_1_1 in pairs(IdleAllPlayersRuleState.MemberDefinitions) do
		arg_1_0[iter_1_0] = arg_1_1[iter_1_0]
	end

	arg_1_0.activateStoppageTime = arg_1_0.activateStoppageTime or false
end).MemberDefinitions = {
	nextState = types.Nilable(types.RuleState),
	expireTime = types.Time,
	enablePlayerSwitching = types.Boolean,
	blockGamerSwitching = types.Boolean,
	activateStoppageTime = types.Boolean,
	offendingSide = types.Nilable(types.Team),
	idleTime = types.Time,
	guid = types.Guid,
	randomSeed = types.SignedInteger
}

function IdleAllPlayersRuleState.getSwitchingEnabledForSide(arg_2_0, arg_2_1, arg_2_2)
	return arg_2_0.enablePlayerSwitching
end

function IdleAllPlayersRuleState.getBlockSwitchingGamers(arg_3_0, arg_3_1)
	return arg_3_0.blockGamerSwitching
end

function IdleAllPlayersRuleState.onEnterSolid(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7, arg_4_8, arg_4_9, arg_4_10)
	local var_4_0 = arg_4_6:getBallEntity():getOwnerId(arg_4_8)
	local var_4_1 = arg_4_0.idleTime
	local var_4_2 = arg_4_0.guid

	arg_4_0.rng = native.Random(arg_4_0.randomSeed)

	local var_4_3 = {}

	for iter_4_0, iter_4_1 in arg_4_7:activeObjects(playertype.TypeId) do
		table.insert(var_4_3, iter_4_1)
	end

	for iter_4_2, iter_4_3 in arg_4_7:activeObjects(umpiretype.TypeId) do
		table.insert(var_4_3, iter_4_3)
	end

	arg_4_0.playerObjectsYetToIdle = var_4_3
end

function IdleAllPlayersRuleState.apply(arg_5_0, arg_5_1, arg_5_2)
	matchtime.updateTime(arg_5_1, arg_5_2)

	if arg_5_0.activateStoppageTime then
		matchtime.startRealTime(arg_5_1, arg_5_2)
	end
end

function IdleAllPlayersRuleState.createRules(arg_6_0, arg_6_1, arg_6_2)
	local var_6_0 = arg_6_0.expireTime
	local var_6_1 = rules.Rules()

	if arg_6_0.nextState then
		local function var_6_2(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7)
			-- r25-imports: a cutscene queued by the play that led here (e.g. the 40/20
			-- celebration) plays first, then the stock next state
			local var_7_0 = r25TakeQueuedCutscene()

			if var_7_0 then
				arg_7_7:addRuleStateRequest(class.instantiate("R25CutsceneRuleState", {
					nextState = arg_6_0.nextState,
					targetIds = var_7_0.targetIds,
					primarySide = var_7_0.primarySide,
					cutsceneGroup = var_7_0.cutsceneGroup,
					randomSeed = native.Random.FromSystemTime():nextAsSeed(),
					guid = arg_7_2:alloc()
				}), arg_7_2:alloc())

				return
			end

			arg_7_7:addRuleStateRequest(arg_6_0.nextState, arg_7_2:alloc())
		end

		var_6_1:add(timedelay_detect.TimeDelayDetect(var_6_2, var_6_0))
	end

	return var_6_1
end

function IdleAllPlayersRuleState.updateSolid(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5, arg_8_6, arg_8_7, arg_8_8, arg_8_9, arg_8_10, arg_8_11, arg_8_12)
	local var_8_0 = arg_8_0.rng

	for iter_8_0 = 1, var_0_0 do
		if #arg_8_0.playerObjectsYetToIdle < 1 then
			return
		end

		local var_8_1 = var_8_0:next(1, #arg_8_0.playerObjectsYetToIdle)

		arg_8_0.playerObjectsYetToIdle[var_8_1]:setBehaviour("Idle", arg_8_9)
		table.remove(arg_8_0.playerObjectsYetToIdle, var_8_1)
	end

	local var_8_2 = arg_8_6:getMatchTimeEntity()
	local var_8_3 = matchtime.canEndCurrentPeriod(arg_8_5, var_8_2)
	local var_8_4 = var_8_2.goldenPointActive

	if var_8_3 or var_8_4 then
		print("[] Ending current period in idle players rulestate...")

		local var_8_5 = {
			idleDuration = 0.5,
			endedWithScore = false,
			randomSeed = var_8_0:nextAsSeed()
		}
		local var_8_6 = class.instantiate("TimePeriodExpiredIdleRuleState", var_8_5)

		rulestate_request.RuleStateRequest(var_8_6, arg_8_4:alloc())
	end
end

function IdleAllPlayersRuleState.onExitSolid(arg_9_0, arg_9_1, arg_9_2, arg_9_3, arg_9_4, arg_9_5, arg_9_6, arg_9_7, arg_9_8, arg_9_9, arg_9_10)
	if #arg_9_0.playerObjectsYetToIdle < 1 then
		return
	end

	for iter_9_0, iter_9_1 in ipairs(arg_9_0.playerObjectsYetToIdle) do
		iter_9_1:setBehaviour("Idle", arg_9_8)
	end
end

-- r25-imports: plays a cutscene group on its targets (primarySide for actor filters with
-- side = "primary"), then nextState. Skipped (straight to nextState) online, in practice
-- and training, or when the group isn't defined.
rulestateclass.rulestateclass("R25CutsceneRuleState", function(arg_10_0, arg_10_1)
	for iter_10_0, iter_10_1 in pairs(R25CutsceneRuleState.MemberDefinitions) do
		arg_10_0[iter_10_0] = arg_10_1[iter_10_0]
	end
end).MemberDefinitions = {
	nextState = types.RuleState,
	targetIds = types.Array(types.ObjectId),
	primarySide = types.Team,
	cutsceneGroup = types.String("name"),
	randomSeed = types.Number,
	guid = types.Guid
}
R25CutsceneRuleState.HidePlayerMarkers = true
R25CutsceneRuleState.HideBallMarkers = true

function R25CutsceneRuleState.onEnterSolid(arg_11_0, arg_11_1, arg_11_2, arg_11_3, arg_11_4, arg_11_5, arg_11_6, arg_11_7, arg_11_8, arg_11_9, arg_11_10)
	local var_11_0 = arg_11_5:getComponent("matchInData")
	local var_11_1 = import("intermediatelua.cutscenes.data.cutscenedata_config")

	arg_11_0.skip = var_11_0.onlineMultiplayer or var_11_0.gameMode == native.EGameMode.Practice
		or arg_11_6:getTrainingEntity().trainingActive
		or not (var_11_1 and var_11_1.GroupList[arg_11_0.cutsceneGroup])

	local var_11_2 = arg_11_3.hud and arg_11_3.hud.featureStack

	if var_11_2 and not arg_11_0.skip then
		var_11_2:push("cutscene")

		arg_11_0.pushedHud = true
	end
end

function R25CutsceneRuleState.onExitSolid(arg_12_0, arg_12_1, arg_12_2, arg_12_3, arg_12_4, arg_12_5, arg_12_6, arg_12_7, arg_12_8, arg_12_9, arg_12_10)
	local var_12_0 = arg_12_3.hud and arg_12_3.hud.featureStack

	if var_12_0 and arg_12_0.pushedHud then
		var_12_0:pop("cutscene")
	end
end

function R25CutsceneRuleState.updateSolid(arg_13_0, arg_13_1, arg_13_2, arg_13_3, arg_13_4, arg_13_5, arg_13_6, arg_13_7, arg_13_8, arg_13_9, arg_13_10, arg_13_11)
	if arg_13_0.haveSentRulestateRequest then
		return
	end

	if not VERIFY(arg_13_3.network):isMaster() then
		return
	end

	arg_13_0.haveSentRulestateRequest = true

	if arg_13_0.skip then
		arg_13_11:add(rulestate_request.RuleStateRequest(arg_13_0.nextState, arg_13_0.guid:derive(70)))

		return
	end

	arg_13_11:add(cutsceneplayevent_request.CutscenePlayEventRequest({
		cutsceneName = arg_13_0.cutsceneGroup,
		targetIds = arg_13_0.targetIds,
		primarySide = arg_13_0.primarySide,
		hideIds = {},
		guid = arg_13_0.guid:derive(69),
		onFinishedState = arg_13_0.nextState,
		randomSeed = arg_13_0.randomSeed
	}))
end
