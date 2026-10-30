function hideLoadingScreen(arg_1_0)
	native.hideLoadingScreen("Default")
	native.hideLoadingScreen("TeamLoading")

	local var_1_0 = arg_1_0:getLoadingScreen()

	var_1_0:toggleContinueText(false)
	var_1_0:toggleWaitingForPlayersText(false)

	-- loading-screen-secondary-arrows: clear the competition and stadium keys once
	-- the screen is hidden, so the next load's keys are a change (the team logos'
	-- slide-in starts when a competition key arrives)
	pcall(function()
		var_1_0:setLoadingText("")
		var_1_0:setTipsText("")
	end)
end
