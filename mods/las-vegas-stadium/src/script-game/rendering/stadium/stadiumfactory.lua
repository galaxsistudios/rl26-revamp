import("rendering.props.fieldposts")
import("rendering.stadium.stadiummodel")
import("rendering.stadium.stadiumgrass")
import("core.assets.assetjoin")

function loadStadiumModel(arg_1_0, arg_1_1, arg_1_2)
	local var_1_0 = stadiummodel.StadiumModel()

	var_1_0:loadFrom(arg_1_0, arg_1_1, arg_1_2)

	return var_1_0
end

-- Las Vegas grass layers (appended by las-vegas-stadium/install.py):
--   sponsor_field_lasvegasingoal      black in-goals, Allegiant Stadium only
-- The "Rugby League Las Vegas" field markings themselves are a round in
-- nrl-field-sponsor-markings' config (rounds/lasvegas.json, on the otherwise
-- unused NRL_Season_Wednesday value); Allegiant forces that round below.
-- Not for stadium-creator grounds (their own line models / sizes).
--
-- The in-goal is drawn in the sponsor decal pass. It sat coplanar with the
-- sponsor models' in-goal banners there and the two flickered, so its quads
-- are 3 mm lower (install.py IN_GOAL_Y) and the banners win the depth test.
-- (The field-lines pass, tried first, doesn't draw it at all.) It uses a
-- solid white detail map (the stock one is grass noise that keeps sponsor
-- decals mostly see-through) and is drawn twice, so the black covers ~96%
-- instead of tinting the grass.
local var_0_VegasGround = "lasVegasStadium"
local var_0_VegasDetailTexture = "fields/textures/sponsors/sponsor_alphaDetail_col.texture"
local var_0_VegasSolidDetailTexture = "fields/textures/sponsors/sponsor_alphadetail_solid_col.texture"
local var_0_VegasSponsorLists = {
	native.CRenderListType.fieldSponsorDecals,
	native.CRenderListType.fieldSponsorDecalsPIP,
	native.CRenderListType.undrawFieldDecals,
	native.CRenderListType.undrawFieldDecalsPIP
}

local function var_0_vegasLayers(arg_0_0, arg_0_1, arg_0_2, arg_0_3)
	local var_0_0 = {}

	if arg_0_3 ~= nil then
		return var_0_0
	end

	local var_0_1 = arg_0_2.fieldFlipped and "_flipped" or ""

	if arg_0_1.ground == var_0_VegasGround then
		table.insert(var_0_0, {
			copies = 2,
			name = "sponsor_field_lasvegasingoal" .. var_0_1,
			lists = var_0_VegasSponsorLists,
			detail = var_0_VegasSolidDetailTexture
		})
	end

	return var_0_0
end

local function var_0_loadVegasLayers(arg_0_0, arg_0_1, arg_0_2)
	for iter_0_0, iter_0_1 in ipairs(arg_0_2) do
		iter_0_1.models = {}

		for iter_0_2 = 1, iter_0_1.copies do
			local var_0_0 = native.ModelLoader.load(arg_0_0:getAssetManager(), "fields/default/" .. iter_0_1.name .. ".model", arg_0_1)

			var_0_0.visible = true

			for iter_0_3, iter_0_4 in ipairs(iter_0_1.lists) do
				var_0_0:addToRenderList(iter_0_4)
			end

			table.insert(iter_0_1.models, var_0_0)
		end
	end

	return arg_0_2
end

-- Hands the layers to the grass so its dispose() frees them (it disposes
-- every model in fieldmarkings_linesList and unloads every texture in
-- fieldSponsorTextures), and gives them their detail map once loaded, as
-- stadiumgrass.lua does for its own sponsor model.
local function var_0_attachVegasLayers(arg_0_0, arg_0_1, arg_0_2)
	if #arg_0_2 == 0 then
		return
	end

	arg_0_1.fieldSponsorTextures = arg_0_1.fieldSponsorTextures or {}

	local var_0_0 = arg_0_1.fieldSponsorTextures
	local var_0_1 = assetjoin.AssetJoin(arg_0_0:getAssetNotifier(), "las vegas field")

	for iter_0_0, iter_0_1 in ipairs(arg_0_2) do
		local var_0_2 = iter_0_1.detail or var_0_VegasDetailTexture

		if var_0_0[var_0_2] == nil then
			var_0_0[var_0_2] = var_0_2 == var_0_VegasDetailTexture and var_0_0.fieldSponsorDetailTexture or arg_0_0:getTextureManager():load(var_0_2)
		end

		iter_0_1.detailTexture = var_0_0[var_0_2]

		var_0_1:addAsset(iter_0_1.detailTexture)

		for iter_0_2, iter_0_3 in ipairs(iter_0_1.models) do
			table.insert(arg_0_1.fieldmarkings_linesList, iter_0_3)
			var_0_1:addAsset(iter_0_3)
		end
	end

	-- The grass already unloads its own detail texture; don't unload it twice.
	if var_0_0.fieldSponsorDetailTexture ~= nil and var_0_0[var_0_VegasDetailTexture] == var_0_0.fieldSponsorDetailTexture then
		var_0_0[var_0_VegasDetailTexture] = nil
	end

	var_0_1:fire(function()
		for iter_0_4, iter_0_5 in ipairs(arg_0_2) do
			for iter_0_6, iter_0_7 in ipairs(iter_0_5.models) do
				iter_0_7:setShaderValues(function(arg_1_0, arg_1_1)
					arg_1_0:setTexture("detail_map", iter_0_5.detailTexture)
				end)
			end
		end

	end)
end

function loadStadiumGrass(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7)
	local var_2_0 = stadiumgrass.StadiumGrass()

	local var_2_1 = var_0_loadVegasLayers(arg_2_0, arg_2_1, var_0_vegasLayers(arg_2_2, arg_2_3, arg_2_4, arg_2_6))

	-- Allegiant always gets the Las Vegas markings, whatever was picked. That
	-- round has no in-goal panels, so nothing draws over the black in-goals.
	if arg_2_3.ground == var_0_VegasGround and arg_2_6 == nil then
		var_2_0.fieldRoundOverride = "lasvegas"
	end

	var_2_0:loadFrom(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7)
	var_0_attachVegasLayers(arg_2_0, var_2_0, var_2_1)

	if arg_2_3.ground == var_0_VegasGround and arg_2_6 == nil then
		-- NFL-style numbers: the stock lines model (first in the list) is
		-- hidden and las-vegas-stadium's clone - same lines, red-outlined
		-- numbers, long arrows - is drawn in the same passes instead.
		local var_2_3 = var_2_0.fieldmarkings_linesList[1]

		if var_2_3 then
			var_2_3.visible = false
		end

		local var_2_4 = native.ModelLoader.load(arg_2_0:getAssetManager(), "fields/default/lines_lasvegas" .. (arg_2_4.fieldFlipped and "_flipped" or "") .. ".model", arg_2_1)

		for iter_2_0, iter_2_1 in ipairs({
			native.CRenderListType.fieldDecals,
			native.CRenderListType.fieldDecalsPIP,
			native.CRenderListType.undrawFieldDecals,
			native.CRenderListType.undrawFieldDecalsPIP
		}) do
			var_2_4:addToRenderList(iter_2_1)
		end

		table.insert(var_2_0.fieldmarkings_linesList, var_2_4)
	end

	return var_2_0
end

function loadPostTextures(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6)
	local var_3_0 = fieldposts.FieldPosts()

	var_3_0:loadFrom(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6)

	return var_3_0
end

function registerJumbotronScreen(arg_4_0, arg_4_1, arg_4_2, arg_4_3)
	assert(arg_4_1)

	for iter_4_0, iter_4_1 in pairs(arg_4_1) do
		iter_4_1:setShaderValues(function(arg_5_0, arg_5_1)
			local var_5_0 = string.lower(arg_5_1:match("([^/]+)$"))

			if arg_5_0.technique:find("es2_videoscreen") then
				arg_5_0:setFloat("g_flipVideoScreenUV", 1)
				arg_5_0:setTexture("col_map", var_5_0 ~= "videoscreen_large" and arg_4_3 or arg_4_2)
				arg_5_0:setFloat("g_autoPan", 0)
			end
		end)
	end
end

function updateJumbotronScreen(arg_6_0, arg_6_1, arg_6_2, arg_6_3)
	return
end

function registerSightScreen(arg_7_0, arg_7_1, arg_7_2)
	local var_7_0 = arg_7_0.modelsList

	assert(var_7_0)

	for iter_7_0, iter_7_1 in pairs(var_7_0) do
		iter_7_1:setShaderValues(function(arg_8_0, arg_8_1)
			local var_8_0 = arg_8_0.name

			if var_8_0:find("/sightscreen") or var_8_0:find("/tarp") then
				arg_8_0:setVec4("mat_color_matrix_b", arg_7_2.x, arg_7_2.y, arg_7_2.z, arg_7_2.w)
			end
		end)
	end
end
