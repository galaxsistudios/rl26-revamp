-- r25_dump.lua - run one cutscene-data module (LuaJIT bytecode or source)
-- with the game's globals stubbed, and print its CutsceneData table as JSON.
-- Used by r25_import.py; run as:  luajit r25_dump.lua <module file> [scripts root] [global]
-- ([global] defaults to CutsceneData; e.g. "groups" for emotiongroups.lua, or
-- "*globals" for every global table with an animsetName)
-- (the root lets import() load the modules a data file clones from).
--
-- native.* accesses become {"$expr": "native.X.Y"} markers (calls keep their
-- arguments, e.g. "native.CRange(1, 1)") so the Python side can write them
-- back out as Lua source unchanged.

local function expr(text)
	return setmetatable({ ["$expr"] = text }, { __expr = true })
end

local function fmtArg(v)
	if type(v) == "table" and rawget(v, "$expr") then
		return v["$expr"]
	elseif type(v) == "string" then
		return string.format("%q", v)
	end
	return tostring(v)
end

local function proxy(path)
	return setmetatable({ ["$expr"] = path }, {
		__index = function(_, k)
			return proxy(path .. "." .. k)
		end,
		__call = function(_, ...)
			local args = {}
			for i = 1, select("#", ...) do
				args[i] = fmtArg((select(i, ...)))
			end
			return expr(path .. "(" .. table.concat(args, ", ") .. ")")
		end
	})
end

local function deepclone(t)
	if type(t) ~= "table" or rawget(t, "$expr") then
		return t
	end
	local out = {}
	for k, v in pairs(t) do
		out[k] = deepclone(v)
	end
	return out
end

local root = arg[2]
local modules = {}

local function newEnv()
	local env = setmetatable({
		native = proxy("native"),
		tablex = {
			merge = function(a, b)
				for k, v in pairs(b or {}) do
					a[k] = v
				end
				return a
			end
		}
	}, {
		-- Unknown globals (sidehelper etc.) become proxies like native.*.
		__index = function(_, k)
			if _G[k] ~= nil then
				return _G[k]
			end
			return proxy(k)
		end
	})

	env.load = function(name)
		if name == "core.foundation.deepclone" then
			return { deepCloneTable = deepclone }
		end
		return proxy(name:match("([^.]+)$"))
	end
	env.loadTemp = env.load

	-- import("a.b.c") runs that module and exposes its globals as global c.
	env.import = function(name)
		local short = name:match("([^.]+)$")
		if not modules[name] and root then
			local chunk = loadfile(root .. "/" .. name:gsub("%.", "/") .. ".lua")
			if chunk then
				local modEnv = newEnv()
				modules[name] = modEnv
				setfenv(chunk, modEnv)
				pcall(chunk)
			end
		end
		rawset(env, short, modules[name] or proxy(short))
	end
	return env
end

local path = assert(arg[1], "usage: luajit r25_dump.lua <module file> [scripts root]")
local env = newEnv()
local chunk = assert(loadfile(path))
setfenv(chunk, env)
chunk()

local function isArray(t)
	local n = 0
	for _ in pairs(t) do
		n = n + 1
	end
	for i = 1, n do
		if t[i] == nil then
			return false
		end
	end
	return n > 0
end

local out = {}

local function enc(v)
	local tv = type(v)
	if tv == "table" then
		if rawget(v, "$expr") then
			out[#out + 1] = '{"$expr":' .. string.format("%q", v["$expr"]):gsub("\\\n", "\\n") .. "}"
		elseif isArray(v) then
			out[#out + 1] = "["
			for i = 1, #v do
				if i > 1 then
					out[#out + 1] = ","
				end
				enc(v[i])
			end
			out[#out + 1] = "]"
		else
			out[#out + 1] = "{"
			local first = true
			for k, x in pairs(v) do
				if not first then
					out[#out + 1] = ","
				end
				first = false
				out[#out + 1] = string.format("%q", tostring(k)) .. ":"
				enc(x)
			end
			out[#out + 1] = "}"
		end
	elseif tv == "string" then
		out[#out + 1] = (string.format("%q", v):gsub("\\\n", "\\n"))
	elseif tv == "number" then
		out[#out + 1] = string.format("%.14g", v)
	elseif tv == "boolean" then
		out[#out + 1] = tostring(v)
	else
		out[#out + 1] = "null"
	end
end

local result
if arg[3] == "*globals" then
	-- legacy files (design/cutscenes/cutscenes_config.lua) define each
	-- cutscene as its own global table rather than inside CutsceneData
	result = {}
	for k, v in pairs(env) do
		if type(v) == "table" and not rawget(v, "$expr") and rawget(v, "animsetName") then
			result[k] = v
		end
	end
else
	result = rawget(env, arg[3] or "CutsceneData") or {}
end
enc(result)
io.write(table.concat(out))
