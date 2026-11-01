"""Offline tests for hia-protocol's HIAManager (no game needed).

Runs src/script-game/game/injury/injuryevent_listener.lua under the toolchain's LuaJIT with stubbed
natives: a fake match (one 13 + 4 side), a substitution entity that counts interchanges like the
native one is assumed to, and a stoppage step that carries out queued requests. Each test asserts
on HIAState, the interchange count and who is on the field.

    python mods\\hia-protocol\\test_hia.py          # all tests
    python mods\\hia-protocol\\test_hia.py -v       # also print hia_debug.txt

The mod's in-game test switches (HIATestEveryHighTackle, HIATestMinutes) are forced off in the
copy under test. build.py skips *.py in mod folders, so this file never goes into a bundle.
"""
import os
import re
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
MOD_LUA = os.path.join(HERE, "src", "script-game", "game", "injury", "injuryevent_listener.lua")

sys.path.insert(0, os.path.join(ROOT, "tools"))
import games  # noqa: E402

LUAJIT = games.toolchain("luajit", "bin", "luajit.exe")

HARNESS = r'''
local MOD = arg[1]

-- enums ----------------------------------------------------------------------------------------
local function enum(names)
	local e = {}
	for i, n in ipairs(names) do
		local v = setmetatable({ n = n, i = i - 1 }, { __tostring = function(s) return s.n end })
		v.toInt = function(s) return s.i end
		e[n] = v
		e[i - 1] = v
	end
	e.fromInt = function(self, i) return self[i] end
	return e
end

local R = enum({ "FullBack", "WingerLeft", "CentreLeft", "CentreRight", "WingerRight", "FiveEighth", "HalfBack", "PropLeft", "Hooker", "PropRight", "SecondRowLeft", "SecondRowRight", "Lock", "Substitute" })
local S = { InPlay = "InPlay", Sideline = "Sideline" }
local D = enum({ "Easiest", "Easy", "Medium", "Hard", "Hardest", "Custom" })
local MaxSubs = enum({ "Unlimited", "Four", "Eight", "Ten" })

local rolls = {}
native = {
	CSimulationRequest = { init = function() end },
	EAssignedRole = R,
	EInPlayState = S,
	EDifficulty = D,
	EMaxSubstitutionCounts = MaxSubs,
	EMatchType = { MT_Nines = "nines" },
	EGameMode = { Practice = "practice" },
	Random = { FromSystemTime = function() return { next = function() return table.remove(rolls, 1) or 50 end } end },
	PlayerRole = { getPreferredRoleForAssignedRole = function(r) return r.n end }
}

function VERIFY(x) return x end
function ASSERT() end
function import() end

function Class(name, ctor)
	local c = {}
	c.__index = c
	setmetatable(c, { __call = function(_, ...) local o = setmetatable({}, c); if ctor then ctor(o, ...) end; return o end })
	_G[name] = c
	return c
end

func = { bindmethod = function(o, m) return function(...) return m(o, ...) end end }
request = { requestclass = function(name, base, ctor) return Class(name, ctor) end }
types = { SignedInteger = "int" }
substitution_request = { SubstitutionRequest = function(t) t.kind = "sub"; return t end }
sidehelper = { home = 1, away = 2, sides = { 1, 2 } }
playertype = { TypeId = 1 }
injury_cconfig = { cInjuryConfig = { customDifficultyInjuryChanceModifier = 1 } }
sinbin_config = { sinbinStatus = { OnField = "OnField", SinBin = "SinBin" } }
interchange_config = { AllocatedPrimaryRoleWeight = 2, AllocatedSecondaryRoleWeight = 1.75, AllocatedTertiaryRoleWeight = 1.5, NonAllocatedRoleWeight = 0.5, InjuryWeights = { [0] = 1 } }

dofile(MOD)

-- world ----------------------------------------------------------------------------------------
local W

local function newWorld(opts)
	opts = opts or {}
	W = { players = {}, inPlay = {}, requests = {}, clock = 0, sinBinned = {} }

	local function add(id, role, pref, overall, sub)
		W.players[id] = { id = id, side = 1, identity = { surname = "P" .. id }, getDerivedAttribute = function() return 1 end }
		W.inPlay[id] = { role = sub and R.Substitute or role, inPlayState = sub and S.Sideline or S.InPlay }
		W.players[id].club = { primaryRole = pref, getOverallForRole = function(_, r) return r == pref and overall or overall * 0.5 end }
	end

	for i = 1, 13 do add(i, R[i - 1], R[i - 1].n, 70) end
	-- bench: a prop, a five-eighth, a centre, a hooker
	local bench = opts.bench or { { 14, "PropLeft", 75 }, { 15, "FiveEighth", 72 }, { 16, "CentreLeft", 74 }, { 17, "Hooker", 71 } }
	for _, b in ipairs(bench) do add(b[1], nil, b[2], b[3], true) end

	local e = { remaining = opts.remaining or 8, completed = 0, queue = {}, originalSubsNotInterchanged = {} }
	function e:getRemainingSubstitutions() return self.remaining end
	function e:getCompletedSubstitutions() return self.completed end
	function e:queuedSubstitutionsContains(id) for _, q in ipairs(self.queue) do if q.offId == id or q.onId == id then return true end end return false end
	function e:addSubstitutionAdditions(n) self.remaining = self.remaining + n end
	function e:getOriginalSubsInterchangedCount() return 0 end
	W.entity = e

	local maxSubs = opts.unlimited and MaxSubs.Unlimited or MaxSubs.Eight
	local difficulty = opts.custom and D.Custom or (opts.difficulty and D[opts.difficulty] or D.Medium)

	-- Like the engine's, gamestate and gameobjects only work inside the frame they were handed
	-- out in (an update, a tackle or a stoppage): keeping one for later is an error.
	local function live()
		if not W.inFrame then error("bad self (CGameEntityManager expected, got userdata): used outside its frame") end
	end
	W.gamestate = {
		getTeamSubstitutionEntityPair = function() live(); return { get = function() return e end } end,
		getInjuryPool = function() live(); return { get = function() return { severity = 0 } end } end,
		getSinBinInfoPool = function() live(); return { get = function(_, id) return { status = W.sinBinned[id] and "SinBin" or "OnField" } end } end,
		getTrainingEntity = function() live(); return { trainingActive = false } end
	}

	local idAssetMap = {}
	for id in pairs(W.players) do idAssetMap[id] = id end

	W.match = {
		matchInProgressData = { gameplayModifiers = { name = opts.custom, sliderMiscDifficulty = D[opts.difficulty or "Medium"].i } },
		getComponent = function(_, n)
			if n == "matchInData" then
				return { matchType = { maxSubstitutionCount = maxSubs, maxOriginalSubstitutesToSelect = MaxSubs.Unlimited }, difficulty = difficulty, gameMode = "normal",
					getClub = function() return { getPlayer = function(_, a) return W.players[a].club end } end }
			end
			return { timePeriodDuration = (opts.halfMinutes or 40) * 60, getMatchSecondsElapsed = function() return W.clock end }
		end,
		getSide = function() return { idAssetMap = idAssetMap, getIdAsset = function() return nil end } end
	}

	W.services = {
		knowledgeBank = { inPlayInfoPool = { get = function(_, id) return W.inPlay[id] end }, teamSubstitutionDecisionKnowledgePair = { get = function() return nil end } },
		pools = { staminaInfoPool = { get = function() return { stamina = 0.9 } end } }
	}
	W.gameobjects = { getGameObject = function(_, id) live(); return W.players[id] end }
	W.reqs = { add = function(_, r) table.insert(W.requests, r) end }

	local listener = InjuryEventListener()
	listener:registerWithMatchSim({ registerSolidEventListener = function() end, registerUpdateable = function(_, f) W.update = f end })
	return W
end

local function tick(seconds)
	W.clock = W.clock + (seconds or 0)
	W.inFrame = true
	W.update(nil, nil, W.services, nil, W.match, W.gamestate, W.gameobjects, 0.3, 0, W.reqs)
	W.inFrame = false
end

-- What referee-on-report's tackle_detect does on a high tackle penalty: live objects, mid-frame.
local function highTackle(id)
	W.inFrame = true
	HIAState.onHighTackle(id, 99, W.services, W.match, W.gamestate, W.gameobjects, 0)
	W.inFrame = false
end

-- The native job carries out queued interchanges at the next stoppage: each swap costs one.
local function stoppage()
	for _, r in ipairs(W.requests) do
		if r.kind == "sub" then
			local offRole = W.inPlay[r.offId].role
			W.inPlay[r.offId] = { role = R.Substitute, inPlayState = S.Sideline }
			W.inPlay[r.onId] = { role = offRole, inPlayState = S.InPlay }
			W.entity.completed = W.entity.completed + 1
			if W.entity.remaining then W.entity.remaining = W.entity.remaining - 1 end
		else
			W.inFrame = true
			r:apply(nil, W.gamestate)
			W.inFrame = false
		end
	end
	W.requests = {}
	tick(0)
end

local function count(kind)
	local n = 0
	for _, r in ipairs(W.requests) do if (r.kind or "free") == kind then n = n + 1 end end
	return n
end

local function eq(a, b, what)
	if a ~= b then error(string.format("%s: expected %s, got %s", what, tostring(b), tostring(a)), 2) end
end

local function onField(id) return W.inPlay[id].inPlayState == S.InPlay end

-- tests ----------------------------------------------------------------------------------------
local tests = {}

tests["pass: free swap off, 15 minutes, free swap back on"] = function()
	newWorld()
	rolls = { 10 }                    -- HIA: 10 < 25
	highTackle(9)      -- hooker (ids 1-13 = roles 0-12)
	tick(1)
	eq(#HIAState.cases, 1, "cases")
	eq(count("free"), 1, "free interchange requests")
	eq(count("sub"), 1, "swap requests")
	eq(HIAState.banners[1], "P9 OFF FOR HIA", "banner")
	stoppage()
	local c = HIAState.cases[1]
	eq(c.state, "off", "state after swap")
	eq(c.replacementId, 17, "replacement (bench hooker)")
	eq(onField(9), false, "P9 on field")
	eq(W.entity.remaining, 8, "interchanges left after HIA swap")
	eq(HIAState.isLocked(9), true, "P9 locked")
	eq(HIAState.isLocked(17), true, "replacement locked")
	tick(14 * 60)
	eq(c.state, "off", "state at 14 minutes")
	rolls = { 90 }                    -- pass: 90 >= 40 (Medium)
	tick(60)
	eq(c.state, "returning", "state at 15 minutes")
	eq(HIAState.banners[2], "P9 PASSED HIA", "pass banner")
	stoppage()
	eq(c.state, "done", "state after return")
	eq(onField(9), true, "P9 back on")
	eq(onField(17), false, "replacement off")
	eq(W.entity.remaining, 8, "interchanges left after return")
	eq(HIAState.isLocked(9) or HIAState.isLocked(17), false, "locks released")
	eq(HIAState.freeSwaps[1], 2, "free swaps counted")
end

tests["fail: out for the match"] = function()
	newWorld()
	rolls = { 0 }
	highTackle(7)
	tick(1); stoppage()
	rolls = { 10 }                    -- fail: 10 < 40
	tick(15 * 60)
	local c = HIAState.cases[1]
	eq(c.state, "failed", "state")
	eq(HIAState.banners[2], "P7 FAILED HIA", "fail banner")
	eq(count("sub"), 0, "no return swap")
	eq(HIAState.isLocked(7), true, "P7 locked for the match")
	eq(HIAState.isLocked(c.replacementId), false, "replacement free")
	tick(40 * 60)
	eq(c.state, "failed", "still failed later")
end

tests["no HIA when the roll misses"] = function()
	newWorld()
	rolls = { 30 }                    -- 30 >= 25
	highTackle(3)
	tick(1)
	eq(#HIAState.cases, 0, "cases")
	eq(#W.requests, 0, "requests")
end

tests["difficulty: Hardest x1.4 frequency, 60% fail rate"] = function()
	newWorld({ difficulty = "Hardest" })
	rolls = { 34 }                    -- 34 < 35 only at x1.4
	highTackle(3)
	tick(1); stoppage()
	eq(#HIAState.cases, 1, "HIA at Hardest")
	rolls = { 55 }                    -- 55 < 60: fails at Hardest
	tick(15 * 60)
	eq(HIAState.cases[1].state, "failed", "fails at Hardest")
end

tests["custom difficulty: sliders from the ini"] = function()
	local f = io.open("rl26_revamp_sliders.ini", "w")
	f:write("[My Diff]\nhia = on\nhia_frequency = 4.00\nhia_fail_rate = 0\n\n[Off Diff]\nhia = off\n")
	f:close()
	newWorld({ custom = "My Diff", difficulty = "Easiest" })
	rolls = { 95 }                    -- 95 < 25 x4 = 100
	highTackle(3)
	tick(1); stoppage()
	eq(#HIAState.cases, 1, "HIA at x4")
	rolls = { 0 }                     -- fail rate 0: always passes
	tick(15 * 60)
	eq(HIAState.cases[1].state, "returning", "passes at 0% fail rate")

	newWorld({ custom = "Off Diff" })
	rolls = { 0 }
	highTackle(3)
	tick(1)
	eq(#HIAState.cases, 0, "no HIA when switched off")

	newWorld({ custom = "Not In File", difficulty = "Hard" })
	rolls = { 29 }                    -- base Hard: 25 x1.2 = 30
	highTackle(3)
	tick(1)
	eq(#HIAState.cases, 1, "unsaved custom difficulty follows its base difficulty")
	os.remove("rl26_revamp_sliders.ini")
end

tests["short halves: 10-minute halves give a 3.75-minute HIA"] = function()
	newWorld({ halfMinutes = 10 })
	rolls = { 0 }
	highTackle(5)
	tick(1); stoppage()
	rolls = { 90 }
	tick(220)
	eq(HIAState.cases[1].state, "off", "before 225 s")
	tick(10)
	eq(HIAState.cases[1].state, "returning", "after 225 s")
end

tests["no bench player: no HIA, he plays on"] = function()
	newWorld({ bench = {} })
	rolls = { 0 }
	highTackle(5)
	tick(1)
	eq(#HIAState.cases, 0, "cases")
	eq(#W.requests, 0, "requests")
end

tests["replacement left the field: the HIA player stays on the bench"] = function()
	newWorld()
	rolls = { 0 }
	highTackle(10)
	tick(1); stoppage()
	local c = HIAState.cases[1]
	W.inPlay[c.replacementId].inPlayState = S.Sideline  -- e.g. sin-binned
	rolls = { 90 }
	tick(15 * 60)
	eq(c.state, "done", "state")
	eq(count("sub"), 0, "no return swap")
	eq(HIAState.isLocked(10), false, "P10 free to come back on normally")
end

tests["a second high tackle on the same player during his HIA is ignored"] = function()
	newWorld()
	rolls = { 0 }
	highTackle(4)
	tick(1)
	rolls = { 0 }
	highTackle(4)
	tick(1)
	eq(#HIAState.cases, 1, "cases")
	eq(count("sub"), 1, "swap requests")
end

tests["two HIAs at once use different bench players"] = function()
	newWorld()
	rolls = { 0, 0 }
	highTackle(8)
	highTackle(9)
	tick(1)
	eq(#HIAState.cases, 2, "cases")
	if HIAState.cases[1].replacementId == HIAState.cases[2].replacementId then
		error("both HIAs picked the same bench player")
	end
end

tests["unlimited interchanges: no free interchange request needed"] = function()
	newWorld({ unlimited = true })
	rolls = { 0 }
	highTackle(3)
	tick(1)
	eq(count("free"), 0, "free interchange requests")
	eq(count("sub"), 1, "swap requests")
end

tests["queued swap that never happens is dropped"] = function()
	newWorld()
	rolls = { 0 }
	highTackle(3)
	tick(1)
	W.requests = {}                   -- the native job never carries it out
	tick(601)
	eq(HIAState.cases[1].state, "cancelled", "state")
	eq(HIAState.isLocked(3), false, "lock released")
end

tests["concussion cutscene: handed to the next high tackle penalty once"] = function()
	newWorld()
	tick(1)                           -- the manager has run: decisions are immediate now
	rolls = { 0 }
	highTackle(6)
	eq(HIAState.cases[1].state, "pending", "decided at the tackle")
	eq(HIAState.isLocked(6), true, "locked while pending")
	eq(HIAState.takeConcussionCutscene(W.clock + 5), 6, "cutscene for the penalty")
	eq(HIAState.takeConcussionCutscene(W.clock + 6), nil, "only once")
	tick(1)
	eq(HIAState.cases[1].state, "queued", "swap queued on the next update")
	eq(count("sub"), 1, "swap requests")

	rolls = { 0 }
	highTackle(5)
	eq(HIAState.takeConcussionCutscene(W.clock + 500), nil, "too late for the penalty")

	rolls = { 99 }
	highTackle(4)
	eq(HIAState.takeConcussionCutscene(W.clock), nil, "no HIA, no cutscene")
end

tests["HIA Protocol off: immediate path does nothing either"] = function()
	local f = io.open("rl26_revamp_sliders.ini", "w")
	f:write("[Off Diff]\nhia = off\n")
	f:close()
	newWorld({ custom = "Off Diff" })
	tick(1)
	rolls = { 0 }
	highTackle(3)
	tick(1)
	eq(#HIAState.cases, 0, "cases")
	eq(HIAState.takeConcussionCutscene(W.clock), nil, "cutscene")
	os.remove("rl26_revamp_sliders.ini")
end

tests["no errors logged"] = function()
	local f = io.open("hia_debug.txt", "r")
	if not f then return end
	for line in f:lines() do
		if line:find("ERROR") then error("hia_debug.txt: " .. line) end
	end
	f:close()
end

local names = {}
for name in pairs(tests) do table.insert(names, name) end
table.sort(names)
local failed = 0
for i, name in ipairs(names) do
	if name == "no errors logged" then table.remove(names, i); table.insert(names, name); break end
end
for _, name in ipairs(names) do
	local ok, err = pcall(tests[name])
	print((ok and "PASS  " or "FAIL  ") .. name .. (ok and "" or ("\n      " .. tostring(err))))
	if not ok then failed = failed + 1 end
end
print(string.format("%d/%d passed", #names - failed, #names))
os.exit(failed == 0 and 0 or 1)
'''


def main():
    verbose = "-v" in sys.argv[1:]
    with tempfile.TemporaryDirectory() as tmp:
        harness = os.path.join(tmp, "hia_harness.lua")
        with open(harness, "w", encoding="utf-8", newline="\n") as f:
            f.write(HARNESS)
        # cwd = tmp so hia_debug.txt and the test ini land there, not in the game folder
        # A copy of the mod with its in-game test switches forced off, so the tests see normal play
        # whatever the switches are set to for in-game testing.
        with open(MOD_LUA, encoding="utf-8-sig") as f:
            source = f.read()
        source, n = re.subn(r"^local HIATestEveryHighTackle = .*$", "local HIATestEveryHighTackle = false", source, flags=re.M)
        source, m = re.subn(r"^local HIATestMinutes = .*$", "local HIATestMinutes = nil", source, flags=re.M)
        if n != 1 or m != 1:
            sys.exit("test switches not found in injuryevent_listener.lua")
        mod_copy = os.path.join(tmp, "injuryevent_listener.lua")
        with open(mod_copy, "w", encoding="utf-8", newline="\n") as f:
            f.write(source)
        result = subprocess.run([LUAJIT, harness, mod_copy], cwd=tmp, capture_output=True, text=True)
        sys.stdout.write(result.stdout)
        sys.stderr.write(result.stderr)
        log = os.path.join(tmp, "hia_debug.txt")
        if verbose and os.path.exists(log):
            print("\n--- hia_debug.txt ---")
            with open(log, encoding="utf-8") as f:
                sys.stdout.write(f.read())
    return result.returncode


if __name__ == "__main__":
    sys.exit(main())
