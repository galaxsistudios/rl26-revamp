import("base.side.sidehelper")
import("intermediatelua.cutscenes.data.cutscenedata_copier")

local var_0_0 = native.ECutsceneOrigin.PrimaryActor
local var_0_1 = native.ECutsceneOrigin.PrimaryActorFacingOrigin
local var_0_2 = native.ECutsceneOrigin.CenterAroundActors
local var_0_3 = native.ECutsceneOrigin.World
local var_0_4 = native.ECutsceneOrigin.Custom

default_near = 0.5
default_far = 1200
CutscenesForStadiumClone = {
	rl1_intro_lockers_home = true,
	rl1_intro_lockers_away = true,
	rl1_intro_lockers_away_02 = true,
	rl1_intro_lockers_home_02 = true
}
CutsceneData = {
	rl1_intro_lockers_away = {
		playerPosY = 0.2,
		worldRot = 0,
		animsetName = "rl1_intro_lockers_away",
		cameraAndLightingYOffset = 0.2,
		povCameraAllowed = false,
		lightingScenes = {
			"cs_intro_lockers_01"
		},
		cutsceneOrigin = var_0_4,
		worldPos = {
			0,
			0
		},
		clampScale = native.CRange(0.95, 1.05),
		actors = {
			{
				animName = "p1_rl1_intro_lockers_away",
				name = "p1_cameraplayer",
				syncOnFrame = 0,
				optional = true,
				filter = {
					specialRole = "captain",
					actorType = "player",
					side = sidehelper.away
				}
			},
			{
				animName = "p2_rl1_intro_lockers_away",
				optional = true,
				syncOnFrame = 0,
				filter = {
					actorType = "player",
					side = sidehelper.away
				}
			},
			{
				animName = "p3_rl1_intro_lockers_away",
				optional = true,
				syncOnFrame = 0,
				filter = {
					actorType = "player",
					side = sidehelper.away
				}
			},
			{
				animName = "p4_rl1_intro_lockers_away",
				optional = true,
				syncOnFrame = 0,
				filter = {
					actorType = "player",
					side = sidehelper.away
				}
			},
			{
				animName = "p5_rl1_intro_lockers_away",
				optional = true,
				syncOnFrame = 0,
				filter = {
					actorType = "player",
					side = sidehelper.away
				}
			},
			{
				animName = "p6_rl1_intro_lockers_away",
				optional = true,
				syncOnFrame = 0,
				filter = {
					actorType = "player",
					side = sidehelper.away
				}
			},
			{
				animName = "p7_rl1_intro_lockers_away",
				optional = true,
				syncOnFrame = 0,
				filter = {
					actorType = "player",
					side = sidehelper.away
				}
			},
			{
				animName = "p8_rl1_intro_lockers_away",
				optional = true,
				syncOnFrame = 0,
				filter = {
					actorType = "player",
					side = sidehelper.away
				}
			},
			{
				animName = "p9_rl1_intro_lockers_away",
				optional = true,
				syncOnFrame = 0,
				filter = {
					actorType = "player",
					side = sidehelper.away
				}
			},
			{
				animName = "p10_rl1_intro_lockers_away",
				optional = true,
				syncOnFrame = 0,
				filter = {
					actorType = "player",
					side = sidehelper.away
				}
			},
			{
				animName = "p11_rl1_intro_lockers_away",
				optional = true,
				syncOnFrame = 0,
				filter = {
					actorType = "player",
					side = sidehelper.away
				}
			},
			{
				animName = "p12_rl1_intro_lockers_away",
				optional = true,
				syncOnFrame = 0,
				filter = {
					actorType = "player",
					side = sidehelper.away
				}
			},
			{
				animName = "p13_rl1_intro_lockers_away",
				optional = true,
				syncOnFrame = 0,
				filter = {
					actorType = "player",
					side = sidehelper.away
				}
			}
		},
		props = {
			{
				propName = "props/cutscene/models/lockerRoom01.model",
				position = {
					0,
					0.2,
					0
				},
				orientation = {
					0,
					0,
					0
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_intro_lockers_away",
				name = "cs_camera01",
				near = 0.5,
				jointName = "cs_camera01",
				dof = {
					{
						intensity = 0,
						nearIntensity = 0,
						focusDistance = "auto",
						frame = 0,
						aperture = 0,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_intro_lockers_away",
				name = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera02",
				scaleCameraHeightToActorIndex = 1,
				dof = {
					{
						intensity = 0,
						nearIntensity = 0,
						focusDistance = "auto",
						frame = 0,
						aperture = 0,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_intro_lockers_away",
				name = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.5,
				jointName = "cs_camera03",
				scaleCameraHeightToActorIndex = 1,
				dof = {
					{
						intensity = 0,
						nearIntensity = 0,
						focusDistance = "auto",
						frame = 0,
						aperture = 0,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_intro_lockers_away",
				name = "cs_camera04",
				near = 0.5,
				jointName = "cs_camera04",
				dof = {
					{
						intensity = 0,
						nearIntensity = 0,
						focusDistance = "auto",
						frame = 0,
						aperture = 0,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_intro_lockers_away",
				name = "cs_camera06",
				near = 0.5,
				jointName = "cs_camera06",
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 0,
						focusDistance = 0.7,
						frame = 0,
						aperture = 2.25
					},
					{
						intensity = 1.5,
						nearIntensity = 0,
						focusDistance = 0.7,
						frame = 35,
						aperture = 2.25
					},
					{
						intensity = 0.2,
						nearIntensity = 1.5,
						focusDistance = 2.6,
						frame = 48,
						aperture = 0.8
					}
				}
			},
			{
				animName = "p1_rl1_intro_lockers_away",
				name = "cs_camera07",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.5,
				jointName = "cs_camera07",
				scaleCameraHeightToActorIndex = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1.5,
						focusDistance = 2,
						frame = 0,
						aperture = 2
					},
					{
						intensity = 1,
						nearIntensity = 1.5,
						focusDistance = 2,
						frame = 12,
						aperture = 2
					},
					{
						intensity = 1.5,
						nearIntensity = 1.5,
						focusDistance = 1.27,
						frame = 19,
						aperture = 1.5
					},
					{
						intensity = 1.5,
						nearIntensity = 1.5,
						focusDistance = 1.27,
						frame = 29,
						aperture = 1.5
					},
					{
						intensity = 1,
						nearIntensity = 1.5,
						focusDistance = 3,
						frame = 44,
						aperture = 2
					}
				}
			}
		},
		playbackEvents = {
			{
				frame = 0,
				name = "EnableLightGroup",
				layerName = "stadium_lights",
				enable = false
			},
			{
				frame = 0,
				name = "EnableLightGroup",
				layerName = "sun",
				enable = false
			},
			{
				frame = 0,
				name = "SetRainIntensityEvent",
				rainfallOverride = 0
			},
			{
				onFinalise = true,
				name = "SetRainIntensityEvent",
				rainfallOverride = native.CWeather.RainfallOverrideDisabled
			},
			{
				frame = 0,
				name = "RebakeSpecEvent"
			}
		},
		cuts = {
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera02"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera03"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera04"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera01"
				}
			}
		},
		soundEvents = {
			{
				frame = 0,
				eventTable = {
					soundKey = "sfx_cutscene_ambience_gf_stadium_wide_01",
					type = "StopSoundEvent"
				}
			},
			{
				frame = 120,
				eventTable = {
					soundKey = "sfx_cutscene_boots_locker_room_intro_01",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 0,
				eventTable = {
					soundKey = "sfx_cutscene_ambience_locker_room_intro_01",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 0,
				eventTable = {
					soundKey = "sfx_cutscene_player_vocals_locker_room_intro_01",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 0,
				eventTable = {
					soundKey = "sfx_cutscene_announcer_gf_locker_room_intro_02",
					type = "PlaySoundEvent"
				}
			}
		}
	},
	rl1_intro_lockers_away_02 = {
		playerPosY = 0.2,
		animsetName = "rl1_intro_lockers_away",
		worldRot = 0,
		cameraAndLightingYOffset = 0.2,
		povCameraAllowed = false,
		lightingScenes = {
			"cs_intro_lockers_standard_01"
		},
		cutsceneOrigin = var_0_4,
		worldPos = {
			0,
			0
		},
		actors = {
			{
				animName = "p1_rl1_intro_lockers_away_02",
				name = "player01",
				syncTo = "world",
				syncOnFrame = 0,
				optional = true,
				filter = {
					specialRole = "captain",
					actorType = "player",
					side = sidehelper.away
				}
			},
			{
				animName = "p2_rl1_intro_lockers_away_02",
				name = "player02",
				syncOnFrame = 0,
				optional = true,
				filter = {
					actorType = "player",
					side = sidehelper.away
				}
			},
			{
				animName = "p3_rl1_intro_lockers_away_02",
				name = "player03",
				syncOnFrame = 0,
				optional = true,
				filter = {
					actorType = "player",
					side = sidehelper.away
				}
			},
			{
				animName = "p4_rl1_intro_lockers_away_02",
				name = "player04",
				syncOnFrame = 0,
				optional = true,
				filter = {
					actorType = "player",
					side = sidehelper.away
				}
			},
			{
				animName = "p5_rl1_intro_lockers_away_02",
				name = "player05",
				syncOnFrame = 0,
				optional = true,
				filter = {
					actorType = "player",
					side = sidehelper.away
				}
			},
			{
				animName = "p6_rl1_intro_lockers_away_02",
				name = "player06",
				syncOnFrame = 0,
				optional = true,
				filter = {
					actorType = "player",
					side = sidehelper.away
				}
			},
			{
				animName = "p7_rl1_intro_lockers_away_02",
				name = "player07",
				syncOnFrame = 0,
				optional = true,
				filter = {
					actorType = "player",
					side = sidehelper.away
				}
			},
			{
				animName = "p8_rl1_intro_lockers_away_02",
				name = "player08",
				syncOnFrame = 0,
				optional = true,
				filter = {
					actorType = "player",
					side = sidehelper.away
				}
			},
			{
				animName = "p9_rl1_intro_lockers_away_02",
				name = "player09",
				syncOnFrame = 0,
				optional = true,
				filter = {
					actorType = "player",
					side = sidehelper.away
				}
			},
			{
				animName = "p10_rl1_intro_lockers_away_02",
				name = "player10",
				syncOnFrame = 0,
				optional = true,
				filter = {
					actorType = "player",
					side = sidehelper.away
				}
			},
			{
				animName = "p11_rl1_intro_lockers_away_02",
				name = "player11",
				syncOnFrame = 0,
				optional = true,
				filter = {
					actorType = "player",
					side = sidehelper.away
				}
			},
			{
				animName = "p12_rl1_intro_lockers_away_02",
				name = "player12",
				syncOnFrame = 0,
				optional = true,
				filter = {
					actorType = "player",
					side = sidehelper.away
				}
			},
			{
				animName = "p13_rl1_intro_lockers_away_02",
				name = "player13",
				syncOnFrame = 0,
				optional = true,
				filter = {
					actorType = "player",
					side = sidehelper.away
				}
			}
		},
		props = {
			{
				propName = "props/cutscene/models/lockerRoom01.model",
				position = {
					0,
					0.2,
					0
				},
				orientation = {
					0,
					0,
					0
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_intro_lockers_away_02",
				name = "cs_camera09",
				moveRelativeToActorLabel = "player01",
				near = 0.1,
				jointName = "cs_camera09",
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 0.5,
						focusDistance = "auto",
						frame = 0,
						aperture = 3,
						targetActor = "player01",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_intro_lockers_away_02",
				name = "cs_camera10",
				moveRelativeToActorLabel = "player01",
				near = 0.1,
				jointName = "cs_camera10",
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 0.5,
						focusDistance = "auto",
						frame = 0,
						aperture = 3,
						targetActor = "player01",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_intro_lockers_away_02",
				name = "cs_camera11",
				moveRelativeToActorLabel = "player01",
				near = 0.1,
				jointName = "cs_camera11",
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 0.5,
						focusDistance = "auto",
						frame = 0,
						aperture = 3,
						targetActor = "player01",
						autoDofJoints = {
							"hips"
						}
					}
				}
			}
		},
		playbackEvents = {
			{
				frame = 0,
				name = "EnableLightGroup",
				layerName = "stadium_lights",
				enable = false
			},
			{
				frame = 0,
				name = "EnableLightGroup",
				layerName = "sun",
				enable = false
			},
			{
				frame = 0,
				name = "SetRainIntensityEvent",
				rainfallOverride = 0
			},
			{
				onFinalise = true,
				name = "SetRainIntensityEvent",
				rainfallOverride = native.CWeather.RainfallOverrideDisabled
			},
			{
				frame = 0,
				name = "RebakeSpecEvent"
			}
		},
		cuts = {
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera11"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			}
		},
		soundEvents = {
			{
				frame = 170,
				eventTable = {
					soundKey = "sfx_cutscene_crowd_reset_lp_01",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 260,
				eventTable = {
					soundKey = "sfx_cutscene_boots_locker_room_intro_01",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 2,
				eventTable = {
					soundKey = "sfx_cutscene_ambience_locker_room_intro_01",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 2,
				eventTable = {
					soundKey = "sfx_cutscene_player_vocals_locker_room_intro_01",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 2,
				eventTable = {
					soundKey = "sfx_cutscene_announcer_gf_locker_room_intro_01",
					type = "PlaySoundEvent"
				}
			}
		}
	},
	rl1_intro_lockers_home = {
		playerPosY = 0.2,
		worldRot = 0,
		animsetName = "rl1_intro_lockers_home",
		cameraAndLightingYOffset = 0.2,
		povCameraAllowed = false,
		lightingScenes = {
			"cs_intro_lockers_01"
		},
		cutsceneOrigin = var_0_4,
		worldPos = {
			0,
			0
		},
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_intro_lockers_home",
				name = "p1_cameraplayer",
				syncOnFrame = 0,
				optional = true,
				filter = {
					actorType = "player",
					side = sidehelper.home
				}
			},
			{
				animName = "p2_rl1_intro_lockers_home",
				optional = true,
				syncOnFrame = 0,
				filter = {
					actorType = "player",
					side = sidehelper.home
				}
			},
			{
				animName = "p3_rl1_intro_lockers_home",
				optional = true,
				syncOnFrame = 0,
				filter = {
					actorType = "player",
					side = sidehelper.home
				}
			},
			{
				animName = "p4_rl1_intro_lockers_home",
				name = "p4_cameraplayer",
				syncOnFrame = 0,
				optional = true,
				filter = {
					actorType = "player",
					side = sidehelper.home
				}
			},
			{
				animName = "p5_rl1_intro_lockers_home",
				optional = true,
				syncOnFrame = 0,
				filter = {
					actorType = "player",
					side = sidehelper.home
				}
			},
			{
				animName = "p6_rl1_intro_lockers_home",
				name = "p6_cameraplayer",
				syncOnFrame = 44,
				optional = true,
				filter = {
					actorType = "player",
					side = sidehelper.home
				}
			},
			{
				animName = "p7_rl1_intro_lockers_home",
				optional = true,
				syncOnFrame = 44,
				filter = {
					actorType = "player",
					side = sidehelper.home
				}
			},
			{
				animName = "p8_rl1_intro_lockers_home",
				optional = true,
				syncOnFrame = 44,
				filter = {
					actorType = "player",
					side = sidehelper.home
				}
			},
			{
				animName = "p9_rl1_intro_lockers_home",
				optional = true,
				syncOnFrame = 0,
				filter = {
					actorType = "player",
					side = sidehelper.home
				}
			},
			{
				animName = "p10_rl1_intro_lockers_home",
				name = "p10_cameraplayer",
				syncOnFrame = 0,
				optional = true,
				filter = {
					actorType = "player",
					side = sidehelper.home
				}
			},
			{
				animName = "p11_rl1_intro_lockers_home",
				optional = true,
				syncOnFrame = 0,
				filter = {
					actorType = "player",
					side = sidehelper.home
				}
			},
			{
				animName = "p12_rl1_intro_lockers_home",
				optional = true,
				syncOnFrame = 0,
				filter = {
					actorType = "player",
					side = sidehelper.home
				}
			},
			{
				animName = "p13_rl1_intro_lockers_home",
				optional = true,
				syncOnFrame = 0,
				filter = {
					actorType = "player",
					side = sidehelper.home
				}
			}
		},
		props = {
			{
				propName = "props/cutscene/models/lockerRoom01.model",
				position = {
					0,
					0.2,
					0
				},
				orientation = {
					0,
					0,
					0
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_intro_lockers_home",
				name = "cs_camera01",
				near = 0.1,
				jointName = "cs_camera01",
				dof = {
					{
						intensity = 0,
						nearIntensity = 0,
						focusDistance = 3,
						frame = 0,
						aperture = 0
					}
				}
			},
			{
				animName = "p1_rl1_intro_lockers_home",
				name = "cs_camera02",
				near = 0.1,
				jointName = "cs_camera02",
				dof = {
					{
						intensity = 0,
						nearIntensity = 0,
						focusDistance = 3,
						frame = 0,
						aperture = 0
					}
				}
			},
			{
				animName = "p1_rl1_intro_lockers_home",
				name = "cs_camera03",
				moveRelativeToActorLabel = "p4_cameraplayer",
				near = 0.1,
				jointName = "cs_camera03",
				scaleCameraHeightToActorIndex = 4,
				dof = {
					{
						intensity = 0,
						nearIntensity = 0,
						focusDistance = "auto",
						frame = 0,
						aperture = 0,
						targetActor = "p3_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_intro_lockers_home",
				name = "cs_camera04",
				moveRelativeToActorLabel = "p10_cameraplayer",
				near = 0.1,
				jointName = "cs_camera04",
				scaleCameraHeightToActorIndex = 10,
				dof = {
					{
						intensity = 0,
						nearIntensity = 0,
						focusDistance = "auto",
						frame = 0,
						aperture = 0,
						targetActor = "p10_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_intro_lockers_home",
				name = "cs_camera06",
				moveRelativeToActorLabel = "p6_cameraplayer",
				near = 0.7,
				jointName = "cs_camera06",
				scaleCameraHeightToActorIndex = 10,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = 2.6,
						frame = 105,
						aperture = 3
					},
					{
						intensity = 1.5,
						nearIntensity = 1.5,
						focusDistance = 6.3,
						frame = 116,
						aperture = 1.2
					},
					{
						intensity = 1.5,
						nearIntensity = 1.5,
						focusDistance = 4.5,
						frame = 122,
						aperture = 1.2
					},
					{
						intensity = 1.5,
						nearIntensity = 1.5,
						focusDistance = 6.3,
						frame = 130,
						aperture = 1.2
					}
				}
			},
			{
				animName = "p1_rl1_intro_lockers_home",
				name = "cs_camera07",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera07",
				scaleCameraHeightToActorIndex = 10,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1.5,
						focusDistance = 2.3,
						frame = 0,
						aperture = 5.5
					},
					{
						intensity = 1,
						nearIntensity = 1.5,
						focusDistance = 2.3,
						frame = 20,
						aperture = 5.5
					},
					{
						intensity = 1,
						nearIntensity = 1.5,
						focusDistance = 5.9,
						frame = 31,
						aperture = 2.3
					},
					{
						intensity = 1,
						nearIntensity = 1.5,
						focusDistance = 5.9,
						frame = 49,
						aperture = 2.3
					},
					{
						intensity = 1,
						nearIntensity = 1.5,
						focusDistance = 3.4,
						frame = 54,
						aperture = 4.5
					},
					{
						intensity = 1,
						nearIntensity = 1.5,
						focusDistance = 3.4,
						frame = 59,
						aperture = 4.5
					},
					{
						intensity = 1,
						nearIntensity = 1.5,
						focusDistance = 6,
						frame = 66,
						aperture = 3.4
					}
				}
			}
		},
		playbackEvents = {
			{
				frame = 0,
				name = "EnableLightGroup",
				layerName = "stadium_lights",
				enable = false
			},
			{
				frame = 0,
				name = "EnableLightGroup",
				layerName = "sun",
				enable = false
			},
			{
				frame = 0,
				name = "SetRainIntensityEvent",
				rainfallOverride = 0
			},
			{
				onFinalise = true,
				name = "SetRainIntensityEvent",
				rainfallOverride = native.CWeather.RainfallOverrideDisabled
			},
			{
				frame = 0,
				name = "RebakeSpecEvent"
			}
		},
		cuts = {
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera03"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera01"
				}
			}
		},
		soundEvents = {
			{
				frame = 180,
				eventTable = {
					soundKey = "sfx_cutscene_crowd_reset_lp_01",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 0,
				eventTable = {
					soundKey = "sfx_cutscene_ambience_locker_room_intro_01",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 29,
				cutIndex = 1,
				eventTable = {
					soundKey = "sfx_cutscene_boots_locker_room_intro_02",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 18,
				cutIndex = 2,
				eventTable = {
					soundKey = "sfx_cutscene_boots_locker_room_intro_03",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 17,
				cutIndex = 3,
				eventTable = {
					soundKey = "sfx_cutscene_boots_locker_room_intro_04",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 15,
				cutIndex = 4,
				eventTable = {
					soundKey = "sfx_cutscene_boots_locker_room_intro_05",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 8,
				cutIndex = 5,
				eventTable = {
					soundKey = "sfx_cutscene_boots_locker_room_intro_06",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 6,
				cutIndex = 6,
				eventTable = {
					soundKey = "sfx_cutscene_boots_locker_room_intro_07",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 50,
				cutIndex = 1,
				eventTable = {
					soundKey = "sfx_cutscene_body_contact_locker_room_intro_01",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 4,
				cutIndex = 2,
				eventTable = {
					soundKey = "sfx_cutscene_body_contact_locker_room_intro_02",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 94,
				cutIndex = 3,
				eventTable = {
					soundKey = "sfx_cutscene_body_contact_locker_room_intro_03",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 50,
				cutIndex = 4,
				eventTable = {
					soundKey = "sfx_cutscene_body_contact_locker_room_intro_04",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 104,
				cutIndex = 5,
				eventTable = {
					soundKey = "sfx_cutscene_body_contact_locker_room_intro_05",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 28,
				cutIndex = 6,
				eventTable = {
					soundKey = "sfx_cutscene_body_contact_locker_room_intro_06",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 0,
				eventTable = {
					soundKey = "sfx_cutscene_player_vocals_locker_room_intro_02",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 0,
				eventTable = {
					soundKey = "sfx_cutscene_announcer_gf_locker_room_intro_01",
					type = "PlaySoundEvent"
				}
			}
		}
	},
	rl1_intro_lockers_home_02 = {
		playerPosY = 0.2,
		animsetName = "rl1_intro_lockers_home",
		worldRot = 0,
		cameraAndLightingYOffset = 0.2,
		povCameraAllowed = false,
		lightingScenes = {
			"cs_intro_lockers_standard_01"
		},
		cutsceneOrigin = var_0_4,
		worldPos = {
			0,
			0
		},
		actors = {
			{
				animName = "p1_rl1_intro_lockers_home_02",
				name = "player01",
				syncTo = "world",
				syncOnFrame = 90,
				optional = true,
				filter = {
					specialRole = "captain",
					actorType = "player",
					side = sidehelper.home
				}
			},
			{
				animName = "p2_rl1_intro_lockers_home_02",
				name = "player02",
				syncOnFrame = 90,
				optional = true,
				filter = {
					actorType = "player",
					side = sidehelper.home
				}
			},
			{
				animName = "p3_rl1_intro_lockers_home_02",
				name = "player03",
				syncOnFrame = 90,
				optional = true,
				filter = {
					actorType = "player",
					side = sidehelper.home
				}
			},
			{
				animName = "p4_rl1_intro_lockers_home_02",
				name = "player04",
				syncOnFrame = 90,
				optional = true,
				filter = {
					actorType = "player",
					side = sidehelper.home
				}
			},
			{
				animName = "p5_rl1_intro_lockers_home_02",
				name = "player05",
				syncOnFrame = 90,
				optional = true,
				filter = {
					actorType = "player",
					side = sidehelper.home
				}
			},
			{
				animName = "p6_rl1_intro_lockers_home_02",
				name = "player06",
				syncOnFrame = 90,
				optional = true,
				filter = {
					actorType = "player",
					side = sidehelper.home
				}
			},
			{
				animName = "p7_rl1_intro_lockers_home_02",
				name = "player07",
				syncOnFrame = 90,
				optional = true,
				filter = {
					actorType = "player",
					side = sidehelper.home
				}
			},
			{
				animName = "p8_rl1_intro_lockers_home_02",
				name = "player08",
				syncOnFrame = 90,
				optional = true,
				filter = {
					actorType = "player",
					side = sidehelper.home
				}
			},
			{
				animName = "p9_rl1_intro_lockers_home_02",
				name = "player09",
				syncOnFrame = 90,
				optional = true,
				filter = {
					actorType = "player",
					side = sidehelper.home
				}
			},
			{
				animName = "p10_rl1_intro_lockers_home_02",
				name = "player10",
				syncOnFrame = 90,
				optional = true,
				filter = {
					actorType = "player",
					side = sidehelper.home
				}
			},
			{
				animName = "p11_rl1_intro_lockers_home_02",
				name = "player11",
				syncOnFrame = 90,
				optional = true,
				filter = {
					actorType = "player",
					side = sidehelper.home
				}
			},
			{
				animName = "p12_rl1_intro_lockers_home_02",
				name = "player12",
				syncOnFrame = 90,
				optional = true,
				filter = {
					actorType = "player",
					side = sidehelper.home
				}
			},
			{
				animName = "p13_rl1_intro_lockers_home_02",
				name = "player13",
				syncOnFrame = 90,
				optional = true,
				filter = {
					actorType = "player",
					side = sidehelper.home
				}
			}
		},
		props = {
			{
				propName = "props/cutscene/models/lockerRoom01.model",
				position = {
					0,
					0.2,
					0
				},
				orientation = {
					0,
					0,
					0
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_intro_lockers_home_02",
				name = "cs_camera09",
				moveRelativeToActorLabel = "player01",
				near = 0.1,
				jointName = "cs_camera09",
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 0.5,
						focusDistance = "auto",
						frame = 0,
						aperture = 3,
						targetActor = "player01",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_intro_lockers_home_02",
				name = "cs_camera10",
				moveRelativeToActorLabel = "player01",
				near = 0.1,
				jointName = "cs_camera10",
				dof = {
					{
						intensity = 0.2,
						nearIntensity = 0.2,
						focusDistance = 5.5,
						frame = 0,
						aperture = 3,
						targetActor = "player01",
						autoDofJoints = {
							"hips"
						}
					}
				}
			}
		},
		playbackEvents = {
			{
				frame = 0,
				name = "EnableLightGroup",
				layerName = "stadium_lights",
				enable = false
			},
			{
				frame = 0,
				name = "EnableLightGroup",
				layerName = "sun",
				enable = false
			},
			{
				frame = 0,
				name = "SetRainIntensityEvent",
				rainfallOverride = 0
			},
			{
				onFinalise = true,
				name = "SetRainIntensityEvent",
				rainfallOverride = native.CWeather.RainfallOverrideDisabled
			},
			{
				frame = 0,
				name = "RebakeSpecEvent"
			}
		},
		cuts = {
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera10"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			}
		},
		soundEvents = {
			{
				frame = 2,
				eventTable = {
					soundKey = "sfx_cutscene_ambience_locker_room_intro_01",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 2,
				eventTable = {
					soundKey = "sfx_cutscene_player_vocals_locker_room_intro_02",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 2,
				eventTable = {
					soundKey = "sfx_cutscene_announcer_gf_locker_room_intro_02",
					type = "PlaySoundEvent"
				}
			}
		}
	}
}

-- match-intro-versus: trailer-style locker room edits. The p1 clip of each locker animset holds 14
-- camera tracks, but the stock scenes only show one random camera for the whole 6 s (away 01-04,
-- home 01/03). The rest (away 05-07, home 02/04-07; 06/07 have authored focus pulls) are never seen.
-- These copies cut between them over one take. Frames are 30 fps (the clips are ~183 long).
-- Played by the Grand Final trailer intro in rules/cutscenes/initial_cutscene.lua.
local function lockerTrailerCamera(arg_animName, arg_camera)
	return {
		animName = arg_animName,
		name = arg_camera,
		near = 0.5,
		jointName = arg_camera,
		dof = {
			{
				intensity = 0,
				nearIntensity = 0,
				focusDistance = "auto",
				frame = 0,
				aperture = 0,
				targetActor = "p1_cameraplayer",
				autoDofJoints = {
					"hips"
				}
			}
		}
	}
end

local LockerTrailerEdits = {
	{
		base = "rl1_intro_lockers_away",
		name = "rl1_intro_lockers_away_trailer",
		addCameras = {
			"cs_camera05"
		},
		cuts = {
			{ frame = 0, camera = "cs_camera06" },
			{ frame = 48, camera = "cs_camera07" },
			{ frame = 96, camera = "cs_camera05" },
			{ frame = 138, camera = "cs_camera03" }
		}
	},
	{
		base = "rl1_intro_lockers_home",
		name = "rl1_intro_lockers_home_trailer",
		addCameras = {},
		cuts = {
			{ frame = 0, camera = "cs_camera07" },
			{ frame = 66, camera = "cs_camera02" },
			{ frame = 105, camera = "cs_camera06" },
			{ frame = 135, camera = "cs_camera04" }
		}
	}
}

for iter_0_lt, iter_0_edit in ipairs(LockerTrailerEdits) do
	local var_0_ltBase = CutsceneData[iter_0_edit.base]

	if var_0_ltBase and not CutsceneData[iter_0_edit.name] then
		local var_0_ltCopy = {}

		for iter_0_k, iter_0_v in pairs(var_0_ltBase) do
			var_0_ltCopy[iter_0_k] = iter_0_v
		end

		local var_0_ltAnim = "p1_" .. iter_0_edit.base
		local var_0_ltCameras = {}

		for iter_0_c, iter_0_cam in ipairs(var_0_ltBase.cameras or {}) do
			table.insert(var_0_ltCameras, iter_0_cam)
		end

		for iter_0_c, iter_0_cam in ipairs(iter_0_edit.addCameras) do
			table.insert(var_0_ltCameras, lockerTrailerCamera(var_0_ltAnim, iter_0_cam))
		end

		local var_0_ltCuts = {}

		for iter_0_c, iter_0_cut in ipairs(iter_0_edit.cuts) do
			table.insert(var_0_ltCuts, {
				frame = iter_0_cut.frame,
				transition = "cut",
				camera = iter_0_cut.camera
			})
		end

		var_0_ltCopy.cameras = var_0_ltCameras
		var_0_ltCopy.cuts = {
			var_0_ltCuts
		}
		CutsceneData[iter_0_edit.name] = var_0_ltCopy
		CutscenesForStadiumClone[iter_0_edit.name] = true
	end
end

cutscenedata_copier.addCSAnims(CutsceneData, CutscenesForStadiumClone, "home")
