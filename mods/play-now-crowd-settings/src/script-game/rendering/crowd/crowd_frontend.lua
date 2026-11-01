Class("CrowdFrontend", function(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5)
	local var_1_0 = arg_1_1:getAssetManager()
	local var_1_1 = arg_1_1:getTextureManager()
	local var_1_2 = arg_1_1:getJobManager()
	local var_1_3 = arg_1_1:getRenderInterface()
	local var_1_4 = arg_1_1:getGraphicsSettings()
	local var_1_5 = loadTemp("intermediatelua.crowd.crowd_item_config")

	var_1_5.archetypes.active = var_1_5.archetypes.frontend

	local var_1_6 = var_1_4.crowdQuality
	local var_1_7 = false
	local var_1_8 = native.CCrowdScene(var_1_3, var_1_0, var_1_1, var_1_2, var_1_6, var_1_4.crowdCapacity)

	-- play-now-crowd-settings: its exe patch makes the home/away split read the scene's
	-- padding dword (setLODRatio index 7), which isn't initialised - 0 is the stock split
	pcall(function()
		var_1_8:setLODRatio(7, 0)
	end)

	var_1_8:init(arg_1_3, "crowd/nodefiles/" .. arg_1_5 .. "_crowdnodes.nodefile", "", var_1_5, "", 0, "", "", nil, nil, nil, nil)

	arg_1_2.crowdScene = var_1_8
	arg_1_0.crowdScene = var_1_8
	arg_1_0.renderer = arg_1_2
	arg_1_0.onReload = _G.registerOnReload(function()
		arg_1_0.crowdScene:setWantRebuild()
	end)
end)

function CrowdFrontend.updateLoading(arg_3_0)
	return arg_3_0.crowdScene:updateLoading()
end

function CrowdFrontend.dispose(arg_4_0)
	arg_4_0.crowdScene:dispose()

	arg_4_0.crowdScene = nil
	arg_4_0.renderer.crowdScene = nil
end

function CrowdFrontend.update(arg_5_0, arg_5_1)
	arg_5_0.crowdScene:update(arg_5_1)
end

function CrowdFrontend.getCrowdScene(arg_6_0)
	return arg_6_0.crowdScene
end

function CrowdFrontend.setEnabled(arg_7_0, arg_7_1)
	arg_7_0.crowdScene:setEnableRender(arg_7_1)
end
