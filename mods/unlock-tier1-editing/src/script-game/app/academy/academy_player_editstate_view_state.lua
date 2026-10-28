import("app.academy.academy_helper")
import("app.player.player_view_state")
import("app.academy.academy_player_viewstate_tiles")
import("app.academy.academy_player_viewstate_appearance_state")
import("core.foundation.tablex")

local var_0_0 = player_view_state.PlayerViewState

Class("AcademyPlayerEditStateViewState", var_0_0)

AcademyPlayerEditStateViewState.PlayerHoldStick = true

function AcademyPlayerEditStateViewState.enter(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7, arg_1_8)
	arg_1_5:titleSetSubAreaOfGame(string.format("%s / %s", native.Localise("Players"), arg_1_8.fullName))
	ASSERT(arg_1_7.searchOptions)
	ASSERT(arg_1_7.searchOptionsReset)

	arg_1_0.goBackHighlightPlayerId = arg_1_8.id

	local var_1_0 = academy_helper.getCanEdit(arg_1_5, arg_1_8.sharing)
	local var_1_1 = academy_player_viewstate_tiles.CreateTiles(arg_1_6.partyMember, arg_1_6, arg_1_8)

	-- unlock-tier1-editing: the stock Appearance tile is locked for every scanned (tier-1)
	-- player ("Tier1Likeness"). Lock it only when the player can't be edited at all; the
	-- appearance state then shows tier-1 players the edit groups without face options.
	for iter_1_0, iter_1_1 in ipairs(var_1_1) do
		if iter_1_1.stateFactory == academy_player_viewstate_appearance_state.AcademyPlayerViewAppearanceState then
			iter_1_1.lockedGetFn = function(arg_2_0)
				local var_2_0 = arg_1_6.debugHook

				if var_2_0 and var_2_0.isArtist then
					return false
				end

				return not arg_2_0.canEdit
			end
		end
	end

	var_0_0.enter(arg_1_0, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, tablex.merge(arg_1_7, {
		title = native.Localise("EditPlayer"),
		canEdit = var_1_0,
		canEditSkills = var_1_0,
		canEditAttributes = var_1_0,
		player = arg_1_8,
		tiles = var_1_1,
		sex = arg_1_8.identity.sex
	}))

	arg_1_0.editInfo = arg_1_7
end

function AcademyPlayerEditStateViewState.update(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8)
	local var_2_0 = arg_2_0.editInfo

	ASSERT(var_2_0.searchOptions)
	ASSERT(var_2_0.searchOptionsReset)

	local function var_2_1()
		local var_3_0 = arg_2_0.createdPlayerId or arg_2_0.goBackHighlightPlayerId

		arg_2_1:changeState(var_2_0.stateFactoryMap.List(), arg_2_2, arg_2_3, arg_2_5, arg_2_6, arg_2_8, var_2_0, var_3_0)
	end

	var_0_0.update(arg_2_0, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, var_2_1)
end

function AcademyPlayerEditStateViewState.checkReadOnlyStatus(arg_4_0, arg_4_1, arg_4_2)
	if not arg_4_2.sharingInformation then
		return
	end

	local var_4_0 = arg_4_2.player

	if arg_4_2.canEdit then
		local var_4_1 = arg_4_1:sharingGetUserId()

		if not (var_4_1 == var_4_0.sharing.originalAuthor or var_4_1 == var_4_0.sharing.currentAuthor) and arg_4_2.sharingInformation.isOnSharingServer then
			return var_4_0.sharing.readOnly
		end
	end
end
