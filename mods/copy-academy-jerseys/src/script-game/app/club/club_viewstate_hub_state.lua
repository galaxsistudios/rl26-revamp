import("app.club.club_helper")
import("core.foundation.func")
import("core.foundation.tablex")
import("core.foundation.stringx")
import("core.statemachine.statemachine")
import("app.noesis.controls.nvm_buttonMenu")
Class("ClubViewHubState")

function ClubViewHubState.enter(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7, arg_1_8, arg_1_9)
	arg_1_5:toggleLockerRoomVisibility(true)

	local var_1_0 = {
		backInputAllowed = true,
		homeInputAllowed = true
	}
	local var_1_1 = tablex.clone(arg_1_7.tiles)

	for iter_1_0, iter_1_1 in ipairs(var_1_1) do
		if iter_1_1.isIdentity then
			local var_1_2 = VERIFY(arg_1_7.club)
			local var_1_3 = VERIFY(var_1_2.identity)
			local var_1_4 = VERIFY(club_helper.getIdentityDecalTexture(arg_1_2, arg_1_5, var_1_3))

			iter_1_1.customImage = {
				clubLogoTexture = var_1_4,
				additionalImageInfo = {
					rowSize = 1,
					image = "honeycomb/1x2",
					colSize = 2
				}
			}
			iter_1_1.description = stringx.interp(native.Localise("IdentityClubDescription"), {
				name = arg_1_7.club.nickname
			})

			if iter_1_1.lockedGetFn then
				iter_1_1.locked = iter_1_1.lockedGetFn(arg_1_7)
			end
		end

		if iter_1_1.lockedGetFn then
			iter_1_1.locked = iter_1_1.lockedGetFn(arg_1_7)
		end
	end

	arg_1_0.tiles = var_1_1

	local var_1_5 = arg_1_2:getNoesis()
	local var_1_6 = nvm_buttonMenu.NVMButtonMenu()

	var_1_6:populateMenu(var_1_1)
	var_1_6:setTemplate(arg_1_7.inCommunity and "ClubHubFullCommunity" or "ClubHubFull")

	arg_1_0.view = var_1_5:loadViewWithVM("Workspace/views/academy/paAcademyHubView", var_1_6, native.ENoesisViewManagerLayer.POST_SCENE, native.CNoesisViewManager.DefaultPriority)
	arg_1_0.viewModel = var_1_6

	arg_1_5:playerModelUpdate(1, {
		rotationEnabled = false,
		camera = "FullBody_OutsideOfAppearance"
	})

	if arg_1_7.inCommunity then
		arg_1_0.subStateMachine = statemachine.StateMachine(type(arg_1_0))
	end
end

function ClubViewHubState.exit(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4)
	for iter_2_0, iter_2_1 in ipairs(arg_2_0.tiles) do
		local var_2_0 = iter_2_1.customImage and iter_2_1.customImage.clubLogoTexture

		if var_2_0 then
			var_2_0:unload()
		end
	end

	arg_2_0.viewModel:dispose()
	arg_2_0.view:release()
end

function ClubViewHubState.update(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9)
	if arg_3_6:updateBlockingMixins(arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_7) then
		arg_3_0.view.userInputEnabled = false

		return
	elseif not arg_3_0.view.userInputEnabled then
		arg_3_0.view.userInputEnabled = true
	end

	if arg_3_0.subStateMachine and arg_3_0.subStateMachine:getCurrentState() then
		if arg_3_0.subStateMachine:update(arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9) then
			arg_3_0.subStateMachine:changeState(nil, arg_3_2, arg_3_3, arg_3_5, arg_3_6, arg_3_8)

			arg_3_0.subState = nil
		end

		arg_3_0.view.userInputEnabled = false

		return
	end

	-- copy-academy-jerseys mod: open a tile without input (clubViewInfo
	-- .autoOpenTileKey), and close the hub when coming back from it, so the
	-- FanHub club browser's X shortcut lands in and returns from Uniforms
	if arg_3_9.autoOpenTileKey then
		local var_3_auto = func.find(function(arg_3_auto_0, arg_3_auto_1)
			return arg_3_auto_1.key == arg_3_9.autoOpenTileKey
		end, ipairs(arg_3_0.tiles))
		local var_3_tile = var_3_auto and arg_3_0.tiles[var_3_auto]

		arg_3_9.autoOpenTileKey = nil

		if var_3_tile and var_3_tile.stateFactory then
			arg_3_9.key = var_3_tile.key
			arg_3_9.autoCloseOnReturn = true

			arg_3_1:changeState(var_3_tile.stateFactory(), arg_3_2, arg_3_3, arg_3_5, arg_3_6, arg_3_8, arg_3_9, arg_3_0.__proto)

			return
		end
	elseif arg_3_9.autoCloseOnReturn then
		arg_3_9.autoCloseOnReturn = nil
		arg_3_9.key = nil

		arg_3_1:changeState(nil, arg_3_2, arg_3_3, arg_3_5, arg_3_6, arg_3_8, arg_3_9, arg_3_0.__proto)

		return
	end

	if arg_3_9.key then
		arg_3_0.viewModel.FocusElementIdentifier = arg_3_9.key
		arg_3_0.viewModel.ForceElementFocus = true
		arg_3_9.key = nil
	end

	local var_3_0, var_3_1 = arg_3_0.viewModel:update(arg_3_6)

	arg_3_6:addTooltip(nil, native.InputTypes.Decline, native.Localise("Back"))

	if arg_3_6:checkForRelease(arg_3_8.partyMember, native.InputTypes.Decline) and not arg_3_0.viewModel.subMenuClosing then
		arg_3_6:playSound("Back")

		local var_3_2 = arg_3_0.getBackInputAlertParams and arg_3_0:getBackInputAlertParams(arg_3_2, arg_3_3, arg_3_5, arg_3_6, arg_3_8, arg_3_9)

		if var_3_2 then
			arg_3_6:blockingAlert(arg_3_2, arg_3_3, {
				text = VERIFY(var_3_2.text),
				options = VERIFY(var_3_2.options),
				canCancel = var_3_2.canCancel,
				input = arg_3_8.partyMember:getInput(),
				onSelected = var_3_2.onSelected or function(arg_4_0, arg_4_1, arg_4_2)
					if arg_4_2 and arg_4_2.val then
						var_3_0 = true
					end
				end
			})
		else
			var_3_0 = true
		end
	end

	if var_3_0 then
		local var_3_3

		if var_3_1 and var_3_1.stateFactory then
			arg_3_6:playSound("Select")

			var_3_3 = var_3_1.stateFactory()
			arg_3_9.lineupCategory = var_3_1.lineupCategory
			arg_3_9.key = var_3_1.key
		end

		arg_3_1:changeState(var_3_3, arg_3_2, arg_3_3, arg_3_5, arg_3_6, arg_3_8, arg_3_9, arg_3_0.__proto)
	elseif var_3_1 then
		arg_3_0.subStateMachine:changeState(var_3_1.subStateFactory(), arg_3_2, arg_3_3, arg_3_5, arg_3_6, arg_3_8, arg_3_9)
	end
end

function ClubViewHubState.render(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4)
	if arg_5_0.subStateMachine and arg_5_0.subStateMachine:getCurrentState() then
		arg_5_0.subStateMachine:render(arg_5_1, arg_5_2, arg_5_3, arg_5_4)
	end
end
