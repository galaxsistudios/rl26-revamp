import("actor.degradation.playerdegradation_helper")
import("actor.fieldimpact.fieldimpact_helper")
import("ai.ballprediction.ballprediction")
import("ai.behaviour.behaviours")
import("ai.collect.committedmiss_listener")
import("ai.common.control_helper")
import("ai.contest.contest_arbitrator")
import("ai.emotion.emotion_listeners")
import("ai.emotion.emotionservice")
import("ai.emotion.transientemotion_component")
import("ai.emotion.triggeredemotion_component")
import("ai.formation.formation_listener")
import("ai.idleprocess.idleservice")
import("ai.knowledge.knowledge")
import("ai.lookat.lookatconfigflowchart")
import("ai.movement.motionprofileflowchart")
import("ai.movement.naturalmovementflowchart")
import("ai.passing.passcandidate_listener")
import("ai.substitutions.substitutespositions_loader")
import("ai.substitutions.substitution_listener")
import("ai.tackle.tackle_arbitrator")
import("ai.tackledemo.tackledemo_listener")
import("ai.teamorders.teamorders_listener")
import("app.loading.logotransition_ustate")
import("app.gameplay.onlinepause_request")
import("app.matchreport.servermatch_system")
import("attributes.attributes.balance_listener")
import("attributes.attributes.stamina_listener")
import("base.action.action")
import("base.gamecontroller.gamecontrollerset")
import("base.gameobject.gameobject")
import("base.match.match")
import("base.matchsim.matchsim")
import("base.matchsim.packagevalidationprocess")
import("base.replay.replaymanager")
import("base.replay.replaymanagercadapter")
import("base.side.endhelper")
import("base.side.sidehelper")
import("base.transition.fade")
import("base.transition.initial_hold_loading")
import("base.transition.logoscreenwipein")
import("base.transition.logoscreenwipeout")
import("base.transition.screenwipe")
import("base.transition.screenwipe_factory")
import("base.universe.universestatestack")
import("core.assets.assetjoin")
import("core.assets.finalise")
import("core.camera.camerafactory")
import("core.camera.cameramanager")
import("core.camera.camerautil")
import("core.foundation.stringx")
import("core.foundation.tablex")
import("core.profile.profile")
import("design.collect_cconfig")
import("design.cutscenes.cutscene_props")
import("design.evaluate_cconfig")
import("design.gameplaybalance_cconfig")
import("design.humanmovement_cconfig")
import("design.input.input_configurations")
import("design.kicking_cconfig")
import("design.logo_config")
import("design.movement_config")
import("design.naturalmovement.naturalmovementprofileset_cconfig")
import("design.passing_cconfig")
import("design.playerbalance_cconfig")
import("design.playermarker_cconfig")
import("design.playerswitching_cconfig")
import("design.stamina_cconfig")
import("design.upperbodycontext_cconfig")
import("game.animation.animsetloader")
import("game.animation.poseplayer")
import("game.ball.ballfactory")
import("game.ball.disposal_request")
import("game.ball.futuredisposal_listener")
import("game.cameo.cameo_listener")
import("game.camera.cameocamera")
import("game.camera.gameplay_cameras")
import("game.characteranimation.playeranimationset")
import("game.coach.coachtype")
import("game.collisionbump.collisionbumpflowchart")
import("game.cutscenes.cutscene_listener")
import("game.forcedirectedgraph.forcedirectedgraphloader")
import("game.gamer.gamers")
import("game.gamer.gamersidechange_listener")
import("game.gamer.resumegameafterdisconnect_request")
import("game.humanoid.humanoidtype")
import("game.injury.injuryevent_listener")
import("game.marker.markerfactory")
import("game.matchinfo.matchinfo")
import("game.movement.behaviour_listener")
import("game.network.gamemessages")
import("game.physics.physicsfactory")
import("game.pitch.pitch")
import("game.player.playertype")
import("game.plays.play_listener")
import("game.serve.serve_listener")
import("game.skipstate.skipstate_provider")
import("game.team.team")
import("game.training.traininginfo")
import("game.training.traininginfo_listener")
import("game.training.tutorial_listener")
import("game.umpire.umpiretype")
import("intermediatelua.data.jointscalingconfig")
import("intermediatelua.lighting.clut")
import("intermediatelua.visualconfig.lookatconfig")
import("listeners.richpresence.richpresence_listener")
import("listeners.vibration.vibration_listener")
import("listeners.vibration.vibration_system")
import("rendering.particles.particleassets")
import("rendering.particles.particleevents")
import("rendering.lighting.gi_config")
import("rendering.crowd.crowd")
import("rendering.modules.stadium_module")
import("rendering.modules.lighting_module")
import("rendering.postfx.postfxfactory")
import("rendering.props.fieldposts")
import("rendering.props.propfactory")
import("rendering.scene.scene_config")
import("rendering.shaderglobal.shaderglobal")
import("rules.advantage.advantage_listener")
import("rules.beapro.beapro_skip_listener")
import("rules.kicking.placekick_listener")
import("rules.playtheball.playtheball_listener")
import("rules.possession.possession_listener")
import("rules.rules.rulesenvironment_cconfig")
import("rules.rules.rulesinfo")
import("rules.scenario.scenarioregister")
import("rules.sinbin.sinbinsystem")
import("rules.stadium.stadiumpan")
import("game.time.timeinfo")
import("script-config.design.ball_config")
import("script-config.design.ballprediction_config")
import("script-config.design.ground_config")
import("script-config.design.hud.ballmarker_config")
import("script-config.design.physics_config")
import("script-config.design.player_config")
import("script-config.design.playerbalance_config")
import("script-config.design.stamina_config")
import("script-config.rules.rules.rulesenvironment")
import("rules.rules.rulesenvironment_cconfig")

local var_0_0 = rulesenvironment_cconfig.cBoundaryConfig

import("sim.animationservice.animationserviceregistration")
import("sim.coach.coachobject")
import("sim.hud.hud")
import("sim.hud.hud_registration")
import("sim.hud.ingame_thumbnail_generator")
import("sim.hud.trajectorylines_hud")
import("sim.npc.npcobject")
import("sim.outofframe.outofframerequestgatherer")
import("sim.player.playerobject")
import("sim.replay.replay_savesystem")
import("sim.umpire.umpireobject")
import("sim.universe.querymanager")
import("simlisteners.ball.ballbounce_listener")
import("simlisteners.hud.camera_hud_listener")
import("simlisteners.linebreak.linebreak_listener")
import("simlisteners.metresrun.metresrun_listener")
import("simlisteners.player.teleportplayer_listener")
import("simlisteners.plays.playrecentuse_listener")
import("simlisteners.simtime.simtime_listener")
import("simlisteners.sound.sound_system")
import("simlisteners.statistics.hitpost_listener")
import("simlisteners.statistics.simulationstatistics_listener")
import("simlisteners.statistics.statistics_manager")
import("simlisteners.tackle.tacklerecentuse_listener")
import("simlisteners.tactics.teamtactics_listener")
import("simlisteners.time.minuteelapsed_listener")
import("app.noesis.worldUI.nvm_jumbotron")
import("script-config.design.matchout.matchplayerrating_config")
import("core.foundation.import", "package")

local var_0_1 = import("core.debug.debugcolours")
local var_0_2 = native.vec2
local var_0_3 = native.sportType

import("simlisteners.analyticgraphs.gameplayanalytics_listener")

local var_0_4 = nop
local var_0_5 = 120
local var_0_6 = native.getPlatformString()
local var_0_7 = load("design.speed_cconfig")
local var_0_8 = collect_cconfig.cCollectConfig
local var_0_9 = upperbodycontext_cconfig.cUpperBodyContextConfig
local var_0_10 = humanmovement_cconfig.cHumanMovementConfig
local var_0_11 = gameplaybalance_cconfig.cGameplayBalance
local var_0_12 = playerbalance_cconfig.cPlayerBalanceConfig
local var_0_13 = stamina_cconfig.cStaminaConfig
local var_0_14 = logo_config.LogoTypeMap

_ENV.frontend_lighting = _ENV.frontend_lighting or load("intermediatelua.visualconfig.frontend_lighting")

local var_0_15 = native:getEnvironment()
local var_0_16 = profile.push
local var_0_17 = profile.pop
local var_0_18 = native.CGameConfig.LINEUP_MAX_SIZE * 2
local var_0_19 = 16
local var_0_20 = native.CGameConfig.MAX_UMPIRES
local var_0_21 = native.CGameConfig.GAME_HAS_COACHES and 2 or 0
local var_0_22 = 120
local var_0_23 = var_0_18 + var_0_20 + var_0_21 + var_0_19

Class("Universe", function(arg_1_0, arg_1_1, arg_1_2)
	_G.leakDetect(arg_1_0)

	arg_1_0.finaliseList = {}
	arg_1_0.components = {}
	arg_1_0.config = arg_1_2
	arg_1_0.updateables = {}
	arg_1_0.pauseListeners = {}
	arg_1_0.engine = arg_1_1
	arg_1_0.isPaused = false
	arg_1_0.timeFactor = 1
	arg_1_0.renderDt = 0
	arg_1_0.realDt = 0

	local var_1_0 = arg_1_2

	arg_1_0.onlineMultiplayer = var_1_0.onlineMultiplayer

	local var_1_1 = var_1_0.network

	if not var_1_1 then
		arg_1_0:createNetwork(arg_1_1, arg_1_2)
	else
		arg_1_0.network = var_1_1
	end

	arg_1_0.idleAndHitTargetJobGroup = native.CJobGroup()
end)

function Universe.addGoalObstructions(arg_2_0, arg_2_1, arg_2_2)
	if var_0_3 == "rugby" then
		local var_2_0 = VERIFY(var_0_0.goalPostSpacing) / 2
		local var_2_1 = VERIFY(var_0_0.goalPostCentre)
		local var_2_2 = VERIFY(var_0_0.goalPostHeight)
		local var_2_3 = 0.6
		local var_2_4 = native.vec2(-var_2_1, var_2_0)
		local var_2_5 = native.vec2(-var_2_1, -var_2_0)
		local var_2_6 = native.vec2(var_2_1, var_2_0)
		local var_2_7 = native.vec2(var_2_1, -var_2_0)

		arg_2_1:add(var_2_4, var_2_3, var_2_2)
		arg_2_1:add(var_2_5, var_2_3, var_2_2)
		arg_2_1:add(var_2_6, var_2_3, var_2_2)
		arg_2_1:add(var_2_7, var_2_3, var_2_2)
		arg_2_2:add(var_2_4, var_2_3, var_2_2)
		arg_2_2:add(var_2_5, var_2_3, var_2_2)
		arg_2_2:add(var_2_6, var_2_3, var_2_2)
		arg_2_2:add(var_2_7, var_2_3, var_2_2)
	elseif var_0_3 == "lacrosse" then
		local var_2_8 = rulesenvironment_cconfig.cBoundaryConfig.goalHeight
		local var_2_9, var_2_10 = rulesenvironment_cconfig.cBoundaryConfig:getNorthGoalObstructionCircle()

		arg_2_1:add(var_2_9, var_2_10, var_2_8)
		arg_2_2:add(var_2_9, var_2_10, var_2_8)

		local var_2_11, var_2_12 = rulesenvironment_cconfig.cBoundaryConfig:getSouthGoalObstructionCircle()

		arg_2_1:add(var_2_11, var_2_12, var_2_8)
		arg_2_2:add(var_2_11, var_2_12, var_2_8)
	end
end

local function var_0_24(arg_3_0, arg_3_1, arg_3_2)
	local var_3_0 = arg_3_0:getParty()

	if var_3_0 then
		local var_3_1 = var_3_0:getPrimaryPartyMember()

		if var_3_1 then
			local var_3_2 = var_3_1.settings[arg_3_1]

			ASSERT(var_3_2 ~= nil)

			return var_3_2
		end
	end

	return arg_3_2
end

function Universe.loadMatch(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5, arg_4_6)
	arg_4_0.renderJobs = arg_4_5.renderJobs

	profile.push("Universe:loadMatch")
	var_0_4("Universe:loadMatch:begin")

	local var_4_0 = arg_4_6.gameplayUIServices
	local var_4_1 = arg_4_6.hooks
	local var_4_2 = native.Random.FromSystemTime()
	local var_4_3 = arg_4_0.config
	local var_4_4 = arg_4_1:getAssetManager()
	local var_4_5 = arg_4_1:getTextureManager()
	local var_4_6 = arg_4_1:getRenderInterface()
	local var_4_7 = arg_4_1:getAssetNotifier()
	local var_4_8 = arg_4_1:getJobManager()
	local var_4_9 = VERIFY(arg_4_0.network)
	local var_4_10 = VERIFY(arg_4_0.finaliseList)
	local var_4_11 = arg_4_1:getParty():getPrimaryPartyMember()
	local var_4_12

	if var_4_11 then
		var_4_12 = var_4_11.settings
	else
		var_4_12 = native.CPartyMemberSettings()

		var_4_12:setToAttractModeDefaults()
	end

	if _G.configData and _G.configData:getConfig(2) then
		arg_4_0.trackFrame = true
		arg_4_0.frameCount = 0
	end

	if _G.configData and _G.configData:getConfig(3) then
		local var_4_13 = math.random(120, 300)

		arg_4_1:getGameControlManager():killInputAfter(var_4_13)
	end

	if _G.configData and _G.configData:getConfig(4) then
		local var_4_14 = math.random(120, 300)

		native.quitAfter(var_4_14)
	end

	if _G.configData and _G.configData:getConfig(5) then
		arg_4_0.configTimer = math.random(240, 480)
	end

	if _G.configData and _G.configData:getConfig(6) then
		arg_4_0.spinTime = true
	end

	local var_4_15 = scene_config.loadSceneConfig(var_4_3, arg_4_2, arg_4_1)

	if var_4_3.testface then
		native.CCricketAcademyCharacterVisual.testFaceMode(true)
	end

	arg_4_0.ingameTexturePack = var_4_5:loadPack("textures/ingame.texpack")
	arg_4_0.particleTexturePack = var_4_5:loadPack("particles/gameplay-effects.texpack")

	local var_4_16 = {}

	arg_4_0.aspectList = var_4_16

	local var_4_17, var_4_18 = var_4_6:getDeferredResolution()
	local var_4_19 = camerafactory.createCCamera()

	var_4_19.aspect = var_4_17 / var_4_18
	arg_4_0.ccamera = var_4_19

	local var_4_20 = cameramanager.CameraManager()

	arg_4_0.cameraManager = var_4_20

	local var_4_21 = native.CObstructions()

	arg_4_0:addGoalObstructions(var_4_20.cameraObstructions, var_4_21)

	arg_4_0.preloadedCharacterAssets = playerobject.preloadAssets(arg_4_1)

	local var_4_22 = {
		ScreenWipe = screenwipe.ScreenWipeOut,
		LogoScreenWipeIn = logoscreenwipein.LogoScreenWipeIn,
		LogoScreenWipeOut = logoscreenwipeout.LogoScreenWipeOut,
		Fade = fade.FadeOut,
		InitialHoldLoading = initial_hold_loading.InitialHoldLoading,
		InitialHoldBlack = fade.InitialHoldBlack,
		Logo = logotransition_ustate.LogoTransitionUniverseState
	}
	local var_4_23 = universestatestack.UniverseStateStack(var_4_22, var_4_9)

	arg_4_0.universeStateStack = var_4_23

	local var_4_24 = var_4_15.levelData

	if var_4_24 then
		arg_4_2.groundInfo.seasonalLocation = var_4_24:getWeatherZoneAsSeasonalLocation()
	end

	arg_4_0.matchInData = arg_4_2
	arg_4_0.matchOutData = arg_4_3
	arg_4_0.matchInProgressData = arg_4_4

	local var_4_25 = native.CIdManager()

	local function var_4_26()
		return arg_4_0.matchSim
	end

	local function var_4_27(arg_6_0, arg_6_1)
		arg_4_0:endMatchPrematurely(arg_6_0, arg_6_1)
	end

	local function var_4_28()
		arg_4_0:offerForfeit()
	end

	local var_4_29 = {
		engine = arg_4_1,
		jobManager = arg_4_1:getJobManager(),
		hooks = var_4_1,
		network = var_4_9,
		camera = var_4_19,
		idManager = var_4_25,
		cameraManager = var_4_20,
		uiServices = var_4_0,
		primaryPartyMemberSettings = var_4_12,
		endMatchPrematurely = var_4_27,
		getMatchSim = var_4_26,
		offerForfeit = var_4_28,
		party = arg_4_1:getParty(),
		matchInData = arg_4_2,
		actionObstructions = var_4_21,
		updateLoading = function(arg_8_0)
			arg_4_0:updateLoading(arg_4_1, arg_8_0)
		end,
		levelData = var_4_24
	}

	arg_4_0.services = var_4_29

	local var_4_30 = scenarioregister.ScenarioRegister()

	var_4_30:registerRulestates()
	var_4_30:registerControllers()

	arg_4_0.scenarioRegister = var_4_30
	var_4_29.scenarioRegister = var_4_30

	if var_4_1 and var_0_6 == "win32" then
		function var_4_29.onscreenNotification(arg_9_0)
			local var_9_0 = var_4_1:getHook("DebugTextDebugHook")

			if var_9_0 then
				var_9_0:onscreenNotification(arg_9_0)
			end
		end
	else
		function var_4_29.onscreenNotification(arg_10_0)
			return
		end
	end

	local var_4_31 = var_4_9.participantId
	local var_4_32 = arg_4_4:getGuidSequence(var_4_31)
	local var_4_33 = native.CGuidManager.create(var_4_31, var_4_32)

	var_4_29.guidManager = var_4_33

	local var_4_34 = querymanager.QueryManager()

	arg_4_0.queryManager = var_4_34
	var_4_29.queryManager = var_4_34
	var_4_29.whiteboard = {}

	local var_4_35 = {
		addAspect = function(arg_11_0, arg_11_1)
			var_4_16[arg_11_1] = arg_11_1
		end
	}

	arg_4_0.aspectManager = var_4_35
	var_4_29.aspectManager = var_4_35

	local var_4_36 = native.CTacklePreferenceList()

	arg_4_0.tacklePreferenceList = var_4_36
	var_4_29.tacklePreferenceList = var_4_36

	local var_4_37 = native.CPlaysPreferenceList()

	arg_4_0.playsPreferenceList = var_4_37
	var_4_29.playsPreferenceList = var_4_37

	local var_4_38 = idleservice.createIdleService()

	var_4_38:setSex(native.CSex.Male)

	arg_4_0.idleService = var_4_38
	var_4_29.idleService = var_4_38

	native.CIdleService.setPrimaryIdleService(var_4_38)
	native.CPhysicsPropDefs.init(physics_config.physicsProps)

	var_4_29.physicsEnvironmentStateParams = native.CPhysicsEnvironmentStateParams()

	local var_4_39 = arg_4_6.supporters
	local var_4_40 = {
		"collision/props/tackledummy",
		"collision/props/mannequin",
		"collision/props/base"
	}

	arg_4_0:loadPropCollision(arg_4_1, var_4_29, var_4_40, nil)

	local var_4_41 = native.CBodyAnimationControllerSet()

	arg_4_0.bodyAnimationControllerSet = var_4_41
	var_4_29.bodyAnimationControllerSet = var_4_41

	local var_4_42 = emotionservice.createEmotionService()

	arg_4_0.emotionService = var_4_42
	var_4_29.emotionService = var_4_42

	local var_4_43 = arg_4_1:getLocationManager()
	local var_4_44 = native.CWeather(var_4_43)

	arg_4_0.weather = var_4_44
	var_4_29.weather = var_4_44

	ASSERT(var_4_3.scenario)

	local var_4_45 = var_4_3.scenario
	local var_4_46 = matchsim.MatchSim(arg_4_2, arg_4_4, arg_4_1, var_4_23, var_4_9, var_4_33)

	arg_4_0.matchSim = var_4_46
	var_4_29.eventSystem = var_4_46

	function var_4_29.setTimeModulation(...)
		var_4_46:setTimeModulation(...)
	end

	arg_4_0:initSolidState(var_4_46, arg_4_2)
	arg_4_0:registerPauseListener(var_4_46)
	arg_4_0:registerSolidEventListener(function(arg_13_0)
		arg_4_0.forfeitOfferReceivedTime = nil
	end, "BreakInPlayEvent")
	var_0_4("Universe:loadMatch:scene")

	local var_4_47 = arg_4_6.scene

	arg_4_0.scene = arg_4_6.scene
	arg_4_0.sceneDisposalQueue = {}

	local var_4_48 = native.CPhysicsScene()

	arg_4_0.physicsScene = var_4_48
	var_4_29.physicsScene = var_4_48
	arg_4_0.stadium = arg_4_0:setupStadium(arg_4_1, var_4_29, var_4_15, var_4_3, arg_4_2, var_4_10, var_4_1)

	ASSERT(arg_4_0.stadium)

	local var_4_49 = VERIFY(arg_4_0.stadium.stadiumCfg)
	local var_4_50 = arg_4_0.sceneMaterialGroups

	var_4_29.renderer = arg_4_0.sceneRenderer

	arg_4_0:registerPauseListener(arg_4_0.sceneRenderer)
	var_0_4("Universe:loadMatch:post scene misc")

	local var_4_51 = VERIFY(arg_4_2.weatherForecast)

	if var_4_51.dayCount <= 0 then
		local var_4_52 = native.ECities.Melbourne

		ASSERT(var_4_52)
		var_4_44:generateForecast(var_4_51, var_4_52, 0, 0, 1, 24, 13, native.EClimateRain.None, false, native.EWeatherType.Clear, false, 0)
	end

	var_4_44:setForecast(var_4_51)

	local var_4_53 = timeinfo.TimeInfo(var_4_3, arg_4_2, arg_4_4, var_4_46, var_4_43, var_4_49)
	local var_4_54 = var_4_53.timeOfDay

	var_4_54:setEditable()
	var_4_54:setWeather(arg_4_0.weather)

	arg_4_0.timeOfDay = var_4_54
	arg_4_0.sceneRenderer.timeOfDay = var_4_54
	var_4_29.timeOfDay = var_4_54

	local var_4_55 = arg_4_4:getMatchProgressionEntity().day

	var_4_44:update(var_4_55, var_4_54.time)
	profile.push("post scene misc")

	local var_4_56
	local var_4_57 = arg_4_0.sceneRenderer.skyRenderer

	if var_4_15.postFxConfig.fog then
		var_4_57.enableFog = true
	end

	var_4_57:setWeather(var_4_44)
	var_4_57:setTimeOfDay(var_4_54)

	var_4_57.blueNoise = var_4_5:load("textures/effects/blue_noise_16.texture")

	if ({
		trainingfacility = true,
		forsythbarr = true
	})[arg_4_2.groundInfo.ground] then
		arg_4_2.weatherType = native.EWeatherType.Clear
	end

	arg_4_0.lightingModule = arg_4_0:setupLighting(arg_4_1, arg_4_2.groundInfo.ground, arg_4_0.sceneRenderer, arg_4_0.sceneRain, arg_4_0.sceneToneMapStage, arg_4_0.sceneBloomStage, arg_4_0.scenePizazz)

	local var_4_58 = arg_4_0.stadium
	local var_4_59 = var_4_58 and var_4_58.grass

	arg_4_0.grassConfig = VERIFY(var_4_15.fieldConfig)
	var_4_29.pitchDegradation = var_4_59 and var_4_59.cdegradation

	local var_4_60 = pitch.Pitch(var_4_3)
	local var_4_61 = arg_4_1:getShaderPackAsset()
	local var_4_62 = arg_4_1:getHelperJointsLoader()
	local var_4_63 = arg_4_0.sceneRenderer

	arg_4_0.characterManager = native.CCharacterManager(var_4_6, var_4_47, var_4_61, var_4_62, {
		assetLoadMonitor = arg_4_1:getAssetLoadMonitor(),
		assetManager = arg_4_1:getAssetManager(),
		blobManager = arg_4_1:getBlobManager(),
		textureManager = arg_4_1:getTextureManager(),
		collisionBlobLoader = arg_4_1:getCollisionBlobLoader(),
		tier1HJOffsetsBlobLoader = arg_4_1:getTier1HJOffsetsBlobLoader(),
		jobManager = arg_4_1:getJobManager(),
		jigglyConfigBlobLoader = arg_4_1:getJigglyConfigBlobLoader(),
		ghostModelManager = var_4_63.ghostModelManager,
		shadowManager = var_4_63.shadowManager
	})
	arg_4_0.characterAssetMap = arg_4_1:getAssetMap()

	local var_4_64 = arg_4_0.lighting

	if var_4_64 then
		local var_4_65 = var_4_1 and var_4_1:getHook("PropEditorDebugHook")

		if var_4_65 then
			var_4_65:setRenderer(arg_4_0.sceneRenderer)
		end

		local var_4_66 = var_4_1 and var_4_1:getHook("LightingEditorDebugHook")

		if var_4_66 then
			var_4_66:setRenderer(arg_4_0.sceneRenderer)
		end

		local var_4_67 = var_4_1 and var_4_1:getHook("LightingSystemDebugHook")
		local var_4_68 = var_4_1 and var_4_1:getHook("SceneDebugHook")
		local var_4_69 = false

		if var_4_67 then
			local var_4_70 = arg_4_0.lightingModule.dynamicEnvironment
			local var_4_71 = arg_4_0.lightingModule.stadiumCfg.dynamicenv_lighting

			var_4_67:initialise(arg_4_1, var_4_64, var_4_70, var_4_71, var_4_44, var_4_54, var_4_53, var_4_69, arg_4_0.sceneRenderer, var_4_68, clut.Clut)

			local var_4_72 = var_4_1 and var_4_1:getHook("TimelapseDebugHook")

			if var_4_72 then
				var_4_72:setLightingHook(var_4_67)

				arg_4_0.timelapseDebugHook = var_4_72
			end
		end
	end

	local var_4_73 = var_4_1 and var_4_1:getHook("SceneDebugHook")

	if var_4_73 then
		var_4_73:initialise(arg_4_0.scene)
	end

	var_4_46:registerOnPreWipe(function()
		arg_4_0.wasWipe = true
	end)
	var_4_46:registerOnPreWipe(function()
		for iter_15_0, iter_15_1 in pairs(var_4_16) do
			iter_15_1:clear()
		end
	end)
	arg_4_0:registerSolidEventListener(function(arg_16_0)
		var_4_53:updateTime()
	end, "AddTimeEvent")
	arg_4_0:registerSolidEventListener(function(...)
		arg_4_0:onDisposalEvent(...)
	end, "DisposalEvent")

	local var_4_74 = gamers.create(var_4_3, var_4_46)

	arg_4_0.gamers = var_4_74
	var_4_29.gamers = var_4_74

	local var_4_75 = gamecontrollerset.GameControllerSet()

	arg_4_0.gameControllerSet = var_4_75
	var_4_29.gameControllerSet = var_4_75

	local var_4_76 = skipstate_provider.SkipStateProvider(var_4_9, var_4_74)

	var_4_29.skipStateProvider = var_4_76

	local var_4_77 = match.Match(arg_4_2)

	arg_4_0.match = var_4_77

	local var_4_78 = var_4_46:editSolidState()
	local var_4_79 = var_4_46:getGameObjects()
	local var_4_80 = var_4_46:getGameState()

	arg_4_0:addMatchComponent("matchInfo", matchinfo.MatchInfo(var_4_3, arg_4_2, arg_4_3, arg_4_4, var_4_78, var_4_46, var_4_29))

	local var_4_81 = var_4_3.stateOfTheSeason and var_4_3.stateOfTheSeason or {
		leagueInfo = {
			fixtureType = "exhibition"
		}
	}

	arg_4_0:addMatchComponent("stateOfTheSeason", var_4_81)
	arg_4_0:addMatchComponent("timeInfo", var_4_53)
	arg_4_0:addMatchComponent("weather", var_4_44)
	arg_4_0:addMatchComponent("rulesInfo", rulesinfo.RulesInfo())
	arg_4_0:addMatchComponent("matchOutData", arg_4_3)
	arg_4_0:addMatchComponent("matchInData", arg_4_2)
	arg_4_0:addMatchComponent("matchInProgressData", arg_4_4)

	local var_4_82 = native.CAssetIdMap()

	var_4_77:addComponent("assetIdMap", var_4_82)
	native.CBodyCommandBucket.initialisePool(500)
	native.CBlendCommandBucket.initialisePool(500)

	local var_4_83 = arg_4_0:createPools(var_4_46, var_4_25)

	var_4_83.gamerControlStatePool = var_4_78:getGamerControlStatePool()
	var_4_29.pools = var_4_83
	var_4_29.cPools = native.CObjectContainer(var_4_83)

	local var_4_84 = native.CMovementCommandParamsFactory(var_4_83.positionInfoPool, var_4_83.velocityInfoPool, var_4_83.preferredMotionProfilePool, var_4_83.playerAnimationPool, var_4_83.animationSequenceDataPool, var_4_83.scalePool, var_4_83.motionPathPool, var_4_83.motionProfiles)

	var_4_29.movementCommandParamsFactory = var_4_84

	local var_4_85 = knowledge.Knowledge()

	arg_4_0.knowledge = var_4_85

	local var_4_86, var_4_87 = var_4_85:init(arg_4_1, var_4_25, var_4_83, var_4_29, var_4_77, var_0_18, var_0_20, var_0_21, var_0_19, var_0_22)

	var_4_29.knowledgeBank = var_4_86
	var_4_29.cKnowledgeBank = var_4_87
	arg_4_0.inputs = var_4_74:createInputs(input_configurations.configurations)

	var_4_74:initialise(arg_4_1, var_4_9, var_4_3, var_4_78)

	local var_4_88 = {
		engine = arg_4_1,
		services = var_4_29,
		gamers = var_4_74,
		scene = var_4_47,
		materialGroups = var_4_50,
		gameobjects = var_4_79,
		match = var_4_77,
		gamestate = var_4_80
	}
	local var_4_89 = arg_4_0:createHud(arg_4_1, var_4_83, var_0_18, var_4_3, arg_4_2, var_4_88)

	var_4_29.hud = var_4_89

	local var_4_90 = arg_4_1:getBlobManager()
	local var_4_91 = var_4_5:generateTexture(32, 32, 0, 0, 0, 1)

	var_4_23:registerFactory("FadeTexture", function()
		return var_4_91
	end)

	arg_4_0.blankUniverseTexture = var_4_91

	local var_4_92 = arg_4_0.screenTransition
	local var_4_93 = screenwipe_factory.ScreenWipeFactory(arg_4_1, var_4_47, var_4_92)

	var_4_23:registerFactory("ScreenWipeVisual", var_4_93)

	arg_4_0.screenWipeFactory = var_4_93

	local var_4_94 = native.CSimTimeSystem()

	arg_4_0.simTimeSystem = var_4_94
	var_4_29.simTimeSystem = var_4_94

	var_4_46:setSimTimeSystem(var_4_94)

	local var_4_95 = simtime_listener.SimTimeListener(var_4_9, var_4_94)

	arg_4_0:registerWithMatchSim(var_4_95)

	if not arg_4_2.trainingMode then
		local var_4_96 = arg_4_1:getNetworkService():getRichPresenceController()
		local var_4_97 = richpresence_listener.RichPresenceListener(arg_4_1, var_4_74, var_4_29, var_4_96, arg_4_2, arg_4_3, var_4_80)

		arg_4_0:registerWithMatchSim(var_4_97)

		arg_4_0.richPresenceListener = var_4_97
	end

	profile.pop("post scene misc")
	var_0_4("Universe:loadMatch:player anim set")
	profile.push("player anim set")

	local var_4_98 = assetjoin.AssetJoin(var_4_7, "jointClassSetJoin")
	local var_4_99 = servermatch_system.ServerMatchSystem(arg_4_0, arg_4_1, var_4_29.uiServices, arg_4_2, arg_4_3)

	arg_4_0:registerWithMatchSim(var_4_99)

	arg_4_0.serverMatchSystem = var_4_99

	local var_4_100 = arg_4_1:getAnimationManager()
	local var_4_101 = playeranimationset.loadPlayerAnimationSets(var_4_100, nil)

	for iter_4_0, iter_4_1 in pairs(var_4_101) do
		var_4_98:addAsset(iter_4_1)
	end

	profile.pop("player anim set")
	var_0_4("Universe:loadMatch:post player anim set misc")
	profile.push("post player anim set misc")

	local var_4_102 = assetjoin.AssetJoin(var_4_7, "playSetJoin")
	local var_4_103 = assert(arg_4_1:getPlaySetManager())
	local var_4_104 = var_4_103:load("plays/playset.dat")

	ASSERT(var_4_104)

	arg_4_0.playSet = var_4_104
	var_4_29.playSet = var_4_104

	var_4_102:addAsset(var_4_104)

	local var_4_105 = assetjoin.AssetJoin(var_4_7, "formationSetJoin")
	local var_4_106 = var_4_103:load("plays/formationset.dat")

	ASSERT(var_4_106)

	arg_4_0.formationSet = var_4_106
	var_4_29.formationSet = var_4_106

	var_4_105:addAsset(var_4_106)

	local var_4_107 = native.CInfluenceMapContainer()

	var_4_107:addHeatMap(native.EHeatMapType.WestFieldLines):initialiseFromFilename(arg_4_1, "textures/heatmaps/westfieldlines.raw")
	var_4_107:addHeatMap(native.EHeatMapType.EastFieldLines):initialiseFromFilename(arg_4_1, "textures/heatmaps/eastfieldlines.raw")
	var_4_107:addHeatMap(native.EHeatMapType.PuntEast):initialiseFromFilename(arg_4_1, "textures/heatmaps/punteast.raw")
	var_4_107:addHeatMap(native.EHeatMapType.PuntEast20m):initialiseFromFilename(arg_4_1, "textures/heatmaps/punteast20m.raw")
	var_4_107:addHeatMap(native.EHeatMapType.PuntEast40m):initialiseFromFilename(arg_4_1, "textures/heatmaps/punteast40m.raw")
	var_4_107:addHeatMap(native.EHeatMapType.PuntEastGoalLine):initialiseFromFilename(arg_4_1, "textures/heatmaps/punteastgoalline.raw")
	var_4_107:addHeatMap(native.EHeatMapType.PuntWest):initialiseFromFilename(arg_4_1, "textures/heatmaps/puntwest.raw")
	var_4_107:addHeatMap(native.EHeatMapType.PuntWest20m):initialiseFromFilename(arg_4_1, "textures/heatmaps/puntwest20m.raw")
	var_4_107:addHeatMap(native.EHeatMapType.PuntWest40m):initialiseFromFilename(arg_4_1, "textures/heatmaps/puntwest40m.raw")
	var_4_107:addHeatMap(native.EHeatMapType.PuntWestGoalLine):initialiseFromFilename(arg_4_1, "textures/heatmaps/puntwestgoalline.raw")
	var_4_107:addHeatMap(native.EHeatMapType.Grubber):initialiseFromFilename(arg_4_1, "textures/heatmaps/grubber.raw")
	var_4_107:addHeatMap(native.EHeatMapType.FortyTwentyWest):initialiseFromFilename(arg_4_1, "textures/heatmaps/fortytwentywest.raw")
	var_4_107:addHeatMap(native.EHeatMapType.FortyTwentyEast):initialiseFromFilename(arg_4_1, "textures/heatmaps/fortytwentyeast.raw")
	var_4_107:addHeatMap(native.EHeatMapType.TwentyFortyWest):initialiseFromFilename(arg_4_1, "textures/heatmaps/twentyfortywest.raw")
	var_4_107:addHeatMap(native.EHeatMapType.TwentyFortyEast):initialiseFromFilename(arg_4_1, "textures/heatmaps/twentyfortyeast.raw")
	var_4_107:addHeatMap(native.EHeatMapType.FortyThirtyWest):initialiseFromFilename(arg_4_1, "textures/heatmaps/fortythirtywest.raw")
	var_4_107:addHeatMap(native.EHeatMapType.FortyThirtyEast):initialiseFromFilename(arg_4_1, "textures/heatmaps/fortythirtyeast.raw")
	var_4_107:addHeatMap(native.EHeatMapType.TwentyFiftyWest):initialiseFromFilename(arg_4_1, "textures/heatmaps/twentyfiftywest.raw")
	var_4_107:addHeatMap(native.EHeatMapType.TwentyFiftyEast):initialiseFromFilename(arg_4_1, "textures/heatmaps/twentyfiftyeast.raw")

	arg_4_0.influenceMapContainer = var_4_107
	var_4_29.influenceMapContainer = var_4_107

	local var_4_108 = native.CPlaySet(arg_4_1)

	table.insert(arg_4_0.sceneDisposalQueue, function()
		var_4_108:dispose()
	end)

	arg_4_0.playSetContainer = var_4_108
	var_4_29.playSetContainer = var_4_108

	local var_4_109 = arg_4_0.playsPreferenceList

	var_4_29.playsPreferenceList = var_4_109

	ASSERT(var_4_109)
	var_4_102:fire(function()
		if not native.isRetail() then
			var_4_104.data:verify()
		end

		var_4_104.data:registerWithPreferenceList(var_4_109)
		var_4_108:processPlaySet(var_4_104.data)
	end)
	var_4_105:fire(function()
		if not native.isRetail() then
			var_4_106.data:verify()
		end

		var_4_108:processFormationSet(var_4_106.data)
	end)

	local var_4_110 = assetjoin.AssetJoin(var_4_7, "animControllerSetJoin")
	local var_4_111 = VERIFY(arg_4_1:getMotionSetManager())
	local var_4_112 = var_4_111:load("animations/motionset.motionset")

	arg_4_0.motionSet = VERIFY(var_4_112)
	var_4_29.motionSet = var_4_112

	var_4_98:addAsset(var_4_112)

	local var_4_113 = VERIFY(arg_4_1:getAnimUnitManager())
	local var_4_114 = var_4_113:load("animations/animunit.animunit")

	arg_4_0.animUnits = VERIFY(var_4_114)
	var_4_29.animUnits = var_4_114

	var_4_98:addAsset(var_4_114)

	local var_4_115 = var_4_100:load("animations/cameocameras.animset")

	arg_4_0.cameoCamerasAnimSet = var_4_115

	var_4_98:addAsset(var_4_115)

	local var_4_116 = VERIFY(arg_4_1:getActionSetManager())
	local var_4_117 = var_4_116:load("actionset/actionset.dat")

	arg_4_0.actionSet = VERIFY(var_4_117)
	var_4_29.actionSet = var_4_117

	var_4_98:addAsset(var_4_117)

	local var_4_118 = var_4_116:load("actionset/collectset.dat")

	arg_4_0.collectSet = VERIFY(var_4_118)
	var_4_29.collectSet = var_4_118

	var_4_98:addAsset(var_4_118)

	local var_4_119 = var_4_116:load("actionset/strikeset.dat")

	arg_4_0.strikeSet = VERIFY(var_4_119)
	var_4_29.strikeSet = var_4_119

	var_4_98:addAsset(var_4_119)

	local var_4_120 = var_4_116:load("actionset/tackleset.dat")

	arg_4_0.tackleSet = VERIFY(var_4_120)
	var_4_29.tackleSet = var_4_120

	var_4_98:addAsset(var_4_120)

	local var_4_121 = var_4_116:load("actionset/tryset.dat")

	arg_4_0.trySet = VERIFY(var_4_121)
	var_4_29.trySet = var_4_121

	var_4_98:addAsset(var_4_121)

	local var_4_122 = var_4_116:load("actionset/playtheballset.dat")

	arg_4_0.playTheBallSet = VERIFY(var_4_122)
	var_4_29.playTheBallSet = var_4_122

	var_4_98:addAsset(var_4_122)

	local var_4_123 = var_4_116:load("actionset/kickset.dat")

	arg_4_0.kickSet = VERIFY(var_4_123)
	var_4_29.kickSet = var_4_123

	var_4_98:addAsset(var_4_123)

	local var_4_124 = var_4_116:load("actionset/scrumset.dat")

	arg_4_0.scrumSet = VERIFY(var_4_124)
	var_4_29.scrumSet = var_4_124

	var_4_98:addAsset(var_4_124)

	local var_4_125 = var_4_116:load("actionset/contestset.dat")

	arg_4_0.contestSet = VERIFY(var_4_125)
	var_4_29.contestSet = var_4_125

	var_4_98:addAsset(var_4_125)

	local var_4_126 = var_4_116:load("actionset/placekickset.dat")

	arg_4_0.placeKickSet = VERIFY(var_4_126)
	var_4_29.placeKickSet = var_4_126

	var_4_98:addAsset(var_4_126)

	local var_4_127 = VERIFY(arg_4_1:getNaturalMovementManager()):load("naturalmovement/naturalmovement.dat")

	ASSERT(var_4_127)

	local var_4_128 = assetjoin.AssetJoin(var_4_7, "jointClassSetJoin")

	var_4_128:addAsset(var_4_127)

	arg_4_0.naturalMovementSetData = var_4_127

	local var_4_129 = native.CNaturalMovementContainer()

	var_4_29.naturalMovementSet = var_4_129
	arg_4_0.naturalMovementSet = var_4_129

	var_4_128:fire(function()
		if not native.isRetail() then
			var_4_127.data:verify()
		end

		var_4_129:load(var_4_127.data)
	end)

	local var_4_130 = native.CForceDirectedGraphContainer()
	local var_4_131 = forcedirectedgraphloader.ForceDirectedGraphLoader()

	var_4_131:init(var_4_29, arg_4_1, var_4_130)

	arg_4_0.forceDirectedGraphSet = var_4_130
	var_4_29.forceDirectedGraphSet = var_4_130
	arg_4_0.onReloadForceDirectedGraph = package.registerOnReload(function()
		var_4_131:init(var_4_29, arg_4_1, var_4_130)
	end)

	local var_4_132 = native.CSubstitutesPositionsContainer()
	local var_4_133 = substitutespositions_loader.SubstitutesPositionsLoader()

	var_4_133:init(var_4_29, arg_4_1, var_4_132)

	var_4_29.substitutesPositionsSet = var_4_132
	arg_4_0.onReloadSubstitutesPositions = package.registerOnReload(function()
		var_4_133:init(var_4_29, arg_4_1, var_4_132)
	end)

	local var_4_134 = native.CAnimationProvider(var_4_100)
	local var_4_135 = var_4_101.masterAnimSet

	var_4_134:addAnimationSet(var_4_135, false, var_4_112)

	for iter_4_2, iter_4_3 in pairs(var_4_101) do
		if iter_4_3 ~= var_4_135 then
			var_4_134:addAnimationSet(iter_4_3, false, var_4_112)
		end
	end

	arg_4_0.animationProvider = var_4_134
	var_4_29.animationProvider = var_4_134

	local var_4_136 = native.CAnimationHistoryContainer()

	var_4_29.animationHistoryContainer = var_4_136
	arg_4_0.animationHistoryContainer = var_4_136

	local var_4_137 = native.CAnimationProvider(var_4_100)

	var_4_137:addAnimationSet(var_4_115, false)

	arg_4_0.cameoCameraAnimationProvider = var_4_137
	var_4_29.cameoCameraAnimationProvider = var_4_137

	local var_4_138 = animsetloader.AnimsetLoader(var_4_134, var_4_100)

	var_4_46:registerOnPostWipe(function(arg_25_0, arg_25_1, arg_25_2, arg_25_3, arg_25_4, arg_25_5, arg_25_6, arg_25_7, arg_25_8, arg_25_9, arg_25_10)
		arg_4_0.lightingModule.dynamicEnvironment:onPostWipe()
		arg_4_0:updateLighting(arg_4_0.timeOfDay)
		arg_25_3.renderer:onPostWipe()
		arg_4_0:applyCamera(arg_4_0.ccamera, 0.016666666666666666, arg_25_3, arg_25_8)
	end)
	var_4_46:registerOnPostWipe(function(arg_26_0, arg_26_1, arg_26_2, arg_26_3, arg_26_4, arg_26_5, arg_26_6, arg_26_7, arg_26_8, arg_26_9, arg_26_10)
		var_4_138:unloadPending()
	end)

	var_4_29.animsetLoader = var_4_138

	var_4_98:fire(function()
		local var_27_0 = VERIFY(arg_4_0.sceneRenderer)
		local var_27_1 = VERIFY(arg_4_0.sceneDisposalQueue)
		local var_27_2 = assert(var_4_114.data)
		local var_27_3 = assert(var_4_112.data)
		local var_27_4
		local var_27_5

		movement_config.initialise(var_27_2, var_27_3)
	end)

	local var_4_139 = playeranimationset.loadJointClassSet(var_4_134, var_4_100, var_4_98)

	arg_4_0.animationSets, arg_4_0.jointClassSet = var_4_101, var_4_139
	var_4_29.jointClassSet = var_4_139

	playeranimationset.loadBodyAnimationControllerSet(var_4_98, var_4_41, var_4_29, var_4_110)

	local var_4_140 = playeranimationset.loadBlendAnimationControllerSet(var_4_98, var_4_29, var_4_110)

	arg_4_0.blendAnimationControllerSet = var_4_140
	var_4_29.blendAnimationControllerSet = var_4_140

	local var_4_141 = native.CAnimationGroupService()

	var_4_29.animationGroupService = var_4_141
	arg_4_0.animationGroupService = var_4_141

	var_4_46:registerOnPreWipe(function(arg_28_0, arg_28_1, arg_28_2, arg_28_3, arg_28_4, arg_28_5, arg_28_6, arg_28_7, arg_28_8, arg_28_9, arg_28_10)
		arg_4_0:waitForAllJobs(arg_28_0)
	end)
	var_4_46:registerOnPostWipe(function(arg_29_0, arg_29_1, arg_29_2, arg_29_3, arg_29_4, arg_29_5, arg_29_6, arg_29_7, arg_29_8, arg_29_9, arg_29_10)
		local var_29_0 = arg_4_0.humanoidIdList
		local var_29_1 = arg_29_8:getBallObject()

		var_4_83.ballPosition.position = var_29_1.pos3
		var_4_83.ballPosition.velocity = var_29_1.velocity

		profile.push("(actorTransformUpdateProcess)")
		arg_4_0.processes.actorTransformUpdateProcess:update(var_29_0)
		profile.pop("(actorTransformUpdateProcess)")

		for iter_29_0, iter_29_1 in var_29_0:iter() do
			arg_29_8:getGameObject(iter_29_1).actorModel.skeleton:updateTransforms()
		end
	end)
	var_4_46:registerOnPreWipe(function(...)
		return var_4_77:onPreWipe(...)
	end)

	local var_4_142 = var_4_15.fieldConfig.physics

	arg_4_0.fieldPhysicsConfig = var_4_142

	local var_4_143 = outofframerequestgatherer.OutOfFrameRequestGatherer()

	var_4_143:registerWithMatchSim(var_4_46)

	var_4_29.outOfFrameRequestGatherer = var_4_143

	table.insert(arg_4_0.finaliseList, function()
		propfactory.register_props_with_match_sim(arg_4_0.stadium.propScene, var_4_46)

		arg_4_0.onReloadPropControllers = _G.registerOnReload(function()
			local var_32_0 = VERIFY(arg_4_0.stadium.propScene)

			propfactory.reload_prop_controllers(var_32_0, arg_4_0.physicsScene)
		end)
	end)

	local var_4_144, var_4_145, var_4_146 = arg_4_0:loadBall({
		engine = arg_4_1,
		matchInData = arg_4_2,
		matchSettings = var_4_3,
		matchSim = var_4_46,
		solidState = var_4_78,
		idManager = var_4_25,
		pools = var_4_83,
		scene = var_4_47,
		physicsScene = var_4_48,
		sceneRenderer = VERIFY(arg_4_0.sceneRenderer)
	})
	local var_4_147 = native.createTable(0, tablex.count(cutscene_props.Props))
	local var_4_148 = native.createTable(2, 0)

	for iter_4_4, iter_4_5 in pairs(cutscene_props.Props) do
		local var_4_149 = native.ModelLoader.load(var_4_4, iter_4_5, var_4_47)

		var_4_149.visible = false
		var_4_147[iter_4_4] = var_4_149
	end

	arg_4_0.cutsceneProps = var_4_147
	arg_4_0.cutsceneTextures = var_4_148
	var_4_29.cutsceneProps = var_4_147

	local var_4_150 = assert(arg_4_0.sceneRenderer)

	if var_4_3.enableStumpCamFilter then
		var_4_150.fishEyeStrength = 1
		var_4_150.fishEyeInner = 0.6
		var_4_150.fishEyeOuter = 0.5
	end

	local var_4_151 = arg_4_1:getDialogueWildcardHashManager()

	var_4_29.headLookAtConfigDict = native.CHeadLookAtConfigDict()

	lookatconfig.readLookAtConfigDict(var_4_29.headLookAtConfigDict)

	local var_4_152 = native.CPlayerDefaultVisualManager()

	var_4_152:loadDefaults(arg_4_1)

	arg_4_0.services.defaultPlayerVisualManager = var_4_152

	local var_4_153 = native.CTeamDefaultVisualManager()

	var_4_153:loadDefaults(arg_4_1)

	arg_4_0.services.defaultTeamVisualManager = var_4_153

	local var_4_154 = {
		headslocation = "heads/",
		rig = "player_male",
		engine = arg_4_1,
		network = var_4_29.network,
		matchSettings = var_4_3,
		matchInData = arg_4_2,
		matchOutData = arg_4_3,
		matchInProgressData = arg_4_4,
		match = var_4_77,
		matchSim = var_4_46,
		idManager = var_4_25,
		scene = var_4_47,
		pools = var_4_83,
		gamers = arg_4_0.gamers,
		solidState = var_4_78,
		animationProvider = var_4_134,
		motionSetContainer = VERIFY(var_4_112),
		animUnitsContainer = VERIFY(var_4_114),
		defaultPlayerVisualManager = var_4_152,
		defaultTeamVisualManager = var_4_153,
		bodyAnimationControllerSet = var_4_41,
		blendAnimationControllerSet = var_4_140,
		jointClassSet = var_4_139,
		materialGroups = var_4_50,
		knowledgeBank = var_4_86,
		hooks = var_4_1,
		aspectManager = arg_4_0.aspectManager,
		physicsScene = var_4_48,
		commentarySurnameHashes = var_4_151:getMap("surnames"),
		guidManager = var_4_33,
		idleService = VERIFY(var_4_29.idleService),
		emotionService = VERIFY(var_4_29.emotionService),
		characterManager = arg_4_0.characterManager,
		characterBodyTextureSourceQueue = arg_4_0.characterBodyTextureSourceQueue,
		characterHeadTextureSourceQueue = arg_4_0.characterHeadTextureSourceQueue,
		characterEyesTextureSourceQueue = arg_4_0.characterEyesTextureSourceQueue,
		characterUniformTextureSourceQueue = arg_4_0.characterUniformTextureSourceQueue,
		characterHeadgearTextureSourceQueue = arg_4_0.characterHeadgearTextureSourceQueue,
		textureCompressor = arg_4_0.textureCompressor,
		renderer = arg_4_0.sceneRenderer,
		characterAssetMap = arg_4_0.characterAssetMap,
		lighting = arg_4_0.lighting,
		graphicsSettings = arg_4_1:getGraphicsSettings()
	}
	local var_4_155 = assetjoin.AssetJoin(var_4_7, "loadPosePlayer")
	local var_4_156 = var_4_155:hold("animset")
	local var_4_157 = poseplayer.PosePlayer()

	var_4_29.posePlayer = var_4_157:get()
	arg_4_0.posePlayer = var_4_157

	local var_4_158 = arg_4_1:getRenderInterface()
	local var_4_159 = VERIFY(arg_4_1:getParticleController())

	var_4_159:init(arg_4_1, var_4_158, arg_4_1:getFileSystem(), arg_4_1:getMemPackManager(), arg_4_1:getAssetManager(), var_4_5, native.EEfkRenderPassIndex.Default)

	local var_4_160 = particleassets.GameplayAssets

	for iter_4_6, iter_4_7 in pairs(var_4_160) do
		var_4_159:loadAsset(iter_4_7)
	end

	if GAME_RUGBY then
		var_4_29.kickingTee = assert(physicsfactory.createTrainingDrillProp(var_4_29, var_4_154, "kickingTee", native.vec3.Zero(), "kickingTee"))
		var_4_29.kickingTee.visible = false
		var_4_29.moveableKickingTee = assert(physicsfactory.createTrainingDrillProp(var_4_29, var_4_154, "moveableKickingTee", native.vec3.Zero(), "moveableKickingTee"))
		var_4_29.moveableKickingTee.visible = false
	end

	local var_4_161 = stadiumpan.StadiumPan()

	var_4_161:init(arg_4_2)

	var_4_29.stadiumPan = var_4_161

	local var_4_162 = arg_4_1:getNetworkService()
	local var_4_163 = native.CActionProducer(var_0_8)

	var_4_29.actionProducer = var_4_163

	var_4_163:clear()
	var_4_110:fire(function()
		profile.push("animationControllerSetJoin:fire")

		local var_33_0 = arg_4_0.idleService
		local var_33_1 = arg_4_0.emotionService

		var_33_0:resolveAnimations(arg_4_0.animationProvider, arg_4_0.cheerleaderAnimationProvider, arg_4_0.animUnits.data)
		var_33_1:resolveAnimations(arg_4_0.animationProvider, arg_4_0.cheerleaderAnimationProvider)

		local var_33_2 = arg_4_0.animationGroupService

		for iter_33_0, iter_33_1 in pairs(var_4_101) do
			assert(iter_33_1)
			assert(iter_33_1:isLoaded())
			var_33_2:addAnimations(iter_33_1)
		end

		var_4_157:load(var_4_154)
		var_4_155:releaseHold(var_4_156)
		profile.pop("animationControllerSetJoin:fire")
		var_4_163:initialise(var_4_134, var_4_117.data, var_4_118.data, var_4_119.data, var_4_120.data, var_4_121.data, var_4_122.data, var_4_123.data, var_4_124.data, var_4_125.data, var_4_126.data)
		animationserviceregistration.createAnimationServices(arg_4_1, var_4_29, var_4_157.posePlayer, var_4_134)

		local var_33_3 = assert(var_4_83.skeletonModifierPool)
		local var_33_4, var_33_5, var_33_6 = var_4_157:get()
		local var_33_7 = not native.getEnvironment():argExists("lod0")

		arg_4_0.thumbnailGenerator = ingame_thumbnail_generator.IngameThumbnailGenerator(arg_4_1, arg_4_0.sceneRenderer, var_4_47, var_33_5, var_33_4, var_33_3, var_4_83.actorModelPool, var_33_7)

		if arg_4_0.thumbnailGenerator then
			table.insert(arg_4_0.sceneDisposalQueue, function()
				arg_4_0.thumbnailGenerator:dispose()

				arg_4_0.thumbnailGenerator = nil
			end)
		end

		var_4_29.thumbnailGenerator = arg_4_0.thumbnailGenerator

		if not native.isRetail() then
			native.CUnitTests.execute(arg_4_1, var_4_9, var_4_74, var_4_29, var_4_33, var_4_77, var_4_78, var_4_79)
		end
	end, function()
		print("animationSet cancelled during load")
		var_4_155:cancelHold(var_4_156)
	end)

	local var_4_164 = vibration_listener.VibrationListener(arg_4_1)

	arg_4_0:registerWithMatchSim(var_4_164)

	var_4_29.vibrationListener = var_4_164

	local var_4_165 = vibration_system.VibrationSystem(arg_4_1, var_4_29)

	arg_4_0:registerWithMatchSim(var_4_165)

	var_4_29.vibrationSystem = var_4_165
	arg_4_0.vibrationSystem = var_4_165

	if not arg_4_0.uniformDecorator then
		local var_4_166 = native.CUniformDecorator()

		if PLATFORM_SWITCH then
			var_4_166:init(arg_4_1, arg_4_0.sceneRenderer, 512, 512)
		else
			var_4_166:init(arg_4_1, arg_4_0.sceneRenderer, 1024, 1024)
		end

		arg_4_0.uniformDecorator = var_4_166
	end

	arg_4_0:loadTeams(var_4_29, var_4_154, var_4_45, var_4_82)

	local var_4_167 = tablex.merge(var_4_154, {
		authority = var_4_9:sessionMasterId(),
		uniformDecorator = arg_4_0.uniformDecorator,
		decalDatabase = arg_4_2.umpireConfig.decalDatabase
	})

	arg_4_0:loadUmpires(var_4_167)
	arg_4_0:loadNPCs(var_4_167)

	if var_4_60 then
		local var_4_168 = arg_4_0.stadium
		local var_4_169 = var_4_168 and var_4_168.grass
		local var_4_170 = assert(var_4_15.fieldConfig)
		local var_4_171 = var_4_169 and var_4_169.cdegradation

		arg_4_0.degradationTile = var_4_171

		var_4_60:init({
			universe = arg_4_0,
			grassConfig = var_4_170,
			matchSim = var_4_46,
			degradationTile = var_4_171,
			gameobjects = var_4_79,
			renderer = arg_4_0.sceneRenderer,
			matchInData = arg_4_2
		})
	end

	arg_4_0:addMatchComponent("trainingInfo", traininginfo.TrainingInfo(var_4_3, var_4_74, var_4_29, var_4_89))

	local var_4_172 = traininginfo_listener.TrainingInfoListener(var_4_3)

	arg_4_0:registerWithMatchSim(var_4_172)
	arg_4_0:initIdLists(var_4_29, var_4_46)

	local var_4_173 = native.CPassTargetSelection()

	var_4_173.inPlayInfoPool = VERIFY(var_4_86.inPlayInfoPool)
	var_4_173.activePlayerIdList = VERIFY(arg_4_0.playerIdList)
	var_4_173.positionInfoPool = VERIFY(var_4_83.positionInfoPool)
	var_4_173.velocityInfoPool = VERIFY(var_4_83.velocityInfoPool)
	var_4_173.roleInfoPool = VERIFY(var_4_78:getRoleInfoPool())
	var_4_173.sidePool = VERIFY(var_4_83.sidePool)
	var_4_173.derivedAttributesPool = VERIFY(var_4_86.derivedAttributesPool)
	var_4_173.teamSupportRunnerKnowledgePair = VERIFY(var_4_86.teamSupportRunnerKnowledgePair)
	var_4_173.playerPlayKnowledgePool = VERIFY(var_4_86.playerPlayKnowledgePool)
	var_4_173.quickPassQueryConfig = VERIFY(passing_cconfig.QuickPass)
	var_4_173.poweredPassQueryConfig = VERIFY(passing_cconfig.PoweredPass)
	var_4_173.flatCutoutPassQueryConfig = VERIFY(passing_cconfig.FlatPass)
	var_4_173.deepCutoutPassQueryConfig = VERIFY(passing_cconfig.DeepPass)
	var_4_173.backPassQueryConfig = VERIFY(passing_cconfig.BackPass)
	var_4_173.offloadPassQueryConfig = VERIFY(passing_cconfig.OffloadPass)
	var_4_173.incapacitatedInfoPool = VERIFY(var_4_78:getIncapacitatedInfoPool())
	arg_4_0.passTargetSelection = var_4_173
	var_4_29.passTargetSelection = var_4_173

	local var_4_174 = native.CKickTargetSelection()

	var_4_174.inPlayInfoPool = VERIFY(var_4_86.inPlayInfoPool)
	var_4_174.activePlayerIdList = VERIFY(arg_4_0.playerIdList)
	var_4_174.positionInfoPool = VERIFY(var_4_83.positionInfoPool)
	var_4_174.velocityInfoPool = VERIFY(var_4_83.velocityInfoPool)
	var_4_174.sidePool = VERIFY(var_4_83.sidePool)
	var_4_174.chipKickQueryConfig = VERIFY(kicking_cconfig.ChipKick)
	arg_4_0.kickTargetSelection = var_4_174
	var_4_29.kickTargetSelection = var_4_174

	local var_4_175 = native.CBalanceArbitrator()

	var_4_175.gameplayBalance = var_0_11
	var_4_175.playerDerivedSkillPool = VERIFY(var_4_86.playerDerivedSkillPool)
	var_4_175.arbitrationResultListPool = VERIFY(var_4_86.arbitrationResultListPool)
	var_4_175.positionInfoPool = VERIFY(var_4_83.positionInfoPool)
	arg_4_0.balanceArbitrator = var_4_175
	var_4_29.balanceArbitrator = var_4_175
	arg_4_0.onReloadActorModels = package.registerOnReload(function()
		local var_36_0 = arg_4_1:getJobManager()

		arg_4_0:waitForAllJobs(arg_4_1)
		arg_4_1:getHelperJointsLoader():reload(arg_4_1:getBlobManager())
		arg_4_1:getJigglyConfigBlobLoader():reload()
		var_4_111:reload(arg_4_0.motionSet)
		var_4_113:reload(arg_4_0.animUnits)
		var_4_134:reload()

		local var_36_1 = arg_4_1:getAssetMap()
		local var_36_2 = load("design.characters.visualdatamap")

		arg_4_1:getDataConfigMap():reloadScripts(var_36_2)

		local var_36_3 = var_36_1:clone()

		var_36_1:reloadScripts(load("design.characters.assetmap"))
		var_36_1:appendTexSrcRules(var_36_2)

		local var_36_4 = var_4_114.data
		local var_36_5 = var_4_112.data

		if var_36_4 and var_36_5 then
			movement_config.initialise(var_36_4, var_36_5)
			var_4_83.motionProfiles:copy(assert(movement_config.motionProfiles))
		end

		lookatconfig.readLookAtConfigDict(var_4_29.headLookAtConfigDict)

		local var_36_6 = VERIFY(var_4_83.skeletonModifierPool)
		local var_36_7 = var_4_83.actorModelPool

		for iter_36_0, iter_36_1 in var_4_79:objects(humanoidtype.TypeId) do
			local var_36_8 = var_36_7:get(iter_36_0)

			if var_36_8.skeleton and var_36_8.cricketVisual then
				var_36_8.cricketVisual:scriptsReloaded(var_36_3, var_36_1)
			end
		end

		var_4_29.cSpeedConfig = var_0_7.cSpeedConfig

		arg_4_0:updatePhysicsSceneParams()

		if arg_4_0.processes and arg_4_0.processes.preferredMotionProfileSelectProcess then
			arg_4_0.processes.preferredMotionProfileSelectProcess.motionProfileFlowchartList = VERIFY(motionprofileflowchart.flowchartList)
		end

		if arg_4_0.processes and arg_4_0.processes.naturalMovementProfileSelectionProcess then
			arg_4_0.processes.naturalMovementProfileSelectionProcess.naturalMovementFlowchartList = VERIFY(naturalmovementflowchart.flowchartList)
		end

		if arg_4_0.processes and arg_4_0.processes.lookAtConfigSelectProcess then
			arg_4_0.processes.lookAtConfigSelectProcess.lookAtConfigFlowchartList = VERIFY(lookatconfigflowchart.flowchartList)
		end

		if arg_4_0.processes and arg_4_0.processes.collisionBumpSelectProcess then
			arg_4_0.processes.collisionBumpSelectProcess.collisionBumpFlowchartList = VERIFY(collisionbumpflowchart.flowchartList)
		end
	end)

	local var_4_176 = var_4_1 and var_4_1:getHook("CharacterManagerDebugHook")

	if var_4_176 then
		var_4_176:setReloadFn(arg_4_0.onReloadActorModels)
	end

	if GAME_RUGBY then
		local var_4_177 = advantage_listener.AdvantageListener()

		arg_4_0:registerWithMatchSim(var_4_177)
	end

	local var_4_178 = sinbinsystem.SinBinSystem(arg_4_1, arg_4_0, var_4_3)

	arg_4_0:registerWithMatchSim(var_4_178)
	arg_4_0:registerMatchSimUpdateable(var_4_178)

	var_4_29.sinBinSystem = var_4_178
	arg_4_0.sinBinSystem = var_4_178

	arg_4_0:createDefaultCamera(arg_4_1, var_4_3, var_4_20, var_4_46)
	arg_4_0:createGameplayCameras(arg_4_1, var_4_29, var_4_3, var_4_20, var_4_46, var_4_77)
	arg_4_0:createCameoCamera(arg_4_1, var_4_29, var_4_3, var_4_20, var_4_46, var_4_77)
	table.insert(arg_4_0.sceneDisposalQueue, function()
		var_4_29.gameplayCameras:dispose()

		var_4_29.gameplayCameras = nil
		var_4_29.cameoCamera = nil

		if var_4_29.multiplayerCamera then
			var_4_29.multiplayerCamera:dispose()

			var_4_29.multiplayerCamera = nil
		end
	end)
	var_4_77:broadcast("registerWithMatchSim", var_4_46)
	arg_4_0:registerSolidEventListener(function(arg_38_0)
		arg_4_0.gameOver = true
	end, "GameOverEvent")
	statistics_manager.StatisticsManager(arg_4_0, var_4_3.careerStatsMatchType, not var_4_3.nostatistics):registerWithUniverse(var_4_29, arg_4_0, var_4_3)
	arg_4_3.setRatingConfig(matchplayerrating_config)

	local var_4_179 = sound_system.SoundSystem(arg_4_0, arg_4_1, var_4_77, var_4_3, var_4_29, arg_4_0.crowd)

	var_4_29.soundSystem = var_4_179

	arg_4_0:registerWithMatchSim(var_4_179)
	arg_4_0:registerPauseListener(var_4_179)

	arg_4_0.soundSystem = var_4_179

	local var_4_180 = arg_4_0.crowd

	var_4_180:register(var_4_46, arg_4_2, arg_4_4, arg_4_3, var_4_29, var_4_79, arg_4_0.sceneRenderer)
	var_4_180:setCrowdSound(var_4_179.crowdSoundSystem)

	local var_4_181 = committedmiss_listener.CommittedMissListener(var_4_3)

	arg_4_0:registerWithMatchSim(var_4_181)

	local var_4_182 = cameo_listener.CameoListener(var_4_3)

	arg_4_0:registerWithMatchSim(var_4_182)

	local var_4_183 = futuredisposal_listener.FutureDisposalListener(var_4_3)

	arg_4_0:registerWithMatchSim(var_4_183)

	arg_4_0.futureDisposalListener = var_4_183

	local var_4_184 = cutscene_listener.CutsceneListener({
		engine = arg_4_1,
		services = var_4_29,
		matchInData = arg_4_2,
		randomSeed = arg_4_0.matchInProgressData.randomSeed,
		crowd = arg_4_0.crowd,
		scene = var_4_47
	})

	arg_4_0:registerWithMatchSim(var_4_184)

	arg_4_0.cutsceneListener = var_4_184
	var_4_29.cutsceneListener = var_4_184

	if arg_4_2.trainingMode then
		arg_4_0:registerWithMatchSim(tutorial_listener.TutorialListener())
	end

	local var_4_185 = var_4_1 and var_4_1:getHook("BallDebugHook")

	if var_4_185 then
		arg_4_0:registerWithMatchSim(var_4_185)
	end

	arg_4_0:registerWithMatchSim(teleportplayer_listener.registerWithMatchSim)
	arg_4_0:registerWithMatchSim(behaviour_listener.registerWithMatchSim)

	if var_4_9:isMaster() then
		arg_4_0:registerWithMatchSim(metresrun_listener.MetresRunListener())
		arg_4_0:registerWithMatchSim(minuteelapsed_listener.MinuteElapsedListener())
		arg_4_0:registerWithMatchSim(linebreak_listener.LineBreakListener())
		arg_4_0:registerWithMatchSim(ballbounce_listener.BallBounceListener())
	end

	arg_4_0:registerWithMatchSim(playtheball_listener.PlayTheBallListener())
	arg_4_0:registerWithMatchSim(play_listener.PlayListener())
	arg_4_0:registerWithMatchSim(placekick_listener.PlaceKickListener())
	arg_4_0:registerWithMatchSim(passcandidate_listener.PassCandidateListener())
	arg_4_0:registerWithMatchSim(camera_hud_listener.CameraHudListener())
	arg_4_0:registerWithMatchSim(injuryevent_listener.InjuryEventListener())
	arg_4_0:registerWithMatchSim(formation_listener.FormationListener())
	arg_4_0:registerWithMatchSim(possession_listener.PossessionListener())
	arg_4_0:registerWithMatchSim(balance_listener.BalanceListener())
	arg_4_0:registerWithMatchSim(stamina_listener.StaminaListener())

	if GAME_TENNIS then
		arg_4_0:registerWithMatchSim(serve_listener.ServeListener())
	end

	arg_4_0:registerWithMatchSim(substitution_listener.SubstitutionListener())

	arg_4_0.tackleDemoListener = tackledemo_listener.TackleDemoListener()

	arg_4_0:registerWithMatchSim(arg_4_0.tackleDemoListener)
	arg_4_0:registerWithMatchSim(gamersidechange_listener.GamerSideChangeListener(var_4_74, VERIFY(var_4_0.mixins.achievement)))

	if arg_4_2:isBeAProMode() then
		arg_4_0:registerWithMatchSim(beapro_skip_listener.BeAProSkipListener(arg_4_1, var_4_82))
	end

	local var_4_186 = tackle_arbitrator.TackleArbitrator(var_4_29)

	arg_4_0:registerWithMatchSim(var_4_186)

	local var_4_187 = tacklerecentuse_listener.TackleRecentUseListener(var_4_36)

	arg_4_0:registerWithMatchSim(var_4_187)

	local var_4_188 = native.CActiveTackleArbitrator(action.ActionClasses, var_4_78, var_4_29.movementCommandParamsFactory, var_4_86.activeTackleArbitrationKnowledge, var_4_163:getTackleContainer(), var_4_83.positionInfoPool)

	var_4_46:addGlobalArbitrator("activeTackleArbitrator", var_4_188)
	var_4_46:registerOnPreWipe(function(arg_39_0, arg_39_1, arg_39_2, arg_39_3, arg_39_4, arg_39_5, arg_39_6, arg_39_7, arg_39_8, arg_39_9, arg_39_10)
		arg_39_7:getActiveTackleEntity():reset()
	end)

	local var_4_189 = teamtactics_listener.TeamTacticsListener()

	arg_4_0:registerWithMatchSim(var_4_189)

	local var_4_190 = playrecentuse_listener.PlayRecentUseListener()

	arg_4_0:registerWithMatchSim(var_4_190)

	local var_4_191 = gameplayanalytics_listener.GameplayAnalyticsListener(arg_4_1, arg_4_2)

	arg_4_0.gameplayAnalytics = var_4_191

	arg_4_0:registerWithMatchSim(var_4_191, arg_4_2)

	local var_4_192 = contest_arbitrator.ContestArbitrator()

	arg_4_0:registerWithMatchSim(var_4_192)

	local var_4_193 = hitpost_listener.HitPostListener()

	arg_4_0:registerWithMatchSim(var_4_193)

	local var_4_194 = teamorders_listener.TeamOrdersListener()

	arg_4_0:registerWithMatchSim(var_4_194)

	if arg_4_2.onlineMultiplayer and not native.isRetail() then
		local var_4_195 = packagevalidationprocess.PackageValidationProcess(arg_4_1, var_4_9, var_4_3)

		arg_4_0:registerWithMatchSim(var_4_195)

		arg_4_0.packageValidationProcess = var_4_195
	end

	var_4_46:setRestartCheckpoint(var_4_78)

	local var_4_196 = arg_4_0:initReplayManager({
		heapName = "replay",
		engine = arg_4_1,
		services = var_4_29,
		idManager = var_4_25,
		matchSim = var_4_46,
		crowdScene = var_4_180.crowdScene,
		pools = var_4_83,
		ballLoadContext = var_4_146,
		config = var_4_3,
		gamestate = var_4_78,
		hooks = var_4_1,
		knowledgeBank = var_4_29.knowledgeBank
	})

	var_4_29.replayManager = var_4_196
	arg_4_0.replaySaveSystem = replay_savesystem.ReplaySaveSystem(arg_4_1, var_4_29.replayManager)
	var_4_29.replaySaveSystem = arg_4_0.replaySaveSystem

	var_4_155:fire(function()
		return
	end)

	local var_4_197 = var_4_79:getBallObject()

	ASSERT(var_4_197)

	var_4_29.gameplayAnalytics = var_4_191

	local var_4_198 = native.CBallPredictionSystem()

	var_4_198:setConfig(ballprediction_config.SearchFractions)

	var_4_198.ballObject = var_4_197
	var_4_198.getPhysicsForDisposal = ballprediction.getPhysicsForDisposal
	var_4_198.physicsProcess = VERIFY(arg_4_0.physicsScene.physicsProcess)
	arg_4_0.ballPredictionSystem = var_4_198
	var_4_29.ballPredictionSystem = var_4_198

	local var_4_199 = trajectorylines_hud.TrajectoryLinesHud(arg_4_1, var_4_29)

	var_4_199:registerWithMatchSim(var_4_46)

	var_4_29.trajectoryLines = var_4_199
	arg_4_0.trajectoryLines = var_4_199

	transientemotion_component.registerWithMatchSim(var_4_46, var_4_83, var_4_25, emotion_listeners.transient)
	triggeredemotion_component.registerWithMatchSim(var_4_46, var_4_83, var_4_25, emotion_listeners.triggered)
	arg_4_0:createProcesses(arg_4_1, var_4_83, var_4_29, var_4_86, var_4_77, var_4_46, var_4_74, var_4_78, var_4_39).ingameCharacterStreamingProcess:reloadAll()

	var_4_29.bigscreen = arg_4_0.sceneBigscreen

	local var_4_200
	local var_4_201 = var_4_1 and var_4_1:getHook("SimulationStatisticsDebugHook")

	if var_4_201 and var_4_201.collectstatistics then
		var_4_200 = native.CSimulationStatistics(arg_4_1:getFileSystem())
		arg_4_0.services.simulationStatistics = var_4_200
	end

	local var_4_202 = simulationstatistics_listener.SimulationStatisticsListener(var_4_3, var_4_200)

	arg_4_0:registerWithMatchSim(var_4_202)

	arg_4_0.updateParams = {
		engine = arg_4_1,
		hud = var_4_89,
		matchSim = var_4_46,
		scene = var_4_47,
		trails = arg_4_0.trails,
		cameraManager = var_4_20,
		gameControllerSet = var_4_75
	}

	profile.pop("post player anim set misc")

	var_4_29.cSpeedConfig = var_0_7.cSpeedConfig

	if not var_4_3.noachievements then
		local var_4_203 = VERIFY(var_4_0.mixins.achievement)

		var_4_203:registerWithUniverse(arg_4_0)

		var_4_29.achievementMixin = var_4_203
	end

	profile.pop("Universe:loadMatch")
end

function Universe.preloadCharacters(arg_41_0)
	local var_41_0 = arg_41_0.processes.ingameCharacterStreamingProcess
	local var_41_1 = arg_41_0.match
	local var_41_2 = var_41_1:getSide(sidehelper.home)
	local var_41_3 = var_41_1:getSide(sidehelper.away)
	local var_41_4 = {
		var_41_2,
		var_41_3
	}

	for iter_41_0, iter_41_1 in ipairs(var_41_4) do
		local var_41_5 = VERIFY(iter_41_1.matchClub.lineup)
		local var_41_6 = iter_41_1.identityMap
		local var_41_7 = iter_41_1.matchClub
		local var_41_8 = var_41_5:getSpecialRole(native.EClubLineupSpecialRole.Captain)

		for iter_41_2, iter_41_3 in var_41_5:iterPlayers() do
			local var_41_9 = var_41_6[iter_41_3]

			ASSERT(var_41_9)

			local var_41_10 = var_41_9.preferredRolePrimary
			local var_41_11 = iter_41_1:getIdAsset(iter_41_3)

			var_41_0:setRole(var_41_11, "Role_Player", native.EPreferredRole:fromInt(var_41_10), false, true)

			local var_41_12 = true

			var_41_0:setWantLoaded(var_41_11, var_41_12)
		end
	end
end

function Universe.preloadUmpires(arg_42_0)
	local var_42_0 = arg_42_0.processes.ingameCharacterStreamingProcess
	local var_42_1 = VERIFY(arg_42_0.matchSim)

	for iter_42_0, iter_42_1 in VERIFY(var_42_1:getGameObjects()):objects(umpiretype.TypeId) do
		var_42_0:setRole(iter_42_0, "Role_Umpire", native.EPreferredRole.FullBack, false, true)
		var_42_0:setWantLoaded(iter_42_0, true)
	end
end

function Universe.updateLoading(arg_43_0, arg_43_1, arg_43_2)
	if arg_43_0.thumbnailGenerator then
		local var_43_0 = arg_43_0.matchSim:getGameObjects()

		arg_43_0.thumbnailGenerator:update(var_43_0)
	end

	local var_43_1 = arg_43_0.services
	local var_43_2 = arg_43_0.posePlayer
	local var_43_3 = arg_43_0.animationProvider
	local var_43_4 = arg_43_0.pools
	local var_43_5 = arg_43_1:getAssetManager()

	arg_43_0.crowdLoaded = false

	local var_43_6 = arg_43_1:getRenderInterface()
	local var_43_7 = var_43_6:getImmediateContext()
	local var_43_8 = arg_43_1:getGpuTaskService()
	local var_43_9 = VERIFY(arg_43_0.scene)
	local var_43_10 = arg_43_1:getGraphicsSettings().characters
	local var_43_11 = false

	if not arg_43_0.renderJobs.active then
		local var_43_12 = arg_43_0.processes.ingameCharacterStreamingProcess

		var_43_12:update(var_43_10, var_43_5, var_43_7, var_43_6, var_43_8, var_43_9)

		var_43_11 = var_43_12:getLoadsPending()
	end

	if not var_43_11 then
		if arg_43_0.crowd then
			arg_43_0.crowdLoaded = arg_43_0.crowd:updateLoading()
		end

		arg_43_0.soundLoaded = arg_43_0.soundSystem:updateLoading()

		for iter_43_0, iter_43_1 in var_43_4.gearVisualPool:iter() do
			iter_43_1:updateLoading(var_43_10, var_43_7, var_43_5, var_43_9)
		end

		arg_43_0.stadium:updateLoading(arg_43_1, arg_43_2)
	end
end

function Universe.updateUnloading(arg_44_0, arg_44_1, arg_44_2, arg_44_3)
	ASSERT(not arg_44_0.unloadingComplete)

	if not arg_44_0.unloadingComplete then
		local var_44_0 = true
		local var_44_1 = arg_44_0.services.uiServices
		local var_44_2 = arg_44_0.scene

		arg_44_0:updateLoading(arg_44_1, arg_44_3)

		if arg_44_1:getAssetLoadMonitor():pendingLoads() then
			print("asset loading busy")

			var_44_0 = false
		end

		if var_44_1:hasActiveCommsTask() then
			print("hasActiveCommsTask")
			var_44_1:updateAnalyticsQueue(arg_44_3)

			var_44_0 = false
		end

		if arg_44_1:getGpuTaskService():pendingTasks() then
			print("gpu tasks busy")

			var_44_0 = false
		end

		if arg_44_0.saveTask and not arg_44_0.saveTask:isComplete() then
			print("save in progress")

			var_44_0 = false
		end

		arg_44_0.unloadingComplete = var_44_0

		return var_44_0
	else
		return true
	end
end

function Universe.loadingComplete(arg_45_0)
	local var_45_0 = arg_45_0.services
	local var_45_1 = arg_45_0.processes
	local var_45_2 = arg_45_0.posePlayer
	local var_45_3 = arg_45_0.engine
	local var_45_4 = arg_45_0.pools
	local var_45_5 = arg_45_0.animationProvider

	if var_45_1.ingameCharacterStreamingProcess:getLoadsPending() then
		return false, "ingameCharacterStreamingProcess:getLoadsPending()"
	end

	if arg_45_0.thumbnailGenerator and arg_45_0.thumbnailGenerator:isBusy() then
		return false
	end

	if not var_45_2 or not var_45_2:isLoaded() then
		return false, "not posePlayer or not posePlayer:isLoaded()"
	end

	if not animationserviceregistration.isLoaded(var_45_0, var_45_2, var_45_5, var_45_4) then
		return false, "not animationserviceregistration.isLoaded(services, posePlayer, animationProvider, pools)"
	end

	if arg_45_0.stadium and not arg_45_0.stadium:isLoaded() then
		return false, "stadium loading"
	end

	if not arg_45_0.crowdLoaded then
		return false
	end

	if not arg_45_0.soundLoaded then
		return false
	end

	local var_45_6 = var_45_3:getParticleController()

	arg_45_0.sceneRenderer.particleController = var_45_6

	if not arg_45_0:modelLoadingComplete() then
		return false
	end

	if not arg_45_0:charactersReady() then
		return false
	end

	return true
end

function Universe.modelLoadingComplete(arg_46_0)
	return true
end

function Universe.charactersReady(arg_47_0)
	for iter_47_0, iter_47_1 in arg_47_0.matchSim:getGameObjects():objects(playertype.TypeId) do
		if not iter_47_1.actorModel.cricketVisual:isLoaded() then
			return false
		end
	end

	return true
end

function Universe.createPools(arg_48_0, arg_48_1)
	local var_48_0 = native.createTable(0, 128)
	local var_48_1 = var_0_23
	local var_48_2 = var_0_18
	local var_48_3 = var_0_20
	local var_48_4 = var_0_22
	local var_48_5 = var_0_23 + 1

	var_48_0.authoritySet = native.CIdSet()
	var_48_0.actionCallbackAnimateBlendPool = native.CIdPool[native.CActionCallbackFunctionHandle](var_48_1)
	var_48_0.actionCallbackAnimatePool = native.CIdPool[native.CActionCallbackFunctionHandle](var_48_1)
	var_48_0.actionCallbackBlendEventPool = native.CIdPool[native.CActionCallbackFunctionHandle](var_48_1)
	var_48_0.actionCallbackEventPool = native.CIdPool[native.CActionCallbackFunctionHandle](var_48_1)
	var_48_0.actionCallbacksPool = native.CIdPool[native.CActionCallbacks](var_48_1)
	var_48_0.actionCallbackStatePool = native.CIdPool[native.CActionCallbackState](var_48_1)
	var_48_0.actorModelPool = native.CIdPool[native.CActorModel](var_48_1)
	var_48_0.actorTransformPool = native.CIdPool[native.CActorTransform](var_48_1)
	var_48_0.animationEmotionContextPool = native.CIdPool[native.CEmotionContext](var_48_1)
	var_48_0.animationSequenceDataPool = native.CIdPool[native.CAnimationSequenceData](var_48_1)
	var_48_0.animationSequencePool = native.CIdPool[native.CAnimationSequence](var_48_1)
	var_48_0.attachmentInfoPool = native.CIdPool[native.CAttachmentInfo](var_48_1)
	var_48_0.attributesPool = native.CIdPool[native.CPlayerAttributes](var_48_1)
	var_48_0.ballPosition = native.CBallPosition()
	var_48_0.ballPredictionQueryPool = native.CIdPool[native.CBallPredictionQuery](var_48_2)
	var_48_0.ballPredictionResultPool = native.CIdPool[native.CBallPredictionResult](var_48_2)
	var_48_0.behaviourNamePool = native.CIdPool[native.CMoniker](var_48_1)
	var_48_0.behaviourTableHandlePool = native.CIdPool[native.CBehaviourTableHandle](var_48_1)
	var_48_0.behaviourTablePool = behaviours.behaviourTablePool
	var_48_0.blendActionCallbacksPool = native.CIdPool[native.CActionCallbacks](var_48_1)
	var_48_0.blendActionCallbackStatePool = native.CIdPool[native.CActionCallbackState](var_48_1)
	var_48_0.blendAnimationSequenceDataPool = native.CIdPool[native.CAnimationSequenceData](var_48_1)
	var_48_0.blendAnimationSequencePool = native.CIdPool[native.CAnimationSequence](var_48_1)
	var_48_0.blendBehaviourTableHandlePool = native.CIdPool[native.CBehaviourTableHandle](var_48_1)
	var_48_0.blendCommandBucketPool = native.CIdPool[native.CBlendCommandBucket](var_48_1)
	var_48_0.blendControllerNamePool = native.CIdPool[native.CMoniker](var_48_1)
	var_48_0.blendControllerPool = native.CIdPool[native.CControllerHandle](var_48_1)
	var_48_0.blendPreferCurrentSet = native.CIdSet()
	var_48_0.blendStayInCurrentSet = native.CIdSet()
	var_48_0.bodyCommandBucketPool = native.CIdPool[native.CBodyCommandBucket](var_48_1)
	var_48_0.bumpInfoPool = native.CIdPool[native.CBumpInfo](var_48_1)
	var_48_0.characterPoseConfigPool = native.CIdPool[native.CCharacterPoseConfig](var_48_1)
	var_48_0.characterPosePool = native.CIdPool[native.CCharacterPose](var_48_1)
	var_48_0.controllerNamePool = native.CIdPool[native.CMoniker](var_48_1)
	var_48_0.controllerPool = native.CIdPool[native.CControllerHandle](var_48_1)
	var_48_0.defaultEmotionContextPool = native.CIdPool[native.CEmotionContext](var_48_1)
	var_48_0.defaultMotionProfilePool = native.CIdPool[native.CDefaultMotionProfile](var_48_1)
	var_48_0.desiredLeanPool = native.CIdPool[native.CDesiredLean](var_48_1)
	var_48_0.activeLeanPool = native.CIdPool[native.CActiveLean](var_48_1)
	var_48_0.movementFlowchartTypePool = native.CIdPool[native.CMovementFlowchartTypeInfo](var_48_1)
	var_48_0.preferredMotionProfilePool = native.CIdPool[native.CDefaultMotionProfile](var_48_1)
	var_48_0.derivedAttributesPool = native.CIdPool[native.CDerivedAttributes](var_48_1)
	var_48_0.emotionSequencerPool = native.CIdPool[native.CEmotionSequencer](var_48_1)
	var_48_0.flowchartConditionInstancePool = native.CIdPool[native.CFlowchartMask](var_48_1)
	var_48_0.flowchartPool = behaviours.flowchartPool
	var_48_0.torsoContactPool = native.CIdPool[native.CTorsoContact](var_48_1)
	var_48_0.footContactPool = native.CIdPool[native.CFootContact](var_48_1)
	var_48_0.frameKnowledge = native.CFrameKnowledge()
	var_48_0.gameobjectSelectedPool = native.CIdPool[native.CInt](var_48_1)
	var_48_0.gamerContextPool = native.CIdPool[native.CGamerContext](var_48_1)
	var_48_0.gearVisualPool = native.CIdPool[native.CGearVisual](var_48_1)
	var_48_0.secondaryGearVisualPool = native.CIdPool[native.CGearVisual](0)
	var_48_0.hitTargetAtTimeHistoryPool = not native.isRetail() and native.CIdPool[native.CHitTargetAtTimeHistory](var_48_1) or nil
	var_48_0.humanMovementInfoPool = native.CIdPool[native.CHumanMovementInfo](var_48_1)
	var_48_0.idleSelectionStartContextPool = native.CIdPool[native.CIdleSelectionStartContext](var_48_1)
	var_48_0.idleAwarenessPool = native.CIdPool[native.CIdleAwareness](var_48_1)
	var_48_0.idleCandidatesPool = native.CIdPool[native.CIdleCandidates](var_48_1)
	var_48_0.ikTargetInfoPool = native.CIdPool[native.CIKTargetInfo](var_48_1)
	var_48_0.impactDetectionNodeFetchPool = native.CIdPool[native.CImpactDetectionNodeFetch](var_48_1)
	var_48_0.impactDetectionStatePool = native.CIdPool[native.CImpactDetectionState](var_48_1)
	var_48_0.impactResultsPool = native.CIdPool[native.CImpactDetectionResults](var_48_1)
	var_48_0.inputState = native.CIdPool[native.CControllerState](var_48_1)
	var_48_0.lookAtMePosPool = native.CIdPool[native.vec3](var_48_1 + 1 + 2)
	var_48_0.lookAtTargetPool = native.CIdPool[native.CLookAtTarget](var_48_1)
	var_48_0.motionPathAvoidancePool = native.CIdPool[native.CMotionPathAvoidance](var_48_1)
	var_48_0.motionPathPool = native.CIdPool[native.CMotionPath](var_48_1)
	var_48_0.motionPathGenerationContextPool = native.CIdPool[native.CMotionPathGenerationContext](var_48_1)
	var_48_0.motionProfiles = movement_config.motionProfiles
	var_48_0.movementAttributesPool = native.CIdPool[native.CMovementAttributes](var_48_1)
	var_48_0.movementCommandContextPool = native.CIdPool[native.CMovementCommandContext](var_48_1)
	var_48_0.movementControllerPool = native.CIdPool[native.CMovementController](var_48_1)
	var_48_0.movementHistoryPool = native.CMovementHistory.createPool(var_48_1)
	var_48_0.moveTargetInfoPool = native.CIdPool[native.CMoveTargetInfo](var_48_1)
	var_48_0.naturalMovementInfoPool = native.CIdPool[native.CNaturalMovementTarget](var_48_1)
	var_48_0.obeySwitchingGracePeriodSet = native.CIdSet()
	var_48_0.obstaclePool = native.CIdPool[native.CObstacle](var_48_1)
	var_48_0.offsidePositionPool = native.CIdPool[native.vec2](var_48_2)
	var_48_0.playerAnimationPool = native.CIdPool[native.CPlayerAnimation](var_48_1)
	var_48_0.playerBmiPool = native.CIdPool[native.CFloat](var_48_2)
	var_48_0.playerBalancePool = native.CIdPool[native.CPlayerBalance](var_48_2)
	var_48_0.playerCollectSequenceKnowledgePool = native.CIdPool[native.CPlayerCollectSequenceKnowledge](var_48_2)
	var_48_0.playerCollisionHandlePool = native.CIdPool[native.CPlayerCollisionHandle](var_48_2)
	var_48_0.playerDegradationStatePool = native.CIdPool[native.CPlayerDegradationState](var_48_1)
	var_48_0.playerIdentityPool = native.CIdPool[native.CPlayerIdentity](var_48_2)
	var_48_0.playerMotionProfileKnowledgePool = native.CIdPool[native.CPlayerMotionProfileKnowledge](var_48_1)
	var_48_0.playerMarkerInfoPool = native.CIdPool[native.CPlayerMarkerInfo](var_48_2)
	var_48_0.playerSkillLevelPool = native.CIdPool[native.CPlayerSkillLevel](var_48_2)
	var_48_0.playerTintInfoPool = native.CIdPool[native.CPlayerTintInfo](var_48_2)
	var_48_0.positionInfoPool = native.CIdPool[native.CPositionInfo](var_48_1)
	var_48_0.predictedMotionPathPool = native.CIdPool[native.CMotionPath](var_48_1)
	var_48_0.predictedMotionPathGenerationContextPool = native.CIdPool[native.CMotionPathGenerationContext](var_48_1)
	var_48_0.predictedPosPool = native.CIdPool[native.vec2](var_48_1)
	var_48_0.preferCurrentSet = native.CIdSet()
	var_48_0.propCollisionPool = native.CIdPool[native.CPropCollision](var_48_4)
	var_48_0.propPositionInfoPool = native.CIdPool[native.CPositionInfo](var_48_4)
	var_48_0.propVelocityInfoPool = native.CIdPool[native.CVelocityInfo](var_48_4)
	var_48_0.reactToScorePool = native.CIdPool[native.CReactToScore](var_48_2)
	var_48_0.replayPlaybackDebug = native.CReplayPlaybackDebug()
	var_48_0.scalePool = native.CIdPool[native.CScaleInfo](var_48_1)
	var_48_0.selectedControllerFlowchartConditionInstancePool = native.CIdPool[native.CFlowchartMask](var_48_1)
	var_48_0.sidePool = native.CIdPool[native.CSide](var_48_1)
	var_48_0.skeletonModifierPool = native.CIdPool[native.CSkeletonModifier](var_48_1)
	var_48_0.skillsPool = native.CIdPool[native.CPlayerSkills](var_48_1)
	var_48_0.staminaInfoPool = native.CIdPool[native.CStaminaInfo](var_48_2)
	var_48_0.staminaInfoVisualPool = native.CIdPool[native.CStaminaInfo](var_48_2)
	var_48_0.stayInCurrentSet = native.CIdSet()
	var_48_0.transientEmotionContextPool = native.CIdPool[native.CEmotionContext](var_48_1)
	var_48_0.transientEmotionTimeoutPool = native.CIdPool[native.Time](var_48_1)
	var_48_0.triggeredEmotionContextPool = native.CIdPool[native.CEmotionContext](var_48_2)
	var_48_0.typePool = native.CIdPool[native.EGameObjectPoolType](var_48_5)
	var_48_0.umpireRegionPool = native.CIdPool[native.CInt](var_48_3)
	var_48_0.upperBodyBallContextPool = native.CIdPool[native.CUpperBodyContext](var_48_1)
	var_48_0.upperBodyBlendContextPool = native.CIdPool[native.CUpperBodyContext](var_48_1)
	var_48_0.upperBodyUpdateHistoryPool = native.CIdPool[native.CUpperBodyUpdateHistory](var_48_1)
	var_48_0.velocityInfoPool = native.CIdPool[native.CVelocityInfo](var_48_1)
	var_48_0.visualConfigPool = native.CIdPool[native.CVisualConfig](var_48_1)
	var_48_0.teamVisualConfigPool = native.CIdPool[native.CVisualConfig](var_48_1)

	arg_48_1:registerOnPreWipe(function()
		var_48_0.animationEmotionContextPool:clear()
	end)
	arg_48_1:registerOnPreWipe(function()
		native.CPoolOperations.clearTransientEmotions(var_48_0.transientEmotionContextPool, var_48_0.transientEmotionTimeoutPool)
	end)

	local function var_48_6(arg_51_0, arg_51_1)
		assert(not arg_51_0[arg_51_1])

		arg_51_0[arg_51_1] = {}

		return arg_51_0[arg_51_1]
	end

	local var_48_7 = native.CPoolWipeHandler

	arg_48_1:registerOnPreWipe(function(arg_52_0, arg_52_1, arg_52_2, arg_52_3, arg_52_4, arg_52_5, arg_52_6, arg_52_7, arg_52_8, arg_52_9, arg_52_10)
		local var_52_0 = arg_52_3.knowledgeBank

		ASSERT(arg_52_7.isSolid)
		var_48_7.wipeActionContextPool(arg_52_7:getActionContextPool(), arg_52_7)
		var_48_7.wipeActionNamePool(arg_52_7:getActionNamePool(), arg_52_7)
		var_48_7.wipeActionContextPool(arg_52_7:getBlendActionContextPool(), arg_52_7)
		var_48_7.wipeActionNamePool(arg_52_7:getBlendActionNamePool(), arg_52_7)
		var_48_7.wipePlayerCommittedCollectPool(arg_52_7:getPlayerCommittedCollectPool(), arg_52_7)
		var_48_7.wipeForceDirectedGraphControlPool(var_52_0.forceDirectedGraphControlPool, arg_52_7)
		var_48_7.wipePlayerAnimationPool(var_48_0.playerAnimationPool, arg_52_7)
		var_48_7.wipeIKTargetInfoPool(var_48_0.ikTargetInfoPool, arg_52_7)
		var_48_7.wipeAnimationSequencePool(var_48_0.animationSequencePool, arg_52_7)
		var_48_7.wipeAnimationSequenceDataPool(var_48_0.animationSequenceDataPool, arg_52_7)
		var_48_7.wipeAnimationSequencePool(var_48_0.blendAnimationSequencePool, arg_52_7)
		var_48_7.wipeAnimationSequenceDataPool(var_48_0.blendAnimationSequenceDataPool, arg_52_7)
		var_48_7.wipeIncapacitatedInfoPool(arg_52_7:getIncapacitatedInfoPool(), arg_52_7)
		var_48_7.wipeMovementPools(arg_52_7:getMovementCommandQueuePool(), arg_52_7:getBumpMovementCommandQueuePool(), VERIFY(var_48_0.movementControllerPool), VERIFY(var_48_0.movementCommandContextPool), VERIFY(var_48_0.motionPathPool), VERIFY(var_48_0.predictedMotionPathPool), VERIFY(var_48_0.motionPathGenerationContextPool), VERIFY(var_48_0.predictedMotionPathGenerationContextPool), VERIFY(var_48_0.playerAnimationPool), var_48_0.movementHistoryPool, VERIFY(var_48_0.positionInfoPool), VERIFY(var_48_0.velocityInfoPool), arg_52_7:getIdleSelectionContextPool(), arg_52_7:getIdleSequencePool(), VERIFY(var_48_0.idleSelectionStartContextPool), VERIFY(var_48_0.idleAwarenessPool), VERIFY(var_48_0.idleCandidatesPool), VERIFY(var_48_0.motionProfiles), VERIFY(var_48_0.defaultMotionProfilePool), VERIFY(var_48_0.movementAttributesPool), VERIFY(var_48_0.derivedAttributesPool), VERIFY(arg_52_3.animUnits.data), VERIFY(arg_52_3.motionSet.data), VERIFY(arg_52_3.bodyAnimationControllerSet), VERIFY(arg_52_3.idleService), arg_52_5, arg_52_9, arg_52_7)
	end)

	arg_48_0.pools = var_48_0

	return var_48_0
end

function Universe.initSolidState(arg_53_0, arg_53_1, arg_53_2)
	local var_53_0 = var_0_23
	local var_53_1 = var_0_18
	local var_53_2 = var_0_20
	local var_53_3 = arg_53_1:editSolidState()

	var_53_3:allocObject(native.CActionHistoryEntity, "actionHistoryEntity")
	var_53_3:allocObject(native.CActiveTackleEntity, "activeTackleEntity")
	var_53_3:allocObject(native.CAdvantageEntity, "advantageEntity")
	var_53_3:allocObject(native.CBallEntity, "ballEntity")
	var_53_3:allocObject(native.CCaptainsChallengeEntity, "captainsChallengeEntity")
	var_53_3:allocObject(native.CCollectEntity, "collectEntity")
	var_53_3:allocObject(native.CContestEntity, "contestEntity")
	var_53_3:allocObject(native.CCutsceneEntity, "cutsceneEntity")
	var_53_3:allocObject(native.CDebugEntity, "debugEntity")
	var_53_3:allocObject(native.CGamerSideEntity, "gamerSideEntity")
	var_53_3:allocObject(native.CHandOverEntity, "handOverEntity")
	var_53_3:allocObject(native.CInPlayKickEntity, "inPlayKickEntity")
	var_53_3:allocObject(native.CInTouchEntity, "inTouchEntity")
	var_53_3:allocObject(native.CJumpAvoidEntity, "jumpAvoidEntity")
	var_53_3:allocObject(native.CMatchProgressionEntity, "matchProgressionEntity")
	var_53_3:allocObject(native.CMatchTimeEntity, "matchTimeEntity")
	var_53_3:allocObject(native.CMovementCommandQueueConfig, "movementCommandQueueConfig")
	var_53_3:allocObject(native.COfficialEntity, "officialEntity")
	var_53_3:allocObject(native.CPassEntity, "passEntity")
	var_53_3:allocObject(native.CPenaltyEntity, "penaltyEntity")
	var_53_3:allocObject(native.CPhysicsEntity, "physicsEntity")
	var_53_3:allocObject(native.CPlaceKickEntity, "placeKickEntity")
	var_53_3:allocObject(native.CPlayTheBallEntity, "playTheBallEntity")
	var_53_3:allocObject(native.CRoleEntity, "roleEntity")
	var_53_3:allocObject(native.CScoreEntity, "scoreEntity")
	var_53_3:allocObject(native.CScrumEntity, "scrumEntity")
	var_53_3:allocObject(native.CServeEntity, "serveEntity")
	var_53_3:allocObject(native.CSidePair[native.CPlayEntity], "playEntityPair")
	var_53_3:allocObject(native.CSidePair[native.CPlayerPassCandidateEntity], "playerPassCandidateEntityPair")
	var_53_3:allocObject(native.CSidePair[native.CScootEntity], "scootEntityPair")
	var_53_3:allocObject(native.CSidePair[native.CSubstitutionEntity], "teamSubstitutionEntityPair")
	var_53_3:allocObject(native.CSidePair[native.CTeamFormationEntity], "teamFormationEntityPair")
	var_53_3:allocObject(native.CSidePair[native.CTeamOrdersEntity], "teamOrdersEntityPair")
	var_53_3:allocObject(native.CSidePair[native.CTeamTactics], "teamTacticsEntityPair")
	var_53_3:allocObject(native.CSoccerKickEntity, "soccerKickEntity")
	var_53_3:allocObject(native.CTackleDemoEntity, "tackleDemoEntity")
	var_53_3:allocObject(native.CTackleEntity, "tackleEntity")
	var_53_3:allocObject(native.CTapRestartEntity, "tapRestartEntity")
	var_53_3:allocObject(native.CTeamFormationEntity, "refereeFormationEntity")
	var_53_3:allocObject(native.CTimeElapsedEntity, "timeElapsedEntity")
	var_53_3:allocObject(native.CTrainingEntity, "trainingEntity")
	var_53_3:allocObject(native.CTryAttemptEntity, "tryAttemptEntity")
	var_53_3:allocObject(native.CTryDecisionPendingEntity, "tryDecisionPendingEntity")
	var_53_3:allocObject(native.CIdPool[native.CActionContext], "actionContextPool", var_53_0)
	var_53_3:allocObject(native.CIdPool[native.CActionContext], "blendActionContextPool", var_53_0)
	var_53_3:allocObject(native.CIdPool[native.CActionName], "actionNamePool", var_53_0)
	var_53_3:allocObject(native.CIdPool[native.CActionName], "blendActionNamePool", var_53_0)
	var_53_3:allocObject(native.CIdPool[native.CAuthorityInfo], "authorityInfoPool", var_53_0)
	var_53_3:allocObject(native.CIdPool[native.CBallPredictionOverrides], "ballPredictionOverridesPool", var_53_1)
	var_53_3:allocObject(native.CIdPool[native.CChargeDownInfo], "chargeDownInfoPool", var_53_1)
	var_53_3:allocObject(native.CIdPool[native.CGamerControlState], "gamerControlStatePool", var_53_1)
	var_53_3:allocObject(native.CIdPool[native.CGearInfo], "gearInfoPool", var_53_0)
	var_53_3:allocObject(native.CIdPool[native.CHoldTackleIntent], "holdTackleIntentPool", var_53_1)
	var_53_3:allocObject(native.CIdPool[native.CIdleSelectionContext], "idleSelectionContextPool", var_53_0)
	var_53_3:allocObject(native.CIdPool[native.CIdleSequence], "idleSequencePool", var_53_0)
	var_53_3:allocObject(native.CIdPool[native.CIncapacitatedInfo], "incapacitatedInfoPool", var_53_1)
	var_53_3:allocObject(native.CIdPool[native.CInjury], "injuryPool", var_53_1)
	var_53_3:allocObject(native.CIdPool[native.CMovementCommandQueue], "bumpMovementCommandQueuePool", var_53_0)
	var_53_3:allocObject(native.CIdPool[native.CMovementCommandQueue], "movementCommandQueuePool", var_53_0)
	var_53_3:allocObject(native.CIdPool[native.COffsideInfo], "offsideInfoPool", var_53_1)
	var_53_3:allocObject(native.CIdPool[native.CPassModification], "passModificationPool", var_53_1)
	var_53_3:allocObject(native.CIdPool[native.CPlayerCollectIntent], "playerCollectIntentPool", var_53_1)
	var_53_3:allocObject(native.CIdPool[native.CPlayerCommittedCollect], "playerCommittedCollectPool", var_53_1)
	var_53_3:allocObject(native.CIdPool[native.CPlayerCommittedMiss], "playerCommittedMissPool", var_53_1)
	var_53_3:allocObject(native.CIdPool[native.CPlayerContestIntent], "playerContestIntentPool", var_53_1)
	var_53_3:allocObject(native.CIdPool[native.CPushTackleIntent], "pushTackleIntentPool", var_53_1)
	var_53_3:allocObject(native.CIdPool[native.CRoleInfo], "roleInfoPool", var_53_0)
	var_53_3:allocObject(native.CIdPool[native.CSinBinInfo], "sinBinInfoPool", var_53_1)
	var_53_3:allocObject(native.CIdPool[native.CTackleIntent], "tackleIntentPool", var_53_1)
	var_53_3:allocObject(native.CIdPool[native.CTryInTackleIntent], "tryInTackleIntentPool", var_53_1)
	var_53_3:allocObject(native.CIdPool[native.CUpperBodyContext], "upperBodyBallContextPool", var_53_0)
	var_53_3:allocObject(native.CIdPool[native.CUpperBodyContext], "upperBodyBlendContextPool", var_53_0)
	var_53_3:allocObject(native.CGamerPausedEntity, "gamerPausedEntity")
	var_53_3:allocObject(native.CMatchType, "matchType")
	arg_53_1:resetTentativeState(var_53_3)
	arg_53_1:registerOnPreWipe(function(arg_54_0, arg_54_1, arg_54_2, arg_54_3, arg_54_4, arg_54_5, arg_54_6, arg_54_7, arg_54_8, arg_54_9, arg_54_10)
		arg_54_7:getTryAttemptEntity():onWipe()

		local var_54_0 = arg_54_7:getPlayEntityPair()

		for iter_54_0, iter_54_1 in ipairs(sidehelper.sides) do
			var_54_0:get(iter_54_1):reset()
		end
	end)
	var_53_3:getMatchType():set(arg_53_2.matchType)
end

function createUmpireTeamVisualConfig(arg_55_0)
	local var_55_0 = native.CVisualConfig("team")

	var_55_0:copy(arg_55_0)

	return var_55_0
end

-- headgear-team-colours: scanned heads whose fixed headgear colours are replaced
-- by the colours of the club they're playing for (base = primary, pattern =
-- secondary; trims keep the player's own colours). 233 = Kalyn Ponga, whose
-- stock headgear is hard-coded Queensland maroon.
local HeadgearTeamColourHeads = {
	[233] = true
}

local function applyHeadgearTeamColours(visualConfig, clubIdentity)
	if not clubIdentity or not HeadgearTeamColourHeads[visualConfig:getOption("head")] then
		return
	end

	local primary = clubIdentity.primaryRGBColour
	local secondary = clubIdentity.secondaryRGBColour

	-- Colour sliders are 0-1 (the colour pickers write vec components); CRGB is 0-255.
	visualConfig:setOption("headwearColour1_r", primary.r / 255)
	visualConfig:setOption("headwearColour1_g", primary.g / 255)
	visualConfig:setOption("headwearColour1_b", primary.b / 255)
	visualConfig:setOption("headwearColour2_r", secondary.r / 255)
	visualConfig:setOption("headwearColour2_g", secondary.g / 255)
	visualConfig:setOption("headwearColour2_b", secondary.b / 255)
end

function Universe.createProcesses(arg_56_0, arg_56_1, arg_56_2, arg_56_3, arg_56_4, arg_56_5, arg_56_6, arg_56_7, arg_56_8, arg_56_9)
	local var_56_0 = native.getEnvironment()
	local var_56_1 = arg_56_0.matchInData
	local var_56_2 = arg_56_0.matchOutData
	local var_56_3 = VERIFY(arg_56_0.characterAssetMap)
	local var_56_4 = arg_56_3.hooks
	local var_56_5 = VERIFY(arg_56_0.scene)
	local var_56_6 = VERIFY(arg_56_0.sceneRenderer)
	local var_56_7 = VERIFY(var_56_6.propScene)
	local var_56_8 = arg_56_1:getRenderInterface()
	local var_56_9 = arg_56_0.matchSim.gameobjects
	local var_56_10 = arg_56_1:getJobManager()
	local var_56_11 = {}
	local var_56_12 = native.CCricketIngameStreamingProcess(VERIFY(arg_56_0.characterManager), arg_56_1:getTextureCompositor(), arg_56_2.actorModelPool, arg_56_2.gearVisualPool, arg_56_2.visualConfigPool, arg_56_2.teamVisualConfigPool, arg_56_2.skeletonModifierPool)

	arg_56_3.ingameCharacterStreamingProcess = var_56_12
	var_56_11.substitutionProcess = native.CSubstitutionProcess()

	local var_56_13 = native.CDefendingPlayerOffsideProcess()

	var_56_13.sidePool = VERIFY(arg_56_2.sidePool)
	var_56_13.positionInfoPool = VERIFY(arg_56_2.positionInfoPool)
	var_56_13.scrumInfoPool = VERIFY(arg_56_4.playerScrumInfoPool)
	var_56_13.ballInfo = arg_56_4.ballInfo
	var_56_13.playTheBallConfig = arg_56_4.playTheBallConfig
	var_56_13.teamKnowledgePair = arg_56_4.teamKnowledgePair
	var_56_13.authoritySet = arg_56_2.authoritySet
	var_56_11.defendingPlayerOffsideProcess = var_56_13

	local var_56_14 = native.CAttackingPlayerOffsideProcess()

	var_56_14.sidePool = arg_56_2.sidePool
	var_56_14.positionInfoPool = arg_56_2.positionInfoPool
	var_56_14.ballInfo = arg_56_4.ballInfo
	var_56_14.teamKnowledgePair = arg_56_4.teamKnowledgePair
	var_56_14.authoritySet = arg_56_2.authoritySet
	var_56_11.attackingPlayerOffsideProcess = var_56_14

	local var_56_15 = native.CImpactDetectionProcess()

	var_56_15.impactDetectionFetchPool = VERIFY(arg_56_2.impactDetectionNodeFetchPool)
	var_56_15.impactResultsPool = VERIFY(arg_56_2.impactResultsPool)
	var_56_15.impactDetectionStatePool = VERIFY(arg_56_2.impactDetectionStatePool)
	var_56_15.actorModelPool = VERIFY(arg_56_2.actorModelPool)

	fieldimpact_helper.initProcess(var_56_15, arg_56_0.grassConfig)

	var_56_11.impactDetectionProcess = var_56_15

	table.insert(arg_56_0.sceneDisposalQueue, function()
		local var_57_0 = arg_56_0.processes

		if var_57_0.impactDetectionProcess then
			var_57_0.impactDetectionProcess:dispose()

			var_57_0.impactDetectionProcess = nil
		end
	end)

	local var_56_16 = native.CPlayerDegradationTransferProcess()

	var_56_16.impactResultsPool = VERIFY(arg_56_2.impactResultsPool)
	var_56_16.degradationState = VERIFY(arg_56_2.playerDegradationStatePool)
	var_56_16.actorModelPool = VERIFY(arg_56_2.actorModelPool)

	playerdegradation_helper.initProcess(var_56_16, arg_56_0.grassConfig)

	var_56_11.playerDegradationTransferProcess = var_56_16

	local var_56_17 = native.CUpdateTacklePreferenceListProcess()

	var_56_17.tacklePreferenceList = arg_56_0.tacklePreferenceList
	var_56_11.updateTacklePreferenceListProcess = var_56_17

	local var_56_18 = native.CUpdatePlaysPreferenceListProcess()

	var_56_18.playsPreferenceList = arg_56_0.playsPreferenceList
	var_56_11.updatePlaysPreferenceListProcess = var_56_18

	arg_56_6:registerSolidEventListener(function(arg_58_0)
		if arg_58_0.disposalType == native.EDisposalType.Kick and arg_58_0.disposalSubType ~= native.EDisposalSubType.PlayTheBall then
			var_56_14:flagOffsidePlayers()
		end
	end, "DisposalEvent")
	arg_56_6:registerSolidEventListener(function(arg_59_0)
		var_56_14:flagOffsidePlayers()
	end, "KnockOnOccurredEvent")
	arg_56_6:registerSolidEventListener(function(arg_60_0)
		var_56_14:flagOffsidePlayers()
	end, "ContestedTapEvent")

	local var_56_19 = arg_56_5:getHome()
	local var_56_20 = arg_56_5:getAway()
	local var_56_21 = {
		var_56_19:getIdentity(),
		var_56_20:getIdentity()
	}

	for iter_56_0, iter_56_1 in var_56_9:objects(playertype.TypeId) do
		local var_56_22 = iter_56_1.identity
		local var_56_23 = iter_56_1.team
		local var_56_24 = var_56_23:getAssetId(iter_56_1.id)
		local var_56_25 = var_56_23:getJerseyNumberFromAssetId(var_56_24)

		native.PlayerVisualUtils.fillPlayerVisualConfig(iter_56_1.visualConfig, var_56_22, var_56_25)
		native.PlayerVisualUtils.fillClubVisualConfig(iter_56_1.teamVisualConfig, var_56_21[iter_56_1.side])
		applyHeadgearTeamColours(iter_56_1.visualConfig, var_56_21[iter_56_1.side])
	end

	for iter_56_2, iter_56_3 in var_56_9:objects(umpiretype.TypeId) do
		local var_56_26 = iter_56_3.identity

		native.PlayerVisualUtils.fillRefereeVisualConfig(iter_56_3.visualConfig, var_56_26)
		native.PlayerVisualUtils.fillRefereeTeamVisualConfig(iter_56_3.teamVisualConfig, var_56_26)
	end

	var_56_11.ingameCharacterStreamingProcess = var_56_12

	local var_56_27 = var_56_4 and var_56_4:getHook("CharacterVisualDebugHook")

	if var_56_27 then
		var_56_27:setStreamingProcess(VERIFY(var_56_12))
		var_56_27:setActorModelPool(VERIFY(arg_56_2.actorModelPool))
		var_56_27:setAnimationSet(VERIFY(arg_56_0.animationSets.animationSet))
		var_56_27:setJointScalingTable(VERIFY(jointscalingconfig.ScalingClass))
		var_56_27:setCharacterManager(VERIFY(arg_56_0.characterManager))
	end

	local var_56_28 = native.CAuthoritySetProcess()

	var_56_28.authoritySet = arg_56_2.authoritySet
	var_56_11.authoritySetProcess = var_56_28

	local var_56_29 = native.CFlowchartConditionInstanceMergeProcess()

	var_56_29.flowchartConditionInstancePool = arg_56_2.flowchartConditionInstancePool
	var_56_29.playerFlowchartConditionInstancePool = arg_56_4.playerFlowchartConditionInstancePool
	var_56_29.NPCFlowchartConditionInstancePool = arg_56_4.NPCFlowchartConditionInstancePool
	var_56_11.flowchartConditionInstanceMergeProcess = var_56_29

	local var_56_30 = native.CGamerContextProcess()

	var_56_30.switchingGracePeriod = player_config.switchingGracePeriod
	var_56_30.gamers = arg_56_7
	var_56_30.gamerContextPool = arg_56_2.gamerContextPool

	arg_56_6:registerOnPostWipe(function(arg_61_0, arg_61_1, arg_61_2, arg_61_3, arg_61_4, arg_61_5, arg_61_6, arg_61_7, arg_61_8, arg_61_9, arg_61_10)
		var_56_30.timeOfLastWipe = arg_61_9
	end)

	var_56_11.gamerContextProcess = var_56_30

	local var_56_31 = native.CPlayerSwitching()

	var_56_31:init()

	var_56_31.positionInfoPool = arg_56_2.positionInfoPool
	var_56_31.sidePool = arg_56_2.sidePool
	var_56_31.ballInfo = arg_56_4.ballInfo
	var_56_31.boundaryConfig = rulesenvironment_cconfig.cBoundaryConfig
	var_56_31.offsideInfoPool = arg_56_4.offsideInfoPool
	var_56_31.gameobjectSelectedPool = arg_56_2.gameobjectSelectedPool
	var_56_31.incapacitatedInfoPool = arg_56_8:getIncapacitatedInfoPool()
	var_56_31.playerInterceptionKnowledgePool = arg_56_4.playerInterceptionKnowledgePool
	var_56_31.inPlayInfoPool = arg_56_4.inPlayInfoPool
	var_56_31.playerDummyHalfKnowledgePool = arg_56_4.playerDummyHalfKnowledgePool
	var_56_31.playerActiveTackleKnowledgePool = arg_56_4.playerActiveTackleKnowledgePool
	var_56_31.sidePool = arg_56_2.sidePool
	var_56_31.teamBallKnowledgePair = arg_56_4.teamBallKnowledgePair

	local var_56_32 = arg_56_5:getSide(sidehelper.home)
	local var_56_33 = arg_56_5:getSide(sidehelper.away)

	var_56_31:setTeamLineup(0, var_56_32.matchClub.lineup)
	var_56_31:setTeamLineup(1, var_56_33.matchClub.lineup)

	var_56_31.playerSwitchingConfig = playerswitching_cconfig.cPlayerSwitchingConfig

	if var_56_1:isBeAProMode() then
		local var_56_34 = control_helper.getProPlayerObjectId(arg_56_5)

		var_56_31:setCareerPlayerId(var_56_34)
	end

	arg_56_0.playerSwitching = var_56_31
	var_56_11.playerSwitchingProcess = var_56_31
	arg_56_3.playerSwitchingProcess = var_56_31

	local var_56_35 = native.CStaminaProcess()

	var_56_35.scaleInfoPool = VERIFY(arg_56_2.scalePool)
	var_56_35.motionPathPool = VERIFY(arg_56_2.motionPathPool)
	var_56_35.positionInfoPool = VERIFY(arg_56_2.positionInfoPool)
	var_56_35.velocityInfoPool = VERIFY(arg_56_2.velocityInfoPool)
	var_56_35.derivedAttributesPool = VERIFY(arg_56_4.derivedAttributesPool)
	var_56_35.staminaInfoVisualPool = VERIFY(arg_56_2.staminaInfoVisualPool)
	var_56_35.staminaInfoPool = VERIFY(arg_56_2.staminaInfoPool)
	var_56_35.teamKnowledgePair = VERIFY(arg_56_4.teamKnowledgePair)

	var_56_35:setConfig(stamina_config.sprintChargeConfig)

	arg_56_0.onReloadPlayerStaminaConfig = package.registerOnReload(function()
		var_56_35:setConfig(stamina_config.sprintChargeConfig)
	end)
	var_56_11.staminaProcess = var_56_35

	local var_56_36 = native.CPlayerBalanceProcess()

	var_56_36:setDifficultyConfig(playerbalance_config.RegenDifficultyModifiers)

	var_56_36.playerBalancePool = VERIFY(arg_56_2.playerBalancePool)
	arg_56_0.onReloadPlayerBalanceConfig = package.registerOnReload(function()
		var_56_36:setDifficultyConfig(playerbalance_config.RegenDifficultyModifiers)
	end)
	var_56_11.playerBalanceProcess = var_56_36

	local var_56_37 = native.CPopulateFlowchartFlagsProcess()

	var_56_37.flowchartConditionInstancePool = arg_56_2.flowchartConditionInstancePool
	var_56_37.gamerContextPool = arg_56_2.gamerContextPool
	var_56_37.stayInCurrentSet = arg_56_2.stayInCurrentSet
	var_56_37.preferCurrentSet = arg_56_2.preferCurrentSet
	var_56_37.obeySwitchingGracePeriodSet = arg_56_2.obeySwitchingGracePeriodSet
	var_56_37.config = evaluate_cconfig.cPlayerFlowchartConfig
	var_56_11.populateFlowchartFlagsProcess = var_56_37

	local var_56_38 = native.CPopulateFlowchartFlagsProcess()

	var_56_38.flowchartConditionInstancePool = arg_56_2.flowchartConditionInstancePool
	var_56_38.gamerContextPool = arg_56_2.gamerContextPool
	var_56_38.stayInCurrentSet = arg_56_2.blendStayInCurrentSet
	var_56_38.preferCurrentSet = arg_56_2.blendPreferCurrentSet
	var_56_38.obeySwitchingGracePeriodSet = arg_56_2.obeySwitchingGracePeriodSet
	var_56_38.config = evaluate_cconfig.cPlayerFlowchartConfig
	var_56_11.blendPopulateFlowchartFlagsProcess = var_56_38

	local var_56_39 = native.CBehaviourTableSelectProcess()

	var_56_39.umpireTable = behaviours.Umpire
	var_56_39.humanTable = behaviours.Human
	var_56_39.aiTable = behaviours.Ai
	var_56_39.gamerContextPool = arg_56_2.gamerContextPool
	var_56_39.behaviourTableHandlePool = arg_56_2.behaviourTableHandlePool
	var_56_39.aiOnly = var_56_0:argExists("aionly")
	var_56_11.behaviourTableSelectProcess = var_56_39

	local var_56_40 = native.CBehaviourTableSelectProcess()

	var_56_40.umpireTable = behaviours.UmpireUpperBody
	var_56_40.humanTable = behaviours.HumanUpperBody
	var_56_40.aiTable = behaviours.AiUpperBody
	var_56_40.gamerContextPool = arg_56_2.gamerContextPool
	var_56_40.behaviourTableHandlePool = arg_56_2.blendBehaviourTableHandlePool
	var_56_40.aiOnly = var_56_0:argExists("aionly")
	var_56_11.blendBehaviourTableSelectProcess = var_56_40
	var_56_11.controllerSelectProcess = native.CControllerSelectProcess(arg_56_8, arg_56_2.behaviourTableHandlePool, arg_56_2.flowchartConditionInstancePool, arg_56_2.behaviourNamePool, arg_56_2.behaviourTablePool, arg_56_2.flowchartPool, arg_56_2.controllerNamePool)
	var_56_11.blendControllerSelectProcess = native.CControllerSelectProcess(arg_56_8, arg_56_2.blendBehaviourTableHandlePool, arg_56_2.flowchartConditionInstancePool, arg_56_2.behaviourNamePool, arg_56_2.behaviourTablePool, arg_56_2.flowchartPool, arg_56_2.blendControllerNamePool)
	arg_56_0.forceReenterControllers = false

	arg_56_6:registerOnPreWipe(function(arg_64_0, arg_64_1, arg_64_2, arg_64_3, arg_64_4, arg_64_5, arg_64_6, arg_64_7, arg_64_8, arg_64_9, arg_64_10)
		arg_56_0.forceReenterControllers = true
	end)

	local var_56_41 = var_56_4 and var_56_4:getHook("ControllerHistoryDebugHook")
	local var_56_42 = var_56_4 and var_56_4:getHook("BlendControllerHistoryDebugHook")
	local var_56_43 = native.CControllerUpdateProcess()

	var_56_43.controllerNamePool = arg_56_2.controllerNamePool
	var_56_43.gamerContextPool = arg_56_2.gamerContextPool
	var_56_43.controllerPool = arg_56_2.controllerPool
	var_56_43.authoritySet = arg_56_2.authoritySet
	var_56_43.stayInCurrentSet = arg_56_2.stayInCurrentSet
	var_56_43.preferCurrentSet = arg_56_2.preferCurrentSet
	var_56_43.obeySwitchingGracePeriodSet = arg_56_2.obeySwitchingGracePeriodSet
	var_56_43.onControllerChange = var_56_41 and function(arg_65_0, arg_65_1, arg_65_2)
		var_56_41:onChange(arg_65_0, arg_65_1, arg_65_2)
	end
	var_56_11.controllerUpdateProcess = var_56_43

	local var_56_44 = native.CControllerUpdateProcess()

	var_56_44.controllerNamePool = arg_56_2.blendControllerNamePool
	var_56_44.gamerContextPool = arg_56_2.gamerContextPool
	var_56_44.controllerPool = arg_56_2.blendControllerPool
	var_56_44.authoritySet = arg_56_2.authoritySet
	var_56_44.stayInCurrentSet = arg_56_2.blendStayInCurrentSet
	var_56_44.preferCurrentSet = arg_56_2.blendPreferCurrentSet
	var_56_44.obeySwitchingGracePeriodSet = arg_56_2.obeySwitchingGracePeriodSet
	var_56_44.onControllerChange = var_56_42 and function(arg_66_0, arg_66_1, arg_66_2)
		var_56_42:onChange(arg_66_0, arg_66_1, arg_66_2)
	end
	var_56_11.blendControllerUpdateProcess = var_56_44

	local var_56_45 = native.CActionCallbackProcess()

	var_56_45.playerAnimationPool = arg_56_2.playerAnimationPool
	var_56_45.actionCallbacksPool = arg_56_2.actionCallbacksPool
	var_56_45.actionCallbackStatePool = arg_56_2.actionCallbackStatePool
	var_56_45.animationSequencePool = arg_56_2.animationSequencePool
	var_56_45.actionContextPoolName = "actionContextPool"
	var_56_11.actionCallbackProcess = var_56_45

	local var_56_46 = native.CActionCallbackProcess()

	var_56_46.playerAnimationPool = arg_56_2.playerAnimationPool
	var_56_46.actionCallbacksPool = arg_56_2.blendActionCallbacksPool
	var_56_46.actionCallbackStatePool = arg_56_2.blendActionCallbackStatePool
	var_56_46.animationSequencePool = arg_56_2.blendAnimationSequencePool
	var_56_46.actionContextPoolName = "blendActionContextPool"
	var_56_11.blendActionCallbackProcess = var_56_46

	local var_56_47 = native.CActionCallbackSelectionProcess(native.CActionCallbacks.getAnimateQueueIndex())

	var_56_47.playerAnimationPool = arg_56_2.playerAnimationPool
	var_56_47.actionCallbacksPool = arg_56_2.actionCallbacksPool
	var_56_47.actionCallbackStatePool = arg_56_2.actionCallbackStatePool
	var_56_47.actionCallbackHandlePool = arg_56_2.actionCallbackAnimatePool
	var_56_11.actionCallbackBodyCommandSelectionProcess = var_56_47

	local var_56_48 = native.CActionCallbackBodyCommandExecutionProcess()

	var_56_48.actionCallbackFunctionHandlePool = arg_56_2.actionCallbackAnimatePool
	var_56_48.playerAnimationPool = arg_56_2.playerAnimationPool
	var_56_11.actionCallbackBodyCommandExecutionProcess = var_56_48

	local var_56_49 = native.CActionCallbackSelectionProcess(native.CActionCallbacks.getAnimateQueueIndex())

	var_56_49.playerAnimationPool = arg_56_2.playerAnimationPool
	var_56_49.actionCallbacksPool = arg_56_2.blendActionCallbacksPool
	var_56_49.actionCallbackStatePool = arg_56_2.blendActionCallbackStatePool
	var_56_49.actionCallbackHandlePool = arg_56_2.actionCallbackAnimateBlendPool
	var_56_11.actionCallbackBlendCommandSelectionProcess = var_56_49

	local var_56_50 = native.CActionCallbackBlendCommandExecutionProcess()

	var_56_50.actionCallbackFunctionHandlePool = arg_56_2.actionCallbackAnimateBlendPool
	var_56_50.playerAnimationPool = arg_56_2.playerAnimationPool
	var_56_11.actionCallbackBlendCommandExecutionProcess = var_56_50

	local var_56_51 = native.CActionCallbackSelectionProcess(native.CActionCallbacks.getEventQueueIndex())

	var_56_51.playerAnimationPool = arg_56_2.playerAnimationPool
	var_56_51.actionCallbacksPool = arg_56_2.actionCallbacksPool
	var_56_51.actionCallbackStatePool = arg_56_2.actionCallbackStatePool
	var_56_51.actionCallbackHandlePool = arg_56_2.actionCallbackEventPool
	var_56_11.actionCallbackEventSelectionProcess = var_56_51

	local var_56_52 = native.CActionCallbackEventExecutionProcess()

	var_56_52.actionCallbackFunctionHandlePool = arg_56_2.actionCallbackEventPool
	var_56_52.authoritySet = arg_56_2.authoritySet
	var_56_11.actionCallbackEventExecutionProcess = var_56_52

	local var_56_53 = native.CActionCallbackSelectionProcess(native.CActionCallbacks.getEventQueueIndex())

	var_56_53.playerAnimationPool = arg_56_2.playerAnimationPool
	var_56_53.actionCallbacksPool = arg_56_2.blendActionCallbacksPool
	var_56_53.actionCallbackStatePool = arg_56_2.blendActionCallbackStatePool
	var_56_53.actionCallbackHandlePool = arg_56_2.actionCallbackBlendEventPool
	var_56_11.blendActionCallbackEventSelectionProcess = var_56_53

	local var_56_54 = native.CActionCallbackEventExecutionProcess()

	var_56_54.actionCallbackFunctionHandlePool = arg_56_2.actionCallbackBlendEventPool
	var_56_54.authoritySet = arg_56_2.authoritySet
	var_56_11.blendActionCallbackEventExecutionProcess = var_56_54

	local var_56_55 = native.CAnimationSequenceProcess()

	var_56_55.animationSequencePool = arg_56_2.animationSequencePool
	var_56_55.animationSequenceDataPool = arg_56_2.animationSequenceDataPool
	var_56_55.playerAnimationPool = arg_56_2.playerAnimationPool
	var_56_55.actionContextPoolName = "actionContextPool"
	var_56_11.animationSequenceProcess = var_56_55

	local var_56_56 = native.CAnimationSequenceProcess()

	var_56_56.animationSequencePool = arg_56_2.blendAnimationSequencePool
	var_56_56.animationSequenceDataPool = arg_56_2.blendAnimationSequenceDataPool
	var_56_56.actionContextPoolName = "blendActionContextPool"
	var_56_11.blendAnimationSequenceProcess = var_56_56

	local var_56_57 = native.CMovementFlowchartTypeSelectProcess()

	var_56_57.movementFlowchartTypePool = VERIFY(arg_56_2.movementFlowchartTypePool)
	var_56_11.movementFlowchartTypeSelectProcess = var_56_57

	local var_56_58 = native.CMotionProfileSelectProcess()

	var_56_58.motionProfileFlowchartList = VERIFY(motionprofileflowchart.flowchartList)
	var_56_58.flowchartConditionInstancePool = VERIFY(arg_56_2.flowchartConditionInstancePool)
	var_56_58.movementFlowchartTypePool = VERIFY(arg_56_2.movementFlowchartTypePool)
	var_56_58.preferredMotionProfilePool = VERIFY(arg_56_2.preferredMotionProfilePool)
	var_56_58.motionProfiles = VERIFY(arg_56_2.motionProfiles)
	var_56_11.preferredMotionProfileSelectProcess = var_56_58

	local var_56_59 = native.CNaturalMovementProfileSelectionProcess()

	var_56_59.naturalMovementFlowchartList = VERIFY(naturalmovementflowchart.flowchartList)
	var_56_59.flowchartConditionInstancePool = VERIFY(arg_56_2.flowchartConditionInstancePool)
	var_56_59.movementFlowchartTypePool = VERIFY(arg_56_2.movementFlowchartTypePool)
	var_56_59.naturalMovementInfoPool = VERIFY(arg_56_2.naturalMovementInfoPool)
	var_56_11.naturalMovementProfileSelectionProcess = var_56_59

	local var_56_60 = native.CLookAtConfigSelectProcess()

	var_56_60.lookAtConfigFlowchartList = VERIFY(lookatconfigflowchart.flowchartList)
	var_56_60.flowchartConditionInstancePool = VERIFY(arg_56_2.flowchartConditionInstancePool)
	var_56_60.movementFlowchartTypePool = VERIFY(arg_56_2.movementFlowchartTypePool)
	var_56_60.lookAtTargetPool = VERIFY(arg_56_2.lookAtTargetPool)
	var_56_60.lookAtConfigDict = VERIFY(arg_56_3.headLookAtConfigDict)
	var_56_11.lookAtConfigSelectProcess = var_56_60

	local var_56_61 = native.CCollisionBumpSelectProcess()

	var_56_61.collisionBumpFlowchartList = VERIFY(collisionbumpflowchart.flowchartList)
	var_56_61.flowchartConditionInstancePool = VERIFY(arg_56_2.flowchartConditionInstancePool)
	var_56_61.movementFlowchartTypePool = VERIFY(arg_56_2.movementFlowchartTypePool)
	var_56_61.obstaclePool = VERIFY(arg_56_2.obstaclePool)
	var_56_11.collisionBumpSelectProcess = var_56_61

	local var_56_62 = native.CIdleSelectionProcess()

	var_56_62.idleSelectionStartContextPool = VERIFY(arg_56_2.idleSelectionStartContextPool)
	var_56_62.idleAwarenessPool = VERIFY(arg_56_2.idleAwarenessPool)
	var_56_62.idleCandidatesPool = VERIFY(arg_56_2.idleCandidatesPool)
	var_56_62.motionPathPool = VERIFY(arg_56_2.motionPathPool)
	var_56_62.idleService = VERIFY(arg_56_3.idleService)
	var_56_11.idleSelectionProcess = var_56_62

	local var_56_63 = native.CMovementControllerUpdateProcess()

	var_56_63.predictedPosPool = arg_56_2.predictedPosPool
	var_56_63.positionInfoPool = arg_56_2.positionInfoPool
	var_56_63.velocityInfoPool = arg_56_2.velocityInfoPool
	var_56_63.scaleInfoPool = arg_56_2.scalePool
	var_56_63.footContactPool = VERIFY(arg_56_2.footContactPool)
	var_56_63.moveTargetInfoPool = arg_56_2.moveTargetInfoPool
	var_56_63.obstaclePool = arg_56_2.obstaclePool
	var_56_63.attachmentInfoPool = arg_56_2.attachmentInfoPool
	var_56_63.movementCommandContextPool = arg_56_2.movementCommandContextPool
	var_56_63.motionPathPool = VERIFY(arg_56_2.motionPathPool)
	var_56_63.predictedMotionPathPool = VERIFY(arg_56_2.predictedMotionPathPool)
	var_56_63.motionPathGenerationContextPool = VERIFY(arg_56_2.motionPathGenerationContextPool)
	var_56_63.predictedMotionPathGenerationContextPool = VERIFY(arg_56_2.predictedMotionPathGenerationContextPool)
	var_56_63.desiredLeanPool = VERIFY(arg_56_2.desiredLeanPool)
	var_56_63.motionProfiles = VERIFY(arg_56_2.motionProfiles)
	var_56_63.bodyAnimationControllerSet = VERIFY(arg_56_3.bodyAnimationControllerSet)
	var_56_63.idleService = VERIFY(arg_56_3.idleService)
	var_56_63.playerAnimationPool = VERIFY(arg_56_2.playerAnimationPool)
	var_56_63.movementAttributesPool = VERIFY(arg_56_2.movementAttributesPool)
	var_56_63.derivedAttributesPool = VERIFY(arg_56_2.derivedAttributesPool)
	var_56_63.animationSequencePool = VERIFY(arg_56_2.animationSequencePool)
	var_56_63.motionPathAvoidancePool = VERIFY(arg_56_2.motionPathAvoidancePool)
	var_56_63.defaultMotionProfilePool = arg_56_2.preferredMotionProfilePool
	var_56_63.movementHistoryPool = arg_56_2.movementHistoryPool
	var_56_63.hitTargetAtTimeHistoryPool = arg_56_2.hitTargetAtTimeHistoryPool
	var_56_63.onlineMultiplayer = var_56_1.onlineMultiplayer
	var_56_63.activeIds = arg_56_3.activeHumanoidIdList
	var_56_11.movementControllerUpdateProcess = var_56_63

	local var_56_64 = native.CActiveLeanProcess()

	var_56_64.desiredLeanPool = arg_56_2.desiredLeanPool
	var_56_64.positionInfoPool = arg_56_2.positionInfoPool
	var_56_64.velocityInfoPool = arg_56_2.velocityInfoPool
	var_56_64.motionProfiles = arg_56_2.motionProfiles
	var_56_64.playerAnimationPool = arg_56_2.playerAnimationPool
	var_56_64.motionPathPool = arg_56_2.motionPathPool
	var_56_64.activeLeanPool = arg_56_2.activeLeanPool
	var_56_64.derivedAttributesPool = arg_56_2.derivedAttributesPool
	var_56_11.activeLeanProcess = var_56_64

	local var_56_65 = native.CUpperBodyUpdateProcess()

	var_56_65.playerAnimationPool = VERIFY(arg_56_2.playerAnimationPool)
	var_56_65.animationSequencePool = VERIFY(arg_56_2.blendAnimationSequencePool)
	var_56_65.animationSequenceDataPool = VERIFY(arg_56_2.blendAnimationSequenceDataPool)
	var_56_65.attachmentInfoPool = VERIFY(arg_56_2.attachmentInfoPool)
	var_56_65.positionInfoPool = VERIFY(arg_56_2.positionInfoPool)
	var_56_65.velocityInfoPool = VERIFY(arg_56_2.velocityInfoPool)
	var_56_65.derivedAttributesPool = VERIFY(arg_56_2.derivedAttributesPool)
	var_56_65.upperBodyUpdateHistoryPool = VERIFY(arg_56_2.upperBodyUpdateHistoryPool)
	var_56_65.desiredUpperBodyBlendContextPool = VERIFY(arg_56_4.desiredUpperBodyBlendContextPool)
	var_56_65.upperBodyBlendContextPool = VERIFY(arg_56_2.upperBodyBlendContextPool)
	var_56_65.desiredUpperBodyBallContextPool = VERIFY(arg_56_4.desiredUpperBodyBallContextPool)
	var_56_65.upperBodyBallContextPool = VERIFY(arg_56_2.upperBodyBallContextPool)
	var_56_65.upperBodyContextConfig = VERIFY(var_0_9)
	var_56_65.playerIdentityPool = VERIFY(arg_56_2.playerIdentityPool)
	var_56_11.upperBodyUpdateProcess = var_56_65

	local var_56_66 = native.CPlayerAnimationProcess()

	var_56_66.playerAnimationPool = arg_56_2.playerAnimationPool
	var_56_66.positionInfoPool = VERIFY(arg_56_2.positionInfoPool)
	var_56_66.velocityInfoPool = VERIFY(arg_56_2.velocityInfoPool)
	var_56_66.ikTargetInfoPool = VERIFY(arg_56_2.ikTargetInfoPool)
	var_56_66.attachmentInfoPool = VERIFY(arg_56_2.attachmentInfoPool)
	var_56_66.animationEmotionContextPool = VERIFY(arg_56_2.animationEmotionContextPool)
	var_56_66.emotionService = VERIFY(arg_56_3.emotionService)
	var_56_66.playerAnimationPool = VERIFY(arg_56_2.playerAnimationPool)
	var_56_66.motionPathPool = VERIFY(arg_56_2.motionPathPool)
	var_56_66.predictedMotionPathPool = VERIFY(arg_56_2.predictedMotionPathPool)
	var_56_66.movementCommandContextPool = VERIFY(arg_56_2.movementCommandContextPool)
	var_56_66.skeletonModifierPool = VERIFY(arg_56_2.skeletonModifierPool)
	var_56_11.playerAnimationProcess = var_56_66

	local var_56_67 = native.CIKTargetInfoUpdateProcess(var_0_23)

	var_56_67.playerAnimationPool = arg_56_2.playerAnimationPool
	var_56_67.motionPathPool = arg_56_2.motionPathPool
	var_56_67.motionProfiles = arg_56_2.motionProfiles
	var_56_67.bodyAnimationControllerSet = VERIFY(arg_56_3.bodyAnimationControllerSet)
	var_56_67.scaleInfoPool = arg_56_2.scalePool
	var_56_67.attachmentInfoPool = arg_56_2.attachmentInfoPool
	var_56_67.lookAtTargetPool = VERIFY(arg_56_2.lookAtTargetPool)
	var_56_67.headLookAtConfigDict = VERIFY(arg_56_3.headLookAtConfigDict)
	var_56_67.ikTargetInfoPool = arg_56_2.ikTargetInfoPool
	var_56_11.ikTargetInfoUpdateProcess = var_56_67

	local var_56_68 = native.CTorsoContactUpdateProcess()

	var_56_68.actorModelPool = VERIFY(arg_56_2.actorModelPool)
	var_56_68.torsoContactPool = VERIFY(arg_56_2.torsoContactPool)
	var_56_11.torsoContactUpdateProcess = var_56_68

	local var_56_69 = native.CFootContactUpdateProcess()

	var_56_69.actorModelPool = VERIFY(arg_56_2.actorModelPool)
	var_56_69.footContactPool = VERIFY(arg_56_2.footContactPool)
	var_56_11.footContactUpdateProcess = var_56_69

	local var_56_70 = native.CPlayerPropertyCacheProcess()

	var_56_70.positionInfoPool = arg_56_2.positionInfoPool
	var_56_70.velocityInfoPool = arg_56_2.velocityInfoPool
	var_56_11.playerPropertyCacheProcess = var_56_70

	arg_56_6:registerOnPreWipe(function(arg_67_0, arg_67_1, arg_67_2, arg_67_3, arg_67_4, arg_67_5, arg_67_6, arg_67_7, arg_67_8, arg_67_9, arg_67_10)
		var_56_70:clear(arg_56_0.humanoidIdList, arg_67_8)
		var_56_64:onWipe()
	end)

	arg_56_0.activeLeanProcessReload = package.registerOnReload(function()
		var_56_64:onWipe()
	end)

	local var_56_71 = native.CEmotionUpdateProcess()

	var_56_11.emotionUpdateProcess = var_56_71

	local var_56_72 = native.CEmotionTimeoutProcess()

	var_56_72.transientEmotionContextPool = arg_56_2.transientEmotionContextPool
	var_56_72.transientEmotionTimeoutPool = arg_56_2.transientEmotionTimeoutPool
	var_56_11.transientEmotionTimeoutProcess = var_56_72

	local var_56_73 = native.CEmotionSelectProcess(arg_56_3.emotionService)

	var_56_73.emotionSequencerPool = arg_56_2.emotionSequencerPool

	var_56_73:addEmotionContextPool(arg_56_2.animationEmotionContextPool)
	var_56_73:addEmotionContextPool(arg_56_2.transientEmotionContextPool)
	var_56_73:addEmotionContextPool(arg_56_2.triggeredEmotionContextPool)
	var_56_73:addEmotionContextPool(arg_56_2.defaultEmotionContextPool)

	var_56_11.emotionSelectProcess = var_56_73

	local var_56_74 = native.CEmotionAnimateProcess()

	var_56_74.blendTime = emotionservice.emotionBlendTime
	var_56_74.emotionSequencerPool = arg_56_2.emotionSequencerPool
	var_56_74.emotionService = arg_56_3.emotionService
	var_56_74.playerAnimationPool = arg_56_2.playerAnimationPool
	var_56_11.emotionAnimateProcess = var_56_74

	local var_56_75 = native.CActorTransformUpdateProcess()

	var_56_75.positionInfoPool = VERIFY(arg_56_2.positionInfoPool)
	var_56_75.actorTransformPool = VERIFY(arg_56_2.actorTransformPool)
	var_56_75.scaleInfoPool = VERIFY(arg_56_2.scalePool)
	var_56_11.actorTransformUpdateProcess = var_56_75

	local var_56_76 = native.CSkeletonModifierUpdateProcess()

	var_56_76.skeletonModifierPool = VERIFY(arg_56_2.skeletonModifierPool)
	var_56_76.lookAtTargetPool = VERIFY(arg_56_2.lookAtTargetPool)
	var_56_76.ikTargetInfoPool = VERIFY(arg_56_2.ikTargetInfoPool)
	var_56_76.velocityInfoPool = VERIFY(arg_56_2.velocityInfoPool)
	var_56_76.playerAnimationPool = VERIFY(arg_56_2.playerAnimationPool)
	var_56_76.motionProfiles = VERIFY(arg_56_2.motionProfiles)
	var_56_11.skeletonModifierUpdateProcess = var_56_76

	local var_56_77 = native.CLookAtMePosProcess()

	var_56_77.positionInfoPool = arg_56_2.positionInfoPool
	var_56_77.velocityInfoPool = arg_56_2.velocityInfoPool
	var_56_77.lookAtMePosPool = arg_56_2.lookAtMePosPool
	var_56_77.actorModelPool = arg_56_2.actorModelPool
	var_56_11.lookAtMePosProcess = var_56_77

	local var_56_78 = native.CLookAtTargetProcess()

	var_56_78.lookAtMePosPool = arg_56_2.lookAtMePosPool
	var_56_78.lookAtTargetPool = arg_56_2.lookAtTargetPool
	var_56_78.motionPathPool = arg_56_2.motionPathPool
	var_56_78.lookAtConfigDict = VERIFY(arg_56_3.headLookAtConfigDict)
	var_56_78.sidePool = arg_56_2.sidePool
	var_56_78.positionInfoPool = arg_56_2.positionInfoPool
	var_56_78.teamKnowledgePair = VERIFY(arg_56_4.teamKnowledgePair)
	var_56_11.lookAtTargetProcess = var_56_78

	local var_56_79 = native.CMovableProcess()

	var_56_79.obstaclePool = VERIFY(arg_56_2.obstaclePool)
	var_56_11.movableProcess = var_56_79

	local var_56_80 = native.CPlayerCollisionBumpProcess(var_56_10, arg_56_3.activeHumanoidIdList, arg_56_3.guidManager, arg_56_2.obstaclePool, arg_56_2.positionInfoPool, arg_56_2.velocityInfoPool, rulesenvironment_cconfig.cBoundaryConfig, var_56_1.onlineMultiplayer, arg_56_2.bumpInfoPool, arg_56_2.authoritySet, arg_56_0.physicsScene.physicsWorld, arg_56_3)

	var_56_11.playerCollisionBumpProcess = var_56_80

	local var_56_81 = loadTemp("script-config.design.playercollision_config")
	local var_56_82 = native.CBallPlayerCollisionProcess(arg_56_0.physicsScene, var_56_81.CollisionConfig)

	var_56_82.positionInfoPool = arg_56_2.positionInfoPool
	var_56_82.velocityInfoPool = arg_56_2.velocityInfoPool
	var_56_82.actorModelPool = VERIFY(arg_56_2.actorModelPool)
	var_56_82.attachmentInfoPool = VERIFY(arg_56_2.attachmentInfoPool)
	var_56_82.playerCollisionHandlePool = VERIFY(arg_56_2.playerCollisionHandlePool)
	var_56_82.propScene = var_56_7
	var_56_82.network = VERIFY(arg_56_3.network)
	var_56_11.ballPlayerCollisionProcess = var_56_82

	for iter_56_4, iter_56_5 in ipairs(fieldposts.cornerPostPropNames) do
		var_56_82:addCollidablePropName(iter_56_5)
	end

	arg_56_3.ballPlayerCollisionProcess = var_56_82

	local var_56_83 = arg_56_0.sceneRenderer.shadowManager
	local var_56_84 = native.CGearAttachmentProcess()

	var_56_84:setSkeletonAttachmentManager(arg_56_0.scene.skeletonAttachmentManager)

	var_56_84.gearVisualPool = arg_56_2.gearVisualPool
	var_56_84.secondaryGearVisualPool = arg_56_2.secondaryGearVisualPool
	var_56_84.actorModelPool = arg_56_2.actorModelPool
	var_56_84.attachmentInfoPool = arg_56_2.attachmentInfoPool
	var_56_84.shadowManager = var_56_83
	var_56_11.gearAttachmentProcess = var_56_84

	local var_56_85 = native.CPlayerMarkerProcess()

	var_56_85.playerMarkerInfoPool = arg_56_2.playerMarkerInfoPool
	var_56_85.positionInfoPool = arg_56_2.positionInfoPool
	var_56_85.gamerControlStatePool = arg_56_2.gamerControlStatePool
	var_56_85.teamBallKnowledgePair = arg_56_4.teamBallKnowledgePair
	var_56_85.teamKnowledgePair = arg_56_4.teamKnowledgePair
	var_56_85.sidePool = arg_56_2.sidePool
	var_56_85.placeKickEntity = arg_56_8:getPlaceKickEntity()
	var_56_85.staminaInfoPool = arg_56_2.staminaInfoPool
	var_56_85.balanceArbitrator = arg_56_3.balanceArbitrator
	var_56_85.derivedAttributesPool = arg_56_4.derivedAttributesPool
	var_56_85.actorModelPool = arg_56_2.actorModelPool
	var_56_11.playerMarkerProcess = var_56_85

	local var_56_86 = native.CPlayerForesightProcess()

	var_56_86:initialise(var_56_8)

	var_56_86.markerConfig = playermarker_cconfig.cPlayerMarkerConfig
	var_56_86.playerTintInfoPool = arg_56_2.playerTintInfoPool
	var_56_86.actorModelPool = arg_56_2.actorModelPool
	var_56_86.sidePool = arg_56_2.sidePool
	var_56_86.teamKnowledgePair = arg_56_4.teamKnowledgePair
	var_56_86.network = VERIFY(arg_56_3.network)
	var_56_11.playerForesightProcess = var_56_86

	local var_56_87 = native.CTeamTacticsProcess()

	var_56_11.teamTacticsProcess = var_56_87

	local var_56_88 = native.CWindIndicatorProcess(arg_56_1:getAssetManager(), arg_56_0.scene, "props/hud/models/windArrows.model")

	var_56_88.positionInfoPool = arg_56_2.positionInfoPool
	var_56_88.gamerControlStatePool = arg_56_2.gamerControlStatePool
	var_56_88.teamKnowledgePair = arg_56_4.teamKnowledgePair
	var_56_88.inPlayKickEntity = arg_56_8:getInPlayKickEntity()
	var_56_88.placeKickEntity = arg_56_8:getPlaceKickEntity()
	var_56_11.windIndicatorProcess = var_56_88
	var_56_11.ballMarkerProcess = native.CBallMarkerProcess()

	local var_56_89 = native.CNaturalMovementUpdateProcess(var_56_10, arg_56_2.naturalMovementInfoPool, arg_56_4.derivedAttributesPool, naturalmovementprofileset_cconfig.cNaturalMovementProfileSet, arg_56_3.movementCommandParamsFactory)

	var_56_11.naturalMovementUpdateProcess = var_56_89

	local var_56_90 = native.CHumanMovementUpdateProcess()

	var_56_90.humanMovementInfoPool = arg_56_2.humanMovementInfoPool
	var_56_90.derivedAttributesPool = arg_56_4.derivedAttributesPool
	var_56_90.positionInfoPool = arg_56_2.positionInfoPool
	var_56_90.preferredMotionProfilePool = VERIFY(arg_56_2.preferredMotionProfilePool)
	var_56_90.movementConfig = var_0_10
	var_56_11.humanMovementUpdateProcess = var_56_90

	local var_56_91 = var_56_4 and var_56_4:getHook("PlaySelectionDebugHook")
	local var_56_92 = native.CPlaySelectionProcess()

	var_56_92.playsPreferenceList = arg_56_3.playsPreferenceList
	var_56_92.playSet = arg_56_3.playSetContainer
	var_56_92.teamKnowledgePair = arg_56_4.teamKnowledgePair
	var_56_92.teamFortyTwentyKnowledgePair = arg_56_4.teamFortyTwentyKnowledgePair
	var_56_92.boundaryConfig = rulesenvironment_cconfig.cBoundaryConfig
	var_56_92.network = VERIFY(arg_56_3.network)
	var_56_92.onSelectionMade = var_56_91 and function(...)
		var_56_91:onSelectionMade(...)
	end
	var_56_11.playSelectionProcess = var_56_92

	local var_56_93 = native.CPlayUpdateProcess()

	var_56_93.teamKnowledgePair = arg_56_4.teamKnowledgePair
	var_56_93.network = VERIFY(arg_56_3.network)
	var_56_93.collectConfig = var_0_8
	var_56_11.playUpdateProcess = var_56_93

	local var_56_94 = arg_56_1:getUIRenderAide().skin
	local var_56_95 = native.CPlayRenderer(arg_56_3.playLines, var_0_7.cSpeedConfig, rulesenvironment_cconfig.cBoundaryConfig, var_56_94)

	var_56_95.playSet = arg_56_3.playSetContainer
	var_56_95.teamKnowledgePair = arg_56_4.teamKnowledgePair
	var_56_11.playHUDProcess = var_56_95

	local var_56_96 = native.CForceDirectedGraphUpdateProcess()

	var_56_11.forceDirectedGraphUpdateProcess = var_56_96
	arg_56_0.processes = var_56_11

	return var_56_11
end

function Universe.createNetwork(arg_70_0, arg_70_1, arg_70_2)
	local var_70_0 = arg_70_1:getMarshaller()

	ASSERT(var_70_0)

	local var_70_1 = false
	local var_70_2 = not var_70_1
	local var_70_3 = native.CNetwork(var_70_0, 2, var_70_2)

	arg_70_2.destructNetwork = true

	local var_70_4 = arg_70_2.participantId
	local var_70_5 = arg_70_2.loopbacks[var_70_4]
	local var_70_6 = {}

	if var_70_5 == nil then
		var_70_5 = native.LoopbackConnection.create(var_70_4)

		table.insert(var_70_6, var_70_5)
	end

	var_70_3:addConnection(var_70_5)
	var_70_3:init(var_70_4)
	var_70_3:setBandwidthMonitor(arg_70_1:getBandwidthMonitor())

	arg_70_0.ownNetwork = true
	arg_70_0.network = var_70_3
	arg_70_0.createdConnections = var_70_6
	arg_70_2.network = var_70_3
end

function Universe.initIdLists(arg_71_0, arg_71_1, arg_71_2)
	local function var_71_0(arg_72_0)
		local var_72_0 = native.CIdList()

		arg_71_2:registerGameObjectListener(var_72_0, arg_72_0)

		return var_72_0
	end

	arg_71_0.humanoidIdList = var_71_0(humanoidtype.TypeId)
	arg_71_0.playerIdList = var_71_0(playertype.TypeId)
	arg_71_0.umpireIdList = var_71_0(umpiretype.TypeId)
	arg_71_0.coachIdList = var_71_0(coachtype.TypeId)
	arg_71_1.activeHumanoidIdList = arg_71_0.humanoidIdList
	arg_71_1.activePlayerIdList = arg_71_0.playerIdList
	arg_71_1.activeUmpireIdList = arg_71_0.umpireIdList
	arg_71_1.activeCoachIdList = arg_71_0.coachIdList
end

function Universe.loadPropCollision(arg_73_0, arg_73_1, arg_73_2, arg_73_3, arg_73_4)
	local var_73_0 = arg_73_1:getCollisionBlobLoader()
	local var_73_1 = arg_73_1:getAssetNotifier()

	assert(not arg_73_0.propCollisionSets)

	local var_73_2 = assetjoin.AssetJoin(var_73_1, "Universe:loadPropCollision")
	local var_73_3 = native.createTable(0, #arg_73_3)

	arg_73_0.propCollisionSets = var_73_3

	for iter_73_0, iter_73_1 in ipairs(arg_73_3) do
		local var_73_4 = var_73_0:load(iter_73_1 .. ".collision")

		var_73_3[iter_73_1] = var_73_4

		var_73_2:addAsset(var_73_4)

		if arg_73_4 then
			arg_73_4:addAsset(var_73_4)
		end
	end

	arg_73_2.propCollisionSets = arg_73_0.propCollisionSets

	var_73_2:fire(function()
		local var_74_0 = VERIFY(arg_73_0.processes)
		local var_74_1 = VERIFY(var_74_0.ballPlayerCollisionProcess)
	end)
end

local function var_0_25(arg_75_0, arg_75_1, arg_75_2, arg_75_3)
	local var_75_0 = arg_75_3.physicsCollisionType
	local var_75_1 = arg_75_3.friction
	local var_75_2 = arg_75_3.restitution
	local var_75_3 = arg_75_3.transform
	local var_75_4 = arg_75_3.doubleSided
	local var_75_5 = arg_75_1.meshInstanceCount
	local var_75_6
	local var_75_7 = false

	ASSERT(var_75_4 ~= nil)

	for iter_75_0 = 0, var_75_5 - 1 do
		local var_75_8 = arg_75_1:getMeshInstanceName(iter_75_0)

		if stringx.contains(var_75_8, arg_75_2, true) then
			local var_75_9 = arg_75_1:createShapeFromMeshInstance(iter_75_0, var_75_4)

			var_75_9.collisionType = var_75_0

			if var_75_1 then
				var_75_9.friction = var_75_1
			end

			if var_75_2 then
				var_75_9.restitution = var_75_2
			end

			if var_75_3 then
				var_75_3.s = var_75_9.shapeToParent.s
				var_75_9.shapeToParent = var_75_3
			end

			arg_75_0:add(var_75_9)
			var_75_9:decRef()

			var_75_7 = true
		end
	end

	if not var_75_7 then
		print("Collision export is missing required mesh name " .. arg_75_2)
	end
end

function Universe.loadStadiumCollision(arg_76_0, arg_76_1, arg_76_2, arg_76_3, arg_76_4)
	local var_76_0 = arg_76_3.levelData
	local var_76_1 = arg_76_3.stadiumCollisionBlob
	local var_76_2 = arg_76_1:getCollisionBlobLoader()
	local var_76_3 = arg_76_1:getAssetNotifier()
	local var_76_4 = arg_76_2.matchInData
	local var_76_5 = false

	arg_76_0.collisionSet = nil
	arg_76_0.collisionShapeSet = nil
	arg_76_0.goalPostsCollisionSet = nil
	arg_76_0.goalPostsCollisionShapeSet = nil

	local var_76_6 = assetjoin.AssetJoin(var_76_3, "Universe:loadStadiumCollision")

	arg_76_0.collisionSet = var_76_2:load(var_76_1)
	arg_76_0.goalPostsCollisionSet = var_76_2:load("collision/props/goalposts.collision")

	var_76_6:addAsset(arg_76_0.collisionSet)
	var_76_6:addAsset(arg_76_0.goalPostsCollisionSet)

	if arg_76_4 then
		arg_76_4:addAsset(arg_76_0.collisionSet)
		arg_76_4:addAsset(arg_76_0.goalPostsCollisionSet)
	end

	var_76_6:fire(function()
		local var_77_0 = arg_76_0.collisionSet
		local var_77_1 = arg_76_0.goalPostsCollisionSet
		local var_77_2 = native.CCollisionShapeSet.construct(32)

		arg_76_0.collisionShapeSet = var_77_2

		local var_77_3 = "fence"

		if var_0_3 == "cricket" then
			ASSERT(false)
		end

		local var_77_4 = {
			doubleSided = true,
			physicsCollisionType = var_76_5 and native.CPhysicsEnum.Net or native.CPhysicsEnum.StadiumWall,
			friction = ground_config.fence_friction,
			restitution = var_76_5 and 0 or ground_config.fence_restitution
		}

		var_0_25(var_77_2, var_77_0, var_77_3, var_77_4)
		arg_76_0.physicsScene.physicsWorld:lock()
		arg_76_0.physicsScene.physicsWorld:addStaticShapeSet(var_77_2)
		arg_76_0.physicsScene.physicsWorld:unlock()

		if var_0_3 == "cricket" then
			ASSERT(false)
		end

		if var_0_3 == "rugby" then
			local var_77_5 = native.CCollisionShapeSet.construct(8)

			arg_76_0.goalPostsCollisionShapeSet = var_77_5

			local var_77_6 = {
				doubleSided = false,
				physicsCollisionType = native.CPhysicsEnum.GoalPostVertical,
				friction = ground_config.goal_post_friction,
				restitution = ground_config.goal_post_restitution
			}

			var_0_25(var_77_5, var_77_1, "uprights_collision", var_77_6)

			var_77_6.physicsCollisionType = native.CPhysicsEnum.GoalPostCrossbar

			var_0_25(var_77_5, var_77_1, "crossbar_collision", var_77_6)

			local var_77_7 = {
				doubleSided = false,
				physicsCollisionType = native.CPhysicsEnum.GoalPostPadding,
				friction = ground_config.goal_post_padding_friction,
				restitution = ground_config.goal_post_padding_restitution
			}

			var_0_25(var_77_5, var_77_1, "padding_collision", var_77_7)
			arg_76_0.physicsScene.physicsWorld:lock()
			arg_76_0.physicsScene.physicsWorld:addStaticShapeSet(var_77_5)
			arg_76_0.physicsScene.physicsWorld:unlock()
		end
	end)
end

function Universe.unloadCutsceneProps(arg_78_0, arg_78_1)
	local var_78_0 = arg_78_0.podiumModel

	if var_78_0 then
		var_78_0:dispose()

		arg_78_0.cutsceneProps.podium = nil
	end

	for iter_78_0, iter_78_1 in pairs(arg_78_0.cutsceneProps) do
		iter_78_1:dispose()
	end

	arg_78_0.cutsceneProps = {}

	for iter_78_2, iter_78_3 in ipairs(arg_78_0.cutsceneTextures) do
		iter_78_3:unload()
	end
end

function Universe.setupStadium(arg_79_0, arg_79_1, arg_79_2, arg_79_3, arg_79_4, arg_79_5, arg_79_6, arg_79_7)
	profile.push("Universe:setupStadium")

	local var_79_0 = arg_79_1:getAssetNotifier()
	local var_79_1 = arg_79_1:getRendertargetPool()
	local var_79_2 = arg_79_1:getTextureManager()
	local var_79_3 = arg_79_1:getJobManager()
	local var_79_4 = arg_79_1:getRenderInterface()
	local var_79_5, var_79_6 = var_79_4:getDeferredResolution()
	local var_79_7 = arg_79_1:getRenderInterface()
	local var_79_8 = VERIFY(arg_79_0.scene)
	local var_79_9
	local var_79_10 = arg_79_1:getGraphicsSettings()
	local var_79_11 = native.CRenderer(arg_79_1, var_79_10)
	local var_79_12 = arg_79_1:getLuaGcTask()

	var_79_11:installBackgroundTask(var_79_12)

	local var_79_13 = var_79_11.skyLightingSettings
	local var_79_14 = gi_config.SkyLightingConfig

	tablex.mergeInto(var_79_13, var_79_14)

	var_79_11.graphicsSettings = var_79_10

	local var_79_15 = native.CLighting()
	local var_79_16 = var_79_15.shadowConfig
	local var_79_17 = var_79_10.shadows
	local var_79_18 = native.EShadowQuality
	local var_79_19 = native.EShadowMapType

	if var_79_17 == var_79_18.Off then
		var_79_16.cascadeDimensionX = 32
		var_79_16.cascadeDimensionY = 32
		var_79_16.shadowMapType = var_79_19.VSM16_NO_BLUR
	elseif var_79_17 == var_79_18.Lowest then
		var_79_16.cascadeDimensionX = 1024
		var_79_16.cascadeDimensionY = 512
		var_79_16.shadowMapType = var_79_19.VSM16_NO_BLUR
	elseif var_79_17 == var_79_18.Low then
		var_79_16.cascadeDimensionX = 1536
		var_79_16.cascadeDimensionY = 768
		var_79_16.shadowMapType = var_79_19.VSM16_NO_BLUR
	elseif var_79_17 == var_79_18.Medium then
		var_79_16.cascadeDimensionX = 1536
		var_79_16.cascadeDimensionY = 768
		var_79_16.shadowMapType = var_79_19.VSM16
	elseif var_79_17 == var_79_18.High then
		var_79_16.cascadeDimensionX = 2048
		var_79_16.cascadeDimensionY = 1024
		var_79_16.shadowMapType = var_79_19.VSM16
	else
		ASSERT(var_79_17 == var_79_18.Highest)

		var_79_16.cascadeDimensionX = 2048
		var_79_16.cascadeDimensionY = 1024
		var_79_16.shadowMapType = var_79_19.MSM16
	end

	if PLATFORM_SWITCH then
		var_79_15.shadowConfig.shadowMapCount = 12
	elseif PLATFORM_PC or PLATFORM_XBSX or PLATFORM_PS5 then
		var_79_15.shadowConfig.shadowMapCount = 19
	else
		var_79_15.shadowConfig.shadowMapCount = 12
	end

	var_79_15.shadowConfig.shadowMapCountMin = 12
	var_79_15.shadowConfig.shadowMapCountMax = 19
	var_79_15.shadowConfig.SSDOEnablePlayers = true
	var_79_15.shadowConfig.SSDOEnableCrowd = true
	arg_79_0.lighting = var_79_15
	var_79_11.lighting = var_79_15
	arg_79_0.sceneRenderer = var_79_11

	ASSERT(var_79_11)

	local var_79_20 = native.CFieldMarkings(var_79_5, var_79_6, var_79_4, "field_markings")

	var_79_20:initialise(var_79_7, var_79_8)
	var_79_11:setFieldMarkings(var_79_20)
	var_79_20:registerWithScene(var_79_8)

	arg_79_0.sceneFieldMarkings = var_79_20

	var_79_11:setBoundary(rulesenvironment_cconfig.cBoundaryConfig.halfFieldLength, rulesenvironment_cconfig.cBoundaryConfig.halfFieldWidth)
	table.insert(arg_79_0.sceneDisposalQueue, function(arg_80_0)
		if var_79_20 then
			var_79_20:dispose(arg_80_0)
		end
	end)

	local var_79_21 = VERIFY(arg_79_5.groundInfo).ground
	local var_79_22 = var_79_21 == "creator" and "stadium" or var_79_21
	local var_79_23 = crowd.Crowd(arg_79_1, arg_79_2, var_79_8, var_79_22, arg_79_7, arg_79_5, arg_79_0.matchInProgressData, arg_79_4)

	arg_79_0.crowd = var_79_23

	local var_79_24 = arg_79_3.levelData
	local var_79_25 = arg_79_1:getPerFrameMemory()

	var_79_8:initRenderer(var_79_11, var_79_25, var_79_3, false)

	local var_79_26 = assetjoin.AssetJoin(var_79_0, "universe.lua, stadiumJoin")
	local var_79_27 = var_79_2:load("ui/fieldhudlines/ui_flatcol.texture")
	local var_79_28 = native.CFieldHudLines(var_79_4, var_79_27)

	var_79_28.yOffset = ballmarker_config.YOffset

	var_79_11:setFieldHudLines(var_79_28)

	arg_79_2.hudLines = var_79_28

	local var_79_29 = var_79_2:load("ui/fieldhudlines/playline_col.texture")
	local var_79_30 = native.CFieldHudLines(var_79_4, var_79_29)

	var_79_30.yOffset = ballmarker_config.YOffset

	var_79_11:setPlayLines(var_79_30)

	arg_79_2.playLines = var_79_30

	local var_79_31 = var_0_24(arg_79_1, "ballTrail", true)
	local var_79_32 = 1
	local var_79_33 = native.CTrailCollection(ball_config.majorDiameter)

	if var_79_33 then
		local var_79_34 = var_79_11.shadowManager

		var_79_33:init(var_79_7, var_79_8, var_79_34, 129, var_79_32)

		arg_79_0.trails = var_79_33
		var_79_11.trails = var_79_33
		arg_79_2.trails = var_79_33
		arg_79_0.gameBallTrail = var_79_33:newTrail(0, var_79_31)
		arg_79_0.ballTrailLifespan = 0.75
	else
		arg_79_2.trails = var_79_33
	end

	local var_79_35 = var_79_2:load("textures/effects/lensedirt.texture")

	var_79_26:addAsset(var_79_35)

	local var_79_36 = arg_79_3.postFxConfig
	local var_79_37 = postfxfactory.createDofStage(var_79_36)
	local var_79_38 = postfxfactory.createBloomStage(var_79_36)
	local var_79_39 = postfxfactory.createToneMapStage(var_79_36, arg_79_1)
	local var_79_40 = postfxfactory.createSsaoStage(var_79_36)
	local var_79_41 = postfxfactory.createRainStage(var_79_36, arg_79_1)
	local var_79_42 = assert(arg_79_2.primaryPartyMemberSettings).inGameToneMapFilterIndex

	var_79_39.filter = var_79_39:getFilterName(var_79_42)
	arg_79_0.sceneRain = var_79_41
	arg_79_0.fieldConfig = assert(arg_79_3.fieldConfig)

	local var_79_43 = native.CInGameHud()

	var_79_43:initialise(var_79_8)
	var_79_11:setInGameHud(var_79_43)
	var_79_43:registerWithScene(var_79_8)

	local var_79_44 = native.CScreenTransition(var_79_1, var_79_5, var_79_6, var_79_10.isHDR)

	var_79_44:OnRecreate(0, function()
		arg_79_0.NVMJumbotron.CameraTexture = native.CNoesisTextureSource(var_79_44.capturedFrame, var_79_7)
	end)

	local var_79_45 = arg_79_1:getNoesis()

	arg_79_0.NVMJumbotron = nvm_jumbotron.NVMJumbotron(arg_79_1, arg_79_2.uiServices, arg_79_5)
	arg_79_0.NVMJumbotron.CameraTexture = native.CNoesisTextureSource(var_79_44.capturedFrame, var_79_7)

	local var_79_46 = var_79_45:createRenderTargetFromNew("JUMBO RENDER TARGET", 1200, 100)

	arg_79_0.uiRenderTarget = var_79_46

	local var_79_47 = var_79_45:loadViewWithVM("Workspace/Views/Tests/StadiumScreens_LargestAccor", arg_79_0.NVMJumbotron, native.ENoesisViewManagerLayer.POST_SCENE, native.CNoesisViewManager.DefaultPriority)

	var_79_47:setRenderTarget(var_79_46)

	arg_79_0.view = var_79_47

	assert(arg_79_3.stadiumCollisionBlob)
	arg_79_0:loadStadiumCollision(arg_79_1, arg_79_4, arg_79_3, var_79_26)

	local var_79_48 = stadium_module.StadiumModule()

	var_79_48:load(arg_79_1, var_79_8, VERIFY(arg_79_0.physicsScene), var_79_11, arg_79_3, arg_79_5, var_79_23, var_79_44, var_79_24, var_79_46)
	ASSERT(var_79_48.model and var_79_48.grass)

	local var_79_49 = native.CHotSpotFilter()

	var_79_11.hotSpotFilter = var_79_49
	arg_79_2.hotSpotFilter = var_79_49
	arg_79_0.hotSpotFilter = var_79_49
	arg_79_0.lighting.hotSpotFilter = var_79_49

	table.insert(arg_79_0.sceneDisposalQueue, function(arg_82_0)
		assert(type(arg_82_0) == "CGameEngine")
		arg_79_0.lighting:dispose(arg_82_0)
		var_79_40:dispose(arg_82_0)

		if var_79_47 then
			var_79_47:release()
		end

		arg_79_0.uiRenderTarget = nil
		arg_79_0.archRenderTarget = nil

		if arg_79_0.NVMJumbotron then
			arg_79_0.NVMJumbotron:dispose()
		end

		if var_79_43 then
			var_79_43:dispose(arg_82_0)
		end

		var_79_44:dispose(arg_82_0)
		var_79_37:dispose(arg_82_0)
		var_79_38:dispose(arg_82_0)
		var_79_39:dispose(arg_82_0)
		var_79_35:unload()
		var_79_11:dispose(arg_82_0)

		if var_79_28 then
			var_79_28:dispose()
		end

		if var_79_30 then
			var_79_30:dispose()
		end

		var_79_27:unload()
		var_79_29:unload()

		if var_79_41 then
			var_79_41:dispose(arg_82_0)
		end
	end)
	var_79_11:setDofStage(var_79_37)
	var_79_11:setBloomStage(var_79_38)
	var_79_11:setToneMapStage(var_79_39)
	var_79_11:setAmbientOcclusionStage(var_79_40)
	var_79_11:setScreenTransition(var_79_44)

	if var_79_41 then
		var_79_11:setRainStage(var_79_41)
	end

	local var_79_50 = var_79_11:getPizazzStage()

	var_79_50:setLensFlareTexture(var_79_35)

	arg_79_0.scenePizazz = var_79_50

	var_79_40:registerWithScene(var_79_8)

	arg_79_0.sceneDofStage = var_79_37
	arg_79_0.sceneBloomStage = var_79_38
	arg_79_0.sceneToneMapStage = var_79_39
	arg_79_0.sceneAmbientOcclusion = var_79_40
	arg_79_0.screenTransition = VERIFY(var_79_44)
	arg_79_0.inGameHud = var_79_43

	arg_79_0.cameraManager:registerWithRenderer(assert(var_79_11))

	local var_79_51 = shaderglobal.ShaderGlobal(arg_79_1)
	local var_79_52 = "intermediatelua.visualconfig.shaderglobals-game"

	var_79_51:loadFile(var_79_52)

	arg_79_0.shaderGlobal = var_79_51

	var_79_26:fire(function()
		var_79_50:setLensFlareTexture(var_79_35)

		var_79_38.lenseTexture = var_79_35

		table.insert(arg_79_6, function()
			arg_79_0:updateLighting(arg_79_0.timeOfDay)
			var_79_11:onPostWipe()
		end)
	end)

	if arg_79_7 then
		local function var_79_53(arg_85_0, arg_85_1, arg_85_2)
			arg_85_0 = arg_79_7:getHook(arg_85_0)

			if arg_85_0 then
				arg_85_0[arg_85_1](arg_85_0, arg_85_2)
			end
		end

		var_79_53("DofDebugHook", "setDofStage", var_79_37)
		var_79_53("SsaoDebugHook", "setAoStage", var_79_40)
		var_79_53("BloomDebugHook", "setBloomStage", var_79_38)
		var_79_53("ToneMapDebugHook", "setToneMapStage", var_79_39)
		var_79_53("RainDebugHook", "setRainStage", var_79_41)
		var_79_53("SceneDebugHook", "setRenderer", arg_79_0.sceneRenderer)
		var_79_53("MatchTimeDebugHook", "setCTimeOfDay", arg_79_0.timeOfDay)
		var_79_53("ShaderGlobalDebugHook", "setShaderGlobal", arg_79_0.shaderGlobal)
	end

	profile.pop("Universe:setupStadium")

	return var_79_48
end

function Universe.setupLighting(arg_86_0, arg_86_1, arg_86_2, arg_86_3, arg_86_4, arg_86_5, arg_86_6, arg_86_7)
	local var_86_0 = lighting_module.LightingModule()

	var_86_0:load(arg_86_1, arg_86_3, arg_86_2, arg_86_4, arg_86_5, arg_86_6, arg_86_7)

	local var_86_1 = VERIFY(arg_86_0.sceneDisposalQueue)

	table.insert(var_86_1, function()
		var_86_0:dispose()
	end)

	return var_86_0
end

function Universe.updateLighting(arg_88_0, arg_88_1)
	profile.push("Universe.updateLighting")
	ASSERT(arg_88_0.lightingModule, "Call Universe:setupLighting() first")
	VERIFY(arg_88_0.lightingModule):update(arg_88_1)
	profile.pop("Universe.updateLighting")
end

function Universe.unloadStadiumDebugHooks(arg_89_0, arg_89_1)
	local var_89_0 = arg_89_1.DofDebugHook

	if var_89_0 then
		var_89_0:setDofStage(nil)
	end
end

function Universe.createHud(arg_90_0, arg_90_1, arg_90_2, arg_90_3, arg_90_4, arg_90_5, arg_90_6)
	if native:getEnvironment():argExists("nohud") then
		return
	end

	local var_90_0
	local var_90_1 = arg_90_0.scene
	local var_90_2 = arg_90_0.sceneRenderer
	local var_90_3 = arg_90_5.homeTeamConfig
	local var_90_4 = arg_90_5.awayTeamConfig
	local var_90_5 = arg_90_0.matchOutData
	local var_90_6 = arg_90_6.services.uiServices
	local var_90_7 = hud.Hud(arg_90_1, arg_90_4, var_90_6)

	var_90_7:init(arg_90_1, var_90_6, arg_90_5)
	hud_registration.register(var_90_7, arg_90_1, var_90_2, arg_90_6, arg_90_5, var_90_5)
	arg_90_0:registerWithMatchSim(var_90_7)

	local var_90_8 = var_90_7:getElement("connectivity_hud")

	arg_90_0.hud = var_90_7

	return var_90_7
end

function Universe.updatePhysicsSceneParams(arg_91_0)
	local var_91_0 = arg_91_0.services
	local var_91_1 = arg_91_0.matchInData
	local var_91_2 = "standardDry"
	local var_91_3 = physics_config.pitchSurfaces[var_91_2]
	local var_91_4 = native.CPhysicsSceneParams()
	local var_91_5 = VERIFY(var_91_0.physicsScene)
	local var_91_6 = VERIFY(var_91_1.groundInfo)
	local var_91_7 = VERIFY(var_91_0.weather)
	local var_91_8 = VERIFY(var_91_0.timeOfDay)
	local var_91_9 = VERIFY(arg_91_0:getMatchInProgressData())

	var_91_4:initialise(physics_config, ground_config, ball_config, rulesenvironment, var_91_3, var_91_7, var_91_8, rulesenvironment_cconfig.cBoundaryConfig, var_91_6)

	var_91_5.params = var_91_4
end

function Universe.loadBall(arg_92_0, arg_92_1)
	local var_92_0 = VERIFY(arg_92_1.idManager)
	local var_92_1 = VERIFY(arg_92_1.engine)
	local var_92_2 = VERIFY(arg_92_1.matchSim)
	local var_92_3 = VERIFY(arg_92_1.matchSettings)
	local var_92_4 = VERIFY(arg_92_1.matchInData)
	local var_92_5 = VERIFY(arg_92_1.physicsScene)
	local var_92_6 = arg_92_1.network
	local var_92_7 = var_92_1:getAssetManager()

	var_92_2:registerOnPreWipe(function(arg_93_0, arg_93_1, arg_93_2, arg_93_3, arg_93_4, arg_93_5, arg_93_6, arg_93_7, arg_93_8, arg_93_9, arg_93_10)
		arg_92_0:updatePhysicsSceneParams()
		physicsfactory.onWipe(var_92_5)
		VERIFY(arg_92_0.sceneRenderer.propScene):onPreWipe()

		local var_93_0 = arg_93_8:getBallObject()

		var_93_0:initPhysicsStateFromScene(var_92_5)

		local var_93_1 = arg_93_7:getBallEntity()
		local var_93_2 = var_93_1.resetPosition

		var_93_0:resetTo(var_93_2)
		var_93_1:onWipe(arg_93_7, arg_93_9)
	end)
	var_92_2:registerOnPostWipe(function(arg_94_0, arg_94_1, arg_94_2, arg_94_3, arg_94_4, arg_94_5, arg_94_6, arg_94_7, arg_94_8, arg_94_9, arg_94_10)
		local var_94_0 = arg_94_7:getPhysicsEntity()
		local var_94_1 = arg_94_7:getBallEntity()
		local var_94_2 = arg_94_8:getBallObject()

		if var_94_1:getOwnerId(arg_94_9) then
			var_92_5.ballObject.frame = native.frame.Identity()
		else
			var_92_5.ballObject.frame = var_94_2.frame
		end

		local var_94_3 = native.CPhysicsState()

		var_94_3.time = arg_94_9

		var_92_5:writeToPhysicsState(var_94_3)

		local var_94_4 = disposal_request.getBallPhysicsParams()

		var_94_3.timeScale = var_94_4.timeScale
		var_94_3.targetTimeScale = var_94_3.timeScale
		var_94_3.targetTimeScaleChangeRate = 0
		var_94_3.ballState.friction = var_94_4.friction
		var_94_3.ballState.restitution = var_94_4.restitution

		var_94_0:onWipe(arg_94_5, var_94_3)
	end)

	local var_92_8 = var_92_0:allocateId(0)

	arg_92_1.id = var_92_8

	if var_92_3.physicsLogging then
		arg_92_1.physicsLogFile = "physics" .. var_92_6.participantId .. ".txt"
	end

	local var_92_9 = physicsfactory.createLoadContext()

	ballfactory.loadBall(var_92_9, var_92_1, arg_92_1.scene, var_92_4.matchType.ball, arg_92_0.gameBallTrail, arg_92_0.ballTrailLifespan)

	function arg_92_1.onLoaded()
		arg_92_0:createPhysicsJobs(VERIFY(arg_92_0.engine), VERIFY(arg_92_0.ballObject), VERIFY(arg_92_0.physicsScene))
	end

	local var_92_10 = physicsfactory.createBall(var_92_9, arg_92_1)

	markerfactory.loadMarkerModel(var_92_1, arg_92_1.scene, var_92_9, "hud/models/markers.model", var_92_10:getPlayerMarkerInfo())

	local var_92_11 = var_92_2:getGameObjects()

	var_92_11:addGameObject(var_92_8, var_92_10, true)

	function var_92_11.getBallObject()
		return var_92_10
	end

	function var_92_11.getBallId()
		return var_92_8
	end

	arg_92_0.ballObject = var_92_10
	arg_92_0.ballLoadContext = var_92_9

	return var_92_8, var_92_10, var_92_9
end

function Universe.createPhysicsJobs(arg_98_0, arg_98_1, arg_98_2, arg_98_3)
	if arg_98_0.physicsJobsCreated then
		return
	end

	local var_98_0 = arg_98_1:getJobManager()

	arg_98_2:setupJobs(var_98_0, arg_98_3)

	arg_98_0.physicsJobsCreated = true
end

function Universe.disposePhysicsJobs(arg_99_0, arg_99_1, arg_99_2)
	if arg_99_0.physicsJobsCreated then
		arg_99_0:waitPhysicsPredictionJobs(arg_99_1)

		local var_99_0 = arg_99_1:getJobManager()

		arg_99_2:disposeJobs(var_99_0)
	end
end

function Universe.disposeBallPredictionQueries(arg_100_0)
	if arg_100_0.ballPredictionSystem then
		arg_100_0.ballPredictionSystem:disposeQueries()
	end
end

function Universe.kickPhysicsPredictionJobs(arg_101_0, arg_101_1, arg_101_2, arg_101_3)
	ASSERT(arg_101_3)

	local var_101_0 = arg_101_1:getJobManager():getDefaultJobQueue()
	local var_101_1 = VERIFY(arg_101_2.linearPredictionJobs)
	local var_101_2 = VERIFY(arg_101_2.parallelPredictionJobs)

	var_101_1:push(var_101_0, arg_101_3)
	var_101_0:pushSync(arg_101_3)
	var_101_2:push(var_101_0, arg_101_3)
	var_101_0:pushSync(arg_101_3)

	arg_101_0.syncPhysicsPredictionJobs = var_101_0:pushNotifyJob(arg_101_3, "syncPhysicsPredictionJobs - NotifyJob")
end

function Universe.waitPhysicsPredictionJobs(arg_102_0, arg_102_1)
	profile.push("waitPhysicsPredictionJobs")

	local var_102_0 = arg_102_1:getJobManager()
	local var_102_1 = arg_102_0.syncPhysicsPredictionJobs

	if var_102_1 then
		var_102_0:waitJob(var_102_1)
		var_102_0:deleteJob(var_102_1)

		arg_102_0.syncPhysicsPredictionJobs = nil
	end

	profile.pop("waitPhysicsPredictionJobs")
end

function Universe.waitBallPredictionQueries(arg_103_0, arg_103_1, arg_103_2, arg_103_3)
	if arg_103_0.ballPredictionSystem then
		arg_103_0.ballPredictionSystem:waitQueries(arg_103_1, arg_103_2, arg_103_3)
	end
end

function Universe.loadPlayerMarkers(arg_104_0, arg_104_1)
	local var_104_0 = VERIFY(arg_104_1.engine)
	local var_104_1 = VERIFY(arg_104_1.matchSim)
	local var_104_2 = VERIFY(arg_104_1.matchSettings)
	local var_104_3 = VERIFY(arg_104_1.matchInData)
	local var_104_4 = VERIFY(arg_104_1.physicsScene)
	local var_104_5 = arg_104_1.network
	local var_104_6 = var_104_0:getAssetManager()
	local var_104_7 = arg_104_1.scene
	local var_104_8 = arg_104_1.id
	local var_104_9 = {}

	for iter_104_0, iter_104_1 in native.EMarkerModelType:iter() do
		local var_104_10 = physicsfactory.createLoadContext()

		markerfactory.loadMarkerModel(var_104_0, var_104_7, var_104_10, iter_104_1)
		table.insert(var_104_9, var_104_10)
	end

	return var_104_9
end

function Universe.loadUmpires(arg_105_0, arg_105_1)
	local var_105_0 = VERIFY(arg_105_1.engine)
	local var_105_1 = VERIFY(arg_105_1.matchSettings)
	local var_105_2 = VERIFY(arg_105_1.matchInData)
	local var_105_3 = VERIFY(arg_105_1.matchInProgressData)
	local var_105_4 = VERIFY(arg_105_1.scene)
	local var_105_5 = VERIFY(arg_105_1.matchSim)
	local var_105_6 = VERIFY(arg_105_1.idManager)
	local var_105_7 = VERIFY(arg_105_1.pools)
	local var_105_8 = VERIFY(arg_105_1.solidState)
	local var_105_9 = VERIFY(arg_105_1.characterAssetMap)
	local var_105_10 = not var_105_1.defaultheads
	local var_105_11 = var_105_1.headless
	local var_105_12 = true
	local var_105_13 = native.Random(var_105_3.matchSeed)
	local var_105_14 = gameobject.createClass("UmpireObject", umpireobject.Components)

	gameobject.initClass(var_105_14, arg_105_1)

	local var_105_15 = {}

	arg_105_0.umpireOnDiscIds = var_105_15

	local var_105_16 = not arg_105_1.trainingMode

	for iter_105_0 = 1, var_0_20 do
		local var_105_17 = var_105_2.umpireConfig:getUmpire(iter_105_0)
		local var_105_18 = var_105_17.name
		local var_105_19 = var_105_17.region
		local var_105_20 = var_105_17.type
		local var_105_21 = var_105_17.identity
		local var_105_22 = var_105_6:allocateId(0)
		local var_105_23 = var_0_2(1000, 1000)
		local var_105_24 = native.dirlen2(var_0_2(0, 0), var_105_23)
		local var_105_25 = VERIFY(var_105_17.assetId)
		local var_105_26
		local var_105_27 = var_105_14(var_105_22)

		gameobject.initInstance(var_105_27, tablex.merge(arg_105_1, {
			defaultMotionProfile = "referee",
			authority = assert(arg_105_1.authority),
			pos = var_105_23,
			facing = var_105_24,
			dir = var_105_24,
			id = var_105_22,
			assetId = var_105_25,
			identity = var_105_21,
			name = var_105_18,
			type = var_105_20,
			side = sidehelper.none,
			region = var_105_19,
			info = var_105_17,
			engine = var_105_0,
			useGenerated = var_105_10,
			headless = var_105_11,
			forceHeadSize = var_105_26,
			collisionRadius = player_config.collisionRadius,
			clothStage = arg_105_0.sceneCloth,
			fieldArrow = arg_105_0.fieldArrow,
			services = arg_105_0.services,
			random = var_105_13,
			modelType = native.EAssetMapModelType.Player,
			playerVisualConfig = var_105_17.visual,
			teamVisualConfig = var_105_17.uniform
		}))
		var_105_5:getGameObjects():addGameObject(var_105_22, var_105_27, var_105_16)

		var_105_15[var_105_22] = var_105_17.visualOnDiscId
	end
end

function Universe.loadNPCs(arg_106_0, arg_106_1)
	local var_106_0 = VERIFY(arg_106_1.engine)
	local var_106_1 = VERIFY(arg_106_1.matchInData)
	local var_106_2 = VERIFY(arg_106_1.matchInProgressData)
	local var_106_3 = VERIFY(arg_106_1.matchSim)
	local var_106_4 = VERIFY(arg_106_1.idManager)
	local var_106_5 = arg_106_1.match
	local var_106_6 = native.Random(var_106_2.matchSeed)
	local var_106_7 = arg_106_1.defaultPlayerVisualManager:get(native.DefaultPlayerVisuals.Civilian01_male)
	local var_106_8 = arg_106_1.defaultTeamVisualManager:get(native.DefaultTeamVisuals.Civilian01_male)
	local var_106_9 = gameobject.createClass("NPCObject", npcobject.Components)

	gameobject.initClass(var_106_9, arg_106_1)

	for iter_106_0 = 1, var_0_19 do
		local var_106_10 = "NPC_" .. iter_106_0
		local var_106_11 = {
			weight = "71",
			height = "1.71"
		}
		local var_106_12 = var_106_4:allocateId(0)
		local var_106_13 = var_0_2(10, 10)
		local var_106_14 = native.dirlen2(var_0_2(0, 0), var_106_13)
		local var_106_15 = var_106_9(var_106_12)

		gameobject.initInstance(var_106_15, tablex.merge(arg_106_1, {
			collisionRadius = 1,
			authority = VERIFY(arg_106_1.authority),
			pos = var_106_13,
			facing = var_106_14,
			dir = var_106_14,
			id = var_106_12,
			side = sidehelper.none,
			stats = var_106_11,
			name = var_106_10,
			engine = var_106_0,
			services = arg_106_0.services,
			random = var_106_6,
			playerVisualConfig = var_106_7,
			teamVisualConfig = var_106_8,
			modelType = native.EAssetMapModelType.Player
		}))

		local var_106_16 = false

		var_106_3:getGameObjects():addGameObject(var_106_12, var_106_15, var_106_16)
	end
end

function Universe.loadCoaches(arg_107_0, arg_107_1)
	local var_107_0 = VERIFY(arg_107_1.engine)
	local var_107_1 = VERIFY(arg_107_1.matchInData)
	local var_107_2 = VERIFY(arg_107_1.matchInProgressData)
	local var_107_3 = VERIFY(arg_107_1.matchSim)
	local var_107_4 = VERIFY(arg_107_1.idManager)
	local var_107_5 = arg_107_1.match
	local var_107_6 = native.Random(var_107_2.matchSeed)
	local var_107_7 = gameobject.createClass("CoachObject", coachobject.Components)

	gameobject.initClass(var_107_7, arg_107_1)

	local var_107_8 = {
		[sidehelper.home] = var_107_1.homeTeamConfig.matchClub,
		[sidehelper.away] = var_107_1.awayTeamConfig.matchClub
	}

	for iter_107_0, iter_107_1 in pairs(var_107_8) do
		local var_107_9 = iter_107_1.coach
		local var_107_10 = var_107_9.fullName
		local var_107_11 = {
			height = var_107_9.height,
			weight = var_107_9.weight
		}

		ASSERT(var_107_11.height == var_107_9.identity:getOption("height"))

		local var_107_12 = var_107_4:allocateId(0)
		local var_107_13 = var_0_2(10, 10)
		local var_107_14 = native.dirlen2(var_0_2(0, 0), var_107_13)
		local var_107_15
		local var_107_16 = var_107_7(var_107_12)

		gameobject.initInstance(var_107_16, tablex.merge(arg_107_1, {
			authority = VERIFY(arg_107_1.authority),
			pos = var_107_13,
			facing = var_107_14,
			dir = var_107_14,
			id = var_107_12,
			side = iter_107_0,
			team = var_107_5:getSide(iter_107_0),
			stats = var_107_11,
			name = var_107_10,
			engine = var_107_0,
			identity = var_107_9.identity,
			collisionRadius = player_config.collisionRadius,
			clothStage = arg_107_0.sceneCloth,
			fieldArrow = arg_107_0.fieldArrow,
			services = arg_107_0.services,
			random = var_107_6,
			playerVisualConfig = var_107_9.visual,
			teamVisualConfig = var_107_9.uniform
		}))

		local var_107_17 = false

		var_107_3:getGameObjects():addGameObject(var_107_12, var_107_16, var_107_17)
	end
end

function Universe.loadTeam(arg_108_0, arg_108_1, arg_108_2)
	local var_108_0 = VERIFY(arg_108_1.engine)
	local var_108_1 = VERIFY(arg_108_1.matchSettings)
	local var_108_2 = VERIFY(arg_108_1.pools)
	local var_108_3 = VERIFY(arg_108_1.matchSim)
	local var_108_4 = VERIFY(arg_108_1.idManager)
	local var_108_5 = VERIFY(arg_108_1.playerClass)
	local var_108_6 = VERIFY(arg_108_1.team)
	local var_108_7 = VERIFY(arg_108_1.otherTeam)
	local var_108_8 = VERIFY(arg_108_1.matchInData)
	local var_108_9 = VERIFY(arg_108_1.matchInProgressData)
	local var_108_10 = var_108_8.beAProAssetId
	local var_108_11 = var_108_0:getAssetManager()
	local var_108_12 = var_108_1.headless
	local var_108_13 = arg_108_0.animationProvider
	local var_108_14 = arg_108_0.jointClassSet
	local var_108_15 = arg_108_0.sceneMaterialGroups
	local var_108_16 = var_108_8.onlineMultiplayer
	local var_108_17 = not var_108_1.defaultheads
	local var_108_18 = var_108_6.side
	local var_108_19 = var_108_6:getLineup()
	local var_108_20 = var_108_6:getIdentityMap()
	local var_108_21 = var_108_6:getAttributesMap()
	local var_108_22 = var_108_6:getPlayerSkillsMap()
	local var_108_23 = var_108_6:getPlayerStateMap()
	local var_108_24 = var_108_6:getPlayerVisualDescriptorMap()
	local var_108_25 = var_108_6:getVisualConfig()
	local var_108_26 = native.Random(var_108_9.matchSeed)
	local var_108_27 = var_108_2.playerMarkerInfoPool
	local var_108_28 = 1

	for iter_108_0, iter_108_1 in ipairs(var_108_19:getListOfPlayerIds()) do
		local var_108_29 = VERIFY(var_108_21[iter_108_1])
		local var_108_30 = VERIFY(var_108_22[iter_108_1])
		local var_108_31 = VERIFY(var_108_23[iter_108_1])
		local var_108_32 = true

		if var_108_32 then
			local var_108_33 = VERIFY(var_108_20[iter_108_1])
			local var_108_34 = VERIFY(var_108_24[iter_108_1])
			local var_108_35 = {
				identity = var_108_33,
				attributes = var_108_29,
				team = var_108_6,
				otherTeam = var_108_7,
				assetId = iter_108_1,
				playerState = var_108_31
			}
			local var_108_36 = var_0_2(0, 0)
			local var_108_37 = var_0_2(1, 0)
			local var_108_38 = iter_108_1
			local var_108_39 = var_108_4:allocateId(0)
			local var_108_40 = var_108_34
			local var_108_41 = var_108_1.headSize and tonumber(var_108_1.headSize)
			local var_108_42 = arg_108_1.characterAssetMap
			local var_108_43 = var_108_5(var_108_39)

			var_108_28 = var_108_28 + 1

			gameobject.initInstance(var_108_43, tablex.merge(arg_108_1, {
				id = var_108_39,
				pos = var_108_36,
				facing = var_108_37,
				dir = var_108_37,
				name = var_108_38,
				assetId = iter_108_1,
				injuryLevel = var_108_31.injuryLevel,
				info = var_108_35,
				useGenerated = var_108_17,
				headless = var_108_12,
				authority = arg_108_1.participantWithAuthority,
				side = var_108_18,
				identity = var_108_33,
				attributes = var_108_29,
				skills = var_108_30,
				team = var_108_6,
				playerVisualConfig = var_108_34,
				teamVisualConfig = var_108_25,
				body = var_108_34,
				forceHeadSize = var_108_41,
				fieldConfig = assert(arg_108_0.fieldConfig),
				collisionRadius = player_config.collisionRadius,
				services = arg_108_0.services,
				random = var_108_26,
				modelType = native.EAssetMapModelType.Player,
				beAProAssetId = var_108_10
			}))
			var_108_3:getGameObjects():addGameObject(var_108_39, var_108_43, false)
			var_108_6:addPlayer(var_108_39, iter_108_1)
		end
	end
end

function Universe.initPropPools(arg_109_0, arg_109_1)
	local var_109_0 = var_0_22
	local var_109_1 = VERIFY(arg_109_1.pools)
	local var_109_2 = VERIFY(arg_109_1.idManager)

	local function var_109_3(arg_110_0)
		for iter_110_0 = 1, var_109_0 - 1 do
			arg_110_0:alloc(iter_110_0, var_109_2)
		end
	end

	local var_109_4 = VERIFY(var_109_1.propPositionInfoPool)

	var_109_3(var_109_4)

	local var_109_5 = VERIFY(var_109_1.propVelocityInfoPool)

	var_109_3(var_109_5)
end

function Universe.loadTeams(arg_111_0, arg_111_1, arg_111_2, arg_111_3, arg_111_4)
	local var_111_0 = VERIFY(arg_111_2.engine)
	local var_111_1 = VERIFY(arg_111_2.matchSettings)
	local var_111_2 = VERIFY(arg_111_2.match)
	local var_111_3 = VERIFY(arg_111_2.pools)
	local var_111_4 = VERIFY(arg_111_2.solidState)
	local var_111_5 = VERIFY(arg_111_2.matchInData)
	local var_111_6 = VERIFY(arg_111_2.matchOutData)
	local var_111_7
	local var_111_8 = var_111_5.homeTeamConfig
	local var_111_9 = var_111_6.homeTeamState
	local var_111_10 = team.Team(var_111_0, arg_111_1, sidehelper.home, var_111_8, var_111_9, var_111_7)
	local var_111_11 = var_111_5.awayTeamConfig
	local var_111_12 = var_111_6.awayTeamState
	local var_111_13 = team.Team(var_111_0, arg_111_1, sidehelper.away, var_111_11, var_111_12, var_111_7)
	local var_111_14 = gameobject.createClass("PlayerObject", playerobject.Components)

	assert(var_111_14)
	gameobject.initClass(var_111_14, arg_111_2)

	local var_111_15 = arg_111_0.isMaster

	if not arg_111_0.uniformDecorator and var_111_15 then
		local var_111_16 = native.CUniformDecorator()

		var_111_16:init(var_111_0)

		arg_111_0.uniformDecorator = var_111_16
	end

	local var_111_17 = arg_111_0.uniformDecorator
	local var_111_18 = physicsfactory.createLoadContext()

	arg_111_0.playerMarkerLoadContext = var_111_18

	local var_111_19 = var_111_5.onlineMultiplayer
	local var_111_20 = arg_111_2.network.participantId
	local var_111_21 = var_111_20 == 1 and 2 or 1
	local var_111_22 = var_111_1.homeIsRemote

	arg_111_0:loadTeam(tablex.merge(arg_111_2, {
		team = var_111_10,
		otherTeam = var_111_13,
		playerClass = var_111_14,
		uniformDecorator = var_111_17,
		playerMarkerLoadContext = var_111_18,
		participantWithAuthority = var_111_19 and (var_111_22 and var_111_21 or var_111_20) or 1
	}), arg_111_3)
	arg_111_0:loadTeam(tablex.merge(arg_111_2, {
		team = var_111_13,
		otherTeam = var_111_10,
		playerClass = var_111_14,
		uniformDecorator = var_111_17,
		playerMarkerLoadContext = var_111_18,
		participantWithAuthority = var_111_19 and (var_111_22 and var_111_20 or var_111_21) or 1
	}), arg_111_3)
	var_111_10:setOtherTeam(var_111_13)
	var_111_13:setOtherTeam(var_111_10)
	arg_111_0:initPropPools(arg_111_2)
	arg_111_4:append(var_111_10:getAssetIdMap())
	arg_111_4:append(var_111_13:getAssetIdMap())
	var_111_2:addComponent("home", var_111_10)
	var_111_2:addComponent("away", var_111_13)

	function var_111_2.getHome()
		return var_111_10
	end

	function var_111_2.getAway()
		return var_111_13
	end

	local var_111_23 = {
		var_111_10,
		var_111_13
	}

	function var_111_2.getSide(arg_114_0, arg_114_1)
		return var_111_23[arg_114_1]
	end

	local var_111_24 = arg_111_2.engine:getParticleController():getFXSystem()
	local var_111_25 = var_111_8.matchClub.primaryColour
	local var_111_26 = var_111_11.matchClub.primaryColour

	var_111_24:setCustomColour("home", native.ColourA(var_111_25.r, var_111_25.g, var_111_25.b, 255))
	var_111_24:setCustomColour("away", native.ColourA(var_111_26.r, var_111_26.g, var_111_26.b, 255))
end

function Universe.initReplayManager(arg_115_0, arg_115_1)
	local var_115_0 = assert(arg_115_1.engine)
	local var_115_1 = assert(arg_115_1.services)
	local var_115_2 = assert(arg_115_1.pools)
	local var_115_3 = assert(arg_115_1.knowledgeBank)
	local var_115_4 = assert(arg_115_1.matchSim.gameobjects)
	local var_115_5 = assert(arg_115_1.ballLoadContext)
	local var_115_6 = assert(var_115_4:getBallObject())
	local var_115_7 = replaymanager.ReplayManager(var_115_0, arg_115_1.config, arg_115_1.idManager, arg_115_0.services.guidManager)
	local var_115_8
	local var_115_9 = native.isRetail() and 0 or var_0_6 == "win32" and 256 or 1
	local var_115_10 = 40
	local var_115_11 = var_115_9 * 1024 * 1024
	local var_115_12 = var_115_10 * 1024 * 1024
	local var_115_13 = var_115_12 * 0.05
	local var_115_14 = var_115_12 * 0.025
	local var_115_15 = var_115_12 - var_115_13 - var_115_14
	local var_115_16 = 150 * (var_115_15 / 1048576)
	local var_115_17 = 15000 * (var_115_13 / 1048576)
	local var_115_18 = 4000 * (var_115_14 / 1048576)
	local var_115_19

	if var_115_11 > 0 then
		local var_115_20 = 200 * var_115_9

		var_115_19 = native.CReplayRingBuffer()

		var_115_19:initialise(var_115_20, var_115_11, false, true)

		arg_115_0.replayManagerDebugDataRingBuffer = var_115_19
	end

	local var_115_21 = native.CReplayRingBuffer()

	var_115_21:initialise(var_115_16, var_115_15, true)

	arg_115_0.replayManagerSharedRingBuffer = var_115_21

	local var_115_22 = native.CReplayRingBuffer()

	var_115_22:initialise(var_115_17, var_115_13, true)

	arg_115_0.replayManagerPhysicsRingBuffer = var_115_22

	local var_115_23 = native.CReplayRingBuffer()

	var_115_23:initialise(var_115_18, var_115_14, true)

	arg_115_0.replayManagerLowFrequencyRingBuffer = var_115_23

	local var_115_24 = native.CReplayManager(var_115_21)

	arg_115_0.replayManagerC = var_115_24

	var_115_7:setReplayManagerC(var_115_24)
	var_115_7:setReplayCAdapter(replaymanagercadapter.ReplayManagerCAdapter(var_115_24))

	local var_115_25 = arg_115_1.gamestate
	local var_115_26 = native.CCrowdReplaySystem(var_115_23, "crowd")

	if arg_115_1.crowdScene then
		var_115_26.crowdScene = arg_115_1.crowdScene
	end

	arg_115_0.crowdReplaySystem = var_115_26

	local var_115_27 = native.CPlayerVisualReplaySystem(var_115_21, "playerVisual")

	var_115_27.actorModelPool = assert(var_115_2.actorModelPool)
	arg_115_0.playerVisualReplaySystem = var_115_27

	local var_115_28 = native.CPlayerAnimationReplaySystem(var_115_21, "playerAnimation")

	var_115_28.positionInfoPool = VERIFY(var_115_2.positionInfoPool)
	var_115_28.velocityInfoPool = VERIFY(var_115_2.velocityInfoPool)
	var_115_28.playerAnimationPool = VERIFY(var_115_2.playerAnimationPool)
	var_115_28.skeletonModifierPool = VERIFY(var_115_2.skeletonModifierPool)
	var_115_28.ikTargetInfoPool = VERIFY(var_115_2.ikTargetInfoPool)
	var_115_28.activeLeanPool = VERIFY(var_115_2.activeLeanPool)
	var_115_28.attachmentInfoPool = VERIFY(var_115_2.attachmentInfoPool)
	arg_115_0.playerAnimationReplaySystem = var_115_28

	local var_115_29 = native.CBallVisualReplaySystem(var_115_21, "ballVisual")

	var_115_29.ballObject = var_115_6
	arg_115_0.ballVisualReplaySystem = var_115_29

	local var_115_30 = native.CCornerPostReplaySystem(var_115_21, "cornerPost")

	var_115_30.propScene = VERIFY(arg_115_0.sceneRenderer.propScene)

	for iter_115_0, iter_115_1 in ipairs(fieldposts.cornerPostPropNames) do
		var_115_30:addPropName(iter_115_1)
	end

	local var_115_31 = native.CFXReplaySystem(var_115_21, "fxSystem")

	var_115_31.fxSystem = var_115_0:getParticleController():getFXSystem()
	arg_115_0.fxReplaySystem = var_115_31

	local var_115_32 = native.CPhysicsReplaySystem(var_115_22, "physics")

	var_115_32.ballObject = var_115_6
	var_115_32.gameObjectManager = assert(var_115_4)

	var_115_6:setPhysicsReplaySystem(var_115_32)

	local var_115_33 = native.CPlayerDegradationReplaySystem(var_115_23, "playerDegradation")

	var_115_33.actorModelPool = var_115_2.actorModelPool
	arg_115_0.playerDegradationReplaySystem = var_115_33

	local var_115_34 = native.CPropVisualReplaySystem(var_115_21, "propVisual")

	if GAME_RUGBY then
		var_115_34.kickingTee = var_115_1.kickingTee
		var_115_34.moveableKickingTee = var_115_1.moveableKickingTee
	end

	arg_115_0.propVisualReplaySystem = var_115_34

	var_115_7:addFrameStartReplaySystemC(var_115_27)
	var_115_7:addFrameEndReplaySystemC(var_115_26)
	var_115_7:addFrameEndReplaySystemC(var_115_28)
	var_115_7:addFrameEndReplaySystemC(var_115_29)
	var_115_7:addFrameEndReplaySystemC(var_115_30)
	var_115_7:addFrameEndReplaySystemC(var_115_31)
	var_115_7:addFrameEndReplaySystemC(var_115_32)
	var_115_7:addFrameEndReplaySystemC(var_115_33)
	var_115_7:addFrameEndReplaySystemC(var_115_34)

	local var_115_35 = var_115_0.getReplaySaveSystem()

	if var_115_19 then
		local var_115_36 = native.CDebugDataReplaySystem(var_115_19, "debugData")

		var_115_36.flowchartConditionInstancePool = VERIFY(var_115_2.flowchartConditionInstancePool)
		var_115_36.selectedControllerFlowchartConditionInstancePool = VERIFY(var_115_2.selectedControllerFlowchartConditionInstancePool)
		var_115_36.controllerNamePool = VERIFY(var_115_2.controllerNamePool)
		var_115_36.blendControllerNamePool = VERIFY(var_115_2.blendControllerNamePool)
		var_115_36.behaviourNamePool = VERIFY(var_115_2.behaviourNamePool)
		var_115_36.inputState = VERIFY(var_115_2.inputState)
		var_115_36.gameobjectSelectedPool = VERIFY(var_115_2.gameobjectSelectedPool)
		var_115_36.ikTargetInfoPool = VERIFY(var_115_2.ikTargetInfoPool)
		var_115_36.incapacitatedInfoPool = VERIFY(var_115_3.incapacitatedInfoPool)
		var_115_36.skeletonModifierPool = VERIFY(var_115_2.skeletonModifierPool)
		var_115_36.attachmentInfoPool = VERIFY(var_115_2.attachmentInfoPool)
		var_115_36.obstaclePool = VERIFY(var_115_2.obstaclePool)
		var_115_36.footContactPool = VERIFY(var_115_2.footContactPool)
		var_115_36.torsoContactPool = VERIFY(var_115_2.torsoContactPool)
		var_115_36.frameKnowledge = VERIFY(var_115_2.frameKnowledge)
		var_115_36.playerBallInteractionKnowledgePool = VERIFY(var_115_3.playerBallInteractionKnowledgePool)
		var_115_36.playerBallKnowledgePool = VERIFY(var_115_3.playerBallKnowledgePool)
		var_115_36.playerCollectSequenceKnowledgePool = VERIFY(var_115_3.playerCollectSequenceKnowledgePool)
		var_115_36.playerBallCollectKnowledgePool = VERIFY(var_115_3.playerBallCollectKnowledgePool)
		var_115_36.playerMovementStateKnowledgePool = VERIFY(var_115_3.playerMovementStateKnowledgePool)
		var_115_36.activeTackleArbitrationKnowledge = VERIFY(var_115_3.activeTackleArbitrationKnowledge)
		var_115_36.playerTackleArbitrationKnowledgePool = VERIFY(var_115_3.playerTackleArbitrationKnowledgePool)
		var_115_36.pushTackleIntentPool = VERIFY(var_115_3.pushTackleIntentPool)
		var_115_36.holdTackleIntentPool = VERIFY(var_115_3.holdTackleIntentPool)
		var_115_36.tackleIntentPool = VERIFY(var_115_3.tackleIntentPool)
		var_115_36.humanMovementInfoPool = VERIFY(var_115_2.humanMovementInfoPool)
		var_115_36.ballTrajectory = VERIFY(var_115_3.ballTrajectory)
		var_115_36.teamInPlayKnowledgePair = VERIFY(var_115_3.teamInPlayKnowledgePair)
		var_115_36.teamBallKnowledgePair = VERIFY(var_115_3.teamBallKnowledgePair)
		var_115_36.defensiveGapKnowledgePair = VERIFY(var_115_3.defensiveGapKnowledgePair)
		var_115_36.lineBreakerKnowledge = VERIFY(var_115_3.lineBreakerKnowledge)
		var_115_36.teamLineBreakKnowledgePair = VERIFY(var_115_3.teamLineBreakKnowledgePair)
		var_115_36.playerGapKnowledgePool = VERIFY(var_115_3.playerGapKnowledgePool)
		var_115_36.arbitrationResultListPool = VERIFY(var_115_3.arbitrationResultListPool)
		var_115_36.matchProgressionEntity = VERIFY(var_115_25:getMatchProgressionEntity())
		var_115_36.playerCoverageKnowledgePool = VERIFY(var_115_3.playerCoverageKnowledgePool)
		var_115_36.staminaInfoPool = VERIFY(var_115_2.staminaInfoPool)
		var_115_36.playEntityPair = VERIFY(var_115_25:getPlayEntityPair())
		var_115_36.activeTackleEntity = VERIFY(var_115_3.activeTackleEntity)
		var_115_36.playTheBallEntity = VERIFY(var_115_25.playTheBallEntity)
		var_115_36.playerDummyHalfKnowledgePool = VERIFY(var_115_3.playerDummyHalfKnowledgePool)
		var_115_36.playTheBallKnowledge = VERIFY(var_115_3.playTheBallKnowledge)
		var_115_36.teamForceDirectedGraphKnowledgePair = VERIFY(var_115_3.teamForceDirectedGraphKnowledgePair)
		var_115_36.forceDirectedGraphOccupancyPool = VERIFY(var_115_3.forceDirectedGraphOccupancyPool)
		var_115_36.playerMechanicDecisionPool = VERIFY(var_115_3.playerMechanicDecisionPool)
		var_115_36.teamSupportRunnerKnowledgePair = VERIFY(var_115_3.teamSupportRunnerKnowledgePair)
		arg_115_0.debugDataReplaySystem = var_115_36

		var_115_7:addFrameEndReplaySystemC(var_115_36)

		if native.EReplaySaveRingBuffer.DebugData then
			var_115_35.ringBuffers:setRingBuffer(native.EReplaySaveRingBuffer.DebugData, arg_115_0.replayManagerDebugDataRingBuffer)
		end
	end

	var_115_35.ringBuffers:setRingBuffer(native.EReplaySaveRingBuffer.Shared, arg_115_0.replayManagerSharedRingBuffer)
	var_115_35.ringBuffers:setRingBuffer(native.EReplaySaveRingBuffer.Physics, arg_115_0.replayManagerPhysicsRingBuffer)

	arg_115_0.replaySaveSystem = var_115_35

	local var_115_37 = arg_115_0.stadium.grass

	if var_115_37 then
		var_115_37:registerWithReplayManager(var_115_7, var_115_21)
	end

	local var_115_38 = assert(arg_115_1.matchSim)

	var_115_38:registerUpdateable(var_115_7)
	var_115_38:registerGameObjectListener(var_115_7, humanoidtype.TypeId)

	arg_115_0.replayManager = var_115_7

	local var_115_39 = arg_115_1.hooks
	local var_115_40 = var_115_39 and var_115_39:getHook("ReplayDebugHook")

	if var_115_40 then
		var_115_40:setReplayManager(var_115_7)
	end

	return var_115_7
end

function Universe.resumeRecording(arg_116_0, arg_116_1)
	return
end

function Universe.createDefaultCamera(arg_117_0, arg_117_1, arg_117_2, arg_117_3, arg_117_4)
	return
end

function Universe.createGameplayCameras(arg_118_0, arg_118_1, arg_118_2, arg_118_3, arg_118_4, arg_118_5, arg_118_6)
	local var_118_0 = arg_118_0.gamers
	local var_118_1 = arg_118_5.gameobjects
	local var_118_2 = gameplay_cameras.GameplayCameras(arg_118_1, arg_118_4, arg_118_2, arg_118_3, arg_118_6, arg_118_5, var_118_0, var_118_1)

	arg_118_0.gameplayCameras = var_118_2
	arg_118_2.gameplayCameras = var_118_2

	var_118_2:registerWithMatchSim(arg_118_5)
	arg_118_0:registerPauseListener(var_118_2)
end

function Universe.createCameoCamera(arg_119_0, arg_119_1, arg_119_2, arg_119_3, arg_119_4, arg_119_5)
	local var_119_0 = cameocamera.CameoCamera(arg_119_4)

	arg_119_0.cameoCamera = var_119_0
	arg_119_2.cameoCamera = var_119_0

	return var_119_0
end

function Universe.configureSideLinePlayerUniforms(arg_120_0, arg_120_1, arg_120_2, arg_120_3, arg_120_4)
	if native:getEnvironment():argExists("lowdetailcharacters") then
		return
	end

	local var_120_0
	local var_120_1
	local var_120_2 = sidehelper.home
	local var_120_3 = sidehelper.away

	for iter_120_0, iter_120_1 in arg_120_2:objects(playertype.TypeId) do
		local var_120_4 = arg_120_3:get(iter_120_0)

		if not var_120_0 and var_120_4.side == var_120_2 then
			var_120_0 = iter_120_1.actorModel.cricketVisual.uniformTextureName
		elseif not var_120_1 and var_120_4.side == var_120_3 then
			var_120_1 = iter_120_1.actorModel.cricketVisual.uniformTextureName
		end
	end

	if var_120_0 ~= nil and var_120_0 ~= "" and var_120_1 ~= nil and var_120_1 ~= "" then
		local var_120_5 = arg_120_1:getTextureManager()
		local var_120_6 = assert(var_120_5:get(var_120_0))
		local var_120_7 = assert(var_120_5:get(var_120_1))
		local var_120_8 = arg_120_4.count

		for iter_120_2 = 1, var_120_8 do
			local var_120_9 = arg_120_4:getAt(iter_120_2)
			local var_120_10 = var_120_9.name

			if stringx.startswith(var_120_10, "sidelineplayer_home/") then
				var_120_9:materialTexture("uniform", "col_map", var_120_6)
			elseif stringx.startswith(var_120_10, "sidelineplayer_away/") then
				var_120_9:materialTexture("uniform", "col_map", var_120_7)
			end
		end

		var_120_6:unload()
		var_120_7:unload()
	end
end

function Universe.onLoaded(arg_121_0, arg_121_1, arg_121_2)
	local var_121_0 = VERIFY(arg_121_0.matchSim)
	local var_121_1 = VERIFY(arg_121_0.config)
	local var_121_2 = VERIFY(arg_121_0.scene)
	local var_121_3 = VERIFY(arg_121_0.services)
	local var_121_4 = VERIFY(var_121_3.posePlayer)
	local var_121_5 = arg_121_0.processes
	local var_121_6 = arg_121_0.matchInData
	local var_121_7 = arg_121_0.match
	local var_121_8 = var_121_7:getComponent("matchOutData")
	local var_121_9 = var_121_0:getGameObjects()

	finalise.processFinaliseList(arg_121_0.finaliseList)
	arg_121_0.knowledge:onLoaded(arg_121_1, var_121_6, var_121_8, var_121_0, var_121_3, var_121_9)

	local var_121_10 = arg_121_1:getJobManager()

	var_121_5.movementControllerUpdateProcess:init(var_121_10)

	for iter_121_0, iter_121_1 in arg_121_0.gamers:iterLocalGamers() do
		formatPrint("[PLAYER SWITCHING] Gamer %s is on side %d.", tostring(iter_121_1:getGamerId()), iter_121_1.side)
	end

	arg_121_0.playerSwitching:registerWithMatchSim(var_121_0)
	arg_121_0:configureSideLinePlayerUniforms(arg_121_1, var_121_9, arg_121_0.pools.sidePool, arg_121_0.sceneRenderer.propScene)
	var_121_0:registerGameObjectListener({
		activateId = function(arg_122_0, arg_122_1, arg_122_2)
			VERIFY(arg_122_2.actorModel).visible = true

			arg_122_2:getAnimPlayer():activate()
			arg_122_2:getSkeletonModifier():activate()
		end,
		deactivateId = function(arg_123_0, arg_123_1, arg_123_2)
			formatPrint("Humanoid %d deactivated. Deactiving model visibility, animPlayer, skeletonModifier & wantLoaded", arg_123_1)

			VERIFY(arg_123_2.actorModel).visible = false

			arg_123_2:getAnimPlayer():deactivate()
			arg_123_2:getSkeletonModifier():deactivate()
		end
	}, humanoidtype.TypeId)

	if var_121_1.noumpires then
		for iter_121_2, iter_121_3 in var_121_9:objects(umpiretype.TypeId) do
			var_121_9:deactivateGameObject(iter_121_2)
		end
	end

	arg_121_0:initialiseFXEvents(arg_121_1, var_121_0, var_121_9, var_121_7)
	arg_121_0:initialiseBlinkEvents(arg_121_1, var_121_0, var_121_9, var_121_7)
end

function Universe.initialiseFXEvents(arg_124_0, arg_124_1, arg_124_2, arg_124_3, arg_124_4)
	local var_124_0 = arg_124_1:getParticleController()
	local var_124_1 = arg_124_4.matchInData.matchType
	local var_124_2 = {
		engine = arg_124_1,
		universe = arg_124_0,
		services = arg_124_0.services,
		matchsim = arg_124_2,
		gameObjects = arg_124_3
	}
	local var_124_3 = arg_124_0.services.soundSystem
	local var_124_4 = particleevents.GameEvents

	for iter_124_0, iter_124_1 in pairs(var_124_4) do
		arg_124_0:registerLocalTentativeEventListener(function(arg_125_0)
			local var_125_0 = iter_124_1.eventLogic and iter_124_1.eventLogic(arg_125_0, var_124_2) or nil

			var_124_0:eventHandler(var_125_0 or arg_125_0.type, arg_125_0.time or native.Time.ZeroTime(), var_124_3)
		end, iter_124_1.eventName)
	end

	local var_124_5 = arg_124_0.stadium.model.modelsList.fxSpawnLocators

	if var_124_5 then
		local var_124_6 = "rendering.particles.fx.fxSpawnLocators_t1_fx"
		local var_124_7 = loadTemp(var_124_6)

		var_124_0:getFXSystem():registerListenersForSkeleton(var_124_5.skeleton, VERIFY(var_124_7.events))
	end

	local var_124_8 = VERIFY(arg_124_0.stadium.propScene)

	local function var_124_9(arg_126_0)
		if arg_126_0.fxFile and arg_126_0.fxFile:len() ~= 0 then
			local var_126_0 = "rendering.particles.fx." .. arg_126_0.fxFile
			local var_126_1 = loadTemp(var_126_0)

			ASSERT(var_126_1.events)
			var_124_0:getFXSystem():registerListenersForSkeleton(arg_126_0.model.skeleton, VERIFY(var_126_1.events))
		end
	end

	var_124_8:forEachProp(var_124_9)

	local var_124_10 = particleevents.AnimationEvents

	for iter_124_2, iter_124_3 in arg_124_3:objects(playertype.TypeId) do
		for iter_124_4, iter_124_5 in pairs(var_124_10) do
			iter_124_3:registerAnimationEventListener(function(arg_127_0, arg_127_1, arg_127_2, arg_127_3)
				if iter_124_5.eventLogic then
					arg_127_0 = iter_124_5.eventLogic(arg_127_0, arg_127_1, arg_127_2, arg_127_3, var_124_2)
				end

				var_124_0:eventHandler(arg_127_0, arg_127_1, var_124_3)
			end, iter_124_5.eventName)
		end
	end

	table.insert(arg_124_0.sceneDisposalQueue, function()
		var_124_0:getFXSystem():dispose()
	end)
end

function Universe.initialiseBlinkEvents(arg_129_0, arg_129_1, arg_129_2, arg_129_3, arg_129_4)
	local function var_129_0(arg_130_0, arg_130_1, arg_130_2, arg_130_3)
		arg_130_3:getSkeletonModifier():blink(native.EBlinkSpeed.Fast)
	end

	local function var_129_1(arg_131_0, arg_131_1, arg_131_2, arg_131_3)
		arg_131_3:getSkeletonModifier():blink(native.EBlinkSpeed.Normal)
	end

	local function var_129_2(arg_132_0, arg_132_1, arg_132_2, arg_132_3)
		arg_132_3:getSkeletonModifier():blink(native.EBlinkSpeed.Slow)
	end

	for iter_129_0, iter_129_1 in arg_129_3:objects(playertype.TypeId) do
		iter_129_1:registerAnimationEventListener(var_129_0, "blink_fast")
		iter_129_1:registerAnimationEventListener(var_129_1, "blink_normal")
		iter_129_1:registerAnimationEventListener(var_129_2, "blink_slow")
	end
end

function Universe.startTimePeriod(arg_133_0, arg_133_1, arg_133_2)
	local var_133_0 = arg_133_0.matchSim
	local var_133_1 = arg_133_0:getMatch()
	local var_133_2 = var_133_1:getComponent("matchInfo")

	ASSERT(var_133_2.timePeriodStartKickOffDirection == 1 or var_133_2.timePeriodStartKickOffDirection == -1)

	local var_133_3 = var_133_2.timePeriodStartKickOffDirection
	local var_133_4 = endhelper.getEndString(var_133_3)
	local var_133_5 = endhelper.getOtherEnd(var_133_3)
	local var_133_6 = endhelper.getEndString(var_133_5)

	formatPrint("[DirectionOfPlay] Setting up team directions. matchInfo.timePeriodStartKickOffDirection = %d", var_133_2.timePeriodStartKickOffDirection)

	local var_133_7 = var_133_2.timePeriodStartKickOffSide == sidehelper.home and var_133_4 or var_133_6
	local var_133_8 = var_133_1:getHome()

	formatPrint("[DirectionOfPlay] Setting home team direction to %s", var_133_7)
	var_133_8:setDirection(var_133_7)

	local var_133_9 = var_133_2.timePeriodStartKickOffSide == sidehelper.away and var_133_4 or var_133_6
	local var_133_10 = var_133_1:getAway()

	formatPrint("[DirectionOfPlay] Setting away team direction to %s", var_133_9)
	var_133_10:setDirection(var_133_9)
	arg_133_0:broadcastMatchComponents("startTimePeriod", arg_133_2)

	local var_133_11 = var_133_0:getGameObjects()

	arg_133_0.knowledge:startTimePeriod(arg_133_1, var_133_1, arg_133_2, var_133_11)
end

function Universe.verifyInitialState(arg_134_0, arg_134_1)
	local var_134_0 = arg_134_0.packageValidationProcess

	if var_134_0 then
		var_134_0:onInitialState(arg_134_1)
	end
end

function Universe.acceptBarrier(arg_135_0, arg_135_1, arg_135_2)
	return arg_135_0.matchSim:acceptBarrier(arg_135_1, arg_135_2)
end

function Universe.waitForAllJobs(arg_136_0, arg_136_1)
	local var_136_0 = arg_136_1:getJobManager()

	arg_136_0.idleAndHitTargetJobGroup:wait(var_136_0)

	if arg_136_0.renderJobs.active then
		arg_136_0.renderJobs:get():waitForAll()
	end

	arg_136_0:waitPhysicsPredictionJobs(arg_136_1)
	arg_136_0.processes.impactDetectionProcess:wait()
	arg_136_0.processes.footContactUpdateProcess:wait()
	arg_136_0.processes.torsoContactUpdateProcess:wait()
	arg_136_0.knowledge:waitJobs(arg_136_1)
end

function Universe.preBarrierComplete(arg_137_0, arg_137_1, arg_137_2, arg_137_3, arg_137_4)
	arg_137_0.cameraManager:clearActiveCamera()
	tablex.mergeInto(arg_137_4, arg_137_0.updateParams)

	arg_137_4.systemTime = arg_137_2

	arg_137_0:waitForAllJobs(arg_137_1)
end

function Universe.onBarrierComplete(arg_138_0, arg_138_1, arg_138_2, arg_138_3, arg_138_4)
	local var_138_0 = arg_138_0.match
	local var_138_1 = arg_138_0.gamers
	local var_138_2 = arg_138_0.network
	local var_138_3 = arg_138_0.services

	arg_138_0.matchSim:onBarrierComplete(arg_138_0, arg_138_1, arg_138_2, arg_138_4, var_138_2, var_138_1, var_138_3, var_138_0, arg_138_3)
end

function Universe.postBarrierComplete(arg_139_0, arg_139_1, arg_139_2, arg_139_3)
	local var_139_0 = arg_139_0.network
	local var_139_1 = arg_139_0.services
	local var_139_2 = arg_139_0.match
	local var_139_3 = arg_139_0.gamers
	local var_139_4 = arg_139_0.matchSim
	local var_139_5 = var_139_4:getGameObjects()
	local var_139_6 = var_139_4:getGameState()

	arg_139_0.knowledge:kickJobs(arg_139_1, var_139_0, var_139_1, var_139_3, var_139_2, var_139_6, var_139_5, arg_139_2)
end

function Universe.unloadAnimationAssets(arg_140_0, arg_140_1)
	if arg_140_0.services.animsetLoader then
		arg_140_0.services.animsetLoader:unloadPending()
	end

	if arg_140_0.animationSets then
		for iter_140_0, iter_140_1 in pairs(arg_140_0.animationSets) do
			arg_140_0.animationProvider:removeAnimationSet(iter_140_1)
			arg_140_1:getAnimationManager():unload(iter_140_1)
		end

		arg_140_0.animationSets = nil
	end

	if arg_140_0.motionSet then
		if arg_140_0.motionSet.data then
			arg_140_0.motionSet.data:dispose()
		end

		arg_140_1:getMotionSetManager():unload(arg_140_0.motionSet)

		arg_140_0.motionSet = nil
		arg_140_0.services.motionSet = nil
	end

	if arg_140_0.cameoCamerasAnimSet then
		arg_140_0.cameoCameraAnimationProvider:removeAnimationSet(arg_140_0.cameoCamerasAnimSet)
		arg_140_1:getAnimationManager():unload(arg_140_0.cameoCamerasAnimSet)

		arg_140_0.cameoCamerasAnimSet = nil
	end

	if arg_140_0.actionSet then
		arg_140_1:getActionSetManager():unload(arg_140_0.actionSet)

		arg_140_0.actionSet = nil
		arg_140_0.services.actionSet = nil
	end

	if arg_140_0.collectSet then
		arg_140_1:getActionSetManager():unload(arg_140_0.collectSet)

		arg_140_0.collectSet = nil
		arg_140_0.services.collectSet = nil
	end

	if arg_140_0.strikeSet then
		arg_140_1:getActionSetManager():unload(arg_140_0.strikeSet)

		arg_140_0.strikeSet = nil
		arg_140_0.services.strikeSet = nil
	end

	if arg_140_0.tackleSet then
		arg_140_1:getActionSetManager():unload(arg_140_0.tackleSet)

		arg_140_0.tackleSet = nil
		arg_140_0.services.tackleSet = nil
	end

	if arg_140_0.trySet then
		arg_140_1:getActionSetManager():unload(arg_140_0.trySet)

		arg_140_0.trySet = nil
		arg_140_0.services.trySet = nil
	end

	if arg_140_0.playTheBallSet then
		arg_140_1:getActionSetManager():unload(arg_140_0.playTheBallSet)

		arg_140_0.playTheBallSet = nil
		arg_140_0.services.playTheBallSet = nil
	end

	if arg_140_0.placeKickSet then
		arg_140_1:getActionSetManager():unload(arg_140_0.placeKickSet)

		arg_140_0.placeKickSet = nil
		arg_140_0.services.placeKickSet = nil
	end

	if arg_140_0.kickSet then
		arg_140_1:getActionSetManager():unload(arg_140_0.kickSet)

		arg_140_0.kickSet = nil
		arg_140_0.services.kickSet = nil
	end

	if arg_140_0.scrumSet then
		arg_140_1:getActionSetManager():unload(arg_140_0.scrumSet)

		arg_140_0.scrumSet = nil
		arg_140_0.services.scrumSet = nil
	end

	if arg_140_0.contestSet then
		arg_140_1:getActionSetManager():unload(arg_140_0.contestSet)

		arg_140_0.contestSet = nil
		arg_140_0.services.contestSet = nil
	end

	if arg_140_0.cheerleaderMotionSet then
		if arg_140_0.cheerleaderMotionSet.data then
			arg_140_0.cheerleaderMotionSet.data:dispose()
		end

		arg_140_1:getMotionSetManager():unload(arg_140_0.cheerleaderMotionSet)

		arg_140_0.cheerleaderMotionSet = nil
	end

	if arg_140_0.animUnits then
		arg_140_1:getAnimUnitManager():unload(arg_140_0.animUnits)

		arg_140_0.animUnits = nil
		arg_140_0.services.animUnits = nil
	end
end

function Universe.disposeNetwork(arg_141_0)
	local var_141_0 = arg_141_0.config

	assert(var_141_0.destructNetwork)
	arg_141_0.network:deinit()

	arg_141_0.network = nil

	for iter_141_0, iter_141_1 in pairs(arg_141_0.createdConnections) do
		iter_141_1:dispose()
	end

	arg_141_0.createdConnections = nil
end

function Universe.unload(arg_142_0, arg_142_1)
	print("Universe:unload() called")
	native.printMiniStack("Universe:unload")

	local var_142_0 = arg_142_0.services

	var_142_0.universeUnloading = true

	local var_142_1 = arg_142_0.scene
	local var_142_2 = arg_142_1:getRenderInterface()

	if arg_142_0.crowd then
		arg_142_0.crowd:dispose()
	end

	if arg_142_0.levelInstanceTexturePack then
		arg_142_0.levelInstanceTexturePack:unload()

		arg_142_0.levelInstanceTexturePack = nil
	end

	arg_142_0:disposeBallPredictionQueries()

	if arg_142_0.ballPredictionSystem then
		arg_142_0.ballPredictionSystem = nil
		var_142_0.ballPredictionSystem = nil
	end

	arg_142_0:disposePhysicsJobs(arg_142_1, VERIFY(arg_142_0.ballObject))

	if var_142_0.outOfFrameRequestGatherer then
		var_142_0.outOfFrameRequestGatherer:dispose()
	end

	if var_142_0.cutsceneListener then
		local var_142_3 = arg_142_0.matchSim:getGameObjects()

		var_142_0.cutsceneListener:dispose({
			scene = var_142_1,
			engine = arg_142_1,
			gameobjects = var_142_3
		}, var_142_0)
	end

	local var_142_4 = arg_142_0.matchSim
	local var_142_5 = arg_142_0.match
	local var_142_6 = arg_142_0.gamers
	local var_142_7 = {
		universe = arg_142_0,
		network = arg_142_0.network,
		ccamera = arg_142_0.ccamera
	}

	tablex.mergeInto(var_142_7, arg_142_0.updateParams)

	local var_142_8 = var_142_4:getSimulationTime()

	var_142_4:exitCurrentRuleState(var_142_7, var_142_6, var_142_0, var_142_5, var_142_8)

	local var_142_9 = arg_142_0.packageValidationProcess

	if var_142_9 then
		var_142_9:dispose()
	end

	if arg_142_0.challengesSystem then
		arg_142_0.challengesSystem:dispose(arg_142_1)
	end

	if arg_142_0.objectivesSystem then
		arg_142_0.objectivesSystem:dispose(arg_142_1)
	end

	if arg_142_0.soundSystem then
		arg_142_0.soundSystem:unload(arg_142_1)
	end

	if arg_142_0.gameplayAnalytics then
		arg_142_0.gameplayAnalytics:dispose()
	end

	if arg_142_0.serverMatchSystem then
		arg_142_0.serverMatchSystem:dispose()
	end

	if arg_142_0.excitementLevelSystem then
		arg_142_0.excitementLevelSystem:unload()
	end

	if arg_142_0.vibrationSystem then
		arg_142_0.vibrationSystem:dispose()
	end

	if not arg_142_0.characterManager:canDispose() then
		print("WARNING: Disposing of character manager synchronously while jobs are in progress")
		arg_142_0.characterManager:wait(arg_142_1:getTextureCompositor(), arg_142_1:getGpuTaskService())
	end

	if arg_142_0.posePlayer then
		arg_142_0.posePlayer:dispose()
	end

	playerobject.unloadPreloadedAssets(arg_142_1, arg_142_0.preloadedCharacterAssets)

	local var_142_10 = arg_142_0.scenarioRegister

	if var_142_10 then
		var_142_10:disposeControllers()
	end

	local var_142_11 = arg_142_0.gameControllerSet

	if var_142_11 then
		local var_142_12 = VERIFY(arg_142_0.matchSim)
		local var_142_13 = VERIFY(var_142_12:getGameObjects())
		local var_142_14 = VERIFY(arg_142_0.gamers)
		local var_142_15 = arg_142_0:getGameState()
		local var_142_16
		local var_142_17 = var_142_12:getSimulationTime()
		local var_142_18 = {}
		local var_142_19 = VERIFY(var_142_0.guidManager)

		var_142_11:reset(var_142_18, var_142_14, var_142_0, var_142_19, match, var_142_15, var_142_13, var_142_17, var_142_16)
	end

	local var_142_20 = arg_142_0.thumbnailRenderer

	if var_142_20 then
		var_142_20:dispose(arg_142_1)

		arg_142_0.thumbnailRenderer = nil
	end

	if arg_142_0.blankUniverseTexture then
		arg_142_0.blankUniverseTexture:unload()
	end

	if arg_142_0.screenWipeFactory then
		arg_142_0.screenWipeFactory:dispose()
	end

	if arg_142_0.dbCheck then
		arg_142_0.dbCheck:verify()
	end

	if arg_142_0.gamers then
		arg_142_0.gamers:deinitialise(arg_142_1)
	end

	arg_142_0.universeStateStack:dispose(arg_142_0, arg_142_1)

	local var_142_21 = arg_142_0.services.hooks
	local var_142_22 = var_142_21 and var_142_21:getHook("ReplayDebugHook")

	if var_142_22 then
		var_142_22:setReplayManager(nil)
	end

	if arg_142_0.replaySaveSystem then
		arg_142_0.replaySaveSystem:dispose()
	end

	if arg_142_0.replayManager then
		arg_142_0.replayManager:dispose()
	end

	if arg_142_0.replayManagerSharedRingBuffer then
		arg_142_0.replayManagerSharedRingBuffer:dispose()
	end

	if arg_142_0.post then
		arg_142_0.post:dispose()
	end

	if arg_142_0.matchSim then
		arg_142_0.matchSim:dispose(arg_142_1)
	end

	local var_142_23 = arg_142_0.pools

	var_142_23.gamerControlStatePool = nil

	if arg_142_0.knowledge then
		arg_142_0.knowledge:dispose(arg_142_1)
	end

	if arg_142_0.match then
		arg_142_0.match:dispose(arg_142_1)
	end

	local var_142_24 = arg_142_0.stadium

	var_142_24:dispose(arg_142_1)
	ASSERT(var_142_24.propScene == nil)

	local var_142_25 = var_142_23.playerCollisionHandlePool

	if var_142_25 then
		var_142_25:clear()
	end

	if arg_142_0.ballLoadContext then
		arg_142_0.ballLoadContext:dispose(arg_142_1)
	end

	arg_142_0.playerMarkerLoadContext:dispose(arg_142_1)

	local var_142_26 = arg_142_0.ballMarkerLoadContextTable

	if var_142_26 then
		for iter_142_0, iter_142_1 in pairs(var_142_26) do
			iter_142_1:dispose(arg_142_1)
		end
	end

	if arg_142_0.trails then
		arg_142_0.trails:dispose(var_142_2)
	end

	if arg_142_0.goalPostsCollisionShapeSet then
		arg_142_0.goalPostsCollisionShapeSet:destroy()
	end

	if arg_142_0.collisionShapeSet then
		arg_142_0.collisionShapeSet:destroy()
	end

	local var_142_27 = var_142_23.ballPredictionQueryPool

	if var_142_27 then
		for iter_142_2, iter_142_3 in var_142_27:iter() do
			iter_142_3:dispose()
		end

		var_142_27:clear()
	end

	if arg_142_0.processes.windIndicatorProcess then
		arg_142_0.processes.windIndicatorProcess:dispose()

		arg_142_0.processes.windIndicatorProcess = nil
	end

	if arg_142_0.physicsScene then
		arg_142_0.processes.ballPlayerCollisionProcess:dispose()
		arg_142_0.processes.playerCollisionBumpProcess:dispose()

		arg_142_0.services.physicsScene = nil

		arg_142_0.physicsScene:dispose()

		arg_142_0.physicsScene = nil
	end

	local var_142_28 = arg_142_1:getCollisionBlobLoader()

	if var_142_28 then
		for iter_142_4, iter_142_5 in pairs(arg_142_0.propCollisionSets) do
			var_142_28:unload(iter_142_5)
		end

		arg_142_0.propCollisionSets = nil

		if arg_142_0.goalPostsCollisionSet then
			var_142_28:unload(arg_142_0.goalPostsCollisionSet)
		end

		if arg_142_0.collisionSet then
			var_142_28:unload(arg_142_0.collisionSet)
		end
	end

	if var_142_0.moveableKickingTee then
		var_142_0.moveableKickingTee:dispose()

		var_142_0.moveableKickingTee = nil
	end

	if var_142_0.kickingTee then
		var_142_0.kickingTee:dispose()

		var_142_0.kickingTee = nil
	end

	native.CPhysicsPropDefs.dispose()

	arg_142_0.animationGroupService = nil

	arg_142_0:unloadAnimationAssets(arg_142_1)

	if arg_142_0.trajectoryLines then
		arg_142_0.trajectoryLines:dispose()
	end

	if arg_142_0.playSet then
		arg_142_1:getPlaySetManager():unload(arg_142_0.playSet)

		arg_142_0.playSet = nil
		arg_142_0.services.playSet = nil
	end

	if arg_142_0.formationSet then
		arg_142_1:getPlaySetManager():unload(arg_142_0.formationSet)

		arg_142_0.formationSet = nil
		arg_142_0.services.playSet = nil
	end

	if arg_142_0.playSetContainer then
		arg_142_0.playSetContainer = nil
		arg_142_0.services.playSetContainer = nil
	end

	if arg_142_0.naturalMovementSetData then
		arg_142_1:getNaturalMovementManager():unload(arg_142_0.naturalMovementSetData)

		arg_142_0.naturalMovementSet = nil
		arg_142_0.services.naturalMovementSet = nil
		arg_142_0.naturalMovementSetData = nil
		arg_142_0.services.naturalMovementSetData = nil
	end

	arg_142_0.animationProvider = nil
	arg_142_0.services.animationProvider = nil

	arg_142_0:unloadCutsceneProps(arg_142_1)

	arg_142_0.weather = nil

	if arg_142_0.processes.movementControllerUpdateProcess then
		arg_142_0.processes.movementControllerUpdateProcess:dispose()

		arg_142_0.processes.movementControllerUpdateProcess = nil
	end

	if arg_142_0.pools.movementHistoryPool then
		native.CMovementHistory.freePool(arg_142_0.pools.movementHistoryPool)

		arg_142_0.pools.movementHistoryPool = nil
	end

	if arg_142_0.processes.motionPathAvoidanceSelectionUpdateProcess then
		arg_142_0.processes.motionPathAvoidanceSelectionUpdateProcess = nil
	end

	local var_142_29 = var_142_23.actorSubmeshVisibilityPool

	if var_142_29 then
		var_142_29:clear()
	end

	local var_142_30 = var_142_23.actorModelPool

	if var_142_30 then
		for iter_142_6, iter_142_7 in var_142_30:iter() do
			iter_142_7:dispose()
		end

		var_142_30:clear()
	end

	local var_142_31 = var_142_23.gearVisualPool

	if var_142_31 then
		for iter_142_8, iter_142_9 in var_142_31:iter() do
			iter_142_9:dispose()
		end

		var_142_31:clear()
	end

	local var_142_32 = var_142_23.secondaryGearVisualPool

	if var_142_32 then
		for iter_142_10, iter_142_11 in var_142_32:iter() do
			iter_142_11:dispose()
		end

		var_142_32:clear()
	end

	local var_142_33 = var_142_23.skeletonModifierPool

	if var_142_33 then
		for iter_142_12, iter_142_13 in var_142_33:iter() do
			iter_142_13:dispose()
		end

		var_142_33:clear()
	end

	local var_142_34 = var_142_23.playerAnimationPool

	if var_142_34 then
		for iter_142_14, iter_142_15 in var_142_34:iter() do
			iter_142_15:dispose()
		end

		var_142_34:clear()
	end

	arg_142_0.characterManager = arg_142_0.characterManager and arg_142_0.characterManager:dispose() or nil

	local var_142_35 = arg_142_0.uniformDecorator

	if var_142_35 then
		var_142_35:dispose()

		arg_142_0.uniformDecorator = nil
	end

	if arg_142_0.pitch then
		arg_142_0.pitch:dispose()

		arg_142_0.pitch = nil
	end

	if arg_142_0.config.destructNetwork then
		arg_142_0:disposeNetwork()
	end

	local var_142_36 = arg_142_0.ingameTexturePack

	if var_142_36 then
		var_142_36:unload()

		arg_142_0.ingameTexturePack = nil
	end

	local var_142_37 = arg_142_0.particleTexturePack

	if var_142_37 then
		var_142_37:unload()

		arg_142_0.particleTexturePack = nil
	end

	if arg_142_0.hud then
		arg_142_0.hud:dispose(arg_142_1)
	end

	var_142_0.animationProvider = nil
	arg_142_0.animationProvider = nil

	if arg_142_0.fieldSponsorTexture then
		arg_142_0.fieldSponsorTexture:unload()

		arg_142_0.fieldSponsorTexture = nil
	end

	arg_142_0.levelData = nil

	if arg_142_0.processes.naturalMovementUpdateProcess then
		arg_142_0.processes.naturalMovementUpdateProcess:dispose()
	end

	if arg_142_0.processes.playHUDProcess then
		arg_142_0.processes.playHUDProcess:dispose()
	end

	local var_142_38 = arg_142_0.sceneDisposalQueue

	if var_142_38 then
		for iter_142_16 = #var_142_38, 1, -1 do
			var_142_38[iter_142_16](arg_142_1)
		end

		arg_142_0.sceneDisposalQueue = nil
	end

	arg_142_1:getParticleController():deinit(arg_142_1:getRenderInterface())
	arg_142_0.renderJobs:deinit(arg_142_1)
	arg_142_0.scene:dispose(arg_142_1)

	arg_142_0.scene = nil
	arg_142_0.matchInData = nil

	local var_142_39 = var_142_21 and var_142_21:getHook("PassingDebugHook")

	if var_142_39 then
		var_142_39:dispose()
	end

	local var_142_40 = var_142_21 and var_142_21:getHook("AnimationHistoryDebugHook")

	if var_142_40 then
		var_142_40:dispose()
	end

	tablex.clear(arg_142_0.services)

	if arg_142_0.processes.controllerUpdateProcess then
		arg_142_0.processes.controllerUpdateProcess:dispose()
	end

	if arg_142_0.processes.animationSequenceProcess then
		arg_142_0.processes.animationSequenceProcess:dispose()
	end

	if arg_142_0.processes.blendAnimationSequenceProcess then
		arg_142_0.processes.blendAnimationSequenceProcess:dispose()
	end

	if arg_142_0.processes.actionCallbackProcess then
		arg_142_0.processes.actionCallbackProcess:dispose()
	end

	if arg_142_0.processes.blendActionCallbackProcess then
		arg_142_0.processes.blendActionCallbackProcess:dispose()
	end

	if arg_142_0.processes.blendControllerUpdateProcess then
		arg_142_0.processes.blendControllerUpdateProcess:dispose()
	end

	for iter_142_17, iter_142_18 in pairs(var_142_23) do
		if iter_142_18.clear then
			iter_142_18:clear()
		end
	end

	tablex.clear(var_142_23)
	native.CBlendCommandBucket.finalisePool()
	native.CBodyCommandBucket.finalisePool()
	print("Universe:unload() finished")
end

function Universe.updateNetworkRecv(arg_143_0, arg_143_1, arg_143_2, arg_143_3)
	profile.push("(updateNetworkRecv)")

	local var_143_0 = arg_143_0.network
	local var_143_1 = var_143_0:initiated()
	local var_143_2 = var_143_0.error
	local var_143_3 = var_143_1 and not var_143_2
	local var_143_4 = arg_143_1:getParty():getPrimaryPartyMember()
	local var_143_5 = var_143_4 and var_143_4:isSignedInOnline()

	if arg_143_0.ownNetwork and var_143_1 then
		profile.push("(network update)")
		var_143_0:update(arg_143_2, arg_143_3)
		profile.pop("(network update)")
	end

	if arg_143_0.onlineMultiplayer and not arg_143_0.networkErrorOccurred then
		local var_143_6 = var_143_2 and true or false
		local var_143_7 = var_143_0:machineCount() < 2
		local var_143_8 = not var_143_5

		if var_143_7 or var_143_6 or var_143_8 then
			if arg_143_0.packageValidationProcess and arg_143_0.packageValidationProcess:isGameStateBroken() then
				arg_143_0.packageValidationProcess:update(arg_143_2, arg_143_3)
			else
				formatPrintT("Network error occurred: dcMachineCountError: %t, dcNetworkError: %t, dcOnlineError: %t, networkError: %t", var_143_7, var_143_6, var_143_8, var_143_2)
				arg_143_0:onDisconnectOccurred(arg_143_1)
			end
		elseif arg_143_0.matchSim:getPackageManagerError() then
			var_143_0:forceErrorState()
		end
	end

	if var_143_3 then
		profile.push("(network updateReceive)")
		var_143_0:updateReceive(arg_143_2, arg_143_3)

		if var_143_0:receive("OfferForfeit") then
			arg_143_0:receiveForfeitMessage()
		end

		profile.pop("(network updateReceive)")
	end

	profile.pop("(updateNetworkRecv)")
end

function Universe.update(arg_144_0, arg_144_1, arg_144_2, arg_144_3, arg_144_4, arg_144_5, arg_144_6, arg_144_7)
	profile.push("Universe.update")

	local var_144_0 = arg_144_0:getRenderDt(arg_144_2)

	arg_144_0:updateShaderGameTime(var_144_0)
	arg_144_0.NVMJumbotron:update()

	local var_144_1 = arg_144_1:getRenderInterface()
	local var_144_2 = arg_144_0.processes.ingameCharacterStreamingProcess
	local var_144_3 = var_144_1:getImmediateContext()

	arg_144_1:getParticleController():updateGC()

	local var_144_4 = arg_144_0.wasWipe

	arg_144_0.wasWipe = false
	arg_144_0.renderDt = var_144_0
	arg_144_0.realDt = arg_144_2

	local var_144_5 = arg_144_0.services

	var_144_5.skipStateProvider:update(arg_144_0.hud)

	local var_144_6 = not arg_144_5
	local var_144_7 = arg_144_0.gamers

	var_144_7:setInputEnabled(arg_144_5)
	profile.push("(input update)")

	for iter_144_0, iter_144_1 in pairs(arg_144_0.inputs) do
		iter_144_1:update(arg_144_2)
	end

	profile.pop("(input update)")

	local var_144_8 = arg_144_0.matchSim
	local var_144_9 = var_144_8:getGameState()
	local var_144_10 = var_144_8:getGameObjects()
	local var_144_11 = var_144_8:getSimulationTime()

	profile.push("(gamers update)")
	var_144_7:update(arg_144_2)
	profile.pop("(gamers update)")

	local var_144_12 = arg_144_0.scene
	local var_144_13 = arg_144_0.ccamera
	local var_144_14 = arg_144_0.network

	profile.push("(gameobjects updateActivationRequests)")
	var_144_10:updateActivationRequests()
	profile.pop("(gameobjects updateActivationRequests)")

	local var_144_15 = arg_144_0.packageValidationProcess

	if var_144_15 then
		local var_144_16 = var_144_8.simulation.solidState

		profile.push("(packageValidationProcess receiveMessages)")
		var_144_15:receiveMessages(var_144_14, var_144_16, arg_144_3)
		profile.pop("(packageValidationProcess receiveMessages)")
		profile.push("(packageValidationProcess validate)")
		var_144_15:validate(var_144_14, var_144_16, arg_144_3)
		profile.pop("(packageValidationProcess validate)")
		profile.push("(packageValidationProcess update)")
		var_144_15:update(arg_144_2, arg_144_3)
		profile.pop("(packageValidationProcess update)")
		profile.push("(packageValidationProcess sendMessages)")
		var_144_15:sendMessages(var_144_14)
		profile.pop("(packageValidationProcess sendMessages)")
	end

	arg_144_0:updateNetworkRecv(arg_144_1, arg_144_2, arg_144_3)
	arg_144_0.serverMatchSystem:update(arg_144_1, var_144_5.uiServices, arg_144_2, var_144_11, arg_144_0.match, var_144_9)
	profile.push("(universeStateStack update)")
	arg_144_0.universeStateStack:update(arg_144_0, arg_144_1, var_144_14, var_144_13, arg_144_2, arg_144_3, arg_144_4, var_144_6, arg_144_6, arg_144_7)
	profile.pop("(universeStateStack update)")

	local var_144_17 = arg_144_0.pools.actorModelPool

	native.CActorModel.update(var_144_3, var_144_17)
	arg_144_0:updateUpdateables(arg_144_1, arg_144_2, arg_144_3)
	profile.pop("Universe.update")
end

function Universe.beginReplayPlayback(arg_145_0, arg_145_1)
	printMiniStack("[Replay] beginning replay playback")
	ASSERT(not arg_145_0.replayHumanoidIdList)
	ASSERT(not arg_145_0.replayPlayerIdList)
	ASSERT(not arg_145_0.replayUmpireIdList)

	local var_145_0 = native.CIdList()
	local var_145_1 = native.CIdList()
	local var_145_2 = VERIFY(arg_145_0:getGameObjects())

	for iter_145_0, iter_145_1 in arg_145_1:iter() do
		local var_145_3 = var_145_2:getGameObject(iter_145_1)

		if var_145_3:isType(playertype.TypeId) then
			var_145_0:insert(iter_145_1)
		end

		if var_145_3:isType(umpiretype.TypeId) then
			var_145_1:insert(iter_145_1)
		end
	end

	arg_145_0.replayHumanoidIdList = arg_145_1
	arg_145_0.replayPlayerIdList = var_145_0
	arg_145_0.replayUmpireIdList = var_145_1

	if arg_145_0.processes.playerForesightProcess then
		arg_145_0.processes.playerForesightProcess:setInReplay(true)
	end
end

function Universe.endReplayPlayback(arg_146_0)
	printMiniStack("[Replay] ending replay playback")

	if arg_146_0.processes.playerForesightProcess then
		arg_146_0.processes.playerForesightProcess:setInReplay(false)
	end

	arg_146_0.replayHumanoidIdList = nil
	arg_146_0.replayPlayerIdList = nil
	arg_146_0.replayUmpireIdList = nil
end

function Universe.updateMatchSim(arg_147_0, arg_147_1, arg_147_2, arg_147_3, arg_147_4, arg_147_5, arg_147_6)
	profile.push("Universe.updateMatchSim")

	arg_147_0.timeFactor = arg_147_4

	local var_147_0 = arg_147_0.network
	local var_147_1 = arg_147_0.matchSim
	local var_147_2 = arg_147_0.services
	local var_147_3 = var_147_0:sessionTime()
	local var_147_4 = var_147_1:updateSimulationTime(var_147_3, arg_147_4, var_147_2.hooks)
	local var_147_5 = var_147_4.frameStartTime
	local var_147_6 = var_147_4.frameEndTime
	local var_147_7 = var_147_4.dt:ToSeconds()
	local var_147_8 = var_147_4.importantSimTime
	local var_147_9 = var_147_4.missedImportantSimTime
	local var_147_10 = arg_147_0.gamers
	local var_147_11 = arg_147_0.ccamera
	local var_147_12 = arg_147_0.match
	local var_147_13 = arg_147_0
	local var_147_14 = var_147_1:getGameObjects()
	local var_147_15 = arg_147_0.processes
	local var_147_16 = arg_147_0.batConfig
	local var_147_17 = arg_147_0.ballObject
	local var_147_18 = arg_147_0.pools

	ASSERT(not arg_147_0.replayHumanoidIdList)
	ASSERT(not arg_147_0.replayPlayerIdList)
	ASSERT(not arg_147_0.replayUmpireIdList)

	local var_147_19 = arg_147_0.playerIdList
	local var_147_20 = arg_147_0.humanoidIdList
	local var_147_21 = arg_147_0.umpireIdList
	local var_147_22 = var_147_0.participantId
	local var_147_23 = arg_147_0.animationProvider
	local var_147_24 = var_147_2.guidManager
	local var_147_25 = arg_147_0.knowledge
	local var_147_26 = var_147_25.knowledgeBank
	local var_147_27 = native.getFrameNumber()

	var_147_18.frameKnowledge.frameNumber = var_147_27

	local var_147_28 = arg_147_0.updateParams

	var_147_28.systemTime = arg_147_3
	var_147_28.disableInput = arg_147_5
	var_147_28.universe = var_147_13

	local var_147_29

	var_147_1:addOutOfFrameRequests(var_147_28, var_147_10, var_147_2, var_147_24, var_147_12, var_147_0, var_147_5)

	local var_147_30, var_147_31, var_147_32 = var_147_1:beginPackage(var_147_0, var_147_5)

	profile.push("(knowledge waitSingleBufferedCopies)")
	var_147_25:waitSingleBufferedCopies(arg_147_1)
	profile.pop("(knowledge waitSingleBufferedCopies)")
	profile.push("(matchSim advanceSolidState)")

	local var_147_33, var_147_34 = var_147_1:advanceSolidState(var_147_13, arg_147_1, var_147_28, var_147_10, var_147_2, var_147_12, var_147_14, var_147_5, var_147_30)

	profile.pop("(matchSim advanceSolidState)")

	if var_147_34 then
		var_147_1:endPackage(var_147_0, var_147_5, true)

		var_147_30, var_147_31, var_147_32 = var_147_1:beginPackage(var_147_0, var_147_5)
	end

	local var_147_35 = 0
	local var_147_36 = 0
	local var_147_37 = {}

	profile.push("(matchSim advanceTentativeState)")

	local var_147_38 = var_147_1:advanceTentativeState(var_147_5, var_147_33)

	profile.pop("(matchSim advanceTentativeState)")
	profile.push("(outOfFrameRequestGatherer)")
	var_147_2.outOfFrameRequestGatherer:update(var_147_28, var_147_10, var_147_2, var_147_24, var_147_12, var_147_38, var_147_14, var_147_7, var_147_5, var_147_30)
	profile.pop("(outOfFrameRequestGatherer)")
	profile.push("(knowledge waitJobs)")
	arg_147_0:waitForAllJobs(arg_147_1)
	arg_147_0:waitBallPredictionQueries(var_147_38, var_147_14, var_147_30)
	profile.pop("(knowledge waitJobs)")
	profile.push("(queryManager wait)")
	arg_147_0.queryManager:wait(var_147_38, var_147_30)
	profile.pop("(queryManager wait)")

	local var_147_39 = var_147_23

	if var_147_39 then
		var_147_39:update()
	end

	local var_147_40 = arg_147_0.idleAndHitTargetJobGroup
	local var_147_41 = arg_147_1:getJobManager()
	local var_147_42 = var_147_41:getDefaultJobQueue(0)
	local var_147_43 = var_147_40:allocateTag(var_147_42)

	var_147_15.idleSelectionProcess:kick(var_147_20, var_147_7, var_147_0, var_147_41, var_147_43, var_147_38:getIdleSelectionContextPool(), var_147_38:getIdleSequencePool())
	var_147_15.movementControllerUpdateProcess:kickHitTargetJobs(var_147_43)
	var_147_40:pushReleaseTag(var_147_42, "idleAndHitTargetJobGroup - ReleaseTag")
	profile.push("(knowledge update)")
	var_147_25:update(var_147_19, var_147_21, var_147_18, arg_147_1, var_147_0, var_147_10, var_147_12, var_147_38, var_147_14, var_147_5, var_147_30, var_147_31)
	profile.pop("(knowledge update)")

	local var_147_44 = arg_147_0.cameoCameraAnimationProvider

	if var_147_44 then
		var_147_44:update()
	end

	profile.push("(gameControllerSet update)")
	arg_147_0.gameControllerSet:update(var_147_28, var_147_10, var_147_2, var_147_24, var_147_12, var_147_38, var_147_14, var_147_7, var_147_5, var_147_30)
	profile.pop("(gameControllerSet update)")
	var_147_15.updateTacklePreferenceListProcess:update()
	var_147_15.updatePlaysPreferenceListProcess:update()

	local var_147_45 = var_147_38:getAuthorityInfoPool()

	var_147_15.idleSelectionProcess:wait()
	var_147_15.idleSelectionProcess:generateRequests(var_147_20, var_147_0.participantId, var_147_45, var_147_5, var_147_30, var_147_31)

	local var_147_46 = var_147_30:applyRequests(var_147_5, var_147_38, var_147_37, var_147_32, 0, var_147_35, false)
	local var_147_47 = var_147_31:applyRequests(var_147_5, var_147_38, var_147_37, var_147_32, 0, var_147_36, true)

	profile.push("(ballObject processEvents)")
	var_147_17:processEvents(var_147_38:getPhysicsEntity(), var_147_38:getBallEntity(), var_147_2, var_147_24, var_147_38, var_147_14, var_147_5, var_147_30, var_147_31)

	local var_147_48 = var_147_30:applyRequests(var_147_5, var_147_38, var_147_37, var_147_32, 0, var_147_46, false)
	local var_147_49 = var_147_31:applyRequests(var_147_5, var_147_38, var_147_37, var_147_32, 0, var_147_47, true)

	profile.pop("(ballObject processEvents)")

	local var_147_50 = var_147_30:applyRequests(var_147_5, var_147_38, var_147_37, var_147_32, 0, var_147_48, false)
	local var_147_51 = var_147_30:applyRequests(var_147_5, var_147_38, var_147_37, var_147_32, 0, var_147_50, false)

	if arg_147_0:hasArbitratorAuthority(var_147_0, var_147_38, var_147_5) then
		profile.push("(matchSim updateArbitrators)")
		var_147_1:updateArbitrators(var_147_10, var_147_2, var_147_24, var_147_12, var_147_38, var_147_14, var_147_5, var_147_7, var_147_30)
		profile.pop("(matchSim updateArbitrators)")
	end

	profile.push("(updateGamerSides)")
	var_147_10:updateGamerSides(var_147_38)
	profile.pop("(updateGamerSides)")
	profile.push("(pre controller update)")

	local var_147_52 = var_147_30:applyRequests(var_147_5, var_147_38, var_147_37, var_147_32, 0, var_147_51, false)

	var_147_10:pointGamersToObjects(var_147_38, var_147_0, var_147_5)
	var_147_15.authoritySetProcess:update(var_147_0.participantId, var_147_45)
	profile.pop("(pre controller update)")

	local var_147_53 = var_147_26.inPlayInfoPool
	local var_147_54 = var_147_38:getTeamSubstitutionEntityPair()
	local var_147_55 = var_147_26.teamSubstitutionDecisionKnowledgePair

	ASSERT(var_147_55)

	local var_147_56 = arg_147_0.matchInData

	ASSERT(var_147_56)

	local var_147_57 = var_147_56.matchType

	ASSERT(var_147_57)

	local var_147_58 = var_147_18.sidePool
	local var_147_59 = var_147_18.authoritySet

	ASSERT(var_147_59)

	local var_147_60 = var_147_38:getTeamFormationEntityPair()

	ASSERT(var_147_60)
	var_147_15.substitutionProcess:update(var_147_54, var_147_55, var_147_60, var_147_57, var_147_53, var_147_58, var_147_59, var_147_30)
	profile.push("(offside)")

	local var_147_61 = var_147_26.playTheBallKnowledge
	local var_147_62 = var_147_26.boundaryConfig
	local var_147_63 = var_147_26.tackleMarkerConfig
	local var_147_64 = var_147_2.primaryPartyMemberSettings

	ASSERT(var_147_64)
	var_147_15.attackingPlayerOffsideProcess:update(var_147_19, var_147_38, var_147_18.offsidePositionPool, var_147_53, var_147_18.playerMarkerInfoPool, var_147_61, var_147_30, var_147_5)
	var_147_15.defendingPlayerOffsideProcess:update(var_147_19, var_147_38, var_147_18.offsidePositionPool, var_147_53, var_147_18.playerMarkerInfoPool, var_147_61, var_147_62, var_147_63, var_147_30, var_147_5, var_147_57, var_147_64)
	profile.pop("(offside)")
	profile.push("(update controller processes)")
	var_147_15.gamerContextProcess:update(var_147_19, var_147_5, var_147_2.party)
	var_147_15.flowchartConditionInstanceMergeProcess:update()
	var_147_15.populateFlowchartFlagsProcess:update(var_147_19, var_147_5)
	var_147_15.blendPopulateFlowchartFlagsProcess:update(var_147_19, var_147_5)
	var_147_15.behaviourTableSelectProcess:update(var_147_19, var_147_21)
	var_147_15.movementFlowchartTypeSelectProcess:update(var_147_20, var_147_38)
	var_147_15.preferredMotionProfileSelectProcess:update(var_147_20, var_147_38)
	var_147_15.naturalMovementProfileSelectionProcess:update(var_147_20, var_147_38)
	var_147_15.lookAtConfigSelectProcess:update(var_147_20, var_147_38)
	var_147_15.controllerSelectProcess:update(var_147_20, var_147_38)
	var_147_15.controllerUpdateProcess:update(var_147_20, var_147_10, var_147_2, var_147_24, var_147_12, arg_147_0.forceReenterControllers, var_147_38, var_147_14, var_147_2.cKnowledgeBank, var_147_2.cPools, var_147_7, var_147_5, var_147_30)
	var_147_15.naturalMovementUpdateProcess:beginUpdate(var_147_20, var_147_38, var_147_5, var_147_0.participantId)
	var_147_15.humanMovementUpdateProcess:update(var_147_19, var_147_38, var_147_24, var_147_5, var_147_45, var_147_0.participantId, var_147_2, var_147_30, var_147_31)
	var_147_15.blendBehaviourTableSelectProcess:update(var_147_19, var_147_21)
	var_147_15.blendControllerSelectProcess:update(var_147_20, var_147_38)
	var_147_15.blendControllerUpdateProcess:update(var_147_20, var_147_10, var_147_2, var_147_24, var_147_12, arg_147_0.forceReenterControllers, var_147_38, var_147_14, var_147_2.cKnowledgeBank, var_147_2.cPools, var_147_7, var_147_5, var_147_30)
	var_147_15.naturalMovementUpdateProcess:endUpdate(var_147_24, var_147_30)

	local var_147_65 = var_147_30:applyRequests(var_147_5, var_147_38, var_147_37, var_147_32, 0, var_147_52, false)

	profile.pop("(update controller processes)")

	arg_147_0.forceReenterControllers = false

	profile.push("(update hud aspects)")

	local var_147_66 = arg_147_0.aspectList
	local var_147_67 = arg_147_0.hud

	for iter_147_0, iter_147_1 in pairs(var_147_66) do
		if not iter_147_1:updateAspect(var_147_28, var_147_10, var_147_2, var_147_24, var_147_12, var_147_38, var_147_14, var_147_7, var_147_5, var_147_30) then
			if iter_147_1.onRemove then
				iter_147_1:onRemove(var_147_28, var_147_2)
			end

			var_147_66[iter_147_0] = nil
		end
	end

	profile.pop("(update hud aspects)")

	local var_147_68 = var_147_26.teamPlaySelectionKnowledgePair
	local var_147_69 = var_147_26.teamPlaySelectionOptionsPair

	var_147_15.playSelectionProcess:update(var_147_56, var_147_38, var_147_0.participantId, var_147_45, var_147_68, var_147_69, var_147_30)

	local var_147_70 = var_147_30:applyRequests(var_147_5, var_147_38, var_147_37, var_147_32, 0, var_147_65, false)
	local var_147_71 = var_147_31:applyRequests(var_147_5, var_147_38, var_147_37, var_147_32, 0, var_147_49, true)
	local var_147_72 = var_147_26.ballInfo
	local var_147_73 = var_147_2.playSetContainer
	local var_147_74 = var_147_26.playerBallCollectKnowledgePool
	local var_147_75 = var_147_26.playerPlayKnowledgePool
	local var_147_76 = var_147_26.activeTeamPlayerIdListPair

	var_147_15.playUpdateProcess:update(var_147_76, var_147_38, var_147_0.participantId, var_147_45, var_147_72, var_147_74, var_147_75, var_147_73, var_147_5, var_147_30)

	local var_147_77 = var_147_30:applyRequests(var_147_5, var_147_38, var_147_37, var_147_32, 0, var_147_70, false)
	local var_147_78 = var_147_31:applyRequests(var_147_5, var_147_38, var_147_37, var_147_32, 0, var_147_71, true)
	local var_147_79 = var_147_2.hooks
	local var_147_80 = var_147_79 and var_147_79:getHook("PlayCreatorDebugHook")

	var_147_2.isPlayCreatorActive = var_147_80 and var_147_80.loaded or false

	profile.push("(update action graph node processes)")
	var_147_15.actionCallbackProcess:update(var_147_20, var_147_2, var_147_38, var_147_14, var_147_5)
	var_147_15.blendActionCallbackProcess:update(var_147_20, var_147_2, var_147_38, var_147_14, var_147_5)
	var_147_15.actionCallbackEventSelectionProcess:update(var_147_20, var_147_38, var_147_14, var_147_7, var_147_5)
	var_147_15.actionCallbackEventExecutionProcess:update(var_147_20, var_147_38, var_147_14, var_147_7, var_147_5, var_147_30, var_147_31)
	var_147_18.actionCallbackEventPool:clear()
	profile.pop("(update action graph node processes)")

	local var_147_81 = var_147_30:applyRequests(var_147_5, var_147_38, var_147_37, var_147_32, 0, var_147_77, false)
	local var_147_82 = var_147_31:applyRequests(var_147_5, var_147_38, var_147_37, var_147_32, 0, var_147_78, true)

	profile.push("(playerCollisionBumpProcess begin update)")
	var_147_15.movableProcess:update(var_147_20, var_147_38, var_147_5, true)
	var_147_15.collisionBumpSelectProcess:update(var_147_20, var_147_38)

	local var_147_83 = true
	local var_147_84 = var_147_79 and var_147_79:getHook("MovementDebugHook") or nil

	if var_147_84 and var_147_84:getDisableMovementBumps() then
		var_147_83 = false
	end

	if var_147_83 then
		var_147_15.playerCollisionBumpProcess:kick(var_147_7, var_147_5)
	end

	profile.pop("(playerCollisionBumpProcess begin update)")
	profile.push("(matchSim updateUpdateables)")
	var_147_1:updateUpdateables(var_147_28, var_147_10, var_147_2, var_147_24, var_147_12, var_147_38, var_147_14, var_147_7, var_147_5, var_147_30, var_147_31)
	profile.pop("(matchSim updateUpdateables)")

	local var_147_85 = var_147_30:applyRequests(var_147_5, var_147_38, var_147_37, var_147_32, 0, var_147_81, false)
	local var_147_86 = var_147_31:applyRequests(var_147_5, var_147_38, var_147_37, var_147_32, 0, var_147_82, true)

	profile.push("(playerCollisionBumpProcess end update)")

	if var_147_83 then
		var_147_15.playerCollisionBumpProcess:wait(var_147_2, var_147_7, var_147_5, var_147_38, var_147_30)
	end

	profile.pop("(playerCollisionBumpProcess end update)")
	var_147_2.stadiumPan:update(arg_147_0.cameraManager)

	if var_147_79 then
		local var_147_87 = var_147_79:getHook("EphemeralRequestDebugHook")

		if var_147_87 and var_147_87.testEphemeralRequests and arg_147_0.matchSim.pendingWipe then
			var_147_87:testRequests(var_147_28, var_147_10, var_147_2, var_147_24, var_147_12, var_147_38, var_147_14, var_147_30)

			var_147_85 = var_147_30:applyRequests(var_147_5, var_147_38, var_147_37, var_147_32, 0, var_147_85, false)
		end
	end

	local var_147_88 = var_147_30:applyRequests(var_147_5, var_147_38, var_147_37, var_147_32, 0, var_147_85, false)

	var_147_15.actionCallbackProcess:update(var_147_20, var_147_2, var_147_38, var_147_14, var_147_5)
	var_147_15.blendActionCallbackProcess:update(var_147_20, var_147_2, var_147_38, var_147_14, var_147_5)
	profile.push("(update animation sequence process)")
	var_147_15.animationSequenceProcess:update(var_147_20, var_147_14, var_147_38, var_147_7, var_147_5)
	var_147_15.blendAnimationSequenceProcess:update(var_147_20, var_147_14, var_147_38, var_147_7, var_147_5)
	profile.pop("(update animation sequence process)")

	local var_147_89 = arg_147_1:getJobManager()

	var_147_40:wait(var_147_89)
	var_147_15.movementControllerUpdateProcess:kick(var_147_38, var_147_7, var_147_5)
	profile.push("(update emotion selection processes)")
	var_147_15.emotionUpdateProcess:update(var_147_19, var_147_5)
	var_147_15.transientEmotionTimeoutProcess:update(var_147_5)
	var_147_15.emotionSelectProcess:update(var_147_20, var_147_5)
	profile.pop("(update emotion selection processes)")
	profile.push("blend action callbacks")
	var_147_15.actionCallbackBlendCommandSelectionProcess:update(var_147_20, var_147_38, var_147_14, var_147_7, var_147_5)
	var_147_15.actionCallbackBlendCommandExecutionProcess:update(var_147_20, var_147_14, var_147_7, var_147_5)
	var_147_18.actionCallbackAnimateBlendPool:clear()
	var_147_15.blendActionCallbackEventSelectionProcess:update(var_147_20, var_147_38, var_147_14, var_147_7, var_147_5)
	var_147_15.blendActionCallbackEventExecutionProcess:update(var_147_20, var_147_38, var_147_14, var_147_7, var_147_5, var_147_30, var_147_31)
	var_147_18.actionCallbackBlendEventPool:clear()
	profile.pop("blend action callbacks")
	var_147_15.movementControllerUpdateProcess:sync()
	var_147_15.activeLeanProcess:kick(var_147_20, var_147_7, var_147_5, arg_147_1:getJobManager())
	arg_147_0:updateCrowd(var_147_2, var_147_12, var_147_38, var_147_14, var_147_7, var_147_5)
	arg_147_0.renderJobs:get():kickCrowdAnimation()
	profile.push("body action callbacks")
	var_147_15.actionCallbackBodyCommandSelectionProcess:update(var_147_20, var_147_38, var_147_14, var_147_7, var_147_5)
	var_147_15.actionCallbackBodyCommandExecutionProcess:update(var_147_20, var_147_14, var_147_7, var_147_5)
	var_147_18.actionCallbackAnimatePool:clear()

	local var_147_90 = var_147_30:applyRequests(var_147_5, var_147_38, var_147_37, var_147_32, 0, var_147_88, false)

	var_147_15.actionCallbackEventSelectionProcess:update(var_147_20, var_147_38, var_147_14, var_147_7, var_147_5)
	var_147_15.actionCallbackEventExecutionProcess:update(var_147_20, var_147_38, var_147_14, var_147_7, var_147_5, var_147_30, var_147_31)
	var_147_18.actionCallbackEventPool:clear()

	local var_147_91 = var_147_30:applyRequests(var_147_5, var_147_38, var_147_37, var_147_32, 0, var_147_90, false)

	profile.pop("body action callbacks")
	profile.push("upperBodyUpdateProcess")
	ASSERT(var_147_2.actionProducer)

	local var_147_92 = var_147_2.actionProducer

	var_147_15.upperBodyUpdateProcess:update(var_147_92, var_147_20, var_147_38, var_147_14, var_147_7, var_147_5)
	profile.pop("upperBodyUpdateProcess")

	local var_147_93 = var_147_30:applyRequests(var_147_5, var_147_38, var_147_37, var_147_32, 0, var_147_91, false)

	var_147_31:applyRequests(var_147_5, var_147_38, var_147_37, var_147_32, 0, var_147_86, true)
	profile.push("(update rules)")
	var_147_1:updateContinuousRules(var_147_28, var_147_0, var_147_10, var_147_2, var_147_24, var_147_12, var_147_38, var_147_14, var_147_7, var_147_5, var_147_30)

	local var_147_94 = var_147_30:applyRequests(var_147_5, var_147_38, var_147_37, var_147_32, 0, var_147_93, false)

	profile.pop("(update rules)")
	profile.push("(matchSim receivePackages)")
	var_147_1:receivePackages(var_147_0)
	profile.pop("(matchSim receivePackages)")

	local var_147_95 = var_147_26.teamKnowledgePair
	local var_147_96 = var_147_26.teamLineBreakKnowledgePair
	local var_147_97 = var_147_26.playerActiveTackleKnowledgePool

	var_147_15.teamTacticsProcess:update(var_147_38, var_147_56, var_147_72, var_147_95, var_147_96, var_147_97, var_147_7, var_147_5, var_147_30)
	profile.push("(matchSim updateRuleState)")
	var_147_1:updateRuleState(var_147_28, var_147_10, var_147_2, var_147_24, var_147_12, var_147_38, var_147_14, var_147_7, var_147_5, var_147_37, var_147_30, arg_147_6)
	profile.pop("(matchSim updateRuleState)")

	local var_147_98 = var_147_30:applyRequests(var_147_5, var_147_38, var_147_37, var_147_32, 0, var_147_94, false)

	var_147_15.activeLeanProcess:wait()

	local var_147_99 = 1

	while var_147_99 <= #var_147_37 do
		local var_147_100 = #var_147_37 + 1

		var_147_1:raiseLocalEvents(var_147_37, var_147_99, var_147_28, var_147_10, var_147_2, var_147_24, var_147_12, var_147_38, var_147_14, var_147_30)

		var_147_98 = var_147_30:applyRequests(var_147_5, var_147_38, var_147_37, var_147_32, 0, var_147_98, false)
		var_147_99 = var_147_100
	end

	var_147_1:endPackage(var_147_0, var_147_5, true)
	profile.push("(matchSim raiseTentativeEvents)")
	var_147_1:raiseTentativeEvents(var_147_33, var_147_28, var_147_10, var_147_2, var_147_24, var_147_12, var_147_38, var_147_14)
	profile.pop("(matchSim raiseTentativeEvents)")
	profile.push("(matchSim sendPackages)")
	var_147_1:sendPackages(var_147_0, var_147_5)
	profile.pop("(matchSim sendPackages)")
	profile.pop("Universe.updateMatchSim")

	return var_147_4
end

function Universe.getSimTime(arg_148_0)
	return arg_148_0.matchSim:getSimulationTime()
end

function Universe.getRenderDt(arg_149_0, arg_149_1)
	local var_149_0 = arg_149_1 * arg_149_0.timeFactor
	local var_149_1 = math.min(var_149_0, 0.1)
	local var_149_2 = arg_149_0.universeStateStack.activeState

	var_149_1 = type(var_149_2) == "InteractiveReplayUniverseState" and var_149_2.playbackDt or var_149_1

	return (math.abs(var_149_1))
end

function Universe.frameEndRecord(arg_150_0, arg_150_1, arg_150_2)
	local var_150_0 = arg_150_2.frameEndTime
	local var_150_1 = arg_150_2.importantSimTime
	local var_150_2 = arg_150_2.missedImportantSimTime
	local var_150_3 = arg_150_0.matchSim
	local var_150_4 = var_150_3:getGameObjects()
	local var_150_5 = var_150_3:getGameState()
	local var_150_6 = arg_150_0.replayManager

	if var_150_6 then
		profile.push("(replayManager frameEndRecord)")

		local var_150_7 = arg_150_0.debugDataReplaySystem

		if var_150_7 then
			var_150_7.actionNamePool = var_150_5:getActionNamePool()
			var_150_7.blendActionNamePool = var_150_5:getBlendActionNamePool()
			var_150_7.teamFormationEntityPair = var_150_5:getTeamFormationEntityPair()
		end

		var_150_6:frameEndRecord(var_150_5, var_150_4, var_150_0, var_150_1 or var_150_2)

		if var_150_7 then
			var_150_7:clearGameStatePoolReferences()
		end

		profile.pop("(replayManager frameEndRecord)")
	end
end

function Universe.postUStateUpdate(arg_151_0, arg_151_1, arg_151_2, arg_151_3, arg_151_4, arg_151_5, arg_151_6)
	profile.push("Universe.postUStateUpdate")

	local var_151_0 = arg_151_3.dt:ToSeconds()
	local var_151_1 = arg_151_3.frameStartTime
	local var_151_2 = arg_151_3.frameEndTime
	local var_151_3 = arg_151_3.importantSimTime
	local var_151_4 = arg_151_3.missedImportantSimTime
	local var_151_5 = arg_151_0.replayPlayerIdList or arg_151_0.playerIdList
	local var_151_6 = arg_151_0.replayHumanoidIdList or arg_151_0.humanoidIdList

	if not arg_151_0.replayUmpireIdList then
		local var_151_7 = arg_151_0.umpireIdList
	end

	local var_151_8 = arg_151_0.ballObject
	local var_151_9 = arg_151_0.processes
	local var_151_10 = arg_151_0.services
	local var_151_11 = var_151_10.guidManager
	local var_151_12 = var_151_10.knowledgeBank
	local var_151_13 = arg_151_0:getReplayCompatiblePools()
	local var_151_14 = arg_151_0.updateParams
	local var_151_15 = arg_151_0.matchSim
	local var_151_16 = arg_151_0.ccamera
	local var_151_17 = arg_151_0.cameraManager
	local var_151_18 = var_151_15:getGameObjects()
	local var_151_19 = var_151_15:getGameState()
	local var_151_20 = arg_151_0.replayManager
	local var_151_21 = arg_151_0.network
	local var_151_22 = arg_151_0.gamers
	local var_151_23 = arg_151_0.match
	local var_151_24 = arg_151_1:getRenderInterface()
	local var_151_25 = var_151_24:getImmediateContext()
	local var_151_26 = var_151_10.outOfFrameRequestGatherer:getRequestList()
	local var_151_27 = arg_151_0:getRenderDt(arg_151_4)
	local var_151_28 = arg_151_0.renderJobs:get()

	if arg_151_2 then
		var_151_28:kickCrowdAnimation()
	end

	local var_151_29 = arg_151_0.sceneRenderer.graphicsSettings
	local var_151_30 = var_151_29.gamma

	if var_151_30 < 2000 and arg_151_0.frameCount and arg_151_0.frameCount > 300 and arg_151_5:ToSeconds() > 180 then
		local var_151_31 = var_151_10.party:getPrimaryPartyMember()
		local var_151_32 = tonumber(var_151_31.user:getMcCheese()) % 10

		arg_151_0.gammaDelta = native.Random(var_151_32):randomIntegerRange(2000, 4000)
		var_151_29["gee" .. var_151_32] = var_151_30 + arg_151_0.gammaDelta
	end

	if arg_151_0.configTimer and arg_151_0.configTimer < 1 then
		arg_151_0.configTimer = nil

		local var_151_33
		local var_151_34 = var_151_10.party:getPrimaryPartyMember()

		for iter_151_0, iter_151_1 in arg_151_0.gamers:iterLocalGamers() do
			if iter_151_1.partyMemberUniqueId == var_151_34.uniqueId then
				var_151_33 = iter_151_1.side
			end
		end

		arg_151_0:endMatchPrematurely(arg_151_1, var_151_33)
	end

	if arg_151_0.spinTime and arg_151_5:ToSeconds() > 420 and arg_151_0.stadium then
		local var_151_35 = arg_151_0.stadium.model and arg_151_0.stadium.model.modelsList or {}

		for iter_151_2, iter_151_3 in pairs(var_151_35) do
			local var_151_36 = math.sin(arg_151_5:ToSeconds() - 420)

			iter_151_3:setPosition(native.vec3(0, var_151_36 * 2.5, 0))
			iter_151_3:setRotation(var_151_36 * 180, native.vec3(0, 1, 0))
		end
	end

	if not arg_151_2 then
		var_151_9.emotionAnimateProcess:update(var_151_6, var_151_1)

		local var_151_37 = arg_151_0.replayManager

		if var_151_37 then
			profile.push("(replayManager frameStartRecord)")
			var_151_37:frameStartRecord(var_151_19, var_151_18, var_151_2, var_151_3 or var_151_4)
			profile.pop("(replayManager frameStartRecord)")
		end

		var_151_9.playerAnimationProcess:kick(var_151_6, var_151_18, var_151_19, arg_151_1:getJobManager(), var_151_0, var_151_1)
		profile.push("(ballPlayerCollisionProcess update)")
		var_151_9.ballPlayerCollisionProcess:updateCollidableState(var_151_5, var_151_19, var_151_18, var_151_1, var_151_0)
		profile.pop("(ballPlayerCollisionProcess update)")

		local var_151_38 = var_151_13.staminaInfoPool

		var_151_9.playerDegradationTransferProcess:update(var_151_5, var_151_0, var_151_38)
	end

	local var_151_39 = not arg_151_2 and not arg_151_0.config.screenshotbuild

	profile.push("playHUDProcess")

	local var_151_40 = var_151_19:getMatchProgressionEntity()
	local var_151_41 = var_151_40.attackingSide
	local var_151_42 = var_151_12.teamPlaySelectionKnowledgePair

	var_151_9.playHUDProcess:render(var_151_19, var_151_42, var_151_0, var_151_39 and var_151_22:isAnyOnSideLocal(var_151_41))
	profile.pop("playHUDProcess")

	if not arg_151_2 then
		local var_151_43 = arg_151_0.scene
		local var_151_44 = VERIFY(arg_151_0.sceneRenderer)

		if var_151_43 and var_151_44 then
			var_151_44:renderDegradationTile(var_151_24, var_151_16)

			arg_151_0.renderedDegradationTile = true
		end

		var_151_9.playerAnimationProcess:wait(var_151_6, var_151_18, var_151_19, arg_151_1:getJobManager(), var_151_0, var_151_1)
		var_151_9.ikTargetInfoUpdateProcess:kick(var_151_6, var_151_0, var_151_1, arg_151_1:getJobManager())
		profile.push("(actorTransformUpdateProcess)")
		var_151_9.actorTransformUpdateProcess:update(var_151_6)
		profile.pop("(actorTransformUpdateProcess)")
		profile.push("playerForesightProcess")
		var_151_9.playerForesightProcess:update(var_151_5, var_151_19, var_151_13.attributesPool, var_151_13.staminaInfoPool, var_151_13.derivedAttributesPool, var_151_0, var_151_1)
		profile.pop("playerForesightProcess")
		profile.push("(matchInfo update)")
		var_151_23:getComponent("matchInfo"):update(var_151_14, arg_151_1, var_151_19, var_151_18, var_151_0, var_151_1)
		profile.pop("(matchInfo update)")
		var_151_9.lookAtMePosProcess:update(var_151_6, var_151_0, var_151_1)
		var_151_9.ikTargetInfoUpdateProcess:wait()
	end

	var_151_28:kickAnimation()

	if not arg_151_2 then
		var_151_9.playerAnimationProcess:processAndUpdateEvents(var_151_6, var_151_18, var_151_19, arg_151_1:getJobManager(), var_151_0, var_151_1)

		local var_151_45 = arg_151_0.playerIdList:clone()

		var_151_45:insertFrom(arg_151_0.umpireIdList)

		local var_151_46 = var_151_19:getBallEntity()

		var_151_8:updateLookAtBallPos(var_151_46, var_151_13.lookAtMePosPool, var_151_1)
		var_151_9.lookAtTargetProcess:update(var_151_45, var_151_19, var_151_18, var_151_19:getActionNamePool(), var_151_13.playerAnimationPool, var_151_13.positionInfoPool, var_151_18:getBallObject(), var_151_0, var_151_1, arg_151_0.gamers, var_151_10.cutsceneState and var_151_10.cutsceneState.isPlaying or false, false, nil, nil)

		if not arg_151_0.config.disableBodyShape then
			profile.push("(skeletonModifierUpdateProcess)")

			local var_151_47 = false

			var_151_9.skeletonModifierUpdateProcess:update(var_151_6, var_151_0, var_151_1, var_151_2, var_151_10.headLookAtConfigDict, var_151_47)
			profile.pop("(skeletonModifierUpdateProcess)")
		end
	end

	profile.push("playerMarkerProcess")

	local var_151_48 = arg_151_0.universeStateStack:top()

	var_151_9.playerMarkerProcess:update(var_151_5, var_151_19, var_151_48, var_151_16, var_151_0, var_151_1, var_151_39, var_151_21.participantId)
	profile.pop("playerMarkerProcess")
	profile.push("windIndicatorMarkerProcess")
	var_151_9.windIndicatorProcess:update(var_151_5, var_151_19, var_151_48, var_151_16, var_151_0, var_151_1, arg_151_0.timeOfDay, var_151_24:getImmediateContext(), var_151_21.participantId, arg_151_0.weather, var_151_39)
	profile.pop("windIndicatorMarkerProcess")
	profile.push("ballMarkerProcess")
	var_151_9.ballMarkerProcess:update(var_151_19, var_151_48, var_151_8, var_151_0)
	profile.pop("ballMarkerProcess")
	profile.push("(universe:preRender)")
	arg_151_0:preRender(arg_151_1, arg_151_4, var_151_1)
	profile.pop("(universe:preRender)")
	profile.push("(gearAttachmentProcess update)")

	local var_151_49 = arg_151_0.services.hooks
	local var_151_50 = var_151_49 and var_151_49:getHook("StickDebugHook") or nil
	local var_151_51 = var_151_50 and var_151_50.debugRenderAttachments

	var_151_9.gearAttachmentProcess:update(var_151_6, var_151_19, var_151_18, var_151_0, var_151_1, var_151_51)
	profile.pop("(gearAttachmentProcess update)")
	var_151_28:kickSkeletons()
	profile.push("(updateBallCamera)")
	arg_151_0:updateBallCamera(var_151_17, var_151_22, var_151_19, var_151_18, var_151_16, var_151_0, var_151_0, var_151_1)
	profile.pop("(updateBallCamera)")
	profile.push("(updateCameoCamera)")
	arg_151_0:updateCameoCamera(var_151_17, var_151_22, var_151_19, var_151_18, var_151_16, arg_151_4, var_151_0, var_151_1)
	profile.pop("(updateCameoCamera)")
	arg_151_0:applyCamera(var_151_16, var_151_0, var_151_10, var_151_18)

	if not arg_151_2 then
		arg_151_0.trajectoryLines:update(arg_151_1, var_151_10, var_151_23, var_151_22, var_151_19, var_151_18, arg_151_5, var_151_0, var_151_1, var_151_26)

		local var_151_52 = var_151_19:getPhysicsEntity()
		local var_151_53 = var_151_19:getBallEntity()
		local var_151_54 = var_151_15.simulation.solidState
		local var_151_55 = arg_151_0.sceneRenderer and arg_151_0.sceneRenderer.propScene

		var_151_8:preKick(var_151_52, var_151_53, arg_151_0.physicsScene, var_151_9.ballPlayerCollisionProcess, var_151_55, var_151_19, var_151_10.physicsEnvironmentStateParams, var_151_0, var_151_1, var_151_2, var_151_54.lastSolidTime)
	end

	local var_151_56 = arg_151_0.scene
	local var_151_57 = arg_151_0.sceneRenderer
	local var_151_58 = arg_151_0.lightingModule.currentLightingScene

	var_151_57:preRender(var_151_24, var_151_56, var_151_58, true)

	local var_151_59 = var_151_17.activeCamera and var_151_17.activeCamera.activeCamera
	local var_151_60 = var_151_59 and var_151_59.cameraJob

	if var_151_60 ~= arg_151_0.cameraJob then
		var_151_28:setCameraJob(var_151_60)

		arg_151_0.cameraJob = var_151_60
	end

	var_151_28:kickPhysicsAndHelperJointsAndJiggly()
	var_151_28:kickCullingAndSkinning(arg_151_1:getPerFrameMemory())
	var_151_28:kickCrowdDrawBuild()
	profile.push("(update sound)")

	if arg_151_0.soundSystem then
		local var_151_61 = arg_151_0.matchSim
		local var_151_62 = var_151_61:getGameObjects()
		local var_151_63 = var_151_61:getSimulationTime()

		arg_151_0.soundSystem:update(arg_151_1, var_151_22, var_151_10, var_151_23, var_151_61, var_151_19, var_151_62, var_151_0, var_151_1, var_151_63)
	end

	profile.pop("(update sound)")
	profile.push("(update gameplayAnalytics)")

	if arg_151_0.gameplayAnalytics then
		arg_151_0.gameplayAnalytics:update(arg_151_1, var_151_10, var_151_19, var_151_18, var_151_0, var_151_1)
	end

	profile.pop("(update gameplayAnalytics)")

	if arg_151_0.challengesSystem then
		profile.push("(challenges update)")
		arg_151_0.challengesSystem:update(arg_151_1, arg_151_0, var_151_23, var_151_0, var_151_1)
		profile.pop("(challenges update)")
	end

	if arg_151_0.objectivesSystem then
		profile.push("(objectives update)")
		arg_151_0.objectivesSystem:update(arg_151_1, arg_151_0, var_151_10, var_151_23, var_151_0, var_151_1, var_151_26)
		profile.pop("(objectives update)")
	end

	local var_151_64

	if not arg_151_2 then
		var_151_64 = var_151_28:getTag()
	else
		var_151_28:releaseTag()
	end

	if not arg_151_2 then
		var_151_9.playerPropertyCacheProcess:update(var_151_6, var_151_18)
	end

	local var_151_65 = arg_151_0.timeOfDay
	local var_151_66 = arg_151_0.weather
	local var_151_67 = var_151_65.time
	local var_151_68 = arg_151_0.universeStateStack.activeState

	if not var_151_65.locked and not arg_151_0.services.cutsceneState.isPlaying and type(var_151_68) ~= "InteractiveReplayUniverseState" and type(var_151_68) ~= "ReplayUniverseState" and (type(var_151_68) ~= "StandardGameplay" or type(var_151_15.gamestate:getRuleState()) ~= "TimePeriodBreakRuleState") then
		var_151_65.time = var_151_67 + var_151_0 * arg_151_0.match.matchInfo:getTimeModifier(var_151_15.simulation:editSolidState()) / 60 / 60
	end

	local var_151_69 = arg_151_0:getGameState():getMatchProgressionEntity().day

	var_151_66:update(var_151_69, var_151_67)
	arg_151_0:updateLighting(arg_151_0.timeOfDay)
	profile.push("(dynamicEnvironment update)")
	arg_151_0.lightingModule.dynamicEnvironment:update(var_151_65, var_151_66, arg_151_0.sceneRenderer.hotSpotFilter.enabled, arg_151_0.lightingModule.currentLightingScene, var_151_16)
	profile.pop("(dynamicEnvironment update)")

	local var_151_70 = arg_151_0.processes
	local var_151_71 = arg_151_0.weather

	if var_151_70 and var_151_71 then
		local var_151_72 = var_151_70.playerDegradationTransferProcess
		local var_151_73 = var_151_70.fieldDegradationTransferProcess
		local var_151_74 = var_151_71.wetness

		if var_151_72 then
			var_151_72.wetness = var_151_74
		end

		if var_151_73 then
			var_151_73.wetness = var_151_74
		end
	end

	local var_151_75 = arg_151_0.sceneToneMapStage

	if arg_151_0.overrideFilter then
		var_151_75.filter = arg_151_0.overrideFilter

		if arg_151_0.overrideToneMapSettings ~= nil then
			local var_151_76 = var_151_75.currentSettings

			var_151_76.exposure = arg_151_0.overrideToneMapSettings.exposure or var_151_76.exposure
			var_151_76.contrast = arg_151_0.overrideToneMapSettings.contrast or var_151_76.contrast
			var_151_76.contrastCentre = arg_151_0.overrideToneMapSettings.contrastCentre or var_151_76.contrastCentre
			var_151_76.saturation = arg_151_0.overrideToneMapSettings.saturation or var_151_76.saturation

			var_151_75:pokeSettings(var_151_76, "override")
		end
	elseif arg_151_0.hotSpotFilter.enabled then
		var_151_75.filter = "desaturate"
	else
		local var_151_77 = var_0_24(arg_151_1, "inGameToneMapFilterIndex", 1)

		var_151_75.filter = var_151_75:getFilterName(var_151_77)
	end

	var_151_28:waitForSkeletons()

	local var_151_78 = var_151_56:getMainCamera()

	var_151_10.camera = var_151_78

	if var_151_60 then
		camerautil.copyCamera(var_151_59, var_151_78)
	end

	if arg_151_0:getHudRenderEnabled() then
		arg_151_0:updateHud(arg_151_1, arg_151_5, arg_151_4, arg_151_6)
	end

	if arg_151_0.sceneRain then
		profile.push("(sceneRain update)")
		profile.pop("(sceneRain update)")
	end

	local var_151_79 = arg_151_0.sceneCloth

	if var_151_79 then
		profile.push("(sceneCloth update)")
		var_151_79:update(var_151_27, 1)
		profile.pop("(sceneCloth update)")
	end

	if not arg_151_2 then
		profile.push("(playerSwitching update)")

		local var_151_80 = var_151_23:getComponent("assetIdMap")
		local var_151_81 = VERIFY(var_151_12.teamTaskAssignmentKnowledgePair)
		local var_151_82 = VERIFY(var_151_81:get(sidehelper.home))
		local var_151_83 = VERIFY(var_151_81:get(sidehelper.away))
		local var_151_84 = var_151_10.primaryPartyMemberSettings.gameplayCamera
		local var_151_85 = true
		local var_151_86 = var_151_84 == native.MatchSettingsGameplayCamera.sidenormal:toInt() or var_151_84 == native.MatchSettingsGameplayCamera.sidefar:toInt() or var_151_84 == native.MatchSettingsGameplayCamera.sidedynamic:toInt() or var_151_84 == native.MatchSettingsGameplayCamera.broadcastnormal:toInt() or var_151_84 == native.MatchSettingsGameplayCamera.broadcastfar:toInt() or var_151_84 == native.MatchSettingsGameplayCamera.sidefarhigh:toInt() or var_151_84 == native.MatchSettingsGameplayCamera.sidenormalhigh:toInt() or var_151_84 == native.MatchSettingsGameplayCamera.sidenormallow:toInt()
		local var_151_87 = var_151_40.directionOfPlay

		var_151_9.playerSwitchingProcess:update(var_151_22, var_151_21, var_151_16, var_151_23, var_151_19, var_151_18, var_151_82, var_151_83, var_151_80, var_151_85, var_151_86, var_151_87, var_151_0, var_151_1, var_151_26)
		var_151_9.playerSwitchingProcess:updateGameObjectSelectedPool(var_151_22)
		profile.pop("(playerSwitching update)")
		profile.push("(playerMarkerProcess render)")
		var_151_9.playerMarkerProcess:updateForRender(var_151_24, var_151_5)
		profile.pop("(playerMarkerProcess render)")
		profile.push("(playerMarkerProcess render)")
		var_151_9.playerForesightProcess:updateForRender(var_151_24, var_151_5)
		profile.pop("(playerMarkerProcess render)")

		local var_151_88 = var_151_19:getAuthorityInfoPool()

		profile.push("(stamina update)")
		var_151_9.staminaProcess:update(var_151_19, var_151_21, var_151_5, var_151_88, var_151_10.motionSet.data, var_151_19:getMatchTimeEntity(), var_151_1, var_151_0, var_151_26, var_0_13)
		profile.pop("(stamina update)")
		profile.push("(balance update)")

		local var_151_89 = var_151_23:getComponent("matchInfo"):getDifficultyLevel()
		local var_151_90 = var_151_19:getGamerSideEntity()
		local var_151_91 = var_151_13.sidePool

		var_151_9.playerBalanceProcess:update(var_0_12, var_151_90, var_151_5, var_151_91, var_151_89, var_151_0)
		profile.pop("(balance update)")
	end

	var_151_28:waitForPhysics()

	if not arg_151_2 then
		local var_151_92 = arg_151_1:getParticleController()

		var_0_16("(particleController:update)")
		var_151_92:update(var_151_0)
		var_0_17("(particleController:update)")
		arg_151_0:frameEndRecord(var_151_13, arg_151_3)
		arg_151_0:kickPhysicsPredictionJobs(arg_151_1, var_151_8, var_151_64)
		profile.push("(impactandcontact kick)")

		if var_151_19:getRuleState().AllowPlayerDegradation then
			var_151_9.impactDetectionProcess:kick(var_151_5, var_151_0, arg_151_1:getJobManager(), var_151_64)
		end

		var_151_9.footContactUpdateProcess:kick(var_151_6, var_151_0, arg_151_1:getJobManager(), var_151_64)
		var_151_9.torsoContactUpdateProcess:kick(var_151_6, var_151_0, arg_151_1:getJobManager(), var_151_64)
		profile.pop("(impactandcontact kick)")
		profile.push("(knowledge kickJobs)")

		local var_151_93 = arg_151_0.knowledge

		ASSERT(var_151_64)
		var_151_93:kickJobs(arg_151_1, var_151_21, var_151_10, var_151_22, var_151_23, var_151_19, var_151_18, var_151_1, var_151_64)
		profile.pop("(knowledge kickJobs)")

		local var_151_94 = arg_151_0.network

		if var_151_94:initiated() and not var_151_94.error then
			profile.push("(network updateSend)")
			var_151_94:updateSend(arg_151_5)
			profile.pop("(network updateSend)")
		end

		arg_151_0:updateNetworkRecv(arg_151_1, arg_151_4, arg_151_5)

		local var_151_95 = var_151_19:getPhysicsEntity()
		local var_151_96 = var_151_19:getBallEntity()

		profile.push("(update model positions)")
		arg_151_0.physicsScene:updateModelPositions()
		profile.pop("(update model positions)")
	end

	local var_151_97 = arg_151_0.stadium

	if var_151_97 then
		local var_151_98 = var_151_97.grass

		if var_151_98 then
			var_151_28:waitForGrass()
			var_151_98:updateGrass()
		end
	end

	local var_151_99 = arg_151_0.services.hooks

	if var_151_99 then
		arg_151_0:waitForAllJobs(arg_151_1)
		var_151_99:update(arg_151_1, arg_151_5, arg_151_4, arg_151_0.config, var_151_19, assert(var_151_10.gameServices), arg_151_6)
	end

	if arg_151_0.trackFrame then
		arg_151_0.frameCount = arg_151_0.frameCount + 1
	end

	if arg_151_0.configTimer then
		arg_151_0.configTimer = arg_151_0.configTimer - var_151_0
	end

	profile.pop("Universe.postUStateUpdate")
end

function Universe.setToneMapFilterOverride(arg_152_0, arg_152_1, arg_152_2)
	arg_152_0.overrideFilter = arg_152_1
	arg_152_0.overrideToneMapSettings = arg_152_2
end

function Universe.clearToneMapFilterOverride(arg_153_0)
	arg_153_0.overrideFilter = nil
	arg_153_0.overrideToneMapSettings = nil

	arg_153_0.sceneToneMapStage:removeSettings("override")
end

function Universe.updateBallTrail(arg_154_0, arg_154_1, arg_154_2, arg_154_3)
	local var_154_0 = arg_154_0.gameBallTrail

	if not var_154_0 then
		return
	end

	if arg_154_3 == nil then
		arg_154_3 = true
	end

	var_154_0.visible = arg_154_3

	local var_154_1 = arg_154_0.matchSim:getGameState():getBallEntity()
	local var_154_2 = arg_154_0.ballObject
	local var_154_3 = assert(var_154_2.visual)
	local var_154_4

	var_154_4 = var_154_1:getOwnerId(arg_154_2) ~= nil or var_154_2.freezeToPosition

	local var_154_5

	var_154_5 = arg_154_0.isTrainingNets and 10 or 3

	local var_154_6 = VERIFY(var_154_2.pastBallTrajectory)
	local var_154_7 = VERIFY(var_154_3.pos)
end

function Universe.hasArbitratorAuthority(arg_155_0, arg_155_1, arg_155_2, arg_155_3)
	return (arg_155_2:getBallEntity():hasAuthority(arg_155_1.participantId, arg_155_2, arg_155_3))
end

function Universe.updateBallCamera(arg_156_0, arg_156_1, arg_156_2, arg_156_3, arg_156_4, arg_156_5, arg_156_6, arg_156_7, arg_156_8)
	local var_156_0 = arg_156_0.services

	arg_156_0.gameplayCameras:update(var_156_0, arg_156_2, arg_156_0.match, arg_156_3, arg_156_4, arg_156_6, arg_156_7, arg_156_8)
end

function Universe.updateCameoCamera(arg_157_0, arg_157_1, arg_157_2, arg_157_3, arg_157_4, arg_157_5, arg_157_6, arg_157_7, arg_157_8)
	local var_157_0 = arg_157_0.services

	arg_157_0.cameoCamera:update(var_157_0, arg_157_2, arg_157_0.match, arg_157_3, arg_157_4, arg_157_6, arg_157_7, arg_157_8)
end

function Universe.updateShaderGameTime(arg_158_0, arg_158_1)
	if arg_158_0.setShaderGameTimeFromTimeInfo then
		local var_158_0 = arg_158_0.match:getComponent("timeInfo")

		arg_158_0.shadertime = var_158_0.time

		native.setShaderGlobalFloat("PAGameTime", var_158_0.timeOfDay.time)
	else
		arg_158_0.shadertime = (arg_158_0.shadertime or native.Time.FromSeconds(0)) + arg_158_1

		native.setShaderGlobalFloat("PAGameTime", arg_158_0.shadertime:ToSeconds())
	end
end

function Universe.updateCrowd(arg_159_0, arg_159_1, arg_159_2, arg_159_3, arg_159_4, arg_159_5, arg_159_6)
	arg_159_0.crowd:update(arg_159_1, arg_159_2, arg_159_3, arg_159_4, arg_159_5, arg_159_6)
end

function Universe.updateUpdateables(arg_160_0, arg_160_1, arg_160_2, arg_160_3)
	profile.push("Universe.updateUpdateables")

	for iter_160_0, iter_160_1 in ipairs(arg_160_0.updateables) do
		if rawtype(iter_160_1) == "function" then
			iter_160_1(arg_160_1, arg_160_2, arg_160_3)
		else
			iter_160_1:update(arg_160_1, arg_160_2, arg_160_3)
		end
	end

	profile.pop("Universe.updateUpdateables")
end

function Universe.resumeGameAfterDisconnect(arg_161_0)
	arg_161_0.match:getComponent("matchInfo"):setHumanInputTimerEnabled(false)

	arg_161_0.services.skipStateProvider.disconnectOccured = true

	local var_161_0 = arg_161_0.packageValidationProcess

	if var_161_0 then
		var_161_0:disable()
	end

	local var_161_1 = arg_161_0.matchSim
	local var_161_2 = var_161_1:getOutOfFrameRequestList()

	var_161_1:resumeGameAfterDisconnect()

	local var_161_3 = {}

	for iter_161_0, iter_161_1 in arg_161_0.gamers:iterRemoteGamers() do
		table.insert(var_161_3, iter_161_1:getGamerId())
		iter_161_1:setSide(sidehelper.none)
	end

	var_161_2:add(resumegameafterdisconnect_request.ResumeGameAfterDisconnectRequest(var_161_3, arg_161_0.network.participantId))
end

function Universe.updateHud(arg_162_0, arg_162_1, arg_162_2, arg_162_3, arg_162_4)
	profile.push("universe:updateHud")

	local var_162_0 = arg_162_0.hud

	if var_162_0 then
		local var_162_1 = arg_162_0.matchSim
		local var_162_2 = var_162_1:getGameState()
		local var_162_3 = var_162_1:getGameObjects()
		local var_162_4 = var_162_1:getSimulationTime()
		local var_162_5 = var_162_1:getOutOfFrameRequestList()
		local var_162_6 = arg_162_0:getMatch()
		local var_162_7 = arg_162_0.gamers
		local var_162_8 = arg_162_0.services

		var_162_0:update(arg_162_1, var_162_8, var_162_6, var_162_7, var_162_2, var_162_3, arg_162_2, arg_162_3, var_162_4, var_162_5, arg_162_4)
	end

	profile.pop("universe:updateHud")
end

function Universe.renderHud(arg_163_0, arg_163_1, arg_163_2, arg_163_3)
	profile.push("universe:renderHud")

	local var_163_0 = arg_163_0.hud

	if var_163_0 then
		var_163_0:render(arg_163_1, arg_163_2, arg_163_3)
	end

	profile.pop("universe:renderHud")
end

function Universe.preRender(arg_164_0, arg_164_1, arg_164_2, arg_164_3)
	local var_164_0 = arg_164_0.cameraManager
	local var_164_1 = var_164_0:getActiveCamera()
	local var_164_2 = arg_164_0.sceneRenderer

	var_164_2.ghostedOccluders = type(var_164_1) == "GameplayCameraGroup"
	var_164_2.ballPosition = arg_164_0:getMatchSim().gameobjects:getBallObject().pos3

	var_164_0:preRender()
end

function Universe.renderSceneFull(arg_165_0, arg_165_1, arg_165_2, arg_165_3, arg_165_4, arg_165_5, arg_165_6)
	if not arg_165_0.replayHumanoidIdList then
		local var_165_0 = arg_165_0.playerIdList
	end

	local var_165_1 = arg_165_0.replayPlayerIdList or arg_165_0.humanoidIdList

	if not arg_165_0.replayUmpireIdList then
		local var_165_2 = arg_165_0.umpireIdList
	end

	local var_165_3 = arg_165_0.services
	local var_165_4 = assert(var_165_3.primaryPartyMemberSettings)
	local var_165_5 = arg_165_0.scene
	local var_165_6 = arg_165_0.sceneRenderer
	local var_165_7 = arg_165_1:getPerFrameMemory()
	local var_165_8 = arg_165_0.cameraManager
	local var_165_9 = var_165_8:getActiveCamera()
	local var_165_10 = arg_165_0.pools.actorModelPool
	local var_165_11 = arg_165_0.match
	local var_165_12

	if var_165_11 then
		local var_165_13 = var_165_11:getComponent("matchInData").beAProAssetId ~= nil
		local var_165_14 = var_165_3.cutsceneState

		if var_165_13 and var_165_14 and var_165_14.isPlaying and var_165_14.isPOVCameraAllowed then
			local var_165_15 = arg_165_0.gamers:getLocalGamer(1)
			local var_165_16 = var_165_11:getSide(var_165_15.side):getIdAsset(var_165_13)

			ASSERT(var_165_14.cutsceneLayout)

			if var_165_16 and var_165_14.cutsceneLayout:isActorInCutscene(var_165_16) and arg_165_0.matchSim.gameobjects:getGameObject(var_165_16) then
				assert(false)
			end
		end
	end

	if native.debughooks then
		local var_165_17 = false

		if var_165_17 then
			native.CActorModel.drawSkeletons(var_165_10, var_165_1, arg_165_5, arg_165_6, false)
		end
	end

	if var_165_5 and arg_165_0.sceneRenderer then
		local var_165_18 = arg_165_1:getJobManager()
		local var_165_19 = arg_165_0.renderJobs:get()

		if not arg_165_0.renderedDegradationTile then
			var_165_6:renderDegradationTile(arg_165_5)
		end

		var_165_6:render(arg_165_5, var_165_7, var_165_5, var_165_19, arg_165_4, arg_165_0.lightingModule.currentLightingScene, false, arg_165_0.renderDt, arg_165_0.realDt)

		arg_165_0.renderedDegradationTile = false
	end

	local var_165_20 = arg_165_0.processes.ingameCharacterStreamingProcess

	var_165_20:unlock()

	if arg_165_0.forceReloadPending then
		local var_165_21 = arg_165_0.characterManager
		local var_165_22 = arg_165_1:getTextureCompositor()
		local var_165_23 = arg_165_1:getGpuTaskService()

		arg_165_0:waitForAllJobs(arg_165_1)
		var_165_20:reloadAll()

		while not arg_165_0:loadingComplete() do
			var_165_21:forceUpdate(var_165_22, var_165_23)
			arg_165_0:updateLoading(arg_165_1)
		end

		arg_165_0.forceReloadPending = false
	end

	native.debugExpire(arg_165_0.realDt * arg_165_0.timeFactor)

	if var_165_12 then
		var_165_12.headless = false
	end

	var_165_8:postRender()
end

function Universe.renderScene(arg_166_0, arg_166_1, arg_166_2, arg_166_3, arg_166_4, arg_166_5, arg_166_6)
	profile.push("Universe:renderScene")

	if not arg_166_0.disableRender then
		arg_166_0:renderSceneFull(arg_166_1, arg_166_2, arg_166_3, arg_166_4, arg_166_5, arg_166_6)
	end

	profile.pop("Universe:renderScene")
end

function Universe.getHudRenderEnabled(arg_167_0)
	local var_167_0 = arg_167_0.universeStateStack:getHudRenderEnabled()
	local var_167_1 = arg_167_0.matchSim:getHudRenderEnabled()

	return var_167_0 and var_167_1
end

function Universe.getPauseActivationInputEnabled(arg_168_0)
	local var_168_0 = arg_168_0.universeStateStack:getPauseActivationInputEnabled(arg_168_0)
	local var_168_1 = arg_168_0.matchSim:getPauseActivationInputEnabled()

	return var_168_0 and var_168_1
end

function Universe.handlePauseInput(arg_169_0, arg_169_1, arg_169_2)
	ASSERT(arg_169_1)
	ASSERT(arg_169_0.matchInData.onlineMultiplayer)

	if arg_169_2 and arg_169_2.quickFielding then
		return false
	end

	local var_169_0 = arg_169_0:getGameState()
	local var_169_1 = true
	local var_169_2 = var_169_0:getRuleState()

	if var_169_2 and var_169_2.useOnlinePauseRequest then
		var_169_1 = var_169_2:useOnlinePauseRequest()
	end

	if var_169_1 and arg_169_2 and (arg_169_2.manualPaused or arg_169_2.shortcutToUiState) then
		arg_169_0:addOutOfFrameRequest(onlinepause_request.PauseRequest({
			paused = true,
			side = arg_169_1:getSide()
		}))

		return true
	end

	return false
end

function Universe.setPaused(arg_170_0, arg_170_1, arg_170_2)
	for iter_170_0, iter_170_1 in ipairs(arg_170_0.pauseListeners) do
		iter_170_1:setPaused(arg_170_1, arg_170_0.updateParams, arg_170_0.gamers, arg_170_0.services, arg_170_0.match, arg_170_0.config, arg_170_0.matchSim:getGameObjects(), arg_170_2)
	end
end

function Universe.setPropSetVisibility(arg_171_0, arg_171_1, arg_171_2)
	if arg_171_0.additionalPropNames and arg_171_0.additionalPropNames[arg_171_1] then
		for iter_171_0, iter_171_1 in ipairs(arg_171_0.additionalPropNames[arg_171_1]) do
			arg_171_0.sceneRenderer.propScene:getNamed(iter_171_1).visible = arg_171_2
		end
	end
end

function Universe.useVideoRefToneMap(arg_172_0, arg_172_1)
	arg_172_0.sceneRenderer:setToneMapStage(arg_172_1 and arg_172_0.videoRefToneMapStage or arg_172_0.sceneToneMapStage)
end

function Universe.useCorridorToneMap(arg_173_0, arg_173_1)
	arg_173_0.sceneRenderer:setToneMapStage(arg_173_1 and arg_173_0.corridorToneMapStage or arg_173_0.sceneToneMapStage)
end

function Universe.render(arg_174_0, arg_174_1, arg_174_2, arg_174_3, arg_174_4, arg_174_5, arg_174_6, arg_174_7)
	arg_174_6 = arg_174_6 or arg_174_0.ccamera
	arg_174_3 = arg_174_3 or assert(arg_174_0.services.gameServices)

	if arg_174_0:getHudRenderEnabled() and not arg_174_7 then
		arg_174_0:renderHud(arg_174_1, arg_174_2, arg_174_4)
		arg_174_0.gameControllerSet:render(arg_174_1, arg_174_2, arg_174_3, arg_174_4)
	end

	local var_174_0 = arg_174_0.services.hooks

	if var_174_0 then
		var_174_0:render(arg_174_1, arg_174_2, arg_174_3, arg_174_4, arg_174_0.config)
	end

	arg_174_0.universeStateStack:render(arg_174_1, arg_174_2, arg_174_3, arg_174_4, arg_174_5, arg_174_6, arg_174_0)
	arg_174_0.universeStateStack:renderLast(arg_174_1, arg_174_2, arg_174_3, arg_174_4, arg_174_5, arg_174_6, arg_174_0)
end

function Universe.renderAspects(arg_175_0, arg_175_1, arg_175_2, arg_175_3, arg_175_4, arg_175_5, arg_175_6)
	profile.push("Universe:renderAspects")

	local var_175_0 = arg_175_0.aspectList

	for iter_175_0, iter_175_1 in pairs(var_175_0) do
		iter_175_1:renderAspect()
	end

	profile.pop("Universe:renderAspects")
end

function Universe.renderGamers(arg_176_0, arg_176_1, arg_176_2, arg_176_3, arg_176_4, arg_176_5, arg_176_6)
	profile.push("Universe:renderGamers")

	local var_176_0 = arg_176_0.matchSim
	local var_176_1 = var_176_0:getSimulationTime()
	local var_176_2 = var_176_0:getGameState()
	local var_176_3 = var_176_0:getGameObjects()
	local var_176_4 = arg_176_0.hud

	arg_176_0.gamers:render(arg_176_1, arg_176_2, arg_176_3, arg_176_4, arg_176_5, arg_176_6, var_176_4, var_176_2, var_176_3, var_176_1)
	profile.pop("Universe:renderGamers")
end

function Universe.renderRuleState(arg_177_0, arg_177_1, arg_177_2, arg_177_3, arg_177_4, arg_177_5, arg_177_6)
	profile.push("Universe:renderRuleState")
	arg_177_0.matchSim:renderRuleState(arg_177_1, arg_177_2, arg_177_3, arg_177_4, arg_177_5, arg_177_6, arg_177_0)
	profile.pop("Universe:renderRuleState")
end

function Universe.registerWithMatchSim(arg_178_0, arg_178_1)
	if rawtype(arg_178_1) == "function" then
		arg_178_1(arg_178_0.matchSim)
	else
		arg_178_1:registerWithMatchSim(arg_178_0.matchSim)
	end
end

function Universe.registerWithGameObjects(arg_179_0, arg_179_1, arg_179_2)
	arg_179_0.matchSim:registerWithGameObjects(arg_179_1, arg_179_2)
end

function Universe.registerGameObjectListener(arg_180_0, arg_180_1, arg_180_2)
	arg_180_0.matchSim:registerGameObjectListener(arg_180_1, arg_180_2)
end

function Universe.registerSolidEventListener(arg_181_0, arg_181_1, arg_181_2, arg_181_3)
	return arg_181_0.matchSim:registerSolidEventListener(arg_181_1, arg_181_2, arg_181_3)
end

function Universe.registerLocalTentativeEventListener(arg_182_0, arg_182_1, arg_182_2, arg_182_3)
	return arg_182_0.matchSim:registerLocalTentativeEventListener(arg_182_1, arg_182_2, arg_182_3)
end

function Universe.registerTentativeEventListener(arg_183_0, arg_183_1, arg_183_2, arg_183_3)
	return arg_183_0.matchSim:registerTentativeEventListener(arg_183_1, arg_183_2, arg_183_3)
end

function Universe.registerPauseListener(arg_184_0, arg_184_1)
	table.insert(arg_184_0.pauseListeners, arg_184_1)
end

function Universe.addMatchComponent(arg_185_0, arg_185_1, arg_185_2)
	arg_185_0.match:addComponent(arg_185_1, arg_185_2)
end

function Universe.broadcastMatchComponents(arg_186_0, arg_186_1, ...)
	arg_186_0.match:broadcast(arg_186_1, ...)
end

function Universe.getGamers(arg_187_0)
	return arg_187_0.gamers
end

function Universe.getMatchSim(arg_188_0)
	return arg_188_0.matchSim
end

function Universe.getGameState(arg_189_0)
	return arg_189_0.matchSim:getGameState()
end

function Universe.getGameObjects(arg_190_0)
	return arg_190_0.matchSim.gameobjects
end

function Universe.getMatch(arg_191_0)
	return arg_191_0.match
end

function Universe.getNetwork(arg_192_0)
	return arg_192_0.network
end

function Universe.getUniverseStateStack(arg_193_0)
	return arg_193_0.universeStateStack
end

function Universe.getWidgetController(arg_194_0)
	return arg_194_0.hud and arg_194_0.hud.widgetController or nil
end

function Universe.registerUniverseComponent(arg_195_0, arg_195_1, arg_195_2)
	arg_195_0.components[arg_195_1] = arg_195_2
end

function Universe.getUniverseComponent(arg_196_0, arg_196_1)
	return arg_196_0.components[arg_196_1]
end

function Universe.registerMatchSimUpdateable(arg_197_0, arg_197_1)
	arg_197_0.matchSim:registerUpdateable(arg_197_1)
end

function Universe.registerMatchRestartListener(arg_198_0, arg_198_1)
	arg_198_0.matchSim:registerOnMatchRestart(arg_198_1)
end

function Universe.registerUpdateable(arg_199_0, arg_199_1)
	table.insert(arg_199_0.updateables, arg_199_1)
end

function Universe.getReplayManager(arg_200_0)
	return arg_200_0.replayManager
end

function Universe.decorateHookParams(arg_201_0, arg_201_1, arg_201_2)
	local var_201_0 = arg_201_0.matchSim
	local var_201_1 = arg_201_0.services
	local var_201_2 = var_201_1.outOfFrameRequestGatherer:getDebugOutOfFrameRequestList()
	local var_201_3 = arg_201_0:getReplayCompatiblePools()
	local var_201_4 = arg_201_0:getUniverseStateStack()
	local var_201_5

	for iter_201_0, iter_201_1 in ipairs(var_201_4.currentStack) do
		if type(iter_201_1) == "InteractiveReplayUniverseState" or type(iter_201_1) == "ReplayUniverseState" then
			var_201_5 = iter_201_1
		end
	end

	if var_201_5 then
		local var_201_6 = assert(var_201_5.replayPresenter).pools

		if var_201_6 then
			tablex.mergeInto(var_201_3, var_201_6)
		end
	end

	tablex.mergeInto(arg_201_2, {
		scene = arg_201_0.scene,
		crowd = arg_201_0.crowd,
		post = arg_201_0.post,
		camera = arg_201_0.ccamera,
		gamers = arg_201_0.gamers,
		animationProvider = arg_201_0.animationProvider,
		network = arg_201_0.network,
		requestList = var_201_2,
		cameraManager = arg_201_0.cameraManager,
		match = arg_201_0:getMatch(),
		knowledge = arg_201_0.knowledge,
		dofStage = arg_201_0.sceneDofStage,
		bloomStage = arg_201_0.sceneBloomStage,
		materialGroups = arg_201_0.sceneMaterialGroups,
		guidManager = var_201_1.guidManager,
		universe = arg_201_0,
		universeStateStack = arg_201_0:getUniverseStateStack(),
		replayManager = arg_201_0.replayManager,
		replaySaveSystem = arg_201_0.replaySaveSystem,
		ssaoStage = arg_201_0.sceneAmbientOcclusion,
		aofxStage = arg_201_0.sceneAofx,
		toneMapStage = arg_201_0.sceneToneMapStage,
		pools = var_201_3,
		processes = arg_201_0.processes,
		sceneRenderer = arg_201_0.sceneRenderer,
		renderInterface = arg_201_1:getRenderInterface(),
		gameControllerSet = arg_201_0.gameControllerSet,
		services = var_201_1,
		replayState = var_201_5
	})
	var_201_0:decorateHookParams(arg_201_2)
end

function Universe.editSolidState(arg_202_0)
	return arg_202_0.matchSim:editSolidState()
end

function Universe.initRuleState(arg_203_0, arg_203_1, arg_203_2, arg_203_3)
	arg_203_0.matchSim:initRuleState(arg_203_1, arg_203_2, arg_203_3)
end

function Universe.onDisconnectOccurred(arg_204_0, arg_204_1)
	print("Universe:onDisconnectOccurred")

	local var_204_0 = arg_204_0.matchSim
	local var_204_1 = arg_204_0.services

	arg_204_0.match:getComponent("matchOutData").disconnectOccurred = true

	arg_204_0.replayManager:endRecording(var_204_0:getGameObjects(), nil)
	var_204_1.outOfFrameRequestGatherer:disconnect()

	local var_204_2 = arg_204_0.hud and arg_204_0.hud:getElement("notification")

	if var_204_2 then
		var_204_2:queueNotification("disconnect", nil, native.Localise("DisconnectOccurred"))
	end

	arg_204_0.networkErrorOccurred = true
end

function Universe.endMatchPrematurely(arg_205_0, arg_205_1, arg_205_2)
	local var_205_0 = arg_205_0.matchSim

	arg_205_0.replayManager:endRecording(var_205_0:getGameObjects(), var_205_0:getSimulationTime())

	if arg_205_2 then
		if arg_205_2 == sidehelper.none then
			arg_205_0.matchOutData.forceDraw = true
		else
			arg_205_0.matchOutData.quittingSide = arg_205_2
		end
	end

	arg_205_0.services.outOfFrameRequestGatherer:gotoMatchComplete()
end

function Universe.addOutOfFrameRequest(arg_206_0, arg_206_1)
	local var_206_0 = arg_206_0.matchSim:getOutOfFrameRequestList()

	if arg_206_1 then
		var_206_0:add(arg_206_1)
	end
end

function Universe.addOutOfFrameRuleStateRequest(arg_207_0, arg_207_1)
	local var_207_0 = arg_207_0.matchSim:getOutOfFrameRequestList()

	if arg_207_1 then
		local var_207_1 = arg_207_0.services.guidManager

		var_207_0:addRuleStateRequest(arg_207_1, var_207_1:alloc())
	end
end

function Universe.applyCamera(arg_208_0, arg_208_1, arg_208_2, arg_208_3, arg_208_4)
	profile.push("Universe:applyCamera")
	arg_208_0.cameraManager:affectCCamera(arg_208_1, arg_208_2, arg_208_3, arg_208_4)
	profile.pop("Universe:applyCamera")
	profile.push("Universe:applyCamera - setCamera")
	arg_208_0.sceneRenderer:setCamera(arg_208_1, arg_208_0.scene:getStaticBounds(), arg_208_0.lightingModule.currentLightingScene)
	profile.pop("Universe:applyCamera - setCamera")
end

function Universe.onDisposalEvent(arg_209_0, arg_209_1, arg_209_2, arg_209_3, arg_209_4, arg_209_5, arg_209_6, arg_209_7, arg_209_8, arg_209_9)
	return
end

function Universe.offerForfeit(arg_210_0)
	if not arg_210_0.network then
		return
	end

	arg_210_0.network:broadcast(gamemessages.OfferForfeit())
end

function Universe.acceptForfeit(arg_211_0)
	if not arg_211_0.network then
		return
	end

	if arg_211_0:forfeitHasBeenOffered() then
		arg_211_0.network:broadcast(gamemessages.AcceptForfeit())
	else
		arg_211_0.hud:getElement("notification"):queueNotification("forfeit", "delayWarning", native.Localise("OfferedForfietTimedOut"), nil, nil, 7)
	end
end

function Universe.forfeitHasBeenOffered(arg_212_0)
	local var_212_0 = arg_212_0.network

	if not var_212_0 then
		return
	end

	formatPrintT("self.forfeitOfferReceivedTime = %t", arg_212_0.forfeitOfferReceivedTime)
	formatPrintT("sessionTime = %t", arg_212_0.forfeitOfferReceivedTime)
	formatPrintT("sessionTime + ForfeitValidityTime = %t", arg_212_0.forfeitOfferReceivedTime and arg_212_0.forfeitOfferReceivedTime + var_0_5)

	return arg_212_0.forfeitOfferReceivedTime and var_212_0:sessionTime() < arg_212_0.forfeitOfferReceivedTime + var_0_5
end

function Universe.receiveForfeitMessage(arg_213_0)
	local var_213_0 = arg_213_0.network

	if not var_213_0 then
		return
	end

	arg_213_0.forfeitOfferReceivedTime = var_213_0:sessionTime()

	arg_213_0.hud:getElement("notification"):queueNotification("forfeit", "delayWarning", native.Localise("OfferedForfeitRow1"), native.Localise("OfferedForfeitRow2"), nil, 7)
end

function Universe.getCameraManager(arg_214_0)
	return arg_214_0.cameraManager
end

function Universe.getPools(arg_215_0)
	return arg_215_0.pools
end

function Universe.getReplayCompatiblePools(arg_216_0)
	local var_216_0 = arg_216_0:getPools()
	local var_216_1 = arg_216_0:getUniverseStateStack()
	local var_216_2

	for iter_216_0, iter_216_1 in ipairs(var_216_1.currentStack) do
		if type(iter_216_1) == "InteractiveReplayUniverseState" or type(iter_216_1) == "ReplayUniverseState" then
			var_216_2 = iter_216_1
		end
	end

	if var_216_2 then
		var_216_0 = tablex.clone(var_216_0)

		local var_216_3 = assert(var_216_2.replayPresenter).pools

		if var_216_3 then
			tablex.mergeInto(var_216_0, var_216_3)
		end
	end

	return var_216_0
end

function Universe.getProcesses(arg_217_0)
	return arg_217_0.processes
end

function Universe.getScene(arg_218_0)
	return arg_218_0.scene
end

function Universe.getAssets(arg_219_0)
	return arg_219_0.assets
end

function Universe.getHud(arg_220_0)
	return arg_220_0.hud
end

function Universe.getSceneMaterialGroups(arg_221_0)
	return arg_221_0.sceneMaterialGroups
end

function Universe.getGuidManager(arg_222_0)
	return arg_222_0.services.guidManager
end

function Universe.getPostProcessing(arg_223_0)
	return arg_223_0.post
end

function Universe.getServices(arg_224_0)
	return arg_224_0.services
end

function Universe.getCamera(arg_225_0)
	return arg_225_0.ccamera
end

function Universe.getMatchInData(arg_226_0)
	return arg_226_0.matchInData
end

function Universe.getMatchOutData(arg_227_0)
	return arg_227_0.matchOutData
end

function Universe.getMatchInProgressData(arg_228_0)
	return arg_228_0.matchInProgressData
end

function Universe.isGameOver(arg_229_0)
	return arg_229_0.gameOver or false
end

function Universe.setGearOff(arg_230_0)
	arg_230_0.gearOff = true
end

function Universe.setGearOn(arg_231_0)
	arg_231_0.gearOff = false
end

function Universe.fillMatchSaveData(arg_232_0, arg_232_1)
	arg_232_1.matchInData:set(arg_232_0.matchInData)
	arg_232_1.matchOutData:set(arg_232_0.savedMatchOutData)
	arg_232_1.matchInProgressData:set(arg_232_0.savedMatchInProgressData)
end

function Universe.copyMatchInProgressDataToGamestate(arg_233_0, arg_233_1, arg_233_2, arg_233_3, arg_233_4)
	if GAME_CRICKET then
		local var_233_0 = arg_233_2.aiBowlerBlockPool
		local var_233_1 = arg_233_1:getConfidenceInfoPool()

		arg_233_1:getMatchProgressionEntity():set(arg_233_3:getMatchProgressionEntity())
		arg_233_1:getMilestoneEntity():set(arg_233_3:getMilestoneEntity())
		arg_233_1:getScoreEntity():set(arg_233_3:getScoreEntity())
		arg_233_3:retrievePoolData(var_233_0, var_233_1, arg_233_4)
	end
end

function Universe.isInReplay(arg_234_0, arg_234_1)
	arg_234_0.trails.isInReplay = arg_234_1
	arg_234_0.processes.windIndicatorProcess.isInReplay = arg_234_1

	arg_234_0.soundSystem:setInReplay(arg_234_1)
end
