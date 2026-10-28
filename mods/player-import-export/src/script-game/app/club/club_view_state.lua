import("core.statemachine.statemachine")
import("game.club.clubgenerator")
import("app.club.club_viewstate_hub_state")
import("app.save.save_aide")
import("app.sharing.sharing_searchtags_aide")

local var_0_0 = native.sportType
local var_0_1 = native.InputTypes
local var_0_2

var_0_2 = var_0_0 ~= "cricket"

Class("ClubViewState")

function ClubViewState.enter(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6)
	local var_1_0 = arg_1_5.partyMember
	local var_1_1 = {
		partyMember = var_1_0,
		tiles = assert(arg_1_6.tiles),
		searchTagInfo = sharing_searchtags_aide.Tags,
		downloadedClubInfo = arg_1_6.downloadedClubInfo,
		inCommunity = arg_1_6.downloadedClubInfo ~= nil
	}

	save_aide.addDirtySaveHelper(var_1_1, arg_1_4, var_1_0, false, true)

	local var_1_2 = arg_1_4:getLeagueManager()
	local var_1_3 = arg_1_4:getClubManager()
	local var_1_4
	local var_1_5

	if arg_1_6.club then
		var_1_4 = arg_1_6.club
	elseif arg_1_6.clubId then
		var_1_4 = var_1_3:getClub(arg_1_6.clubId)
	end

	if arg_1_6.canEdit then
		if not var_1_4 then
			arg_1_6.creatingNewClub = true

			local var_1_6 = arg_1_4.playerModelGetAssetMap()
			local var_1_7 = VERIFY(arg_1_6.sex)
			local var_1_8 = var_1_7 == native.CSex.Male and native.DefaultTeamVisuals.NewCustomMale or native.DefaultTeamVisuals.NewCustomFemale
			local var_1_9 = native.CClub()

			var_1_9.createdAt = native.UTCTime.now()

			clubgenerator.bogStandardIdentity(arg_1_1, var_1_9, var_1_7)
			clubgenerator.addCopyOfUniform(var_1_9, arg_1_4:getDefaultTeamVisual(var_1_8))
			arg_1_4:playerModelSetUniform(1, var_1_9:getHomeUniformVisual(), var_1_9.identity)
			var_1_9:setCrowdColoursFromUniforms(var_1_6)
			var_1_9.identity:setOption("nickname", string.format("%s %d", var_1_9.nickname, var_1_3.userCreated.count + 1))
			var_1_9:setSex(var_1_7)

			local var_1_10 = var_1_3.userCreated:addClub(var_1_9)

			var_1_4 = var_1_3:getClub(var_1_10)
		else
			var_1_5 = native.CClubManager.getIsOnDiscClub(var_1_4.id)

			if var_1_5 then
				var_1_4 = var_1_3:editOrCreateUserCreatedVersionOfClub(var_1_4.id)
			end
		end
	end

	ASSERT(var_1_4)

	var_1_1.club = var_1_4
	var_1_1.clubId = var_1_4.academyId
	var_1_1.leagueId = arg_1_6.leagueId and var_1_2:getIsValidLeagueId(arg_1_6.leagueId) and arg_1_6.leagueId or nil
	var_1_1.isOnDiscClub = var_1_5 or native.CClubManager.getIsOnDiscClub(var_1_4.id)
	var_1_1.sharingInformation = var_1_4.sharing

	local var_1_11

	if arg_1_0.checkReadOnlyStatus then
		var_1_11 = arg_1_0:checkReadOnlyStatus(arg_1_4, var_1_1)
	end

	var_1_1.canEdit = arg_1_6.canEdit and not var_1_11 or false
	var_1_1.clubManager = var_1_3
	var_1_1.sex = var_1_4.identity.sex
	var_1_1.supporters = var_1_4.identity.supporters
	arg_1_0.clubViewInfo = var_1_1

	arg_1_4:forEachHookFn("setClubViewInfo", var_1_1)

	arg_1_0.stateMachine = statemachine.StateMachine(arg_1_0.__type)

	arg_1_0.stateMachine:changeState(club_viewstate_hub_state.ClubViewHubState(), arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_0.clubViewInfo)
end

function ClubViewState.exit(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5)
	local var_2_0 = arg_2_0.clubViewInfo
	local var_2_1 = var_2_0.club

	if var_2_0.canEdit and native.CClubDatabaseOnDisc.getIsOfficialClubId(var_2_1.id) then
		VERIFY(arg_2_4:getClubManager()):saveCustomLicensed(var_2_1)
		var_2_0.setDirty(arg_2_1)
	end

	arg_2_0.stateMachine:changeState(nil, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, var_2_0)
	var_2_0.saveIfDirty(arg_2_1)
	arg_2_4:forEachHookFn("setClubViewInfo")
end

function ClubViewState.update(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8)
	local var_3_0 = arg_3_0.clubViewInfo
	local var_3_1 = arg_3_0.stateMachine:getCurrentState()

	var_3_0.saveUpdate(arg_3_1)

	if var_3_1 then
		arg_3_0.stateMachine:update(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, var_3_0)
	else
		return arg_3_8(var_3_0)
	end
end

function ClubViewState.render(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4)
	arg_4_0.stateMachine:render(arg_4_1, arg_4_2, arg_4_3, arg_4_4)
end

-- player-import-export mod: team export ----------------------------------------
-- Share teams as JSON files (export only):
--   * X on the club hub ("Export Team") saves the team being viewed.
--   * The home screen's Clubs submenu gets Export Teams (row added from
--     app/noesis/homescreen/nvm_homescreen.lua): Created & Edited Teams, Base
--     Game Teams or All Teams.
-- A team holds its identity, emblem, home grounds, kits (every design option),
-- default kits, coach, roster and lineups. The file also carries every player
-- in the roster and lineups, in the player export's format, so it stands on
-- its own. Field lists come from the design tables (identitymap ClubIdentity /
-- ClubHomeGroundInfo, assetmap.options.team). The JSON codec, file dialog and
-- busy screen are shared with app/player/player_viewstate_hub_state.lua.

import("app.player.player_viewstate_hub_state")
import("app.match.stadium_helper")
import("base.ui.optionmenu.optionmenu_state")
import("base.ui.optionmenu.optionmenu_aide")
import("design.characters.assetmap")
import("design.characters.identitymap")

local TeamPlayerTransfer = player_viewstate_hub_state.PlayerTransfer
local TeamShared = TeamPlayerTransfer.shared
local teamTransferSafe = TeamShared.safe
local teamTransferToNumber = TeamShared.toNumber

TeamTransfer = {}

local TeamTransferLabels = {
	exportTeam = "Export Team",
	exportTeams = "Export Teams",
	exportCreated = "Created & Edited Teams",
	exportBase = "Base Game Teams",
	exportAll = "All Teams",
	busyExport = "Exporting Teams",
	exportingTeams = "Exporting team %d of %d...",
	exportingPlayers = "Exporting player %d of %d...",
	writing = "Writing file...",
	noDialog = "The file browser could not be opened.",
	exportedOne = "Exported %s (%d player(s)) to:\n%s",
	exportedMany = "Exported %d team(s) and %d player(s) to:\n%s",
	teamsSkipped = "%d team(s) could not be read and were left out.",
	playersSkipped = "%d player(s) could not be read and were left out.",
	customLogos = "%d team(s) use a logo made in the Logo editor. The file only has the logo's id, not the image.",
	writeFailed = "Could not write the file:\n%s\n\n%s",
	serialiseFailed = "Could not read this team's data.",
	nothingToExport = "There are no teams in this list."
}

local TeamTransferFormatOne = "RL26TeamExport"
local TeamTransferFormatMany = "RL26TeamsExport"
local TeamTransferTeamBatch = 3
local TeamTransferFilters = {
	dialog = "Team files (*.json)|*.json|All files (*.*)|*.*",
	task = "Team files (*.json)\0*.json\0All files (*.*)\0*.*\0"
}

-- sex is written at the top of the team and the grounds are read through
-- getGround. Array fields (colours, feeder clubs) are skipped by the spec
-- loop; the colours are read below.
local TeamTransferSkipIdentity = {
	sex = true,
	homeGroundCount = true
}
local TeamTransferColours = {
	"primaryRGBColour",
	"secondaryRGBColour",
	"hudTextRGBColour"
}

-- Set by the Academy editor but not listed in identitymap.
local TeamTransferIdentityExtras = {
	"colourSet",
	"showUniformEmblemDecals"
}
local TeamTransferSkipGround = {
	isOnDisk = true
}
local TeamTransferSkipUniform = {
	version = true,
	sex = true
}
local TeamTransferSpecialRoles = {
	captain = "Captain",
	goalKicker = "GoalKicker",
	playMaker = "PlayMaker"
}

-- Team fields -------------------------------------------------------------------

local TeamTransferSpecs

local function teamTransferIdentityMap(name)
	for _, entry in ipairs(identitymap.Data) do
		if type(entry) == "table" and type(entry[name]) == "table" then
			return entry[name]
		end
	end

	return {}
end

local function teamTransferValueKind(definition)
	return definition.type == "string" and "string" or definition.type == "bool" and "bool" or definition.type == "integer" and "integer" or nil
end

function TeamTransfer.getSpecs()
	if TeamTransferSpecs then
		return TeamTransferSpecs
	end

	local specs = {}

	for _, sectionName in ipairs({
		"identity",
		"ground",
		"uniform"
	}) do
		specs[sectionName] = {
			list = {},
			byName = {}
		}
	end

	for name, definition in pairs(teamTransferIdentityMap("ClubIdentity")) do
		if type(definition) == "table" and not definition.arraySize and not TeamTransferSkipIdentity[name] then
			local kind = teamTransferValueKind(definition)

			if kind then
				TeamShared.addSpec(specs.identity, name, definition, kind)
			end
		end
	end

	for name, definition in pairs(teamTransferIdentityMap("ClubHomeGroundInfo")) do
		if type(definition) == "table" and not definition.arraySize and not TeamTransferSkipGround[name] then
			local kind = teamTransferValueKind(definition)

			if kind then
				TeamShared.addSpec(specs.ground, name, definition, kind)
			end
		end
	end

	for name, definition in pairs(assetmap.options.team) do
		if type(definition) == "table" and not definition.noSave and not TeamTransferSkipUniform[name] then
			if definition.type == "guid" then
				TeamShared.addSpec(specs.uniform, name, definition, "guid")
			elseif definition.type == "slider" then
				TeamShared.addSpec(specs.uniform, name, definition, "slider")
			end
		end
	end

	for _, section in pairs(specs) do
		table.sort(section.list, function(a, b)
			return a.name < b.name
		end)
	end

	TeamTransferSpecs = specs

	return specs
end

local function teamTransferReadAll(config, section, values)
	values = values or {}

	if config then
		for _, spec in ipairs(section.list) do
			local value = TeamShared.readField(config, spec)

			if value ~= nil then
				values[spec.name] = value
			end
		end
	end

	return values
end

local function teamTransferIsOfficialClubId(id)
	if id == nil then
		return false
	end

	if teamTransferSafe(function()
		return native.CClubManager.getIsOnDiscClub(id)
	end) == true then
		return true
	end

	return teamTransferSafe(function()
		return native.CClubDatabaseOnDisc.getIsOfficialClubId(id)
	end) == true
end

local function teamTransferColour(identity, name)
	local colour = teamTransferSafe(function()
		return identity[name]
	end)

	if colour == nil then
		return nil
	end

	local rgb = {}

	for _, channel in ipairs({
		"r",
		"g",
		"b"
	}) do
		local value = teamTransferToNumber(teamTransferSafe(function()
			return colour[channel]
		end))

		if value == nil or value ~= value then
			return nil
		end

		rgb[channel] = math.floor(value + 0.5)
	end

	return rgb
end

local function teamTransferIdentity(identity)
	local values = teamTransferReadAll(identity, TeamTransfer.getSpecs().identity)

	if not identity then
		return values
	end

	for _, name in ipairs(TeamTransferColours) do
		values[name] = teamTransferColour(identity, name)
	end

	for _, name in ipairs(TeamTransferIdentityExtras) do
		local value = teamTransferSafe(function()
			return identity[name]
		end)

		if type(value) == "boolean" then
			values[name] = value
		else
			value = teamTransferToNumber(value)

			if value ~= nil and value == value then
				values[name] = value
			end
		end
	end

	return values
end

-- icon: a stock club badge by name. decalId: a logo made in the Logo editor,
-- which lives in the local decal store (only its id can be written).
local function teamTransferEmblem(identity)
	local emblem = {}
	local decal = identity and teamTransferSafe(function()
		return identity.decalIdOrIcon
	end)

	if decal == nil then
		return emblem
	end

	local icon = teamTransferSafe(function()
		return decal.icon
	end)

	if type(icon) == "string" and icon ~= "" then
		emblem.icon = icon
	end

	local decalId = teamTransferSafe(function()
		return decal.decalId
	end)

	if type(decalId) == "string" and decalId ~= "" then
		emblem.decalId = decalId
	else
		decalId = teamTransferToNumber(decalId)

		if decalId ~= nil then
			emblem.decalId = decalId
		end
	end

	if emblem.decalId ~= nil then
		emblem.customLogo = true
	end

	return emblem
end

local function teamTransferGrounds(identity)
	local list = {}
	local count = identity and teamTransferToNumber(teamTransferSafe(function()
		return identity.groundCount
	end)) or 0
	local section = TeamTransfer.getSpecs().ground

	for index = 1, count do
		local ground = teamTransferSafe(function()
			return identity:getGround(index)
		end)

		if ground then
			local values = teamTransferReadAll(ground, section)
			local label = teamTransferSafe(function()
				return stadium_helper.getClubStadiumLabel(ground)
			end)

			if type(label) == "string" and label ~= "" then
				values.label = label
			end

			list[#list + 1] = values
		end
	end

	return TeamPlayerTransfer.jsonArray(list)
end

local function teamTransferUniforms(club, withOptions)
	local list = {}
	local count = teamTransferToNumber(teamTransferSafe(function()
		return club.uniformCount
	end)) or 0
	local section = TeamTransfer.getSpecs().uniform

	for index = 1, count do
		local uniform = teamTransferSafe(function()
			return club:getUniform(index)
		end)

		if uniform then
			local entry = {
				name = tostring(teamTransferSafe(function()
					return uniform.name
				end) or "")
			}
			local displayName = teamTransferSafe(function()
				return uniform:getDisplayName(index)
			end)

			if type(displayName) == "string" and displayName ~= entry.name then
				entry.displayName = displayName
			end

			for key, field in pairs({
				hidden = "isHidden",
				nines = "isNines"
			}) do
				local value = teamTransferSafe(function()
					return uniform[field]
				end)

				if type(value) == "boolean" then
					entry[key] = value
				end
			end

			if withOptions then
				entry.options = teamTransferReadAll(teamTransferSafe(function()
					return uniform.config
				end), section)
			end

			list[#list + 1] = entry
		end
	end

	return TeamPlayerTransfer.jsonArray(list)
end

-- Kit index (1-based) per category. Nines is left out, like the stock Set
-- Defaults menu.
local function teamTransferUniformDefaults(club)
	local defaults = {}
	local categories = teamTransferSafe(function()
		return native.CClubUniformCategory
	end)
	local count = categories and teamTransferToNumber(teamTransferSafe(function()
		return categories.Count
	end)) or 0

	for index = 1, count do
		local category = teamTransferSafe(function()
			return categories:fromInt(index - 1)
		end)

		if category ~= nil and category ~= categories.Nines then
			local value = teamTransferToNumber(teamTransferSafe(function()
				return club:getDefaultUniformIndex(category)
			end))

			if value ~= nil then
				defaults[tostring(category)] = value
			end
		end
	end

	return defaults
end

local function teamTransferRoster(club)
	local ids = {}
	local count = teamTransferToNumber(teamTransferSafe(function()
		return club.playerCount
	end)) or 0

	for index = 1, count do
		local id = teamTransferToNumber(teamTransferSafe(function()
			return club:getPlayerIdAt(index)
		end))

		if id ~= nil then
			ids[#ids + 1] = id
		end
	end

	return TeamPlayerTransfer.jsonArray(ids)
end

-- Only the slots the lineup's category has are read: slots past the end hold
-- uninitialised memory (see clear-academy-data).
local function teamTransferLineups(club)
	local list = {}
	local count = teamTransferToNumber(teamTransferSafe(function()
		return club:getLineupCount()
	end)) or 0

	for index = 1, count do
		local lineup = teamTransferSafe(function()
			return club:getLineup(index)
		end)

		if lineup then
			local category = teamTransferSafe(function()
				return lineup.category
			end)
			local size = category ~= nil and teamTransferToNumber(teamTransferSafe(function()
				return native.CClubLineup.getLineupSize(category)
			end) or teamTransferSafe(function()
				return native.CClubLineupDefintions.getLineupSizeMax(category)
			end)) or 0
			local entry = {
				category = category ~= nil and tostring(category) or nil,
				players = TeamPlayerTransfer.jsonArray()
			}

			for slot = 1, size do
				local id = teamTransferToNumber(teamTransferSafe(function()
					return lineup:getPlayerIdAt(slot)
				end))

				entry.players[slot] = id or TeamPlayerTransfer.JsonNull
			end

			for key, roleName in pairs(TeamTransferSpecialRoles) do
				local id = teamTransferToNumber(teamTransferSafe(function()
					return lineup:getSpecialRole(native.EClubLineupSpecialRole[roleName])
				end))

				if id ~= nil then
					entry[key] = id
				end
			end

			list[#list + 1] = entry
		end
	end

	return TeamPlayerTransfer.jsonArray(list)
end

local function teamTransferSexName(identity)
	return teamTransferSafe(function()
		return identity.sex == native.CSex.Female
	end) and "Female" or "Male"
end

-- options.withKitOptions = false leaves out each kit's design options (used to
-- compare a club with its stock copy cheaply). options.created / options.edited
-- are written as given.
function TeamTransfer.serialiseTeam(club, options)
	options = options or {}

	local identity = teamTransferSafe(function()
		return club.identity
	end)
	local id = teamTransferSafe(function()
		return club.id
	end)
	local data = {
		id = teamTransferToNumber(id) or id,
		name = tostring(teamTransferSafe(function()
			return club.fullName
		end) or ""),
		sex = teamTransferSexName(identity),
		baseGame = teamTransferIsOfficialClubId(id),
		identity = teamTransferIdentity(identity),
		emblem = teamTransferEmblem(identity),
		homeGrounds = teamTransferGrounds(identity),
		uniforms = teamTransferUniforms(club, options.withKitOptions ~= false),
		uniformDefaults = teamTransferUniformDefaults(club),
		roster = teamTransferRoster(club),
		lineups = teamTransferLineups(club)
	}
	local academyId = teamTransferToNumber(teamTransferSafe(function()
		return club.academyId
	end))

	if academyId ~= nil and academyId ~= data.id then
		data.academyId = academyId
	end

	local coachId = teamTransferToNumber(teamTransferSafe(function()
		return club.coachId
	end))

	if coachId ~= nil then
		data.coachId = coachId
	end

	if options.created ~= nil then
		data.created = options.created
	end

	if options.edited ~= nil then
		data.edited = options.edited
	end

	return data
end

-- Every player id in the roster and lineups, in order, once.
function TeamTransfer.playerIdsOf(team, out, seen)
	out = out or {}
	seen = seen or {}

	local function add(id)
		if type(id) == "number" and not seen[id] then
			seen[id] = true
			out[#out + 1] = id
		end
	end

	for _, id in ipairs(team.roster or {}) do
		add(id)
	end

	for _, lineup in ipairs(team.lineups or {}) do
		for _, id in ipairs(lineup.players or {}) do
			add(id)
		end
	end

	return out, seen
end

local function teamTransferSignature(club)
	return TeamPlayerTransfer.encode(TeamTransfer.serialiseTeam(club, {
		withKitOptions = false
	}))
end

-- Stock copy of an official club: clubManager.onDisc already has Academy
-- edits merged in, onDiscDatabase is the raw disc data.
local function teamTransferStockClub(clubManager, id)
	return teamTransferSafe(function()
		return clubManager.onDiscDatabase:getClub(id)
	end) or teamTransferSafe(function()
		return clubManager.onDisc:getClub(id)
	end)
end

-- Official club edits live in the native custom-licensed store, not
-- userCreated, so compare the live club with the stock one.
function TeamTransfer.isEditedOfficial(clubManager, id, live)
	live = live or teamTransferSafe(function()
		return clubManager:getClub(id)
	end)

	local stock = teamTransferStockClub(clubManager, id)

	if not live or not stock or rawequal(live, stock) then
		return false
	end

	local ok, a = pcall(teamTransferSignature, live)
	local okStock, b = pcall(teamTransferSignature, stock)

	return ok and okStock and a ~= b
end

-- created: Academy-made (and downloaded) clubs plus edited official clubs.
-- base: every on-disc club. all: both, once each.
function TeamTransfer.collectExportIds(clubManager)
	local lists = {
		created = {},
		base = {},
		all = {},
		edited = {},
		made = {}
	}
	local seen = {
		created = {},
		base = {},
		all = {}
	}

	local function add(listName, id)
		if id ~= nil and not seen[listName][id] then
			seen[listName][id] = true

			local list = lists[listName]

			list[#list + 1] = id
		end
	end

	pcall(function()
		for _, club in clubManager.userCreated:iterateAll() do
			local id = club and club.id

			if id ~= nil and not teamTransferIsOfficialClubId(id) then
				lists.made[id] = true

				add("created", id)
			end
		end
	end)
	pcall(function()
		for _, disc in clubManager.onDisc:iterateAll() do
			local id = disc and disc.id

			if id ~= nil then
				add("base", id)

				if TeamTransfer.isEditedOfficial(clubManager, id) then
					lists.edited[id] = true

					add("created", id)
				end
			end
		end
	end)

	for _, listName in ipairs({
		"base",
		"created"
	}) do
		for _, id in ipairs(lists[listName]) do
			add("all", id)
		end
	end

	return lists
end

-- Documents ---------------------------------------------------------------------

local function teamTransferSerialisePlayers(playerManager, ids)
	local players, skipped = {}, 0

	for _, id in ipairs(ids) do
		local ok, data = pcall(function()
			return TeamPlayerTransfer.serialisePlayer(VERIFY(playerManager:getPlayer(id)))
		end)

		if ok then
			players[#players + 1] = data
		else
			skipped = skipped + 1

			TeamShared.logError("export team player " .. tostring(id) .. " failed: " .. tostring(data))
		end
	end

	return players, skipped
end

-- Returns the document and how many players couldn't be read.
function TeamTransfer.exportDocument(club, playerManager, options)
	local team = TeamTransfer.serialiseTeam(club, options)
	local players, skipped = teamTransferSerialisePlayers(playerManager, TeamTransfer.playerIdsOf(team))

	return {
		format = TeamTransferFormatOne,
		version = TeamShared.version,
		game = "Rugby League 26",
		exportedAt = os.date("!%Y-%m-%dT%H:%M:%SZ"),
		team = team,
		playerCount = #players,
		players = TeamPlayerTransfer.jsonArray(players)
	}, skipped
end

local function teamTransferFilePart(text)
	text = string.gsub(tostring(text or ""), "[^%w%-]+", "_")
	text = string.gsub(text, "^_+", "")

	return (string.gsub(text, "_+$", ""))
end

function TeamTransfer.defaultFileName(club)
	local pieces = {
		"Team"
	}
	local name = teamTransferFilePart(teamTransferSafe(function()
		return club.fullName
	end))

	if name ~= "" then
		pieces[#pieces + 1] = name
	end

	pieces[#pieces + 1] = tostring(teamTransferSafe(function()
		return club.id
	end))

	return table.concat(pieces, "_") .. ".json"
end

-- Export Team (club hub) --------------------------------------------------------

local function teamTransferWriteOne(state, engine, time, uiServices, partyMember, pending, path)
	local ok, err = TeamShared.writeFile(engine, path, pending.text)
	local lines = {}

	if ok then
		lines[1] = string.format(TeamTransferLabels.exportedOne, pending.fullName, pending.playerCount, path)

		if pending.skipped > 0 then
			lines[#lines + 1] = ""
			lines[#lines + 1] = string.format(TeamTransferLabels.playersSkipped, pending.skipped)
		end

		if pending.customLogo then
			lines[#lines + 1] = ""
			lines[#lines + 1] = string.format(TeamTransferLabels.customLogos, 1)
		end
	else
		lines[1] = string.format(TeamTransferLabels.writeFailed, path, tostring(err))
	end

	TeamShared.alert(state, engine, time, uiServices, partyMember, {
		options = "ok",
		text = table.concat(lines, "\n")
	})
end

local function teamTransferExportViewed(state, engine, time, uiServices, info)
	local club = info.club
	local clubManager = uiServices:getClubManager()
	local id = teamTransferSafe(function()
		return club.id
	end)
	local flags = {
		created = not teamTransferIsOfficialClubId(id)
	}

	if not flags.created then
		flags.edited = TeamTransfer.isEditedOfficial(clubManager, id, club)
	end

	local ok, doc, skipped = pcall(TeamTransfer.exportDocument, club, uiServices:getPlayerManager(), flags)
	local text

	if ok then
		ok, text = pcall(function()
			return TeamPlayerTransfer.encode(doc) .. "\n"
		end)
	else
		text = doc
	end

	if not ok then
		TeamShared.logError("export team failed: " .. tostring(text))
		TeamShared.alert(state, engine, time, uiServices, info.partyMember, {
			options = "ok",
			text = TeamTransferLabels.serialiseFailed
		})

		return
	end

	local pending = {
		text = text,
		fullName = doc.team.name,
		playerCount = doc.playerCount,
		skipped = skipped or 0,
		customLogo = doc.team.emblem.customLogo == true
	}
	local result, path = TeamShared.browse(uiServices, true, TeamTransfer.defaultFileName(club), "TeamTransferExportOne", TeamTransferFilters)

	if result == "picked" then
		teamTransferWriteOne(state, engine, time, uiServices, info.partyMember, pending, path)
	elseif result == "pending" then
		state.teamTransferPending = pending
	elseif result == "unavailable" then
		TeamShared.alert(state, engine, time, uiServices, info.partyMember, {
			options = "ok",
			text = TeamTransferLabels.noDialog
		})
	end
end

-- The prompt only shows on the hub itself: the tiles' own screens use X (e.g.
-- Delete in the kit list).
local function teamTransferOnHub(state)
	local hub = state.stateMachine and state.stateMachine:getCurrentState()
	local hubClass = club_viewstate_hub_state.ClubViewHubState

	if not hub or not hubClass or state.stateMachine.isTransitioning or hub.update ~= hubClass.update then
		return nil
	end

	return hub
end

local function teamTransferHubUpdate(state, engine, time, uiServices)
	local info = state.clubViewInfo

	if not info or info.inCommunity or not info.club or not info.partyMember then
		return
	end

	local hub = teamTransferOnHub(state)

	if not hub or not hub.view or not hub.view.userInputEnabled or hub.viewModel and hub.viewModel.subMenuClosing then
		return
	end

	if state.alertOpen or uiServices:getIsBlockingMixinActive() or state.ignoreInputUntil and time < state.ignoreInputUntil then
		return
	end

	uiServices:addTooltip(nil, native.InputTypes.X, TeamTransferLabels.exportTeam)

	if uiServices:checkForRelease(info.partyMember, native.InputTypes.X) then
		uiServices:playSound("Select")
		teamTransferExportViewed(state, engine, time, uiServices, info)
	end
end

local teamTransferStockUpdate = ClubViewState.update
local teamTransferStockExit = ClubViewState.exit

function ClubViewState.update(arg_tt_0, arg_tt_1, arg_tt_2, arg_tt_3, arg_tt_4, arg_tt_5, arg_tt_6, arg_tt_7, arg_tt_8)
	local pending = arg_tt_0.teamTransferPending

	-- An async dialog task (fallback path) is open: wait for it, like the
	-- stock custom face import does.
	if pending then
		arg_tt_0.clubViewInfo.saveUpdate(arg_tt_1)

		local done, path = TeamShared.pollDialog(arg_tt_5, "TeamTransferExportOne", true)

		if done then
			arg_tt_0.teamTransferPending = nil

			if path then
				teamTransferWriteOne(arg_tt_0, arg_tt_1, arg_tt_2, arg_tt_5, arg_tt_0.clubViewInfo.partyMember, pending, path)
			end
		end

		return
	end

	if not arg_tt_0.stateMachine:getCurrentState() then
		return teamTransferStockUpdate(arg_tt_0, arg_tt_1, arg_tt_2, arg_tt_3, arg_tt_4, arg_tt_5, arg_tt_6, arg_tt_7, arg_tt_8)
	end

	teamTransferStockUpdate(arg_tt_0, arg_tt_1, arg_tt_2, arg_tt_3, arg_tt_4, arg_tt_5, arg_tt_6, arg_tt_7, arg_tt_8)

	local ok, err = pcall(teamTransferHubUpdate, arg_tt_0, arg_tt_1, arg_tt_2, arg_tt_5)

	if not ok then
		TeamShared.logError("hub team export: " .. tostring(err))
	end
end

function ClubViewState.exit(arg_tt_10, arg_tt_11, arg_tt_12, arg_tt_13, arg_tt_14, arg_tt_15)
	if arg_tt_10.teamTransferPending then
		arg_tt_10.teamTransferPending = nil

		TeamShared.disposeDialog(arg_tt_14, "TeamTransferExportOne")
	end

	teamTransferStockExit(arg_tt_10, arg_tt_11, arg_tt_12, arg_tt_13, arg_tt_14, arg_tt_15)
end

-- Export Teams ------------------------------------------------------------------
-- Three buttons (created & edited / base game / all) with counts, then a save
-- dialog and a busy screen: the teams are read a few per frame, then their
-- players (each once) a batch per frame.

local var_tt_0 = optionmenu_state.OptionMenuState

Class("AcademyTeamExportAllState", var_tt_0)

local TeamTransferLists = {
	{
		key = "created",
		label = TeamTransferLabels.exportCreated,
		file = "Created"
	},
	{
		key = "base",
		label = TeamTransferLabels.exportBase,
		file = "BaseGame"
	},
	{
		key = "all",
		label = TeamTransferLabels.exportAll,
		file = "All"
	}
}

function AcademyTeamExportAllState.enter(arg_tt_20, arg_tt_21, arg_tt_22, arg_tt_23, arg_tt_24, arg_tt_25, arg_tt_26, arg_tt_27, arg_tt_28)
	arg_tt_20.phase = "menu"
	arg_tt_20.goBackFactoryStack = arg_tt_28
	arg_tt_20.lists = TeamTransfer.collectExportIds(arg_tt_25:getClubManager())

	TeamShared.log(string.format("team export lists: created %d, base %d, all %d", #arg_tt_20.lists.created, #arg_tt_20.lists.base, #arg_tt_20.lists.all))
	pcall(function()
		arg_tt_25:titleSetSubAreaOfGame(TeamTransferLabels.exportTeams)
	end)
	var_tt_0.enter(arg_tt_20, arg_tt_22, arg_tt_23, arg_tt_24, arg_tt_25, arg_tt_20:createMenuItems(), nil, {
		noSpaceBeforePanel = true,
		examineSelectionBeforeExit = true,
		itemParams = {},
		titleBox = {
			left = true,
			title = TeamTransferLabels.exportTeams
		}
	})
end

function AcademyTeamExportAllState.createMenuItems(arg_tt_30)
	local items = {}

	for _, list in ipairs(TeamTransferLists) do
		items[#items + 1] = optionmenu_aide.createButton(string.format("%s (%d)", list.label, #arg_tt_30.lists[list.key]), {
			teamTransferAction = list.key
		})
	end

	return items
end

function AcademyTeamExportAllState.startExport(arg_tt_40, arg_tt_41, arg_tt_42, arg_tt_43, arg_tt_44, arg_tt_45)
	local ids = arg_tt_40.lists[arg_tt_45]

	if #ids == 0 then
		TeamShared.alert(arg_tt_40, arg_tt_41, arg_tt_42, arg_tt_43, arg_tt_44.partyMember, {
			options = "ok",
			text = TeamTransferLabels.nothingToExport
		})

		return
	end

	local fileTag = arg_tt_45

	for _, list in ipairs(TeamTransferLists) do
		if list.key == arg_tt_45 then
			fileTag = list.file
		end
	end

	local defaultName = string.format("Teams_%s_%d_%s.json", fileTag, #ids, os.date("%Y-%m-%d"))
	local result, path = TeamShared.browse(arg_tt_43, true, defaultName, "TeamTransferExportAll", TeamTransferFilters)

	arg_tt_40.exportIds = ids

	if result == "picked" then
		arg_tt_40:beginExport(arg_tt_41, arg_tt_42, path)
	elseif result == "pending" then
		arg_tt_40.phase = "dialog"
	elseif result == "unavailable" then
		TeamShared.alert(arg_tt_40, arg_tt_41, arg_tt_42, arg_tt_43, arg_tt_44.partyMember, {
			options = "ok",
			text = TeamTransferLabels.noDialog
		})
	end
end

function AcademyTeamExportAllState.beginExport(arg_tt_50, arg_tt_51, arg_tt_52, arg_tt_53)
	arg_tt_50.path = arg_tt_53
	arg_tt_50.phase = "teams"
	arg_tt_50.exportIndex = 1
	arg_tt_50.teamParts = {}
	arg_tt_50.playerIds = {}
	arg_tt_50.playerSeen = {}
	arg_tt_50.playerIndex = 1
	arg_tt_50.playerParts = {}
	arg_tt_50.teamsSkipped = 0
	arg_tt_50.playersSkipped = 0
	arg_tt_50.customLogos = 0

	TeamShared.openBusy(arg_tt_50, arg_tt_51, arg_tt_52, TeamTransferLabels.busyExport, string.format(TeamTransferLabels.exportingTeams, 0, #arg_tt_50.exportIds))
end

-- One team: its JSON text (indented for the hand-built bulk document) is kept
-- and its players are queued.
function AcademyTeamExportAllState.exportTeam(arg_tt_60, arg_tt_61, arg_tt_62)
	local lists = arg_tt_60.lists
	local flags = {
		created = lists.made[arg_tt_62] == true
	}

	if not flags.created then
		flags.edited = lists.edited[arg_tt_62] == true
	end

	local ok, team = pcall(function()
		return TeamTransfer.serialiseTeam(VERIFY(arg_tt_61:getClub(arg_tt_62)), flags)
	end)
	local text

	if ok then
		ok, text = pcall(TeamPlayerTransfer.encode, team, "    ")
	else
		text = team
	end

	if not ok then
		arg_tt_60.teamsSkipped = arg_tt_60.teamsSkipped + 1

		TeamShared.logError("export team " .. tostring(arg_tt_62) .. " failed: " .. tostring(text))

		return
	end

	arg_tt_60.teamParts[#arg_tt_60.teamParts + 1] = text

	if team.emblem.customLogo then
		arg_tt_60.customLogos = arg_tt_60.customLogos + 1
	end

	TeamTransfer.playerIdsOf(team, arg_tt_60.playerIds, arg_tt_60.playerSeen)
end

function AcademyTeamExportAllState.finishExport(arg_tt_70, arg_tt_71, arg_tt_72, arg_tt_73, arg_tt_74)
	local teamParts = arg_tt_70.teamParts
	local playerParts = arg_tt_70.playerParts
	local text = table.concat({
		"{\n",
		"  \"format\": ",
		TeamShared.jsonString(TeamTransferFormatMany),
		",\n",
		"  \"version\": ",
		tostring(TeamShared.version),
		",\n",
		"  \"game\": \"Rugby League 26\",\n",
		"  \"exportedAt\": ",
		TeamShared.jsonString(os.date("!%Y-%m-%dT%H:%M:%SZ")),
		",\n",
		"  \"count\": ",
		tostring(#teamParts),
		",\n",
		"  \"teams\": ",
		#teamParts > 0 and "[\n    " .. table.concat(teamParts, ",\n    ") .. "\n  ]" or "[]",
		",\n",
		"  \"playerCount\": ",
		tostring(#playerParts),
		",\n",
		"  \"players\": ",
		#playerParts > 0 and "[\n    " .. table.concat(playerParts, ",\n    ") .. "\n  ]" or "[]",
		"\n}\n"
	})

	arg_tt_70.teamParts = nil
	arg_tt_70.playerParts = nil

	local ok, err = TeamShared.writeFile(arg_tt_71, arg_tt_70.path, text)

	text = nil

	collectgarbage()
	TeamShared.closeBusy(arg_tt_70)

	arg_tt_70.phase = "menu"

	local lines = {}

	if ok then
		lines[1] = string.format(TeamTransferLabels.exportedMany, #teamParts, #playerParts, arg_tt_70.path)

		for _, entry in ipairs({
			{
				arg_tt_70.teamsSkipped,
				TeamTransferLabels.teamsSkipped
			},
			{
				arg_tt_70.playersSkipped,
				TeamTransferLabels.playersSkipped
			},
			{
				arg_tt_70.customLogos,
				TeamTransferLabels.customLogos
			}
		}) do
			if entry[1] > 0 then
				lines[#lines + 1] = ""
				lines[#lines + 1] = string.format(entry[2], entry[1])
			end
		end
	else
		lines[1] = string.format(TeamTransferLabels.writeFailed, arg_tt_70.path, tostring(err))
	end

	TeamShared.alert(arg_tt_70, arg_tt_71, arg_tt_72, arg_tt_73, arg_tt_74.partyMember, {
		options = "ok",
		text = table.concat(lines, "\n")
	})
end

function AcademyTeamExportAllState.updateExport(arg_tt_80, arg_tt_81, arg_tt_82, arg_tt_83, arg_tt_84, arg_tt_85)
	if arg_tt_80.area then
		arg_tt_80.area:update(arg_tt_83)
	end

	if arg_tt_80.busyArea then
		arg_tt_80.busyArea:update(arg_tt_83)
	end

	local phase = arg_tt_80.phase

	if phase == "dialog" then
		local done, path = TeamShared.pollDialog(arg_tt_84, "TeamTransferExportAll", true)

		if done then
			if path then
				arg_tt_80:beginExport(arg_tt_81, arg_tt_82, path)
			else
				arg_tt_80.phase = "menu"
			end
		end
	elseif phase == "teams" then
		local ids = arg_tt_80.exportIds
		local clubManager = arg_tt_84:getClubManager()
		local done = 0

		while arg_tt_80.exportIndex <= #ids and done < TeamTransferTeamBatch do
			arg_tt_80:exportTeam(clubManager, ids[arg_tt_80.exportIndex])

			arg_tt_80.exportIndex = arg_tt_80.exportIndex + 1
			done = done + 1
		end

		if arg_tt_80.exportIndex <= #ids then
			TeamShared.setBusy(arg_tt_80, string.format(TeamTransferLabels.exportingTeams, arg_tt_80.exportIndex - 1, #ids))
		else
			arg_tt_80.phase = "players"

			TeamShared.setBusy(arg_tt_80, string.format(TeamTransferLabels.exportingPlayers, 0, #arg_tt_80.playerIds))
		end
	elseif phase == "players" then
		local ids = arg_tt_80.playerIds
		local playerManager = arg_tt_84:getPlayerManager()
		local done = 0

		while arg_tt_80.playerIndex <= #ids and done < TeamShared.exportBatch do
			local id = ids[arg_tt_80.playerIndex]
			local ok, text = pcall(function()
				return TeamPlayerTransfer.encode(TeamPlayerTransfer.serialisePlayer(VERIFY(playerManager:getPlayer(id))), "    ")
			end)

			if ok then
				arg_tt_80.playerParts[#arg_tt_80.playerParts + 1] = text
			else
				arg_tt_80.playersSkipped = arg_tt_80.playersSkipped + 1

				TeamShared.logError("export team player " .. tostring(id) .. " failed: " .. tostring(text))
			end

			arg_tt_80.playerIndex = arg_tt_80.playerIndex + 1
			done = done + 1
		end

		if arg_tt_80.playerIndex <= #ids then
			TeamShared.setBusy(arg_tt_80, string.format(TeamTransferLabels.exportingPlayers, arg_tt_80.playerIndex - 1, #ids))
		else
			-- One more frame so "Writing file..." shows before the write blocks.
			arg_tt_80.phase = "write"

			TeamShared.setBusy(arg_tt_80, TeamTransferLabels.writing)
		end
	elseif phase == "write" then
		arg_tt_80:finishExport(arg_tt_81, arg_tt_82, arg_tt_84, arg_tt_85)
	end
end

function AcademyTeamExportAllState.update(arg_tt_90, arg_tt_91, arg_tt_92, arg_tt_93, arg_tt_94, arg_tt_95, arg_tt_96, arg_tt_97, arg_tt_98)
	if arg_tt_90.errorExited then
		return
	end

	local ok, err = xpcall(function()
		return arg_tt_90:updateInner(arg_tt_91, arg_tt_92, arg_tt_93, arg_tt_94, arg_tt_95, arg_tt_96, arg_tt_97, arg_tt_98)
	end, TeamShared.traceback)

	if not ok then
		-- Never soft-lock the UI: log the error and back out to the home screen.
		TeamShared.logError("team export update error (phase " .. tostring(arg_tt_90.phase) .. "): " .. tostring(err))

		arg_tt_90.errorExited = true

		local exited, exitErr = pcall(arg_tt_91.changeState, arg_tt_91, nil, arg_tt_92, arg_tt_93, arg_tt_95, arg_tt_96, arg_tt_98)

		if not exited then
			TeamShared.logError("exit after error failed: " .. tostring(exitErr))
		end
	end
end

function AcademyTeamExportAllState.updateInner(arg_tt_100, arg_tt_101, arg_tt_102, arg_tt_103, arg_tt_104, arg_tt_105, arg_tt_106, arg_tt_107, arg_tt_108)
	if arg_tt_100.phase ~= "menu" then
		arg_tt_100:updateExport(arg_tt_102, arg_tt_103, arg_tt_104, arg_tt_106, arg_tt_108)

		return
	end

	local partyMember = arg_tt_108.partyMember
	local _, _, _, selected = var_tt_0.update(arg_tt_100, arg_tt_102, arg_tt_103, arg_tt_104, arg_tt_105, arg_tt_106, arg_tt_107, partyMember:getInput())

	if arg_tt_100.alertOpen or arg_tt_106:getIsBlockingMixinActive() or arg_tt_100.ignoreInputUntil and arg_tt_103 < arg_tt_100.ignoreInputUntil then
		return
	end

	arg_tt_106:addTooltip(arg_tt_100.tooltipsWidget, native.InputTypes.Decline, native.Localise("Back"), 99)

	local action = selected and selected.teamTransferAction

	if action then
		arg_tt_106:playSound("Select")
		arg_tt_100:startExport(arg_tt_102, arg_tt_103, arg_tt_106, arg_tt_108, action)
	elseif arg_tt_106:checkForRelease(partyMember, native.InputTypes.Decline) then
		arg_tt_106:playSound("Back")
		arg_tt_101:changeState(nil, arg_tt_102, arg_tt_103, arg_tt_105, arg_tt_106, arg_tt_108)
	end
end

function AcademyTeamExportAllState.render(arg_tt_110, arg_tt_111, arg_tt_112, arg_tt_113, arg_tt_114, arg_tt_115)
	var_tt_0.render(arg_tt_110, arg_tt_111, arg_tt_112, arg_tt_113, arg_tt_114)

	if arg_tt_110.busyArea then
		arg_tt_110.busyArea:doRender(arg_tt_111, arg_tt_114)
	end
end

function AcademyTeamExportAllState.exit(arg_tt_120, arg_tt_121, arg_tt_122, arg_tt_123, arg_tt_124, arg_tt_125)
	TeamShared.closeBusy(arg_tt_120)
	TeamShared.disposeDialog(arg_tt_124, "TeamTransferExportAll")
	var_tt_0.exit(arg_tt_120, arg_tt_121, arg_tt_122, arg_tt_123, arg_tt_124, arg_tt_125)
end

-- Row for the home screen's Clubs submenu (added by nvm_homescreen.lua).
function TeamTransfer.menuRows()
	return {
		{
			teamTransferRow = true,
			title = TeamTransferLabels.exportTeams,
			stateData = {
				nextState = AcademyTeamExportAllState
			}
		}
	}
end
