import("core.statemachine.statemachine")
import("app.academy.academy_communitystate_clubstate_viewstate_getplayers_state")
import("app.academy.academy_communitystate_clubstate_download_substate")
import("app.academy.academy_communitystate_base_download")
import("app.academy.academy_communitystate_base_list_state")
import("app.online.online_helper")

local var_0_0 = native.InputTypes
local var_0_1 = native.Localise("Rotation")
local var_0_2 = {
	native.Localise("Name"),
	native.Localise("OverallAbbr"),
	native.Localise("Rating"),
	native.Localise("Downloads"),
	native.Localise("Status")
}
local var_0_3 = academy_communitystate_base_list_state.AcademyCommunityBaseListState

Class("AcademyCommunityClubListState", var_0_3)

AcademyCommunityClubListState.WantsGamercards = true
AcademyCommunityClubListState.QuickDownloadInput = var_0_0.Y

function AcademyCommunityClubListState.enter(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7)
	arg_1_7.type = "Clubs"

	arg_1_0:initMenuState(arg_1_2, arg_1_3, arg_1_5, arg_1_6, arg_1_7, var_0_2)
	arg_1_0.viewModel:createClubHeaders(var_0_2)

	local var_1_0 = arg_1_6.partyMember.controllerInfo
	local var_1_1 = arg_1_2:getNetworkService():getBlockManagerBas()
	local var_1_2 = arg_1_2:getNetworkService():getBlockListManager()

	for iter_1_0 = #arg_1_7.downloadedList, 1, -1 do
		local var_1_3 = arg_1_7.downloadedList[iter_1_0].object.sharing

		if not online_helper.getDoesSharingInfoPassUgcBlockCheck(var_1_3, var_1_0, var_1_1, var_1_2) then
			print("Removing club due to author being blocked: " .. arg_1_7.downloadedList[iter_1_0].object.fullName)
			table.remove(arg_1_7.downloadedList, iter_1_0)
		end
	end

	if #arg_1_7.downloadedList == 0 then
		arg_1_1:changeState(nil, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7)

		return
	end

	arg_1_0.viewModel:createClubList(arg_1_2, arg_1_5, arg_1_7)

	arg_1_0.viewModel.Header = native.Localise("Clubs")

	if not arg_1_0.viewModel.SelectedItem then
		arg_1_0.viewModel.SelectedItem = arg_1_0.viewModel.ListNVM:getComponent(1)
	end
end

function AcademyCommunityClubListState.refreshMenuItems(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4)
	local var_2_0 = arg_2_2:getDecalManager()
	local var_2_1 = arg_2_3.highlightedClubInfo
	local var_2_2 = var_2_1 and var_2_1.serverSortOrder or 1
	local var_2_3 = var_2_1 and var_2_1.sharingId

	arg_2_4:populateWithDownloadedClubs(arg_2_1, var_2_0, arg_2_3.downloadedList, var_2_3)

	arg_2_4.activeItemIndex = var_2_2
end

function AcademyCommunityClubListState.initPlayerModel(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4)
	if GAME_CRICKET then
		arg_3_2:playerModelGetPlayer(1):setBodyHidden(true)
	end

	arg_3_2:playerModelUpdate(1, {
		resetOptions = true,
		camera = "FullBody_OutsideOfAppearanceCommunity"
	})

	arg_3_0.playerModelRefreshAt = arg_3_1
end

function AcademyCommunityClubListState.exit(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4)
	arg_4_0:disposeQuickDownload()

	if GAME_CRICKET then
		arg_4_4:playerModelGetPlayer(1):setBodyHidden(false)
	end

	arg_4_0:disposePlayerModel(arg_4_4)
	var_0_3.exit(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4)
end

local function var_0_4(arg_5_0, arg_5_1, arg_5_2, arg_5_3)
	if arg_5_2 and arg_5_2 <= arg_5_1 then
		if not arg_5_3 then
			return
		end

		local var_5_0
		local var_5_1 = arg_5_0:getPlayerManager()
		local var_5_2 = var_5_1 and var_5_1.onDisc

		if var_5_2 then
			local var_5_3 = arg_5_3 and arg_5_3:getLineup(1)
			local var_5_4 = var_5_3 and var_5_3:getSpecialRole(native.EClubLineupSpecialRole.Captain)

			var_5_0 = var_5_4 and var_5_2:getPlayer(var_5_4)
		end

		arg_5_0:playerModelSetUniform(1, arg_5_3:getHomeUniformVisual(), arg_5_3.identity)

		local var_5_5 = var_5_0 and var_5_0.identity.sex or arg_5_3.identity.sex

		arg_5_0:playerModelUpdate(1, {
			refresh = true,
			draw = true,
			player = var_5_0,
			defaultPlayer = var_5_0 == nil,
			defaultPlayerSex = var_5_5
		})

		return
	end

	return arg_5_2
end

local function var_0_5(arg_6_0, arg_6_1)
	if arg_6_1 then
		for iter_6_0, iter_6_1 in ipairs(arg_6_0) do
			if iter_6_1.item.object == arg_6_1.object then
				return iter_6_1
			end
		end

		error("cant find club in list of downloaded clubs!")
	end
end

function AcademyCommunityClubListState.update(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7, arg_7_8, arg_7_9)
	if var_0_3.update(arg_7_0, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7, arg_7_8, arg_7_9, arg_7_1) then
		return
	end

	if arg_7_0:checkQuickDownloadUpdate(arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7, arg_7_8, arg_7_9) then
		return
	end

	local var_7_0 = arg_7_8.partyMember
	local var_7_1 = arg_7_0.viewModel

	if not var_7_1 then
		return
	end

	local var_7_2 = var_7_1:getSelectedItem()

	if not var_7_2 then
		return
	end

	if arg_7_6:playerModelGetRotationEnabled(1) then
		arg_7_6:addTooltip(nil, var_0_0.Triggers, var_0_1)
	end

	local var_7_3 = var_0_5(arg_7_9.downloadedList, var_7_2)

	if var_7_2 then
		arg_7_0.playerModelRefreshAt = var_0_4(arg_7_6, arg_7_3, arg_7_0.playerModelRefreshAt, var_7_2.object)
		var_7_1.SelectedItemChanged = false
	end

	-- copy-academy-jerseys mod: X opens the highlighted club straight into its
	-- Uniforms screen (same path as View, see the club view/hub overrides)
	if var_7_3 then
		arg_7_6:addTooltip(nil, var_0_0.X, native.Localise("Uniforms"))

		if arg_7_6:checkForRelease(var_7_0, var_0_0.X) then
			arg_7_9.highlightedObjectInfo = var_7_3
			arg_7_9.selectedRowIndex = var_7_1.SelectedRowIndex
			arg_7_9.selectedColumnIndex = var_7_1.SelectedColumnIndex
			arg_7_9.topIndex = var_7_1.TopIndex
			arg_7_9.direction = 0
			arg_7_9.openUniformsDirectly = true

			arg_7_1:changeState(arg_7_9.stateFactoryMap.View(), arg_7_2, arg_7_3, arg_7_5, arg_7_6, arg_7_8, arg_7_9)

			return
		end
	end

	local var_7_4 = arg_7_2:getInputControlDistributor():getControlManager(native.EInputControlFocusLevel.Game)

	if var_7_0:checkForRepeatingInput(arg_7_3, var_7_4, native.InputTypes.Up) then
		arg_7_0.viewModel.Direction = -1
	end

	if var_7_0:checkForRepeatingInput(arg_7_3, var_7_4, native.InputTypes.Down) then
		arg_7_0.viewModel.Direction = 1
	end
end

function AcademyCommunityClubListState.render(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4)
	var_0_3.render(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4)
end

local var_0_6 = academy_communitystate_base_download.AcademyCommunityBaseDownloadSubState

Class("AcademyCommunityClubQuickDownloadSubState", var_0_6)

function AcademyCommunityClubQuickDownloadSubState.enter(arg_9_0, arg_9_1, arg_9_2, arg_9_3, arg_9_4, arg_9_5, arg_9_6, arg_9_7)
	ASSERT(arg_9_7.item)

	local var_9_0 = arg_9_7.item

	arg_9_0.playerViewInfo = {
		downloadedClubInfo = arg_9_7,
		partyMember = arg_9_6.partyMember
	}

	local var_9_1 = arg_9_5:getSharedDataCache()
	local var_9_2 = {}
	local var_9_3 = {
		includeDecals = true,
		includeLargeImageData = true,
		dontIncDownloads = arg_9_7.dontIncDownloads or false,
		preDownloaded = arg_9_7.preDownloaded or false
	}
	local var_9_4 = {
		autoHandleMultipleCopiesOfOfficialObject = {
			saveNewAsCustom = true
		}
	}

	academy_communitystate_clubstate_download_substate.addClubToDownloadList(var_9_2, arg_9_5, var_9_1, var_9_0, var_9_3)
	var_0_6.enter(arg_9_0, arg_9_2, arg_9_3, arg_9_4, arg_9_5, arg_9_6, var_9_2, var_9_4)
end

function AcademyCommunityClubQuickDownloadSubState.update(arg_10_0, arg_10_1, arg_10_2, arg_10_3, arg_10_4, arg_10_5, arg_10_6, arg_10_7, arg_10_8)
	return (var_0_6.update(arg_10_0, arg_10_2, arg_10_3, arg_10_4, arg_10_5, arg_10_6, arg_10_7, arg_10_8, arg_10_0.playerViewInfo))
end

Class("AcademyCommunityClubPreCacheAndQuickDownloadSubState")

function AcademyCommunityClubPreCacheAndQuickDownloadSubState.enter(arg_11_0, arg_11_1, arg_11_2, arg_11_3, arg_11_4, arg_11_5, arg_11_6, arg_11_7)
	arg_11_0.downloadData = {
		queryFunction = "academy/team",
		quickDownload = true,
		viewInfo = {
			downloadedClubInfo = arg_11_7
		},
		item = arg_11_7.item,
		downloadStrategy = native.CSharingClubDownloadStrategy(),
		getInfoFactory = native.CSharingClubQuery,
		highlightedObjectInfo = arg_11_7
	}

	local var_11_0 = academy_communitystate_clubstate_viewstate_getplayers_state.AcademyCommunityClubViewGetPlayersState

	arg_11_0.stateMachine = statemachine.StateMachine(arg_11_0.__type)

	arg_11_0.stateMachine:changeState(var_11_0(), arg_11_2, arg_11_3, arg_11_4, arg_11_5, arg_11_6, arg_11_0.downloadData)
end

function AcademyCommunityClubPreCacheAndQuickDownloadSubState.exit(arg_12_0, arg_12_1, arg_12_2, arg_12_3, arg_12_4, arg_12_5)
	arg_12_0.stateMachine:changeState(nil, arg_12_1, arg_12_2, arg_12_3, arg_12_4, arg_12_5)
end

function AcademyCommunityClubPreCacheAndQuickDownloadSubState.update(arg_13_0, arg_13_1, arg_13_2, arg_13_3, arg_13_4, arg_13_5, arg_13_6, arg_13_7, arg_13_8)
	if arg_13_0.stateMachine:getCurrentState() then
		arg_13_0.stateMachine:update(arg_13_2, arg_13_3, arg_13_4, arg_13_5, arg_13_6, arg_13_7, arg_13_8, arg_13_0.downloadData)
	else
		local var_13_0 = academy_communitystate_clubstate_download_substate.AcademyCommunityClubDownloadSubState()

		arg_13_1:changeState(var_13_0, arg_13_2, arg_13_3, arg_13_5, arg_13_6, arg_13_8, arg_13_0.downloadData)
	end
end

function AcademyCommunityClubPreCacheAndQuickDownloadSubState.render(arg_14_0, arg_14_1, arg_14_2, arg_14_3, arg_14_4)
	arg_14_0.stateMachine:render(arg_14_1, arg_14_2, arg_14_3, arg_14_4)
end
