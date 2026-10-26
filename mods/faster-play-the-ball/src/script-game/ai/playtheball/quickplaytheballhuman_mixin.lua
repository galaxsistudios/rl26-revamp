import("rules.playtheball.playtheballentity_request")
import("design.playtheball_config")

local var_0_0 = playtheball_config.doubleTapWindow

-- faster-play-the-ball: the human quick play-the-ball (double-tap left
-- trigger). Stock only read the double-tap once the tackle had collapsed with
-- no offload possible, and only in the tackled contact / collapse monitors and
-- the dummy half controller, so a double-tap made during the contact phase (or
-- during the hold-down) was lost. Now the double-tap is read throughout the
-- tackle and remembered per ball carrier, then applied as soon as a quick
-- play-the-ball is allowed. The mod also runs this mixin from the tackled
-- hold / drag / drive / dive / getup monitors.

-- Ball carrier id -> sim time of a remembered double-tap (or slow request).
PendingQuickPlayTheBall = {}
PendingSlowPlayTheBall = {}
-- A remembered double-tap is used for at most this long (s).
PendingWindow = 4

-- Attacking quick play-the-ball button: double-tap right trigger (the stock
-- QuickPlayTheBall action, left trigger, stays the defensive retreat).
QuickPlayTheBallAction = "QuickPlayTheBallAttack"

-- Pass spam: pass presses made once an offload is no longer possible (during
-- the hold-down / get-up; earlier the same buttons offload) count up. This many
-- give a quick play-the-ball...
PassSpamQuickPresses = 2
-- ...and each press past that adds this much to the quick play rate
-- (stock quick is design.playtheball_config playrateQuickPTB, 1.4), up to
-- PassSpamMaxRate.
PassSpamRatePerPress = 0.1
PassSpamMaxRate = 1.9
PassSpamPresses = {}
-- { carrier = id, rate = n }: read by playtheball_action.lua for this
-- carrier's quick play-the-ball.
QuickPlayTheBallRate = nil
-- The boosted rate applies to a quick play-the-ball starting within this
-- long (s) after the last pass press.
QuickPlayTheBallRateWindow = 3

-- Debug: log requests to ptb_decision_debug.txt (game folder). Turn off for
-- release.
local DebugLog = true

local function debugWrite(arg_0_0)
	if not DebugLog then
		return
	end

	pcall(function()
		local var_0_1 = io.open("ptb_decision_debug.txt", "a")

		if var_0_1 then
			var_0_1:write(os.date("%H:%M:%S"), " ", arg_0_0, "\n")
			var_0_1:flush()
			var_0_1:close()
		end
	end)
end

Class("QuickPlayTheBallHumanMixin", function(arg_1_0, arg_1_1)
	return
end)

function QuickPlayTheBallHumanMixin.onEnter(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	local var_2_0 = arg_2_1:getGamer(arg_2_5)

	ASSERT(var_2_0)

	if not var_2_0 then
		return
	end

	var_2_0:setInputBarrier()
end

function QuickPlayTheBallHumanMixin.update(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	local var_3_0 = arg_3_1:getGamer(arg_3_5)

	if not var_3_0 then
		return
	end

	local var_3_1 = arg_3_7:getActiveTackleEntity():getMostRecentActiveTackle()

	if not var_3_1 then
		return
	end

	local var_3_3 = var_3_1:getParticipantId(native.ETackleParticipantType.BallCarrier)

	-- Read the buttons every frame of the tackle and remember them.
	local var_3_9 = var_3_0:getInputEvent("PlayTheBall", QuickPlayTheBallAction) ~= nil
	local var_3_10 = var_3_0:getInputEvent("Kicking", "TargetKickModifier") ~= nil
	local var_3_11 = var_3_0:getInputEvent("Global", "Sprint") ~= nil
	local var_3_12 = var_3_10 and var_3_11

	if var_3_9 and var_3_12 then
		var_3_9 = false
	end

	if var_3_3 then
		if var_3_9 then
			PendingQuickPlayTheBall[var_3_3] = arg_3_10
			PendingSlowPlayTheBall[var_3_3] = nil
		elseif var_3_12 then
			PendingSlowPlayTheBall[var_3_3] = arg_3_10
			PendingQuickPlayTheBall[var_3_3] = nil
		end
	end

	-- Stock conditions for the play-the-ball speed to be set at all.
	local var_3_2 = arg_3_2.knowledgeBank.playerActiveTackleKnowledgePool
	local var_3_4 = var_3_2 and var_3_3 and var_3_2:get(var_3_3)
	local var_3_5 = var_3_4 and var_3_4.offloadPossible
	local var_3_6 = var_3_1:hasCollapsed()
	local var_3_7 = var_3_1:getFirstTackleBlock()
	local var_3_8 = var_3_7 and var_3_7.blockType == native.ETackleBlockType.Ground

	if var_3_5 or not var_3_6 or var_3_8 then
		return
	end

	-- Pass spam (only counted from here: no offload possible any more).
	if var_3_3 then
		local var_3_20 = tostring(var_3_3) .. ":" .. tostring(arg_3_7:getMatchProgressionEntity().tackleCount)
		local var_3_21 = PassSpamPresses[var_3_3]

		if not var_3_21 or var_3_21.key ~= var_3_20 then
			var_3_21 = {
				key = var_3_20,
				count = 0
			}
			PassSpamPresses[var_3_3] = var_3_21
		end

		local var_3_22 = var_3_0:getInputEvent("HaveBall", "PassLeft") or var_3_0:getInputEvent("HaveBall", "PassRight") or var_3_0:getInputEvent("HaveBall", "PassLeftDuringTackle") or var_3_0:getInputEvent("HaveBall", "PassRightDuringTackle")

		if var_3_22 then
			var_3_21.count = var_3_21.count + 1

			if var_3_21.count >= PassSpamQuickPresses then
				local var_3_23 = PendingQuickPlayTheBall[var_3_3]

				if not var_3_23 then
					PendingQuickPlayTheBall[var_3_3] = arg_3_10
				end

				QuickPlayTheBallRate = {
					carrier = var_3_3,
					time = arg_3_10,
					rate = math.min(PassSpamMaxRate, playtheball_config.cPlayTheBallConfig.playrateQuickPTB + PassSpamRatePerPress * (var_3_21.count - PassSpamQuickPresses))
				}

				debugWrite(string.format("HUMAN carrier=%s pass spam x%d -> quick rate %.2f", tostring(var_3_3), var_3_21.count, QuickPlayTheBallRate.rate))
			end
		end
	end

	local var_3_14 = var_3_3 and PendingQuickPlayTheBall[var_3_3]
	local var_3_15 = var_3_3 and PendingSlowPlayTheBall[var_3_3]
	local var_3_16 = var_3_14 ~= nil and arg_3_10 - var_3_14 <= PendingWindow
	local var_3_17 = var_3_15 ~= nil and arg_3_10 - var_3_15 <= PendingWindow

	if var_3_16 or var_3_17 then
		local var_3_13 = arg_3_7:getPlayTheBallEntity()

		if not (var_3_13.isQuickPlayTheBall or var_3_13.isSlowPlayTheBall) then
			arg_3_11:add(playtheballentity_request.QuickPlayTheBallRequest({
				isQuickPlayTheBall = var_3_16,
				isSlowPlayTheBall = var_3_17 and not var_3_16
			}))

			debugWrite(string.format("HUMAN carrier=%s %s play-the-ball (pressed %.2fs before it was allowed)", tostring(var_3_3), var_3_16 and "quick" or "slow", arg_3_10 - (var_3_16 and var_3_14 or var_3_15)))
		end

		PendingQuickPlayTheBall[var_3_3] = nil
		PendingSlowPlayTheBall[var_3_3] = nil
	end
end
