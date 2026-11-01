import("base.controller.controller")

local var_0_0 = controller.Controller

-- attack-play-coverage: at a kick-off everyone runs placekick_flowchart_ai.flow (the behaviour stays PlaceKick
-- until the catch). The kicking team is in KickOffRunUpAi (one 20 m jog, set on entry) or this controller
-- (stock: idle), so the chasers stood still while the ball was in the air. kickOffChase(), called from both
-- (kickoffrunup_ai.lua in this mod), sprints them at the landing spot once the kick-off is in the air
-- (ballInfo.nextBouncePosition, then the ball once it bounces), keeping KickOffFunnel of their sideways
-- distance from it so they arrive as a line, and aiming KickOffStopShort m before it.
local KickOffFunnel = 0.4
local KickOffStopShort = 2
local UpdateInterval = 0.25
local KickOffMaxAge = 8
local DebugLog = true

local function debugWrite(arg_0_0)
	if not DebugLog then
		return
	end

	pcall(function()
		local var_0_1 = io.open("attack_plays_debug.txt", "a")

		if var_0_1 then
			var_0_1:write(os.date("%H:%M:%S"), " ", arg_0_0, "\n")
			var_0_1:flush()
			var_0_1:close()
		end
	end)
end

local function toField(arg_0_0)
	if type(arg_0_0) == "vec3" then
		return native.vec2(arg_0_0.x, arg_0_0.z)
	end

	return arg_0_0
end

-- Controller times are native Time objects (string.format on one crashed the game, 2026-11-01); the
-- listener's are plain numbers. Everything here works in seconds.
local function secs(arg_0_0)
	if type(arg_0_0) == "number" then
		return arg_0_0
	end

	local var_0_0, var_0_1 = pcall(function()
		return arg_0_0:ToSeconds()
	end)

	if var_0_0 and type(var_0_1) == "number" then
		return var_0_1
	end

	return tonumber(arg_0_0)
end

local function isKickOffSubType(arg_0_0)
	return arg_0_0 ~= nil and (arg_0_0 == native.EDisposalSubType.KickOff or arg_0_0 == native.EDisposalSubType.KickOffDrop)
end

-- Where to run, or nil while the kick-off hasn't been kicked (or has been caught). Second result: why not.
local function chaseTarget(arg_0_0, arg_0_1, arg_0_2)
	local var_0_0 = arg_0_1:getBallEntity()

	if var_0_0:getOwnerId(arg_0_2) then
		return nil, "owned"
	end

	local var_0_1 = arg_0_0.knowledgeBank.ballInfo
	local var_0_2
	local var_0_4

	pcall(function()
		local var_0_3 = var_0_0:getDisposalInfo(arg_0_1, arg_0_2)

		var_0_2 = var_0_3 and var_0_3.disposalSubType
		var_0_4 = var_0_3 and var_0_3.disposalTime
	end)

	-- play_listener.lua stamps _G.APC_KickOffTime on every kick-off disposal event (the ball's disposal
	-- info and ballInfo.newestDisposalSubType are both nil for place kicks).
	local var_0_6 = rawget(_G, "APC_KickOffTime")

	if type(var_0_6) ~= "number" and not isKickOffSubType(var_0_2) and not isKickOffSubType(var_0_1.newestDisposalSubType) then
		return nil, "no kick-off yet"
	end

	-- A re-kick's tee setup still has the last (failed) kick-off as its disposal: only chase a fresh kick.
	local var_0_5 = type(var_0_6) == "number" and var_0_6 or secs(var_0_4) or secs(var_0_1.newestDisposalTime)
	local var_0_7 = secs(arg_0_2)

	-- (negative age = a stamp from an earlier match; game time restarts each match)
	if var_0_5 and var_0_7 and (var_0_7 - var_0_5 > KickOffMaxAge or var_0_7 < var_0_5) then
		return nil, string.format("old kick (%.1fs)", var_0_7 - var_0_5)
	end

	-- not until the ball has actually left the tee (a kick-off disposal event can fire before the kick)
	local var_0_8 = rawget(_G, "APC_KickOffPos")
	local var_0_9 = toField(var_0_1.position)

	if var_0_8 and var_0_9 and native.length2(var_0_9 - var_0_8) < 3 then
		return nil, "ball still on the tee"
	end

	if not var_0_1.hasBounced and var_0_1.nextBouncePosition then
		return toField(var_0_1.nextBouncePosition)
	end

	return toField(var_0_1.position)
end

-- Throttled chase step for a kicking-team player. Returns true once he is chasing.
function kickOffChase(arg_0_0, arg_0_1, arg_0_2, arg_0_3, arg_0_4, arg_0_5, arg_0_6, arg_0_7)
	local var_0_8 = secs(arg_0_6) or 0

	if arg_0_0.nextChase and var_0_8 < arg_0_0.nextChase then
		return arg_0_0.chasing
	end

	arg_0_0.nextChase = var_0_8 + UpdateInterval

	local var_0_0, var_0_1, var_0_2 = pcall(chaseTarget, arg_0_1, arg_0_5, arg_0_6)

	if not var_0_0 then
		if not arg_0_0.chaseLogged then
			arg_0_0.chaseLogged = true

			debugWrite("CHASE kick-off ERROR " .. tostring(var_0_1))
		end

		return false
	end

	if not var_0_1 then
		-- Say why we aren't chasing whenever the reason changes (a few lines per player at most).
		if var_0_2 ~= "owned" and var_0_2 ~= "no kick-off yet" and var_0_2 ~= arg_0_0.lastReason and (arg_0_0.reasonLogs or 0) < 4 then
			arg_0_0.lastReason = var_0_2
			arg_0_0.reasonLogs = (arg_0_0.reasonLogs or 0) + 1

			debugWrite(string.format("CHASE kick-off not chasing id=%s t=%.2f stamp=%s: %s", tostring(arg_0_3), var_0_8, tostring(rawget(_G, "APC_KickOffTime")), tostring(var_0_2)))
		end

		arg_0_0.chasing = false

		return false
	end

	local var_0_3 = arg_0_4:getPlayDir().x >= 0 and 1 or -1
	local var_0_4 = native.vec2(var_0_1.x - var_0_3 * KickOffStopShort, var_0_1.y + (arg_0_4.pos.y - var_0_1.y) * KickOffFunnel)
	local var_0_5 = native.CMoveToTarget(arg_0_3, var_0_4, arg_0_6, arg_0_1)

	var_0_5.speed = arg_0_4:getDerivedAttribute("max_speed")

	arg_0_7:add(native.CMovementRequest(arg_0_3, arg_0_2:alloc(), var_0_5))

	arg_0_0.chasing = true

	if not arg_0_0.chaseLogged then
		arg_0_0.chaseLogged = true

		debugWrite(string.format("CHASE kick-off id=%s side=%s from=(%.1f,%.1f) target=(%.1f,%.1f)", tostring(arg_0_3), tostring(arg_0_4.side), arg_0_4.pos.x, arg_0_4.pos.y, var_0_4.x, var_0_4.y))
	end

	return true
end

-- True if the kick-off is in the air now (onEnter uses it so a re-entry mid-chase doesn't idle him).
function kickOffInAir(arg_0_0, arg_0_1, arg_0_2)
	local var_0_0, var_0_1 = pcall(chaseTarget, arg_0_0, arg_0_1, arg_0_2)

	return var_0_0 and var_0_1 ~= nil
end

controller.controllerclass("KickOffIdleAi", var_0_0, function(arg_1_0)
	var_0_0.init(arg_1_0)
end)

function KickOffIdleAi.onEnter(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	if not kickOffInAir(arg_2_2, arg_2_7, arg_2_9) then
		local var_2_0 = native.CIdleCommand(arg_2_5, arg_2_9, arg_2_2)

		var_2_0.facing = arg_2_6.facing

		arg_2_10:add(native.CMovementRequest(arg_2_5, arg_2_3:alloc(), var_2_0))
	end

	arg_2_0.nextChase = nil
end

function KickOffIdleAi.update(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	pcall(kickOffChase, arg_3_0, arg_3_2, arg_3_3, arg_3_5, arg_3_6, arg_3_7, arg_3_10, arg_3_11)

	return arg_3_0
end
