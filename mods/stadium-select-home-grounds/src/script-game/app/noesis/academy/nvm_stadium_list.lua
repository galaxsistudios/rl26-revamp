import("app.noesis.util.noesis_texture_batch_converter")
import("app.noesis.ns")
import("app.noesis.ns_viewmodel")
import("app.noesis.ns_observablecollection")
import("app.match.stadium_helper")

local var_0_0 = ns_viewmodel.ViewModel
local var_0_1 = ns_observablecollection.ObservableCollection
local var_0_2 = {
	"stadiumAustralia",
	"manchesterStadium"
}
local var_0_3 = ns.Class("NVMStadiumListItem", var_0_0, function(arg_1_0)
	var_0_0.init(arg_1_0)
end)

var_0_3.Bindings = {
	Namespace = "Workspace.ViewModels.Academy",
	Properties = {
		Name = ns.String,
		IsClubGround = ns.Bool,
		ClubColour = ns.Color,
		ClubTextColour = ns.Color,
		ClubLogo = ns.typeOf(native.CNoesisTextureSource)
	}
}

function var_0_3.dispose(arg_2_0)
	if arg_2_0.clubLogoConverter then
		arg_2_0.clubLogoConverter:dispose()

		arg_2_0.clubLogoConverter = nil
	end

	if arg_2_0.ClubLogo then
		arg_2_0.ClubLogo:dispose()
	end

	var_0_0.dispose(arg_2_0)
end

-- Home/away ground rows: club primary colour background, logo, readable text colour
function var_0_3.setClub(arg_2_0, arg_2_1, arg_2_2, arg_2_3)
	local var_2_0 = arg_2_1.primaryColour or {
		r = 25,
		g = 25,
		b = 25
	}

	arg_2_0.IsClubGround = true
	arg_2_0.ClubColour = native.NsColor(var_2_0.r, var_2_0.g, var_2_0.b, 255)

	if var_2_0.r * 0.299 + var_2_0.g * 0.587 + var_2_0.b * 0.114 > 170 then
		arg_2_0.ClubTextColour = native.NsColor(0, 0, 0, 255)
	else
		arg_2_0.ClubTextColour = native.NsColor(255, 255, 255, 255)
	end

	if not arg_2_1.decalIdOrIcon then
		return
	end

	arg_2_0.clubLogoConverter = noesis_texture_batch_converter.NoesisTextureBatchConverter(arg_2_2, arg_2_0)

	arg_2_0.clubLogoConverter:setMap({
		ClubLogo = arg_2_1.decalIdOrIcon:createTexture(arg_2_3:getDecalManager(), arg_2_2:getDecalRender(), arg_2_2:getTextureManager(), "small")
	})
end

function var_0_3.setName(arg_3_0, arg_3_1)
	arg_3_0.Name = arg_3_1 or ""
end

function var_0_3.setCustomStadiumData(arg_4_0, arg_4_1)
	arg_4_0.customStadiumData = arg_4_1
end

function var_0_3.getCustomStadiumData(arg_5_0)
	return arg_5_0.customStadiumData
end

function var_0_3.setOnDiscStadiumData(arg_6_0, arg_6_1)
	arg_6_0.onDiscStadiumData = arg_6_1
end

function var_0_3.getOnDiscStadiumData(arg_7_0)
	return arg_7_0.onDiscStadiumData
end

local var_0_4 = ns.Class("NVMStadiumSelectViewTabItem", var_0_0, function(arg_8_0, arg_8_1, arg_8_2, arg_8_3)
	var_0_0.init(arg_8_0)

	arg_8_0.StadiumListItems = var_0_1()
	arg_8_0.Header = ""
	arg_8_0.StadiumListSelectedIndex = 0
end)

var_0_4.Bindings = {
	Namespace = "Workspace.ViewModels.Academy",
	Properties = {
		StadiumListItems = ns.typeOf(var_0_1),
		Header = ns.String,
		StadiumListSelectedIndex = ns.Int32,
		StadiumListSelectionChangedCommand = ns.typeOf(native.CIsActiveWrapperCommand),
		Repopulate = ns.Bool
	}
}

function var_0_4.dispose(arg_9_0)
	var_0_0.dispose(arg_9_0)
end

function var_0_4.setHeader(arg_10_0, arg_10_1)
	arg_10_0.Header = arg_10_1 or ""
end

function var_0_4.getSelectedItem(arg_11_0)
	local var_11_0 = arg_11_0.StadiumListSelectedIndex or 0

	if var_11_0 < 0 then
		return nil
	end

	return arg_11_0.StadiumListItems:getComponent(var_11_0 + 1)
end

local function var_0_5(arg_12_0, arg_12_1)
	local var_12_0 = arg_12_0 and arg_12_0.identity
	local var_12_2 = {}

	if not var_12_0 then
		return var_12_2
	end

	for iter_12_0 = 1, var_12_0.groundCount do
		local var_12_1 = native.Stadiums.getKey(var_12_0:getGround(iter_12_0).stadium)

		for iter_12_1, iter_12_2 in ipairs(arg_12_1) do
			if iter_12_2.stadium == var_12_1 then
				table.insert(var_12_2, iter_12_2)

				break
			end
		end
	end

	return var_12_2
end

-- arg_12_2 = { home = club, away = club } puts each club's on-disc home grounds (in club order) at the top
function var_0_4.populateWithOnDiscStadiums(arg_12_0, arg_12_1, arg_12_2, arg_12_3)
	arg_12_0.StadiumListSelectedIndex = 0

	arg_12_0.StadiumListItems:dispose()

	local var_12_0 = arg_12_1:getLevelManager():getUIStadiumsAsTable(false, false, false)

	table.sort(var_12_0, function(arg_13_0, arg_13_1)
		return arg_13_0.label < arg_13_1.label
	end)

	if arg_12_2 and arg_12_3 then
		local var_12_3 = {}

		for iter_12_3, iter_12_4 in ipairs({
			arg_12_2.home,
			arg_12_2.away
		}) do
			for iter_12_5, var_12_4 in ipairs(var_0_5(iter_12_4, var_12_0)) do
				if not var_12_3[var_12_4.stadium] then
					var_12_3[var_12_4.stadium] = true

					local var_12_5 = var_0_3()

					var_12_5:setName(native.Localise("MatchSettings_Ground_" .. var_12_4.stadium))
					var_12_5:setOnDiscStadiumData(var_12_4)
					var_12_5:setClub(iter_12_4, arg_12_3, arg_12_1)
					arg_12_0.StadiumListItems:addItem(var_12_5)
				end
			end
		end
	end

	for iter_12_0, iter_12_1 in ipairs(var_12_0 or {}) do
		local var_12_1 = var_0_3()
		local var_12_2 = iter_12_1.stadium

		var_12_1:setName(native.Localise("MatchSettings_Ground_" .. var_12_2))
		var_12_1:setOnDiscStadiumData(iter_12_1)
		arg_12_0.StadiumListItems:addItem(var_12_1)
	end
end

function var_0_4.populateWithGrandFinalStadiums(arg_14_0, arg_14_1)
	arg_14_0.StadiumListSelectedIndex = 0

	arg_14_0.StadiumListItems:dispose()

	local var_14_0 = arg_14_1:getLevelManager():getGrandFinalStadiumsAsTable()

	for iter_14_0, iter_14_1 in ipairs(var_14_0) do
		local var_14_1 = var_0_3()
		local var_14_2 = iter_14_1.stadium

		var_14_1:setName(native.Localise("MatchSettings_Ground_" .. var_14_2))
		var_14_1:setOnDiscStadiumData(iter_14_1)
		arg_14_0.StadiumListItems:addItem(var_14_1)
	end
end

function var_0_4.populateWithCustomStadiums(arg_15_0, arg_15_1, arg_15_2, arg_15_3)
	arg_15_0.StadiumListSelectedIndex = 0

	arg_15_0.StadiumListItems:dispose()

	arg_15_0.wantUserCreatedStadiums = arg_15_2
	arg_15_0.wantDownloadedStadiums = arg_15_3

	local var_15_0 = arg_15_1:getLevelManager().academyLevelManager
	local var_15_1 = var_15_0:getAllLevels(arg_15_2, true, arg_15_3, -1)

	for iter_15_0, iter_15_1 in ipairs(var_15_1 or {}) do
		local var_15_2 = var_15_0:getLevel(iter_15_1)

		if var_15_2 then
			local var_15_3 = var_0_3()

			var_15_3:setName(var_15_2.name)
			var_15_3:setCustomStadiumData(var_15_2)
			arg_15_0.StadiumListItems:addItem(var_15_3)
		end
	end
end

function var_0_4.refreshCustomStadiumList(arg_16_0, arg_16_1)
	arg_16_0:populateWithCustomStadiums(arg_16_1, arg_16_0.wantUserCreatedStadiums, arg_16_0.wantDownloadedStadiums)
end

function var_0_4.refresh(arg_17_0)
	arg_17_0.repopulate = true
end

function var_0_4.update(arg_18_0)
	if arg_18_0.repopulate then
		arg_18_0.Repopulate = true
		arg_18_0.repopulate = false
	end

	if arg_18_0.Repopulate then
		arg_18_0.Repopulate = false
	end
end

ns.Class("paNVMStadiumSelectView", var_0_0, function(arg_19_0, arg_19_1)
	ASSERT(arg_19_1)
	var_0_0.init(arg_19_0)

	arg_19_0.TabItems = var_0_1()
	arg_19_0.SelectedTabIndex = 0
	arg_19_0.texConverter = noesis_texture_batch_converter.NoesisTextureBatchConverter(arg_19_1, arg_19_0)
end).Bindings = {
	Namespace = "Workspace.ViewModels.Academy",
	Properties = {
		StadiumTexture = ns.typeOf(native.CNoesisTextureSource),
		TabItems = ns.typeOf(var_0_1),
		SelectedTabIndex = ns.Int32
	}
}

function paNVMStadiumSelectView.update(arg_20_0, arg_20_1, arg_20_2, arg_20_3)
	arg_20_0:updateCustomStadiumTexture(arg_20_1, arg_20_3)

	local var_20_0 = arg_20_0.TabItems

	if var_20_0 then
		for iter_20_0, iter_20_1 in var_20_0:iter() do
			iter_20_1:update()
		end
	end
end

function paNVMStadiumSelectView.dispose(arg_21_0)
	if arg_21_0.imageTask ~= nil then
		arg_21_0.imageTask:cancel()
		arg_21_0.imageTask:dispose()

		arg_21_0.imageTask = nil
	end

	arg_21_0.texConverter:dispose()
	var_0_0.dispose(arg_21_0)
end

function paNVMStadiumSelectView.getSelectedTab(arg_22_0)
	local var_22_0 = arg_22_0.SelectedTabIndex or 0

	if var_22_0 < 0 then
		return nil
	end

	return arg_22_0.TabItems:getComponent(var_22_0 + 1)
end

function paNVMStadiumSelectView.addTabItem(arg_23_0, arg_23_1, arg_23_2, arg_23_3)
	local var_23_0 = var_0_4(arg_23_2, arg_23_3)

	var_23_0:setHeader(arg_23_1)

	var_23_0.StadiumListSelectionChangedCommand = native.CIsActiveWrapperCommand(native.CLuaDelegateCommand(function()
		arg_23_0:setStadiumPreviewTexture(arg_23_2, arg_23_3)
	end))

	arg_23_0.TabItems:addItem(var_23_0)

	return var_23_0
end

function paNVMStadiumSelectView.clearStadiumTexture(arg_25_0)
	local var_25_0 = arg_25_0.StadiumTexture

	if var_25_0 then
		var_25_0:dispose()
	end
end

function paNVMStadiumSelectView.getCurrentTabSelectedItem(arg_26_0)
	local var_26_0 = arg_26_0.SelectedTabIndex or 0

	if var_26_0 < 0 then
		return nil
	end

	local var_26_1 = arg_26_0.TabItems:getComponent(var_26_0 + 1)

	return var_26_1 and var_26_1:getSelectedItem() or nil
end

function paNVMStadiumSelectView.setStadiumPreviewTexture(arg_27_0, arg_27_1, arg_27_2)
	local var_27_0 = arg_27_0:getCurrentTabSelectedItem()

	if var_27_0 then
		local var_27_1 = var_27_0:getCustomStadiumData()

		if var_27_1 then
			local var_27_2 = arg_27_2:getImageStore()
			local var_27_3 = var_27_1:getData().levelIcon

			if arg_27_0.imageTask then
				arg_27_0.imageTask:cancel()

				arg_27_0.imageTask = nil
			end

			arg_27_0.imageTask = var_27_2:getImage(var_27_3, native.EImageType.Stadium)
		else
			local var_27_4 = var_27_0:getOnDiscStadiumData()

			if var_27_4 then
				local var_27_5 = stadium_helper.getGroundTextureString(var_27_4.stadium)

				arg_27_0.texConverter:setMap({
					StadiumTexture = var_27_5
				})
			end
		end
	else
		arg_27_0:clearStadiumTexture()
	end
end

function paNVMStadiumSelectView.updateCustomStadiumTexture(arg_28_0, arg_28_1, arg_28_2)
	local var_28_0 = arg_28_1:getTextureManager()

	if arg_28_0.imageTask and arg_28_0.imageTask:update(arg_28_2) then
		if arg_28_0.imageTask:getStatus() == native.ETaskStatus.success then
			local var_28_1 = arg_28_0:getCurrentTabSelectedItem()

			if var_28_1 then
				local var_28_2 = var_28_1:getCustomStadiumData()

				if var_28_2 then
					local var_28_3 = arg_28_0.imageTask:getImage()
					local var_28_4 = native.CImageFns.createTexture(var_28_0, var_28_3, "textureCustomStadium." .. var_28_2.id)

					arg_28_0.texConverter:setMap({
						StadiumTexture = var_28_4
					})
				end
			end
		else
			local var_28_5 = arg_28_0.imageTask:getLastError()

			print(var_28_5.errorString)
			arg_28_0.texConverter:setMap({
				StadiumTexture = "ui/textures/stadium_images/random.texture"
			})
		end

		arg_28_0.imageTask:dispose()

		arg_28_0.imageTask = nil
	end
end

function paNVMStadiumSelectView.refreshTabsShowingCustomStadiums(arg_29_0, arg_29_1)
	local var_29_0 = arg_29_0.TabItems

	if var_29_0 then
		for iter_29_0, iter_29_1 in var_29_0:iter() do
			iter_29_1:refreshCustomStadiumList(arg_29_1)
		end
	end
end

function paNVMStadiumSelectView.refreshCurrentTab(arg_30_0, arg_30_1)
	local var_30_0 = arg_30_0:getSelectedTab()

	if var_30_0 then
		var_30_0:refresh()
	end
end
