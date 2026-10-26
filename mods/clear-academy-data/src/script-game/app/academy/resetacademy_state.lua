import("base.ui.optionmenu.optionmenu_state")
import("base.ui.optionmenu.optionmenu_aide")
import("app.save.save_helper")
import("base.ui.busy.busy_layout")
import("base.ui.util.gobackstack")

local var_0_0 = {
	{
		key = "UserStatistics",
		localisedLabel = native.Localise("UserStatistics")
	},
	{
		key = "Clubs",
		localisedLabel = native.Localise("Clubs")
	},
	{
		key = "Players",
		localisedLabel = native.Localise("Players")
	},
	{
		key = "Logos",
		localisedLabel = native.Localise("LevelEditorHelpLogos")
	},
	{
		key = "Stadiums",
		localisedLabel = native.Localise("LevelEditorStadiums")
	},
	{
		key = "MatchTypes",
		localisedLabel = native.Localise("MatchTypeDesigner")
	},
	{
		key = "Leagues",
		localisedLabel = native.Localise("Leagues")
	}
}
local var_0_1 = {
	Logos = function(arg_1_0, arg_1_1, arg_1_2, arg_1_3)
		local var_1_0 = arg_1_0:getDecalManager().dataStore

		if var_1_0 then
			var_1_0:setToDefault()

			local var_1_1, var_1_2 = save_helper.createDescriptor(arg_1_2, arg_1_3, "DecalDataStore")
			local var_1_3 = arg_1_2:getSaveDataService()

			var_1_0:save(arg_1_3.user, var_1_1, var_1_2.iconBuffer, var_1_3)
		end
	end,
	Stadiums = function(arg_2_0, arg_2_1, arg_2_2, arg_2_3)
		local var_2_0 = arg_2_0:getLevelManager().dataStore

		if var_2_0 then
			var_2_0:setToDefault()

			local var_2_1, var_2_2 = save_helper.createDescriptor(arg_2_2, arg_2_3, "LevelDataStore")
			local var_2_3 = arg_2_2:getSaveDataService()

			var_2_0:save(arg_2_3.user, var_2_1, var_2_2.iconBuffer, var_2_3)
		end
	end,
	Equipment = function(arg_3_0)
		local var_3_0 = arg_3_0:getBatManager().userCreated

		if var_3_0 then
			var_3_0:setToDefault()
		end
	end,
	Players = function(arg_4_0)
		local var_4_0 = arg_4_0:getPlayerManager().userCreated

		if var_4_0 then
			var_4_0:setToDefault()
		end
	end,
	Clubs = function(arg_5_0, arg_5_1, arg_5_2, arg_5_3)
		local var_5_0 = arg_5_0:getClubManager().userCreated

		if var_5_0 then
			local var_5_1 = arg_5_3.onlineRankedClub or native.INVALID_PLAYER_ID

			var_5_0:clearNonRanked(var_5_1)
		end
	end,
	UserStatistics = function(arg_6_0, arg_6_1)
		if arg_6_1 then
			arg_6_1:reset()
		end
	end,
	MatchTypes = function(arg_7_0, arg_7_1)
		arg_7_0:getMatchTypeManager():clearUserCreatedMatchTypes()
	end,
	Leagues = function(arg_8_0, arg_8_1)
		arg_8_0:getLeagueManager().userCreated:clear()
	end
}
local var_0_2 = 0
local var_0_3 = 1
local var_0_4 = native.Localise("ResetAcademy_Button")
local var_0_5 = native.Localise("Back")
local var_0_6 = native.Localise("Confirm")
local var_0_7 = native.Localise("ResetAcademy_NoneSelected")
local var_0_8 = native.Localise("ResetAcademy_Confirmation")
local var_0_9 = optionmenu_state.OptionMenuState
local var_0_10 = native.InputTypes
local var_0_11 = var_0_10.Accept
local var_0_12 = var_0_10.Decline

Class("ResetAcademyState", var_0_9)

function ResetAcademyState.enter(arg_9_0, arg_9_1, arg_9_2, arg_9_3, arg_9_4, arg_9_5, arg_9_6, arg_9_7, arg_9_8)
	function arg_9_0.reload()
		arg_9_0:exit(arg_9_2, arg_9_3, arg_9_4, arg_9_5, arg_9_6)
		arg_9_0:initialise(arg_9_1, arg_9_2, arg_9_3, arg_9_4, arg_9_5, arg_9_6, arg_9_7, arg_9_8)
	end

	arg_9_0:initialise(arg_9_1, arg_9_2, arg_9_3, arg_9_4, arg_9_5, arg_9_6, arg_9_7, arg_9_8)
end

function ResetAcademyState.initialise(arg_11_0, arg_11_1, arg_11_2, arg_11_3, arg_11_4, arg_11_5, arg_11_6, arg_11_7, arg_11_8)
	arg_11_0.state = var_0_2

	local var_11_0, var_11_1 = arg_11_0:createMenuItems()

	arg_11_0.itemParams = var_11_0

	local var_11_2 = {
		noSpaceBeforePanel = true,
		examineSelectionBeforeExit = true,
		adjustedOnSubstateExit = true,
		itemParams = var_11_0,
		titleBox = {
			left = true,
			title = native.Localise("ResetAcademy")
		}
	}
	local var_11_3

	var_0_9.enter(arg_11_0, arg_11_2, arg_11_3, arg_11_4, arg_11_5, var_11_1, var_11_3, var_11_2)

	arg_11_0.goBackFactoryStack = arg_11_8
end

function ResetAcademyState.resetSelectedFeatures(arg_12_0, arg_12_1, arg_12_2, arg_12_3, arg_12_4, arg_12_5)
	arg_12_0.state = var_0_2

	local var_12_0 = arg_12_0.itemParams

	if arg_12_3 and arg_12_3.val then
		for iter_12_0, iter_12_1 in ipairs(var_0_0) do
			if var_12_0[iter_12_1.key] then
				local var_12_1 = var_0_1[iter_12_1.key]

				if var_12_1 then
					var_12_1(arg_12_4, arg_12_5.stats, arg_12_1, arg_12_5)
				end
			end
		end

		arg_12_4:profileSaveFull(arg_12_5)
		arg_12_0:reload()
	end
end

function ResetAcademyState.checkSelectedFeatures(arg_13_0, arg_13_1, arg_13_2, arg_13_3, arg_13_4)
	local var_13_0 = arg_13_0.itemParams

	arg_13_0.state = var_0_3

	if var_13_0 then
		local var_13_1 = ""

		for iter_13_0, iter_13_1 in ipairs(var_0_0) do
			if var_13_0[iter_13_1.key] then
				var_13_1 = var_13_1 .. iter_13_1.localisedLabel .. "\n"
			end
		end

		if var_13_1 == "" then
			arg_13_1:blockingAlert(arg_13_2, arg_13_3, {
				options = "ok",
				canCancel = false,
				text = var_0_7,
				onSelected = function()
					arg_13_0.state = var_0_2
				end
			})
		else
			arg_13_1:blockingAlert(arg_13_2, arg_13_3, {
				options = "yesno",
				yPos = 0.5,
				canCancel = true,
				text = var_0_8 .. "\n" .. "\n" .. var_13_1,
				onSelected = function(arg_15_0, arg_15_1, arg_15_2)
					arg_13_0:resetSelectedFeatures(arg_15_0, arg_15_1, arg_15_2, arg_13_1, arg_13_4)
				end
			})
		end
	end
end

function ResetAcademyState.exitState(arg_16_0, arg_16_1, arg_16_2, arg_16_3, arg_16_4, arg_16_5, arg_16_6)
	local var_16_0
	local var_16_1
	local var_16_2, var_16_3 = arg_16_5.goBackStack:pop()

	if var_16_2 then
		var_16_0 = var_16_2()
		var_16_1 = var_16_3
	end

	arg_16_6:changeState(var_16_0, arg_16_1, arg_16_2, arg_16_3, arg_16_4, arg_16_5, var_16_1)
end

function ResetAcademyState.update(arg_17_0, arg_17_1, arg_17_2, arg_17_3, arg_17_4, arg_17_5, arg_17_6, arg_17_7, arg_17_8)
	local var_17_0 = arg_17_8.partyMember
	local var_17_1 = var_17_0:getInput()
	local var_17_2 = arg_17_0.state
	local var_17_3, var_17_4, var_17_5, var_17_6 = var_0_9.update(arg_17_0, arg_17_2, arg_17_3, arg_17_4, arg_17_5, arg_17_6, arg_17_7, var_17_1)

	if var_17_2 == var_0_2 then
		arg_17_6:addTooltip(arg_17_0.tooltipsWidget, var_0_12, var_0_5, 99)

		if var_17_6 and var_17_6.label == var_0_4 then
			arg_17_0:checkSelectedFeatures(arg_17_6, arg_17_2, arg_17_3, var_17_0)
		elseif arg_17_6:checkForRelease(var_17_0, var_0_12) then
			arg_17_0:exitState(arg_17_2, arg_17_3, arg_17_5, arg_17_6, arg_17_8, arg_17_1)
			arg_17_6:playSound("Back")
		end
	end
end

function ResetAcademyState.createMenuItems(arg_18_0)
	local var_18_0 = {}
	local var_18_1 = {}

	for iter_18_0, iter_18_1 in ipairs(var_0_0) do
		table.insert(var_18_0, optionmenu_aide.createToggle(iter_18_1.localisedLabel, iter_18_1.key))

		var_18_1[iter_18_1.key] = false
	end

	table.insert(var_18_0, optionmenu_aide.createButton(var_0_4))

	return var_18_1, var_18_0
end

function ResetAcademyState.render(arg_19_0, arg_19_1, arg_19_2, arg_19_3, arg_19_4, arg_19_5)
	var_0_9.render(arg_19_0, arg_19_1, arg_19_2, arg_19_3, arg_19_4)
end

function ResetAcademyState.exit(arg_20_0, arg_20_1, arg_20_2, arg_20_3, arg_20_4, arg_20_5)
	var_0_9.exit(arg_20_0, arg_20_1, arg_20_2, arg_20_3, arg_20_4, arg_20_5)
end

-- clear-academy-data mod ------------------------------------------------------
-- Y / Triangle on the home screen's Academy row opens ClearAcademyDataState.
-- Everything here deletes LOCAL save data only. Nothing calls the sharing
-- service, so content uploaded to the Big Ant servers is never touched. User
-- statistics (synced with the sharing service) and the online ranked club are
-- deliberately left alone.

local function clearAcademyText(arg_ca_0, arg_ca_1)
	local var_ca_0 = native.Localise(arg_ca_0)

	if type(var_ca_0) ~= "string" or var_ca_0 == "" or var_ca_0 == arg_ca_0 or string.find(var_ca_0, "^[<#%[]") then
		return arg_ca_1
	end

	return var_ca_0
end

local ClearAcademyLabels = {
	open = "Clear Academy Data",
	title = "Clear Academy Data",
	selectAll = "Select All",
	deselectAll = "Deselect All",
	clear = "Clear Selected Data",
	noneSelected = "Select at least one type of Academy data to clear.",
	confirmHeader = "Permanently delete or reset the following Academy data in this save?",
	confirmFooter = "This cannot be undone. Deleted data cannot be recovered.\nContent shared online is not affected.",
	leaguesRequired = "(required when clearing Clubs)",
	rankedKept = "Your online ranked club will be kept.",
	busyTitle = "Clearing Academy Data",
	clearing = "Clearing %s...",
	saving = "Saving...",
	done = "Academy data cleared.",
	playersKept = "%d player(s) could not be removed or reset because a club needs them to fill its lineup.",
	failed = "Could not clear: %s"
}

-- Log in the game folder (retail Lua has io/os). Errors are always written;
-- ClearAcademyDebug adds verbose tracing (player/club dumps, Y input, resets).
local ClearAcademyDebug = false

local function clearAcademyLogError(arg_ca_200)
	pcall(function()
		local var_ca_200 = io.open("clearacademy_debug.txt", "a")

		if var_ca_200 then
			var_ca_200:write(os.date("%Y-%m-%d %H:%M:%S ") .. tostring(arg_ca_200) .. "\n")
			var_ca_200:close()
		end
	end)
end

local function clearAcademyLog(arg_ca_202)
	if ClearAcademyDebug then
		clearAcademyLogError(arg_ca_202)
	end
end

local function clearAcademyTraceback(arg_ca_201)
	if debug and debug.traceback then
		return debug.traceback(tostring(arg_ca_201), 2)
	end

	return tostring(arg_ca_201)
end

local function clearAcademySafe(arg_ca_2, ...)
	local var_ca_1, var_ca_2 = pcall(arg_ca_2, ...)

	if var_ca_1 then
		return var_ca_2
	end
end

local function clearAcademyEnumEquals(arg_ca_3, arg_ca_4)
	if arg_ca_3 == arg_ca_4 then
		return true
	end

	local var_ca_3 = clearAcademySafe(function()
		return arg_ca_3:toInt()
	end)
	local var_ca_4 = clearAcademySafe(function()
		return arg_ca_4:toInt()
	end)

	return var_ca_3 ~= nil and var_ca_3 == var_ca_4
end

local function clearAcademyCollect(arg_ca_5, arg_ca_6)
	local var_ca_5 = {}

	for iter_ca_0, iter_ca_1 in arg_ca_5:iterateAll() do
		if iter_ca_1 and (not arg_ca_6 or arg_ca_6(iter_ca_1)) then
			table.insert(var_ca_5, iter_ca_1.id)
		end
	end

	return var_ca_5
end

local function clearAcademyNpcIds(arg_ca_7, arg_ca_8)
	return clearAcademyCollect(arg_ca_7:getRefereeManager().userCreated, function(arg_ca_9)
		return clearAcademyEnumEquals(arg_ca_9.identity.npcType, arg_ca_8)
	end)
end

local function clearAcademyCustomDifficultyCount(arg_ca_10)
	local var_ca_6 = arg_ca_10.settings
	local var_ca_7 = 0

	for iter_ca_2 = 1, var_ca_6.gameplayModifiers_count do
		if var_ca_6:gameplayModifiers_get(iter_ca_2).custom then
			var_ca_7 = var_ca_7 + 1
		end
	end

	return var_ca_7
end

local function clearAcademyRankedClubId(arg_ca_11)
	return arg_ca_11.onlineRankedClub or native.INVALID_PLAYER_ID
end

local function clearAcademyIsOnDiscPlayerId(arg_ca_230)
	return clearAcademySafe(native.CPlayerDatabaseOnDisc.getIsOnDiscPlayerId, arg_ca_230) == true
end

-- A user-created entry that stands in for an official player: it keeps the
-- on-disc id, or it is an override (linked to an on-disc player).
local function clearAcademyIsOfficialEdit(arg_ca_236)
	return clearAcademyIsOnDiscPlayerId(arg_ca_236.id) or clearAcademySafe(function()
		return arg_ca_236:getIsOverride()
	end) == true
end

-- Players made in the Academy (or downloaded). Edits to official players are
-- user-created versions that keep the on-disc id, so those are skipped here.
local function clearAcademyCreatedPlayerIds(arg_ca_231)
	return clearAcademyCollect(arg_ca_231:getPlayerManager().userCreated, function(arg_ca_232)
		return not clearAcademyIsOfficialEdit(arg_ca_232)
	end)
end

-- Official players with an Academy edit: user-created entries that keep an
-- on-disc id, plus any on-disc player the manager reports as having a
-- user-created version (covers tier-1 scanned players too).
local function clearAcademyPlayerDesc(arg_ca_260)
	local function var_ca_260(arg_ca_261)
		local var_ca_261, var_ca_262 = pcall(arg_ca_261)

		return var_ca_261 and tostring(var_ca_262) or "err"
	end

	return string.format("id=%s name=%s onDiscId=%s tier1=%s licensed=%s override=%s onDiskPlayer=%s academyId=%s ovr=%s spent=%s userEdited=%s customStrings=%s", var_ca_260(function()
		return arg_ca_260.id
	end), var_ca_260(function()
		return arg_ca_260.fullName
	end), var_ca_260(function()
		return clearAcademyIsOnDiscPlayerId(arg_ca_260.id)
	end), var_ca_260(function()
		return arg_ca_260.isTier1
	end), var_ca_260(function()
		return arg_ca_260.isLicensed
	end), var_ca_260(function()
		return arg_ca_260:getIsOverride()
	end), var_ca_260(function()
		return arg_ca_260:getIsOnDiskPlayer()
	end), var_ca_260(function()
		return arg_ca_260.academyId
	end), var_ca_260(function()
		return arg_ca_260:getOverallForPrimaryRole()
	end), var_ca_260(function()
		return arg_ca_260.attributes.totalSpent
	end), var_ca_260(function()
		return arg_ca_260.isUserEdited
	end), var_ca_260(function()
		return arg_ca_260.hasCustomStrings
	end))
end

-- One-off dump of the player stores, written to clearacademy_debug.txt when
-- the menu opens, to see where official-player edits actually live.
local function clearAcademyDumpPlayers(arg_ca_262)
	local var_ca_263 = arg_ca_262:getPlayerManager()
	local var_ca_264, var_ca_265 = pcall(function()
		local var_ca_266 = 0

		for iter_ca_60, iter_ca_61 in var_ca_263.userCreated:iterateAll() do
			var_ca_266 = var_ca_266 + 1

			if var_ca_266 <= 60 then
				clearAcademyLog("  userCreated: " .. clearAcademyPlayerDesc(iter_ca_61))
			end
		end

		return var_ca_266
	end)

	clearAcademyLog("userCreated iterate ok=" .. tostring(var_ca_264) .. " result=" .. tostring(var_ca_265) .. " count=" .. tostring(clearAcademySafe(function()
		return var_ca_263.userCreated.count
	end)))

	local var_ca_267, var_ca_268 = pcall(function()
		local var_ca_269 = 0
		local var_ca_270 = 0

		for iter_ca_62, iter_ca_63 in var_ca_263.onDisc:iterateAll() do
			var_ca_269 = var_ca_269 + 1

			if iter_ca_63.isTier1 then
				var_ca_270 = var_ca_270 + 1
			end

		end

		return string.format("%d players, %d tier-1", var_ca_269, var_ca_270)
	end)

	clearAcademyLog("onDisc iterate ok=" .. tostring(var_ca_267) .. " result=" .. tostring(var_ca_268))
end

local function clearAcademyOverall(arg_ca_280)
	return clearAcademySafe(function()
		return arg_ca_280:getOverallForPrimaryRole()
	end)
end

local function clearAcademyTotalSpent(arg_ca_281)
	return clearAcademySafe(function()
		return arg_ca_281.attributes.totalSpent
	end)
end

-- Tier-1 (scanned) players keep their edits in the native custom-licensed
-- store (saveCustomLicensed), not in userCreated, and stat edits don't set
-- isUserEdited, so also compare the live player against the on-disc one.
local function clearAcademyTier1LooksEdited(arg_ca_282, arg_ca_283)
	if arg_ca_282.isUserEdited or arg_ca_282.hasCustomStrings then
		return true
	end

	local var_ca_280 = clearAcademyOverall(arg_ca_282)
	local var_ca_281 = clearAcademyOverall(arg_ca_283)

	if type(var_ca_280) == "number" and type(var_ca_281) == "number" and math.abs(var_ca_280 - var_ca_281) > 0.001 then
		return true
	end

	local var_ca_282 = clearAcademyTotalSpent(arg_ca_282)
	local var_ca_283 = clearAcademyTotalSpent(arg_ca_283)

	return var_ca_282 ~= nil and var_ca_283 ~= nil and var_ca_282 ~= var_ca_283
end

-- Returns (editedIds, resetIds). editedIds is what the menu counts; resetIds
-- also holds every tier-1 player, because resetCustomLicensedPlayer is the
-- stock reset and edits can't always be detected from Lua.
local function clearAcademyOfficialPlayerSets(arg_ca_233)
	local var_ca_230 = arg_ca_233:getPlayerManager()
	local var_ca_231 = {}
	local var_ca_232 = {}
	local var_ca_284 = {}
	local var_ca_285 = {}

	local function var_ca_233(arg_ca_234, arg_ca_284)
		if arg_ca_234 == nil then
			return
		end

		if arg_ca_284 and not var_ca_232[arg_ca_234] then
			var_ca_232[arg_ca_234] = true

			table.insert(var_ca_231, arg_ca_234)
		end

		if not var_ca_285[arg_ca_234] then
			var_ca_285[arg_ca_234] = true

			table.insert(var_ca_284, arg_ca_234)
		end
	end

	pcall(function()
		for iter_ca_40, iter_ca_41 in var_ca_230.userCreated:iterateAll() do
			if iter_ca_41 and clearAcademyIsOfficialEdit(iter_ca_41) then
				var_ca_233(iter_ca_41.id, true)
			end
		end
	end)
	pcall(function()
		for iter_ca_42, iter_ca_43 in var_ca_230.onDisc:iterateAll() do
			if iter_ca_43 and iter_ca_43.isTier1 then
				local var_ca_286 = clearAcademySafe(var_ca_230.getPlayer, var_ca_230, iter_ca_43.id)

				var_ca_233(iter_ca_43.id, var_ca_286 ~= nil and clearAcademyTier1LooksEdited(var_ca_286, iter_ca_43))
			end
		end
	end)

	return var_ca_231, var_ca_284
end

local function clearAcademyEditedOfficialPlayerIds(arg_ca_287)
	return (clearAcademyOfficialPlayerSets(arg_ca_287))
end

local function clearAcademyIsOfficialClubId(arg_ca_300)
	if clearAcademySafe(native.CClubManager.getIsOnDiscClub, arg_ca_300) == true then
		return true
	end

	return clearAcademySafe(native.CClubDatabaseOnDisc.getIsOfficialClubId, arg_ca_300) == true
end

local function clearAcademyClubDesc(arg_ca_301)
	local var_ca_300 = clearAcademySafe(function()
		return arg_ca_301.fullName
	end)

	return string.format("id=%s name=%s official=%s", tostring(clearAcademySafe(function()
		return arg_ca_301.id
	end)), tostring(var_ca_300), tostring(clearAcademyIsOfficialClubId(arg_ca_301.id)))
end

-- Clubs made in the Academy (or downloaded), minus the online ranked club.
local function clearAcademyCreatedClubIds(arg_ca_302, arg_ca_303)
	local var_ca_301 = clearAcademyRankedClubId(arg_ca_303)

	return clearAcademyCollect(arg_ca_302:getClubManager().userCreated, function(arg_ca_304)
		return arg_ca_304.id ~= var_ca_301 and not clearAcademyIsOfficialClubId(arg_ca_304.id)
	end)
end

-- Stock copy of an official club. In game every official club reports
-- isCustomLicensedData and clubManager.onDisc already has the edits merged in,
-- so prefer onDiscDatabase (the raw disc data).
local function clearAcademyStockClub(arg_ca_340, arg_ca_341)
	return clearAcademySafe(function()
		return arg_ca_340.onDiscDatabase:getClub(arg_ca_341)
	end) or clearAcademySafe(function()
		return arg_ca_340.onDisc:getClub(arg_ca_341)
	end)
end

-- Signature of what an Academy edit can change: identity, kit count, roster
-- and every lineup (player in each slot plus captain).
local function clearAcademyClubSignature(arg_ca_342)
	local var_ca_340 = {}

	local function var_ca_341(arg_ca_343)
		local var_ca_342, var_ca_343 = pcall(arg_ca_343)

		table.insert(var_ca_340, var_ca_342 and tostring(var_ca_343) or "?")
	end

	var_ca_341(function()
		return arg_ca_342.fullName
	end)
	var_ca_341(function()
		return arg_ca_342.nickname
	end)
	var_ca_341(function()
		return arg_ca_342.uniformCount
	end)

	local var_ca_344 = clearAcademySafe(function()
		return arg_ca_342.playerCount
	end) or 0

	table.insert(var_ca_340, "P")

	for iter_ca_90 = 1, var_ca_344 do
		var_ca_341(function()
			return arg_ca_342:getPlayerIdAt(iter_ca_90)
		end)
	end

	local var_ca_345 = clearAcademySafe(function()
		return arg_ca_342:getLineupCount()
	end) or 0

	for iter_ca_91 = 1, var_ca_345 do
		local var_ca_346 = clearAcademySafe(function()
			return arg_ca_342:getLineup(iter_ca_91)
		end)

		table.insert(var_ca_340, "L")

		if var_ca_346 then
			-- Only read the slots the lineup's category actually has: slots
			-- past the end hold uninitialised memory that differs every read.
			local var_ca_349 = clearAcademySafe(function()
				return var_ca_346.category
			end)
			local var_ca_350 = var_ca_349 ~= nil and (clearAcademySafe(native.CClubLineup.getLineupSize, var_ca_349) or clearAcademySafe(native.CClubLineupDefintions.getLineupSizeMax, var_ca_349))

			table.insert(var_ca_340, tostring(var_ca_349))

			for iter_ca_92 = 1, type(var_ca_350) == "number" and var_ca_350 or 0 do
				local var_ca_347, var_ca_348 = pcall(function()
					return var_ca_346:getPlayerIdAt(iter_ca_92)
				end)

				table.insert(var_ca_340, var_ca_347 and tostring(var_ca_348) or "?")
			end

			var_ca_341(function()
				return var_ca_346:getSpecialRole(native.EClubLineupSpecialRole.Captain)
			end)
		end
	end

	return table.concat(var_ca_340, ",")
end

-- Official clubs with an Academy edit (identity, kits, roster or a saved
-- casual lineup). In game these live in the native custom-licensed store
-- (saveCustomLicensed / saveCustomLicensedMatchClubLineup), not userCreated.
-- userCreated:containsClub and isCustomLicensedData are true for every
-- official club, so edits are found by comparing against the stock club.
local ClearAcademyClubSigLogged = 0

local function clearAcademyEditedOfficialClubIds(arg_ca_305)
	local var_ca_302 = arg_ca_305:getClubManager()
	local var_ca_303 = {}
	local var_ca_304 = {}

	local function var_ca_305(arg_ca_306)
		if arg_ca_306 ~= nil and not var_ca_304[arg_ca_306] then
			var_ca_304[arg_ca_306] = true

			table.insert(var_ca_303, arg_ca_306)
		end
	end

	pcall(function()
		for iter_ca_70, iter_ca_71 in var_ca_302.userCreated:iterateAll() do
			if iter_ca_71 and clearAcademyIsOfficialClubId(iter_ca_71.id) then
				var_ca_305(iter_ca_71.id)
			end
		end
	end)
	pcall(function()
		for iter_ca_72, iter_ca_73 in var_ca_302.onDisc:iterateAll() do
			if iter_ca_73 and not var_ca_304[iter_ca_73.id] then
				local var_ca_310 = clearAcademySafe(var_ca_302.getClub, var_ca_302, iter_ca_73.id)
				local var_ca_311 = clearAcademyStockClub(var_ca_302, iter_ca_73.id)

				if var_ca_310 and var_ca_311 then
					local var_ca_312 = clearAcademyClubSignature(var_ca_310)
					local var_ca_313 = clearAcademyClubSignature(var_ca_311)

					if ClearAcademyDebug and var_ca_312 ~= var_ca_313 and ClearAcademyClubSigLogged < 5 then
						ClearAcademyClubSigLogged = ClearAcademyClubSigLogged + 1

						clearAcademyLog("  edited club id=" .. tostring(iter_ca_73.id) .. "\n    live : " .. var_ca_312 .. "\n    stock: " .. var_ca_313)
					end

					if var_ca_312 ~= var_ca_313 then
						var_ca_305(iter_ca_73.id)
					end
				end
			end
		end
	end)

	return var_ca_303
end

local function clearAcademyDumpClubs(arg_ca_307)
	ClearAcademyClubSigLogged = 0

	local var_ca_306 = arg_ca_307:getClubManager()
	local var_ca_307, var_ca_308 = pcall(function()
		local var_ca_309 = 0

		for iter_ca_74, iter_ca_75 in var_ca_306.userCreated:iterateAll() do
			var_ca_309 = var_ca_309 + 1

			if var_ca_309 <= 60 then
				clearAcademyLog("  userCreated club: " .. clearAcademyClubDesc(iter_ca_75))
			end
		end

		return var_ca_309
	end)

	clearAcademyLog("userCreated clubs iterate ok=" .. tostring(var_ca_307) .. " result=" .. tostring(var_ca_308) .. "; edited official clubs found: " .. tostring(#clearAcademyEditedOfficialClubIds(arg_ca_307)))
end

-- Menu order. count(uiServices, partyMember) returns a number or nil (unknown).
local ClearAcademyCategories = {
	{
		key = "Players",
		label = "Created Players",
		count = function(arg_ca_12)
			return #clearAcademyCreatedPlayerIds(arg_ca_12)
		end
	},
	{
		key = "OfficialPlayers",
		label = "Reset Edited Official Players",
		status = "Resetting edited official players...",
		count = function(arg_ca_235)
			return #clearAcademyEditedOfficialPlayerIds(arg_ca_235)
		end
	},
	{
		key = "Clubs",
		label = "Created Clubs",
		count = function(arg_ca_13, arg_ca_310)
			return #clearAcademyCreatedClubIds(arg_ca_13, arg_ca_310)
		end
	},
	{
		key = "OfficialClubs",
		label = "Reset Edited Official Clubs",
		status = "Resetting edited official clubs...",
		count = function(arg_ca_311)
			return #clearAcademyEditedOfficialClubIds(arg_ca_311)
		end
	},
	{
		key = "Logos",
		label = clearAcademyText("LevelEditorHelpLogos", "Logos"),
		count = function(arg_ca_14)
			return arg_ca_14:getDecalManager().dataStore.count
		end
	},
	{
		key = "Referees",
		label = clearAcademyText("Umpires", "Referees"),
		count = function(arg_ca_15)
			return #clearAcademyNpcIds(arg_ca_15, native.CNpcType.Referee)
		end
	},
	{
		key = "Coaches",
		label = clearAcademyText("Coaches", "Coaches"),
		count = function(arg_ca_16)
			return #clearAcademyNpcIds(arg_ca_16, native.CNpcType.Coach)
		end
	},
	{
		key = "Stadiums",
		label = clearAcademyText("LevelEditorStadiums", "Stadiums"),
		count = function(arg_ca_17)
			return arg_ca_17:getLevelManager().dataStore.count
		end
	},
	{
		key = "Leagues",
		label = clearAcademyText("Leagues", "Leagues"),
		count = function(arg_ca_18)
			return arg_ca_18:getLeagueManager().userCreated.count
		end
	},
	{
		key = "MatchTypes",
		label = clearAcademyText("MatchTypeDesigner", "Match Types")
	},
	{
		key = "CustomDifficulties",
		label = clearAcademyText("CustomDifficulties", "Custom Difficulties"),
		count = function(arg_ca_19, arg_ca_20)
			return clearAcademyCustomDifficultyCount(arg_ca_20)
		end
	}
}

-- Execution order: leagues reference clubs, clubs reference players, so they
-- go first. Each step is step(ctx) and returns true when finished; Players is
-- spread over several frames so the busy screen keeps animating.
local ClearAcademyOrder = {
	"Leagues",
	"Clubs",
	"OfficialClubs",
	"Players",
	"OfficialPlayers",
	"Referees",
	"Coaches",
	"MatchTypes",
	"CustomDifficulties",
	"Stadiums",
	"Logos"
}
local var_ca_8 = 20

local function clearAcademyDeleteNpcs(arg_ca_21, arg_ca_22)
	local var_ca_9 = arg_ca_21.uiServices:getRefereeManager().userCreated

	for iter_ca_3, iter_ca_4 in ipairs(clearAcademyNpcIds(arg_ca_21.uiServices, arg_ca_22)) do
		var_ca_9:deleteReferee(iter_ca_4)
	end

	return true
end

local ClearAcademySteps = {
	Leagues = function(arg_ca_23)
		arg_ca_23.uiServices:getLeagueManager().userCreated:clear()

		return true
	end,
	Clubs = function(arg_ca_24)
		local var_ca_320 = arg_ca_24.uiServices:getClubManager().userCreated
		local var_ca_321 = clearAcademySafe(clearAcademyCreatedClubIds, arg_ca_24.uiServices, arg_ca_24.partyMember)

		if not var_ca_321 then
			-- No iterator: fall back to the stock Reset Academy behaviour.
			var_ca_320:clearNonRanked(clearAcademyRankedClubId(arg_ca_24.partyMember))

			return true
		end

		for iter_ca_76, iter_ca_77 in ipairs(var_ca_321) do
			var_ca_320:deleteClub(iter_ca_77)
		end

		return true
	end,
	OfficialClubs = function(arg_ca_322)
		local var_ca_322 = arg_ca_322.uiServices:getClubManager()
		local var_ca_323 = clearAcademyEditedOfficialClubIds(arg_ca_322.uiServices)

		clearAcademyLog(string.format("official club reset: %d edited", #var_ca_323))

		local var_ca_330 = {}

		pcall(function()
			for iter_ca_80, iter_ca_81 in var_ca_322.userCreated:iterateAll() do
				if iter_ca_81 then
					var_ca_330[iter_ca_81.id] = true
				end
			end
		end)

		local function var_ca_331(arg_ca_330)
			local var_ca_333 = clearAcademySafe(var_ca_322.getClub, var_ca_322, arg_ca_330)
			local var_ca_334 = clearAcademyStockClub(var_ca_322, arg_ca_330)

			if not var_ca_333 or not var_ca_334 then
				return "unknown"
			end

			local var_ca_335 = clearAcademyClubSignature(var_ca_333)
			local var_ca_336 = clearAcademyClubSignature(var_ca_334)

			if var_ca_335 == var_ca_336 then
				return "matches stock"
			end

			return "STILL DIFFERENT\n    live : " .. var_ca_335 .. "\n    stock: " .. var_ca_336
		end

		for iter_ca_78, iter_ca_79 in ipairs(var_ca_323) do
			local var_ca_324 = clearAcademySafe(var_ca_322.getClub, var_ca_322, iter_ca_79)
			local var_ca_325, var_ca_326

			if var_ca_330[iter_ca_79] then
				-- A user-created version with the official id: the stock Academy
				-- Delete Club ("Restored official version of X").
				var_ca_325, var_ca_326 = pcall(var_ca_322.userCreated.deleteClub, var_ca_322.userCreated, iter_ca_79)
			else
				-- Custom-licensed data: there is no native reset, so write an
				-- untouched copy of the on-disc club back over it, the same way
				-- a downloaded club replaces a licensed one (saveCustomLicensed).
				var_ca_325, var_ca_326 = pcall(function()
					local var_ca_332 = native.CClub()

					var_ca_332:set(clearAcademyStockClub(var_ca_322, iter_ca_79))
					pcall(function()
						var_ca_332.isCustomLicensedData = false
					end)

					return var_ca_322:saveCustomLicensed(var_ca_332)
				end)
			end

			clearAcademyLog(string.format("  reset club %s ok=%s %s after: %s", var_ca_324 and clearAcademyClubDesc(var_ca_324) or tostring(iter_ca_79), tostring(var_ca_325), tostring(var_ca_326), tostring(var_ca_331(iter_ca_79))))
		end

		return true
	end,
	Players = function(arg_ca_25)
		local var_ca_10 = arg_ca_25.uiServices:getPlayerManager()
		local var_ca_11 = arg_ca_25.uiServices:getClubManager()

		if not arg_ca_25.playerIds then
			local var_ca_12 = clearAcademySafe(clearAcademyCreatedPlayerIds, arg_ca_25.uiServices)

			if not var_ca_12 then
				-- No iterator: fall back to the stock Reset Academy behaviour.
				var_ca_10.userCreated:setToDefault()

				return true
			end

			arg_ca_25.playerIds = var_ca_12
			arg_ca_25.playerIndex = 1
		end

		local var_ca_13 = arg_ca_25.playerIds
		local var_ca_14 = math.min(#var_ca_13, arg_ca_25.playerIndex + var_ca_8 - 1)

		for iter_ca_5 = arg_ca_25.playerIndex, var_ca_14 do
			local var_ca_15 = var_ca_13[iter_ca_5]

			-- Same as the stock Delete Player screen: fix up any club lineup
			-- that uses the player first, and keep the player if it can't.
			if native.ClubLineupHelper.tryDeletePlayerRepairLineups(var_ca_10, var_ca_11, var_ca_15) then
				var_ca_10.userCreated:deletePlayer(var_ca_15)

				local var_ca_240 = arg_ca_25.partyMember.settings

				if var_ca_240.drillPlayerId == var_ca_15 then
					var_ca_240.drillPlayerId = native.INVALID_PLAYER_ID
				end
			else
				arg_ca_25.playersKept = arg_ca_25.playersKept + 1
			end
		end

		arg_ca_25.playerIndex = var_ca_14 + 1

		return var_ca_14 >= #var_ca_13
	end,
	OfficialPlayers = function(arg_ca_241)
		local var_ca_241 = arg_ca_241.uiServices:getPlayerManager()
		local var_ca_242 = arg_ca_241.uiServices:getClubManager()

		if not arg_ca_241.officialIds then
			local var_ca_290, var_ca_291 = clearAcademyOfficialPlayerSets(arg_ca_241.uiServices)

			arg_ca_241.officialEdited = {}

			for iter_ca_47, iter_ca_48 in ipairs(var_ca_290) do
				arg_ca_241.officialEdited[iter_ca_48] = true
			end

			arg_ca_241.officialIds = var_ca_291
			arg_ca_241.officialIndex = 1
			arg_ca_241.officialFailures = 0

			clearAcademyLog(string.format("official reset: %d detected edits, %d players to reset", #var_ca_290, #var_ca_291))
		end

		local var_ca_243 = arg_ca_241.officialIds
		local var_ca_244 = math.min(#var_ca_243, arg_ca_241.officialIndex + 50 - 1)

		for iter_ca_44 = arg_ca_241.officialIndex, var_ca_244 do
			local var_ca_245 = var_ca_243[iter_ca_44]
			local var_ca_246 = clearAcademySafe(var_ca_241.getPlayer, var_ca_241, var_ca_245)
			local var_ca_292 = arg_ca_241.officialEdited[var_ca_245]
			local var_ca_293 = var_ca_246 and clearAcademyOverall(var_ca_246)

			if var_ca_246 then
				-- The same calls as the stock Reset (tier-1 scanned players) and
				-- Delete (other edited officials, which restores the on-disc
				-- version) actions in the Academy player list. Each player is
				-- protected so one failure doesn't stop the rest.
				local var_ca_294, var_ca_295 = pcall(function()
					if var_ca_246.isTier1 then
						var_ca_241:resetCustomLicensedPlayer(var_ca_246)
					elseif native.ClubLineupHelper.tryDeletePlayerRepairLineups(var_ca_241, var_ca_242, var_ca_245, var_ca_246.academyId) then
						local var_ca_247 = var_ca_241.academyPlayerManager

						if var_ca_247 then
							var_ca_247:deleteUserCreatedVersionOfPlayer(var_ca_246)
						else
							var_ca_241.userCreated:deletePlayer(var_ca_245)
						end
					else
						arg_ca_241.playersKept = arg_ca_241.playersKept + 1
					end
				end)

				if not var_ca_294 then
					arg_ca_241.officialFailures = arg_ca_241.officialFailures + 1

					if arg_ca_241.officialFailures <= 5 then
						clearAcademyLogError("  reset failed for " .. clearAcademyPlayerDesc(var_ca_246) .. ": " .. tostring(var_ca_295))
					end
				end

				if var_ca_292 then
					local var_ca_296 = clearAcademySafe(var_ca_241.getPlayer, var_ca_241, var_ca_245)

					clearAcademyLog(string.format("  reset %s: ovr %s -> %s", clearAcademyPlayerDesc(var_ca_246), tostring(var_ca_293), tostring(var_ca_296 and clearAcademyOverall(var_ca_296))))
				end
			end
		end

		arg_ca_241.officialIndex = var_ca_244 + 1

		if var_ca_244 >= #var_ca_243 and arg_ca_241.officialFailures > 0 then
			clearAcademyLogError(string.format("official reset: %d failures", arg_ca_241.officialFailures))
		end

		return var_ca_244 >= #var_ca_243
	end,
	Referees = function(arg_ca_26)
		return clearAcademyDeleteNpcs(arg_ca_26, native.CNpcType.Referee)
	end,
	Coaches = function(arg_ca_27)
		return clearAcademyDeleteNpcs(arg_ca_27, native.CNpcType.Coach)
	end,
	MatchTypes = function(arg_ca_28)
		var_0_1.MatchTypes(arg_ca_28.uiServices)

		return true
	end,
	CustomDifficulties = function(arg_ca_29)
		local var_ca_16 = arg_ca_29.partyMember.settings

		for iter_ca_6 = var_ca_16.gameplayModifiers_count, 1, -1 do
			if var_ca_16:gameplayModifiers_get(iter_ca_6).custom then
				var_ca_16:gameplayModifiers_remove(iter_ca_6)
			end
		end

		local var_ca_17 = var_ca_16.casualSettings

		if var_ca_17 and var_ca_17.difficulty == native.EDifficulty.Custom then
			var_ca_17.difficulty = native.EDifficulty.Medium
			var_ca_17.difficultyIndex = native.EDifficulty.Medium:toInt()
		end

		return true
	end,
	Stadiums = function(arg_ca_30)
		var_0_1.Stadiums(arg_ca_30.uiServices, nil, arg_ca_30.engine, arg_ca_30.partyMember)

		return true
	end,
	Logos = function(arg_ca_31)
		var_0_1.Logos(arg_ca_31.uiServices, nil, arg_ca_31.engine, arg_ca_31.partyMember)

		return true
	end
}

local function clearAcademyStatusFor(arg_ca_250)
	for iter_ca_50, iter_ca_51 in ipairs(ClearAcademyCategories) do
		if iter_ca_51.key == arg_ca_250 then
			return iter_ca_51.status or string.format(ClearAcademyLabels.clearing, iter_ca_51.label)
		end
	end

	return string.format(ClearAcademyLabels.clearing, arg_ca_250)
end

local function clearAcademyLabelFor(arg_ca_32)
	for iter_ca_7, iter_ca_8 in ipairs(ClearAcademyCategories) do
		if iter_ca_8.key == arg_ca_32 then
			return iter_ca_8.label
		end
	end

	return arg_ca_32
end

local function clearAcademySaveBusy(arg_ca_33, arg_ca_34)
	if clearAcademySafe(function()
		return arg_ca_34:profileSaveInProgress(arg_ca_33)
	end) then
		return true
	end

	local var_ca_18 = clearAcademySafe(function()
		return arg_ca_34:getDecalManager().dataStore:isBusy()
	end)
	local var_ca_19 = clearAcademySafe(function()
		return arg_ca_34:getLevelManager().dataStore:isBusy()
	end)

	return var_ca_18 == true or var_ca_19 == true
end

Class("ClearAcademyDataState", var_0_9)

function ClearAcademyDataState.enter(arg_ca_35, arg_ca_36, arg_ca_37, arg_ca_38, arg_ca_39, arg_ca_40, arg_ca_41, arg_ca_42, arg_ca_43)
	clearAcademyLog("enter ClearAcademyDataState")

	if ClearAcademyDebug then
		clearAcademyDumpPlayers(arg_ca_40)
		clearAcademyDumpClubs(arg_ca_40)
	end

	arg_ca_35.phase = "menu"
	arg_ca_35.goBackFactoryStack = arg_ca_43
	arg_ca_35.itemParams = {}

	for iter_ca_9, iter_ca_10 in ipairs(ClearAcademyCategories) do
		arg_ca_35.itemParams[iter_ca_10.key] = false
	end

	arg_ca_40:titleSetSubAreaOfGame(ClearAcademyLabels.title)
	var_0_9.enter(arg_ca_35, arg_ca_37, arg_ca_38, arg_ca_39, arg_ca_40, arg_ca_35:createMenuItems(arg_ca_40, arg_ca_41.partyMember), nil, {
		noSpaceBeforePanel = true,
		examineSelectionBeforeExit = true,
		itemParams = arg_ca_35.itemParams,
		titleBox = {
			left = true,
			title = ClearAcademyLabels.title
		}
	})
end

function ClearAcademyDataState.countFor(arg_ca_44, arg_ca_45, arg_ca_46, arg_ca_47)
	if arg_ca_45.count then
		local var_ca_20 = clearAcademySafe(arg_ca_45.count, arg_ca_46, arg_ca_47)

		if type(var_ca_20) == "number" then
			return var_ca_20
		end
	end
end

function ClearAcademyDataState.allSelected(arg_ca_48)
	for iter_ca_11, iter_ca_12 in ipairs(ClearAcademyCategories) do
		if not arg_ca_48.itemParams[iter_ca_12.key] then
			return false
		end
	end

	return true
end

function ClearAcademyDataState.createMenuItems(arg_ca_49, arg_ca_50, arg_ca_51)
	local var_ca_21 = {}

	-- Counting scans the whole on-disc player database, so it only happens on
	-- entry and after a clear, not on every toggle.
	if not arg_ca_49.counts or arg_ca_49.countsDirty then
		arg_ca_49.counts = {}
		arg_ca_49.countsDirty = false

		for iter_ca_45, iter_ca_46 in ipairs(ClearAcademyCategories) do
			arg_ca_49.counts[iter_ca_46.key] = arg_ca_49:countFor(iter_ca_46, arg_ca_50, arg_ca_51)
		end
	end

	for iter_ca_13, iter_ca_14 in ipairs(ClearAcademyCategories) do
		local var_ca_22 = arg_ca_49.counts[iter_ca_14.key]
		local var_ca_23 = iter_ca_14.label

		if var_ca_22 then
			var_ca_23 = string.format("%s (%d)", var_ca_23, var_ca_22)
		end

		table.insert(var_ca_21, optionmenu_aide.createToggle(var_ca_23, iter_ca_14.key))
	end

	table.insert(var_ca_21, optionmenu_aide.createButton(arg_ca_49:allSelected() and ClearAcademyLabels.deselectAll or ClearAcademyLabels.selectAll, {
		clearAcademyAction = "selectAll"
	}))
	table.insert(var_ca_21, optionmenu_aide.createButton(ClearAcademyLabels.clear, {
		clearAcademyAction = "clear"
	}))

	return var_ca_21
end

function ClearAcademyDataState.rebuildMenu(arg_ca_52, arg_ca_53, arg_ca_54, arg_ca_55)
	arg_ca_52.menuItems = arg_ca_52:createMenuItems(arg_ca_54, arg_ca_55)

	arg_ca_52:refreshMenuItems(arg_ca_53, arg_ca_54)
end

function ClearAcademyDataState.selectedKeys(arg_ca_56, arg_ca_57, arg_ca_58)
	local var_ca_24 = {}
	local var_ca_25 = arg_ca_56.itemParams

	-- A user league can contain user clubs, and clearing the clubs would leave
	-- it broken, so Leagues always goes with Clubs.
	if var_ca_25.Clubs and not var_ca_25.Leagues and (arg_ca_56.counts.Clubs or 1) > 0 and (arg_ca_56.counts.Leagues or 1) > 0 then
		var_ca_24.LeaguesRequired = true
	end

	for iter_ca_15, iter_ca_16 in ipairs(ClearAcademyOrder) do
		if var_ca_25[iter_ca_16] or iter_ca_16 == "Leagues" and var_ca_24.LeaguesRequired then
			table.insert(var_ca_24, iter_ca_16)
		end
	end

	return var_ca_24
end

function ClearAcademyDataState.alert(arg_ca_59, arg_ca_60, arg_ca_61, arg_ca_62, arg_ca_63, arg_ca_64)
	arg_ca_59.alertOpen = true
	arg_ca_64.canCancel = arg_ca_64.canCancel ~= false
	arg_ca_64.input = arg_ca_63:getInput()

	local var_ca_26 = arg_ca_64.onSelected

	function arg_ca_64.onSelected(arg_ca_65, arg_ca_66, arg_ca_67, ...)
		arg_ca_59.alertOpen = false
		arg_ca_59.ignoreInputUntil = arg_ca_66 + 0.25

		if var_ca_26 then
			return var_ca_26(arg_ca_65, arg_ca_66, arg_ca_67, ...)
		end
	end

	arg_ca_62:blockingAlert(arg_ca_60, arg_ca_61, arg_ca_64)
end

function ClearAcademyDataState.confirmClear(arg_ca_68, arg_ca_69, arg_ca_70, arg_ca_71, arg_ca_72)
	local var_ca_27 = arg_ca_72.partyMember
	local var_ca_28 = arg_ca_68:selectedKeys(arg_ca_71, var_ca_27)

	if #var_ca_28 == 0 then
		arg_ca_68:alert(arg_ca_69, arg_ca_70, arg_ca_71, var_ca_27, {
			options = "ok",
			text = ClearAcademyLabels.noneSelected
		})

		return
	end

	local var_ca_29 = {
		ClearAcademyLabels.confirmHeader,
		""
	}

	for iter_ca_17, iter_ca_18 in ipairs(ClearAcademyCategories) do
		for iter_ca_19, iter_ca_20 in ipairs(var_ca_28) do
			if iter_ca_20 == iter_ca_18.key then
				local var_ca_30 = iter_ca_18.label
				local var_ca_31 = arg_ca_68.counts[iter_ca_18.key]

				if var_ca_31 then
					var_ca_30 = string.format("%s (%d)", var_ca_30, var_ca_31)
				end

				if iter_ca_20 == "Leagues" and var_ca_28.LeaguesRequired then
					var_ca_30 = var_ca_30 .. " " .. ClearAcademyLabels.leaguesRequired
				end

				table.insert(var_ca_29, var_ca_30)
			end
		end
	end

	if arg_ca_68.itemParams.Clubs and clearAcademyRankedClubId(var_ca_27) ~= native.INVALID_PLAYER_ID then
		table.insert(var_ca_29, "")
		table.insert(var_ca_29, ClearAcademyLabels.rankedKept)
	end

	table.insert(var_ca_29, "")
	table.insert(var_ca_29, ClearAcademyLabels.confirmFooter)
	arg_ca_68:alert(arg_ca_69, arg_ca_70, arg_ca_71, var_ca_27, {
		options = "noyes",
		yPos = 0.5,
		text = table.concat(var_ca_29, "\n"),
		onSelected = function(arg_ca_73, arg_ca_74, arg_ca_75)
			if arg_ca_75 and arg_ca_75.val then
				arg_ca_68:beginClear(arg_ca_69, arg_ca_74, arg_ca_71, arg_ca_72, var_ca_28)
			end
		end
	})
end

function ClearAcademyDataState.beginClear(arg_ca_76, arg_ca_77, arg_ca_78, arg_ca_79, arg_ca_80, arg_ca_81)
	local var_ca_32 = busy_layout.create(arg_ca_77, ClearAcademyLabels.busyTitle, clearAcademyStatusFor(arg_ca_81[1]))

	busy_layout.playEnter(var_ca_32, true)
	arg_ca_79:playSound("SelectLrg")

	arg_ca_76.busyArea = var_ca_32
	arg_ca_76.phase = "clearing"
	arg_ca_76.busyMinUntil = arg_ca_78 + 1.5
	arg_ca_76.clearCtx = {
		stepIndex = 1,
		playersKept = 0,
		failed = {},
		keys = arg_ca_81,
		engine = arg_ca_77,
		uiServices = arg_ca_79,
		partyMember = arg_ca_80.partyMember
	}
end

function ClearAcademyDataState.updateClearing(arg_ca_82, arg_ca_83, arg_ca_84, arg_ca_85, arg_ca_86, arg_ca_87)
	local var_ca_33 = arg_ca_82.busyArea
	local var_ca_34 = arg_ca_82.clearCtx

	var_ca_33:update(arg_ca_86)

	if arg_ca_82.area then
		arg_ca_82.area:update(arg_ca_86)
	end

	if arg_ca_82.phase == "clearing" then
		local var_ca_35 = var_ca_34.keys[var_ca_34.stepIndex]

		if var_ca_35 then
			busy_layout.setStatus(var_ca_33, clearAcademyStatusFor(var_ca_35))

			local var_ca_36, var_ca_37 = pcall(ClearAcademySteps[var_ca_35], var_ca_34)

			if not var_ca_36 then
				table.insert(var_ca_34.failed, clearAcademyLabelFor(var_ca_35))
			end

			if not var_ca_36 or var_ca_37 then
				var_ca_34.stepIndex = var_ca_34.stepIndex + 1
			end
		else
			busy_layout.setStatus(var_ca_33, ClearAcademyLabels.saving)
			arg_ca_87:profileSaveFull(var_ca_34.partyMember)

			arg_ca_82.phase = "saving"
		end
	elseif arg_ca_82.phase == "saving" then
		if arg_ca_85 >= arg_ca_82.busyMinUntil and not clearAcademySaveBusy(arg_ca_84, arg_ca_87) then
			arg_ca_82.busyExitAt = arg_ca_85 + busy_layout.playExit(var_ca_33)
			arg_ca_82.phase = "closing"
		end
	elseif arg_ca_82.phase == "closing" and arg_ca_85 >= arg_ca_82.busyExitAt then
		var_ca_33:dispose()

		arg_ca_82.busyArea = nil
		arg_ca_82.clearCtx = nil
		arg_ca_82.phase = "menu"

		for iter_ca_21, iter_ca_22 in ipairs(ClearAcademyCategories) do
			arg_ca_82.itemParams[iter_ca_22.key] = false
		end

		arg_ca_82.countsDirty = true

		arg_ca_82:rebuildMenu(arg_ca_84, arg_ca_87, var_ca_34.partyMember)

		local var_ca_38 = {
			ClearAcademyLabels.done
		}

		if var_ca_34.playersKept > 0 then
			table.insert(var_ca_38, string.format(ClearAcademyLabels.playersKept, var_ca_34.playersKept))
		end

		if #var_ca_34.failed > 0 then
			table.insert(var_ca_38, string.format(ClearAcademyLabels.failed, table.concat(var_ca_34.failed, ", ")))
		end

		arg_ca_82:alert(arg_ca_84, arg_ca_85, arg_ca_87, var_ca_34.partyMember, {
			options = "ok",
			text = table.concat(var_ca_38, "\n\n")
		})
	end
end

function ClearAcademyDataState.update(arg_ca_89, arg_ca_90, arg_ca_91, arg_ca_92, arg_ca_93, arg_ca_94, arg_ca_95, arg_ca_96, arg_ca_97)
	if arg_ca_89.errorExited then
		return
	end

	local var_ca_202, var_ca_203 = xpcall(function()
		return arg_ca_89:updateInner(arg_ca_90, arg_ca_91, arg_ca_92, arg_ca_93, arg_ca_94, arg_ca_95, arg_ca_96, arg_ca_97)
	end, clearAcademyTraceback)

	if not var_ca_202 then
		-- Never soft-lock the UI: log the error and back out to the home screen.
		clearAcademyLogError("update error (phase " .. tostring(arg_ca_89.phase) .. "): " .. tostring(var_ca_203))

		arg_ca_89.errorExited = true

		local var_ca_204, var_ca_205 = pcall(arg_ca_90.changeState, arg_ca_90, nil, arg_ca_91, arg_ca_92, arg_ca_94, arg_ca_95, arg_ca_97)

		if not var_ca_204 then
			clearAcademyLogError("exit after error failed: " .. tostring(var_ca_205))
		end
	end
end

function ClearAcademyDataState.updateInner(arg_ca_89, arg_ca_90, arg_ca_91, arg_ca_92, arg_ca_93, arg_ca_94, arg_ca_95, arg_ca_96, arg_ca_97)
	if arg_ca_89.phase ~= "menu" then
		arg_ca_89:updateClearing(arg_ca_90, arg_ca_91, arg_ca_92, arg_ca_93, arg_ca_95)

		return
	end

	local var_ca_39 = arg_ca_97.partyMember
	local var_ca_40, var_ca_41, var_ca_42, var_ca_43 = var_0_9.update(arg_ca_89, arg_ca_91, arg_ca_92, arg_ca_93, arg_ca_94, arg_ca_95, arg_ca_96, var_ca_39:getInput())

	if arg_ca_89.alertOpen or arg_ca_95:getIsBlockingMixinActive() or arg_ca_89.ignoreInputUntil and arg_ca_92 < arg_ca_89.ignoreInputUntil then
		return
	end

	arg_ca_95:addTooltip(arg_ca_89.tooltipsWidget, var_0_12, var_0_5, 99)

	local var_ca_44 = var_ca_43 and var_ca_43.clearAcademyAction

	if var_ca_44 == "selectAll" then
		local var_ca_45 = not arg_ca_89:allSelected()

		for iter_ca_23, iter_ca_24 in ipairs(ClearAcademyCategories) do
			arg_ca_89.itemParams[iter_ca_24.key] = var_ca_45
		end

		arg_ca_95:playSound("SelectSmall")
		arg_ca_89:rebuildMenu(arg_ca_91, arg_ca_95, var_ca_39)
	elseif var_ca_44 == "clear" then
		arg_ca_89:confirmClear(arg_ca_91, arg_ca_92, arg_ca_95, arg_ca_97)
	elseif var_ca_42 then
		-- A toggle changed: keep the Select All / Deselect All label in step.
		arg_ca_89:rebuildMenu(arg_ca_91, arg_ca_95, var_ca_39)
	elseif arg_ca_89:acceptFlipsToggle(arg_ca_95, var_ca_39) then
		arg_ca_89:rebuildMenu(arg_ca_91, arg_ca_95, var_ca_39)
	elseif arg_ca_95:checkForRelease(var_ca_39, var_0_12) then
		arg_ca_95:playSound("Back")
		arg_ca_90:changeState(nil, arg_ca_91, arg_ca_92, arg_ca_94, arg_ca_95, arg_ca_97)
	end
end

-- Stock toggles only react to left/right; let Accept flip them too.
function ClearAcademyDataState.acceptFlipsToggle(arg_ca_206, arg_ca_207, arg_ca_208)
	local var_ca_206 = arg_ca_206:getHighlightedItemInfo()

	if not var_ca_206 or var_ca_206.editType ~= optionmenu_aide.EditTypes.Toggle or not var_ca_206.key then
		return false
	end

	if not arg_ca_207:checkForRelease(arg_ca_208, var_0_11) then
		return false
	end

	arg_ca_206.itemParams[var_ca_206.key] = not arg_ca_206.itemParams[var_ca_206.key]

	arg_ca_207:playSound("ScrollSmall")

	return true
end

function ClearAcademyDataState.render(arg_ca_98, arg_ca_99, arg_ca_100, arg_ca_101, arg_ca_102, arg_ca_103)
	var_0_9.render(arg_ca_98, arg_ca_99, arg_ca_100, arg_ca_101, arg_ca_102)

	if arg_ca_98.busyArea then
		arg_ca_98.busyArea:doRender(arg_ca_99, arg_ca_102)
	end
end

function ClearAcademyDataState.exit(arg_ca_104, arg_ca_105, arg_ca_106, arg_ca_107, arg_ca_108, arg_ca_109)
	if arg_ca_104.busyArea then
		arg_ca_104.busyArea:dispose()

		arg_ca_104.busyArea = nil
	end

	var_0_9.exit(arg_ca_104, arg_ca_105, arg_ca_106, arg_ca_107, arg_ca_108, arg_ca_109)
end

-- Home screen hook. homescreen_state.lua is owned by allow-exit-any-menu-tab,
-- so HomeScreenState.update is wrapped instead of overridden. This file is
-- imported (via homescreenstate_config) before homescreen_state runs
-- Class("HomeScreenState"), and Class() reuses an existing _G._CLASSES entry,
-- so a __newindex trap on that entry wraps update when it is defined.

local ClearAcademyLastHookError

local function clearAcademyIsAcademyTile(arg_ca_110, arg_ca_111)
	local var_ca_46 = arg_ca_110.homescreenTilesData
	local var_ca_47 = var_ca_46 and var_ca_46.tilesRows and var_ca_46.tilesRows.Academy

	if not var_ca_47 then
		return false
	end

	for iter_ca_25, iter_ca_26 in ipairs(var_ca_47) do
		if iter_ca_26 == arg_ca_111 or iter_ca_26.dataContextKey ~= nil and iter_ca_26.dataContextKey == arg_ca_111.dataContextKey then
			return true
		end
	end

	return false
end

-- The plain checkForRelease(partyMember, Y) never fired on the Noesis home
-- screen in game, so Y is read three ways (release via party member, release
-- via its input, and a down->up edge from checkForDown) and the log records
-- which one works.
local function clearAcademyYPressed(arg_ca_220, arg_ca_221)
	local var_ca_220 = native.InputTypes.Y
	local var_ca_221 = arg_ca_220.partyMember
	local var_ca_222 = clearAcademySafe(function()
		return var_ca_221:getInput()
	end)

	if not arg_ca_220.clearAcademyLoggedRow then
		arg_ca_220.clearAcademyLoggedRow = true

		clearAcademyLog("hook active on Academy row (input object: " .. tostring(var_ca_222 ~= nil) .. ")")
	end

	local var_ca_223 = clearAcademySafe(function()
		return arg_ca_221:checkForRelease(var_ca_221, var_ca_220)
	end) and true or false
	local var_ca_224 = var_ca_222 and clearAcademySafe(function()
		return arg_ca_221:checkForRelease(var_ca_222, var_ca_220)
	end) and true or false
	local var_ca_225 = clearAcademySafe(function()
		return arg_ca_221:checkForDown(var_ca_221, var_ca_220)
	end) and true or false
	local var_ca_226 = arg_ca_220.clearAcademyYWasDown and not var_ca_225

	if var_ca_225 ~= (arg_ca_220.clearAcademyYWasDown or false) then
		clearAcademyLog("Y down state: " .. tostring(var_ca_225))
	end

	arg_ca_220.clearAcademyYWasDown = var_ca_225

	if var_ca_223 or var_ca_224 or var_ca_226 then
		clearAcademyLog(string.format("Y detected: releasePartyMember=%s releaseInput=%s downEdge=%s", tostring(var_ca_223), tostring(var_ca_224), tostring(var_ca_226)))

		arg_ca_220.clearAcademyYWasDown = false

		return true
	end

	return false
end

local function clearAcademyHomeScreenHook(arg_ca_112, arg_ca_113, arg_ca_114, arg_ca_115, arg_ca_116, arg_ca_117)
	if native.standalone or not arg_ca_112.scanComplete or not arg_ca_112.partyMember then
		return false
	end

	local var_ca_48 = arg_ca_112.viewModel

	if not var_ca_48 or var_ca_48.subMenuOpen or arg_ca_112.subMenuOpen or not var_ca_48.getHighlightedTile then
		return false
	end

	if arg_ca_117:getIsBlockingMixinActive() or not arg_ca_117:getInputAllowed() then
		return false
	end

	local var_ca_49 = var_ca_48:getHighlightedTile()

	if not var_ca_49 or not clearAcademyIsAcademyTile(arg_ca_112, var_ca_49) then
		return false
	end

	arg_ca_117:addTooltip(arg_ca_112.tooltipsWidget, native.InputTypes.Y, ClearAcademyLabels.open, 3)

	if not clearAcademyYPressed(arg_ca_112, arg_ca_117) then
		return false
	end

	-- Front-end classes live in TEMP_CLASSES, not _CLASSES, so take the
	-- factory from the Academy row tiles (they all open AcademyState).
	local var_ca_51

	for iter_ca_30, iter_ca_31 in ipairs(arg_ca_112.homescreenTilesData.tilesRows.Academy) do
		local var_ca_52 = iter_ca_31.stateFactory

		if type(var_ca_52) == "table" and var_ca_52.__type == "AcademyState" then
			var_ca_51 = var_ca_52

			break
		end
	end

	if not var_ca_51 then
		local var_ca_53 = rawget(_G, "TEMP_CLASSES")
		local var_ca_54 = rawget(_G, "_CLASSES")

		var_ca_51 = var_ca_53 and var_ca_53.AcademyState or var_ca_54 and var_ca_54.AcademyState
	end

	if not var_ca_51 then
		clearAcademyLogError("Y pressed but AcademyState class not found")

		return false
	end

	clearAcademyLog("Y pressed on Academy row: opening Clear Academy Data")
	arg_ca_117:playSound("SelectLrg")
	arg_ca_113:changeState(var_ca_51(), arg_ca_114, arg_ca_115, arg_ca_116, arg_ca_117, arg_ca_112.partyMember, {
		nextState = ClearAcademyDataState,
		goBackStack = gobackstack.GoBackStack()
	})

	return true
end

local function clearAcademyWrapUpdate(arg_ca_118)
	return function(arg_ca_119, arg_ca_120, arg_ca_121, arg_ca_122, arg_ca_123, arg_ca_124, arg_ca_125, ...)
		local var_ca_52, var_ca_53 = xpcall(function()
			return clearAcademyHomeScreenHook(arg_ca_119, arg_ca_120, arg_ca_121, arg_ca_122, arg_ca_124, arg_ca_125)
		end, clearAcademyTraceback)

		if not var_ca_52 then
			local var_ca_210 = tostring(var_ca_53)

			if var_ca_210 ~= ClearAcademyLastHookError then
				ClearAcademyLastHookError = var_ca_210

				clearAcademyLogError("home hook error: " .. var_ca_210)
			end
		elseif var_ca_53 then
			return
		end

		return arg_ca_118(arg_ca_119, arg_ca_120, arg_ca_121, arg_ca_122, arg_ca_123, arg_ca_124, arg_ca_125, ...)
	end
end

local function clearAcademyInstallHomeHook()
	local var_ca_54 = rawget(_G, "_CLASSES")

	if type(var_ca_54) ~= "table" then
		return
	end

	local var_ca_55 = var_ca_54.HomeScreenState

	if var_ca_55 == nil then
		var_ca_55 = {}
		var_ca_54.HomeScreenState = var_ca_55
	end

	local var_ca_56 = rawget(var_ca_55, "update")

	if type(var_ca_56) == "function" then
		if rawget(var_ca_55, "__clearAcademyWrapper") ~= var_ca_56 then
			local var_ca_59 = clearAcademyWrapUpdate(var_ca_56)

			rawset(var_ca_55, "__clearAcademyWrapper", var_ca_59)
			rawset(var_ca_55, "update", var_ca_59)
		end

		return
	end

	local var_ca_57 = getmetatable(var_ca_55) or {}

	if rawget(var_ca_57, "__clearAcademyTrap") then
		return
	end

	rawset(var_ca_57, "__clearAcademyTrap", true)

	local var_ca_58 = var_ca_57.__newindex

	function var_ca_57.__newindex(arg_ca_126, arg_ca_127, arg_ca_128)
		if arg_ca_127 == "update" and type(arg_ca_128) == "function" and rawget(arg_ca_126, "__clearAcademyWrapper") ~= arg_ca_128 then
			arg_ca_128 = clearAcademyWrapUpdate(arg_ca_128)

			rawset(arg_ca_126, "__clearAcademyWrapper", arg_ca_128)
		end

		if type(var_ca_58) == "function" then
			var_ca_58(arg_ca_126, arg_ca_127, arg_ca_128)
		elseif type(var_ca_58) == "table" then
			var_ca_58[arg_ca_127] = arg_ca_128
		else
			rawset(arg_ca_126, arg_ca_127, arg_ca_128)
		end
	end

	setmetatable(var_ca_55, var_ca_57)
end

clearAcademyInstallHomeHook()
