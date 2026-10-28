import("uicore.uiinput")
import("app.attractmode.attractmode_aide")
import("app.firstboot.firstboot_state")
import("app.signin.waitforsignin_layout")
import("app.transition.transition_strings")
import("design.loading_setup_helper")

local var_0_0 = native.InputTypes
local var_0_1 = native:getEnvironment()
local var_0_2 = native.standalone
local var_0_3 = var_0_1:argExists("impersonateuser") and var_0_1:getArg("impersonateuser")

-- skip-intro-to-main-menu: rl26_revamp.ini in the game folder turns the skip on
-- (skip_intro = true). install.py / unlock-all-kits launch.py read the same file
-- for the splash exe patch. A missing file is written with the default (off).
SkipIntroConfigFile = "rl26_revamp.ini"
SkipIntroDefaultConfig = "; RL26 Revamp settings. Restart the game after changing them.\n" ..
	"\n" ..
	"; true = boot straight to the main menu (no splash logos, no start screen).\n" ..
	"; The splash logos are only skipped when the game is started through\n" ..
	"; unlock-all-kits launch.py, which applies the exe patch to match this.\n" ..
	"skip_intro = false\n"

function skipIntroEnabled()
	local ok, enabled = pcall(function()
		local file = io.open(SkipIntroConfigFile, "r")

		if not file then
			file = io.open(SkipIntroConfigFile, "w")

			if file then
				file:write(SkipIntroDefaultConfig)
				file:close()
			end

			return false
		end

		local value

		for line in file:lines() do
			local key, v = line:match("^%s*([%w_]+)%s*=%s*([%w_]+)")

			if key and key:lower() == "skip_intro" then
				value = v:lower()
			end
		end

		file:close()

		return value == "true" or value == "1" or value == "yes" or value == "on"
	end)

	return ok and enabled or false
end

-- Start screen intro problems go to rl26_revamp_debug.txt in the game folder.
function skipIntroLog(msg)
	pcall(function()
		local file = io.open("rl26_revamp_debug.txt", "a")

		if file then
			file:write(os.date("%H:%M:%S "), tostring(msg), "\n")
			file:close()
		end
	end)
end

-- rl26-revamp-branding's NVMBackground title art (nil without that mod).
function titleArtViewModel(uiServices)
	local background = uiServices.mixins.background
	local viewModel = background and background.viewModel

	return viewModel and viewModel.loadTitleArt and viewModel or nil
end

Class("ReturnFromMatchAttractModeState")

function ReturnFromMatchAttractModeState.enter(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6)
	arg_1_1:changeState(WaitForSignInState(), arg_1_2, arg_1_3, arg_1_4, arg_1_5, {})
end

Class("WaitForSignInState")

WaitForSignInState.canHandleInvitations = true

function WaitForSignInState.enter(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6)
	ASSERT(arg_2_6)
	arg_2_5:sharingKickNagVersion(arg_2_2, nil)

	arg_2_0.area = waitforsignin_layout.create(arg_2_2, arg_2_6.reasonForBeingHere)

	arg_2_5:setNavBarEnabled(true)
	arg_2_5:titleSetEnabled(false)
	arg_2_5:titleSetAreaOfGame("home", "GameTitle")
	arg_2_5:titleSetSubAreaOfGame()
	arg_2_5:titleSetTitleOnlyMode(false)
	arg_2_5:clearLastSignIn()
	arg_2_5:enableSignInActivations()
	arg_2_5:sharingResetSession()

	local var_2_0 = arg_2_2:getParty()
	local var_2_1 = arg_2_2:getGameControlManager()

	var_2_0:setRequireLeadPartyMember(false)

	for iter_2_0, iter_2_1 in var_2_0:iterMembers() do
		local var_2_2 = iter_2_1.controllerInfo

		if var_2_2.isValid then
			var_2_1:getController(var_2_2):resetControllerColour()
		end
	end

	var_2_0:removeAllMembers()
	arg_2_5:runOnAllMixins("clearAcademyData")
	arg_2_5:partyMemberHideInformation()
	arg_2_5:forcefullyDeactivate(arg_2_2, arg_2_3, arg_2_4)

	local var_2_3 = arg_2_2:getSignInService()

	arg_2_0.signInMonitor = native.CSignInMonitor.create(var_2_3)

	arg_2_0.signInMonitor:init(native.CInputControllerInfo.Create(), true)
	arg_2_0.signInMonitor:beginWatching()

	arg_2_0.pads = uiinput.getAllControllers(var_2_1)

	arg_2_5:playerModelCameraEnabled(true)

	-- skip-intro-to-main-menu: only the boot path passes attractModeEnabled; a sign-out
	-- or return-from-attract still waits for a button press.
	arg_2_0.autoSignInPending = arg_2_6.attractModeEnabled and skipIntroEnabled() or false

	-- skip-intro-to-main-menu: start loading the start screen art now, so it's
	-- usually bound by the time the splash screens are gone.
	local ok, err = pcall(function()
		local viewModel = titleArtViewModel(arg_2_5)

		if viewModel then
			viewModel:loadTitleArt(arg_2_2)
		end
	end)

	if not ok then
		skipIntroLog("loadTitleArt failed: " .. tostring(err))
	end
end

function WaitForSignInState.exit(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4)
	arg_3_4:playerModelCameraEnabled(false)
	VERIFY(arg_3_1:getDlcManager()):enumerateDlc()
	arg_3_0.signInMonitor:endWatching()
	arg_3_0.signInMonitor:deinit()
	native.CSignInMonitor.destroy(arg_3_0.signInMonitor)
	arg_3_4:disableSignInActivations()
	arg_3_0.area:dispose()
end

function WaitForSignInState.update(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7)
	if not arg_4_0.destroyedLegals then
		local var_4_0 = native.destroyLegalScreens()

		arg_4_0.destroyedLegals = var_4_0

		if not var_4_0 then
			return
		end

		arg_4_6:playSound("SplashIntro")

		-- skip-intro-to-main-menu: the start screen is showing now
		arg_4_0.titleIntroPending = true
		arg_4_0.titleIntroFrames = 0
	end

	-- skip-intro-to-main-menu: slide in the RL26 Revamp title art
	-- (rl26-revamp-branding title_screen.py) once its textures are bound, or
	-- after ~3 s regardless. "signon" first brings the logo back after a
	-- sign-out, "title" plays the intro.
	if arg_4_0.titleIntroPending then
		arg_4_0.titleIntroFrames = arg_4_0.titleIntroFrames + 1

		local ok, ready = pcall(function()
			local viewModel = titleArtViewModel(arg_4_6)

			return not viewModel or viewModel:updateTitleArt()
		end)

		if not ok then
			skipIntroLog("updateTitleArt failed: " .. tostring(ready))
		elseif not ready and arg_4_0.titleIntroFrames == 180 then
			skipIntroLog("title art still not loaded after 180 frames, playing the intro anyway")
		end

		if not ok or ready or arg_4_0.titleIntroFrames >= 180 then
			arg_4_0.titleIntroPending = false

			local ok2, err2 = pcall(function()
				arg_4_6:setBackgroundVisual("signon")
				arg_4_6:setBackgroundVisual("title")
			end)

			if not ok2 then
				skipIntroLog("setBackgroundVisual failed: " .. tostring(err2))
			else
				skipIntroLog("title intro played after " .. arg_4_0.titleIntroFrames .. " frames, art bound: " .. tostring(ok and ready))
			end
		end
	end

	local var_4_1 = arg_4_2:getInputControlDistributor():getControlManager(native.EInputControlFocusLevel.Game)

	arg_4_0.pads = uiinput.getAllControllers(var_4_1)

	arg_4_0.signInMonitor:update(arg_4_4)

	while arg_4_0.signInMonitor:getNextChange() do
		arg_4_0.pads = uiinput.getAllControllers(var_4_1)
	end

	local var_4_2 = arg_4_6.mixins.alert
	local var_4_3 = arg_4_6.mixins.signin
	local var_4_4 = arg_4_0.area

	if var_4_2:updateBlocking(arg_4_6.frontEndStateMachine, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7) then
		return
	end

	if arg_4_6:sharingUpdateNagVersion(arg_4_2, arg_4_3, arg_4_4) then
		arg_4_0.checkedNagVersion = true
	end

	if var_4_3:updateBlocking(arg_4_6.frontEndStateMachine, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7) then
		return
	end

	local var_4_5 = var_4_3:getLastSignIn(arg_4_2)

	if var_4_5 then
		var_4_5.checkedNagVersion = arg_4_0.checkedNagVersion or var_4_5.checkedNagVersion

		local var_4_6 = arg_4_2:getParty():getPrimaryPartyMember()

		ASSERT(var_4_6 == var_4_5)

		local var_4_7 = var_4_5.sharingInfo or {}

		if var_0_3 == tostring(var_4_7.userId) then
			arg_4_6:setPlayerNameText(var_4_7.userId, true)
		else
			arg_4_6:setPlayerNameText(var_4_5:getName(), false)
		end

		arg_4_6:titleSetEnabled(true)

		local var_4_8 = var_4_5.settings
		local var_4_9 = arg_4_6:getClubManager()
		local var_4_10 = var_4_8.favouriteClubSet

		if not arg_4_2:getStreamingInstallManager():isInstallationComplete() then
			local var_4_11 = arg_4_6:getTransitionCreateParams().matchStateData

			var_4_11:reset()

			local var_4_12 = var_4_11.matchInData
			local var_4_13 = var_4_11.matchOutData
			local var_4_14 = var_4_11.matchInProgressData

			attractmode_aide.setupMatchInData(arg_4_2, arg_4_5, arg_4_6, var_4_12, var_4_13, var_4_14)
			arg_4_6:transitionEngineState(arg_4_2, arg_4_3, arg_4_5, {
				nextStateFactory = transition_strings.AttractModeState,
				exitGameplayStateFactory = arg_4_6.exitGameplayStateFactory,
				frontEndSubStateFactory = transition_strings.ReturnFromAttractMode,
				onSignedInFactory = arg_4_0.onSignedInFactory,
				attractModeCounter = arg_4_0.attractModeCounter
			})

			local var_4_15 = loading_setup_helper.SetupLoadingScreen(arg_4_2, arg_4_6, var_4_12.home, var_4_12.away)

			native.setTeamsLoadingProps(var_4_15)
			native.showLoadingScreen("Default")
			native.showLoadingScreen("TeamLoading")

			return
		end

		local var_4_16 = arg_4_6.HomeScreenFactory

		if firstboot_state.getShouldEnterFirstBootFlow(var_4_5) then
			var_4_16 = firstboot_state.FirstBootState
		end

		arg_4_6:startMusic()
		arg_4_6:playSound("SigninCrowdStinger")

		if var_4_5.sharingInfo.impersonated then
			var_4_2:blockingAlert(arg_4_6, arg_4_2, arg_4_3, {
				text = "Changes will affect their account in the wild",
				options = "ok",
				canCancel = false,
				title = "WARNING: LOGGING IN WHILE IMPERSONATING USER",
				onSelected = function(arg_5_0, arg_5_1, arg_5_2)
					if arg_5_2 then
						arg_4_1:changeState(var_4_16(), arg_5_0, arg_5_1, arg_4_5, arg_4_6, var_4_5)
					end
				end
			})
		else
			arg_4_1:changeState(var_4_16(), arg_4_2, arg_4_3, arg_4_5, arg_4_6, var_4_5)
		end

		return
	end

	local var_4_17 = arg_4_2:getInvitationManager()

	if var_4_17:hasAcceptedInvitePending() then
		print("party member has accepted invite before pressing start, auto signing them in.")

		local var_4_18 = var_4_17:getPendingInviteControllerInfo()

		var_4_3:beginActivation(arg_4_2, arg_4_3, arg_4_5, arg_4_6, var_4_18, true, true)

		return
	else
		local var_4_19 = var_4_17:getLastError()

		if var_4_19.isError and var_4_19.errorString == "JOIN_REJECTED_NONEXISTENT_SESSION" then
			var_4_2:blockingAlert(arg_4_6, arg_4_2, arg_4_3, {
				options = "ok",
				canCancel = false,
				text = native.Localise("ErrorOnlineJoinFailedUnavailable")
			})
		end

		var_4_17:cancelPendingInvitation()
	end

	if var_4_4.isLoaded then
		var_4_4:update(arg_4_4)

		-- skip-intro-to-main-menu: sign in the default pad (what Enter on the keyboard
		-- does) instead of waiting on "press start". Retried until the mixin accepts it.
		if arg_4_0.autoSignInPending and arg_4_2:getParty().localMemberCount < 1 then
			local var_4_22 = var_4_1:getDefaultControllerInfo(native.EDeviceType.Pad)

			if var_4_22 and var_4_3:activateBlockingMixin(arg_4_2, arg_4_3, arg_4_5, arg_4_6, {
				var_4_22,
				false
			}) then
				arg_4_0.autoSignInPending = false

				return
			end
		end

		local var_4_20 = arg_4_6:checkForTooltipMouseInput(var_0_0.Accept)
		local var_4_21 = var_4_3:checkForActivation(arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, var_4_20)

		if var_4_21 then
			var_4_3:activateBlockingMixin(arg_4_2, arg_4_3, arg_4_5, arg_4_6, var_4_21)

			return
		end
	end
end

function WaitForSignInState.render(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4)
	local var_6_0 = arg_6_3.mixins.alert
	local var_6_1 = arg_6_3.mixins.signin

	if var_6_0:isActive() or var_6_1:activationInProgress() then
		return
	end

	if arg_6_1:getInvitationManager():hasAcceptedInvitePending() then
		return
	end

	arg_6_0.area:doRender(arg_6_1, arg_6_4)
end

local var_0_4 = {
	"r2",
	"l2",
	"rjoy-x",
	"rjoy-y"
}
local var_0_5 = {
	"lshift",
	"rshift"
}
