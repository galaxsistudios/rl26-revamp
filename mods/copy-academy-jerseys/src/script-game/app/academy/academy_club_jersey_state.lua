import("core.statemachine.statemachine")
import("app.academy.academy_club_jerseystate_list_state")
import("app.academy.academy_club_jerseystate_appearance_state")
import("app.academy.academy_club_jerseystate_copylicensed_state")
import("app.academy.academy_communitystate_base_download")
import("app.academy.academy_communitystate_decal_download_substate")
import("base.ui.defaults")
import("base.ui.optionmenu.optionmenu_aide")
import("base.ui.optionmenu.optionmenu_state")
import("core.foundation.stringx")
import("intermediatelua.convant.uitextures")

-- copy-academy-jerseys mod: "COPY ACADEMY UNIFORM" in a club's jersey list.
-- Lists every club of the same sex - stock official, Academy-edited official,
-- user-created and downloaded - using a plain option menu instead of the
-- native club picker grid (whose search can't show on-disc and user clubs
-- together), then that club's jerseys, then copies the chosen one into the
-- club being edited. Clubs are read through the merged club manager, so an
-- edited official club shows its edited jerseys.

local var_0_ca_base = optionmenu_state.OptionMenuState
local var_0_ca_list = academy_club_jerseystate_copylicensed_state.JerseyCopyLicensedShowList

local function var_0_ca_menuConfig(arg_ca_0, arg_ca_1)
	return {
		anchorTopLeft = true,
		displayCount = 13,
		backInputAllowed = true,
		examineSelectionBeforeExit = true,
		itemParams = true,
		scrollBar = {},
		title = native.Localise("Copy"),
		titleBox = {
			centre = true,
			title = arg_ca_0
		},
		headerTexture = uitextures.RugbyFrameHalfTitleBox.texture,
		titleRowWhite = {
			centre = true,
			label = arg_ca_1
		},
		rowHeight = defaults.RowHeight
	}
end

local function var_0_ca_getSourceClubs(arg_ca_0, arg_ca_1, arg_ca_2)
	local var_ca_0 = arg_ca_0:getClubManager()
	local var_ca_1 = arg_ca_1.club
	local var_ca_2 = arg_ca_1.sex or var_ca_1.identity.sex
	local var_ca_3 = {}
	local var_ca_4, var_ca_5 = pcall(function()
		return var_ca_0:getAllClubsWithSex(true, true, var_ca_2, arg_ca_0:getDlcManager(), true)
	end)

	if var_ca_4 and type(var_ca_5) == "table" then
		for iter_ca_0, iter_ca_1 in ipairs(var_ca_5) do
			table.insert(var_ca_3, type(iter_ca_1) == "number" and iter_ca_1 or iter_ca_1.id)
		end
	else
		print("copy-academy-jerseys: getAllClubsWithSex failed: " .. tostring(var_ca_5))

		for iter_ca_2, iter_ca_3 in ipairs(var_ca_0:getOnDiscClubIds()) do
			table.insert(var_ca_3, iter_ca_3)
		end
	end

	local var_ca_6 = {}
	local var_ca_7 = {}

	for iter_ca_4, iter_ca_5 in ipairs(var_ca_3) do
		if iter_ca_5 ~= arg_ca_2 and not var_ca_7[iter_ca_5] then
			var_ca_7[iter_ca_5] = true

			local var_ca_8 = var_ca_0:getClub(iter_ca_5)

			if var_ca_8 and var_ca_8.uniformCount > 0 and (not var_ca_8.identity or var_ca_8.identity.sex == var_ca_2) then
				table.insert(var_ca_6, var_ca_8)
			end
		end
	end

	return var_ca_6
end

local function var_0_ca_preview(arg_ca_0, arg_ca_1, arg_ca_2)
	arg_ca_0:playerModelSetUniform(1, arg_ca_1)
	arg_ca_0:playerModelUpdate(1, {
		refresh = true,
		camera = arg_ca_2 and "FullBody_OutsideOfAppearance" or nil
	})
end

Class("JerseyCopyAcademyClubList", var_0_ca_list)

function JerseyCopyAcademyClubList.enter(arg_ca_0, arg_ca_1, arg_ca_2, arg_ca_3, arg_ca_4, arg_ca_5, arg_ca_6, arg_ca_7, arg_ca_8, arg_ca_9)
	local var_ca_0 = {}
	local var_ca_1

	for iter_ca_0, iter_ca_1 in ipairs(var_0_ca_getSourceClubs(arg_ca_5, arg_ca_7, arg_ca_7.club.id)) do
		table.insert(var_ca_0, {
			editable = true,
			label = iter_ca_1.fullName,
			displayType = optionmenu_aide.DisplayTypes.LabelOnly,
			editType = optionmenu_aide.EditTypes.SubMenu,
			club = iter_ca_1
		})
	end

	table.sort(var_ca_0, function(arg_ca_10, arg_ca_11)
		if arg_ca_10.label ~= arg_ca_11.label then
			return arg_ca_10.label < arg_ca_11.label
		end

		return arg_ca_10.club.id < arg_ca_11.club.id
	end)

	for iter_ca_2, iter_ca_3 in ipairs(var_ca_0) do
		if iter_ca_3.club.id == arg_ca_9 then
			var_ca_1 = iter_ca_2
		end
	end

	if #var_ca_0 == 0 then
		table.insert(var_ca_0, {
			editable = false,
			label = "NO CLUBS FOUND",
			displayType = optionmenu_aide.DisplayTypes.LabelOnly
		})
	else
		var_0_ca_preview(arg_ca_5, var_ca_0[var_ca_1 or 1].club:getHomeUniformVisual(), true)
	end

	var_0_ca_base.enter(arg_ca_0, arg_ca_2, arg_ca_3, arg_ca_4, arg_ca_5, var_ca_0, var_ca_1, var_0_ca_menuConfig(arg_ca_7.club.fullName, native.Localise("Clubs")))
end

function JerseyCopyAcademyClubList.update(arg_ca_0, arg_ca_1, arg_ca_2, arg_ca_3, arg_ca_4, arg_ca_5, arg_ca_6, arg_ca_7, arg_ca_8, arg_ca_9, arg_ca_10)
	local var_ca_0 = assert(arg_ca_8.partyMember)
	local var_ca_1, var_ca_2, var_ca_3, var_ca_4 = var_0_ca_base.update(arg_ca_0, arg_ca_2, arg_ca_3, arg_ca_4, arg_ca_5, arg_ca_6, arg_ca_7, var_ca_0:getInput())

	-- examineSelectionBeforeExit: a selection comes back as (false, _, _, item);
	-- true only means the menu was backed out of
	if var_ca_1 then
		arg_ca_1:changeState(nil, arg_ca_2, arg_ca_3, arg_ca_5, arg_ca_6, arg_ca_8, arg_ca_9, arg_ca_10)
	elseif var_ca_4 and var_ca_4.club then
		arg_ca_1:changeState(JerseyCopyAcademyUniformList(), arg_ca_2, arg_ca_3, arg_ca_5, arg_ca_6, arg_ca_8, arg_ca_9, arg_ca_10, var_ca_4.club.id)
	elseif var_ca_2 and var_ca_2.club then
		var_0_ca_preview(arg_ca_6, var_ca_2.club:getHomeUniformVisual())
	end
end

Class("JerseyCopyAcademyUniformList", var_0_ca_list)

function JerseyCopyAcademyUniformList.enter(arg_ca_0, arg_ca_1, arg_ca_2, arg_ca_3, arg_ca_4, arg_ca_5, arg_ca_6, arg_ca_7, arg_ca_8, arg_ca_9)
	local var_ca_0 = VERIFY(arg_ca_5:getClubManager():getClub(arg_ca_9))
	local var_ca_1 = {}

	arg_ca_0.sourceClubId = arg_ca_9

	for iter_ca_0 = 1, var_ca_0.uniformCount do
		local var_ca_2 = var_ca_0:getUniform(iter_ca_0)

		if not var_ca_2.isHidden then
			table.insert(var_ca_1, {
				editable = true,
				label = var_ca_2:getDisplayName(iter_ca_0),
				displayType = optionmenu_aide.DisplayTypes.LabelOnly,
				editType = optionmenu_aide.EditTypes.SubMenu,
				uniformIndex = iter_ca_0,
				uniform = var_ca_2
			})
		end
	end

	if #var_ca_1 == 0 then
		table.insert(var_ca_1, {
			editable = false,
			label = "NO UNIFORMS",
			displayType = optionmenu_aide.DisplayTypes.LabelOnly
		})
	else
		var_0_ca_preview(arg_ca_5, var_ca_1[1].uniform.config, true)
	end

	var_0_ca_base.enter(arg_ca_0, arg_ca_2, arg_ca_3, arg_ca_4, arg_ca_5, var_ca_1, nil, var_0_ca_menuConfig(var_ca_0.fullName, native.Localise("Uniforms")))
end

function JerseyCopyAcademyUniformList.update(arg_ca_0, arg_ca_1, arg_ca_2, arg_ca_3, arg_ca_4, arg_ca_5, arg_ca_6, arg_ca_7, arg_ca_8, arg_ca_9, arg_ca_10)
	local var_ca_0 = assert(arg_ca_8.partyMember)
	local var_ca_1, var_ca_2, var_ca_3, var_ca_4 = var_0_ca_base.update(arg_ca_0, arg_ca_2, arg_ca_3, arg_ca_4, arg_ca_5, arg_ca_6, arg_ca_7, var_ca_0:getInput())

	if var_ca_1 then
		arg_ca_1:changeState(JerseyCopyAcademyClubList(), arg_ca_2, arg_ca_3, arg_ca_5, arg_ca_6, arg_ca_8, arg_ca_9, arg_ca_10, arg_ca_0.sourceClubId)
	elseif var_ca_4 and var_ca_4.uniform then
		local var_ca_5 = arg_ca_9.club
		local var_ca_6 = var_ca_5:addNewUniform()

		var_ca_6.name = string.format("%s %d", native.Localise("Jersey"), var_ca_5.uniformCount)

		var_ca_6.config:copy(var_ca_4.uniform.config)

		arg_ca_10.editUniformIndex = var_ca_5.uniformCount

		arg_ca_6:showNotification("alert", stringx.interp(native.Localise("AddedCopyOfLicensedJersey"), {
			name = var_ca_4.uniform.name,
			newName = var_ca_6.name
		}))
		arg_ca_9.setDirty()

		var_ca_5.sharing.hasUnsharedModifications = true

		if var_ca_5.uniformCanCreateCount == 0 then
			arg_ca_6:blockingAlert(arg_ca_2, arg_ca_3, {
				options = "ok",
				canCancel = false,
				text = native.Localise("ClubFullOfJerseys"),
				input = var_ca_0:getInput()
			})
		end

		arg_ca_1:changeState(nil, arg_ca_2, arg_ca_3, arg_ca_5, arg_ca_6, arg_ca_8, arg_ca_9, arg_ca_10)
	elseif var_ca_2 and var_ca_2.uniform then
		var_0_ca_preview(arg_ca_6, var_ca_2.uniform.config)
	end
end

Class("AcademyClubJerseyCopyAcademyState")

function AcademyClubJerseyCopyAcademyState.enter(arg_ca_0, arg_ca_1, arg_ca_2, arg_ca_3, arg_ca_4, arg_ca_5, arg_ca_6, arg_ca_7, arg_ca_8)
	arg_ca_5:toggleLockerRoomVisibility(true)

	arg_ca_0.stateMachine = statemachine.StateMachine(type(arg_ca_0))

	arg_ca_0.stateMachine:changeState(JerseyCopyAcademyClubList(), arg_ca_2, arg_ca_3, arg_ca_4, arg_ca_5, arg_ca_6, arg_ca_7, arg_ca_8)
end

function AcademyClubJerseyCopyAcademyState.exit(arg_ca_0, arg_ca_1, arg_ca_2, arg_ca_3, arg_ca_4, arg_ca_5)
	arg_ca_4:toggleLockerRoomVisibility(false)
	arg_ca_0.stateMachine:changeState(nil, arg_ca_1, arg_ca_2, arg_ca_3, arg_ca_4, arg_ca_5)
end

function AcademyClubJerseyCopyAcademyState.update(arg_ca_0, arg_ca_1, arg_ca_2, arg_ca_3, arg_ca_4, arg_ca_5, arg_ca_6, arg_ca_7, arg_ca_8, arg_ca_9, arg_ca_10)
	if arg_ca_0.stateMachine:getCurrentState() then
		arg_ca_0.stateMachine:update(arg_ca_2, arg_ca_3, arg_ca_4, arg_ca_5, arg_ca_6, arg_ca_7, arg_ca_8, arg_ca_9, arg_ca_10)
	else
		arg_ca_1:changeState(arg_ca_10.stateFactoryMap.List(), arg_ca_2, arg_ca_3, arg_ca_5, arg_ca_6, arg_ca_8, arg_ca_9, arg_ca_10)
	end
end

function AcademyClubJerseyCopyAcademyState.render(arg_ca_0, arg_ca_1, arg_ca_2, arg_ca_3, arg_ca_4)
	if arg_ca_0.stateMachine:getCurrentState() then
		arg_ca_0.stateMachine:render(arg_ca_1, arg_ca_2, arg_ca_3, arg_ca_4)
	end
end

-- FanHub: the jersey list (viewing a community club, jerseyData.inCommunity)
-- sends a selected uniform here; pick one of your clubs and the uniform is
-- added to it. Official clubs get their Academy-edited version, the same as
-- editing them in Academy; the FanHub club view's dirty-save helper writes
-- the profile when the view is left.

Class("JerseyCopyToClubList", var_0_ca_list)

function JerseyCopyToClubList.enter(arg_ca_0, arg_ca_1, arg_ca_2, arg_ca_3, arg_ca_4, arg_ca_5, arg_ca_6, arg_ca_7, arg_ca_8)
	local var_ca_0 = VERIFY(arg_ca_7.club:getUniform(VERIFY(arg_ca_8.editUniformIndex)))
	local var_ca_1 = {}

	arg_ca_0.sourceUniform = var_ca_0

	for iter_ca_0, iter_ca_1 in ipairs(var_0_ca_getSourceClubs(arg_ca_5, arg_ca_7)) do
		table.insert(var_ca_1, {
			editable = true,
			label = iter_ca_1.fullName,
			displayType = optionmenu_aide.DisplayTypes.LabelOnly,
			editType = optionmenu_aide.EditTypes.SubMenu,
			clubId = iter_ca_1.id
		})
	end

	table.sort(var_ca_1, function(arg_ca_10, arg_ca_11)
		if arg_ca_10.label ~= arg_ca_11.label then
			return arg_ca_10.label < arg_ca_11.label
		end

		return arg_ca_10.clubId < arg_ca_11.clubId
	end)

	if #var_ca_1 == 0 then
		table.insert(var_ca_1, {
			editable = false,
			label = "NO CLUBS FOUND",
			displayType = optionmenu_aide.DisplayTypes.LabelOnly
		})
	end

	var_0_ca_preview(arg_ca_5, var_ca_0.config, true)
	var_0_ca_base.enter(arg_ca_0, arg_ca_2, arg_ca_3, arg_ca_4, arg_ca_5, var_ca_1, nil, var_0_ca_menuConfig(var_ca_0:getDisplayName(arg_ca_8.editUniformIndex), "COPY TO CLUB"))
end

function JerseyCopyToClubList.update(arg_ca_0, arg_ca_1, arg_ca_2, arg_ca_3, arg_ca_4, arg_ca_5, arg_ca_6, arg_ca_7, arg_ca_8, arg_ca_9, arg_ca_10)
	local var_ca_0 = assert(arg_ca_8.partyMember)
	local var_ca_1, var_ca_2, var_ca_3, var_ca_4 = var_0_ca_base.update(arg_ca_0, arg_ca_2, arg_ca_3, arg_ca_4, arg_ca_5, arg_ca_6, arg_ca_7, var_ca_0:getInput())

	if var_ca_1 then
		arg_ca_1:changeState(nil, arg_ca_2, arg_ca_3, arg_ca_5, arg_ca_6, arg_ca_8, arg_ca_9, arg_ca_10)
	elseif var_ca_4 and var_ca_4.clubId then
		local var_ca_5 = arg_ca_6:getClubManager():getClub(var_ca_4.clubId)

		if not var_ca_5 or var_ca_5.uniformCanCreateCount == 0 then
			arg_ca_6:blockingAlert(arg_ca_2, arg_ca_3, {
				options = "ok",
				canCancel = false,
				text = native.Localise("ClubFullOfJerseys"),
				input = var_ca_0:getInput()
			})

			return
		end

		-- fetch the FanHub club's decals (logos) first, as "Download with
		-- decals" does, then copy with the decal ids remapped to local ones
		arg_ca_1:changeState(JerseyCopyDecalDownload(), arg_ca_2, arg_ca_3, arg_ca_5, arg_ca_6, arg_ca_8, arg_ca_9, arg_ca_10, var_ca_4.clubId)
	end
end

-- Adds clubViewInfo.club's uniform (jerseyData.editUniformIndex) to the club
-- with id arg_ca_3. A FanHub club holds FanHub decal ids, so the uniform is
-- taken from a copy of the club with replaceDecalIdsWithLocalIds() applied,
-- exactly like the stock club download does.
local function var_0_ca_copyIntoClub(arg_ca_0, arg_ca_1, arg_ca_2, arg_ca_3)
	local var_ca_0 = arg_ca_0:getClubManager()
	local var_ca_1 = native.CClub()

	var_ca_1:set(arg_ca_1.club)
	var_ca_1:replaceDecalIdsWithLocalIds(arg_ca_0:getDecalManager())

	local var_ca_2 = VERIFY(var_ca_1:getUniform(VERIFY(arg_ca_2.editUniformIndex)))
	local var_ca_3 = native.CClubManager.getIsOnDiscClub(arg_ca_3) and var_ca_0:editOrCreateUserCreatedVersionOfClub(arg_ca_3) or var_ca_0:getClub(arg_ca_3)

	if not var_ca_3 or var_ca_3.uniformCanCreateCount == 0 then
		return
	end

	local var_ca_4 = var_ca_3:addNewUniform()

	var_ca_4.name = string.format("%s %d", native.Localise("Jersey"), var_ca_3.uniformCount)

	var_ca_4.config:copy(var_ca_2.config)

	var_ca_3.sharing.hasUnsharedModifications = true

	if native.CClubDatabaseOnDisc.getIsOfficialClubId(var_ca_3.id) then
		var_ca_0:saveCustomLicensed(var_ca_3)
	end

	arg_ca_1.setDirty()
	arg_ca_0:showNotification("alert", stringx.interp(native.Localise("AddedCopyOfLicensedJersey"), {
		name = var_ca_2.name,
		newName = string.format("%s (%s)", var_ca_4.name, var_ca_3.fullName)
	}))
end

local var_0_ca_download = academy_communitystate_base_download.AcademyCommunityBaseDownloadSubState

Class("JerseyCopyDecalDownload", var_0_ca_download)

function JerseyCopyDecalDownload.enter(arg_ca_0, arg_ca_1, arg_ca_2, arg_ca_3, arg_ca_4, arg_ca_5, arg_ca_6, arg_ca_7, arg_ca_8, arg_ca_9)
	local var_ca_0 = arg_ca_7.downloadedClubInfo
	local var_ca_1 = var_ca_0 and var_ca_0.item
	local var_ca_2 = arg_ca_5:getSharedDataCache()
	local var_ca_3 = {}

	arg_ca_0.targetClubId = arg_ca_9

	if var_ca_1 and var_ca_1.decals and var_ca_2.decals then
		for iter_ca_0, iter_ca_1 in ipairs(var_ca_1.decals.asTable) do
			local var_ca_4 = var_ca_2.decals.dict:get(iter_ca_1)

			if var_ca_4 then
				academy_communitystate_decal_download_substate.addDecalToDownloadList(var_ca_3, arg_ca_5, var_ca_2, var_ca_4, {
					data = true
				})
			end
		end
	end

	arg_ca_0.noDownload = #var_ca_3 == 0

	if not arg_ca_0.noDownload then
		var_0_ca_download.enter(arg_ca_0, arg_ca_2, arg_ca_3, arg_ca_4, arg_ca_5, arg_ca_6, var_ca_3)
	end
end

function JerseyCopyDecalDownload.exit(arg_ca_0)
	if not arg_ca_0.noDownload then
		var_0_ca_download.exit(arg_ca_0)
	end
end

function JerseyCopyDecalDownload.update(arg_ca_0, arg_ca_1, arg_ca_2, arg_ca_3, arg_ca_4, arg_ca_5, arg_ca_6, arg_ca_7, arg_ca_8, arg_ca_9, arg_ca_10)
	if arg_ca_0.noDownload or var_0_ca_download.update(arg_ca_0, arg_ca_2, arg_ca_3, arg_ca_4, arg_ca_5, arg_ca_6, arg_ca_7, arg_ca_8) then
		if arg_ca_0.noDownload or not arg_ca_0.downloadList.cancel then
			var_0_ca_copyIntoClub(arg_ca_6, arg_ca_9, arg_ca_10, arg_ca_0.targetClubId)
		end

		arg_ca_1:changeState(nil, arg_ca_2, arg_ca_3, arg_ca_5, arg_ca_6, arg_ca_8, arg_ca_9, arg_ca_10)
	end
end

function JerseyCopyDecalDownload.render(arg_ca_0, arg_ca_1, arg_ca_2, arg_ca_3, arg_ca_4)
	if not arg_ca_0.noDownload then
		var_0_ca_download.render(arg_ca_0, arg_ca_1, arg_ca_2, arg_ca_3, arg_ca_4)
	end
end

Class("AcademyClubJerseyCopyToClubState", AcademyClubJerseyCopyAcademyState)

function AcademyClubJerseyCopyToClubState.enter(arg_ca_0, arg_ca_1, arg_ca_2, arg_ca_3, arg_ca_4, arg_ca_5, arg_ca_6, arg_ca_7, arg_ca_8)
	arg_ca_5:toggleLockerRoomVisibility(true)

	arg_ca_0.stateMachine = statemachine.StateMachine(type(arg_ca_0))

	arg_ca_0.stateMachine:changeState(JerseyCopyToClubList(), arg_ca_2, arg_ca_3, arg_ca_4, arg_ca_5, arg_ca_6, arg_ca_7, arg_ca_8)
end

Class("AcademyClubJerseyState")

function AcademyClubJerseyState.enter(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7, arg_1_8)
	local var_1_0 = {
		stateFactoryMap = {
			List = academy_club_jerseystate_list_state.AcademyClubJerseyListState,
			Appearance = academy_club_jerseystate_appearance_state.AcademyClubJerseyAppearanceState,
			CopyLicensed = academy_club_jerseystate_copylicensed_state.AcademyClubJerseyCopyLicensedState,
			CopyAcademy = AcademyClubJerseyCopyAcademyState,
			CopyToClub = AcademyClubJerseyCopyToClubState
		},
		inCommunity = arg_1_7.inCommunity
	}
	local var_1_1
	local var_1_2 = arg_1_7.downloadedClubInfo
	local var_1_3 = arg_1_7.club:getLineupCount() > 0 and arg_1_7.club:getLineup(1)
	local var_1_4 = var_1_3 and var_1_3:getSpecialRole(native.EClubLineupSpecialRole.Captain)

	-- copy-academy-jerseys mod: this screen is now reachable from FanHub,
	-- where a club's downloaded player list can be nil (getPlayerWithId then
	-- ipairs()es nil and the UI dies) - fall back to the default player
	if var_1_4 and arg_1_7.club:containsPlayer(var_1_4) then
		if var_1_2 then
			var_1_1 = var_1_2.getPlayerWithId and var_1_2.allPlayersList and var_1_2.getPlayerWithId(var_1_4)
		else
			var_1_1 = arg_1_5:getPlayerManager():getPlayer(var_1_4)
		end
	end

	if not var_1_1 and arg_1_7.club.playerCount > 0 then
		if var_1_2 then
			local var_1_5 = var_1_2.allPlayersList and var_1_2.allPlayersList[1]

			var_1_1 = var_1_5 and var_1_5.object or nil
		else
			local var_1_6 = arg_1_5:getPlayerManager()

			var_1_1 = assert(var_1_6:getPlayer(arg_1_7.club:getPlayerIdAt(1)))
		end
	end

	local var_1_7 = arg_1_7.club

	arg_1_5:playerModelSetUniform(1, var_1_7:getHomeUniformVisual(), var_1_7.identity)
	arg_1_5:playerModelUpdate(1, {
		draw = true,
		rotationEnabled = true,
		hideUntilLoaded = true,
		player = var_1_1,
		defaultPlayer = not var_1_1,
		defaultPlayerSex = var_1_7.identity.sex,
		club = var_1_7
	})

	arg_1_0.stateMachine = statemachine.StateMachine(type(arg_1_0))

	arg_1_0.stateMachine:changeState(var_1_0.stateFactoryMap.List(), arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7, var_1_0)

	arg_1_0.jerseyData = var_1_0
	arg_1_0.goBackFactory = assert(arg_1_8)

	arg_1_5:titleSetTitleOnlyMode(true)
	arg_1_5:titleSetSubAreaOfGame(native.Localise("Clubs"))
end

function AcademyClubJerseyState.exit(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6)
	arg_2_0.stateMachine:changeState(nil, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6)
	arg_2_4:playerModelUpdate(1, {
		draw = false
	})
end

function AcademyClubJerseyState.update(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9)
	if arg_3_0.stateMachine:getCurrentState() then
		arg_3_0.stateMachine:update(arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_0.jerseyData)
	else
		if arg_3_9.getDirty and arg_3_8.characterAssetMap then
			arg_3_9.club:setCrowdColoursFromUniforms(arg_3_8.characterAssetMap)
		end

		arg_3_9.saveIfDirty(arg_3_2)

		local var_3_0 = arg_3_0.goBackFactory

		arg_3_1:changeState(var_3_0(), arg_3_2, arg_3_3, arg_3_5, arg_3_6, arg_3_8, arg_3_9, arg_3_0.__proto)
	end
end

function AcademyClubJerseyState.render(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4)
	arg_4_0.stateMachine:render(arg_4_1, arg_4_2, arg_4_3, arg_4_4)
end
