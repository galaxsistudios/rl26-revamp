import("base.controller.controller")

local var_0_0 = controller.Controller

-- reduce-ai-dummy-half-scoots: a marker who is flagged offside walks to his
-- marker spot in this controller (TackleMarkerHuman inherits it). Stock only
-- clears the flag when the ball is played, so a marker standing square on his
-- spot could stay offside (yellow) the whole play-the-ball. Clear it once he's
-- actually there and has stopped.
local ClearOffsideOnArrival = true
-- Within this far (m) of the marker spot...
local ArriveDistance = 0.75
-- ...and moving slower than this (m/s).
local ArriveSpeed = 1.5

-- Debug: log arrivals and whether the clear held, to reduce_scoots_debug.txt
-- (game folder). Turn off for release.
local DebugLog = true

local function debugWrite(arg_0_0)
	if not DebugLog then
		return
	end

	pcall(function()
		local var_0_1 = io.open("reduce_scoots_debug.txt", "a")

		if var_0_1 then
			var_0_1:write(os.date("%H:%M:%S"), " ", arg_0_0, "\n")
			var_0_1:flush()
			var_0_1:close()
		end
	end)
end

controller.controllerclass("TackleMarkerAi", var_0_0, function(arg_1_0)
	var_0_0.init(arg_1_0)
end)

function TackleMarkerAi.onEnter(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7, arg_5_8, arg_5_9, arg_5_10)
	arg_5_0.arrivedAt = nil
	arg_5_0.checkedAfterClear = false
end

-- Cleared and no longer flagged: the flowchart moves him on to the ready /
-- cover marker controllers, so the 0.2 s check below never runs.
function TackleMarkerAi.onExit(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8, arg_6_9, arg_6_10)
	if arg_6_0.arrivedAt and not arg_6_0.checkedAfterClear then
		debugWrite(string.format("MARKER id=%s left TackleMarkerAi %.2fs after arriving (clear held)", tostring(arg_6_5), type(arg_6_9) == "number" and arg_6_9 - arg_6_0.arrivedAt or -1))
	end
end

local function onsideInfo(arg_0_0)
	local var_0_1 = "?"

	pcall(function()
		local var_0_2 = arg_0_0.onsidePosition

		var_0_1 = string.format("%.2f", native.length2(arg_0_0.pos - var_0_2))
	end)

	return var_0_1
end

function TackleMarkerAi.update(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10, arg_2_11)
	local var_2_0 = arg_2_2.knowledgeBank.playerTackleMarkerKnowledgePool

	ASSERT(var_2_0)

	local var_2_1 = var_2_0:get(arg_2_5)

	ASSERT(var_2_1)

	local var_2_2 = var_2_1.markerPosition
	local var_2_3 = var_2_1.markerFacing

	ASSERT(var_2_2)
	ASSERT(var_2_3)

	local var_2_4 = var_2_1.waypoints

	ASSERT(var_2_4)
	arg_2_6:setWaypoints(var_2_4)
	arg_2_6:setMovementTarget(var_2_2, var_2_3)

	local var_2_5 = arg_2_6:getDerivedAttribute("sprint_speed")

	arg_2_6:setMovementSpeed(var_2_5, 0)

	if ClearOffsideOnArrival then
		pcall(function()
			local var_2_6 = arg_2_6.offsideInfo

			if not arg_2_0.arrivedAt then
				local var_2_7 = native.length2(arg_2_6.pos - var_2_2)
				local var_2_8 = native.length2(arg_2_6.velocity)

				if var_2_7 <= ArriveDistance and var_2_8 <= ArriveSpeed then
					arg_2_0.arrivedAt = arg_2_10

					debugWrite(string.format("MARKER id=%s side=%s arrived spot=%.2f speed=%.2f flagged=%s onsideDist=%s -> clear", tostring(arg_2_5), tostring(arg_2_6.side), var_2_7, var_2_8, tostring(var_2_6.flaggedOffside), onsideInfo(arg_2_6)))

					if var_2_6.flaggedOffside then
						var_2_6:clearOffside()
					end
				end
			elseif not arg_2_0.checkedAfterClear and arg_2_10 - arg_2_0.arrivedAt > 0.2 then
				arg_2_0.checkedAfterClear = true

				debugWrite(string.format("MARKER id=%s 0.2s after clear: flagged=%s", tostring(arg_2_5), tostring(var_2_6.flaggedOffside)))
			end
		end)
	end

	return arg_2_0
end
