import("design.characters.assetmap")

-- official-jersey-editing: edits to an official club's own kits (the ones its on-disc
-- data has) don't survive a restart: the game restores them from the disc data when
-- the profile loads. So the jersey editor also writes each edited official kit's
-- changed options (those that differ from the disc kit) to OfficialKitEditsFile in
-- the game folder, and setupAcademyData writes them back once the profile's clubs are
-- set on the club manager. Keyed "<club id>|<kit name>".
OfficialKitEditsFile = "official_kit_edits.lua"

local var_0_ojeEdits

local function var_0_ojeLog(arg_text)
	pcall(function()
		local var_file = io.open("occasion_text_debug.txt", "a")

		if var_file then
			var_file:write(os.date("%H:%M:%S ") .. tostring(arg_text) .. "\n")
			var_file:close()
		end
	end)
end

local function var_0_ojeLoadEdits()
	if var_0_ojeEdits then
		return var_0_ojeEdits
	end

	var_0_ojeEdits = {}

	local var_file = io.open(OfficialKitEditsFile, "rb")

	if not var_file then
		return var_0_ojeEdits
	end

	local var_text = var_file:read("*a")

	var_file:close()

	local var_chunk = loadstring(var_text or "")

	if var_chunk then
		setfenv(var_chunk, {})

		local var_ok, var_value = pcall(var_chunk)

		if var_ok and type(var_value) == "table" then
			var_0_ojeEdits = var_value
		else
			var_0_ojeLog("official kit edits: couldn't read " .. OfficialKitEditsFile .. ": " .. tostring(var_value))
		end
	end

	return var_0_ojeEdits
end

local function var_0_ojeWriteEdits()
	local var_keys = {}

	for iter_key in pairs(var_0_ojeEdits) do
		table.insert(var_keys, iter_key)
	end

	table.sort(var_keys)

	local var_lines = { "-- official-jersey-editing: edited official kits (written by the game)", "return {" }

	for _, iter_key in ipairs(var_keys) do
		local var_options = {}

		for iter_option in pairs(var_0_ojeEdits[iter_key]) do
			table.insert(var_options, iter_option)
		end

		table.sort(var_options)
		table.insert(var_lines, string.format("\t[%q] = {", iter_key))

		for _, iter_option in ipairs(var_options) do
			local var_value = var_0_ojeEdits[iter_key][iter_option]

			table.insert(var_lines, string.format("\t\t[%q] = %s,", iter_option, type(var_value) == "string" and string.format("%q", var_value) or string.format("%.17g", var_value)))
		end

		table.insert(var_lines, "\t},")
	end

	table.insert(var_lines, "}")

	local var_file = io.open(OfficialKitEditsFile, "wb")

	if var_file then
		var_file:write(table.concat(var_lines, "\n") .. "\n")
		var_file:close()
	else
		var_0_ojeLog("official kit edits: couldn't write " .. OfficialKitEditsFile)
	end
end

local function var_0_ojeSame(arg_a, arg_b)
	if type(arg_a) == "number" and type(arg_b) == "number" then
		return math.abs(arg_a - arg_b) < 1e-6
	end

	return arg_a == arg_b
end

local function var_0_ojeOption(arg_cfg, arg_option)
	local var_ok, var_value = pcall(arg_cfg.getOption, arg_cfg, arg_option)

	if var_ok and (type(var_value) == "number" or type(var_value) == "string") then
		return var_value
	end
end

-- the disc copy of this club's kit with this name, if it has one
local function var_0_ojeDiscUniform(arg_universe, arg_clubId, arg_name)
	local var_club = arg_universe:getClubDatabaseOnDisc():getClub(arg_clubId)

	if not var_club then
		return nil
	end

	for iter_index = 1, var_club.uniformCount do
		local var_uniform = var_club:getUniform(iter_index)

		if var_uniform.name == arg_name then
			return var_uniform
		end
	end
end

-- called by the jersey editor on leaving an official club's kit
function saveOfficialKitEdits(arg_universe, arg_club, arg_uniform)
	local var_ok, var_error = pcall(function()
		local var_disc = var_0_ojeDiscUniform(arg_universe, arg_club.id, arg_uniform.name)

		if not var_disc then
			var_0_ojeLog("official kit edits: no disc kit " .. tostring(arg_uniform.name) .. " for club " .. tostring(arg_club.id))

			return
		end

		local var_changed = {}
		local var_count = 0

		for iter_option in pairs(assetmap.options.team) do
			local var_value = var_0_ojeOption(arg_uniform.config, iter_option)

			if var_value ~= nil and not var_0_ojeSame(var_value, var_0_ojeOption(var_disc.config, iter_option)) then
				var_changed[iter_option] = var_value
				var_count = var_count + 1
			end
		end

		local var_key = arg_club.id .. "|" .. arg_uniform.name

		var_0_ojeLoadEdits()[var_key] = var_count > 0 and var_changed or nil

		var_0_ojeWriteEdits()
		var_0_ojeLog("official kit edits: saved " .. var_key .. " (" .. var_count .. " options)")
	end)

	if not var_ok then
		var_0_ojeLog("official kit edits: save failed: " .. tostring(var_error))
	end
end

-- after the profile's clubs load: put the edits back on the official clubs' kits
function applyOfficialKitEdits(arg_uiServices)
	local var_byClub = {}

	for iter_key, iter_options in pairs(var_0_ojeLoadEdits()) do
		local var_id, var_name = string.match(iter_key, "^(%d+)|(.*)$")

		if var_id then
			var_id = tonumber(var_id)
			var_byClub[var_id] = var_byClub[var_id] or {}
			var_byClub[var_id][var_name] = iter_options
		end
	end

	local var_clubManager = arg_uiServices:getClubManager()

	if not var_clubManager or not var_clubManager.userCreated then
		var_0_ojeLog("official kit edits: club manager not ready")

		return
	end

	for iter_id, iter_kits in pairs(var_byClub) do
		local var_ok, var_error = pcall(function()
			local var_live = var_clubManager:getClub(iter_id)

			if not var_live then
				return
			end

			local var_club = native.CClub()

			var_club:set(var_live)

			local var_applied, var_differed = 0, 0

			for iter_index = 1, var_club.uniformCount do
				local var_uniform = var_club:getUniform(iter_index)
				local var_options = iter_kits[var_uniform.name]

				if var_options then
					for iter_option, iter_value in pairs(var_options) do
						if not var_0_ojeSame(var_0_ojeOption(var_uniform.config, iter_option), iter_value) then
							var_differed = var_differed + 1

							pcall(var_uniform.config.setOption, var_uniform.config, iter_option, iter_value)
						end

						var_applied = var_applied + 1
					end
				end
			end

			if var_differed > 0 then
				var_clubManager:saveCustomLicensed(var_club)
			end

			-- differed = options the load had reverted
			var_0_ojeLog("official kit edits: club " .. iter_id .. ": " .. var_applied .. " options, " .. var_differed .. " restored")
		end)

		if not var_ok then
			var_0_ojeLog("official kit edits: club " .. tostring(iter_id) .. " failed: " .. tostring(var_error))
		end
	end
end

function setupAcademyData(arg_1_0, arg_1_1, arg_1_2, arg_1_3)
	arg_1_2:setupAcademyData(arg_1_1)

	if arg_1_3 then
		arg_1_2.userAcademyData:processLoadedData(arg_1_3)
	end

	arg_1_2:initialiseCustomLicensedContent(arg_1_1)
	arg_1_0:runOnAllMixins("setAcademyData", arg_1_2.userAcademyData)

	-- official-jersey-editing: only once the club manager has the profile's clubs
	-- (setAcademyData); before that its custom-licensed store is unset and a lookup
	-- crashes natively, past pcall
	if arg_1_2.userAcademyData then
		pcall(applyOfficialKitEdits, arg_1_0)
	end

	local var_1_0 = arg_1_2.settings
	local var_1_1 = verifySavedTeams(arg_1_1, arg_1_0, var_1_0.casualHomeId)
	local var_1_2 = verifySavedTeams(arg_1_1, arg_1_0, var_1_0.casualAwayId)
	local var_1_3 = verifySavedTeams(arg_1_1, arg_1_0, var_1_0.casualHomeIdW)
	local var_1_4 = verifySavedTeams(arg_1_1, arg_1_0, var_1_0.casualAwayIdW)

	if not var_1_1 then
		var_1_0.casualHomeId = 118
	end

	if not var_1_2 then
		var_1_0.casualAwayId = 118
	end

	if not var_1_3 then
		var_1_0.casualHomeIdW = 32
	end

	if not var_1_4 then
		var_1_0.casualAwayIdW = 32
	end
end

function verifySavedTeams(arg_2_0, arg_2_1, arg_2_2)
	local var_2_0 = arg_2_1:getClubManager():getClub(arg_2_2)

	if not var_2_0 then
		return false
	end

	return var_2_0:getLineupCount() > 0
end

function toggleAcademyClubsEnabled(arg_3_0, arg_3_1, arg_3_2, arg_3_3)
	local var_3_0 = arg_3_3.settings

	var_3_0.academyClubsEnabled = not var_3_0.academyClubsEnabled

	arg_3_2:profileSaveSettings(arg_3_3)
	arg_3_2:runOnAllMixins("setAcademyData", var_3_0.academyClubsEnabled and arg_3_3.userAcademyData or nil)

	if var_3_0.HelpAcademyClubsEnabled then
		var_3_0.HelpAcademyClubsEnabled = false

		arg_3_2:blockingAlert(arg_3_0, arg_3_1, {
			options = "ok",
			canCancel = false,
			title = native.Localise("Help"),
			text = native.Localise("HelpAcademyClubsEnabled"),
			input = arg_3_3
		})
	end
end
