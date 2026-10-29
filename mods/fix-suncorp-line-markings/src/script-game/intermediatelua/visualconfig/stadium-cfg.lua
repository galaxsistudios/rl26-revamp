if not native.ECities then
	native.ECities = {}
end

if not native.ECountry then
	native.ECountry = {}
end

standardFxID = {
	[{
		time = "day",
		weather = "fine"
	}] = "dayFineFx",
	[{
		time = "dusk",
		weather = "fine"
	}] = "duskFineFx",
	[{
		time = "night",
		weather = "fine"
	}] = "nightFineFx",
	[{
		time = "day",
		weather = "raining"
	}] = "dayRainingFx",
	[{
		time = "dusk",
		weather = "raining"
	}] = "duskRainingFx",
	[{
		time = "night",
		weather = "raining"
	}] = "nightRainingFx",
	[{
		time = "day",
		weather = "overcast"
	}] = "dayOvercastFx",
	[{
		time = "dusk",
		weather = "overcast"
	}] = "duskOvercastFx",
	[{
		time = "night",
		weather = "overcast"
	}] = "nightOvercastFx"
}
standardGrassID = {
	[{
		weather = "fine"
	}] = "standardDry",
	[{
		weather = "raining"
	}] = "standardMuddy",
	[{
		weather = "overcast"
	}] = "standardDry"
}
artificialGrassID = {
	[{
		weather = "fine"
	}] = "artificialDry",
	[{
		weather = "raining"
	}] = "artificialWet",
	[{
		weather = "overcast"
	}] = "artificialDry"
}
standardModels = {
	"field",
	"stadium",
	"lightglows"
}
creatorModels = {
	"stadium"
}
standardAdditionalModels = {
	"stadiums/day_sun_flare.model"
}
standardAppendConfig = {}
default_dynamicenv_lighting = "dynamicenv_lighting"
default_dawn_dark_threshold = 0.4
default_dusk_dark_threshold = 0.4
default_north_offset = -90
flipped_north_offset = 90
north_offset_northern_hemisphere = 180
outdoor_fog_params = {
	137,
	0.025,
	60,
	0.038,
	5e-05,
	0.3,
	0.7,
	-15
}
indoor_fog_params = {
	100,
	0.05,
	20,
	0.3,
	0.0005,
	0,
	1,
	10
}
Stadiums = {
	creator = {
		ModelCfg = {
			canAddCrowd = true,
			basePath = "stadiums/creator/",
			commonTexpack = false,
			noDefaultCrowd = true,
			models = creatorModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {}
		},
		PostFxID = standardFxID,
		fogParams = outdoor_fog_params,
		cutsceneOffset = {
			home = {
				pos = {
					0,
					0
				},
				rot = -0
			},
			away = {
				pos = {
					0,
					6
				},
				rot = -0
			}
		},
		northOffset = default_north_offset,
		GrassConfigID = standardGrassID,
		dynamicenv_lighting = default_dynamicenv_lighting,
		GrassDimensions = {
			minZ = -36,
			maxX = 61,
			maxZ = 36,
			minX = -61,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig
	},
	belmoreSportsGround = {
		commentary = "belmoresportsground",
		sponsorType = "nrl",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/belmoreSportsGround/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				nrl = "sponsors_nrl",
				bulldogs = "sponsors_bulldogs",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 180,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 180,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Sydney,
		countryEnum = native.ECountry.Australia
	},
	brisbane = {
		fieldFlipped = true,
		northOffset = -75,
		commentary = "suncorpstadium",
		sponsorType = "nrl",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/brisbane/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				magicRound_rabbitohs = "sponsors_magicRound_rabbitohs",
				magicRound_panthers = "sponsors_magicRound_panthers",
				magicRound_storm = "sponsors_magicRound_storm",
				magicRound_roosters = "sponsors_magicRound_roosters",
				broncos = "sponsors_broncos",
				magicRound_titans = "sponsors_magicRound_titans",
				magicRound_sharks = "sponsors_magicRound_sharks",
				magicRound_warriors = "sponsors_magicRound_warriors",
				magicRound_tigers = "sponsors_magicRound_westsTigers",
				rlwcMale = "sponsors_rlwc_male",
				standard = "sponsors_standard",
				rlwcFemale = "sponsors_rlwc_female",
				nrl = "sponsors_nrl"
			}
		},
		cutsceneOffset = {
			home = {
				pos = {
					0,
					0
				},
				rot = -0
			},
			away = {
				pos = {
					0,
					6
				},
				rot = -0
			}
		},
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Brisbane,
		countryEnum = native.ECountry.Australia
	},
	brookvaleOval = {
		fieldFlipped = true,
		commentary = "4pinespark",
		sponsorType = "nrl",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/brookvaleOval/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				nrl = "sponsors_nrl",
				["sea eagles"] = "sponsors_seaEagles",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Sydney,
		countryEnum = native.ECountry.Australia
	},
	campbelltownSportsStadium = {
		commentary = "campbelltownsportsstadium",
		sponsorType = "nrl",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/campbelltownSportsStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				tigers = "sponsors_westsTigers",
				nrl = "sponsors_nrl",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 180,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 180,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Sydney,
		countryEnum = native.ECountry.Australia
	},
	canberraStadium = {
		commentary = "giostadium",
		sponsorType = "nrl",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/canberraStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				raiders = "sponsors_raiders",
				nrl = "sponsors_nrl",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Canberra,
		countryEnum = native.ECountry.Australia
	},
	cravenPark = {
		commentary = "sewellgroupcravenpark",
		sponsorType = "superLeague",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/cravenPark/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				championTrophy = "sponsors_championTrophy",
				superLeagueWomens = "sponsors_superLeagueWomens",
				superLeague = "sponsors_superLeague",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Hull,
		countryEnum = native.ECountry.England
	},
	endeavourField = {
		commentary = "sharksstadium",
		sponsorType = "nrl",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/endeavourField/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				nrl = "sponsors_nrl",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 180,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 180,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Sydney,
		countryEnum = native.ECountry.Australia
	},
	warringtonStadium = {
		commentary = "halliwelljonesstadium",
		sponsorType = "superLeague",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/warringtonStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				championTrophy = "sponsors_championTrophy",
				superLeagueWomens = "sponsors_superLeagueWomens",
				superLeague = "sponsors_superLeague",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 180,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 180,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Warrington,
		countryEnum = native.ECountry.England
	},
	headingleyRugbyStadium = {
		commentary = "amtheadingleystadium",
		sponsorType = "superLeague",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/headingleyRugbyStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				championTrophy = "sponsors_championTrophy",
				superLeagueWomens = "sponsors_superLeagueWomens",
				superLeague = "sponsors_superLeague",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = -180,
				pos = {
					4.708464505,
					-7.154627766
				}
			},
			away = {
				rot = -180,
				pos = {
					5.07648616,
					-11.95213816
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Leeds,
		countryEnum = native.ECountry.England
	},
	hunterStadium = {
		commentary = "mcdonaldjonesstadium",
		sponsorType = "nrl",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/hunterStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				nrl = "sponsors_nrl",
				standard = "sponsors_standard",
				rlwcFemale = "sponsors_rlwc_female",
				knights = "sponsors_knights",
				rlwcMale = "sponsors_rlwc_male"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 180,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 180,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Newcastle,
		countryEnum = native.ECountry.Australia
	},
	hullCityStadium = {
		commentary = "mkmstadium",
		sponsorType = "superLeague",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/hullCityStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				championTrophy = "sponsors_championTrophy",
				superLeagueWomens = "sponsors_superLeagueWomens",
				superLeague = "sponsors_superLeague",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Hull,
		countryEnum = native.ECountry.England
	},
	kirkleesStadium = {
		commentary = "johnsmithsstadium",
		sponsorType = "superLeague",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/kirkleesStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				championTrophy = "sponsors_championTrophy",
				superLeagueWomens = "sponsors_superLeagueWomens",
				superLeague = "sponsors_superLeague",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 180,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 180,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Huddersfield,
		countryEnum = native.ECountry.England
	},
	kogarahOval = {
		commentary = "netstratajubileestadium",
		sponsorType = "nrl",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/kogarahOval/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				dragons = "sponsors_dragons",
				nrl = "sponsors_nrl",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Sydney,
		countryEnum = native.ECountry.Australia
	},
	langtreePark = {
		commentary = "totallywickedstadium",
		sponsorType = "superLeague",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/langtreePark/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				championTrophy = "sponsors_championTrophy",
				superLeagueWomens = "sponsors_superLeagueWomens",
				superLeague = "sponsors_superLeague",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 180,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 180,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.StHelens,
		countryEnum = native.ECountry.England
	},
	lasVegasStadium = {
		commentary = "allegiantstadium",
		grassType = "grass_lush_col",
		isIndoors = true,
		ModelCfg = {
			basePath = "stadiums/lasVegasStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				raiders = "sponsors_raiders",
				panthers = "sponsors_panthers",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 180,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 180,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.LasVegas,
		countryEnum = native.ECountry.UnitedStates
	},
	leichhardtOval = {
		commentary = "leichhardtoval",
		sponsorType = "nrl",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/leichhardtOval/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				tigers = "sponsors_westsTigers",
				nrl = "sponsors_nrl",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 180,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 180,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Sydney,
		countryEnum = native.ECountry.Australia
	},
	leighSportsVillage = {
		commentary = "leighsportsvillage",
		sponsorType = "superLeague",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/leighSportsVillage/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				championTrophy = "sponsors_championTrophy",
				superLeagueWomens = "sponsors_superLeagueWomens",
				superLeague = "sponsors_superLeague",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 180,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 180,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Leigh,
		countryEnum = native.ECountry.England
	},
	melbourneRectangularStadium = {
		fieldFlipped = true,
		commentary = "aamipark",
		sponsorType = "nrl",
		duskDark = 0.65,
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/melbourneRectangularStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				storm = "sponsors_storm",
				nrl = "sponsors_nrl",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Melbourne,
		countryEnum = native.ECountry.Australia
	},
	moorePark = {
		commentary = "allianzstadium",
		sponsorType = "nrl",
		duskDark = 1.2,
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/moorePark/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				nrl = "sponsors_nrl",
				standard = "sponsors_standard",
				rlwcFemale = "sponsors_rlwc_female",
				roosters = "sponsors_roosters",
				rlwcMale = "sponsors_rlwc_male"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Sydney,
		countryEnum = native.ECountry.Australia
	},
	redcliffeStadium = {
		commentary = "kayostadium",
		sponsorType = "nrl",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/redcliffeStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				dolphins = "sponsors_dolphins",
				nrl = "sponsors_nrl",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Redcliffe,
		countryEnum = native.ECountry.Australia
	},
	mtSmartStadium = {
		commentary = "gomediastadium",
		sponsorType = "nrl",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/mtSmartStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				warriors = "sponsors_warriors",
				nrl = "sponsors_nrl",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Auckland,
		countryEnum = native.ECountry.NewZealand
	},
	townsvilleStadium = {
		commentary = "queenslandcountrybankstadium",
		sponsorType = "nrl",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/townsvilleStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				rlwcMale = "sponsors_rlwc_male",
				rlwcFemale = "sponsors_rlwc_female",
				nrl = "sponsors_nrl",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 180,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 180,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Townsville,
		countryEnum = native.ECountry.Australia
	},
	manchesterStadium = {
		commentary = "",
		sponsorType = "superLeague",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/manchesterStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				championTrophy = "sponsors_championTrophy",
				superLeagueWomens = "sponsors_superLeagueWomens",
				superLeague = "sponsors_superLeague",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 180,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 180,
				pos = {
					-4.610379267e-16,
					-3.75
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Manchester,
		countryEnum = native.ECountry.England
	},
	penrithStadium = {
		commentary = "bluebetstadium",
		sponsorType = "nrl",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/penrithStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Sydney,
		countryEnum = native.ECountry.Australia
	},
	perthRectangularStadium = {
		commentary = "hbfpark",
		sponsorType = "nrl",
		duskDark = 0.6,
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/perthRectangularStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				rlwcMale = "sponsors_rlwc_male",
				rlwcFemale = "sponsors_rlwc_female",
				nrl = "sponsors_nrl",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Perth,
		countryEnum = native.ECountry.Australia
	},
	perthStadium = {
		commentary = "optusstadium",
		sponsorType = "nrl",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/perthStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				sharks = "sponsors_sharks",
				nrl = "sponsors_nrl",
				rabbitohs = "sponsors_rabbitohs",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Perth,
		countryEnum = native.ECountry.Australia
	},
	robinaStadium = {
		commentary = "cbussuperstadium",
		sponsorType = "nrl",
		duskDark = 0.55,
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/robinaStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				rlwcMale = "sponsors_rlwc_male",
				rlwcFemale = "sponsors_rlwc_female",
				nrl = "sponsors_nrl",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 180,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 180,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.GoldCoast,
		countryEnum = native.ECountry.Australia
	},
	salfordCommunityStadium = {
		commentary = "salfordcommunitystadium",
		sponsorType = "superLeague",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/salfordCommunityStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				championTrophy = "sponsors_championTrophy",
				superLeagueWomens = "sponsors_superLeagueWomens",
				superLeague = "sponsors_superLeague",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Salford,
		countryEnum = native.ECountry.England
	},
	scg = {
		commentary = "scg",
		sponsorType = "nrl",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/scg/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				nrl = "sponsors_nrl",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Sydney,
		countryEnum = native.ECountry.Australia
	},
	perpignanStadium = {
		commentary = "stadegilbertbrutus",
		sponsorType = "superLeague",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/perpignanStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				championTrophy = "sponsors_championTrophy",
				superLeagueWomens = "sponsors_superLeagueWomens",
				superLeague = "sponsors_superLeague",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Perpignan,
		countryEnum = native.ECountry.France
	},
	stadiumAustralia = {
		fieldFlipped = true,
		commentary = "accorstadium",
		sponsorType = "nrl",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/stadiumAustralia/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				nrl = "sponsors_nrl",
				bulldogs = "sponsors_bulldogs",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				pos = {
					0,
					0
				},
				rot = -0
			},
			away = {
				pos = {
					0,
					0
				},
				rot = -0
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Sydney,
		countryEnum = native.ECountry.Australia
	},
	wakefieldStadium = {
		commentary = "thediykitchensstadium",
		sponsorType = "superLeague",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/wakefieldStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				championTrophy = "sponsors_championTrophy",
				superLeagueWomens = "sponsors_superLeagueWomens",
				superLeague = "sponsors_superLeague",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 180,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 180,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Wakefield,
		countryEnum = native.ECountry.England
	},
	parramattaStadium = {
		commentary = "commbankstadium",
		sponsorType = "nrl",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/parramattaStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				eels = "sponsors_eels",
				standard = "sponsors_standard",
				rlwcFemale = "sponsors_rlwc_female",
				nrl = "sponsors_nrl",
				rlwcMale = "sponsors_rlwc_male"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 180,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 180,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Sydney,
		countryEnum = native.ECountry.Australia
	},
	castlefordRugbyGround = {
		commentary = "mendahosejungle",
		sponsorType = "superLeague",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/castlefordRugbyGround/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				championTrophy = "sponsors_championTrophy",
				superLeagueWomens = "sponsors_superLeagueWomens",
				superLeague = "sponsors_superLeague",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 180,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 180,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Castleford,
		countryEnum = native.ECountry.England
	},
	wiganStadium = {
		commentary = "thebrickcommunitystadium",
		sponsorType = "superLeague",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/wiganStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				championTrophy = "sponsors_championTrophy",
				superLeagueWomens = "sponsors_superLeagueWomens",
				superLeague = "sponsors_superLeague",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Wigan,
		countryEnum = native.ECountry.England
	},
	wollongongShowground = {
		commentary = "winstadium",
		sponsorType = "nrl",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/wollongongShowground/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				rlwcFemale = "sponsors_rlwc_female",
				standard = "sponsors_standard",
				dragons = "sponsors_dragons",
				nrl = "sponsors_nrl",
				rlwcMale = "sponsors_rlwc_male"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 180,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 180,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = flipped_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Wollongong,
		countryEnum = native.ECountry.Australia
	},
	barrowRugbyStadium = {
		commentary = "northerncompetitionsstadium",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/barrowRugbyStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.BarrowInFurness,
		countryEnum = native.ECountry.England
	},
	batleyStadium = {
		commentary = "thefoxsbiscuitstadium",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/batleyStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Batley,
		countryEnum = native.ECountry.England
	},
	bradfordRugbyStadium = {
		commentary = "odsalstadium",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/bradfordRugbyStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = -180,
				pos = {
					-0.1762680219,
					0.6401840127
				}
			},
			away = {
				rot = -180,
				pos = {
					-0.3210946578,
					-5.2833796
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Bradford,
		countryEnum = native.ECountry.England
	},
	doncasterStadium = {
		commentary = "ecopowerstadium",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/doncasterStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 180,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 180,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Doncaster,
		countryEnum = native.ECountry.England
	},
	featherstoneRugbyStadium = {
		commentary = "principalitystadium",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/featherstoneRugbyStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Featherstone,
		countryEnum = native.ECountry.England
	},
	halifaxStadium = {
		commentary = "theshaystadium",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/halifaxStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Halifax,
		countryEnum = native.ECountry.England
	},
	southLeedsStadium = {
		commentary = "southleedsstadium",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/southLeedsStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Leeds,
		countryEnum = native.ECountry.England
	},
	oldhamStadium = {
		commentary = "vestacarestadium",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/oldhamStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Oldham,
		countryEnum = native.ECountry.England
	},
	sheffieldRugbyStadium = {
		commentary = "olympiclegacypark",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/sheffieldRugbyStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Sheffield,
		countryEnum = native.ECountry.England
	},
	toulouseStadium = {
		commentary = "stadeernestwallon",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/toulouseStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Toulouse,
		countryEnum = native.ECountry.France
	},
	widnesStadium = {
		commentary = "dcblstadium",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/widnesStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Widnes,
		countryEnum = native.ECountry.England
	},
	yorkStadium = {
		commentary = "lnercommunitystadium",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/yorkStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.York,
		countryEnum = native.ECountry.England
	},
	penrynRugbyGround = {
		commentary = "thememorialground",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/penrynRugbyGround/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Exeter,
		countryEnum = native.ECountry.England
	},
	dewsburyStadium = {
		commentary = "flairstadium",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/dewsburyStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Dewsbury,
		countryEnum = native.ECountry.England
	},
	gooleRugbyGround = {
		commentary = "goolerufc",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/gooleRugbyGround/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					-16,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					-16,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Goole,
		countryEnum = native.ECountry.England
	},
	keighleyStadium = {
		commentary = "cougarpark",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/keighleyStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Keighley,
		countryEnum = native.ECountry.England
	},
	birminghamRugbyStadium = {
		commentary = "alexanderstadium",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/birminghamRugbyStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Birmingham,
		countryEnum = native.ECountry.England
	},
	swalwellRugbyPark = {
		commentary = "blaydonrufc",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/swalwellRugbyPark/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.NewcastleUponTyne,
		countryEnum = native.ECountry.England
	},
	colwynBayStadium = {
		commentary = "stadiumcsm",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/colwynBayStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.ColwynBay,
		countryEnum = native.ECountry.Wales
	},
	rochdaleStadium = {
		commentary = "crownoilarena",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/rochdaleStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 180,
				pos = {
					5,
					0
				}
			},
			away = {
				rot = 180,
				pos = {
					5,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Rochdale,
		countryEnum = native.ECountry.England
	},
	saleRugbyStadium = {
		commentary = "salfordcommunitystadium",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/saleRugbyStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Sale,
		countryEnum = native.ECountry.England
	},
	whitehavenStadium = {
		commentary = "theortusrec",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/whitehavenStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 180,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 180,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Whitehaven,
		countryEnum = native.ECountry.England
	},
	workingtonRugbyStadium = {
		commentary = "fibruscommunitystadium",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/workingtonRugbyStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 180,
				pos = {
					4,
					0
				}
			},
			away = {
				rot = 180,
				pos = {
					4,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Workington,
		countryEnum = native.ECountry.England
	},
	marrickvilleRugbyPark = {
		commentary = "hensonpark",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/marrickvilleRugbyPark/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Sydney,
		countryEnum = native.ECountry.Australia
	},
	northSydneyOval = {
		commentary = "northsydneyoval",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/northSydneyOval/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Sydney,
		countryEnum = native.ECountry.Australia
	},
	kellyvilleMemorialPark = {
		commentary = "kellyvillepark",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/kellyvilleMemorialPark/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Sydney,
		countryEnum = native.ECountry.Australia
	},
	penrithReserve = {
		commentary = "",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/penrithReserve/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Sydney,
		countryEnum = native.ECountry.Australia
	},
	redfernOval = {
		commentary = "redfernoval",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/redfernOval/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Sydney,
		countryEnum = native.ECountry.Australia
	},
	blacktownSportingComplex = {
		commentary = "helaybuttsportingcomplex",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/blacktownSportingComplex/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Sydney,
		countryEnum = native.ECountry.Australia
	},
	stonesCornerRugbyPark = {
		commentary = "totallyworkwearstadium",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/stonesCornerRugbyPark/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Brisbane,
		countryEnum = native.ECountry.Australia
	},
	miamiRugbyPark = {
		commentary = "autonationsportsfield",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/miamiRugbyPark/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Brisbane,
		countryEnum = native.ECountry.Australia
	},
	rockhamptonRugbyStadium = {
		commentary = "rugbyparkrockhampton",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/rockhamptonRugbyStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Brisbane,
		countryEnum = native.ECountry.Australia
	},
	ipswichReserve = {
		commentary = "northipswichreserve",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/ipswichReserve/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Brisbane,
		countryEnum = native.ECountry.Australia
	},
	mackayStadium = {
		commentary = "bbprintstadium",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/mackayStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Brisbane,
		countryEnum = native.ECountry.Australia
	},
	cairnsRugbyPark = {
		commentary = "barlowpark",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/cairnsRugbyPark/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.GoldCoast,
		countryEnum = native.ECountry.Australia
	},
	nundahRugbyPark = {
		commentary = "bishoppark",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/nundahRugbyPark/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.GoldCoast,
		countryEnum = native.ECountry.Australia
	},
	portmoresbyStadium = {
		commentary = "santosnationalfootballstadium",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/portmoresbyStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				rlwcMale = "sponsors_rlwc_male",
				rlwcFemale = "sponsors_rlwc_female",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 180,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 180,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.PortMoresby,
		countryEnum = native.ECountry.PapuaNewGuinea
	},
	westEndRugbyPark = {
		commentary = "daviespark",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/westEndRugbyPark/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Brisbane,
		countryEnum = native.ECountry.Australia
	},
	bokarinaStadium = {
		commentary = "sunshinecoaststadium",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/bokarinaStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Brisbane,
		countryEnum = native.ECountry.Australia
	},
	kirwanOval = {
		commentary = "jackmanskioval",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/kirwanOval/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.GoldCoast,
		countryEnum = native.ECountry.Australia
	},
	tweedHeadsWestSportsComplex = {
		commentary = "piggabeensportscomplex",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/tweedHeadsWestSportsComplex/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Brisbane,
		countryEnum = native.ECountry.Australia
	},
	toowoombaSportsGround = {
		commentary = "toowoombasportsground",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/toowoombaSportsGround/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Sydney,
		countryEnum = native.ECountry.Australia
	},
	manlyWestOval = {
		commentary = "bmdkougarioval",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/manlyWestOval/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Sydney,
		countryEnum = native.ECountry.Australia
	},
	aucklandRugbyStadium = {
		commentary = "edenpark",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/aucklandRugbyStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Auckland,
		countryEnum = native.ECountry.NewZealand
	},
	waikatoStadium = {
		commentary = "fmgstadiumwaikato",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/waikatoStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Hamilton,
		countryEnum = native.ECountry.NewZealand
	},
	wellingtonRegionalStadium = {
		commentary = "skystadium",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/wellingtonRegionalStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Wellington,
		countryEnum = native.ECountry.NewZealand
	},
	christchurch_rugbyLeaguePark = {
		commentary = "apolloprojectsstadium",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/christchurch_rugbyLeaguePark/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				warriors = "sponsors_warriors",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Christchurch,
		countryEnum = native.ECountry.NewZealand
	},
	wembleyStadium = {
		commentary = "",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/wembleyStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				pos = {
					0,
					0
				},
				rot = -0
			},
			away = {
				pos = {
					0,
					4
				},
				rot = -0
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.London,
		countryEnum = native.ECountry.England
	},
	ploughLaneStadium = {
		commentary = "cherryredrecordsstadium",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/ploughLaneStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 180,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 180,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = north_offset_northern_hemisphere,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.London,
		countryEnum = native.ECountry.England
	},
	marraraOval = {
		commentary = "tiostadium",
		sponsorType = "nrl",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/marraraOval/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				nrl = "sponsors_nrl",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Darwin,
		countryEnum = native.ECountry.Australia
	},
	bathurstStadium = {
		commentary = "carringtonpark",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/bathurstStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					5,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					5,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Bathurst,
		countryEnum = native.ECountry.Australia
	},
	glenwillSportsStadium = {
		commentary = "glenwillowoval",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/glenwillSportsStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Mudgee,
		countryEnum = native.ECountry.Australia
	},
	industreeGroupStadium = {
		commentary = "industreegroupstadium",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/industreeGroupStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Gosford,
		countryEnum = native.ECountry.Australia
	},
	stadeErnestWallon = {
		commentary = "stadeernestwallon",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/stadeErnestWallon/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Toulouse,
		countryEnum = native.ECountry.Francce
	},
	hillDickinsonStadium = {
		commentary = "",
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/hillDickinsonStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		dawnDark = default_dawn_dark_threshold,
		duskDark = default_dusk_dark_threshold,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Sydney,
		countryEnum = native.ECountry.Australia
	},
	christchurch_teKahaStadium = {
		dawnDark = 3,
		fieldFlipped = true,
		isIndoors = true,
		commentary = "",
		sponsorType = "nrl",
		duskDark = 3,
		grassType = "grass_lush_col",
		ModelCfg = {
			basePath = "stadiums/christchurch_teKahaStadium/",
			models = standardModels,
			additionalModels = standardAdditionalModels,
			sponsorHoardingModels = {
				warriors = "sponsors_warriors",
				rlwcFemale = "sponsors_rlwc_female",
				rlwcMale = "sponsors_rlwc_male",
				standard = "sponsors_standard"
			}
		},
		cutsceneOffset = {
			home = {
				rot = 0,
				pos = {
					0,
					0
				}
			},
			away = {
				rot = 0,
				pos = {
					0,
					0
				}
			}
		},
		northOffset = default_north_offset,
		fogParams = outdoor_fog_params,
		PostFxID = standardFxID,
		GrassConfigID = standardGrassID,
		GrassDimensions = {
			minZ = -38,
			maxX = 63,
			maxZ = 38,
			minX = -63,
			fadeRadius = 1
		},
		AppendConfig = standardAppendConfig,
		dynamicenv_lighting = default_dynamicenv_lighting,
		locationEnum = native.ECities.Christchurch,
		countryEnum = native.ECountry.NewZealand
	}
}
