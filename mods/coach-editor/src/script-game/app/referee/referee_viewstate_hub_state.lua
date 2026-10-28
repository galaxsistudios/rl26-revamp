import("app.academy.viewhubbase_state")
import("core.foundation.stringx")
import("game.player.playergenerator")

local var_0_0 = viewhubbase_state.ViewHubBaseState

Class("RefereeViewHubState", var_0_0)

function RefereeViewHubState.enter(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7, arg_1_8, arg_1_9)
	ASSERT(arg_1_7.tiles)

	arg_1_7.camera = "HeadAndShoulders_OutsideOfAppearance"

	var_0_0.enter(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_7, arg_1_8, arg_1_9)
end

function RefereeViewHubState.getBackInputAlertParams(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6)
	if arg_2_6.creatingNewReferee then
		if arg_2_6.getHaveEverBeenDirty() then
			nop()
		else
			local var_2_0 = arg_2_4:getRefereeManager()

			arg_2_6.isUnchangedAndNew = true

			return {
				options = "yesno",
				canCancel = true,
				text = stringx.interp(playergenerator.npcText(arg_2_6.referee, "RefereeDeleteConfirm"), {
					name = arg_2_6.referee.fullName
				}),
				onSelected = function(arg_3_0, arg_3_1, arg_3_2)
					if arg_3_2 then
						if arg_3_2.val then
							var_2_0.userCreated:deleteReferee(arg_2_6.refereeId)
							arg_2_4:showNotification("alert", playergenerator.npcText(arg_2_6.referee, "UnchangedUmpireDeleted"))
						else
							arg_2_6.setDirty()
							arg_2_6.saveIfDirty(arg_3_0)
						end

						arg_2_0.exitAt = arg_3_1
					end
				end
			}
		end
	end
end
