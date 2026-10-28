#!/usr/bin/env python3
"""
Offline tests for revamp-stats-sync: runs the mod's app/homescreen/homescreen_mixin.lua
in LuaJIT on top of player-import-export's test harness (its stubbed player
manager, design tables and the real PlayerTransfer / TeamTransfer modules),
with CBasCommsTask stubbed to serve version.json / players.json / teams.json.
The sync is driven the way the game does it: getMenuBannersFromServer on home
screen entry, then updateAfterState every frame.

    python mods\\revamp-stats-sync\\tests\\run_tests.py

build.py skips *.py, so this file is never packed into the game.
"""

import importlib.util
import os
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
MODS = os.path.dirname(os.path.dirname(HERE))
SYNC_FILE = os.path.join(HERE, "..", "src", "script-game", "app", "homescreen", "homescreen_mixin.lua")
PIE_TESTS = os.path.join(MODS, "player-import-export", "tests", "run_tests.py")

SYNC_TESTS = r'''
-- revamp-stats-sync -------------------------------------------------------------

do
	local T = env.PlayerTransfer
	local TT = env.TeamTransfer

	local function enum(name, value)
		return setmetatable({ value = value }, {
			__tostring = function() return name end,
			__index = { toInt = function(self) return self.value end }
		})
	end
	local Home, Away, Nines = enum("Home", 0), enum("Away", 1), enum("Nines", 2)
	local League, NRL = enum("LeagueMatch", 0), enum("NRL2026Match", 1)
	native.CClubUniformCategory = { Count = 3, Home = Home, Away = Away, Nines = Nines,
		fromInt = function(_, i) return ({ [0] = Home, Away, Nines })[i] end }
	native.EClubLineupCategory = { LeagueMatch = League, NRL2026Match = NRL }
	native.CClubLineup = { getLineupSize = function(category) return category == NRL and 4 or 3 end }
	native.EClubLineupSpecialRole = { Captain = "C", GoalKicker = "K", PlayMaker = "P" }
	native.EIconCategory = { Clubs = "Clubs" }
	native.CDecalIdOrIcon = function(category, icon) return { icon = icon } end
	native.ETaskStatus = { success = "ok", failed = "bad" }
	native.getPlatformString = function() return "pc" end

	-- Clubs: readable by TeamTransfer.serialiseTeam, writable by the sync.
	local function newLineup(category, ids, roles)
		local l = { category = category, ids = {}, roles = {} }
		for i, id in ipairs(ids) do l.ids[i] = id end
		for k, v in pairs(roles or {}) do l.roles[k] = v end
		function l:getPlayerIdAt(i) return self.ids[i] end
		function l:getSpecialRole(role) return self.roles[role] end
		function l:replacePlayerAt(slot, id, carry)
			assert(slot >= 1 and slot <= 19, "slot out of range " .. tostring(slot))
			self.ids[slot] = id
		end
		function l:setSpecialRole(role, id, flag) self.roles[role] = id end
		return l
	end

	local function newClub(id, name, opts)
		opts = opts or {}
		local c = { id = id, academyId = id, fullName = name, uniformCount = 2, coachId = opts.coachId or 4 }
		local identity = config({ fullName = name, nickname = opts.nickname or "Nick", hudName = "NCK", supporters = 119, isWorldCup = false })
		identity.sex = native.CSex.Male
		identity.primaryRGBColour = { r = 0, g = 52, b = 93 }
		identity.secondaryRGBColour = { r = 255, g = 200, b = 0 }
		identity.hudTextRGBColour = { r = 255, g = 255, b = 255 }
		identity.decalIdOrIcon = { icon = opts.icon or "nrl_broncos" }
		identity.groundCount = 0
		function identity:getGround() end
		function identity:setPrimaryRGBFromTable(t) self.primaryRGBColour = { r = t.r, g = t.g, b = t.b } end
		function identity:setSecondaryRGBFromTable(t) self.secondaryRGBColour = { r = t.r, g = t.g, b = t.b } end
		c.identity = identity
		c.roster = {}
		for i, pid in ipairs(opts.roster or { 339, 341 }) do c.roster[i] = pid end
		c.lineups = {
			newLineup(League, opts.league or { 339, 341, 999 }, { C = 339 }),
			newLineup(NRL, opts.nrl or { 339, 341, 999, 998 }, { C = 339 })
		}
		c.defaults = { [Home] = 1, [Away] = 2 }
		local mt = { __index = function(self, key)
			if key == "playerCount" then return #rawget(self, "roster") end
		end }
		setmetatable(c, mt)
		function c:getUniform(i) return ({ { name = "HOME", isHidden = false }, { name = "AWAY", isHidden = false } })[i] end
		function c:getDefaultUniformIndex(cat) return self.defaults[cat] end
		function c:setDefaultUniformIndex(cat, i) self.defaults[cat] = i end
		function c:getPlayerIdAt(i) return self.roster[i] end
		function c:getLineupCount() return #self.lineups end
		function c:getLineup(i) return self.lineups[i] end
		function c:getLineupFromLineupCategory(cat)
			for _, l in ipairs(self.lineups) do if l.category == cat then return l end end
		end
		function c:clearRoster() self.roster = {} end
		function c:addPlayer(pid) self.roster[#self.roster + 1] = pid end
		function c:setCoachId(cid) self.coachId = cid end
		function c:setDecalIdOrIcon(d) self.identity.decalIdOrIcon = { icon = d.icon } end
		function c:set(other)
			self.id, self.academyId, self.fullName, self.coachId = other.id, other.academyId, other.fullName, other.coachId
			self.identity.values = copyTable(other.identity.values)
			for _, k in ipairs({ "primaryRGBColour", "secondaryRGBColour", "hudTextRGBColour", "decalIdOrIcon" }) do
				self.identity[k] = copyTable(other.identity[k])
			end
			self.roster = copyTable(other.roster)
			self.lineups = {}
			for i, l in ipairs(other.lineups) do self.lineups[i] = newLineup(l.category, l.ids, l.roles) end
			self.defaults = copyTable(other.defaults)
		end
		return c
	end
	native.CClub = function() return newClub(0, "") end
	native.CClubManager = { getIsOnDiscClub = function(id) return id < 1000 end }
	native.CClubDatabaseOnDisc = { getIsOfficialClubId = function(id) return id < 1000 end }

	-- Downloads ---------------------------------------------------------------
	-- failOnce[endpoint]: the next fetch of it fails. inFlight / maxInFlight
	-- count tasks not yet disposed.
	local served, fetches, failOnce, inFlight, maxInFlight = {}, {}, {}, 0, 0
	native.CBasCommsTask = function(userManager, http, cfg)
		assert(cfg.urlOverride == "https://raw.githubusercontent.com/galaxsistudios/rl26-revamped-stats/refs/heads/main/", cfg.urlOverride)
		assert(cfg.verb == "GET")
		fetches[#fetches + 1] = cfg.endpoint
		local body = served[cfg.endpoint]
		if failOnce[cfg.endpoint] then failOnce[cfg.endpoint], body = nil, nil end
		local frames = 0
		inFlight = inFlight + 1
		maxInFlight = math.max(maxInFlight, inFlight)
		return {
			update = function(self, dt) frames = frames + 1; return frames >= 2 end,
			getStatus = function() return body and native.ETaskStatus.success or native.ETaskStatus.failed end,
			getResponseBody = function() return body or "404: Not Found" end,
			getLastErrorCode = function() return body and 0 or 404 end,
			fillInfo = function() return {} end,
			dispose = function() inFlight = inFlight - 1 end
		}
	end

	-- Game state ---------------------------------------------------------------
	local disc341 = newPlayer(341, "Plain", "Player")
	local pm = newManager({ newPlayer(339, "Zac", "Lomax", { tier1 = true }), disc341, newPlayer(342, "New", "Signing") })
	local stock1 = newClub(1, "Brisbane Broncos")
	local cm = { clubs = { [1] = stock1, [2] = newClub(2, "Bulldogs") }, saved = {}, validated = 0 }
	function cm:getClub(id) return self.clubs[id] end
	function cm:saveCustomLicensed(c) self.clubs[c.id] = c; self.saved[#self.saved + 1] = c.id end
	function cm:validateClub() self.validated = self.validated + 1 end

	local alert, notifications, saves = nil, {}, 0
	-- The "new data" prompt is answered at once: Download unless declineNext.
	local asked, declineNext = 0, false
	local doneAlerts = {}
	local onHome = true
	local ui = {
		frontEndStateMachine = { getCurrentState = function() return onHome and { __type = "HomeScreenState" } or { __type = "AcademyState" } end },
		profileSaveInProgress = function() return false end,
		isAlertActive = function() return alert ~= nil end,
		activeBlockingAlertParams = function() return alert end,
		blockingAlert = function(self, engine, time, params)
			if params.identifier == "revampStatsSyncDone" then
				-- The restart message: OK is pressed at once.
				doneAlerts[#doneAlerts + 1] = params
				return
			end
			if params.identifier == "revampStatsSyncAsk" then
				asked = asked + 1
				assert(params.options and #params.options == 2 and (params.text:find("New RL26 Revamped data") or params.text:find("RL26 Revamped player and team data")), "bad prompt")
				params.onSelected(engine, time, params.options[declineNext and 2 or 1])
				return
			end
			alert = params
		end,
		forcefullyCloseActiveAlert = function() alert = nil end,
		showNotification = function(self, kind, title, body) notifications[#notifications + 1] = { title = title, body = body } end,
		getPlayerManager = function() return pm end,
		getClubManager = function() return cm end,
		profileSaveFrontEndData = function() saves = saves + 1 end,
		buildCommsTask = function() return {} end,
		addCommsTask = function() end
	}
	local engine = {
		getUserManager = function() return "users" end,
		getHttpRequestHandlerService = function() return "http" end,
		getParty = function() return { getPrimaryPartyMember = function() return { getInput = function() return "input" end } end } end
	}

	modules.player_viewstate_hub_state = { PlayerTransfer = T }
	modules.club_view_state = { TeamTransfer = TT }
	modules.homescreen_state = {}
	-- Loading screen stub: records every status line it shows.
	local busyLog, busyOpen, busyRenders = {}, 0, 0
	modules.busy_layout.create = function(engine, title, status)
		busyOpen = busyOpen + 1
		busyLog[#busyLog + 1] = status
		return {
			update = function() end,
			doRender = function() busyRenders = busyRenders + 1 end,
			dispose = function() busyOpen = busyOpen - 1 end
		}
	end
	modules.busy_layout.playEnter = function() end
	modules.busy_layout.setStatus = function(area, status) busyLog[#busyLog + 1] = status end
	falseFn = function() return false end
	env.falseFn = falseFn

	local chunk = assert(loadfile(arg[3]))
	setfenv(chunk, env)
	chunk()
	local Mixin = env.HomeScreenMixIn
	check("sync: mixin loads", Mixin ~= nil and Mixin.updateAfterState ~= nil)

	local function runSync(frames)
		local mixin = setmetatable({}, { __index = Mixin })
		Mixin.getMenuBannersFromServer(mixin, engine, ui, nil, {})
		for _ = 1, frames or 400 do
			Mixin.updateAfterState(mixin, engine, "time", 1 / 60, ui, nil)
			if mixin.revampStatsSync.phase == "finished" then break end
		end
		return mixin.revampStatsSync
	end

	-- Remote data: 341 gets a new tackle rating, 339 (tier-1) is unchanged,
	-- an Academy-made and an unknown "base" player are left alone.
	local function playerEntry(p, mutate)
		local e = T.serialisePlayer(p)
		if mutate then mutate(e) end
		return e
	end
	local players = T.jsonArray({
		playerEntry(pm:getPlayer(339)),
		playerEntry(disc341, function(e) e.skills.tackle = 90 end),
		playerEntry(newPlayer(20001, "Made", "Up"), function(e) e.baseGame = false end),
		playerEntry(newPlayer(555, "Nobody", "Here"), function(e) e.baseGame = true end)
	})
	local remoteTeam = TT.serialiseTeam(newClub(1, "Brisbane Broncos", {
		nickname = "Brissy", coachId = 7, icon = "nrl_broncos_alt",
		roster = { 341, 339, 342, 777 }, league = { 341, 339, 342 }, nrl = { 342, 341, 339, 999 }
	}), { withKitOptions = false })
	remoteTeam.identity.primaryRGBColour = { r = 1, g = 2, b = 3 }
	remoteTeam.lineups[1].captain = 341
	remoteTeam.uniformDefaults.Away = 1
	local teams = T.jsonArray({
		remoteTeam,
		TT.serialiseTeam(cm.clubs[2], { withKitOptions = false }),
		{ id = 1500, name = "Academy FC", baseGame = false, sex = "Male" }
	})
	-- Served the way tools/stats_sync.py writes them: two chunks per part.
	local function serveChunks(name, format, list, split)
		local chunks = { T.jsonArray(), T.jsonArray() }
		for i, entry in ipairs(list) do table.insert(chunks[i <= split and 1 or 2], entry) end
		for i, chunk in ipairs(chunks) do
			served[string.format("%s/%03d.json", name, i - 1)] = T.encode({ format = format, version = 1, part = i - 1, parts = 2, [name] = chunk })
		end
	end
	serveChunks("players", "RL26PlayersExport", players, 2)
	serveChunks("teams", "RL26TeamsExport", teams, 2)
	local function serveVersion(playersSha, teamsSha, playerParts)
		served["version.json"] = T.encode({ format = "RL26RevampStatsVersion", version = 1,
			players = { sha256 = playersSha, count = 4, parts = playerParts or 2, exportedAt = "x" },
			teams = { sha256 = teamsSha, count = 3, parts = 2, exportedAt = "y" } })
	end
	serveVersion("aa11", "bb22")
	os.remove("rl26revamp_stats_state.txt")

	-- First run: everything applies.
	local sync = runSync()
	check("sync: finished", sync.phase == "finished", sync.phase)
	check("sync: fetched version, then chunks", table.concat(fetches, ",") == "version.json,players/000.json,players/001.json,teams/000.json,teams/001.json", table.concat(fetches, ","))
	local busyText = table.concat(busyLog, "|")
	check("sync: asked once before downloading", asked == 1, asked)
	check("sync: loading screen shows download progress", busyText:find("Downloading players: 0 of 2", 1, true) and busyText:find("Downloading teams: 2 of 2", 1, true), busyText)
	check("sync: loading screen shows apply progress", busyText:find("Updating players: 4 of 4", 1, true) and busyText:find("Updating teams: 3 of 3", 1, true) and busyText:find("Saving...", 1, true), busyText)
	check("sync: loading screen closed", busyOpen == 0)
	check("sync: chunks downloaded in parallel", maxInFlight == 4 and inFlight == 0, maxInFlight .. "/" .. inFlight)
	local p341 = pm:getPlayer(341)
	check("sync: base player updated", p341.skills.values.tackle == 90, p341.skills.values.tackle)
	check("sync: no player added", pm.nextId == 20000)
	local club = cm.clubs[1]
	check("sync: club saved once", #cm.saved == 1 and cm.saved[1] == 1, table.concat(cm.saved, ","))
	check("sync: identity", club.identity.values.nickname == "Brissy")
	check("sync: colour", club.identity.primaryRGBColour.r == 1 and club.identity.primaryRGBColour.b == 3)
	check("sync: badge and coach", club.identity.decalIdOrIcon.icon == "nrl_broncos_alt" and club.coachId == 7)
	check("sync: kit default", club.defaults[Away] == 1 and club.defaults[Home] == 1)
	check("sync: roster drops unknown player", table.concat(club.roster, ",") == "341,339,342", table.concat(club.roster, ","))
	check("sync: league lineup + captain", table.concat(club.lineups[1].ids, ",") == "341,339,342" and club.lineups[1].roles.C == 341)
	check("sync: nrl lineup keeps slot of unknown player", table.concat(club.lineups[2].ids, ",") == "342,341,339,998", table.concat(club.lineups[2].ids, ","))
	check("sync: stock club object untouched", stock1.identity.values.nickname == "Nick" and stock1.roster[1] == 339)
	check("sync: unchanged club not saved", cm.clubs[2].fullName == "Bulldogs")
	check("sync: saved profile per part", saves == 2, saves)
	check("sync: alert closed", alert == nil)
	local done = doneAlerts[1]
	check("sync: clubs changed -> restart message with summary", #doneAlerts == 1 and #notifications == 0 and done.options == "ok" and done.text:find("restart the game", 1, true) and done.text:find("Players: 1 updated, 1 already up to date", 1, true) and done.text:find("Teams: 1 updated, 1 already up to date", 1, true), done and done.text)
	local stateFile = io.open("rl26revamp_stats_state.txt"):read("*a")
	check("sync: state written", stateFile:find("players=aa11") and stateFile:find("teams=bb22"), stateFile)

	-- Same version again: nothing downloaded.
	fetches, cm.saved, saves, notifications = {}, {}, 0, {}
	sync = runSync()
	check("sync: up to date skips downloads", table.concat(fetches, ",") == "version.json" and #cm.saved == 0 and saves == 0 and #notifications == 0, table.concat(fetches, ","))

	-- Only teams changed: players.json is not downloaded; re-applying the same
	-- teams finds nothing to change.
	serveVersion("aa11", "cc33")
	fetches = {}
	sync = runSync()
	check("sync: only changed part downloaded", table.concat(fetches, ",") == "version.json,teams/000.json,teams/001.json", table.concat(fetches, ","))
	check("sync: reapply is a no-op", #cm.saved == 0 and saves == 0)

	-- Waits for the home screen before applying.
	serveVersion("dd44", "cc33")
	fetches, onHome = {}, false
	local mixin = setmetatable({}, { __index = Mixin })
	Mixin.getMenuBannersFromServer(mixin, engine, ui, nil, {})
	for _ = 1, 50 do Mixin.updateAfterState(mixin, engine, "time", 1 / 60, ui, nil) end
	check("sync: asks only on the home screen", mixin.revampStatsSync.phase == "ask" and alert == nil and #fetches == 1, mixin.revampStatsSync.phase)
	onHome = true
	for _ = 1, 50 do Mixin.updateAfterState(mixin, engine, "time", 1 / 60, ui, nil) end
	check("sync: applies once home", mixin.revampStatsSync.phase == "finished")
	check("sync: player-only update just notifies", #doneAlerts == 1 and #notifications >= 1, #doneAlerts)
	check("sync: once per session", (function()
		local before = #fetches
		Mixin.getMenuBannersFromServer(mixin, engine, ui, nil, {})
		Mixin.updateAfterState(mixin, engine, "time", 1 / 60, ui, nil)
		return #fetches == before
	end)())

	-- A version without chunk counts is skipped, never fetched whole.
	serveVersion("ff66", "cc33", 0)
	fetches = {}
	sync = runSync()
	check("sync: no chunks, no download", table.concat(fetches, ",") == "version.json", table.concat(fetches, ","))

	-- A chunk that fails once is fetched again.
	serveVersion("ab99", "cc33")
	failOnce["players/001.json"] = true
	fetches, saves = {}, 0
	sync = runSync()
	check("sync: failed chunk retried", table.concat(fetches, ",") == "version.json,players/000.json,players/001.json,players/001.json" and io.open("rl26revamp_stats_state.txt"):read("*a"):find("players=ab99") ~= nil, table.concat(fetches, ","))

	-- Download failure (second chunk missing): logged, nothing applied, state kept.
	serveVersion("ee55", "cc33")
	local chunk2 = served["players/001.json"]
	served["players/001.json"] = nil
	fetches, cm.saved, saves = {}, {}, 0
	sync = runSync()
	check("sync: failed download finishes cleanly", sync.phase == "finished" and saves == 0 and alert == nil)
	stateFile = io.open("rl26revamp_stats_state.txt"):read("*a")
	check("sync: failed part not recorded", stateFile:find("players=ab99") ~= nil, stateFile)

	-- Entry count must match version.json.
	served["players/001.json"] = chunk2
	served["version.json"] = served["version.json"]:gsub('"count": 4', '"count": 5')
	fetches, saves = {}, 0
	sync = runSync()
	check("sync: count mismatch rejected", saves == 0 and sync.phase == "finished")

	-- Not now: nothing downloaded, nothing recorded, asked again next session.
	served["version.json"] = served["version.json"]:gsub('"count": 5', '"count": 4')
	serveVersion("ab12", "cc33")
	fetches, saves, declineNext, asked = {}, 0, true, 0
	sync = runSync()
	check("sync: declined downloads nothing", sync.phase == "finished" and asked == 1 and table.concat(fetches, ",") == "version.json" and saves == 0, table.concat(fetches, ","))
	check("sync: declined version not recorded", not io.open("rl26revamp_stats_state.txt"):read("*a"):find("ab12"))
	declineNext = false

	-- The loading screen is drawn from renderAfterState while it is open.
	busyRenders = 0
	do
		local m = setmetatable({}, { __index = Mixin })
		Mixin.getMenuBannersFromServer(m, engine, ui, nil, {})
		local drew = false
		for _ = 1, 400 do
			Mixin.updateAfterState(m, engine, "time", 1 / 60, ui, nil)
			Mixin.renderAfterState(m, engine, "time", ui, nil)
			if m.revampStatsSync.busy then drew = busyRenders > 0 end
			if m.revampStatsSync.phase == "finished" then break end
		end
		check("sync: loading screen rendered", drew and Mixin.RenderOrder > 1000 and Mixin.RenderOrder < 1001)
	end

	-- Per-chunk hashes: only changed chunks are downloaded.
	do
		local function serveHashed(playersSha, playerChunks, teamsSha, teamChunks)
			served["version.json"] = T.encode({ format = "RL26RevampStatsVersion", version = 1,
				players = { sha256 = playersSha, count = 4, parts = 2, exportedAt = "x", chunks = T.jsonArray(playerChunks), chunkBytes = T.jsonArray({ 1000, 2000 }) },
				teams = { sha256 = teamsSha, count = 3, parts = 2, exportedAt = "y", chunks = T.jsonArray(teamChunks), chunkBytes = T.jsonArray({ 300, 400 }) } })
		end
		os.remove("rl26revamp_stats_state.txt")
		serveHashed("f1", { "a0", "a1" }, "e1", { "b0", "b1" })
		fetches, asked = {}, 0
		local s = runSync()
		check("delta: first run fetches every chunk", table.concat(fetches, ",") == "version.json,players/000.json,players/001.json,teams/000.json,teams/001.json", table.concat(fetches, ","))
		local st = io.open("rl26revamp_stats_state.txt"):read("*a")
		check("delta: chunk hashes recorded", st:find("players/000=a0", 1, true) and st:find("players/001=a1", 1, true) and st:find("teams/001=b1", 1, true), st)

		-- One players chunk changed, teams untouched.
		serveHashed("f2", { "a0", "c1" }, "e1", { "b0", "b1" })
		fetches, asked = {}, 0
		local promptText
		local realAlert = ui.blockingAlert
		ui.blockingAlert = function(self, engine, time, params)
			if params.identifier == "revampStatsSyncAsk" then promptText = params.text end
			return realAlert(self, engine, time, params)
		end
		s = runSync()
		ui.blockingAlert = realAlert
		check("delta: only the changed chunk is fetched", table.concat(fetches, ",") == "version.json,players/001.json", table.concat(fetches, ","))
		check("delta: prompt shows the small size", promptText and promptText:find("2 KB", 1, true) and promptText:find("changes among 4", 1, true), promptText)
		st = io.open("rl26revamp_stats_state.txt"):read("*a")
		check("delta: state updated", st:find("players=f2", 1, true) and st:find("players/001=c1", 1, true) and st:find("players/000=a0", 1, true), st)

		-- New file hash but identical chunks: nothing to download or ask.
		serveHashed("f3", { "a0", "c1" }, "e1", { "b0", "b1" })
		fetches, asked = {}, 0
		s = runSync()
		check("delta: same chunks, no download", table.concat(fetches, ",") == "version.json" and asked == 0, table.concat(fetches, ","))
		check("delta: new file hash noted", io.open("rl26revamp_stats_state.txt"):read("*a"):find("players=f3", 1, true))

		-- A state written before chunk hashes existed gets them filled in.
		local f = io.open("rl26revamp_stats_state.txt", "w"); f:write("players=f3\nteams=e1\n"); f:close()
		fetches, asked = {}, 0
		s = runSync()
		st = io.open("rl26revamp_stats_state.txt"):read("*a")
		check("delta: old state upgraded without download", table.concat(fetches, ",") == "version.json" and st:find("players/001=c1", 1, true) and st:find("teams/000=b0", 1, true), st)
	end

	-- Tier-1 (scanned) players: hair and headgear are applied, the rest of
	-- the look is not.
	do
		local saved = { v = served["version.json"], a = served["players/000.json"], b = served["players/001.json"] }
		local p339 = pm:getPlayer(339)
		local beforeNose = p339.visual.values.nose_height
		local entry = T.serialisePlayer(p339)
		entry.appearance.hairTop = 44
		entry.appearance.nose_height = 0.9
		serveChunks("players", "RL26PlayersExport", T.jsonArray({ entry }), 1)
		served["version.json"] = T.encode({ format = "RL26RevampStatsVersion", version = 1,
			players = { sha256 = "abc1", count = 1, parts = 2, exportedAt = "z" } })
		fetches, asked = {}, 0
		local s = runSync()
		local now = pm:getPlayer(339)
		check("tier1: hair applied", s.phase == "finished" and now.visual.values.hairTop == 44, now.visual.values.hairTop)
		check("tier1: rest of the look untouched", now.visual.values.nose_height == beforeNose, now.visual.values.nose_height)
		check("tier1: field list switched off afterwards", T.tier1AppearanceFields == nil)
		served["version.json"], served["players/000.json"], served["players/001.json"] = saved.v, saved.a, saved.b
	end

	-- Settings > Sync Player & Team Data.
	do
		-- The row: added to the Settings sub-menu, or as the next SettingsItem box
		-- once main-menu-revamp has turned the sub-menu into boxes. Only once.
		local settingsTile = { dataContextKey = "Settings", subMenu = { { title = "General" }, { title = "Audio" } } }
		local sharedTiles = { tilesRows = { Extra = { settingsTile } } }
		modules.homescreenstate_config = { createFirstPageTiles = function() return sharedTiles end }
		local m = setmetatable({}, { __index = Mixin })
		Mixin.updateAfterState(m, engine, "time", 1 / 60, ui, nil)
		Mixin.updateAfterState(m, engine, "time", 1 / 60, ui, nil)
		setmetatable({}, { __index = Mixin }).updateAfterState(setmetatable({}, { __index = Mixin }), engine, "time", 1 / 60, ui, nil)
		local added = settingsTile.subMenu[3]
		check("settings: row added to the sub-menu once", #settingsTile.subMenu == 3 and added.title == "Sync Player & Team Data" and added.stateData.nextState == env.RevampStatsSyncState, #settingsTile.subMenu)

		local boxes = { tilesRows = { Extra = {
			{ dataContextKey = "Practice" },
			{ dataContextKey = "SettingsItem1", stateFactory = "SettingsStateFactory", customSound = "snd" },
			{ dataContextKey = "SettingsItem2", stateFactory = "SettingsStateFactory" }
		} } }
		modules.homescreenstate_config = { createFirstPageTiles = function() return boxes end }
		for _ = 1, 2 do
			Mixin.updateAfterState(setmetatable({}, { __index = Mixin }), engine, "time", 1 / 60, ui, nil)
		end
		local box = boxes.tilesRows.Extra[4]
		check("settings: row added as the next box once", #boxes.tilesRows.Extra == 4 and box.dataContextKey == "SettingsItem3" and box.autoNavKey == "SettingsItem3" and box.stateFactory == "SettingsStateFactory" and box.stateData.nextState == env.RevampStatsSyncState, #boxes.tilesRows.Extra)

		-- Choosing it: the state asks for a forced sync and leaves at once.
		local home = setmetatable({}, { __index = Mixin })
		Mixin.getMenuBannersFromServer(home, engine, ui, nil, {})
		for _ = 1, 50 do Mixin.updateAfterState(home, engine, "time", 1 / 60, ui, nil) end
		check("settings: automatic sync found nothing to do", home.revampStatsSync.phase == "finished")
		ui.revampStatsSyncRequest = function() return Mixin.revampStatsSyncRequest(home) end
		local left
		local sm = { changeState = function(self, nextState) left = nextState == nil end }
		local state = setmetatable({}, { __index = env.RevampStatsSyncState })
		state:enter(sm, engine, "time", nil, ui, {})
		state:update(sm, engine, "time", 1 / 60, nil, ui, nil, {})
		check("settings: state requests and leaves", left == true and home.revampStatsSync.force == true)
		fetches, asked = {}, 0
		local promptText
		local realAlert = ui.blockingAlert
		ui.blockingAlert = function(self, e, t, params)
			if params.identifier == "revampStatsSyncAsk" then promptText = params.text end
			return realAlert(self, e, t, params)
		end
		for _ = 1, 400 do
			Mixin.updateAfterState(home, engine, "time", 1 / 60, ui, nil)
			if home.revampStatsSync.phase == "finished" then break end
		end
		ui.blockingAlert = realAlert
		check("settings: forced sync re-fetches everything", #fetches == 5 and fetches[1] == "version.json" and asked == 1, table.concat(fetches, ","))
		check("settings: repair wording", promptText and promptText:find("again and re-apply", 1, true), promptText)

		-- Offline: a notification says why nothing happened.
		local savedVersion = served["version.json"]
		served["version.json"] = nil
		notifications = {}
		Mixin.revampStatsSyncRequest(home)
		for _ = 1, 50 do Mixin.updateAfterState(home, engine, "time", 1 / 60, ui, nil) end
		check("settings: failure is reported", #notifications == 1 and notifications[1].body:find("internet", 1, true), #notifications)
		served["version.json"] = savedVersion
		ui.revampStatsSyncRequest = nil
	end

	-- Disabled in rl26_revamp.ini.
	local ini = io.open("rl26_revamp.ini", "w"); ini:write("skip_intro = false\nstats_sync = false\n"); ini:close()
	fetches = {}
	sync = runSync()
	check("sync: ini switch", sync.phase == "finished" and #fetches == 0)
	os.remove("rl26_revamp.ini")

	-- The log is written.
	local log = io.open("revampstats_debug.txt")
	check("sync: debug log", log ~= nil and log:read("*a"):find("players done: 1 updated") ~= nil)
	if log then log:close() end
end
'''


def load_pie():
    spec = importlib.util.spec_from_file_location("pie_tests", PIE_TESTS)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def main():
    pie = load_pie()
    marker = 'print(string.format("%d passed, %d failed", passes, failures))'
    if marker not in pie.HARNESS:
        print("player-import-export harness changed: summary line not found")
        return 1
    head, tail = pie.HARNESS.split(marker, 1)
    harness_text = head + SYNC_TESTS + marker + tail

    tmp = tempfile.mkdtemp()
    result = subprocess.run([pie.LUAJIT, "-b", os.path.abspath(SYNC_FILE), os.path.join(tmp, "check.out")],
                            cwd=pie.LUAJIT_CWD, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"compile failed: {SYNC_FILE}\n{result.stderr}")
        return 1
    with tempfile.TemporaryDirectory() as work:
        harness = os.path.join(work, "harness.lua")
        with open(harness, "w", encoding="utf-8", newline="\n") as f:
            f.write(harness_text)
        # cwd = work: the mod writes its state file and log to the current folder.
        result = subprocess.run([pie.LUAJIT, harness, os.path.abspath(pie.MOD_FILE), os.path.abspath(pie.CLUB_FILE),
                                 os.path.abspath(SYNC_FILE)], capture_output=True, text=True, cwd=work)
        sys.stdout.write(result.stdout)
        sys.stderr.write(result.stderr)
        if result.returncode != 0 and os.path.exists(os.path.join(work, "revampstats_debug.txt")):
            print("--- revampstats_debug.txt ---")
            print(open(os.path.join(work, "revampstats_debug.txt"), encoding="utf-8").read())
        return result.returncode


if __name__ == "__main__":
    sys.exit(main())
