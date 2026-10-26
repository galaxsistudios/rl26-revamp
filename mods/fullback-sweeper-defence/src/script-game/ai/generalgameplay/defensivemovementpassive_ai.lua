import("ai.tackle.tackleai_mixin")
import("base.controller.controller")
import("script-config.rules.rules.rulesenvironment")

local var_0_0 = controller.Controller

-- fullback-sweeper-defence: stock registers this controller but no flowchart
-- uses it (it did nothing). It is now the defending fullback's sweeper
-- positioning, picked in master_flowchart_ai.flow while the line is intact.
-- He stands behind the ruck at a depth set by the tackle count and field
-- position, holds that depth when the ball is played or passed back, and
-- still tackles anyone who reaches him (TackleAiMixin checks canTackle).

-- Metres behind the defensive line. The line is RuckLineGap behind the ruck.
local RuckLineGap = 10
local EarlyDepth = 20 -- tackles 1-3
local LateDepth = 35 -- tackles 4-6, covering the end-of-set kick
local OppositionEarlyDepth = 15 -- ruck at least OppositionTerritory from our line
local OppositionLateDepth = 22
local OppositionTerritory = 70
-- Ruck closer than this to our line: use the formation spot (the native "10m"
-- graphs put the fullback in the line, level with the ball).
local GoalLineDistance = 15
-- How far into the in-goal he may stand.
local MaxInGoalDepth = 2
-- He retreats with a ball carrier who gains ground past the ruck, but only this
-- far; then he holds and comes up to make the tackle.
local MaxRetreatPastRuck = 5
local CloseDownDistance = 10
-- Fraction of the ball's distance from the middle that he follows sideways.
local LateralFollow = 0.75

-- By fullback id: { side, ruckX, ruckY, refX, logged }.
FullbackSweeperState = {}

-- Debug: one line per play-the-ball per fullback to fullback_sweeper_debug.txt
-- in the game folder. Turn off for release.
local DebugLog = true

local function debugWrite(arg_0_0)
	if not DebugLog then
		return
	end

	pcall(function()
		local var_0_1 = io.open("fullback_sweeper_debug.txt", "a")

		if var_0_1 then
			var_0_1:write(os.date("%H:%M:%S"), " ", arg_0_0, "\n")
			var_0_1:flush()
			var_0_1:close()
		end
	end)
end

controller.controllerclass("DefensiveMovementPassiveAi", var_0_0, function(arg_1_0)
	var_0_0.init(arg_1_0)

	arg_1_0.tackleMixin = tackleai_mixin.TackleAiMixin()
end)

function DefensiveMovementPassiveAi.onEnter(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	return
end

function DefensiveMovementPassiveAi.update(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	local var_3_0 = arg_3_6:getDefensiveKnowledge()

	ASSERT(var_3_0.targetPosition)
	ASSERT(var_3_0.targetFacing)
	ASSERT(var_3_0.movementSpeed)
	ASSERT(var_3_0.targetSpeed)

	local var_3_1 = var_3_0.targetPosition
	local var_3_2 = var_3_0.targetFacing
	local var_3_3 = arg_3_6.pos
	local var_3_4 = arg_3_8:getBallObject().pos2
	-- +1/-1: the direction this fullback's team attacks, so our try line is at -dir * halfFieldLength.
	local var_3_5 = arg_3_6:getPlayDir().x >= 0 and 1 or -1
	local var_3_6 = arg_3_7:getMatchProgressionEntity()
	local var_3_7 = var_3_6.tackleCount or 0
	local var_3_8 = arg_3_4:getComponent("matchInData").matchType.maxTackleCount or 5
	local var_3_9 = arg_3_7:getPlayTheBallEntity()
	local var_3_10 = FullbackSweeperState[arg_3_5]

	if not var_3_10 or var_3_10.side ~= var_3_6.attackingSide then
		var_3_10 = {
			side = var_3_6.attackingSide,
			refX = var_3_4.x
		}
		FullbackSweeperState[arg_3_5] = var_3_10
	end

	-- Reference point: the ruck of the current play-the-ball. In general play it
	-- follows a carrier who gains ground (up to MaxRetreatPastRuck), never a
	-- backward pass.
	-- After each play-the-ball the entity is reset (no player, position 0,0,
	-- state still set) about 2 s later; reading that as a ruck at halfway sent
	-- him off to a wrong spot until the next tackle. playTheBallId is the
	-- tackled player, so a new ruck is detected by position, not by id.
	local var_3_26 = var_3_9 and var_3_9.playTheBallPosition
	local var_3_27 = var_3_26 and var_3_9.playTheBallId ~= nil and var_3_9.playTheBallState ~= native.EPlayTheBallState.None and var_3_9.playTheBallState ~= native.EPlayTheBallState.Complete and (var_3_26.x ~= 0 or var_3_26.y ~= 0)

	if var_3_27 then
		if var_3_10.ruckX == nil or math.abs(var_3_10.ruckX - var_3_26.x) > 0.5 or math.abs((var_3_10.ruckY or 0) - var_3_26.y) > 0.5 then
			var_3_10.ruckX = var_3_26.x
			var_3_10.ruckY = var_3_26.y
			var_3_10.refX = var_3_10.ruckX
			var_3_10.logged = false
		end
	elseif var_3_4.x * var_3_5 < var_3_10.refX * var_3_5 then
		local var_3_11 = var_3_10.ruckX or var_3_10.refX
		local var_3_12 = math.max(var_3_4.x * var_3_5, (var_3_11 * var_3_5) - MaxRetreatPastRuck)

		var_3_10.refX = var_3_12 * var_3_5
	end

	local var_3_13 = var_3_10.refX
	local var_3_14 = rulesenvironment.halfFieldLength + var_3_13 * var_3_5
	local var_3_15 = var_3_7 >= var_3_8 - 2
	local var_3_16

	if var_3_14 >= OppositionTerritory then
		var_3_16 = var_3_15 and OppositionLateDepth or OppositionEarlyDepth
	else
		var_3_16 = var_3_15 and LateDepth or EarlyDepth
	end

	local var_3_17 = var_3_1
	local var_3_18 = var_3_2
	local var_3_19 = "formation"

	if var_3_14 >= GoalLineDistance then
		local var_3_20 = var_3_13 - var_3_5 * (RuckLineGap + var_3_16)
		local var_3_21 = -(rulesenvironment.halfFieldLength + MaxInGoalDepth)

		if var_3_20 * var_3_5 < var_3_21 then
			var_3_20 = var_3_21 * var_3_5
		end

		local var_3_22 = rulesenvironment.halfFieldWidth - 6
		local var_3_23 = native.clamp1(var_3_4.y * LateralFollow, -var_3_22, var_3_22)

		var_3_17 = native.vec2(var_3_20, var_3_23)
		var_3_19 = "sweep"

		-- A carrier who has got close (past the point where he stopped retreating): come up and tackle.
		local var_3_24 = var_3_4.x - var_3_3.x
		local var_3_25 = var_3_4.y - var_3_3.y

		if math.sqrt(var_3_24 * var_3_24 + var_3_25 * var_3_25) < CloseDownDistance and not var_3_27 then
			var_3_17 = var_3_4
			var_3_19 = "closedown"
		end

		var_3_18 = native.safenormalise2(var_3_4 - var_3_3, native.vec2(var_3_5, 0))
	end

	if not var_3_10.logged then
		var_3_10.logged = true

		debugWrite(string.format("id=%s tackle=%d/%d ruckFromLine=%.1f depthBehindLine=%d mode=%s target=(%.1f,%.1f) pos=(%.1f,%.1f)", tostring(arg_3_5), var_3_7, var_3_8, var_3_14, var_3_16, var_3_19, var_3_17.x, var_3_17.y, var_3_3.x, var_3_3.y))
	end

	arg_3_6:setMovementTarget(var_3_17, var_3_18)
	arg_3_6:setMovementSpeed(var_3_0.movementSpeed, var_3_0.targetSpeed)
	arg_3_0.tackleMixin:update(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)

	return arg_3_0
end
