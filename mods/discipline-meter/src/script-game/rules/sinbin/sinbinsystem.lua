import("core.foundation.class")
import("core.foundation.tablex")
import("core.foundation.func")
import("base.event.eventoccurred_request")
import("base.side.sidehelper")
import("game.player.playertype")
import("rules.sinbin.sinbincutscene_request")
import("rules.penalty.penaltytypes")
import("rules.rulestate.rulestate_request")
import("rules.sinbin.sinbininfo_request")
import("rules.sinbin.playersentoff_request")
import("rules.sinbin.playersenttosinbin_request")
import("ai.common.control_helper")

sinbin_config = load("script-config.design.sinbin.sinbin_config")

-- discipline-meter: every player has a discipline value (0..1) shown under stamina on the player
-- plate. It drains on bad events, faster when tired, rattled, under siege or chasing the score, and
-- recovers slowly when the team is in control. Low discipline makes CPU tacklers give away illegal
-- tackles (penalty, sin bin, rarely a send-off), sends high tacklers straight to the bin, and
-- lowers everyone's handling and goal kicking skills. Shared through _G.DisciplineState
-- (ai/tackle/tackle_arbitrator.lua rolls the tackles, sim/hud/playerinfo_hud.lua draws the bar).
local DisciplineDebug = true

local var_0_disc_config = {
	-- event costs/gains, as a fraction of a full bar (before multipliers)
	CostPenaltyConceded = 0.14,
	CostSixAgainConceded = 0.07,
	CostTryConceded = 0.06,
	GainTryScored = 0.1,
	CostLineBreakConceded = 0.03,
	GainLineBreak = 0.05,
	CostFended = 0.05,
	GainFend = 0.02,
	GainBigHit = 0.06,
	CostBigHitted = 0.07,
	CostKnockOn = 0.08,
	GainHalfTime = 0.35,
	-- passive rates per whole match (scaled by the fraction of the match clock that ran)
	RecoveryPerMatch = 0.8,
	FatigueDrainPerMatch = 0.5,
	DesperationDrainPerMatch = 0.6,
	-- team siege (0 = in control, 1 = under siege) scales every cost by 0.5..2
	SiegePenaltyConceded = 0.22,
	SiegeSixAgainConceded = 0.12,
	SiegeTryConceded = 0.3,
	SiegeLineBreakConceded = 0.15,
	SiegeKnockOn = 0.1,
	SiegeFended = 0.04,
	ReliefPenaltyWon = 0.25,
	ReliefTryScored = 0.5,
	ReliefBigHit = 0.08,
	ReliefOpponentKnockOn = 0.12,
	SiegeDecayPerMatch = 4,
	RecoverBelowSiege = 0.4,
	-- rattled: a personal state after being embarrassed or penalised
	RattledTime = 0.03,
	RattledMultiplier = 1.6,
	-- score: a deficit of this many points counts as fully "out of the game"
	ScoreGap = 18,
	CloseGameMargin = 6,
	CloseGameFrom = 0.8,
	-- effects
	IllegalTackleBelow = 0.5,
	IllegalTackleMaxChance = 0.1,
	BinBelow = 0.15,
	BinChance = 0.4,
	SendOffBelow = 0.07,
	SendOffChance = 0.12,
	SkillsDebuffBelow = 0.5,
	SkillsMaxDebuff = 0.25,
	DebuffSkills = {
		"basicPass",
		"longPass",
		"offload",
		"diveCollect",
		"contestedCollect",
		"placeKick",
		"fieldgoalKick"
	}
}
-- difficulty: the harder it is, the more your team's discipline drains and the more composed the
-- CPU stays. {human team, CPU team} drain multipliers, by EDifficulty name (a custom difficulty
-- uses its Misc base difficulty). Multiplied by the slider strength on top.
var_0_disc_config.DifficultyDrain = {
	Easiest = {
		0.5,
		1.25
	},
	Easy = {
		0.75,
		1.1
	},
	Medium = {
		1,
		1
	},
	Hard = {
		1.25,
		0.9
	},
	Hardest = {
		1.5,
		0.8
	}
}

-- The Custom Difficulties screen's MODDED section (app/academy/customdifficulty_edit_state.lua)
-- saves here, one section per difficulty: [preset_<EDifficulty>] or [<custom difficulty name>].
local var_0_disc_sliders_file = "rl26_revamp_sliders.ini"

local function var_0_disc_read_sliders()
	local var_sections = {}

	pcall(function()
		local var_file = io.open(var_0_disc_sliders_file, "r")

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

local var_0_disc_base_skills = {}
local var_0_disc_state

local function var_0_disc_clamp(arg_v, arg_lo, arg_hi)
	return math.max(arg_lo, math.min(arg_hi, arg_v))
end

local function var_0_disc_log(arg_fmt, ...)
	if not DisciplineDebug then
		return
	end

	local var_args = {
		...
	}

	pcall(function()
		local var_file = io.open("discipline_debug.txt", "a")

		if var_file then
			var_file:write(os.date("%H:%M:%S "), string.format(arg_fmt, unpack(var_args)), "\n")
			var_file:flush()
			var_file:close()
		end
	end)
end

-- drain, recovery and fatigue sensitivity by age: young players swing, veterans hold their nerve
-- but feel the legs late.
local function var_0_disc_age_traits(arg_age)
	if not arg_age or arg_age <= 0 then
		return 1, 1, 1
	elseif arg_age <= 20 then
		return 1.35, 1.3, 1
	elseif arg_age <= 23 then
		return 1.15, 1.15, 1
	elseif arg_age <= 28 then
		return 1, 1, 1
	elseif arg_age <= 31 then
		return 0.85, 0.95, 1.15
	end

	return 0.75, 0.9, 1.3
end

local function var_0_disc_new_state()
	return {
		players = {},
		flips = {},
		humanTackler = {},
		sides = {
			[sidehelper.home] = {
				siege = 0
			},
			[sidehelper.away] = {
				siege = 0
			}
		},
		score = {
			[sidehelper.home] = 0,
			[sidehelper.away] = 0
		},
		frac = nil,
		eventScale = 1,
		nextSummary = 0,
		-- set by var_0_disc_load_settings on the first update
		settings = nil,
		humanSide = {}
	}
end

local function var_0_disc_load_settings(arg_st, arg_match)
	local var_cfg = var_0_disc_config
	local var_md = arg_st.matchInData
	local var_difficulty = var_md and var_md.difficulty
	local var_key, var_base

	if var_difficulty == native.EDifficulty.Custom then
		pcall(function()
			local var_modifiers = arg_match.matchInProgressData.gameplayModifiers

			var_key = var_modifiers.name
			var_base = tostring(native.EDifficulty:fromInt(var_modifiers.sliderMiscDifficulty))
		end)
	elseif var_difficulty ~= nil then
		var_base = tostring(var_difficulty)
		var_key = "preset_" .. var_base
	end

	local var_section = var_0_disc_read_sliders()[var_key or ""] or {}
	local var_drain = var_cfg.DifficultyDrain[var_base or ""] or {
		1,
		1
	}

	arg_st.settings = {
		enabled = var_section.discipline ~= "off",
		strength = var_0_disc_clamp(tonumber(var_section.discipline_strength) or 1, 0.25, 3),
		humanDrain = var_drain[1],
		cpuDrain = var_drain[2]
	}

	var_0_disc_log("settings [%s] base %s: %s, strength x%.2f, drain human x%.2f cpu x%.2f", tostring(var_key), tostring(var_base), arg_st.settings.enabled and "on" or "OFF", arg_st.settings.strength, var_drain[1], var_drain[2])
end

-- slider strength x difficulty for this player's team (only drains are scaled, not gains)
local function var_0_disc_side_drain(arg_st, arg_side)
	local var_settings = arg_st.settings

	if not var_settings then
		return 1
	end

	return var_settings.strength * (arg_st.humanSide[arg_side] and var_settings.humanDrain or var_settings.cpuDrain)
end

local function var_0_disc_enabled(arg_st)
	return arg_st ~= nil and arg_st.settings ~= nil and arg_st.settings.enabled
end

local function var_0_disc_player(arg_st, arg_id, arg_obj)
	local var_p = arg_st.players[arg_id]

	if var_p then
		return var_p
	end

	arg_obj = arg_obj or arg_st.gameobjects and arg_st.gameobjects:getGameObject(arg_id, playertype.TypeId)

	if not arg_obj then
		return nil
	end

	local var_age, var_aggr
	local var_captain = false

	pcall(function()
		var_age = arg_st.matchInData:getTeamConfig(arg_obj.side):getPlayerAge(arg_obj.assetId)
	end)
	pcall(function()
		var_aggr = arg_obj:getAttribute("aggression")
	end)
	pcall(function()
		local var_team = arg_obj:getTeam()

		var_captain = var_team.captainId ~= nil and var_team.captainId == var_team:getAssetId(arg_id)
	end)

	-- most shipped players leave aggression unset (0, or 1 when getAttribute finds no value):
	-- treat that as average
	if type(var_aggr) ~= "number" or var_aggr <= 0 or var_aggr >= 1 then
		var_aggr = 0.5
	end

	local var_drain, var_recover, var_fatigue = var_0_disc_age_traits(var_age)

	var_p = {
		v = 1,
		side = arg_obj.side,
		age = var_age,
		aggression = var_aggr,
		captain = var_captain,
		drain = var_drain * (0.8 + 0.5 * var_aggr) * (var_captain and 0.8 or 1),
		recover = var_recover * (var_captain and 1.1 or 1),
		fatigueSens = var_fatigue,
		rattledUntil = -1,
		obj = arg_obj
	}
	arg_st.players[arg_id] = var_p

	var_0_disc_log("new player %d side %d age %s aggression %.2f captain %s drain x%.2f", arg_id, var_p.side, tostring(var_age), var_aggr, tostring(var_captain), var_p.drain)

	return var_p
end

local function var_0_disc_stamina(arg_st, arg_id, arg_p)
	local var_ok, var_s = pcall(function()
		local var_max = arg_p.obj:getDerivedAttribute("maxStamina") or 1

		return arg_st.services.pools.staminaInfoPool:get(arg_id).stamina / math.max(var_max, 0.01)
	end)

	return var_ok and type(var_s) == "number" and var_0_disc_clamp(var_s, 0, 1) or 1
end

-- returns the cost multiplier from the scoreboard, plus the "chasing" and "close game" stresses
local function var_0_disc_score(arg_st, arg_side)
	local var_cfg = var_0_disc_config
	local var_diff = (arg_st.score[arg_side] or 0) - (arg_st.score[sidehelper.getOtherSide(arg_side)] or 0)
	local var_late = var_0_disc_clamp(arg_st.frac or 0, 0, 1)
	local var_trailing = var_0_disc_clamp(-var_diff / var_cfg.ScoreGap, 0, 1)
	local var_leading = var_0_disc_clamp(var_diff / var_cfg.ScoreGap, 0, 1)
	local var_close = 0

	if math.abs(var_diff) <= var_cfg.CloseGameMargin and var_late > var_cfg.CloseGameFrom then
		var_close = (var_late - var_cfg.CloseGameFrom) / (1 - var_cfg.CloseGameFrom)
	end

	local var_stress = var_trailing * (0.5 + 0.5 * var_late)

	return 1 + var_stress + 0.6 * var_close - 0.4 * var_leading, var_stress, var_close
end

local function var_0_disc_is_rattled(arg_st, arg_p)
	return arg_st.frac ~= nil and arg_p.rattledUntil > arg_st.frac
end

local function var_0_disc_hit(arg_st, arg_id, arg_amount, arg_reason, arg_rattle)
	if not var_0_disc_enabled(arg_st) then
		return
	end

	local var_p = var_0_disc_player(arg_st, arg_id)

	if not var_p then
		return
	end

	local var_cfg = var_0_disc_config
	local var_s = var_0_disc_stamina(arg_st, arg_id, var_p)
	local var_fatigue = 1 + 2 * var_p.fatigueSens * math.max(0, 0.7 - var_s) / 0.7
	local var_score = var_0_disc_score(arg_st, var_p.side)
	local var_siege = 0.5 + 1.5 * arg_st.sides[var_p.side].siege
	local var_rattled = var_0_disc_is_rattled(arg_st, var_p) and var_cfg.RattledMultiplier or 1
	local var_side = var_0_disc_side_drain(arg_st, var_p.side)
	local var_loss = arg_amount * var_p.drain * var_fatigue * var_score * var_siege * var_rattled * var_side * arg_st.eventScale
	local var_before = var_p.v

	var_p.v = var_0_disc_clamp(var_p.v - var_loss, 0, 1)

	if arg_rattle and arg_st.frac then
		var_p.rattledUntil = arg_st.frac + var_cfg.RattledTime
	end

	var_0_disc_log("%-16s player %d: %.2f -> %.2f (stamina %.2f fatigue x%.2f score x%.2f siege x%.2f rattled x%.2f team x%.2f)", arg_reason, arg_id, var_before, var_p.v, var_s, var_fatigue, var_score, var_siege, var_rattled, var_side)
end

local function var_0_disc_gain(arg_st, arg_id, arg_amount, arg_reason)
	local var_p = var_0_disc_player(arg_st, arg_id)

	if var_p then
		var_p.v = var_0_disc_clamp(var_p.v + arg_amount * var_p.recover, 0, 1)
	end
end

local function var_0_disc_each_on_side(arg_st, arg_side, arg_fn)
	if not arg_st.gameobjects then
		return
	end

	for iter_id, iter_obj in arg_st.gameobjects:activeObjects(playertype.TypeId) do
		if iter_obj.side == arg_side then
			arg_fn(iter_id)
		end
	end
end

local function var_0_disc_siege(arg_st, arg_side, arg_amount)
	local var_side = arg_st.sides[arg_side]

	if var_side then
		var_side.siege = var_0_disc_clamp(var_side.siege + arg_amount, 0, 1)
	end
end

-- handling and goal kicking skills sag as discipline goes (the native mechanic job reads the live
-- skills pool, like the attribute testbed's sliders). Base values are kept so they can be restored.
local function var_0_disc_apply_skills(arg_st, arg_id, arg_p, arg_factor)
	local var_cfg = var_0_disc_config
	local var_factor = arg_factor

	if not var_factor then
		var_factor = 1

		if arg_p.v < var_cfg.SkillsDebuffBelow then
			var_factor = 1 - var_cfg.SkillsMaxDebuff * (1 - arg_p.v / var_cfg.SkillsDebuffBelow)
		end
	end

	local var_level = math.floor(var_factor * 100 + 0.5)

	if arg_p and arg_p.skillLevel == var_level then
		return
	end

	pcall(function()
		local var_skills = arg_st.services.pools.skillsPool:get(arg_id)
		local var_base = var_0_disc_base_skills[arg_id]

		if not var_base then
			var_base = {}

			for iter_i, iter_name in ipairs(var_cfg.DebuffSkills) do
				var_base[iter_name] = var_skills:getOption(iter_name)
			end

			var_0_disc_base_skills[arg_id] = var_base
		end

		for iter_name, iter_value in pairs(var_base) do
			var_skills:setOption(iter_name, math.floor(iter_value * var_factor + 0.5))
		end

		if arg_p then
			arg_p.skillLevel = var_level
		end
	end)
end

local function var_0_disc_restore_skills(arg_st)
	if not arg_st or not arg_st.services then
		return
	end

	for iter_id in pairs(var_0_disc_base_skills) do
		var_0_disc_apply_skills(arg_st, iter_id, nil, 1)
	end
end

local function var_0_disc_update(arg_st, arg_services, arg_match, arg_solid, arg_gameobjects, arg_time)
	local var_cfg = var_0_disc_config

	arg_st.services = arg_services
	arg_st.gameobjects = arg_gameobjects
	arg_st.matchInData = arg_match:getComponent("matchInData")

	if not arg_st.settings then
		var_0_disc_load_settings(arg_st, arg_match)
	end

	-- switched off on the sliders: everyone stays at 100% and nothing else happens
	if not arg_st.settings.enabled then
		return
	end

	pcall(function()
		local var_gamer_sides = arg_solid:getGamerSideEntity()

		for iter_i, iter_side in ipairs(sidehelper.sides) do
			arg_st.humanSide[iter_side] = var_gamer_sides:isAnyGamerOnSide(iter_side) and true or false
		end
	end)

	local var_info = arg_match:getComponent("matchInfo")
	local var_ok, var_frac = pcall(function()
		local var_length = var_info:getMatchLengthInSeconds(arg_solid, arg_time)

		return var_length > 0 and var_info:getMatchSecondsElapsedClamped(arg_solid, arg_time) / var_length or 0
	end)

	var_frac = var_ok and var_frac or arg_st.frac or 0

	local var_dt = arg_st.frac and var_frac - arg_st.frac or 0

	-- the clock stopping gives 0; a restart or a jump (extra time, replays) is ignored
	if var_dt < 0 or var_dt > 0.05 then
		var_dt = 0
	end

	arg_st.frac = var_frac

	pcall(function()
		-- same scaling as the stamina listener: event costs shrink in longer matches, which have
		-- more events (1 at 5 minute halves)
		arg_st.eventScale = var_0_disc_clamp(arg_solid:getMatchTimeEntity().timeModifier / 8, 0.1, 4)
	end)
	pcall(function()
		local var_scores = arg_solid:getScoreEntity()

		for iter_i, iter_side in ipairs(sidehelper.sides) do
			arg_st.score[iter_side] = native.ScoreInfo.getScore(arg_st.matchInData, var_scores, iter_side)
		end
	end)

	for iter_side, iter_info in pairs(arg_st.sides) do
		iter_info.siege = math.max(0, iter_info.siege - var_cfg.SiegeDecayPerMatch * var_dt)
	end

	for iter_id, iter_obj in arg_gameobjects:activeObjects(playertype.TypeId) do
		local var_p = var_0_disc_player(arg_st, iter_id, iter_obj)

		if var_p then
			if var_dt > 0 then
				local var_s = var_0_disc_stamina(arg_st, iter_id, var_p)
				local var_tired = math.max(0, 0.4 - var_s) / 0.4
				local var_mult, var_stress = var_0_disc_score(arg_st, var_p.side)
				local var_drain = (var_cfg.FatigueDrainPerMatch * var_tired * var_p.fatigueSens + var_cfg.DesperationDrainPerMatch * var_stress * var_frac) * var_p.drain * var_0_disc_side_drain(arg_st, var_p.side)
				local var_recover = 0

				if arg_st.sides[var_p.side].siege < var_cfg.RecoverBelowSiege and var_s > 0.5 and not var_0_disc_is_rattled(arg_st, var_p) then
					var_recover = var_cfg.RecoveryPerMatch * var_p.recover
				end

				var_p.v = var_0_disc_clamp(var_p.v + (var_recover - var_drain) * var_dt, 0, 1)
			end

			var_0_disc_apply_skills(arg_st, iter_id, var_p)
		end
	end

	if DisciplineDebug and var_frac >= arg_st.nextSummary then
		arg_st.nextSummary = var_frac + 0.05

		local var_line = {}

		for iter_id, iter_p in pairs(arg_st.players) do
			if iter_p.v < 0.6 then
				table.insert(var_line, string.format("%d:%.2f%s", iter_id, iter_p.v, var_0_disc_is_rattled(arg_st, iter_p) and "R" or ""))
			end
		end

		var_0_disc_log("summary %.0f%% score %d-%d siege %.2f/%.2f low: %s", var_frac * 100, arg_st.score[sidehelper.home] or 0, arg_st.score[sidehelper.away] or 0, arg_st.sides[sidehelper.home].siege, arg_st.sides[sidehelper.away].siege, table.concat(var_line, " "))
	end
end

DisciplineState = {
	config = var_0_disc_config
}

rawset(_G, "DisciplineState", DisciplineState)

-- HUD: value (0..1) and rattled flag, nil when the player has no record yet
function DisciplineState.get(arg_id)
	local var_st = var_0_disc_state
	local var_p = var_st and var_st.players[arg_id]

	-- no bar when switched off on the sliders
	if not var_p or not var_0_disc_enabled(var_st) then
		return nil
	end

	return var_p.v, var_0_disc_is_rattled(var_st, var_p)
end

-- tackle_arbitrator: does this (legal) tackle become an illegal one? CPU tacklers only.
function DisciplineState.rollIllegalTackle(arg_id, arg_gamers)
	local var_st = var_0_disc_state
	local var_cfg = var_0_disc_config

	if not var_0_disc_enabled(var_st) or not arg_id then
		return false
	end

	local var_human = false

	if arg_gamers then
		pcall(function()
			var_human = control_helper.getAnyGamerControllingGameobject(arg_gamers, arg_id) and true or false
		end)
	end

	var_st.humanTackler[arg_id] = var_human

	local var_p = var_0_disc_player(var_st, arg_id)

	if var_human or not var_p or var_p.v >= var_cfg.IllegalTackleBelow then
		return false
	end

	local var_x = (var_cfg.IllegalTackleBelow - var_p.v) / var_cfg.IllegalTackleBelow
	local var_chance = var_cfg.IllegalTackleMaxChance * var_x ^ 1.5

	if math.random() >= var_chance then
		return false
	end

	local var_severity = "penalty"

	if var_p.v < var_cfg.SendOffBelow and math.random() < var_cfg.SendOffChance * (0.5 + var_p.aggression) then
		var_severity = "sendoff"
	elseif var_p.v < var_cfg.BinBelow and math.random() < var_cfg.BinChance then
		var_severity = "bin"
	end

	var_st.flips[arg_id] = {
		severity = var_severity,
		frac = var_st.frac or 0
	}

	var_0_disc_log("ILLEGAL TACKLE player %d discipline %.2f chance %.3f -> %s", arg_id, var_p.v, var_chance, var_severity)

	return true
end

local function var_0_disc_take_flip(arg_st, arg_id)
	local var_flip = arg_st.flips[arg_id]

	arg_st.flips[arg_id] = nil

	if var_flip and (arg_st.frac or 0) - var_flip.frac < 0.02 then
		return var_flip
	end

	return nil
end

local function var_0_disc_tacklers_of(arg_solid, arg_guid)
	local var_ids = {}

	pcall(function()
		local var_tackle = arg_solid:getActiveTackleEntity():getTackle(arg_guid)

		for iter_i, iter_type in ipairs({
			native.ETackleParticipantType.Tackler1,
			native.ETackleParticipantType.Tackler2,
			native.ETackleParticipantType.Tackler3
		}) do
			local var_id = var_tackle and var_tackle:getParticipantId(iter_type)

			if var_id then
				table.insert(var_ids, var_id)
			end
		end
	end)

	return var_ids
end

local var_0_0 = penaltytypes.infringementTypes
local var_0_1 = {
	0.45,
	0.35,
	0.1,
	0.075
}

local function var_0_2(arg_1_0, arg_1_1)
	local var_1_0 = native.MatchOutInfringement.getMaxGrade(arg_1_0)
	local var_1_1 = arg_1_1:next()
	local var_1_2 = 0

	for iter_1_0 = 1, var_1_0 do
		local var_1_3 = var_1_2 + var_0_1[iter_1_0]

		if var_1_1 <= var_1_3 then
			return iter_1_0 - 1
		end

		var_1_2 = var_1_3
	end

	return var_1_0
end

Class("SinBinSystem", function(arg_2_0, arg_2_1, arg_2_2, arg_2_3)
	local var_2_0 = not VERIFY(arg_2_3.matchInData).sinBinsAndSendOffsEnabled or sinbin_config.disableSinBin

	arg_2_0.gameConfig = arg_2_3
	arg_2_0.engine = arg_2_1
	arg_2_0.universe = arg_2_2
	arg_2_0.sinbinDisabled = var_2_0

	-- discipline-meter: a new match has new player pools, so forget the old skill bases
	var_0_disc_state = nil
	var_0_disc_base_skills = {}

	arg_2_0:reset()
end)

function SinBinSystem.registerWithMatchSim(arg_3_0, arg_3_1)
	for iter_3_0, iter_3_1 in ipairs({
		"TryScoredEvent",
		"LineBreakEvent",
		"FendEvent",
		"BigHitEvent",
		"BigHittedEvent",
		"KnockOnOccurredEvent"
	}) do
		arg_3_1:registerSolidEventListener(func.bindmethod(arg_3_0, arg_3_0.onDisciplineEvent), iter_3_1)
	end

	arg_3_1:registerSolidEventListener(func.bindmethod(arg_3_0, arg_3_0.onPenaltyAwardedEvent), "PenaltyAwardedEvent")
	arg_3_1:registerSolidEventListener(func.bindmethod(arg_3_0, arg_3_0.onProcessSixAgainInfringementEvent), "ProcessSixAgainInfringementEvent")
	arg_3_1:registerSolidEventListener(func.bindmethod(arg_3_0, arg_3_0.onTimePeriodExpiredEvent), "TimePeriodExpiredEvent")
	arg_3_1:registerSolidEventListener(func.bindmethod(arg_3_0, arg_3_0.onSinBinInfoEvent), "SinBinInfoEvent")
	arg_3_1:registerSolidEventListener(func.bindmethod(arg_3_0, arg_3_0.onCutsceneEvent), "SinBinCutsceneEvent")
	arg_3_1:registerOnPreWipe(function(...)
		arg_3_0:onWipe(...)
	end)
end

function SinBinSystem.hasAuthority(arg_5_0, arg_5_1, arg_5_2)
	return (arg_5_1.network:isMaster())
end

function SinBinSystem.onMatchRestart(arg_6_0)
	arg_6_0:reset()
end

function SinBinSystem.reset(arg_7_0)
	local var_7_0 = sidehelper.home
	local var_7_1 = sidehelper.away
	local var_7_2 = sinbin_config.initialSinBinWarnings
	local var_7_3 = sinbin_config.initialSendOffWarnings

	arg_7_0.remainingSinBinWarnings = {
		[var_7_0] = var_7_2,
		[var_7_1] = var_7_2
	}
	arg_7_0.remainingSendOffWarnings = {
		[var_7_0] = var_7_3,
		[var_7_1] = var_7_3
	}
	arg_7_0.sinBinPlayersList = {
		[var_7_0] = {},
		[var_7_1] = {}
	}
	arg_7_0.sendOffPlayersList = {
		[var_7_0] = {},
		[var_7_1] = {}
	}
	arg_7_0.playerPenalised = {
		[var_7_0] = false,
		[var_7_1] = false
	}
	arg_7_0.pendingDeactivation = {}
	arg_7_0.pendingActivation = {}
	arg_7_0.pendingHudEvents = {}
	arg_7_0.individualInfringementCount = {
		[var_7_0] = {},
		[var_7_1] = {}
	}

	var_0_disc_restore_skills(var_0_disc_state)

	var_0_disc_state = var_0_disc_new_state()

	var_0_disc_log("---- match start ----")
end

-- discipline-meter: match events that move the meter (penalties are in onPenaltyAwardedEvent)
function SinBinSystem.onDisciplineEvent(arg_d_0, arg_d_1, arg_d_2, arg_d_3, arg_d_4, arg_d_5, arg_d_6, arg_d_7, arg_d_8, arg_d_9)
	local var_st = var_0_disc_state
	local var_cfg = var_0_disc_config

	if not var_st then
		return
	end

	var_st.gameobjects = var_st.gameobjects or arg_d_8

	local var_type = arg_d_1.type

	if var_type == "TryScoredEvent" then
		local var_scoring = arg_d_1.scoringSide
		local var_conceding = sidehelper.getOtherSide(var_scoring)

		var_0_disc_each_on_side(var_st, var_scoring, function(arg_id)
			var_0_disc_gain(var_st, arg_id, var_cfg.GainTryScored, "try scored")
		end)
		var_0_disc_each_on_side(var_st, var_conceding, function(arg_id)
			var_0_disc_hit(var_st, arg_id, var_cfg.CostTryConceded, "try conceded")
		end)
		var_0_disc_siege(var_st, var_conceding, var_cfg.SiegeTryConceded)
		var_0_disc_siege(var_st, var_scoring, -var_cfg.ReliefTryScored)
	elseif var_type == "LineBreakEvent" then
		local var_defending = sidehelper.getOtherSide(arg_d_1.attackingSide)

		var_0_disc_gain(var_st, arg_d_1.ballCarrierId, var_cfg.GainLineBreak, "line break")
		var_0_disc_each_on_side(var_st, var_defending, function(arg_id)
			var_0_disc_hit(var_st, arg_id, var_cfg.CostLineBreakConceded, "line break against")
		end)
		var_0_disc_siege(var_st, var_defending, var_cfg.SiegeLineBreakConceded)
	elseif var_type == "FendEvent" then
		var_0_disc_gain(var_st, arg_d_1.maker, var_cfg.GainFend, "fend")

		for iter_i, iter_id in ipairs(var_0_disc_tacklers_of(arg_d_7, arg_d_1.tackleGuid)) do
			local var_p = var_0_disc_player(var_st, iter_id)

			var_0_disc_hit(var_st, iter_id, var_cfg.CostFended, "fended", true)

			if var_p then
				var_0_disc_siege(var_st, var_p.side, var_cfg.SiegeFended)
			end
		end
	elseif var_type == "BigHitEvent" then
		local var_p = var_0_disc_player(var_st, arg_d_1.maker)

		var_0_disc_gain(var_st, arg_d_1.maker, var_cfg.GainBigHit, "big hit")

		if var_p then
			var_0_disc_siege(var_st, var_p.side, -var_cfg.ReliefBigHit)
		end
	elseif var_type == "BigHittedEvent" then
		var_0_disc_hit(var_st, arg_d_1.maker, var_cfg.CostBigHitted, "big hitted", true)
	elseif var_type == "KnockOnOccurredEvent" then
		local var_p = var_0_disc_player(var_st, arg_d_1.maker)

		var_0_disc_hit(var_st, arg_d_1.maker, var_cfg.CostKnockOn, "knock on")

		if var_p then
			var_0_disc_siege(var_st, var_p.side, var_cfg.SiegeKnockOn)
			var_0_disc_siege(var_st, sidehelper.getOtherSide(var_p.side), -var_cfg.ReliefOpponentKnockOn)
		end
	end
end

-- discipline-meter: a penalty or six-again costs the offender and puts his team under siege
local function var_0_disc_on_infringement(arg_id, arg_cost, arg_siege, arg_reason)
	local var_st = var_0_disc_state
	local var_p = var_st and arg_id and var_0_disc_player(var_st, arg_id)

	if not var_p then
		return
	end

	var_0_disc_hit(var_st, arg_id, arg_cost, arg_reason, true)
	var_0_disc_siege(var_st, var_p.side, arg_siege)
	var_0_disc_siege(var_st, sidehelper.getOtherSide(var_p.side), -var_0_disc_config.ReliefPenaltyWon)
end

function shouldPushSinBinCutscene(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5, arg_8_6, arg_8_7)
	local var_8_0 = native.Random.FromSystemTime():nextAsSeed()
	local var_8_1 = arg_8_3:getPenaltyEntity()
	local var_8_2 = arg_8_2.matchType.categorisedMatchType == native.EMatchType.MT_Nines
	local var_8_3 = arg_8_2.usingOffensiveRef
	local var_8_4

	var_8_4 = var_8_2 or not var_8_3

	local var_8_5 = arg_8_0.network:isMaster()

	if var_8_1.isSinBin and var_8_5 then
		local var_8_6, var_8_7, var_8_8 = arg_8_3:getOfficialEntity():getRefereesIds()
		local var_8_9 = var_8_6
		local var_8_10 = {
			cutsceneName = "SinBin",
			targetIds = {
				arg_8_7,
				var_8_9
			},
			nextState = arg_8_1,
			randomSeed = var_8_0,
			guid = arg_8_6
		}
		local var_8_11 = class.instantiate("SinBinCutsceneRuleState", var_8_10)

		return rulestate_request.RuleStateRequest(var_8_11, arg_8_6)
	elseif var_8_1.isSentOff and var_8_5 then
		local var_8_12, var_8_13, var_8_14 = arg_8_3:getOfficialEntity():getRefereesIds()
		local var_8_15 = var_8_12
		local var_8_16 = {
			cutsceneName = "SendOff",
			targetIds = {
				arg_8_7,
				var_8_15
			},
			nextState = arg_8_1,
			randomSeed = var_8_0,
			guid = arg_8_6
		}
		local var_8_17 = class.instantiate("SinBinCutsceneRuleState", var_8_16)

		return rulestate_request.RuleStateRequest(var_8_17, arg_8_6)
	else
		return rulestate_request.RuleStateRequest(arg_8_1, arg_8_6)
	end
end

function SinBinSystem.onCutsceneEvent(arg_9_0, arg_9_1, arg_9_2, arg_9_3, arg_9_4, arg_9_5, arg_9_6, arg_9_7, arg_9_8, arg_9_9)
	return
end

function SinBinSystem.onTimePeriodExpiredEvent(arg_10_0, arg_10_1, arg_10_2, arg_10_3, arg_10_4, arg_10_5, arg_10_6, arg_10_7, arg_10_8, arg_10_9)
	local var_10_0 = sinbin_config.initialSinBinWarnings
	local var_10_1 = sinbin_config.initialSendOffWarnings
	local var_10_2 = sidehelper.home
	local var_10_3 = sidehelper.away

	arg_10_0.remainingSinBinWarnings = {
		[var_10_2] = var_10_0,
		[var_10_3] = var_10_0
	}
	arg_10_0.remainingSendOffWarnings = {
		[var_10_2] = var_10_1,
		[var_10_3] = var_10_1
	}

	-- discipline-meter: the break settles everyone down
	local var_10_st = var_0_disc_state

	if var_10_st and not arg_10_1.matchCompleted then
		for iter_10_0, iter_10_1 in pairs(var_10_st.players) do
			var_0_disc_gain(var_10_st, iter_10_0, var_0_disc_config.GainHalfTime, "break")

			iter_10_1.rattledUntil = -1
		end

		for iter_10_2, iter_10_3 in pairs(var_10_st.sides) do
			iter_10_3.siege = 0
		end

		var_0_disc_log("break: discipline recovered, siege cleared")
	end
end

function SinBinSystem.onHighTacklePenaltyEvent(arg_11_0, arg_11_1, arg_11_2, arg_11_3, arg_11_4, arg_11_5, arg_11_6, arg_11_7, arg_11_8, arg_11_9)
	if arg_11_0.sinbinDisabled then
		return
	end

	local var_11_0 = arg_11_0:hasAuthority(arg_11_4, arg_11_7)
	local var_11_1 = arg_11_1.infringementById
	local var_11_2 = arg_11_1.time
	local var_11_3 = arg_11_8:getGameObject(var_11_1, playertype.TypeId)
	local var_11_4 = var_11_3:getSide()

	-- discipline-meter: a CPU player with no discipline left skips the team warnings and goes
	-- straight to the bin (rarely off, more likely for aggressive players)
	local var_11_disc_st = var_0_disc_state
	local var_11_disc_p = var_11_disc_st and var_11_disc_st.players[var_11_1]
	local var_11_disc_cfg = var_0_disc_config

	if var_11_disc_p and var_11_disc_st.humanTackler[var_11_1] ~= true and var_11_disc_p.v < var_11_disc_cfg.BinBelow then
		arg_11_0.remainingSendOffWarnings[var_11_4] = 0

		if var_11_disc_p.v < var_11_disc_cfg.SendOffBelow and math.random() < var_11_disc_cfg.SendOffChance * (0.5 + var_11_disc_p.aggression) then
			arg_11_0.individualInfringementCount[var_11_4][var_11_1] = 99

			var_0_disc_log("HIGH TACKLE player %d discipline %.2f -> send off", var_11_1, var_11_disc_p.v)
		else
			var_0_disc_log("HIGH TACKLE player %d discipline %.2f -> straight to the bin", var_11_1, var_11_disc_p.v)
		end
	end
	local var_11_5 = arg_11_0.remainingSendOffWarnings
	local var_11_6 = var_11_5[var_11_4]
	local var_11_7 = math.max(var_11_6 - 1, 0)
	local var_11_8 = tablex.icount(arg_11_0.sinBinPlayersList[var_11_4]) + tablex.icount(arg_11_0.sendOffPlayersList[var_11_4])
	local var_11_9 = var_11_8 < sinbin_config.maximumPlayerPenalty
	local var_11_10 = var_11_6 == 0
	local var_11_11 = not var_11_10
	local var_11_12 = sinbin_config.sinbinStatus
	local var_11_13 = arg_11_6:getComponent("matchInfo"):getMatchSecondsElapsedClamped(arg_11_7, var_11_2)
	local var_11_14 = native.Random.FromSystemTime()
	local var_11_15 = var_11_14:nextAsSeed()
	local var_11_16 = arg_11_6:getComponent("matchInData")
	local var_11_17 = var_11_16.rules

	if var_11_9 and var_11_11 and var_11_0 then
		local var_11_18 = arg_11_6:getComponent("matchOutData")
		local var_11_19 = var_11_3:getTeam():getAssetId(var_11_1)
		local var_11_20

		if not arg_11_0.individualInfringementCount[var_11_4][var_11_1] then
			var_11_20 = native.MatchOutInfringementType.CarelessHighTackle
		elseif arg_11_0.individualInfringementCount[var_11_4][var_11_1] == 1 then
			var_11_20 = native.MatchOutInfringementType.RecklessHighTackle
		elseif arg_11_0.individualInfringementCount[var_11_4][var_11_1] >= 2 then
			var_11_20 = native.MatchOutInfringementType.IntentionalHighTackle
		end

		local var_11_21 = var_0_2(var_11_20, var_11_14)

		if var_11_18:canAddCharge() then
			var_11_18:addNewChargeFromValues(var_11_19, var_11_20, var_11_21)
		end

		if arg_11_0.individualInfringementCount[var_11_4][var_11_1] then
			arg_11_0.individualInfringementCount[var_11_4][var_11_1] = arg_11_0.individualInfringementCount[var_11_4][var_11_1] + 1
		else
			arg_11_0.individualInfringementCount[var_11_4][var_11_1] = 1
		end

		local var_11_22 = var_11_6 == 1 and "SendOffFinalWarningEvent" or "SendOffWarningEvent"

		arg_11_9:add(eventoccurred_request.EventOccurredRequest(var_11_22))
	end

	if var_11_9 and var_11_10 then
		local var_11_23 = var_11_16.matchType.categorisedMatchType == native.EMatchType.MT_Nines
		local var_11_24 = {
			penaltyComplete = false,
			id = var_11_1,
			side = var_11_4,
			status = var_11_12.SentOff,
			entryElapsedMatchTime = var_11_13,
			penaltyDuration = var_11_23 and sinbin_config.sinbinDurationAucklandNines or sinbin_config.sinbinDuration
		}

		var_11_7 = sinbin_config.subsequentSendOffWarnings
		arg_11_0.playerPenalised[var_11_4] = true

		if var_11_0 then
			local var_11_25 = arg_11_6:getComponent("matchOutData")
			local var_11_26 = var_11_3:getTeam():getAssetId(var_11_1)
			local var_11_27

			if not arg_11_0.individualInfringementCount[var_11_4][var_11_1] then
				var_11_27 = native.MatchOutInfringementType.CarelessHighTackle
			elseif arg_11_0.individualInfringementCount[var_11_4][var_11_1] == 1 then
				var_11_27 = native.MatchOutInfringementType.RecklessHighTackle
			elseif arg_11_0.individualInfringementCount[var_11_4][var_11_1] >= 2 then
				var_11_27 = native.MatchOutInfringementType.IntentionalHighTackle
			end

			local var_11_28 = var_0_2(var_11_27, var_11_14)

			if var_11_25:canAddCharge() then
				var_11_25:addNewChargeFromValues(var_11_26, var_11_27, var_11_28)
			end

			if arg_11_0.individualInfringementCount[var_11_4][var_11_1] then
				arg_11_0.individualInfringementCount[var_11_4][var_11_1] = arg_11_0.individualInfringementCount[var_11_4][var_11_1] + 1
			else
				arg_11_0.individualInfringementCount[var_11_4][var_11_1] = 1
			end

			local var_11_29 = var_11_16.difficulty == native.EDifficulty.Custom
			local var_11_30 = arg_11_4.party:getPrimaryPartyMember()
			local var_11_31 = arg_11_6.matchInProgressData.gameplayModifiers
			local var_11_32 = var_11_31 and var_11_31.sendOffAggressionCustom
			local var_11_33 = var_11_32 and 3 - var_11_32 or 3
			local var_11_34 = var_11_29 and var_11_33 or 2
			local var_11_35
			local var_11_36

			if var_11_34 < arg_11_0.individualInfringementCount[var_11_4][var_11_1] then
				formatPrint("[sinbinsystem] SENT OFF: id: %d, individualInfin: %d, offenseLimit: %d", var_11_1, arg_11_0.individualInfringementCount[var_11_4][var_11_1], var_11_34)

				var_11_35 = "%SENTOFF%"
				var_11_36 = sinbin_config.sendoffCutSceneName[var_11_17]
				var_11_24.status = var_11_12.SentOff
			else
				formatPrint("[sinbinsystem] SIN BIN: id: %d, individualInfin: %d, offenseLimit: %d", var_11_1, arg_11_0.individualInfringementCount[var_11_4][var_11_1], var_11_34)

				var_11_35 = "%SINBIN%"
				var_11_36 = sinbin_config.sinbinCutSceneName[var_11_17]
				var_11_24.status = var_11_12.SinBin
			end

			ASSERT(var_11_35)
			ASSERT(var_11_36)
			arg_11_9:add(sinbininfo_request.SinBinInfoRequest(var_11_24))
			arg_11_9:add(sinbincutscene_request.SinBinCutsceneRequest({
				primaryTargetId = var_11_1,
				primarySide = var_11_4,
				subtext = var_11_35,
				cutsceneType = var_11_36,
				matchRules = var_11_17:toInt(),
				randomSeed = var_11_15
			}))

			if var_11_34 < arg_11_0.individualInfringementCount[var_11_4][var_11_1] then
				arg_11_9:add(playersentoff_request.PlayerSentOffRequest({
					maker = var_11_1
				}))
			else
				arg_11_9:add(playersenttosinbin_request.PlayerSentToSinBinRequest({
					maker = var_11_1
				}))
			end
		end
	end

	print("[SINBIN] - penalisedPlayerCount: {1}  canPenalise: {2}  updatedWarningCount: {3}" % {
		var_11_8,
		var_11_9,
		var_11_7
	})

	var_11_5[var_11_4] = var_11_7
end

function SinBinSystem.onTackleOffBallPenaltyEvent(arg_12_0, arg_12_1, arg_12_2, arg_12_3, arg_12_4, arg_12_5, arg_12_6, arg_12_7, arg_12_8, arg_12_9)
	local var_12_0 = arg_12_0.sinbinDisabled
	local var_12_1 = arg_12_0:hasAuthority(arg_12_4, arg_12_7)

	if var_12_0 or not var_12_1 then
		return
	end

	local var_12_2 = arg_12_1.infringementById
	local var_12_3 = arg_12_1.time
	local var_12_4 = arg_12_8:getGameObject(var_12_2, playertype.TypeId):getSide()

	if not (tablex.icount(arg_12_0.sinBinPlayersList[var_12_4]) + tablex.icount(arg_12_0.sendOffPlayersList[var_12_4]) < sinbin_config.maximumPlayerPenalty) then
		return
	end

	local var_12_5 = sinbin_config.sinbinStatus
	local var_12_6 = arg_12_6:getComponent("matchInfo")
	local var_12_7 = arg_12_6:getComponent("matchInData").rules
	local var_12_8 = var_12_6:getMatchSecondsElapsedClamped(arg_12_7, var_12_3)
	local var_12_9 = native.Random.FromSystemTime():nextAsSeed()
	local var_12_10 = "%SINBIN%"
	local var_12_11 = sinbin_config.sinbinCutSceneName[var_12_7]
	local var_12_12 = {
		penaltyComplete = false,
		id = var_12_2,
		side = var_12_4,
		status = var_12_5.SinBin,
		entryElapsedMatchTime = var_12_8,
		penaltyDuration = sinbin_config.sinbinDuration
	}

	arg_12_9:add(sinbininfo_request.SinBinInfoRequest(var_12_12))
	arg_12_9:add(sinbincutscene_request.SinBinCutsceneRequest({
		primaryTargetId = var_12_2,
		primarySide = var_12_4,
		subtext = var_12_10,
		cutsceneType = var_12_11,
		matchRules = var_12_7:toInt(),
		randomSeed = var_12_9
	}))
	arg_12_9:add(playersenttosinbin_request.PlayerSentToSinBinRequest({
		maker = var_12_2
	}))
end

-- discipline-meter: arg_13_10 = true sends the player off instead of to the bin
function SinBinSystem.onIllegalTacklePenaltyEvent(arg_13_0, arg_13_1, arg_13_2, arg_13_3, arg_13_4, arg_13_5, arg_13_6, arg_13_7, arg_13_8, arg_13_9, arg_13_10)
	local var_13_0 = arg_13_0.sinbinDisabled
	local var_13_1 = arg_13_0:hasAuthority(arg_13_4, arg_13_7)

	if var_13_0 or not var_13_1 then
		return
	end

	local var_13_2 = arg_13_1.infringementById
	local var_13_3 = arg_13_1.time
	local var_13_4 = arg_13_8:getGameObject(var_13_2, playertype.TypeId):getSide()

	if not (tablex.icount(arg_13_0.sinBinPlayersList[var_13_4]) + tablex.icount(arg_13_0.sendOffPlayersList[var_13_4]) < sinbin_config.maximumPlayerPenalty) then
		return
	end

	local var_13_5 = sinbin_config.sinbinStatus
	local var_13_6 = arg_13_6:getComponent("matchInfo")
	local var_13_7 = arg_13_6:getComponent("matchInData").rules
	local var_13_8 = var_13_6:getMatchSecondsElapsedClamped(arg_13_7, var_13_3)
	local var_13_9 = native.Random.FromSystemTime():nextAsSeed()
	local var_13_10 = arg_13_10 and "%SENTOFF%" or "%SINBIN%"
	local var_13_11 = arg_13_10 and sinbin_config.sendoffCutSceneName[var_13_7] or sinbin_config.sinbinCutSceneName[var_13_7]
	local var_13_12 = {
		penaltyComplete = false,
		id = var_13_2,
		side = var_13_4,
		status = arg_13_10 and var_13_5.SentOff or var_13_5.SinBin,
		entryElapsedMatchTime = var_13_8,
		penaltyDuration = sinbin_config.sinbinDuration
	}

	arg_13_9:add(sinbininfo_request.SinBinInfoRequest(var_13_12))
	arg_13_9:add(sinbincutscene_request.SinBinCutsceneRequest({
		primaryTargetId = var_13_2,
		primarySide = var_13_4,
		subtext = var_13_10,
		cutsceneType = var_13_11,
		matchRules = var_13_7:toInt(),
		randomSeed = var_13_9
	}))

	if arg_13_10 then
		arg_13_0.playerPenalised[var_13_4] = true

		arg_13_9:add(playersentoff_request.PlayerSentOffRequest({
			maker = var_13_2
		}))
	else
		arg_13_9:add(playersenttosinbin_request.PlayerSentToSinBinRequest({
			maker = var_13_2
		}))
	end
end

function SinBinSystem.onHeldInTacklePenaltyEvent(arg_14_0, arg_14_1, arg_14_2, arg_14_3, arg_14_4, arg_14_5, arg_14_6, arg_14_7, arg_14_8, arg_14_9)
	if arg_14_0.sinbinDisabled then
		return
	end

	local var_14_0 = arg_14_0:hasAuthority(arg_14_4, arg_14_7)
	local var_14_1 = arg_14_1.infringementById
	local var_14_2 = arg_14_1.time
	local var_14_3 = arg_14_8:getGameObject(var_14_1, playertype.TypeId)
	local var_14_4 = var_14_3:getSide()
	local var_14_5 = arg_14_0.remainingSinBinWarnings
	local var_14_6 = var_14_5[var_14_4]
	local var_14_7 = math.max(var_14_6 - 1, 0)
	local var_14_8 = tablex.icount(arg_14_0.sinBinPlayersList[var_14_4]) + tablex.icount(arg_14_0.sendOffPlayersList[var_14_4])
	local var_14_9 = var_14_8 < sinbin_config.maximumPlayerPenalty
	local var_14_10 = var_14_6 == 0
	local var_14_11 = not var_14_10

	if var_14_9 and var_14_11 and var_14_0 then
		local var_14_12 = var_14_6 == 1 and "SinBinFinalWarningEvent" or "SinBinWarningEvent"

		arg_14_9:add(eventoccurred_request.EventOccurredRequest(var_14_12))
	end

	if var_14_9 and var_14_10 then
		local var_14_13 = sinbin_config.sinbinStatus
		local var_14_14 = arg_14_6:getComponent("matchInfo"):getMatchSecondsElapsedClamped(arg_14_7, var_14_2)
		local var_14_15 = native.Random.FromSystemTime()
		local var_14_16 = var_14_15:nextAsSeed()
		local var_14_17 = arg_14_6:getComponent("matchInData").matchType.categorisedMatchType == native.EMatchType.MT_Nines
		local var_14_18 = {
			penaltyComplete = false,
			id = var_14_1,
			side = var_14_4,
			status = var_14_13.SinBin,
			entryElapsedMatchTime = var_14_14,
			penaltyDuration = var_14_17 and sinbin_config.sinbinDurationAucklandNines or sinbin_config.sinbinDuration
		}

		var_14_7 = sinbin_config.subsequentSinBinWarnings
		arg_14_0.playerPenalised[var_14_4] = true

		if var_14_0 then
			local var_14_19 = arg_14_6:getComponent("matchOutData")
			local var_14_20 = var_14_3:getTeam():getAssetId(var_14_1)
			local var_14_21

			if not arg_14_0.individualInfringementCount[var_14_4][var_14_1] then
				var_14_21 = native.MatchOutInfringementType.CarelessHighTackle
			elseif arg_14_0.individualInfringementCount[var_14_4][var_14_1] == 1 then
				var_14_21 = native.MatchOutInfringementType.RecklessHighTackle
			elseif arg_14_0.individualInfringementCount[var_14_4][var_14_1] >= 2 then
				var_14_21 = native.MatchOutInfringementType.IntentionalHighTackle
			end

			local var_14_22 = var_0_2(var_14_21, var_14_15)

			if var_14_19:canAddCharge() then
				var_14_19:addNewChargeFromValues(var_14_20, var_14_21, var_14_22)
			end

			if arg_14_0.individualInfringementCount[var_14_4][var_14_1] then
				arg_14_0.individualInfringementCount[var_14_4][var_14_1] = arg_14_0.individualInfringementCount[var_14_4][var_14_1] + 1
			else
				arg_14_0.individualInfringementCount[var_14_4][var_14_1] = 1
			end

			arg_14_0:sendPlayerToSinBin(arg_14_6, var_14_1, var_14_3, var_14_4, var_14_18, var_14_16, arg_14_9)
		end

		print("[SINBIN] - added: {1}" % {
			var_14_3.name
		})
		print("[SINBIN] - penalisedPlayerCount: {1}  canPenalise: {2}  updatedWarningCount: {3}" % {
			var_14_8,
			var_14_9,
			var_14_7
		})
	end

	var_14_5[var_14_4] = var_14_7
end

function SinBinSystem.sendPlayerToSinBin(arg_15_0, arg_15_1, arg_15_2, arg_15_3, arg_15_4, arg_15_5, arg_15_6, arg_15_7)
	local var_15_0 = arg_15_1:getComponent("matchInData").rules

	arg_15_7:add(sinbininfo_request.SinBinInfoRequest(arg_15_5))
	arg_15_7:add(sinbincutscene_request.SinBinCutsceneRequest({
		subtext = "%SINBIN%",
		primaryTargetId = arg_15_2,
		primarySide = arg_15_4,
		cutsceneType = sinbin_config.sinbinCutSceneName[var_15_0],
		matchRules = var_15_0:toInt(),
		randomSeed = arg_15_6
	}))
	arg_15_7:add(playersenttosinbin_request.PlayerSentToSinBinRequest({
		maker = arg_15_2
	}))
end

function SinBinSystem.onPenaltyAwardedEvent(arg_16_0, arg_16_1, arg_16_2, arg_16_3, arg_16_4, arg_16_5, arg_16_6, arg_16_7, arg_16_8, arg_16_9)
	var_0_disc_on_infringement(arg_16_1.infringementById, var_0_disc_config.CostPenaltyConceded, var_0_disc_config.SiegePenaltyConceded, "penalty")

	if arg_16_1.infringmentType == var_0_0.HighTackle then
		arg_16_0:onHighTacklePenaltyEvent(arg_16_1, arg_16_2, arg_16_3, arg_16_4, arg_16_5, arg_16_6, arg_16_7, arg_16_8, arg_16_9)
	elseif arg_16_1.infringmentType == var_0_0.IllegalTackle then
		-- discipline-meter: an illegal tackle it caused is only binned when its roll said so
		local var_16_0 = var_0_disc_state and var_0_disc_take_flip(var_0_disc_state, arg_16_1.infringementById)

		if var_16_0 and var_16_0.severity == "penalty" then
			return
		end

		arg_16_0:onIllegalTacklePenaltyEvent(arg_16_1, arg_16_2, arg_16_3, arg_16_4, arg_16_5, arg_16_6, arg_16_7, arg_16_8, arg_16_9, var_16_0 ~= nil and var_16_0.severity == "sendoff")
	end
end

function SinBinSystem.onProcessSixAgainInfringementEvent(arg_17_0, arg_17_1, arg_17_2, arg_17_3, arg_17_4, arg_17_5, arg_17_6, arg_17_7, arg_17_8, arg_17_9)
	var_0_disc_on_infringement(arg_17_1.infringementById, var_0_disc_config.CostSixAgainConceded, var_0_disc_config.SiegeSixAgainConceded, "six again")

	if arg_17_1.penaltyType == var_0_0.HeldInTackle then
		arg_17_0:onHeldInTacklePenaltyEvent(arg_17_1, arg_17_2, arg_17_3, arg_17_4, arg_17_5, arg_17_6, arg_17_7, arg_17_8, arg_17_9)
	end
end

function SinBinSystem.onSinBinInfoEvent(arg_18_0, arg_18_1, arg_18_2, arg_18_3, arg_18_4, arg_18_5, arg_18_6, arg_18_7, arg_18_8, arg_18_9)
	local var_18_0 = sinbin_config.sinbinStatus

	if arg_18_1.status == var_18_0.SentOff then
		table.insert(arg_18_0.sendOffPlayersList[arg_18_1.side], arg_18_1)
		table.insert(arg_18_0.pendingDeactivation, arg_18_1)
	elseif arg_18_1.status == var_18_0.SinBin then
		table.insert(arg_18_0.sinBinPlayersList[arg_18_1.side], arg_18_1)
		table.insert(arg_18_0.pendingDeactivation, arg_18_1)
	elseif arg_18_1.status == var_18_0.OnField then
		local var_18_1 = arg_18_7:getMatchProgressionEntity()
		local var_18_2 = arg_18_6:getComponent("matchInfo"):getMatchSecondsElapsedClamped(arg_18_7, arg_18_1.time)
		local var_18_3 = arg_18_0.sinBinPlayersList
		local var_18_4 = arg_18_1.id
		local var_18_5 = arg_18_8:getGameObject(var_18_4, playertype.TypeId)
		local var_18_6 = var_18_5:getSinBinInfo(arg_18_7)

		var_18_6.status = var_18_0.OnField
		var_18_6.entryMatchElapsedTime = arg_18_1.entryElapsedMatchTime

		local var_18_7 = arg_18_1.side
		local var_18_8, var_18_9 = func.firstThat(function(arg_19_0, arg_19_1)
			return arg_19_1.id == var_18_4
		end, ipairs(var_18_3[var_18_7]))

		table.remove(var_18_3[var_18_7], var_18_8)
		var_18_1:decreaseSinBinCount(var_18_5.side)
		print("[SINBIN] - Added player: {id} at {time}" % {
			var_18_4,
			var_18_2
		})
		table.insert(arg_18_0.pendingHudEvents, {
			side = var_18_7,
			id = var_18_4
		})
	end

	arg_18_9:add(eventoccurred_request.EventOccurredRequest("AutoInterchangeShuffleEvent", {
		side = arg_18_1.side
	}))
	formatPrint("[SINBIN] - onSinBinInfoEvent %d at %.2f", arg_18_1.id, arg_18_1.entryElapsedMatchTime)
end

function SinBinSystem.onWipe(arg_20_0, arg_20_1, arg_20_2, arg_20_3, arg_20_4, arg_20_5, arg_20_6, arg_20_7, arg_20_8, arg_20_9, arg_20_10, arg_20_11)
	if arg_20_0.sinbinDisabled then
		return
	end

	local var_20_0 = arg_20_8:getMatchProgressionEntity()
	local var_20_1 = sinbin_config.sinbinStatus
	local var_20_2 = arg_20_0.pendingDeactivation

	for iter_20_0, iter_20_1 in ipairs(var_20_2) do
		local var_20_3 = iter_20_1.id
		local var_20_4 = arg_20_9:getGameObject(var_20_3, playertype.TypeId)
		local var_20_5 = var_20_4:getSinBinInfo(arg_20_8)

		var_20_5.status = iter_20_1.status
		var_20_5.entryMatchElapsedTime = iter_20_1.entryElapsedMatchTime

		if iter_20_1.status == var_20_1.SinBin then
			var_20_0:incrementSinBinCount(var_20_4.side)
		else
			ASSERT(iter_20_1.status == var_20_1.SentOff)
			var_20_0:incrementSentOffCount(var_20_4.side)
		end

		print("[SINBIN] - Added player: {id} at {time%.2f} for {status}" % {
			var_20_3,
			iter_20_1.entryElapsedMatchTime,
			iter_20_1.status
		})
	end

	tablex.clear(var_20_2)
end

function SinBinSystem.update(arg_21_0, arg_21_1, arg_21_2, arg_21_3, arg_21_4, arg_21_5, arg_21_6, arg_21_7, arg_21_8, arg_21_9, arg_21_10)
	-- discipline-meter: runs even with sin bins switched off
	if var_0_disc_state then
		local var_21_disc_ok, var_21_disc_err = pcall(var_0_disc_update, var_0_disc_state, arg_21_3, arg_21_5, arg_21_6, arg_21_7, arg_21_9)

		if not var_21_disc_ok and not var_0_disc_state.errorLogged then
			var_0_disc_state.errorLogged = true

			var_0_disc_log("update error: %s", tostring(var_21_disc_err))
		end
	end

	if arg_21_0.sinbinDisabled then
		return
	end

	local var_21_0 = arg_21_0:hasAuthority(arg_21_3, arg_21_6)
	local var_21_1 = arg_21_0.sinBinPlayersList
	local var_21_2 = arg_21_5:getComponent("matchInfo"):getMatchSecondsElapsedClamped(arg_21_6, arg_21_9)

	for iter_21_0, iter_21_1 in ipairs(sidehelper.sides) do
		local var_21_3 = var_21_1[iter_21_1]

		for iter_21_2, iter_21_3 in pairs(var_21_3) do
			if not iter_21_3.penaltyComplete then
				local var_21_4 = iter_21_3.entryElapsedMatchTime
				local var_21_5 = iter_21_3.penaltyDuration <= var_21_2 - var_21_4

				iter_21_3.penaltyComplete = var_21_5

				if var_21_5 then
					local var_21_6 = sinbin_config.sinbinStatus
					local var_21_7 = {
						entryElapsedMatchTime = 0,
						id = iter_21_3.id,
						side = iter_21_1,
						status = var_21_6.OnField,
						time = arg_21_9
					}

					arg_21_10:add(sinbininfo_request.ClearSinBinInfoRequest(var_21_7))
					arg_21_10:add(eventoccurred_request.EventOccurredRequest("AutoInterchangeShuffleEvent", {
						side = iter_21_1
					}))
				end
			end
		end
	end

	local var_21_8 = arg_21_0.pendingHudEvents
	local var_21_9 = sidehelper.home
	local var_21_10 = sidehelper.away
	local var_21_11 = arg_21_0.sendOffPlayersList
	local var_21_12 = tablex.count(var_21_11[var_21_9])
	local var_21_13 = tablex.count(var_21_1[var_21_9])
	local var_21_14 = tablex.count(var_21_11[var_21_10])
	local var_21_15 = tablex.count(var_21_1[var_21_10])

	for iter_21_4, iter_21_5 in ipairs(var_21_8) do
		local var_21_16 = iter_21_5.side
		local var_21_17 = iter_21_5.id
		local var_21_18 = arg_21_7:getGameObject(var_21_17)

		if var_21_0 then
			arg_21_10:add(eventoccurred_request.EventOccurredRequest("SinBinCompletedEvent", {
				maker = var_21_17
			}))
		end
	end

	tablex.clear(arg_21_0.pendingHudEvents)
end

function SinBinSystem.getNumberOfPlayersInSinBin(arg_22_0, arg_22_1)
	return tablex.icount(arg_22_0.sinBinPlayersList[arg_22_1])
end

function SinBinSystem.getNumberOfPlayersSentOff(arg_23_0, arg_23_1)
	return tablex.icount(arg_23_0.sendOffPlayersList[arg_23_1])
end

function SinBinSystem.getPlayersInSinBin(arg_24_0, arg_24_1)
	return arg_24_0.sinBinPlayersList[arg_24_1]
end

function SinBinSystem.getPlayersSentOff(arg_25_0, arg_25_1)
	return arg_25_0.sendOffPlayersList[arg_25_1]
end

function SinBinSystem.isPlayerServingPenalty(arg_26_0, arg_26_1, arg_26_2)
	local var_26_0, var_26_1 = func.firstThat(function(arg_27_0, arg_27_1)
		return arg_27_1.id == arg_26_1
	end, ipairs(arg_26_0.sinBinPlayersList[arg_26_2]))
	local var_26_2, var_26_3 = func.firstThat(function(arg_28_0, arg_28_1)
		return arg_28_1.id == arg_26_1
	end, ipairs(arg_26_0.sendOffPlayersList[arg_26_2]))

	return var_26_1 or var_26_3
end

function SinBinSystem.checkAndResetPlayerPenalised(arg_29_0, arg_29_1)
	local var_29_0 = arg_29_0.playerPenalised[arg_29_1]

	arg_29_0.playerPenalised[arg_29_1] = false

	return var_29_0
end
