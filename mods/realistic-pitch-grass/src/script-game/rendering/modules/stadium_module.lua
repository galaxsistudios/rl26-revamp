import("core.assets.assetjoin")
import("core.foundation.tablex")
import("core.profile.profile")
import("rendering.props.propfactory")
import("rendering.stadium.stadiumfactory")
import("intermediatelua.convant.stadiumcreator")
import("script-config.game.stadiums.stadiumtemplates")

local var_0_0 = load("intermediatelua.visualconfig.stadium-cfg")
local var_0_1 = load("intermediatelua.props.list")

-- realistic-pitch-grass: every stock ground uses grass_lush_col. Grounds
-- listed here get one of the other grass colour textures instead (all four
-- are repainted by this mod from the lush blade detail):
--   grass_verylush_col  deep, cool winter ryegrass (UK, France, NZ, Melbourne, Canberra)
--   grass_standard_col  warmer couch / bermuda (tropics, Las Vegas)
--   grass_verydry_col   tired suburban turf with dry patches (park grounds)
-- Anything not listed keeps the stadium-cfg grassType (repainted lush).
local var_0_RyeGrass = "grass_verylush_col"
local var_0_CouchGrass = "grass_standard_col"
local var_0_SuburbanGrass = "grass_verydry_col"
local var_0_GroundGrass = {
	-- England / Wales / France
	cravenPark = var_0_RyeGrass,
	warringtonStadium = var_0_RyeGrass,
	headingleyRugbyStadium = var_0_RyeGrass,
	hullCityStadium = var_0_RyeGrass,
	kirkleesStadium = var_0_RyeGrass,
	langtreePark = var_0_RyeGrass,
	leighSportsVillage = var_0_RyeGrass,
	manchesterStadium = var_0_RyeGrass,
	salfordCommunityStadium = var_0_RyeGrass,
	perpignanStadium = var_0_RyeGrass,
	wakefieldStadium = var_0_RyeGrass,
	castlefordRugbyGround = var_0_RyeGrass,
	wiganStadium = var_0_RyeGrass,
	barrowRugbyStadium = var_0_RyeGrass,
	batleyStadium = var_0_RyeGrass,
	bradfordRugbyStadium = var_0_RyeGrass,
	doncasterStadium = var_0_RyeGrass,
	featherstoneRugbyStadium = var_0_RyeGrass,
	halifaxStadium = var_0_RyeGrass,
	southLeedsStadium = var_0_RyeGrass,
	oldhamStadium = var_0_RyeGrass,
	sheffieldRugbyStadium = var_0_RyeGrass,
	toulouseStadium = var_0_RyeGrass,
	stadeErnestWallon = var_0_RyeGrass,
	widnesStadium = var_0_RyeGrass,
	yorkStadium = var_0_RyeGrass,
	penrynRugbyGround = var_0_RyeGrass,
	dewsburyStadium = var_0_RyeGrass,
	gooleRugbyGround = var_0_RyeGrass,
	keighleyStadium = var_0_RyeGrass,
	birminghamRugbyStadium = var_0_RyeGrass,
	swalwellRugbyPark = var_0_RyeGrass,
	colwynBayStadium = var_0_RyeGrass,
	rochdaleStadium = var_0_RyeGrass,
	saleRugbyStadium = var_0_RyeGrass,
	whitehavenStadium = var_0_RyeGrass,
	workingtonRugbyStadium = var_0_RyeGrass,
	wembleyStadium = var_0_RyeGrass,
	ploughLaneStadium = var_0_RyeGrass,
	hillDickinsonStadium = var_0_RyeGrass,
	-- New Zealand, Melbourne, Canberra
	mtSmartStadium = var_0_RyeGrass,
	aucklandRugbyStadium = var_0_RyeGrass,
	waikatoStadium = var_0_RyeGrass,
	wellingtonRegionalStadium = var_0_RyeGrass,
	christchurch_rugbyLeaguePark = var_0_RyeGrass,
	christchurch_teKahaStadium = var_0_RyeGrass,
	melbourneRectangularStadium = var_0_RyeGrass,
	canberraStadium = var_0_RyeGrass,
	-- Tropics and the US
	townsvilleStadium = var_0_CouchGrass,
	marraraOval = var_0_CouchGrass,
	portmoresbyStadium = var_0_CouchGrass,
	cairnsRugbyPark = var_0_CouchGrass,
	mackayStadium = var_0_CouchGrass,
	rockhamptonRugbyStadium = var_0_CouchGrass,
	kirwanOval = var_0_CouchGrass,
	robinaStadium = var_0_CouchGrass,
	bokarinaStadium = var_0_CouchGrass,
	redcliffeStadium = var_0_CouchGrass,
	lasVegasStadium = var_0_CouchGrass,
	-- Suburban and country park grounds
	marrickvilleRugbyPark = var_0_SuburbanGrass,
	kellyvilleMemorialPark = var_0_SuburbanGrass,
	penrithReserve = var_0_SuburbanGrass,
	redfernOval = var_0_SuburbanGrass,
	stonesCornerRugbyPark = var_0_SuburbanGrass,
	miamiRugbyPark = var_0_SuburbanGrass,
	ipswichReserve = var_0_SuburbanGrass,
	westEndRugbyPark = var_0_SuburbanGrass,
	nundahRugbyPark = var_0_SuburbanGrass,
	tweedHeadsWestSportsComplex = var_0_SuburbanGrass,
	manlyWestOval = var_0_SuburbanGrass,
	glenwillSportsStadium = var_0_SuburbanGrass,
	bathurstStadium = var_0_SuburbanGrass
}

Class("StadiumModule", function(arg_1_0)
	arg_1_0.model = nil
	arg_1_0.grass = nil
	arg_1_0.propScene = nil
	arg_1_0.stadiumCfg = nil
	arg_1_0.postTextures = nil
	arg_1_0.levelInstance = nil
	arg_1_0.groundName = nil
	arg_1_0.updateables = {}
	arg_1_0.disposeList = {}
	arg_1_0.crowdScene = nil
end)

function loadProps(arg_2_0, arg_2_1, arg_2_2, arg_2_3)
	profile.push("loadProps")

	local var_2_0 = native.CPropScene()

	var_2_0:init(arg_2_0, arg_2_2)

	local var_2_1 = arg_2_1.groundInfo.ground
	local var_2_2 = var_0_1.Selection.posts

	if var_2_2 then
		local var_2_3 = "intermediatelua.props." .. var_2_2
		local var_2_4 = load(var_2_3)

		propfactory.import_props_file_fromTable(var_2_0, var_2_3, var_2_4, nil, true, nil, "main", arg_2_3)
	end

	local var_2_5 = var_0_1.Selection[var_2_1] or var_0_1.Selection.default

	propfactory.import_props_file(var_2_0, var_2_5, nil, true, nil, "main", arg_2_3)
	profile.pop("loadProps")

	return var_2_0
end

function StadiumModule.load(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10)
	local var_3_0 = arg_3_1:getAssetNotifier()
	local var_3_1 = assetjoin.AssetJoin(var_3_0, "stadium.lua, stadiumJoin")
	local var_3_2 = arg_3_6.groundInfo
	local var_3_3 = var_3_2.ground
	local var_3_4 = var_0_0.Stadiums[var_3_3]

	arg_3_0.stadiumCfg = var_3_4
	arg_3_0.groundName = var_3_3

	assert(arg_3_5.stadiumModels)

	arg_3_0.model = stadiumfactory.loadStadiumModel(arg_3_1, arg_3_2, arg_3_5.stadiumModels)

	arg_3_0.model:addToJoin(var_3_1)

	local var_3_GrassCfg = var_3_4
	local var_3_GrassType = var_0_GroundGrass[var_3_3]

	if var_3_GrassType and var_3_4 then
		var_3_GrassCfg = setmetatable({
			grassType = var_3_GrassType
		}, {
			__index = var_3_4
		})
	end

	arg_3_0.grass = stadiumfactory.loadStadiumGrass(arg_3_1, arg_3_2, arg_3_6, var_3_2, var_3_GrassCfg, arg_3_5.fieldConfig, arg_3_9, arg_3_0.model)

	arg_3_0.grass:addToJoin(var_3_1)
	table.insert(arg_3_0.updateables, arg_3_0.grass)

	arg_3_0.propScene = loadProps(arg_3_1, arg_3_6, arg_3_2, var_3_1)
	arg_3_4.propScene = arg_3_0.propScene

	local var_3_5

	arg_3_0.postTextures = stadiumfactory.loadPostTextures(arg_3_1, arg_3_2, arg_3_6, var_3_5, var_3_2, var_3_4, arg_3_5.fieldConfig, arg_3_9, arg_3_0.model)

	if arg_3_6.gameMode ~= native.EGameMode.Practice then
		local var_3_6 = var_3_3 == "creator" and "stadium" or var_3_3
		local var_3_7 = "crowd/nodefiles/" .. var_3_6 .. "_crowdnodes.nodefile"

		arg_3_7.crowdScene:setNodeFile(var_3_7)

		arg_3_0.crowdScene = arg_3_7.crowdScene
	end

	if arg_3_9 then
		local var_3_8 = arg_3_1:getAssetManager()
		local var_3_9 = arg_3_0.model
		local var_3_10 = loadTemp("intermediatelua.crowd.stadiumCreator.stadium_creator_crowdNodes").nodes
		local var_3_11 = native.CLevelInstance(var_3_8, arg_3_1:getTextureManager(), var_3_2.levelDecalData, arg_3_7.crowdScene, stadiumcreator.props, stadiumcreator.fieldTextures, stadiumcreator.backgrounds, stadiumcreator.StadiumCapBias, stadiumtemplates, var_3_10)

		var_3_11:load(var_3_8, arg_3_1, arg_3_2, arg_3_9)

		var_3_9.modelsList.field = var_3_11:getGroundModel()
		var_3_9.modelsList.sightScreenNorth = var_3_11:getSightScreenNorthModel()
		var_3_9.modelsList.sightScreenSouth = var_3_11:getSightScreenSouthModel()
		var_3_9.modelsList.tarpEnd01 = var_3_11:getTarpEnd01Model()
		var_3_9.modelsList.tarpEnd02 = var_3_11:getTarpEnd02Model()

		local var_3_12 = var_3_11:getScoreBoardModelList()

		local function var_3_13(arg_4_0)
			if arg_4_0 then
				arg_4_0:addReference()
			end
		end

		var_3_13(var_3_9.modelsList.field)
		var_3_13(var_3_9.modelsList.sightScreenNorth)
		var_3_13(var_3_9.modelsList.sightScreenSouth)
		var_3_13(var_3_9.modelsList.tarpEnd01)
		var_3_13(var_3_9.modelsList.tarpEnd02)

		for iter_3_0, iter_3_1 in pairs(var_3_12) do
			iter_3_1:addReference()
		end

		tablex.mergeInto(var_3_9.modelsList, var_3_12)
		var_3_1:addAsset(var_3_11)

		arg_3_0.levelInstance = var_3_11
	end

	local var_3_14 = arg_3_5.fieldPatternConfig

	native.setShaderGlobalVec4("g_field_stripeDirection", var_3_14.stripeDirection)
	native.setShaderGlobalFloat("g_grass_amountInner", var_3_14.innerAmount)
	native.setShaderGlobalFloat("g_grass_amountOuter", var_3_14.outerAmount)
	native.setShaderGlobalFloat("g_field_stripeWidth", var_3_14.stripeWidth)

	local var_3_15 = var_3_4.fogParams[1]
	local var_3_16 = var_3_4.fogParams[2]
	local var_3_17 = var_3_4.fogParams[3]
	local var_3_18 = var_3_4.fogParams[4]
	local var_3_19 = var_3_4.fogParams[5]
	local var_3_20 = var_3_4.fogParams[6]
	local var_3_21 = var_3_4.fogParams[7] or 1
	local var_3_22 = var_3_4.fogParams[8] or 1

	native.setShaderGlobalFloat("g_fogStadiumNear", var_3_15)
	native.setShaderGlobalFloat("g_fogStadiumFalloff", var_3_16)
	native.setShaderGlobalFloat("g_fogHeightFogNear", var_3_17)
	native.setShaderGlobalFloat("g_fogHeightFalloffB", var_3_18)
	native.setShaderGlobalFloat("g_fogHeightFalloffA", var_3_19)
	native.setShaderGlobalFloat("g_fogMinColour", var_3_20)
	native.setShaderGlobalFloat("g_litFogMultiplier", var_3_21)
	native.setShaderGlobalFloat("g_litFogSaturation", var_3_22)

	arg_3_0.joinLoaded = false

	var_3_1:fire(function()
		arg_3_0.joinLoaded = true

		local var_5_0 = VERIFY(arg_3_0.grass)
		local var_5_1 = VERIFY(arg_3_0.model)
		local var_5_2 = VERIFY(arg_3_0.propScene)
		local var_5_3 = VERIFY(arg_3_0.postTextures)

		var_5_0:setFieldTextures(var_5_1.modelsList.field)
		var_5_3:setPostTextures(var_5_2)
		propfactory.init_prop_controllers(var_5_2, arg_3_3)

		local var_5_4 = arg_3_10 and arg_3_10.texture or arg_3_8.capturedFrame

		stadiumfactory.registerJumbotronScreen(arg_3_1, arg_3_0.model.modelsList, var_5_4, arg_3_8.capturedFrame)
	end)
end

function StadiumModule.dispose(arg_6_0, arg_6_1)
	arg_6_0.model:dispose()

	arg_6_0.model = nil

	arg_6_0.grass:dispose(arg_6_1)

	arg_6_0.grass = nil

	local var_6_0 = arg_6_1:getRenderInterface()

	arg_6_0.propScene:dispose(var_6_0)

	arg_6_0.propScene = nil

	arg_6_0.postTextures:dispose()

	arg_6_0.postTextures = nil

	if arg_6_0.levelInstance then
		arg_6_0.levelInstance:unload()

		arg_6_0.levelInstance = nil
	end
end

function StadiumModule.updateLoading(arg_7_0, arg_7_1, arg_7_2)
	local var_7_0 = arg_7_1:getAssetManager()
	local var_7_1 = arg_7_1:getAssetNotifier()
	local var_7_2 = arg_7_0.levelInstance

	if var_7_2 then
		var_7_2:updateLoading(var_7_0, var_7_1)
	end

	arg_7_0.grass:updateLoading(arg_7_1, arg_7_2)
end

function StadiumModule.isLoaded(arg_8_0)
	if not arg_8_0.joinLoaded then
		return false
	end

	if arg_8_0.crowdScene and not arg_8_0.crowdScene:isLoaded() then
		return false
	end

	return true
end
