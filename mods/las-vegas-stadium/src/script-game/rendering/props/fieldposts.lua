import("rendering.props.propfactory")

local var_0_0 = load("script-config.game.stadiums.stadiumSponsorTextures")

cornerPostPropNames = {
	"fieldposts/cornerpost1",
	"fieldposts/cornerpost2",
	"fieldposts/cornerpost3",
	"fieldposts/cornerpost4"
}

Class("FieldPosts")

function FieldPosts.dispose(arg_1_0)
	local var_1_0 = arg_1_0.postTextures

	if var_1_0 then
		for iter_1_0, iter_1_1 in pairs(var_1_0) do
			for iter_1_2, iter_1_3 in pairs(iter_1_1) do
				iter_1_3:unload()
			end
		end

		arg_1_0.postTextures = nil
	end
end

function FieldPosts.loadFrom(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7)
	local var_2_0 = arg_2_1:getRenderInterface()
	local var_2_1 = arg_2_1:getAssetManager()
	local var_2_2 = arg_2_1:getRendertargetPool()
	local var_2_3 = arg_2_1:getTextureManager()
	local var_2_4 = arg_2_1:getDecalRender()
	local var_2_5 = arg_2_5.ground
	local var_2_6

	var_2_6 = arg_2_7 ~= nil

	local var_2_7 = arg_2_3.stateOfTheSeason.competitionId
	local var_2_8 = arg_2_3.stateOfTheSeason.specialEvent
	local var_2_9 = arg_2_6.sponsorType
	local var_2_10 = var_2_9 == "nrl"
	local var_2_11 = var_2_5 == "lasVegasStadium"
	local var_2_12 = var_2_8 == native.CareerFixtureSpecialEvent.MagicRound
	local var_2_13 = var_2_8 == native.CareerFixtureSpecialEvent.GrandFinal
	local var_2_14 = var_2_7 == native.CareerCompetitionIdEnum.Tournament_ChallengeCup or var_2_7 == native.CareerCompetitionIdEnum.Tournament_WomensChallengeCup
	local var_2_15 = var_2_7 == native.CareerCompetitionIdEnum.Tournament_RLWC2026Men
	local var_2_16 = var_2_7 == native.CareerCompetitionIdEnum.Tournament_RLWC2026Women
	local var_2_17 = var_0_0.cornerPostSponsorFolderPath
	local var_2_18 = var_0_0.goalPostSponsorFolderPath
	local var_2_19 = arg_2_3.home
	local var_2_20 = var_2_19.identity:getGround(1)
	local var_2_21 = var_2_19.identity:getGround(2)
	local var_2_22 = var_2_19.identity:getGround(3)
	local var_2_23 = var_2_10 and (var_2_20.key == var_2_5 or var_2_21.key == var_2_5 or var_2_22.key == var_2_5) and string.lower(var_2_19.nickname)
	local var_2_24 = var_2_13 and "nrl_grandFinal" or var_2_12 and "magicRound" or var_2_11 and "lasvagas" or var_2_15 and "rlwc26_male" or var_2_16 and "rlwc26_female" or var_2_23 or var_2_14 and "challengeCup" or var_2_9
	local var_2_25 = {
		nrl = {
			"cornerpost_nrl_col"
		},
		nrl_grandFinal = {
			"cornerpost_nrl_grandFinal_col"
		},
		superLeague = {
			"cornerpost_superLeague_col"
		},
		challengeCup = {
			"cornerpost_challengeCup_col"
		},
		lasvagas = {
			"cornerpost_lasvegas_col"
		},
		magicRound = {
			"cornerpost_magicRound_col"
		},
		rlwc26_male = {
			"cornerpost_rlwc26_male_col"
		},
		rlwc26_female = {
			"cornerpost_rlwc26_female_col"
		},
		broncos = {
			"cornerpost_broncos_col"
		},
		bulldogs = {
			"cornerpost_bulldogs_col"
		},
		cowboys = {
			"cornerpost_cowboys_col"
		},
		dolphins = {
			"cornerpost_dolphins_col"
		},
		dragons = {
			"cornerpost_dragons_col"
		},
		eels = {
			"cornerpost_eels_col"
		},
		knights = {
			"cornerpost_knights_col"
		},
		panthers = {
			"cornerpost_panthers_col"
		},
		rabbitohs = {
			"cornerpost_rabbitohs_col"
		},
		raiders = {
			"cornerpost_raiders_col"
		},
		roosters = {
			"cornerpost_roosters_col"
		},
		["sea eagles"] = {
			"cornerpost_seaEagles_col"
		},
		sharks = {
			"cornerpost_sharks_col"
		},
		storm = {
			"cornerpost_storm_col"
		},
		titans = {
			"cornerpost_titans_col"
		},
		warriors = {
			"cornerpost_warriors_col"
		},
		tigers = {
			"cornerpost_westsTigers_col"
		}
	}
	local var_2_26 = {
		nrl = {
			"goalpost_nrl_col"
		},
		nrl_grandFinal = {
			"goalpost_nrl_grandFinal_col"
		},
		superLeague = {
			"goalpost_superLeague_col"
		},
		challengeCup = {
			"goalpost_challengeCup_col"
		},
		lasvagas = {
			"goalpost_lasvegas_col"
		},
		magicRound = {
			"goalpost_magicRound_col"
		},
		rlwc26_male = {
			"goalpost_rlwc26_male_col"
		},
		rlwc26_female = {
			"goalpost_rlwc26_female_col"
		},
		broncos = {
			"goalpost_broncos_col"
		},
		bulldogs = {
			"goalpost_bulldogs_col"
		},
		cowboys = {
			"goalpost_cowboys_col"
		},
		dolphins = {
			"goalpost_dolphins_col"
		},
		dragons = {
			"goalpost_dragons_col"
		},
		eels = {
			"goalpost_eels_col"
		},
		knights = {
			"goalpost_knights_col"
		},
		panthers = {
			"goalpost_panthers_col"
		},
		rabbitohs = {
			"goalpost_rabbitohs_col"
		},
		raiders = {
			"goalpost_raiders_col"
		},
		roosters = {
			"goalpost_roosters_col"
		},
		["sea eagles"] = {
			"goalpost_seaEagles_col"
		},
		sharks = {
			"goalpost_sharks_col"
		},
		storm = {
			"goalpost_storm_col"
		},
		titans = {
			"goalpost_titans_col"
		},
		warriors = {
			"goalpost_warriors_col"
		},
		tigers = {
			"goalpost_westsTigers_col"
		}
	}
	local var_2_27 = var_2_25[var_2_24] or {
		"cornerpost_col"
	}
	local var_2_28 = {}

	for iter_2_0, iter_2_1 in ipairs(var_2_27) do
		local var_2_29 = var_2_17 .. iter_2_1 .. ".texture"
		local var_2_30 = var_2_3:load(var_2_29)

		table.insert(var_2_28, var_2_30)
	end

	local var_2_31 = var_2_26[var_2_24] or {
		"goalpost_rugby_col"
	}
	local var_2_32 = {}

	for iter_2_2, iter_2_3 in pairs(var_2_31) do
		local var_2_33 = var_2_18 .. iter_2_3 .. ".texture"

		var_2_32[iter_2_2] = var_2_3:load(var_2_33)
	end

	arg_2_0.postTextures = {
		cornerPost_colList = var_2_28,
		goalPost_colList = var_2_32
	}

	-- Allegiant Stadium: NFL-style mustard uprights (the appended
	-- goalposts01_mustard_col, see las-vegas-stadium/install.py). Only the
	-- ground decides it - Magic Round / Grand Final pads still win there.
	if var_2_11 then
		arg_2_0.postTextures.goalPostUpright_colList = {
			var_2_3:load(var_2_18 .. "goalposts01_mustard_col.texture")
		}
	end
end

function FieldPosts.setPostTextures(arg_3_0, arg_3_1)
	local var_3_0 = arg_3_0.postTextures

	if var_3_0 == nil then
		return
	end

	local var_3_1 = {
		"fieldposts/goalpostsN"
	}
	local var_3_2 = {
		"fieldposts/goalpostsS"
	}
	local var_3_3 = "cornerpost_SS"
	local var_3_4 = "goalPads_SS"
	local var_3_5 = var_3_0.cornerPost_colList
	local var_3_6 = #cornerPostPropNames / 2

	for iter_3_0 = 1, var_3_6 do
		local var_3_7 = iter_3_0
		local var_3_8 = iter_3_0 + var_3_6
		local var_3_9 = {
			cornerPostPropNames[var_3_7],
			cornerPostPropNames[var_3_8]
		}
		local var_3_10 = var_3_5[iter_3_0] or var_3_5[1]

		propfactory.set_textures(arg_3_1, var_3_9, var_3_10, var_3_3, "col_map")
	end

	local var_3_11 = var_3_0.goalPost_colList
	local var_3_12 = var_3_11.goalPostSponsorN or var_3_11[1]
	local var_3_13 = var_3_11.goalPostSponsorS or var_3_11[1]

	propfactory.set_textures(arg_3_1, var_3_1, var_3_12, var_3_4, "col_map")
	propfactory.set_textures(arg_3_1, var_3_2, var_3_13, var_3_4, "col_map")

	-- goalPosts_SS is the uprights/crossbar material of goalpost.model (the
	-- black base is goalPosts_black_SS, the pads goalPads_SS).
	local var_3_UprightList = var_3_0.goalPostUpright_colList

	if var_3_UprightList and var_3_UprightList[1] then
		propfactory.set_textures(arg_3_1, {
			"fieldposts/goalpostsN",
			"fieldposts/goalpostsS"
		}, var_3_UprightList[1], "goalPosts_SS", "col_map")
	end
end
