import("app.noesis.ns")
import("app.noesis.ns_viewmodel")
import("uicore.uicolours")

local var_0_0 = ns_viewmodel.ViewModel
local var_0_1 = native.getEnvironment():argExists("LightMode")

ns.Class("NVMBackground", var_0_0, function(arg_1_0)
	var_0_0.init(arg_1_0)

	arg_1_0.HighlightedTileText = " "
	arg_1_0.tempText = ""
	arg_1_0.MenuTextChangeCommand = native.CIsActiveWrapperCommand(native.CLuaDelegateCommand(function()
		return arg_1_0:setTextCommand()
	end))
	arg_1_0.HomeTeamColour = native.NsColor.White()
	arg_1_0.AwayTeamColour = native.NsColor.White()
	arg_1_0.LightMode = var_0_1

	local var_1_0 = uicolours.toUIColour(uicolours.rlgreencol)

	arg_1_0.MainColour = native.NsColor(var_1_0.r, var_1_0.g, var_1_0.b, 255)
end).Bindings = {
	Properties = {
		HighlightedTileText = ns.String,
		MenuTextChangeCommand = native.CIsActiveWrapperCommand.nsType(),
		PlayOutro = ns.Bool,
		VisualStateKey = ns.String,
		HomeTeamColour = ns.Color,
		AwayTeamColour = ns.Color,
		MainColour = ns.Color,
		LightMode = ns.Bool,
		TitleHerbieImage = ns.typeOf(native.CNoesisTextureSource),
		TitleJesseImage = ns.typeOf(native.CNoesisTextureSource),
		TitleSmokeImage = ns.typeOf(native.CNoesisTextureSource),
		TitleSmokeBlueImage = ns.typeOf(native.CNoesisTextureSource),
		TitleBgImage = ns.typeOf(native.CNoesisTextureSource)
	}
}

-- rl26-revamp-branding: start screen art (title_screen.py). Noesis can't
-- load these appended textures from a XAML Source URI, so they're loaded
-- here and bound, like the career club logos. Called by skip-intro's
-- waitforsignin_state.lua.
NVMBackgroundTitleArt = {
	TitleHerbieImage = "noesis/workspace/images/background/rl26revamp_title_herbie.texture",
	TitleJesseImage = "noesis/workspace/images/background/rl26revamp_title_jesse.texture",
	TitleSmokeImage = "noesis/workspace/images/background/rl26revamp_title_smoke.texture",
	TitleSmokeBlueImage = "noesis/workspace/images/background/rl26revamp_title_smoke_blue.texture",
	TitleBgImage = "noesis/workspace/images/background/rl26revamp_title_bg.texture",
}

function NVMBackground.loadTitleArt(arg_ta_0, arg_ta_1)
	if arg_ta_0.titleArtTextures then
		return
	end

	local var_ta_0 = arg_ta_1:getTextureManager()

	arg_ta_0.titleArtTextures = {}

	for iter_ta_0, iter_ta_1 in pairs(NVMBackgroundTitleArt) do
		arg_ta_0.titleArtTextures[iter_ta_0] = var_ta_0:load(iter_ta_1)
	end
end

-- Binds each texture once it has loaded; true when all are bound.
function NVMBackground.updateTitleArt(arg_tu_0)
	local var_tu_0 = arg_tu_0.titleArtTextures

	if not var_tu_0 then
		return false
	end

	local var_tu_1 = true

	for iter_tu_0, iter_tu_1 in pairs(var_tu_0) do
		if iter_tu_1:isLoaded() then
			arg_tu_0[iter_tu_0] = native.CNoesisTextureSource(iter_tu_1)

			iter_tu_1:unload()

			var_tu_0[iter_tu_0] = nil
		else
			var_tu_1 = false
		end
	end

	return var_tu_1
end

function NVMBackground.setVisualKey(arg_3_0, arg_3_1)
	ASSERT(arg_3_1)

	arg_3_0.VisualStateKey = arg_3_1

	if arg_3_1 == "teamselect" then
		arg_3_0.allowThrough = false
		arg_3_0.colours = nil
	end
end

function NVMBackground.setText(arg_4_0, arg_4_1)
	if arg_4_0.HighlightedTileText == "" or arg_4_0.HighlightedTileText == " " then
		arg_4_0.HighlightedTileText = arg_4_1
	else
		arg_4_0.tempText = arg_4_1
		arg_4_0.PlayOutro = true
	end
end

function NVMBackground.setTextCommand(arg_5_0, arg_5_1)
	arg_5_0.PlayOutro = false
	arg_5_0.HighlightedTileText = arg_5_0.tempText
end

function NVMBackground.setBackgroundTeamColours(arg_6_0, arg_6_1)
	if not arg_6_0.colours then
		arg_6_0.colours = arg_6_1
		arg_6_0.allowThrough = true
	end

	for iter_6_0, iter_6_1 in pairs(arg_6_1) do
		if arg_6_0.colours[iter_6_0].clubId ~= iter_6_1.clubId or arg_6_0.allowThrough then
			local var_6_0 = iter_6_1.colour

			if iter_6_0 == "home" then
				arg_6_0.HomeTeamColour = native.NsColor(var_6_0.r, var_6_0.g, var_6_0.b, 255)
			else
				arg_6_0.AwayTeamColour = native.NsColor(var_6_0.r, var_6_0.g, var_6_0.b, 255)
			end
		end
	end

	arg_6_0.allowThrough = false
	arg_6_0.colours = arg_6_1
end

function NVMBackground.setBackgroundColour(arg_7_0, arg_7_1)
	arg_7_0.MainColour = native.NsColor(arg_7_1.r, arg_7_1.g, arg_7_1.b, 255)
end
