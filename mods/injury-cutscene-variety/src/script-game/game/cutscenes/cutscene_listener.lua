import("app.gameplay.gameplay_loadingscreen_helper")
import("base.side.sidehelper")
import("base.transition.nonbarrierwipe")
import("core.foundation.tablex")
import("design.cutscenes.cutscene_props")
import("game.ball.disposal_request")
import("game.camera.animated_camera")
import("game.cutscenes.cutscene_helper")
import("game.cutscenes.internal.cutscene_functions")
import("game.cutscenes.internal.cutscenequeue_request")
import("game.cutscenes.cutscene_playbackevents")
import("game.humanoid.humanoidtype")
import("game.player.playertype")
import("game.cutscenes.cutscene_config_loader")
import("game.cutscenes.cutscene_helper")
import("game.cutscenes.sequencedscene")
import("core.sequencer.sequencerfactory")
import("core.profile.profile")
import("rules.rules.rulesenvironment_cconfig")

local var_0_0 = rulesenvironment_cconfig.cBoundaryConfig

CutsceneState_WaitingToLoad = 0
CutsceneState_Loading = 1
CutsceneState_LoadedButWaiting = 2
CutsceneState_Loaded = 3
CutsceneState_Playback = 4
CutsceneState_Stopped = 5
FPS = 30

local function var_0_1(arg_1_0)
	local var_1_0 = false

	if arg_1_0.skipMixin then
		ASSERT(not arg_1_0.cutsceneSkippingDisabled)

		if not arg_1_0.cutsceneSkippingDisabled then
			var_1_0 = arg_1_0.skipMixin:checkForSkip()
		end
	elseif arg_1_0.event.externalSkip ~= nil and arg_1_0.event.externalSkip() then
		var_1_0 = true
	end

	return var_1_0
end

local function var_0_2(arg_2_0, arg_2_1)
	local var_2_0 = {}

	for iter_2_0, iter_2_1 in arg_2_1:activeObjects(humanoidtype.TypeId) do
		table.insert(var_2_0, iter_2_0)
	end

	return var_2_0
end

local function var_0_3(arg_3_0)
	return arg_3_0.state >= CutsceneState_LoadedButWaiting
end

local function var_0_4(arg_4_0)
	local var_4_0 = 0

	for iter_4_0 = 1, #arg_4_0 do
		if arg_4_0[iter_4_0].state >= CutsceneState_Loaded then
			var_4_0 = var_4_0 + 1
		end
	end

	return var_4_0
end

local function var_0_5(arg_5_0)
	for iter_5_0 = 1, #arg_5_0 do
		if arg_5_0[iter_5_0].state < CutsceneState_Loaded then
			return arg_5_0[iter_5_0]
		end
	end

	return nil
end

local function var_0_6(arg_6_0)
	for iter_6_0 = #arg_6_0, 1, -1 do
		if arg_6_0[iter_6_0].state >= CutsceneState_Loaded then
			return arg_6_0[iter_6_0]
		end
	end

	return nil
end

local function var_0_7(arg_7_0, arg_7_1)
	for iter_7_0, iter_7_1 in ipairs(arg_7_1) do
		if arg_7_0.id == iter_7_1.id then
			table.remove(arg_7_1, iter_7_0)

			break
		end
	end
end

Class("CutsceneListener", function(arg_8_0, arg_8_1)
	local var_8_0 = arg_8_1.services
	local var_8_1 = arg_8_1.matchInData

	arg_8_0.cutsceneConfigLoader = cutscene_config_loader.CutsceneConfigLoader()
	arg_8_0.scene = arg_8_1.scene
	arg_8_0.time = native.Time.FromSeconds(0)
	arg_8_0.isInCutsceneDebugger = false
	arg_8_0.crowd = arg_8_1.crowd
	arg_8_0.cutsceneQueue = {}
	arg_8_0.conditionalCutsceneQueue = {}
	arg_8_0.pendingUnload = {}
	arg_8_0.loadedAnimsets = {}
	arg_8_0.currentCutscene = nil
	arg_8_0.lastRemoved = nil
	arg_8_0.overriddenPlayerScalesTable = {}
	arg_8_0.hiddenActorIdSet = native.CIdSet()
	arg_8_0.randomSeed = arg_8_1.randomSeed

	local var_8_2 = native.CRefereeManager()

	var_8_2:setupFromConvantData(arg_8_1.engine)

	var_8_0.npcManager = var_8_2
	var_8_0.cutsceneState = {
		isActive = false,
		isPlaying = false
	}
	arg_8_0.playbackEventManager = cutscene_playbackevents.CutscenePlaybackEvents(arg_8_0)
	arg_8_0.cameoCameraTable = arg_8_0:loadCameoCameras(var_8_0, var_8_1)
	arg_8_0.onReload = _G.registerOnReload(function()
		arg_8_0.cameoCameraTable = arg_8_0:loadCameoCameras(var_8_0, var_8_1)
	end)
end)

function CutsceneListener.isStateLoaded(arg_10_0, arg_10_1)
	return arg_10_1.state >= CutsceneState_Loaded
end

function CutsceneListener.registerPlaybackEventListener(arg_11_0, arg_11_1, arg_11_2)
	arg_11_0.playbackEventManager:registerPlaybackEventListener(arg_11_1, arg_11_2)
end

function CutsceneListener.registerWithMatchSim(arg_12_0, arg_12_1)
	arg_12_1:registerSolidEventListener(function(...)
		arg_12_0:onCutscenePlay(...)
	end, "CutscenePlayEvent")
	arg_12_1:registerSolidEventListener(function(...)
		arg_12_0:onQueueReplayEvent(...)
	end, "QueueReplayEvent")
	arg_12_1:registerLocalTentativeEventListener(function(...)
		arg_12_0:onAdjustCutscenePlayRateEvent(...)
	end, "AdjustCutscenePlayRateEvent")
	arg_12_1:registerUpdateable(function(...)
		arg_12_0:update(...)
	end)
	arg_12_1:registerOnPreWipe(function(...)
		return arg_12_0:onPreWipe(...)
	end, true)
	arg_12_1:registerOnPostWipe(function(...)
		return arg_12_0:onPostWipe(...)
	end)
	arg_12_1:registerSolidEventListener(function(...)
		arg_12_0:onFinishedBodyCommand(...)
	end, "CutsceneFinishedBodyCommandEvent")
end

function CutsceneListener.loadCameoCameras(arg_20_0, arg_20_1, arg_20_2)
	return {}
end

function CutsceneListener.onFinishedBodyCommand(arg_21_0, arg_21_1, arg_21_2, arg_21_3, arg_21_4, arg_21_5, arg_21_6, arg_21_7, arg_21_8, arg_21_9)
	formatPrint("[CutsceneListener] Setting unloadPendingAnimsetsCounter to unload animsets")

	arg_21_0.unloadPendingAnimsetsCounter = 3
end

function CutsceneListener.onPreWipe(arg_22_0, arg_22_1, arg_22_2, arg_22_3, arg_22_4, arg_22_5, arg_22_6, arg_22_7, arg_22_8, arg_22_9, arg_22_10, arg_22_11)
	profile.push("CutsceneListener:onPreWipe()")
	formatPrint("[CutsceneListener] onPreWipe")
	arg_22_0:updatePendingUnload(nil, arg_22_0.scene, arg_22_4, true)
	arg_22_0:restoreCutsceneState(arg_22_9)
	arg_22_4.animsetLoader:unloadPending()
	profile.pop("CutsceneListener:onPreWipe()")
end

function CutsceneListener.forceClearQueue(arg_23_0, arg_23_1)
	local var_23_0 = true

	for iter_23_0, iter_23_1 in ipairs(arg_23_0.cutsceneQueue) do
		arg_23_0:unloadCutscene(iter_23_1, arg_23_0.scene, arg_23_1, var_23_0)
	end

	arg_23_0:updatePendingUnload(nil, arg_23_0.scene, arg_23_1, true)
	arg_23_0.cutsceneConfigLoader:clearCache()

	arg_23_0.cutsceneQueue = {}
	arg_23_0.conditionalCutsceneQueue = {}
	arg_23_0.pendingUnload = {}
	arg_23_0.currentCutscene = nil
	arg_23_0.lastRemoved = nil
end

function CutsceneListener.dispose(arg_24_0, arg_24_1, arg_24_2)
	arg_24_0:forceClearQueue(arg_24_2)
	arg_24_0.playbackEventManager:dispose()

	arg_24_0.playbackEventManager = nil
	arg_24_2.npcManager = nil

	arg_24_0:unloadCutsceneProps(arg_24_1.engine, arg_24_1.scene)
	arg_24_2.uiServices.universe.lightingModule:setLightingScene("default")
end

function CutsceneListener.getCutscenesToPlay(arg_25_0, arg_25_1, arg_25_2)
	local var_25_0 = {}
	local var_25_1 = arg_25_0.cutsceneConfigLoader:getCutsceneSequence(arg_25_1)

	if var_25_1 and var_25_1.cutscenes then
		for iter_25_0, iter_25_1 in ipairs(var_25_1.cutscenes) do
			local var_25_2 = arg_25_2:derive(iter_25_0)

			table.insert(var_25_0, {
				unresolvedCutsceneName = iter_25_1,
				cutsceneGuid = var_25_2
			})
		end
	else
		table.insert(var_25_0, {
			unresolvedCutsceneName = arg_25_1,
			cutsceneGuid = arg_25_2
		})
	end

	return var_25_0, var_25_1 and var_25_1.lightingScenes
end

function CutsceneListener.preloadCutsceneAssets(arg_26_0, arg_26_1, arg_26_2, arg_26_3, arg_26_4, arg_26_5, arg_26_6)
	local var_26_0 = arg_26_0.cutsceneConfigLoader
	local var_26_1 = var_26_0:getCutsceneSequence(arg_26_1)

	if var_26_1 and var_26_1.cutscenes then
		arg_26_1 = var_26_1.cutscenes[1]
	end

	local var_26_2 = true
	local var_26_3, var_26_4, var_26_5 = var_26_0:getCutsceneConfigWithKeywords(arg_26_1, arg_26_4, arg_26_2, var_26_2)

	ASSERT(var_26_3)
	ASSERT(var_26_5)

	local var_26_6

	if var_26_3.animsetName then
		arg_26_0:loadAnimset(var_26_3.animsetName, arg_26_5)

		var_26_6 = var_26_3.animsetName
	end

	local var_26_7

	if var_26_3.additionalAnimSets then
		var_26_7 = {}

		for iter_26_0, iter_26_1 in ipairs(var_26_3.additionalAnimSets) do
			arg_26_0:loadAnimset(iter_26_1, arg_26_5)
			table.insert(var_26_7, iter_26_1)
		end
	end

	local var_26_8

	if var_26_3.sequences then
		var_26_8 = {}

		for iter_26_2, iter_26_3 in pairs(var_26_3.sequences) do
			local var_26_9 = sequencerfactory.createSequence(iter_26_3.sequencer, arg_26_6)

			var_26_9:load(arg_26_3)

			var_26_9.propIndices = iter_26_3.propIndices
			var_26_8[iter_26_2] = var_26_9
		end
	end

	arg_26_0.preloadedAssets = {
		animsetName = var_26_6,
		additionalAnimSets = var_26_7,
		loadingSequences = var_26_8
	}
end

function CutsceneListener.updateLoadingPreloadedAssets(arg_27_0, arg_27_1)
	local var_27_0 = arg_27_0.preloadedAssets

	if not var_27_0 then
		return true
	end

	VERIFY(arg_27_1.animationProvider):update()

	local var_27_1 = var_27_0.animsetName
	local var_27_2 = var_27_0.additionalAnimSets

	if not arg_27_0:areAnimsetsLoaded(var_27_1, var_27_2) then
		return false
	end

	local var_27_3 = var_27_0.loadingSequences

	if var_27_3 then
		for iter_27_0, iter_27_1 in pairs(var_27_3) do
			if not iter_27_1:isLoaded() then
				return false
			end
		end
	end

	return true
end

function CutsceneListener.moveTheOwnershipOfPreloadedAssetsToCutscene(arg_28_0, arg_28_1, arg_28_2)
	local var_28_0 = VERIFY(arg_28_2.config)
	local var_28_1 = arg_28_1.animsetName
	local var_28_2 = arg_28_1.additionalAnimSets
	local var_28_3 = arg_28_1.loadingSequences

	ASSERT(var_28_1 == var_28_0.animsetName, "We preloaded a different animset")

	arg_28_2.animsetName = var_28_1

	if var_28_2 then
		ASSERT(var_28_0.additionalAnimSets, "We preloaded additional animsets that are't getting used")

		for iter_28_0, iter_28_1 in ipairs(var_28_2) do
			local var_28_4 = var_28_0.additionalAnimSets[iter_28_0]

			ASSERT(iter_28_1 == var_28_4, "We preloaded additional animsets that don't match the config's")
		end

		arg_28_2.additionalAnimSets = var_28_2
	end

	if var_28_3 then
		local var_28_5 = var_28_0.sequences

		for iter_28_2, iter_28_3 in pairs(var_28_3) do
			ASSERT(var_28_5[iter_28_2], "We preloaded sequences that aren't a part of this cutscene")
		end
	end

	arg_28_2.loadingSequences = var_28_3
end

function CutsceneListener.onCutscenePlay(arg_29_0, arg_29_1, arg_29_2, arg_29_3, arg_29_4, arg_29_5, arg_29_6, arg_29_7, arg_29_8, arg_29_9)
	local var_29_0 = VERIFY(arg_29_1.cutsceneName)

	if arg_29_1.clearPrevious then
		ASSERT(arg_29_0.isInCutsceneDebugger, "This is an editor only feature. Do not clearPrevious for gameplay purposes. Gracias")
		arg_29_0:forceClearQueue(arg_29_4)
	end

	local var_29_1 = cutscene_helper.getFinalCutsceneWaneTime(arg_29_6)
	local var_29_2, var_29_3 = arg_29_0:getCutscenesToPlay(var_29_0, arg_29_1.guid)
	local var_29_4 = #var_29_2

	arg_29_2.lightingScenes = var_29_3

	local var_29_5 = arg_29_0.cutsceneConfigLoader

	for iter_29_0, iter_29_1 in ipairs(var_29_2) do
		local var_29_6 = VERIFY(iter_29_1.unresolvedCutsceneName)
		local var_29_7 = VERIFY(iter_29_1.cutsceneGuid)
		local var_29_8 = tablex.clone(arg_29_1)

		var_29_8.waneTime = var_29_8.waneTime or var_29_1

		if iter_29_0 ~= 1 then
			var_29_8.onStarted = nil
		end

		if iter_29_0 ~= var_29_4 then
			var_29_8.onFinished = nil
			var_29_8.onFinishedState = nil
			var_29_8.waneTime = nil
		end

		local var_29_9 = true
		local var_29_10, var_29_11, var_29_12 = var_29_5:getCutsceneConfigWithKeywords(var_29_6, arg_29_6, arg_29_1.randomSeed, var_29_9)

		ASSERT(var_29_10)
		ASSERT(var_29_12)

		if var_29_10 and var_29_12 then
			arg_29_0:initAndQueueCutscene(var_29_12, var_29_10, var_29_7, var_29_8, arg_29_2, arg_29_3, arg_29_4, arg_29_5, arg_29_6, arg_29_7, arg_29_8, arg_29_9)
		end
	end

	var_29_5:clearCache()
	arg_29_0:updateServicesCutsceneState(arg_29_4, arg_29_7:getCutsceneEntity(), arg_29_9)
end

function CutsceneListener.initAndQueueCutscene(arg_30_0, arg_30_1, arg_30_2, arg_30_3, arg_30_4, arg_30_5, arg_30_6, arg_30_7, arg_30_8, arg_30_9, arg_30_10, arg_30_11, arg_30_12)
	ASSERT(#arg_30_4.targetIds > 0 or not arg_30_2.actors)

	local var_30_0 = {
		event = arg_30_4,
		name = arg_30_1,
		config = arg_30_2,
		state = CutsceneState_WaitingToLoad,
		id = VERIFY(arg_30_3)
	}

	if arg_30_5.lightingScenes then
		arg_30_0.loadedLightingScenes = arg_30_0.loadedLightingScenes or {}

		local var_30_1 = arg_30_7.uiServices.universe.lightingModule.currentLightingScene

		for iter_30_0, iter_30_1 in ipairs(arg_30_5.lightingScenes) do
			local var_30_2 = "intermediatelua.lighting." .. iter_30_1
			local var_30_3 = load(var_30_2)

			var_30_1:import(var_30_3.lighting2, "", iter_30_1, native.vec3.Zero(), native.vec3.Zero())

			arg_30_0.loadedLightingScenes[#arg_30_0.loadedLightingScenes + 1] = iter_30_1
		end
	end

	formatPrint("[CutsceneListener] Queueing cutscene %s for playback", arg_30_1)

	local var_30_4 = VERIFY(arg_30_7.skipStateProvider)

	cutscene_functions.createLoadingSkipMixin(var_30_0, var_30_4, var_0_3)
	cutscene_functions.createSkipMixin(var_30_0, arg_30_11, var_30_4)

	if arg_30_4.queueCondition ~= nil then
		table.insert(arg_30_0.conditionalCutsceneQueue, var_30_0)
	else
		arg_30_0:loadAndQueueCutscene(var_30_0, arg_30_7, arg_30_5, arg_30_9, arg_30_8, arg_30_12, arg_30_11, arg_30_10)
	end

	arg_30_0:updateServicesCutsceneState(arg_30_7, arg_30_10:getCutsceneEntity(), arg_30_12)
end

function CutsceneListener.loadAndQueueCutscene(arg_31_0, arg_31_1, arg_31_2, arg_31_3, arg_31_4, arg_31_5, arg_31_6, arg_31_7, arg_31_8)
	local var_31_0

	for iter_31_0, iter_31_1 in ipairs(arg_31_0.cutsceneQueue) do
		if iter_31_1.id == arg_31_1.id then
			var_31_0 = iter_31_1

			break
		end
	end

	if var_31_0 then
		formatPrintT("[CutsceneListener] Trying to insert a duplicate cutscene into the queue (name: %t, id: %t).", arg_31_1.name, arg_31_1.id)

		if ENABLE_ASSERT and not arg_31_0.isInCutsceneDebugger then
			ASSERT(false)
		end
	end

	arg_31_0:loadCutscene(arg_31_1, arg_31_2, arg_31_3.engine, arg_31_3.scene, arg_31_4)
	table.insert(arg_31_0.cutsceneQueue, arg_31_1)

	if VERIFY(arg_31_2.network):isMaster() then
		local var_31_1 = {
			id = arg_31_1.id,
			skipSequence = arg_31_1.event.skipSequence,
			skipRemaining = arg_31_1.event.skipRemaining and true or false,
			clearPrevious = arg_31_1.event.clearPrevious
		}

		arg_31_6:add(cutscenequeue_request.CutsceneEnqueueRequest(var_31_1))
	end
end

function CutsceneListener.concludeAndRemoveCutscene(arg_32_0, arg_32_1, arg_32_2, arg_32_3, arg_32_4, arg_32_5, arg_32_6, arg_32_7, arg_32_8, arg_32_9, arg_32_10)
	local var_32_0 = arg_32_1.state

	if var_32_0 == CutsceneState_Stopped then
		return
	end

	formatPrintT("[CutsceneListener] Concluding cutscene: %t.", arg_32_1.name)
	arg_32_0:stopCutscene(arg_32_1, arg_32_2, arg_32_4, arg_32_5, arg_32_6, arg_32_7, arg_32_8, arg_32_10)

	if var_32_0 == CutsceneState_Playback then
		if arg_32_9 and arg_32_1.event.onSkipped then
			arg_32_1.event.onSkipped()
		end

		arg_32_0:finaliseCutscene(arg_32_1, arg_32_3, arg_32_2, arg_32_4, arg_32_8, arg_32_6)
		var_0_7(arg_32_1, arg_32_0.cutsceneQueue)
		table.insert(arg_32_0.pendingUnload, arg_32_1)
	else
		arg_32_0:unloadCutscene(arg_32_1, arg_32_3.scene, arg_32_2)
		var_0_7(arg_32_1, arg_32_0.cutsceneQueue)
	end
end

function CutsceneListener.concludeTo(arg_33_0, arg_33_1, arg_33_2, arg_33_3, arg_33_4, arg_33_5, arg_33_6, arg_33_7, arg_33_8, arg_33_9, arg_33_10)
	ASSERT(arg_33_1)
	formatPrintT("[CutsceneListener] Concluding everything before and including: %t.", arg_33_1 and arg_33_1.name or nil)

	local var_33_0 = arg_33_0:findCutsceneIdxFromId(arg_33_1.id)

	ASSERT(var_33_0 >= 0)

	if var_33_0 > 0 then
		for iter_33_0 = var_33_0, 1, -1 do
			local var_33_1 = arg_33_0.cutsceneQueue[iter_33_0]

			arg_33_0:concludeAndRemoveCutscene(var_33_1, arg_33_2, arg_33_3, arg_33_4, arg_33_5, arg_33_6, arg_33_7, arg_33_8, arg_33_9, arg_33_10)
		end
	end
end

function CutsceneListener.updateFade(arg_34_0, arg_34_1, arg_34_2)
	local var_34_0 = arg_34_0.activeFade

	if var_34_0 then
		local var_34_1 = VERIFY(arg_34_1.engine)

		var_34_0:update(var_34_1, arg_34_2, 1)

		if var_34_0:isFinished() then
			var_34_0:exit()

			arg_34_0.activeFade = nil
		end
	end
end

function CutsceneListener.updateServicesCutsceneState(arg_35_0, arg_35_1, arg_35_2, arg_35_3)
	local var_35_0 = arg_35_1.cutsceneState.isPlaying

	arg_35_1.cutsceneState.isActive = arg_35_2:count() > 0 or #arg_35_0.cutsceneQueue > 0 or #arg_35_0.conditionalCutsceneQueue > 0
	arg_35_1.cutsceneState.isPlaying = arg_35_2:count() > 0
end

function CutsceneListener.checkAndQueueConditionalCutscenes(arg_36_0, arg_36_1, arg_36_2, arg_36_3, arg_36_4, arg_36_5, arg_36_6, arg_36_7, arg_36_8)
	for iter_36_0 = #arg_36_0.conditionalCutsceneQueue, 1, -1 do
		local var_36_0 = arg_36_0.conditionalCutsceneQueue[iter_36_0]
		local var_36_1 = var_36_0.event.queueCondition

		if var_36_1 then
			local var_36_2 = var_36_0.event.queueConditionParams

			if var_36_1(var_36_2) then
				formatPrintT("[CutsceneListener] Sending a request to enqueue cutscene [%t].", var_36_0.name)
				table.remove(arg_36_0.conditionalCutsceneQueue, iter_36_0)
				arg_36_0:loadAndQueueCutscene(var_36_0, arg_36_2, arg_36_3, arg_36_4, arg_36_5, arg_36_6, arg_36_7, arg_36_8)
			end
		end
	end
end

function CutsceneListener.restoreCutsceneState(arg_37_0, arg_37_1)
	for iter_37_0, iter_37_1 in pairs(arg_37_0.overriddenPlayerScalesTable) do
		local var_37_0 = arg_37_1:getGameObject(iter_37_0)

		VERIFY(var_37_0:getActorModel()).skeleton.scale = iter_37_1

		var_37_0:setScale(iter_37_1.x)
	end

	arg_37_0.overriddenPlayerScalesTable = {}

	for iter_37_2, iter_37_3 in arg_37_0.hiddenActorIdSet:iter() do
		local var_37_1 = arg_37_1:getGameObject(iter_37_3)

		if arg_37_1:isActive(iter_37_3) then
			VERIFY(var_37_1:getActorModel()).visible = true
		end
	end

	arg_37_0.hiddenActorIdSet:clear()
end

function CutsceneListener.resetJigglyJointEvents(arg_38_0, arg_38_1, arg_38_2, arg_38_3)
	if arg_38_2.jigglyJointCleanup and arg_38_2.jigglyJointCleanup == true then
		ASSERT(not PLATFORM_SWITCH)

		for iter_38_0, iter_38_1 in arg_38_2.cutsceneLayout:iterateActorOrigins() do
			local var_38_0 = iter_38_1.id
			local var_38_1 = arg_38_3:getGameObject(var_38_0)

			if var_38_1.identity.sex.isMale then
				var_38_1.teamVisualConfig:setOption("dynamic", 1)
				arg_38_1.ingameCharacterStreamingProcess:reloadId(var_38_0)
			end
		end

		arg_38_2.jigglyJointCleanup = nil
	end
end

function CutsceneListener.resetScene(arg_39_0, arg_39_1, arg_39_2, arg_39_3, arg_39_4)
	formatPrint("[CutsceneListener] resetScene for %s", arg_39_1.name)

	local var_39_0 = VERIFY(arg_39_3.network):isMaster()

	arg_39_0:resetJigglyJointEvents(arg_39_3, arg_39_1, arg_39_4)

	local var_39_1 = arg_39_3.uiServices:getUniverse()

	var_39_1:clearToneMapFilterOverride()

	var_39_1.trails.isInReplay = false

	if not GAME_RUGBY then
		var_39_1:setCameraMode(native.EUniverseCameraSelection.None)
	end

	local var_39_2 = arg_39_1.config.reparents

	if var_39_2 then
		local var_39_3 = VERIFY(arg_39_3.pools)

		for iter_39_0, iter_39_1 in pairs(var_39_2) do
			local var_39_4 = iter_39_1.actorName
			local var_39_5 = arg_39_1.cutsceneLayout.actorOrigins.asTable
			local var_39_6

			for iter_39_2, iter_39_3 in ipairs(var_39_5) do
				if iter_39_3.actorLabel == var_39_4 then
					var_39_6 = iter_39_3.id

					break
				end
			end

			ASSERT(var_39_6)
			var_39_3.skeletonModifierPool:get(var_39_6):clearActiveReparents()
		end
	end

	local var_39_7 = arg_39_1.hudTable
	local var_39_8 = arg_39_3.hud and arg_39_3.hud.featureStack

	if var_39_7 and var_39_8 then
		for iter_39_4, iter_39_5 in pairs(var_39_7) do
			var_39_8:pop(iter_39_5)
		end
	end

	if arg_39_1.particleStopEvents then
		arg_39_0:callStopParticleEvents(arg_39_2, arg_39_1)
	end

	local var_39_9 = arg_39_1.defaultGlobalShaderValues

	if var_39_9 then
		for iter_39_6, iter_39_7 in pairs(var_39_9) do
			native.setShaderGlobalFloat(iter_39_6, iter_39_7)
		end
	end

	if (arg_39_1.event.forceStop or arg_39_1.forceStop) and arg_39_1.event.onFinished then
		arg_39_1.event.onFinished()
	end

	if arg_39_1.event.stadiumPan or arg_39_1.config.stadiumPan then
		local var_39_10 = arg_39_3.cameraManager
		local var_39_11 = true

		arg_39_3.stadiumPan:endTransition(var_39_10, var_39_11)
	end

	local var_39_12 = var_39_1.lightingModule

	if arg_39_1.unloadLighting then
		for iter_39_8, iter_39_9 in ipairs(arg_39_1.unloadLighting) do
			var_39_12:unloadLightingScene(iter_39_9)
		end

		arg_39_1.unloadLighting = nil
	end

	if arg_39_1.masterLightingScenes then
		for iter_39_10, iter_39_11 in ipairs(arg_39_1.masterLightingScenes) do
			var_39_12:unloadLightingScene(iter_39_11)
		end

		arg_39_1.masterLightingScenes = nil
	end

	local var_39_13 = var_39_1.renderJobs:get()

	if var_39_13.assertNotRunningCullingAndSkinningJobs then
		var_39_13:assertNotRunningCullingAndSkinningJobs()
	end

	local var_39_14 = arg_39_2.engine

	var_39_12:reloadLightingScene(var_39_14)

	if arg_39_1.enabledLightGroups then
		for iter_39_12, iter_39_13 in pairs(arg_39_1.enabledLightGroups) do
			var_39_1.lightingModule.currentLightingScene:toggleGroup(iter_39_12, iter_39_13)
		end

		arg_39_1.enabledLightGroups = nil
	end
end

function CutsceneListener.finaliseCutscene(arg_40_0, arg_40_1, arg_40_2, arg_40_3, arg_40_4, arg_40_5, arg_40_6)
	ASSERT(arg_40_1.state == CutsceneState_Stopped)

	local var_40_0 = arg_40_2.engine
	local var_40_1 = VERIFY(arg_40_2.universe)

	arg_40_0.playbackEventManager:finaliseCutscene(arg_40_1, var_40_0, arg_40_3, var_40_1, arg_40_4, arg_40_6)
	arg_40_0:resetScene(arg_40_1, arg_40_2, arg_40_3, arg_40_5)
end

function CutsceneListener.onQueueReplayEvent(arg_41_0, arg_41_1, arg_41_2, arg_41_3, arg_41_4, arg_41_5, arg_41_6, arg_41_7, arg_41_8, arg_41_9)
	formatPrint("[CutsceneListener] onQueueReplayEvent")
	arg_41_0:updatePendingUnload(arg_41_0.currentCutscene, arg_41_0.scene, arg_41_4, true)
end

function CutsceneListener.updatePendingUnload(arg_42_0, arg_42_1, arg_42_2, arg_42_3, arg_42_4)
	ASSERT(arg_42_2)

	local var_42_0 = arg_42_0.pendingUnload

	if arg_42_4 or arg_42_1 ~= nil or arg_42_0.isInCutsceneDebugger then
		for iter_42_0 = #var_42_0, 1, -1 do
			local var_42_1 = var_42_0[iter_42_0]

			if var_42_1 ~= arg_42_1 then
				arg_42_0:unloadCutscene(var_42_1, arg_42_2, arg_42_3)
				table.remove(var_42_0, iter_42_0)
			end
		end
	end
end

function CutsceneListener.unloadAllPendingCutscenes(arg_43_0, arg_43_1)
	arg_43_0:updatePendingUnload(nil, arg_43_0.scene, arg_43_1, true)
end

function CutsceneListener.updateLoading(arg_44_0, arg_44_1, arg_44_2, arg_44_3, arg_44_4, arg_44_5, arg_44_6, arg_44_7, arg_44_8, arg_44_9)
	local var_44_0 = arg_44_0.cutsceneQueue
	local var_44_1 = var_0_5(var_44_0)

	if not var_44_1 then
		return
	end

	local var_44_2 = arg_44_7:getCutsceneEntity()
	local var_44_3 = var_44_2:loadedCount()
	local var_44_4 = var_0_4(var_44_0)

	if var_44_4 >= 2 then
		formatPrintT("[CutsceneListener] reach max loading count (local: %t) (entity: %t).", var_44_4, var_44_3)

		return
	end

	if var_44_2:find(var_44_1.id) < 0 then
		return
	end

	if arg_44_0:updateCutsceneLoading(var_44_1, arg_44_3, arg_44_4, arg_44_5, arg_44_6, arg_44_7, arg_44_8) then
		local var_44_5 = var_44_1.loadingSkipStateMixin

		if not var_44_5 or var_44_5:checkForSkip() then
			ASSERT(var_44_1.state == CutsceneState_LoadedButWaiting)
			formatPrintT("[CutsceneListener] Cutscene [%t] finished loading.", var_44_1.name)
			cutscene_functions.releaseLoadingSkipMixin(var_44_1)

			var_44_1.state = CutsceneState_Loaded

			if arg_44_1 then
				local var_44_6 = (var_44_1.animsetName and arg_44_0.loadedAnimsets[var_44_1.animsetName].animset) ~= nil
				-- injury-cutscene-variety: event.startOffset starts the cutscene that many seconds
				-- into its animations, by starting it that long ago. Actors and cameras both run
				-- from the start time, so they stay in sync.
				local var_44_start = arg_44_2
				local var_44_offset = var_44_1.event and var_44_1.event.startOffset

				if var_44_offset and var_44_offset > 0 and var_44_offset < (var_44_1.duration or 0) then
					local var_44_ok, var_44_backdated = pcall(function()
						if type(arg_44_2) == "number" then
							return arg_44_2 - var_44_offset
						end

						return arg_44_2 - native.Time.FromSeconds(var_44_offset)
					end)

					if var_44_ok and var_44_backdated then
						var_44_start = var_44_backdated
					end

					local var_44_hia = rawget(_G, "HIAState")

					if var_44_hia and var_44_hia.log then
						var_44_hia.log(string.format("cutscene %s: starting %.2f s in (%s), %.2f s long", tostring(var_44_1.name), var_44_offset, var_44_ok and "ok" or ("failed: " .. tostring(var_44_backdated)), (var_44_1.duration or 0) - (var_44_ok and var_44_offset or 0)))
					end
				end

				local var_44_7 = {
					id = var_44_1.id,
					time = var_44_start,
					hasAnimations = var_44_6,
					duration = native.Time.FromSeconds(var_44_1.duration),
					cutsceneLayout = VERIFY(var_44_1.cutsceneLayout),
					guid1 = arg_44_5:alloc(),
					guid2 = arg_44_5:alloc()
				}

				arg_44_9:add(cutscenequeue_request.CutsceneLoadedRequest(var_44_7))
			end
		end
	end

	if var_44_2:loadedCount() == 0 and var_44_1.event.hideActorsDuringLoad then
		local var_44_8 = var_0_2(arg_44_4, arg_44_8)

		cutscene_functions.hideActorIds(var_44_8, arg_44_0.hiddenActorIdSet, arg_44_8)
	end
end

local function var_0_8(arg_45_0, arg_45_1, arg_45_2, arg_45_3)
	local var_45_0 = 0

	for iter_45_0 = 0, arg_45_1:loadedCount() - 1 do
		local var_45_1 = arg_45_1:get(iter_45_0)

		ASSERT(var_45_1:isLoaded())

		local var_45_2 = var_45_1.data

		if arg_45_0 >= var_45_2.startTime + var_45_2.duration then
			var_45_0 = var_45_0 + 1
		else
			break
		end
	end

	if var_45_0 > 0 then
		formatPrintT("[CutsceneListener] Sending a request to dequeue %t cutscenes.", var_45_0)

		local var_45_3 = var_45_0 < arg_45_1:loadedCount()
		local var_45_4 = {
			time = arg_45_0,
			dequeueCount = var_45_0,
			shouldMakeActions = var_45_3,
			guid1 = var_45_3 and arg_45_2:alloc() or nil,
			guid2 = var_45_3 and arg_45_2:alloc() or nil
		}

		arg_45_3:add(cutscenequeue_request.CutsceneDequeueRequest(var_45_4))
	end

	if ENABLE_ASSERT and var_45_0 > 0 and var_45_0 == arg_45_1:loadedCount() and arg_45_1:count() > arg_45_1:loadedCount() then
		print("[CutsceneListener] WARN: We've removed the last cutscene from the queue, but there were still cutscenes loading.")
	end
end

function CutsceneListener.processChanges(arg_46_0, arg_46_1, arg_46_2, arg_46_3, arg_46_4, arg_46_5, arg_46_6, arg_46_7, arg_46_8, arg_46_9, arg_46_10, arg_46_11)
	local var_46_0 = false
	local var_46_1
	local var_46_2 = arg_46_1:getLastRemoved()

	if arg_46_0.currentCutscene ~= arg_46_2 then
		var_46_0 = true

		if arg_46_2 then
			local var_46_3 = arg_46_0:findCutsceneIdxFromId(arg_46_2.id)

			var_46_1 = arg_46_0.cutsceneQueue[var_46_3 - 1]
		else
			var_46_1 = arg_46_0.cutsceneQueue[#arg_46_0.cutsceneQueue]
		end

		if var_46_1 then
			arg_46_0.lastRemoved = var_46_1.id
		end
	elseif arg_46_0.lastRemoved ~= var_46_2 and arg_46_1:count() > 0 and arg_46_0.currentCutscene == arg_46_1:get(0) then
		var_46_1 = arg_46_0:findCutsceneFromId(var_46_2)

		if var_46_1 then
			var_46_0 = true
		end

		arg_46_0.lastRemoved = var_46_2
	end

	if var_46_0 then
		if var_46_1 then
			local var_46_4 = arg_46_1:getDequeueReason(arg_46_4) == native.EDequeueReason.Skip

			arg_46_0:concludeTo(var_46_1, arg_46_5, arg_46_6, arg_46_7, arg_46_8, arg_46_11, arg_46_9, arg_46_10, var_46_4, arg_46_3)
		end

		if arg_46_2 and arg_46_2.state == CutsceneState_Loaded then
			arg_46_0:updatePendingUnload(arg_46_2, arg_46_0.scene, arg_46_5, false)
			ASSERT(arg_46_2.state == CutsceneState_Loaded)

			arg_46_2.state = CutsceneState_Playback

			arg_46_0:setupSceneForCutscene(arg_46_2, arg_46_3, arg_46_6, arg_46_5, arg_46_7, arg_46_9, arg_46_10, arg_46_11)
		end

		arg_46_0.currentCutscene = arg_46_2
	end
end

function CutsceneListener.checkAndProcessSkip(arg_47_0, arg_47_1, arg_47_2, arg_47_3, arg_47_4, arg_47_5, arg_47_6, arg_47_7)
	ASSERT(arg_47_2)

	local var_47_0 = false
	local var_47_1 = arg_47_5:count() - arg_47_5:loadedCount()
	local var_47_2
	local var_47_3 = true

	if arg_47_3 then
		var_47_2 = (arg_47_2.event.skipSequence ~= nil or false) and arg_47_2.event.skipSequence == arg_47_3.event.skipSequence

		local var_47_4 = arg_47_2.event.skipSequence

		for iter_47_0, iter_47_1 in ipairs(arg_47_0.cutsceneQueue) do
			if var_47_4 ~= iter_47_1.event.skipSequence then
				var_47_3 = false

				break
			end

			var_47_4 = iter_47_1.event.skipSequence
		end
	end

	if ENABLE_ASSERT and (arg_47_2.skipMixin or arg_47_2.event.externalSkip) and arg_47_3 and var_47_2 and not var_47_3 then
		formatPrintT("[CutsceneListener] WARN: There may be an incorrect cutscene sequence.  [%t] has skip conditions, but the next cutscene ([%t]) is part of the\n\t\t\t\tsame sequence, and not all cutscenes in the queue are part of that sequence.", arg_47_2.name, arg_47_3.name)
	end

	if var_47_1 == 0 or arg_47_3 and (var_47_3 or not var_47_2) then
		var_47_0 = var_0_1(arg_47_2)
	end

	if arg_47_1 and not arg_47_2.skipped and var_47_0 then
		formatPrintT("[CutsceneListener] Firing skip request for cutscene: %t.", arg_47_2.name)

		arg_47_2.skipped = true

		local var_47_5 = {
			id = arg_47_2.id,
			time = arg_47_4,
			guid1 = arg_47_6:alloc(),
			guid2 = arg_47_6:alloc()
		}

		arg_47_7:add(cutscenequeue_request.CutsceneQueueSkipRequest(var_47_5))
	end
end

function CutsceneListener.update(arg_48_0, arg_48_1, arg_48_2, arg_48_3, arg_48_4, arg_48_5, arg_48_6, arg_48_7, arg_48_8, arg_48_9, arg_48_10, arg_48_11)
	profile.push("CutsceneListener:update()")

	local var_48_0 = VERIFY(arg_48_3.network):isMaster()
	local var_48_1 = arg_48_3.hooks
	local var_48_2 = var_48_1 and var_48_1:getHook("CutsceneDebuggerDebugHook")

	arg_48_0.isInCutsceneDebugger = var_48_2 and var_48_2.show or false

	if not arg_48_0.isInCutsceneDebugger then
		local var_48_3 = var_48_1 and var_48_1:getHook("ImGuiEditorDebugHook")

		arg_48_0.isInCutsceneDebugger = var_48_3 and var_48_3:isEditorEnabled("Cutscene Editor")
	end

	local var_48_4 = arg_48_9 + arg_48_8

	arg_48_0.time = var_48_4

	arg_48_0:checkAndQueueConditionalCutscenes(var_48_0, arg_48_3, arg_48_1, arg_48_5, arg_48_4, arg_48_10, arg_48_7, arg_48_6)
	arg_48_0:updateLoading(var_48_0, var_48_4, arg_48_1, arg_48_3, arg_48_4, arg_48_5, arg_48_6, arg_48_7, arg_48_10)

	local var_48_5 = arg_48_6:getCutsceneEntity()

	if var_48_0 then
		var_0_8(var_48_4, var_48_5, arg_48_4, arg_48_10)
	end

	for iter_48_0 = 0, var_48_5:count() - 1 do
		local var_48_6 = var_48_5:get(iter_48_0)

		if var_48_6:isLoaded() then
			local var_48_7 = arg_48_0:findCutsceneFromId(var_48_6.id)

			if var_48_7 then
				if var_48_7.startTime ~= var_48_6.data.startTime then
					formatPrintT("[CutsceneListener] Synchronizing cutscene [%t] start time to %t, frameEndTime is %t.", var_48_7.name, var_48_6.data.startTime, var_48_4)
				end

				var_48_7.startTime = var_48_6.data.startTime
				var_48_7.time = var_48_4
			end
		end
	end

	local var_48_8 = var_48_5:getCurrentlyPlaying(var_48_4)
	local var_48_9 = var_48_5:getNextPlaying(var_48_4)
	local var_48_10 = var_48_8 and arg_48_0:findCutsceneFromId(var_48_8.id) or nil
	local var_48_11 = var_48_9 and arg_48_0:findCutsceneFromId(var_48_9.id) or nil
	local var_48_12 = var_48_5:count() - var_48_5:loadedCount()

	if not var_48_8 and var_48_12 > 0 then
		formatPrintT("[CutsceneListener] WARN: We want to be playing a cutscene, but nothing is loaded, so we're doing nothing.  Bad user experience! (loadingCount: %t, frameEndTime: %t) ", var_48_12, var_48_4)
		profile.pop("CutsceneListener:update()")

		return
	end

	arg_48_0:processChanges(var_48_5, var_48_10, arg_48_9, var_48_4, arg_48_3, arg_48_1, arg_48_5, arg_48_4, arg_48_6, arg_48_7, arg_48_10)

	if var_48_10 then
		if var_48_10.event.hideLoadingScreen then
			var_48_10.event.hideLoadingScreen = false

			gameplay_loadingscreen_helper.hideLoadingScreen(arg_48_1.engine)
		end

		arg_48_0:checkAndProcessSkip(var_48_0, var_48_10, var_48_11, arg_48_9, var_48_5, arg_48_4, arg_48_10)
		arg_48_0:updatePlayback(var_48_10, arg_48_1, arg_48_2, arg_48_3, arg_48_4, arg_48_5, arg_48_6, arg_48_7, var_48_4, arg_48_8, arg_48_10)
	end

	arg_48_0:updatePendingUnload(var_48_10, arg_48_0.scene, arg_48_3)

	if arg_48_0.unloadPendingAnimsetsCounter then
		if arg_48_0.unloadPendingAnimsetsCounter == 0 then
			arg_48_0.unloadPendingAnimsetsCounter = nil

			formatPrint("[CutsceneListener] Finished unloadPendingAnimsetsCounter and now we unload animsets")
			arg_48_3.animsetLoader:unloadPending()
		elseif arg_48_1.universe.timeFactor ~= 0 then
			arg_48_0.unloadPendingAnimsetsCounter = arg_48_0.unloadPendingAnimsetsCounter - 1
		end
	end

	arg_48_0:updateFade(arg_48_1, arg_48_8)
	arg_48_0:updateServicesCutsceneState(arg_48_3, var_48_5, arg_48_10)
	profile.pop("CutsceneListener:update()")
end

function CutsceneListener.loadCutscene(arg_49_0, arg_49_1, arg_49_2, arg_49_3, arg_49_4, arg_49_5)
	ASSERT(arg_49_1.state == CutsceneState_WaitingToLoad)

	arg_49_1.state = CutsceneState_Loading

	local var_49_0 = arg_49_0.cutsceneQueue[#arg_49_0.cutsceneQueue]

	if var_49_0 then
		arg_49_1.prevCameraChange = var_49_0.event.onCameraChange
	end
end

local function var_0_9(arg_50_0, arg_50_1, arg_50_2)
	arg_50_1.primarySide = arg_50_0.event.primarySide or sidehelper.none

	if GAME_CRICKET then
		local var_50_0 = arg_50_2:getComponent("matchInProgressData")
		local var_50_1 = var_50_0.fieldingSide

		arg_50_1.battingSide, arg_50_1.fieldingSide = var_50_0.battingSide, var_50_1
	end
end

function CutsceneListener.initCutsceneLayout(arg_51_0, arg_51_1, arg_51_2, arg_51_3, arg_51_4, arg_51_5, arg_51_6)
	local var_51_0 = arg_51_1.config
	local var_51_1 = arg_51_1.event
	local var_51_2 = cutscene_helper.createCutsceneParams(var_51_0, var_51_1)

	arg_51_1.cutsceneParams = var_51_2

	local var_51_3 = VERIFY(arg_51_3.pools)
	local var_51_4 = native.CCutsceneLayout()

	formatPrintT("[CutsceneListener] Initialising cutscene layout for %t.", arg_51_1.name)
	var_0_9(arg_51_1, var_51_2, arg_51_4)

	local var_51_5 = cutscene_helper.constructRoleIdTable(arg_51_3, arg_51_4, arg_51_5, arg_51_6)
	local var_51_6 = {}
	local var_51_7 = var_51_1.targetIds
	local var_51_8 = cutscene_helper.getSortedHeightIndexTable(arg_51_6, var_51_7)
	local var_51_9 = arg_51_4:getComponent("matchInData")
	local var_51_10 = var_51_1.useActorFiltering or arg_51_1.event.useActorFiltering == nil
	local var_51_11 = arg_51_4:getHome()
	local var_51_12 = arg_51_4:getAway()
	local var_51_13 = tablex.merge(var_51_11.assetIdMap, var_51_12.assetIdMap)

	var_51_4:init(var_51_10, var_51_0, var_51_7, var_51_3, var_51_9, arg_51_5, arg_51_6, var_51_2, var_51_5, var_51_6, var_51_8, var_51_13)

	arg_51_1.cutsceneLayout = var_51_4
end

local function var_0_10(arg_52_0, arg_52_1, arg_52_2, arg_52_3)
	local var_52_0 = arg_52_1.loadLightingScenes
	local var_52_1 = arg_52_1.enableLightGroups
	local var_52_2 = arg_52_2.uiServices.universe
	local var_52_3 = var_52_2.lightingModule.currentLightingScene
	local var_52_4 = arg_52_0.config.worldPos
	local var_52_5 = 0
	local var_52_6

	var_52_6 = var_52_4 and native.vec3(var_52_4[1], var_52_5, var_52_4[2]) or native.vec3.Zero()

	local var_52_7 = native.vec3(0, arg_52_0.config.worldRot or 0, 0)

	if var_52_0 then
		var_52_2.lightingModule:loadLightingScene(var_52_0, arg_52_3, var_52_6, var_52_7)
	end

	if var_52_1 then
		arg_52_0.enabledLightGroups = {}

		for iter_52_0, iter_52_1 in ipairs(var_52_1) do
			local var_52_8 = true

			var_52_3:toggleGroup(iter_52_1, var_52_8)

			arg_52_0.enabledLightGroups[iter_52_1] = not var_52_8
		end
	end
end

function CutsceneListener.createAnimatedCamera(arg_53_0, arg_53_1, arg_53_2, arg_53_3, arg_53_4, arg_53_5, arg_53_6, arg_53_7, arg_53_8, arg_53_9)
	local var_53_0 = VERIFY(arg_53_1.config.cameras)
	local var_53_1 = arg_53_1.config.cuts and #arg_53_1.config.cuts > 1 and arg_53_1.config.checkCameraBoundary
	local var_53_2 = arg_53_1.config.excludeBoundaryCheck

	var_53_1 = var_53_1 and not var_53_2

	local var_53_3 = arg_53_1.config.cameraAndLightingYOffset
	local var_53_4 = {
		disableAO = true,
		ignoreObstructions = false,
		actors = arg_53_6,
		ambientOcclusionStage = arg_53_2.renderer.ambientOcclusionStage,
		cameras = var_53_0,
		cut = arg_53_4,
		checkLineOfSight = arg_53_1.config.enableLineOfSight,
		dofStage = arg_53_2.renderer.dofStage,
		lineOfSightCheckIdTable = arg_53_5,
		mirrorCamera = arg_53_1.event.mirrorCutsceneAnimations,
		checkOutsideBoundary = var_53_1,
		startTime = arg_53_9,
		referenceFrame = arg_53_8,
		randomSeed = arg_53_7:nextAsSeed(),
		yOffset = var_53_3
	}

	if arg_53_1.config.camerasUsePropAnims then
		var_53_4.cameraAnimationProvider = VERIFY(arg_53_1.props.animationProvider)
	end

	local var_53_5 = {}

	for iter_53_0, iter_53_1 in pairs(var_53_0) do
		local var_53_6 = iter_53_1.shaderGlobals

		if var_53_6 then
			for iter_53_2, iter_53_3 in pairs(var_53_6) do
				var_53_5[iter_53_2] = native.getShaderGlobalFloat(iter_53_2)
			end
		end
	end

	arg_53_1.defaultGlobalShaderValues = var_53_5

	local var_53_7 = arg_53_2.uiServices.universe

	local function var_53_8(arg_54_0, arg_54_1, arg_54_2, arg_54_3)
		if arg_54_2 ~= "cut" then
			if arg_53_0.activeFade then
				arg_53_0.activeFade:exit()

				arg_53_0.activeFade = nil
			end

			if not arg_53_0.activeFade then
				local var_54_0 = arg_54_3.uiServices.universe:getUniverseStateStack()

				arg_53_0.activeFade = nonbarrierwipe.NonBarrierWipe(var_54_0)

				arg_53_0.activeFade:enter()
			end
		end

		if arg_53_1.unloadLighting then
			for iter_54_0, iter_54_1 in ipairs(arg_53_1.unloadLighting) do
				var_53_7.lightingModule:unloadLightingScene(iter_54_1)
			end

			arg_53_1.unloadLighting = nil
		end

		if arg_53_1.enabledLightGroups then
			for iter_54_2, iter_54_3 in pairs(arg_53_1.enabledLightGroups) do
				var_53_7.lightingModule.currentLightingScene:toggleGroup(iter_54_2, iter_54_3)
			end

			arg_53_1.enabledLightGroups = nil
		end

		if arg_54_1.additiveLighting then
			var_0_10(arg_53_1, arg_54_1.additiveLighting, arg_54_3, arg_53_1.name)

			arg_53_1.unloadLighting = arg_54_1.additiveLighting.loadLightingScenes
		end

		if arg_53_1.prevCameraChange then
			arg_53_1.prevCameraChange(arg_54_0, arg_54_1, arg_54_2, arg_54_3)
		end

		if arg_54_0 and arg_54_0.breakCamera and not arg_54_1.breakCamera then
			local var_54_1 = arg_54_3.cameraManager
			local var_54_2 = true
			local var_54_3 = true

			arg_54_3.stadiumPan:endTransition(var_54_1, var_54_2, var_54_3)
		elseif arg_54_1.breakCamera then
			local var_54_4 = arg_54_3.cameraManager

			arg_54_3.stadiumPan:beginTransition(var_54_4, arg_54_3, arg_54_1.breakDuration)
		end

		if arg_54_1.shaderGlobals then
			for iter_54_4, iter_54_5 in pairs(arg_54_1.shaderGlobals) do
				native.setShaderGlobalFloat(iter_54_4, iter_54_5)
			end
		elseif arg_54_0 and arg_54_0.shaderGlobals then
			local var_54_5 = arg_53_0.currentCutscene

			if var_54_5 then
				local var_54_6 = VERIFY(var_54_5.defaultGlobalShaderValues)

				for iter_54_6, iter_54_7 in pairs(arg_54_0.shaderGlobals) do
					local var_54_7 = var_54_6[iter_54_6]

					native.setShaderGlobalFloat(iter_54_6, iter_54_7)
				end
			end
		end
	end

	local var_53_9 = arg_53_2.cameraManager

	return (animated_camera.AnimatedCamera(var_53_9, var_53_4, nil, nil, var_53_8, arg_53_2, arg_53_3))
end

function CutsceneListener.createCameoCamera(arg_55_0, arg_55_1, arg_55_2, arg_55_3, arg_55_4, arg_55_5, arg_55_6, arg_55_7)
	return
end

function searchForCameraWithName(arg_56_0, arg_56_1)
	local var_56_0 = #arg_56_0

	for iter_56_0 = 1, var_56_0 do
		local var_56_1 = arg_56_0[iter_56_0]

		if var_56_1.name == arg_56_1 then
			return var_56_1
		end
	end

	return nil
end

function CutsceneListener.createCameras(arg_57_0, arg_57_1, arg_57_2, arg_57_3, arg_57_4, arg_57_5, arg_57_6, arg_57_7, arg_57_8, arg_57_9)
	local var_57_0 = arg_57_1.cutsceneLayout
	local var_57_1 = {}

	for iter_57_0, iter_57_1 in var_57_0:iterateActorOrigins() do
		local var_57_2 = VERIFY(iter_57_1.id)
		local var_57_3 = VERIFY(iter_57_1.animName)
		local var_57_4 = iter_57_1.actorLabel

		table.insert(var_57_1, {
			label = var_57_4,
			id = var_57_2,
			animName = var_57_3
		})
	end

	local var_57_5 = var_0_2(arg_57_2, arg_57_5)

	for iter_57_2, iter_57_3 in ipairs(arg_57_1.event.targetIds) do
		tablex.remove(var_57_5, iter_57_3)
	end

	local var_57_6 = {}
	local var_57_7 = arg_57_1.config.cameras
	local var_57_8

	for iter_57_4, iter_57_5 in ipairs(arg_57_6) do
		local var_57_9 = iter_57_5.camera
		local var_57_10 = var_57_9 == "break"
		local var_57_11 = not var_57_10 and searchForCameraWithName(var_57_7, var_57_9) or nil

		ASSERT(var_57_10 or var_57_11)

		if var_57_11 and (var_57_11.cameoCameraName ~= nil or var_57_11.cameoSearchCriteria ~= nil) then
			if var_57_8 and #var_57_8 > 0 then
				local var_57_12 = arg_57_0:createAnimatedCamera(arg_57_1, arg_57_2, arg_57_5, var_57_8, var_57_5, var_57_1, arg_57_9, arg_57_8, arg_57_7)
				local var_57_13 = var_57_8[1].frame
				local var_57_14 = {
					isCameo = false,
					camera = var_57_12,
					startFrame = var_57_13
				}

				table.insert(var_57_6, var_57_14)

				var_57_8 = {}
			end

			local var_57_15 = arg_57_0:createCameoCamera(arg_57_1, arg_57_2, arg_57_3, arg_57_5, iter_57_5, var_57_1, var_57_11)
			local var_57_16 = iter_57_5.frame
			local var_57_17 = {
				isCameo = true,
				camera = var_57_15,
				startFrame = var_57_16
			}

			table.insert(var_57_6, var_57_17)
		else
			var_57_8 = var_57_8 or {}

			table.insert(var_57_8, iter_57_5)
		end
	end

	if var_57_8 and #var_57_8 > 0 then
		local var_57_18 = arg_57_0:createAnimatedCamera(arg_57_1, arg_57_2, arg_57_5, var_57_8, var_57_5, var_57_1, arg_57_9, arg_57_8, arg_57_7)
		local var_57_19 = var_57_8[1].frame
		local var_57_20 = {
			isCameo = false,
			camera = var_57_18,
			startFrame = var_57_19
		}

		table.insert(var_57_6, var_57_20)
	end

	return var_57_6
end

function CutsceneListener.startCamera(arg_58_0, arg_58_1, arg_58_2, arg_58_3, arg_58_4, arg_58_5, arg_58_6, arg_58_7, arg_58_8, arg_58_9)
	ASSERT(arg_58_9 == arg_58_1.startTime)

	local var_58_0 = arg_58_4.cameraManager
	local var_58_1 = arg_58_4.hud

	if var_58_1 then
		local var_58_2 = var_58_1:getElement("bigscreen")

		if var_58_2 then
			if not var_58_2.firstSetup then
				var_58_2.newInningsEvent = true
			end

			var_58_2:showScoreboard()

			arg_58_4.bigscreen.enableBackground = true
		end
	end

	local var_58_3 = VERIFY(arg_58_3.universe)
	local var_58_4 = arg_58_1.cutsceneLayout
	local var_58_5 = native.frame.fromFrame2(var_58_4.referenceOrigin)

	arg_58_1.cameras = arg_58_0:createCameras(arg_58_1, arg_58_4, arg_58_5, arg_58_6, arg_58_7, arg_58_2, arg_58_9, var_58_5, arg_58_8)
	arg_58_1.currentCameraIndex = 1

	local var_58_6 = arg_58_1.cameras[arg_58_1.currentCameraIndex].camera

	ASSERT(not var_58_6.stopped)
	var_58_0:pushCamera(var_58_6, var_58_6.name)
end

function CutsceneListener.updateCameras(arg_59_0, arg_59_1, arg_59_2)
	local var_59_0 = arg_59_1.currentCameraIndex

	if var_59_0 then
		local var_59_1 = arg_59_1.time * cutscene_helper.FPS
		local var_59_2 = arg_59_1.cameras
		local var_59_3 = var_59_2[var_59_0]

		for iter_59_0 = var_59_0 + 1, #var_59_2 do
			local var_59_4 = var_59_2[iter_59_0]

			if var_59_1 >= var_59_4.startFrame then
				local var_59_5 = arg_59_2.cameraManager
				local var_59_6 = var_59_4.camera
				local var_59_7 = var_59_3.camera

				var_59_5:scheduleRemoveCamera(var_59_7)

				if var_59_3.isCameo and var_59_4.isCameo then
					local var_59_8 = var_59_6.targetId == var_59_7.targetId

					if var_59_6.pos == var_59_7.pos or var_59_8 then
						local var_59_9 = var_59_7:getTrackingValues()

						var_59_6:setTrackingValues(var_59_9, var_59_6.targetId)

						var_59_6.dir = var_59_7.dir
					end
				end

				var_59_5:pushCamera(var_59_6)

				arg_59_1.currentCameraIndex = var_59_0 + 1
			end
		end
	end
end

function CutsceneListener.stopCamera(arg_60_0, arg_60_1, arg_60_2)
	local var_60_0 = arg_60_2.cameraManager
	local var_60_1 = arg_60_1.currentCameraIndex
	local var_60_2 = arg_60_1.cameras

	if not var_60_2 or not var_60_0 then
		return
	end

	local var_60_3 = var_60_2[var_60_1]
	local var_60_4 = var_60_3.camera

	var_60_4:stop()

	if arg_60_1.event.forceStop then
		var_60_0:removeCamera(var_60_4)
	else
		var_60_0:scheduleRemoveCamera(var_60_4)
	end

	for iter_60_0 = #var_60_2, 1, -1 do
		var_60_3[iter_60_0] = nil
	end

	if arg_60_1.resetRacquetsAfterCameraStops then
		local var_60_5 = arg_60_2:getMatchSim():getGameObjects()
		local var_60_6 = arg_60_2.pools.gearInfoPool

		for iter_60_1, iter_60_2 in var_60_5:objects(playertype.TypeId) do
			local var_60_7 = var_60_6:get(iter_60_1)

			var_60_7.isProp = false
			var_60_7.jointOffset = native.vec3.Zero()
		end
	end

	local var_60_8 = true

	if arg_60_2.stadiumPan then
		arg_60_2.stadiumPan:endTransition(var_60_0, var_60_8)
	end
end

local function var_0_11(arg_61_0, arg_61_1, arg_61_2, arg_61_3, arg_61_4, arg_61_5)
	local var_61_0 = arg_61_3:getBallEntity():getOwnerId(arg_61_4)

	if not var_61_0 then
		return
	end

	local var_61_1 = arg_61_2:getBallObject()
	local var_61_2 = arg_61_1:alloc()
	local var_61_3 = {
		onlineMultiplayer = false,
		disposalId = var_61_2,
		disposalTime = arg_61_4,
		disposalType = native.EDisposalType.Teleport,
		disposalSubType = native.EDisposalSubType.None
	}

	disposal_request.initDisposalInfoFromGameState(arg_61_0, var_61_3, var_61_1)

	var_61_3.ownerId = nil
	var_61_3.objectId = var_61_0
	var_61_3.initialVelocity = native.vec3.Zero()
	var_61_3.rollSpeed = 0
	var_61_3.localRollAxis = native.vec3.ZAxis()

	arg_61_5:add(disposal_request.DisposalRequest(var_61_3))
end

function CutsceneListener.changePlayingCutsceneCut(arg_62_0, arg_62_1, arg_62_2, arg_62_3, arg_62_4, arg_62_5)
	local var_62_0 = arg_62_3:getCutsceneEntity():getCurrentlyPlaying(arg_62_5)
	local var_62_1 = var_62_0 and arg_62_0:findCutsceneFromId(var_62_0.id) or nil

	if not var_62_1 then
		return false
	end

	local var_62_2 = var_62_1.validCutIndexes

	if var_62_2 and #var_62_2 <= 1 or not var_62_1.config.checkCameraBoundary then
		return false
	end

	local var_62_3 = var_62_1.chosenCutIndex

	tablex.remove(var_62_2, var_62_3)

	local var_62_4 = arg_62_1.cameraManager
	local var_62_5 = var_62_1.cameras[var_62_1.currentCameraIndex]
	local var_62_6 = var_62_5.camera.startTime
	local var_62_7 = var_62_5.camera.rng
	local var_62_8 = tablex.randomelement(var_62_2, var_62_7)

	var_62_4:scheduleRemoveCamera(var_62_5.camera)

	local var_62_9 = var_62_1.cutsceneLayout.referenceOrigin

	var_62_1.cameras = {}

	local var_62_10 = var_62_1.config.cuts[var_62_8]

	var_62_1.cameras = arg_62_0:createCameras(var_62_1, arg_62_1, arg_62_2, arg_62_3, arg_62_4, var_62_10, var_62_6, var_62_9, var_62_7)

	var_62_4:pushCamera(var_62_1.cameras[1].camera)

	var_62_1.chosenCutIndex = var_62_8
end

function CutsceneListener.setupSceneForCutscene(arg_63_0, arg_63_1, arg_63_2, arg_63_3, arg_63_4, arg_63_5, arg_63_6, arg_63_7, arg_63_8)
	formatPrintT("[CutsceneListener] Setting up scene for cutscene: %t.", arg_63_1.name)

	local var_63_0 = arg_63_1.cutsceneLayout
	local var_63_1 = VERIFY(arg_63_3.universe)
	local var_63_2 = VERIFY(arg_63_3.scene)
	local var_63_3 = VERIFY(arg_63_4.network)
	local var_63_4 = arg_63_4.guidManager
	local var_63_5 = arg_63_1.startTime

	ASSERT(var_63_5)

	if not var_63_5 then
		formatPrintT("[CutsceneListener] ERROR: Cutscene %t has no start time.", arg_63_1.name)

		return
	end

	if arg_63_1.event.stadiumPan or arg_63_1.config.stadiumPan then
		local var_63_6 = arg_63_4.cameraManager

		arg_63_4.stadiumPan:beginTransition(var_63_6, arg_63_4)
	end

	arg_63_0.playbackEventManager:onCutsceneStartPlayback(arg_63_1, arg_63_3.engine, arg_63_4, var_63_1, arg_63_5)

	if arg_63_1.event.onStartPlayback then
		arg_63_1.event.onStartPlayback(arg_63_2)
	end

	local var_63_7 = arg_63_1.config.lightingMode or "default"

	var_63_1.lightingModule:setLightingScene(var_63_7)

	if arg_63_1.config.lightingScenes then
		local var_63_8 = arg_63_4.uiServices.universe
		local var_63_9 = arg_63_1.config.worldPos
		local var_63_10 = 0
		local var_63_11

		var_63_11 = var_63_9 and native.vec3(var_63_9[1], var_63_10, var_63_9[2]) or native.vec3.Zero()

		local var_63_12 = native.vec3(0, arg_63_1.config.worldRot or 0, 0)

		var_63_8.lightingModule:loadLightingScene(arg_63_1.config.lightingScenes, arg_63_1.name, var_63_11, var_63_12)

		arg_63_1.masterLightingScenes = arg_63_1.config.lightingScenes
	end

	arg_63_1.props:startPlayback(var_63_5, arg_63_4.pools, var_63_2)

	local var_63_13 = arg_63_1.props:getTimeRemaining(var_63_5)

	ASSERT(var_63_13 <= arg_63_1.duration)

	local var_63_14 = false

	if arg_63_1.config.props then
		for iter_63_0, iter_63_1 in pairs(arg_63_1.config.props) do
			if iter_63_1.name == "ball" then
				var_63_14 = true

				break
			end
		end
	end

	local var_63_15 = arg_63_7:getBallObject():getVisual()

	if var_63_14 then
		var_63_15:setVisible(true)
	else
		arg_63_1.hiddenBall = true

		var_63_15:setVisible(false)
	end

	local var_63_16 = arg_63_1.event.activateActors
	local var_63_17 = {}
	local var_63_18 = arg_63_1.event.delayVisualReload
	local var_63_19 = {}

	for iter_63_2, iter_63_3 in var_63_0:iterateActorOrigins() do
		local var_63_20 = iter_63_3.id

		if var_63_16 and not arg_63_7:isActive(var_63_20) then
			table.insert(var_63_17, var_63_20)
			arg_63_7:activateGameObject(var_63_20)
			arg_63_7:getGameObject(var_63_20):setBehaviour("Idle", var_63_5)
		end

		if var_63_18 then
			arg_63_4.ingameCharacterStreamingProcess:reloadId(var_63_20)
		end

		if not arg_63_1.event.disableJigglyReset then
			local var_63_21 = arg_63_4.pools.skeletonModifierPool:get(var_63_20)

			var_63_21:setWantReinitialiseJigglySkinning()
			var_63_21:setWantJigglyJointsSettle()
		end

		local var_63_22 = VERIFY(iter_63_3.animName)
		local var_63_23 = iter_63_3.actorLabel

		table.insert(var_63_19, {
			label = var_63_23,
			id = var_63_20,
			animName = var_63_22
		})
	end

	arg_63_1.activatedActors = var_63_17

	if arg_63_1.config.cuts and #arg_63_1.config.cuts > 0 then
		local var_63_24 = native.Random.FromTimeValue(var_63_5)

		arg_63_1.validCutIndexes = {}

		local var_63_25

		if arg_63_1.event.cutIndex then
			var_63_25 = arg_63_1.event.cutIndex

			table.insert(arg_63_1.validCutIndexes, var_63_25)
		elseif arg_63_1.config.checkCameraBoundary then
			local var_63_26, var_63_27 = arg_63_0:getBoundaryValidCuts(arg_63_1, var_63_0, arg_63_2, arg_63_4, arg_63_7, var_63_19)

			arg_63_1.validCutIndexes = var_63_26

			if #var_63_26 == 0 then
				table.sort(var_63_27, function(arg_64_0, arg_64_1)
					return arg_64_0.cameraDistance < arg_64_1.cameraDistance
				end)

				var_63_25 = var_63_27[1].cutIndex
			else
				var_63_25 = tablex.randomelement(var_63_26, var_63_24)
			end
		else
			var_63_25 = var_63_24:randomIntegerRange(1, #arg_63_1.config.cuts)
		end

		arg_63_1.chosenCutIndex = var_63_25

		local var_63_28 = arg_63_1.config.cuts[var_63_25]

		if var_63_28[1].frame == 0 then
			arg_63_0:startCamera(arg_63_1, var_63_28, arg_63_3, arg_63_4, arg_63_5, arg_63_6, arg_63_7, var_63_24, var_63_5)

			if not arg_63_4.loadingScreenHidden then
				gameplay_loadingscreen_helper.hideLoadingScreen(arg_63_3.engine)

				arg_63_4.loadingScreenHidden = true
			end
		else
			local var_63_29 = {
				frame = var_63_28[1].frame,
				callback = function(arg_65_0)
					arg_63_0:startCamera(arg_63_1, var_63_28, arg_63_3, arg_63_4, arg_63_5, arg_65_0, arg_63_7, var_63_24, var_63_5)

					if not arg_63_4.loadingScreenHidden then
						gameplay_loadingscreen_helper.hideLoadingScreen(arg_63_3.engine)

						arg_63_4.loadingScreenHidden = true
					end
				end
			}
			local var_63_30 = {}

			table.insert(var_63_30, var_63_29)

			arg_63_1.cameraStartEvent = var_63_30
		end
	end

	arg_63_0:restoreCutsceneState(arg_63_7)

	local var_63_31 = {}

	cutscene_functions.overridePlayerScales(arg_63_1, arg_63_7, var_63_31)

	arg_63_0.overriddenPlayerScalesTable = var_63_31

	local var_63_32

	if arg_63_1.event.hideIds then
		var_63_32 = tablex.iclone(arg_63_1.event.hideIds)

		for iter_63_4, iter_63_5 in var_63_0:iterateActorOrigins() do
			tablex.remove(var_63_32, iter_63_5.id)
		end
	end

	if var_63_32 and #var_63_32 > 0 then
		cutscene_functions.hideActorIds(var_63_32, arg_63_0.hiddenActorIdSet, arg_63_7)
	end

	arg_63_0.playbackEventManager:setupCutsceneEvents(arg_63_1)
	arg_63_0:setupParticleNodes(arg_63_3, arg_63_4, arg_63_1)

	arg_63_0.gameControlledPlayerInCutscene = false

	for iter_63_6, iter_63_7 in var_63_0:iterateActorOrigins() do
		local var_63_33 = iter_63_7.id
		local var_63_34 = arg_63_7:getGameObject(var_63_33, playertype.TypeId)

		if var_63_34 and var_63_34:getGamer() ~= nil then
			arg_63_0.gameControlledPlayerInCutscene = true

			break
		end
	end

	local var_63_35 = arg_63_1.config.reparents

	if var_63_35 then
		local var_63_36 = arg_63_4.pools

		for iter_63_8, iter_63_9 in pairs(var_63_35) do
			local var_63_37 = VERIFY(iter_63_9.childBone)
			local var_63_38 = VERIFY(iter_63_9.parentBone)
			local var_63_39 = iter_63_9.actorName
			local var_63_40 = arg_63_1.cutsceneLayout.actorOrigins.asTable
			local var_63_41

			for iter_63_10, iter_63_11 in ipairs(var_63_40) do
				if iter_63_11.actorLabel == var_63_39 then
					var_63_41 = iter_63_11.id

					break
				end
			end

			ASSERT(var_63_41)

			local var_63_42 = var_63_36.skeletonModifierPool:get(var_63_41)
			local var_63_43 = var_63_36.actorModelPool:get(var_63_41).skeleton
			local var_63_44 = VERIFY(var_63_43:findChild(var_63_37))
			local var_63_45 = VERIFY(var_63_43:findChild(var_63_38))

			var_63_42:setActiveReparent(var_63_44, var_63_45)
		end
	end

	if arg_63_1.event.hideBall then
		arg_63_0.ignoreBallDisposal = true

		arg_63_7:getBallObject().visual:setVisible(false)
	end

	local var_63_46 = arg_63_1.config.crowd

	if var_63_46 then
		local var_63_47 = arg_63_0.crowd.crowdScene
		local var_63_48 = var_63_46.startPercentage

		if var_63_48 then
			var_63_47:setCrowdPercentage(var_63_48)
		end

		local var_63_49 = var_63_46.cutsceneType

		if var_63_49 then
			var_63_47:setCurrentCutsceneType(var_63_49)
		end
	end

	if arg_63_1.config.overlay then
		arg_63_0:initOverlay(arg_63_3.engine, arg_63_4, arg_63_1.config.overlay)
	end

	if arg_63_1.animsetName ~= nil then
		local var_63_50 = arg_63_1.animsetName
		local var_63_51 = arg_63_1.additionalAnimSets
		local var_63_52 = arg_63_0:areAnimsetsLoaded(var_63_50, var_63_51)

		ASSERT(var_63_52)
	end

	local var_63_53 = arg_63_1.config.playerPosY or 0
	local var_63_54 = arg_63_1.cutsceneLayout.actorOrigins.asTable

	for iter_63_12, iter_63_13 in ipairs(var_63_54) do
		local var_63_55 = iter_63_13.id
		local var_63_56 = arg_63_7:getGameObject(var_63_55)
		local var_63_57 = var_63_56.pos
		local var_63_58 = var_63_56.facing

		var_63_56:resetPosition(var_63_57, var_63_58, var_63_5, var_63_53)
	end

	var_63_1.trails.isInReplay = true

	if not GAME_RUGBY then
		var_63_1:setCameraMode(native.EUniverseCameraSelection.None)
	end

	if arg_63_1.config.toneMapFilter then
		local var_63_59 = arg_63_1.config.toneMapFilter
		local var_63_60 = arg_63_1.config.toneMapSettings

		var_63_1:setToneMapFilterOverride(var_63_59, var_63_60)
	else
		var_63_1:clearToneMapFilterOverride()
	end

	if var_63_3:isMaster() then
		if not arg_63_1.config.onlyUseCamera and not arg_63_0.ignoreBallDisposal and not GAME_CRICKET then
			var_0_11(arg_63_4, var_63_4, arg_63_7, arg_63_6, var_63_5, arg_63_8)
		end

		arg_63_0.ignoreBallDisposal = false

		if arg_63_1.config.hideBall then
			local var_63_61 = arg_63_7:getBallObject():getVisual()

			arg_63_1.hiddenBall = true

			var_63_61:setVisible(false)
		end

		local var_63_62 = arg_63_1.event.playingRuleState

		if var_63_62 then
			if arg_63_1.event.activateObjects then
				var_63_62:activateObjects(arg_63_4, var_63_4, arg_63_5, arg_63_6, arg_63_7, var_63_5, arg_63_8)
			end

			arg_63_8:addRuleStateRequest(var_63_62, var_63_4:alloc())
		end
	end
end

function CutsceneListener.onPostWipe(arg_66_0, arg_66_1, arg_66_2, arg_66_3, arg_66_4, arg_66_5, arg_66_6, arg_66_7, arg_66_8, arg_66_9, arg_66_10, arg_66_11)
	return
end

function CutsceneListener.unloadCutsceneProps(arg_67_0, arg_67_1, arg_67_2)
	local var_67_0 = arg_67_0.cutscenePropsToUnload

	if var_67_0 and #var_67_0 > 0 then
		local var_67_1 = arg_67_1:getAnimationManager()

		for iter_67_0, iter_67_1 in ipairs(var_67_0) do
			iter_67_1:dispose(arg_67_2, var_67_1)
		end
	end

	arg_67_0.cutscenePropsToUnload = {}
end

function CutsceneListener.unloadCutscene(arg_68_0, arg_68_1, arg_68_2, arg_68_3, arg_68_4)
	profile.push("CutsceneListener:unloadCutscene()")
	formatPrint("[CutsceneListener] unloadCutscene %s", arg_68_1.name)

	local var_68_0 = arg_68_0.currentCutscene == nil
	local var_68_1 = VERIFY(arg_68_3.uiServices.universe)
	local var_68_2 = VERIFY(var_68_1:getGameObjects())

	if not arg_68_4 then
		ASSERT(arg_68_1.state == CutsceneState_Stopped)
	end

	local var_68_3 = arg_68_3.engine

	arg_68_0.crowd.crowdScene:setCurrentCutsceneType(native.ECrowdCutsceneType.None)
	cutscene_functions.releaseSkipMixins(arg_68_1)
	arg_68_0:stopCamera(arg_68_1, arg_68_3)
	arg_68_0:removeParticleNodes(var_68_3, arg_68_3, arg_68_1)

	local var_68_4 = arg_68_1.swappedVisuals

	if var_68_4 ~= nil and (not arg_68_1.event.disableVisualReset or var_68_0) then
		arg_68_0:resetVisuals(arg_68_3, var_68_4, arg_68_4, var_68_2)
	end

	local var_68_5 = arg_68_1.activatedActors

	if var_68_5 then
		for iter_68_0, iter_68_1 in ipairs(var_68_5) do
			var_68_2:deactivateGameObject(iter_68_1)
		end
	end

	if arg_68_1.config.playerPosY then
		local var_68_6 = arg_68_1.cutsceneLayout and arg_68_1.cutsceneLayout.actorOrigins and arg_68_1.cutsceneLayout.actorOrigins.asTable or {}
		local var_68_7 = var_68_1:getSimTime()

		for iter_68_2, iter_68_3 in ipairs(var_68_6) do
			local var_68_8 = iter_68_3.id
			local var_68_9 = var_68_2:getGameObject(var_68_8)
			local var_68_10 = var_68_9.pos
			local var_68_11 = var_68_9.facing

			var_68_9:resetPosition(var_68_10, var_68_11, var_68_7, 0)
		end
	end

	if arg_68_1.sequencedScenes then
		for iter_68_4, iter_68_5 in pairs(arg_68_1.sequencedScenes) do
			iter_68_5:dispose(var_68_3, arg_68_3)
		end
	end

	arg_68_1.sequencedScenes = nil

	if arg_68_1.loadingSequences then
		for iter_68_6, iter_68_7 in pairs(arg_68_1.loadingSequences) do
			iter_68_7:unload()
		end
	end

	arg_68_1.loadingSequences = nil

	if arg_68_1.props then
		local var_68_12 = VERIFY(var_68_3:getAnimationManager())

		arg_68_1.props:dispose(arg_68_2, var_68_12)

		arg_68_1.props = nil
	end

	local var_68_13 = arg_68_1.animsetName

	if var_68_13 then
		arg_68_0:unloadAnimset(var_68_13, arg_68_3)

		arg_68_1.animsetName = nil
	end

	local var_68_14 = arg_68_1.additionalAnimSets

	if var_68_14 then
		for iter_68_8, iter_68_9 in ipairs(var_68_14) do
			arg_68_0:unloadAnimset(iter_68_9, arg_68_3)
		end

		arg_68_1.additionalAnimSets = nil
	end

	if arg_68_1.hiddenBall and not arg_68_4 then
		arg_68_3.uiServices.universe:getGameObjects():getBallObject():getVisual():setVisible(true)
	end

	var_68_1:unloadCutsceneProps()

	if arg_68_1.texturesLoaded then
		for iter_68_10, iter_68_11 in ipairs(arg_68_1.texturesLoaded) do
			iter_68_11:unload()
		end

		arg_68_1.texturesLoaded = nil
	end

	profile.pop("CutsceneListener:unloadCutscene()")
end

local function var_0_12(arg_69_0, arg_69_1, arg_69_2)
	local var_69_0 = arg_69_2.matName
	local var_69_1 = arg_69_2.texturePath
	local var_69_2 = arg_69_0:getTextureManager():load(var_69_1)

	if not arg_69_1.texturesLoaded then
		arg_69_1.texturesLoaded = {}
	end

	table.insert(arg_69_1.texturesLoaded, var_69_2)

	local function var_69_3(arg_70_0)
		arg_70_0:setShaderValues(function(arg_71_0, arg_71_1)
			if var_69_0 == arg_71_1 then
				arg_71_0:setTexture("col_map", var_69_2)
			end
		end)
	end

	arg_69_1.props:forEachModel(var_69_3)
end

function CutsceneListener.loadAnimset(arg_72_0, arg_72_1, arg_72_2)
	local var_72_0 = "animations/" .. arg_72_1 .. ".animset"

	print("[CutsceneListener] Requested load animset " .. var_72_0)

	local var_72_1 = true
	local var_72_2 = VERIFY(arg_72_2.animsetLoader)
	local var_72_3 = VERIFY(arg_72_2.motionSet)

	arg_72_0.loadedAnimsets[arg_72_1] = arg_72_0.loadedAnimsets[arg_72_1] or {
		count = 0
	}
	arg_72_0.loadedAnimsets[arg_72_1].count = arg_72_0.loadedAnimsets[arg_72_1].count + 1

	local var_72_4 = arg_72_0.loadedAnimsets[arg_72_1].animset or var_72_2:load(var_72_0, var_72_1, var_72_3)

	arg_72_0.loadedAnimsets[arg_72_1].animset = var_72_4
end

function CutsceneListener.unloadAnimset(arg_73_0, arg_73_1, arg_73_2)
	local var_73_0 = "animations/" .. arg_73_1 .. ".animset"

	print("[CutsceneListener] Requested unload animset " .. var_73_0)

	local var_73_1 = VERIFY(arg_73_2.animsetLoader)

	ASSERT(arg_73_0.loadedAnimsets[arg_73_1], "Tried to unload an animset that hasn't been loaded yet")

	arg_73_0.loadedAnimsets[arg_73_1].count = arg_73_0.loadedAnimsets[arg_73_1].count - 1

	if arg_73_0.loadedAnimsets[arg_73_1].count == 0 then
		local var_73_2 = arg_73_0.loadedAnimsets[arg_73_1].animset

		var_73_1:unload(var_73_2)

		arg_73_0.loadedAnimsets[arg_73_1] = nil
	end
end

function CutsceneListener.areAnimsetsLoaded(arg_74_0, arg_74_1, arg_74_2)
	local var_74_0 = arg_74_0.loadedAnimsets

	if arg_74_1 then
		local var_74_1 = var_74_0[arg_74_1].animset

		if not var_74_1 then
			return false
		end

		if not var_74_1:isLoaded() or not var_74_1:isRegistered() then
			return false
		end
	end

	if arg_74_2 then
		for iter_74_0, iter_74_1 in ipairs(arg_74_2) do
			local var_74_2 = VERIFY(var_74_0[iter_74_1].animset)

			if not var_74_2:isLoaded() or not var_74_2:isRegistered() then
				return false
			end
		end
	end

	return true
end

function CutsceneListener.updateCutsceneLoading(arg_75_0, arg_75_1, arg_75_2, arg_75_3, arg_75_4, arg_75_5, arg_75_6, arg_75_7)
	if arg_75_1.state > CutsceneState_Loading then
		return true
	end

	local var_75_0 = arg_75_3.pools
	local var_75_1 = arg_75_1.config
	local var_75_2 = arg_75_2.engine
	local var_75_3 = arg_75_2.universe.scene

	if arg_75_0.preloadedAssets then
		if not arg_75_0:updateLoadingPreloadedAssets(arg_75_3) then
			return false
		end

		arg_75_0:moveTheOwnershipOfPreloadedAssetsToCutscene(arg_75_0.preloadedAssets, arg_75_1)

		arg_75_0.preloadedAssets = nil
	end

	if var_75_1.animsetName and not arg_75_1.animsetName then
		arg_75_0:loadAnimset(var_75_1.animsetName, arg_75_3)

		arg_75_1.animsetName = var_75_1.animsetName
	end

	local var_75_4 = var_75_1.additionalAnimSets

	if var_75_4 and not arg_75_1.additionalAnimSets then
		local var_75_5 = {}

		for iter_75_0, iter_75_1 in ipairs(var_75_4) do
			arg_75_0:loadAnimset(iter_75_1, arg_75_3)
			table.insert(var_75_5, iter_75_1)
		end

		arg_75_1.additionalAnimSets = var_75_5
	end

	arg_75_1.event.homeTeam = arg_75_5:getHome()
	arg_75_1.event.awayTeam = arg_75_5:getAway()

	if var_75_1.sequences and not arg_75_1.loadingSequences then
		arg_75_1.loadingSequences = {}

		for iter_75_2, iter_75_3 in pairs(var_75_1.sequences) do
			local var_75_6 = sequencerfactory.createSequence(iter_75_3.sequencer, var_75_3)

			var_75_6:load(var_75_2)

			var_75_6.propIndices = iter_75_3.propIndices
			arg_75_1.loadingSequences[iter_75_2] = var_75_6
		end
	end

	VERIFY(arg_75_3.animationProvider):update()

	local var_75_7 = arg_75_1.animsetName
	local var_75_8 = arg_75_1.additionalAnimSets
	local var_75_9 = arg_75_0:areAnimsetsLoaded(var_75_7, var_75_8)

	if not var_75_9 then
		formatPrintT("[CutsceneListener] Waiting for animsets to load for cutscene: %s", arg_75_1.name)
	end

	if not var_75_9 then
		return false
	end

	for iter_75_4, iter_75_5 in ipairs(arg_75_1.event.targetIds) do
		if not arg_75_7:getGameObject(iter_75_5):getActorModel().cricketVisual:isLoaded() then
			formatPrintT("[CutsceneListener] Waiting for character visual to load for actor %s in cutscene: %s", tostring(iter_75_5), arg_75_1.name)

			return false
		end
	end

	if arg_75_1.loadingSequences then
		for iter_75_6, iter_75_7 in pairs(arg_75_1.loadingSequences) do
			if not iter_75_7:isLoaded() then
				formatPrintT("[CutsceneListener] Waiting for sequence \"%s\" to load for cutscene: %s", iter_75_6, arg_75_1.name)

				return false
			end
		end
	end

	if not arg_75_1.cutsceneLayout and not arg_75_1.props then
		arg_75_0:initCutsceneLayout(arg_75_1, arg_75_2, arg_75_3, arg_75_5, arg_75_6, arg_75_7)
		arg_75_1.cutsceneLayout:setActionBaseGuid(arg_75_4:alloc())

		local var_75_10 = native.CCutsceneProps()
		local var_75_11 = VERIFY(var_75_2:getAssetManager())
		local var_75_12 = VERIFY(arg_75_2.scene)
		local var_75_13 = VERIFY(var_75_2:getAnimationManager())

		if var_75_1.props then
			local var_75_14 = {}

			for iter_75_8, iter_75_9 in pairs(var_75_1.props) do
				local var_75_15 = cutscene_props.getPropPath(arg_75_3, arg_75_6, arg_75_5, iter_75_9.name or iter_75_9.propName)

				if var_75_15 ~= nil then
					local var_75_16 = {}

					for iter_75_10, iter_75_11 in pairs(iter_75_9) do
						if iter_75_10 ~= "propName" and iter_75_10 ~= "name" then
							var_75_16[iter_75_10] = iter_75_11
						end
					end

					var_75_16.name = var_75_15

					table.insert(var_75_14, var_75_16)
				end
			end

			var_75_10:init(arg_75_1.cutsceneLayout, var_75_14, var_75_0, arg_75_6, arg_75_7, var_75_11, var_75_12, var_75_13, var_75_1.propAnimsetName or "")

			for iter_75_12, iter_75_13 in ipairs(var_75_14) do
				iter_75_13.propName = nil
			end
		end

		arg_75_1.props = var_75_10
	end

	if not arg_75_1.props:isLoaded() then
		formatPrintT("[CutsceneListener] Waiting for props to load for cutscene: %s", arg_75_1.name)

		return false
	end

	if not arg_75_1.hasRebakedSpec then
		arg_75_3.renderer:rebakeSpec()

		arg_75_1.hasRebakedSpec = true
	end

	local var_75_17 = arg_75_2.universe.ballLoadContext

	if arg_75_1.config.textureOverride then
		var_0_12(var_75_2, arg_75_1, arg_75_1.config.textureOverride)
	end

	local var_75_18, var_75_19 = arg_75_1.cutsceneLayout:getBounds(var_75_0.playerAnimationPool, arg_75_1.props)

	if arg_75_1.event.constrainBounds then
		local var_75_20 = native.vec2.maxPerElem(var_75_18, arg_75_1.event.constrainBounds.min)
		local var_75_21 = native.vec2.minPerElem(var_75_19, arg_75_1.event.constrainBounds.max)
		local var_75_22 = var_75_20 - var_75_18 + (var_75_21 - var_75_19)

		arg_75_1.cutsceneLayout:translateBy(var_75_22)

		local var_75_23 = arg_75_1.event.goalPostBounds

		if var_75_23 then
			local var_75_24, var_75_25 = arg_75_1.cutsceneLayout:getBounds(var_75_0.playerAnimationPool, arg_75_1.props)
			local var_75_26 = native.CRectangle(var_75_24, var_75_25)

			if var_75_23:overlapsRect(var_75_26) then
				local var_75_27 = cutscene_helper.getRectDepenetrationDelta(var_75_23, var_75_26)

				arg_75_1.cutsceneLayout:translateBy(var_75_27)
			end
		end
	end

	local var_75_28 = arg_75_1.config.actors

	if var_75_28 then
		local var_75_29 = arg_75_1.cutsceneLayout.actorOrigins.asTable
		local var_75_30 = {}

		for iter_75_14, iter_75_15 in ipairs(var_75_28) do
			local var_75_31 = var_75_29[iter_75_14]

			if var_75_31 then
				local var_75_32 = var_75_31.id
				local var_75_33 = arg_75_1.event.ignoreCutsceneVisuals

				if (iter_75_15.playerVisual or iter_75_15.teamVisual or iter_75_15.gearId or iter_75_15.playerVisualOptions or iter_75_15.teamVisualOptions) and var_75_29[iter_75_14] and not var_75_33 then
					local var_75_34 = {
						side = arg_75_1.event.side
					}
					local var_75_35 = arg_75_1.event.delayVisualReload
					local var_75_36 = cutscene_helper.swapVisual(arg_75_3.npcManager, arg_75_3, arg_75_6, arg_75_5, arg_75_7, var_75_32, iter_75_15.playerVisual, iter_75_15.teamVisual, iter_75_15.playerVisualOptions, iter_75_15.teamVisualOptions, var_75_34, var_75_35)
					local var_75_37 = var_0_6(arg_75_0.cutsceneQueue)

					ASSERT(var_75_37 ~= arg_75_1)

					if var_75_37 and var_75_37.swappedVisuals and #var_75_37.swappedVisuals > 0 then
						for iter_75_16, iter_75_17 in ipairs(var_75_37.swappedVisuals) do
							if var_75_32 == iter_75_17.id then
								var_75_36 = iter_75_17

								break
							end
						end
					end

					table.insert(var_75_30, var_75_36)
				end
			end
		end

		if #var_75_30 > 0 then
			arg_75_1.swappedVisuals = var_75_30
		end
	end

	local var_75_38 = 0

	for iter_75_18, iter_75_19 in arg_75_1.cutsceneLayout:iterateActorOrigins() do
		local var_75_39 = iter_75_19.id
		local var_75_40 = VERIFY(iter_75_19.weightedAnimations.duration)

		var_75_38 = math.max(var_75_38, var_75_40)
	end

	if arg_75_1.event.waneTime then
		local var_75_41 = arg_75_1.event.waneTime

		arg_75_1.waneTime = var_75_41
		var_75_38 = var_75_38 - var_75_41
	end

	arg_75_1.duration = var_75_38

	if arg_75_1.loadingSequences then
		arg_75_1.sequencedScenes = {}

		for iter_75_20, iter_75_21 in pairs(arg_75_1.loadingSequences) do
			ASSERT(iter_75_21:isLoaded())

			local var_75_42 = {}

			if iter_75_21.propIndices then
				for iter_75_22, iter_75_23 in ipairs(iter_75_21.propIndices) do
					local var_75_43 = arg_75_1.props:getPropModel(iter_75_23 - 1)

					ASSERT(var_75_43)
					table.insert(var_75_42, var_75_43)
				end
			end

			local var_75_44 = arg_75_1.config.worldPos
			local var_75_45 = arg_75_1.config.worldRot
			local var_75_46 = 0
			local var_75_47 = {
				translation = var_75_44 and native.vec3(var_75_44[1], var_75_46, var_75_44[2]) or native.vec3.Zero(),
				rotation = var_75_45 and native.quat.fromEulerDeg(0, var_75_45, 0) or native.quat.Identity()
			}
			local var_75_48 = arg_75_2.universe.lightingModule.dynamicEnvironment

			arg_75_1.sequencedScenes[iter_75_20] = sequencedscene.SequencedScene(arg_75_2.engine, var_75_42, arg_75_3.renderer, var_75_48, arg_75_3.cameraManager, iter_75_20, nil, iter_75_21, var_75_47)
		end

		arg_75_1.loadingSequences = nil
	end

	arg_75_1.state = CutsceneState_LoadedButWaiting

	return true
end

function CutsceneListener.clearConditionalCutscenes(arg_76_0)
	arg_76_0.conditionalCutsceneQueue = {}
end

local function var_0_13(arg_77_0, arg_77_1)
	local var_77_0 = arg_77_0.event.callbacks
	local var_77_1 = arg_77_0.startTime

	if not var_77_0 or not var_77_1 then
		return
	end

	local var_77_2 = arg_77_1 - var_77_1

	for iter_77_0 = #var_77_0, 1, -1 do
		local var_77_3 = var_77_0[iter_77_0]

		if var_77_2 >= var_77_3.time then
			var_77_3.func()
			table.remove(var_77_0, iter_77_0)
		end
	end
end

local function var_0_14(arg_78_0, arg_78_1, arg_78_2)
	local var_78_0 = (arg_78_2 - arg_78_0.startTime) * FPS

	arg_78_0.props:update(arg_78_2, arg_78_1, var_78_0)
end

function CutsceneListener.updatePlayback(arg_79_0, arg_79_1, arg_79_2, arg_79_3, arg_79_4, arg_79_5, arg_79_6, arg_79_7, arg_79_8, arg_79_9, arg_79_10, arg_79_11)
	ASSERT(arg_79_1)
	ASSERT(arg_79_1.state == CutsceneState_Playback)

	arg_79_1.time = arg_79_9 - arg_79_1.startTime

	var_0_13(arg_79_1, arg_79_9)

	local var_79_0 = arg_79_4.uiServices:getUniverse()

	arg_79_0.playbackEventManager:update(arg_79_1, arg_79_2.engine, arg_79_4, arg_79_6, var_79_0, arg_79_7, arg_79_11, arg_79_10)
	arg_79_0:updateCameras(arg_79_1, arg_79_4)

	local var_79_1
	local var_79_2 = false

	if arg_79_1.config.povCameraAllowed then
		local var_79_3 = arg_79_4.gamers
		local var_79_4 = arg_79_1.cutsceneLayout.actorOrigins.asTable[1].id

		var_79_1 = arg_79_8:getGameObject(var_79_4)

		local var_79_5 = var_79_3:getLocalGamersOnSide(var_79_1.side)

		for iter_79_0, iter_79_1 in ipairs(var_79_5) do
			if iter_79_1:getInputEvent("Cutscenes", "ShowFirstPerson") then
				var_79_2 = true

				break
			end
		end
	end

	if not GAME_RUGBY then
		if var_79_2 and var_79_1 ~= nil then
			var_79_0:setCameraMode(native.EUniverseCameraSelection.FirstPersonCamera)
			var_79_0:setFirstPersonCameraParameters(var_79_1, 0)
		else
			var_79_0:setCameraMode(native.EUniverseCameraSelection.None)
		end
	end

	if arg_79_1.sequencedScenes then
		local var_79_6 = var_79_0.lightingModule.currentLightingScene

		for iter_79_2, iter_79_3 in pairs(arg_79_1.sequencedScenes) do
			iter_79_3:update(arg_79_2.engine, arg_79_10, var_79_6)
		end
	end

	if arg_79_1.props then
		var_0_14(arg_79_1, arg_79_8, arg_79_9)
	end
end

function CutsceneListener.stopCutscene(arg_80_0, arg_80_1, arg_80_2, arg_80_3, arg_80_4, arg_80_5, arg_80_6, arg_80_7, arg_80_8)
	ASSERT(arg_80_1.state ~= CutsceneState_Stopped)

	arg_80_1.state = CutsceneState_Stopped

	if arg_80_0.isInCutsceneDebugger then
		return
	end

	if arg_80_1.event.onFinished then
		arg_80_1.event.onFinished()
	end

	if arg_80_1.cutsceneLayout then
		local var_80_0 = arg_80_1.cutsceneLayout.actorOrigins.asTable

		for iter_80_0, iter_80_1 in ipairs(var_80_0) do
			local var_80_1 = iter_80_1.id
			local var_80_2 = arg_80_7:getGameObject(var_80_1)
			local var_80_3 = var_80_2.pos
			local var_80_4 = var_80_2.facing

			var_80_2:resetPosition(var_80_3, var_80_4, arg_80_8, 0)
		end
	end

	if VERIFY(arg_80_2.network):isMaster() then
		local var_80_5 = arg_80_1.event.onFinishedState

		if var_80_5 and arg_80_5 then
			if var_80_5.activateObjects then
				var_80_5:activateObjects(arg_80_2, arg_80_4, arg_80_3, arg_80_6, arg_80_7, arg_80_0.time, arg_80_5)
			end

			arg_80_5:addRuleStateRequest(arg_80_1.event.onFinishedState, arg_80_4:alloc())
		end
	end
end

function CutsceneListener.resetVisuals(arg_81_0, arg_81_1, arg_81_2, arg_81_3, arg_81_4)
	if not arg_81_3 then
		local var_81_0 = true

		cutscene_helper.resetVisuals(arg_81_1, arg_81_2, var_81_0, arg_81_4)
	end
end

function CutsceneListener.callStopParticleEvents(arg_82_0, arg_82_1, arg_82_2)
	local var_82_0 = arg_82_1.engine:getParticleController()
	local var_82_1 = arg_82_2.particleStopEvents

	if var_82_1 then
		for iter_82_0, iter_82_1 in ipairs(var_82_1) do
			var_82_0:eventHandler(iter_82_1, native.Time.ZeroTime())
		end

		arg_82_2.particleStopEvents = nil
	end
end

function CutsceneListener.setupParticleNodes(arg_83_0, arg_83_1, arg_83_2, arg_83_3)
	local var_83_0 = arg_83_1.engine:getParticleController()
	local var_83_1 = {}

	local function var_83_2(arg_84_0, arg_84_1)
		if arg_84_1:len() ~= 0 then
			local var_84_0 = "rendering.particles.fx." .. arg_84_1
			local var_84_1 = loadTemp(var_84_0)

			ASSERT(var_84_1.events)

			local var_84_2 = var_83_0:getFXSystem():registerListenersForSkeleton(arg_84_0.skeleton, VERIFY(var_84_1.events))

			if var_84_2:count() > 0 then
				table.insert(var_83_1, var_84_2)
			end
		end
	end

	arg_83_3.props:forEachModel(var_83_2)

	arg_83_3.registeredFX = var_83_1
end

function CutsceneListener.removeParticleNodes(arg_85_0, arg_85_1, arg_85_2, arg_85_3)
	local var_85_0 = arg_85_3.registeredFX

	if var_85_0 and #var_85_0 > 0 then
		local var_85_1 = arg_85_1:getParticleController()

		for iter_85_0 = #var_85_0, 1, -1 do
			local var_85_2 = var_85_0[iter_85_0]

			var_85_1:getFXSystem():deregisterListeners(var_85_2)
		end
	end

	arg_85_3.registeredFX = nil
end

function CutsceneListener.initOverlay(arg_86_0, arg_86_1, arg_86_2, arg_86_3)
	arg_86_2.hud.elements.inGameOverlay:initOverlay(arg_86_1, arg_86_3)

	local var_86_0 = arg_86_2.hud and arg_86_2.hud.featureStack

	if var_86_0 then
		var_86_0:push("inGameOverlay")
	end
end

function CutsceneListener.onBeginStoryboardEvent(arg_87_0, arg_87_1, arg_87_2, arg_87_3, arg_87_4)
	local var_87_0 = arg_87_3.hud.elements.inGameOverlay
	local var_87_1 = arg_87_4.storyboardName
	local var_87_2 = arg_87_4.removeStoryboardName

	if var_87_2 then
		var_87_0:removeStoryboard(var_87_2)
	end

	if var_87_1 then
		var_87_0:beginStoryboard(var_87_1)
	end
end

function CutsceneListener.removeOverlay(arg_88_0, arg_88_1, arg_88_2)
	arg_88_2.hud.elements.inGameOverlay:clearView(arg_88_1)

	local var_88_0 = arg_88_2.hud and arg_88_2.hud.featureStack

	if var_88_0 then
		var_88_0:pop("inGameOverlay")
	end
end

function CutsceneListener.onAdjustCutscenePlayRateEvent(arg_89_0, arg_89_1, arg_89_2, arg_89_3, arg_89_4, arg_89_5, arg_89_6, arg_89_7, arg_89_8, arg_89_9)
	local var_89_0 = arg_89_1.playRate
	local var_89_1 = arg_89_1.transitionTime

	arg_89_0:adjustCutscenePlayRate(arg_89_4, var_89_0, var_89_1, arg_89_8)
end

function CutsceneListener.resetCutscenePlayRate(arg_90_0, arg_90_1, arg_90_2)
	local var_90_0 = 1
	local var_90_1 = 0.1

	arg_90_0:adjustCutscenePlayRate(arg_90_1, var_90_0, var_90_1, arg_90_2)
end

function CutsceneListener.adjustCutscenePlayRate(arg_91_0, arg_91_1, arg_91_2, arg_91_3, arg_91_4)
	return
end

function CutsceneListener.findCutsceneFromId(arg_92_0, arg_92_1)
	for iter_92_0, iter_92_1 in ipairs(arg_92_0.cutsceneQueue) do
		if iter_92_1.id == arg_92_1 then
			return iter_92_1
		end
	end

	return nil
end

function CutsceneListener.findCutsceneIdxFromId(arg_93_0, arg_93_1)
	for iter_93_0, iter_93_1 in ipairs(arg_93_0.cutsceneQueue) do
		if iter_93_1.id == arg_93_1 then
			return iter_93_0
		end
	end

	return nil
end

function CutsceneListener.hasCutscene(arg_94_0, arg_94_1)
	local var_94_0 = arg_94_0.cutsceneQueue

	for iter_94_0, iter_94_1 in ipairs(var_94_0) do
		if iter_94_1.id == arg_94_1 then
			return true
		end
	end

	return false
end

function CutsceneListener.getBoundaryValidCuts(arg_95_0, arg_95_1, arg_95_2, arg_95_3, arg_95_4, arg_95_5, arg_95_6)
	local var_95_0 = {}

	local function var_95_1(arg_96_0, arg_96_1)
		for iter_96_0, iter_96_1 in pairs(arg_96_0) do
			if iter_96_1.name and iter_96_1.name == arg_96_1 or iter_96_0 == arg_96_1 then
				return iter_96_0, iter_96_1
			end
		end

		ASSERT(false, "Camera " .. arg_96_1 .. " not found")
	end

	local function var_95_2(arg_97_0, arg_97_1)
		if not arg_97_1 then
			return
		end

		for iter_97_0, iter_97_1 in ipairs(arg_97_1) do
			ASSERT(iter_97_1.id)
			ASSERT(iter_97_1.label)

			if iter_97_1.label == arg_97_0 then
				return iter_97_1
			end
		end
	end

	local function var_95_3(arg_98_0, arg_98_1)
		local var_98_0 = arg_98_0.moveRelativeToActorLabel

		if not var_98_0 then
			return
		end

		local var_98_1 = var_95_2(var_98_0, arg_98_1)

		if var_98_1 then
			return var_98_1
		end

		ASSERT(false, "Camera referencing non-existant actor label " .. var_98_0)
	end

	local var_95_4 = native.frame.fromFrame2(arg_95_2.referenceOrigin)

	for iter_95_0, iter_95_1 in pairs(arg_95_1.config.cuts) do
		local var_95_5 = 999
		local var_95_6 = true
		local var_95_7 = -1

		for iter_95_2, iter_95_3 in pairs(iter_95_1) do
			local var_95_8 = arg_95_1.config.cameras
			local var_95_9, var_95_10 = var_95_1(var_95_8, iter_95_3.camera)

			var_95_7 = var_95_9

			ASSERT(var_95_10)

			local var_95_11 = VERIFY(var_95_10.animName)
			local var_95_12 = var_95_10.jointName or var_95_10.node

			ASSERT(var_95_12)

			local var_95_13 = var_95_3(var_95_10, arg_95_6)
			local var_95_14 = var_95_13 and var_95_13.id
			local var_95_15
			local var_95_16

			if var_95_14 then
				var_95_15 = arg_95_5:getGameObject(var_95_14)
				var_95_16 = var_95_15:getAnimationProvider()
			elseif arg_95_6 and #arg_95_6 > 0 then
				var_95_15 = arg_95_5:getGameObject(arg_95_6[1].id)
				var_95_16 = var_95_15:getAnimationProvider()
			end

			local var_95_17
			local var_95_18 = arg_95_1.props.animationProvider

			if var_95_18 then
				ASSERT(not var_95_13)

				var_95_17 = var_95_18:getAnimationByName(var_95_11)
			else
				var_95_17 = arg_95_4.cameoCameraAnimationProvider:getAnimationByName(var_95_11)

				if not var_95_17 and var_95_16 then
					var_95_17 = var_95_16:getAnimationByName(var_95_11)
				end
			end

			ASSERT(var_95_17, debugFormat("Animation '%s' could not be found by animated camera", var_95_11))

			local var_95_19 = 1
			local var_95_20 = var_95_17:getDuration()

			if var_95_19 < var_95_20 then
				var_95_19 = var_95_20
			end

			local var_95_21 = var_95_17:findRotationChannelId(var_95_12)
			local var_95_22 = var_95_17:findTranslationChannelId(var_95_12)
			local var_95_23 = var_95_17:findScaleChannelId(var_95_12)

			if var_95_21 == -1 or var_95_22 == -1 or var_95_23 == -1 then
				var_95_6 = false
			end

			if var_95_6 then
				local var_95_24
				local var_95_25 = var_95_17:evaluate(var_95_22, var_95_21, -1, var_95_19)

				if var_95_13 then
					local var_95_26 = var_95_15.getHandedness == nil or var_95_15:getHandedness() == "right"
					local var_95_27, var_95_28, var_95_29, var_95_30 = var_95_15:getMotionPath():query(arg_95_3, var_95_15:getMotionSet(), var_95_26)

					ASSERT(var_95_14)

					local var_95_31 = var_95_16:getAnimationByName(var_95_13.animName) or var_95_16:getAnimationByName(var_95_11)
					local var_95_32 = var_95_31:getOriginalWorldRootStartFrame()
					local var_95_33 = var_95_31:evaluateWorldRoot(var_95_19)
					local var_95_34 = var_95_32:transform(var_95_33)
					local var_95_35 = native.frame.fromFrame2(var_95_34):inverse():transform(var_95_25)

					var_95_35.t = var_95_35.t * var_95_15.scale

					local var_95_36 = arg_95_3 + var_95_19
					local var_95_37 = arg_95_4.pools.animationSequenceDataPool:get(var_95_14)
					local var_95_38 = var_95_37.valid and var_95_37:getWorldRootAtTime(var_95_15:getMotionSet(), var_95_15.scale, var_95_36)

					var_95_38 = var_95_38 or native.CFrame2(var_95_27, var_95_28)
					var_95_24 = native.frame.fromFrame2(var_95_38):transform(var_95_35)
				else
					var_95_24 = var_95_4:transform(var_95_25)
				end

				local var_95_39 = var_95_24.t:tovec2()
				local var_95_40 = 0
				local var_95_41 = var_0_0:outOfBounds(var_95_39, var_95_40)

				var_95_5 = var_0_0:closestBoundary(var_95_39, var_95_40)
				var_95_6 = not var_95_41
			end
		end

		table.insert(var_95_0, {
			cutIndex = iter_95_0,
			cameraIndex = var_95_7,
			cameraValid = var_95_6,
			cameraDistance = var_95_5
		})
	end

	local var_95_42 = {}

	for iter_95_4, iter_95_5 in pairs(var_95_0) do
		if iter_95_5.cameraValid then
			table.insert(var_95_42, iter_95_4)
		end
	end

	return var_95_42, var_95_0
end
