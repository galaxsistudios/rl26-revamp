import("app.academy.academy_helper")
import("app.academy.academy_referee_edit")
import("app.academy.academy_referee_list")
import("app.sharing.sharing_searchtags_aide")
import("core.statemachine.statemachine")
import("design.academy_config")

local var_0_0 = academy_referee_edit.AcademyRefereeEdit

Class("AcademyRefereeEditEdit", var_0_0)

function AcademyRefereeEditEdit.enter(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7)
	local var_1_0 = arg_1_5:getRefereeManager()
	local var_1_1

	arg_1_5:toggleLockerRoomVisibility(true)

	if var_1_0.userCreated.canCreateCount > 0 or var_1_0.userCreated:containsReferee(arg_1_7.referee.id) then
		var_1_1 = var_1_0:editOrCreateUserCreatedVersionOfReferee(arg_1_7.referee.id)
	else
		arg_1_0.immediateFail = true

		arg_1_5:blockingAlert(arg_1_2, arg_1_3, {
			options = "ok",
			canCancel = true,
			text = native.Localise("AcademyEditBlockedRefereeDatabaseFull"),
			input = arg_1_6.partyMember:getInput()
		})

		return
	end

	local var_1_2 = VERIFY(var_1_1.sharing)
	local var_1_3 = {
		isNew = false,
		referee = var_1_1,
		sex = var_1_1.identity.sex,
		sharingInformation = var_1_2,
		searchTagInfo = sharing_searchtags_aide.Tags,
		canEdit = academy_helper.getCanEdit(arg_1_5, var_1_2) and not var_1_1.isTier1,
		partyMember = arg_1_6.partyMember
	}

	var_0_0.enter(arg_1_0, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, var_1_3)
	arg_1_5:toggleLockerRoomVisibility(true)
end

function AcademyRefereeEditEdit.update(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9)
	if var_0_0.update(arg_2_0, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8) then
		local var_2_0 = arg_2_9.stateFactoryMap.List()

		arg_2_1:changeState(var_2_0, arg_2_2, arg_2_3, arg_2_5, arg_2_6, arg_2_8, arg_2_9)
	end
end

function AcademyRefereeEditEdit.exit(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5)
	arg_3_4:toggleLockerRoomVisibility(false)
	var_0_0.exit(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5)
end

local var_0_1 = academy_referee_list.AcademyRefereeListState

Class("AcademyRefereeEditList", var_0_1)

function AcademyRefereeEditList.enter(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7)
	local var_4_0 = arg_4_7.referee
	local var_4_1 = var_4_0 and var_4_0.id or nil

	arg_4_5:toggleLockerRoomVisibility(true)
	var_0_1.enter(arg_4_0, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6.partyMember, var_4_1, {
		sortAllowed = true,
		filterAllowed = false,
		exitOnSelection = true,
		backInputAllowed = true,
		playerModelConfig = {
			uniformSet = true
		},
		columns = academy_config.RefereeColumns,
		columnInitialSort = academy_config.RefereeColumnsInitialSort,
		itemParams = {},
		boxTitle = native.Localise(arg_4_7.isCoach and "EditCoach" or "EditReferee"),
		listTitle = arg_4_7.isCoach and native.Localise("Coach") or nil,
		searchOptions = assert(arg_4_7.searchOptions),
		searchOptionsReset = assert(arg_4_7.searchOptionsReset)
	})
end

function AcademyRefereeEditList.update(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7, arg_5_8, arg_5_9)
	local var_5_0, var_5_1, var_5_2, var_5_3 = var_0_1.update(arg_5_0, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7, arg_5_8.partyMember)

	if var_5_0 then
		local var_5_4

		if var_5_3 then
			arg_5_9.referee = var_5_3
			var_5_4 = arg_5_9.stateFactoryMap.Edit()
		end

		arg_5_1:changeState(var_5_4, arg_5_2, arg_5_3, arg_5_5, arg_5_6, arg_5_8, arg_5_9)
	end
end

function AcademyRefereeEditList.exit(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4)
	arg_6_4:toggleLockerRoomVisibility(false)
	var_0_1.exit(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4)
end

Class("AcademyRefereeEditState")

function AcademyRefereeEditState.enter(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7, arg_7_8)
	arg_7_0.goBackFactoryStack = assert(arg_7_8)

	arg_7_5:setBackgroundVisual("mainnotitle")

	local var_7_0 = {
		List = AcademyRefereeEditList,
		Edit = AcademyRefereeEditEdit
	}
	local var_7_1 = arg_7_6.debugHook
	local var_7_2 = var_7_1 and var_7_1.isArtist
	local var_7_3 = native.CRefereeSearchOptions()

	local var_7_5 = arg_7_7 and arg_7_7.npcType or native.CNpcType.Referee

	if not var_7_2 then
		var_7_3.mustBeType = var_7_5
	end

	local var_7_4 = native.CRefereeSearchOptions()

	var_7_4:set(var_7_3)

	arg_7_0.editInfo = {
		isCoach = var_7_5 == native.CNpcType.Coach,
		stateFactoryMap = var_7_0,
		searchOptions = var_7_3,
		searchOptionsReset = var_7_4
	}
	arg_7_0.stateMachine = statemachine.StateMachine(type(arg_7_0))

	arg_7_0.stateMachine:changeState(var_7_0.List(), arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_0.editInfo)
end

function AcademyRefereeEditState.exit(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5)
	arg_8_0.stateMachine:changeState(nil, arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5, arg_8_0.editInfo)
end

function AcademyRefereeEditState.update(arg_9_0, arg_9_1, arg_9_2, arg_9_3, arg_9_4, arg_9_5, arg_9_6, arg_9_7, arg_9_8)
	if arg_9_0.stateMachine:getCurrentState() then
		arg_9_0.stateMachine:update(arg_9_2, arg_9_3, arg_9_4, arg_9_5, arg_9_6, arg_9_7, arg_9_8, arg_9_0.editInfo)
	else
		local var_9_0 = arg_9_0.goBackFactoryStack
		local var_9_1 = var_9_0.pop and var_9_0:pop() or nil

		arg_9_1:changeState(var_9_1 and var_9_1() or nil, arg_9_2, arg_9_3, arg_9_5, arg_9_6, arg_9_8, nil, var_9_0, arg_9_0.__proto)
	end
end

function AcademyRefereeEditState.render(arg_10_0, arg_10_1, arg_10_2, arg_10_3, arg_10_4)
	arg_10_0.stateMachine:render(arg_10_1, arg_10_2, arg_10_3, arg_10_4)
end
