local var_0_0 = native.InputTypes
local var_0_1 = native.getPlatformString()

local function var_0_2(arg_1_0, arg_1_1, arg_1_2, arg_1_3)
	local var_1_0 = arg_1_1:getParty()
	local var_1_1 = arg_1_1:getGameControlManager()
	local var_1_2 = var_1_0:checkForRelease(var_1_1, var_0_0.Start)

	if not var_1_2 and arg_1_0:checkForTooltipMouseInput(var_0_0.Start) then
		var_1_2 = var_1_0:getPrimaryPartyMember()
	end

	if var_1_2 and var_1_0:hasProfileSaveInProgress() then
		return
	end

	if var_0_1 == "xbox360" and var_1_2 and not var_1_2:hasProfileData() then
		native.showSignInUI(1, false, false, true)

		return nil
	end

	return var_1_2
end

-- revamp-stats-sync -----------------------------------------------------------
-- Keeps the base game players and clubs in line with the RL26 Revamped stats
-- repo (github.com/galaxsistudios/rl26-revamped-stats). The first time the
-- home screen is reached each session, version.json is fetched; players.json /
-- teams.json are downloaded when their sha256 differs from the one last
-- applied (rl26revamp_stats_state.txt in the game folder), then applied on the
-- home screen behind a blocking alert, players first, then teams.
--
-- Only official (on-disc) players and clubs are changed: nothing is added and
-- Academy-made players and clubs are left alone. Players go through the
-- player-import-export update path (tier-1 looks are never touched); clubs get
-- identity, colours, badge, coach, kit defaults, roster and lineups, and are
-- saved with saveCustomLicensed like the Academy editor does.
--
-- The game's own HTTP client does the download: CBasCommsTask requests
-- urlOverride .. endpoint (concatenated as is) when urlOverride is set, and
-- skips the BAS sign-in check. rl26_revamp.ini: stats_sync = false turns the
-- sync off; stats_url = <https base> fetches from somewhere else.
-- Everything is logged to revampstats_debug.txt in the game folder.

local StatsSyncBaseUrl = "https://raw.githubusercontent.com/galaxsistudios/rl26-revamped-stats/refs/heads/main"
local StatsSyncStateFile = "rl26revamp_stats_state.txt"
local StatsSyncLogFile = "revampstats_debug.txt"
local StatsSyncConfigFile = "rl26_revamp.ini"
local StatsSyncAlertId = "revampStatsSync"
local StatsSyncAskAlertId = "revampStatsSyncAsk"
local StatsSyncDoneAlertId = "revampStatsSyncDone"
local StatsSyncVersionFormat = "RL26RevampStatsVersion"
local StatsSyncPlayerBatch = 20
local StatsSyncTimeout = 300
local StatsSyncPollLimit = 4
-- Chunks downloaded at once (rl26_revamp.ini stats_parallel = 1..16), and how
-- many times a failed chunk is fetched again before its part is dropped.
local StatsSyncParallel = 6
local StatsSyncRetries = 2
-- A CClubLineup holds 19 ids and replacePlayerAt writes slot - 1 without a
-- bounds check (0x140f09180).
local StatsSyncMaxLineupSlots = 19
local StatsSyncParts = {
	{
		name = "players",
		file = "players.json",
		format = "RL26PlayersExport",
		list = "players"
	},
	{
		name = "teams",
		file = "teams.json",
		format = "RL26TeamsExport",
		list = "teams"
	}
}
-- The only appearance options applied to scanned (tier-1) players: hair and
-- headgear. Their head, hair and headwear meshes come from the scan (item
-- head + 1000), but the textures and colours come from these options.
-- tools/stats_sync.py keeps the same list in tier-1 chunk entries.
local StatsSyncTier1Appearance = {}

for _, name in ipairs({
	"helmet",
	"headwearColour1_r", "headwearColour1_g", "headwearColour1_b",
	"headwearColour2_r", "headwearColour2_g", "headwearColour2_b",
	"headwearColour3_r", "headwearColour3_g", "headwearColour3_b",
	"headwearColour4_r", "headwearColour4_g", "headwearColour4_b",
	"headStrappingColour1_r", "headStrappingColour1_g", "headStrappingColour1_b",
	"headStrappingColour2_r", "headStrappingColour2_g", "headStrappingColour2_b",
	"hair", "hairTop", "hairSide", "hairSide2", "hairTexture_cap", "hairTipsOption",
	"hairColour1", "hairColour2"
}) do
	StatsSyncTier1Appearance[name] = true
end

local StatsSyncSpecialRoles = {
	captain = "Captain",
	goalKicker = "GoalKicker",
	playMaker = "PlayMaker"
}
local StatsSyncLabels = {
	alertTitle = "RL26 Revamped",
	applying = "Updating the base game %s to the latest RL26 Revamped data.\nThis can take a minute.",
	players = "players",
	teams = "teams",
	playersTitle = "Players",
	teamsTitle = "Team lists",
	askIntro = "New RL26 Revamped data is available:",
	askIntroForce = "Download all RL26 Revamped player and team data again and re-apply it? This repairs any base game players and clubs that no longer match it:",
	menuTitle = "Sync Player & Team Data",
	menuDescription = "Download the latest RL26 Revamped player ratings and team lists and re-apply them to the base game players and clubs.",
	manualFailed = "Could not get the RL26 Revamped data. Check your internet connection and try again (details in revampstats_debug.txt).",
	manualBusy = "The RL26 Revamped data is already being synced.",
	askPart = "%s: %d (updated %s)",
	askPartSome = "%s: changes among %d (updated %s)",
	askFooter = "Download it now (%s)? It is applied to the base game players and clubs when it's ready. Academy-made players and clubs are not changed.",
	askYes = "Download",
	askNo = "Not now",
	downloading = "Downloading the latest RL26 Revamped data...",
	progressStart = "Connecting...",
	progressDownload = "Downloading %s: %d of %d\n%.1f of %.1f MB",
	progressApply = "Updating %s: %d of %d",
	progressSave = "Saving...",
	done = "RL26 Revamped data updated",
	restart = "Team lists were updated. Please restart the game before playing a match so every screen picks up the new lineups.\n",
	partDone = "%s: %d updated, %d already up to date",
	partFailed = "%s: %d could not be updated (see revampstats_debug.txt)"
}

local function statsSyncLog(text)
	pcall(function()
		local file = io.open(StatsSyncLogFile, "a")

		if file then
			file:write(os.date("%Y-%m-%d %H:%M:%S ") .. tostring(text) .. "\n")
			file:close()
		end
	end)
end

local function statsSyncSafe(fn, ...)
	local ok, result = pcall(fn, ...)

	if ok then
		return result
	end
end

local function statsSyncTraceback(err)
	if debug and debug.traceback then
		return debug.traceback(tostring(err), 2)
	end

	return tostring(err)
end

-- Returns whether the sync is on and the base URL to fetch from
-- (stats_url overrides the repo, e.g. for a local test server).
local function statsSyncConfig()
	local enabled, url, parallel = true, StatsSyncBaseUrl, StatsSyncParallel

	pcall(function()
		local file = io.open(StatsSyncConfigFile, "r")

		if not file then
			return
		end

		for line in file:lines() do
			local value = string.match(line, "^%s*stats_sync%s*=%s*(%a+)")

			if value then
				enabled = string.lower(value) ~= "false"
			end

			value = string.match(line, "^%s*stats_url%s*=%s*(%S+)")

			if value then
				url = string.gsub(value, "/+$", "")
			end

			value = tonumber(string.match(line, "^%s*stats_parallel%s*=%s*(%d+)"))

			if value then
				parallel = math.max(1, math.min(16, value))
			end
		end

		file:close()
	end)

	return enabled, url, parallel
end

local function statsSyncReadState()
	local state = {}

	pcall(function()
		local file = io.open(StatsSyncStateFile, "r")

		if not file then
			return
		end

		for line in file:lines() do
			-- "players=<sha>" per part, "players/007=<sha>" per chunk.
			local key, value = string.match(line, "^%s*([%w/]+)%s*=%s*(%x+)")

			if key then
				state[key] = string.lower(value)
			end
		end

		file:close()
	end)

	return state
end

local function statsSyncWriteState(state)
	pcall(function()
		local file = io.open(StatsSyncStateFile, "w")

		if file then
			file:write("; Last RL26 Revamped stats applied (sha256 of each file and chunk). Delete this file to apply them again.\n")

			for _, part in ipairs(StatsSyncParts) do
				if state[part.name] then
					file:write(part.name .. "=" .. state[part.name] .. "\n")
				end

				local keys = {}

				for key in pairs(state) do
					if string.sub(key, 1, #part.name + 1) == part.name .. "/" then
						keys[#keys + 1] = key
					end
				end

				table.sort(keys)

				for _, key in ipairs(keys) do
					file:write(key .. "=" .. state[key] .. "\n")
				end
			end

			file:close()
		end
	end)
end

-- Marks a part as applied: its file hash plus every chunk's hash (chunks that
-- weren't downloaded were already applied, their hash is unchanged).
local function statsSyncRecordApplied(sync, part)
	local state = sync.state
	local info = sync.info[part.name]

	state[part.name] = sync.remote[part.name]

	for key in pairs(state) do
		if string.sub(key, 1, #part.name + 1) == part.name .. "/" then
			state[key] = nil
		end
	end

	for index = 1, info.parts do
		if info.chunks[index] then
			state[string.format("%s/%03d", part.name, index - 1)] = info.chunks[index]
		end
	end
end

-- player-import-export owns the JSON codec, the player update path and the
-- team field specs. Imported here at run time (the home screen is up, so both
-- modules are already loaded) to keep the boot import order untouched.
local function statsSyncModules()
	local ok, result = pcall(function()
		import("app.player.player_viewstate_hub_state")
		import("app.club.club_view_state")
		import("base.ui.busy.busy_layout")

		return {
			player = assert(player_viewstate_hub_state.PlayerTransfer, "PlayerTransfer missing"),
			team = assert(club_view_state.TeamTransfer, "TeamTransfer missing"),
			busy = busy_layout
		}
	end)

	if ok then
		return result
	end

	statsSyncLog("player-import-export is not installed or failed to load: " .. tostring(result))
end

-- Requests and responses ------------------------------------------------------

local function statsSyncStartFetch(sync, engine, file, quiet, key)
	local task = native.CBasCommsTask(engine:getUserManager(), engine:getHttpRequestHandlerService(), {
		key = key or "RevampStatsSync",
		verb = "GET",
		endpoint = file,
		-- The request URL is urlOverride .. endpoint, no separator added
		-- (0x140dfd545); without the slash GitHub got ".../mainversion.json".
		urlOverride = sync.baseUrl .. "/"
	})

	if not quiet then
		statsSyncLog("GET " .. sync.baseUrl .. "/" .. file)
	end

	return task
end

local function statsSyncErrorText(task)
	local parts = {}

	for _, name in ipairs({
		"getStatus",
		"getLastErrorCode",
		"getBasErrorCode"
	}) do
		local value = statsSyncSafe(function()
			return task[name](task)
		end)

		parts[#parts + 1] = name .. "=" .. tostring(value)
	end

	return table.concat(parts, " ")
end

-- Pumps a download (holder.task, timed by holder.elapsed). Returns nil while running, then true and the response
-- (a string, or the table fillInfo built when there is no body string), or
-- false and a reason.
local function statsSyncPoll(holder, dt, quiet)
	local task = holder.task

	holder.elapsed = holder.elapsed + (tonumber(dt) or 0)

	local finished = task:update(dt)

	if not finished then
		if holder.elapsed > StatsSyncTimeout then
			holder.task = nil

			pcall(task.dispose, task)

			return false, "timed out"
		end

		return nil
	end

	holder.task = nil

	local success = statsSyncSafe(function()
		return task:getStatus() == native.ETaskStatus.success
	end)
	local body = statsSyncSafe(function()
		return task:getResponseBody()
	end)
	local response, reason

	if type(body) == "string" and body ~= "" then
		response = body
	elseif success then
		response = statsSyncSafe(function()
			return task:fillInfo()
		end)
	end

	if not success and type(body) == "string" and string.match(body, "^[\239\187\191%s]*{") then
		-- A large file arrives intact but the task still reports an error;
		-- the decoder decides whether it is complete.
		statsSyncLog(string.format("  task reported an error (%s) but returned %d bytes, ending %q", statsSyncErrorText(task), #body, string.sub(body, -60)))
	elseif not success then
		reason = "request failed (" .. statsSyncErrorText(task) .. ")"

		if type(body) == "string" then
			reason = reason .. string.format(" %d bytes: ", #body) .. string.sub(body, 1, 200)
		end
	elseif response == nil then
		reason = "empty response (body " .. type(body) .. ")"
	end

	pcall(task.dispose, task)

	if reason then
		return false, reason
	end

	if quiet then
		return true, response
	end

	statsSyncLog(string.format("  received %s in %.1fs", type(response) == "string" and string.format("%d bytes", #response) or "a " .. type(response), holder.elapsed))

	return true, response
end

local function statsSyncDecode(modules, response)
	if type(response) == "table" then
		return response
	end

	if string.sub(response, 1, 3) == "\239\187\191" then
		response = string.sub(response, 4)
	end

	return modules.player.decode(response)
end

-- Players ---------------------------------------------------------------------

local function statsSyncIsOnDiscPlayer(id)
	return type(id) == "number" and statsSyncSafe(native.CPlayerDatabaseOnDisc.getIsOnDiscPlayerId, id) == true
end

-- Returns "updated" | "unchanged" | "skipped" | "failed".
local function statsSyncApplyPlayer(apply, entry)
	if type(entry) ~= "table" or entry.baseGame ~= true then
		return "skipped"
	end

	local PlayerTransfer = apply.modules.player
	local clean, reason = PlayerTransfer.validatePlayer(entry)

	if not clean then
		statsSyncLog(string.format("  player %s (%s): %s", tostring(entry.id), tostring(entry.name), tostring(reason)))

		return "failed"
	end

	local targetId = PlayerTransfer.resolveTarget(apply.context, clean)

	if not statsSyncIsOnDiscPlayer(targetId) then
		statsSyncLog(string.format("  player %s (%s): no matching base game player", tostring(entry.id), clean.fullName))

		return "skipped"
	end

	local result, extra = PlayerTransfer.importOne(apply.context, {
		targetId = targetId,
		clean = clean
	})

	if result == nil then
		statsSyncLog(string.format("  player %d (%s): %s", targetId, clean.fullName, tostring(extra)))

		return "failed"
	end

	if type(extra) == "table" and #extra > 0 then
		statsSyncLog(string.format("  player %d (%s): could not set %s", targetId, clean.fullName, table.concat(extra, ", ")))
	end

	return result == "unchanged" and "unchanged" or "updated"
end

-- Teams -----------------------------------------------------------------------

local function statsSyncIsOfficialClub(id)
	if type(id) ~= "number" then
		return false
	end

	return statsSyncSafe(native.CClubManager.getIsOnDiscClub, id) == true or statsSyncSafe(native.CClubDatabaseOnDisc.getIsOfficialClubId, id) == true
end

local function statsSyncColour(rgb)
	if type(rgb) ~= "table" then
		return nil
	end

	local r, g, b = tonumber(rgb.r), tonumber(rgb.g), tonumber(rgb.b)

	if not r or not g or not b then
		return nil
	end

	return {
		r = math.floor(r + 0.5),
		g = math.floor(g + 0.5),
		b = math.floor(b + 0.5)
	}
end

-- The parts of a team this sync owns, in a form both the remote entry and
-- TeamTransfer.serialiseTeam(live) reduce to, so they can be compared.
local function statsSyncTeamSections(modules, team)
	local specs = modules.team.getSpecs().identity
	local identity = {}
	local remoteIdentity = type(team.identity) == "table" and team.identity or {}

	for _, spec in ipairs(specs.list) do
		if remoteIdentity[spec.name] ~= nil then
			identity[spec.name] = remoteIdentity[spec.name]
		end
	end

	for _, name in ipairs({
		"primaryRGBColour",
		"secondaryRGBColour",
		"hudTextRGBColour"
	}) do
		identity[name] = statsSyncColour(remoteIdentity[name])
	end

	local emblem = type(team.emblem) == "table" and team.emblem or {}

	return {
		identity = identity,
		icon = not emblem.customLogo and type(emblem.icon) == "string" and emblem.icon or nil,
		coachId = tonumber(team.coachId),
		uniformDefaults = type(team.uniformDefaults) == "table" and team.uniformDefaults or {},
		roster = type(team.roster) == "table" and team.roster or {},
		lineups = type(team.lineups) == "table" and team.lineups or {}
	}
end

local function statsSyncSame(modules, a, b)
	local encode = modules.player.encode

	return encode(a) == encode(b)
end

local function statsSyncPlayerExists(playerManager, id)
	return type(id) == "number" and statsSyncSafe(function()
		return playerManager:getPlayer(id)
	end) ~= nil
end

-- Players a team lists that this game doesn't have (e.g. from a mod that isn't
-- installed) can't be applied: they are dropped from the roster, and a lineup
-- slot holding one keeps its current player. Done before comparing, so such a
-- team isn't counted as changed. Returns the ids that were left out.
local function statsSyncKeepKnownPlayers(modules, wanted, current, playerManager)
	local missing, seen = {}, {}

	local function note(id)
		if type(id) == "number" and not seen[id] then
			seen[id] = true
			missing[#missing + 1] = id
		end
	end

	local roster = modules.player.jsonArray()

	for _, id in ipairs(wanted.roster) do
		if statsSyncPlayerExists(playerManager, id) then
			roster[#roster + 1] = id
		else
			note(id)
		end
	end

	wanted.roster = roster

	local currentByCategory = {}

	for _, entry in ipairs(current.lineups) do
		if type(entry) == "table" and entry.category and not currentByCategory[entry.category] then
			currentByCategory[entry.category] = entry
		end
	end

	local lineups = modules.player.jsonArray()

	for index, entry in ipairs(wanted.lineups) do
		if type(entry) == "table" and type(entry.players) == "table" then
			local copy = {}

			for key, value in pairs(entry) do
				copy[key] = value
			end

			local now = currentByCategory[entry.category]
			local players = modules.player.jsonArray()

			for slot, id in ipairs(entry.players) do
				if type(id) == "number" and not statsSyncPlayerExists(playerManager, id) then
					note(id)

					id = now and now.players and now.players[slot] or id
				end

				players[slot] = id
			end

			copy.players = players

			for key in pairs(StatsSyncSpecialRoles) do
				if type(copy[key]) == "number" and not statsSyncPlayerExists(playerManager, copy[key]) then
					note(copy[key])

					copy[key] = now and now[key] or nil
				end
			end

			lineups[index] = copy
		else
			lineups[index] = entry
		end
	end

	wanted.lineups = lineups

	return missing
end

-- Only the identity values the remote has are compared, so a field the
-- export didn't write never counts as a change.
local function statsSyncIdentityChanged(modules, wanted, live)
	for name, value in pairs(wanted) do
		if not statsSyncSame(modules, value, live[name]) then
			return true
		end
	end

	return false
end

local function statsSyncApplyIdentity(club, identity, wanted, liveIdentity, modules)
	local failed = {}

	for name, value in pairs(wanted) do
		if not statsSyncSame(modules, value, liveIdentity[name]) then
			local ok

			if name == "primaryRGBColour" then
				ok = pcall(function()
					identity:setPrimaryRGBFromTable(value)
				end)
			elseif name == "secondaryRGBColour" then
				ok = pcall(function()
					identity:setSecondaryRGBFromTable(value)
				end)
			elseif name == "hudTextRGBColour" then
				-- No setter is bound; the colour object may be a live reference.
				ok = pcall(function()
					local colour = identity.hudTextRGBColour

					colour.r, colour.g, colour.b = value.r, value.g, value.b
				end)
			else
				ok = pcall(function()
					identity:setOption(name, value)
				end)
			end

			if not ok then
				failed[#failed + 1] = name
			end
		end
	end

	return failed
end

local function statsSyncApplyLineups(club, lineups, playerManager)
	local problems = {}
	local count = tonumber(statsSyncSafe(function()
		return club:getLineupCount()
	end)) or 0

	for index, entry in ipairs(lineups) do
		local category = type(entry) == "table" and type(entry.category) == "string" and statsSyncSafe(function()
			return native.EClubLineupCategory[entry.category]
		end)
		local lineup

		if category ~= nil then
			-- Same position and category first (the export walks getLineup in
			-- order), else the club's lineup for that category.
			if index <= count then
				local candidate = statsSyncSafe(function()
					return club:getLineup(index)
				end)

				if candidate and statsSyncSafe(function()
					return candidate.category == category
				end) then
					lineup = candidate
				end
			end

			lineup = lineup or statsSyncSafe(function()
				return club:getLineupFromLineupCategory(category)
			end)
		end

		if not lineup then
			problems[#problems + 1] = "no " .. tostring(entry and entry.category) .. " lineup"
		else
			local size = tonumber(statsSyncSafe(function()
				return native.CClubLineup.getLineupSize(category)
			end)) or 0

			size = math.min(size, StatsSyncMaxLineupSlots, type(entry.players) == "table" and #entry.players or 0)

			for slot = 1, size do
				local id = entry.players[slot]

				if type(id) == "number" and statsSyncSafe(function()
					return playerManager:getPlayer(id)
				end) then
					lineup:replacePlayerAt(slot, id, false)
				end
			end

			for key, roleName in pairs(StatsSyncSpecialRoles) do
				local id = entry[key]
				local role = native.EClubLineupSpecialRole[roleName]

				if type(id) == "number" and role ~= nil and not pcall(function()
					lineup:setSpecialRole(role, id, false)
				end) then
					problems[#problems + 1] = entry.category .. " " .. key
				end
			end
		end
	end

	return problems
end

-- Returns "updated" | "unchanged" | "skipped" | "failed".
local function statsSyncApplyTeam(apply, team)
	if type(team) ~= "table" or team.baseGame ~= true or not statsSyncIsOfficialClub(team.id) then
		return "skipped"
	end

	local modules = apply.modules
	local clubManager = apply.clubManager
	local playerManager = apply.playerManager
	local live = clubManager:getClub(team.id)

	if not live then
		statsSyncLog("  team " .. tostring(team.id) .. ": not in this game")

		return "skipped"
	end

	local label = string.format("team %d (%s)", team.id, tostring(team.name))
	local wanted = statsSyncTeamSections(modules, team)
	local current = statsSyncTeamSections(modules, modules.team.serialiseTeam(live, {
		withKitOptions = false
	}))
	local missing = statsSyncKeepKnownPlayers(modules, wanted, current, playerManager)
	local changes = {
		identity = statsSyncIdentityChanged(modules, wanted.identity, current.identity),
		icon = wanted.icon ~= nil and wanted.icon ~= current.icon,
		coachId = wanted.coachId ~= nil and wanted.coachId ~= current.coachId,
		uniformDefaults = not statsSyncSame(modules, wanted.uniformDefaults, current.uniformDefaults),
		roster = not statsSyncSame(modules, wanted.roster, current.roster),
		lineups = not statsSyncSame(modules, wanted.lineups, current.lineups)
	}

	if not (changes.identity or changes.icon or changes.coachId or changes.uniformDefaults or changes.roster or changes.lineups) then
		return "unchanged"
	end

	local club = native.CClub()

	club:set(live)

	local problems = {}
	local identity = club.identity

	for _, id in ipairs(missing) do
		problems[#problems + 1] = "player " .. tostring(id) .. " (not in this game)"
	end

	if changes.identity then
		for _, name in ipairs(statsSyncApplyIdentity(club, identity, wanted.identity, current.identity, modules)) do
			problems[#problems + 1] = "identity." .. name
		end
	end

	if changes.icon and not pcall(function()
		club:setDecalIdOrIcon(native.CDecalIdOrIcon(native.EIconCategory.Clubs, wanted.icon))
	end) then
		problems[#problems + 1] = "badge " .. wanted.icon
	end

	if changes.coachId and not pcall(function()
		club:setCoachId(wanted.coachId)
	end) then
		problems[#problems + 1] = "coach"
	end

	if changes.uniformDefaults then
		local kits = tonumber(statsSyncSafe(function()
			return club.uniformCount
		end)) or 0

		for name, index in pairs(wanted.uniformDefaults) do
			local category = statsSyncSafe(function()
				return native.CClubUniformCategory[name]
			end)

			if category == nil or type(index) ~= "number" or index < 1 or index > kits or not pcall(function()
				club:setDefaultUniformIndex(category, index)
			end) then
				problems[#problems + 1] = "kit default " .. tostring(name)
			end
		end
	end

	if changes.roster then
		club:clearRoster()

		for _, id in ipairs(wanted.roster) do
			club:addPlayer(id)
		end
	end

	if changes.lineups or changes.roster then
		for _, problem in ipairs(statsSyncApplyLineups(club, wanted.lineups, playerManager)) do
			problems[#problems + 1] = problem
		end
	end

	pcall(function()
		clubManager:validateClub(club, playerManager)
	end)
	clubManager:saveCustomLicensed(club)

	local changed = {}

	for name, value in pairs(changes) do
		if value then
			changed[#changed + 1] = name
		end
	end

	table.sort(changed)
	statsSyncLog("  " .. label .. ": updated " .. table.concat(changed, ", ") .. (#problems > 0 and "; could not set " .. table.concat(problems, ", ") or ""))

	return "updated"
end

-- Driver ----------------------------------------------------------------------

local function statsSyncCanApply(engine, uiServices)
	local machine = uiServices.frontEndStateMachine
	local state = machine and machine:getCurrentState()

	if not state or state.__type ~= "HomeScreenState" then
		return false
	end

	if statsSyncSafe(function()
		return uiServices:profileSaveInProgress(engine)
	end) then
		return false
	end

	if uiServices:isAlertActive() then
		local params = uiServices:activeBlockingAlertParams()

		return params ~= nil and params.identifier == StatsSyncAlertId
	end

	return true
end

-- Loading screen: the busy layout (spinner + status line) drawn from
-- HomeScreenMixIn.renderAfterState above a blocking alert. The alert locks
-- input and is what shows if the busy layout can't be made; its text can't
-- change once open, the busy layout's status can.
local function statsSyncProgress(sync, status)
	if sync.busy and status ~= sync.busyStatus then
		sync.busyStatus = status

		pcall(sync.modules.busy.setStatus, sync.busy, status)
	end
end

local function statsSyncShowAlert(sync, engine, time, uiServices, text, status)
	uiServices:blockingAlert(engine, time, {
		canCancel = false,
		identifier = StatsSyncAlertId,
		title = StatsSyncLabels.alertTitle,
		text = text
	})

	if not sync.busy then
		local ok, area = pcall(sync.modules.busy.create, engine, StatsSyncLabels.alertTitle, status)

		if ok and area then
			sync.busy = area
			sync.busyStatus = status

			pcall(sync.modules.busy.playEnter, area, true)
		else
			statsSyncLog("loading screen unavailable: " .. tostring(area))
		end
	end

	statsSyncProgress(sync, status)
end

local function statsSyncCloseProgress(sync)
	if sync.busy then
		pcall(sync.busy.dispose, sync.busy)

		sync.busy = nil
	end
end

local function statsSyncShowApply(sync, engine, time, uiServices)
	local part = sync.queue[sync.applyIndex]
	local label = StatsSyncLabels[part.name]

	local items = sync.items[part.name]

	statsSyncShowAlert(sync, engine, time, uiServices, string.format(StatsSyncLabels.applying, label), string.format(StatsSyncLabels.progressApply, label, 0, items and #items or 0))
end

-- Shows the first part still downloading (the last one once all are done).
local function statsSyncDownloadStatus(sync)
	local part, progress

	for _, queued in ipairs(sync.queue or {}) do
		part, progress = queued, sync.progress and sync.progress[queued.name]

		if not progress or progress.done < #sync.info[queued.name].needed then
			break
		end
	end

	if not progress then
		return StatsSyncLabels.progressStart
	end

	local info = sync.info[part.name]

	return string.format(StatsSyncLabels.progressDownload, StatsSyncLabels[part.name], progress.done, #info.needed, progress.bytes / 1048576, info.bytes / 1048576)
end

-- "New data is available" with Download / Not now. Cancel (B) counts as Not now.
local function statsSyncAsk(sync, engine, time, uiServices)
	local lines = {
		sync.force and StatsSyncLabels.askIntroForce or StatsSyncLabels.askIntro,
		""
	}
	local bytes = 0

	for _, part in ipairs(sync.queue) do
		local info = sync.info[part.name]
		local date = type(info.exportedAt) == "string" and string.match(info.exportedAt, "^%d+%-%d+%-%d+") or "?"
		local label = #info.needed < info.parts and StatsSyncLabels.askPartSome or StatsSyncLabels.askPart

		lines[#lines + 1] = string.format(label, StatsSyncLabels[part.name .. "Title"], info.count, date)
		bytes = bytes + info.bytes
	end

	local size = bytes >= 1048576 and string.format("%.0f MB", bytes / 1048576) or string.format("%d KB", math.max(1, math.floor(bytes / 1024 + 0.5)))

	lines[#lines + 1] = ""
	lines[#lines + 1] = string.format(StatsSyncLabels.askFooter, size)

	sync.answer = nil

	local input = statsSyncSafe(function()
		return engine:getParty():getPrimaryPartyMember():getInput()
	end)

	uiServices:blockingAlert(engine, time, {
		identifier = StatsSyncAskAlertId,
		title = StatsSyncLabels.alertTitle,
		text = table.concat(lines, "\n"),
		yPos = 0.5,
		canCancel = true,
		input = input,
		options = {
			{
				val = true,
				label = StatsSyncLabels.askYes
			},
			{
				val = false,
				label = StatsSyncLabels.askNo
			}
		},
		onSelected = function(arg_engine, arg_time, result)
			sync.answer = type(result) == "table" and result.val == true
		end
	})
end

local function statsSyncCloseAlert(engine, uiServices)
	pcall(function()
		local params = uiServices:isAlertActive() and uiServices:activeBlockingAlertParams()

		if params and params.identifier == StatsSyncAlertId then
			uiServices:forcefullyCloseActiveAlert(engine, uiServices)
		end
	end)
end

local function statsSyncFinish(sync, engine, uiServices, reason)
	statsSyncCloseProgress(sync)
	statsSyncCloseAlert(engine, uiServices)

	if sync.needsRestart then
		-- Clubs changed: the match setup keeps copies of clubs loaded this
		-- session, and Play Now crashed in the session that rewrote every
		-- lineup (lobby_sideinfo: captain not in the cached squad); after a
		-- restart it was fine. So the player is asked to restart.
		local lines = {
			StatsSyncLabels.restart
		}

		for _, line in ipairs(sync.summary or {}) do
			lines[#lines + 1] = line
		end

		pcall(function()
			uiServices:blockingAlert(engine, sync.time, {
				identifier = StatsSyncDoneAlertId,
				title = StatsSyncLabels.done,
				text = table.concat(lines, "\n"),
				options = "ok",
				canCancel = true,
				input = statsSyncSafe(function()
					return engine:getParty():getPrimaryPartyMember():getInput()
				end)
			})
		end)
	elseif sync.summary and #sync.summary > 0 then
		pcall(function()
			uiServices:showNotification("alert", StatsSyncLabels.done, table.concat(sync.summary, "\n"))
		end)
	elseif sync.force and reason ~= "applied" and not string.find(tostring(reason), "declined", 1, true) then
		-- Asked for from Settings: say why nothing happened.
		pcall(function()
			uiServices:showNotification("alert", StatsSyncLabels.alertTitle, StatsSyncLabels.manualFailed)
		end)
	end

	for _, job in ipairs(sync.active or {}) do
		if job.task then
			pcall(job.task.dispose, job.task)

			job.task = nil
		end
	end

	sync.phase = "finished"
	sync.task = nil
	sync.active = nil
	sync.jobs = nil
	sync.apply = nil
	sync.items = nil

	if sync.modules and sync.modules.player then
		sync.modules.player.tier1AppearanceFields = nil
	end

	statsSyncLog("finished: " .. tostring(reason))
end

local function statsSyncBeginApply(sync, engine, uiServices, part)
	local modules = sync.modules
	local items = sync.items[part.name]

	sync.items[part.name] = nil

	if not items then
		return false
	end

	local apply = {
		part = part,
		modules = modules,
		items = items,
		index = 1,
		results = {
			updated = 0,
			unchanged = 0,
			skipped = 0,
			failed = 0
		}
	}

	if part.name == "players" then
		apply.context = modules.player.newImportContext(engine, uiServices)
		-- Only while this sync applies players (cleared when the part ends).
		modules.player.tier1AppearanceFields = StatsSyncTier1Appearance
	else
		apply.clubManager = uiServices:getClubManager()
		apply.playerManager = uiServices:getPlayerManager()
	end

	statsSyncLog(string.format("applying %s: %d entries (exported %s)", part.name, #apply.items, tostring(sync.info[part.name].exportedAt)))

	sync.apply = apply

	return true
end

local function statsSyncApplyBatch(sync, engine, uiServices)
	local apply = sync.apply
	local part = apply.part
	local results = apply.results
	local step = part.name == "players" and statsSyncApplyPlayer or statsSyncApplyTeam
	local batch = part.name == "players" and StatsSyncPlayerBatch or 1
	local done = 0

	while apply.index <= #apply.items and done < batch do
		local entry = apply.items[apply.index]
		local ok, result = xpcall(step, statsSyncTraceback, apply, entry)

		if not ok then
			statsSyncLog(string.format("  %s entry %d failed: %s", part.name, apply.index, tostring(result)))

			result = "failed"
		end

		results[result] = results[result] + 1
		apply.index = apply.index + 1
		done = done + 1
	end

	statsSyncProgress(sync, string.format(StatsSyncLabels.progressApply, StatsSyncLabels[part.name], apply.index - 1, #apply.items))

	if apply.index <= #apply.items then
		return false
	end

	statsSyncProgress(sync, StatsSyncLabels.progressSave)

	statsSyncLog(string.format("%s done: %d updated, %d unchanged, %d skipped, %d failed", part.name, results.updated, results.unchanged, results.skipped, results.failed))

	if results.updated > 0 then
		local partyMember = engine:getParty():getPrimaryPartyMember()

		uiServices:profileSaveFrontEndData(partyMember)

		if part.name == "teams" then
			sync.needsRestart = true
		end
	end

	local label = StatsSyncLabels[part.name]

	label = string.upper(string.sub(label, 1, 1)) .. string.sub(label, 2)
	sync.summary[#sync.summary + 1] = string.format(StatsSyncLabels.partDone, label, results.updated, results.unchanged)

	if results.failed > 0 then
		sync.summary[#sync.summary + 1] = string.format(StatsSyncLabels.partFailed, label, results.failed)
	end

	if part.name == "players" then
		apply.modules.player.tier1AppearanceFields = nil
	end

	-- Failed entries are logged; the version still counts as applied so a bad
	-- entry doesn't re-run the whole file on every launch.
	statsSyncRecordApplied(sync, part)
	statsSyncWriteState(sync.state)

	sync.apply = nil

	return true
end

local function statsSyncUpdate(sync, engine, time, dt, uiServices)
	local phase = sync.phase

	if phase == "version" then
		if not sync.task then
			sync.modules = statsSyncModules()

			if not sync.modules then
				return statsSyncFinish(sync, engine, uiServices, "player-import-export missing")
			end

			sync.elapsed = 0
			sync.task = statsSyncStartFetch(sync, engine, "version.json")

			return
		end

		local ok, response = statsSyncPoll(sync, dt)

		if ok == nil then
			return
		elseif not ok then
			return statsSyncFinish(sync, engine, uiServices, "version.json: " .. tostring(response))
		end

		local version, err = statsSyncDecode(sync.modules, response)

		if type(version) ~= "table" or version.format ~= StatsSyncVersionFormat then
			return statsSyncFinish(sync, engine, uiServices, "version.json is not valid: " .. tostring(err or version and version.format))
		end

		sync.state = statsSyncReadState()
		sync.remote = {}
		sync.info = {}
		sync.queue = {}

		-- Settings > Sync Player & Team Data (sync.force) repairs: everything
		-- is fetched and applied again, whatever was applied before.
		local applied = sync.force and {} or sync.state

		for _, part in ipairs(StatsSyncParts) do
			local entry = version[part.name]
			local sha = type(entry) == "table" and type(entry.sha256) == "string" and string.lower(entry.sha256)
			local count = sha and tonumber(entry.count)
			local parts = sha and tonumber(entry.parts)

			-- count is missing while the file is still the empty placeholder.
			-- A file without chunks is never fetched whole: one multi-megabyte
			-- response corrupts the game's native heap.
			if count and count > 0 then
				if not parts or parts < 1 then
					statsSyncLog(part.name .. ": version.json lists no chunks, skipped")
				else
					local info = {
						count = count,
						parts = parts,
						exportedAt = entry.exportedAt,
						chunks = {},
						needed = {},
						bytes = 0
					}

					sync.remote[part.name] = sha
					sync.info[part.name] = info

					-- Only chunks whose hash differs from the one last applied
					-- are downloaded (all of them without per-chunk hashes).
					local hashes = type(entry.chunks) == "table" and #entry.chunks == parts and entry.chunks
					local sizes = type(entry.chunkBytes) == "table" and entry.chunkBytes or {}

					for index = 0, parts - 1 do
						local chunkSha = hashes and type(hashes[index + 1]) == "string" and string.lower(hashes[index + 1])

						info.chunks[index + 1] = chunkSha or nil

						if not chunkSha or applied[string.format("%s/%03d", part.name, index)] ~= chunkSha then
							info.needed[#info.needed + 1] = index
							info.bytes = info.bytes + (tonumber(sizes[index + 1]) or 0)
						end
					end

					if not hashes then
						info.bytes = tonumber(entry.bytes) or 0
					end

					if applied[part.name] ~= sha then
						if #info.needed == 0 then
							-- Same records, new file hash (e.g. a fresh export date).
							statsSyncRecordApplied(sync, part)
							statsSyncWriteState(sync.state)
						else
							sync.queue[#sync.queue + 1] = part
						end
					elseif hashes and #info.needed > 0 then
						-- Applied before chunk hashes were kept: note them now
						-- so the next update only fetches what changed.
						statsSyncRecordApplied(sync, part)
						statsSyncWriteState(sync.state)
					end
				end
			end
		end

		if #sync.queue == 0 then
			return statsSyncFinish(sync, engine, uiServices, "already up to date")
		end

		sync.items = {}
		sync.summary = {}
		sync.failedFrom = nil
		sync.phase = "ask"
	elseif phase == "ask" then
		-- Nothing is downloaded until the player agrees.
		if statsSyncCanApply(engine, uiServices) and not uiServices:isAlertActive() then
			statsSyncAsk(sync, engine, time, uiServices)

			sync.phase = "asking"
		end
	elseif phase == "asking" then
		if sync.answer == nil then
			return
		elseif not sync.answer then
			return statsSyncFinish(sync, engine, uiServices, "declined (asks again next session)")
		end

		statsSyncLog("download accepted")
		statsSyncShowAlert(sync, engine, time, uiServices, StatsSyncLabels.downloading, statsSyncDownloadStatus(sync))

		sync.phase = "download"
	elseif phase == "download" then
		-- Every chunk of every queued part, fetched sync.parallel at a time.
		if not sync.jobs then
			sync.jobs = {}
			sync.active = {}
			sync.nextJob = 1
			sync.progress = {}

			for partIndex, part in ipairs(sync.queue) do
				sync.progress[part.name] = {
					done = 0,
					bytes = 0,
					chunks = {},
					started = os.clock()
				}

				for order, index in ipairs(sync.info[part.name].needed) do
					sync.jobs[#sync.jobs + 1] = {
						part = part,
						partIndex = partIndex,
						index = index,
						first = order == 1,
						tries = 0
					}
				end
			end
		end

		-- A failed part drops itself and every later one (teams name players).
		local function fail(job, reason)
			statsSyncLog(string.format("%s chunk %d of %d: %s", job.part.name, job.index + 1, sync.info[job.part.name].parts, tostring(reason)))

			if not sync.failedFrom or job.partIndex < sync.failedFrom then
				sync.failedFrom = job.partIndex
			end
		end

		local still = {}

		for _, job in ipairs(sync.active) do
			if sync.failedFrom and job.partIndex >= sync.failedFrom then
				if job.task then
					pcall(job.task.dispose, job.task)

					job.task = nil
				end
			elseif not job.task then
				-- A retry: fetched again from this frame.
				job.elapsed = 0
				job.task = statsSyncStartFetch(sync, engine, string.format("%s/%03d.json", job.part.name, job.index), true, "RevampStatsSync" .. job.part.name .. job.index)
				still[#still + 1] = job
			else
				local ok, response = statsSyncPoll(job, dt, true)
				local failure

				if ok then
					local data, err = statsSyncDecode(sync.modules, response)

					if type(data) ~= "table" or data.format ~= job.part.format or type(data[job.part.list]) ~= "table" then
						failure = "not a " .. job.part.format .. " chunk: " .. tostring(err or data and data.format)
					else
						local progress = sync.progress[job.part.name]

						progress.chunks[job.index + 1] = data[job.part.list]
						progress.done = progress.done + 1
						progress.bytes = progress.bytes + (type(response) == "string" and #response or 0)
					end
				elseif ok == false then
					failure = response
				end

				if ok == nil then
					still[#still + 1] = job
				elseif failure and job.tries < StatsSyncRetries then
					job.tries = job.tries + 1

					statsSyncLog(string.format("  %s chunk %d: %s, retrying", job.part.name, job.index + 1, tostring(failure)))

					still[#still + 1] = job
				elseif failure then
					fail(job, failure)
				end
			end
		end

		sync.active = still

		while #sync.active < sync.parallel and sync.nextJob <= #sync.jobs do
			local job = sync.jobs[sync.nextJob]

			sync.nextJob = sync.nextJob + 1

			if not (sync.failedFrom and job.partIndex >= sync.failedFrom) then
				if job.first then
					statsSyncLog(string.format("downloading %s: %d of %d chunks changed, %d at a time", job.part.name, #sync.info[job.part.name].needed, sync.info[job.part.name].parts, sync.parallel))
				end

				job.elapsed = 0
				job.task = statsSyncStartFetch(sync, engine, string.format("%s/%03d.json", job.part.name, job.index), not job.first, "RevampStatsSync" .. job.part.name .. job.index)
				sync.active[#sync.active + 1] = job
			end
		end

		statsSyncProgress(sync, statsSyncDownloadStatus(sync))

		if #sync.active > 0 or sync.nextJob <= #sync.jobs then
			return
		end

		-- Everything is in: join each part's chunks in order. Apply whatever
		-- fully downloaded before the first failed part.
		for partIndex, part in ipairs(sync.queue) do
			if sync.failedFrom and partIndex >= sync.failedFrom then
				break
			end

			local progress = sync.progress[part.name]
			local info = sync.info[part.name]
			local items = {}

			for _, index in ipairs(info.needed) do
				for _, entry in ipairs(progress.chunks[index + 1]) do
					items[#items + 1] = entry
				end
			end

			-- The total can only be checked when every chunk came down.
			if #info.needed == info.parts and #items ~= info.count then
				statsSyncLog(string.format("%s: got %d entries, version.json says %d", part.name, #items, info.count))

				sync.failedFrom = partIndex

				break
			end

			statsSyncLog(string.format("  downloaded %s: %d of %d chunks, %d bytes, %d entries in %.1fs", part.name, #info.needed, info.parts, progress.bytes, #items, os.clock() - progress.started))

			sync.items[part.name] = items
		end

		sync.progress = nil
		sync.jobs = nil
		sync.active = nil

		if sync.failedFrom then
			for index = #sync.queue, sync.failedFrom, -1 do
				table.remove(sync.queue, index)
			end

			if #sync.queue == 0 then
				return statsSyncFinish(sync, engine, uiServices, "download failed")
			end
		end

		sync.applyIndex = 1
		sync.phase = "wait"
	elseif phase == "wait" then
		-- Applied only on the home screen with nothing else up, so no editor
		-- has a player or club open.
		if statsSyncCanApply(engine, uiServices) then
			statsSyncShowApply(sync, engine, time, uiServices)

			sync.phase = "begin"
		end
	elseif phase == "begin" then
		-- One frame after the alert went up, so it is on screen while the
		-- large file is decoded.
		local part = sync.queue[sync.applyIndex]

		if statsSyncBeginApply(sync, engine, uiServices, part) then
			sync.phase = "apply"
		else
			sync.applyIndex = sync.applyIndex + 1
			sync.phase = sync.applyIndex <= #sync.queue and "begin" or "done"
		end
	elseif phase == "apply" then
		if statsSyncApplyBatch(sync, engine, uiServices) then
			sync.applyIndex = sync.applyIndex + 1

			if sync.applyIndex <= #sync.queue then
				statsSyncShowApply(sync, engine, time, uiServices)

				sync.phase = "begin"
			else
				sync.phase = "done"
			end
		end
	elseif phase == "done" then
		statsSyncFinish(sync, engine, uiServices, "applied")
	end
end

-- Called every front-end frame (HomeScreenMixIn.updateAfterState).
local function statsSyncTick(sync, engine, time, dt, uiServices)
	if not sync or sync.phase == "finished" then
		return
	end

	if sync.busy then
		pcall(sync.busy.update, sync.busy, dt)
	end

	sync.time = time

	local polls = 0
	local phase

	-- Phases that only move state along run again in the same frame.
	repeat
		phase = sync.phase

		local ok, err = xpcall(statsSyncUpdate, statsSyncTraceback, sync, engine, time, dt, uiServices)

		if not ok then
			statsSyncLog("error in phase " .. tostring(phase) .. ": " .. tostring(err))
			statsSyncFinish(sync, engine, uiServices, "error")

			return
		end

		polls = polls + 1
	until sync.phase == phase or sync.phase == "finished" or sync.phase == "begin" or polls >= StatsSyncPollLimit
end

-- Settings > Sync Player & Team Data ------------------------------------------
-- The row runs inside SettingsState (its sub-items are nextState classes).
-- This state asks the HomeScreenMixIn for a forced sync and ends at once;
-- SettingsState then goes back to the home screen, where the sync asks,
-- downloads and applies like the automatic one.
Class("RevampStatsSyncState")

function RevampStatsSyncState.enter(arg_ss_0, arg_ss_1, arg_ss_2, arg_ss_3, arg_ss_4, arg_ss_5, arg_ss_6)
	local ok, err = pcall(function()
		arg_ss_5:revampStatsSyncRequest()
	end)

	if not ok then
		statsSyncLog("manual sync request failed: " .. tostring(err))
	end
end

function RevampStatsSyncState.update(arg_ss_10, arg_ss_11, arg_ss_12, arg_ss_13, arg_ss_14, arg_ss_15, arg_ss_16, arg_ss_17, arg_ss_18)
	if not arg_ss_10.left then
		arg_ss_10.left = true

		arg_ss_11:changeState(nil, arg_ss_12, arg_ss_13, arg_ss_15, arg_ss_16, arg_ss_18)
	end
end

function RevampStatsSyncState.render()
	return
end

-- Adds the row to the shared Settings sub-menu. main-menu-revamp turns that
-- sub-menu into SettingsItem1..12 boxes on the Extra row (in place, once), so
-- when it already has, the row is added as the next SettingsItem box instead.
local function statsSyncAddSettingsRow()
	import("app.homescreen.homescreenstate_config")

	local tiles = homescreenstate_config.createFirstPageTiles()
	local extra = tiles and tiles.tilesRows and tiles.tilesRows.Extra

	if type(extra) ~= "table" then
		return "no Extra tile row"
	end

	local row = {
		revampStatsSyncRow = true,
		title = StatsSyncLabels.menuTitle,
		description = StatsSyncLabels.menuDescription,
		stateData = {
			nextState = RevampStatsSyncState
		}
	}

	for _, tile in ipairs(extra) do
		if tile.dataContextKey == "Settings" and type(tile.subMenu) == "table" then
			for _, item in ipairs(tile.subMenu) do
				if item.revampStatsSyncRow then
					return "already added"
				end
			end

			table.insert(tile.subMenu, row)

			return "added to the Settings sub-menu"
		end
	end

	local last, template = 0, nil

	for _, tile in ipairs(extra) do
		if tile.revampStatsSyncRow then
			return "already added"
		end

		local index = tonumber(string.match(tostring(tile.dataContextKey), "^SettingsItem(%d+)$"))

		if index and index > last then
			last, template = index, tile
		end
	end

	if not template then
		return "no Settings tile found"
	elseif last >= 12 then
		return "all 12 Settings slots are taken"
	end

	local key = "SettingsItem" .. (last + 1)

	table.insert(extra, {
		revampStatsSyncRow = true,
		dataContextKey = key,
		autoNavKey = key,
		customSound = template.customSound,
		title = row.title,
		description = row.description,
		stateFactory = template.stateFactory,
		stateData = row.stateData
	})

	return "added as " .. key
end

Class("HomeScreenMixIn")

function HomeScreenMixIn.enter(arg_2_0, arg_2_1, arg_2_2)
	arg_2_0.highlightTitle = nil
end

-- Settings > Sync Player & Team Data: a forced sync (everything re-fetched and
-- re-applied), once the home screen is back.
function HomeScreenMixIn.revampStatsSyncRequest(arg_rq_0)
	local current = arg_rq_0.revampStatsSync

	-- Taking over is fine until the automatic sync has asked the player.
	if current and current.phase ~= "finished" and current.phase ~= "version" and current.phase ~= "ask" then
		statsSyncLog("manual sync ignored: a sync is already running (" .. tostring(current.phase) .. ")")

		return false
	end

	if current and current.task then
		pcall(current.task.dispose, current.task)
	end

	local enabled, baseUrl, parallel = statsSyncConfig()

	arg_rq_0.revampStatsSync = {
		phase = "version",
		baseUrl = baseUrl,
		parallel = parallel,
		force = true
	}

	statsSyncLog("manual sync requested from Settings")

	return true
end

function HomeScreenMixIn.getHighlightTitle(arg_3_0)
	return arg_3_0.highlightTitle
end

function HomeScreenMixIn.setHighlightTitle(arg_4_0, arg_4_1)
	arg_4_0.highlightTitle = arg_4_1
end

function HomeScreenMixIn.getCurrentTabIndex(arg_5_0)
	return arg_5_0.tabIndex
end

function HomeScreenMixIn.setCurrentTabIndex(arg_6_0, arg_6_1)
	arg_6_0.tabIndex = arg_6_1
end

function HomeScreenMixIn.updateAfterState(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5)
	arg_7_0.homeScreenCalled = nil

	-- First front-end frame: the home screen config is loaded by now and its
	-- tiles haven't been built yet.
	if not arg_7_0.revampSettingsRow then
		local ok, result = pcall(statsSyncAddSettingsRow)

		arg_7_0.revampSettingsRow = true

		statsSyncLog("Settings row: " .. tostring(result))
	end

	statsSyncTick(arg_7_0.revampStatsSync, arg_7_1, arg_7_2, arg_7_3, arg_7_4)
end

-- The stats sync loading screen, drawn over the alert (AlertMixIn.RenderOrder
-- is 1000) and under the controller prompts (1001).
HomeScreenMixIn.RenderOrder = 1000.5

function HomeScreenMixIn.renderAfterState(arg_rs_0, arg_rs_1, arg_rs_2, arg_rs_3, arg_rs_4)
	local sync = arg_rs_0.revampStatsSync
	local busy = sync and sync.busy

	if busy and not pcall(busy.doRender, busy, arg_rs_1, arg_rs_4) then
		-- Stop drawing it; the blocking alert underneath still shows.
		sync.busy = nil
	end
end

function HomeScreenMixIn.getHighlightDynastyTitle(arg_8_0)
	return arg_8_0.highlightDynastyTitle
end

function HomeScreenMixIn.setHighlightDynastyTitle(arg_9_0, arg_9_1)
	arg_9_0.highlightDynastyTitle = arg_9_1
end

function HomeScreenMixIn.setHomescreenBanners(arg_10_0, arg_10_1)
	arg_10_0.homescreenBanners = arg_10_1
end

function HomeScreenMixIn.getHomescreenBanners(arg_11_0)
	return arg_11_0.homescreenBanners
end

function HomeScreenMixIn.setDynastyBanners(arg_12_0, arg_12_1)
	arg_12_0.dynastyBanners = arg_12_1
end

function HomeScreenMixIn.getDynastyBanners(arg_13_0)
	return arg_13_0.dynastyBanners
end

function HomeScreenMixIn.setDynastyStoreBanners(arg_14_0, arg_14_1)
	arg_14_0.dynastyStoreBanners = arg_14_1
end

function HomeScreenMixIn.getDynastyStoreBanners(arg_15_0)
	return arg_15_0.dynastyStoreBanners
end

function HomeScreenMixIn.getMenuBannersFromServer(arg_16_0, arg_16_1, arg_16_2, arg_16_3, arg_16_4)
	-- Home screen (and Pro Team hub) entry: start the stats sync once a session.
	if not arg_16_0.revampStatsSync then
		local enabled, baseUrl, parallel = statsSyncConfig()

		arg_16_0.revampStatsSync = {
			phase = enabled and "version" or "finished",
			baseUrl = baseUrl,
			parallel = parallel
		}

		statsSyncLog(enabled and "stats sync started" or "stats sync off (rl26_revamp.ini stats_sync = false)")
	end

	local var_16_0 = arg_16_2.buildCommsTask(arg_16_1, "GetMenuBanners")

	arg_16_2.addCommsTask(var_16_0, arg_16_4, function(arg_17_0, arg_17_1)
		if arg_17_1 then
			local var_17_0 = arg_16_1:getImageStore()
			local var_17_1 = arg_17_0:fillInfo()
			local var_17_2 = {}
			local var_17_3 = {}
			local var_17_4 = {}
			local var_17_5 = {}

			for iter_17_0, iter_17_1 in pairs(var_17_1.data) do
				local var_17_6 = native.CUuid.fromString(iter_17_1.image_uuid)

				table.insert(var_17_2, native.CUuidS3Pair(var_17_6, iter_17_1.image_url))

				if iter_17_1.screen == "homescreen" then
					table.insert(var_17_3, iter_17_1)
				elseif iter_17_1.screen == "proteam" then
					table.insert(var_17_4, iter_17_1)
				else
					table.insert(var_17_5, iter_17_1)
				end
			end

			var_17_0:preloadImagesWithS3(var_17_2, native.EImageType.MenuBanner)
			arg_16_2:setHomescreenBanners(var_17_3)
			arg_16_2:setDynastyBanners(var_17_4)
			arg_16_2:setDynastyStoreBanners(var_17_5)
		end
	end)
end

function HomeScreenMixIn.dispose(arg_18_0, arg_18_1)
	return
end

function HomeScreenMixIn.addConvenienceFunctionsToServices(arg_19_0, arg_19_1)
	function arg_19_1.homeScreenEnter(arg_20_0, arg_20_1, arg_20_2, arg_20_3, arg_20_4, arg_20_5, arg_20_6)
		assert(arg_20_5)
		assert(arg_20_6 ~= nil)

		local var_20_0 = assert(arg_20_4.frontEndStateMachine)
		local var_20_1 = var_20_0:getCurrentState()
		local var_20_2 = var_20_1 and (var_20_1.HighlightStateFactory or var_20_1.__proto) or nil
		local var_20_3

		arg_19_0.homeScreenCalled = true

		if var_20_1 and var_20_1.ExitStateFactory then
			var_20_0:changeState(var_20_1.ExitStateFactory(), arg_20_1, arg_20_2, arg_20_3, arg_20_4, arg_20_4.HomeScreenFactory, {
				arg_20_5,
				var_20_2,
				var_20_3,
				arg_20_6
			})
		else
			var_20_0:changeState(arg_20_4.HomeScreenFactory(), arg_20_1, arg_20_2, arg_20_3, arg_20_4, arg_20_5, var_20_2, var_20_3, arg_20_6)
		end
	end

	arg_19_1.homeScreenCheckForInput = falseFn

	function arg_19_1.getHighlightTitle(arg_21_0, ...)
		return arg_19_0:getHighlightTitle()
	end

	function arg_19_1.setHighlightTitle(arg_22_0, ...)
		return arg_19_0:setHighlightTitle(...)
	end

	function arg_19_1.getHighlightDynastyTitle(arg_23_0, ...)
		return arg_19_0:getHighlightDynastyTitle()
	end

	function arg_19_1.setHighlightDynastyTitle(arg_24_0, ...)
		return arg_19_0:setHighlightDynastyTitle(...)
	end

	function arg_19_1.getMenuBannersFromServer(arg_25_0, ...)
		return arg_19_0:getMenuBannersFromServer(...)
	end

	function arg_19_1.getHomescreenBanners(arg_26_0, ...)
		return arg_19_0:getHomescreenBanners()
	end

	function arg_19_1.setHomescreenBanners(arg_27_0, ...)
		return arg_19_0:setHomescreenBanners(...)
	end

	function arg_19_1.getDynastyBanners(arg_28_0, ...)
		return arg_19_0:getDynastyBanners()
	end

	function arg_19_1.setDynastyBanners(arg_29_0, ...)
		return arg_19_0:setDynastyBanners(...)
	end

	function arg_19_1.getDynastyStoreBanners(arg_30_0, ...)
		return arg_19_0:getDynastyStoreBanners()
	end

	function arg_19_1.setDynastyStoreBanners(arg_31_0, ...)
		return arg_19_0:setDynastyStoreBanners(...)
	end

	function arg_19_1.getCurrentTabIndex(arg_32_0, ...)
		return arg_19_0:getCurrentTabIndex()
	end

	function arg_19_1.setCurrentTabIndex(arg_33_0, ...)
		return arg_19_0:setCurrentTabIndex(...)
	end

	function arg_19_1.hasHomeScreenEnterBeenCalled(...)
		return arg_19_0.homeScreenCalled
	end

	function arg_19_1.revampStatsSyncRequest(arg_rq_10, ...)
		return arg_19_0:revampStatsSyncRequest(...)
	end
end
