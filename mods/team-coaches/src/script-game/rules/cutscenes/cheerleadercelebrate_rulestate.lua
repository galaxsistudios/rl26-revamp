import("base.rulestate.rulestateclass")
import("core.marshalling.types")
import("game.cheerleader.cheerleadertype")
import("game.humanoid.humanoidtype")
import("game.cheerleader.cheerleader_helper")
import("game.cutscenes.cutscene_helper")
import("game.cutscenes.cutsceneplayevent_request")

local var_0_0 = {
	"CheerleaderTry_01",
	"CheerleaderTry_02",
	"CheerleaderTry_03"
}

rulestateclass.rulestateclass("CheerleaderCelebrateRuleState", function(arg_1_0, arg_1_1)
	for iter_1_0, iter_1_1 in pairs(CheerleaderCelebrateRuleState.MemberDefinitions) do
		arg_1_0[iter_1_0] = arg_1_1[iter_1_0]
	end
end).MemberDefinitions = {
	nextState = types.RuleState,
	skipReplayEvent = types.Nilable(types.Boolean),
	scoringSide = types.Team,
	randomSeed = types.SignedInteger
}

function CheerleaderCelebrateRuleState.wipe(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7)
	cheerleader_helper.positionCheerleaders(arg_2_2, arg_2_4, arg_2_6, arg_2_7)
end

function CheerleaderCelebrateRuleState.onEnterSolid(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10)
	if not arg_3_0.skipReplayEvent then
		table.insert(arg_3_9, {
			type = "QueueReplayEvent",
			time = arg_3_8
		})
	end

	local var_3_0 = arg_3_3.pools.sidePool
	local var_3_1 = native.createTable(64, 0)

	for iter_3_0, iter_3_1 in arg_3_7:activeObjects(humanoidtype.TypeId) do
		table.insert(var_3_1, iter_3_0)
	end

	local var_3_2 = native.createTable(64, 0)

	for iter_3_2, iter_3_3 in arg_3_7:activeObjects(cheerleadertype.TypeId) do
		local var_3_3 = var_3_0:get(iter_3_2)

		if var_3_3 and var_3_3.side == arg_3_0.scoringSide then
			table.insert(var_3_2, iter_3_2)
		end
	end

	if #var_3_2 > 0 then
		local var_3_4 = arg_3_1.ruleStateGuidManager:alloc()
		local var_3_5 = arg_3_0.randomSeed

		ASSERT(var_3_5)

		local var_3_6 = native.Random(var_3_5):randomInteger(#var_0_0) + 1
		local var_3_7 = var_0_0[var_3_6]

		arg_3_10:add(cutsceneplayevent_request.CutscenePlayEventRequest({
			hideActorsDuringLoad = false,
			cutsceneName = var_3_7,
			targetIds = var_3_2,
			hideIds = var_3_1,
			guid = var_3_4,
			constrainBounds = cutscene_helper.getSafeCutsceneConstrainBounds(),
			onFinished = function()
				arg_3_0.shouldAdvance = true
			end,
			time = arg_3_8,
			randomSeed = arg_3_0.randomSeed
		}))
	else
		arg_3_0.shouldAdvance = true
		arg_3_0.noCheerleaders = true
	end

	local var_3_8 = arg_3_3.soundSystem

	if var_3_8 then
		var_3_8:queueSoundOnlyEvent({
			type = "CheerleaderSoundEvent",
			time = arg_3_8
		})
	end
end

function CheerleaderCelebrateRuleState.onExitSolid(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7, arg_5_8, arg_5_9, arg_5_10)
	return
end

function CheerleaderCelebrateRuleState.updateSolid(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8, arg_6_9, arg_6_10, arg_6_11)
	local var_6_0 = arg_6_0.noCheerleaders and true or arg_6_9 > arg_6_0.__applyTime + 0.3333333333333333

	if not arg_6_0.sentRuleStateRequest and arg_6_0.shouldAdvance and var_6_0 then
		arg_6_0.sentRuleStateRequest = true

		if arg_6_3.network:isMaster() then
			arg_6_11:addRuleStateRequest(arg_6_0.nextState, arg_6_4:alloc())
		end
	end
end

-- team-coaches: coach reaction close-ups run through this (otherwise unused)
-- CheerleaderCelebrateRuleState, flagged with coachReaction. Reusing it rather
-- than adding a class means replay-team-stinger, which only stings replays
-- queued during the celebration states it lists (this one included, reading
-- scoringSide), puts its team stinger after the coach shot. Built by
-- coach_helper.makeCoachReaction (penalties, 40/20s, some tries): stops play,
-- runs one teamcoaches_* cutscene (cs_conversion_data.lua) on the reacting
-- side's sideline coach with a front-facing camera, then continues with
-- nextState. After a try it also queues the try replay (taken off the try
-- celebration), so the order is celebration, coach, replay, conversion.
-- Without coachReaction the stock cheerleader code runs unchanged.
import("game.player.playertype")
import("rules.match.matchtime")
import("game.coach.coach_helper")

local var_tc_members = CheerleaderCelebrateRuleState.MemberDefinitions

var_tc_members.coachReaction = types.Nilable(types.Boolean)
var_tc_members.coachSide = types.Nilable(types.Team)
var_tc_members.coachHappy = types.Nilable(types.Boolean)
var_tc_members.queueReplay = types.Nilable(types.Boolean)

CheerleaderCelebrateRuleState.CoachFailsafeSeconds = 14

local var_tc_stockOnEnterSolid = CheerleaderCelebrateRuleState.onEnterSolid
local var_tc_stockUpdateSolid = CheerleaderCelebrateRuleState.updateSolid
local var_tc_stockWipe = CheerleaderCelebrateRuleState.wipe
local var_tc_stockApply = CheerleaderCelebrateRuleState.apply

function CheerleaderCelebrateRuleState.apply(arg_tc_0, arg_tc_1, arg_tc_2, ...)
	if arg_tc_0.coachReaction then
		matchtime.updateTime(arg_tc_1, arg_tc_2)
		matchtime.startStoppageTime(arg_tc_1, arg_tc_2)

		return
	end

	if var_tc_stockApply then
		return var_tc_stockApply(arg_tc_0, arg_tc_1, arg_tc_2, ...)
	end
end

function CheerleaderCelebrateRuleState.wipe(arg_tc_0, ...)
	if arg_tc_0.coachReaction then
		return
	end

	return var_tc_stockWipe(arg_tc_0, ...)
end

function CheerleaderCelebrateRuleState.onEnterSolid(arg_tc_0, arg_tc_1, arg_tc_2, arg_tc_3, arg_tc_4, arg_tc_5, arg_tc_6, arg_tc_7, arg_tc_8, arg_tc_9, arg_tc_10)
	if not arg_tc_0.coachReaction then
		return var_tc_stockOnEnterSolid(arg_tc_0, arg_tc_1, arg_tc_2, arg_tc_3, arg_tc_4, arg_tc_5, arg_tc_6, arg_tc_7, arg_tc_8, arg_tc_9, arg_tc_10)
	end

	if arg_tc_0.queueReplay then
		table.insert(arg_tc_9, {
			type = "QueueReplayEvent",
			time = arg_tc_8
		})
	end

	local var_tc_0 = coach_helper.getSidelineCoachId(arg_tc_0.coachSide)

	if not var_tc_0 or not arg_tc_7:isActive(var_tc_0) then
		coach_helper.sidelineLog("reaction: no active coach for side %s, skipped", tostring(arg_tc_0.coachSide))

		arg_tc_0.shouldAdvance = true
		arg_tc_0.noCheerleaders = true

		return
	end

	for iter_tc_0, iter_tc_1 in arg_tc_7:activeObjects(playertype.TypeId) do
		iter_tc_1:setBehaviour("Idle", arg_tc_8)
	end

	local var_tc_1 = native.createTable(64, 0)

	for iter_tc_2, iter_tc_3 in arg_tc_7:activeObjects(humanoidtype.TypeId) do
		if iter_tc_2 ~= var_tc_0 then
			table.insert(var_tc_1, iter_tc_2)
		end
	end

	local var_tc_2 = native.Random(arg_tc_0.randomSeed)
	local var_tc_3 = arg_tc_0.coachHappy and coach_helper.CoachReactionCutscenes.happy or coach_helper.CoachReactionCutscenes.gutted
	local var_tc_4 = var_tc_3[var_tc_2:randomInteger(#var_tc_3) + 1]
	local var_tc_5 = var_tc_4.cuts[var_tc_2:randomInteger(#var_tc_4.cuts) + 1]

	arg_tc_0.coachId = var_tc_0
	arg_tc_0.cameraChecked = false

	arg_tc_10:add(cutsceneplayevent_request.CutscenePlayEventRequest({
		hideActorsDuringLoad = false,
		cutsceneName = var_tc_4.name,
		cutIndex = var_tc_5,
		waneTime = var_tc_4.wane,
		targetIds = {
			var_tc_0
		},
		hideIds = var_tc_1,
		guid = arg_tc_1.ruleStateGuidManager:alloc(),
		constrainBounds = cutscene_helper.getSafeCutsceneConstrainBounds(),
		onFinished = function()
			arg_tc_0.shouldAdvance = true
		end,
		time = arg_tc_8,
		randomSeed = arg_tc_0.randomSeed
	}))
	coach_helper.sidelineLog("reaction: playing %s camera %d on npc id %s%s", var_tc_4.name, var_tc_5, tostring(var_tc_0), arg_tc_0.queueReplay and ", replay queued after it" or "")
end

function CheerleaderCelebrateRuleState.updateSolid(arg_tc_0, arg_tc_1, arg_tc_2, arg_tc_3, arg_tc_4, arg_tc_5, arg_tc_6, arg_tc_7, arg_tc_8, arg_tc_9, arg_tc_10, arg_tc_11)
	if not arg_tc_0.coachReaction then
		return var_tc_stockUpdateSolid(arg_tc_0, arg_tc_1, arg_tc_2, arg_tc_3, arg_tc_4, arg_tc_5, arg_tc_6, arg_tc_7, arg_tc_8, arg_tc_9, arg_tc_10, arg_tc_11)
	end

	local var_tc_0 = arg_tc_9 - arg_tc_0.__applyTime

	-- one-off check that the shot faces the coach (camera in front of him)
	if not arg_tc_0.cameraChecked and arg_tc_0.coachId and var_tc_0 > 1.2 then
		arg_tc_0.cameraChecked = true

		pcall(function()
			local var_tc_1 = arg_tc_3.camera.pos:tovec2()
			local var_tc_2 = arg_tc_7:getGameObject(arg_tc_0.coachId)
			local var_tc_3, var_tc_6 = native.dirlen2(var_tc_1, var_tc_2.pos)
			local var_tc_4 = native.safenormalise2(var_tc_3, var_tc_2.facing)
			local var_tc_5 = var_tc_4.x * var_tc_2.facing.x + var_tc_4.y * var_tc_2.facing.y

			coach_helper.sidelineLog("reaction camera: %s (dot %.2f, %s m from the coach)", var_tc_5 > 0.3 and "in front" or (var_tc_5 < -0.3 and "BEHIND" or "side-on"), var_tc_5, tostring(var_tc_6))
		end)
	end

	if not arg_tc_0.shouldAdvance and var_tc_0 > CheerleaderCelebrateRuleState.CoachFailsafeSeconds then
		coach_helper.sidelineLog("reaction: cutscene didn't finish within %d s, moving on", CheerleaderCelebrateRuleState.CoachFailsafeSeconds)

		arg_tc_0.shouldAdvance = true
	end

	local var_tc_6 = arg_tc_0.noCheerleaders and true or var_tc_0 > 0.3333333333333333

	if not arg_tc_0.sentRuleStateRequest and arg_tc_0.shouldAdvance and var_tc_6 then
		arg_tc_0.sentRuleStateRequest = true

		if arg_tc_3.network:isMaster() then
			arg_tc_11:addRuleStateRequest(arg_tc_0.nextState, arg_tc_4:alloc())
		end
	end
end
