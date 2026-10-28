import("app.playermodel.playermodel_animation")
import("app.playermodel.playermodel_camera_aide")
import("app.playermodel.playermodel_helper")
import("app.playermodel.playermodel_rotation")
import("app.playermodel.playermodel_skeleton")
import("core.foundation.tablex")

local var_0_0 = native.CPlayerAttributes.DEFAULT_HEIGHT
local var_0_1 = native.CPlayerIdentity()

var_0_1:setOption("shirtName", "PLAYER")
var_0_1:setOption("shirtNumber", 1)

local var_0_2 = native.CClubIdentity()

var_0_2.decalIdOrIcon = native.CDecalIdOrIcon(native.EIconCategory.Clubs, "rep_bigant_male")

var_0_2:setOption("shortName", "Club Name")
var_0_2:setOption("nickname", "nickname")

local var_0_3 = native.CRefereeIdentity()
local var_0_4 = native.getPlatformString()

Class("PlayerModel", function(arg_1_0, arg_1_1, arg_1_2)
	arg_1_0.name = arg_1_1
	arg_1_0.sideIndex = arg_1_2
end)

function PlayerModel.create(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9)
	local var_2_0 = arg_2_1:getAssetManager()
	local var_2_1 = arg_2_1:getTextureCompositor()
	local var_2_2 = native.CCharacterSkeleton("frontend")

	var_2_2:load(var_2_0, arg_2_3, "player_male")

	arg_2_0.rigInstance = var_2_2
	arg_2_0.skeletonAttachmentManager = arg_2_3.skeletonAttachmentManager
	arg_2_0.resources = arg_2_5
	arg_2_0.scene = arg_2_3
	arg_2_0.playerModelSkeleton = playermodel_skeleton.PlayerModelSkeleton(var_2_2)

	local var_2_3 = arg_2_0.playerModelSkeleton.skeletonModifier

	arg_2_0.skeletonModifier = var_2_3
	arg_2_0.characterConfig = native.CCharacterVisualConfig()
	arg_2_0.uniformConfig = native.CVisualConfig("team")
	arg_2_0.playerIdentity = native.CPlayerIdentity()
	arg_2_0.clubIdentity = native.CClubIdentity()
	arg_2_0.refereeIdentity = native.CRefereeIdentity()

	local var_2_4 = arg_2_1:getGraphicsSettings()
	local var_2_5 = arg_2_9 and native.EGraphicsSettingsCharacterTextureCompression.Off or var_2_4.characterTextureCompression
	local var_2_6 = var_2_4.frontendCharacters
	local var_2_7 = var_2_4.clothQuality

	arg_2_0.quality = var_2_6
	arg_2_0.clothQuality = var_2_7

	local var_2_8 = arg_2_5.animationProvider
	local var_2_9 = native.CCharacterVisual(arg_2_1, arg_2_5.characterManager, arg_2_6, var_2_1, arg_2_2, nil, nil, var_2_2, native.EAssetMapModelType.Player, var_2_3, var_2_8, not arg_2_8, var_2_5, var_2_6, var_2_7)

	function var_2_9.onCharacterCompleteCallback()
		arg_2_0:onCharacterComplete()
	end

	var_2_9.uniformDecorator = arg_2_5.uniformDecorator
	var_2_9.uniformName = string.format("frontend_uniform_%s", arg_2_0.name)
	arg_2_0.characterVisual = var_2_9

	local var_2_10 = playermodel_animation.PlayerModelAnimation(arg_2_1, var_2_2, "cricketAcademyCharacter")

	arg_2_0.playerModelAnimation = var_2_10

	arg_2_0:registerAnimationEvents(var_2_10.characterAnimator, var_2_3)

	arg_2_0.playerModelRotation = playermodel_rotation.PlayerModelRotation(arg_2_1, var_2_2)

	arg_2_0:setIdentity(nil)
	arg_2_0:setTeamIdentity(nil)
	arg_2_0:setAnimationUpdateEnabled(true)
	arg_2_0:setManualLookAtEnable(true)
	arg_2_0:setLookAtEnable(true)
	arg_2_0:setLookAtFullHeadTurn(false)
	arg_2_0:setUniformGearAllowed(true)
	arg_2_0:setRotationEnabled(true)

	arg_2_0.props = arg_2_7

	for iter_2_0, iter_2_1 in pairs(arg_2_7) do
		arg_2_0:hideProp(iter_2_0)
		arg_2_0:attachProp(iter_2_0, iter_2_1.joint)
	end
end

function PlayerModel.registerAnimationEvents(arg_4_0, arg_4_1, arg_4_2)
	local function var_4_0(arg_5_0, arg_5_1, arg_5_2)
		arg_4_2:blink(native.EBlinkSpeed.Fast)
	end

	local function var_4_1(arg_6_0, arg_6_1, arg_6_2)
		arg_4_2:blink(native.EBlinkSpeed.Normal)
	end

	local function var_4_2(arg_7_0, arg_7_1, arg_7_2)
		arg_4_2:blink(native.EBlinkSpeed.Slow)
	end

	arg_4_1:registerAnimationEventListener(var_4_0, "blink_fast")
	arg_4_1:registerAnimationEventListener(var_4_1, "blink_normal")
	arg_4_1:registerAnimationEventListener(var_4_2, "blink_slow")
end

function PlayerModel.scriptsReloaded(arg_8_0, arg_8_1, arg_8_2)
	arg_8_0.characterVisual:scriptsReloaded(arg_8_1, arg_8_2)
	arg_8_0.characterConfig:scriptsReloaded(arg_8_1, arg_8_2)
	arg_8_0.uniformConfig:scriptsReloaded(arg_8_1, arg_8_2)
end

function PlayerModel.dispose(arg_9_0, arg_9_1, arg_9_2)
	arg_9_0.playerModelAnimation:dispose()
	arg_9_0.playerModelSkeleton:dispose()
	arg_9_0.characterVisual:dispose()
	arg_9_0.rigInstance:dispose()

	for iter_9_0, iter_9_1 in pairs(arg_9_0.props) do
		iter_9_1.prop:dispose()
	end
end

function PlayerModel.hideAllProps(arg_10_0)
	for iter_10_0, iter_10_1 in pairs(arg_10_0.props) do
		iter_10_1.visible = false
	end
end

function PlayerModel.showProp(arg_11_0, arg_11_1)
	arg_11_0.props[arg_11_1].visible = true
end

function PlayerModel.hideProp(arg_12_0, arg_12_1)
	arg_12_0.props[arg_12_1].visible = false
end

function PlayerModel.getPropConfig(arg_13_0, arg_13_1)
	return arg_13_0.props[arg_13_1].prop.gearConfig
end

function PlayerModel.setPropConfig(arg_14_0, arg_14_1, arg_14_2)
	if arg_14_1 == "all" then
		for iter_14_0, iter_14_1 in pairs(arg_14_0.props) do
			arg_14_0:setPropConfig(iter_14_0, arg_14_2)
		end

		return
	end

	local var_14_0 = arg_14_0.props[arg_14_1]
	local var_14_1 = VERIFY(var_14_0.prop)

	var_14_1:setConfig(arg_14_2)

	if var_14_0.subType then
		var_14_1.gearConfig:call("setSubType", var_14_0.subType)
	end
end

function PlayerModel.flushPropVisibility(arg_15_0)
	local var_15_0 = arg_15_0.drawProps

	if arg_15_0.hideUntilLoaded and not arg_15_0:isLoaded() then
		var_15_0 = false
	end

	for iter_15_0, iter_15_1 in pairs(arg_15_0.props) do
		local var_15_1 = var_15_0 and iter_15_1.visible

		iter_15_1.prop:setVisible(var_15_1)
	end
end

function PlayerModel.attachProp(arg_16_0, arg_16_1, arg_16_2)
	local var_16_0 = arg_16_0.props[arg_16_1]

	var_16_0.attached = true
	var_16_0.attachmentJoint = arg_16_2
end

function PlayerModel.detachProp(arg_17_0, arg_17_1)
	local var_17_0 = arg_17_0.props[arg_17_1]

	var_17_0.attached = false
	var_17_0.attachmentJoint = nil
end

function PlayerModel.flushPropAttachments(arg_18_0, arg_18_1)
	local var_18_0 = arg_18_0.rigInstance.skeleton

	if not var_18_0 then
		return
	end

	local var_18_1 = arg_18_0.skeletonAttachmentManager
	local var_18_2 = arg_18_1.shadowManager

	for iter_18_0, iter_18_1 in pairs(arg_18_0.props) do
		if iter_18_1.attached then
			local var_18_3 = iter_18_1.attachmentJoint or native.EGearAttachmentJoint.RightHandBallJoint

			iter_18_1.prop:attachToSkeletonJoint(var_18_1, var_18_0, var_18_3)
		else
			iter_18_1.prop:detachFromSkeletonJoint()
		end
	end
end

function PlayerModel.setForcedDefaultHeightEnabled(arg_19_0, arg_19_1)
	arg_19_0.forceUseOfDefaultHeight = arg_19_1
end

function PlayerModel.getDraw(arg_20_0)
	return arg_20_0.draw, arg_20_0.drawProps
end

function PlayerModel.setDraw(arg_21_0, arg_21_1, arg_21_2, arg_21_3)
	arg_21_0.draw = arg_21_1
	arg_21_0.playerModelRotation.draw = arg_21_1
	arg_21_0.drawProps = (arg_21_1 or arg_21_2) and not arg_21_3

	if arg_21_1 then
		local var_21_0

		if arg_21_0.queuedAnimationInfo then
			var_21_0 = arg_21_0.queuedAnimationInfo.emotionGroupName

			ASSERT(var_21_0 ~= "")
		end

		if arg_21_0.overrideEmotionGroupName then
			var_21_0 = arg_21_0.overrideEmotionGroupName
		end

		var_21_0 = var_21_0 or arg_21_0.playerModelAnimation:getEmotionGroup()

		ASSERT(var_21_0 and var_21_0 ~= "", "No emotion group specified for UI actor, head will be shrunken.")
	else
		arg_21_0.characterVisual.visible = false

		arg_21_0:flushPropVisibility()
	end
end

function PlayerModel.getJoint(arg_22_0, arg_22_1)
	assert(arg_22_0.rigInstance)

	return arg_22_0.rigInstance:getJoint(arg_22_1)
end

function PlayerModel.getJointCount(arg_23_0)
	return arg_23_0.rigInstance.jointCount
end

function PlayerModel.getJointNameFromIndex(arg_24_0, arg_24_1)
	return arg_24_0.rigInstance:getJointNameFromIndex(arg_24_1)
end

function PlayerModel.getIsReporter(arg_25_0)
	return arg_25_0.isReporter
end

function PlayerModel.setPosition(arg_26_0, arg_26_1)
	local var_26_0 = arg_26_0.rigInstance:getRootNode()

	if not native.withinDistance3(var_26_0.position, arg_26_1, 0.01) then
		arg_26_0:onReset()
	end

	var_26_0.position = arg_26_1
end

function PlayerModel.getPosition(arg_27_0)
	return arg_27_0.rigInstance:getRootNode().position
end

function PlayerModel.getOrientation(arg_28_0)
	return arg_28_0.rigInstance:getRootNode().rotation
end

function PlayerModel.onReset(arg_29_0)
	arg_29_0.playerModelSkeleton:onReset()
end

function PlayerModel.setRotationEnabled(arg_30_0, arg_30_1)
	arg_30_0.rotationEnabled = arg_30_1
end

function PlayerModel.setRotation(arg_31_0, arg_31_1, arg_31_2)
	ASSERT(arg_31_2)

	arg_31_0.currentRotation = arg_31_1

	arg_31_0.playerModelRotation:setDeltaRotation(0)
end

function PlayerModel.getRotation(arg_32_0)
	return arg_32_0.currentRotation
end

function PlayerModel.setLookAtManual(arg_33_0, arg_33_1, arg_33_2, arg_33_3)
	return arg_33_0.playerModelRotation:setLookAtManual(arg_33_1, arg_33_2, arg_33_3)
end

function PlayerModel.setMoveEnabled(arg_34_0, arg_34_1)
	arg_34_0.moveEnabled = arg_34_1
end

function PlayerModel.setAnimationUpdateEnabled(arg_35_0, arg_35_1)
	arg_35_0.animationUpdateEnabled = arg_35_1
end

function PlayerModel.setLookAtEnable(arg_36_0, arg_36_1)
	assert(arg_36_1 ~= nil)

	arg_36_0.lookAtEnable = arg_36_1
end

function PlayerModel.setManualLookAtEnable(arg_37_0, arg_37_1)
	assert(arg_37_1 ~= nil)

	arg_37_0.manualLookAtEnable = arg_37_1
end

function PlayerModel.setLookAtFullHeadTurn(arg_38_0, arg_38_1)
	arg_38_0.fullHeadTurnEnabled = arg_38_1
end

function PlayerModel.updateRotationFromChannelSum(arg_39_0, arg_39_1, arg_39_2, arg_39_3)
	VERIFY(arg_39_0.playerModelRotation):updateRotationFromChannelSum(arg_39_1, arg_39_2, arg_39_3)
end

function PlayerModel.setUniformConfig(arg_40_0, arg_40_1, arg_40_2)
	arg_40_0.uniformConfig:copy(assert(arg_40_1))

	if arg_40_2 then
		arg_40_0:setTeamIdentity(arg_40_2)
	end
end

function PlayerModel.setUniformGearAllowed(arg_41_0, arg_41_1)
	arg_41_0.uniformGearAllowed = arg_41_1
end

function PlayerModel.getVisualConfig(arg_42_0)
	return arg_42_0.characterConfig, arg_42_0.uniformConfig
end

function PlayerModel.setCharacterConfig(arg_43_0, arg_43_1)
	arg_43_0:clearVisualRoleFlags()
	arg_43_0.characterConfig:copy(arg_43_1)
end

function PlayerModel.setHideUntilLoaded(arg_44_0, arg_44_1)
	arg_44_0.hideUntilLoaded = true

	if not arg_44_0:isLoaded() then
		arg_44_0.characterVisual.visible = false

		arg_44_0:flushPropVisibility(arg_44_1)
	end
end

function PlayerModel.setIdentity(arg_45_0, arg_45_1)
	arg_45_0.playerIdentity:set(arg_45_1 or var_0_1)
end

function PlayerModel.setRefereeIdentity(arg_46_0, arg_46_1)
	arg_46_0.refereeIdentity:set(arg_46_1 or var_0_3)
end

function PlayerModel.setTeamIdentity(arg_47_0, arg_47_1)
	local var_47_0 = arg_47_0.clubIdentity

	if type(arg_47_1) == "table" then
		for iter_47_0, iter_47_1 in pairs(arg_47_1) do
			if var_47_0:hasProperty(iter_47_0) then
				var_47_0[iter_47_0] = iter_47_1
			else
				var_47_0:setOption(iter_47_0, iter_47_1)
			end
		end
	else
		var_47_0:set(arg_47_1 or var_0_2)
	end
end

function PlayerModel.setCharacterVisualOptions(arg_48_0, arg_48_1)
	arg_48_0.characterVisualOptions = arg_48_1
end

function PlayerModel.setBodyHidden(arg_49_0, arg_49_1)
	arg_49_0.hideBody = arg_49_1
end

function PlayerModel.setAsReporter(arg_50_0, arg_50_1, arg_50_2)
	arg_50_0:setNonPlayerVisuals(arg_50_1, arg_50_2)

	arg_50_0.isReporter = true
end

function PlayerModel.setNonPlayerVisuals(arg_51_0, arg_51_1, arg_51_2)
	arg_51_0:setCharacterConfig(arg_51_1)
	arg_51_0:setIdentity()
	arg_51_0:setUniformConfig(arg_51_2)
	arg_51_0:refresh()
end

function PlayerModel.clearVisualRoleFlags(arg_52_0)
	arg_52_0.isReporter = false
end

function PlayerModel.refresh(arg_53_0)
	local var_53_0 = VERIFY(arg_53_0.characterConfig)
	local var_53_1 = VERIFY(arg_53_0.uniformConfig)
	local var_53_2 = VERIFY(arg_53_0.clubIdentity)

	local var_53_ce = var_53_0:getOption("role")

	if var_53_ce == "referee" then
		native.PlayerVisualUtils.fillRefereeVisualConfig(var_53_0, arg_53_0.refereeIdentity)
		native.PlayerVisualUtils.fillRefereeTeamVisualConfig(var_53_1, arg_53_0.refereeIdentity)
	elseif var_53_ce == "coach" then
		native.PlayerVisualUtils.fillRefereeVisualConfig(var_53_0, arg_53_0.refereeIdentity)
		var_53_0:setOption("role", "coach")
	else
		native.PlayerVisualUtils.fillPlayerVisualConfigForFrontEnd(var_53_0, arg_53_0.playerIdentity)
		native.PlayerVisualUtils.fillPlayerTeamVisualConfig(var_53_1, arg_53_0.playerIdentity)
	end

	if arg_53_0.characterVisualOptions then
		for iter_53_0, iter_53_1 in pairs(arg_53_0.characterVisualOptions) do
			var_53_0:setOption(iter_53_0, iter_53_1)
		end
	end

	var_53_0:setOption("forceUseOfDefaultHeight", arg_53_0.forceUseOfDefaultHeight and 1 or 0)
	var_53_0:setOption("currentGearType", 0)

	for iter_53_2, iter_53_3 in pairs(arg_53_0.props) do
		if (iter_53_3.prop:isVisible() or iter_53_3.visible) and iter_53_3.attached then
			var_53_0:setOption("currentGearType", iter_53_3.gearType:toInt())
		end
	end

	arg_53_0.characterVisual:setConfig(var_53_0, var_53_1)

	arg_53_0.bodyShapePending = true

	if not arg_53_0.queuedAnimationInfo and arg_53_0:animFiltersChanged() then
		arg_53_0:queueAnimation(arg_53_0.idleInfo)
	end
end

function PlayerModel.playAnim(arg_54_0, arg_54_1, arg_54_2, arg_54_3)
	if not arg_54_3 and arg_54_1 == arg_54_0.animName then
		return
	end

	arg_54_0.animName = arg_54_1

	if arg_54_3 and arg_54_0.overrideEmotionGroupName then
		arg_54_0.playerModelAnimation:setEmotionGroup(arg_54_0.overrideEmotionGroupName)
	end

	return arg_54_0.playerModelAnimation:playBodyAnim(arg_54_1, arg_54_2)
end

function PlayerModel.getPrimaryBodyCommand(arg_55_0)
	return arg_55_0.playerModelAnimation:getPrimaryBodyCommand()
end

function PlayerModel.isLoaded(arg_56_0)
	if not arg_56_0.characterVisual:isLoaded() then
		return false
	end

	if not arg_56_0.playerModelAnimation:isFinishedLoading(arg_56_0.resources) then
		return false
	end

	if not arg_56_0.playerModelSkeleton:isLoaded() then
		return false
	end

	for iter_56_0, iter_56_1 in pairs(arg_56_0.props) do
		if iter_56_1.prop:isLoading() then
			return false
		end
	end

	return true
end

function PlayerModel.isGearLoaded(arg_57_0, arg_57_1, arg_57_2)
	local var_57_0 = arg_57_1.assetManager
	local var_57_1 = arg_57_0.scene

	for iter_57_0, iter_57_1 in pairs(arg_57_0.props) do
		iter_57_1.prop:updateLoading(arg_57_0.quality, arg_57_2, var_57_0, var_57_1)

		if iter_57_1.prop:isLoading() then
			return false
		end
	end

	return true
end

function PlayerModel.onLoadingCompleted(arg_58_0, arg_58_1, arg_58_2)
	arg_58_0:setDraw(false)
end

function PlayerModel.updateIKTargets(arg_59_0, arg_59_1)
	local var_59_0 = VERIFY(arg_59_0.playerModelSkeleton)
	local var_59_1 = arg_59_0.playerModelAnimation.characterAnimator.armIKCancellationFactor

	if arg_59_0.ikBallHoldFixup then
		local var_59_2 = VERIFY(arg_59_0:getPrimaryBodyCommand()).anim
		local var_59_3 = arg_59_0.playerModelAnimation.characterAnimator:getAnimationProvider():getAnimationByName(var_59_2)

		ASSERT(var_59_3, debugFormat("Unable to find animation %s", var_59_2))

		local var_59_4 = var_59_3:findTranslationChannelId("balljoint")
		local var_59_5 = var_59_3:findTranslationChannelId("worldlefthand")
		local var_59_6 = var_59_3:findTranslationChannelId("worldrighthand")
		local var_59_7 = var_59_3:evaluateTranslation(var_59_4, 0)
		local var_59_8 = var_59_3:evaluateTranslation(var_59_5, 0)
		local var_59_9 = var_59_3:evaluateTranslation(var_59_6, 0)
		local var_59_10 = var_59_8 - var_59_7
		local var_59_11 = var_59_9 - var_59_7
		local var_59_12 = arg_59_0.playerModelSkeleton:getFrame()
		local var_59_13 = var_59_12:transform3(var_59_7)
		local var_59_14 = var_59_12.q:transform(var_59_10)
		local var_59_15 = var_59_12.q:transform(var_59_11)
		local var_59_16 = var_59_13 + var_59_14
		local var_59_17 = var_59_13 + var_59_15
		local var_59_18 = native.CIKTarget()
		local var_59_19 = native.CIKTarget()
		local var_59_20 = 0

		var_59_18:setTargetWorldPos(var_59_16)

		var_59_18.targetTime = arg_59_1
		var_59_18.blendInTime = 0
		var_59_18.holdDuration = 1000

		var_59_19:setTargetWorldPos(var_59_17)

		var_59_19.targetTime = arg_59_1
		var_59_19.blendInTime = 0
		var_59_19.holdDuration = 1000

		return var_59_18, var_59_19, var_59_1
	end

	return nil, nil, var_59_1
end

function PlayerModel.update(arg_60_0, arg_60_1, arg_60_2, arg_60_3, arg_60_4, arg_60_5, arg_60_6, arg_60_7, arg_60_8)
	arg_60_0:advanceAnimation(arg_60_1, arg_60_2, arg_60_3, arg_60_4, arg_60_5, arg_60_6, arg_60_7, arg_60_8)

	local var_60_0 = arg_60_1:getRenderInterface()

	arg_60_0.characterVisual:update(var_60_0:getImmediateContext())
end

function PlayerModel.advanceAnimation(arg_61_0, arg_61_1, arg_61_2, arg_61_3, arg_61_4, arg_61_5, arg_61_6, arg_61_7, arg_61_8)
	if arg_61_0.queuedAnimationInfo then
		arg_61_0:playAnimation(arg_61_0.queuedAnimationInfo)

		arg_61_0.queuedAnimationInfo = nil
	end

	local var_61_0 = arg_61_0.playerModelRotation:getLookAt(arg_61_0.lookAtEnable, arg_61_0.manualLookAtEnable, arg_61_8)
	local var_61_1, var_61_2 = arg_61_0.playerModelAnimation:update(arg_61_0.animationUpdateEnabled and arg_61_3 or 0, arg_61_5)

	local function var_61_3(arg_62_0)
		return arg_61_0:updateIKTargets(arg_62_0)
	end

	local var_61_4 = arg_61_0.moveEnabled

	arg_61_0.playerModelSkeleton:update(arg_61_3, arg_61_2, arg_61_5, var_61_1, var_61_2, var_61_0, var_61_3, var_61_4)
end

function PlayerModel.onCharacterComplete(arg_63_0)
	print("PlayerModel:onCharacterComplete()")

	if arg_63_0.queuedAnimationInfo then
		arg_63_0:playAnimation(arg_63_0.queuedAnimationInfo)

		arg_63_0.queuedAnimationInfo = nil
	elseif arg_63_0:animFiltersChanged() then
		arg_63_0:playAnimation(arg_63_0.idleInfo)
	end
end

function PlayerModel.updateLoading(arg_64_0, arg_64_1, arg_64_2)
	local var_64_0 = arg_64_0.characterVisual
	local var_64_1 = arg_64_1:getRenderInterface():getImmediateContext()

	var_64_0:updateLoading(var_64_1)

	local var_64_2 = arg_64_0.scene

	for iter_64_0, iter_64_1 in pairs(arg_64_0.props) do
		iter_64_1.prop:updateLoading(arg_64_0.quality, var_64_1, arg_64_1:getAssetManager(), var_64_2)
	end

	local var_64_3 = arg_64_0:isLoaded()

	if var_64_3 then
		var_64_0.visible = arg_64_0.draw

		if arg_64_0.draw then
			arg_64_0.hideUntilLoaded = nil
		end

		arg_64_0:flushPropAttachments(arg_64_2)
		arg_64_0:flushPropVisibility()
	else
		var_64_0.visible = arg_64_0.draw and not arg_64_0.hideUntilLoaded
	end

	return var_64_3
end

function PlayerModel.reloadModel(arg_65_0)
	arg_65_0:refresh()
end

function PlayerModel.queueAnimation(arg_66_0, arg_66_1)
	arg_66_0.queuedAnimationInfo = arg_66_1
end

function PlayerModel.setEmotionGroupName(arg_67_0, arg_67_1)
	arg_67_0.overrideEmotionGroupName = arg_67_1
end

function PlayerModel.setOverrideEmotionGroup(arg_68_0, arg_68_1)
	arg_68_0:setEmotionGroupName(arg_68_1)
	arg_68_0.playerModelAnimation:setEmotionGroup(arg_68_1)
end

function PlayerModel.animFiltersChanged(arg_69_0)
	local var_69_0 = arg_69_0.characterVisual.renderedCharacterVisualConfig

	if var_69_0.configType ~= "player" then
		return
	end

	local var_69_1 = VERIFY(var_69_0:getOption("sex"))
	local var_69_2 = not arg_69_0.ignoreSex and native.CSex(var_69_1)
	local var_69_3 = var_69_0:getOption("currentGearType")
	local var_69_4 = native.EGearType:fromInt(var_69_3)
	local var_69_5 = "base"

	if var_69_0:getOption("heavy_bodyShape") > 0 then
		var_69_5 = "heavy"
	elseif var_69_0:getOption("athletique_bodyShape") > 0 then
		var_69_5 = "base"
	end

	local var_69_6 = {
		sex = var_69_2,
		gearType = var_69_4,
		side = arg_69_0.sideIndex,
		hand = var_69_0:getOption("handedness"),
		physique = var_69_5
	}

	return not tablex.equalTo(var_69_6, arg_69_0.idleFilterParams), var_69_6
end

function PlayerModel.playAnimation(arg_70_0, arg_70_1)
	arg_70_0.idleInfo = arg_70_1

	if not arg_70_1 then
		return
	end

	if not arg_70_0.overrideEmotionGroupName and arg_70_1.emotionGroupName then
		arg_70_0.playerModelAnimation:setEmotionGroup(arg_70_1.emotionGroupName)
	end

	arg_70_0:setLookAtEnable(arg_70_1.lookAtEnable and arg_70_1.lookAtEnable or false)

	local var_70_0 = arg_70_1.playerAnimation

	if not var_70_0 then
		return
	end

	arg_70_0.idleGroupName = var_70_0
	arg_70_0.ignoreSex = arg_70_1.ignoreSex

	local var_70_1, var_70_2 = arg_70_0:animFiltersChanged()
	local var_70_3 = playermodel_helper.getIdleAnimationName(var_70_0, arg_70_0.resources, var_70_2)

	arg_70_0.idleFilterParams = var_70_2

	if var_70_3 then
		local var_70_4 = arg_70_1.playerAnimationParams or {}

		if var_70_1 then
			var_70_4 = tablex.merge(var_70_4, {
				transitionFrameCount = 0
			})
			arg_70_0.queueFrameCounter = 10
		end

		arg_70_0:playAnim(var_70_3, var_70_4)
	end
end

function PlayerModel.setCameraInfo(arg_71_0, arg_71_1, arg_71_2)
	local var_71_0

	if type(arg_71_1) == "string" then
		local var_71_1 = arg_71_1

		var_71_0 = VERIFY(playermodel_camera_aide[var_71_1])
		arg_71_0.cameraName = var_71_1
	else
		var_71_0 = arg_71_1
		arg_71_0.cameraName = var_71_0 and var_71_0.name or "Unnamed"
	end

	arg_71_0.cameraInfo = var_71_0

	ASSERT(not var_71_0 or type(var_71_0) == "table")
	arg_71_0:queueAnimation(var_71_0)

	arg_71_0.cameraInstant = arg_71_2
end

function PlayerModel.debugCameraToPlayerCamera(arg_72_0, arg_72_1)
	arg_72_0.debugFlightCamera = arg_72_1
end

function PlayerModel.updateCamera(arg_73_0, arg_73_1, arg_73_2, arg_73_3)
	local var_73_0 = arg_73_0.cameraInfo

	if not var_73_0 then
		return
	end

	if not arg_73_0.currentRotation then
		arg_73_0.currentRotation = 0
	end

	local var_73_1 = arg_73_0.rigInstance:getRootNode()
	local var_73_2 = var_73_1.position
	local var_73_3
	local var_73_4 = var_73_0.fov
	local var_73_5 = var_73_0.joints
	local var_73_6 = var_73_0.frameJoints
	local var_73_7 = var_73_0.nearClip or 0.1
	local var_73_8 = var_73_0.farClip or 10
	local var_73_9

	if var_73_0.rotatePlayer then
		var_73_2 = native.vec3.Zero()
	else
		arg_73_0.playerModelSkeleton:setYRotation(0)
	end

	local var_73_10 = var_73_0.scaleHack and var_73_1:getFrame().s.x or 1

	if var_73_5 then
		local var_73_11 = arg_73_0:getJoint(var_73_5[1])
		local var_73_12 = arg_73_0:getJoint(var_73_5[2])
		local var_73_13 = var_73_11.position
		local var_73_14 = var_73_12.position
		local var_73_15 = var_73_0.jointYOffsets

		if var_73_15 then
			var_73_13 = var_73_13 + native.vec3.YAxis() * var_73_15[1]
			var_73_14 = var_73_14 + native.vec3.YAxis() * var_73_15[2]
		end

		var_73_3 = (var_73_13 + var_73_14) * 0.5

		if var_73_6 then
			var_73_9 = math.abs(var_73_13.y - var_73_14.y) * 0.5
		end
	else
		var_73_3 = var_73_2
	end

	local var_73_16 = var_73_3
	local var_73_17 = native.vec3(var_73_0.preLookAtOffset[1], var_73_0.preLookAtOffset[2], var_73_0.preLookAtOffset[3])
	local var_73_18 = var_73_0.postLookAtOffset and native.vec3(var_73_0.postLookAtOffset[1], var_73_0.postLookAtOffset[2], var_73_0.postLookAtOffset[3]) or native.vec3.Zero()
	local var_73_19 = var_73_0.shadowExtent

	ASSERT(var_73_19)

	if arg_73_0.debugFlightCamera then
		var_73_4 = arg_73_0.debugFlightCamera.fov
		var_73_17 = var_73_16 - arg_73_0.debugFlightCamera.dir * native.dot3(var_73_16 - arg_73_0.debugFlightCamera.pos, arg_73_0.debugFlightCamera.dir)
		var_73_17 = native.vec3(var_73_17.x, var_73_17.y, var_73_17.z / var_73_10)
		var_73_17 = native.vec3(var_73_17.x, var_73_17.y, var_73_17.z - var_73_9 / math.tan(math.rad(0.5 * var_73_4)))
		var_73_17 = native.vec3(var_73_17.x, var_73_17.y, var_73_17.z - var_73_7)
		var_73_18 = native.vec3.Zero()
	end

	if var_73_6 then
		var_73_17 = var_73_17 + native.vec3(0, 0, var_73_7 + var_73_9 / math.tan(math.rad(0.5 * var_73_4)))
	end

	if not arg_73_0.cameraInstant and not arg_73_0.debugFlightCamera then
		local var_73_20 = arg_73_0.previousPreLookAtOffset or var_73_17
		local var_73_21 = arg_73_0.previousPostLookAtOffset or var_73_18
		local var_73_22 = arg_73_0.previousTarget or var_73_16
		local var_73_23 = arg_73_0.previousFov or var_73_4
		local var_73_24 = arg_73_0.previousShadowExtent or var_73_19

		var_73_4, arg_73_0.fovVelocity = native.smoothDamp1(var_73_23, var_73_4, arg_73_0.fovVelocity or 0, 0.2, 100, arg_73_3)
		var_73_17, arg_73_0.preLookAtOffsetVelocity = native.smoothDamp3(var_73_20, var_73_17, arg_73_0.preLookAtOffsetVelocity or native.vec3.Zero(), 0.2, 100, arg_73_3)
		var_73_18, arg_73_0.postLookAtOffsetVelocity = native.smoothDamp3(var_73_21, var_73_18, arg_73_0.postLookAtOffsetVelocity or native.vec3.Zero(), 0.2, 100, arg_73_3)
		var_73_16, arg_73_0.targetVelocity = native.smoothDamp3(var_73_22, var_73_16, arg_73_0.targetVelocity or native.vec3.Zero(), 0.2, 100, arg_73_3)
		var_73_19, arg_73_0.shadowExtentVelocity = native.smoothDamp3(var_73_24, var_73_19, arg_73_0.shadowExtentVelocity or native.vec3.Zero(), 0.08, 100, arg_73_3)
	end

	local var_73_25 = {
		var_73_16,
		var_73_19
	}
	local var_73_26 = var_73_16 + native.vec3(var_73_17.x, var_73_17.y, var_73_17.z * var_73_10)
	local var_73_27 = native.safenormalize3(var_73_16 - var_73_26, -native.vec3.XAxis())
	local var_73_28 = var_73_26 + native.vec3(var_73_18.x, var_73_18.y * var_73_10, var_73_18.z)

	if var_73_0.rotatePlayer then
		arg_73_0.playerModelSkeleton:setYRotation(arg_73_0.currentRotation)
	else
		var_73_28 = native.rotateAroundYByAngle(var_73_28 - var_73_16, arg_73_0.currentRotation) + var_73_16
		var_73_27 = native.rotateAroundYByAngle(var_73_27, arg_73_0.currentRotation)
	end

	if arg_73_2 then
		arg_73_2.name = arg_73_0.cameraName
		arg_73_2.pos = var_73_28
		arg_73_2.dir = var_73_27
		arg_73_2.fov = var_73_4
		arg_73_2.near = var_73_7
		arg_73_2.far = var_73_8
		arg_73_2.bounds = var_73_25
	end

	arg_73_0.previousFov = var_73_4
	arg_73_0.previousPreLookAtOffset = var_73_17
	arg_73_0.previousPostLookAtOffset = var_73_18
	arg_73_0.previousTarget = var_73_16
	arg_73_0.previousShadowExtent = var_73_19
end

function PlayerModel.updateRotation(arg_74_0, arg_74_1, arg_74_2, arg_74_3, arg_74_4, arg_74_5)
	local var_74_0 = arg_74_0.cameraInfo
	local var_74_1 = arg_74_0.draw
	local var_74_2 = arg_74_0.rotationEnabled

	if not var_74_0 then
		return
	end

	local var_74_3 = arg_74_0.playerModelRotation
	local var_74_4 = assert(var_74_0.mouseRegion, "camera has no mouse region!")

	var_74_3:update(arg_74_1, arg_74_2, arg_74_3, arg_74_4, arg_74_5, var_74_2, var_74_4)

	local var_74_5 = var_74_3:getDeltaRotation()
	local var_74_6 = arg_74_0.currentRotation or 0
	local var_74_7

	if arg_74_0.instantRotation then
		var_74_6, var_74_7 = var_74_6 + var_74_5, var_74_5
	else
		var_74_7, arg_74_0.rotationVelocity = native.smoothDamp1(0, var_74_5, arg_74_0.rotationVelocity or 0, 0.1, 720, arg_74_3)
		var_74_6 = (var_74_6 + var_74_7) % 360
	end

	arg_74_0.currentRotation = var_74_6

	var_74_3:setDeltaRotation(var_74_5 - var_74_7)
end

function PlayerModel.getAnimationProvider(arg_75_0)
	if arg_75_0.playerModelAnimation then
		return arg_75_0.playerModelAnimation.characterAnimator:getAnimationProvider()
	end

	return nil
end

function PlayerModel.getSkeleton(arg_76_0)
	if arg_76_0.skeletonModifier then
		return arg_76_0.skeletonModifier.skeleton
	end

	return nil
end
