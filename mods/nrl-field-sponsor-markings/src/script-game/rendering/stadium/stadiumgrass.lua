import("core.assets.assetjoin")

local var_0_0 = load("intermediatelua.visualconfig.cracks")

import("rules.rules.rulesenvironment_cconfig")

local var_0_1 = rulesenvironment_cconfig.cBoundaryConfig
local var_0_2 = "intermediatelua.visualconfig.field-cfg"
local var_0_3 = load(var_0_2)
local var_0_4 = "textures/effects/brush.texture"

Class("StadiumGrass")

function StadiumGrass.dispose(arg_1_0, arg_1_1)
	local var_1_0 = arg_1_0.cdegradation

	if var_1_0 then
		var_1_0:dispose(arg_1_1:getRenderInterface())

		arg_1_0.cdegradation = nil
	end

	local var_1_1 = arg_1_0.pitchdeg

	if var_1_1 then
		var_1_1:unloadBlob()

		arg_1_0.pitchdeg = nil
	end

	local var_1_2 = arg_1_0.grassmodel

	if var_1_2 then
		var_1_2:dispose()

		arg_1_0.grassmodel = nil
	end

	local var_1_3 = arg_1_0.fieldmarkings_linesList

	for iter_1_0, iter_1_1 in ipairs(var_1_3) do
		if iter_1_1 then
			iter_1_1:dispose()

			arg_1_0.fieldmarkings_lines = nil
		end
	end

	local var_1_4 = arg_1_0.fieldmarkings_sponsors

	if var_1_4 then
		var_1_4:dispose()

		arg_1_0.fieldmarkings_sponsors = nil
	end

	if arg_1_0.fieldmarkings_sponsorsExtra then
		arg_1_0.fieldmarkings_sponsorsExtra:dispose()

		arg_1_0.fieldmarkings_sponsorsExtra = nil
	end

	if arg_1_0.fieldTextures then
		for iter_1_2, iter_1_3 in pairs(arg_1_0.fieldTextures) do
			iter_1_3:unload()
		end

		arg_1_0.fieldTextures = nil
	end

	if arg_1_0.fieldSponsorTextures then
		for iter_1_4, iter_1_5 in pairs(arg_1_0.fieldSponsorTextures) do
			iter_1_5:unload()
		end

		arg_1_0.fieldSponsorTextures = nil
	end

	if arg_1_0.grassUpdateJob then
		arg_1_0.grassUpdateJob:dispose()

		arg_1_0.grassUpdateJob = nil
	end
end

function StadiumGrass.loadFrom(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8)
	local var_2_0 = arg_2_1:getRenderInterface()
	local var_2_1 = arg_2_1:getAssetManager()
	local var_2_2 = arg_2_1:getRendertargetPool()
	local var_2_3 = arg_2_1:getTextureManager()
	local var_2_4 = arg_2_1:getDecalRender()
	local var_2_5 = VERIFY(arg_2_6.field)
	local var_2_6 = VERIFY(arg_2_6.fieldDegradation)
	local var_2_7 = arg_2_4.ground
	local var_2_8 = arg_2_7 ~= nil
	local var_2_9 = arg_2_3.advertisingHoardings
	local var_2_10 = arg_2_3.stateOfTheSeason.competitionId
	local var_2_11 = arg_2_3.stateOfTheSeason.specialEvent
	local var_2_12 = arg_2_3.matchType.fieldMarkings
	local var_2_13 = arg_2_5.sponsorCountry
	local var_2_14 = arg_2_5.fieldFlipped and "_flipped" or ""
	local var_2_15
	local var_2_16 = {}

	if var_2_8 then
		local var_2_17 = ""
		local var_2_18 = native.ModelLoader.load(var_2_1, "fields/default/lines" .. var_2_17 .. ".model", arg_2_2)

		var_2_15 = arg_2_7:getStadium(1):getScale()

		local var_2_19 = native.ModelLoader.load(var_2_1, "stadiumCreator/fields/models/fieldMarkings_lines_" .. tostring(var_2_15) .. ".model", arg_2_2)

		table.insert(var_2_16, var_2_18)
		table.insert(var_2_16, var_2_19)
	else
		local var_2_20 = native.ModelLoader.load(var_2_1, "fields/default/lines" .. var_2_14 .. ".model", arg_2_2)

		table.insert(var_2_16, var_2_20)
	end

	for iter_2_0, iter_2_1 in ipairs(var_2_16) do
		iter_2_1:addToRenderList(native.CRenderListType.fieldDecals)
		iter_2_1:addToRenderList(native.CRenderListType.fieldDecalsPIP)
		iter_2_1:addToRenderList(native.CRenderListType.undrawFieldDecals)
		iter_2_1:addToRenderList(native.CRenderListType.undrawFieldDecalsPIP)
	end

	arg_2_0.fieldmarkings_linesList = var_2_16

	local var_2_21 = {
		[native.CareerFixtureSpecialEvent.Indigenous] = "sponsor_field_indigenous",
		[native.CareerFixtureSpecialEvent.MulticulturalRound] = "sponsor_field_multicultural",
		[native.CareerFixtureSpecialEvent.AnzacRound] = "sponsor_field_anzac",
		[native.CareerFixtureSpecialEvent.WomenInLeague] = "sponsor_field_womenInLeague"
	}
	local var_2_22 = {
		[native.CareerCompetitionIdEnum.Tournament_RLWC2026Men] = "sponsor_field_rlwc_male",
		[native.CareerCompetitionIdEnum.Tournament_RLWC2026Women] = "sponsor_field_rlwc_female"
	}
	local var_2_23 = {
		[native.MatchSettingsFieldMarkings.NRL_Season_Thursday] = "sponsor_field_thursdayNightFootball",
		[native.MatchSettingsFieldMarkings.NRL_Season_Friday] = "sponsor_field_fridayNightFootball",
		[native.MatchSettingsFieldMarkings.NRL_Season_Saturday] = "sponsor_field_superSaturday",
		[native.MatchSettingsFieldMarkings.NRL_Season_Sunday] = "sponsor_field_sundayFootball",
		[native.MatchSettingsFieldMarkings.NRL_Season_Monday] = "sponsor_field_mondayFootball"
	}

	-- These rounds/tournaments ship sponsor models but were only reachable via
	-- career special events / competition ids, so picking them as the field
	-- markings (Play Now) loaded nothing. Multicultural Round has no enum
	-- value of its own, so it rides on the otherwise unused PlayNRL round.
	-- The Grand Final has no sponsor model, so it takes over the women's RLWC
	-- one (re-textured by this mod); both World Cups share the men's model,
	-- whose geometry is identical. Guarded: a nil enum value would make a
	-- nil table key.
	local var_2_FM = native.MatchSettingsFieldMarkings

	var_2_22[native.CareerCompetitionIdEnum.Tournament_RLWC2026Women] = "sponsor_field_rlwc_male"

	for iter_2_FM, iter_2_FMModel in pairs({
		NRL_Round_Anzac = "sponsor_field_anzac",
		NRL_Round_Indigenous = "sponsor_field_indigenous",
		NRL_Round_WomenInLeague = "sponsor_field_womenInLeague",
		NRL_Round_PlayNRL = "sponsor_field_multicultural",
		NRL_GrandFinal = "sponsor_field_rlwc_female",
		NRL_GrandFinal_Post2017 = "sponsor_field_rlwc_female",
		WorldCup = "sponsor_field_rlwc_male",
		WorldCupWomens = "sponsor_field_rlwc_male"
	}) do
		if var_2_FM[iter_2_FM] ~= nil then
			var_2_23[var_2_FM[iter_2_FM]] = iter_2_FMModel
		end
	end

	local var_2_24
	local var_2_25
	local var_2_26 = var_2_21[var_2_11] or var_2_22[var_2_10] or var_2_23[var_2_12]

	if var_2_26 then
		var_2_24 = native.ModelLoader.load(var_2_1, "fields/default/" .. var_2_26 .. var_2_14 .. ".model", arg_2_2)
		-- Stock hid this until the team-shield intro set it visible, so any
		-- path that never ran that intro left the sponsors off the grass.
		var_2_24.visible = true

		var_2_24:addToRenderList(native.CRenderListType.fieldSponsorDecals)
		var_2_24:addToRenderList(native.CRenderListType.fieldSponsorDecalsPIP)
		var_2_24:addToRenderList(native.CRenderListType.undrawFieldDecals)
		var_2_24:addToRenderList(native.CRenderListType.undrawFieldDecalsPIP)

		arg_2_0.fieldmarkings_sponsors = var_2_24
		var_2_25 = var_2_3:load("fields/textures/sponsors/sponsor_alphaDetail_col.texture")
	end

	-- The Grand Final model only has a centre slot (its in-goal banners are
	-- collapsed by this mod), so the Monday model - re-textured to Westpac
	-- mid-field squares + KFC in-goal banners, badge collapsed - is drawn
	-- as a second sponsor layer under it.
	local var_2_SponsorExtra
	local var_2_SponsorExtraName = ({
		sponsor_field_rlwc_female = "sponsor_field_mondayFootball"
	})[var_2_26]

	if var_2_SponsorExtraName then
		var_2_SponsorExtra = native.ModelLoader.load(var_2_1, "fields/default/" .. var_2_SponsorExtraName .. var_2_14 .. ".model", arg_2_2)
		var_2_SponsorExtra.visible = true

		var_2_SponsorExtra:addToRenderList(native.CRenderListType.fieldSponsorDecals)
		var_2_SponsorExtra:addToRenderList(native.CRenderListType.fieldSponsorDecalsPIP)
		var_2_SponsorExtra:addToRenderList(native.CRenderListType.undrawFieldDecals)
		var_2_SponsorExtra:addToRenderList(native.CRenderListType.undrawFieldDecalsPIP)

		arg_2_0.fieldmarkings_sponsorsExtra = var_2_SponsorExtra
	end

	if arg_2_1:getGraphicsSettings().grass == native.EGraphicsSettingsGrass.HighQuality and not arg_2_6.noGrass then
		local var_2_27 = native.CModelData.create()

		var_2_27.contributeToRTAO = false

		local var_2_28 = native.ModelLoader.load(var_2_1, var_2_5.grassModel .. ".model", arg_2_2, var_2_27)

		var_2_28:removeFromRenderList(native.CRenderListType.depthPrePass)
		var_2_28:addToRenderList(native.CRenderListType.lateDepthPrePass)
		var_2_28:addToRenderList(native.CRenderListType.grass)
		var_2_28:setPosition(native.vec3.Zero())

		arg_2_0.grassmodel = var_2_28

		local var_2_29 = native.CGrassUpdate()

		arg_2_0.grassUpdateJob = var_2_29
		arg_2_0.grassGlobals = native.CGrassShaderGlobals()

		local var_2_30 = assetjoin.AssetJoin(arg_2_1:getAssetNotifier(), "stadium grass")

		var_2_30:addAsset(var_2_28)
		var_2_30:fire(function()
			var_2_29:init(arg_2_1:getJobManager(), arg_2_2, var_2_28, arg_2_0.grassGlobals)
		end)
	end

	local var_2_31 = assetjoin.AssetJoin(arg_2_1:getAssetNotifier(), "field team logos")

	for iter_2_2, iter_2_3 in ipairs(var_2_16) do
		var_2_31:addAsset(iter_2_3)
	end

	var_2_31:addAsset(var_2_24)

	if var_2_SponsorExtra then
		var_2_31:addAsset(var_2_SponsorExtra)
	end

	local var_2_32
	local var_2_34

	if arg_2_7 then
		local var_2_33 = arg_2_7:getGrassType()

		if var_2_33 == native.ELevelGrassType.VeryLush then
			var_2_34 = "grass_verylush_col"
		elseif var_2_33 == native.ELevelGrassType.Lush then
			var_2_34 = "grass_lush_col"
		elseif var_2_33 == native.ELevelGrassType.Standard then
			var_2_34 = "grass_standard_col"
		elseif var_2_33 == native.ELevelGrassType.Dry then
			var_2_34 = "grass_dry_col"
		else
			var_2_34 = "grass_verydry_col"
		end
	else
		var_2_34 = arg_2_5.grassType
	end

	local var_2_35 = "fields/textures/"
	local var_2_36 = var_2_35 .. "grass/" .. var_2_34 .. ".texture"
	local var_2_37 = var_2_35 .. "grass/grass_dry_col.texture"
	local var_2_38 = var_2_35 .. "dirt/" .. var_2_5.dirtTex .. "_col.texture"
	local var_2_39 = var_2_35 .. "grass/grass_standard_nrm.texture"
	local var_2_40 = var_2_35 .. "dirt/" .. var_2_5.dirtTex .. "_nrm.texture"
	local var_2_41 = var_2_35 .. "grass/grassDetail_msk.texture"
	local var_2_42 = "grass/textures/"
	local var_2_43
	local var_2_44

	if arg_2_0.grassmodel then
		var_2_43 = var_2_42 .. "grass_plane_col.texture"
		var_2_44 = var_2_42 .. "grass_plane_alpha_col.texture"
	end

	local var_2_45 = var_2_3:load(var_2_36)
	local var_2_46 = var_2_3:load(var_2_37)
	local var_2_47 = var_2_3:load(var_2_38)
	local var_2_48 = var_2_3:load(var_2_39)
	local var_2_49 = var_2_3:load(var_2_40)
	local var_2_50 = var_2_3:load(var_2_41)
	local var_2_51
	local var_2_52

	if arg_2_0.grassmodel then
		var_2_51 = var_2_3:load(var_2_43)
		var_2_52 = var_2_3:load(var_2_44)
	end

	local var_2_53

	if arg_2_7 then
		var_2_53 = var_2_3:load(var_2_35 .. "outerWear/outerFieldDegredation_" .. tostring(var_2_15) .. "_msk.texture")
	else
		var_2_53 = var_2_3:load(var_2_35 .. "outerWear/outerFieldDegredation_default_msk.texture")
	end

	local var_2_54 = var_2_3:load(var_0_4)
	local var_2_55 = {
		32,
		16
	}

	native.setShaderGlobalVec2f("g_field_dynamicMaskArea", var_2_55[1] / 2, var_2_55[2] / 2)

	local var_2_56 = 1024
	local var_2_57 = 128

	arg_2_0.cdegradation = native.CDegradationTile(var_2_0, var_2_57, var_2_56, var_2_55[1], var_2_55[2], var_2_3)

	native.setShaderGlobalVec4f("g_field_posRot", 0, 0, 1, 0)
	var_2_31:fire(function()
		if var_2_24 and var_2_25 then
			var_2_24:setShaderValues(function(arg_5_0, arg_5_1)
				arg_5_0:setTexture("detail_map", var_2_25)
			end)
		end

		if var_2_SponsorExtra and var_2_25 then
			var_2_SponsorExtra:setShaderValues(function(arg_5_0, arg_5_1)
				arg_5_0:setTexture("detail_map", var_2_25)
			end)
		end
	end)

	local var_2_58 = {
		145,
		145
	}

	native.setShaderGlobalVec2f("g_field_fieldMaskArea", var_2_58[1] / -2, var_2_58[2] / 2)

	arg_2_0.fieldTextures = {
		grass_col = var_2_45,
		grass2_col = var_2_46,
		dirt_col = var_2_47,
		grass_nrm = var_2_48,
		dirt_nrm = var_2_49,
		grassDetail_msk = var_2_50,
		field_msk = var_2_53,
		stampTex = var_2_54,
		grass_plane_col = var_2_51,
		grass_plane_alpha_col = var_2_52
	}
	arg_2_0.fieldSponsorTextures = {
		fieldSponsorDetailTexture = var_2_25
	}
	arg_2_0.stadiumModel = arg_2_8
	arg_2_0.gpuDevice = var_2_0
end

function StadiumGrass.setFieldTextures(arg_6_0, arg_6_1)
	local var_6_0 = arg_6_0.fieldTextures

	if var_6_0 == nil then
		return
	end

	local var_6_1 = VERIFY(var_6_0.grass_col)
	local var_6_2 = VERIFY(var_6_0.grass2_col)
	local var_6_3 = VERIFY(var_6_0.dirt_col)
	local var_6_4 = VERIFY(var_6_0.grass_nrm)
	local var_6_5 = VERIFY(var_6_0.dirt_nrm)
	local var_6_6 = VERIFY(var_6_0.grassDetail_msk)
	local var_6_7 = VERIFY(var_6_0.field_msk)
	local var_6_8 = VERIFY(arg_6_0.cdegradation)

	if arg_6_1 then
		arg_6_1:setShaderValues(function(arg_7_0, arg_7_1)
			arg_7_0:setTexture("grass_col", var_6_1)
			arg_7_0:setTexture("grass2_col", var_6_2)
			arg_7_0:setTexture("dirt_col", var_6_3)
			arg_7_0:setTexture("grass_nrm", var_6_4)
			arg_7_0:setTexture("dirt_nrm", var_6_5)
			arg_7_0:setTexture("grassDetail_msk", var_6_6)
			arg_7_0:setTexture("field_msk", var_6_7)
			arg_7_0:setTexture("dynamic_scuff_map", var_6_8:getRenderTarget())
		end)
	end

	if arg_6_0.grassmodel then
		local var_6_9 = VERIFY(var_6_0.grass_plane_col)
		local var_6_10 = VERIFY(var_6_0.grass_plane_alpha_col)

		arg_6_0.grassmodel:setShaderValues(function(arg_8_0, arg_8_1)
			arg_8_0:setTexture("col_map", var_6_9)
			arg_8_0:setTexture("alpha_map", var_6_10)
			arg_8_0:setTexture("grass_col", var_6_1)
			arg_8_0:setTexture("grass2_col", var_6_2)
			arg_8_0:setTexture("dirt_col", var_6_3)
			arg_8_0:setTexture("grass_nrm", var_6_4)
			arg_8_0:setTexture("grassDetail_msk", var_6_6)
			arg_8_0:setTexture("field_msk", var_6_7)
			arg_8_0:setTexture("dynamic_scuff_map", var_6_8:getRenderTarget())
		end)
	end
end

function StadiumGrass.resetDegradation(arg_9_0)
	local var_9_0 = arg_9_0.cdegradation

	if var_9_0 then
		var_9_0:resetDegradation()
	end
end

function StadiumGrass.getDegradation(arg_10_0)
	return arg_10_0.cdegradation
end

function StadiumGrass.addToJoin(arg_11_0, arg_11_1)
	local var_11_0 = arg_11_0.grassmodel

	if var_11_0 then
		arg_11_1:addAsset(var_11_0)
	end

	local var_11_1 = arg_11_0.fieldTextures

	if var_11_1 then
		for iter_11_0, iter_11_1 in pairs(var_11_1) do
			arg_11_1:addAsset(iter_11_1)
		end
	end
end

function StadiumGrass.registerWithRenderer(arg_12_0, arg_12_1)
	if arg_12_0.cdegradation then
		arg_12_1:setDegradationTile(arg_12_0.cdegradation)
	end
end

function StadiumGrass.registerWithHooks(arg_13_0, arg_13_1)
	arg_13_1("FieldDegradationHook", "setDegradationTile", arg_13_0.cdegradation)
end

function StadiumGrass.registerWithReplayManager(arg_14_0, arg_14_1, arg_14_2)
	if arg_14_0.cdegradation then
		assert(not arg_14_0.replaySystem)

		local var_14_0 = native.CDegradationReplaySystem(arg_14_2, "degradation")

		var_14_0.degradation = arg_14_0.cdegradation
		arg_14_0.replaySystem = var_14_0

		arg_14_1:addFrameStartReplaySystemC(var_14_0)
	end
end

function StadiumGrass.registerWithReplayManagerPlaybackInstance(arg_15_0, arg_15_1, arg_15_2)
	if arg_15_0.replaySystem then
		local var_15_0 = native.CDegradationReplaySystemPlaybackInstance(arg_15_2, "degradation")

		var_15_0.degradation = arg_15_0.cdegradation

		arg_15_1:addReplaySystemPlaybackInstanceC(var_15_0)

		return var_15_0
	end
end

function StadiumGrass.updateLoading(arg_16_0, arg_16_1, arg_16_2)
	if arg_16_0.replacementTextures then
		local var_16_0 = true

		for iter_16_0, iter_16_1 in pairs(arg_16_0.replacementTextures) do
			var_16_0 = var_16_0 and iter_16_1:isLoaded()
		end

		if var_16_0 then
			for iter_16_2, iter_16_3 in pairs(arg_16_0.fieldTextures) do
				iter_16_3:unload()
			end

			arg_16_0.fieldTextures = arg_16_0.replacementTextures

			arg_16_0:setFieldTextures(arg_16_0.stadiumModel.modelsList.field)

			arg_16_0.replacementTextures = nil
		end
	end
end

function StadiumGrass.updateGrass(arg_17_0)
	local var_17_0 = arg_17_0.grassGlobals

	if var_17_0 then
		native.setShaderGlobalFloat("grass_patchRadius", var_17_0.patchRadius)
		native.setShaderGlobalFloat("grass_grassHeight", var_17_0.grassHeight)
		native.setShaderGlobalFloat("grass_patchx", var_17_0.patchx)
		native.setShaderGlobalFloat("grass_patchz", var_17_0.patchz)
		native.setShaderGlobalFloat("grass_distanceFalloff", var_17_0.distanceFalloff)
	end
end
