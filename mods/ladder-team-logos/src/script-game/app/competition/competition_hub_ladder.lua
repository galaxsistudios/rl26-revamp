import("app.noesis.competition.nvm_competitionladder")

local var_0_0 = native.InputTypes

Class("CompetitionHubLadder")

function CompetitionHubLadder.enter(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7, arg_1_8)
	arg_1_0.viewModel = nvm_competitionladder.NVMCompetitionLadder(arg_1_6, arg_1_8)
	arg_1_0.viewInfo = arg_1_8

	arg_1_0.viewModel:setLogoContext(arg_1_2, arg_1_5)

	arg_1_7.competitionHubNVM:addTab(arg_1_0.viewModel)
	arg_1_0:refreshLadder(arg_1_6.career)
end

function CompetitionHubLadder.refreshLadder(arg_2_0, arg_2_1)
	local var_2_0 = arg_2_0.viewInfo
	local var_2_1 = var_2_0.fixtureIndex
	local var_2_2 = var_2_0.competition
	local var_2_3 = native.CareerLadder()

	var_2_2:getLadder(var_2_3, var_2_1)

	local var_2_4 = var_2_2:getFixture(var_2_1)

	arg_2_0.viewModel:populateLadder(arg_2_1, var_2_2:getLadderConfig(var_2_1), var_2_3, arg_2_1.user.coachClubId, var_2_4.name)
end

function CompetitionHubLadder.exit(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5)
	return
end

function CompetitionHubLadder.onFocus(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7, arg_4_8)
	arg_4_0:refreshLadder(arg_4_6.career)

	arg_4_0.nextFixtureIndex = arg_4_7.checkForNextFixture(arg_4_6.career, arg_4_0.viewInfo.competition)
end

function CompetitionHubLadder.update(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7, arg_5_8, arg_5_9)
	local var_5_0 = arg_5_8.partyMember

	if arg_5_0.viewModel.updated then
		arg_5_0.viewModel.SelectedIndex = 0
		arg_5_0.viewModel.updated = false
	end

	arg_5_6:addTooltip(nil, var_0_0.Decline, native.Localise("Back"), 99)

	if arg_5_6:checkForRelease(var_5_0, var_0_0.Decline) then
		arg_5_6:playSound("Back")

		arg_5_0.exitAt = arg_5_3 + 0.3
	else
		arg_5_0.homeScreenPartyMember = arg_5_6:homeScreenCheckForInput(arg_5_2, arg_5_3, arg_5_5)

		if arg_5_0.homeScreenPartyMember then
			arg_5_6:playSound("Back")

			arg_5_0.exitAt = arg_5_3 + 0.3
		end
	end

	local var_5_1 = arg_5_0.nextFixtureIndex

	if var_5_1 then
		arg_5_6:addTooltip(nil, var_0_0.Y, native.Localise("GoToNextFixtureStr"), 3)

		if arg_5_6:checkForRelease(var_5_0, var_0_0.Y) then
			arg_5_1:changeState(var_5_1, arg_5_2, arg_5_3, arg_5_5, arg_5_6, arg_5_8, arg_5_9)

			arg_5_9.stateIndex = var_5_1
			arg_5_9.stateNameDrivesTab = true
		end
	end
end

function CompetitionHubLadder.render(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4)
	return
end
