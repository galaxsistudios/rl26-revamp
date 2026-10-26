import("app.casual.casual")
import("app.casual.casual_newmatch")
import("app.practice.practice_state")
import("app.competition.competitionstate")
import("app.competition.competition_neworload_new")
import("app.competition.competition_neworload_load")
import("app.metagamemode.metagamemode_neworload_list_manage")
import("app.career.careerstate")
import("app.online.online_state")
import("app.online.online_quickmatch_state")
import("app.online.online_custommatch_state")
import("app.online.online_leaderboard_state")
import("app.online.online_controllerselect_state")
import("app.settings.settings_state")
import("app.settings.settings_audio_state")
import("app.settings.settings_changeprimaryuser")
import("app.settings.settings_controls_state")
import("app.settings.settings_credits_state")
import("app.settings.settings_gameplaymodifiers_state")
import("app.settings.settings_gameplaysliders_state")
import("app.settings.settings_general_state")
import("app.settings.settings_userstatistics_state")
import("app.academy.resetacademy_state")
import("app.settings.settings_mynacon_viewagreement_state")
import("app.academy.academy_state")
import("app.academy.academy_community_state")
import("app.academy.academy_communitystate_quickcodes_state")
import("app.academy.academy_player_hub_state")
import("app.academy.academy_player_edit_state")
import("app.academy.academy_player_delete_state")
import("app.academy.academyplayercreateethnicity_state")
import("app.academy.academy_club_hub_state")
import("app.academy.academy_club_createcustom_state")
import("app.academy.academy_club_edit_state")
import("app.academy.academy_club_delete_state")
import("app.academy.customdifficulty_state")
import("app.academy.matchtypedesignertypeselection_state")
import("app.academy.academy_referee_hub")
import("app.academy.academy_referee_hub_delete")
import("app.academy.academy_referee_hub_edit")
import("app.academy.academyrefereecreateethnicity_state")
import("app.academy.academy_league_hub")
import("app.academy.academy_league_hub_create")
import("app.academy.academy_league_hub_delete")
import("app.academy.academy_league_hub_edit")
import("app.decal.decal_state")
import("app.decal.decal_create")
import("app.decal.decal_edit")
import("app.level.level_state")
import("app.level.level_create")
import("app.level.level_edit")
import("intermediatelua.convant.uitextures")
import("app.competition.competitionstate_hub")
import("app.dynasty.dynasty_state")
import("app.uitest.uitest_nathan_commstasks")
import("app.noesis.noesisteststate_hub")

local var_0_0 = native.EClubLineupCategory.LeagueMatch
local var_0_1 = native.EClubLineupCategory.NinesMatch
local var_0_2 = native.getEnvironment()
local var_0_3 = var_0_2:argExists("proteam")
local var_0_4 = var_0_2:argExists("debugDynasty")
local var_0_5 = var_0_2:argExists("noesisTest")
local var_0_6 = {
	casual = native.Localise("Homescreen_Casual_Title"),
	finals = native.Localise("Homescreen_Finals_Title"),
	playAsClubMens = native.Localise("PlayAsClubMens"),
	playAsClubWomens = native.Localise("PlayAsClubWomens"),
	playAsPlayerMens = native.Localise("PlayAsPlayerMens"),
	playAsPlayerWomens = native.Localise("PlayAsPlayerWomens"),
	playAsMensGrandFinal = native.Localise("MensGrandFinal"),
	playAsWomensGrandFinal = native.Localise("WoemensGrandFinal"),
	playAsMensSooDecider = native.Localise("MensOriginDecider"),
	playAsWomensSooDecider = native.Localise("WomensOriginDecider"),
	online = native.Localise("Online"),
	career = native.Localise("Career"),
	proTeam = native.Localise("ProTeam"),
	competition = native.Localise("Competition"),
	academy = native.Localise("Academy"),
	settings = native.Localise("Settings"),
	practice = native.Localise("Practice"),
	designer = native.Localise("Designer"),
	resume = native.Localise("Resume"),
	worldcup = native.Localise("WorldCup"),
	community = native.Localise("Community"),
	NewRLWC2026Competition = native.Localise("PlayMensRLWC2026"),
	NewRLWC2026WomensCompetition = native.Localise("PlayWomensRLWC2026"),
	RLWCCompetitions = native.Localise("RLWC2026"),
	NrlMatch = native.Localise("NrlMatch"),
	Womens13s = native.Localise("Womens13s"),
	Womens9s = native.Localise("Womens9s"),
	SuperLeagueMatch = native.Localise("SuperLeagueMatch"),
	GrandFinalMatch = native.Localise("GrandFinalMatch"),
	NinesMatchMatch = native.Localise("NinesMatchMatch"),
	StateOfOriginMatch = native.Localise("StateOfOriginMatch"),
	NrlWMatch = native.Localise("NRLWMatch"),
	WslMatch = native.Localise("WSLMatch"),
	NrlCompetition = native.Localise("NRLCompetition"),
	SuperLegueCompetition = native.Localise("SuperLeagueCompetition"),
	NrlWCompetition = native.Localise("NRLWCompetition"),
	WslCompetition = native.Localise("WSLCompetition"),
	QuickMatch = native.Localise("QuickMatch"),
	CustomMatch = native.Localise("CustomMatch"),
	Leaderboards = native.Localise("Leaderboards"),
	NewCompetition = native.Localise("NewCompetition"),
	NewCareer = native.Localise("CareerNew"),
	DeleteCompetition = native.Localise("DeleteCompetition"),
	ManageCompetition = native.Localise("ManageCompetition"),
	ManageCareer = native.Localise("ManageCareer"),
	GeneralSettings = native.Localise("GeneralSettings"),
	AudioSettings = native.Localise("AudioSettings"),
	ControlsSettings = native.Localise("Controls"),
	SharingSettings = native.Localise("SharingSettings"),
	GameplayModifiersSettings = native.Localise("GameplayModifiersSettings"),
	GameplaySlidersSettings = native.Localise("GameplaySlidersSettings"),
	StatisticsSettings = native.Localise("StatisticsSettings"),
	CreditsSettings = native.Localise("CreditsSettings"),
	ChangePrimaryUser = native.Localise("ChangePrimaryUser"),
	SharingSetupAccount = native.Localise("SharingSetupAccount"),
	UserStatistics = native.Localise("UserStatistics"),
	Credits = native.Localise("Credits"),
	ResetAcademy = native.Localise("ResetAcademy"),
	MyNaconAgreements = native.Localise("MyNaconAgreements"),
	Players = native.Localise("Players"),
	AllPlayers = native.Localise("AllPlayers"),
	CreateMalePlayer = native.Localise("CreateMalePlayer"),
	CreateFemalePlayer = native.Localise("CreateFemalePlayer"),
	DeletePlayer = native.Localise("DeletePlayer"),
	Clubs = native.Localise("Clubs"),
	ClubManager = native.Localise("ClubManager"),
	CreateCustomMensClub = native.Localise("CreateCustomMensClub"),
	CreateCustomWomensClub = native.Localise("CreateCustomWomensClub"),
	DeleteClub = native.Localise("DeleteClub"),
	Umpires = native.Localise("Umpires"),
	EditReferee = native.Localise("EditReferee"),
	CreateRefereeMan = native.Localise("CreateRefereeMan"),
	CreateRefereeWoman = native.Localise("CreateRefereeWoman"),
	DeleteReferee = native.Localise("DeleteReferee"),
	SearchCommunity = native.Localise("SearchCommunity"),
	QuickCodes = native.Localise("QuickCodes"),
	Decals = native.Localise("Decals"),
	CreateDecal = native.Localise("CreateDecal"),
	EditDecal = native.Localise("EditDecal"),
	Levels = native.Localise("Levels"),
	CreateLevel = native.Localise("CreateLevel"),
	CreateLevelFromTemplate = native.Localise("CreateLevelFromTemplate"),
	EditLevel = native.Localise("EditLevel"),
	DeleteLevel = native.Localise("DeleteLevel"),
	Leagues = native.Localise("Leagues"),
	CreateLeague = native.Localise("CreateLeague"),
	DeleteLeague = native.Localise("DeleteLeague"),
	EditLeague = native.Localise("EditLeague")
}
local var_0_7 = {
	casual = native.Localise("CasualDescription"),
	finals = native.Localise("FinalsDescription"),
	online = native.Localise("OnlineDescription"),
	career = native.Localise("CareerDescription"),
	proTeam = native.Localise("ProteamDescription"),
	competition = native.Localise("CompetitionDescription"),
	NRLCompetition = native.Localise("NRLCompetitionDescription"),
	SuperLeagueCompetition = native.Localise("SuperLeagueCompetitionDescription"),
	NRLWCompetition = native.Localise("NRLWCompetitionDescription"),
	WSLCompetition = native.Localise("WSLCompetitionDescription"),
	academy = native.Localise("AcademyDataDescription"),
	settings = native.Localise("SettingsDescription"),
	practice = native.Localise("PracticeDescription"),
	designer = native.Localise("DesignerDescription"),
	resume = native.Localise("ContinueMostRecentTypeDescription"),
	worldcup = native.Localise("WorldCupDescription"),
	community = native.Localise("CommunityDescription"),
	NewRLWC2026Competition = native.Localise("MensRLWC2026Description"),
	NewRLWC2026WomensCompetition = native.Localise("WomensRLWC2026Description"),
	RLWCCompetitions = native.Localise("RLWC2026Description")
}
local var_0_8 = {
	{
		title = var_0_6.playAsClubMens,
		stateData = {
			nextState = casual_newmatch.CasualNewState,
			sex = native.CSex.Male,
			lineupCategory = var_0_0
		}
	},
	{
		title = var_0_6.playAsClubWomens,
		stateData = {
			nextState = casual_newmatch.CasualNewState,
			sex = native.CSex.Female,
			lineupCategory = var_0_0
		}
	},
	{
		title = var_0_6.playAsPlayerMens,
		stateData = {
			beAPro = true,
			nextState = casual_newmatch.CasualNewState,
			sex = native.CSex.Male,
			lineupCategory = var_0_0
		}
	},
	{
		title = var_0_6.playAsPlayerWomens,
		stateData = {
			beAPro = true,
			nextState = casual_newmatch.CasualNewState,
			sex = native.CSex.Female,
			lineupCategory = var_0_0
		}
	}
}
local var_0_9 = {
	autoNavKey = "casual",
	dataContextKey = "Casual",
	customSound = "front_end_play_now",
	image = "casual",
	title = var_0_6.casual,
	description = var_0_7.casual,
	stateFactory = casual.CasualState,
	subMenu = var_0_8
}
local var_0_10 = {
	{
		dataContextKey = "RLWC2026",
		new = true,
		competition = true,
		title = var_0_6.NewRLWC2026Competition,
		stateData = {
			nextState = competition_neworload_new.CompetitionNew,
			stateData = native.CareerCompetitionIdEnum.Tournament_RLWC2026Men
		}
	},
	{
		dataContextKey = "RLWC2026",
		new = true,
		competition = true,
		title = var_0_6.NewRLWC2026WomensCompetition,
		stateData = {
			nextState = competition_neworload_new.CompetitionNew,
			stateData = native.CareerCompetitionIdEnum.Tournament_RLWC2026Women
		}
	},
	{
		locked = true,
		title = var_0_6.ManageCompetition,
		stateData = {
			nextState = metagamemode_neworload_list_manage.MetagameModeNewOrLoadListManage
		}
	}
}
local var_0_11 = {
	autoNavKey = "RLWC2026",
	customSound = "front_end_competitions",
	image = "competition",
	dataContextKey = "RLWC2026",
	title = var_0_6.RLWCCompetitions,
	competitionId = native.CareerCompetitionIdEnum.Tournament_RLWC2026Men,
	competitionIdWomens = native.CareerCompetitionIdEnum.Tournament_RLWC2026Women,
	loadState = competition_neworload_load.CompetitionNewOrLoadLoad,
	description = var_0_7.RLWCCompetitions,
	stateFactory = competitionstate.CompetitionState,
	scanTasksOnSubmenuOpen = {
		"Competition"
	},
	subMenu = var_0_10
}
local var_0_12 = {
	{
		title = var_0_6.playAsMensGrandFinal,
		stateData = {
			ground = "stadiumAustralia",
			isGrandFinal = true,
			nextState = casual_newmatch.CasualNewState,
			sex = native.CSex.Male,
			lineupCategory = var_0_0,
			trophyId = native.ETrophy.NRL,
			matchSettingsOverrides = {
				timeOfDay = native.MatchSettingsTimeOfDay.night
			},
			clubInfoMap = {
				home = {
					clubId = 130,
					uniformCategory = native.CClubUniformCategory.Home
				},
				away = {
					clubId = 118,
					uniformCategory = native.CClubUniformCategory.Away
				}
			}
		}
	},
	{
		title = var_0_6.playAsWomensGrandFinal,
		stateData = {
			ground = "stadiumAustralia",
			isGrandFinal = true,
			nextState = casual_newmatch.CasualNewState,
			sex = native.CSex.Female,
			lineupCategory = var_0_0,
			trophyId = native.ETrophy.NRLW,
			matchSettingsOverrides = {
				timeOfDay = native.MatchSettingsTimeOfDay.afternoon
			},
			clubInfoMap = {
				home = {
					clubId = 194,
					uniformCategory = native.CClubUniformCategory.Home
				},
				away = {
					clubId = 184,
					uniformCategory = native.CClubUniformCategory.Away
				}
			}
		}
	},
	{
		title = var_0_6.playAsMensSooDecider,
		stateData = {
			ground = "stadiumAustralia",
			isGrandFinal = true,
			matchTypeId = 1,
			nextState = casual_newmatch.CasualNewState,
			sex = native.CSex.Male,
			lineupCategory = var_0_0,
			trophyId = native.ETrophy.StateOfOrigin,
			matchSettingsOverrides = {
				ball = native.MatchSettingsBall.soo1,
				timeOfDay = native.MatchSettingsTimeOfDay.night
			},
			clubInfoMap = {
				home = {
					clubId = 19,
					uniformCategory = native.CClubUniformCategory.Home
				},
				away = {
					clubId = 18,
					uniformCategory = native.CClubUniformCategory.Away
				}
			}
		}
	},
	{
		title = var_0_6.playAsWomensSooDecider,
		stateData = {
			ground = "hunterStadium",
			isGrandFinal = true,
			matchTypeId = 6,
			nextState = casual_newmatch.CasualNewState,
			sex = native.CSex.Female,
			lineupCategory = var_0_0,
			trophyId = native.ETrophy.StateOfOriginWomens,
			matchSettingsOverrides = {
				ball = native.MatchSettingsBall.soo1,
				timeOfDay = native.MatchSettingsTimeOfDay.night
			},
			clubInfoMap = {
				home = {
					clubId = 109,
					uniformCategory = native.CClubUniformCategory.Home
				},
				away = {
					clubId = 108,
					uniformCategory = native.CClubUniformCategory.Away
				}
			}
		}
	}
}
local var_0_13 = {
	autoNavKey = "finals",
	dataContextKey = "Finals",
	customSound = "front_end_play_now",
	image = "Finals",
	title = var_0_6.finals,
	description = var_0_7.finals,
	stateFactory = casual.CasualState,
	subMenu = var_0_12
}
local var_0_14 = {
	{
		title = native.Localise("QuickMatch"),
		stateData = {
			forcePostMatch = true,
			stateFactory = online_controllerselect_state.OnlineControllerSelectState,
			nextStateFactory = online_quickmatch_state.OnlineQuickMatchState
		}
	},
	{
		title = native.Localise("CustomMatch"),
		stateData = {
			forcePostMatch = true,
			stateFactory = online_controllerselect_state.OnlineControllerSelectState,
			nextStateFactory = online_custommatch_state.OnlineCustomMatchState
		}
	},
	{
		title = native.Localise("Leaderboards"),
		stateData = {
			launchedFromInvite = false,
			stateFactory = online_leaderboard_state.OnlineLeaderboardState
		}
	}
}
local var_0_15 = {
	{
		title = native.Localise("QuickMatch"),
		stateData = {
			stateFactory = online_controllerselect_state.OnlineControllerSelectState,
			nextStateFactory = online_quickmatch_state.OnlineQuickMatchState
		}
	}
}

;({})[1] = {
	title = native.Localise("QuickMatch"),
	stateData = {
		stateFactory = online_controllerselect_state.OnlineControllerSelectState,
		nextStateFactory = online_quickmatch_state.OnlineQuickMatchState
	}
}

local var_0_16 = {
	customSound = "front_end_online",
	autoNavKey = "online",
	image = "online",
	dataContextKey = "Online",
	requiresStrictUGCPrivileges = true,
	title = var_0_6.online,
	description = var_0_7.online,
	stateFactory = online_state.OnlineSetupState,
	subMenu = native.precert and var_0_15 or var_0_14,
	locked = native.lockonline
}
local var_0_17 = {
	autoNavKey = "career",
	image = "career",
	customSound = "front_end_career",
	locked = false,
	dataContextKey = "Career",
	competitionId = -1,
	requiresStrictUGCPrivileges = true,
	title = var_0_6.career,
	description = var_0_7.career,
	stateFactory = careerstate.CareerState,
	scanTasksOnSubmenuOpen = {
		"Career"
	},
	subMenu = {
		{
			new = true,
			career = true,
			title = var_0_6.NewCareer,
			stateData = {
				new = true
			}
		},
		{
			locked = true,
			title = var_0_6.ManageCareer,
			stateData = {
				manage = true
			}
		}
	}
}
local var_0_18 = {
	autoNavKey = "NRL",
	image = "competition",
	customSound = "front_end_competitions",
	dataContextKey = "NRL",
	title = var_0_6.NrlCompetition,
	competitionId = native.CareerCompetitionIdEnum.League_NRL,
	loadState = competition_neworload_load.CompetitionNewOrLoadLoad,
	description = var_0_7.NRLCompetition,
	stateFactory = competitionstate.CompetitionState,
	scanTasksOnSubmenuOpen = {
		"Competition"
	},
	subMenu = {
		{
			new = true,
			competition = true,
			title = var_0_6.NewCompetition,
			stateData = {
				nextState = competition_neworload_new.CompetitionNew,
				stateData = native.CareerCompetitionIdEnum.League_NRL
			}
		},
		{
			locked = true,
			title = var_0_6.ManageCompetition,
			stateData = {
				nextState = metagamemode_neworload_list_manage.MetagameModeNewOrLoadListManage
			}
		}
	}
}
local var_0_19 = {
	autoNavKey = "NRWL",
	image = "competition",
	customSound = "front_end_competitions",
	dataContextKey = "NRLW",
	title = var_0_6.NrlWCompetition,
	competitionId = native.CareerCompetitionIdEnum.League_NRLW,
	loadState = competition_neworload_load.CompetitionNewOrLoadLoad,
	description = var_0_7.NRLWCompetition,
	stateFactory = competitionstate.CompetitionState,
	scanTasksOnSubmenuOpen = {
		"Competition"
	},
	subMenu = {
		{
			new = true,
			competition = true,
			title = var_0_6.NewCompetition,
			stateData = {
				nextState = competition_neworload_new.CompetitionNew,
				stateData = native.CareerCompetitionIdEnum.League_NRLW
			}
		},
		{
			locked = true,
			title = var_0_6.ManageCompetition,
			stateData = {
				nextState = metagamemode_neworload_list_manage.MetagameModeNewOrLoadListManage
			}
		}
	}
}
local var_0_20 = {
	autoNavKey = "SuperLeague",
	image = "competition",
	customSound = "front_end_competitions",
	dataContextKey = "SuperLeague",
	title = var_0_6.SuperLegueCompetition,
	competitionId = native.CareerCompetitionIdEnum.League_SuperLeague2026,
	loadState = competition_neworload_load.CompetitionNewOrLoadLoad,
	description = var_0_7.SuperLeagueCompetition,
	stateFactory = competitionstate.CompetitionState,
	scanTasksOnSubmenuOpen = {
		"Competition"
	},
	subMenu = {
		{
			new = true,
			competition = true,
			title = var_0_6.NewCompetition,
			stateData = {
				nextState = competition_neworload_new.CompetitionNew,
				stateData = native.CareerCompetitionIdEnum.League_SuperLeague2026
			}
		},
		{
			locked = true,
			title = var_0_6.ManageCompetition,
			stateData = {
				nextState = metagamemode_neworload_list_manage.MetagameModeNewOrLoadListManage
			}
		}
	}
}
local var_0_21 = {
	autoNavKey = "WSL",
	image = "competition",
	customSound = "front_end_competitions",
	dataContextKey = "WSL",
	title = var_0_6.WslCompetition,
	competitionId = native.CareerCompetitionIdEnum.League_WSL,
	loadState = competition_neworload_load.CompetitionNewOrLoadLoad,
	description = var_0_7.WSLCompetition,
	stateFactory = competitionstate.CompetitionState,
	scanTasksOnSubmenuOpen = {
		"Competition"
	},
	subMenu = {
		{
			new = true,
			competition = true,
			title = var_0_6.NewCompetition,
			stateData = {
				nextState = competition_neworload_new.CompetitionNew,
				stateData = native.CareerCompetitionIdEnum.League_WSL
			}
		},
		{
			locked = true,
			title = var_0_6.ManageCompetition,
			stateData = {
				nextState = metagamemode_neworload_list_manage.MetagameModeNewOrLoadListManage
			}
		}
	}
}
local var_0_22 = {
	dataContextKey = "CustomDifficulties",
	title = native.Localise("CustomDifficulties"),
	description = native.Localise("CustomDifficultiesDescription"),
	stateFactory = academy_state.AcademyState,
	stateData = {
		nextState = customdifficulty_state.CustomDifficultyState
	}
}
local var_0_23 = {
	dataContextKey = "MatchTypeCreator",
	title = native.Localise("MatchTypeDesigner"),
	description = native.Localise("MatchTypeDesignerDescription"),
	stateFactory = academy_state.AcademyState,
	stateData = {
		nextState = matchtypedesignertypeselection_state.MatchTypeDesignerTypeSelectionState
	}
}
local var_0_24 = {
	{
		title = var_0_6.GeneralSettings,
		stateData = {
			nextState = settings_general_state.SettingsGeneralState
		}
	},
	{
		title = var_0_6.AudioSettings,
		stateFactory = settings_audio_state.SettingsAudioState,
		stateData = {
			nextState = settings_audio_state.SettingsAudioState
		}
	},
	{
		title = var_0_6.ControlsSettings,
		locked = native.standalone,
		stateData = {
			nextState = settings_controls_state.SettingsControlsState
		}
	}
}
local var_0_25 = {
	{
		title = var_0_6.GeneralSettings,
		stateData = {
			nextState = settings_general_state.SettingsGeneralState
		}
	},
	{
		title = var_0_6.AudioSettings,
		stateFactory = settings_audio_state.SettingsAudioState,
		stateData = {
			nextState = settings_audio_state.SettingsAudioState
		}
	},
	{
		title = var_0_6.ControlsSettings,
		locked = native.standalone,
		stateData = {
			nextState = settings_controls_state.SettingsControlsState
		}
	}
}
local var_0_26 = {
	{
		title = var_0_6.GeneralSettings,
		stateData = {
			nextState = settings_general_state.SettingsGeneralState
		}
	},
	{
		title = var_0_6.GameplayModifiersSettings,
		stateData = {
			nextState = settings_gameplaymodifiers_state.SettingsGameplayModifiersState
		}
	},
	{
		title = var_0_6.GameplaySlidersSettings,
		stateData = {
			nextState = settings_gameplaysliders_state.SettingsGameplaySlidersState
		}
	},
	{
		title = var_0_6.AudioSettings,
		stateFactory = settings_audio_state.SettingsAudioState,
		stateData = {
			nextState = settings_audio_state.SettingsAudioState
		}
	},
	{
		lockWhileSaving = true,
		title = var_0_6.ChangePrimaryUser,
		locked = native.standalone,
		stateData = {
			nextState = settings_changeprimaryuser.SettingsChangePrimaryUser
		}
	},
	{
		title = var_0_6.ControlsSettings,
		locked = native.standalone,
		stateData = {
			nextState = settings_controls_state.SettingsControlsState
		}
	},
	{
		title = var_0_6.SharingSettings,
		locked = native.standalone,
		stateData = {
			nextState = settings_userstatistics_state.SettingsUserStatisticsState
		}
	},
	{
		title = var_0_6.ResetAcademy,
		locked = native.standalone,
		stateData = {
			nextState = resetacademy_state.ResetAcademyState
		}
	}
}

if not PLATFORM_SWITCH2 then
	table.insert(var_0_24, {
		title = var_0_6.MyNaconAgreements,
		stateData = {
			nextState = settings_mynacon_viewagreement_state.SettingsMyNaconViewAgreementState
		}
	})
	table.insert(var_0_25, {
		title = var_0_6.MyNaconAgreements,
		stateData = {
			nextState = settings_mynacon_viewagreement_state.SettingsMyNaconViewAgreementState
		}
	})
	table.insert(var_0_26, {
		title = var_0_6.MyNaconAgreements,
		stateData = {
			nextState = settings_mynacon_viewagreement_state.SettingsMyNaconViewAgreementState
		}
	})
end

local var_0_27 = {
	autoNavKey = "settings",
	dataContextKey = "Settings",
	customSound = "front_end_settings",
	image = "settings",
	title = var_0_6.settings,
	description = var_0_7.settings,
	stateFactory = settings_state.SettingsState,
	subMenu = native.precert and var_0_24 or native.publicfacing and var_0_25 or var_0_26
}
local var_0_28 = {
	autoNavKey = "practice",
	dataContextKey = "Practice",
	customSound = "front_end_tutorials",
	image = "drills",
	title = var_0_6.practice,
	description = var_0_7.practice,
	stateFactory = practice_state.PracticeState
}
local var_0_29 = {
	dataContextKey = "Credits",
	autoNavKey = "credits",
	customSound = "front_end_credits",
	title = var_0_6.Credits,
	description = native.Localise("CreditsDescription"),
	stateFactory = settings_credits_state.SettingsCreditsState
}
local var_0_30 = {
	dataContextKey = "Players",
	requiresStrictUGCPrivileges = true,
	title = var_0_6.Players,
	description = native.Localise("PlayersDescription"),
	stateFactory = academy_state.AcademyState,
	stateData = {
		nextState = academy_player_hub_state.AcademyPlayerHubState
	},
	subMenu = {
		{
			title = var_0_6.AllPlayers,
			stateData = {
				boxTitle = "AllPlayers",
				nextState = academy_player_edit_state.AcademyPlayerEditState
			}
		},
		{
			title = var_0_6.CreateMalePlayer,
			stateData = {
				nextState = academyplayercreateethnicity_state.AcademyPlayerCreateEthnicity,
				sex = native.CSex.Male
			}
		},
		{
			title = var_0_6.CreateFemalePlayer,
			stateData = {
				nextState = academyplayercreateethnicity_state.AcademyPlayerCreateEthnicity,
				sex = native.CSex.Female
			}
		},
		{
			title = var_0_6.DeletePlayer,
			stateData = {
				nextState = academy_player_delete_state.AcademyPlayerDeleteState
			}
		}
	}
}
local var_0_31 = {
	dataContextKey = "Clubs",
	requiresStrictUGCPrivileges = true,
	title = var_0_6.Clubs,
	description = native.Localise("ClubsDescription"),
	stateFactory = academy_state.AcademyState,
	stateData = {
		nextState = academy_club_hub_state.AcademyClubHubState
	},
	subMenu = {
		{
			title = var_0_6.ClubManager,
			stateData = {
				nextState = academy_club_edit_state.AcademyClubEditState
			}
		},
		{
			title = var_0_6.CreateCustomMensClub,
			stateData = {
				sex = native.CSex.Male,
				nextState = academy_club_createcustom_state.AcademyClubCreateCustomState
			},
			checkLockFn = function(arg_1_0)
				local var_1_0 = arg_1_0:getClubManager().userCreated

				return var_1_0 and var_1_0.canCreateCount == 0 or false
			end
		},
		{
			title = var_0_6.CreateCustomWomensClub,
			stateData = {
				sex = native.CSex.Female,
				nextState = academy_club_createcustom_state.AcademyClubCreateCustomState
			},
			checkLockFn = function(arg_2_0)
				local var_2_0 = arg_2_0:getClubManager().userCreated

				return var_2_0 and var_2_0.canCreateCount == 0 or false
			end
		},
		{
			title = var_0_6.DeleteClub,
			stateData = {
				nextState = academy_club_delete_state.AcademyClubDeleteState
			}
		}
	}
}
local function coachEditorText(arg_ce_0, arg_ce_1)
	local var_ce_0 = native.Localise(arg_ce_0)

	if type(var_ce_0) ~= "string" or var_ce_0 == "" or var_ce_0 == arg_ce_0 or string.find(var_ce_0, "^[<#%[]") then
		return arg_ce_1
	end

	return var_ce_0
end

local var_0_32 = {
	dataContextKey = "Referees",
	locked = false,
	requiresStrictUGCPrivileges = true,
	title = coachEditorText("RefereesAndCoaches", "Referees & Coaches"),
	description = native.Localise("UmpiresDescription"),
	stateFactory = academy_state.AcademyState,
	stateData = {
		nextState = academy_referee_hub.AcademyRefereeHubState
	},
	subMenu = {
		{
			title = var_0_6.EditReferee,
			stateData = {
				nextState = academy_referee_hub_edit.AcademyRefereeEditState
			}
		},
		{
			title = var_0_6.CreateRefereeMan,
			stateData = {
				nextState = academyrefereecreateethnicity_state.AcademyRefereeCreateEthnicityState,
				sex = native.CSex.Male
			}
		},
		{
			title = var_0_6.CreateRefereeWoman,
			stateData = {
				nextState = academyrefereecreateethnicity_state.AcademyRefereeCreateEthnicityState,
				sex = native.CSex.Female
			}
		},
		{
			title = var_0_6.DeleteReferee,
			stateData = {
				nextState = academy_referee_hub_delete.AcademyRefereeDeleteState
			}
		},
		{
			title = coachEditorText("EditCoach", "Edit Coach"),
			stateData = {
				nextState = academy_referee_hub_edit.AcademyRefereeEditState,
				npcType = native.CNpcType.Coach
			}
		},
		{
			title = coachEditorText("CreateCoachMan", "Create Coach (Man)"),
			stateData = {
				nextState = academyrefereecreateethnicity_state.AcademyRefereeCreateEthnicityState,
				sex = native.CSex.Male,
				npcType = native.CNpcType.Coach
			}
		},
		{
			title = coachEditorText("CreateCoachWoman", "Create Coach (Woman)"),
			stateData = {
				nextState = academyrefereecreateethnicity_state.AcademyRefereeCreateEthnicityState,
				sex = native.CSex.Female,
				npcType = native.CNpcType.Coach
			}
		},
		{
			title = coachEditorText("DeleteCoach", "Delete Coach"),
			stateData = {
				nextState = academy_referee_hub_delete.AcademyRefereeDeleteState,
				npcType = native.CNpcType.Coach
			}
		}
	}
}
local var_0_33 = {
	locked = false,
	customSound = "front_end_community",
	dataContextKey = "Community",
	requiresStrictUGCPrivileges = true,
	title = var_0_6.community,
	description = var_0_7.community,
	stateData = {
		nextState = academy_community_state.AcademyCommunitySetupState
	},
	stateFactory = academy_state.AcademyState,
	highlightIcon = uitextures.tile_community.texture,
	subMenu = native.precert and {
		{
			title = var_0_6.SearchCommunity,
			stateData = {
				nextState = academy_community_state.AcademyCommunitySetupState,
				stateData = {
					stateFactory = academy_community_state.AcademyCommunitySetupState
				}
			}
		}
	} or native.publicfacing and {
		{
			title = var_0_6.SearchCommunity,
			stateData = {
				nextState = academy_community_state.AcademyCommunitySetupState,
				stateData = {
					stateFactory = academy_community_state.AcademyCommunitySetupState
				}
			}
		}
	} or {
		{
			title = var_0_6.SearchCommunity,
			stateData = {
				nextState = academy_community_state.AcademyCommunitySetupState,
				stateData = {
					stateFactory = academy_community_state.AcademyCommunitySetupState
				}
			}
		},
		{
			title = var_0_6.QuickCodes,
			stateData = {
				nextState = academy_communitystate_quickcodes_state.AcademyCommunityQuickCodes
			}
		}
	}
}
local var_0_34 = {
	dataContextKey = "Decal",
	requiresStrictUGCPrivileges = true,
	title = var_0_6.Decals,
	description = native.Localise("DecalHubDescription"),
	stateFactory = academy_state.AcademyState,
	stateData = {
		nextState = decal_state.DecalState
	},
	subMenu = {
		{
			title = var_0_6.CreateDecal,
			stateData = {
				nextState = decal_create.DecalCreate
			}
		},
		{
			title = var_0_6.EditDecal,
			stateData = {
				nextState = decal_edit.DecalEdit
			}
		}
	}
}
local var_0_35 = {
	dataContextKey = "stadium",
	requiresStrictUGCPrivileges = true,
	title = var_0_6.Levels,
	description = native.Localise("LevelsDescription"),
	stateFactory = academy_state.AcademyState,
	stateData = {
		nextState = level_state.LevelState
	},
	subMenu = {
		{
			locked = false,
			title = var_0_6.CreateLevel,
			stateData = {
				nextState = level_create.LevelCreate
			}
		},
		{
			locked = false,
			title = var_0_6.EditLevel,
			stateData = {
				nextState = level_edit.LevelEdit,
				nextStateData = {
					nextState = "List"
				}
			}
		}
	}
}
local var_0_36 = {
	dataContextKey = "League",
	requiresStrictUGCPrivileges = true,
	title = var_0_6.Leagues,
	description = native.Localise("LeaguesDescription"),
	stateFactory = academy_state.AcademyState,
	stateData = {
		nextState = academy_league_hub.AcademyLeagueHubState
	},
	subMenu = {
		{
			title = var_0_6.EditLeague,
			stateData = {
				nextState = academy_league_hub_edit.AcademyLeagueEditState
			}
		},
		{
			title = var_0_6.CreateLeague,
			stateData = {
				nextState = academy_league_hub_create.AcademyLeagueCreateState
			}
		},
		{
			title = var_0_6.DeleteLeague,
			stateData = {
				nextState = academy_league_hub_delete.AcademyLeagueDeleteState
			}
		}
	}
}
local var_0_37 = {
	dataContextKey = "CompetitionHub",
	autoNavKey = "CompetitionHub",
	title = var_0_6.competition,
	description = var_0_7.competition,
	stateFactory = competitionstate.CompetitionState,
	competitionId = native.CareerCompetitionIdEnum.Custom_Tournament,
	scanTasksOnSubmenuOpen = {
		"Competition"
	},
	subMenu = {
		{
			new = true,
			competition = true,
			title = var_0_6.NewCompetition,
			stateData = {
				nextState = competitionstate_hub.CompetitionStateHub
			}
		},
		{
			title = var_0_6.ManageCompetition,
			stateData = {
				nextState = metagamemode_neworload_list_manage.MetagameModeNewOrLoadListManage
			}
		}
	}
}
local var_0_38 = {
	dataContextKey = "NTS",
	title = "NTS",
	description = native.Localise("NTS"),
	stateFactory = noesisteststate_hub.NoesisTestState,
	stateData = {}
}
local var_0_39 = not PLATFORM_SWITCH_ANY and {
	autoNavKey = "proteam",
	dataContextKey = "ProTeam",
	requiresStrictUGCPrivileges = true,
	locked = false,
	textTexture = "ui/textures/tiles/main/pro_team/s01.texture",
	title = var_0_6.proTeam,
	description = var_0_7.proTeam,
	stateFactory = dynasty_state.DynastyState
} or nil
local var_0_40 = {
	title = "CommsTasks",
	dataContextKey = "CommsTasks",
	autoNavKey = "CommsTasks",
	textTexture = "ui/textures/tiles/main/pro_team/s01.texture",
	stateFactory = uitest_nathan_commstasks.UITestNathanCommsTasks,
	stateData = {}
}

function getTileFn(arg_3_0, arg_3_1)
	local var_3_0 = {}
	local var_3_1 = {}

	for iter_3_0, iter_3_1 in ipairs({
		arg_3_1.Main,
		arg_3_1.Competition
	}) do
		for iter_3_2, iter_3_3 in ipairs(iter_3_1) do
			if iter_3_3.competitionId == arg_3_0 or iter_3_3.competitionIdWomens == arg_3_0 then
				table.insert(var_3_0, iter_3_3)
				table.insert(var_3_1, iter_3_1.dataContextKey)
			end
		end
	end

	return var_3_0, var_3_1
end

function createFirstPageTiles(arg_4_0)
	local var_4_0 = {
		Main = {
			dataContextKey = "Main"
		},
		Competition = {
			dataContextKey = "Competition"
		},
		Academy = {
			dataContextKey = "Academy"
		},
		Extra = {
			dataContextKey = "Extra"
		}
	}
	local var_4_1 = {
		tilesRows = var_4_0
	}

	if native.precert then
		table.insert(var_4_1.tilesRows.Main, var_0_9)
		table.insert(var_4_1.tilesRows.Main, var_0_13)
		table.insert(var_4_1.tilesRows.Main, var_0_16)
		table.insert(var_4_1.tilesRows.Main, var_0_39)
		table.insert(var_4_1.tilesRows.Competition, var_0_18)
		table.insert(var_4_1.tilesRows.Competition, var_0_20)
		table.insert(var_4_1.tilesRows.Competition, var_0_19)
		table.insert(var_4_1.tilesRows.Competition, var_0_21)
		table.insert(var_4_1.tilesRows.Academy, var_0_30)
		table.insert(var_4_1.tilesRows.Academy, var_0_31)
		table.insert(var_4_1.tilesRows.Academy, var_0_33)
		table.insert(var_4_1.tilesRows.Academy, var_0_34)
		table.insert(var_4_1.tilesRows.Academy, var_0_35)
		table.insert(var_4_1.tilesRows.Extra, var_0_27)
		table.insert(var_4_1.tilesRows.Extra, var_0_29)
	elseif native.publicfacing then
		table.insert(var_4_1.tilesRows.Main, var_0_9)
		table.insert(var_4_1.tilesRows.Main, var_0_11)
		table.insert(var_4_1.tilesRows.Main, var_0_13)
		table.insert(var_4_1.tilesRows.Main, var_0_17)
		table.insert(var_4_1.tilesRows.Main, var_0_16)
		table.insert(var_4_1.tilesRows.Main, var_0_39)
		table.insert(var_4_1.tilesRows.Competition, var_0_18)
		table.insert(var_4_1.tilesRows.Competition, var_0_20)
		table.insert(var_4_1.tilesRows.Competition, var_0_19)
		table.insert(var_4_1.tilesRows.Competition, var_0_21)
		table.insert(var_4_1.tilesRows.Competition, var_0_37)
		table.insert(var_4_1.tilesRows.Academy, var_0_30)
		table.insert(var_4_1.tilesRows.Academy, var_0_31)
		table.insert(var_4_1.tilesRows.Academy, var_0_32)
		table.insert(var_4_1.tilesRows.Academy, var_0_22)
		table.insert(var_4_1.tilesRows.Academy, var_0_23)
		table.insert(var_4_1.tilesRows.Academy, var_0_33)
		table.insert(var_4_1.tilesRows.Academy, var_0_34)

		if not PLATFORM_SWITCH_ANY then
			table.insert(var_4_1.tilesRows.Academy, var_0_35)
		end

		table.insert(var_4_1.tilesRows.Academy, var_0_36)
		table.insert(var_4_1.tilesRows.Extra, var_0_27)
		table.insert(var_4_1.tilesRows.Extra, var_0_28)
		table.insert(var_4_1.tilesRows.Extra, var_0_29)
	else
		table.insert(var_4_1.tilesRows.Main, var_0_9)
		table.insert(var_4_1.tilesRows.Main, var_0_11)
		table.insert(var_4_1.tilesRows.Main, var_0_13)
		table.insert(var_4_1.tilesRows.Main, var_0_17)
		table.insert(var_4_1.tilesRows.Main, var_0_16)
		table.insert(var_4_1.tilesRows.Main, var_0_39)
		table.insert(var_4_1.tilesRows.Competition, var_0_18)
		table.insert(var_4_1.tilesRows.Competition, var_0_20)
		table.insert(var_4_1.tilesRows.Competition, var_0_19)
		table.insert(var_4_1.tilesRows.Competition, var_0_21)
		table.insert(var_4_1.tilesRows.Competition, var_0_37)
		table.insert(var_4_1.tilesRows.Academy, var_0_30)
		table.insert(var_4_1.tilesRows.Academy, var_0_31)

		table.insert(var_4_1.tilesRows.Academy, var_0_32)

		table.insert(var_4_1.tilesRows.Academy, var_0_22)
		table.insert(var_4_1.tilesRows.Academy, var_0_23)
		table.insert(var_4_1.tilesRows.Academy, var_0_33)
		table.insert(var_4_1.tilesRows.Academy, var_0_34)
		table.insert(var_4_1.tilesRows.Academy, var_0_35)
		table.insert(var_4_1.tilesRows.Academy, var_0_36)
		table.insert(var_4_1.tilesRows.Extra, var_0_28)
		table.insert(var_4_1.tilesRows.Extra, var_0_27)
		table.insert(var_4_1.tilesRows.Extra, var_0_29)
	end

	if var_0_4 then
		table.insert(var_4_1.tilesRows.Main, var_0_40)
	end

	if var_0_5 then
		table.insert(var_4_1.tilesRows.Extra, var_0_38)
	end

	return var_4_1
end

ScanTasks = {
	"Competition",
	"Career"
}
