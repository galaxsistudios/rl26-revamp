import("app.noesis.ns")
import("app.noesis.ns_viewmodel")
import("app.noesis.ns_observablecollection")
import("app.noesis.util.nvm_team")
import("sim.hud.hud_helper")

local var_0_0 = ns_viewmodel.ViewModel
local var_0_1 = ns_observablecollection.ObservableCollection

ns.Class("NVMPlayerPlate", var_0_0, function(arg_1_0, arg_1_1)
	var_0_0.init(arg_1_0)

	arg_1_0.HomeTeam = hud_helper.getSideHudNVMTeam(arg_1_1, hud_helper.HOME_SIDE)
	arg_1_0.AwayTeam = hud_helper.getSideHudNVMTeam(arg_1_1, hud_helper.AWAY_SIDE)
	arg_1_0.PlayerNumber = "XX"
	arg_1_0.PlayerName = "I"
	arg_1_0.IsVisible = false
	arg_1_0.Stamina = 45
	arg_1_0.PlayerPosition = ""
	arg_1_0.RevealKey = 0
	arg_1_0.SwitchKey = 0
	arg_1_0.HideKey = 0
	arg_1_0.StaminaLevel = 0
	arg_1_0.HasDiscipline = false
	arg_1_0.Discipline = 100
	arg_1_0.DisciplineFill = 34
	arg_1_0.DisciplineLevel = 0
	arg_1_0.IsRattled = false
	arg_1_0.wantShown = false
	arg_1_0.hideTimer = nil
	arg_1_0.revealedPlayer = nil
end).Bindings = {
	Properties = {
		IsOnBottom = ns.Bool,
		PlayerNumber = ns.String,
		PlayerName = ns.String,
		PlayerPosition = ns.String,
		RevealKey = ns.Int32,
		SwitchKey = ns.Int32,
		HideKey = ns.Int32,
		StaminaLevel = ns.Int32,
		HasDiscipline = ns.Bool,
		Discipline = ns.Int8,
		DisciplineFill = ns.Single,
		DisciplineLevel = ns.Int32,
		IsRattled = ns.Bool,
		Team = ns.typeOf(nvm_team.NVMTeam),
		Stamina = ns.Int8,
		IsVisible = ns.Bool
	}
}

function NVMPlayerPlate.update(arg_2_0)
	return
end

function NVMPlayerPlate.dispose(arg_3_0)
	var_0_0.dispose(arg_3_0)
end

-- nrl-broadcast-scoreboard: StaminaLevel picks the underline colour in PlayerPlateTemplate
-- (0 green, 1 yellow, 2 orange, 3 red).
local var_0_stamina_levels = {
	60,
	40,
	20
}

function NVMPlayerPlate.updateStamina(arg_4_0, arg_4_1)
	arg_4_0.Stamina = arg_4_1 * 100

	local var_4_0 = #var_0_stamina_levels

	for iter_4_0, iter_4_1 in ipairs(var_0_stamina_levels) do
		if arg_4_1 * 100 >= iter_4_1 then
			var_4_0 = iter_4_0 - 1

			break
		end
	end

	if arg_4_0.StaminaLevel ~= var_4_0 then
		arg_4_0.StaminaLevel = var_4_0
	end
end

-- discipline-meter (mods/discipline-meter): vertical bar on the right of the card. arg_4_1 =
-- discipline 0..1 or nil (no meter / no record yet, bar hidden), arg_4_2 = rattled. Levels use the
-- stamina bands. The fill is a height in px: keep in step with the 34px track in
-- PlayerPlateTemplate.
local var_0_discipline_bar_height = 34

function NVMPlayerPlate.updateDiscipline(arg_4_0, arg_4_1, arg_4_2)
	local var_4_0 = arg_4_1 ~= nil

	if arg_4_0.HasDiscipline ~= var_4_0 then
		arg_4_0.HasDiscipline = var_4_0
	end

	if not var_4_0 then
		return
	end

	local var_4_1 = math.floor(arg_4_1 * 100 + 0.5)

	if arg_4_0.Discipline ~= var_4_1 then
		arg_4_0.Discipline = var_4_1
		arg_4_0.DisciplineFill = var_0_discipline_bar_height * var_4_1 / 100
	end

	local var_4_2 = #var_0_stamina_levels

	for iter_4_0, iter_4_1 in ipairs(var_0_stamina_levels) do
		if var_4_1 >= iter_4_1 then
			var_4_2 = iter_4_0 - 1

			break
		end
	end

	if arg_4_0.DisciplineLevel ~= var_4_2 then
		arg_4_0.DisciplineLevel = var_4_2
	end

	local var_4_3 = arg_4_2 and true or false

	if arg_4_0.IsRattled ~= var_4_3 then
		arg_4_0.IsRattled = var_4_3
	end
end

function NVMPlayerPlate.setPlayerName(arg_5_0, arg_5_1)
	arg_5_0.PlayerName = arg_5_1
end

function NVMPlayerPlate.setPlayerPosition(arg_5_0, arg_5_1)
	if arg_5_0.PlayerPosition ~= arg_5_1 then
		arg_5_0.PlayerPosition = arg_5_1
	end
end

-- nrl-broadcast-scoreboard: these keys drive the plate's animations (PropertyChangedTriggers in
-- PlayerPlateTemplate). RevealKey = the plate reappears (full intro), SwitchKey = a different
-- player on a plate that is already showing (name/position/stamina only).
function NVMPlayerPlate.refreshReveal(arg_5_0, arg_5_1)
	if arg_5_0.revealedPlayer == arg_5_1 then
		return
	end

	if arg_5_0.revealedPlayer == nil then
		arg_5_0.RevealKey = (arg_5_0.RevealKey + 1) % 1000000
	else
		arg_5_0.SwitchKey = (arg_5_0.SwitchKey + 1) % 1000000
	end

	arg_5_0.revealedPlayer = arg_5_1
end

function NVMPlayerPlate.resetReveal(arg_5_0)
	arg_5_0.revealedPlayer = nil
end

-- nrl-broadcast-scoreboard: playerinfo_hud requests visibility here instead of writing IsVisible.
-- tick() applies it once a frame: hiding bumps HideKey (outro storyboard) and keeps the plate up
-- until the outro has played. Matches the outro length in PlayerPlateTemplate.
local var_0_outro_time = 0.45

function NVMPlayerPlate.setShown(arg_5_0, arg_5_1)
	arg_5_0.wantShown = arg_5_1
end

function NVMPlayerPlate.tick(arg_5_0, arg_5_1)
	if arg_5_0.wantShown then
		arg_5_0.hideTimer = nil

		if not arg_5_0.IsVisible then
			arg_5_0.IsVisible = true
		end
	elseif arg_5_0.hideTimer then
		arg_5_0.hideTimer = arg_5_0.hideTimer - arg_5_1

		if arg_5_0.hideTimer <= 0 then
			arg_5_0.hideTimer = nil
			arg_5_0.IsVisible = false
		end
	elseif arg_5_0.IsVisible then
		arg_5_0.hideTimer = var_0_outro_time
		arg_5_0.HideKey = (arg_5_0.HideKey + 1) % 1000000

		arg_5_0:resetReveal()
	end
end

function NVMPlayerPlate.setTeamName(arg_6_0, arg_6_1)
	arg_6_0.TeamName = arg_6_1
end

function NVMPlayerPlate.setTeamColour(arg_7_0, arg_7_1)
	arg_7_0.TeamColor = arg_7_1
end

function NVMPlayerPlate.setBottomAllignment(arg_8_0, arg_8_1)
	arg_8_0.IsOnBottom = arg_8_1
end

function NVMPlayerPlate.setPlayerNumber(arg_9_0, arg_9_1)
	arg_9_0.PlayerNumber = arg_9_1
end

function NVMPlayerPlate.setGamer(arg_10_0, arg_10_1)
	arg_10_0.gamer = arg_10_1
end

function NVMPlayerPlate.setSide(arg_11_0, arg_11_1)
	arg_11_0.Team = nil

	if arg_11_1 == 1 then
		arg_11_0.Team = arg_11_0.HomeTeam
	else
		arg_11_0.Team = arg_11_0.AwayTeam
	end
end

function NVMPlayerPlate.getIsAIHud(arg_12_0)
	return arg_12_0.gamer == 0
end
