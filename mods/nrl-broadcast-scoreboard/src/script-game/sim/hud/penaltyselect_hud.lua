import("app.noesis.hud.nvm_penaltyHud")
import("game.helpers.colour_helper")
import("sim.hud.hud_helper")
Class("PenaltySelectHud", function(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7)
	local var_1_0 = arg_1_7.featureStack
	local var_1_1 = nvm_penaltyHud.NVMPenaltyHud(arg_1_7)

	arg_1_0.enabled = false
	arg_1_0.hudFeatureStack = var_1_0
	arg_1_0.penaltyHud = var_1_1

	var_1_0:registerViewModel(hud_helper.HUD_IDENTIFIERS.gameplay, "PenaltySelect", var_1_1)
	var_1_0:register("penaltySelect", arg_1_0, function(arg_2_0)
		arg_1_0:show(arg_2_0)
	end, function()
		arg_1_0:hide()
	end)
end)

function PenaltySelectHud.registerWithMatchSim(arg_4_0, arg_4_1)
	return
end

function PenaltySelectHud.dispose(arg_5_0, arg_5_1)
	arg_5_0.penaltyHud:dispose()
	arg_5_0.hudFeatureStack:unregisterHUDElement(hud_helper.HUD_IDENTIFIERS.gameplay, arg_5_0.penaltyHud)
end

function PenaltySelectHud.update(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8, arg_6_9, arg_6_10, arg_6_11, arg_6_12)
	-- nrl-broadcast-scoreboard: pass dt so the bar can finish its outro before hiding
	arg_6_0.penaltyHud:update(arg_6_8)
end

function PenaltySelectHud.render(arg_7_0, arg_7_1, arg_7_2, arg_7_3)
	return
end

function PenaltySelectHud.show(arg_8_0, arg_8_1)
	arg_8_0.enabled = true

	ASSERT(arg_8_1)
	arg_8_0:setup(arg_8_1)
end

function PenaltySelectHud.setup(arg_9_0, arg_9_1)
	ASSERT(arg_9_1.allowKick ~= nil)
	ASSERT(arg_9_1.sideAwardedPenalty ~= nil)
	ASSERT(arg_9_1.gamer)

	local var_9_0 = arg_9_1.gamer:getGamerId()
	local var_9_1 = colour_helper.getPlayerColourIndex(var_9_0.participantId, var_9_0.localGamerIndex)

	arg_9_0.penaltyHud:setPenaltyPrompt()
	arg_9_0.penaltyHud:show()
	arg_9_0.penaltyHud:setAllowKick(arg_9_1.allowKick)
	arg_9_0.penaltyHud:setAllowScrum(arg_9_1.allowScrum)
	arg_9_0.penaltyHud:setPlayerColour(var_9_1)
	arg_9_0.penaltyHud:setClub(arg_9_1.sideAwardedPenalty)
end

-- scrum-feed-control (rules/scrum/scrum_setup_rulestate.lua): the scrum position / feed prompt
-- on the penalty bar. Shown directly, not through the HUD feature stack.
function PenaltySelectHud.showScrumPrompt(arg_9_0, arg_9_1)
	arg_9_0.enabled = true
	arg_9_0.scrumPrompt = true

	arg_9_0.penaltyHud:setScrumPrompt(arg_9_1)

	if arg_9_1.side then
		arg_9_0.penaltyHud:setClub(arg_9_1.side)
	end

	arg_9_0.penaltyHud:show()
end

function PenaltySelectHud.setScrumTitle(arg_9_0, arg_9_1, arg_9_2)
	if arg_9_0.scrumPrompt then
		arg_9_0.penaltyHud:setScrumTitle(arg_9_1, arg_9_2)
	end
end

function PenaltySelectHud.setScrumOptionText(arg_9_0, arg_9_1, arg_9_2)
	if arg_9_0.scrumPrompt then
		arg_9_0.penaltyHud:setScrumOptionText(arg_9_1, arg_9_2)
	end
end

function PenaltySelectHud.hideScrumPrompt(arg_9_0)
	if arg_9_0.scrumPrompt then
		arg_9_0.scrumPrompt = false
		arg_9_0.enabled = false

		arg_9_0.penaltyHud:hide()
	end
end

function PenaltySelectHud.hide(arg_10_0)
	-- scrum-feed-control: the feature stack disables every feature outside its top frame
	-- (processTopFrame) whenever a frame is pushed or popped, which would take the scrum prompt
	-- straight back down. Only hideScrumPrompt closes it.
	if arg_10_0.scrumPrompt then
		return
	end

	arg_10_0.enabled = false

	arg_10_0.penaltyHud:hide()
end
