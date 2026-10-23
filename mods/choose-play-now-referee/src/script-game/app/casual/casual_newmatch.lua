import("app.casual.casual_newmatch_begin")
import("app.casual.casual_newmatch_controllerselect")
import("app.casual.casual_newmatch_matchsetup")
import("app.match.match_scenecontroller")
import("app.match.matchsetup_aide")
import("app.match.matchsetup_lockdown")
import("app.match.matchsetupmatchsettings_state")
import("app.network.matchsettingssynchroniser")
import("app.uiinput.input_gamepad_helper")
import("base.ui.optionmenu.optionmenu_aide")
import("core.foundation.tablex")
import("core.statemachine.statemachine")

-- choose-play-now-referee: Play Now gets a "Referee" row on the Match Settings screen.
-- The pick goes in localMatchSettings.refereeIds[1] (slot 1 = EOfficialRole.Referee),
-- which matchin.setupReferees uses instead of rolling random officials, and which
-- matchsetup_aide.saveSettingsForFutureMatches stores in the profile's casualReferees*.
-- Touch judges (slots 2..) are still re-rolled each match.
local MOD_REFEREE_COUNT = native.CGameConfig.MAX_UMPIRES

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

	local savedId

	if sex == native.CSex.Male then
		if settings.casualRefereesMale_count >= 1 then
			savedId = settings:casualRefereesMale_get(1)
		end
	elseif settings.casualRefereesFemale_count >= 1 then
		savedId = settings:casualRefereesFemale_get(1)
	end

	local _, validIds = modListRefereeIds(refereeManager, sex)

	if savedId == nil or not validIds[tostring(savedId)] then
		return randomIds
	end

	local ids = {
		savedId
	}

	for _, id in ipairs(randomIds) do
		if #ids < MOD_REFEREE_COUNT and tostring(id) ~= tostring(savedId) then
			table.insert(ids, id)
		end
	end

	return ids
end

local function modCreateRefereeItem(app, matchData, refereeIds)
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

	if #valueList == 0 then
		return nil
	end

	table.sort(valueList, function(a, b)
		return a.label < b.label
	end)

	return {
		key = "Referee",
		label = "Referee",
		editable = true,
		editType = optionmenu_aide.EditTypes.ValueList,
		displayType = optionmenu_aide.DisplayTypes.ValueList,
		tooltip = native.InputTypes.LJoyLeftRight,
		tooltipText = native.Localise("Select"),
		valueList = valueList,
		getValue = function(list)
			for index, entry in ipairs(list) do
				if tostring(entry.value) == tostring(refereeIds[1]) then
					return index - 1
				end
			end

			return 0
		end,
		setValue = function(index, list)
			if type(index) ~= "number" then
				index = index:toInt()
			end

			local entry = list[index + 1]

			if not entry then
				return
			end

			local previousId = refereeIds[1]

			-- keep the officials distinct: a touch judge who is now the referee takes the old referee's slot
			for slot = 2, #refereeIds do
				if tostring(refereeIds[slot]) == tostring(entry.value) then
					refereeIds[slot] = previousId
				end
			end

			refereeIds[1] = entry.value
		end
	}
end

-- matchsetupmatchsettings_state.lua is already overridden by enable-casual-fieldmarkings,
-- so the row is added by wrapping createMenuItems here instead. Its own referee rows use a
-- display type the Noesis menu can't render and are locked in public builds, so refereeIds
-- is hidden from the stock code while it runs.
local modSettingsState = matchsetupmatchsettings_state.MatchSetupMatchSettingsState
local modStockCreateMenuItems = modSettingsState.modStockCreateMenuItems or modSettingsState.createMenuItems

modSettingsState.modStockCreateMenuItems = modStockCreateMenuItems

function modSettingsState.createMenuItems(arg_0_0, arg_0_1, arg_0_2, arg_0_3, arg_0_4, arg_0_5, arg_0_6, ...)
	local localMatchSettings = arg_0_6 and arg_0_6.isCasual and arg_0_6.localMatchSettings
	local refereeIds = localMatchSettings and localMatchSettings.refereeIds

	if not refereeIds then
		return modStockCreateMenuItems(arg_0_0, arg_0_1, arg_0_2, arg_0_3, arg_0_4, arg_0_5, arg_0_6, ...)
	end

	localMatchSettings.refereeIds = nil

	local ok, menuItems, extra = pcall(modStockCreateMenuItems, arg_0_0, arg_0_1, arg_0_2, arg_0_3, arg_0_4, arg_0_5, arg_0_6, ...)

	localMatchSettings.refereeIds = refereeIds

	if not ok then
		error(menuItems, 0)
	end

	local refereeItem = modCreateRefereeItem(arg_0_5, arg_0_6, refereeIds)

	if refereeItem then
		table.insert(menuItems, refereeItem)
	end

	return menuItems, extra
end

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
