import("game.umpire.umpiretype")
import("script-config.design.sound.soundmap_banks")
import("script-config.design.sound.soundmap_switches")
import("rules.penalty.penaltytypes")
import("ai.officials.refereesignaltypes")

local var_0_0 = penaltytypes.infringementTypes
local var_0_1 = native.getEnvironment():argExists("debugSound")
local var_0_2
local var_0_3
local var_0_4 = "Referee"

-- The stock referee banks have no "field goal" line. This one is added to the
-- blobset by tools/add_sound_bank.py (bank and event share the name). Loading a
-- bank that isn't in the blobset is a native fatal error (pcall can't catch it),
-- so only enable this once the bank is installed.
local FieldGoalCallEnabled = false
local FieldGoalCallBank = "sfx_ref_field_goal"
local FieldGoalCallDelay = 0.8

-- bunker-broadcast-decision: seconds from VideoRefereeDecisionEvent to the try whistle.
local BunkerTryWhistleDelay = 3.25

Class("SoundListenerReferee", function(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6)
	arg_1_0.soundSystem = arg_1_1
	arg_1_0.soundManager = arg_1_5
	arg_1_0.enabled = true
	arg_1_0.isPracticeMode = arg_1_4.gameMode == native.EGameMode.Practice
	arg_1_0.soundObject = "Referee"

	local var_1_0 = soundmap_banks.Banks

	table.insert(arg_1_2, var_1_0.OnfieldRefereeVocals)
	table.insert(arg_1_2, var_1_0.RefereeWhistle)
end)

function SoundListenerReferee.unload(arg_2_0)
	if not arg_2_0.enabled then
		return
	end

	arg_2_0.soundManager:unregisterGameObject(arg_2_0.soundObject)

	if arg_2_0.fieldGoalCallLoaded then
		arg_2_0.fieldGoalCallLoaded = false

		pcall(function()
			arg_2_0.soundManager:unloadBank(FieldGoalCallBank)
		end)
	end
end

function SoundListenerReferee.registerWithMatchSim(arg_3_0, arg_3_1)
	if not arg_3_0.enabled then
		return
	end

	local var_3_0 = arg_3_0.soundSystem

	var_3_0:registerSoundOnlyEvents(arg_3_0, {
		KickTooShortSoundEvent = arg_3_0.onKickTooShortSoundEvent,
		ScrumEvent = arg_3_0.onScrumEvent,
		TryCelebrateEvent = arg_3_0.onTryCelebrateEvent,
		VideoRefereeDecisionEvent = arg_3_0.onVideoRefereeDecisionEvent
	})

	local var_3_1

	if arg_3_0.isPracticeMode then
		var_3_1 = {
			TutorialEvent = arg_3_0.onTutorialEvent
		}
	else
		var_3_1 = {
			AdvanceToNextTimePeriodEvent = arg_3_0.onAdvanceToNextTimePeriodEvent,
			AdvantagePaidEvent = arg_3_0.onAdvantagePaidEvent,
			ConversionOutcomeEvent = arg_3_0.onConversionOutcomeEvent,
			ConversionTimeoutEvent = arg_3_0.onConversionTimeoutEvent,
			FieldGoalSuccessEvent = arg_3_0.onFieldGoalSuccessEvent,
			GameOverEvent = arg_3_0.onGameOverEvent,
			HandOverEvent = arg_3_0.onHandOverEvent,
			IncrementTackleCountEvent = arg_3_0.onIncrementTackleCountEvent,
			InjuryEvent = arg_3_0.onInjuryEvent,
			InTouchEvent = arg_3_0.onInTouchEvent,
			KnockOnEvent = arg_3_0.onKnockOnEvent,
			NoAdvantageEvent = arg_3_0.onNoAdvantageEvent,
			PenaltyAwardedEvent = arg_3_0.onPenaltyAwardedEvent,
			PenaltyGoalSuccessEvent = arg_3_0.onPenaltyGoalSuccessEvent,
			PlayerSentOffEvent = arg_3_0.onPlayerSentOffEvent,
			RefereeSignalEvent = arg_3_0.onRefereeSignalEvent,
			SendOffFinalWarningEvent = arg_3_0.onSendOffFinalWarningEvent,
			SinBinFinalWarningEvent = arg_3_0.onSinBinFinalWarningEvent,
			TackleCompletedEvent = arg_3_0.onTackleCompletedEvent,
			TryScoredEvent = arg_3_0.onTryScoredEvent
		}
	end

	var_3_0:registerSolidEvents(arg_3_0, arg_3_1, var_3_1)
end

function SoundListenerReferee.soundObjectsInit(arg_4_0)
	local var_4_0 = arg_4_0.soundSystem
	local var_4_1 = arg_4_0.soundManager
	local var_4_2 = arg_4_0.refereeObject.identity.sex.isFemale
	local var_4_3 = arg_4_0.soundObject

	var_4_1:registerGameObject(arg_4_0.soundObject)

	local var_4_4 = soundmap_switches.Switches.Match_Gender_Switch
	local var_4_5 = var_4_4.switchNames
	local var_4_6 = var_4_2 and var_4_5.Female or var_4_5.Male

	var_4_1:setSwitchValue(var_4_4.switchGroup, var_4_6, var_4_3)

	local var_4_7 = var_4_0.refereeDialogueSystem
	local var_4_8 = soundmap_switches.Switches.sfxSwitchRefereeVocal
	local var_4_9 = var_4_8.switchNames
	local var_4_10 = var_4_7.ausRef and var_4_9.Dru or var_4_9.Oscar

	var_4_0:prepareSwitch(var_4_8, var_4_10)
	var_4_1:setSwitchValue(var_4_8.switchGroup, var_4_10, var_4_3)

	if FieldGoalCallEnabled and not arg_4_0.isPracticeMode then
		arg_4_0.fieldGoalCallLoaded = pcall(function()
			var_4_1:loadTransitionBank(FieldGoalCallBank)
		end)
	end
end

function SoundListenerReferee.stopAllEventsAndClearQueue(arg_5_0)
	if not arg_5_0.enabled then
		return
	end

	var_0_3(arg_5_0)
end

function SoundListenerReferee.update(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6)
	if not arg_6_0.enabled then
		return
	end

	if not arg_6_0.initialized then
		arg_6_0.initialized = true

		for iter_6_0, iter_6_1 in arg_6_4:activeObjects(umpiretype.TypeId) do
			if iter_6_1:getAssignedRole(arg_6_3) == native.EOfficialRole.Referee then
				arg_6_0.refereeObject = iter_6_1
			end
		end

		arg_6_0:soundObjectsInit()
	end
end

function SoundListenerReferee.onTutorialEvent(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7, arg_7_8, arg_7_9)
	if arg_7_1.subType == "TutorialTackleCompletedEvent" then
		var_0_2(arg_7_0, "Whistle_Tutorial_Tackle")
	end
end

function SoundListenerReferee.onAdvanceToNextTimePeriodEvent(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5, arg_8_6, arg_8_7, arg_8_8, arg_8_9)
	if arg_8_1.currentTimePeriod == 1 then
		var_0_2(arg_8_0, "Whistle_Half_Time")
	end
end

function SoundListenerReferee.onAdvantagePaidEvent(arg_9_0, arg_9_1, arg_9_2, arg_9_3, arg_9_4, arg_9_5, arg_9_6, arg_9_7, arg_9_8, arg_9_9)
	var_0_2(arg_9_0, "sfxRefAdvantage")
end

function SoundListenerReferee.onConversionOutcomeEvent(arg_10_0, arg_10_1, arg_10_2, arg_10_3, arg_10_4, arg_10_5, arg_10_6, arg_10_7, arg_10_8, arg_10_9)
	if arg_10_1.wasSuccessful then
		var_0_2(arg_10_0, "Whistle_Penalty", {
			delay = 0.2
		})
	end
end

function SoundListenerReferee.onConversionTimeoutEvent(arg_11_0, arg_11_1, arg_11_2, arg_11_3, arg_11_4, arg_11_5, arg_11_6, arg_11_7, arg_11_8, arg_11_9)
	var_0_2(arg_11_0, "Whistle_TimeExpired")
end

function SoundListenerReferee.onFieldGoalSuccessEvent(arg_12_0, arg_12_1, arg_12_2, arg_12_3, arg_12_4, arg_12_5, arg_12_6, arg_12_7, arg_12_8, arg_12_9)
	arg_12_0:stopAllEventsAndClearQueue()
	var_0_2(arg_12_0, "Whistle_Penalty", {
		delay = 0.2
	})

	if arg_12_0.fieldGoalCallLoaded then
		var_0_2(arg_12_0, FieldGoalCallBank, {
			wwiseEvent = FieldGoalCallBank,
			delay = FieldGoalCallDelay
		})
	end
end

function SoundListenerReferee.onGameOverEvent(arg_13_0, arg_13_1, arg_13_2, arg_13_3, arg_13_4, arg_13_5, arg_13_6, arg_13_7, arg_13_8, arg_13_9)
	var_0_2(arg_13_0, "Whistle_Full_Time")
end

function SoundListenerReferee.onHandOverEvent(arg_14_0, arg_14_1, arg_14_2, arg_14_3, arg_14_4, arg_14_5, arg_14_6, arg_14_7, arg_14_8, arg_14_9)
	arg_14_0:stopAllEventsAndClearQueue()
	var_0_2(arg_14_0, "sfxRefHandover")
end

function SoundListenerReferee.onIncrementTackleCountEvent(arg_15_0, arg_15_1, arg_15_2, arg_15_3, arg_15_4, arg_15_5, arg_15_6, arg_15_7, arg_15_8, arg_15_9)
	local var_15_0 = VERIFY(arg_15_7:getMatchProgressionEntity()).tackleCount

	if var_15_0 == 0 then
		var_0_2(arg_15_0, "sfxRefZeroTackle")
	elseif var_15_0 == 1 then
		var_0_2(arg_15_0, "sfxRefFirstTackle")
	elseif var_15_0 == 2 then
		var_0_2(arg_15_0, "sfxRefSecondTackle")
	elseif var_15_0 == 3 then
		var_0_2(arg_15_0, "sfxRefThirdTackle")
	elseif var_15_0 == 4 then
		var_0_2(arg_15_0, "sfxRefFourthTackle")
	elseif var_15_0 == 5 then
		var_0_2(arg_15_0, "sfxRefFifthTackle")
	end
end

function SoundListenerReferee.onInjuryEvent(arg_16_0, arg_16_1, arg_16_2, arg_16_3, arg_16_4, arg_16_5, arg_16_6, arg_16_7, arg_16_8, arg_16_9)
	if arg_16_1.severity == native.EInjurySeverity.Serious then
		var_0_2(arg_16_0, "sfxRefInjury")
	end
end

function SoundListenerReferee.onInTouchEvent(arg_17_0, arg_17_1, arg_17_2, arg_17_3, arg_17_4, arg_17_5, arg_17_6, arg_17_7, arg_17_8, arg_17_9)
	arg_17_0:stopAllEventsAndClearQueue()
	var_0_2(arg_17_0, "Whistle_Out_Of_Play")
end

function SoundListenerReferee.onKickTooShortSoundEvent(arg_18_0, arg_18_1, arg_18_2, arg_18_3, arg_18_4, arg_18_5, arg_18_6)
	var_0_2(arg_18_0, "Whistle_Penalty")
end

function SoundListenerReferee.onKnockOnEvent(arg_19_0, arg_19_1, arg_19_2, arg_19_3, arg_19_4, arg_19_5, arg_19_6, arg_19_7, arg_19_8, arg_19_9)
	arg_19_0:stopAllEventsAndClearQueue()
	var_0_2(arg_19_0, "sfxRefAdvantageKnockOn", {
		delay = 1
	})
end

function SoundListenerReferee.onNoAdvantageEvent(arg_20_0, arg_20_1, arg_20_2, arg_20_3, arg_20_4, arg_20_5, arg_20_6, arg_20_7, arg_20_8, arg_20_9)
	arg_20_0:stopAllEventsAndClearQueue()
	var_0_2(arg_20_0, "Whistle_Knockon")
	var_0_2(arg_20_0, "sfxRefKnockOn")
end

function SoundListenerReferee.onPenaltyAwardedEvent(arg_21_0, arg_21_1, arg_21_2, arg_21_3, arg_21_4, arg_21_5, arg_21_6, arg_21_7, arg_21_8, arg_21_9)
	arg_21_0:stopAllEventsAndClearQueue()

	local var_21_0 = arg_21_1.infringementType
	local var_21_1
	local var_21_2 = "Whistle_Penalty"
	local var_21_3 = "sfxRefPenalty"

	if var_21_0 == var_0_0.OffSide then
		var_21_1 = {
			delay = 1
		}
	elseif var_21_0 == var_0_0.HeldInTackle then
		var_21_1 = {
			delay = 1
		}
	elseif var_21_0 == var_0_0.TimerExpired then
		var_21_2 = "Whistle_TimeExpired"
	end

	var_0_2(arg_21_0, var_21_2, var_21_1)
	var_0_2(arg_21_0, var_21_3, var_21_1)
end

function SoundListenerReferee.onPenaltyGoalSuccessEvent(arg_22_0, arg_22_1, arg_22_2, arg_22_3, arg_22_4, arg_22_5, arg_22_6, arg_22_7, arg_22_8, arg_22_9)
	var_0_2(arg_22_0, "Whistle_Penalty", {
		delay = 0.2
	})
end

function SoundListenerReferee.onPlayerSentOffEvent(arg_23_0, arg_23_1, arg_23_2, arg_23_3, arg_23_4, arg_23_5, arg_23_6, arg_23_7, arg_23_8, arg_23_9)
	var_0_2(arg_23_0, "sfxRefSendOff")
end

function SoundListenerReferee.onRefereeSignalEvent(arg_24_0, arg_24_1, arg_24_2, arg_24_3, arg_24_4, arg_24_5, arg_24_6, arg_24_7, arg_24_8, arg_24_9)
	local var_24_0
	local var_24_1
	local var_24_2
	local var_24_3 = arg_24_1.signalType

	if var_24_3 == refereesignaltypes.ForwardPass then
		arg_24_0:stopAllEventsAndClearQueue()

		var_24_0 = "Whistle_Forward_Pass"
		var_24_1 = "sfxRefForwardPass"
	elseif var_24_3 == refereesignaltypes.HeldUp then
		var_24_0 = "Whistle_Knockon"
		var_24_1 = "sfxRefNoTryHeldUp"
	elseif var_24_3 == refereesignaltypes.KickOff then
		var_24_0 = "Whistle_Start_of_Game"
	elseif var_24_3 == refereesignaltypes.Scrum then
		var_24_0 = "Whistle_Out_Of_Play"
		var_24_2 = {
			delay = 0.4
		}
	elseif var_24_3 == refereesignaltypes.StopPlayBunker then
		var_24_0 = "Whistle_Videoref"
	elseif var_24_3 == refereesignaltypes.TapRestart then
		var_24_0 = "Whistle_Penalty"
		var_24_2 = {
			delay = 0.4
		}
	elseif var_24_3 == refereesignaltypes.Try then
		arg_24_0:stopAllEventsAndClearQueue()

		var_24_0 = "Whistle_TryCameo"
		var_24_1 = "sfxRefTry"
	elseif var_24_3 == refereesignaltypes.VideoReferee then
		var_24_0 = "Whistle_Videoref"
		var_24_1 = "sfxRefVideoRefCheck"
	end

	if var_24_0 then
		var_0_2(arg_24_0, var_24_0, var_24_2)
	end

	if var_24_1 then
		var_0_2(arg_24_0, var_24_1, var_24_2)
	end
end

function SoundListenerReferee.onScrumEvent(arg_25_0, arg_25_1, arg_25_2, arg_25_3, arg_25_4, arg_25_5, arg_25_6)
	var_0_2(arg_25_0, "sfxRefScrum")
end

function SoundListenerReferee.onSendOffFinalWarningEvent(arg_26_0, arg_26_1, arg_26_2, arg_26_3, arg_26_4, arg_26_5, arg_26_6, arg_26_7, arg_26_8, arg_26_9)
	var_0_2(arg_26_0, "sfxRefSendoffWarning")
end

function SoundListenerReferee.onSinBinFinalWarningEvent(arg_27_0, arg_27_1, arg_27_2, arg_27_3, arg_27_4, arg_27_5, arg_27_6, arg_27_7, arg_27_8, arg_27_9)
	var_0_2(arg_27_0, "sfxRefSendoffWarning")
end

function SoundListenerReferee.onTackleCompletedEvent(arg_28_0, arg_28_1, arg_28_2, arg_28_3, arg_28_4, arg_28_5, arg_28_6, arg_28_7, arg_28_8, arg_28_9)
	var_0_2(arg_28_0, "sfxRefHeld")
end

function SoundListenerReferee.onTryCelebrateEvent(arg_29_0, arg_29_1, arg_29_2, arg_29_3, arg_29_4, arg_29_5, arg_29_6)
	var_0_2(arg_29_0, "Whistle_Try")
	var_0_2(arg_29_0, "sfxRefTry")
end

function SoundListenerReferee.onVideoRefereeDecisionEvent(arg_30_0, arg_30_1, arg_30_2, arg_30_3, arg_30_4, arg_30_5, arg_30_6)
	local var_30_0
	local var_30_1 = arg_30_1.isTry and "sfxRefTry" or "sfxRefNoTry"

	-- bunker-broadcast-decision: the try whistle blows as TRY lands on the bunker card
	-- (VideoRefHud swaps "Pending" for the decision 3 s in), ahead of the stock "Try!" call.
	if arg_30_1.bunkerBroadcast and arg_30_1.isTry then
		var_0_2(arg_30_0, "Whistle_Try", {
			delay = BunkerTryWhistleDelay
		})
	end

	var_0_2(arg_30_0, var_30_1, {
		delay = 4
	})
end

function var_0_2(arg_31_0, arg_31_1, arg_31_2)
	arg_31_2 = arg_31_2 or {}

	ASSERT(not arg_31_2.soundObject)

	arg_31_2.soundObject = arg_31_0.soundObject

	local var_31_0 = arg_31_0.refereeObject

	if var_31_0 then
		arg_31_2.worldPosition = var_31_0.pos3
		arg_31_2.worldDirection = var_31_0.facing:tovec3()
	end

	arg_31_2.queueTag = var_0_4

	arg_31_0.soundSystem:queueEvent(arg_31_1, arg_31_2, var_0_4)
end

function var_0_3(arg_32_0)
	arg_32_0.soundSystem:stopEvents({
		tags = {
			var_0_4
		}
	})
end
