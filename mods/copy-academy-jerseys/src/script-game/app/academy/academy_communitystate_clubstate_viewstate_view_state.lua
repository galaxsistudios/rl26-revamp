import("core.foundation.func")
import("app.club.club_view_state")
import("app.academy.academy_club_viewstate_tiles")

local var_0_0 = club_view_state.ClubViewState

Class("AcademyCommunityClubViewViewState", var_0_0)

function AcademyCommunityClubViewViewState.enter(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7)
	local var_1_0 = assert(arg_1_7.highlightedObjectInfo)

	var_0_0.enter(arg_1_0, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, {
		canEdit = false,
		title = native.Localise("ViewClub"),
		club = VERIFY(var_1_0.object),
		downloadedClubInfo = var_1_0,
		tiles = academy_club_viewstate_tiles.CommunityTiles
	})

	-- copy-academy-jerseys mod: X in the club browser - have the hub open the
	-- Uniforms tile straight away and close again when it's left
	if arg_1_7.openUniformsDirectly then
		arg_1_7.openUniformsDirectly = nil
		arg_1_0.clubViewInfo.autoOpenTileKey = "Kits"
	end
end

function AcademyCommunityClubViewViewState.exit(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5)
	var_0_0.exit(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5)
end

function AcademyCommunityClubViewViewState.update(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9)
	local function var_3_0(arg_4_0)
		if arg_4_0.removedSharedItem then
			local var_4_0 = VERIFY(arg_3_9.highlightedObjectInfo)
			local var_4_1 = VERIFY(arg_3_9.downloadedList)
			local var_4_2 = func.find(function(arg_5_0, arg_5_1)
				return arg_5_1.sharingId == var_4_0.sharingId
			end, ipairs(var_4_1))

			if var_4_2 then
				table.remove(var_4_1, var_4_2)

				local var_4_3 = math.min(var_4_2, #var_4_1)

				arg_3_9.highlightedClubInfo = var_4_1[var_4_3]
			end
		end

		arg_3_1:changeState(nil, arg_3_2, arg_3_3, arg_3_5, arg_3_6, arg_3_8, arg_3_9)
	end

	var_0_0.update(arg_3_0, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, var_3_0)
end
