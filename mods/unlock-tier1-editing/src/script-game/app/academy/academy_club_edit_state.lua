import("core.statemachine.statemachine")
import("app.club.club_view_state")
import("app.academy.academy_clubselect_state")
import("app.academy.academy_club_viewstate_tiles")

local var_0_0 = native.InputTypes
local var_0_1 = academy_clubselect_state.AcademyClubSelectState

Class("AcademyClubEditClubSelectState", var_0_1)

AcademyClubEditClubSelectState.LeaguelessClubsEnabled = true
AcademyClubEditClubSelectState.ShowCaptain = true

function AcademyClubEditClubSelectState.enter(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7)
	local var_1_0 = "HelpAcademyClubSelectEdit"
	local var_1_1 = true

	var_0_1.enter(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6.partyMember, var_1_0, var_1_1, arg_1_7.leagueId, arg_1_7.clubId, nil, nil, nil, nil, arg_1_6.debugHook)
	arg_1_5:toggleLockerRoomVisibility(true)
end

function AcademyClubEditClubSelectState.createSearchOptions(arg_2_0)
	return native.CClubSearchOptions()
end

function AcademyClubEditClubSelectState.update(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9)
	local function var_3_0(arg_4_0, arg_4_1)
		local var_4_0 = arg_3_6:getClubManager()

		if var_4_0.userCreated:containsClub(arg_4_1) or var_4_0.userCreated.canCreateCount > 0 then
			return true
		else
			arg_3_6:blockingAlert(arg_3_2, arg_3_3, {
				options = "ok",
				canCancel = true,
				text = native.Localise("AcademyEditBlockedTeamDatabaseFull"),
				input = arg_3_8.partyMember:getInput()
			})
		end
	end

	local var_3_1
	local var_3_2, var_3_3, var_3_4, var_3_5 = var_0_1.update(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8.partyMember, var_3_0, var_3_1)

	if var_3_2 then
		local var_3_6

		if var_3_3 then
			arg_3_9.leagueId = var_3_4
			arg_3_9.clubId = var_3_5
			var_3_6 = arg_3_9.stateFactoryMap.Edit()
		end

		arg_3_1:changeState(var_3_6, arg_3_2, arg_3_3, arg_3_5, arg_3_6, arg_3_8, arg_3_9)
	end
end

function AcademyClubEditClubSelectState.exit(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5)
	arg_5_4:toggleLockerRoomVisibility(false)

	if arg_5_0.subState then
		arg_5_0.subState:exit(arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5)

		arg_5_0.subState = nil
	end

	var_0_1.exit(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5)
end

local var_0_2 = club_view_state.ClubViewState

Class("AcademyClubEditViewState", var_0_2)

function AcademyClubEditViewState.enter(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7)
	local var_6_0 = arg_6_7.clubId
	local var_6_1 = arg_6_5:getClubManager().userCreated.canCreateCount > 0

	var_0_2.enter(arg_6_0, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, {
		title = native.Localise("EditClub"),
		canEdit = var_6_1,
		clubId = var_6_0,
		leagueId = arg_6_7.leagueId,
		tiles = academy_club_viewstate_tiles.CreateTiles(arg_6_6.partyMember, arg_6_5, arg_6_7)
	})

	-- unlock-tier1-editing: official (on-disc) clubs lock Identity (names, emblem, colours,
	-- commentary names) and Home Grounds on isOnDiscClub. The view reads it lazily, so
	-- clearing it here unlocks them. Edits to official clubs are still saved by
	-- ClubViewState.exit (saveCustomLicensed), which checks the club id, not this flag.
	local var_6_2 = arg_6_0.clubViewInfo

	if var_6_2 and var_6_2.canEdit and var_6_2.isOnDiscClub then
		var_6_2.isOnDiscClub = false
		var_6_2.unlockTier1WasOnDiscClub = true
	end
end

function AcademyClubEditViewState.update(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7, arg_7_8, arg_7_9)
	local function var_7_0()
		arg_7_1:changeState(arg_7_9.stateFactoryMap.ClubSelect(), arg_7_2, arg_7_3, arg_7_5, arg_7_6, arg_7_8, arg_7_9)
	end

	var_0_2.update(arg_7_0, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7, arg_7_8, var_7_0)
end

function AcademyClubEditViewState.checkReadOnlyStatus(arg_9_0, arg_9_1, arg_9_2)
	local var_9_0 = arg_9_2.club

	if arg_9_2.canEdit then
		local var_9_1 = arg_9_1:sharingGetUserId()

		if not (var_9_1 == var_9_0.sharing.originalAuthor or var_9_1 == var_9_0.sharing.currentAuthor) and arg_9_2.sharingInformation.isOnSharingServer then
			return var_9_0.sharing.readOnly
		end
	end
end

Class("AcademyClubEditState")

function AcademyClubEditState.enter(arg_10_0, arg_10_1, arg_10_2, arg_10_3, arg_10_4, arg_10_5, arg_10_6, arg_10_7, arg_10_8)
	arg_10_0.goBackFactoryStack = assert(arg_10_8)

	local var_10_0 = {
		ClubSelect = AcademyClubEditClubSelectState,
		Edit = AcademyClubEditViewState
	}

	arg_10_0.editInfo = {
		stateFactoryMap = var_10_0
	}
	arg_10_0.stateMachine = statemachine.StateMachine(type(arg_10_0))

	arg_10_0.stateMachine:changeState(var_10_0.ClubSelect(), arg_10_2, arg_10_3, arg_10_4, arg_10_5, arg_10_6, arg_10_0.editInfo)
end

function AcademyClubEditState.exit(arg_11_0, arg_11_1, arg_11_2, arg_11_3, arg_11_4, arg_11_5)
	arg_11_0.stateMachine:changeState(nil, arg_11_1, arg_11_2, arg_11_3, arg_11_4, arg_11_5, arg_11_0.editInfo)
end

function AcademyClubEditState.update(arg_12_0, arg_12_1, arg_12_2, arg_12_3, arg_12_4, arg_12_5, arg_12_6, arg_12_7, arg_12_8)
	if arg_12_0.stateMachine:getCurrentState() then
		arg_12_0.stateMachine:update(arg_12_2, arg_12_3, arg_12_4, arg_12_5, arg_12_6, arg_12_7, arg_12_8, arg_12_0.editInfo)
	else
		local var_12_0 = arg_12_0.goBackFactoryStack

		arg_12_1:changeState(nil, arg_12_2, arg_12_3, arg_12_5, arg_12_6, arg_12_8, nil, var_12_0, arg_12_0.__proto)
	end
end

function AcademyClubEditState.render(arg_13_0, arg_13_1, arg_13_2, arg_13_3, arg_13_4, arg_13_5)
	arg_13_0.stateMachine:render(arg_13_1, arg_13_2, arg_13_3, arg_13_4)
end
