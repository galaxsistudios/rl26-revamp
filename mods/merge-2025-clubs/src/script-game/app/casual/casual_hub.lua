import("app.casual.casual_newmatch")
import("base.side.sidehelper")
import("base.ui.tilemenu.tilemenu_state")
import("core.foundation.tablex")

local var_0_0 = GAME_RUGBY
local var_0_1 = native:getEnvironment():argExists("ebpromo")
local var_0_2 = {
	home = 38,
	away = 27
}
local var_0_3 = native.EClubLineupCategory.LeagueMatch
local var_0_4 = native.EClubLineupCategory.NinesMatch
local var_0_5 = {
	"RecentMatch",
	"NrlMatch",
	"SuperLeagueMatch",
	"NinesMatch",
	"GrandFinalMatch",
	"StateOfOriginMatch",
	"MysteryMatch",
	"Womens13s",
	"Womens9s"
}
local var_0_6 = {
	StateOfOriginMatch = native.ETrophy.StateOfOrigin,
	GrandFinalMatch = native.ETrophy.NRL
}
local var_0_7 = native.EOnDiscLeagues
local var_0_8 = var_0_0 and {
	[var_0_7.NRL] = {
		runnerUp = "Cronulla-Sutherland Sharks",
		premier = "Melbourne Storm"
	},
	nines = {
		runnerUp = "Sydney Roosters",
		premier = "Penrith Panthers"
	}
}
local var_0_9 = {
	GrandFinalMatch = {
		optionsGround = {
			"anz",
			"oldtrafford"
		},
		optionsTrophy = {
			native.ETrophy.NRL,
			native.ETrophy.SuperLeague
		},
		optionsFieldMarkings = {
			native.MatchSettingsFieldMarkings.NRL_GrandFinal,
			native.MatchSettingsFieldMarkings.SuperLeague_GrandFinal
		},
		optionsBall = {
			native.MatchSettingsBall.nrlgrandfinal,
			native.MatchSettingsBall.superleague
		}
	},
	NinesMatch = {
		lockedFieldMarkings = true,
		lockedGround = false,
		lockedBall = true
	},
	StateOfOriginMatch = {
		lockedTrophy = true,
		lockedBall = true,
		optionsGround = {
			"anz",
			"suncorp"
		}
	}
}

local function var_0_10(arg_1_0, arg_1_1)
	ASSERT(arg_1_0.partyMember)

	local var_1_0, var_1_1 = arg_1_1:getLeagueClubAndPlayerManagers(arg_1_0.partyMember)
	local var_1_2 = {
		home = {
			clubId = -1,
			uniformCategory = -1
		},
		away = {
			clubId = -1,
			uniformCategory = -1
		}
	}
	local var_1_3 = var_1_0:getMysteryClubs(var_1_1)

	var_1_2.home.clubId = var_1_3[sidehelper.home]
	var_1_2.away.clubId = var_1_3[sidehelper.away]

	local var_1_4 = native.Random.FromSystemTime()

	var_1_2.home.uniformCategory = native.CClubUniformCategory:fromInt(var_1_4:next(1, native.CClubUniformCategory.Count))
	var_1_2.away.uniformCategory = native.CClubUniformCategory:fromInt(var_1_4:next(1, native.CClubUniformCategory.Count))

	return var_1_2
end

local function var_0_11(arg_2_0, arg_2_1)
	local var_2_0 = native.CFrontendMatchSettings()

	var_2_0:set(arg_2_1)

	local var_2_1 = native.Random.FromSystemTime()
	local var_2_2 = var_2_1:next(1, native.MatchSettingsRules.Count)

	var_2_0.rules = native.MatchSettingsRules:fromInt(var_2_2 - 1)
	var_2_0.ball = native.MatchSettingsBall:fromInt(var_2_1:next(1, native.MatchSettingsBall.Count) - 1)
	var_2_0.extraTime = native.MatchSettingsExtraTime:fromInt(var_2_1:next(1, native.MatchSettingsExtraTime.Count) - 1)
	var_2_0.fieldMarkings = native.MatchSettingsFieldMarkings:fromInt(var_2_1:next(1, native.MatchSettingsFieldMarkings.Count) - 1)
	var_2_0.injuries = native.MatchSettingsInjuries:fromInt(var_2_1:next(1, native.MatchSettingsInjuries.Count) - 1)
	var_2_0.timeOfDay = native.MatchSettingsTimeOfDay:fromInt(var_2_1:next(1, native.MatchSettingsTimeOfDay.Count) - 1)
	var_2_0.weather = native.EWeatherType.Auto
	var_2_0.ground = "random"

	ASSERT(arg_2_0:getMatchTypeManager())

	var_2_0.matchType = arg_2_0:getMatchTypeManager():getRandomOnDiscMatchType()

	return var_2_0
end

local function var_0_12(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5)
	local var_3_0 = tilemenu_state.createBasicTile(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5)

	ASSERT(var_3_0.stateData)

	local var_3_1 = VERIFY(tablex.indexOf(var_0_5, arg_3_4))

	ASSERT(var_3_1)

	var_3_0.stateData.gameModeIndex = var_3_1

	function var_3_0.stateDataCompareFn(arg_4_0)
		return var_3_1 == arg_4_0.gameModeIndex
	end

	return var_3_0
end

local function var_0_13(arg_5_0, arg_5_1, arg_5_2)
	local var_5_0 = assert(arg_5_1.partyMember)
	local var_5_1 = var_5_0.settings
	local var_5_2, var_5_3 = arg_5_2:getLeagueClubAndPlayerManagers(var_5_0)
	local var_5_4 = VERIFY(arg_5_2:getMatchTypeManager())
	local var_5_5 = arg_5_2:getDlc1Enabled()
	local var_5_6 = casual_newmatch.CasualNewState

	return {
		var_0_12(1, 1, 2, 1, "NrlMatch", {
			image = "competition/nrl2",
			stateFactory = var_5_6,
			stateData = {
				enterLockdownAfterControllerSetup = false,
				settingsInfo = {
					rules = native.MatchSettingsRules.nrl,
					ball = native.MatchSettingsBall.nrl,
					fieldMarkings = native.MatchSettingsFieldMarkings.NRL_Season_Friday,
					extraTime = native.MatchSettingsExtraTime.goldenpointlimited,
					matchType = var_5_4:getMatchTypeByName("NRL")
				},
				clubInfoMap = {
					home = {
						clubId = VERIFY(var_5_3:getClubIdFromFullName(var_0_8[var_0_7.NRL].premier)),
						uniformCategory = native.CClubUniformCategory.Home
					},
					away = {
						clubId = VERIFY(var_5_3:getClubIdFromFullName(var_0_8[var_0_7.NRL].runnerUp)),
						uniformCategory = native.CClubUniformCategory.Away
					}
				},
				settingRestrictions = var_0_9.NrlMatch,
				sex = native.CSex.Male,
				lineupCategory = var_0_3
			}
		}),
		var_0_12(1, 2, 2, 1, "Womens13s", {
			image = "casual/womens13s",
			locked = false,
			stateFactory = var_5_6,
			stateData = {
				enterLockdownAfterControllerSetup = false,
				settingsInfo = {
					rules = native.MatchSettingsRules.nrl,
					ball = native.MatchSettingsBall.nrl,
					fieldMarkings = native.MatchSettingsFieldMarkings.NRL_Season_Friday,
					extraTime = native.MatchSettingsExtraTime.goldenpointlimited,
					matchType = var_5_4:getMatchTypeByName("NRL")
				},
				clubInfoMap = {
					home = {
						clubId = 118,
						uniformCategory = native.CClubUniformCategory.Home
					},
					away = {
						clubId = 119,
						uniformCategory = native.CClubUniformCategory.Away
					}
				},
				settingRestrictions = var_0_9.NrlMatch,
				sex = native.CSex.Female,
				lineupCategory = var_0_3
			}
		}),
		var_0_12(2, 4, 1, 1, "Womens9s", {
			image = "casual/womens9s",
			stateFactory = var_5_6,
			stateData = {
				usingOffensiveRef = false,
				enterLockdownAfterControllerSetup = false,
				settingsInfo = {
					ground = "edenpark",
					rules = native.MatchSettingsRules.aucklandnines,
					ball = native.MatchSettingsBall.aucklandnines,
					fieldMarkings = native.MatchSettingsFieldMarkings.AucklandNines,
					extraTime = native.MatchSettingsExtraTime.goldentrylimited,
					matchType = var_5_4:getMatchTypeByName("Nines")
				},
				clubInfoMap = {
					home = {
						clubId = var_5_1.casualHomeIdW > native.INVALID_CLUB_ID and var_5_1.casualHomeIdW or 144,
						uniformCategory = native.CClubUniformCategory.Home
					},
					away = {
						clubId = var_5_1.casualAwayIdW > native.INVALID_CLUB_ID and var_5_1.casualHomeIdW or 145,
						uniformCategory = native.CClubUniformCategory.Away
					}
				},
				settingRestrictions = var_0_9.NinesMatch,
				lineupCategory = var_0_4,
				sex = native.CSex.Female
			},
			locked = not var_5_5
		}),
		var_0_12(1, 3, 2, 1, "SuperLeagueMatch", {
			image = "competition/super league2",
			stateFactory = var_5_6,
			stateData = {
				usingOffensiveRef = false,
				enterLockdownAfterControllerSetup = false,
				settingsInfo = {
					rules = native.MatchSettingsRules.superleague,
					ball = native.MatchSettingsBall.superleague,
					fieldMarkings = native.MatchSettingsFieldMarkings.SuperLeague_Season,
					extraTime = native.MatchSettingsExtraTime.none,
					matchType = var_5_4:getMatchTypeByName("SuperLeague")
				},
				clubInfoMap = {
					home = {
						clubId = VERIFY(var_5_3:getClubIdFromFullName(var_0_8[var_0_7.SuperLeague].premier)),
						uniformCategory = native.CClubUniformCategory.Home
					},
					away = {
						clubId = VERIFY(var_5_3:getClubIdFromFullName(var_0_8[var_0_7.SuperLeague].runnerUp)),
						uniformCategory = native.CClubUniformCategory.Away
					}
				},
				settingRestrictions = var_0_9.SuperLeagueMatch,
				lineupCategory = var_0_3,
				sex = native.CSex.Male
			}
		}),
		var_0_12(3, 3, 1, 2, "GrandFinalMatch", {
			image = "casual/grand final",
			stateFactory = var_5_6,
			stateData = {
				enterLockdownAfterControllerSetup = false,
				settingsInfo = {
					ground = "anz",
					rules = native.MatchSettingsRules.nrl,
					ball = native.MatchSettingsBall.nrlgrandfinal,
					fieldMarkings = native.MatchSettingsFieldMarkings.NRL_GrandFinal,
					extraTime = native.MatchSettingsExtraTime.fiveminutehalvesthengoldenpointunlimited,
					matchType = var_5_4:getMatchTypeByName("NRL")
				},
				clubInfoMap = {
					home = {
						clubId = VERIFY(var_5_3:getClubIdFromFullName(var_0_8[var_0_7.NRL].premier)),
						uniformCategory = native.CClubUniformCategory.Home
					},
					away = {
						clubId = VERIFY(var_5_3:getClubIdFromFullName(var_0_8[var_0_7.NRL].runnerUp)),
						uniformCategory = native.CClubUniformCategory.Away
					}
				},
				trophyId = var_0_6.GrandFinalMatch,
				settingRestrictions = var_0_9.GrandFinalMatch,
				lineupCategory = var_0_3,
				sex = native.CSex.Male
			}
		}),
		var_0_12(1, 4, 1, 1, "NinesMatch", {
			image = "competition/auckland nines",
			stateFactory = var_5_6,
			stateData = {
				usingOffensiveRef = false,
				enterLockdownAfterControllerSetup = false,
				settingsInfo = {
					ground = "edenpark",
					rules = native.MatchSettingsRules.aucklandnines,
					ball = native.MatchSettingsBall.aucklandnines,
					fieldMarkings = native.MatchSettingsFieldMarkings.AucklandNines,
					extraTime = native.MatchSettingsExtraTime.goldentrylimited,
					matchType = var_5_4:getMatchTypeByName("Nines")
				},
				clubInfoMap = {
					home = {
						clubId = VERIFY(var_5_3:getClubIdFromFullName(var_0_8.nines.premier)),
						uniformCategory = native.CClubUniformCategory.Nines
					},
					away = {
						clubId = VERIFY(var_5_3:getClubIdFromFullName(var_0_8.nines.runnerUp)),
						uniformCategory = native.CClubUniformCategory.Nines
					}
				},
				settingRestrictions = var_0_9.NinesMatch,
				lineupCategory = var_0_4,
				sex = native.CSex.Male
			}
		}),
		var_0_12(3, 1, 1, 2, "StateOfOriginMatch", {
			image = "competition/state of origin2",
			stateFactory = var_5_6,
			stateData = {
				enterLockdownAfterControllerSetup = false,
				settingsInfo = {
					ground = "suncorp",
					rules = native.MatchSettingsRules.nrl,
					ball = native.MatchSettingsBall.soo3,
					matchType = var_5_4:getMatchTypeByName("NRL"),
					fieldMarkings = native.MatchSettingsFieldMarkings.NRL_Rep_StateOfOrigin,
					lockedExtraTime = native.MatchSettingsExtraTime.goldenpointunlimited
				},
				clubInfoMap = {
					home = {
						clubId = var_5_3:getClubIdFromFullName("Queensland Maroons"),
						uniformCategory = native.CClubUniformCategory.Home
					},
					away = {
						clubId = var_5_3:getClubIdFromFullName("New South Wales Blues"),
						uniformCategory = native.CClubUniformCategory.Away
					}
				},
				trophyId = var_0_6.StateOfOriginMatch,
				settingRestrictions = var_0_9.StateOfOriginMatch,
				lineupCategory = var_0_3,
				sex = native.CSex.Male
			}
		})
	}
end

local var_0_14 = tilemenu_state.TileMenuState

Class("CasualHub", var_0_14)

function CasualHub.enter(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7)
	local var_6_0 = var_0_13(arg_6_2, arg_6_6, arg_6_5)

	if var_0_1 then
		for iter_6_0, iter_6_1 in ipairs(var_6_0) do
			iter_6_1.locked = iter_6_0 > 1
		end
	end

	var_0_14.enter(arg_6_0, arg_6_2, arg_6_3, arg_6_4, arg_6_5, var_6_0, nil, arg_6_7, {
		backInputAllowed = true
	})
end

function CasualHub.update(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7, arg_7_8)
	local var_7_0 = VERIFY(arg_7_8.partyMember)
	local var_7_1, var_7_2 = var_0_14.update(arg_7_0, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7, var_7_0:getInput())

	if var_7_1 then
		if var_7_2 then
			local var_7_3 = var_7_2.stateData

			arg_7_8.goBackStack:push(arg_7_0.__proto, {
				goBackData = arg_7_8,
				goBackHighlightData = var_7_3
			})

			local var_7_4 = native.CFrontendMatchSettings()

			if var_7_3.mysterySettings then
				var_7_4:set(var_7_3.mysterySettings)
			else
				var_7_4:set(var_7_0.settings.casualSettings)

				local var_7_5 = var_7_3.settingsInfo

				if var_7_5 then
					for iter_7_0, iter_7_1 in pairs(var_7_5) do
						if var_7_4[iter_7_0] then
							var_7_4[iter_7_0] = iter_7_1
						end
					end
				end
			end

			if var_7_4.ground == "creator" then
				local var_7_6 = arg_7_6:getLevelManager():getLevel(var_7_4.groundId)

				if not (var_7_6 and var_7_6:getData()) then
					var_7_4.ground = "moorePark"
					var_7_4.groundId = native.INVALID_LEVEL_ID
				end
			end

			if var_7_4.groundInfo.key == "creator" then
				local var_7_7 = arg_7_6:getLevelManager():getLevel(var_7_4.groundInfo.stadiumId)

				if not (var_7_7 and var_7_7:getData()) then
					var_7_4.groundInfo.key = "moorePark"
					var_7_4.groundInfo.stadium = native.EStadiums.moorePark
					var_7_4.groundInfo.stadiumId = native.INVALID_LEVEL_ID
					var_7_4.groundInfo.stadiumSharingId = native.INVALID_LEVEL_ID
				end
			end

			arg_7_8.gameModes = var_0_5

			arg_7_1:changeState(var_7_2.stateFactory(), arg_7_2, arg_7_3, arg_7_5, arg_7_6, arg_7_8, var_7_3, var_7_4)
		elseif var_0_1 then
			arg_7_1:changeState(arg_7_8.stateFactoryMap.Enter(), arg_7_2, arg_7_3, arg_7_5, arg_7_6)
		else
			arg_7_6:homeScreenEnter(arg_7_2, arg_7_3, arg_7_5, arg_7_6, var_7_0, false)
		end
	end
end
