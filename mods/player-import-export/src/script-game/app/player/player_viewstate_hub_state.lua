import("app.academy.viewhubbase_state")

local var_0_0 = viewhubbase_state.ViewHubBaseState

Class("PlayerViewHubState", var_0_0)

function PlayerViewHubState.enter(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7, arg_1_8, arg_1_9)
	ASSERT(arg_1_7.tiles)

	arg_1_7.camera = "HeadAndShoulders_OutsideOfAppearance"

	var_0_0.enter(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_7, arg_1_8, arg_1_9)
end

function PlayerViewHubState.getBackInputAlertParams(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6)
	if arg_2_6.creatingNewPlayer then
		if arg_2_6.getHaveEverBeenDirty() then
			nop()
		else
			arg_2_6.isUnchangedAndNew = true

			return {
				options = "yesno",
				canCancel = true,
				text = native.Localise("CreateCustomPlayer_DeleteUnchangedPlayer"),
				onSelected = function(arg_3_0, arg_3_1, arg_3_2)
					if arg_3_2 then
						if arg_3_2.val then
							arg_2_4:getPlayerManager().userCreated:deletePlayer(arg_2_6.playerId)

							if arg_2_6.club then
								arg_2_6.club:removePlayer(arg_2_6.playerId)
							end

							arg_2_4:showNotification("alert", native.Localise("CreateCustomPlayer_DeletedUnchangedPlayer"))
						else
							arg_2_6.setDirty()
							arg_2_6.saveIfDirty(arg_3_0)
						end

						arg_2_0.exitAt = arg_3_1
					end
				end
			}
		end
	end
end

-- player-import-export mod ----------------------------------------------------
-- Share players as JSON files:
--   * X on the player hub ("Export Player") saves the player being viewed.
--   * The home screen's Players submenu gets Import Player, Import Players and
--     Export Players (rows added from app/noesis/homescreen/nvm_homescreen.lua).
-- A file holds the player's identity, attributes, skills and appearance. The
-- field lists come from the game's own design tables (identitymap,
-- attributemap, assetmap.options.player). Clubs and lineups are never touched:
-- imported new players are free agents.

import("base.ui.optionmenu.optionmenu_state")
import("base.ui.optionmenu.optionmenu_aide")
import("base.ui.busy.busy_layout")
import("design.characters.assetmap")
import("design.characters.attributemap")
import("design.characters.identitymap")
import("game.player.playergenerator")

PlayerTransfer = {}

local PlayerTransferLabels = {
	exportPlayer = "Export Player",
	importPlayer = "Import Player",
	importPlayers = "Import Players",
	exportPlayers = "Export Players",
	exportEdited = "Edited & Created Players",
	exportAll = "All Players",
	busyImport = "Importing Players",
	busyExport = "Exporting Players",
	reading = "Reading file...",
	importing = "Importing player %d of %d...",
	exporting = "Exporting player %d of %d...",
	writing = "Writing file...",
	saving = "Saving...",
	noDialog = "The file browser could not be opened.",
	exportedOne = "Exported %s to:\n%s",
	exportedMany = "Exported %d player(s) to:\n%s",
	exportSkipped = "%d player(s) could not be read and were left out.",
	writeFailed = "Could not write the file:\n%s\n\n%s",
	readFailed = "Could not read the file:\n%s\n\n%s",
	tooBig = "the file is larger than %d MB",
	serialiseFailed = "Could not read this player's data.",
	nothingToExport = "There are no edited or created players to export.",
	tooManyForSingle = "This file contains %d players. Use Import Players to import more than one player.",
	noValidPlayers = "No players in this file can be imported:",
	confirmSingleUpdate = "Import %s?\n\nThis overwrites the %s %s (#%d) with the data in the file.",
	confirmSingleAdd = "Import %s?\n\nThey will be added as a new player (free agent).",
	confirmMany = "Import %d player(s) from this file?\n\n%d will overwrite existing players.\n%d will be added as new players (free agents).",
	confirmSkipped = "%d entry(ies) have errors and will be skipped:",
	confirmFooter = "Overwritten data can't be restored from this file.",
	baseGamePlayer = "base game player",
	academyPlayer = "Academy player",
	done = "Import finished.",
	countUpdated = "Updated: %d",
	countAdded = "Added as new players: %d",
	countUnchanged = "Already up to date: %d",
	countFailed = "Not imported: %d",
	partial = "%d player(s) had fields that could not be set (listed in playertransfer_debug.txt).",
	missingItems = "%d player(s) use appearance items (hair, heads, gear...) that aren't installed in this game, probably from a mod. Those parts keep their current or default look (listed in playertransfer_debug.txt).",
	freeAgents = "New players are free agents. Add them to a club from the Academy.",
	moreErrors = "...and %d more (all listed in playertransfer_debug.txt in the game folder).",
	storageFull = "the Academy player database is full",
	targetMissing = "the player to update no longer exists",
	cannotEdit = "the player could not be opened for editing",
	cannotCreate = "a new player could not be created",
	unexpected = "an unexpected error occurred (see playertransfer_debug.txt)"
}

-- Log in the game folder (retail Lua has io/os). Errors and per-player import
-- problems are always written; PlayerTransferDebug adds verbose tracing.
local PlayerTransferDebug = false

-- true: native.showFileDialog (blocking, pre-fills the file name). It falls
-- back to the retail async task (no pre-filled name) if that call is missing
-- or fails.
local PlayerTransferUseBlockingDialog = true

local PlayerTransferFormatOne = "RL26PlayerExport"
local PlayerTransferFormatMany = "RL26PlayersExport"
local PlayerTransferVersion = 1
local PlayerTransferMaxPlayers = 10000
local PlayerTransferMaxFileMB = 128
local PlayerTransferMaxUInt = 4294967295
local PlayerTransferMinInt = -2147483648
local PlayerTransferImportBatch = 12
local PlayerTransferExportBatch = 40
local PlayerTransferShownErrors = 6
local PlayerTransferSections = {
	"identity",
	"attributes",
	"skills",
	"appearance"
}

-- sex is decided when a player is created and never changed by an import;
-- photogrammetryStatus belongs to scanned (tier-1) heads.
local PlayerTransferSkipIdentity = {
	sex = true,
	photogrammetryStatus = true
}

-- version/sex are owned by the game; ugcHead/headUuid point at a photo in the
-- local image store, which doesn't exist on another machine.
local PlayerTransferSkipAppearance = {
	version = true,
	sex = true,
	ugcHead = true,
	headUuid = true
}

-- The only appearance options taken from a tier-1 (scanned) player's export
-- when it becomes a new player: the stock game never copies a scanned likeness.
local PlayerTransferBodyAppearance = {
	height = true,
	weight = true,
	fitness = true
}

-- Appearance options that pick an item (a model) from assetmap.AssetMapItems.
-- An item a mod adds on the exporter's machine may not exist on the importer's,
-- and a missing head asset aborts the game, so these are checked against the
-- live lists (mod additions included) and dropped when the item isn't there.
-- Verified against a 4,060-player export: every stock value is in its list.
-- head is the scanned-head guid (0 = generic face) and lives in tier1head.
local PlayerTransferItemMaps = {
	head = "tier1head",
	body = "body",
	hair = "hair",
	hairTop = "hairTop",
	hairSide = "hairSide",
	hairSide2 = "hairSide2",
	beard = "beard",
	moustache = "moustache",
	chinhair = "chinhair",
	sideburns = "sideburns",
	helmet = "helmet",
	shoes = "shoes",
	sockHeight = "sockHeight",
	topType = "topType",
	eyeSocketTint_type = "eyeSocketTint_type"
}

local function playerTransferLogError(text)
	pcall(function()
		local file = io.open("playertransfer_debug.txt", "a")

		if file then
			file:write(os.date("%Y-%m-%d %H:%M:%S ") .. tostring(text) .. "\n")
			file:close()
		end
	end)
end

local function playerTransferLog(text)
	if PlayerTransferDebug then
		playerTransferLogError(text)
	end
end

local function playerTransferTraceback(err)
	if debug and debug.traceback then
		return debug.traceback(tostring(err), 2)
	end

	return tostring(err)
end

local function playerTransferSafe(fn, ...)
	local ok, result = pcall(fn, ...)

	if ok then
		return result
	end
end

local function playerTransferTrim(text)
	return (string.gsub(text or "", "^%s*(.-)%s*$", "%1"))
end

-- JSON ------------------------------------------------------------------------

local PlayerTransferJsonArray = {}
local PlayerTransferJsonNull = setmetatable({}, {
	__tostring = function()
		return "null"
	end
})

PlayerTransfer.JsonNull = PlayerTransferJsonNull

function PlayerTransfer.jsonArray(list)
	return setmetatable(list or {}, PlayerTransferJsonArray)
end

local function playerTransferIsArray(value)
	return type(value) == "table" and getmetatable(value) == PlayerTransferJsonArray
end

local function playerTransferIsObject(value)
	return type(value) == "table" and value ~= PlayerTransferJsonNull and getmetatable(value) ~= PlayerTransferJsonArray
end

local PlayerTransferJsonEscapes = {
	["\""] = "\\\"",
	["\\"] = "\\\\",
	["\b"] = "\\b",
	["\f"] = "\\f",
	["\n"] = "\\n",
	["\r"] = "\\r",
	["\t"] = "\\t"
}

local function playerTransferJsonString(text)
	local escaped = string.gsub(text, "[%c\"\\]", function(char)
		return PlayerTransferJsonEscapes[char] or string.format("\\u%04x", string.byte(char))
	end)

	return "\"" .. escaped .. "\""
end

-- Keys are written in this order, then alphabetically.
local PlayerTransferKeyOrder = {
	format = 1,
	version = 2,
	game = 3,
	exportedAt = 4,
	count = 5,
	player = 6,
	team = 6,
	teams = 7,
	playerCount = 8,
	players = 9,
	id = 1,
	name = 2,
	sex = 3,
	baseGame = 4,
	tier1 = 5,
	created = 5,
	edited = 6,
	overall = 6,
	identity = 7,
	attributes = 8,
	skills = 9,
	appearance = 10,
	emblem = 11,
	homeGrounds = 12,
	uniforms = 13,
	uniformDefaults = 14,
	coachId = 15,
	roster = 16,
	lineups = 17,
	options = 20
}

local function playerTransferSortedKeys(object)
	local keys = {}

	for key in pairs(object) do
		keys[#keys + 1] = tostring(key)
	end

	table.sort(keys, function(a, b)
		local rankA = PlayerTransferKeyOrder[a] or 100
		local rankB = PlayerTransferKeyOrder[b] or 100

		if rankA ~= rankB then
			return rankA < rankB
		end

		return a < b
	end)

	return keys
end

local function playerTransferJsonNumber(value)
	if value ~= value or value == math.huge or value == -math.huge then
		error("cannot write a non-finite number")
	end

	if value == math.floor(value) and math.abs(value) < 2^53 then
		return string.format("%d", value)
	end

	return string.format("%.9g", value)
end

local function playerTransferJsonEncode(value, indent, out)
	local kind = type(value)

	if kind == "table" then
		if value == PlayerTransferJsonNull then
			out[#out + 1] = "null"

			return
		end

		local inner = indent .. "  "

		if playerTransferIsArray(value) then
			if #value == 0 then
				out[#out + 1] = "[]"

				return
			end

			out[#out + 1] = "[\n"

			for index, item in ipairs(value) do
				out[#out + 1] = inner

				playerTransferJsonEncode(item, inner, out)

				out[#out + 1] = index < #value and ",\n" or "\n"
			end

			out[#out + 1] = indent .. "]"

			return
		end

		local keys = playerTransferSortedKeys(value)

		if #keys == 0 then
			out[#out + 1] = "{}"

			return
		end

		out[#out + 1] = "{\n"

		for index, key in ipairs(keys) do
			out[#out + 1] = inner .. playerTransferJsonString(key) .. ": "

			playerTransferJsonEncode(value[key], inner, out)

			out[#out + 1] = index < #keys and ",\n" or "\n"
		end

		out[#out + 1] = indent .. "}"
	elseif kind == "string" then
		out[#out + 1] = playerTransferJsonString(value)
	elseif kind == "number" then
		out[#out + 1] = playerTransferJsonNumber(value)
	elseif kind == "boolean" then
		out[#out + 1] = value and "true" or "false"
	else
		error("cannot write a " .. kind .. " value")
	end
end

-- indent: prefix of the lines after the first one (when the value is nested in
-- a document assembled by hand, like the bulk export).
function PlayerTransfer.encode(value, indent)
	local out = {}

	playerTransferJsonEncode(value, indent or "", out)

	return table.concat(out)
end

local function playerTransferJsonFail(text, pos, message)
	local line = 1
	local lineStart = 1
	local before = string.sub(text, 1, pos - 1)

	for newline in string.gmatch(before, "()\n") do
		line = line + 1
		lineStart = newline + 1
	end

	error({
		jsonError = string.format("line %d, column %d: %s", line, pos - lineStart + 1, message)
	}, 0)
end

local function playerTransferJsonSkip(text, pos)
	return string.find(text, "[^ \t\r\n]", pos) or #text + 1
end

local function playerTransferUtf8(code)
	if code < 128 then
		return string.char(code)
	elseif code < 2048 then
		return string.char(192 + math.floor(code / 64), 128 + code % 64)
	elseif code < 65536 then
		return string.char(224 + math.floor(code / 4096), 128 + math.floor(code / 64) % 64, 128 + code % 64)
	end

	return string.char(240 + math.floor(code / 262144), 128 + math.floor(code / 4096) % 64, 128 + math.floor(code / 64) % 64, 128 + code % 64)
end

local PlayerTransferJsonUnescapes = {
	["\""] = "\"",
	["\\"] = "\\",
	["/"] = "/",
	b = "\b",
	f = "\f",
	n = "\n",
	r = "\r",
	t = "\t"
}

-- pos is just after the opening quote. Returns the string and the position
-- after the closing quote.
local function playerTransferJsonStringAt(text, pos)
	local parts = {}

	while true do
		local found, _, char = string.find(text, "([\"\\%c])", pos)

		if not found then
			playerTransferJsonFail(text, #text + 1, "unterminated string")
		end

		parts[#parts + 1] = string.sub(text, pos, found - 1)

		if char == "\"" then
			return table.concat(parts), found + 1
		elseif char ~= "\\" then
			playerTransferJsonFail(text, found, "control character inside a string")
		end

		local escape = string.sub(text, found + 1, found + 1)

		if escape == "u" then
			local hex = string.match(text, "^%x%x%x%x", found + 2)

			if not hex then
				playerTransferJsonFail(text, found, "invalid \\u escape")
			end

			local code = tonumber(hex, 16)

			pos = found + 6

			if code >= 55296 and code <= 56319 then
				local low = string.match(text, "^\\u(%x%x%x%x)", pos)
				local lowCode = low and tonumber(low, 16)

				if not lowCode or lowCode < 56320 or lowCode > 57343 then
					playerTransferJsonFail(text, found, "invalid surrogate pair")
				end

				code = 65536 + (code - 55296) * 1024 + (lowCode - 56320)
				pos = pos + 6
			elseif code >= 56320 and code <= 57343 then
				playerTransferJsonFail(text, found, "invalid surrogate pair")
			end

			parts[#parts + 1] = playerTransferUtf8(code)
		else
			local replacement = PlayerTransferJsonUnescapes[escape]

			if not replacement then
				playerTransferJsonFail(text, found, "invalid escape in string")
			end

			parts[#parts + 1] = replacement
			pos = found + 2
		end
	end
end

local function playerTransferJsonNumberAt(text, pos)
	local token = string.match(text, "^%-?%d+%.?%d*[eE]?[%+%-]?%d*", pos)
	local valid = token and not string.find(token, "^%-?0%d") and (string.find(token, "^%-?%d+$") or string.find(token, "^%-?%d+%.%d+$") or string.find(token, "^%-?%d+[eE][%+%-]?%d+$") or string.find(token, "^%-?%d+%.%d+[eE][%+%-]?%d+$"))
	local number = valid and tonumber(token)

	if not number or number ~= number or number == math.huge or number == -math.huge then
		playerTransferJsonFail(text, pos, "invalid number")
	end

	return number, pos + #token
end

local playerTransferJsonValue

local function playerTransferJsonObjectAt(text, pos, depth)
	local object = {}

	pos = playerTransferJsonSkip(text, pos + 1)

	if string.sub(text, pos, pos) == "}" then
		return object, pos + 1
	end

	while true do
		if string.sub(text, pos, pos) ~= "\"" then
			playerTransferJsonFail(text, pos, "expected a quoted key")
		end

		local key

		key, pos = playerTransferJsonStringAt(text, pos + 1)
		pos = playerTransferJsonSkip(text, pos)

		if string.sub(text, pos, pos) ~= ":" then
			playerTransferJsonFail(text, pos, "expected ':' after a key")
		end

		object[key], pos = playerTransferJsonValue(text, pos + 1, depth + 1)
		pos = playerTransferJsonSkip(text, pos)

		local char = string.sub(text, pos, pos)

		if char == "}" then
			return object, pos + 1
		elseif char ~= "," then
			playerTransferJsonFail(text, pos, "expected ',' or '}'")
		end

		pos = playerTransferJsonSkip(text, pos + 1)
	end
end

local function playerTransferJsonArrayAt(text, pos, depth)
	local list = PlayerTransfer.jsonArray()

	pos = playerTransferJsonSkip(text, pos + 1)

	if string.sub(text, pos, pos) == "]" then
		return list, pos + 1
	end

	while true do
		list[#list + 1], pos = playerTransferJsonValue(text, pos, depth + 1)
		pos = playerTransferJsonSkip(text, pos)

		local char = string.sub(text, pos, pos)

		if char == "]" then
			return list, pos + 1
		elseif char ~= "," then
			playerTransferJsonFail(text, pos, "expected ',' or ']'")
		end

		pos = pos + 1
	end
end

function playerTransferJsonValue(text, pos, depth)
	if depth > 32 then
		playerTransferJsonFail(text, pos, "data is nested too deeply")
	end

	pos = playerTransferJsonSkip(text, pos)

	local char = string.sub(text, pos, pos)

	if char == "{" then
		return playerTransferJsonObjectAt(text, pos, depth)
	elseif char == "[" then
		return playerTransferJsonArrayAt(text, pos, depth)
	elseif char == "\"" then
		return playerTransferJsonStringAt(text, pos + 1)
	elseif char == "-" or string.find(char, "^%d$") then
		return playerTransferJsonNumberAt(text, pos)
	elseif string.sub(text, pos, pos + 3) == "true" then
		return true, pos + 4
	elseif string.sub(text, pos, pos + 4) == "false" then
		return false, pos + 5
	elseif string.sub(text, pos, pos + 3) == "null" then
		return PlayerTransferJsonNull, pos + 4
	elseif char == "" then
		playerTransferJsonFail(text, pos, "unexpected end of file")
	end

	playerTransferJsonFail(text, pos, "unexpected character '" .. char .. "'")
end

-- Returns the decoded value, or nil and "line L, column C: message". JSON null
-- decodes to PlayerTransfer.JsonNull and arrays carry PlayerTransferJsonArray.
function PlayerTransfer.decode(text)
	local ok, result = pcall(function()
		local value, pos = playerTransferJsonValue(text, 1, 0)

		pos = playerTransferJsonSkip(text, pos)

		if pos <= #text then
			playerTransferJsonFail(text, pos, "unexpected text after the end of the data")
		end

		return value
	end)

	if ok then
		return result
	end

	if type(result) == "table" and result.jsonError then
		return nil, result.jsonError
	end

	return nil, tostring(result)
end

-- Player fields ---------------------------------------------------------------
-- Every section is a CDataConfig with getOption/setOption by name. Specs come
-- from the design tables, so edits to those (by other mods too) are picked up.

local PlayerTransferSpecs

local function playerTransferToNumber(value)
	if type(value) == "number" then
		return value
	end

	if type(value) == "userdata" or type(value) == "table" then
		local ok, number = pcall(function()
			return value:toInt()
		end)

		if ok and type(number) == "number" then
			return number
		end
	end
end

local function playerTransferAddSpec(section, name, definition, kind)
	local spec = {
		name = name,
		kind = kind
	}

	if kind == "integer" then
		spec.min = playerTransferToNumber(definition.min) or PlayerTransferMinInt
		spec.max = playerTransferToNumber(definition.max) or PlayerTransferMaxUInt
	elseif kind == "guid" then
		spec.min = PlayerTransferMinInt
		spec.max = PlayerTransferMaxUInt
		spec.itemMap = PlayerTransferItemMaps[name]
	elseif kind == "string" then
		spec.maxLength = math.max((playerTransferToNumber(definition.byteSize) or 32) - 1, 1)
	end

	section.byName[name] = spec
	section.list[#section.list + 1] = spec
end

function PlayerTransfer.getSpecs()
	if PlayerTransferSpecs then
		return PlayerTransferSpecs
	end

	local specs = {}

	for _, sectionName in ipairs(PlayerTransferSections) do
		specs[sectionName] = {
			list = {},
			byName = {}
		}
	end

	for name, definition in pairs(identitymap.Data[1].PlayerIdentity) do
		if type(definition) == "table" and not PlayerTransferSkipIdentity[name] then
			local kind = definition.type == "string" and "string" or definition.type == "bool" and "bool" or definition.type == "integer" and "integer"

			if kind then
				playerTransferAddSpec(specs.identity, name, definition, kind)
			end
		end
	end

	for _, group in ipairs({
		attributemap.PlayerAttributesDoNotCountTowardsBudget,
		attributemap.PlayerAttributesCountTowardsBudget
	}) do
		for name, definition in pairs(group) do
			if type(definition) == "table" then
				playerTransferAddSpec(specs.attributes, name, definition, "integer")
			end
		end
	end

	for name, definition in pairs(attributemap.PlayerSkills) do
		if type(definition) == "table" then
			playerTransferAddSpec(specs.skills, name, definition, "integer")
		end
	end

	for name, definition in pairs(assetmap.options.player) do
		if type(definition) == "table" and not definition.noSave and not PlayerTransferSkipAppearance[name] then
			if definition.type == "guid" then
				playerTransferAddSpec(specs.appearance, name, definition, "guid")
			elseif definition.type == "slider" then
				playerTransferAddSpec(specs.appearance, name, definition, "slider")
			end
		end
	end

	for _, sectionName in ipairs(PlayerTransferSections) do
		table.sort(specs[sectionName].list, function(a, b)
			return a.name < b.name
		end)
	end

	PlayerTransferSpecs = specs

	return specs
end

local function playerTransferConfigFor(player, sectionName)
	return playerTransferSafe(function()
		if sectionName == "identity" then
			return player.identity
		elseif sectionName == "attributes" then
			return player.attributes
		elseif sectionName == "skills" then
			return player.skills
		end

		return player.visual
	end)
end

local function playerTransferReadField(config, spec)
	local ok, value = pcall(function()
		return config:getOption(spec.name)
	end)

	if not ok or value == nil then
		return nil
	end

	if spec.kind == "string" then
		return type(value) == "string" and value or nil
	elseif spec.kind == "bool" then
		if type(value) == "boolean" then
			return value
		end

		local number = playerTransferToNumber(value)

		if number ~= nil then
			return number ~= 0
		end

		return nil
	end

	local number = playerTransferToNumber(value)

	if number == nil or number ~= number or number == math.huge or number == -math.huge then
		return nil
	end

	if spec.kind ~= "slider" then
		local rounded = math.floor(number + 0.5)

		if math.abs(rounded - number) < 1e-6 then
			number = rounded
		end
	end

	return number
end

local function playerTransferSameValue(a, b)
	if type(a) == "number" and type(b) == "number" then
		return math.abs(a - b) <= 0.0001
	end

	return a == b
end

local function playerTransferIsOnDiscId(id)
	return id ~= nil and playerTransferSafe(native.CPlayerDatabaseOnDisc.getIsOnDiscPlayerId, id) == true
end

local function playerTransferSexName(player)
	return playerTransferSafe(function()
		return player.identity.sex == native.CSex.Female
	end) and "Female" or "Male"
end

local function playerTransferIdentityValue(player, name)
	return playerTransferSafe(function()
		return player.identity:getOption(name)
	end)
end

function PlayerTransfer.serialisePlayer(player)
	local specs = PlayerTransfer.getSpecs()
	local id = player.id
	local data = {
		id = id,
		name = tostring(playerTransferSafe(function()
			return player.fullName
		end) or ""),
		sex = playerTransferSexName(player),
		baseGame = playerTransferIsOnDiscId(id),
		tier1 = playerTransferSafe(function()
			return player.isTier1
		end) == true
	}
	local overall = playerTransferSafe(function()
		return player:getOverallForPrimaryRole()
	end)

	if type(overall) == "number" and overall == overall then
		data.overall = math.floor(overall + 0.5)
	end

	for _, sectionName in ipairs(PlayerTransferSections) do
		local config = playerTransferConfigFor(player, sectionName)
		local values = {}

		if config then
			for _, spec in ipairs(specs[sectionName].list) do
				local value = playerTransferReadField(config, spec)

				if value ~= nil then
					values[spec.name] = value
				end
			end
		end

		data[sectionName] = values
	end

	return data
end

function PlayerTransfer.exportDocument(player)
	return {
		format = PlayerTransferFormatOne,
		version = PlayerTransferVersion,
		game = "Rugby League 26",
		exportedAt = os.date("!%Y-%m-%dT%H:%M:%SZ"),
		player = PlayerTransfer.serialisePlayer(player)
	}
end

function PlayerTransfer.defaultFileName(player)
	local function part(text)
		text = string.gsub(tostring(text or ""), "[^%w%-]+", "_")
		text = string.gsub(text, "^_+", "")

		return (string.gsub(text, "_+$", ""))
	end

	local pieces = {
		"Player"
	}

	for _, name in ipairs({
		part(playerTransferIdentityValue(player, "firstname")),
		part(playerTransferIdentityValue(player, "surname"))
	}) do
		if name ~= "" then
			pieces[#pieces + 1] = name
		end
	end

	pieces[#pieces + 1] = tostring(player.id)

	return table.concat(pieces, "_") .. ".json"
end

-- Validation ------------------------------------------------------------------

local function playerTransferDescribe(value)
	if value == PlayerTransferJsonNull then
		return "null"
	elseif type(value) == "string" then
		return string.format("%q", #value > 40 and string.sub(value, 1, 40) .. "..." or value)
	elseif playerTransferIsArray(value) then
		return "a list"
	elseif type(value) == "table" then
		return "an object"
	end

	return tostring(value)
end

-- Returns the value to apply, or nil and why it was rejected.
local function playerTransferCheckField(spec, value)
	if spec.kind == "string" then
		if type(value) ~= "string" then
			return nil, "must be text"
		elseif #value > spec.maxLength then
			return nil, string.format("must be at most %d characters", spec.maxLength)
		elseif string.find(value, "%c") then
			return nil, "must not contain control characters"
		end

		return value
	elseif spec.kind == "bool" then
		if type(value) ~= "boolean" then
			return nil, "must be true or false"
		end

		return value
	end

	if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then
		return nil, "must be a number"
	end

	if spec.kind == "slider" then
		if math.abs(value) > 1000000 then
			return nil, "is out of range"
		end

		return value
	end

	if value ~= math.floor(value) then
		return nil, "must be a whole number"
	elseif value < spec.min or value > spec.max then
		return nil, string.format("must be from %d to %d", spec.min, spec.max), true
	end

	return value
end

-- false when an item-picking appearance value isn't in this game's item list.
local function playerTransferItemInstalled(spec, value)
	if not spec.itemMap or spec.name == "head" and value == 0 then
		return true
	end

	local map = playerTransferSafe(function()
		return assetmap.AssetMapItems[spec.itemMap]
	end)

	if type(map) ~= "table" then
		return true
	end

	return playerTransferSafe(assetmap.getItemByGuid, map, value) ~= nil
end

-- Checks one entry of a file. Returns a clean copy holding only known fields:
--   { sex, sourceId, baseGame, tier1, firstname, surname, fullName, ignored,
--     missingItems, sections = { identity = {...}, attributes = {...},
--     skills = {...}, appearance = {...} or nil } }
-- or nil and the reason the entry was rejected. Unknown keys are ignored.
-- identitymap's ranges are editor limits that stock data doesn't always keep
-- to, so an out-of-range identity value is left out (listed in ignored)
-- instead of rejecting the player. Attribute and skill ranges are firm.
-- Appearance items this game doesn't have are left out too (missingItems), so
-- those parts keep the player's current or default look.
function PlayerTransfer.validatePlayer(entry)
	if not playerTransferIsObject(entry) then
		return nil, "is not a player"
	end

	local specs = PlayerTransfer.getSpecs()
	local clean = {
		sections = {},
		ignored = {},
		missingItems = {}
	}

	if entry.sex ~= "Male" and entry.sex ~= "Female" then
		return nil, string.format("sex must be \"Male\" or \"Female\" (got %s)", playerTransferDescribe(entry.sex))
	end

	clean.sex = entry.sex

	if entry.id ~= nil then
		if type(entry.id) ~= "number" or entry.id ~= math.floor(entry.id) or entry.id < 0 or entry.id > PlayerTransferMaxUInt then
			return nil, string.format("id must be a whole number (got %s)", playerTransferDescribe(entry.id))
		end

		clean.sourceId = entry.id
	end

	for _, flag in ipairs({
		"baseGame",
		"tier1"
	}) do
		if entry[flag] ~= nil and type(entry[flag]) ~= "boolean" then
			return nil, string.format("%s must be true or false (got %s)", flag, playerTransferDescribe(entry[flag]))
		end

		clean[flag] = entry[flag] == true
	end

	for _, sectionName in ipairs(PlayerTransferSections) do
		local section = entry[sectionName]

		if section == nil then
			if sectionName ~= "appearance" then
				return nil, "is missing its " .. sectionName .. " section"
			end
		elseif not playerTransferIsObject(section) then
			return nil, string.format("%s must be an object (got %s)", sectionName, playerTransferDescribe(section))
		else
			local values = {}

			for _, spec in ipairs(specs[sectionName].list) do
				local raw = section[spec.name]

				if raw ~= nil then
					local value, reason, outOfRange = playerTransferCheckField(spec, raw)
					local message = value == nil and string.format("%s.%s %s (got %s)", sectionName, spec.name, reason, playerTransferDescribe(raw))

					if value ~= nil and sectionName == "appearance" and not playerTransferItemInstalled(spec, value) then
						clean.missingItems[#clean.missingItems + 1] = string.format("appearance.%s %s is not installed in this game", spec.name, playerTransferDescribe(value))
					elseif value ~= nil then
						values[spec.name] = value
					elseif outOfRange and sectionName == "identity" then
						clean.ignored[#clean.ignored + 1] = message
					else
						return nil, message
					end
				end
			end

			clean.sections[sectionName] = values
		end
	end

	local identity = clean.sections.identity

	if type(identity.surname) ~= "string" or playerTransferTrim(identity.surname) == "" then
		return nil, "identity.surname is missing"
	end

	clean.firstname = identity.firstname or ""
	clean.surname = identity.surname
	clean.fullName = playerTransferTrim(clean.firstname .. " " .. clean.surname)

	return clean
end

-- Returns the list of raw player entries in a file's text, or nil and a
-- message for the user.
function PlayerTransfer.parseFile(text)
	if type(text) ~= "string" or playerTransferTrim(text) == "" then
		return nil, "The file is empty."
	end

	if string.sub(text, 1, 3) == "\239\187\191" then
		text = string.sub(text, 4)
	end

	local data, err = PlayerTransfer.decode(text)

	if data == nil then
		return nil, "The file is not valid JSON, so it may be damaged or incomplete.\n(" .. tostring(err) .. ")"
	end

	if not playerTransferIsObject(data) or data.format ~= PlayerTransferFormatOne and data.format ~= PlayerTransferFormatMany then
		return nil, "This file is not a player export from this mod."
	end

	if type(data.version) ~= "number" then
		return nil, "The file has no format version, so it may be damaged."
	elseif data.version > PlayerTransferVersion then
		return nil, "This file was made by a newer version of the player import/export mod. Update the mod to import it."
	end

	if data.format == PlayerTransferFormatOne then
		if not playerTransferIsObject(data.player) then
			return nil, "The file has no player data, so it may be damaged."
		end

		return {
			data.player
		}
	end

	if not playerTransferIsArray(data.players) then
		return nil, "The file has no players list, so it may be damaged."
	elseif #data.players == 0 then
		return nil, "The file contains no players."
	elseif #data.players > PlayerTransferMaxPlayers then
		return nil, string.format("The file contains %d players. At most %d can be imported at once.", #data.players, PlayerTransferMaxPlayers)
	end

	return data.players
end

-- Import ----------------------------------------------------------------------

local function playerTransferNameKey(firstname, surname)
	return string.lower(playerTransferTrim(firstname)) .. "|" .. string.lower(playerTransferTrim(surname))
end

local function playerTransferPlayerKey(player)
	local function value(name)
		return tostring(playerTransferIdentityValue(player, name))
	end

	return table.concat({
		playerTransferNameKey(playerTransferIdentityValue(player, "firstname"), playerTransferIdentityValue(player, "surname")),
		value("birthDay"),
		value("birthMonth"),
		value("birthYear"),
		playerTransferSexName(player)
	}, "|")
end

local function playerTransferCleanKey(clean)
	local identity = clean.sections.identity

	return table.concat({
		playerTransferNameKey(clean.firstname, clean.surname),
		tostring(identity.birthDay),
		tostring(identity.birthMonth),
		tostring(identity.birthYear),
		clean.sex
	}, "|")
end

-- Academy-made players by name + date of birth + sex, so importing the same
-- file twice updates them instead of making duplicates. Downloaded read-only
-- players are left out (they can't be edited).
local function playerTransferCreatedIndex(playerManager)
	local index = {}

	pcall(function()
		for _, player in playerManager.userCreated:iterateAll() do
			if player and not playerTransferIsOnDiscId(player.id) and playerTransferSafe(function()
				return player.sharing.readOnly
			end) ~= true then
				local key = playerTransferPlayerKey(player)

				if index[key] == nil then
					index[key] = player.id
				end
			end
		end
	end)

	return index
end

function PlayerTransfer.newImportContext(engine, uiServices)
	local playerManager = uiServices:getPlayerManager()

	return {
		engine = engine,
		uiServices = uiServices,
		playerManager = playerManager,
		createdIndex = playerTransferCreatedIndex(playerManager)
	}
end

-- A base game id only counts as the same player when the sex matches and the
-- name (stock or as edited here) or the date of birth matches: mods that add
-- players can give the same id to different people.
local function playerTransferMatchesBasePlayer(context, id, clean)
	local playerManager = context.playerManager
	local identity = clean.sections.identity
	local wanted = playerTransferNameKey(clean.firstname, clean.surname)

	for _, player in ipairs({
		playerTransferSafe(function()
			return playerManager.onDisc:getPlayer(id)
		end),
		playerTransferSafe(function()
			return playerManager:getPlayer(id)
		end)
	}) do
		if player and playerTransferSexName(player) == clean.sex then
			if playerTransferNameKey(playerTransferIdentityValue(player, "firstname"), playerTransferIdentityValue(player, "surname")) == wanted then
				return true
			end

			if identity.birthYear ~= nil and playerTransferSameValue(playerTransferIdentityValue(player, "birthYear"), identity.birthYear) and playerTransferSameValue(playerTransferIdentityValue(player, "birthMonth"), identity.birthMonth) and playerTransferSameValue(playerTransferIdentityValue(player, "birthDay"), identity.birthDay) then
				return true
			end
		end
	end

	return false
end

-- Returns the id of the player this entry updates, or nil to add a new one.
function PlayerTransfer.resolveTarget(context, clean)
	local playerManager = context.playerManager
	local sourceId = clean.sourceId

	if sourceId and playerTransferIsOnDiscId(sourceId) and playerTransferMatchesBasePlayer(context, sourceId, clean) then
		return sourceId
	end

	if clean.baseGame then
		local found = playerTransferSafe(function()
			return playerManager.onDisc:getIdFromName(clean.firstname, clean.surname)
		end)

		found = playerTransferToNumber(found)

		if found and playerTransferIsOnDiscId(found) and playerTransferMatchesBasePlayer(context, found, clean) then
			return found
		end
	end

	return context.createdIndex[playerTransferCleanKey(clean)]
end

-- mode: "full", "noAppearance" (tier-1 targets: the game locks their look),
-- "bodyOnly" (a tier-1 export becoming another player) or "tier1Fields"
-- (tier-1 targets while PlayerTransfer.tier1AppearanceFields is set: only
-- those options, e.g. revamp-stats-sync's hair and headgear).
local function playerTransferAppearanceAllowed(mode, name)
	if mode == "noAppearance" then
		return false
	elseif mode == "bodyOnly" then
		return PlayerTransferBodyAppearance[name] == true
	elseif mode == "tier1Fields" then
		local fields = PlayerTransfer.tier1AppearanceFields

		return type(fields) == "table" and fields[name] == true
	end

	return true
end

function PlayerTransfer.isUnchanged(player, clean, mode)
	local specs = PlayerTransfer.getSpecs()

	for sectionName, values in pairs(clean.sections) do
		local config = playerTransferConfigFor(player, sectionName)

		for name, value in pairs(values) do
			if sectionName ~= "appearance" or playerTransferAppearanceAllowed(mode, name) then
				local current = config and playerTransferReadField(config, specs[sectionName].byName[name])

				if current == nil or not playerTransferSameValue(current, value) then
					return false
				end
			end
		end
	end

	return true
end

-- Returns the "section.field" names the game refused.
function PlayerTransfer.applyToPlayer(player, clean, mode)
	local specs = PlayerTransfer.getSpecs()
	local failed = {}

	local function apply(sectionName)
		local values = clean.sections[sectionName]

		if not values then
			return
		end

		local config = playerTransferConfigFor(player, sectionName)

		for _, spec in ipairs(specs[sectionName].list) do
			local value = values[spec.name]

			if value ~= nil and (sectionName ~= "appearance" or playerTransferAppearanceAllowed(mode, spec.name)) then
				local ok = config and pcall(function()
					config:setOption(spec.name, value)
				end)

				if not ok then
					failed[#failed + 1] = sectionName .. "." .. spec.name
				end
			end
		end
	end

	apply("identity")

	if mode ~= "noAppearance" and clean.sections.appearance then
		apply("appearance")

		-- tier1Fields only touches hair/headgear options, never the body.
		if mode ~= "tier1Fields" then
			pcall(function()
				player:heightWeight_SetAttributesFromVisual()
			end)
		end
	end

	-- After the visual, so the file's height/weight attributes win.
	apply("attributes")
	apply("skills")
	pcall(function()
		player.sharing.hasUnsharedModifications = true
	end)

	return failed
end

local function playerTransferCanCreate(playerManager)
	return (playerTransferToNumber(playerTransferSafe(function()
		return playerManager.userCreated.canCreateCount
	end)) or 0) > 0
end

-- Mirrors PlayerViewState: official players are edited through
-- userCreated:editPlayer (licensed non-tier-1 ones get their user-created
-- version first), tier-1 edits are stored with saveCustomLicensed.
local function playerTransferUpdatePlayer(context, id, clean)
	local playerManager = context.playerManager
	local current = playerTransferSafe(function()
		return playerManager:getPlayer(id)
	end)

	if not current then
		return nil, PlayerTransferLabels.targetMissing
	end

	local tier1 = current.isTier1 == true
	local mode = tier1 and (PlayerTransfer.tier1AppearanceFields and "tier1Fields" or "noAppearance") or clean.tier1 and "bodyOnly" or "full"

	if PlayerTransfer.isUnchanged(current, clean, mode) then
		return "unchanged"
	end

	local target

	if playerTransferIsOnDiscId(id) then
		if not tier1 then
			local hasEdit = playerTransferSafe(function()
				return playerManager.userCreated:containsPlayer(id)
			end) == true

			if not hasEdit and not playerTransferCanCreate(playerManager) then
				return nil, PlayerTransferLabels.storageFull
			end

			if current.isLicensed then
				pcall(function()
					playerManager:editOrCreateUserCreatedVersionOfPlayer(id)
				end)
			end
		end

		target = playerTransferSafe(function()
			return playerManager.userCreated:editPlayer(id)
		end)
	else
		target = playerTransferSafe(function()
			return playerManager.userCreated:getPlayer(id)
		end)
	end

	if not target then
		return nil, PlayerTransferLabels.cannotEdit
	end

	local failed = PlayerTransfer.applyToPlayer(target, clean, mode)

	if tier1 then
		playerManager:saveCustomLicensed(target)
	end

	return "updated", failed
end

local function playerTransferAddPlayer(context, clean)
	local playerManager = context.playerManager

	if not playerTransferCanCreate(playerManager) then
		return nil, PlayerTransferLabels.storageFull
	end

	local female = clean.sex == "Female"
	local player = native.CPlayer()

	playergenerator.bogStandardPlayerWithEthnicity(context.engine, player, female and native.CSex.Female or native.CSex.Male, female and native.DefaultPlayerVisuals.PlayerFemaleCaucasian or native.DefaultPlayerVisuals.PlayerMaleCaucasian, context.uiServices:getDefaultPlayerVisualManager())

	local newId = playerManager.userCreated:addPlayer(player)
	local created = newId ~= nil and playerTransferSafe(function()
		return playerManager.userCreated:getPlayer(newId)
	end)

	if not created then
		return nil, PlayerTransferLabels.cannotCreate
	end

	local ok, failed = pcall(PlayerTransfer.applyToPlayer, created, clean, clean.tier1 and "bodyOnly" or "full")

	if not ok then
		playerTransferLogError("apply to new player failed: " .. tostring(failed))
		pcall(function()
			playerManager.userCreated:deletePlayer(newId)
		end)

		return nil, PlayerTransferLabels.cannotCreate
	end

	-- A later entry for the same person in this file updates this player.
	context.createdIndex[playerTransferCleanKey(clean)] = newId

	return "added", failed
end

-- Returns "updated" | "added" | "unchanged" and the fields that failed, or
-- nil and a reason.
function PlayerTransfer.importOne(context, item)
	if item.targetId then
		return playerTransferUpdatePlayer(context, item.targetId, item.clean)
	end

	local existing = context.createdIndex[playerTransferCleanKey(item.clean)]

	if existing then
		return playerTransferUpdatePlayer(context, existing, item.clean)
	end

	return playerTransferAddPlayer(context, item.clean)
end

local function playerTransferEntryLabel(index, entry, clean, total)
	local name = clean and clean.fullName or playerTransferIsObject(entry) and type(entry.name) == "string" and entry.name or nil

	if total == 1 then
		return name or "The player"
	end

	return name and string.format("Player %d (%s)", index, name) or string.format("Player %d", index)
end

-- Validates every entry and works out what each one will do, before anything
-- is changed.
function PlayerTransfer.planImport(context, entries)
	local plan = {
		items = {},
		errors = {},
		updates = 0,
		adds = 0,
		missingItems = 0
	}

	for index, entry in ipairs(entries) do
		local clean, reason = PlayerTransfer.validatePlayer(entry)
		local label = playerTransferEntryLabel(index, entry, clean, #entries)

		if clean then
			local targetId = PlayerTransfer.resolveTarget(context, clean)

			for _, message in ipairs(clean.ignored) do
				playerTransferLogError("import " .. label .. ": left out " .. message)
			end

			-- A scanned player's look is never copied, so their missing items
			-- (e.g. heads from rll4-legacy-players) don't matter.
			if #clean.missingItems > 0 and not clean.tier1 then
				plan.missingItems = plan.missingItems + 1

				for _, message in ipairs(clean.missingItems) do
					playerTransferLogError("import " .. label .. ": left out " .. message)
				end
			end

			plan.items[#plan.items + 1] = {
				clean = clean,
				targetId = targetId,
				label = label
			}

			if targetId then
				plan.updates = plan.updates + 1
			else
				plan.adds = plan.adds + 1
			end
		else
			plan.errors[#plan.errors + 1] = label .. ": " .. reason
		end
	end

	return plan
end

-- Export lists ----------------------------------------------------------------

-- Tier-1 edits live in the native custom-licensed store, not userCreated, so
-- compare the live player with the on-disc one.
local function playerTransferTier1Edited(current, disc)
	if rawequal(current, disc) then
		return false
	end

	if playerTransferSafe(function()
		return current.isUserEdited or current.hasCustomStrings
	end) == true then
		return true
	end

	local specs = PlayerTransfer.getSpecs()

	for _, sectionName in ipairs({
		"identity",
		"attributes",
		"skills"
	}) do
		local currentConfig = playerTransferConfigFor(current, sectionName)
		local discConfig = playerTransferConfigFor(disc, sectionName)

		if currentConfig and discConfig then
			for _, spec in ipairs(specs[sectionName].list) do
				if not playerTransferSameValue(playerTransferReadField(currentConfig, spec), playerTransferReadField(discConfig, spec)) then
					return true
				end
			end
		end
	end

	return false
end

-- edited: Academy-made players, edited official players and edited tier-1
-- players. all: every on-disc player plus the Academy-made ones.
function PlayerTransfer.collectExportIds(playerManager)
	local edited, all = {}, {}
	local seenEdited, seenAll = {}, {}

	local function add(list, seen, id)
		if id ~= nil and not seen[id] then
			seen[id] = true
			list[#list + 1] = id
		end
	end

	pcall(function()
		for _, player in playerManager.userCreated:iterateAll() do
			if player then
				add(edited, seenEdited, player.id)
			end
		end
	end)
	pcall(function()
		for _, disc in playerManager.onDisc:iterateAll() do
			if disc then
				local id = disc.id

				add(all, seenAll, id)

				if disc.isTier1 and not seenEdited[id] then
					local current = playerTransferSafe(function()
						return playerManager:getPlayer(id)
					end)

					if current and playerTransferTier1Edited(current, disc) then
						add(edited, seenEdited, id)
					end
				end
			end
		end
	end)

	for _, id in ipairs(edited) do
		add(all, seenAll, id)
	end

	return {
		edited = edited,
		all = all
	}
end

-- Files and the file dialog -------------------------------------------------------

local PlayerTransferDialogFilter = "Player files (*.json)|*.json|All files (*.*)|*.*"
local PlayerTransferTaskFilter = "Player files (*.json)\0*.json\0All files (*.*)\0*.*\0"
local playerTransferLastDir

local function playerTransferDefaultDir()
	if playerTransferLastDir then
		return playerTransferLastDir
	end

	local home = playerTransferSafe(os.getenv, "USERPROFILE")

	if type(home) == "string" and home ~= "" then
		return home .. "\\Documents"
	end
end

local function playerTransferFinishPath(path, isSave)
	if type(path) ~= "string" or path == "" then
		return nil
	end

	if isSave and not string.find(path, "%.[^\\/%.]+$") then
		path = path .. ".json"
	end

	local dir = string.match(path, "^(.*)[\\/][^\\/]*$")

	if dir and dir ~= "" then
		playerTransferLastDir = dir
	end

	return path
end

-- Returns "picked", path | "cancelled" | "pending" (an async dialog task was
-- started under tag: poll it with playerTransferPollDialog) | "unavailable".
-- filters: optional { dialog = "A|*.a", task = "A\0*.a\0" } (default: player files).
local function playerTransferBrowse(uiServices, isSave, defaultName, tag, filters)
	local showFileDialog = PlayerTransferUseBlockingDialog and playerTransferSafe(function()
		return native.showFileDialog
	end)
	local configClass = playerTransferSafe(function()
		return native.CLuaDialogBoxConfig
	end)

	if type(showFileDialog) == "function" and configClass then
		local ok, config = pcall(configClass)

		if ok and config then
			local dir = playerTransferDefaultDir()

			if dir then
				pcall(function()
					config.initialDir = dir
				end)
			end

			if defaultName then
				pcall(function()
					config.filePath = dir and dir .. "\\" .. defaultName or defaultName
				end)
			end

			local called, path = pcall(showFileDialog, filters and filters.dialog or PlayerTransferDialogFilter, isSave, config)

			if called then
				path = playerTransferFinishPath(path, isSave)

				if path then
					return "picked", path
				end

				return "cancelled"
			end

			playerTransferLogError("showFileDialog failed, using the dialog task: " .. tostring(path))
		end
	end

	if uiServices.showFileDialog and not uiServices:hasFileDialogTask() then
		local ok, err = pcall(uiServices.showFileDialog, filters and filters.task or PlayerTransferTaskFilter, isSave, tag)

		if ok then
			return "pending"
		end

		playerTransferLogError("dialog task failed: " .. tostring(err))
	end

	return "unavailable"
end

-- Returns false while the dialog is open, then true and the path (nil when
-- cancelled).
local function playerTransferPollDialog(uiServices, tag, isSave)
	if uiServices:hasFileDialogTask() ~= tag then
		return true, nil
	end

	if not uiServices:fileDialogIsComplete() then
		return false
	end

	local path = playerTransferSafe(function()
		return uiServices:fileDialogGetData()
	end)

	pcall(function()
		uiServices:fileDialogDispose()
	end)

	return true, playerTransferFinishPath(path, isSave)
end

local function playerTransferDisposeDialog(uiServices, tag)
	pcall(function()
		if uiServices:hasFileDialogTask() == tag then
			uiServices:fileDialogDispose()
		end
	end)
end

-- io first; the engine's file system as a fallback (it may handle paths io
-- can't, e.g. non-ASCII folder names).
local function playerTransferWriteFile(engine, path, text)
	local ok, err = pcall(function()
		local file, openErr = io.open(path, "wb")

		if not file then
			error(openErr or "the file could not be opened", 0)
		end

		local written, writeErr = file:write(text)

		file:close()

		if not written then
			error(writeErr or "the file could not be written", 0)
		end
	end)

	if ok then
		return true
	end

	if pcall(function()
		local handle = engine:getFileSystem():fopen(path, true, false)

		if not handle then
			error("fopen failed")
		end

		handle:write(text)
		handle:close()
	end) then
		return true
	end

	return false, tostring(err)
end

local function playerTransferReadFile(engine, path)
	local maxBytes = PlayerTransferMaxFileMB * 1024 * 1024
	local tooBig = string.format(PlayerTransferLabels.tooBig, PlayerTransferMaxFileMB)
	local text, size
	local ok, err = pcall(function()
		local file, openErr = io.open(path, "rb")

		if not file then
			error(openErr or "the file could not be opened", 0)
		end

		size = file:seek("end")

		if size and size <= maxBytes then
			file:seek("set", 0)

			text = file:read("*a")
		end

		file:close()
	end)

	if ok and size and size > maxBytes then
		return nil, tooBig
	elseif ok and type(text) == "string" then
		return text
	end

	local nativeText = playerTransferSafe(function()
		local handle = engine:getFileSystem():fopen(path, false)

		if not handle then
			return nil
		end

		local content = handle:read()

		handle:close()

		return content
	end)

	if type(nativeText) == "string" then
		if #nativeText > maxBytes then
			return nil, tooBig
		end

		return nativeText
	end

	return nil, tostring(err)
end

local function playerTransferFileName(path)
	return string.match(path, "([^\\/]+)$") or path
end

-- Shared UI helpers -----------------------------------------------------------

local function playerTransferAlert(owner, engine, time, uiServices, partyMember, params)
	owner.alertOpen = true
	params.canCancel = params.canCancel ~= false
	params.input = partyMember:getInput()

	local onSelected = params.onSelected

	function params.onSelected(arg_engine, arg_time, arg_result, ...)
		owner.alertOpen = false
		owner.ignoreInputUntil = arg_time + 0.25

		if onSelected then
			return onSelected(arg_engine, arg_time, arg_result, ...)
		end
	end

	uiServices:blockingAlert(engine, time, params)
end

local function playerTransferOpenBusy(owner, engine, time, title, status)
	owner.busyArea = busy_layout.create(engine, title, status)

	busy_layout.playEnter(owner.busyArea, true)

	owner.busyMinUntil = time + 1
end

local function playerTransferSetBusy(owner, status)
	if owner.busyArea then
		busy_layout.setStatus(owner.busyArea, status)
	end
end

local function playerTransferCloseBusy(owner)
	if owner.busyArea then
		owner.busyArea:dispose()

		owner.busyArea = nil
	end
end

local function playerTransferSaveBusy(engine, uiServices)
	return playerTransferSafe(function()
		return uiServices:profileSaveInProgress(engine)
	end) == true
end

local function playerTransferErrorLines(errors, lines)
	for index, text in ipairs(errors) do
		if index > PlayerTransferShownErrors then
			lines[#lines + 1] = string.format(PlayerTransferLabels.moreErrors, #errors - PlayerTransferShownErrors)

			break
		end

		lines[#lines + 1] = "- " .. text
	end
end

-- Export Player (player hub) ----------------------------------------------------

local function playerTransferWriteOne(state, engine, time, uiServices, academyData, pending, path)
	local ok, err = playerTransferWriteFile(engine, path, pending.text)

	playerTransferAlert(state, engine, time, uiServices, academyData.partyMember, {
		options = "ok",
		text = ok and string.format(PlayerTransferLabels.exportedOne, pending.fullName, path) or string.format(PlayerTransferLabels.writeFailed, path, tostring(err))
	})
end

local function playerTransferExportViewed(state, engine, time, uiServices, academyData, info)
	local player = info.player
	local ok, text = pcall(function()
		return PlayerTransfer.encode(PlayerTransfer.exportDocument(player)) .. "\n"
	end)

	if not ok then
		playerTransferLogError("export player failed: " .. tostring(text))
		playerTransferAlert(state, engine, time, uiServices, academyData.partyMember, {
			options = "ok",
			text = PlayerTransferLabels.serialiseFailed
		})

		return
	end

	local pending = {
		text = text,
		fullName = tostring(playerTransferSafe(function()
			return player.fullName
		end) or "")
	}
	local result, path = playerTransferBrowse(uiServices, true, PlayerTransfer.defaultFileName(player), "PlayerTransferExportOne")

	if result == "picked" then
		playerTransferWriteOne(state, engine, time, uiServices, academyData, pending, path)
	elseif result == "pending" then
		state.playerTransferPending = pending
	elseif result == "unavailable" then
		playerTransferAlert(state, engine, time, uiServices, academyData.partyMember, {
			options = "ok",
			text = PlayerTransferLabels.noDialog
		})
	end
end

local function playerTransferHubUpdate(state, engine, time, uiServices, academyData, info)
	if not info or info.inCommunity or not info.player or not academyData or not academyData.partyMember then
		return
	end

	if state.alertOpen or not state.view or not state.view.userInputEnabled or uiServices:getIsBlockingMixinActive() then
		return
	end

	if state.ignoreInputUntil and time < state.ignoreInputUntil then
		return
	end

	uiServices:addTooltip(nil, native.InputTypes.X, PlayerTransferLabels.exportPlayer)

	if uiServices:checkForRelease(academyData.partyMember, native.InputTypes.X) then
		uiServices:playSound("Select")
		playerTransferExportViewed(state, engine, time, uiServices, academyData, info)
	end
end

function PlayerViewHubState.update(arg_pt_0, arg_pt_1, arg_pt_2, arg_pt_3, arg_pt_4, arg_pt_5, arg_pt_6, arg_pt_7, arg_pt_8, arg_pt_9)
	local pending = arg_pt_0.playerTransferPending

	-- An async dialog task (fallback path) is open: wait for it, like the
	-- stock custom face import does.
	if pending then
		local done, path = playerTransferPollDialog(arg_pt_6, "PlayerTransferExportOne", true)

		if done then
			arg_pt_0.playerTransferPending = nil

			if path then
				playerTransferWriteOne(arg_pt_0, arg_pt_2, arg_pt_3, arg_pt_6, arg_pt_8, pending, path)
			end
		end

		return
	end

	var_0_0.update(arg_pt_0, arg_pt_1, arg_pt_2, arg_pt_3, arg_pt_4, arg_pt_5, arg_pt_6, arg_pt_7, arg_pt_8, arg_pt_9)

	if arg_pt_0.playerTransferExited then
		return
	end

	local ok, err = pcall(playerTransferHubUpdate, arg_pt_0, arg_pt_2, arg_pt_3, arg_pt_6, arg_pt_8, arg_pt_9)

	if not ok then
		playerTransferLogError("hub export: " .. tostring(err))
	end
end

function PlayerViewHubState.exit(arg_pt_10, ...)
	arg_pt_10.playerTransferExited = true

	if arg_pt_10.playerTransferPending then
		local uiServices = select(4, ...)

		arg_pt_10.playerTransferPending = nil

		if uiServices then
			playerTransferDisposeDialog(uiServices, "PlayerTransferExportOne")
		end
	end

	var_0_0.exit(arg_pt_10, ...)
end

-- Import Player / Import Players ----------------------------------------------------
-- Runs inside AcademyState (stateData.nextState). Flow: file dialog -> read,
-- validate and plan every entry -> confirm -> apply a batch per frame -> save
-- -> summary -> back to the home screen.

Class("AcademyPlayerImportState")

function AcademyPlayerImportState.enter(arg_pt_20, arg_pt_21, arg_pt_22, arg_pt_23, arg_pt_24, arg_pt_25, arg_pt_26, arg_pt_27, arg_pt_28)
	arg_pt_20.multi = arg_pt_27 and arg_pt_27.playerTransferMulti == true
	arg_pt_20.goBackFactoryStack = arg_pt_28
	arg_pt_20.phase = "browse"

	pcall(function()
		arg_pt_25:titleSetSubAreaOfGame(arg_pt_20.multi and PlayerTransferLabels.importPlayers or PlayerTransferLabels.importPlayer)
	end)
end

function AcademyPlayerImportState.fail(arg_pt_30, arg_pt_31, arg_pt_32, arg_pt_33, arg_pt_34, arg_pt_35)
	playerTransferCloseBusy(arg_pt_30)

	arg_pt_30.phase = "finished"

	playerTransferAlert(arg_pt_30, arg_pt_31, arg_pt_32, arg_pt_33, arg_pt_34.partyMember, {
		options = "ok",
		yPos = 0.5,
		text = arg_pt_35,
		onSelected = function()
			arg_pt_30.exitRequested = true
		end
	})
end

function AcademyPlayerImportState.readAndPlan(arg_pt_40, arg_pt_41, arg_pt_42, arg_pt_43, arg_pt_44)
	local path = arg_pt_40.path
	local text, readErr = playerTransferReadFile(arg_pt_41, path)

	if not text then
		return arg_pt_40:fail(arg_pt_41, arg_pt_42, arg_pt_43, arg_pt_44, string.format(PlayerTransferLabels.readFailed, path, tostring(readErr)))
	end

	local entries, parseErr = PlayerTransfer.parseFile(text)

	text = nil

	if not entries then
		return arg_pt_40:fail(arg_pt_41, arg_pt_42, arg_pt_43, arg_pt_44, parseErr)
	end

	if not arg_pt_40.multi and #entries > 1 then
		return arg_pt_40:fail(arg_pt_41, arg_pt_42, arg_pt_43, arg_pt_44, string.format(PlayerTransferLabels.tooManyForSingle, #entries))
	end

	local context = PlayerTransfer.newImportContext(arg_pt_41, arg_pt_43)
	local plan = PlayerTransfer.planImport(context, entries)

	entries = nil

	collectgarbage()

	for _, message in ipairs(plan.errors) do
		playerTransferLogError("import " .. playerTransferFileName(path) .. ": skipped " .. message)
	end

	if #plan.items == 0 then
		local lines = {
			PlayerTransferLabels.noValidPlayers
		}

		playerTransferErrorLines(plan.errors, lines)

		return arg_pt_40:fail(arg_pt_41, arg_pt_42, arg_pt_43, arg_pt_44, table.concat(lines, "\n"))
	end

	arg_pt_40.context = context
	arg_pt_40.plan = plan

	playerTransferCloseBusy(arg_pt_40)
	arg_pt_40:confirm(arg_pt_41, arg_pt_42, arg_pt_43, arg_pt_44)
end

function AcademyPlayerImportState.confirm(arg_pt_50, arg_pt_51, arg_pt_52, arg_pt_53, arg_pt_54)
	local plan = arg_pt_50.plan
	local lines = {}

	if #plan.items == 1 and #plan.errors == 0 then
		local item = plan.items[1]

		if item.targetId then
			local target = playerTransferSafe(function()
				return arg_pt_50.context.playerManager:getPlayer(item.targetId)
			end)
			local targetName = target and tostring(playerTransferSafe(function()
				return target.fullName
			end) or item.clean.fullName) or item.clean.fullName
			local kind = playerTransferIsOnDiscId(item.targetId) and PlayerTransferLabels.baseGamePlayer or PlayerTransferLabels.academyPlayer

			lines[1] = string.format(PlayerTransferLabels.confirmSingleUpdate, item.clean.fullName, kind, targetName, item.targetId)
		else
			lines[1] = string.format(PlayerTransferLabels.confirmSingleAdd, item.clean.fullName)
		end
	else
		lines[1] = string.format(PlayerTransferLabels.confirmMany, #plan.items, plan.updates, plan.adds)

		if #plan.errors > 0 then
			lines[#lines + 1] = ""
			lines[#lines + 1] = string.format(PlayerTransferLabels.confirmSkipped, #plan.errors)

			playerTransferErrorLines(plan.errors, lines)
		end
	end

	if plan.missingItems > 0 then
		lines[#lines + 1] = ""
		lines[#lines + 1] = string.format(PlayerTransferLabels.missingItems, plan.missingItems)
	end

	if plan.updates > 0 then
		lines[#lines + 1] = ""
		lines[#lines + 1] = PlayerTransferLabels.confirmFooter
	end

	arg_pt_50.phase = "confirm"

	playerTransferAlert(arg_pt_50, arg_pt_51, arg_pt_52, arg_pt_53, arg_pt_54.partyMember, {
		options = "noyes",
		yPos = 0.5,
		text = table.concat(lines, "\n"),
		onSelected = function(arg_pt_55, arg_pt_56, arg_pt_57)
			if arg_pt_57 and arg_pt_57.val then
				arg_pt_50.startApply = true
			else
				arg_pt_50.exitRequested = true
			end
		end
	})
end

function AcademyPlayerImportState.applyBatch(arg_pt_60, arg_pt_61, arg_pt_62, arg_pt_63, arg_pt_64)
	local plan = arg_pt_60.plan
	local results = arg_pt_60.results
	local total = #plan.items
	local done = 0

	while arg_pt_60.applyIndex <= total and done < PlayerTransferImportBatch do
		local item = plan.items[arg_pt_60.applyIndex]
		local ok, result, extra = pcall(PlayerTransfer.importOne, arg_pt_60.context, item)

		if not ok then
			playerTransferLogError("import " .. item.label .. " failed: " .. tostring(result))
			results.errors[#results.errors + 1] = item.label .. ": " .. PlayerTransferLabels.unexpected
		elseif result == nil then
			results.errors[#results.errors + 1] = item.label .. ": " .. tostring(extra)
		else
			results[result] = results[result] + 1

			if type(extra) == "table" and #extra > 0 then
				results.partial = results.partial + 1

				playerTransferLogError("import " .. item.label .. ": could not set " .. table.concat(extra, ", "))
			end
		end

		arg_pt_60.applyIndex = arg_pt_60.applyIndex + 1
		done = done + 1
	end

	playerTransferSetBusy(arg_pt_60, string.format(PlayerTransferLabels.importing, math.min(arg_pt_60.applyIndex, total), total))

	if arg_pt_60.applyIndex > total then
		for _, message in ipairs(results.errors) do
			playerTransferLogError("import " .. playerTransferFileName(arg_pt_60.path) .. ": not imported " .. message)
		end

		if results.updated + results.added > 0 then
			arg_pt_63:profileSaveFrontEndData(arg_pt_64.partyMember)
		end

		playerTransferSetBusy(arg_pt_60, PlayerTransferLabels.saving)

		arg_pt_60.phase = "saving"
	end
end

function AcademyPlayerImportState.showSummary(arg_pt_70, arg_pt_71, arg_pt_72, arg_pt_73, arg_pt_74)
	local results = arg_pt_70.results
	local lines = {
		PlayerTransferLabels.done,
		""
	}

	for _, entry in ipairs({
		{
			"updated",
			PlayerTransferLabels.countUpdated
		},
		{
			"added",
			PlayerTransferLabels.countAdded
		},
		{
			"unchanged",
			PlayerTransferLabels.countUnchanged
		}
	}) do
		if results[entry[1]] > 0 then
			lines[#lines + 1] = string.format(entry[2], results[entry[1]])
		end
	end

	local failed = #results.errors + #arg_pt_70.plan.errors

	if failed > 0 then
		lines[#lines + 1] = string.format(PlayerTransferLabels.countFailed, failed)

		local all = {}

		for _, list in ipairs({
			arg_pt_70.plan.errors,
			results.errors
		}) do
			for _, message in ipairs(list) do
				all[#all + 1] = message
			end
		end

		playerTransferErrorLines(all, lines)
	end

	if results.partial > 0 then
		lines[#lines + 1] = string.format(PlayerTransferLabels.partial, results.partial)
	end

	if arg_pt_70.plan.missingItems > 0 then
		lines[#lines + 1] = string.format(PlayerTransferLabels.missingItems, arg_pt_70.plan.missingItems)
	end

	if results.added > 0 then
		lines[#lines + 1] = ""
		lines[#lines + 1] = PlayerTransferLabels.freeAgents
	end

	arg_pt_70.phase = "finished"

	playerTransferAlert(arg_pt_70, arg_pt_71, arg_pt_72, arg_pt_73, arg_pt_74.partyMember, {
		options = "ok",
		yPos = 0.5,
		text = table.concat(lines, "\n"),
		onSelected = function()
			arg_pt_70.exitRequested = true
		end
	})
end

function AcademyPlayerImportState.update(arg_pt_80, arg_pt_81, arg_pt_82, arg_pt_83, arg_pt_84, arg_pt_85, arg_pt_86, arg_pt_87, arg_pt_88)
	if arg_pt_80.errorExited then
		return
	end

	local ok, err = xpcall(function()
		return arg_pt_80:updateInner(arg_pt_81, arg_pt_82, arg_pt_83, arg_pt_84, arg_pt_85, arg_pt_86, arg_pt_87, arg_pt_88)
	end, playerTransferTraceback)

	if not ok then
		-- Never soft-lock the UI: log the error and back out to the home screen.
		playerTransferLogError("import update error (phase " .. tostring(arg_pt_80.phase) .. "): " .. tostring(err))

		arg_pt_80.errorExited = true

		local exited, exitErr = pcall(arg_pt_81.changeState, arg_pt_81, nil, arg_pt_82, arg_pt_83, arg_pt_85, arg_pt_86, arg_pt_88)

		if not exited then
			playerTransferLogError("exit after error failed: " .. tostring(exitErr))
		end
	end
end

function AcademyPlayerImportState.updateInner(arg_pt_90, arg_pt_91, arg_pt_92, arg_pt_93, arg_pt_94, arg_pt_95, arg_pt_96, arg_pt_97, arg_pt_98)
	if arg_pt_90.busyArea then
		arg_pt_90.busyArea:update(arg_pt_94)
	end

	if arg_pt_96:updateBlockingMixins(arg_pt_92, arg_pt_93, arg_pt_94, arg_pt_95, arg_pt_97) then
		return
	end

	if arg_pt_90.exitRequested then
		arg_pt_91:changeState(nil, arg_pt_92, arg_pt_93, arg_pt_95, arg_pt_96, arg_pt_98)

		return
	end

	local phase = arg_pt_90.phase

	if phase == "browse" then
		local result, path = playerTransferBrowse(arg_pt_96, false, nil, "PlayerTransferImport")

		if result == "picked" then
			arg_pt_90.path = path
		elseif result == "pending" then
			arg_pt_90.phase = "dialog"
		elseif result == "unavailable" then
			arg_pt_90:fail(arg_pt_92, arg_pt_93, arg_pt_96, arg_pt_98, PlayerTransferLabels.noDialog)
		else
			arg_pt_90.exitRequested = true
		end
	elseif phase == "dialog" then
		local done, path = playerTransferPollDialog(arg_pt_96, "PlayerTransferImport", false)

		if done then
			if path then
				arg_pt_90.path = path
			else
				arg_pt_90.exitRequested = true
			end
		end
	elseif phase == "read" then
		-- Reading and parsing block for a moment, so let the busy screen draw
		-- first.
		arg_pt_90.readFrames = arg_pt_90.readFrames + 1

		if arg_pt_90.readFrames > 2 then
			arg_pt_90.phase = "planning"

			arg_pt_90:readAndPlan(arg_pt_92, arg_pt_93, arg_pt_96, arg_pt_98)
		end
	elseif phase == "confirm" and arg_pt_90.startApply then
		arg_pt_90.startApply = nil
		arg_pt_90.phase = "apply"
		arg_pt_90.applyIndex = 1
		arg_pt_90.results = {
			updated = 0,
			added = 0,
			unchanged = 0,
			partial = 0,
			errors = {}
		}

		playerTransferOpenBusy(arg_pt_90, arg_pt_92, arg_pt_93, PlayerTransferLabels.busyImport, string.format(PlayerTransferLabels.importing, 0, #arg_pt_90.plan.items))
	elseif phase == "apply" then
		arg_pt_90:applyBatch(arg_pt_92, arg_pt_93, arg_pt_96, arg_pt_98)
	elseif phase == "saving" then
		if arg_pt_93 >= arg_pt_90.busyMinUntil and not playerTransferSaveBusy(arg_pt_92, arg_pt_96) then
			playerTransferCloseBusy(arg_pt_90)
			arg_pt_90:showSummary(arg_pt_92, arg_pt_93, arg_pt_96, arg_pt_98)
		end
	end

	if arg_pt_90.path and (phase == "browse" or phase == "dialog") then
		arg_pt_90.phase = "read"
		arg_pt_90.readFrames = 0

		playerTransferOpenBusy(arg_pt_90, arg_pt_92, arg_pt_93, PlayerTransferLabels.busyImport, PlayerTransferLabels.reading)
	end
end

function AcademyPlayerImportState.render(arg_pt_100, arg_pt_101, arg_pt_102, arg_pt_103, arg_pt_104, arg_pt_105)
	if arg_pt_100.busyArea then
		arg_pt_100.busyArea:doRender(arg_pt_101, arg_pt_104)
	end
end

function AcademyPlayerImportState.exit(arg_pt_110, arg_pt_111, arg_pt_112, arg_pt_113, arg_pt_114, arg_pt_115)
	playerTransferCloseBusy(arg_pt_110)
	playerTransferDisposeDialog(arg_pt_114, "PlayerTransferImport")
end

-- Export Players ------------------------------------------------------------------
-- Two buttons (edited & created / all) with counts, then a save dialog and a
-- busy screen while the players are written a batch per frame.

local var_pt_0 = optionmenu_state.OptionMenuState

Class("AcademyPlayerExportAllState", var_pt_0)

function AcademyPlayerExportAllState.enter(arg_pt_120, arg_pt_121, arg_pt_122, arg_pt_123, arg_pt_124, arg_pt_125, arg_pt_126, arg_pt_127, arg_pt_128)
	arg_pt_120.phase = "menu"
	arg_pt_120.goBackFactoryStack = arg_pt_128
	arg_pt_120.lists = PlayerTransfer.collectExportIds(arg_pt_125:getPlayerManager())

	playerTransferLog(string.format("export lists: edited %d, all %d", #arg_pt_120.lists.edited, #arg_pt_120.lists.all))
	pcall(function()
		arg_pt_125:titleSetSubAreaOfGame(PlayerTransferLabels.exportPlayers)
	end)
	var_pt_0.enter(arg_pt_120, arg_pt_122, arg_pt_123, arg_pt_124, arg_pt_125, arg_pt_120:createMenuItems(), nil, {
		noSpaceBeforePanel = true,
		examineSelectionBeforeExit = true,
		itemParams = {},
		titleBox = {
			left = true,
			title = PlayerTransferLabels.exportPlayers
		}
	})
end

function AcademyPlayerExportAllState.createMenuItems(arg_pt_130)
	return {
		optionmenu_aide.createButton(string.format("%s (%d)", PlayerTransferLabels.exportEdited, #arg_pt_130.lists.edited), {
			playerTransferAction = "edited"
		}),
		optionmenu_aide.createButton(string.format("%s (%d)", PlayerTransferLabels.exportAll, #arg_pt_130.lists.all), {
			playerTransferAction = "all"
		})
	}
end

function AcademyPlayerExportAllState.startExport(arg_pt_140, arg_pt_141, arg_pt_142, arg_pt_143, arg_pt_144, arg_pt_145)
	local ids = arg_pt_140.lists[arg_pt_145]

	if #ids == 0 then
		playerTransferAlert(arg_pt_140, arg_pt_141, arg_pt_142, arg_pt_143, arg_pt_144.partyMember, {
			options = "ok",
			text = PlayerTransferLabels.nothingToExport
		})

		return
	end

	local defaultName = string.format("Players_%s_%d_%s.json", arg_pt_145 == "all" and "All" or "Edited", #ids, os.date("%Y-%m-%d"))
	local result, path = playerTransferBrowse(arg_pt_143, true, defaultName, "PlayerTransferExportAll")

	arg_pt_140.exportIds = ids

	if result == "picked" then
		arg_pt_140:beginExport(arg_pt_141, arg_pt_142, path)
	elseif result == "pending" then
		arg_pt_140.phase = "dialog"
	elseif result == "unavailable" then
		playerTransferAlert(arg_pt_140, arg_pt_141, arg_pt_142, arg_pt_143, arg_pt_144.partyMember, {
			options = "ok",
			text = PlayerTransferLabels.noDialog
		})
	end
end

function AcademyPlayerExportAllState.beginExport(arg_pt_150, arg_pt_151, arg_pt_152, arg_pt_153)
	arg_pt_150.path = arg_pt_153
	arg_pt_150.phase = "export"
	arg_pt_150.exportIndex = 1
	arg_pt_150.exportParts = {}
	arg_pt_150.exportSkipped = 0

	playerTransferOpenBusy(arg_pt_150, arg_pt_151, arg_pt_152, PlayerTransferLabels.busyExport, string.format(PlayerTransferLabels.exporting, 0, #arg_pt_150.exportIds))
end

function AcademyPlayerExportAllState.finishExport(arg_pt_160, arg_pt_161, arg_pt_162, arg_pt_163, arg_pt_164)
	local parts = arg_pt_160.exportParts
	local text = table.concat({
		"{\n",
		"  \"format\": ",
		playerTransferJsonString(PlayerTransferFormatMany),
		",\n",
		"  \"version\": ",
		tostring(PlayerTransferVersion),
		",\n",
		"  \"game\": \"Rugby League 26\",\n",
		"  \"exportedAt\": ",
		playerTransferJsonString(os.date("!%Y-%m-%dT%H:%M:%SZ")),
		",\n",
		"  \"count\": ",
		tostring(#parts),
		",\n",
		"  \"players\": [\n    ",
		table.concat(parts, ",\n    "),
		"\n  ]\n}\n"
	})

	arg_pt_160.exportParts = nil

	local ok, err = playerTransferWriteFile(arg_pt_161, arg_pt_160.path, text)

	text = nil

	collectgarbage()
	playerTransferCloseBusy(arg_pt_160)

	arg_pt_160.phase = "menu"

	local lines = {}

	if ok then
		lines[1] = string.format(PlayerTransferLabels.exportedMany, #parts, arg_pt_160.path)

		if arg_pt_160.exportSkipped > 0 then
			lines[2] = ""
			lines[3] = string.format(PlayerTransferLabels.exportSkipped, arg_pt_160.exportSkipped)
		end
	else
		lines[1] = string.format(PlayerTransferLabels.writeFailed, arg_pt_160.path, tostring(err))
	end

	playerTransferAlert(arg_pt_160, arg_pt_161, arg_pt_162, arg_pt_163, arg_pt_164.partyMember, {
		options = "ok",
		text = table.concat(lines, "\n")
	})
end

function AcademyPlayerExportAllState.updateExport(arg_pt_170, arg_pt_171, arg_pt_172, arg_pt_173, arg_pt_174, arg_pt_175)
	if arg_pt_170.area then
		arg_pt_170.area:update(arg_pt_173)
	end

	if arg_pt_170.busyArea then
		arg_pt_170.busyArea:update(arg_pt_173)
	end

	if arg_pt_170.phase == "dialog" then
		local done, path = playerTransferPollDialog(arg_pt_174, "PlayerTransferExportAll", true)

		if done then
			if path then
				arg_pt_170:beginExport(arg_pt_171, arg_pt_172, path)
			else
				arg_pt_170.phase = "menu"
			end
		end

		return
	end

	local ids = arg_pt_170.exportIds
	local playerManager = arg_pt_174:getPlayerManager()
	local done = 0

	while arg_pt_170.exportIndex <= #ids and done < PlayerTransferExportBatch do
		local id = ids[arg_pt_170.exportIndex]
		local ok, text = pcall(function()
			return PlayerTransfer.encode(PlayerTransfer.serialisePlayer(VERIFY(playerManager:getPlayer(id))), "    ")
		end)

		if ok then
			arg_pt_170.exportParts[#arg_pt_170.exportParts + 1] = text
		else
			arg_pt_170.exportSkipped = arg_pt_170.exportSkipped + 1

			playerTransferLogError("export player " .. tostring(id) .. " failed: " .. tostring(text))
		end

		arg_pt_170.exportIndex = arg_pt_170.exportIndex + 1
		done = done + 1
	end

	if arg_pt_170.exportIndex <= #ids then
		playerTransferSetBusy(arg_pt_170, string.format(PlayerTransferLabels.exporting, arg_pt_170.exportIndex - 1, #ids))
	elseif arg_pt_170.phase == "export" then
		-- One more frame so "Writing file..." shows before the write blocks.
		arg_pt_170.phase = "write"

		playerTransferSetBusy(arg_pt_170, PlayerTransferLabels.writing)
	else
		arg_pt_170:finishExport(arg_pt_171, arg_pt_172, arg_pt_174, arg_pt_175)
	end
end

function AcademyPlayerExportAllState.update(arg_pt_180, arg_pt_181, arg_pt_182, arg_pt_183, arg_pt_184, arg_pt_185, arg_pt_186, arg_pt_187, arg_pt_188)
	if arg_pt_180.errorExited then
		return
	end

	local ok, err = xpcall(function()
		return arg_pt_180:updateInner(arg_pt_181, arg_pt_182, arg_pt_183, arg_pt_184, arg_pt_185, arg_pt_186, arg_pt_187, arg_pt_188)
	end, playerTransferTraceback)

	if not ok then
		playerTransferLogError("export update error (phase " .. tostring(arg_pt_180.phase) .. "): " .. tostring(err))

		arg_pt_180.errorExited = true

		local exited, exitErr = pcall(arg_pt_181.changeState, arg_pt_181, nil, arg_pt_182, arg_pt_183, arg_pt_185, arg_pt_186, arg_pt_188)

		if not exited then
			playerTransferLogError("exit after error failed: " .. tostring(exitErr))
		end
	end
end

function AcademyPlayerExportAllState.updateInner(arg_pt_190, arg_pt_191, arg_pt_192, arg_pt_193, arg_pt_194, arg_pt_195, arg_pt_196, arg_pt_197, arg_pt_198)
	if arg_pt_190.phase ~= "menu" then
		arg_pt_190:updateExport(arg_pt_192, arg_pt_193, arg_pt_194, arg_pt_196, arg_pt_198)

		return
	end

	local partyMember = arg_pt_198.partyMember
	local _, _, _, selected = var_pt_0.update(arg_pt_190, arg_pt_192, arg_pt_193, arg_pt_194, arg_pt_195, arg_pt_196, arg_pt_197, partyMember:getInput())

	if arg_pt_190.alertOpen or arg_pt_196:getIsBlockingMixinActive() or arg_pt_190.ignoreInputUntil and arg_pt_193 < arg_pt_190.ignoreInputUntil then
		return
	end

	arg_pt_196:addTooltip(arg_pt_190.tooltipsWidget, native.InputTypes.Decline, native.Localise("Back"), 99)

	local action = selected and selected.playerTransferAction

	if action then
		arg_pt_196:playSound("Select")
		arg_pt_190:startExport(arg_pt_192, arg_pt_193, arg_pt_196, arg_pt_198, action)
	elseif arg_pt_196:checkForRelease(partyMember, native.InputTypes.Decline) then
		arg_pt_196:playSound("Back")
		arg_pt_191:changeState(nil, arg_pt_192, arg_pt_193, arg_pt_195, arg_pt_196, arg_pt_198)
	end
end

function AcademyPlayerExportAllState.render(arg_pt_200, arg_pt_201, arg_pt_202, arg_pt_203, arg_pt_204, arg_pt_205)
	var_pt_0.render(arg_pt_200, arg_pt_201, arg_pt_202, arg_pt_203, arg_pt_204)

	if arg_pt_200.busyArea then
		arg_pt_200.busyArea:doRender(arg_pt_201, arg_pt_204)
	end
end

function AcademyPlayerExportAllState.exit(arg_pt_210, arg_pt_211, arg_pt_212, arg_pt_213, arg_pt_214, arg_pt_215)
	playerTransferCloseBusy(arg_pt_210)
	playerTransferDisposeDialog(arg_pt_214, "PlayerTransferExportAll")
	var_pt_0.exit(arg_pt_210, arg_pt_211, arg_pt_212, arg_pt_213, arg_pt_214, arg_pt_215)
end

-- Rows for the home screen's Players submenu (added by nvm_homescreen.lua).
function PlayerTransfer.menuRows()
	return {
		{
			playerTransferRow = true,
			title = PlayerTransferLabels.importPlayer,
			stateData = {
				playerTransferMulti = false,
				nextState = AcademyPlayerImportState
			}
		},
		{
			playerTransferRow = true,
			title = PlayerTransferLabels.importPlayers,
			stateData = {
				playerTransferMulti = true,
				nextState = AcademyPlayerImportState
			}
		},
		{
			playerTransferRow = true,
			title = PlayerTransferLabels.exportPlayers,
			stateData = {
				nextState = AcademyPlayerExportAllState
			}
		}
	}
end

-- Helpers shared with the team export (app/club/club_view_state.lua).
PlayerTransfer.shared = {
	logError = playerTransferLogError,
	log = playerTransferLog,
	traceback = playerTransferTraceback,
	safe = playerTransferSafe,
	toNumber = playerTransferToNumber,
	addSpec = playerTransferAddSpec,
	readField = playerTransferReadField,
	sameValue = playerTransferSameValue,
	jsonString = playerTransferJsonString,
	browse = playerTransferBrowse,
	pollDialog = playerTransferPollDialog,
	disposeDialog = playerTransferDisposeDialog,
	writeFile = playerTransferWriteFile,
	alert = playerTransferAlert,
	openBusy = playerTransferOpenBusy,
	setBusy = playerTransferSetBusy,
	closeBusy = playerTransferCloseBusy,
	version = PlayerTransferVersion,
	exportBatch = PlayerTransferExportBatch
}
