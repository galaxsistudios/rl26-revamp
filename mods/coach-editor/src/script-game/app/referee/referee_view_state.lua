import("app.academy.academy_helper")
import("app.referee.referee_viewstate_hub_state")
import("app.save.save_aide")
import("app.sharing.sharing_searchtags_aide")
import("core.statemachine.statemachine")
import("game.player.playergenerator")

local var_0_0 = native.InputTypes

Class("RefereeViewState")

function RefereeViewState.enter(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6)
	local var_1_0 = arg_1_5.partyMember
	local var_1_1 = arg_1_4:getRefereeManager()
	local var_1_2 = arg_1_6.ethnicity
	local var_1_3 = {
		partyMember = var_1_0,
		refereeManager = var_1_1,
		tiles = VERIFY(arg_1_6.tiles),
		searchTagInfo = sharing_searchtags_aide.Tags,
		downloadedRefereeInfo = arg_1_6.downloadedRefereeInfo,
		inCommunity = arg_1_6.downloadedRefereeInfo ~= nil,
		playerHoldStick = arg_1_0.PlayerHoldStick,
		sex = arg_1_6.sex,
		ethnicity = var_1_2,
		stateFactoryMap = arg_1_6.stateFactoryMap,
		searchOptions = arg_1_6.searchOptions,
		searchOptionsReset = arg_1_6.searchOptionsReset
	}

	arg_1_0.refereeViewInfo = var_1_3

	save_aide.addDirtySaveHelper(var_1_3, arg_1_4, var_1_0, false, true)

	local var_1_4

	if arg_1_6.referee then
		if arg_1_6.canEdit then
			var_1_4 = var_1_1:editOrCreateUserCreatedVersionOfReferee(arg_1_6.referee.id)
		else
			var_1_4 = arg_1_6.referee
		end
	elseif arg_1_6.playerId then
		var_1_4 = var_1_1:getReferee(arg_1_6.refereeId)
	end

	if arg_1_6.canEdit and not var_1_4 then
		var_1_3.creatingNewReferee = true

		if var_1_1.userCreated.canCreateCount == 0 then
			arg_1_0.immediateFail = true

			arg_1_4:blockingAlert(arg_1_1, arg_1_2, {
				options = "ok",
				canCancel = true,
				text = arg_1_6.npcType == native.CNpcType.Coach and playergenerator.coachText("AcademyEditBlockedRefereeDatabaseFull") or native.Localise("AcademyEditBlockedRefereeDatabaseFull"),
				input = var_1_0:getInput()
			})

			return
		end

		local var_1_5 = arg_1_4:getDefaultPlayerVisualManager()
		local var_1_6 = arg_1_4:getDefaultTeamVisualManager()
		local var_1_7 = playergenerator.createBogStandardNPCWithEthnicity(arg_1_6.npcType or native.CNpcType.Referee, var_1_3.sex, var_1_3.ethnicity, var_1_5, var_1_6)

		arg_1_4:playerModelUpdate(1, {
			refresh = true
		})

		local var_1_8 = var_1_1.userCreated:addReferee(var_1_7)

		var_1_4 = var_1_1.userCreated:getReferee(var_1_8)
	end

	ASSERT(var_1_4)

	var_1_3.referee = var_1_4
	var_1_3.refereeId = var_1_4.id
	var_1_3.sharingInformation = var_1_4.sharing

	local var_1_9

	if arg_1_0.checkReadOnlyStatus then
		var_1_9 = arg_1_0:checkReadOnlyStatus(arg_1_4, arg_1_6)
	end

	var_1_3.canEdit = arg_1_6.canEdit and not var_1_9 or false
	var_1_3.canEditAttributes = arg_1_6.canEditAttributes and not var_1_9 or false
	var_1_3.canEditSkills = arg_1_6.canEditSkills and not var_1_9 or false
	var_1_3.canRandomiseSkills = arg_1_6.canRandomiseSkills and not var_1_9 or false

	arg_1_4:setPlayerModelProps(1, arg_1_6.props)

	arg_1_0.originalPlayerDrawnEnabledState = arg_1_4:playerModelUpdate(1, {
		draw = true,
		resetOptions = true,
		rotationEnabled = true,
		refresh = true,
		referee = var_1_3.referee,
		characterVisualOptions = academy_helper.VisualConfigSets.RefereeDefault
	})

	arg_1_4:forEachHookFn("setRefereeViewInfo", var_1_3)

	arg_1_0.stateMachine = statemachine.StateMachine(arg_1_0.__type)

	arg_1_0.stateMachine:changeState(referee_viewstate_hub_state.RefereeViewHubState(), arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, var_1_3)
end

function RefereeViewState.update(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8)
	local var_2_0 = arg_2_0.refereeViewInfo
	local var_2_1 = arg_2_0.stateMachine
	local var_2_2 = var_2_1 and var_2_1:getCurrentState()

	if var_2_0 then
		var_2_0.saveUpdate(arg_2_1)
	end

	if var_2_2 then
		arg_2_0.stateMachine:update(arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, var_2_0)
	else
		return arg_2_8(var_2_0)
	end
end

function RefereeViewState.render(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5)
	local var_3_0 = arg_3_0.stateMachine

	if var_3_0 and var_3_0:getCurrentState() then
		arg_3_0.stateMachine:render(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5)
	end
end

function RefereeViewState.exit(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5)
	arg_4_4:useFavouriteClubColourSet(arg_4_1)

	local var_4_0 = arg_4_0.refereeViewInfo

	if arg_4_0.immediateFail then
		return
	end

	arg_4_0.stateMachine:changeState(nil, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, var_4_0)
	arg_4_4:playerModelUpdate(1, {
		draw = arg_4_0.originalPlayerDrawnEnabledState
	})

	if var_4_0.creatingCustomExistingReferee then
		local var_4_1 = VERIFY(arg_4_4:getRefereeManager())
		local var_4_2 = var_4_0.referee

		if var_4_0.getChangesSaved() then
			var_4_0.setDirty()
		end
	end

	var_4_0.saveIfDirty(arg_4_1)
	arg_4_4:forEachHookFn("setRefereeViewInfo")
end

function RefereeViewState.isUnchangedAndNew(arg_5_0)
	local var_5_0 = arg_5_0.refereeViewInfo

	ASSERT(var_5_0)

	return var_5_0 and var_5_0.isUnchangedAndNew
end
