import("app.noesis.ns")
import("app.noesis.ns_viewmodel")
import("app.noesis.ns_observablecollection")

local var_0_0 = ns_viewmodel.ViewModel
local var_0_1 = ns_observablecollection.ObservableCollection

-- defence-tactics-hud: label text while the defence is on the default.
DefaultDefenceTacticText = "Standard"
-- Debug: log every label change to defence_tactics_debug.txt (game folder).
-- Turn off for release.
DefenceTacticDebugLog = true

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
end).Bindings = {
	Namespace = "Workspace.ViewModels.HUD.Rugby",
	Properties = {
		Items = ns.typeOf(var_0_1),
		Header = ns.String,
		Index = ns.Int8,
		TacticsVisibility = ns.Bool,
		DefenceTacticKey = ns.String,
		DefenceTacticText = ns.String,
		DefenceTacticVisible = ns.Bool,
		DefenceTacticAlert = ns.Bool
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

			var_4_0:addComponent(var_4_1)
		end

		table.insert(arg_4_0.cardSets, var_4_0)
	end
end

function NVMTactics.getSelectedIndex(arg_5_0)
	return arg_5_0.Index + 1
end

function NVMTactics.setSelectedIndex(arg_6_0, arg_6_1)
	arg_6_0.Index = arg_6_1 - 1
end

function NVMTactics.getCardSetIndex(arg_7_0)
	return arg_7_0.cardSetIndex
end

function NVMTactics.setCardSetIndex(arg_8_0, arg_8_1)
	arg_8_0.cardSetIndex = arg_8_1
	arg_8_0.Items = arg_8_0.cardSets[arg_8_0.cardSetIndex]
	arg_8_0.Index, arg_8_0.Index = arg_8_0.Index, 0
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
end

function NVMTactics.openMenu(arg_10_0)
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
