import("ai.collect.dummyhalfcollectball_ai")
import("ai.fend.fendai_mixin")
import("ai.kicking.kickai_mixin")
import("ai.hitup.hitupai_mixin")
import("ai.passing.fakepassai_mixin")
import("ai.passing.passai_mixin")
import("ai.plays.clearplay_request")
import("ai.sidestep.sidestepai_mixin")
import("ai.tackle.drivetackleai_mixin")
import("ai.try.tryai_mixin")
import("base.controller.controller")
import("base.side.sidehelper")
import("game.player.playertype")
import("script-config.rules.rules.rulesenvironment")

local var_0_0 = controller.Controller

-- reduce-ai-dummy-half-scoots: master_flowchart_ai.flow sends a dummy half
-- holding the ball with a marker offside here: that run is the AI scoot.
-- DummyHalfCollectBallAi records each pickup with a dice roll; the scoot is
-- decided here, when the run would start:
--   * situational chance (situationalScootChance): ScootBaseChance times a
--     factor for each situation that applies (offside crowd, retreating
--     defence, near the line, open/shut blind side, own end, hooker speed,
--     late score, scoots already this set, last play), capped,
--   * a crowd scoot runs at the side with the offside defenders.
-- A vetoed scoot keeps the set play (no ClearPlayRequest) and passes as soon
-- as a receiver is known. An allowed scoot sometimes passes after a short run.

-- Fallback chances, only used if the situational chance below fails.
local ScootChance = 0.1
local CrowdScootChance = 0.6

-- Situational scoot chance (2026-11-01): ScootBaseChance times every factor that
-- applies, capped at ScootMaxChance. Each decision logs the factors it used.
local ScootBaseChance = 0.05
local ScootMaxChance = 0.4
-- 3+ defenders offside on one side of the ruck.
local CrowdFactor = 6
-- Defence still backpedalling: RetreatCount+ defenders within RetreatZone m in front of the
-- ruck, moving back faster than RetreatSpeed m/s.
local RetreatFactor = 2.5
local RetreatCount = 3
local RetreatZone = 10
local RetreatSpeed = 1.5
-- Within NearLineDistance m of the opposition try line.
local NearLineFactor = 3
local NearLineDistance = 10
-- Ruck within BlindSideTouchDistance m of touch: at most BlindSideOpenMax defenders on that
-- side (within BlindSideDepth m along the field) = open blind side, more = closed.
local BlindSideTouchDistance = 15
local BlindSideOpenMax = 1
local BlindSideDepth = 15
local BlindSideOpenFactor = 2
local BlindSideClosedFactor = 0.5
-- Own 20 m on the early tackles (tackle count below OwnEndEarlyTackles).
local OwnEndFactor = 0.5
local OwnEndDistance = 20
local OwnEndEarlyTackles = 3
-- His max speed against his team's average: 1 + (ratio - 1) * SpeedSensitivity, clamped.
local SpeedSensitivity = 5
local SpeedFactorMin = 0.6
local SpeedFactorMax = 1.5
-- Last LateGameSeconds of the match: trailing by up to LateTrailMargin, or leading.
local LateGameSeconds = 600
local LateTrailMargin = 12
local LateTrailFactor = 1.5
local LateLeadFactor = 0.5
-- Each scoot already made this set multiplies the chance by this.
local RepeatScootFactor = 0.4
-- Last play: no scoot, unless within LastPlayLineDistance m of the line.
local LastPlayLineDistance = 5

-- Scoots this set, by side -> { count, tackle, time }.
SetScoots = {}
local SetGapTime = 45

local OffsideCrowdCount = 3
-- Defenders this close (m) to the ruck, along the field, count towards a crowd.
local OffsideCrowdRadius = 20
-- Tackle count at the play-the-ball before the last play (no scoot then).
local LastPlayTackleCount = 4
-- Give up waiting for a receiver after this long (s) and run.
local VetoPassTimeout = 1.5
-- A veto holds for this long (s) after it's made: the flowchart can drop him out of HitGapAi
-- and back in a moment later, and that re-entry must not count as a fresh (free) run.
local VetoHoldTime = 4
-- Allowed scoots: chance to pass after a short run, and how long the run is.
local RunThenPassChance = 0.5
local RunThenPassMinTime = 0.8
local RunThenPassMaxTime = 1.4
-- Chance the run-then-pass goes the way he's running (else back the other way).
local RunThenPassSameSideChance = 0.75

controller.controllerclass("HitGapAi", var_0_0, function(arg_1_0)
	var_0_0.init(arg_1_0)

	arg_1_0.passMixin = passai_mixin.PassAiMixin()
	arg_1_0.fakePassMixin = fakepassai_mixin.FakePassAiMixin()
	arg_1_0.kickMixin = kickai_mixin.KickAiMixin()
	arg_1_0.tryMixin = tryai_mixin.TryAiMixin()
	arg_1_0.fendMixin = fendai_mixin.FendAiMixin()
	arg_1_0.hitUpMixin = hitupai_mixin.HitUpAiMixin()
	arg_1_0.sideStepMixin = sidestepai_mixin.SideStepAiMixin()
	arg_1_0.driveTackleMixin = drivetackleai_mixin.DriveTackleAiMixin()
end)

-- Debug: log every decision to reduce_scoots_debug.txt (game folder), to line
-- up with the PTB lines from dummyhalfcollectball_ai.lua. Turn off for release.
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

local function clearPlay(arg_0_0, arg_0_1)
	arg_0_0:add(clearplay_request.ClearPlayRequest({
		side = arg_0_1.side
	}))
end

-- Offside defenders near the ruck on each side of the dummy half (field y).
local function countOffsideDefenders(arg_0_0, arg_0_1, arg_0_2)
	local var_0_3 = 0
	local var_0_4 = 0
	local var_0_5 = sidehelper.getOtherSide(arg_0_2.side)

	for iter_0_0, iter_0_1 in arg_0_0.knowledgeBank.activeTeamPlayerIdListPair:get(var_0_5):iter() do
		local var_0_6 = arg_0_1:getGameObject(iter_0_1, playertype.TypeId)

		if var_0_6 and var_0_6.offsideInfo.flaggedOffside and math.abs(var_0_6.pos.x - arg_0_2.pos.x) <= OffsideCrowdRadius then
			if var_0_6.pos.y > arg_0_2.pos.y then
				var_0_3 = var_0_3 + 1
			else
				var_0_4 = var_0_4 + 1
			end
		end
	end

	return var_0_3, var_0_4
end

-- This side's scoot record for the current set (reset when the tackle count goes
-- back down or after a long gap).
local function setScootRecord(arg_0_0, arg_0_1, arg_0_2)
	local var_0_3 = SetScoots[arg_0_0]

	if not var_0_3 or arg_0_1 < var_0_3.tackle or arg_0_2 - var_0_3.time > SetGapTime then
		var_0_3 = {
			count = 0
		}
		SetScoots[arg_0_0] = var_0_3
	end

	var_0_3.tackle = arg_0_1
	var_0_3.time = arg_0_2

	return var_0_3
end

-- Situational scoot chance: returns the chance and a "name*factor" list for the log.
local function situationalScootChance(arg_0_0, arg_0_1, arg_0_2, arg_0_3, arg_0_4, arg_0_5, arg_0_6, arg_0_7, arg_0_8)
	local var_0_9 = arg_0_2:getPlayDir().x >= 0 and 1 or -1
	local var_0_10 = arg_0_2.pos
	local var_0_11 = rulesenvironment.halfFieldLength - var_0_10.x * var_0_9
	local var_0_12 = rulesenvironment.fieldLength - var_0_11
	local var_0_13 = ScootBaseChance
	local var_0_14 = {}

	local function var_0_15(arg_1_0, arg_1_1)
		var_0_13 = var_0_13 * arg_1_1

		table.insert(var_0_14, string.format("%s*%.2f", arg_1_0, arg_1_1))
	end

	if arg_0_7 then
		var_0_15("crowd", CrowdFactor)
	end

	-- Defenders: backpedalling in front of the ruck, and on the short side near touch.
	local var_0_16 = sidehelper.getOtherSide(arg_0_2.side)
	local var_0_17 = 0
	local var_0_18 = 0
	local var_0_19 = rulesenvironment.halfFieldWidth - math.abs(var_0_10.y)
	local var_0_20 = var_0_10.y >= 0 and 1 or -1

	for iter_0_0, iter_0_1 in arg_0_0.knowledgeBank.activeTeamPlayerIdListPair:get(var_0_16):iter() do
		local var_0_21 = arg_0_4:getGameObject(iter_0_1, playertype.TypeId)

		if var_0_21 then
			local var_0_22 = (var_0_21.pos.x - var_0_10.x) * var_0_9

			if var_0_22 > 0 and var_0_22 <= RetreatZone and var_0_21.velocity.x * var_0_9 > RetreatSpeed then
				var_0_17 = var_0_17 + 1
			end

			if (var_0_21.pos.y - var_0_10.y) * var_0_20 > 0 and math.abs(var_0_22) <= BlindSideDepth then
				var_0_18 = var_0_18 + 1
			end
		end
	end

	if var_0_17 >= RetreatCount then
		var_0_15("retreating" .. var_0_17, RetreatFactor)
	end

	if var_0_11 <= NearLineDistance then
		var_0_15("nearLine", NearLineFactor)
	end

	if var_0_19 <= BlindSideTouchDistance then
		if var_0_18 <= BlindSideOpenMax then
			var_0_15("blindOpen" .. var_0_18, BlindSideOpenFactor)
		else
			var_0_15("blindShut" .. var_0_18, BlindSideClosedFactor)
		end
	end

	if var_0_12 <= OwnEndDistance and arg_0_6 < OwnEndEarlyTackles then
		var_0_15("ownEnd", OwnEndFactor)
	end

	-- His speed against his team's average.
	pcall(function()
		local var_0_23 = 0
		local var_0_24 = 0

		for iter_0_2, iter_0_3 in arg_0_0.knowledgeBank.activeTeamPlayerIdListPair:get(arg_0_2.side):iter() do
			local var_0_25 = arg_0_4:getGameObject(iter_0_3, playertype.TypeId)

			if var_0_25 then
				var_0_23 = var_0_23 + var_0_25:getDerivedAttribute("max_speed")
				var_0_24 = var_0_24 + 1
			end
		end

		if var_0_24 > 0 and var_0_23 > 0 then
			local var_0_26 = arg_0_2:getDerivedAttribute("max_speed") / (var_0_23 / var_0_24)

			var_0_15(string.format("speed%.2f", var_0_26), math.max(SpeedFactorMin, math.min(SpeedFactorMax, 1 + (var_0_26 - 1) * SpeedSensitivity)))
		end
	end)

	-- Late in the match: chasing the game, or protecting a lead.
	pcall(function()
		if arg_0_1:getComponent("matchInfo"):getMatchSecondsRemaining(arg_0_3, arg_0_5) > LateGameSeconds then
			return
		end

		local var_0_27 = arg_0_1:getComponent("matchInData")
		local var_0_28 = arg_0_3:getScoreEntity()
		local var_0_29 = native.ScoreInfo.getScore(var_0_27, var_0_28, arg_0_2.side) - native.ScoreInfo.getScore(var_0_27, var_0_28, var_0_16)

		if var_0_29 < 0 and var_0_29 >= -LateTrailMargin then
			var_0_15("lateTrail", LateTrailFactor)
		elseif var_0_29 > 0 then
			var_0_15("lateLead", LateLeadFactor)
		end
	end)

	if arg_0_8.count > 0 then
		var_0_15("repeat" .. arg_0_8.count, RepeatScootFactor ^ arg_0_8.count)
	end

	if arg_0_6 >= LastPlayTackleCount and var_0_11 > LastPlayLineDistance then
		var_0_15("lastPlay", 0)
	end

	return math.min(var_0_13, ScootMaxChance), table.concat(var_0_14, " ")
end

function HitGapAi.onEnter(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	local var_2_0 = dummyhalfcollectball_ai.DummyHalfPickups
	local var_2_1 = var_2_0[arg_2_5]

	var_2_0[arg_2_5] = nil

	-- Re-entry after a veto on this play-the-ball: still vetoed, no new roll.
	if var_2_1 and var_2_1.vetoed and arg_2_9 <= var_2_1.expires then
		var_2_0[arg_2_5] = var_2_1
		arg_2_0.vetoPass = true
		arg_2_0.runSide = nil
		arg_2_0.runPassAt = nil
		arg_2_0.startTime = arg_2_9
		arg_2_0.vetoRecord = var_2_1

		debugWrite(string.format("HITGAP id=%s veto-reentry, still vetoed", tostring(arg_2_5)))
		arg_2_0.sideStepMixin:onEnter(arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
		arg_2_0.fendMixin:onEnter(arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
		arg_2_0.hitUpMixin:onEnter(arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
		arg_2_0.passMixin:onEnter(arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
		arg_2_0.fakePassMixin:onEnter(arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
		arg_2_0.kickMixin:onEnter(arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
		arg_2_0.tryMixin:onEnter(arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)

		return
	end

	arg_2_0.vetoRecord = nil
	arg_2_0.vetoPass = false
	arg_2_0.runSide = nil
	arg_2_0.runPassAt = nil
	arg_2_0.startTime = arg_2_9

	local var_2_2 = "run"

	if var_2_1 and arg_2_9 <= var_2_1.expires then
		local var_2_3 = native.Random(native.Random.FromSystemTime():nextAsSeed())
		local var_2_4 = arg_2_7:getMatchProgressionEntity().tackleCount
		local var_2_5, var_2_6 = 0, 0

		pcall(function()
			var_2_5, var_2_6 = countOffsideDefenders(arg_2_2, arg_2_8, arg_2_6)
		end)

		local var_2_7 = math.max(var_2_5, var_2_6) >= OffsideCrowdCount
		local var_2_8 = var_2_7 and CrowdScootChance or ScootChance

		if var_2_4 >= LastPlayTackleCount then
			var_2_8 = 0
		end

		local var_2_9 = setScootRecord(arg_2_6.side, var_2_4, arg_2_9)
		local var_2_10 = "fallback"
		local var_2_11, var_2_12, var_2_13 = pcall(situationalScootChance, arg_2_2, arg_2_4, arg_2_6, arg_2_7, arg_2_8, arg_2_9, var_2_4, var_2_7, var_2_9)

		if var_2_11 then
			var_2_8 = var_2_12
			var_2_10 = var_2_13 ~= "" and var_2_13 or "base"
		else
			var_2_10 = "fallback (" .. tostring(var_2_12) .. ")"
		end

		if var_2_1.roll < var_2_8 then
			var_2_9.count = var_2_9.count + 1
			var_2_2 = var_2_7 and "scoot-crowd" or "scoot"

			if var_2_7 then
				arg_2_0.runSide = var_2_5 >= var_2_6 and 1 or -1
			end

			if var_2_3:randomFloatRange(0, 1) < RunThenPassChance then
				arg_2_0.runPassAt = arg_2_9 + var_2_3:randomFloatRange(RunThenPassMinTime, RunThenPassMaxTime)
				arg_2_0.runPassSameSide = var_2_3:randomFloatRange(0, 1) < RunThenPassSameSideChance
				var_2_2 = var_2_2 .. "-thenpass"
			end
		else
			arg_2_0.vetoPass = true
			var_2_2 = var_2_4 >= LastPlayTackleCount and "veto-lastplay" or "veto"
			-- Keep the record (marked vetoed) so a re-entry stays vetoed.
			var_2_1.vetoed = true
			var_2_1.expires = arg_2_9 + VetoHoldTime
			var_2_0[arg_2_5] = var_2_1
			arg_2_0.vetoRecord = var_2_1
		end

		debugWrite(string.format("HITGAP id=%s side=%s tackle=%s x=%.1f y=%.1f roll=%.2f chance=%.2f offsideL/R=%d/%d [%s] -> %s", tostring(arg_2_5), tostring(arg_2_6.side), tostring(var_2_4), arg_2_6.pos.x, arg_2_6.pos.y, var_2_1.roll, var_2_8, var_2_5, var_2_6, var_2_10, var_2_2))
	elseif DebugLog then
		pcall(function()
			debugWrite(string.format("HITGAP id=%s side=%s tackle=%s x=%.1f y=%.1f (not a dummy half)", tostring(arg_2_5), tostring(arg_2_6.side), tostring(arg_2_7:getMatchProgressionEntity().tackleCount), arg_2_6.pos.x, arg_2_6.pos.y))
		end)
	end

	if not arg_2_0.vetoPass then
		clearPlay(arg_2_10, arg_2_6)
	end

	arg_2_0.sideStepMixin:onEnter(arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	arg_2_0.fendMixin:onEnter(arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	arg_2_0.hitUpMixin:onEnter(arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	arg_2_0.passMixin:onEnter(arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	arg_2_0.fakePassMixin:onEnter(arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	arg_2_0.kickMixin:onEnter(arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	arg_2_0.tryMixin:onEnter(arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
end

function HitGapAi.update(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	if arg_3_0.vetoPass then
		if arg_3_0.passMixin.passExecuted then
			return arg_3_0
		end

		-- He already holds the ball here: use the open-play pass, not the
		-- dummy-half pick-up pass (that one spills the ball, i.e. a knock-on).
		if dummyhalfcollectball_ai.ForceDummyHalfPass(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11, nil, true) then
			debugWrite(string.format("HITGAP id=%s veto-passed after %.2fs", tostring(arg_3_5), arg_3_10 - arg_3_0.startTime))

			if dummyhalfcollectball_ai.DummyHalfPickups[arg_3_5] == arg_3_0.vetoRecord then
				dummyhalfcollectball_ai.DummyHalfPickups[arg_3_5] = nil
			end

			return arg_3_0
		end

		if arg_3_10 - arg_3_0.startTime < VetoPassTimeout then
			return arg_3_0
		end

		debugWrite(string.format("HITGAP id=%s veto-timeout, running", tostring(arg_3_5)))

		arg_3_0.vetoPass = false

		if dummyhalfcollectball_ai.DummyHalfPickups[arg_3_5] == arg_3_0.vetoRecord then
			dummyhalfcollectball_ai.DummyHalfPickups[arg_3_5] = nil
		end

		clearPlay(arg_3_11, arg_3_6)
	end

	if arg_3_0.runPassAt and arg_3_10 >= arg_3_0.runPassAt and not arg_3_0.passMixin.passExecuted then
		local var_3_5 = arg_3_6.velocity.y
		local var_3_6 = arg_3_0.runSide or (var_3_5 >= 0 and 1 or -1)
		local var_3_7 = arg_3_0.runPassSameSide and var_3_6 or -var_3_6

		if dummyhalfcollectball_ai.ForceDummyHalfPass(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11, var_3_7, true) then
			arg_3_0.runPassAt = nil

			debugWrite(string.format("HITGAP id=%s run-then-pass %s after %.2fs", tostring(arg_3_5), arg_3_0.runPassSameSide and "same-side" or "switch", arg_3_10 - arg_3_0.startTime))

			return arg_3_0
		end
	end

	local var_3_0 = {}

	arg_3_0.sideStepMixin:update(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	arg_3_0.fendMixin:update(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	arg_3_0.hitUpMixin:update(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	arg_3_0.driveTackleMixin:update(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	arg_3_0.passMixin:update(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11, var_3_0)
	arg_3_0.fakePassMixin:update(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11, var_3_0)
	arg_3_0.kickMixin:update(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11, var_3_0)
	arg_3_0.tryMixin:update(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11, var_3_0)

	local var_3_1 = arg_3_2.knowledgeBank.playerGapKnowledgePool:get(arg_3_5).gapPosition

	-- Crowd scoot: run at the side with the offside defenders, not the gap.
	if arg_3_0.runSide and arg_3_10 - arg_3_0.startTime < RunThenPassMaxTime then
		var_3_1 = native.vec2(arg_3_6.pos.x + arg_3_6:getPlayDir().x * 10, arg_3_6.pos.y + arg_3_0.runSide * 6)
	end

	local var_3_2 = native.normalize2(var_3_1 - arg_3_6.pos)

	arg_3_6:setMovementTarget(var_3_1, var_3_2)

	local var_3_3 = arg_3_6:getDerivedAttribute("max_speed")
	local var_3_4 = var_3_3

	arg_3_6:setMovementSpeed(var_3_3, var_3_4)

	return arg_3_0
end
