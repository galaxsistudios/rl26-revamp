import("base.rulestate.rulestateclass")
import("base.side.sidehelper")
import("core.foundation.class")
import("core.marshalling.types")
import("game.camera.camerahelper")
import("game.player.playertype")
import("game.interchange.interchange_helper")
import("game.scrum.scrum_helper")
import("rules.match.matchtime")
import("rules.match.resettacklecount_request")
import("game.cheerleader.cheerleader_helper")
import("script-config.rules.rugby.scrum_config")
import("ai.plays.stopplay_request")
import("ai.scrum.scrumentity_request")
import("base.gamecontroller.gamecontroller")
import("game.umpire.umpiretype")
import("rules.penalty.penalty")
import("rules.penalty.penaltytypes")
import("rules.rules.ruleauthority")
import("rules.rules.rules")
import("rules.rulestate.rulestate_request")
import("script-config.rules.rules.rulesenvironment")
import("rules.sinbin.sinbinsystem")
import("rules.sinbin.sinbininfo_request")
import("rules.sinbin.sinbincutscene_request")
import("rules.sinbin.playersentoff_request")

local var_0_0

rulestateclass.rulestateclass("ScrumSetupRuleState", function(arg_1_0, arg_1_1)
	for iter_1_0, iter_1_1 in pairs(ScrumSetupRuleState.MemberDefinitions) do
		arg_1_0[iter_1_0] = arg_1_1[iter_1_0]
	end
end).MemberDefinitions = {
	scrumPosition = types.Vec2,
	sideWithFeed = types.SignedInteger,
	randomSeed = types.SignedInteger
}

function ScrumSetupRuleState.apply(arg_2_0, arg_2_1, arg_2_2)
	local var_2_0 = arg_2_1:getMatchProgressionEntity()

	var_2_0:clearLineBroken()
	var_2_0:clearBallDead()
	matchtime.updateTime(arg_2_1, arg_2_2)
	matchtime.startStoppageTime(arg_2_1, arg_2_2)
end

function ScrumSetupRuleState.activateObjects(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7)
	interchange_helper.activateOnFieldObjects(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7)
end

function ScrumSetupRuleState.getBlockSwitchingGamers(arg_4_0, arg_4_1)
	return true
end

function ScrumSetupRuleState.onEnterSolid(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7, arg_5_8, arg_5_9, arg_5_10)
	local var_5_0 = arg_5_3.hooks

	if var_5_0 then
		var_5_0:getHook("KnockOnDebugHook"):resetBehaviourFn(arg_5_8)
	end

	arg_5_10:add(resettacklecount_request.ResetTackleCountRequest({}))

	for iter_5_0, iter_5_1 in arg_5_7:activeObjects(playertype.TypeId) do
		iter_5_1.offsideInfo:clearOffside()
	end

	local var_5_1 = arg_5_0.sideWithFeed
	local var_5_2 = sidehelper.getOtherSide(var_5_1)
	local var_5_3 = arg_5_5:getComponent("matchInData")
	local var_5_4 = arg_5_5:getSide(var_5_1)
	local var_5_5 = arg_5_5:getSide(var_5_2)
	local var_5_6 = var_5_3:getClub(var_5_4.side)
	local var_5_7 = var_5_3:getClub(var_5_5.side)
	local var_5_8 = arg_5_0.scrumPosition
	local var_5_9 = var_5_4:getPlayDir()
	local var_5_10 = var_5_3.matchType.categorisedMatchType == native.EMatchType.MT_Nines
	local var_5_11 = var_5_5:getPlayDir().x < 0 and -50 or 50
	local var_5_12 = math.abs(var_5_8.x - var_5_11) < 80
	local var_5_13 = arg_5_3.knowledgeBank
	local var_5_14 = var_5_13.activeTeamPlayerIdListPair

	ASSERT(var_5_14)

	local var_5_15 = arg_5_6:getSinBinInfoPool()

	local function var_5_16(arg_6_0)
		local var_6_0 = var_5_14:get(arg_6_0)

		ASSERT(var_6_0)

		for iter_6_0, iter_6_1 in var_6_0:iter() do
			if var_5_15:get(iter_6_1).status ~= native.ESinBinState.OnField then
				return true
			end
		end

		return false
	end

	local var_5_17 = (var_5_10 or var_5_16(var_5_1)) and 9 or 13
	local var_5_18 = (var_5_10 or var_5_16(var_5_2)) and 9 or 13
	local var_5_19 = var_5_4:getActivePlayers(arg_5_7)
	local var_5_20 = scrum_helper.GetScrumPlayers(var_5_4, var_5_6, arg_5_7, arg_5_6, arg_5_3, scrum_config.Positions[var_5_17].Attacking, false, var_5_1)
	local var_5_21 = scrum_helper.MapPlayerIDToScrumSlot(var_5_20, scrum_config.IDMap[var_5_17].Attacking)
	local var_5_22 = var_5_5:getActivePlayers(arg_5_7)
	local var_5_23 = scrum_helper.GetScrumPlayers(var_5_5, var_5_7, arg_5_7, arg_5_6, arg_5_3, scrum_config.Positions[var_5_18].Defending, var_5_12, var_5_1)
	local var_5_24 = scrum_helper.MapPlayerIDToScrumSlot(var_5_23, scrum_config.IDMap[var_5_18].Defending)
	local var_5_25 = table.concat(var_5_20, ", ")

	formatPrintT("[ScrumSetupRuleState] - side: %t, scrumPlayers: %t", var_5_4.side, var_5_25)

	local var_5_26 = table.concat(var_5_23, ", ")

	formatPrintT("[ScrumSetupRuleState] - side: %t, scrumPlayers: %t", var_5_5.side, var_5_26)

	local var_5_27 = scrum_helper.ShouldChangeScrumRotation(var_5_8, var_5_9.x)
	local var_5_28 = arg_5_6:getScrumEntity()

	var_5_28:clearScrumEndTime()

	var_5_28.isActive = true
	var_5_28.scrumPosition = arg_5_0.scrumPosition
	var_5_28.playDirection = var_5_9.x
	var_5_28.scrumType = (var_5_10 or var_5_16(var_5_1)) and native.EScrumType.FeederCollects or native.EScrumType.OtherCollects
	var_5_28.mirrored = var_5_27

	local var_5_29 = var_5_3.onlineMultiplayer
	local var_5_30 = var_5_13.playerScrumInfoPool
	local var_5_31
	local var_5_32

	local function var_5_33(arg_7_0, arg_7_1, arg_7_2)
		local var_7_0 = var_5_30:get(arg_7_0)

		var_7_0.scrumPositionId = arg_7_1

		if var_5_29 then
			local var_7_1 = 186

			var_7_0.dispersalTime = arg_5_8 + var_7_1 / 30 + 2
		end

		arg_7_2[arg_7_0] = nil

		local var_7_2 = arg_5_3.actionProducer:getScrumContainer()
		local var_7_3 = var_5_28.scrumType
		local var_7_4 = var_7_2:getAnimationGroup(var_7_3, var_5_27)

		if var_7_4.feederPositionId == arg_7_1 then
			var_5_28.feederPositionId = arg_7_1

			arg_5_6:getBallEntity():setOwnerId(arg_7_0, arg_5_8, var_5_28.scrumPosition, arg_5_6)

			local var_7_5 = arg_5_7:getGameObject(arg_7_0)
			local var_7_6 = var_7_5:getPlayDir()

			var_7_5:resetTo(var_5_28.scrumPosition, var_7_6, arg_5_8)

			var_5_32 = arg_7_0
		end

		if var_7_4.receiverPositionId == arg_7_1 then
			var_5_28.receiverPositionId = arg_7_1
			var_5_28.receiverId = arg_7_0
			var_5_31 = arg_7_0
		end
	end

	for iter_5_2, iter_5_3 in pairs(var_5_21) do
		var_5_33(iter_5_2, iter_5_3, var_5_19)
	end

	for iter_5_4, iter_5_5 in pairs(var_5_24) do
		var_5_33(iter_5_4, iter_5_5, var_5_22)
	end

	ASSERT(var_5_32)
	ASSERT(var_5_31)

	local function var_5_34(arg_8_0)
		for iter_8_0, iter_8_1 in pairs(arg_8_0) do
			local var_8_0 = arg_5_7:getGameObject(iter_8_0)

			var_5_30:get(iter_8_0).scrumPositionId = -1
		end
	end

	var_5_34(var_5_19)
	var_5_34(var_5_22)

	local var_5_35 = {
		sideWithFeed = arg_5_0.sideWithFeed,
		scrumPosition = var_5_8,
		scrumReceiverId = var_5_31,
		directionOfPlay = var_5_9
	}

	-- scrum-feed-control: hold the scrum on the feed clock first.
	local var_5_control = rawget(_G, "ScrumControlState")

	if var_5_control and var_5_control.isActive(arg_5_5, arg_5_6) then
		var_5_35.feederId = var_5_32
		arg_5_0.nextState = class.instantiate("ScrumFeedPendingRuleState", var_5_35)
	else
		arg_5_0.nextState = class.instantiate("ScrumRuleState", var_5_35)
	end

	local var_5_36 = arg_5_6:getIncapacitatedInfoPool()
	local var_5_incapacitated = var_5_control and var_5_control.incapacitatedSeconds(arg_5_5, arg_5_6) or 20

	local function var_5_37(arg_9_0, arg_9_1)
		local var_9_0 = arg_9_1:get(arg_9_0)

		var_9_0.incapacitatedStartTime = arg_5_8
		var_9_0.incapacitatedStopTime = arg_5_8 + var_5_incapacitated
		var_9_0.incapacitatedAppliesToSwitching = true
		var_9_0.inSuccessfulTackle = false
	end

	for iter_5_6, iter_5_7 in pairs(var_5_23) do
		var_5_37(iter_5_7, var_5_36)
	end

	for iter_5_8, iter_5_9 in pairs(var_5_20) do
		if iter_5_9 ~= var_5_31 then
			var_5_37(iter_5_9, var_5_36)
		end
	end

	local var_5_38 = arg_5_6:getTeamFormationEntityPair()

	ASSERT(var_5_38)

	local var_5_39 = var_5_38:get(sidehelper.home)
	local var_5_40 = var_5_38:get(sidehelper.away)

	var_5_39.formationFocus = native.EFormationFocus.Manual
	var_5_39.manualFocusPoint = var_5_8
	var_5_40.formationFocus = native.EFormationFocus.Manual
	var_5_40.manualFocusPoint = var_5_8

	cheerleader_helper.positionCheerleaders(arg_5_3, arg_5_5, arg_5_7, arg_5_8)
	matchtime.updateTime(arg_5_6, arg_5_8)

	local var_5_41, var_5_42 = arg_5_3.gameplayCameras:getActiveGroup()

	var_5_42.activeCamera:reset(nil)
	camerahelper.SetActiveCameraGroupGameplay(arg_5_3, arg_5_5, arg_5_7)
end

function ScrumSetupRuleState.advanceRuleState(arg_10_0)
	return arg_10_0.nextState
end

-- scrum-feed-control (settings + overview in game/scrum/scrum_helper.lua). build.py can't add
-- script files, so the new classes live here: this module is registered at boot
-- (rulestate_registration.lua).
--
--   ScrumPositionSelectRuleState  human feed: LEFT / MIDDLE / RIGHT on the penalty prompt,
--                                 clock on the scoreboard; out of time = stock spot
--   ScrumFeedPendingRuleState     pack set, scrum clock; FEED (human) or the AI's random
--                                 moment -> ScrumRuleState; out of time = penalty to the
--                                 other side at the scrum
--   ScrumControlGameController    reads the prompt buttons (input -> session flags)
--   ScrumControlDetect            per-frame clock / HUD / transitions (owner:controlUpdate)
--
-- Offside line: every player outside the scrum gets the x he stands on when the pack is set.
-- Going past it before the ball is out of the scrum flags him (sticky); a flagged tackler is
-- penalised by TackleDetect (referee-on-report's tackle_detect.lua asks isScrumOffside).

local var_0_control = rawget(_G, "ScrumControlState") or {}

local function var_0_log(arg_text)
	if var_0_control.log then
		var_0_control.log(arg_text)
	end
end

local function var_0_settings()
	return var_0_control.settings or {}
end

local function var_0_promptHud(arg_services)
	local var_hud = arg_services and arg_services.hud
	local var_element = var_hud and var_hud:getElement("penaltySelect")

	if var_element and var_element.showScrumPrompt then
		return var_element
	end
end

local function var_0_hideHud(arg_services)
	local var_prompt = var_0_promptHud(arg_services)

	if var_prompt then
		var_prompt:hideScrumPrompt()
	end
end

-- The clock is in the prompt's title ("SCRUM 4", red for the last 3 seconds), so it only shows
-- while a human has something to do. "OFFSIDE" for a moment after a human-controlled player
-- crosses his line. No prompt (AI feed): nothing to show.
local function var_0_showClock(arg_services, arg_session, arg_label, arg_dt)
	local var_prompt = var_0_promptHud(arg_services)

	if arg_session.offsideWarn and arg_session.offsideWarn > 0 then
		arg_session.offsideWarn = arg_session.offsideWarn - (arg_dt or 0)

		if var_prompt then
			var_prompt:setScrumTitle("OFFSIDE", true)
		end
	elseif var_prompt and arg_session.remaining then
		var_prompt:setScrumTitle(arg_label .. "  " .. tostring(math.max(0, math.ceil(arg_session.remaining))), arg_session.remaining <= 3)
	end
end

local function var_0_newSession(arg_phase, arg_side, arg_human, arg_seconds)
	var_0_control.sessionCounter = (var_0_control.sessionCounter or 0) + 1

	local var_session = {
		id = var_0_control.sessionCounter,
		phase = arg_phase,
		side = arg_side,
		human = arg_human,
		remaining = arg_seconds,
		total = arg_seconds,
		elapsed = 0
	}

	var_0_control.session = var_session

	return var_session
end

-- native Random:next(min, max) only gave whole numbers (feeds at 2.0 / 4.0 / 5.0 s), so it only
-- seeds the fraction.
local function var_0_random(arg_min, arg_max)
	local var_ok, var_value = pcall(function()
		return native.Random.FromSystemTime():next(0, 1000000)
	end)
	local var_fraction = var_ok and type(var_value) == "number" and var_value / 1000000 or math.random()

	return arg_min + var_fraction * (arg_max - arg_min)
end

-- LEFT (1) / MIDDLE (2) / RIGHT (3) -> y, as the feeding side attacks along arg_dirX.
local function var_0_laneY(arg_choice, arg_dirX)
	local var_lane = rulesenvironment.fieldWidth * 0.5 - scrum_config.offsetFromSideLine
	-- Confirmed in game 2026-11-01: +y is the attacking side's right (was mirrored).
	local var_left = arg_dirX < 0 and var_lane or -var_lane

	if var_0_settings().flipLeftRight then
		var_left = -var_left
	end

	if arg_choice == 1 then
		return var_left
	elseif arg_choice == 3 then
		return -var_left
	end

	return 0
end

local function var_0_closestLane(arg_y, arg_dirX)
	local var_best, var_bestDistance = 2, math.huge

	for iter_choice = 1, 3 do
		local var_distance = math.abs(var_0_laneY(iter_choice, arg_dirX) - arg_y)

		if var_distance < var_bestDistance then
			var_best, var_bestDistance = iter_choice, var_distance
		end
	end

	return var_best
end

local var_0_laneNames = {
	"LEFT",
	"MIDDLE",
	"RIGHT"
}

local function var_0_showPlayerMarkers(arg_services)
	if not arg_services.gamers then
		return
	end

	for iter_0, iter_gamer in arg_services.gamers:iterLocalGamers() do
		local var_markers = arg_services.hud and arg_services.hud:getElement("playermarkers")

		if var_markers then
			var_markers:enableMarkerForGamer(iter_gamer)
			var_markers:show()
		end
	end
end

-- Offside line -------------------------------------------------------------------------------

var_0_control.offside = var_0_control.offside or {
	lines = {},
	flagged = {},
	tracking = false
}

function var_0_control.clearScrumOffside()
	local var_offside = var_0_control.offside

	var_offside.lines = {}
	var_offside.flagged = {}
	var_offside.creepers = {}
	var_offside.tracking = false
	var_offside.flagUntil = nil
end

-- arg_time: the tackle's time (native.Time) or nil.
function var_0_control.isScrumOffside(arg_id, arg_time)
	local var_offside = var_0_control.offside

	if not arg_id or not var_offside.flagged[arg_id] then
		return false
	end

	if var_offside.tracking or not var_offside.flagUntil or not arg_time then
		return true
	end

	return not (var_offside.flagUntil < arg_time)
end

local function var_0_startOffsideLines(arg_services, arg_gameobjects, arg_sideWithFeed, arg_scrumPosition)
	var_0_control.clearScrumOffside()

	local var_offside = var_0_control.offside

	var_offside.scrumPosition = arg_scrumPosition
	local var_pending = var_0_control.pendingRepackAgainst

	var_offside.repackAgainst = var_pending and var_pending.side
	var_offside.repackCount = var_pending and var_pending.count or 0
	var_0_control.pendingRepackAgainst = nil
	var_0_control.repackOffer = nil
	local var_scrumInfo = arg_services.knowledgeBank.playerScrumInfoPool

	var_offside.defenders = {}

	for iter_id, iter_player in arg_gameobjects:activeObjects(playertype.TypeId) do
		if iter_player.side ~= arg_sideWithFeed then
			var_offside.defenders[iter_id] = true
		end

		if not var_scrumInfo:get(iter_id):checkForValidId() then
			var_offside.lines[iter_id] = {
				x = iter_player.pos.x,
				dir = iter_player:getPlayDir().x < 0 and -1 or 1
			}
		end
	end

	var_offside.tracking = true
end

function var_0_control.trackScrumOffside(arg_session, arg_gameobjects)
	local var_offside = var_0_control.offside

	if not var_offside.tracking then
		return
	end

	local var_settings = var_0_settings()
	local var_tolerance = var_settings.offsideTolerance or 0.5

	for iter_id, iter_line in pairs(var_offside.lines) do
		if not var_offside.flagged[iter_id] then
			local var_player = arg_gameobjects:getGameObject(iter_id, playertype.TypeId)
			local var_human = var_player and var_player:getGamer() ~= nil

			if var_player and (var_human or var_settings.offsideAiPlayers or var_offside.creepers[iter_id]) and (var_player.pos.x - iter_line.x) * iter_line.dir > var_tolerance then
				var_offside.flagged[iter_id] = true

				var_0_log(string.format("offside: player %d is %.1f m past his line (human %s)", iter_id, (var_player.pos.x - iter_line.x) * iter_line.dir, tostring(var_human)))

				if var_human and arg_session then
					arg_session.offsideWarn = 1.5
				end
			end
		end
	end
end

-- AI line adjustments -----------------------------------------------------------------------------
-- While the scrum is fed, AI players outside it shuffle their line: some shift sideways or drop
-- back (legal), and now and then an AI defender creeps up past his line (offside: he's in
-- offside.creepers, so trackScrumOffside flags him even though he's AI). Moves are walked with
-- CMoveToTarget, like the kick-off run-up.

local function var_0_difficultyChance(arg_match, arg_table, arg_default)
	local var_chance = arg_default
	local var_ok, var_difficulty = pcall(function()
		return arg_match:getComponent("matchInfo"):getDifficultyLevel()
	end)

	if var_ok and var_difficulty then
		for iter_difficulty, iter_chance in pairs(arg_table or {}) do
			if iter_difficulty == var_difficulty then
				var_chance = iter_chance
			end
		end
	end

	return var_chance
end

local function var_0_planAiLines(arg_session, arg_match, arg_gameobjects, arg_sideWithFeed)
	local var_settings = var_0_settings()
	local var_offside = var_0_control.offside
	local var_all, var_defenders = {}, {}

	for iter_id in pairs(var_offside.lines) do
		local var_player = arg_gameobjects:getGameObject(iter_id, playertype.TypeId)

		if var_player and var_player:getGamer() == nil then
			table.insert(var_all, iter_id)

			if var_player.side ~= arg_sideWithFeed then
				table.insert(var_defenders, iter_id)
			end
		end
	end

	local function var_pick(arg_list)
		if #arg_list == 0 then
			return nil
		end

		local var_index = math.min(#arg_list, 1 + math.floor(var_0_random(0, #arg_list)))

		return table.remove(arg_list, var_index)
	end

	arg_session.lineMoves = {}

	local var_creepChance = var_settings.testAiAlwaysCreeps and 100 or var_0_difficultyChance(arg_match, var_settings.aiCreepChance, var_settings.aiCreepChanceDefault or 8)

	if var_0_random(0, 100) < var_creepChance then
		local var_id = var_pick(var_defenders)

		if var_id then
			var_offside.creepers[var_id] = true

			table.insert(arg_session.lineMoves, {
				creep = true,
				id = var_id,
				at = var_0_random(0.3, 1.2),
				forward = var_0_random(1.5, 3),
				across = var_0_random(-1, 1)
			})

			for iter_index = #var_all, 1, -1 do
				if var_all[iter_index] == var_id then
					table.remove(var_all, iter_index)
				end
			end
		end
	end

	if var_0_random(0, 100) < (var_settings.aiLineAdjustChance or 60) then
		for iter_0 = 1, 1 + math.floor(var_0_random(0, 3)) do
			local var_id = var_pick(var_all)

			if not var_id then
				break
			end

			table.insert(arg_session.lineMoves, {
				id = var_id,
				at = var_0_random(0.2, 1.5),
				forward = -var_0_random(0, 1.5),
				across = var_0_random(-3, 3)
			})
		end
	end

	for iter_0, iter_move in ipairs(arg_session.lineMoves) do
		var_0_log(string.format("AI line: player %d %s %.1f m forward, %.1f m across at %.1f s", iter_move.id, iter_move.creep and "CREEPS" or "adjusts", iter_move.forward, iter_move.across, iter_move.at))
	end
end

function var_0_control.runAiLineMoves(arg_session, arg_services, arg_guid, arg_gameobjects, arg_time, arg_requests)
	local var_lines = var_0_control.offside.lines
	local var_halfWidth = rulesenvironment.fieldWidth * 0.5 - 1

	for iter_0, iter_move in ipairs(arg_session.lineMoves or {}) do
		if not iter_move.done and (arg_session.elapsed or 0) >= iter_move.at then
			iter_move.done = true

			local var_player = arg_gameobjects:getGameObject(iter_move.id, playertype.TypeId)
			local var_line = var_lines[iter_move.id]

			-- A human may have switched to him since.
			if var_player and var_line and var_player:getGamer() == nil then
				local var_ok, var_error = pcall(function()
					local var_target = native.vec2(var_line.x + var_line.dir * iter_move.forward, native.clamp1(var_player.pos.y + iter_move.across, -var_halfWidth, var_halfWidth))
					local var_command = native.CMoveToTarget(iter_move.id, var_target, arg_time, arg_services)

					var_command.facing = var_player.facing
					var_command.speed = var_player:getDerivedAttribute("walk_speed")

					arg_requests:add(native.CMovementRequest(iter_move.id, arg_guid:alloc(), var_command))
				end)

				if not var_ok then
					var_0_log("AI line: player " .. tostring(iter_move.id) .. " move failed: " .. tostring(var_error))
				end
			end
		end
	end
end

-- The ball is out of the scrum: crossing the line is legal from here; flagged players stay
-- offside for offsideFlagSeconds (or until the first tackle completes).
function var_0_control.scrumBallOut(arg_time)
	local var_offside = var_0_control.offside

	if not var_offside.tracking then
		return
	end

	var_offside.tracking = false

	if var_0_settings().testAlwaysOffside then
		for iter_id in pairs(var_offside.defenders or {}) do
			var_offside.flagged[iter_id] = true
		end

		var_0_log("TEST: every defender flagged offside")
	end

	local var_count = 0

	for iter_id in pairs(var_offside.flagged) do
		var_count = var_count + 1
	end

	if var_count > 0 and arg_time then
		var_offside.flagUntil = arg_time + native.Time.FromSeconds(var_0_settings().offsideFlagSeconds or 10)
	end

	var_0_log(string.format("ball out of the scrum, %d player(s) offside", var_count))
end

-- Repack -------------------------------------------------------------------------------------
-- An offside penalty off a scrum (not a scrum infringement such as the feed clock) lets the
-- side awarded it pack the scrum again at the same spot instead (SCRUM on the penalty choice,
-- rules/penalty/penaltyselectpending_rulestate.lua). Offered by bunker-overturned-try's
-- generalgameplay_rulestate.lua when the offside penalty has scrumOffside.

function var_0_control.offerRepack(arg_side, arg_offenceNumber)
	local var_position = var_0_control.offside.scrumPosition

	if var_position then
		var_0_control.repackOffer = {
			position = var_position,
			side = arg_side,
			count = arg_offenceNumber or 1
		}

		var_0_log(string.format("repack offered to side %s at (%.1f, %.1f)", tostring(arg_side), var_position.x, var_position.y))
	end
end

-- Offences in a row by one side, scrum after repacked scrum (1 = the first offside). Called by
-- generalgameplay_rulestate.lua: 2nd -> the tackler is sin binned, 3rd -> sent off and no
-- repack offered. The penalty goes on as normal; the cutscene plays when the option is picked.
function var_0_control.scrumOffenceNumber(arg_offendingSide)
	local var_offside = var_0_control.offside

	if var_offside.repackAgainst ~= nil and var_offside.repackAgainst == arg_offendingSide then
		return (var_offside.repackCount or 0) + 1
	end

	return 1
end

function var_0_control.scrumSinBin(arg_services, arg_match, arg_gamestate, arg_gameobjects, arg_offenderId, arg_time, arg_requests, arg_sendOff)
	local var_sinBinSystem = arg_services.sinBinSystem
	local var_player = arg_offenderId and arg_gameobjects:getGameObject(arg_offenderId, playertype.TypeId)

	if not var_sinBinSystem or not var_player then
		var_0_log("repeat offside: no sin bin system / offender")

		return
	end

	local var_ok, var_error = pcall(function()
		local var_config = sinbinsystem.sinbin_config
		local var_side = var_player:getSide()
		local var_matchInData = arg_match:getComponent("matchInData")
		local var_nines = var_matchInData.matchType.categorisedMatchType == native.EMatchType.MT_Nines
		local var_info = {
			penaltyComplete = false,
			id = arg_offenderId,
			side = var_side,
			status = var_config.sinbinStatus.SinBin,
			entryElapsedMatchTime = arg_match:getComponent("matchInfo"):getMatchSecondsElapsedClamped(arg_gamestate, arg_time),
			penaltyDuration = var_nines and var_config.sinbinDurationAucklandNines or var_config.sinbinDuration
		}

		var_sinBinSystem.playerPenalised[var_side] = true

		if not arg_sendOff then
			var_sinBinSystem:sendPlayerToSinBin(arg_match, arg_offenderId, var_player, var_side, var_info, native.Random.FromSystemTime():nextAsSeed(), arg_requests)

			return
		end

		-- Red card: the same requests SinBinSystem sends for a send-off.
		local var_rules = var_matchInData.rules

		var_info.status = var_config.sinbinStatus.SentOff

		arg_requests:add(sinbininfo_request.SinBinInfoRequest(var_info))
		arg_requests:add(sinbincutscene_request.SinBinCutsceneRequest({
			primaryTargetId = arg_offenderId,
			primarySide = var_side,
			subtext = "%SENTOFF%",
			cutsceneType = var_config.sendoffCutSceneName[var_rules],
			matchRules = var_rules:toInt(),
			randomSeed = native.Random.FromSystemTime():nextAsSeed()
		}))
		arg_requests:add(playersentoff_request.PlayerSentOffRequest({
			maker = arg_offenderId
		}))
	end)

	var_0_log(string.format("repeat offside after a repack: player %d %s (%s)", arg_offenderId, arg_sendOff and "SENT OFF" or "sin binned", var_ok and "ok" or tostring(var_error)))
end

function var_0_control.repackOfferFor(arg_side)
	local var_offer = var_0_control.repackOffer

	if var_offer and var_offer.side == arg_side then
		return var_offer
	end
end

Class("ScrumRepackDetect", function(arg_self, arg_owner)
	arg_self.owner = arg_owner
end)

ScrumRepackDetect.Authoritative = ruleauthority.both
ScrumRepackDetect.Events = {}

function ScrumRepackDetect.evaluate(arg_self)
	return
end

function ScrumRepackDetect.update(arg_self, arg_1, arg_gamers, arg_services, arg_guid, arg_match, arg_gamestate, arg_gameobjects, arg_dt, arg_time, arg_requests)
	local var_owner = arg_self.owner
	local var_offer = var_0_control.repackOffer

	if not var_0_control.repackChosen or not var_offer or var_owner.haveSentRulestateRequest then
		return
	end

	var_owner.haveSentRulestateRequest = true
	var_0_control.repackChosen = nil
	var_0_control.repackOffer = nil
	var_0_control.pendingRepackAgainst = {
		side = sidehelper.getOtherSide(var_offer.side),
		count = var_offer.count
	}

	var_owner:hideHud(arg_services)
	var_0_log(string.format("repack: scrum again at (%.1f, %.1f), feed side %s", var_offer.position.x, var_offer.position.y, tostring(var_offer.side)))

	local var_nextState = scrum_helper.GetScrumState({
		scrumPositionChosen = true,
		scrumPosition = var_offer.position,
		sideWithFeed = var_offer.side,
		randomSeed = native.Random.FromSystemTime():nextAsSeed()
	}, arg_services, arg_guid, arg_match, arg_gamestate, arg_gameobjects, arg_time, arg_requests)

	-- Like the stock penalty options: a sin bin given with this penalty plays its cutscene first.
	arg_requests:add(sinbinsystem.shouldPushSinBinCutscene(arg_services, var_nextState, arg_match:getComponent("matchInData"), arg_gamestate, arg_gameobjects, arg_requests, arg_guid:alloc(), var_owner.infringementById))
end

-- Prompt input -------------------------------------------------------------------------------

-- Reuses actions every pad map already has: the penalty choice buttons (square / triangle /
-- circle) for the position; cross / A or either pass button (L1 / R1) for the feed.
local var_0_positionInputs = {
	{
		"PenaltySelect",
		"TapRestart",
		1
	},
	{
		"PenaltySelect",
		"KickToTouch",
		2
	},
	{
		"PenaltySelect",
		"PenaltyGoalAttempt",
		3
	}
}
local var_0_feedInputs = {
	{
		"PlaceKick",
		"AcceptBallPosition"
	},
	{
		"Contest",
		"Collect"
	},
	{
		"AntVision",
		"Skip"
	},
	{
		"HaveBall",
		"PassLeft"
	},
	{
		"HaveBall",
		"PassRight"
	}
}

local function var_0_inputEvent(arg_gamer, arg_category, arg_action)
	local var_ok, var_event = pcall(function()
		return arg_gamer:getInputEvent(arg_category, arg_action)
	end)

	return var_ok and var_event
end

local var_0_gameController = gamecontroller.GameController

Class("ScrumControlGameController", var_0_gameController, function(arg_self, arg_args)
	arg_self.sessionId = arg_args.sessionId
	arg_self.side = arg_args.side
end)

function ScrumControlGameController.update(arg_self, arg_params, arg_gamers, arg_services, arg_guid, arg_match, arg_gamestate, arg_gameobjects, arg_dt, arg_time, arg_requests)
	local var_session = var_0_control.session

	if not var_session or var_session.id ~= arg_self.sessionId or var_session.finished then
		return nil
	end

	if var_session.phase ~= "position" and var_session.phase ~= "feed" then
		return nil
	end

	local var_home, var_away = arg_gamers:getLocalGamersSplitBySide(true)
	local var_gamers = arg_self.side == sidehelper.home and var_home or var_away

	for iter_0, iter_gamer in pairs(var_gamers or {}) do
		if var_session.phase == "position" and not var_session.choice then
			for iter_1, iter_input in ipairs(var_0_positionInputs) do
				if var_0_inputEvent(iter_gamer, iter_input[1], iter_input[2]) then
					var_session.choice = iter_input[3]

					break
				end
			end
		elseif var_session.phase == "feed" and not var_session.feedPressed then
			for iter_1, iter_input in ipairs(var_0_feedInputs) do
				if var_0_inputEvent(iter_gamer, iter_input[1], iter_input[2]) then
					var_session.feedPressed = true

					break
				end
			end
		end
	end

	if (var_session.choice or var_session.feedPressed) and not arg_self.playedSound then
		arg_self.playedSound = true

		if arg_services.uiServices then
			pcall(function()
				arg_services.uiServices:playSound("Select_No_Vib")
			end)
		end
	end

	return arg_self
end

local function var_0_addController(arg_gameControllerSet, arg_session)
	if not arg_gameControllerSet then
		return
	end

	if arg_gameControllerSet:get("scrumControl") then
		arg_gameControllerSet:remove("scrumControl")
	end

	arg_gameControllerSet:add("scrumControl", ScrumControlGameController({
		sessionId = arg_session.id,
		side = arg_session.side
	}))
end

-- Per-frame driver -----------------------------------------------------------------------------

Class("ScrumControlDetect", function(arg_self, arg_owner)
	arg_self.owner = arg_owner
end)

ScrumControlDetect.Authoritative = ruleauthority.both
ScrumControlDetect.Events = {}

function ScrumControlDetect.evaluate(arg_self)
	return
end

function ScrumControlDetect.update(arg_self, arg_1, arg_gamers, arg_services, arg_guid, arg_match, arg_gamestate, arg_gameobjects, arg_dt, arg_time, arg_requests)
	local var_session = var_0_control.session
	local var_owner = arg_self.owner

	if not var_session or var_session.id ~= var_owner.sessionId or var_session.finished then
		return
	end

	var_owner:controlUpdate(var_session, arg_gamers, arg_services, arg_guid, arg_match, arg_gamestate, arg_gameobjects, arg_dt or 0, arg_time, arg_requests)
end

-- Position select ------------------------------------------------------------------------------

rulestateclass.rulestateclass("ScrumPositionSelectRuleState", function(arg_1_0, arg_1_1)
	for iter_1_0, iter_1_1 in pairs(ScrumPositionSelectRuleState.MemberDefinitions) do
		arg_1_0[iter_1_0] = arg_1_1[iter_1_0]
	end
end).MemberDefinitions = {
	scrumPosition = types.Vec2,
	sideWithFeed = types.SignedInteger,
	randomSeed = types.SignedInteger
}

function ScrumPositionSelectRuleState.apply(arg_self, arg_gamestate, arg_time)
	matchtime.updateTime(arg_gamestate, arg_time)
	matchtime.startStoppageTime(arg_gamestate, arg_time)
end

function ScrumPositionSelectRuleState.getBlockSwitchingGamers(arg_self)
	return true
end

function ScrumPositionSelectRuleState.onEnterSolid(arg_self, arg_1, arg_gamers, arg_services, arg_guid, arg_match, arg_gamestate, arg_gameobjects, arg_time, arg_9, arg_requests)
	local var_settings = var_0_settings()
	local var_session = var_0_newSession("position", arg_self.sideWithFeed, true, var_settings.positionSelectSeconds or 5)

	arg_self.sessionId = var_session.id
	var_session.dirX = arg_match:getSide(arg_self.sideWithFeed):getPlayDir().x
	var_session.defaultChoice = var_0_closestLane(arg_self.scrumPosition.y, var_session.dirX)

	for iter_id, iter_player in arg_gameobjects:activeObjects(playertype.TypeId) do
		iter_player:setBehaviour("Idle", arg_time)
	end

	-- The state before can leave a cameo camera up (referee signal).
	pcall(function()
		camerahelper.SetActiveCameraGroupGameplay(arg_services, arg_match, arg_gameobjects)
	end)

	var_0_addController(arg_1 and arg_1.gameControllerSet, var_session)

	local var_prompt = var_0_promptHud(arg_services)

	if var_prompt then
		local var_options = {}

		for iter_choice, iter_glyph in ipairs({
			"|SQUARE|",
			"|TRIANGLE|",
			"|CIRCLE|"
		}) do
			var_options[iter_choice] = {
				glyph = iter_glyph,
				text = var_0_laneNames[iter_choice] .. (iter_choice == var_session.defaultChoice and " (AUTO)" or "")
			}
		end

		var_prompt:showScrumPrompt({
			title = "SCRUM",
			side = arg_self.sideWithFeed,
			options = var_options
		})
	end

	var_0_showClock(arg_services, var_session, "SCRUM", 0)
	var_0_log(string.format("position select: side %s, default %s, %.1f s", tostring(arg_self.sideWithFeed), var_0_laneNames[var_session.defaultChoice], var_session.total))
end

function ScrumPositionSelectRuleState.createRules(arg_self, arg_1, arg_time)
	local var_rules = rules.Rules()

	var_rules:add(ScrumControlDetect(arg_self))

	return var_rules
end

function ScrumPositionSelectRuleState.controlUpdate(arg_self, arg_session, arg_gamers, arg_services, arg_guid, arg_match, arg_gamestate, arg_gameobjects, arg_dt, arg_time, arg_requests)
	if arg_self.haveSentRulestateRequest then
		return
	end

	arg_session.remaining = arg_session.remaining - arg_dt
	arg_session.elapsed = arg_session.elapsed + arg_dt

	var_0_showClock(arg_services, arg_session, "SCRUM", arg_dt)

	if not arg_session.choice and arg_session.remaining > 0 then
		return
	end

	arg_self.haveSentRulestateRequest = true
	arg_session.finished = true

	local var_position = arg_self.scrumPosition

	if arg_session.choice then
		var_position = native.vec2(var_position.x, var_0_laneY(arg_session.choice, arg_session.dirX))
	end

	var_0_log(string.format("position select: %s -> (%.1f, %.1f)", arg_session.choice and var_0_laneNames[arg_session.choice] or "timed out, stock spot", var_position.x, var_position.y))
	var_0_hideHud(arg_services)

	local var_nextState = scrum_helper.GetScrumState({
		scrumPositionChosen = true,
		scrumPosition = var_position,
		sideWithFeed = arg_self.sideWithFeed,
		randomSeed = arg_self.randomSeed
	}, arg_services, arg_guid, arg_match, arg_gamestate, arg_gameobjects, arg_time, arg_requests)

	arg_requests:add(rulestate_request.RuleStateRequest(var_nextState, arg_guid:alloc()))
end

function ScrumPositionSelectRuleState.onExitSolid(arg_self, arg_1, arg_gamers, arg_services)
	local var_session = var_0_control.session

	if var_session and var_session.id == arg_self.sessionId then
		var_session.finished = true
	end

	var_0_hideHud(arg_services)
end

-- Feed clock -------------------------------------------------------------------------------------

rulestateclass.rulestateclass("ScrumFeedPendingRuleState", function(arg_1_0, arg_1_1)
	for iter_1_0, iter_1_1 in pairs(ScrumFeedPendingRuleState.MemberDefinitions) do
		arg_1_0[iter_1_0] = arg_1_1[iter_1_0]
	end
end).MemberDefinitions = {
	sideWithFeed = types.SignedInteger,
	scrumPosition = types.Vec2,
	scrumReceiverId = types.ObjectId,
	directionOfPlay = types.Vec2,
	feederId = types.ObjectId
}

function ScrumFeedPendingRuleState.apply(arg_self, arg_gamestate, arg_time)
	matchtime.updateTime(arg_gamestate, arg_time)
	matchtime.startStoppageTime(arg_gamestate, arg_time)
end

-- Players outside the scrum can be switched to (the scrum players are incapacitated for
-- switching by ScrumSetupRuleState).
function ScrumFeedPendingRuleState.getBlockSwitchingGamers(arg_self)
	return false
end

-- The pack stands on its scrum animation start spots (where ScrumBase would snap it) until the
-- feed, so the snap isn't seen when the scrum starts.
local function var_0_packScrum(arg_services, arg_gamestate, arg_gameobjects, arg_time)
	local var_scrumInfo = arg_services.knowledgeBank.playerScrumInfoPool
	local var_entity = arg_gamestate:getScrumEntity()
	local var_container = arg_services.actionProducer:getScrumContainer()
	local var_group = var_container:getAnimationGroup(var_entity.scrumType, var_entity.mirrored)
	local var_dir = var_entity.playDirection < 0 and native.vec2.XAxis() * -1 or native.vec2.XAxis()

	for iter_id, iter_player in arg_gameobjects:activeObjects(playertype.TypeId) do
		local var_info = var_scrumInfo:get(iter_id)

		if var_info:checkForValidId() then
			local var_ok, var_error = pcall(function()
				local var_animation = var_container:getAnimation(var_group, var_info.scrumPositionId)
				local var_position = native.rotateByDir2(var_dir, var_animation.position) + var_entity.scrumPosition
				local var_facing = native.rotateByDir2(var_dir, var_animation.facing)

				iter_player:resetTo(var_position, var_facing, arg_time)
			end)

			if not var_ok then
				var_0_log("pack: player " .. tostring(iter_id) .. " not moved: " .. tostring(var_error))
			end

			iter_player:setBehaviour("Idle", arg_time)
		else
			iter_player:setBehaviour("Scrum", arg_time)
		end
	end
end

local function var_0_aiViolationChance(arg_match)
	local var_settings = var_0_settings()
	local var_chance = var_settings.aiViolationChanceDefault or 4
	local var_ok, var_difficulty = pcall(function()
		return arg_match:getComponent("matchInfo"):getDifficultyLevel()
	end)

	if var_ok and var_difficulty then
		for iter_difficulty, iter_chance in pairs(var_settings.aiViolationChance or {}) do
			if iter_difficulty == var_difficulty then
				var_chance = iter_chance
			end
		end
	end

	return var_chance, var_ok and tostring(var_difficulty) or "?"
end

function ScrumFeedPendingRuleState.onEnterSolid(arg_self, arg_1, arg_gamers, arg_services, arg_guid, arg_match, arg_gamestate, arg_gameobjects, arg_time, arg_9, arg_requests)
	local var_settings = var_0_settings()
	local var_human = arg_gamestate:getGamerSideEntity():isAnyGamerOnSide(arg_self.sideWithFeed)
	local var_session = var_0_newSession("feed", arg_self.sideWithFeed, var_human, var_settings.feedClockSeconds or 10)

	arg_self.sessionId = var_session.id

	var_0_packScrum(arg_services, arg_gamestate, arg_gameobjects, arg_time)

	for iter_id, iter_umpire in arg_gameobjects:activeObjects(umpiretype.TypeId) do
		iter_umpire:setBehaviour("Master", arg_time)
	end

	var_0_showPlayerMarkers(arg_services)
	var_0_startOffsideLines(arg_services, arg_gameobjects, arg_self.sideWithFeed, arg_self.scrumPosition)
	var_0_planAiLines(var_session, arg_match, arg_gameobjects, arg_self.sideWithFeed)

	if var_human then
		var_0_addController(arg_1 and arg_1.gameControllerSet, var_session)

		local var_prompt = var_0_promptHud(arg_services)

		if var_prompt then
			var_prompt:showScrumPrompt({
				title = "SCRUM",
				side = arg_self.sideWithFeed,
				options = {
					{
						glyph = "|CROSS|",
						text = "FEED"
					},
					{
						glyph = "|L1| |R1|",
						text = "FEED"
					}
				}
			})
		end

		var_0_log(string.format("feed clock: human feed, side %s, %.1f s", tostring(arg_self.sideWithFeed), var_session.total))
	else
		local var_chance, var_difficulty = var_0_aiViolationChance(arg_match)

		var_session.aiViolation = var_0_random(0, 100) < var_chance
		var_session.aiFeedAt = var_0_random(var_settings.aiFeedMinSeconds or 1.5, math.min(var_settings.aiFeedMaxSeconds or 6, var_session.total - 0.5))

		var_0_log(string.format("feed clock: AI feed, side %s, difficulty %s, feeds at %.1f s, violation %s (%d%%)", tostring(arg_self.sideWithFeed), var_difficulty, var_session.aiFeedAt, tostring(var_session.aiViolation), var_chance))
	end

	var_0_showClock(arg_services, var_session, "SCRUM", 0)
end

function ScrumFeedPendingRuleState.createRules(arg_self, arg_1, arg_time)
	local var_rules = rules.Rules()

	var_rules:add(ScrumControlDetect(arg_self))

	return var_rules
end

function ScrumFeedPendingRuleState.controlUpdate(arg_self, arg_session, arg_gamers, arg_services, arg_guid, arg_match, arg_gamestate, arg_gameobjects, arg_dt, arg_time, arg_requests)
	-- Fed (ScrumRuleState takes over the session) or penalised: the request is out.
	if arg_self.haveSentRulestateRequest then
		return
	end

	arg_session.remaining = arg_session.remaining - arg_dt
	arg_session.elapsed = arg_session.elapsed + arg_dt

	var_0_control.runAiLineMoves(arg_session, arg_services, arg_guid, arg_gameobjects, arg_time, arg_requests)
	var_0_control.trackScrumOffside(arg_session, arg_gameobjects)
	var_0_showClock(arg_services, arg_session, "SCRUM", arg_dt)

	local var_feed

	if arg_session.human then
		var_feed = arg_session.feedPressed
	else
		var_feed = not arg_session.aiViolation and arg_session.elapsed >= arg_session.aiFeedAt
	end

	if var_feed then
		arg_self.haveSentRulestateRequest = true
		arg_session.phase = "scrum"
		arg_session.remaining = nil

		var_0_log(string.format("feed at %.1f s", arg_session.elapsed))

		local var_prompt = var_0_promptHud(arg_services)

		if var_prompt then
			var_prompt:hideScrumPrompt()
		end

		local var_scrumState = class.instantiate("ScrumRuleState", {
			sideWithFeed = arg_self.sideWithFeed,
			scrumPosition = arg_self.scrumPosition,
			scrumReceiverId = arg_self.scrumReceiverId,
			directionOfPlay = arg_self.directionOfPlay
		})

		arg_requests:add(rulestate_request.RuleStateRequest(var_scrumState, arg_guid:alloc()))

		return
	end

	if arg_session.remaining > 0 then
		return
	end

	-- Out of time: penalty to the other side at the scrum (as linedropout_rulestate's
	-- TimerExpired).
	arg_self.haveSentRulestateRequest = true
	arg_self.endedWithPenalty = true
	arg_session.finished = true

	var_0_hideHud(arg_services)
	var_0_control.clearScrumOffside()

	local var_otherSide = sidehelper.getOtherSide(arg_self.sideWithFeed)

	var_0_log(string.format("scrum clock expired: penalty to side %s at (%.1f, %.1f)", tostring(var_otherSide), arg_self.scrumPosition.x, arg_self.scrumPosition.y))
	arg_requests:add(scrumentity_request.ScrumEntityCollectFinishedRequest())

	local var_infringementTypes = penaltytypes.infringementTypes
	local var_penaltyState = penalty.generatePenaltyAwardedState(arg_gamers, arg_services, arg_guid, arg_match, arg_gamestate, arg_gameobjects, arg_time, arg_requests, {
		offendingSide = arg_self.sideWithFeed,
		penaltyPosition = arg_self.scrumPosition,
		offenderId = arg_self.feederId,
		penaltyAwardedToSide = var_otherSide,
		infringementTypes = var_infringementTypes,
		penaltyType = var_infringementTypes.TimerExpired,
		refereeSignal = native.EUmpireSignalTypes.None
	})

	arg_requests:add(rulestate_request.RuleStateRequest(var_penaltyState, arg_guid:alloc()))
end

function ScrumFeedPendingRuleState.onExitSolid(arg_self, arg_1, arg_gamers, arg_services, arg_guid, arg_match, arg_gamestate, arg_gameobjects)
	local var_session = var_0_control.session

	if var_session and var_session.id == arg_self.sessionId and var_session.phase ~= "scrum" then
		var_session.finished = true

		var_0_hideHud(arg_services)
		var_0_control.clearScrumOffside()
	end

	if not arg_self.endedWithPenalty then
		return
	end

	-- No scrum after all: nobody is part of one, nobody stays incapacitated.
	local var_scrumInfo = arg_services.knowledgeBank.playerScrumInfoPool

	for iter_id in arg_gameobjects:activeObjects(playertype.TypeId) do
		var_scrumInfo:get(iter_id).scrumPositionId = -1
	end

	native.CPoolWipeHandler.wipeIncapacitatedInfoPool(arg_gamestate:getIncapacitatedInfoPool(), arg_gamestate)
end
