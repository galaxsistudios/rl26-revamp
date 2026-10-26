import("core.foundation.import", "package")

local var_0_0 = {
	{
		name = "intermediatelua.animations.animunits",
		registerCAnimUnitFunction = function(arg_1_0, arg_1_1, arg_1_2, arg_1_3)
			assert(type(arg_1_2) == "CAnimUnit")
			arg_1_0:registerAnimUnit(arg_1_1, arg_1_2, arg_1_3)
		end,
		addFunction = function(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5)
			local var_2_0 = arg_2_0.addAnimation

			if var_2_0 then
				var_2_0(arg_2_0, arg_2_3.animName, arg_2_3, arg_2_1)
			end

			return arg_2_5
		end
	},
	{
		name = "intermediatelua.animations.cutsceneanimunits",
		addFunction = function(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5)
			local var_3_0 = arg_3_0.addAnimation

			if var_3_0 then
				var_3_0(arg_3_0, arg_3_3.animName)
			end

			return arg_3_5
		end
	}
}

local function var_0_1(arg_4_0, arg_4_1)
	local var_4_0 = arg_4_1.actionSet.data

	arg_4_0:addActionSet(var_4_0)
end

local function var_0_2(arg_5_0, arg_5_1)
	local var_5_0 = arg_5_1.animUnits and assert(arg_5_1.animUnits.data) or nil
	local var_5_1 = arg_5_1.motionSet and assert(arg_5_1.motionSet.data) or nil

	for iter_5_0, iter_5_1 in ipairs(var_0_0) do
		local var_5_2 = load(iter_5_1.name).content
		local var_5_3 = {}

		for iter_5_2, iter_5_3 in pairs(var_5_2) do
			if iter_5_3.animationController then
				local var_5_4 = assert(iter_5_3.animationController, "Cannot find animationController for " .. iter_5_2)
				local var_5_5 = assert(native[var_5_4], "No such animation controller: " .. var_5_4).construct(iter_5_2, arg_5_1.animationProvider, arg_5_0, iter_5_3, var_5_1)

				var_5_5:parseMetadata(iter_5_3)
				arg_5_0:addBodyAnimationController(iter_5_2, var_5_5)

				var_5_3[iter_5_2] = var_5_5
			end
		end

		if var_5_0 and var_5_1 then
			for iter_5_4, iter_5_5 in pairs(var_5_3) do
				local var_5_6 = var_5_2[iter_5_4]
				local var_5_7 = assert(var_5_6.anims)
				local var_5_8 = 1

				if iter_5_1.registerCAnimUnitFunction then
					local var_5_9 = 0
					local var_5_10 = var_5_0:findAnimUnitByName(iter_5_4, 0)

					if var_5_10 then
						assert(type(var_5_10) == "CAnimUnit")
						iter_5_1.registerCAnimUnitFunction(iter_5_5, var_5_0, var_5_10, var_5_1)
					end
				end

				for iter_5_6, iter_5_7 in ipairs(var_5_7) do
					var_5_8 = iter_5_1.addFunction(iter_5_5, var_5_6, iter_5_6, iter_5_7, var_5_2, var_5_8)
				end
			end
		end
	end
end

function finaliseBlendAnimationControllerSet(arg_6_0, arg_6_1)
	for iter_6_0, iter_6_1 in arg_6_1.actionSet.data:iter() do
		for iter_6_2, iter_6_3 in iter_6_1:iter() do
			local var_6_0 = iter_6_3.animationControllerName
			local var_6_1 = var_6_0 and arg_6_0:getBlendAnimationController(var_6_0)

			if var_6_1 then
				var_6_1:finalize()
			end
		end
	end
end

function loadBlendAnimationControllerSet(arg_7_0, arg_7_1, arg_7_2)
	local var_7_0 = native.CBlendAnimationControllerSet()
	local var_7_1 = arg_7_2:hold("blendanimcontrollerset")

	arg_7_0:fire(function()
		var_0_1(var_7_0, arg_7_1)
		arg_7_2:releaseHold(var_7_1)
	end)

	return var_7_0
end

function finaliseBodyAnimationControllerSet(arg_9_0)
	local var_9_0 = load("intermediatelua.animations.blendinganimunits").content

	for iter_9_0, iter_9_1 in pairs(var_9_0) do
		arg_9_0:getBodyAnimationController(iter_9_0):finalize()
	end

	package.unloadPackage("intermediatelua.animations.blendinganimunits")
end

function loadBodyAnimationControllerSet(arg_10_0, arg_10_1, arg_10_2, arg_10_3)
	local var_10_0 = arg_10_3:hold("bodyanimcontrollerset")

	arg_10_0:fire(function()
		ASSERT(arg_10_2.animationProvider)
		arg_10_2.animationProvider:update()

		if arg_10_2.cheerleaderAnimationProvider then
			arg_10_2.cheerleaderAnimationProvider:update()
		end

		var_0_2(arg_10_1, arg_10_2)
		arg_10_3:releaseHold(var_10_0)
	end)
end

local function var_0_3(arg_12_0, arg_12_1)
	local var_12_0 = load("intermediatelua.animations.jointclass")

	for iter_12_0, iter_12_1 in pairs(var_12_0.JointClass) do
		arg_12_0:registerJointClass(arg_12_1, iter_12_0)

		for iter_12_2, iter_12_3 in pairs(iter_12_1) do
			arg_12_0:setJointWeight(arg_12_1, iter_12_0, iter_12_2, iter_12_3)
		end
	end

	package.unloadPackage("intermediatelua.animations.jointclass")
end

function loadJointClassSet(arg_13_0, arg_13_1, arg_13_2)
	local var_13_0 = native.CJointClassSet()
	local var_13_1 = arg_13_0.masterAnimationSet
	local var_13_2 = arg_13_2:hold("jointclassset")

	local function var_13_3()
		var_0_3(var_13_0, var_13_1)
		arg_13_2:releaseHold(var_13_2)
	end

	arg_13_1:addCallback(var_13_1, var_13_3)

	return var_13_0
end

function loadPlayerAnimationSets(arg_15_0, arg_15_1)
	return {
		masterAnimSet = arg_15_0:load("animations/master.animset"),
		animationSet = arg_15_0:load("animations/ingame.animset"),
		movementAnimSet = arg_15_0:load("animations/movement.animset"),
		facialAnimSet = arg_15_0:load("animations/facial.animset"),
		tackleAnimSet = arg_15_0:load("animations/tackle.animset"),
		r25TackleAnimSet = arg_15_0:load("animations/r25_tackles.animset"), -- Rugby 25 tackles (tools/r25_import.py)
		r25FacialAnimSet = arg_15_0:load("animations/r25_faces.animset"), -- Rugby 25 faces (tools/r25_import.py)
		rigDeltaAnimSet = arg_15_0:load("animations/rigdelta.animset")
	}
end
