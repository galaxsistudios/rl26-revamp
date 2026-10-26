import("base.side.sidehelper")
local var_0_0 = native.ECutsceneOrigin.PrimaryActor
local var_0_1 = native.ECutsceneOrigin.PrimaryActorFacingOrigin
local var_0_2 = native.ECutsceneOrigin.CenterAroundActors
local var_0_3 = native.ECutsceneOrigin.World
local var_0_4 = native.ECutsceneOrigin.Custom

default_near = 0.5
default_far = 1200
CutsceneData = {
	rl1_test_sync_01 = {
		animsetName = "cutscene_rl1_test_sync_01",
		povCameraAllowed = false,
		cutsceneOrigin = var_0_3,
		actors = {
			{
				animName = "p1_rl1_test_sync_01",
				name = "player01",
				syncOnFrame = 0,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_test_sync_01",
				name = "player02",
				syncTo = "player01",
				syncOnFrame = 150,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p3_rl1_test_sync_01",
				name = "player03",
				syncTo = "player01",
				syncOnFrame = 300,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_test_sync_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "player03",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.9,
						focusArea = 5,
						focusDistance = "auto",
						frame = 0,
						aperture = 0.5,
						targetActor = "player01",
						nearIntensity = 1,
						autoDofJoints = {
							"hips"
						}
					}
				}
			}
		},
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01"
				}
			}
		}
	},
	rl1_test_eyeline_01 = {
		animsetName = "rl1_test_eyeline_01_animset",
		povCameraAllowed = false,
		cutsceneOrigin = var_0_3,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "rl1_test_eyeline_01",
				name = "player01",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "rl1_test_eyeline_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "player01",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.9,
						focusArea = 5,
						focusDistance = "auto",
						frame = 0,
						aperture = 1.5,
						targetActor = "player03",
						nearIntensity = 0,
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "rl1_test_eyeline_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "player01",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.9,
						focusArea = 5,
						focusDistance = "auto",
						frame = 0,
						aperture = 1.5,
						targetActor = "player03",
						nearIntensity = 0,
						autoDofJoints = {
							"hips"
						}
					}
				}
			}
		},
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02"
				}
			}
		}
	},
	rl1_test_dof_01 = {
		animsetName = "cutscene_rl1_test_dof_01",
		povCameraAllowed = false,
		cutsceneOrigin = var_0_3,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_test_dof_01",
				name = "player01",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_test_dof_01",
				name = "player02",
				syncTo = "player01",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p3_rl1_test_dof_01",
				name = "player03",
				syncTo = "player01",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p4_rl1_test_dof_01",
				name = "player04",
				syncTo = "player01",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p5_rl1_test_dof_01",
				name = "player05",
				syncTo = "player01",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p6_rl1_test_dof_01",
				name = "player06",
				syncTo = "player01",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_test_dof_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "player03",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.9,
						focusArea = 5,
						focusDistance = "auto",
						frame = 0,
						aperture = 0.5,
						targetActor = "player03",
						nearIntensity = 1,
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_test_dof_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "player03",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.9,
						focusArea = 5,
						focusDistance = "auto",
						frame = 0,
						aperture = 0.5,
						targetActor = "player03",
						nearIntensity = 1,
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_test_dof_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "player03",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.9,
						focusArea = 5,
						focusDistance = "auto",
						frame = 0,
						aperture = 0.5,
						targetActor = "player03",
						nearIntensity = 1,
						autoDofJoints = {
							"hips"
						}
					}
				}
			}
		},
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03"
				}
			}
		}
	},
	rl1_test_cutscene_asset_01 = {
		animsetName = "cutscene_rl1_test_cutscene_asset_01",
		povCameraAllowed = false,
		lightingScenes = {
			"cinematic_generic_walkon_light_spin_01"
		},
		cutsceneOrigin = var_0_3,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_test_cutscene_asset_01",
				name = "player01",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_test_cutscene_asset_01",
				name = "player02",
				syncTo = "player01",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p3_rl1_test_cutscene_asset_01",
				name = "player03",
				syncTo = "player01",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p4_rl1_test_cutscene_asset_01",
				name = "player04",
				syncTo = "player01",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p5_rl1_test_cutscene_asset_01",
				name = "player05",
				syncTo = "player01",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p6_rl1_test_cutscene_asset_01",
				name = "player06",
				syncTo = "player01",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		props = {
			{
				name = "props/cutscene/models/effectMachine_smoke04.model",
				fxFile = "effectMachine_firework01_cutscene_01a_fx",
				position = {
					-17.5,
					0,
					30
				},
				orientation = {
					0,
					0,
					0
				}
			},
			{
				name = "props/cutscene/models/effectMachine_smoke04.model",
				fxFile = "effectMachine_firework01_cutscene_01b_fx",
				position = {
					-12.5,
					0,
					30
				},
				orientation = {
					0,
					0,
					0
				}
			},
			{
				name = "props/cutscene/models/effectMachine_smoke04.model",
				fxFile = "effectMachine_firework01_cutscene_01c_fx",
				position = {
					-7.5,
					0,
					30
				},
				orientation = {
					0,
					0,
					0
				}
			},
			{
				name = "props/cutscene/models/effectMachine_smoke04.model",
				fxFile = "effectMachine_firework01_cutscene_01d_fx",
				position = {
					-2.5,
					0,
					30
				},
				orientation = {
					0,
					0,
					0
				}
			},
			{
				name = "props/cutscene/models/effectMachine_smoke04.model",
				fxFile = "effectMachine_firework01_cutscene_01e_fx",
				position = {
					2.5,
					0,
					30
				},
				orientation = {
					0,
					0,
					0
				}
			},
			{
				name = "props/cutscene/models/effectMachine_smoke04.model",
				fxFile = "effectMachine_firework01_cutscene_01f_fx",
				position = {
					7.5,
					0,
					30
				},
				orientation = {
					0,
					0,
					0
				}
			},
			{
				name = "props/cutscene/models/effectMachine_smoke04.model",
				fxFile = "effectMachine_firework01_cutscene_01g_fx",
				position = {
					12.5,
					0,
					30
				},
				orientation = {
					0,
					0,
					0
				}
			},
			{
				name = "props/cutscene/models/effectMachine_smoke04.model",
				fxFile = "effectMachine_firework01_cutscene_01h_fx",
				position = {
					17.5,
					0,
					30
				},
				orientation = {
					0,
					0,
					0
				}
			},
			{
				name = "props/cutscene/models/effectMachine_flame01.model",
				fxFile = "effectMachine_flame01_cutscene_01a_fx",
				position = {
					5,
					0,
					-34
				},
				orientation = {
					0,
					0,
					0
				}
			},
			{
				name = "props/cutscene/models/effectMachine_flame01.model",
				fxFile = "effectMachine_flame01_cutscene_01b_fx",
				position = {
					6,
					0,
					-28.5
				},
				orientation = {
					0,
					0,
					0
				}
			},
			{
				name = "props/cutscene/models/effectMachine_flame01.model",
				fxFile = "effectMachine_flame01_cutscene_01c_fx",
				position = {
					7,
					0,
					-23
				},
				orientation = {
					0,
					0,
					0
				}
			},
			{
				name = "props/cutscene/models/effectMachine_flame01.model",
				fxFile = "effectMachine_flame01_cutscene_01a_fx",
				position = {
					-5,
					0,
					-34
				},
				orientation = {
					0,
					0,
					0
				}
			},
			{
				name = "props/cutscene/models/effectMachine_flame01.model",
				fxFile = "effectMachine_flame01_cutscene_01b_fx",
				position = {
					-6,
					0,
					-28.5
				},
				orientation = {
					0,
					0,
					0
				}
			},
			{
				name = "props/cutscene/models/effectMachine_flame01.model",
				fxFile = "effectMachine_flame01_cutscene_01c_fx",
				position = {
					-7,
					0,
					-23
				},
				orientation = {
					0,
					0,
					0
				}
			},
			{
				name = "props/cutscene/models/effectMachine_smoke05_GF_male.model",
				fxFile = "effectMachine_smoke05_cutscene_01a_fx",
				position = {
					0,
					0,
					-10
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
				animName = "p1_rl1_test_cutscene_asset_01",
				name = "cs_camera01",
				jointName = "cs_camera01",
				near = 0.1
			},
			{
				animName = "p1_rl1_test_cutscene_asset_01",
				name = "cs_camera02",
				jointName = "cs_camera02",
				near = 0.1
			},
			{
				animName = "p1_rl1_test_cutscene_asset_01",
				name = "cs_camera03",
				jointName = "cs_camera03",
				near = 0.1
			}
		},
		cuts = {
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera01"
				}
			},
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
			}
		},
		playbackEvents = {
			{
				sequenceClipName = "Clip1_walkon_stadium_spotlights",
				sequenceName = "walkon_stadium_light_spotlights",
				name = "PlaySequenceClip",
				frame = 0,
				looping = true
			},
			{
				frame = 20,
				name = "ParticleEvent",
				particleEvent = "fw_comet_all"
			},
			{
				frame = 50,
				name = "ParticleEvent",
				particleEvent = "fw_comet_01"
			},
			{
				frame = 50,
				name = "ParticleEvent",
				particleEvent = "fw_comet_08"
			},
			{
				frame = 60,
				name = "ParticleEvent",
				particleEvent = "fw_comet_02"
			},
			{
				frame = 60,
				name = "ParticleEvent",
				particleEvent = "fw_comet_07"
			},
			{
				frame = 70,
				name = "ParticleEvent",
				particleEvent = "fw_comet_03"
			},
			{
				frame = 70,
				name = "ParticleEvent",
				particleEvent = "fw_comet_06"
			},
			{
				frame = 80,
				name = "ParticleEvent",
				particleEvent = "fw_comet_04"
			},
			{
				frame = 80,
				name = "ParticleEvent",
				particleEvent = "fw_comet_05"
			},
			{
				frame = 90,
				name = "ParticleEvent",
				particleEvent = "fw_comet_03"
			},
			{
				frame = 90,
				name = "ParticleEvent",
				particleEvent = "fw_comet_06"
			},
			{
				frame = 100,
				name = "ParticleEvent",
				particleEvent = "fw_comet_02"
			},
			{
				frame = 100,
				name = "ParticleEvent",
				particleEvent = "fw_comet_07"
			},
			{
				frame = 110,
				name = "ParticleEvent",
				particleEvent = "fw_comet_01"
			},
			{
				frame = 110,
				name = "ParticleEvent",
				particleEvent = "fw_comet_08"
			},
			{
				frame = 140,
				name = "ParticleEvent",
				particleEvent = "fw_comet_all"
			},
			{
				frame = 200,
				name = "ParticleEvent",
				particleEvent = "fw_dual_01"
			},
			{
				frame = 200,
				name = "ParticleEvent",
				particleEvent = "fw_dual_03"
			},
			{
				frame = 200,
				name = "ParticleEvent",
				particleEvent = "fw_dual_06"
			},
			{
				frame = 200,
				name = "ParticleEvent",
				particleEvent = "fw_dual_08"
			},
			{
				frame = 0,
				name = "ParticleEvent",
				particleEvent = "f01_cs_flame_stream_all"
			},
			{
				frame = 20,
				name = "ParticleEvent",
				particleEvent = "f01_cs_flame_burst02_all"
			},
			{
				frame = 50,
				name = "ParticleEvent",
				particleEvent = "f01_cs_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_cs_flame_burst02_02"
			},
			{
				frame = 80,
				name = "ParticleEvent",
				particleEvent = "f01_cs_flame_burst02_03"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_cs_flame_burst02_01"
			},
			{
				frame = 110,
				name = "ParticleEvent",
				particleEvent = "f01_cs_flame_burst02_02"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_cs_flame_burst02_03"
			},
			{
				frame = 155,
				name = "ParticleEvent",
				particleEvent = "f01_cs_flame_burst02_all"
			},
			{
				frame = 185,
				name = "ParticleEvent",
				particleEvent = "f01_cs_flame_burst02_01"
			},
			{
				frame = 200,
				name = "ParticleEvent",
				particleEvent = "f01_cs_flame_burst02_02"
			},
			{
				frame = 215,
				name = "ParticleEvent",
				particleEvent = "f01_cs_flame_burst02_03"
			},
			{
				frame = 245,
				name = "ParticleEvent",
				particleEvent = "f01_cs_flame_burst02_all"
			},
			{
				frame = 40,
				name = "ParticleEvent",
				particleEvent = "s05_cs_flame_burst_01"
			},
			{
				frame = 40,
				name = "ParticleEvent",
				particleEvent = "s05_cs_smoke_burst_01"
			},
			{
				frame = 90,
				name = "ParticleEvent",
				particleEvent = "s05_cs_smoke_burst_a_01"
			},
			{
				frame = 110,
				name = "ParticleEvent",
				particleEvent = "s05_cs_smoke_burst_b_01"
			},
			{
				frame = 0,
				name = "PlaySequenceClip",
				sequenceClipName = "start_off",
				sequenceName = "cutscene_dynamic_stadium_lights"
			},
			{
				frame = 250,
				name = "PlaySequenceClip",
				sequenceClipName = "turn_on",
				sequenceName = "cutscene_dynamic_stadium_lights"
			},
			{
				frame = 0,
				name = "RebakeSpecEvent"
			},
			{
				frame = 20,
				name = "ParticleEvent",
				particleEvent = "TryScored_FlamejetEvent"
			},
			{
				frame = 110,
				name = "ParticleEvent",
				particleEvent = "TryScored_FlamejetEvent"
			},
			{
				frame = 200,
				name = "ParticleEvent",
				particleEvent = "TryScored_FlamejetEvent"
			}
		},
		sequences = {
			walkon_stadium_light_spotlights = {
				sequencer = "ui/frontend/walkon_stadium_light_spotlights.seq",
				propIndices = {}
			},
			cutscene_dynamic_stadium_lights = {
				sequencer = "ui/frontend/cutscene_dynamic_stadium_lights.seq",
				propIndices = {}
			}
		}
	},
	rl1_test_cutscene_glowsticks_01 = {
		animsetName = "rl1_stadium_team_logos_animset",
		povCameraAllowed = false,
		cutsceneOrigin = var_0_3,
		clampScale = native.CRange(1, 1),
		actors = {
			{
				animName = "p1_rl1_stadium_team_logos",
				name = "player01",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_stadium_team_logos",
				name = "cs_camera01",
				moveRelativeToActorLabel = "player01",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.9,
						focusArea = 5,
						focusDistance = "auto",
						frame = 0,
						aperture = 0.5,
						targetActor = "player01",
						nearIntensity = 1,
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_stadium_team_logos",
				name = "cs_camera02",
				moveRelativeToActorLabel = "player01",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.9,
						focusArea = 5,
						focusDistance = "auto",
						frame = 0,
						aperture = 0.5,
						targetActor = "player01",
						nearIntensity = 1,
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_stadium_team_logos",
				name = "cs_camera03",
				moveRelativeToActorLabel = "player01",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.9,
						focusArea = 5,
						focusDistance = "auto",
						frame = 0,
						aperture = 0.5,
						targetActor = "player01",
						nearIntensity = 1,
						autoDofJoints = {
							"hips"
						}
					}
				}
			}
		},
		cuts = {
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera01"
				}
			},
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
			}
		},
		playbackEvents = {
			{
				frame = 1,
				name = "CrowdEvent",
				group = "Intro",
				animations = {
					{
						forceSnap = true,
						tags = "TAGS_ALL",
						animGroup = native.ECrowdAnimGroup.glowsticks_idle
					}
				}
			}
		}
	},
	-- imported from Rugby 25 by tools/r25_import.py
	r25_TryCelebrate_roll_hug = {
		animsetName = "r25_cutsceneCelebrateRollHug_01",
		actors = {
			{
				name = "primary",
				animName = "p1_22_celebrate_roll_hug_01",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 100
			},
			{
				name = "p2_ballplayer",
				animName = "p2_22_celebrate_roll_hug_01",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 100
			},
			{
				animName = "p3_22_celebrate_roll_hug_01",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 100
			},
			{
				animName = "p4_22_celebrate_roll_hug_01",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 100
			},
			{
				animName = "p5_22_celebrate_roll_hug_01",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 100
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_22_celebrate_roll_hug_01",
				dof = {
					{
						frame = 0,
						focusArea = 2.4,
						focusDistance = 70,
						focusTransition = 30,
						intensity = 1,
						nearIntensity = 0
					}
				},
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1
			},
			{
				name = "cs_camera02",
				animName = "p1_22_celebrate_roll_hug_01",
				dof = {
					{
						frame = 310,
						focusArea = 2.4,
						focusDistance = 70,
						focusTransition = 30,
						intensity = 1,
						nearIntensity = 0
					}
				},
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				},
				{
					frame = 115,
					camera = "cs_camera02",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false,
		props = {
			{
				name = "ball",
				attachTo = {
					name = "p2_ballplayer",
					jointName = "ballJoint"
				}
			}
		}
	},
	r25_TryCelebrate_intense_slide_yell = {
		animsetName = "r25_cutsceneCelebrateIntenseSlideYell_01",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_21_celebrate_intense_slide_yell_01",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 100
			},
			{
				animName = "p2_21_celebrate_intense_slide_yell_01",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 100
			},
			{
				animName = "p3_21_celebrate_intense_slide_yell_01",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 100
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_21_celebrate_intense_slide_yell_01",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5,
						focusDistance = "auto",
						focusTransition = 12,
						intensity = 0.25,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_21_celebrate_intense_slide_yell_01",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.2,
						nearIntensity = 0.4,
						targetActor = "p1_cameraplayer"
					}
				},
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_21_celebrate_intense_slide_yell_01",
				dof = {
					{
						frame = 43,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1.5,
						focusDistance = "auto",
						focusTransition = 1,
						intensity = 1,
						nearIntensity = 1,
						targetActor = "p1_cameraplayer"
					}
				},
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		clampScale = native.CRange(0.97, 1.03),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false,
		props = {
			{
				name = "ball",
				attachTo = {
					name = "p1_cameraplayer",
					jointName = "ballJoint"
				}
			}
		}
	},
	r25_TryCelebrate_ball_throw_group = {
		animsetName = "r25_cutsceneCelebrateBallThrowGroup_01",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_23_celebrate_ball_throw_group_01",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 100
			},
			{
				animName = "p2_23_celebrate_ball_throw_group_01",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 100
			},
			{
				animName = "p3_23_celebrate_ball_throw_group_01",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 100
			},
			{
				animName = "p4_23_celebrate_ball_throw_group_01",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 100
			}
		},
		cameras = {
			{
				name = "cs_camera02",
				animName = "p1_23_celebrate_ball_throw_group_01",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5,
						focusDistance = "auto",
						focusTransition = 12,
						intensity = 0.25,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera01",
				animName = "p1_23_celebrate_ball_throw_group_01",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.2,
						nearIntensity = 0.4,
						targetActor = "p1_cameraplayer"
					}
				},
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_23_celebrate_ball_throw_group_01",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5,
						focusDistance = "auto",
						focusTransition = 12,
						intensity = 0.25,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera04",
				animName = "p1_23_celebrate_ball_throw_group_01",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.2,
						nearIntensity = 0.4,
						targetActor = "p1_cameraplayer"
					}
				},
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				jointName = "cs_camera04",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				},
				{
					frame = 24,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera04",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false,
		props = {
			{
				name = "ball",
				attachTo = {
					name = "p1_cameraplayer",
					jointName = "ballJoint"
				}
			}
		}
	},
	r25_TryCelebrate_ball_throw_hug_group = {
		animsetName = "r25_cutsceneCelebrate_ball_throw_hug_group",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_20_celebrate_ball_throw_hug_group",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 100
			},
			{
				animName = "p2_20_celebrate_ball_throw_hug_group",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 100
			},
			{
				animName = "p3_20_celebrate_ball_throw_hug_group",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 100
			},
			{
				animName = "p4_20_celebrate_ball_throw_hug_group",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 100
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_20_celebrate_ball_throw_hug_group",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = "auto",
						focusTransition = 1,
						intensity = 0.1,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 10
			},
			{
				name = "cs_camera02",
				animName = "p1_20_celebrate_ball_throw_hug_group",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = "auto",
						focusTransition = 1,
						intensity = 0.1,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 10
			},
			{
				name = "cs_camera03",
				animName = "p1_20_celebrate_ball_throw_hug_group",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = "auto",
						focusTransition = 1,
						intensity = 0.1,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1
			},
			{
				name = "cs_camera04",
				animName = "p1_20_celebrate_ball_throw_hug_group",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = "auto",
						focusTransition = 1,
						intensity = 0.1,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				jointName = "cs_camera04",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 20
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				},
				{
					frame = 56,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera04",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false,
		props = {
			{
				name = "ball",
				attachTo = {
					name = "p1_cameraplayer",
					jointName = "ballJoint"
				}
			}
		}
	},
	r25_Post_Conversion_01 = {
		animsetName = "r25_PostConversion",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_post_conversion_01",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				animName = "p2_post_conversion_01",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_post_conversion_01",
				dof = {
					{
						frame = 0,
						focusArea = 4,
						focusDistance = 8.5,
						focusTransition = 2,
						intensity = 0.6,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_post_conversion_01",
				dof = {
					{
						frame = 0,
						focusArea = 2,
						focusDistance = 8.4,
						focusTransition = 2,
						intensity = 1.25,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		checkCameraBoundary = true,
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false
	},
	r25_Post_Conversion_02 = {
		animsetName = "r25_PostConversion",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_post_conversion_02",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_post_conversion_02",
				dof = {
					{
						frame = 0,
						focusArea = 4,
						focusDistance = 8.5,
						focusTransition = 2,
						intensity = 0.6,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_post_conversion_02",
				dof = {
					{
						frame = 0,
						focusArea = 2,
						focusDistance = 8.4,
						focusTransition = 2,
						intensity = 1.25,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		checkCameraBoundary = true,
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false
	},
	r25_Post_Conversion_03 = {
		animsetName = "r25_PostConversion",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_post_conversion_03",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_post_conversion_03",
				dof = {
					{
						frame = 0,
						focusArea = 4,
						focusDistance = 8.5,
						focusTransition = 2,
						intensity = 0.6,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_post_conversion_03",
				dof = {
					{
						frame = 0,
						focusArea = 2,
						focusDistance = 8.4,
						focusTransition = 2,
						intensity = 1.25,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		checkCameraBoundary = true,
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false
	},
	r25_Conversion_T_success_r24_01 = {
		animsetName = "r25_cutsceneConversionTsuccess24_01",
		actors = {
			{
				name = "cameraplayer",
				animName = "conversion_t_success_01",
				filter = {
					actorType = "player"
				},
				optional = true
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "conversion_t_success_01",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2.5,
						focusDistance = "auto",
						focusTransition = 5,
						intensity = 0.02,
						nearIntensity = 0,
						targetActor = "conversionguy"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "cameraplayer",
				near = 0.1,
				safe = true,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "conversion_t_success_01",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1.5,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 1,
						nearIntensity = 0.1,
						targetActor = "cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "conversion_t_success_01",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = "auto",
						focusTransition = 1,
						intensity = 0.2,
						nearIntensity = 0,
						targetActor = "cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera04",
				animName = "conversion_t_success_01",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.9,
						nearIntensity = 0,
						targetActor = "cameraplayer"
					}
				},
				jointName = "cs_camera04",
				moveRelativeToActorLabel = "cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera04"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false
	},
	r25_IntroCorridorWalkTeam_02 = {
		animsetName = "r25_cutsceneIntroCorridorWalk",
		actors = {
			{
				animName = "p1_intro_corridor_team_02",
				filter = {
					actorType = "player",
					side = sidehelper.home
				},
				optional = true,
				syncOnFrame = 75
			},
			{
				name = "p16_cameraplayer",
				animName = "p16_intro_corridor_team_02",
				filter = {
					actorType = "player",
					side = sidehelper.home,
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 75
			},
			{
				animName = "p17_intro_corridor_team_02",
				filter = {
					actorType = "player",
					side = sidehelper.home
				},
				optional = true,
				syncOnFrame = 75
			},
			{
				animName = "p18_intro_corridor_team_02",
				filter = {
					actorType = "player",
					side = sidehelper.home
				},
				optional = true,
				syncOnFrame = 75
			},
			{
				animName = "p19_intro_corridor_team_02",
				filter = {
					actorType = "player",
					side = sidehelper.home
				},
				optional = true,
				syncOnFrame = 75
			},
			{
				animName = "p20_intro_corridor_team_02",
				filter = {
					actorType = "player",
					side = sidehelper.home
				},
				optional = true,
				syncOnFrame = 75
			},
			{
				animName = "p21_intro_corridor_team_02",
				filter = {
					actorType = "player",
					side = sidehelper.home
				},
				optional = true,
				syncOnFrame = 75
			},
			{
				animName = "p22_intro_corridor_team_02",
				filter = {
					actorType = "player",
					side = sidehelper.home
				},
				optional = true,
				syncOnFrame = 75
			},
			{
				animName = "p23_intro_corridor_team_02",
				filter = {
					actorType = "player",
					side = sidehelper.home
				},
				optional = true,
				syncOnFrame = 75
			},
			{
				animName = "p24_intro_corridor_team_02",
				filter = {
					actorType = "player",
					side = sidehelper.home
				},
				optional = true,
				syncOnFrame = 75
			}
		},
		cameraAndLightingYOffset = 0.3,
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_intro_corridor_team_02",
				dof = {
					{
						frame = 0,
						focusArea = 1,
						focusDistance = 8,
						focusTransition = 1,
						intensity = 0,
						nearIntensity = 0
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p16_cameraplayer",
				near = 0.01,
				scaleCameraHeightToActorIndex = 2
			},
			{
				name = "cs_camera02",
				animName = "p1_intro_corridor_team_02",
				dof = {
					{
						frame = 0,
						focusArea = 1,
						focusDistance = 8,
						focusTransition = 1,
						intensity = 0,
						nearIntensity = 0
					}
				},
				jointName = "cs_camera02",
				near = 0.01
			},
			{
				name = "cs_camera03",
				animName = "p1_intro_corridor_team_02",
				dof = {
					{
						frame = 0,
						focusArea = 1,
						focusDistance = 8,
						focusTransition = 1,
						intensity = 0,
						nearIntensity = 0
					}
				},
				jointName = "cs_camera03",
				near = 0.01
			}
		},
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.Custom,
		lightingScenes = {
			"cs_corridor_home_01"
		},
		playbackEvents = {
			{
				name = "EnableLightGroup",
				frame = 0,
				enable = false,
				layerName = "stadium_lights"
			},
			{
				name = "EnableLightGroup",
				frame = 0,
				enable = false,
				layerName = "sun"
			},
			{
				name = "SetRainIntensityEvent",
				frame = 0,
				rainfallOverride = 0
			},
			{
				name = "SetRainIntensityEvent",
				onFinalise = true,
				rainfallOverride = native.CWeather.RainfallOverrideDisabled
			},
			{
				name = "RebakeSpecEvent",
				frame = 0
			}
		},
		playerPosY = 0.2,
		povCameraAllowed = false,
		props = {
			{
				name = "props/cutscene/models/corridor01.model",
				orientation = {
					0,
					0,
					0
				},
				position = {
					0,
					0.2,
					0
				}
			}
		},
		soundEvents = {
			{
				frame = 1,
				eventTable = {
					type = "StopAwayThemeEvent"
				}
			},
			{
				frame = 116,
				eventTable = {
					soundKey = "sfx_cutscene_crowd_reset_lp_01",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 0,
				eventTable = {
					soundKey = "sfx_cutscene_crowd_tone_corridor_intro_01",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 0,
				eventTable = {
					soundKey = "sfx_cutscene_crowd_tone_corridor_intro_02",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 0,
				eventTable = {
					soundKey = "sfx_cutscene_boots_corridor_intro_01",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 0,
				eventTable = {
					soundKey = "sfx_cutscene_boots_corridor_intro_02",
					type = "PlaySoundEvent"
				}
			}
		},
		syncToWorldPositions = true,
		worldPos = {
			0,
			0
		},
		worldRot = 0
	},
	r25_IntroCorridorWalkTeam_01 = {
		animsetName = "r25_cutsceneIntroCorridorWalk",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_intro_corridor_team_01",
				filter = {
					actorType = "player",
					side = sidehelper.home,
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				animName = "p2_intro_corridor_team_01",
				filter = {
					actorType = "player",
					side = sidehelper.home
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				animName = "p3_intro_corridor_team_01",
				filter = {
					actorType = "player",
					side = sidehelper.home
				},
				optional = true,
				syncOnFrame = 20
			},
			{
				animName = "p4_intro_corridor_team_01",
				filter = {
					actorType = "player",
					side = sidehelper.home
				},
				optional = true,
				syncOnFrame = 55
			},
			{
				animName = "p5_intro_corridor_team_01",
				filter = {
					actorType = "player",
					side = sidehelper.home
				},
				optional = true,
				syncOnFrame = 85
			},
			{
				animName = "p6_intro_corridor_team_01",
				filter = {
					actorType = "player",
					side = sidehelper.home
				},
				optional = true,
				syncOnFrame = 120
			},
			{
				animName = "p7_intro_corridor_team_01",
				filter = {
					actorType = "player",
					side = sidehelper.home
				},
				optional = true,
				syncOnFrame = 140
			},
			{
				animName = "p8_intro_corridor_team_01",
				filter = {
					actorType = "player",
					side = sidehelper.home
				},
				optional = true,
				syncOnFrame = 140
			}
		},
		cameraAndLightingYOffset = 0.3,
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_intro_corridor_team_01",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = "auto",
						focusTransition = 1,
						intensity = 0.1,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_intro_corridor_team_01",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = 1.5,
						focusTransition = 2,
						intensity = 0.5,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				near = 0.1
			},
			{
				name = "cs_camera03",
				animName = "p1_intro_corridor_team_01",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = "auto",
						focusTransition = 1,
						intensity = 0.1,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.Custom,
		lightingScenes = {
			"cs_corridor_home_01"
		},
		playbackEvents = {
			{
				name = "EnableLightGroup",
				frame = 0,
				enable = false,
				layerName = "stadium_lights"
			},
			{
				name = "EnableLightGroup",
				frame = 0,
				enable = false,
				layerName = "sun"
			},
			{
				name = "SetRainIntensityEvent",
				frame = 0,
				rainfallOverride = 0
			},
			{
				name = "SetRainIntensityEvent",
				onFinalise = true,
				rainfallOverride = native.CWeather.RainfallOverrideDisabled
			},
			{
				name = "RebakeSpecEvent",
				frame = 0
			}
		},
		playerPosY = 0.2,
		povCameraAllowed = false,
		props = {
			{
				name = "props/cutscene/models/corridor01.model",
				orientation = {
					0,
					0,
					0
				},
				position = {
					0,
					0.2,
					0
				}
			}
		},
		soundEvents = {
			{
				frame = 1,
				eventTable = {
					type = "StopAwayThemeEvent"
				}
			},
			{
				frame = 116,
				eventTable = {
					soundKey = "sfx_cutscene_crowd_reset_lp_01",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 0,
				eventTable = {
					soundKey = "sfx_cutscene_crowd_tone_corridor_intro_01",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 0,
				eventTable = {
					soundKey = "sfx_cutscene_crowd_tone_corridor_intro_02",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 0,
				eventTable = {
					soundKey = "sfx_cutscene_boots_corridor_intro_01",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 0,
				eventTable = {
					soundKey = "sfx_cutscene_boots_corridor_intro_02",
					type = "PlaySoundEvent"
				}
			}
		},
		syncToWorldPositions = true,
		worldPos = {
			0,
			0
		},
		worldRot = 0
	},
	r25_IntroStandardTwoTeams_01 = {
		animsetName = "r25_cutsceneIntroWalkonNoEntrance",
		actors = {
			{
				animName = "p1_intro_std_two_teams_ne",
				filter = {
					actorType = "player",
					side = sidehelper.away,
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				animName = "p2_intro_std_two_teams_ne",
				filter = {
					actorType = "player",
					side = sidehelper.away
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				animName = "p3_intro_std_two_teams_ne",
				filter = {
					actorType = "player",
					side = sidehelper.away
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				animName = "p4_intro_std_two_teams_ne",
				filter = {
					actorType = "player",
					side = sidehelper.away
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				animName = "p5_intro_std_two_teams_ne",
				filter = {
					actorType = "player",
					side = sidehelper.away
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p6_cameraplayer",
				animName = "p6_intro_std_two_teams_ne",
				filter = {
					actorType = "player",
					side = sidehelper.away
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				animName = "p7_intro_std_two_teams_ne",
				filter = {
					actorType = "player",
					side = sidehelper.away
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p8_cameraplayer",
				animName = "p8_intro_std_two_teams_ne",
				filter = {
					actorType = "player",
					side = sidehelper.away
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p9_cameraplayer",
				animName = "p9_intro_std_two_teams_ne",
				filter = {
					actorType = "player",
					side = sidehelper.away
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p10_cameraplayer",
				animName = "p10_intro_std_two_teams_ne",
				filter = {
					actorType = "player",
					side = sidehelper.away
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				animName = "p11_intro_std_two_teams_ne",
				filter = {
					actorType = "player",
					side = sidehelper.away
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				animName = "p12_intro_std_two_teams_ne",
				filter = {
					actorType = "player",
					side = sidehelper.away
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				animName = "p13_intro_std_two_teams_ne",
				filter = {
					actorType = "player",
					side = sidehelper.away
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				animName = "p14_intro_std_two_teams_ne",
				filter = {
					actorType = "player",
					side = sidehelper.away
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				animName = "p15_intro_std_two_teams_ne",
				filter = {
					actorType = "player",
					side = sidehelper.away
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p16_cameraplayer",
				animName = "p16_intro_std_two_teams_ne",
				filter = {
					actorType = "player",
					side = sidehelper.home,
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p17_cameraplayer",
				animName = "p17_intro_std_two_teams_ne",
				filter = {
					actorType = "player",
					side = sidehelper.home
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				animName = "p18_intro_std_two_teams_ne",
				filter = {
					actorType = "player",
					side = sidehelper.home
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				animName = "p19_intro_std_two_teams_ne",
				filter = {
					actorType = "player",
					side = sidehelper.home
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				animName = "p20_intro_std_two_teams_ne",
				filter = {
					actorType = "player",
					side = sidehelper.home
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p21_cameraplayer",
				animName = "p21_intro_std_two_teams_ne",
				filter = {
					actorType = "player",
					side = sidehelper.home
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				animName = "p22_intro_std_two_teams_ne",
				filter = {
					actorType = "player",
					side = sidehelper.home
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				animName = "p23_intro_std_two_teams_ne",
				filter = {
					actorType = "player",
					side = sidehelper.home
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p24_cameraplayer",
				animName = "p24_intro_std_two_teams_ne",
				filter = {
					actorType = "player",
					side = sidehelper.home
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				animName = "p25_intro_std_two_teams_ne",
				filter = {
					actorType = "player",
					side = sidehelper.home
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				animName = "p26_intro_std_two_teams_ne",
				filter = {
					actorType = "player",
					side = sidehelper.home
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				animName = "p27_intro_std_two_teams_ne",
				filter = {
					actorType = "player",
					side = sidehelper.home
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				animName = "p28_intro_std_two_teams_ne",
				filter = {
					actorType = "player",
					side = sidehelper.home
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				animName = "p29_intro_std_two_teams_ne",
				filter = {
					actorType = "player",
					side = sidehelper.home
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				animName = "p30_intro_std_two_teams_ne",
				filter = {
					actorType = "player",
					side = sidehelper.home
				},
				optional = true,
				syncOnFrame = 0
			}
		},
		cameras = {
			{
				name = "cs_camera02",
				animName = "p1_intro_std_two_teams_ne",
				dof = {
					{
						frame = 0,
						focusArea = 25,
						focusDistance = 6,
						focusTransition = 30,
						intensity = 0.05,
						nearIntensity = 0
					}
				},
				jointName = "cs_camera02",
				near = 0.1
			},
			{
				name = "cs_camera03",
				animName = "p1_intro_std_two_teams_ne",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 3.5,
						intensity = 1,
						nearIntensity = 1.5,
						targetActor = "p17_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p17_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 17
			},
			{
				name = "cs_camera04",
				animName = "p1_intro_std_two_teams_ne",
				dof = {
					{
						frame = 100,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = "auto",
						focusTransition = 1,
						intensity = 0.95,
						nearIntensity = 1.2,
						targetActor = "p9_cameraplayer"
					}
				},
				jointName = "cs_camera04",
				moveRelativeToActorLabel = "p9_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 9
			},
			{
				name = "cs_camera05",
				animName = "p1_intro_std_two_teams_ne",
				dof = {
					{
						frame = 110,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = "auto",
						focusTransition = 8,
						intensity = 0.15,
						nearIntensity = 0,
						targetActor = "p24_cameraplayer"
					},
					{
						frame = 184,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 16,
						intensity = 0.07,
						nearIntensity = 0,
						targetActor = "p24_cameraplayer"
					},
					{
						frame = 252,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = "auto",
						focusTransition = 1,
						intensity = 0.3,
						nearIntensity = 0,
						targetActor = "p24_cameraplayer"
					}
				},
				jointName = "cs_camera05",
				moveRelativeToActorLabel = "p24_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 24
			},
			{
				name = "cs_camera06",
				animName = "p1_intro_std_two_teams_ne",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5,
						focusDistance = "auto",
						focusTransition = 20,
						intensity = 0.05,
						nearIntensity = 0,
						targetActor = "p21_cameraplayer"
					}
				},
				jointName = "cs_camera06",
				moveRelativeToActorLabel = "p21_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 21
			},
			{
				name = "cs_camera07",
				animName = "p1_intro_std_two_teams_ne",
				dof = {
					{
						frame = 195,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5,
						focusDistance = "auto",
						focusTransition = 20,
						intensity = 0.3,
						nearIntensity = 0,
						targetActor = "p6_cameraplayer"
					}
				},
				jointName = "cs_camera07",
				moveRelativeToActorLabel = "p6_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 6
			},
			{
				name = "cs_camera10",
				animName = "p1_intro_std_two_teams_ne",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.15,
						nearIntensity = 0,
						targetActor = "p16_cameraplayer"
					}
				},
				jointName = "cs_camera10",
				moveRelativeToActorLabel = "p16_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 16
			},
			{
				name = "cs_camera12",
				animName = "p1_intro_std_two_teams_ne",
				dof = {
					{
						frame = 0,
						focusArea = 15,
						focusDistance = 30,
						focusTransition = 0.01,
						intensity = 0,
						nearIntensity = 0
					}
				},
				jointName = "cs_camera12",
				near = 0.1
			},
			{
				name = "cs_camera14",
				animName = "p1_intro_std_two_teams_ne",
				jointName = "cs_camera14",
				near = 0.1
			},
			{
				name = "cs_camera17",
				animName = "p1_intro_std_two_teams_ne",
				dof = {
					{
						frame = 0,
						focusArea = 10,
						focusDistance = 6,
						focusTransition = 25,
						intensity = 0.05,
						nearIntensity = 0
					}
				},
				jointName = "cs_camera17",
				moveRelativeToActorLabel = "p8_cameraplayer",
				near = 1.5,
				scaleCameraHeightToActorIndex = 8
			}
		},
		clampScale = native.CRange(0.98, 1.04),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera12",
					transition = "cut"
				},
				{
					frame = 112,
					camera = "cs_camera03",
					transition = "cut"
				},
				{
					frame = 187,
					camera = "cs_camera07",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				},
				{
					frame = 100,
					camera = "cs_camera04",
					transition = "cut"
				},
				{
					frame = 184,
					camera = "cs_camera06",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera14",
					transition = "cut"
				},
				{
					frame = 80,
					camera = "cs_camera07",
					transition = "cut"
				},
				{
					frame = 173,
					camera = "cs_camera10",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera17",
					transition = "cut"
				},
				{
					frame = 112,
					camera = "cs_camera05",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.Custom,
		lightingScenes = {
			"cinematic_generic_walkon_flamejet_01",
			"cinematic_generic_walkon_flamejet_02"
		},
		playbackEvents = {
			{
				name = "ParticleEvent",
				frame = 0,
				particleEvent = "f01_cs_flame_stream_all"
			},
			{
				name = "ParticleEvent",
				frame = 100,
				particleEvent = "f01_cs_flame_burst02_all"
			},
			{
				name = "ParticleEvent",
				frame = 130,
				particleEvent = "f01_cs_flame_burst02_all"
			},
			{
				name = "ParticleEvent",
				frame = 160,
				particleEvent = "f01_cs_flame_burst02_all"
			},
			{
				name = "ParticleEvent",
				frame = 190,
				particleEvent = "f01_cs_flame_burst02_all"
			},
			{
				name = "ParticleEvent",
				frame = 220,
				particleEvent = "f01_cs_flame_burst02_all"
			},
			{
				name = "ParticleEvent",
				frame = 250,
				particleEvent = "f01_cs_flame_burst02_all"
			},
			{
				name = "ParticleEvent",
				frame = 280,
				particleEvent = "f01_cs_flame_burst02_all"
			},
			{
				name = "ParticleEvent",
				frame = 310,
				particleEvent = "f01_cs_flame_burst02_all"
			},
			{
				name = "ParticleEvent",
				frame = 340,
				particleEvent = "f01_cs_flame_burst02_all"
			},
			{
				name = "PlaySequenceClip",
				frame = 100,
				sequenceClipName = "flame_jet_L_02burst",
				sequenceName = "flamejets_emission_light_01"
			},
			{
				name = "PlaySequenceClip",
				frame = 130,
				sequenceClipName = "flame_jet_L_02burst",
				sequenceName = "flamejets_emission_light_01"
			},
			{
				name = "PlaySequenceClip",
				frame = 160,
				sequenceClipName = "flame_jet_L_02burst",
				sequenceName = "flamejets_emission_light_01"
			},
			{
				name = "PlaySequenceClip",
				frame = 190,
				sequenceClipName = "flame_jet_L_02burst",
				sequenceName = "flamejets_emission_light_01"
			},
			{
				name = "PlaySequenceClip",
				frame = 220,
				sequenceClipName = "flame_jet_L_02burst",
				sequenceName = "flamejets_emission_light_01"
			},
			{
				name = "PlaySequenceClip",
				frame = 250,
				sequenceClipName = "flame_jet_L_02burst",
				sequenceName = "flamejets_emission_light_01"
			},
			{
				name = "PlaySequenceClip",
				frame = 280,
				sequenceClipName = "flame_jet_L_02burst",
				sequenceName = "flamejets_emission_light_01"
			},
			{
				name = "PlaySequenceClip",
				frame = 310,
				sequenceClipName = "flame_jet_L_02burst",
				sequenceName = "flamejets_emission_light_01"
			},
			{
				name = "PlaySequenceClip",
				frame = 340,
				sequenceClipName = "flame_jet_L_02burst",
				sequenceName = "flamejets_emission_light_01"
			},
			{
				name = "PlaySequenceClip",
				frame = 100,
				sequenceClipName = "flame_jet_L_02burst",
				sequenceName = "flamejets_emission_light_02"
			},
			{
				name = "PlaySequenceClip",
				frame = 130,
				sequenceClipName = "flame_jet_L_02burst",
				sequenceName = "flamejets_emission_light_02"
			},
			{
				name = "PlaySequenceClip",
				frame = 160,
				sequenceClipName = "flame_jet_L_02burst",
				sequenceName = "flamejets_emission_light_02"
			},
			{
				name = "PlaySequenceClip",
				frame = 190,
				sequenceClipName = "flame_jet_L_02burst",
				sequenceName = "flamejets_emission_light_02"
			},
			{
				name = "PlaySequenceClip",
				frame = 220,
				sequenceClipName = "flame_jet_L_02burst",
				sequenceName = "flamejets_emission_light_02"
			},
			{
				name = "PlaySequenceClip",
				frame = 250,
				sequenceClipName = "flame_jet_L_02burst",
				sequenceName = "flamejets_emission_light_02"
			},
			{
				name = "PlaySequenceClip",
				frame = 280,
				sequenceClipName = "flame_jet_L_02burst",
				sequenceName = "flamejets_emission_light_02"
			},
			{
				name = "PlaySequenceClip",
				frame = 310,
				sequenceClipName = "flame_jet_L_02burst",
				sequenceName = "flamejets_emission_light_02"
			},
			{
				name = "PlaySequenceClip",
				frame = 340,
				sequenceClipName = "flame_jet_L_02burst",
				sequenceName = "flamejets_emission_light_02"
			},
			{
				name = "CrowdEvent",
				frame = 1,
				animations = {
					{
						animGroup = native.ECrowdAnimGroup.excitement_level_1,
						forceSnap = true,
						tags = "TAGS_HOME"
					},
					{
						animGroup = native.ECrowdAnimGroup.excitement_level_4,
						forceSnap = true,
						tags = "TAGS_AWAY"
					}
				},
				group = "Intro"
			}
		},
		povCameraAllowed = false,
		props = {
			{
				name = "props/cutscene/models/effectMachine_flame01.model",
				fxFile = "effectMachine_flame01_cutscene_01a_fx",
				orientation = {
					0,
					0,
					0
				},
				position = {
					2,
					0,
					-34.5
				}
			},
			{
				name = "props/cutscene/models/effectMachine_flame01.model",
				fxFile = "effectMachine_flame01_cutscene_01a_fx",
				orientation = {
					0,
					0,
					0
				},
				position = {
					-2,
					0,
					-34.5
				}
			}
		},
		sequences = {
			flamejets_emission_light_01 = {
				propIndices = {},
				sequencer = "ui/frontend/flamejets_emission_light_01.seq"
			},
			flamejets_emission_light_02 = {
				propIndices = {},
				sequencer = "ui/frontend/flamejets_emission_light_02.seq"
			}
		},
		soundEvents = {
			{
				frame = 60,
				eventTable = {
					soundKey = "sfx_cutscene_crowd_match_intro_01",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 143,
				eventTable = {
					soundKey = "sfx_cutscene_player_vocals_match_intro_01",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 635,
				eventTable = {
					soundKey = "sfx_cutscene_player_claps_match_intro_01",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 130,
				eventTable = {
					soundKey = "sfx_cutscene_flame_jets_match_intro_01",
					type = "PlaySoundEvent"
				}
			},
			{
				frame = 60,
				eventTable = {
					type = "PlayAwayThemeEvent"
				}
			}
		},
		syncToWorldPositions = true,
		worldPos = {
			0,
			0
		},
		worldRot = 0
	},
	r25_RefereePenalty_01 = {
		animsetName = "r25_cutsceneRefereePenalty",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_referee_penalty_01",
				filter = {
					actorType = "official"
				},
				optional = false,
				syncOnFrame = 97
			},
			{
				name = "p2_cameraplayer",
				animName = "p2_referee_penalty_01",
				filter = {
					actorType = "player"
				},
				optional = false,
				syncOnFrame = 97
			},
			{
				animName = "p3_referee_penalty_01",
				filter = {
					actorType = "player",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 97
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_referee_penalty_01",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2.6,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0.2,
						nearIntensity = 0,
						targetActor = "p2_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p2_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 2
			},
			{
				name = "cs_camera02",
				animName = "p1_referee_penalty_01",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0.07,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_referee_penalty_01",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0.8,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 55,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0.8,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 80,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.4,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera06",
				animName = "p1_referee_penalty_01",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 4,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 215,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1.4,
						focusDistance = "auto",
						focusTransition = 1.4,
						intensity = 0.08,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera06",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera06",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false,
		syncToWorldPositions = true,
		worldRot = 0
	},
	r25_RefereePenalty_02 = {
		animsetName = "r25_cutsceneRefereePenalty",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_referee_penalty_02",
				filter = {
					actorType = "official"
				},
				optional = false,
				syncOnFrame = 60
			},
			{
				name = "p2_cameraplayer",
				animName = "p2_referee_penalty_02",
				filter = {
					actorType = "player"
				},
				optional = false,
				syncOnFrame = 60
			}
		},
		cameras = {
			{
				name = "cs_camera03",
				animName = "p1_referee_penalty_02",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0.35,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 70,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0.35,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 170,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0.95,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera05",
				animName = "p1_referee_penalty_02",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1.6,
						focusDistance = "auto",
						focusTransition = 1.6,
						intensity = 0.11,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 60,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1.6,
						focusDistance = "auto",
						focusTransition = 1.6,
						intensity = 0.11,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 95,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1.6,
						focusDistance = "auto",
						focusTransition = 1.6,
						intensity = 0.06,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera05",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera07",
				animName = "p1_referee_penalty_02",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2.3,
						focusDistance = "auto",
						focusTransition = 1.5,
						intensity = 0.17,
						nearIntensity = 0,
						targetActor = "p2_cameraplayer"
					},
					{
						frame = 70,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = "auto",
						focusTransition = 1,
						intensity = 0.03,
						nearIntensity = 0,
						targetActor = "p2_cameraplayer"
					}
				},
				jointName = "cs_camera07",
				moveRelativeToActorLabel = "p2_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 2
			}
		},
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera05",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera07",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false,
		syncToWorldPositions = true,
		worldRot = 0
	},
	r25_RefereePenalty_03 = {
		animsetName = "r25_cutsceneRefereePenalty",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_referee_penalty_03",
				filter = {
					actorType = "official"
				},
				optional = false,
				syncOnFrame = 24
			},
			{
				name = "p2_cameraplayer",
				animName = "p2_referee_penalty_03",
				filter = {
					actorType = "player"
				},
				optional = false,
				syncOnFrame = 24
			},
			{
				animName = "p3_referee_penalty_03",
				filter = {
					actorType = "player",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 24
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_referee_penalty_03",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2.5,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0.11,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 190,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 1.6,
						intensity = 0.2,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 255,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 1.6,
						intensity = 0.2,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 270,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2.6,
						focusDistance = "auto",
						focusTransition = 1.6,
						intensity = 0.2,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_referee_penalty_03",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 1.2,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 30,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 1.2,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 50,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0.87,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera05",
				animName = "p1_referee_penalty_03",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 1,
						intensity = 0.07,
						nearIntensity = 0,
						targetActor = "p2_cameraplayer"
					}
				},
				jointName = "cs_camera05",
				moveRelativeToActorLabel = "p2_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 2
			}
		},
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera05",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false,
		syncToWorldPositions = true,
		worldRot = 0
	},
	r25_RefereePenalty_04 = {
		animsetName = "r25_cutsceneRefereePenalty",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_referee_penalty_04",
				filter = {
					actorType = "official"
				},
				optional = false,
				syncOnFrame = 33
			},
			{
				name = "p2_cameraplayer",
				animName = "p2_referee_penalty_04",
				filter = {
					actorType = "player"
				},
				optional = false,
				syncOnFrame = 33
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_referee_penalty_04",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 2.4,
						intensity = 0.2,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_referee_penalty_04",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2.5,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 1.1,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera06",
				animName = "p1_referee_penalty_04",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = "auto",
						focusTransition = 12.6,
						intensity = 0.05,
						nearIntensity = 0,
						targetActor = "p2_cameraplayer"
					}
				},
				jointName = "cs_camera06",
				moveRelativeToActorLabel = "p2_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 2
			}
		},
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera06",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false,
		syncToWorldPositions = true,
		worldRot = 0
	},
	r25_TryCelebrate24_01 = {
		animsetName = "r25_cutsceneTryCelebrates24",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_01_celebrate_intense_fist_pump_group",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 100
			},
			{
				animName = "p2_01_celebrate_intense_fist_pump_group",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 100
			},
			{
				animName = "p3_01_celebrate_intense_fist_pump_group",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 100
			},
			{
				animName = "p4_01_celebrate_intense_fist_pump_group",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 100
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_01_celebrate_intense_fist_pump_group",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.2,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_01_celebrate_intense_fist_pump_group",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_01_celebrate_intense_fist_pump_group",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.3,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 92,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.3,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 114,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.2,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false,
		props = {
			{
				name = "ball",
				attachTo = {
					name = "p1_cameraplayer",
					jointName = "ballJoint"
				}
			}
		}
	},
	r25_TryCelebrate24_02 = {
		animsetName = "r25_cutsceneTryCelebrates24",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_02_celebrate_ball_throw_stand_run",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 77
			},
			{
				animName = "p2_02_celebrate_ball_throw_stand_run",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 77
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_02_celebrate_ball_throw_stand_run",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.8,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_02_celebrate_ball_throw_stand_run",
				dof = {
					{
						frame = 10,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1.5,
						focusDistance = "auto",
						focusTransition = 4,
						intensity = 0.1,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 35,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1.5,
						focusDistance = "auto",
						focusTransition = 1.1,
						intensity = 0.1,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_02_celebrate_ball_throw_stand_run",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 5.5,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false,
		props = {
			{
				name = "ball",
				attachTo = {
					name = "p1_cameraplayer",
					jointName = "ballJoint"
				}
			}
		}
	},
	r25_TryCelebrate24_03 = {
		animsetName = "r25_cutsceneTryCelebrates24",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_03_celebrate_exhausted",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 84
			},
			{
				animName = "p2_03_celebrate_exhausted",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 84
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_03_celebrate_exhausted",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 6,
						intensity = 0.65,
						nearIntensity = 0.1,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_03_celebrate_exhausted",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 6,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_03_celebrate_exhausted",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 20,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 40,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 1,
						intensity = 0.15,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false
	},
	r25_TryCelebrate24_03b = {
		animsetName = "r25_cutsceneTryCelebrates24",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_03_celebrate_exhausted_b",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 54
			},
			{
				animName = "p2_03_celebrate_exhausted_b",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 54
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_03_celebrate_exhausted_b",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 6,
						intensity = 0.65,
						nearIntensity = 0.1,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_03_celebrate_exhausted_b",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 6,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_03_celebrate_exhausted_b",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 20,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 40,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 1,
						intensity = 0.15,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false
	},
	r25_TryCelebrate24_04 = {
		animsetName = "r25_cutsceneTryCelebrates24",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_04_celebrate_fist_raise_yell_run",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 128
			},
			{
				animName = "p2_04_celebrate_fist_raise_yell_run",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 128
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_04_celebrate_fist_raise_yell_run",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.55,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_04_celebrate_fist_raise_yell_run",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1.5,
						focusDistance = "auto",
						focusTransition = 1,
						intensity = 0.3,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_04_celebrate_fist_raise_yell_run",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false
	},
	r25_TryCelebrate24_05 = {
		animsetName = "r25_cutsceneTryCelebrates24",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_05_celebrate_group_head_scuff",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 214
			},
			{
				animName = "p2_05_celebrate_group_head_scuff",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 214
			},
			{
				animName = "p3_05_celebrate_group_head_scuff",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 214
			},
			{
				animName = "p4_05_celebrate_group_head_scuff",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 214
			},
			{
				animName = "p5_05_celebrate_group_head_scuff",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 214
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_05_celebrate_group_head_scuff",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4.7,
						focusDistance = "auto",
						focusTransition = 6,
						intensity = 0.2,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 35,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4.7,
						focusDistance = "auto",
						focusTransition = 6,
						intensity = 0.2,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 75,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.4,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_05_celebrate_group_head_scuff",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_05_celebrate_group_head_scuff",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.2,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false
	},
	r25_TryCelebrate24_06 = {
		animsetName = "r25_cutsceneTryCelebrates24",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_06_celebrate_intense_yell_onspot_group",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 56
			},
			{
				animName = "p2_06_celebrate_intense_yell_onspot_group",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 56
			},
			{
				animName = "p3_06_celebrate_intense_yell_onspot_group",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 56
			},
			{
				animName = "p4_06_celebrate_intense_yell_onspot_group",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 56
			},
			{
				animName = "p5_06_celebrate_intense_yell_onspot_group",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 56
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_06_celebrate_intense_yell_onspot_group",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 6,
						focusDistance = "auto",
						focusTransition = 19,
						intensity = 0.7,
						nearIntensity = 0.1,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_06_celebrate_intense_yell_onspot_group",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5.7,
						focusDistance = "auto",
						focusTransition = 5,
						intensity = 0.2,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 24,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5.7,
						focusDistance = "auto",
						focusTransition = 5,
						intensity = 0.2,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 45,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.2,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_06_celebrate_intense_yell_onspot_group",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 6,
						focusDistance = "auto",
						focusTransition = 19,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false,
		props = {
			{
				name = "ball",
				attachTo = {
					name = "p1_cameraplayer",
					jointName = "ballJoint"
				}
			}
		}
	},
	r25_TryCelebrate24_07 = {
		animsetName = "r25_cutsceneTryCelebrates24",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_07_celebrate_intense_yell_walk_3",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 59
			},
			{
				animName = "p2_07_celebrate_intense_yell_walk_3",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 59
			},
			{
				animName = "p3_07_celebrate_intense_yell_walk_3",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 59
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_07_celebrate_intense_yell_walk_3",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 8,
						intensity = 1,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_07_celebrate_intense_yell_walk_3",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3.8,
						focusDistance = "auto",
						focusTransition = 4,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 7,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3.8,
						focusDistance = "auto",
						focusTransition = 4,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 25,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 1.7,
						intensity = 0.23,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_07_celebrate_intense_yell_walk_3",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 8,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false
	},
	r25_TryCelebrate24_08 = {
		animsetName = "r25_cutsceneTryCelebrates24",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_08_celebrate_jog_bounce_group",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 91
			},
			{
				animName = "p2_08_celebrate_jog_bounce_group",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 91
			},
			{
				animName = "p3_08_celebrate_jog_bounce_group",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 91
			},
			{
				animName = "p4_08_celebrate_jog_bounce_group",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 91
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_08_celebrate_jog_bounce_group",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.4,
						nearIntensity = 0.5,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_08_celebrate_jog_bounce_group",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 3.3,
						intensity = 0.17,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_08_celebrate_jog_bounce_group",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false
	},
	r25_TryCelebrate24_09 = {
		animsetName = "r25_cutsceneTryCelebrates24",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_09_celebrate_jump_up_fall_down_group",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 100
			},
			{
				animName = "p2_09_celebrate_jump_up_fall_down_group",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 100
			},
			{
				animName = "p3_09_celebrate_jump_up_fall_down_group",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 100
			},
			{
				animName = "p4_09_celebrate_jump_up_fall_down_group",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 100
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_09_celebrate_jump_up_fall_down_group",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 7,
						focusDistance = "auto",
						focusTransition = 5.4,
						intensity = 0.4,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_09_celebrate_jump_up_fall_down_group",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1.5,
						focusDistance = "auto",
						focusTransition = 1.6,
						intensity = 0.12,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 57,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1.5,
						focusDistance = "auto",
						focusTransition = 1.6,
						intensity = 0.12,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 80,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2.4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.1,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_09_celebrate_jump_up_fall_down_group",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 7,
						focusDistance = "auto",
						focusTransition = 5.4,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false
	},
	r25_TryCelebrate24_10 = {
		animsetName = "r25_cutsceneTryCelebrates24",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_10_celebrate_knees_ball_throw",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 167
			},
			{
				animName = "p2_10_celebrate_knees_ball_throw",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 167
			},
			{
				animName = "p3_10_celebrate_knees_ball_throw",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 167
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_10_celebrate_knees_ball_throw",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.3,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_10_celebrate_knees_ball_throw",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_10_celebrate_knees_ball_throw",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 8.15,
						focusDistance = "auto",
						focusTransition = 7,
						intensity = 0.1,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 78,
						autoDofJoints = {
							"hips"
						},
						focusArea = 8.15,
						focusDistance = "auto",
						focusTransition = 7,
						intensity = 0.1,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 105,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.1,
						nearIntensity = 0.1,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false,
		props = {
			{
				name = "ball",
				attachTo = {
					name = "p1_cameraplayer",
					jointName = "ballJoint"
				}
			}
		}
	},
	r25_TryCelebrate24_11 = {
		animsetName = "r25_cutsceneTryCelebrates24",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_11_celebrate_pass_ball",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 94
			},
			{
				animName = "p2_11_celebrate_pass_ball",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 94
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_11_celebrate_pass_ball",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.2,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_11_celebrate_pass_ball",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_11_celebrate_pass_ball",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4.3,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.4,
						nearIntensity = 0.4,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false,
		props = {
			{
				name = "ball",
				attachTo = {
					name = "p1_cameraplayer",
					jointName = "ballJoint"
				}
			}
		}
	},
	r25_TryCelebrate24_12 = {
		animsetName = "r25_cutsceneTryCelebrates24",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_12_celebrate_point_up",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 113
			},
			{
				animName = "p2_12_celebrate_point_up",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 113
			},
			{
				animName = "p3_12_celebrate_point_up",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 113
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_12_celebrate_point_up",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.7,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_12_celebrate_point_up",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2.7,
						focusDistance = "auto",
						focusTransition = 9,
						intensity = 0.45,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_12_celebrate_point_up",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false
	},
	r25_TryCelebrate24_12b = {
		animsetName = "r25_cutsceneTryCelebrates24",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_12_celebrate_point_up_02",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 53
			},
			{
				animName = "p2_12_celebrate_point_up_02",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 53
			},
			{
				animName = "p3_12_celebrate_point_up_02",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 53
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_12_celebrate_point_up_02",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.7,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_12_celebrate_point_up_02",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2.7,
						focusDistance = "auto",
						focusTransition = 9,
						intensity = 0.45,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_12_celebrate_point_up_02",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false
	},
	r25_TryCelebrate24_13 = {
		animsetName = "r25_cutsceneTryCelebrates24",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_13_celebrate_pray",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 97
			},
			{
				animName = "p2_13_celebrate_pray",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 97
			},
			{
				animName = "p3_13_celebrate_pray",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 97
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_13_celebrate_pray",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.8,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_13_celebrate_pray",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = "auto",
						focusTransition = 1,
						intensity = 0.15,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_13_celebrate_pray",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false
	},
	r25_TryCelebrate24_14 = {
		animsetName = "r25_cutsceneTryCelebrates24",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_14_celebrate_roll_arm_point_walk_away_3",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 85
			},
			{
				animName = "p2_14_celebrate_roll_arm_point_walk_away_3",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 85
			},
			{
				animName = "p3_14_celebrate_roll_arm_point_walk_away_3",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 85
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_14_celebrate_roll_arm_point_walk_away_3",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5,
						focusDistance = "auto",
						focusTransition = 7,
						intensity = 0.3,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_14_celebrate_roll_arm_point_walk_away_3",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5,
						focusDistance = "auto",
						focusTransition = 7,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_14_celebrate_roll_arm_point_walk_away_3",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10.7,
						focusDistance = "auto",
						focusTransition = 7,
						intensity = 0.3,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 14,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10.7,
						focusDistance = "auto",
						focusTransition = 7,
						intensity = 0.3,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 26,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 5,
						intensity = 0.13,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false
	},
	r25_TryCelebrate24_15 = {
		animsetName = "r25_cutsceneTryCelebrates24",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_15_celebrate_run_backwards_group",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 102
			},
			{
				animName = "p2_15_celebrate_run_backwards_group",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 102
			},
			{
				animName = "p3_15_celebrate_run_backwards_group",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 102
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_15_celebrate_run_backwards_group",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2.5,
						focusDistance = "auto",
						focusTransition = 4,
						intensity = 0.65,
						nearIntensity = 0.2,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_15_celebrate_run_backwards_group",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2.5,
						focusDistance = "auto",
						focusTransition = 4,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_15_celebrate_run_backwards_group",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.2,
						nearIntensity = 0.2,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false
	},
	r25_TryCelebrate24_16 = {
		animsetName = "r25_cutsceneTryCelebrates24",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_16_celebrate_slow_get_up_hand_slap",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 50
			},
			{
				animName = "p2_16_celebrate_slow_get_up_hand_slap",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 50
			},
			{
				animName = "p3_16_celebrate_slow_get_up_hand_slap",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 50
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_16_celebrate_slow_get_up_hand_slap",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 6,
						intensity = 0.4,
						nearIntensity = 0.2,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 88,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 1.5,
						intensity = 0.65,
						nearIntensity = 0.2,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_16_celebrate_slow_get_up_hand_slap",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5,
						focusDistance = "auto",
						focusTransition = 15,
						intensity = 1,
						nearIntensity = 0.5,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_16_celebrate_slow_get_up_hand_slap",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 9,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false
	},
	r25_TryCelebrate24_16b = {
		animsetName = "r25_cutsceneTryCelebrates24",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_16_celebrate_slow_get_up_hand_slap_b",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 1
			},
			{
				animName = "p2_16_celebrate_slow_get_up_hand_slap_b",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 1
			},
			{
				animName = "p3_16_celebrate_slow_get_up_hand_slap_b",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 1
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_16_celebrate_slow_get_up_hand_slap_b",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 6,
						intensity = 0.4,
						nearIntensity = 0.2,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 63,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 1.5,
						intensity = 0.65,
						nearIntensity = 0.2,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_16_celebrate_slow_get_up_hand_slap_b",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5,
						focusDistance = "auto",
						focusTransition = 15,
						intensity = 1,
						nearIntensity = 0.5,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_16_celebrate_slow_get_up_hand_slap_b",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 9,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false
	},
	r25_TryCelebrate24_17 = {
		animsetName = "r25_cutsceneTryCelebrates24",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_17_celebrate_stand_quick_hug_2",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 60
			},
			{
				animName = "p2_17_celebrate_stand_quick_hug_2",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 60
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_17_celebrate_stand_quick_hug_2",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.4,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 40,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.4,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 70,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.8,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 95,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.8,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 125,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 1,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_17_celebrate_stand_quick_hug_2",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1.5,
						focusDistance = "auto",
						focusTransition = 5.8,
						intensity = 1,
						nearIntensity = 0.5,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_17_celebrate_stand_quick_hug_2",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false
	},
	r25_TryCelebrate24_17b = {
		animsetName = "r25_cutsceneTryCelebrates24",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_17_celebrate_stand_quick_hug_2_b",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 40
			},
			{
				animName = "p2_17_celebrate_stand_quick_hug_2_b",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 40
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_17_celebrate_stand_quick_hug_2_b",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.4,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 20,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.4,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 50,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.8,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 75,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.8,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 105,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 1,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_17_celebrate_stand_quick_hug_2_b",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1.5,
						focusDistance = "auto",
						focusTransition = 5.8,
						intensity = 1,
						nearIntensity = 0.5,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_17_celebrate_stand_quick_hug_2_b",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false
	},
	r25_TryCelebrate24_18 = {
		animsetName = "r25_cutsceneTryCelebrates24",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_18_celebrate_standing_3",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 218
			},
			{
				animName = "p2_18_celebrate_standing_3",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 218
			},
			{
				animName = "p3_18_celebrate_standing_3",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 218
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_18_celebrate_standing_3",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5.5,
						focusDistance = "auto",
						focusTransition = 12,
						intensity = 0.35,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 45,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5.5,
						focusDistance = "auto",
						focusTransition = 12,
						intensity = 0.35,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 107,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 8,
						intensity = 0.6,
						nearIntensity = 0.1,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_18_celebrate_standing_3",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5.5,
						focusDistance = "auto",
						focusTransition = 12,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_18_celebrate_standing_3",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1.5,
						focusDistance = "auto",
						focusTransition = 1,
						intensity = 0.15,
						nearIntensity = 0.1,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false
	},
	r25_TryCelebrate24_19 = {
		animsetName = "r25_cutsceneTryCelebrates24",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_19_celebrate_neutral_get_up_walk_1",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 0
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_19_celebrate_neutral_get_up_walk_1",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.8,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_19_celebrate_neutral_get_up_walk_1",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 1,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 80,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 1,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 90,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_19_celebrate_neutral_get_up_walk_1",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5.5,
						focusDistance = "auto",
						focusTransition = 12,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false,
		props = {
			{
				name = "ball",
				attachTo = {
					name = "p1_cameraplayer",
					jointName = "ballJoint"
				}
			}
		}
	},
	r25_TryCelebrate24_20 = {
		animsetName = "r25_cutsceneTryCelebrates24",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_20_celebrate_neutral_standing_walk_1",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 0
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_20_celebrate_neutral_standing_walk_1",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.35,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 34,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.35,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 57,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.7,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_20_celebrate_neutral_standing_walk_1",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 6,
						intensity = 0.35,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 61,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 6,
						intensity = 0.35,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 80,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 1,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_20_celebrate_neutral_standing_walk_1",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5.5,
						focusDistance = "auto",
						focusTransition = 12,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false,
		props = {
			{
				name = "ball",
				attachTo = {
					name = "p1_cameraplayer",
					jointName = "ballJoint"
				}
			}
		}
	},
	r25_TryCelebrate24_21 = {
		animsetName = "r25_cutsceneTryCelebrates24",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_21_celebrate_neutral_get_up_jog_1",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 380
			},
			{
				animName = "p2_21_celebrate_neutral_get_up_jog_1",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 380
			},
			{
				animName = "p3_21_celebrate_neutral_get_up_jog_1",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 380
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_21_celebrate_neutral_get_up_jog_1",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 3.6,
						intensity = 0.2,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 103,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 3.6,
						intensity = 0.2,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 132,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 4,
						intensity = 0.4,
						nearIntensity = 0.6,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 222,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 4,
						intensity = 0.4,
						nearIntensity = 0.6,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 270,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2.8,
						focusDistance = "auto",
						focusTransition = 4,
						intensity = 0.16,
						nearIntensity = 0.2,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_21_celebrate_neutral_get_up_jog_1",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.25,
						nearIntensity = 0.25,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_21_celebrate_neutral_get_up_jog_1",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 4,
						intensity = 0.4,
						nearIntensity = 0.3,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 160,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 4,
						intensity = 0.4,
						nearIntensity = 0.3,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 187,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5.5,
						focusDistance = "auto",
						focusTransition = 12,
						intensity = 0.25,
						nearIntensity = 0.2,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false,
		props = {
			{
				name = "ball",
				attachTo = {
					name = "p1_cameraplayer",
					jointName = "ballJoint"
				}
			}
		}
	},
	r25_TryCelebrate24_22 = {
		animsetName = "r25_cutsceneTryCelebrates24",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_22_celebrate_neutral_get_up_pass_ball_1",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				animName = "p2_22_celebrate_neutral_get_up_pass_ball_1",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 0
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_22_celebrate_neutral_get_up_pass_ball_1",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 6,
						focusDistance = "auto",
						focusTransition = 4,
						intensity = 1,
						nearIntensity = 0.2,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 35,
						autoDofJoints = {
							"hips"
						},
						focusArea = 6,
						focusDistance = "auto",
						focusTransition = 4,
						intensity = 1,
						nearIntensity = 0.2,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 68,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 4,
						intensity = 1,
						nearIntensity = 0.5,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_22_celebrate_neutral_get_up_pass_ball_1",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 2.7,
						intensity = 0.25,
						nearIntensity = 0.3,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_22_celebrate_neutral_get_up_pass_ball_1",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 4,
						intensity = 0.5,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 138,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 4,
						intensity = 0.5,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 173,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4,
						focusDistance = "auto",
						focusTransition = 4,
						intensity = 0.15,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false,
		props = {
			{
				name = "ball",
				attachTo = {
					name = "p1_cameraplayer",
					jointName = "ballJoint"
				}
			}
		}
	},
	r25_TryCelebrate24_23 = {
		animsetName = "r25_cutsceneTryCelebrates24",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_23_celebrate_neutral_standing_pass_ball_1",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				animName = "p2_23_celebrate_neutral_standing_pass_ball_1",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 0
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_23_celebrate_neutral_standing_pass_ball_1",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.3,
						nearIntensity = 0.5,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 40,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.3,
						nearIntensity = 0.5,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 53,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 1,
						intensity = 0.3,
						nearIntensity = 0.5,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 118,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 1,
						intensity = 0.3,
						nearIntensity = 0.5,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 135,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2.5,
						focusDistance = "auto",
						focusTransition = 4,
						intensity = 0.2,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 158,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2.5,
						focusDistance = "auto",
						focusTransition = 4,
						intensity = 0.2,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 180,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0.35,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_23_celebrate_neutral_standing_pass_ball_1",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5.5,
						focusDistance = "auto",
						focusTransition = 12,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_23_celebrate_neutral_standing_pass_ball_1",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.3,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 54,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.3,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 89,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = "auto",
						focusTransition = 0.8,
						intensity = 1,
						nearIntensity = 1,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false,
		props = {
			{
				name = "ball",
				attachTo = {
					name = "p1_cameraplayer",
					jointName = "ballJoint"
				}
			}
		}
	},
	r25_TryCelebrate24_24 = {
		animsetName = "r25_cutsceneTryCelebrates24",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_24_celebrate_neutral_standing_backpat_1",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 116
			},
			{
				animName = "p2_24_celebrate_neutral_standing_backpat_1",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 116
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_24_celebrate_neutral_standing_backpat_1",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.2,
						nearIntensity = 0.8,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 40,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1.5,
						focusDistance = "auto",
						focusTransition = 1,
						intensity = 0.6,
						nearIntensity = 0.8,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 70,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1.5,
						focusDistance = "auto",
						focusTransition = 1,
						intensity = 0.6,
						nearIntensity = 0.8,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 95,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 1,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera04",
				animName = "p1_24_celebrate_neutral_standing_backpat_1",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.25,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera04",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_24_celebrate_neutral_standing_backpat_1",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera04",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false,
		props = {
			{
				name = "ball",
				attachTo = {
					name = "p1_cameraplayer",
					jointName = "ballJoint"
				}
			}
		}
	},
	r25_TryCelebrate24_25 = {
		animsetName = "r25_cutsceneTryCelebrates24",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_25_celebrate_neutral_get_up_backpat_1",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 100
			},
			{
				animName = "p2_25_celebrate_neutral_get_up_backpat_1",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 100
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_25_celebrate_neutral_get_up_backpat_1",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.3,
						nearIntensity = 0.3,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 68,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.3,
						nearIntensity = 0.3,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 93,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 12,
						intensity = 0.2,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera04",
				animName = "p1_25_celebrate_neutral_get_up_backpat_1",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.35,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 94,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.35,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 115,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.25,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera04",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_25_celebrate_neutral_get_up_backpat_1",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.1,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera04",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false,
		props = {
			{
				name = "ball",
				attachTo = {
					name = "p1_cameraplayer",
					jointName = "ballJoint"
				}
			}
		}
	},
	r25_TryCelebrate24_26 = {
		animsetName = "r25_cutsceneTryCelebrates24",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_26_celebrate_neutral_standing_jog_1",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 100
			},
			{
				animName = "p2_26_celebrate_neutral_standing_jog_1",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 100
			},
			{
				animName = "p3_26_celebrate_neutral_standing_jog_1",
				filter = {
					actorType = "player"
				},
				optional = true,
				syncOnFrame = 100
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_26_celebrate_neutral_standing_jog_1",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5,
						focusDistance = "auto",
						focusTransition = 12,
						intensity = 0.25,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 75,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5,
						focusDistance = "auto",
						focusTransition = 12,
						intensity = 0.25,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 90,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5,
						focusDistance = "auto",
						focusTransition = 12,
						intensity = 0.15,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 130,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5,
						focusDistance = "auto",
						focusTransition = 12,
						intensity = 0.15,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 163,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 5,
						intensity = 0.4,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_26_celebrate_neutral_standing_jog_1",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.2,
						nearIntensity = 0.4,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_26_celebrate_neutral_standing_jog_1",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.35,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 23,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.35,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 43,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1.5,
						focusDistance = "auto",
						focusTransition = 1,
						intensity = 1,
						nearIntensity = 1,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false,
		props = {
			{
				name = "ball",
				attachTo = {
					name = "p1_cameraplayer",
					jointName = "ballJoint"
				}
			}
		}
	},
	r25_FiftyTwentyTwo_02 = {
		animsetName = "r25_FiftyTwentyTwo",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_fifty_twenty_two_02",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				animName = "p2_fifty_twenty_two_02",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_fifty_twenty_two_02",
				dof = {
					{
						frame = 214,
						focusArea = 8,
						focusDistance = 18.5,
						focusTransition = 30,
						intensity = 1.25,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_fifty_twenty_two_02",
				dof = {
					{
						frame = 55,
						focusArea = 8,
						focusDistance = 18,
						focusTransition = 2,
						intensity = 1.25,
						nearIntensity = 1,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 100,
						focusArea = 2,
						focusDistance = 20,
						focusTransition = 2,
						intensity = 1.25,
						nearIntensity = 1,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 140,
						focusArea = 2,
						focusDistance = 18,
						focusTransition = 2,
						intensity = 1.25,
						nearIntensity = 1,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		checkCameraBoundary = true,
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false
	},
	r25_FiftyTwentyTwo_03 = {
		animsetName = "r25_FiftyTwentyTwo",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_fifty_twenty_two_03",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				animName = "p2_fifty_twenty_two_03",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				animName = "p3_fifty_twenty_two_03",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_fifty_twenty_two_03",
				dof = {
					{
						frame = 214,
						focusArea = 8,
						focusDistance = 18.5,
						focusTransition = 30,
						intensity = 1.25,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_fifty_twenty_two_03",
				dof = {
					{
						frame = 55,
						focusArea = 8,
						focusDistance = 18,
						focusTransition = 2,
						intensity = 1.25,
						nearIntensity = 1,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 100,
						focusArea = 2,
						focusDistance = 20,
						focusTransition = 2,
						intensity = 1.25,
						nearIntensity = 1,
						targetActor = "p1_cameraplayer"
					},
					{
						frame = 140,
						focusArea = 2,
						focusDistance = 18,
						focusTransition = 2,
						intensity = 1.25,
						nearIntensity = 1,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		checkCameraBoundary = true,
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				},
				{
					frame = 50,
					camera = "cs_camera02",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false
	},
	r25_PostReplayScorerWalksBack_01 = {
		animsetName = "r25_cutscenePostReplay",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_post_replay_scorer_walks_back",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p2_cameraplayer",
				animName = "p2_post_replay_scorer_walks_back",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p3_cameraplayer",
				animName = "p3_post_replay_scorer_walks_back",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p4_cameraplayer",
				animName = "p4_post_replay_scorer_walks_back",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_post_replay_scorer_walks_back",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0.4,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_post_replay_scorer_walks_back",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0.4,
						nearIntensity = 0.5,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_post_replay_scorer_walks_back",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 1,
						intensity = 0.4,
						nearIntensity = 0,
						targetActor = "p1_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		checkCameraBoundary = true,
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false,
		soundEvents = {}
	},
	r25_PostReplayTeamHuddle_01 = {
		animsetName = "r25_cutscenePostReplay",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_post_replay_team_huddle",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p2_cameraplayer",
				animName = "p2_post_replay_team_huddle",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p3_cameraplayer",
				animName = "p3_post_replay_team_huddle",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p4_cameraplayer",
				animName = "p4_post_replay_team_huddle",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p5_cameraplayer",
				animName = "p5_post_replay_team_huddle",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p6_cameraplayer",
				animName = "p6_post_replay_team_huddle",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p7_cameraplayer",
				animName = "p7_post_replay_team_huddle",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p8_cameraplayer",
				animName = "p8_post_replay_team_huddle",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p9_cameraplayer",
				animName = "p9_post_replay_team_huddle",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p10_cameraplayer",
				animName = "p10_post_replay_team_huddle",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p11_cameraplayer",
				animName = "p11_post_replay_team_huddle",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p12_cameraplayer",
				animName = "p12_post_replay_team_huddle",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p13_cameraplayer",
				animName = "p13_post_replay_team_huddle",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p14_cameraplayer",
				animName = "p14_post_replay_team_huddle",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p15_cameraplayer",
				animName = "p15_post_replay_team_huddle",
				filter = {
					actorType = "player",
					side = "primary",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_post_replay_team_huddle",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 0.5,
						focusDistance = "45.3",
						focusTransition = 0.2,
						intensity = 0.5,
						nearIntensity = 0.5,
						targetActor = "p15_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera02",
				animName = "p1_post_replay_team_huddle",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 4.4,
						focusDistance = "28.5",
						focusTransition = 5.8,
						intensity = 1,
						nearIntensity = 0.5,
						targetActor = "p15_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera03",
				animName = "p1_post_replay_team_huddle",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 0.7,
						focusDistance = "2.3",
						focusTransition = 0.11,
						intensity = 0.54,
						nearIntensity = 0.55,
						targetActor = "p15_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			},
			{
				name = "cs_camera04",
				animName = "p1_post_replay_team_huddle",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1.7,
						focusDistance = "19.7",
						focusTransition = 1.1,
						intensity = 0.5,
						nearIntensity = 0.5,
						targetActor = "p15_cameraplayer"
					},
					{
						frame = 125,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1.7,
						focusDistance = "11.6",
						focusTransition = 1.1,
						intensity = 0.5,
						nearIntensity = 0.5,
						targetActor = "p15_cameraplayer"
					},
					{
						frame = 225,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1.7,
						focusDistance = "16.3",
						focusTransition = 1.1,
						intensity = 0.5,
						nearIntensity = 0.5,
						targetActor = "p15_cameraplayer"
					}
				},
				jointName = "cs_camera04",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				scaleCameraHeightToActorIndex = 1
			}
		},
		checkCameraBoundary = true,
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera04",
					transition = "cut"
				}
			}
		},
		cutsceneOrigin = native.ECutsceneOrigin.PrimaryActor,
		povCameraAllowed = false,
		soundEvents = {}
	},
	r25_FulltimeWinLose_01 = {
		animsetName = "r25_cutsceneFulltimeWinLose",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_fulltime_win_lose_cam01",
				filter = {
					actorType = "player",
					side = "secondary",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p2_cameraplayer",
				animName = "p2_fulltime_win_lose_cam01",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p3_cameraplayer",
				animName = "p3_fulltime_win_lose_cam01",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p4_cameraplayer",
				animName = "p4_fulltime_win_lose_cam01",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p5_cameraplayer",
				animName = "p5_fulltime_win_lose_cam01",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p6_cameraplayer",
				animName = "p6_fulltime_win_lose_cam01",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p7_cameraplayer",
				animName = "p7_fulltime_win_lose_cam01",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p8_cameraplayer",
				animName = "p8_fulltime_win_lose_cam01",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p9_cameraplayer",
				animName = "p9_fulltime_win_lose_cam01",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p10_cameraplayer",
				animName = "p10_fulltime_win_lose_cam01",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p11_cameraplayer",
				animName = "p11_fulltime_win_lose_cam01",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p12_cameraplayer",
				animName = "p12_fulltime_win_lose_cam01",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p13_cameraplayer",
				animName = "p13_fulltime_win_lose_cam01",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p14_cameraplayer",
				animName = "p14_fulltime_win_lose_cam01",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p15_cameraplayer",
				animName = "p15_fulltime_win_lose_cam01",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p16_cameraplayer",
				animName = "p16_fulltime_win_lose_cam01",
				filter = {
					actorType = "player",
					side = "primary",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p17_cameraplayer",
				animName = "p17_fulltime_win_lose_cam01",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p18_cameraplayer",
				animName = "p18_fulltime_win_lose_cam01",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p19_cameraplayer",
				animName = "p19_fulltime_win_lose_cam01",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p20_cameraplayer",
				animName = "p20_fulltime_win_lose_cam01",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p21_cameraplayer",
				animName = "p21_fulltime_win_lose_cam01",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p22_cameraplayer",
				animName = "p22_fulltime_win_lose_cam01",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p24_cameraplayer",
				animName = "p24_fulltime_win_lose_cam01",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p25_cameraplayer",
				animName = "p25_fulltime_win_lose_cam01",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p26_cameraplayer",
				animName = "p26_fulltime_win_lose_cam01",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p27_cameraplayer",
				animName = "p27_fulltime_win_lose_cam01",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p29_cameraplayer",
				animName = "p29_fulltime_win_lose_cam01",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p30_cameraplayer",
				animName = "p30_fulltime_win_lose_cam01",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_fulltime_win_lose_cam01",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 5,
						focusDistance = "auto",
						focusTransition = 5,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p30_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				near = 0.1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera01",
					transition = "cut"
				}
			}
		},
		playbackEvents = {
			{
				name = "CrowdEvent",
				frame = 5,
				animations = {
					{
						animGroup = native.ECrowdAnimGroup.excitement_level_3,
						tags = "TAGS_ALL"
					}
				},
				group = "full_time_applause",
				sounds = {
					{
						params = {
							noDuplicate = true
						},
						soundKey = "ApplauseLoop_EndOfMatch",
						tags = "TAGS_ALL"
					}
				}
			}
		},
		povCameraAllowed = false,
		soundEvents = {
			{
				frame = 1,
				eventTable = {
					musicType = "FullTime_Music_Play",
					type = "LoudspeakerPlayMusicEvent"
				}
			}
		},
		syncToWorldPositions = true,
		worldPos = {
			0,
			0
		},
		worldRot = 0
	},
	r25_FulltimeWinLose_02 = {
		animsetName = "r25_cutsceneFulltimeWinLose",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_fulltime_win_lose_cam02",
				filter = {
					actorType = "player",
					side = "secondary",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p2_cameraplayer",
				animName = "p2_fulltime_win_lose_cam02",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p3_cameraplayer",
				animName = "p3_fulltime_win_lose_cam02",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p4_cameraplayer",
				animName = "p4_fulltime_win_lose_cam02",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p5_cameraplayer",
				animName = "p5_fulltime_win_lose_cam02",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p6_cameraplayer",
				animName = "p6_fulltime_win_lose_cam02",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p7_cameraplayer",
				animName = "p7_fulltime_win_lose_cam02",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p8_cameraplayer",
				animName = "p8_fulltime_win_lose_cam02",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p9_cameraplayer",
				animName = "p9_fulltime_win_lose_cam02",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p10_cameraplayer",
				animName = "p10_fulltime_win_lose_cam02",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p11_cameraplayer",
				animName = "p11_fulltime_win_lose_cam02",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p12_cameraplayer",
				animName = "p12_fulltime_win_lose_cam02",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p13_cameraplayer",
				animName = "p13_fulltime_win_lose_cam02",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p14_cameraplayer",
				animName = "p14_fulltime_win_lose_cam02",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p15_cameraplayer",
				animName = "p15_fulltime_win_lose_cam02",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p16_cameraplayer",
				animName = "p16_fulltime_win_lose_cam02",
				filter = {
					actorType = "player",
					side = "primary",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p17_cameraplayer",
				animName = "p17_fulltime_win_lose_cam02",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p18_cameraplayer",
				animName = "p18_fulltime_win_lose_cam02",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p19_cameraplayer",
				animName = "p19_fulltime_win_lose_cam02",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p20_cameraplayer",
				animName = "p20_fulltime_win_lose_cam02",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p21_cameraplayer",
				animName = "p21_fulltime_win_lose_cam02",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p22_cameraplayer",
				animName = "p22_fulltime_win_lose_cam02",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p24_cameraplayer",
				animName = "p24_fulltime_win_lose_cam02",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p25_cameraplayer",
				animName = "p25_fulltime_win_lose_cam02",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p26_cameraplayer",
				animName = "p26_fulltime_win_lose_cam02",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p27_cameraplayer",
				animName = "p27_fulltime_win_lose_cam02",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p29_cameraplayer",
				animName = "p29_fulltime_win_lose_cam02",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p30_cameraplayer",
				animName = "p30_fulltime_win_lose_cam02",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			}
		},
		cameras = {
			{
				name = "cs_camera02",
				animName = "p1_fulltime_win_lose_cam02",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 1,
						nearIntensity = 1,
						targetActor = "p29_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				near = 0.1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera02",
					transition = "cut"
				}
			}
		},
		playbackEvents = {},
		povCameraAllowed = false,
		syncToWorldPositions = true,
		worldPos = {
			0,
			0
		},
		worldRot = 0
	},
	r25_FulltimeWinLose_03 = {
		animsetName = "r25_cutsceneFulltimeWinLose",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_fulltime_win_lose_cam03",
				filter = {
					actorType = "player",
					side = "secondary",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p2_cameraplayer",
				animName = "p2_fulltime_win_lose_cam03",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p3_cameraplayer",
				animName = "p3_fulltime_win_lose_cam03",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p4_cameraplayer",
				animName = "p4_fulltime_win_lose_cam03",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p5_cameraplayer",
				animName = "p5_fulltime_win_lose_cam03",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p6_cameraplayer",
				animName = "p6_fulltime_win_lose_cam03",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p7_cameraplayer",
				animName = "p7_fulltime_win_lose_cam03",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p8_cameraplayer",
				animName = "p8_fulltime_win_lose_cam03",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p9_cameraplayer",
				animName = "p9_fulltime_win_lose_cam03",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p10_cameraplayer",
				animName = "p10_fulltime_win_lose_cam03",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p11_cameraplayer",
				animName = "p11_fulltime_win_lose_cam03",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p12_cameraplayer",
				animName = "p12_fulltime_win_lose_cam03",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p13_cameraplayer",
				animName = "p13_fulltime_win_lose_cam03",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p14_cameraplayer",
				animName = "p14_fulltime_win_lose_cam03",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p15_cameraplayer",
				animName = "p15_fulltime_win_lose_cam03",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p16_cameraplayer",
				animName = "p16_fulltime_win_lose_cam03",
				filter = {
					actorType = "player",
					side = "primary",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p17_cameraplayer",
				animName = "p17_fulltime_win_lose_cam03",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p18_cameraplayer",
				animName = "p18_fulltime_win_lose_cam03",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p19_cameraplayer",
				animName = "p19_fulltime_win_lose_cam03",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p20_cameraplayer",
				animName = "p20_fulltime_win_lose_cam03",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p21_cameraplayer",
				animName = "p21_fulltime_win_lose_cam03",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p22_cameraplayer",
				animName = "p22_fulltime_win_lose_cam03",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p24_cameraplayer",
				animName = "p24_fulltime_win_lose_cam03",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p25_cameraplayer",
				animName = "p25_fulltime_win_lose_cam03",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p26_cameraplayer",
				animName = "p26_fulltime_win_lose_cam03",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p27_cameraplayer",
				animName = "p27_fulltime_win_lose_cam03",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p29_cameraplayer",
				animName = "p29_fulltime_win_lose_cam03",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p30_cameraplayer",
				animName = "p30_fulltime_win_lose_cam03",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			}
		},
		cameras = {
			{
				name = "cs_camera03",
				animName = "p1_fulltime_win_lose_cam03",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = 30,
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				near = 0.1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera03",
					transition = "cut"
				}
			}
		},
		playbackEvents = {
			{
				name = "CrowdEvent",
				frame = 100,
				animations = {
					{
						animGroup = native.ECrowdAnimGroup.excitement_level_3,
						tags = "TAGS_ALL"
					}
				},
				group = "full_time_applause",
				sounds = {
					{
						soundKey = "cheer_low",
						tags = "TAGS_ALL"
					}
				}
			}
		},
		povCameraAllowed = false,
		syncToWorldPositions = true,
		worldPos = {
			0,
			0
		},
		worldRot = 0
	},
	r25_FulltimeWinLose_04 = {
		animsetName = "r25_cutsceneFulltimeWinLose",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_fulltime_win_lose_cam04",
				filter = {
					actorType = "player",
					side = "secondary",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p2_cameraplayer",
				animName = "p2_fulltime_win_lose_cam04",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p3_cameraplayer",
				animName = "p3_fulltime_win_lose_cam04",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p4_cameraplayer",
				animName = "p4_fulltime_win_lose_cam04",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p5_cameraplayer",
				animName = "p5_fulltime_win_lose_cam04",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p6_cameraplayer",
				animName = "p6_fulltime_win_lose_cam04",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p7_cameraplayer",
				animName = "p7_fulltime_win_lose_cam04",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p8_cameraplayer",
				animName = "p8_fulltime_win_lose_cam04",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p9_cameraplayer",
				animName = "p9_fulltime_win_lose_cam04",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p10_cameraplayer",
				animName = "p10_fulltime_win_lose_cam04",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p11_cameraplayer",
				animName = "p11_fulltime_win_lose_cam04",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p12_cameraplayer",
				animName = "p12_fulltime_win_lose_cam04",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p13_cameraplayer",
				animName = "p13_fulltime_win_lose_cam04",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p14_cameraplayer",
				animName = "p14_fulltime_win_lose_cam04",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p15_cameraplayer",
				animName = "p15_fulltime_win_lose_cam04",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p16_cameraplayer",
				animName = "p16_fulltime_win_lose_cam04",
				filter = {
					actorType = "player",
					side = "primary",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p17_cameraplayer",
				animName = "p17_fulltime_win_lose_cam04",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p18_cameraplayer",
				animName = "p18_fulltime_win_lose_cam04",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p19_cameraplayer",
				animName = "p19_fulltime_win_lose_cam04",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p20_cameraplayer",
				animName = "p20_fulltime_win_lose_cam04",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p21_cameraplayer",
				animName = "p21_fulltime_win_lose_cam04",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p22_cameraplayer",
				animName = "p22_fulltime_win_lose_cam04",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p23_cameraplayer",
				animName = "p23_fulltime_win_lose_cam04",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p24_cameraplayer",
				animName = "p24_fulltime_win_lose_cam04",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p25_cameraplayer",
				animName = "p25_fulltime_win_lose_cam04",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p26_cameraplayer",
				animName = "p26_fulltime_win_lose_cam04",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p27_cameraplayer",
				animName = "p27_fulltime_win_lose_cam04",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p28_cameraplayer",
				animName = "p28_fulltime_win_lose_cam04",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p29_cameraplayer",
				animName = "p29_fulltime_win_lose_cam04",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p30_cameraplayer",
				animName = "p30_fulltime_win_lose_cam04",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			}
		},
		cameras = {
			{
				name = "cs_camera04",
				animName = "p1_fulltime_win_lose_cam04",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 2,
						focusDistance = "auto",
						focusTransition = 0.5,
						intensity = 0.01,
						nearIntensity = 0.01,
						targetActor = "p17_cameraplayer"
					},
					{
						frame = 50,
						autoDofJoints = {
							"hips"
						},
						focusArea = 0.08,
						focusDistance = "auto",
						focusTransition = 0.5,
						intensity = 0.01,
						nearIntensity = 0.2,
						targetActor = "p17_cameraplayer"
					}
				},
				jointName = "cs_camera04",
				near = 0.01,
				scaleCameraHeightToActorIndex = 30
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera04",
					transition = "cut"
				}
			}
		},
		playbackEvents = {
			{
				name = "CrowdEvent",
				frame = 50,
				animations = {
					{
						animGroup = native.ECrowdAnimGroup.excitement_level_3,
						tags = "TAGS_ALL"
					}
				},
				group = "full_time_applause",
				sounds = {
					{
						soundKey = "cheer_low",
						tags = "TAGS_ALL"
					}
				}
			}
		},
		povCameraAllowed = false,
		syncToWorldPositions = true,
		worldPos = {
			0,
			0
		},
		worldRot = 0
	},
	r25_FulltimeWinLose_05 = {
		animsetName = "r25_cutsceneFulltimeWinLose",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_fulltime_win_lose_cam05",
				filter = {
					actorType = "player",
					side = "secondary",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p2_cameraplayer",
				animName = "p2_fulltime_win_lose_cam05",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p3_cameraplayer",
				animName = "p3_fulltime_win_lose_cam05",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p4_cameraplayer",
				animName = "p4_fulltime_win_lose_cam05",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p5_cameraplayer",
				animName = "p5_fulltime_win_lose_cam05",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p6_cameraplayer",
				animName = "p6_fulltime_win_lose_cam05",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p7_cameraplayer",
				animName = "p7_fulltime_win_lose_cam05",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p8_cameraplayer",
				animName = "p8_fulltime_win_lose_cam05",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p9_cameraplayer",
				animName = "p9_fulltime_win_lose_cam05",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p10_cameraplayer",
				animName = "p10_fulltime_win_lose_cam05",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p11_cameraplayer",
				animName = "p11_fulltime_win_lose_cam05",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p12_cameraplayer",
				animName = "p12_fulltime_win_lose_cam05",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p13_cameraplayer",
				animName = "p13_fulltime_win_lose_cam05",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p14_cameraplayer",
				animName = "p14_fulltime_win_lose_cam05",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p15_cameraplayer",
				animName = "p15_fulltime_win_lose_cam05",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p16_cameraplayer",
				animName = "p16_fulltime_win_lose_cam05",
				filter = {
					actorType = "player",
					side = "primary",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p17_cameraplayer",
				animName = "p17_fulltime_win_lose_cam05",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p18_cameraplayer",
				animName = "p18_fulltime_win_lose_cam05",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p19_cameraplayer",
				animName = "p19_fulltime_win_lose_cam05",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p20_cameraplayer",
				animName = "p20_fulltime_win_lose_cam05",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p21_cameraplayer",
				animName = "p21_fulltime_win_lose_cam05",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p22_cameraplayer",
				animName = "p22_fulltime_win_lose_cam05",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p23_cameraplayer",
				animName = "p23_fulltime_win_lose_cam05",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p24_cameraplayer",
				animName = "p24_fulltime_win_lose_cam05",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p25_cameraplayer",
				animName = "p25_fulltime_win_lose_cam05",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p26_cameraplayer",
				animName = "p26_fulltime_win_lose_cam05",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p27_cameraplayer",
				animName = "p27_fulltime_win_lose_cam05",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p28_cameraplayer",
				animName = "p28_fulltime_win_lose_cam05",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p29_cameraplayer",
				animName = "p29_fulltime_win_lose_cam05",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p30_cameraplayer",
				animName = "p30_fulltime_win_lose_cam05",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			}
		},
		cameras = {
			{
				name = "cs_camera05",
				animName = "p1_fulltime_win_lose_cam05",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p5_cameraplayer"
					}
				},
				jointName = "cs_camera05",
				near = 0.1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera05",
					transition = "cut"
				}
			}
		},
		playbackEvents = {
			{
				name = "CrowdEvent",
				frame = 100,
				animations = {
					{
						animGroup = native.ECrowdAnimGroup.excitement_level_3,
						tags = "TAGS_ALL"
					}
				},
				group = "full_time_applause",
				sounds = {
					{
						soundKey = "cheer_mid",
						tags = "TAGS_ALL"
					}
				}
			}
		},
		povCameraAllowed = false,
		syncToWorldPositions = true,
		worldPos = {
			0,
			0
		},
		worldRot = 0
	},
	r25_FulltimeWinLose_06 = {
		animsetName = "r25_cutsceneFulltimeWinLose",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_fulltime_win_lose_cam07",
				filter = {
					actorType = "player",
					side = "secondary",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p2_cameraplayer",
				animName = "p2_fulltime_win_lose_cam07",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p3_cameraplayer",
				animName = "p3_fulltime_win_lose_cam07",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p4_cameraplayer",
				animName = "p4_fulltime_win_lose_cam07",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p5_cameraplayer",
				animName = "p5_fulltime_win_lose_cam07",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p6_cameraplayer",
				animName = "p6_fulltime_win_lose_cam07",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p7_cameraplayer",
				animName = "p7_fulltime_win_lose_cam07",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p8_cameraplayer",
				animName = "p8_fulltime_win_lose_cam07",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p9_cameraplayer",
				animName = "p9_fulltime_win_lose_cam07",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p10_cameraplayer",
				animName = "p10_fulltime_win_lose_cam07",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p11_cameraplayer",
				animName = "p11_fulltime_win_lose_cam07",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p12_cameraplayer",
				animName = "p12_fulltime_win_lose_cam07",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p13_cameraplayer",
				animName = "p13_fulltime_win_lose_cam07",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p14_cameraplayer",
				animName = "p14_fulltime_win_lose_cam07",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p15_cameraplayer",
				animName = "p15_fulltime_win_lose_cam07",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p16_cameraplayer",
				animName = "p16_fulltime_win_lose_cam07",
				filter = {
					actorType = "player",
					side = "primary",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p17_cameraplayer",
				animName = "p17_fulltime_win_lose_cam07",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p18_cameraplayer",
				animName = "p18_fulltime_win_lose_cam07",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p19_cameraplayer",
				animName = "p19_fulltime_win_lose_cam07",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p20_cameraplayer",
				animName = "p20_fulltime_win_lose_cam07",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p21_cameraplayer",
				animName = "p21_fulltime_win_lose_cam07",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p22_cameraplayer",
				animName = "p22_fulltime_win_lose_cam07",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p23_cameraplayer",
				animName = "p23_fulltime_win_lose_cam07",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p24_cameraplayer",
				animName = "p24_fulltime_win_lose_cam07",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p25_cameraplayer",
				animName = "p25_fulltime_win_lose_cam07",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p26_cameraplayer",
				animName = "p26_fulltime_win_lose_cam07",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p27_cameraplayer",
				animName = "p27_fulltime_win_lose_cam07",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p28_cameraplayer",
				animName = "p28_fulltime_win_lose_cam07",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p29_cameraplayer",
				animName = "p29_fulltime_win_lose_cam07",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p30_cameraplayer",
				animName = "p30_fulltime_win_lose_cam07",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			}
		},
		cameras = {
			{
				name = "cs_camera07",
				animName = "p1_fulltime_win_lose_cam07",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.8,
						nearIntensity = 0.7,
						targetActor = "p23_cameraplayer"
					},
					{
						frame = 105,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = "auto",
						focusTransition = 3,
						intensity = 0.8,
						nearIntensity = 0.7,
						targetActor = "p23_cameraplayer"
					},
					{
						frame = 120,
						autoDofJoints = {
							"hips"
						},
						focusArea = 0.5,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 1.5,
						nearIntensity = 2,
						targetActor = "p23_cameraplayer"
					}
				},
				jointName = "cs_camera07",
				near = 0.1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera07",
					transition = "cut"
				}
			}
		},
		playbackEvents = {
			{
				name = "CrowdEvent",
				frame = 0,
				animations = {
					{
						animGroup = native.ECrowdAnimGroup.excitement_level_3,
						tags = "TAGS_ALL"
					}
				},
				group = "full_time_applause",
				sounds = {
					{
						soundKey = "cheer_low",
						tags = "TAGS_ALL"
					}
				}
			}
		},
		povCameraAllowed = false,
		syncToWorldPositions = true,
		worldPos = {
			0,
			0
		},
		worldRot = 0
	},
	r25_FulltimeWinLose_07 = {
		animsetName = "r25_cutsceneFulltimeWinLose",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_fulltime_win_lose_cam06",
				filter = {
					actorType = "player",
					side = "secondary",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p2_cameraplayer",
				animName = "p2_fulltime_win_lose_cam06",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p3_cameraplayer",
				animName = "p3_fulltime_win_lose_cam06",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p4_cameraplayer",
				animName = "p4_fulltime_win_lose_cam06",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p5_cameraplayer",
				animName = "p5_fulltime_win_lose_cam06",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p6_cameraplayer",
				animName = "p6_fulltime_win_lose_cam06",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p7_cameraplayer",
				animName = "p7_fulltime_win_lose_cam06",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p8_cameraplayer",
				animName = "p8_fulltime_win_lose_cam06",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p9_cameraplayer",
				animName = "p9_fulltime_win_lose_cam06",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p10_cameraplayer",
				animName = "p10_fulltime_win_lose_cam06",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p11_cameraplayer",
				animName = "p11_fulltime_win_lose_cam06",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p12_cameraplayer",
				animName = "p12_fulltime_win_lose_cam06",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p13_cameraplayer",
				animName = "p13_fulltime_win_lose_cam06",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p14_cameraplayer",
				animName = "p14_fulltime_win_lose_cam06",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p15_cameraplayer",
				animName = "p15_fulltime_win_lose_cam06",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p16_cameraplayer",
				animName = "p16_fulltime_win_lose_cam06",
				filter = {
					actorType = "player",
					side = "primary",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p17_cameraplayer",
				animName = "p17_fulltime_win_lose_cam06",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p18_cameraplayer",
				animName = "p18_fulltime_win_lose_cam06",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p19_cameraplayer",
				animName = "p19_fulltime_win_lose_cam06",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p20_cameraplayer",
				animName = "p20_fulltime_win_lose_cam06",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p21_cameraplayer",
				animName = "p21_fulltime_win_lose_cam06",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p22_cameraplayer",
				animName = "p22_fulltime_win_lose_cam06",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p23_cameraplayer",
				animName = "p23_fulltime_win_lose_cam06",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p24_cameraplayer",
				animName = "p24_fulltime_win_lose_cam06",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p25_cameraplayer",
				animName = "p25_fulltime_win_lose_cam06",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p26_cameraplayer",
				animName = "p26_fulltime_win_lose_cam06",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p27_cameraplayer",
				animName = "p27_fulltime_win_lose_cam06",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p28_cameraplayer",
				animName = "p28_fulltime_win_lose_cam06",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p29_cameraplayer",
				animName = "p29_fulltime_win_lose_cam06",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p30_cameraplayer",
				animName = "p30_fulltime_win_lose_cam06",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			}
		},
		cameras = {
			{
				name = "cs_camera06",
				animName = "p1_fulltime_win_lose_cam06",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 1,
						nearIntensity = 1,
						targetActor = "p20_cameraplayer"
					}
				},
				jointName = "cs_camera06",
				near = 0.1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera06",
					transition = "cut"
				}
			}
		},
		playbackEvents = {
			{
				name = "CrowdEvent",
				frame = 5,
				animations = {
					{
						animGroup = native.ECrowdAnimGroup.excitement_level_3,
						tags = "TAGS_ALL"
					}
				},
				group = "full_time_applause",
				sounds = {
					{
						soundKey = "cheer_low_mid",
						tags = "TAGS_ALL"
					}
				}
			}
		},
		povCameraAllowed = false,
		syncToWorldPositions = true,
		worldPos = {
			0,
			0
		},
		worldRot = 0
	},
	r25_Handshakes_01 = {
		animsetName = "r25_cutsceneHandshakes",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_handshakes",
				filter = {
					actorType = "player",
					side = "secondary",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p2_cameraplayer",
				animName = "p2_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p3_cameraplayer",
				animName = "p3_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p4_cameraplayer",
				animName = "p4_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p5_cameraplayer",
				animName = "p5_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p6_cameraplayer",
				animName = "p6_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p7_cameraplayer",
				animName = "p7_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p8_cameraplayer",
				animName = "p8_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p9_cameraplayer",
				animName = "p9_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p10_cameraplayer",
				animName = "p10_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p11_cameraplayer",
				animName = "p11_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p12_cameraplayer",
				animName = "p12_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p13_cameraplayer",
				animName = "p13_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p14_cameraplayer",
				animName = "p14_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p15_cameraplayer",
				animName = "p15_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p16_cameraplayer",
				animName = "p16_handshakes",
				filter = {
					actorType = "player",
					side = "primary",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p17_cameraplayer",
				animName = "p17_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p18_cameraplayer",
				animName = "p18_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p19_cameraplayer",
				animName = "p19_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p20_cameraplayer",
				animName = "p20_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p21_cameraplayer",
				animName = "p21_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p22_cameraplayer",
				animName = "p22_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p23_cameraplayer",
				animName = "p23_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p24_cameraplayer",
				animName = "p24_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p25_cameraplayer",
				animName = "p25_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p26_cameraplayer",
				animName = "p26_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p27_cameraplayer",
				animName = "p27_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p28_cameraplayer",
				animName = "p28_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p29_cameraplayer",
				animName = "p29_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p30_cameraplayer",
				animName = "p30_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p18_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				near = 0.1
			},
			{
				name = "cs_camera02",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				near = 0.1
			},
			{
				name = "cs_camera03",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 125,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 15.33,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 0.5,
						targetActor = "p22_cameraplayer"
					},
					{
						frame = 144,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 18.15,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 0.5,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				near = 0.1
			},
			{
				name = "cs_camera04",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = 5,
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera04",
				near = 0.1
			},
			{
				name = "cs_camera05",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera05",
				near = 0.1
			},
			{
				name = "cs_camera06",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 17.15,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 1,
						targetActor = "p22_cameraplayer"
					},
					{
						frame = 180,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 14.68,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 1,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera06",
				near = 0.1
			},
			{
				name = "cs_camera07",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p25_cameraplayer"
					}
				},
				jointName = "cs_camera07",
				near = 0.1
			},
			{
				name = "cs_camera08",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p9_cameraplayer"
					}
				},
				jointName = "cs_camera08",
				near = 0.1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera08",
					transition = "cut"
				}
			}
		},
		povCameraAllowed = false,
		syncToWorldPositions = true,
		worldPos = {
			0,
			0
		},
		worldRot = 0
	},
	r25_Handshakes_02 = {
		animsetName = "r25_cutsceneHandshakes",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_handshakes",
				filter = {
					actorType = "player",
					side = "secondary",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p2_cameraplayer",
				animName = "p2_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p3_cameraplayer",
				animName = "p3_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p4_cameraplayer",
				animName = "p4_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p5_cameraplayer",
				animName = "p5_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p6_cameraplayer",
				animName = "p6_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p7_cameraplayer",
				animName = "p7_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p8_cameraplayer",
				animName = "p8_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p9_cameraplayer",
				animName = "p9_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p10_cameraplayer",
				animName = "p10_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p11_cameraplayer",
				animName = "p11_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p12_cameraplayer",
				animName = "p12_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p13_cameraplayer",
				animName = "p13_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p14_cameraplayer",
				animName = "p14_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p15_cameraplayer",
				animName = "p15_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p16_cameraplayer",
				animName = "p16_handshakes",
				filter = {
					actorType = "player",
					side = "primary",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p17_cameraplayer",
				animName = "p17_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p18_cameraplayer",
				animName = "p18_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p19_cameraplayer",
				animName = "p19_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p20_cameraplayer",
				animName = "p20_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p21_cameraplayer",
				animName = "p21_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p22_cameraplayer",
				animName = "p22_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p23_cameraplayer",
				animName = "p23_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p24_cameraplayer",
				animName = "p24_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p25_cameraplayer",
				animName = "p25_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p26_cameraplayer",
				animName = "p26_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p27_cameraplayer",
				animName = "p27_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p28_cameraplayer",
				animName = "p28_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p29_cameraplayer",
				animName = "p29_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p30_cameraplayer",
				animName = "p30_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p18_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				near = 0.1
			},
			{
				name = "cs_camera02",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				near = 0.1
			},
			{
				name = "cs_camera03",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 125,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 15.33,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 0.5,
						targetActor = "p22_cameraplayer"
					},
					{
						frame = 144,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 18.15,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 0.5,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				near = 0.1
			},
			{
				name = "cs_camera04",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = 5,
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera04",
				near = 0.1
			},
			{
				name = "cs_camera05",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera05",
				near = 0.1
			},
			{
				name = "cs_camera06",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 17.15,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 1,
						targetActor = "p22_cameraplayer"
					},
					{
						frame = 180,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 14.68,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 1,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera06",
				near = 0.1
			},
			{
				name = "cs_camera07",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p25_cameraplayer"
					}
				},
				jointName = "cs_camera07",
				near = 0.1
			},
			{
				name = "cs_camera08",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p9_cameraplayer"
					}
				},
				jointName = "cs_camera08",
				near = 0.1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera08",
					transition = "cut"
				}
			}
		},
		povCameraAllowed = false,
		syncToWorldPositions = true,
		worldPos = {
			0,
			0
		},
		worldRot = 0
	},
	r25_Handshakes_03 = {
		animsetName = "r25_cutsceneHandshakes",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_handshakes",
				filter = {
					actorType = "player",
					side = "secondary",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p2_cameraplayer",
				animName = "p2_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p3_cameraplayer",
				animName = "p3_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p4_cameraplayer",
				animName = "p4_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p5_cameraplayer",
				animName = "p5_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p6_cameraplayer",
				animName = "p6_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p7_cameraplayer",
				animName = "p7_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p8_cameraplayer",
				animName = "p8_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p9_cameraplayer",
				animName = "p9_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p10_cameraplayer",
				animName = "p10_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p11_cameraplayer",
				animName = "p11_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p12_cameraplayer",
				animName = "p12_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p13_cameraplayer",
				animName = "p13_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p14_cameraplayer",
				animName = "p14_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p15_cameraplayer",
				animName = "p15_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p16_cameraplayer",
				animName = "p16_handshakes",
				filter = {
					actorType = "player",
					side = "primary",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p17_cameraplayer",
				animName = "p17_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p18_cameraplayer",
				animName = "p18_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p19_cameraplayer",
				animName = "p19_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p20_cameraplayer",
				animName = "p20_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p21_cameraplayer",
				animName = "p21_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p22_cameraplayer",
				animName = "p22_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p23_cameraplayer",
				animName = "p23_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p24_cameraplayer",
				animName = "p24_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p25_cameraplayer",
				animName = "p25_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p26_cameraplayer",
				animName = "p26_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p27_cameraplayer",
				animName = "p27_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p28_cameraplayer",
				animName = "p28_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p29_cameraplayer",
				animName = "p29_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p30_cameraplayer",
				animName = "p30_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p18_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				near = 0.1
			},
			{
				name = "cs_camera02",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				near = 0.1
			},
			{
				name = "cs_camera03",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 125,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 15.33,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 0.5,
						targetActor = "p22_cameraplayer"
					},
					{
						frame = 144,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 18.15,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 0.5,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				near = 0.1
			},
			{
				name = "cs_camera04",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = 5,
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera04",
				near = 0.1
			},
			{
				name = "cs_camera05",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera05",
				near = 0.1
			},
			{
				name = "cs_camera06",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 17.15,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 1,
						targetActor = "p22_cameraplayer"
					},
					{
						frame = 180,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 14.68,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 1,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera06",
				near = 0.1
			},
			{
				name = "cs_camera07",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p25_cameraplayer"
					}
				},
				jointName = "cs_camera07",
				near = 0.1
			},
			{
				name = "cs_camera08",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p9_cameraplayer"
					}
				},
				jointName = "cs_camera08",
				near = 0.1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera08",
					transition = "cut"
				}
			}
		},
		povCameraAllowed = false,
		syncToWorldPositions = true,
		worldPos = {
			0,
			0
		},
		worldRot = 0
	},
	r25_Handshakes_04 = {
		animsetName = "r25_cutsceneHandshakes",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_handshakes",
				filter = {
					actorType = "player",
					side = "secondary",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p2_cameraplayer",
				animName = "p2_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p3_cameraplayer",
				animName = "p3_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p4_cameraplayer",
				animName = "p4_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p5_cameraplayer",
				animName = "p5_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p6_cameraplayer",
				animName = "p6_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p7_cameraplayer",
				animName = "p7_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p8_cameraplayer",
				animName = "p8_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p9_cameraplayer",
				animName = "p9_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p10_cameraplayer",
				animName = "p10_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p11_cameraplayer",
				animName = "p11_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p12_cameraplayer",
				animName = "p12_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p13_cameraplayer",
				animName = "p13_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p14_cameraplayer",
				animName = "p14_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p15_cameraplayer",
				animName = "p15_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p16_cameraplayer",
				animName = "p16_handshakes",
				filter = {
					actorType = "player",
					side = "primary",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p17_cameraplayer",
				animName = "p17_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p18_cameraplayer",
				animName = "p18_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p19_cameraplayer",
				animName = "p19_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p20_cameraplayer",
				animName = "p20_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p21_cameraplayer",
				animName = "p21_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p22_cameraplayer",
				animName = "p22_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p23_cameraplayer",
				animName = "p23_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p24_cameraplayer",
				animName = "p24_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p25_cameraplayer",
				animName = "p25_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p26_cameraplayer",
				animName = "p26_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p27_cameraplayer",
				animName = "p27_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p28_cameraplayer",
				animName = "p28_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p29_cameraplayer",
				animName = "p29_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p30_cameraplayer",
				animName = "p30_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p18_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				near = 0.1
			},
			{
				name = "cs_camera02",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				near = 0.1
			},
			{
				name = "cs_camera03",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 125,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 15.33,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 0.5,
						targetActor = "p22_cameraplayer"
					},
					{
						frame = 144,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 18.15,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 0.5,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				near = 0.1
			},
			{
				name = "cs_camera04",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = 5,
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera04",
				near = 0.1
			},
			{
				name = "cs_camera05",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera05",
				near = 0.1
			},
			{
				name = "cs_camera06",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 17.15,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 1,
						targetActor = "p22_cameraplayer"
					},
					{
						frame = 180,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 14.68,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 1,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera06",
				near = 0.1
			},
			{
				name = "cs_camera07",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p25_cameraplayer"
					}
				},
				jointName = "cs_camera07",
				near = 0.1
			},
			{
				name = "cs_camera08",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p9_cameraplayer"
					}
				},
				jointName = "cs_camera08",
				near = 0.1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera08",
					transition = "cut"
				}
			}
		},
		povCameraAllowed = false,
		syncToWorldPositions = true,
		worldPos = {
			0,
			0
		},
		worldRot = 0
	},
	r25_Handshakes_05 = {
		animsetName = "r25_cutsceneHandshakes",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_handshakes",
				filter = {
					actorType = "player",
					side = "secondary",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p2_cameraplayer",
				animName = "p2_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p3_cameraplayer",
				animName = "p3_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p4_cameraplayer",
				animName = "p4_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p5_cameraplayer",
				animName = "p5_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p6_cameraplayer",
				animName = "p6_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p7_cameraplayer",
				animName = "p7_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p8_cameraplayer",
				animName = "p8_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p9_cameraplayer",
				animName = "p9_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p10_cameraplayer",
				animName = "p10_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p11_cameraplayer",
				animName = "p11_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p12_cameraplayer",
				animName = "p12_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p13_cameraplayer",
				animName = "p13_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p14_cameraplayer",
				animName = "p14_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p15_cameraplayer",
				animName = "p15_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p16_cameraplayer",
				animName = "p16_handshakes",
				filter = {
					actorType = "player",
					side = "primary",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p17_cameraplayer",
				animName = "p17_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p18_cameraplayer",
				animName = "p18_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p19_cameraplayer",
				animName = "p19_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p20_cameraplayer",
				animName = "p20_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p21_cameraplayer",
				animName = "p21_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p22_cameraplayer",
				animName = "p22_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p23_cameraplayer",
				animName = "p23_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p24_cameraplayer",
				animName = "p24_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p25_cameraplayer",
				animName = "p25_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p26_cameraplayer",
				animName = "p26_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p27_cameraplayer",
				animName = "p27_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p28_cameraplayer",
				animName = "p28_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p29_cameraplayer",
				animName = "p29_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p30_cameraplayer",
				animName = "p30_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p18_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				near = 0.1
			},
			{
				name = "cs_camera02",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				near = 0.1
			},
			{
				name = "cs_camera03",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 125,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 15.33,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 0.5,
						targetActor = "p22_cameraplayer"
					},
					{
						frame = 144,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 18.15,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 0.5,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				near = 0.1
			},
			{
				name = "cs_camera04",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = 5,
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera04",
				near = 0.1
			},
			{
				name = "cs_camera05",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera05",
				near = 0.1
			},
			{
				name = "cs_camera06",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 17.15,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 1,
						targetActor = "p22_cameraplayer"
					},
					{
						frame = 180,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 14.68,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 1,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera06",
				near = 0.1
			},
			{
				name = "cs_camera07",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p25_cameraplayer"
					}
				},
				jointName = "cs_camera07",
				near = 0.1
			},
			{
				name = "cs_camera08",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p9_cameraplayer"
					}
				},
				jointName = "cs_camera08",
				near = 0.1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera08",
					transition = "cut"
				}
			}
		},
		povCameraAllowed = false,
		syncToWorldPositions = true,
		worldPos = {
			0,
			0
		},
		worldRot = 0
	},
	r25_Handshakes_06 = {
		animsetName = "r25_cutsceneHandshakes",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_handshakes",
				filter = {
					actorType = "player",
					side = "secondary",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p2_cameraplayer",
				animName = "p2_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p3_cameraplayer",
				animName = "p3_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p4_cameraplayer",
				animName = "p4_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p5_cameraplayer",
				animName = "p5_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p6_cameraplayer",
				animName = "p6_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p7_cameraplayer",
				animName = "p7_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p8_cameraplayer",
				animName = "p8_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p9_cameraplayer",
				animName = "p9_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p10_cameraplayer",
				animName = "p10_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p11_cameraplayer",
				animName = "p11_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p12_cameraplayer",
				animName = "p12_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p13_cameraplayer",
				animName = "p13_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p14_cameraplayer",
				animName = "p14_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p15_cameraplayer",
				animName = "p15_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p16_cameraplayer",
				animName = "p16_handshakes",
				filter = {
					actorType = "player",
					side = "primary",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p17_cameraplayer",
				animName = "p17_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p18_cameraplayer",
				animName = "p18_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p19_cameraplayer",
				animName = "p19_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p20_cameraplayer",
				animName = "p20_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p21_cameraplayer",
				animName = "p21_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p22_cameraplayer",
				animName = "p22_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p23_cameraplayer",
				animName = "p23_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p24_cameraplayer",
				animName = "p24_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p25_cameraplayer",
				animName = "p25_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p26_cameraplayer",
				animName = "p26_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p27_cameraplayer",
				animName = "p27_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p28_cameraplayer",
				animName = "p28_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p29_cameraplayer",
				animName = "p29_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p30_cameraplayer",
				animName = "p30_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p18_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				near = 0.1
			},
			{
				name = "cs_camera02",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				near = 0.1
			},
			{
				name = "cs_camera03",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 125,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 15.33,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 0.5,
						targetActor = "p22_cameraplayer"
					},
					{
						frame = 144,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 18.15,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 0.5,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				near = 0.1
			},
			{
				name = "cs_camera04",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = 5,
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera04",
				near = 0.1
			},
			{
				name = "cs_camera05",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera05",
				near = 0.1
			},
			{
				name = "cs_camera06",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 17.15,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 1,
						targetActor = "p22_cameraplayer"
					},
					{
						frame = 180,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 14.68,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 1,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera06",
				near = 0.1
			},
			{
				name = "cs_camera07",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p25_cameraplayer"
					}
				},
				jointName = "cs_camera07",
				near = 0.1
			},
			{
				name = "cs_camera08",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p9_cameraplayer"
					}
				},
				jointName = "cs_camera08",
				near = 0.1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera08",
					transition = "cut"
				}
			}
		},
		povCameraAllowed = false,
		syncToWorldPositions = true,
		worldPos = {
			0,
			0
		},
		worldRot = 0
	},
	r25_Handshakes_07 = {
		animsetName = "r25_cutsceneHandshakes",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_handshakes",
				filter = {
					actorType = "player",
					side = "secondary",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p2_cameraplayer",
				animName = "p2_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p3_cameraplayer",
				animName = "p3_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p4_cameraplayer",
				animName = "p4_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p5_cameraplayer",
				animName = "p5_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p6_cameraplayer",
				animName = "p6_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p7_cameraplayer",
				animName = "p7_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p8_cameraplayer",
				animName = "p8_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p9_cameraplayer",
				animName = "p9_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p10_cameraplayer",
				animName = "p10_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p11_cameraplayer",
				animName = "p11_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p12_cameraplayer",
				animName = "p12_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p13_cameraplayer",
				animName = "p13_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p14_cameraplayer",
				animName = "p14_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p15_cameraplayer",
				animName = "p15_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p16_cameraplayer",
				animName = "p16_handshakes",
				filter = {
					actorType = "player",
					side = "primary",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p17_cameraplayer",
				animName = "p17_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p18_cameraplayer",
				animName = "p18_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p19_cameraplayer",
				animName = "p19_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p20_cameraplayer",
				animName = "p20_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p21_cameraplayer",
				animName = "p21_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p22_cameraplayer",
				animName = "p22_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p23_cameraplayer",
				animName = "p23_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p24_cameraplayer",
				animName = "p24_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p25_cameraplayer",
				animName = "p25_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p26_cameraplayer",
				animName = "p26_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p27_cameraplayer",
				animName = "p27_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p28_cameraplayer",
				animName = "p28_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p29_cameraplayer",
				animName = "p29_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p30_cameraplayer",
				animName = "p30_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p18_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				near = 0.1
			},
			{
				name = "cs_camera02",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				near = 0.1
			},
			{
				name = "cs_camera03",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 125,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 15.33,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 0.5,
						targetActor = "p22_cameraplayer"
					},
					{
						frame = 144,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 18.15,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 0.5,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				near = 0.1
			},
			{
				name = "cs_camera04",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = 5,
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera04",
				near = 0.1
			},
			{
				name = "cs_camera05",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera05",
				near = 0.1
			},
			{
				name = "cs_camera06",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 17.15,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 1,
						targetActor = "p22_cameraplayer"
					},
					{
						frame = 180,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 14.68,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 1,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera06",
				near = 0.1
			},
			{
				name = "cs_camera07",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p25_cameraplayer"
					}
				},
				jointName = "cs_camera07",
				near = 0.1
			},
			{
				name = "cs_camera08",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p9_cameraplayer"
					}
				},
				jointName = "cs_camera08",
				near = 0.1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera08",
					transition = "cut"
				}
			}
		},
		povCameraAllowed = false,
		syncToWorldPositions = true,
		worldPos = {
			0,
			0
		},
		worldRot = 0
	},
	r25_Handshakes_08 = {
		animsetName = "r25_cutsceneHandshakes",
		actors = {
			{
				name = "p1_cameraplayer",
				animName = "p1_handshakes",
				filter = {
					actorType = "player",
					side = "secondary",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p2_cameraplayer",
				animName = "p2_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p3_cameraplayer",
				animName = "p3_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p4_cameraplayer",
				animName = "p4_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p5_cameraplayer",
				animName = "p5_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p6_cameraplayer",
				animName = "p6_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p7_cameraplayer",
				animName = "p7_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p8_cameraplayer",
				animName = "p8_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p9_cameraplayer",
				animName = "p9_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p10_cameraplayer",
				animName = "p10_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p11_cameraplayer",
				animName = "p11_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p12_cameraplayer",
				animName = "p12_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p13_cameraplayer",
				animName = "p13_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p14_cameraplayer",
				animName = "p14_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p15_cameraplayer",
				animName = "p15_handshakes",
				filter = {
					actorType = "player",
					side = "secondary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p16_cameraplayer",
				animName = "p16_handshakes",
				filter = {
					actorType = "player",
					side = "primary",
					specialRole = "captain"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p17_cameraplayer",
				animName = "p17_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p18_cameraplayer",
				animName = "p18_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p19_cameraplayer",
				animName = "p19_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p20_cameraplayer",
				animName = "p20_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p21_cameraplayer",
				animName = "p21_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p22_cameraplayer",
				animName = "p22_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p23_cameraplayer",
				animName = "p23_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p24_cameraplayer",
				animName = "p24_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p25_cameraplayer",
				animName = "p25_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p26_cameraplayer",
				animName = "p26_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p27_cameraplayer",
				animName = "p27_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p28_cameraplayer",
				animName = "p28_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p29_cameraplayer",
				animName = "p29_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			},
			{
				name = "p30_cameraplayer",
				animName = "p30_handshakes",
				filter = {
					actorType = "player",
					side = "primary"
				},
				optional = true,
				syncOnFrame = 0
			}
		},
		cameras = {
			{
				name = "cs_camera01",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p18_cameraplayer"
					}
				},
				jointName = "cs_camera01",
				near = 0.1
			},
			{
				name = "cs_camera02",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera02",
				near = 0.1
			},
			{
				name = "cs_camera03",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 125,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 15.33,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 0.5,
						targetActor = "p22_cameraplayer"
					},
					{
						frame = 144,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 18.15,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 0.5,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera03",
				near = 0.1
			},
			{
				name = "cs_camera04",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = 5,
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera04",
				near = 0.1
			},
			{
				name = "cs_camera05",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 3,
						focusDistance = "auto",
						focusTransition = 2,
						intensity = 0,
						nearIntensity = 0,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera05",
				near = 0.1
			},
			{
				name = "cs_camera06",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 17.15,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 1,
						targetActor = "p22_cameraplayer"
					},
					{
						frame = 180,
						autoDofJoints = {
							"hips"
						},
						focusArea = 1,
						focusDistance = 14.68,
						focusTransition = 1,
						intensity = 0.5,
						nearIntensity = 1,
						targetActor = "p22_cameraplayer"
					}
				},
				jointName = "cs_camera06",
				near = 0.1
			},
			{
				name = "cs_camera07",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p25_cameraplayer"
					}
				},
				jointName = "cs_camera07",
				near = 0.1
			},
			{
				name = "cs_camera08",
				animName = "p1_handshakes",
				dof = {
					{
						frame = 0,
						autoDofJoints = {
							"hips"
						},
						focusArea = 10,
						focusDistance = "auto",
						focusTransition = 10,
						intensity = 0.01,
						nearIntensity = 0,
						targetActor = "p9_cameraplayer"
					}
				},
				jointName = "cs_camera08",
				near = 0.1
			}
		},
		clampScale = native.CRange(1, 1),
		cuts = {
			{
				{
					frame = 0,
					camera = "cs_camera08",
					transition = "cut"
				}
			}
		},
		povCameraAllowed = false,
		syncToWorldPositions = true,
		worldPos = {
			0,
			0
		},
		worldRot = 0
	}
}
