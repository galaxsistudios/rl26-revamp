local function ArrowKeyColour(arg_0_0, arg_0_1)
	local var_0_0 = math.floor(arg_0_0.r)
	local var_0_1 = math.floor(arg_0_0.g)
	local var_0_2 = math.floor(arg_0_0.b)
	local var_0_3 = (math.floor(arg_0_1.r) * 1 + math.floor(arg_0_1.g) * 3 + math.floor(arg_0_1.b) * 5) % 64

	return native.NsColor(var_0_0 - var_0_0 % 4 + var_0_3 % 4, var_0_1 - var_0_1 % 4 + math.floor(var_0_3 / 4) % 4, var_0_2 - var_0_2 % 4 + math.floor(var_0_3 / 16), 255)
end

function SetupLoadingScreen(arg_1_0, arg_1_1, arg_1_2, arg_1_3)
	if arg_1_2 and arg_1_3 then
		local var_1_0 = arg_1_1:getDecalManager()
		local var_1_1 = arg_1_0:getDecalRender()
		local var_1_2 = arg_1_0:getTextureManager()
		local var_1_3 = arg_1_2.decalIdOrIcon:createTexture(var_1_0, var_1_1, var_1_2, "large_mirrored")
		local var_1_4 = arg_1_3.decalIdOrIcon:createTexture(var_1_0, var_1_1, var_1_2, "large_mirrored")
		local var_1_5 = native.CTeamLoadingScreenData()

		var_1_5.homeTeamImage = var_1_3
		var_1_5.awayTeamImage = var_1_4

		local var_1_6 = arg_1_2.identity.primaryRGBColour
		local var_1_7 = arg_1_3.identity.primaryRGBColour

		var_1_5.homeTeamColour = ArrowKeyColour(var_1_6, arg_1_2.identity.secondaryRGBColour)
		var_1_5.awayTeamColour = ArrowKeyColour(var_1_7, arg_1_3.identity.secondaryRGBColour)

		var_1_1:render(arg_1_0:getRenderInterface())

		return var_1_5
	end

	ASSERT(false)
end

function SetupLoadingScreenFromSideInfo(arg_2_0, arg_2_1, arg_2_2, arg_2_3)
	local var_2_0 = arg_2_0:getDecalRender()
	local var_2_1 = arg_2_0:getTextureManager()
	local var_2_2
	local var_2_3

	if arg_2_2.clubId < 1000 then
		local var_2_4 = arg_2_1:getSideInfo("home"):getClubIcon()

		var_2_2 = var_2_1:load("ui/club_logos/large_mirrored/" .. var_2_4 .. ".texture")
	elseif not arg_2_2.clubLogo:getData() then
		var_2_2 = var_2_1:load("ui/club_logos/large_mirrored/custom.texture")
	else
		var_2_2 = var_2_0:addForLoadingScreen(arg_2_2.clubLogo)
	end

	if arg_2_3.clubId < 1000 then
		local var_2_5 = arg_2_1:getSideInfo("away"):getClubIcon()

		var_2_3 = var_2_1:load("ui/club_logos/large_mirrored/" .. var_2_5 .. ".texture")
	elseif not arg_2_3.clubLogo:getData() then
		var_2_3 = var_2_1:load("ui/club_logos/large_mirrored/custom.texture")
	else
		var_2_3 = var_2_0:addForLoadingScreen(arg_2_3.clubLogo)
	end

	local var_2_6 = native.CTeamLoadingScreenData()

	var_2_6.homeTeamImage = var_2_2
	var_2_6.awayTeamImage = var_2_3

	local var_2_7 = arg_2_2.primaryColour
	local var_2_8 = arg_2_3.primaryColour

	var_2_6.homeTeamColour = native.NsColor(var_2_7.r, var_2_7.g, var_2_7.b, 255)
	var_2_6.awayTeamColour = native.NsColor(var_2_8.r, var_2_8.g, var_2_8.b, 255)

	return var_2_6
end

function SetupLoadingScreenOnline(arg_3_0, arg_3_1)
	ASSERT(arg_3_1.getLobbyService)

	local var_3_0
	local var_3_1

	for iter_3_0 in arg_3_1:getLobbyService():allRemoteObjectsOfType("LobbySideInfo") do
		if iter_3_0.localSide == "home" then
			var_3_0 = iter_3_0
		elseif iter_3_0.localSide == "away" then
			var_3_1 = iter_3_0
		end
	end

	local var_3_2 = arg_3_1:getLocalSide()

	for iter_3_1 in arg_3_1:getLobbyService():allLocalObjectsOfType("LobbySideInfo") do
		if iter_3_1.localSide == "home" and var_3_2 == "home" then
			var_3_0 = iter_3_1
		elseif iter_3_1.localSide == "away" and var_3_2 == "away" then
			var_3_1 = iter_3_1
		end
	end

	ASSERT(var_3_0 and var_3_1)

	if not var_3_0 or not var_3_1 then
		return nil
	end

	return (SetupLoadingScreenFromSideInfo(arg_3_0, arg_3_1, var_3_0, var_3_1))
end

function SetupLoadingScreenProTeam(arg_4_0, arg_4_1)
	ASSERT(arg_4_1.getLobbyService)

	local var_4_0
	local var_4_1

	for iter_4_0 in arg_4_1:getLobbyService():allLocalObjectsOfType("LobbySideInfo") do
		if iter_4_0.localSide == "home" then
			var_4_0 = iter_4_0
		elseif iter_4_0.localSide == "away" then
			var_4_1 = iter_4_0
		end
	end

	ASSERT(var_4_0 and var_4_1)

	if not var_4_0 or not var_4_1 then
		return nil
	end

	return (SetupLoadingScreenFromSideInfo(arg_4_0, arg_4_1, var_4_0, var_4_1))
end
