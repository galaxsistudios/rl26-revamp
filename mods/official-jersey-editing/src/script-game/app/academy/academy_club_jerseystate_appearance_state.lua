import("core.statemachine.statemachine")
import("base.ui.util.preload_aide")
import("app.academy.academy_club_jerseystate_appearancestate_enter_state")
import("intermediatelua.convant.uitextures")
import("design.characters.assetmap")

local var_0_0 = {
	uitextures.MorphBoth.texture,
	uitextures.MorphX.texture,
	uitextures.MorphY.texture
}

-- official-jersey-editing: an official kit (one the on-disc club database has for this
-- club) or a licensed copy (uniformEditable 0, from New Licensed Uniform) opens in the
-- restricted editor; see the jersey edit state
local function var_0_ojeIsOfficialUniform(arg_universe, arg_club, arg_uniform)
	if arg_uniform.config:getOption("uniformEditable") == 0 then
		return true
	end

	local var_ok, var_onDisc = pcall(function()
		return arg_universe:getClubDatabaseOnDisc():isUniformAssociatedWithClub(arg_uniform.name, arg_club.id)
	end)

	return var_ok and var_onDisc and true or false
end

Class("AcademyClubJerseyAppearanceState")

function AcademyClubJerseyAppearanceState.enter(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7, arg_1_8)
	local var_1_0 = arg_1_2:getTextureManager()

	arg_1_0.texturePack = var_1_0:loadPack("ui/textures/appearance.texpack")
	arg_1_0.textures = preload_aide.loadTextures(var_1_0, var_0_0)

	local var_1_1 = arg_1_7
	local var_1_2 = arg_1_7.club
	local var_1_3 = arg_1_8.editUniformIndex
	local var_1_4 = var_1_2:getUniform(var_1_3).config

	var_1_1.officialUniformEdit = var_0_ojeIsOfficialUniform(arg_1_2, var_1_2, var_1_2:getUniform(var_1_3))

	-- official-jersey-editing: sample chest text while editing (kits with Chest text on)
	local var_1_ojeClub = "HOME"

	pcall(function()
		var_1_ojeClub = string.upper(var_1_2.nickname ~= "" and var_1_2.nickname or var_1_2.fullName)
	end)
	rawset(_G, "MOD_OCCASION_TEXT_PREVIEW", {
		"NRL TELSTRA PREMIERSHIP GRAND FINAL",
		var_1_ojeClub .. " V OPPONENT",
		(assetmap.formatOccasionDate and assetmap.formatOccasionDate() or "DATE") .. ", SYDNEY"
	})

	local var_1_5 = native.CVisualConfig("team")

	var_1_5:copy(var_1_4)

	arg_1_0.unmodifiedVisual = var_1_5

	local var_1_6, var_1_7 = arg_1_5:playerModelGetVisualConfig(1)

	function var_1_1.refreshVisual()
		arg_1_5:queueRefresh()
	end

	-- official-jersey-editing: the model was built before the sample chest text was set,
	-- so redraw it now to show the text (kits with Chest text on)
	pcall(var_1_1.refreshVisual)

	function var_1_1.getCurrentConfig()
		return var_1_7
	end

	function var_1_1.getSavedConfig()
		return var_1_4
	end

	var_1_1.undoPrivate = {
		getFn = function()
			local var_5_0 = native.CVisualConfig("team")

			var_5_0:copy(var_1_7)

			return var_5_0
		end,
		setFn = function(arg_6_0)
			var_1_7:copy(arg_6_0)
			var_1_4:copy(var_1_7)
		end
	}

	arg_1_5:toggleLockerRoomVisibility(true)

	arg_1_0.stateMachine = statemachine.StateMachine(arg_1_0.__type)

	arg_1_0.stateMachine:changeState(academy_club_jerseystate_appearancestate_enter_state.AcademyClubJerseyAppearanceEnterState(), arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7)
	arg_1_5:titleSetAreaOfGame("academy", "Academy")
	arg_1_5:titleSetSubAreaOfGame(native.Localise("Clubs"))
end

function AcademyClubJerseyAppearanceState.exit(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7)
	local var_7_0 = arg_7_6
	local var_7_1 = var_7_0.getSavedConfig()
	local var_7_2 = var_7_0.getCurrentConfig()

	var_7_1:copy(var_7_2)

	if not arg_7_0.unmodifiedVisual:matches(var_7_1, false) then
		var_7_0.club.sharing.hasUnsharedModifications = true
	end

	arg_7_4:toggleLockerRoomVisibility(false)
	arg_7_0.stateMachine:changeState(nil, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5, var_7_0)
	arg_7_0.texturePack:unload()
	preload_aide.unloadAssets(arg_7_0.textures)

	var_7_0.refreshVisual = nil
	var_7_0.getCurrentConfig = nil
	var_7_0.undoPrivate = nil
	var_7_0.officialUniformEdit = nil

	rawset(_G, "MOD_OCCASION_TEXT_PREVIEW", nil)
	-- and redraw without it for the kit list
	pcall(arg_7_4.queueRefresh, arg_7_4)

	local var_7_3 = arg_7_5.partyMember

	arg_7_4:profileSaveFrontEndData(var_7_3)
end

function AcademyClubJerseyAppearanceState.update(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5, arg_8_6, arg_8_7, arg_8_8, arg_8_9, arg_8_10)
	arg_8_0.stateMachine:update(arg_8_2, arg_8_3, arg_8_4, arg_8_5, arg_8_6, arg_8_7, arg_8_8, arg_8_9)

	if not arg_8_0.stateMachine:getCurrentState() then
		arg_8_1:changeState(arg_8_10.stateFactoryMap.List(), arg_8_2, arg_8_3, arg_8_5, arg_8_6, arg_8_8, arg_8_9, arg_8_10)
	end
end

function AcademyClubJerseyAppearanceState.render(arg_9_0, arg_9_1, arg_9_2, arg_9_3, arg_9_4)
	arg_9_0.stateMachine:render(arg_9_1, arg_9_2, arg_9_3, arg_9_4)
end
