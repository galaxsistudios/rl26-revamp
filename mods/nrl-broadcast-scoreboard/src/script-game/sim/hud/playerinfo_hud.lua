import("base.side.sidehelper")
import("core.foundation.tablex")
import("core.profile.profile")
import("game.helpers.colour_helper")
import("app.noesis.hud.nvm_playerplate")
import("sim.hud.hud_helper")

local var_0_0 = {
	false,
	true
}

-- nrl-broadcast-scoreboard: position line on the player plate. Built on first use so
-- Localise runs once the string tables are up. (The stock scorer banner swaps HB/5-8.)
local var_0_role_names

local function var_0_role_name(arg_r_0, arg_r_1, arg_r_2)
	if not var_0_role_names then
		local var_r_0 = native.EAssignedRole

		var_0_role_names = {
			[var_r_0.FullBack] = native.Localise("FullBack"),
			[var_r_0.WingerLeft] = native.Localise("Winger"),
			[var_r_0.WingerRight] = native.Localise("Winger"),
			[var_r_0.CentreLeft] = native.Localise("Centre"),
			[var_r_0.CentreRight] = native.Localise("Centre"),
			[var_r_0.FiveEighth] = native.Localise("FiveEighth"),
			[var_r_0.HalfBack] = native.Localise("HalfBack"),
			[var_r_0.PropLeft] = native.Localise("Prop"),
			[var_r_0.PropRight] = native.Localise("Prop"),
			[var_r_0.Hooker] = native.Localise("Hooker"),
			[var_r_0.SecondRowLeft] = native.Localise("SecondRow"),
			[var_r_0.SecondRowRight] = native.Localise("SecondRow"),
			[var_r_0.Lock] = native.Localise("Lock")
		}
	end

	local var_r_1 = arg_r_0.roleInfoPool and arg_r_0.roleInfoPool:get(arg_r_1)
	local var_r_2 = var_r_1 and var_r_1.assignedRole or arg_r_2

	return var_r_2 and var_0_role_names[var_r_2] or ""
end

local function var_0_1(arg_1_0, arg_1_1, arg_1_2, arg_1_3)
	profile.push("setupInfoHudPosition")

	if arg_1_3 == sidehelper.home then
		arg_1_1 = arg_1_1 + 1

		arg_1_0:setBottomAllignment(var_0_0[arg_1_1])
	else
		arg_1_2 = arg_1_2 + 1

		arg_1_0:setBottomAllignment(var_0_0[arg_1_2])
	end

	profile.pop("setupInfoHudPosition")

	return arg_1_1, arg_1_2
end

local function var_0_2(arg_2_0)
	ASSERT(arg_2_0.infoHuds)

	local var_2_0 = arg_2_0.infoHuds

	for iter_2_0, iter_2_1 in ipairs(var_2_0) do
		iter_2_1:setShown(false)
	end
end

local function var_0_3(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5)
	profile.push("setupWidgetForObject")

	arg_3_1:setShown(true)

	arg_3_1:setGamer(arg_3_3)
	arg_3_1:setSide(arg_3_2)

	arg_3_4, arg_3_5 = var_0_1(arg_3_1, arg_3_4, arg_3_5, arg_3_2)

	profile.pop("setupWidgetForObject")

	return arg_3_4, arg_3_5
end

local function var_0_4(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6)
	profile.push("updateWidgetForObject")
	arg_4_2:update()

	local var_4_0 = arg_4_0.identity
	local var_4_1 = arg_4_0.team
	local var_4_2 = var_4_1:getAssetId(arg_4_0.id)
	local var_4_3 = var_4_1.matchClub.lineup
	local var_4_4 = var_4_3:getIndexForPlayer(var_4_2) + 1
	local var_4_5 = var_4_3:getShirtNumber(var_4_4)

	if var_4_5 == 0 then
		var_4_5 = var_4_1:getJerseyNumberMap()[var_4_2]
	end

	arg_4_2:setPlayerName(var_4_0.shortName)
	arg_4_2:setTeamName(var_4_1.hudName)
	arg_4_2:setPlayerNumber(var_4_5)
	arg_4_2:setGamer(arg_4_4)

	local var_4_6 = arg_4_6:get(arg_4_0.id).charge

	arg_4_2:updateStamina(var_4_6)

	-- discipline-meter: nil when that mod isn't installed, which hides the bar
	local var_4_disc = rawget(_G, "DisciplineState")

	if var_4_disc then
		arg_4_2:updateDiscipline(var_4_disc.get(arg_4_0.id))
	else
		arg_4_2:updateDiscipline(nil)
	end

	arg_4_2:setPlayerPosition(var_0_role_name(arg_4_1, arg_4_0.id, var_4_3:getAssignedRole(var_4_2)))

	if arg_4_5 then
		arg_4_2:setShown(false)
	else
		arg_4_2:setShown(true)
		arg_4_2:refreshReveal(arg_4_0.id)
	end

	profile.pop("updateWidgetForObject")
end

local function var_0_5(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5)
	profile.push("setupWidgetForGamer")

	local var_5_0 = arg_5_1:getGamerId()
	local var_5_1 = arg_5_1.side
	local var_5_2 = 0

	for iter_5_0, iter_5_1 in ipairs(arg_5_0.gamers:getAllGamersOnSide(var_5_1)) do
		if arg_5_1.localGamerIndex == iter_5_1.localGamerIndex then
			var_5_2 = var_5_1 == 1 and 0 + iter_5_0 or 2 + iter_5_0
		end
	end

	local var_5_3 = arg_5_0.infoHuds[var_5_2]
	local var_5_4 = arg_5_1.objectId

	if var_5_4 then
		local var_5_5 = 128

		ASSERT(var_5_4 ~= var_5_5)

		arg_5_4, arg_5_5 = var_0_3(arg_5_2, var_5_3, var_5_1, var_5_2, arg_5_4, arg_5_5)
		arg_5_0.inUseHuds[var_5_2] = true
	end

	profile.pop("setupWidgetForGamer")

	return arg_5_4, arg_5_5
end

local function var_0_6(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5)
	profile.push("updateWidgetForGamer")

	local var_6_0 = arg_6_1:getGamerId()
	local var_6_1 = colour_helper.getPlayerColourIndex(var_6_0.participantId, var_6_0.localGamerIndex)
	local var_6_2 = arg_6_1.side
	local var_6_3 = 0

	for iter_6_0, iter_6_1 in ipairs(arg_6_0.gamers:getAllGamersOnSide(var_6_2)) do
		if arg_6_1.localGamerIndex == iter_6_1.localGamerIndex then
			var_6_3 = var_6_2 == 1 and 0 + iter_6_0 or 2 + iter_6_0
		end
	end

	local var_6_4 = arg_6_0.infoHuds[var_6_3]
	local var_6_5 = arg_6_1.objectId

	if var_6_5 then
		local var_6_6 = 128

		ASSERT(var_6_5 ~= var_6_6)

		local var_6_7 = arg_6_3:getGameObject(var_6_5)

		var_0_4(var_6_7, arg_6_2, var_6_4, var_6_2, var_6_3, arg_6_4, arg_6_5)
	end

	profile.pop("updateWidgetForGamer")
end

local function var_0_7(arg_7_0, arg_7_1)
	local var_7_0
	local var_7_1
	local var_7_2 = arg_7_0.infoHuds

	for iter_7_0, iter_7_1 in ipairs(var_7_2) do
		if not arg_7_0.inUseHuds[iter_7_0] and (arg_7_1 == 1 and iter_7_0 <= 2 or arg_7_1 == 2 and iter_7_0 >= 3) then
			var_7_0 = iter_7_1
			var_7_1 = iter_7_0

			break
		end
	end

	return var_7_0, var_7_1
end

local function var_0_8(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5, arg_8_6, arg_8_7)
	profile.push("addAIPlayerForSide")

	local var_8_0, var_8_1 = var_0_7(arg_8_0, arg_8_1)
	local var_8_2 = arg_8_2:getBallEntity()
	local var_8_3 = var_8_2:getOwnerId(arg_8_5) or var_8_2:getLastOwnerId(arg_8_5)

	if var_8_3 and var_8_0 then
		local var_8_4 = arg_8_3:getGameObject(var_8_3)
		local var_8_5 = var_8_1

		arg_8_6, arg_8_7 = var_0_3(arg_8_2, var_8_0, arg_8_1, 0, arg_8_6, arg_8_7)
		arg_8_0.inUseHuds[var_8_5] = true
	end

	profile.pop("addAIPlayerForSide")

	return arg_8_6, arg_8_7
end

local function var_0_9(arg_9_0, arg_9_1, arg_9_2)
	ASSERT(arg_9_0)

	-- nrl-broadcast-scoreboard: name no longer blanked, it stays on the plate while it animates out
	arg_9_0:setShown(false)
	arg_9_0:setGamer(arg_9_2)
end

local function var_0_10(arg_10_0, arg_10_1, arg_10_2, arg_10_3, arg_10_4, arg_10_5, arg_10_6, arg_10_7, arg_10_8, arg_10_9)
	profile.push("updateAIPlayerForSide")

	if arg_10_6 > 0 and arg_10_7 > 0 then
		profile.pop("updateAIPlayerForSide")

		return
	end

	local var_10_0 = arg_10_6 > 0 and sidehelper.away or sidehelper.home
	local var_10_1 = arg_10_2:getBallEntity()
	local var_10_2 = var_10_1:getOwnerId(arg_10_5) or var_10_1:getLastOwnerId(arg_10_5)
	local var_10_3 = arg_10_0.infoHuds

	for iter_10_0, iter_10_1 in ipairs(var_10_3) do
		if iter_10_1:getIsAIHud() then
			local var_10_4 = 0

			if var_10_2 then
				local var_10_5 = arg_10_3:getGameObject(var_10_2)
				local var_10_6 = arg_10_0.inUseHuds[iter_10_0]

				if var_10_5.side == var_10_0 and var_10_6 then
					var_0_4(var_10_5, arg_10_2, iter_10_1, var_10_0, var_10_4, arg_10_8, arg_10_9)
				else
					var_0_9(iter_10_1, iter_10_0, var_10_4)
				end
			else
				var_0_9(iter_10_1, iter_10_0, var_10_4)
			end
		end
	end

	profile.pop("updateAIPlayerForSide")
end

local function var_0_11(arg_11_0, arg_11_1)
	local var_11_0 = 999
	local var_11_1

	for iter_11_0, iter_11_1 in ipairs(arg_11_0) do
		local var_11_2 = native.distance2(iter_11_1.pos, arg_11_1)

		if var_11_2 < 0.5 then
			return iter_11_1.id
		end

		if var_11_2 < var_11_0 then
			var_11_0 = var_11_2
			var_11_1 = iter_11_1.id
		end
	end

	return var_11_1
end

local function var_0_12(arg_12_0, arg_12_1, arg_12_2, arg_12_3, arg_12_4, arg_12_5, arg_12_6, arg_12_7)
	local var_12_0 = arg_12_2:getBallEntity()
	local var_12_1 = var_12_0:getOwnerId(arg_12_5) or var_12_0:getLastOwnerId(arg_12_5)

	if not var_12_1 then
		var_0_2(arg_12_0)
	else
		local var_12_2 = 0
		local var_12_3 = arg_12_3:getGameObject(var_12_1)
		local var_12_4 = var_12_3.side
		local var_12_5 = var_12_4 == 1 and 1 or 3
		local var_12_6 = arg_12_0.infoHuds[var_12_5]

		for iter_12_0, iter_12_1 in ipairs(arg_12_0.infoHuds) do
			if iter_12_0 == var_12_5 then
				arg_12_0.inUseHuds[iter_12_0] = true
			else
				var_0_9(iter_12_1, iter_12_0, var_12_2)
			end
		end

		var_0_4(var_12_3, arg_12_2, var_12_6, var_12_4, var_12_2, arg_12_6, arg_12_7)
	end
end

Class("PlayerInfoHud", function(arg_13_0, arg_13_1, arg_13_2, arg_13_3, arg_13_4, arg_13_5, arg_13_6, arg_13_7)
	local var_13_0 = arg_13_4.knowledgeBank
	local var_13_1 = arg_13_7.featureStack

	arg_13_0.infoHuds = tablex.icreate(4, function(arg_14_0)
		local var_14_0 = nvm_playerplate.NVMPlayerPlate(arg_13_7)
		local var_14_1 = arg_14_0 < 3
		local var_14_2 = var_14_1 and "Home" or "Away"
		local var_14_3 = (arg_14_0 == 2 or arg_14_0 == 4) and "Top" or "Bottom"

		var_14_0.Team = var_14_1 and var_14_0.HomeTeam or var_14_0.AwayTeam
		var_14_0.themeOption = arg_13_2.stateOfTheSeason.competitionId or native.CareerCompetitionIdEnum.CareerCompetitionCount

		var_13_1:registerViewModel(hud_helper.HUD_IDENTIFIERS.gameplay, "PlayerPlate" .. var_14_2 .. "" .. var_14_3, var_14_0)

		return var_14_0
	end)
	arg_13_0.enabled = false
	arg_13_0.hudFeatureStack = var_13_1
	arg_13_0.inUseHuds = {}
	arg_13_0.matchInData = arg_13_2
	arg_13_0.needsReinitialise = true
	arg_13_0.staminaInfoPool = var_13_0.staminaInfoPool
	arg_13_0.waitFrame = true

	var_13_1:register("playerInfo", arg_13_0, function()
		arg_13_0:show()
	end, function()
		arg_13_0:hide()
	end)
end)

function PlayerInfoHud.registerWithMatchSim(arg_17_0, arg_17_1)
	local function var_17_0(arg_18_0)
		return function(...)
			return arg_18_0(arg_17_0, ...)
		end
	end

	local var_17_1 = {
		GamerSideChangeEvent = var_17_0(arg_17_0.onGamerSideChangeEvent)
	}

	for iter_17_0, iter_17_1 in pairs(var_17_1) do
		arg_17_1:registerSolidEventListener(iter_17_1, iter_17_0)
	end
end

function PlayerInfoHud.onGamerSideChangeEvent(arg_20_0, arg_20_1, arg_20_2, arg_20_3, arg_20_4, arg_20_5, arg_20_6, arg_20_7, arg_20_8, arg_20_9)
	ASSERT(arg_20_0.needsReinitialise ~= nil)

	arg_20_0.needsReinitialise = true
	arg_20_0.waitFrame = true
end

function PlayerInfoHud.reinitialiseAllHuds(arg_21_0, arg_21_1, arg_21_2, arg_21_3, arg_21_4, arg_21_5)
	ASSERT(arg_21_0.waitFrame ~= nil)

	if arg_21_0.waitFrame then
		arg_21_0.waitFrame = false

		return
	end

	arg_21_0.gamers = arg_21_1

	var_0_2(arg_21_0)

	arg_21_0.inUseHuds = {}

	local var_21_0 = 0
	local var_21_1 = 0

	for iter_21_0, iter_21_1 in arg_21_1:iterLocalGamers() do
		var_21_0, var_21_1 = var_0_5(arg_21_0, iter_21_1, arg_21_2, arg_21_3, var_21_0, var_21_1)
	end

	for iter_21_2, iter_21_3 in arg_21_1:iterRemoteGamers() do
		var_21_0, var_21_1 = var_0_5(arg_21_0, iter_21_3, arg_21_2, arg_21_3, var_21_0, var_21_1)
	end

	if var_21_0 == 0 then
		var_21_0, var_21_1 = var_0_8(arg_21_0, sidehelper.home, arg_21_2, arg_21_3, arg_21_4, arg_21_5, var_21_0, var_21_1)
	end

	if var_21_1 == 0 then
		var_0_8(arg_21_0, sidehelper.away, arg_21_2, arg_21_3, arg_21_4, arg_21_5, var_21_0, var_21_1)
	end

	ASSERT(arg_21_0.needsReinitialise ~= nil)

	arg_21_0.needsReinitialise = false
end

function PlayerInfoHud.dispose(arg_22_0, arg_22_1)
	for iter_22_0, iter_22_1 in ipairs(arg_22_0.infoHuds) do
		arg_22_0.hudFeatureStack:unregisterHUDElement(hud_helper.HUD_IDENTIFIERS.gameplay, iter_22_1)
		iter_22_1:dispose()
	end

	arg_22_0.hudFeatureStack = nil
end

local function var_0_13(arg_23_0, arg_23_1, arg_23_2, arg_23_3)
	local var_23_0 = VERIFY(arg_23_0:getComponent("matchInData")).beAProAssetId or 0

	if var_23_0 ~= native.INVALID_PLAYER_ID then
		local var_23_1 = arg_23_3.knowledgeBank

		ASSERT(var_23_1)

		local var_23_2 = var_23_1.teamInPlayKnowledgePair

		ASSERT(var_23_2)

		local var_23_3 = arg_23_0:getSide(sidehelper.home)
		local var_23_4 = arg_23_0:getSide(sidehelper.away)
		local var_23_5 = var_23_3:getIdAsset(var_23_0) or var_23_4:getIdAsset(var_23_0)

		ASSERT(var_23_5)

		local var_23_6 = arg_23_2:getGameObject(var_23_5)
		local var_23_7 = VERIFY(arg_23_1:getMatchProgressionEntity()).attackingSide
		local var_23_8 = var_23_7 == var_23_6.side and var_23_7 or sidehelper.getOtherSide(var_23_7)
		local var_23_9 = var_23_2:get(var_23_8).sidelineSet

		ASSERT(var_23_9)

		for iter_23_0, iter_23_1 in var_23_9:iter() do
			if iter_23_1 == var_23_5 then
				return true
			end
		end

		return false
	end
end

function PlayerInfoHud.updateWidgets(arg_24_0, arg_24_1, arg_24_2, arg_24_3, arg_24_4, arg_24_5, arg_24_6)
	local var_24_0 = arg_24_5.network:isMaster()
	local var_24_1 = #arg_24_2:getAllGamersOnSide(sidehelper.home, var_24_0)
	local var_24_2 = #arg_24_2:getAllGamersOnSide(sidehelper.away, var_24_0)
	local var_24_3 = var_0_13(arg_24_1, arg_24_3, arg_24_4, arg_24_5)
	local var_24_4 = not arg_24_0.enabled

	if (var_24_1 > 0 or var_24_2 > 0) and not var_24_3 then
		for iter_24_0, iter_24_1 in arg_24_2:iterLocalGamers() do
			var_0_6(arg_24_0, iter_24_1, arg_24_3, arg_24_4, var_24_4, arg_24_0.staminaInfoPool)
		end

		for iter_24_2, iter_24_3 in arg_24_2:iterRemoteGamers() do
			var_0_6(arg_24_0, iter_24_3, arg_24_3, arg_24_4, var_24_4, arg_24_0.staminaInfoPool)
		end

		var_0_10(arg_24_0, arg_24_2, arg_24_3, arg_24_4, arg_24_5, arg_24_6, var_24_1, var_24_2, var_24_4, arg_24_0.staminaInfoPool)
	else
		var_0_12(arg_24_0, arg_24_2, arg_24_3, arg_24_4, arg_24_5, arg_24_6, var_24_4, arg_24_0.staminaInfoPool)
	end
end

function PlayerInfoHud.update(arg_25_0, arg_25_1, arg_25_2, arg_25_3, arg_25_4, arg_25_5, arg_25_6, arg_25_7, arg_25_8, arg_25_9, arg_25_10, arg_25_11, arg_25_12)
	if not arg_25_0.enabled then
		var_0_2(arg_25_0)
	elseif arg_25_0.needsReinitialise then
		arg_25_0:reinitialiseAllHuds(arg_25_4, arg_25_5, arg_25_6, arg_25_2, arg_25_9)
	else
		arg_25_0:updateWidgets(arg_25_3, arg_25_4, arg_25_5, arg_25_6, arg_25_2, arg_25_9)
	end

	-- nrl-broadcast-scoreboard: plates settle their requested visibility once per frame, so a
	-- hide followed by a show in the same frame (reinitialiseAllHuds) never plays the outro
	for iter_25_0, iter_25_1 in ipairs(arg_25_0.infoHuds) do
		iter_25_1:tick(arg_25_8 or 0)
	end
end

function PlayerInfoHud.render(arg_26_0, arg_26_1, arg_26_2, arg_26_3, arg_26_4)
	return
end

function PlayerInfoHud.fade(arg_27_0, arg_27_1)
	return
end

function PlayerInfoHud.show(arg_28_0)
	arg_28_0.isVisible = true
	arg_28_0.enabled = true
end

function PlayerInfoHud.hide(arg_29_0)
	arg_29_0.enabled = false
end
