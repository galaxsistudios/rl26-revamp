import("app.academy.academy_referee_list")
import("core.foundation.stringx")
import("design.academy_config")
import("game.player.playergenerator")

local var_0_0 = academy_referee_list.AcademyRefereeListState

Class("AcademyRefereeDeleteState", var_0_0)

function AcademyRefereeDeleteState.enter(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7, arg_1_8)
	arg_1_0.goBackFactoryStack = assert(arg_1_8)

	local var_1_0 = native.CRefereeSearchOptions()

	local var_1_3 = arg_1_7 and arg_1_7.npcType or native.CNpcType.Referee

	var_1_0.mustBeType = var_1_3
	var_1_0.onlyShowUserCreated = true

	local var_1_1 = native.CRefereeSearchOptions()

	var_1_1:set(var_1_0)

	local var_1_2

	arg_1_5:toggleLockerRoomVisibility(true)
	var_0_0.enter(arg_1_0, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6.partyMember, var_1_2, {
		sortAllowed = true,
		exitOnSelection = false,
		filterAllowed = false,
		backInputAllowed = true,
		homeInputAllowed = true,
		playerModelConfig = {
			uniformSet = true
		},
		columns = academy_config.RefereeColumns,
		columnInitialSort = academy_config.RefereeColumnsInitialSort,
		itemParams = {},
		boxTitle = var_1_3 == native.CNpcType.Coach and playergenerator.coachText("DeleteReferee") or native.Localise("DeleteReferee"),
		listTitle = var_1_3 == native.CNpcType.Coach and playergenerator.coachText("Referee") or nil,
		searchOptions = var_1_0,
		searchOptionsReset = var_1_1
	})
	arg_1_5:toggleLockerRoomVisibility(true)
end

function AcademyRefereeDeleteState.update(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8)
	local var_2_0, var_2_1, var_2_2, var_2_3 = var_0_0.update(arg_2_0, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8.partyMember)

	if var_2_0 then
		local var_2_4 = arg_2_0.goBackFactoryStack
		local var_2_5 = var_2_4:pop()

		arg_2_1:changeState(var_2_5 and var_2_5() or nil, arg_2_2, arg_2_3, arg_2_5, arg_2_6, arg_2_8, nil, var_2_4, arg_2_0.__proto)
	elseif var_2_3 then
		local var_2_6 = arg_2_8.partyMember
		local var_2_7 = arg_2_6:getRefereeManager()
		local var_2_8 = var_2_3.id

		arg_2_6:blockingAlert(arg_2_2, arg_2_3, {
			options = "yesno",
			canCancel = true,
			text = stringx.interp(playergenerator.npcText(var_2_3, "RefereeDeleteConfirm"), {
				name = var_2_3.fullName
			}),
			input = var_2_6:getInput(),
			onSelected = function(arg_3_0, arg_3_1, arg_3_2)
				if arg_3_2 and arg_3_2.val then
					arg_2_0:immediateRefreshPlayerModel(arg_2_6, arg_3_1, arg_2_8.partyMember, nil, arg_2_0.listConfig)
					var_2_7.userCreated:deleteReferee(var_2_8)
					arg_2_6:profileSaveFrontEndData(var_2_6)
					arg_2_0:refreshMenuItems(arg_2_6, var_2_6)
				end
			end
		})
	end
end

function AcademyRefereeDeleteState.exit(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4)
	arg_4_4:toggleLockerRoomVisibility(false)
	var_0_0.exit(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4)
end
