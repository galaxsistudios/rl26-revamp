import("core.camera.camerautil")
import("core.foundation.tablex")
import("design.cutscenes.cutscenes_config")
import("rules.rules.rulesenvironment_cconfig")
import("script-config.design.player_config")

local var_0_0 = rulesenvironment_cconfig.cBoundaryConfig

CAMEO_DOF_NAME = "CameoDOF"
CAMEO_AO_NAME = "CameoAO"

function findActorWithLabel(arg_1_0, arg_1_1)
	if not arg_1_1.actors then
		return
	end

	for iter_1_0, iter_1_1 in ipairs(arg_1_1.actors) do
		ASSERT(iter_1_1.id)
		ASSERT(iter_1_1.label)

		if iter_1_1.label == arg_1_0 then
			return iter_1_1
		end
	end
end

function getActorToMoveRelativeTo(arg_2_0, arg_2_1)
	local var_2_0 = arg_2_0.moveRelativeToActorLabel

	if not var_2_0 then
		return
	end

	local var_2_1 = findActorWithLabel(var_2_0, arg_2_1)

	if var_2_1 then
		return var_2_1
	end

	ASSERT(false, "Camera referencing non-existant actor label " .. var_2_0)
end

function getAutoDofTarget(arg_3_0, arg_3_1, arg_3_2)
	if arg_3_0 == nil or #arg_3_0 == 0 then
		return arg_3_1.actorModel:getJoint("head"):getPosition()
	end

	local var_3_0 = arg_3_2 and 0 or arg_3_1.pos.x
	local var_3_1 = arg_3_2 and 0 or arg_3_1.pos.y
	local var_3_2 = 0

	for iter_3_0, iter_3_1 in ipairs(arg_3_0) do
		local var_3_3 = arg_3_1.actorModel:getJoint(iter_3_1):getPosition()

		var_3_2 = var_3_2 + var_3_3.y

		if arg_3_2 then
			var_3_0 = var_3_0 + var_3_3.x
			var_3_1 = var_3_1 + var_3_3.z
		end
	end

	if arg_3_2 then
		var_3_0 = var_3_0 / #arg_3_0
		var_3_1 = var_3_1 / #arg_3_0
	end

	local var_3_4 = var_3_2 / #arg_3_0

	return (native.vec3(var_3_0, var_3_4, var_3_1))
end

function getGameObjectMatchingName(arg_4_0, arg_4_1, arg_4_2)
	local var_4_0

	for iter_4_0, iter_4_1 in ipairs(arg_4_2) do
		if iter_4_1.label == arg_4_1 then
			local var_4_1 = iter_4_1.id

			var_4_0 = arg_4_0:getGameObject(var_4_1)
		end
	end

	return var_4_0
end

function evaluateCamera(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7, arg_5_8)
	ASSERT(arg_5_0)

	local var_5_0 = VERIFY(arg_5_0.animName)

	if arg_5_3.mirrorCamera then
		var_5_0 = var_5_0 .. "_m"
	end

	local var_5_1 = arg_5_0.jointName or arg_5_0.node

	ASSERT(var_5_1)

	local var_5_2 = getActorToMoveRelativeTo(arg_5_0, arg_5_3)
	local var_5_3 = var_5_2 and var_5_2.id
	local var_5_4
	local var_5_5

	if var_5_3 then
		var_5_4 = arg_5_1:getGameObject(var_5_3)
		var_5_5 = var_5_4:getAnimationProvider()
	elseif arg_5_3.actors and #arg_5_3.actors > 0 then
		var_5_4 = arg_5_1:getGameObject(arg_5_3.actors[1].id)
		var_5_5 = var_5_4:getAnimationProvider()
	end

	local var_5_6

	if arg_5_3.cameraAnimationProvider then
		ASSERT(not var_5_2)

		var_5_6 = arg_5_3.cameraAnimationProvider:getAnimationByName(var_5_0)
	else
		var_5_6 = arg_5_2.cameoCameraAnimationProvider:getAnimationByName(var_5_0)

		if not var_5_6 and var_5_5 then
			var_5_6 = var_5_5:getAnimationByName(var_5_0)
		end
	end

	if not var_5_6 then
		formatPrint("Animation '%s' could not be found by animated camera", var_5_0)

		return true
	end

	if arg_5_6 <= var_5_6:getDuration() then
		local var_5_7 = var_5_6:findRotationChannelId(var_5_1)

		ASSERT(var_5_7 > -1)

		local var_5_8 = var_5_6:findTranslationChannelId(var_5_1)

		ASSERT(var_5_8 > -1)

		local var_5_9 = var_5_6:findScaleChannelId(var_5_1)
		local var_5_10 = var_5_6:evaluate(var_5_8, var_5_7, -1, arg_5_6)
		local var_5_11

		if var_5_2 then
			ASSERT(var_5_3)

			local var_5_12 = var_5_5:getAnimationByName(var_5_2.animName) or var_5_5:getAnimationByName(var_5_0)
			local var_5_13 = var_5_12:getOriginalWorldRootStartFrame()
			local var_5_14 = var_5_12:evaluateWorldRoot(arg_5_6)
			local var_5_15 = var_5_13:transform(var_5_14)
			local var_5_16 = native.frame.fromFrame2(var_5_15):inverse():transform(var_5_10)

			var_5_16.t = var_5_16.t * var_5_4.scale

			local var_5_17 = arg_5_5 + arg_5_6
			local var_5_18 = arg_5_2.pools.animationSequenceDataPool:get(var_5_3)
			local var_5_19 = var_5_18.valid and var_5_18:getWorldRootAtTime(var_5_4:getMotionSet(), var_5_4.scale, var_5_17)

			if not var_5_19 then
				local var_5_20, var_5_21, var_5_22, var_5_23 = var_5_4:getMotionPath():query(var_5_17, var_5_4:getMotionSet())

				var_5_19 = native.CFrame2(var_5_20, var_5_21)
			end

			var_5_11 = native.frame.fromFrame2(var_5_19):transform(var_5_16)
		else
			var_5_11 = arg_5_4:transform(var_5_10)
		end

		arg_5_7.pos = var_5_11.t + native.vec3(0, arg_5_3.yOffset or 0, 0)
		arg_5_7.dir = var_5_11.q.at
		arg_5_7.up = var_5_11.q.up
		arg_5_7.fov = var_5_6:evaluateScale(var_5_9, arg_5_6).x

		local var_5_24 = arg_5_0.fovScaleShortestPlayer
		local var_5_25 = arg_5_0.fovScaleTallestPlayer
		local var_5_26

		if var_5_24 or var_5_25 then
			if var_5_4.scale < 1 and var_5_24 then
				local var_5_27 = math.max(0, var_5_4.scale - native.CPlayerAttributes.MIN_SCALE) / (1 - native.CPlayerAttributes.MIN_SCALE)

				var_5_26 = native.lerp1(var_5_27, var_5_24, 1)
			elseif var_5_4.scale > 1 and var_5_25 then
				local var_5_28 = math.max(0, var_5_4.scale - 1) / (native.CPlayerAttributes.MAX_SCALE - 1)

				var_5_26 = native.lerp1(var_5_28, 1, var_5_25)
			end

			if var_5_26 then
				arg_5_7.fov = arg_5_7.fov * var_5_26
			end
		end

		if arg_5_0.motionPushInFovScale or arg_5_0.motionDollyDistance or arg_5_0.motionSway then
			local var_5_motionT = math.min(1, math.max(0, arg_5_6 / math.max(var_5_6:getDuration(), 0.001)))
			local var_5_motionEase = var_5_motionT * var_5_motionT * (3 - 2 * var_5_motionT)

			if arg_5_0.motionPushInFovScale then
				arg_5_7.fov = arg_5_7.fov * native.lerp1(var_5_motionEase, 1, arg_5_0.motionPushInFovScale)
			end

			if arg_5_0.motionDollyDistance then
				arg_5_7.pos = arg_5_7.pos + arg_5_7.dir * (arg_5_0.motionDollyDistance * var_5_motionEase)
			end

			if arg_5_0.motionSway then
				local var_5_motionRight = native.cross3(arg_5_7.up, arg_5_7.dir)

				arg_5_7.pos = arg_5_7.pos + var_5_motionRight * (math.sin(arg_5_6 * 0.9) * arg_5_0.motionSway) + arg_5_7.up * (math.sin(arg_5_6 * 1.3 + 1) * arg_5_0.motionSway * 0.6)
			end
		end

		if arg_5_0.near then
			arg_5_7.near = arg_5_0.near
		else
			local var_5_29 = arg_5_8:closestBoundary(arg_5_7.pos:tovec2(), 0)
			local var_5_30 = arg_5_8:outOfBounds(arg_5_7.pos:tovec2(), 0)
			local var_5_31 = cutscenes_config.default_near

			if var_5_30 then
				var_5_31 = arg_5_7.autoNearClip and var_5_29 + 0.1 or arg_5_7.near
			end

			arg_5_7.near = var_5_31
		end

		if arg_5_0.far then
			arg_5_7.far = arg_5_0.far
		else
			arg_5_7.far = cutscenes_config.default_far
		end

		local var_5_32 = arg_5_2.renderer.dofStage
		local var_5_33 = var_5_32:peekSettings(CAMEO_DOF_NAME)

		if var_5_33 then
			if arg_5_0.dof then
				local var_5_34 = 1
				local var_5_35 = arg_5_6 * 30

				for iter_5_0 = 2, #arg_5_0.dof do
					if var_5_35 < arg_5_0.dof[iter_5_0].frame then
						break
					end

					var_5_34 = iter_5_0
				end

				local var_5_36 = arg_5_0.dof[var_5_34]
				local var_5_37
				local var_5_38 = var_5_36.targetActor ~= nil and getGameObjectMatchingName(arg_5_1, var_5_36.targetActor, arg_5_3.actors) or var_5_4

				if var_5_38 ~= nil then
					local var_5_39 = var_5_36.autoDofJoints
					local var_5_40 = var_5_36.useAllJointPos
					local var_5_41 = getAutoDofTarget(var_5_39, var_5_38, var_5_40)

					var_5_37 = native.distance3(var_5_11.t, var_5_41)
				end

				local var_5_42 = var_5_36.intensity
				local var_5_43 = var_5_36.focusDistance == "auto" and var_5_37 or var_5_36.focusDistance
				local var_5_44 = var_5_36.focusArea
				local var_5_45 = var_5_36.focusTransition
				local var_5_46 = var_5_36.nearIntensity
				local var_5_47 = var_5_36.aperture

				if var_5_34 < #arg_5_0.dof then
					local var_5_48 = arg_5_0.dof[var_5_34 + 1]
					local var_5_49 = var_5_48.frame - var_5_36.frame
					local var_5_50 = var_5_49 > 0 and (var_5_35 - var_5_36.frame) / var_5_49 or 0
					local var_5_51
					local var_5_52 = var_5_48.targetActor ~= nil and getGameObjectMatchingName(arg_5_1, var_5_48.targetActor, arg_5_3.actors) or var_5_4

					if var_5_52 ~= nil then
						local var_5_53 = var_5_48.autoDofJoints
						local var_5_54 = var_5_36.useAllJointPos
						local var_5_55 = getAutoDofTarget(var_5_53, var_5_52, var_5_54)

						var_5_51 = native.distance3(var_5_11.t, var_5_55)
					end

					local var_5_56 = var_5_48.intensity
					local var_5_57 = var_5_48.focusDistance == "auto" and var_5_51 or var_5_48.focusDistance

					var_5_33.intensity = native.lerp1(var_5_50, VERIFY(var_5_42), VERIFY(var_5_56))
					var_5_33.focusDistance = native.lerp1(var_5_50, VERIFY(var_5_43), VERIFY(var_5_57))

					local var_5_58 = var_5_48.nearIntensity

					var_5_33.nearIntensity = native.lerp1(var_5_50, VERIFY(var_5_46), VERIFY(var_5_58))

					local var_5_59 = var_5_48.aperture

					if var_5_47 then
						var_5_33.aperture = native.lerp1(var_5_50, VERIFY(var_5_47), VERIFY(var_5_59))
					end
				else
					var_5_33.focusDistance = VERIFY(var_5_43)
					var_5_33.intensity = VERIFY(var_5_42)
					var_5_33.nearIntensity = VERIFY(var_5_46)

					if var_5_47 then
						var_5_33.aperture = var_5_47
					end
				end
			else
				ASSERT(var_5_4, debugFormat("A target id must be specified to use automatic target-based DOF on camera, which is required if the camera doesn't manually specify DOF settings. animName: %s, jointName: %s", var_5_0, var_5_1))

				var_5_33.focusDistance = native.distance3(var_5_11.t, var_5_4.pos3)
			end

			var_5_32:pokeSettings(var_5_33, CAMEO_DOF_NAME)

			arg_5_7.dofStage = var_5_32
		end

		return true
	else
		return false
	end
end

Class("AnimatedCamera", function(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7)
	ASSERT(arg_6_1)

	arg_6_0.name = "AnimatedCamera"
	arg_6_0.animatedCameraParams = arg_6_2

	local var_6_0 = native.CIdSet()

	if arg_6_2.lineOfSightCheckIdTable then
		for iter_6_0, iter_6_1 in pairs(arg_6_2.lineOfSightCheckIdTable) do
			var_6_0:insert(iter_6_1)
		end
	end

	arg_6_0.rng = native.Random(VERIFY(arg_6_2.randomSeed))
	arg_6_0.lineOfSightCheckIdSet = var_6_0
	arg_6_0.viewObstructedTimer = 0
	arg_6_0.ignoreObstructions = arg_6_2.ignoreObstructions or false
	arg_6_0.transitionToTime = 0
	arg_6_0.transitionFromTime = 0
	arg_6_0.maxTransitionTime = 0
	arg_6_0.pos = native.vec3.Zero()
	arg_6_0.dir = native.vec3.XAxis()
	arg_6_0.up = native.vec3.YAxis()
	arg_6_0.fov = 55
	arg_6_0.autoNearClip = arg_6_2.near and arg_6_2.near == "auto"
	arg_6_0.near = not arg_6_0.autoNearClip and arg_6_2.near or cutscenes_config.default_near
	arg_6_0.far = cutscenes_config.default_far
	arg_6_0.cameraManager = arg_6_1
	arg_6_0.onFinishCallback = arg_6_3
	arg_6_0.onFinishCallbackParams = arg_6_4
	arg_6_0.onCameraChange = arg_6_5
	arg_6_0.stopped = false
	arg_6_0.services = arg_6_6

	if arg_6_2.startTime then
		ASSERT(not arg_6_2.checkOutsideBoundary or arg_6_2.referenceFrame)
		ASSERT(not arg_6_2.moveRelativeToActorLabel or arg_6_2.referenceFrame)
		arg_6_0:setReferenceFrame(arg_6_7, arg_6_2.referenceFrame, arg_6_2.startTime)
	end

	if arg_6_2.checkOutsideBoundary then
		ASSERT(arg_6_6)
		ASSERT(arg_6_7)

		local var_6_1 = arg_6_6.knowledgeBank.timeKnowledge.time
		local var_6_2 = arg_6_0.animatedCameraParams.cameras
		local var_6_3 = 1
		local var_6_4 = arg_6_0.referenceFrame

		arg_6_0:excludeCameraShotsOutsideBounds(var_6_2, arg_6_7, arg_6_6, arg_6_2, var_6_4, var_6_1, var_6_3)
	end

	arg_6_0:extractCameraTimeline()
end)

function AnimatedCamera.stop(arg_7_0)
	arg_7_0.animatedCameraParams.cameraAnimationProvider = nil

	arg_7_0.cameraManager:removeCamera(arg_7_0)

	arg_7_0.stopped = true
end

local function var_0_1(arg_8_0, arg_8_1)
	for iter_8_0, iter_8_1 in pairs(arg_8_0.cameras) do
		if iter_8_1.name and iter_8_1.name == arg_8_1 or iter_8_0 == arg_8_1 then
			return iter_8_0, iter_8_1
		end
	end

	ASSERT(false, "Camera " .. arg_8_1 .. " not found")
end

function AnimatedCamera.extractCameraTimeline(arg_9_0)
	local var_9_0 = arg_9_0.animatedCameraParams
	local var_9_1 = {}

	if var_9_0.cut then
		for iter_9_0, iter_9_1 in ipairs(var_9_0.cut) do
			local var_9_2
			local var_9_3

			if iter_9_1.camera == "break" then
				var_9_2 = "break"
			else
				var_9_2, var_9_3 = var_0_1(var_9_0, iter_9_1.camera)
			end

			local var_9_4 = VERIFY(arg_9_0.startTime)
			local var_9_5
			local var_9_6

			if var_9_3 ~= nil and arg_9_0.excludedCameras ~= nil then
				if arg_9_0.excludedCameras[var_9_2] ~= nil then
					var_9_6 = false
				else
					var_9_6 = true
				end
			else
				var_9_6 = true
			end

			if var_9_6 then
				table.insert(var_9_1, {
					cameraIndex = var_9_2,
					startTime = var_9_4 + iter_9_1.frame / 30,
					transition = iter_9_1.transition,
					shadowHack = iter_9_1.shadowHack
				})
			else
				print("[AnimatedCamera] Cut contained a camera that was out of bounds. Using random valid camera as a fallback")

				var_9_1 = {}

				break
			end
		end
	end

	if #var_9_1 == 0 then
		local var_9_7 = var_9_0.startingCameraIndex

		if not var_9_7 then
			local var_9_8

			for iter_9_2, iter_9_3 in pairs(var_9_0.cut) do
				if var_9_8 == nil then
					var_9_8 = var_0_1(var_9_0, iter_9_3.camera)
				end
			end

			var_9_7 = VERIFY(var_9_8)
		end

		table.insert(var_9_1, {
			transition = "cut",
			cameraIndex = var_9_7,
			startTime = arg_9_0.startTime
		})
	end

	arg_9_0.cameraShots = var_9_1
end

function AnimatedCamera.setMaxTransitionTime(arg_10_0, arg_10_1)
	arg_10_0.maxTransitionTime = arg_10_1
end

function AnimatedCamera.setInitialPosition(arg_11_0, arg_11_1)
	arg_11_0.initialPos = arg_11_1
end

function AnimatedCamera.setInitialTarget(arg_12_0, arg_12_1)
	arg_12_0.initialTarget = arg_12_1
end

function AnimatedCamera.setReferenceFrame(arg_13_0, arg_13_1, arg_13_2, arg_13_3)
	arg_13_0.referenceFrame = arg_13_2
	arg_13_0.startTime = VERIFY(arg_13_3)
end

function AnimatedCamera.dispose(arg_14_0)
	if arg_14_0.onFinishCallback and not arg_14_0.finishCallbackCalled then
		print("ERROR")
		native.breakpoint()
	end

	arg_14_0.cameraShots = nil
	arg_14_0.startTime = nil
end

function AnimatedCamera.onPush(arg_15_0)
	local var_15_0 = arg_15_0.animatedCameraParams
	local var_15_1 = var_15_0.dofStage
	local var_15_2 = var_15_1.currentSettings

	var_15_1:pushSettings(var_15_2, CAMEO_DOF_NAME)

	local var_15_3 = var_15_0.ambientOcclusionStage
	local var_15_4 = var_15_3.currentSettings

	var_15_4.ssaoDisable = false

	var_15_3:pushSettings(var_15_4, CAMEO_AO_NAME)
end

function AnimatedCamera.onPop(arg_16_0)
	local var_16_0 = arg_16_0.animatedCameraParams

	var_16_0.dofStage:removeSettings(CAMEO_DOF_NAME)
	var_16_0.ambientOcclusionStage:removeSettings(CAMEO_AO_NAME)

	if arg_16_0.onFinishCallback and not arg_16_0.finishCallbackCalled then
		arg_16_0.onFinishCallback(arg_16_0.onFinishCallbackParams)

		arg_16_0.finishCallbackCalled = true
	end
end

function AnimatedCamera.registerWithMatchSim(arg_17_0, arg_17_1)
	return
end

function AnimatedCamera.setCareerPlayerObject(arg_18_0, arg_18_1)
	return
end

function AnimatedCamera.reset(arg_19_0)
	return
end

function AnimatedCamera.onUpdate(arg_20_0, arg_20_1, arg_20_2, arg_20_3)
	if arg_20_0.stopped then
		return
	end

	local var_20_0 = arg_20_0.animatedCameraParams
	local var_20_1 = arg_20_2:getMatchSim()

	ASSERT(var_20_1)

	local var_20_2 = VERIFY(var_20_1.simTimeInfo.frameEndTime)
	local var_20_3 = var_20_2 - VERIFY(arg_20_0.startTime)

	if var_20_0.manualTime then
		if not arg_20_0.manualTime then
			arg_20_0.manualTime = 0
		end

		arg_20_0.manualTime = arg_20_0.manualTime + arg_20_1
		var_20_3 = arg_20_0.manualTime
		var_20_2 = arg_20_0.startTime + var_20_3
	end

	local var_20_4
	local var_20_5
	local var_20_6
	local var_20_7
	local var_20_8
	local var_20_9 = arg_20_0.cameraShots
	local var_20_10 = 1

	for iter_20_0 = 2, #var_20_9 do
		if var_20_2 <= var_20_9[iter_20_0].startTime then
			break
		end

		var_20_10 = iter_20_0
	end

	if arg_20_0.viewObstructedToCameraShotIndex then
		var_20_10 = math.max(var_20_10, arg_20_0.viewObstructedToCameraShotIndex)
	end

	if var_20_10 <= #var_20_9 then
		var_20_8 = var_20_9[var_20_10]
		var_20_5 = var_20_8.cameraIndex
		var_20_6 = var_20_8.transition
		var_20_7 = var_20_8.shadowHack
	else
		if not arg_20_0.viewObstructedToCameraIndex then
			local var_20_11 = {}
			local var_20_12 = var_20_9[#var_20_9].cameraIndex

			for iter_20_1, iter_20_2 in ipairs(var_20_0.cameras) do
				if iter_20_2.safe and iter_20_1 ~= var_20_12 then
					table.insert(var_20_11, iter_20_1)
				end
			end

			if #var_20_11 > 0 then
				var_20_5 = var_20_11[arg_20_0.rng:randomInteger(#var_20_11) + 1]
				arg_20_0.viewObstructedToCameraIndex = var_20_5
				var_20_6 = "cut"
			end
		else
			var_20_5 = arg_20_0.viewObstructedToCameraIndex
			var_20_6 = "cut"
		end

		if not var_20_5 then
			var_20_8 = var_20_9[#var_20_9]
			var_20_5 = var_20_8.cameraIndex
			var_20_6 = var_20_8.transition
		end
	end

	local var_20_13 = var_20_0.cameras
	local var_20_14

	if var_20_5 == "break" then
		var_20_14 = {
			breakCamera = true
		}

		local var_20_15

		for iter_20_3 = var_20_10 + 1, #var_20_9 do
			local var_20_16 = var_20_9[iter_20_3]

			if var_20_16.cameraIndex ~= "break" then
				var_20_15 = var_20_16.startTime - var_20_8.startTime

				break
			end
		end

		var_20_14.breakDuration = var_20_15
	else
		var_20_14 = var_20_0.cameras[var_20_5]
	end

	if not arg_20_0.currentCameraIndex or var_20_5 ~= arg_20_0.currentCameraIndex then
		if arg_20_0.onCameraChange then
			local var_20_17 = arg_20_0.currentCameraIndex and var_20_0.cameras[arg_20_0.currentCameraIndex] or nil

			arg_20_0.onCameraChange(var_20_17, var_20_14, var_20_6, arg_20_0.services)
		end

		arg_20_0.currentCameraIndex = var_20_5
	end

	if var_20_14.breakCamera then
		return
	end

	if arg_20_0.shadowHack ~= var_20_7 then
		arg_20_0.shadowHack = var_20_7
	end

	if not evaluateCamera(var_20_14, arg_20_3, arg_20_2, var_20_0, arg_20_0.referenceFrame, arg_20_0.startTime, var_20_3, arg_20_0, var_0_0) and arg_20_0.onFinishCallback then
		arg_20_0.onFinishCallback(arg_20_0.onFinishCallbackParams)

		arg_20_0.finishCallbackCalled = true
	end

	local var_20_18 = false
	local var_20_19 = var_20_14.keepLineOfSightWithActorLabel or var_20_14.moveRelativeToActor
	local var_20_20 = var_20_19 and findActorWithLabel(var_20_19, var_20_0)

	if not var_20_20 and var_20_0.actors and #var_20_0.actors > 0 then
		var_20_20 = var_20_0.actors[1]
	end

	local var_20_21 = var_20_20 and VERIFY(var_20_20.id)

	if var_20_21 then
		local var_20_22 = arg_20_3:getGameObject(var_20_21)
		local var_20_23 = var_20_22.pos
		local var_20_24 = var_20_22.scale or 1
		local var_20_25 = native.CPlayerAttributes.DEFAULT_HEIGHT * 0.01 * var_20_24
		local var_20_26 = var_20_23:tovec3(var_20_25 * 0.75)
		local var_20_27 = arg_20_2.pools
		local var_20_28 = arg_20_0.lineOfSightCheckIdSet:clone()

		var_20_28:remove(var_20_21)

		if not native.getGameObjectsCurrentlyObstructingView(arg_20_0.pos, var_20_26, var_20_28, var_20_27.positionInfoPool, var_20_27.actorModelPool, var_20_27.scalePool, player_config.collisionRadius):isEmpty() then
			var_20_18 = true
		end
	end

	if var_20_18 and not arg_20_0.ignoreObstructions then
		arg_20_0.viewObstructedTimer = arg_20_0.viewObstructedTimer + arg_20_1
	end

	if arg_20_0.viewObstructedTimer > 1 then
		arg_20_0.viewObstructedTimer = 0

		local var_20_29 = arg_20_2.cutsceneListener
		local var_20_30 = var_20_29.currentCutscene
		local var_20_31 = var_20_30 and var_20_30.duration - var_20_30.time or nil

		if var_20_10 == #var_20_9 and var_20_30 and var_20_31 and var_20_31 > 1 then
			local var_20_32 = arg_20_2.uiServices.universe
			local var_20_33 = var_20_32:getGameState()
			local var_20_34 = var_20_32:getMatch()

			var_20_29:changePlayingCutsceneCut(arg_20_2, var_20_34, var_20_33, arg_20_3, var_20_2)
		else
			arg_20_0.viewObstructedToCameraShotIndex = math.min(var_20_10 + 1, #var_20_9)
		end
	end
end

function AnimatedCamera.copyCamera(arg_21_0, arg_21_1)
	camerautil.copyCamera(arg_21_1, arg_21_0.camera)

	arg_21_1.far = arg_21_0.far or cutscenes_config.default_far
	arg_21_1.near = arg_21_0.near or cutscenes_config.default_near
end

local function var_0_2(arg_22_0)
	if 3 > math.abs(arg_22_0.x) then
		return 1 > arg_22_0.y
	end

	return false
end

function AnimatedCamera.excludeCameraShotsOutsideBounds(arg_23_0, arg_23_1, arg_23_2, arg_23_3, arg_23_4, arg_23_5, arg_23_6, arg_23_7)
	local var_23_0 = {}
	local var_23_1 = 1
	local var_23_2 = 999

	for iter_23_0, iter_23_1 in pairs(arg_23_1) do
		ASSERT(iter_23_1)

		local var_23_3 = VERIFY(iter_23_1.animName)
		local var_23_4 = iter_23_1.jointName or iter_23_1.node

		ASSERT(var_23_4)

		local var_23_5 = getActorToMoveRelativeTo(iter_23_1, arg_23_4)
		local var_23_6 = var_23_5 and var_23_5.id
		local var_23_7
		local var_23_8

		if var_23_6 then
			var_23_7 = arg_23_2:getGameObject(var_23_6)
			var_23_8 = var_23_7:getAnimationProvider()
		elseif arg_23_4.actors and #arg_23_4.actors > 0 then
			var_23_7 = arg_23_2:getGameObject(arg_23_4.actors[1].id)
			var_23_8 = var_23_7:getAnimationProvider()
		end

		local var_23_9

		if arg_23_4.cameraAnimationProvider then
			ASSERT(not var_23_5)

			var_23_9 = arg_23_4.cameraAnimationProvider:getAnimationByName(var_23_3)
		else
			var_23_9 = arg_23_3.cameoCameraAnimationProvider:getAnimationByName(var_23_3)

			if not var_23_9 and var_23_8 then
				var_23_9 = var_23_8:getAnimationByName(var_23_3)
			end
		end

		ASSERT(var_23_9, debugFormat("Animation '%s' could not be found by animated camera", var_23_3))

		local var_23_10 = var_23_9:getDuration()

		if arg_23_7 < var_23_10 then
			arg_23_7 = var_23_10
		end

		local var_23_11 = true
		local var_23_12 = var_23_9:findRotationChannelId(var_23_4)
		local var_23_13 = var_23_9:findTranslationChannelId(var_23_4)
		local var_23_14 = var_23_9:findScaleChannelId(var_23_4)

		if var_23_12 == -1 or var_23_13 == -1 or var_23_14 == -1 then
			var_23_11 = false
		end

		if var_23_11 then
			local var_23_15
			local var_23_16 = var_23_9:evaluate(var_23_13, var_23_12, -1, arg_23_7)

			if var_23_5 then
				local var_23_17 = var_23_7.getHandedness == nil or var_23_7:getHandedness() == "right"
				local var_23_18, var_23_19, var_23_20, var_23_21 = var_23_7:getMotionPath():query(arg_23_6, var_23_7:getMotionSet(), var_23_17)

				ASSERT(var_23_6)

				local var_23_22 = var_23_8:getAnimationByName(var_23_5.animName) or var_23_8:getAnimationByName(var_23_3)
				local var_23_23 = var_23_22:getOriginalWorldRootStartFrame()
				local var_23_24 = var_23_22:evaluateWorldRoot(arg_23_7)
				local var_23_25 = var_23_23:transform(var_23_24)
				local var_23_26 = native.frame.fromFrame2(var_23_25):inverse():transform(var_23_16)

				var_23_26.t = var_23_26.t * var_23_7.scale

				local var_23_27 = arg_23_6 + arg_23_7
				local var_23_28 = arg_23_3.pools.animationSequenceDataPool:get(var_23_6)
				local var_23_29 = var_23_28.valid and var_23_28:getWorldRootAtTime(var_23_7:getMotionSet(), var_23_7.scale, var_23_27)

				var_23_29 = var_23_29 or native.CFrame2(var_23_18, var_23_19)
				var_23_15 = native.frame.fromFrame2(var_23_29):transform(var_23_26)
			else
				var_23_15 = arg_23_5:transform(var_23_16)
			end

			local var_23_30 = var_23_15.t:tovec2()
			local var_23_31 = 0
			local var_23_32 = var_0_0:outOfBounds(var_23_30, var_23_31)
			local var_23_33 = var_0_0:closestBoundary(var_23_30, var_23_31)

			if var_23_33 < var_23_2 then
				var_23_2 = var_23_33
				var_23_1 = iter_23_0
			end

			if var_23_32 and iter_23_0 ~= "break" and iter_23_1.cameoSearchCriteria == nil then
				var_23_0[iter_23_0] = true

				formatPrintT("excludingCameraIndex: %t", iter_23_0)
			end
		else
			table.insert(var_23_0, iter_23_0)
			formatPrintT("excludingCameraIndex: %t due to having no valid animation", iter_23_0)
		end
	end

	if tablex.size(var_23_0) > 0 then
		arg_23_0.excludedCameras = var_23_0
	end

	if #var_23_0 == #arg_23_1 then
		arg_23_4.startingCameraIndex = var_23_1
		arg_23_0.near = arg_23_0.autoNearClip and var_23_2 + 0.1 or arg_23_0.near

		print("[AnimatedCamera] WARNING, We have no cameras being fed into this animation, selecting the least problematic camera, this will probably look bad!")
	end
end
