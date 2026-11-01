import("ai.playtheball.playtheball_mixin")
import("base.controller.controller")
import("design.playtheball_config")
import("game.incapacitated.incapacitated_request")
import("rules.playtheball.playtheballentity_request")
import("rules.knockon.knockon_request")
import("script-config.rules.rules.rulesenvironment")

local var_0_0 = controller.Controller

controller.controllerclass("PlayTheBallAi", var_0_0, function(arg_1_0)
	var_0_0.init(arg_1_0)
end)

local var_0_1 = rulesenvironment.halfFieldLength - playtheball_config.getInsideFieldOffset

-- ai-last-tackle-kick: logs the start of each last tackle (tackleCount ==
-- max) and each handover to last_tackle_debug.txt, with the attacking side's
-- active play. A handover with no KICK line since its LAST line = the side ran
-- the last tackle. Turn off for release.
local DebugLog = true

-- Play-the-ball facing: cos of the largest angle off up-field that counts as square (0.9 = ~25 deg), the
-- longest the walk-turn may take, and the low-discipline exception (chance BadFacingMaxChance at 0
-- discipline, falling to 0 at LowDisciplineFacing).
FacingTolerance = 0.9
FacingTurnTimeout = 1.5
LowDisciplineFacing = 0.35
BadFacingMaxChance = 0.25

-- Controller times are native Time objects.
function secs(arg_0_0)
	if type(arg_0_0) == "number" then
		return arg_0_0
	end

	local var_0_0, var_0_1 = pcall(function()
		return arg_0_0:ToSeconds()
	end)

	return var_0_0 and type(var_0_1) == "number" and var_0_1 or nil
end

function facingLog(arg_0_0)
	if not DebugLog then
		return
	end

	pcall(function()
		local var_0_0 = io.open("ptb_decision_debug.txt", "a")

		if var_0_0 then
			var_0_0:write(os.date("%H:%M:%S"), " ", arg_0_0, "\n")
			var_0_0:close()
		end
	end)
end

-- True if he may play the ball now (square, or the rare low-discipline skip); second result true for that
-- skip, which is then called as an error (knock-on).
function facingCheck(arg_0_0, arg_0_1)
	local var_0_0 = true
	local var_0_5 = false

	pcall(function()
		local var_0_1 = native.dot2(arg_0_0.facing, arg_0_0:getPlayDir())

		if var_0_1 >= FacingTolerance then
			return
		end

		local var_0_2 = rawget(_G, "DisciplineState")
		local var_0_3 = var_0_2 and var_0_2.get and var_0_2.get(arg_0_0.id)
		local var_0_4 = false

		if type(var_0_3) == "number" and var_0_3 < LowDisciplineFacing then
			var_0_4 = native.Random(native.Random.FromSystemTime():nextAsSeed()):randomFloatRange(0, 1) < BadFacingMaxChance * (1 - var_0_3 / LowDisciplineFacing)
		end

		var_0_0 = var_0_4
		var_0_5 = var_0_4

		facingLog(string.format("FACING id=%s off by %.0f deg discipline=%s -> %s", tostring(arg_0_0.id), math.deg(math.acos(math.max(-1, math.min(1, var_0_1)))), tostring(var_0_3), var_0_4 and "kept (low discipline)" or "turning"))
	end)

	return var_0_0, var_0_5
end

-- A sloppy (sideways) play-the-ball is an error: raise the stock knock-on (advantage to the defending side,
-- then scrum / handover), once per play-the-ball.
function callSloppyPlayTheBall(arg_0_0, arg_0_1, arg_0_2, arg_0_3, arg_0_4, arg_0_5, arg_0_6)
	if not arg_0_0.sloppyPlay or arg_0_0.sloppyCalled then
		return
	end

	arg_0_0.sloppyCalled = true

	local var_0_0, var_0_1 = pcall(function()
		arg_0_6:add(knockon_request.KnockOnRequest({
			guid = arg_0_1:alloc(),
			knockOnSide = arg_0_3.side,
			offenderId = arg_0_2,
			knockOnPosition = arg_0_3.pos,
			tackleCount = arg_0_4:getMatchProgressionEntity().tackleCount,
			startTime = arg_0_5,
			accidentalKnockOn = false,
			accidentalOffside = false,
			isUmpireWrongCall = false,
			isGreyAreaUmpireCall = false
		}))
	end)

	facingLog(string.format("FACING id=%s sloppy play-the-ball -> knock-on %s", tostring(arg_0_2), var_0_0 and "called" or "FAILED: " .. tostring(var_0_1)))
end

local function debugPlayTheBall(arg_0_0, arg_0_1, arg_0_2, arg_0_3)
	if not DebugLog then
		return
	end

	pcall(function()
		local var_0_4 = arg_0_1.tackleCount

		if var_0_4 < arg_0_2 then
			return
		end

		local var_0_5 = arg_0_0:getSide()
		local var_0_6 = "?"

		pcall(function()
			var_0_6 = arg_0_3:getPlayEntityPair():get(var_0_5):getPlayName()
		end)

		local var_0_7 = arg_0_0:getPlayDir().x >= 0 and 1 or -1
		local var_0_8 = rulesenvironment.halfFieldLength + arg_0_0.pos.x * var_0_7
		local var_0_9 = io.open("last_tackle_debug.txt", "a")

		if var_0_9 then
			var_0_9:write(os.date("%H:%M:%S"), string.format(" %s side=%s tackle=%s/%s fromOwnLine=%.0f play=%s\n", arg_0_2 < var_0_4 and "HANDOVER" or "LAST", tostring(var_0_5), tostring(var_0_4), tostring(arg_0_2), var_0_8, tostring(var_0_6)))
			var_0_9:flush()
			var_0_9:close()
		end
	end)
end

function PlayTheBallAi.onEnter(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	arg_2_0.playTheBallMixin = playtheball_mixin.PlayTheBallMixin()

	local var_2_0 = arg_2_4:getComponent("matchInData")

	ASSERT(var_2_0)

	local var_2_1 = var_2_0.matchType

	ASSERT(var_2_1)

	local var_2_2 = var_2_1.maxTackleCount

	ASSERT(var_2_2)

	local var_2_3 = arg_2_7:getMatchProgressionEntity()

	ASSERT(var_2_3)

	arg_2_0.isHandOver = var_2_2 < var_2_3.tackleCount

	formatPrint("[PlayTheBallAi:onEnter] - isHandOver, %s.", tostring(arg_2_0.isHandOver))
	debugPlayTheBall(arg_2_6, var_2_3, var_2_2, arg_2_7)

	local var_2_4 = arg_2_6.facing
	local var_2_5 = arg_2_6.pos
	local var_2_6 = arg_2_6:getPlayDir()

	ASSERT(var_2_6)

	local var_2_7 = var_2_5.x * var_2_6.x < rulesenvironment.halfFieldLength - playtheball_config.checkInsideFieldOffset

	arg_2_0.notInsideTryArea = var_2_7

	-- ai-last-tackle-kick (lives here: one owner per file): stock hard-coded this to true, so its own
	-- "turn to face up-field first" branch in update never ran and players played the ball facing the
	-- sideline (Tracy, 2026-11-01). Now a real check; update turns him, with a FacingTurnTimeout fallback.
	-- A player with discipline-meter value below LowDisciplineFacing may skip the turn (rare sloppiness).
	local var_2_8, var_2_12 = facingCheck(arg_2_6, arg_2_7)

	arg_2_0.sloppyPlay = var_2_12
	arg_2_0.sloppyCalled = false

	arg_2_0.facingTurnStart = secs(arg_2_9)
	arg_2_0.nextTurnCommand = nil

	arg_2_0.facingCorrectDirection = var_2_8

	local var_2_9 = arg_2_7:getPlayTheBallEntity()

	arg_2_0.triggeredPlayTheBallAction = arg_2_0.triggeredPlayTheBallAction or var_2_9.playTheBallActionRequested

	if var_2_7 and var_2_8 and not arg_2_0.triggeredPlayTheBallAction then
		arg_2_0.triggeredPlayTheBallAction = true

		arg_2_0.playTheBallMixin:onEnter(arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
		callSloppyPlayTheBall(arg_2_0, arg_2_3, arg_2_5, arg_2_6, arg_2_7, arg_2_9, arg_2_10)
		formatPrint("[PlayTheBallAi:onEnter] - Wasn't inside try area and was facing correct direction, playing the ball.")
	elseif not var_2_7 then
		formatPrint("[PlayTheBallAi:onEnter] - Was inside try area.")

		local var_2_10 = {
			isMovingBackIntoPlay = true,
			playTheBallPosition = native.vec2(var_0_1 * var_2_6.x, var_2_5.y)
		}

		arg_2_10:add(playtheballentity_request.MovingBackIntoPlayPlayTheBallRequest(var_2_10))
	elseif not var_2_8 then
		formatPrint("[PlayTheBallAi:onEnter] - Was facing incorrect direction.")
	end

	local var_2_11 = {
		id = arg_2_5,
		startTime = arg_2_9,
		endTime = arg_2_9 + 86400
	}

	arg_2_10:add(incapacitated_request.IncapacitatedRequest(var_2_11))
end

function PlayTheBallAi.update(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	local var_3_0 = arg_3_7:getPlayTheBallEntity()

	arg_3_0.triggeredPlayTheBallAction = arg_3_0.triggeredPlayTheBallAction or var_3_0.playTheBallActionRequested

	if arg_3_0.isHandOver then
		formatPrint("[PlayTheBallAi:update] - isHandOver, not playing the ball.")

		return arg_3_0
	elseif arg_3_0.notInsideTryArea and arg_3_0.facingCorrectDirection and not arg_3_0.triggeredPlayTheBallAction then
		formatPrint("[PlayTheBallAi:update] - inside try area and facing direction, playing the ball.")

		arg_3_0.triggeredPlayTheBallAction = true

		arg_3_0.playTheBallMixin:onEnter(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_10, arg_3_11)
		callSloppyPlayTheBall(arg_3_0, arg_3_3, arg_3_5, arg_3_6, arg_3_7, arg_3_10, arg_3_11)
	elseif not arg_3_0.notInsideTryArea then
		local var_3_1 = arg_3_6:getPlayDir()

		ASSERT(var_3_1)

		local var_3_2 = arg_3_6.pos
		local var_3_3 = native.vec2(var_0_1 * var_3_1.x, var_3_2.y)
		local var_3_4 = var_3_1

		ASSERT(var_3_4:isNormal())

		local var_3_5 = 2
		local var_3_6 = 0

		arg_3_6:setMovementTarget(var_3_3, var_3_4)
		arg_3_6:setMovementSpeed(var_3_5, var_3_6)

		if math.abs(var_3_2.x) <= var_0_1 + 0.25 then
			arg_3_0.notInsideTryArea = true
		end
	elseif not arg_3_0.facingCorrectDirection then
		local var_3_7 = arg_3_6:getPlayDir()
		local var_3_8 = arg_3_6.facing
		local var_3_9 = arg_3_6.pos
		local var_3_13 = secs(arg_3_10)

		-- Turn on the spot with an idle command facing up-field (what PlayTheBallMixin itself uses); stock's
		-- setMovementTarget to his own spot at walk speed barely rotated him (1 s timeouts in the log).
		if var_3_13 and (not arg_3_0.nextTurnCommand or var_3_13 >= arg_3_0.nextTurnCommand) then
			arg_3_0.nextTurnCommand = var_3_13 + 0.3

			pcall(function()
				local var_3_14 = native.CIdleCommand(arg_3_5, arg_3_10, arg_3_2)

				var_3_14.facing = var_3_7

				arg_3_11:add(native.CMovementRequest(arg_3_5, arg_3_3:alloc(), var_3_14))
			end)
		end

		arg_3_0.facingCorrectDirection = native.dot2(var_3_8, var_3_7) > FacingTolerance

		if not arg_3_0.facingCorrectDirection and var_3_13 and arg_3_0.facingTurnStart and var_3_13 - arg_3_0.facingTurnStart > FacingTurnTimeout then
			arg_3_0.facingCorrectDirection = true

			facingLog(string.format("FACING id=%s turn timed out after %.1fs, playing anyway", tostring(arg_3_5), var_3_13 - arg_3_0.facingTurnStart))
		elseif arg_3_0.facingCorrectDirection then
			facingLog(string.format("FACING id=%s turned up-field in %.1fs", tostring(arg_3_5), var_3_13 and arg_3_0.facingTurnStart and var_3_13 - arg_3_0.facingTurnStart or -1))
		end
	end
end
