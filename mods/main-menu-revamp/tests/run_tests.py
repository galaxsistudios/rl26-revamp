#!/usr/bin/env python3
"""
Offline tests for main-menu-revamp: runs the mod's appended block of
app/save/compresssavedata_state.lua in LuaJIT with a stubbed Class(),
uiServices and player model, and checks the HomeScreenState hook (install
before/after the class exists, re-definition after a frontend reload, chaining
with clear-academy-data's update trap) and the show / animate / hide flow.

    python mods\\main-menu-revamp\\tests\\run_tests.py

build.py skips *.py, so this file is never packed into the game.
"""

import os
import subprocess
import sys
import tempfile

LUAJIT = r"D:\galaxsi\projects\games\modding\toolchain\luajit\bin\luajit.exe"
LUAJIT_CWD = os.path.dirname(LUAJIT)
HERE = os.path.dirname(os.path.abspath(__file__))
MOD_FILE = os.path.join(HERE, "..", "src", "script-game", "app", "save", "compresssavedata_state.lua")
MARKER = "-- main-menu-revamp mod:"

HARNESS = r'''
local blockPath = arg[1]
local failures, passes = 0, 0

local function check(name, cond, detail)
	if cond then
		passes = passes + 1
	else
		failures = failures + 1
		print("FAIL: " .. name .. (detail and (" -- " .. tostring(detail)) or ""))
	end
end

local clock = 100
os.clock = function() return clock end

native = {
	vec3 = setmetatable({ Zero = function() return { 0, 0, 0 } end }, {
		__call = function(_, x, y, z) return { x, y, z } end
	}),
	AcademyLeagues = { League_NRL2026 = 77, League_NRL = 1 },
	InputTypes = { Decline = "Decline" },
	EGearAttachmentJoint = { LeftHandBallJoint = "LeftHand", RightHandBallJoint = "RightHand" }
}

local function loadBlock()
	local chunk = assert(loadfile(blockPath))
	chunk()
end

-- Mirrors core/foundation/class.lua: reuse _CLASSES[name], keep its metatable,
-- assign __index / methods through normal indexing.
local function Class(name)
	local cls = _G._CLASSES[name] or {}
	cls.__index = cls
	local meta = getmetatable(cls) or {}
	meta.__call = function(c, ...) return setmetatable({}, c) end
	setmetatable(cls, meta)
	_G._CLASSES[name] = cls
	return cls
end

-- clear-academy-data's trap, reduced: wraps update when it is assigned.
local function installClearAcademyTrap(log)
	local cls = _G._CLASSES.HomeScreenState
	local meta = getmetatable(cls) or {}
	if rawget(meta, "__clearAcademyTrap") then return end
	rawset(meta, "__clearAcademyTrap", true)
	local previous = meta.__newindex
	function meta.__newindex(t, k, v)
		if k == "update" and type(v) == "function" and rawget(t, "__clearAcademyWrapper") ~= v then
			local inner = v
			v = function(...) table.insert(log, "clear"); return inner(...) end
			rawset(t, "__clearAcademyWrapper", v)
		end
		if type(previous) == "function" then previous(t, k, v)
		elseif type(previous) == "table" then previous[k] = v
		else rawset(t, k, v) end
	end
	setmetatable(cls, meta)
end

-- Fake services / player model --------------------------------------------

local function newServices(opts)
	opts = opts or {}
	local s = { log = {}, cameraEnabled = opts.cameraEnabled or false, updates = {}, props = {} }
	local model = { cameraInfo = opts.cameraInfo, loaded = false }
	function model.setCameraInfo(self, info, instant) self.cameraInfo = info; self.restoredInstant = instant end
	function model.attachProp(self, name, joint) self.ballJoint = joint end
	function model.showProp(self, name) self.ballVisible = true end
	function model.hideProp(self, name) self.ballVisible = false end
	s.model = model

	local clubs = {}
	for id = 118, 134 do
		clubs[id] = {
			id = id,
			playerCount = 3,
			identity = "identity" .. id,
			getPlayerIdAt = function(self, i) return id * 100 + i end,
			getHomeUniformVisual = function(self) return "uniform" .. id end
		}
	end

	function s.getLeagueManager()
		if opts.noLeague then error("no league manager") end
		return {
			onDisc = { getLeagueIdBasedOff = function(_, academyId) return academyId == 77 and 5 or nil end },
			getLeague = function(_, id) return id == 5 and { getClubIds = function() return { 120, 121 } end } or nil end
		}
	end
	function s.getClubManager() return { getClub = function(_, id) return clubs[id] end } end
	function s.getPlayerManager()
		return { getPlayer = function(_, id) return { id = id, visual = {}, identity = { fullName = "P" .. id } } end }
	end
	function s.playerModelGetPlayer(self, index) return model end
	function s.playerModelCameraEnabled(self, value)
		local was = self.cameraEnabled
		if value ~= nil then
			if value then model.cameraInfo = nil end
			self.cameraEnabled = value
		end
		return was
	end
	function s.playerModelSetUniform(self, index, uniform, identity) self.uniform = uniform end
	function s.setPlayerModelProps(self, index, list, player)
		if opts.noBallProp and list and list[1] and list[1].attach then error("no ball prop") end
		table.insert(self.props, list and list[1] and (list[1].attach and "attach" or "detach") or "hideAll")
	end
	function s.playerModelUpdate(self, index, params)
		table.insert(self.updates, params)
		if params.camera then model.cameraInfo = params.camera end
		if params.draw ~= nil then self.draw = params.draw end
		if params.player then self.player = params.player end
	end
	function s.playerModelGetIsLoaded(self, index) return model.loaded end
	return s
end

local function lastAnim(s)
	for i = #s.updates, 1, -1 do
		local p = s.updates[i].idleParams
		if p then return p.playerAnimation end
	end
end

-- 1. Install before Class(), then define methods -------------------------
-- Game order: this file (homescreen_state's 1st import), then clear-academy-data
-- (via homescreenstate_config), then Class() and the method definitions.
_G._CLASSES = {}
loadBlock()
local calls = {}
installClearAcademyTrap(calls)

local cls = Class("HomeScreenState")
function cls.enter(self, sm, engine, a3, config, uiServices) table.insert(calls, "enter"); self.view = "view" end
function cls.update(self) table.insert(calls, "update") end
function cls.exit(self) table.insert(calls, "exit") end

check("enter not stored raw", rawget(cls, "enter") == nil)
check("non-hooked keys rawset", rawget(cls, "__index") == cls)

local services = newServices({ cameraInfo = "featured" })
local state = cls()
state:enter("sm", "engine", nil, {}, services, "party")
check("original enter ran", calls[1] == "enter")
check("player drawn", services.draw == true)
check("camera pushed", services.cameraEnabled == true)
check("uniform from NRL league club", services.uniform == "uniform120" or services.uniform == "uniform121", services.uniform)
check("camera set with base anim", services.model.cameraInfo and services.model.cameraInfo.playerAnimation == "FullBodyIdle")
check("rotation set", services.updates[1].rotation == 0)
check("ball in the left hand and shown", services.model.ballJoint == "LeftHand" and services.model.ballVisible == true)
check("head tracking off", not services.model.cameraInfo.lookAtEnable)

-- update: not loaded -> nothing; loaded -> idle timer then a flourish
state:update("sm", "engine", nil, nil, nil, services)
check("update original ran", calls[#calls] == "update")
check("clear-academy wrapper still runs", calls[#calls - 1] == "clear", calls[#calls - 1])
local before = #services.updates
clock = clock + 30
state:update("sm", "engine", nil, nil, nil, services)
check("no flourish before load", #services.updates == before)

services.model.loaded = true
state:update("sm", "engine", nil, nil, nil, services)
clock = clock + 5
state:update("sm", "engine", nil, nil, nil, services)
check("no flourish during idle", #services.updates == before)
clock = clock + 7
state:update("sm", "engine", nil, nil, nil, services)
local flourish = lastAnim(services)
check("flourish started", flourish ~= nil and flourish ~= "FullBodyIdle", flourish)

-- run the flourish to completion: it must return to the base idle
for _ = 1, 10 do
	clock = clock + 6.5
	state:update("sm", "engine", nil, nil, nil, services)
	if lastAnim(services) == "FullBodyIdle" then break end
end
check("returns to base idle", lastAnim(services) == "FullBodyIdle", lastAnim(services))

state:exit("engine", nil, {}, services)
check("original exit ran", calls[#calls] == "exit")
check("player hidden", services.draw == false)
check("camera popped", services.cameraEnabled == false)
check("camera info restored", services.model.cameraInfo == "featured", tostring(services.model.cameraInfo))
check("ball detached then props hidden", services.props[#services.props] == "hideAll" and services.props[#services.props - 1] == "detach")

-- 2. Frontend reload: methods redefined on the same class table ----------
local reloadCalls = {}
local cls2 = Class("HomeScreenState")
check("class table reused", cls2 == cls)
function cls2.enter(self, sm, engine, a3, config, uiServices) table.insert(reloadCalls, "enter2"); self.view = "v" end
function cls2.update(self) table.insert(reloadCalls, "update2") end
function cls2.exit(self) table.insert(reloadCalls, "exit2") end
local s2 = newServices()
local st2 = cls2()
st2:enter("sm", "engine", nil, {}, s2)
check("reloaded enter wrapped", reloadCalls[1] == "enter2" and s2.draw == true)
st2:update("sm", "engine", nil, nil, nil, s2)
check("reloaded update wrapped and chained", reloadCalls[#reloadCalls] == "update2")
st2:exit("engine", nil, {}, s2)
check("reloaded exit wrapped", s2.draw == false and s2.cameraEnabled == false)
-- reloading the block itself must not double-install
loadBlock()
check("no double install", getmetatable(cls).__mainMenuHooks ~= nil)

-- 3. Install after the class already exists ------------------------------
_G._CLASSES = {}
local cls3 = Class("HomeScreenState")
local c3 = {}
function cls3.enter(self) table.insert(c3, "enter"); self.view = "v" end
function cls3.update(self) table.insert(c3, "update") end
function cls3.exit(self) table.insert(c3, "exit") end
loadBlock()
check("existing enter moved to side table", rawget(cls3, "enter") == nil)
local s3 = newServices()
local st3 = cls3()
st3:enter("sm", "engine", nil, {}, s3)
check("existing enter wrapped", c3[1] == "enter" and s3.draw == true)

-- 4. Autonav / standalone enter (no view) shows nothing -------------------
_G._CLASSES = {}
loadBlock()
local cls4 = Class("HomeScreenState")
function cls4.enter(self) end
function cls4.exit(self) end
local s4 = newServices()
cls4():enter("sm", "engine", nil, {}, s4)
check("no view -> no player", s4.draw == nil and s4.cameraEnabled == false)

-- 5. League lookup failure -> fallback ids; missing ball prop -> no ball ---
_G._CLASSES = {}
loadBlock()
local cls5 = Class("HomeScreenState")
function cls5.enter(self) self.view = "v" end
function cls5.exit(self) end
local seenBall, seenFallback = false, false
for i = 1, 20 do
	local s5 = newServices({ noLeague = true, noBallProp = true })
	local st5 = cls5()
	st5:enter("sm", "engine", nil, {}, s5)
	local id = tonumber(s5.uniform:match("%d+"))
	if id and (id < 120 or id > 121) then seenFallback = true end
	for _, p in ipairs(s5.props) do if p == "attach" then seenBall = true end end
	check("shown despite failures " .. i, s5.draw == true)
	st5:exit("engine", nil, {}, s5)
end
check("fallback club ids used", seenFallback)
check("ball never attached without a ball prop", not seenBall)

-- 6. Services found by scan when the position differs --------------------
_G._CLASSES = {}
loadBlock()
local cls6 = Class("HomeScreenState")
function cls6.enter(self) self.view = "v" end
function cls6.exit(self) end
local s6 = newServices()
local st6 = cls6()
st6:enter("sm", "engine", nil, {}, s6)
st6:exit("engine", s6)
check("exit finds services by scan", s6.draw == false)

-- 7. Engine type() returns class names for instances --------------------
local realType = type
rawtype = realType
type = function(v)
	if realType(v) == "table" and rawget(v, "__className") then return rawget(v, "__className") end
	return realType(v)
end
_G._CLASSES = {}
loadBlock()
local cls7 = Class("HomeScreenState")
function cls7.enter(self) self.view = "v" end
function cls7.exit(self) end
local s7 = newServices()
s7.__className = "FrontEndServices"
cls7():enter("sm", "engine", nil, {}, s7)
check("services found despite overridden type()", s7.draw == true)
type = realType

-- 8. Menu reorganisation -------------------------------------------------
native.CSex = { Male = "M", Female = "F" }
local function item(title, sex, pro) return { title = title, stateData = { sex = sex, beAPro = pro } } end
local shared = {
	casual = { dataContextKey = "Casual", autoNavKey = "casual", title = "Play Now", stateFactory = "CasualState",
		subMenu = { item("club m", "M"), item("club f", "F"), item("pro m", "M", true), item("pro f", "F", true) } },
	rlwc = { dataContextKey = "RLWC2026", title = "RLWC", competitionId = 9, subMenu = { { title = "x" } } },
	finals = { dataContextKey = "Finals", title = "Finals" },
	career = { dataContextKey = "Career", title = "Career" },
	online = { dataContextKey = "Online", title = "Online", stateFactory = "OnlineSetup",
		subMenu = { { title = "Quick", stateData = { stateFactory = "QS" } } } },
	pro = { dataContextKey = "ProTeam", title = "Pro Team", stateFactory = "Dynasty", locked = false },
	hub = { dataContextKey = "CompetitionHub", title = "Comp", stateFactory = "CompState", scanTasksOnSubmenuOpen = { "Competition" }, subMenu = {} },
	settings = { dataContextKey = "Settings", title = "Settings", stateFactory = "SettingsState", description = "sd",
		subMenu = { { title = "General", stateData = { nextState = "G" } }, { title = "Controls", locked = true, stateData = { nextState = "C" } } } },
	practice = { dataContextKey = "Practice", title = "Practice" }
}
homescreenstate_config = {
	createFirstPageTiles = function()
		return { tilesRows = {
			Main = { dataContextKey = "Main", shared.casual, shared.rlwc, shared.finals, shared.career, shared.online, shared.pro },
			Competition = { dataContextKey = "Competition", shared.hub },
			Academy = { dataContextKey = "Academy" },
			Extra = { dataContextKey = "Extra", shared.settings, shared.practice }
		} }
	end
}
import = function() end
_G._CLASSES = {}
loadBlock()
local cls8 = Class("HomeScreenState")
local seenTiles
function cls8.enter(self) self.view = "v"; seenTiles = homescreenstate_config.createFirstPageTiles() end
function cls8.exit(self) end
local s8 = newServices()
cls8():enter("sm", "engine", nil, {}, s8)
local main = seenTiles.tilesRows.Main
local keys = {}
for i, t in ipairs(main) do keys[i] = t.dataContextKey end
check("play row order", table.concat(keys, ",") == "CasualGame,CasualTeam,CasualPlayer,Competitions,Career,OnlineMenu,RLWC2026,PageBack", table.concat(keys, ","))
local byKey = {}
for _, t in ipairs(main) do byKey[t.dataContextKey] = t end
check("casual game is a page button", byKey.CasualGame.subMenu == nil and byKey.CasualGame.stateData.mainMenuPage == "Casual" and byKey.CasualGame.autoNavKey == "casual")
check("team = club male/female", #byKey.CasualTeam.subMenu == 2 and byKey.CasualTeam.subMenu[1].title == "Male" and byKey.CasualTeam.subMenu[2].title == "Female" and not byKey.CasualTeam.subMenu[1].stateData.beAPro)
check("player = be a pro male/female", #byKey.CasualPlayer.subMenu == 2 and byKey.CasualPlayer.subMenu[1].stateData.beAPro)
check("competitions page button drops hub scan/submenu", byKey.Competitions.subMenu == nil and byKey.Competitions.scanTasksOnSubmenuOpen == nil and byKey.Competitions.stateData.mainMenuPage == "Competitions")
check("online has pro team, own factories", byKey.OnlineMenu.stateFactory == nil and #byKey.OnlineMenu.subMenu == 2 and byKey.OnlineMenu.subMenu[1].stateFactory == "OnlineSetup" and byKey.OnlineMenu.subMenu[2].stateFactory == "Dynasty")
check("world cup renamed, keeps competition id", byKey.RLWC2026.title == "World Cup" and byKey.RLWC2026.competitionId == 9)
check("shared tiles untouched", shared.rlwc.title == "RLWC" and shared.casual.subMenu[1].title == "club m" and shared.hub.scanTasksOnSubmenuOpen ~= nil and shared.casual.title == "Play Now")
local extra = {}
for i, t in ipairs(seenTiles.tilesRows.Extra) do extra[i] = t.dataContextKey end
check("settings split into boxes", table.concat(extra, ",") == "Practice,SettingsItem1,SettingsItem2", table.concat(extra, ","))
check("settings box keeps state + lock", seenTiles.tilesRows.Extra[2].stateFactory == "SettingsState" and seenTiles.tilesRows.Extra[2].stateData.nextState == "G" and seenTiles.tilesRows.Extra[3].locked == true)
local again = homescreenstate_config.createFirstPageTiles()
check("wrapper applied once per call", #again.tilesRows.Main == 8)
cls8():enter("sm", "engine", nil, {}, s8)
check("not double wrapped", #homescreenstate_config.createFirstPageTiles().tilesRows.Main == 8)

-- 9. Bound properties injected into ns classes ----------------------------
ns = { typeOf = function(c) return "type:" .. tostring(c) end, String = "String" }
native.paNVMButton = "paNVMButton"
local function nsClass(name)
	-- class.Class reuses _CLASSES[name] and its metatable; ns then installs a
	-- one-shot __newindex that receives Bindings.
	local cls = _G._CLASSES[name] or {}
	local meta = getmetatable(cls) or {}
	meta.__call = function() end
	setmetatable(cls, meta)
	_G._CLASSES[name] = cls
	local got
	meta.__newindex = function(t, k, v) meta.__newindex = nil; got = v end
	return cls, function() return got end
end
local mainCls, mainGot = nsClass("MainNVM")
mainCls.Bindings = { Properties = { Casual = "orig" } }
local props = mainGot() and mainGot().Properties or {}
check("MainNVM keeps stock props", props.Casual == "orig")
check("MainNVM gains Page + tiles", props.Page == "String" and props.FocusRequest == "String" and props.CasualTeam == "type:paNVMButton" and props.OnlineMenu ~= nil and props.PageBack ~= nil)
local extraCls, extraGot = nsClass("ExtraNVM")
extraCls.Bindings = { Properties = {} }
check("ExtraNVM gains settings slots", extraGot().Properties.SettingsItem1 ~= nil and extraGot().Properties.SettingsItem12 ~= nil)
-- frontend reload: ns.Class runs again on the same class/metatable
local mainCls2, mainGot2 = nsClass("MainNVM")
mainCls2.Bindings = { Properties = {} }
check("re-registration after reload also injected", mainGot2().Properties.Page == "String")

-- 10. Pages ---------------------------------------------------------------
_G._CLASSES = {}
loadBlock()
local cls10 = Class("HomeScreenState")
function cls10.enter(self)
	self.view = "v"
	self.homescreenTilesData = homescreenstate_config.createFirstPageTiles()
	self.viewModel = { Main = {}, TabIndex = 0 }
	self.partyMember = "party"
end
function cls10.update(self) end
function cls10.exit(self) end
local s10 = newServices()
local released = false
function s10.checkForRelease(self, party, input) local r = released; released = false; return r end
function s10.playSound() end
function s10.getHighlightTitle() return nil end
local st10 = cls10()
st10:enter("sm", "engine", nil, {}, s10)
st10.viewModel.selectedItem = { stateData = { mainMenuPage = "Casual" } }
st10:update("sm", "engine", nil, 0.016, nil, s10)
check("page tile opens page", st10.viewModel.Main.Page == "Casual" and st10.viewModel.selectedItem == nil)
check("no focus request while page lays out", (st10.viewModel.Main.FocusRequest or "") == "")
st10:update("sm", "engine", nil, 0.016, nil, s10)
st10:update("sm", "engine", nil, 0.016, nil, s10)
check("focus request for the page after layout", st10.viewModel.Main.FocusRequest == "Casual")
st10:update("sm", "engine", nil, 0.016, nil, s10)
check("focus request cleared next frame", st10.viewModel.Main.FocusRequest == "")
check("exit prompt held off on a page", st10.canExitGameTimer < 0)
-- B that closes an open sub-menu must not also leave the page
st10.viewModel.subMenuOpen = true
st10:update("sm", "engine", nil, 0.016, nil, s10)
st10.viewModel.subMenuOpen = false
released = true
clock = clock + 0.016
st10:update("sm", "engine", nil, 0.016, nil, s10)
check("B closing a sub-menu stays on the page", st10.viewModel.Main.Page == "Casual")
clock = clock + 1
released = true
st10:update("sm", "engine", nil, 0.016, nil, s10)
st10:update("sm", "engine", nil, 0.016, nil, s10)
st10:update("sm", "engine", nil, 0.016, nil, s10)
check("B goes back, focus returns to the opener", st10.viewModel.Main.Page == "" and st10.viewModel.Main.FocusRequest == "@Casual")
check("exit prompt timer restored", st10.canExitGameTimer == 0)
st10.viewModel.selectedItem = { stateData = { mainMenuPage = "Competitions" } }
st10:update("sm", "engine", nil, 0.016, nil, s10)
check("competitions page", st10.viewModel.Main.Page == "Competitions")
st10.viewModel.TabIndex = 2
st10:update("sm", "engine", nil, 0.016, nil, s10)
check("tab change closes page", st10.viewModel.Main.Page == "")
st10.viewModel.selectedItem = { stateFactory = "X", stateData = { nextState = "Y" } }
st10:update("sm", "engine", nil, 0.016, nil, s10)
check("normal selections pass through", st10.viewModel.selectedItem ~= nil)
-- returning from a competition reopens its page
function s10.getHighlightTitle() return "RLWC2026" end
local st10b = cls10()
st10b:enter("sm", "engine", nil, {}, s10)
check("re-enter restores page of last tile", st10b.viewModel.Main.Page == "Competitions" and st10b.viewModel.FocusElementIdentifier == "RLWC2026")

print(string.format("%d passed, %d failed", passes, failures))
os.exit(failures == 0 and 0 or 1)
'''


def main():
    with open(MOD_FILE, "rb") as f:
        text = f.read().decode("utf-8-sig")
    start = text.find(MARKER)
    if start < 0:
        print("marker not found in " + MOD_FILE)
        return 1
    tmp = tempfile.mkdtemp(prefix="mainmenu_tests_")
    block_path = os.path.join(tmp, "block.lua")
    harness_path = os.path.join(tmp, "harness.lua")
    with open(block_path, "w", encoding="utf-8", newline="\n") as f:
        f.write(text[start:].replace("\r\n", "\n"))
    with open(harness_path, "w", encoding="utf-8", newline="\n") as f:
        f.write(HARNESS)
    result = subprocess.run([LUAJIT, harness_path, block_path], cwd=LUAJIT_CWD, capture_output=True, text=True)
    sys.stdout.write(result.stdout)
    sys.stderr.write(result.stderr)
    return result.returncode


if __name__ == "__main__":
    sys.exit(main())
