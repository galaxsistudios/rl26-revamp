import("core.foundation.func")
import("base.event.notification_request")
import("ai.substitutions.substitution_request")
import("base.side.sidehelper")
import("game.player.playertype")
import("script-config.design.sinbin.sinbin_config")
import("script-config.game.interchange.interchange_config")

-- ai-interchange-rotation: fatigue-driven interchanges for AI-run sides.
--
-- Stock AI interchanges are native (paTeamSubstitutionDecisionKnowledge_job_)
-- and run on a fixed clock: both props at 20', 38' and 60', the hooker at 55'
-- and the lock at 65', each time bringing on the first bench player in
-- subOnOrderList. That is why the AI only ever uses the same two bench players.
-- install.py turns that clock off (injury interchanges stay native) and lets
-- the job accept SubstitutionRequests for AI sides, which AiInterchangeManager
-- (below) sends when a forward or the hooker tires.

Class("SubstitutionListener", function(arg_1_0, arg_1_1)
	return
end)

function SubstitutionListener.registerWithMatchSim(arg_2_0, arg_2_1)
	arg_2_1:registerSolidEventListener(func.bindmethod(arg_2_0, arg_2_0.onInterchangeQueuedEvent), "InterchangeQueuedEvent")
	arg_2_1:registerSolidEventListener(func.bindmethod(arg_2_0, arg_2_0.onChangeRoleEvent), "ChangeRoleEvent")
	arg_2_1:registerSolidEventListener(func.bindmethod(arg_2_0, arg_2_0.onChangeSpecialRoleEvent), "ChangeSpecialRoleEvent")

	-- ai-interchange-rotation
	local var_2_0 = AiInterchangeManager()

	arg_2_1:registerUpdateable(function(...)
		var_2_0:update(...)
	end)
end

function SubstitutionListener.onInterchangeQueuedEvent(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9)
	local var_3_0 = VERIFY(arg_3_1.side)
	local var_3_1 = VERIFY(arg_3_1.offId)
	local var_3_2 = VERIFY(arg_3_1.onId)
	local var_3_3 = arg_3_6:getComponent("matchInData")

	-- ai-interchange-rotation: "Interchange queued" only for interchanges a human picked. AI
	-- sides (and gamer sides on automatic interchanges / Be a Pro, same test as
	-- substitution_hud.lua) queue silently; the scoreboard shows the swap when it happens.
	local var_3_a = arg_3_4.primaryPartyMemberSettings
	local var_3_b = var_3_a and var_3_a.automaticInterchanges and not var_3_3.onlineMultiplayer or var_3_3:isBeAProMode()

	if var_3_b or not arg_3_7:getGamerSideEntity():isAnyGamerOnSide(var_3_0) then
		return
	end

	local var_3_4 = VERIFY(arg_3_6:getSide(var_3_0))
	local var_3_5 = VERIFY(var_3_3:getTeamConfig(var_3_4.side))
	local var_3_6 = VERIFY(var_3_4:getAssetIdMap())
	local var_3_7 = VERIFY(var_3_4.assetIdMap[var_3_2])
	local var_3_8 = VERIFY(var_3_4.assetIdMap[var_3_1])
	local var_3_9 = VERIFY(var_3_5:getIdentity(var_3_7))
	local var_3_10 = VERIFY(var_3_9.shortName)
	local var_3_11 = VERIFY(var_3_5:getIdentity(var_3_8))
	local var_3_12 = VERIFY(var_3_11.shortName)
	local var_3_13 = native.Localise("SubstitutionQueued")
	local var_3_14 = string.format("%s: %s, %s: %s", native.Localise("On"), var_3_10, native.Localise("Off"), var_3_12)
	local var_3_15 = {
		priority = 1,
		notificationName = "SubstitutionQueuedNotification",
		duration = 5,
		topText = var_3_13,
		bottomText = var_3_14
	}

	arg_3_9:add(notification_request.NotificationRequest(var_3_15))
end

function SubstitutionListener.onChangeRoleEvent(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7, arg_4_8, arg_4_9)
	local var_4_0 = arg_4_4.knowledgeBank.inPlayInfoPool
	local var_4_1 = VERIFY(arg_4_1.id)
	local var_4_2 = VERIFY(arg_4_1.playerAtRoleId)
	local var_4_3 = var_4_0:get(var_4_1)
	local var_4_4 = var_4_0:get(var_4_2)
	local var_4_5 = VERIFY(arg_4_1.tentativeRole)
	local var_4_6 = VERIFY(arg_4_1.solidRole)

	var_4_3:setRole(var_4_5)
	var_4_4:setRole(var_4_6)
end

function SubstitutionListener.onChangeSpecialRoleEvent(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7, arg_5_8, arg_5_9)
	local var_5_0 = VERIFY(arg_5_1.side)
	local var_5_1 = VERIFY(arg_5_1.id)
	local var_5_2 = VERIFY(arg_5_1.specialRole)
	local var_5_3 = arg_5_7:getRoleInfoPool()
	local var_5_4 = arg_5_6:getSide(var_5_0)

	for iter_5_0, iter_5_1 in var_5_4.matchClub.lineup:iterPlayers() do
		local var_5_5 = var_5_4:getIdAsset(iter_5_1)
		local var_5_6 = var_5_3:get(var_5_5)
		local var_5_7 = {}
		local var_5_8 = var_5_6:getSpecialRoles(var_5_7)

		for iter_5_2, iter_5_3 in ipairs(var_5_8) do
			if iter_5_3 == var_5_2 then
				var_5_6:removeSpecialRole(iter_5_3)
				formatPrintT("[SubstitutionListener:onChangeSpecialRoleEvent] - id: %d, is being cleared from (specialRole): %s", var_5_5, tostring(var_5_2))
			end
		end
	end

	var_5_3:get(var_5_1):setSpecialRole(var_5_2)
	formatPrintT("[SubstitutionListener:onChangeSpecialRoleEvent] - id: %d, is being set to (specialRole): %s", var_5_1, tostring(var_5_2))
end

-- ---------------------------------------------------------------------------
-- ai-interchange-rotation: AiInterchangeManager
-- ---------------------------------------------------------------------------

-- A forward or hooker comes off once his stamina (stamina / maxStamina, the
-- figure the pause menu shows) drops below a threshold between FatigueMin and
-- FatigueMax. Each player gets his own threshold per half so the whole pack
-- doesn't come off at once.
FatigueMin = 0.45
FatigueMax = 0.55

-- A bench player must be at least this fresh to go on (a forward who came off
-- at 25% has to recover first).
MinBenchStamina = 0.6

-- Interchanges left unused for injuries (stock injury interchanges stay native).
ReserveInterchanges = 1

-- Most interchanges (fatigue and injury) per period, so they spread over both
-- halves (stamina resets at the break).
MaxPerPeriod = 4

-- No fatigue interchanges in the last EndOfPeriodSeconds of a period (scaled
-- for shortened halves): stamina resets at half time, so they'd be wasted.
EndOfPeriodSeconds = 120

-- Match-clock seconds between fatigue interchanges for one side, and the most
-- interchanges a side may have queued at once.
RequestCooldown = 60
MaxQueued = 2

-- Rotation checkpoints (match minutes of an 80 minute game, scaled for short
-- halves): at each one the side swaps up to `swaps` tired forwards/hookers
-- for fresher bench players, so the whole bench gets a turn. 40 is half time
-- (taken at the start of the second half). Checkpoints ignore
-- timePeriodStartNoInterchange and the cooldown, but not the budget rules.
Checkpoints = {
	{
		minute = 20,
		swaps = 2
	},
	{
		minute = 40,
		swaps = 1
	},
	{
		minute = 60,
		swaps = 1
	},
	{
		minute = 70,
		swaps = 1
	}
}

-- At a checkpoint, only players below CheckpointMaxStamina come off, and only
-- for a bench player at least CheckpointMinGain fresher.
CheckpointMaxStamina = 0.9
CheckpointMinGain = 0.1

-- Each turn on the field a player has had multiplies his pick score by this,
-- so players who haven't been on yet go first. Starters count as one turn.
TurnWeight = 0.6

-- Real seconds between evaluations.
EvaluateInterval = 1

-- Debug: decisions and a stamina snapshot to ai_interchange_debug.txt in the
-- game folder. Turn off for release.
DebugLog = true

local var_0_0 = native.EAssignedRole
local var_0_1 = native.EPreferredRole

-- Assigned roles rotated for fatigue.
local var_0_2 = {
	[var_0_0.PropLeft] = true,
	[var_0_0.PropRight] = true,
	[var_0_0.Hooker] = true,
	[var_0_0.SecondRowLeft] = true,
	[var_0_0.SecondRowRight] = true,
	[var_0_0.Lock] = true
}

-- Spine positions: a bench player with one of these as primary or secondary
-- role is the utility and never comes on for a forward.
local var_0_3 = {
	[var_0_1.FullBack] = true,
	[var_0_1.FiveEighth] = true,
	[var_0_1.HalfBack] = true,
	[var_0_1.Hooker] = true
}

-- Default period lengths (match-clock seconds) that interchange_config's
-- timePeriodStartNoInterchange values were written for.
local var_0_4 = 2400
local var_0_5 = 600

local function debugWrite(arg_0_0)
	if not DebugLog then
		return
	end

	pcall(function()
		local var_0_6 = io.open("ai_interchange_debug.txt", "a")

		if var_0_6 then
			var_0_6:write(os.date("%H:%M:%S"), " ", arg_0_0, "\n")
			var_0_6:flush()
			var_0_6:close()
		end
	end)
end

Class("AiInterchangeManager", function(arg_6_0)
	arg_6_0.timer = 0
	arg_6_0.lastRequestTime = {}
	arg_6_0.lastSnapshotTime = {}
	arg_6_0.loggedErrors = {}
	arg_6_0.periodStartCount = {}
	arg_6_0.turns = {}
	arg_6_0.checkpointsDone = {}
end)

function AiInterchangeManager.update(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7, arg_7_8, arg_7_9, arg_7_10, arg_7_11)
	arg_7_0.timer = arg_7_0.timer + (arg_7_8 or 0)

	if arg_7_0.timer < EvaluateInterval then
		return
	end

	arg_7_0.timer = 0

	arg_7_0.stage = "setup"

	local var_7_0, var_7_1 = pcall(arg_7_0.evaluate, arg_7_0, arg_7_3, arg_7_5, arg_7_6, arg_7_7, arg_7_9, arg_7_10)

	if not var_7_0 then
		local var_7_2 = tostring(arg_7_0.stage) .. ": " .. tostring(var_7_1)

		if not arg_7_0.loggedErrors[var_7_2] then
			arg_7_0.loggedErrors[var_7_2] = true

			debugWrite("ERROR " .. var_7_2)
		end
	end
end

-- services, match, gamestate, gameobjects, frame time, request list
function AiInterchangeManager.evaluate(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5, arg_8_6)
	local var_8_0 = arg_8_2:getComponent("matchInData")
	local var_8_1 = arg_8_2:getComponent("matchInfo")
	local var_8_2 = var_8_0.matchType
	local var_8_3 = arg_8_3:getMatchProgressionEntity()

	if not var_8_2 or not var_8_3 then
		return
	end

	if not arg_8_0.started then
		arg_8_0.started = true

		debugWrite(string.format("started: maxSubstitutionCount %s, maxOriginalSubstitutesToSelect %s, period length %s", tostring(var_8_2.maxSubstitutionCount), tostring(var_8_2.maxOriginalSubstitutesToSelect), tostring(var_8_1.timePeriodDuration)))
	end

	arg_8_0.stage = "timing"

	local var_8_4 = arg_8_1.primaryPartyMemberSettings
	local var_8_5 = var_8_4 and var_8_4.automaticInterchanges or var_8_0:isBeAProMode()
	local var_8_6 = arg_8_3:getGamerSideEntity()
	local var_8_7 = var_8_1:getTimePeriodSecondsElapsed(arg_8_3, arg_8_5)
	local var_8_9 = var_8_2.categorisedMatchType == native.EMatchType.MT_Nines and var_0_5 or var_0_4

	if var_8_1:getTimePeriodSecondsRemaining(arg_8_3, arg_8_5) < EndOfPeriodSeconds * (var_8_1.timePeriodDuration or var_8_9) / var_8_9 then
		return
	end

	local var_8_8 = {
		services = arg_8_1,
		match = arg_8_2,
		gamestate = arg_8_3,
		gameobjects = arg_8_4,
		requestList = arg_8_6,
		matchInData = var_8_0,
		matchType = var_8_2,
		period = var_8_3.currentTimePeriod + var_8_3.currentExtraTimePeriod,
		inOpening = var_8_7 < arg_8_0:getNoInterchangeTime(var_8_1, var_8_2, var_8_3),
		normalTime = var_8_3.currentExtraTimePeriod == 0,
		timeScale = (var_8_1.timePeriodDuration or var_8_9) / var_8_9,
		matchSeconds = var_8_1:getMatchSecondsElapsed(arg_8_3, arg_8_5),
		proId = arg_8_0:getProPlayerId(arg_8_2, var_8_0)
	}

	arg_8_0.stage = "sides"

	for iter_8_0, iter_8_1 in ipairs(sidehelper.sides) do
		-- Same split as the native job: a side a gamer controls is left alone
		-- unless the automatic interchanges setting (or Be a Pro) hands it to
		-- the AI.
		if var_8_5 or not var_8_6:isAnyGamerOnSide(iter_8_1) then
			arg_8_0:evaluateSide(iter_8_1, var_8_8)
		end
	end
end

function AiInterchangeManager.getNoInterchangeTime(arg_9_0, arg_9_1, arg_9_2, arg_9_3)
	local var_9_0 = arg_9_3.currentExtraTimePeriod > 0
	local var_9_1 = arg_9_2.categorisedMatchType == native.EMatchType.MT_Nines

	if var_9_0 then
		local var_9_2 = interchange_config.extraTime.timePeriodStartNoInterchange

		return var_9_2[math.min(arg_9_3.currentExtraTimePeriod, #var_9_2)] or 0
	end

	local var_9_3 = var_9_1 and interchange_config.ninesTime or interchange_config.normalTime
	local var_9_4 = var_9_3.timePeriodStartNoInterchange
	local var_9_5 = var_9_4[math.min(math.max(arg_9_3.currentTimePeriod, 1), #var_9_4)] or 0
	local var_9_6 = var_9_1 and var_0_5 or var_0_4
	local var_9_7 = arg_9_1.timePeriodDuration or var_9_6

	-- Scale for shortened halves.
	return var_9_5 * var_9_7 / var_9_6
end

function AiInterchangeManager.getProPlayerId(arg_10_0, arg_10_1, arg_10_2)
	local var_10_0 = arg_10_2.beAProAssetId

	if not var_10_0 then
		return nil
	end

	return arg_10_1:getSide(sidehelper.home):getIdAsset(var_10_0) or arg_10_1:getSide(sidehelper.away):getIdAsset(var_10_0)
end

function AiInterchangeManager.getStamina(arg_11_0, arg_11_1, arg_11_2)
	local var_11_0 = arg_11_2.services.pools.staminaInfoPool:get(arg_11_1)

	if not var_11_0 then
		return 1
	end

	-- Same lookup as StaminaListener.
	local var_11_4 = arg_11_2.gameobjects:getGameObject(arg_11_1, playertype.TypeId)
	local var_11_1 = var_11_4 and var_11_4:getDerivedAttribute("maxStamina")

	if not var_11_1 or var_11_1 <= 0 then
		var_11_1 = 1
	end

	return var_11_0.stamina / var_11_1
end

-- Per player, per period: FatigueMin..FatigueMax, deterministic so a replayed
-- sim makes the same calls.
function AiInterchangeManager.getFatigueThreshold(arg_12_0, arg_12_1, arg_12_2)
	local var_12_0 = (arg_12_1 * 37 + arg_12_2 * 101) % 11 / 10

	return FatigueMin + (FatigueMax - FatigueMin) * var_12_0
end

local function var_0_7(arg_13_0, arg_13_1)
	if arg_13_1 == arg_13_0.primaryRole then
		return interchange_config.AllocatedPrimaryRoleWeight
	elseif arg_13_1 == arg_13_0.secondaryRole then
		return interchange_config.AllocatedSecondaryRoleWeight
	elseif arg_13_1 == arg_13_0.tertiaryRole then
		return interchange_config.AllocatedTertiaryRoleWeight
	end

	return interchange_config.NonAllocatedRoleWeight
end

-- hia-protocol: players in a Head Injury Assessment (and their replacements) are never moved, and
-- HIA swaps (free interchanges) don't count towards MaxPerPeriod. Without that mod: false / 0.
local function var_0_hia_locked(arg_h_0)
	local var_h_0 = rawget(_G, "HIAState")

	return var_h_0 ~= nil and var_h_0.isLocked ~= nil and var_h_0.isLocked(arg_h_0)
end

local function var_0_hia_free_swaps(arg_h_1)
	local var_h_1 = rawget(_G, "HIAState")

	return var_h_1 and var_h_1.freeSwaps and var_h_1.freeSwaps[arg_h_1] or 0
end

local function var_0_8(arg_14_0)
	return var_0_3[arg_14_0.primaryRole] or var_0_3[arg_14_0.secondaryRole] or false
end

function AiInterchangeManager.evaluateSide(arg_15_0, arg_15_1, arg_15_2)
	local var_15_0 = arg_15_2.gamestate
	local var_15_1 = arg_15_2.matchType
	local var_15_2 = VERIFY(var_15_0:getTeamSubstitutionEntityPair()):get(arg_15_1)
	local var_15_3 = arg_15_2.services.knowledgeBank.teamSubstitutionDecisionKnowledgePair:get(arg_15_1)
	local var_15_4 = var_15_1.maxSubstitutionCount == native.EMaxSubstitutionCounts.Unlimited

	if not var_15_2 or not var_15_3 then
		return
	end

	arg_15_0.stage = "snapshot"

	arg_15_0:snapshot(arg_15_1, arg_15_2)

	arg_15_0.stage = "budget"

	-- How many interchanges may be queued now. Budget: the limit minus the
	-- reserve, and MaxPerPeriod per period; queue: MaxQueued at once.
	local var_15_5 = MaxQueued - var_15_2:getCurrentQueuedSubstitutionCount()
	local var_15_6 = math.huge

	if not var_15_4 then
		local var_15_7 = var_15_2:getCompletedSubstitutions() + var_15_2:getCurrentQueuedSubstitutionCount() - var_0_hia_free_swaps(arg_15_1)
		local var_15_8 = arg_15_0.periodStartCount[arg_15_1]

		if not var_15_8 or var_15_8.period ~= arg_15_2.period then
			var_15_8 = {
				period = arg_15_2.period,
				count = var_15_7
			}
			arg_15_0.periodStartCount[arg_15_1] = var_15_8
		end

		var_15_6 = math.min(var_15_2:getRemainingSubstitutions(var_15_1) - ReserveInterchanges, MaxPerPeriod - (var_15_7 - var_15_8.count))
	end

	local var_15_9 = arg_15_0:getDueCheckpoint(arg_15_1, arg_15_2)

	if var_15_9 and var_15_6 <= 0 then
		debugWrite(string.format("side %d checkpoint %d': skipped, no interchanges left in the budget", arg_15_1, Checkpoints[var_15_9].minute))

		arg_15_0.checkpointsDone[arg_15_1][var_15_9] = true
		var_15_9 = nil
	end

	local var_15_10 = math.min(var_15_5, var_15_6)

	if var_15_10 <= 0 then
		return
	end

	arg_15_0.stage = "collect"

	local var_15_11, var_15_12, var_15_13 = arg_15_0:collectPlayers(arg_15_1, arg_15_2, var_15_2, var_15_3)

	if var_15_9 then
		arg_15_0.stage = "checkpoint"

		arg_15_0:runCheckpoint(arg_15_1, arg_15_2, var_15_9, math.min(Checkpoints[var_15_9].swaps, var_15_10), var_15_13, var_15_12, var_15_2)

		arg_15_0.checkpointsDone[arg_15_1][var_15_9] = true

		return
	end

	if arg_15_2.inOpening then
		return
	end

	local var_15_14 = arg_15_0.lastRequestTime[arg_15_1]

	if var_15_14 and arg_15_2.matchSeconds - var_15_14 < RequestCooldown and arg_15_2.matchSeconds >= var_15_14 then
		return
	end

	arg_15_0.stage = "choose"

	table.sort(var_15_11, function(arg_16_0, arg_16_1)
		return arg_16_0.stamina < arg_16_1.stamina
	end)

	for iter_15_0, iter_15_1 in ipairs(var_15_11) do
		local var_15_15 = arg_15_0:chooseReplacement(iter_15_1, var_15_12, var_15_2, var_15_1, MinBenchStamina)

		if var_15_15 then
			arg_15_0:requestSwap(arg_15_1, arg_15_2, iter_15_1, var_15_15, string.format("%.0f%% < %.0f%%", iter_15_1.stamina * 100, iter_15_1.threshold * 100))

			return
		end

		debugWrite(string.format("side %d: %s tired (%.0f%%) but no eligible bench player", arg_15_1, iter_15_1.name, iter_15_1.stamina * 100))
	end
end

-- Index of the latest checkpoint whose time has passed and that this side
-- hasn't run yet (earlier missed ones are dropped), or nil.
function AiInterchangeManager.getDueCheckpoint(arg_20_0, arg_20_1, arg_20_2)
	local var_20_0 = arg_20_0.checkpointsDone[arg_20_1]

	if not var_20_0 then
		var_20_0 = {}
		arg_20_0.checkpointsDone[arg_20_1] = var_20_0
	end

	if not arg_20_2.normalTime then
		return nil
	end

	local var_20_1

	for iter_20_0, iter_20_1 in ipairs(Checkpoints) do
		if not var_20_0[iter_20_0] and arg_20_2.matchSeconds >= iter_20_1.minute * 60 * arg_20_2.timeScale then
			if var_20_1 then
				var_20_0[var_20_1] = true
			end

			var_20_1 = iter_20_0
		end
	end

	return var_20_1
end

-- Most tired first: each forward/hooker below CheckpointMaxStamina is swapped
-- for the best bench player (fewest turns first) who is CheckpointMinGain
-- fresher, up to arg_21_4 swaps.
function AiInterchangeManager.runCheckpoint(arg_21_0, arg_21_1, arg_21_2, arg_21_3, arg_21_4, arg_21_5, arg_21_6, arg_21_7)
	local var_21_0 = Checkpoints[arg_21_3].minute
	local var_21_1 = 0

	table.sort(arg_21_5, function(arg_22_0, arg_22_1)
		return arg_22_0.stamina < arg_22_1.stamina
	end)

	for iter_21_0, iter_21_1 in ipairs(arg_21_5) do
		if var_21_1 >= arg_21_4 or iter_21_1.stamina >= CheckpointMaxStamina then
			break
		end

		local var_21_2 = arg_21_0:chooseReplacement(iter_21_1, arg_21_6, arg_21_7, arg_21_2.matchType, math.max(MinBenchStamina, iter_21_1.stamina + CheckpointMinGain))

		if var_21_2 then
			arg_21_0:requestSwap(arg_21_1, arg_21_2, iter_21_1, var_21_2, string.format("checkpoint %d', %.0f%%", var_21_0, iter_21_1.stamina * 100))

			var_21_1 = var_21_1 + 1
		end
	end

	debugWrite(string.format("side %d checkpoint %d': %d swap(s) of %d allowed", arg_21_1, var_21_0, var_21_1, arg_21_4))
end

function AiInterchangeManager.requestSwap(arg_23_0, arg_23_1, arg_23_2, arg_23_3, arg_23_4, arg_23_5)
	local var_23_0 = arg_23_2.matchType

	arg_23_0.stage = "request"

	arg_23_2.requestList:add(substitution_request.SubstitutionRequest({
		side = arg_23_1,
		offId = arg_23_3.id,
		onId = arg_23_4.id,
		maxSubstitutions = var_23_0.maxSubstitutionCount:toInt(),
		unlimitedSubstitutions = var_23_0.maxSubstitutionCount == native.EMaxSubstitutionCounts.Unlimited
	}))

	arg_23_4.used = true
	arg_23_3.used = true
	arg_23_0.turns[arg_23_4.id] = arg_23_4.turns + 1
	arg_23_0.lastRequestTime[arg_23_1] = arg_23_2.matchSeconds

	debugWrite(string.format("side %d %02d:%02d  OFF %s (%s, %s)  ON %s (%s/%s, %.0f%%, turn %d%s)", arg_23_1, math.floor(arg_23_2.matchSeconds / 60), math.floor(arg_23_2.matchSeconds % 60), arg_23_3.name, tostring(arg_23_3.role), arg_23_5, arg_23_4.name, tostring(arg_23_4.player.primaryRole), tostring(arg_23_4.player.secondaryRole), arg_23_4.stamina * 100, arg_23_4.turns + 1, arg_23_4.utility and ", utility" or ""))
end

-- Turns on the field so far: counted by this manager, starters start at one.
function AiInterchangeManager.getTurns(arg_24_0, arg_24_1, arg_24_2)
	local var_24_0 = arg_24_0.turns[arg_24_2]

	if var_24_0 == nil then
		var_24_0 = arg_24_1:isOriginalSub(arg_24_2) and 0 or 1
		arg_24_0.turns[arg_24_2] = var_24_0
	end

	return var_24_0
end

-- Returns tired on-field forwards/hookers, available bench players, and every
-- available on-field forward/hooker.
function AiInterchangeManager.collectPlayers(arg_17_0, arg_17_1, arg_17_2, arg_17_3, arg_17_4)
	local var_17_0 = arg_17_2.gamestate
	local var_17_1 = arg_17_2.match:getSide(arg_17_1)
	local var_17_2 = arg_17_2.matchInData:getClub(arg_17_1)
	local var_17_3 = arg_17_2.services.knowledgeBank.inPlayInfoPool
	local var_17_4 = var_17_0:getInjuryPool()
	local var_17_5 = var_17_0:getSinBinInfoPool()
	local var_17_6 = {}
	local var_17_7 = {}
	local var_17_15 = {}

	for iter_17_0, iter_17_1 in pairs(var_17_1.idAssetMap) do
		local var_17_8 = var_17_3:get(iter_17_1)
		local var_17_9 = var_17_2:getPlayer(iter_17_0)
		local var_17_10 = iter_17_1 ~= arg_17_2.proId and var_17_8 and var_17_9 and not arg_17_3:queuedSubstitutionsContains(iter_17_1) and not arg_17_4:queuedSubstitutionsContains(iter_17_1) and var_17_5:get(iter_17_1).status == sinbin_config.sinbinStatus.OnField and not var_0_hia_locked(iter_17_1)

		if var_17_10 then
			local var_17_11 = var_17_4:get(iter_17_1).severity
			local var_17_12 = interchange_config.InjuryWeights[var_17_11] or 0
			local var_17_13 = var_17_8.role
			local var_17_14 = {
				id = iter_17_1,
				assetId = iter_17_0,
				player = var_17_9,
				role = var_17_13,
				name = var_17_9.fullName or tostring(iter_17_1),
				stamina = arg_17_0:getStamina(iter_17_1, arg_17_2),
				injuryWeight = var_17_12,
				turns = arg_17_0:getTurns(arg_17_3, iter_17_1)
			}

			if var_17_13 == var_0_0.Substitute then
				if var_17_8.inPlayState == native.EInPlayState.Sideline and var_17_12 > 0 then
					var_17_14.utility = var_0_8(var_17_9)
					var_17_14.unusedOriginal = arg_17_3.originalSubsNotInterchanged[iter_17_1] ~= nil

					table.insert(var_17_7, var_17_14)
				end
			elseif var_0_2[var_17_13] and var_17_8.inPlayState == native.EInPlayState.InPlay and var_17_11 == native.EInjurySeverity.None then
				var_17_14.threshold = arg_17_0:getFatigueThreshold(iter_17_1, arg_17_2.period)

				table.insert(var_17_15, var_17_14)

				if var_17_14.stamina < var_17_14.threshold then
					table.insert(var_17_6, var_17_14)
				end
			end
		end
	end

	return var_17_6, var_17_7, var_17_15
end

function AiInterchangeManager.chooseReplacement(arg_18_0, arg_18_1, arg_18_2, arg_18_3, arg_18_4, arg_18_5)
	local var_18_0 = arg_18_1.role == var_0_0.Hooker
	local var_18_1 = native.PlayerRole.getPreferredRoleForAssignedRole(arg_18_1.role)
	local var_18_2 = arg_18_4.maxOriginalSubstitutesToSelect
	local var_18_3

	-- Interchange rule (17 and 19 man squads): only maxOriginalSubstitutesToSelect
	-- of the original bench may ever take the field.
	if var_18_2 and var_18_2 ~= native.EMaxSubstitutionCounts.Unlimited then
		var_18_3 = var_18_2:toInt() - arg_18_3:getOriginalSubsInterchangedCount()

		for iter_18_0, iter_18_1 in ipairs(arg_18_2) do
			-- Swaps queued this evaluation haven't reached the entity yet.
			if iter_18_1.used and iter_18_1.unusedOriginal then
				var_18_3 = var_18_3 - 1
			end
		end
	end

	local var_18_4 = false

	for iter_18_0, iter_18_1 in ipairs(arg_18_2) do
		if iter_18_1.utility and iter_18_1.unusedOriginal and not iter_18_1.used then
			var_18_4 = true
		end
	end

	local var_18_5
	local var_18_6 = 0

	for iter_18_2, iter_18_3 in ipairs(arg_18_2) do
		local var_18_7 = not iter_18_3.used and iter_18_3.stamina >= arg_18_5

		if var_18_7 and iter_18_3.utility and not var_18_0 then
			var_18_7 = false
		end

		if var_18_7 and iter_18_3.unusedOriginal and var_18_3 then
			if var_18_3 <= 0 then
				var_18_7 = false
			elseif var_18_3 == 1 and var_18_4 and not iter_18_3.utility then
				-- Keep the last bench slot for the utility (hooker cover).
				var_18_7 = false
			end
		end

		if var_18_7 then
			local var_18_8 = iter_18_3.player:getOverallForRole(var_18_1) or 0
			local var_18_9 = var_18_8 * var_0_7(iter_18_3.player, var_18_1) * iter_18_3.stamina * iter_18_3.injuryWeight * TurnWeight ^ iter_18_3.turns

			if var_18_6 < var_18_9 then
				var_18_6 = var_18_9
				var_18_5 = iter_18_3
			end
		end
	end

	return var_18_5
end

-- Debug: every 5 match minutes, each side's forwards' stamina.
function AiInterchangeManager.snapshot(arg_19_0, arg_19_1, arg_19_2)
	if not DebugLog then
		return
	end

	local var_19_0 = arg_19_0.lastSnapshotTime[arg_19_1]

	if var_19_0 and arg_19_2.matchSeconds - var_19_0 < 300 and arg_19_2.matchSeconds >= var_19_0 then
		return
	end

	arg_19_0.lastSnapshotTime[arg_19_1] = arg_19_2.matchSeconds

	local var_19_1 = arg_19_2.match:getSide(arg_19_1)
	local var_19_2 = arg_19_2.services.knowledgeBank.inPlayInfoPool
	local var_19_3 = VERIFY(arg_19_2.gamestate:getTeamSubstitutionEntityPair()):get(arg_19_1)
	local var_19_4 = {}

	for iter_19_0, iter_19_1 in pairs(var_19_1.idAssetMap) do
		local var_19_5 = var_19_2:get(iter_19_1)

		if var_19_5 and (var_0_2[var_19_5.role] or var_19_5.role == var_0_0.Substitute) then
			table.insert(var_19_4, string.format("%s=%.0f%%", tostring(var_19_5.role), arg_19_0:getStamina(iter_19_1, arg_19_2) * 100))
		end
	end

	table.sort(var_19_4)
	debugWrite(string.format("side %d %02d:%02d  remaining %s  %s", arg_19_1, math.floor(arg_19_2.matchSeconds / 60), math.floor(arg_19_2.matchSeconds % 60), tostring(var_19_3:getRemainingSubstitutions(arg_19_2.matchType)), table.concat(var_19_4, " ")))
end
