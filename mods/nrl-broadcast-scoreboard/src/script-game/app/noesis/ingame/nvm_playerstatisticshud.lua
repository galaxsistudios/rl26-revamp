import("app.noesis.ns")
import("app.noesis.ns_viewmodel")
import("app.noesis.ns_observablecollection")
import("app.noesis.util.nvm_team")
import("game.ui.noesis.viewmodels.nvm_notification")
import("sim.hud.hud_helper")

local var_0_0 = ns_viewmodel.ViewModel
local var_0_1 = ns_observablecollection.ObservableCollection
local var_0_2 = 4
-- nrl-broadcast-scoreboard: outro length; keep in step with PlayerStatisticsTemplate's HideKey storyboard
local var_0_outro_time = 0.3

ns.Class("NVMPlayerStatisticsHud", var_0_0, function(arg_1_0, arg_1_1)
	var_0_0.init(arg_1_0)

	arg_1_0.isPlayerStatisticVisible = false
	arg_1_0.PlayerStatsHud = var_0_1()
	arg_1_0.inCleanState = false
	arg_1_0.isReadyToDisplay = false
	arg_1_0.HomeTeam = hud_helper.getSideHudNVMTeam(arg_1_1, hud_helper.HOME_SIDE)
	arg_1_0.AwayTeam = hud_helper.getSideHudNVMTeam(arg_1_1, hud_helper.AWAY_SIDE)
	-- nrl-broadcast-scoreboard: what the card displays. Copied from the Player*/Team/stats
	-- properties in show(), and left alone by clean(), so the card keeps its data while it
	-- animates out even though the game's state logic has already cleared and may be rebuilding.
	arg_1_0.ShownName = ""
	arg_1_0.ShownNumber = ""
	arg_1_0.ShownPosition = ""
	arg_1_0.ShownTeam = arg_1_0.HomeTeam
	arg_1_0.ShownStats = var_0_1()
	arg_1_0.IsShown = false
	arg_1_0.RevealKey = 0
	arg_1_0.HideKey = 0
	arg_1_0.hideTimer = nil

	arg_1_0:clean()
end).Bindings = {
	Properties = {
		ShownName = ns.String,
		ShownNumber = ns.String,
		ShownPosition = ns.String,
		ShownTeam = ns.typeOf(nvm_team.NVMTeam),
		ShownStats = ns.typeOf(var_0_1),
		IsShown = ns.Bool,
		RevealKey = ns.Int32,
		HideKey = ns.Int32,
		isPlayerStatisticVisible = ns.Bool,
		PlayerName = ns.String,
		PlayerNumber = ns.String,
		PlayerPosition = ns.String,
		PlayerStatsHud = ns.typeOf(var_0_1),
		Team = ns.typeOf(nvm_team.NVMTeam),
		TeamColour = ns.Color,
		TeamLogo = ns.typeOf(native.CNoesisTextureSource),
		ThemeOptionInt = ns.Int8
	}
}

function NVMPlayerStatisticsHud.update(arg_2_0, arg_2_1)
	if arg_2_0.hideTimer then
		arg_2_0.hideTimer = arg_2_0.hideTimer - (arg_2_1 or 1 / 60)

		if arg_2_0.hideTimer <= 0 then
			arg_2_0.hideTimer = nil
			arg_2_0.IsShown = false
		end
	end

	if arg_2_0.teamTexture and arg_2_0.teamTexture:isLoaded() then
		arg_2_0.TeamLogo = native.CNoesisTextureSource(arg_2_0.teamTexture)

		arg_2_0.teamTexture:unload()

		arg_2_0.teamTexture = nil
	end

	if arg_2_0.secondaryTeamTexture and arg_2_0.secondaryTeamTexture:isLoaded() then
		arg_2_0.SecondaryTeamLogo = native.CNoesisTextureSource(arg_2_0.secondaryTeamTexture)

		arg_2_0.secondaryTeamTexture:unload()

		arg_2_0.secondaryTeamTexture = nil
	end

	if arg_2_0.playerPhotoTexture and arg_2_0.playerPhotoTexture:isLoaded() then
		arg_2_0.PlayerPhoto = native.CNoesisTextureSource(arg_2_0.playerPhotoTexture)

		arg_2_0.playerPhotoTexture:unload()

		arg_2_0.playerPhotoTexture = nil
	end
end

function NVMPlayerStatisticsHud.dispose(arg_3_0)
	if arg_3_0.teamTexture then
		arg_3_0.teamTexture:unload()

		arg_3_0.teamTexture = nil
	end

	if arg_3_0.secondaryTeamTexture then
		arg_3_0.secondaryTeamTexture:unload()

		arg_3_0.secondaryTeamTexture = nil
	end

	if arg_3_0.playerPhotoTexture then
		arg_3_0.playerPhotoTexture:unload()

		arg_3_0.playerPhotoTexture = nil
	end

	if arg_3_0.ShownStats then
		arg_3_0.ShownStats:dispose()

		arg_3_0.ShownStats = nil
	end

	var_0_0.dispose(arg_3_0)
end

function NVMPlayerStatisticsHud.setCompetitionId(arg_4_0, arg_4_1)
	if arg_4_1 then
		arg_4_0.competitionId = arg_4_1
		arg_4_0.ThemeOptionInt = arg_4_1:toInt()
		arg_4_0.inCleanState = false
	end
end

function NVMPlayerStatisticsHud.show(arg_5_0)
	arg_5_0.isPlayerStatisticVisible = true
	arg_5_0.isReadyToDisplay = false
	arg_5_0.inCleanState = false

	-- nrl-broadcast-scoreboard: copy this card's data to the Shown* properties. The stats rows are
	-- copied too, so PlayerStatsHud stays intact for the other HUD themes' templates.
	arg_5_0.ShownStats:dispose()

	for iter_5_0 = 1, arg_5_0.PlayerStatsHud.count do
		local var_5_0 = arg_5_0.PlayerStatsHud:getComponent(iter_5_0)

		if var_5_0 then
			local var_5_1 = nvm_notification.NVMNotification()

			var_5_1.Message = var_5_0.Message
			var_5_1.SecondMessage = var_5_0.SecondMessage

			arg_5_0.ShownStats:addComponent(var_5_1)
		end
	end

	arg_5_0.ShownName = arg_5_0.PlayerName or ""
	arg_5_0.ShownNumber = arg_5_0.PlayerNumber or ""
	arg_5_0.ShownPosition = arg_5_0.PlayerPosition or ""
	arg_5_0.ShownTeam = arg_5_0.Team or arg_5_0.HomeTeam
	arg_5_0.hideTimer = nil
	arg_5_0.IsShown = true
	arg_5_0.RevealKey = (arg_5_0.RevealKey + 1) % 1000000
end

function NVMPlayerStatisticsHud.getIsVisible(arg_6_0)
	return arg_6_0.isPlayerStatisticVisible
end

function NVMPlayerStatisticsHud.setIsReadyToDisplay(arg_7_0, arg_7_1)
	arg_7_0.isReadyToDisplay = arg_7_1
end

function NVMPlayerStatisticsHud.getIsReadyToDisplay(arg_8_0)
	return arg_8_0.isReadyToDisplay
end

function NVMPlayerStatisticsHud.clean(arg_9_0)
	-- nrl-broadcast-scoreboard: animate out; update() hides the card once the outro has played
	if arg_9_0.IsShown and not arg_9_0.hideTimer then
		arg_9_0.hideTimer = var_0_outro_time
		arg_9_0.HideKey = (arg_9_0.HideKey + 1) % 1000000
	end

	if not arg_9_0.inCleanState then
		arg_9_0.PlayerName = " "
		arg_9_0.PlayerNumber = " "
		arg_9_0.PlayerPosition = " "

		if arg_9_0.teamTexture then
			arg_9_0.teamTexture:unload()

			arg_9_0.teamTexture = nil
		end

		if arg_9_0.secondaryTeamTexture then
			arg_9_0.secondaryTeamTexture:unload()

			arg_9_0.secondaryTeamTexture = nil
		end

		if arg_9_0.playerPhotoTexture then
			arg_9_0.playerPhotoTexture:unload()

			arg_9_0.playerPhotoTexture = nil
		end

		arg_9_0.SecondaryTeamLogo = nil
		arg_9_0.PlayerPhoto = nil
		arg_9_0.TeamColour = nil
		arg_9_0.IsAway = false
		arg_9_0.isPlayerStatisticVisible = false
		arg_9_0.isReadyToDisplay = false

		arg_9_0:clearStatistics()

		arg_9_0.inCleanState = true
	end
end

function NVMPlayerStatisticsHud.clearStatistics(arg_10_0)
	arg_10_0.PlayerStatsHud:dispose()
end

function NVMPlayerStatisticsHud.setPlayerDetails(arg_11_0, arg_11_1, arg_11_2, arg_11_3, arg_11_4)
	formatPrint("[NVMPlayerStatisticsHud]: setPlayerDetails() called")
	formatPrintT("[NVMPlayerStatisticsHud]: setPlayerDetails - shortName: %t, jerseyNumber: %t, role: %t", arg_11_1, arg_11_2, arg_11_3)
	formatPrint("[NVMPlayerStatisticsHud]: setPlayerDetails - Using names like normal")

	arg_11_0.PlayerName = arg_11_1
	arg_11_0.PlayerNumber = tostring(arg_11_2)
	arg_11_0.PlayerPosition = native.Localise("PreferredRole_" .. tostring(arg_11_3))
	arg_11_0.inCleanState = false
end

function NVMPlayerStatisticsHud.setPlayerDetailsFromPlayer(arg_12_0, arg_12_1, arg_12_2)
	ASSERT(arg_12_1 ~= nil)
	ASSERT(arg_12_2 ~= nil)

	local var_12_0 = arg_12_1.primaryRole:toInt()

	if arg_12_0.jerseyNumberMap and arg_12_1.id and arg_12_1.id <= #arg_12_0.jerseyNumberMap then
		var_12_0 = arg_12_0.jerseyNumberMap[arg_12_1.id]
	end

	if arg_12_1 and arg_12_2 then
		arg_12_0:setPlayerDetails(arg_12_1.shortName, var_12_0, arg_12_1.primaryRole, arg_12_2)
	end
end

function NVMPlayerStatisticsHud.setPlayerImage(arg_13_0, arg_13_1, arg_13_2)
	return
end

function NVMPlayerStatisticsHud.setClub(arg_14_0, arg_14_1, arg_14_2, arg_14_3, arg_14_4)
	local var_14_0 = ""
	local var_14_1

	arg_14_0.Team = arg_14_4 and (arg_14_4 == hud_helper.HOME_SIDE and arg_14_0.HomeTeam or arg_14_0.AwayTeam) or arg_14_0.HomeTeam

	if arg_14_0.TeamRef then
		var_14_0 = arg_14_0.TeamRef.HudName
		var_14_1 = arg_14_0.TeamRef.PrimaryColour

		if not arg_14_0.TeamLogo then
			arg_14_0.TeamLogo = arg_14_0.TeamRef.TeamLogo
		end

		arg_14_0.TeamFullName = arg_14_0.TeamRef.FullName
		arg_14_0.TeamShortName = arg_14_0.TeamRef.ShortName
		arg_14_0.TeamHudName = arg_14_0.TeamRef.HudName
		arg_14_0.TeamHudTextColour = arg_14_0.TeamRef.HudTextColour
		arg_14_0.TeamPrimaryColour = arg_14_0.TeamRef.PrimaryColour
		arg_14_0.TeamSecondaryColour = arg_14_0.TeamRef.SecondaryColour
	end

	arg_14_0.TeamName = var_14_0
	arg_14_0.TeamColour = var_14_1
	arg_14_0.inCleanState = false
end

function NVMPlayerStatisticsHud.addStatistic(arg_15_0, arg_15_1, arg_15_2)
	if arg_15_0.PlayerStatsHud.count < var_0_2 then
		local var_15_0 = nvm_notification.NVMNotification()

		var_15_0.Message = arg_15_1
		var_15_0.SecondMessage = arg_15_2

		arg_15_0.PlayerStatsHud:addComponent(var_15_0)

		arg_15_0.inCleanState = false
	end
end

function NVMPlayerStatisticsHud.testEnter(arg_16_0, arg_16_1, arg_16_2, arg_16_3, arg_16_4)
	local var_16_0 = arg_16_4:getPlayerManager():getPlayer(10)
	local var_16_1 = arg_16_4:getClubManager():getClub(89)

	arg_16_0:setPlayer(arg_16_1, var_16_0)
	arg_16_0:setPlayerImage(arg_16_1, var_16_0)
	arg_16_0:setClub(arg_16_1, var_16_1)

	for iter_16_0 = 1, var_0_2 do
		arg_16_0:addStatistic("Goals", iter_16_0)
	end
end

function NVMPlayerStatisticsHud.testUpdate(arg_17_0, arg_17_1, arg_17_2, arg_17_3, arg_17_4)
	if arg_17_0.teamTexture and arg_17_0.teamTexture:isLoaded() then
		arg_17_0.TeamLogo = native.CNoesisTextureSource(arg_17_0.teamTexture)

		arg_17_0.teamTexture:unload()

		arg_17_0.teamTexture = nil
	end

	if arg_17_0.secondaryTeamTexture and arg_17_0.secondaryTeamTexture:isLoaded() then
		arg_17_0.SecondaryTeamLogo = native.CNoesisTextureSource(arg_17_0.secondaryTeamTexture)

		arg_17_0.secondaryTeamTexture:unload()

		arg_17_0.secondaryTeamTexture = nil
	end

	local var_17_0 = arg_17_1:getParty():getPrimaryPartyMember()

	if arg_17_4:checkForRelease(var_17_0, native.InputTypes.LT) then
		arg_17_0.ThemeOptionInt = arg_17_0.ThemeOptionInt == 6 and 1 or 6
	end
end

function NVMPlayerStatisticsHud.testExit(arg_18_0)
	return
end

Class("PlayerStatisticsInformation", function(arg_19_0)
	arg_19_0.inCleanState = false

	arg_19_0:clean()
end)

function PlayerStatisticsInformation.dispose(arg_20_0)
	arg_20_0.inCleanState = false

	arg_20_0:clean()
end

function PlayerStatisticsInformation.clean(arg_21_0)
	if not arg_21_0.inCleanState then
		if arg_21_0.player then
			arg_21_0.player.playerData = nil
		end

		if arg_21_0.team then
			arg_21_0.team.matchClub = nil
		end

		arg_21_0.player = {}
		arg_21_0.team = {}
		arg_21_0.statistics = {}
		arg_21_0.stateInformation = {}
		arg_21_0.matchData = nil
		arg_21_0.inCleanState = true
	end
end

function PlayerStatisticsInformation.setInformation(arg_22_0, arg_22_1, arg_22_2, arg_22_3, arg_22_4)
	ASSERT(arg_22_1 ~= nil)
	ASSERT(arg_22_2 ~= nil)

	local var_22_0 = arg_22_1.teamSide
	local var_22_1 = arg_22_1.playerId
	local var_22_2 = var_22_0 == native.ESide.Home:toInt()
	local var_22_3

	if var_22_2 == true then
		var_22_3 = arg_22_2.home
	else
		var_22_3 = arg_22_2.away
	end

	local var_22_4 = var_22_3.matchClub
	local var_22_5 = var_22_3:getAssetId(var_22_1)
	local var_22_6 = var_22_4:getPlayer(var_22_5)
	local var_22_7 = var_22_3:getJerseyNumberMap()[var_22_5]
	local var_22_8 = VERIFY(arg_22_3.matchSim.gamestate).roleInfoPool:get(var_22_1).assignedRole
	local var_22_9 = var_22_8 and var_22_8 or var_22_4.lineup:getAssignedRole(var_22_5)

	arg_22_0:setStateInformation(arg_22_1)
	arg_22_0:setMatchData(arg_22_2)
	arg_22_0:setPlayerInfo(var_22_5, var_22_1, var_22_6.firstName, var_22_6.surname, var_22_6.shortName, var_22_7, var_22_9, var_22_6)
	arg_22_0:setTeamInfo(var_22_2, var_22_0, var_22_4)

	arg_22_0.inCleanState = false
end

function PlayerStatisticsInformation.setStateInformation(arg_23_0, arg_23_1)
	arg_23_0.stateInformation = arg_23_1
	arg_23_0.inCleanState = false
end

function PlayerStatisticsInformation.setMatchData(arg_24_0, arg_24_1)
	arg_24_0.matchData = arg_24_1
	arg_24_0.inCleanState = false
end

function PlayerStatisticsInformation.setPlayerInfo(arg_25_0, arg_25_1, arg_25_2, arg_25_3, arg_25_4, arg_25_5, arg_25_6, arg_25_7, arg_25_8)
	formatPrint("[PlayerStatisticsInformation]: setPlayerInfo() called")
	formatPrintT("[PlayerStatisticsInformation]: setPlayerInfo - playerId: %t, playerAssetId: %t, playerFirstName: %t, playerSurname: %t, playerShortName: %t, jerseyNumber: %t, role: %t", arg_25_1, arg_25_2, arg_25_3, arg_25_4, arg_25_5, arg_25_6, arg_25_7)

	arg_25_0.player.playerId = arg_25_1
	arg_25_0.player.assetId = arg_25_2
	arg_25_0.player.firstName = arg_25_3 or " "
	arg_25_0.player.lastName = arg_25_4 or " "
	arg_25_0.player.shortName = arg_25_5 or " "
	arg_25_0.player.jerseyNumber = arg_25_6 or " "
	arg_25_0.player.role = arg_25_7
	arg_25_0.player.playerData = arg_25_8
	arg_25_0.inCleanState = false
end

function PlayerStatisticsInformation.setTeamInfo(arg_26_0, arg_26_1, arg_26_2, arg_26_3)
	formatPrint("[PlayerStatisticsInformation]: setTeamInfo() called")
	formatPrintT("[PlayerStatisticsInformation]: setTeamInfo - isHome: %t, teamSide: %t", arg_26_1, arg_26_2)

	arg_26_0.team.isHome = arg_26_1
	arg_26_0.team.side = arg_26_2
	arg_26_0.team.matchClub = arg_26_3
	arg_26_0.inCleanState = false
end

function PlayerStatisticsInformation.addStatistic(arg_27_0, arg_27_1, arg_27_2)
	if #arg_27_0.statistics < var_0_2 then
		arg_27_0.statistics[#arg_27_0.statistics + 1] = {
			name = arg_27_1,
			value = arg_27_2
		}
		arg_27_0.inCleanState = false
	end
end

function PlayerStatisticsInformation.addStatisticFromMatch(arg_28_0, arg_28_1)
	local var_28_0 = arg_28_0:getMatchStat(arg_28_0.matchData, arg_28_0.player.assetId, arg_28_1)

	arg_28_0:addStatistic(var_28_0.name, var_28_0.value)
end

function PlayerStatisticsInformation.addStatisticFromPlayer(arg_29_0, arg_29_1)
	local var_29_0 = arg_29_0:getPlayerStat(arg_29_0.player.playerData, arg_29_1)

	arg_29_0:addStatistic(var_29_0.name, var_29_0.value)
end

function PlayerStatisticsInformation.getMatchStat(arg_30_0, arg_30_1, arg_30_2, arg_30_3)
	ASSERT(arg_30_1 ~= nil)

	return {
		name = native.Localise("Stat_" .. arg_30_3),
		value = arg_30_1.statistics:getPlayerStat(arg_30_2, arg_30_3)
	}
end

function PlayerStatisticsInformation.getPlayerStat(arg_31_0, arg_31_1, arg_31_2)
	ASSERT(arg_31_1 ~= nil)
	ASSERT(arg_31_0.matchData ~= nil)

	local var_31_0 = arg_31_2:lower()
	local var_31_1

	if var_31_0 == "age" then
		local var_31_2 = arg_31_0.matchData.matchInProgressData.date

		if var_31_2 then
			var_31_1 = arg_31_1:getAge(var_31_2.year, var_31_2.month, var_31_2.day)
		end
	elseif var_31_0 == "height" or var_31_0 == "weight" then
		var_31_1 = arg_31_1.attributes:getOption(var_31_0)
	elseif var_31_0 == "foot" or var_31_0 == "hand" then
		local var_31_3 = var_31_0:sub(1, 1):upper() .. var_31_0:sub(2)

		if arg_31_1.identity:getOption("right" .. var_31_3 .. "ed") == true then
			var_31_1 = native.Localise("Right")
		else
			var_31_1 = native.Localise("Left")
		end
	elseif var_31_0 == "country" then
		local var_31_4 = arg_31_1.identity:getOption(var_31_0 .. "OfBirth")
		local var_31_5 = native.EAffiliations:fromInt(var_31_4)

		var_31_1 = native.EAffiliations[var_31_5]
	end

	return {
		name = native.Localise("Identity_" .. var_31_0),
		value = var_31_1
	}
end
