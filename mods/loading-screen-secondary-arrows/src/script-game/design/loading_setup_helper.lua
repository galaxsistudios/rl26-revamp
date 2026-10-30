local function ArrowKeyColour(arg_0_0, arg_0_1)
	local var_0_0 = math.floor(arg_0_0.r)
	local var_0_1 = math.floor(arg_0_0.g)
	local var_0_2 = math.floor(arg_0_0.b)
	local var_0_3 = (math.floor(arg_0_1.r) * 1 + math.floor(arg_0_1.g) * 3 + math.floor(arg_0_1.b) * 5) % 64

	return native.NsColor(var_0_0 - var_0_0 % 4 + var_0_3 % 4, var_0_1 - var_0_1 % 4 + math.floor(var_0_3 / 4) % 4, var_0_2 - var_0_2 % 4 + math.floor(var_0_3 / 16), 255)
end

local function LogoTexture(arg_0_0, arg_0_1, arg_0_2, arg_0_3)
	local var_0_0, var_0_1 = pcall(function()
		return arg_0_0.decalIdOrIcon.icon
	end)

	if var_0_0 and var_0_1 ~= nil and tostring(var_0_1) ~= "" then
		local var_0_2, var_0_3 = pcall(function()
			return arg_0_3:load("ui/club_logos/large_mirrored/" .. tostring(var_0_1) .. ".texture")
		end)

		if var_0_2 and var_0_3 ~= nil then
			return var_0_3
		end
	end

	return arg_0_0.decalIdOrIcon:createTexture(arg_0_1, arg_0_2, arg_0_3, "large_mirrored")
end

-- Competition background logo: the competition's enum name goes to the
-- loading screen's m_loadingText, which the XAML maps to a logo.
local LOADING_DEBUG = false

local function LoadingDebugLog(arg_0_0)
	if not LOADING_DEBUG then
		return
	end

	pcall(function()
		local var_0_0 = io.open("loadingscreen_debug.txt", "a")

		if var_0_0 then
			var_0_0:write(os.date("%H:%M:%S ") .. arg_0_0 .. "\n")
			var_0_0:close()
		end
	end)
end

-- every key the XAML has a logo for; any other value falls through
local LoadingLogoKeys = {
	AnzacTest = true,
	KingstoneChampionship = true,
	KingstoneLeague1 = true,
	League_BetfredChampionship = true,
	League_BetfredLeague1 = true,
	League_Championship2026 = true,
	League_Championship2026WithFax = true,
	League_NRL = true,
	League_NRLW = true,
	League_NSWCup = true,
	League_QLDCup = true,
	League_QLDCup2026 = true,
	League_SuperLeague = true,
	League_SuperLeague2026 = true,
	League_WSL = true,
	Markings_NRL_Rep_AllStarsMatch = true,
	Markings_NRL_Rep_AnzacTest = true,
	Markings_NRL_Rep_CityVsCountry = true,
	Markings_NRL_Rep_StateOfOrigin = true,
	Markings_WorldCup = true,
	Markings_WorldCupWomens = true,
	Round_allstars = true,
	Round_country = true,
	Round_nswcup = true,
	Round_pacific = true,
	Round_qldcup = true,
	Round_stateoforigin = true,
	Round_worldcup = true,
	Round_worldcupwomens = true,
	StateOfOrigin = true,
	SuperLeague = true,
	Tournament_ChallengeCup = true,
	Tournament_ChallengeCup2026 = true,
	Tournament_ChallengeCup2026WithFax = true,
	Tournament_EighteenNinetyFiveCup2026 = true,
	Tournament_EighteenNinetyFiveCup2026WithFax = true,
	Tournament_EighteenNinteyFiveCup = true,
	Tournament_IndigenousVsMaori = true,
	Tournament_RLWC2026Men = true,
	Tournament_RLWC2026Women = true,
	Tournament_StateOfOrigin = true,
	Tournament_StateOfOriginWomens = true,
	Tournament_WomensChallengeCup = true,
	Tournament_WorldCupMens = true,
	Tournament_WorldCupWomens = true,
	WorldCupMens = true,
	WorldCupWomens = true,
}

-- an enum value's name (the enum tables map both ways: name -> id, id -> name)
local function LoadingEnumName(arg_0_0, arg_0_1)
	if arg_0_1 == nil then
		return nil
	end

	if type(arg_0_1) == "string" then
		return arg_0_1
	end

	for iter_0_0, iter_0_1 in pairs(arg_0_0) do
		if type(iter_0_0) == "string" and iter_0_1 == arg_0_1 then
			return iter_0_0
		end
	end

	local var_0_0 = arg_0_0[arg_0_1]

	return type(var_0_0) == "string" and var_0_0 or nil
end

-- Play Now's round pick, then the competition (career, competition mode or a
-- Play Now casualMimicSeason), then the field markings setting.
local function LoadingCompetitionKey(arg_0_0)
	local var_0_0 = {}

	pcall(function()
		local var_0_1 = rawget(_G, "MOD_FIELD_ROUND_ACTIVE")

		if var_0_1 ~= nil then
			table.insert(var_0_0, "Round_" .. tostring(var_0_1))
		end
	end)
	pcall(function()
		local var_0_2 = LoadingEnumName(native.CareerCompetitionIdEnum, arg_0_0.stateOfTheSeason.competitionId)

		if var_0_2 then
			table.insert(var_0_0, var_0_2)
		end
	end)
	pcall(function()
		local var_0_3 = LoadingEnumName(native.MatchSettingsFieldMarkings, arg_0_0.matchType.fieldMarkings)

		if var_0_3 then
			table.insert(var_0_0, "Markings_" .. var_0_3)
		end
	end)

	LoadingDebugLog("candidates: " .. table.concat(var_0_0, ", "))

	for iter_0_0, iter_0_1 in ipairs(var_0_0) do
		if LoadingLogoKeys[iter_0_1] then
			return iter_0_1
		end
	end

	return ""
end

-- Play Now (no competition): NSW v QLD is Origin (women's sides use soow_
-- icons); otherwise the first league, in this order, that holds both clubs
-- picks the logo (as the competition key it would have).
local LoadingOriginIcons = {
	rep_nsw = true,
	rep_qld = true,
}

local LoadingAllStarsIcons = {
	maori = true,
	rep_allstars = true,
	rep_indigenous = true,
}

local LoadingClubLeagues = {
	{
		"League_NRL2026",
		"League_NRL"
	},
	{
		"League_NRL",
		"League_NRL"
	},
	{
		"League_NRLW2026",
		"League_NRLW"
	},
	{
		"League_NRLW",
		"League_NRLW"
	},
	{
		"League_NSWCup",
		"League_NSWCup"
	},
	{
		"League_QLDCup2026",
		"League_QLDCup"
	},
	{
		"League_QLDCup",
		"League_QLDCup"
	},
	{
		"League_SuperLeague2026",
		"League_SuperLeague"
	},
	{
		"League_SuperLeague",
		"League_SuperLeague"
	},
	{
		"League_WSL2026",
		"League_WSL"
	},
	{
		"League_WSL",
		"League_WSL"
	},
	{
		"League_Championship2026",
		"League_BetfredChampionship"
	},
	{
		"League_BetfredChampionship",
		"League_BetfredChampionship"
	},
	{
		"League_BetfredLeague1",
		"League_BetfredLeague1"
	},
	{
		"League_WorldCupMen",
		"Tournament_RLWC2026Men"
	},
	{
		"League_WorldCupWomen",
		"Tournament_RLWC2026Women"
	},
}

local function LoadingClubIcon(arg_0_0)
	local var_0_0, var_0_1 = pcall(function()
		return tostring(arg_0_0.decalIdOrIcon.icon)
	end)

	return var_0_0 and var_0_1 or ""
end

local function LoadingClubLeagueKey(arg_0_0, arg_0_1, arg_0_2)
	local var_0_9 = LoadingClubIcon(arg_0_1)
	local var_0_10 = LoadingClubIcon(arg_0_2)

	if LoadingOriginIcons[var_0_9] and LoadingOriginIcons[var_0_10] then
		return "Tournament_StateOfOrigin"
	end

	if var_0_9:sub(1, 5) == "soow_" and var_0_10:sub(1, 5) == "soow_" then
		return "Tournament_StateOfOriginWomens"
	end

	if LoadingAllStarsIcons[var_0_9] and LoadingAllStarsIcons[var_0_10] then
		return "Tournament_IndigenousVsMaori"
	end

	local var_0_0, var_0_1 = pcall(function()
		local var_0_2 = arg_0_0:getLeagueManager()

		local function var_0_3(arg_1_0)
			local var_1_0 = {}

			for iter_1_0, iter_1_1 in ipairs({
				var_0_2,
				var_0_2.onDisc
			}) do
				pcall(function()
					local var_1_1 = iter_1_1:getLeagueIdsContainingClub(arg_1_0, false)

					for iter_1_2 = 1, #var_1_1 do
						table.insert(var_1_0, var_1_1[iter_1_2])
					end
				end)
			end

			return var_1_0
		end

		local function var_0_4(arg_2_0, arg_2_1)
			for iter_2_0, iter_2_1 in ipairs(arg_2_0) do
				if iter_2_1 == arg_2_1 then
					return true
				end
			end

			return false
		end

		local var_0_5 = var_0_3(arg_0_1)
		local var_0_6 = var_0_3(arg_0_2)

		if LOADING_DEBUG then
			-- every league each club is in: id and name (whatever the league object offers)
			local function var_0_11(arg_3_0)
				local var_3_0 = {}

				for iter_3_0, iter_3_1 in ipairs(arg_3_0) do
					local var_3_1, var_3_2 = pcall(function()
						local var_3_3 = var_0_2:getLeague(iter_3_1)

						return tostring(var_3_3 and (var_3_3.name or var_3_3.fullName or var_3_3.shortName))
					end)

					table.insert(var_3_0, tostring(iter_3_1) .. "=" .. tostring(var_3_2))
				end

				return table.concat(var_3_0, " | ")
			end

			LoadingDebugLog("club icons: " .. LoadingClubIcon(arg_0_1) .. " v " .. LoadingClubIcon(arg_0_2))
			LoadingDebugLog("home leagues: " .. var_0_11(var_0_5))
			LoadingDebugLog("away leagues: " .. var_0_11(var_0_6))
		end

		for iter_0_0, iter_0_1 in ipairs(LoadingClubLeagues) do
			local var_0_7, var_0_8 = pcall(function()
				return var_0_2.onDisc:getLeagueIdBasedOff(native.AcademyLeagues[iter_0_1[1]])
			end)

			LoadingDebugLog("  " .. iter_0_1[1] .. ": ok=" .. tostring(var_0_7) .. " id=" .. tostring(var_0_8) .. " home=" .. tostring(var_0_7 and var_0_4(var_0_5, var_0_8)) .. " away=" .. tostring(var_0_7 and var_0_4(var_0_6, var_0_8)))

			if var_0_7 and var_0_8 ~= nil and var_0_4(var_0_5, var_0_8) and var_0_4(var_0_6, var_0_8) then
				return iter_0_1[2]
			end
		end

		return ""
	end)

	LoadingDebugLog("club guess: ok=" .. tostring(var_0_0) .. " " .. tostring(var_0_1))

	return var_0_0 and var_0_1 or ""
end

-- arg_0_0: true when the screen has just come up after Play - the key is
-- cleared first, so it always changes and the team logos' slide-in (which
-- starts on any competition key) plays every time.
local function SendLoadingCompetition(arg_0_0)
	local var_0_1, var_0_2 = pcall(function()
		local var_0_0 = rawget(_G, "MOD_LOADING_SCREEN")

		if var_0_0 then
			if arg_0_0 then
				var_0_0:setLoadingText("")
			end

			var_0_0:setLoadingText(rawget(_G, "MOD_LOADING_COMPETITION") or "")
		end

		return var_0_0 ~= nil
	end)

	LoadingDebugLog("send: key=" .. tostring(rawget(_G, "MOD_LOADING_COMPETITION")) .. " screen=" .. tostring(var_0_2) .. " ok=" .. tostring(var_0_1))
end

-- Stadium background: "<stadium>_<time of day>" names one of the shipped
-- ui/textures/stadium_images (morning/day/afternoon/dusk/night per ground).
-- arg_0_1: matchin's getTimeOfDayFromHour (matchInData.timeOfDay is the hour)
local function LoadingStadiumKey(arg_0_0, arg_0_1)
	local var_0_0, var_0_1 = pcall(function()
		local var_0_2 = arg_0_0.groundInfo.groundInfo.stadium
		local var_0_3 = LoadingEnumName(native.EStadiums, var_0_2) or tostring(var_0_2)
		local var_0_5 = arg_0_0.timeOfDay

		if type(var_0_5) == "number" and arg_0_1 then
			var_0_5 = arg_0_1(var_0_5)
		end

		local var_0_4 = string.lower(tostring(LoadingEnumName(native.MatchSettingsTimeOfDay, var_0_5) or var_0_5))

		LoadingDebugLog("stadium: " .. tostring(var_0_3) .. " time of day: " .. var_0_4)

		-- the preloaded set is day and night only: dusk kickoffs are under lights
		var_0_4 = (var_0_4 == "dusk" or var_0_4 == "night") and "night" or "day"

		return string.lower(var_0_3) .. "_" .. var_0_4
	end)

	return var_0_0 and var_0_1 or nil
end

-- The stadium background: m_tipsText (getLoadingScreen():setTipsText, unused
-- by this XAML) carries "<stadium>_<day|night>", which the XAML maps to one
-- of the images install.py preloads in the view's texpack.
local function SendLoadingStadium()
	local var_0_0, var_0_1 = pcall(function()
		rawget(_G, "MOD_LOADING_SCREEN"):setTipsText(rawget(_G, "MOD_LOADING_STADIUM") or "")
	end)

	LoadingDebugLog("send stadium: " .. tostring(rawget(_G, "MOD_LOADING_STADIUM")) .. " ok=" .. tostring(var_0_0) .. " " .. tostring(var_0_1))
end

-- called from matchin.finalise (nrl-special-balls' matchin.lua)
rawset(_G, "MOD_LOADING_COMPETITION_HOOK", function(arg_0_0, arg_0_1)
	local var_0_0 = LoadingCompetitionKey(arg_0_0)

	-- no competition (Play Now): keep SetupLoadingScreen's club guess
	if var_0_0 ~= "" or rawget(_G, "MOD_LOADING_COMPETITION") == nil then
		rawset(_G, "MOD_LOADING_COMPETITION", var_0_0)
	end
	LoadingDebugLog("finalise hook: key=" .. tostring(rawget(_G, "MOD_LOADING_COMPETITION")) .. " id=" .. tostring(arg_0_0.stateOfTheSeason and arg_0_0.stateOfTheSeason.competitionId) .. " (" .. type(arg_0_0.stateOfTheSeason and arg_0_0.stateOfTheSeason.competitionId) .. ")")
	SendLoadingCompetition()
	rawset(_G, "MOD_LOADING_STADIUM", LoadingStadiumKey(arg_0_0, arg_0_1))
	SendLoadingStadium()
end)

function SetupLoadingScreen(arg_1_0, arg_1_1, arg_1_2, arg_1_3)
	if arg_1_2 and arg_1_3 then
		local var_1_0 = arg_1_1:getDecalManager()
		local var_1_1 = arg_1_0:getDecalRender()
		local var_1_2 = arg_1_0:getTextureManager()
		local var_1_3 = LogoTexture(arg_1_2, var_1_0, var_1_1, var_1_2)
		local var_1_4 = LogoTexture(arg_1_3, var_1_0, var_1_1, var_1_2)
		local var_1_5 = native.CTeamLoadingScreenData()

		LoadingDebugLog("SetupLoadingScreen")
		pcall(function()
			rawset(_G, "MOD_LOADING_SCREEN", arg_1_0:getLoadingScreen())
		end)

		if rawget(_G, "MOD_LOADING_COMPETITION") == nil then
			rawset(_G, "MOD_LOADING_COMPETITION", LoadingClubLeagueKey(arg_1_1, arg_1_2, arg_1_3))
		end
		SendLoadingCompetition(true)
		SendLoadingStadium()

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
