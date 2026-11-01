import("core.requestmodel.request")
import("core.marshalling.types")

local var_0_0 = native.CSimulationRequest

request.requestclass("CutscenePlayEventRequest", var_0_0, function(arg_1_0, arg_1_1)
	var_0_0.init(arg_1_0)

	for iter_1_0, iter_1_1 in pairs(CutscenePlayEventRequest.MemberDefinitions) do
		arg_1_0[iter_1_0] = arg_1_1[iter_1_0]
	end

	if ENABLE_ASSERT then
		local var_1_0 = {}

		for iter_1_2, iter_1_3 in ipairs(arg_1_1.targetIds) do
			ASSERT(not var_1_0[iter_1_3])

			var_1_0[iter_1_3] = true
		end
	end
end).MemberDefinitions = {
	guid = types.Guid,
	cutsceneName = types.ArbitraryString,
	targetIds = types.Array(types.ObjectId),
	hideIds = types.Nilable(types.Array(types.ObjectId)),
	hideLoadingScreen = types.Nilable(types.Boolean),
	primarySide = types.Nilable(types.SignedInteger),
	forceWorldRelative = types.Nilable(types.Boolean),
	onFinished = types.Nilable(types.Ignored),
	onFinishedState = types.Nilable(types.RuleState),
	cutIndex = types.Nilable(types.SignedInteger),
	customOrigin = types.Nilable(types.Frame2),
	forceCustomOrigin = types.Nilable(types.Boolean),
	waneTime = types.Nilable(types.Number),
	-- injury-cutscene-variety: seconds into the animations to start (cutscene_listener.lua
	-- backdates the start, so actors and cameras both start this far in and it ends this much
	-- sooner). Used by the HIA concussion scene (rules/injury/injurycameo_rulestate.lua).
	startOffset = types.Nilable(types.Number),
	mirrorCutsceneAnimations = types.Nilable(types.Boolean),
	hideBall = types.Nilable(types.Boolean),
	useActorFiltering = types.Nilable(types.Boolean),
	ignoreCutsceneVisuals = types.Nilable(types.Boolean),
	activateActors = types.Nilable(types.Boolean),
	ignoreSkipMixins = types.Nilable(types.Boolean),
	randomSeed = types.Nilable(types.SignedInteger),
	activateObjects = types.Nilable(types.Boolean),
	disableVisualReset = types.Nilable(types.Boolean),
	clearPrevious = types.Nilable(types.Boolean),
	onStartPlayback = types.Nilable(types.Ignored),
	skipSequence = types.Nilable(types.ArbitraryString),
	goalPostBounds = types.Nilable(types.Rectangle),
	constrainBounds = types.Nilable(types.Rectangle)
}

function CutscenePlayEventRequest.apply(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5)
	local var_2_0
	local var_2_1 = {
		type = "CutscenePlayEvent",
		time = arg_2_1
	}

	for iter_2_0, iter_2_1 in pairs(CutscenePlayEventRequest.MemberDefinitions) do
		var_2_1[iter_2_0] = arg_2_0[iter_2_0]
	end

	table.insert(arg_2_3, var_2_1)
end
