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

-- coach-editor: true when an NPC (CReferee) is a coach. The identity's npcType can come back
-- as an int or an enum, depending on how the record was made.
function isCoachNPC(arg_ce_0)
	if arg_ce_0 == nil then
		return false
	end

	local var_ce_0, var_ce_1 = pcall(function()
		return arg_ce_0.identity:getOption("npcType")
	end)

	if not var_ce_0 or var_ce_1 == nil then
		var_ce_0, var_ce_1 = pcall(function()
			return arg_ce_0.identity.npcType
		end)
	end

	if not var_ce_0 or var_ce_1 == nil then
		return false
	end

	local var_ce_2, var_ce_3 = pcall(function()
		return var_ce_1:toInt()
	end)

	return (var_ce_2 and var_ce_3 or tonumber(var_ce_1)) == native.CNpcType.Coach:toInt()
end

-- coach-editor: the coach screens reuse referee string keys; swap the wording
local var_0_ce_words = {
	{ "An umpire", "A coach" },
	{ "an umpire", "a coach" },
	{ "Referees", "Coaches" },
	{ "referees", "coaches" },
	{ "REFEREES", "COACHES" },
	{ "Referee", "Coach" },
	{ "referee", "coach" },
	{ "REFEREE", "COACH" },
	{ "Umpires", "Coaches" },
	{ "umpires", "coaches" },
	{ "UMPIRES", "COACHES" },
	{ "Umpire", "Coach" },
	{ "umpire", "coach" },
	{ "UMPIRE", "COACH" }
}

local function var_0_ce_swap(arg_ce_1)
	if type(arg_ce_1) ~= "string" then
		return arg_ce_1
	end

	for iter_ce_0, iter_ce_1 in ipairs(var_0_ce_words) do
		arg_ce_1 = string.gsub(arg_ce_1, iter_ce_1[1], iter_ce_1[2])
	end

	return arg_ce_1
end

function coachText(arg_ce_2)
	return var_0_ce_swap(native.Localise(arg_ce_2))
end

-- localised text for an NPC: coach wording when it's a coach
function npcText(arg_ce_3, arg_ce_4)
	if isCoachNPC(arg_ce_3) then
		return coachText(arg_ce_4)
	end

	return native.Localise(arg_ce_4)
end

function coachTiles(arg_ce_5)
	for iter_ce_2, iter_ce_3 in ipairs(arg_ce_5) do
		iter_ce_3.title = var_0_ce_swap(iter_ce_3.title)
		iter_ce_3.description = var_0_ce_swap(iter_ce_3.description)
	end

	return arg_ce_5
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

		local var_7_5 = arg_7_1 == native.CSex.Female

		var_7_4 = native.CVisualConfig("team")

		var_7_4:copy(arg_7_4:get(var_7_5 and native.DefaultTeamVisuals.NewCustomFemale or native.DefaultTeamVisuals.NewCustomMale))
		var_7_4:setOption("uniformTop", var_7_5 and 20101 or 20001)
		var_7_4:setOption("uniformBottom", var_7_5 and 20102 or 20002)

		for iter_7_0, iter_7_1 in ipairs({
			"topType",
			"topPatternLayer01",
			"topPatternLayer02",
			"topPatternLayer03",
			"showTeamLogo"
		}) do
			pcall(var_7_4.setOption, var_7_4, iter_7_1, 0)
		end
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
