import("base.transition.logotransition_hud_ui")
import("script-config.design.sound.soundmap")
import("script-config.design.sound.soundmap_switches")
import("app.noesis.ns")
import("app.noesis.ns_viewmodel")
import("app.noesis.util.nvm_team")
import("base.side.sidehelper")

local var_0_0 = native.getEnvironment():argExists("marketingtools")
local var_0_1 = soundmap_switches.Switches.ScreenWipe_Switch
local var_0_2 = native.EWipeEventType

-- replay-team-stinger: a stinger in the scoring team's primary colour that slides in
-- at the end of a try celebration, holds while the replay loads and slides out once
-- the replay is playing. The view is the unused Views/Tests/MatchIntro XAML (build.py
-- can't add new files), bound to the HUD's own home/away NVMTeam. TeamStinger lives
-- here because LogoTransitionHud exists for every match HUD; the barrier side is in
-- base/transition/screenwipe.lua.
--
-- Flow:
-- 1. A try celebration queues a ReplayUniverseState at its start. update() tags it
--    with the scoring team (only while the rule state is in TeamStingerRuleStates,
--    so bunker/referee-cameo replays are left alone).
-- 2. When the celebration cutscene has TeamStingerCoverTime left, the stinger kicks
--    ("in"), so it covers the screen just as the celebration ends.
-- 3. ScreenWipeOut holds the replay barrier until the stinger covers ("covered").
--    A skipped celebration never reaches step 2, so the barrier kicks it instead.
-- 4. ScreenWipeIn releases it ("out") once the replay presenter is in playback.
--
-- 5. Outro (bunker-overturned-try only): when step 4 releases into a replay flagged
--    provisionalTryReplay, the outro is armed (pendingOutroTeam). The next ScreenWipeOut is
--    that replay's end barrier, and screenwipe.lua kicks the stinger there (kickOutro),
--    cutting back to the referee who sends the try upstairs.
--
-- TeamStingerCoverTime/OutTime must match the StingerIn/StingerOut storyboards.
local TeamStingerDebug = true
local TeamStingerView = "Workspace/Views/Tests/MatchIntro"
local TeamStingerCoverTime = 0.5
local TeamStingerOutTime = 0.5
local TeamStingerLeadTime = 0.05
local TeamStingerRevealDelay = 0.15
-- Outro hold after the barrier back to gameplay, while the referee cameo camera takes over.
local TeamStingerOutroRevealDelay = 0.35
local TeamStingerMaxHold = 5
local TeamStingerRuleStates = {
	TryCelebrateRuleState = true,
	CheerleaderCelebrateRuleState = true,
	-- field goals and 40m field goals both celebrate here
	FieldGoalCelebrateRuleState = true
}

local teamStingerLogFile
local teamStingerLogTried = false

-- Debug: TeamStingerDebug appends to teamstinger_debug.txt (game folder, else
-- Saved Games\Rugby League 26) when the Lua io library is available.
function teamStingerLog(arg_text)
	if not TeamStingerDebug then
		return
	end

	pcall(function()
		if not teamStingerLogTried then
			teamStingerLogTried = true

			if io and io.open then
				teamStingerLogFile = io.open("teamstinger_debug.txt", "a")

				if not teamStingerLogFile and os and os.getenv and os.getenv("USERPROFILE") then
					teamStingerLogFile = io.open(os.getenv("USERPROFILE") .. "/Saved Games/Rugby League 26/teamstinger_debug.txt", "a")
				end
			end
		end

		if teamStingerLogFile then
			teamStingerLogFile:write(tostring(arg_text) .. "\n")
			teamStingerLogFile:flush()
		end
	end)
end

-- Cutscene times may be plain seconds or native Time values.
local function teamStingerSeconds(arg_value)
	if rawtype(arg_value) == "number" then
		return arg_value
	end

	local var_ok, var_seconds = pcall(function()
		return arg_value:ToSeconds()
	end)

	return var_ok and rawtype(var_seconds) == "number" and var_seconds or nil
end

-- True on the frame the current cutscene's remaining time drops to arg_threshold.
-- A cutscene only counts once it's been seen with more than that left (kept in
-- arg_owner[arg_key]), so a finished one still sitting in currentCutscene can't fire.
local function teamStingerCutsceneEnding(arg_owner, arg_key, arg_universe, arg_threshold)
	local var_listener = arg_universe.cutsceneListener
	local var_cutscene = var_listener and var_listener.currentCutscene

	if not var_cutscene then
		return false
	end

	local var_duration = teamStingerSeconds(var_cutscene.duration)
	local var_time = teamStingerSeconds(var_cutscene.time)

	if not var_duration or not var_time then
		if arg_owner.loggedCutsceneTimes ~= var_cutscene then
			arg_owner.loggedCutsceneTimes = var_cutscene

			teamStingerLog("cutscene " .. tostring(var_cutscene.name) .. " has no usable time: duration " .. rawtype(var_cutscene.duration) .. ", time " .. rawtype(var_cutscene.time))
		end

		return false
	end

	local var_remaining = var_duration - var_time

	if arg_owner[arg_key] ~= var_cutscene then
		if var_remaining > arg_threshold then
			arg_owner[arg_key] = var_cutscene

			teamStingerLog(string.format("%s: watching cutscene %s (%.2fs of %.2fs)", arg_key, tostring(var_cutscene.name), var_time, var_duration))
		end

		return false
	end

	if var_remaining <= arg_threshold then
		arg_owner[arg_key] = nil

		teamStingerLog(string.format("%s: cutscene ending, %.2fs left", arg_key, var_remaining))

		return true
	end

	return false
end

-- Conversion wipe: after a conversion, the result cutscene hands to KickoffSetup and
-- then PositionPlayersTransitionRulestate, whose LogoScreenWipeOut freezes the frame
-- the moment it starts and only then kicks the logo wipe, so the cutscene visibly
-- stops while the wipe slides in. Kicking the wipe LogoPreKickLeadTime before the
-- cutscene ends means it already covers the screen when the freeze happens.
-- LogoScreenWipeOut (checkWipeState) won't re-kick a running wipe and waits for it to
-- cover, then the stock flow releases it as usual.
-- Rule state -> the nextState type it must lead to (one that always reaches the wipe).
local LogoPreKickLeadTime = 1
local LogoPreKickRuleStates = {
	ConversionCutsceneRuleState = "KickoffSetupRuleState"
}
-- Safety: if no LogoScreenWipeOut shows up this long after an early kick, release it.
local LogoPreKickTimeout = 3

local function logoPreKickUpdate(arg_hud, arg_dt, arg_uiServices)
	local var_universe = arg_uiServices and arg_uiServices.universe

	if not var_universe then
		return
	end

	if arg_hud.preKicked then
		arg_hud.preKickTime = arg_hud.preKickTime + arg_dt

		for iter_0, iter_1 in ipairs(var_universe:getUniverseStateStack().currentStack or {}) do
			if type(iter_1) == "LogoScreenWipeOut" then
				teamStingerLog(string.format("conversion wipe: barrier arrived %.2fs after kick, covered: %s", arg_hud.preKickTime, tostring(arg_hud.wipeUI:readyToTransition())))

				arg_hud.preKicked = nil

				return
			end
		end

		if arg_hud.preKickTime > LogoPreKickTimeout then
			teamStingerLog("conversion wipe: no barrier after " .. LogoPreKickTimeout .. "s, releasing")
			arg_hud.wipeUI:setNextStateIsReady()

			arg_hud.preKicked = nil
		end

		return
	end

	local var_matchSim = var_universe.matchSim
	local var_ruleState = var_matchSim and var_matchSim:editSolidState():getRuleState()
	local var_required = var_ruleState and LogoPreKickRuleStates[type(var_ruleState)]

	if var_required and type(var_ruleState.nextState) ~= var_required and arg_hud.loggedPreKickSkip ~= var_ruleState then
		arg_hud.loggedPreKickSkip = var_ruleState

		teamStingerLog("conversion wipe: " .. type(var_ruleState) .. " leads to " .. tostring(type(var_ruleState.nextState)) .. ", not kicking early")
	end

	if not var_required or type(var_ruleState.nextState) ~= var_required or arg_hud.enabled then
		arg_hud.logoPreKickCutscene = nil

		return
	end

	if teamStingerCutsceneEnding(arg_hud, "logoPreKickCutscene", var_universe, LogoPreKickLeadTime) then
		teamStingerLog("conversion wipe: kicked early")
		arg_hud:kick()

		arg_hud.preKicked = true
		arg_hud.preKickTime = 0
	end
end

ns.Class("NVMTeamStinger", ns_viewmodel.ViewModel, function(arg_s_0)
	ns_viewmodel.ViewModel.init(arg_s_0)

	arg_s_0.StingerState = "hidden"
end).Bindings = {
	Properties = {
		StingerState = ns.String,
		Team = ns.typeOf(nvm_team.NVMTeam)
	}
}

function NVMTeamStinger.dispose(arg_s_0)
	-- Team is the HUD's own NVMTeam: ViewModel.dispose would dispose it with us.
	arg_s_0.Team = nil

	ns_viewmodel.ViewModel.dispose(arg_s_0)
end

Class("TeamStinger", function(arg_t_0, arg_t_1, arg_t_2)
	arg_t_0.hud = arg_t_2
	arg_t_0.viewModel = NVMTeamStinger()

	local var_ok, var_view = pcall(function()
		return arg_t_1:getNoesis():loadViewWithVM(TeamStingerView, arg_t_0.viewModel, native.ENoesisViewManagerLayer.POST_SCENE, native.CNoesisViewManager.HighPriority)
	end)

	if var_ok and var_view then
		arg_t_0.view = var_view
	end

	teamStingerLog("created, view " .. (arg_t_0.view and "loaded" or "FAILED: " .. tostring(var_view)))
end)

function TeamStinger.dispose(arg_t_0)
	if arg_t_0.view then
		arg_t_0.view:release()

		arg_t_0.view = nil
	end

	if arg_t_0.viewModel then
		arg_t_0.viewModel:dispose()

		arg_t_0.viewModel = nil
	end
end

function TeamStinger.update(arg_t_0, arg_t_1, arg_t_2)
	local var_phase = arg_t_0.phase

	if var_phase then
		arg_t_0.time = arg_t_0.time + arg_t_1

		if var_phase == "in" and arg_t_0.time >= TeamStingerCoverTime then
			arg_t_0.phase = "covered"
			arg_t_0.time = 0

			teamStingerLog("covered")
		elseif var_phase == "covered" and arg_t_0.time >= TeamStingerMaxHold then
			teamStingerLog("covered for " .. TeamStingerMaxHold .. "s without a replay, releasing")
			arg_t_0:release()
		elseif var_phase == "out" and arg_t_0.time >= TeamStingerOutTime then
			teamStingerLog("finished")
			arg_t_0:reset()
		end

		return
	end

	local var_universe = arg_t_2 and arg_t_2.universe
	local var_matchSim = var_universe and var_universe.matchSim

	if not var_matchSim then
		return
	end

	local var_replay = arg_t_0:tagQueuedReplays(var_matchSim)

	if var_replay then
		arg_t_0:watchCutscene(var_universe, var_replay)
	end
end

-- Returns the queued try replay that hasn't had its stinger yet, tagging new ones.
function TeamStinger.tagQueuedReplays(arg_t_0, arg_t_1)
	local var_found

	for iter_t_0, iter_t_1 in ipairs(arg_t_1.universeStateQueue or {}) do
		if type(iter_t_1) == "ReplayUniverseState" then
			if iter_t_1.teamStingerChecked == nil then
				iter_t_1.teamStingerChecked = true

				local var_ok, var_team, var_ruleStateName = pcall(arg_t_0.scoringTeam, arg_t_0, arg_t_1)

				if var_ok then
					iter_t_1.teamStingerTeam = var_team

					teamStingerLog("replay queued during " .. tostring(var_ruleStateName) .. (var_team and ", stinger for " .. tostring(var_team.FullName) or ", no stinger"))
				else
					teamStingerLog("scoringTeam error: " .. tostring(var_team))
				end
			end

			if iter_t_1.teamStingerTeam and not iter_t_1.teamStingerKicked then
				var_found = iter_t_1
			end
		end
	end

	return var_found
end

function TeamStinger.scoringTeam(arg_t_0, arg_t_1)
	local var_ruleState = arg_t_1:editSolidState():getRuleState()
	local var_ruleStateName = var_ruleState and type(var_ruleState)

	if not TeamStingerRuleStates[var_ruleStateName] then
		return nil, var_ruleStateName
	end

	local var_side = var_ruleState.scoringSide

	if var_side == nil and var_ruleState.scorer then
		var_side = arg_t_1:getGameObjects():getGameObject(var_ruleState.scorer).side
	end

	if var_side == sidehelper.home then
		return arg_t_0.hud.homeTeamNVM, var_ruleStateName
	elseif var_side == sidehelper.away then
		return arg_t_0.hud.awayTeamNVM, var_ruleStateName
	end

	return nil, var_ruleStateName
end

-- Kicks the stinger when the celebration cutscene is TeamStingerCoverTime from its end.
-- A cutscene only counts once it's been seen with more than that left, so a finished
-- one still sitting in currentCutscene can't kick it early.
function TeamStinger.watchCutscene(arg_t_0, arg_t_1, arg_t_2)
	if teamStingerCutsceneEnding(arg_t_0, "watchedCutscene", arg_t_1, TeamStingerCoverTime + TeamStingerLeadTime) then
		teamStingerLog("kick from cutscene")
		arg_t_0:kick(arg_t_2)
	end
end

function TeamStinger.kick(arg_t_0, arg_t_1)
	if not arg_t_0.view or arg_t_0.phase then
		return false
	end

	arg_t_1.teamStingerKicked = true
	arg_t_0.pendingOutroTeam = nil
	arg_t_0.replay = arg_t_1
	arg_t_0.viewModel.Team = arg_t_1.teamStingerTeam
	arg_t_0.viewModel.StingerState = "in"
	arg_t_0.phase = "in"
	arg_t_0.time = 0
	arg_t_0.revealTime = 0
	arg_t_0.revealDelay = TeamStingerRevealDelay

	return true
end

-- Outro: covers the end of a replay. No replay to wait for, so updateReveal releases it
-- TeamStingerOutroRevealDelay after the barrier hands back to gameplay.
function TeamStinger.kickOutro(arg_t_0, arg_t_1)
	if not arg_t_0.view or arg_t_0.phase or not arg_t_1 then
		return false
	end

	arg_t_0.replay = nil
	arg_t_0.viewModel.Team = arg_t_1
	arg_t_0.viewModel.StingerState = "in"
	arg_t_0.phase = "in"
	arg_t_0.time = 0
	arg_t_0.revealTime = 0
	arg_t_0.revealDelay = TeamStingerOutroRevealDelay

	return true
end

function TeamStinger.isActiveFor(arg_t_0, arg_t_1)
	return arg_t_0.phase ~= nil and arg_t_0.replay == arg_t_1
end

function TeamStinger.isCovered(arg_t_0)
	return arg_t_0.phase == "covered"
end

function TeamStinger.isBusy(arg_t_0)
	return arg_t_0.phase ~= nil
end

-- Called by ScreenWipeIn each frame with the state under it (the replay).
function TeamStinger.updateReveal(arg_t_0, arg_t_1, arg_t_2)
	if arg_t_0.phase ~= "covered" then
		return
	end

	local var_presenter = arg_t_0.replay and arg_t_1 == arg_t_0.replay and arg_t_1.replayPresenter or nil

	if var_presenter and not var_presenter:isInPlayback() then
		return
	end

	arg_t_0.revealTime = arg_t_0.revealTime + arg_t_2

	if arg_t_0.revealTime >= (arg_t_0.revealDelay or TeamStingerRevealDelay) then
		teamStingerLog(var_presenter and "replay playing, releasing" or "replay gone, releasing")

		if var_presenter and arg_t_0.replay.provisionalTryReplay then
			arg_t_0.pendingOutroTeam = arg_t_0.replay.teamStingerTeam

			teamStingerLog("outro: armed for the end of the provisional try replay")
		end

		arg_t_0:release()
	end
end

function TeamStinger.release(arg_t_0)
	if arg_t_0.phase == "in" or arg_t_0.phase == "covered" then
		arg_t_0.phase = "out"
		arg_t_0.time = 0
		arg_t_0.viewModel.StingerState = "out"
	end
end

function TeamStinger.reset(arg_t_0)
	arg_t_0.phase = nil
	arg_t_0.replay = nil

	if arg_t_0.viewModel then
		arg_t_0.viewModel.StingerState = "hidden"
	end
end

Class("LogoTransitionHud", function(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7)
	local var_1_0 = native.UIWidgetArea(arg_1_1)
	local var_1_1 = logotransition_hud_ui.LogoTransitionUI(arg_1_1, arg_1_2, arg_1_3, var_1_0)

	arg_1_0.area = var_1_0
	arg_1_0.soundManager = arg_1_1:getSoundManager()
	arg_1_0.wipeStateSounds = {
		[var_0_2.Intro] = nil,
		[var_0_2.Outro] = nil
	}
	arg_1_0.wipeType = native.EWipeType.Default
	arg_1_0.wipeUI = var_1_1
	arg_1_0.lastSystemTime = native.Time()

	arg_1_0:setEnabled(false)

	-- replay-team-stinger
	local var_1_2, var_1_3 = pcall(TeamStinger, arg_1_1, arg_1_7)

	if var_1_2 then
		arg_1_0.teamStinger = var_1_3
	else
		teamStingerLog("TeamStinger error: " .. tostring(var_1_3))
	end
end)

function LogoTransitionHud.setEnabled(arg_2_0, arg_2_1)
	arg_2_0.enabled = arg_2_1

	arg_2_0.wipeUI:setEnabled(arg_2_1)
end

function LogoTransitionHud.registerWithMatchSim(arg_3_0, arg_3_1)
	return
end

function LogoTransitionHud.dispose(arg_4_0, arg_4_1)
	-- replay-team-stinger
	if arg_4_0.teamStinger then
		arg_4_0.teamStinger:dispose()

		arg_4_0.teamStinger = nil
	end

	arg_4_0.wipeUI:dispose()

	arg_4_0.wipeUI = nil

	arg_4_0.area:dispose()

	arg_4_0.area = nil
end

function LogoTransitionHud.update(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7, arg_5_8, arg_5_9, arg_5_10, arg_5_11, arg_5_12)
	-- replay-team-stinger: arg_5_8 is the frame dt, arg_5_11 the HUD's uiServices.
	local var_5_1 = arg_5_0.teamStinger

	if var_5_1 then
		local var_5_2, var_5_3 = pcall(var_5_1.update, var_5_1, arg_5_8, arg_5_11)

		if not var_5_2 then
			teamStingerLog("update error: " .. tostring(var_5_3))
			pcall(var_5_1.reset, var_5_1)
		end
	end

	local var_5_4, var_5_5 = pcall(logoPreKickUpdate, arg_5_0, arg_5_8, arg_5_11)

	if not var_5_4 then
		teamStingerLog("conversion wipe error: " .. tostring(var_5_5))

		arg_5_0.preKicked = nil
	end

	arg_5_0:updateImpl(arg_5_1, arg_5_7, arg_5_8, arg_5_12, arg_5_2)

	local var_5_0 = arg_5_0.wipeUI:getWipeProgressState()

	if var_5_0 then
		arg_5_0:processWipeStateSound(var_5_0, arg_5_11)
	end
end

function LogoTransitionHud.updateImpl(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5)
	if not arg_6_0.enabled then
		return
	end

	local var_6_0 = math.min(0.033, arg_6_2 - arg_6_0.lastSystemTime)

	arg_6_0.area:update(var_6_0)
	arg_6_0.wipeUI:update(var_6_0)

	if arg_6_0.wipeUI:getIsFinished() then
		print("Logo transition - finished")
		arg_6_0:setEnabled(false)
	end
end

function LogoTransitionHud.render(arg_7_0, arg_7_1, arg_7_2, arg_7_3)
	if not arg_7_0.enabled then
		return
	end

	arg_7_0.area:doRender(arg_7_1, arg_7_3)
end

function LogoTransitionHud.kick(arg_8_0, arg_8_1)
	arg_8_0:setEnabled(true)
	arg_8_0.wipeUI:kickWipe(arg_8_1 or arg_8_0.wipeType)

	local var_8_0 = var_0_1.switchGroup
	local var_8_1 = arg_8_1 and var_0_1.switchNames[arg_8_1] or var_0_1.switchNames[native.EWipeType.Default]

	arg_8_0.soundManager:setSwitchValue(var_8_0, var_8_1)

	arg_8_0.wipeStateSounds[var_0_2.Intro] = soundmap.screenWipeEventTypeMap[var_0_2.Intro]
	arg_8_0.wipeStateSounds[var_0_2.Outro] = soundmap.screenWipeEventTypeMap[var_0_2.Outro]
	arg_8_0.wipeType = native.EWipeType.Default
end

function LogoTransitionHud.readyToTransition(arg_9_0)
	return not arg_9_0.enabled or arg_9_0.wipeUI:readyToTransition() or var_0_0
end

function LogoTransitionHud.resetWipeType(arg_10_0)
	arg_10_0.wipeType = native.EWipeType.Default
end

function LogoTransitionHud.isFinished(arg_11_0)
	if arg_11_0.enabled then
		return arg_11_0.wipeUI:getIsFinished()
	else
		return true
	end
end

function LogoTransitionHud.setNextStateIsReady(arg_12_0)
	arg_12_0.wipeUI:setNextStateIsReady()
end

function LogoTransitionHud.processWipeStateSound(arg_13_0, arg_13_1, arg_13_2)
	local var_13_0 = arg_13_0.wipeStateSounds[arg_13_1]

	if var_13_0 then
		arg_13_2:playSound(var_13_0)

		arg_13_0.wipeStateSounds[arg_13_1] = nil
	end
end
