import("base.rulestate.rulestateclass")
import("core.marshalling.types")
import("game.humanoid.humanoidtype")
import("game.umpire.umpiretype")
import("game.npc.npctype")
import("base.side.sidehelper")
import("game.kickoff.kickoff_helper")
import("app.club.club_helper")
import("game.cheerleader.cheerleader_helper")
import("core.foundation.stringx")
import("rules.cutscenes.initial_cutscene")
import("game.cutscenes.cutsceneplayevent_request")

local var_0_0 = load("intermediatelua.visualconfig.stadium-cfg")
local var_0_1 = native.getEnvironment()

import("app.noesis.controls.nvm_lineuplist")
import("app.noesis.ns")
import("app.noesis.ns_viewmodel")
import("app.noesis.ns_observablecollection")
import("app.noesis.util.nvm_team")
import("game.cutscenes.cutscene_helper")

local var_0_2 = ns_viewmodel.ViewModel
local var_0_3 = ns_observablecollection.ObservableCollection
local var_0_4 = {
	{
		teamVisual = "Civilian01_male",
		playerVisual = "Civilian01_male"
	},
	{
		teamVisual = "Civilian06_male",
		playerVisual = "Civilian06_male"
	},
	{
		teamVisual = "Civilian07_male",
		playerVisual = "Civilian07_male"
	},
	{
		teamVisual = "Civilian04_female",
		playerVisual = "PlayerFemaleCaucasian"
	},
	{
		teamVisual = "Civilian02_female",
		playerVisual = "PlayerFemaleCaucasian"
	},
	{
		teamVisual = "Civilian07_male",
		playerVisual = "Civilian07_male"
	},
	{
		teamVisual = "Civilian04_male",
		playerVisual = "Civilian04_male"
	},
	{
		teamVisual = "Civilian02_female",
		playerVisual = "PlayerFemaleCaucasian"
	},
	{
		teamVisual = "Civilian01_male",
		playerVisual = "Civilian01_male"
	},
	{
		teamVisual = "Civilian02_male",
		playerVisual = "Civilian02_male"
	},
	{
		teamVisual = "Civilian03_female",
		playerVisual = "PlayerFemaleCaucasian"
	},
	{
		teamVisual = "Civilian04_male",
		playerVisual = "Civilian04_male"
	},
	{
		teamVisual = "Civilian04_female",
		playerVisual = "PlayerFemaleCaucasian"
	},
	{
		teamVisual = "Civilian02_male",
		playerVisual = "Civilian02_male"
	},
	{
		teamVisual = "Civilian04_male",
		playerVisual = "Civilian04_male"
	},
	{
		teamVisual = "Civilian01_female",
		playerVisual = "PlayerFemaleCaucasian"
	}
}

ns.Class("NVMFinalsArchway", var_0_2, function(arg_1_0, arg_1_1)
	var_0_2.init(arg_1_0)
end).Bindings = {
	Properties = {
		TeamData = ns.typeOf(nvm_team.NVMTeam)
	}
}

function NVMFinalsArchway.dispose(arg_2_0)
	var_0_2.dispose(arg_2_0)
end

rulestateclass.rulestateclass("TeamShieldRuleState", function(arg_3_0, arg_3_1)
	for iter_3_0, iter_3_1 in pairs(TeamShieldRuleState.MemberDefinitions) do
		arg_3_0[iter_3_0] = arg_3_1[iter_3_0]
	end
end).MemberDefinitions = {
	randomSeed = types.SignedInteger,
	guid = types.Guid
}
TeamShieldRuleState.HidePlayerMarkers = true
TeamShieldRuleState.HideBallMarkers = true

local function var_0_5(arg_4_0)
	local var_4_0 = arg_4_0:getTimePeriodKickOffSide()

	if var_0_1:argExists("attackingSide") then
		if var_0_1:getArg("attackingSide") == "home" then
			var_4_0 = sidehelper.home
		else
			var_4_0 = sidehelper.away
		end
	end

	return var_4_0
end

function TeamShieldRuleState.setupNextState(arg_5_0, arg_5_1, arg_5_2, arg_5_3, arg_5_4, arg_5_5, arg_5_6, arg_5_7, arg_5_8, arg_5_9, arg_5_10)
	local var_5_0 = arg_5_5:getComponent("matchInfo")
	local var_5_1 = var_0_5(var_5_0)
	local var_5_2 = true
	local var_5_3 = {
		kickerSide = var_5_1,
		kickOffBeginsTimePeriod = var_5_2,
		actionGuid = arg_5_4:alloc()
	}

	arg_5_0.nextState = kickoff_helper.GetKickOffState(var_5_3, arg_5_5, arg_5_6, arg_5_3)
end

function TeamShieldRuleState.showVersusHud(arg_6_0)
	arg_6_0.introVersusHud:show()
end

function TeamShieldRuleState.removeVersusHud(arg_7_0)
	arg_7_0.introVersusHud:dispose()

	arg_7_0.introVersusHud = nil
end

function TeamShieldRuleState.onEnterSolid(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5, arg_8_6, arg_8_7, arg_8_8, arg_8_9, arg_8_10)
	arg_8_0:setupNextState(arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5, arg_8_6, arg_8_7, arg_8_8, arg_8_9, arg_8_10)

	local var_8_0 = arg_8_1.engine
	local var_8_1 = arg_8_1.universe
	local var_8_2 = arg_8_1.matchInData

	-- Hand both clubs' colours to LightingModule, which recolours the GF
	-- walkout tunnel lights for whichever side is walking out.
	local function copyClubColours(arg_club)
		local primary = arg_club and arg_club.primaryColour
		local secondary = arg_club and arg_club.secondaryColour

		return {
			primary = primary and {
				primary.r,
				primary.g,
				primary.b
			},
			secondary = secondary and {
				secondary.r,
				secondary.g,
				secondary.b
			}
		}
	end

	local tunnelOk, tunnelColours = pcall(function()
		return {
			home = copyClubColours(var_8_2.home),
			away = copyClubColours(var_8_2.away)
		}
	end)

	_G.GFTunnelTeamColours = tunnelOk and tunnelColours or nil

	local var_8_3, var_8_4 = club_helper.getClubLogos(var_8_0, var_8_2, "plinths")

	arg_8_0.homeTexture = var_8_3
	arg_8_0.awayTexture = var_8_4

	local function var_8_5(arg_9_0)
		local var_9_0 = arg_9_0:getFilename()

		if var_9_0 == "props/shield/shield_left.model" then
			arg_9_0:setShaderValues(function(arg_10_0, arg_10_1)
				if arg_10_0.technique == "es2_lcdsign" then
					arg_10_0:setTexture("col_map", var_8_3)
				end
			end)
		elseif var_9_0 == "props/shield/shield_right.model" then
			arg_9_0:setShaderValues(function(arg_11_0, arg_11_1)
				if arg_11_0.technique == "es2_lcdsign" then
					arg_11_0:setTexture("col_map", var_8_4)
				end
			end)
		end
	end

	local var_8_6 = arg_8_3.hud and arg_8_3.hud.featureStack

	if var_8_6 then
		var_8_6:push("introVersus")
	end

	local var_8_7 = nvm_lineuplist.NVMMatchIntroLineup()
	local var_8_8 = var_8_0:getNoesis()

	arg_8_0.viewLineup = var_8_8:loadViewWithVM("Workspace/Views/HUD/Rugby/paVerticalLineupHUDControl", var_8_7, native.ENoesisViewManagerLayer.POST_SCENE, native.CNoesisViewManager.DefaultPriority)
	arg_8_0.viewModelLineup = var_8_7

	local function var_8_9(arg_12_0, arg_12_1, arg_12_2)
		local var_12_0 = arg_8_3.hud and arg_8_3.hud.featureStack

		if var_12_0 then
			var_12_0:pop("introVersus")
		end
	end

	arg_8_0.fieldSponsors = var_8_1.stadium.grass.fieldmarkings_sponsors

	local function var_8_10()
		arg_8_0:showVersusHud()
	end

	local function var_8_11()
		arg_8_0:removeVersusHud()
	end

	local var_8_12 = arg_8_6:getRoleInfoPool()
	local var_8_13 = native.createTable(64, 0)
	local var_8_14 = native.createTable(64, 0)

	for iter_8_0, iter_8_1 in arg_8_7:objects(humanoidtype.TypeId) do
		table.insert(var_8_13, iter_8_0)

		local var_8_15 = var_8_12:get(iter_8_0)

		if var_8_15 and var_8_15.assignedRole ~= native.EAssignedRole.Substitute then
			table.insert(var_8_14, iter_8_0)
		end
	end

	for iter_8_2, iter_8_3 in arg_8_7:activeObjects(umpiretype.TypeId) do
		if iter_8_3:getAssignedRole(arg_8_6) == native.EOfficialRole.TouchJudge then
			iter_8_3.actorModel.cricketVisual.characterModel:setFlagType(native.EFlagType.None)
		end
	end

	local var_8_16 = arg_8_5:getComponent("matchInfo")
	local var_8_17 = var_8_2.groundInfo.ground
	local var_8_18 = var_0_0.Stadiums[var_8_17].cutsceneOffset.home.rot

	if arg_8_0.introVersusHud then
		arg_8_0.introVersusHud:rotateRenderQuad(180 - var_8_18, var_8_0)
	end

	local var_8_19 = arg_8_3.soundSystem

	arg_8_0.soundSystem = var_8_19

	var_8_19:queueSoundOnlyEvent({
		type = "PrematchSoundEvent"
	})

	if arg_8_0.fieldSponsors then
		arg_8_0.fieldSponsors.visible = true
	end

	local function var_8_20(arg_15_0, arg_15_1, arg_15_2)
		local var_15_0 = arg_8_3.hud and arg_8_3.hud.featureStack

		if var_15_0 then
			var_15_0:pop("introVersus")
			var_15_0:push("lineup", {})
		end
	end

	local var_8_21 = arg_8_0.guid
	local var_8_22 = initial_cutscene.getInitialCutsceneName(arg_8_3, arg_8_5)

	arg_8_10:add(cutsceneplayevent_request.CutscenePlayEventRequest({
		skipSequence = "intro",
		activateActors = true,
		hideLoadingScreen = true,
		hideActorsDuringLoad = true,
		cutsceneName = var_8_22,
		targetIds = var_8_13,
		hideIds = var_8_13,
		guid = var_8_21,
		onCameraChange = var_8_20,
		time = arg_8_8,
		randomSeed = arg_8_0.randomSeed,
		onFinishedState = arg_8_0.nextState
	}))

	-- match-intro-versus (initial_cutscene.lua): versus overlay + locker-room team stingers.
	-- The stock initial_cutscene has no MatchIntroVersus, so this does nothing without that mod.
	if initial_cutscene.MatchIntroVersus then
		local var_8_26, var_8_27 = pcall(initial_cutscene.MatchIntroVersus, var_8_0, arg_8_3, var_8_2, var_8_22)

		if var_8_26 then
			arg_8_0.matchIntroVersus = var_8_27
		elseif initial_cutscene.introVersusLog then
			initial_cutscene.introVersusLog("create error: " .. tostring(var_8_27))
		end
	end

	local var_8_23 = VERIFY(var_8_2.cutsceneInfo).playGFIntroCutscene or var_0_1:argExists("gfintro")

	if var_8_23 then
		local var_8_24 = var_8_8:createRenderTargetFromNew("ARCH RENDER TARGET", 1920, 1080)

		arg_8_0.archRenderTarget = var_8_24
		arg_8_0.NVMFinalsArchway = NVMFinalsArchway()

		local var_8_25 = var_8_8:loadViewWithVM("Workspace/Views/Tests/GF_ArchwayScreen", arg_8_0.NVMFinalsArchway, native.ENoesisViewManagerLayer.POST_SCENE, native.CNoesisViewManager.DefaultPriority)

		var_8_25:setRenderTarget(var_8_24, true)

		arg_8_0.gfArchView = var_8_25
		arg_8_0.playGFIntroCutscene = var_8_23
	end
end

function TeamShieldRuleState.updateSolid(arg_16_0, arg_16_1, arg_16_2, arg_16_3, arg_16_4, arg_16_5, arg_16_6, arg_16_7, arg_16_8, arg_16_9, arg_16_10, arg_16_11)
	local var_16_0 = arg_16_3.cutsceneListener.currentCutscene

	if arg_16_0.playGFIntroCutscene and var_16_0 then
		local var_16_1 = var_16_0.animsetName

		if var_16_1 ~= arg_16_0.gfCutsceneName then
			arg_16_0.gfCutsceneName = var_16_1

			local var_16_2 = string.match(var_16_1:lower(), "home") ~= nil
			local var_16_3 = arg_16_3.hud

			arg_16_0.NVMFinalsArchway.TeamData = var_16_2 and var_16_3.homeTeamNVM or var_16_3.awayTeamNVM

			var_16_0.props:forEachModel(function(arg_17_0)
				if stringx.contains(arg_17_0:getAssetName(), "arch_grandfinal01.model") then
					arg_17_0:setShaderValues(function(arg_18_0, arg_18_1)
						if arg_18_0.technique:find("emissive") then
							arg_18_0:setTexture("col_map", arg_16_0.archRenderTarget.texture)
							arg_18_0:setTexture("emi_map", arg_16_0.archRenderTarget.texture)
						end
					end)
				end
			end)
		end
	end

	if var_16_0 then
		local var_16_4 = var_16_0.animsetName

		if string.match(var_16_4:lower(), "lockers") then
			if var_16_4 ~= arg_16_0.lineupCutSceneName then
				arg_16_0.lineupCutSceneName = var_16_4

				local var_16_5 = string.match(var_16_4:lower(), "home") ~= nil
				local var_16_6 = arg_16_5.matchInData

				arg_16_0.viewModelLineup:populate(arg_16_3.hud, var_16_5 and 1 or 2, var_16_5 and var_16_6.home or var_16_6.away)
				arg_16_0.viewModelLineup:show()
			end
		else
			arg_16_0.viewModelLineup:hide()
		end
	end

	if arg_16_0.introVersusHud then
		arg_16_0.introVersusHud:update()
	end

	-- match-intro-versus
	local var_16_7 = arg_16_0.matchIntroVersus

	if var_16_7 then
		local var_16_8, var_16_9 = pcall(var_16_7.update, var_16_7, arg_16_3)

		if not var_16_8 then
			if initial_cutscene.introVersusLog then
				initial_cutscene.introVersusLog("update error: " .. tostring(var_16_9))
			end

			pcall(var_16_7.dispose, var_16_7)

			arg_16_0.matchIntroVersus = nil
		end
	end
end

function TeamShieldRuleState.onExitSolid(arg_19_0, arg_19_1, arg_19_2, arg_19_3, arg_19_4, arg_19_5, arg_19_6, arg_19_7, arg_19_8, arg_19_9, arg_19_10)
	-- match-intro-versus
	if arg_19_0.matchIntroVersus then
		pcall(arg_19_0.matchIntroVersus.dispose, arg_19_0.matchIntroVersus)

		arg_19_0.matchIntroVersus = nil
	end

	arg_19_0.homeTexture:unload()
	arg_19_0.awayTexture:unload()

	if arg_19_0.introVersusHud then
		arg_19_0.introVersusHud:dispose()

		arg_19_0.introVersusHud = nil
	end

	if arg_19_0.viewModelLineup then
		arg_19_0.viewLineup:release()
		arg_19_0.viewModelLineup:dispose()
	end

	if arg_19_0.NVMFinalsArchway then
		arg_19_0.NVMFinalsArchway:dispose()

		arg_19_0.archRenderTarget = nil

		arg_19_0.gfArchView:release()
	end

	arg_19_7:getBallObject():getVisual():setVisible(true)
	arg_19_1.universe:setPropSetVisibility("grandFinalIntroProps", false)

	local var_19_0 = arg_19_3.hud and arg_19_3.hud.featureStack

	if var_19_0 then
		var_19_0:pop("lineup")
	end

	local var_19_1 = arg_19_0.soundSystem

	if var_19_1 then
		local var_19_2 = arg_19_6:getCutsceneEntity()

		if (var_19_2 and var_19_2:getDequeueReason(arg_19_8)) == native.EDequeueReason.Skip then
			var_19_1:stopCommentary()
		end

		var_19_1:queueSoundOnlyEvent({
			type = "StopAwayThemeEvent"
		})
		var_19_1:queueSoundOnlyEvent({
			type = "StopHomeThemeEvent"
		})
		var_19_1:queueSoundOnlyEvent({
			type = "StopNationalAnthemEvent"
		})
		var_19_1:queueSoundOnlyEvent({
			soundKey = "sfx_cutscene_music_gf_01",
			fadeTime = 2,
			type = "StopSoundEvent"
		})

		arg_19_0.soundSystem = nil
	end

	for iter_19_0, iter_19_1 in arg_19_7:activeObjects(umpiretype.TypeId) do
		if iter_19_1:getAssignedRole(arg_19_6) == native.EOfficialRole.TouchJudge then
			ASSERT(iter_19_1.visualConfig:getOption("currentFlagType") == "static" or iter_19_1.visualConfig:getOption("currentFlagType") == "dynamic", "Setting flag type won't do anything here!")
			iter_19_1.actorModel.cricketVisual.characterModel:setFlagType(native.EFlagType.Static)
		end
	end
end

function TeamShieldRuleState.wipe(arg_20_0, arg_20_1, arg_20_2, arg_20_3, arg_20_4, arg_20_5, arg_20_6, arg_20_7)
	arg_20_0:setNPCVisuals(arg_20_2, arg_20_5, arg_20_4, arg_20_6)
	cheerleader_helper.positionCheerleaders(arg_20_2, arg_20_4, arg_20_6, arg_20_7)
end

function TeamShieldRuleState.setNPCVisuals(arg_21_0, arg_21_1, arg_21_2, arg_21_3, arg_21_4)
	local var_21_0 = 1
	local var_21_1 = {}

	for iter_21_0, iter_21_1 in arg_21_4:objects(npctype.TypeId) do
		local var_21_2 = var_0_4[var_21_0]
		local var_21_3 = cutscene_helper.swapVisual(arg_21_1.npcManager, arg_21_1, arg_21_2, arg_21_3, arg_21_4, iter_21_0, var_21_2.playerVisual, var_21_2.teamVisual, nil, nil, nil, false)

		table.insert(var_21_1, var_21_3)

		var_21_0 = var_21_0 + 1
	end
end
