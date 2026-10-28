import("base.ui.tilemenu.tilemenu_state")
import("app.academy.academy_referee_appearance_state")
import("app.npc.npc_viewstate_identity_state")
import("app.npc.npc_viewstate_sharing_state")
import("app.academy.academy_helper")
import("game.player.playergenerator")

local function var_0_0(arg_1_0, arg_1_1)
	local function var_1_0(arg_2_0)
		local var_2_0 = arg_1_1.debugHook

		if var_2_0 and var_2_0.isArtist then
			return false
		end

		return not arg_2_0.canEdit
	end

	return {
		tilemenu_state.createBasicTile(1, 1, 3, 1, "AppearanceReferee", {
			image = "academy/referees/appearance",
			stateFactory = academy_referee_appearance_state.AcademyRefereeAppearanceState,
			additionalTooltips = {},
			lockedGetFn = var_1_0
		}),
		tilemenu_state.createBasicTile(1, 2, 2, 1, "IdentityReferee", {
			image = "academy/referees/Identity",
			stateFactory = npc_viewstate_identity_state.NPCViewIdentityState
		}),
		tilemenu_state.createBasicTile(3, 2, 1, 1, "Sharing", {
			image = "academy/player/sharing",
			stateFactory = npc_viewstate_sharing_state.NPCViewSharingState,
			lockedGetFn = var_1_0
		})
	}
end

local var_0_1 = tilemenu_state.TileMenuState

Class("AcademyRefereeEditHub", var_0_1)

function AcademyRefereeEditHub.enter(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9)
	arg_3_5:playerModelUpdate(1, {
		refresh = true,
		rotationEnabled = true,
		camera = "HeadAndShoulders_OutsideOfAppearance",
		characterVisualOptions = academy_helper.VisualConfigSets.RefereeDefault
	})

	local var_3_0 = var_0_0(arg_3_6.partyMember, arg_3_6)

	if playergenerator.isCoachNPC(arg_3_6.referee) then
		playergenerator.coachTiles(var_3_0)
	end

	for iter_3_0, iter_3_1 in ipairs(var_3_0) do
		if iter_3_1.lockedGetFn then
			iter_3_1.locked = iter_3_1.lockedGetFn(arg_3_7)
		end
	end

	var_0_1.enter(arg_3_0, arg_3_2, arg_3_3, arg_3_4, arg_3_5, var_3_0, arg_3_8, arg_3_9, {
		backInputAllowed = true
	})

	local var_3_1 = arg_3_0.tileMenu

	var_3_1:setX(0, 0)
	var_3_1:setAnchorPoint(0, 0.5)
end

function AcademyRefereeEditHub.exit(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4)
	arg_4_4:playerModelUpdate(1, {
		characterVisualOptions = academy_helper.VisualConfigSets.RefereeDefault
	})
	var_0_1.exit(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4)
end

function AcademyRefereeEditHub.getBackInputAlertParams(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6)
	if arg_5_6.isNew and not arg_5_6.getHaveEverBeenDirty() then
		arg_5_6.isUnchangedAndNew = true

		return {
			options = "yesno",
			canCancel = true,
			text = playergenerator.npcText(arg_5_6.referee, "DeleteUnchangedUmpire"),
			onSelected = function(arg_6_0, arg_6_1, arg_6_2)
				if arg_6_2 then
					if arg_6_2.val then
						arg_5_4:getRefereeManager().userCreated:deleteReferee(arg_5_6.referee.id)
						arg_5_4:showNotification("alert", playergenerator.npcText(arg_5_6.referee, "UnchangedUmpireDeleted"))
					else
						arg_5_6.setDirty()
						arg_5_6.saveIfDirty(arg_6_0)
					end

					arg_5_0.exitAt = arg_6_1 + arg_5_0.area:kickFancyExitAnimation(false)
				end
			end
		}
	end
end

function AcademyRefereeEditHub.update(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7, arg_7_8, arg_7_9)
	local var_7_0, var_7_1 = var_0_1.update(arg_7_0, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7, arg_7_8.partyMember:getInput(), arg_7_8, arg_7_9)

	if var_7_0 then
		local var_7_2

		if var_7_1 then
			var_7_2 = var_7_1.stateFactory()
		end

		arg_7_1:changeState(var_7_2, arg_7_2, arg_7_3, arg_7_5, arg_7_6, arg_7_8, arg_7_9, arg_7_0.__proto)
	elseif var_7_1 then
		local var_7_3 = var_7_1.subStateFactory()

		var_7_3:enter(arg_7_2, arg_7_3, arg_7_5, arg_7_6, arg_7_8, arg_7_9)
		arg_7_0:setSubState(var_7_3)
	end
end
