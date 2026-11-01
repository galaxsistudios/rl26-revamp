import("base.side.sidehelper")
import("core.foundation.tablex")
import("core.profile.profile")
import("design.characters.realisticcolour")
import("rules.penalty.penaltytypes")
import("rules.rules.rulesenvironment_cconfig")
import("script-config.design.sound.soundmap")

local var_0_0 = native.getEnvironment():argExists("debugSound") or false
local var_0_1 = rulesenvironment_cconfig.cBoundaryConfig
local var_0_2 = native.EDisposalType
local var_0_3 = native.EDisposalSubType
local var_0_4 = native.CPhysicsEnum
local var_0_5 = native.ECrowdAnimGroup
local var_0_6 = native.ESide.Home:toInt()
local var_0_7 = native.ESide.Away:toInt()
local var_0_8 = native.ESide.None:toInt()
local var_0_9 = native.ECrowdTags
local var_0_10
local var_0_11
local var_0_12
local var_0_13
local var_0_14 = soundmap.crowdOneShotSoundObjectTable

local function var_0_15(arg_1_0)
	return native.vec3(arg_1_0.x, 0, arg_1_0.y)
end

local function var_0_16(arg_2_0, ...)
	if var_0_0 then
		formatPrintT("[CrowdSystem] " .. arg_2_0, ...)
	end
end

-- play-now-crowd-settings (when installed): Play Now's Crowd Settings (attendance %,
-- home fans %), read through its soundlistener_crowd.lua. Nil outside Play Now or
-- without that mod.
-- the scene's padding dword (+0x1c, after 6 LOD ratios and a byte) its exe patch reads
local MOD_CROWD_SIDE_SLOT = 7

local function modPlayNowCrowd(matchInData)
	local ok, settings = pcall(function()
		local reader = import("simlisteners.sound.listeners.soundlistener_crowd").modPlayNowCrowdSettings

		return reader and reader(matchInData)
	end)

	return ok and settings or nil
end

local function var_0_17(arg_3_0)
	return (VERIFY(loadTemp("intermediatelua.crowd.crowd_item_config")))
end

local function var_0_18(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4)
	local var_4_0 = arg_4_0:getAssetManager()
	local var_4_1 = arg_4_0:getTextureManager()
	local var_4_2 = arg_4_0:getJobManager()
	local var_4_3 = arg_4_0:getRenderInterface()
	local var_4_4 = arg_4_0:getGraphicsSettings()

	-- crowd-team-kits: crowd_item_config reads the node file to size the
	-- random Souths guy's odds to the ground
	rawset(_G, "crowdTeamKitsNodeFile", arg_4_2)
	-- crowd-team-kits: the playing teams' crowd tag ids, for per-match items (crowd-flags)
	rawset(_G, "crowdTeamKitsTeams", {
		home = arg_4_3.home.academyId,
		away = arg_4_3.away.academyId
	})

	local var_4_5 = var_0_17(arg_4_3)
	local var_4_6 = var_4_4.crowdQuality
	local var_4_7 = var_4_4.crowdCapacity
	local var_4_8 = arg_4_3.home
	local var_4_9 = arg_4_3.away
	local var_4_10 = var_4_8.identity
	local var_4_11 = var_4_9.identity
	local var_4_12 = "teamID" .. var_4_8.academyId
	local var_4_13 = "teamID" .. var_4_9.academyId
	local var_4_14 = var_4_10.primaryRGBColour
	local var_4_15 = native.vec4(var_4_14.r / 255, var_4_14.g / 255, var_4_14.b / 255, 1)
	local var_4_16 = var_4_10.secondaryRGBColour
	local var_4_17 = native.vec4(var_4_16.r / 255, var_4_16.g / 255, var_4_16.b / 255, 1)
	local var_4_18 = var_4_11.primaryRGBColour
	local var_4_19 = native.vec4(var_4_18.r / 255, var_4_18.g / 255, var_4_18.b / 255, 1)
	local var_4_20 = var_4_11.secondaryRGBColour
	local var_4_21 = native.vec4(var_4_20.r / 255, var_4_20.g / 255, var_4_20.b / 255, 1)
	local var_4_22 = realisticcolour.make(var_4_15)
	local var_4_23 = realisticcolour.make(var_4_17)
	local var_4_24 = realisticcolour.make(var_4_19)
	local var_4_25 = realisticcolour.make(var_4_21)
	local var_4_26 = native.CCrowdScene(var_4_3, var_4_0, var_4_1, var_4_2, var_4_6, var_4_7)

	-- play-now-crowd-settings: each seat's side comes from a random value in [-1, 1]
	-- against a threshold (stock 0: about half each). Its exe patch reads the threshold
	-- from the scene's padding dword, written here through setLODRatio (unchecked index):
	-- home share H -> 1 - 2H. Padding isn't initialised, so it's written for every match
	-- (0 = stock outside Play Now). Without the patch nothing reads it.
	local modCrowd = modPlayNowCrowd(arg_4_3)
	local modThreshold = modCrowd and math.max(-1, math.min(1, 1 - 2 * modCrowd.homeFans / 100)) or 0
	local modOk, modErr = pcall(function()
		var_4_26:setLODRatio(MOD_CROWD_SIDE_SLOT, modThreshold)
	end)
	local modLogFn = rawget(_G, "crowdTeamKitsLog")

	if modLogFn and (modCrowd or not modOk) then
		modLogFn("play now crowd: attendance %s%%, home fans %s%%, side threshold %.2f%s", modCrowd and modCrowd.attendance or "-", modCrowd and modCrowd.homeFans or "-", modThreshold, modOk and "" or " (failed: " .. tostring(modErr) .. ")")
	end

	var_4_26:init(arg_4_1, arg_4_2, "crowd/anims.dat", var_4_5, "", arg_4_4.matchSeed, var_4_12, var_4_13, var_4_22, var_4_23, var_4_24, var_4_25)

	return var_4_26
end

Class("Crowd", function(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7, arg_5_8)
	local var_5_0 = "crowd/nodefiles/" .. arg_5_4 .. "_crowdnodes.nodefile"

	arg_5_0.crowdScene = var_0_18(arg_5_1, arg_5_3, var_5_0, arg_5_6, arg_5_7)

	local var_5_1 = arg_5_6.crowdCapacity

	if var_5_1 and arg_5_6.gameMode == native.EGameMode.Career then
		arg_5_0.crowdScene:setWantCrowdPercentage(var_5_1)
	elseif arg_5_6.gameMode == native.EGameMode.Practice then
		arg_5_0.crowdScene:setWantCrowdPercentage(0)
	end

	-- play-now-crowd-settings: Play Now attendance (0 = an empty ground; its sound
	-- listener is silent then too)
	local modCrowd = modPlayNowCrowd(arg_5_6)

	if modCrowd then
		arg_5_0.crowdScene:setWantCrowdPercentage(modCrowd.attendance)
	end

	arg_5_0.TAGS_HOME = {
		var_0_9.Home
	}
	arg_5_0.TAGS_AWAY = {
		var_0_9.Away
	}
	arg_5_0.TAGS_NEUTRAL = {
		var_0_9.Neutral
	}
	arg_5_0.TAGS_HOME_AWAY = {
		var_0_9.Home,
		var_0_9.Away
	}
	arg_5_0.TAGS_HOME_NEUTRAL = {
		var_0_9.Home,
		var_0_9.Neutral
	}
	arg_5_0.TAGS_AWAY_NEUTRAL = {
		var_0_9.Away,
		var_0_9.Neutral
	}
	arg_5_0.TAGS_ALL = {
		var_0_9.Home,
		var_0_9.Away,
		var_0_9.Neutral
	}
	arg_5_0.currentBoundaryIdx = 1
	arg_5_0.currentDistance = 0
	arg_5_0.lastBoundaryNodeDist = 0
	arg_5_0.stepsEvery = 5
	arg_5_0.waveSpeed = 12.5

	local var_5_2 = var_0_5.idle
	local var_5_3 = {
		audioPlayingId = 0,
		eventId = 0,
		anim = var_5_2
	}

	arg_5_0.fallbackTriggers = {
		[var_0_9.Home] = tablex.clone(var_5_3),
		[var_0_9.Away] = tablex.clone(var_5_3),
		[var_0_9.Neutral] = tablex.clone(var_5_3)
	}

	local var_5_4 = arg_5_1:getSoundManager()

	arg_5_0.soundManager = var_5_4
	arg_5_0.markerCallbacks = var_0_10(arg_5_0, var_5_4, arg_5_2)
	arg_5_0.onLoadedCallbacks = {}
	arg_5_0.eventGroup = "Unset"
	arg_5_0.eventId = 0
	arg_5_0.crowdQueueEvent = {}
	arg_5_0.fieldGoalSuccessEventPlayed = false
	arg_5_0.conversionSuccessEventPlayed = false
	arg_5_0.onReload = _G.registerOnReload(function()
		arg_5_0:reload(arg_5_4)
	end)
	arg_5_0.hook = arg_5_5 and arg_5_5:getHook("CrowdDebugHook")
end)

function Crowd.updateLoading(arg_7_0)
	local var_7_0 = arg_7_0.crowdScene:updateLoading()

	if var_7_0 and arg_7_0.onLoadedCallbacks then
		local var_7_1 = arg_7_0:getPotentialAttendanceCount()

		-- crowd-team-kits: log the real crowd size to calibrate the Souths guy odds
		local log = rawget(_G, "crowdTeamKitsLog")

		if log then
			log("crowd loaded: potential attendance %s", tostring(var_7_1))
		end

		for iter_7_0, iter_7_1 in ipairs(arg_7_0.onLoadedCallbacks) do
			iter_7_1(var_7_1)
		end

		arg_7_0.onLoadedCallbacks = nil
	end

	return var_7_0
end

function Crowd.isLoaded(arg_8_0)
	return arg_8_0.crowdScene:isLoaded()
end

function Crowd.reload(arg_9_0, arg_9_1)
	arg_9_0.crowdScene:disposePartial()

	local var_9_0 = "crowd/anims.dat"
	local var_9_1 = "crowd/nodefiles/" .. arg_9_1 .. "_crowdnodes.nodefile"
	local var_9_2 = var_0_17(nil)

	arg_9_0.crowdScene:initialisePartial(var_9_1, var_9_0, var_9_2)
end

function Crowd.register(arg_10_0, arg_10_1, arg_10_2, arg_10_3, arg_10_4, arg_10_5, arg_10_6, arg_10_7)
	arg_10_7.crowdScene = arg_10_0.crowdScene

	arg_10_5.soundSystem:registerSoundOnlyEvents(arg_10_0, {
		PlayWinningCrowdEvent = arg_10_0.onPlayWinningCrowdEvent
	})

	local function var_10_0(arg_11_0)
		return function(...)
			return arg_11_0(arg_10_0, ...)
		end
	end

	local var_10_1 = {}

	for iter_10_0, iter_10_1 in pairs(var_10_1) do
		arg_10_1:registerTentativeEventListener(iter_10_1, iter_10_0)
	end

	local var_10_2 = {
		AdvanceToNextTimePeriodEvent = var_10_0(arg_10_0.onAdvanceToNextTimePeriodEvent),
		BallCollisionEvent = var_10_0(arg_10_0.onBallCollisionEvent),
		ConversionOutcomeEvent = var_10_0(arg_10_0.onConversionOutcomeEvent),
		DisposalEvent = var_10_0(arg_10_0.onDisposalEvent),
		FieldGoalSuccessEvent = var_10_0(arg_10_0.onFieldGoalSuccessEvent),
		ForwardPassEvent = var_10_0(arg_10_0.onForwardPassEvent),
		GameOverEvent = var_10_0(arg_10_0.onGameOverEvent),
		HeldUpEvent = var_10_0(arg_10_0.onHeldUpEvent),
		InjuryEvent = var_10_0(arg_10_0.onInjuryEvent),
		InTouchEvent = var_10_0(arg_10_0.onInTouchEvent),
		KnockOnEvent = var_10_0(arg_10_0.onKnockOnEvent),
		LineBreakEvent = var_10_0(arg_10_0.onLineBreakEvent),
		PenaltyAwardedEvent = var_10_0(arg_10_0.onPenaltyAwardedEvent),
		PenaltyGoalFailEvent = var_10_0(arg_10_0.onPenaltyGoalFailEvent),
		PenaltyGoalSuccessEvent = var_10_0(arg_10_0.onPenaltyGoalSuccessEvent),
		TimePeriodExpiredEvent = var_10_0(arg_10_0.onTimePeriodExpiredEvent),
		TryScoredEvent = var_10_0(arg_10_0.onTryScoredEvent)
	}

	for iter_10_2, iter_10_3 in pairs(var_10_2) do
		arg_10_1:registerSolidEventListener(iter_10_3, iter_10_2)
	end
end

function Crowd.processCrowdEventQueue(arg_13_0, arg_13_1, arg_13_2, arg_13_3)
	local var_13_0 = 1

	while var_13_0 <= #arg_13_0.crowdQueueEvent do
		local var_13_1 = arg_13_0.crowdQueueEvent[var_13_0]

		if not var_13_1 then
			break
		end

		local var_13_2 = var_13_1.fn

		if var_13_2 then
			if var_13_1.time <= arg_13_3:ToSeconds() then
				table.remove(arg_13_0.crowdQueueEvent, var_13_0)
				var_13_2(arg_13_1, arg_13_2)
			else
				var_13_0 = var_13_0 + 1
			end
		end
	end
end

function Crowd.addOnLoadedCallback(arg_14_0, arg_14_1)
	table.insert(arg_14_0.onLoadedCallbacks, arg_14_1)
end

function Crowd.getPotentialAttendanceCount(arg_15_0)
	return arg_15_0.crowdScene:getPotentialAttendanceCount()
end

function Crowd.setCrowdSound(arg_16_0, arg_16_1)
	if not arg_16_1 or not arg_16_1.enabled then
		return
	end

	arg_16_0.crowdSound = arg_16_1
end

function Crowd.dispose(arg_17_0)
	arg_17_0.crowdScene:dispose()

	if arg_17_0.crowdSound then
		arg_17_0.crowdSound = nil
	end

	arg_17_0.eventQueue = nil

	local var_17_0 = arg_17_0.soundManager

	for iter_17_0, iter_17_1 in pairs(arg_17_0.markerCallbacks) do
		var_17_0:removeMarkerCallback(iter_17_0)
	end

	arg_17_0.markerCallbacks = nil
	arg_17_0.soundManager = nil
end

function Crowd.getCrowdScene(arg_18_0)
	return arg_18_0.crowdScene
end

function Crowd.enqueueAnimation(arg_19_0, arg_19_1, arg_19_2, arg_19_3)
	arg_19_0.crowdScene:enqueueAnimation(arg_19_1, arg_19_2, arg_19_3)
end

function Crowd.update(arg_20_0, arg_20_1, arg_20_2, arg_20_3, arg_20_4, arg_20_5, arg_20_6)
	profile.push("Crowd:update()")

	if not arg_20_0.initialised then
		arg_20_0:startNewCrowdEvent("Initialise")
		arg_20_0:playAnimation(var_0_5.idle, arg_20_0.TAGS_ALL)

		arg_20_0.initialised = true
	end

	local var_20_0 = arg_20_0.crowdScene

	var_20_0:update(arg_20_5)

	local var_20_1 = arg_20_0.crowdSound

	if var_20_1 then
		local var_20_2 = var_20_0:getCrowdPercentage()

		var_20_1:setCrowdPercentage(var_20_2)
		var_0_12(arg_20_0, arg_20_1)
	end

	local var_20_3 = arg_20_1.soundSystem
	local var_20_4 = false
	local var_20_5 = {}

	for iter_20_0, iter_20_1 in pairs(arg_20_0.fallbackTriggers) do
		local var_20_6 = iter_20_1.audioPlayingId

		if var_20_6 > 0 then
			local var_20_7 = not var_20_3:isEventActive({
				eventPlayId = var_20_6
			})

			if var_20_7 then
				var_20_4 = true

				local var_20_8 = var_20_5[iter_20_1.anim]

				if not var_20_8 then
					var_20_8 = {}
					var_20_5[iter_20_1.anim] = var_20_8
				end

				table.insert(var_20_8, iter_20_0)
				var_0_16("Play animation fallback: crowdTag %t, eventId %t, soundFinished %t, anim %t", iter_20_0, iter_20_1.eventId, var_20_7, iter_20_1.anim)

				iter_20_1.eventId = 0
				iter_20_1.audioPlayingId = 0
			end
		end
	end

	if var_20_4 then
		arg_20_0:startNewCrowdEvent("AnimationFallback")

		for iter_20_2, iter_20_3 in pairs(var_20_5) do
			arg_20_0:playAnimation(iter_20_2, iter_20_3)
		end
	end

	arg_20_0:processCrowdEventQueue(arg_20_2, arg_20_3, arg_20_6)
	profile.pop("Crowd:update()")
end

function Crowd.startNewCrowdEvent(arg_21_0, arg_21_1)
	arg_21_0.eventGroup = arg_21_1
	arg_21_0.eventId = arg_21_0.eventId + 1
end

function Crowd.playSound(arg_22_0, arg_22_1, arg_22_2, arg_22_3)
	if arg_22_0.crowdSound and arg_22_1 then
		local var_22_0 = arg_22_0.crowdSound:playSound(arg_22_1, arg_22_3, arg_22_2)

		if var_22_0 then
			if arg_22_2 then
				for iter_22_0, iter_22_1 in ipairs(arg_22_2) do
					var_0_16("Set animation fallback: crowdTag %t, eventId %t, eventGroup %t, soundKey %t, audioPlayingId %t", iter_22_1, arg_22_0.eventId, arg_22_0.eventGroup, arg_22_1, var_22_0)

					local var_22_1 = arg_22_0.fallbackTriggers[iter_22_1]

					var_22_1.eventId = arg_22_0.eventId
					var_22_1.audioPlayingId = var_22_0
				end
			end

			local var_22_2 = arg_22_0.hook

			if var_22_2 then
				var_22_2:pushCrowdEvent(arg_22_0.eventId, arg_22_0.eventGroup, arg_22_2, arg_22_1)
			end
		end
	end
end

function Crowd.playAnimation(arg_23_0, arg_23_1, arg_23_2, arg_23_3, arg_23_4)
	local var_23_0 = arg_23_0.hook
	local var_23_1 = arg_23_4 or false

	for iter_23_0, iter_23_1 in ipairs(arg_23_2) do
		arg_23_0:enqueueAnimation(iter_23_1, arg_23_1, var_23_1)

		if not arg_23_3 then
			local var_23_2 = arg_23_0.fallbackTriggers[iter_23_1]

			if var_23_2.eventId ~= arg_23_0.eventId then
				var_0_16("Clearing animation fallback: crowdTag %t, oldEventId %t, newEventId/group %t/%t, newAnim %t", iter_23_1, var_23_2.eventId, arg_23_0.eventId, arg_23_0.eventGroup, arg_23_1)

				var_23_2.eventId = 0
				var_23_2.audioPlayingId = 0
			end
		end

		if var_23_0 then
			var_23_0:setCurrentAnimationGroup(iter_23_1, arg_23_1, false)
		end
	end

	if var_23_0 then
		var_23_0:pushCrowdEvent(arg_23_0.eventId, arg_23_0.eventGroup, arg_23_2, nil, arg_23_1)
	end
end

function Crowd.playSoundAndAnimation(arg_24_0, arg_24_1, arg_24_2, arg_24_3, arg_24_4)
	arg_24_0:playSound(arg_24_1, arg_24_3, arg_24_4)
	arg_24_0:playAnimation(arg_24_2, arg_24_3)
end

function Crowd.pushDebugCommentGroup(arg_25_0, arg_25_1)
	local var_25_0 = arg_25_0.hook

	if arg_25_1 and var_25_0 then
		var_25_0:pushCrowdEventCommentGroup(arg_25_0.eventId, arg_25_0.eventGroup, arg_25_1)
	end
end

function Crowd.pushDebugCommentAnimation(arg_26_0, arg_26_1, arg_26_2)
	local var_26_0 = arg_26_0.hook

	if var_26_0 then
		arg_26_1 = "> " .. arg_26_1

		var_26_0:pushCrowdEventCommentAnimation(arg_26_0.eventId, arg_26_0.eventGroup, arg_26_2, arg_26_1)
	end
end

function Crowd.pushDebugCommentSound(arg_27_0, arg_27_1, arg_27_2)
	local var_27_0 = arg_27_0.hook

	if var_27_0 then
		arg_27_1 = "> " .. arg_27_1

		var_27_0:pushCrowdEventCommentSound(arg_27_0.eventId, arg_27_0.eventGroup, arg_27_2, arg_27_1)
	end
end

function Crowd.stopSpecificSound(arg_28_0, arg_28_1, arg_28_2)
	if arg_28_0.crowdSound and arg_28_1 then
		local var_28_0 = arg_28_2.fadeTime or 0.2

		if arg_28_0.crowdSound:stopSoundsOnAllCrowdSoundObjects(arg_28_1, var_28_0) then
			local var_28_1 = arg_28_0.hook

			if var_28_1 then
				var_28_1:pushCrowdStopEvent(arg_28_0.eventId, arg_28_0.eventGroup, nil, arg_28_1)
			end
		end
	end
end

function var_0_10(arg_29_0, arg_29_1, arg_29_2)
	local var_29_0 = {
		CrowdEventFinish = function(arg_30_0)
			var_0_12(arg_29_0, arg_29_2)
			arg_29_0:startNewCrowdEvent("AnimationFallback")

			for iter_30_0, iter_30_1 in pairs(arg_29_0.fallbackTriggers) do
				if iter_30_1.audioPlayingId == arg_30_0 then
					arg_29_0:playAnimation(iter_30_1.anim, {
						iter_30_0
					})

					iter_30_1.audioPlayingId = 0
				end
			end
		end
	}

	for iter_29_0, iter_29_1 in pairs(var_29_0) do
		arg_29_1:addMarkerCallback(iter_29_0, iter_29_1)
	end

	return var_29_0
end

local function var_0_19(arg_31_0, arg_31_1)
	local var_31_0 = arg_31_0.crowdSound

	if var_31_0 then
		var_31_0:trySetExtraCrowdExcitement(arg_31_1)
	end
end

function var_0_12(arg_32_0, arg_32_1)
	local var_32_0 = arg_32_0.crowdSound.crowdExcitementValues
	local var_32_1 = var_32_0 and var_32_0.prevValueSentToWwise

	if var_32_1 then
		local var_32_2 = false
		local var_32_3 = var_0_5.idle

		if var_32_1 > 80 then
			var_32_3 = var_0_5.idle_excite_level_2
		elseif var_32_1 > 60 then
			var_32_3 = var_0_5.idle_excite_level_1
		end

		local var_32_4 = arg_32_0.fallbackTriggers

		for iter_32_0, iter_32_1 in ipairs(arg_32_0.TAGS_ALL) do
			if var_32_4[iter_32_1].audioPlayingId == 0 and var_32_4[iter_32_1].anim ~= var_32_3 then
				var_0_16("Idle level changed: crowdTag %t, oldAnim %t, newAnim %t", iter_32_1, var_32_4[iter_32_1].anim, var_32_3)

				if not var_32_2 then
					var_32_2 = true

					arg_32_0:startNewCrowdEvent("IdleLevelChange")
				end

				local var_32_5 = true

				arg_32_0:playAnimation(var_32_3, {
					iter_32_1
				}, var_32_5)
			end

			var_32_4[iter_32_1].anim = var_32_3
		end
	end
end

local function var_0_20(arg_33_0, arg_33_1)
	local var_33_0 = var_0_1.boundaryLine.sortedPoints
	local var_33_1 = var_33_0.asTable
	local var_33_2 = var_33_0.count
	local var_33_3 = arg_33_0.currentBoundaryIdx
	local var_33_4 = var_33_3 == var_33_2 and 1 or var_33_3 + 1
	local var_33_5 = arg_33_0.currentDistance
	local var_33_6 = arg_33_0.lastBoundaryNodeDist
	local var_33_7 = var_33_1[var_33_3]
	local var_33_8 = var_33_1[var_33_4]
	local var_33_9 = native.distance2(var_33_7, var_33_8)
	local var_33_10 = (var_33_5 - var_33_6) / var_33_9
	local var_33_11 = native.lerp2(var_33_10, var_33_7, var_33_8)
	local var_33_12 = var_33_8 - var_33_7
	local var_33_13 = native.vec2(var_33_12.y, -var_33_12.x)
	local var_33_14 = native.normalize2(var_33_13)

	if not arg_33_0.lastWaveStep or math.abs(arg_33_0.lastWaveStep - arg_33_0.currentDistance) >= arg_33_0.stepsEvery then
		arg_33_0.lastWaveStep = var_33_5

		local var_33_15 = var_33_11 + var_33_14 * 10
		local var_33_16 = var_33_11 + var_33_14 * 20
		local var_33_17 = var_33_11 + var_33_14 * 30
		local var_33_18 = var_33_11 + var_33_14 * 40
		local var_33_19 = {}

		table.insert(var_33_19, var_33_15)
		table.insert(var_33_19, var_33_16)
		table.insert(var_33_19, var_33_17)
		table.insert(var_33_19, var_33_18)

		for iter_33_0, iter_33_1 in ipairs(var_33_19) do
			local var_33_20 = native.vec3(0, 2, 0)

			arg_33_0.crowdScene:addAnimationSphere(var_0_15(iter_33_1) + var_33_20, 7, 1.2, 0.35, var_0_5.cs_cheer_stand_excited)
		end
	end

	local var_33_21 = var_33_5 + arg_33_1 * arg_33_0.waveSpeed
	local var_33_22 = var_33_21 - var_33_6

	while var_33_9 < var_33_22 do
		var_33_3 = var_33_3 == var_33_2 and 1 or var_33_3 + 1

		local var_33_23 = var_33_3 == var_33_2 and 1 or var_33_3 + 1

		var_33_6 = var_33_6 + var_33_9
		var_33_22 = var_33_21 - var_33_6
		var_33_9 = native.distance2(var_33_1[var_33_3], var_33_1[var_33_23])

		if var_33_3 == 1 then
			var_33_21 = var_33_22
			var_33_6 = 0
		end
	end

	arg_33_0.lastBoundaryNodeDist = var_33_6
	arg_33_0.currentBoundaryIdx = var_33_3
	arg_33_0.currentDistance = var_33_21
end

function Crowd.onAdvanceToNextTimePeriodEvent(arg_34_0, arg_34_1, arg_34_2, arg_34_3, arg_34_4, arg_34_5, arg_34_6, arg_34_7, arg_34_8, arg_34_9)
	arg_34_0:startNewCrowdEvent("EndTimePeriod")
	arg_34_0:playSoundAndAnimation("cheer_mid", var_0_5.excitement_level_3, arg_34_0.TAGS_ALL, {
		delay = 1
	})
end

function Crowd.onBallCollisionEvent(arg_35_0, arg_35_1, arg_35_2, arg_35_3, arg_35_4, arg_35_5, arg_35_6, arg_35_7, arg_35_8, arg_35_9)
	local var_35_0 = VERIFY(arg_35_1.colliderType)
	local var_35_1 = arg_35_1.disposalType
	local var_35_2 = isAnyOf(var_35_0, {
		var_0_4.GoalPostCrossbar,
		var_0_4.GoalPostVertical,
		var_0_4.GoalPostPadding
	})

	if var_35_1 == native.EDisposalType.Kick and var_35_2 then
		arg_35_0:startNewCrowdEvent("BallHitPost")
		arg_35_0:playSound("groan_low", arg_35_0.TAGS_ALL, {
			noDuplicate = true
		})
	end

	arg_35_0.kickAtGoalValid = false
end

function Crowd.onConversionOutcomeEvent(arg_36_0, arg_36_1, arg_36_2, arg_36_3, arg_36_4, arg_36_5, arg_36_6, arg_36_7, arg_36_8, arg_36_9)
	local var_36_0 = arg_36_1.kickerSide

	if arg_36_1.wasSuccessful then
		arg_36_0:playConversionAnimationAndSound(var_36_0)
	else
		arg_36_0:startNewCrowdEvent("ConversionMissed")

		local var_36_1 = arg_36_1.failedDueToTimer and "groan_high" or "sfxCrowdConversionOutcomeMissed"
		local var_36_2 = getCrowdTagsForSide(arg_36_0, var_36_0)

		arg_36_0:playSoundAndAnimation(var_36_1, var_0_5.frustrate_level_5, var_36_2)
	end

	arg_36_0.conversionSuccessEventPlayed = false
end

function Crowd.onDisposalEvent(arg_37_0, arg_37_1, arg_37_2, arg_37_3, arg_37_4, arg_37_5, arg_37_6, arg_37_7, arg_37_8, arg_37_9)
	local var_37_0 = arg_37_1.disposalType
	local var_37_1 = arg_37_1.maker

	if var_37_1 then
		arg_37_0:startNewCrowdEvent("Disposal")

		local var_37_2 = arg_37_1.disposalSubType
		local var_37_3 = arg_37_8:getGameObject(var_37_1).side

		if var_37_2 == var_0_3.KickOff or var_37_2 == var_0_3.KickOffDrop then
			arg_37_0:pushDebugCommentGroup("KickOff")

			local var_37_4 = arg_37_7:getTimeElapsedEntity()

			if (var_37_4 and var_37_4.minutesElapsed) < 1 then
				arg_37_0:playSoundAndAnimation("cheer_mid", var_0_5.excitement_level_3, arg_37_0.TAGS_ALL)
			end

			var_0_19(arg_37_0, 10)
		elseif var_37_2 == var_0_3.Offload then
			arg_37_0:pushDebugCommentGroup("Pass")
			var_0_19(arg_37_0, 10)
		end

		local var_37_5 = arg_37_1.time
		local var_37_6 = getPossibleGoalFromKick(var_37_1, var_37_2, arg_37_8, var_37_5)

		if var_37_6 and var_37_6.passGoalTime then
			arg_37_0.kickAtGoalValid = true

			local var_37_7 = var_37_6.timeToScorePoint
			local var_37_8 = var_37_7 * (var_37_6.distanceToGoal / var_0_1.fieldLength) * 1.5
			local var_37_9 = 0.5
			local var_37_10 = var_37_5 + native.clamp1(var_37_8, var_37_9, var_37_7)
			local var_37_11 = var_37_2
			local var_37_12

			if var_37_2 == var_0_3.FieldGoal then
				function var_37_12(arg_38_0, arg_38_1)
					if arg_37_0.kickAtGoalValid then
						local var_38_0 = arg_37_8:getGameObject(var_37_1).side

						arg_37_0:playFieldGoalAnimationAndSound(arg_38_0, arg_38_1, var_38_0)
					end
				end
			else
				function var_37_12(arg_39_0, arg_39_1)
					if arg_37_0.kickAtGoalValid then
						local var_39_0 = arg_37_8:getGameObject(var_37_1).side

						arg_37_0:playConversionAnimationAndSound(var_39_0)
					end
				end
			end

			table.insert(arg_37_0.crowdQueueEvent, {
				fn = var_37_12,
				time = var_37_10,
				eventType = var_37_11
			})
		end
	end
end

function Crowd.onFieldGoalSuccessEvent(arg_40_0, arg_40_1, arg_40_2, arg_40_3, arg_40_4, arg_40_5, arg_40_6, arg_40_7, arg_40_8, arg_40_9)
	arg_40_0:playFieldGoalAnimationAndSound(arg_40_6, arg_40_7, arg_40_1.scoringSide)

	arg_40_0.fieldGoalSuccessEventPlayed = false
end

function Crowd.onForwardPassEvent(arg_41_0, arg_41_1, arg_41_2, arg_41_3, arg_41_4, arg_41_5, arg_41_6, arg_41_7, arg_41_8, arg_41_9)
	local var_41_0 = arg_41_1.side
	local var_41_1 = sidehelper.getOtherSide(var_41_0)
	local var_41_2 = getCrowdTagsForSide(arg_41_0, var_41_1)
	local var_41_3 = getCrowdTagsForSide(arg_41_0, var_41_0)

	arg_41_0:startNewCrowdEvent("ForwardPass")
	arg_41_0:playSoundAndAnimation("cheer_low", var_0_5.excitement_level_1, var_41_2)
	arg_41_0:playSoundAndAnimation("groan_high", var_0_5.frustrate_level_4, var_41_3)
end

function Crowd.onGameOverEvent(arg_42_0, arg_42_1, arg_42_2, arg_42_3, arg_42_4, arg_42_5, arg_42_6, arg_42_7, arg_42_8, arg_42_9)
	local var_42_0 = arg_42_6:getComponent("matchInData")
	local var_42_1 = VERIFY(arg_42_7:getScoreEntity()):getWinningSide(var_42_0)

	arg_42_0:startNewCrowdEvent("GameOver")

	if sidehelper.isValidSide(var_42_1) then
		local var_42_2 = var_42_1 == var_0_6
		local var_42_3 = var_42_2 and arg_42_0.TAGS_HOME_NEUTRAL or arg_42_0.TAGS_AWAY_NEUTRAL
		local var_42_4 = var_42_2 and arg_42_0.TAGS_AWAY or arg_42_0.TAGS_HOME

		arg_42_0:playSoundAndAnimation("cheer_high", var_0_5.excitement_level_5, var_42_3)
		arg_42_0:playSoundAndAnimation("groan_high", var_0_5.frustrate_level_4, var_42_4)
		arg_42_0:playSound("applause_loop", var_42_3)
	else
		arg_42_0:playSound("applause_loop", arg_42_0.TAGS_ALL)
		arg_42_0:playSoundAndAnimation("cheer_high", var_0_5.excitement_level_4, arg_42_0.TAGS_ALL)
	end
end

function Crowd.onHeldUpEvent(arg_43_0, arg_43_1, arg_43_2, arg_43_3, arg_43_4, arg_43_5, arg_43_6, arg_43_7, arg_43_8, arg_43_9)
	local var_43_0 = arg_43_1.maker
	local var_43_1 = arg_43_8:getGameObject(var_43_0).side
	local var_43_2 = getCrowdTagsForSide(arg_43_0, var_43_1)

	arg_43_0:startNewCrowdEvent("HeldUp")
	arg_43_0:playSoundAndAnimation("groan_high", var_0_5.frustrate_level_4, var_43_2)
end

function Crowd.onInjuryEvent(arg_44_0, arg_44_1, arg_44_2, arg_44_3, arg_44_4, arg_44_5, arg_44_6, arg_44_7, arg_44_8, arg_44_9)
	local var_44_0 = arg_44_1.id
	local var_44_1 = arg_44_8:getGameObject(var_44_0).side == var_0_6 and arg_44_0.TAGS_HOME_NEUTRAL or arg_44_0.TAGS_AWAY_NEUTRAL

	arg_44_0:startNewCrowdEvent("Injury")
	arg_44_0:playSoundAndAnimation("groan_high", var_0_5.frustrate_level_4, var_44_1)
end

function Crowd.onInTouchEvent(arg_45_0, arg_45_1, arg_45_2, arg_45_3, arg_45_4, arg_45_5, arg_45_6, arg_45_7, arg_45_8, arg_45_9)
	local var_45_0 = arg_45_1.restartSide
	local var_45_1 = arg_45_1.offendingSide
	local var_45_2 = getCrowdTagsForSide(arg_45_0, var_45_0)

	arg_45_0:startNewCrowdEvent("InTouch")

	if var_45_1 ~= var_45_0 then
		local var_45_3 = getCrowdTagsForSide(arg_45_0, var_45_1)

		arg_45_0:playSoundAndAnimation("groan_low", var_0_5.frustrate_level_3, var_45_3)
	end

	arg_45_0:playSoundAndAnimation("cheer_low", var_0_5.excitement_level_1, var_45_2)
end

function Crowd.onKnockOnEvent(arg_46_0, arg_46_1, arg_46_2, arg_46_3, arg_46_4, arg_46_5, arg_46_6, arg_46_7, arg_46_8, arg_46_9)
	local var_46_0 = arg_46_1.advantageSide

	if sidehelper.isValidSide(var_46_0) then
		arg_46_0:startNewCrowdEvent("KnockOn")

		local var_46_1 = getCrowdTagsForSide(arg_46_0, var_46_0)
		local var_46_2 = sidehelper.getOtherSide(var_46_0)
		local var_46_3 = getCrowdTagsForSide(arg_46_0, var_46_2)

		arg_46_0:playSoundAndAnimation("cheer_low_mid", var_0_5.excitement_level_2, var_46_1)
		arg_46_0:playSoundAndAnimation("groan_low", var_0_5.frustrate_level_2, var_46_3)
	end
end

function Crowd.onLineBreakEvent(arg_47_0, arg_47_1, arg_47_2, arg_47_3, arg_47_4, arg_47_5, arg_47_6, arg_47_7, arg_47_8, arg_47_9)
	arg_47_0:startNewCrowdEvent("LineBreak")

	local var_47_0 = "cheer_mid_line_break"
	local var_47_1 = arg_47_1.attackingSide
	local var_47_2 = getCrowdTagsForSide(arg_47_0, var_47_1)

	if arg_47_4.soundSystem:isEventActive(var_47_0) ~= nil then
		arg_47_0:pushDebugCommentGroup("linebreak retrigger")
		arg_47_0:playSoundAndAnimation("cheer_low_mid_line_break", var_0_5.excitement_level_1, var_47_2)
	else
		arg_47_0:playSoundAndAnimation(var_47_0, var_0_5.excitement_level_3, var_47_2)
		var_0_19(arg_47_0, 15)
	end
end

function Crowd.onPenaltyAwardedEvent(arg_48_0, arg_48_1, arg_48_2, arg_48_3, arg_48_4, arg_48_5, arg_48_6, arg_48_7, arg_48_8, arg_48_9)
	local var_48_0 = arg_48_1.sideAwardedPenalty
	local var_48_1 = sidehelper.getOtherSide(var_48_0)
	local var_48_2 = getCrowdTagsForSide(arg_48_0, var_48_0)
	local var_48_3 = getCrowdTagsForSide(arg_48_0, var_48_1)
	local var_48_4 = arg_48_1.infringementType == penaltytypes.infringementTypes.HighTackle
	local var_48_5 = var_48_4 and "groan_high" or "groan_low"
	local var_48_6 = var_48_4 and "HighTacklePenaltyAwarded" or "PenaltyAwarded"

	arg_48_0:startNewCrowdEvent(var_48_6)
	arg_48_0:playSoundAndAnimation(var_48_5, var_0_5.frustrate_level_3, var_48_3)
	arg_48_0:playSoundAndAnimation("cheer_low_mid", var_0_5.excitement_level_2, var_48_2)
	var_0_19(arg_48_0, 20)

	if VERIFY(arg_48_6:getComponent("statistics")):getTeamStat(var_48_1, "penaltiesConceded") % 4 == 0 then
		arg_48_0:playSound("boo_high", var_48_3, {
			delay = 1
		})
	end
end

function Crowd.onPenaltyGoalFailEvent(arg_49_0, arg_49_1, arg_49_2, arg_49_3, arg_49_4, arg_49_5, arg_49_6, arg_49_7, arg_49_8, arg_49_9)
	local var_49_0 = arg_49_1.maker
	local var_49_1 = arg_49_8:getGameObject(var_49_0).side
	local var_49_2 = sidehelper.getOtherSide(var_49_1)
	local var_49_3 = getCrowdTagsForSide(arg_49_0, var_49_1)
	local var_49_4 = getCrowdTagsForSide(arg_49_0, var_49_2)

	arg_49_0:startNewCrowdEvent("PenaltyGoalFail")
	arg_49_0:playSoundAndAnimation("cheer_mid", var_0_5.excitement_level_2, var_49_4)
	arg_49_0:playSoundAndAnimation("groan_low", var_0_5.frustrate_level_2, var_49_3)
end

function Crowd.onPenaltyGoalSuccessEvent(arg_50_0, arg_50_1, arg_50_2, arg_50_3, arg_50_4, arg_50_5, arg_50_6, arg_50_7, arg_50_8, arg_50_9)
	local var_50_0 = arg_50_1.kickerSide
	local var_50_1 = sidehelper.getOtherSide(var_50_0)
	local var_50_2 = getCrowdTagsForSide(arg_50_0, var_50_0)
	local var_50_3 = getCrowdTagsForSide(arg_50_0, var_50_1)

	arg_50_0:startNewCrowdEvent("PenaltyGoalSuccess")
	arg_50_0:playSoundAndAnimation("cheer_high", var_0_5.excitement_level_3, var_50_2)
	arg_50_0:playSoundAndAnimation("groan_low", var_0_5.frustrate_level_2, var_50_3)
	var_0_19(arg_50_0, 15)
end

function Crowd.onTimePeriodExpiredEvent(arg_51_0, arg_51_1, arg_51_2, arg_51_3, arg_51_4, arg_51_5, arg_51_6, arg_51_7, arg_51_8, arg_51_9)
	local var_51_0 = arg_51_7:getMatchProgressionEntity().currentTimePeriod

	arg_51_0:startNewCrowdEvent("TimePeriodExpired")

	if var_51_0 == 1 then
		arg_51_0:playSoundAndAnimation("cheer_mid", var_0_5.excitement_level_3, arg_51_0.TAGS_ALL)
	else
		local var_51_1 = arg_51_6:getComponent("matchInData")
		local var_51_2 = VERIFY(arg_51_7:getScoreEntity())
		local var_51_3 = var_51_2:getMargin(var_51_1)

		if var_51_3 ~= 0 then
			local var_51_4 = var_51_1:getScoreValue(native.EScoreType.Try)
			local var_51_5 = var_51_1:getScoreValue(native.EScoreType.ConversionGoal)
			local var_51_6 = var_51_1:getScoreValue(native.EScoreType.PenaltyGoal)
			local var_51_7 = var_51_4 + var_51_5
			local var_51_8 = "cheer_low"
			local var_51_9 = "groan_low"
			local var_51_10 = var_0_5.excitement_level_1
			local var_51_11 = var_0_5.frustrate_level_1

			if var_51_7 < var_51_3 then
				var_51_8 = "cheer_high"
				var_51_9 = "groan_high"
				var_51_10 = var_0_5.excitement_level_5
				var_51_11 = var_0_5.frustrate_level_3
			elseif var_51_6 < var_51_3 then
				var_51_8 = "cheer_mid_high"
				var_51_9 = "groan_high"
				var_51_10 = var_0_5.excitement_level_3
				var_51_11 = var_0_5.frustrate_level_2
			end

			local var_51_12 = var_51_2:getWinningSide(var_51_1)
			local var_51_13 = sidehelper.getOtherSide(var_51_12)
			local var_51_14 = var_51_12 == var_0_6 and arg_51_0.TAGS_HOME_NEUTRAL or arg_51_0.TAGS_AWAY_NEUTRAL
			local var_51_15 = getCrowdTagsForSide(arg_51_0, var_51_13)

			arg_51_0:playSoundAndAnimation(var_51_8, var_51_10, var_51_14)
			arg_51_0:playSoundAndAnimation(var_51_9, var_51_11, var_51_15)
		end
	end
end

function Crowd.onTryScoredEvent(arg_52_0, arg_52_1, arg_52_2, arg_52_3, arg_52_4, arg_52_5, arg_52_6, arg_52_7, arg_52_8, arg_52_9)
	arg_52_0:startNewCrowdEvent("TryScored")

	local var_52_0 = arg_52_1.scoringSide
	local var_52_1 = sidehelper.getOtherSide(var_52_0)
	local var_52_2 = var_52_0 == var_0_6 and arg_52_0.TAGS_HOME_NEUTRAL or arg_52_0.TAGS_AWAY_NEUTRAL
	local var_52_3 = getCrowdTagsForSide(arg_52_0, var_52_1)

	arg_52_0:playSoundAndAnimation("cheer_high", var_0_5.excitement_level_5, var_52_2)
	arg_52_0:playSoundAndAnimation("groan_high", var_0_5.frustrate_level_5, var_52_3)
	var_0_19(arg_52_0, 30)
end

function Crowd.playConversionAnimationAndSound(arg_53_0, arg_53_1)
	if arg_53_0.conversionSuccessEventPlayed then
		return
	end

	arg_53_0:startNewCrowdEvent("ConversionSuccess")

	local var_53_0 = sidehelper.getOtherSide(arg_53_1)
	local var_53_1 = getCrowdTagsForSide(arg_53_0, arg_53_1)
	local var_53_2 = getCrowdTagsForSide(arg_53_0, var_53_0)

	arg_53_0:playSoundAndAnimation("cheer_high", var_0_5.excitement_level_4, var_53_1)
	arg_53_0:playSoundAndAnimation("cheer_mid", var_0_5.excitement_level_2, arg_53_0.TAGS_NEUTRAL)
	arg_53_0:playSoundAndAnimation("groan_low", var_0_5.frustrate_level_4, var_53_2)
	var_0_19(arg_53_0, 20)

	arg_53_0.conversionSuccessEventPlayed = true
end

function Crowd.playFieldGoalAnimationAndSound(arg_54_0, arg_54_1, arg_54_2, arg_54_3)
	if arg_54_0.fieldGoalSuccessEventPlayed then
		return
	end

	arg_54_0:startNewCrowdEvent("FieldGoalSuccess")
	arg_54_0:playSoundAndAnimation("cheer_mid", var_0_5.excitement_level_3, arg_54_0.TAGS_NEUTRAL)

	local var_54_0 = sidehelper.getOtherSide(arg_54_3)
	local var_54_1 = getCrowdTagsForSide(arg_54_0, arg_54_3)
	local var_54_2 = getCrowdTagsForSide(arg_54_0, var_54_0)
	local var_54_3 = arg_54_1:getComponent("matchInData")

	if VERIFY(arg_54_2:getScoreEntity()):getMargin(var_54_3) <= 5 then
		arg_54_0:pushDebugCommentGroup("Margin <= 5")
		var_0_19(arg_54_0, 30)
		arg_54_0:playSoundAndAnimation("cheer_high", var_0_5.excitement_level_5, var_54_1)
		arg_54_0:playSoundAndAnimation("groan_high", var_0_5.frustrate_level_4, var_54_2)
	else
		arg_54_0:pushDebugCommentGroup("Margin > 5")
		var_0_19(arg_54_0, 15)
		arg_54_0:playSoundAndAnimation("cheer_mid_high", var_0_5.excitement_level_4, var_54_1)
		arg_54_0:playSoundAndAnimation("groan_low", var_0_5.frustrate_level_3, var_54_2)
	end

	arg_54_0.fieldGoalSuccessEventPlayed = true
end

function Crowd.onPlayWinningCrowdEvent(arg_55_0, arg_55_1, arg_55_2, arg_55_3, arg_55_4, arg_55_5, arg_55_6)
	local var_55_0 = arg_55_3:getComponent("matchInData")
	local var_55_1 = VERIFY(arg_55_4:getScoreEntity()):getWinningSide(var_55_0)
	local var_55_2 = true
	local var_55_3 = true

	arg_55_0:startNewCrowdEvent("PlayWinningCrowdEvent")

	if sidehelper.isValidSide(var_55_1) then
		local var_55_4 = var_55_1 == var_0_6
		local var_55_5 = var_55_4 and arg_55_0.TAGS_HOME_NEUTRAL or arg_55_0.TAGS_AWAY_NEUTRAL
		local var_55_6 = var_55_4 and arg_55_0.TAGS_AWAY or arg_55_0.TAGS_HOME

		arg_55_0:playAnimation(var_0_5.excitement_level_5, var_55_5, var_55_2, var_55_3)
		arg_55_0:playAnimation(var_0_5.frustrate_level_1, var_55_6, var_55_2, var_55_3)
	else
		arg_55_0:playAnimation(var_0_5.excitement_level_4, arg_55_0.TAGS_ALL, var_55_2, var_55_3)
	end

	var_0_19(arg_55_0, 20)
end

function getPossibleGoalFromKick(arg_56_0, arg_56_1, arg_56_2, arg_56_3)
	if not arg_56_1 or not arg_56_2 then
		return nil
	end

	local var_56_0 = {}

	if arg_56_1 == var_0_3.FieldGoal or arg_56_1 == var_0_3.Conversion then
		local var_56_1 = arg_56_2:getBallObject()
		local var_56_2 = var_56_1:getBallTrajectory()

		if var_56_2 then
			local var_56_3 = arg_56_2:getGameObject(arg_56_0):getGoalPos()
			local var_56_4 = native.vec3(var_56_3.x > 0 and 1 or -1, 0, 0)
			local var_56_5 = var_56_3:tovec3()
			local var_56_6 = var_56_2:getTimeCrossedPlane(var_56_2:getTailTime(), var_56_2:getHeadTime(), var_56_5, var_56_4)
			local var_56_7 = var_56_6 and var_56_2:getPos3At(var_56_6)

			if var_56_7 then
				local var_56_8 = var_0_1.goalPostSpacing * 0.5 - 0.5
				local var_56_9 = var_0_1.goalCrossBarHeight + 0.5 > var_56_7.y
				local var_56_10 = var_56_8 < math.abs(var_56_7.z)

				if not var_56_9 and not var_56_10 then
					local var_56_11 = var_56_6:ToSeconds()

					var_56_0.passGoalTime = var_56_11
					var_56_0.crossPosition = var_56_7
					var_56_0.timeToScorePoint = var_56_11 - arg_56_3:ToSeconds()
					var_56_0.distanceToGoal = native.distance3(var_56_1.pos3, var_56_7)
				end
			end
		end
	end

	return var_56_0
end

function getCrowdTagsForSide(arg_57_0, arg_57_1)
	local var_57_0

	if arg_57_1 == var_0_6 then
		var_57_0 = arg_57_0.TAGS_HOME
	elseif arg_57_1 == var_0_7 then
		var_57_0 = arg_57_0.TAGS_AWAY
	else
		var_57_0 = arg_57_0.TAGS_NEUTRAL
	end

	return var_57_0
end
