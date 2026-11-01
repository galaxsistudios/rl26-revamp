import("ai.tackle.initialtackle_request")
import("ai.tackle.tackleintent_request")
import("base.action.action")
import("base.action.action_request")
import("base.event.eventoccurred_request")
import("base.side.sidehelper")
import("core.foundation.func")
import("design.tryarea_cconfig")
import("game.ball.disposal_request")

local var_0_0 = load("design.tackle.tackle_config")
local var_0_1 = var_0_0.tackleeBlockTypeActions
local var_0_2 = var_0_0.tacklerBlockTypeActions
local var_0_3 = var_0_0.kickInTackleActionNameMap
local var_0_4 = var_0_0.kickInBigHittedActionNameMap

Class("TackleArbitrator", function(arg_1_0, arg_1_1)
	return
end)

function TackleArbitrator.registerWithMatchSim(arg_2_0, arg_2_1)
	arg_2_1:addGlobalArbitrator("initialTackleArbitrator", arg_2_0)
	arg_2_1:registerOnPreWipe(func.bindmethod(arg_2_0, arg_2_0.onPreWipe))
	arg_2_1:registerOnPostWipe(func.bindmethod(arg_2_0, arg_2_0.onPostWipe))
end

function TackleArbitrator.onPostWipe(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	return
end

function TackleArbitrator.onPreWipe(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7, arg_4_8, arg_4_9, arg_4_10, arg_4_11)
	for iter_4_0, iter_4_1 in arg_4_8:getTackleIntentPool():iter() do
		iter_4_1:clear()
	end
end

function TackleArbitrator.update(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7, arg_5_8, arg_5_9)
	local var_5_0 = arg_5_5:getMatchProgressionEntity().attackingSide
	local var_5_1 = sidehelper.getOtherSide(var_5_0)
	local var_5_2 = arg_5_2.knowledgeBank
	local var_5_3 = var_5_2.playerTackleArbitrationKnowledgePool

	for iter_5_0, iter_5_1 in var_5_2.teamPlayerIdListPair:get(var_5_1):iter() do
		local var_5_4 = var_5_3:get(iter_5_1)

		if var_5_4.success then
			local var_5_5 = var_5_4.bestTackleInfo

			arg_5_0:processSuccessfulTackle(arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7, arg_5_9, var_5_5)

			return
		end
	end
end

function TackleArbitrator.processSuccessfulTackle(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8, arg_6_9)
	local var_6_0 = arg_6_3:alloc()
	local var_6_1 = arg_6_3:alloc()
	local var_6_2 = arg_6_9.animGroupIndex
	local var_6_3 = arg_6_9.tackleBlockType

	if var_6_3 == native.ETackleBlockType.Fend then
		if arg_6_9.mechanic ~= native.CGameplayMechanic.Fend then
			var_6_3 = native.ETackleBlockType.Contact
		end
	elseif var_6_3 == native.ETackleBlockType.SideStep then
		if arg_6_9.mechanic ~= native.CGameplayMechanic.SideStep then
			var_6_3 = native.ETackleBlockType.Contact
		end
	elseif var_6_3 == native.ETackleBlockType.FakePass then
		if arg_6_9.mechanic ~= native.CGameplayMechanic.FakePass then
			var_6_3 = native.ETackleBlockType.Contact
		end
	elseif var_6_3 == native.ETackleBlockType.HitUp then
		if arg_6_9.mechanic ~= native.CGameplayMechanic.HitUp then
			var_6_3 = native.ETackleBlockType.Contact
		end
	elseif var_6_3 == native.ETackleBlockType.GooseStep then
		if arg_6_9.mechanic ~= native.CGameplayMechanic.GooseStep then
			var_6_3 = native.ETackleBlockType.Dive
		end
	elseif var_6_3 == native.ETackleBlockType.AnkleTap then
		if arg_6_9.mechanic ~= native.CGameplayMechanic.AnkleTap then
			var_6_3 = native.ETackleBlockType.Dive
		end
	elseif var_6_3 == native.ETackleBlockType.BigHit then
		if arg_6_9.mechanic ~= native.CGameplayMechanic.BigHit then
			var_6_3 = native.ETackleBlockType.Contact
		end
	elseif var_6_3 == native.ETackleBlockType.Dive then
		if arg_6_9.mechanic == native.CGameplayMechanic.AnkleTap then
			var_6_3 = native.ETackleBlockType.AnkleTap
		elseif arg_6_9.mechanic == native.CGameplayMechanic.GooseStep then
			var_6_3 = native.ETackleBlockType.GooseStep
		end
	end

	local var_6_4 = arg_6_2.actionProducer:getTackleContainer():getTackleAnimGroupByIndex(var_6_3, var_6_2)
	local var_6_5 = var_6_4.isMirrored
	local var_6_6 = var_6_4:canLoop()
	local var_6_7 = arg_6_9:getParticipantInfo(native.ETackleParticipantType.BallCarrier)
	local var_6_8 = var_6_7.id

	if arg_6_5:getActiveTackleEntity():getTackleForTackleeId(var_6_8) then
		return
	end

	local var_6_9 = arg_6_9:getParticipantInfo(native.ETackleParticipantType.Tackler1)
	local var_6_10 = arg_6_9:getParticipantInfo(native.ETackleParticipantType.Tackler2)
	local var_6_11 = arg_6_9.direction
	local var_6_12 = arg_6_9.startTime
	local var_6_13 = arg_6_9.blockDuration
	local var_6_14 = arg_6_9.playRate
	local var_6_15 = arg_6_9.arbitrationResult
	local var_6_16 = var_6_15.winnerId

	ASSERT(var_6_16)

	local var_6_17 = var_6_15.winnerMechanic
	local var_6_18 = var_6_15.winningMechanicResult
	local var_6_19 = arg_6_2.knowledgeBank.sidePool:get(var_6_16).side
	local var_6_20 = native.Time.FromSeconds(0)

	for iter_6_0, iter_6_1 in arg_6_9:iterParticipants() do
		if iter_6_1.valid then
			local var_6_21 = iter_6_1.startTime

			if var_6_20 < var_6_21 then
				var_6_20 = var_6_21
			end
		end
	end

	local var_6_22 = arg_6_4.matchInData.difficulty
	local var_6_23 = var_6_22 == native.EDifficulty.Hardest and 5 or 0
	local var_6_24 = arg_6_6:getGameObject(var_6_7.id)
	local var_6_25 = var_6_24.side == 1 and arg_6_4.matchInData.home.playerTable[var_6_24.assetId] or arg_6_4.matchInData.away.playerTable[var_6_24.assetId]
	local var_6_26 = var_6_25:getBMI()
	local var_6_27 = var_6_25.skills:getOption("ballStrip")
	local var_6_28 = arg_6_6:getGameObject(var_6_9.id)
	local var_6_29 = var_6_28.side == 1 and arg_6_4.matchInData.home.playerTable[var_6_28.assetId] or arg_6_4.matchInData.away.playerTable[var_6_28.assetId]
	local var_6_30 = var_6_29:getBMI()
	local var_6_31 = var_6_29.skills:getOption("ballStrip")
	local var_6_32 = arg_6_1 and arg_6_1:getLocalGamer(1)
	local var_6_33 = var_6_32 and var_6_32.side or sidehelper.none
	local var_6_34 = var_6_28.side
	local var_6_35 = false
	local var_6_36 = false
	local var_6_37 = false
	local var_6_38 = false
	local var_6_39 = var_6_32 and var_6_32.objectId == var_6_28.id or false
	local var_6_40 = arg_6_2.hooks

	if var_6_40 then
		local var_6_41 = var_6_40 and var_6_40:getHook("TackleDebugHook")

		var_6_41:updateBallStripInfo(var_6_27, var_6_31, var_6_31 - var_6_27, var_6_26, var_6_30, var_6_30 - var_6_26, var_6_22, var_6_23, 30)
		var_6_41:updateBallStripResult(false, var_6_28)

		var_6_35 = var_6_41.forceAIAttempt and true or false
		var_6_36 = var_6_41.forceAISuccess and true or false
		var_6_37 = var_6_41.forceAISuccessAttempt and true or false
		var_6_38 = var_6_41.forceHumanSuccessAttempt and true or false
	end

	if var_6_3 ~= native.ETackleBlockType.SideStep and var_6_3 ~= native.ETackleBlockType.GooseStep and var_6_3 ~= native.ETackleBlockType.AnkleTap and var_6_3 ~= native.ETackleBlockType.BigHit then
		-- discipline-meter: a CPU tackler low on discipline can turn a legal tackle into an
		-- illegal one (rules/sinbin/sinbinsystem.lua decides penalty, bin or send-off). The high
		-- tackle flag is left alone because it also swaps the animation.
		local var_6_disc = rawget(_G, "DisciplineState")
		local var_6_illegal = arg_6_9.isIllegalTackle

		if var_6_disc and not arg_6_9.isHighTackle and not var_6_illegal then
			local var_6_disc_ok, var_6_disc_roll = pcall(var_6_disc.rollIllegalTackle, var_6_9.id, arg_6_1)

			var_6_illegal = var_6_disc_ok and var_6_disc_roll or false
		end

		local var_6_42 = var_6_7.startPosition
		local var_6_43 = {
			tackleBlockType = var_6_3:toInt(),
			ballCarrierId = var_6_8,
			tackler1Id = var_6_9.id,
			tackler2Id = var_6_10.id,
			ballCarrierBMI = var_6_26,
			ballCarrierBallStripSkill = var_6_27,
			tackler1BMI = var_6_30,
			tackler1BallStripSkill = var_6_31,
			difficultyMod = var_6_23,
			forceAIAttempt = var_6_35,
			forceAISuccess = var_6_36,
			forceAISuccessAttempt = var_6_37,
			forceHumanSuccessAttempt = var_6_38,
			gamerSide = var_6_33,
			tacklerSide = var_6_34,
			tackleGuid = var_6_0,
			blockGuid = var_6_1,
			direction = var_6_11,
			startPosition = var_6_42,
			startTime = var_6_12,
			barrierTime = var_6_20,
			blockDuration = var_6_13,
			animGroupIndex = var_6_2,
			playRate = var_6_14,
			winningSide = var_6_19,
			winningMechanic = var_6_17:toInt(),
			winningMechanicResult = var_6_18:toInt(),
			canLoop = var_6_6,
			isMirrored = var_6_5,
			isHighTackle = arg_6_9.isHighTackle,
			isIllegalTackle = var_6_illegal,
			isHumanTackle = var_6_39,
			gamerObjectId = var_6_32 and var_6_32.objectId or nil
		}

		arg_6_8:add(initialtackle_request.InitialTackleRequest(var_6_43))
	end

	local var_6_44 = {
		tackleQueryInfo = arg_6_9,
		tackleGuid = var_6_0,
		blockGuid = var_6_1
	}
	local var_6_45 = true

	for iter_6_2, iter_6_3 in arg_6_9:iterParticipants() do
		if iter_6_3.valid then
			local var_6_46 = iter_6_3.id
			local var_6_47 = iter_6_3.participantType

			ASSERT(var_6_46)

			if var_6_45 then
				ASSERT(var_6_47 == native.ETackleParticipantType.BallCarrier)

				var_6_45 = false
			end

			var_6_44.tackleAnimation, var_6_44.participantInfo = var_6_4:getParticipant(var_6_47):getTackleAnimation(), iter_6_3
			var_6_44.tackleBlockType = var_6_3
			var_6_44.ballCarrierId = var_6_8

			processTackleParticipant(arg_6_1, arg_6_2, arg_6_3, arg_6_5, arg_6_6, arg_6_7, arg_6_8, var_6_44, arg_6_4)
		end
	end
end

function processTackleParticipant(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7, arg_7_8)
	local var_7_0 = arg_7_7.tackleQueryInfo
	local var_7_1 = arg_7_7.participantInfo
	local var_7_2 = arg_7_7.tackleAnimation
	local var_7_3 = arg_7_7.tackleGuid
	local var_7_4 = arg_7_7.ballCarrierId

	ASSERT(var_7_0)
	ASSERT(var_7_1)
	ASSERT(var_7_2)
	ASSERT(var_7_3)

	local var_7_5 = var_7_0.blockDuration
	local var_7_6 = var_7_0.animGroupIndex
	local var_7_7 = var_7_2.bodyAnimName
	local var_7_8 = var_7_2.blendAnimName
	local var_7_9 = var_7_0.playRate
	local var_7_10 = arg_7_7.tackleBlockType
	local var_7_11 = var_7_0.mechanic
	local var_7_12 = var_7_1.id
	local var_7_13 = var_7_1.startPosition
	local var_7_14 = var_7_1.startFacing
	local var_7_15 = var_7_1.targetPosition
	local var_7_16 = var_7_1.targetFacing
	local var_7_17 = var_7_1.startTime
	local var_7_18 = var_7_1.targetTime
	local var_7_19 = var_7_1.isExit
	local var_7_20 = var_7_1.participantType
	local var_7_21 = var_7_20 == native.ETackleParticipantType.BallCarrier

	ASSERT(var_7_17 < var_7_18)

	local var_7_22 = native.CTackleActionParams()

	var_7_22.startPosition = var_7_13
	var_7_22.startFacing = var_7_14
	var_7_22.startTime = var_7_17
	var_7_22.targetPosition = var_7_15
	var_7_22.targetFacing = var_7_16
	var_7_22.targetTime = var_7_18
	var_7_22.endTime = var_7_17 + var_7_5
	var_7_22.animName = var_7_7
	var_7_22.disposalId = arg_7_2:alloc()
	var_7_22.playRate = var_7_9
	var_7_22.tackleGuid = var_7_3
	var_7_22.blockGuid = arg_7_7.blockGuid
	var_7_22.participantTypeIndex = var_7_20:toInt()
	var_7_22.isExitBlock = var_7_19
	var_7_22.isEnteringTackle = true

	local var_7_23 = false
	local var_7_24 = false
	local var_7_25 = false
	local var_7_26

	if var_7_21 then
		local var_7_27 = arg_7_4:getGameObject(var_7_12)

		ASSERT(var_7_27)

		local var_7_28 = var_7_27:getAction(arg_7_3)
		local var_7_29 = arg_7_1.knowledgeBank.playerCommittedCollectPool:get(var_7_12)

		var_7_24 = var_7_28 and var_7_28.IsCollect and var_7_29.collectActive

		local var_7_30 = var_7_18 + 0.03333333333333333
		local var_7_31 = var_7_27:getBlendAction(arg_7_3)

		if var_7_28 and var_7_28.IsKickInPlayAction then
			local var_7_32 = var_7_28.startTime
			local var_7_33 = var_7_28.kickAnimName

			var_7_22.kickAnimName = var_7_33

			local var_7_34 = arg_7_1.animationProvider
			local var_7_35 = var_7_32 + var_7_34:getEventFrame(var_7_33, "committed") / 30
			local var_7_36 = var_7_32 + var_7_34:getEventFrame(var_7_33, "detach_ball") / 30
			local var_7_37 = var_7_35 < var_7_30
			local var_7_38 = var_7_35 < var_7_30 and var_7_30 < var_7_36

			if var_7_37 then
				var_7_22.offsetFrameCount = (var_7_22.targetTime - var_7_22.startTime) * 30
				var_7_22.startTime = var_7_22.targetTime
				var_7_22.targetTime = var_7_22.targetTime + 0.03333333333333333
				var_7_22.startPosition = var_7_22.targetPosition
				var_7_22.startFacing = var_7_22.targetFacing
			end

			if var_7_38 then
				var_7_22.spillTime = var_7_35
				var_7_22.spillDisposalId = arg_7_2:alloc()
			end

			var_7_25 = var_7_37 and not var_7_38

			if not var_7_37 and not var_7_38 then
				local var_7_39 = {
					clearTime = var_7_17
				}

				arg_7_6:add(disposal_request.ClearFutureDisposalsRequest(var_7_39))
			end
		end

		local var_7_40 = var_7_28 and var_7_28.IsPassAction
		local var_7_41 = var_7_31 and var_7_31.IsPassAction
		local var_7_42 = var_7_10 == native.ETackleBlockType.BigHit

		if (var_7_40 or var_7_41) and not var_7_42 then
			var_7_26 = var_7_40 and var_7_28 or var_7_31

			ASSERT(var_7_26)

			var_7_23 = true

			local var_7_43 = var_7_26.startTime
			local var_7_44 = var_7_26.animName
			local var_7_45 = var_7_43 + arg_7_1.animationProvider:getEventFrame(var_7_44, "pass") / 30
			local var_7_46 = var_7_43 < var_7_30
			local var_7_47 = var_7_43 < var_7_30 and var_7_30 < var_7_45

			if var_7_46 then
				var_7_22.offsetFrameCount = (var_7_22.targetTime - var_7_22.startTime) * 30
				var_7_22.startTime = var_7_22.targetTime
				var_7_22.targetTime = var_7_22.targetTime + 0.03333333333333333
				var_7_22.startPosition = var_7_22.targetPosition
				var_7_22.startFacing = var_7_22.targetFacing
			end

			if var_7_47 then
				var_7_22.spillTime = var_7_30
				var_7_22.spillDisposalId = arg_7_2:alloc()
			end

			if not var_7_46 and not var_7_47 then
				local var_7_48 = {
					clearTime = var_7_17
				}

				arg_7_6:add(disposal_request.ClearFutureDisposalsRequest(var_7_48))
			end
		end

		if var_7_42 then
			local var_7_49 = arg_7_1.balanceArbitrator
			local var_7_50 = native.Random.FromSystemTime()
			local var_7_51 = native.CGameplayMechanic.BallControl

			formatPrint("[paMechanicResult] mechanic for score calc: ballControlMechanic")

			local var_7_52 = var_7_49:score(var_7_12, var_7_51, arg_7_5, var_7_50).winningMechanicResult == native.EMechanicResult.NoWin
			local var_7_53 = arg_7_8.matchInProgressData.gameplayModifiers

			if var_7_53 and var_7_53.bigHitSpillChanceCustom == 1 then
				var_7_52 = true
			elseif var_7_53 and var_7_53.bigHitSpillChanceCustom == 0 then
				var_7_52 = false
			end

			if var_7_52 then
				formatPrint("[11696] tackle_arbitrator isSpill")

				var_7_22.spillTime = var_7_30
				var_7_22.spillDisposalId = arg_7_2:alloc()
			else
				formatPrint("[11696] tackle_arbitrator NOT isSpill")
			end
		end

		local var_7_54 = var_7_10 == native.ETackleBlockType.Ground
		local var_7_55 = var_7_11 == native.CGameplayMechanic.TryAttempt or var_7_11 == native.CGameplayMechanic.DiveTryAttempt

		if var_7_54 and var_7_55 then
			local var_7_56 = arg_7_1.balanceArbitrator
			local var_7_57 = native.Random.FromSystemTime()
			local var_7_58 = native.CGameplayMechanic.BallControl
			local var_7_59 = var_7_56:score(var_7_12, var_7_58, arg_7_5, var_7_57).winningMechanicResult == native.EMechanicResult.NoWin

			formatPrint("[11696] %s", var_7_59 and "isSpill" or "not Spill")

			local var_7_60 = arg_7_3:getMatchProgressionEntity().attackingSide
			local var_7_61 = arg_7_1.knowledgeBank.teamKnowledgePair:get(var_7_60)

			ASSERT(var_7_61)

			local var_7_62 = arg_7_4:getBallObject()

			ASSERT(var_7_62)

			local var_7_63 = var_7_62.pos
			local var_7_64 = tryarea_cconfig.cTryAreaConfig.tryAreaDefinition

			ASSERT(var_7_64)

			local var_7_65 = native.CTryArea.isPositionWithinTryAreaDefinition(var_7_61, var_7_63, var_7_64)

			if var_7_59 and not var_7_65 then
				var_7_22.spillTime = var_7_30
				var_7_22.spillDisposalId = arg_7_2:alloc()
			end
		end
	end

	ASSERT(not var_7_24 or not var_7_25)
	ASSERT(not var_7_23 or not var_7_25)

	local var_7_66 = var_7_21 and var_0_1[var_7_10] or var_0_2[var_7_10]

	if var_7_0.mechanic == native.CGameplayMechanic.Fend then
		var_7_66 = var_7_21 and "FendAction" or "FendedAction"
	end

	if var_7_0.mechanic == native.CGameplayMechanic.HitUp then
		var_7_66 = var_7_21 and "HitUpAction" or "HitUppedAction"
	end

	if var_7_0.mechanic == native.CGameplayMechanic.SideStep then
		var_7_66 = var_7_21 and "SideStepAction" or "SideSteppedAction"
		var_7_22.ballCarrierId = var_7_4
	end

	if var_7_0.mechanic == native.CGameplayMechanic.FakePass then
		var_7_66 = var_7_21 and "SideStepAction" or "SideSteppedAction"
		var_7_22.ballCarrierId = var_7_4
	end

	if var_7_0.mechanic == native.CGameplayMechanic.GooseStep then
		var_7_66 = var_7_21 and "GooseStepAction" or "GooseSteppedAction"
	end

	local var_7_67 = var_7_0.mechanic == native.CGameplayMechanic.AnkleTap

	if var_7_67 then
		var_7_66 = var_7_21 and "AnkleTappedAction" or "AnkleTapAction"
	end

	if var_7_0.mechanic == native.CGameplayMechanic.BigHit then
		var_7_66 = var_7_21 and "BigHittedAction" or "BigHitAction"
	end

	local var_7_68 = var_7_0.mechanic == native.CGameplayMechanic.TryAttempt or var_7_0.mechanic == native.CGameplayMechanic.DiveTryAttempt

	if var_7_68 then
		var_7_66 = var_7_21 and "TackledInTryAction" or "TackleInTryAction"
	end

	if var_7_0.isHighTackle then
		var_7_66 = var_7_21 and "HighTackledContactAction" or "HighTackleContactAction"
	end

	if var_7_21 and var_7_24 and var_7_10 == native.ETackleBlockType.Contact then
		var_7_66 = "CollectInTackleAction"

		local var_7_69 = arg_7_4:getGameObject(var_7_12):getAction(arg_7_3)

		var_7_22.expectedDisposalId = var_7_69.expectedDisposalId
		var_7_22.gamerId = var_7_69.gamerId
		var_7_22.expectedDisposalType = var_7_69.expectedDisposalType
		var_7_22.expectedDisposalSubType = var_7_69.expectedDisposalSubType
		var_7_22.collectTime = var_7_69.collectTime

		ASSERT(var_7_22.expectedDisposalId)
		ASSERT(var_7_22.expectedDisposalType)
		ASSERT(var_7_22.expectedDisposalSubType)
		ASSERT(var_7_22.collectTime)
	end

	if var_7_21 and var_7_25 and var_7_10 == native.ETackleBlockType.BigHit then
		local var_7_70 = arg_7_4:getGameObject(var_7_12)
		local var_7_71 = var_7_70:getAction(arg_7_3)
		local var_7_72 = type(var_7_71)

		var_7_66 = var_0_4[var_7_72]

		local var_7_73
		local var_7_74 = var_7_70:tryGetKickInput()

		if var_7_74 and var_7_74.kickAimingPos then
			var_7_73 = var_7_74.kickAimingPos:tovec3(0.1)
		else
			var_7_73 = var_7_71.targetPos
		end

		ASSERT(var_7_71.startPosition)
		ASSERT(var_7_71.startFacing)

		var_7_22.kickStartPosition = var_7_71.startPosition
		var_7_22.kickStartFacing = var_7_71.startFacing
		var_7_22.disposalId = var_7_71.disposalId
		var_7_22.disposalTime = var_7_71.disposalTime
		var_7_22.disposalSubType = var_7_71.disposalSubType
		var_7_22.trajectoryName = var_7_71.trajectoryName
		var_7_22.configName = var_7_71.configName
		var_7_22.groundSpeed = var_7_71.groundSpeed
		var_7_22.kickDirection = var_7_71.kickDirection
		var_7_22.power = var_7_71.power
		var_7_22.targetPos = var_7_73
	end

	if var_7_21 and var_7_25 and (var_7_10 == native.ETackleBlockType.Contact or var_7_10 == native.ETackleBlockType.Dive) then
		local var_7_75 = arg_7_4:getGameObject(var_7_12)
		local var_7_76 = var_7_75:getAction(arg_7_3)
		local var_7_77 = type(var_7_76)

		var_7_66 = var_0_3[var_7_77]

		local var_7_78
		local var_7_79 = var_7_75:tryGetKickInput()

		if var_7_79 and var_7_79.kickAimingPos then
			var_7_78 = var_7_79.kickAimingPos:tovec3(0.1)
		else
			var_7_78 = var_7_76.targetPos
		end

		ASSERT(var_7_76.startPosition)
		ASSERT(var_7_76.startFacing)

		var_7_22.kickStartPosition = var_7_76.startPosition
		var_7_22.kickStartFacing = var_7_76.startFacing
		var_7_22.disposalId = var_7_76.disposalId
		var_7_22.disposalTime = var_7_76.disposalTime
		var_7_22.disposalSubType = var_7_76.disposalSubType
		var_7_22.trajectoryName = var_7_76.trajectoryName
		var_7_22.configName = var_7_76.configName
		var_7_22.groundSpeed = var_7_76.groundSpeed
		var_7_22.kickDirection = var_7_76.kickDirection
		var_7_22.power = var_7_76.power
		var_7_22.targetPos = var_7_78
	end

	if var_7_21 and var_7_23 and (var_7_10 == native.ETackleBlockType.Contact or var_7_10 == native.ETackleBlockType.Dive) then
		ASSERT(var_7_26)

		var_7_66 = "PassInTackleAction"
		var_7_22.disposalId = var_7_26.disposalId
		var_7_22.disposalTime = var_7_26.disposalTime
		var_7_22.ballTargetTime = var_7_26.ballTargetTime
		var_7_22.disposalSubType = var_7_26.disposalSubType
		var_7_22.trajectoryName = var_7_26.trajectoryName
		var_7_22.configName = var_7_26.configName
		var_7_22.groundSpeed = var_7_26.groundSpeed
		var_7_22.targetId = var_7_26.targetId
		var_7_22.originPos = var_7_26.originPos
		var_7_22.targetPos = var_7_26.targetPos
		var_7_22.passAngle = var_7_26.passAngle
	end

	if var_7_21 and var_7_68 then
		local var_7_80 = arg_7_4:getGameObject(var_7_12):getAction(arg_7_3)

		ASSERT(var_7_80)

		if var_7_80 then
			var_7_22.attemptGuid = var_7_80.attemptGuid
			var_7_22.tryDisposalId = var_7_80.tryDisposalId
		end
	end

	if var_7_21 and var_7_67 then
		var_7_22.attemptGuid = arg_7_2:alloc()
	end

	local var_7_81 = action.createAction(var_7_66, {
		params = var_7_22
	})

	arg_7_6:add(action_request.requestAction(arg_7_3, var_7_12, arg_7_1.guidManager:alloc(), var_7_81))
	arg_7_6:add(tackleintent_request.ClearTackleIntentRequest(var_7_12))

	if var_7_66 == "TackleContactAction" and not var_7_21 and not var_7_21 then
		local var_7_82 = arg_7_4:getGameObject(var_7_12)

		ASSERT(var_7_82)

		local var_7_83 = var_7_82:getController()

		if var_7_83 and type(var_7_83) == "DefendingControlledRoamHuman" then
			arg_7_6:add(eventoccurred_request.EventOccurredRequest("ControlledMovementTackleStartEvent", {
				maker = var_7_12,
				guid = var_7_3
			}))
		end
	end
end
