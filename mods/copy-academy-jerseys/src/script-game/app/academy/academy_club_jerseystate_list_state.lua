import("app.academy.academy_club_jerseystate_list_defaults")
import("app.academy.academy_club_jerseystate_appearancestate_edit_groups")
import("app.academy.academy_helper")
import("app.alert.alert_state")
import("base.ui.optionmenu.optionmenu_aide")
import("base.ui.optionmenu.optionmenu_state")
import("base.ui.textinput.textinput_substate")
import("core.foundation.func")
import("core.foundation.stringx")

local var_0_0 = native.InputTypes
local var_0_1 = true

local function var_0_2(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6)
	local var_1_0 = {}
	local var_1_1 = arg_1_2.debugHook
	local var_1_2 = var_1_1 and var_1_1.isArtist
	local var_1_3 = arg_1_0:getClubDatabaseOnDisc()
	-- copy-academy-jerseys mod: viewing a FanHub club, selecting a uniform
	-- copies it into one of your clubs instead of opening the editor
	local var_1_copy = arg_1_3.inCommunity and arg_1_3.stateFactoryMap.CopyToClub

	for iter_1_0 = 1, arg_1_4.uniformCount do
		local var_1_4 = arg_1_4:getUniform(iter_1_0)

		if not var_1_4.isHidden or var_1_2 then
			local var_1_5 = var_1_3:isUniformAssociatedWithClub(var_1_4.name, arg_1_4.id)
			local var_1_6 = var_1_4.config:getOption("uniformEditable") == 1 and true or false
			local var_1_7 = not var_1_5 and arg_1_5 and var_1_6
			-- official-jersey-editing (when installed): official kits and licensed copies open
			-- in a restricted editor (Manufacturer cut and numbers only)
			local var_1_official = arg_1_5 and academy_club_jerseystate_appearancestate_edit_groups.OfficialKitEditing and (var_1_5 or not var_1_6)

			table.insert(var_1_0, {
				label = var_1_4:getDisplayName(iter_1_0),
				editable = var_1_2 or var_1_7 or var_1_official or var_1_copy and true,
				editType = optionmenu_aide.EditTypes.SubMenu,
				onDisc = var_1_5,
				displayType = optionmenu_aide.DisplayTypes.Value,
				uniformIndex = iter_1_0,
				uniform = var_1_4,
				stateFactory = var_1_copy or arg_1_3.stateFactoryMap.Appearance
			})
		end
	end

	-- copy-academy-jerseys mod: KIT LIBRARY - the club's kits kept outside its
	-- 20 slots (KitLibrary, see academy_club_jersey_state). Shown even when the
	-- club is full: a library kit can replace one of its kits
	if arg_1_3.stateFactoryMap.KitLibrary and not arg_1_3.inCommunity and (var_1_2 or arg_1_5) then
		local var_1_libOk, var_1_lib = pcall(function()
			return import("intermediatelua.data.jigglyjointsconfig").KitLibrary
		end)
		local var_1_libCount = var_1_libOk and var_1_lib and var_1_lib[arg_1_4.id] and #var_1_lib[arg_1_4.id] or 0

		if var_1_libCount > 0 then
			table.insert(var_1_0, {
				displayType = optionmenu_aide.DisplayTypes.Separator
			})
			table.insert(var_1_0, {
				editable = true,
				label = string.format("KIT LIBRARY (%d)", var_1_libCount),
				editType = optionmenu_aide.EditTypes.SubMenu,
				displayType = optionmenu_aide.DisplayTypes.Value,
				stateFactory = arg_1_3.stateFactoryMap.KitLibrary
			})
		end
	end

	-- crowd-fangear (when installed): FANGEAR LIBRARY - the fan tees, polos and
	-- scarves this club's crowd wears, each switchable on and off
	if arg_1_3.stateFactoryMap.FangearLibrary and not arg_1_3.inCommunity then
		local var_1_fgOk, var_1_fgCount = pcall(function()
			local var_1_fgItems = import("intermediatelua.crowd.crowd_items")
			local var_1_fgIcon = var_1_fgItems.FangearClubs and var_1_fgItems.FangearClubs[arg_1_4.id]

			return var_1_fgIcon and var_1_fgItems.FangearLibrary and #(var_1_fgItems.FangearLibrary[var_1_fgIcon] or {}) or 0
		end)

		var_1_fgCount = var_1_fgOk and var_1_fgCount or 0

		if var_1_fgCount > 0 then
			table.insert(var_1_0, {
				displayType = optionmenu_aide.DisplayTypes.Separator
			})
			table.insert(var_1_0, {
				editable = true,
				label = string.format("FANGEAR LIBRARY (%d)", var_1_fgCount),
				editType = optionmenu_aide.EditTypes.SubMenu,
				displayType = optionmenu_aide.DisplayTypes.Value,
				stateFactory = arg_1_3.stateFactoryMap.FangearLibrary
			})
		end
	end

	if arg_1_4.uniformCanCreateCount > 0 and (var_1_2 or arg_1_5) then
		table.insert(var_1_0, {
			displayType = optionmenu_aide.DisplayTypes.Separator
		})

		local var_1_8 = arg_1_4.identity.sex == native.CSex.Male and native.DefaultTeamVisuals.NewCustomMale or native.DefaultTeamVisuals.NewCustomFemale
		local var_1_9 = arg_1_1:getDefaultTeamVisual(var_1_8)

		var_1_9:setOption("showTeamLogo", arg_1_4.identity.showUniformEmblemDecals and 1 or 0)
		table.insert(var_1_0, {
			editable = true,
			label = native.Localise("NewLicensedUniform"),
			editType = optionmenu_aide.EditTypes.SubMenu,
			displayType = optionmenu_aide.DisplayTypes.Value,
			stateFactory = arg_1_3.stateFactoryMap.CopyLicensed
		})

		-- copy-academy-jerseys mod: copy a jersey from any club (edited
		-- official, user-created or downloaded), see academy_club_jersey_state
		if arg_1_3.stateFactoryMap.CopyAcademy then
			table.insert(var_1_0, {
				editable = true,
				label = "COPY ACADEMY UNIFORM",
				editType = optionmenu_aide.EditTypes.SubMenu,
				displayType = optionmenu_aide.DisplayTypes.Value,
				stateFactory = arg_1_3.stateFactoryMap.CopyAcademy
			})
		end
		table.insert(var_1_0, {
			editable = true,
			label = native.Localise("NewCustomUniform"),
			editType = optionmenu_aide.EditTypes.SubMenu,
			displayType = optionmenu_aide.DisplayTypes.Value,
			stateFactory = arg_1_3.stateFactoryMap.Appearance,
			newJerseyCopyFrom = var_1_9
		})
	end

	return var_1_0
end

-- copy-academy-jerseys mod: LB on a jersey saves its design info - club,
-- kit, sex and the design items (guid + item name) for the top, shorts and
-- socks - to Documents\RL26Jersey_<club>_<kit>.json. The kit's pixels come
-- from a RenderDoc capture of the same screen (tools/renderdoc_kit.py), and
-- tools/fanhub_kit_import.py turns the pair into a kit. Reading the composited
-- textures back from Lua (CRenderUtils.textureToDataBuffer) returned zeros or
-- stale data for every texture, so it was dropped (2026-10-29).
local function jerseyExportLog(fmt, ...)
	local ok, msg = pcall(string.format, fmt, ...)
	local okOpen, file = pcall(io.open, "jerseyexport_debug.txt", "a")

	if okOpen and file then
		file:write(os.date("%H:%M:%S "), ok and msg or fmt, "\n")
		file:close()
	end
end

local function jerseyExportSafeName(text)
	text = string.lower(tostring(text or ""))
	text = string.gsub(text, "[^%w]+", "_")
	text = string.gsub(text, "^_+", "")
	text = string.gsub(text, "_+$", "")

	return text ~= "" and text or "jersey"
end

local function jerseyExportClubName(club)
	local ok, name = pcall(function()
		return club.fullName or club.identity.fullName or club.identity.name
	end)

	return ok and name or "club" .. tostring(club.id)
end

local function jerseyExportJson(value, indent)
	indent = indent or ""

	if type(value) == "table" then
		local keys = {}

		for key in pairs(value) do
			table.insert(keys, key)
		end

		if #keys == 0 then
			return "{}"
		end

		if #value == #keys then
			local items = {}

			for _, item in ipairs(value) do
				table.insert(items, indent .. "  " .. jerseyExportJson(item, indent .. "  "))
			end

			return "[\n" .. table.concat(items, ",\n") .. "\n" .. indent .. "]"
		end

		table.sort(keys, function(a, b)
			return tostring(a) < tostring(b)
		end)

		local items = {}

		for _, key in ipairs(keys) do
			table.insert(items, string.format("%s  %q: %s", indent, tostring(key), jerseyExportJson(value[key], indent .. "  ")))
		end

		return "{\n" .. table.concat(items, ",\n") .. "\n" .. indent .. "}"
	elseif type(value) == "string" then
		return (string.gsub(string.format("%q", value), "\\\n", "\\n"))
	elseif type(value) == "boolean" or type(value) == "number" then
		return tostring(value)
	end

	return "null"
end

local function jerseyExportSave(engine, arg3, uiServices, input, club, uniform)
	local okHome, home = pcall(os.getenv, "USERPROFILE")
	local clubName = jerseyExportClubName(club)
	local path = (okHome and home and home ~= "" and home .. "\\Documents\\" or "") .. "RL26Jersey_" .. jerseyExportSafeName(clubName) .. "_" .. jerseyExportSafeName(uniform.name) .. ".json"
	local config = uniform.config
	local info = {
		club = clubName,
		clubId = club.id,
		kit = uniform.name,
		isNines = uniform.isNines and true or false
	}

	for _, option in ipairs({ "sex", "uniformTop", "uniformBottom", "uniformSocks", "uniformTop_patternLayer01", "uniformEditable" }) do
		local ok, value = pcall(config.getOption, config, option)

		info[option] = ok and value or nil
	end

	-- the design items' names give the importer the models (and so the UV
	-- layouts) the textures belong to; assetmap is loaded by the jersey editor
	pcall(function()
		local map = rawget(_G, "assetmap")

		for _, option in ipairs({ "uniformTop", "uniformBottom", "uniformSocks" }) do
			local item = info[option] and map.getItemByGuid(map.AssetMapItems[option], info[option])

			info[option .. "Item"] = item and item.name or nil
		end
	end)

	local ok, file = pcall(io.open, path, "w")
	local text

	if ok and file then
		file:write(jerseyExportJson(info), "\n")
		file:close()

		text = "Saved the jersey's design info to\n" .. path .. "\nCapture this screen with RenderDoc (F12) for the textures."
	else
		text = "Couldn't write " .. path
	end

	jerseyExportLog("export %s / %s -> %s (top %s %s, bottom %s, socks %s): %s", clubName, tostring(uniform.name), path, tostring(info.uniformTop), tostring(info.uniformTopItem), tostring(info.uniformBottom), tostring(info.uniformSocks), ok and file and "ok" or "failed")

	pcall(function()
		uiServices:blockingAlert(engine, arg3, {
			options = "ok",
			canCancel = true,
			text = text,
			input = input
		})
	end)
end


local var_0_3 = alert_state.AlertState

Class("AcademyClubJerseyList_RestoreOfficialJerseys", var_0_3)

function AcademyClubJerseyList_RestoreOfficialJerseys.enter(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7)
	var_0_3.enter(arg_2_0, arg_2_1, arg_2_2, arg_2_4, {
		options = "yesno",
		canCancel = true,
		text = native.Localise("RestoreOfficialJerseys_AreYouSure")
	})

	arg_2_0.uiInput = arg_2_5
end

function AcademyClubJerseyList_RestoreOfficialJerseys.update(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7)
	local var_3_0, var_3_1 = var_0_3.update(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_5, arg_3_6, arg_3_0.uiInput)

	if var_3_0 and var_3_1.val then
		local var_3_2 = VERIFY(arg_3_7.clubViewInfo)
		local var_3_3 = arg_3_5:getClubManager()
		local var_3_4 = VERIFY(var_3_2.club)
		local var_3_5 = var_3_3.onDisc:getClub(var_3_4.id)

		var_3_4:copyJerseysFrom(var_3_5)
		var_3_2.setDirty()

		VERIFY(arg_3_7.listState).menuItems = var_0_2(arg_3_1, arg_3_5, arg_3_7.academyData, arg_3_7.jerseyData, var_3_4, var_3_2.canEdit, var_3_2.isOnDiscClub)

		arg_3_5:playerModelSetUniform(1, var_3_4:getHomeUniformVisual())
		arg_3_5:playerModelUpdate(1, {
			refresh = true
		})
	end

	return var_3_0
end

local var_0_4 = optionmenu_state.OptionMenuState

Class("AcademyClubJerseyListState", var_0_4)

function AcademyClubJerseyListState.enter(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7, arg_4_8)
	arg_4_5:toggleLockerRoomVisibility(true)

	local var_4_0 = {
		backInputAllowed = true,
		displayCount = 21,
		noSpaceBeforePanel = true,
		itemParams = {
			listState = arg_4_0,
			academyData = arg_4_6,
			jerseyData = arg_4_8,
			clubViewInfo = arg_4_7
		},
		titleBox = {
			title = native.Localise("Uniforms")
		}
	}
	local var_4_1 = var_0_2(arg_4_2, arg_4_5, arg_4_6, arg_4_8, arg_4_7.club, arg_4_7.canEdit, arg_4_7.isOnDiscClub)
	local var_4_2

	if arg_4_8.editUniformIndex then
		var_4_2 = func.find(function(arg_5_0, arg_5_1)
			return arg_5_1.uniformIndex == arg_4_8.editUniformIndex
		end, ipairs(var_4_1))
		arg_4_8.editUniformIndex = nil
	end

	local var_4_3 = assert(var_4_1[var_4_2 or 1].uniform)

	arg_4_5:playerModelSetUniform(1, var_4_3.config)

	local var_4_4 = VERIFY(arg_4_7.club)

	arg_4_0.club = var_4_4

	local var_4_5 = academy_helper.getCaptainForClub(arg_4_5, var_4_4)

	arg_4_0.player = var_4_5

	arg_4_5:playerModelUpdate(1, {
		refresh = true,
		camera = "FullBody_OutsideOfAppearance",
		player = var_4_5,
		club = var_4_4,
		isNines = var_4_3.isNines
	})
	var_0_4.enter(arg_4_0, arg_4_2, arg_4_3, arg_4_4, arg_4_5, var_4_1, var_4_2, var_4_0)

	local var_4_6 = arg_4_0.menu

	var_4_6:setY(0.05, 0)
	var_4_6:setX(0, 0)
	var_4_6:setAnchorPoint(0, 0)

	arg_4_0.canEdit = arg_4_7.canEdit
end

function AcademyClubJerseyListState.addCustomTooltips(arg_6_0, arg_6_1, arg_6_2, arg_6_3)
	return
end

function AcademyClubJerseyListState.update(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7, arg_7_8, arg_7_9, arg_7_10)
	local var_7_0 = assert(arg_7_8.partyMember)

	local var_7_1, var_7_2, var_7_3, var_7_4 = var_0_4.update(arg_7_0, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7, var_7_0:getInput())
	local var_7_5 = arg_7_8.debugHook
	local var_7_6 = var_7_5 and var_7_5.isArtist

	if var_7_1 then
		if var_7_4 then
			local var_7_7 = var_7_4.uniformIndex

			if var_7_4.newJerseyCopyFrom then
				local var_7_8 = arg_7_9.club
				local var_7_9 = var_7_8:addNewUniform()

				var_7_9.name = string.format("%s %d", native.Localise("Jersey"), var_7_8.uniformCount)

				local var_7_10 = var_7_9.config

				var_7_10:copy(var_7_4.newJerseyCopyFrom)
				arg_7_6:playerModelSetUniform(1, var_7_10)
				arg_7_6:playerModelUpdate(1, {
					refresh = true
				})

				var_7_7 = var_7_8.uniformCount

				arg_7_9.setDirty()
			end

			arg_7_10.editUniformIndex = var_7_7

			arg_7_1:changeState(var_7_4.stateFactory(), arg_7_2, arg_7_3, arg_7_5, arg_7_6, arg_7_8, arg_7_9, arg_7_10)
		else
			arg_7_1:changeState(nil, arg_7_2, arg_7_3, arg_7_5, arg_7_6)
		end
	else
		if var_7_2 and var_7_2.uniform then
			local var_7_11 = var_7_2.uniform

			arg_7_6:playerModelSetUniform(1, var_7_11.config)
			arg_7_6:playerModelUpdate(1, {
				refresh = true,
				player = arg_7_0.player,
				club = arg_7_0.club,
				isNines = var_7_11.isNines
			})
		end

		-- copy-academy-jerseys mod: save the highlighted jersey's design info
		-- (any club, FanHub included; artists keep LB for "debug dupe uniform")
		if not arg_7_0.subState and not var_7_6 and not arg_7_6:getIsBlockingMixinActive() then
			local var_7_export = arg_7_0:getHighlightedItemInfo()

			if var_7_export and var_7_export.uniform then
				arg_7_6:addTooltip(arg_7_0.tooltipsWidget, var_0_0.LB, "Export Jersey", 82)

				if arg_7_6:checkForRelease(var_7_0, var_0_0.LB) then
					arg_7_6:playSound("SelectAlternative")
					jerseyExportSave(arg_7_2, arg_7_3, arg_7_6, var_7_0:getInput(), arg_7_9.club, var_7_export.uniform)

					return
				end
			end
		end

		local var_7_12 = not native.getCensorAllUGC()

		if var_7_6 or arg_7_9.canEdit and not arg_7_6:getIsBlockingMixinActive() then
			local var_7_13 = arg_7_9.club
			local var_7_14 = arg_7_0:getHighlightedItemInfo()

			if not arg_7_0.subState then
				if var_7_14.uniformIndex and not var_7_14.onDisc or var_7_6 then
					arg_7_6:addTooltip(arg_7_0.tooltipsWidget, var_0_0.X, native.Localise("Delete"))

					if arg_7_6:checkForRelease(var_7_0, var_0_0.X) then
						arg_7_6:playSound("SelectAlternative")

						if var_7_13.uniformCount > 1 then
							arg_7_6:blockingAlert(arg_7_2, arg_7_3, {
								options = "yesno",
								canCancel = true,
								text = stringx.interp(native.Localise("ConfirmDeleteUniformX"), {
									name = var_7_14.label
								}),
								input = var_7_0:getInput(),
								onSelected = function(arg_8_0, arg_8_1, arg_8_2, arg_8_3)
									if arg_8_2 and arg_8_2.val then
										var_7_13:deleteUniform(var_7_14.uniformIndex)

										arg_7_0.menuItems = var_0_2(arg_8_0, arg_7_6, arg_7_8, arg_7_10, var_7_13, arg_7_9.canEdit, arg_7_9.isOnDiscClub)

										arg_7_0:refreshMenuItems(arg_8_0, arg_7_6)
									end
								end
							})
						else
							arg_7_6:blockingAlert(arg_7_2, arg_7_3, {
								options = "ok",
								canCancel = true,
								text = native.Localise("CannotDeleteClubsOnlyUniform"),
								input = var_7_0:getInput()
							})
						end
					end

					if var_7_12 then
						arg_7_6:addTooltip(arg_7_0.tooltipsWidget, var_0_0.Y, native.Localise("Rename"))

						if arg_7_6:checkForRelease(var_7_0, var_0_0.Y) then
							arg_7_6:playSound("SelectAlternative")

							local var_7_15 = var_7_13:getUniform(var_7_14.uniformIndex)
							local var_7_16 = {
								label = native.Localise("Rename"),
								helpText = native.Localise("UniformNameHelpText"),
								getValue = function()
									return var_7_15:getDisplayName(var_7_14.uniformIndex)
								end,
								setValue = function(arg_10_0)
									var_7_15.name = arg_10_0
									arg_7_0.menuItems = var_0_2(arg_7_2, arg_7_6, arg_7_8, arg_7_10, var_7_13, arg_7_9.canEdit, arg_7_9.isDiscClub)
								end,
								textProperties = {
									allowEmpty = false,
									maxLength = native.CUniform.NAME_MAX_LENGTH
								}
							}

							arg_7_0.subState = textinput_substate.TextInputSubState()

							arg_7_0.subState:enter(arg_7_2, arg_7_3, arg_7_5, arg_7_6, arg_7_8.partyMember, var_7_16)
						end
					end
				end

				if var_0_1 then
					arg_7_6:addTooltip(arg_7_0.tooltipsWidget, var_0_0.RB, native.Localise("SetDefaults"), 80)

					if arg_7_6:checkForRelease(var_7_0, var_0_0.RB) then
						arg_7_6:playSound("SelectAlternative")

						arg_7_0.subState = academy_club_jerseystate_list_defaults.AcademyClubJerseyListDefaultsSubState()

						arg_7_0.subState:enter(arg_7_2, arg_7_3, arg_7_5, arg_7_6, arg_7_8, arg_7_9, arg_7_10)
					end
				end

				local var_7_17 = arg_7_8.debugHook

				if var_7_17 and var_7_17.isArtist and var_7_14.uniformIndex then
					local var_7_18 = var_7_13:getUniform(var_7_14.uniformIndex)

					if var_7_13.uniformCanCreateCount then
						arg_7_6:addTooltip(arg_7_0.tooltipsWidget, var_0_0.LB, "debug dupe uniform", 81)

						if arg_7_6:checkForRelease(var_7_0, var_0_0.LB) then
							arg_7_6:playSound("SelectAlternative")

							local var_7_19 = var_7_18
							local var_7_20 = var_7_13:addNewUniform()

							var_7_20.name = string.format("%s %d", native.Localise("Jersey"), var_7_13.uniformCount)

							var_7_20.config:copy(var_7_19.config)

							arg_7_0.menuItems = var_0_2(arg_7_2, arg_7_6, arg_7_8, arg_7_10, var_7_13, arg_7_9.canEdit, arg_7_9.isOnDiscClub)

							arg_7_0:refreshMenuItems(arg_7_2, arg_7_6)
						end
					end

					arg_7_6:addTooltip(arg_7_0.tooltipsWidget, var_0_0.L3, var_7_18.isHidden and "debug unhide uniform" or "debug hide uniform", 81)

					if arg_7_6:checkForRelease(var_7_0, var_0_0.L3) then
						var_7_18.isHidden = not var_7_18.isHidden
					end
				end
			end
		end
	end
end

function AcademyClubJerseyListState.exit(arg_11_0, arg_11_1, arg_11_2, arg_11_3, arg_11_4)
	arg_11_4:toggleLockerRoomVisibility(false)
	var_0_4.exit(arg_11_0, arg_11_1, arg_11_2, arg_11_3, arg_11_4)
end
