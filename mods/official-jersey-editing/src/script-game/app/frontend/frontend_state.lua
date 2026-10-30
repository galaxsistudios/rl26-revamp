ASSERT(hasTempLoadedTable())
import("core.statemachine.statemachine")
import("app.frontend.partymember_aide")
import("app.signin.waitforsignin_state")
import("core.profile.profile")

local var_0_0 = native.standalone
local var_0_1 = {}

setmetatable(var_0_1, {
	__mode = "v",
	__index = _G
})

local function var_0_2(arg_1_0)
	local var_1_0, var_1_1 = loadstring(arg_1_0)
	local var_1_2 = false
	local var_1_3 = false

	if var_1_0 then
		setfenv(var_1_0, var_0_1)

		var_1_3, var_1_1 = pcall(var_1_0)
		var_1_2 = true
	end

	return var_1_3, var_1_1, var_1_2
end

local function var_0_3(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4)
	local var_2_0 = arg_2_1:getInvitationManager()
	local var_2_1 = arg_2_1:getParty()
	local var_2_2 = var_2_0:getPendingInviteControllerInfo()
	local var_2_3 = var_2_1:getPartyMemberForDevice(var_2_2)

	if var_2_3 then
		arg_2_0:changeState(arg_2_4.HomeScreenFactory(), arg_2_1, arg_2_2, arg_2_3, arg_2_4, var_2_3)
	else
		arg_2_0:changeState(waitforsignin_state.WaitForSignInState(), arg_2_1, arg_2_2, arg_2_3, arg_2_4, {
			reasonForBeingHere = native.Localise("AcceptedInviteBeforeBeingSignedIn")
		})
	end
end

Class("ReLoadFrontendDataState")

ReLoadFrontendDataState.canHandleInvitations = true

function ReLoadFrontendDataState.enter(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6)
	arg_3_0.createParams = arg_3_6

	arg_3_5:startMusic()
	arg_3_2:getDynastyDatabase():reload()
	arg_3_2:getPlayerDatabaseOnDisc():reload()
	arg_3_2:getClubDatabaseOnDisc():reload()

	local var_3_0 = VERIFY(arg_3_6.frontendReturnParams).partyMember

	if not var_3_0 or arg_3_4.nosave then
		if var_3_0 then
			partymember_aide.setupAcademyData(arg_3_5, arg_3_2, var_3_0)
		end

		local var_3_1, var_3_2, var_3_3 = var_0_2(arg_3_6.frontEndSubStateFactory)

		arg_3_1:changeState(var_3_2, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6)
	else
		arg_3_5.mixins.signin:reloadPartyMember(arg_3_2, arg_3_3, arg_3_4, arg_3_5, var_3_0, true, true)
	end
end

function ReLoadFrontendDataState.update(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7)
	if arg_4_2:getParty():hasOfflineJobInProgress() then
		return
	end

	local var_4_0 = arg_4_6.mixins.signin

	if var_4_0:updateBlocking(arg_4_6.frontEndStateMachine, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7) then
		return
	end

	local var_4_1 = var_4_0:getLastSignIn(arg_4_2)

	if var_4_1 then
		local var_4_2 = arg_4_0.createParams
		local var_4_3 = assert(var_4_2.frontendReturnParams)

		ASSERT(var_4_3.partyMember == var_4_1)

		if arg_4_2:getInvitationManager():hasAcceptedInvitePending() then
			var_0_3(arg_4_1, arg_4_2, arg_4_3, arg_4_5, arg_4_6)
		else
			local var_4_4, var_4_5, var_4_6 = var_0_2(var_4_2.frontEndSubStateFactory)

			arg_4_1:changeState(var_4_5, arg_4_2, arg_4_3, arg_4_5, arg_4_6, var_4_2)
		end
	else
		arg_4_1:changeState(waitforsignin_state.WaitForSignInState(), arg_4_2, arg_4_3, arg_4_5, arg_4_6, {
			reasonForBeingHere = native.Localise("SaveDataAcademyFailedToLoad")
		})
	end
end

function ReLoadFrontendDataState.render(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4)
	return
end

function ReLoadFrontendDataState.exit(arg_6_0, arg_6_1, arg_6_2)
	if arg_6_0.loadTask then
		arg_6_0.loadTask:dispose()
	end

	if arg_6_0.loadDataBuffer then
		arg_6_0.loadDataBuffer:dispose()
	end

	native.hideLoadingScreen("Default")
end

local var_0_4 = native.CLuaState

Class("FrontEndState", var_0_4)

function FrontEndState.enter(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5)
	_G.leakDetect(arg_7_0)

	-- official-jersey-editing: a match's chest text ends with the match
	rawset(_G, "MOD_OCCASION_TEXT", nil)

	arg_7_0.onReload = _G.registerOnReload(function()
		local var_8_0 = {
			"app.frontend.frontendsetup_state",
			"app.frontend.frontend_state",
			"app.frontend.frontend_scene",
			"app.frontend.frontend_uiservices",
			"app.frontend.frontend_layout"
		}

		for iter_8_0, iter_8_1 in ipairs(var_8_0) do
			import(iter_8_1)
		end
	end)
	arg_7_0.stateMachine = statemachine.StateMachine(arg_7_0.__type)
	arg_7_0.config = arg_7_4
	arg_7_0.hooks = arg_7_5.hooks
	arg_7_0.uiServices = assert(arg_7_5.uiServices)

	arg_7_0.uiServices:setFrontEndStateMachine(arg_7_0.stateMachine)

	local var_7_0 = arg_7_0.uiServices
	local var_7_1 = unpack(assert(arg_7_5.frontendAreas))

	arg_7_0.frontendAreas = {
		var_7_1
	}
	arg_7_0.reportBugTexture = var_7_1:find("reportBugTexture")
	arg_7_0.reportBugText = var_7_1:find("reportBugText")

	arg_7_0:addConvienienceFunctions(arg_7_2, arg_7_4, arg_7_0.uiServices, unpack(arg_7_0.frontendAreas))
	arg_7_2:getNetworkService():unpauseFrontEndJobs()
	arg_7_2:getParty():unpauseFrontEndJobs()
	arg_7_2:getCloudStorageService():unpause()

	local var_7_2 = arg_7_0.uiServices

	var_7_2:setStateUpdateEnabled(true)

	local var_7_3 = arg_7_2:getParty()
	local var_7_4 = arg_7_2:getInvitationManager():hasAcceptedInvitePending()
	local var_7_5 = true

	if var_7_5 then
		var_7_2:setNavBarEnabled(true)

		local var_7_6 = var_7_3:getPrimaryPartyMember()

		var_7_2:titleSetEnabled(var_7_6 ~= nil)
	end

	if var_7_4 and not arg_7_5.frontEndSubStateFactory then
		var_0_3(arg_7_0.stateMachine, arg_7_2, arg_7_3, arg_7_4, var_7_2)
	elseif arg_7_5.frontendReturnParams and arg_7_5.frontendReturnParams.signOutOccurred then
		arg_7_0.stateMachine:changeState(waitforsignin_state.WaitForSignInState(), arg_7_2, arg_7_3, arg_7_4, var_7_2, {
			reasonForBeingHere = native.Localise(arg_7_5.frontendReturnParams.removedStorageDevice and "SignedOut_RemovedStorageDevice" or "SignedOut")
		})
	elseif arg_7_5.frontEndSubStateFactory then
		arg_7_0.stateMachine:changeState(ReLoadFrontendDataState(), arg_7_2, arg_7_3, arg_7_4, var_7_2, arg_7_5)
	else
		arg_7_0.stateMachine:changeState(waitforsignin_state.WaitForSignInState(), arg_7_2, arg_7_3, arg_7_4, var_7_2, {
			attractModeEnabled = true
		})
	end

	if var_0_0 then
		local var_7_7 = "https://forum.bigant.com/"

		if GAME_CRICKET then
			var_7_7 = string.format("%s%s", var_7_7, "forum-17.html")
		elseif GAME_RUGBY then
			var_7_7 = string.format("%s%s", var_7_7, "forum-25.html")
		elseif GAME_LACROSSE then
			var_7_7 = string.format("%s%s", var_7_7, "forum-21.html")
		end

		ASSERT(var_7_7)

		arg_7_0.reportBugWebAddress = var_7_7
	end

	if arg_7_0.hooks then
		for iter_7_0, iter_7_1 in ipairs(arg_7_0.hooks.baseHooks) do
			if type(iter_7_1) == "HookInputDebugHook" then
				arg_7_0.hookInputDebugHook = iter_7_1

				break
			end
		end
	end
end

function FrontEndState.addConvienienceFunctions(arg_9_0, arg_9_1, arg_9_2, arg_9_3, arg_9_4)
	local var_9_0 = arg_9_4:find("titleBar")
	local var_9_1 = arg_9_4:find("tooltipsGradient")
	local var_9_2 = arg_9_4:find("staticTooltips")
	local var_9_3 = arg_9_4:find("partyMemberNotification")

	arg_9_3:addConvenienceFunction("titleSetEnabled", function(arg_10_0, arg_10_1)
		if arg_10_1 ~= var_9_0.visible then
			if arg_10_1 then
				var_9_0:show()
				var_9_0:kickShowAnim(1.2, 0.2, native.EaseType.QuadraticOut, 0.1, native.EaseType.QuadraticInOut, 0.4, 0.2, native.EaseType.QuadraticOut, 0.2, 0.6, native.EaseType.Linear)
			else
				var_9_0:hide()
			end
		end

		if arg_10_1 and var_9_3 then
			local var_10_0 = arg_9_1:getParty():getPrimaryPartyMember()

			assert(var_10_0, "why is the party member widget enabled with no party member!?")
			var_9_3:setPartyMember(var_10_0)
		end
	end)
	arg_9_3:addConvenienceFunction("partyMemberShowInformation", function(arg_11_0, arg_11_1)
		if var_9_3 and arg_11_1:getIsPrimaryUser() then
			var_9_3:setPartyMember(arg_11_1)
			var_9_3:invalidateRenderBuffers()
		end
	end)
	arg_9_3:addConvenienceFunction("partyMemberHideInformation", function(arg_12_0)
		if var_9_3 then
			var_9_3:clearAll()
			var_9_3:clearPartyMemberInfo()
			var_9_3:invalidateRenderBuffers()
		end
	end)
	arg_9_3:addConvenienceFunction("showBigNotification", function(arg_13_0, arg_13_1, arg_13_2, arg_13_3, arg_13_4)
		if var_9_3 then
			if var_9_3.haveValidPartyMemberInformation then
				var_9_3:addNotification(native.SkinUVs.NotificationIconMusic, arg_13_2, arg_13_3, arg_13_4 or 2)
			else
				arg_9_3:showNotification("music", arg_13_2, nil, nil, arg_13_4 or 2)
			end
		else
			arg_9_3:showNotification("music", arg_13_2, nil, nil, arg_13_4 or 2)
		end
	end)
	arg_9_3:addConvenienceFunction("updateBigNotification", function(arg_14_0, arg_14_1, arg_14_2, arg_14_3, arg_14_4)
		var_9_3:updateNotification(native.SkinUVs.NotificationIconMusic, arg_14_2, arg_14_3, arg_14_4 or 2)
	end)
	arg_9_3:addConvenienceFunction("clearBigNotification", function(arg_15_0)
		var_9_3:clearAll()
	end)
	arg_9_3:addConvenienceFunction("titleSetTitleOnlyMode", function(arg_16_0, arg_16_1)
		var_9_0:setTitleOnlyMode(arg_16_1)
	end)
	arg_9_3:addConvenienceFunction("titleGetCurrent", function(arg_17_0)
		return var_9_0.iconKey, var_9_0.title, var_9_0.subTitle
	end)
	arg_9_3:addConvenienceFunction("titleSetAreaOfGame", function(arg_18_0, arg_18_1, arg_18_2, arg_18_3)
		return
	end)
	arg_9_3:addConvenienceFunction("titleSetSubAreaOfGame", function(arg_19_0, arg_19_1, arg_19_2)
		return
	end)
	arg_9_3:addConvenienceFunction("setNavBarEnabled", function(arg_20_0, arg_20_1)
		if arg_20_1 then
			var_9_2:show()
		else
			var_9_2:hide()
		end
	end)
	arg_9_3:addConvenienceFunction("setStateUpdateEnabled", function(arg_21_0, arg_21_1)
		arg_9_0.stateUpdateAllowed = arg_21_1
	end)
	arg_9_3:addConvenienceFunction("getStateUpdateEnabled", function(arg_22_0)
		return arg_9_0.stateUpdateAllowed
	end)
end

function setYARRR(arg_23_0)
	_G.YARRR = arg_23_0

	native.setYARRR(arg_23_0)
end

function FrontEndState.update(arg_24_0, arg_24_1, arg_24_2, arg_24_3, arg_24_4, arg_24_5)
	profile.push("FrontEndState:update")

	arg_24_4 = arg_24_4 > 0.1 and 0.1 or arg_24_4

	local var_24_0 = arg_24_0.config
	local var_24_1 = arg_24_0.uiServices

	var_24_1.systemTime = arg_24_3
	var_24_1.realDt = arg_24_4

	native.setShaderGlobalFloat("PAGameTime", arg_24_3:ToSeconds())
	var_24_1:updateScene(arg_24_2, arg_24_3, arg_24_4, var_24_0, arg_24_5)

	local var_24_2 = arg_24_2:getParty():getPrimaryPartyMember()

	VERIFY(arg_24_2:getParticleController()):update(arg_24_4)
	native.Metrics.update(arg_24_4, false)

	if arg_24_0.needCheck and var_24_2 and var_24_2.user:hasJobInProgress() then
		profile.pop("FrontEndState:update")

		return
	end

	if var_24_1:updateDestructiveAction(arg_24_2, arg_24_3, arg_24_4, var_24_0) then
		return
	end

	if arg_24_0.stateUpdateAllowed then
		for iter_24_0, iter_24_1 in ipairs(arg_24_0.frontendAreas) do
			iter_24_1:update(arg_24_4)
		end

		arg_24_0.stateMachine:update(arg_24_2, arg_24_3, arg_24_4, var_24_0, var_24_1, arg_24_5)
	end

	if arg_24_0.stateMachine:getCurrentState() then
		var_24_1:updateAfterState(arg_24_2, arg_24_3, arg_24_4, arg_24_5)

		if var_0_0 then
			local var_24_3 = native.InputTypes
			local var_24_4 = arg_24_2:getGameControlManager():getDefaultController(native.EDeviceType.Keyboard)
			local var_24_5 = var_24_4 and var_24_4:wasReleased("F1")
			local var_24_6 = var_24_1:mouseProcessWidget(arg_24_0.reportBugTexture) or var_24_1:mouseProcessWidget(arg_24_0.reportBugText)

			if var_24_5 or var_24_6 then
				local var_24_7 = arg_24_0.reportBugWebAddress

				ASSERT(var_24_7)
				native.steamActivateGameOverlayToWebPage(var_24_7)
			end
		end

		var_24_1:toolTipsPreRender(arg_24_4)

		if arg_24_0.hooks then
			arg_24_0.hooks:update(arg_24_2, arg_24_3, arg_24_4, var_24_0, var_24_1, arg_24_5)
		end
	end

	if var_24_1:getWantExitGame() then
		arg_24_1:clearState(arg_24_2)
	end

	profile.pop("FrontEndState:update")
end

function FrontEndState.render(arg_25_0, arg_25_1, arg_25_2, arg_25_3)
	local var_25_0 = arg_25_0.config
	local var_25_1 = arg_25_0.uiServices

	if arg_25_0.stateUpdateAllowed then
		for iter_25_0, iter_25_1 in ipairs(arg_25_0.frontendAreas) do
			iter_25_1:doRender(arg_25_1, arg_25_3)
		end

		arg_25_0.stateMachine:render(arg_25_1, arg_25_2, var_25_1, arg_25_3)
	end

	if arg_25_0.stateMachine:getCurrentState() then
		var_25_1:renderAfterState(arg_25_1, arg_25_2, arg_25_3)
	end

	if arg_25_0.hooks then
		arg_25_0.hooks:render(arg_25_1, arg_25_2, var_25_1, arg_25_3)
	end
end

function FrontEndState.exit(arg_26_0, arg_26_1, arg_26_2)
	if arg_26_0.contentCheck then
		arg_26_0.contentCheck:dispose()

		arg_26_0.contentCheck = nil
	end

	if arg_26_0.hooks then
		arg_26_0.hooks:exit(arg_26_1)
	end

	if not arg_26_2 then
		local var_26_0 = arg_26_1:getParty():getPrimaryPartyMember()

		if var_26_0 and var_26_0:hasProfileSaveInProgress() then
			print("a save is in progress, block until it has began correctly")
			var_26_0:blockUntilProfileSaveBegan(arg_26_1)
		end
	end

	arg_26_1:getDynastyDatabase():unload()
	arg_26_1:getPlayerDatabaseOnDisc():unload()
	arg_26_1:getClubDatabaseOnDisc():unload()
	arg_26_0.stateMachine:changeState(nil, arg_26_1, native.Time.CurrentTime(), arg_26_0.config, arg_26_0.uiServices)
	arg_26_0.uiServices:dispose(arg_26_1)

	if arg_26_2 then
		arg_26_1:getParty():releaseAcademyData()
	end

	for iter_26_0, iter_26_1 in ipairs(arg_26_0.frontendAreas) do
		iter_26_1:dispose()
	end
end
