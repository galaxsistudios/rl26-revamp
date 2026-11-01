import("ai.formation.refereeformationchange_request")
import("ai.officials.refereehelper")
import("ai.plays.stopplay_request")
import("ai.scrum.scrumentity_request")
import("base.side.sidehelper")
import("core.foundation.class")
import("game.incapacitated.incapacitated_request")
import("rules.positioning.positionplayerstransition_rulestate")
import("script-config.rules.rugby.scrum_config")
import("rules.restart.restart")

-- scrum-feed-control: the side with the feed picks where the scrum packs (left / middle / right)
-- against a clock, then has to feed it before the scrum clock on the scoreboard runs out or the
-- other side gets a penalty. Players outside the scrum can be switched to and moved, but a
-- player who goes past the line he stood on when the scrum was set is offside for the next
-- tackle. The rule states, clock and offside line live in rules/scrum/scrum_setup_rulestate.lua.
--
--   GetScrumState -> ScrumPositionSelectRuleState (human feed only) -> GetScrumState again
--   (positioning wipe) -> ScrumSetupRuleState -> ScrumFeedPendingRuleState -> ScrumRuleState
--
-- Online matches and training keep the stock scrum.
local ScrumControlEnabled = true
-- Seconds to pick the position. Out of time: the stock spot.
local ScrumPositionSelectSeconds = 5
-- Seconds on the scrum clock to feed.
local ScrumFeedClockSeconds = 10
-- AI feeds this many seconds into the clock (random in the range). Human feeds land at about
-- 1.5-2 s, so the AI shouldn't sit on it much longer.
local ScrumAiFeedMinSeconds = 0.8
local ScrumAiFeedMaxSeconds = 2.5
-- Percent of AI scrums where the AI lets the clock run out (penalty to the other side).
local ScrumAiViolationChance = {
	[native.EDifficulty.Easiest] = 10,
	[native.EDifficulty.Easy] = 7,
	[native.EDifficulty.Medium] = 4,
	[native.EDifficulty.Hard] = 2,
	[native.EDifficulty.Hardest] = 1
}
local ScrumAiViolationChanceDefault = 4
-- "Left" is the feeding side's left as it attacks. Flip if it comes out mirrored in game.
local ScrumFlipLeftRight = false
-- Metres a player can be past his line before he is offside.
local ScrumOffsideTolerance = 0.5
-- false: only players a human is controlling can be flagged offside (the AI's formation drift
-- never is).
local ScrumOffsideAiPlayers = false
-- AI players outside the scrum adjust their line while it's fed. In this percent of scrums 1-3
-- of them shift sideways or drop back (legal).
local ScrumAiLineAdjustChance = 60
-- Percent of scrums where one AI defender creeps up past his line instead (1.5-3 m). He is
-- flagged offside like a human would be, so if he makes the first tackle it's a penalty.
local ScrumAiCreepChance = {
	[native.EDifficulty.Easiest] = 15,
	[native.EDifficulty.Easy] = 12,
	[native.EDifficulty.Medium] = 8,
	[native.EDifficulty.Hard] = 5,
	[native.EDifficulty.Hardest] = 3
}
local ScrumAiCreepChanceDefault = 8
-- AI with the feed picks its lane: when the human defence stacked one side, it packs on the
-- other side this percent of the time ("reads" the stack); in the attacking 20 m it favours the
-- middle; otherwise half the time it keeps the stock spot.
local ScrumAiReadStackChance = 75
-- Defence line-up pick: STACK LEFT / RIGHT moves the defending side's formation focus this many
-- metres towards that side for the positioning wipe. (New force-directed graphs are not an
-- option: the native graph container is a fixed pool, 65 graphs crashed match load.)
local ScrumDefenceStackShift = 6
-- discipline-meter: a defender's discipline scales the AI creep chance (x0.5 at full, x2 at
-- empty, x1.5 more when rattled) and the least disciplined defender is the likeliest creeper.
-- The AI feeder's discipline scales the feed clock violation chance the same way.
local ScrumUseDiscipline = true
-- Seconds after the ball comes out of the scrum that a flagged player is still offside (also
-- cleared by the first completed tackle).
local ScrumOffsideFlagSeconds = 10
-- Appends to scrumcontrol_debug.txt in the game folder.
local ScrumControlDebug = true
-- TEST ONLY: every completed tackle becomes a scrum (feed to the side in possession) instead
-- of a play-the-ball, so scrums can be tested on demand. Hooked in bunker-overturned-try's
-- rules/tackle/tackleoutcomes.lua. false for normal play.
local ScrumTestEveryTackle = false
-- TEST ONLY: an AI defender creeps offside at every scrum. false for normal play.
local ScrumTestAiAlwaysCreeps = false
-- TEST ONLY: when the ball comes out of a scrum, every player on the defending side is flagged
-- offside, so the first tackle after it is an offside penalty. false for normal play.
local ScrumTestAlwaysOffside = false

-- Shared with scrum_setup_rulestate.lua, scrum_rulestate.lua and (referee-on-report's)
-- tackle_detect.lua. Modules have their own environments, so it lives in _G.
local function scrumControl()
	local var_state = rawget(_G, "ScrumControlState")

	if not var_state then
		var_state = {}

		rawset(_G, "ScrumControlState", var_state)
	end

	return var_state
end

local scrumControlLogFile
local scrumControlLogTried = false

local function scrumControlLog(arg_text)
	if not ScrumControlDebug then
		return
	end

	pcall(function()
		if not scrumControlLogTried then
			scrumControlLogTried = true

			if io and io.open then
				scrumControlLogFile = io.open("scrumcontrol_debug.txt", "a")
			end
		end

		if scrumControlLogFile then
			scrumControlLogFile:write(tostring(arg_text) .. "\n")
			scrumControlLogFile:flush()
		end
	end)
end

local var_0_control = scrumControl()

var_0_control.log = scrumControlLog
var_0_control.settings = {
	positionSelectSeconds = ScrumPositionSelectSeconds,
	feedClockSeconds = ScrumFeedClockSeconds,
	aiFeedMinSeconds = ScrumAiFeedMinSeconds,
	aiFeedMaxSeconds = ScrumAiFeedMaxSeconds,
	aiViolationChance = ScrumAiViolationChance,
	aiViolationChanceDefault = ScrumAiViolationChanceDefault,
	flipLeftRight = ScrumFlipLeftRight,
	offsideTolerance = ScrumOffsideTolerance,
	offsideAiPlayers = ScrumOffsideAiPlayers,
	offsideFlagSeconds = ScrumOffsideFlagSeconds,
	aiLineAdjustChance = ScrumAiLineAdjustChance,
	aiReadStackChance = ScrumAiReadStackChance,
	defenceStackShift = ScrumDefenceStackShift,
	useDiscipline = ScrumUseDiscipline,
	aiCreepChance = ScrumAiCreepChance,
	aiCreepChanceDefault = ScrumAiCreepChanceDefault,
	testAiAlwaysCreeps = ScrumTestAiAlwaysCreeps,
	testAlwaysOffside = ScrumTestAlwaysOffside
}

-- Feed clock + offside line for every scrum (human or AI feed).
function var_0_control.isActive(arg_match, arg_gamestate)
	if not ScrumControlEnabled then
		return false, "disabled"
	end

	local var_matchInData = arg_match.matchInData or arg_match:getComponent("matchInData")

	if var_matchInData.onlineMultiplayer then
		return false, "online"
	end

	local var_ok, var_training = pcall(function()
		return arg_gamestate:getTrainingEntity().trainingActive
	end)

	if var_ok and var_training then
		return false, "training"
	end

	return true
end

-- Before the pack goes down: "select" when a human is on either side (attack picks the lane,
-- defence picks how to line up; ScrumPositionSelectRuleState), "ai" when nobody is (the AI
-- picks its lane here), nil for the stock scrum.
local function wantsPositionSelect(arg_params, arg_match, arg_gamestate)
	if arg_params.scrumPositionChosen then
		return nil
	end

	local var_active, var_reason = var_0_control.isActive(arg_match, arg_gamestate)

	if not var_active then
		scrumControlLog("GetScrumState: stock scrum (" .. tostring(var_reason) .. ")")

		return nil
	end

	local var_ok, var_human = pcall(function()
		local var_sides = arg_gamestate:getGamerSideEntity()

		return var_sides:isAnyGamerOnSide(arg_params.sideWithFeed) or var_sides:isAnyGamerOnSide(sidehelper.getOtherSide(arg_params.sideWithFeed))
	end)

	if var_ok and var_human then
		return "select"
	end

	return "ai"
end

-- Incapacitation of the scrum players has to outlast the feed clock as well as the scrum.
function var_0_control.incapacitatedSeconds(arg_match, arg_gamestate)
	if scrumControl().isActive(arg_match, arg_gamestate) then
		return 20 + ScrumFeedClockSeconds
	end

	return 20
end

-- ScrumTestEveryTackle: the scrum state for a tackle at arg_position, or nil (play-the-ball).
function var_0_control.testTackleScrum(arg_side, arg_position, arg_services, arg_guid, arg_match, arg_gamestate, arg_gameobjects, arg_time, arg_requests)
	if not ScrumTestEveryTackle or not var_0_control.isActive(arg_match, arg_gamestate) then
		return nil
	end

	local var_position = restart.adjustRestartPositionInToFieldOfPlay(arg_position, scrum_config)

	scrumControlLog(string.format("TEST: tackle -> scrum, side %s at (%.1f, %.1f)", tostring(arg_side), var_position.x, var_position.y))

	return GetScrumState({
		scrumPosition = var_position,
		sideWithFeed = arg_side,
		randomSeed = native.Random.FromSystemTime():nextAsSeed()
	}, arg_services, arg_guid, arg_match, arg_gamestate, arg_gameobjects, arg_time, arg_requests)
end

function GetScrumState(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7)
	print("[9464] GetScrumState() called. Assuemes next state must be Scrum.")

	-- A set play forced off the last scrum is over.
	if var_0_control.clearForcedPlay then
		var_0_control.clearForcedPlay(arg_1_1, "new scrum")
	end

	local var_1_mode = wantsPositionSelect(arg_1_0, arg_1_3, arg_1_4)

	if var_1_mode == "ai" and var_0_control.aiLane then
		local var_1_position, var_1_why = var_0_control.aiLane(arg_1_0.scrumPosition, arg_1_0.sideWithFeed, arg_1_3, nil)

		scrumControlLog(string.format("GetScrumState: AI lane, %s (%.1f, %.1f)", var_1_why, var_1_position.x, var_1_position.y))

		arg_1_0.scrumPosition = var_1_position
	end

	if var_1_mode == "select" then
		scrumControlLog(string.format("GetScrumState: position select, side %s, stock spot (%.1f, %.1f)", tostring(arg_1_0.sideWithFeed), arg_1_0.scrumPosition.x, arg_1_0.scrumPosition.y))
		arg_1_7:add(stopplay_request.StopPlayRequest({}))

		return class.instantiate("ScrumPositionSelectRuleState", {
			scrumPosition = arg_1_0.scrumPosition,
			sideWithFeed = arg_1_0.sideWithFeed,
			randomSeed = arg_1_0.randomSeed
		})
	end
	ASSERT(arg_1_0)
	ASSERT(arg_1_1)
	ASSERT(arg_1_2)
	ASSERT(arg_1_3)
	ASSERT(arg_1_4)
	ASSERT(arg_1_5)
	ASSERT(arg_1_6)
	ASSERT(arg_1_7)

	local var_1_0 = arg_1_0.scrumPosition
	local var_1_1 = arg_1_0.sideWithFeed
	local var_1_2 = arg_1_0.randomSeed

	ASSERT(var_1_0)
	ASSERT(var_1_1)
	ASSERT(var_1_2)

	local var_1_3 = class.instantiate("ScrumSetupRuleState", arg_1_0)
	local var_1_4 = arg_1_3:getComponent("matchInData").matchType.categorisedMatchType == native.EMatchType.MT_StandardMatch
	local var_1_5 = refereehelper.getRefereeGraphName(native.EForceDirectedGraphType.RefereeScrum, var_1_4)
	local var_1_6 = {
		refereeGraphName = var_1_5,
		refereeFormationFocus = native.EFormationFocus.Manual
	}

	arg_1_7:add(refereeformationchange_request.RefereeFormationChangeRequest(var_1_6))

	local var_1_7
	local var_1_8
	local var_1_9
	local var_1_10
	local var_1_11
	local var_1_12

	if var_1_1 == sidehelper.home then
		var_1_7 = "ScrumOffence"
		var_1_8 = "ScrumDefence"
		var_1_9 = ""
		var_1_10 = ""
		var_1_11 = native.EForceDirectedGraphType.ScrumOffence
		var_1_12 = native.EForceDirectedGraphType.ScrumDefence
	else
		var_1_7 = "ScrumDefence"
		var_1_8 = "ScrumOffence"
		var_1_9 = ""
		var_1_10 = ""
		var_1_11 = native.EForceDirectedGraphType.ScrumDefence
		var_1_12 = native.EForceDirectedGraphType.ScrumOffence
	end

	ASSERT(var_1_7)
	ASSERT(var_1_8)
	ASSERT(var_1_9)
	ASSERT(var_1_10)
	ASSERT(var_1_11)
	ASSERT(var_1_12)
	arg_1_7:add(stopplay_request.StopPlayRequest({}))

	for iter_1_0, iter_1_1 in ipairs(sidehelper.sides) do
		local var_1_13 = arg_1_3:getSide(iter_1_1)
		local var_1_14 = arg_1_4:getRoleInfoPool()

		for iter_1_2, iter_1_3 in var_1_13.matchClub.lineup:iterPlayers() do
			local var_1_15 = var_1_13:getIdAsset(iter_1_3)
			local var_1_16 = var_1_14:get(var_1_15)
			local var_1_17 = {}
			local var_1_18 = var_1_16:getSpecialRoles(var_1_17)

			for iter_1_4, iter_1_5 in ipairs(var_1_18) do
				if iter_1_5 == native.EClubLineupSpecialRole.PlayMaker3 then
					var_1_16:removeSpecialRole(iter_1_5)
				end
			end
		end
	end

	local var_1_19 = {
		wantLoadingCamera = false,
		nextState = var_1_3,
		randomSeed = var_1_2,
		homeFocusPosition = var_1_0,
		awayFocusPosition = var_1_0,
		refereeFocusPosition = var_1_0,
		focusObjectPosition = var_1_0,
		attackingSide = var_1_1,
		homeGraphName = var_1_7,
		homeGraphType = var_1_11,
		homeFormationName = var_1_9,
		awayGraphName = var_1_8,
		awayGraphType = var_1_12,
		awayFormationName = var_1_10,
		resetBallPosition = var_1_0
	}
	-- scrum-feed-control: the defence's STACK LEFT / RIGHT pick shifts its formation focus across.
	if arg_1_0.defenceShiftY and arg_1_0.defenceShiftY ~= 0 then
		local var_1_shifted = native.vec2(var_1_0.x, native.clamp1(var_1_0.y + arg_1_0.defenceShiftY, -29, 29))

		if var_1_1 == sidehelper.home then
			var_1_19.awayFocusPosition = var_1_shifted
		else
			var_1_19.homeFocusPosition = var_1_shifted
		end

		scrumControlLog(string.format("defence stack: focus shifted %.1f m to y %.1f", arg_1_0.defenceShiftY, var_1_shifted.y))
	end

	local var_1_20 = positionplayerstransition_rulestate.PositionPlayersTransitionRulestate(var_1_19)
	local var_1_21 = IncapacitateScrumPlayers(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7)

	ASSERT(var_1_21)

	local var_1_22 = {
		isActive = true,
		restartPosition = var_1_0,
		playMakerId = var_1_21
	}

	arg_1_7:add(scrumentity_request.ScrumEntityRequest(var_1_22))

	return var_1_20
end

function IncapacitateScrumPlayers(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7)
	local var_2_0 = arg_2_0.sideWithFeed

	ASSERT(var_2_0)

	local var_2_1 = arg_2_0.scrumPosition

	ASSERT(var_2_1)

	local var_2_2 = arg_2_3:getComponent("matchInData")
	local var_2_3 = arg_2_3:getSide(var_2_0)
	local var_2_4 = arg_2_3:getSide(sidehelper.getOtherSide(var_2_0))
	local var_2_5 = var_2_2:getClub(var_2_3.side)
	local var_2_6 = var_2_4:getPlayDir().x < 0 and -50 or 50
	local var_2_7

	var_2_7 = math.abs(var_2_1.x - var_2_6) < 80

	local var_2_8 = var_2_2.matchType.categorisedMatchType == native.EMatchType.MT_Nines
	local var_2_9 = arg_2_1.knowledgeBank
	local var_2_10 = var_2_9.activeTeamPlayerIdListPair

	ASSERT(var_2_10)

	local var_2_11 = arg_2_4:getSinBinInfoPool()

	local function var_2_12(arg_3_0)
		local var_3_0 = var_2_10:get(arg_3_0)

		ASSERT(var_3_0)

		for iter_3_0, iter_3_1 in var_3_0:iter() do
			if var_2_11:get(iter_3_1).status ~= native.ESinBinState.OnField then
				return true
			end
		end

		return false
	end

	local var_2_13 = (var_2_8 or var_2_12(var_2_0)) and 9 or 13
	local var_2_14 = GetScrumPlayers(var_2_3, var_2_5, arg_2_5, arg_2_4, arg_2_1, scrum_config.Positions[var_2_13].Attacking, false)
	local var_2_15 = MapPlayerIDToScrumSlot(var_2_14, scrum_config.IDMap[var_2_13].Attacking)
	local var_2_16 = arg_2_1.actionProducer:getScrumContainer()
	local var_2_17 = (var_2_8 or var_2_12(var_2_0)) and native.EScrumType.FeederCollects or native.EScrumType.OtherCollects
	local var_2_18 = var_2_3:getPlayDir()
	local var_2_19 = ShouldChangeScrumRotation(var_2_1, var_2_18.x)
	local var_2_20 = var_2_16:getAnimationGroup(var_2_17, var_2_19)
	local var_2_21 = var_2_9.playerScrumInfoPool
	local var_2_22

	for iter_2_0, iter_2_1 in pairs(var_2_15) do
		if var_2_20.receiverPositionId == iter_2_1 then
			var_2_22 = iter_2_0
		end
	end

	ASSERT(var_2_22)

	-- scrum-feed-control: + the feed clock
	local var_2_incapacitated = scrumControl().incapacitatedSeconds(arg_2_3, arg_2_4)

	local function var_2_23(arg_4_0)
		local var_4_0 = {
			id = arg_4_0,
			startTime = arg_2_6,
			endTime = arg_2_6 + var_2_incapacitated
		}

		arg_2_7:add(incapacitated_request.IncapacitatedRequest(var_4_0))
	end

	local var_2_24
	local var_2_25 = false

	for iter_2_2, iter_2_3 in pairs(var_2_15) do
		if iter_2_2 ~= var_2_22 then
			var_2_23(iter_2_2)
		elseif iter_2_2 == var_2_22 then
			var_2_24 = iter_2_2

			ASSERT(var_2_25 == false)

			var_2_25 = true
		end
	end

	ASSERT(var_2_24)

	return var_2_24
end

function GetScrumPlayers(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7)
	local var_5_0 = arg_5_3:getRoleInfoPool()

	ASSERT(var_5_0)

	local var_5_1 = arg_5_4.knowledgeBank
	local var_5_2 = var_5_1.inPlayInfoPool

	ASSERT(var_5_2)

	local var_5_3 = var_5_1.activeTeamPlayerIdListPair:get(arg_5_0.side)
	local var_5_4 = {}

	for iter_5_0, iter_5_1 in var_5_3:iter() do
		local var_5_5 = var_5_0:get(iter_5_1)

		ASSERT(var_5_5)

		local var_5_6 = var_5_5.assignedRole

		if var_5_4[var_5_6] == nil then
			var_5_4[var_5_6] = {}
		end

		local var_5_7 = var_5_2:get(iter_5_1)

		ASSERT(var_5_7)

		if var_5_7:isInPlay() then
			table.insert(var_5_4[var_5_6], iter_5_1)
		end
	end

	local function var_5_8(arg_6_0, arg_6_1)
		local var_6_0 = scrum_config.RolePriorityOffense[arg_6_0]

		if arg_6_1 and arg_5_0.side ~= arg_5_7 then
			var_6_0 = scrum_config.RolePriorityDefense[arg_6_0]
		end

		for iter_6_0, iter_6_1 in ipairs(var_6_0) do
			local var_6_1 = var_5_4[iter_6_1]
			local var_6_2

			if var_6_1 and #var_6_1 > 0 then
				var_6_2 = var_6_1[1]
				var_6_1[1] = nil
			end

			if var_6_2 then
				return var_6_2
			end
		end
	end

	local var_5_9 = {}

	for iter_5_2, iter_5_3 in ipairs(arg_5_5) do
		local var_5_10 = var_5_8(iter_5_3, arg_5_6)

		table.insert(var_5_9, var_5_10)
	end

	ASSERT(#arg_5_5 == #var_5_9)

	return var_5_9
end

function MapPlayerIDToScrumSlot(arg_7_0, arg_7_1)
	ASSERT(#arg_7_1 == #arg_7_0)

	local var_7_0 = {}

	for iter_7_0, iter_7_1 in ipairs(arg_7_1) do
		var_7_0[arg_7_0[iter_7_0]] = arg_7_1[iter_7_0]
	end

	return var_7_0
end

function ShouldChangeScrumRotation(arg_8_0, arg_8_1)
	local var_8_0 = scrum_config.rotationThreshhold
	local var_8_1
	local var_8_2

	if var_8_0 < arg_8_0.y then
		if arg_8_1 > 0 then
			var_8_2 = true
		else
			var_8_2 = false
		end
	elseif arg_8_0.y < -var_8_0 then
		if arg_8_1 > 0 then
			var_8_2 = false
		else
			var_8_2 = true
		end
	else
		var_8_2 = false
	end

	ASSERT(var_8_2 ~= nil)

	return var_8_2
end
