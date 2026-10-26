import("rules.playtheball.playtheballentity_request")
import("design.playtheball_config")

local var_0_0 = playtheball_config.doubleTapWindow

-- early-defensive-retreat: double-tapping the left trigger (QuickPlayTheBall)
-- sends the line back 10 m. Stock only accepted it once the tackle had
-- collapsed and was 1/6 s into its current block, and only from
-- DefendingFreeRoamHuman. Now it works at any point of a tackle on the ball
-- carrier, and the mod also runs this mixin from the controlled-movement and
-- tackler controllers. playtheball_listener.lua clears the flag again if the
-- tackle is broken.

Class("QuickDefensivePlayTheBallHumanMixin", function(arg_1_0, arg_1_1)
	return
end)

function QuickDefensivePlayTheBallHumanMixin.onEnter(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	return
end

function QuickDefensivePlayTheBallHumanMixin.update(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	local var_3_0 = arg_3_1:getGamer(arg_3_5)

	if not var_3_0 then
		return
	end

	local var_3_2 = arg_3_7:getActiveTackleEntity():getMostRecentActiveTackle()

	if not var_3_2 then
		return
	end

	local var_3_6 = arg_3_7:getBallEntity()

	if not ((var_3_6 and var_3_6:getOwnerId(arg_3_10)) == var_3_2:getParticipantId(native.ETackleParticipantType.BallCarrier)) then
		return
	end

	local var_3_7 = var_3_0:getInputEvent("PlayTheBall", "QuickPlayTheBall") ~= nil

	if var_3_7 and not arg_3_7:getPlayTheBallEntity():getQuickDefensivePlayTheBall() then
		arg_3_11:add(playtheballentity_request.QuickDefensivePlayTheBallRequest({
			isDefensiveQuickPlayTheBall = var_3_7
		}))
	end
end
