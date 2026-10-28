import("game.humanoid.humanoidtype")
import("rules.penalty.penaltytypes")
import("script-config.design.sound.soundmap")
import("script-config.design.sound.soundmap_rtpc")
import("script-config.design.sound.soundmap_states")
import("script-config.design.sound.soundmap_switches")
import("script-config.design.sound.soundmap_banks")

local var_0_0
local var_0_1 = soundmap_states.States.GoalPost_Component_State
local var_0_2 = var_0_1.stateGroup
local var_0_3 = var_0_1.stateNames
local var_0_4 = 12
local var_0_5 = soundmap.ParticleMap
local var_0_6 = soundmap_switches.Switches
local var_0_7 = var_0_6.StadiumWallType_Switch
local var_0_8 = var_0_7.switchGroup
local var_0_9 = var_0_7.switchNames
local var_0_10 = native.getEnvironment():argExists("novibrations")
local var_0_11 = native.EDisposalType
local var_0_12 = native.EDisposalSubType
local var_0_13 = penaltytypes.infringementTypes
local var_0_14 = {
	[var_0_12.Punt] = {
		med_p_limit = 24,
		low_p_limit = 20
	},
	[var_0_12.Bomb] = {
		med_p_limit = 26,
		low_p_limit = 21
	},
	[var_0_12.FieldGoal] = {
		med_p_limit = 37,
		low_p_limit = 29
	}
}
local var_0_15 = "Sfx"

-- nrl-siren: stadiums outside the UK sound the NRL siren (bank siren_nrl) at
-- half time and full time; UK stadiums keep the stock Siren_default.
-- Siren_AAMI / Siren_MtSmart stay unused. Only enable once the siren_nrl bank
-- is installed: loading a missing bank is a native crash pcall can't catch.
local NrlSirenBank = "siren_nrl"
local NrlSirenEnabled = true
local NrlSirenStadiumCfg = load("intermediatelua.visualconfig.stadium-cfg")
local NrlSirenUKCountries = {}

for _, country in ipairs({ "England", "Wales", "Scotland", "Ireland", "NorthernIreland" }) do
	if native.ECountry[country] ~= nil then
		NrlSirenUKCountries[native.ECountry[country]] = true
	end
end

-- Custom (creator) grounds aren't in stadium-cfg, so they count as non-UK,
-- matching stadium_helper's Australia default for custom stadiums.
local function nrlSirenForMatch(matchInData)
	local ground = matchInData.groundInfo and matchInData.groundInfo.ground
	local stadium = ground and NrlSirenStadiumCfg.Stadiums[ground]
	local country = stadium and stadium.countryEnum

	if country ~= nil and NrlSirenUKCountries[country] then
		return nil
	end

	return NrlSirenBank
end

Class("SoundListenerSfx", function(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6)
	arg_1_0.enabled = true

	if not arg_1_0.enabled then
		return
	end

	arg_1_0.soundSystem = arg_1_1
	arg_1_0.soundManager = arg_1_5

	if PLATFORM_PS5 and not var_0_10 then
		arg_1_0.vibrationSystem = arg_1_6.vibrationSystem
	end

	arg_1_0.hook = arg_1_6.hooks and arg_1_6.hooks:getHook("SoundDebugHook")

	local var_1_0 = soundmap_banks.Banks

	table.insert(arg_1_2, var_1_0.OnField)
	table.insert(arg_1_2, var_1_0.Particles_SFX)
	table.insert(arg_1_2, var_1_0.Intro_Only_Cutscenes)

	arg_1_0.soundObjects = {
		ball = "Ball",
		sfx = "SFX"
	}

	for iter_1_0, iter_1_1 in pairs(arg_1_0.soundObjects) do
		arg_1_5:registerGameObject(iter_1_1)
	end

	local var_1_1 = {}

	for iter_1_2 = 1, var_0_4 do
		local var_1_2 = "particleEmitter" .. iter_1_2

		var_1_1[iter_1_2] = var_1_2

		arg_1_5:registerGameObject(var_1_2)
	end

	arg_1_0.particleEmitterObjects = var_1_1
	arg_1_0.currentParticleEmitterObject = 1
	arg_1_0.hitGroundPlayed = false

	local var_1_3 = arg_1_3:getComponent("matchInData")

	-- nrl-siren: the stock bank loader loads the bank with the match and
	-- unloads it after.
	if NrlSirenEnabled then
		local ok, siren = pcall(nrlSirenForMatch, var_1_3)

		arg_1_0.nrlSiren = ok and siren or nil

		if arg_1_0.nrlSiren then
			table.insert(arg_1_2, {
				name = arg_1_0.nrlSiren,
				bankType = soundmap_banks.BankTypes.Complete,
				sounds = {
					[arg_1_0.nrlSiren] = arg_1_0.nrlSiren
				}
			})
		end
	end

	if var_1_3.isCareerOrCompetitionMode then
		local var_1_4 = var_1_3.stateOfTheSeason and var_1_3.stateOfTheSeason.competitionId
		local var_1_5 = var_0_6.Trophy_Type_Switch
		local var_1_6 = var_1_5.switchGroup
		local var_1_7 = var_1_5.switchNames
		local var_1_8 = var_1_7[var_1_4] or var_1_7.Trophy

		arg_1_5:setSwitchValue(var_1_6, var_1_8)
	end

	local var_1_9 = var_1_3.sex.isFemale
	local var_1_10 = var_0_6.Match_Gender_Switch
	local var_1_11 = var_1_10.switchGroup
	local var_1_12 = var_1_10.switchNames
	local var_1_13 = var_1_9 and var_1_12.Female or var_1_12.Male

	arg_1_5:setSwitchValue(var_1_11, var_1_13, arg_1_0.soundObjects.ball)
	arg_1_5:setSwitchValue(var_1_11, var_1_13, arg_1_0.soundObjects.sfx)
end)

function SoundListenerSfx.unload(arg_2_0, arg_2_1)
	if not arg_2_0.enabled then
		return
	end

	local var_2_0 = arg_2_0.soundManager

	for iter_2_0, iter_2_1 in pairs(arg_2_0.soundObjects) do
		var_2_0:unregisterGameObject(iter_2_1)
	end

	for iter_2_2, iter_2_3 in pairs(arg_2_0.particleEmitterObjects) do
		var_2_0:unregisterGameObject(iter_2_3)
	end
end

function SoundListenerSfx.registerWithMatchSim(arg_3_0, arg_3_1)
	if not arg_3_0.enabled then
		return
	end

	local var_3_0 = arg_3_0.soundSystem

	var_3_0:registerSoundOnlyEvents(arg_3_0, {
		ParticleSoundEvent = arg_3_0.onParticleSoundEvent,
		ScrumEvent = arg_3_0.onScrumEvent,
		TapRestartSoundEvent = arg_3_0.onTapRestartSoundEvent
	})
	var_3_0:registerTentativeEvents(arg_3_0, arg_3_1, {
		AnkleTapEvent = arg_3_0.onAnkleTapEvent,
		BallCollisionEvent = arg_3_0.onBallCollisionEvent,
		CollectBallEvent = arg_3_0.onCollectBallEvent,
		DisposalEvent = arg_3_0.onDisposalEvent,
		HitGroundEvent = arg_3_0.onHitGroundEvent,
		SpillBallEvent = arg_3_0.onSpillBallEvent,
		TackleBlockInitiatedEvent = arg_3_0.onTackleBlockInitiatedEvent,
		TackleCompletedEvent = arg_3_0.onTackleCompletedEvent,
		TryScoredEvent = arg_3_0.onTryScoredEvent
	})
	var_3_0:registerSolidEvents(arg_3_0, arg_3_1, {
		GamerSideChangeEvent = arg_3_0.onGamerSideChangeEvent,
		SixAgainEvent = arg_3_0.onSixAgainEvent,
		TimePeriodExpiredEvent = arg_3_0.onTimePeriodExpiredEvent
	})

	local function var_3_1(arg_4_0, arg_4_1, arg_4_2, arg_4_3, arg_4_4, arg_4_5)
		local var_4_0 = {
			soundObject = arg_3_0.soundObjects.sfx,
			worldPosition = arg_4_4.pos3,
			worldDirection = arg_4_4.facing:tovec3(),
			replay = arg_4_5
		}

		var_0_0(arg_3_0, arg_4_0, var_4_0)

		local var_4_1 = arg_3_0.hook

		if var_4_1 then
			table.insert(var_4_1.footstepSounds, {
				eventName = arg_4_1,
				soundName = arg_4_0,
				time = arg_4_2,
				gameobject = arg_4_4
			})
		end
	end

	arg_3_1:registerWithGameObjects(function(arg_5_0, arg_5_1)
		local function var_5_0(arg_6_0, arg_6_1, arg_6_2, arg_6_3)
			var_3_1("Ball_Bounce", arg_6_0, arg_6_1, arg_6_2, arg_6_3)
		end

		arg_5_1:registerAnimationEventListener(var_5_0, "ballbouncesfx")

		local function var_5_1(arg_7_0, arg_7_1, arg_7_2, arg_7_3)
			var_3_1("Cutscene_Ball_Bounce_Medium", arg_7_0, arg_7_1, arg_7_2, arg_7_3)
		end

		arg_5_1:registerAnimationEventListener(var_5_1, "ballbounce_sfx_med")

		local function var_5_2(arg_8_0, arg_8_1, arg_8_2, arg_8_3)
			var_3_1("Cutscene_Ball_Bounce_Soft", arg_8_0, arg_8_1, arg_8_2, arg_8_3)
		end

		arg_5_1:registerAnimationEventListener(var_5_2, "ballbounce_sfx_soft")

		local function var_5_3(arg_9_0, arg_9_1, arg_9_2, arg_9_3)
			local var_9_0 = true

			var_3_1("Ground_Body_Fall", arg_9_0, arg_9_1, arg_9_2, arg_9_3, var_9_0)
		end

		arg_5_1:registerAnimationEventListener(var_5_3, "ground_impact_sound")

		local function var_5_4(arg_10_0, arg_10_1, arg_10_2, arg_10_3)
			local var_10_0 = true

			var_3_1("Ground_Slide", arg_10_0, arg_10_1, arg_10_2, arg_10_3, var_10_0)
		end

		arg_5_1:registerAnimationEventListener(var_5_4, "sfx_ground_slide")
	end, humanoidtype.TypeId)
end

function SoundListenerSfx.update(arg_11_0, arg_11_1, arg_11_2, arg_11_3, arg_11_4, arg_11_5, arg_11_6)
	if not arg_11_0.enabled then
		return
	end
end

function SoundListenerSfx.onAnkleTapEvent(arg_12_0, arg_12_1, arg_12_2, arg_12_3, arg_12_4, arg_12_5, arg_12_6, arg_12_7, arg_12_8, arg_12_9)
	local var_12_0 = {
		replay = true,
		noDuplicate = true
	}

	var_0_0(arg_12_0, "Ankle_Tap_Tackle", var_12_0)

	if arg_12_0.vibrationSystem then
		local var_12_1 = arg_12_8:getGameObject(arg_12_1.maker)
		local var_12_2 = false
		local var_12_3 = arg_12_3.localGamers.asTable

		for iter_12_0, iter_12_1 in ipairs(var_12_3) do
			arg_12_0.vibrationSystem:playVibration("AnkleTapTackle_1", iter_12_1, var_12_2)
		end
	end
end

function SoundListenerSfx.onBallCollisionEvent(arg_13_0, arg_13_1, arg_13_2, arg_13_3, arg_13_4, arg_13_5, arg_13_6, arg_13_7, arg_13_8, arg_13_9)
	local var_13_0 = arg_13_6:getComponent("matchInData")
	local var_13_1 = arg_13_8:getGameObject(arg_13_1.maker)
	local var_13_2 = arg_13_1.velocity

	if not var_13_2 then
		return
	end

	local var_13_3 = native.length3(var_13_2)
	local var_13_4 = arg_13_8:getBallObject().pos3
	local var_13_5 = arg_13_1.colliderType
	local var_13_6 = {
		noDuplicate = true,
		replay = true,
		soundObject = arg_13_0.soundObjects.ball,
		rtpcValues = {
			rtpcName = soundmap_rtpc.inGameRTPCs.ballVelocity.rtpc,
			rtpcValue = var_13_3
		},
		worldPosition = var_13_4
	}
	local var_13_7
	local var_13_8 = var_13_5 == native.CPhysicsEnum.GoalPostPadding

	if var_13_5 == native.CPhysicsEnum.GoalPostCrossbar or var_13_5 == native.CPhysicsEnum.GoalPostVertical or var_13_8 then
		local var_13_9 = var_13_8 and var_0_3.Padding or var_0_3.Metal

		var_13_6.stateValues = {
			stateGroup = var_0_2,
			stateName = var_13_9
		}

		var_0_0(arg_13_0, "Ball_Impact_Goal_Post", var_13_6)

		if arg_13_0.vibrationSystem then
			local var_13_10 = arg_13_4.camera.dir.x
			local var_13_11 = arg_13_1.position.z

			if var_13_10 > 0 and var_13_11 < 0 then
				var_13_7 = "HitGoalPostEvent_Left_Emphasis"
			elseif var_13_10 < 0 and var_13_11 > 0 then
				var_13_7 = "HitGoalPostEvent_Left_Emphasis"
			else
				var_13_7 = "HitGoalPostEvent_Right_Emphasis"
			end
		end
	elseif var_13_5 == native.CPhysicsEnum.StadiumWall then
		local var_13_12 = var_0_9.Default

		var_13_6.switchValues = {
			switchGroup = var_0_8,
			switchName = var_13_12
		}

		var_0_0(arg_13_0, "Ball_Impact_Hard_Surface", var_13_6)

		var_13_7 = "BallHitStadiumWallEvent"
	elseif var_13_5 == native.CPhysicsEnum.Net then
		local var_13_13 = var_0_9.Netting

		var_13_6.switchValues = {
			switchGroup = var_0_8,
			switchName = var_13_13
		}

		var_0_0(arg_13_0, "Ball_Impact_Hard_Surface", var_13_6)
	elseif var_13_5 == native.CPhysicsEnum.Ground then
		var_0_0(arg_13_0, "Ball_Bounce", var_13_6)

		if var_13_3 > 25 then
			var_13_7 = "BallHitGround_Hard"
		elseif var_13_3 > 9 then
			var_13_7 = "BallHitGround_Soft"
		end
	elseif var_13_5 == native.CPhysicsEnum.Player then
		var_0_0(arg_13_0, "Ball_Impact_Player", var_13_6)

		var_13_7 = "BallHitPlayer"
	end

	if arg_13_0.vibrationSystem and var_13_7 then
		local var_13_14 = arg_13_3.localGamers.asTable
		local var_13_15 = false

		for iter_13_0, iter_13_1 in ipairs(var_13_14) do
			arg_13_0.vibrationSystem:playVibration(var_13_7, iter_13_1, var_13_15)
		end
	end
end

function SoundListenerSfx.onCollectBallEvent(arg_14_0, arg_14_1, arg_14_2, arg_14_3, arg_14_4, arg_14_5, arg_14_6, arg_14_7, arg_14_8, arg_14_9)
	local var_14_0 = arg_14_8:getBallObject().pos3
	local var_14_1 = {
		replay = true,
		soundObject = arg_14_0.soundObjects.ball,
		worldPosition = var_14_0
	}
	local var_14_2
	local var_14_3 = arg_14_1.disposalSubType == var_0_12.PlayTheBall

	if arg_14_1.caughtOnFull and not var_14_3 then
		if arg_14_1.disposalType == var_0_11.Kick then
			var_0_0(arg_14_0, "Ball_Catch_Chest", var_14_1)

			var_14_2 = "BallCatchChestEvent"
		else
			var_0_0(arg_14_0, "Ball_Catch", var_14_1)

			var_14_2 = "BallCatchEvent"
		end
	elseif not arg_14_1.caughtOnFull or var_14_3 then
		var_0_0(arg_14_0, "Ball_Pickup")

		var_14_2 = "CollectBallEvent"
	end

	if arg_14_0.vibrationSystem and var_14_2 then
		local var_14_4 = arg_14_8:getGameObject(arg_14_1.maker):getGamer()
		local var_14_5 = false

		arg_14_0.vibrationSystem:playVibration(var_14_2, var_14_4, var_14_5)
	end
end

function SoundListenerSfx.onDisposalEvent(arg_15_0, arg_15_1, arg_15_2, arg_15_3, arg_15_4, arg_15_5, arg_15_6, arg_15_7, arg_15_8, arg_15_9)
	local var_15_0 = arg_15_1.disposalInfo

	if var_15_0 then
		local var_15_1 = {
			replay = true,
			soundObject = arg_15_0.soundObjects.ball
		}
		local var_15_2 = arg_15_8:getGameObject(arg_15_1.maker)
		local var_15_3 = var_15_0.disposalType
		local var_15_4 = var_15_0.disposalSubType
		local var_15_5

		if var_15_3 == var_0_11.Kick and var_15_4 ~= var_0_12.PlayTheBall and not var_15_0.isAfterTouch then
			if var_15_4 == var_0_12.KickOff or var_15_4 == var_0_12.Conversion or var_15_4 == var_0_12.PenaltyGoal then
				var_0_0(arg_15_0, "Ball_Kick_Conversion", var_15_1)
			elseif var_15_4 == var_0_12.KickOffDrop or var_15_4 == var_0_12.ConversionDrop or var_15_4 == var_0_12.PenaltyGoalDrop or var_15_4 == var_0_12.DropOut then
				var_0_0(arg_15_0, "Ball_Drop_Kick", var_15_1)
			else
				var_0_0(arg_15_0, "Ball_Kick", var_15_1)
			end

			local var_15_6 = {
				replay = true,
				soundObject = arg_15_0.soundObjects.sfx,
				worldPosition = var_15_2.pos3,
				worldDirection = var_15_2.facing:tovec3()
			}

			var_0_0(arg_15_0, "anim_plr_cloth_kick", var_15_6)

			if arg_15_0.vibrationSystem then
				local var_15_7 = var_15_0.initialVelocity
				local var_15_8 = var_15_7 and native.length3(var_15_7)
				local var_15_9 = var_0_14[var_15_4]

				if not var_15_9 then
					var_15_5 = "Kick_MediumPower"
				elseif var_15_8 < var_15_9.low_p_limit then
					var_15_5 = "Kick_LowPower"
				elseif var_15_8 < var_15_9.med_p_limit then
					var_15_5 = "Kick_MediumPower"
				else
					var_15_5 = "Kick_HighPower"
				end
			end
		elseif var_15_3 == var_0_11.Pass then
			var_0_0(arg_15_0, "Pass", var_15_1)

			var_15_5 = "PassBallEvent"
		end

		if arg_15_0.vibrationSystem and var_15_5 then
			local var_15_10 = false
			local var_15_11 = var_15_2:getGamer()

			arg_15_0.vibrationSystem:playVibration(var_15_5, var_15_11, var_15_10)
		end

		arg_15_0.hitGroundPlayed = false
	end
end

function SoundListenerSfx.onGamerSideChangeEvent(arg_16_0, arg_16_1, arg_16_2, arg_16_3, arg_16_4, arg_16_5, arg_16_6, arg_16_7, arg_16_8, arg_16_9)
	local var_16_0 = arg_16_1.time
	local var_16_1 = native.ESide.Home:toInt()
	local var_16_2 = native.ESide.Away:toInt()
	local var_16_3 = arg_16_7:getRuleState()

	if var_16_3:getSwitchingEnabledForSide(arg_16_7, var_16_1, var_16_0) and var_16_3:getSwitchingEnabledForSide(arg_16_7, var_16_2, var_16_0) then
		var_0_0(arg_16_0, "UI_Team_Swap")

		if arg_16_0.vibrationSystem then
			local var_16_4 = false

			for iter_16_0, iter_16_1 in ipairs(arg_16_3.localGamers.asTable) do
				if iter_16_1.side == arg_16_1.previousSide then
					local var_16_5 = iter_16_1

					arg_16_0.vibrationSystem:playVibration("UI_Team_Swap", var_16_5, var_16_4)
				end
			end
		end
	else
		var_0_0(arg_16_0, "UI_Team_Swap_Queued")
	end
end

function SoundListenerSfx.onHitGroundEvent(arg_17_0, arg_17_1, arg_17_2, arg_17_3, arg_17_4, arg_17_5, arg_17_6, arg_17_7, arg_17_8, arg_17_9)
	if not arg_17_0.hitGroundPlayed then
		local var_17_0 = arg_17_8:getGameObject(arg_17_1.maker)
		local var_17_1 = {
			replay = true,
			soundObject = arg_17_0.soundObjects.sfx,
			worldPosition = var_17_0.pos3,
			worldDirection = var_17_0.facing:tovec3()
		}

		var_0_0(arg_17_0, "Ground_Tackle", var_17_1)

		arg_17_0.hitGroundPlayed = true
	end
end

function SoundListenerSfx.onSixAgainEvent(arg_18_0, arg_18_1, arg_18_2, arg_18_3, arg_18_4, arg_18_5, arg_18_6, arg_18_7, arg_18_8, arg_18_9)
	local var_18_0
	local var_18_1 = arg_18_1.penaltyType

	if var_18_1 == var_0_13.HeldInTackle then
		var_18_0 = "sixAgainRuleRuckInfringement"
	elseif var_18_1 == var_0_13.OffSide then
		var_18_0 = "sixAgainRule10Metres"
	end

	if var_18_0 then
		arg_18_0.soundSystem:stopEvents({
			tags = {
				"Referee"
			}
		})
		var_0_0(arg_18_0, var_18_0, {
			controllerOutput = true
		})
	end
end

function SoundListenerSfx.onSpillBallEvent(arg_19_0, arg_19_1, arg_19_2, arg_19_3, arg_19_4, arg_19_5, arg_19_6, arg_19_7, arg_19_8, arg_19_9)
	if arg_19_0.vibrationSystem then
		local var_19_0 = arg_19_8:getGameObject(arg_19_1.maker):getGamer()
		local var_19_1 = false

		arg_19_0.vibrationSystem:playVibration("SpillBallEvent", var_19_0, var_19_1)
	end
end

function SoundListenerSfx.onTackleBlockInitiatedEvent(arg_20_0, arg_20_1, arg_20_2, arg_20_3, arg_20_4, arg_20_5, arg_20_6, arg_20_7, arg_20_8, arg_20_9)
	local var_20_0 = arg_20_4.knowledgeBank.ballInfo
	local var_20_1 = var_20_0.ownerId

	if var_20_1 then
		local var_20_2 = arg_20_8:getGameObject(var_20_1)
		local var_20_3 = {
			replay = true,
			soundObject = arg_20_0.soundObjects.sfx,
			worldPosition = var_20_2.pos3,
			worldDirection = var_20_2.facing:tovec3()
		}
		local var_20_4 = native.length2(var_20_0.groundVelocity)
		local var_20_5 = arg_20_7:getActiveTackleEntity():getTackleForTackleeId(var_20_1)
		local var_20_6 = var_20_5 and var_20_5:getParticipantCount() or 0

		if var_20_4 >= 7 or var_20_6 > 2 then
			var_0_0(arg_20_0, "Body_Tackle", var_20_3)
			var_0_0(arg_20_0, "anim_plr_cloth_getup", var_20_3)
		else
			var_0_0(arg_20_0, "Body_Tackle_Soft", var_20_3)
			var_0_0(arg_20_0, "anim_plr_cloth_getdown", var_20_3)
		end
	end
end

function SoundListenerSfx.onTackleCompletedEvent(arg_21_0, arg_21_1, arg_21_2, arg_21_3, arg_21_4, arg_21_5, arg_21_6, arg_21_7, arg_21_8, arg_21_9)
	local var_21_0 = arg_21_8:getGameObject(arg_21_1.maker)
	local var_21_1 = {
		replay = true,
		soundObject = arg_21_0.soundObjects.sfx,
		worldPosition = var_21_0.pos3,
		worldDirection = var_21_0.facing:tovec3()
	}

	var_0_0(arg_21_0, "anim_plr_cloth_kick", var_21_1)

	if not arg_21_0.hitGroundPlayed then
		var_0_0(arg_21_0, "Ground_Tackle", var_21_1)

		arg_21_0.hitGroundPlayed = true
	end
end

function SoundListenerSfx.onTimePeriodExpiredEvent(arg_22_0, arg_22_1, arg_22_2, arg_22_3, arg_22_4, arg_22_5, arg_22_6, arg_22_7, arg_22_8, arg_22_9)
	if arg_22_0.nrlSiren then
		var_0_0(arg_22_0, arg_22_0.nrlSiren, {
			wwiseEvent = arg_22_0.nrlSiren
		})

		return
	end

	var_0_0(arg_22_0, "siren_default")
end

function SoundListenerSfx.onTryScoredEvent(arg_23_0, arg_23_1, arg_23_2, arg_23_3, arg_23_4, arg_23_5, arg_23_6, arg_23_7, arg_23_8, arg_23_9)
	local var_23_0 = arg_23_8:getGameObject(arg_23_1.scorer)
	local var_23_1 = {
		replay = true,
		soundObject = arg_23_0.soundObjects.sfx,
		worldPosition = var_23_0.pos3,
		worldDirection = var_23_0.facing:tovec3()
	}
	local var_23_2
	local var_23_3

	if arg_23_1.divingTry then
		var_0_0(arg_23_0, "anim_plr_cloth_getdown", var_23_1)
		var_0_0(arg_23_0, "Try_Touchdown", var_23_1)
		var_0_0(arg_23_0, "Ball_Touch_Down", var_23_1, {
			delay = 0.18
		})

		var_23_2 = 0.18
		var_23_3 = "TryTouchDownDive"
	else
		var_0_0(arg_23_0, "Ball_Touch_Down", var_23_1)

		var_23_2 = 0
		var_23_3 = "TryTouchDownStanding"
	end

	if arg_23_0.vibrationSystem then
		local var_23_4 = var_23_0:getGamer()
		local var_23_5 = false

		arg_23_0.vibrationSystem:playVibration(var_23_3, var_23_4, var_23_5, var_23_2)
	end
end

function SoundListenerSfx.onParticleSoundEvent(arg_24_0, arg_24_1, arg_24_2, arg_24_3, arg_24_4, arg_24_5, arg_24_6)
	local var_24_0 = arg_24_1.particleName
	local var_24_1 = arg_24_1.particles

	if var_24_0 and var_24_1 then
		local var_24_2 = var_0_5[var_24_0]

		if var_24_2 then
			local var_24_3 = arg_24_0.particleEmitterObjects
			local var_24_4 = arg_24_0.currentParticleEmitterObject

			for iter_24_0, iter_24_1 in ipairs(var_24_1) do
				local var_24_5 = iter_24_1.position
				local var_24_6 = var_24_3[var_24_4]
				local var_24_7 = {
					soundObject = var_24_6,
					worldPosition = var_24_5
				}

				var_0_0(arg_24_0, var_24_2, var_24_7)

				var_24_4 = var_24_4 == var_0_4 and 1 or var_24_4 + 1
			end
		end
	end
end

function SoundListenerSfx.onScrumEvent(arg_25_0, arg_25_1, arg_25_2, arg_25_3, arg_25_4, arg_25_5, arg_25_6)
	local var_25_0 = arg_25_1.scrumPosition and arg_25_1.scrumPosition:tovec3()
	local var_25_1 = arg_25_1.directionOfPlay and arg_25_1.directionOfPlay:tovec3()
	local var_25_2 = {
		replay = true,
		soundObject = arg_25_0.soundObjects.sfx,
		worldPosition = var_25_0,
		worldDirection = var_25_1
	}

	var_0_0(arg_25_0, "anim_scrum_setup", var_25_2)
end

function SoundListenerSfx.onTapRestartSoundEvent(arg_26_0, arg_26_1, arg_26_2, arg_26_3, arg_26_4, arg_26_5, arg_26_6)
	var_0_0(arg_26_0, "Ball_Kick_TapRestart")

	local var_26_0 = arg_26_5:getGameObject(arg_26_1.maker)
	local var_26_1 = {
		replay = true,
		soundObject = arg_26_0.soundObjects.sfx,
		worldPosition = var_26_0.pos3,
		worldDirection = var_26_0.facing:tovec3()
	}

	var_0_0(arg_26_0, "anim_plr_cloth_getup", var_26_1)

	if arg_26_0.vibrationSystem then
		local var_26_2 = var_26_0:getGamer()
		local var_26_3 = false

		arg_26_0.vibrationSystem:playVibration("KickTapRestart", var_26_2, var_26_3)
	end
end

function var_0_0(arg_27_0, arg_27_1, arg_27_2)
	return arg_27_0.soundSystem:queueEvent(arg_27_1, arg_27_2, var_0_15)
end
