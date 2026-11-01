import("ai.try.tryattempt_request")
import("base.event.eventoccurred_request")
import("base.side.sidehelper")
import("core.foundation.class")
import("design.tackle.tackle_config")
import("game.player.playertype")
import("rules.penalty.penaltytypes")
import("rules.playtheball.playtheballrules_helper")
import("rules.playtheball.playtheballentity_request")
import("rules.rules.ruleauthority")
import("design.tryarea_cconfig")
import("rules.captainschallenge.captainschallenge_helper")
import("rules.captainschallenge.captainschallengecalledevent_request")
import("rules.match.incrementtacklecount_request")
import("rules.match.settacklecountdisabled_request")
import("rules.positioning.postpositionplayerswipe_rulestate")
import("rules.rulestate.rulestate_request")
import("design.tackle.tacklequery_cconfig")

-- referee-on-report TEST ONLY: every contact tackle is penalised as a high tackle, so the
-- on-report flow can be tested on demand. false for normal play.
local OnReportTestEveryTackleHigh = false

-- scrum-feed-control: a player who went past his line at a scrum is offside for the next tackle
-- (mods/scrum-feed-control, rules/scrum/scrum_setup_rulestate.lua). False without that mod.
local function var_0_scrumOffside(arg_id, arg_time)
	local var_state = rawget(_G, "ScrumControlState")

	return var_state ~= nil and var_state.isScrumOffside ~= nil and var_state.isScrumOffside(arg_id, arg_time)
end

Class("TackleDetect", function(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5)
	arg_1_0.penaltyRequestFactory = arg_1_1
	arg_1_0.tackledInOwnGoalRequestFactory = arg_1_2
	arg_1_0.playTheBallRequestFactory = arg_1_3
	arg_1_0.handoverRequestFactory = arg_1_4
	arg_1_0.heldUpRequestFactory = arg_1_5
	arg_1_0.eventMap = {
		TackleContactEvent = "onTackleContact",
		TackleCommittedEvent = "onTackleCommitted",
		BallStripEvent = "onBallStrip",
		BigHittedEvent = "onTackleContact",
		TackleCompletedEvent = "onTackleCompleted",
		BigHitEvent = "onTackleContact"
	}
end)

TackleDetect.Events = {
	"TackleContactEvent",
	"BigHittedEvent",
	"BigHitEvent",
	"TackleCommittedEvent",
	"TackleCompletedEvent",
	"BallStripEvent"
}
TackleDetect.Authoritative = ruleauthority.ifBallOwnerIsLocal

function TackleDetect.evaluate(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10, arg_2_11)
	local var_2_0 = arg_2_1.type

	arg_2_0[arg_2_0.eventMap[var_2_0]](arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10, arg_2_11)
end

function TackleDetect.onBallStrip(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	formatPrintT("[TackleDetect] - BallStrip started, guid: %t", arg_3_1.guid)

	local var_3_0 = arg_3_7:getActiveTackleEntity():getMostRecentActiveTackle()
	local var_3_1 = var_3_0 and var_3_0.tackleGuid
	local var_3_2 = arg_3_0:getTackleInfo(var_3_1, arg_3_7, arg_3_4)

	if arg_3_1.maker then
		local var_3_3 = arg_3_1.isIllegalBallStrip
		local var_3_4 = var_3_3
		local var_3_5 = arg_3_7:getBallEntity():getOwnerId(arg_3_10) == arg_3_1.maker
		local var_3_6 = arg_3_8:getGameObject(arg_3_1.maker, playertype.TypeId)
		local var_3_7 = var_3_6.side
		local var_3_8 = var_3_6.id
		local var_3_9 = arg_3_4.hooks

		if var_3_9 then
			local var_3_10 = var_3_9 and var_3_9:getHook("TackleDebugHook")

			var_3_10:updateBallStripResult(true, var_3_6)

			local var_3_11 = var_3_7 == sidehelper.home and sidehelper.home or sidehelper.away

			var_3_10:updateBallStripCount(var_3_11, not arg_3_1.isIllegalBallStrip)
		end

		if arg_3_6.matchInData.captainsChallengeEnabled then
			local var_3_12 = arg_3_7:getCaptainsChallengeEntity()
			local var_3_13 = var_3_12:getCaptainsChallengeRemaining(var_3_7) and var_3_12:getCaptainsChallengeEnabled(var_3_7)
			local var_3_14 = arg_3_4.hooks

			if var_3_14 then
				local var_3_15 = var_3_14:getHook("CaptainsChallengeDebugHook")

				if var_3_15 and var_3_15.forceUnlimitedChallenges then
					var_3_13 = true
				end
			end

			if var_3_13 then
				local var_3_16 = false
				local var_3_17 = 2
				local var_3_18 = 99.9

				for iter_3_0, iter_3_1 in arg_3_8:activeObjects(playertype.TypeId) do
					if iter_3_1.side == var_3_6.side and iter_3_0 ~= var_3_6.id then
						local var_3_19 = math.abs(native.distance2(var_3_6.pos, iter_3_1.pos))

						var_3_18 = var_3_19 < var_3_18 and var_3_19 or var_3_18
						var_3_16 = var_3_16 or var_3_19 < var_3_17
					end
				end

				if var_3_14 then
					local var_3_20 = var_3_14:getHook("CaptainsChallengeDebugHook")

					if var_3_20 and var_3_20.forceAlwaysGreyArea then
						var_3_16 = true
					end
				end

				if var_3_16 then
					local var_3_21 = var_3_3 and 0 or captainschallenge_helper.getUmpireWrongCallChance(var_3_18, var_3_17, arg_3_4, arg_3_6)

					formatPrint("[BallStrip][UmpireWrongCall] shortestTackler2Distance: %0.2f, maxDistConsideredTackler2: %0.2f, chance = %0.2f", var_3_18, var_3_17, var_3_21)

					local var_3_22 = native.Random(native.Random.FromSystemTime():nextAsSeed())
					local var_3_23 = var_3_12:getCaptainsChallengeEnabled(var_3_6.side)
					local var_3_24 = var_3_21 > var_3_22:randomFloatRange(0, 1) and var_3_23

					formatPrint("[BallStrip][UmpireWrongCall] isPenaltyTackle: %s, chance: %0.2f, isWrongCall: %s", var_3_4 and "true" or "false", var_3_21, var_3_24 and "true" or "false")

					if var_3_4 or var_3_24 then
						formatPrint("[BallStrip][UmpireWrongCall] isPenalty: %s, wrongCallChance: %0.2f, isUmpireWrongCall: %s", var_3_4 and "true" or "false", var_3_21, var_3_24 and "true" or "false")
						arg_3_11:add(eventoccurred_request.EventOccurredRequest("ShowIllegalBallStripHudEvent", {
							maker = var_3_6.id
						}))

						local var_3_25

						var_3_25 = arg_3_3 and arg_3_3:getLocalGamer(1)

						local var_3_26 = #arg_3_3:getAllGamersOnSide(var_3_7, arg_3_4.network:isMaster()) > 0
						local var_3_27 = false

						if not var_3_26 then
							local var_3_28 = captainschallenge_helper.getAICaptainsChallengeChance(arg_3_6, arg_3_4, arg_3_6.matchInData, arg_3_7, var_3_7, var_3_6.pos, arg_3_10)

							var_3_27 = var_3_28 > var_3_22:randomFloatRange(0, 1)

							if var_3_14 then
								local var_3_29 = var_3_14:getHook("CaptainsChallengeDebugHook")

								if var_3_29 then
									var_3_29:newAiChallengeInfo(var_3_28, var_3_27)
								end
							end
						end

						local var_3_30 = var_3_22:nextAsSeed()
						local var_3_31 = (var_3_4 or var_3_24) and sidehelper.getOtherSide(var_3_7) or var_3_7
						local var_3_32 = arg_3_7:getAdvantageEntity().tackleCount
						local var_3_33 = arg_3_6:getComponent("matchInData").matchType.maxTackleCount

						ASSERT(var_3_33)

						local var_3_34 = var_3_32 == var_3_33
						local var_3_35
						local var_3_36 = (var_3_4 or var_3_24) and "RestartWithTap" or var_3_34 and "IsHandOverPTB" or "NotScrumNotDoubleKnockOnPTB"
						local var_3_37

						if not var_3_26 and var_3_27 then
							print("[CaptainsChallenge] Will process ai captains challenge.")
							formatPrint("[CaptainsChallenge] isUmpireWrongCall: %s", var_3_24 and "true" or "false")

							var_3_37 = captainschallenge_helper.processCaptainsChallengeOutcome(var_3_24, var_3_36, var_3_7, arg_3_5:alloc(), var_3_6.pos, var_3_6.pos, var_3_31, arg_3_7, var_3_30, arg_3_4.knowledgeBank.playTheBallKnowledge, arg_3_4, arg_3_5, arg_3_6, arg_3_8, arg_3_10, arg_3_11)
						elseif var_3_26 then
							print("[CaptainsChallenge] Will process human captains challenge.")

							local var_3_38 = {
								isDoubleKnockOn = false,
								isAccidentalKnockOn = false,
								isAccidentalOffside = false,
								challengeSide = var_3_7,
								originalOutcomeStateType = var_3_36,
								isUmpireWrongCall = var_3_24,
								guid = arg_3_5:alloc(),
								isHumanChallenge = var_3_26,
								offenderId = var_3_8,
								restartPosition = var_3_6.pos,
								restartPositionKnockOn = var_3_6.pos,
								randomSeed = var_3_30,
								restartSide = var_3_31,
								lastAttackingSide = sidehelper.getOtherSide(var_3_7),
								isHandOver = var_3_34 or false
							}
							local var_3_39 = class.instantiate("CaptainsChallengeCountdownRuleState", var_3_38)
							local var_3_40 = {
								awayFormationName = "20mTapOffence",
								homeFormationName = "20mTapOffence",
								awayGraphName = "BasicOffence",
								wantLoadingCamera = false,
								homeGraphName = "BasicOffence",
								nextState = var_3_39,
								randomSeed = var_3_30,
								homeFocusPosition = var_3_6.pos,
								awayFocusPosition = var_3_6.pos,
								refereeFocusPosition = var_3_6.pos,
								focusObjectPosition = var_3_6.pos,
								attackingSide = var_3_7,
								homeGraphType = native.EForceDirectedGraphType.Offence,
								awayGraphType = native.EForceDirectedGraphType.Offence
							}
							local var_3_41 = postpositionplayerswipe_rulestate.PostPositionPlayersWipeRulestate(var_3_40)

							arg_3_11:add(rulestate_request.RuleStateRequest(var_3_41, arg_3_5:alloc()))

							local var_3_42 = {
								time = arg_3_10,
								challengerId = var_3_8,
								challengeSide = var_3_7,
								challengeSuccessful = var_3_24
							}

							arg_3_11:add(captainschallengecalledevent_request.CaptainsChallengeCalledEventRequest(var_3_42))

							return
						else
							var_3_4 = var_3_4 or var_3_24

							print("[CaptainsChallenge] Will not process ai or human captains challenge.")
						end

						if var_3_37 ~= nil then
							local var_3_43 = {
								blockGamerSwitching = false,
								enablePlayerSwitching = false,
								expireTime = arg_3_10 + 2.5,
								randomSeed = var_3_30,
								nextState = var_3_37,
								guid = arg_3_5:alloc(),
								idleTime = arg_3_10
							}
							local var_3_44 = class.instantiate("IdleAllPlayersRuleState", var_3_43)

							arg_3_11:add(rulestate_request.RuleStateRequest(var_3_44, arg_3_5:alloc()))

							return
						end
					end
				end
			end
		end

		if var_3_4 then
			formatPrint("[Penalty][TackleDetect] Player %d initiated penalty tackle. Event: %s", arg_3_1.maker, arg_3_1.type)

			local var_3_45 = penaltytypes.infringementTypes
			local var_3_46 = {
				defensiveOffside = false,
				offenderId = arg_3_1.maker,
				penaltyPosition = arg_3_1.position,
				penaltyType = var_3_45.IllegalBallStrip,
				refereeSignalType = native.EUmpireSignalTypes.HighTackle,
				tackledPlayerHasBall = var_3_5
			}

			if arg_3_0.lastPenaltyGuid ~= var_3_1 then
				arg_3_0.lastPenaltyGuid = var_3_1

				arg_3_0:onPenaltyTackleOutcome(var_3_2, arg_3_1, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_10, arg_3_11, var_3_46)
			end
		end
	end
end

function TackleDetect.onTackleContact(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7, arg_4_8, arg_4_9, arg_4_10, arg_4_11)
	formatPrintT("[TackleDetect] - Tackle started: %t", arg_4_1.guid)

	local var_4_0 = arg_4_1.guid
	local var_4_1 = arg_4_0:getTackleInfo(var_4_0, arg_4_7, arg_4_4)

	if OnReportTestEveryTackleHigh and var_4_1 then
		var_4_1.isHighTackle = true
	end

	local var_4_2 = arg_4_7:getBallEntity()
	local var_4_3 = var_4_2:getOwnerId(arg_4_10) or 0

	if arg_4_1.type == "BigHittedEvent" then
		arg_4_0.bigHittedId = arg_4_1.maker
		arg_4_0.bigHittedTime = arg_4_10
	elseif arg_4_1.type == "BigHitEvent" then
		arg_4_0.bigHitId = arg_4_1.maker
	end

	if arg_4_0.bigHittedId and arg_4_0.bigHittedId ~= var_4_3 then
		local var_4_4 = var_4_2:getOwnerId(arg_4_0.bigHittedTime) or 0
		local var_4_5 = false
		local var_4_6 = var_4_2:getDisposalId(arg_4_0.bigHittedTime)

		if var_4_6 then
			local var_4_7 = var_4_2:getDisposalInfoForId(arg_4_7, var_4_6)
			local var_4_8 = var_4_7.disposalType

			var_4_5 = arg_4_0.bigHittedTime - var_4_7.disposalTime < tackle_config.TackledOffBallTime and (var_4_8 == native.EDisposalType.Kick or var_4_8 == native.EDisposalType.Pass or var_4_8 == native.EDisposalType.Spill)
		end

		local var_4_9 = var_4_4 == arg_4_0.bigHittedId or var_4_5

		formatPrintT("[TackleDetect] - ownerAtContactId: %d, bigHittedId: %d, bigHittedWasLastOwner: %s", var_4_4, arg_4_0.bigHittedId, var_4_9 and "true" or "false")

		if not var_4_9 then
			arg_4_0.isPenaltyTackle = true
		end
	end

	if arg_4_0.isPenaltyTackle and arg_4_0.bigHitId and arg_4_0.bigHittedId then
		formatPrint("[Penalty][TackleDetect][10926] Illegal Big Hit:bigHitId: %d, bigHittedId: %d, ballOwnerId: %d", arg_4_0.bigHitId, arg_4_0.bigHittedId, var_4_3)

		local var_4_10 = {
			defensiveOffside = false,
			offenderId = arg_4_0.bigHitId,
			penaltyPosition = arg_4_8:getGameObject(arg_4_0.bigHittedId, playertype.TypeId).pos,
			penaltyType = penaltytypes.infringementTypes.TackleOffBall,
			refereeSignalType = native.EUmpireSignalTypes.HighTackle,
			tackledPlayerHasBall = arg_4_0.bigHittedId == var_4_3
		}

		arg_4_0:onPenaltyTackleOutcome(var_4_1, arg_4_1, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7, arg_4_8, arg_4_10, arg_4_11, var_4_10)

		arg_4_0.bigHitId = nil
		arg_4_0.bigHittedId = nil
		arg_4_0.bigHittedTime = nil
	elseif var_4_1 then
		arg_4_0.bigHitId = nil
		arg_4_0.bigHittedId = nil
		arg_4_0.bigHittedTime = nil

		local var_4_11 = var_4_1.tacklerIds[1]
		local var_4_12 = arg_4_8:getGameObject(var_4_11, playertype.TypeId).offsideInfo.flaggedOffside
		-- scrum-feed-control: offside off a scrum is always a full penalty (scrumOffside), never
		-- a six again (generalgameplay_rulestate.lua).
		local var_4_scrumOffside = not var_4_12 and var_0_scrumOffside(var_4_11, var_4_1.startTime)

		var_4_12 = var_4_12 or var_4_scrumOffside
		local var_4_13 = arg_4_8:getGameObject(var_4_1.tackledId, playertype.TypeId).pos
		local var_4_14 = var_4_2:getOwnerId(var_4_1.startTime) or 0
		local var_4_15 = false
		local var_4_16 = var_4_2:getDisposalId(var_4_1.startTime)

		if var_4_16 then
			local var_4_17 = var_4_2:getDisposalInfoForId(arg_4_7, var_4_16)
			local var_4_18 = var_4_17 and var_4_17.disposalType or native.EDisposalType.None
			local var_4_19 = var_4_1.startTime - var_4_17.disposalTime < tackle_config.TackledOffBallTime

			var_4_15 = var_4_19 and (var_4_18 == native.EDisposalType.Kick or var_4_18 == native.EDisposalType.Pass or var_4_18 == native.EDisposalType.Spill or var_4_18 == native.EDisposalType.Collision)

			if not var_4_15 then
				formatPrint("[TackleDetect] Ball has disposal id during tackle but tackled player did not just dispose of it. lastDisposalTimeWithinThreshold: %s, tackledLastDisposalType: %s", var_4_19 and "true" or "false", var_4_18 and tostring(var_4_18) or "None")
			end
		end

		local var_4_20 = var_4_14 == var_4_1.tackledId or var_4_15

		formatPrintT("[TackleDetect] - ownerAtContactId: %d, tackledId: %d, tackledPlayerWasLastOwner: %s", var_4_14, var_4_1.tackledId, var_4_20 and "true" or "false")

		local var_4_21 = var_4_3 == var_4_1.tackledId
		local var_4_22 = not var_4_21 and not var_4_20

		if var_4_12 or var_4_1.isHighTackle or var_4_1.isIllegalTackle or var_4_22 then
			formatPrint("[Penalty][TackleDetect] Player %d initiated penalty tackle. Event: %s", arg_4_1.maker, arg_4_1.type)

			local var_4_23 = penaltytypes.infringementTypes
			local var_4_24

			if var_4_12 then
				var_4_24 = {
					defensiveOffside = true,
					offenderId = var_4_11,
					penaltyPosition = var_4_13,
					penaltyType = var_4_23.OffSide,
					refereeSignalType = native.EUmpireSignalTypes.Offside,
					tackledPlayerHasBall = var_4_21,
					scrumOffside = var_4_scrumOffside or nil
				}
			elseif var_4_1.isHighTackle then
				var_4_24 = {
					defensiveOffside = false,
					offenderId = var_4_11,
					penaltyPosition = var_4_13,
					penaltyType = var_4_23.HighTackle,
					refereeSignalType = native.EUmpireSignalTypes.HighTackle,
					tackledPlayerHasBall = var_4_21
				}
			elseif var_4_1.isIllegalTackle then
				var_4_24 = {
					defensiveOffside = false,
					offenderId = var_4_11,
					penaltyPosition = var_4_13,
					penaltyType = var_4_23.IllegalTackle,
					refereeSignalType = native.EUmpireSignalTypes.HighTackle,
					tackledPlayerHasBall = var_4_21
				}

				print("We have an illegal tackle")
			elseif var_4_22 then
				formatPrint("[Penalty][TackleDetect] Invalid player tackled. Player %d initiated penalty tackle. Event: %s", arg_4_1.maker, arg_4_1.type)

				var_4_24 = {
					defensiveOffside = false,
					offenderId = var_4_11,
					penaltyPosition = var_4_13,
					penaltyType = var_4_23.TackleOffBall,
					refereeSignalType = native.EUmpireSignalTypes.HighTackle,
					tackledPlayerHasBall = var_4_21
				}
			end

			if arg_4_0.lastPenaltyGuid ~= var_4_0 then
				arg_4_0.lastPenaltyGuid = var_4_0

				arg_4_0:onPenaltyTackleOutcome(var_4_1, arg_4_1, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7, arg_4_8, arg_4_10, arg_4_11, var_4_24)
			end
		end
	end
end

function TackleDetect.onTackleCommitted(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7, arg_5_8, arg_5_9, arg_5_10, arg_5_11)
	formatPrintT("[TackleDetect] - onTackleCommitted: %t", arg_5_1.guid)

	local var_5_0 = arg_5_1.guid
	local var_5_1 = arg_5_0:getTackleInfo(var_5_0, arg_5_7, arg_5_4)

	if var_5_1 then
		local var_5_2 = arg_5_0.lastTackleGuid == nil and true or arg_5_0.lastTackleGuid ~= var_5_1.tackleGuid

		arg_5_0.lastTackleGuid = var_5_1.tackleGuid

		local var_5_3 = var_5_1.tacklerIds[1]
		local var_5_4 = arg_5_8:getGameObject(var_5_3, playertype.TypeId)
		local var_5_5 = var_5_4.offsideInfo.flaggedOffside or var_0_scrumOffside(var_5_3, arg_5_10)
		local var_5_6 = arg_5_7:getBallEntity():getOwnerId(arg_5_10)
		local var_5_7

		var_5_7 = var_5_6 == var_5_1.tackledId

		local var_5_8 = arg_5_8:getGameObject(var_5_6, playertype.TypeId)

		if var_5_8 ~= nil and var_5_4 ~= nil then
			local var_5_9 = var_5_4.facing
			local var_5_10 = var_5_8.facing
			local var_5_11 = var_5_4.pos
			local var_5_12 = var_5_8.pos - var_5_10 * 0.25
			local var_5_13 = native.dirlen2(var_5_12, var_5_11)
			local var_5_14 = native.angle_signed2(var_5_10, var_5_13)
			local var_5_15 = arg_5_4.hooks

			if var_5_15 then
				local var_5_16 = var_5_15 and var_5_15:getHook("TackleDebugHook")

				if var_5_16 and var_5_2 then
					local var_5_17 = var_5_4.side == sidehelper.home and sidehelper.home or sidehelper.away

					var_5_16:updateTackleCount(var_5_17)

					local var_5_18 = var_5_1.isHighTackle or var_5_1.tackleIsBroken or var_5_1.offloadGuid

					if math.abs(var_5_14) > tacklequery_cconfig.cTackleQueryConfig.maxSwivelDegreesForBallStrip and not var_5_18 then
						var_5_16:updateBallStripAvailableCount(var_5_4.side)
					end
				end
			end
		end

		if var_5_5 or var_5_1.isHighTackle then
			return
		end

		local var_5_19 = arg_5_6:getComponent("matchInData")

		ASSERT(var_5_19)

		local var_5_20 = var_5_19.matchType

		ASSERT(var_5_20)

		local var_5_21 = arg_5_8:getBallObject().pos
		local var_5_22 = var_5_1.tackledId
		local var_5_23 = arg_5_8:getGameObject(var_5_22, playertype.TypeId)

		ASSERT(var_5_23)

		local var_5_24 = var_5_23:getSide()
		local var_5_25 = sidehelper.getOtherSide(var_5_24)
		local var_5_26 = tryarea_cconfig.cTryAreaConfig.tryAreaDefinition
		local var_5_27 = arg_5_7:getMatchProgressionEntity().tackleCount
		local var_5_28 = var_5_20.maxTackleCount

		ASSERT(var_5_28)

		local var_5_29 = var_5_27 == var_5_28
		local var_5_30 = arg_5_4.knowledgeBank.teamKnowledgePair:get(var_5_25)
		local var_5_31 = native.CTryArea.isPositionWithinTryAreaDefinition(var_5_30, var_5_21, var_5_26)
		local var_5_32 = not var_5_29 and not var_5_31
		local var_5_33 = var_5_1.offloadGuid

		if var_5_33 and var_5_33.valid then
			return
		end

		if var_5_1.tackleIsBroken then
			return
		end

		if var_5_32 then
			local var_5_34 = arg_5_4.knowledgeBank.playTheBallKnowledge

			ASSERT(var_5_34)

			local var_5_35 = var_5_34.dummyHalfId

			if var_5_35 then
				arg_5_11:add(playtheballentity_request.DummyHalfPlayTheBallRequest({
					dummyHalfId = var_5_35
				}))
			end
		end
	end
end

function TackleDetect.onTackleCompleted(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8, arg_6_9, arg_6_10, arg_6_11)
	local var_6_0 = arg_6_7:getMatchProgressionEntity().tackleCount

	formatPrintT("[TackleDetect] - onTackleCompleted, tackle count: %d", var_6_0)

	-- scrum-feed-control: the first completed tackle after a scrum ends its offside flags.
	local var_6_scrum = rawget(_G, "ScrumControlState")

	if var_6_scrum and var_6_scrum.clearScrumOffside then
		var_6_scrum.clearScrumOffside()
	end

	local var_6_1 = arg_6_1.guid
	local var_6_2 = arg_6_0:getTackleInfo(var_6_1, arg_6_7, arg_6_4)

	if var_6_2 then
		local var_6_3 = var_6_2.tackledId
		local var_6_4 = arg_6_1.maker

		if var_6_4 ~= var_6_3 then
			formatPrint("tackle ids don't match! maker id = %d, tackledId = %d", var_6_4, var_6_3)

			return
		end

		local var_6_5 = var_6_2.tacklerIds[1]
		local var_6_6 = arg_6_7:getBallEntity():getOwnerId(arg_6_10) == var_6_3
		local var_6_7 = arg_6_8:getBallObject().pos
		local var_6_8 = arg_6_8:getGameObject(var_6_5, playertype.TypeId)
		local var_6_9 = arg_6_8:getGameObject(var_6_3, playertype.TypeId)
		local var_6_10 = var_6_9:getSide()

		var_6_2.tackleCompletePosition = var_6_9.pos or var_6_7
		var_6_2.holdTime = arg_6_1.holdTime or arg_6_10
		var_6_2.tackleEndTime = arg_6_1.tackleEndTime

		local var_6_11 = tryarea_cconfig.cTryAreaConfig.tryAreaDefinition
		local var_6_12 = arg_6_4.knowledgeBank.teamKnowledgePair
		local var_6_13 = var_6_12:get(var_6_10)
		local var_6_14 = native.CTryArea.isPositionWithinTryAreaDefinition(var_6_13, var_6_2.tackleCompletePosition, var_6_11)
		local var_6_15 = arg_6_8:getGameObject(var_6_3, playertype.TypeId)

		ASSERT(var_6_15)

		local var_6_16 = var_6_15:getSide()
		local var_6_17 = sidehelper.getOtherSide(var_6_16)
		local var_6_18 = var_6_12:get(var_6_17)
		local var_6_19 = native.CTryArea.isPositionWithinTryAreaDefinition(var_6_18, var_6_2.tackleCompletePosition, var_6_11)
		local var_6_20 = arg_6_7:getMatchProgressionEntity().tackleCount
		local var_6_21 = arg_6_6:getComponent("matchInData")

		ASSERT(var_6_21)

		local var_6_22 = var_6_21.matchType

		ASSERT(var_6_22)

		local var_6_23 = var_6_22.maxTackleCount

		ASSERT(var_6_23)

		local var_6_24 = var_6_20 == var_6_23
		local var_6_25 = var_6_14 and not var_6_24
		local var_6_26 = var_6_2.offloadGuid

		if var_6_26 and var_6_26.valid then
			return
		end

		if not var_6_6 then
			return
		end

		if var_6_2.tackleIsBroken then
			return
		end

		if var_6_19 then
			formatPrintT("[TackleDetect::onTackledInOwnGoalOutcome] onTackleCompleted: %t, tackleCount %d", arg_6_1.guid, var_6_20)
			arg_6_0:onTackledInOwnGoalOutcome(var_6_2, arg_6_1, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8, arg_6_10, arg_6_11)
		elseif var_6_25 then
			formatPrintT("[TackleDetect::onHeldUpTackleOutcome] - onTackleCompleted: %t, tackleCount %d", arg_6_1.guid, var_6_20)
			arg_6_0:onHeldUpTackleOutcome(var_6_2, arg_6_1, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8, arg_6_10, arg_6_11)
		elseif var_6_24 then
			formatPrintT("[TackleDetect::onHandOverOutcome] - onTackleCompleted: %t, tackleCount %d", arg_6_1.guid, var_6_20)
			arg_6_0:onHandOverOutcome(var_6_2, arg_6_1, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8, arg_6_10, arg_6_11)
		else
			formatPrintT("[TackleDetect::onPlayTheBallOutcome] - onTackleCompleted: %t, tackleCount: %d", arg_6_1.guid, var_6_20)
			arg_6_0:onPlayTheBallOutcome(var_6_2, arg_6_1, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8, arg_6_10, arg_6_11)
		end
	end
end

function TackleDetect.onHandOverOutcome(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7, arg_7_8, arg_7_9, arg_7_10)
	local var_7_0 = arg_7_1.tackledId
	local var_7_1 = arg_7_8:getGameObject(var_7_0, playertype.TypeId).side
	local var_7_2 = arg_7_1.tackleCompletePosition
	local var_7_3 = tryarea_cconfig.cTryAreaConfig.tryAreaDefinition
	local var_7_4 = arg_7_4.knowledgeBank.teamKnowledgePair:get(var_7_1)
	local var_7_5 = native.CTryArea.isPositionWithinTryAreaDefinition(var_7_4, var_7_2, var_7_3)
	local var_7_6 = sidehelper.getOtherSide(var_7_1)
	local var_7_7 = var_7_5 and playtheballrules_helper.getHeldUpRestartPosition(arg_7_6, var_7_1, var_7_2) or var_7_2
	local var_7_8 = arg_7_1.tacklerIds[1]
	local var_7_9 = {
		restartSide = var_7_6,
		restartPosition = var_7_7,
		originalHandOverPosition = var_7_2,
		outPosition = var_7_2,
		occurredInTryArea = var_7_5,
		tackleEndTime = arg_7_1.tackleEndTime,
		primaryTacklerId = var_7_8,
		tackledId = var_7_0
	}

	formatPrint("[TackleDetect][onHandOverOutcome] Increment Tackle Count Request Sent")
	arg_7_10:add(incrementtacklecount_request.IncrementTackleCountRequest())

	local var_7_10 = arg_7_0.handoverRequestFactory(arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7, arg_7_8, arg_7_9, arg_7_10, var_7_9)

	arg_7_10:add(var_7_10)
end

function TackleDetect.onPlayTheBallOutcome(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5, arg_8_6, arg_8_7, arg_8_8, arg_8_9, arg_8_10)
	if not arg_8_7:getMatchProgressionEntity().tackleCountDisabled then
		formatPrint("[TackleDetect][onPlayTheBallOutcome] Increment Tackle Count Request Sent")
		arg_8_10:add(incrementtacklecount_request.IncrementTackleCountRequest())
	else
		formatPrint("[TackleDetect][onPlayTheBallOutcome] IGNORE Increment Tackle Count")

		local var_8_0 = {
			ruckInfringement = false,
			disable = false
		}

		arg_8_10:add(settacklecountdisabled_request.SetTackleCountDisabledRequest(var_8_0))
	end

	local var_8_1 = arg_8_0.playTheBallRequestFactory(arg_8_3, arg_8_4, arg_8_5, arg_8_6, arg_8_7, arg_8_8, arg_8_9, arg_8_10)

	arg_8_10:add(var_8_1)
end

function TackleDetect.onHeldUpTackleOutcome(arg_9_0, arg_9_1, arg_9_2, arg_9_3, arg_9_4, arg_9_5, arg_9_6, arg_9_7, arg_9_8, arg_9_9, arg_9_10)
	formatPrint("[TackleDetect][onHeldUpTackleOutcome] Increment Tackle Count Request Sent")
	arg_9_10:add(incrementtacklecount_request.IncrementTackleCountRequest())

	local var_9_0 = arg_9_5:alloc()
	local var_9_1 = arg_9_8:getGameObject(arg_9_1.tackledId)
	local var_9_2 = {
		videoRefChance = 0,
		attemptedWithinSuccessfulTackle = true,
		evaluateFrom = arg_9_1.holdTime,
		evaluateUntil = arg_9_1.holdTime,
		attemptGuid = var_9_0,
		attemptById = arg_9_1.tackledId,
		attemptByGamerId = arg_9_3:getGamerIdFor(arg_9_1.tackledId),
		firstTacklerGamerId = arg_9_3:getGamerIdFor(arg_9_1.tacklerIds[1]),
		tryAttemptOutcome = native.ETryAttemptOutcome.HeldUp,
		position = var_9_1 and var_9_1.pos or native.vec2.Zero()
	}

	arg_9_10:add(tryattempt_request.TryAttemptRequest(var_9_2))

	local var_9_3 = arg_9_0.heldUpRequestFactory(arg_9_3, arg_9_4, arg_9_5, arg_9_6, arg_9_7, arg_9_8, arg_9_9, arg_9_10, arg_9_2)
	local var_9_4 = arg_9_4.hooks
	local var_9_5 = var_9_4 and var_9_4:getHook("TryDebugHook")

	if var_9_5 then
		var_9_5:addTryAttempt(var_9_2)
	end
end

function TackleDetect.onPenaltyTackleOutcome(arg_10_0, arg_10_1, arg_10_2, arg_10_3, arg_10_4, arg_10_5, arg_10_6, arg_10_7, arg_10_8, arg_10_9, arg_10_10, arg_10_11)
	local var_10_0 = arg_10_11.offenderId
	local var_10_1 = arg_10_8:getGameObject(var_10_0, playertype.TypeId).side
	local var_10_2 = arg_10_11.penaltyPosition

	formatPrint("[TackleDetect][onPenaltyTackleOutcome] OffenderId: %d, type: %s", var_10_0, arg_10_11.penaltyType)

	local var_10_3 = {
		offendingSide = var_10_1,
		position = var_10_2,
		offenderId = var_10_0,
		eventType = arg_10_2.type,
		defensiveOffside = arg_10_11.defensiveOffside,
		penaltyType = arg_10_11.penaltyType,
		refereeSignalType = arg_10_11.refereeSignalType,
		tackledPlayerHasBall = arg_10_11.tackledPlayerHasBall,
		scrumOffside = arg_10_11.scrumOffside
	}
	local var_10_4 = arg_10_0.penaltyRequestFactory(arg_10_3, arg_10_4, arg_10_5, arg_10_6, arg_10_7, arg_10_8, arg_10_9, arg_10_10, var_10_3)

	if var_10_4 == nil then
		return
	end

	arg_10_10:add(var_10_4)
end

function TackleDetect.onTackledInOwnGoalOutcome(arg_11_0, arg_11_1, arg_11_2, arg_11_3, arg_11_4, arg_11_5, arg_11_6, arg_11_7, arg_11_8, arg_11_9, arg_11_10)
	if arg_11_7:getAdvantageEntity().isActive then
		return
	end

	local var_11_0 = arg_11_5:alloc()
	local var_11_1 = arg_11_1.tackledId
	local var_11_2 = arg_11_8:getGameObject(var_11_1, playertype.TypeId)
	local var_11_3 = var_11_2:getSide()
	local var_11_4 = arg_11_1.tacklerIds[1]
	local var_11_5 = arg_11_3:getGamerIdFor(var_11_4)
	local var_11_6 = native.Random.FromSystemTime():nextAsSeed()
	local var_11_7 = arg_11_1.tackleCompletePosition or var_11_2.pos
	local var_11_8 = arg_11_1.tackleEndTime or arg_11_9

	formatPrint("[TackleDetect:onTackledInOwnGoalOutcome] - Tackle in goal detected at: %.2f, %.2f  (%.2f, %.2f)", var_11_7.x, var_11_7.y, var_11_2.pos.x, var_11_2.pos.y)

	local var_11_9 = arg_11_4.soundSystem

	if var_11_9 then
		var_11_9:queueSoundOnlyEvent({
			type = "TackledInGoalSoundEvent",
			maker = var_11_1,
			time = arg_11_9
		})
	end

	local var_11_10 = {
		tackledSide = var_11_3,
		primaryTacklerId = var_11_4,
		tackledId = var_11_1,
		position = var_11_7,
		tackleEndTime = var_11_8
	}
	local var_11_11 = arg_11_0.tackledInOwnGoalRequestFactory(arg_11_3, arg_11_4, arg_11_5, arg_11_6, arg_11_7, arg_11_8, arg_11_9, arg_11_10, var_11_10)

	arg_11_10:add(var_11_11)
end

function TackleDetect.getTackleInfo(arg_12_0, arg_12_1, arg_12_2, arg_12_3)
	local var_12_0 = arg_12_2:getActiveTackleEntity():getTackle(arg_12_1)

	if var_12_0 then
		local var_12_1 = var_12_0.tackleEntryTime
		local var_12_2 = var_12_0.isHighTackle
		local var_12_3 = var_12_0.isIllegalTackle
		local var_12_4 = false
		local var_12_5 = false
		local var_12_6 = var_12_0:getBallCarrierId()
		local var_12_7 = var_12_0:getTacklerIds()
		local var_12_8 = arg_12_3.knowledgeBank.playTheBallKnowledge

		ASSERT(var_12_8)

		local var_12_9 = {
			var_12_8.primaryMarkerId,
			var_12_8.secondaryMarkerId
		}
		local var_12_10 = var_12_0.offloadGuid
		local var_12_11 = var_12_0:hasBlockType(native.ETackleBlockType.Break)

		return {
			tackleGuid = arg_12_1,
			offloadGuid = var_12_10,
			startTime = var_12_1,
			tackledId = var_12_6,
			tacklerIds = var_12_7,
			markerIds = var_12_9,
			tackleIsBroken = var_12_11,
			isHighTackle = var_12_2,
			isLowTackle = var_12_4,
			isDiveTackle = var_12_5,
			isIllegalTackle = var_12_3
		}
	end

	return nil
end
