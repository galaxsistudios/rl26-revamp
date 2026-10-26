import("ai.playtheball.quickplaytheballhuman_mixin")
import("base.controller.controller")
import("ai.tackle.pushtacklehuman_mixin")
import("ai.tackle.ballstriptacklehuman_mixin")
import("ai.tackle.tryintacklehuman_mixin")

local var_0_0 = controller.Controller

controller.controllerclass("TackledDriveMonitorHuman", var_0_0, function(arg_1_0)
	var_0_0.init(arg_1_0)

	-- faster-play-the-ball: read the quick play-the-ball double-tap here too
	arg_1_0.quickPlayTheBallMixin = quickplaytheballhuman_mixin.QuickPlayTheBallHumanMixin()

	arg_1_0.pushTackleHumanMixin = pushtacklehuman_mixin.PushTackleHumanMixin()
	arg_1_0.ballStripTackleHumanMixin = ballstriptacklehuman_mixin.BallStripTackleHumanMixin()
	arg_1_0.tryInTackleMixin = tryintacklehuman_mixin.TryInTackleHumanMixin()
end)

function TackledDriveMonitorHuman.onEnter(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	arg_2_0.pushTackleHumanMixin:onEnter(arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	arg_2_0.ballStripTackleHumanMixin:onEnter(arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	arg_2_0.tryInTackleMixin:onEnter(arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
end

function TackledDriveMonitorHuman.update(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	arg_3_0.pushTackleHumanMixin:update(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	arg_3_0.ballStripTackleHumanMixin:update(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	arg_3_0.tryInTackleMixin:update(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)

	arg_3_0.quickPlayTheBallMixin:update(arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)

	return arg_3_0
end
