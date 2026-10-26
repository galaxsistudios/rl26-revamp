import("rules.penalty.penaltytypes")
import("sim.hud.hud_helper")
import("app.noesis.hud.nvm_scorecard")

local var_0_0 = penaltytypes.infringementTypes

-- referee-on-report: seconds the "<NAME> ON REPORT" banner stays under the scoreboard. It uses
-- the scorecard's MatchStateMessage/ShowMatchState bindings, which the stock game never sets
-- (the banner itself is in defaulthudresources.xaml, mods/nrl-broadcast-scoreboard).
local OnReportBannerSeconds = 4
-- Seconds after the scoreboard comes back from the close-ups before the banner slides out.
local OnReportBannerDelay = 0.75

Class("GameplayScoreHud", function(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7)
	local var_1_0 = nvm_scorecard.NVMScoreCard(arg_1_7, arg_1_2)
	local var_1_1 = arg_1_7.featureStack

	var_1_1:registerViewModel(hud_helper.HUD_IDENTIFIERS.gameplay, "ScoreCard", var_1_0)

	arg_1_0.scoreCardNVM = var_1_0
	arg_1_0.hudFeatureStack = var_1_1

	-- referee-on-report: a new match HUD starts with no reports.
	local var_1_2 = rawget(_G, "OnReportState")

	if var_1_2 then
		var_1_2.pending = nil
		var_1_2.reports = {}
	end

	var_1_1:register("gameplayScore", arg_1_0, function(arg_2_0)
		arg_1_0:show(arg_2_0)
	end, function()
		arg_1_0:hide()
	end)
end)

function GameplayScoreHud.registerWithMatchSim(arg_4_0, arg_4_1)
	local function var_4_0(arg_5_0)
		return function(...)
			return arg_5_0(arg_4_0, ...)
		end
	end

	local var_4_1 = {
		AdvantagePaidEvent = var_4_0(arg_4_0.onAdvantagePaid),
		AdvantageInterruptedEvent = var_4_0(arg_4_0.onAdvantageInterruptedEvent),
		BreakInPlayEvent = var_4_0(arg_4_0.onBreakInPlay),
		CaughtInGoalEvent = var_4_0(arg_4_0.onCaughtInGoal),
		ConversionOutcomeEvent = var_4_0(arg_4_0.onConversion),
		FieldGoalSuccessEvent = var_4_0(arg_4_0.onFieldGoalSuccess),
		ForwardPassEvent = var_4_0(arg_4_0.onForwardPass),
		HandOverEvent = var_4_0(arg_4_0.onHandOver),
		HeldInTackleWarningEvent = var_4_0(arg_4_0.onHeldInTackleWarning),
		HeldInTacklePenaltyEvent = var_4_0(arg_4_0.onHeldInTacklePenalty),
		InTouchEvent = var_4_0(arg_4_0.onInTouch),
		NoAdvantageEvent = var_4_0(arg_4_0.onNoAdvantage),
		PenaltyAwardedEvent = var_4_0(arg_4_0.onPenaltyAwarded),
		ShowIllegalBallStripHudEvent = var_4_0(arg_4_0.onShowIllegalBallStripHud),
		PenaltyGoalSuccessEvent = var_4_0(arg_4_0.onPenaltyGoalSuccess),
		PlaceKickFeedbackEvent = var_4_0(arg_4_0.onPlaceKickFeedback),
		TackledInGoalEvent = var_4_0(arg_4_0.onTackledInGoalEvent),
		SendOffFinalWarningEvent = var_4_0(arg_4_0.onSendOffFinalWarning),
		SinBinFinalWarningEvent = var_4_0(arg_4_0.onSinBinFinalWarning),
		TapRestartEvent = var_4_0(arg_4_0.onTapRestart),
		TackleCompletedEvent = var_4_0(arg_4_0.onTackleCompleted),
		TouchedInGoalEvent = var_4_0(arg_4_0.onTouchedInGoal),
		TryScoredEvent = var_4_0(arg_4_0.onTryScored),
		PlayTheBallEvent = var_4_0(arg_4_0.onPlayTheBall),
		TwentyFiftyEvent = var_4_0(arg_4_0.onTwentyFifty),
		TwentyFortyEvent = var_4_0(arg_4_0.onTwentyForty),
		FortyThirtyEvent = var_4_0(arg_4_0.onFortyThirty),
		FortyTwentyEvent = var_4_0(arg_4_0.onFortyTwenty),
		PlayerSentToSinBinEvent = var_4_0(arg_4_0.onPlayerSentToSinBin),
		PlayerSentOffEvent = var_4_0(arg_4_0.onPlayerOffEvent),
		SinBinCompletedEvent = var_4_0(arg_4_0.onSinBinCompleted),
		SixAgainEvent = var_4_0(arg_4_0.onSixAgainEvent),
		SinBinInfoEvent = var_4_0(arg_4_0.onSinBinInfoEvent),
		RefereeSignalEvent = var_4_0(arg_4_0.onRefereeSignal)
	}

	for iter_4_0, iter_4_1 in pairs(var_4_1) do
		arg_4_1:registerSolidEventListener(iter_4_1, iter_4_0)
	end

	local var_4_2 = {
		TimePeriodExpiredEvent = var_4_0(arg_4_0.onTimePeriodExpired),
		BeginTimePeriodEvent = var_4_0(arg_4_0.onBeginTimePeriodEvent),
		AdvanceToNextTimePeriodEvent = var_4_0(arg_4_0.onAdvanceToNextTimePeriodEvent)
	}

	for iter_4_2, iter_4_3 in pairs(var_4_2) do
		arg_4_1:registerTentativeEventListener(iter_4_3, iter_4_2)
		arg_4_1:registerLocalTentativeEventListener(iter_4_3, iter_4_2)
		arg_4_1:registerSolidEventListener(iter_4_3, iter_4_2)
	end
end

function GameplayScoreHud.onAdvanceToNextTimePeriodEvent(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7, arg_7_8, arg_7_9)
	local var_7_0 = VERIFY(arg_7_1.time)

	arg_7_0:updateGameTime(arg_7_6, arg_7_7, var_7_0, true)
end

function GameplayScoreHud.onTimePeriodExpired(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5, arg_8_6, arg_8_7, arg_8_8, arg_8_9)
	local var_8_0 = VERIFY(arg_8_1.time)

	arg_8_0:updateGameTime(arg_8_6, arg_8_7, var_8_0)
end

function GameplayScoreHud.onBreakInPlay(arg_9_0, arg_9_1, arg_9_2, arg_9_3, arg_9_4, arg_9_5, arg_9_6, arg_9_7, arg_9_8, arg_9_9)
	return
end

function GameplayScoreHud.onBeginTimePeriodEvent(arg_10_0, arg_10_1, arg_10_2, arg_10_3, arg_10_4, arg_10_5, arg_10_6, arg_10_7, arg_10_8, arg_10_9)
	local var_10_0 = VERIFY(arg_10_1.time)

	arg_10_0:updateGameTime(arg_10_6, arg_10_7, var_10_0)
	arg_10_0:setGoldenPointActive(arg_10_7)
end

function GameplayScoreHud.setGoldenPointActive(arg_11_0, arg_11_1)
	local var_11_0 = arg_11_0.scoreCardNVM

	ASSERT(var_11_0)

	local var_11_1 = VERIFY(arg_11_1:getMatchTimeEntity()).goldenPointActive

	ASSERT(var_11_1 ~= nil)
	var_11_0:setGoldenPointActive(var_11_1)
end

function GameplayScoreHud.onSinBinInfoEvent(arg_12_0, arg_12_1)
	ASSERT(arg_12_0.scoreCardNVM)

	if arg_12_1.status == native.ESinBinState.SentOff then
		arg_12_0.scoreCardNVM:addRedCard(arg_12_1.side)
	elseif arg_12_1.status == native.ESinBinState.SinBin then
		arg_12_0.scoreCardNVM:addYellowCard(arg_12_1.side)
	elseif arg_12_1.status == native.ESinBinState.OnField then
		arg_12_0.scoreCardNVM:removeYellowCard(arg_12_1.side)
	end
end

function GameplayScoreHud.onSinBinEvent(arg_13_0, arg_13_1, arg_13_2, arg_13_3, arg_13_4, arg_13_5, arg_13_6, arg_13_7, arg_13_8, arg_13_9)
	return
end

function GameplayScoreHud.onSinBinCompletedEvent(arg_14_0, arg_14_1, arg_14_2, arg_14_3, arg_14_4, arg_14_5, arg_14_6, arg_14_7, arg_14_8, arg_14_9)
	return
end

function GameplayScoreHud.dispose(arg_15_0, arg_15_1)
	arg_15_0.scoreCardNVM:dispose()
	arg_15_0.hudFeatureStack:unregisterHUDElement(hud_helper.HUD_IDENTIFIERS.gameplay, arg_15_0.scoreCardNVM)
end

function GameplayScoreHud.updateGameTime(arg_16_0, arg_16_1, arg_16_2, arg_16_3, arg_16_4)
	arg_16_0:setHalfText(arg_16_2)

	if not arg_16_4 and arg_16_0.freezeClock then
		return
	end

	local var_16_0 = arg_16_1:getComponent("matchInfo")

	ASSERT(var_16_0)

	local var_16_1 = var_16_0:getTimePeriodSecondsRemaining(arg_16_2, arg_16_3)
	local var_16_2 = arg_16_0.scoreCardNVM

	ASSERT(var_16_2)

	var_16_2.ElapsedSeconds = var_16_1
end

function GameplayScoreHud.setHalfText(arg_17_0, arg_17_1)
	local var_17_0 = arg_17_0.scoreCardNVM

	ASSERT(var_17_0)

	local var_17_1 = arg_17_1:getMatchTimeEntity()
	local var_17_2 = arg_17_1:getMatchProgressionEntity().currentTimePeriod
	local var_17_3 = arg_17_1:getMatchProgressionEntity().currentExtraTimePeriod
	local var_17_4 = (var_17_3 == 0 or var_17_1.unlimitedExtraTimeActive) and "" or var_17_3

	if var_17_1.extraTimeActive then
		if var_17_1.goldenPointActive then
			var_17_0.HalfAbbr = native.Localise("ScoreHud_MatchStatus_GPAbbr", {
				timePeriod = var_17_4
			})
		elseif var_17_1.goldenTryActive then
			var_17_0.HalfAbbr = native.Localise("ScoreHud_MatchStatus_GTAbbr", {
				timePeriod = var_17_4
			})
		else
			var_17_0.HalfAbbr = native.Localise("ScoreHud_MatchStatus_ETAbbr", {
				timePeriod = var_17_3
			})
		end
	else
		var_17_0.HalfAbbr = native.Localise("ScoreHud_MatchStatus_HalfAbbr", {
			timePeriod = var_17_2
		})
	end
end

function GameplayScoreHud.update(arg_18_0, arg_18_1, arg_18_2, arg_18_3, arg_18_4, arg_18_5, arg_18_6, arg_18_7, arg_18_8, arg_18_9, arg_18_10, arg_18_11, arg_18_12)
	arg_18_0.scoreCardNVM:update(arg_18_8)

	-- referee-on-report: a queued banner waits for the scoreboard to be back on screen (the
	-- close-ups hide it), then OnReportBannerDelay more so it's seen sliding out.
	if arg_18_0.onReportQueued and arg_18_0.enabled then
		arg_18_0.onReportDelay = (arg_18_0.onReportDelay or 0) + arg_18_8

		if arg_18_0.onReportDelay >= OnReportBannerDelay then
			arg_18_0.scoreCardNVM.MatchStateMessage = arg_18_0.onReportQueued
			arg_18_0.scoreCardNVM.ShowMatchState = true
			arg_18_0.onReportTimer = OnReportBannerSeconds

			local var_18_r = rawget(_G, "OnReportState")

			if var_18_r and var_18_r.log then
				var_18_r.log("scoreboard: " .. arg_18_0.onReportQueued)
			end

			arg_18_0.onReportQueued = nil
			arg_18_0.onReportDelay = nil
		end
	elseif arg_18_0.onReportQueued then
		arg_18_0.onReportDelay = nil
	end

	-- referee-on-report: slide the banner back up once its time is up.
	if arg_18_0.onReportTimer then
		arg_18_0.onReportTimer = arg_18_0.onReportTimer - arg_18_8

		if arg_18_0.onReportTimer <= 0 then
			arg_18_0.onReportTimer = nil
			arg_18_0.scoreCardNVM.ShowMatchState = false
		end
	end

	if not arg_18_0.enabled then
		return
	end

	if not arg_18_0.services then
		ASSERT(arg_18_2)

		arg_18_0.services = arg_18_2
	end

	if not arg_18_0.jumbotron then
		arg_18_0.jumbotron = arg_18_2.uiServices.universe.NVMJumbotron
	end

	local var_18_0 = arg_18_0.scoreCardNVM

	ASSERT(var_18_0)

	local var_18_1 = arg_18_3:getComponent("matchInData")

	ASSERT(var_18_1)

	local var_18_2 = VERIFY(arg_18_5:getMatchProgressionEntity())
	local var_18_3 = var_18_2.tackleCount

	ASSERT(var_18_3)
	arg_18_0:updateGameTime(arg_18_3, arg_18_5, arg_18_9)

	local var_18_4 = var_18_2.nextTackleIsZero

	ASSERT(var_18_4 ~= nil)

	local var_18_5 = var_18_2.lastTackleWasZero

	ASSERT(var_18_5 ~= nil)

	local var_18_6 = var_18_2.stopTackleIsZero

	ASSERT(var_18_6 ~= nil)

	local var_18_7 = var_18_3 == 0 and (var_18_5 or var_18_6)
	local var_18_8 = var_18_3 == 0 and not var_18_5 and not var_18_6

	if var_18_3 ~= arg_18_0.tackleCount or var_18_4 and not arg_18_0.triggeredZeroTackle or var_18_8 then
		var_18_0:setTackleCount(var_18_3, var_18_4, var_18_7, var_18_1.matchType.maxTackleCount)

		arg_18_0.triggeredZeroTackle = var_18_4 and true or false
	end

	arg_18_0.tackleCount = var_18_3
	arg_18_0.freezeClock = not VERIFY(arg_18_5:getMatchTimeEntity()).isValid

	local var_18_9 = arg_18_5:getScoreEntity()

	ASSERT(var_18_9)

	if var_18_0:updateScores(var_18_1, var_18_9) and arg_18_0.jumbotron then
		arg_18_0.jumbotron:updateScores(arg_18_0.scoreCardNVM.HomeScore, arg_18_0.scoreCardNVM.AwayScore)
	end
end

function GameplayScoreHud.render(arg_19_0, arg_19_1, arg_19_2, arg_19_3)
	return
end

function GameplayScoreHud.setTimer(arg_20_0, arg_20_1, arg_20_2)
	return
end

function GameplayScoreHud.show(arg_21_0, arg_21_1)
	arg_21_0.scoreCardNVM.IsVisible = true
	arg_21_0.enabled = true
end

function GameplayScoreHud.hide(arg_22_0)
	arg_22_0.enabled = false
	arg_22_0.scoreCardNVM.IsVisible = false
end

function GameplayScoreHud.onAdvantagePaid(arg_23_0)
	ASSERT(arg_23_0.scoreCardNVM)
	arg_23_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_KnockOnAdvantage"))
end

function GameplayScoreHud.onAdvantageInterruptedEvent(arg_24_0)
	ASSERT(arg_24_0.scoreCardNVM)
	arg_24_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_AdvantageInterrupted"))
end

function GameplayScoreHud.onCaughtInGoal(arg_25_0)
	ASSERT(arg_25_0.scoreCardNVM)
	arg_25_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_CaughtInGoal"))
end

function GameplayScoreHud.onConversion(arg_26_0, arg_26_1)
	ASSERT(arg_26_1)

	local var_26_0 = arg_26_1.wasSuccessful

	ASSERT(var_26_0 ~= nil)
	ASSERT(arg_26_0.scoreCardNVM)

	local var_26_1 = arg_26_1.kickerSide

	if var_26_0 then
		arg_26_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_Conversion"), true, var_26_1)
	else
		arg_26_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_ConversionFailed"), false, var_26_1)
	end
end

function GameplayScoreHud.onFieldGoalSuccess(arg_27_0)
	ASSERT(arg_27_0.scoreCardNVM)
	arg_27_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_FieldGoal"), true)
end

function GameplayScoreHud.onForwardPass(arg_28_0)
	ASSERT(arg_28_0.scoreCardNVM)
	arg_28_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_ForwardPass"))
end

function GameplayScoreHud.onHandOver(arg_29_0, arg_29_1, arg_29_2, arg_29_3, arg_29_4, arg_29_5, arg_29_6, arg_29_7, arg_29_8, arg_29_9, arg_29_10, arg_29_11, arg_29_12)
	ASSERT(arg_29_0.scoreCardNVM)
	arg_29_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_HandOver"))
end

function GameplayScoreHud.onHeldInTackleWarning(arg_30_0)
	ASSERT(arg_30_0.scoreCardNVM)
end

function GameplayScoreHud.onHeldInTacklePenalty(arg_31_0)
	ASSERT(arg_31_0.scoreCardNVM)
	arg_31_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_HeldInTackle"))
end

function GameplayScoreHud.onInTouch(arg_32_0, arg_32_1)
	ASSERT(arg_32_0.scoreCardNVM)

	if arg_32_1.isInTouchOnFull then
		arg_32_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_InTouchOnFull"))
	elseif arg_32_1.isDeadBall then
		arg_32_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_DeadInGoal"))
	elseif arg_32_1.isInTouchInGoal then
		arg_32_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_InTouchInGoal"))
	else
		arg_32_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_InTouch"))
	end
end

function GameplayScoreHud.onNoAdvantage(arg_33_0, arg_33_1)
	ASSERT(arg_33_0.scoreCardNVM)
	ASSERT(arg_33_1.isDoubleKnockOn ~= nil)

	if arg_33_1.isDoubleKnockOn then
		arg_33_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_DoubleKnockOn"))
	elseif arg_33_1.isAccidentalKnockOn then
		arg_33_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_AccidentalKnockOn"))
	elseif arg_33_1.isAccidentalOffside then
		arg_33_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_AccidentalOffside"))
	else
		arg_33_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_KnockOnNoAdvantage"))
	end
end

function GameplayScoreHud.onPenaltyAwarded(arg_34_0, arg_34_1)
	ASSERT(arg_34_0.scoreCardNVM)

	if arg_34_1.infringmentType == var_0_0.OffSide then
		arg_34_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_Offside"))
	elseif arg_34_1.infringmentType == var_0_0.HighTackle then
		arg_34_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_HighTackle"))
	elseif arg_34_1.infringmentType == var_0_0.InTouchOnFull then
		arg_34_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_InTouchOnFull"))
	elseif arg_34_1.infringmentType == var_0_0.HeldInTackle then
		arg_34_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_HeldInTackle"))
	elseif arg_34_1.infringmentType == var_0_0.KickTooShort then
		arg_34_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_KickTooShort"))
	elseif arg_34_1.infringmentType == var_0_0.TimerExpired then
		arg_34_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_TimerExpired"))
	elseif arg_34_1.infringmentType == var_0_0.IllegalTackle then
		arg_34_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_IllegalTackle"))
	elseif arg_34_1.infringmentType == var_0_0.IllegalBallStrip then
		arg_34_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_IllegalBallStrip"))
	elseif arg_34_1.infringmentType == var_0_0.TackleOffBall then
		arg_34_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_TackleOffBall"))
	end
end

function GameplayScoreHud.onShowIllegalBallStripHud(arg_35_0, arg_35_1)
	arg_35_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_IllegalBallStrip"))
end

function GameplayScoreHud.onPenaltyGoalSuccess(arg_36_0)
	ASSERT(arg_36_0.scoreCardNVM)
	arg_36_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_PenaltyGoal"), true)
end

function GameplayScoreHud.onPlaceKickFeedback(arg_37_0, arg_37_1)
	ASSERT(arg_37_0.scoreCardNVM)

	local var_37_0 = arg_37_1.number
	local var_37_1 = math.floor(math.abs(var_37_0) + 0.5)

	if var_37_1 > 0 then
		local var_37_2 = var_37_1 == 1 and native.Localise("Degree") or native.Localise("Degrees")
		local var_37_3 = var_37_0 > 0 and native.Localise("Right") or native.Localise("Left")
		local var_37_4 = stringFormatT("%i %s %s", var_37_1, var_37_2, var_37_3)

		arg_37_0.scoreCardNVM:displayEventInfo(var_37_4)
	end
end

function GameplayScoreHud.onTackledInGoalEvent(arg_38_0)
	ASSERT(arg_38_0.scoreCardNVM)
	arg_38_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_TackleInGoal"))
end

function GameplayScoreHud.onSendOffFinalWarning(arg_39_0)
	ASSERT(arg_39_0.scoreCardNVM)
	arg_39_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_SendOffFinalWarning"))
end

function GameplayScoreHud.onSinBinFinalWarning(arg_40_0)
	ASSERT(arg_40_0.scoreCardNVM)
	arg_40_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_SinBinFinalWarning"))
end

function GameplayScoreHud.onPlayerSentToSinBin(arg_41_0)
	ASSERT(arg_41_0.scoreCardNVM)
	arg_41_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_SinBin"))
end

function GameplayScoreHud.onSinBinCompleted(arg_42_0, arg_42_1)
	ASSERT(arg_42_0.scoreCardNVM)
	arg_42_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_SinBinCompleted"))
end

function GameplayScoreHud.onTwentyFifty(arg_43_0, arg_43_1)
	ASSERT(arg_43_0.scoreCardNVM)
	arg_43_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_TwentyFifty"))
end

function GameplayScoreHud.onTwentyForty(arg_44_0, arg_44_1)
	ASSERT(arg_44_0.scoreCardNVM)
	arg_44_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_TwentyForty"))
end

function GameplayScoreHud.onFortyThirty(arg_45_0, arg_45_1)
	ASSERT(arg_45_0.scoreCardNVM)
	arg_45_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_FortyThirty"))
end

function GameplayScoreHud.onFortyTwenty(arg_46_0, arg_46_1)
	ASSERT(arg_46_0.scoreCardNVM)
	arg_46_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_FortyTwenty"))
end

function GameplayScoreHud.onTapRestart(arg_47_0, arg_47_1)
	return
end

function GameplayScoreHud.onTackleCompleted(arg_48_0, arg_48_1, arg_48_2, arg_48_3, arg_48_4, arg_48_5, arg_48_6, arg_48_7, arg_48_8, arg_48_9)
	return
end

function GameplayScoreHud.onPlayTheBall(arg_49_0, arg_49_1, arg_49_2, arg_49_3, arg_49_4, arg_49_5, arg_49_6, arg_49_7, arg_49_8, arg_49_9)
	local var_49_0 = arg_49_7:getBallEntity()

	ASSERT(var_49_0)
	ASSERT(arg_49_1)

	local var_49_1 = arg_49_1.time

	ASSERT(var_49_1)

	local var_49_2 = var_49_0:getOwnerId(arg_49_1.time)
	local var_49_3 = arg_49_1.maker

	ASSERT(var_49_3)

	if not var_49_2 or var_49_2 ~= var_49_3 then
		return
	end

	local var_49_4 = VERIFY(arg_49_7:getMatchProgressionEntity())
	local var_49_5 = VERIFY(arg_49_6:getComponent("matchInData")).matchType

	ASSERT(var_49_5)

	local var_49_6 = var_49_5.maxTackleCount

	ASSERT(var_49_6)

	local var_49_7 = var_49_4.tackleCount

	ASSERT(var_49_7)

	if var_49_7 == var_49_6 then
		local var_49_8 = arg_49_6:getComponent("statistics")

		ASSERT(var_49_8)

		local var_49_9 = var_49_8:getSetMetersGained()

		ASSERT(var_49_9)
		ASSERT(arg_49_0.scoreCardNVM)
		arg_49_0.scoreCardNVM:displayEventInfo(math.floor(var_49_9) .. " " .. native.Localise("Hud_MetresGained"), false, arg_49_1.side)
	end
end

function GameplayScoreHud.onTouchedInGoal(arg_50_0)
	ASSERT(arg_50_0.scoreCardNVM)
	arg_50_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_TouchedInGoal"))
end

function GameplayScoreHud.onTryScored(arg_51_0, arg_51_1)
	ASSERT(arg_51_0.scoreCardNVM)
	ASSERT(arg_51_1)

	if arg_51_1.videoRefereeRequired then
		return
	end

	ASSERT(arg_51_1.tryAttemptOutcome)

	local var_51_0 = arg_51_1.scoringSide

	if arg_51_1.tryAttemptOutcome == native.ETryAttemptOutcome.Try then
		arg_51_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_Try"), true, var_51_0)
	elseif arg_51_1.tryAttemptOutcome == native.ETryAttemptOutcome.HeldUp then
		arg_51_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_HeldUp"), false, var_51_0)
	elseif arg_51_1.tryAttemptOutcome == native.ETryAttemptOutcome.PenaltyTry then
		arg_51_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_PenaltyTry"), true, var_51_0)
	end
end

function GameplayScoreHud.onPlayerOffEvent(arg_52_0, arg_52_1)
	return
end

function GameplayScoreHud.onSixAgainEvent(arg_53_0, arg_53_1)
	ASSERT(arg_53_0.scoreCardNVM)

	if arg_53_1.consecutiveSixAgainsAwarded == arg_53_1.maxConsecutiveSixAgainsBeforePenalty then
		arg_53_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_SixAgainPenaltyWarning"))
	else
		arg_53_0.scoreCardNVM:displayEventInfo(native.Localise("Hud_SixAgain"))
	end
end

function GameplayScoreHud.showTryConfirmed(arg_54_0)
	arg_54_0.scoreCardNVM:showTryConfirmed()
end

-- referee-on-report: the referee's Report signal (the report close-up rolled and queued in
-- rules/penalty/penalty.lua) shows "<NAME> ON REPORT" under the scoreboard.
function GameplayScoreHud.onRefereeSignal(arg_55_0, arg_55_1)
	if arg_55_1.signalType ~= native.EUmpireSignalTypes.Report then
		return
	end

	local var_55_0 = rawget(_G, "OnReportState")
	local var_55_1 = var_55_0 and var_55_0.pending

	if not var_55_1 then
		return
	end

	var_55_0.pending = nil

	local var_55_2 = string.upper(var_55_1.surname or "")
	local var_55_3 = var_55_2 ~= "" and var_55_2 .. " ON REPORT" or "ON REPORT"

	-- Shown by update() once the scoreboard is back after the close-up.
	arg_55_0.onReportQueued = var_55_3
	arg_55_0.onReportDelay = nil

	if var_55_0.log then
		var_55_0.log("report signalled, banner queued: " .. var_55_3)
	end
end
