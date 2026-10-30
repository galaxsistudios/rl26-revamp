import("app.online.online_matchreporting_state")
import("app.online.online_error_state")
import("core.statemachine.statemachine")
import("design.loading_setup_helper")

local var_0_0 = 3
local var_0_1 = 0.1

Class("MatchSetupLockdown")

function MatchSetupLockdown.enter(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7, arg_1_8)
	print("entering lockdown match state")

	local var_1_0 = arg_1_7.gameMode
	local var_1_1 = arg_1_7.isOnlineMatch

	arg_1_0.wantOnlineMatchReporting = var_1_1 and var_1_0 ~= native.EGameMode.ProTeamSingleMatch and var_1_0 ~= native.EGameMode.PremiershipChallenge
	arg_1_0.matchSetupData = arg_1_8
	arg_1_0.matchData = arg_1_7

	-- loading-screen-secondary-arrows: a new match - forget the last competition
	-- until matchin.finalise reports this one
	rawset(_G, "MOD_LOADING_COMPETITION", nil)
	rawset(_G, "MOD_LOADING_STADIUM", nil)
	arg_1_0.metagameModeData = arg_1_6

	local var_1_2 = arg_1_7.matchSettingsSynchroniser

	if var_1_1 or arg_1_7.isDynasty then
		print("Online match, deferring the loading screen setup until after players are confirmed ready")

		arg_1_0.setupOnlineLoadingScreen = true

		native.showLoadingScreen("Default")
	else
		print("not online match, showing loading screen")

		local var_1_3 = arg_1_2:getLoadingScreen()

		native.showLoadingScreen("Default")
		native.showLoadingScreen("TeamLoading")
		var_1_3:toggleContinueText(false)
		arg_1_0:setupLoadingScreenLocal(arg_1_2, arg_1_5, var_1_2:getLobbyClub("home"), var_1_2:getLobbyClub("away"))
	end

	arg_1_5:prepareForTransition(arg_1_2, arg_1_3)
	var_1_2:setLocalMachineReady()
end

function MatchSetupLockdown.setupLoadingScreenLocal(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4)
	local var_2_0 = loading_setup_helper.SetupLoadingScreen(arg_2_1, arg_2_2, arg_2_3, arg_2_4)

	native.setTeamsLoadingProps(var_2_0)
end

function MatchSetupLockdown.setupLoadingScreenOnline(arg_3_0, arg_3_1, arg_3_2, arg_3_3)
	local var_3_0

	if arg_3_3 then
		var_3_0 = loading_setup_helper.SetupLoadingScreenProTeam(arg_3_1, arg_3_2)
	else
		var_3_0 = loading_setup_helper.SetupLoadingScreenOnline(arg_3_1, arg_3_2)
	end

	if var_3_0 then
		native.setTeamsLoadingProps(var_3_0)
	end
end

function MatchSetupLockdown.exit(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7)
	if arg_4_0.stateMachine and arg_4_0.stateMachine:getCurrentState() then
		arg_4_0.stateMachine:changeState(nil, arg_4_1, arg_4_2, arg_4_3, arg_4_4)
	end
end

function MatchSetupLockdown.update(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7, arg_5_8, arg_5_9, arg_5_10)
	if arg_5_6:updateBlockingMixins(arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_7) then
		print("waiting for blocking mixins to complete")
		native.hideLoadingScreen("Default")
		native.hideLoadingScreen("TeamLoading")

		arg_5_0.hideLoadingScreen = true

		return
	end

	if arg_5_0.hideLoadingScreen then
		native.showLoadingScreen("Default")

		arg_5_0.hideLoadingScreen = false

		return
	end

	arg_5_9 = arg_5_0.matchData or arg_5_9
	arg_5_8 = arg_5_0.metagameModeData or arg_5_8

	local var_5_0 = arg_5_8.partyMember
	local var_5_1 = VERIFY(arg_5_9.matchSettingsSynchroniser)

	if not var_5_1:update(arg_5_2, arg_5_4) then
		print("[MatchSetupLockdown] mss:update has returned an error")

		local function var_5_2(arg_6_0)
			arg_5_6:homeScreenEnter(arg_5_2, arg_6_0, arg_5_5, arg_5_6, var_5_0, true)
		end

		local var_5_3 = {
			partyMember = var_5_0
		}
		local var_5_4 = {
			errorString = native.Localise("ErrorConnectionLost"),
			returnFn = var_5_2
		}

		arg_5_1:changeState(online_error_state.OnlineErrorState(), arg_5_2, arg_5_3, arg_5_5, arg_5_6, var_5_3, var_5_4)

		return
	end

	if not arg_5_0.lockdownKicked then
		if var_5_1:areAllMachinesReady() then
			if arg_5_0.setupOnlineLoadingScreen then
				local var_5_5 = arg_5_9.matchSettingsSynchroniser
				local var_5_6 = var_5_5:getPartyMember(arg_5_8.partyMember)
				local var_5_7 = var_5_5:getSideInfo(var_5_6.localSide).matchClubSerialisable.matchClub.lineup.playerCount

				arg_5_0:setupLoadingScreenOnline(arg_5_2, var_5_5, arg_5_9.isDynasty and arg_5_9.gameMode ~= native.EGameMode.ProTeamSingleMatch)
			end

			if arg_5_0.wantOnlineMatchReporting then
				print("all machines ready, starting online match reporting state")

				local var_5_8 = statemachine.StateMachine(type(arg_5_0))

				arg_5_0.stateMachine = var_5_8

				var_5_8:changeState(online_matchreporting_state.OnlineMatchReportingState(), arg_5_2, arg_5_3, arg_5_5, arg_5_6, var_5_0, arg_5_9)
			else
				print("all machines ready, starting lockdown")
				var_5_1:lockdownBegin(arg_5_2, var_0_0, var_0_1)
			end

			native.showLoadingScreen("TeamLoading")

			arg_5_0.lockdownKicked = true
		end

		return
	end

	if arg_5_0.wantOnlineMatchReporting and arg_5_0.stateMachine:update(arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7) then
		print("online match reporting state complete, starting lockdown")
		arg_5_0.stateMachine:changeState(nil, arg_5_2, arg_5_3, arg_5_5, arg_5_6)
		var_5_1:lockdownBegin(arg_5_2, var_0_0, var_0_1)
	end

	if arg_5_6:hasActiveCommsTask() then
		return
	end

	if var_5_1:lockdownIsActive() then
		return
	end

	if var_5_1:lockdownComplete() then
		if not arg_5_6:getTransitionCanBegin(arg_5_2, arg_5_3, arg_5_4) then
			return
		end

		native.showLoadingScreen("Default")
		native.showLoadingScreen("TeamLoading")
		print("beginning match")

		if arg_5_10 then
			arg_5_10.enteringGame = true
		end

		if arg_5_9.saveMatchSettingsToPartyMember then
			arg_5_9.saveMatchSettingsToPartyMember()
		end

		arg_5_9.beginMatch(arg_5_2, arg_5_3, arg_5_5, arg_5_6, arg_5_8, var_5_1, arg_5_9)
	end
end

function MatchSetupLockdown.render(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4)
	return
end
