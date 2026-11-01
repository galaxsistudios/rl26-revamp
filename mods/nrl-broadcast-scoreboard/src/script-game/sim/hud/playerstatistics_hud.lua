import("app.noesis.ingame.nvm_playerStatisticsHud")
import("design.ui.playerstatisticshud_config")
import("sim.hud.hud_helper")

local var_0_0 = playerstatisticshud_config.checkStateExists
local var_0_1 = playerstatisticshud_config.checkStateIsShowState
local var_0_2 = playerstatisticshud_config.dispose
local var_0_3 = playerstatisticshud_config.getAllStates
local var_0_4 = playerstatisticshud_config.getScoreTypes
local var_0_5 = playerstatisticshud_config.getShowState
local var_0_6 = playerstatisticshud_config.getHideStates
local var_0_7 = playerstatisticshud_config.getIgnoreStates
local var_0_8 = playerstatisticshud_config.getEventParameters
local var_0_9 = playerstatisticshud_config.getStatistics
local var_0_10 = 5
-- nrl-broadcast-scoreboard: debug log of states/visibility to playerstatistics_debug.txt (game
-- folder) while the try card is being checked. Turn off once confirmed.
local var_0_debug_log = true

local function var_0_log(...)
	if not var_0_debug_log then
		return
	end

	local var_l_1 = table.concat({
		...
	}, " ")

	pcall(function()
		local var_l_0 = io.open("playerstatistics_debug.txt", "a")

		if var_l_0 then
			var_l_0:write(os.date("%H:%M:%S"), " ", var_l_1, "\n")
			var_l_0:close()
		end
	end)
end

Class("PlayerStatisticsHud", function(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7)
	local var_1_0 = arg_1_2 and arg_1_2.stateOfTheSeason and arg_1_2.stateOfTheSeason.competitionId or nil
	local var_1_1 = arg_1_7.featureStack
	local var_1_2 = var_1_1.features.playerInfo
	local var_1_3 = VERIFY(nvm_playerStatisticsHud.NVMPlayerStatisticsHud(arg_1_7))
	local var_1_4 = VERIFY(nvm_playerStatisticsHud.NVMPlayerStatisticsHud(arg_1_7))

	var_1_3:setCompetitionId(var_1_0)
	var_1_4:setCompetitionId(var_1_0)

	arg_1_0.awayPlayerStatisticsVM = var_1_3
	arg_1_0.homePlayerStatisticsVM = var_1_4
	arg_1_0.hudFeatureStack = VERIFY(var_1_1)
	arg_1_0.statisticsInformation = VERIFY(nvm_playerStatisticsHud.PlayerStatisticsInformation())

	var_1_1:registerViewModel(hud_helper.HUD_IDENTIFIERS.gameplay, "HomePlayerStatistics", var_1_4)
	var_1_1:registerViewModel(hud_helper.HUD_IDENTIFIERS.gameplay, "AwayPlayerStatistics", var_1_3)
	var_1_1:register("playerstatisticshud", arg_1_0, function(arg_2_0)
		-- nrl-broadcast-scoreboard: HUD back up (after a cutscene/replay). A card that was waiting
		-- through it replays its intro now that it can be seen.
		var_0_log("hud show, showing=" .. tostring(arg_1_0:currentlyShowing() and true or false))

		if arg_1_0.hudHidden and not arg_1_0.disposed then
			for iter_2_0, iter_2_1 in ipairs({
				arg_1_0.homePlayerStatisticsVM,
				arg_1_0.awayPlayerStatisticsVM
			}) do
				if iter_2_1.IsShown and not iter_2_1.hideTimer then
					iter_2_1.RevealKey = (iter_2_1.RevealKey + 1) % 1000000
				end
			end
		end

		arg_1_0.hudHidden = false
	end, function()
		if arg_1_0.disposed then
			return
		end

		arg_1_0.hudHidden = true

		var_0_log("hud hide, showing=" .. tostring(arg_1_0:currentlyShowing() and true or false))

		if arg_1_0:currentlyShowing() and not arg_1_0:isWaitingForState() then
			arg_1_0:reset()
		end
	end)
	arg_1_0:reset()
end)

function PlayerStatisticsHud.update(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7, arg_4_8, arg_4_9, arg_4_10, arg_4_11, arg_4_12)
	if arg_4_0.disposed then
		return
	end

	if arg_4_0.homePlayerStatisticsVM:getIsReadyToDisplay() then
		arg_4_0:show(true)
	end

	if arg_4_0.awayPlayerStatisticsVM:getIsReadyToDisplay() then
		arg_4_0:show(false)
	end

	if arg_4_0:currentlyShowing() then
		if var_0_10 > arg_4_0.displayTimer then
			-- nrl-broadcast-scoreboard: only count time the card can actually be seen
			if not arg_4_0.hudHidden then
				arg_4_0.displayTimer = arg_4_0.displayTimer + arg_4_8
			end
		else
			var_0_log("display timer done -> reset")
			arg_4_0:reset()
		end
	end

	-- nrl-broadcast-scoreboard: pass dt so the cards can finish their outro before hiding
	arg_4_0.homePlayerStatisticsVM:update(arg_4_8)
	arg_4_0.awayPlayerStatisticsVM:update(arg_4_8)
end

function PlayerStatisticsHud.render(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4)
	return
end

function PlayerStatisticsHud.dispose(arg_6_0)
	arg_6_0.hudFeatureStack:unregisterHUDElement(hud_helper.HUD_IDENTIFIERS.gameplay, arg_6_0.homePlayerStatisticsVM)
	arg_6_0.hudFeatureStack:unregisterHUDElement(hud_helper.HUD_IDENTIFIERS.gameplay, arg_6_0.awayPlayerStatisticsVM)
	arg_6_0.homePlayerStatisticsVM:dispose()
	arg_6_0.awayPlayerStatisticsVM:dispose()
	arg_6_0.statisticsInformation:dispose()
	var_0_2()

	arg_6_0.hudFeatureStack = nil
	arg_6_0.homePlayerStatisticsVM = nil
	arg_6_0.awayPlayerStatisticsVM = nil
	arg_6_0.statisticsInformation = nil
	arg_6_0.disposed = true
end

function PlayerStatisticsHud.registerWithMatchSim(arg_7_0, arg_7_1)
	local var_7_0 = var_0_3()

	if var_7_0 then
		ASSERT(arg_7_1 ~= nil)

		local function var_7_1(arg_8_0)
			return function(...)
				return arg_8_0(arg_7_0, ...)
			end
		end

		for iter_7_0, iter_7_1 in pairs(var_7_0) do
			arg_7_1:registerSolidEventListener(var_7_1(arg_7_0.onEvent), iter_7_1)
		end

		arg_7_1:registerRuleStateListener(arg_7_0)
	end
end

function PlayerStatisticsHud.clean(arg_10_0)
	arg_10_0.displayTimer = 0
	arg_10_0.showState = nil
	arg_10_0.activeState = nil
	arg_10_0.hideStates = nil
	arg_10_0.ignoreStates = nil

	if arg_10_0.statisticsInformation then
		arg_10_0.statisticsInformation:clean()
	end
end

function PlayerStatisticsHud.reset(arg_11_0)
	var_0_log("reset")
	arg_11_0:clean()
	arg_11_0:hideAllHuds()
end

function PlayerStatisticsHud.getPlayerStatisticsHud(arg_12_0, arg_12_1)
	return arg_12_1 and arg_12_0.homePlayerStatisticsVM or arg_12_0.awayPlayerStatisticsVM
end

function PlayerStatisticsHud.show(arg_13_0, arg_13_1)
	var_0_log("show card home=" .. tostring(arg_13_1), "hudHidden=" .. tostring(arg_13_0.hudHidden and true or false))
	arg_13_0:getPlayerStatisticsHud(arg_13_1):show()

	arg_13_0.enabled = true
end

function PlayerStatisticsHud.hide(arg_14_0, arg_14_1)
	arg_14_0:getPlayerStatisticsHud(arg_14_1):clean()

	if not arg_14_0:currentlyShowing() then
		arg_14_0.enabled = false
	end
end

function PlayerStatisticsHud.hideAllHuds(arg_15_0)
	arg_15_0:hide(true)
	arg_15_0:hide(false)
end

function PlayerStatisticsHud.currentlyShowing(arg_16_0)
	return arg_16_0.homePlayerStatisticsVM:getIsVisible() or arg_16_0.awayPlayerStatisticsVM:getIsVisible()
end

function PlayerStatisticsHud.isWaitingForState(arg_17_0)
	return arg_17_0.statisticsInformation.stateInformation.hideStates ~= nil or arg_17_0.statisticsInformation.stateInformation.ignoreStates ~= nil
end

function PlayerStatisticsHud.onEvent(arg_18_0, arg_18_1, arg_18_2, arg_18_3, arg_18_4, arg_18_5, arg_18_6, arg_18_7, arg_18_8, arg_18_9)
	local var_18_0 = arg_18_1
	local var_18_1

	if arg_18_1.type then
		var_18_1 = arg_18_1.type
	end

	arg_18_0:handleState(var_18_1, var_18_0, arg_18_2, arg_18_4, arg_18_6)
end

function PlayerStatisticsHud.onRuleStateChanged(arg_19_0, arg_19_1, arg_19_2, arg_19_3, arg_19_4, arg_19_5, arg_19_6, arg_19_7, arg_19_8)
	local var_19_0 = arg_19_1 or arg_19_2
	local var_19_1

	if var_19_0 then
		var_19_1 = type(var_19_0)
	end

	arg_19_0:handleState(var_19_1, var_19_0, nil, arg_19_3, arg_19_4)
end

function PlayerStatisticsHud.handleState(arg_20_0, arg_20_1, arg_20_2, arg_20_3, arg_20_4, arg_20_5)
	if arg_20_0.disposed then
		return
	end

	local var_20_0 = false

	var_0_log("state", tostring(arg_20_1), "showing=" .. tostring(arg_20_0:currentlyShowing() and true or false))

	if not arg_20_0:currentlyShowing() then
		if var_0_1(arg_20_1) then
			local var_20_1 = arg_20_0:getStateInformation(arg_20_2)

			if var_20_1 then
				var_20_0 = true

				arg_20_0:reset()
				arg_20_0:eventRequiringReconstruction(var_20_1, arg_20_3, arg_20_4, arg_20_5)
			end
		end
	else
		local var_20_2 = arg_20_0.statisticsInformation.stateInformation.ignoreStates
		local var_20_3 = arg_20_0.statisticsInformation.stateInformation.hideStates
		local var_20_4 = false

		if var_20_2 and arg_20_1 and var_20_2[arg_20_1] then
			var_20_4 = true
			var_20_2[arg_20_1] = nil

			if #var_20_2 == 0 then
				arg_20_0.statisticsInformation.stateInformation.ignoreStates = nil
			end
		end

		if not var_20_4 then
			if var_20_3 then
				if arg_20_1 and var_20_3[arg_20_1] then
					var_20_0 = true

					arg_20_0:reset()
				end
			else
				arg_20_0:reset()
			end
		end
	end

	return var_20_0
end

function PlayerStatisticsHud.eventRequiringReconstruction(arg_21_0, arg_21_1, arg_21_2, arg_21_3, arg_21_4)
	ASSERT(arg_21_4 ~= nil)

	local var_21_0 = arg_21_0:getStatisticsForEvent(arg_21_1)

	if var_21_0 and #var_21_0 >= 1 then
		arg_21_0.statisticsInformation:setInformation(arg_21_1, arg_21_4, arg_21_2, arg_21_3)
		arg_21_0:updateStatisticsInformation(var_21_0)
		arg_21_0:setPlayerStatisticsHudVM(arg_21_3.engine, arg_21_4.matchInData[(arg_21_1.teamSide == 1 and "home" or "away") .. "TeamConfig"])
	end
end

function PlayerStatisticsHud.updateStatisticsInformation(arg_22_0, arg_22_1)
	if arg_22_1 then
		for iter_22_0 = 1, #arg_22_1 do
			for iter_22_1, iter_22_2 in pairs(arg_22_1[iter_22_0]) do
				local var_22_0 = iter_22_2

				if type(iter_22_2) == "table" then
					var_22_0 = iter_22_2[arg_22_0:getRandomStatisticIndex(iter_22_2)]
				end

				arg_22_0:AddStatisticToStatisticsInformation(iter_22_1, tostring(var_22_0))
			end
		end
	end
end

function PlayerStatisticsHud.getRandomStatisticIndex(arg_23_0, arg_23_1)
	if arg_23_1 and #arg_23_1 > 0 then
		return native.Random.FromSystemTime():next(1, #arg_23_1)
	end

	return nil
end

function PlayerStatisticsHud.AddStatisticToStatisticsInformation(arg_24_0, arg_24_1, arg_24_2)
	if arg_24_1 == "statistic" then
		arg_24_0.statisticsInformation:addStatisticFromMatch(arg_24_2)
	elseif arg_24_1 == "player" then
		arg_24_0.statisticsInformation:addStatisticFromPlayer(arg_24_2)
	end
end

function PlayerStatisticsHud.setPlayerStatisticsHudVM(arg_25_0, arg_25_1, arg_25_2)
	local var_25_0 = arg_25_0.statisticsInformation.team.isHome
	local var_25_1 = arg_25_0:getPlayerStatisticsHud(var_25_0)
	local var_25_2 = arg_25_0.statisticsInformation.player
	local var_25_3 = arg_25_0.statisticsInformation.statistics
	local var_25_4 = arg_25_0.statisticsInformation.team

	var_25_1:setPlayerDetails(var_25_2.shortName, var_25_2.jerseyNumber, var_25_2.role, var_25_2.playerData.identity)
	var_25_1:setPlayerImage(arg_25_1, var_25_2.player)
	var_25_1:setClub(arg_25_1, var_25_4.matchClub, arg_25_2, var_25_4.side)

	for iter_25_0, iter_25_1 in pairs(var_25_3) do
		var_25_1:addStatistic(iter_25_1.name, iter_25_1.value)
	end

	var_25_1:setIsReadyToDisplay(true)
end

function PlayerStatisticsHud.getStateInformation(arg_26_0, arg_26_1)
	if not arg_26_1 then
		return nil
	end

	local var_26_0 = var_0_5(arg_26_1.type)
	local var_26_1
	local var_26_2
	local var_26_3 = var_0_4(var_26_0)

	if var_26_3 then
		for iter_26_0, iter_26_1 in pairs(var_26_3) do
			local var_26_4 = var_0_8(var_26_0, iter_26_1)
			local var_26_5 = var_26_4.scoreType

			if var_26_5 and arg_26_1[var_26_5] then
				local var_26_6

				if type(arg_26_1[var_26_5]) ~= type(native.EScoreType) then
					var_26_6 = native.EScoreType[arg_26_1[var_26_5]]
				else
					var_26_6 = arg_26_1[var_26_5]
				end

				if var_26_6 == iter_26_1 then
					var_26_2 = var_26_4

					break
				end
			end
		end
	else
		var_26_2 = var_0_8(var_26_0, nil)
	end

	if var_26_2 then
		var_26_1 = {}

		for iter_26_2, iter_26_3 in pairs(var_26_2) do
			var_26_1[iter_26_2] = arg_26_1[iter_26_3]
		end

		var_26_1.showState = var_26_0
		var_26_1.hideStates = var_0_6(var_26_0, var_26_1.scoreType)
		var_26_1.ignoreStates = var_0_7(var_26_0, var_26_1.scoreType)
	end

	return var_26_1
end

function PlayerStatisticsHud.getStatisticsForEvent(arg_27_0, arg_27_1)
	ASSERT(arg_27_1 ~= nil)

	return (var_0_9(arg_27_1.showState, arg_27_1.scoreType))
end
