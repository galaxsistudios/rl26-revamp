import("intermediatelua.props.events")
import("intermediatelua.cloth.goalcloth_config")
import("core.foundation.tablex")

local var_0_0 = {
	goalcloth_config = goalcloth_config
}

function assign_prop(arg_1_0, arg_1_1, arg_1_2)
	local var_1_0 = arg_1_0.getPropNames and arg_1_0:getPropNames()

	local function var_1_1(arg_2_0)
		local var_2_0 = arg_1_1[arg_2_0]

		if var_2_0 ~= nil and (not var_1_0 or var_1_0[arg_2_0]) then
			arg_1_0[arg_2_0] = var_2_0
		elseif arg_2_0 == "group" then
			arg_1_0[arg_2_0] = arg_1_2
		end
	end

	var_1_1("position")
	var_1_1("rotation")
	var_1_1("scale")
	var_1_1("visible")
	var_1_1("ambient")
	var_1_1("useCm")
	var_1_1("cmR")
	var_1_1("cmG")
	var_1_1("cmB")
	var_1_1("cmA")
	var_1_1("animOffset")
	var_1_1("animSwivelExtent")
	var_1_1("animRotateRate")
	var_1_1("animTranslate")
	var_1_1("animTranslateRate")
	var_1_1("baseAnimator")
	var_1_1("fxSpawnJoint")
	var_1_1("fxFile")
	var_1_1("idleAnim")
	var_1_1("eventAnims")
	var_1_1("spriteSize")
	var_1_1("spriteVelocity")
	var_1_1("bounds")
end

function import_props_file(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6)
	local var_3_0 = "intermediatelua.props." .. arg_3_1
	local var_3_1 = load(var_3_0)

	return (import_props_file_fromTable(arg_3_0, var_3_0, var_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6))
end

function import_props_file_fromTable(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7)
	local var_4_0 = {}
	local var_4_1 = native:getEnvironment():argExists("lowdetailcharacters")

	if arg_4_2 then
		local var_4_2 = native.getPlatformString()
		local var_4_3 = {}

		for iter_4_0, iter_4_1 in ipairs(arg_4_2.props) do
			local var_4_4 = iter_4_1.name:gsub("|", "")

			if arg_4_3 then
				for iter_4_2, iter_4_3 in pairs(arg_4_3) do
					if var_4_4 == iter_4_3.name then
						iter_4_1 = tablex.merge(iter_4_1, iter_4_3)

						break
					end
				end
			end

			local var_4_5 = iter_4_1.type
			local var_4_6 = string.find(var_4_5, "goalposts")

			if var_4_6 or not var_4_1 then
				local var_4_7 = "data.props." .. var_4_5:gsub("\\", "/"):gsub("/", "%.")
				local var_4_8 = var_4_3[var_4_7]

				if not var_4_8 then
					var_4_8 = load(var_4_7)
					var_4_3[var_4_7] = var_4_8
				end

				local var_4_9 = native.CModelData.create()

				if var_4_6 then
					var_4_9.motionVectors = true
				end

				if iter_4_1.contributeToSkyLighting then
					var_4_9.contributeToSkyLighting = true
				end

				local var_4_10 = arg_4_0:makeInstance(var_4_8, var_4_5, var_4_9)

				if arg_4_5 then
					table.insert(arg_4_5, var_4_10)
				end

				if arg_4_7 then
					arg_4_7:addAsset(var_4_10.model)
				end

				var_4_10.name = var_4_4

				assign_prop(var_4_10, iter_4_1, arg_4_6)

				var_4_0[#var_4_0 + 1] = var_4_4

				if var_4_8.prop_desc and var_4_8.prop_desc.controller then
					local var_4_11 = var_4_8.prop_desc.controller
					local var_4_12 = native[var_4_11]

					ASSERT(var_4_12, debugFormat("Unknown controller type '%s'", var_4_8.prop_desc.controller))

					local var_4_13 = var_4_8.prop_desc.controllerParams or {}
					local var_4_14 = var_4_12(var_4_13)

					ASSERT(var_4_14, debugFormat("Failed to construct '%s'", var_4_8.prop_desc.controller))

					var_4_10.propControllerType = var_4_11
					var_4_10.propController = var_4_14
				end
			end
		end

		for iter_4_4, iter_4_5 in pairs(var_4_3) do
			_G.unloadPackage(iter_4_4)
		end
	end

	_G.unloadPackage(arg_4_1)

	return var_4_0
end

function register_props_with_match_sim(arg_5_0, arg_5_1)
	local function var_5_0(arg_6_0)
		return function(arg_7_0, ...)
			-- bunker-overturned-try: stadium props react to a provisional try too.
			if (arg_7_0.unsuccessfulAttempt or arg_7_0.videoRefereeRequired) and not arg_7_0.provisionalTry then
				return
			end

			return arg_5_0:onEvent(arg_6_0, arg_7_0, ...)
		end
	end

	local function var_5_1(arg_8_0)
		arg_5_1:registerSolidEventListener(var_5_0(arg_8_0), arg_8_0)
	end

	for iter_5_0, iter_5_1 in ipairs(events.events) do
		var_5_1(iter_5_1)
	end
end

function init_prop_controllers(arg_9_0, arg_9_1)
	local var_9_0 = {
		clothConfigs = var_0_0
	}
	local var_9_1 = arg_9_0.count

	if var_9_1 > 0 then
		for iter_9_0 = 1, var_9_1 do
			local var_9_2 = arg_9_0:getAt(iter_9_0)
			local var_9_3 = var_9_2.propController

			if var_9_3 then
				var_9_3:init(var_9_2, arg_9_1, var_9_0)
			end
		end
	end
end

function reload_prop_controllers(arg_10_0, arg_10_1)
	local var_10_0 = {
		clothConfigs = var_0_0
	}
	local var_10_1 = arg_10_0.count

	if var_10_1 > 0 then
		for iter_10_0 = 1, var_10_1 do
			local var_10_2 = arg_10_0:getAt(iter_10_0)
			local var_10_3 = var_10_2.propController

			if var_10_3 then
				var_10_3:dispose()
				var_10_3:init(var_10_2, arg_10_1, var_10_0)
			end
		end
	end
end

function set_textures(arg_11_0, arg_11_1, arg_11_2, arg_11_3, arg_11_4)
	for iter_11_0, iter_11_1 in ipairs(arg_11_1) do
		arg_11_0:setTexturesOnPropsWithSubstring(iter_11_1, arg_11_2, arg_11_3, arg_11_4)
	end
end

function registerJumbotronScreen(arg_12_0, arg_12_1, arg_12_2)
	for iter_12_0 = 1, arg_12_1.count do
		arg_12_1:getAt(iter_12_0).model:setShaderValues(function(arg_13_0, arg_13_1)
			if arg_13_0.technique:find("es2_videoscreen") then
				arg_13_0:setFloat("g_flipVideoScreenUV", 1)
				arg_13_0:setTexture("col_map", arg_12_2)
				arg_13_0:setFloat("g_autoPan", 0)
			end
		end)
	end
end
