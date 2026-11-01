local var_0_0 = native.EScoreType
local var_0_1 = native.EPlayerStatistic
local var_0_2 = {
	conversionOutcome = {
		showState = "ConversionShowOutcomeEvent",
		stateData = {
			hideStates = {
				"KickoffSetupEvent",
				"KickoffSetupRuleState"
			},
			eventParameters = {
				teamSide = "kickerSide",
				playerId = "kickerId"
			},
			statistics = {
				{
					statistic = tostring(var_0_1.conversions)
				},
				{
					statistic = tostring(var_0_1.conversionAttempts)
				}
			}
		}
	},
	scoreOutcome = {
		showState = "ScoreAttemptNotificationEvent",
		[var_0_0.Try] = {
			stateData = {
				-- nrl-broadcast-scoreboard: stock had no hideStates, so the first rule state after the
				-- celebration (replay, bunker...) reset the card while the HUD was still hidden. Keep it
				-- until the conversion is taken or play restarts; playerstatistics_hud.lua runs its 5s
				-- display timer only while the HUD is up.
				hideStates = {
					"ConversionKickRuleState",
					"PlayGoConversionKickRuleState",
					"KickoffSetupEvent",
					"KickoffSetupRuleState"
				},
				ignoreStates = {
					"TryCelebrateRuleState"
				},
				eventParameters = {
					teamSide = "side",
					scoreType = "scoreType",
					playerId = "maker"
				},
				statistics = {
					{
						statistic = tostring(var_0_1.tries)
					},
					{
						statistic = tostring(var_0_1.minutesPlayed)
					}
				}
			}
		},
		[var_0_0.BonusTry] = {
			stateData = {
				-- nrl-broadcast-scoreboard: stock had no hideStates, so the first rule state after the
				-- celebration (replay, bunker...) reset the card while the HUD was still hidden. Keep it
				-- until the conversion is taken or play restarts; playerstatistics_hud.lua runs its 5s
				-- display timer only while the HUD is up.
				hideStates = {
					"ConversionKickRuleState",
					"PlayGoConversionKickRuleState",
					"KickoffSetupEvent",
					"KickoffSetupRuleState"
				},
				ignoreStates = {
					"TryCelebrateRuleState"
				},
				eventParameters = {
					teamSide = "side",
					scoreType = "scoreType",
					playerId = "maker"
				},
				statistics = {
					{
						statistic = tostring(var_0_1.bonusTries)
					},
					{
						statistic = tostring(var_0_1.tries)
					},
					{
						statistic = tostring(var_0_1.minutesPlayed)
					}
				}
			}
		}
	}
}

import("core.foundation.tablex")

local var_0_3 = type(var_0_0)
local var_0_4

local function var_0_5(arg_1_0)
	if not arg_1_0 then
		return false
	end

	return type(arg_1_0) ~= "table"
end

local function var_0_6(arg_2_0)
	if not arg_2_0 then
		return nil
	end

	local var_2_0 = {}

	if type(arg_2_0) == "table" then
		for iter_2_0, iter_2_1 in pairs(arg_2_0) do
			if var_0_5(iter_2_1) then
				var_2_0[iter_2_1] = iter_2_1
			else
				var_2_0[iter_2_0] = iter_2_1
			end
		end
	end

	if tablex.count(var_2_0) == 0 then
		var_2_0 = nil
	end

	return var_2_0
end

local function var_0_7()
	return var_0_2 and tablex.count(var_0_2) > 0 or false
end

local function var_0_8()
	return var_0_4 and var_0_4.count and var_0_4.count > 0 or false
end

local function var_0_9(arg_5_0)
	return arg_5_0 and arg_5_0.showState ~= nil or false
end

local function var_0_10(arg_6_0)
	local var_6_0 = arg_6_0 and arg_6_0.eventParameters or nil
	local var_6_1 = arg_6_0 and arg_6_0.statistics or nil

	return var_6_0 and var_6_1 and tablex.count(var_6_0) > 0 and tablex.count(var_6_1) > 0 or false
end

local function var_0_11(arg_7_0)
	return arg_7_0 and var_0_10(arg_7_0.stateData) or false
end

local function var_0_12(arg_8_0)
	if arg_8_0 then
		for iter_8_0, iter_8_1 in pairs(arg_8_0) do
			if type(iter_8_1) == "table" then
				var_0_12(arg_8_0[iter_8_0])
			end

			if arg_8_0[iter_8_0] then
				arg_8_0[iter_8_0] = nil
			end
		end
	end
end

local function var_0_13()
	if var_0_8() then
		var_0_4 = nil
	end
end

local function var_0_14(arg_10_0)
	local var_10_0

	if arg_10_0 then
		local var_10_1 = type(arg_10_0)

		if var_10_1 ~= var_0_3 then
			if var_10_1 == "number" or var_10_1 == "string" then
				var_10_0 = var_0_0[arg_10_0]
			end
		else
			var_10_0 = arg_10_0
		end
	end

	return var_10_0
end

local function var_0_15(arg_11_0, arg_11_1)
	local var_11_0

	if not var_0_11(arg_11_0) then
		local var_11_1 = var_0_14(arg_11_1)

		if var_11_1 then
			var_11_0 = arg_11_0[var_11_1]
		end
	end

	return var_11_0
end

local function var_0_16(arg_12_0, arg_12_1)
	local var_12_0

	if var_0_11(arg_12_0) then
		var_12_0 = arg_12_0.stateData
	else
		local var_12_1 = var_0_15(arg_12_0, arg_12_1)

		if var_12_1 then
			var_12_0 = var_12_1.stateData
		end
	end

	return var_12_0
end

local function var_0_17(arg_13_0)
	local var_13_0 = {}

	if arg_13_0 then
		for iter_13_0, iter_13_1 in pairs(arg_13_0) do
			if type(iter_13_0) == var_0_3 then
				var_13_0[iter_13_0] = iter_13_0
			end
		end
	end

	if tablex.count(var_13_0) == 0 then
		var_13_0 = nil
	end

	return var_13_0
end

local function var_0_18(arg_14_0)
	return arg_14_0 and arg_14_0.scoreTypes or nil
end

local function var_0_19(arg_15_0)
	return arg_15_0 and arg_15_0.showState or nil
end

local function var_0_20(arg_16_0)
	return arg_16_0 and arg_16_0.hideStates or nil
end

local function var_0_21(arg_17_0)
	return arg_17_0 and arg_17_0.ignoreStates or nil
end

local function var_0_22(arg_18_0)
	return arg_18_0 and arg_18_0.eventParameters or nil
end

local function var_0_23(arg_19_0)
	return arg_19_0 and arg_19_0.statistics or nil
end

local function var_0_24(arg_20_0, arg_20_1)
	local var_20_0 = var_0_19(arg_20_0)
	local var_20_1 = var_0_16(arg_20_0, arg_20_1)
	local var_20_2 = var_0_20(var_20_1)
	local var_20_3 = var_0_21(var_20_1)

	return var_20_0, var_20_2, var_20_3
end

local function var_0_25(arg_21_0)
	local var_21_0, var_21_1, var_21_2 = var_0_24(arg_21_0, nil)
	local var_21_3 = var_0_18(arg_21_0)

	if var_21_3 then
		for iter_21_0, iter_21_1 in pairs(var_21_3) do
			local var_21_4 = var_0_16(arg_21_0, iter_21_1)
			local var_21_5 = var_0_20(var_21_4)
			local var_21_6 = var_0_21(var_21_4)

			if var_21_5 then
				var_21_1 = var_21_1 or {}

				for iter_21_2, iter_21_3 in pairs(var_21_5) do
					var_21_1[iter_21_3] = iter_21_3
				end
			end

			if var_21_6 then
				var_21_2 = var_21_2 or {}

				for iter_21_4, iter_21_5 in pairs(var_21_6) do
					var_21_2[iter_21_5] = iter_21_5
				end
			end
		end
	end

	return var_21_0, var_21_1, var_21_2
end

local function var_0_26(arg_22_0)
	local var_22_0 = {}
	local var_22_1, var_22_2, var_22_3 = var_0_25(arg_22_0)

	if var_22_1 then
		var_22_0[var_22_1] = var_22_1
	end

	if var_22_2 then
		for iter_22_0, iter_22_1 in pairs(var_22_2) do
			var_22_0[iter_22_1] = iter_22_1
		end
	end

	if var_22_3 then
		for iter_22_2, iter_22_3 in pairs(var_22_3) do
			var_22_0[iter_22_3] = iter_22_3
		end
	end

	if tablex.count(var_22_0) == 0 then
		var_22_0 = nil
	end

	return var_22_0
end

local function var_0_27(arg_23_0, arg_23_1)
	local var_23_0 = var_0_19(arg_23_0)

	return var_23_0 and arg_23_1 and var_23_0 == arg_23_1 or false
end

local function var_0_28(arg_24_0, arg_24_1)
	local var_24_0 = var_0_20(arg_24_0)

	return var_24_0 and arg_24_1 and var_24_0[arg_24_1] ~= nil or false
end

local function var_0_29(arg_25_0, arg_25_1)
	local var_25_0 = var_0_21(arg_25_0)

	return var_25_0 and arg_25_1 and var_25_0[arg_25_1] ~= nil or false
end

local function var_0_30()
	local var_26_0 = {}

	for iter_26_0, iter_26_1 in pairs(var_0_2) do
		local var_26_1 = {}

		if type(iter_26_1) == "table" and var_0_9(iter_26_1) then
			local var_26_2 = var_0_17(iter_26_1)

			if var_26_2 then
				for iter_26_2, iter_26_3 in pairs(var_26_2) do
					local var_26_3 = var_0_15(iter_26_1, iter_26_3)

					if var_26_3 and var_0_10(var_26_3.stateData) then
						if not var_26_1.scoreTypes then
							var_26_1.scoreTypes = {}
						end

						var_26_1.scoreTypes[iter_26_3] = iter_26_3
						var_26_1[iter_26_3] = {}
						var_26_1[iter_26_3].stateData = tablex.cloneNoMeta(var_26_3.stateData)

						if var_26_1[iter_26_3].stateData.hideStates then
							var_26_1[iter_26_3].stateData.hideStates = var_0_6(var_26_1[iter_26_3].stateData.hideStates)
						end

						if var_26_1[iter_26_3].stateData.ignoreStates then
							var_26_1[iter_26_3].stateData.ignoreStates = var_0_6(var_26_1[iter_26_3].stateData.ignoreStates)
						end
					end
				end

				if var_26_1.scoreTypes then
					var_26_1.showState = iter_26_1.showState
				end
			else
				local var_26_4 = iter_26_1.stateData

				if var_0_10(iter_26_1.stateData) then
					var_26_1.showState = iter_26_1.showState
					var_26_1.stateData = tablex.cloneNoMeta(iter_26_1.stateData)

					if var_26_1.stateData.hideStates then
						var_26_1.stateData.hideStates = var_0_6(var_26_1.stateData.hideStates)
					end

					if var_26_1.stateData.ignoreStates then
						var_26_1.stateData.ignoreStates = var_0_6(var_26_1.stateData.ignoreStates)
					end
				end
			end
		end

		if var_0_9(var_26_1) then
			var_26_1.allStates = var_0_26(var_26_1)
			var_26_0[iter_26_0] = var_26_1

			if not var_26_0.allStates then
				var_26_0.allStates = {}
			end

			for iter_26_4, iter_26_5 in pairs(var_26_1.allStates) do
				var_26_0.allStates[iter_26_5] = iter_26_5
			end

			if not var_26_0.count then
				var_26_0.count = 0
			end

			var_26_0.count = var_26_0.count + 1
		end
	end

	if not var_26_0.count then
		var_26_0 = nil
	end

	var_0_4 = var_26_0
end

local function var_0_31()
	if not var_0_7() then
		return nil
	end

	local var_27_0

	if not var_0_8() then
		var_0_30()
	end

	if var_0_8() then
		var_27_0 = var_0_4
	end

	return var_27_0
end

local function var_0_32(arg_28_0, arg_28_1)
	return arg_28_0 and arg_28_1 and type(arg_28_1) == "string" and arg_28_0.allStates[arg_28_1] ~= nil or false
end

local function var_0_33(arg_29_0, arg_29_1)
	local var_29_0 = var_0_18(arg_29_0)

	return var_29_0 and arg_29_1 and var_29_0[arg_29_1] ~= nil or false
end

local function var_0_34(arg_30_0)
	local var_30_0
	local var_30_1 = var_0_31()

	if var_0_32(var_30_1, arg_30_0) then
		for iter_30_0, iter_30_1 in pairs(var_30_1) do
			if type(iter_30_1) == "table" and var_0_27(iter_30_1, arg_30_0) then
				var_30_0 = iter_30_1

				break
			end
		end
	end

	return var_30_0
end

local function var_0_35(arg_31_0, arg_31_1)
	local var_31_0 = var_0_34(arg_31_0)

	return var_0_16(var_31_0, arg_31_1)
end

function getAllStates()
	local var_32_0 = var_0_31()

	return var_32_0 and var_32_0.allStates or nil
end

function getScoreTypes(arg_33_0)
	local var_33_0 = var_0_34(arg_33_0)

	return var_0_18(var_33_0)
end

function getShowState(arg_34_0)
	local var_34_0 = var_0_34(arg_34_0)

	return var_0_19(var_34_0)
end

function getHideStates(arg_35_0, arg_35_1)
	local var_35_0 = var_0_35(arg_35_0, arg_35_1)

	return var_0_20(var_35_0)
end

function getIgnoreStates(arg_36_0, arg_36_1)
	local var_36_0 = var_0_35(arg_36_0, arg_36_1)

	return var_0_21(var_36_0)
end

function getEventParameters(arg_37_0, arg_37_1)
	local var_37_0 = var_0_35(arg_37_0, arg_37_1)

	return var_0_22(var_37_0)
end

function getStatistics(arg_38_0, arg_38_1)
	local var_38_0 = var_0_35(arg_38_0, arg_38_1)

	return var_0_23(var_38_0)
end

function checkStateHasHideStates(arg_39_0, arg_39_1)
	return getHideStates(arg_39_0, arg_39_1) ~= nil
end

function checkStateHasIgnoreStates(arg_40_0, arg_40_1)
	return getIgnoreStates(arg_40_0, arg_40_1) ~= nil
end

function checkStateIsShowState(arg_41_0)
	local var_41_0 = getShowState(arg_41_0)

	return var_41_0 and var_41_0 == arg_41_0
end

function checkStateExists(arg_42_0)
	local var_42_0 = var_0_31()

	return var_0_32(var_42_0, arg_42_0)
end

function dispose()
	var_0_13()
end
