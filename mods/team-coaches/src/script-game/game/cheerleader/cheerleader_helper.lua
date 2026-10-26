import("base.side.sidehelper")
import("game.cheerleader.cheerleadertype")
import("script-config.design.cheerleader_config")

local var_0_0 = load("intermediatelua.visualconfig.cheerleader-defaults")
local var_0_1 = var_0_0.LicensedMap
local var_0_2 = var_0_0.DefaultUniform

function positionCheerleaders(arg_1_0, arg_1_1, arg_1_2, arg_1_3)
	local var_1_0 = arg_1_1.components.matchInData.groundInfo.ground
	local var_1_1 = cheerleader_config.positionInfo[var_1_0] or cheerleader_config.positionInfo.default

	for iter_1_0, iter_1_1 in arg_1_2:activeObjects(cheerleadertype.TypeId) do
		if iter_1_1.side == sidehelper.away then
			var_1_1 = cheerleader_config.positionInfoGf[var_1_0] or cheerleader_config.positionInfoGf.default

			break
		end
	end

	local var_1_2 = {
		1,
		1
	}

	for iter_1_2, iter_1_3 in arg_1_2:activeObjects(cheerleadertype.TypeId) do
		local var_1_3 = iter_1_3.side
		local var_1_4 = var_1_2[var_1_3]

		var_1_2[var_1_3] = var_1_4 + 1

		local var_1_5 = var_1_1[var_1_3]
		local var_1_6 = VERIFY(var_1_5.pos[var_1_4])
		local var_1_7 = native.vec2(var_1_6.x, var_1_6.y)
		local var_1_8 = VERIFY(var_1_5.facing)
		local var_1_9 = native.normalize2(native.vec2(var_1_8.x, var_1_8.y))

		iter_1_3:resetTo(var_1_7, var_1_9, arg_1_3)
	end
end

function colourCheerleaders(arg_2_0, arg_2_1, arg_2_2)
	local var_2_0

	if arg_2_0:getIsReadOnly(arg_2_1) then
		var_2_0 = var_0_1[arg_2_2]

		formatPrint("uniform is a licensed one - %s - %s", arg_2_2, tostring(var_2_0))
	end

	local function var_2_1(arg_3_0)
		return native.vec4(arg_3_0.r / 255, arg_3_0.g / 255, arg_3_0.b / 255, 1)
	end

	if var_2_0 then
		local var_2_2 = var_0_0.min
		local var_2_3 = var_0_0.max - var_2_2

		arg_2_0.cheerleaderTexture = var_2_0.cheerleaderTexture
		arg_2_0.cheerleaderColour1 = var_2_1(var_2_0.cheerleaderColour1) * var_2_3 + native.vec4(var_2_2, var_2_2, var_2_2, var_2_2)
		arg_2_0.cheerleaderColour2 = var_2_1(var_2_0.cheerleaderColour2) * var_2_3 + native.vec4(var_2_2, var_2_2, var_2_2, var_2_2)
		arg_2_0.cheerleaderColour3 = var_2_1(var_2_0.cheerleaderColour3) * var_2_3 + native.vec4(var_2_2, var_2_2, var_2_2, var_2_2)
		arg_2_0.cheerleaderColour4 = var_2_1(var_2_0.cheerleaderColour4) * var_2_3 + native.vec4(var_2_2, var_2_2, var_2_2, var_2_2)
		arg_2_0.cheerleaderTop = var_2_0.cheerleaderTop
		arg_2_0.cheerleaderBottom = var_2_0.cheerleaderBottom
	else
		arg_2_0.cheerleaderTexture = var_0_2.cheerleaderTexture
		arg_2_0.cheerleaderTop = var_0_2.cheerleaderTop
		arg_2_0.cheerleaderBottom = var_0_2.cheerleaderBottom
		arg_2_0.cheerleaderColour1 = var_2_1(native.Colour(255, 89, 168))
		arg_2_0.cheerleaderColour2 = var_2_1(native.Colour(255, 255, 255))
		arg_2_0.cheerleaderColour3 = var_2_1(native.Colour(0, 0, 0))
		arg_2_0.cheerleaderColour4 = var_2_1(native.Colour(255, 89, 168))
	end
end

-- team-coaches: every reposition wipe calls positionCheerleaders, so the
-- sideline coaches are placed (and re-skinned once per match) right after it.
import("game.coach.coach_helper")

local var_tc_positionCheerleaders = positionCheerleaders

function positionCheerleaders(arg_tc_0, arg_tc_1, arg_tc_2, arg_tc_3)
	var_tc_positionCheerleaders(arg_tc_0, arg_tc_1, arg_tc_2, arg_tc_3)

	local var_tc_0, var_tc_1 = pcall(coach_helper.positionSidelineCoaches, arg_tc_0, arg_tc_1, arg_tc_2, arg_tc_3)

	if not var_tc_0 then
		coach_helper.sidelineLog("positionSidelineCoaches failed: %s", tostring(var_tc_1))
	end
end
