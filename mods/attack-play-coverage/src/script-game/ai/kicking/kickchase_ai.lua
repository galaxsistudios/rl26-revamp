import("base.controller.controller")

local var_0_0 = controller.Controller

-- attack-play-coverage: master_flowchart_ai.flow also sends the whole kicking team here while a kick is in
-- the air (stock: only the native kick chasers came here; everyone else held the support formation). On a
-- long kick (LongKickDistance+ from the kicker) the side of the field it lands on chases it:
--   * landing within MiddleHalfWidth of the middle: the fullback charges it;
--   * otherwise everyone on that side of the field (|y| >= SideMinY, same sign as the landing spot) sprints
--     at it, keeping ChaserFunnel of their sideways distance so they arrive as a line, StopShort m short (0: at the spot, so they contest the catch);
--   * everyone else runs up to a line LineDepth m short of the landing spot, keeping their width.
-- Short kicks (grubbers, chips) stay stock: everyone here sprints at the landing spot.
local LongKickDistance = 25
local MiddleHalfWidth = 10
local SideMinY = 4
local ChaserFunnel = 0.3
local StopShort = 0
local LineDepth = 10
local LineWidthScale = 0.85
local ProjectSeconds = 2.5
local UpdateInterval = 0.25
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

-- Controller times are native Time objects: work in seconds.
local function secs(arg_0_0)
	if type(arg_0_0) == "number" then
		return arg_0_0
	end

	local var_0_0, var_0_1 = pcall(function()
		return arg_0_0:ToSeconds()
	end)

	return var_0_0 and type(var_0_1) == "number" and var_0_1 or tonumber(arg_0_0) or 0
end

local function toField(arg_0_0)
	if type(arg_0_0) == "vec3" then
		return native.vec2(arg_0_0.x, arg_0_0.z)
	end

	return arg_0_0
end

-- Last kick seen (shared by the team's controllers): { target, kickPos, long, middle }.
local var_0_1 = {}

-- The kick's landing spot: ballInfo.nextBouncePosition (before it bounces), else the kick target, else the
-- ball. A candidate only counts if it is at least 3 m ahead of the kicker: the in-play kick entity's
-- kickTargetPosition is the aiming target and was (1, 0) for a punt from 29.5 m, sending the team 35 m back.
local function landingSpot(arg_0_0, arg_0_1, arg_0_2, arg_0_3)
	local var_0_0 = arg_0_0.knowledgeBank.ballInfo
	local var_0_1 = {}

	if not var_0_0.hasBounced and var_0_0.nextBouncePosition then
		table.insert(var_0_1, {
			toField(var_0_0.nextBouncePosition),
			"bounce"
		})
	end

	-- (the kick entity's kickTargetPosition is the aiming target and read (1, 0) for punts; project the ball's
	-- ground velocity instead)
	local var_0_4 = toField(var_0_0.position)
	local var_0_5 = var_0_0.groundVelocity and toField(var_0_0.groundVelocity)

	if var_0_4 and var_0_5 then
		table.insert(var_0_1, {
			native.vec2(var_0_4.x + var_0_5.x * ProjectSeconds, math.max(-33, math.min(33, var_0_4.y + var_0_5.y * ProjectSeconds))),
			"projected"
		})
	end

	table.insert(var_0_1, {
		toField(var_0_0.position),
		"ball"
	})

	for iter_0_0, iter_0_1 in ipairs(var_0_1) do
		local var_0_3 = iter_0_1[1]

		if var_0_3 and (var_0_3.x - arg_0_2.x) * arg_0_3 >= 3 then
			return var_0_3, iter_0_1[2]
		end
	end

	return nil, "none ahead"
end

local function kickInfo(arg_0_0, arg_0_1, arg_0_2, arg_0_3, arg_0_4)
	local var_0_2 = arg_0_1:getInPlayKickEntity()
	local var_0_7 = var_0_2 and var_0_2.kickerId
	local var_0_8 = secs(arg_0_4)
	local var_0_9 = arg_0_3:getPlayDir().x >= 0 and 1 or -1

	-- Same kick (same kicker, within 8 s): reuse the classification, refresh the landing spot.
	if var_0_1.kicker == var_0_7 and var_0_1.time and var_0_8 - var_0_1.time < 8 and var_0_8 >= var_0_1.time then
		local var_0_10 = landingSpot(arg_0_0, arg_0_1, var_0_1.kickPos, var_0_9)

		var_0_1.target = var_0_10 or var_0_1.target

		return var_0_1
	end

	local var_0_4

	pcall(function()
		local var_0_5 = var_0_7 and arg_0_2:getGameObject(var_0_7)

		var_0_4 = var_0_5 and var_0_5.pos
	end)

	var_0_4 = var_0_4 or toField(arg_0_0.knowledgeBank.ballInfo.position)

	local var_0_3, var_0_11 = landingSpot(arg_0_0, arg_0_1, var_0_4, var_0_9)

	if not var_0_3 then
		debugWrite(string.format("KICKCHASE kick from (%.1f,%.1f): no landing spot ahead -> run up", var_0_4.x, var_0_4.y))

		var_0_1 = {
			kicker = var_0_7,
			kickPos = var_0_4,
			time = var_0_8,
			long = false
		}

		return var_0_1
	end

	local var_0_6 = math.sqrt((var_0_3.x - var_0_4.x) ^ 2 + (var_0_3.y - var_0_4.y) ^ 2)

	var_0_1 = {
		kicker = var_0_7,
		target = var_0_3,
		kickPos = var_0_4,
		time = var_0_8,
		long = var_0_6 >= LongKickDistance,
		middle = math.abs(var_0_3.y) < MiddleHalfWidth
	}

	debugWrite(string.format("KICKCHASE kick from (%.1f,%.1f) to (%.1f,%.1f) [%s] dist=%.0f %s", var_0_4.x, var_0_4.y, var_0_3.x, var_0_3.y, var_0_11, var_0_6, var_0_1.long and (var_0_1.middle and "long/middle -> fullback" or "long/side " .. (var_0_3.y > 0 and "+y" or "-y")) or "short -> stock"))

	return var_0_1
end

local function isFullBack(arg_0_0, arg_0_1)
	local var_0_2 = false

	pcall(function()
		var_0_2 = arg_0_0:getAssignedRole(arg_0_1) == native.EAssignedRole.FullBack
	end)

	return var_0_2
end

controller.controllerclass("KickChaseAi", var_0_0, function(arg_1_0)
	var_0_0.init(arg_1_0)
end)

function KickChaseAi.onEnter(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	arg_2_0.updateTime = arg_2_9
end

function KickChaseAi.updateMovement(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	return true
end

local function chaseUpdate(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7, arg_4_8, arg_4_9, arg_4_10, arg_4_11)
	if arg_4_10 < arg_4_0.updateTime then
		return arg_4_0
	end

	arg_4_0.updateTime = arg_4_10 + UpdateInterval

	local var_4_0, var_4_1 = pcall(kickInfo, arg_4_2, arg_4_7, arg_4_8, arg_4_6, arg_4_10)
	local var_4_5 = arg_4_6:getPlayDir().x >= 0 and 1 or -1
	local var_4_6 = arg_4_6.pos

	if not var_4_0 or not var_4_1 or not var_4_1.target then
		-- No landing spot ahead of the kicker: run up 8 m, never back.
		local var_4_3 = native.CMoveToTarget(arg_4_5, native.vec2(var_4_6.x + var_4_5 * 8, var_4_6.y), arg_4_10, arg_4_2)

		var_4_3.speed = arg_4_6:getDerivedAttribute("run_speed")

		arg_4_11:add(native.CMovementRequest(arg_4_5, arg_4_3:alloc(), var_4_3))

		if not var_4_0 and not arg_4_0.kickErrorLogged then
			arg_4_0.kickErrorLogged = true

			debugWrite("KICKCHASE kickInfo ERROR " .. tostring(var_4_1))
		end

		return arg_4_0
	end

	local var_4_4 = var_4_1.target
	local var_4_7
	local var_4_8
	local var_4_9

	if not var_4_1.long then
		var_4_7, var_4_9 = true, "short"
	elseif var_4_1.middle then
		var_4_7 = isFullBack(arg_4_6, arg_4_7)
		var_4_9 = var_4_7 and "fullback" or "line"
	else
		var_4_7 = var_4_6.y * var_4_4.y > 0 and math.abs(var_4_6.y) >= SideMinY
		var_4_9 = var_4_7 and "side" or "line"
	end

	if var_4_7 then
		local var_4_10 = var_4_1.long and ChaserFunnel or 0

		var_4_8 = native.vec2(var_4_4.x - var_4_5 * StopShort, var_4_4.y + (var_4_6.y - var_4_4.y) * var_4_10)
	else
		local var_4_12 = var_4_4.x - var_4_5 * LineDepth

		-- never back towards his own line
		if (var_4_12 - var_4_6.x) * var_4_5 < 0 then
			var_4_12 = var_4_6.x
		end

		var_4_8 = native.vec2(var_4_12, var_4_6.y * LineWidthScale)
	end

	local var_4_11 = native.CMoveToTarget(arg_4_5, var_4_8, arg_4_10, arg_4_2)

	var_4_11.speed = arg_4_6:getDerivedAttribute(var_4_7 and "max_speed" or "run_speed")

	arg_4_11:add(native.CMovementRequest(arg_4_5, arg_4_3:alloc(), var_4_11))

	if arg_4_0.loggedFor ~= var_4_1 then
		arg_4_0.loggedFor = var_4_1

		debugWrite(string.format("KICKCHASE id=%s %s from=(%.1f,%.1f) to=(%.1f,%.1f)", tostring(arg_4_5), var_4_9, var_4_6.x, var_4_6.y, var_4_8.x, var_4_8.y))
	end

	return arg_4_0
end

function KickChaseAi.update(arg_5_0, ...)
	local var_5_0, var_5_1 = pcall(chaseUpdate, arg_5_0, ...)

	if not var_5_0 and not arg_5_0.errorLogged then
		arg_5_0.errorLogged = true

		debugWrite("KICKCHASE ERROR " .. tostring(var_5_1))
	end

	return arg_5_0
end
