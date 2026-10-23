import("app.academy.academy_referee_viewstate_tiles")
import("app.referee.referee_view_state")
import("core.foundation.class")
import("core.foundation.tablex")
import("core.statemachine.statemachine")
import("design.academy_config")

local var_0_0 = referee_view_state.RefereeViewState

Class("AcademyRefereeCreateViewState", var_0_0)

function AcademyRefereeCreateViewState.enter(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7)
	var_0_0.enter(arg_1_0, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, tablex.merge(arg_1_7, {
		canEdit = true,
		title = native.Localise("CreateReferee"),
		tiles = academy_referee_viewstate_tiles.CreateTiles(arg_1_6.partyMember, arg_1_6)
	}))

	arg_1_0.exitWaitTime = academy_config.CreatePlayerExitWaitTime
end

function AcademyRefereeCreateViewState.setExitingWithUnchangedNewReferee(arg_2_0, arg_2_1)
	arg_2_0.exitingWithUnchangedNewReferee = arg_2_1
end

function AcademyRefereeCreateViewState.getExitingWithUnchangedNewReferee(arg_3_0)
	return arg_3_0.exitingWithUnchangedNewReferee
end

function AcademyRefereeCreateViewState.update(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7, arg_4_8, arg_4_9)
	local function var_4_0()
		arg_4_0.exitAt = arg_4_3 + arg_4_0.exitWaitTime

		arg_4_0:setExitingWithUnchangedNewReferee(arg_4_0.isUnchangedAndNew and arg_4_0:isUnchangedAndNew())
	end

	local var_4_1 = arg_4_0.exitAt

	if var_4_1 then
		if var_4_1 < arg_4_3 then
			arg_4_1:changeState(nil, arg_4_2, arg_4_3, arg_4_5, arg_4_6, arg_4_8, arg_4_9)
			arg_4_0:setExitingWithUnchangedNewReferee(nil)
		end

		return
	end

	var_0_0.update(arg_4_0, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7, arg_4_8, var_4_0)
end

Class("AcademyRefereeCreateState")

function AcademyRefereeCreateState.enter(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8)
	arg_6_0.goBackFactoryStack = arg_6_8
	arg_6_0.originalGoBackFactoryStack = arg_6_7.originalGoBackFactoryStack

	local var_6_0 = {
		Edit = AcademyRefereeCreateViewState
	}
	local var_6_1 = {
		stateFactoryMap = var_6_0,
		sex = arg_6_7.sex,
		ethnicity = arg_6_7.ethnicity,
		npcType = arg_6_7.npcType
	}

	arg_6_0.createInfo = var_6_1

	local var_6_2 = statemachine.StateMachine(type(arg_6_0))

	arg_6_0.stateMachine = var_6_2

	var_6_2:changeState(var_6_0.Edit(), arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, var_6_1)
	arg_6_5:toggleLockerRoomVisibility(true)
end

function AcademyRefereeCreateState.update(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7, arg_7_8)
	local var_7_0 = arg_7_0.stateMachine:getCurrentState()

	if var_7_0 then
		arg_7_0.stateMachine:update(arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7, arg_7_8, arg_7_0.createInfo)

		arg_7_0.exitingWithUnchangedNewReferee = arg_7_0.exitingWithUnchangedNewReferee or var_7_0.getExitingWithUnchangedNewReferee and var_7_0:getExitingWithUnchangedNewReferee()
	else
		local var_7_1 = arg_7_0.createInfo
		local var_7_2 = var_7_1.sex

		if arg_7_0.exitingWithUnchangedNewReferee then
			arg_7_0.exitingWithUnchangedNewReferee = nil

			local var_7_3 = arg_7_0.goBackFactoryStack
			local var_7_4 = table.remove(var_7_3)
			local var_7_5 = {
				ethnicity = var_7_1.ethnicity
			}
			local var_7_6 = {
				sex = var_7_2,
				npcType = var_7_1.npcType,
				originalGoBackFactoryStack = arg_7_0.originalGoBackFactoryStack
			}

			arg_7_1:changeState(var_7_4(), arg_7_2, arg_7_3, arg_7_5, arg_7_6, arg_7_8, var_7_6, var_7_3, arg_7_0.__proto, var_7_5)
		else
			local var_7_7 = {
				sex = var_7_2,
				npcType = var_7_1.npcType
			}

			arg_7_1:changeState(nil, arg_7_2, arg_7_3, arg_7_5, arg_7_6, arg_7_8, nil, arg_7_0.originalGoBackFactoryStack, class.instantiate("AcademyRefereeCreateEthnicityState").__proto, var_7_7)
		end
	end
end

function AcademyRefereeCreateState.render(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5)
	arg_8_0.stateMachine:render(arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5, arg_8_0.createInfo)
end

function AcademyRefereeCreateState.exit(arg_9_0, arg_9_1, arg_9_2, arg_9_3, arg_9_4, arg_9_5)
	arg_9_0.stateMachine:changeState(nil, arg_9_1, arg_9_2, arg_9_3, arg_9_4, arg_9_5, arg_9_0.editInfo)
	arg_9_4:toggleLockerRoomVisibility(false)
end
