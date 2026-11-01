import("base.event.eventoccurred_request")
import("base.side.sidehelper")
import("game.plays.foresight_request")
import("sim.hud.hud_helper")
import("simlisteners.tactics.teamtactics_request")
import("app.noesis.hud.nvm_tactics")
import("script-config.rules.rules.rulesenvironment")

local var_0_0 = {
	hud_helper.PosX_Home,
	hud_helper.PosX_Away
}
local var_0_1 = 0.35
local var_0_2 = var_0_1 + 0.5
local var_0_3 = 0.75
local var_0_4 = 0.28
local var_0_5 = 7
local var_0_6 = native.EPlayerForesightType
local var_0_7 = native.EOffensePlayType
-- defence-tactics-hud: last-tackle warning when the ruck is further than this
-- (m) from the try line the defending side is defending.
local LastTackleWarnDistance = 20
local var_0_8 = {
	{
		key = "SlideLeft",
		label = "Slide Left",
		defenseTacticsFacing = {
			tacticPlayTheBall = "BasicPlayTheBallDefenceSlideLeft",
			tacticBasicDefense = "BasicDefenceSlideLeft"
		}
	},
	{
		key = "Compress",
		label = "Compress",
		defenseTacticsFacing = {
			tacticPlayTheBall = "BasicPlayTheBallDefenceCompress",
			tacticBasicDefense = "BasicDefenceCompress"
		}
	},
	{
		key = "DropWings",
		label = "Drop Wingers",
		defenseTacticsFacing = {
			tacticPlayTheBall = "BasicPlayTheBallDefenceDropWings",
			tacticBasicDefense = "BasicDefenceDropWings"
		}
	},
	{
		key = "SlideRight",
		label = "Slide Right",
		defenseTacticsFacing = {
			tacticPlayTheBall = "BasicPlayTheBallDefenceSlideRight",
			tacticBasicDefense = "BasicDefenceSlideRight"
		}
	}
}
local var_0_9 = {
	{
		key = "CrossOver",
		offenceType = var_0_7.CrossOver
	},
	{
		key = "HitUp",
		offenceType = var_0_7.HitUp
	},
	{
		key = "OutTheBack",
		offenceType = var_0_7.OutTheBack
	},
	{
		key = "InsideBall",
		offenceType = var_0_7.InsideBall
	},
	{
		key = "Kick",
		offenceType = var_0_7.Kick
	}
}
local var_0_10 = {
	{
		key = "Stamina",
		foresightType = var_0_6.Stamina
	},
	{
		key = "Strength",
		foresightType = var_0_6.Strength
	},
	{
		key = "Fitness",
		foresightType = var_0_6.Fitness
	},
	{
		key = "Agility",
		foresightType = var_0_6.Agility
	},
	{
		key = "Speed",
		foresightType = var_0_6.Speed
	}
}
local var_0_11 = 1
local var_0_12 = 2
local var_0_13 = 3
local var_0_14 = {
	[var_0_11] = var_0_8,
	[var_0_12] = var_0_9,
	[var_0_13] = var_0_10
}

Class("TacticsHud", function(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7)
	local var_1_0 = nvm_tactics.NVMTactics()
	local var_1_1 = nvm_tactics.NVMTactics()

	arg_1_7.featureStack:registerViewModel(hud_helper.HUD_IDENTIFIERS.gameplay, "HomeTactics", var_1_0)
	arg_1_7.featureStack:registerViewModel(hud_helper.HUD_IDENTIFIERS.gameplay, "AwayTactics", var_1_1)

	local var_1_2 = {
		{
			selectionTriggered = false,
			blockingInput = false,
			selectionTime = 0,
			tacticsHud = var_1_0
		},
		{
			selectionTriggered = false,
			blockingInput = false,
			selectionTime = 0,
			tacticsHud = var_1_1
		}
	}

	for iter_1_0, iter_1_1 in pairs(sidehelper.sideStrings) do
		var_1_2[iter_1_0].tacticsHud:initialiseCardSets(var_0_14)
	end

	arg_1_0.enabled = false
	arg_1_0.sideStates = var_1_2

	arg_1_7.featureStack:register("tactics", arg_1_0, function(arg_2_0)
		arg_1_0:show()
	end, function()
		arg_1_0:hide()
	end)

	arg_1_0.featureStack = arg_1_7.featureStack
end)

function TacticsHud.registerWithMatchSim(arg_4_0, arg_4_1)
	local function var_4_0(arg_5_0)
		return function(...)
			return arg_5_0(arg_4_0, ...)
		end
	end

	local var_4_1 = {
		ForwardPassEvent = var_4_0(arg_4_0.onEventRequiringReconstruction),
		TwentyFiftyEvent = var_4_0(arg_4_0.onEventRequiringReconstruction),
		TwentyFortyEvent = var_4_0(arg_4_0.onEventRequiringReconstruction),
		FortyThirtyEvent = var_4_0(arg_4_0.onEventRequiringReconstruction),
		FortyTwentyEvent = var_4_0(arg_4_0.onEventRequiringReconstruction),
		GameOverEvent = var_4_0(arg_4_0.onEventRequiringReconstruction),
		HandOverEvent = var_4_0(arg_4_0.onEventRequiringReconstruction),
		InTouchEvent = var_4_0(arg_4_0.onEventRequiringReconstruction),
		KickoffSetupEvent = var_4_0(arg_4_0.onEventRequiringReconstruction),
		PossessionChangeEvent = var_4_0(arg_4_0.onEventRequiringReconstruction),
		PenaltyAwardedEvent = var_4_0(arg_4_0.onEventRequiringReconstruction),
		PlacedKickPrepCompleteEvent = var_4_0(arg_4_0.onEventRequiringReconstruction),
		SubstitutionHudClosed = var_4_0(arg_4_0.onSubstitutionHudClosed),
		SubstitutionHudOpen = var_4_0(arg_4_0.onSubstitutionHudOpen),
		TryScoredEvent = var_4_0(arg_4_0.onEventRequiringReconstruction)
	}

	for iter_4_0, iter_4_1 in pairs(var_4_1) do
		arg_4_1:registerSolidEventListener(iter_4_1, iter_4_0)
	end
end

function TacticsHud.resetAllSelectionDelayTimers(arg_7_0, arg_7_1)
	for iter_7_0, iter_7_1 in pairs(arg_7_0.sideStates) do
		iter_7_1.selectionTriggered = false
		iter_7_1.selectionTime = var_0_2
	end
end

function TacticsHud.onEventRequiringReconstruction(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5, arg_8_6, arg_8_7, arg_8_8, arg_8_9)
	arg_8_0:closeAllMenus()
	arg_8_0:resetAllSelectionDelayTimers(arg_8_3)
	arg_8_9:add(eventoccurred_request.EventOccurredRequest("TacticsHudClosed", {
		side = sidehelper.away
	}))
	arg_8_9:add(eventoccurred_request.EventOccurredRequest("TacticsHudClosed", {
		side = sidehelper.home
	}))
end

function TacticsHud.onSubstitutionHudClosed(arg_9_0, arg_9_1, arg_9_2, arg_9_3, arg_9_4, arg_9_5, arg_9_6, arg_9_7, arg_9_8, arg_9_9)
	arg_9_0.sideStates[arg_9_1.side].blockingInput = false
end

function TacticsHud.onSubstitutionHudOpen(arg_10_0, arg_10_1, arg_10_2, arg_10_3, arg_10_4, arg_10_5, arg_10_6, arg_10_7, arg_10_8, arg_10_9)
	arg_10_0.sideStates[arg_10_1.side].blockingInput = true
end

function TacticsHud.dispose(arg_11_0, arg_11_1)
	for iter_11_0, iter_11_1 in ipairs(arg_11_0.sideStates) do
		local var_11_0 = iter_11_1.tacticsHud

		arg_11_0.featureStack:unregisterHUDElement(hud_helper.HUD_IDENTIFIERS.gameplay, var_11_0)
		var_11_0:dispose()
	end
end

function TacticsHud.getTeamPlayOptions(arg_12_0, arg_12_1, arg_12_2)
	local var_12_0 = arg_12_1.knowledgeBank.teamPlaySelectionOptionsPair
	local var_12_1 = arg_12_2:getMatchProgressionEntity().attackingSide

	return var_12_0:get(var_12_1)
end

local function var_0_15(arg_13_0, arg_13_1, arg_13_2, arg_13_3, arg_13_4, arg_13_5, arg_13_6)
	local var_13_0 = arg_13_2.side
	local var_13_1 = arg_13_0:getTeamPlayOptions(arg_13_3, arg_13_4)
	local var_13_2 = var_13_1:getPlaySelectionOptions()
	local var_13_3 = var_0_9[arg_13_1:getSelectedIndex()].offenceType

	var_13_1:setSelectedPlay(var_13_3)
	arg_13_1:closeMenu()
	arg_13_5:add(eventoccurred_request.EventOccurredRequest("TacticsHudClosed", {
		side = var_13_0
	}))

	arg_13_0.sideStates[var_13_0].selectionTriggered = false
end

local function var_0_16(arg_14_0, arg_14_1, arg_14_2, arg_14_3, arg_14_4, arg_14_5, arg_14_6)
	local var_14_0 = arg_14_2.side
	local var_14_1 = VERIFY(var_0_10[arg_14_1:getSelectedIndex()].foresightType)

	formatPrintT("[foresight] about to add request. side %t, time %t, foresightType %t", var_14_0, arg_14_6, var_14_1)
	arg_14_5:add(foresight_request.ForesightRequest({
		side = var_14_0,
		time = arg_14_6,
		foresightType = var_14_1
	}))
	arg_14_1:closeMenu()
	arg_14_5:add(eventoccurred_request.EventOccurredRequest("TacticsHudClosed", {
		side = var_14_0
	}))

	arg_14_0.sideStates[var_14_0].selectionTriggered = false
end

function TacticsHud.handleDelaySelection(arg_15_0, arg_15_1, arg_15_2, arg_15_3, arg_15_4, arg_15_5, arg_15_6, arg_15_7)
	local var_15_0 = arg_15_1.side
	local var_15_1 = arg_15_0.sideStates[var_15_0]

	if arg_15_1:getInputEventTriggered("Tactics", "Up") or arg_15_1:getInputEventTriggered("Tactics", "Left") or arg_15_1:getInputEventTriggered("Tactics", "Down") or arg_15_1:getInputEventTriggered("Tactics", "Right") then
		var_15_1.selectionTriggered = true
		var_15_1.selectionTime = var_0_2
	end

	if var_15_1.selectionTriggered then
		var_15_1.selectionTime = var_15_1.selectionTime - arg_15_7

		if var_15_1.selectionTime <= 0 and arg_15_2.TacticsVisibility then
			if arg_15_2:getCardSetIndex() == var_0_13 then
				var_0_16(arg_15_0, arg_15_2, arg_15_1, arg_15_3, arg_15_4, arg_15_5, arg_15_6)
			else
				var_0_15(arg_15_0, arg_15_2, arg_15_1, arg_15_3, arg_15_4, arg_15_5, arg_15_6)
			end

			var_15_1.selectionTriggered = false
			var_15_1.selectionTime = var_0_2

			return true
		end
	end

	return false
end

-- defence-tactics-hud: logs each automatic defence reset to defence_tactics_debug.txt.
function logDefenceReset(arg_0_0, arg_0_1)
	if not nvm_tactics.DefenceTacticDebugLog then
		return
	end

	pcall(function()
		local var_0_2 = io.open("defence_tactics_debug.txt", "a")

		if var_0_2 then
			var_0_2:write(os.date("%H:%M:%S"), string.format(" RESET side=%s (%s)", tostring(arg_0_0), tostring(arg_0_1)), "\n")
			var_0_2:flush()
			var_0_2:close()
		end
	end)
end

function TacticsHud.update(arg_16_0, arg_16_1, arg_16_2, arg_16_3, arg_16_4, arg_16_5, arg_16_6, arg_16_7, arg_16_8, arg_16_9, arg_16_10, arg_16_11, arg_16_12)
	if not arg_16_0.enabled then
		return
	end

	local var_16_0 = arg_16_5:getMatchProgressionEntity().attackingSide
	local var_16_1 = arg_16_0.sideStates
	local var_16_9 = false

	pcall(function()
		local var_16_10 = arg_16_5:getPlayTheBallEntity()

		var_16_9 = arg_16_5:getMatchProgressionEntity():getGeneralGameplayActive() or var_16_10 ~= nil and var_16_10.playTheBallState ~= native.EPlayTheBallState.None
	end)

	-- defence-tactics-hud: last tackle with the ruck well away from the
	-- defended line? (The ruck position is remembered from the last
	-- play-the-ball; the play-the-ball entity is cleared once it completes.)
	local var_16_11 = false

	pcall(function()
		local var_16_12 = arg_16_5:getPlayTheBallEntity()

		local var_16_15 = arg_16_3:getComponent("matchInData").matchType.maxTackleCount
		local var_16_16 = arg_16_5:getMatchProgressionEntity().tackleCount

		-- About 2 s after each play-the-ball the entity's position resets to (0,0); skip that
		-- (it read as "50 m from the line" and could show the warning near our line).
		if var_16_12 and var_16_12.playTheBallState ~= native.EPlayTheBallState.None and (var_16_12.playTheBallPosition.x ~= 0 or var_16_12.playTheBallPosition.y ~= 0) then
			local var_16_13 = var_16_12.playTheBallPosition
			-- Attacking direction from the dummy half (current, swaps at half
			-- time); arg_16_3's side data looked fixed at kick-off.
			local var_16_14
			local var_16_18 = var_16_12.dummyHalfId and arg_16_6:getGameObject(var_16_12.dummyHalfId)

			if var_16_18 and var_16_18.side == var_16_0 then
				var_16_14 = var_16_18:getPlayDir().x
			else
				var_16_14 = arg_16_3:getSide(var_16_0):getPlayDir().x
			end

			local var_16_19 = rulesenvironment.halfFieldLength - var_16_13.x * var_16_14

			if nvm_tactics.DefenceTacticDebugLog and var_16_12.playTheBallId ~= arg_16_0.loggedPlayTheBallId then
				arg_16_0.loggedPlayTheBallId = var_16_12.playTheBallId

				pcall(function()
					local var_16_20 = io.open("defence_tactics_debug.txt", "a")

					if var_16_20 then
						var_16_20:write(os.date("%H:%M:%S"), string.format(" PTB tackle=%s/%s ruckX=%.1f dir=%s(%s) distFromDefendedLine=%.1f", tostring(var_16_16), tostring(var_16_15), var_16_13.x, tostring(var_16_14), var_16_18 and "dummyhalf" or "side", var_16_19), "\n")
						var_16_20:flush()
						var_16_20:close()
					end
				end)
			end

			arg_16_0.ruckDistanceFromDefendedLine = var_16_19
		end

		-- Shown once the 5th tackle is made, i.e. for the last play of the set.
		var_16_11 = var_16_16 >= var_16_15 and (arg_16_0.ruckDistanceFromDefendedLine or 0) > LastTackleWarnDistance
	end)

	for iter_16_0, iter_16_1 in arg_16_4:iterLocalGamers() do
		local var_16_2 = iter_16_1.side
		local var_16_3 = var_16_1[var_16_2]

		-- defence-tactics-hud: once this side has the ball, put its defence back
		-- to the default so a tactic picked on the last play (e.g. Drop Wingers)
		-- doesn't carry into the next defensive set.
		if var_16_2 == var_16_0 and var_16_3.defenseTacticEnabled then
			arg_16_0:resetDefensiveTactic(var_16_3, var_16_2, arg_16_10)
			logDefenceReset(var_16_2, "won the ball")
		end

		-- defence-tactics-hud: also reset when the opposition starts a new set without this side
		-- having the ball (try + kick-off, six-again, dropout...: the tackle count goes back down). Compared with what
		-- was seen last update, so it still works when the change happened during a cutscene
		-- (this update doesn't run then).
		pcall(function()
			local var_16_30 = arg_16_5:getMatchProgressionEntity()
			local var_16_31 = var_16_30.tackleCount or 0
			local var_16_34 = var_16_3.seenSet

			if var_16_34 and var_16_2 ~= var_16_0 and var_16_3.defenseTacticEnabled then
				local var_16_35

				if var_16_34.attackingSide ~= var_16_0 then
					var_16_35 = "attacking side changed"
				elseif var_16_31 < var_16_34.tackleCount then
					var_16_35 = string.format("tackle count %d -> %d", var_16_34.tackleCount, var_16_31)
				end

				if var_16_35 then
					arg_16_0:resetDefensiveTactic(var_16_3, var_16_2, arg_16_10)
					logDefenceReset(var_16_2, "new set: " .. var_16_35)
				end
			end

			var_16_3.seenSet = {
				attackingSide = var_16_0,
				tackleCount = var_16_31
			}
		end)

		-- defence-tactics-hud: this loop only visits human-controlled sides; show
		-- their defence tactic label while they defend in live play (the XAML fades
		-- it). Live = general play, or a play-the-ball under way (general play
		-- exits for each play-the-ball). Hidden at tries, conversions, penalties,
		-- kick-off setup, scrums, breaks.
		local var_16_8 = var_16_2 ~= var_16_0 and var_16_9

		if var_16_3.tacticsHud.DefenceTacticVisible ~= var_16_8 then
			var_16_3.tacticsHud.DefenceTacticVisible = var_16_8
		end

		-- Red, flashing "last tackle" prompt unless the wingers are already back.
		local var_16_17 = var_16_8 and var_16_11 and not (var_16_3.defenseTacticEnabled and var_16_3.tacticsHud.DefenceTacticKey == "DropWings")

		if var_16_3.tacticsHud.DefenceTacticAlert ~= var_16_17 then
			var_16_3.tacticsHud.DefenceTacticAlert = var_16_17
		end

		if not var_16_3.blockingInput then
			local var_16_4 = var_16_2 == var_16_0
			local var_16_5 = var_16_3.tacticsHud
			local var_16_6 = var_16_5.TacticsVisibility
			local var_16_7 = var_16_5.closing

			if var_16_5:update(arg_16_8) then
				arg_16_10:add(eventoccurred_request.EventOccurredRequest("TacticsHudClosed", {
					side = var_16_2
				}))
			end

			if var_16_4 then
				if not arg_16_0:handleDelaySelection(iter_16_1, var_16_5, arg_16_2, arg_16_5, arg_16_10, arg_16_9, arg_16_8) then
					if iter_16_1:getInputEvent("Tactics", "Up") then
						if not var_16_6 then
							var_16_5:setSelectedIndex(3)
							var_16_5:setCardSetIndex(var_0_12)
							var_16_5:openMenu(0)
							arg_16_10:add(eventoccurred_request.EventOccurredRequest("TacticsHudOpen", {
								side = var_16_2
							}))
						elseif not var_16_7 then
							if var_16_5:getCardSetIndex() == var_0_13 then
								var_0_16(arg_16_0, var_16_5, iter_16_1, arg_16_2, arg_16_5, arg_16_10, arg_16_9)
							else
								var_0_15(arg_16_0, var_16_5, iter_16_1, arg_16_2, arg_16_5, arg_16_10, arg_16_9)
							end
						end
					elseif iter_16_1:getInputEvent("Tactics", "Left") and var_16_6 and not var_16_7 then
						var_16_5:cycleSelectedIndex(true)
					elseif iter_16_1:getInputEvent("Tactics", "Right") and var_16_6 and not var_16_7 then
						var_16_5:cycleSelectedIndex(false)
					elseif iter_16_1:getInputEvent("Tactics", "Down") and not var_16_7 and var_16_6 then
						var_16_5:closeMenu()
						arg_16_10:add(eventoccurred_request.EventOccurredRequest("TacticsHudClosed", {
							side = var_16_2
						}))

						var_16_3.selectionTriggered = false
						var_16_3.selectionTime = var_0_2
					end
				end
			else
				var_16_3.selectionTriggered = false
				var_16_3.selectionTime = var_0_2

				if iter_16_1:getInputEvent("Tactics", "Left") then
					arg_16_0:setDefensiveTactic(var_16_5, 1, arg_16_10, var_16_2, arg_16_2, arg_16_5)
				elseif iter_16_1:getInputEvent("Tactics", "Up") then
					arg_16_0:setDefensiveTactic(var_16_5, 2, arg_16_10, var_16_2, arg_16_2, arg_16_5)
				elseif iter_16_1:getInputEvent("Tactics", "Down") then
					arg_16_0:setDefensiveTactic(var_16_5, 3, arg_16_10, var_16_2, arg_16_2, arg_16_5)
				elseif iter_16_1:getInputEvent("Tactics", "Right") then
					arg_16_0:setDefensiveTactic(var_16_5, 4, arg_16_10, var_16_2, arg_16_2, arg_16_5)
				end
			end
		end
	end
end

function TacticsHud.resetDefensiveTactic(arg_22_0, arg_22_1, arg_22_2, arg_22_3)
	arg_22_3:add(teamtactics_request.ChangeTeamTacticRequest({
		graphName = "BasicDefence",
		side = arg_22_2,
		graphType = native.EForceDirectedGraphType.Defence
	}))
	arg_22_3:add(teamtactics_request.ChangeTeamTacticRequest({
		graphName = "BasicPlayTheBallDefence",
		side = arg_22_2,
		graphType = native.EForceDirectedGraphType.PlayTheBallDefence
	}))

	arg_22_1.defenseTacticEnabled = false

	arg_22_1.tacticsHud:setDefenceTactic(nil)
end

function TacticsHud.setDefensiveTactic(arg_17_0, arg_17_1, arg_17_2, arg_17_3, arg_17_4, arg_17_5, arg_17_6)
	if arg_17_6:getTrainingEntity().trainingActive then
		return
	end

	local var_17_0 = arg_17_1:getSelectedIndex()
	-- defence-tactics-hud: tracked per side (stock shared one flag between both teams)
	local var_17_6 = arg_17_0.sideStates[arg_17_4]
	local var_17_1 = var_17_6.defenseTacticEnabled and var_17_0 == arg_17_2
	local var_17_2 = var_0_8[arg_17_2].defenseTacticsFacing
	local var_17_3 = var_17_2.tacticBasicDefense
	local var_17_4 = var_17_2.tacticPlayTheBall

	if not var_17_3 and not var_17_4 then
		return
	end

	local var_17_5 = var_17_1 and 1 or 1.5

	arg_17_1:setCardSetIndex(var_0_11)

	if var_17_1 then
		arg_17_3:add(teamtactics_request.ChangeTeamTacticRequest({
			graphName = "BasicDefence",
			side = arg_17_4,
			graphType = native.EForceDirectedGraphType.Defence
		}))
		arg_17_3:add(teamtactics_request.ChangeTeamTacticRequest({
			graphName = "BasicPlayTheBallDefence",
			side = arg_17_4,
			graphType = native.EForceDirectedGraphType.PlayTheBallDefence
		}))

		var_17_6.defenseTacticEnabled = false

		arg_17_1:setDefenceTactic(nil)
	else
		ASSERT(var_17_3)
		ASSERT(var_17_4)
		arg_17_3:add(teamtactics_request.ChangeTeamTacticRequest({
			side = arg_17_4,
			graphType = native.EForceDirectedGraphType.Defence,
			graphName = var_17_3
		}))
		arg_17_3:add(teamtactics_request.ChangeTeamTacticRequest({
			side = arg_17_4,
			graphType = native.EForceDirectedGraphType.PlayTheBallDefence,
			graphName = var_17_4
		}))

		var_17_6.defenseTacticEnabled = true

		arg_17_1:setSelectedIndex(arg_17_2)
		arg_17_1:setDefenceTactic(var_0_8[arg_17_2].key, var_0_8[arg_17_2].label)
	end

	arg_17_1:showSelection(var_17_5)
	arg_17_3:add(eventoccurred_request.EventOccurredRequest("TacticsHudOpen", {
		side = arg_17_4
	}))
end

function TacticsHud.render(arg_18_0, arg_18_1, arg_18_2, arg_18_3)
	return
end

function TacticsHud.closeAllMenus(arg_19_0, arg_19_1)
	local var_19_0

	var_19_0 = arg_19_1 or 0

	for iter_19_0, iter_19_1 in ipairs(arg_19_0.sideStates) do
		iter_19_1.tacticsHud:forceClose()
	end
end

function TacticsHud.show(arg_20_0)
	arg_20_0.enabled = true
end

function TacticsHud.hide(arg_21_0)
	arg_21_0.enabled = false
end
