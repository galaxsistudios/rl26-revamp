import("app.noesis.ns")
import("app.noesis.ns_viewmodel")
import("app.noesis.ns_observablecollection")
import("game.ui.noesis.viewmodels.nvm_notification")
import("app.noesis.util.nvm_team")
import("uicore.uiutil")

local var_0_0 = ns_viewmodel.ViewModel
local var_0_1 = ns_observablecollection.ObservableCollection

ns.Class("NVMInterchangePlayer", var_0_0, function(arg_1_0)
	var_0_0.init(arg_1_0)
end).Bindings = {
	Namespace = "Workspace.ViewModels.HUD.Rugby",
	Properties = {
		ShortName = ns.String,
		Role = ns.String,
		Stamina = ns.String,
		IsInjured = ns.Bool,
		LowStamina = ns.Bool,
		Position = ns.String,
		Number = ns.String,
		StaminaValue = ns.Int32,
		StaminaLevel = ns.Int32
	}
}
ns.Class("NVMSubstitutionHud", var_0_0, function(arg_2_0, arg_2_1, arg_2_2, arg_2_3)
	var_0_0.init(arg_2_0)

	arg_2_0.ManagingInterchange = false
	arg_2_0.TooltipList = var_0_1()
	arg_2_0.BenchPlayers = var_0_1()
	arg_2_0.OnFieldPlayers = var_0_1()

	arg_2_0:setClub(arg_2_1, arg_2_2, arg_2_3)

	arg_2_0.SelectedOnFieldPlayer = 1
	arg_2_0.SelectedBenchPlayer = 1
	arg_2_0.closeTimer = 0
	arg_2_0.isSubstitutionHudVisible = false
	arg_2_0.IsClosing = false
	arg_2_0.ChoosingBench = false
end).Bindings = {
	Properties = {
		IsClosing = ns.Bool,
		ChoosingBench = ns.Bool,
		BenchPlayers = ns.typeOf(var_0_1),
		OnFieldPlayers = ns.typeOf(var_0_1),
		TooltipList = ns.typeOf(var_0_1),
		SelectedOnFieldPlayer = ns.Int8,
		SelectedBenchPlayer = ns.Int8,
		Team = ns.typeOf(nvm_team.NVMTeam),
		ReplacementHeading = ns.String,
		SubsRemainingDisplay = ns.String,
		ManagingInterchange = ns.Bool,
		isSubstitutionHudVisible = ns.Bool
	}
}

function NVMSubstitutionHud.AddToolTipRow(arg_3_0, arg_3_1, arg_3_2)
	local var_3_0 = nvm_notification.NVMNotification()

	var_3_0.Message = arg_3_1
	var_3_0.SecondMessage = arg_3_2

	arg_3_0.TooltipList:addComponent(var_3_0)
end

function NVMSubstitutionHud.setManagingInterchange(arg_4_0, arg_4_1)
	arg_4_0.TooltipList:dispose()

	if arg_4_1 then
		arg_4_0:AddToolTipRow(native.Localise("Exit"), "|DPADLEFT|")
		arg_4_0:AddToolTipRow(native.Localise("Confirm"), "|DPADRIGHT|")
	else
		arg_4_0:AddToolTipRow(native.Localise("Forwards"), "|DPADUP|")
		arg_4_0:AddToolTipRow(native.Localise("Backs"), "|DPADDOWN|")
		arg_4_0:AddToolTipRow(native.Localise("Exit"), "|DPADLEFT|")
	end

	arg_4_0.ManagingInterchange = arg_4_1
end

function NVMSubstitutionHud.setClub(arg_5_0, arg_5_1, arg_5_2, arg_5_3)
	arg_5_0.teamTexture = arg_5_3:createDecalIdOrIconTexture(arg_5_2.decalIdOrIcon, arg_5_1:getDecalRender(), arg_5_1:getTextureManager(), "large_mirrored")
	arg_5_0.TeamColour = native.NsColor(arg_5_2.primaryColour.r / 255, arg_5_2.primaryColour.g / 255, arg_5_2.primaryColour.b / 255, 255)
end

function NVMSubstitutionHud.forceClose(arg_6_0)
	arg_6_0.isSubstitutionHudVisible = false
	arg_6_0.IsClosing = false
	arg_6_0.closing = false
	arg_6_0.active = false
	arg_6_0.opened = false
	arg_6_0.closeTimer = 0
	arg_6_0.positionsSelected = false
	arg_6_0.populated = false
	arg_6_0.SmallerHeading = ""
	arg_6_0.ManagingInterchange = false
end

function NVMSubstitutionHud.shouldOpen(arg_7_0)
	return true
end

function NVMSubstitutionHud.isOpened(arg_8_0)
	return arg_8_0.opened
end

function NVMSubstitutionHud.isClosing(arg_9_0)
	return arg_9_0.closing
end

-- nrl-broadcast-scoreboard: the panel stays up while it animates out (IsClosing -> outro storyboard
-- in pareplacementcontrol.xaml); update() hides it once the delay has run. substitution_hud.lua
-- won't reopen it while isClosing(). Keep in step with the outro length in the XAML.
local var_0_outro_time = 0.35

function NVMSubstitutionHud.closeMenu(arg_10_0)
	arg_10_0.closedDelayTimer = arg_10_0.isSubstitutionHudVisible and var_0_outro_time or 0
	arg_10_0.closing = true
	arg_10_0.opened = false
	arg_10_0.IsClosing = true
	arg_10_0.SmallerHeading = ""
end

function NVMSubstitutionHud.openMenu(arg_11_0)
	arg_11_0.active = true
	arg_11_0.opened = true
	arg_11_0.IsClosing = false
	arg_11_0.isSubstitutionHudVisible = true
end

function NVMSubstitutionHud.isActive(arg_12_0)
	return arg_12_0.active
end

-- nrl-broadcast-scoreboard: jersey number for the row's box, read the way playerinfo_hud does
local function var_0_shirt_number(arg_n_0, arg_n_1)
	local var_n_0, var_n_1 = pcall(function()
		local var_n_2 = arg_n_0.lineup

		return var_n_2:getShirtNumber(var_n_2:getIndexForPlayer(arg_n_1) + 1)
	end)

	if var_n_0 and var_n_1 and var_n_1 ~= 0 then
		return var_n_1
	end
end

function NVMSubstitutionHud.populate(arg_13_0, arg_13_1, arg_13_2, arg_13_3, arg_13_4, arg_13_5, arg_13_6)
	arg_13_0.OnFieldPlayers:dispose()
	arg_13_0.BenchPlayers:dispose()

	local var_13_0 = arg_13_3.matchClub
	local var_13_1 = arg_13_1:substitutionOnOrderFitnessesList()
	local var_13_2 = arg_13_1:substitutionOffOrderFitnessesList()

	arg_13_0.ReplacementHeading = native.Localise(arg_13_6)

	for iter_13_0, iter_13_1 in ipairs(var_13_2) do
		local var_13_3 = iter_13_1.id

		if not arg_13_4:queuedSubstitutionsContains(var_13_3) then
			local var_13_4 = arg_13_2:getAssetId(var_13_3):getAssetId()

			ASSERT(var_13_4)

			local var_13_5 = var_13_0:getPlayer(var_13_4)
			local var_13_6 = arg_13_3:getIdentity(var_13_4)

			if native.EAssignedRole.isRoleAForward(iter_13_1.assignedRole) == (arg_13_6 == "Forwards") then
				arg_13_0.OnFieldPlayers:addComponent(arg_13_0:setupPlayer(var_13_5, var_13_6, iter_13_1, var_0_shirt_number(var_13_0, var_13_4)))
			end
		end
	end

	for iter_13_2, iter_13_3 in ipairs(var_13_1) do
		local var_13_7 = iter_13_3.id

		if not arg_13_4:queuedSubstitutionsContains(var_13_7) then
			local var_13_8 = arg_13_2:getAssetId(var_13_7):getAssetId()
			local var_13_9 = var_13_0:getPlayer(var_13_8)
			local var_13_10 = arg_13_3:getIdentity(var_13_8)

			arg_13_0.BenchPlayers:addComponent(arg_13_0:setupPlayer(var_13_9, var_13_10, iter_13_3, var_0_shirt_number(var_13_0, var_13_8)))
		end
	end

	if arg_13_0.BenchPlayers.count == 0 then
		arg_13_0:forceClose()
	end

	arg_13_0.managingOnField = true
	arg_13_0.SelectedOnFieldPlayer = 0
	arg_13_0.SelectedBenchPlayer = 0
end

-- nrl-broadcast-scoreboard: full position under the name. On-field players show the spot they're
-- playing (Winger Left...); bench players are "Substitute" there, so they show their preferred role.
local function var_0_position_name(arg_p_0, arg_p_1)
	if arg_p_1.assignedRole ~= native.EAssignedRole.Substitute then
		return native.Localise("PreferredRole_" .. tostring(arg_p_1.assignedRole))
	end

	local var_p_0, var_p_1 = pcall(function()
		return arg_p_0.primaryRole
	end)

	if var_p_0 and var_p_1 then
		return native.Localise("PreferredRole_" .. tostring(var_p_1))
	end

	return native.Localise("Substitute")
end

function NVMSubstitutionHud.setupPlayer(arg_14_0, arg_14_1, arg_14_2, arg_14_3, arg_14_4)
	local var_14_0 = NVMInterchangePlayer()
	local var_14_1 = math.floor(arg_14_3.stamina * 100)

	var_14_0.IsInjured = arg_14_3.injury ~= native.EInjurySeverity.None
	var_14_0.ShortName = arg_14_2.shortName
	var_14_0.playerId = arg_14_3.id
	var_14_0.Stamina = tostring(var_14_1 .. "%")
	var_14_0.LowStamina = arg_14_3.stamina < 0.2
	var_14_0.Role = native.Localise("PreferredRoleAbbr_" .. tostring(arg_14_3.assignedRole))
	var_14_0.Position = var_0_position_name(arg_14_1, arg_14_3)
	var_14_0.Number = arg_14_4 and tostring(arg_14_4) or ""
	var_14_0.StaminaValue = var_14_1
	var_14_0.StaminaLevel = var_14_1 >= 60 and 0 or var_14_1 >= 40 and 1 or var_14_1 >= 20 and 2 or 3

	return var_14_0
end

function NVMSubstitutionHud.getSelectedPlayerIdentifier(arg_15_0, arg_15_1)
	if arg_15_1 then
		local var_15_0 = arg_15_0.OnFieldPlayers:getComponent(arg_15_0.SelectedOnFieldPlayer + 1)

		return var_15_0 and var_15_0.playerId
	else
		local var_15_1 = arg_15_0.BenchPlayers:getComponent(arg_15_0.SelectedBenchPlayer + 1)

		return var_15_1 and var_15_1.playerId
	end
end

function NVMSubstitutionHud.invalidateSubOnSelection(arg_16_0)
	return
end

function NVMSubstitutionHud.setSelectedIndex(arg_17_0, arg_17_1, arg_17_2)
	if arg_17_0.managingOnField then
		arg_17_0.SelectedOnFieldPlayer = uiutil.wrapIndex(arg_17_0.SelectedOnFieldPlayer + arg_17_1, 0, arg_17_0.OnFieldPlayers.count - 1)
	else
		arg_17_0.SelectedBenchPlayer = uiutil.wrapIndex(arg_17_0.SelectedBenchPlayer + arg_17_1, 0, arg_17_0.BenchPlayers.count - 1)
	end
end

function NVMSubstitutionHud.update(arg_18_0, arg_18_1)
	local var_18_0 = arg_18_0.ManagingInterchange and not arg_18_0.managingOnField or false

	if arg_18_0.ChoosingBench ~= var_18_0 then
		arg_18_0.ChoosingBench = var_18_0
	end

	if arg_18_0.active and arg_18_0.closing then
		arg_18_0.closeTimer = arg_18_0.closeTimer + arg_18_1

		if arg_18_0.closeTimer >= arg_18_0.closedDelayTimer then
			arg_18_0.isSubstitutionHudVisible = false
			arg_18_0.IsClosing = false
			arg_18_0.closing = false
			arg_18_0.active = false
			arg_18_0.opened = false
			arg_18_0.closeTimer = 0
			arg_18_0.stage = 0
			arg_18_0.populated = false
			arg_18_0.positionsSelected = false
			arg_18_0.lookingAtBench = false
		end
	end
end

function NVMSubstitutionHud.dispose(arg_19_0)
	if arg_19_0.teamTexture then
		arg_19_0.teamTexture:unload()

		arg_19_0.teamTexture = nil
	end

	var_0_0.dispose(arg_19_0)
end

function NVMSubstitutionHud.ResetList(arg_20_0)
	arg_20_0.ReplacementsList:dispose()
	arg_20_0.ReplacementsList:clear()
end

function NVMSubstitutionHud.ResetRecommendedList(arg_21_0)
	arg_21_0.RecommendedList:dispose()
	arg_21_0.RecommendedList:clear()
end

function NVMSubstitutionHud.ResetTooltips(arg_22_0)
	arg_22_0.TooltipList:dispose()
	arg_22_0.TooltipList:clear()
end
