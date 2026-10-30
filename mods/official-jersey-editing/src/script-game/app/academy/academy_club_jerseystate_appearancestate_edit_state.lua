import("app.academy.academy_appearancestate_edit_state")
import("app.academy.academy_appearancestate_exit_state")
import("app.academy.academy_club_jerseystate_appearancestate_edit_groups")
import("app.academy.academy_helper")
import("core.foundation.tablex")
import("design.academy_config")

local var_0_0 = academy_config.SlowDownFactor
local var_0_1 = 7

local function var_0_2(arg_1_0, arg_1_1)
	if arg_1_0.activeItemIndex == var_0_1 then
		arg_1_1:show()
	else
		arg_1_1:hide()
	end
end

local var_0_3 = academy_helper.updateDecalPreviewMode
local var_0_4 = academy_helper.setPlayerVisualOption
local var_0_5 = academy_helper.applyChangeToVisual
local var_0_6 = academy_appearancestate_edit_state.AppearanceEditState

Class("AcademyClubJerseyAppearanceEditState", var_0_6)

AcademyClubJerseyAppearanceEditState.OverlaySupported = false
AcademyClubJerseyAppearanceEditState.ViewModeSupported = false
AcademyClubJerseyAppearanceEditState.SponsorLogoChange = var_0_2

function AcademyClubJerseyAppearanceEditState.enter(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7)
	local var_2_0 = arg_2_7:getCurrentConfig()
	-- official-jersey-editing: official kits (set by the appearance state) get the
	-- licensed list: Manufacturer (cut) and numbers only. Stock always used Custom.
	local var_2_1 = arg_2_7.officialUniformEdit and true or false
	local var_2_2 = tablex.iclone(var_2_1 and academy_club_jerseystate_appearancestate_edit_groups.LicensedGroupList or academy_club_jerseystate_appearancestate_edit_groups.CustomGroupList)
	local var_2_3 = arg_2_6.debugHook

	if var_2_3 and var_2_3.isArtist then
		table.insert(var_2_2, academy_club_jerseystate_appearancestate_edit_groups.DebugGroup)
	end

	arg_2_0.GroupList = var_2_2

	var_0_6.enter(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7)

	local var_2_4 = native.UIWidgetTexture(arg_2_2)

	var_2_4.name = "socksLogo"

	var_2_4:load("ui/textures/sponsor/legends.texture")
	var_2_4:setX(0, 90)
	var_2_4:setY(0, 650)
	var_2_4:setAnchorPoint(0.5, 0.5)
	var_2_4:hide()
	arg_2_0.tabUIState.area:addChild(var_2_4)

	arg_2_0.sponsorLogoWidget = var_2_4
end

function AcademyClubJerseyAppearanceEditState.update(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9)
	-- official-jersey-editing: name / chest text placement rows (sticks, like a logo)
	local var_3_ojeTextPlacement = academy_club_jerseystate_appearancestate_edit_groups.updateTextPlacement

	if var_3_ojeTextPlacement and var_3_ojeTextPlacement(arg_3_2, arg_3_6, arg_3_9) then
		return
	elseif arg_3_9.previewMode then
		var_0_3(arg_3_2, arg_3_6, arg_3_9, arg_3_8)
	else
		var_0_6.update(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9)
	end
end

function AcademyClubJerseyAppearanceEditState.exit(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6)
	var_0_6.exit(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6)

	arg_4_6.previewMode = nil
end

AcademyClubJerseyAppearanceEditState.ExitStateFactory = academy_appearancestate_exit_state.AppearanceExitState
