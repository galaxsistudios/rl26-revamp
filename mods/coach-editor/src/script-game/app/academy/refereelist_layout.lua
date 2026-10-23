import("base.ui.defaults")
import("base.ui.frame.frame_aide")
import("base.ui.scrollbar.scrollbar_aide")
import("design.academy_config")

local var_0_0 = academy_config.RefereeColumns
local var_0_1 = academy_config.RefereeColumnsInitialSort
local var_0_2 = defaults.GapFromScrollBarToMenu

function create(arg_1_0, arg_1_1)
	local var_1_0 = native.UIWidgetArea(arg_1_0)

	var_1_0:setX(0, 100)
	var_1_0:setY(0, 0)
	var_1_0:setHeight(0, 597)
	var_1_0:setWidth(0, 1920)
	var_1_0:setAnchorPoint(0, 0)

	local var_1_1 = native.UIWidgetRefereeGridMenu(arg_1_0)

	for iter_1_0, iter_1_1 in ipairs(var_0_0) do
		var_1_1:addColumn(unpack(iter_1_1))
	end

	var_1_1:sortSetColumn(VERIFY(var_0_1))

	var_1_1.showSelectButton = false
	var_1_1.gapFromColumnEdge = 5
	var_1_1.rowHeight = defaults.RowHeight
	var_1_1.displayCount = 13

	local var_1_2, var_1_3 = scrollbar_aide.create(arg_1_0, var_1_1)

	var_1_1:setScrollBar(var_1_3)
	var_1_2:setX(1, 10)
	var_1_2:setY(1, 0)

	local var_1_4 = var_1_2.width
	local var_1_5, var_1_6, var_1_7, var_1_8, var_1_9, var_1_10, var_1_11 = frame_aide.create(arg_1_0, {
		noSpaceBeforePanel = true,
		wantItemOutline = false,
		height = 0,
		noDropShadow = true,
		isNotTopLevel = true,
		width = var_1_1.width,
		titleBox = {
			title = arg_1_1 or native.Localise("Referee")
		}
	})

	var_1_1:setX(0, 0)
	var_1_1:setWidth(1, 0)

	var_1_1.name = "menu"

	var_1_1:setY(1, 0)
	var_1_0:addChild(var_1_5)

	local var_1_12 = native.UIWidgetQuad(arg_1_0)

	var_1_12:setWidth(1, 0)
	var_1_12:setHeight(0, 20)
	var_1_12:setY(0, 0)

	var_1_12.colour = native.SkinColours.GridMenuTitleRowBackground

	var_1_5:addChild(var_1_12)
	var_1_12:addChild(var_1_1)
	var_1_12:addChild(var_1_2)

	local var_1_13 = defaults.RowHeight
	local var_1_14 = native.UIWidgetGridMenuTitleRow(arg_1_0, var_1_1)

	var_1_14:setX(0, 0)
	var_1_14:setHeight(0, 20)
	var_1_14:setY(0, 0)
	var_1_14:setWidth(1, 0)

	var_1_14.name = "titleRow"
	var_1_14.renderSortColumnHighlight = true

	var_1_12:addChild(var_1_14)

	return var_1_1, var_1_2, var_1_3, var_1_0, var_1_6, var_1_7, var_1_8, var_1_9, var_1_14
end
