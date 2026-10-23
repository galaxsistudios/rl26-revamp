import("app.academy.academy_helper")
import("app.academy.academy_referee_hub_create")
import("app.noesis.controls.nvm_buttonMenu")
import("game.player.playergenerator")

local var_0_0 = native.DefaultPlayerVisuals

Class("AcademyRefereeCreateEthnicityState")

local function var_0_1(arg_1_0)
	local var_1_0 = arg_1_0 == native.CSex.Male
	local var_1_1 = var_1_0 and var_0_0.RefereeMaleCaucasian or var_0_0.RefereeFemaleCaucasian
	local var_1_2 = var_1_0 and var_0_0.RefereeMaleIndian or var_0_0.RefereeFemaleIndian
	local var_1_3 = var_1_0 and var_0_0.RefereeMaleAfrican or var_0_0.RefereeFemaleAfrican
	local var_1_4 = var_1_0 and var_0_0.RefereeMaleAsian or var_0_0.RefereeFemaleAsian
	local var_1_5 = var_1_0 and var_0_0.RefereeMaleIslander or var_0_0.RefereeFemaleIslander
	local var_1_6 = var_1_0 and var_0_0.RefereeMaleMiddleEastern or var_0_0.RefereeFemaleMiddleEastern

	return {
		{
			useBackgroundUV = true,
			twoCutoff = true,
			useBaseColour = false,
			title = native.Localise("Caucasian"),
			image = var_1_0 and "academy/referees/ethnicity/caucasian" or "academy/referees/female ethnicity/caucasian",
			stateFactory = academy_referee_hub_create.AcademyRefereeCreateState,
			stateData = {
				sex = arg_1_0,
				ethnicity = var_1_1
			},
			stateDataCompareFn = function(arg_2_0)
				return arg_2_0.ethnicity == var_1_1
			end
		},
		{
			useBackgroundUV = true,
			twoCutoff = true,
			useBaseColour = false,
			title = native.Localise("Indian"),
			image = var_1_0 and "academy/referees/ethnicity/asian" or "academy/referees/female ethnicity/asian",
			stateFactory = academy_referee_hub_create.AcademyRefereeCreateState,
			stateData = {
				sex = arg_1_0,
				ethnicity = var_1_2
			},
			stateDataCompareFn = function(arg_3_0)
				return arg_3_0.ethnicity == var_1_2
			end
		},
		{
			useBackgroundUV = true,
			twoCutoff = true,
			useBaseColour = false,
			title = native.Localise("African"),
			image = var_1_0 and "academy/referees/ethnicity/african" or "academy/referees/female ethnicity/african",
			stateFactory = academy_referee_hub_create.AcademyRefereeCreateState,
			stateData = {
				sex = arg_1_0,
				ethnicity = var_1_3
			},
			stateDataCompareFn = function(arg_4_0)
				return arg_4_0.ethnicity == var_1_3
			end
		},
		{
			useBackgroundUV = true,
			twoCutoff = true,
			useBaseColour = false,
			title = native.Localise("Asian"),
			image = var_1_0 and "academy/referees/ethnicity/southeastasian" or "academy/referees/female ethnicity/southeastasian",
			stateFactory = academy_referee_hub_create.AcademyRefereeCreateState,
			stateData = {
				sex = arg_1_0,
				ethnicity = var_1_4
			},
			stateDataCompareFn = function(arg_5_0)
				return arg_5_0.ethnicity == var_1_4
			end
		},
		{
			useBackgroundUV = true,
			twoCutoff = true,
			useBaseColour = false,
			title = native.Localise("Islander"),
			image = var_1_0 and "academy/referees/ethnicity/islander" or "academy/referees/female ethnicity/islander",
			stateFactory = academy_referee_hub_create.AcademyRefereeCreateState,
			stateData = {
				sex = arg_1_0,
				ethnicity = var_1_5
			},
			stateDataCompareFn = function(arg_6_0)
				return arg_6_0.ethnicity == var_1_5
			end
		},
		{
			useBackgroundUV = true,
			twoCutoff = true,
			useBaseColour = false,
			title = native.Localise("MiddleEastern"),
			image = var_1_0 and "academy/referees/ethnicity/middleeastern" or "academy/referees/female ethnicity/middleeastern",
			stateFactory = academy_referee_hub_create.AcademyRefereeCreateState,
			stateData = {
				sex = arg_1_0,
				ethnicity = var_1_6
			},
			stateDataCompareFn = function(arg_7_0)
				return arg_7_0.ethnicity == var_1_6
			end
		}
	}
end

function AcademyRefereeCreateEthnicityState.enter(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5, arg_8_6, arg_8_7, arg_8_8, arg_8_9, arg_8_10, arg_8_11)
	arg_8_0.goBackFactoryStack = arg_8_8

	local var_8_0 = arg_8_5:getDefaultTeamVisualManager()
	local var_8_1 = arg_8_5:getDefaultPlayerVisualManager()
	local var_8_2 = arg_8_2:getNoesis()
	local var_8_3 = VERIFY(arg_8_7.sex)

	arg_8_0.viewModel = nvm_buttonMenu.NVMButtonMenu()

	arg_8_0.viewModel:populateMenu(var_0_1(var_8_3))

	arg_8_0.view = var_8_2:loadViewWithVM("Workspace/Views/Academy/paAcademyPresetView", arg_8_0.viewModel, native.ENoesisViewManagerLayer.POST_SCENE, native.CNoesisViewManager.DefaultPriority)
	arg_8_0.sex = var_8_3
	arg_8_0.npcType = arg_8_7.npcType or native.CNpcType.Referee

	local var_8_4 = arg_8_0.viewModel:getHighlightedTile()
	local var_8_5 = VERIFY(var_8_4.stateData.ethnicity)
	local var_8_6 = playergenerator.createBogStandardNPCWithEthnicity(arg_8_0.npcType, var_8_3, var_8_5, var_8_1, var_8_0)

	arg_8_0.lastHighlightedEthnicity = var_8_5

	arg_8_5:setPlayerModelProps(1, nil)

	arg_8_0.originalPlayerDrawnEnabledState = arg_8_5:playerModelUpdate(1, {
		draw = true,
		resetOptions = true,
		rotationEnabled = true,
		refresh = true,
		camera = "HeadAndShoulders_OutsideOfAppearance",
		referee = var_8_6,
		characterVisualOptions = academy_helper.VisualConfigSets.RefereeDefault
	})

	arg_8_5:toggleLockerRoomVisibility(true)
end

function AcademyRefereeCreateEthnicityState.update(arg_9_0, arg_9_1, arg_9_2, arg_9_3, arg_9_4, arg_9_5, arg_9_6, arg_9_7, arg_9_8)
	if arg_9_6:updateBlockingMixins(arg_9_2, arg_9_3, arg_9_4, arg_9_5, arg_9_7) then
		return
	end

	local var_9_0, var_9_1 = arg_9_0.viewModel:update(arg_9_6, arg_9_8.partyMember)
	local var_9_2 = arg_9_0.viewModel:getHighlightedTile()
	local var_9_3 = VERIFY(var_9_2.stateData.ethnicity)

	if var_9_0 then
		local var_9_4 = arg_9_0.goBackFactoryStack

		if var_9_1 then
			local var_9_5 = {
				sex = VERIFY(var_9_1.stateData.sex),
				ethnicity = VERIFY(var_9_1.stateData.ethnicity),
				npcType = arg_9_0.npcType
			}

			var_9_4 = var_9_4 or {}

			arg_9_6:playSound("Select")
			table.insert(var_9_4, arg_9_0.__proto)
			arg_9_1:changeState(var_9_1.stateFactory(), arg_9_2, arg_9_3, arg_9_5, arg_9_6, arg_9_8, var_9_5, var_9_4)
		else
			arg_9_6:playSound("Back")
			arg_9_1:changeState(nil, arg_9_2, arg_9_3, arg_9_5, arg_9_6, arg_9_8)
		end
	elseif var_9_3 ~= arg_9_0.lastHighlightedEthnicity then
		formatPrint("[Debug] Ethnicity tile changed")

		arg_9_0.lastHighlightedEthnicity = var_9_3

		local var_9_6 = arg_9_6:getDefaultPlayerVisualManager()
		local var_9_7 = arg_9_6:getDefaultTeamVisualManager()
		local var_9_8 = playergenerator.createBogStandardNPCWithEthnicity(arg_9_0.npcType, var_9_2.stateData.sex, var_9_3, var_9_6, var_9_7)

		arg_9_0.originalPlayerDrawnEnabledState = arg_9_6:playerModelUpdate(1, {
			draw = true,
			resetOptions = true,
			rotationEnabled = true,
			refresh = true,
			referee = var_9_8,
			characterVisualOptions = academy_helper.VisualConfigSets.RefereeDefault
		})
	end
end

function AcademyRefereeCreateEthnicityState.exit(arg_10_0, arg_10_1, arg_10_2, arg_10_3, arg_10_4, arg_10_5)
	arg_10_4:toggleLockerRoomVisibility(false)
	arg_10_4:playerModelUpdate(1, {
		draw = false,
		refresh = true,
		resetOptions = true
	})
	arg_10_0.viewModel:dispose()
	arg_10_0.view:release()
end
