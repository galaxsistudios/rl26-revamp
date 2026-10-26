import("ai.officials.refereehelper")
import("ai.officials.refereesignalevent_request")
import("base.action.action")
import("base.action.actioncallback")
import("base.action.nilaction_request")
import("core.marshalling.types")
import("core.requestmodel.request")
import("game.cameo.cameostart_request")

-- referee-on-report: a report (rolled in rules/penalty/penalty.lua) is signalled inside the high
-- tackle close-up. When the high tackle signal finishes, the close-up is kept open
-- (OnReportHoldSeconds, as a fallback) and the Report signal is queued. The Report signal starts
-- no camera of its own: the high tackle shot holds its last frame, so there is no cut. It turns
-- the referee to face that camera, blending over OnReportTurnFrames.
-- OnReportSkipFrames (30 fps) are cut off the start of referee_report_01, so it opens on the arm
-- cross instead of the whistle blow.
local OnReportSkipFrames = 30
local OnReportTurnFrames = 15
local OnReportHoldSeconds = 8

local function onReportLog(arg_text)
	local var_r = rawget(_G, "OnReportState")

	if var_r and var_r.log then
		var_r.log(arg_text)
	end
end

local var_0_r = native.CSimulationRequest

request.requestclass("RefereeReportSignalRequest", var_0_r, function(arg_r_0, arg_r_1)
	var_0_r.init(arg_r_0)
end).MemberDefinitions = {}

function RefereeReportSignalRequest.validate(arg_r_0, arg_r_1, arg_r_2, arg_r_3)
	return arg_r_2:getOfficialEntity().refereeSignal == native.EUmpireSignalTypes.None
end

function RefereeReportSignalRequest.apply(arg_r_0, arg_r_1, arg_r_2, arg_r_3, arg_r_4)
	arg_r_2:getOfficialEntity():setRefereeSignal(native.EUmpireSignalTypes.Report)
end

-- Facing from the referee towards the camera on screen (the held close-up shot), or nil.
local function facingTowardsCamera(arg_services, arg_position, arg_fallback)
	local var_ok, var_facing = pcall(function()
		local var_camera = arg_services.camera
		local var_cameraPos = var_camera and var_camera.pos

		if not var_cameraPos then
			return nil
		end

		local var_dir = native.dirlen2(var_cameraPos:tovec2(), arg_position)

		return native.safenormalise2(var_dir, arg_fallback)
	end)

	if not var_ok then
		onReportLog("report signal: couldn't face the camera: " .. tostring(var_facing))

		return nil
	end

	return var_facing
end

local var_0_0 = action.Action

action.actionclass("RefereeSignalAction", var_0_0, function(arg_1_0, arg_1_1)
	var_0_0.init(arg_1_0, arg_1_1)

	for iter_1_0, iter_1_1 in pairs(RefereeSignalAction.MemberDefinitions) do
		arg_1_0[iter_1_0] = arg_1_1[iter_1_0]
	end
end).MemberDefinitions = {
	guid = types.Guid,
	animName = types.String("AnimName"),
	signalType = types.OfficialSignalType,
	duration = types.Number,
	startTime = types.Nilable(types.Time),
	startPosition = types.Vec2,
	startFacing = types.Vec2
}

function RefereeSignalAction.apply(arg_2_0, arg_2_1, arg_2_2)
	local var_2_0 = arg_2_1:getOfficialEntity()
	local var_2_1, var_2_2, var_2_3 = var_2_0:getRefereesIds()

	if arg_2_2 == var_2_1 then
		var_2_0.refereeSignal = native.EUmpireSignalTypes.None
	elseif arg_2_2 == var_2_2 or arg_2_2 == var_2_3 then
		var_2_0.touchJudgeSignal = native.EUmpireSignalTypes.None
		arg_2_0.isTouchJudge = true
	end
end

function RefereeSignalAction.addCallbacks(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8)
	local var_3_0 = arg_3_0.animName
	local var_3_1 = arg_3_0.startTime or arg_3_8
	local var_3_2 = native.Random.FromSystemTime()
	local var_3_3 = arg_3_0.signalType
	local var_3_4 = 10
	local var_3_5 = arg_3_0.startPosition
	local var_3_6 = arg_3_0.startFacing
	local var_3_7 = var_3_1 + 0.13333333333333333

	-- referee-on-report: the Report signal of a report inside the high tackle close-up.
	local var_3_s = rawget(_G, "OnReportState")
	local var_3_p = var_3_s and var_3_s.pending
	local var_3_c = var_3_3 == native.EUmpireSignalTypes.Report and var_3_p and var_3_p.inCloseUp
	local var_3_r = var_3_3 == native.EUmpireSignalTypes.Report and OnReportSkipFrames or 0

	if var_3_c then
		local var_3_f = facingTowardsCamera(arg_3_2, var_3_5, var_3_6)

		if var_3_f then
			var_3_6 = var_3_f
		end

		var_3_4 = OnReportTurnFrames
	end

	local var_3_8 = arg_3_7:addBodyCommand(var_3_0, arg_3_4, arg_3_6, {
		ikTwistBlendFrameCount = 10,
		startTime = var_3_1,
		startPosition = var_3_5,
		startFacing = var_3_6,
		transitionFrameCount = var_3_4,
		targetTime = var_3_7,
		offsetFrameCount = var_3_r > 0 and var_3_r or nil
	})

	formatPrintT("REFEREE SIGNAL ACTION: %t", var_3_3)

	if var_3_r > 0 then
		local var_3_d = arg_3_4:getAnimationProvider()
		local var_3_e = var_3_d and var_3_d:getAnimationDuration(var_3_0)

		onReportLog(string.format("report signal: %s is %s s long, starting %d frames in%s", tostring(var_3_0), tostring(var_3_e), var_3_r, var_3_c and ", in the high tackle close-up" or ""))
	end

	local var_3_9 = refereehelper.getCameoRequired(var_3_3, arg_3_2) or arg_3_0.forcedCameo

	arg_3_0.cameoCamera = var_3_9 and arg_3_2.cameoCamera
	arg_3_0.ingameCharacterStreamingProcess = arg_3_2.ingameCharacterStreamingProcess

	arg_3_1:addEventCallback(actioncallback.atTime(arg_3_4, arg_3_6, var_3_8, var_3_1, function(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6)
		if arg_3_0.isTouchJudge then
			ASSERT(arg_4_1.visualConfig:getOption("currentFlagType") == "static" or arg_4_1.visualConfig:getOption("currentFlagType") == "dynamic", "Setting flag type won't do anything here!")
			arg_4_1.actorModel.cricketVisual.characterModel:setFlagType(native.EFlagType.Dynamic)
		end

		arg_4_6:add(refereesignalevent_request.RefereeSignalEventRequest({
			eventTime = var_3_1,
			signalType = var_3_3,
			umpireId = arg_4_0
		}))
	end))

	-- referee-on-report: no new camera for the Report signal inside the close-up.
	if var_3_9 and not var_3_c then
		arg_3_1:addEventCallback(actioncallback.atTime(arg_3_4, arg_3_6, var_3_8, var_3_7, function(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6)
			arg_5_6:add(cameostart_request.CameoStartRequest({
				objectId = arg_5_0,
				animName = var_3_0,
				startPosition = var_3_5,
				startFacing = var_3_6,
				startTime = var_3_7 + -var_3_r / 30
			}))
		end))
	end

	arg_3_1:addEventCallback(actioncallback.atAnimationWane(arg_3_6, var_3_8, function(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6)
		arg_6_6:add(nilaction_request.createRequest(arg_6_2, arg_6_0))

		if arg_3_0.isTouchJudge then
			ASSERT(arg_6_1.visualConfig:getOption("currentFlagType") == "static" or arg_6_1.visualConfig:getOption("currentFlagType") == "dynamic", "Setting flag type won't do anything here!")
			arg_6_1.actorModel.cricketVisual.characterModel:setFlagType(native.EFlagType.Static)
		end

		if arg_3_0.cameoCamera then
			arg_3_0.cameoCamera:setTimer(0.25)
		end

		-- referee-on-report: after the high tackle signal, keep the close-up open and go
		-- straight into the Report signal.
		local var_6_r = rawget(_G, "OnReportState")
		local var_6_p = var_6_r and var_6_r.pending

		-- A sin bin or send-off from the same penalty has its own cutscene after the choice: the
		-- report signal isn't needed, so the report is dropped (no signal, no banner).
		if var_6_p and not var_6_p.inCloseUp then
			local var_6_ok, var_6_binned = pcall(function()
				local var_6_pe = arg_6_2:getPenaltyEntity()

				return var_6_pe.isSinBin or var_6_pe.isSentOff
			end)

			if var_6_ok and var_6_binned then
				var_6_r.pending = nil
				var_6_r.reportedOffender = nil

				if var_6_r.reports and var_6_r.reports[#var_6_r.reports] == var_6_p then
					table.remove(var_6_r.reports)
				end

				onReportLog("report dropped: the offender was sin-binned / sent off")

				var_6_p = nil
			end
		end

		if var_6_p and not var_6_p.inCloseUp and not arg_3_0.isTouchJudge and var_3_3 == native.EUmpireSignalTypes.HighTackle and arg_3_0.cameoCamera then
			var_6_p.inCloseUp = true

			arg_3_0.cameoCamera:setTimer(OnReportHoldSeconds)
			arg_6_6:add(RefereeReportSignalRequest({}))
			onReportLog("high tackle signal done, Report signal next in the same close-up")
		end
	end))
end
