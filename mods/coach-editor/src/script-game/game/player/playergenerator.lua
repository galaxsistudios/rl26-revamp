import("core.foundation.tablex")

local function var_0_0(arg_1_0, arg_1_1, arg_1_2)
	arg_1_0:setOption(arg_1_1, arg_1_2)
end

function bogStandardIdentity(arg_2_0, arg_2_1, arg_2_2)
	local function var_2_0(arg_3_0, arg_3_1)
		var_0_0(arg_2_1, arg_3_0, arg_3_1)
	end

	local var_2_1 = "Smith"
	local var_2_2 = arg_2_0:getDialogueWildcardHashManager():getMap("surnames")
	local var_2_3 = var_2_2:getParsedWildcardString(var_2_1)

	var_2_0("sex", arg_2_2.toInt)
	var_2_0("firstname", arg_2_2 == native.CSex.Female and "Jane" or "John")
	var_2_0("surname", var_2_1)
	var_2_0("shirtNumber", 9)
	var_2_0("shirtName", "SMITH")
	var_2_0("commentaryNameHash", var_2_2:getHash(var_2_3))
	var_2_0("countryOfBirth", native.EAffiliations.Australia:toInt())
end

function bogStandardPlayer(arg_4_0, arg_4_1, arg_4_2, arg_4_3)
	return bogStandardPlayerWithEthnicity(arg_4_0, arg_4_1, arg_4_2, native.DefaultVisualsCricket1.Caucasian, arg_4_3)
end

function bogStandardPlayerWithEthnicity(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4)
	local var_5_0 = tostring(arg_5_3)

	ASSERT(native.DefaultPlayerVisuals[var_5_0] or native.DefaultVisualsCricket1[var_5_0])
	bogStandardIdentity(arg_5_0, arg_5_1.identity, arg_5_2)
	arg_5_1.attributes:setAllThatCountTowardsBudgetToValue(native.CPlayerAttributes.PLAYER_ATTRIBUTE_MIN)

	local var_5_1 = native.DefaultPlayerVisuals[var_5_0] or native.DefaultPlayerVisuals["Player" .. tostring(arg_5_2.value) .. tostring(var_5_0)]

	ASSERT(var_5_1)

	local var_5_2 = arg_5_4:get(var_5_1)

	arg_5_1.visual:copy(var_5_2)
	arg_5_1:heightWeight_SetAttributesFromVisual()

	return arg_5_1
end

function createBogStandardNPC(arg_6_0, arg_6_1, arg_6_2, arg_6_3)
	createBogStandardNPCWithEthnicity(arg_6_0, arg_6_1, native.DefaultPlayerVisuals.RefereeMaleCaucasian, arg_6_2, arg_6_3)
end

function createBogStandardNPCWithEthnicity(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4)
	local var_7_0 = native.CReferee()
	local var_7_1 = var_7_0.identity

	local function var_7_2(arg_8_0, arg_8_1)
		var_0_0(var_7_1, arg_8_0, arg_8_1)
	end

	var_7_2("sex", arg_7_1.toInt)
	var_7_2("firstname", arg_7_1 == native.CSex.Female and "Jane" or "John")
	var_7_2("surname", "Smith")
	var_7_2("npcType", arg_7_0:toInt())
	var_7_2("number", 1)
	var_7_2("voice", 1)

	local var_7_3
	local var_7_4

	if arg_7_0 == native.CNpcType.Coach then
		var_7_3 = arg_7_2

		local var_7_5 = {
			native.DefaultTeamVisuals.Coach_Suit,
			native.DefaultTeamVisuals.Coach_TrackSuit
		}
		local var_7_6 = tablex.randomelement(var_7_5)

		var_7_4 = arg_7_4:get(var_7_6)
	elseif arg_7_0 == native.CNpcType.Referee then
		local var_7_7 = arg_7_1 == native.CSex.Male and native.DefaultTeamVisuals.NewCustomMale or native.DefaultTeamVisuals.NewCustomFemale

		var_7_4 = arg_7_4:get(var_7_7)
		var_7_3 = arg_7_2
	else
		ASSERT(false)
	end

	local var_7_8 = arg_7_3:get(var_7_3)

	var_7_0.visual:copy(var_7_8)
	var_7_0.uniform:copy(var_7_4)
	var_7_0:setNPCHeightWeightIdentityFromVisual()

	return var_7_0
end
