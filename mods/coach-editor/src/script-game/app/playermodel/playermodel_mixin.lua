import("core.camera.camerautil")
import("core.foundation.tablex")
import("app.academy.academy_helper")
import("app.frontend.frontend_playervisuals_helper")
import("app.playermodel.playermodel")
import("app.playermodel.playermodel_resources")
import("app.playermodel.playermodel_helper")
import("game.player.playergenerator")
import("game.gear.gearfactory")
import("script-config.design.playermodel.visualconfigsets_config")

local var_0_0 = "player model override camera"
local var_0_1 = 4
local var_0_2 = VERIFY(visualconfigsets_config.VisualConfigSets.PlayerDefault)

Class("PlayerModelMixin", function(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6)
	local var_1_0 = arg_1_3:getScene()
	local var_1_1 = arg_1_3:getRenderer()
	local var_1_2 = arg_1_3:getCameraManager()
	local var_1_3 = arg_1_1:getAssetMap()
	local var_1_4 = arg_1_1:getRenderInterface()

	if arg_1_6 then
		local var_1_5 = 1152000

		arg_1_0.thumbnailGpuFrameBuffer = native.CGpuFrameBuffer(var_1_4, var_1_5, 2, true, "fe_thumbnail")
	end

	arg_1_0.censorAllUGC = native.getCensorAllUGC()

	local var_1_6 = playermodel_resources.PlayerModelResources()

	var_1_6:create(arg_1_1, arg_1_2, var_1_0, var_1_1)

	arg_1_0.engine = arg_1_1
	arg_1_0.resources = var_1_6
	arg_1_0.assetMap = var_1_3
	arg_1_0.renderer = var_1_1
	arg_1_0.scene = var_1_0
	arg_1_0.cameraManager = var_1_2
	arg_1_0.playerData = arg_1_4
	arg_1_0.isFrontEnd = arg_1_6
	arg_1_0.onReload = _G.registerOnReload(function()
		arg_1_0.resources:reload()
		arg_1_5:get():waitForAll()
		arg_1_1:getHelperJointsLoader():reload(arg_1_1:getBlobManager())
		arg_1_1:getJigglyConfigBlobLoader():reload()

		local var_2_0 = load("design.characters.visualdatamap")

		arg_1_1:getDataConfigMap():reloadScripts(var_2_0)

		local var_2_1 = var_1_3:clone()

		var_1_3:reloadScripts(load("design.characters.assetmap"))
		var_1_3:appendTexSrcRules(var_2_0)

		for iter_2_0, iter_2_1 in ipairs(arg_1_0.playerModels) do
			iter_2_1:scriptsReloaded(var_2_1, var_1_3)
		end

		for iter_2_2, iter_2_3 in arg_1_0.playerManager.onDisc:iterateAll() do
			iter_2_3.visual:scriptsReloaded(var_2_1, var_1_3)
		end

		local var_2_2 = arg_1_0.playerManager.userCreated

		if var_2_2 then
			local var_2_3 = var_2_2.count

			for iter_2_4 = 0, var_2_3 - 1 do
				local var_2_4 = var_2_2:getAtIndex(iter_2_4)

				for iter_2_5, iter_2_6 in var_2_4.visualList:iter() do
					iter_2_6:scriptsReloaded(var_2_1, var_1_3)
				end

				for iter_2_7, iter_2_8 in var_2_4:getUniforms():iter() do
					iter_2_8.config:scriptsReloaded(var_2_1, var_1_3)
				end
			end
		end

		for iter_2_9, iter_2_10 in arg_1_0.clubManager.onDisc:iterateAll() do
			for iter_2_11 = 1, iter_2_10.uniformCount do
				iter_2_10:getUniform(iter_2_11).config:scriptsReloaded(var_2_1, var_1_3)
			end
		end

		local var_2_5 = arg_1_0.clubManager.userCreated

		if var_2_5 then
			local var_2_6 = var_2_5.count

			for iter_2_12 = 0, var_2_6 - 1 do
				local var_2_7 = var_2_5:getAtIndex(iter_2_12)

				for iter_2_13 = 1, var_2_7.uniformCount do
					var_2_7:getUniform(iter_2_13).config:scriptsReloaded(var_2_1, var_1_3)
				end
			end
		end
	end)
end)

function PlayerModelMixin.loadDefaultPlayer(arg_3_0, arg_3_1)
	local var_3_0
	local var_3_1
	local var_3_2
	local var_3_3
	local var_3_4

	academy_helper.setupFeaturedPlayerModel(arg_3_1, 1, true)

	local var_3_5 = arg_3_0.playerModels[1]
	local var_3_6, var_3_7 = var_3_5:getVisualConfig()
	local var_3_8 = var_3_5.clubIdentity
	local var_3_9 = var_3_5.playerIdentity
	local var_3_10 = var_3_5.characterVisualOptions

	for iter_3_0 = 2, var_0_1 do
		local var_3_11 = arg_3_0.playerModels[iter_3_0]

		var_3_11:setUniformConfig(var_3_7, var_3_8)
		var_3_11:setIdentity(var_3_9)
		var_3_11:setCharacterConfig(var_3_6)
		var_3_11:setCharacterVisualOptions(var_3_10)
		var_3_11:refresh()
	end
end

local var_0_3 = {
	"Journalist1",
	"Journalist2",
	"Journalist3",
	"Journalist4",
	"Journalist5",
	"Journalist6",
	"Journalist7",
	"Journalist8",
	"Journalist9"
}
local var_0_4 = {
	"ChairUmpireMale_UK",
	"ChairUmpireFemale_UK",
	"ChairUmpireMale_UK",
	"ChairUmpireMale_US",
	"ChairUmpireMale_UK",
	"ChairUmpireMale_US",
	"ChairUmpireFemale_UK",
	"ChairUmpireFemale_US",
	"ChairUmpireMale_US"
}

function PlayerModelMixin.loadCareerPlayers(arg_4_0, arg_4_1)
	local var_4_0 = 0

	if arg_4_0.playerData then
		for iter_4_0, iter_4_1 in ipairs(arg_4_0.playerData) do
			local var_4_1 = iter_4_1:getSelectedUniform().config

			arg_4_1:playerModelSetUniform(iter_4_0, var_4_1)

			local var_4_2 = {
				refresh = true,
				player = iter_4_1
			}

			arg_4_1:playerModelUpdate(iter_4_0, var_4_2)
		end
	end

	for iter_4_2 = #arg_4_0.playerData + 1, #arg_4_0.playerModels do
		arg_4_0:setPlayerAsReporter(arg_4_1, iter_4_2)
	end
end

function PlayerModelMixin.setPlayerAsReporter(arg_5_0, arg_5_1, arg_5_2)
	local var_5_0 = frontend_playervisuals_helper.reporterPlayerVisuals
	local var_5_1 = frontend_playervisuals_helper.reporterTeamVisuals

	if not arg_5_0.reporterIndexes or #arg_5_0.reporterIndexes == 0 then
		local var_5_2 = {}
		local var_5_3 = #var_5_0

		for iter_5_0 = 1, var_5_3 do
			table.insert(var_5_2, iter_5_0)
		end

		arg_5_0.reporterIndexes = var_5_2
	end

	local var_5_4, var_5_5 = tablex.randomelement(arg_5_0.reporterIndexes)

	table.remove(arg_5_0.reporterIndexes, var_5_5)

	local var_5_6 = var_5_0[var_5_4]
	local var_5_7 = var_5_1[var_5_4]

	arg_5_1:setPlayerModelAsReporter(arg_5_2, var_5_6, var_5_7)
end

function PlayerModelMixin.havePreloadedCutsceneVisuals(arg_6_0)
	return arg_6_0.preloadedCutsceneVisuals
end

function PlayerModelMixin.setHavePreloadedCutsceneVisuals(arg_7_0, arg_7_1)
	arg_7_0.preloadedCutsceneVisuals = arg_7_1
end

function PlayerModelMixin.onAllMixinsCreated(arg_8_0, arg_8_1)
	local var_8_0 = arg_8_1:getDecalManager()
	local var_8_1 = arg_8_1:getPlayerManager()

	arg_8_0.clubManager, arg_8_0.playerManager = arg_8_1:getClubManager(), var_8_1
	arg_8_0.decalManager = var_8_0

	local var_8_2 = arg_8_0.assetMap
	local var_8_3 = arg_8_0.engine
	local var_8_4 = arg_8_0.resources
	local var_8_5 = arg_8_0.renderer
	local var_8_6 = arg_8_0.scene
	local var_8_7 = var_8_3:getAssetManager()
	local var_8_8 = var_8_3:getTextureCompositor()

	native.CBodyCommandBucket.initialisePool(500)
	native.CBlendCommandBucket.initialisePool(500)

	local var_8_9 = {}

	var_8_4.gpuContext = var_8_3:getRenderInterface():getImmediateContext()

	for iter_8_0 = 1, var_0_1 do
		local var_8_10 = playermodel.PlayerModel(string.format("feplayer_%d", iter_8_0), (iter_8_0 - 1) % 2 + 1)
		local var_8_11 = arg_8_0:createPlayerProps(var_8_3, var_8_8, var_8_7, var_8_6)
		local var_8_12 = arg_8_0.isFrontEnd and iter_8_0 == 1

		var_8_10:create(var_8_3, var_8_0, var_8_6, var_8_5, var_8_4, var_8_2, var_8_11, arg_8_0.isFrontEnd, var_8_12)
		table.insert(var_8_9, var_8_10)
	end

	var_8_4.gpuContext = nil
	arg_8_0.playerModels = var_8_9

	if arg_8_0.playerData then
		arg_8_0:loadCareerPlayers(arg_8_1)

		arg_8_0.preloadedCutsceneVisuals = true
	else
		arg_8_0:loadDefaultPlayer(arg_8_1)
	end

	arg_8_1:playerModelCameraEnabled(true)
end

function PlayerModelMixin.dispose(arg_9_0, arg_9_1)
	local var_9_0 = arg_9_0.renderer

	for iter_9_0, iter_9_1 in ipairs(arg_9_0.playerModels) do
		iter_9_1:dispose(arg_9_1, var_9_0)
	end

	if arg_9_0.thumbnailGpuFrameBuffer then
		arg_9_0.thumbnailGpuFrameBuffer:dispose(arg_9_1:getRenderInterface())

		arg_9_0.thumbnailGpuFrameBuffer = nil
	end

	arg_9_0.resources:dispose(arg_9_1)
	native.CBlendCommandBucket.finalisePool()
	native.CBodyCommandBucket.finalisePool()
end

function PlayerModelMixin.registerWithDebugHooks(arg_10_0, arg_10_1)
	local var_10_0 = arg_10_1:getHook("CharacterManagerDebugHook")

	if var_10_0 then
		var_10_0:setReloadFn(arg_10_0.onReload)
	end
end

function PlayerModelMixin.createPlayerProps(arg_11_0, arg_11_1, arg_11_2, arg_11_3, arg_11_4)
	local var_11_0 = arg_11_0.assetMap
	local var_11_1 = arg_11_0.decalManager
	local var_11_2 = arg_11_0.renderer.renderer.ghostModelManager
	local var_11_3 = arg_11_1:getCollisionBlobLoader()

	if GAME_LACROSSE then
		local var_11_4 = native.CGearVisual()
		local var_11_5 = native.CGearVisual()
		local var_11_6 = native.CGearVisual()

		var_11_4:initialise(arg_11_1, arg_11_2, var_11_2, var_11_3, var_11_0, var_11_1)
		var_11_5:initialise(arg_11_1, arg_11_2, var_11_2, var_11_3, var_11_0, var_11_1)
		var_11_6:initialise(arg_11_1, arg_11_2, var_11_2, var_11_3, var_11_0, var_11_1)
		gearfactory.loadStickModel(var_11_4, native.EGearSubType.Crosse_Offence)
		gearfactory.loadStickModel(var_11_5, native.EGearSubType.Crosse_Defence)
		gearfactory.loadStickModel(var_11_6, native.EGearSubType.Crosse_Goalie)

		return {
			offenceCrosse = {
				prop = var_11_4,
				gearType = native.EGearType.Crosse,
				subType = native.EGearSubType.Crosse_Offence
			},
			defenceCrosse = {
				prop = var_11_5,
				gearType = native.EGearType.Crosse,
				subType = native.EGearSubType.Crosse_Defence
			},
			goalieCrosse = {
				prop = var_11_6,
				gearType = native.EGearType.Crosse,
				subType = native.EGearSubType.Crosse_Goalie
			}
		}
	elseif GAME_RUGBY then
		local var_11_7 = native.CGearVisual()

		var_11_7:initialise(arg_11_1, arg_11_2, var_11_2, var_11_3, var_11_0, var_11_1)
		gearfactory.loadBallModel(var_11_7)

		return {
			ball = {
				prop = var_11_7,
				gearType = native.EGearType.Ball,
				joint = native.EGearAttachmentJoint.LeftHandBallJoint
			}
		}
	elseif GAME_TENNIS then
		ASSERT(false)
	elseif GAME_CRICKET then
		local var_11_8 = native.CGearVisual()

		var_11_8:initialise(arg_11_1, arg_11_2, var_11_2, var_11_3, var_11_0, var_11_1)
		gearfactory.loadBatModel(var_11_8)

		return {
			gear = {
				prop = var_11_8,
				gearType = native.EGearType.Bat
			}
		}
	else
		return {}
	end
end

function PlayerModelMixin.onGraphicsSettingsChanged(arg_12_0, arg_12_1)
	arg_12_0.resources:onGraphicsSettingsChanged(arg_12_1)
end

function PlayerModelMixin.isLoaded(arg_13_0, arg_13_1, arg_13_2, arg_13_3, arg_13_4)
	local var_13_0 = arg_13_0.renderer
	local var_13_1 = arg_13_0.resources
	local var_13_2 = true
	local var_13_3
	local var_13_4

	for iter_13_0, iter_13_1 in ipairs(arg_13_0.playerModels) do
		iter_13_1:updateLoading(arg_13_1, var_13_0.renderer)

		if not iter_13_1:isLoaded(var_13_1) then
			var_13_2 = false
		end
	end

	var_13_1:updateLoading(arg_13_1)

	return var_13_2
end

function PlayerModelMixin.isGearLoaded(arg_14_0, arg_14_1)
	local var_14_0 = arg_14_0.resources

	for iter_14_0, iter_14_1 in ipairs(arg_14_0.playerModels) do
		if not iter_14_1:isGearLoaded(var_14_0, arg_14_1) then
			return false
		end
	end

	return true
end

function PlayerModelMixin.onLoadingCompleted(arg_15_0, arg_15_1)
	local var_15_0 = arg_15_0.renderer

	for iter_15_0, iter_15_1 in ipairs(arg_15_0.playerModels) do
		iter_15_1:onLoadingCompleted(arg_15_1, var_15_0)
	end
end

function PlayerModelMixin.updateBackground(arg_16_0, arg_16_1, arg_16_2, arg_16_3, arg_16_4, arg_16_5)
	local var_16_0 = arg_16_0.renderer
	local var_16_1 = arg_16_0.resources
	local var_16_2 = arg_16_0.playerModelCamera
	local var_16_3 = native.getCensorAllUGC()

	if arg_16_0.censorAllUGC ~= var_16_3 then
		for iter_16_0, iter_16_1 in ipairs(arg_16_0.playerModels) do
			iter_16_1:reloadModel()
		end

		arg_16_0.censorAllUGC = var_16_3
	end

	if not arg_16_0.inCutscene then
		for iter_16_2, iter_16_3 in ipairs(arg_16_0.playerModels) do
			iter_16_3:update(arg_16_1, arg_16_2, arg_16_3, arg_16_4, arg_16_5, var_16_0, var_16_1, var_16_2)
		end
	end
end

function PlayerModelMixin.updateCutsceneModels(arg_17_0, arg_17_1, arg_17_2, arg_17_3, arg_17_4, arg_17_5)
	if not arg_17_0.inCutscene then
		return
	end

	local var_17_0 = arg_17_0.renderer
	local var_17_1 = arg_17_0.resources
	local var_17_2 = arg_17_0.playerModelCamera

	var_17_1.gpuContext = arg_17_1:getRenderInterface():getImmediateContext()

	for iter_17_0, iter_17_1 in ipairs(arg_17_0.playerModels) do
		iter_17_1:update(arg_17_1, arg_17_2, arg_17_3, arg_17_4, arg_17_5, var_17_0, var_17_1, var_17_2)
	end

	var_17_1.gpuContext = nil
end

function PlayerModelMixin.setInCutscene(arg_18_0, arg_18_1)
	arg_18_0.inCutscene = arg_18_1
end

function PlayerModelMixin.updatePostRender(arg_19_0, arg_19_1, arg_19_2, arg_19_3, arg_19_4, arg_19_5)
	local var_19_0 = arg_19_0.cameraManager
	local var_19_1 = arg_19_0.playerModelCamera

	for iter_19_0, iter_19_1 in ipairs(arg_19_0.playerModels) do
		iter_19_1:updateCamera(var_19_0, var_19_1, arg_19_3)

		var_19_1 = nil

		iter_19_1:updateRotation(arg_19_1, arg_19_2, arg_19_3, arg_19_4, arg_19_5)
	end
end

function PlayerModelMixin.updateRotationFromChannelSum(arg_20_0, arg_20_1, arg_20_2, arg_20_3, arg_20_4)
	VERIFY(arg_20_0.playerModels[arg_20_2]):updateRotationFromChannelSum(arg_20_1, arg_20_3, arg_20_4)
end

function PlayerModelMixin.addConvenienceFunctionsToServices(arg_21_0, arg_21_1)
	local var_21_0 = arg_21_0.resources
	local var_21_1 = arg_21_0.cameraManager

	function arg_21_1.getNumberOfPlayerModels(arg_22_0)
		return var_0_1
	end

	function arg_21_1.getPlayerModels(arg_23_0)
		return arg_21_0.playerModels
	end

	function arg_21_1.getAnimInstances(arg_24_0)
		local var_24_0 = {}

		for iter_24_0, iter_24_1 in ipairs(arg_21_0.playerModels) do
			table.insert(var_24_0, iter_24_1.playerModelAnimation.characterAnimator.animInstance)
		end

		return var_24_0
	end

	function arg_21_1.getPlayerAnimationInstances(arg_25_0)
		local var_25_0 = {}

		for iter_25_0, iter_25_1 in ipairs(arg_21_0.playerModels) do
			table.insert(var_25_0, iter_25_1.playerModelAnimation.characterAnimator)
		end

		return var_25_0
	end

	function arg_21_1.getPlayerAnimationProvider(arg_26_0, arg_26_1)
		return arg_21_0.playerModels[arg_26_1]:getAnimationProvider()
	end

	function arg_21_1.getMotionSet(arg_27_0)
		return arg_21_0.resources:getMotionSet()
	end

	function arg_21_1.getPlayerModelSkeleton(arg_28_0, arg_28_1)
		return arg_21_0.playerModels[arg_28_1]:getSkeleton()
	end

	function arg_21_1.getCharacterVisualInstances(arg_29_0)
		local var_29_0 = {}

		for iter_29_0, iter_29_1 in ipairs(arg_21_0.playerModels) do
			table.insert(var_29_0, iter_29_1.characterVisual)
		end

		return var_29_0
	end

	function arg_21_1.getSkeletonModifiers(arg_30_0)
		local var_30_0 = {}

		for iter_30_0, iter_30_1 in ipairs(arg_21_0.playerModels) do
			table.insert(var_30_0, iter_30_1.playerModelSkeleton.skeletonModifier)
		end

		return var_30_0
	end

	function arg_21_1.getSkeletonModifier(arg_31_0, arg_31_1)
		return arg_21_0.playerModels[arg_31_1].playerModelSkeleton.skeletonModifier
	end

	function arg_21_1.getActiveLeans(arg_32_0)
		local var_32_0 = {}

		for iter_32_0, iter_32_1 in ipairs(arg_21_0.playerModels) do
			table.insert(var_32_0, iter_32_1.playerModelAnimation.activeLean)
		end

		return var_32_0
	end

	function arg_21_1.playerModelGetAssetMap()
		return arg_21_0.assetMap
	end

	function arg_21_1.getCameraManager()
		return arg_21_0.cameraManager
	end

	function arg_21_1.playerModelCameraEnabled(arg_35_0, arg_35_1)
		local var_35_0 = arg_21_0.playerModelCamera ~= nil

		if arg_35_1 ~= nil then
			if arg_35_1 then
				if not arg_21_0.playerModelCamera then
					local var_35_1 = var_21_1:getActiveCamera()
					local var_35_2 = camerautil.copyCamera({}, var_35_1)

					var_21_1:pushCamera(var_35_2, var_0_0)

					for iter_35_0, iter_35_1 in ipairs(arg_21_0.playerModels) do
						iter_35_1:setCameraInfo(nil)
					end

					arg_21_0.playerModelCamera = var_35_2
				end
			elseif arg_21_0.playerModelCamera then
				var_21_1:removeCamera(arg_21_0.playerModelCamera)

				arg_21_0.playerModelCamera = nil
			end
		end

		return var_35_0
	end

	function arg_21_1.playerModelGetPlayer(arg_36_0, arg_36_1)
		return VERIFY(arg_21_0.playerModels[arg_36_1])
	end

	function arg_21_1.playerModelGetIsLoaded(arg_37_0, arg_37_1)
		return VERIFY(arg_21_0.playerModels[arg_37_1]):isLoaded(var_21_0)
	end

	function arg_21_1.allPlayerModelsAreLoaded(arg_38_0)
		for iter_38_0 = 1, var_0_1 do
			if not arg_21_1:playerModelGetIsLoaded(iter_38_0) then
				return false
			end
		end

		return true
	end

	function arg_21_1.playerModelGetPosition(arg_39_0, arg_39_1)
		return VERIFY(arg_21_0.playerModels[arg_39_1]):getPosition()
	end

	function arg_21_1.playerModelGetOrientation(arg_40_0, arg_40_1)
		return VERIFY(arg_21_0.playerModels[arg_40_1]):getOrientation()
	end

	function arg_21_1.playerModelGetRotation(arg_41_0, arg_41_1)
		return VERIFY(arg_21_0.playerModels[arg_41_1]):getRotation()
	end

	function arg_21_1.playerModelIsShowing(arg_42_0, arg_42_1)
		return VERIFY(arg_21_0.playerModels[arg_42_1]).characterModelViewing ~= nil
	end

	function arg_21_1.playerModelGetDrawEnabled(arg_43_0, arg_43_1)
		return VERIFY(arg_21_0.playerModels[arg_43_1]).draw
	end

	function arg_21_1.updateRotationFromChannelSum(arg_44_0, arg_44_1, arg_44_2, arg_44_3)
		arg_21_0:updateRotationFromChannelSum(arg_21_1, arg_44_1, arg_44_2, arg_44_3)
	end

	function arg_21_1.playerModelGetVisualConfig(arg_45_0, arg_45_1)
		return arg_21_0.playerModels[arg_45_1]:getVisualConfig()
	end

	arg_21_0.queuedRefresh = false
	arg_21_0.allowQueuedRefreshes = false

	function arg_21_1.allowQueuedRefreshes(arg_46_0)
		arg_21_0.allowQueuedRefreshes = true
	end

	function arg_21_1.queueRefresh(arg_47_0)
		arg_21_0.queuedRefresh = true
	end

	function arg_21_1.refreshIfQueued(arg_48_0)
		if arg_21_0.queuedRefresh then
			for iter_48_0, iter_48_1 in ipairs(arg_21_0.playerModels) do
				iter_48_1:refresh()
			end
		end

		arg_21_0.queuedRefresh = false
		arg_21_0.allowQueuedRefreshes = false
	end

	function arg_21_1.playerModelGetRotationEnabled(arg_49_0, arg_49_1)
		return VERIFY(arg_21_0.playerModels[arg_49_1]).rotationEnabled
	end

	function arg_21_1.setPlayerModelProps(arg_50_0, arg_50_1, arg_50_2, arg_50_3)
		local var_50_0 = VERIFY(arg_21_0.playerModels[arg_50_1])

		var_50_0:hideAllProps()

		if arg_50_2 then
			for iter_50_0, iter_50_1 in ipairs(arg_50_2) do
				local var_50_1 = iter_50_1.name

				if var_50_1 == "default" then
					var_50_1 = playermodel_helper.getDefaultProp(arg_50_3)
				end

				if var_50_1 then
					local var_50_2 = iter_50_1.config

					if var_50_2 then
						var_50_0:setPropConfig(var_50_1, var_50_2)
					end

					if iter_50_1.attach ~= nil then
						if iter_50_1.attach then
							var_50_0:attachProp(var_50_1)
						else
							var_50_0:detachProp(var_50_1)
						end
					end

					var_50_0:showProp(var_50_1)
				end
			end
		end
	end

	local var_21_2 = native.CGearConfig(native.EGearConfigType.DefaultValue)

	function arg_21_1.overridePlayerModelRotate(arg_51_0, arg_51_1, arg_51_2)
		VERIFY(arg_21_0.playerModels[arg_51_1]):setRotationEnabled(arg_51_2)
	end

	function arg_21_1.playerModelUpdate(arg_52_0, arg_52_1, arg_52_2)
		local var_52_0 = VERIFY(arg_21_0.playerModels[arg_52_1])
		local var_52_1 = var_52_0.draw

		if arg_52_2.overrideEmotionGroup then
			var_52_0:setEmotionGroupName(arg_52_2.overrideEmotionGroup)
		else
			var_52_0:setEmotionGroupName(nil)
		end

		if arg_52_2.draw == false then
			var_52_0:setDraw(false, arg_52_2.drawProps)
		end

		if arg_52_2.resetOptions then
			var_52_0:setForcedDefaultHeightEnabled(false)
			var_52_0:setUniformGearAllowed(false)
			var_52_0:setLookAtEnable(arg_52_2.lookAtEnable or false)
			var_52_0:setLookAtFullHeadTurn(arg_52_2.lookAtFullHeadTurn or false)
			var_52_0:setCharacterVisualOptions()
		end

		if arg_52_2.rotationEnabled ~= nil then
			var_52_0:setRotationEnabled(arg_52_2.rotationEnabled)
		end

		if arg_52_2.player then
			local var_52_2 = arg_52_2.player
			local var_52_3 = VERIFY(arg_52_2.player.visual)

			var_52_3:setOption("role", "player")
			var_52_0:setCharacterConfig(var_52_3)

			local var_52_4 = VERIFY(arg_52_2.player.identity)

			var_52_0:setIdentity(var_52_4)

			if arg_52_2.identityOverride then
				for iter_52_0, iter_52_1 in pairs(arg_52_2.identityOverride) do
					var_52_0.playerIdentity:setOption(iter_52_0, iter_52_1)
				end
			end
		end

		if arg_52_2.defaultPlayer then
			local var_52_5

			if arg_52_2.defaultPlayerSex.isFemale then
				var_52_5 = arg_21_1:getDefaultPlayerVisual(native.DefaultPlayerVisuals.PlayerFemaleCaucasian)
			else
				var_52_5 = arg_21_1:getDefaultPlayerVisual(native.DefaultPlayerVisuals.PlayerMaleCaucasian)
			end

			var_52_0:setCharacterConfig(var_52_5)
			var_52_0:setIdentity()

			local var_52_6, var_52_7 = var_52_0:getVisualConfig()

			var_52_6:setOption("role", "player")
			arg_21_1:setPlayerModelProps(1, nil)
		end

		if arg_52_2.defaultHeight ~= nil then
			var_52_0:setForcedDefaultHeightEnabled(arg_52_2.defaultHeight)
		end

		if arg_52_2.referee or arg_52_2.coach then
			local var_52_8 = arg_52_2.referee or arg_52_2.coach
			local var_52_9 = VERIFY(var_52_8.visual)
			local var_52_10 = VERIFY(var_52_8.identity)
			local var_52_ce = arg_52_2.coach ~= nil or playergenerator.isCoachNPC(var_52_8)

			var_52_9:setOption("role", var_52_ce and "coach" or "referee")
			var_52_0:setCharacterConfig(var_52_9)
			var_52_0:setRefereeIdentity(var_52_10)

			if not var_52_ce then
				local var_52_11 = var_52_10.sex.isMale and native.DefaultTeamVisuals.NewCustomMale or native.DefaultTeamVisuals.NewCustomFemale
				local var_52_12 = arg_21_1:getDefaultTeamVisualManager()

				var_52_0:setUniformConfig(var_52_12:get(var_52_11))
			else
				var_52_0:setUniformConfig(var_52_8.uniform)
			end
		end

		if arg_52_2.characterVisualOptions then
			var_52_0:setCharacterVisualOptions(arg_52_2.characterVisualOptions)
		end

		if arg_52_2.animationEnabled ~= nil then
			var_52_0:setAnimationUpdateEnabled(arg_52_2.animationEnabled)
		end

		if arg_52_2.frontEndCutscene then
			local var_52_13 = arg_52_2.frontEndCutscene.animationName
			local var_52_14 = arg_52_2.frontEndCutscene.bodyCommand
			local var_52_15 = true

			var_52_0:playAnim(var_52_13, var_52_14, var_52_15)
		end

		if arg_52_2.moveEnabled then
			var_52_0:setMoveEnabled(arg_52_2.moveEnabled)
		else
			var_52_0:setMoveEnabled(false)
		end

		if arg_52_2.idleParams then
			if arg_52_2.idleParams.playerAnimation ~= "BindPose" then
				arg_21_0.lastQueuedAnimation = arg_52_2.idleParams
			end

			var_52_0:queueAnimation(arg_52_2.idleParams)
		end

		if arg_52_2.hideProps then
			var_52_0:hideAllProps()
		end

		if arg_52_2.camera then
			var_52_0:setCameraInfo(arg_52_2.camera, arg_52_2.cameraInstant)
		end

		if arg_52_2.visualConfig then
			var_52_0:setCharacterConfig(arg_52_2.visualConfig)
		end

		if arg_52_2.position then
			var_52_0:setPosition(arg_52_2.position)
		end

		if arg_52_2.rotation then
			var_52_0:setRotation(arg_52_2.rotation, true)
		end

		if arg_52_2.refresh or arg_52_2.refreshIfBeingDrawn and var_52_0.draw then
			var_52_0:refresh()
		end

		if arg_52_2.draw == true then
			var_52_0:setDraw(true, arg_52_2.drawProps, arg_52_2.forcePropHidden)
		end

		if arg_52_2.drawProps ~= nil and arg_52_2.draw == nil then
			var_52_0:setDraw(var_52_0:getDraw(), arg_52_2.drawProps, arg_52_2.forcePropHidden)
		end

		if arg_52_2.hideUntilLoaded then
			var_52_0:setHideUntilLoaded()
		end

		return var_52_1
	end

	function arg_21_1.playerModelUpdateAll(arg_53_0, arg_53_1)
		for iter_53_0 = 1, #arg_21_0.playerModels do
			arg_53_0:playerModelUpdate(iter_53_0, arg_53_1)
		end
	end

	function arg_21_1.playerModelSetUniform(arg_54_0, arg_54_1, arg_54_2, arg_54_3)
		arg_21_0.playerModels[arg_54_1]:setUniformConfig(arg_54_2, arg_54_3)
	end

	function arg_21_1.playerModelSetDefaultUniform(arg_55_0, arg_55_1, arg_55_2)
		local var_55_0 = VERIFY(arg_55_2.defaultUniformConfig)
		local var_55_1

		arg_21_1:playerModelSetUniform(arg_55_1, var_55_0, var_55_1)
	end

	function arg_21_1.playerModelThumbnailRender(arg_56_0, arg_56_1, arg_56_2, arg_56_3, arg_56_4, arg_56_5, arg_56_6)
		ASSERT(arg_56_4)
		ASSERT(arg_56_6)

		local var_56_0 = arg_56_2:getRenderInterface()
		local var_56_1 = arg_56_2:getJobManager()
		local var_56_2 = arg_21_0.renderer.renderer
		local var_56_3 = arg_56_2:getPerFrameMemory()
		local var_56_4 = VERIFY(arg_21_0.playerModels[arg_56_1])

		if not var_56_4:isLoaded(arg_21_0.resources) then
			return false
		end

		local var_56_5 = var_56_4.characterVisual
		local var_56_6 = var_56_4.playerModelSkeleton.skeletonModifier
		local var_56_7 = arg_21_0.scene
		local var_56_8 = arg_21_0.thumbnailGpuFrameBuffer
		local var_56_9
		local var_56_10 = var_56_4.rigInstance

		if arg_56_5 then
			var_56_9, var_56_10 = arg_56_5:get()
		end

		return var_56_2:renderThumbnail(var_56_0, var_56_3, var_56_1, var_56_7, arg_56_4, var_56_5, var_56_6, var_56_10, var_56_9, arg_56_3, arg_56_6, var_56_8)
	end

	function arg_21_1.setPlayerOverrideEmotionGroup(arg_57_0, arg_57_1, arg_57_2)
		VERIFY(arg_21_0.playerModels[arg_57_1]):setOverrideEmotionGroup(arg_57_2)
	end

	function arg_21_1.setPlayerModelAsReporter(arg_58_0, arg_58_1, arg_58_2, arg_58_3)
		local var_58_0 = VERIFY(arg_21_0.playerModels[arg_58_1])

		if not var_58_0:getIsReporter() then
			local var_58_1 = native.DefaultPlayerVisuals
			local var_58_2 = native.DefaultTeamVisuals
			local var_58_3 = var_58_1[arg_58_2]
			local var_58_4 = var_58_2[arg_58_3]
			local var_58_5 = arg_21_1:getDefaultPlayerVisual(var_58_3)
			local var_58_6 = arg_21_1:getDefaultTeamVisual(var_58_4)

			var_58_0:setAsReporter(var_58_5, var_58_6)
		end
	end

	function arg_21_1.setPlayerModelAsNonPlayerVisual(arg_59_0, arg_59_1, arg_59_2, arg_59_3)
		local var_59_0 = VERIFY(arg_21_0.playerModels[arg_59_1])
		local var_59_1 = native.DefaultPlayerVisuals
		local var_59_2 = native.DefaultTeamVisuals
		local var_59_3 = var_59_1[arg_59_2]
		local var_59_4 = var_59_2[arg_59_3]
		local var_59_5 = arg_21_1:getDefaultPlayerVisual(var_59_3)
		local var_59_6 = arg_21_1:getDefaultTeamVisual(var_59_4)

		var_59_0:setNonPlayerVisuals(var_59_5, var_59_6)
	end

	function arg_21_1.getHavePreloadedCutsceneVisuals(arg_60_0)
		return arg_21_0:havePreloadedCutsceneVisuals()
	end

	function arg_21_1.setHavePreloadedCutsceneVisuals(arg_61_0, arg_61_1)
		arg_21_0:setHavePreloadedCutsceneVisuals(arg_61_1)
	end

	function arg_21_1.updateCutsceneModels(arg_62_0, ...)
		arg_21_0:updateCutsceneModels(...)
	end

	function arg_21_1.setInCutscene(arg_63_0, ...)
		arg_21_0:setInCutscene(...)
	end

	function arg_21_1.inCutscene(arg_64_0)
		return arg_21_0.inCutscene
	end
end
