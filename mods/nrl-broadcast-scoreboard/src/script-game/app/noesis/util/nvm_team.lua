import("app.noesis.ns")
import("app.noesis.ns_viewmodel")
import("app.noesis.ns_observablecollection")

local var_0_0 = ns_viewmodel.ViewModel
local var_0_1 = ns_observablecollection.ObservableCollection
local var_0_2 = native.NsColor

ns.Class("NVMPenaltyCard", var_0_0, function(arg_1_0)
	var_0_0.init(arg_1_0)
end).Bindings = {
	Properties = {}
}
ns.Class("NVMTeam", var_0_0, function(arg_2_0)
	var_0_0.init(arg_2_0)

	arg_2_0.FullName = ""
	arg_2_0.ShortName = ""
	arg_2_0.HudName = ""
	arg_2_0.ScoreDebug = ""
	arg_2_0.HudTextColour = var_0_2(242.25, 242.25, 242.25, 255)
	arg_2_0.PrimaryColour = var_0_2(76.5, 0, 76.5, 255)
	arg_2_0.SecondaryColour = var_0_2(63.75, 0, 63.75, 255)
	arg_2_0.YellowCards = var_0_1()
	arg_2_0.RedCards = var_0_1()
end).Bindings = {
	Properties = {
		FullName = ns.String,
		ShortName = ns.String,
		HudName = ns.String,
		HudTextColour = ns.Color,
		PrimaryColour = ns.Color,
		SecondaryColour = ns.Color,
		TeamLogo = ns.typeOf(native.CNoesisTextureSource),
		ScoreLogo = ns.typeOf(native.CNoesisTextureSource),
		ScoreDebug = ns.String,
		YellowCards = ns.typeOf(var_0_1),
		RedCards = ns.typeOf(var_0_1)
	}
}

function NVMTeam.update(arg_3_0)
	if arg_3_0.teamTexture and arg_3_0.teamTexture:isLoaded() then
		arg_3_0.TeamLogo = native.CNoesisTextureSource(arg_3_0.teamTexture)

		arg_3_0.teamTexture:unload()

		arg_3_0.teamTexture = nil
	end

	-- nrl-broadcast-scoreboard: hud_score crest for the score card. hud.lua fills
	-- scoreTextures with one texture per load method; the first to load wins.
	if arg_3_0.scoreTextures then
		local var_3_states = {}
		local var_3_winner

		for iter_3_0, iter_3_1 in ipairs(arg_3_0.scoreTextures) do
			local var_3_ok, var_3_loaded = pcall(function()
				return iter_3_1.texture:isLoaded()
			end)

			var_3_states[#var_3_states + 1] = iter_3_1.label .. "=" .. (var_3_ok and tostring(var_3_loaded) or "err")

			if var_3_ok and var_3_loaded and not var_3_winner then
				var_3_winner = iter_3_1
			end
		end

		if var_3_winner then
			local var_3_ok, var_3_source = pcall(function()
				return native.CNoesisTextureSource(var_3_winner.texture)
			end)

			if var_3_ok then
				arg_3_0.ScoreLogo = var_3_source
			else
				arg_3_0:setScoreDebug(" | src err: " .. tostring(var_3_source))
			end

			arg_3_0:releaseScoreTextures()
		else
			arg_3_0:setScoreDebug(" | " .. table.concat(var_3_states, " "))
		end
	end
end

function NVMTeam.setScoreDebug(arg_3_0, arg_3_1)
	local var_3_text = (arg_3_0.scoreDebugBase or "") .. arg_3_1

	if arg_3_0.ScoreDebug ~= var_3_text then
		arg_3_0.ScoreDebug = var_3_text
	end
end

function NVMTeam.releaseScoreTextures(arg_3_0)
	for iter_3_0, iter_3_1 in ipairs(arg_3_0.scoreTextures or {}) do
		pcall(function()
			iter_3_1.texture:unload()
		end)
	end

	arg_3_0.scoreTextures = nil
end

function NVMTeam.dispose(arg_4_0, arg_4_1)
	if arg_4_1 then
		if arg_4_0.teamTexture then
			arg_4_0.teamTexture:unload()

			arg_4_0.teamTexture = nil
		end

		arg_4_0:releaseScoreTextures()

		var_0_0.dispose(arg_4_0)
	end
end

function NVMTeam.populateWithMatchClubAndTeamConfig(arg_5_0, arg_5_1, arg_5_2)
	arg_5_0.HudName = arg_5_1.hudName

	local var_5_0 = arg_5_1.primaryColour
	local var_5_1 = arg_5_1.secondaryColour
	local var_5_2 = arg_5_1.identity

	arg_5_0.PrimaryColour = native.NsColor(var_5_0.r, var_5_0.g, var_5_0.b, 255)
	arg_5_0.SecondaryColour = native.NsColor(var_5_1.r, var_5_1.g, var_5_1.b, 255)
	arg_5_0.FullName = var_5_2.fullName
	arg_5_0.ShortName = var_5_2.nickname

	local var_5_3 = var_5_2.hudTextRGBColour

	arg_5_0.HudTextColour = native.NsColor(var_5_3.r, var_5_3.g, var_5_3.b, 255)
	arg_5_0.teamTexture = arg_5_2
end

function NVMTeam.addRedCard(arg_6_0)
	local var_6_0 = NVMPenaltyCard()

	arg_6_0.RedCards:addComponent(var_6_0)
end

function NVMTeam.addYellowCard(arg_7_0)
	local var_7_0 = NVMPenaltyCard()

	arg_7_0.YellowCards:addComponent(var_7_0)
end

function NVMTeam.removeYellowCard(arg_8_0)
	local var_8_0 = arg_8_0.YellowCards

	if var_8_0.count > 0 then
		local var_8_1 = arg_8_0.YellowCards:getComponent(var_8_0.count)

		var_8_1:dispose()
		arg_8_0.YellowCards:removeItem(var_8_1)
	end
end
