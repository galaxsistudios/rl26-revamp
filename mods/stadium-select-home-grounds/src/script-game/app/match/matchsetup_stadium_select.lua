import("app.noesis.academy.nvm_stadium_list")
Class("MatchSetupStadiumSelect")

GrandFinalsStadiums = {
	"stadiumAustralia",
	"manchesterStadium"
}

local function var_0_0(arg_1_0)
	arg_1_0:addTooltip(nil, native.InputTypes.Accept, native.Localise("Accept"))
	arg_1_0:addTooltip(nil, native.InputTypes.Decline, native.Localise("Back"))
end

local function var_0_1(arg_2_0, arg_2_1, arg_2_2)
	local var_2_0 = nvm_stadium_list.paNVMStadiumSelectView(arg_2_0, arg_2_1)

	if arg_2_2 == false then
		var_2_0:addTabItem(native.Localise("LevelEditorHelpStadiums"), arg_2_0, arg_2_1):populateWithOnDiscStadiums(arg_2_1)
		var_2_0:addTabItem(native.Localise("Custom"), arg_2_0, arg_2_1):populateWithCustomStadiums(arg_2_1, true, true)
	else
		var_2_0:addTabItem(native.Localise("LevelEditorHelpStadiums"), arg_2_0, arg_2_1):populateWithGrandFinalStadiums(arg_2_1)
	end

	return var_2_0
end

function MatchSetupStadiumSelect.enter(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6)
	local var_3_0 = arg_3_6.isGrandFinal or false

	arg_3_0.isGrandFinal = var_3_0
	arg_3_0.viewModel = var_0_1(arg_3_2, arg_3_5, var_3_0)
	arg_3_0.view = arg_3_2:getNoesis():loadViewWithVM("Workspace/Views/Academy/paStadiumSelectView", arg_3_0.viewModel, native.ENoesisViewManagerLayer.POST_SCENE, native.CNoesisViewManager.DefaultPriority)
end

function MatchSetupStadiumSelect.update(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7, arg_4_8, arg_4_9, arg_4_10, arg_4_11, arg_4_12)
	if not arg_4_0.firstFrameInputHandled then
		arg_4_0.firstFrameInputHandled = true

		if not arg_4_0.isGrandFinal then
			arg_4_0:addClubHomeGrounds(arg_4_2, arg_4_6, arg_4_9)
		end

		return
	end

	local var_4_0 = VERIFY(arg_4_8.partyMember)

	if arg_4_0.viewModel then
		arg_4_0.viewModel:update(arg_4_2, arg_4_6, arg_4_4)
	end

	var_0_0(arg_4_6)

	local function var_4_1()
		arg_4_1:changeState(arg_4_10.stateFactoryMap.MatchSettings(), arg_4_2, arg_4_3, arg_4_5, arg_4_6, arg_4_8, arg_4_9, arg_4_10)
	end

	if arg_4_6:checkForRelease(var_4_0, native.InputTypes.Accept) and arg_4_0:acceptStadiumSelection(arg_4_9) then
		var_4_1()

		return
	end

	if arg_4_6:checkForRelease(var_4_0, native.InputTypes.Decline) then
		var_4_1()
	end
end

-- Rebuild the on-disc tab with the home then away club's home ground at the top
function MatchSetupStadiumSelect.addClubHomeGrounds(arg_5_0, arg_5_1, arg_5_2, arg_5_3)
	local var_5_0 = arg_5_3 and arg_5_3.matchSettingsSynchroniser
	local var_5_1 = arg_5_0.viewModel and arg_5_0.viewModel.TabItems:getComponent(1)

	if not var_5_0 or not var_5_1 then
		return
	end

	local var_5_2 = {
		home = var_5_0:getLobbyClub("home"),
		away = var_5_0:getLobbyClub("away")
	}

	if not var_5_2.home and not var_5_2.away then
		return
	end

	var_5_1:populateWithOnDiscStadiums(arg_5_2, var_5_2, arg_5_1)
	var_5_1:refresh()
	arg_5_0.viewModel:setStadiumPreviewTexture(arg_5_1, arg_5_2)
end

function MatchSetupStadiumSelect.acceptStadiumSelection(arg_6_0, arg_6_1)
	local var_6_0 = arg_6_0.viewModel:getCurrentTabSelectedItem()

	if var_6_0 then
		arg_6_1.stadiumSelectedByPlayer = true

		local var_6_1 = VERIFY(arg_6_1.matchSettingsSynchroniser)
		local var_6_2 = var_6_0:getCustomStadiumData()

		if var_6_2 then
			var_6_1:setMatchSettings({
				ground = native.Stadiums.getKey(native.EStadiums.creator),
				groundId = var_6_2.id,
				groundSharingId = var_6_2.sharing.sharingId
			})
		else
			local var_6_3 = var_6_0:getOnDiscStadiumData()

			if var_6_3 then
				var_6_1:setMatchSettings({
					ground = var_6_3.stadium,
					groundId = var_6_3.stadiumId,
					groundSharingId = var_6_3.stadiumSharingId
				})
			end
		end

		return true
	end

	return false
end

function MatchSetupStadiumSelect.exit(arg_7_0)
	if arg_7_0.view then
		arg_7_0.view:release()

		arg_7_0.view = nil
	end

	if arg_7_0.viewModel then
		arg_7_0.viewModel:dispose()

		arg_7_0.viewModel = nil
	end
end
