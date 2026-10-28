#!/usr/bin/env python3
"""
Offline tests for player-import-export: loads the mod's
app/player/player_viewstate_hub_state.lua in LuaJIT with stubbed game objects
(player manager, CDataConfig getOption/setOption, design tables) and checks
the JSON codec, validation, matching and the import/export paths.

    python mods\\player-import-export\\tests\\run_tests.py

build.py skips *.py, so this file is never packed into the game.
"""

import os
import subprocess
import sys
import tempfile

LUAJIT = r"D:\galaxsi\projects\games\modding\toolchain\luajit\bin\luajit.exe"
LUAJIT_CWD = os.path.dirname(LUAJIT)  # luajit -b finds its jit.* modules from its own dir (as in tools/build.py)
HERE = os.path.dirname(os.path.abspath(__file__))
MOD_FILE = os.path.join(HERE, "..", "src", "script-game", "app", "player", "player_viewstate_hub_state.lua")
HOME_FILE = os.path.join(HERE, "..", "src", "script-game", "app", "noesis", "homescreen", "nvm_homescreen.lua")
CLUB_FILE = os.path.join(HERE, "..", "src", "script-game", "app", "club", "club_view_state.lua")

HARNESS = r'''
local modPath = arg[1]
local failures, passes = 0, 0

local function check(name, cond, detail)
	if cond then
		passes = passes + 1
	else
		failures = failures + 1
		print("FAIL: " .. name .. (detail and (" -- " .. tostring(detail)) or ""))
	end
end

-- Stubs ----------------------------------------------------------------------

local function config(values, reject)
	return {
		values = values or {},
		reject = reject or {},
		getOption = function(self, name) return self.values[name] end,
		setOption = function(self, name, value)
			if self.reject[name] then error("rejected " .. name) end
			self.values[name] = value
		end
	}
end

local function copyTable(t)
	local out = {}
	for k, v in pairs(t) do out[k] = v end
	return out
end

local function newPlayer(id, first, surname, opts)
	opts = opts or {}
	local p = {
		id = id,
		isTier1 = opts.tier1 or false,
		isLicensed = opts.licensed or false,
		sharing = { readOnly = opts.readOnly or false },
		identity = config({
			firstname = first, surname = surname, birthDay = opts.day or 1, birthMonth = opts.month or 2,
			birthYear = opts.year or 1999, shirtNumber = 7, rightHanded = true, commentaryNameHash = 3000000000,
			preferredRolePrimary = 3
		}),
		attributes = config({ height = 180, weight = 90, perk = 0, agility = 70, strength = 80 }),
		skills = config({ tackle = 75, basicPass = 60 }),
		visual = config({ height = 0.5, weight = 0.25, fitness = 0.75, head = 1068, hairTop = 12, nose_height = 0.1234 }),
		heightWeightCalls = 0
	}
	p.identity.sex = opts.sex or native.CSex.Male
	p.fullName = first .. " " .. surname
	function p:getOverallForPrimaryRole() return 84.6 end
	function p:heightWeight_SetAttributesFromVisual() self.heightWeightCalls = self.heightWeightCalls + 1 end
	return p
end

local function clonePlayer(src, id)
	local p = newPlayer(id or src.id, src.identity.values.firstname, src.identity.values.surname,
		{ tier1 = src.isTier1, licensed = src.isLicensed, sex = src.identity.sex })
	p.identity.values = copyTable(src.identity.values)
	p.attributes.values = copyTable(src.attributes.values)
	p.skills.values = copyTable(src.skills.values)
	p.visual.values = copyTable(src.visual.values)
	return p
end

local function iterList(list)
	local i = 0
	return function()
		i = i + 1
		if list[i] then return i, list[i] end
	end
end

local function newManager(discPlayers, userPlayers, capacity)
	local pm = { disc = {}, discList = {}, user = {}, userList = {}, custom = {}, nextId = 20000,
		capacity = capacity or 10, savedCustom = {}, editOrCreateCalls = 0 }
	for _, p in ipairs(discPlayers or {}) do pm.disc[p.id] = p; table.insert(pm.discList, p) end
	local function rebuildUserList()
		pm.userList = {}
		for _, p in pairs(pm.user) do table.insert(pm.userList, p) end
		table.sort(pm.userList, function(a, b) return a.id < b.id end)
	end
	for _, p in ipairs(userPlayers or {}) do pm.user[p.id] = p end
	rebuildUserList()
	pm.onDisc = {
		getPlayer = function(_, id) return pm.disc[id] end,
		iterateAll = function() return iterList(pm.discList) end,
		getIdFromName = function(_, first, surname)
			for _, p in ipairs(pm.discList) do
				if p.identity.values.firstname == first and p.identity.values.surname == surname then return p.id end
			end
		end
	}
	local uc = {
		getPlayer = function(_, id) return pm.user[id] end,
		containsPlayer = function(_, id) return pm.user[id] ~= nil end,
		editPlayer = function(_, id)
			if not pm.user[id] then
				local base = pm.custom[id] or pm.disc[id]
				pm.user[id] = clonePlayer(base)
				rebuildUserList()
			end
			return pm.user[id]
		end,
		addPlayer = function(_, p)
			local id = pm.nextId
			pm.nextId = pm.nextId + 1
			pm.user[id] = clonePlayer(p, id)
			rebuildUserList()
			return id
		end,
		deletePlayer = function(_, id) pm.user[id] = nil; rebuildUserList() end,
		iterateAll = function() return iterList(pm.userList) end
	}
	pm.userCreated = setmetatable(uc, { __index = function(_, key)
		if key == "canCreateCount" then
			local n = 0
			for _ in pairs(pm.user) do n = n + 1 end
			return pm.capacity - n
		end
	end })
	function pm:getPlayer(id) return self.user[id] or self.custom[id] or self.disc[id] end
	function pm:saveCustomLicensed(p) self.custom[p.id] = p; table.insert(self.savedCustom, p.id) end
	function pm:editOrCreateUserCreatedVersionOfPlayer(id)
		self.editOrCreateCalls = self.editOrCreateCalls + 1
		return self.userCreated:editPlayer(id)
	end
	return pm
end

native = {
	CSex = { Male = { tag = "Male" }, Female = { tag = "Female" } },
	DefaultPlayerVisuals = { PlayerMaleCaucasian = "PMC", PlayerFemaleCaucasian = "PFC" },
	CPlayerDatabaseOnDisc = { getIsOnDiscPlayerId = function(id) return type(id) == "number" and id < 20000 end },
	InputTypes = { X = "X", Decline = "Decline" },
	Localise = function(s) return s end,
	CPlayer = function() return newPlayer(0, "", "") end
}

local modules = {
	viewhubbase_state = { ViewHubBaseState = { enter = function() end, update = function() end, exit = function() end } },
	optionmenu_state = { OptionMenuState = { enter = function() end, update = function() end, exit = function() end, render = function() end } },
	optionmenu_aide = { createButton = function(label, data) local t = copyTable(data or {}); t.label = label; return t end },
	busy_layout = {},
	assetmap = { options = { player = {
		version = { type = "guid" }, sex = { type = "guid" }, head = { type = "guid" }, hairTop = { type = "guid" },
		height = { type = "slider" }, weight = { type = "slider" }, fitness = { type = "slider" },
		nose_height = { type = "slider" }, ugcHead = { type = "guid" }, headUuid = { type = "uuid" },
		tag = { type = "string", noSave = true }, isTier1 = { type = "guid", noSave = true },
		jerseyIcon = function() end
	} },
		-- installed items on the "importing" machine
		AssetMapItems = {
			hairTop = { item_setup = { { guid = 0 }, { guid = 12 }, { guid = 44 }, { guid = 55 }, { guid = 77 }, { guid = 99 } } },
			tier1head = { item_setup = { { guid = 339 }, { guid = 1068 } } }
		},
		getItemByGuid = function(map, guid)
			for _, item in ipairs(map.item_setup) do
				if item.guid == guid then return item end
			end
		end
	},
	attributemap = {
		PlayerAttributesDoNotCountTowardsBudget = { height = { min = 155, max = 220 }, weight = { min = 50, max = 200 }, perk = { min = 0, max = 10 } },
		PlayerAttributesCountTowardsBudget = { agility = { min = 0, max = 99 }, strength = { min = 0, max = 99 } },
		PlayerSkills = { tackle = { min = 0, max = 99 }, basicPass = { min = 0, max = 99 } }
	},
	identitymap = { Data = { { PlayerIdentity = {
		firstname = { type = "string", byteSize = 32 }, surname = { type = "string", byteSize = 32 },
		sex = { type = "integer", min = 0, max = 1 }, birthDay = { type = "integer", min = 1, max = 31 },
		birthMonth = { type = "integer", min = 1, max = 12 }, birthYear = { type = "integer", min = 1800, max = 2500 },
		shirtNumber = { type = "integer", min = 0, max = 99 }, rightHanded = { type = "bool" },
		commentaryNameHash = { type = "integer", byteSize = 4 }, photogrammetryStatus = { type = "integer", min = 0, max = 3 },
		preferredRolePrimary = { type = "integer", min = 0, max = 20 }
	} } } },
	playergenerator = { bogStandardPlayerWithEthnicity = function(engine, p, sex, eth, vm)
		p.identity.sex = sex
		p.identity.values.firstname = "John"
		p.identity.values.surname = "Smith"
		p.visual.values.head = 1
		return p
	end }
}

local env = setmetatable({}, { __index = _G })
env.import = function(path)
	local name = string.match(path, "([^%.]+)$")
	env[name] = assert(modules[name], "no stub for " .. path)
end
env.Class = function(name, base)
	local cls = setmetatable({}, { __index = base })
	env[name] = cls
	return cls
end
env.ASSERT = function(v) assert(v) return v end
env.VERIFY = function(v) assert(v) return v end
env.nop = function() end

local chunk = assert(loadfile(modPath))
setfenv(chunk, env)
chunk()

local T = env.PlayerTransfer
check("module exports PlayerTransfer", T ~= nil)

-- JSON -----------------------------------------------------------------------

do
	local doc = { format = "x", version = 1, players = T.jsonArray({ { name = "Zac \"Z\" O'Lomax\n\t\\", n = 4294967295, f = 0.5019608, neg = -12, b = false } }), empty = T.jsonArray(), obj = {} }
	local text = T.encode(doc)
	local back, err = T.decode(text)
	check("roundtrip decodes", back ~= nil, err)
	check("roundtrip string", back and back.players[1].name == doc.players[1].name)
	check("roundtrip uint", back and back.players[1].n == 4294967295)
	check("roundtrip float", back and math.abs(back.players[1].f - 0.5019608) < 1e-9)
	check("roundtrip negative", back and back.players[1].neg == -12)
	check("roundtrip false", back and back.players[1].b == false)
	check("empty array stays array", back and #back.empty == 0 and getmetatable(back.empty) ~= nil)
	check("key order format first", string.find(text, '"format"') < string.find(text, '"version"'))
	check("uint written plainly", string.find(text, "4294967295", 1, true) ~= nil)

	local u = T.decode('"caf\\u00e9 \\ud83d\\ude00 \\/"')
	check("unicode escapes", u == "caf\195\169 \240\159\152\128 /", u)

	local bad = {
		'{"a": 1,}', '{"a" 1}', '[1, 2', '"abc', '01', '1.', '.5', 'NaN', '{"a": tru}', '{} x',
		'"tab\there"', '"\\x"', '"\\ud800"', '', '   ', string.rep("[", 40) .. string.rep("]", 40), '{a: 1}', '-'
	}
	for _, s in ipairs(bad) do
		local v, e = T.decode(s)
		check("rejects " .. s:sub(1, 20), v == nil and type(e) == "string" and e:find("^line %d+, column %d+:"), e)
	end
	local _, e = T.decode('{\n  "a": 1,\n  "b": ]\n}')
	check("error position", e and e:find("^line 3, column 8"), e)
	local nul = T.decode('{"a": null}')
	check("null sentinel", nul and nul.a == T.JsonNull)
	check("encode non-finite fails", not pcall(T.encode, { a = 0 / 0 }))
	check("numbers with exponent", T.decode("1.5e3") == 1500 and T.decode("-2E-2") == -0.02)
end

-- Export / validate ------------------------------------------------------------

local zac = newPlayer(339, "Zac", "Lomax", { tier1 = true, licensed = true })
local doc = T.exportDocument(zac)
local text = T.encode(doc)
local entries, perr = T.parseFile(text)
check("parse single export", entries and #entries == 1, perr)
local clean, verr = T.validatePlayer(entries and entries[1])
check("validate own export", clean ~= nil, verr)
check("export id/flags", doc.player.id == 339 and doc.player.baseGame == true and doc.player.tier1 == true and doc.player.overall == 85)
check("export skips sex/version/ugc", doc.player.identity.sex == nil and doc.player.appearance.version == nil and doc.player.appearance.ugcHead == nil and doc.player.appearance.headUuid == nil)
check("export skips noSave/functions", doc.player.appearance.tag == nil and doc.player.appearance.isTier1 == nil and doc.player.appearance.jerseyIcon == nil)
check("export includes skills", doc.player.skills.tackle == 75 and doc.player.attributes.strength == 80)
check("export big hash", doc.player.identity.commentaryNameHash == 3000000000)
check("parse tolerates BOM", T.parseFile("\239\187\191" .. text) ~= nil)
check("default file name", T.defaultFileName(zac) == "Player_Zac_Lomax_339.json", T.defaultFileName(zac))
check("file name sanitised", T.defaultFileName(newPlayer(5, "Sione", "Mata'utia Jr.")) == "Player_Sione_Mata_utia_Jr_5.json", T.defaultFileName(newPlayer(5, "Sione", "Mata'utia Jr.")))

local function variant(mutate)
	local d = T.decode(text)
	mutate(d.player)
	return T.validatePlayer(d.player)
end
local _, r1 = variant(function(p) p.skills.tackle = 120 end)
check("rejects skill out of range", r1 and r1:find("skills.tackle must be from 0 to 99"), r1)
local _, r2 = variant(function(p) p.attributes.agility = "fast" end)
check("rejects wrong type", r2 and r2:find("attributes.agility must be a number"), r2)
local _, r3 = variant(function(p) p.identity = nil end)
check("rejects missing identity", r3 and r3:find("missing its identity"), r3)
local _, r4 = variant(function(p) p.sex = "M" end)
check("rejects bad sex", r4 and r4:find("sex must be"), r4)
local _, r5 = variant(function(p) p.identity.surname = string.rep("x", 40) end)
check("rejects long name", r5 and r5:find("at most 31"), r5)
local _, r6 = variant(function(p) p.appearance.head = 1.5 end)
check("rejects fractional guid", r6 and r6:find("appearance.head must be a whole number"), r6)
local _, r7 = variant(function(p) p.skills = T.jsonArray({}) end)
check("rejects list section", r7 and r7:find("skills must be an object"), r7)
local _, r8 = variant(function(p) p.identity.rightHanded = 1 end)
check("rejects non-bool", r8 and r8:find("true or false"), r8)
local _, r9 = variant(function(p) p.identity.surname = "  " end)
check("rejects blank surname", r9 and r9:find("surname is missing"), r9)
local _, r10 = variant(function(p) p.identity.firstname = "a\1b" end)
check("rejects control chars", r10 and r10:find("control"), r10)
local ok11 = variant(function(p) p.appearance = nil; p.unknownKey = 5; p.skills.notASkill = "x" end)
check("appearance optional, unknown keys ignored", ok11 ~= nil)
local _, r12 = variant(function(p) p.identity.firstname = T.JsonNull end)
check("rejects null", r12 and r12:find("got null"), r12)
local c13 = variant(function(p) p.identity.shirtNumber = 150 end)
check("identity out of range is left out, not fatal", c13 and c13.sections.identity.shirtNumber == nil and #c13.ignored == 1 and c13.ignored[1]:find("identity.shirtNumber must be from 0 to 99"), c13 and c13.ignored[1])
local _, r14 = variant(function(p) p.identity.shirtNumber = 7.5 end)
check("identity fraction still rejected", r14 and r14:find("whole number"), r14)
local _, r15 = variant(function(p) p.attributes.height = 300 end)
check("attribute out of range rejected", r15 and r15:find("attributes.height must be from 155 to 220"), r15)

local function parseErr(s) local v, e = T.parseFile(s) return v == nil and e or nil end
check("parse empty", parseErr("") ~= nil)
check("parse bad json", (parseErr("{") or ""):find("not valid JSON"))
check("parse wrong format", (parseErr('{"format": "other", "version": 1}') or ""):find("not a player export"))
check("parse newer version", (parseErr('{"format": "RL26PlayerExport", "version": 2, "player": {}}') or ""):find("newer version"))
check("parse missing version", (parseErr('{"format": "RL26PlayerExport", "player": {}}') or ""):find("no format version"))
check("parse empty list", (parseErr('{"format": "RL26PlayersExport", "version": 1, "players": []}') or ""):find("no players"))
check("parse list not array", (parseErr('{"format": "RL26PlayersExport", "version": 1, "players": {}}') or ""):find("no players list"))
check("parse top-level array", (parseErr('[]') or ""):find("not a player export"))

-- Import -------------------------------------------------------------------------

local function context(pm)
	return { engine = {}, uiServices = { getDefaultPlayerVisualManager = function() return {} end }, playerManager = pm,
		createdIndex = (function()
			local ui = { getPlayerManager = function() return pm end, getDefaultPlayerVisualManager = function() return {} end }
			return T.newImportContext({}, ui).createdIndex
		end)() }
end

local function cleanFrom(player, mutate)
	local d = T.decode(T.encode(T.exportDocument(player)))
	if mutate then mutate(d.player) end
	return assert(T.validatePlayer(d.player))
end

do
	-- tier-1 base player: matched by id, look untouched, stored via saveCustomLicensed
	local discZac = newPlayer(339, "Zac", "Lomax", { tier1 = true, licensed = true })
	local pm = newManager({ discZac })
	local ctx = context(pm)
	local c = cleanFrom(discZac, function(p) p.skills.tackle = 99; p.appearance.hairTop = 55 end)
	check("tier-1 resolves by id", T.resolveTarget(ctx, c) == 339)
	local res = T.importOne(ctx, { clean = c, targetId = 339 })
	check("tier-1 updated", res == "updated", res)
	check("tier-1 saved custom licensed", pm.savedCustom[1] == 339)
	check("tier-1 skill applied", pm:getPlayer(339).skills.values.tackle == 99)
	check("tier-1 appearance untouched", pm:getPlayer(339).visual.values.hairTop == 12)
	check("tier-1 no editOrCreate", pm.editOrCreateCalls == 0)
	check("on-disc copy untouched", discZac.skills.values.tackle == 75)
	local again = T.importOne(ctx, { clean = c, targetId = 339 })
	check("re-import unchanged", again == "unchanged", again)
end

do
	-- licensed non-tier-1: editOrCreate + editPlayer, appearance applied
	local disc = newPlayer(100, "Reece", "Walsh", { licensed = true })
	local pm = newManager({ disc })
	local ctx = context(pm)
	local c = cleanFrom(disc, function(p) p.skills.basicPass = 90; p.appearance.hairTop = 77; p.appearance.height = 0.9 end)
	local res, failed = T.importOne(ctx, { clean = c, targetId = T.resolveTarget(ctx, c) })
	check("licensed updated", res == "updated", res)
	check("licensed editOrCreate called", pm.editOrCreateCalls == 1)
	local live = pm:getPlayer(100)
	check("licensed skill + look applied", live.skills.values.basicPass == 90 and live.visual.values.hairTop == 77 and live.visual.values.height == 0.9)
	check("height/weight resynced", live.heightWeightCalls == 1)
	check("sharing flagged", live.sharing.hasUnsharedModifications == true)
	check("no failed fields", failed and #failed == 0)
end

do
	-- base id match rules
	local disc = newPlayer(200, "Tom", "Trbojevic", { day = 4, month = 5, year = 1996 })
	local pm = newManager({ disc })
	local ctx = context(pm)
	local renamed = cleanFrom(disc, function(p) p.identity.firstname = "Thomas" end)
	check("renamed base player matched by DOB", T.resolveTarget(ctx, renamed) == 200)
	local other = cleanFrom(disc, function(p) p.identity.firstname = "Someone"; p.identity.surname = "Else"; p.identity.birthYear = 2001 end)
	check("different person on same id -> new", T.resolveTarget(ctx, other) == nil)
	local female = cleanFrom(disc, function(p) p.sex = "Female" end)
	check("sex mismatch -> new", T.resolveTarget(ctx, female) == nil)
	local shifted = cleanFrom(disc, function(p) p.id = 9999 end)
	check("base player found by name when id differs", T.resolveTarget(ctx, shifted) == 200)
	local createdCopy = cleanFrom(disc, function(p) p.id = 25000; p.baseGame = false end)
	check("created clone of a base name stays new", T.resolveTarget(ctx, createdCopy) == nil)
end

do
	-- new players, dedupe, capacity, tier-1 source
	local pm = newManager({}, {}, 2)
	local ctx = context(pm)
	local src = newPlayer(25001, "Made", "Up", { year = 2004 })
	src.visual.values.hairTop = 99
	local c = cleanFrom(src)
	check("created player -> new", T.resolveTarget(ctx, c) == nil)
	local res = T.importOne(ctx, { clean = c })
	check("added", res == "added", res)
	local newId = 20000
	local added = pm:getPlayer(newId)
	check("added data", added and added.identity.values.firstname == "Made" and added.visual.values.hairTop == 99 and added.skills.values.tackle == 75)
	check("added keeps generated sex", added and added.identity.sex == native.CSex.Male)
	local res2 = T.importOne(ctx, { clean = c })
	check("same file again dedupes", res2 == "unchanged", res2)
	local ctx2 = context(pm)
	check("dedupe across imports", T.resolveTarget(ctx2, c) == newId)

	local scan = newPlayer(339, "Zac", "Lomax", { tier1 = true })
	scan.visual.values.height = 0.66
	scan.visual.values.hairTop = 44
	local cs = cleanFrom(scan)
	local res3 = T.importOne(ctx, { clean = cs })
	check("tier-1 source -> new", res3 == "added", res3)
	local clone = pm:getPlayer(20001)
	check("tier-1 source body only", clone and clone.visual.values.height == 0.66 and clone.visual.values.head == 1 and clone.visual.values.hairTop ~= 44)

	local res4, why = T.importOne(ctx, { clean = cleanFrom(newPlayer(25002, "No", "Room")) })
	check("storage full", res4 == nil and why:find("full"), why)

	local readOnly = newPlayer(20500, "Down", "Loaded", { readOnly = true })
	local pm2 = newManager({}, { readOnly }, 5)
	check("read-only downloads not updated", T.resolveTarget(context(pm2), cleanFrom(readOnly)) == nil)
end

do
	-- failed setOption is reported, not fatal
	local disc = newPlayer(300, "Picky", "Player")
	local pm = newManager({ disc })
	local ctx = context(pm)
	local c = cleanFrom(disc, function(p) p.skills.tackle = 10 end)
	pm.userCreated:editPlayer(300).skills.reject.tackle = true
	local res, failed = T.importOne(ctx, { clean = c, targetId = 300 })
	check("partial update reported", res == "updated" and failed[1] == "skills.tackle", tostring(res) .. " " .. tostring(failed and failed[1]))
end

do
	-- planImport
	local disc = newPlayer(339, "Zac", "Lomax", { tier1 = true })
	local pm = newManager({ disc })
	local ctx = context(pm)
	local d = T.decode(T.encode(T.exportDocument(disc)))
	local good = d.player
	local fresh = T.decode(T.encode(T.exportDocument(newPlayer(25003, "New", "Guy")))).player
	local broken = T.decode(T.encode(T.exportDocument(newPlayer(25004, "Bad", "Data")))).player
	broken.skills.tackle = -1
	local plan = T.planImport(ctx, { good, fresh, broken, "junk" })
	check("plan counts", #plan.items == 2 and plan.updates == 1 and plan.adds == 1 and #plan.errors == 2, #plan.errors)
	check("plan error label", plan.errors[1]:find("^Player 3 %(Bad Data%): skills.tackle"), plan.errors[1])
	check("plan junk label", plan.errors[2]:find("^Player 4: is not a player"), plan.errors[2])
end

do
	-- export lists
	local t1 = newPlayer(339, "Zac", "Lomax", { tier1 = true })
	local t2 = newPlayer(340, "Nathan", "Cleary", { tier1 = true })
	local plain = newPlayer(341, "Plain", "Player")
	local pm = newManager({ t1, t2, plain }, { newPlayer(20000, "Made", "Up"), clonePlayer(plain) })
	local editedT2 = clonePlayer(t2)
	editedT2.skills.values.tackle = 99
	pm.custom[340] = editedT2
	local lists = T.collectExportIds(pm)
	local function has(list, id) for _, v in ipairs(list) do if v == id then return true end end end
	check("edited has created", has(lists.edited, 20000))
	check("edited has official edit", has(lists.edited, 341))
	check("edited has tier-1 edit", has(lists.edited, 340))
	check("edited skips unedited tier-1", not has(lists.edited, 339))
	check("all has everyone once", #lists.all == 4 and has(lists.all, 339) and has(lists.all, 20000))
end

do
	-- appearance items that aren't installed here are dropped, not fatal
	local modded = newPlayer(25010, "Hair", "Mod", { year = 2003 })
	modded.visual.values.hairTop = 5000
	modded.visual.values.head = 0
	local c = cleanFrom(modded)
	check("missing hair item dropped", c.sections.appearance.hairTop == nil and #c.missingItems == 1 and c.missingItems[1]:find("appearance.hairTop 5000 is not installed"), c.missingItems[1])
	check("generic head 0 always allowed", c.sections.appearance.head == 0)
	check("installed items kept", cleanFrom(newPlayer(25011, "Has", "Hair")).sections.appearance.hairTop == 12)
	local scan = cleanFrom(newPlayer(3982, "Johnathan", "Thurston", { tier1 = true }), function(p) p.appearance.head = 10208 end)
	check("missing scanned head dropped", scan.sections.appearance.head == nil and #scan.missingItems == 1)
	local pm = newManager({}, {}, 5)
	local plan = T.planImport(context(pm), { T.decode(T.encode(T.exportDocument(modded))).player, (function()
		local d = T.decode(T.encode(T.exportDocument(newPlayer(3982, "Johnathan", "Thurston", { tier1 = true })))).player
		d.appearance.head = 10208
		return d
	end)() })
	check("plan counts only non-scanned missing items", plan.missingItems == 1 and plan.adds == 2, plan.missingItems)
	local res = T.importOne(context(pm), plan.items[1])
	local added = pm:getPlayer(20000)
	check("import keeps default for missing item", res == "added" and added.visual.values.hairTop == 12 and added.skills.values.tackle == 75, res)
	local res2 = T.importOne(context(pm), plan.items[2])
	check("RLL4 scan without the mod -> new player, default face", res2 == "added" and pm:getPlayer(20001).visual.values.head == 1, res2)
end

do
	local rows = T.menuRows()
	check("three menu rows", #rows == 3 and rows[1].stateData.nextState == env.AcademyPlayerImportState and rows[2].stateData.playerTransferMulti == true and rows[3].stateData.nextState == env.AcademyPlayerExportAllState)
end

-- Team export (app/club/club_view_state.lua) ----------------------------------

do
	local function enum(name, value)
		return setmetatable({ value = value }, {
			__tostring = function() return name end,
			__index = { toInt = function(self) return self.value end }
		})
	end
	local Home, Away, Nines = enum("Home", 0), enum("Away", 1), enum("Nines", 2)
	local League = enum("LeagueMatch", 0)
	native.sportType = "rugbyleague"
	native.CClubManager = { getIsOnDiscClub = function(id) return id < 1000 end }
	native.CClubDatabaseOnDisc = { getIsOfficialClubId = function(id) return id < 1000 end }
	native.CClubUniformCategory = { Count = 3, Nines = Nines, fromInt = function(_, i) return ({ [0] = Home, Away, Nines })[i] end }
	native.CClubLineup = { getLineupSize = function(category) return 3 end }
	native.EClubLineupSpecialRole = { Captain = "C", GoalKicker = "K", PlayMaker = "P" }

	table.insert(modules.identitymap.Data, { ClubHomeGroundInfo = {
		stadium = { type = "integer", min = 0, max = 200 }, customName = { type = "string", byteSize = 32 },
		wantCustomName = { type = "integer", min = 0, max = 1 }, isOnDisk = { type = "bool" }
	} })
	table.insert(modules.identitymap.Data, { ClubIdentity = {
		fullName = { type = "string", byteSize = 54 }, nickname = { type = "string", byteSize = 19 },
		hudName = { type = "string", byteSize = 4 }, sex = { type = "integer", min = 0, max = 1 },
		supporters = { type = "integer", byteSize = 1 }, isWorldCup = { type = "bool" },
		homeGroundCount = { type = "integer" }, primaryRGBColour = { type = "integer", arraySize = 3 },
		homeGrounds = { type = "dataConfig", arraySize = 3 }, feederClubs = { type = "integer", arraySize = 7 }
	} })
	modules.assetmap.options.team = {
		version = { type = "guid" }, sex = { type = "guid" }, uniformTop = { type = "guid" },
		uniformTop_layer1_colour_r = { type = "slider" }, icon = { type = "string", noSave = true },
		jerseyIcon = function() end
	}
	for _, name in ipairs({ "statemachine", "clubgenerator", "save_aide", "sharing_searchtags_aide" }) do
		modules[name] = {}
	end
	local hubClass = { update = function() end }
	modules.club_viewstate_hub_state = { ClubViewHubState = hubClass }
	modules.stadium_helper = { getClubStadiumLabel = function(g) return "Ground " .. tostring(g.values.stadium) end }
	modules.player_viewstate_hub_state = { PlayerTransfer = T }

	local clubChunk = assert(loadfile(arg[2]))
	setfenv(clubChunk, env)
	clubChunk()

	local TT = env.TeamTransfer
	check("module exports TeamTransfer", TT ~= nil and env.ClubViewState ~= nil and env.AcademyTeamExportAllState ~= nil)

	local function lineup(ids, captain)
		return { category = League, ids = ids,
			getPlayerIdAt = function(self, i) return self.ids[i] end,
			getSpecialRole = function(self, role) if role == "C" then return captain end end }
	end
	local function newClub(id, name, opts)
		opts = opts or {}
		local identity = config({ fullName = name, nickname = "Nick", hudName = "NCK", supporters = 119, isWorldCup = false })
		identity.sex = opts.sex or native.CSex.Male
		identity.primaryRGBColour = { r = 0, g = 52, b = 93 }
		identity.colourSet = 7
		identity.decalIdOrIcon = opts.decalId and { decalId = opts.decalId } or { icon = "nrl_broncos" }
		local grounds = { config({ stadium = 12, customName = "Home Park", wantCustomName = 1, isOnDisk = true }) }
		identity.groundCount = #grounds
		function identity:getGround(i) return grounds[i] end
		local kits = {
			{ name = "HOME", isHidden = false, config = config({ uniformTop = 105, uniformTop_layer1_colour_r = 0.5, version = 9 }) },
			{ name = "AWAY", isHidden = true, config = config({ uniformTop = 106 }) }
		}
		local club = { id = id, academyId = id, fullName = name, identity = identity, uniformCount = #kits, coachId = 4,
			roster = opts.roster or { 339, 341 }, lineups = { lineup(opts.lineup or { 339, 341, 999 }, 339) } }
		club.playerCount = #club.roster
		function club:getUniform(i) return kits[i] end
		function club:getDefaultUniformIndex(cat) return cat == Home and 1 or 2 end
		function club:getPlayerIdAt(i) return self.roster[i] end
		function club:getLineupCount() return #self.lineups end
		function club:getLineup(i) return self.lineups[i] end
		return club
	end

	local broncos = newClub(1, "Brisbane Broncos")
	local team = TT.serialiseTeam(broncos, { created = false, edited = true })
	check("team top fields", team.id == 1 and team.name == "Brisbane Broncos" and team.sex == "Male" and team.baseGame == true and team.edited == true and team.created == false and team.coachId == 4)
	check("team identity from map", team.identity.nickname == "Nick" and team.identity.supporters == 119 and team.identity.isWorldCup == false)
	check("team identity skips sex/arrays/count", team.identity.sex == nil and team.identity.homeGroundCount == nil and team.identity.feederClubs == nil and team.identity.homeGrounds == nil)
	check("team colours and extras", team.identity.primaryRGBColour.b == 93 and team.identity.colourSet == 7)
	check("team emblem icon", team.emblem.icon == "nrl_broncos" and team.emblem.customLogo == nil)
	check("team grounds", #team.homeGrounds == 1 and team.homeGrounds[1].customName == "Home Park" and team.homeGrounds[1].label == "Ground 12" and team.homeGrounds[1].isOnDisk == nil)
	check("team kits", #team.uniforms == 2 and team.uniforms[1].name == "HOME" and team.uniforms[1].options.uniformTop == 105 and team.uniforms[1].options.version == nil and team.uniforms[2].hidden == true)
	check("team kit sliders", math.abs(team.uniforms[1].options.uniformTop_layer1_colour_r - 0.5) < 1e-9)
	check("team kit defaults skip nines", team.uniformDefaults.Home == 1 and team.uniformDefaults.Away == 2 and team.uniformDefaults.Nines == nil)
	check("team roster and lineup", #team.roster == 2 and team.lineups[1].category == "LeagueMatch" and #team.lineups[1].players == 3 and team.lineups[1].captain == 339)
	local ids = TT.playerIdsOf(team)
	check("player ids once, roster then lineup", #ids == 3 and ids[1] == 339 and ids[2] == 341 and ids[3] == 999)
	check("signature leaves kit options out", TT.serialiseTeam(broncos, { withKitOptions = false }).uniforms[1].options == nil)
	check("custom logo flagged", TT.serialiseTeam(newClub(1000, "My Team", { decalId = 77 })).emblem.customLogo == true)
	check("team file name", TT.defaultFileName(broncos) == "Team_Brisbane_Broncos_1.json", TT.defaultFileName(broncos))

	local pm = newManager({ newPlayer(339, "Zac", "Lomax"), newPlayer(341, "Plain", "Player") })
	local tdoc, skipped = TT.exportDocument(broncos, pm, { created = false, edited = false })
	check("team doc players", tdoc.format == "RL26TeamExport" and tdoc.playerCount == 2 and skipped == 1 and tdoc.players[1].id == 339)
	local back = T.decode(T.encode(tdoc))
	check("team doc roundtrips", back and back.team.uniforms[1].options.uniformTop == 105 and back.team.lineups[1].players[3] == 999)
	check("team doc key order", (function()
		local s = T.encode(tdoc)
		local function top(key) return s:find('\n  "' .. key .. '"') end
		return top("team") < top("playerCount") and top("playerCount") < top("players")
	end)())

	-- export lists: Academy-made, edited official, untouched official
	local stock1, stock2 = newClub(1, "Brisbane Broncos"), newClub(2, "Bulldogs")
	local live1 = newClub(1, "Brisbane Broncos", { roster = { 339, 341, 342 } })
	local made = newClub(1000, "My Team")
	local cm = {
		clubs = { [1] = live1, [2] = stock2, [1000] = made },
		onDiscDatabase = { getClub = function(_, id) return ({ [1] = stock1, [2] = stock2 })[id] end },
		onDisc = { iterateAll = function() return iterList({ live1, stock2 }) end },
		userCreated = { iterateAll = function() return iterList({ made }) end }
	}
	function cm:getClub(id) return self.clubs[id] end
	local lists = TT.collectExportIds(cm)
	check("created list", #lists.created == 2 and lists.created[1] == 1000 and lists.created[2] == 1 and lists.made[1000] and lists.edited[1])
	check("base list", #lists.base == 2 and lists.base[1] == 1 and lists.base[2] == 2)
	check("all list once each", #lists.all == 3)
	check("same object is not edited", not TT.isEditedOfficial(cm, 2))

	local rows = TT.menuRows()
	check("team menu row", #rows == 1 and rows[1].teamTransferRow and rows[1].stateData.nextState == env.AcademyTeamExportAllState)
end

print(string.format("%d passed, %d failed", passes, failures))
os.exit(failures == 0 and 0 or 1)
'''


def main():
    tmp = tempfile.mkdtemp()
    for path in (MOD_FILE, HOME_FILE, CLUB_FILE):
        result = subprocess.run([LUAJIT, "-b", os.path.abspath(path), os.path.join(tmp, "check.out")], cwd=LUAJIT_CWD,
                                    capture_output=True, text=True)
        if result.returncode != 0:
            print(f"compile failed: {path}\n{result.stderr}")
            return 1
    with tempfile.TemporaryDirectory() as tmp:
        harness = os.path.join(tmp, "harness.lua")
        with open(harness, "w", encoding="utf-8", newline="\n") as f:
            f.write(HARNESS)
        result = subprocess.run([LUAJIT, harness, os.path.abspath(MOD_FILE), os.path.abspath(CLUB_FILE)], capture_output=True, text=True)
        sys.stdout.write(result.stdout)
        sys.stderr.write(result.stderr)
        return result.returncode


if __name__ == "__main__":
    sys.exit(main())
