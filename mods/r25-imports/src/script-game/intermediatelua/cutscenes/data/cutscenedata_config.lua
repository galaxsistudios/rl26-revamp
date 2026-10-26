import("intermediatelua.cutscenes.data.cutscenegroupdata_config")

GroupList = cutscenegroupdata_config.GroupList

-- Rugby 25 imports (tools/r25_import.py): appended to the stock groups at load time.
local var_0_r25Groups = {
	TryCelebrateStanding = {
		{ name = "r25_TryCelebrate_roll_hug", weight = 2 },
		{ name = "r25_TryCelebrate_intense_slide_yell", weight = 2 },
		{ name = "r25_TryCelebrate_ball_throw_group", weight = 2 },
		{ name = "r25_TryCelebrate_ball_throw_hug_group", weight = 2 },
		{ name = "r25_TryCelebrate24_01", weight = 1 },
		{ name = "r25_TryCelebrate24_02", weight = 1 },
		{ name = "r25_TryCelebrate24_03", weight = 1 },
		{ name = "r25_TryCelebrate24_03b", weight = 1 },
		{ name = "r25_TryCelebrate24_04", weight = 1 },
		{ name = "r25_TryCelebrate24_06", weight = 1 },
		{ name = "r25_TryCelebrate24_07", weight = 1 },
		{ name = "r25_TryCelebrate24_08", weight = 1 },
		{ name = "r25_TryCelebrate24_09", weight = 1 },
		{ name = "r25_TryCelebrate24_10", weight = 1 },
		{ name = "r25_TryCelebrate24_11", weight = 1 },
		{ name = "r25_TryCelebrate24_12", weight = 1 },
		{ name = "r25_TryCelebrate24_12b", weight = 1 },
		{ name = "r25_TryCelebrate24_13", weight = 1 },
		{ name = "r25_TryCelebrate24_14", weight = 1 },
		{ name = "r25_TryCelebrate24_15", weight = 1 },
		{ name = "r25_TryCelebrate24_16", weight = 1 },
		{ name = "r25_TryCelebrate24_16b", weight = 1 },
		{ name = "r25_TryCelebrate24_17", weight = 1 },
		{ name = "r25_TryCelebrate24_17b", weight = 1 },
		{ name = "r25_TryCelebrate24_18", weight = 1 },
		{ name = "r25_TryCelebrate24_20", weight = 1 },
		{ name = "r25_TryCelebrate24_23", weight = 1 },
		{ name = "r25_TryCelebrate24_24", weight = 1 },
		{ name = "r25_TryCelebrate24_26", weight = 1 },
	},
	TryCelebrateStanding_low = {
		{ name = "r25_TryCelebrate_roll_hug", weight = 2 },
		{ name = "r25_TryCelebrate_intense_slide_yell", weight = 2 },
		{ name = "r25_TryCelebrate_ball_throw_group", weight = 2 },
		{ name = "r25_TryCelebrate_ball_throw_hug_group", weight = 2 },
		{ name = "r25_TryCelebrate24_03", weight = 1 },
		{ name = "r25_TryCelebrate24_03b", weight = 1 },
		{ name = "r25_TryCelebrate24_16", weight = 1 },
		{ name = "r25_TryCelebrate24_16b", weight = 1 },
		{ name = "r25_TryCelebrate24_20", weight = 1 },
		{ name = "r25_TryCelebrate24_23", weight = 1 },
		{ name = "r25_TryCelebrate24_24", weight = 1 },
		{ name = "r25_TryCelebrate24_26", weight = 1 },
	},
	TryCelebrateStanding_high = {
		{ name = "r25_TryCelebrate_roll_hug", weight = 2 },
		{ name = "r25_TryCelebrate_intense_slide_yell", weight = 2 },
		{ name = "r25_TryCelebrate_ball_throw_group", weight = 2 },
		{ name = "r25_TryCelebrate_ball_throw_hug_group", weight = 2 },
		{ name = "r25_TryCelebrate24_01", weight = 1 },
		{ name = "r25_TryCelebrate24_04", weight = 1 },
		{ name = "r25_TryCelebrate24_06", weight = 1 },
		{ name = "r25_TryCelebrate24_07", weight = 1 },
		{ name = "r25_TryCelebrate24_08", weight = 1 },
		{ name = "r25_TryCelebrate24_09", weight = 1 },
		{ name = "r25_TryCelebrate24_15", weight = 1 },
	},
	TryCelebrateGround = {
		{ name = "r25_TryCelebrate_roll_hug", weight = 2 },
		{ name = "r25_TryCelebrate_intense_slide_yell", weight = 2 },
		{ name = "r25_TryCelebrate_ball_throw_group", weight = 2 },
		{ name = "r25_TryCelebrate_ball_throw_hug_group", weight = 2 },
		{ name = "r25_TryCelebrate24_05", weight = 1 },
		{ name = "r25_TryCelebrate24_19", weight = 1 },
		{ name = "r25_TryCelebrate24_21", weight = 1 },
		{ name = "r25_TryCelebrate24_22", weight = 1 },
		{ name = "r25_TryCelebrate24_25", weight = 1 },
	},
	TryCelebrateGround_low = {
		{ name = "r25_TryCelebrate_roll_hug", weight = 2 },
		{ name = "r25_TryCelebrate_intense_slide_yell", weight = 2 },
		{ name = "r25_TryCelebrate_ball_throw_group", weight = 2 },
		{ name = "r25_TryCelebrate_ball_throw_hug_group", weight = 2 },
		{ name = "r25_TryCelebrate24_19", weight = 1 },
		{ name = "r25_TryCelebrate24_21", weight = 1 },
		{ name = "r25_TryCelebrate24_22", weight = 1 },
		{ name = "r25_TryCelebrate24_25", weight = 1 },
	},
	TryCelebrateGround_high = {
		{ name = "r25_TryCelebrate_roll_hug", weight = 2 },
		{ name = "r25_TryCelebrate_intense_slide_yell", weight = 2 },
		{ name = "r25_TryCelebrate_ball_throw_group", weight = 2 },
		{ name = "r25_TryCelebrate_ball_throw_hug_group", weight = 2 },
		{ name = "r25_TryCelebrate24_05", weight = 1 },
	},
	Conversion_Success = {
		{ name = "r25_Post_Conversion_01", weight = 1 },
		{ name = "r25_Post_Conversion_02", weight = 1 },
		{ name = "r25_Conversion_T_success_r24_01", weight = 1 },
	},
	Conversion_Success_NoTee = {
		{ name = "r25_Post_Conversion_01", weight = 1 },
		{ name = "r25_Post_Conversion_02", weight = 1 },
		{ name = "r25_Conversion_T_success_r24_01", weight = 1 },
	},
	Conversion_Fail = {
		{ name = "r25_Post_Conversion_03", weight = 1 },
	},
	Conversion_Fail_NoTee = {
		{ name = "r25_Post_Conversion_03", weight = 1 },
	},
	rl1_corridor_home_02 = {
		{ name = "rl1_corridor_home_02", weight = 2 },
		{ name = "r25_IntroCorridorWalkTeam_02", weight = 1 },
		{ name = "r25_IntroCorridorWalkTeam_01", weight = 1 },
	},
	PenaltyTalkCaptain = {
		{ name = "r25_RefereePenalty_01", weight = 1 },
		{ name = "r25_RefereePenalty_03", weight = 1 },
	},
	PenaltyTalkSolo = {
		{ name = "r25_RefereePenalty_02", weight = 1 },
		{ name = "r25_RefereePenalty_04", weight = 1 },
	},
	FortyTwentyCelebrate = {
		{ name = "r25_FiftyTwentyTwo_02", weight = 1 },
		{ name = "r25_FiftyTwentyTwo_03", weight = 1 },
	},
	PostReplay = {
		{ name = "r25_PostReplayScorerWalksBack_01", weight = 1 },
		{ name = "r25_PostReplayTeamHuddle_01", weight = 1 },
	},
	FullTime = {
		{ name = "r25_FulltimeWinLose_01", weight = 1 },
		{ name = "r25_FulltimeWinLose_02", weight = 1 },
		{ name = "r25_FulltimeWinLose_03", weight = 1 },
		{ name = "r25_FulltimeWinLose_04", weight = 1 },
		{ name = "r25_FulltimeWinLose_05", weight = 1 },
		{ name = "r25_FulltimeWinLose_06", weight = 1 },
		{ name = "r25_FulltimeWinLose_07", weight = 1 },
		{ name = "r25_Handshakes_01", weight = 1 },
		{ name = "r25_Handshakes_02", weight = 1 },
		{ name = "r25_Handshakes_03", weight = 1 },
		{ name = "r25_Handshakes_04", weight = 1 },
		{ name = "r25_Handshakes_05", weight = 1 },
		{ name = "r25_Handshakes_06", weight = 1 },
		{ name = "r25_Handshakes_07", weight = 1 },
		{ name = "r25_Handshakes_08", weight = 1 },
	},
}

local var_0_r25TestMode = false
-- groups whose stock entries an import replaces (imports.json "exclusive")
local var_0_r25Exclusive = { }

for iter_0_r25Group, iter_0_r25Entries in pairs(var_0_r25Groups) do
	-- test mode: the imports become the only choices in their groups
	if var_0_r25TestMode or var_0_r25Exclusive[iter_0_r25Group] or not GroupList[iter_0_r25Group] then
		GroupList[iter_0_r25Group] = {}
	end

	for iter_0_r25Index, iter_0_r25Entry in ipairs(iter_0_r25Entries) do
		table.insert(GroupList[iter_0_r25Group], iter_0_r25Entry)
	end
end

local var_0_0 = {
	"intermediatelua.cutscenes.data.cs_test_cutscene_data",
	"intermediatelua.cutscenes.data.cs_intro_generic_data",
	"intermediatelua.cutscenes.data.cs_intro_finals_data",
	"intermediatelua.cutscenes.data.cs_intro_grandfinals_data",
	"intermediatelua.cutscenes.data.cs_intro_anthem_data",
	"intermediatelua.cutscenes.data.cs_halftime_data",
	"intermediatelua.cutscenes.data.cs_fulltime_data",
	"intermediatelua.cutscenes.data.cs_fulltime_grandfinals_data",
	"intermediatelua.cutscenes.data.cs_champions_data",
	"intermediatelua.cutscenes.data.cs_try_celebrate_data",
	"intermediatelua.cutscenes.data.cs_conversion_data",
	"intermediatelua.cutscenes.data.cs_sendoff_data",
	"intermediatelua.cutscenes.data.cs_sinbin_data",
	"intermediatelua.cutscenes.data.cs_injury_data",
	"intermediatelua.cutscenes.data.cs_trailer_data",
	"intermediatelua.cutscenes.data.cs_cheerleader_data",
	"intermediatelua.cutscenes.data.cs_rll4_misc_data",
	"intermediatelua.cutscenes.data.cs_teamshield_data",
	"intermediatelua.cutscenes.data.cs_screenshot_data",
	"intermediatelua.cutscenes.data.cs_corridor_data",
	"intermediatelua.cutscenes.data.cs_lockerroom_data",
	"intermediatelua.cutscenes.data.cs_stadium_team_logos",
	"intermediatelua.cutscenes.data.cs_trophy_data",
	"intermediatelua.cutscenes.data.cs_proteam_screenshots",
	"intermediatelua.cutscenes.data.cs_storm_promo"
}

MappedNamesToFiles = {}

for iter_0_0, iter_0_1 in ipairs(var_0_0) do
	local var_0_1 = loadTemp(iter_0_1, false)
	local var_0_2 = VERIFY(var_0_1.CutsceneData)

	for iter_0_2, iter_0_3 in pairs(var_0_2) do
		MappedNamesToFiles[iter_0_2] = iter_0_1
	end
end

SequenceList = {
	Champions = {
		cutscenes = {
			"rl1_fulltime_gf_01",
			"rl1_fulltime_gf_stadium",
			"rl1_fulltime_gf_02",
			"rl1_fulltime_gf_03",
			"rl1_trophy_01{CompetitionName}{StadiumName}",
			"rl1_trophy_02{CompetitionName}{StadiumName}"
		}
	},
	gf_intro_NRL = {
		cutscenes = {
			"rl1_gf_stadium_wide_cam01{CompetitionName}{StadiumName}",
			"rl1_intro_lockers_away{StadiumName}",
			"rl1_intro_lockers_home{StadiumName}",
			"rl1_gf_stadium_trophy_cam05{CompetitionName}{StadiumName}",
			"rl1_corridor_away{CompetitionName}{StadiumName}",
			"rl1_gf_stadium_crowd_away_cam04{StadiumName}",
			"rl1_intro_gf_away_team_01{CompetitionName}{StadiumName}",
			"rl1_corridor_home{CompetitionName}{StadiumName}",
			"rl1_gf_stadium_crowd_home_cam07{StadiumName}",
			"rl1_intro_gf_home_team_01{CompetitionName}{StadiumName}",
			"rl1_gf_national_anthem{StadiumName}"
		}
	},
	gf_intro_SuperLeague = {
		cutscenes = {
			"rl1_gf_stadium_wide_cam01{CompetitionName}{StadiumName}",
			"rl1_intro_lockers_away{StadiumName}",
			"rl1_intro_lockers_home{StadiumName}",
			"rl1_gf_stadium_trophy_cam05{CompetitionName}{StadiumName}",
			"rl1_gf_corridor_home_away{CompetitionName}{StadiumName}",
			"rl1_intro_gf_home_away_team_01{CompetitionName}{StadiumName}",
			"rl1_gf_stadium_crowd_home_cam07{StadiumName}",
			"rl1_gf_national_anthem{StadiumName}"
		}
	},
	gf_intro_NRL_noanthem = {
		cutscenes = {
			"rl1_gf_stadium_wide_cam01{CompetitionName}{StadiumName}",
			"rl1_intro_lockers_away{StadiumName}",
			"rl1_intro_lockers_home{StadiumName}",
			"rl1_gf_stadium_trophy_cam05{CompetitionName}{StadiumName}",
			"rl1_corridor_away{CompetitionName}{StadiumName}",
			"rl1_gf_stadium_crowd_away_cam04{StadiumName}",
			"rl1_intro_gf_away_team_01{CompetitionName}{StadiumName}",
			"rl1_corridor_home{CompetitionName}{StadiumName}",
			"rl1_gf_stadium_crowd_home_cam07{StadiumName}",
			"rl1_intro_gf_home_team_01{CompetitionName}{StadiumName}"
		}
	},
	gf_intro_SuperLeague_noanthem = {
		cutscenes = {
			"rl1_gf_stadium_wide_cam01{CompetitionName}{StadiumName}",
			"rl1_intro_lockers_away{StadiumName}",
			"rl1_intro_lockers_home{StadiumName}",
			"rl1_gf_stadium_trophy_cam05{CompetitionName}{StadiumName}",
			"rl1_gf_corridor_home_away{CompetitionName}{StadiumName}",
			"rl1_intro_gf_home_away_team_01{CompetitionName}{StadiumName}",
			"rl1_gf_stadium_crowd_home_cam07{StadiumName}"
		}
	},
	finals_intro = {
		cutscenes = {
			"rl1_stadium_wide_cam02{StadiumName}",
			"rl1_intro_lockers_away{StadiumName}",
			"rl1_intro_lockers_home{StadiumName}",
			"rl1_stadium_crowd_away_cam04{StadiumName}",
			"rl1_intro_finals_away_team_01{StadiumName}",
			"rl1_stadium_crowd_home_cam07{StadiumName}",
			"rl1_intro_finals_home_team_01{StadiumName}"
		}
	},
	finals_intro_anthem = {
		cutscenes = {
			"rl1_stadium_wide_cam02{StadiumName}",
			"rl1_intro_lockers_away{StadiumName}",
			"rl1_intro_lockers_home{StadiumName}",
			"rl1_stadium_crowd_away_cam04{StadiumName}",
			"rl1_intro_finals_away_team_01{StadiumName}",
			"rl1_stadium_crowd_home_cam07{StadiumName}",
			"rl1_intro_finals_home_team_01{StadiumName}",
			"rl1_gf_national_anthem{StadiumName}"
		}
	},
	home_is_kickoff_intro = {
		cutscenes = {
			"rl1_intro_lockers_home_02{StadiumName}",
			"rl1_intro_lockers_away_02{StadiumName}",
			"IntroAwayTeam",
			"rl1_corridor_home_02{StadiumName}",
			"rl1_intro_stadium_crowd_cam12{StadiumName}",
			"IntroHomeTeamReceiving"
		}
	},
	away_is_kickoff_intro = {
		cutscenes = {
			"rl1_intro_lockers_home_02{StadiumName}",
			"rl1_intro_lockers_away_02{StadiumName}",
			"IntroAwayTeam",
			"rl1_corridor_home_02{StadiumName}",
			"rl1_intro_stadium_crowd_cam12{StadiumName}",
			"IntroHomeTeamKickOff"
		}
	},
	home_is_kickoff_intro_anthem = {
		cutscenes = {
			"rl1_intro_lockers_home_02{StadiumName}",
			"rl1_intro_lockers_away_02{StadiumName}",
			"IntroAwayTeam",
			"rl1_corridor_home_02{StadiumName}",
			"rl1_intro_stadium_crowd_cam12{StadiumName}",
			"IntroHomeTeamReceiving",
			"rl1_gf_national_anthem{StadiumName}"
		}
	},
	away_is_kickoff_intro_anthem = {
		cutscenes = {
			"rl1_intro_lockers_home_02{StadiumName}",
			"rl1_intro_lockers_away_02{StadiumName}",
			"IntroAwayTeam",
			"rl1_corridor_home_02{StadiumName}",
			"rl1_intro_stadium_crowd_cam12{StadiumName}",
			"IntroHomeTeamKickOff",
			"rl1_gf_national_anthem{StadiumName}"
		}
	}
}

-- Rugby 25 intro sequence alternatives (imports.json introSequences, tools/r25_import.py).
-- match-intro-versus (getInitialCutsceneName) picks one per match from the match seed.
local var_0_r25IntroSequences = {
	{
		name = "r25_runout",
		weight = 1,
		before = "rl1_gf_national_anthem{StadiumName}",
		cutscene = "r25_IntroStandardTwoTeams_01",
		drop = {
			IntroAwayTeam = true,
			IntroHomeTeamKickOff = true,
			IntroHomeTeamReceiving = true
		},
		sequences = {
			"home_is_kickoff_intro",
			"away_is_kickoff_intro",
			"home_is_kickoff_intro_anthem",
			"away_is_kickoff_intro_anthem"
		},
		stockWeight = 3
	}
}

SequenceAlternatives = SequenceAlternatives or {}

for iter_0_r25Index, iter_0_r25Spec in ipairs(var_0_r25IntroSequences) do
	for iter_0_r25Seq, iter_0_r25Base in ipairs(iter_0_r25Spec.sequences) do
		local var_0_r25Stock = SequenceList[iter_0_r25Base]

		if var_0_r25Stock and var_0_r25Stock.cutscenes then
			local var_0_r25List = {}
			local var_0_r25Inserted = false

			for iter_0_r25C, iter_0_r25Name in ipairs(var_0_r25Stock.cutscenes) do
				if iter_0_r25Name == iter_0_r25Spec.before and not var_0_r25Inserted then
					table.insert(var_0_r25List, iter_0_r25Spec.cutscene)

					var_0_r25Inserted = true
				end

				if not iter_0_r25Spec.drop[iter_0_r25Name] then
					table.insert(var_0_r25List, iter_0_r25Name)
				end
			end

			if not var_0_r25Inserted then
				table.insert(var_0_r25List, iter_0_r25Spec.cutscene)
			end

			local var_0_r25Name = iter_0_r25Spec.name .. "_" .. iter_0_r25Base

			SequenceList[var_0_r25Name] = {
				cutscenes = var_0_r25List,
				lightingScenes = var_0_r25Stock.lightingScenes
			}

			if not SequenceAlternatives[iter_0_r25Base] then
				SequenceAlternatives[iter_0_r25Base] = {
					{
						name = iter_0_r25Base,
						weight = iter_0_r25Spec.stockWeight
					}
				}
			end

			table.insert(SequenceAlternatives[iter_0_r25Base], {
				name = var_0_r25Name,
				weight = iter_0_r25Spec.weight
			})
		end
	end
end
