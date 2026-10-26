local var_0_0 = native.getPlatformString()

Class("PlayerModelResources")

function PlayerModelResources.create(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4)
	local var_1_0 = arg_1_1:getGraphicsSettings()
	local var_1_1 = arg_1_1:getAssetManager()

	arg_1_0.assetManager = var_1_1
	arg_1_0.collisionBlobLoader = arg_1_1:getCollisionBlobLoader()

	local var_1_2 = arg_1_1:getJobManager()
	local var_1_3 = {
		assetManager = var_1_1,
		blobManager = arg_1_1:getBlobManager(),
		graphicsSettings = var_1_0,
		textureManager = arg_1_1:getTextureManager(),
		assetLoadMonitor = arg_1_1:getAssetLoadMonitor(),
		collisionBlobLoader = arg_1_1:getCollisionBlobLoader(),
		tier1HJOffsetsBlobLoader = arg_1_1:getTier1HJOffsetsBlobLoader(),
		jigglyConfigBlobLoader = arg_1_1:getJigglyConfigBlobLoader(),
		jobManager = var_1_2,
		ghostModelManager = arg_1_4.renderer.ghostModelManager,
		shadowManager = arg_1_4.renderer.shadowManager
	}

	local function var_1_4(arg_2_0)
		ASSERT(false)

		return 1 + native.CCricketCharacterAssetMap.getGeometrySlotIndex(arg_2_0)
	end

	local var_1_5 = native.CUniformDecorator()

	if PLATFORM_SWITCH then
		var_1_5:init(arg_1_1, arg_1_4.renderer, 512, 512)
	else
		var_1_5:init(arg_1_1, arg_1_4.renderer, 1024, 1024)
	end

	arg_1_0.uniformDecorator = var_1_5

	local var_1_6 = arg_1_1:getTextureManager()
	local var_1_7 = arg_1_1:getJobManager()
	local var_1_8 = arg_1_1:getTextureCache()
	local var_1_9 = var_1_0.frontendCharacters

	var_1_8:setTexelLimit(var_1_9)

	arg_1_0.textureCache = var_1_8

	local var_1_10 = arg_1_1:getRenderInterface()
	local var_1_11 = arg_1_1:getShaderPackAsset()
	local var_1_12 = arg_1_1:getHelperJointsLoader()

	arg_1_0.characterManager = native.CCharacterManager(var_1_10, arg_1_3, var_1_11, var_1_12, var_1_3)

	local var_1_13 = arg_1_1:getAnimationManager()
	local var_1_14 = native.CAnimationProvider(var_1_13)
	local var_1_15 = var_1_13:load("animations/master.animset")

	var_1_14:addAnimationSet(var_1_15, false)

	local var_1_16 = var_1_13:load("animations/rigdelta.animset")

	var_1_14:addAnimationSet(var_1_16, false)

	local var_1_17 = var_1_13:load("animations/ui.animset")

	var_1_14:addAnimationSet(var_1_17, false)

	local var_1_18 = var_1_13:load("animations/uifacial.animset")

	var_1_14:addAnimationSet(var_1_18, false)

	-- storm-celebration-viewer: the Storm promo celebrations, played by the Celebrations tile
	local var_1_storm = var_1_13:load("animations/cutsceneStormPromo.animset")

	var_1_14:addAnimationSet(var_1_storm, false)

	arg_1_0.stormPromoAnimationSet = var_1_storm

	local var_1_19 = assert(arg_1_1:getMotionSetManager())
	local var_1_20 = var_1_19:load("animations/motionset.motionset")
	local var_1_21 = assert(arg_1_1:getAnimUnitManager())
	local var_1_22 = var_1_21:load("animations/animunit.animunit")

	arg_1_0.animationManager = var_1_13
	arg_1_0.animationSet = var_1_17
	arg_1_0.masterAnimationSet = var_1_15
	arg_1_0.rigDeltaAnimationSet = var_1_16
	arg_1_0.facialAnimationSet = var_1_18
	arg_1_0.animationProvider = var_1_14
	arg_1_0.jobManager = var_1_2
	arg_1_0.motionSetContainer = assert(var_1_20)
	arg_1_0.animUnitsContainer = assert(var_1_22)
	arg_1_0.motionSetManager = var_1_19
	arg_1_0.animUnitManager = var_1_21

	local var_1_23 = arg_1_1:getActionSetManager()

	arg_1_0.frontEndSet = VERIFY(var_1_23:load("actionset/frontendset.dat"))
end

function PlayerModelResources.dispose(arg_3_0, arg_3_1)
	print("Unloading player model/animation resources")
	arg_3_1:getActionSetManager():unload(arg_3_0.frontEndSet)

	if arg_3_0.motionSetContainer.data then
		arg_3_0.motionSetContainer.data:dispose()
	end

	arg_3_0.motionSetManager:unload(arg_3_0.motionSetContainer)
	arg_3_0.animUnitManager:unload(arg_3_0.animUnitsContainer)
	arg_3_0.animationProvider:removeAnimationSet(arg_3_0.stormPromoAnimationSet)
	arg_3_0.animationManager:unload(arg_3_0.stormPromoAnimationSet)
	arg_3_0.animationProvider:removeAnimationSet(arg_3_0.facialAnimationSet)
	arg_3_0.animationManager:unload(arg_3_0.facialAnimationSet)
	arg_3_0.animationProvider:removeAnimationSet(arg_3_0.rigDeltaAnimationSet)
	arg_3_0.animationManager:unload(arg_3_0.rigDeltaAnimationSet)
	arg_3_0.animationProvider:removeAnimationSet(arg_3_0.masterAnimationSet)
	arg_3_0.animationManager:unload(arg_3_0.masterAnimationSet)
	arg_3_0.animationProvider:removeAnimationSet(arg_3_0.animationSet)
	arg_3_0.animationManager:unload(arg_3_0.animationSet)

	if not arg_3_0.characterManager:canDispose() then
		print("WARNING: Disposing of character manager synchronously while jobs are in progress")

		local var_3_0 = arg_3_1:getTextureCompositor()
		local var_3_1 = arg_3_1:getGpuTaskService()

		arg_3_0.characterManager:wait(var_3_0, var_3_1)
	end

	arg_3_0.characterManager:dispose()
	arg_3_0.uniformDecorator:dispose()
	arg_3_0.textureCache:clear()
end

function PlayerModelResources.onGraphicsSettingsChanged(arg_4_0, arg_4_1)
	local var_4_0 = arg_4_1.frontendCharacters

	arg_4_0.textureCache:setTexelLimit(var_4_0)
end

function PlayerModelResources.updateLoading(arg_5_0, arg_5_1)
	local var_5_0 = arg_5_1:getRenderInterface():getImmediateContext()
	local var_5_1 = arg_5_0.characterManager
	local var_5_2 = arg_5_1:getGpuTaskService()

	arg_5_0.animationProvider:update()
	var_5_1:update(var_5_0)
end

function PlayerModelResources.reload(arg_6_0)
	arg_6_0.motionSetManager:reload(arg_6_0.motionSetContainer)
	arg_6_0.animUnitManager:reload(arg_6_0.animUnitsContainer)
	arg_6_0.animationProvider:reload()
end

function PlayerModelResources.getMotionSet(arg_7_0)
	return arg_7_0.motionSetContainer
end
