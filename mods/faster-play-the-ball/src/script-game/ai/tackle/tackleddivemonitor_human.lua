import("ai.playtheball.quickplaytheballhuman_mixin")
import("base.controller.controller")

local var_0_0 = controller.Controller

controller.controllerclass("TackledDiveMonitorHuman", var_0_0, function(arg_1_0)
	var_0_0.init(arg_1_0)

	-- faster-play-the-ball: read the quick play-the-ball double-tap here too
	arg_1_0.quickPlayTheBallMixin = quickplaytheballhuman_mixin.QuickPlayTheBallHumanMixin()
end)

function TackledDiveMonitorHuman.onEnter(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	return
end

function TackledDiveMonitorHuman.update(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	arg_3_0.quickPlayTheBallMixin:update(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)

	return arg_3_0
end
