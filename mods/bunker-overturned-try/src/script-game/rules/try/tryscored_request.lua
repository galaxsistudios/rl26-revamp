import("core.marshalling.types")
import("core.requestmodel.request")
import("rules.try.tryoutcome")
import("game.scoring.score_request")
import("game.scoring.scoretypes")

local var_0_0 = native.CSimulationRequest

-- bunker-overturned-try: shared state, see rules/try/tryattemptoutcomes.lua.
local function provisionalTry()
	local var_state = rawget(_G, "ProvisionalTryState")

	if not var_state then
		var_state = {}

		rawset(_G, "ProvisionalTryState", var_state)
	end

	return var_state
end

request.requestclass("TryScoredRequest", var_0_0, function(arg_1_0, arg_1_1)
	var_0_0.init(arg_1_0)

	for iter_1_0, iter_1_1 in pairs(TryScoredRequest.MemberDefinitions) do
		arg_1_0[iter_1_0] = arg_1_1[iter_1_0]
	end

	if ENABLE_LOGGING then
		printMiniStack("[TryScoredRequest] scorer: %d, scoringSide: %d, gamerId: %t", arg_1_0.scorer, arg_1_0.scoringSide, arg_1_0.gamerId)
	end
end).MemberDefinitions = {
	assetId = types.SignedInteger,
	attemptGuid = types.Nilable(types.Guid),
	scorer = types.ObjectId,
	scoringSide = types.Team,
	scoringPosition = types.Vec2,
	diveOnLooseBall = types.Boolean,
	divingTry = types.Boolean,
	tryAttemptOutcome = types.TryAttemptOutcome,
	currentTackleCount = types.Number,
	tackleSetStartPosition = types.Vec2,
	canEndCurrentPeriod = types.Boolean,
	videoRefereeRequired = types.Boolean,
	isKnockOn = types.Boolean,
	gamerId = types.Nilable(types.GamerId),
	isBonusTry = types.Boolean,
	scoreTime = types.Number,
	isDropDownTry = types.Boolean,
	provisionalTry = types.Nilable(types.Boolean)
}

function TryScoredRequest.validate(arg_2_0, arg_2_1, arg_2_2, arg_2_3)
	-- bunker-overturned-try: a held-up tackle's provisional try is issued after the ball is dead.
	if arg_2_0.provisionalTry then
		return true
	end

	local var_2_0 = arg_2_2:getMatchProgressionEntity().ballIsDead
	local var_2_1 = false
	local var_2_2 = arg_2_2:getAdvantageEntity()

	if var_2_2.isActive then
		var_2_1 = var_2_2.advantageSide ~= arg_2_0.scoringSide
	end

	return not var_2_0 and not var_2_1
end

function TryScoredRequest.apply(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4)
	local var_3_0 = arg_3_0.scorer

	ASSERT(var_3_0)

	local var_3_1 = arg_3_0.assetId

	ASSERT(var_3_1)

	local var_3_2 = arg_3_0.gamerId
	local var_3_3 = arg_3_0.scoringSide

	ASSERT(var_3_3)

	local var_3_4 = arg_3_0.scoringPosition

	ASSERT(var_3_4)

	local var_3_5 = arg_3_0.videoRefereeRequired

	ASSERT(var_3_5 ~= nil)

	local var_3_6 = arg_3_0.tryAttemptOutcome

	ASSERT(var_3_6)

	local var_3_7 = var_3_6 == native.ETryAttemptOutcome.PenaltyTry

	ASSERT(var_3_7 ~= nil)

	local var_3_8 = arg_3_0.isBonusTry

	ASSERT(var_3_8 ~= nil)

	local var_3_9 = arg_3_0.diveOnLooseBall

	ASSERT(var_3_9 ~= nil)

	local var_3_10 = arg_3_0.divingTry

	ASSERT(var_3_10 ~= nil)

	local var_3_11 = var_3_9 or var_3_10

	ASSERT(var_3_11 ~= nil)

	local var_3_12 = arg_3_0.currentTackleCount

	ASSERT(var_3_12)

	local var_3_13 = var_3_12 > 0

	ASSERT(var_3_13 ~= nil)

	local var_3_14 = tryoutcome.successfulTryOutcomes[var_3_6]

	ASSERT(var_3_14 ~= nil)

	local var_3_15 = not var_3_14

	ASSERT(var_3_15 ~= nil)

	local var_3_16 = arg_3_0.isDropDownTry

	ASSERT(arg_3_1)

	-- bunker-overturned-try: listeners see a clean try (commentary, TRY banner, crowd,
	-- music, props), but unsuccessfulAttempt stays true so stats don't count it, and the
	-- decision-pending entity below is still filled in for the bunker.
	local var_p_0 = arg_3_0.provisionalTry

	if var_p_0 then
		local var_p_1 = provisionalTry()

		var_p_1.side = var_3_3
		var_p_1.points = var_3_8 and 5 or 4
		var_p_1.replayPending = true
		var_p_1.outroReleased = nil

		if var_p_1.log then
			var_p_1.log(string.format("try scored: side %s shows +%d, scorer %s", tostring(var_3_3), var_p_1.points, tostring(var_3_0)))
		end
	end
	table.insert(arg_3_3, {
		type = "TryScoredEvent",
		attemptGuid = arg_3_0.attemptGuid,
		scorer = var_3_0,
		scoringSide = var_3_3,
		scoringPosition = var_3_4,
		isPenaltyTry = var_3_7,
		tryAttemptOutcome = var_p_0 and native.ETryAttemptOutcome.Try or var_3_6,
		diveOnLooseBall = arg_3_0.diveOnLooseBall,
		divingTry = arg_3_0.divingTry,
		unsuccessfulAttempt = var_3_15,
		videoRefereeRequired = var_3_5 and not var_p_0,
		provisionalTry = var_p_0,
		time = arg_3_1,
		gamerId = var_3_2,
		isBonusTry = var_3_8,
		isDropDownTry = var_3_16
	})

	local var_3_17 = var_3_8 and scoretypes.BonusTry or scoretypes.Try

	ASSERT(var_3_17)

	if not var_3_5 and var_3_14 then
		score_request.ScoreRequest({
			scoreTime = arg_3_0.scoreTime,
			scoringSide = var_3_3,
			scorerId = var_3_0,
			scorerAssetId = var_3_1,
			scoreType = var_3_17,
			gamerId = var_3_2
		}):apply(arg_3_1, arg_3_2, arg_3_3, arg_3_4)
	end

	local var_3_18 = var_3_5

	if var_3_5 then
		local var_3_19 = arg_3_2:getTryDecisionPendingEntity()
		local var_3_20 = var_3_8 and scoretypes.BonusTry or scoretypes.Try

		var_3_19.decisionPending = true
		var_3_19.outcome = var_3_6
		var_3_19.scoreType = native.EScoreType[var_3_20]
		var_3_19.scoringSide = var_3_3
		var_3_19.scorerId = var_3_0
		var_3_19.gamerId = var_3_2
	end

	-- bunker-overturned-try: the knock-on is called with the NO TRY decision instead
	-- (trydecisionpending_rulestate.lua), not while the try is being awarded.
	if arg_3_0.isKnockOn and not var_p_0 then
		table.insert(arg_3_3, {
			isDoubleKnockOn = false,
			type = "KnockOnEvent",
			side = var_3_3,
			position = var_3_4,
			restartPosition = arg_3_0.restartPosition,
			decisionPending = var_3_18,
			offenderId = var_3_0,
			time = arg_3_1
		})
	end
end
