import("game.npc.npctype")
import("base.side.sidehelper")

-- Black jeans (uniformBottom pants01, m_pants01_jeans_black_col) per sex.
PoloBottomGuid = {
	male = 20002,
	female = 20102
}
PoloFemaleGuidOffset = 100

-- native objects raise on unknown properties; read one without risking that
function tryGetField(arg_tc_38, arg_tc_39)
	local var_tc_56, var_tc_57 = pcall(function()
		return arg_tc_38[arg_tc_39]
	end)

	return var_tc_56 and var_tc_57 or nil
end

local function poloDistance(arg_tc_0, arg_tc_1, arg_tc_2, arg_tc_3)
	-- "redmean" weighted RGB distance: cheap and close enough to perceptual
	local var_tc_0 = (arg_tc_0.r + arg_tc_1) * 0.5
	local var_tc_1 = arg_tc_0.r - arg_tc_1
	local var_tc_2 = arg_tc_0.g - arg_tc_2
	local var_tc_3 = arg_tc_0.b - arg_tc_3

	return (2 + var_tc_0 / 256) * var_tc_1 * var_tc_1 + 4 * var_tc_2 * var_tc_2 + (2 + (255 - var_tc_0) / 256) * var_tc_3 * var_tc_3
end

function getPoloForColour(arg_tc_4)
	local var_tc_4 = PoloPalette[1]
	local var_tc_5

	if arg_tc_4 == nil then
		return var_tc_4
	end

	for iter_tc_0, iter_tc_1 in ipairs(PoloPalette) do
		local var_tc_6 = poloDistance(iter_tc_1, arg_tc_4.r, arg_tc_4.g, arg_tc_4.b)

		if var_tc_5 == nil or var_tc_6 < var_tc_5 then
			var_tc_4 = iter_tc_1
			var_tc_5 = var_tc_6
		end
	end

	return var_tc_4
end

local function isFemaleCoach(arg_tc_5)
	local var_tc_7, var_tc_8 = pcall(function()
		return arg_tc_5.identity.sex.isFemale
	end)

	return var_tc_7 and var_tc_8 == true
end

local function setOptionSafe(arg_tc_6, arg_tc_7, arg_tc_8)
	pcall(arg_tc_6.setOption, arg_tc_6, arg_tc_7, arg_tc_8)
end

-- Copy of the coach's own uniform config with the club-coloured polo and
-- black jeans. clubColour is a CRGB (identity.primaryRGBColour).
function makePoloUniform(arg_tc_9, arg_tc_10)
	local var_tc_9 = native.CVisualConfig("team")

	var_tc_9:copy(arg_tc_9.uniform)

	local var_tc_10 = isFemaleCoach(arg_tc_9)
	local var_tc_11 = getPoloForColour(arg_tc_10)

	var_tc_9:setOption("uniformTop", var_tc_11.guid + (var_tc_10 and PoloFemaleGuidOffset or 0))
	var_tc_9:setOption("uniformBottom", var_tc_10 and PoloBottomGuid.female or PoloBottomGuid.male)
	setOptionSafe(var_tc_9, "topType", 0)
	setOptionSafe(var_tc_9, "topPatternLayer01", 0)
	setOptionSafe(var_tc_9, "topPatternLayer02", 0)
	setOptionSafe(var_tc_9, "topPatternLayer03", 0)
	setOptionSafe(var_tc_9, "showTeamLogo", 0)

	return var_tc_9, var_tc_11
end

-- Club -> coach assignments, kept by the mod in the game folder. Official
-- (licensed) clubs are rebuilt by editOrCreateUserCreatedVersionOfClub every
-- time the club editor opens and saved only as a "custom licensed" delta
-- (saveCustomLicensed), which drops coachId, so club:setCoachId alone doesn't
-- survive. Keyed by academyId, which the match side also has (matchInData.home).
CoachAssignmentsFile = "teamcoaches_assignments.txt"

local var_tc_assignments

local function loadAssignments()
	if var_tc_assignments then
		return var_tc_assignments
	end

	var_tc_assignments = {}

	pcall(function()
		local var_tc_48 = io.open(CoachAssignmentsFile, "r")

		if var_tc_48 then
			for iter_tc_5 in var_tc_48:lines() do
				local var_tc_49, var_tc_50 = string.match(iter_tc_5, "^%s*(%d+)%s*=%s*(%d+)")

				if var_tc_49 then
					var_tc_assignments[tonumber(var_tc_49)] = tonumber(var_tc_50)
				end
			end

			var_tc_48:close()
		end
	end)

	return var_tc_assignments
end

function getAssignedCoachId(arg_tc_34)
	return arg_tc_34 and loadAssignments()[tonumber(arg_tc_34)] or nil
end

function setAssignedCoachId(arg_tc_35, arg_tc_36, arg_tc_37)
	local var_tc_51 = loadAssignments()

	var_tc_51[tonumber(arg_tc_35)] = arg_tc_36 and tonumber(arg_tc_36) or nil

	local var_tc_52, var_tc_53 = pcall(function()
		local var_tc_54 = {}

		for iter_tc_6 in pairs(var_tc_51) do
			table.insert(var_tc_54, iter_tc_6)
		end

		table.sort(var_tc_54)

		local var_tc_55 = assert(io.open(CoachAssignmentsFile, "w"))

		var_tc_55:write("# team-coaches: academy club id = coach NPC id\n")

		for iter_tc_7, iter_tc_8 in ipairs(var_tc_54) do
			var_tc_55:write(string.format("%d=%d\n", iter_tc_8, var_tc_51[iter_tc_8]))
		end

		var_tc_55:close()
	end)

	sidelineLog("academy: assignment club %s -> coach %s (%s)%s", tostring(arg_tc_35), tostring(arg_tc_36), tostring(arg_tc_37), var_tc_52 and "" or " WRITE FAILED " .. tostring(var_tc_53))
end

function getClubCoach(arg_tc_11, arg_tc_12)
	local var_tc_12 = arg_tc_12 and (getAssignedCoachId(tryGetField(arg_tc_12, "academyId") or tryGetField(arg_tc_12, "id")) or arg_tc_12.coachId)

	if var_tc_12 == nil or var_tc_12 == 0 then
		return nil
	end

	local var_tc_13, var_tc_14 = pcall(function()
		return arg_tc_11:getRefereeManager():getReferee(var_tc_12)
	end)

	if not var_tc_13 or not var_tc_14 then
		sidelineLog("academy: coachId %s lookup failed: %s", tostring(var_tc_12), tostring(var_tc_14))
	end

	return var_tc_13 and var_tc_14 or nil, var_tc_12
end

-- ---------------------------------------------------------------------------
-- In-match sideline coaches (pilot). Each match spawns 16 pooled civilian
-- NPCObjects (Universe.loadNPCs) that only the tunnel walkout uses. The last
-- two are re-skinned as the home and away coaches (coach face + club polo)
-- and placed on the sideline whenever the game repositions the cheerleaders.
-- Everything is logged to teamcoaches_debug.txt in the game folder.

SidelineLogFile = "teamcoaches_debug.txt"
-- far touchline (the cheerleaders and broadcast camera are on +y), the same
-- distance off it as the cheerleaders, facing the field. [1] = home, in front
-- of the home bench (+x), [2] = away (confirmed in game 2026-10-26)
SidelineSpots = {
	[1] = { x = 6, y = -36 },
	[2] = { x = -6, y = -36 }
}
SidelineFacing = { x = 0, y = 1 }
-- pilot: still stream in and place the pooled civilian when a side has no
-- coach, to see whether sideline NPCs render and animate at all
SidelinePlaceWithoutCoach = true

local var_tc_logged = {}

function sidelineLog(arg_tc_16, ...)
	pcall(function(...)
		local var_tc_18 = io.open(SidelineLogFile, "a")

		if var_tc_18 then
			var_tc_18:write(os.date("%H:%M:%S "), string.format(arg_tc_16, ...), "\n")
			var_tc_18:flush()
			var_tc_18:close()
		end
	end, ...)
end

local function sidelineLogOnce(arg_tc_17, ...)
	if not var_tc_logged[arg_tc_17] then
		var_tc_logged[arg_tc_17] = true

		sidelineLog(...)
	end
end

local function tryGet(arg_tc_18, arg_tc_19)
	local var_tc_19, var_tc_20 = pcall(function()
		return arg_tc_18[arg_tc_19]
	end)

	return var_tc_19 and var_tc_20 or nil
end

-- The match club's coach NPC: the mod's own assignment (by academyId), else
-- matchClub.coach (what Universe.loadCoaches and cutscene_visual_config
-- expect; the game fills in a default coach when the club has none), else
-- look coachId up in the NPC manager.
local function findMatchCoach(arg_tc_20, arg_tc_21, arg_tc_22)
	local var_tc_58 = getAssignedCoachId(tryGet(arg_tc_21, "academyId"))
	local var_tc_59 = tryGet(arg_tc_20, "npcManager")

	if var_tc_58 and var_tc_59 then
		local var_tc_60, var_tc_61 = pcall(var_tc_59.getReferee, var_tc_59, var_tc_58)

		if var_tc_60 and var_tc_61 and tryGet(var_tc_61, "visual") then
			return var_tc_61, "assignment " .. tostring(var_tc_58)
		end

		sidelineLog("assignment %s for club %s not found in the NPC manager (%s)", tostring(var_tc_58), tostring(tryGet(arg_tc_21, "academyId")), tostring(var_tc_61))
	end

	local var_tc_21 = tryGet(arg_tc_21, "coach")

	if var_tc_21 and tryGet(var_tc_21, "visual") then
		return var_tc_21, "matchClub.coach"
	end

	local var_tc_22 = tryGet(arg_tc_21, "coachId")
	local var_tc_23 = tryGet(arg_tc_20, "npcManager")

	if var_tc_22 and var_tc_22 ~= 0 and var_tc_23 then
		local var_tc_24, var_tc_25 = pcall(var_tc_23.getReferee, var_tc_23, var_tc_22)

		if var_tc_24 and var_tc_25 then
			return var_tc_25, "npcManager:getReferee(" .. tostring(var_tc_22) .. ")"
		end
	end

	return nil, string.format("no coach (coach=%s coachId=%s npcManager=%s)", tostring(var_tc_21), tostring(var_tc_22), tostring(var_tc_23))
end

local function calledFromTunnel()
	local var_tc_26, var_tc_27 = pcall(function()
		for iter_tc_0 = 3, 12 do
			local var_tc_28 = debug.getinfo(iter_tc_0, "S")

			if var_tc_28 and var_tc_28.source and string.find(var_tc_28.source, "teamshield", 1, true) then
				return true
			end
		end

		return false
	end)

	return var_tc_26 and var_tc_27
end

-- per match: side -> pooled NPC id of that side's coach (real coaches only),
-- and whether it's an online match (reactions are off online)
local var_tc_coachIdBySide = {}
local var_tc_onlineMatch = false

-- pooled NPC ids this mod activated; switched off again before the match
-- unloads (stock only ever unloads with every pooled NPC inactive, and
-- quitting a match with them active crashed)
local var_tc_activatedIds = {}

local var_tc_unloadWrapped = false

local function deactivateCoachesBeforeUnload()
	if var_tc_unloadWrapped then
		return
	end

	var_tc_unloadWrapped = true

	local var_tc_102, var_tc_103 = pcall(function()
		local var_tc_104 = import("sim.universe.universe").Universe
		local var_tc_105 = rawget(var_tc_104, "unload")

		rawset(var_tc_104, "unload", function(arg_tc_57, ...)
			pcall(function()
				local var_tc_106 = arg_tc_57.matchSim:getGameObjects()
				local var_tc_107 = {}

				for iter_tc_14 in pairs(var_tc_activatedIds) do
					if var_tc_106:isActive(iter_tc_14) then
						var_tc_106:deactivateGameObject(iter_tc_14)
						table.insert(var_tc_107, tostring(iter_tc_14))
					end
				end

				var_tc_106:updateActivationRequests()

				var_tc_activatedIds = {}
				var_tc_coachIdBySide = {}

				sidelineLog("unload: deactivated coach npc ids [%s] before teardown", table.concat(var_tc_107, ", "))
			end)

			return var_tc_105(arg_tc_57, ...)
		end)
	end)

	sidelineLog("unload hook %s", var_tc_102 and "installed" or "FAILED " .. tostring(var_tc_103))
end

local var_tc_skinned = setmetatable({}, {
	__mode = "k"
})

local function skinCoach(arg_tc_23, arg_tc_24, arg_tc_25, arg_tc_26)
	local var_tc_29 = arg_tc_23.pools
	local var_tc_30 = arg_tc_23.ingameCharacterStreamingProcess
	local var_tc_31, var_tc_32 = makePoloUniform(arg_tc_25, tryGet(tryGet(arg_tc_26, "identity"), "primaryRGBColour"))

	var_tc_29.visualConfigPool:get(arg_tc_24):copy(arg_tc_25.visual)
	var_tc_29.visualConfigPool:get(arg_tc_24):setOption("role", "coach")
	var_tc_29.teamVisualConfigPool:get(arg_tc_24):copy(var_tc_31)
	pcall(var_tc_30.setRole, var_tc_30, arg_tc_24, "Role_Umpire", native.EPreferredRole.FullBack, false, true)
	pcall(var_tc_30.setWantLoaded, var_tc_30, arg_tc_24, true)
	var_tc_30:reloadId(arg_tc_24)

	return var_tc_32
end

-- Activating an object adds it to the replay recording list
-- (ReplayManager.activateId, via the game object listeners). Pooled NPCs never
-- get there in the stock game. With the coaches in it, entering the pause-menu
-- replay froze the game once (cause not found yet). CoachesInReplays = false
-- keeps them out (replays then just hide them). While it's true, the replay
-- entry points log any error with its stack before re-raising it.
CoachesInReplays = true
-- per-method replay error logging (wraps replay update every frame). On again
-- 2026-10-26: automatic replays freeze at the transition with the coaches
-- recorded (the pause-menu replay works)
ReplayDiagnostics = true

local var_tc_replayIds = {}
local var_tc_hiddenCount

local function packResults(...)
	return {
		n = select("#", ...),
		...
	}
end

local function wrapForErrors(arg_tc_40, arg_tc_41, arg_tc_42)
	if not arg_tc_40 then
		sidelineLog("replay diagnostics: %s not found", arg_tc_41)

		return
	end

	for iter_tc_9, iter_tc_10 in ipairs(arg_tc_42) do
		local var_tc_66 = rawget(arg_tc_40, iter_tc_10)
		local var_tc_67 = "teamCoachesWrapped_" .. iter_tc_10

		if type(var_tc_66) == "function" and not rawget(arg_tc_40, var_tc_67) then
			rawset(arg_tc_40, var_tc_67, true)
			rawset(arg_tc_40, iter_tc_10, function(...)
				local var_tc_68 = packResults(xpcall(var_tc_66, function(arg_tc_43)
					local var_tc_69 = ""

					if type(debug) == "table" and debug.traceback then
						var_tc_69 = debug.traceback("", 2)
					end

					return {
						msg = tostring(arg_tc_43),
						tb = var_tc_69
					}
				end, ...))

				if not var_tc_68[1] then
					local var_tc_70 = var_tc_68[2]

					sidelineLog("REPLAY ERROR in %s.%s: %s\n%s", arg_tc_41, iter_tc_10, var_tc_70.msg, var_tc_70.tb)
					error(var_tc_70.msg, 0)
				end

				return unpack(var_tc_68, 2, var_tc_68.n)
			end)
		end
	end
end

local function installReplayDiagnostics()
	local function classOf(arg_tc_44, arg_tc_45)
		local var_tc_71, var_tc_72 = pcall(function()
			return import(arg_tc_44)[arg_tc_45]
		end)

		return var_tc_71 and var_tc_72 or nil
	end

	wrapForErrors(classOf("sim.replay.interactivereplay_ustate", "InteractiveReplayUniverseState"), "InteractiveReplayUniverseState", {
		"onFirstFocus",
		"beginPlayback",
		"endPlayback",
		"update",
		"getLookAtDetails",
		"onRemove",
		"dispose"
	})
	wrapForErrors(classOf("sim.replay.replaypresenter", "ReplayPresenter"), "ReplayPresenter", {
		"init",
		"beginPlayback",
		"endPlayback",
		"dispose"
	})
	wrapForErrors(classOf("app.gameplay.gameplaypaused_uistate_hub_interactivereplay", "GameplayPausedInteractiveReplayBegin"), "GameplayPausedInteractiveReplayBegin", {
		"enter"
	})
	wrapForErrors(classOf("base.replay.replaymanager", "ReplayManager"), "ReplayManager", {
		"beginSegment",
		"endSegment",
		"pauseSegment",
		"resumePreviousSegment"
	})
	-- automatic (moment) replays and the transitions that start them
	wrapForErrors(classOf("sim.replay.replay_ustate", "ReplayUniverseState"), "ReplayUniverseState", {
		"onFirstFocus",
		"onBarrierComplete",
		"update",
		"onRemove",
		"dispose"
	})
	wrapForErrors(classOf("sim.replay.replay_ustate_playing_state", "ReplayUStatePlayingState"), "ReplayUStatePlayingState", {
		"enter",
		"update",
		"onFirstFocus",
		"beginPlayback",
		"dispose"
	})
	wrapForErrors(classOf("sim.replay.replay_ustate_handshake_state", "ReplayUStateHandshakeState"), "ReplayUStateHandshakeState", {
		"enter",
		"update"
	})

	local var_tc_100, var_tc_101 = pcall(import, "game.replay.replaycameraselection")

	wrapForErrors(var_tc_100 and var_tc_101 or nil, "replaycameraselection", {
		"selectCameras",
		"createMomentShotsFromConfig"
	})
	wrapForErrors(classOf("base.transition.logotransition_hud", "LogoTransitionHud"), "LogoTransitionHud", {
		"update",
		"kick"
	})
	wrapForErrors(classOf("base.transition.logotransition_hud", "TeamStinger"), "TeamStinger", {
		"update",
		"kick",
		"kickOutro",
		"updateReveal"
	})
	wrapForErrors(classOf("base.transition.screenwipe", "ScreenWipeOut"), "ScreenWipeOut", {
		"onFirstFocus",
		"update",
		"onBarrierComplete"
	})
	wrapForErrors(classOf("base.transition.screenwipe", "ScreenWipeIn"), "ScreenWipeIn", {
		"onPush",
		"update",
		"onRemove"
	})
	sidelineLog("replay diagnostics: installed")
end

function keepOutOfReplays(arg_tc_31)
	var_tc_replayIds[arg_tc_31] = true

	local var_tc_46 = import("base.replay.replaymanager").ReplayManager

	if var_tc_46 and not var_tc_46.teamCoachesWrapped then
		local var_tc_47 = var_tc_46.activateId

		function var_tc_46.activateId(arg_tc_32, arg_tc_33, ...)
			if var_tc_replayIds[arg_tc_33] then
				if not CoachesInReplays then
					return
				end

				if arg_tc_32.segment then
					-- stock activateId raises "this could cause problems - see
					-- stu" when an id joins mid-segment; skip instead
					sidelineLog("replay: coach id %s activated mid-segment, not recorded", tostring(arg_tc_33))

					return
				end

				sidelineLog("replay: coach id %s added to replay recording", tostring(arg_tc_33))
			end

			return var_tc_47(arg_tc_32, arg_tc_33, ...)
		end

		var_tc_46.teamCoachesWrapped = true

		if CoachesInReplays then
			if ReplayDiagnostics then
				installReplayDiagnostics()
			end

			sidelineLog("replay: coaches included in replays%s", ReplayDiagnostics and ", replay diagnostics on" or "")
		else
			sidelineLog("replay: coach NPCs kept out of replay recording")
		end
	end
end

-- Called after cheerleader_helper.positionCheerleaders (same arguments).
function positionSidelineCoaches(arg_tc_27, arg_tc_28, arg_tc_29, arg_tc_30)
	local var_tc_33 = arg_tc_28.components.matchInData

	if calledFromTunnel() then
		-- the tunnel walkout just re-skinned every pooled NPC as a civilian
		var_tc_skinned[var_tc_33] = nil

		sidelineLogOnce("tunnel", "tunnel walkout: leaving pooled NPCs as civilians")

		return
	end

	local var_tc_34 = {}

	for iter_tc_1, iter_tc_2 in arg_tc_29:objects(npctype.TypeId) do
		table.insert(var_tc_34, iter_tc_1)
	end

	table.sort(var_tc_34)

	if #var_tc_34 < 2 then
		sidelineLogOnce("nonpcs", "only %d pooled NPCs, no sideline coaches", #var_tc_34)

		return
	end

	local var_tc_35 = {
		[1] = var_tc_34[#var_tc_34 - 1],
		[2] = var_tc_34[#var_tc_34]
	}
	local var_tc_36 = not var_tc_skinned[var_tc_33]

	if var_tc_36 then
		var_tc_coachIdBySide = {}
		var_tc_onlineMatch = tryGet(var_tc_33, "onlineMultiplayer") and true or false

		installReactionHooks()
		deactivateCoachesBeforeUnload()
	end

	for iter_tc_3, iter_tc_4 in ipairs({
		"home",
		"away"
	}) do
		local var_tc_37 = var_tc_35[iter_tc_3]
		local var_tc_38 = tryGet(var_tc_33, iter_tc_4)
		local var_tc_39, var_tc_40 = findMatchCoach(arg_tc_27, var_tc_38, arg_tc_28)

		if var_tc_39 then
			var_tc_coachIdBySide[sidehelper[iter_tc_4]] = var_tc_37
		end

		if var_tc_36 then
			if var_tc_39 then
				local var_tc_41, var_tc_42 = pcall(skinCoach, arg_tc_27, var_tc_37, var_tc_39, var_tc_38)

				sidelineLog("%s: npc id %s <- %s (%s), polo %s%s", iter_tc_4, tostring(var_tc_37), getCoachName(var_tc_39), var_tc_40, var_tc_41 and var_tc_42 and var_tc_42.name or "?", var_tc_41 and "" or " ERROR " .. tostring(var_tc_42))
			else
				sidelineLog("%s: %s%s", iter_tc_4, var_tc_40, SidelinePlaceWithoutCoach and " - placing the pooled civilian instead" or "")

				if SidelinePlaceWithoutCoach then
					local var_tc_45 = arg_tc_27.ingameCharacterStreamingProcess

					pcall(var_tc_45.setRole, var_tc_45, var_tc_37, "Role_Umpire", native.EPreferredRole.FullBack, false, true)
					pcall(var_tc_45.setWantLoaded, var_tc_45, var_tc_37, true)
				end
			end
		end

		if var_tc_36 then
			sidelineLog("%s club: %s, academyId %s, coachId %s", iter_tc_4, tostring(tryGet(var_tc_38, "fullName")), tostring(tryGet(var_tc_38, "academyId")), tostring(tryGet(var_tc_38, "coachId")))
		end

		if var_tc_39 or SidelinePlaceWithoutCoach then
			local var_tc_43 = arg_tc_29:getGameObject(var_tc_37)
			local var_tc_44 = SidelineSpots[iter_tc_3]

			-- pooled NPCs are added inactive (Universe.loadNPCs); cutscenes
			-- activate their actors the same way and only deactivate the ones
			-- they activated themselves, so these stay on after a cutscene
			if not arg_tc_29:isActive(var_tc_37) then
				keepOutOfReplays(var_tc_37)
				arg_tc_29:activateGameObject(var_tc_37)

				var_tc_activatedIds[var_tc_37] = true
				var_tc_43:setBehaviour("Idle", arg_tc_30)
				sidelineLog("%s: activated npc id %s", iter_tc_4, tostring(var_tc_37))
			end

			var_tc_43:resetTo(native.vec2(var_tc_44.x, var_tc_44.y), native.normalize2(native.vec2(SidelineFacing.x, SidelineFacing.y)), arg_tc_30)

			-- replay playback (and its restore) hides every actor model that
			-- isn't in the replay id list, which the coaches are kept out of
			local var_tc_62, var_tc_63 = pcall(function()
				local var_tc_64 = var_tc_43:getActorModel()
				local var_tc_65 = var_tc_64.visible

				var_tc_64.visible = true

				return var_tc_65
			end)

			if not var_tc_62 or var_tc_63 == false then
				var_tc_hiddenCount = (var_tc_hiddenCount or 0) + 1

				if var_tc_hiddenCount <= 6 then
					sidelineLog("%s: npc id %s %s", iter_tc_4, tostring(var_tc_37), var_tc_62 and "was hidden, made visible" or "actor model error " .. tostring(var_tc_63))
				end
			end
		end
	end

	if var_tc_36 then
		var_tc_skinned[var_tc_33] = true
	end
end

-- ---------------------------------------------------------------------------
-- Coach reactions, run by CheerleaderCelebrateRuleState flagged coachReaction
-- (reaction_rulestate_block.lua): a close-up cutscene on one sideline coach,
-- using copies of the conversion-reaction cutscenes with the actor slot retyped
-- to "npc" (cs_conversion_data.lua). It is chained in by wrapping the stock
-- builders, since the files that build these flows belong to other mods:
--   penalty  penalty.generatePenaltyAwardedState: before PenaltySelectSetup
--            (after referee-on-report's referee close-up, if any)
--   40/20    ruleactionhandler.processRuleAction with fortyTwentyVariationRequest
--   try      TryCelebrateRuleState.onEnterSolid: after the celebration; the try
--            replay moves from the celebration to the reaction, so it plays after
--            the coach (and gets replay-team-stinger's stinger there)

ReactionChance = {
	penalty = 0.5,
	fortyTwenty = 1,
	try = 0.35
}
-- cuts: the cutscene's cs_cameraNN shots (cutIndex N) that sit in front of the
-- actor, measured from the animsets' camera and root tracks (scratch cams.py,
-- 2026-10-26; the actor's forward is +z in clip space - the first pick assumed
-- -z and the in-game check put camera 3 BEHIND at exactly the mirrored dot).
-- The rest look at the coach's back. wane trims the long disappointed clips
-- (9.4-11.1 s) to about 5.5 s.
CoachReactionCutscenes = {
	happy = {
		{
			name = "teamcoaches_happy_01",
			cuts = {1, 2, 5, 8}
		},
		{
			name = "teamcoaches_happy_02",
			cuts = {1, 2}
		}
	},
	gutted = {
		{
			name = "teamcoaches_gutted_01",
			cuts = {1, 3, 5},
			wane = 3.9
		},
		{
			name = "teamcoaches_gutted_02",
			cuts = {1, 3, 5},
			wane = 5
		},
		{
			name = "teamcoaches_gutted_03",
			cuts = {1, 5},
			wane = 5.6
		}
	}
}

function getSidelineCoachId(arg_tc_46)
	return var_tc_coachIdBySide and var_tc_coachIdBySide[arg_tc_46] or nil
end

local function chance(arg_tc_47)
	if arg_tc_47 >= 1 then
		return true
	end

	return native.Random.FromSystemTime():randomInteger(1000) < arg_tc_47 * 1000
end

-- Returns a coach reaction state (CheerleaderCelebrateRuleState, coachReaction)
-- that plays `side`'s coach reacting and then continues with nextState, or nil
-- (no coach, online, roll failed). options: scoringSide (the team the stinger
-- belongs to, default side), queueReplay (queue the pending replay after it).
function makeCoachReaction(arg_tc_48, arg_tc_49, arg_tc_50, arg_tc_51, arg_tc_52, arg_tc_58)
	if var_tc_onlineMatch or not ReactionChance[arg_tc_52] or not chance(ReactionChance[arg_tc_52]) then
		return nil
	end

	if not arg_tc_48 or not getSidelineCoachId(arg_tc_49) then
		sidelineLog("reaction %s: no sideline coach for side %s", arg_tc_52, tostring(arg_tc_49))

		return nil
	end

	local var_tc_108 = arg_tc_58 or {}
	local var_tc_73 = import("core.foundation.class").instantiate("CheerleaderCelebrateRuleState", {
		nextState = arg_tc_48,
		skipReplayEvent = true,
		scoringSide = var_tc_108.scoringSide or arg_tc_49,
		randomSeed = native.Random.FromSystemTime():nextAsSeed(),
		coachReaction = true,
		coachSide = arg_tc_49,
		coachHappy = arg_tc_50 and true or false,
		queueReplay = var_tc_108.queueReplay or nil
	})

	sidelineLog("reaction %s: side %s coach %s (%s)", arg_tc_52, tostring(arg_tc_49), arg_tc_50 and "happy" or "gutted", tostring(arg_tc_51))

	return var_tc_73
end

local function pickReactingSide(arg_tc_53, arg_tc_54, arg_tc_55)
	-- the winning side's coach (happy) arg_tc_55 of the time, else the other one (gutted)
	if native.Random.FromSystemTime():randomInteger(1000) < arg_tc_55 * 1000 then
		return arg_tc_53, true
	end

	return arg_tc_54, false
end

local var_tc_hooksInstalled = false

function installReactionHooks()
	if var_tc_hooksInstalled then
		return
	end

	var_tc_hooksInstalled = true

	local var_tc_74, var_tc_75 = pcall(function()
		local var_tc_76 = import("rules.penalty.penalty")
		local var_tc_77 = var_tc_76.generatePenaltyAwardedState

		var_tc_76.generatePenaltyAwardedState = function(...)
			local var_tc_78 = var_tc_77(...)
			local var_tc_79 = select(9, ...)

			pcall(function()
				if not var_tc_78 or var_tc_79.isDebug then
					return
				end

				local var_tc_80, var_tc_81 = pickReactingSide(var_tc_79.penaltyAwardedToSide, var_tc_79.offendingSide, 0.5)
				local var_tc_82 = var_tc_78

				for iter_tc_11 = 1, 6 do
					local var_tc_83 = var_tc_82.nextState

					if not var_tc_83 then
						break
					end

					if (tryGet(var_tc_83, "__type") or type(var_tc_83)) == "PenaltySelectSetupRuleState" then
						var_tc_82.nextState = makeCoachReaction(var_tc_83, var_tc_80, var_tc_81, "penalty awarded", "penalty") or var_tc_83

						return
					end

					var_tc_82 = var_tc_83
				end

				sidelineLog("reaction penalty: PenaltySelectSetupRuleState not found in the chain")
			end)

			return var_tc_78
		end

		local var_tc_84 = import("rules.ruleactions.ruleactionhandler")
		local var_tc_85 = var_tc_84.processRuleAction

		var_tc_84.processRuleAction = function(...)
			local var_tc_86 = select(9, ...)
			local var_tc_87 = false

			pcall(function()
				for iter_tc_12, iter_tc_13 in ipairs(var_tc_86.requests or {}) do
					if iter_tc_13 == "fortyTwentyVariationRequest" then
						var_tc_87 = true
					end
				end
			end)

			local var_tc_88 = var_tc_85(...)

			if var_tc_87 and var_tc_88 then
				local var_tc_89, var_tc_90 = pcall(function()
					local var_tc_91 = var_tc_86.restartSide or var_tc_86.offendingSide
					local var_tc_92, var_tc_93 = pickReactingSide(var_tc_91, sidehelper.getOtherSide(var_tc_91), 0.6)

					return makeCoachReaction(var_tc_88, var_tc_92, var_tc_93, tostring(var_tc_86.eventType or "40/20"), "fortyTwenty")
				end)

				if var_tc_89 and var_tc_90 then
					return var_tc_90
				end
			end

			return var_tc_88
		end

		local var_tc_94 = import("rules.cutscenes.trycelebrate_rulestate").TryCelebrateRuleState
		local var_tc_95 = rawget(var_tc_94, "onEnterSolid")

		rawset(var_tc_94, "onEnterSolid", function(arg_tc_56, ...)
			if not arg_tc_56.teamCoachesChecked then
				arg_tc_56.teamCoachesChecked = true

				local var_tc_96 = select(7, ...)

				pcall(function()
					local var_tc_97 = var_tc_96:getGameObject(arg_tc_56.scorer).side
					local var_tc_98, var_tc_99 = pickReactingSide(var_tc_97, sidehelper.getOtherSide(var_tc_97), 0.75)

					local var_tc_109 = makeCoachReaction(arg_tc_56.nextState, var_tc_98, var_tc_99, "try", "try", {
						scoringSide = var_tc_97,
						queueReplay = arg_tc_56.queueReplay
					})

					if var_tc_109 then
						-- celebration, coach, then the replay (queued by the reaction)
						arg_tc_56.nextState = var_tc_109
						arg_tc_56.queueReplay = false
					end
				end)
			end

			return var_tc_95(arg_tc_56, ...)
		end)
	end)

	sidelineLog("reactions: hooks %s", var_tc_74 and "installed" or "FAILED " .. tostring(var_tc_75))
end

-- native.Localise with an English fallback for keys the string tables may lack
function localiseOr(arg_tc_14, arg_tc_15)
	local var_tc_17 = native.Localise(arg_tc_14)

	if type(var_tc_17) ~= "string" or var_tc_17 == "" or var_tc_17 == arg_tc_14 or string.find(var_tc_17, "^[<#%[]") then
		return arg_tc_15
	end

	return var_tc_17
end

function getCoachName(arg_tc_13)
	local var_tc_15, var_tc_16 = pcall(function()
		return arg_tc_13.fullName
	end)

	if var_tc_15 and type(var_tc_16) == "string" and var_tc_16 ~= "" then
		return var_tc_16
	end

	return localiseOr("Coach", "Coach")
end
