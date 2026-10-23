import("base.rulestate.rulestateclass")
import("core.marshalling.types")
import("game.player.playertype")
import("game.scoring.scoretypes")
import("base.event.eventoccurred_request")
import("sim.hud.hud_helper")
import("game.cutscenes.cutscene_helper")
import("game.humanoid.humanoidtype")
import("game.cutscenes.cutsceneplayevent_request")

local var_0_0 = 10
local var_0_signatureChancePercent = 50
local var_0_signatureCelebrations = {
	jackhowarth = "rl1_try_jack_howarth_celebration",
	suafaalogo = "rl1_try_sua_faalogo_celebration",
	harrygrant = "rl1_try_harry_grant_celebration",
	cameronmunster = "rl1_try_cameron_munster_celebration",
	jahromehughes = "rl1_try_jahrome_hughes_celebration",
	nickmeaney = "rl1_try_nick_meaney_celebration",
	joshking = "rl1_try_josh_king_celebration",
	tyranwishart = "rl1_try_tyran_wishart_celebration",
	mosesleo = "rl1_try_moses_leo_celebration",
	shawnblore = "rl1_try_shawn_blore_celebration",
	willwarbrick = "rl1_try_will_warbrick_celebration",
	alecmacdonald = "rl1_try_alec_macdonald_celebration",
	xaviercoates = "rl1_try_xavier_coates_celebration",
	joechan = "rl1_try_joe_chan_celebration",
	tuikamikamica = "rl1_try_tui_kamikamica_celebration",
}

-- Storm players' own celebration (cutsceneStormPromo clips), standing tries only.
local function var_0_getSignatureCelebration(arg_0_0, arg_0_1, arg_0_2)
	if arg_0_1 then
		return nil
	end

	local var_0_identity = arg_0_0 and arg_0_0.identity
	local var_0_fullName = var_0_identity and var_0_identity.fullName

	if type(var_0_fullName) ~= "string" then
		return nil
	end

	local var_0_key = string.gsub(string.lower(var_0_fullName), "[^a-z]", "")
	local var_0_cutscene = var_0_signatureCelebrations[var_0_key]

	if var_0_cutscene and var_0_signatureChancePercent < 100 and native.Random.FromTimeValue(arg_0_2):randomIntegerRange(1, 100) > var_0_signatureChancePercent then
		return nil
	end

	return var_0_cutscene
end

rulestateclass.rulestateclass("TryCelebrateRuleState", function(arg_1_0, arg_1_1)
	for iter_1_0, iter_1_1 in pairs(TryCelebrateRuleState.MemberDefinitions) do
		arg_1_0[iter_1_0] = arg_1_1[iter_1_0]
	end
end).MemberDefinitions = {
	nextState = types.RuleState,
	scorer = types.ObjectId,
	randomSeed = types.SignedInteger,
	quickCutToCutscene = types.Boolean,
	playersWithinRange = types.Nilable(types.Array(types.ObjectId)),
	queueReplay = types.Boolean,
	playerIsOnGround = types.Boolean,
	guid = types.Guid
}
TryCelebrateRuleState.HideBallMarkers = true
TryCelebrateRuleState.HidePlayerMarkers = true

function TryCelebrateRuleState.onEnterSolid(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	local var_2_0 = arg_2_0.scorer
	local var_2_1 = {}
	local var_2_2 = arg_2_6:getRoleInfoPool()
	local var_2_3 = arg_2_7:getGameObject(var_2_0)
	local var_2_4 = var_2_3.side
	local var_2_5 = 0

	for iter_2_0, iter_2_1 in arg_2_7:activeObjects(playertype.TypeId) do
		if iter_2_1.side == var_2_4 and iter_2_0 ~= var_2_0 then
			local var_2_6 = var_2_2:get(iter_2_0)

			if var_2_6 and var_2_6.assignedRole ~= native.EAssignedRole.Substitute then
				local var_2_7 = native.distance2(iter_2_1.pos, var_2_3.pos)
				local var_2_8 = {
					id = iter_2_0,
					dist = var_2_7
				}

				table.insert(var_2_1, var_2_8)
			end
		end
	end

	table.sort(var_2_1, function(arg_3_0, arg_3_1)
		return arg_3_0.dist < arg_3_1.dist
	end)

	local var_2_9 = {
		var_2_0
	}

	for iter_2_2, iter_2_3 in ipairs(var_2_1) do
		table.insert(var_2_9, iter_2_3.id)
	end

	local var_2_10 = native.createTable(64, 0)

	for iter_2_4, iter_2_5 in arg_2_7:activeObjects(humanoidtype.TypeId) do
		table.insert(var_2_10, iter_2_4)
	end

	local var_2_11 = arg_2_6:getScoreEntity()
	local var_2_12 = arg_2_6:getMatchTimeEntity()
	local var_2_13 = arg_2_5.matchInData
	local var_2_14 = arg_2_5.matchInfo
	local var_2_15 = var_2_11:getMargin(var_2_13)
	local var_2_16 = var_2_4 == var_2_11:getWinningSide(var_2_13)
	local var_2_17

	var_2_17 = var_2_16 and var_2_15 <= 5

	local var_2_18 = not var_2_16 and var_2_15 < 2
	local var_2_19 = var_2_14:getMatchSecondsRemaining(arg_2_6, arg_2_8) / 60 <= 10
	local var_2_20 = var_2_12.goldenTryActive
	local var_2_21 = "TryCelebrate"

	if arg_2_0.playerIsOnGround then
		var_2_21 = var_2_21 .. "Ground"
	else
		var_2_21 = var_2_21 .. "Standing"
	end

	local var_2_22 = var_2_20 or var_2_19 and var_2_16 or var_2_19 and var_2_18
	local var_2_23 = not var_2_16 and var_2_15 >= 9

	if var_2_22 then
		var_2_21 = var_2_21 .. "_high"
	elseif var_2_23 then
		var_2_21 = var_2_21 .. "_low"
	end

	var_2_21 = var_0_getSignatureCelebration(var_2_3, arg_2_0.playerIsOnGround, arg_2_8) or var_2_21

	local var_2_24 = var_2_13.matchType.usingBonusTry or false

	arg_2_10:add(eventoccurred_request.EventOccurredRequest("ScoreAttemptNotificationEvent", {
		maker = var_2_0,
		side = var_2_4,
		scoreType = var_2_24 and scoretypes.BonusTry or scoretypes.Try
	}))

	local function var_2_25(arg_4_0, arg_4_1, arg_4_2)
		hud_helper.showScorerNotificationHudOnCameraTransition(arg_2_3, arg_2_7, arg_4_0, arg_4_1, arg_4_2)
	end

	local var_2_26 = var_2_3.pos.x < 0 and -1 or 1
	local var_2_27 = arg_2_0.guid

	arg_2_10:add(cutsceneplayevent_request.CutscenePlayEventRequest({
		cutsceneName = var_2_21,
		targetIds = var_2_9,
		hideIds = var_2_10,
		guid = var_2_27:derive(69),
		onFinishedState = arg_2_0.nextState,
		onCameraChange = var_2_25,
		constrainBounds = cutscene_helper.getSafeCutsceneConstrainBounds(),
		goalPostBounds = cutscene_helper.getCutsceneGoalPostConstrainBounds(var_2_26),
		time = arg_2_8,
		randomSeed = arg_2_0.randomSeed
	}))

	if arg_2_0.queueReplay then
		table.insert(arg_2_9, {
			type = "QueueReplayEvent",
			time = arg_2_8
		})
	end

	local var_2_28 = arg_2_3.hud
	local var_2_29 = var_2_28 and var_2_28:getElement("playernamefieldhud")

	if var_2_29 then
		var_2_29:hide()
	end
end

function TryCelebrateRuleState.onExitSolid(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7, arg_5_8, arg_5_9, arg_5_10)
	local var_5_0 = arg_5_3.hud and arg_5_3.hud.featureStack

	if var_5_0 then
		var_5_0:pop("scorerNotification")
	end
end

function TryCelebrateRuleState.updateSolid(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8, arg_6_9, arg_6_10, arg_6_11)
	if not arg_6_0.issuedCommandToContinueMovement then
		local var_6_0 = arg_6_3.pools.reactToScorePool

		for iter_6_0, iter_6_1 in arg_6_7:activeObjects(playertype.TypeId) do
			iter_6_1:setBehaviour("TeamScored", arg_6_9)

			local var_6_1 = iter_6_1:getController()

			if iter_6_1.id ~= arg_6_0.scorer and (type(var_6_1) == "ReactToScoreCelebrateAi" or type(var_6_1) == "ReactToScoreDissapointedAi") then
				var_6_1:setState("finalMove")
			end
		end

		arg_6_0.issuedCommandToContinueMovement = true
	end
end
