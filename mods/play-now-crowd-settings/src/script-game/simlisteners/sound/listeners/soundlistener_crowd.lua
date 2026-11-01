import("ai.officials.refereesignaltypes")
import("base.side.sidehelper")
import("script-config.design.sound.soundmap")
import("script-config.design.sound.soundmap_banks")
import("script-config.design.sound.soundmap_rtpc")
import("script-config.design.sound.soundmap_switches")
import("script-config.design.sound.soundmap_states")

local var_0_0 = native.ESide.Home:toInt()
local var_0_1 = native.ESide.Away:toInt()
local var_0_2 = native.ESide.None:toInt()
local var_0_3 = 0
local var_0_4 = 100
local var_0_5 = soundmap_switches.Switches
local var_0_6 = soundmap_banks.Banks
local var_0_7 = soundmap_rtpc.inGameRTPCs
local var_0_8 = var_0_5.sfxSwitchTeamCountry
local var_0_9 = var_0_8.switchGroup
local var_0_10 = var_0_8.switchNames
local var_0_11 = load("simlisteners.sound.excitementlevel")
local var_0_12 = native.getEnvironment():argExists("debugSound")
local var_0_13 = native.getEnvironment():argExists("debugLoudspeakerMusic")
local var_0_14
local var_0_15
local var_0_16
local var_0_17
local var_0_18
local var_0_19
local var_0_20
local var_0_21 = soundmap.crowdOneShotSoundObjectTable
local var_0_22 = "Crowd"

-- play-now-crowd-settings: Play Now's Crowd Settings page (choose-play-now-referee's
-- casual_newmatch.lua) sets the attendance and the home/away split for Play Now
-- matches: _G.modPlayNowCrowd = { attendance = 0..100, homeFans = 0..100 } for the
-- session, saved as playnow_attendance / playnow_home_fans in rl26_revamp.ini.
-- crowd-team-kits' crowd_rugby.lua fills the seats to match. Here: no attendance
-- means no crowd sound at all (the listener stays disabled, which the crowd already
-- copes with: Crowd.setCrowdSound ignores a disabled listener), and the home/away
-- chant loudness follows the split instead of the stock 65/45.
local MOD_CROWD_FILE = "rl26_revamp.ini"
local MOD_CROWD_DEFAULTS = {
	attendance = 70,
	homeFans = 80
}

function modPlayNowCrowdSettings(matchInData)
	if not matchInData or matchInData.gameMode ~= native.EGameMode.Casual then
		return nil
	end

	local settings = rawget(_G, "modPlayNowCrowd")

	if type(settings) ~= "table" then
		settings = {
			attendance = MOD_CROWD_DEFAULTS.attendance,
			homeFans = MOD_CROWD_DEFAULTS.homeFans
		}

		pcall(function()
			local file = io.open(MOD_CROWD_FILE, "r")

			if file then
				for line in file:lines() do
					local key, value = line:match("^%s*([%w_]+)%s*=%s*(%d+)")

					if key == "playnow_attendance" then
						settings.attendance = math.min(100, tonumber(value))
					elseif key == "playnow_home_fans" then
						settings.homeFans = math.min(100, tonumber(value))
					end
				end

				file:close()
			end
		end)
	end

	return settings
end

Class("SoundListenerCrowd", function(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7)
	arg_1_0.soundSystem = arg_1_1
	arg_1_0.soundManager = arg_1_5
	arg_1_0.enabled = true

	-- play-now-crowd-settings: an empty ground is silent
	local modOk, modSettings = pcall(modPlayNowCrowdSettings, arg_1_3 and arg_1_3.matchInData)

	arg_1_0.modCrowdSettings = modOk and modSettings or nil

	if arg_1_0.modCrowdSettings and arg_1_0.modCrowdSettings.attendance <= 0 then
		arg_1_0.enabled = false
	end

	if not arg_1_0.enabled then
		return
	end

	arg_1_0.crowdSystem = arg_1_7

	arg_1_0:initCrowdEmitters()
	arg_1_0:initCrowdSize(arg_1_3)
	arg_1_0:initTeamSupport(arg_1_3)
	table.insert(arg_1_2, var_0_6.Crowd)
	table.insert(arg_1_2, var_0_6.Loudspeaker_Crowd_Mx_ClapAlong)

	arg_1_0.crowdPercentage = -1
	arg_1_0.markerCallbacks = var_0_16(arg_1_0, arg_1_5, arg_1_6)
	arg_1_0.localGamerIsWinning = false

	local var_1_0 = var_0_3
	local var_1_1 = var_0_4

	arg_1_0.crowdExcitementValues = {
		prevValueSentToWwise = -1,
		rtpc = var_0_7.crowdExcitement.rtpc,
		min = var_1_0,
		max = var_1_1,
		base = var_1_0,
		extra = {
			value = 0,
			duration = 0
		}
	}
end)

function SoundListenerCrowd.initCrowdEmitters(arg_2_0)
	local var_2_0 = arg_2_0.soundManager
	local var_2_1 = {
		"crowd_emitter_1",
		"crowd_emitter_2",
		"crowd_emitter_3",
		"crowd_emitter_4",
		"crowd_emitter_5",
		"crowd_emitter_6"
	}
	local var_2_2 = soundmap.CrowdEmittersMap.DEFAULT

	for iter_2_0, iter_2_1 in ipairs(var_2_1) do
		var_2_0:registerGameObject(iter_2_1)

		local var_2_3 = var_2_2[iter_2_0]

		var_2_0:setGameObjectPosition(var_2_1[iter_2_0], var_2_3.x, var_2_3.y, var_2_3.z, var_2_3.rx, var_2_3.ry, var_2_3.rz, true)
	end

	arg_2_0.crowdSweetenerObjects = var_2_1
end

function SoundListenerCrowd.initCrowdSize(arg_3_0, arg_3_1)
	local var_3_0 = arg_3_0.soundSystem
	local var_3_1 = arg_3_0.soundManager
	local var_3_2 = arg_3_1.matchInData
	local var_3_3 = var_3_2 and var_3_2.trainingMode
	local var_3_4 = arg_3_1.matchInfo.ground
	local var_3_5 = soundmap.StadiumSizeMap[var_3_4] or "Medium"
	local var_3_6 = soundmap_states.States.CrowdSize_State
	local var_3_7 = var_3_6.stateNames
	local var_3_8 = var_0_5.CrowdSize_Switch
	local var_3_9 = var_3_8.switchGroup
	local var_3_10 = var_3_8.switchNames
	local var_3_11
	local var_3_12

	if var_3_3 then
		var_3_11 = var_3_7.ParkGround
		var_3_12 = var_3_10.ParkGround
	else
		var_3_11 = var_3_7[var_3_5] or var_3_7.Medium
		var_3_12 = var_3_10[var_3_5] or var_3_10.Medium
	end

	var_3_0:prepareState(var_3_6, var_3_11)
	var_3_1:setStateValue(var_3_6.stateGroup, var_3_11)
	var_3_0:prepareSwitch(var_3_8, var_3_12)
	var_3_1:setSwitchValue(var_3_9, var_3_12)

	for iter_3_0, iter_3_1 in pairs(var_0_21) do
		var_3_1:registerGameObject(iter_3_1)
		var_3_1:setSwitchValue(var_3_9, var_3_12, iter_3_1)
	end

	arg_3_0:calculateCrowdBias()

	local var_3_13 = {
		"crowd_pos_loop_1",
		"crowd_pos_loop_2",
		"crowd_pos_loop_3"
	}
	local var_3_14 = soundmap.CrowdPositionalLoopMap.DEFAULT

	for iter_3_2, iter_3_3 in ipairs(var_3_13) do
		var_3_1:registerGameObject(iter_3_3)

		local var_3_15 = var_3_14[iter_3_2]

		var_3_1:setGameObjectPosition(var_3_13[iter_3_2], var_3_15.x, var_3_15.y, var_3_15.z, var_3_15.rx, var_3_15.ry, var_3_15.rz, true)
		var_3_1:setSwitchValue(var_3_9, var_3_12, var_3_13[iter_3_2])
	end

	arg_3_0.crowdLoopPositionalObjects = var_3_13
end

function SoundListenerCrowd.initTeamSupport(arg_4_0, arg_4_1)
	local var_4_0 = arg_4_0.soundSystem
	local var_4_1 = arg_4_0.soundManager
	local var_4_2 = {
		[var_0_0] = "teamSupportHomeObject",
		[var_0_1] = "teamSupportAwayObjects"
	}

	for iter_4_0, iter_4_1 in pairs(var_4_2) do
		var_4_1:registerGameObject(iter_4_1)
	end

	local var_4_3 = var_0_10.noCountry
	local var_4_4 = arg_4_1.home.matchClub
	local var_4_5 = arg_4_1.away.matchClub
	local var_4_6 = var_4_4 and var_4_4.clubAffiliation
	local var_4_7 = var_4_5 and var_4_5.clubAffiliation
	local var_4_8 = var_4_6 and var_0_10[var_4_6] or var_4_3
	local var_4_9 = var_4_7 and var_0_10[var_4_7] or var_4_3

	var_4_0:prepareSwitch(var_0_8, var_4_8)
	var_4_0:prepareSwitch(var_0_8, var_4_9)
	var_4_1:setSwitchValue(var_0_9, var_4_8, var_4_2[var_0_0])
	var_4_1:setSwitchValue(var_0_9, var_4_9, var_4_2[var_0_1])

	arg_4_0.teamSupportSoundObjects = var_4_2

	local var_4_10 = "crowdChantObject"

	var_4_1:registerGameObject(var_4_10)

	local var_4_11 = var_0_5.National_Chants_Active_Switch
	local var_4_12 = var_4_11.switchNames
	local var_4_13 = var_4_8 ~= var_4_3 and var_4_8 == var_4_9
	local var_4_14 = var_4_13 and var_4_12.disabled or var_4_12.active

	var_4_0:prepareSwitch(var_4_11, var_4_14)
	var_4_1:setSwitchValue(var_4_11.switchGroup, var_4_14, var_4_10)

	arg_4_0.crowdChantObject = var_4_10
	arg_4_0.teamChantSwitchValues = {
		home = var_4_13 and var_4_3 or var_4_8,
		away = var_4_13 and var_4_3 or var_4_9
	}
end

function var_0_16(arg_5_0, arg_5_1, arg_5_2)
	local var_5_0 = {}
	local var_5_1 = var_0_6.Loudspeaker_Crowd_Mx_ClapAlong.sounds

	for iter_5_0, iter_5_1 in pairs(var_5_1) do
		var_5_0[iter_5_0] = function()
			if arg_5_0.localGamerIsWinning or var_0_13 then
				var_0_14(arg_5_0, iter_5_0, {
					soundObject = var_0_21.all
				})
			end
		end
	end

	for iter_5_2, iter_5_3 in pairs(var_5_0) do
		arg_5_1:addMarkerCallback(iter_5_2, iter_5_3)
	end

	return var_5_0
end

function SoundListenerCrowd.onCrowdLoaded(arg_7_0, arg_7_1)
	if not arg_7_0.enabled then
		return
	end

	arg_7_0.soundManager:setGlobalRTPC(var_0_7.crowdMaxAttendance.rtpc, arg_7_1)
end

function SoundListenerCrowd.calculateCrowdBias(arg_8_0)
	local var_8_0 = arg_8_0.soundManager
	local var_8_1 = 65
	local var_8_2 = 45

	-- play-now-crowd-settings: chant loudness follows the Play Now split (stock 65/45 at 50/50)
	local modSettings = arg_8_0.modCrowdSettings

	if modSettings then
		var_8_1 = math.max(0, math.min(100, math.floor(65 + 0.9 * (modSettings.homeFans - 50) + 0.5)))
		var_8_2 = math.max(0, math.min(100, math.floor(45 + 0.9 * (50 - modSettings.homeFans) + 0.5)))
	end
	local var_8_3 = 25
	local var_8_4 = var_8_1 + var_8_2
	local var_8_5 = var_8_1 + var_8_3
	local var_8_6 = var_8_2 + var_8_3
	local var_8_7 = 100
	local var_8_8 = var_0_7.crowdBiasPercentage.rtpc

	var_8_0:setRTPCValueForGameObject("homeCrowd", var_8_8, var_8_1)
	var_8_0:setRTPCValueForGameObject("awayCrowd", var_8_8, var_8_2)
	var_8_0:setRTPCValueForGameObject("neutralCrowd", var_8_8, var_8_3)
	var_8_0:setRTPCValueForGameObject("homeAndAwayCrowd", var_8_8, var_8_4)
	var_8_0:setRTPCValueForGameObject("homeAndNeutralCrowd", var_8_8, var_8_5)
	var_8_0:setRTPCValueForGameObject("awayAndNeutralCrowd", var_8_8, var_8_6)
	var_8_0:setRTPCValueForGameObject("allCrowd", var_8_8, var_8_7)
end

function SoundListenerCrowd.postSoundSystemInit(arg_9_0)
	if not arg_9_0.enabled then
		return
	end

	var_0_14(arg_9_0, "CrowdLoop", {
		persist = true
	})

	local var_9_0 = arg_9_0.crowdSweetenerObjects

	var_0_14(arg_9_0, "intermittent_crowd_yells_looping", {
		soundObject = var_9_0[1]
	})
	var_0_14(arg_9_0, "intermittent_crowd_yells_looping", {
		soundObject = var_9_0[3]
	})
	var_0_14(arg_9_0, "intermittent_crowd_yells_looping", {
		soundObject = var_9_0[5]
	})

	local var_9_1 = arg_9_0.crowdLoopPositionalObjects

	for iter_9_0 = 1, #var_9_1 do
		local var_9_2 = "CrowdLoop_Positional_" .. iter_9_0

		var_0_14(arg_9_0, var_9_2, {
			soundObject = var_9_1[iter_9_0]
		})
	end
end

function SoundListenerCrowd.unload(arg_10_0, arg_10_1)
	if not arg_10_0.enabled then
		return
	end

	local var_10_0 = arg_10_0.soundManager

	for iter_10_0, iter_10_1 in pairs(arg_10_0.markerCallbacks) do
		var_10_0:removeMarkerCallback(iter_10_0)
	end

	arg_10_0.markerCallbacks = nil

	for iter_10_2, iter_10_3 in pairs(arg_10_0.crowdSweetenerObjects) do
		var_10_0:unregisterGameObject(iter_10_3)
	end

	for iter_10_4, iter_10_5 in ipairs(arg_10_0.crowdLoopPositionalObjects) do
		var_10_0:unregisterGameObject(iter_10_5)
	end

	for iter_10_6, iter_10_7 in ipairs(arg_10_0.teamSupportSoundObjects) do
		var_10_0:unregisterGameObject(iter_10_7)
	end

	for iter_10_8, iter_10_9 in pairs(var_0_21) do
		var_10_0:unregisterGameObject(iter_10_9)
	end

	var_10_0:unregisterGameObject(arg_10_0.crowdChantObject)
end

function SoundListenerCrowd.registerWithMatchSim(arg_11_0, arg_11_1)
	if not arg_11_0.enabled then
		return
	end

	local var_11_0 = arg_11_0.soundSystem

	var_11_0:registerSoundOnlyEvents(arg_11_0, {
		PlayNationalAnthemEvent = arg_11_0.onPlayNationalAnthemEvent,
		StopNationalAnthemEvent = arg_11_0.onStopNationalAnthemEvent,
		VideoRefereeDecisionEvent = arg_11_0.onVideoRefereeDecisionEvent
	})
	var_11_0:registerSolidEvents(arg_11_0, arg_11_1, {
		AdvanceToNextTimePeriodEvent = arg_11_0.onAdvanceToNextTimePeriodEvent,
		BallStripEvent = arg_11_0.onBallStripEvent,
		BigHitContactEvent = arg_11_0.onBigHitContactEvent,
		CaughtInGoalEvent = arg_11_0.onCaughtInGoalEvent,
		ChargeDownStartEvent = arg_11_0.onChargeDownStartEvent,
		CollectBallEvent = arg_11_0.onCollectBallEvent,
		ConversionKickReadyEvent = arg_11_0.onConversionKickReadyEvent,
		ConversionOutcomeEvent = arg_11_0.onConversionOutcomeEvent,
		DisposalEvent = arg_11_0.onDisposalEvent,
		FakePassEvent = arg_11_0.onFakePassEvent,
		FendEvent = arg_11_0.onFendEvent,
		FieldGoalSuccessEvent = arg_11_0.onFieldGoalSuccessEvent,
		FortyThirtyEvent = arg_11_0.onFortyThirtyEvent,
		FortyTwentyEvent = arg_11_0.onFortyTwentyEvent,
		GameOverEvent = arg_11_0.onGameOverEvent,
		InTouchEvent = arg_11_0.onInTouchEvent,
		LineBreakEvent = arg_11_0.onLineBreakEvent,
		RefereeSignalEvent = arg_11_0.onRefereeSignalEvent,
		ScoreIncrementEvent = arg_11_0.onScoreIncrementEvent,
		SideStepEvent = arg_11_0.onSideStepEvent,
		TackleBreakEvent = arg_11_0.onTackleBreakEvent,
		TackleCompletedEvent = arg_11_0.onTackleCompletedEvent,
		TackleContactEvent = arg_11_0.onTackleContactEvent,
		TimePeriodExpiredEvent = arg_11_0.onTimePeriodExpiredEvent,
		TryScoredEvent = arg_11_0.onTryScoredEvent,
		TwentyFiftyEvent = arg_11_0.onTwentyFiftyEvent,
		TwentyFortyEvent = arg_11_0.onTwentyFortyEvent
	})
end

function SoundListenerCrowd.update(arg_12_0, arg_12_1, arg_12_2, arg_12_3, arg_12_4, arg_12_5, arg_12_6)
	if not arg_12_0.enabled then
		return
	end

	arg_12_0:updateCrowdExcitement(arg_12_1, arg_12_2, arg_12_3, arg_12_4, arg_12_5, arg_12_6)
end

function SoundListenerCrowd.updateCrowdExcitement(arg_13_0, arg_13_1, arg_13_2, arg_13_3, arg_13_4, arg_13_5, arg_13_6)
	if not arg_13_0.enabled then
		return
	end

	local var_13_0 = arg_13_0.crowdExcitementValues
	local var_13_1 = var_13_0.min
	local var_13_2 = var_13_0.max
	local var_13_3 = var_13_2 - var_13_1
	local var_13_4 = var_13_0.extra.value
	local var_13_5 = var_13_0.extra.duration
	local var_13_6, var_13_7 = var_0_11.get(arg_13_1, arg_13_2, arg_13_3, arg_13_4, arg_13_6)

	var_13_0.base = var_13_6

	local var_13_8 = math.min(var_13_6 + var_13_4, var_13_2)
	local var_13_9 = math.max(var_13_8, var_13_1) / 100 * var_13_3

	if var_13_9 ~= var_13_0.prevValueSentToWwise then
		arg_13_0.soundManager:setGlobalRTPC(var_13_0.rtpc, var_13_9)

		var_13_0.prevValueSentToWwise = var_13_9
	end

	local var_13_10 = var_13_5 - arg_13_5

	if var_13_10 <= 0 then
		var_13_0.extra.value = 0
		var_13_0.extra.duration = 0
	else
		var_13_0.extra.duration = var_13_10
	end
end

function SoundListenerCrowd.trySetExtraCrowdExcitement(arg_14_0, arg_14_1)
	if not arg_14_0.enabled then
		return
	end

	if arg_14_1 then
		local var_14_0 = arg_14_0.crowdExcitementValues.extra

		var_14_0.value = math.max(var_14_0.value, arg_14_1)
		var_14_0.duration = 4

		local var_14_1 = arg_14_0.crowdSystem

		if var_14_1 then
			var_14_1:pushDebugCommentSound("CrowdExcitement " .. arg_14_1)
		end
	end
end

function SoundListenerCrowd.stopSound(arg_15_0, arg_15_1, arg_15_2, arg_15_3)
	arg_15_0.soundSystem:stopEvents({
		soundKey = arg_15_1,
		fadeTime = arg_15_2,
		soundObject = arg_15_3
	})
end

function SoundListenerCrowd.stopSoundsOnAllCrowdSoundObjects(arg_16_0, arg_16_1, arg_16_2)
	local var_16_0 = arg_16_0.soundSystem

	if var_16_0:isEventActive(arg_16_1) then
		for iter_16_0, iter_16_1 in pairs(var_0_21) do
			var_16_0:stopEvents({
				soundKey = arg_16_1,
				fadeTime = arg_16_2,
				soundObject = iter_16_1
			})
		end

		return true
	end

	return false
end

function SoundListenerCrowd.setCrowdPercentage(arg_17_0, arg_17_1)
	if not arg_17_0.enabled then
		return
	end

	if PLATFORM_SWITCH then
		arg_17_1 = 100
	end

	if arg_17_1 ~= arg_17_0.crowdPercentage then
		arg_17_0.soundManager:setGlobalRTPC(var_0_7.crowdPercentage.rtpc, arg_17_1)

		arg_17_0.crowdPercentage = arg_17_1
	end
end

function SoundListenerCrowd.playSound(arg_18_0, arg_18_1, arg_18_2, arg_18_3)
	if arg_18_3 then
		local var_18_0
		local var_18_1 = false
		local var_18_2 = false
		local var_18_3 = false

		for iter_18_0, iter_18_1 in ipairs(arg_18_3) do
			if iter_18_1 == native.ECrowdTags.Home then
				var_18_1 = true
			elseif iter_18_1 == native.ECrowdTags.Away then
				var_18_2 = true
			elseif iter_18_1 == native.ECrowdTags.Neutral then
				var_18_3 = true
			end
		end

		if var_18_1 and not var_18_2 and not var_18_3 then
			var_18_0 = var_0_21.home
		elseif var_18_2 and not var_18_1 and not var_18_3 then
			var_18_0 = var_0_21.away
		elseif var_18_3 and not var_18_1 and not var_18_2 then
			var_18_0 = var_0_21.neutral
		elseif var_18_1 and var_18_2 and not var_18_3 then
			var_18_0 = var_0_21.home_away
		elseif var_18_1 and var_18_3 and not var_18_2 then
			var_18_0 = var_0_21.home_neutral
		elseif var_18_2 and var_18_3 and not var_18_1 then
			var_18_0 = var_0_21.away_neutral
		elseif var_18_1 and var_18_2 and var_18_3 then
			var_18_0 = var_0_21.all
		end

		if arg_18_2 then
			ASSERT(not arg_18_2.soundObject)

			arg_18_2.soundObject = var_18_0
		else
			arg_18_2 = {
				soundObject = var_18_0
			}
		end
	end

	ASSERT(not var_0_12 or arg_18_2.soundObject)

	return var_0_15(arg_18_0, arg_18_1, arg_18_2)
end

function SoundListenerCrowd.enterInteractiveReplay(arg_19_0)
	if not arg_19_0.enabled then
		return
	end

	local var_19_0 = var_0_7.allAmbienceLPF

	arg_19_0.soundManager:setGlobalRTPC(var_19_0.rtpc, var_19_0.interactiveReplayValue)

	local var_19_1 = 0.5
	local var_19_2 = arg_19_0.crowdSweetenerObjects

	for iter_19_0 = 1, #var_19_2 do
		arg_19_0:stopSound("intermittent_crowd_yells_looping", var_19_1, var_19_2[iter_19_0])
	end
end

function SoundListenerCrowd.exitInteractiveReplay(arg_20_0)
	if not arg_20_0.enabled then
		return
	end

	local var_20_0 = var_0_7.allAmbienceLPF

	arg_20_0.soundManager:setGlobalRTPC(var_20_0.rtpc, var_20_0.startingValue)

	local var_20_1 = arg_20_0.crowdSweetenerObjects

	var_0_14(arg_20_0, "intermittent_crowd_yells_looping", {
		persist = true,
		soundObject = var_20_1[1]
	})
	var_0_14(arg_20_0, "intermittent_crowd_yells_looping", {
		persist = true,
		soundObject = var_20_1[3]
	})
	var_0_14(arg_20_0, "intermittent_crowd_yells_looping", {
		persist = true,
		soundObject = var_20_1[5]
	})
end

function SoundListenerCrowd.onAdvanceToNextTimePeriodEvent(arg_21_0, arg_21_1, arg_21_2, arg_21_3, arg_21_4, arg_21_5, arg_21_6, arg_21_7, arg_21_8, arg_21_9)
	var_0_15(arg_21_0, "Crowd_Lull_to_50", {
		soundObject = var_0_21.all
	})
end

function SoundListenerCrowd.onBallStripEvent(arg_22_0, arg_22_1, arg_22_2, arg_22_3, arg_22_4, arg_22_5, arg_22_6, arg_22_7, arg_22_8, arg_22_9)
	local var_22_0 = arg_22_1.maker

	if var_22_0 then
		local var_22_1 = arg_22_8:getGameObject(var_22_0).side

		if sidehelper.isValidSide(var_22_1) then
			arg_22_0:startNewCrowdEvent("BallStrip")

			local var_22_2 = var_0_20(var_22_1)

			var_0_15(arg_22_0, "cheer_low", {
				soundObject = var_22_2
			})

			local var_22_3 = sidehelper.getOtherSide(var_22_1)
			local var_22_4 = var_0_20(var_22_3)

			var_0_15(arg_22_0, "groan_low", {
				soundObject = var_22_4
			})
			var_0_15(arg_22_0, "ReactionLayerSwell_to_15", {
				soundObject = var_0_21.all
			})
			arg_22_0:trySetExtraCrowdExcitement(5)
		end
	end
end

function SoundListenerCrowd.onBigHitContactEvent(arg_23_0, arg_23_1, arg_23_2, arg_23_3, arg_23_4, arg_23_5, arg_23_6, arg_23_7, arg_23_8, arg_23_9)
	arg_23_0:startNewCrowdEvent("BigHitContact")

	local var_23_0 = arg_23_1.maker

	arg_23_0:playSoundForPlayer("cheer_mid", var_23_0, arg_23_8)
	var_0_15(arg_23_0, "ReactionLayerSwell_to_20", {
		soundObject = var_0_21.all
	})
	arg_23_0:trySetExtraCrowdExcitement(5)
end

function SoundListenerCrowd.onCaughtInGoalEvent(arg_24_0, arg_24_1, arg_24_2, arg_24_3, arg_24_4, arg_24_5, arg_24_6, arg_24_7, arg_24_8, arg_24_9)
	local var_24_0 = arg_24_1.caughtById

	if var_24_0 then
		local var_24_1 = arg_24_8:getGameObject(var_24_0).side

		if sidehelper.isValidSide(var_24_1) then
			arg_24_0:startNewCrowdEvent("CaughtInGoal")

			local var_24_2 = var_0_20(var_24_1)

			var_0_15(arg_24_0, "cheer_mid", {
				soundObject = var_24_2
			})

			local var_24_3 = sidehelper.getOtherSide(var_24_1)
			local var_24_4 = var_0_20(var_24_3)

			var_0_15(arg_24_0, "groan_low", {
				soundObject = var_24_4
			})
		end
	end
end

function SoundListenerCrowd.onChargeDownStartEvent(arg_25_0, arg_25_1, arg_25_2, arg_25_3, arg_25_4, arg_25_5, arg_25_6, arg_25_7, arg_25_8, arg_25_9)
	local var_25_0 = arg_25_1.maker

	if var_25_0 then
		local var_25_1 = arg_25_8:getGameObject(var_25_0).side

		if sidehelper.isValidSide(var_25_1) then
			arg_25_0:startNewCrowdEvent("ChargeDownStart")

			local var_25_2 = var_0_20(var_25_1)

			var_0_15(arg_25_0, "cheer_low", {
				soundObject = var_25_2
			})

			local var_25_3 = sidehelper.getOtherSide(var_25_1)
			local var_25_4 = var_0_20(var_25_3)

			var_0_15(arg_25_0, "groan_low", {
				soundObject = var_25_4
			})
			var_0_15(arg_25_0, "ReactionLayerSwell_to_15", {
				soundObject = var_0_21.all
			})
			arg_25_0:trySetExtraCrowdExcitement(5)
		end
	end
end

function SoundListenerCrowd.onCollectBallEvent(arg_26_0, arg_26_1, arg_26_2, arg_26_3, arg_26_4, arg_26_5, arg_26_6, arg_26_7, arg_26_8, arg_26_9)
	local var_26_0 = arg_26_1.disposalType
	local var_26_1 = arg_26_1.disposalInfo
	local var_26_2 = native.EDisposalType

	if var_26_0 and var_26_0 ~= var_26_2.Teleport and var_26_1 then
		local var_26_3 = var_26_1.objectId or var_26_1.maker

		if var_26_3 and var_26_3 ~= 0 then
			local var_26_4 = VERIFY(arg_26_8:getGameObject(arg_26_1.maker))
			local var_26_5 = arg_26_1.side
			local var_26_6 = VERIFY(arg_26_8:getGameObject(var_26_3))
			local var_26_7 = VERIFY(var_26_6.side)

			if var_26_0 == var_26_2.Kick and arg_26_1.disposalSubType ~= native.EDisposalSubType.PlayTheBall and var_26_5 == var_26_7 then
				local var_26_8 = var_0_20(var_26_5)

				if var_26_4 == var_26_6 then
					arg_26_0:startNewCrowdEvent("CaughtOwnKick")
					var_0_15(arg_26_0, "cheer_mid_high_interruptible", {
						soundObject = var_26_8
					})
				else
					arg_26_0:startNewCrowdEvent("CaughtSameTeamKick")
					var_0_15(arg_26_0, "cheer_low_mid", {
						soundObject = var_26_8
					})
				end

				var_0_15(arg_26_0, "ReactionLayerSwell_to_15", {
					soundObject = var_0_21.all
				})
				arg_26_0:trySetExtraCrowdExcitement(5)
			elseif var_26_0 == var_26_2.Pass and var_26_7 ~= var_26_5 then
				arg_26_0:startNewCrowdEvent("Turnover")

				local var_26_9 = var_0_20(var_26_7)

				var_0_15(arg_26_0, "groan_low", {
					soundObject = var_26_9
				})
				var_0_15(arg_26_0, "ReactionLayerSwell_to_15", {
					soundObject = var_0_21.all
				})
				arg_26_0:trySetExtraCrowdExcitement(10)
			end
		end
	end
end

function SoundListenerCrowd.onConversionKickReadyEvent(arg_27_0, arg_27_1, arg_27_2, arg_27_3, arg_27_4, arg_27_5, arg_27_6, arg_27_7, arg_27_8, arg_27_9)
	arg_27_0:startNewCrowdEvent("ConversionKickReady")

	local var_27_0 = "CrowdConversionKickStateDisable"
	local var_27_1 = arg_27_0.crowdSweetenerObjects
	local var_27_2 = #var_27_1
	local var_27_3 = arg_27_1.side
	local var_27_4 = var_0_17(arg_27_3, var_27_3)
	local var_27_5 = var_0_18(arg_27_3)

	if var_27_4 or not var_27_5 and var_27_3 == var_0_0 then
		for iter_27_0 = 1, var_27_2 do
			var_0_15(arg_27_0, "CrowdElements_YouGotThis", {
				soundObject = var_27_1[iter_27_0]
			})
		end

		var_27_0 = "CrowdConversionKickStatePolite"
	elseif var_27_5 or not var_27_5 and var_27_3 == var_0_1 then
		for iter_27_1 = 1, var_27_2 do
			var_0_15(arg_27_0, "CrowdElements_YoureGoingToMiss", {
				soundObject = var_27_1[iter_27_1]
			})
		end

		var_27_0 = "CrowdConversionKickStateImpolite"
	end

	var_0_15(arg_27_0, var_27_0, {
		soundObject = var_0_21.all
	})
	var_0_15(arg_27_0, "ReactionLayerSwell_to_20", {
		soundObject = var_0_21.all
	})
end

function SoundListenerCrowd.onConversionOutcomeEvent(arg_28_0, arg_28_1, arg_28_2, arg_28_3, arg_28_4, arg_28_5, arg_28_6, arg_28_7, arg_28_8, arg_28_9)
	if arg_28_1.wasSuccessful then
		var_0_15(arg_28_0, "Crowd_Horns", {
			soundObject = var_0_21.all
		})
		var_0_15(arg_28_0, "ReactionLayerSwell_to_30", {
			soundObject = var_0_21.all
		})
	end
end

function SoundListenerCrowd.onDisposalEvent(arg_29_0, arg_29_1, arg_29_2, arg_29_3, arg_29_4, arg_29_5, arg_29_6, arg_29_7, arg_29_8, arg_29_9)
	if arg_29_1.maker then
		local var_29_0 = arg_29_1.disposalType
		local var_29_1 = arg_29_1.disposalSubType
		local var_29_2 = native.EDisposalType
		local var_29_3 = native.EDisposalSubType

		if var_29_0 == var_29_2.Spill then
			var_0_15(arg_29_0, "ReactionLayerSwell_to_10", {
				soundObject = var_0_21.all
			})
		elseif var_29_1 == var_29_3.KickOff or var_29_1 == var_29_3.KickOffDrop then
			local var_29_4 = arg_29_7:getTimeElapsedEntity()

			if (var_29_4 and var_29_4.minutesElapsed) >= 1 then
				var_0_15(arg_29_0, "ReactionLayerSwell_to_30", {
					soundObject = var_0_21.all
				})
			end

			var_0_15(arg_29_0, "CrowdChantPlay", {
				noDuplicate = true,
				soundObject = arg_29_0.crowdChantObject
			})
		elseif var_29_1 == var_29_3.Offload then
			var_0_15(arg_29_0, "ReactionLayerSwell_to_25", {
				soundObject = var_0_21.all
			})
		elseif var_29_1 == var_29_3.FieldGoal or var_29_1 == native.EDisposalSubType.Conversion then
			var_0_15(arg_29_0, "sfxCrowdDisposalConversionKick", {
				soundObject = var_0_21.all
			})
			var_0_15(arg_29_0, "ReactionLayerSwell_to_30", {
				soundObject = var_0_21.all
			})
		end
	end
end

function SoundListenerCrowd.onFakePassEvent(arg_30_0, arg_30_1, arg_30_2, arg_30_3, arg_30_4, arg_30_5, arg_30_6, arg_30_7, arg_30_8, arg_30_9)
	arg_30_0:startNewCrowdEvent("FakePass")

	local var_30_0 = arg_30_1.maker

	arg_30_0:playSoundForPlayer("cheer_low", var_30_0, arg_30_8)
	var_0_15(arg_30_0, "ReactionLayerSwell_to_15", {
		soundObject = var_0_21.all
	})
	arg_30_0:trySetExtraCrowdExcitement(5)
end

function SoundListenerCrowd.onFendEvent(arg_31_0, arg_31_1, arg_31_2, arg_31_3, arg_31_4, arg_31_5, arg_31_6, arg_31_7, arg_31_8, arg_31_9)
	arg_31_0:startNewCrowdEvent("Fend")

	local var_31_0 = arg_31_1.maker

	arg_31_0:playSoundForPlayer("cheer_low", var_31_0, arg_31_8)
	var_0_15(arg_31_0, "ReactionLayerSwell_to_15", {
		soundObject = var_0_21.all
	})
	arg_31_0:trySetExtraCrowdExcitement(5)
end

function SoundListenerCrowd.onFieldGoalSuccessEvent(arg_32_0, arg_32_1, arg_32_2, arg_32_3, arg_32_4, arg_32_5, arg_32_6, arg_32_7, arg_32_8, arg_32_9)
	var_0_15(arg_32_0, "CrowdChantStop", {
		soundObject = arg_32_0.crowdChantObject
	})
	var_0_15(arg_32_0, "ReactionLayerSwell_to_30", {
		soundObject = var_0_21.all
	})
end

function SoundListenerCrowd.onFortyThirtyEvent(arg_33_0, arg_33_1, arg_33_2, arg_33_3, arg_33_4, arg_33_5, arg_33_6, arg_33_7, arg_33_8, arg_33_9)
	arg_33_0:playFortyTwentyVariantEvent(arg_33_1, arg_33_8)
end

function SoundListenerCrowd.onFortyTwentyEvent(arg_34_0, arg_34_1, arg_34_2, arg_34_3, arg_34_4, arg_34_5, arg_34_6, arg_34_7, arg_34_8, arg_34_9)
	arg_34_0:playFortyTwentyVariantEvent(arg_34_1, arg_34_8)
end

function SoundListenerCrowd.onGameOverEvent(arg_35_0, arg_35_1, arg_35_2, arg_35_3, arg_35_4, arg_35_5, arg_35_6, arg_35_7, arg_35_8, arg_35_9)
	var_0_15(arg_35_0, "CrowdChantStop", {
		soundObject = arg_35_0.crowdChantObject
	})
end

function SoundListenerCrowd.onInTouchEvent(arg_36_0, arg_36_1, arg_36_2, arg_36_3, arg_36_4, arg_36_5, arg_36_6, arg_36_7, arg_36_8, arg_36_9)
	if arg_36_1.isInTouchInGoal or arg_36_1.isDeadBall then
		local var_36_0 = arg_36_0.crowdExcitementValues

		if not ((var_36_0 and var_36_0.prevValueSentToWwise) > 30) then
			var_0_15(arg_36_0, "Crowd_Lull_to_50", {
				soundObject = var_0_21.all
			})
		end
	else
		var_0_15(arg_36_0, "Crowd_Lull_to_50", {
			soundObject = var_0_21.all
		})
	end
end

function SoundListenerCrowd.onLineBreakEvent(arg_37_0, arg_37_1, arg_37_2, arg_37_3, arg_37_4, arg_37_5, arg_37_6, arg_37_7, arg_37_8, arg_37_9)
	var_0_15(arg_37_0, "CrowdElements_ComeOn", {
		soundObject = var_0_21.all
	})
	var_0_15(arg_37_0, "ReactionLayerSwell_to_15", {
		soundObject = var_0_21.all
	})
end

function SoundListenerCrowd.onRefereeSignalEvent(arg_38_0, arg_38_1, arg_38_2, arg_38_3, arg_38_4, arg_38_5, arg_38_6, arg_38_7, arg_38_8, arg_38_9)
	if arg_38_1.signalType == refereesignaltypes.VideoReferee then
		var_0_15(arg_38_0, "sfxCrowdRefereeSignalVideoRef", {
			soundObject = var_0_21.all
		})
	end
end

function SoundListenerCrowd.onScoreIncrementEvent(arg_39_0, arg_39_1, arg_39_2, arg_39_3, arg_39_4, arg_39_5, arg_39_6, arg_39_7, arg_39_8, arg_39_9)
	local var_39_0 = arg_39_6:getComponent("matchInData")
	local var_39_1 = VERIFY(arg_39_7:getScoreEntity()):getWinningSide(var_39_0)

	if sidehelper.isValidSide(var_39_1) then
		arg_39_0.localGamerIsWinning = var_0_17(arg_39_3, var_39_1)
	else
		arg_39_0.localGamerIsWinning = false
	end

	var_0_19(arg_39_0, arg_39_3, var_39_1)
end

function SoundListenerCrowd.onSideStepEvent(arg_40_0, arg_40_1, arg_40_2, arg_40_3, arg_40_4, arg_40_5, arg_40_6, arg_40_7, arg_40_8, arg_40_9)
	arg_40_0:startNewCrowdEvent("SideStep")

	local var_40_0 = arg_40_1.maker

	arg_40_0:playSoundForPlayer("cheer_low", var_40_0, arg_40_8)
	var_0_15(arg_40_0, "ReactionLayerSwell_to_15", {
		soundObject = var_0_21.all
	})
	arg_40_0:trySetExtraCrowdExcitement(5)
end

function SoundListenerCrowd.onTackleBreakEvent(arg_41_0, arg_41_1, arg_41_2, arg_41_3, arg_41_4, arg_41_5, arg_41_6, arg_41_7, arg_41_8, arg_41_9)
	arg_41_0:startNewCrowdEvent("TackleBreak")

	local var_41_0 = arg_41_1.maker

	arg_41_0:playSoundForPlayer("cheer_low", var_41_0, arg_41_8)
	var_0_15(arg_41_0, "ReactionLayerSwell_to_15", {
		soundObject = var_0_21.all
	})
	arg_41_0:trySetExtraCrowdExcitement(5)
end

function SoundListenerCrowd.onTackleCompletedEvent(arg_42_0, arg_42_1, arg_42_2, arg_42_3, arg_42_4, arg_42_5, arg_42_6, arg_42_7, arg_42_8, arg_42_9)
	arg_42_0:startNewCrowdEvent("TackleCompleted")

	local var_42_0 = arg_42_1.side
	local var_42_1 = sidehelper.getOtherSide(var_42_0)
	local var_42_2 = arg_42_6.statistics.play_listeners.set:getPlayMetersGained() > 0
	local var_42_3 = var_42_2 and var_42_1 or var_42_0
	local var_42_4 = var_0_20(var_42_3)

	var_0_15(arg_42_0, "cheer_low", {
		soundObject = var_42_4
	})

	local var_42_5 = var_42_2 and var_42_0 or var_42_1
	local var_42_6 = var_0_20(var_42_5)

	var_0_15(arg_42_0, "groan_low", {
		soundObject = var_42_6
	})
end

function SoundListenerCrowd.onTackleContactEvent(arg_43_0, arg_43_1, arg_43_2, arg_43_3, arg_43_4, arg_43_5, arg_43_6, arg_43_7, arg_43_8, arg_43_9)
	local var_43_0 = arg_43_0.crowdSweetenerObjects
	local var_43_1 = math.random(1, #var_43_0)

	var_0_14(arg_43_0, "CrowdElements_GetRidOfIt", {
		soundObject = var_43_0[var_43_1]
	})
end

function SoundListenerCrowd.onTimePeriodExpiredEvent(arg_44_0, arg_44_1, arg_44_2, arg_44_3, arg_44_4, arg_44_5, arg_44_6, arg_44_7, arg_44_8, arg_44_9)
	if arg_44_7:getMatchProgressionEntity().currentTimePeriod ~= 1 then
		local var_44_0 = arg_44_6:getComponent("matchInData")

		if VERIFY(arg_44_7:getScoreEntity()):getMargin(var_44_0) ~= 0 then
			var_0_14(arg_44_0, "CrowdChantPlay", {
				noDuplicate = true,
				soundObject = arg_44_0.crowdChantObject
			})
		end
	end
end

function SoundListenerCrowd.onTryScoredEvent(arg_45_0, arg_45_1, arg_45_2, arg_45_3, arg_45_4, arg_45_5, arg_45_6, arg_45_7, arg_45_8, arg_45_9)
	var_0_15(arg_45_0, "Crowd_Horns", {
		soundObject = var_0_21.all
	})
	var_0_15(arg_45_0, "CrowdChantStop", {
		soundObject = arg_45_0.crowdChantObject
	})
	var_0_15(arg_45_0, "ReactionLayerSwell_to_50", {
		soundObject = var_0_21.all
	})
end

function SoundListenerCrowd.onTwentyFiftyEvent(arg_46_0, arg_46_1, arg_46_2, arg_46_3, arg_46_4, arg_46_5, arg_46_6, arg_46_7, arg_46_8, arg_46_9)
	arg_46_0:playFortyTwentyVariantEvent(arg_46_1, arg_46_8)
end

function SoundListenerCrowd.onTwentyFortyEvent(arg_47_0, arg_47_1, arg_47_2, arg_47_3, arg_47_4, arg_47_5, arg_47_6, arg_47_7, arg_47_8, arg_47_9)
	arg_47_0:playFortyTwentyVariantEvent(arg_47_1, arg_47_8)
end

function SoundListenerCrowd.onPlayNationalAnthemEvent(arg_48_0, arg_48_1, arg_48_2, arg_48_3, arg_48_4, arg_48_5, arg_48_6)
	arg_48_0:startNewCrowdEvent("PlayNationalAnthem")
end

function SoundListenerCrowd.onStopNationalAnthemEvent(arg_49_0, arg_49_1, arg_49_2, arg_49_3, arg_49_4, arg_49_5, arg_49_6)
	arg_49_0:startNewCrowdEvent("StopNationalAnthem")
end

function SoundListenerCrowd.onVideoRefereeDecisionEvent(arg_50_0, arg_50_1, arg_50_2, arg_50_3, arg_50_4, arg_50_5, arg_50_6)
	local var_50_0 = arg_50_4:getTryDecisionPendingEntity().scoringSide

	if sidehelper.isValidSide(var_50_0) then
		arg_50_0:startNewCrowdEvent("VideoRefereeDecision")

		local var_50_1 = var_0_20(var_50_0)

		var_0_15(arg_50_0, "sfxCrowdVideoRefereeDecisionPending", {
			soundObject = var_50_1
		})

		local var_50_2 = arg_50_1.isTry and "sfxCrowdVideoRefereeDecisionTry" or "sfxCrowdVideoRefereeDecisionNoTry"

		var_0_15(arg_50_0, var_50_2, {
			delay = 5,
			soundObject = var_50_1
		})
		var_0_15(arg_50_0, "ReactionLayerSwell_to_30", {
			delay = 5,
			soundObject = var_0_21.all
		})
	end
end

function SoundListenerCrowd.respondToQuietPeriod(arg_51_0, arg_51_1, arg_51_2, arg_51_3)
	-- play-now-crowd-settings: sound_system calls this directly; a disabled listener has no objects
	if not arg_51_0.enabled then
		return
	end

	local var_51_0 = arg_51_2:getBallEntity():getOwnerId(arg_51_3)
	local var_51_1 = var_51_0 and arg_51_1:getGameObject(var_51_0).side or var_0_0

	var_0_15(arg_51_0, "TeamSupportYells", {
		soundObject = arg_51_0.teamSupportSoundObjects[var_51_1]
	})
end

function SoundListenerCrowd.playSoundForPlayer(arg_52_0, arg_52_1, arg_52_2, arg_52_3)
	if arg_52_2 then
		local var_52_0 = arg_52_3:getGameObject(arg_52_2).side

		if sidehelper.isValidSide(var_52_0) then
			local var_52_1 = var_0_20(var_52_0)

			var_0_15(arg_52_0, arg_52_1, {
				soundObject = var_52_1
			})
		end
	end
end

function SoundListenerCrowd.playFortyTwentyVariantEvent(arg_53_0, arg_53_1, arg_53_2)
	arg_53_0:startNewCrowdEvent("FortyTwentyVariant")

	local var_53_0 = arg_53_1.kicker

	arg_53_0:playSoundForPlayer("cheer_mid", var_53_0, arg_53_2)
	var_0_15(arg_53_0, "ReactionLayerSwell_to_15", {
		soundObject = var_0_21.all
	})
	arg_53_0:trySetExtraCrowdExcitement(5)
end

function SoundListenerCrowd.startNewCrowdEvent(arg_54_0, arg_54_1)
	local var_54_0 = arg_54_0.crowdSystem

	if var_54_0 then
		var_54_0:startNewCrowdEvent(arg_54_1)
	end
end

function var_0_14(arg_55_0, arg_55_1, arg_55_2)
	return arg_55_0.soundSystem:queueEvent(arg_55_1, arg_55_2, var_0_22)
end

function var_0_15(arg_56_0, arg_56_1, arg_56_2)
	local var_56_0 = arg_56_0.crowdSystem

	if var_56_0 then
		var_56_0:pushDebugCommentSound(arg_56_1)
	end

	return arg_56_0.soundSystem:playEvent(arg_56_1, arg_56_2, var_0_22)
end

function var_0_17(arg_57_0, arg_57_1)
	local var_57_0 = arg_57_0.localGamers.asTable

	for iter_57_0, iter_57_1 in ipairs(var_57_0) do
		if arg_57_1 == iter_57_1.side then
			return true
		end
	end
end

function var_0_18(arg_58_0)
	local var_58_0 = arg_58_0.localGamers.asTable

	for iter_58_0, iter_58_1 in ipairs(var_58_0) do
		if iter_58_1.side ~= var_0_2 then
			return true
		end
	end
end

function var_0_19(arg_59_0, arg_59_1, arg_59_2)
	local var_59_0 = var_0_10.noCountry

	if var_0_18(arg_59_1) then
		if var_0_17(arg_59_1, var_0_0) and arg_59_2 ~= var_0_1 then
			var_59_0 = arg_59_0.teamChantSwitchValues.home
		elseif var_0_17(arg_59_1, var_0_1) and arg_59_2 ~= var_0_0 then
			var_59_0 = arg_59_0.teamChantSwitchValues.away
		end
	elseif arg_59_2 == var_0_0 then
		var_59_0 = arg_59_0.teamChantSwitchValues.home
	elseif arg_59_2 == var_0_1 then
		var_59_0 = arg_59_0.teamChantSwitchValues.away
	end

	arg_59_0.soundManager:setSwitchValue(var_0_9, var_59_0, arg_59_0.crowdChantObject)
end

function var_0_20(arg_60_0)
	local var_60_0

	if arg_60_0 == var_0_0 then
		var_60_0 = var_0_21.home
	elseif arg_60_0 == var_0_1 then
		var_60_0 = var_0_21.away
	else
		var_60_0 = var_0_21.neutral
	end

	return var_60_0
end
