import("core.foundation.func")
import("core.requestmodel.request")
import("core.marshalling.types")
import("ai.substitutions.substitution_request")
import("base.side.sidehelper")
import("game.player.playertype")
import("design.injury_cconfig")
import("script-config.design.sinbin.sinbin_config")
import("script-config.game.interchange.interchange_config")

-- hia-protocol: Head Injury Assessments (NRL style), pilot.
--
-- A head-high tackle can send the tackled player off for an HIA (rules/tackle/tackle_detect.lua,
-- mods/referee-on-report, calls HIAState.onHighTackle). He goes off on a free interchange for the
-- best bench player in his position, sits out HIAMinutes of match clock (15, scaled for short
-- halves), then passes and comes back on for his replacement (another free interchange) or fails
-- and stays off for the rest of the match. "Free" = the side gets an extra interchange
-- (addSubstitutionAdditions, the call golden point uses) for each HIA swap.
--
-- Settings come from the custom difficulty MODDED section (rl26_revamp_sliders.ini, written by
-- mods/discipline-meter's app/academy/customdifficulty_edit_state.lua). Presets use HIADifficulty.

-- Chance (%) a head-high tackle sends the tackled player off for an HIA, before the frequency
-- slider and the stock Injury Probability slider.
local HighTackleHIAChance = 25
-- Match-clock minutes off for the assessment (NRL: 15), scaled to the half length.
local HIAMinutes = 15
-- A queued HIA swap that hasn't happened after this many match seconds is dropped.
local HIAQueueTimeout = 600
-- The concussion cutscene (injury-cutscene-variety's InjuryConcussion_01) plays in front of the
-- high tackle penalty, before the referee close-up. The penalty can come a while after the tackle
-- (advantage), so it waits up to HIACutsceneWindow match-clock seconds for it. false = no cutscene.
local HIACutscene = true
local HIACutsceneWindow = 180

-- Per difficulty (a custom difficulty uses its Misc base difficulty): frequency multiplier and
-- the % of assessments failed. The sliders override these for a custom difficulty.
HIADifficulty = {
	Easiest = {
		frequency = 0.6,
		failRate = 25
	},
	Easy = {
		frequency = 0.8,
		failRate = 30
	},
	Medium = {
		frequency = 1,
		failRate = 40
	},
	Hard = {
		frequency = 1.2,
		failRate = 50
	},
	Hardest = {
		frequency = 1.4,
		failRate = 60
	}
}

-- Test switches: every head-high tackle is an HIA / assessments last this many match-clock
-- minutes instead of HIAMinutes (nil = off). Pair with referee-on-report's
-- OnReportTestEveryTackleHigh to make every tackle a high tackle. Off for play: false / nil.
local HIATestEveryHighTackle = false
local HIATestMinutes = nil

-- Appends to hia_debug.txt in the game folder. Turn off once confirmed in game.
local HIADebugLog = true

local HIASlidersFile = "rl26_revamp_sliders.ini"

-- Default period length (match-clock seconds) that HIAMinutes is written for.
local var_0_full_period = 2400
local var_0_nines_period = 600

local function var_0_hia_log(arg_text)
	if not HIADebugLog then
		return
	end

	pcall(function()
		local var_file = io.open("hia_debug.txt", "a")

		if var_file then
			var_file:write(os.date("%H:%M:%S"), " ", arg_text, "\n")
			var_file:flush()
			var_file:close()
		end
	end)
end

-- Gives a side one extra interchange, so the HIA swap queued with it costs nothing.
local var_0_r = native.CSimulationRequest

request.requestclass("HIAFreeInterchangeRequest", var_0_r, function(arg_r_0, arg_r_1)
	var_0_r.init(arg_r_0)

	for iter_r_0, iter_r_1 in pairs(HIAFreeInterchangeRequest.MemberDefinitions) do
		arg_r_0[iter_r_0] = arg_r_1[iter_r_0]
	end
end).MemberDefinitions = {
	side = types.SignedInteger
}

function HIAFreeInterchangeRequest.validate(arg_r_0, arg_r_1, arg_r_2, arg_r_3)
	return true
end

function HIAFreeInterchangeRequest.apply(arg_r_0, arg_r_1, arg_r_2, arg_r_3, arg_r_4)
	local var_r_0 = VERIFY(arg_r_2:getTeamSubstitutionEntityPair()):get(arg_r_0.side)

	if var_r_0 then
		var_r_0:addSubstitutionAdditions(1)
	end
end

-- Shared with other mods: tackle_detect (trigger), gameplayscore_hud (banners),
-- ai-interchange-rotation (isLocked: never moves a player in an HIA).
local function var_0_hia_new_state()
	local var_state = {
		incoming = {},
		cases = {},
		banners = {},
		freeSwaps = {
			[sidehelper.home] = 0,
			[sidehelper.away] = 0
		},
		log = var_0_hia_log
	}

	-- tackle_detect passes its own (live) services/match/gamestate/gameobjects/time, so the HIA is
	-- decided straight away and penalty.lua, a few frames later, knows to play the concussion
	-- cutscene. Before the manager's first update (no settings yet), it waits for that update.
	function var_state.onHighTackle(arg_victimId, arg_offenderId, arg_services, arg_match, arg_gamestate, arg_gameobjects, arg_time)
		local var_manager = var_state.manager

		if var_manager and var_manager.settings and (not var_manager.settings.enabled or var_manager.skipReason) then
			return
		end

		if var_manager and var_manager.settings and arg_gamestate and arg_gameobjects then
			local var_ok, var_err = pcall(function()
				local var_ctx = var_manager:makeContext(arg_services, arg_match, arg_gamestate, arg_gameobjects, arg_time, nil)

				var_manager:onHighTackle(arg_victimId, arg_offenderId, var_ctx)
			end)

			if not var_ok then
				var_0_hia_log("ERROR onHighTackle: " .. tostring(var_err))
			end

			return
		end

		table.insert(var_state.incoming, {
			victimId = arg_victimId,
			offenderId = arg_offenderId
		})
	end

	-- referee-on-report's penalty.lua: the player whose concussion cutscene should play before
	-- this high tackle penalty, or nil. Each HIA's cutscene is handed out once.
	function var_state.takeConcussionCutscene(arg_matchSeconds)
		local var_pending = var_state.concussionCutscene

		var_state.concussionCutscene = nil

		if not var_pending or not HIACutscene then
			return nil
		end

		if arg_matchSeconds and (arg_matchSeconds - var_pending.at > HIACutsceneWindow or arg_matchSeconds < var_pending.at) then
			var_0_hia_log(string.format("concussion cutscene for %s dropped: the penalty came too late", var_pending.surname))

			return nil
		end

		var_0_hia_log(string.format("concussion cutscene for %s, before the high tackle penalty", var_pending.surname))

		return var_pending.id
	end

	-- The player in the HIA can't come back on (pending/queued/off/failed), and his replacement
	-- can't go off (pending/queued/off/returning).
	function var_state.isLocked(arg_id)
		for iter_c, iter_case in ipairs(var_state.cases) do
			local var_s = iter_case.state

			if iter_case.id == arg_id and (var_s == "pending" or var_s == "queued" or var_s == "off" or var_s == "failed") then
				return true
			end

			if iter_case.replacementId == arg_id and (var_s == "pending" or var_s == "queued" or var_s == "off" or var_s == "returning") then
				return true
			end
		end

		return false
	end

	return var_state
end

local function var_0_read_sliders()
	local var_sections = {}

	pcall(function()
		local var_file = io.open(HIASlidersFile, "r")

		if not var_file then
			return
		end

		local var_section

		for iter_line in var_file:lines() do
			local var_name = iter_line:match("^%s*%[(.-)%]%s*$")

			if var_name then
				var_section = {}
				var_sections[var_name] = var_section
			elseif var_section then
				local var_key, var_value = iter_line:match("^%s*([%w_]+)%s*=%s*(.-)%s*$")

				if var_key then
					var_section[var_key] = var_value
				end
			end
		end

		var_file:close()
	end)

	return var_sections
end

local function var_0_clamp(arg_v, arg_min, arg_max)
	return math.max(arg_min, math.min(arg_max, arg_v))
end

Class("HIAManager", function(arg_m_0)
	arg_m_0.timer = 0
	arg_m_0.loggedErrors = {}
	arg_m_0.state = var_0_hia_new_state()
	arg_m_0.state.manager = arg_m_0

	rawset(_G, "HIAState", arg_m_0.state)
end)

HIAManager.UpdateInterval = 0.25

function HIAManager.update(arg_u_0, arg_u_1, arg_u_2, arg_u_3, arg_u_4, arg_u_5, arg_u_6, arg_u_7, arg_u_8, arg_u_9, arg_u_10, arg_u_11)
	arg_u_0.timer = arg_u_0.timer + (arg_u_8 or 0)

	if arg_u_0.timer < HIAManager.UpdateInterval then
		return
	end

	arg_u_0.timer = 0
	arg_u_0.stage = "setup"

	local var_u_0, var_u_1 = pcall(arg_u_0.evaluate, arg_u_0, arg_u_3, arg_u_5, arg_u_6, arg_u_7, arg_u_9, arg_u_10)

	if not var_u_0 then
		local var_u_2 = tostring(arg_u_0.stage) .. ": " .. tostring(var_u_1)

		if not arg_u_0.loggedErrors[var_u_2] then
			arg_u_0.loggedErrors[var_u_2] = true

			var_0_hia_log("ERROR " .. var_u_2)
		end
	end
end

function HIAManager.loadSettings(arg_s_0, arg_s_1, arg_s_2)
	local var_s_0 = arg_s_2.difficulty
	local var_s_1, var_s_2

	if var_s_0 == native.EDifficulty.Custom then
		pcall(function()
			local var_s_3 = arg_s_1.matchInProgressData.gameplayModifiers

			var_s_1 = var_s_3.name
			var_s_2 = tostring(native.EDifficulty:fromInt(var_s_3.sliderMiscDifficulty))
		end)
	elseif var_s_0 ~= nil then
		var_s_2 = tostring(var_s_0)
	end

	local var_s_4 = HIADifficulty[var_s_2 or ""] or HIADifficulty.Medium
	local var_s_5 = var_s_1 and var_0_read_sliders()[var_s_1] or {}
	local var_s_6 = injury_cconfig.cInjuryConfig.customDifficultyInjuryChanceModifier or 1

	arg_s_0.settings = {
		enabled = var_s_5.hia ~= "off",
		frequency = var_0_clamp(tonumber(var_s_5.hia_frequency) or var_s_4.frequency, 0, 5),
		failRate = var_0_clamp(tonumber(var_s_5.hia_fail_rate) or var_s_4.failRate, 0, 100),
		injuryModifier = var_s_6
	}

	var_0_hia_log(string.format("settings [%s] base %s: %s, frequency x%.2f, fail rate %d%%, stock injury probability x%.2f", tostring(var_s_1 or "preset"), tostring(var_s_2), arg_s_0.settings.enabled and "on" or "OFF", arg_s_0.settings.frequency, arg_s_0.settings.failRate, var_s_6))
end

-- services, match, gamestate, gameobjects, time, request list
function HIAManager.evaluate(arg_e_0, arg_e_1, arg_e_2, arg_e_3, arg_e_4, arg_e_5, arg_e_6)
	local var_e_0 = arg_e_2:getComponent("matchInData")
	local var_e_1 = arg_e_2:getComponent("matchInfo")
	local var_e_2 = var_e_0 and var_e_0.matchType

	if not var_e_2 or not var_e_1 then
		return
	end

	if not arg_e_0.settings then
		arg_e_0:loadSettings(arg_e_2, var_e_0)

		arg_e_0.skipReason = var_e_0.gameMode == native.EGameMode.Practice and "practice" or arg_e_3:getTrainingEntity().trainingActive and "training" or nil
	end

	local var_e_3 = arg_e_0.state

	if not arg_e_0.settings.enabled or arg_e_0.skipReason then
		var_e_3.incoming = {}

		return
	end

	local var_e_5 = arg_e_0:makeContext(arg_e_1, arg_e_2, arg_e_3, arg_e_4, arg_e_5, arg_e_6)

	arg_e_0.stage = "incoming"

	local var_e_6 = var_e_3.incoming

	var_e_3.incoming = {}

	for iter_e_0, iter_e_1 in ipairs(var_e_6) do
		arg_e_0:onHighTackle(iter_e_1.victimId, iter_e_1.offenderId, var_e_5)
	end

	arg_e_0.stage = "cases"

	for iter_e_2, iter_e_3 in ipairs(var_e_3.cases) do
		arg_e_0:updateCase(iter_e_3, var_e_5)
	end
end

-- Everything for one decision or update. Only valid during the frame it was made in: the
-- engine's gamestate/gameobjects objects go bad after it, so never keep one.
function HIAManager.makeContext(arg_k_0, arg_k_1, arg_k_2, arg_k_3, arg_k_4, arg_k_5, arg_k_6)
	local var_k_0 = arg_k_2:getComponent("matchInData")
	local var_k_1 = arg_k_2:getComponent("matchInfo")
	local var_k_2 = var_k_0.matchType
	local var_k_3 = var_k_2.categorisedMatchType == native.EMatchType.MT_Nines and var_0_nines_period or var_0_full_period

	return {
		services = arg_k_1,
		match = arg_k_2,
		gamestate = arg_k_3,
		gameobjects = arg_k_4,
		requestList = arg_k_6,
		matchInData = var_k_0,
		matchType = var_k_2,
		timeScale = (var_k_1.timePeriodDuration or var_k_3) / var_k_3,
		matchSeconds = var_k_1:getMatchSecondsElapsed(arg_k_3, arg_k_5),
		proId = arg_k_0:getProPlayerId(arg_k_2, var_k_0)
	}
end

function HIAManager.getProPlayerId(arg_p_0, arg_p_1, arg_p_2)
	local var_p_0 = arg_p_2.beAProAssetId

	if not var_p_0 then
		return nil
	end

	return arg_p_1:getSide(sidehelper.home):getIdAsset(var_p_0) or arg_p_1:getSide(sidehelper.away):getIdAsset(var_p_0)
end

function HIAManager.getCase(arg_g_0, arg_g_1)
	for iter_g_0, iter_g_1 in ipairs(arg_g_0.state.cases) do
		if iter_g_1.id == arg_g_1 and iter_g_1.state ~= "done" and iter_g_1.state ~= "cancelled" then
			return iter_g_1
		end
	end

	return nil
end

local function var_0_surname(arg_obj, arg_id)
	local var_identity = arg_obj and arg_obj.identity
	local var_name = var_identity and (var_identity.surname or var_identity.shortName) or tostring(arg_id)

	return string.upper(var_name)
end

local function var_0_remaining(arg_ctx, arg_side)
	local var_entity = VERIFY(arg_ctx.gamestate:getTeamSubstitutionEntityPair()):get(arg_side)

	if arg_ctx.matchType.maxSubstitutionCount == native.EMaxSubstitutionCounts.Unlimited then
		return "unlimited"
	end

	return string.format("%s left (%s made)", tostring(var_entity:getRemainingSubstitutions(arg_ctx.matchType)), tostring(var_entity:getCompletedSubstitutions()))
end

local function var_0_banner(arg_state, arg_text)
	table.insert(arg_state.banners, arg_text)
	var_0_hia_log("banner queued: " .. arg_text)
end

function HIAManager.onHighTackle(arg_h_0, arg_h_1, arg_h_2, arg_h_3)
	if not arg_h_1 or arg_h_0:getCase(arg_h_1) then
		return
	end

	local var_h_0 = arg_h_3.gameobjects:getGameObject(arg_h_1, playertype.TypeId)

	if not var_h_0 then
		return
	end

	local var_h_1 = var_0_surname(var_h_0, arg_h_1)

	if arg_h_1 == arg_h_3.proId then
		var_0_hia_log(string.format("high tackle on %s: Be a Pro player, no HIA", var_h_1))

		return
	end

	local var_h_2 = arg_h_0.settings
	local var_h_3 = HIATestEveryHighTackle and 100 or HighTackleHIAChance * var_h_2.frequency * var_h_2.injuryModifier
	local var_h_4 = native.Random.FromSystemTime():next(0, 100)

	if var_h_3 <= var_h_4 then
		var_0_hia_log(string.format("high tackle on %s: no HIA (rolled %d, needed < %.1f)", var_h_1, var_h_4, var_h_3))

		return
	end

	arg_h_0.stage = "start"

	local var_h_5 = var_h_0.side
	local var_h_6 = arg_h_3.services.knowledgeBank.inPlayInfoPool:get(arg_h_1)

	if not var_h_6 or var_h_6.role == native.EAssignedRole.Substitute or var_h_6.inPlayState ~= native.EInPlayState.InPlay then
		var_0_hia_log(string.format("high tackle on %s: HIA rolled but he isn't on the field", var_h_1))

		return
	end

	local var_h_7 = arg_h_0:chooseReplacement(var_h_5, var_h_6.role, arg_h_3)

	if not var_h_7 then
		-- Pilot: no bench player, so he plays on (playing a man short comes later).
		var_0_hia_log(string.format("high tackle on %s: HIA rolled but no bench player is available, he plays on", var_h_1))

		return
	end

	local var_h_8 = {
		id = arg_h_1,
		side = var_h_5,
		role = var_h_6.role,
		surname = var_h_1,
		offenderId = arg_h_2,
		replacementId = var_h_7.id,
		replacementName = var_h_7.surname,
		state = "pending",
		decidedAt = arg_h_3.matchSeconds
	}

	table.insert(arg_h_0.state.cases, var_h_8)
	var_0_hia_log(string.format("side %d %s: HIA after a high tackle (rolled %d < %.1f). Interchanges before: %s", var_h_5, var_h_1, var_h_4, var_h_3, var_0_remaining(arg_h_3, var_h_5)))
	var_0_banner(arg_h_0.state, var_h_1 .. " OFF FOR HIA")

	if HIACutscene then
		arg_h_0.state.concussionCutscene = {
			id = arg_h_1,
			surname = var_h_1,
			at = arg_h_3.matchSeconds
		}
	end
end

function HIAManager.requestFreeSwap(arg_f_0, arg_f_1, arg_f_2, arg_f_3, arg_f_4)
	local var_f_0 = arg_f_4.matchType
	local var_f_1 = var_f_0.maxSubstitutionCount == native.EMaxSubstitutionCounts.Unlimited

	if not var_f_1 then
		arg_f_4.requestList:add(HIAFreeInterchangeRequest({
			side = arg_f_1
		}))

		arg_f_0.state.freeSwaps[arg_f_1] = (arg_f_0.state.freeSwaps[arg_f_1] or 0) + 1
	end

	-- unlimitedSubstitutions skips the limit check in SubstitutionRequest.validate: the extra
	-- interchange above may not be counted yet when it runs.
	arg_f_4.requestList:add(substitution_request.SubstitutionRequest({
		side = arg_f_1,
		offId = arg_f_2,
		onId = arg_f_3,
		maxSubstitutions = var_f_1 and 0 or var_f_0.maxSubstitutionCount:toInt(),
		unlimitedSubstitutions = true
	}))
	var_0_hia_log(string.format("side %d: free interchange queued, OFF %s ON %s", arg_f_1, tostring(arg_f_2), tostring(arg_f_3)))
end

local function var_0_role_weight(arg_player, arg_role)
	if arg_role == arg_player.primaryRole then
		return interchange_config.AllocatedPrimaryRoleWeight
	elseif arg_role == arg_player.secondaryRole then
		return interchange_config.AllocatedSecondaryRoleWeight
	elseif arg_role == arg_player.tertiaryRole then
		return interchange_config.AllocatedTertiaryRoleWeight
	end

	return interchange_config.NonAllocatedRoleWeight
end

function HIAManager.getStamina(arg_t_0, arg_t_1, arg_t_2)
	local var_t_0 = arg_t_2.services.pools.staminaInfoPool:get(arg_t_1)

	if not var_t_0 then
		return 1
	end

	local var_t_1 = arg_t_2.gameobjects:getGameObject(arg_t_1, playertype.TypeId)
	local var_t_2 = var_t_1 and var_t_1:getDerivedAttribute("maxStamina")

	if not var_t_2 or var_t_2 <= 0 then
		var_t_2 = 1
	end

	return var_t_0.stamina / var_t_2
end

-- Best available bench player for the role: overall for the role x role fit x stamina, same as
-- ai-interchange-rotation. Obeys the original-bench limit (maxOriginalSubstitutesToSelect).
function HIAManager.chooseReplacement(arg_c_0, arg_c_1, arg_c_2, arg_c_3)
	local var_c_0 = arg_c_3.gamestate
	local var_c_1 = arg_c_3.match:getSide(arg_c_1)
	local var_c_2 = arg_c_3.matchInData:getClub(arg_c_1)
	local var_c_3 = arg_c_3.services.knowledgeBank.inPlayInfoPool
	local var_c_4 = arg_c_3.services.knowledgeBank.teamSubstitutionDecisionKnowledgePair:get(arg_c_1)
	local var_c_5 = VERIFY(var_c_0:getTeamSubstitutionEntityPair()):get(arg_c_1)
	local var_c_6 = var_c_0:getInjuryPool()
	local var_c_7 = var_c_0:getSinBinInfoPool()
	local var_c_8 = native.PlayerRole.getPreferredRoleForAssignedRole(arg_c_2)
	local var_c_9 = arg_c_3.matchType.maxOriginalSubstitutesToSelect
	local var_c_10

	if var_c_9 and var_c_9 ~= native.EMaxSubstitutionCounts.Unlimited then
		var_c_10 = var_c_9:toInt() - var_c_5:getOriginalSubsInterchangedCount()
	end

	local var_c_11
	local var_c_12 = 0

	for iter_c_0, iter_c_1 in pairs(var_c_1.idAssetMap) do
		local var_c_13 = var_c_3:get(iter_c_1)
		local var_c_14 = var_c_2:getPlayer(iter_c_0)
		local var_c_15 = var_c_13 and var_c_14 and var_c_13.role == native.EAssignedRole.Substitute and var_c_13.inPlayState == native.EInPlayState.Sideline and iter_c_1 ~= arg_c_3.proId and not var_c_5:queuedSubstitutionsContains(iter_c_1) and not (var_c_4 and var_c_4:queuedSubstitutionsContains(iter_c_1)) and not arg_c_0.state.isLocked(iter_c_1) and var_c_7:get(iter_c_1).status == sinbin_config.sinbinStatus.OnField

		if var_c_15 then
			local var_c_16 = interchange_config.InjuryWeights[var_c_6:get(iter_c_1).severity] or 0

			if var_c_16 <= 0 then
				var_c_15 = false
			end

			if var_c_15 and var_c_10 and var_c_5.originalSubsNotInterchanged[iter_c_1] ~= nil and var_c_10 <= 0 then
				var_c_15 = false
			end

			if var_c_15 then
				local var_c_17 = (var_c_14:getOverallForRole(var_c_8) or 0) * var_0_role_weight(var_c_14, var_c_8) * arg_c_0:getStamina(iter_c_1, arg_c_3) * var_c_16

				if var_c_12 < var_c_17 then
					var_c_12 = var_c_17

					local var_c_18 = arg_c_3.gameobjects:getGameObject(iter_c_1, playertype.TypeId)

					var_c_11 = {
						id = iter_c_1,
						surname = var_0_surname(var_c_18, iter_c_1)
					}
				end
			end
		end
	end

	return var_c_11
end

function HIAManager.updateCase(arg_x_0, arg_x_1, arg_x_2)
	local var_x_0 = arg_x_2.services.knowledgeBank.inPlayInfoPool
	local var_x_1 = var_x_0:get(arg_x_1.id)
	local var_x_2 = var_x_0:get(arg_x_1.replacementId)
	local var_x_3 = arg_x_1.state
	local var_x_4 = arg_x_2.matchSeconds

	if var_x_3 == "pending" then
		-- The swap is queued from the update (the request list belongs to it).
		arg_x_1.state = "queued"
		arg_x_1.queuedAt = var_x_4

		arg_x_0:requestFreeSwap(arg_x_1.side, arg_x_1.id, arg_x_1.replacementId, arg_x_2)
	elseif var_x_3 == "queued" then
		if var_x_1 and (var_x_1.role == native.EAssignedRole.Substitute or var_x_1.inPlayState == native.EInPlayState.Sideline) then
			arg_x_1.state = "off"
			arg_x_1.offAt = var_x_4

			var_0_hia_log(string.format("side %d %s: off for his HIA at %02d:%02d (%s on). Interchanges now: %s", arg_x_1.side, arg_x_1.surname, math.floor(var_x_4 / 60), math.floor(var_x_4 % 60), arg_x_1.replacementName, var_0_remaining(arg_x_2, arg_x_1.side)))
		elseif var_x_4 - arg_x_1.queuedAt > HIAQueueTimeout * arg_x_2.timeScale then
			arg_x_1.state = "cancelled"

			var_0_hia_log(string.format("side %d %s: HIA swap never happened, dropped", arg_x_1.side, arg_x_1.surname))
		end
	elseif var_x_3 == "off" then
		-- The clock restarts each period in some modes; never count backwards.
		if var_x_4 < arg_x_1.offAt then
			arg_x_1.offAt = var_x_4
		end

		local var_x_5 = (HIATestMinutes or HIAMinutes) * 60 * arg_x_2.timeScale

		if var_x_4 - arg_x_1.offAt < var_x_5 then
			return
		end

		local var_x_6 = native.Random.FromSystemTime():next(0, 100)

		if var_x_6 < arg_x_0.settings.failRate then
			arg_x_1.state = "failed"

			var_0_hia_log(string.format("side %d %s: FAILED his HIA (rolled %d < %d%%), out for the match", arg_x_1.side, arg_x_1.surname, var_x_6, arg_x_0.settings.failRate))
			var_0_banner(arg_x_0.state, arg_x_1.surname .. " FAILED HIA")

			return
		end

		local var_x_7 = arg_x_2.services.knowledgeBank.teamSubstitutionDecisionKnowledgePair:get(arg_x_1.side)
		local var_x_8 = VERIFY(arg_x_2.gamestate:getTeamSubstitutionEntityPair()):get(arg_x_1.side)
		local var_x_9 = var_x_2 and var_x_2.role ~= native.EAssignedRole.Substitute and var_x_2.inPlayState == native.EInPlayState.InPlay and not var_x_8:queuedSubstitutionsContains(arg_x_1.replacementId) and not (var_x_7 and var_x_7:queuedSubstitutionsContains(arg_x_1.replacementId))

		var_0_hia_log(string.format("side %d %s: passed his HIA (rolled %d >= %d%%)", arg_x_1.side, arg_x_1.surname, var_x_6, arg_x_0.settings.failRate))
		var_0_banner(arg_x_0.state, arg_x_1.surname .. " PASSED HIA")

		if var_x_9 then
			arg_x_1.state = "returning"
			arg_x_1.returnQueuedAt = var_x_4

			arg_x_0:requestFreeSwap(arg_x_1.side, arg_x_1.replacementId, arg_x_1.id, arg_x_2)
		else
			-- His replacement has left the field (sin bin, injury...): he waits on the bench.
			arg_x_1.state = "done"

			var_0_hia_log(string.format("side %d %s: %s is no longer on the field, so %s stays on the bench", arg_x_1.side, arg_x_1.surname, arg_x_1.replacementName, arg_x_1.surname))
		end
	elseif var_x_3 == "returning" then
		if var_x_1 and var_x_1.role ~= native.EAssignedRole.Substitute and var_x_1.inPlayState == native.EInPlayState.InPlay then
			arg_x_1.state = "done"

			var_0_hia_log(string.format("side %d %s: back on for %s at %02d:%02d. Interchanges now: %s", arg_x_1.side, arg_x_1.surname, arg_x_1.replacementName, math.floor(var_x_4 / 60), math.floor(var_x_4 % 60), var_0_remaining(arg_x_2, arg_x_1.side)))
		elseif var_x_4 - arg_x_1.returnQueuedAt > HIAQueueTimeout * arg_x_2.timeScale then
			arg_x_1.state = "done"

			var_0_hia_log(string.format("side %d %s: return swap never happened, dropped", arg_x_1.side, arg_x_1.surname))
		end
	end
end

Class("InjuryEventListener", function(arg_1_0, arg_1_1)
	return
end)

function InjuryEventListener.registerWithMatchSim(arg_2_0, arg_2_1)
	arg_2_1:registerSolidEventListener(func.bindmethod(arg_2_0, arg_2_0.onInjuryEvent), "InjuryEvent")

	-- hia-protocol
	local var_2_0 = HIAManager()

	arg_2_1:registerUpdateable(function(...)
		var_2_0:update(...)
	end)
end

function InjuryEventListener.onInjuryEvent(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9)
	ASSERT(arg_3_1)

	local var_3_0 = arg_3_1.id
	local var_3_1 = arg_3_6:getComponent("matchOutData")
	local var_3_2 = arg_3_8:getGameObject(var_3_0):getTeam():getAssetId(var_3_0)
	local var_3_3 = arg_3_1.severity

	var_3_1:addNewInjuryFromValues(var_3_2, var_3_3, arg_3_1.injury, arg_3_1.duration)

	local var_3_4 = arg_3_4.hud and arg_3_4.hud:getElement("pitchoverlay")

	if var_3_4 and (var_3_3 == native.EInjurySeverity.Light or var_3_3 == native.EInjurySeverity.Minor) then
		var_3_4:assignInjuryIndicatorToPlayer(var_3_0)
	end
end
