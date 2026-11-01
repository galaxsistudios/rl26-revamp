import("ai.formation.formation_request")
import("base.rulestate.rulestateclass")
import("base.side.sidehelper")
import("core.foundation.class")
import("core.marshalling.types")
import("game.camera.camerahelper")
import("game.player.playertype")
import("game.umpire.umpiretype")
import("rules.match.resumegeneralgameplay_request")
import("rules.match.matchtime")
import("rules.rules.rules")
import("rules.rulestate.rulestate_request")
import("rules.gameevent.collectball_detect")
import("ai.scrum.scrumentity_request")
import("rules.scrum.scrum_setup_rulestate")

local var_0_0 = "scrum"

rulestateclass.rulestateclass("ScrumRuleState", function(arg_1_0, arg_1_1)
	for iter_1_0, iter_1_1 in pairs(ScrumRuleState.MemberDefinitions) do
		arg_1_0[iter_1_0] = arg_1_1[iter_1_0]
	end
end).MemberDefinitions = {
	sideWithFeed = types.SignedInteger,
	scrumPosition = types.Vec2,
	scrumReceiverId = types.ObjectId,
	directionOfPlay = types.Vec2
}

function ScrumRuleState.apply(arg_2_0, arg_2_1, arg_2_2)
	matchtime.startRealTime(arg_2_1, arg_2_2)
end

-- scrum-feed-control: after the feed, players outside the scrum can still be switched to (the
-- feeding side starts on the receiver, as stock).
local function var_0_controlSession(arg_self)
	local var_control = rawget(_G, "ScrumControlState")
	local var_session = var_control and var_control.session

	if var_session and var_session.phase == "scrum" and not var_session.finished and (not arg_self or var_session.id == arg_self.sessionId) then
		return var_session, var_control
	end
end

function ScrumRuleState.getBlockSwitchingGamers(arg_3_0, arg_3_1)
	return var_0_controlSession() == nil
end

function ScrumRuleState.switchingGetPriorityTargetForSide(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4)
	if arg_4_1 == arg_4_0.sideWithFeed then
		return arg_4_0.scrumReceiverId
	end
end

function ScrumRuleState.onEnterSolid(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7, arg_5_8, arg_5_9, arg_5_10)
	local var_5_session = var_0_controlSession()

	if var_5_session then
		arg_5_0.sessionId = var_5_session.id
	end

	local var_5_0 = arg_5_3.gameplayCameras:getGroup("gameplay").activeCamera
	local var_5_1 = arg_5_3.cameraManager
	local var_5_2 = arg_5_0.scrumPosition
	local var_5_3 = var_5_2:tovec3(0.1)
	local var_5_4 = var_5_3 + native.vec3(0, 2, 0)

	camerahelper.SetActiveCameraGroup("scrum", arg_5_0.scrumReceiverId, arg_5_0.sideWithFeed, arg_5_1.engine, arg_5_3, arg_5_5, arg_5_7, var_5_4, var_5_3)

	local var_5_5 = arg_5_3.knowledgeBank.playerScrumInfoPool

	for iter_5_0, iter_5_1 in arg_5_3.gamers:iterLocalGamers() do
		local var_5_6 = arg_5_3.hud and arg_5_3.hud:getElement("playermarkers")

		if var_5_6 then
			var_5_6:enableMarkerForGamer(iter_5_1)
			var_5_6:show()
		end
	end

	for iter_5_2, iter_5_3 in arg_5_7:activeObjects(playertype.TypeId) do
		if var_5_5:get(iter_5_2):checkForValidId() then
			iter_5_3:setBehaviour("Master", arg_5_8)
		else
			iter_5_3:setBehaviour("Scrum", arg_5_8)
		end
	end

	for iter_5_4, iter_5_5 in arg_5_7:activeObjects(umpiretype.TypeId) do
		iter_5_5:setBehaviour("Master", arg_5_8)
	end

	local var_5_7 = arg_5_3.soundSystem

	if var_5_7 then
		var_5_7:queueSoundOnlyEvent({
			type = "ScrumEvent",
			time = arg_5_8,
			scrumPosition = var_5_2,
			directionOfPlay = arg_5_0.directionOfPlay
		})
	end
end

function ScrumRuleState.onExitSolid(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8, arg_6_9, arg_6_10)
	local var_6_session, var_6_control = var_0_controlSession(arg_6_0)

	if var_6_session then
		var_6_session.finished = true

		var_6_control.scrumBallOut(arg_6_8)
		var_6_control.hideOffsideOverlay(arg_6_3)
	end

	local var_6_0 = arg_6_3.gameplayCameras:getGroup("gameplay").activeCamera

	var_6_0:removeZoomProvider(var_0_0)
	var_6_0:removeInterpolationPointProvider(var_0_0)
	native.CPoolWipeHandler.wipeIncapacitatedInfoPool(arg_6_6:getIncapacitatedInfoPool(), arg_6_6)
end

function ScrumRuleState.updateSolid(arg_7_0, arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5, arg_7_6, arg_7_7, arg_7_8, arg_7_9, arg_7_10, arg_7_11)
	return
end

-- scrum-feed-control: offside line until the ball is out.
function ScrumRuleState.createRules(arg_self, arg_1, arg_time)
	local var_rules = rules.Rules()

	var_rules:add(scrum_setup_rulestate.ScrumControlDetect(arg_self))

	return var_rules
end

function ScrumRuleState.controlUpdate(arg_self, arg_session, arg_gamers, arg_services, arg_guid, arg_match, arg_gamestate, arg_gameobjects, arg_dt, arg_time, arg_requests)
	local var_control = rawget(_G, "ScrumControlState")

	arg_session.elapsed = (arg_session.elapsed or 0) + arg_dt

	var_control.runAiLineMoves(arg_session, arg_services, arg_guid, arg_gameobjects, arg_time, arg_requests)
	var_control.trackScrumOffside(arg_session, arg_gameobjects)
	var_control.updateOffsideOverlay(arg_services, arg_gamers)
end

function ScrumRuleState.addSolidRules(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5)
	local function var_8_0(arg_9_0, arg_9_1, arg_9_2, arg_9_3, arg_9_4, arg_9_5, arg_9_6, arg_9_7, arg_9_8)
		formatPrint("[scrumtest] Collect ball in scrum detected")

		-- scrum-feed-control: ball out, the offside line ends.
		local var_9_control = rawget(_G, "ScrumControlState")

		if var_9_control and var_9_control.scrumBallOut then
			var_9_control.scrumBallOut(arg_9_6)
		end
		arg_9_7:add(scrumentity_request.ScrumEntityCollectFinishedRequest())

		local var_9_0 = arg_9_4:getMatchProgressionEntity()
		local var_9_1 = {
			isZeroTackle = false,
			attackingSide = arg_8_0.sideWithFeed,
			disposalType = native.EDisposalType.Pass,
			disposalSubType = native.EDisposalSubType.None,
			tackleCount = var_9_0.tackleCount,
			tackleSetStartPosition = var_9_0.tackleSetStartPosition,
			playStartPosition = arg_8_0.scrumPosition
		}

		arg_9_7:add(resumegeneralgameplay_request.ResumeGeneralGameplayRequest(var_9_1))
		arg_9_7:add(formation_request.ClearFormationRequest({
			side = sidehelper.home
		}))
		arg_9_7:add(formation_request.ClearFormationRequest({
			side = sidehelper.away
		}))

		local var_9_2 = arg_9_1.gameplayCameras:getGroup("gameplay").activeCamera

		var_9_2:removeZoomProvider(var_0_0)
		var_9_2:removeInterpolationPointProvider(var_0_0)

		local var_9_3 = class.instantiate("GeneralGameplayRuleState", var_9_1)

		arg_9_7:add(rulestate_request.RuleStateRequest(var_9_3, arg_9_2:alloc()))
	end

	local var_8_1 = arg_8_5 or rules.Rules()

	var_8_1:add(collectball_detect.CollectBallDetect(var_8_0, native.EDisposalSubType.None))

	return var_8_1
end
