import("app.academy.academy_player_appearance_state")
import("app.academy.academy_player_appearancestate_edit_groups")

local var_0_0 = academy_player_appearance_state.AcademyPlayerAppearanceState

Class("AcademyPlayerViewAppearanceState", var_0_0)

function AcademyPlayerViewAppearanceState.enter(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7, arg_1_8)
	arg_1_0.goBackFactory = arg_1_8

	local var_1_0 = arg_1_6 and arg_1_6.debugHook and arg_1_6.debugHook.isArtist
	local var_1_1 = var_1_0 and academy_player_appearancestate_edit_groups.DebugGroupListMale or academy_player_appearancestate_edit_groups.GroupList
	local var_1_2 = var_1_0 and academy_player_appearancestate_edit_groups.DebugGroupListFemale or academy_player_appearancestate_edit_groups.FemaleGroupList

	-- unlock-tier1-editing: scanned players keep their face; no Head, Hair or Skin tabs
	if not var_1_0 and arg_1_7.isTier1 then
		var_1_1 = academy_player_appearancestate_edit_groups.Tier1GroupList
		var_1_2 = academy_player_appearancestate_edit_groups.Tier1FemaleGroupList
	end

	arg_1_7.editGroups = arg_1_7.sex == native.CSex.Female and var_1_2 or var_1_1

	var_0_0.enter(arg_1_0, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7)
end

function AcademyPlayerViewAppearanceState.update(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9)
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

	if var_0_0.update(arg_2_0, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9) then
		arg_2_9.saveIfDirty(arg_2_2)
		arg_2_1:changeState(arg_2_0.goBackFactory(), arg_2_2, arg_2_3, arg_2_5, arg_2_6, arg_2_8, arg_2_9, arg_2_0.__proto)
	end
end
