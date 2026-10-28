import("app.academy.academy_player_appearancestate_edit_groups")
import("app.academy.academy_appearancestate_edit_state")
import("app.academy.academy_appearancestate_exit_state")
import("app.academy.academy_helper")
import("game.player.playergenerator")

local var_0_0 = academy_appearancestate_edit_state.AppearanceEditState

Class("AcademyRefereeAppearanceEditState", var_0_0)

local var_0_1 = academy_helper.updateDecalPreviewMode

function AcademyRefereeAppearanceEditState.enter(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7, arg_1_8)
	arg_1_0.goBackFactory = arg_1_8
	arg_1_0.GroupList = arg_1_7.sex.isFemale and academy_player_appearancestate_edit_groups.FemaleRefereeGroupList or academy_player_appearancestate_edit_groups.RefereeGroupList

	if playergenerator.isCoachNPC(arg_1_7.referee) then
		local var_1_ce = arg_1_0.GroupList

		-- Body, Skin, Head, Hair
		arg_1_0.GroupList = {
			var_1_ce[1],
			var_1_ce[2],
			var_1_ce[3],
			var_1_ce[4]
		}
	end

	var_0_0.enter(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7)
end

function AcademyRefereeAppearanceEditState.update(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9)
	if arg_2_0:UGCUpdated(arg_2_8, arg_2_9) then
		return
	end

	if arg_2_6:hasFileDialogTask() and arg_2_6:fileDialogIsComplete() then
		if arg_2_6:hasFileDialogTask() == "AttachCustomFace" then
			academy_player_appearancestate_edit_groups.AttachCustomFaceCallBack(arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_8, arg_2_9)
		else
			return
		end

		arg_2_6:fileDialogDispose()
	elseif arg_2_6:hasFileDialogTask() then
		return
	end

	if arg_2_9.previewMode then
		var_0_1(arg_2_2, arg_2_6, arg_2_9)
	else
		var_0_0.update(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9)
	end
end

AcademyRefereeAppearanceEditState.OverlaySupported = native.getPlatformString() == "win32"
AcademyRefereeAppearanceEditState.ViewModeSupported = false
AcademyRefereeAppearanceEditState.ExitStateFactory = academy_appearancestate_exit_state.AppearanceExitState
