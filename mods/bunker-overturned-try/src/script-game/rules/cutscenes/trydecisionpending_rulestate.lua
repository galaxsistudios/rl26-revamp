import("base.rulestate.rulestateclass")
import("core.marshalling.types")
import("game.scoring.score_request")
import("rules.try.posttrydecision_request")
import("rules.match.matchtime")
import("game.player.playertype")
import("game.umpire.umpiretype")
import("script-config.rules.rules.rulesenvironment")

-- bunker-overturned-try: shared state, see rules/try/tryattemptoutcomes.lua.
local function provisionalTry()
	local var_state = rawget(_G, "ProvisionalTryState")

	if not var_state then
		var_state = {}

		rawset(_G, "ProvisionalTryState", var_state)
	end

	return var_state
end

local function provisionalTryLog(arg_text)
	local var_log = provisionalTry().log

	if var_log then
		var_log(arg_text)
	end
end

-- Seconds after the decision starts that the points come off the scoreboard. VideoRefHud
-- swaps "Pending" for the NO TRY decision after 3 s.
local ProvisionalTryRemovePointsTime = 3

-- ProvisionalTryReviewRuleState's wipe: players go back to where they were when the try was
-- awarded, pushed apart to at least ProvisionalTrySpacing metres from each other and
-- ProvisionalTryRefClearance metres from the referee, all facing the try spot. The other
-- officials (touch judges) go out to the touchlines, ProvisionalTryTouchJudgeInfield metres
-- in from the try line, so only the referee is in the cameo.
local ProvisionalTrySpacing = 3
local ProvisionalTryRefClearance = 7
local ProvisionalTrySpreadPasses = 12
local ProvisionalTryTouchJudgeInfield = 12
local ProvisionalTryTouchJudgeOffField = 2

-- Pushes arg_pos out to arg_min metres from arg_from (arg_fallback picks a direction when
-- they're on top of each other). Returns the moved position, or nil if it was far enough.
local function provisionalTryPushOut(arg_pos, arg_from, arg_min, arg_fallback)
	local var_offset = arg_pos - arg_from
	local var_dist = native.length2(var_offset)

	if var_dist >= arg_min then
		return nil
	end

	local var_dir = var_dist > 0.01 and var_offset * (1 / var_dist) or arg_fallback

	return arg_from + var_dir * arg_min
end

local function provisionalTrySpreadPlayers(arg_gameobjects, arg_time, arg_gamestate)
	local var_state = provisionalTry()
	local var_tryPos = var_state.tryPosition
	local var_players = {}

	for iter_0, iter_1 in ipairs(var_state.players or {}) do
		local var_object = arg_gameobjects:getGameObject(iter_1.id)

		if var_object then
			table.insert(var_players, {
				object = var_object,
				pos = iter_1.pos
			})
		end
	end

	if #var_players == 0 then
		for iter_2, iter_3 in arg_gameobjects:activeObjects(playertype.TypeId) do
			table.insert(var_players, {
				object = iter_3,
				pos = native.vec2(iter_3.pos.x, iter_3.pos.y)
			})
		end
	end

	var_tryPos = var_tryPos or var_players[1] and var_players[1].pos or native.vec2(0, 0)

	local var_officials = {}
	local var_refereeId = arg_gamestate:getOfficialEntity():getRefereesIds()
	local var_touchJudges = 0
	local var_touchJudgeX = native.clamp1(var_tryPos.x, -rulesenvironment.halfFieldLength, rulesenvironment.halfFieldLength)

	var_touchJudgeX = var_touchJudgeX - (var_touchJudgeX >= 0 and 1 or -1) * ProvisionalTryTouchJudgeInfield

	for iter_4, iter_5 in arg_gameobjects:activeObjects(umpiretype.TypeId) do
		if iter_4 == var_refereeId then
			table.insert(var_officials, native.vec2(iter_5.pos.x, iter_5.pos.y))
		else
			local var_sideY = var_touchJudges % 2 == 0 and 1 or -1
			local var_y = var_sideY * (rulesenvironment.halfFieldWidth + ProvisionalTryTouchJudgeOffField)

			var_touchJudges = var_touchJudges + 1

			iter_5:resetTo(native.vec2(var_touchJudgeX, var_y), native.vec2(0, -var_sideY), arg_time)
		end
	end

	local var_maxX = rulesenvironment.deadBallLine - 1
	local var_maxY = rulesenvironment.halfFieldWidth - 1

	for iter_6 = 1, ProvisionalTrySpreadPasses do
		for iter_7 = 1, #var_players do
			local var_a = var_players[iter_7]

			for iter_8 = iter_7 + 1, #var_players do
				local var_b = var_players[iter_8]
				local var_offset = var_b.pos - var_a.pos
				local var_dist = native.length2(var_offset)

				if var_dist < ProvisionalTrySpacing then
					local var_angle = (iter_7 * 7 + iter_8 * 13) % 360 * math.pi / 180
					local var_dir = var_dist > 0.01 and var_offset * (1 / var_dist) or native.vec2(math.cos(var_angle), math.sin(var_angle))
					local var_push = var_dir * ((ProvisionalTrySpacing - var_dist) * 0.5)

					var_a.pos = var_a.pos - var_push
					var_b.pos = var_b.pos + var_push
				end
			end

			for iter_9, iter_10 in ipairs(var_officials) do
				local var_angle = iter_7 * 37 % 360 * math.pi / 180

				var_a.pos = provisionalTryPushOut(var_a.pos, iter_10, ProvisionalTryRefClearance, native.vec2(math.cos(var_angle), math.sin(var_angle))) or var_a.pos
			end

			var_a.pos = native.vec2(native.clamp1(var_a.pos.x, -var_maxX, var_maxX), native.clamp1(var_a.pos.y, -var_maxY, var_maxY))
		end
	end

	for iter_11, iter_12 in ipairs(var_players) do
		local var_toTry = var_tryPos - iter_12.pos
		local var_facing = native.length2(var_toTry) > 0.5 and native.normalize2(var_toTry) or iter_12.object.facing

		iter_12.object:resetTo(iter_12.pos, var_facing, arg_time)
	end

	provisionalTryLog(string.format("review: spread %d players around the try, referee kept clear, %d touch judges sent to the touchlines", #var_players, var_touchJudges))
end

rulestateclass.rulestateclass("TryDecisionPendingRuleState", function(arg_1_0, arg_1_1)
	for iter_1_0, iter_1_1 in pairs(TryDecisionPendingRuleState.MemberDefinitions) do
		arg_1_0[iter_1_0] = arg_1_1[iter_1_0]
	end
end).MemberDefinitions = {
	nextState = types.RuleState,
	isSuccessfulTry = types.Boolean,
	scoreTime = types.Number,
	provisionalTry = types.Nilable(types.Boolean),
	knockOnPosition = types.Nilable(types.Vec2)
}

function TryDecisionPendingRuleState.wipe(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7)
	return
end

function TryDecisionPendingRuleState.onEnterSolid(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10)
	arg_3_0.skipStateMixin = arg_3_3.skipStateProvider:createMixinFromConfig("Default")

	local var_3_0 = arg_3_3.hud
	local var_3_1 = var_3_0 and var_3_0:getElement("videoRef")

	if var_3_1 then
		var_3_1:show()
		var_3_1:SetVisualKey("Default")
	end

	local var_3_2 = arg_3_6:getTryDecisionPendingEntity()

	if var_3_2.decisionPending and var_3_2.outcome == native.ETryAttemptOutcome.Try and arg_3_0.isSuccessfulTry then
		local var_3_3 = var_3_2.scoringSide
		local var_3_4 = VERIFY(arg_3_5:getSide(var_3_3))
		local var_3_5 = var_3_2.scorerId

		arg_3_0.scorerId = var_3_5

		local var_3_6 = var_3_4.assetIdMap[var_3_5]

		ASSERT(var_3_6)
		arg_3_10:add(score_request.ScoreRequest({
			scoreTime = arg_3_0.scoreTime,
			scoringSide = var_3_3,
			scorerId = var_3_5,
			scorerAssetId = var_3_6,
			scoreType = var_3_2.scoreType:toInt(),
			gamerId = var_3_2.gamerId
		}))
	end

	local var_3_7 = var_3_0 and var_3_0.featureStack

	if var_3_7 then
		var_3_7:push("videoRef")

		arg_3_0.videoRefHud = var_3_0:getElement("videoRef")
	end

	arg_3_0.timer = 0

	-- bunker-overturned-try: call the knock-on that was held back when the try was awarded.
	-- It goes before the decision event: the referee listener's knock-on handler clears
	-- the referee's queued calls, which would otherwise include the "No try".
	if arg_3_0.provisionalTry then
		provisionalTryLog("decision pending: NO TRY" .. (arg_3_0.knockOnPosition and ", calling knock-on" or ""))

		if arg_3_0.knockOnPosition then
			table.insert(arg_3_9, {
				isDoubleKnockOn = false,
				decisionPending = false,
				type = "KnockOnEvent",
				side = var_3_2.scoringSide,
				position = arg_3_0.knockOnPosition,
				offenderId = var_3_2.scorerId,
				time = arg_3_8
			})
		end
	end
end

function TryDecisionPendingRuleState.onExitSolid(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7, arg_4_8, arg_4_9, arg_4_10)
	if arg_4_0.isSuccessfulTry then
		local var_4_0 = {
			isSuccessfulTry = arg_4_0.isSuccessfulTry,
			scorerId = arg_4_0.scorerId
		}

		arg_4_10:add(posttrydecision_request.PostTryDecisionRequest(var_4_0))
	end

	if arg_4_0.videoRefHud then
		arg_4_0.videoRefHud:hide()
	end

	-- bunker-overturned-try
	if arg_4_0.provisionalTry then
		local var_p_0 = provisionalTry()

		var_p_0.players = nil
		var_p_0.tryPosition = nil
		var_p_0.points = nil
		var_p_0.side = nil
		var_p_0.replayPending = nil
	end

	arg_4_0.skipStateMixin:release()
	arg_4_1.universe:useVideoRefToneMap(false)

	local var_4_1 = arg_4_3.hud
	local var_4_2 = var_4_1 and var_4_1.featureStack

	if var_4_2 then
		var_4_2:removeState("videoRef")
	end
end

function TryDecisionPendingRuleState.updateSolid(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7, arg_5_8, arg_5_9, arg_5_10, arg_5_11)
	if arg_5_0.skipStateMixin:checkForSkip() and not arg_5_0.sentRuleStateRequest and arg_5_3.network:isMaster() then
		arg_5_0.sentRuleStateRequest = true

		arg_5_11:addRuleStateRequest(arg_5_0.nextState, arg_5_4:alloc())
	end

	if not arg_5_0.kickedOffTryNoTry then
		arg_5_0.kickedOffTryNoTry = true

		arg_5_0.videoRefHud:setDecision(arg_5_0.isSuccessfulTry and "Try" or "NoTry")

		local var_5_0 = arg_5_3.soundSystem

		if var_5_0 then
			var_5_0:queueSoundOnlyEvent({
				type = "VideoRefereeDecisionEvent",
				isTry = arg_5_0.isSuccessfulTry,
				time = arg_5_9
			})
		end

		return
	elseif arg_5_0.timer > 8 then
		arg_5_0.skipStateMixin:skip()
	end

	-- bunker-overturned-try: take the provisional points off as NO TRY shows.
	if arg_5_0.provisionalTry and not arg_5_0.removedProvisionalPoints and arg_5_0.timer >= ProvisionalTryRemovePointsTime then
		arg_5_0.removedProvisionalPoints = true
		provisionalTry().points = nil

		provisionalTryLog("decision shown, points removed")
	end

	print("WARN: This rulestate used to play an animation but has been replaced with a timer.")

	arg_5_0.timer = arg_5_0.timer + arg_5_8
end

-- bunker-overturned-try: entered after the provisional try's celebration. Its wipe is the
-- barrier that plays the try replay (queued at the start of the celebration); then it hands
-- straight to the referee cameo that sends the try upstairs.
rulestateclass.rulestateclass("ProvisionalTryReviewRuleState", function(arg_6_0, arg_6_1)
	for iter_6_0, iter_6_1 in pairs(ProvisionalTryReviewRuleState.MemberDefinitions) do
		arg_6_0[iter_6_0] = arg_6_1[iter_6_0]
	end
end).MemberDefinitions = {
	nextState = types.RuleState
}
ProvisionalTryReviewRuleState.HidePlayerMarkers = true
ProvisionalTryReviewRuleState.HideBallMarkers = true

function ProvisionalTryReviewRuleState.wipe(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7)
	local var_7_0, var_7_1 = pcall(provisionalTrySpreadPlayers, arg_7_6, arg_7_7, arg_7_5)

	if not var_7_0 then
		provisionalTryLog("review: spreading players failed: " .. tostring(var_7_1))
	end
end

function ProvisionalTryReviewRuleState.apply(arg_8_0, arg_8_1, arg_8_2)
	matchtime.updateTime(arg_8_1, arg_8_2)
	matchtime.startStoppageTime(arg_8_1, arg_8_2)
end

function ProvisionalTryReviewRuleState.onEnterSolid(arg_9_0, arg_9_1, arg_9_2, arg_9_3, arg_9_4, arg_9_5, arg_9_6, arg_9_7, arg_9_8, arg_9_9, arg_9_10)
	provisionalTry().replayPending = nil

	provisionalTryLog("review: try replay done, sending it upstairs")
end

function ProvisionalTryReviewRuleState.updateSolid(arg_10_0, arg_10_1, arg_10_2, arg_10_3, arg_10_4, arg_10_5, arg_10_6, arg_10_7, arg_10_8, arg_10_9, arg_10_10, arg_10_11)
	if not arg_10_0.sentRuleStateRequest and arg_10_3.network:isMaster() then
		arg_10_0.sentRuleStateRequest = true

		arg_10_11:addRuleStateRequest(arg_10_0.nextState, arg_10_4:alloc())
	end
end
