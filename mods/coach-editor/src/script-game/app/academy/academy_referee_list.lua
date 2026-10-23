import("app.academy.refereelist_layout")
import("app.academy.academy_helper")
import("base.ui.defaults")

local var_0_0 = native.InputTypes
local var_0_1 = defaults.GapFromScrollBarToMenu

Class("AcademyRefereeListState")

function AcademyRefereeListState.enter(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7)
	assert(not arg_1_7.filterAllowed or arg_1_7.searchOptions and arg_1_7.searchOptionsReset)

	arg_1_0.listConfig = arg_1_7

	local var_1_0 = not arg_1_6

	arg_1_0:createArea(arg_1_1, arg_1_2, arg_1_4, arg_1_5, var_1_0, arg_1_7)
	arg_1_0:refreshMenuItems(arg_1_4, arg_1_5, arg_1_6)

	if arg_1_7.playerModelConfig then
		arg_1_4:setPlayerModelProps(1, nil)

		arg_1_0.originalPlayerDrawnEnabledState = arg_1_4:playerModelUpdate(1, {
			draw = true,
			resetOptions = true,
			rotationEnabled = true,
			camera = arg_1_7.playerModelConfig.cameraName or "FullBody_OutsideOfAppearance",
			characterVisualOptions = academy_helper.VisualConfigSets.RefereeDefault
		})

		arg_1_0:immediateRefreshPlayerModel(arg_1_4, arg_1_2, arg_1_5, arg_1_0.menu.highlightedReferee, arg_1_7)
	end

	arg_1_4:toggleLockerRoomVisibility(true)
end

function AcademyRefereeListState.exit(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4)
	arg_2_0.area:dispose()

	if arg_2_0.listConfig.playerModelConfig then
		arg_2_4:playerModelUpdate(1, {
			draw = arg_2_0.originalPlayerDrawnEnabledState
		})
	end
end

function AcademyRefereeListState.getParentStateInputAllowed(arg_3_0, arg_3_1, arg_3_2)
	if arg_3_0.exitAt then
		return false
	end

	if arg_3_1 < arg_3_0.allowInputAfter or not arg_3_2:getInputAllowed() then
		return false
	end

	return true
end

function AcademyRefereeListState.createArea(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6)
	local var_4_0, var_4_1, var_4_2, var_4_3, var_4_4, var_4_5, var_4_6, var_4_7, var_4_8 = refereelist_layout.create(arg_4_1, arg_4_6.listTitle)
	local var_4_9 = var_4_3:fadeIn()

	arg_4_0.menu = var_4_0
	arg_4_0.scrollBarBg = var_4_1
	arg_4_0.scrollBar = var_4_2
	arg_4_0.contentArea = var_4_4
	arg_4_0.titleRowBlack = var_4_5
	arg_4_0.titleRowWhite = var_4_6
	arg_4_0.titleBox = var_4_7
	arg_4_0.menuTitleRow = var_4_8
	arg_4_0.area = var_4_3
	arg_4_0.allowInputAfter = arg_4_2 + var_4_9
end

function AcademyRefereeListState.refreshMenuItems(arg_5_0, arg_5_1, arg_5_2, arg_5_3)
	local var_5_0 = arg_5_0.listConfig
	local var_5_1 = arg_5_1:getRefereeManager()
	local var_5_2 = arg_5_1:getClubManager()

	arg_5_0.menu:populate_Academy(var_5_1, var_5_2, var_5_0.searchOptions, arg_5_3)
	arg_5_0:onHighlightedRefereeChanged(arg_5_1, arg_5_2, var_5_0)
end

function AcademyRefereeListState.onHighlightedRefereeChanged(arg_6_0, arg_6_1, arg_6_2, arg_6_3)
	return
end

function AcademyRefereeListState.immediateRefreshPlayerModel(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5)
	arg_7_0.pmWantingReferee = arg_7_4
	arg_7_0.pmRefreshAt = arg_7_2

	arg_7_0:delayedRefreshPlayerModel(arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5)
end

function AcademyRefereeListState.delayedRefreshPlayerModel(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5)
	if not arg_8_5.playerModelConfig then
		return
	end

	if arg_8_4 then
		if arg_8_4 ~= arg_8_0.pmShowingReferee then
			if arg_8_4 == arg_8_0.pmWantingReferee then
				if arg_8_2 >= arg_8_0.pmRefreshAt then
					arg_8_1:playerModelUpdate(1, {
						refresh = true,
						draw = true,
						referee = arg_8_4
					})

					arg_8_0.pmShowingReferee = arg_8_4
					arg_8_0.pmWantingReferee = nil
					arg_8_0.pmRefreshAt = nil
				end
			else
				arg_8_0.pmWantingReferee = arg_8_4
				arg_8_0.pmRefreshAt = arg_8_2 + 0.4
			end
		end
	else
		arg_8_1:playerModelUpdate(1, {
			draw = false
		})

		arg_8_0.pmShowingReferee = nil
		arg_8_0.pmWantingReferee = nil
		arg_8_0.pmRefreshAt = nil
	end
end

function AcademyRefereeListState.getIsSubStateActive(arg_9_0)
	return arg_9_0.subState ~= nil
end

function AcademyRefereeListState.update(arg_10_0, arg_10_1, arg_10_2, arg_10_3, arg_10_4, arg_10_5, arg_10_6, arg_10_7, arg_10_8)
	local var_10_0 = arg_10_1:getGameControlManager()
	local var_10_1 = arg_10_0.listConfig
	local var_10_2 = arg_10_0.menu
	local var_10_3 = arg_10_0.menuTitleRow
	local var_10_4 = var_10_2.highlightedReferee
	local var_10_5 = var_10_2.highlightColumnIndex == var_10_2.sortColumnIndex

	arg_10_0:immediateRefreshPlayerModel(arg_10_5, arg_10_2, arg_10_7, var_10_4, var_10_1)

	local var_10_6 = arg_10_0.area

	var_10_6:update(arg_10_3)

	if arg_10_0.subState then
		if arg_10_0.subState:update(arg_10_1, arg_10_2, arg_10_3, arg_10_4, arg_10_5, arg_10_6, arg_10_7) then
			arg_10_0.subState:exit(arg_10_1, arg_10_2, arg_10_4, arg_10_5)

			arg_10_0.subState = nil

			arg_10_0:refreshMenuItems(arg_10_5, arg_10_7, var_10_4 and var_10_4.id)
		end

		return
	end

	if arg_10_5:updateBlockingMixins(arg_10_1, arg_10_2, arg_10_3, arg_10_4, arg_10_6) then
		return
	end

	if arg_10_0.exitAt then
		if arg_10_2 >= arg_10_0.exitAt then
			if arg_10_0.homeScreenPartyMember then
				arg_10_5:homeScreenEnter(arg_10_1, arg_10_2, arg_10_4, arg_10_5, arg_10_0.homeScreenPartyMember, true)
			else
				return true, nil, nil, arg_10_0.selectedPlayer, arg_10_0.additionalInformation
			end
		end

		return
	end

	if arg_10_2 < arg_10_0.allowInputAfter or not arg_10_5:getInputAllowed() then
		return
	end

	if var_10_1.sortAllowed and var_10_2.highlightColumnSortAllowed then
		arg_10_5:addTooltip(arg_10_0.tooltipsWidget, var_0_0.X, native.Localise(var_10_5 and "SortToggle" or "Sort"), 1)
	end

	if var_10_1.filterAllowed then
		arg_10_5:addTooltip(arg_10_0.tooltipsWidget, var_0_0.Y, native.Localise("Filter"), 2)
	end

	if var_10_1.backInputAllowed then
		arg_10_5:addTooltip(arg_10_0.tooltipsWidget, var_0_0.Decline, native.Localise("Back"), 99)
	end

	if var_10_1.homeInputAllowed then
		arg_10_5:addHomeTooltip(arg_10_1, arg_10_0.tooltipsWidget)
	end

	local var_10_7 = arg_10_5:mouseProcessWidget(var_10_2)
	local var_10_8 = arg_10_5:mouseProcessWidget(var_10_3)
	local var_10_9 = arg_10_7:checkForRepeatingInput(arg_10_2, var_10_0, var_0_0.Up)
	local var_10_10 = arg_10_7:checkForRepeatingInput(arg_10_2, var_10_0, var_0_0.Down)
	local var_10_11 = var_10_7 and var_10_7.highlightChanged
	local var_10_12

	if var_10_9 or var_10_10 then
		var_10_2:setCanvasAutoScrollEnabled(true)

		var_10_12 = var_10_2:scrollBy(var_10_9 and -1 or 1)
	elseif var_10_11 then
		var_10_2:setCanvasAutoScrollEnabled(false)

		var_10_2.activeItemIndex = var_10_7.highlightIndex
		var_10_12 = true
	end

	if var_10_12 then
		arg_10_5:playSound("ScrollSmall")
		arg_10_0:onHighlightedRefereeChanged(arg_10_5, arg_10_7, var_10_1)

		return false, var_10_2.highlightedReferee, nil, nil
	end

	if var_10_1.sortAllowed then
		local var_10_13 = arg_10_7:checkForRepeatingInput(arg_10_2, var_10_0, var_0_0.Left)
		local var_10_14 = arg_10_7:checkForRepeatingInput(arg_10_2, var_10_0, var_0_0.Right)
		local var_10_15 = var_10_8 and var_10_8.highlightChanged
		local var_10_16

		if var_10_13 or var_10_14 then
			var_10_16 = var_10_2:scrollColumnHighlightBy(var_10_13 and -1 or 1)

			var_10_3:invalidateRenderBuffers()
		elseif var_10_15 then
			var_10_2:scrollColumnHighlightSet(var_10_8.highlightIndex)
			var_10_3:invalidateRenderBuffers()

			var_10_16 = true
		end

		if var_10_16 then
			arg_10_5:playSound("ScrollSmall")
		end
	end

	if (arg_10_5:checkForRelease(arg_10_7, var_0_0.Accept) or var_10_7 and var_10_7.selected) and var_10_4 then
		arg_10_5:playSound("Select")

		if var_10_1.exitOnSelection then
			if arg_10_8 then
				local function var_10_17(arg_11_0)
					arg_10_0.exitAt = arg_11_0 + var_10_6:fadeOut()
					arg_10_0.selectedPlayer = var_10_4
				end

				arg_10_8(var_10_4, var_10_17)
			else
				arg_10_0.exitAt = arg_10_2 + var_10_6:fadeOut()
				arg_10_0.selectedPlayer = var_10_4
			end
		else
			return false, nil, nil, var_10_4
		end
	end

	if arg_10_5:checkForRelease(arg_10_7, var_0_0.X) or var_10_8 and var_10_8.selected then
		if var_10_1.sortAllowed and var_10_2.highlightColumnSortAllowed then
			arg_10_5:playSound("Filter")
			var_10_2:sortGotInput()
			var_10_3:invalidateRenderBuffers()
		end
	elseif arg_10_5:checkForRelease(arg_10_7, var_0_0.Y) then
		if var_10_1.filterAllowed then
			arg_10_5:playSound("SelectAlternative")

			arg_10_0.subState = arg_10_0.SearchOptionsSubStateFactory()

			arg_10_0.subState:enter(arg_10_1, arg_10_2, arg_10_4, arg_10_5, arg_10_7, var_10_1)
		end
	elseif arg_10_5:checkForRelease(arg_10_7, var_0_0.Decline) then
		if var_10_1.backInputAllowed and (not arg_10_0.onBackInputRecieved or arg_10_0:onBackInputRecieved(arg_10_1, arg_10_2, arg_10_4, arg_10_5, arg_10_7, var_10_1)) then
			arg_10_5:playSound("Back")

			arg_10_0.exitAt = arg_10_2 + var_10_6:fadeOut()
		end
	elseif var_10_1.homeInputAllowed then
		arg_10_0.homeScreenPartyMember = arg_10_5:homeScreenCheckForInput(arg_10_1, arg_10_2, arg_10_4)

		if arg_10_0.homeScreenPartyMember then
			arg_10_5:playSound("Back")

			arg_10_0.exitAt = arg_10_2 + var_10_6:fadeOut()
		end
	end
end

function AcademyRefereeListState.render(arg_12_0, arg_12_1, arg_12_2, arg_12_3, arg_12_4)
	arg_12_0.area:doRender(arg_12_1, arg_12_4)

	if arg_12_0.subState then
		arg_12_0.subState:render(arg_12_1, arg_12_2, arg_12_3, arg_12_4)
	end
end
