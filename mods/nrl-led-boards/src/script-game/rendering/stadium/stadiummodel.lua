Class("StadiumModel", function(arg_1_0)
	arg_1_0.modelsList = {}
	arg_1_0.textureList = {}
end)

function StadiumModel.dispose(arg_2_0)
	local var_2_0 = arg_2_0.modelsList

	if var_2_0 then
		arg_2_0.modelsList = nil

		for iter_2_0, iter_2_1 in pairs(var_2_0) do
			iter_2_1:dispose()
		end
	end

	local var_2_1 = arg_2_0.textureList

	if var_2_1 then
		arg_2_0.textureList = nil

		for iter_2_2, iter_2_3 in pairs(var_2_1) do
			iter_2_3:unload()
		end
	end

	local var_2_2 = arg_2_0.texpack

	if var_2_2 then
		var_2_2:unload()

		arg_2_0.texpack = nil
	end
end

function StadiumModel.loadFrom(arg_3_0, arg_3_1, arg_3_2, arg_3_3)
	local var_3_0 = arg_3_1:getAssetManager()
	local var_3_1 = arg_3_1:getAssetNotifier()
	local var_3_2 = arg_3_1:getTextureManager()
	local var_3_3 = arg_3_0.modelsList
	local var_3_4 = arg_3_3.texpack
	local var_3_5 = arg_3_3.models
	local var_3_6 = native.ModelLoader

	for iter_3_0, iter_3_1 in pairs(var_3_5) do
		assert(var_3_3[iter_3_0] == nil)

		local var_3_7 = native.CModelData.create()

		var_3_7.contributeToSkyLighting = true

		local var_3_8 = true
		local var_3_9 = var_3_6.load(var_3_0, iter_3_1, arg_3_2, var_3_7, var_3_8)

		var_3_9:addToRenderList(native.CRenderListType.glows)

		var_3_3[iter_3_0] = var_3_9
	end

	local var_3_10 = "textures/effects/clouds.texture"
	local var_3_11 = var_3_2:load(var_3_10)

	arg_3_0.textureList.cloudTexture = var_3_11

	local var_3_12 = arg_3_0.modelsList.field

	if var_3_12 then
		var_3_12:addToRenderList(native.CRenderListType.playerMarkersMask)
		var_3_12:addToRenderList(native.CRenderListType.undrawPlayerMarkersMask)
	end

	if var_3_4 then
		arg_3_0.texpack = var_3_2:loadPack(var_3_4)
	end

	-- nrl-led-boards: the home club's LED board (stadiumconfig.lua picks it).
	-- In textureList, so the join waits for it and dispose unloads it.
	local ledBoard = arg_3_3.ledBoard

	if ledBoard then
		arg_3_0.ledBoard = ledBoard
		arg_3_0.textureList.ledBoard = var_3_2:load(ledBoard.texture)
	end
end

local function ledLog(arg_msg)
	pcall(function()
		local file = io.open("ledboards_debug.txt", "a")

		if file then
			file:write(os.date("%H:%M:%S") .. " " .. arg_msg .. "\n")
			file:flush()
			file:close()
		end
	end)
end

-- Every LED material (technique es2_lcdsign) on every stadium model shows the
-- board. The material's row grid comes from the stock texture it shipped with
-- (gridRows / gridRows_active per ground), so it is set to the board's.
function StadiumModel.applyLedBoard(arg_led_0)
	local board = arg_led_0.ledBoard
	local texture = arg_led_0.textureList and arg_led_0.textureList.ledBoard

	if not board or not texture or not arg_led_0.modelsList then
		return
	end

	local materials = 0
	local failed = {}

	local function setFloat(arg_sv, arg_name, arg_value)
		if not pcall(function()
			arg_sv:setFloat(arg_name, arg_value)
		end) then
			failed[arg_name] = true
		end
	end

	for iter_name, iter_model in pairs(arg_led_0.modelsList) do
		local ok, err = pcall(function()
			iter_model:setShaderValues(function(arg_sv, arg_path)
				if arg_sv.technique and string.find(arg_sv.technique, "lcdsign", 1, true) then
					arg_sv:setTexture("col_map", texture)
					setFloat(arg_sv, "gridRows", board.rows)
					setFloat(arg_sv, "gridRows_active", board.rows)
					setFloat(arg_sv, "numRows", board.rows)
					setFloat(arg_sv, "startingRow", 0)
					setFloat(arg_sv, "persistTime", board.persistTime)
					setFloat(arg_sv, "transitionTime", board.transitionTime)

					materials = materials + 1
				end
			end)
		end)

		if not ok then
			ledLog("model " .. tostring(iter_name) .. ": " .. tostring(err))
		end
	end

	local failedNames = {}

	for iter_param in pairs(failed) do
		table.insert(failedNames, iter_param)
	end

	ledLog("board " .. board.name .. " (" .. board.rows .. " rows) on " .. materials .. " LED materials"
		.. (#failedNames > 0 and ("; setFloat failed: " .. table.concat(failedNames, ", ")) or ""))
end

function StadiumModel.isLoaded(arg_4_0)
	for iter_4_0, iter_4_1 in pairs(arg_4_0.modelsList) do
		if not iter_4_1:isLoaded() then
			return false
		end
	end

	return arg_4_0.texpack:isLoaded()
end

function StadiumModel.addToJoin(arg_5_0, arg_5_1)
	local var_5_0 = arg_5_0.modelsList
	local var_5_1 = arg_5_0.textureList
	local var_5_2 = arg_5_0.texpack

	for iter_5_0, iter_5_1 in pairs(var_5_0) do
		arg_5_1:addAsset(iter_5_1)
	end

	for iter_5_2, iter_5_3 in pairs(var_5_1) do
		arg_5_1:addAsset(iter_5_3)
	end

	if var_5_2 then
		arg_5_1:addAsset(var_5_2)
	end

	-- nrl-led-boards: queued before the stadium module's own fire callback, so
	-- it runs once every model and the board texture have loaded
	if arg_5_0.ledBoard then
		arg_5_1:addCallback(function()
			arg_5_0:applyLedBoard()
		end)
	end
end

function StadiumModel.getModel(arg_6_0, arg_6_1)
	return arg_6_0.modelsList[arg_6_1]
end
