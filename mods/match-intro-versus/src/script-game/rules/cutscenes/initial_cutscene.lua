import("base.side.sidehelper")
import("intermediatelua.convant.stadiums")
import("core.foundation.tablex")
-- match-intro-versus
import("intermediatelua.cutscenes.data.cutscenedata_config")
import("app.noesis.ns")
import("app.noesis.ns_viewmodel")
import("app.noesis.util.nvm_team")

local var_0_0 = native.getEnvironment()

-- match-intro-versus: a broadcast-style opening for the match intro.
--
-- 1. The generic intro (home/away_is_kickoff_intro, with or without anthem) gets the stadium
--    establishing shots in IntroVersusEstablishingShots played back to back in front of it, in an
--    order picked from the match seed (each shot is only 3-4 s). One sequence copy is registered
--    per order, and getInitialCutsceneName picks one with matchInProgressData.matchSeed, so the
--    preload and the playback agree. Finals intros already open on rl1_stadium_wide_cam02 and
--    are left as they are.
-- 2. While the establishing shots play, the Views/TestScreens/TestScreen XAML (unused, build.py
--    can't add files) shows both crests flying in from the sides, VS in the middle and a venue /
--    kick-off bar under it. It animates out IntroVersusOutLead before the last one ends.
-- 3. Before every locker-room cutscene, the replay-team-stinger panel (TeamStinger in
--    base/transition/logotransition_hud.lua) sweeps in in the colours of the team in that locker
--    room, covers the cut, and sweeps off once the locker shot has started.
--
-- MatchIntroVersus is driven by TeamShieldRuleState (rules/cutscenes/teamshield_rulestate.lua,
-- owned by gf-tunnel-team-colour-lights): created in onEnterSolid, updated in updateSolid,
-- disposed in onExitSolid. Every call there is pcall'ed, so a failure loses the effect, never
-- the intro.
local IntroVersusDebug = false
local IntroVersusView = "Workspace/Views/TestScreens/TestScreen"
-- All share the cutsceneStadiumShots animset (only the first one of a sequence is preloaded).
local IntroVersusEstablishingShots = {
	"rl1_stadium_wide_cam02{StadiumName}",
	"rl1_stadium_crowd_away_cam04{StadiumName}",
	"rl1_stadium_crowd_home_cam07{StadiumName}"
}
-- Stock sequence -> whether it gets the establishing shots added in front.
local IntroVersusSequences = {
	home_is_kickoff_intro = true,
	away_is_kickoff_intro = true,
	home_is_kickoff_intro_anthem = true,
	away_is_kickoff_intro_anthem = true
}
-- Sequences that get the overlay and the locker stingers (prefixed copies included). The
-- Grand Final intro has its own spectacle (gf-intro-effects) and is left alone.
local IntroVersusOverlaySequences = {
	home_is_kickoff_intro = true,
	away_is_kickoff_intro = true,
	home_is_kickoff_intro_anthem = true,
	away_is_kickoff_intro_anthem = true,
	finals_intro = true,
	finals_intro_anthem = true
}
local IntroVersusSequencePrefix = "versus_"
-- The overlay's first cutscene must match one of these to show (resolved names, lower case).
local IntroVersusEstablishingPatterns = {
	"rl1_stadium_wide_cam02",
	"rl1_stadium_crowd_away_cam04",
	"rl1_stadium_crowd_home_cam07"
}
-- Seconds before the last establishing shot ends that the overlay starts leaving (the VersusOut
-- storyboard takes 0.5 s).
local IntroVersusOutLead = 1.1
-- Stinger kick lead before a cut into a locker room: TeamStingerCoverTime (0.5) + a little.
local IntroVersusStingerLead = 0.55
-- Seconds of the locker shot played under the stinger before it sweeps off.
local IntroVersusRevealDelay = 0.15
-- Kick-off labels for the stock time-of-day hours (script-config/design/timeofday_config.lua),
-- as the match settings menu (matchsetup_matchsetup_hub.lua) shows them.
local IntroVersusKickOffLabels = {
	[10] = "10:00AM",
	[13] = "2:00PM",
	[16] = "4:30PM",
	[18] = "7:00PM",
	[19] = "8:30PM"
}

local introVersusLogFile
local introVersusLogTried = false

-- Debug: IntroVersusDebug appends to matchintroversus_debug.txt (game folder, else
-- Saved Games\Rugby League 26) when the Lua io library is available.
function introVersusLog(arg_text)
	if not IntroVersusDebug then
		return
	end

	pcall(function()
		if not introVersusLogTried then
			introVersusLogTried = true

			if io and io.open then
				introVersusLogFile = io.open("matchintroversus_debug.txt", "a")

				if not introVersusLogFile and os and os.getenv and os.getenv("USERPROFILE") then
					introVersusLogFile = io.open(os.getenv("USERPROFILE") .. "/Saved Games/Rugby League 26/matchintroversus_debug.txt", "a")
				end
			end
		end

		if introVersusLogFile then
			introVersusLogFile:write(tostring(arg_text) .. "\n")
			introVersusLogFile:flush()
		end
	end)
end

-- Every order of IntroVersusEstablishingShots.
local function introVersusPermutations(arg_list)
	if #arg_list <= 1 then
		return {
			{
				arg_list[1]
			}
		}
	end

	local var_result = {}

	for iter_0 = 1, #arg_list do
		local var_rest = {}

		for iter_1 = 1, #arg_list do
			if iter_1 ~= iter_0 then
				table.insert(var_rest, arg_list[iter_1])
			end
		end

		for iter_2, iter_3 in ipairs(introVersusPermutations(var_rest)) do
			table.insert(iter_3, 1, arg_list[iter_0])
			table.insert(var_result, iter_3)
		end
	end

	return var_result
end

local IntroVersusOrders = introVersusPermutations(IntroVersusEstablishingShots)

-- Alternative sequence name -> the stock sequence it stands in for. Other mods publish
-- alternatives as cutscenedata_config.SequenceAlternatives = {stock = {{name, weight}, ...}}
-- (r25-imports' two-team run-out); they get the same establishing shots and overlay.
local IntroVersusAlternativeBase = {}

local function introVersusCollectAlternatives()
	for iter_base, iter_list in pairs(cutscenedata_config.SequenceAlternatives or {}) do
		for iter_0, iter_alt in ipairs(iter_list) do
			IntroVersusAlternativeBase[iter_alt.name] = iter_base
		end
	end
end

pcall(introVersusCollectAlternatives)

local function introVersusBase(arg_name)
	return IntroVersusAlternativeBase[arg_name] or arg_name
end

-- Registers one prefixed copy of each sequence per shot order: versus_<n>_<stock name>.
-- SequenceList is the same table CutsceneConfigLoader holds, so adding keys here is enough.
local function introVersusRegisterSequences()
	local var_sequences = cutscenedata_config.SequenceList

	if not var_sequences then
		introVersusLog("no SequenceList, sequences not added")

		return
	end

	local var_names = {}

	for iter_name, iter_enabled in pairs(IntroVersusSequences) do
		if iter_enabled then
			var_names[iter_name] = true
		end
	end

	for iter_alt, iter_base in pairs(IntroVersusAlternativeBase) do
		if IntroVersusSequences[iter_base] then
			var_names[iter_alt] = true
		end
	end

	for iter_name, iter_enabled in pairs(var_names) do
		local var_stock = var_sequences[iter_name]

		if iter_enabled and var_stock and var_stock.cutscenes then
			for iter_order, iter_shots in ipairs(IntroVersusOrders) do
				local var_cutscenes = {}

				for iter_0, iter_1 in ipairs(iter_shots) do
					table.insert(var_cutscenes, iter_1)
				end

				for iter_0, iter_1 in ipairs(var_stock.cutscenes) do
					table.insert(var_cutscenes, iter_1)
				end

				var_sequences[IntroVersusSequencePrefix .. iter_order .. "_" .. iter_name] = {
					cutscenes = var_cutscenes,
					lightingScenes = var_stock.lightingScenes
				}
			end
		end
	end
end

-- Shot order for this match, from the match seed (the same one the preload and the playback use).
local function introVersusOrderFor(arg_match)
	local var_seed = 0

	pcall(function()
		var_seed = arg_match:getComponent("matchInProgressData").matchSeed or 0
	end)

	if rawtype(var_seed) ~= "number" then
		var_seed = tonumber(tostring(var_seed)) or 0
	end

	return math.floor(math.abs(var_seed)) % math.max(#IntroVersusOrders, 1) + 1
end

-- The stock sequence or one of its SequenceAlternatives for this match: a weighted pick from the
-- match seed (bits above the ones introVersusOrderFor uses), so preload and playback agree.
local function introVersusAlternativeFor(arg_name, arg_match)
	local var_list = (cutscenedata_config.SequenceAlternatives or {})[arg_name]

	if not var_list or #var_list == 0 then
		return arg_name
	end

	local var_seed = 0

	pcall(function()
		var_seed = arg_match:getComponent("matchInProgressData").matchSeed or 0
	end)

	if rawtype(var_seed) ~= "number" then
		var_seed = tonumber(tostring(var_seed)) or 0
	end

	local var_total = 0

	for iter_0, iter_alt in ipairs(var_list) do
		var_total = var_total + math.max(iter_alt.weight or 0, 0)
	end

	if var_total <= 0 then
		return arg_name
	end

	local var_roll = math.floor(math.abs(var_seed) / math.max(#IntroVersusOrders, 1)) % var_total

	for iter_0, iter_alt in ipairs(var_list) do
		var_roll = var_roll - math.max(iter_alt.weight or 0, 0)

		if var_roll < 0 then
			if cutscenedata_config.SequenceList[iter_alt.name] then
				return iter_alt.name
			end

			break
		end
	end

	return arg_name
end

pcall(introVersusRegisterSequences)

local function var_0_1(arg_1_0)
	local var_1_0 = arg_1_0:getTimePeriodKickOffSide()

	if var_0_0:argExists("attackingSide") then
		if var_0_0:getArg("attackingSide") == "home" then
			var_1_0 = sidehelper.home
		else
			var_1_0 = sidehelper.away
		end
	end

	return var_1_0
end

function getInitialCutsceneName(arg_2_0, arg_2_1)
	local var_2_0 = arg_2_1:getComponent("matchInfo")
	local var_2_1 = arg_2_1:getComponent("matchInData")
	local var_2_2 = VERIFY(var_2_1.cutsceneInfo)
	local var_2_3 = arg_2_1.stateOfTheSeason
	local var_2_4 = var_2_2.playGFIntroCutscene or var_0_0:argExists("gfintro")
	local var_2_5 = var_2_2.playAnthem
	local var_2_6 = var_2_3.isFinal and not var_2_3.isGrandFinal or var_0_0:argExists("finalsintro")
	local var_2_7

	if var_2_4 then
		local var_2_8 = var_2_1.matchType.rules == native.MatchSettingsRules.superleague
		local var_2_9 = var_2_1.groundInfo.ground
		local var_2_10 = tablex.contains(stadiums.NRLIntroUnsafeStadiums, var_2_9)

		var_2_7 = (var_2_8 or var_2_10) and "gf_intro_SuperLeague" or "gf_intro_NRL"
		var_2_7 = arg_2_0.soundSystem:isAnthemAvailable() and var_2_7 or var_2_7 .. "_noanthem"
	elseif var_2_6 then
		var_2_7 = "finals_intro"

		if var_2_5 then
			var_2_7 = var_2_7 .. "_anthem" or var_2_7
		end
	else
		var_2_7 = var_0_1(var_2_0) ~= sidehelper.home and "away_is_kickoff_intro" or "home_is_kickoff_intro"
		var_2_7 = var_2_5 and var_2_7 .. "_anthem" or var_2_7
	end

	ASSERT(var_2_7)

	-- match-intro-versus: another mod's alternative for this sequence, if one is picked, then the
	-- copy with the establishing shots in front, when it was registered.
	local var_2_base = var_2_7

	var_2_7 = introVersusAlternativeFor(var_2_7, arg_2_1)

	local var_2_11 = cutscenedata_config.SequenceList
	local var_2_12 = IntroVersusSequencePrefix .. introVersusOrderFor(arg_2_1) .. "_" .. var_2_7

	if IntroVersusSequences[var_2_base] and var_2_11 and var_2_11[var_2_12] then
		var_2_7 = var_2_12
	end

	return var_2_7
end

function preloadInitialCutscene(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5)
	local var_3_0 = getInitialCutsceneName(arg_3_4, arg_3_3)

	arg_3_0:preloadCutsceneAssets(var_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5)
end

function updateLoadingPreloadedAssets(arg_4_0, arg_4_1)
	return arg_4_0:updateLoadingPreloadedAssets(arg_4_1)
end

-- match-intro-versus: overlay + locker stingers.

-- Cutscene times may be plain seconds or native Time values.
local function introVersusSeconds(arg_value)
	if rawtype(arg_value) == "number" then
		return arg_value
	end

	local var_ok, var_seconds = pcall(function()
		return arg_value:ToSeconds()
	end)

	return var_ok and rawtype(var_seconds) == "number" and var_seconds or nil
end

local function introVersusString(arg_value)
	if rawtype(arg_value) == "string" and arg_value ~= "" then
		return arg_value
	end

	return nil
end

local function introVersusUpper(arg_value)
	return arg_value and string.upper(arg_value) or ""
end

local function introVersusKickOffLabel(arg_hour)
	if rawtype(arg_hour) ~= "number" then
		return nil
	end

	local var_label = IntroVersusKickOffLabels[arg_hour]

	if var_label then
		return var_label
	end

	local var_minutes = math.floor(arg_hour * 60 + 0.5)
	local var_h = math.floor(var_minutes / 60) % 24
	local var_m = var_minutes % 60
	local var_suffix = var_h >= 12 and "PM" or "AM"
	local var_h12 = var_h % 12

	return string.format("%d:%02d%s", var_h12 == 0 and 12 or var_h12, var_m, var_suffix)
end

-- Venue name, city and kick-off time, each nil when unknown.
local function introVersusVenue(arg_matchInData)
	local var_groundInfo = arg_matchInData.groundInfo
	local var_name, var_city, var_time

	pcall(function()
		var_name = introVersusString(var_groundInfo.groundDisplayName)
	end)

	pcall(function()
		local var_key = tostring(var_groundInfo.ground)

		if not var_name then
			var_name = introVersusString(native.Localise(string.format("Ground_%s", var_key)))
		end

		local var_stadiumCfg = load("intermediatelua.visualconfig.stadium-cfg")
		local var_stadium = var_stadiumCfg and var_stadiumCfg.Stadiums and var_stadiumCfg.Stadiums[var_key]

		if var_stadium and var_stadium.locationEnum ~= nil then
			var_city = introVersusString(native.Localise(string.format("Location_%s", tostring(var_stadium.locationEnum))))
		end
	end)

	pcall(function()
		var_time = introVersusKickOffLabel(arg_matchInData.startTime)
	end)

	return var_name, var_city, var_time
end

local function introVersusMatches(arg_name, arg_patterns)
	local var_lower = string.lower(tostring(arg_name))

	for iter_0, iter_1 in ipairs(arg_patterns) do
		if string.find(var_lower, iter_1, 1, true) then
			return true
		end
	end

	return false
end

-- sidehelper side of a locker-room cutscene, or nil if it isn't one.
local function introVersusLockerSide(arg_name)
	local var_lower = string.lower(tostring(arg_name))

	if string.find(var_lower, "lockers_home", 1, true) then
		return sidehelper.home
	elseif string.find(var_lower, "lockers_away", 1, true) then
		return sidehelper.away
	end

	return nil
end

ns.Class("NVMMatchIntroVersus", ns_viewmodel.ViewModel, function(arg_v_0)
	ns_viewmodel.ViewModel.init(arg_v_0)

	arg_v_0.IntroState = "hidden"
	arg_v_0.HomeName = ""
	arg_v_0.AwayName = ""
	arg_v_0.VenueName = ""
	arg_v_0.VenueCity = ""
	arg_v_0.KickOffTime = ""
	arg_v_0.ShowDivider = false
end).Bindings = {
	Properties = {
		IntroState = ns.String,
		HomeTeam = ns.typeOf(nvm_team.NVMTeam),
		AwayTeam = ns.typeOf(nvm_team.NVMTeam),
		HomeName = ns.String,
		AwayName = ns.String,
		VenueName = ns.String,
		VenueCity = ns.String,
		KickOffTime = ns.String,
		ShowDivider = ns.Bool
	}
}

function NVMMatchIntroVersus.dispose(arg_v_0)
	-- HomeTeam/AwayTeam are the HUD's own NVMTeams: ViewModel.dispose would dispose them with us.
	arg_v_0.HomeTeam = nil
	arg_v_0.AwayTeam = nil

	ns_viewmodel.ViewModel.dispose(arg_v_0)
end

-- arg_1: engine, arg_2: rule-state services (hud, cutsceneListener), arg_3: matchInData,
-- arg_4: the intro sequence name.
Class("MatchIntroVersus", function(arg_m_0, arg_m_1, arg_m_2, arg_m_3, arg_m_4)
	arg_m_0.sequenceName = arg_m_4
	arg_m_0.hud = arg_m_2.hud
	arg_m_0.enabled = IntroVersusOverlaySequences[introVersusBase((string.gsub(tostring(arg_m_4), "^" .. IntroVersusSequencePrefix .. "%d+_", "")))] == true
	arg_m_0.cutscenesSeen = 0

	introVersusLog("intro " .. tostring(arg_m_4) .. (arg_m_0.enabled and "" or ", not handled"))

	if not arg_m_0.enabled then
		return
	end

	local var_vm = NVMMatchIntroVersus()
	local var_name, var_city, var_time = introVersusVenue(arg_m_3)

	var_vm.VenueName = introVersusUpper(var_name)
	var_vm.VenueCity = introVersusUpper(var_city)
	var_vm.KickOffTime = var_time and "KICK-OFF " .. var_time or ""
	var_vm.ShowDivider = var_city ~= nil and var_time ~= nil

	if arg_m_0.hud then
		var_vm.HomeTeam = arg_m_0.hud.homeTeamNVM
		var_vm.AwayTeam = arg_m_0.hud.awayTeamNVM
	end

	arg_m_0.viewModel = var_vm

	local var_ok, var_view = pcall(function()
		return arg_m_1:getNoesis():loadViewWithVM(IntroVersusView, var_vm, native.ENoesisViewManagerLayer.POST_SCENE, native.CNoesisViewManager.DefaultPriority)
	end)

	if var_ok and var_view then
		arg_m_0.view = var_view
	end

	introVersusLog("view " .. (arg_m_0.view and "loaded" or "FAILED: " .. tostring(var_view)) .. ", venue " .. tostring(var_name) .. " / " .. tostring(var_city) .. " / " .. tostring(var_time))
end)

function MatchIntroVersus.stinger(arg_m_0)
	local var_hud = arg_m_0.hud
	local var_logo = var_hud and var_hud.getElement and var_hud:getElement("logotransition")

	return var_logo and var_logo.teamStinger
end

function MatchIntroVersus.teamFor(arg_m_0, arg_side)
	local var_hud = arg_m_0.hud

	if not var_hud then
		return nil
	end

	if arg_side == sidehelper.home then
		return var_hud.homeTeamNVM
	elseif arg_side == sidehelper.away then
		return var_hud.awayTeamNVM
	end

	return nil
end

-- The queued cutscene after arg_cutscene, from the listener's queue.
function MatchIntroVersus.nextCutscene(arg_m_0, arg_listener, arg_cutscene)
	local var_queue = arg_listener.cutsceneQueue or {}

	for iter_0, iter_1 in ipairs(var_queue) do
		if iter_1 == arg_cutscene or iter_1.id == arg_cutscene.id then
			return var_queue[iter_0 + 1]
		end
	end

	return nil
end

-- Team names come from the HUD's NVMTeams, which may still be filling in on the first frames.
function MatchIntroVersus.updateNames(arg_m_0)
	local var_vm = arg_m_0.viewModel
	local var_hud = arg_m_0.hud

	if not var_vm or not var_hud then
		return
	end

	local var_home = var_hud.homeTeamNVM and introVersusString(var_hud.homeTeamNVM.FullName)
	local var_away = var_hud.awayTeamNVM and introVersusString(var_hud.awayTeamNVM.FullName)

	if var_home and var_vm.HomeName ~= string.upper(var_home) then
		var_vm.HomeName = string.upper(var_home)
	end

	if var_away and var_vm.AwayName ~= string.upper(var_away) then
		var_vm.AwayName = string.upper(var_away)
	end
end

function MatchIntroVersus.setState(arg_m_0, arg_state)
	if arg_m_0.viewModel and arg_m_0.viewModel.IntroState ~= arg_state then
		arg_m_0.viewModel.IntroState = arg_state

		introVersusLog("overlay " .. arg_state)
	end
end

function MatchIntroVersus.onCutsceneStarted(arg_m_0, arg_cutscene)
	arg_m_0.cutscenesSeen = arg_m_0.cutscenesSeen + 1
	arg_m_0.armedCutscene = nil
	arg_m_0.stingerKickedFor = nil

	local var_name = arg_cutscene and arg_cutscene.name

	introVersusLog(string.format("cutscene %d: %s (%s)", arg_m_0.cutscenesSeen, tostring(var_name), tostring(arg_cutscene and introVersusSeconds(arg_cutscene.duration))))

	if arg_m_0.cutscenesSeen == 1 and var_name and introVersusMatches(var_name, IntroVersusEstablishingPatterns) then
		arg_m_0.versusShowing = true

		arg_m_0:updateNames()
		arg_m_0:setState("in")
	elseif arg_m_0.versusShowing and not (var_name and introVersusMatches(var_name, IntroVersusEstablishingPatterns)) then
		arg_m_0.versusShowing = false

		arg_m_0:setState("out")
	end
end

function MatchIntroVersus.update(arg_m_0, arg_m_1)
	if not arg_m_0.enabled then
		return
	end

	local var_listener = arg_m_1 and arg_m_1.cutsceneListener
	local var_cutscene = var_listener and var_listener.currentCutscene

	if var_cutscene ~= arg_m_0.currentCutscene then
		arg_m_0.currentCutscene = var_cutscene

		if var_cutscene then
			arg_m_0:onCutsceneStarted(var_cutscene)
		end
	end

	if not var_cutscene then
		return
	end

	local var_duration = introVersusSeconds(var_cutscene.duration)
	local var_time = introVersusSeconds(var_cutscene.time)

	if not var_duration or not var_time then
		if not arg_m_0.loggedNoTime then
			arg_m_0.loggedNoTime = true

			introVersusLog("cutscene " .. tostring(var_cutscene.name) .. " has no usable time: duration " .. rawtype(var_cutscene.duration) .. ", time " .. rawtype(var_cutscene.time))
		end

		return
	end

	local var_remaining = var_duration - var_time

	if arg_m_0.versusShowing then
		arg_m_0:updateNames()

		-- Stays up across back-to-back establishing shots; leaves before the last one ends.
		local var_next = arg_m_0:nextCutscene(var_listener, var_cutscene)
		local var_lastShot = not (var_next and introVersusMatches(var_next.name, IntroVersusEstablishingPatterns))

		if var_lastShot and var_remaining <= IntroVersusOutLead then
			arg_m_0.versusShowing = false

			arg_m_0:setState("out")
		end
	end

	-- Sweep the stinger off once the locker shot it covered has started playing.
	if arg_m_0.revealPending and arg_m_0.revealAfter ~= var_cutscene and var_time >= IntroVersusRevealDelay then
		arg_m_0.revealPending = false

		local var_stinger = arg_m_0:stinger()

		if var_stinger then
			introVersusLog("stinger release into " .. tostring(var_cutscene.name))
			var_stinger:release()
		end
	end

	-- A cutscene only counts once it's been seen with more than the lead left, so a finished
	-- one still sitting in currentCutscene can't kick early.
	if arg_m_0.stingerKickedFor == var_cutscene then
		return
	end

	if arg_m_0.armedCutscene ~= var_cutscene then
		if var_remaining > IntroVersusStingerLead then
			arg_m_0.armedCutscene = var_cutscene
		end

		return
	end

	if var_remaining > IntroVersusStingerLead then
		return
	end

	arg_m_0.stingerKickedFor = var_cutscene

	local var_next = arg_m_0:nextCutscene(var_listener, var_cutscene)
	local var_side = var_next and introVersusLockerSide(var_next.name)
	local var_team = var_side and arg_m_0:teamFor(var_side)

	if not var_team then
		return
	end

	local var_stinger = arg_m_0:stinger()

	if var_stinger and var_stinger:kickOutro(var_team) then
		arg_m_0.revealPending = true
		arg_m_0.revealAfter = var_cutscene

		introVersusLog(string.format("stinger kick for %s, %.2fs before %s", tostring(var_team.FullName), var_remaining, tostring(var_next.name)))
	else
		introVersusLog("stinger unavailable or busy before " .. tostring(var_next.name))
	end
end

function MatchIntroVersus.dispose(arg_m_0)
	-- A skipped intro can leave the stinger covering the screen.
	if arg_m_0.revealPending then
		arg_m_0.revealPending = false

		local var_stinger = arg_m_0:stinger()

		if var_stinger then
			pcall(var_stinger.release, var_stinger)
		end
	end

	if arg_m_0.view then
		arg_m_0.view:release()

		arg_m_0.view = nil
	end

	if arg_m_0.viewModel then
		arg_m_0.viewModel:dispose()

		arg_m_0.viewModel = nil
	end

	introVersusLog("disposed")
end
