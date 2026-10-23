import("core.foundation.func")
import("core.foundation.stringx")
import("app.save.compresssavedata_state")
import("app.standalone.standalonehomescreen_state")
import("base.ui.util.gobackstack")
import("app.sharing.sharing_updatedatabase")
import("app.homescreen.homescreenstate_config")
import("app.noesis.homescreen.nvm_homescreen")
import("core.foundation.deepclone")
import("core.foundation.tablex")
import("app.signin.signinmixin_loadsaves")
import("app.sharing.sharing_gate_aide")
import("uicore.uiutil")
import("app.dynasty.dynasty_state")
import("script-config.game.metrics.metrics_config")

local var_0_0 = native.getEnvironment():argExists("testconfig")
local var_0_1 = native.InputTypes
local var_0_2 = PLATFORM_PC
local var_0_3 = native.isDebuggerAttached()

Class("HomeScreenState")

function HomeScreenState.enter(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7, arg_1_8, arg_1_9)
	arg_1_5:sharingKickNagVersion(arg_1_2, arg_1_6)
	arg_1_5:setBackgroundVisual("main")

	arg_1_0.homescreenConfig = tablex.clone(homescreenstate_config)

	local var_1_0 = arg_1_2:getParty()

	var_1_0:setLeadPartyMember(arg_1_6)
	var_1_0:setRequireLeadPartyMember(true)

	local var_1_1 = arg_1_6.serverMatch
	local var_1_2 = var_1_1.hasPendingReport

	arg_1_0.commsTaskIds = {}

	if var_1_2 and var_1_1.gameMode == native.EGameMode.Online then
		arg_1_0:kickOffPostMatch(arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, var_1_1, arg_1_6)
	end

	if arg_1_4.standalone then
		arg_1_1:changeState(standalonehomescreen_state.StandaloneHomeScreenState(), arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7, arg_1_8, arg_1_9)

		return
	end

	arg_1_0.partyMember = arg_1_6

	arg_1_5:titleSetAreaOfGame("home", "ProductName")
	arg_1_5:titleSetSubAreaOfGame()
	arg_1_5:getRenderer():setActiveLightingMode("academy")

	local var_1_3 = deepclone.deepCloneTable(arg_1_0.homescreenConfig.createFirstPageTiles(arg_1_5))

	arg_1_0.homescreenTilesData = var_1_3

	if arg_1_4.autoNavTo and not arg_1_7 then
		local var_1_4, var_1_5 = func.find(function(arg_2_0, arg_2_1)
			return arg_2_1.autoNavKey == arg_1_4.autoNavTo
		end, ipairs(var_1_3))

		if var_1_5 then
			arg_1_1:changeState(var_1_5.stateFactory(), arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, var_1_5.stateData)

			return
		end

		ASSERT(false, debugFormat("no such auto nav key: %s", arg_1_4.autoNavTo))
	end

	function arg_1_0.setHighlightTile(arg_3_0)
		arg_1_5:setHighlightTitle(arg_3_0)
	end

	arg_1_0:setScanTasks(arg_1_2, arg_1_3, arg_1_5, arg_1_6)

	arg_1_0.scanResults = {}

	if PLATFORM_PS5 then
		local var_1_6 = arg_1_2:getUniversalDataSystem()

		var_1_6:setCanLaunchActivity(true)

		if var_1_6.activityIntentId == "" then
			var_1_6:clearCurrentActivity()
		end

		local var_1_7 = arg_1_2:getParty():getPrimaryPartyMember()
		local var_1_8 = var_1_7 and var_1_7:getControllerInfo()

		var_1_6:enableAllActivities(var_1_8)
	end

	arg_1_0:createMenu(arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_7, arg_1_8, arg_1_9)
	arg_1_5:getMenuBannersFromServer(arg_1_2, arg_1_5, arg_1_6, arg_1_0.commsTaskIds)
	arg_1_2:getNetworkService():getRichPresenceController():setPresenceForAll("RichPresence_MainMenu")

	arg_1_0.databaseVersionLocal = native.getLocalBinaryFileVersion(arg_1_2, "defaultdata/playerdatabase_version.bin")
	arg_1_0.loadedImages = {}

	function arg_1_5.refreshBannerViewModels(arg_4_0, ...)
		return arg_1_0:refreshBannerViewModels(...)
	end
end

function HomeScreenState.exit(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4)
	arg_5_0:destroyMenu()

	if arg_5_0.dialogTask then
		arg_5_0.dialogTask:dispose()

		arg_5_0.dialogTask = nil
	end

	arg_5_4.cancelCommsTasks(arg_5_0.commsTaskIds)
end

function HomeScreenState.update(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7)
	local var_6_0 = arg_6_0.partyMember

	if not arg_6_0.scanComplete then
		arg_6_0:updateScanning(arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7)

		arg_6_0.view.userInputEnabled = false

		if arg_6_0.scanComplete then
			arg_6_0.view.userInputEnabled = true
		end

		return
	end

	if arg_6_6:updateBlockingMixins(arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_7) then
		if arg_6_0.view then
			arg_6_0.view.userInputEnabled = false
		end

		return
	else
		arg_6_0.view.userInputEnabled = true
	end

	if arg_6_6:sharingUpdateNagVersion(arg_6_2, arg_6_3, arg_6_4) then
		var_6_0.checkedNagVersion = true
	end

	if arg_6_0.dialogTask and arg_6_0.dialogTask:update(arg_6_4) then
		arg_6_0.dialogTask:dispose()

		arg_6_0.dialogTask = nil
	end

	local var_6_1 = arg_6_6:sharingGetWelcomeInfo()

	if var_6_1 and var_6_1.data_requested and not var_6_0.dataRequestedThisSession then
		arg_6_1:changeState(compresssavedata_state.CompressSaveDataPromptState(), arg_6_2, arg_6_3, arg_6_5, arg_6_6, {
			uploadToServer = true,
			partyMember = var_6_0
		})

		var_6_0.dataRequestedThisSession = true

		return
	end

	if var_0_3 then
		arg_6_6:addTooltip(arg_6_0.tooltipsWidget, native.InputTypes.Start, native.Localise("CompressSaveData"), 999)

		if arg_6_6:checkForRelease(var_6_0, native.InputTypes.Start) then
			arg_6_6:playSound("sfxDynastyListReorderCards")
			arg_6_1:changeState(compresssavedata_state.CompressSaveDataState(), arg_6_2, arg_6_3, arg_6_5, arg_6_6, {
				uploadToServer = false,
				partyMember = var_6_0
			})

			return
		end
	end

	local var_6_2 = arg_6_0.viewModel

	if var_6_2 then
		if not arg_6_0.allImagesLoaded then
			arg_6_0:updateBannerViewModelLoading(arg_6_2, arg_6_6)
		end

		local var_6_3 = var_6_2.subMenuOpen

		arg_6_6:addTooltip(arg_6_0.tooltipsWidget, var_0_1.Accept, native.Localise("Select"), 1)

		local var_6_4, var_6_5 = var_6_2:update(arg_6_2, arg_6_3, arg_6_4, var_6_0)

		ASSERT(var_6_2.getHighlightedTile)

		local var_6_6 = var_6_2:getHighlightedTile()

		if not var_6_4 and (arg_6_6:getIsBlockingMixinActive() or arg_6_0.lastHighlightedTile ~= var_6_6) or arg_6_0.viewModel.subMenuOpen then
			arg_6_0.lastHighlightedTile = var_6_6

			arg_6_6:setHighlightTitle(var_6_6.dataContextKey)
			arg_6_6:setCurrentTabIndex(arg_6_0.viewModel.TabIndex)

			if not var_6_3 then
				arg_6_6:setBackgroundText(var_6_6.title)
			else
				arg_6_6:addTooltip(arg_6_0.tooltipsWidget, var_0_1.Decline, native.Localise("Back"), 2)
			end
		end

		if var_6_3 ~= arg_6_0.subMenuOpen then
			arg_6_0.canExitGameTimer = 0
			arg_6_0.subMenuOpen = arg_6_0.viewModel.subMenuOpen

			if arg_6_0.subMenuOpen then
				if var_6_6.scanTasksOnSubmenuOpen then
					if arg_6_0.skipSubMenuSaveScan then
						arg_6_0.skipSubMenuSaveScan = false
					else
						arg_6_0:clearSavesFromSubMenu(var_6_6)
						arg_6_0:setScanTasks(arg_6_2, arg_6_3, arg_6_6, var_6_0, var_6_6.scanTasksOnSubmenuOpen)

						if type(var_6_6.competitionId) ~= "number" then
							local var_6_7 = arg_6_0.scanResults and arg_6_0.scanResults.Competition

							var_6_6.subMenu[#var_6_6.subMenu].locked = var_6_7 and var_6_7.existingSaveFiles:getFileListCount() == 0

							if var_6_2.Competition[var_6_6.dataContextKey] then
								var_6_2.Competition[var_6_6.dataContextKey]:refreshCommands()
							else
								var_6_2.Main[var_6_6.dataContextKey]:refreshCommands()
							end
						end
					end
				end

				arg_6_6:playSound("SelectLrg")
			else
				arg_6_0.skipSubMenuSaveScan = false
			end
		end

		if not arg_6_0.subMenuOpen then
			local var_6_8 = var_6_2.TabIndex

			if PLATFORM_PC then
				arg_6_0.canExitGameTimer = arg_6_0.canExitGameTimer + arg_6_4

				arg_6_6:addTooltip(nil, native.InputTypes.Decline, native.Localise("Exit"))

				if arg_6_6:checkForRelease(var_6_0, var_0_1.Decline) and arg_6_0.canExitGameTimer > 1.5 then
					arg_6_6:playSound("Back")
					arg_6_6:blockingAlert(arg_6_2, arg_6_3, {
						options = "noyes",
						canCancel = true,
						text = native.Localise("ExitGameConfirm"),
						uiInput = var_6_0:getInput(),
						onSelected = function(arg_7_0, arg_7_1, arg_7_2)
							if arg_7_2 and arg_7_2.val then
								arg_6_6:setWantExitGame(true)
							end
						end
					})

					return
				end
			end
		end

		if var_6_4 then
			if var_6_5 then
				ASSERT(var_6_5.stateFactory)

				local var_6_9 = false

				if var_6_6.requiresStrictUGCPrivileges then
					local var_6_10, var_6_11 = sharing_gate_aide.CheckStrictUGCPrivileges(arg_6_2, arg_6_3, arg_6_6, var_6_0, arg_6_0.dialogTask, nil, function()
						arg_6_6:homeScreenEnter(arg_6_2, arg_6_3, arg_6_5, arg_6_6, var_6_0, true)
					end)

					arg_6_0.dialogTask = var_6_11

					if var_6_10 then
						var_6_9 = true
					end
				elseif var_6_5.requiresUGCPrivileges and native.getCensorAllUGC() then
					var_6_9 = true

					if not native.getCensoredSignInState().signedInToService then
						arg_6_6:blockingAlert(arg_6_2, arg_6_3, {
							options = "ok",
							canCancel = true,
							text = native.Localise("ErrorUGCNotSignedInToPSN"),
							onSelected = function(arg_9_0, arg_9_1, arg_9_2)
								arg_6_6:homeScreenEnter(arg_9_0, arg_9_1, arg_6_5, arg_6_6, var_6_0, true)
							end
						})
					else
						if arg_6_0.dialogTask then
							arg_6_0.dialogTask:dispose()
						end

						arg_6_0.dialogTask = arg_6_2:getSystemDialogService():showUGCRestrictionDialog(native.getCensoredControllerInfo())

						arg_6_6:blockingAlert(arg_6_2, arg_6_3, {
							options = "ok",
							canCancel = true,
							text = native.Localise("ErrorUGCNoPrivilege") % {
								name = native.getCensoredUser()
							},
							onSelected = function(arg_10_0, arg_10_1, arg_10_2)
								arg_6_6:homeScreenEnter(arg_10_0, arg_10_1, arg_6_5, arg_6_6, var_6_0, true)
							end
						})
					end
				end

				if not var_6_9 then
					if var_6_5.stateData then
						var_6_5.stateData.goBackStack = gobackstack.GoBackStack()
					end

					if var_6_5.new and var_6_5.competition and arg_6_0.CompetitionFull or var_6_5.career and arg_6_0.CareerFull then
						arg_6_0.viewModel.selectedItem = nil

						arg_6_6:showNotification("alert", native.Localise("SavesFull"))

						return
					end

					if not arg_6_0.subMenuOpen then
						arg_6_6:playSound("SelectLrg")
					end

					if var_6_5.stateData and var_6_5.stateData.forcePostMatch then
						var_6_2.selectedItem = nil

						arg_6_0:handlePendingServerMatch(arg_6_1, arg_6_2, arg_6_3, arg_6_5, arg_6_6, var_6_0, var_6_5)
					else
						local var_6_12 = var_6_6 and var_6_6.dataContextKey

						if var_6_12 then
							native.Metrics.addMetricData(metrics_config.HomescreenNavigation, var_6_12)
						end

						arg_6_1:changeState(var_6_5.stateFactory(), arg_6_2, arg_6_3, arg_6_5, arg_6_6, var_6_0, var_6_5.stateData)
					end
				end

				return
			else
				arg_6_6:setWantExitGame(true)
			end
		elseif not arg_6_6:getIsBlockingMixinActive() then
			local var_6_13 = var_6_0.settings
			local var_6_14 = arg_6_6:sharingGetDatabaseVersion()
			local var_6_15 = arg_6_0.databaseVersionLocal

			if var_6_14 and var_6_15 < var_6_14 and var_6_14 > native.databaseVersionHaveAskedUser then
				native.databaseVersionHaveAskedUser = var_6_14

				arg_6_6:profileSaveSettings(var_6_0)
				arg_6_6:blockingAlert(arg_6_2, arg_6_3, {
					options = "yesno",
					canCancel = true,
					text = stringx.interp(native.Localise("PlayerDatabaseUpdateAvailable"), {
						new = var_6_14,
						old = var_6_15
					}),
					input = var_6_0:getInput(),
					onSelected = function(arg_11_0, arg_11_1, arg_11_2)
						if arg_11_2 and arg_11_2.val then
							arg_6_1:changeState(sharing_updatedatabase.SharingUpdateDatabase(), arg_11_0, arg_11_1, arg_6_5, arg_6_6, var_6_0, HomeScreenState)
						end
					end
				})
			end
		end
	end
end

function HomeScreenState.render(arg_12_0, arg_12_1, arg_12_2, arg_12_3, arg_12_4, arg_12_5)
	local var_12_0 = arg_12_0.tileMenu

	if var_12_0 then
		var_12_0:render(arg_12_1, arg_12_2, arg_12_3, arg_12_4, arg_12_5)
	end
end

function HomeScreenState.createMenu(arg_13_0, arg_13_1, arg_13_2, arg_13_3, arg_13_4, arg_13_5, arg_13_6, arg_13_7)
	local var_13_0 = arg_13_1:getNoesis()

	arg_13_0.viewModel = nvm_homescreen.NVMHomeScreen(arg_13_0.homescreenTilesData.tilesRows, arg_13_4)
	arg_13_0.view = var_13_0:loadViewWithVM("Workspace/Views/HomeScreen/paHomeScreenView", arg_13_0.viewModel, native.ENoesisViewManagerLayer.PRE_SCENE, native.CNoesisViewManager.DefaultPriority)
end

function HomeScreenState.destroyMenu(arg_14_0)
	if arg_14_0.view then
		arg_14_0.view:release()

		arg_14_0.view = nil
	end

	if arg_14_0.viewModel then
		arg_14_0.viewModel:dispose()

		arg_14_0.viewModel = nil
	end
end

function HomeScreenState.setScanTasks(arg_15_0, arg_15_1, arg_15_2, arg_15_3, arg_15_4, arg_15_5)
	local var_15_0 = arg_15_5 or arg_15_0.homescreenConfig.ScanTasks

	arg_15_0.scanTasks = {}

	for iter_15_0 = 1, #var_15_0 do
		local var_15_1 = var_15_0[iter_15_0]

		arg_15_0.scanTasks[var_15_1] = signinmixin_loadsaves.ScanForModeSaves(var_15_1, nil, nil, arg_15_1, arg_15_2, arg_15_3, arg_15_4)
	end

	arg_15_0.scanComplete = false
end

function HomeScreenState.updateScanning(arg_16_0, arg_16_1, arg_16_2, arg_16_3, arg_16_4, arg_16_5, arg_16_6)
	local var_16_0 = arg_16_0.partyMember

	if arg_16_1:getParty():hasOfflineJobInProgress() then
		return
	end

	local var_16_1 = arg_16_0.scanTasks
	local var_16_2 = true

	for iter_16_0, iter_16_1 in pairs(var_16_1) do
		local var_16_3, var_16_4, var_16_5, var_16_6 = iter_16_1:update(arg_16_1, arg_16_2, arg_16_3, arg_16_4, arg_16_5, arg_16_6, var_16_0)

		if var_16_3 then
			formatPrint("finished looking for \"%s/%s\" profile files - got %d", var_16_6.saveFolder, var_16_6.saveFileName, var_16_4:getFileListCount())
			iter_16_1:dispose()

			var_16_1[iter_16_0] = nil
			arg_16_0.scanResults[iter_16_0] = {
				existingSaveFiles = var_16_4,
				errorInfo = var_16_5,
				saveConfig = var_16_6,
				saveHelperKey = iter_16_1.saveHelperKey
			}
		else
			var_16_2 = false
		end
	end

	if not var_16_2 then
		return
	end

	local var_16_7 = false
	local var_16_8

	for iter_16_2, iter_16_3 in pairs(arg_16_0.scanResults) do
		local var_16_9 = iter_16_3.existingSaveFiles

		if var_16_9:getFileListCount() > 0 then
			var_16_7 = true

			iter_16_3.existingSaveFiles:sortList()

			local var_16_10 = var_16_9:getFileListItem(1)

			if not var_16_8 or var_16_8.saveFile.utc < var_16_10.utc then
				var_16_8 = {
					saveFile = var_16_10,
					gameMMode = iter_16_2
				}
			end
		end
	end

	arg_16_0.hasExistingSaves = var_16_7
	arg_16_0.mostRecentSave = var_16_8
	arg_16_0.scanComplete = true

	arg_16_0:postScanSetup(arg_16_1, arg_16_2, arg_16_4, arg_16_5, var_16_0)

	arg_16_0.highlightStateFactory = nil
	arg_16_0.highlightStateData = nil
	arg_16_0.enterFromLeftOverride = nil
end

function HomeScreenState.postScanSetup(arg_17_0, arg_17_1, arg_17_2, arg_17_3, arg_17_4, arg_17_5)
	arg_17_0:CheckForMaxSaves()
	arg_17_0:loadExistingSaves(arg_17_4)
end

function HomeScreenState.loadExistingSaves(arg_18_0, arg_18_1)
	for iter_18_0, iter_18_1 in pairs(arg_18_0.scanResults) do
		local var_18_0 = iter_18_1.existingSaveFiles
		local var_18_1 = var_18_0:getFileListCount()

		for iter_18_2 = 1, var_18_1 do
			local var_18_2 = var_18_0:getFileListItem(iter_18_2)

			arg_18_0:loadSaveIntoSubMenu(arg_18_1, var_18_2, iter_18_0)
		end
	end

	if arg_18_0.subMenuOpen then
		local var_18_3 = arg_18_0.viewModel:getHighlightedTile()
		local var_18_4, var_18_5 = arg_18_0.homescreenConfig.getTileFn(var_18_3.competitionId, arg_18_0.homescreenTilesData.tilesRows)

		arg_18_0.viewModel:populateSubMenuWithSaves(arg_18_1, var_18_4, var_18_5)
	end
end

function HomeScreenState.CheckForMaxSaves(arg_19_0, arg_19_1)
	for iter_19_0, iter_19_1 in pairs(arg_19_0.scanResults) do
		local var_19_0 = iter_19_1.existingSaveFiles
		local var_19_1 = iter_19_1.saveHelperKey
		local var_19_2 = (iter_19_1.saveConfig.maxSaves or 10) <= var_19_0:getFileListCount()
		local var_19_3 = var_19_0.requiredSpaceKB:toNumber()
		local var_19_4 = var_19_0.freeSpaceKB:toNumber()

		arg_19_0[iter_19_0 .. "Full"] = var_19_4 < var_19_3 or var_19_2
	end
end

function HomeScreenState.loadSaveIntoSubMenu(arg_20_0, arg_20_1, arg_20_2)
	local var_20_0 = tonumber(string.gsub(arg_20_2.privateData, "CompetitionId=", ""), 10)
	local var_20_1 = native.CareerCompetitionIdEnum[var_20_0] or -1

	if var_20_1 == -1 and not string.find(arg_20_2.mountName, "Career") then
		return
	end

	local var_20_2, var_20_3 = arg_20_0.homescreenConfig.getTileFn(var_20_1, arg_20_0.homescreenTilesData.tilesRows)

	for iter_20_0, iter_20_1 in ipairs(var_20_2) do
		if not (#iter_20_1.subMenu > 5) then
			local var_20_4 = {
				isSaveFile = true,
				title = arg_20_2.valid and arg_20_2.subTitle or native.Localise("Corrupted"),
				description = uiutil.utcToSimpleDisplayStr(arg_20_2.utc),
				stateFactory = iter_20_1.stateFactory,
				stateData = {
					addedAfter = true,
					nextState = iter_20_1.loadState,
					competitionId = iter_20_1.competitionId,
					stateData = {
						fileName = arg_20_2.subFileName,
						mountName = arg_20_2.mountName,
						additionalData = {
							fileName = arg_20_2.subFileName,
							mountName = arg_20_2.mountName
						}
					}
				},
				valid = arg_20_2.valid
			}

			iter_20_1.subMenu[#iter_20_1.subMenu].locked = false

			table.insert(iter_20_1.subMenu, #iter_20_1.subMenu, var_20_4)
		end
	end
end

function HomeScreenState.clearSavesFromSubMenu(arg_21_0, arg_21_1)
	for iter_21_0 = #arg_21_1.subMenu, 1, -1 do
		if arg_21_1.subMenu[iter_21_0].isSaveFile then
			table.remove(arg_21_1.subMenu, iter_21_0)
		end
	end

	local var_21_0, var_21_1 = arg_21_0.homescreenConfig.getTileFn(arg_21_1.competitionId, arg_21_0.homescreenTilesData.tilesRows)

	arg_21_0.viewModel:removeSavesFromTile(var_21_0, var_21_1)
end

function HomeScreenState.updateBannerViewModelLoading(arg_22_0, arg_22_1, arg_22_2)
	local var_22_0 = arg_22_2:getHomescreenBanners() or {}
	local var_22_1 = arg_22_0.viewModel

	if not var_22_1 or #var_22_0 < 1 then
		return
	end

	if not var_22_1:hasBannerViewModels() and var_22_1.BannerItemsSource then
		for iter_22_0, iter_22_1 in ipairs(var_22_0) do
			var_22_1:addBannerToCollection(arg_22_1, iter_22_1)
		end
	end

	local var_22_2 = arg_22_1:getImageStore()
	local var_22_3 = true

	for iter_22_2, iter_22_3 in ipairs(var_22_0) do
		local var_22_4 = native.CUuid.fromString(iter_22_3.image_uuid)
		local var_22_5 = tostring(var_22_4)

		if not arg_22_0.loadedImages[var_22_5] then
			local var_22_6 = var_22_2:doesImageExist(var_22_4)

			if var_22_6 then
				arg_22_0.loadedImages[var_22_5] = true
			end

			var_22_3 = var_22_3 and var_22_6
		end
	end

	if var_22_3 then
		var_22_1:setChosenBanner(1)
	end

	arg_22_0.allImagesLoaded = var_22_3
end

function HomeScreenState.refreshBannerViewModels(arg_23_0, arg_23_1)
	arg_23_0.allImagesLoaded = false
	arg_23_0.loadedImages = {}

	if arg_23_0.viewModel then
		arg_23_0.viewModel:clearBanners(arg_23_1)
	end
end

function HomeScreenState.autotestHighlightItem(arg_24_0, arg_24_1)
	local var_24_0 = VERIFY(arg_24_1.title)

	for iter_24_0, iter_24_1 in pairs(arg_24_0.homescreenTilesData.tilesRows) do
		for iter_24_2, iter_24_3 in ipairs(iter_24_1) do
			if iter_24_3.autoNavKey and iter_24_3.autoNavKey == var_24_0 then
				arg_24_0.setHighlightTile(iter_24_3.dataContextKey)

				local var_24_1 = arg_24_0.viewModel

				var_24_1.FocusElementIdentifier = iter_24_3.autoNavKey
				var_24_1.ForceElementFocus = true

				return true
			end
		end
	end

	return false
end

function HomeScreenState.handlePendingServerMatch(arg_25_0, arg_25_1, arg_25_2, arg_25_3, arg_25_4, arg_25_5, arg_25_6, arg_25_7)
	local var_25_0 = arg_25_6.serverMatch

	if var_25_0.hasPendingReport and (var_25_0.gameMode == native.EGameMode.CoachBattles or var_25_0.gameMode == native.EGameMode.LadderLeaders or var_25_0.gameMode == native.EGameMode.PremiershipChallenge) then
		arg_25_5:blockingAlert(arg_25_2, arg_25_5.systemTime, {
			options = "yesno",
			canCancel = false,
			title = native.Localise("Dynasty_MatchReporting_PostMatch_Pending_Title"),
			text = native.Localise("Dynasty_MatchReporting_PostMatch_Pending"),
			input = arg_25_6:getInput(),
			onSelected = function(arg_26_0, arg_26_1, arg_26_2)
				if arg_26_2 and arg_26_2.val then
					local var_26_0 = {}
					local var_26_1 = dynasty_state.DynastyState

					arg_25_1:changeState(var_26_1(), arg_26_0, arg_26_1, arg_25_4, arg_25_5, arg_25_6)
				else
					arg_25_0:kickOffPostMatch(arg_25_1, arg_26_0, arg_26_1, arg_25_4, arg_25_5, var_25_0, arg_25_6, arg_25_7)
				end
			end
		})
	else
		arg_25_1:changeState(arg_25_7.stateFactory(), arg_25_2, arg_25_3, arg_25_4, arg_25_5, arg_25_6, arg_25_7.stateData)
	end
end

function HomeScreenState.kickOffPostMatch(arg_27_0, arg_27_1, arg_27_2, arg_27_3, arg_27_4, arg_27_5, arg_27_6, arg_27_7, arg_27_8)
	local var_27_0 = arg_27_6:getReportData()
	local var_27_1 = arg_27_5.buildCommsTask(arg_27_2, "PostMatch", arg_27_6.matchId, var_27_0)

	arg_27_5.addCommsTask(var_27_1, arg_27_0.commsTaskIds, function(arg_28_0, arg_28_1)
		if arg_28_1 then
			arg_27_6:reset()
			arg_27_5:profileSaveFull(arg_27_7)

			if arg_27_8 then
				arg_27_1:changeState(arg_27_8.stateFactory(), arg_27_2, arg_27_3, arg_27_4, arg_27_5, arg_27_7, arg_27_8.stateData)
			end
		else
			arg_27_5:blockingAlert(arg_27_2, arg_27_5.systemTime, {
				options = "yesno",
				canCancel = false,
				title = native.Localise("Dynasty_MatchReporting_PostMatch_Fail_Title"),
				text = native.Localise("Dynasty_MatchReporting_PostMatch_Fail"),
				input = arg_27_7:getInput(),
				onSelected = function(arg_29_0, arg_29_1, arg_29_2)
					if arg_29_2 and arg_29_2.val then
						arg_27_0:kickOffPostMatch(arg_27_1, arg_29_0, arg_29_1, arg_27_4, arg_27_5, arg_27_6, arg_27_7, arg_27_8)
					elseif arg_29_2 and not arg_29_2.val then
						arg_27_6:ignore()
						arg_27_5:profileSaveFull(arg_27_7)
					end
				end
			})
		end
	end, {
		text = "Dynasty_MatchReporting_PostMatch_Uploading"
	})
end
