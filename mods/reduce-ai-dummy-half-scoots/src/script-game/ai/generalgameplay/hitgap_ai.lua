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

local var_0_0 = controller.Controller

-- reduce-ai-dummy-half-scoots: master_flowchart_ai.flow sends a dummy half
-- holding the ball with a marker offside here: that run is the AI scoot.
-- DummyHalfCollectBallAi records each pickup with a dice roll; the scoot is
-- decided here, when the run would start:
--   * never on the last play,
--   * CrowdScootChance if OffsideCrowdCount+ defenders on one side of the
--     ruck are still offside (and the run goes that way),
--   * ScootChance otherwise.
-- A vetoed scoot keeps the set play (no ClearPlayRequest) and passes as soon
-- as a receiver is known. An allowed scoot sometimes passes after a short run.

local ScootChance = 0.1
local CrowdScootChance = 0.6
local OffsideCrowdCount = 3
-- Defenders this close (m) to the ruck, along the field, count towards a crowd.
local OffsideCrowdRadius = 20
-- Tackle count at the play-the-ball before the last play (no scoot then).
local LastPlayTackleCount = 4
-- Give up waiting for a receiver after this long (s) and run.
local VetoPassTimeout = 0.5
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

function HitGapAi.onEnter(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	local var_2_0 = dummyhalfcollectball_ai.DummyHalfPickups
	local var_2_1 = var_2_0[arg_2_5]

	var_2_0[arg_2_5] = nil
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

		if var_2_1.roll < var_2_8 then
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
		end

		debugWrite(string.format("HITGAP id=%s side=%s tackle=%s x=%.1f y=%.1f roll=%.2f chance=%.2f offsideL/R=%d/%d -> %s", tostring(arg_2_5), tostring(arg_2_6.side), tostring(var_2_4), arg_2_6.pos.x, arg_2_6.pos.y, var_2_1.roll, var_2_8, var_2_5, var_2_6, var_2_2))
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

			return arg_3_0
		end

		if arg_3_10 - arg_3_0.startTime < VetoPassTimeout then
			return arg_3_0
		end

		debugWrite(string.format("HITGAP id=%s veto-timeout, running", tostring(arg_3_5)))

		arg_3_0.vetoPass = false

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
