import("core.statemachine.statemachine")
import("app.settings.settings_creditsstate_company_bigant")

local var_0_0 = {
	native.vec3(-1.018, 0, -1.25),
	native.vec3(-1.018, 0, 1.25)
}
local var_0_1 = {
	-0.95,
	-1.85
}

Class("SettingsCreditsState")

function SettingsCreditsState.enter(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7)
	arg_1_5:titleSetSubAreaOfGame(native.Localise("Credits"))
	arg_1_5:setBackgroundVisual("datanofloor")

	local var_1_0 = 0
	local var_1_1 = {
		settings_creditsstate_company_bigant.SettingsCreditsCompanyBigAnt
	}
	local var_1_2 = {
		getNextState = function()
			var_1_0 = var_1_0 + 1

			local var_2_0 = var_1_1[var_1_0]

			return var_2_0 and var_2_0() or nil
		end,
		partyMember = arg_1_6
	}

	arg_1_0.stateMachine = statemachine.StateMachine(arg_1_0.__type)

	arg_1_0.stateMachine:changeState(var_1_2.getNextState(), arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, var_1_2)

	arg_1_0.creditsData = var_1_2

	local var_1_3 = arg_1_5:getRenderer()
end

function SettingsCreditsState.exit(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4)
	arg_3_0.stateMachine:changeState(nil, arg_3_1, arg_3_2, arg_3_3, arg_3_4)

	local var_3_0 = arg_3_4:getRenderer()
end

function SettingsCreditsState.update(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7, arg_4_8)
	local var_4_0 = arg_4_0.creditsData

	if arg_4_0.stateMachine:getCurrentState() then
		arg_4_0.stateMachine:update(arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7, arg_4_8, var_4_0)
	else
		arg_4_6:homeScreenEnter(arg_4_2, arg_4_3, arg_4_5, arg_4_6, arg_4_0.creditsData.partyMember, true)
	end
end

function SettingsCreditsState.render(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4)
	arg_5_0.stateMachine:render(arg_5_1, arg_5_2, arg_5_3, arg_5_4)
end

-- about-rl26-revamped: imported last so SettingsCreditsState is complete; adds the About tile
import("app.settings.settings_creditsstate_company_external")
