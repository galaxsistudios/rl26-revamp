import("app.casual.casual_newmatch_begin")
import("app.casual.casual_newmatch_controllerselect")
import("app.casual.casual_newmatch_matchsetup")
import("app.match.match_scenecontroller")
import("app.match.matchin")
import("app.match.matchin_refereeuniform")
import("app.match.matchsetup_aide")
import("app.match.matchsetup_lockdown")
import("app.match.matchsetupmatchsettings_state")
import("app.network.matchsettingssynchroniser")
import("app.uiinput.input_gamepad_helper")
import("base.ui.optionmenu.optionmenu_aide")
import("core.foundation.tablex")
import("core.statemachine.statemachine")

-- choose-play-now-referee: Play Now's Match Settings screen gets a "Match Officials" button
-- that swaps the settings panel to its own page (Back returns): Referee, Touch Judge 1,
-- Touch Judge 2 and Referee Jersey.
-- The officials go in localMatchSettings.refereeIds (slot 1 = EOfficialRole.Referee, 2..3 =
-- TouchJudge), which matchin.setupReferees uses instead of rolling random officials, and which
-- matchsetup_aide.saveSettingsForFutureMatches stores in the profile's casualReferees*.
-- The jersey goes in localMatchSettings.modRefereeUniform (EUmpireUniform int, nil = Auto) and
-- replaces matchin_refereeuniform.determineUniformType's pick while setupLobbyMatch runs. The
-- profile has no field for it, so it is only remembered for the session (in _G).
-- Extra kits from other mods (_G.MOD_EXTRA_REFEREE_KITS, e.g. nrl-referee-2026-kits: {guid,
-- label, base}) are listed after the stock ones as MOD_EXTRA_UNIFORM_BASE + their index: the
-- base stock kit is picked, then every official's uniformTop is set to the kit's guid.
local MOD_REFEREE_COUNT = native.CGameConfig.MAX_UMPIRES
local MOD_EXTRA_UNIFORM_BASE = 1000
local MOD_OFFICIAL_LABELS = {
	"Referee",
	"Touch Judge 1",
	"Touch Judge 2"
}
local MOD_PAGE_HEADING = "Match Officials"
local MOD_SESSION_UNIFORM_KEY = "modPlayNowRefereeUniform"
local MOD_UNIFORM_PREFIXES = {
	NRL = "NRL",
	SL = "Super League",
	SOO = "State of Origin",
	RLWC = "World Cup",
	Default = "Generic"
}

local function modLog(fmt, ...)
	pcall(function(...)
		local file = io.open("playnow_officials_debug.txt", "a")

		if file then
			file:write(os.date("%H:%M:%S "), string.format(fmt, ...), "\n")
			file:flush()
			file:close()
		end
	end, ...)
end

local function modRefereeSex(sex)
	return sex or native.CSex.Male
end

-- Women's matches can be refereed by either sex: the game only ships two female referees
-- (fewer than MAX_UMPIRES), and stock matchin always rolls male officials anyway.
local function modPoolSexes(sex)
	if sex == native.CSex.Female then
		return {
			native.CSex.Female,
			native.CSex.Male
		}
	end

	return {
		native.CSex.Male
	}
end

-- Every referee id available for a match of this sex, found per sex by stepping
-- getRelativeNPCIdOfType from a random start until it wraps.
local function modListRefereeIds(refereeManager, sex)
	local ids = {}
	local seen = {}

	for _, poolSex in ipairs(modPoolSexes(sex)) do
		local first = refereeManager:getRandomIdsOfType(native.Random.FromSystemTime(), 1, native.CNpcType.Referee, poolSex)
		local id = first and first[1]

		for _ = 1, 2000 do
			if id == nil or seen[tostring(id)] then
				break
			end

			seen[tostring(id)] = true

			table.insert(ids, id)

			id = refereeManager:getRelativeNPCIdOfType(id, native.CNpcType.Referee, poolSex, 1)
		end
	end

	return ids, seen
end

local function modSavedRefereeId(settings, sex, slot)
	if sex == native.CSex.Male then
		if settings.casualRefereesMale_count >= slot then
			return settings:casualRefereesMale_get(slot)
		end
	elseif settings.casualRefereesFemale_count >= slot then
		return settings:casualRefereesFemale_get(slot)
	end

	return nil
end

-- Slot by slot: the profile's saved official if they still exist and aren't already used,
-- otherwise a random one.
local function modInitialRefereeIds(app, settings, sex)
	local refereeManager = app:getRefereeManager()
	local random = native.Random.FromSystemTime()
	local randomIds = refereeManager:getRandomIdsOfType(random, MOD_REFEREE_COUNT, native.CNpcType.Referee, native.CSex.Male)

	if not randomIds or #randomIds < MOD_REFEREE_COUNT then
		return nil
	end

	-- women's match: a female referee in the middle when there is one, male touch judges
	if sex == native.CSex.Female then
		local femaleIds = refereeManager:getRandomIdsOfType(random, 1, native.CNpcType.Referee, native.CSex.Female)

		if femaleIds and femaleIds[1] then
			table.insert(randomIds, 1, femaleIds[1])
			table.remove(randomIds)
		end
	end

	local _, validIds = modListRefereeIds(refereeManager, sex)
	local ids = {}
	local used = {}

	for slot = 1, MOD_REFEREE_COUNT do
		local savedId = modSavedRefereeId(settings, sex, slot)

		if savedId ~= nil and validIds[tostring(savedId)] and not used[tostring(savedId)] then
			ids[slot] = savedId
			used[tostring(savedId)] = true
		end
	end

	for slot = 1, MOD_REFEREE_COUNT do
		if ids[slot] == nil then
			for _, id in ipairs(randomIds) do
				if not used[tostring(id)] then
					ids[slot] = id
					used[tostring(id)] = true

					break
				end
			end
		end
	end

	return ids
end

local function modValueListIndex(list, value)
	for index, entry in ipairs(list) do
		if tostring(entry.value) == tostring(value) then
			return index - 1
		end
	end

	return 0
end

local function modToIndex(index)
	if type(index) ~= "number" then
		index = index:toInt()
	end

	return index
end

local function modRefereeValueList(app, matchData)
	local refereeManager = app:getRefereeManager()
	local valueList = {}

	for _, id in ipairs((modListRefereeIds(refereeManager, modRefereeSex(matchData.sex)))) do
		local referee = refereeManager:getReferee(id)

		if referee then
			table.insert(valueList, {
				value = id,
				label = tostring(referee.fullName)
			})
		end
	end

	table.sort(valueList, function(a, b)
		return a.label < b.label
	end)

	return valueList
end

-- The page's rows remember their NVMOptionSelector (set after populateMenu) so a swap can
-- update the other row's shown name.
local function modShowSlotValue(items, slot, value)
	local item = items[slot]
	local selector = item and item.modSelector

	if selector then
		pcall(function()
			selector.SelectedFocusOption = modValueListIndex(item.valueList, value)
		end)
	end
end

local function modCreateOfficialItem(items, valueList, refereeIds, slot)
	return {
		key = MOD_OFFICIAL_LABELS[slot],
		label = MOD_OFFICIAL_LABELS[slot],
		editable = true,
		editType = optionmenu_aide.EditTypes.ValueList,
		displayType = optionmenu_aide.DisplayTypes.ValueList,
		tooltip = native.InputTypes.LJoyLeftRight,
		tooltipText = native.Localise("Select"),
		valueList = valueList,
		getValue = function(list)
			return modValueListIndex(list, refereeIds[slot])
		end,
		setValue = function(index, list)
			local entry = list[modToIndex(index) + 1]

			if not entry or tostring(entry.value) == tostring(refereeIds[slot]) then
				return
			end

			local previousId = refereeIds[slot]

			-- keep the officials distinct: whoever already had this official takes the old one
			for otherSlot = 1, #refereeIds do
				if otherSlot ~= slot and tostring(refereeIds[otherSlot]) == tostring(entry.value) then
					refereeIds[otherSlot] = previousId

					modShowSlotValue(items, otherSlot, previousId)
				end
			end

			refereeIds[slot] = entry.value
		end
	}
end

local function modUniformLabel(name)
	local prefix, colour = name:match("^(.-)_(.+)$")

	if not prefix then
		return name
	end

	return string.format("%s %s", MOD_UNIFORM_PREFIXES[prefix] or prefix, colour)
end

local function modHasUniformVisual(name)
	local ok, visual = pcall(function()
		return native.DefaultTeamVisuals[string.format("RefereeMale_%s", name)]
	end)

	return ok and visual ~= nil
end

local function modExtraUniform(value)
	local kits = rawget(_G, "MOD_EXTRA_REFEREE_KITS")

	return value and kits and kits[value - MOD_EXTRA_UNIFORM_BASE] or nil
end

local function modCreateUniformItem(localMatchSettings)
	local valueList = {
		{
			value = -1,
			label = "Auto"
		}
	}

	for index = 0, native.EUmpireUniform.Count - 1 do
		local name = tostring(native.EUmpireUniform:fromInt(index))

		if modHasUniformVisual(name) then
			table.insert(valueList, {
				value = index,
				label = modUniformLabel(name)
			})
		end
	end

	for index, kit in ipairs(rawget(_G, "MOD_EXTRA_REFEREE_KITS") or {}) do
		if modHasUniformVisual(kit.base) then
			table.insert(valueList, {
				value = MOD_EXTRA_UNIFORM_BASE + index,
				label = kit.label
			})
		end
	end

	return {
		key = "RefereeJersey",
		label = "Referee Jersey",
		editable = true,
		editType = optionmenu_aide.EditTypes.ValueList,
		displayType = optionmenu_aide.DisplayTypes.ValueList,
		tooltip = native.InputTypes.LJoyLeftRight,
		tooltipText = native.Localise("Select"),
		valueList = valueList,
		getValue = function(list)
			return modValueListIndex(list, localMatchSettings.modRefereeUniform or -1)
		end,
		setValue = function(index, list)
			local entry = list[modToIndex(index) + 1]

			if not entry then
				return
			end

			local uniform = entry.value >= 0 and entry.value or nil

			localMatchSettings.modRefereeUniform = uniform

			modLog("jersey picked: %s (%s)", tostring(uniform), tostring(entry.label))

			rawset(_G, MOD_SESSION_UNIFORM_KEY, uniform)
		end
	}
end

local function modCreateOfficialsItems(app, matchData)
	local localMatchSettings = matchData.localMatchSettings
	local refereeIds = localMatchSettings.refereeIds
	local valueList = modRefereeValueList(app, matchData)
	local items = {}

	if #valueList >= #refereeIds then
		for slot = 1, #refereeIds do
			table.insert(items, modCreateOfficialItem(items, valueList, refereeIds, slot))
		end
	end

	table.insert(items, modCreateUniformItem(localMatchSettings))

	return items
end

-- Pages swap in place on the live option menu, as the stock refreshMenuItems does. Reloading
-- paPreMatchSettingsView with the same view model showed an empty panel in game, and a fresh
-- view model (stock reconstruct) re-runs setGrounds, which resets the picked stadium.
local function modShowPage(state, synchroniser, items, heading)
	local optionMenu = state.menuViewModel.OptionMenuNVM

	optionMenu:populateMenu(items, synchroniser)

	optionMenu.HeadingText = heading

	for _, item in ipairs(items) do
		item.modSelector = nil
	end

	local linked = 0
	local ok, err = pcall(function()
		local position = 0

		for _, component in optionMenu.OptionCollection:iter() do
			position = position + 1

			if items[position] then
				items[position].modSelector = component
				linked = linked + 1
			end
		end
	end)

	modLog("page '%s': %d rows, %d linked%s", heading, #items, linked, ok and "" or " (iter failed: " .. tostring(err) .. ")")
end

local function modCreateOfficialsButton(state)
	return {
		key = "MatchOfficials",
		label = MOD_PAGE_HEADING,
		editable = true,
		selectSelectsItem = true,
		editType = optionmenu_aide.EditTypes.Button,
		displayType = optionmenu_aide.DisplayTypes.Button,
		tooltip = native.InputTypes.Accept,
		tooltipText = native.Localise("Select"),
		-- runs inside the button's Noesis command, so the view swap waits for the next update
		execute = function()
			modLog("officials button pressed")

			state.modPendingPage = "officials"

			return true
		end
	}
end

-- matchsetupmatchsettings_state.lua is already overridden by enable-casual-fieldmarkings,
-- so the button and page are added by wrapping its class methods here instead. Its own
-- referee rows use a display type the Noesis menu can't render and are locked in public
-- builds, so refereeIds is hidden from the stock code while it runs. A wrapper is only
-- replaced when the current method isn't ours (the module is re-imported after a match).
local modSettingsState = matchsetupmatchsettings_state.MatchSetupMatchSettingsState

if modSettingsState.createMenuItems ~= modSettingsState.modWrappedCreateMenuItems then
	modSettingsState.modStockCreateMenuItems = modSettingsState.createMenuItems
end

if modSettingsState.update ~= modSettingsState.modWrappedUpdate then
	modSettingsState.modStockUpdate = modSettingsState.update
end

function modSettingsState.modWrappedCreateMenuItems(arg_0_0, arg_0_1, arg_0_2, arg_0_3, arg_0_4, arg_0_5, arg_0_6, ...)
	local stockCreateMenuItems = modSettingsState.modStockCreateMenuItems
	local localMatchSettings = arg_0_6 and arg_0_6.isCasual and arg_0_6.localMatchSettings
	local refereeIds = localMatchSettings and localMatchSettings.refereeIds

	if not refereeIds then
		return stockCreateMenuItems(arg_0_0, arg_0_1, arg_0_2, arg_0_3, arg_0_4, arg_0_5, arg_0_6, ...)
	end

	localMatchSettings.refereeIds = nil

	local ok, menuItems, extra = pcall(stockCreateMenuItems, arg_0_0, arg_0_1, arg_0_2, arg_0_3, arg_0_4, arg_0_5, arg_0_6, ...)

	localMatchSettings.refereeIds = refereeIds

	if not ok then
		error(menuItems, 0)
	end

	arg_0_0.modOfficialsItems = modCreateOfficialsItems(arg_0_5, arg_0_6)

	-- the button goes after Manage Lineup when that row is there
	local position = #menuItems + 1
	local lineupLabel = native.Localise("MatchSettingsManageLineup")

	for index, item in ipairs(menuItems) do
		if item.label == lineupLabel then
			position = index + 1

			break
		end
	end

	table.insert(menuItems, position, modCreateOfficialsButton(arg_0_0))

	modLog("settings menu built: %d rows, officials button at %d, %d officials rows", #menuItems, position, #arg_0_0.modOfficialsItems)

	return menuItems, extra
end

-- update(self, sm, engine, time, dt, ?, uiServices, ?, metagameModeData, matchData, matchSetupData).
-- While the officials page is up this replaces the stock update: Back returns to the
-- settings rows instead of leaving the screen.
function modSettingsState.modWrappedUpdate(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7, arg_1_8, arg_1_9, ...)
	if arg_1_0.exitAt or arg_1_0.subState or not arg_1_0.modPage and not arg_1_0.modPendingPage then
		return modSettingsState.modStockUpdate(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7, arg_1_8, arg_1_9, ...)
	end

	local synchroniser = arg_1_9.matchSettingsSynchroniser

	if arg_1_0.modPendingPage then
		local page = arg_1_0.modPendingPage

		arg_1_0.modPendingPage = nil

		local ok, err

		arg_1_0.modPage = nil

		if page == "officials" and arg_1_0.modOfficialsItems then
			ok, err = pcall(modShowPage, arg_1_0, synchroniser, arg_1_0.modOfficialsItems, MOD_PAGE_HEADING)
			arg_1_0.modPage = ok and page or nil
		end

		if not arg_1_0.modPage then
			if err then
				modLog("officials page failed: %s", tostring(err))
			end

			ok, err = pcall(modShowPage, arg_1_0, synchroniser, arg_1_0.menuItems, native.Localise("MatchSettings"))

			if not ok then
				modLog("settings page failed: %s", tostring(err))
			end
		end

		arg_1_0.allowInputAfter = arg_1_3 + 0.2

		return
	end

	arg_1_0.menuViewModel:update(arg_1_2, arg_1_4)

	if arg_1_6:updateBlockingMixins(arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_7) then
		return
	end

	local optionMenu = arg_1_0.menuViewModel.OptionMenuNVM

	if optionMenu.toolTip and optionMenu.toolTipText then
		arg_1_6:addTooltip(nil, optionMenu.toolTip, native.Localise(optionMenu.toolTipText), 1)
	end

	arg_1_6:addTooltip(nil, native.InputTypes.Decline, native.Localise("Back"), 20)

	if arg_1_3 < arg_1_0.allowInputAfter or not arg_1_6:getInputAllowed() then
		return
	end

	if arg_1_6:checkForRelease(arg_1_2:getParty(), native.InputTypes.Decline) then
		arg_1_6:playSound("Back")

		arg_1_0.modPendingPage = "settings"
	end
end

modSettingsState.createMenuItems = modSettingsState.modWrappedCreateMenuItems
modSettingsState.update = modSettingsState.modWrappedUpdate

-- Referee jersey: while setupLobbyMatch runs for a Play Now match with a picked jersey,
-- determineUniformType (called from matchin.finalise) returns that jersey.
local modForcedUniform

if matchin_refereeuniform.determineUniformType ~= matchin_refereeuniform.modWrappedDetermineUniformType then
	matchin_refereeuniform.modStockDetermineUniformType = matchin_refereeuniform.determineUniformType
end

function matchin_refereeuniform.modWrappedDetermineUniformType(...)
	local extra = modExtraUniform(modForcedUniform)

	local uniform

	if extra then
		uniform = native.EUmpireUniform[extra.base]
	elseif modForcedUniform ~= nil then
		uniform = native.EUmpireUniform:fromInt(modForcedUniform)
	else
		uniform = matchin_refereeuniform.modStockDetermineUniformType(...)
	end

	modLog("determineUniformType: forced %s -> %s", tostring(modForcedUniform), tostring(uniform))

	return uniform
end

matchin_refereeuniform.determineUniformType = matchin_refereeuniform.modWrappedDetermineUniformType

if matchin.setupLobbyMatch ~= matchin.modWrappedSetupLobbyMatch then
	matchin.modStockSetupLobbyMatch = matchin.setupLobbyMatch
end

-- setupLobbyMatch's 8th argument is the match's localMatchSettings
function matchin.modWrappedSetupLobbyMatch(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, ...)
	local ok, uniform = pcall(function()
		return arg_2_7.modRefereeUniform
	end)

	modForcedUniform = ok and uniform or nil

	modLog("setupLobbyMatch: jersey %s (read ok %s)", tostring(modForcedUniform), tostring(ok))

	local results = {
		pcall(matchin.modStockSetupLobbyMatch, arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, ...)
	}

	local extra = modExtraUniform(modForcedUniform)

	modForcedUniform = nil

	if not results[1] then
		error(results[2], 0)
	end

	-- an extra kit: finalise dressed the officials in its base kit, swap the jersey design
	local okUmpires, err = pcall(function()
		local umpires = arg_2_0.umpireConfig

		for index = 1, umpires:getUmpireCount() do
			-- an umpire's uniform is the team visual config itself (matchin copies into it),
			-- unlike a club uniform, which wraps one in .config
			local config = umpires:getUmpire(index).uniform
			local before = config:getOption("uniformTop")

			if extra then
				config:setOption("uniformTop", extra.guid)
			end

			modLog("official %d: uniformTop %s -> %s", index, tostring(before), tostring(umpires:getUmpire(index).uniform:getOption("uniformTop")))
		end
	end)

	if not okUmpires then
		modLog("officials' uniforms failed: %s", tostring(err))
	end

	return unpack(results, 2)
end

matchin.setupLobbyMatch = matchin.modWrappedSetupLobbyMatch

Class("CasualNewState")

function CasualNewState.enter(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7)
	local var_1_0 = VERIFY(arg_1_6.partyMember)
	local var_1_1 = var_1_0.settings

	arg_1_5:sceneObjectPlayAnim("teamBoxes", "hold_rightSource", false, true, 1)
	arg_1_5:sceneObjectSetVisible("teamBoxes", true)

	local var_1_2 = arg_1_5:getPlayerManager()
	local var_1_3 = arg_1_5:getDecalManager()
	local var_1_4 = arg_1_5:getLevelManager()
	local var_1_5 = matchsettingssynchroniser.MatchSettingsSynchroniser(arg_1_2, var_1_0, var_1_3, var_1_4, var_1_2)

	arg_1_0.matchSettingsSynchroniser = var_1_5

	arg_1_0:validateCasualSettings(arg_1_2, arg_1_5, var_1_0)
	var_1_1.casualSettings:generateMatchIdentifiers()
	var_1_5:setMatchSettings(var_1_1.casualSettings)

	if not var_1_1.casualSettings.matchType:isIntialised() then
		local var_1_6 = arg_1_5:getMatchTypeManager():getMatchType(8)

		var_1_5:setMatchType(var_1_6)
	end

	local var_1_7 = {}
	local var_1_8 = 1

	var_1_5:addPartyMember(arg_1_6.partyMember, "home", var_1_8)

	var_1_7[var_1_8] = arg_1_6.partyMember.uniqueId

	local var_1_9 = native.CMatchObjectives()
	local var_1_10 = {}
	local var_1_11 = arg_1_7.isGrandFinal

	var_1_10.trophyId = var_1_11 and arg_1_7.trophyId
	var_1_10.refereeIds = modInitialRefereeIds(arg_1_5, var_1_1, modRefereeSex(arg_1_7.sex))
	var_1_10.modRefereeUniform = rawget(_G, MOD_SESSION_UNIFORM_KEY)

	if var_1_11 and arg_1_7.ground then
		local var_1_12 = var_1_5:getMatchSettings()

		var_1_12.ground = arg_1_7.ground

		var_1_5:setMatchSettings(var_1_12)
	end

	local var_1_13 = false

	if var_1_11 then
		local var_1_14 = arg_1_7.matchTypeId

		if var_1_14 then
			local var_1_15 = arg_1_5:getMatchTypeManager():getMatchType(var_1_14)

			var_1_5:setMatchType(var_1_15)

			var_1_13 = true
		end

		local var_1_16 = arg_1_7.matchSettingsOverrides

		if var_1_16 then
			local var_1_17 = var_1_5:getMatchSettings()

			for iter_1_0, iter_1_1 in pairs(var_1_16) do
				if var_1_17[iter_1_0] then
					var_1_17[iter_1_0] = iter_1_1
				end
			end

			var_1_5:setMatchSettings(var_1_17)
		end
	end

	local var_1_18 = casual_newmatch_controllerselect.CasualControllerSelectState
	local var_1_19 = {
		ControllerSelection = var_1_18,
		MatchSetup = casual_newmatch_matchsetup.CasualMatchSetupState,
		Lockdown = matchsetup_lockdown.MatchSetupLockdown
	}
	local var_1_20 = statemachine.StateMachine(arg_1_0.__type)

	arg_1_0.stateMachine = var_1_20

	local var_1_21 = {
		allowedToChangeUniform = true,
		allowedToChangeLineup = true,
		isCasual = true,
		allowedToChangeClub = true,
		allowedToChangeSettings = true,
		callstack = native.getLuaCallstack(),
		isBeAPro = arg_1_7.beAPro,
		usingLineupScreen = GAME_CRICKET,
		matchSettingsSynchroniser = var_1_5,
		matchObjectives = var_1_9,
		sceneController = match_scenecontroller.MatchSceneController(),
		controllerSlotToPartyMemberUniqueId = var_1_7,
		stateFactoryMap = var_1_19,
		fixedClubs = arg_1_7.fixedClubs,
		getAutoProgress = falseFn,
		disableInput = falseFn,
		beginMatch = casual_newmatch_begin.beginMatch,
		enterLockdownAfterControllerSetup = arg_1_7.enterLockdownAfterControllerSetup,
		settingRestrictions = arg_1_7.settingRestrictions,
		sex = arg_1_7.sex,
		lineupCategory = arg_1_7.lineupCategory,
		settingsInfo = arg_1_7.settingsInfo,
		clubInfoMap = arg_1_7.clubInfoMap,
		usingOffensiveRef = arg_1_7.usingOffensiveRef,
		canSelectLineupFromList = not GAME_RUGBY,
		usingFeederClubs = GAME_RUGBY,
		localMatchSettings = var_1_10,
		exitMatch = function(arg_2_0)
			var_1_20:changeState(nil, arg_1_2, arg_2_0, arg_1_4, arg_1_5, arg_1_6)
		end,
		matchTypeSet = var_1_13,
		isGrandFinal = arg_1_7.isGrandFinal or false
	}

	local function var_1_22(arg_3_0)
		var_1_20:changeState(var_1_18(), arg_1_2, arg_3_0, arg_1_4, arg_1_5, arg_1_6, var_1_21)
	end

	function var_1_21.returnToTop(arg_4_0)
		var_1_22(arg_4_0)
	end

	function var_1_21.saveMatchSettingsToPartyMember()
		matchsetup_aide.saveSettingsForFutureMatches(arg_1_2, arg_1_5, var_1_0, var_1_21)
	end

	arg_1_0.matchData = var_1_21

	var_1_22(arg_1_3)
end

function CasualNewState.update(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8, arg_6_9)
	local var_6_0 = arg_6_0.matchData
	local var_6_1 = var_6_0.matchSettingsSynchroniser

	var_6_1:update(arg_6_2, arg_6_4)

	local var_6_2 = arg_6_2:getParty()
	local var_6_3 = arg_6_2:getGameControlManager()
	local var_6_4 = input_gamepad_helper.hasPartyMemberInMatchDisconnected(var_6_3, var_6_2, var_6_1)
	local var_6_5 = arg_6_1:getCurrentState()
	local var_6_6 = var_6_5 and var_6_5.stateMachine.currentState and var_6_5.stateMachine.currentState.__type == "CasualControllerSelectState"

	if var_6_4 and var_6_4 ~= var_6_1.primaryPartyMember and not var_6_6 then
		arg_6_0:removePartyMember(var_6_4)
		var_6_1:setClubSelectionMade("home", false)
		var_6_1:setClubSelectionMade("away", false)
		var_6_1:setJerseySelectionMade("home", false)
		var_6_1:setJerseySelectionMade("away", false)
		var_6_0.returnToTop(arg_6_3)
	end

	if arg_6_0.soloGameTask then
		arg_6_0.soloGameTask:update(arg_6_4)

		if arg_6_0.soloGameTask:isComplete() then
			local var_6_7 = arg_6_0.soloGameTask:getStatus()

			if var_6_7 ~= native.ETaskStatus.success then
				print("Solo game task failed, err:" .. tostring(arg_6_0.soloGameTask:getLastError()))
			else
				print("Solo game task completed with status: " .. tostring(var_6_7))
			end

			arg_6_0.soloGameTask = nil
		end
	end

	if var_6_5 and var_6_5.stateMachine:getCurrentState() then
		arg_6_0.stateMachine:update(arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8, var_6_0)
	else
		arg_6_6:homeScreenEnter(arg_6_2, arg_6_3, arg_6_5, arg_6_6, arg_6_8.partyMember, true)
	end
end

function CasualNewState.render(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4)
	arg_7_0.stateMachine:render(arg_7_1, arg_7_2, arg_7_3, arg_7_4)
end

function CasualNewState.exit(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4)
	local var_8_0 = arg_8_0.matchData

	if not arg_8_0.enteringGame then
		if arg_8_0.soloGameTask then
			arg_8_0.soloGameTask:cancel()
			arg_8_0.soloGameTask:dispose()

			arg_8_0.soloGameTask = nil
		end

		arg_8_1:getNetworkService():closeAllSessions()
	end

	var_8_0.matchSettingsSynchroniser:dispose()
	arg_8_0.stateMachine:changeState(nil, arg_8_1, arg_8_2, arg_8_3, arg_8_4)
end

function CasualNewState.removePartyMember(arg_9_0, arg_9_1)
	local var_9_0 = arg_9_0.matchData
	local var_9_1 = var_9_0.matchSettingsSynchroniser
	local var_9_2 = var_9_1:getPartyMember(arg_9_1)

	if var_9_2.localSide ~= "neutral" then
		var_9_1:getSideInfo(var_9_2.localSide):removedPartyMember(var_9_2.localGamerIndex)
	end

	var_9_1:removePartyMember(arg_9_1)

	local var_9_3 = var_9_0.controllerSlotToPartyMemberUniqueId

	var_9_3[tablex.indexOf(var_9_3, arg_9_1.uniqueId)] = nil
end

function CasualNewState.validateCasualSettings(arg_10_0, arg_10_1, arg_10_2, arg_10_3)
	local var_10_0 = arg_10_3.settings.casualSettings

	if var_10_0.ground == "creator" then
		local var_10_1 = arg_10_2:getLevelManager():getLevel(var_10_0.groundId)

		if not (var_10_1 and var_10_1:getData()) then
			print("WARN: Replacing party member casual settings ground with default scg")

			var_10_0.ground = "moorePark"
			var_10_0.groundId = native.INVALID_LEVEL_ID
		end
	end
end
