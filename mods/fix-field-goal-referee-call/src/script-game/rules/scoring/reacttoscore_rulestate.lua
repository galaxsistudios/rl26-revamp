import("base.rulestate.rulestateclass")
import("core.foundation.class")
import("core.marshalling.types")
import("game.player.playertype")
import("game.umpire.umpiretype")
import("rules.match.matchtime")
import("rules.rules.ruleauthority")
import("rules.rules.rules")
import("script-config.ai.rugby.officials.referee_config")
import("rules.advance.timedelay_detect")
import("rules.advance.cutsceneparticipantswithinrange_detect")
import("rules.rules.conditionalrule")

local var_0_0 = 15
local var_0_1 = 4

rulestateclass.rulestateclass("ReactToScoreRuleState", function(arg_1_0, arg_1_1)
	for iter_1_0, iter_1_1 in pairs(ReactToScoreRuleState.MemberDefinitions) do
		arg_1_0[iter_1_0] = arg_1_1[iter_1_0]
	end
end).MemberDefinitions = {
	nextState = types.RuleState,
	maxDelayBeforeCutscene = types.Number,
	minDelayBeforeCutscene = types.Number,
	quickCutToCutscene = types.Boolean,
	decisionPending = types.Boolean,
	scoringSide = types.Team,
	scorer = types.ObjectId,
	scoringGamer = types.Nilable(types.GamerId),
	scorePosition = types.Vec2,
	randomSeed = types.SignedInteger,
	unsuccessfulAttempt = types.Boolean,
	isFieldGoalAttempt = types.Nilable(types.Boolean),
	tryAttemptOutcome = types.Nilable(types.TryAttemptOutcome),
	playCheerleaderCameo = types.Nilable(types.Boolean),
	isBonusTry = types.Boolean
}

function ReactToScoreRuleState.getSwitchingEnabled(arg_2_0, arg_2_1)
	return false
end

function ReactToScoreRuleState.onEnterSolid(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10)
	for iter_3_0, iter_3_1 in arg_3_7:activeObjects(playertype.TypeId) do
		iter_3_1:setBehaviour("TeamScored", arg_3_8)
	end

	for iter_3_2, iter_3_3 in arg_3_7:activeObjects(umpiretype.TypeId) do
		iter_3_3:setBehaviour("Idle", arg_3_8)
	end

	local var_3_0 = {}
	local var_3_1 = arg_3_0.scorer
	local var_3_2 = arg_3_7:getGameObject(var_3_1)
	local var_3_3 = 0

	for iter_3_4, iter_3_5 in arg_3_7:activeObjects(playertype.TypeId) do
		if iter_3_5.side == arg_3_0.scoringSide and iter_3_4 ~= var_3_1 then
			local var_3_4 = native.distance2(iter_3_5.pos, var_3_2.pos)
			local var_3_5 = {
				id = iter_3_4,
				dist = var_3_4
			}

			table.insert(var_3_0, var_3_5)
		end
	end

	table.sort(var_3_0, function(arg_4_0, arg_4_1)
		return arg_4_0.dist < arg_4_1.dist
	end)

	local var_3_6 = assert(arg_3_3.motionSet.data)
	local var_3_7 = assert(arg_3_3.pools.animationSequenceDataPool):get(var_3_1)
	local var_3_8 = var_3_2.pos

	if var_3_7.valid then
		local var_3_9 = var_3_7:getEndTime(var_3_6)
		local var_3_10 = var_3_7:getWorldRootAtTime(var_3_6, var_3_2.scale, var_3_9)

		ASSERT(var_3_10)

		if var_3_10 then
			var_3_8 = var_3_10.translation
		end
	end

	local var_3_11 = arg_3_3.pools.reactToScorePool
	local var_3_12 = arg_3_0.randomSeed

	ASSERT(var_3_12)

	local var_3_13 = native.Random(var_3_12)

	for iter_3_6, iter_3_7 in ipairs(var_3_0) do
		local var_3_14 = iter_3_7.id
		local var_3_15 = arg_3_7:getGameObject(var_3_14)
		local var_3_16 = var_3_11:get(var_3_14)
		local var_3_17 = native.normalize2(var_3_8 - var_3_15.pos)

		if not arg_3_0.quickCutToCutscene and iter_3_7.dist <= var_0_0 and iter_3_6 <= 2 then
			var_3_16.role = native.ECelebrateReactionRole.JoinCutscene
			var_3_16.target = var_3_8 - var_3_17 * var_0_1
		else
			var_3_16.role = native.ECelebrateReactionRole.DoNotJoinCutscene

			local var_3_18 = var_3_13:randomFloatRange(1, 4)
			local var_3_19 = native.vec2(var_3_13:randomFloatRange(-0.25, 0.25), var_3_13:randomFloatRange(-0.25, 0.25))

			var_3_16.target = var_3_8 - native.normalize2(var_3_17 + var_3_19) * var_0_1 * var_3_18
		end
	end
end

function ReactToScoreRuleState.onExitSolid(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7, arg_5_8, arg_5_9, arg_5_10)
	arg_5_6:getJumpAvoidEntity():reset()
end

function ReactToScoreRuleState.apply(arg_6_0, arg_6_1, arg_6_2)
	matchtime.updateTime(arg_6_1, arg_6_2)
	matchtime.startStoppageTime(arg_6_1, arg_6_2)
	matchtime.startRealTime(arg_6_1, arg_6_2)
end

function ReactToScoreRuleState.createRules(arg_7_0, arg_7_1, arg_7_2)
	local var_7_0 = arg_7_0.nextState
	local var_7_1 = arg_7_2 + arg_7_0.maxDelayBeforeCutscene
	local var_7_2 = arg_7_2 + arg_7_0.minDelayBeforeCutscene
	local var_7_3 = false
	local var_7_4

	if arg_7_0.decisionPending then
		function var_7_4(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5, arg_8_6, arg_8_7, arg_8_8)
			arg_7_0.rulestateRequestSent = true

			local var_8_0 = arg_8_8 and arg_8_8.playersWithinRange or {}

			if #var_8_0 < 1 then
				local var_8_1 = 99999
				local var_8_2

				for iter_8_0, iter_8_1 in arg_8_5:activeObjects(playertype.TypeId) do
					local var_8_3 = arg_8_5:getGameObject(arg_7_0.scorer)
					local var_8_4 = iter_8_1.side == var_8_3.side
					local var_8_5 = iter_8_1.id == arg_7_0.scorer

					if var_8_4 and not var_8_5 then
						local var_8_6 = native.distance2(iter_8_1.pos, var_8_3.pos)

						if var_8_6 < var_8_1 then
							var_8_1 = var_8_6
							var_8_2 = iter_8_1.id
						end
					end
				end

				table.insert(var_8_0, var_8_2)
			end

			local var_8_7 = arg_8_3:getComponent("matchInfo"):getMatchSecondsElapsed(arg_8_4, arg_8_6)
			local var_8_8 = {
				nextState = arg_7_0.nextState,
				randomSeed = arg_7_0.randomSeed,
				isSuccessfulTry = not arg_7_0.unsuccessfulAttempt,
				scoreTime = var_8_7
			}
			local var_8_9 = class.instantiate("TryDecisionPendingRuleState", var_8_8)
			local var_8_10 = {
				isVideoReferee = true,
				delayBeforeSignal = 0,
				skipReplayEvent = false,
				nextState = var_8_9,
				tryAttemptOutcome = arg_7_0.tryAttemptOutcome,
				refereeSignal = native.EUmpireSignalTypes.VideoReferee
			}
			local var_8_11 = class.instantiate("RefereeCameoRuleState", var_8_10)

			arg_8_7:addRuleStateRequest(var_8_11, arg_8_2:alloc())
		end
	else
		function var_7_4(arg_9_0, arg_9_1, arg_9_2, arg_9_3, arg_9_4, arg_9_5, arg_9_6, arg_9_7, arg_9_8)
			arg_7_0.rulestateRequestSent = true

			local var_9_0 = arg_9_8 and arg_9_8.playersWithinRange or {}
			local var_9_1 = arg_9_5:getBallObject()
			local var_9_2 = arg_9_4:getOfficialEntity()
			local var_9_3 = {
				var_9_2:getRefereesIds()
			}
			local var_9_4 = false

			for iter_9_0, iter_9_1 in pairs(var_9_3) do
				local var_9_5 = arg_9_5:getGameObject(iter_9_1)

				if native.distance2(var_9_1.pos2, var_9_5.pos) < referee_config.tryCameoDistance then
					var_9_4 = true

					break
				end
			end

			local var_9_6 = false

			if not arg_7_0.isFieldGoalAttempt then
				local var_9_7 = arg_9_5:getGameObject(arg_7_0.scorer)
				local var_9_8 = var_9_7:getAnimationProvider()
				local var_9_9 = var_9_7:getAnimPlayer()
				local var_9_10 = var_9_9:getBodyAnimName()
				local var_9_11 = 1.5
				local var_9_12 = 0.2

				if var_9_8:getAnimationByName(var_9_10) then
					local var_9_13 = var_9_8:getAllEvents(var_9_10)
					local var_9_14 = var_9_8:getEventAnimTime(var_9_10, "tryground_enabled")
					local var_9_15 = var_9_8:getEventAnimTime(var_9_10, "tryground_disabled")
					local var_9_16 = var_9_9:getPrimaryCommand():getAnimationTime()

					if var_9_14 and var_9_15 then
						local var_9_17 = var_9_16 + (var_9_4 and var_9_11 + var_9_12 or var_9_11)

						if var_9_14 < var_9_17 and var_9_17 < var_9_15 then
							var_9_6 = true
						end
					end
				end
			end

			if not arg_7_0.unsuccessfulAttempt then
				local var_9_18 = {
					queueReplay = true,
					nextState = arg_7_0.nextState,
					scorer = arg_7_0.scorer,
					randomSeed = arg_7_0.randomSeed,
					playCheerleaderCameo = arg_7_0.playCheerleaderCameo,
					quickCutToCutscene = arg_7_0.quickCutToCutscene,
					playersWithinRange = var_9_0,
					playerIsOnGround = var_9_6,
					guid = arg_9_2:alloc()
				}
				local var_9_19

				if not arg_7_0.isFieldGoalAttempt then
					var_9_19 = class.instantiate("TryCelebrateRuleState", var_9_18)
				else
					var_9_19 = class.instantiate("FieldGoalCelebrateRuleState", var_9_18)
				end

				local var_9_20 = arg_7_0.tryAttemptOutcome
				local var_9_21 = arg_7_0.isBonusTry
				local var_9_22 = ({
					[native.ETryAttemptOutcome.Try] = var_9_21 and native.EUmpireSignalTypes.FivePoints or native.EUmpireSignalTypes.Try,
					[native.ETryAttemptOutcome.HeldUp] = native.EUmpireSignalTypes.HeldUp,
					[native.ETryAttemptOutcome.DoubleMovement] = native.EUmpireSignalTypes.DoubleMovement,
					[native.ETryAttemptOutcome.OutsideTryArea] = native.EUmpireSignalTypes.OutsideTryArea,
					[native.ETryAttemptOutcome.PenaltyTry] = native.EUmpireSignalTypes.PenaltyTry,
					[native.ETryAttemptOutcome.KnockOn] = native.EUmpireSignalTypes.KnockOn
				})[var_9_20]
				local var_9_23 = {
					delayBeforeSignal = 0.5,
					isVideoReferee = false,
					skipReplayEvent = true,
					nextState = var_9_19,
					refereeSignal = var_9_22
				}
				local var_9_24 = class.instantiate("RefereeCameoRuleState", var_9_23)
				local var_9_25 = arg_9_5:getBallObject()
				local var_9_26 = arg_9_4:getOfficialEntity():getRefereeIdsAsTable()
				local var_9_27 = false

				for iter_9_2, iter_9_3 in pairs(var_9_26) do
					local var_9_28 = arg_9_5:getGameObject(iter_9_3)
					local var_9_29 = native.distance2(var_9_25.pos2, var_9_28.pos)

					var_9_27 = var_9_27 or var_9_29 < referee_config.tryCameoDistance
				end

				if var_9_27 then
					arg_9_7:addRuleStateRequest(var_9_24, arg_9_2:alloc())
				else
					-- Field goals get their whistle and call from FieldGoalSuccessEvent
					-- (soundlistener_referee); TryCelebrateEvent would add a try whistle + "Try!".
					if not arg_7_0.isFieldGoalAttempt then
						arg_9_1.soundSystem:queueSoundOnlyEvent({
							type = "TryCelebrateEvent",
							time = arg_9_6
						})
					end

					arg_9_7:addRuleStateRequest(var_9_19, arg_9_2:alloc())
				end
			else
				arg_9_7:addRuleStateRequest(arg_7_0.nextState, arg_9_2:alloc())
			end
		end
	end

	local var_7_5 = ruleauthority.ifMaster
	local var_7_6 = rules.Rules()

	local function var_7_7()
		return arg_7_0.rulestateRequestSent == nil
	end

	local var_7_8 = 5

	var_7_6:add(conditionalrule.ConditionalRule({
		var_7_7
	}, timedelay_detect.TimeDelayDetect(var_7_4, arg_7_2 + var_7_8, var_7_5)))
	var_7_6:add(conditionalrule.ConditionalRule({
		var_7_7
	}, cutsceneparticipantswithinrange_detect.CutsceneParticipantsWithinRangeDetect(var_7_4, {
		earliestAdvanceTime = var_7_2,
		scoringSide = arg_7_0.scoringSide,
		scorer = arg_7_0.scorer,
		scorePosition = arg_7_0.scorePosition
	}, var_7_5)))

	return var_7_6
end
