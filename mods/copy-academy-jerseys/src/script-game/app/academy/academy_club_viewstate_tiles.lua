import("app.club.club_viewstate_identity_state")
import("app.club.club_viewstate_homegrounds_state")
import("app.club.club_viewstate_sharing_state")
import("app.academy.academy_club_jersey_state")
import("app.academy.academy_club_managesquad_state")
import("app.academy.academy_club_lineupstate_playerlist_state")
import("app.academy.academy_communitystate_clubstate_download_substate")
import("app.academy.academy_communitystate_clubstate_viewstate_rate_substate")
import("app.academy.academy_communitystate_clubstate_viewstate_report_substate")
import("app.academy.academy_communitystate_clubstate_viewstate_roster_state")

local var_0_0 = native.standalone

function CreateLineupTiles(arg_1_0)
	local var_1_0 = {}

	for iter_1_0 = 1, arg_1_0:getLineupCount() do
		local var_1_1 = arg_1_0:getLineup(iter_1_0)

		if var_1_1.category ~= native.EClubLineupCategory.NinesMatch then
			local var_1_2 = {
				title = native.Localise(string.format("Lineup_%s", tostring(var_1_1.category))),
				stateFactory = academy_club_lineupstate_playerlist_state.AcademyClubLineupPlayerListState,
				lineupIndex = iter_1_0
			}

			table.insert(var_1_0, var_1_2)
		end
	end

	return var_1_0
end

function CreateTiles(arg_2_0, arg_2_1, arg_2_2)
	local var_2_0 = arg_2_1:getClubManager()
	local var_2_1 = arg_2_2.clubId and var_2_0:getClub(arg_2_2.clubId)
	local var_2_2

	if GAME_CRICKET then
		var_2_2 = var_2_1 and var_2_1.onDiscClub
	elseif GAME_RUGBY then
		var_2_2 = var_2_1 and var_2_1.identity.isWorldCup
	end

	return {
		{
			image = "academy/teams/edit team/identity",
			key = "Identity",
			colSize = 1,
			rowStart = 1,
			colStart = 1,
			rowSize = 2,
			isIdentity = true,
			title = native.Localise("Identity"),
			stateFactory = club_viewstate_identity_state.ClubViewIdentityState
		},
		{
			key = "Kits",
			colSize = 1,
			image = "academy/teams/edit team/jerseys",
			colStart = 2,
			rowStart = 1,
			rowSize = 2,
			title = native.Localise("Uniforms"),
			description = native.Localise("UniformsDescription"),
			stateFactory = academy_club_jersey_state.AcademyClubJerseyState
		},
		{
			key = "ManageRoster",
			colSize = 1,
			image = "academy/teams/edit team/add players",
			colStart = 3,
			rowStart = 1,
			rowSize = 2,
			title = native.Localise("ManageSquad"),
			description = native.Localise("ManageSquadDescription"),
			stateFactory = academy_club_managesquad_state.AcademyClubManageSquadState
		},
		{
			key = "Lineup",
			colSize = 1,
			image = "academy/teams/edit team/lineup",
			colStart = 4,
			rowStart = 1,
			rowSize = 2,
			title = native.Localise("Lineup_LeagueMatch"),
			description = native.Localise("LineupDescription"),
			locked = not var_2_1 or not var_2_1:getLineupFromLineupCategory(native.EClubLineupCategory.LeagueMatch),
			lockedGetFn = function(arg_3_0)
				local var_3_0 = arg_3_0.club

				return not var_3_0 or not var_3_0:getLineupFromLineupCategory(native.EClubLineupCategory.LeagueMatch)
			end,
			stateFactory = academy_club_lineupstate_playerlist_state.AcademyClubLineupPlayerListState,
			lineupCategory = native.EClubLineupCategory.LeagueMatch
		},
		{
			key = "Lineup2",
			colSize = 1,
			image = "academy/teams/edit team/lineup",
			colStart = 4,
			rowStart = 1,
			rowSize = 2,
			title = native.Localise("Lineup_NRL2026Match"),
			description = native.Localise("LineupDescription"),
			locked = not var_2_1 or not var_2_1:getLineupFromLineupCategory(native.EClubLineupCategory.NRL2026Match),
			lockedGetFn = function(arg_4_0)
				local var_4_0 = arg_4_0.club

				return not var_4_0 or not var_4_0:getLineupFromLineupCategory(native.EClubLineupCategory.NRL2026Match)
			end,
			stateFactory = academy_club_lineupstate_playerlist_state.AcademyClubLineupPlayerListState,
			lineupCategory = native.EClubLineupCategory.NRL2026Match
		},
		{
			key = "HomeGrounds",
			colSize = 2,
			image = "academy/teams/edit team/home grounds",
			colStart = 1,
			rowStart = 3,
			rowSize = 1,
			title = native.Localise("HomeGround"),
			description = native.Localise("HomeGroundDescription"),
			stateFactory = club_viewstate_homegrounds_state.ClubViewHomeGroundsState
		},
		{
			key = "Sharing",
			colSize = 2,
			image = "academy/teams/edit team/sharing",
			colStart = 3,
			rowStart = 3,
			rowSize = 1,
			title = native.Localise("Sharing"),
			description = native.Localise("SharingDescription"),
			stateFactory = club_viewstate_sharing_state.ClubViewSharingState,
			locked = var_2_2
		}
	}
end

CommunityTiles = {
	{
		image = "academy/community/search/teams/identity",
		key = "Identity",
		colSize = 1,
		rowStart = 1,
		colStart = 3,
		rowSize = 2,
		isIdentity = true,
		title = native.Localise("Identity"),
		stateFactory = club_viewstate_identity_state.ClubViewIdentityState
	},
	{
		key = "Download",
		colSize = 1,
		image = "academy/community/search/players/download",
		colStart = 1,
		rowStart = 2,
		rowSize = 1,
		title = native.Localise("Download"),
		description = native.Localise("DownloadDescription_Club"),
		subStateFactory = academy_communitystate_clubstate_download_substate.AcademyCommunityClubDownloadSubState
	},
	{
		key = "Rate",
		colSize = 1,
		image = "academy/community/search/players/rate",
		colStart = 1,
		rowStart = 1,
		rowSize = 1,
		title = native.Localise("Rate"),
		description = native.Localise("RateDescription_Club"),
		subStateFactory = academy_communitystate_clubstate_viewstate_rate_substate.AcademyCommunityClubRateSubState
	},
	{
		key = "Report",
		colSize = 1,
		image = "academy/community/search/players/report",
		colStart = 1,
		rowStart = 3,
		rowSize = 1,
		title = native.Localise("Report"),
		description = native.Localise("ReportDescription_Club"),
		subStateFactory = academy_communitystate_clubstate_viewstate_report_substate.AcademyCommunityClubReportSubState
	},
	{
		key = "Sharing",
		colSize = 1,
		image = "academy/community/search/teams/sharing",
		colStart = 2,
		rowStart = 1,
		rowSize = 2,
		title = native.Localise("Sharing"),
		description = native.Localise("SharingDescription_Community"),
		stateFactory = club_viewstate_sharing_state.ClubViewSharingState
	},
	-- copy-academy-jerseys mod: view this FanHub club's uniforms and copy one
	-- into a club you own (fills the empty slot under Sharing)
	{
		key = "Kits",
		colSize = 1,
		image = "academy/teams/edit team/jerseys",
		colStart = 2,
		rowStart = 3,
		rowSize = 1,
		title = native.Localise("Uniforms"),
		description = native.Localise("UniformsDescription"),
		stateFactory = academy_club_jersey_state.AcademyClubJerseyState
	},
	{
		key = "HomeGrounds",
		colSize = 1,
		image = "academy/community/search/teams/home grounds",
		colStart = 3,
		rowStart = 3,
		rowSize = 1,
		title = native.Localise("HomeGround"),
		description = native.Localise("HomeGroundCommunityDescription"),
		stateFactory = club_viewstate_homegrounds_state.ClubViewHomeGroundsState
	},
	{
		key = "ManageRoster",
		colSize = 1,
		image = "academy/community/search/teams/roster",
		colStart = 4,
		rowStart = 1,
		rowSize = 3,
		title = native.Localise("Roster"),
		description = native.Localise("RosterCommunityDescription"),
		stateFactory = academy_communitystate_clubstate_viewstate_roster_state.AcademyCommunityClubRosterState
	}
}
