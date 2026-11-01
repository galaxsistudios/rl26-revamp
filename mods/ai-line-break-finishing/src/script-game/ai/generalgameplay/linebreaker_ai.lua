import("base.controller.controller")
import("base.action.action")
import("base.action.action_request")
import("base.action.nilaction_request")
import("base.action.animationfiltering_helper")
import("base.side.sidehelper")
import("ai.taunt.taunt_config")
import("ai.try.tryai_mixin")
import("script-config.design.network_config")
import("script-config.rules.rules.rulesenvironment")

local var_0_0 = controller.Controller
local var_0_1 = network_config.ActionLatency

-- ai-line-break-finishing: the AI ball carrier runs this controller from the
-- moment he breaks the line (master_flowchart_ai.flow: iveBrokenLine). Stock
-- always ran to the native "best interception", whose score includes a pull
-- towards the middle of the goal (weightedDistanceToGoalCentre), and it has no
-- try mixin, so he carried on under the posts every time.
--
-- Now one roll per line break:
--   * PostsChance (10%): stock run to the posts. If nobody can catch him he
--     taunts (showboats) on the way in.
--   * otherwise: same candidate runs, scored without the middle pull, and he
--     grounds the ball as soon as the decision tree says TryAttempt.

PostsChance = 0.1

-- Direct runs: cost per metre of sideways distance between the runner and a candidate run. Without the
-- middle pull many candidates score the same, and a tie once sent a runner 40 m across to the corner.
LateralCostPerMetre = 0.5

-- Rolls by player id -> { roll, time }; reused for RollHoldTime seconds.
BreakRolls = {}
RollHoldTime = 10

-- Taunt window, metres from the try line (stock human taunt uses 20 m).
TauntMaxDistance = taunt_config.TauntDistanceFromTryLine
TauntMinDistance = 6

-- "Almost certain to score": every defender at least this far behind him
-- (along the attacking direction), and none within NearestDefender metres.
SafeBehindMargin = 4
NearestDefender = 7

-- Posts runs ground once he is this close to the middle (or this deep in goal).
PostsGroundHalfWidth = rulesenvironment.goalPostSpacing * 0.5
PostsGroundDepth = 6

-- Debug: one line per line break to line_break_debug.txt in the game folder.
-- Turn off for release.
local DebugLog = true

local function debugWrite(arg_0_0)
	if not DebugLog then
		return
	end

	pcall(function()
		local var_0_1 = io.open("line_break_debug.txt", "a")

		if var_0_1 then
			var_0_1:write(os.date("%H:%M:%S"), " ", arg_0_0, "\n")
			var_0_1:flush()
			var_0_1:close()
		end
	end)
end

local function fmt(arg_0_0)
	if type(arg_0_0) ~= "number" then
		return tostring(arg_0_0)
	end

	return string.format("%.2f", arg_0_0)
end

controller.controllerclass("LineBreakerAi", var_0_0, function(arg_1_0)
	var_0_0.init(arg_1_0)

	arg_1_0.tryMixin = tryai_mixin.TryAiMixin()
end)

-- +1 when attacking towards +x, -1 towards -x.
local function attackSign(arg_0_0)
	local var_0_1 = 1

	pcall(function()
		local var_0_2 = arg_0_0:getPlayDir()

		if var_0_2 and var_0_2.x < 0 then
			var_0_1 = -1
		end
	end)

	return var_0_1
end

-- Metres to the try line (negative once in goal).
local function distanceToTryLine(arg_0_0, arg_0_1)
	return rulesenvironment.halfFieldLength - arg_0_0.pos.x * arg_0_1
end

-- Whether every defender is beaten: all clearly behind him, none close.
local function isCertainToScore(arg_0_0, arg_0_1, arg_0_2)
	local var_0_3 = true

	local var_0_4, var_0_5 = pcall(function()
		local var_0_6 = arg_0_0.knowledgeBank
		local var_0_7 = sidehelper.getOtherSide(arg_0_1.side)
		local var_0_8 = var_0_6.positionInfoPool

		for iter_0_0, iter_0_1 in var_0_6.activeTeamPlayerIdListPair:get(var_0_7):iter() do
			local var_0_9 = var_0_8:get(iter_0_1).position
			local var_0_10 = (var_0_9.x - arg_0_1.pos.x) * arg_0_2
			local var_0_11 = native.length2(var_0_9 - arg_0_1.pos)

			if var_0_10 > -SafeBehindMargin or var_0_11 < NearestDefender then
				var_0_3 = false

				return
			end
		end
	end)

	if not var_0_4 then
		debugWrite("certain check failed: " .. tostring(var_0_5))

		return false
	end

	return var_0_3
end

-- Stock best interception, or (no-posts runs) the candidate that scores best
-- once the middle-of-goal term is taken out of its weight.
local function chooseInterception(arg_0_0, arg_0_1, arg_0_2)
	local var_0_2 = arg_0_0.knowledgeBank.lineBreakerKnowledge
	local var_0_3 = var_0_2:getBestInterception()

	-- Posts runs go straight at the line like a direct run and only bend to the posts (stock target) once in
	-- goal: cutting across in the field of play let the cover catch a winger 13 m out (2026-11-01 log).
	local var_0_10 = arg_0_1.postsRun and (not arg_0_2 or distanceToTryLine(arg_0_2, arg_0_1.attackSign) <= 0)

	if var_0_10 or not var_0_3 then
		return var_0_3
	end

	local var_0_4 = var_0_2:getInterceptions()

	-- The middle-of-goal term is a penalty (<= 0) added to the weight, and only
	-- non-zero near the line. While the stock pick carries none, keep it: the
	-- native pick isn't simply the highest weight, so second-guessing it then
	-- only makes the run worse.
	if not var_0_4 or (var_0_3.weightedDistanceToGoalCentre or 0) == 0 then
		return var_0_3
	end

	local var_0_9 = arg_0_2 and arg_0_2.pos.y

	local function score(arg_1_0)
		local var_1_0 = arg_1_0.weight - (arg_1_0.weightedDistanceToGoalCentre or 0)

		if var_0_9 then
			var_1_0 = var_1_0 - LateralCostPerMetre * math.abs(arg_1_0.interceptionPoint.y - var_0_9)
		end

		return var_1_0
	end

	local var_0_6 = var_0_3
	local var_0_7 = score(var_0_3)

	for iter_0_2, iter_0_3 in pairs(var_0_4) do
		if iter_0_3.interceptionPoint and iter_0_3.weight then
			local var_0_8 = score(iter_0_3)

			if var_0_7 < var_0_8 then
				var_0_6 = iter_0_3
				var_0_7 = var_0_8
			end
		end
	end

	if var_0_6 ~= var_0_3 and not arg_0_1.loggedPick then
		arg_0_1.loggedPick = true

		debugWrite("  pick: stock=(" .. fmt(var_0_3.interceptionPoint.x) .. "," .. fmt(var_0_3.interceptionPoint.y) .. " w=" .. fmt(var_0_3.weight) .. " dc=" .. fmt(var_0_3.weightedDistanceToGoalCentre) .. ") ours=(" .. fmt(var_0_6.interceptionPoint.x) .. "," .. fmt(var_0_6.interceptionPoint.y) .. " w=" .. fmt(var_0_6.weight) .. " dc=" .. fmt(var_0_6.weightedDistanceToGoalCentre) .. ")")
	end

	return var_0_6 or var_0_3
end

local function startTaunt(arg_0_0, arg_0_1, arg_0_2, arg_0_3, arg_0_4, arg_0_5, arg_0_6, arg_0_7, arg_0_8, arg_0_9, arg_0_10)
	local var_0_11 = arg_0_1.actionProducer:getAnimations(taunt_config.ActionSetName)

	if not var_0_11 or var_0_11.count == 0 then
		return false
	end

	var_0_11:filter(animationfiltering_helper.byBallHand(arg_0_0, arg_0_1, arg_0_2, arg_0_3, arg_0_4, arg_0_5, arg_0_6, arg_0_7))

	if var_0_11.count == 0 then
		return false
	end

	local var_0_12 = var_0_11:getRandom()

	if not var_0_12 then
		return false
	end

	local var_0_13 = arg_0_9 + var_0_1
	local var_0_14 = action.createAction("TauntAction", {
		animName = var_0_12.name,
		startTime = var_0_13
	})

	arg_0_10:add(action_request.requestBlendAction(arg_0_6, arg_0_4, arg_0_1.guidManager:alloc(), var_0_14))

	return true, var_0_12.name
end

function LineBreakerAi.onEnter(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	-- One roll per break: the flowchart can drop him out of this controller and
	-- back in during the same break, so reuse a roll made in the last RollHoldTime.
	local var_2_0 = 1
	local var_2_x = BreakRolls[arg_2_5]

	if var_2_x and arg_2_9 and var_2_x.time and arg_2_9 - var_2_x.time <= RollHoldTime then
		var_2_0 = var_2_x.roll
	else
		pcall(function()
			var_2_0 = native.Random(native.Random.FromSystemTime():nextAsSeed()):randomFloatRange(0, 1)
		end)

		BreakRolls[arg_2_5] = {
			roll = var_2_0,
			time = arg_2_9
		}
	end

	arg_2_0.postsRun = var_2_0 < PostsChance
	arg_2_0.tauntDone = false
	arg_2_0.loggedPick = false
	arg_2_0.attackSign = attackSign(arg_2_6)

	arg_2_0.tryMixin:onEnter(arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)

	debugWrite("line break id=" .. tostring(arg_2_5) .. " roll=" .. fmt(var_2_0) .. " mode=" .. (arg_2_0.postsRun and "posts" or "direct") .. " pos=(" .. fmt(arg_2_6.pos.x) .. "," .. fmt(arg_2_6.pos.y) .. ") toLine=" .. fmt(distanceToTryLine(arg_2_6, arg_2_0.attackSign)))
end

function LineBreakerAi.update(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	local var_3_0 = chooseInterception(arg_3_2, arg_3_0, arg_3_6)

	if var_3_0 then
		local var_3_1 = var_3_0.interceptionPoint
		local var_3_2 = native.safenormalize2(var_3_1 - arg_3_6.pos, arg_3_6.facing)

		arg_3_6:setMovementTarget(var_3_1, var_3_2)

		local var_3_3 = arg_3_6:getDerivedAttribute("max_speed")
		local var_3_4 = var_3_3

		arg_3_6:setMovementSpeed(var_3_3, var_3_4)
	end

	local var_3_5 = distanceToTryLine(arg_3_6, arg_3_0.attackSign)

	if arg_3_0.postsRun and not arg_3_0.tauntDone and var_3_5 <= TauntMaxDistance and var_3_5 >= TauntMinDistance and isCertainToScore(arg_3_2, arg_3_6, arg_3_0.attackSign) then
		arg_3_0.tauntDone = true

		local var_3_6, var_3_7 = pcall(startTaunt, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)

		debugWrite("  taunt at toLine=" .. fmt(var_3_5) .. " ok=" .. tostring(var_3_6) .. " " .. tostring(var_3_7))
	end

	-- Direct runs ground whenever the decision tree allows it; posts runs only
	-- once he is between the posts or deep in goal.
	local var_3_8 = not arg_3_0.postsRun or math.abs(arg_3_6.pos.y) <= PostsGroundHalfWidth or var_3_5 <= -PostsGroundDepth

	if var_3_8 and var_3_5 <= 2 then
		if arg_3_0.tauntDone then
			local var_3_9 = arg_3_6:getBlendAction(arg_3_7)

			if var_3_9 and type(var_3_9) == "TauntAction" then
				arg_3_11:add(nilaction_request.createBlendRequest(arg_3_7, arg_3_5))
			end
		end

		arg_3_0.tryMixin:update(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	end

	return arg_3_0
end
