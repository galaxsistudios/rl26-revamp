import("app.noesis.ns")
import("app.noesis.ns_viewmodel")
import("app.noesis.ns_observablecollection")
import("app.noesis.homescreen.nvm_promo_banner")
import("uicore.uiutil")
import("script-config.game.metrics.metrics_config")

local var_0_0 = ns_viewmodel.ViewModel
local var_0_1 = ns_observablecollection.ObservableCollection
local var_0_2 = nvm_promo_banner.HomescreenBannerNVM
local var_0_3 = native.CIsActiveWrapperCommand

local function var_0_4(arg_1_0, arg_1_1)
	arg_1_0.selectedItem = {
		stateFactory = arg_1_1.stateFactory,
		stateData = arg_1_1.stateData,
		academy = arg_1_1.isAcademy,
		new = arg_1_1.new,
		career = arg_1_1.career,
		competition = arg_1_1.competition,
		requiresUGCPrivileges = arg_1_1.requiresUGCPrivileges
	}
end

local function var_0_5(arg_2_0)
	return not arg_2_0.locked
end

local function var_0_6(arg_3_0, arg_3_1, arg_3_2, arg_3_3)
	local var_3_0 = native.paNVMSubButton()

	var_3_0:setTitleString(arg_3_1.title)

	if arg_3_1.description then
		var_3_0:setToolTipString(arg_3_1.description)
	end

	local var_3_1 = arg_3_2.stateFactory or arg_3_1.stateFactory
	local var_3_2 = {
		stateFactory = var_3_1,
		stateData = arg_3_1.stateData,
		new = arg_3_1.new,
		career = arg_3_1.career,
		competition = arg_3_1.competition
	}

	if arg_3_1.checkLockFn then
		arg_3_1.locked = arg_3_1.checkLockFn(arg_3_3)
	end

	var_3_0:bindCommand(function()
		return var_0_5(arg_3_1)
	end, function()
		var_0_4(arg_3_0, var_3_2)
	end, function()
		return true
	end)

	return var_3_0
end

local function var_0_7(arg_7_0, arg_7_1, arg_7_2, arg_7_3)
	for iter_7_0, iter_7_1 in ipairs(arg_7_3.subMenu) do
		local var_7_0 = var_0_6(arg_7_0, iter_7_1, arg_7_3, arg_7_1)

		arg_7_2:addSubButton(var_7_0)
	end
end

local function var_0_8(arg_8_0, arg_8_1, arg_8_2, arg_8_3)
	for iter_8_0, iter_8_1 in ipairs(arg_8_3.subMenu) do
		if iter_8_1.isSaveFile then
			local var_8_0 = var_0_6(arg_8_0, iter_8_1, arg_8_3, arg_8_1)

			arg_8_2:addSubButtonAtIndex(var_8_0, arg_8_2:subMenuCount())
		end
	end
end

ns.Class("MainNVM", var_0_0, function(arg_9_0)
	var_0_0.init(arg_9_0)
end).Bindings = {
	Properties = {
		Casual = ns.typeOf(native.paNVMButton),
		RLWC2026 = ns.typeOf(native.paNVMButton),
		Finals = ns.typeOf(native.paNVMButton),
		Online = ns.typeOf(native.paNVMButton),
		Career = ns.typeOf(native.paNVMButton),
		ProTeam = ns.typeOf(native.paNVMButton),
		CommsTasks = ns.typeOf(native.paNVMButton)
	}
}
ns.Class("CompetitionsNVM", var_0_0, function(arg_10_0, arg_10_1, arg_10_2, arg_10_3, arg_10_4)
	var_0_0.init(arg_10_0)
end).Bindings = {
	Properties = {
		NRL = ns.typeOf(native.paNVMAccordionButton),
		SuperLeague = ns.typeOf(native.paNVMAccordionButton),
		NRLW = ns.typeOf(native.paNVMAccordionButton),
		WSL = ns.typeOf(native.paNVMAccordionButton),
		CompetitionHub = ns.typeOf(native.paNVMAccordionButton)
	}
}
ns.Class("AcademyNVM", var_0_0, function(arg_11_0, arg_11_1, arg_11_2, arg_11_3, arg_11_4)
	var_0_0.init(arg_11_0)
end).Bindings = {
	Properties = {
		Players = ns.typeOf(native.paNVMButton),
		Clubs = ns.typeOf(native.paNVMButton),
		CustomDifficulties = ns.typeOf(native.paNVMButton),
		MatchTypeCreator = ns.typeOf(native.paNVMButton),
		Referees = ns.typeOf(native.paNVMButton),
		Decal = ns.typeOf(native.paNVMButton),
		stadium = ns.typeOf(native.paNVMButton),
		Community = ns.typeOf(native.paNVMButton),
		League = ns.typeOf(native.paNVMButton),
		Academy = ns.typeOf(native.paNVMButton),
		Designer = ns.typeOf(native.paNVMButton)
	}
}
ns.Class("ExtraNVM", var_0_0, function(arg_12_0, arg_12_1, arg_12_2, arg_12_3, arg_12_4)
	var_0_0.init(arg_12_0)
end).Bindings = {
	Properties = {
		Settings = ns.typeOf(native.paNVMAccordionButton),
		Practice = ns.typeOf(native.paNVMButton),
		Credits = ns.typeOf(native.paNVMButton),
		NTS = ns.typeOf(native.paNVMButton)
	}
}
ns.Class("NVMHomeScreen", var_0_0, function(arg_13_0, arg_13_1, arg_13_2)
	var_0_0.init(arg_13_0)

	arg_13_0.Main = MainNVM()
	arg_13_0.Competition = CompetitionsNVM()
	arg_13_0.Academy = AcademyNVM()
	arg_13_0.Extra = ExtraNVM()

	for iter_13_0, iter_13_1 in pairs(arg_13_1) do
		for iter_13_2, iter_13_3 in ipairs(iter_13_1) do
			local var_13_0

			if iter_13_3.subMenu then
				var_13_0 = native.paNVMAccordionButton()

				var_13_0:bindCommand(function()
					return arg_13_0:setHighlightedTile(iter_13_3)
				end, function()
					arg_13_0:setSubMenu(true)
				end, function()
					arg_13_0:setSubMenu(false)
				end)
				var_0_7(arg_13_0, arg_13_2, var_13_0, iter_13_3)
			else
				var_13_0 = native.paNVMButton()

				var_13_0:bindCommand(function()
					return var_0_5(iter_13_3)
				end, function()
					return var_0_4(arg_13_0, iter_13_3)
				end, function()
					arg_13_0:setHighlightedTile(iter_13_3)
				end)
			end

			var_13_0:setTitleString(iter_13_3.title)
			var_13_0:setNavigationTag(iter_13_3.autoNavKey or iter_13_3.dataContextKey)
			var_13_0:setToolTipString(iter_13_3.description or "NO DESCRIPTION FIX ME")

			arg_13_0[iter_13_1.dataContextKey][iter_13_3.dataContextKey] = var_13_0
		end
	end

	arg_13_0.tabs = {
		arg_13_0.Main,
		arg_13_0.Competition,
		arg_13_0.Academy,
		arg_13_0.Extra
	}
	arg_13_0.TabIndex = arg_13_2:getCurrentTabIndex() or 0
	arg_13_0.FocusElementIdentifier = arg_13_2:getHighlightTitle() or "casual"
	arg_13_0.ForceElementFocus = true
	arg_13_0.subMenuOpen = false
	arg_13_0.Submission = native.precert or native.publicfacing
	arg_13_0.promotionalBanners = {}
	arg_13_0.BannerItemsSource = var_0_1()
	arg_13_0.BannerIndex = 0
	arg_13_0.MenuBannerStoryboardCompleteCommand = native.CIsActiveWrapperCommand(native.CLuaDelegateCommand(function()
		return arg_13_0:changeMenuBanner(1)
	end))
end).Bindings = {
	Properties = {
		Main = ns.typeOf(MainNVM),
		Competition = ns.typeOf(CompetitionsNVM),
		Academy = ns.typeOf(AcademyNVM),
		Extra = ns.typeOf(ExtraNVM),
		TabIndex = ns.Int8,
		subMenuOpen = ns.Bool,
		FocusKey = ns.String,
		Description = ns.String,
		FocusElementIdentifier = ns.String,
		FoundElement = ns.Bool,
		ForceStoryboardReset = ns.Bool,
		ForceElementFocus = ns.Bool,
		Submission = ns.Bool,
		BannerItemsSource = ns.typeOf(var_0_1),
		BannerIndex = ns.Int8,
		HomescreenBanner = ns.typeOf(var_0_2),
		MenuBannerStoryboardCompleteCommand = var_0_3.nsType()
	}
}

function NVMHomeScreen.setHighlightedTile(arg_21_0, arg_21_1)
	arg_21_0.Description = arg_21_1.description
	arg_21_0.highlightedTile = arg_21_1
end

function NVMHomeScreen.getHighlightedTile(arg_22_0)
	return arg_22_0.highlightedTile
end

function NVMHomeScreen.setSubMenu(arg_23_0, arg_23_1)
	arg_23_0.subMenuOpen = arg_23_1
end

function NVMHomeScreen.populateSubMenuWithSaves(arg_24_0, arg_24_1, arg_24_2, arg_24_3)
	for iter_24_0, iter_24_1 in ipairs(arg_24_3) do
		local var_24_0 = arg_24_2[iter_24_0]
		local var_24_1 = arg_24_0[iter_24_1][var_24_0.dataContextKey]

		if var_24_0.subMenu and (#var_24_0.subMenu ~= var_24_1:subMenuCount() or var_24_1:subMenuCount() < 5) then
			var_0_8(arg_24_0, arg_24_1, var_24_1, var_24_0)
		end
	end
end

function NVMHomeScreen.removeSavesFromTile(arg_25_0, arg_25_1, arg_25_2)
	for iter_25_0, iter_25_1 in ipairs(arg_25_2) do
		local var_25_0 = arg_25_1[iter_25_0]
		local var_25_1 = var_25_0.dataContextKey
		local var_25_2 = arg_25_0[iter_25_1][var_25_0.dataContextKey]
		local var_25_3 = var_25_1 == "RLWC2026" and 3 or 2

		if var_25_2.subMenuCount then
			if var_25_2:subMenuCount() ~= var_25_3 then
				local var_25_4 = var_25_1 == "RLWC2026" and 3 or 2

				var_25_2:removeRange(var_25_4, var_25_2:subMenuCount())
			end

			var_25_0.subMenu[#var_25_0.subMenu].locked = true
		end
	end
end

function NVMHomeScreen.hasBannerViewModels(arg_26_0)
	return #arg_26_0.promotionalBanners > 0
end

function NVMHomeScreen.addBannerToCollection(arg_27_0, arg_27_1, arg_27_2)
	local var_27_0 = var_0_2(arg_27_1, arg_27_2)

	table.insert(arg_27_0.promotionalBanners, var_27_0)
	arg_27_0.BannerItemsSource:addComponent(var_27_0)
end

function NVMHomeScreen.clearBanners(arg_28_0, arg_28_1)
	arg_28_0.promotionalBanners = {}

	arg_28_0.BannerItemsSource:dispose()

	arg_28_0.BannerIndex = -1
	arg_28_0.HomescreenBanner = nil
end

function NVMHomeScreen.setChosenBanner(arg_29_0, arg_29_1)
	local var_29_0 = arg_29_0.promotionalBanners

	assert(arg_29_1 <= #var_29_0)

	arg_29_0.BannerIndex = arg_29_1 - 1
	arg_29_0.HomescreenBanner = var_29_0[arg_29_1]
end

function NVMHomeScreen.changeMenuBanner(arg_30_0, arg_30_1)
	local var_30_0 = #arg_30_0.promotionalBanners
	local var_30_1 = arg_30_0.BannerIndex + 1

	if var_30_0 == 0 then
		arg_30_0.BannerIndex = -1
		arg_30_0.HomescreenBanner = nil

		return
	elseif var_30_0 == 1 then
		return
	end

	local var_30_2 = var_30_1 + arg_30_1

	if var_30_0 < var_30_2 then
		var_30_2 = 1
	elseif var_30_2 < 1 then
		var_30_2 = var_30_0
	end

	arg_30_0:setChosenBanner(var_30_2)
end

function NVMHomeScreen.update(arg_31_0, arg_31_1, arg_31_2, arg_31_3, arg_31_4)
	if arg_31_0.HomescreenBanner then
		arg_31_0.HomescreenBanner:update(arg_31_1, arg_31_3)
	end

	local var_31_0 = arg_31_1:getGameControlManager()
	local var_31_1 = arg_31_4:checkForRepeatingInput(arg_31_2, var_31_0, native.InputTypes.RJoyLeft)
	local var_31_2 = arg_31_4:checkForRepeatingInput(arg_31_2, var_31_0, native.InputTypes.RJoyRight)

	arg_31_0.ForceStoryboardReset = false

	if var_31_1 or var_31_2 and #arg_31_0.promotionalBanners > 0 then
		local var_31_3 = var_31_1 and -1 or 1

		arg_31_0.ForceStoryboardReset = true

		local var_31_4 = uiutil.wrapIndex(arg_31_0.BannerIndex + 1 + var_31_3, 1, #arg_31_0.promotionalBanners)

		arg_31_0:setChosenBanner(var_31_4)
		native.Metrics.addMetricData(metrics_config.PromoBannerScroll)
	end

	if arg_31_0.selectedItem then
		return true, arg_31_0.selectedItem
	end
end

function NVMHomeScreen.dispose(arg_32_0)
	arg_32_0.HomescreenBanner = nil
	arg_32_0.promotionalBanners = {}

	arg_32_0.BannerItemsSource:dispose()

	if arg_32_0.tabs then
		arg_32_0.tabs = nil
	end

	var_0_0.dispose(arg_32_0)
end

-- player-import-export mod: Import Player / Import Players / Export Players
-- rows at the bottom of the home screen's Players submenu, and Export Teams at
-- the bottom of the Clubs submenu. homescreen_state imports
-- homescreenstate_config (owned by coach-editor) right before this file, so
-- the config is fully loaded here. Its tiles are shared tables that
-- HomeScreenState deep-clones on every visit, so adding the rows once is
-- enough. The states live in app/player/player_viewstate_hub_state.lua and
-- app/club/club_view_state.lua.
local function playerTransferAddRows(tiles, key, marker, rows)
	for _, tile in ipairs(tiles.tilesRows.Academy) do
		if tile.dataContextKey == key and type(tile.subMenu) == "table" then
			for _, row in ipairs(tile.subMenu) do
				if row[marker] then
					return
				end
			end

			for _, row in ipairs(rows) do
				table.insert(tile.subMenu, row)
			end

			return
		end
	end

	error("no " .. key .. " tile on the Academy row")
end

local function playerTransferAddMenuRows()
	import("app.homescreen.homescreenstate_config")
	import("app.player.player_viewstate_hub_state")
	import("app.club.club_view_state")

	local tiles = homescreenstate_config.createFirstPageTiles()

	playerTransferAddRows(tiles, "Players", "playerTransferRow", player_viewstate_hub_state.PlayerTransfer.menuRows())
	playerTransferAddRows(tiles, "Clubs", "teamTransferRow", club_view_state.TeamTransfer.menuRows())
end

local playerTransferOk, playerTransferErr = pcall(playerTransferAddMenuRows)

if not playerTransferOk then
	pcall(function()
		local file = io.open("playertransfer_debug.txt", "a")

		if file then
			file:write(os.date("%Y-%m-%d %H:%M:%S ") .. "adding Players menu rows failed: " .. tostring(playerTransferErr) .. "\n")
			file:close()
		end
	end)
end
