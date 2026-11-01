import("app.noesis.ns")
import("app.noesis.ns_viewmodel")
import("app.noesis.ns_observablecollection")
import("app.noesis.util.nvm_team")
import("sim.hud.hud_helper")

local var_0_0 = ns_viewmodel.ViewModel
local var_0_1 = ns_observablecollection.ObservableCollection

ns.Class("NVMPenaltyHud", var_0_0, function(arg_1_0, arg_1_1)
	var_0_0.init(arg_1_0)

	arg_1_0.ShowPenaltyGoal = true
	arg_1_0.PartyMemberColour = native.NsColor(255, 0, 255, 255)
	arg_1_0.TeamColour = native.NsColor(255, 0, 255, 255)
	arg_1_0.playerColours = {
		native.NsColor(216, 68, 68, 255),
		native.NsColor(63, 123, 196, 255),
		native.NsColor(255, 208, 38, 255),
		native.NsColor(155, 40, 215, 255)
	}
	arg_1_0.HomeTeam = hud_helper.getSideHudNVMTeam(arg_1_1, hud_helper.HOME_SIDE)
	arg_1_0.AwayTeam = hud_helper.getSideHudNVMTeam(arg_1_1, hud_helper.AWAY_SIDE)
	arg_1_0.sides = {
		arg_1_0.HomeTeam,
		arg_1_0.AwayTeam
	}

	arg_1_0:setClub(1)

	arg_1_0.RevealKey = 0
	arg_1_0.HideKey = 0
	arg_1_0.closeTimer = nil
	arg_1_0.IsScrumPrompt = false
	arg_1_0.ShowPenaltyScrum = false
	arg_1_0.ScrumTitle = "SCRUM"
	arg_1_0.ScrumUrgent = false

	for iter_1_0 = 1, 3 do
		arg_1_0["ScrumOpt" .. iter_1_0 .. "Glyph"] = ""
		arg_1_0["ScrumOpt" .. iter_1_0 .. "Text"] = ""
		arg_1_0["ScrumOpt" .. iter_1_0 .. "Visible"] = false
	end
end).Bindings = {
	Properties = {
		IsScrumPrompt = ns.Bool,
		ShowPenaltyScrum = ns.Bool,
		ScrumTitle = ns.String,
		ScrumUrgent = ns.Bool,
		ScrumOpt1Glyph = ns.String,
		ScrumOpt1Text = ns.String,
		ScrumOpt1Visible = ns.Bool,
		ScrumOpt2Glyph = ns.String,
		ScrumOpt2Text = ns.String,
		ScrumOpt2Visible = ns.Bool,
		ScrumOpt3Glyph = ns.String,
		ScrumOpt3Text = ns.String,
		ScrumOpt3Visible = ns.Bool,
		RevealKey = ns.Int32,
		HideKey = ns.Int32,
		HomeTeam = ns.typeOf(nvm_team.NVMTeam),
		AwayTeam = ns.typeOf(nvm_team.NVMTeam),
		ClubName = ns.String,
		TeamLogo = ns.typeOf(native.CNoesisTextureSource),
		TeamColour = ns.Color,
		PartyMemberColour = ns.Color,
		ShowPenaltyGoal = ns.Bool,
		isVisible = ns.Bool
	}
}

function NVMPenaltyHud.setAllowKick(arg_2_0, arg_2_1)
	arg_2_0.ShowPenaltyGoal = arg_2_1
end

-- scrum-feed-control: the same bar is the scrum prompt (position choice / feed).
-- papenaltycontrol.xaml swaps the title and the three option slots while IsScrumPrompt is set.
-- arg_2_1: { title = "SCRUM", options = { { glyph = "|CROSS|", text = "FEED" }, ... } } (1-3)
function NVMPenaltyHud.setScrumPrompt(arg_2_0, arg_2_1)
	arg_2_0.ScrumTitle = arg_2_1.title or "SCRUM"

	for iter_2_0 = 1, 3 do
		local var_2_0 = arg_2_1.options and arg_2_1.options[iter_2_0]

		arg_2_0["ScrumOpt" .. iter_2_0 .. "Glyph"] = var_2_0 and var_2_0.glyph or ""
		arg_2_0["ScrumOpt" .. iter_2_0 .. "Text"] = var_2_0 and var_2_0.text or ""
		arg_2_0["ScrumOpt" .. iter_2_0 .. "Visible"] = var_2_0 ~= nil
	end

	arg_2_0.IsScrumPrompt = true
	arg_2_0.ShowPenaltyScrum = false
end

-- scrum-feed-control: an option's label while the prompt is up (the set play on the feed clock).
function NVMPenaltyHud.setScrumOptionText(arg_2_0, arg_2_1, arg_2_2)
	arg_2_0["ScrumOpt" .. arg_2_1 .. "Text"] = arg_2_2
end

-- scrum-feed-control: SCRUM (pack again) on the penalty choice after offside off a scrum.
function NVMPenaltyHud.setAllowScrum(arg_2_0, arg_2_1)
	arg_2_0.ShowPenaltyScrum = arg_2_1 == true
end

-- The countdown lives in the title ("SCRUM 4"); arg_2_2 turns it red. Only assigns on change.
function NVMPenaltyHud.setScrumTitle(arg_2_0, arg_2_1, arg_2_2)
	if arg_2_0.ScrumTitle ~= arg_2_1 then
		arg_2_0.ScrumTitle = arg_2_1
	end

	if arg_2_0.ScrumUrgent ~= (arg_2_2 == true) then
		arg_2_0.ScrumUrgent = arg_2_2 == true
	end
end

-- Kept through hide() so the outro still shows the scrum labels.
function NVMPenaltyHud.setPenaltyPrompt(arg_2_0)
	arg_2_0.IsScrumPrompt = false
	arg_2_0.ScrumUrgent = false
end

function NVMPenaltyHud.setPlayerColour(arg_3_0, arg_3_1)
	arg_3_0.PartyMemberColour = arg_3_0.playerColours[arg_3_1]
end

function NVMPenaltyHud.setClub(arg_4_0, arg_4_1)
	local var_4_0 = arg_4_0.sides[arg_4_1]

	arg_4_0.TeamLogo = var_4_0.TeamLogo
	arg_4_0.TeamColour = var_4_0.PrimaryColour
end

-- nrl-broadcast-scoreboard: RevealKey / HideKey drive the intro and outro storyboards in
-- papenaltycontrol.xaml. hide() keeps the bar up until the outro has played (update() counts it
-- down); keep var_0_outro_time in step with the XAML.
local var_0_outro_time = 0.35

function NVMPenaltyHud.show(arg_5_0)
	if not arg_5_0.isVisible or arg_5_0.closeTimer then
		arg_5_0.RevealKey = (arg_5_0.RevealKey + 1) % 1000000
	end

	arg_5_0.closeTimer = nil
	arg_5_0.isVisible = true
end

function NVMPenaltyHud.hide(arg_6_0)
	if arg_6_0.isVisible and not arg_6_0.closeTimer then
		arg_6_0.closeTimer = var_0_outro_time
		arg_6_0.HideKey = (arg_6_0.HideKey + 1) % 1000000
	end
end

function NVMPenaltyHud.update(arg_7_0, arg_7_1)
	for iter_7_0, iter_7_1 in ipairs(arg_7_0.sides) do
		iter_7_1:update()
	end

	if arg_7_0.closeTimer then
		arg_7_0.closeTimer = arg_7_0.closeTimer - (arg_7_1 or 1 / 60)

		if arg_7_0.closeTimer <= 0 then
			arg_7_0.closeTimer = nil
			arg_7_0.isVisible = false
		end
	end
end

function NVMPenaltyHud.dispose(arg_8_0)
	var_0_0.dispose(arg_8_0)
end
