import("app.save.save_helper")
import("app.metagamemode.metagamemode_load")
import("app.save.save_scanner")
import("base.ui.busy.busy_layout")
import("base.ui.defaults")
import("base.ui.optionmenu.optionmenu_aide")
import("base.ui.optionmenu.optionmenu_state")
import("core.statemachine.statemachine")
import("uicore.uiutil")

local var_0_0 = native.InputTypes
local var_0_1 = native.InputTypes.Start
local var_0_2 = native.SaveDataCompressorDataType
local var_0_3 = {
	[var_0_2.ProfileAlwaysResident] = true,
	[var_0_2.FrontEndData] = true
}
local var_0_4 = {
	UploadFailed = 3,
	UploadSuccessful = 2,
	ScanFinished = 1
}
local var_0_5 = save_scanner.ScanForSaves

Class("ScanState", var_0_5)

ScanState.WantAlertWhenCantCreate = false
ScanState.MaxSaves = 10

function ScanState.enter(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7, arg_1_8)
	arg_1_0.SaveHelperKey = arg_1_6

	var_0_5.enter(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_7, arg_1_8)
end

function ScanState.update(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9)
	var_0_5.update(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9)

	if arg_2_0.exitAt then
		local var_2_0 = VERIFY(arg_2_0.fileListLoader)
		local var_2_1 = VERIFY(var_2_0:getResultsTable())

		return (VERIFY(var_2_1.saveListResults))
	end
end

local var_0_6 = metagamemode_load.MetagameModeLoad

Class("LoadState", var_0_6)

function LoadState.enter(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	arg_3_0.stateData = {}

	var_0_6.enter(arg_3_0, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
end

function LoadState.updateObjectCreation(arg_4_0, arg_4_1, arg_4_2, arg_4_3)
	return true
end

function LoadState.loadSuccess(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4)
	arg_5_0.stateData.loadDataBuffer = arg_5_4
end

function LoadState.update(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8)
	if var_0_6.update(arg_6_0, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8) then
		return arg_6_0.stateData.loadDataBuffer, true
	end
end

Class("ScanAllConfigs")

function ScanAllConfigs.enter(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7)
	arg_7_0.stateMachine = statemachine.StateMachine("ScanAllConfigs")
	arg_7_0.existingSaveFiles = {}

	local var_7_0 = {}

	for iter_7_0, iter_7_1 in pairs(save_helper.SaveConfigs) do
		local var_7_1 = native.SaveDataCompressorDataType[iter_7_0]

		if var_7_1 and not iter_7_1.disallowUpload then
			table.insert(var_7_0, {
				scan = true,
				partyMember = arg_7_6,
				mode = iter_7_0,
				modeEnum = var_7_1
			})
		end
	end

	arg_7_0.stateData = var_7_0
	arg_7_0.scanData = arg_7_7
end

function ScanAllConfigs.exit(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4)
	if arg_8_0.stateMachine:getCurrentState() then
		arg_8_0.area:dispose()

		arg_8_0.area = nil

		arg_8_0.stateMachine:changeState(nil, arg_8_1, arg_8_2, arg_8_3, arg_8_4)
	end
end

function ScanAllConfigs.update(arg_9_0, arg_9_1, arg_9_2, arg_9_3, arg_9_4, arg_9_5, arg_9_6, arg_9_7, arg_9_8, arg_9_9)
	if arg_9_0.area then
		arg_9_0.area:update(arg_9_4)
	end

	if arg_9_0.stateMachine:getCurrentState() then
		local var_9_0 = arg_9_0.metagameModeData
		local var_9_1 = arg_9_0.stateMachine:update(arg_9_2, arg_9_3, arg_9_4, arg_9_5, arg_9_6, arg_9_7, var_9_0, arg_9_0.scanData)

		if var_9_1 then
			local var_9_2 = arg_9_0.scanData

			arg_9_0.scanData[var_9_0.mode] = var_9_1

			arg_9_0.area:dispose()

			arg_9_0.area = nil

			arg_9_0.stateMachine:changeState(nil, arg_9_2, arg_9_3, arg_9_5, arg_9_6)
		else
			return
		end
	end

	if #arg_9_0.stateData > 0 then
		arg_9_0.metagameModeData = table.remove(arg_9_0.stateData, 1)

		arg_9_0.stateMachine:changeState(ScanState(), arg_9_2, arg_9_3, arg_9_5, arg_9_6, arg_9_0.metagameModeData.mode, arg_9_0.metagameModeData, arg_9_0.stateData)

		local var_9_3 = string.format(native.Localise("ScanningForSaveFilesMode"), native.Localise(arg_9_0.metagameModeData.mode))

		arg_9_0.area = busy_layout.create(arg_9_2, var_9_3, "", false, {
			instant = true
		})
	else
		return var_0_4.ScanFinished
	end
end

function ScanAllConfigs.render(arg_10_0, arg_10_1, arg_10_2, arg_10_3, arg_10_4)
	if arg_10_0.area then
		arg_10_0.area:doRender(arg_10_1, arg_10_4)
	end
end

Class("CompressDataState")

function CompressDataState.enter(arg_11_0, arg_11_1, arg_11_2, arg_11_3, arg_11_4, arg_11_5, arg_11_6, arg_11_7)
	arg_11_0.stateMachine = statemachine.StateMachine("CompressDataState")
	arg_11_0.saveDataCompressor = native.CSaveDataCompressor(arg_11_2)
	arg_11_0.stateData = arg_11_6
	arg_11_0.nextState = arg_11_7
end

function CompressDataState.exit(arg_12_0, arg_12_1, arg_12_2, arg_12_3, arg_12_4, arg_12_5)
	if arg_12_0.area then
		arg_12_0.area:dispose()

		arg_12_0.area = nil
	end

	arg_12_0.stateMachine:changeState(nil, arg_12_1, arg_12_2, arg_12_3, arg_12_4)
end

function CompressDataState.update(arg_13_0, arg_13_1, arg_13_2, arg_13_3, arg_13_4, arg_13_5, arg_13_6, arg_13_7, arg_13_8, arg_13_9)
	if arg_13_0.area then
		arg_13_0.area:update(arg_13_4)
	end

	local var_13_0 = arg_13_0.saveDataCompressor

	if arg_13_0.stateMachine:getCurrentState() then
		local var_13_1, var_13_2 = arg_13_0.stateMachine:update(arg_13_2, arg_13_3, arg_13_4, arg_13_5, arg_13_6, arg_13_7, arg_13_9)

		if var_13_1 then
			local var_13_3 = arg_13_0.loadData
			local var_13_4 = var_13_3.saveFileInfo

			var_13_0:addData(var_13_3.modeEnum, var_13_1, var_13_4)

			if arg_13_0.area then
				arg_13_0.area:dispose()

				arg_13_0.area = nil
			end

			arg_13_0.stateMachine:changeState(nil, arg_13_2, arg_13_3, arg_13_5, arg_13_6)
		elseif var_13_2 then
			if arg_13_0.area then
				arg_13_0.area:dispose()

				arg_13_0.area = nil
			end

			arg_13_0.stateMachine:changeState(nil, arg_13_2, arg_13_3, arg_13_5, arg_13_6)
		else
			return
		end
	end

	if #arg_13_0.stateData > 0 then
		local var_13_5 = table.remove(arg_13_0.stateData, 1)
		local var_13_6 = var_13_5.saveFileInfo
		local var_13_7 = true
		local var_13_8 = var_13_6.compressedSize

		arg_13_0.stateMachine:changeState(LoadState(), arg_13_2, arg_13_3, arg_13_5, arg_13_6, var_13_5.saveHelperKey, arg_13_9, var_13_6.mountName, var_13_6.subFileName, var_13_7, var_13_8)

		arg_13_0.loadData = var_13_5

		local var_13_9 = string.format(native.Localise("LoadingSaveFileMode"), native.Localise(var_13_5.saveHelperKey))

		arg_13_0.area = busy_layout.create(arg_13_2, var_13_9, "", false, {
			instant = true
		})
	else
		local var_13_10 = var_13_0:createDataBuffer(arg_13_9)
		local var_13_11 = {
			saveDataCompressor = var_13_0,
			dataBuffer = var_13_10,
			partyMember = arg_13_9
		}

		arg_13_1:changeState(arg_13_0.nextState(), arg_13_2, arg_13_3, arg_13_5, arg_13_6, var_13_11)
	end
end

function CompressDataState.render(arg_14_0, arg_14_1, arg_14_2, arg_14_3, arg_14_4)
	if arg_14_0.area then
		arg_14_0.area:doRender(arg_14_1, arg_14_4)
	end
end

Class("WriteToFileState")

function WriteToFileState.enter(arg_15_0, arg_15_1, arg_15_2, arg_15_3, arg_15_4, arg_15_5, arg_15_6)
	arg_15_0.saveDataCompressor = arg_15_6.saveDataCompressor
	arg_15_0.dataBuffer = arg_15_6.dataBuffer

	arg_15_0.saveDataCompressor:writeToFile(arg_15_0.dataBuffer)

	arg_15_0.area = busy_layout.create(arg_15_2, native.Localise("WritingToFile"), "", false, {
		instant = true
	})
	arg_15_0.stayUntil = arg_15_3 + 1
end

function WriteToFileState.exit(arg_16_0, arg_16_1, arg_16_2, arg_16_3, arg_16_4, arg_16_5)
	arg_16_0.area:dispose()
end

function WriteToFileState.update(arg_17_0, arg_17_1, arg_17_2, arg_17_3, arg_17_4, arg_17_5, arg_17_6, arg_17_7, arg_17_8, arg_17_9)
	arg_17_0.area:update(arg_17_4)

	if arg_17_3 >= arg_17_0.stayUntil then
		return true
	end
end

function WriteToFileState.render(arg_18_0, arg_18_1, arg_18_2, arg_18_3, arg_18_4)
	arg_18_0.area:doRender(arg_18_1, arg_18_4)
end

Class("UploadToServerState")

function UploadToServerState.enter(arg_19_0, arg_19_1, arg_19_2, arg_19_3, arg_19_4, arg_19_5, arg_19_6)
	arg_19_0.dataBuffer = arg_19_6.dataBuffer
	arg_19_0.getInfoTask = native.CSharingSaveDataGet(arg_19_2:getUserManager(), arg_19_2:getHttpRequestHandlerService(), 0)
	arg_19_0.flag = false
	arg_19_0.area = busy_layout.create(arg_19_2, native.Localise("UploadingToServer"), "", false, {
		instant = true
	})
end

function UploadToServerState.exit(arg_20_0, arg_20_1, arg_20_2, arg_20_3, arg_20_4, arg_20_5)
	arg_20_0.area:dispose()
end

function UploadToServerState.update(arg_21_0, arg_21_1, arg_21_2, arg_21_3, arg_21_4, arg_21_5, arg_21_6, arg_21_7, arg_21_8, arg_21_9)
	arg_21_0.area:update(arg_21_4)

	if arg_21_0.getInfoTask and arg_21_0.getInfoTask:update(arg_21_4) then
		local var_21_0 = arg_21_0.getInfoTask:getStatus() == native.ETaskStatus.success

		if var_21_0 and not arg_21_0.flag then
			local var_21_1 = "CompressedSaveData_" .. arg_21_9:getName() .. ".bin"

			arg_21_0.endpointInfo = arg_21_0.getInfoTask:fillInfo()
			arg_21_0.endpointInfo.variables.fileName = var_21_1
			arg_21_0.uploadFileTask = native.CSharingSaveDataUpload(arg_21_2:getUserManager(), arg_21_2:getHttpRequestHandlerService(), arg_21_0.endpointInfo.url, arg_21_0.endpointInfo.variables, arg_21_0.dataBuffer)

			arg_21_0:disposeGetInfoTask()
		elseif var_21_0 and arg_21_0.flag then
			arg_21_0:disposeGetInfoTask()

			return var_0_4.UploadSuccessful
		else
			arg_21_0:disposeGetInfoTask()

			return var_0_4.UploadFailed
		end
	end

	if arg_21_0.uploadFileTask and arg_21_0.uploadFileTask:update(arg_21_4) then
		if arg_21_0.uploadFileTask:getStatus() == native.ETaskStatus.success and arg_21_0.endpointInfo.id then
			arg_21_0.getInfoTask = native.CSharingSaveDataGet(arg_21_2:getUserManager(), arg_21_2:getHttpRequestHandlerService(), arg_21_0.endpointInfo.id)
			arg_21_0.flag = true
		else
			arg_21_0:disposeUploadFileTask()

			return var_0_4.UploadFailed
		end

		arg_21_0:disposeUploadFileTask()
	end
end

function UploadToServerState.disposeGetInfoTask(arg_22_0)
	if arg_22_0.getInfoTask then
		arg_22_0.getInfoTask:dispose()

		arg_22_0.getInfoTask = nil
	end
end

function UploadToServerState.disposeUploadFileTask(arg_23_0)
	if arg_23_0.uploadFileTask then
		arg_23_0.uploadFileTask:dispose()

		arg_23_0.uploadFileTask = nil
	end
end

function UploadToServerState.render(arg_24_0, arg_24_1, arg_24_2, arg_24_3, arg_24_4)
	arg_24_0.area:doRender(arg_24_1, arg_24_4)
end

local function var_0_7(arg_25_0, arg_25_1, arg_25_2, arg_25_3, arg_25_4, arg_25_5)
	local var_25_0 = true

	arg_25_2[arg_25_1] = arg_25_2[arg_25_1] or var_25_0

	return {
		textureManager = true,
		label = arg_25_0,
		defaultValue = var_25_0,
		getValue = function(arg_26_0)
			return arg_25_2[arg_25_1]
		end,
		setValue = function(arg_27_0, arg_27_1)
			arg_25_2[arg_25_1] = arg_27_0
		end,
		displayType = optionmenu_aide.DisplayTypes.Toggle,
		valueList = {
			{
				value = false,
				label = native.Localise("Disabled")
			},
			{
				value = true,
				label = native.Localise("Enabled")
			}
		},
		editable = not var_0_3[arg_25_5],
		editType = optionmenu_aide.EditTypes.Toggle,
		saveFileInfo = arg_25_3,
		mode = arg_25_4,
		modeEnum = arg_25_5
	}
end

local function var_0_8(arg_28_0)
	return {
		editable = false,
		disabled = true,
		label = arg_28_0,
		displayType = optionmenu_aide.DisplayTypes.SubTitle
	}
end

local function var_0_9(arg_29_0, arg_29_1)
	local var_29_0 = {}
	local var_29_1 = {}
	local var_29_2 = {}

	for iter_29_0, iter_29_1 in pairs(arg_29_0) do
		local var_29_3 = native.SaveDataCompressorDataType[iter_29_0]

		var_29_2[iter_29_0] = {}

		if var_29_3 then
			for iter_29_2 = 1, iter_29_1:getFileListCount() do
				local var_29_4 = iter_29_1:getFileListItem(iter_29_2)
				local var_29_5 = string.format("%s - %s", var_29_4.subTitle, uiutil.utcToDisplayStr(var_29_4.utc))

				table.insert(var_29_2[iter_29_0], var_0_7(var_29_5, var_29_4.mountName, arg_29_1, var_29_4, iter_29_0, var_29_3))
			end
		end

		table.insert(var_29_1, {
			mode = iter_29_0,
			label = native.Localise(iter_29_0)
		})
	end

	table.sort(var_29_1, function(arg_30_0, arg_30_1)
		return arg_30_0.label < arg_30_1.label
	end)

	for iter_29_3, iter_29_4 in ipairs(var_29_1) do
		local var_29_6 = var_29_2[iter_29_4.mode]

		if #var_29_6 > 0 then
			table.sort(var_29_6, function(arg_31_0, arg_31_1)
				return arg_31_0.saveFileInfo.utc > arg_31_1.saveFileInfo.utc
			end)
			table.insert(var_29_0, var_0_8(iter_29_4.label))

			for iter_29_5, iter_29_6 in ipairs(var_29_6) do
				table.insert(var_29_0, iter_29_6)
			end
		end
	end

	return var_29_0
end

local var_0_10 = optionmenu_state.OptionMenuState

Class("CompressSaveDataState", var_0_10)

function CompressSaveDataState.enter(arg_32_0, arg_32_1, arg_32_2, arg_32_3, arg_32_4, arg_32_5, arg_32_6)
	local var_32_0 = VERIFY(arg_32_6.partyMember)
	local var_32_1 = {
		backInputAllowed = true,
		homeInputAllowed = true,
		noTitleBox = true,
		itemParams = {
			partyMember = var_32_0,
			setDirty = nop
		},
		title = native.Localise("SaveFileUploader"),
		width = defaults.MenuWidthDouble
	}

	arg_32_0.options = {}

	local var_32_2 = {}
	local var_32_3

	var_0_10.enter(arg_32_0, arg_32_2, arg_32_3, arg_32_4, arg_32_5, var_32_2, var_32_3, var_32_1)

	arg_32_0.existingSaveFiles = {}
	arg_32_0.stateMachine = statemachine.StateMachine("CompressSaveDataState")

	arg_32_0.stateMachine:changeState(ScanAllConfigs(), arg_32_2, arg_32_3, arg_32_4, arg_32_5, var_32_0, arg_32_0.existingSaveFiles)

	arg_32_0.partyMember = VERIFY(var_32_0)
	arg_32_0.uploadToServer = arg_32_6.uploadToServer
end

function CompressSaveDataState.update(arg_33_0, arg_33_1, arg_33_2, arg_33_3, arg_33_4, arg_33_5, arg_33_6, arg_33_7)
	if arg_33_6:updateBlockingMixins(arg_33_2, arg_33_3, arg_33_4, arg_33_5, arg_33_7) then
		return
	end

	local var_33_0 = VERIFY(arg_33_0.partyMember)
	local var_33_1 = false
	local var_33_2 = arg_33_0.stateData

	arg_33_1 = arg_33_0.stateMachine or arg_33_1

	if arg_33_1:getCurrentState() then
		local var_33_3 = arg_33_1:update(arg_33_2, arg_33_3, arg_33_4, arg_33_5, arg_33_6, arg_33_7, var_33_2, var_33_0)

		if var_33_3 then
			local var_33_4 = arg_33_0.menuConfig.itemParams

			arg_33_0.menuItems = var_0_9(arg_33_0.existingSaveFiles, arg_33_0.options)

			arg_33_0:refreshMenuItems(arg_33_2, arg_33_6)
			arg_33_1:changeState(nil, arg_33_2, arg_33_3, arg_33_5, arg_33_6, var_33_2)

			if var_33_3 == var_0_4.ScanFinished then
				arg_33_6:blockingAlert(arg_33_2, arg_33_3, {
					options = "ok",
					text = native.Localise("SaveDataUploadInstructions"),
					input = var_33_0:getInput()
				})
			elseif var_33_3 == var_0_4.UploadSuccessful or var_33_3 == var_0_4.UploadFailed then
				local var_33_5 = var_33_3 == var_0_4.UploadSuccessful and "SaveDataUploadSuccessful" or "SaveDataUploadFailed"

				arg_33_6:blockingAlert(arg_33_2, arg_33_3, {
					options = "ok",
					text = native.Localise(var_33_5),
					input = var_33_0:getInput(),
					onSelected = function(arg_34_0, arg_34_1, arg_34_2)
						arg_33_6:homeScreenEnter(arg_34_0, arg_34_1, arg_33_5, arg_33_6, var_33_0, false)
					end
				})
			end
		end

		return
	end

	local var_33_6 = arg_33_0.uploadToServer
	local var_33_7 = var_33_6 and "Upload" or "WriteToFile"

	arg_33_6:addTooltip(arg_33_0.tooltipsWidget, var_0_1, native.Localise(var_33_7))

	if arg_33_6:checkForRelease(var_33_0, var_0_1) then
		local var_33_8 = {}

		for iter_33_0, iter_33_1 in ipairs(arg_33_0.menuItems) do
			local var_33_9 = iter_33_1.saveFileInfo

			if var_33_9 and arg_33_0.options[var_33_9.mountName] then
				table.insert(var_33_8, {
					saveHelperKey = iter_33_1.mode,
					modeEnum = iter_33_1.modeEnum,
					saveFileInfo = var_33_9,
					partyMember = var_33_0
				})
			end
		end

		local var_33_10 = var_33_6 and UploadToServerState or WriteToFileState

		arg_33_1:changeState(CompressDataState(), arg_33_2, arg_33_3, arg_33_5, arg_33_6, var_33_8, var_33_10)

		return
	end

	local var_33_11, var_33_12, var_33_13, var_33_14 = var_0_10.update(arg_33_0, arg_33_2, arg_33_3, arg_33_4, arg_33_5, arg_33_6, arg_33_7, var_33_0:getInput())

	if var_33_11 then
		arg_33_6:homeScreenEnter(arg_33_2, arg_33_3, arg_33_5, arg_33_6, var_33_0, false)
	end
end

function CompressSaveDataState.render(arg_35_0, arg_35_1, arg_35_2, arg_35_3, arg_35_4)
	if arg_35_0.stateMachine:getCurrentState() then
		arg_35_0.stateMachine:render(arg_35_1, arg_35_2, arg_35_3, arg_35_4)
	else
		var_0_10.render(arg_35_0, arg_35_1, arg_35_2, arg_35_3, arg_35_4)
	end
end

function CompressSaveDataState.exit(arg_36_0, arg_36_1, arg_36_2, arg_36_3, arg_36_4)
	if arg_36_0.stateMachine:getCurrentState() then
		arg_36_0.stateMachine:changeState(nil, arg_36_1, arg_36_2, arg_36_3, arg_36_4)
	end

	var_0_10.exit(arg_36_0, arg_36_1, arg_36_2, arg_36_3, arg_36_4)
end

Class("CompressSaveDataCancelState")

function CompressSaveDataCancelState.enter(arg_37_0, arg_37_1, arg_37_2, arg_37_3, arg_37_4, arg_37_5, arg_37_6)
	local var_37_0 = arg_37_2:getHttpRequestHandlerService()

	arg_37_0.area = busy_layout.create(arg_37_2, native.Localise("DecliningSharingRequest"), "", false, {
		instant = true
	})
	arg_37_0.stayUntil = arg_37_3 + 1
	arg_37_0.stateData = arg_37_6
	arg_37_0.deleteTask = native.CSharingSaveDataDelete(arg_37_2:getUserManager(), var_37_0)

	arg_37_0.deleteTask:begin()
end

function CompressSaveDataCancelState.exit(arg_38_0)
	arg_38_0.area:dispose()

	if arg_38_0.deleteTask then
		arg_38_0.deleteTask:dispose()
	end
end

function CompressSaveDataCancelState.update(arg_39_0, arg_39_1, arg_39_2, arg_39_3, arg_39_4, arg_39_5, arg_39_6, arg_39_7)
	arg_39_0.area:update(arg_39_4)

	if arg_39_3 > arg_39_0.stayUntil then
		return
	end

	if arg_39_0.deleteTask:update(arg_39_4) then
		arg_39_0.deleteTask:dispose()

		local var_39_0 = arg_39_0.stateData

		arg_39_6:homeScreenEnter(arg_39_2, arg_39_3, arg_39_5, arg_39_6, var_39_0.partyMember, false)
	end
end

function CompressSaveDataCancelState.render(arg_40_0, arg_40_1, arg_40_2, arg_40_3, arg_40_4)
	arg_40_0.area:doRender(arg_40_1, arg_40_4)
end

Class("CompressSaveDataPromptState")

function CompressSaveDataPromptState.enter(arg_41_0, arg_41_1, arg_41_2, arg_41_3, arg_41_4, arg_41_5, arg_41_6)
	local var_41_0 = VERIFY(arg_41_6.partyMember)

	arg_41_5:blockingAlert(arg_41_2, arg_41_3, {
		options = "yesno",
		text = native.Localise("DataRequestedConfirmUpload"),
		input = var_41_0:getInput(),
		onSelected = function(arg_42_0, arg_42_1, arg_42_2)
			if arg_42_2.val then
				arg_41_1:changeState(CompressSaveDataState(), arg_42_0, arg_42_1, arg_41_4, arg_41_5, arg_41_6)
			else
				arg_41_1:changeState(CompressSaveDataCancelState(), arg_42_0, arg_42_1, arg_41_4, arg_41_5, arg_41_6)
			end
		end
	})
end

function CompressSaveDataPromptState.update(arg_43_0, arg_43_1, arg_43_2, arg_43_3, arg_43_4, arg_43_5, arg_43_6, arg_43_7)
	arg_43_6:updateBlockingMixins(arg_43_2, arg_43_3, arg_43_4, arg_43_5, arg_43_7)
end

-- main-menu-revamp mod: a random NRL player stands on the right of the home
-- screen in his club's home kit and cycles through the front-end idle
-- animations, while the menu boxes stack on the left (pahomescreenview.xaml).
--
-- homescreen_state.lua is owned by allow-exit-any-menu-tab, so
-- HomeScreenState.enter/update/exit are wrapped here instead. This file is
-- homescreen_state's first import, so it runs before Class("HomeScreenState"),
-- and Class() reuses an existing _G._CLASSES entry. The wrapped methods are
-- never stored in the class table itself: they live in a side table behind
-- __index, so every (re)definition goes through __newindex and is wrapped
-- again. That covers the frontend scripts being re-imported after a match,
-- which a plain one-shot trap would miss. Other traps on the same metatable
-- (clear-academy-data wraps update) are chained.

-- MainMenuDebug adds verbose tracing to mainmenu_debug.txt in the game folder.
local MainMenuDebug = true

local MainMenuConfig = {
	modelIndex = 1,
	-- Degrees; positive turns the player toward the menu on the left.
	rotation = 0,
	-- Head tracking (PlayerModelRotation.getLookAt) fights the flourish
	-- animations, so it is off; rotation 0 already faces the camera.
	lookAtCamera = false,
	-- Chance that the player holds a ball (changes which animations play).
	-- Always: the no-ball flourishes are kept below for reference only.
	ballChance = 1,
	-- Seconds of plain idle between flourishes.
	idleSecondsMin = 7,
	idleSecondsMax = 11,
	transitionFrameCount = 12,
	emotionGroupName = "ui_default",
	baseAnimation = "FullBodyIdle",
	-- Used when the NRL league can't be read: the 2026 NRL clubs.
	fallbackClubIds = {
		118,
		119,
		120,
		121,
		122,
		123,
		124,
		125,
		126,
		127,
		128,
		129,
		130,
		131,
		132,
		133,
		134
	}
}

-- Framing: playermodel_camera_aide.FullBody_OutsideOfAppearance (the player
-- edit screens), which puts a full-body player on the right of the screen.
local MainMenuCamera = {
	name = "MainMenuPlayer",
	nearClip = 2,
	farClip = 10,
	fov = 25,
	rotatePlayer = true,
	preLookAtOffset = {
		0.5,
		0,
		5.5
	},
	postLookAtOffset = {
		-1,
		1,
		0
	},
	shadowExtent = native.vec3(1, 1, 1),
	mouseRegion = {
		1091,
		42,
		1842,
		993
	}
}

-- Flourishes play between idles. Each is a list of steps. Animation names are
-- action sets in intermediatelua/animations/frontendset.lua. With the ball,
-- only sets that have a Ball variant (or no gear filter) can play; a set that
-- filters out to nothing is skipped by the engine and the idle carries on.
local MainMenuFlourishes = {
	-- With the ball: only sets authored with it. HeroPose has no Ball variant,
	-- so the ball stayed stuck to one hand through it. The Pro Team poses
	-- (p1_pro_team_poses_NN, gear Ball) are static card poses, held briefly
	-- and blended in and out.
	ball = {
		{
			{
				anim = "FullBodyIdleApproval",
				seconds = 4
			}
		}
	},
	noBall = {
		{
			{
				anim = "FullBodyIdleApproval",
				seconds = 4
			}
		},
		{
			{
				anim = "HeroPose",
				seconds = 5
			}
		},
		{
			{
				anim = "JerseySelect",
				seconds = 6
			}
		},
		{
			{
				anim = "ReadyUp",
				seconds = 1.5
			},
			{
				anim = "ReadyUpIdle",
				seconds = 5
			},
			{
				anim = "UnReadyUp",
				seconds = 1.5
			}
		}
	}
}

for index = 1, 10 do
	table.insert(MainMenuFlourishes.ball, {
		{
			anim = string.format("rl1_proteam_screenshot_%02d", index),
			seconds = 3.5
		}
	})
end

local function mainMenuLogError(message)
	pcall(function()
		local file = io.open("mainmenu_debug.txt", "a")

		if file then
			file:write(os.date("%Y-%m-%d %H:%M:%S ") .. tostring(message) .. "\n")
			file:close()
		end
	end)
end

local function mainMenuLog(message)
	if MainMenuDebug then
		mainMenuLogError(message)
	end
end

local function mainMenuTraceback(err)
	if debug and debug.traceback then
		return debug.traceback(tostring(err), 2)
	end

	return tostring(err)
end

local MainMenuLastError

-- LuaJIT's xpcall passes the extra arguments on to fn.
local function mainMenuSafe(label, fn, ...)
	local ok, err = xpcall(fn, mainMenuTraceback, ...)

	if not ok then
		local message = label .. ": " .. tostring(err)

		if message ~= MainMenuLastError then
			MainMenuLastError = message

			mainMenuLogError(message)
		end
	end
end

-- os.clock() is wall time on Windows; fall back to os.time() (1 s steps).
local function mainMenuNow()
	local ok, now = pcall(os.clock)

	if ok and type(now) == "number" then
		return now
	end

	return os.time()
end

-- Own generator, so the game's math.random sequence is left alone.
local mainMenuRandomState = (os.time() + math.floor(mainMenuNow() * 1000)) % 2147483647

local function mainMenuRandom()
	mainMenuRandomState = (mainMenuRandomState * 16807) % 2147483647

	return mainMenuRandomState / 2147483647
end

local function mainMenuRandomIndex(count)
	return math.min(count, math.floor(mainMenuRandom() * count) + 1)
end

local MainMenuShow = {
	active = false
}

local function mainMenuNrlClubIds(uiServices)
	local ok, ids = pcall(function()
		local leagueManager = uiServices:getLeagueManager()
		local academyLeagues = native.AcademyLeagues

		for _, key in ipairs({
			"League_NRL2026",
			"League_NRL"
		}) do
			local academyId = academyLeagues and academyLeagues[key]

			if academyId then
				local leagueId = leagueManager.onDisc:getLeagueIdBasedOff(academyId)
				local league = leagueId and leagueManager:getLeague(leagueId)
				local clubIds = league and league:getClubIds()

				if clubIds and #clubIds > 0 then
					return clubIds
				end
			end
		end
	end)

	if ok and ids then
		return ids
	end

	mainMenuLog("NRL league not found (" .. tostring(ids) .. "), using fallback club ids")

	return MainMenuConfig.fallbackClubIds
end

local function mainMenuPickPlayer(uiServices)
	local clubManager = uiServices:getClubManager()
	local playerManager = uiServices:getPlayerManager()
	local clubIds = mainMenuNrlClubIds(uiServices)

	for attempt = 1, 12 do
		local clubId = clubIds[mainMenuRandomIndex(#clubIds)]
		local club = clubManager:getClub(clubId)
		local playerCount = club and club.playerCount or 0

		if playerCount > 0 then
			local playerId = club:getPlayerIdAt(mainMenuRandomIndex(playerCount))
			local player = playerId and playerManager:getPlayer(playerId)

			if player and player.visual and player.identity then
				return player, club
			end
		end
	end
end

local function mainMenuPlay(uiServices, animation)
	uiServices:playerModelUpdate(MainMenuConfig.modelIndex, {
		idleParams = {
			playerAnimation = animation,
			emotionGroupName = MainMenuConfig.emotionGroupName,
			lookAtEnable = MainMenuConfig.lookAtCamera,
			playerAnimationParams = {
				transitionFrameCount = MainMenuConfig.transitionFrameCount
			}
		}
	})
end

local function mainMenuScheduleIdle(now)
	MainMenuShow.flourish = nil
	MainMenuShow.nextFlourishAt = now + MainMenuConfig.idleSecondsMin + mainMenuRandom() * (MainMenuConfig.idleSecondsMax - MainMenuConfig.idleSecondsMin)
end

local function mainMenuDetachBall(uiServices)
	local index = MainMenuConfig.modelIndex

	-- Listing the ball with attach = false detaches it (and shows it); the
	-- nil list then hides every prop.
	local ok, err = pcall(uiServices.setPlayerModelProps, uiServices, index, {
		{
			name = "ball",
			attach = false
		}
	})

	if not ok then
		mainMenuLogError("detaching ball: " .. tostring(err))
	end

	uiServices:setPlayerModelProps(index, nil)
end

local function mainMenuAttachBall(uiServices, player)
	local ok, err = pcall(uiServices.setPlayerModelProps, uiServices, MainMenuConfig.modelIndex, {
		{
			name = "ball",
			attach = true
		}
	}, player)

	if not ok then
		mainMenuLogError("attaching ball: " .. tostring(err))
		mainMenuDetachBall(uiServices)
	end

	return ok
end

local function mainMenuShowPlayer(uiServices)
	local index = MainMenuConfig.modelIndex
	local player, club = mainMenuPickPlayer(uiServices)

	if not player then
		mainMenuLogError("no NRL player found to show")

		return
	end

	local model = uiServices:playerModelGetPlayer(index)

	MainMenuShow.previousCameraInfo = model.cameraInfo
	MainMenuShow.previousCameraEnabled = uiServices:playerModelCameraEnabled()
	-- Active from here on, so exit restores the camera even if a later step
	-- fails.
	MainMenuShow.active = true
	MainMenuShow.loaded = false
	MainMenuShow.lastFlourish = nil

	mainMenuScheduleIdle(mainMenuNow())

	-- Enabling the model camera clears every model's camera info, so it has
	-- to happen before the camera is set below.
	uiServices:playerModelCameraEnabled(true)
	uiServices:playerModelSetUniform(index, club:getHomeUniformVisual(), club.identity)

	MainMenuShow.ball = mainMenuRandom() < MainMenuConfig.ballChance

	if MainMenuShow.ball then
		MainMenuShow.ball = mainMenuAttachBall(uiServices, player)
	else
		mainMenuDetachBall(uiServices)
	end

	-- The camera table doubles as the first animation request.
	local camera = {}

	for key, value in pairs(MainMenuCamera) do
		camera[key] = value
	end

	camera.playerAnimation = MainMenuConfig.baseAnimation
	camera.emotionGroupName = MainMenuConfig.emotionGroupName
	camera.lookAtEnable = MainMenuConfig.lookAtCamera
	camera.playerAnimationParams = {
		transitionFrameCount = 0
	}

	uiServices:playerModelUpdate(index, {
		resetOptions = true,
		rotationEnabled = false,
		refresh = true,
		draw = true,
		hideUntilLoaded = true,
		player = player,
		position = native.vec3.Zero(),
		rotation = MainMenuConfig.rotation,
		camera = camera,
		cameraInstant = true
	})
	mainMenuLog(string.format("showing %s (club %s, %s)", tostring(player.identity.fullName), tostring(club.id), MainMenuShow.ball and "ball" or "no ball"))
end

local function mainMenuHidePlayer(uiServices)
	if not MainMenuShow.active then
		return
	end

	MainMenuShow.active = false

	local index = MainMenuConfig.modelIndex
	local previousCameraInfo = MainMenuShow.previousCameraInfo

	MainMenuShow.previousCameraInfo = nil

	-- Each step runs on its own, so one failure can't leave the camera pushed.
	mainMenuSafe("hide ball", mainMenuDetachBall, uiServices)
	mainMenuSafe("hide model", function()
		uiServices:playerModelUpdate(index, {
			draw = false
		})
	end)

	if not MainMenuShow.previousCameraEnabled then
		mainMenuSafe("hide camera", function()
			uiServices:playerModelCameraEnabled(false)
		end)
	end

	-- Put back the camera info the home screen found (at boot that is the
	-- featured player's), so screens that don't set their own see no change.
	mainMenuSafe("restore camera info", function()
		uiServices:playerModelGetPlayer(index):setCameraInfo(previousCameraInfo, true)
	end)
	mainMenuLog("player hidden")
end

local function mainMenuUpdatePlayer(uiServices)
	if not MainMenuShow.active then
		return
	end

	local now = mainMenuNow()

	-- The idle timer only starts once the model has streamed in.
	if not MainMenuShow.loaded then
		if uiServices:playerModelGetIsLoaded(MainMenuConfig.modelIndex) then
			MainMenuShow.loaded = true

			mainMenuScheduleIdle(now)
		end

		return
	end

	local flourish = MainMenuShow.flourish

	if flourish then
		if now < MainMenuShow.stepEndsAt then
			return
		end

		local step = MainMenuShow.step + 1

		if step > #flourish then
			mainMenuPlay(uiServices, MainMenuConfig.baseAnimation)
			mainMenuScheduleIdle(now)
		else
			MainMenuShow.step = step
			MainMenuShow.stepEndsAt = now + flourish[step].seconds

			mainMenuPlay(uiServices, flourish[step].anim)
		end

		return
	end

	if now < MainMenuShow.nextFlourishAt then
		return
	end

	local pool = MainMenuShow.ball and MainMenuFlourishes.ball or MainMenuFlourishes.noBall
	local choice = mainMenuRandomIndex(#pool)

	if #pool > 1 and pool[choice] == MainMenuShow.lastFlourish then
		choice = choice % #pool + 1
	end

	flourish = pool[choice]
	MainMenuShow.flourish = flourish
	MainMenuShow.lastFlourish = flourish
	MainMenuShow.step = 1
	MainMenuShow.stepEndsAt = now + flourish[1].seconds

	mainMenuPlay(uiServices, flourish[1].anim)
	mainMenuLog("flourish: " .. flourish[1].anim)
end

-- The engine's type() returns class names for class instances (uiServices is
-- a "FrontEndServices"), so table checks use rawtype.
local mainMenuRawType = rawget(_G, "rawtype") or type

local function mainMenuIsServices(value)
	local kind = mainMenuRawType(value)

	if kind ~= "table" and kind ~= "userdata" then
		return false
	end

	local ok, fn = pcall(function()
		return value.playerModelUpdate
	end)

	return ok and type(fn) == "function"
end

-- uiServices sits at a fixed position for the stock callers, but other mods
-- call changeState from the home screen too, so fall back to a scan.
local function mainMenuFindServices(expected, ...)
	local candidate = (select(expected, ...))

	if mainMenuIsServices(candidate) then
		return candidate
	end

	for position = 1, select("#", ...) do
		candidate = (select(position, ...))

		if mainMenuIsServices(candidate) then
			return candidate
		end
	end
end

-- Menu layout ---------------------------------------------------------------
-- Tabs (pahomescreenview.xaml): Play, Academy, Settings, Extras.
--   Play: Casual Game, Competitions, Career, Online. Casual Game and
--     Competitions open a second page in place (the accordion only nests one
--     level): Casual -> Team / Player (Male / Female); Competitions -> the
--     competition tiles + World Cup. Back box or B returns.
--   Settings: the Settings tile's sub-menu as boxes. Extras: Practice,
--     Credits, About.
-- The tiles come from homescreenstate_config.createFirstPageTiles (owned by
-- coach-editor), wrapped here. Its tile tables are shared, so new tiles are
-- copies; the rows (Main, Competition, Academy, Extra) stay, because
-- NVMHomeScreen builds one view-model per row. New tile keys need bound
-- properties, injected into MainNVM / ExtraNVM below.

local MainMenuText = {
	casualGame = "Casual Game",
	competitions = "Competitions",
	team = "Team",
	player = "Player",
	male = "Male",
	female = "Female",
	worldCup = "World Cup",
	back = "Back"
}

-- Pages of the Play tab, and the tiles that live on them (for returning to
-- the right page and for focus).
local MainMenuPages = {
	Casual = {
		focus = "CasualTeam",
		keys = {
			CasualTeam = true,
			CasualPlayer = true
		}
	},
	Competitions = {
		focus = "NRL",
		keys = {
			NRL = true,
			SuperLeague = true,
			NRLW = true,
			WSL = true,
			CompetitionHub = true,
			RLWC2026 = true
		}
	}
}
local MainMenuSettingsSlots = 12

local function mainMenuCopy(tile, overrides)
	local copy = {}

	for key, value in pairs(tile) do
		copy[key] = value
	end

	-- false in overrides removes the field from the copy.
	for key, value in pairs(overrides or {}) do
		if value == false then
			copy[key] = nil
		else
			copy[key] = value
		end
	end

	return copy
end

local function mainMenuTake(row, key)
	for index, tile in ipairs(row) do
		if tile.dataContextKey == key then
			table.remove(row, index)

			return tile
		end
	end
end

local function mainMenuReorganise(tiles)
	local rows = tiles and tiles.tilesRows

	if not rows or not rows.Main or not rows.Extra or rows.Main.mainMenuDone then
		return tiles
	end

	local main = rows.Main
	local casual = mainMenuTake(main, "Casual")
	local worldCup = mainMenuTake(main, "RLWC2026")
	local online = mainMenuTake(main, "Online")
	local proTeam = mainMenuTake(main, "ProTeam")
	local career = mainMenuTake(main, "Career")
	local commsTasks = mainMenuTake(main, "CommsTasks")

	mainMenuTake(main, "Finals")

	local hub

	for _, tile in ipairs(rows.Competition or {}) do
		if tile.dataContextKey == "CompetitionHub" then
			hub = tile
		end
	end

	local newMain = {
		dataContextKey = main.dataContextKey,
		mainMenuDone = true
	}

	local function add(tile)
		if tile then
			table.insert(newMain, tile)
		end
	end

	if casual then
		add(mainMenuCopy(casual, {
			dataContextKey = "CasualGame",
			autoNavKey = "casual",
			title = MainMenuText.casualGame,
			subMenu = false,
			stateData = {
				mainMenuPage = "Casual"
			}
		}))

		-- Casual sub-menu: club / be-a-pro x men / women.
		local team, player = {}, {}

		for _, item in ipairs(casual.subMenu or {}) do
			local data = item.stateData or {}
			local isFemale = data.sex == native.CSex.Female
			local entry = mainMenuCopy(item, {
				title = isFemale and MainMenuText.female or MainMenuText.male
			})

			table.insert(data.beAPro and player or team, entry)
		end

		add(mainMenuCopy(casual, {
			dataContextKey = "CasualTeam",
			autoNavKey = "CasualTeam",
			title = MainMenuText.team,
			subMenu = team
		}))
		add(mainMenuCopy(casual, {
			dataContextKey = "CasualPlayer",
			autoNavKey = "CasualPlayer",
			title = MainMenuText.player,
			subMenu = player
		}))
	end

	add(mainMenuCopy(hub or {}, {
		dataContextKey = "Competitions",
		autoNavKey = "competitions",
		title = MainMenuText.competitions,
		subMenu = false,
		scanTasksOnSubmenuOpen = false,
		competitionId = false,
		stateFactory = hub and hub.stateFactory or casual and casual.stateFactory,
		stateData = {
			mainMenuPage = "Competitions"
		}
	}))
	add(career)

	if online then
		-- Pro Team joins Online's sub-menu. The tile has no stateFactory of
		-- its own, so each sub-button uses its item's factory.
		local items = {}

		for _, item in ipairs(online.subMenu or {}) do
			table.insert(items, mainMenuCopy(item, {
				stateFactory = item.stateFactory or online.stateFactory
			}))
		end

		if proTeam then
			table.insert(items, {
				title = proTeam.title,
				description = proTeam.description,
				stateFactory = proTeam.stateFactory,
				stateData = proTeam.stateData
			})
		end

		add(mainMenuCopy(online, {
			dataContextKey = "OnlineMenu",
			stateFactory = false,
			subMenu = items
		}))
	end

	add(commsTasks)

	if worldCup then
		add(mainMenuCopy(worldCup, {
			title = MainMenuText.worldCup
		}))
	end

	add({
		dataContextKey = "PageBack",
		autoNavKey = "PageBack",
		title = MainMenuText.back,
		description = "",
		stateFactory = casual and casual.stateFactory,
		stateData = {
			mainMenuPage = ""
		}
	})

	rows.Main = newMain

	-- Settings: the Settings tile's sub-menu becomes its own boxes.
	local settings = mainMenuTake(rows.Extra, "Settings")

	if settings then
		for index, item in ipairs(settings.subMenu or {}) do
			if index > MainMenuSettingsSlots then
				break
			end

			table.insert(rows.Extra, {
				dataContextKey = "SettingsItem" .. index,
				autoNavKey = "SettingsItem" .. index,
				customSound = settings.customSound,
				title = item.title,
				description = item.description or settings.description,
				locked = item.locked,
				stateFactory = settings.stateFactory or item.stateFactory,
				stateData = item.stateData
			})
		end
	end

	return tiles
end

local MainMenuTilesWrapper

local function mainMenuWrapTiles()
	import("app.homescreen.homescreenstate_config")

	local config = homescreenstate_config
	local original = config and config.createFirstPageTiles

	if type(original) ~= "function" or original == MainMenuTilesWrapper then
		return
	end

	MainMenuTilesWrapper = function(...)
		local tiles = original(...)
		local ok, err = pcall(mainMenuReorganise, tiles)

		if not ok then
			mainMenuLogError("reorganising tiles: " .. tostring(err))
		end

		return tiles
	end
	config.createFirstPageTiles = MainMenuTilesWrapper

	mainMenuLog("createFirstPageTiles wrapped")
end

-- Bound view-model properties for the new tiles. ns.Class turns a class's
-- Bindings into a native type the moment Bindings is assigned, so they are
-- added then: the class table is pre-seeded in _G._CLASSES (Class() reuses
-- it and its metatable), and assigning ns's one-shot __newindex handler to
-- that metatable is caught by a metatable on the metatable, which wraps the
-- handler to add the properties first.
local function mainMenuExtraProperties(name)
	import("app.noesis.ns")

	local button = ns.typeOf(native.paNVMButton)
	local props = {}

	if name == "MainNVM" then
		props.Page = ns.String
		props.FocusRequest = ns.String

		for _, key in ipairs({
			"CasualGame",
			"CasualTeam",
			"CasualPlayer",
			"Competitions",
			"OnlineMenu",
			"PageBack"
		}) do
			props[key] = button
		end
	else
		for index = 1, MainMenuSettingsSlots do
			props["SettingsItem" .. index] = button
		end
	end

	return props
end

local function mainMenuSeedBindings(name)
	local classes = rawget(_G, "_CLASSES")
	local class = classes[name]

	if class == nil then
		class = {}
		classes[name] = class
	end

	local meta = getmetatable(class)

	if meta == nil then
		meta = {}

		setmetatable(class, meta)
	end

	if getmetatable(meta) ~= nil then
		return
	end

	if rawget(meta, "__newindex") ~= nil then
		mainMenuLogError(name .. " already registered its bindings: menu boxes for it won't bind")

		return
	end

	setmetatable(meta, {
		__newindex = function(tbl, key, value)
			if key == "__newindex" and mainMenuRawType(value) == "function" then
				local handler = value

				value = function(target, field, bindings)
					if field == "Bindings" and mainMenuRawType(bindings) == "table" then
						mainMenuSafe("bindings " .. name, function()
							bindings.Properties = bindings.Properties or {}

							for prop, propType in pairs(mainMenuExtraProperties(name)) do
								if bindings.Properties[prop] == nil then
									bindings.Properties[prop] = propType
								end
							end

							mainMenuLog("added bound properties to " .. name)
						end)
					end

					return handler(target, field, bindings)
				end
			end

			rawset(tbl, key, value)
		end
	})
end

-- The NavigationTag Noesis focuses by: the tile's autoNavKey or its key.
local function mainMenuNavTag(self, key)
	local rows = self.homescreenTilesData and self.homescreenTilesData.tilesRows

	for _, row in pairs(rows or {}) do
		for _, tile in ipairs(row) do
			if tile.dataContextKey == key then
				return tile.autoNavKey or key
			end
		end
	end

	return key
end

local function mainMenuSetPage(self, page, uiServices)
	local viewModel = self.viewModel
	local main = viewModel and viewModel.Main

	if not main then
		return
	end

	local previous = main.Page or ""

	main.Page = page

	if page == "" then
		self.canExitGameTimer = 0
	end

	-- Focus is moved a couple of frames later, once the page is laid out, by
	-- Main.FocusRequest (XAML SetFocusAction on the named box). Changing
	-- FocusElementIdentifier at runtime did not move focus here.
	self.mainMenuPendingFocus = page ~= "" and page or ("@" .. previous)
	self.mainMenuPendingFrames = 2

	if uiServices then
		pcall(uiServices.playSound, uiServices, page ~= "" and "SelectLrg" or "Back")
	end

	mainMenuLog("page: " .. (page ~= "" and page or "main"))
end

-- Runs before the stock update: page tiles select an item like any tile, so
-- their selection is taken here, before the stock code changes state.
local function mainMenuUpdatePages(self, uiServices)
	local viewModel = self.viewModel
	local main = viewModel and viewModel.Main

	if not main then
		return
	end

	if self.mainMenuPendingFocus then
		self.mainMenuPendingFrames = self.mainMenuPendingFrames - 1

		if self.mainMenuPendingFrames <= 0 then
			main.FocusRequest = self.mainMenuPendingFocus
			self.mainMenuPendingFocus = nil
			self.mainMenuClearFocusRequest = true
		end
	elseif self.mainMenuClearFocusRequest then
		-- Cleared the frame after, so the same request can fire again.
		self.mainMenuClearFocusRequest = nil
		main.FocusRequest = ""
	end

	-- B that closes a sub-menu is handled by the accordion (Noesis) before
	-- this runs, so subMenuOpen already reads false; ignore B for a moment
	-- after any sub-menu was open.
	local now = mainMenuNow()

	if viewModel.subMenuOpen then
		self.mainMenuSubMenuSeenAt = now
	end

	local subMenuRecent = self.mainMenuSubMenuSeenAt and now - self.mainMenuSubMenuSeenAt < 0.35

	local selected = viewModel.selectedItem
	local page = selected and selected.stateData and selected.stateData.mainMenuPage

	if page ~= nil then
		viewModel.selectedItem = nil

		mainMenuSetPage(self, page, uiServices)

		return
	end

	local current = main.Page or ""

	if current == "" then
		return
	end

	-- Leaving the Play tab closes its page.
	if viewModel.TabIndex ~= 0 then
		main.Page = ""
		self.canExitGameTimer = 0

		return
	end

	-- B goes back a page. Keep the stock "exit game" prompt (B on the first
	-- tab) from arming while a page is open.
	self.canExitGameTimer = -1000

	local released = self.partyMember and uiServices:checkForRelease(self.partyMember, native.InputTypes.Decline)

	if released and not viewModel.subMenuOpen and not subMenuRecent then
		mainMenuSetPage(self, "", uiServices)
	end
end

-- After enter: return to the page holding the tile that was highlighted
-- last (e.g. back from a competition).
local function mainMenuRestorePage(self, uiServices)
	local ok, title = pcall(uiServices.getHighlightTitle, uiServices)

	if not ok or not title then
		return
	end

	for page, info in pairs(MainMenuPages) do
		if info.keys[title] then
			self.viewModel.Main.Page = page
			-- The view model's initial focus tag (read when the view loads).
			self.viewModel.FocusElementIdentifier = mainMenuNavTag(self, title)
			self.viewModel.ForceElementFocus = true

			return
		end
	end
end

-- HomeScreenState.enter(self, sm, engine, ?, config, uiServices, ...): an
-- enter that hands straight over to another state (standalone, autoNavTo)
-- leaves no view, so the player is only shown when the menu was built.
local function mainMenuWrapEnter(original)
	return function(self, ...)
		mainMenuSafe("wrap tiles", mainMenuWrapTiles)

		local results = {
			original(self, ...)
		}
		local uiServices = mainMenuFindServices(5, ...)

		if self.viewModel and uiServices then
			mainMenuSafe("restore page", mainMenuRestorePage, self, uiServices)
		end

		mainMenuLog(string.format("enter: view=%s services=%s args=%d", tostring(self.view ~= nil), tostring(uiServices ~= nil), select("#", ...)))

		if self.view and uiServices then
			mainMenuSafe("show", mainMenuShowPlayer, uiServices)
		end

		return unpack(results)
	end
end

-- HomeScreenState.update(self, sm, engine, ?, ?, ?, uiServices, ...)
local function mainMenuWrapUpdate(original)
	return function(self, ...)
		local uiServices = mainMenuFindServices(6, ...)

		if not MainMenuShow.loggedUpdate then
			MainMenuShow.loggedUpdate = true

			mainMenuLog(string.format("first update: services=%s active=%s", tostring(uiServices ~= nil), tostring(MainMenuShow.active)))
		end

		if uiServices then
			mainMenuSafe("update", mainMenuUpdatePlayer, uiServices)
			mainMenuSafe("pages", mainMenuUpdatePages, self, uiServices)
		end

		return original(self, ...)
	end
end

-- HomeScreenState.exit(self, engine, ?, ?, uiServices): changeState passes
-- exit the new state's arguments, without the state machine.
local function mainMenuWrapExit(original)
	return function(self, ...)
		local uiServices = mainMenuFindServices(4, ...)

		if uiServices then
			mainMenuSafe("hide", mainMenuHidePlayer, uiServices)
		end

		return original(self, ...)
	end
end

local MainMenuWrappers = {
	enter = mainMenuWrapEnter,
	update = mainMenuWrapUpdate,
	exit = mainMenuWrapExit
}

local function mainMenuInstallHomeHook()
	local classes = rawget(_G, "_CLASSES")

	if type(classes) ~= "table" then
		mainMenuLogError("_G._CLASSES missing: home screen player not installed")

		return
	end

	local class = classes.HomeScreenState

	if class == nil then
		class = {}
		classes.HomeScreenState = class
	end

	local meta = getmetatable(class) or {}

	if rawget(meta, "__mainMenuHooks") then
		mainMenuLog("hook already installed")

		return
	end

	local hooked = {}

	mainMenuLog(string.format("installing: class existed=%s, metatable=%s, enter raw=%s", tostring(rawget(classes, "HomeScreenState") ~= nil and next(class) ~= nil), tostring(getmetatable(class) ~= nil), tostring(rawget(class, "enter") ~= nil)))

	-- Already defined (this file loaded after homescreen_state): move the
	-- methods into the side table.
	for key, wrap in pairs(MainMenuWrappers) do
		local fn = rawget(class, key)

		if type(fn) == "function" then
			rawset(class, key, nil)

			hooked[key] = wrap(fn)
		end
	end

	local previousIndex = meta.__index
	local previousNewIndex = meta.__newindex

	rawset(meta, "__mainMenuHooks", hooked)

	function meta.__index(tbl, key)
		local fn = hooked[key]

		if fn ~= nil then
			return fn
		end

		if type(previousIndex) == "function" then
			return previousIndex(tbl, key)
		elseif type(previousIndex) == "table" then
			return previousIndex[key]
		end
	end

	function meta.__newindex(tbl, key, value)
		local wrap = MainMenuWrappers[key]

		if wrap and type(value) == "function" then
			-- Let any older trap wrap it first, into a scratch table.
			if type(previousNewIndex) == "function" then
				local scratch = {}

				previousNewIndex(scratch, key, value)

				value = rawget(scratch, key) or value
			end

			hooked[key] = wrap(value)

			return
		end

		if type(previousNewIndex) == "function" then
			previousNewIndex(tbl, key, value)
		elseif type(previousNewIndex) == "table" then
			previousNewIndex[key] = value
		else
			rawset(tbl, key, value)
		end
	end

	setmetatable(class, meta)
	mainMenuLog("home screen hook installed")
end

mainMenuSafe("install", mainMenuInstallHomeHook)
mainMenuSafe("seed MainNVM", mainMenuSeedBindings, "MainNVM")
mainMenuSafe("seed ExtraNVM", mainMenuSeedBindings, "ExtraNVM")
