import("base.side.sidehelper")
import("rules.playtheball.playtheballentity_request")
-- faster-play-the-ball: AI play-the-ball speed in its own end (Red zone), by
-- tackle count: quick up to OwnEndQuickMaxTackle, slow from
-- OwnEndSlowFromTackle, normal in between.
local OwnEndQuickMaxTackle = 1
local OwnEndSlowFromTackle = 4

-- faster-play-the-ball debug: one line per tackle to ptb_decision_debug.txt
-- (game folder): why the AI did / didn't ask for a quick or slow
-- play-the-ball. Turn off for release.
local DecisionDebugLog = true
local ZoneNames = {}

pcall(function()
	ZoneNames[native.EFieldZone.Red] = "Red"
	ZoneNames[native.EFieldZone.Yellow] = "Yellow"
	ZoneNames[native.EFieldZone.Green] = "Green"
end)

local function decisionLog(arg_0_0, arg_0_1, arg_0_2)
	if not DecisionDebugLog or arg_0_0.loggedKey == arg_0_1 then
		return
	end

	arg_0_0.loggedKey = arg_0_1

	pcall(function()
		local var_0_3 = io.open("ptb_decision_debug.txt", "a")

		if var_0_3 then
			var_0_3:write(os.date("%H:%M:%S"), " ", arg_0_2, "\n")
			var_0_3:flush()
			var_0_3:close()
		end
	end)
end

Class("QuickPlayTheBallAiMixin", function(arg_1_0, arg_1_1)
	return
end)

function QuickPlayTheBallAiMixin.onEnter(arg_2_0, arg_2_1, arg_2_2, arg_2_3, arg_2_4, arg_2_5, arg_2_6, arg_2_7, arg_2_8, arg_2_9, arg_2_10)
	local var_2_0 = arg_2_2.network:isMaster()
	local var_2_1 = arg_2_1:getAllGamersOnSide(arg_2_6.side, var_2_0)

	if #var_2_1 > 0 then
		var_2_1[1]:setInputBarrier()
	end
end

function QuickPlayTheBallAiMixin.update(arg_3_0, arg_3_1, arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11)
	local var_3_0 = arg_3_7:getActiveTackleEntity():getMostRecentActiveTackle()

	if not var_3_0 then
		return
	end

	if var_3_0 then
		local var_3_1 = arg_3_2.knowledgeBank.playerActiveTackleKnowledgePool
		local var_3_2 = var_3_0:getParticipantId(native.ETackleParticipantType.BallCarrier)
		local var_3_3 = var_3_1 and var_3_1:get(var_3_2)
		local var_3_4 = var_3_3 and var_3_3.offloadPossible
		local var_3_5 = var_3_0 and var_3_0:hasCollapsed()
		local var_3_6 = var_3_0:getFirstTackleBlock()

		ASSERT(var_3_6)

		local var_3_7 = var_3_6.blockType == native.ETackleBlockType.Ground

		if var_3_4 or not var_3_5 or var_3_7 then
			-- Logged once per tackle state, so a tackle that later collapses
			-- also gets its decision line.
			decisionLog(arg_3_0, tostring(var_3_2) .. ":" .. tostring(var_3_4) .. tostring(var_3_5) .. tostring(var_3_7), string.format("WAIT carrier=%s offloadPossible=%s collapsed=%s groundTackle=%s", tostring(var_3_2), tostring(var_3_4), tostring(var_3_5), tostring(var_3_7)))

			return
		end
	end

	local var_3_8 = arg_3_2.network:isMaster()
	local var_3_9 = arg_3_1:getAllGamersOnSide(arg_3_6.side, var_3_8)
	local var_3_10
	local var_3_11

	if #var_3_9 > 0 then
		local var_3_12 = var_3_9[1]

		-- faster-play-the-ball: attacking quick play-the-ball is the right-trigger action now
		var_3_10 = var_3_12:getInputEvent("PlayTheBall", "QuickPlayTheBallAttack") ~= nil

		local var_3_13 = var_3_12:getInputEvent("Kicking", "TargetKickModifier") ~= nil
		local var_3_14 = var_3_12:getInputEvent("Global", "Sprint") ~= nil

		var_3_11 = var_3_13 and var_3_14

		if var_3_10 and var_3_11 then
			var_3_10 = false
		end
	else
		local var_3_15 = {
			tackle = var_3_0
		}

		var_3_10, var_3_11 = arg_3_0:shouldQuickPlayTheBall(arg_3_2, arg_3_3, arg_3_4, arg_3_5, arg_3_6, arg_3_7, arg_3_8, arg_3_9, arg_3_10, arg_3_11, var_3_15)

		if DecisionDebugLog then
			pcall(function()
				local var_3_17 = arg_3_2.knowledgeBank.ballInfo.position
				local var_3_18 = arg_3_6:getPlayDir()
				local var_3_19 = native.getFieldZone(var_3_17, var_3_18)

				decisionLog(arg_3_0, "decided" .. tostring(var_3_0:getParticipantId(native.ETackleParticipantType.BallCarrier)) .. tostring(arg_3_7:getMatchProgressionEntity().tackleCount), string.format("AI side=%s tackle=%s zone=%s ballX=%.1f dir=%s distToOppLine=%.1f -> quick=%s slow=%s", tostring(arg_3_6.side), tostring(arg_3_7:getMatchProgressionEntity().tackleCount), ZoneNames[var_3_19] or tostring(var_3_19), var_3_17.x, tostring(var_3_18.x), 50 - var_3_17.x * var_3_18.x, tostring(var_3_10), tostring(var_3_11)))
			end)
		end
	end

	if var_3_10 or var_3_11 then
		local var_3_16 = arg_3_7:getPlayTheBallEntity()

		if not (var_3_16.isQuickPlayTheBall or var_3_16.isSlowPlayTheBall) then
			arg_3_11:add(playtheballentity_request.QuickPlayTheBallRequest({
				isQuickPlayTheBall = var_3_10,
				isSlowPlayTheBall = var_3_11
			}))
		end
	end
end

function QuickPlayTheBallAiMixin.shouldQuickPlayTheBall(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6, arg_4_7, arg_4_8, arg_4_9, arg_4_10, arg_4_11)
	local var_4_0 = arg_4_1.knowledgeBank
	local var_4_1 = arg_4_5:getPlayDir()
	local var_4_2 = var_4_1.x
	local var_4_3 = var_4_0.ballInfo.position
	local var_4_4 = var_4_3.x
	local var_4_5 = native.getFieldZone(var_4_3, var_4_1)

	ASSERT(var_4_5)

	local var_4_6 = arg_4_6:getMatchProgressionEntity()

	ASSERT(var_4_6)

	local var_4_7 = var_4_6.tackleCount
	local var_4_8
	local var_4_9

	if var_4_5 == native.EFieldZone.Red then
		-- faster-play-the-ball: Red is the attacking side's OWN end (the log
		-- showed it 77-94 m from the opposition line). Stock played every
		-- play-the-ball there slowly, i.e. the AI crawled out of its own end.
		-- Now: quick early in the set to get out, normal mid-set, slow only
		-- once it's about to kick.
		var_4_9 = var_4_7 <= OwnEndQuickMaxTackle
		var_4_8 = var_4_7 >= OwnEndSlowFromTackle
	elseif var_4_5 == native.EFieldZone.Yellow then
		if var_4_4 >= 0 then
			if var_4_2 > 0 then
				var_4_9 = var_4_7 < 5
				var_4_8 = false
			else
				var_4_9 = var_4_7 < 3
				var_4_8 = var_4_7 >= 5
			end
		elseif var_4_2 > 0 then
			var_4_9 = var_4_7 < 3
			var_4_8 = var_4_7 >= 5
		else
			var_4_9 = var_4_7 < 5
			var_4_8 = false
		end
	else
		var_4_9 = var_4_7 < 5
		var_4_8 = false
	end

	local var_4_10 = arg_4_6:getMatchTimeEntity()
	local var_4_11 = var_4_6:isApproachingEndOfMatch(var_4_10, arg_4_9, 600)
	local var_4_12 = arg_4_6:getScoreEntity()
	local var_4_13 = arg_4_3:getComponent("matchInData")
	local var_4_14 = var_4_12:getWinningSide(var_4_13)
	local var_4_15 = arg_4_5.side

	if var_4_14 == sidehelper.none or not var_4_11 then
		if var_4_9 then
			ASSERT(not var_4_8)
		end

		return var_4_9, var_4_8
	elseif var_4_14 == var_4_15 then
		local var_4_16 = arg_4_3.statistics.play_listeners.set:getPlayMetersGained() > 8
		local var_4_17 = var_4_0.teamLineBreakKnowledgePair:get(sidehelper.getOtherSide(var_4_15))

		if var_4_5 == native.EFieldZone.Green and (var_4_16 and var_4_7 >= 5 or var_4_17.lineBroken) then
			var_4_9 = false
			var_4_8 = true
		end
	else
		var_4_9 = true
		var_4_8 = false
	end

	if var_4_9 then
		ASSERT(not var_4_8)
	end

	return var_4_9, var_4_8
end
