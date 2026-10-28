import("base.rulestate.rulestateclass")
import("core.marshalling.types")
import("game.scoring.score_request")
import("rules.try.posttrydecision_request")
import("rules.match.matchtime")
import("game.player.playertype")
import("game.umpire.umpiretype")
import("script-config.rules.rules.rulesenvironment")
import("core.foundation.class")
import("game.humanoid.humanoidtype")
import("game.cutscenes.cutsceneplayevent_request")

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

-- bunker-broadcast-decision (see mods/bunker-broadcast-decision/README.md). Runs when the
-- video-referee cameo published BunkerBroadcastState (refereecameo_rulestate.lua):
--   * the decision card stays up BunkerDecisionHoldTime instead of the stock 8 s;
--   * VideoRefereeDecisionEvent carries bunkerBroadcast + scoringSide, so the referee and
--     music listeners add the try whistle and the try music;
--   * leaving it, the RL26 logo wipe covers the cut (LogoTransitionHud.bunkerCoverCut in
--     replay-team-stinger's logotransition_hud.lua; the request waits up to
--     BunkerCoverTimeout for it), and the next state is a try celebration (TRY) or
--     BunkerNoTryReactionRuleState (NO TRY), which then hand on to the stock nextState.
local BunkerDecisionHoldTime = 6.5
local BunkerCoverTimeout = 1.5
-- The reaction shot: the captain's challenge "lost" cutscene (referee, the captain and two
-- team-mates of BunkerNoTryReactionRuleState.reactingSide). Its animset loads on demand.
local BunkerNoTryReactionCutscene = "rl1_captains_challenge_lose_01"
-- false = NO TRY goes straight to the stock restart (still behind the logo wipe).
local BunkerNoTryReactionEnabled = true
local BunkerNoTryReactionTimeout = 12

local function bunkerLog(arg_text)
	local var_log = rawget(_G, "BunkerBroadcastLog")

	if var_log then
		var_log(arg_text)
	end
end

local function bunkerFollowUpState(arg_self, arg_guidManager, arg_gameobjects)
	if arg_self.isSuccessfulTry then
		local var_scorer = arg_self.bunkerScorer

		if var_scorer == nil or not arg_gameobjects:getGameObject(var_scorer) then
			return arg_self.nextState, "stock (scorer not found)"
		end

		return class.instantiate("BunkerTryCelebrateRuleState", {
			queueReplay = false,
			quickCutToCutscene = false,
			playerIsOnGround = false,
			nextState = arg_self.nextState,
			scorer = var_scorer,
			randomSeed = native.Random.FromSystemTime():nextAsSeed(),
			guid = arg_guidManager:alloc()
		}), "try celebration"
	end

	if not BunkerNoTryReactionEnabled then
		return arg_self.nextState, "stock restart (reaction shot off)"
	end

	return class.instantiate("BunkerNoTryReactionRuleState", {
		nextState = arg_self.nextState,
		reactingSide = arg_self.bunkerSide,
		guid = arg_guidManager:alloc()
	}), "no-try reaction"
end

-- Kicks the stinger over the decision card once, then true when the cut can go.
local function bunkerDecisionCovered(arg_self, arg_params, arg_services, arg_dt)
	if not arg_self.bunkerCoverKicked then
		arg_self.bunkerCoverKicked = true

		local var_ok, var_result = pcall(function()
			local var_logo = arg_services.hud and arg_services.hud:getElement("logotransition")

			if not var_logo then
				return "missing"
			end

			-- TRY: the scoring team's stinger, falling back to the logo wipe.
			if arg_self.isSuccessfulTry and var_logo.bunkerTeamCoverCut and var_logo:bunkerTeamCoverCut(arg_self.bunkerSide, arg_params and arg_params.universe) then
				arg_self.bunkerCover = var_logo
				arg_self.bunkerCoverTeam = true

				return "skipped, team stinger kicked"
			end

			if var_logo:bunkerCoverCut(arg_params and arg_params.universe) then
				arg_self.bunkerCover = var_logo

				return "kicked"
			end

			return "busy, cutting without it"
		end)

		bunkerLog("decision: leaving, logo wipe " .. (var_ok and tostring(var_result) or "error: " .. tostring(var_result)))
	end

	local var_stinger = arg_self.bunkerCover

	if not var_stinger then
		return true
	end

	arg_self.bunkerCoverWait = (arg_self.bunkerCoverWait or 0) + arg_dt

	local var_ok, var_covered = pcall(arg_self.bunkerCoverTeam and var_stinger.bunkerTeamIsCovered or var_stinger.bunkerIsCovered, var_stinger)

	return not var_ok or var_covered or arg_self.bunkerCoverWait >= BunkerCoverTimeout
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

	-- bunker-broadcast-decision: the cameo decided whether the presentation runs.
	local var_b_0 = rawget(_G, "BunkerBroadcastState")

	if var_b_0 then
		arg_3_0.bunkerBroadcast = true
		arg_3_0.bunkerSide = var_b_0.side
		arg_3_0.bunkerScorer = var_b_0.scorerId

		bunkerLog("decision pending: " .. (arg_3_0.isSuccessfulTry and "TRY" or "NO TRY") .. ", next " .. tostring(type(arg_3_0.nextState)))
	end

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

	-- bunker-broadcast-decision
	if arg_4_0.bunkerBroadcast then
		rawset(_G, "BunkerBroadcastState", nil)
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
		-- bunker-broadcast-decision: leave behind the stinger instead (below).
		if arg_5_0.bunkerBroadcast then
			arg_5_0.bunkerLeaving = true
		else
			arg_5_0.sentRuleStateRequest = true

			arg_5_11:addRuleStateRequest(arg_5_0.nextState, arg_5_4:alloc())
		end
	end

	-- bunker-broadcast-decision
	if arg_5_0.bunkerLeaving and not arg_5_0.sentRuleStateRequest and bunkerDecisionCovered(arg_5_0, arg_5_1, arg_5_3, arg_5_8) then
		arg_5_0.sentRuleStateRequest = true

		local var_b_0, var_b_1, var_b_2 = pcall(bunkerFollowUpState, arg_5_0, arg_5_4, arg_5_7)

		if not var_b_0 then
			var_b_1, var_b_2 = arg_5_0.nextState, "stock (error: " .. tostring(var_b_1) .. ")"
		end

		bunkerLog("decision: on to the " .. tostring(var_b_2))
		arg_5_11:addRuleStateRequest(var_b_1, arg_5_4:alloc())
	end

	if not arg_5_0.kickedOffTryNoTry then
		arg_5_0.kickedOffTryNoTry = true

		arg_5_0.videoRefHud:setDecision(arg_5_0.isSuccessfulTry and "Try" or "NoTry")

		local var_5_0 = arg_5_3.soundSystem

		if var_5_0 then
			-- bunker-broadcast-decision: bunkerBroadcast/scoringSide are read by the referee
			-- (whistle) and in-game music (try music) listeners.
			var_5_0:queueSoundOnlyEvent({
				type = "VideoRefereeDecisionEvent",
				isTry = arg_5_0.isSuccessfulTry,
				bunkerBroadcast = arg_5_0.bunkerBroadcast,
				scoringSide = arg_5_0.bunkerSide,
				time = arg_5_9
			})
		end

		return
	elseif arg_5_0.timer > (arg_5_0.bunkerBroadcast and BunkerDecisionHoldTime or 8) then
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

-- bunker-broadcast-decision: the celebration after a bunker TRY. It plays the stock
-- TryCelebrateRuleState (signature celebrations and team-coaches' coach reaction included),
-- but leaves the players idle. The stock updateSolid switches everyone to "TeamScored" and
-- sends their react-to-score controllers to "finalMove". After the bunker their targets are
-- stale (set before the replay and decision), so the players off camera ran off across the
-- field during the celebration.
local function tryCelebrateClass()
	return import("rules.cutscenes.trycelebrate_rulestate").TryCelebrateRuleState
end

rulestateclass.rulestateclass("BunkerTryCelebrateRuleState", function(arg_15_0, arg_15_1)
	for iter_15_0, iter_15_1 in pairs(BunkerTryCelebrateRuleState.MemberDefinitions) do
		arg_15_0[iter_15_0] = arg_15_1[iter_15_0]
	end
end).MemberDefinitions = {
	nextState = types.RuleState,
	scorer = types.ObjectId,
	randomSeed = types.SignedInteger,
	quickCutToCutscene = types.Boolean,
	playersWithinRange = types.Nilable(types.Array(types.ObjectId)),
	queueReplay = types.Boolean,
	playerIsOnGround = types.Boolean,
	guid = types.Guid
}
BunkerTryCelebrateRuleState.HideBallMarkers = true
BunkerTryCelebrateRuleState.HidePlayerMarkers = true

function BunkerTryCelebrateRuleState.onEnterSolid(arg_16_0, arg_16_1, arg_16_2, arg_16_3, arg_16_4, arg_16_5, arg_16_6, arg_16_7, arg_16_8, arg_16_9, arg_16_10)
	for iter_16_0, iter_16_1 in arg_16_7:activeObjects(playertype.TypeId) do
		iter_16_1:setBehaviour("Idle", arg_16_8)
	end

	bunkerLog("try celebration: players idle, playing the celebration")

	return tryCelebrateClass().onEnterSolid(arg_16_0, arg_16_1, arg_16_2, arg_16_3, arg_16_4, arg_16_5, arg_16_6, arg_16_7, arg_16_8, arg_16_9, arg_16_10)
end

function BunkerTryCelebrateRuleState.onExitSolid(arg_17_0, ...)
	return tryCelebrateClass().onExitSolid(arg_17_0, ...)
end

function BunkerTryCelebrateRuleState.updateSolid(arg_18_0, arg_18_1, arg_18_2, arg_18_3, arg_18_4, arg_18_5, arg_18_6, arg_18_7, arg_18_8, arg_18_9, arg_18_10, arg_18_11)
	return
end

-- bunker-broadcast-decision: the disappointed reaction after a NO TRY, played the way
-- CaptainsChallengeOutcomeCutsceneRulestate plays its "lost" cutscene (without touching the
-- challenge count or HUD). Hands on to the stock restart when it finishes, or after
-- BunkerNoTryReactionTimeout if it never does.
rulestateclass.rulestateclass("BunkerNoTryReactionRuleState", function(arg_11_0, arg_11_1)
	for iter_11_0, iter_11_1 in pairs(BunkerNoTryReactionRuleState.MemberDefinitions) do
		arg_11_0[iter_11_0] = arg_11_1[iter_11_0]
	end
end).MemberDefinitions = {
	nextState = types.RuleState,
	reactingSide = types.SignedInteger,
	guid = types.Guid
}
BunkerNoTryReactionRuleState.HidePlayerMarkers = true
BunkerNoTryReactionRuleState.HideBallMarkers = true

-- A barrier in front of the cutscene, exactly like CaptainsChallengeOutcomeCutsceneRulestate
-- (its pre-wipe flushes finished cutscenes and their animsets before this one loads). The
-- logo wipe from the decision card hides it.
function BunkerNoTryReactionRuleState.wipe(arg_12_0, arg_12_1, arg_12_2, arg_12_3, arg_12_4, arg_12_5, arg_12_6, arg_12_7)
	return
end

function BunkerNoTryReactionRuleState.onEnterSolid(arg_13_0, arg_13_1, arg_13_2, arg_13_3, arg_13_4, arg_13_5, arg_13_6, arg_13_7, arg_13_8, arg_13_9, arg_13_10)
	local var_13_0 = native.createTable(64, 0)

	for iter_13_0, iter_13_1 in arg_13_7:activeObjects(humanoidtype.TypeId) do
		table.insert(var_13_0, iter_13_0)
	end

	arg_13_10:add(cutsceneplayevent_request.CutscenePlayEventRequest({
		ignoreSkipMixins = true,
		guid = arg_13_0.guid:derive(arg_13_0.reactingSide),
		cutsceneName = BunkerNoTryReactionCutscene,
		targetIds = var_13_0,
		hideIds = var_13_0,
		primarySide = arg_13_0.reactingSide,
		onFinished = function()
			arg_13_0.readyToProceed = true
		end
	}))

	arg_13_0.timer = 0

	bunkerLog("no-try reaction: " .. BunkerNoTryReactionCutscene .. " for side " .. tostring(arg_13_0.reactingSide))
end

function BunkerNoTryReactionRuleState.updateSolid(arg_14_0, arg_14_1, arg_14_2, arg_14_3, arg_14_4, arg_14_5, arg_14_6, arg_14_7, arg_14_8, arg_14_9, arg_14_10, arg_14_11)
	arg_14_0.timer = arg_14_0.timer + arg_14_8

	if arg_14_0.sentRuleStateRequest or not arg_14_3.network:isMaster() then
		return
	end

	if arg_14_0.readyToProceed or arg_14_0.timer >= BunkerNoTryReactionTimeout then
		arg_14_0.sentRuleStateRequest = true

		if not arg_14_0.readyToProceed then
			bunkerLog("no-try reaction: timed out")
		end

		arg_14_11:addRuleStateRequest(arg_14_0.nextState, arg_14_4:alloc())
	end
end
