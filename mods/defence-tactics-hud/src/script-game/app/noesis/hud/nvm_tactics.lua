import("app.noesis.ns")
import("app.noesis.ns_viewmodel")
import("app.noesis.ns_observablecollection")
import("app.noesis.util.nvm_team")

local var_0_0 = ns_viewmodel.ViewModel
local var_0_1 = ns_observablecollection.ObservableCollection

-- defence-tactics-hud: label text while the defence is on the default.
DefaultDefenceTacticText = "Standard"
-- Debug: log every label change to defence_tactics_debug.txt (game folder).
-- Turn off for release.
DefenceTacticDebugLog = true

-- nrl-broadcast-scoreboard look: tactic name for the header subtitle ("CrossOver" -> "Cross Over")
local function var_0_label(arg_l_0, arg_l_1)
	return arg_l_1 or (tostring(arg_l_0):gsub("(%l)(%u)", "%1 %2"))
end

-- Card set index -> subtitle prefix (1 defence, 2 attack, 3 foresight; see tactics_hud.lua var_0_14)
local var_0_set_names = {
	"Defence",
	"Attack",
	"Foresight"
}

-- Outro length: it plays inside the existing close delay (starts this long before the menu
-- hides), so the menu closes no later than stock. Keep in step with patacticscontrol.xaml.
local var_0_outro_time = 0.15

ns.Class("NVMTacticItem", var_0_0, function(arg_1_0, arg_1_1)
	var_0_0.init(arg_1_0)

	arg_1_0.Key = arg_1_1
end).Bindings = {
	Namespace = "Workspace.ViewModels.HUD.Rugby",
	Properties = {
		Key = ns.String,
		Confirmed = ns.Bool
	}
}
ns.Class("NVMForesightItem", var_0_0, function(arg_2_0, arg_2_1)
	var_0_0.init(arg_2_0)

	arg_2_0.Key = arg_2_1
end).Bindings = {
	Namespace = "Workspace.ViewModels.HUD.Rugby",
	Properties = {
		Key = ns.String
	}
}
ns.Class("NVMTactics", var_0_0, function(arg_3_0)
	var_0_0.init(arg_3_0)

	arg_3_0.cardSets = {}
	arg_3_0.cardSetIndex = 1
	arg_3_0.Items = var_0_1()
	arg_3_0.Header = "Tactics"
	arg_3_0.Index = 1
	arg_3_0.TacticsVisibility = false
	-- defence-tactics-hud: the active (non-default) defence tactic, shown as a
	-- small label above the player plate.
	arg_3_0.DefenceTacticKey = ""
	arg_3_0.DefenceTacticText = DefaultDefenceTacticText
	-- Set by TacticsHud.update: only for human-controlled sides, while defending.
	arg_3_0.DefenceTacticVisible = false
	-- Last-tackle warning (red, flashing): set by TacticsHud.update.
	arg_3_0.DefenceTacticAlert = false
	-- Tactic label (attack or defence, whichever this side is doing): set by TacticsHud.update.
	arg_3_0.AttackTacticKey = ""
	arg_3_0.AttackTacticText = DefaultDefenceTacticText
	arg_3_0.TacticLabelVisible = false
	arg_3_0.TacticLabelAttack = false
	arg_3_0.TacticLabelText = "Defence: " .. DefaultDefenceTacticText
	-- Plate look: Team (set by TacticsHud), subtitle, intro/outro keys.
	arg_3_0.Subtitle = ""
	arg_3_0.RevealKey = 0
	arg_3_0.HideKey = 0
	arg_3_0.outroStarted = false
end).Bindings = {
	Namespace = "Workspace.ViewModels.HUD.Rugby",
	Properties = {
		Team = ns.typeOf(nvm_team.NVMTeam),
		Subtitle = ns.String,
		RevealKey = ns.Int32,
		HideKey = ns.Int32,
		Items = ns.typeOf(var_0_1),
		Header = ns.String,
		Index = ns.Int8,
		TacticsVisibility = ns.Bool,
		DefenceTacticKey = ns.String,
		DefenceTacticText = ns.String,
		DefenceTacticVisible = ns.Bool,
		DefenceTacticAlert = ns.Bool,
		AttackTacticKey = ns.String,
		AttackTacticText = ns.String,
		TacticLabelVisible = ns.Bool,
		TacticLabelAttack = ns.Bool,
		TacticLabelText = ns.String
	}
}

-- defence-tactics-hud: set the defence tactic label (nil = the default
-- defence). Visibility is handled separately (TacticsHud.update).
function NVMTactics.setDefenceTactic(arg_16_0, arg_16_1, arg_16_2)
	if arg_16_1 then
		arg_16_0.DefenceTacticKey = arg_16_1
		arg_16_0.DefenceTacticText = arg_16_2 or arg_16_1
	else
		arg_16_0.DefenceTacticKey = ""
		arg_16_0.DefenceTacticText = DefaultDefenceTacticText
	end

	arg_16_0:refreshTacticLabel()

	if DefenceTacticDebugLog then
		pcall(function()
			local var_16_0 = io.open("defence_tactics_debug.txt", "a")

			if var_16_0 then
				var_16_0:write(os.date("%H:%M:%S"), " setDefenceTactic key=", tostring(arg_16_1), " text=", tostring(arg_16_0.DefenceTacticText), "\n")
				var_16_0:flush()
				var_16_0:close()
			end
		end)
	end
end

-- defence-tactics-hud: the attack play last called from the tactics menu (nil = none). The game
-- has no getter for the selected play, so TacticsHud remembers it and clears it on a turnover.
function NVMTactics.setAttackTactic(arg_17_0, arg_17_1)
	if arg_17_1 then
		arg_17_0.AttackTacticKey = arg_17_1
		arg_17_0.AttackTacticText = var_0_label(arg_17_1)
	else
		arg_17_0.AttackTacticKey = ""
		arg_17_0.AttackTacticText = DefaultDefenceTacticText
	end

	arg_17_0:refreshTacticLabel()
end

-- defence-tactics-hud: label shown/hidden and attack-or-defence, from TacticsHud.update
function NVMTactics.setTacticLabel(arg_18_0, arg_18_1, arg_18_2)
	if arg_18_0.TacticLabelVisible ~= arg_18_1 then
		arg_18_0.TacticLabelVisible = arg_18_1
	end

	if arg_18_0.TacticLabelAttack ~= arg_18_2 then
		arg_18_0.TacticLabelAttack = arg_18_2

		arg_18_0:refreshTacticLabel()
	end
end

function NVMTactics.refreshTacticLabel(arg_19_0)
	local var_19_0

	if arg_19_0.TacticLabelAttack then
		var_19_0 = "Attack: " .. arg_19_0.AttackTacticText
	else
		var_19_0 = "Defence: " .. arg_19_0.DefenceTacticText
	end

	if arg_19_0.TacticLabelText ~= var_19_0 then
		arg_19_0.TacticLabelText = var_19_0
	end
end

function NVMTactics.initialiseCardSets(arg_4_0, arg_4_1)
	for iter_4_0, iter_4_1 in ipairs(arg_4_1) do
		local var_4_0 = var_0_1()

		for iter_4_2, iter_4_3 in ipairs(iter_4_1) do
			local var_4_1

			if iter_4_0 < 3 then
				var_4_1 = NVMTacticItem(iter_4_3.key)
			else
				var_4_1 = NVMForesightItem(iter_4_3.key)
			end

			var_4_1.label = var_0_label(iter_4_3.key, iter_4_3.label)

			var_4_0:addComponent(var_4_1)
		end

		table.insert(arg_4_0.cardSets, var_4_0)
	end
end

function NVMTactics.getSelectedIndex(arg_5_0)
	return arg_5_0.Index + 1
end

function NVMTactics.refreshSubtitle(arg_6_0)
	local var_6_0 = arg_6_0.Items and arg_6_0.Items:getComponent(arg_6_0.Index + 1)
	local var_6_1 = var_0_set_names[arg_6_0.cardSetIndex] or ""
	local var_6_2 = var_6_0 and var_6_0.label

	arg_6_0.Subtitle = var_6_2 and var_6_1 .. "  /  " .. var_6_2 or var_6_1
end

function NVMTactics.setSelectedIndex(arg_6_0, arg_6_1)
	arg_6_0.Index = arg_6_1 - 1

	arg_6_0:refreshSubtitle()
end

function NVMTactics.getCardSetIndex(arg_7_0)
	return arg_7_0.cardSetIndex
end

function NVMTactics.setCardSetIndex(arg_8_0, arg_8_1)
	arg_8_0.cardSetIndex = arg_8_1
	arg_8_0.Items = arg_8_0.cardSets[arg_8_0.cardSetIndex]
	arg_8_0.Index, arg_8_0.Index = arg_8_0.Index, 0

	arg_8_0:refreshSubtitle()
end

function NVMTactics.cycleSelectedIndex(arg_9_0, arg_9_1)
	local var_9_0 = arg_9_0.Index
	local var_9_1 = arg_9_0.cardSets[arg_9_0.cardSetIndex].count
	local var_9_2 = arg_9_1 and var_9_0 - 1 or var_9_0 + 1
	local var_9_3 = 0
	local var_9_4 = var_9_1 - 1

	if var_9_4 < var_9_2 then
		var_9_2 = var_9_4
	elseif var_9_2 < var_9_3 then
		var_9_2 = var_9_3
	end

	arg_9_0.Index = var_9_2

	arg_9_0:refreshSubtitle()
end

function NVMTactics.openMenu(arg_10_0)
	if not arg_10_0.TacticsVisibility or arg_10_0.outroStarted then
		arg_10_0.RevealKey = (arg_10_0.RevealKey + 1) % 1000000
	end

	arg_10_0.outroStarted = false
	arg_10_0.TacticsVisibility = true
end

function NVMTactics.closeMenu(arg_11_0)
	local var_11_0 = arg_11_0.Items:getComponent(arg_11_0.Index + 1)

	if var_11_0 then
		var_11_0.Confirmed = true
		arg_11_0.confirmedItem = var_11_0
	end

	arg_11_0.closeDelay = 0.5
	arg_11_0.closing = true
end

function NVMTactics.forceClose(arg_12_0)
	arg_12_0.TacticsVisibility = false
	arg_12_0.closing = false
	arg_12_0.outroStarted = false

	local var_12_0 = arg_12_0.confirmedItem

	if var_12_0 then
		var_12_0.Confirmed = false
		arg_12_0.confirmedItem = nil
	end
end

function NVMTactics.showSelection(arg_13_0, arg_13_1)
	arg_13_0:openMenu()

	arg_13_0.closeDelay = arg_13_1
	arg_13_0.closing = true
end

function NVMTactics.update(arg_14_0, arg_14_1)
	if arg_14_0.closeDelay then
		arg_14_0.closeDelay = arg_14_0.closeDelay - arg_14_1

		if not arg_14_0.outroStarted and arg_14_0.closeDelay <= var_0_outro_time then
			arg_14_0.outroStarted = true
			arg_14_0.HideKey = (arg_14_0.HideKey + 1) % 1000000
		end

		if arg_14_0.closeDelay <= 0 then
			arg_14_0.closeDelay = nil

			arg_14_0:forceClose()

			return true
		end
	end
end

function NVMTactics.dispose(arg_15_0)
	if arg_15_0.cardSets then
		for iter_15_0, iter_15_1 in ipairs(arg_15_0.cardSets) do
			iter_15_1:dispose()
		end

		arg_15_0.cardSets = nil
	end

	var_0_0.dispose(arg_15_0)
end
