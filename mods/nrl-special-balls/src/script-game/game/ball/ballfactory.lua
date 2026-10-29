import("core.assets.assetjoin")

local var_0_0 = "props/balls/models/ball.model"

ASSERT(var_0_0)

local var_0_1 = {
	[native.MatchSettingsBall.nrl] = "ball_nrl_col",
	[native.MatchSettingsBall.nrlw] = "ball_nrlw_col",
	[native.MatchSettingsBall.superleague] = "ball_superleague_col",
	[native.MatchSettingsBall.qldcup] = "ball_qldCup_col",
	[native.MatchSettingsBall.soo1] = "ball_stateOfOrigin_NRL_col",
	[native.MatchSettingsBall.challengecup] = "ball_championship_col",
	[native.MatchSettingsBall.league1] = "ball_leagueOne_col",
	[native.MatchSettingsBall.soo2] = "ball_stateOfOrigin_NRLW_col",
	[native.MatchSettingsBall.vegas] = "ball_lasVegas_col",
	[native.MatchSettingsBall.rlwc26Male] = "ball_rlwc26_male_col",
	[native.MatchSettingsBall.rlwc26Female] = "ball_rlwc26_female_col"
}

-- nrl-special-balls: matchin.setupBall leaves the match's special ball in
-- _G.MOD_SPECIAL_BALL = {ball = MatchSettingsBall, texture = name}; it is
-- only used while the ball being loaded is still that MatchSettingsBall, so a
-- later academy/practice ball of another kind keeps its stock texture.
local function modSpecialBallTexture(arg_0_0)
	local var_0_0 = rawget(_G, "MOD_SPECIAL_BALL")

	if var_0_0 and var_0_0.ball == arg_0_0 then
		return var_0_0.texture
	end
end

function setBallTextures(arg_1_0, arg_1_1)
	arg_1_0:setShaderValues(function(arg_2_0, arg_2_1)
		arg_2_0:setTexture("col_map", arg_1_1)
	end)
end

function loadBallAssets(arg_3_0, arg_3_1, arg_3_2)
	local var_3_0 = arg_3_0:getAssetManager()
	local var_3_1 = arg_3_0:getTextureManager()
	local var_3_2 = "props/balls/textures/"
	local var_3_3 = modSpecialBallTexture(arg_3_2) or var_0_1[arg_3_2] or "ball_generic_col"
	local var_3_4 = var_3_1:load(var_3_2 .. var_3_3 .. ".texture")
	local var_3_5 = native.CModelData.create()

	var_3_5.motionVectors = true
	var_3_5.isShadowAtlas = true

	return native.ModelLoader.load(var_3_0, var_0_0, arg_3_1, var_3_5), var_3_4
end

function loadBall(arg_4_0, arg_4_1, arg_4_2, arg_4_3)
	local var_4_0, var_4_1 = loadBallAssets(arg_4_1, arg_4_2, arg_4_3)

	arg_4_0.model = var_4_0
	arg_4_0.texture = var_4_1

	local var_4_2 = assetjoin.AssetJoin(arg_4_1:getAssetNotifier(), "universe.lua, ballJoin")

	var_4_2:addAsset(var_4_0)
	var_4_2:addAsset(var_4_1)
	var_4_2:fire(function()
		setBallTextures(var_4_0, var_4_1)
	end)
	table.insert(arg_4_0.disposeList, function()
		var_4_0:dispose()
		var_4_1:unload()
	end)
end
